#import "@schule/schuldocs:0.3.1": *

#show: docs.with(
  toml: toml("../typst.toml"),
  authors: ("Lukas Köhl", "Alexander Schulz"),
  abstract: [Das `physik`-Paket stellt Werkzeuge für den Physikunterricht bereit: Messwerttabellen aus Datensätzen, berechnete Messreihen, Regressionen mit gesetzter Gleichung, Schaltzeichen für Schaltkreise und eine Sammlung von Naturkonstanten.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
