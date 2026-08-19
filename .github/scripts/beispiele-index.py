#!/usr/bin/env python3
"""Übersichtsseite für die gebauten Beispielpräsentationen.

Aufruf aus build.sh; die Angaben kommen über die Umgebung, damit Namen mit
Leerzeichen oder Umlauten nicht über die Kommandozeile müssen.

    BSP_PAKET=typstage BSP_VERSION=0.1.0 BSP_NAMEN="theme-default theme-night" \
        beispiele-index.py ziel/index.html

Absichtlich eine einzelne Datei ohne Abhängigkeiten: die Seite liegt neben
Dokumenten, die ihre Stilvorlage mitbringen, und soll nichts nachladen.
"""

import html
import os
import sys

paket = os.environ.get("BSP_PAKET", "")
version = os.environ.get("BSP_VERSION", "")
namen = os.environ.get("BSP_NAMEN", "").split()
ziel = sys.argv[1]


def beschriften(name):
    """`theme-default` → `default`, sonst der Dateiname in lesbar."""
    if name.startswith("theme-"):
        return name[len("theme-"):]
    return name.replace("-", " ")


karten = "\n".join(
    '      <a class="deck" href="{datei}">\n'
    '        <span class="name">{titel}</span>\n'
    '        <span class="hin">öffnen →</span>\n'
    "      </a>".format(datei=html.escape(n + ".html"),
                       titel=html.escape(beschriften(n)))
    for n in namen
)

seite = """<!doctype html>
<html lang="de">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Beispiele — {paket} {version}</title>
<style>
  :root {{
    --grund: #ffffff; --tinte: #18181b; --leise: #71717a;
    --rand: #e4e4e7; --feld: #fafafa; --akzent: #eb5e28;
  }}
  @media (prefers-color-scheme: dark) {{
    :root {{
      --grund: #18181b; --tinte: #f4f4f5; --leise: #a1a1aa;
      --rand: #3f3f46; --feld: #27272a; --akzent: #f97316;
    }}
  }}
  * {{ box-sizing: border-box; }}
  body {{
    margin: 0; padding: 3rem 1.25rem 4rem;
    background: var(--grund); color: var(--tinte);
    font: 400 16px/1.6 Inter, -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
  }}
  main {{ max-width: 46rem; margin: 0 auto; }}
  h1 {{ margin: 0 0 .35rem; font-size: 1.7rem; letter-spacing: -.01em; }}
  .unter {{ margin: 0 0 2rem; color: var(--leise); }}
  .gitter {{ display: grid; gap: .6rem; grid-template-columns: repeat(auto-fill, minmax(13rem, 1fr)); }}
  .deck {{
    display: flex; align-items: center; justify-content: space-between; gap: .75rem;
    padding: .85rem 1rem; border: 1px solid var(--rand); border-radius: .5rem;
    background: var(--feld); color: inherit; text-decoration: none;
  }}
  .deck:hover {{ border-color: var(--akzent); }}
  .name {{ font-weight: 600; }}
  .hin {{ color: var(--leise); font-size: .85rem; white-space: nowrap; }}
  .tasten {{
    margin-top: 2.5rem; padding-top: 1.25rem; border-top: 1px solid var(--rand);
    color: var(--leise); font-size: .9rem;
  }}
  kbd {{
    padding: .1rem .35rem; border: 1px solid var(--rand); border-radius: .25rem;
    background: var(--feld); font: 500 .85em/1 ui-monospace, SFMono-Regular, Menlo, monospace;
    color: var(--tinte);
  }}
  .zurueck {{ display: inline-block; margin-bottom: 1.5rem; color: var(--leise); text-decoration: none; }}
  .zurueck:hover {{ color: var(--akzent); }}
</style>
</head>
<body>
  <main>
    <a class="zurueck" href="../">← Handbuch</a>
    <h1>Beispiele</h1>
    <p class="unter">{paket} {version} — dieselbe Präsentation in jedem
    mitgelieferten Theme. Jede Folie ist von Typst gesetzt und als SVG
    eingebettet; bewegt wird sie erst im Browser.</p>
    <div class="gitter">
{karten}
    </div>
    <p class="tasten">
      <kbd>→</kbd> <kbd>←</kbd> einen Schritt weiter oder zurück ·
      <kbd>o</kbd> Übersicht · <kbd>f</kbd> Vollbild ·
      <kbd>s</kbd> Notizen · <kbd>p</kbd> Druckansicht
    </p>
  </main>
</body>
</html>
""".format(paket=html.escape(paket), version=html.escape(version), karten=karten)

with open(ziel, "w", encoding="utf-8") as f:
    f.write(seite)
