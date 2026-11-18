// ═══════════════════════════════════════════════════════════════════
//  WASM-Anbindung: dieselbe Suche, nur nativ gerechnet
// ═══════════════════════════════════════════════════════════════════
//
//  `optimierer.wasm` ist eine 1:1-Übertragung von `optimizer.typ`
//  (Quelltext unter `rust/`). Gleicher Zufallsgenerator, gleiche
//  Reihenfolge der Tausche – bei gleichem Seed kommt derselbe Plan
//  heraus, nur eben in einem Bruchteil der Zeit. Die Typst-Fassung
//  bleibt damit die überprüfbare Referenz.

#import "internal/check.typ": fail

#let _plugin = plugin("optimierer.wasm")

#let _tiefe-nr = (front: 0, middle: 1, back: 2)
#let _seite-nr = (left: 0, middle: 1, right: 2)

/// Setzt die Aufgabe in den Zahlenstrom um, den das Plugin liest.
/// Die Reihenfolge muss zu `lies()` in `rust/src/lib.rs` passen.
#let encode(problem, geometry, scope, attempts, max-steps, seed, nobody-empty: false, max-attempts: 0) = {
  let g = problem.weights
  let np = geometry.seats.len()
  let ns = problem.student-count

  let tisch-nr = (:)
  for (i, t) in geometry.tables.keys().enumerate() { tisch-nr.insert(t, i) }

  let teile = (str(np), str(ns), str(attempts), str(max-steps), str(seed))
  teile += (if nobody-empty { "1" } else { "0" }, str(max-attempts))

  teile += (g.adjacent, g.table, g.fairness, g.priority, g.rejection, g.constraint, g.position, g.position-avoided).map(str)
  teile += range(3).map(i => str(if i < g.ranks.len() { g.ranks.at(i) } else { g.ranks.last() }))
  teile += range(3).map(i => str(if i < g.tiers.len() { g.tiers.at(i) } else { g.tiers.last() }))
  let wz = g.at("wish-count", default: (1.0,))
  teile += range(3).map(i => str(if i < wz.len() { wz.at(i) } else { wz.last() }))

  for p in geometry.seats {
    teile += (
      str(p.row),
      str(p.column),
      str(tisch-nr.at(p.table)),
      str(_tiefe-nr.at(p.zone.depth)),
      str(_seite-nr.at(p.zone.side)),
    )
  }

  let liste(werte) = (str(werte.len()),) + werte.map(str)
  let bits(zones, tabelle) = {
    let value = 0
    for z in zones { value += calc.pow(2, tabelle.at(z)) }
    str(value)
  }

  for i in range(ns) {
    let s = problem.students.at(i)
    teile += liste(problem.wishes.at(i))
    teile += liste(problem.rejections.at(i))
    teile += liste(problem.apart.at(i))
    teile += liste(problem.together.at(i))
    let pt = s.at("position", default: (:)).at("depth", default: none)
    let ps = s.at("position", default: (:)).at("side", default: none)
    teile.push(if pt == none { "-1" } else { str(_tiefe-nr.at(pt)) })
    teile.push(if ps == none { "-1" } else { str(_seite-nr.at(ps)) })
    teile.push(bits(s.at("position-avoided", default: (:)).at("depth", default: ()), _tiefe-nr))
    teile.push(bits(s.at("position-avoided", default: (:)).at("side", default: ()), _seite-nr))
    teile.push(if problem.priority.at(i) { "1" } else { "0" })
  }

  teile += scope.fixed.map(p => if p == none { "-1" } else { str(p) })
  for reihe in scope.allowed {
    teile += reihe.map(x => if x { "1" } else { "0" })
  }

  // Typsts `str()` setzt bei negativen Zahlen das typografische Minuszeichen
  // U+2212 statt des ASCII-Bindestrichs. Rust liest das nicht als Zahl.
  bytes(teile.join(" ").replace("\u{2212}", "-"))
}

/// Ruft das Plugin auf und liefert Belegung, Punkte und Aufwand.
/// -> dictionary
#let wasm-search(
  problem,
  geometry,
  scope,
  attempts: 8,
  max-steps: 500,
  seed: 42,
  nobody-empty: false,
  max-attempts: 0,
) = {
  let eingabe = encode(
    problem,
    geometry,
    scope,
    attempts,
    max-steps,
    seed,
    nobody-empty: nobody-empty,
    max-attempts: max-attempts,
  )
  let antwort = str(_plugin.optimiere(eingabe))
  let teile = antwort.split(" ").filter(t => t != "")
  if teile.len() < 4 {
    fail("typlace", "sitzordnung", "das WASM-Plugin hat geantwortet: " + antwort + " – mit `engine: \"typst\"` arbeiten und den Fehler melden")
  }

  (
    points: float(teile.at(0)),
    steps: int(teile.at(1)),
    checked: int(teile.at(2)),
    runs: int(teile.at(3)),
    assignment: teile.slice(4).map(t => {
      let i = int(t)
      if i < 0 { none } else { i }
    }),
  )
}
