#import "@schule/schuldocs:0.3.1": docs
#import "../src/lib.typ": reset-tasks

#let pkg = toml("../typst.toml")

#show: docs.with(
  toml: pkg,
  authors: pkg.package.at("authors", default: ("Lukas Köhl", "Alexander Schulz")),
  abstract: [Das Paket `klassenarbeit` ist die Vorlage der Schule-Pakete für Klassenarbeiten, Klausuren und Tests. Es baut auf `arbeitsblatt` auf und ergänzt den Kopf mit Logo und Namensfeld, die Seitenzahlen, den Erwartungshorizont, das Lösungsdokument und die Klausurbögen.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
  // Beide Ausgaben teilen sich einen Introspektionsraum: ohne diese
  // Rücksetzung zählt das Handbuch die Aufgaben der Website weiter.
  reset: () => reset-tasks(),
)

#include "content.typ"
