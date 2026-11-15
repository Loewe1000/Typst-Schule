// mathematik 0.5.0: steckbrief mit den drei Zahlenformaten, Dezimalkomma und mehr als acht Bedingungen.
// erwartet: 0,50
// erwartet: Koeffizient a: 0\.5
// erwartet: Wert 1 Ende
// erwartet: Gerade 2
// erwartet: neun i
#import "@schule/mathematik:0.5.0": graphen, steckbrief

#let sb = steckbrief("f(0)=2", "f'(0)=0", "f(2)=0", "f'(2)=0")
#sb.ansatz

#sb.math

#(sb.math-digits)(4)

#sb.system #sb.condition-system #sb.conditions.join[, ] #sb.equations.join[; ]

Koeffizient a: #sb.coefficients.a

Wert #calc.round((sb.function)(1), digits: 6) Ende

#graphen(sb.function, domain: (-1, 3))

#steckbrief("f(1/2)=3", "f'(-1)=0.5", "f''(0)=6", notation: "fraction").math
#steckbrief("f(100)=3", "f(200)=0.00015", notation: "scientific", tolerance: 1e-12).math

// Dezimalkomma in der Bedingung
Gerade #calc.round((steckbrief("f(0)=0,5", "f(1)=1,5").function)(1.5), digits: 6)

// Neun Bedingungen: die Koeffizienten heißen a bis i
#let big = steckbrief(..range(9).map(k => "f(" + str(k) + ")=" + str(k * k)))
neun #big.coefficients.keys().last()
