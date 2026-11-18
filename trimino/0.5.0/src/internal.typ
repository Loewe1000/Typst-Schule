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

#let vertices(t) = if t.up {
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
        if vertices(t).all(((x, y)) => inside(x, y)) { result.push(t) }
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
      let c = vertices(t)
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
      t => vertices(t).map(((x, y)) => y).fold(k, calc.min) < k - m)
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
    let c = vertices(tri)
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

// Farbpaletten.
#let pastels = (rgb("#fde2e4"), rgb("#e2ece9"), rgb("#dfe7fd"), rgb("#fff1c1"), rgb("#e8dff5"), rgb("#d7f0f7"))
#let bauhaus-colors = (rgb("#e63946"), rgb("#1d5fa8"), rgb("#16877a"))
#let ring-colors = (rgb("#ffd166"), rgb("#ef8354"), rgb("#4ea8de"), rgb("#7bc47f"), rgb("#b388eb"), rgb("#f28482"))

/// Die Themes. Schlüssel eines Theme-Dictionarys:
///   fill       – Füllung: none, Farbe, "ring" (helle Ringfarbe), "tint" (Pastell je Kärtchen),
///                "parity" (zwei Violetttöne im Wechsel) oder "single" (ein Violetton)
///   stroke     – Umriss
///   band       – Farbband an den Kanten: none, Farbe oder "edge" (Farbe je Kante)
///   band-depth – Breite des Bands als Anteil der Kantenlänge
///   pill       – Hinterlegung jeder Beschriftung: none oder Farbe
///   ink        – Schriftfarbe
///   weight     – Schriftstärke der Beschriftungen
///   inner      – Umriss des inneren Dreiecks: none oder Stroke
///   corner     – Farbe der Eckspitzen
#let themes = (
  klar: (fill: none, stroke: 0.8pt + black, band: none, band-depth: 0.15, pill: none,
    ink: black, weight: "regular", inner: none, corner: luma(30%)),
  riso: (fill: "ring", stroke: 1pt + luma(35%), band: none, band-depth: 0.15, pill: white,
    ink: luma(10%), weight: "semibold", inner: none, corner: rgb("#c8553d")),
  leiste: (fill: white, stroke: 1.2pt + rgb("#5b4bb7"), band: rgb("#e8e3fb"), band-depth: 0.15, pill: none,
    ink: rgb("#2d2464"), weight: "semibold", inner: 0.6pt + rgb("#5b4bb7").lighten(40%), corner: rgb("#5b4bb7")),
  bauhaus: (fill: white, stroke: 1.6pt + black, band: "edge", band-depth: 0.16, pill: none,
    ink: white, weight: "semibold", inner: 1pt + black, corner: black),
)

