// Ableitungsdomino zur Summenregel als Stapel: zwölf Paare Funktion ↔
// Ableitung. Oben steht jeweils die Ableitung der vorigen Funktion, unten die
// nächste Funktion. Die Rückseiten ergeben von oben nach unten ein
// Lösungswort (13 Kärtchen, also 13 Buchstaben).
#import "@schule/trimino:0.5.0": domino

#set page(paper: "a4", margin: 1.5cm)
#set text(lang: "de")

#domino(
  title: [Summenregel],
  layout: "stack",
  tags: ([$f'(x)$], [$f(x)$]),
  back: [Ableitung\ Summenregel],
  pairs: (
    ([$x^5 + x^(-3)$], [$5x^4 - 3/x^4$]),
    ([$x^7 - x^3$], [$7x^6 - 3x^2$]),
    ([$x^6 + x^(-4)$], [$6x^5 - 4/x^5$]),
    ([$x^2 + x^(-5)$], [$2x - 5/x^6$]),
    ([$x^4 + x^(-2)$], [$4x^3 - 2/x^3$]),
    ([$x^(-6) - x^3$], [$-6/x^7 - 3x^2$]),
    ([$x^3 + x^(-2)$], [$3x^2 - 2/x^3$]),
    ([$x^5 - x^(-2)$], [$5x^4 + 2/x^3$]),
    ([$x^(-8) - x^6$], [$-8/x^9 - 6x^5$]),
    ([$x^7 - x^(-5)$], [$7x^6 + 5/x^6$]),
    ([$x^(-4) + x^6$], [$-4/x^5 + 6x^5$]),
    ([$x^(-2) - x^2$], [$-2/x^3 - 2x$]),
  ),
)
