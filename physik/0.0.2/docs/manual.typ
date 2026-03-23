#import "../../../schuldocs/0.1.0/lib.typ": with-pdf, show-example, show-module, show-code
#import "../lib.typ" as phys

#let pkg = toml("../typst.toml")

#show: with-pdf(
  name: pkg.package.name,
  version: pkg.package.version,
  authors: ("Lukas Köhl", "Alexander Schulz"),
  license: pkg.package.license,
  description: pkg.package.description,
  abstract: [Das `physik`-Paket stellt Werkzeuge für den Physik-Unterricht bereit: Messwerttabellen, statistische Regressionen, Schaltkreis-Visualisierungen und physikalische Konstanten.],
  examples-scope: (
    scope: (phys: phys),
    imports: (phys: "*"),
  ),
)

#include "content.typ"
