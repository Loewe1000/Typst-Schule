// erwartet: Augen circle ok
// erwartet: Augen ring ok
// erwartet: Augen hexagon ok
// erwartet: In keinem Sechseck kommt eine Farbe doppelt vor
// erwartet: In keinem Kreis kommt eine Farbe oder Augenzahl doppelt vor
// nicht: Sechseck kommt eine Farbe oder
// nicht: Kreis kommt eine Farbe doppelt
// Würfelaugen auf dem Schnittbogen: jedes Auge jedes Musters bleibt ab 5 cm
// Kante 0,6 mm, ab 4 cm knapp 0,5 mm von beiden Schnittkanten (±30° zur
// Achse) und liegt ganz in der Spitze, bei Kanten von 3 bis 10 cm. Die Augen
// eines Musters stehen mindestens einen Augendurchmesser auseinander, und die
// Spitzen sind groß (Kreis ≥ 0,22, Sechseck ≥ 0,23 der Kante). Der Kontrollhinweis nennt die Augen
// nur, wenn das Lösungsbild sie zeigt.
#import "/trimino/0.5.0/src/internal.typ": themes, pip-layout, pip-patterns, pip-radius, pip-pitch, pip-across, pip-frame, tip-radius, ring-hole
#import "@schule/trimino:0.5.0": trimino

#for tip in ("circle", "ring", "hexagon") {
  let theme = themes.riso + (tip: tip)
  let f = pip-frame(theme)
  assert(tip-radius(theme) >= if tip == "hexagon" { 0.23 } else { 0.22 }, message: tip + ": Spitze zu klein")
  for unit in (3, 4, 4.2, 5, 6, 8, 10) {
    let pl = pip-layout(theme, unit)
    assert(pl.visible, message: tip + ": Schnittbogen ohne Augen")
    let (g, ga, r, d0) = (pip-pitch * pl.grow, pip-across * pl.grow, pip-radius * pl.grow, pl.d0 * pl.grow)
    for pattern in pip-patterns {
      for (gv, gu) in pattern {
        let (u, v) = (d0 + gu * g, gv * ga)
        // Abstand zur nächsten Schnittkante, in cm
        let clear = (0.5 * u - calc.cos(30deg) * calc.abs(v) - r) * unit
        let need = if unit >= 5 { 0.06 } else if unit >= 4 { 0.048 } else { 0.03 }
        assert(clear >= need, message: tip + " " + str(unit) + " cm: Auge " + str(clear) + " cm an der Schnittkante")
        assert(u + r <= f.far + 0.0001, message: tip + ": Auge ragt aus der Spitze")
        if tip == "ring" { assert(u - r >= ring-hole + 0.004, message: "ring: Auge im Loch") }
        // nicht gequetscht: Augen eines Musters halten Abstand (mind. ihren Radius)
        for (gv2, gu2) in pattern {
          if (gv2, gu2) == (gv, gu) { continue }
          let (du, dv) = ((gu - gu2) * g, (gv - gv2) * ga)
          assert(calc.sqrt(du * du + dv * dv) >= 3 * r - 0.0001, message: tip + ": Augen zu dicht")
        }
      }
    }
  }
  [Augen #tip ok \ ]
}

#set page(paper: "a4", margin: 1.5cm)
#let paare = range(9).map(i => ([#(i + 1)], [#((i + 1) * 10) %]))
#trimino(pairs: paare, cards: false, corners: "wheel", side: 3.5cm, theme: (tip: "hexagon"))
#pagebreak()
#trimino(pairs: paare, cards: false, corners: "wheel")
