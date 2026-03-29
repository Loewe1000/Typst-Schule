#import "../../../schuldocs/0.1.0/lib.typ": with-pdf, show-example, show-module, show-code

#let pkg = toml("../typst.toml")

#show: with-pdf(
  name: pkg.package.name,
  version: pkg.package.version,
  license: pkg.package.license,
  description: pkg.package.description,
  abstract: [Das \`flashcards\`-Paket erstellt beidseitige Lernkarten im 8-up-Format auf Letter-Papier. Die Karten können mit Frage, Antwort, Kopf- und Fußzeile belegt werden.],
)

#include "content.typ"
