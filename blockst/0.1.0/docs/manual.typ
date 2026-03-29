#import "../../../schuldocs/0.1.0/lib.typ": with-pdf, show-example, show-module, show-code

#let pkg = toml("../typst.toml")

#show: with-pdf(
  name: pkg.package.name,
  version: pkg.package.version,
  authors: pkg.package.authors,
  license: pkg.package.license,
  description: pkg.package.description,
  abstract: [Das \`blockst\`-Paket ermöglicht die Darstellung von Scratch-ähnlichen Programmierblöcken in Typst-Dokumenten. Blöcke stehen in verschiedenen Sprachen (Deutsch, Englisch, Französisch) zur Verfügung.],
)

#include "content.typ"
