#import "@schule/schuldocs:0.2.0": *

#show: docs.with(
  toml: toml("../typst.toml"),
  authors: ("Lukas Köhl", "Alexander Schulz"),
  abstract: [Das `physik`-Paket stellt Werkzeuge für den Physik-Unterricht bereit: Messwerttabellen, statistische Regressionen, Schaltkreis-Visualisierungen und physikalische Konstanten.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
