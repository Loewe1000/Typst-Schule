// typlace 0.5.0: Wunschliste lesen und prüfen; die Positionsangaben der
// Liste bleiben deutsch, die Schlüssel des Ergebnisses sind englisch.
// erwartet: liste-ok true
// erwartet: hinweis-ok true
// erwartet: csv-ok true
// erwartet: Hinweise zur Wunschliste
// erwartet: Carl wünscht „vorne“
#import "@schule/typlace:0.5.0": seating-report, sitzordnung, wunschliste

#let liste = wunschliste(
  "Anna;m;Ben;Zoe\nBen;;Anna\nCarl;v, l;Dora;!Ben\nDora;nicht hinten;Carl;Anna;Ben",
  delimiter: ";",
  header-row: false,
  seat-count: 8,
  max-wishes: 2,
  strict: false,
)
liste-ok #(
  liste.students.at(2) == (name: "Carl", position: (depth: "front", side: "left"), position-avoided: (depth: (), side: ()), wishes: ("Dora",), rejections: ("Ben",))
    and liste.students.at(3).position-avoided.depth == ("back",)
    and liste.students.at(3).wishes == ("Carl", "Anna")
)
hinweis-ok #(liste.notes.len() == 2 and liste.notes.last().contains("Zoe"))

#let klein = "TT.TT\nTT.TT\n.....\n..P.."
#seating-report(sitzordnung(klein, liste, seed: 1, front: "top"), details: false)

// Zeilen aus csv() gehen direkt an sitzordnung.
#let plan = sitzordnung(klein, csv(bytes("Name,Position,Wunsch\nUwe,l,Ina\nIna,r,Uwe")), seed: 2)
csv-ok #(plan.statistics.wishes-fulfilled == 2)
