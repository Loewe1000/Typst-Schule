// erwartet: ok
// Eine sehr lange Beschriftung zieht die übrigen nicht unter die lesbare
// Größe (9 pt bei 6 cm): kurze Beschriftungen bleiben so groß wie ohne sie.
#import "/trimino/0.5.0/src/internal.typ": themes, fit-sizes, set-cap

#assert.eq(set-cap((1.0, 1.0, 1.0, 0.2), floor: 0.5), 1.05 * 1.0)
#assert.eq(set-cap((1.0, 1.0, 1.0, 0.2)), 0.25)

#context {
  let kurz = (([$1/2$], [50 %], none), ([$1/4$], [25 %], none), ([30 %], [40 %], none))
  let mit = kurz + (([Supercalifragilisticexpialigetisch und noch mehr], [4 %], none),)
  let a = fit-sizes(kurz, themes.riso, true, side: 6)
  let b = fit-sizes(mit, themes.riso, true, side: 6)
  // „50 %“ bleibt (fast) gleich groß; der Ausreißer allein wird klein.
  assert(b.at(0).at(1) >= 0.9 * a.at(0).at(1), message: "kurze Beschriftung schrumpft mit")
  assert(b.at(3).at(0) * 6 < 9pt)
  [ok]
}
