#!/bin/zsh
# Baut Handbuch (PDF) und Website (HTML) in einem Lauf.
#
#   ./bauen.sh            → Ergebnis in docs/build/
#   ./bauen.sh ~/Desktop  → Ergebnis dorthin
#
# schuldocs 0.2.0 erzeugt beide Fassungen aus derselben Quelle; dafür
# braucht Typst das Bündel-Format und die Features bundle und html.

set -e
cd "$(dirname "$0")/.."

ziel="${1:-docs/build}"

typst compile \
  --root . \
  --format bundle \
  --features bundle,html \
  docs/docs.typ \
  "$ziel"

echo "Fertig:"
for f in "$ziel"/*; do echo "  $f"; done
