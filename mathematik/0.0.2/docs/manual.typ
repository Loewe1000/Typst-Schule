#import "../../../schuldocs/0.1.0/lib.typ": with-pdf, show-example, show-module, show-code
#import "../mathematik.typ" as math-pkg
#import "@schule/aufgaben:0.1.2" as auf-pkg

#let pkg = toml("../typst.toml")

#show: with-pdf(
  name: pkg.package.name,
  version: pkg.package.version,
  authors: ("Lukas Köhl", "Alexander Schulz"),
  license: pkg.package.license,
  description: pkg.package.description,
  abstract: [Das `mathematik`-Paket bietet Werkzeuge zur Visualisierung mathematischer Inhalte: Koordinatensysteme, Funktionsgraphen, Füllbereiche, Datensatz-Plots und strukturierte Teilaufgaben.],
  examples-scope: (
    scope: (mathematik: math-pkg, aufgaben: auf-pkg),
    imports: (mathematik: "*", aufgaben: "*"),
  ),
)

#include "content.typ"
