#import "@schule/schuldocs:0.2.0": *

#show: docs.with(
  toml: toml("../typst.toml"),
  abstract: [Das `flashcards`-Paket erstellt beidseitige Lernkarten im 8-up-Format auf Letter-Papier. Die Karten können mit Frage, Antwort, Kopf- und Fußzeile belegt werden.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
