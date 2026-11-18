#import "@schule/schuldocs:0.3.1": *

#let pkg = toml("../typst.toml")

#show: docs.with(
  toml: pkg,
  abstract: [Das `trimino`-Paket setzt Trimino-Legespiele: Aufgaben und Lösungen stehen auf dreieckigen Kärtchen, die zu einer Figur zusammengelegt werden. Die Form wählt das Paket nach der Zahl der Paare.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
