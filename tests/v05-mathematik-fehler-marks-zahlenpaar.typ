// mathematik 0.5.0: ein nacktes Zahlenpaar in `marks` wird nicht mehr still verworfen.
// fehler: mathematik.graphen: `marks: (1, 2)` ist ein nacktes Zahlenpaar – `marks: ((at: (1, 2)),)` schreiben
#import "@schule/mathematik:0.5.0": *

#graphen($x$, marks: (1, 2))
