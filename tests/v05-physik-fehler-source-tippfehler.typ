// physik 0.5.0: ein Tippfehler eines eigenen Parameters geht nicht still an zap.
// fehler: physik.source: unbekannter Parameter `varient` – meintest du `kind`?
#import "@schule/physik:0.5.0": schaltkreis, source

#schaltkreis({
  source("q", (0, 0), (0, 3), varient: "lines")
})
