// fehler: `word` hat 4 Buchstaben, es gibt aber 5
#import "@schule/trimino:0.5.0": domino
#domino(layout: "stack", word: "TOLL", pairs: range(4).map(i => ([#i], [#i])))
