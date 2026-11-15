// mathematik 0.5.0: die öffentliche Oberfläche ist genau diese Namensmenge.
// erwartet: geogebra-algebra, geogebra-cell, geogebra-style, graphen, internal, kreisdiagramm, steckbrief
// erwartet: geogebra-approximate-button, geogebra-menu-button, geogebra-palette
#import "@schule/mathematik:0.5.0" as mathematik

#dictionary(mathematik).keys().sorted().join(", ")

#dictionary(mathematik.internal).keys().sorted().join(", ")
