#import "../../../schuldocs/0.1.0/lib.typ": with-pdf, show-example, show-module, show-code

#let pkg = toml("../typst.toml")

#show: with-pdf(
  name: pkg.package.name,
  version: pkg.package.version,
  license: pkg.package.license,
  description: pkg.package.description,
  abstract: [Das \`angela\`-Paket stellt ein Brief-Template für die Angelaschule Osnabrück bereit, inklusive Logo und Schulkopf.],
)

#include "content.typ"
