#import "@schule/schuldocs:0.2.0": *

#let pkg = toml("../typst.toml")

#show: docs.with(
  toml: pkg,
  authors: pkg.package.authors,
  abstract: [Das `arbeitsblatt`-Paket ist das zentrale Template-Paket des Schule-Ökosystems. Es bietet eine vollständige Lösung zur Erstellung professioneller Arbeitsblätter.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
