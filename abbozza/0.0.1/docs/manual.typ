#import "../../../schuldocs/0.1.0/lib.typ": with-pdf, show-example, show-module, show-code

#let pkg = toml("../typst.toml")

#show: with-pdf(
  name: pkg.package.name,
  version: pkg.package.version,
  license: pkg.package.license,
  description: pkg.package.description,
  abstract: [Das \`abbozza\`-Paket rendert Hathi-Level als Hex-Kachel-Diagramme mit CeTZ. Es eignet sich für die Darstellung von Unterrichtsmaterialien im Kontext des Hathi-Lernspiels.],
)

#include "content.typ"
