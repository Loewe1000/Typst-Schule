#import "@schule/schuldocs:0.2.0": *

#show: docs.with(
  toml: toml("../typst.toml"),
  authors: (
    "Lukas Köhl",
    "Alexander Schulz",
  ),
  abstract: [
    Das `klassenarbeit` Paket bietet eine spezialisierte Lösung zur Erstellung von Klassenarbeiten und Tests für den Schulbereich. Es basiert auf dem `arbeitsblatt` Paket und erweitert es um spezielle Funktionen für Prüfungssituationen, einschließlich Erwartungshorizonte, Bewertungsbögen und automatischer Klausurbögen-Generierung.
  ],
  links: (
    (name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),
  ),
  notices: (
    [Entwickelt für das Schule-Typst-Ökosystem],
  ),
)

#include "content.typ"
