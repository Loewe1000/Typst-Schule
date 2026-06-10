#!/usr/bin/env bash
# =============================================================================
# build.sh — Baut alle Typst-Paket-Dokumentationen (versioniert) und
#            generiert den Pagefind-Index
# =============================================================================
# Verwendung (aus dem Repo-Root):
#   bash .github/scripts/build.sh
#
# Funktionsweise:
#   - Auto-Discovery: Jeder Versionsordner {paket}/{version}/ mit einer
#     docs/web.typ wird gebaut – Versionen müssen hier NICHT mehr gepflegt
#     werden. Doku gibt es damit automatisch "ab der Version", in der
#     docs/web.typ eingeführt wurde.
#   - Ausgabe: .docs-site/{paket}/{version}/index.html pro Version,
#     .docs-site/{paket}/index.html als Kopie der neuesten Version sowie
#     .docs-site/{paket}/versions.json (absteigend sortiert) für das
#     Versions-Dropdown (siehe schuldocs with-web).
#   - Pagefind indexiert nur Startseite + {paket}/index.html, damit
#     Suchtreffer nicht über alle Versionen dupliziert werden.
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

# Navigationsleiste (Übersicht-Button + Versions-Dropdown) als
# Injection-Fallback für Seiten, die nicht über schuldocs' with-web gebaut
# wurden. Identischer Code wie in schuldocs/0.1.0/lib.typ
# (Marker: schuldocs-nav) – synchron halten!
DROPDOWN_JS="(function(){if(document.getElementById('schuldocs-nav')){return;}var p=location.pathname.replace(/index\\.html\$/,'');if(p.slice(-1)!=='/'){p+='/';}var vm=p.match(/\\/(\\d+\\.\\d+\\.\\d+)\\/\$/);var root=vm?p.slice(0,p.length-vm[1].length-1):p;var current=vm?vm[1]:null;var home=root.replace(/[^/]+\\/\$/,'');var style=document.createElement('style');style.textContent='#schuldocs-nav{position:fixed;top:.75rem;right:.75rem;z-index:50;display:flex;gap:.4rem;align-items:center;}#schuldocs-nav a,#schuldocs-nav select{padding:.3rem .5rem;border:1px solid rgb(212,212,216);border-radius:.375rem;background:rgba(255,255,255,.92);font:500 .8rem/1.2 Inter,system-ui,sans-serif;color:rgb(63,63,70);cursor:pointer;text-decoration:none;}@media (prefers-color-scheme:dark){#schuldocs-nav a,#schuldocs-nav select{background:rgba(39,39,42,.92);color:rgb(212,212,216);border-color:rgb(63,63,70);}}';document.head.appendChild(style);var nav=document.createElement('div');nav.id='schuldocs-nav';var back=document.createElement('a');back.href=home;back.title='Zur Paketübersicht';back.setAttribute('aria-label','Zur Paketübersicht');back.textContent='\\u2190 Übersicht';nav.appendChild(back);document.body.appendChild(nav);fetch(root+'versions.json').then(function(r){if(!r.ok){throw 0;}return r.json();}).then(function(versions){if(!Array.isArray(versions)||versions.length<2){return;}var sel=document.createElement('select');sel.id='schuldocs-versionen';sel.title='Dokumentations-Version';sel.setAttribute('aria-label','Dokumentations-Version wählen');versions.forEach(function(v,i){var o=document.createElement('option');o.value=v;o.textContent=i===0?v+' (neueste)':v;sel.appendChild(o);});sel.value=current||versions[0];sel.onchange=function(){location.href=root+sel.value+'/';};nav.appendChild(sel);}).catch(function(){});})();"

# Ausgabe-Verzeichnis vorbereiten (existierende HTML-Dateien und
# versions.json löschen, Pagefind-Index behalten)
mkdir -p "$SITE_DIR"
find "$SITE_DIR" \( -name "index.html" -o -name "versions.json" \) -not -path "$SITE_DIR/pagefind/*" -delete
find "$SITE_DIR" -type d -empty -delete 2>/dev/null || true

fehlgeschlagen=()
# Neueste gebaute Version je Paket als JSON-Fragment ("paket":"version",…) –
# wird in die Startseite eingesetzt. Kein assoziatives Array, damit das Skript
# auch mit dem älteren bash 3.2 (macOS) läuft.
neueste_versionen_json=""