/// Zeichnet ein Kärtchen mit den Ecken `pts` (in cm, gegen den Uhrzeigersinn).
/// `tint` ist die Füllfarbe des Kärtchens, `edge-tints` die Farben je Kante.
#let draw-card(draw, pts, labels, unit, text-size, number: none, theme: themes.klar,
  tint: none, edge-tints: none, corners: false) = {
  let c = (pts.map(p => p.at(0)).sum() / 3, pts.map(p => p.at(1)).sum() / 3)
  let toward(p, target, f) = (p.at(0) + (target.at(0) - p.at(0)) * f, p.at(1) + (target.at(1) - p.at(1)) * f)
  let fill = if theme.fill in ("tint", "ring", "parity", "single") { tint } else { theme.fill }
  let box-h = 0.17 * unit
  let f = theme.band-depth * unit / (unit * 0.2887)
  let inner = pts.map(p => toward(p, c, f))

  draw.line(..pts, close: true, stroke: none, fill: fill)
  if theme.band != none {
    for i in range(3) {
      let j = calc.rem(i + 1, 3)
      let paint = if theme.band == "edge" { edge-tints.at(i) } else { theme.band }
      draw.line(pts.at(i), pts.at(j), inner.at(j), inner.at(i), close: true, stroke: none, fill: paint)
    }
  }
  if theme.inner != none { draw.line(..inner, close: true, stroke: theme.inner) }
  // Eckspitzen: je Ecke ein zweifarbiger Drachen. Wo sechs Kärtchen richtig
  // zusammenliegen, ergeben sie einen Stern.
  if corners {
    for i in range(3) {
      let p = pts.at(i)
      let a = toward(p, pts.at(calc.rem(i + 1, 3)), 0.12)
      let b = toward(p, pts.at(calc.rem(i + 2, 3)), 0.12)
      let m = toward(p, c, 0.32)
      draw.line(p, a, m, close: true, stroke: none, fill: theme.corner)
      draw.line(p, m, b, close: true, stroke: none, fill: theme.corner.lighten(35%))
    }
  }
  draw.line(..pts, close: true, stroke: theme.stroke, fill: none)

  for i in range(3) {
    let label = labels.at(i)
    if label == none { continue }
    let p = pts.at(i)
    let q = pts.at(calc.rem(i + 1, 3))
    let (dx, dy) = (q.at(0) - p.at(0), q.at(1) - p.at(1))
    let length = calc.sqrt(dx * dx + dy * dy)
    // Mittelpunkt des Textfelds: von der Kantenmitte ins Innere versetzt.
    // Das Feld hat feste Höhe, der Text sitzt unten, also an der Kante.
    let shift = 0.04 * unit + box-h / 2
    let mid = ((p.at(0) + q.at(0)) / 2 - dy / length * shift, (p.at(1) + q.at(1)) / 2 + dx / length * shift)
    let body = text(size: text-size, fill: theme.ink, weight: theme.weight,
      top-edge: "bounds", bottom-edge: "bounds", label)
    let shown = if theme.pill != none {
      box(fill: theme.pill, inset: (x: 0.4em, y: 0.32em), radius: 0.8em, stroke: 0.4pt + luma(70%), body)
    } else { body }
    draw.content(mid, anchor: "center", angle: calc.atan2(dx, dy),
      box(width: 0.62 * unit * 1cm, height: box-h * 1cm, align(center + bottom, shown)))
  }
  if number != none {
    draw.content(c, box(fill: white, inset: (x: 0.3em, y: 0.25em), radius: 0.6em, stroke: 0.4pt + luma(70%),
      text(size: text-size * 0.75, fill: luma(30%), weight: "bold", top-edge: "bounds", bottom-edge: "bounds", str(number))))
  }
}

// ---------------------------------------------------------------------------
// Schneideplotter: Passermarken im Silhouette-Format und Schnittlinien
// ---------------------------------------------------------------------------
//
// Die Marken folgen Silhouette Studio (Typ „Cameo, Portrait“): links oben ein
// gefülltes Quadrat, rechts oben und links unten je ein Winkel. Die Winkel
// sind 0,5 mm stark, wie es der Plotter bei der Suche erwartet (TB53,10);
// dünnere Linien fand er unter Laminierfolie nicht zuverlässig. Der Abstand der
// Marken vom Blattrand ist `mark-inset`; um die Marken herum bleibt ein
// Schutzraum frei, deshalb setzt der Schnittbogen dann den Rand `mark-margin`.

#let mark-inset = 10mm
#let mark-square = 5mm
#let mark-line = 20mm
#let mark-thickness = 0.5mm
#let mark-margin = 30mm
// Prüfkreuz: Mitte so weit von der rechten unteren Blattecke. Der Plotter
// fährt nach der Markensuche dorthin; steht das Messer genau darüber, stimmt
// die Lage.
#let check-inset = 20mm
#let check-size = 8mm

/// Lage der Marken in mm, wie sie der Plotter für die Suche braucht.
#let mark-geometry(width, height) = {
  let mm(l) = calc.round(l / 1mm, digits: 3)
  (
    style: "silhouette",
    left: mm(mark-inset),
    top: mm(mark-inset),
    width: mm(width - 2 * mark-inset),
    length: mm(height - 2 * mark-inset),
    square: mm(mark-square),
    line: mm(mark-line),
    thickness: mm(mark-thickness),
  )
}

/// Mitte des Prüfkreuzes in mm, gemessen von der Marke links oben.
#let check-point(width, height) = {
  let mm(l) = calc.round(l / 1mm, digits: 3)
  (mm(width - check-inset - mark-inset), mm(height - check-inset - mark-inset))
}

