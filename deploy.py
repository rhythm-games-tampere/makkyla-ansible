#!/usr/bin/env python3

import argparse
import os
import sys

PLAYBOOK = "full-install.yml"
INVENTORY = "inventories/makkyla"
ALL_HOSTS_GROUP = "dedicab"


def main():
    parser = argparse.ArgumentParser(
        description="Run the full-install playbook against one or all arcade machines.",
        epilog="Arguments after -- are passed through to ansible-playbook, "
        "e.g. ./deploy.py --limit ten -- --tags hardware --check",
    )
    target = parser.add_mutually_exclusive_group(required=True)
    target.add_argument(
        "--limit",
        metavar="HOST",
        help="deploy to a single machine (e.g. pro, fat, ten)",
    )
    target.add_argument(
        "--all",
        action="store_true",
        help=f"deploy to all machines in the {ALL_HOSTS_GROUP} group",
    )
    parser.add_argument(
        "--itgmania-repo",
        metavar="URL",
        help="override the ITGmania git repository "
        "(default: rhythm-games-tampere/itgmania)",
    )
    parser.add_argument(
        "--itgmania-branch",
        metavar="REF",
        help="override the ITGmania branch/tag/commit to build (default: stable)",
    )
    parser.add_argument(
        "--simplylove-repo",
        metavar="URL",
        help="override the Simply Love theme git repository "
        "(default: rhythm-games-tampere/simplylove)",
    )
    parser.add_argument(
        "--simplylove-branch",
        metavar="REF",
        help="override the Simply Love branch/tag/commit to install "
        "(default: stable)",
    )
    argv = sys.argv[1:]
    extra = []
    if "--" in argv:
        split = argv.index("--")
        argv, extra = argv[:split], argv[split + 1 :]
    args = parser.parse_args(argv)

    limit = ALL_HOSTS_GROUP if args.all else args.limit
    cmd = ["ansible-playbook", "-i", INVENTORY, PLAYBOOK, "--diff", "--limit", limit, "-K"]
    overrides = {
        "itgmania_repo": args.itgmania_repo,
        "itgmania_version": args.itgmania_branch,
        "simplylove_repo": args.simplylove_repo,
        "simplylove_version": args.simplylove_branch,
    }
    for var, value in overrides.items():
        if value is not None:
            cmd += ["-e", f"{var}={value}"]
    cmd += extra

    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    print("+ " + " ".join(cmd), file=sys.stderr)
    try:
        os.execvp(cmd[0], cmd)
    except FileNotFoundError:
        sys.exit("error: ansible-playbook not found on PATH")


if __name__ == "__main__":
    main()
