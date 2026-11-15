// physik 0.5.0: `variant` wird abgefangen, obwohl source weitere Argumente an zap durchreicht.
// fehler: physik.source: `variant` heißt jetzt `kind`
#import "@schule/physik:0.5.0": schaltkreis, source

#schaltkreis({
  source("q", (0, 0), (0, 3), variant: "lines")
})
