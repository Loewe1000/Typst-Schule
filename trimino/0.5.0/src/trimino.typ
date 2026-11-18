// trimino 0.5.0 – öffentliche Funktionen.
#import "@preview/cetz:0.4.2" as cetz
#import "internal/check.typ": fail, check-named, check-value, check-type, check-positional
#import "internal.typ": catalogue, corners, draw-card, edges, fill-edges, height, next-random, point, shape-names, shape-triangles, shuffle

#let pkg = "trimino"

#let describe(entry) = {
  let size = entry.shape-size
  let shown = if type(size) == array { "(" + size.map(str).join(", ") + ")" } else { str(size) }
  "`shape: \"" + entry.shape + "\", shape-size: " + shown + "`"
}

/// Listet die Formen, die zu einer Zahl von Paaren passen.
///
/// Jede innere Kante eines Trimino trägt genau ein Paar. Eine Form passt,
/// wenn sie so viele innere Kanten hat, wie es Paare gibt.
///
/// ```typ
/// #trimino-shapes(12)
/// // ((shape: "star", shape-size: 1, cards: 12, pairs: 12), …)
/// ```
///
/// - count (int, none): Zahl der Paare; `none` liefert alle Formen
/// -> array
#let trimino-shapes(count) = {
  check-type(pkg, "trimino-shapes", "count", count, (int, none), example: "12")
  let all = catalogue()
  if count == none { all } else { all.filter(e => e.pairs == count) }
}

