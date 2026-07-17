#!/usr/bin/env python3

import argparse
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FEEDBACK = ROOT / "scripts" / "opencode-feedback.py"
HEALTHCHECK = ROOT / "scripts" / "opencode-healthcheck.py"


def run(command, cwd=ROOT):
    return subprocess.run(command, cwd=cwd, check=False, capture_output=True, text=True)


def print_section(title, body):
    print(f"\n## {title}")
    print(body.strip() or "(none)")


def main():
    parser = argparse.ArgumentParser(description="End-of-session OpenCode Ops review helper.")
    parser.add_argument("--summary", help="Record a session summary as a Lighthouse signal.")
    parser.add_argument("--followup", action="append", help="Follow-up to record with --summary. Can be repeated.")
    parser.add_argument("--no-healthcheck", action="store_true", help="Skip running the OpenCode healthcheck.")
    args = parser.parse_args()

    print("OpenCode Session Review")
    print_section("Git Status", run(["git", "status", "--short", "--branch"]).stdout)

    if not args.no_healthcheck and HEALTHCHECK.exists():
        health = run([str(HEALTHCHECK)])
        print_section("OpenCode Health", health.stdout + health.stderr)

    print_section(
        "Checklist",
        "\n".join(
            [
                "- Did intended files get committed or intentionally left dirty?",
                "- Did Lighthouse get a signal for completed work or new friction?",
                "- Did anything annoying happen that should become feedback?",
                "- Is there one clear next action?",
            ]
        ),
    )

    if args.summary:
        command = [str(FEEDBACK), args.summary, "--kind", "session-review"]
        for followup in args.followup or []:
            command.extend(["--followup", followup])
        subprocess.run(command, check=True)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
