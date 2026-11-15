#import "@schule/schuldocs:0.3.1": docs

#show: docs.with(
  toml: toml("../typst.toml"),
  abstract: [Das `angela`-Paket stellt die Briefvorlage der Angelaschule Osnabrück bereit: Briefkopf mit Schulname, Logo und blauer Linie, dazu die beiden Schulfarben.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
