#!/usr/bin/env bash
# Prüft, dass jede Kopie <paket>/0.5.0/src/internal/check.typ byte-gleich zur
# Quelle .github/namen/check.typ ist.
# Verwendung (aus beliebigem Verzeichnis): bash .github/scripts/check-sync.sh
# Exit 1, wenn eine Kopie abweicht (mit Liste). Fehlende Kopien werden nur
# aufgelistet.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
QUELLE="$REPO/.github/namen/check.typ"

if [ ! -f "$QUELLE" ]; then
  echo "check-sync: Quelle fehlt: .github/namen/check.typ" >&2
  exit 1
fi

gleich=0; abweichend=(); fehlend=()
for ordner in "$REPO"/*/0.5.0; do
  [ -d "$ordner" ] || continue
  paket="$(basename "$(dirname "$ordner")")"
  kopie="$ordner/src/internal/check.typ"
  if [ ! -f "$kopie" ]; then
    fehlend+=("$paket/0.5.0/src/internal/check.typ")
  elif cmp -s "$QUELLE" "$kopie"; then
    gleich=$((gleich + 1))
  else
    abweichend+=("$paket/0.5.0/src/internal/check.typ")
  fi
done

echo "check-sync: $gleich gleich, ${#abweichend[@]} abweichend, ${#fehlend[@]} fehlend"
if [ ${#fehlend[@]} -gt 0 ]; then
  echo "fehlend (nur Hinweis):"
  printf '  %s\n' "${fehlend[@]}"
fi
if [ ${#abweichend[@]} -gt 0 ]; then
  echo "abweichend von .github/namen/check.typ:"
  printf '  %s\n' "${abweichend[@]}"
  echo "Abhilfe: cp .github/namen/check.typ <paket>/0.5.0/src/internal/check.typ"
  exit 1
fi
exit 0
