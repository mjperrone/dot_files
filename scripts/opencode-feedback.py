#!/usr/bin/env python3

import argparse
import subprocess
from pathlib import Path


DEFAULT_LIGHTHOUSE = Path.home() / "code" / "mjperrone" / "lighthouse" / "scripts" / "project_nudges.py"


def main():
    parser = argparse.ArgumentParser(description="Record OpenCode Ops feedback in Lighthouse.")
    parser.add_argument("summary", help="Short feedback or friction note to record.")
    parser.add_argument("--followup", action="append", help="Suggested follow-up. Can be repeated.")
    parser.add_argument("--kind", default="feedback", help="Signal kind. Defaults to feedback.")
    parser.add_argument("--project", default="opencode-ops", help="Lighthouse project slug.")
    parser.add_argument("--lighthouse", default=str(DEFAULT_LIGHTHOUSE), help="Path to project_nudges.py.")
    parser.add_argument("--dry-run", action="store_true", help="Print the command instead of running it.")
    args = parser.parse_args()

    lighthouse = Path(args.lighthouse).expanduser()
    command = [str(lighthouse), "add-signal", args.project, args.summary, "--kind", args.kind]
    for followup in args.followup or []:
        command.extend(["--followup", followup])

    if args.dry_run:
        print(" ".join(command))
        return 0

    if not lighthouse.exists():
        parser.error(f"Lighthouse script not found: {lighthouse}")

    subprocess.run(command, check=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
