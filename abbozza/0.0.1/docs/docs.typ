#import "@schule/schuldocs:0.2.0": *

#show: docs.with(
  toml: toml("../typst.toml"),
  abstract: [Das `abbozza`-Paket rendert Hathi-Level als Hex-Kachel-Diagramme mit CeTZ. Es eignet sich für die Darstellung von Unterrichtsmaterialien im Kontext des Hathi-Lernspiels.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
