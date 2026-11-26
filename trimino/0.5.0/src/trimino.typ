// trimino 0.5.0 – öffentliche Funktionen.
#import "@preview/cetz:0.4.2" as cetz
#import "internal/check.typ": fail, check-named, check-value, check-type, check-positional
#import "internal.typ": sheet-head, sheet-note, back-bleed, check-point, draw-back-ground, content-area, draw-back, back-label-layout, back-label-zone, back-label-content, cut-segments, cut-svg, mark-drawing, mark-geometry, mark-inset, mark-margin, themes, resolve-theme, pastels, edge-colors, ring-colors, catalogue, vertices, draw-card, edges, fill-edges, height, next-random, point, shape-names, shape-triangles, shuffle, wheel-corners, fit-sizes, pip-layout

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
/// - color (color, auto): Farbe aller Kärtchen; `auto` überlässt sie dem Theme (bei `"riso"` ein Pastellton für den ganzen Satz, der mit `seed` wechselt)
/// - seed (int): Startwert für das Mischen; gleiche Zahl, gleiches Spiel
/// - side (length): Kantenlänge eines Kärtchens auf dem Schnittbogen
/// - title (content, str, none): Titel über Lösung und Schnittbogen
/// - solution (bool): Lösungsbild setzen
/// - cards (bool): Schnittbogen setzen
/// - number (bool): Kärtchennummer in der Mitte des Lösungsbilds; auf dem Schnittbogen steht keine, weil ihre Ausrichtung die Lage des Kärtchens verraten würde
/// - theme (str, dictionary, auto): Gestaltung: `"riso"` (Pastell, weiße Felder, Drachen; Standard bei `auto`), `"klar"` (schwarz-weiß, kopierfest), `"leiste"` (violette Leiste an den Kanten), passend zu `@schule/arbeitsblatt` `"atlas"` (Schulbuch, getönt), `"skizze"` (verspielt, Unterstufe), `"labor"` (technisch, MINT), `"kontur"` (plakativ); ein Dictionary ändert einzelne Schlüssel von `"riso"` oder, mit `base: "atlas"`, eines anderen Themes (alle Schlüssel in der Dokumentation)
/// - label-size (length, auto): Schriftgröße der Beschriftungen auf dem Schnittbogen; `auto` macht sie so groß, wie der Platz an den Kanten erlaubt (alle gleich groß, nur sehr lange einzeln kleiner)
/// - corners (bool, str): `true` Eckmarken (Theme-Schlüssel `corner-mark`: Drachen, die im Lösungsbild Sterne ergeben, Bögen oder Kreissektoren, die sich zu Kreisen schließen, flache Dreiecke oder Messskalen); `"wheel"` Eckspitzen zur Selbstkontrolle: sechs Farben, auf Wunsch mit 1–6 Würfelaugen; richtig gelegt kommt an keiner Ecke eine Farbe doppelt vor (Form und Augen über die Theme-Schlüssel `tip` und `pips`); `false` keine
/// - back (bool, content, str): hinter jeden Schnittbogen eine Rückseite zum beidseitigen Druck an der langen Kante (die Plätze sind dafür gespiegelt); `true` schreibt „TRIMINO“ und den Titel auf jedes Kärtchen, ein Inhalt ersetzt den Titel unter „TRIMINO“, etwa `[*Prozentrechnung*\ Grundaufgaben]`
/// - first-copy (int): Buchstabe des ersten Satzes als Zahl (1 = A, 3 = C), damit mehrere gedruckte Bögen verschiedene Sätze tragen
/// - copies (int): so viele Sätze Kärtchen auf den Schnittbogen, etwa für zwei Gruppen; jeder Satz neu gemischt; auf der Rückseite trägt jedes Kärtchen Satzbuchstabe und Nummer (A1–A12, B1–B12, …)
/// - cut-marks (bool): Passermarken für Silhouette-Schneideplotter auf jeden Schnittbogen; die Schnittlinien stehen dann als `metadata` mit dem Label `<cut-data>` im Dokument (`typst query datei.typ "<cut-data>"`)
/// - ..deprecated (arguments): fängt unbekannte Namen ab, nimmt nichts an
/// -> content
#let trimino(
  pairs: (),
  shape: auto,
  shape-size: auto,
  distractors: (),
  seed: 1,
  color: auto,
  side: 6cm,
  title: none,
  solution: true,
  cards: true,
  number: true,
  theme: auto,
  corners: true,
  label-size: auto,
  back: false,
  copies: 1,
  first-copy: 1,
  cut-marks: false,
  ..deprecated,
) = {
  let fn = "trimino"
  check-positional(pkg, fn, deprecated, hint: "die Paare stehen in `pairs: ((Aufgabe, Lösung), …)`")
  check-named(pkg, fn, deprecated, allowed: ("pairs", "shape", "shape-size", "distractors", "seed", "color",
    "side", "title", "solution", "cards", "number", "theme", "corners", "label-size", "back", "copies", "first-copy", "cut-marks"))
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
  check-type(pkg, fn, "color", color, (std.color, auto), example: "rgb(\"#dfe7fd\")")
  check-type(pkg, fn, "side", side, length, example: "6cm")
  check-type(pkg, fn, "title", title, (content, str, none))
  check-type(pkg, fn, "solution", solution, bool)
  check-type(pkg, fn, "cards", cards, bool)
  check-type(pkg, fn, "number", number, bool)
  let style = resolve-theme(pkg, fn, theme)
  // Eine feste Farbe für alle Kärtchen des Satzes.
  if color != auto { style.fill = color }
  check-type(pkg, fn, "label-size", label-size, (length, auto), example: "12pt")
  check-type(pkg, fn, "corners", corners, (bool, str), example: "\"wheel\"")
  if type(corners) == str { check-value(pkg, fn, "corners", corners, (true, false, "wheel")) }
  check-type(pkg, fn, "back", back, (bool, content, str), example: "[*Prozentrechnung*\\ Grundaufgaben]")
  let has-back = back != false
  check-type(pkg, fn, "copies", copies, int, example: "2")
  if copies < 1 { fail(pkg, fn, "`copies` muss mindestens 1 sein") }
  check-type(pkg, fn, "first-copy", first-copy, int, example: "3")
  if first-copy < 1 { fail(pkg, fn, "`first-copy` muss mindestens 1 sein (1 = A)") }
  check-type(pkg, fn, "cut-marks", cut-marks, bool)
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
  if corners == "wheel" and style.wheel == none and not style.pips {
    fail(pkg, fn, "`corners: \"wheel\"` mit grauen Spitzen (`wheel: none`) braucht Augen – `pips: true` setzen oder ein farbiges Theme wählen")
  }

  // Farben je Kärtchen und je Kante, auf Lösung und Schnittbogen gleich.
  let tints = ()
  let edge-tints = ()
  let r = seed * 7919 + 17
  let centers = triangles.map(t => {
    let c = vertices(t).map(c => point(c, 1))
    (c.map(p => p.at(0)).sum() / 3, c.map(p => p.at(1)).sum() / 3)
  })
  let mid = (centers.map(c => c.at(0)).sum() / centers.len(), centers.map(c => c.at(1)).sum() / centers.len())
  let dist(c) = calc.round(calc.sqrt(calc.pow(c.at(0) - mid.at(0), 2) + calc.pow(c.at(1) - mid.at(1), 2)), digits: 2)
  let distances = centers.map(dist).dedup().sorted()
  for (t, _) in triangles.enumerate() {
    r = next-random(r)
    let ring-index = distances.position(x => x == dist(centers.at(t)))
    let ring-color = ring-colors.at(calc.rem(ring-index, ring-colors.len()))
    tints.push(if style.fill == "ring" { ring-color.lighten(72%) }
      else if style.fill == "parity" { if triangles.at(t).up { rgb("#ece8fb") } else { rgb("#dcd5f7") } }
      else if style.fill == "single" { rgb("#ece8fb") }
      else if style.fill == "set" {
        // ein Ton für den ganzen Satz, nach `seed` aus der Palette
        let palette = style.at("palette", default: pastels)
        palette.at(calc.rem(calc.max(seed - 1, 0), palette.len()))
      } else {
        let palette = if type(style.fill) == array { style.fill } else { style.at("palette", default: pastels) }
        palette.at(calc.rem(calc.quo(r, 65536), palette.len()))
      })
    let et = ()
    for i in range(3) {
      r = next-random(r)
      et.push(edge-colors.at(calc.rem(calc.quo(r, 65536), edge-colors.len())))
    }
    edge-tints.push(et)
  }
  // Eckfarben mit eigenem Zufall, damit `corners` das Spiel nicht ändert.
  let corner-tints = if corners == "wheel" { wheel-corners(triangles, seed * 104729 + 31) }
    else { triangles.map(_ => none) }

  let side-cm = side / 1cm
  let base-size = 10pt * side-cm / 6
  let fixed = if label-size == auto { none } else { label-size / side-cm }
  let head(caption) = sheet-head("Trimino", caption, title, style)

  // Lösungsbild
  if solution {
    head[Lösung]
    layout(available => {
      let pts = triangles.map(t => vertices(t).map(c => point(c, 1)))
      let xs = pts.flatten().chunks(2).map(p => p.at(0))
      let ys = pts.flatten().chunks(2).map(p => p.at(1))
      let (w, h) = (calc.max(..xs) - calc.min(..xs), calc.max(..ys) - calc.min(..ys))
      // `layout` misst den ganzen Satzspiegel: Kopf und Fußnote abziehen.
      let head-h = measure(block(width: available.width, head[Lösung])).height + 5mm
      let room-h = available.height - head-h - if corners == "wheel" { 0.9cm } else { 0.1cm }
      let unit = calc.min(side-cm, available.width / 1cm / w, room-h / 1cm / h)
      let sizes = fit-sizes(labels, style, corners, fixed: fixed, number: number, side: side-cm)
      align(center, cetz.canvas(length: 1cm, {
        import cetz.draw
        for (t, tri) in triangles.enumerate() {
          let p = vertices(tri).map(c => point(c, unit))
          draw-card(draw, p, labels.at(t), unit, base-size * unit / side-cm,
            number: if number { t + 1 } else { none }, theme: style, corners: corners,
            tint: tints.at(t), edge-tints: edge-tints.at(t), corner-tints: corner-tints.at(t), sizes: sizes.at(t),
            solution: true)
        }
      }))
      if corners == "wheel" {
        // Der Hinweis nennt die Augen nur, wenn das Lösungsbild sie auch zeigt.
        let pips = pip-layout(style, unit, solution: true).visible
        let where = if style.tip == "circle" [Kreis] else if style.tip == "ring" [Ring] else [Sechseck]
        sheet-note(theme: style)[Kontrolle][In keinem #where kommt eine #(if pips [Farbe oder Augenzahl] else [Farbe]) doppelt vor.]
      }
    })
  }

  // Schnittbogen
  if cards {
    let pieces = ()
    let s = state
    for copy in range(copies) {
      let (order, s2) = shuffle(range(triangles.len()), s)
      s = s2
      for t in order {
        s = next-random(s)
        // Nummer auf der Rückseite: je Satz 1, 2, …; bei mehreren Sätzen mit
        // dem Buchstaben des Satzes davor (A1, …, B1, …).
        let k = pieces.filter(p => p.copy == copy).len() + 1
        let letter = if copies > 1 or first-copy > 1 {
          "ABCDEFGHIJKLMNOPQRSTUVWXYZ".clusters().at(calc.rem(first-copy - 1 + copy, 26))
        } else { "" }
        pieces.push((t: t, turn: calc.rem(calc.quo(s, 65536), 3), copy: copy, number: letter + str(k)))
      }
    }
    // Kein `layout(…)`: darin sind Seitenumbrüche verboten. Der Satzspiegel
    // folgt aus Seitengröße und Rändern.
    let sheets = context {
      let available = content-area()
      let per-row = calc.max(1, calc.floor(2 * available.width / side - 1))
      // Die Reihen liegen ohne Abstand aneinander, jede zweite um eine halbe
      // Kante versetzt und mit einem Kärtchen „Spitze unten“ beginnend. So
      // liegen alle Kanten auf durchgehenden Geraden über den ganzen Bogen:
      // ein Schnitt trennt zwei Kärtchen, und ein Schneideplotter schneidet
      // lange Geraden am Stück.
      let row-gap = 0
      // Platz unter dem Kopf (je nach Theme verschieden hoch).
      let head-h = measure(block(width: available.width, head[Schnittbogen])).height + 5mm
      let rows-per-page = calc.max(1, calc.floor((available.height - head-h) / 1cm / (side-cm * height + row-gap)))
      let pages = pieces.chunks(per-row * rows-per-page)
      for (pi, page-pieces) in pages.enumerate() {
        if pi > 0 { pagebreak() }
        head[Schnittbogen]
        let rows = page-pieces.chunks(per-row)
        // Ecken jedes Kärtchens in cm, Ursprung links unten im ersten Platz
        let placed = ()
        for (r, row) in rows.enumerate() {
          let y0 = -r * (side-cm * height + row-gap)
          let odd = calc.odd(r)
          let dx = if odd { -side-cm / 2 } else { 0 }
          for (i, piece) in row.enumerate() {
            let j = if odd { i + 1 } else { i }
            let slot = (a: calc.quo(j, 2), b: 0, up: calc.even(j))
            placed.push((piece: piece, pts: vertices(slot).map(c => point(c, side-cm)).map(((x, y)) => (x + dx, y + y0))))
          }
        }
        // Feste Ausdehnung der Zeichnung, damit die Lage auf der Seite bekannt ist.
        let x-max = calc.max(..placed.map(q => q.pts.map(p => p.at(0))).flatten())
        let y-min = -(rows.len() - 1) * (side-cm * height + row-gap)
        let y-max = side-cm * height
        let sizes = fit-sizes(labels, style, corners, fixed: fixed, number: false, side: side-cm)
        let drawing = cetz.canvas(length: 1cm, {
          import cetz.draw
          draw.rect((0, y-min), (x-max, y-max), stroke: none, fill: none)
          for q in placed {
            let piece = q.piece
            let l = labels.at(piece.t)
            let turned = range(3).map(j => l.at(calc.rem(j + piece.turn, 3)))
            let et = edge-tints.at(piece.t)
            let ct = corner-tints.at(piece.t)
            draw-card(draw, q.pts, turned, side-cm, base-size,
              number: none, theme: style, corners: corners,
              tint: tints.at(piece.t), edge-tints: range(3).map(j => et.at(calc.rem(j + piece.turn, 3))),
              corner-tints: if ct == none { none } else { range(3).map(j => ct.at(calc.rem(j + piece.turn, 3))) },
              sizes: range(3).map(j => sizes.at(piece.t).at(calc.rem(j + piece.turn, 3))))
          }
        })
        if cut-marks {
          let segments = cut-segments(placed.map(q => q.pts))
          block({
            place(top + left, context {
              let here-pos = here().position()
              let mm(l) = calc.round(l / 1mm, digits: 3)
              let to-mark((x, y)) = (
                calc.round(mm(here-pos.x) + x * 10 - mark-inset / 1mm, digits: 2),
                calc.round(mm(here-pos.y) + (y-max - y) * 10 - mark-inset / 1mm, digits: 2),
              )
              [#metadata((
                format: "cut-data",
                version: 1,
                source: "trimino",
                page: here-pos.page,
                unit: "mm",
                page-size: (mm(page.width), mm(page.height)),
                marks: mark-geometry(page.width, page.height),
                check: check-point(page.width, page.height),
                paths: segments.map(seg => seg.map(to-mark)),
                pieces: placed.map(q => q.pts.map(to-mark)),
              )) <cut-data>]
            })
            drawing
          })
        } else {
          drawing
        }
        // Rückseite: dieselben Plätze, waagerecht gespiegelt (Duplexdruck an
        // der langen Kante). Gleiche Höhe der Überschrift, damit die Reihen
        // übereinanderliegen; die Zeichnung steht rechtsbündig, also bei
        // gleichen Rändern links und rechts genau gespiegelt.
        if has-back {
          pagebreak()
          [#metadata(none) <trimino-back-page>]
          hide(head[Schnittbogen])
          let mirror(pts) = pts.map(((x, y)) => (x-max - x, y))
          // Die Fläche ragt über die Kärtchen hinaus, an spitzen Ecken bis
          // zum Doppelten von `back-bleed`. Die Zeichnung bekommt ringsum
          // einen festen, sicher größeren Rand `d` und wird um ihn
          // zurückgeschoben, damit die Kärtchen genau gespiegelt liegen.
          let d = 3 * back-bleed
          // Im Fluss nur so hoch wie die Vorderseite, damit der Zusatzrand
          // keinen Seitenumbruch auslöst.
          // Etiketten vorab messen: ihre Fläche (samt Rand) bleibt frei von Konfetti.
          let labels = placed.map(q => back-label-content(style, base-size, title,
            custom: if type(back) == bool { none } else { back }, number: q.piece.number))
          let layouts = placed.zip(labels).map(((q, l)) => back-label-layout(mirror(q.pts), side-cm, l))
          block(width: 100%, height: (y-max - y-min) * 1cm,
            place(top + right, dx: d * 1cm, dy: -d * 1cm, cetz.canvas(length: 1cm, {
            import cetz.draw
            draw.rect((-d, y-min - d), (x-max + d, y-max + d), stroke: none, fill: none)
            let zones = layouts.map(l => back-label-zone(l.rect))
            let row-cards = rows.enumerate().map(((r, row)) => {
              let first = rows.slice(0, r).map(x => x.len()).sum(default: 0)
              placed.slice(first, first + row.len()).map(q => mirror(q.pts))
            })
            draw-back-ground(draw, row-cards, seed + pi, style, zones: zones)
            draw-back(draw, labels, layouts)
          })))
        }
      }
    }
    // Marken nur auf den Vorderseiten. Mit Rückseite beginnt der Schnittbogen auf einer ungeraden
    // Seite, damit das ganze Dokument beidseitig gedruckt werden kann.
    let background = context {
      let backs = query(<trimino-back-page>).map(m => m.location().page())
      if cut-marks and here().page() not in backs { mark-drawing(page.width, page.height) }
    }
    if has-back { pagebreak(weak: true, to: "odd") }
    if cut-marks {
      page(margin: mark-margin, header: none, footer: none, background: background, sheets)
    } else if has-back {
      page(header: none, footer: none, background: background, sheets)
    } else {
      if solution { pagebreak() }
      sheets
    }
  }
}

