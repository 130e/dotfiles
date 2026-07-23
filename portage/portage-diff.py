#!/usr/bin/env python3
"""Diff the *tracked* portage config in this repo against the live system.

Only paths listed in TARGETS are compared.
zz-autounmask, steam, etc. are ignored on purpose.
Lines starting with '#' symbols are ignored.
"""

import os
import platform
import sys
from pathlib import Path

# repo path (relative to this file) -> live system path
TARGETS = {
    "worldset": "/var/lib/portage/world",
    "package.use/main": "/etc/portage/package.use/main",
    "package.accept_keywords/main": "/etc/portage/package.accept_keywords/main",
    "package.license/main": "/etc/portage/package.license",
}


def get_lines(path: Path) -> set[str]:
    """Non-comment, non-blank lines as a set."""
    if not path.exists():
        return set()
    out = set()
    for raw in path.read_text().splitlines():
        line = raw.strip()
        if line and not line.startswith("#"):
            out.add(line)
    return out


def main() -> int:
    if len(sys.argv) > 1:
        hostname = sys.argv[1]
    else:
        hostname = platform.node()
        TARGETS[f"make.{hostname}.conf"] = "/etc/portage/make.conf"

    diffs = 0

    for rel, sys_path in TARGETS.items():
        repo, live = Path(rel), Path(sys_path)

        if not repo.exists():
            print(f"{rel}  (not in repo)")
            continue
        if not live.exists():
            print(f"{rel}  (not on system: {sys_path})")
            continue

        repo_lines, live_lines = get_lines(repo), get_lines(live)
        only_repo = sorted(repo_lines - live_lines)  # in repo, not on this box
        only_live = sorted(live_lines - repo_lines)  # on box, not tracked

        diffs += 1
        print(f"DIFF {rel}  vs  {sys_path}")
        for line in only_repo:
            print(f"  - {line}")  # missing on this machine
        for line in only_live:
            print(f"  + {line}")  # untracked / would add to repo
        print()

    return 1 if diffs else 0


if __name__ == "__main__":
    raise SystemExit(main())
