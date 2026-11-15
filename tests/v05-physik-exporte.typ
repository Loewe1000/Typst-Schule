// physik 0.5.0: Die öffentliche Oberfläche ist genau die geplante Namensliste;
// nichts aus random, zap, fancy-units oder den Unterdateien wird durchgereicht.
// erwartet: Exporte in Ordnung
// erwartet: Faktor 1000 1 100000
#import "@schule/physik:0.5.0" as physik

#let erwartet = (
  "datensatz", "messdaten", "berechnung", "messwerttabelle",
  "lineare-regression", "quadratische-regression", "wurzel-regression",
  "exponentielle-regression", "potenz-regression", "polynom-regression",
  "schaltkreis", "source", "multimeter", "lamp", "ammeter", "voltmeter", "motor", "generator",
  "konstante", "constants", "internal",
  // abbrechende Stubs alter Funktionsnamen
  "lineare_regression", "quadratische_regression", "wurzel_regression",
  "exponentielle_regression", "potenz_regression", "polynom_regression",
  "simple-source", "amperemeter",
)
#let vorhanden = dictionary(physik).keys()
#let fehlend = erwartet.filter(name => name not in vorhanden)
#let zuviel = vorhanden.filter(name => name not in erwartet)
#if fehlend.len() == 0 and zuviel.len() == 0 [Exporte in Ordnung] else [fehlend: #fehlend, zu viel: #zuviel]

// internal.prefix-factor ist die Schnittstelle für mathematik
Faktor #physik.internal.prefix-factor("k") #physik.internal.prefix-factor(none) #physik.internal.prefix-factor("e5")
