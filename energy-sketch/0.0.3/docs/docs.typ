#import "@schule/schuldocs:0.2.0": *

#show: docs.with(
  toml: toml("../typst.toml"),
  abstract: [Das `energy-sketch`-Paket erstellt Energieniveau-Diagramme für Physik- und Chemieunterricht. Energiestufen werden als beschriftete horizontale Balken dargestellt.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
