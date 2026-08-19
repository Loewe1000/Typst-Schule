// ═══════════════════════════════════════════════════════════════════
//  WASM-Anbindung: dieselbe Suche, nur nativ gerechnet
// ═══════════════════════════════════════════════════════════════════
//
//  `optimierer.wasm` ist eine 1:1-Übertragung von `optimierer.typ`
//  (Quelltext unter `rust/`). Gleicher Zufallsgenerator, gleiche
//  Reihenfolge der Tausche – bei gleichem Seed kommt derselbe Plan
//  heraus, nur eben in einem Bruchteil der Zeit. Die Typst-Fassung
//  bleibt damit die überprüfbare Referenz.

#let _plugin = plugin("optimierer.wasm")

#let _tiefe-nr = (vorne: 0, mitte: 1, hinten: 2)
#let _seite-nr = (links: 0, mitte: 1, rechts: 2)

/// Setzt die Aufgabe in den Zahlenstrom um, den das Plugin liest.
/// Die Reihenfolge muss zu `lies()` in `rust/src/lib.rs` passen.
#let kodieren(kontext, geo, spielraum, versuche, max-schritte, seed) = {
  let g = kontext.gewichte
  let np = geo.plaetze.len()
  let ns = kontext.anzahl-schueler

  let tisch-nr = (:)
  for (i, t) in geo.tische.keys().enumerate() { tisch-nr.insert(t, i) }

  let teile = (str(np), str(ns), str(versuche), str(max-schritte), str(seed))

  teile += (g.direkt, g.tisch, g.fairness, g.ablehnung, g.hart, g.position, g.position-meidet).map(str)
  teile += range(3).map(i => str(if i < g.raenge.len() { g.raenge.at(i) } else { g.raenge.last() }))
  teile += range(3).map(i => str(if i < g.stufen.len() { g.stufen.at(i) } else { g.stufen.last() }))
  let wz = g.at("wunschzahl", default: (1.0,))
  teile += range(3).map(i => str(if i < wz.len() { wz.at(i) } else { wz.last() }))

  for p in geo.plaetze {
    teile += (
      str(p.zeile),
      str(p.spalte),
      str(tisch-nr.at(p.tisch)),
      str(_tiefe-nr.at(p.zone.tiefe)),
      str(_seite-nr.at(p.zone.seite)),
    )
  }

  let liste(werte) = (str(werte.len()),) + werte.map(str)
  let bits(zonen, tabelle) = {
    let wert = 0
    for z in zonen { wert += calc.pow(2, tabelle.at(z)) }
    str(wert)
  }

  for i in range(ns) {
    let s = kontext.schueler.at(i)
    teile += liste(kontext.wuensche.at(i))
    teile += liste(kontext.ablehnungen.at(i))
    teile += liste(kontext.getrennt.at(i))
    teile += liste(kontext.zusammen.at(i))
    let pt = s.at("position", default: (:)).at("tiefe", default: none)
    let ps = s.at("position", default: (:)).at("seite", default: none)
    teile.push(if pt == none { "-1" } else { str(_tiefe-nr.at(pt)) })
    teile.push(if ps == none { "-1" } else { str(_seite-nr.at(ps)) })
    teile.push(bits(s.at("position-meidet", default: (:)).at("tiefe", default: ()), _tiefe-nr))
    teile.push(bits(s.at("position-meidet", default: (:)).at("seite", default: ()), _seite-nr))
  }

  teile += spielraum.fest.map(p => if p == none { "-1" } else { str(p) })
  for reihe in spielraum.erlaubt {
    teile += reihe.map(x => if x { "1" } else { "0" })
  }

  // Typsts `str()` setzt bei negativen Zahlen das typografische Minuszeichen
  // U+2212 statt des ASCII-Bindestrichs. Rust liest das nicht als Zahl.
  bytes(teile.join(" ").replace("\u{2212}", "-"))
}

/// Ruft das Plugin auf und liefert Belegung, Punkte und Aufwand.
/// -> dictionary
#let wasm-suchen(kontext, geo, spielraum, versuche: 8, max-schritte: 500, seed: 42) = {
  let antwort = str(_plugin.optimiere(kodieren(kontext, geo, spielraum, versuche, max-schritte, seed)))
  let teile = antwort.split(" ").filter(t => t != "")
  if teile.len() < 3 { panic("typlace: Das WASM-Plugin hat geantwortet: " + antwort) }

  (
    punkte: float(teile.at(0)),
    schritte: int(teile.at(1)),
    geprueft: int(teile.at(2)),
    zuordnung: teile.slice(3).map(t => {
      let i = int(t)
      if i < 0 { none } else { i }
    }),
  )
}
