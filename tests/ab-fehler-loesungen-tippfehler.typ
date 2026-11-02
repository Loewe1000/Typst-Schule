// Ein Tippfehler in `loesungen` darf keine Lösungen in die Schülerfassung drucken.
// fehler: ungültiger Wert für `loesungen`
#import "@schule/arbeitsblatt:0.4.0": *
#show: arbeitsblatt.with(title: [T], loesungen: "kiene")
#aufgabe[A #lsg[GEHEIM]]
