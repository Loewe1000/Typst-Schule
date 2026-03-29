#import "../../../schuldocs/0.1.0/lib.typ": with-pdf, show-example, show-module, show-code

#let pkg = toml("../typst.toml")

#show: with-pdf(
  name: pkg.package.name,
  version: pkg.package.version,
  authors: pkg.package.authors,
  license: pkg.package.license,
  description: pkg.package.description,
  abstract: [Das \`typlace\`-Paket erstellt Tischlayouts für Klassenräume aus einem einfachen String-Muster. Tische, freie Plätze und ein Lehrerpult werden als Rastergrafik dargestellt.],
)

#include "content.typ"
