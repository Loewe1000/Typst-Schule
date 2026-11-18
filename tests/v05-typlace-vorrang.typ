// typlace 0.5.0: Vorrang aus Vorplänen, nobody-empty, Ergebnis-Export.
// Vorpläne im Format von 0.5.0 und von 0.0.2 werden gelesen; Plugin und
// Typst-Referenz liefern mit den neuen Optionen denselben Plan.
// erwartet: vorrang-ok true
// erwartet: altformat-ok true
// erwartet: motoren-ok true
// erwartet: leer-ok true
// erwartet: export-anzahl 1
// erwartet: Vorrang \(alle Wünsche\)
// erwartet: Vorpläne gelesen
#import "@schule/typlace:0.5.0": seating-report, sitzordnung

#let layout = "111.222\n.......\n333.444\n..PPP.."
#let wishes = "A||B|C\nB||A|D\nC||A|B\nD||B|A\nE||F|A\nF||E|B\nG||H|A\nH||G|B\n"
#let vorher = (students: (A: (fulfilled: 1, named: 2), B: (fulfilled: 2, named: 2)))
#let alt = (schueler: (C: (erfuellt: 0, genannt: 2)))
#let basis = (weights: (table: 0.0, fairness: 10.0), attempts: 3, max-attempts: 6, seed: 5, nobody-empty: true)

#let p = sitzordnung(layout, wishes, previous: vorher, ..basis)
#let q = sitzordnung(layout, wishes, previous: (vorher, alt), priority: ("E",), ..basis)
#let r = sitzordnung(layout, wishes, previous: (vorher, alt), priority: ("E",), engine: "typst", ..basis)

vorrang-ok #(p.problem.priority == (true,) + (false,) * 7)
altformat-ok #(q.problem.priority.enumerate().filter(x => x.at(1)).map(x => x.at(0)) == (0, 2, 4))
motoren-ok #(q.assignment == r.assignment and q.points == r.points and q.attempts == r.attempts)
leer-ok #(q.statistics.unfulfilled == ())

#context {
  let e = query(<seating-result>)
  [export-anzahl #e.len()]
}
#seating-report(q)
