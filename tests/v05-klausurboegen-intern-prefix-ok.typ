// klausurboegen 0.5.0: check-names mit Präfix nimmt gültige Schlüssel an; internal exportiert keinen Namen aus patterns
// erwartet: gut
// nicht: kariert
#import "@schule/klausurboegen:0.5.0" as kb
#kb.internal.check-names("klassenarbeit", "klassenarbeit", (pattern: "lines", stage: "sek-1"), prefix: "answer-sheets.")
#kb.internal.check-values("klassenarbeit", "klassenarbeit", (pattern: "lines", stage: "sek-1"), prefix: "answer-sheets.")
gut #dictionary(kb.internal).keys().filter(k => k in ("kariert", "liniert", "tablex")).join(" ")