/// Legt die Schnittvorlage aller Schnittbögen als Datei in ein Bündel.
///
/// Gehört auf die oberste Ebene eines Bündels, neben `document(…)`, und
/// liest die Schnittdaten, die `trimino(cut-marks: true)` dort hinterlegt.
/// Die Endung von `path` bestimmt das Format: `.json` schreibt die Daten
/// wie `typst query`, `.svg` je Schnittbogen ein Blatt mit Passermarken
/// (schwarz) und Schnittlinien (rot, `#ff0000`); bei mehreren Bögen erhalten
/// die Dateien `-1`, `-2`, … vor der Endung.
///
/// ```typ
/// #document("trimino.pdf", trimino(pairs: paare, cut-marks: true))
/// #trimino-cut-file("trimino-schnitt.svg")
/// ```
///
/// Übersetzen mit `typst compile datei.typ ausgabe --format bundle --features bundle`.
///
/// - path (str): Dateiname im Bündel, Endung `.json` oder `.svg`
/// -> content
#let trimino-cut-file(path) = {
  let fn = "trimino-cut-file"
  check-type(pkg, fn, "path", path, str, example: "\"trimino-schnitt.svg\"")
  let ext = lower(path.split(".").last())
  check-value(pkg, fn, "Endung von `path`", ext, ("json", "svg"))
  context {
    if target() != "bundle" {
      fail(pkg, fn, "nur in einem Bündel möglich – auf oberster Ebene neben `document(…)` "
        + "setzen und mit `--format bundle --features bundle` übersetzen")
    }
    let sheets = query(<cut-data>).map(m => m.value)
    if sheets.len() == 0 {
      fail(pkg, fn, "keine Schnittdaten – im Dokument `trimino(…, cut-marks: true)` setzen")
    }
    if ext == "json" {
      asset(path, json.encode(sheets))
    } else {
      let stem = path.slice(0, path.len() - 4)
      for (k, d) in sheets.enumerate() {
        let name = if sheets.len() == 1 { path } else { stem + "-" + str(k + 1) + ".svg" }
        asset(name, cut-svg(d))
      }
    }
  }
}
