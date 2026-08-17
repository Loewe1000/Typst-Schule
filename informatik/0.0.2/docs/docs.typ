#import "@schule/schuldocs:0.2.0": *

#show: docs.with(
  toml: toml("../typst.toml"),
  authors: ("Lukas Köhl", "Alexander Schulz"),
  abstract: [Das `informatik`-Paket stellt Hilfsfunktionen für den Informatikunterricht bereit: Kryptographie, Zahlensysteme, Häufigkeitsanalysen und Scratch-Blockdiagramme.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
