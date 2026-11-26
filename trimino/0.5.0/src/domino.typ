// trimino 0.5.0 – Dominos: rechteckige Kärtchen in einer Kette.
//
// Ein Kärtchen hat zwei quadratische Hälften: links die Lösung der vorigen
// Aufgabe, rechts die nächste Aufgabe. Das erste trägt links „Start“, das
// letzte rechts „Ende“; mit `loop: true` schließt sich die Kette.
//
// Lösungsbild: Die Kette läuft auf einem Raster aus Quadraten (eine Hälfte =
// ein Quadrat). Jedes Kärtchen geht nach rechts, oben oder unten weiter, nie
// nach links; so steht keine Schrift auf dem Kopf und die Kette kann sich nie
// selbst kreuzen. Aus Schlangen und zufälligen Treppen (fest durch `seed`)
// gewinnt die Kette, die im verfügbaren Platz am größten gezeichnet werden kann.
#import "@preview/cetz:0.4.2" as cetz
#import "internal/check.typ": fail, check-named, check-value, check-type, check-positional
#import "internal.typ": (sheet-head, sheet-note, back-bleed, back-safe, back-margin, edge-colors, check-point,
  content-area, label-fonts, displayed, mark-six-nine, chrome-font, code-font, display-font, ink-color, back-palette,
  back-card-label, cut-segments, draw-confetti, draw-back-paper, confetti-shapes, mark-drawing, mark-geometry,
  mark-inset, mark-margin, next-random, pastels, ring-colors, shuffle, themes, resolve-theme, answer-color,
  task-color, field-color, set-cap, readable-size, shadow-box, mono)

#let pkg = "trimino"

// ---------------------------------------------------------------------------
// Lösungsform
// ---------------------------------------------------------------------------

/// Kette aus Richtungen (je Kärtchen `(1, 0)`, `(0, 1)` oder `(0, -1)`).
/// Liefert `(a:, d:)` je Kärtchen oder none, wenn sich die Kette überlappt.
#let domino-build(dirs) = {
  let key(p) = str(p.at(0)) + "," + str(p.at(1))
  let add(p, q) = (p.at(0) + q.at(0), p.at(1) + q.at(1))
  let cards = ((a: (0, 0), d: dirs.at(0)),)
  let cells = (key((0, 0)): true, key(dirs.at(0)): true)
  for o in dirs.slice(1) {
    let last = cards.last()
    let a = add(add(last.a, last.d), o)
    if key(a) in cells or key(add(a, o)) in cells { return none }
    cells.insert(key(a), true)
    cells.insert(key(add(a, o)), true)
    cards.push((a: a, d: o))
  }
  cards
}

/// Kette aus `n` Kärtchen für das Lösungsbild. Liefert je Kärtchen `(a:
/// Zelle der linken Hälfte, d: Richtung)`; die rechte Hälfte liegt bei
/// `a + d`. `aspect` ist Breite : Höhe des Platzes. Kandidaten sind
/// Schlangen (senkrechte Strecken aus `h` Kärtchen, verbunden durch `m`
/// waagerechte) und zufällige Treppen; es gewinnt die Kette, die am größten
/// gezeichnet werden kann, bei Gleichstand die mit mehr waagerechten
/// Kärtchen (deren Schrift steht aufrecht).
#let domino-path(n, seed, aspect, tries: 120) = {
  let candidates = ()
  // Schlangen; der Anfang verschiebt sich mit `seed`, damit verschiedene
  // Seeds verschiedene Formen geben.
  for h in range(1, n) {
    for m in (1, 2) {
      let dirs = ()
      let down = calc.even(seed)
      let k = calc.rem(seed, h + m)
      while dirs.len() < n {
        let phase = calc.rem(k, h + m)
        if phase < m { dirs.push((1, 0)) }
        else {
          dirs.push(if down { (0, -1) } else { (0, 1) })
          if phase == h + m - 1 { down = not down }
        }
        k += 1
      }
      candidates.push(dirs)
    }
  }
  // Zufällige Treppen
  let r = seed * 7907 + 11
  for _ in range(tries) {
    let dirs = ((1, 0),)
    for k in range(1, n) {
      let last = dirs.last()
      let options = if last == (1, 0) { ((1, 0), (0, 1), (0, -1)) } else { (last, (1, 0)) }
      r = next-random(r)
      dirs.push(options.at(calc.rem(calc.quo(r, 65536), options.len())))
    }
    candidates.push(dirs)
  }
  let best = none
  let best-score = none
  for dirs in candidates {
    let cards = domino-build(dirs)
    if cards == none { continue }
    let all = cards.map(c => (c.a, (c.a.at(0) + c.d.at(0), c.a.at(1) + c.d.at(1)))).flatten().chunks(2)
    let xs = all.map(p => p.at(0))
    let ys = all.map(p => p.at(1))
    let (w, h) = (calc.max(..xs) - calc.min(..xs) + 1, calc.max(..ys) - calc.min(..ys) + 1)
    let flat = cards.filter(c => c.d == (1, 0)).len() / cards.len()
    // Maßstab im Platz (Höhe = 1), waagerechte Kärtchen leicht bevorzugt.
    let score = calc.min(aspect / w, 1 / h) * (1 + 0.25 * flat)
    if best-score == none or score > best-score {
      best-score = score
      best = cards.map(c => (a: (c.a.at(0) - calc.min(..xs), c.a.at(1) - calc.min(..ys)), d: c.d))
    }
  }
  best
}

// ---------------------------------------------------------------------------
// Lösungswort (Rückseite beim Stapel)
// ---------------------------------------------------------------------------

