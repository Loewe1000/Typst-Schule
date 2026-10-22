#!/bin/zsh
# Rendert das Beispielblatt in allen Themes: PDF + PNG-Vorschau.
#   ./render.sh [ausgabeordner] [ppi]
cd "${0:A:h}"
OUT=${1:-out}; PPI=${2:-70}
mkdir -p "$OUT"
for t in ${=THEMES:-standard klar atlas skizze labor kontur leiste riso bauhaus}; do
  typst compile --root ../.. --input theme=$t beispiel.typ "$OUT/$t.pdf" || continue
  typst compile --root ../.. --input theme=$t --input loesungen=sofort beispiel.typ "$OUT/$t-loesung.pdf" || continue
  rm -f "$OUT/$t"-*.png(N)
  pdftoppm -r $PPI -png "$OUT/$t.pdf" "$OUT/$t-blatt"
  pdftoppm -r $PPI -png -f 1 -l 1 "$OUT/$t-loesung.pdf" "$OUT/$t-lsg"
done
