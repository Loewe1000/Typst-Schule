// fehler: trimino.trimino: die Form `hexagon` gibt es nicht für 5 Paare
#import "@schule/trimino:0.5.0": trimino

#trimino(shape: "hexagon", pairs: range(5).map(i => ([#i], [#i])))