/// Setzt ein Trimino: Lösungsbild und Schnittbogen mit gemischten,
/// gedrehten Kärtchen.
///
/// Jedes Paar aus Aufgabe und Lösung liegt auf einer inneren Kante: die
/// Aufgabe auf dem einen Kärtchen, die Lösung auf dem Nachbarkärtchen. Die
/// Form wählt das Paket nach der Zahl der Paare (Dreieck, Sechseck, Stern,
/// Raute, Trapez, als letzte Möglichkeit ein Streifen).
///
/// ```typ
/// #trimino(title: [Brüche], pairs: (
///   ([$1/2$], [50 %]), ([$1/4$], [25 %]), ([$3/4$], [75 %]),
/// ))
/// ```
///
/// - pairs (array): Paare `(Aufgabe, Lösung)`, jeweils Inhalt oder Text
/// - shape (str, auto): `"triangle"`, `"hexagon"`, `"star"`, `"rhombus"`, `"trapezoid"`, `"strip"`; `auto` wählt nach der Zahl der Paare
/// - shape-size (int, array, auto): Größe der Form: Kärtchen je Seite, bei `"rhombus"` `(Breite, Höhe)`, bei `"trapezoid"` `(Seite, abgeschnittene Spitze)`, bei `"strip"` die Zahl der Kärtchen
/// - distractors (array): Ablenker für die Außenkanten, damit Randkärtchen nicht auffallen
/// - seed (int): Startwert für das Mischen; gleiche Zahl, gleiches Spiel
/// - side (length): Kantenlänge eines Kärtchens auf dem Schnittbogen
/// - title (content, str, none): Titel über Lösung und Schnittbogen
/// - solution (bool): Lösungsbild setzen
/// - cards (bool): Schnittbogen setzen
/// - number (bool): Kärtchennummer in der Mitte, auf Lösung und Schnittbogen gleich
/// - ..deprecated (arguments): fängt unbekannte Namen ab, nimmt nichts an
/// -> content
#let trimino(
  pairs: (),
  shape: auto,
  shape-size: auto,
  distractors: (),
  seed: 1,
  side: 6cm,
  title: none,
  solution: true,
  cards: true,
  number: true,
  ..deprecated,
) = {
  let fn = "trimino"
  check-positional(pkg, fn, deprecated, hint: "die Paare stehen in `pairs: ((Aufgabe, Lösung), …)`")
  check-named(pkg, fn, deprecated, allowed: ("pairs", "shape", "shape-size", "distractors", "seed",
    "side", "title", "solution", "cards", "number"))
  check-type(pkg, fn, "pairs", pairs, array, example: "(([2 + 3], [5]), ([4 · 2], [8]))")
  for (k, p) in pairs.enumerate() {
    if type(p) != array or p.len() != 2 {
      fail(pkg, fn, "Paar " + str(k + 1) + " hat nicht die Form `(Aufgabe, Lösung)` – jedes Paar als Array aus zwei Einträgen schreiben")
    }
  }
  check-value(pkg, fn, "shape", shape, (auto,) + shape-names)
  check-type(pkg, fn, "shape-size", shape-size, (int, array, auto), example: "3")
  check-type(pkg, fn, "distractors", distractors, array, example: "([12], [0,4])")
  check-type(pkg, fn, "seed", seed, int, example: "7")
  check-type(pkg, fn, "side", side, length, example: "6cm")
  check-type(pkg, fn, "title", title, (content, str, none))
  check-type(pkg, fn, "solution", solution, bool)
  check-type(pkg, fn, "cards", cards, bool)
  check-type(pkg, fn, "number", number, bool)
  if pairs.len() == 0 { fail(pkg, fn, "keine Paare – mindestens ein Paar in `pairs` angeben") }
  if shape == auto and shape-size != auto {
    fail(pkg, fn, "`shape-size` ohne `shape` – auch die Form nennen, zum Beispiel `shape: \"triangle\"`")
  }

  // Form bestimmen
  let n = pairs.len()
  let entry = if shape == auto {
    let matches = catalogue().filter(e => e.pairs == n)
    matches.first()
  } else if shape-size == auto {
    let matches = catalogue().filter(e => e.shape == shape and e.pairs == n)
    if matches.len() == 0 {
      let counts = catalogue().filter(e => e.shape == shape).map(e => str(e.pairs)).dedup()
      fail(pkg, fn, "die Form `" + shape + "` gibt es nicht für " + str(n) + " Paare – möglich sind "
        + counts.join(", ") + " Paare, oder `shape: auto`")
    }
    matches.first()
  } else {
    let pair-size = shape in ("rhombus", "trapezoid")
    if pair-size != (type(shape-size) == array and shape-size.len() == 2) {
      fail(pkg, fn, "`shape-size` passt nicht zu `" + shape + "` – "
        + if pair-size { "ein Paar angeben, zum Beispiel `(3, 2)`" } else { "eine Zahl angeben, zum Beispiel `3`" })
    }
    let tris = shape-triangles(shape, shape-size)
    (shape: shape, shape-size: shape-size, cards: tris.len(), pairs: edges(tris).inner.len())
  }
  if entry.pairs != n {
    fail(pkg, fn, describe(entry) + " hat " + str(entry.pairs) + " innere Kanten, es gibt aber " + str(n)
      + " Paare – Paare ergänzen oder streichen, oder `shape: auto`")
  }
  let triangles = shape-triangles(entry.shape, entry.shape-size)
  let (labels, state) = fill-edges(triangles, pairs, distractors, seed)

  let side-cm = side / 1cm
  let base-size = 9pt * side-cm / 6
  let head(caption) = {
    text(size: 13pt, weight: "bold", caption)
    if title != none { text(size: 13pt)[ · #title] }
    v(4pt)
  }

  // Lösungsbild
  if solution {
    head[Trimino: Lösung]
    layout(available => {
      let pts = triangles.map(t => corners(t).map(c => point(c, 1)))
      let xs = pts.flatten().chunks(2).map(p => p.at(0))
      let ys = pts.flatten().chunks(2).map(p => p.at(1))
      let (w, h) = (calc.max(..xs) - calc.min(..xs), calc.max(..ys) - calc.min(..ys))
      let room-h = available.height - 1cm
      let unit = calc.min(side-cm, available.width / 1cm / w, room-h / 1cm / h)
      align(center, cetz.canvas(length: 1cm, {
        import cetz.draw
        for (t, tri) in triangles.enumerate() {
          let p = corners(tri).map(c => point(c, unit))
          draw-card(draw, p, labels.at(t), unit, base-size * unit / side-cm,
            number: if number { t + 1 } else { none })
        }
      }))
    })
  }

  // Schnittbogen
  if cards {
    if solution { pagebreak() }
    let (order, s) = shuffle(range(triangles.len()), state)
    let pieces = ()
    for t in order {
      s = next-random(s)
      pieces.push((t: t, turn: calc.rem(calc.quo(s, 65536), 3)))
    }
    layout(available => {
      let per-row = calc.max(1, calc.floor(2 * available.width / side - 1))
      let row-gap = 0.4
      let rows-per-page = calc.max(1, calc.floor((available.height - 1.2cm) / 1cm / (side-cm * height + row-gap)))
      let pages = pieces.chunks(per-row * rows-per-page)
      for (pi, page-pieces) in pages.enumerate() {
        if pi > 0 { pagebreak() }
        head[Trimino zum Ausschneiden]
        cetz.canvas(length: 1cm, {
          import cetz.draw
          for (r, row) in page-pieces.chunks(per-row).enumerate() {
            let y0 = -r * (side-cm * height + row-gap)
            for (i, piece) in row.enumerate() {
              let slot = (a: calc.quo(i, 2), b: 0, up: calc.even(i))
              let p = corners(slot).map(c => point(c, side-cm)).map(((x, y)) => (x, y + y0))
              let l = labels.at(piece.t)
              let turned = range(3).map(j => l.at(calc.rem(j + piece.turn, 3)))
              draw-card(draw, p, turned, side-cm, base-size,
                number: if number { piece.t + 1 } else { none }, stroke: 0.6pt)
            }
          }
        })
      }
    })
  }
}
