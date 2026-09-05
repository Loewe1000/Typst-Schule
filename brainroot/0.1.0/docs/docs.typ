#import "@schule/schuldocs:0.2.0": *

#show: docs.with(
  toml: toml("../typst.toml"),
  abstract: [Das `brainroot`-Paket zeichnet zweiseitige Mindmaps: die Wurzel in der Mitte, farbige Äste nach rechts und links, Blätter beliebig tief. Das Layout entsteht automatisch.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
