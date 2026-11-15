// klausurboegen 0.5.0: Note außerhalb von 1 bis 6
// fehler: klausurboegen.klausurboegen: `results`: Note `"9"` in der Zeile `Eva` – in Spalte 2 die Note als ganze Zahl von 1 bis 6 eintragen
#import "@schule/klausurboegen:0.5.0": *
#klausurboegen(title: "P", overprint: true, stage: "sek-1", results: (("Name", "Note", "A1"), ("", "", "4"), ("Eva", "9", "3")))
