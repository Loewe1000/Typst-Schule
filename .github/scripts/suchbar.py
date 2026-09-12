#!/usr/bin/env python3
"""Nimmt eine Seite in den Suchindex auf.

Pagefind indexiert, sobald irgendeine Seite der Website `data-pagefind-body`
trägt, nur noch Seiten mit diesem Merkmal. build.sh setzt es auf die
Startseite und auf die Einstiegsseite der neuesten Version jedes Pakets —
ältere Versionen bleiben erreichbar, aber ohne Suchtreffer, sonst stünde jeder
Treffer so oft da, wie es Versionen gibt.

    suchbar.py <seite.html>

Das Merkmal kommt an das erste `<main>`, sonst an `<body>`. Eine Seite, die
es schon trägt, bleibt unverändert.
"""

import re
import sys
from pathlib import Path

seite = Path(sys.argv[1])
html = seite.read_text(encoding="utf-8")
if "data-pagefind-body" in html:
    sys.exit(0)
for tag in ("main", "body"):
    html, n = re.subn(rf"<{tag}(\s[^>]*)?>", lambda m: f"<{tag} data-pagefind-body{m.group(1) or ''}>", html, count=1)
    if n:
        break
else:
    sys.exit(f"suchbar: kein <main> und kein <body> in {seite}")
seite.write_text(html, encoding="utf-8")
