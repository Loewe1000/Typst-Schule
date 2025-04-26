#import "@schule/gutachten:0.0.1": *

#gutachten-optionen(
  kurs: "MA3",
  niveau: "ea",
  prüfer: "Herr Schulz",
  korreferent: "Herr Köhl",
  jahr: 2024,
  fach: "Mathematik",
)

#gutachten(
  vorname: "Thomas",
  name: "Anders",
  geschlecht: "m",
)[

== Zum Pflichtteil
Hier steht was zum Pflichtteil.
#lorem(50)

== Zum Wahlteil
#sachgebiet(title: "Analysis", wahl: "B", BE: 40, punkte: 20)[

  Hier steht was zum Analysisteil.
  #lorem(70)
]

#sachgebiet(title: "Stochastik", wahl: "A", BE: 25, punkte: 20)[

  Hier steht was zum Stochastikteil.
  #lorem(70)
]
#sachgebiet(title: "Analytische Geometrie", wahl: "B", BE: 25, punkte: 20)[

  Hier steht was zum Analytische Geometrieteil.
  #lorem(70)
]

Hier steht was zur Form der Klausur.
#lorem(50)
]

#gutachten(
  vorname: "Lukas",
  name: "Köhl",
  geschlecht: "m",
)[

== Zum Pflichtteil
Hier steht was zum Pflichtteil.
#lorem(50)

== Zum Wahlteil
#sachgebiet(title: "Analysis", wahl: "B", BE: 40, punkte: 35)[

  Hier steht was zum Analysisteil.
  #lorem(70)
]

#sachgebiet(title: "Stochastik", wahl: "A", BE: 25, punkte: 25)[

  Hier steht was zum Stochastikteil.
  #lorem(70)
]
#sachgebiet(title: "Analytische Geometrie", wahl: "B", BE: 25, punkte: 16.5)[

  Hier steht was zum Analytische Geometrieteil.
  #lorem(70)
]

Hier steht was zur Form der Klausur.
#lorem(50)
]