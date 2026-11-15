// physik 0.5.0: der Sentinel `prefix: "1"` ist weg; das Aus ist `none`.
// fehler: physik.datensatz: `prefix: "1"` heißt jetzt `none`
#import "@schule/physik:0.5.0": datensatz

#datensatz((1, 2, 3), prefix: "1")