/// Lösungswörter; eines mit passender Buchstabenzahl wird ausgewählt.
/// Leerzeichen zählen nicht mit.
#let domino-words = (
  "TOP", "TOLL", "SUPER", "PRIMA", "BRAVO", "KLASSE", "SPITZE", "GENIAL",
  "RICHTIG", "PERFEKT", "TREFFER", "SUPERGUT", "BESTNOTE",
  "GESCHAFFT", "WUNDERBAR", "ALLES KLAR", "FEHLERLOS",
  "GROSSARTIG", "GUT GEMACHT", "WELTKLASSE", "MATHEPROFI", "BÄRENSTARK",
  "SUPERKLASSE", "FANTASTISCH", "EINWANDFREI", "MEISTERHAFT", "VOLLTREFFER", "ERSTKLASSIG",
  "HERVORRAGEND", "ALLES RICHTIG", "SUPER GEMACHT", "ALLES PERFEKT", "ZIEL ERREICHT", "DU BIST SPITZE",
  "AUSGEZEICHNET", "SPITZENKLASSE", "PERFEKT GELEGT", "SAUBERE ARBEIT", "KLASSE GEMACHT",
  "ALLES GESCHAFFT", "STARKE LEISTUNG", "ALLES IN ORDNUNG",
  "SPITZENLEISTUNG", "MEISTERLEISTUNG", "DU BIST DER HAMMER",
  "GANZ GROSSE KLASSE", "WUNDERBAR GEMACHT", "GROSSARTIG GELÖST",
  "DU HAST ES GESCHAFFT", "FANTASTISCH GELÖST",
  "ALLES RICHTIG GELEGT", "HERVORRAGEND GELÖST",
  "DU BIST EIN MATHEPROFI", "AUSGEZEICHNET GELÖST",
  "DAS HAST DU TOLL GEMACHT",
  "DAS HAST DU SUPER GEMACHT", "HERZLICHEN GLÜCKWUNSCH",
  "DAS WAR GANZ GROSSE KLASSE",
  "SUPER DU HAST ALLES RICHTIG",
  "DU HAST ALLES RICHTIG GELEGT", "DAS WAR EINE STARKE LEISTUNG",
  "DU BIST EIN ECHTES MATHEGENIE",
  "DAS HAST DU WIRKLICH TOLL GELÖST", "WAHNSINN DAS WAR SPITZENKLASSE",
  "DAS HAST DU WIRKLICH TOLL GEMACHT", "HERZLICHEN GLÜCKWUNSCH ZUM SIEG",
  "GLÜCKWUNSCH ALLES PERFEKT GELEGT",
)

#let domino-letters(word) = upper(word).clusters().filter(c => c != " ")

/// Ein Lösungswort aus `n` Buchstaben (fest durch `seed`); gibt es keins,
/// zwei Wörter hintereinander. Liefert den Text mit Leerzeichen.
#let domino-word(n, seed) = {
  let by(k) = domino-words.filter(w => domino-letters(w).len() == k)
  let pick(list, k) = list.at(calc.rem(seed + k, list.len()))
  let fit = by(n)
  if fit.len() > 0 { return pick(fit, 0) }
  for a in range(n - 3, 2, step: -1) {
    let (x, y) = (by(a), by(n - a))
    if x.len() > 0 and y.len() > 0 { return pick(x, 1) + " " + pick(y, 2) }
  }
  none
}

// ---------------------------------------------------------------------------
// Kärtchen
// ---------------------------------------------------------------------------

// Rand um das Feld einer Hälfte, Innenabstand des Felds und Platz der
// Überschrift (`tags`), als Anteil der Kantenlänge `side`.
#let domino-pad = 0.075
#let domino-inset = 0.06
#let domino-tag = 0.13
// Stapel: Überschrift als Zeilenkopf links, Platz 3 × 0,11 der Kante.
#let domino-tag-head = 0.33

// Größe einer Hälfte in Einheiten von `side`: Kette quadratisch, Stapel
// breit und flach (zwei Hälften übereinander).
#let domino-dims(layout) = if layout == "stack" { (2, 0.62) } else { (1, 1) }

/// Farbe der Kärtchenfläche.
#let domino-paint(theme, tint) = {
  if type(theme.fill) == array or theme.fill in ("set", "tint", "ring") { tint }
  else if theme.fill in ("parity", "single") { rgb("#f1f3f6") }
  else if theme.fill == none { white }
  else { theme.fill }
}

/// Band einer Hälfte: none, Farbe; bei `"edge"` die Lösung rötlich, die Aufgabe bläulich (hell).
#let domino-band(theme, side) = {
  if theme.band == none { none }
  else if theme.band == "edge" { (if side == 0 { edge-colors.at(0) } else { edge-colors.at(1) }).lighten(55%) }
  else { theme.band }
}

/// Anlegerahmen mit drei Merkmalen: Lösung dünn, rund und rot, Aufgabe
/// kräftig, eckig und dunkelblau (großer Helligkeitsabstand). So bleibt der
/// Unterschied auch auf einer Schwarz-Weiß-Kopie und bei Farbsehschwäche
/// sichtbar; bei `klar` tragen ihn Strichstärke und Ecken.
#let domino-frame-colors(theme) = (theme.at("answer", default: answer-color), theme.at("task", default: task-color))
#let domino-frame-widths = (1pt, 1.7pt)
/// Eckradius der Rahmen an geschlossenen Ecken (s = Kante in Länge).
#let domino-frame-radius(side, s) = if side == 0 { 0.05 * s } else { 0pt }

