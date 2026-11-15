// gutachten 0.5.0: Auch als Show-Regel nennt die Meldung den neuen Namen (Namen werden vor den Positionsargumenten geprüft).
// fehler: gutachten.set-options: `fach` heißt jetzt `subject`
#import "@schule/gutachten:0.5.0": *

#show: set-options.with(fach: "Physik")
