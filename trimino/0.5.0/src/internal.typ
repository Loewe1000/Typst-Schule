// Interne Helfer von trimino. Keine zugesicherte Schnittstelle:
// Namen und Gestalt dürfen sich in jeder Version ändern.
//
// Geometrie: Alle Kärtchen liegen auf einem Dreiecksgitter. Ein Gitterpunkt
// (a, b) liegt bei x = a + b/2, y = b · √3/2 (Kantenlänge 1). Ein Dreieck ist
// (a: …, b: …, up: true/false):
//   up    – Ecken (a, b), (a+1, b), (a, b+1)
//   down  – Ecken (a+1, b), (a+1, b+1), (a, b+1)
// Beide Eckenlisten laufen gegen den Uhrzeigersinn. Kante i geht von Ecke i
// zu Ecke i+1; das Innere liegt links von ihr. Darauf beruht, dass jede
// Beschriftung vom Kärtcheninneren aus aufrecht steht.

#let height = calc.sqrt(3) / 2

/// Die Formen in der Reihenfolge, in der `auto` sie probiert.
#let shape-names = ("triangle", "hexagon", "star", "rhombus", "trapezoid", "strip")

// ---------------------------------------------------------------------------
// Zufall: lineare Kongruenz, damit jede Seed-Zahl dasselbe Spiel liefert.
// ---------------------------------------------------------------------------

#let next-random(state) = calc.rem(state * 1103515245 + 12345, 2147483648)

/// Mischt `items` (Fisher-Yates). Liefert (gemischt, neuer Zustand).
#let shuffle(items, state) = {
  let result = items
  let s = state
  for i in range(result.len() - 1, 0, step: -1) {
    s = next-random(s)
    let j = calc.rem(calc.quo(s, 65536), i + 1)
    let tmp = result.at(i)
    result.at(i) = result.at(j)
    result.at(j) = tmp
  }
  (result, s)
}

// ---------------------------------------------------------------------------
// Formen
// ---------------------------------------------------------------------------

#let corners(t) = if t.up {
  ((t.a, t.b), (t.a + 1, t.b), (t.a, t.b + 1))
} else {
  ((t.a + 1, t.b), (t.a + 1, t.b + 1), (t.a, t.b + 1))
}

#let both(a, b) = ((a: a, b: b, up: true), (a: a, b: b, up: false))

// Alle Dreiecke im Bereich, deren drei Ecken `inside` erfüllen.
#let select(low, high, inside) = {
  let result = ()
  for b in range(low, high + 1) {
    for a in range(low, high + 1) {
      for t in both(a, b) {
        if corners(t).all(((x, y)) => inside(x, y)) { result.push(t) }
      }
    }
  }
  result
}

#let hex-distance(x, y) = calc.max(calc.abs(x), calc.abs(y), calc.abs(x + y))

/// Die Dreiecke einer Form. `size` ist eine Zahl, bei `rhombus` und
/// `trapezoid` ein Paar.
#let shape-triangles(name, size) = {
  if name == "triangle" {
    select(0, size, (x, y) => x >= 0 and y >= 0 and x + y <= size)
  } else if name == "hexagon" {
    select(-size, size, (x, y) => hex-distance(x, y) <= size)
  } else if name == "star" {
    let k = size
    let result = ()
    for t in select(-k, 3 * k, (x, y) => true) {
      let c = corners(t)
      let upward = c.all(((x, y)) => x >= 0 and y >= 0 and x + y <= 3 * k)
      let downward = c.all(((x, y)) => x <= 2 * k and y <= 2 * k and x + y >= k)
      if upward or downward { result.push(t) }
    }
    result
  } else if name == "rhombus" {
    let (m, n) = size
    let result = ()
    for b in range(n) { for a in range(m) { result += both(a, b) } }
    result
  } else if name == "trapezoid" {
    let (k, m) = size
    select(0, k, (x, y) => x >= 0 and y >= 0 and x + y <= k).filter(
      t => corners(t).map(((x, y)) => y).fold(k, calc.min) < k - m)
  } else if name == "strip" {
    range(size).map(i => (a: calc.quo(i, 2), b: 0, up: calc.even(i)))
  }
}

#let edge-key(p, q) = {
  let before = p.at(0) < q.at(0) or (p.at(0) == q.at(0) and p.at(1) < q.at(1))
  let (first, second) = if before { (p, q) } else { (q, p) }
  first.map(str).join(",") + ";" + second.map(str).join(",")
}

