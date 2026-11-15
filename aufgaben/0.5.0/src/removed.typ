// Alte Funktionsnamen (bis aufgaben 0.3.1). Jeder Aufruf bricht mit einer
// Meldung ab, die den neuen Namen oder den Ersatz nennt. Vom Namens-Lint
// ausgenommen (konvention.md 9.3).
#import "internal/check.typ": fail, stub

// Für Namen ohne Nachfolger: „gibt es nicht mehr" mit Abhilfe.
#let gone(old, hint) = (..args) => fail("aufgaben", old, "`" + old + "` gibt es nicht mehr – " + hint)

#let reset-aufgaben = stub("aufgaben", "reset-aufgaben", "reset-tasks")
#let show-loesungen = stub("aufgaben", "show-loesungen", "show-solutions")
#let show-offene-loesungen = stub("aufgaben", "show-offene-loesungen", "show-solutions(select: \"pending\")")
#let show-materialien = stub("aufgaben", "show-materialien", "show-materials")
#let show-erwartungen = stub("aufgaben", "show-erwartungen", "show-expectations")
#let show-bewertung = stub("aufgaben", "show-bewertung", "show-points-table")
#let format-punkte = stub("aufgaben", "format-punkte", "format-points")

#let show-loesung = gone("show-loesung", "`show-solutions(select: \"current\")` schreiben")
#let show-loesung-inline = gone("show-loesung-inline", "`show-solutions(inline: true)` schreiben")
#let show-material = gone("show-material", "`show-materials(select: \"current\")` schreiben")
#let get-punkte-anzeige = gone("get-punkte-anzeige", "die Anzeige steht in der Option `points`")
#let get-punkte-position = gone("get-punkte-position", "die Position steht in der Option `points-position`")
