#import "@schule/schuldocs:0.3.1": *

#let pkg = toml("../typst.toml")

#show: docs.with(
  toml: pkg,
  authors: pkg.package.at("authors", default: ("Lukas Köhl", "Alexander Schulz")),
  abstract: [Das `klausurboegen`-Paket setzt Klausurbögen im A3-Querformat zum Falten: kariertes oder liniertes Schreibfeld mit Korrekturrand, Kopf mit Namenszeile und ein Ergebnisdruck, der Punktetabelle, Note und Notenschlüssel aus einer CSV-Datei auf die beschriebenen Bögen setzt.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