/// Zeichnet die Marken für eine Seite der Größe `width` × `height`.
#let mark-drawing(width, height) = {
  let ink = black
  let s = mark-thickness
  let right = width - mark-inset
  let bottom = height - mark-inset
  // Linien als gefüllte Rechtecke: so sitzen die Kanten genau.
  let bar(x, y, w, h) = place(top + left, dx: x, dy: y, rect(width: w, height: h, fill: ink, stroke: none))
  bar(mark-inset, mark-inset, mark-square, mark-square)
  // rechts oben: Arme nach links und nach unten
  bar(right - mark-line, mark-inset, mark-line, s)
  bar(right - s, mark-inset, s, mark-line)
  // links unten: Arme nach rechts und nach oben
  bar(mark-inset, bottom - s, mark-line, s)
  bar(mark-inset, bottom - mark-line, s, mark-line)
  // Prüfkreuz mit Ring
  let (cx, cy) = (width - check-inset, height - check-inset)
  let t = 0.2mm
  bar(cx - check-size / 2, cy - t / 2, check-size, t)
  bar(cx - t / 2, cy - check-size / 2, t, check-size)
  place(top + left, dx: cx - check-size * 0.3, dy: cy - check-size * 0.3,
    circle(radius: check-size * 0.3, stroke: t + ink, fill: none))
}

/// Kanten aller Kärtchen, gemeinsame Kanten nur einmal. `cards` enthält je
/// Kärtchen drei Ecken (in cm). Liefert Strecken `((x1, y1), (x2, y2))`.
#let cut-segments(cards) = {
  let key(p) = str(calc.round(p.at(0), digits: 3)) + "," + str(calc.round(p.at(1), digits: 3))
  let seen = (:)
  let result = ()
  for pts in cards {
    for i in range(3) {
      let p = pts.at(i)
      let q = pts.at(calc.rem(i + 1, 3))
      let (k1, k2) = (key(p), key(q))
      let k = if k1 < k2 { k1 + ";" + k2 } else { k2 + ";" + k1 }
      if k not in seen {
        seen.insert(k, true)
        result.push((p, q))
      }
    }
  }
  result
}

/// SVG-Schnittvorlage eines `cut-data`-Eintrags: Blatt in mm, Marken
/// schwarz, Schnittlinien rot.
#let cut-svg(d) = {
  let (w, h) = d.page-size
  let m = d.marks
  let n(x) = str(calc.round(x, digits: 2))
  let rect(x, y, rw, rh) = "<rect x=\"" + n(x) + "\" y=\"" + n(y) + "\" width=\"" + n(rw) + "\" height=\"" + n(rh) + "\" fill=\"#000000\"/>"
  let (r, b, s, l) = (m.left + m.width, m.top + m.length, m.thickness, m.line)
  let marks = (
    rect(m.left, m.top, m.square, m.square),
    rect(r - l, m.top, l, s), rect(r - s, m.top, s, l),
    rect(m.left, b - s, l, s), rect(m.left, b - l, s, l),
  ).join("\n")
  let check = if "check" in d {
    let (cx, cy) = (d.check.at(0) + m.left, d.check.at(1) + m.top)
    "\n" + rect(cx - 4, cy - 0.1, 8, 0.2) + "\n" + rect(cx - 0.1, cy - 4, 0.2, 8)
      + "\n<circle cx=\"" + n(cx) + "\" cy=\"" + n(cy) + "\" r=\"2.4\" fill=\"none\" stroke=\"#000000\" stroke-width=\"0.2\"/>"
  } else { "" }
  // Je Kärtchen ein geschlossener Umriss; gemeinsame Kanten entdoppelt der
  // Leser. Ohne Umrisse die einzelnen Strecken.
  let outlines = if "pieces" in d { d.pieces.map(p => p + (p.first(),)) } else { d.paths }
  let lines = outlines.map(p => "<polyline points=\"" + p.map(((x, y)) => n(x + m.left) + "," + n(y + m.top)).join(" ")
    + "\" fill=\"none\" stroke=\"#ff0000\" stroke-width=\"0.25\"/>").join("\n")
  ("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + n(w) + "mm\" height=\"" + n(h) + "mm\" viewBox=\"0 0 "
    + n(w) + " " + n(h) + "\">\n<g id=\"regmarks\">\n" + marks + check + "\n</g>\n<g id=\"cut\">\n" + lines + "\n</g>\n</svg>\n")
}

// ---------------------------------------------------------------------------
// Rückseite
// ---------------------------------------------------------------------------

/// Schriften für den Schriftzug „Trimino“, die erste vorhandene gilt.
#let back-fonts = ("Futura", "Avenir Next", "Montserrat", "Gill Sans", "DejaVu Sans")

/// Zugabe der Rückseitenfläche um die Kärtchen, in cm. Ein versetzter
/// Duplexdruck lässt so keine weißen Ränder an den Kärtchen.
#let back-bleed = 0.4

