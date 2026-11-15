#import "@schule/schuldocs:0.3.1": *

#let pkg = toml("../typst.toml")

#show: docs.with(
  toml: pkg,
  authors: pkg.package.at("authors", default: ("Lukas Köhl", "Alexander Schulz")),
  abstract: [Das `patterns`-Paket zeichnet karierte und linierte Schreibfelder für Arbeitsblätter, Klassenarbeiten und Klausurbögen: mit fester Zeilenzahl, mit fester Höhe oder als flexible Felder, die sich den freien Platz der Seite teilen.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
