#!/bin/bash
# Bilder fürs Handbuch neu erzeugen (nach Designänderungen).
# Aufruf: bash docs/assets/bilder.sh  (aus dem Paketordner trimino/0.5.0)
set -e
cd "$(dirname "$0")"
typst compile logo.typ logo.svg
cd bilder
tmp=$(mktemp -d)
typst compile themes-trimino.typ ../themes-trimino.png --ppi 80
typst compile themes-domino.typ ../themes-domino.png --ppi 80
typst compile trimino.typ "$tmp/t-{p}.png" --ppi 90
# Mit Rückseite beginnt der Schnittbogen auf einer ungeraden Seite (Seite 2 leer).
cp "$tmp/t-1.png" ../trimino-loesung.png
cp "$tmp/t-3.png" ../trimino-schnittbogen.png
cp "$tmp/t-4.png" ../trimino-rueckseite.png
typst compile domino.typ "$tmp/d-{p}.png" --ppi 90
cp "$tmp/d-1.png" ../domino-kette.png
cp "$tmp/d-2.png" ../domino-kette-schnittbogen.png
cp "$tmp/d-3.png" ../domino-stapel.png
cp "$tmp/d-5.png" ../domino-stapel-schnittbogen.png
cp "$tmp/d-6.png" ../domino-stapel-rueckseite.png
rm -r "$tmp"
# Weißen Rand unten abschneiden (Pillow), damit die Bilder kompakt sind.
python3 - ../*.png <<'PY'
import sys
from PIL import Image, ImageChops
for f in sys.argv[1:]:
    im = Image.open(f).convert("RGB")
    bg = Image.new("RGB", im.size, (255, 255, 255))
    box = ImageChops.difference(im, bg).getbbox()
    if box:
        m = 24
        im.crop((max(0, box[0] - m), max(0, box[1] - m), min(im.width, box[2] + m), min(im.height, box[3] + m))).save(f)
PY
