// klausurboegen 0.5.0: check-names mit Präfix (Dictionary `answer-sheets` von klassenarbeit), alter Schlüssel
// fehler: klassenarbeit.klassenarbeit: `answer-sheets.weißer-rand` heißt jetzt `answer-sheets.correction-margin-blank`
#import "@schule/klausurboegen:0.5.0" as kb
#kb.internal.check-names("klassenarbeit", "klassenarbeit", ("weißer-rand": true), prefix: "answer-sheets.")
