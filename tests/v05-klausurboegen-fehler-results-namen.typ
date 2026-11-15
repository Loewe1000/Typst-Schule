// klausurboegen 0.5.0: Namensliste statt CSV-Zeilen (früher „invalid float")
// fehler: klausurboegen.klausurboegen: `results` erwartet CSV-Zeilen (Arrays aus Text), bekam als 1. Zeile `"Max Mustermann"` – Kopfzeile, Maximalpunkte und je Schüler eine Zeile (Name, Note, Punkte …) übergeben, zum Beispiel `csv("ergebnisse.csv")`
#import "@schule/klausurboegen:0.5.0": *
#klausurboegen(title: "P", results: ("Max Mustermann", "Erika Musterfrau"))
