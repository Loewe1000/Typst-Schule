// klausurboegen 0.5.0: Ergebnisdruck ohne Titel (bisher still ein Blankobogen)
// fehler: klausurboegen.klausurboegen: `overprint: true` ohne `title` – der Ergebnisdruck braucht denselben Kopf wie der leere Bogen, `title` angeben
#import "@schule/klausurboegen:0.5.0": *
#klausurboegen(results: (("Name", "Note", "A1"), ("", "", "5"), ("Mia", "3", "4")), overprint: true)
