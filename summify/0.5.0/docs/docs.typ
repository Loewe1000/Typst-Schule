#import "@schule/schuldocs:0.3.1": *
#import "../src/lib.typ": set-theme

#show: docs.with(
  toml: toml("../typst.toml"),
  abstract: [Das `summify`-Paket setzt Zusammenfassungen und Spickzettel im Raster: Themenboxen mit Abschnitten und Zellen auf einer Seite, mit Farbthemen und einem Lernmodus, der die Inhalte ausblendet.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
  // Beide Ausgaben teilen sich einen Introspektionsraum: jede beginnt wieder
  // mit dem Thema "default".
  reset: () => set-theme("default"),
)

#include "content.typ"
