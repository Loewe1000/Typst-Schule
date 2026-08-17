#import "@schule/schuldocs:0.2.0": *

#show: docs.with(
  toml: toml("../typst.toml"),
  abstract: [Das `klausurboegen`-Paket erstellt personalisierte Klausurbögen im A3-Querformat für ganze Schulklassen. Schülernamen werden automatisch auf die Bögen verteilt.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