/// Kanten einer Dreiecksliste: (inner: ((t, i, t2, i2), …), outer: ((t, i), …)).
#let edges(triangles) = {
  let seen = (:)
  let order = ()
  for (t, tri) in triangles.enumerate() {
    let c = corners(tri)
    for i in range(3) {
      let key = edge-key(c.at(i), c.at(calc.rem(i + 1, 3)))
      if key in seen { seen.at(key).push((t, i)) } else {
        seen.insert(key, ((t, i),))
        order.push(key)
      }
    }
  }
  let inner = ()
  let outer = ()
  for key in order {
    let sides = seen.at(key)
    if sides.len() == 2 { inner.push(sides.at(0) + sides.at(1)) } else { outer.push(sides.at(0)) }
  }
  (inner: inner, outer: outer)
}

/// Alle Formen, die das Paket anbietet, mit Kärtchen- und Paarzahl.
#let catalogue() = {
  let entries = ()
  for k in range(2, 8) { entries.push(("triangle", k)) }
  for k in range(1, 4) { entries.push(("hexagon", k)) }
  for k in range(1, 3) { entries.push(("star", k)) }
  for m in range(2, 7) { for n in range(2, m + 1) { entries.push(("rhombus", (m, n))) } }
  for k in range(3, 8) { for m in range(1, k - 1) { entries.push(("trapezoid", (k, m))) } }
  for n in range(2, 61) { entries.push(("strip", n)) }
  entries.map(((name, size)) => {
    let tris = shape-triangles(name, size)
    (shape: name, shape-size: size, cards: tris.len(), pairs: edges(tris).inner.len())
  })
}

// ---------------------------------------------------------------------------
// Belegung
// ---------------------------------------------------------------------------

/// Verteilt Paare und Ablenker auf die Kanten. Liefert je Dreieck ein Array
/// aus drei Beschriftungen (`none` für leer) und den Zufallszustand.
#let fill-edges(triangles, pairs, distractors, state) = {
  let e = edges(triangles)
  let labels = triangles.map(_ => (none, none, none))
  let (order, s) = shuffle(range(e.inner.len()), state)
  for (k, pair) in pairs.enumerate() {
    let (t1, i1, t2, i2) = e.inner.at(order.at(k))
    s = next-random(s)
    let swap = calc.rem(calc.quo(s, 65536), 2) == 1
    let (task, answer) = if swap { (pair.at(1), pair.at(0)) } else { (pair.at(0), pair.at(1)) }
    labels.at(t1).at(i1) = task
    labels.at(t2).at(i2) = answer
  }
  let (outer, s2) = shuffle(e.outer, s)
  for (k, d) in distractors.enumerate() {
    if k >= outer.len() { break }
    let (t, i) = outer.at(k)
    labels.at(t).at(i) = d
  }
  (labels, s2)
}

// ---------------------------------------------------------------------------
// Zeichnen
// ---------------------------------------------------------------------------

#let point((x, y), unit) = ((x + y / 2) * unit, y * height * unit)

/// Zeichnet ein Kärtchen mit den Ecken `pts` (in cm, gegen den Uhrzeigersinn).
#let draw-card(draw, pts, labels, unit, text-size, number: none, stroke: 0.8pt) = {
  draw.line(..pts, close: true, stroke: stroke)
  for i in range(3) {
    let label = labels.at(i)
    if label == none { continue }
    let p = pts.at(i)
    let q = pts.at(calc.rem(i + 1, 3))
    let (dx, dy) = (q.at(0) - p.at(0), q.at(1) - p.at(1))
    let length = calc.sqrt(dx * dx + dy * dy)
    // Mittelpunkt des Textfelds: von der Kantenmitte ins Innere versetzt.
    // Das Feld hat feste Höhe, der Text sitzt unten, also an der Kante.
    let box-h = 0.17 * unit
    let shift = 0.04 * unit + box-h / 2
    let mid = ((p.at(0) + q.at(0)) / 2 - dy / length * shift, (p.at(1) + q.at(1)) / 2 + dx / length * shift)
    draw.content(mid, anchor: "center", angle: calc.atan2(dx, dy),
      box(width: 0.6 * unit * 1cm, height: box-h * 1cm,
        align(center + bottom, text(size: text-size, top-edge: "bounds", bottom-edge: "bounds", label))))
  }
  if number != none {
    let cx = pts.map(p => p.at(0)).sum() / 3
    let cy = pts.map(p => p.at(1)).sum() / 3
    draw.content((cx, cy), text(size: text-size * 0.8, fill: luma(55%), str(number)))
  }
}
