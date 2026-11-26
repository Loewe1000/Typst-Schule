// trimino-cut-file außerhalb eines Bündels: verständliche Meldung.
// fehler: nur in einem Bündel möglich
#import "@schule/trimino:0.5.0": trimino, trimino-cut-file

#trimino(pairs: range(12).map(i => ([#i + 1], [#(i + 1)])), cut-marks: true)
#trimino-cut-file("schnitt.svg")
