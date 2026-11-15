// klausurboegen 0.5.0: check-names mit Präfix, alt und neu zugleich (im Dictionary auch mit Vorgabewert erkannt)
// fehler: klassenarbeit.klassenarbeit: `answer-sheets.rand` (alt) und `answer-sheets.correction-margin` (neu) zugleich – nur `answer-sheets.correction-margin` schreiben
#import "@schule/klausurboegen:0.5.0" as kb
#kb.internal.check-names("klassenarbeit", "klassenarbeit", (rand: 4cm, correction-margin: 5cm), prefix: "answer-sheets.")