/// Inhalt einer Hälfte in Grundgröße, samt Rahmen bei `"pill"`, um `rot`
/// gedreht (Typst-Drehsinn, im Uhrzeigersinn).
#let domino-body(body, size, theme, rot: 0deg, display: true) = {
  let fonts = label-fonts(theme)
  let weight = if theme.weight == auto { fonts.weight } else { theme.weight }
  let shown = {
    set text(font: fonts.text, size: size, fill: theme.ink, weight: weight, number-type: "lining",
      top-edge: "bounds", bottom-edge: "bounds")
    show math.equation: set text(font: fonts.math) if fonts.math != none
    mark-six-nine(body, shown: if display { displayed(body) } else { body })
  }
  // Wie bei den Triminos: "pill" weiße (oder `pill`-farbige) Kapsel mit
  // Haarlinie, "outline" feiner Rahmen; "field"/"tab" färben das Feld.
  let framed = if theme.label == "pill" {
    box(fill: if theme.pill == none { white } else { theme.pill }, inset: (x: 0.45em, y: 0.35em), radius: 0.8em,
      stroke: 0.4pt + luma(70%), shown)
  } else if theme.label == "outline" {
    box(inset: (x: 0.4em, y: 0.32em), radius: 2pt, stroke: 0.5pt + theme.ink.lighten(35%), shown)
  } else { shown }
  if rot == 0deg { framed } else { rotate(rot, reflow: true, framed) }
}

/// Überschrift einer Hälfte in Größe `size`, in der Schrift der Beschriftungen
/// (der Strich in f′ kommt aus der Matheschrift).
#let domino-tag-body(tag, theme, size) = {
  let fonts = label-fonts(theme)
  set text(font: fonts.text, size: size, fill: theme.ink.lighten(12%), top-edge: "bounds", bottom-edge: "bounds",
    hyphenate: false)
  show math.equation: set text(font: fonts.math) if fonts.math != none
  tag
}

/// Größe und Platz der Überschriften (`tags`), in Einheiten der Kante:
/// `size` Schriftgröße, `room` Platz (Kette: oben, Stapel: Breite des
/// Zeilenkopfs), `width` größte Breite. Die Überschrift ist höchstens
/// 0,1 × Kante groß und wird kleiner, bis sie in eine Zeile passt (Kette: das
/// Feld, Stapel: der Zeilenkopf von 0,33 × Kante), aber nicht unter 6 pt.
/// Passt sie dann noch nicht, bricht sie in der Kette um, und beim Stapel
/// wird der Zeilenkopf breiter. Braucht `context`.
#let domino-tag-fit(tags, theme, dims, side-cm) = {
  if tags == none { return none }
  let unit = side-cm * 1cm
  let band = if theme.band == none { 0 } else { theme.band-depth * 0.7 }
  let g = 0.03
  let floor = 6pt / unit
  let probe = 0.1
  let widths = tags.map(t => measure(domino-tag-body(t, theme, probe * unit)).width / unit)
  let wq = calc.max(..widths, 0.001)
  if dims.at(0) > dims.at(1) {
    // Zeilenkopf: Text endet `g` vor dem Inhalt.
    let avail = domino-tag-head - g
    let size = calc.max(floor, probe * calc.min(1, avail / wq))
    let w = wq * size / probe
    (size: size, room: calc.max(domino-tag-head, w + g), width: none, floor: floor)
  } else {
    let avail = dims.at(0) - 2 * (domino-pad + band) - 2 * g
    let size = calc.max(floor, probe * calc.min(1, avail / wq))
    let hs = tags.map(t => measure(block(width: avail * unit, domino-tag-body(t, theme, size * unit))).height / unit)
    (size: size, room: calc.max(..hs) + g, width: avail, floor: floor)
  }
}

/// Platz für den Inhalt einer Hälfte (in Einheiten von `side`): (Breite, Höhe).
/// Die Überschrift (`tag-fit` aus `domino-tag-fit`) nimmt oben Platz weg, bei
/// gedrehtem Inhalt seitlich, beim Stapel links.
#let domino-room(theme, tag-fit, dims, rot) = {
  let band = if theme.band == none { 0 } else { theme.band-depth * 0.7 }
  let edge = 2 * (domino-pad + band + domino-inset)
  let (w, h) = (dims.at(0) - edge, dims.at(1) - edge)
  if tag-fit == none { return (w, h) }
  // Breite Hälften (Stapel): Überschrift als Zeilenkopf links.
  if dims.at(0) > dims.at(1) { return (w - tag-fit.room, h) }
  if rot == 0deg { (w, h - tag-fit.room) } else { (w - tag-fit.room, h) }
}

/// Maßstab je Hälfte (je cm `side`): so groß, wie die Hälfte erlaubt; eine
/// Größe je Satz (wie bei den Triminos: höchstens 1,05 × Median und 1,25 ×
/// die kleinste lesbare), Schrift höchstens 0,2 × Kante. `entries`: je Hälfte
/// `(body:, rot:)`, body none bei Start/Ende. `side-cm`: Kante auf dem
/// Schnittbogen (für die lesbare Mindestgröße). Braucht `context`.
#let domino-fit(entries, theme, tag-fit, dims, fixed: none, probe: 11pt, side-cm: none) = {
  if fixed != none { return entries.map(_ => fixed / probe) }
  let each = entries.map(e => {
    if e.body == none { return none }
    let (rw, rh) = domino-room(theme, tag-fit, dims, e.rot)
    let m = measure(domino-body(e.body, probe, theme, rot: e.rot, display: dims.at(1) >= dims.at(0)))
    calc.min(rw / (m.width / 1cm), rh / (m.height / 1cm))
  })
  let cap = set-cap(each, floor: if side-cm == none { 0 } else { readable-size / 11 / side-cm })
  let cap = if cap == none { 1 } else { cap }
  // Schrift höchstens 0,2 × Kante (20 pt bei 3,5 cm).
  let text-cap = 0.2 * 1cm / probe
  each.map(x => if x == none { none } else { calc.min(x, cap, text-cap) })
}

