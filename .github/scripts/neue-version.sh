#!/usr/bin/env bash
# =============================================================================
# neue-version.sh — legt die nächste Version eines Pakets an
# =============================================================================
# Verwendung (aus dem Repo-Root):
#   bash .github/scripts/neue-version.sh <paket> <version>
#   bash .github/scripts/neue-version.sh aufgaben 0.4.0
#
# Sobald eine Version auf Typst Universe steht (PR an typst/packages), ist ihr
# Ordner eingefroren; alles Weitere gehört in eine neue Version. Das Skript
# nimmt die bisher neueste Version als Vorlage:
#   - ein gewöhnlicher Ordner wird kopiert, typst.toml bekommt die neue
#     Nummer, Importe des eigenen Pakets (`@schule/<paket>:<alt>`) in
#     Beispielen und Doku werden umgestellt;
#   - ein Submodul (typstage, blockst) wird als neues
#     Submodul unter der neuen Nummer eingebunden, auf dem Hauptzweig des
#     Paket-Repos — dort muss typst.toml die neue Nummer tragen.
# Die Website baut die neue Version beim nächsten Lauf von selbst mit.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/../.." && pwd)"

paket="${1:-}"
version="${2:-}"
if [[ -z "$paket" || -z "$version" ]]; then
  echo "Verwendung: bash .github/scripts/neue-version.sh <paket> <version>" >&2
  exit 2
fi
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "FEHLER: '$version' ist keine Version der Form x.y.z" >&2
  exit 2
fi
if [[ ! -d "$REPO/$paket" ]]; then
  echo "FEHLER: kein Paket '$paket' in $REPO" >&2
  exit 1
fi
ziel="$REPO/$paket/$version"
if [[ -e "$ziel" ]]; then
  echo "FEHLER: $paket/$version gibt es schon" >&2
  exit 1
fi

# Bisher neueste Version als Vorlage
vorlage="$(cd "$REPO/$paket" && ls -d [0-9]*.[0-9]*.[0-9]*/ 2>/dev/null | tr -d / | sort -V | tail -1 || true)"
if [[ -z "$vorlage" ]]; then
  echo "FEHLER: $paket hat noch keinen Versionsordner als Vorlage" >&2
  exit 1
fi
if [[ "$(printf '%s\n%s\n' "$vorlage" "$version" | sort -V | tail -1)" != "$version" ]]; then
  echo "FEHLER: $version ist nicht neuer als die vorhandene $vorlage" >&2
  exit 1
fi

cd "$REPO"
submodul_url="$(git config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null \
  | awk -v p="$paket/$vorlage" '$2 == p { sub(/\.path$/, ".url", $1); print $1 }' \
  | xargs -I{} git config -f .gitmodules --get {} || true)"

if [[ -n "$submodul_url" ]]; then
  echo "== $paket/$vorlage ist ein Submodul ($submodul_url) — neues Submodul $paket/$version"
  git submodule add "$submodul_url" "$paket/$version"
  ist="$(sed -n 's/^version *= *"\(.*\)"/\1/p' "$ziel/typst.toml" | head -1)"
  if [[ "$ist" != "$version" ]]; then
    echo "HINWEIS: typst.toml im Paket-Repo sagt '$ist', der Ordner heißt $version." >&2
    echo "         Die Versionsprüfung verlangt dieselbe Nummer — im Paket-Repo anheben," >&2
    echo "         dann hier den Zeiger nachziehen (git -C $paket/$version pull, git add $paket/$version)." >&2
  fi
else
  echo "== $paket/$vorlage → $paket/$version"
  cp -R "$REPO/$paket/$vorlage" "$ziel"
  # Version in typst.toml, Importe des eigenen Pakets in Doku und Beispielen.
  sed -i.bak "s/^\(version *= *\)\"$vorlage\"/\1\"$version\"/" "$ziel/typst.toml" && rm -f "$ziel/typst.toml.bak"
  while IFS= read -r -d '' datei; do
    if grep -q "@schule/$paket:$vorlage" "$datei"; then
      sed -i.bak "s|@schule/$paket:$vorlage|@schule/$paket:$version|g" "$datei" && rm -f "$datei.bak"
      echo "   Import umgestellt: ${datei#$REPO/}"
    fi
  done < <(find "$ziel" -name '*.typ' -print0)
  # Build-Reste der Vorlage reisen nicht mit.
  rm -rf "$ziel/docs/build" "$ziel"/docs/web.html
fi

echo
echo "Angelegt: $paket/$version (Vorlage $paket/$vorlage)"
echo "Weiter:"
echo "  - Änderungen in $paket/$version machen; $paket/$vorlage bleibt, wie es veröffentlicht wurde"
echo "  - CHANGELOG/README des Pakets nachziehen, dann committen"
echo "  - die Website baut $paket/$version beim nächsten Lauf mit und zeigt sie als neueste"
