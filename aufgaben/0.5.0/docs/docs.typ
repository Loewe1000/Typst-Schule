#import "@schule/schuldocs:0.3.1": docs
#import "../src/lib.typ": reset-tasks

#let pkg = toml("../typst.toml")

#show: docs.with(
  toml: pkg,
  authors: pkg.package.at("authors", default: ("Lukas Köhl", "Alexander Schulz")),
  abstract: [Das Paket `aufgaben` ist das Fundament der Schule-Pakete: Aufgaben und Teilaufgaben mit Lösungen, Materialien, Erwartungshorizont und Punktetabelle. Die Vorlagen `arbeitsblatt` und `klassenarbeit` bauen darauf auf.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
  // Beide Ausgaben teilen sich einen Introspektionsraum: ohne diese
  // Rücksetzung zählt das Handbuch bei „Aufgabe 5" weiter, wo die
  // Website bei 4 aufgehört hat.
  reset: () => reset-tasks(),
)

#include "content.typ"
