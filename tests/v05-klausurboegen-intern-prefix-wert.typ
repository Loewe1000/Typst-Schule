// klausurboegen 0.5.0: check-names mit Präfix, alter Schlüssel mit altem Wert
// fehler: klassenarbeit.klassenarbeit: `answer-sheets.muster: "kariert"` heißt jetzt `answer-sheets.pattern: "squares"`
#import "@schule/klausurboegen:0.5.0" as kb
#kb.internal.check-names("klassenarbeit", "klassenarbeit", (muster: "kariert"), prefix: "answer-sheets.")
