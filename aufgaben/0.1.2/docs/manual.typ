#import "../../../schuldocs/0.1.0/lib.typ": with-pdf, show-example, show-module, show-code
#import "../aufgaben.typ" as auf

#let pkg = toml("../typst.toml")

#show: with-pdf(
  name: pkg.package.name,
  version: pkg.package.version,
  authors: pkg.package.at("authors", default: ("Lukas Köhl", "Alexander Schulz")),
  license: pkg.package.license,
  description: pkg.package.description,
  abstract: [Das `aufgaben`-Paket ist das Fundament des Schule-Paket-Ökosystems. Es bietet alle grundlegenden Funktionen zur Strukturierung und Verwaltung von Aufgaben in Bildungsdokumenten.],
  examples-scope: (
    scope: (auf: auf),
    imports: (auf: "*"),
  ),
)

#include "content.typ"
