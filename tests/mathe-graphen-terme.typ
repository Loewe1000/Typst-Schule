// graphen: deutsche Schreibweisen, Polstellen, x: auto, marks, step: none.
#import "@schule/mathematik:0.0.2": *
#graphen($f(x)=0,5 x^2 - 2$)
#graphen($f(x) = x e^(-x)$, x: (-1, 5), y: (-1, 1))
#graphen($x(x-2)$)
#graphen($(x-1)(x+2)$)
#graphen($|x| - 1$)
#graphen($x sin(x)$)
#graphen($1/x$, x: (-3, 3), y: (-3, 3))
#graphen($tan(x)$, x: (-3, 3), y: (-3, 3))
#graphen($x^2$, x: auto)
#graphen($x$, marks: ((1, 2),))
#graphen($x$, step: none)
#graphen((term: $x^2$, label: (content: $f$, x: 4)), x: (-3, 5), y: (-1, 5))