/// Mindestabstand der Rückseiten-Etiketten zu den Schnittkanten, in cm.
#let back-safe = 0.25

// Umriss einer Reihe (konvex, gegen den Uhrzeigersinn) um `d` nach außen
// versetzt: jede Kante parallel verschieben, Nachbarkanten schneiden.
#let offset-outline(pts, d) = {
  let n = pts.len()
  let lines = range(n).map(i => {
    let (p, q) = (pts.at(i), pts.at(calc.rem(i + 1, n)))
    let (dx, dy) = (q.at(0) - p.at(0), q.at(1) - p.at(1))
    let l = calc.sqrt(dx * dx + dy * dy)
    let (nx, ny) = (dy / l * d, -dx / l * d) // nach außen (rechts der Kante)
    ((p.at(0) + nx, p.at(1) + ny), (dx, dy))
  })
  range(n).map(i => {
    let ((p1, d1), (p2, d2)) = (lines.at(calc.rem(i + n - 1, n)), lines.at(i))
    let den = d1.at(0) * d2.at(1) - d1.at(1) * d2.at(0)
    let t = ((p2.at(0) - p1.at(0)) * d2.at(1) - (p2.at(1) - p1.at(1)) * d2.at(0)) / den
    (p1.at(0) + t * d1.at(0), p1.at(1) + t * d1.at(1))
  })
}

#let inside-convex(p, pts) = {
  let n = pts.len()
  range(n).all(i => {
    let (a, b) = (pts.at(i), pts.at(calc.rem(i + 1, n)))
    (b.at(0) - a.at(0)) * (p.at(1) - a.at(1)) - (b.at(1) - a.at(1)) * (p.at(0) - a.at(0)) >= 0
  })
}

/// Rückseitenfläche einer Reihe: Grundfarbe mit kleinen, verstreuten
/// Dreiecken, nur um die Kärtchen herum (plus `back-bleed`). Das Muster hat
/// kein Raster; ein versetzter Duplexdruck fällt darin nicht auf.
#let draw-back-ground(draw, cards, seed, theme) = {
  let ground = if theme.fill == "ring" { rgb("#fbf3ea") }
    else if type(theme.corner) == color { theme.corner.lighten(90%) } else { luma(96%) }
  let colors = if theme.fill == "ring" { ring-colors.map(c => c.lighten(55%)) }
    else if theme.band == "edge" { bauhaus-colors.map(c => c.lighten(45%)) }
    else { (theme.ink.lighten(80%),) }
  // Umriss der Reihe: unten und oben je die äußersten Ecken
  let all = cards.flatten().chunks(2)
  let y0 = calc.min(..all.map(p => p.at(1)))
  let y1 = calc.max(..all.map(p => p.at(1)))
  let low = all.filter(p => calc.abs(p.at(1) - y0) < 0.001).map(p => p.at(0))
  let high = all.filter(p => calc.abs(p.at(1) - y1) < 0.001).map(p => p.at(0))
  let outline = offset-outline(((calc.min(..low), y0), (calc.max(..low), y0),
    (calc.max(..high), y1), (calc.min(..high), y1)), back-bleed)
  draw.line(..outline, close: true, stroke: none, fill: ground)
  let xs = outline.map(p => p.at(0))
  let (x-lo, x-hi) = (calc.min(..xs), calc.max(..xs))
  let (y-lo, y-hi) = (y0 - back-bleed, y1 + back-bleed)
  let r = seed * 48271 + int(y0 * 1000)
  let n = int((x-hi - x-lo) * (y-hi - y-lo) * 0.9)
  for k in range(n) {
    r = next-random(r)
    let x = x-lo + calc.rem(calc.quo(r, 7), 10000) / 10000 * (x-hi - x-lo)
    r = next-random(r)
    let y = y-lo + calc.rem(calc.quo(r, 7), 10000) / 10000 * (y-hi - y-lo)
    r = next-random(r)
    let size = 0.16 + calc.rem(calc.quo(r, 7), 100) / 100 * 0.22
    r = next-random(r)
    let turn = calc.rem(calc.quo(r, 7), 360) * 1deg
    r = next-random(r)
    let paint = colors.at(calc.rem(calc.quo(r, 65536), colors.len()))
    let tri = range(3).map(i => (x + size * calc.cos(turn + i * 120deg), y + size * calc.sin(turn + i * 120deg)))
    if tri.all(p => inside-convex(p, outline)) {
      draw.line(..tri, close: true, stroke: none, fill: paint)
    }
  }
}

