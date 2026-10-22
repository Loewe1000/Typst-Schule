#import "../../../schuldocs/0.1.0/lib.typ": with-pdf, show-example, show-module, show-code
#import "../src/arbeitsblatt.typ" as ab
#import "@schule/aufgaben:0.3.0" as auf

#let pkg = toml("../typst.toml")

#show: with-pdf(
  name: pkg.package.name,
  version: pkg.package.version,
  authors: pkg.package.authors,
  license: pkg.package.license,
  description: pkg.package.description,
  abstract: [Das `arbeitsblatt`-Paket ist das zentrale Template-Paket des Schule-Ökosystems. Es bietet eine vollständige Lösung zur Erstellung professioneller Arbeitsblätter.],
  examples-scope: (
    scope: (arbeitsblatt: ab, aufgaben: auf),
    imports: (arbeitsblatt: "*", aufgaben: "aufgabe, teilaufgabe, loesung, material"),
  ),
)

#include "content.typ"

