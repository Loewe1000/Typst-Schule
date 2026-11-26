// copies unter 1: verständliche Meldung.
// fehler: `copies` muss mindestens 1 sein
#import "@schule/trimino:0.5.0": trimino

#trimino(pairs: range(12).map(i => ([#i + 1], [#(i + 1)])), copies: 0)
