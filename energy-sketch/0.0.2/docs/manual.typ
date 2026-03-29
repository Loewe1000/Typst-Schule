#import "../../../schuldocs/0.1.0/lib.typ": with-pdf, show-example, show-module, show-code

#let pkg = toml("../typst.toml")

#show: with-pdf(
  name: pkg.package.name,
  version: pkg.package.version,
  license: pkg.package.license,
  description: pkg.package.description,
  abstract: [Das \`energy-sketch\`-Paket erstellt Energieniveau-Diagramme für Physik- und Chemieunterricht. Energiestufen werden als beschriftete horizontale Balken dargestellt.],
)

#include "content.typ"
