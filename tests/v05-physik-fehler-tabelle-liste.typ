// physik 0.5.0: die Kurzform mit einer Liste entfällt.
// fehler: physik.messwerttabelle: Positionsargument ist eine Liste – Datensätze einzeln übergeben: `messwerttabelle(a, b)` oder `messwerttabelle(..liste)`
#import "@schule/physik:0.5.0": datensatz, messwerttabelle

#messwerttabelle((datensatz((1, 2)), datensatz((3, 4))))
