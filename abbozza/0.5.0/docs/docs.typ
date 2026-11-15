#import "@schule/schuldocs:0.3.1": *

#show: docs.with(
  toml: toml("../typst.toml"),
  authors: ("Alexander Schulz",),
  abstract: [Das Paket `abbozza` setzt Level des Lernspiels Hathi aus Abbozza! Worlds als Bild: Die Level-Datei wird geladen, und `hathi-level` zeichnet daraus das Spielfeld für Arbeitsblätter und Klassenarbeiten.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
