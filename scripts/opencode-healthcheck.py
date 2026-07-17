#!/usr/bin/env python3

import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path


HOME = Path.home()
CONFIG_PATH = HOME / ".config" / "opencode" / "opencode.jsonc"
STATE_KV_PATH = HOME / ".local" / "state" / "opencode" / "kv.json"
HAMMERSPOON_PATH = HOME / "code" / "mjperrone" / "dot_files" / "init.lua"
EXPECTED_MCPS = ["linear", "notion", "monarch", "ha-mcp", "google-workspace"]


def strip_jsonc(text):
    result = []
    in_string = False
    escape = False
    i = 0

    while i < len(text):
        char = text[i]
        next_char = text[i + 1] if i + 1 < len(text) else ""

        if in_string:
            result.append(char)
            if escape:
                escape = False
            elif char == "\\":
                escape = True
            elif char == '"':
                in_string = False
            i += 1
            continue

        if char == '"':
            in_string = True
            result.append(char)
            i += 1
            continue

        if char == "/" and next_char == "/":
            i = text.find("\n", i)
            if i == -1:
                break
            result.append("\n")
            i += 1
            continue

        if char == "/" and next_char == "*":
            end = text.find("*/", i + 2)
            i = len(text) if end == -1 else end + 2
            continue

        result.append(char)
        i += 1

    without_comments = "".join(result)
    return re.sub(r",\s*([}\]])", r"\1", without_comments)


def load_jsonc(path):
    return json.loads(strip_jsonc(path.read_text()))


def expand_config_string(value):
    if not isinstance(value, str):
        return value
    return value.replace("{env:HOME}", str(HOME))


def status(icon, message):
    print(f"{icon} {message}")


def ok(message):
    status("OK", message)


def warn(message):
    status("WARN", message)


def fail(message):
    status("FAIL", message)


def command_version(command):
    try:
        result = subprocess.run(command, check=False, capture_output=True, text=True, timeout=10)
    except (OSError, subprocess.TimeoutExpired) as error:
        return None, str(error)

    output = (result.stdout or result.stderr).strip().splitlines()
    return (output[0] if output else "available"), None if result.returncode == 0 else f"exit {result.returncode}"


def has_secret_like_value(value):
    if not isinstance(value, str):
        return False
    lower = value.lower()
    return "bearer " in lower or "token" in lower or bool(re.search(r"[a-zA-Z0-9_-]{24,}\.[a-zA-Z0-9_-]{24,}", value))


def has_machine_specific_home_path(value):
    if not isinstance(value, str):
        return False
    return bool(re.search(r"/Users/[^/]+/", value))


def check_local_command(name, command):
    if not command:
        warn(f"{name}: local MCP has no command")
        return False

    executable = command[0]
    if executable.startswith("/"):
        if Path(executable).exists():
            ok(f"{name}: executable exists ({executable})")
            return True
        else:
            fail(f"{name}: executable missing ({executable})")
            return False

    if shutil.which(executable):
        ok(f"{name}: command found ({executable})")
        return True
    else:
        fail(f"{name}: command not found ({executable})")
        return False


def main():
    hard_failures = 0

    print("OpenCode Health")

    opencode = shutil.which("opencode")
    if opencode:
        version, error = command_version([opencode, "--version"])
        if error:
            warn(f"opencode found but version check failed: {error}")
        else:
            ok(f"opencode available ({version})")
    else:
        fail("opencode is not on PATH")
        hard_failures += 1

    if CONFIG_PATH.exists():
        ok(f"config exists ({CONFIG_PATH})")
    else:
        fail(f"config missing ({CONFIG_PATH})")
        return 1

    try:
        config = load_jsonc(CONFIG_PATH)
        ok("config parses as JSONC")
    except Exception as error:
        fail(f"config parse failed: {error}")
        return 1

    if config.get("$schema") == "https://opencode.ai/config.json":
        ok("config schema URL is set")
    else:
        warn("config schema URL is missing or unexpected")

    config_text = CONFIG_PATH.read_text()
    if has_machine_specific_home_path(config_text):
        warn("config contains hardcoded /Users/<name>/ paths; prefer {env:HOME}")
    else:
        ok("config avoids hardcoded home-directory paths")

    experimental = config.get("experimental") or {}
    if experimental.get("disable_paste_summary") is True:
        ok("paste summaries disabled for dictation-friendly input")
    else:
        warn("paste summaries are not disabled")

    if STATE_KV_PATH.exists():
        try:
            kv = json.loads(STATE_KV_PATH.read_text())
            if kv.get("paste_summary_enabled") is True:
                warn("runtime KV re-enabled paste summaries")
            else:
                ok("runtime KV does not re-enable paste summaries")
        except Exception as error:
            warn(f"runtime KV could not be read: {error}")
    else:
        ok("runtime KV file absent")

    mcps = config.get("mcp") or {}
    for name in EXPECTED_MCPS:
        mcp = mcps.get(name)
        if not mcp:
            warn(f"{name}: MCP not configured")
            continue

        if mcp.get("enabled", True) is False:
            warn(f"{name}: MCP configured but disabled")
        else:
            ok(f"{name}: MCP enabled")

        if mcp.get("type") == "local":
            if not check_local_command(name, mcp.get("command") or []):
                hard_failures += 1
        elif mcp.get("type") == "remote":
            if mcp.get("url"):
                ok(f"{name}: remote URL configured")
            else:
                fail(f"{name}: remote MCP missing URL")
                hard_failures += 1
        else:
            warn(f"{name}: unknown MCP type {mcp.get('type')!r}")

        headers = mcp.get("headers") or {}
        for header_name, header_value in headers.items():
            if has_secret_like_value(header_value):
                warn(f"{name}: header {header_name} looks like an embedded secret")

        for value in mcp.get("command") or []:
            expanded = expand_config_string(value)
            if has_machine_specific_home_path(value):
                warn(f"{name}: command contains hardcoded home path")
            if isinstance(expanded, str) and expanded.startswith(str(HOME) + "/") and not Path(expanded).exists():
                warn(f"{name}: referenced path missing ({expanded})")

    if HAMMERSPOON_PATH.exists():
        text = HAMMERSPOON_PATH.read_text()
        if "enabledHostnames" in text and "OpenCode server" in text:
            ok("Hammerspoon OpenCode menu is host-allowlisted")
        elif "OpenCode server" in text:
            warn("Hammerspoon OpenCode menu exists but is not host-allowlisted")
        else:
            warn("Hammerspoon OpenCode menu not found")
    else:
        warn(f"Hammerspoon config not found ({HAMMERSPOON_PATH})")

    return 1 if hard_failures else 0


if __name__ == "__main__":
    sys.exit(main())
