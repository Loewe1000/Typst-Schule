// klausurboegen 0.5.0: Ergebnisdruck ohne Schülerzeile
// fehler: klausurboegen.klausurboegen: `overprint: true` mit 2 Zeilen in `results` – Kopfzeile, Maximalpunkte und je Schüler eine Zeile übergeben
#import "@schule/klausurboegen:0.5.0": *
#klausurboegen(title: "P", overprint: true, results: (("N", "Note", "A1"), ("", "", "4")))
