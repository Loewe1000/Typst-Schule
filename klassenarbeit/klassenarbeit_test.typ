#import "@schule/klassenarbeit:0.0.1": *
#import "@preview/unify:0.4.0": *


#show: klassenarbeit.with(
  title: "Physikklausur Nr. 1",
  class: "PH1",
  date: "06.10.2023",
  teacher: "SLZ",
  font-size: 11pt,
  logo: image("logo.svg"),
  table: (
    ("Hinweise", "Die Lösungen sind nachvollziehbar und in einer sauberen äußeren Form anzufertigen. Skizzen werden mit Lineal und Bleistift angefertigt."),
    ("Hilfsmittel", "keine"),
    ("Bearbeitugszeit","45 Minuten")
  ),
  loesungen: "seite"
)

#aufgabe(large: true)[
  #lorem(50)
]
#loesung[
  Test
]

#aufgabe(large: true)[
  #lorem(50)
]

#aufgabe(large: true)[
  #lorem(50)
]

#aufgabe(large: true)[
  #lorem(50)
]
