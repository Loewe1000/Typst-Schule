// mathematik 0.5.0: aus `size` und `scale` werden `width` und `height` als Längen.
// fehler: mathematik.graphen: `size: (10, 6)` mit `scale: 0.5` heißt jetzt `width: 5cm, height: 3cm`
#import "@schule/mathematik:0.5.0": *

#graphen($x^2$, size: (10, 6), scale: 0.5)
