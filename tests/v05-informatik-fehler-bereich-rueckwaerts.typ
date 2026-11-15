// informatik 0.5.0: rückwärts geschriebener Bereich wird nicht mehr übergangen.
// fehler: informatik.ascii-table: `domains` enthält `("z", "a")` – der Bereich läuft rückwärts, das kleinere Zeichen zuerst schreiben
#import "@schule/informatik:0.5.0": *
#ascii-table(domains: (("z", "a"), "b"))
