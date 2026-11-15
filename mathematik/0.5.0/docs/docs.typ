#import "@schule/schuldocs:0.3.1": *

#show: docs.with(
  toml: toml("../typst.toml"),
  authors: ("Lukas Köhl", "Alexander Schulz"),
  abstract: [Das `mathematik`-Paket stellt Werkzeuge für den Mathematikunterricht bereit: Funktionsgraphen im Koordinatensystem mit Flächen, Punkten und Messreihen, Steckbriefaufgaben, Kreisdiagramme und die nachgebildete Algebra-Ansicht von GeoGebra.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
)

#include "content.typ"