# Pakete kompilieren: alle Versionsordner mit docs/web.typ, neueste zuerst
for pkg_dir in "$PACKAGES_DIR"/*/; do
  pkg_name="$(basename "$pkg_dir")"

  # Versionen mit Doku ermitteln, absteigend sortiert (neueste zuerst)
  versions=()
  while IFS= read -r v; do
    versions+=("$v")
  done < <(
    for vdir in "$pkg_dir"*/; do
      [[ -f "$vdir/docs/web.typ" ]] && basename "$vdir"
    done | sort -rV
  )

  [[ ${#versions[@]} -eq 0 ]] && continue

  echo "--- $pkg_name (${versions[*]}) ---"
  out_pkg_dir="$SITE_DIR/$pkg_name"
  mkdir -p "$out_pkg_dir"

  gebaut=()
  for version in "${versions[@]}"; do
    src="$pkg_dir$version/docs/web.typ"
    out_dir="$out_pkg_dir/$version"
    mkdir -p "$out_dir"

    if (
      cd "$pkg_dir$version"
      typst compile \
        --format html \
        --features html \
        --package-path "$TYPST_PACKAGE_ROOT" \
        --root "$PACKAGES_DIR" \
        docs/web.typ \
        "$out_dir/index.html" \
        2>&1 | awk '!/^warning: html export/ && !/^= hint:/ { print }'
      exit "${PIPESTATUS[0]}"
    ); then
      # Injection-Fallback: Dropdown nur ergänzen, wenn die Seite es nicht
      # bereits nativ (über schuldocs with-web) mitbringt
      if ! grep -q "schuldocs-nav" "$out_dir/index.html"; then
        SCHULDOCS_SNIPPET="<script>$DROPDOWN_JS</script>" python3 -c '
import os, sys
pfad = sys.argv[1]
snippet = os.environ["SCHULDOCS_SNIPPET"]
html = open(pfad, encoding="utf-8").read()
if "</body>" in html:
    html = html.replace("</body>", snippet + "</body>", 1)
else:
    html += snippet
open(pfad, "w", encoding="utf-8").write(html)
' "$out_dir/index.html"
      fi
      gebaut+=("$version")
      echo "    → $pkg_name/$version/index.html"
    else
      echo "    WARNUNG: $pkg_name/$version ließ sich nicht kompilieren, überspringe..."
      fehlgeschlagen+=("$pkg_name/$version")
      rm -rf "$out_dir"
    fi
  done

  [[ ${#gebaut[@]} -eq 0 ]] && { rm -rf "$out_pkg_dir"; continue; }

  # versions.json (absteigend, neueste zuerst) für das Dropdown
  {
    printf '['
    for i in "${!gebaut[@]}"; do
      [[ $i -gt 0 ]] && printf ','
      printf '"%s"' "${gebaut[$i]}"
    done
    printf ']\n'
  } > "$out_pkg_dir/versions.json"

  # Neueste Version zusätzlich als unversionierte Standard-Seite
  cp "$out_pkg_dir/${gebaut[0]}/index.html" "$out_pkg_dir/index.html"
  neueste_versionen_json+="\"$pkg_name\":\"${gebaut[0]}\","
  echo "    → $pkg_name/index.html (= ${gebaut[0]})"
done

# Startseite kopieren und die Paket-Versionsnummern auf den jeweils neuesten
# gebauten Stand aktualisieren (die Versions-Badges in index.html sind sonst
# statisch und veralten bei jedem Release)
if [[ -f "$SCRIPT_DIR/index.html" ]]; then
  cp "$SCRIPT_DIR/index.html" "$SITE_DIR/index.html"

  SCHULDOCS_VERSIONEN="{${neueste_versionen_json}}" python3 -c '
import json, os, re, sys
pfad = sys.argv[1]
# Trailing-Komma vor der schließenden Klammer entfernen (vom inkrementellen
# Aufbau im Shell-Loop), damit json.loads den String akzeptiert.
versionen = json.loads(re.sub(r",\s*}", "}", os.environ["SCHULDOCS_VERSIONEN"]))
html = open(pfad, encoding="utf-8").read()
# Pro Paket die font-mono-Version-Span ersetzen, die direkt auf das
# <h3>paketname</h3> der Karte folgt.
for pkg, version in versionen.items():
    muster = re.compile(
        r"(<h3[^>]*>" + re.escape(pkg)
        + r"</h3>\s*<span class=\"text-xs text-slate-500 font-mono\">)[^<]*(</span>)"
    )
    html, n = muster.subn(r"\g<1>" + version + r"\g<2>", html, count=1)
    if n == 0:
        print("    HINWEIS: keine Versions-Badge fuer " + pkg + " in index.html gefunden")
open(pfad, "w", encoding="utf-8").write(html)
' "$SITE_DIR/index.html"
  echo "--- Startseite kopiert (Versionen aktualisiert) ---"
fi

# Pagefind-Index generieren – nur Startseite und die unversionierten
# Paket-Seiten indexieren, damit Treffer nicht pro Version dupliziert werden
echo ""
echo "--- Generiere Pagefind-Index ---"
if command -v npx &>/dev/null; then
  npx pagefind --site "$SITE_DIR" --output-path "$SITE_DIR/pagefind" --force-language de \
    --glob "{index.html,*/index.html}"
  echo "    → Pagefind-Index in $SITE_DIR/pagefind/"
else
  echo "WARNUNG: npx nicht gefunden. Pagefind wird übersprungen."
  echo "         Installiere Node.js und führe 'npx pagefind --site $SITE_DIR' manuell aus."
fi

echo ""
echo "=== Build abgeschlossen ==="
if [[ ${#fehlgeschlagen[@]} -gt 0 ]]; then
  echo "WARNUNG: Folgende Versionen konnten nicht gebaut werden:"
  printf '  - %s\n' "${fehlgeschlagen[@]}"
fi
echo "Ausgabe: $SITE_DIR/"
ls "$SITE_DIR/"
