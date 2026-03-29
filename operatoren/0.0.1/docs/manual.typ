#import "../../../schuldocs/0.1.0/lib.typ": with-pdf, show-example, show-module, show-code

#let pkg = toml("../typst.toml")

#show: with-pdf(
  name: pkg.package.name,
  version: pkg.package.version,
  license: pkg.package.license,
  description: pkg.package.description,
  abstract: [Das \`operatoren\`-Paket verwaltet Operatoren in Klausuraufgaben und generiert aus CSV-Dateien eine tabellarische Operatorenliste für verschiedene Fächer.],
)

#include "content.typ"
