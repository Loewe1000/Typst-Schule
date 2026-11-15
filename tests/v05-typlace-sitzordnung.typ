// typlace 0.5.0: Sitzordnung suchen, Vorgaben einhalten, Bericht ausgeben.
// erwartet: 14 von 14 Wünschen erfüllt \(100 %\)
// erwartet: Auswertung der Sitzordnung \(50 Versuche
// erwartet: Schüler mit allen Wünschen 8
// erwartet: Greta 1 / 1 Hanna
// erwartet: fest-ok true
// erwartet: getrennt-ok true
// erwartet: kern-gleich true
// erwartet: schluessel-ok true
#import "@schule/typlace:0.5.0": default-weights, seating-report, seating-summary, sitzordnung, typlace

#let layout = "11..22\n11..22\n11..22\n......\n..PP.."
#let wishes = "Name|Position|Wunsch|Wunsch
Anna|l|Ben|Clara
Ben||Anna|Clara
Clara||Anna|Ben
David||Emil|Felix
Emil||David|Felix
Felix||David|Emil
Greta|r|Hanna
Hanna||Greta|!Anna"

#let plan = sitzordnung(layout, wishes, seed: 7, quality: "fast")
#typlace(layout, names: plan.names)
#seating-summary(plan)
#seating-report(plan)

// Harte Vorgaben: fester Platz, Zone, getrennt, zusammen.
// (Eine Tischreihe: in der Tiefe gibt es nur „mitte", deshalb eine Seitenvorgabe.)
#let hart = sitzordnung(
  layout,
  wishes,
  seed: 3,
  quality: "fast",
  constraints: (
    fixed: (Ben: 3),
    must-left: ("Greta",),
    apart: (("Anna", "Clara"),),
    together: (("David", "Hanna"),),
  ),
  weights: (tiers: (1.0, 0.5, 0.25), position: 1.0),
  front: "bottom",
  perspective: "plan",
  duration: "0,1 s",
)
#let tisch(name) = hart.geometry.seats.at(hart.names.position(n => n == name)).table
fest-ok #(hart.names.at(3) == "Ben" and hart.geometry.seats.at(hart.names.position(n => n == "Greta")).zone.side == "left")
getrennt-ok #(tisch("Anna") != tisch("Clara") and tisch("David") == tisch("Hanna"))

// Plugin und Typst-Referenz liefern bei gleichem Seed denselben Plan.
#let a = sitzordnung(layout, wishes, seed: 5, attempts: 3, max-steps: 60, engine: "wasm")
#let b = sitzordnung(layout, wishes, seed: 5, attempts: 3, max-steps: 60, engine: "typst")
kern-gleich #(a.assignment == b.assignment and a.checked == b.checked)

// Rückgabe und Gewichte tragen die englischen Schlüssel.
schluessel-ok #(
  ("names", "assignment", "seat-of", "points", "statistics", "details", "notes", "geometry", "problem").all(k => k in plan)
    and plan.statistics.wishes-fulfilled == 14
    and default-weights.adjacent == 1.0
    and plan.geometry.seats.first().zone == (depth: "middle", side: "right")
)
