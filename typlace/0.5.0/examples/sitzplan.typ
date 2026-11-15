// Sitzplan nach Wünschen: Raum zeichnen, Sitzordnung suchen, Bericht ausgeben.
// Kompilieren:  typst compile examples/sitzplan.typ
#import "@schule/typlace:0.5.0": seating-report, seating-summary, sitzordnung, typlace

#set page(paper: "a4", margin: 1.5cm)
#set text(lang: "de", size: 10pt)

// Fünf Gruppentische zu je sechs Plätzen, Pult unten.
#let layout = "
  .11..22.
  .11..22.
  .11..22.
  ........
  33.44.55
  33.44.55
  33.44.55
  ........
  ...PP..."

// Die Wunschliste ist eine Datei neben dem Dokument: je Zeile
// Name|Position|Wunsch|Wunsch|!Ablehnung.
#let plan = sitzordnung(
  layout,
  read("wuensche.csv"),
  seed: 42,
  constraints: (
    must-front: ("Eva Lang",),
    apart: (("Max Klein", "Moritz Groß"),),
    together: (("Ida Berg", "Jonas Kern"),),
  ),
)

= Sitzplan

#align(center, typlace(layout, names: plan.names, number: true))

#seating-summary(plan)

#pagebreak()
= Auswertung

#seating-report(plan)
