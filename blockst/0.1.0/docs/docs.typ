#import "@schule/schuldocs:0.2.0": *

#let pkg = toml("../typst.toml")

#show: docs.with(
  toml: pkg,
  authors: pkg.package.authors,
  abstract: [Das `blockst`-Paket ermöglicht die Darstellung von Scratch-ähnlichen Programmierblöcken in Typst-Dokumenten. Blöcke stehen in verschiedenen Sprachen (Deutsch, Englisch, Französisch) zur Verfügung.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
