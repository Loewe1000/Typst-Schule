#!/usr/bin/env bash
# =============================================================================
# build.sh — Baut alle Typst-Paket-Dokumentationen und generiert Pagefind-Index
# =============================================================================
# Verwendung (aus dem Repo-Root):
#   bash .github/scripts/build.sh
#
# Anforderungen:
#   - typst >= 0.14.0 (mit HTML-Export-Unterstützung)
#   - npx (Node.js) für Pagefind
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Repo-Root ist zwei Ebenen über .github/scripts/
PACKAGES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SITE_DIR="$PACKAGES_DIR/.docs-site"
TYPST_PACKAGE_ROOT="$(mktemp -d)"

cleanup() {
  rm -rf "$TYPST_PACKAGE_ROOT"
}

trap cleanup EXIT

mkdir -p "$TYPST_PACKAGE_ROOT"
ln -s "$PACKAGES_DIR" "$TYPST_PACKAGE_ROOT/schule"

echo "=== Schule-Typst Dokumentations-Build ==="
echo "Pakete-Verzeichnis: $PACKAGES_DIR"
echo "Ausgabe-Verzeichnis: $SITE_DIR"
echo "Typst-Paketpfad: $TYPST_PACKAGE_ROOT"
echo ""

# Pakete mit Pfad (PAKET/VERSION)
PACKAGES=(
  "aufgaben/0.1.2"
  "arbeitsblatt/0.2.4"
  "klassenarbeit/0.1.2"
  "mathematik/0.0.2"
  "physik/0.0.2"
  "informatik/0.0.2"
  "abbozza/0.0.1"
  "angela/0.0.1"
  "blockst/0.1.0"
  "energy-sketch/0.0.3"
  "flashcards/0.0.1"
  "gutachten/0.0.2"
  "insert-a-word/0.0.3"
  "klausurboegen/0.0.3"
  "operatoren/0.0.1"
  "patterns/0.0.2"
  "summify/0.1.0"
  "typlace/0.0.1"
)

# Ausgabe-Verzeichnis vorbereiten (existierende HTML-Dateien löschen, Pagefind-Index behalten)
mkdir -p "$SITE_DIR"

# Pakete kompilieren
for pkg_path in "${PACKAGES[@]}"; do
  pkg_name=$(echo "$pkg_path" | cut -d'/' -f1)
  pkg_dir="$PACKAGES_DIR/$pkg_path"

  if [[ ! -d "$pkg_dir" ]]; then
    echo "WARNUNG: $pkg_dir existiert nicht, überspringe..."
    continue
  fi

  if [[ ! -f "$pkg_dir/docs/web.typ" ]]; then
    echo "WARNUNG: $pkg_dir/docs/web.typ nicht gefunden, überspringe..."
    continue
  fi

  echo "--- Kompiliere $pkg_name ---"
  (
    cd "$pkg_dir"
    typst compile \
      --format html \
      --features html \
      --package-path "$TYPST_PACKAGE_ROOT" \
      --root "$PACKAGES_DIR" \
      docs/web.typ \
      docs/web.html \
      2>&1 | awk '!/^warning: html export/ && !/^= hint:/ { print }'
  )

  # HTML ins docs-site-Verzeichnis kopieren
  out_dir="$SITE_DIR/$pkg_name"
  mkdir -p "$out_dir"
  cp "$pkg_dir/docs/web.html" "$out_dir/index.html"
  echo "    → $out_dir/index.html"
done

# Startseite kopieren
if [[ -f "$SCRIPT_DIR/index.html" ]]; then
  cp "$SCRIPT_DIR/index.html" "$SITE_DIR/index.html"
  echo "--- Startseite kopiert ---"
fi

# Pagefind-Index generieren
echo ""
echo "--- Generiere Pagefind-Index ---"
if command -v npx &>/dev/null; then
  npx pagefind --site "$SITE_DIR" --output-path "$SITE_DIR/pagefind" --force-language de
  echo "    → Pagefind-Index in $SITE_DIR/pagefind/"
else
  echo "WARNUNG: npx nicht gefunden. Pagefind wird übersprungen."
  echo "         Installiere Node.js und führe 'npx pagefind --site $SITE_DIR' manuell aus."
fi

echo ""
echo "=== Build abgeschlossen ==="
echo "Ausgabe: $SITE_DIR/"
ls "$SITE_DIR/"
