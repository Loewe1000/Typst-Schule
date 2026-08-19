#import "@schule/schuldocs:0.2.0": *

#show: docs.with(
  toml: toml("../typst.toml"),
  abstract: [Das `typlace`-Paket erstellt Sitzpläne für Klassenräume aus einem einfachen String-Muster und sucht auf Wunsch die Sitzordnung, die am besten zu den Wünschen der Klasse passt.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
