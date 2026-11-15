#import "@schule/schuldocs:0.3.1": docs

#show: docs.with(
  toml: toml("../typst.toml"),
  abstract: [Das `gutachten`-Paket setzt Gutachten über schriftliche Abiturprüfungen: Kopf mit Name, Fach und Kürzel, je Aufgabe ein Abschnitt mit den erreichten Bewertungseinheiten, am Ende Gesamtpunktzahl, Note und Unterschriftszeilen.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
