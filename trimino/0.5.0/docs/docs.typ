// Handbuch und Website in einem Lauf:
//
//   typst compile docs.typ build --format bundle --features bundle,html --root /
//
// Der Inhalt steht in `content.typ` und ist für beide Ausgaben derselbe. Die
// Bilder in `assets/` erzeugt `bash assets/bilder.sh` neu (nach Designänderungen).

#import "@schule/schuldocs:0.3.1": *

#let pkg = toml("../typst.toml")

// Die Sprache ausdrücklich: sonst trennt Typst nach englischen Regeln und
// setzt englische Anführungszeichen.
#set text(lang: "de")

#show: docs.with(
  toml: pkg,
  // Das Zeichen statt des Namens im Kopf. Als SVG hängt es an keiner Schrift.
  logo: image("assets/logo.svg", height: 1.6em, alt: "trimino"),
  // Eine Seite je Kapitel; `alles.html` bleibt als eine Seite daneben liegen,
  // für Strg-F und zum Drucken. Das PDF entsteht aus dem ungeteilten Körper.
  split: true,
  toc-depth: 3,
  authors: pkg.package.at("authors", default: ()),
  abstract: [
    `trimino` setzt Legespiele für den Unterricht: *Triminos* aus dreieckigen
    Kärtchen und *Dominos* als Kette oder Stapel. Aus einer Liste von Paaren
    (Aufgabe, Lösung) entstehen Lösungsbild, Schnittbogen und Rückseite. Die
    Form wählt das Paket nach der Zahl der Paare; Farbkreise, Anlegerahmen
    und Lösungswort machen die Spiele selbstkontrollierend. Sieben Themes
    passen zu `@schule/arbeitsblatt`, und für den Schneideplotter gibt es
    Passermarken und Schnittdaten.
  ],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Teil des Schule-Typst-Ökosystems],),
)

#include "content.typ"
