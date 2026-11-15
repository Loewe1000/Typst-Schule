// Beispiel: drei Gutachten zu einer Physikklausur mit Wahlaufgaben.
#import "@schule/gutachten:0.5.0": *

#set-options(
  subject: "Physik",
  level: "E",
  teacher: "MS",
  max-points: 100,
  year: 2027,
)

#set-tasks((
  "Aufgabe 1": (max-points: 30),
  "Aufgabe 2": (max-points: 40, dative: "der zweiten Aufgabe", title: "Elektrisches Feld"),
  "Aufgabe 3": (max-points: 30, title: "Quantenobjekte"),
  "Aufgabe 4": (max-points: 30, title: "Atomhülle"),
))

#gutachten(first-name: "Anna", last-name: "Bauer")[
  #aufgabe("Aufgabe 1", points: 25)[
    #name beschreibt die Bewegung korrekt und rechnet mit $v = 2.5 "m/s"$ weiter.
    In Teil c) fehlt die Einheit.
  ]
  #aufgabe("Aufgabe 2", points: 35.5)[
    Die Formeln sind korrekt angewendet. In b) unterläuft #name ein Rechenfehler,
    der sich bis zum Ergebnis fortsetzt.
  ]
  #aufgabe("Aufgabe 3", points: 28)[
    Die Deutung des Experiments ist vollständig und sprachlich präzise.
  ]
]

#gutachten(first-name: "Lena", last-name: "Braun", selected-tasks: ("Aufgabe 2", "Aufgabe 4"))[
  #aufgabe("Aufgabe 1", points: 9)[#name löst nur Teil a).]
  #aufgabe("Aufgabe 2", points: 29)[Sehr gute Bearbeitung mit kleinen Lücken in d).]
  #aufgabe("Aufgabe 4", points: 14)[Das Termschema ist richtig, die Rechnung bricht ab.]
]

#gutachten(
  first-name: "Max",
  last-name: "Mustermann",
  selected-tasks: ("Pflichtteil": ("Aufgabe 1",), "Wahlteil": ("Aufgabe 2", "Aufgabe 3")),
)[
  #aufgabe("Aufgabe 1", points: 30)[Volle Punktzahl.]
  #aufgabe("Aufgabe 2", points: 40)[Volle Punktzahl.]
  #aufgabe("Aufgabe 3", points: 26.5)[Fast alles richtig; in c) fehlt die Begründung.]
]
