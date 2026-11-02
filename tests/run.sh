#!/usr/bin/env bash
# Regressionstests: kompiliert tests/*.typ und prüft den PDF-Text.
# Verwendung (aus dem Repo-Root): bash tests/run.sh [muster]
set -uo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$TESTS_DIR/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# @schule/... aus diesem Checkout auflösen (wie .github/scripts/build.sh)
mkdir -p "$TMP/pakete"
ln -s "$REPO" "$TMP/pakete/schule"

ok=0; fehl=0
for datei in "$TESTS_DIR"/*${1:-}*.typ; do
  name="$(basename "$datei" .typ)"
  pdf="$TMP/$name.pdf"
  ausgabe="$(typst compile --package-path "$TMP/pakete" --root "$REPO" "$datei" "$pdf" 2>&1)"
  status=$?
  probleme=()

  erwarteter_fehler="$(sed -n 's|^// fehler: ||p' "$datei")"
  if [ -n "$erwarteter_fehler" ]; then
    if [ $status -eq 0 ]; then
      probleme+=("kompiliert, erwartet war der Fehler: $erwarteter_fehler")
    elif ! grep -qF -- "$erwarteter_fehler" <<<"$ausgabe"; then
      probleme+=("falscher Fehler: $(grep -m1 '^error' <<<"$ausgabe")")
    fi
  elif [ $status -ne 0 ]; then
    probleme+=("$(grep -m1 '^error' <<<"$ausgabe")")
  else
    text="$(pdftotext -layout "$pdf" - | tr -s ' ')"
    while IFS= read -r muster; do
      grep -qE -- "$muster" <<<"$text" || probleme+=("fehlt: $muster")
    done < <(sed -n 's|^// erwartet: ||p' "$datei")
    while IFS= read -r muster; do
      grep -qE -- "$muster" <<<"$text" && probleme+=("unerwartet: $muster")
    done < <(sed -n 's|^// nicht: ||p' "$datei")
  fi

  if [ ${#probleme[@]} -eq 0 ]; then
    ok=$((ok + 1)); echo "ok    $name"
  else
    fehl=$((fehl + 1)); echo "FEHL  $name"
    printf '        %s\n' "${probleme[@]}"
  fi
done

echo
echo "$ok bestanden, $fehl fehlgeschlagen"
[ $fehl -eq 0 ]