/// Eine Hälfte als Inhalt der Größe w × h. `h-data`: `(kind:, body:, k:, rot:)`,
/// `open`: offene Seite des Felds oder none, `side`: 0 Lösung, 1 Aufgabe.
#let domino-half(h-data, open, side, w, h, unit, u, theme, paint, tags, start, end, tag-fit: none) = {
  let band = domino-band(theme, side)
  let band-w = if band == none { 0pt } else { theme.band-depth * 0.7 * unit }
  let p = domino-pad * unit
  let rot = h-data.rot
  // Zur offenen Seite reicht das Feld bis an die Kante des Kärtchens.
  let sides(v) = {
    let d = (left: v, right: v, top: v, bottom: v)
    if open != none { d.insert(open, 0pt) }
    d
  }
  let inner = if h-data.kind == "start" or h-data.kind == "end" {
    // Start/Ende: Versalien in der Grotesk, gesperrt, in Tinte, nie größer
    // als die Inhalte. Hinter START zeigt ein Pfeil zur ersten Aufgabe (im
    // fertigen Bild gesehen), hinter ENDE schließt ein kleines Quadrat.
    let stacked = w > h
    let sz = calc.min(0.1 * w, 0.16 * h, 11pt)
    if h-data.at("cap", default: none) != none { sz = calc.min(sz, h-data.cap * u * 11pt) }
    let word = text(font: code-font(theme), size: sz, weight: "semibold", fill: theme.ink,
      tracking: if theme.at("code", default: none) != none { 0.04em } else { 0.14em },
      top-edge: "cap-height", bottom-edge: "baseline", if h-data.kind == "start" {
        let arrow = if stacked { sym.arrow.b } else if rot == 90deg { sym.arrow.t }
          else if rot == -90deg { sym.arrow.b } else { sym.arrow.r }
        upper(start); std.h(0.4em); text(tracking: 0em, arrow)
      } else {
        upper(end); std.h(0.4em); box(width: 0.55em, height: 0.55em, fill: theme.ink)
      })
    align(center + horizon, if rot == 0deg { word } else { rotate(rot, reflow: true, word) })
  } else {
    let wide = w > h
    let shown = scale(h-data.k * u * 100%, reflow: true, domino-body(h-data.body, 11pt, theme, rot: rot, display: not wide))
    let r = domino-frame-radius(side, unit)
    let line = domino-frame-widths.at(side) + domino-frame-colors(theme).at(side)
    let stroke = (left: line, right: line, top: line, bottom: line)
    if open != none { stroke.insert(open, none) }
    let corner(a, b) = if open in (a, b) { 0pt } else { r }
    let field-paint = if theme.pill != none { theme.pill } else { theme.at("field", default: field-color) }
    let i = domino-inset * unit
    // Überschrift: in der Kette oben links im Feld, wie der Inhalt gedreht;
    // beim Stapel als Zeilenkopf links, senkrecht mittig. Nie größer als der
    // kleinste Inhalt (aber nicht unter 6 pt).
    let tf = if tags == none { none } else if tag-fit != none { tag-fit }
      else { (size: 0.1, room: if wide { domino-tag-head } else { domino-tag }, width: none) }
    let t = if tf == none { 0pt } else { tf.room * unit }
    let tag = if tags == none { none } else {
      let content-size = h-data.at("cap", default: h-data.k) * u * 11pt
      let size = calc.min(tf.size * unit, calc.max(content-size, tf.at("floor", default: 0) * unit))
      let body = domino-tag-body(tags.at(side), theme, size)
      if tf.width != none and not wide { block(width: tf.width * unit, body) } else { body }
    }
    let extra = (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt)
    let placed = none
    if tag != none {
      // Abstand zum Rahmen: 0,03 der Kante (Zeilenkopf: 0,06).
      let g = 0.03 * unit
      if wide {
        let th = t
        extra.left = th
        placed = place(left + horizon, dx: -i - th + 2 * g, tag)
      } else if rot == 0deg {
        extra.top = t
        placed = place(top + left, dx: -i + g, dy: -i - t + g, tag)
      } else if rot == 90deg {
        extra.right = t
        placed = place(top + right, dx: i + t - g, dy: -i + g, rotate(90deg, reflow: true, tag))
      } else {
        extra.left = t
        placed = place(bottom + left, dx: -i - t + g, dy: i - g, rotate(-90deg, reflow: true, tag))
      }
    }
    let radii = (top-left: corner("top", "left"), top-right: corner("top", "right"),
      bottom-left: corner("bottom", "left"), bottom-right: corner("bottom", "right"))
    let field = box(width: 100%, height: 100%, radius: radii,
      fill: if theme.label in ("field", "tab", "pill") or band != none or theme.at("shadow", default: none) != none { field-paint } else { none },
      stroke: stroke,
      inset: (left: i + extra.left, right: i + extra.right, top: i + extra.top, bottom: i + extra.bottom), {
        placed
        align(center + horizon, shown)
      })
    let shadow = theme.at("shadow", default: none)
    if shadow == none { field } else {
      // Harter Schatten nach rechts unten (`kontur`), zur offenen Seite hin
      // ohne Versatz, damit er an der Fuge nicht absetzt.
      let d = calc.max(2pt, 0.035 * unit)
      let (dx, dy) = (if open == "right" { 0pt } else { d }, if open == "bottom" { 0pt } else { d })
      box(width: 100%, height: 100%, {
        place(top + left, dx: dx, dy: dy, box(width: 100%, height: 100%, radius: radii, fill: shadow))
        field
      })
    }
  }
  box(width: w, height: h, inset: sides(band-w), fill: band,
    box(width: 100%, height: 100%, fill: if band == none { none } else { paint }, inset: sides(p), inner))
}

