#!/usr/bin/env python3
"""Diff the *tracked* portage config in this repo against the live system.
Only paths listed in TARGETS are compared.
Lines starting with '#' are ignored.
"""

import os
import platform
import sys
from pathlib import Path

# repo path (hardcoded assumptions)
PKG_CONF_DIR = {
    # "make.hostname.conf": "/etc/portage/make.conf",
    "world": "/var/lib/portage/world",
    "package.use/": "/etc/portage/package.use/",
    "package.accept_keywords/": "/etc/portage/package.accept_keywords/",
    "package.license/": "/etc/portage/package.license/",
}


def _get_lines(path: Path) -> set[str]:
    if not path.exists():
        return set()
    out = set()
    for raw in path.read_text().splitlines():
        line = raw.strip()
        if line and not line.startswith("#"):
            out.add(line)
    return out


def compare_cfg(repo_path: Path, host_path: Path):
    r_lines, h_lines = _get_lines(repo_path), _get_lines(host_path)
    r_only = sorted(r_lines - h_lines)
    h_only = sorted(h_lines - r_lines)
    if len(r_only) + len(h_only) > 0:
        print(f"{host_path} diff:")
        print("====")
        if len(r_only) > 0:
            print("[-]")
            for l in r_only:
                print(l)
        if len(h_only) > 0:
            print("[+]")
            for l in h_only:
                print(l)
        print()
    return


def main() -> int:
    if len(sys.argv) > 1:
        hostname = sys.argv[1]
    else:
        hostname = platform.node()
        PKG_CONF_DIR[f"make.{hostname}.conf"] = "/etc/portage/make.conf"

    for repo_dir_s, host_dir_s in PKG_CONF_DIR.items():
        repo_dir, host_dir = Path(repo_dir_s), Path(host_dir_s)
        if not host_dir.exists():
            print(f"[Skip] {host_dir} missing on host.")
            continue

        if repo_dir.is_file():
            compare_cfg(repo_dir, host_dir)
        else:
            for rp in repo_dir.iterdir():
                if not rp.is_file():
                    continue
                hp = host_dir / rp.name
                if hp.exists():
                    compare_cfg(rp, hp)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
