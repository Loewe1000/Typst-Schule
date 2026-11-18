// Alte Funktionsnamen bis 0.0.2. Jeder Aufruf bricht mit „heißt jetzt" ab.
// Die Datei ist vom Namens-Lint ausgenommen.

#import "internal/check.typ": stub

// umbenannte öffentliche Funktionen
#let sitzplan-bericht = stub("typlace", "sitzplan-bericht", "seating-report")
#let sitzplan-kennzahlen = stub("typlace", "sitzplan-kennzahlen", "seating-summary")
#let sitzplan-ergebnis = stub("typlace", "sitzplan-ergebnis", "seating-result")

// Einlesen und Prüfen: `wunschliste` erledigt beides in einem Schritt
#let schueler-lesen = stub("typlace", "schueler-lesen", "wunschliste")
#let schueler-pruefen = stub("typlace", "schueler-pruefen", "wunschliste")

// nach `internal` gewandert (keine zugesicherte Schnittstelle)
#let ist-frei = stub("typlace", "ist-frei", "internal.is-free")
#let ist-pult = stub("typlace", "ist-pult", "internal.is-desk")
#let ist-koerper = stub("typlace", "ist-koerper", "internal.is-table")
#let ist-platz = stub("typlace", "ist-platz", "internal.is-seat")
#let koerper-zellen = stub("typlace", "koerper-zellen", "internal.table-cells")
#let plaetze-analysieren = stub("typlace", "plaetze-analysieren", "internal.analyze-layout")
#let wasm-suchen = stub("typlace", "wasm-suchen", "internal.wasm-search")
#let bewerte = stub("typlace", "bewerte", "internal.score-plan")
#let kontext-erstellen = stub("typlace", "kontext-erstellen", "internal.build-problem")
#let normalisiere-vorgaben = stub("typlace", "normalisiere-vorgaben", "internal.normalize-constraints")
#let platz-von-schueler = stub("typlace", "platz-von-schueler", "internal.seat-of-students")
#let punkte-schueler = stub("typlace", "punkte-schueler", "internal.student-score")
#let punkte-wert = stub("typlace", "punkte-wert", "internal.student-points")
#let tausch-delta = stub("typlace", "tausch-delta", "internal.swap-delta")
#let statistik = stub("typlace", "statistik", "internal.statistics")
