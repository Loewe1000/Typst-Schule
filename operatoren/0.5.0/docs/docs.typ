#import "@schule/schuldocs:0.3.1": docs

#show: docs.with(
  toml: toml("../typst.toml"),
  authors: ("Alexander Schulz",),
  abstract: [Das `operatoren`-Paket markiert Operatoren im Aufgabentext und setzt daraus eine Operatorenliste mit den Definitionen aus den Fachanforderungen für Mathematik und Physik.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
