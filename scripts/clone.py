#!/usr/bin/env python3

import argparse
import os
import subprocess
from urllib.parse import urlparse

"""
    Parse the organization and repository from several github URL formats, like:
    "https://github.com/koxudaxi/datamodel-code-generator",
    "https://github.com/koxudaxi/datamodel-code-generator.git",
    "git@github.com:koxudaxi/datamodel-code-generator.git",
    "koxudaxi/datamodel-code-generator"
    returns tuple (org, repo)
"""
def parse_git_url(url) -> tuple[str]:
    path = ""
    if url.startswith("git@"):
        parts = url.split(":")
        path = parts[1]
    elif url.startswith("http") or url.startswith("https"):
        parsed_url = urlparse(url)
        path = parsed_url.path[1:]
    else:
        path = url

    if path.endswith(".git"):
        path = path[:-4]
        # todo make it work for https://github.com/adrianisk/sqlglot/
    org, repo = path.split("/")

    return org, repo


def main():
    parser = argparse.ArgumentParser(description="Clone a git repository.")
    parser.add_argument("url", type=str, help="The URL of the git repository")
    args = parser.parse_args()

    org, repo = parse_git_url(args.url)
    dest = os.path.expanduser(f"~/code/{org}/{repo}")

    if os.path.exists(dest):
        print(f"The repository {org}/{repo} is already cloned at {dest}.")
        return
    if not os.path.exists(os.path.dirname(dest)):
        os.makedirs(os.path.dirname(dest))

    full_repo = f"{org}/{repo}"
    print(f"Cloning {full_repo} to {dest}")
    subprocess.run(["gh", "repo", "clone", full_repo, dest])


if __name__ == "__main__":
    main()
