#!/usr/bin/env python3
"""Prüft die Versionsordner des Registers.

Zwei Regeln, beide aus dem Aufbau `<paket>/<version>/`:

1. Jeder Versionsordner sagt in seiner `typst.toml` dieselbe Version wie sein
   Name. Ein Submodul, dessen Zeiger auf einen Stand mit anderer Nummer
   rutscht, fällt hier auf.

2. Eine Version, die auf Typst Universe steht (also per PR an typst/packages
   veröffentlicht wurde), ist eingefroren: Änderungen darin — Dateien oder
   der Zeiger eines Submoduls — gehören in eine neue Version. Was
   veröffentlicht ist, sagt `https://packages.typst.org/preview/index.json`.

    versionen-pruefen.py                 # nur Regel 1
    versionen-pruefen.py --basis <ref>   # dazu Regel 2 für alles, was sich
                                         # seit <ref> geändert hat

Beendet sich mit 1, wenn eine Regel verletzt ist, und sagt, was zu tun ist.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
INDEX_URL = "https://packages.typst.org/preview/index.json"
VERSION_RE = re.compile(r"^\d+\.\d+\.\d+$")
PATH_RE = re.compile(r"^([A-Za-z0-9_-]+)/(\d+\.\d+\.\d+)(?:/|$)")


def toml_version(path: Path) -> str | None:
    """Die Version aus `[package]` — ohne tomllib, das erst Python 3.11 hat."""
    if not path.exists():
        return None
    for line in path.read_text(encoding="utf-8").splitlines():
        m = re.match(r'^\s*version\s*=\s*"([^"]+)"', line)
        if m:
            return m.group(1)
    return None


def version_folders() -> list[tuple[str, str, Path]]:
    found = []
    for pkg in sorted(REPO.iterdir()):
        if not pkg.is_dir() or pkg.name.startswith("."):
            continue
        for ver in sorted(pkg.iterdir()):
            if ver.is_dir() and VERSION_RE.match(ver.name):
                found.append((pkg.name, ver.name, ver))
    return found


def released() -> set[tuple[str, str]] | None:
    """(name, version) für alles auf Universe; None, wenn das Verzeichnis
    nicht erreichbar ist."""
    for attempt in range(3):
        try:
            with urllib.request.urlopen(INDEX_URL, timeout=20) as r:
                return {(p["name"], p["version"]) for p in json.load(r)}
        except Exception as e:  # noqa: BLE001 — jede Netzstörung, dann neuer Versuch
            print(f"  Universe-Verzeichnis nicht erreichbar ({e}), Versuch {attempt + 1}/3", file=sys.stderr)
            time.sleep(3)
    return None


def changed_paths(basis: str) -> list[str]:
    base = subprocess.run(["git", "merge-base", basis, "HEAD"], cwd=REPO, capture_output=True, text=True, check=True).stdout.strip()
    out = subprocess.run(["git", "diff", "--name-only", base, "HEAD"], cwd=REPO, capture_output=True, text=True, check=True).stdout
    return [line for line in out.splitlines() if line]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--basis", help="git-Ref, gegen den Änderungen gezählt werden (etwa origin/main)")
    args = parser.parse_args()

    fehler: list[str] = []

    # Regel 1: Ordnername = typst.toml
    folders = version_folders()
    for pkg, ver, path in folders:
        tv = toml_version(path / "typst.toml")
        if tv is None:
            if not any(path.iterdir()):
                fehler.append(f"{pkg}/{ver}: leer — Submodul nicht ausgecheckt? (git submodule update --init --recursive)")
            else:
                fehler.append(f"{pkg}/{ver}: keine Version in typst.toml")
        elif tv != ver:
            fehler.append(f"{pkg}/{ver}: typst.toml sagt {tv} — der Ordner muss die Version tragen, die das Paket hat")

    # Regel 2: veröffentlichte Versionen sind eingefroren
    if args.basis:
        index = released()
        if index is None:
            print("FEHLER: Universe-Verzeichnis nicht erreichbar, Freigabeprüfung nicht möglich", file=sys.stderr)
            return 1
        touched: dict[tuple[str, str], list[str]] = {}
        for p in changed_paths(args.basis):
            m = PATH_RE.match(p)
            if m and (m.group(1), m.group(2)) in index:
                touched.setdefault((m.group(1), m.group(2)), []).append(p)
        for (pkg, ver), paths in sorted(touched.items()):
            beispiele = ", ".join(paths[:3]) + (" …" if len(paths) > 3 else "")
            fehler.append(
                f"{pkg}/{ver} ist auf Typst Universe veröffentlicht und damit eingefroren, "
                f"geändert wurde: {beispiele}\n"
                f"    → Änderungen in eine neue Version legen: bash .github/scripts/neue-version.sh {pkg} <neue Version>"
            )
        print(f"{len(index)} veröffentlichte Versionen auf Universe, {len(folders)} Versionsordner hier")

    if fehler:
        print("Versionsprüfung fehlgeschlagen:")
        for f in fehler:
            print(f"  - {f}")
        return 1
    print(f"Versionsprüfung bestanden: {len(folders)} Versionsordner in Ordnung")
    return 0


if __name__ == "__main__":
    sys.exit(main())
