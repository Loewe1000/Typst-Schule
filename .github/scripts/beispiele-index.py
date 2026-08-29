#!/usr/bin/env python3
"""Übersichtsseite für die gebauten Beispielpräsentationen.

Aufruf aus build.sh; die Angaben kommen über die Umgebung, damit Namen mit
Leerzeichen oder Umlauten nicht über die Kommandozeile müssen.

    BSP_PAKET=typstage BSP_VERSION=0.1.0 BSP_NAMEN="theme-default theme-night" \
        beispiele-index.py ziel/index.html

`BSP_SPRACHE` ist `de` oder `en` und steht auf `de`, wenn nichts gesagt wird --
ein Paket, das die Seite nur auf Deutsch will, ruft weiter auf wie bisher.

Absichtlich eine einzelne Datei ohne Abhängigkeiten: die Seite liegt neben
Dokumenten, die ihre Stilvorlage mitbringen, und soll nichts nachladen.
"""

import html
import os
import sys

paket = os.environ.get("BSP_PAKET", "")
version = os.environ.get("BSP_VERSION", "")
namen = os.environ.get("BSP_NAMEN", "").split()
sprache = os.environ.get("BSP_SPRACHE", "de")
ziel = sys.argv[1]

# Die Beispiele selbst sind englisch -- sie sind Vorträge, keine Oberfläche.
# Was hier steht, ist die Übersicht darüber, und die gibt es in beiden
# Sprachen: wer aus dem englischen Handbuch kommt, soll nicht plötzlich auf
# einer deutschen Seite stehen.
WORTE = {
    "de": dict(
        zurueck="← Handbuch", zurueck_ziel="../",
        titel="Beispiele", oeffnen="öffnen →",
        unter="je ein kurzer Vortrag in jedem mitgelieferten Theme, mit "
              "Einblendungen, Magic Move und verschiedenen Folienübergängen. "
              "Jede Folie ist von Typst gesetzt und als SVG eingebettet; "
              "bewegt wird sie erst im Browser.",
        tasten=[(["→", "←"], "einen Schritt weiter oder zurück"),
                (["Pos 1", "Ende"], "erste und letzte Folie"),
                (["o"], "Übersicht"), (["f"], "Vollbild"),
                (["n"], "Sprecheransicht"), (["?"], "Tastenhilfe")],
    ),
    "en": dict(
        zurueck="← Manual", zurueck_ziel="../en.html",
        titel="Examples", oeffnen="open →",
        unter="one short talk in each bundled theme, with reveals, magic move "
              "and a range of slide transitions. Every slide is typeset by "
              "Typst and embedded as SVG; only the browser moves it.",
        tasten=[(["→", "←"], "one step forward or back"),
                (["Home", "End"], "first and last slide"),
                (["o"], "overview"), (["f"], "full screen"),
                (["n"], "speaker view"), (["?"], "key help")],
    ),
}
w = WORTE.get(sprache, WORTE["de"])


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
                       titel=html.escape(beschriften(n)),
                       hin=html.escape(w["oeffnen"]))
    for n in namen
)

# Nur Tasten, auf die die Laufzeit auch hört. `s` und `p` standen hier einmal
# und griffen ins Leere: zu beiden gibt es keinen Zweig.
tasten = "      " + " ·\n      ".join(
    " ".join("<kbd>%s</kbd>" % html.escape(t) for t in tt) + " " + html.escape(was)
    for tt, was in w["tasten"]
)

seite = """<!doctype html>
<html lang="{sprache}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{titel} — {paket} {version}</title>
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
    <a class="zurueck" href="{zurueck_ziel}">{zurueck}</a>
    <h1>{titel}</h1>
    <p class="unter">{paket} {version} — {unter}</p>
    <div class="gitter">
{karten}
    </div>
    <p class="tasten">
{tasten}
    </p>
  </main>
</body>
</html>
""".format(paket=html.escape(paket), version=html.escape(version), karten=karten,
           sprache=html.escape(sprache), titel=html.escape(w["titel"]),
           zurueck=html.escape(w["zurueck"]),
           zurueck_ziel=html.escape(w["zurueck_ziel"]),
           unter=html.escape(w["unter"]), tasten=tasten)

with open(ziel, "w", encoding="utf-8") as f:
    f.write(seite)