/// Ein Kärtchen als Inhalt (u = `side` in cm). Kette: 2u × u, Hälften
/// nebeneinander; Stapel: 2u × 2·0,62u, Hälften übereinander. `halves`: zwei
/// Einträge `(kind:, body:, k:, rot:)`; `opens`: offene Seite je Hälfte.
#let domino-card(halves, u, theme, layout: "chain", tint: none, tags: none, start: [Start], end: [Ende],
  radius: 0pt, opens: (none, none), tag-fit: none) = {
  let unit = u * 1cm
  let paint = domino-paint(theme, tint)
  let (dw, dh) = domino-dims(layout)
  let (w, h) = (dw * unit, dh * unit)
  let stacked = layout == "stack"
  let (cw, ch) = if stacked { (w, 2 * h) } else { (2 * w, h) }
  let half(side) = domino-half(halves.at(side), opens.at(side), side, w, h, unit, u, theme, paint, tags, start, end,
    tag-fit: tag-fit)
  // Trennlinie der Hälften: durchgezogen und hell, damit sie nicht wie eine
  // Schnittlinie aussieht.
  // `divider`: "line", "dashed", "ticks" (Messskala) oder none.
  let style = theme.at("divider", default: "line")
  let rule = if style == "dashed" { (paint: luma(62%), thickness: 0.6pt, dash: (2pt, 2.5pt)) }
    else { (paint: luma(80%), thickness: 0.4pt) }
  let m = if theme.band == none { 0.2 } else { 0.05 }
  let ticks(length, across) = {
    // Striche alle 0,04 der Kante, jeder fünfte länger, quer zur Trennlinie.
    let n = int(length / (0.04 * unit))
    for k in range(n + 1) {
      let at = (length - n * 0.04 * unit) / 2 + k * 0.04 * unit
      let l = if calc.rem(k, 5) == 0 { 0.05 * unit } else { 0.025 * unit }
      if across { place(top + left, dx: at, dy: -l / 2, line(angle: 90deg, length: l, stroke: 0.4pt + luma(55%))) }
      else { place(top + left, dx: -l / 2, dy: at, line(length: l, stroke: 0.4pt + luma(55%))) }
    }
  }
  box(width: cw, height: ch, fill: paint, radius: radius, clip: true, {
    place(top + left, half(0))
    if stacked {
      place(top + left, dy: h, half(1))
      if style == "ticks" { place(top + left, dx: m * unit, dy: h, ticks(cw - 2 * m * unit, true)) }
      else if style != none { place(top + left, dx: m * unit, dy: h, line(length: cw - 2 * m * unit, stroke: rule)) }
    } else {
      place(top + left, dx: w, half(1))
      if style == "ticks" { place(top + left, dx: w, dy: m * h, ticks((1 - 2 * m) * h, false)) }
      else if style != none { place(top + left, dx: w, dy: m * h, line(angle: 90deg, length: (1 - 2 * m) * h, stroke: rule)) }
    }
    // Umriss zuletzt, damit Bänder ihn nicht verdecken.
    place(top + left, rect(width: cw, height: ch, radius: radius, stroke: theme.stroke, fill: none))
  })
}

/// Offene Seiten der Felder je Kärtchen in der Kette: Die Lösung (links) ist
/// zum vorigen Kärtchen hin offen, also immer links; die Aufgabe (rechts) zu
/// der Seite, an die das nächste Kärtchen anlegt: rechts (geradeaus), oben
/// oder unten (Abbiegen). Erst zusammen mit dem Nachbarn schließt sich der
/// Rahmen; so sieht man, in welche Richtung man anlegt. Beim Stapel ist die
/// Lösung oben, die Aufgabe unten offen.
#let domino-opens(path, dominoes, layout) = dominoes.enumerate().map(((i, d)) => {
  let has(j) = d.at(j).kind == "content"
  if layout == "stack" {
    (if has(0) { "top" } else { none }, if has(1) { "bottom" } else { none })
  } else {
    let c = path.at(i)
    let right = if not has(1) { none }
      else if i + 1 >= path.len() { "right" }
      else {
        let (dx, dy) = c.d
        let n = path.at(i + 1).d
        if n == c.d { "right" } else if n == (-dy, dx) { "top" } else { "bottom" }
      }
    (if has(0) { "left" } else { none }, right)
  }
})

/// Drehung der Inhalte eines Kärtchens, damit sie im fertigen Domino aufrecht
/// stehen: gegen die Lage des Kärtchens (Typst-Drehsinn).
#let domino-rot(c) = if c.d == (0, 1) { 90deg } else if c.d == (0, -1) { -90deg } else { 0deg }

/// Rückseitenetikett eines Dominos: Schriftzug, Titel, Nummer; beim
/// Lösungswort groß der Buchstabe.
#let domino-back-label(theme, title, number, size, letter: none) = back-card-label("DOMINO", theme, size,
  below: title, number: number, letter: letter)

// ---------------------------------------------------------------------------
// Öffentliche Funktion
// ---------------------------------------------------------------------------

