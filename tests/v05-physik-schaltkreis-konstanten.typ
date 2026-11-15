// physik 0.5.0: Schaltzeichen (source mit current/kind, ammeter) und
// constants/konstante mit den Schlüsseln value, unit, qty.
// erwartet: A
// erwartet: V
// erwartet: M
// erwartet: G
// erwartet: ∼
// erwartet: Lichtgeschwindigkeit: 𝑐 = 2.99792458 × 108 ms
// erwartet: g=9\.81
// erwartet: Elektronenmasse 𝑚𝑒
// erwartet: Schall 343
// erwartet: Eigene 𝑇 1.5 m
#import "@schule/physik:0.5.0": ammeter, constants, generator, konstante, lamp, motor, multimeter, schaltkreis, source, voltmeter
#import "@preview/zap:0.4.0"

#schaltkreis({
  source("q", (0, 0), (0, 3))
  source("w", (2, 0), (2, 3), current: "alternating")
  source("s", (4, 0), (4, 3), kind: "bars", flipped: true)
  source("p", (6, 0), (6, 3), flipped-labels: true)
  lamp("l", (8, 0), (8, 3))
  ammeter("a", (10, 0), (10, 3))
  voltmeter("v", (12, 0), (12, 3))
  motor("m", (0, -4), (0, -1))
  generator("g", (2, -4), (2, -1))
  multimeter("z", (4, -4), (4, -1))
  zap.wire("q.out", "w.out")
})

#constants.c.name: #constants.c.symbol = #constants.c.qty

g=#constants.g.value

#constants.m_e.name #constants.m_e.symbol

Schall #constants.v_sound.qty

#let eigene = konstante("1.5", name: "Eigene", unit: [m], symbol: $T$)
#eigene.name #eigene.symbol #eigene.qty
