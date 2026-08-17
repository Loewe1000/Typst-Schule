#import "@schule/schuldocs:0.2.0": *

#show: docs.with(
  toml: toml("../typst.toml"),
  abstract: [Das `angela`-Paket stellt ein Brief-Template für die Angelaschule Osnabrück bereit, inklusive Logo und Schulkopf.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
