#import "@schule/schuldocs:0.2.0": *

#show: docs.with(
  toml: toml("../typst.toml"),
  abstract: [Das `gutachten`-Paket erstellt strukturierte Gutachten und Bewertungsbögen für Klausuren. Es erlaubt die Konfiguration von Fach, Niveau, Kürzel und weiteren Metadaten.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