/// Beschriftet die Rückseiten eines Bogens: je Kärtchen ein Etikett mit
/// „TRIMINO“ und dem Titel, mittig und mit Abstand zu den Kanten. `cards`:
/// Ecken je Kärtchen (in cm, schon gespiegelt).
/// `numbers`: je Kärtchen die Nummer auf der Rückseite (etwa „A7“), oder
/// `none`.
#let draw-back(draw, cards, unit, text-size, theme, title, custom: none, numbers: none) = {
  let palette = if theme.fill == "ring" { ring-colors.map(c => c.darken(22%)) }
    else if theme.band == "edge" { bauhaus-colors }
    else { (theme.ink,) }
  let word = "TRIMINO".clusters().enumerate().map(((i, ch)) =>
    text(fill: palette.at(calc.rem(i, palette.len())), ch)).join()
  // Unter dem Schriftzug: eigener Text oder der Titel
  let below = if custom != none { custom } else { title }
  let label(number) = box(fill: white, inset: (x: 0.35em, y: 0.3em), radius: 0.5em, stack(spacing: 0.3em,
    align(center, text(font: back-fonts, weight: "bold", size: text-size * 1.3, tracking: 0.05em, word)),
    if below != none {
      align(center, text(font: back-fonts, size: text-size * 0.8, fill: theme.ink.lighten(15%),
        hyphenate: false, below))
    },
    if number != none {
      align(center, text(font: back-fonts, size: text-size * 0.62, fill: luma(55%), str(number)))
    },
  ))
  for (k, pts) in cards.enumerate() {
    let c = (pts.map(p => p.at(0)).sum() / 3, pts.map(p => p.at(1)).sum() / 3)
    // Das Etikett so groß wie möglich ins Dreieck setzen, mit `back-safe`
    // Abstand zu allen Kanten. Es sitzt an der breiten Seite (bei Spitze
    // oben unten, bei Spitze unten oben). Für ein Rechteck w × h, das bei
    // Abstand m an der breiten Kante beginnt, muss an seinem schmalen Ende
    // gelten: f·w ≤ s·(1 − (g + f·h)/H) − 2m/sin 60°, H = Höhe des Dreiecks,
    // g = Abstand zur breiten Kante.
    // Daraus folgt der größte Faktor f.
    let up = pts.filter(p => p.at(1) < c.at(1)).len() == 2
    let H = unit * height
    let m = back-safe
    let ys = pts.map(p => p.at(1))
    let wide = if up { calc.min(..ys) } else { calc.max(..ys) }
    let shown = label(if numbers == none { none } else { numbers.at(k) })
    draw.content((c.at(0), wide), anchor: if up { "south" } else { "north" }, context {
      let size = measure(shown)
      let (w, h) = (size.width / 1cm, size.height / 1cm)
      // Abstand zur breiten Kante: m und etwas mehr, damit das Etikett zur
      // Mitte rückt; in die Rechnung geht der ganze Abstand ein.
      let gap = m + 0.05 * unit
      let f = (unit * (1 - gap / H) - 2 * m / calc.sin(60deg)) / (w + unit * h / H)
      pad(top: if up { 0cm } else { gap * 1cm }, bottom: if up { gap * 1cm } else { 0cm },
        scale(f * 100%, reflow: true, shown))
    })
  }
}

/// Breite und Höhe des Satzspiegels der aktuellen Seite (nur im `context`).
/// Ersetzt `layout(…)`, in dem keine Seitenumbrüche erlaubt sind.
#let content-area() = {
  let (w, h) = (page.width, page.height)
  let m = page.margin
  let standard = 2.5 / 21 * calc.min(w, h)
  let side(key, axis) = {
    if m == auto { return standard }
    if type(m) != dictionary { return m.length + m.ratio * w }
    let v = m.at(key, default: m.at(axis, default: m.at("rest", default: auto)))
    if key in ("left", "right") and v == auto {
      v = m.at(if key == "left" { "inside" } else { "outside" }, default: auto)
    }
    if v == auto { standard } else { v.length + v.ratio * w }
  }
  (
    width: w - side("left", "x") - side("right", "x"),
    height: h - side("top", "y") - side("bottom", "y"),
  )
}
