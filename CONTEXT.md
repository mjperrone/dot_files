# dot_files Context

## Purpose

Personal development environment and workflow automation. This repo holds shell config, Hammerspoon automation, userscripts, browser shortcuts, and small local scripts that improve day-to-day agent-assisted work.

## Current OpenCode Ops State

- `init.lua` owns the Hammerspoon menu bar status for the local OpenCode server.
- The OpenCode menu is host-allowlisted to Mike's MacBook Pro.
- The menu can open, start, restart, refresh, and healthcheck OpenCode.
- `scripts/opencode-healthcheck.py` checks OpenCode config, expected MCPs, paste-summary state, and Hammerspoon menu setup.
- OpenCode global config lives at `~/.config/opencode/opencode.jsonc`, outside this repo.

## Agent Startup

1. Run `git status --short --branch` before editing.
2. Run `scripts/opencode-healthcheck.py` for OpenCode/MCP baseline work.
3. Read `init.lua` before changing Hammerspoon behavior.
4. Avoid committing unrelated dirty files; this repo often has local scratch artifacts.

## Verification

- Hammerspoon Lua: `luac -p init.lua`
- Healthcheck Python: `python3 -m py_compile scripts/opencode-healthcheck.py`
- OpenCode health: `scripts/opencode-healthcheck.py`
- Git whitespace: `git diff --check`

## Guardrails

- Do not commit secrets, tokens, `.env`, or generated scratch files.
- Do not modify unrelated dirty files unless explicitly asked.
- Prefer small local scripts over fragile always-on automation.
- For OpenCode config changes, use `~/.config/opencode/opencode.jsonc` and restart OpenCode afterward.
