// klausurboegen 0.5.0: Ergebnisse ohne Titel (bisher still ein Blankobogen)
// fehler: klausurboegen.klausurboegen: `results` ohne `title` – der Blankobogen hat keine Namenszeile; `title` angeben oder `results` weglassen
#import "@schule/klausurboegen:0.5.0": *
#klausurboegen(results: (("Name", "Note", "A1"), ("", "", "5"), ("Mia", "3", "4")))
