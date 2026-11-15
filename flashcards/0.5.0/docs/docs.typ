#import "@schule/schuldocs:0.3.1": *

#let pkg = toml("../typst.toml")

#show: docs.with(
  toml: pkg,
  abstract: [Das `flashcards`-Paket setzt Lernkarten zum Ausdrucken: acht Karten je Seite, auf einer Seite die Fragen, auf der nächsten die Antworten. Beidseitig gedruckt liegt jede Antwort hinter ihrer Frage.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
