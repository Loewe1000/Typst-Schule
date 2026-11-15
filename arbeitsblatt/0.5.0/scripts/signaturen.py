#!/usr/bin/env python3
"""Erzeugt Signaturen, Docstring-Zeilen und Weitergabe-Dictionaries von
`arbeitsblatt` und `arbeitsblatt-einzeln` aus der Parametertabelle.

Quelle:  src/internal/parameters.typ   (eine Zeile je Parameter)
Ziel:    src/worksheet.typ             (Bereiche zwischen `// <erzeugt …>` und `// </erzeugt>`,
                                        dazu die Parameterzeilen der beiden Docstrings)

    python3 arbeitsblatt/0.5.0/scripts/signaturen.py           # schreibt src/worksheet.typ neu
    python3 arbeitsblatt/0.5.0/scripts/signaturen.py --check   # Exit 1, wenn die Datei abweicht
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TABLE = ROOT / "src" / "internal" / "parameters.typ"
TARGET = ROOT / "src" / "worksheet.typ"

LINE = re.compile(
    r'^  ([a-z][a-z0-9-]*): \(default: (.*?), types: \((.*?)\), only: (none|"[a-z-]+"), text: "((?:[^"\\]|\\.)*)"\),$'
)

SINK_DOC = "/// - ..deprecated (arguments): fängt alte Namen ab und meldet den neuen; nimmt nichts an"
BODY_DOC = "/// - body (content): Inhalt des Blatts"


def read_table():
    rows = []
    inside = False
    for line in TABLE.read_text(encoding="utf-8").splitlines():
        if line.startswith("#let worksheet-parameters = ("):
            inside = True
            continue
        if inside and line == ")":
            break
        if not inside or not line.strip():
            continue
        match = LINE.match(line)
        if not match:
            sys.exit(f"signaturen.py: Zeile der Parametertabelle nicht lesbar:\n{line}")
        name, default, types, only, text = match.groups()
        rows.append({
            "name": name,
            "default": default,
            "types": ", ".join(t.strip() for t in types.split(",") if t.strip()),
            "only": None if only == "none" else only.strip('"'),
            "text": text.replace('\\"', '"').replace("\\\\", "\\"),
        })
    if not rows:
        sys.exit("signaturen.py: keine Parameter gefunden")
    return rows


def rows_for(rows, function):
    return [row for row in rows if row["only"] in (None, function)]


def signature(rows, function):
    return [f"  {row['name']}: {row['default']}," for row in rows_for(rows, function)]


def options(rows, function, indent):
    return [f"{indent}{row['name']}: {row['name']}," for row in rows_for(rows, function) if row["name"] != "scope"]


def doc(rows, function):
    lines = [f"/// - {row['name']} ({row['types']}): {row['text']}" for row in rows_for(rows, function)]
    return lines + [SINK_DOC, BODY_DOC]


def generate(text, rows):
    lines = text.split("\n")
    out = []
    i = 0
    while i < len(lines):
        line = lines[i]
        marker = re.match(r"^(\s*)// <erzeugt (signatur|optionen) (arbeitsblatt(?:-einzeln)?)>$", line)
        if marker:
            indent, kind, function = marker.groups()
            out.append(line)
            out += signature(rows, function) if kind == "signatur" else options(rows, function, indent)
            while not re.match(r"^\s*// </erzeugt>$", lines[i]):
                i += 1
                if i >= len(lines):
                    sys.exit(f"signaturen.py: `// </erzeugt>` fehlt nach `{line.strip()}`")
            out.append(lines[i])
            i += 1
            continue
        out.append(line)
        i += 1
    text = "\n".join(out)
    # Parameterzeilen der Docstrings: von der ersten Zeile `/// - ` bis vor `/// -> `
    # im Docstring direkt über `#let <funktion>(`.
    for function in ("arbeitsblatt-einzeln", "arbeitsblatt"):
        pattern = re.compile(r"((?:^///.*\n)+)(?=#let " + re.escape(function) + r"\()", re.M)
        found = pattern.search(text)
        if not found:
            sys.exit(f"signaturen.py: Docstring über `#let {function}(` nicht gefunden")
        block = found.group(1).rstrip("\n").split("\n")
        first = next((k for k, l in enumerate(block) if l.startswith("/// - ")), None)
        last = next((k for k, l in enumerate(block) if l.startswith("/// -> ")), None)
        if first is None or last is None:
            sys.exit(f"signaturen.py: Docstring von `{function}` braucht eine Zeile `/// - …` und eine Zeile `/// -> …`")
        block = block[:first] + doc(rows, function) + block[last:]
        text = text[:found.start(1)] + "\n".join(block) + "\n" + text[found.end(1):]
    return text


def main():
    rows = read_table()
    current = TARGET.read_text(encoding="utf-8")
    wanted = generate(current, rows)
    if "--check" in sys.argv[1:]:
        if current != wanted:
            sys.exit("signaturen.py: src/worksheet.typ weicht von der Parametertabelle ab – Skript ohne --check laufen lassen")
        print(f"signaturen.py: {len(rows)} Parameter, src/worksheet.typ stimmt mit der Tabelle überein")
        return
    if current != wanted:
        TARGET.write_text(wanted, encoding="utf-8")
        print(f"signaturen.py: src/worksheet.typ neu geschrieben ({len(rows)} Parameter)")
    else:
        print(f"signaturen.py: nichts zu tun ({len(rows)} Parameter)")


if __name__ == "__main__":
    main()
