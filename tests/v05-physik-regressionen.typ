// physik 0.5.0: die sechs Regressionen mit x:, y:, degree:; Ergebnis unter
// coefficients, function und math-digits.
// erwartet: m=2 b=1 f=11
// erwartet: a=1 b=0 c=2 f=11
// erwartet: wurzel a=2 b=1
// erwartet: exp a=0\.6931 b=3
// erwartet: potenz a=2 m=3
// erwartet: polynom c0=1 c3=1 f=9
// erwartet: 𝑦 = −2𝑥 \+ 3
// erwartet: 𝑠 = 2 ms ⋅ 𝑡 \+ 0,50 m
// erwartet: 𝑡 \+ 0,5000 m
#import "@schule/physik:0.5.0": datensatz, exponentielle-regression, lineare-regression, polynom-regression, potenz-regression, quadratische-regression, wurzel-regression

#let round(x) = calc.round(x, digits: 4)

#let lin = lineare-regression(x: (0, 1, 2, 3), y: (1, 3, 5, 7))
m=#round(lin.coefficients.m) b=#round(lin.coefficients.b) f=#round((lin.function)(5))

#let quad = quadratische-regression(x: (0, 1, 2, 3), y: (2, 3, 6, 11))
a=#round(quad.coefficients.a) b=#round(quad.coefficients.b) c=#round(quad.coefficients.c) f=#round((quad.function)(3))

#let root = wurzel-regression(x: (0, 1, 4, 9), y: (1, 3, 5, 7))
wurzel a=#round(root.coefficients.a) b=#round(root.coefficients.b)

#let expo = exponentielle-regression(x: (0, 1, 2), y: (3, 6, 12))
exp a=#round(expo.coefficients.a) b=#round(expo.coefficients.b)

#let power = potenz-regression(x: (1, 2, 3), y: (2, 16, 54))
potenz a=#round(power.coefficients.a) m=#round(power.coefficients.m)

#let poly = polynom-regression(x: (0, 1, 2, 3, 4), y: (1, 2, 9, 28, 65), degree: 3)
polynom c0=#round(poly.coefficients.c0) c3=#round(poly.coefficients.c3) f=#round((poly.function)(2))

// negatives Vorzeichen des ersten Koeffizienten bleibt stehen
#lineare-regression(x: (0, 1, 2), y: (3, 1, -1)).math

// Datensätze mit Einheit: Gleichung mit Namen und Einheiten
#let t = datensatz((1, 2, 3), name: $t$, unit: "s")
#let s = datensatz((2.5, 4.5, 6.5), name: $s$, unit: "m")
#lineare-regression(x: t, y: s).math

#(lineare-regression(x: t, y: s).math-digits)(4)