/// Setzt ein Domino: Lösungsbild und Schnittbogen.
///
/// Jedes Kärtchen trägt die Lösung der vorigen und die nächste Aufgabe. Als
/// Kette (`layout: "chain"`) liegen die Hälften nebeneinander; das Lösungsbild
/// legt die Kette zufällig (fest durch `seed`) nach rechts, oben und unten,
/// und die offenen Seiten der Felder zeigen, wo angelegt wird. Als Stapel
/// (`layout: "stack"`) liegen breite Kärtchen untereinander; zur Kontrolle
/// ergibt die Rückseite von oben nach unten ein Lösungswort.
///
/// ```typ
/// #domino(title: [Einmaleins], pairs: (
///   ([3 · 4], [12]), ([6 · 7], [42]), ([8 · 8], [64]),
/// ))
/// ```
///
/// - pairs (array): Paare `(Aufgabe, Lösung)`, jeweils Inhalt oder Text (auch Graphen)
/// - layout (str): `"chain"` (Kette mit Abbiegungen, Hälften nebeneinander) oder `"stack"` (Stapel aus breiten Kärtchen, Lösung oben, Aufgabe unten)
/// - word (auto, str, none): Lösungswort auf den Rückseiten, ein Buchstabe je Kärtchen in Lösungsreihenfolge (Leerzeichen zählen nicht); `auto` wählt beim Stapel ein Wort passender Länge, bei der Kette keins
/// - loop (bool): geschlossene Kette ohne Start und Ende; das erste Kärtchen trägt die letzte Lösung
/// - start (content, str): Aufschrift des ersten Felds
/// - end (content, str): Aufschrift des letzten Felds
/// - tags (array, none): kleine Überschriften der beiden Hälften, etwa `([$f'(x)$], [$f(x)$])`
/// - color (color, auto): Farbe aller Kärtchen; `auto` überlässt sie dem Theme (bei `"riso"` ein Pastellton für den ganzen Satz, der mit `seed` wechselt)
/// - seed (int): Startwert für Lösungsform, Lösungswort und Mischen
/// - side (length): Grundmaß: bei der Kette Kantenlänge einer Hälfte (Kärtchen 2 × 1), beim Stapel halbe Kärtchenbreite
/// - title (content, str, none): Titel über Lösung und Schnittbogen
/// - solution (bool): Lösungsbild setzen
/// - cards (bool): Schnittbogen setzen
/// - theme (str, dictionary, auto): wie bei `trimino`
/// - label-size (length, auto): feste Schriftgröße auf dem Schnittbogen; `auto` füllt jede Hälfte aus
/// - back (bool, content, str): Rückseite zum beidseitigen Druck an der langen Kante; ein Inhalt ersetzt den Titel; mit Lösungswort immer an
/// - copies (int): so viele Sätze auf den Schnittbogen
/// - first-copy (int): Buchstabe des ersten Satzes als Zahl (1 = A)
/// - cut-marks (bool): Passermarken für Silhouette-Schneideplotter, Schnittdaten als `<cut-data>`
/// - ..deprecated (arguments): fängt unbekannte Namen ab, nimmt nichts an
/// -> content
#let domino(
  pairs: (),
  layout: "chain",
  word: auto,
  loop: false,
  start: [Start],
  end: [Ende],
  tags: none,
  seed: 1,
  color: auto,
  side: 3.5cm,
  title: none,
  solution: true,
  cards: true,
  theme: auto,
  label-size: auto,
  back: false,
  copies: 1,
  first-copy: 1,
  cut-marks: false,
  ..deprecated,
) = {
  let fn = "domino"
  check-positional(pkg, fn, deprecated, hint: "die Paare stehen in `pairs: ((Aufgabe, Lösung), …)`")
  check-named(pkg, fn, deprecated, allowed: ("pairs", "layout", "word", "loop", "start", "end", "tags", "seed", "color",
    "side", "title", "solution", "cards", "theme", "label-size", "back", "copies", "first-copy", "cut-marks"))
  check-type(pkg, fn, "pairs", pairs, array, example: "(([2 + 3], [5]), ([4 · 2], [8]))")
  for (k, p) in pairs.enumerate() {
    if type(p) != array or p.len() != 2 {
      fail(pkg, fn, "Paar " + str(k + 1) + " ist kein Paar – jedes Paar als `(Aufgabe, Lösung)` angeben")
    }
  }
  if pairs.len() < 2 { fail(pkg, fn, "zu wenige Paare – mindestens zwei Paare in `pairs` angeben") }
  check-value(pkg, fn, "layout", layout, ("chain", "stack"))
  check-type(pkg, fn, "word", word, (auto, str, none), example: "\"SUPER\"")
  check-type(pkg, fn, "loop", loop, bool)
  check-type(pkg, fn, "start", start, (content, str))
  check-type(pkg, fn, "end", end, (content, str))
  check-type(pkg, fn, "tags", tags, (array, none), example: "([$f'(x)$], [$f(x)$])")
  if tags != none and tags.len() != 2 { fail(pkg, fn, "`tags` braucht zwei Einträge – `(links, rechts)`") }
  check-type(pkg, fn, "seed", seed, int, example: "7")
  check-type(pkg, fn, "color", color, (std.color, auto), example: "rgb(\"#dfe7fd\")")
  check-type(pkg, fn, "side", side, length, example: "3.5cm")
  check-type(pkg, fn, "title", title, (content, str, none))
  check-type(pkg, fn, "solution", solution, bool)
  check-type(pkg, fn, "cards", cards, bool)
  let style = resolve-theme(pkg, fn, theme)
  // Eine feste Farbe für alle Kärtchen des Satzes.
  if color != auto { style.fill = color }
  check-type(pkg, fn, "label-size", label-size, (length, auto), example: "12pt")
  check-type(pkg, fn, "back", back, (bool, content, str), example: "[*Ableitung*]")
  check-type(pkg, fn, "copies", copies, int, example: "2")
  if copies < 1 { fail(pkg, fn, "`copies` muss mindestens 1 sein") }
  check-type(pkg, fn, "first-copy", first-copy, int, example: "3")
  if first-copy < 1 { fail(pkg, fn, "`first-copy` muss mindestens 1 sein (1 = A)") }
  check-type(pkg, fn, "cut-marks", cut-marks, bool)

  let stacked = layout == "stack"
  let side-cm = side / 1cm
  let fixed = if label-size == auto { none } else { label-size / side-cm }
  let dims = domino-dims(layout)
  let (card-w, card-h) = if stacked { (dims.at(0), 2 * dims.at(1)) } else { (2, 1) }

  // Kärtchen in Lösungsreihenfolge: (Lösung, Aufgabe) als Hälften.
  let n = pairs.len()
  let task(k) = (kind: "content", body: pairs.at(k).at(0))
  let answer(k) = (kind: "content", body: pairs.at(k).at(1))
  let dominoes = if loop {
    range(n).map(k => (answer(calc.rem(k + n - 1, n)), task(k)))
  } else {
    (((kind: "start", body: none), task(0)),) + range(1, n).map(k => (answer(k - 1), task(k))) + (
      (answer(n - 1), (kind: "end", body: none)),)
  }
  let count = dominoes.len()

  // Lösungswort
  let letters = if word == none or (word == auto and not stacked) { none } else {
    let chosen = if word == auto { domino-word(count, seed) } else { word }
    if chosen == none { fail(pkg, fn, "kein Lösungswort mit " + str(count) + " Buchstaben – `word` selbst setzen") }
    let l = domino-letters(chosen)
    if l.len() != count {
      fail(pkg, fn, "`word` hat " + str(l.len()) + " Buchstaben, es gibt aber " + str(count)
        + " Kärtchen – ein Wort mit " + str(count) + " Buchstaben wählen (Leerzeichen zählen nicht)")
    }
    (text: upper(chosen), list: l)
  }
  let has-back = back != false or letters != none

  // Farbe je Kärtchen, auf Lösung und Schnittbogen gleich.
  let r = seed * 7919 + 17
  let tints = ()
  let palette = if type(style.fill) == array { style.fill } else { style.at("palette", default: pastels) }
  for _ in dominoes {
    r = next-random(r)
    // "set": ein Ton für den ganzen Satz, nach `seed` aus der Palette.
    tints.push(if style.fill == "set" { palette.at(calc.rem(calc.max(seed - 1, 0), palette.len())) }
      else { palette.at(calc.rem(calc.quo(r, 65536), palette.len())) })
  }

  let head(caption) = sheet-head("Domino", caption, title, style)
  // Lösungskette: aus dem Satzspiegel, damit Lösungsbild und Schnittbogen
  // dieselbe Kette (offene Seiten, Drehungen) haben. Braucht `context`.
  let chain() = if stacked { none } else {
    let area = content-area()
    let head-h = measure(block(width: area.width, head[Lösung])).height + 5mm
    domino-path(count, seed, area.width / (area.height - head-h - 0.6cm))
  }
  // Hälften mit Drehung und Maßstab. Braucht `context`.
  let prepare(path, fixed) = {
    let rots = if path == none { dominoes.map(_ => 0deg) } else { path.map(domino-rot) }
    let entries = dominoes.enumerate().map(((i, d)) => d.map(h => (body: h.body, rot: rots.at(i)))).flatten()
    let tag-fit = domino-tag-fit(tags, style, dims, side-cm)
    let ks = domino-fit(entries, style, tag-fit, dims, fixed: fixed, side-cm: side-cm)
    // Start/Ende nie größer als der kleinste Inhalt.
    let kmin = calc.min(..ks.filter(x => x != none), 100)
    let halves = dominoes.enumerate().map(((i, d)) =>
      d.enumerate().map(((j, h)) => h + (k: ks.at(2 * i + j), rot: rots.at(i), cap: kmin)))
    (halves: halves, opens: domino-opens(path, dominoes, layout), tag-fit: tag-fit)
  }

  // Lösungsbild
  if solution {
    head[Lösung]
    std.layout(available => {
      // `layout` misst den ganzen Satzspiegel: Kopf und Fußnote abziehen.
      let head-h = measure(block(width: available.width, head[Lösung])).height + 5mm
      let room-h = available.height - head-h - if letters != none { 1.3cm } else { 0.5cm }
      let path = chain()
      let prep = prepare(path, none)
      let card(i, u, radius: 0pt) = domino-card(prep.halves.at(i), u, style, layout: layout, tint: tints.at(i),
        tags: tags, start: start, end: end, radius: radius, opens: prep.opens.at(i), tag-fit: prep.tag-fit)
      if stacked {
        // Spalten von oben nach unten, so viele, wie den größten Maßstab geben.
        let gap = 0.5
        let best = (1, 0)
        for cols in range(1, count + 1) {
          let per = calc.ceil(count / cols)
          let u = calc.min(side-cm, (available.width / 1cm - (cols - 1) * gap) / (cols * card-w),
            room-h / 1cm / (per * card-h))
          if u > best.at(1) { best = (cols, u) }
        }
        let (cols, u) = best
        let per = calc.ceil(count / cols)
        align(center, grid(columns: cols, column-gutter: gap * 1cm,
          ..range(cols).map(c => stack(..range(c * per, calc.min(count, (c + 1) * per)).map(i =>
            card(i, u))))))
      } else {
        let cells = path.map(c => (c.a, (c.a.at(0) + c.d.at(0), c.a.at(1) + c.d.at(1)))).flatten().chunks(2)
        let w = calc.max(..cells.map(p => p.at(0))) + 1
        let h = calc.max(..cells.map(p => p.at(1))) + 1
        let u = calc.min(side-cm, available.width / 1cm / w, room-h / 1cm / h)
        align(center, cetz.canvas(length: 1cm, {
          import cetz.draw
          draw.rect((0, 0), (w * u, h * u), stroke: none, fill: none)
          for (i, c) in path.enumerate() {
            let center = ((c.a.at(0) + c.d.at(0) / 2 + 0.5) * u, (c.a.at(1) + c.d.at(1) / 2 + 0.5) * u)
            let angle = if c.d == (1, 0) { 0deg } else if c.d == (0, 1) { 90deg } else { -90deg }
            draw.content(center, anchor: "center", angle: angle, card(i, u))
          }
        }))
      }
      if letters != none {
        sheet-note(theme: style)[Lösungswort][
          #box(baseline: 30%, stack(dir: ltr, spacing: 1mm, ..letters.list.map(l => box(width: 5.2mm, height: 6mm,
            stroke: 0.5pt + luma(45%), align(center + horizon, text(font: display-font(style), size: 11pt, weight: "semibold",
              features: ("ss02",), l))))))
          #h(0.8em) #text(fill: luma(40%), size: 9pt)[Rückseiten von oben nach unten]]
      }
    })
  }

  // Schnittbogen
  if cards {
    let pieces = ()
    let s = r
    for copy in range(copies) {
      let (order, s2) = shuffle(range(count), s)
      s = s2
      for (j, i) in order.enumerate() {
        let letter = if copies > 1 or first-copy > 1 {
          "ABCDEFGHIJKLMNOPQRSTUVWXYZ".clusters().at(calc.rem(first-copy - 1 + copy, 26))
        } else { "" }
        pieces.push((i: i, number: letter + str(j + 1)))
      }
    }
    let (cw, ch) = (card-w * side-cm, card-h * side-cm)
    let sheets = context {
      let available = content-area()
      let per-row = calc.max(1, calc.floor(available.width / 1cm / cw))
      let head-h = measure(block(width: available.width, head[Schnittbogen])).height + 5mm
      let rows-per-page = calc.max(1, calc.floor((available.height - head-h) / 1cm / ch))
      let prep = prepare(chain(), fixed)
      for (pi, page-pieces) in pieces.chunks(per-row * rows-per-page).enumerate() {
        if pi > 0 { pagebreak() }
        head[Schnittbogen]
        let rows = page-pieces.chunks(per-row)
        let placed = ()
        for (ri, row) in rows.enumerate() {
          for (ci, piece) in row.enumerate() {
            let (x0, y0) = (ci * cw, -(ri + 1) * ch)
            placed.push((piece: piece, pts: ((x0, y0), (x0 + cw, y0), (x0 + cw, y0 + ch), (x0, y0 + ch))))
          }
        }
        let x-max = calc.max(..placed.map(q => q.pts.at(1).at(0)))
        let y-min = -rows.len() * ch
        let y-max = 0
        let drawing = cetz.canvas(length: 1cm, {
          import cetz.draw
          draw.rect((0, y-min), (x-max, y-max), stroke: none, fill: none)
          for q in placed {
            let (x0, y0) = q.pts.at(0)
            let i = q.piece.i
            draw.content((x0 + cw / 2, y0 + ch / 2), anchor: "center",
              domino-card(prep.halves.at(i), side-cm, style, layout: layout, tint: tints.at(i), tags: tags,
                start: start, end: end, opens: prep.opens.at(i), tag-fit: prep.tag-fit))
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
                source: "domino",
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
        // Rückseite: dieselben Plätze, waagerecht gespiegelt.
        if has-back {
          pagebreak()
          [#metadata(none) <domino-back-page>]
          hide(head[Schnittbogen])
          let mirror(pts) = pts.map(((x, y)) => (x-max - x, y))
          let d = 3 * back-bleed
          let pal = back-palette(style)
          let palette = pal.colors
          let ground = pal.ground
          let custom = if type(back) == bool { none } else { back }
          block(width: 100%, height: (y-max - y-min) * 1cm,
            place(top + right, dx: d * 1cm, dy: -d * 1cm, cetz.canvas(length: 1cm, {
              import cetz.draw
              draw.rect((-d, y-min - d), (x-max + d, y-max + d), stroke: none, fill: none)
              let b = back-bleed
              let outline = ((-b, y-min - b), (x-max + b, y-min - b), (x-max + b, y-max + b), (-b, y-max + b))
              draw-back-paper(draw, (outline,), style)
              // Etiketten vorab messen und einpassen; ihre Fläche samt Rand
              // bleibt frei von Konfetti.
              let labels = placed.map(q => {
                let pts = mirror(q.pts)
                let center = ((pts.at(0).at(0) + pts.at(1).at(0)) / 2, pts.at(0).at(1) + ch / 2)
                let label = domino-back-label(style, if custom != none { custom } else { title },
                  q.piece.number, 10pt, letter: if letters == none { none } else { letters.list.at(q.piece.i) })
                let m = measure(label)
                let (lw, lh) = (m.width / 1cm, m.height / 1cm)
                let f = calc.min(calc.min(0.68 * cw, cw - 2 * back-safe - 0.4) / lw, (ch - 2 * back-safe - 0.3) / lh, 1.3)
                (center: center, label: label, scale: f, rect: (center.at(0) - lw * f / 2, center.at(1) - lh * f / 2,
                  center.at(0) + lw * f / 2, center.at(1) + lh * f / 2))
              })
              let zones = labels.map(l => {
                let (x0, y0, x1, y1) = l.rect
                (x0 - back-margin, y0 - back-margin, x1 + back-margin, y1 + back-margin)
              })
              draw-confetti(draw, outline, seed * 48271 + pi, palette, (y-min - b, y-max + b),
                shape: confetti-shapes(style, "domino"),
                avoid: zones)
              for l in labels {
                draw.content(l.center, anchor: "center", scale(l.scale * 100%, reflow: true, l.label))
              }
            })))
        }
      }
    }
    let background = context {
      let backs = query(<domino-back-page>).map(m => m.location().page())
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
