#import "@schule/schuldocs:0.2.0": *

#show: docs.with(
  toml: toml("../typst.toml"),
  abstract: [Das `patterns`-Paket erstellt kariertes Papier und Raster-Hintergründe für Arbeitsblätter. Rastergröße, Farbe und Dimensionen sind frei konfigurierbar.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
