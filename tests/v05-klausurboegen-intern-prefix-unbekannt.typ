// klausurboegen 0.5.0: check-names mit Präfix, Tippfehler
// fehler: klassenarbeit.klassenarbeit: unbekannter Schlüssel `answer-sheets.patern` – meintest du `answer-sheets.pattern`?
#import "@schule/klausurboegen:0.5.0" as kb
#kb.internal.check-names("klassenarbeit", "klassenarbeit", (patern: "lines"), prefix: "answer-sheets.")
