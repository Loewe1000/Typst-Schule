#import "@schule/schuldocs:0.2.0": *

#show: docs.with(
  toml: toml("../typst.toml"),
  abstract: [Das `typlace`-Paket erstellt Tischlayouts für Klassenräume aus einem einfachen String-Muster. Tische, freie Plätze und ein Lehrerpult werden als Rastergrafik dargestellt.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
