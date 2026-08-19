#!/bin/zsh
# Baut optimierer.wasm neu und legt es im Paket ab.
#
#   ./bauen.sh
#
# Voraussetzung: rustup mit dem Ziel wasm32-unknown-unknown.
# Unter macOS:   brew install rustup

set -e
cd "$(dirname "$0")"

if ! command -v rustup >/dev/null 2>&1; then
  echo "rustup fehlt. Unter macOS: brew install rustup" >&2
  exit 1
fi

# Wichtig: den Pfad der rustup-Toolchain voranstellen. Liegt daneben ein
# Rust aus Homebrew im PATH, nimmt cargo sonst dessen rustc – und der hat
# die Standardbibliothek für wasm32 nicht dabei ("can't find crate for std").
TC="$(dirname "$(rustup which cargo)")"
export PATH="$TC:$PATH"

if ! rustup target list --installed | grep -q wasm32-unknown-unknown; then
  echo "Ziel wasm32-unknown-unknown wird nachinstalliert …"
  rustup target add wasm32-unknown-unknown
fi

cargo build --release --target wasm32-unknown-unknown
cp target/wasm32-unknown-unknown/release/typlace_optimierer.wasm ../optimierer.wasm

echo "optimierer.wasm aktualisiert ($(wc -c < ../optimierer.wasm | tr -d ' ') Bytes)"
echo "Zur Kontrolle: beide Fassungen müssen bei gleichem Seed dasselbe liefern —"
echo "  sitzordnung(..., motor: \"wasm\")  gegen  sitzordnung(..., motor: \"typst\")"
