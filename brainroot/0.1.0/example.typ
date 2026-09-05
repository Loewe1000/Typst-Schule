#import "lib.typ": *
#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Helvetica", size: 11pt)

#brainroot([Energiearten],
  branch([Bewegungsenergie], [Kinetische Energie], [Windenergie], [Flugenergie], [Körper-Energie]),
  branch([Geräuschenergie/Schallenergie]),
  branch([Druckenergie]),
  branch([Spannenergie], [Dehnungsenergie / Verformungsenergie]),
  branch([Elektrische Energie], [Spannungsenergie]),
  branch([Wärmeenergie], [Feuerenergie]),
  branch([Atomenergie]),
  branch([Chemische Energie], [Körper-Energie], color: rgb("#e8321e")),
  branch([Strahlungsenergie], [Lichtenergie], color: rgb("#f5a623")),
  branch([Höhenenergie], [Schwerkraftenergie], [Gewichtenergie/ Masseenergie], color: rgb("#f2c230")),
)

#pagebreak()

// Drei Ebenen, explizite Seiten, Umbruch langer Beschriftungen
#brainroot([Fotosynthese], max-width: 3.5cm, root-fill: green.lighten(50%),
  branch([Lichtreaktion], branch([Fotolyse], [Wasser wird gespalten, Sauerstoff entsteht]), [ATP], [NADPH], side: right),
  branch([Dunkelreaktion], [Calvin-Zyklus], [Glucose]),
  branch([Voraussetzungen], [Licht], [Wasser], [Kohlenstoffdioxid], [Chlorophyll], side: left),
)

#pagebreak()

// Dieselbe Karte als Liste
#brainroot(title: [Energiearten])[
  - Bewegungsenergie
    - Kinetische Energie
    - Flugenergie
    - Körper-Energie
    - Windenergie
  - Spannenergie
    - Dehnungsenergie
    - Verformungsenergie
  - Wärmeenergie
    - Feuerenergie
  - Höhenenergie
    - Schwerkraftenergie
    - Gewichtenergie
      - Masseenergie
]

#pagebreak()

// Die sechs Themes, dieselbe Karte
#let karte = [
  - Bewegungsenergie
    - Kinetische Energie
    - Windenergie
  - Spannenergie
    - Dehnungsenergie
  - Wärmeenergie
    - Feuerenergie
  - Höhenenergie
    - Schwerkraftenergie
    - Gewichtenergie
]
#set text(size: 8pt)
#grid(columns: 2, gutter: 1cm,
  ..("soft", "outline", "blocks", "lines", "sketch", "bubbles").map(t => [
    #text(size: 10pt, weight: "bold", raw(t))
    #v(2mm)
    #brainroot(title: [Energiearten], theme: t, karte)
  ])
)

#pagebreak()

// Ein Theme anpassen und alles auf eine Seite legen
#brainroot(title: [Energiearten], layout: "right",
  theme: (base: "outline", edge: "elbow", radius: 0pt), karte)

#pagebreak()

// Die drei weiteren Anordnungen
#set text(size: 9pt)
#brainroot(title: [Energiearten], layout: "down", karte)
#v(1cm)
#brainroot(title: [Energiearten], layout: "up", theme: "blocks", karte)

#pagebreak()
#brainroot(title: [Energiearten], layout: "radial",
  branch([Bewegungsenergie], [Kinetische Energie], [Windenergie]),
  branch([Spannenergie], [Dehnungsenergie]),
  branch([Wärmeenergie], [Feuerenergie]),
  branch([Druckenergie]),
  branch([Höhenenergie], [Schwerkraftenergie], [Gewichtenergie]),
  branch([Strahlungsenergie], [Lichtenergie]),
  branch([Chemische Energie]),
)
#v(1cm)
#brainroot(title: [Energiearten], layout: "radial", theme: "lines", karte)

#pagebreak()

// Handgezeichnet: vier Varianten, mit einer Handschrift
#set text(font: "Patrick Hand", size: 10pt)
#grid(columns: 2, gutter: 1cm,
  ..("hand", "scribble", "marker", "pencil").map(t => [
    #text(size: 12pt, weight: "bold", raw(t))
    #v(2mm)
    #brainroot(title: [Energiearten], theme: t, karte)
  ])
)
#v(1cm)
// Stärke des Wackelns
#grid(columns: 3, gutter: 1cm, ..(0.5, 1, 2.5).map(w => [
  #raw("wobble: " + str(w))
  #brainroot(title: [Energiearten], theme: "hand", wobble: w, karte)
]))
#v(1cm)
// Eigene Mischung: Kritzel-Wackeln auf dem Blocks-Theme, Beschriftung in Kalam
#brainroot(title: [Energiearten], layout: "radial",
  theme: (base: "blocks", hand: (amplitude: 1, wavelength: 60, randomness: 2, segment: 1.5, passes: 1), font: "Kalam"),
  karte)

#pagebreak()

// Die zehn Paletten
#set text(font: "Helvetica", size: 8pt)
#grid(columns: 2, gutter: 8mm,
  ..("poster", "pastel", "grayscale", "mono", "plain", "earth", "ocean", "sunset", "forest", "neon").map(p => [
    #text(size: 10pt, weight: "bold", raw(p))
    #v(1mm)
    #brainroot(title: [Energiearten], palette: p, karte,
      branch([Strahlungsenergie], [Lichtenergie]), branch([Druckenergie]))
  ])
)
