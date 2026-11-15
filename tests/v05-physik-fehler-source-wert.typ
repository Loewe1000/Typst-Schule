// physik 0.5.0: `current: "ac"` heißt jetzt `"alternating"`.
// fehler: physik.source: `current: "ac"` heißt jetzt `"alternating"`
#import "@schule/physik:0.5.0": schaltkreis, source

#schaltkreis({
  source("q", (0, 0), (0, 3), current: "ac")
})
