#import "../../../schuldocs/0.1.0/lib.typ": with-pdf, show-example, show-module, show-code
#import "../lib.typ" as info
#import "@schule/blockst:0.0.1": de, set-blockst

#let pkg = toml("../typst.toml")

#show: with-pdf(
  name: pkg.package.name,
  version: pkg.package.version,
  authors: ("Lukas Köhl", "Alexander Schulz"),
  license: pkg.package.license,
  description: pkg.package.description,
  abstract: [Das `informatik`-Paket stellt Hilfsfunktionen für den Informatikunterricht bereit: Kryptographie, Zahlensysteme, Häufigkeitsanalysen und Scratch-Blockdiagramme.],
  examples-scope: (
    scope: (informatik: info, de: de),
    imports: (informatik: "*", de: "*"),
  ),
)

#set text(lang: "de")

#include "content.typ"
