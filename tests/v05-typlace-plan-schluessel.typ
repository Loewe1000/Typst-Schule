// typlace 0.5.0: Schlüssel im Plan (details, geometry, problem) wie in der
// Umbenennungstabelle; ein Dictionary mit `students` geht unverändert durch;
// Eingaben, die in 0.0.2 kompilierten, kompilieren weiter.
// erwartet: eintrag-ok true
// erwartet: details-ok true
// erwartet: geometrie-ok true
// erwartet: problem-ok true
// erwartet: durchgereicht-ok true
// erwartet: 0\.4\)
#import "@schule/typlace:0.5.0": seating-report, sitzordnung, typlace, wunschliste

#let layout = "11.22\n11.22\n..P.."
#let wishes = "A|v|B|!C\nB||A\nC|h|A\nD|!l|C"
#let plan = sitzordnung(layout, wishes)
#let d = plan.details.at(0)

eintrag-ok #(
  d.fulfilled.at(0).keys() == ("student", "kind", "points")
    and d.violated.at(0).keys() == ("student", "kind", "points")
    and d.fulfilled.at(0).student == 1
    and d.fulfilled.at(0).kind == "adjacent"
)
details-ok #(
  d.keys().sorted() == ("constraints-violated", "fulfilled", "points", "position", "position-points", "position-violated", "violated")
)
geometrie-ok #(
  ("matrix", "rows", "columns", "front", "seats", "tables", "zones", "relations").all(k => k in plan.geometry)
    and plan.geometry.seats.at(0).keys().sorted() == ("character", "column", "distance", "index", "row", "table", "zone")
    and plan.geometry.seats.at(0).table == "table-1"
    and plan.geometry.relations.at(0).at(0) == "self"
    and plan.geometry.zones.keys() == ("depth", "side")
)
problem-ok #(
  ("geometry", "students", "index-of", "wishes", "rejections", "apart", "together", "reverse", "weights", "student-count", "seat-count").all(k => k in plan.problem)
)

// Das Ergebnis von `wunschliste()` wird nur geprüft, nicht neu aufgelöst.
#let liste = wunschliste(wishes)
#let aus-liste = sitzordnung(layout, liste)
durchgereicht-ok #(
  aus-liste.problem.students == liste.students
    and aus-liste.assignment == plan.assignment
    and sitzordnung(layout, (students: liste.students)).notes == ()
)

// Füllung als Verlauf, Zellmaße als Anteil/Bruchteil, Rechenzeit als Zahl.
#typlace(layout, names: plan.names, table-fill: gradient.linear(red, blue), cell-width: 20%, cell-height: auto)
#seating-report(sitzordnung(layout, wishes, duration: 0.4))
