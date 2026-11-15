#import "@schule/schuldocs:0.3.1": *

#show: docs.with(
  toml: toml("../typst.toml"),
  authors: ("Lukas Köhl", "Alexander Schulz"),
  abstract: [Das `informatik`-Paket stellt Werkzeuge für den Informatikunterricht bereit: klassische Chiffren, Häufigkeitsanalyse, Zahlensysteme und eine ASCII-Tabelle.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
