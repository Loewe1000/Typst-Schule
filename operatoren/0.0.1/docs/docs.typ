#import "@schule/schuldocs:0.2.0": *

#show: docs.with(
  toml: toml("../typst.toml"),
  abstract: [Das `operatoren`-Paket verwaltet Operatoren in Klausuraufgaben und generiert aus CSV-Dateien eine tabellarische Operatorenliste für verschiedene Fächer.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
