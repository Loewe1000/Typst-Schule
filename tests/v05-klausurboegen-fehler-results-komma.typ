// klausurboegen 0.5.0: Punkte mit Komma
// fehler: klausurboegen.klausurboegen: `results`: `"3,5"` in der Zeile `Eva`, Spalte `A1`, ist keine Zahl – Punkte mit Dezimalpunkt schreiben, zum Beispiel `"3.5"`
#import "@schule/klausurboegen:0.5.0": *
#klausurboegen(title: "P", overprint: true, results: (("N", "Note", "A1"), ("", "", "4"), ("Eva", "9", "3,5")))
