// Alte Funktionsnamen aus gutachten 0.0.1 und 0.0.2. Jeder Aufruf bricht mit
// einer Meldung ab, die den neuen Namen nennt (konvention.md 9.3).
#import "internal/check.typ": fail, stub

// 0.0.2
#let set-gutachten-infos = stub("gutachten", "set-gutachten-infos", "set-options")
#let set-aufgaben = stub("gutachten", "set-aufgaben", "set-tasks")
#let bewertungsskala = stub("gutachten", "bewertungsskala", "format-grade")

// 0.0.1
#let gutachten-optionen = stub("gutachten", "gutachten-optionen", "set-options")
#let sachgebiet = (..args) => fail("gutachten", "sachgebiet", "`sachgebiet` gibt es seit 0.0.2 nicht mehr – die Aufgaben in `set-tasks` eintragen und je Aufgabe `aufgabe(\"…\", points: …)[...]` schreiben")
#let pflichtteil = (..args) => fail("gutachten", "pflichtteil", "`pflichtteil` gibt es seit 0.0.2 nicht mehr – die Aufgaben in `set-tasks` eintragen und je Aufgabe `aufgabe(\"…\", points: …)[...]` schreiben")
