#import "@schule/schuldocs:0.2.0": *
#import "../aufgaben.typ": reset-aufgaben

#let pkg = toml("../typst.toml")

#show: docs.with(
  toml: pkg,
  authors: pkg.package.at("authors", default: ("Lukas Köhl", "Alexander Schulz")),
  abstract: [Das `aufgaben`-Paket ist das Fundament des Schule-Paket-Ökosystems. Es bietet alle grundlegenden Funktionen zur Strukturierung und Verwaltung von Aufgaben in Bildungsdokumenten.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
  // Beide Ausgaben teilen sich einen Introspektionsraum: ohne diese
  // Rücksetzung zählt das Handbuch bei „Aufgabe 5" weiter, wo die
  // Website bei 4 aufgehört hat.
  reset: () => reset-aufgaben(),
)

#include "content.typ"
