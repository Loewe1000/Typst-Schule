// brainroot -- zweiseitige Mindmaps mit farbigen Ästen.
//
// Die Wurzel steht in der Mitte, die Äste verteilen sich nach rechts und
// links, jeder Ast trägt seine eigene Farbe bis in die Blätter. Das Layout
// ist ein einfacher "tidy tree": jeder Teilbaum bekommt so viel Höhe, wie
// seine Kinder brauchen, und wird am Elternknoten zentriert.

#import "@preview/cetz:0.4.2"

/// Ein Ast der Mindmap.
///
/// - label: Beschriftung des Knotens (Content oder String).
/// - ..kids: Kinder; entweder weitere `branch(...)` oder einfach Content,
///   der dann als Blatt ohne eigene Kinder gilt.
/// - color: Farbe des Astes. Nur auf der ersten Ebene ausgewertet, darunter
///   erbt jeder Knoten die Farbe seines Elternknotens. `none` nimmt die
///   nächste Farbe aus der Palette.
/// - side: `left`, `right` oder `auto`. Nur auf der ersten Ebene ausgewertet.
#let branch(label, ..kids, color: none, side: auto) = (
  brainroot-node: true,
  label: label,
  kids: kids.pos(),
  color: color,
  side: side,
)

// Alles, was kein branch ist, wird zu einem Blatt.
#let _norm(k) = if type(k) == dictionary and k.at("brainroot-node", default: false) { k } else { branch(k) }

// --- Listen als Eingabe ----------------------------------------------------
//
// Im Markup ist eine Liste eine Folge von `list.item`-Elementen; erst beim
// Setzen werden sie zu einem `list`. Beide Formen werden hier verstanden.

#let _is-item(c) = type(c) == content and c.func() in (list.item, enum.item)
#let _is-list(c) = type(c) == content and c.func() in (list, enum)
#let _is-blank(c) = type(c) == content and c.func() in (parbreak, [ ].func())

// Zerlegt den Rumpf eines Listenpunkts in Beschriftung und verschachtelte
// Punkte: alles, was kein Listenpunkt ist, bleibt Beschriftung; jeder
// verschachtelte Punkt wird zum Kind.
#let _from-item(item) = {
  let body = item.body
  let parts = if body.func() == [].func() { body.children } else { (body,) }
  let label = ()
  let kids = ()
  for p in parts {
    if _is-item(p) {
      kids.push(_from-item(p))
    } else if _is-list(p) {
      kids += p.children.map(_from-item)
    } else if kids.len() == 0 {
      label.push(p)
    }
  }
  // Leerraum am Rand der Beschriftung stört nur.
  while label.len() > 0 and _is-blank(label.first()) { label = label.slice(1) }
  while label.len() > 0 and _is-blank(label.last()) { label = label.slice(0, -1) }
  branch(label.join(), ..kids)
}

// Ist das Argument eine Liste oder eine Folge von Listenpunkten, liefert es
// deren Punkte als Äste; sonst das Argument selbst als einzelnen Ast.
#let _expand(arg) = {
  if _is-list(arg) {
    arg.children.map(_from-item)
  } else if _is-item(arg) {
    (_from-item(arg),)
  } else if type(arg) == content and arg.func() == [].func() and arg.children.any(_is-item) and arg.children.all(c => _is-item(c) or _is-list(c) or _is-blank(c)) {
    arg.children.filter(c => not _is-blank(c)).map(_expand).flatten()
  } else {
    (arg,)
  }
}

// --- Paletten --------------------------------------------------------------
//
// Jede Palette: acht Astfarben, der Reihe nach vergeben, und eine Farbe für
// die Wurzel. Die Kästen bekommen die Astfarbe um `tint` aufgehellt.

#let palettes = (
  // Kräftig bunt wie Filzstifte an der Tafel.
  poster: (colors: (rgb("#e8321e"), rgb("#f5a623"), rgb("#f2c230"), rgb("#3fc728"),
                    rgb("#1fc2ee"), rgb("#9b3fd6"), rgb("#f78fc0"), rgb("#2a7de1")),
           root: rgb("#7f9bff")),
  // Zartes Pastell, gedämpfte Töne.
  pastel: (colors: (rgb("#e28f8f"), rgb("#e9b97a"), rgb("#d6cf7a"), rgb("#8fc79a"),
                    rgb("#7fb8d4"), rgb("#a99adb"), rgb("#d9a0c8"), rgb("#8fbfb5")),
           root: rgb("#9aa6d6")),
  // Nur Grau: Stufen von dunkel bis mittel.
  grayscale: (colors: (rgb("#222222"), rgb("#555555"), rgb("#333333"), rgb("#777777"),
                       rgb("#444444"), rgb("#888888"), rgb("#2b2b2b"), rgb("#666666")),
              root: rgb("#111111")),
  // Ein Farbton, Blau, in wechselnder Helligkeit.
  mono: (colors: (rgb("#0b3d91"), rgb("#2a62c2"), rgb("#1749a8"), rgb("#4d80d6"),
                  rgb("#0f2f6e"), rgb("#6e9be0"), rgb("#1f56b5"), rgb("#3a70cc")),
         root: rgb("#082a66")),
  // Schlicht: eine dunkle Tinte für alles, wie mit dem Füller gezeichnet.
  plain: (colors: (rgb("#1a1a1a"),), root: rgb("#1a1a1a")),
  // Erdtöne: Terrakotta, Ocker, Oliv, Sand.
  earth: (colors: (rgb("#b5532a"), rgb("#c98b2e"), rgb("#7a7a2f"), rgb("#8c5a3c"),
                   rgb("#a3762b"), rgb("#5d6b3a"), rgb("#c47a54"), rgb("#6b4e35")),
          root: rgb("#4e3a2a")),
  // Meer: Türkis, Petrol, Seegrün.
  ocean: (colors: (rgb("#0c7c8c"), rgb("#1ea8b5"), rgb("#155e75"), rgb("#2bb39a"),
                   rgb("#0e4d64"), rgb("#4cc3d2"), rgb("#1b8a7d"), rgb("#3b6fa0")),
          root: rgb("#0b3a4a")),
  // Abendhimmel: Rot, Orange, Rosa, Violett.
  sunset: (colors: (rgb("#c72c41"), rgb("#ee6f3b"), rgb("#f2a541"), rgb("#d9436b"),
                    rgb("#8e3b8f"), rgb("#f07f6f"), rgb("#b02a5c"), rgb("#e88d3a")),
           root: rgb("#5b1f4a")),
  // Wald: Grün mit etwas Braun.
  forest: (colors: (rgb("#2d6a4f"), rgb("#40916c"), rgb("#1b4332"), rgb("#74a57f"),
                    rgb("#6b8e23"), rgb("#8a6e3a"), rgb("#52b788"), rgb("#3e5c3a")),
           root: rgb("#1b4332")),
  // Neon: grelle, gesättigte Farben.
  neon: (colors: (rgb("#ff2079"), rgb("#00e5ff"), rgb("#aaff00"), rgb("#ffe600"),
                  rgb("#ff6a00"), rgb("#b026ff"), rgb("#00ff9c"), rgb("#ff3cac")),
         root: rgb("#1a1a2e")),
)

#let _palette(p) = {
  if type(p) == str {
    assert(p in palettes, message: "brainroot: unbekannte Palette \"" + p + "\", erwartet eine von " + palettes.keys().join(", "))
    palettes.at(p)
  } else if type(p) == array {
    (colors: p, root: rgb("#7f9bff"))
  } else if type(p) == dictionary {
    (colors: palettes.poster.colors, root: rgb("#7f9bff")) + p
  } else {
    panic("brainroot: palette muss ein Name, ein Array von Farben oder ein Dictionary (colors, root) sein")
  }
}

// --- Themes ----------------------------------------------------------------
//
// Ein Theme bestimmt, wie Kästen und Kanten aussehen; die Farben kommen
// weiterhin aus der Palette. Felder:
//   edge      "curve" | "elbow" | "straight"   Kantenführung
//   fill      "tint" | "solid" | "white" | "none"   Füllung der Kästen
//   stroke    Rahmenstärke der Kästen (0pt = kein Rahmen)
//   radius    Eckenradius (auch relativ, 50% = Pille)
//   underline true: kein Kasten, der Text steht auf einer farbigen Linie,
//             und die Kanten laufen in diese Linie hinein
//   dash      Strichmuster der Kanten ("solid", "dashed", "dotted")
//   font      Schrift der Beschriftungen; `none` erbt vom Dokument
//   hand      `none`, oder ein Dictionary für handgezeichnete Linien:
//               amplitude   Ausschlag des Wackelns in pt
//               wavelength  Länge einer Welle in pt
//               randomness  Unregelmäßigkeit des Rhythmus (1 = reiner Sinus)
//               segment     Schrittweite entlang des Pfades in pt
//               passes      wie oft jede Linie gezeichnet wird (2 = "gekritzelt")
//   root      Überschreibungen nur für die Wurzel (fill, stroke, radius)

#let themes = (
  // Pastellkästen, weiche S-Kurven -- die Vorlage von der Tafel.
  soft: (edge: "curve", fill: "tint", stroke: 0pt, radius: 8pt, underline: false, dash: "solid",
         root: (fill: "solid")),
  // Weiße Kästen mit farbigem Rahmen, Kurven.
  outline: (edge: "curve", fill: "white", stroke: 1pt, radius: 6pt, underline: false, dash: "solid",
            root: (fill: "solid", stroke: 0pt)),
  // Volle Farbe, weiße Schrift, rechte Winkel: Organigramm-Optik.
  blocks: (edge: "elbow", fill: "solid", stroke: 0pt, radius: 0pt, underline: false, dash: "solid",
           root: (:)),
  // Keine Kästen: der Text steht auf seiner Linie, klassische Mindmap.
  lines: (edge: "curve", fill: "none", stroke: 0pt, radius: 0pt, underline: true, dash: "solid",
          root: (fill: "solid", radius: 6pt)),
  // Skizze: gestrichelte Geraden, dünner Rahmen, keine Füllung.
  sketch: (edge: "straight", fill: "none", stroke: 0.8pt, radius: 3pt, underline: false, dash: "dashed",
           root: (fill: "white", stroke: 1.5pt)),
  // Pillen und gerade Verbindungen.
  bubbles: (edge: "straight", fill: "tint", stroke: 1pt, radius: 50%, underline: false, dash: "solid",
            root: (fill: "solid")),
  // Handgezeichnet: wie `soft`, aber jede Linie wackelt leicht.
  hand: (edge: "curve", fill: "tint", stroke: 1pt, radius: 8pt, underline: false, dash: "solid",
         hand: (amplitude: 0.6, wavelength: 80, randomness: 2, segment: 1.5, passes: 1),
         root: (fill: "solid")),
  // Gekritzelt: keine Füllung, jede Linie zweimal gezogen.
  scribble: (edge: "curve", fill: "none", stroke: 0.7pt, radius: 6pt, underline: false, dash: "solid",
             hand: (amplitude: 0.9, wavelength: 50, randomness: 2.5, segment: 1.5, passes: 2),
             root: (fill: "white", stroke: 1pt)),
  // Filzstift: volle Farbe, breite gerade Striche mit langem Wackeln.
  marker: (edge: "straight", fill: "solid", stroke: 0pt, radius: 4pt, underline: false, dash: "solid",
           hand: (amplitude: 1.2, wavelength: 120, randomness: 2, segment: 2, passes: 1),
           root: (:)),
  // Bleistift: dünne graue Linien mit feinem Zittern, rechte Winkel.
  pencil: (edge: "elbow", fill: "white", stroke: 0.6pt, radius: 2pt, underline: false, dash: "solid",
           hand: (amplitude: 0.35, wavelength: 30, randomness: 3, segment: 1, passes: 1),
           root: (stroke: 1pt)),
)

#let _theme-defaults = (font: none, hand: none)

#let _theme(t) = {
  if type(t) == str {
    assert(t in themes, message: "brainroot: unbekanntes Theme \"" + t + "\", erwartet eines von " + themes.keys().join(", "))
    _theme-defaults + themes.at(t)
  } else if type(t) == dictionary {
    // Ein Dictionary überschreibt einzelne Felder von `soft`; `hand` und
    // `root` werden feldweise zusammengeführt.
    let base = _theme-defaults + themes.at(t.at("base", default: "soft"))
    let hand = if type(t.at("hand", default: none)) == dictionary {
      (if base.hand == none { (:) } else { base.hand }) + t.hand
    } else { t.at("hand", default: base.hand) }
    base + t + (root: base.root + t.at("root", default: (:)), hand: hand)
  } else {
    panic("brainroot: theme muss ein String oder ein Dictionary sein")
  }
}

// --- Darstellung eines einzelnen Knotens -----------------------------------

// Wahrgenommene Helligkeit einer Farbe, 0 dunkel bis 1 hell.
#let _luma(c) = {
  let (r, g, b, ..) = rgb(c).components().map(v => v / 100%)
  0.299 * r + 0.587 * g + 0.114 * b
}

// Füllung eines Kastens nach dem Theme-Feld `fill`. Getönte Füllungen
// werden um `tint` aufgehellt und dann so weit weiter, bis sie mindestens
// `tint-min` hell sind: aus einer fast schwarzen Tinte wird sonst nur ein
// mittleres Grau, auf dem Schrift schlecht steht.
#let _fill(mode, color, opts) = {
  if mode == "solid" { color }
  else if mode == "white" { white }
  else if mode == "tint" {
    let f = color.lighten(opts.tint)
    let n = 0
    while _luma(f) < opts.tint-min and n < 4 { f = f.lighten(30%); n += 1 }
    f
  } else { none }
}

// Schriftfarbe zu einer Füllung: `ink` gilt, wenn gesetzt; bei `auto`
// entscheidet die Helligkeit der Füllung, ob dunkle oder helle Schrift
// besser lesbar ist. Ohne Füllung ist es die dunkle.
#let _ink(fill, opts) = {
  if opts.ink != auto { opts.ink }
  else if fill == none { opts.ink-dark }
  else if _luma(fill) < opts.ink-threshold { opts.ink-light }
  else { opts.ink-dark }
}

#let _nodebox(node, depth, color, opts, width: auto) = {
  let th = opts.theme
  let root = depth == 0
  let spec = if root { th + th.root } else { th }
  let color = if root { opts.root-fill } else { color }
  let scale = opts.scale.at(calc.min(depth, opts.scale.len() - 1))
  let weight = if depth < opts.bold-depth { "bold" } else { "regular" }
  let fill = _fill(spec.fill, color, opts)
  let ink = _ink(fill, opts)
  let stroke = if spec.underline and not root { none }
    else if spec.stroke == 0pt { none } else { spec.stroke + color }
  // Handgezeichnet: der Kasten selbst bleibt unsichtbar, seine Form zeichnet
  // `_hand-shape` als wackelnden Pfad darunter. Maße und Innenabstand
  // bleiben dieselben, damit das Layout stimmt.
  let drawn = th.hand == none
  let label = text(weight: weight, size: 1em * scale, fill: ink, node.label)
  let label = if th.font != none { text(font: th.font, label) } else { label }
  box(
    width: width,
    fill: if drawn { fill } else { none },
    stroke: if drawn { stroke } else { none },
    radius: if spec.underline and not root { 0pt } else { spec.radius },
    inset: opts.inset,
    label,
  )
}

// CeTZ misst `content` mit eigenen Schriftkanten (cap-height, baseline)
// und setzt den Kasten deshalb ein paar Punkt zu hoch. Ein Block mit der
// hier gemessenen festen Größe nimmt CeTZ diese Entscheidung ab: er wird
// genau dort zentriert, wo die Kanten und die handgezeichnete Form ihn
// erwarten.
#let _framed(t, body) = block(width: t.w, height: t.h, body)

// Füllung und Rahmen eines Knotens, wie `_nodebox` sie wählt -- für den
// handgezeichneten Pfad.
#let _node-paint(depth, color, opts) = {
  let th = opts.theme
  let root = depth == 0
  let spec = if root { th + th.root } else { th }
  let color = if root { opts.root-fill } else { color }
  let fill = _fill(spec.fill, color, opts)
  let stroke = if spec.underline and not root { none }
    else if spec.stroke == 0pt { none } else { spec.stroke + color }
  (fill: fill, stroke: stroke, radius: if spec.underline and not root { 0pt } else { spec.radius })
}

// --- Handgezeichnete Linien --------------------------------------------------
//
// Nach der TikZ-Dekoration `sketch` (tex.stackexchange.com/a/445690): ein
// Pfad wird in Schritten von `segment` pt abgelaufen, jeder Punkt senkrecht
// zum Pfad um `amplitude * sin(2πt/wavelength)` versetzt, wobei t einen
// Zufallslauf mit Schrittweite `randomness^rand` macht. `rand` kommt aus dem
// PGF-Generator (Park-Miller mit Schrage-Trick), also gibt derselbe Seed
// dasselbe Wackeln wie in LaTeX. Alles in Typst gerechnet: eine Mindmap hat
// nur einige Dutzend kurze Pfade, dafür braucht es kein Plugin.

#let _rng-next(z) = {
  let t = 69621 * calc.rem(z, 30845) - 23902 * calc.quo(z, 30845)
  if t < 0 { t + 2147483647 } else { t }
}
#let _rng-seed(seed) = {
  let z = calc.rem(seed, 2147483647)
  if z <= 0 { z + 2147483646 } else { z }
}
// Gleichverteilt auf [-1, 1], auf fünf Stellen quantisiert wie in TeX.
#let _rng-rand(z) = (calc.rem(z, 200001) - 100000) / 100000

// Wackelt einen Polygonzug (Punkte als (x, y) in pt, Zahlen). Liefert die
// neuen Punkte. `closed` schließt am Startpunkt.
#let _wobble(pts, hand, seed, closed: false) = {
  let pts = if closed { pts + (pts.first(),) } else { pts }
  let total = range(1, pts.len()).map(i => {
    let (ax, ay) = pts.at(i - 1)
    let (bx, by) = pts.at(i)
    calc.sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
  }).sum(default: 0.0)
  let z = _rng-seed(seed)
  let t = 0.0
  let out = (pts.first(),)
  let carry = 0.0     // Rest der Schrittweite aus dem vorigen Segment
  let done = 0.0      // bereits abgelaufene Länge
  let off = 0.0
  for i in range(1, pts.len()) {
    let (ax, ay) = pts.at(i - 1)
    let (bx, by) = pts.at(i)
    let (dx, dy) = (bx - ax, by - ay)
    let len = calc.sqrt(dx * dx + dy * dy)
    if len < 1e-9 { continue }
    let (tx, ty) = (dx / len, dy / len)
    let (nx, ny) = (-ty, tx)
    let d = carry
    while d <= len {
      z = _rng-next(z)
      t = calc.rem(t + calc.pow(hand.randomness, _rng-rand(z)), hand.wavelength)
      off = calc.sin(2 * calc.pi * t / hand.wavelength * 1rad) * hand.amplitude
      // Geschlossene Pfade: der Versatz klingt vor dem Schließen aus, sonst
      // bleibt am Startpunkt eine Kerbe.
      if closed { off *= calc.min(1, (total - done - d) / (4 * hand.segment)) }
      out.push((ax + tx * d + nx * off, ay + ty * d + ny * off))
      d += hand.segment
    }
    carry = d - len
    done += len
  }
  if closed { out.push(pts.first()) } else {
    let (ax, ay) = pts.at(pts.len() - 2)
    let (bx, by) = pts.last()
    let (dx, dy) = (bx - ax, by - ay)
    let len = calc.max(calc.sqrt(dx * dx + dy * dy), 1e-9)
    out.push((bx - dy / len * off, by + dx / len * off))
  }
  out
}

// Ein Seed aus Koordinaten, damit jede Linie anders wackelt, der Lauf aber
// reproduzierbar bleibt.
#let _seed(..xs) = {
  let h = 7
  for x in xs.pos() { h = calc.rem(h * 31 + int(calc.round(calc.abs(x) * 10)), 1000003) }
  h + 1
}

#let _pt(l) = if type(l) == length { l.pt() } else { float(l) }

// Kubische Bézierkurve als Polygonzug.
#let _flatten-bezier(p0, c0, c1, p1, n: 24) = range(n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  let (a, b, c, d) = (u * u * u, 3 * u * u * t, 3 * u * t * t, t * t * t)
  (a * p0.at(0) + b * c0.at(0) + c * c1.at(0) + d * p1.at(0),
   a * p0.at(1) + b * c0.at(1) + c * c1.at(1) + d * p1.at(1))
})

// Abgerundetes Rechteck um (cx, cy) als Polygonzug.
#let _rounded-rect(cx, cy, w, h, r, n: 6) = {
  let r = calc.min(r, w / 2, h / 2)
  if r <= 0.01 {
    return ((cx - w / 2, cy - h / 2), (cx + w / 2, cy - h / 2), (cx + w / 2, cy + h / 2), (cx - w / 2, cy + h / 2))
  }
  let corner(x, y, a0) = range(n + 1).map(i => {
    let a = a0 + 90deg * i / n
    (x + r * calc.cos(a), y + r * calc.sin(a))
  })
  let out = corner(cx + w / 2 - r, cy - h / 2 + r, -90deg)
  out += corner(cx + w / 2 - r, cy + h / 2 - r, 0deg)
  out += corner(cx - w / 2 + r, cy + h / 2 - r, 90deg)
  out += corner(cx - w / 2 + r, cy - h / 2 + r, 180deg)
  out
}

// Zeichnet einen Polygonzug (Zahlen in pt) handgezeichnet, in `passes` Lagen.
#let _hand-line(pts, st, hand, seed, closed: false, fill: none) = {
  import cetz.draw: line
  for p in range(hand.passes) {
    let q = _wobble(pts, hand, seed + 977 * p, closed: closed)
    line(..q, close: closed, stroke: st, fill: if p == 0 { fill } else { none })
  }
}

// Die Form eines Knotens als wackelnder Pfad, bei (cx, cy) in Längen.
#let _hand-shape(cx, cy, t, depth, color, opts) = {
  let paint = _node-paint(depth, color, opts)
  let (w, h) = (_pt(t.w), _pt(t.h))
  let r = if type(paint.radius) == ratio { calc.min(w, h) * paint.radius / 100% } else { _pt(paint.radius) }
  let pts = _rounded-rect(_pt(cx), _pt(cy), w, h, r)
  let st = if paint.stroke == none { none } else { paint.stroke }
  if st == none and paint.fill == none { return }
  _hand-line(pts, st, opts.theme.hand, _seed(_pt(cx), _pt(cy), w, h), closed: true, fill: paint.fill)
}

// Die Wörter einer Beschriftung, sofern sie nur aus Text besteht; sonst
// `none`. Gebraucht, um die Breite des längsten Wortes zu kennen: darunter
// darf ein Kasten nicht schrumpfen, sonst ragt das Wort heraus.
#let _words(c) = {
  if type(c) == str { return c.split() }
  if type(c) != content { return none }
  if c.func() == text { return c.text.split() }
  if c.func() == [ ].func() { return () }
  if c.func() == [].func() {
    let out = ()
    for p in c.children {
      let w = _words(p)
      if w == none { return none }
      out += w
    }
    return out
  }
  if c.has("body") { return _words(c.body) }
  none
}

// Misst einen Knoten. Ist die Beschriftung breiter als `max-width`, wird sie
// umgebrochen; danach sucht eine Intervallschachtelung die kleinste Breite,
// bei der der Umbruch nicht weiter wächst, damit der Kasten nicht breiter ist
// als sein längster Zeilenrest. Untere Grenze ist das längste Wort; lässt es
// sich nicht bestimmen, bleibt der Kasten bei `max-width`. Ist schon das
// längste Wort breiter als `max-width`, bleibt die natürliche Breite: ein
// abgeschnittenes Wort wäre schlimmer als ein breiter Kasten.
// Nur im context aufrufbar.
#let _measure-node(node, depth, color, opts) = {
  let natural = measure(_nodebox(node, depth, color, opts))
  if opts.max-width == none or natural.width <= opts.max-width {
    return (w: natural.width, h: natural.height, width: auto)
  }
  let words = _words(node.label)
  let floor = if words == none { opts.max-width } else {
    words.map(w => measure(_nodebox((label: w), depth, color, opts)).width).fold(0pt, calc.max)
  }
  if floor > opts.max-width {
    return (w: natural.width, h: natural.height, width: auto)
  }
  let wrapped = measure(_nodebox(node, depth, color, opts, width: opts.max-width))
  let lo = floor
  let hi = opts.max-width
  for _ in range(7) {
    let mid = (lo + hi) / 2
    let m = measure(_nodebox(node, depth, color, opts, width: mid))
    if m.height <= wrapped.height { hi = mid } else { lo = mid }
  }
  (w: hi, h: wrapped.height, width: hi)
}

// --- Layout ----------------------------------------------------------------
//
// Alle Anordnungen rechnen in zwei Achsen: die Hauptachse m, in die der
// Baum wächst, und die Querachse u, in der Geschwister nebeneinander
// stehen. Waagerechte Anordnungen (both, right, left, radial) haben m = x
// und u nach unten; senkrechte (down, up) haben m = y und u = x nach rechts.
// `dir` ist das Vorzeichen der Wachstumsrichtung auf m.

// Maße eines Kastens auf den beiden Achsen.
#let _sizes(m, vertical) = if vertical { (m: m.h, u: m.w) } else { (m: m.w, u: m.h) }

// Annotiert einen Teilbaum mit Maßen und legt seine Kinder. Ergebnis:
//   w, h, width   Maße des eigenen Kastens
//   size-m/-u     dieselben Maße auf den Achsen
//   kids          die Kinder, jedes mit `du`: Versatz auf u zur Kastenmitte
//   contour       je Tiefe unterhalb dieses Knotens (lo, hi): wie weit der
//                 Teilbaum auf dieser Ebene auf u vor und hinter die Mitte
//                 reicht (lo negativ)
//   lo, hi        dasselbe über alle Ebenen; size = hi - lo
//   extent        Ausdehnung des Teilbaums auf m, vom eigenen Kasten an
//
// Geschwister werden nicht als Blöcke gestapelt, sondern per Kontur: das
// nächste Kind rückt so weit auf, wie es auf keiner Ebene mit dem vorigen
// zusammenstößt. So bleibt ein Blatt ohne Kinder nah an seinem Nachbarn,
// auch wenn der einen tiefen Teilbaum hat.
#let _measure-tree(node, depth, color, opts, vertical) = {
  let m = _measure-node(node, depth, color, opts)
  let sz = _sizes(m, vertical)
  let kids = node.kids.map(k => _measure-tree(_norm(k), depth + 1, color, opts, vertical))

  let placed = ()
  let merged = ()   // Kontur der bisher gelegten Kinder, absolut auf u
  for k in kids {
    let u = 0pt
    if placed.len() > 0 {
      u = -1e9 * 1pt
      let d = 0
      while d < merged.len() and d < k.contour.len() {
        let limit = merged.at(d).hi + opts.sibling-gap - k.contour.at(d).lo
        if limit > u { u = limit }
        d += 1
      }
    }
    placed.push(k + (du: u))
    let d = 0
    while d < k.contour.len() {
      let c = (lo: u + k.contour.at(d).lo, hi: u + k.contour.at(d).hi)
      if d < merged.len() {
        merged.at(d) = (lo: calc.min(merged.at(d).lo, c.lo), hi: calc.max(merged.at(d).hi, c.hi))
      } else {
        merged.push(c)
      }
      d += 1
    }
  }

  // Eltern mittig zwischen erstem und letztem Kind.
  let shift = if placed.len() > 0 { (placed.first().du + placed.last().du) / 2 } else { 0pt }
  placed = placed.map(k => k + (du: k.du - shift))
  merged = merged.map(c => (lo: c.lo - shift, hi: c.hi - shift))

  let contour = ((lo: -sz.u / 2, hi: sz.u / 2),) + merged
  let lo = contour.map(c => c.lo).fold(0pt, calc.min)
  let hi = contour.map(c => c.hi).fold(0pt, calc.max)
  let extent = sz.m + if kids.len() > 0 { opts.level-gap + kids.map(k => k.extent).fold(0pt, calc.max) } else { 0pt }
  (
    node: node, depth: depth, color: color, kids: placed,
    w: m.w, h: m.h, width: m.width, size-m: sz.m, size-u: sz.u,
    contour: contour, lo: lo, hi: hi, size: hi - lo, extent: extent,
  )
}

// Verteilt die Äste der ersten Ebene auf rechts und links. Explizit gesetzte
// Seiten bleiben; die übrigen füllen erst rechts auf, bis die rechte Seite
// mindestens die Hälfte der Gesamthöhe hat, der Rest geht nach links.
// Die Reihenfolge (oben nach unten) bleibt auf beiden Seiten erhalten.
#let _split(trees, gap, layout) = {
  if layout == "right" { return (right: trees, left: ()) }
  if layout == "left" { return (right: (), left: trees) }
  let total = trees.map(t => t.size).sum(default: 0pt) + gap * calc.max(trees.len() - 1, 0)
  let right = ()
  let left = ()
  let right-h = 0pt
  let fixed-right = trees.filter(t => t.node.side == right).map(t => t.size).sum(default: 0pt)
  for t in trees {
    if t.node.side == right {
      right.push(t)
    } else if t.node.side == left {
      left.push(t)
    } else if right-h + fixed-right + t.size / 2 <= total / 2 {
      right.push(t)
      right-h += t.size + gap
    } else {
      left.push(t)
    }
  }
  (right: right, left: left)
}

// --- Zeichnen --------------------------------------------------------------

#let _stroke(depth, color, opts) = (
  paint: color,
  thickness: opts.thickness.at(calc.min(depth, opts.thickness.len() - 1)),
  cap: "round",
  join: "round",
  dash: opts.theme.dash,
)

// Von Achsenkoordinaten (m, u) nach (x, y).
#let _xy(m, u, vertical) = if vertical { (u, m) } else { (m, -u) }

// Zeichnet die Kante mit den Kontrollpunkten in der Führung des Themes;
// handgezeichnet wird sie erst zum Polygonzug und dann gewackelt.
#let _path(p0, c0, c1, p1, st, opts) = {
  import cetz.draw: bezier, line
  let hand = opts.theme.hand
  if hand == none {
    if opts.theme.edge == "curve" {
      bezier(p0, p1, c0, c1, stroke: st)
    } else if opts.theme.edge == "elbow" {
      line(p0, c0, c1, p1, stroke: st)
    } else {
      line(p0, p1, stroke: st)
    }
  } else {
    let n(p) = (_pt(p.at(0)), _pt(p.at(1)))
    let pts = if opts.theme.edge == "curve" {
      _flatten-bezier(n(p0), n(c0), n(c1), n(p1))
    } else if opts.theme.edge == "elbow" {
      (n(p0), n(c0), n(c1), n(p1))
    } else {
      (n(p0), n(p1))
    }
    _hand-line(pts, st, hand, _seed(..n(p0), ..n(p1)))
  }
}

// Eine Kante von p0 nach p1 in der Führung des Themes; die Kurve verläuft
// an beiden Enden parallel zur Hauptachse.
// (`st` statt `stroke`: cetz.draw bringt eine Funktion dieses Namens mit.)
#let _edge(p0, p1, st, opts, vertical) = {
  import cetz.draw: bezier, line
  let (x0, y0) = p0
  let (x1, y1) = p1
  let (c0, c1) = if vertical {
    let mid = (y0 + y1) / 2
    ((x0, mid), (x1, mid))
  } else {
    let mid = (x0 + x1) / 2
    ((mid, y0), (mid, y1))
  }
  _path(p0, c0, c1, p1, st, opts)
}

// Zeichnet einen Teilbaum, dessen Kasten mit der inneren Kante bei m und
// auf u zentriert bei u steht. Bei `underline` in waagerechter Anordnung
// liegen die Kanten auf der Grundlinie des Textes, sonst in der Kastenmitte.
#let _draw-tree(t, m, u, dir, opts, vertical) = {
  import cetz.draw: *
  let ul = opts.theme.underline and not vertical
  let anchor(tree, cu) = if ul { cu + tree.size-u / 2 } else { cu }
  let m0 = m + dir * t.size-m
  let m1 = m0 + dir * opts.level-gap
  for k in t.kids {
    let ku = u + k.du
    _edge(_xy(m0, anchor(t, u), vertical), _xy(m1, anchor(k, ku), vertical),
      _stroke(k.depth - 1, t.color, opts), opts, vertical)
    _draw-tree(k, m1, ku, dir, opts, vertical)
  }
  // Der Kasten nach den Kanten, damit er über deren Enden liegt.
  let (cx, cy) = _xy(m + dir * t.size-m / 2, u, vertical)
  if opts.theme.hand != none { _hand-shape(cx, cy, t, t.depth, t.color, opts) }
  content((cx, cy), _framed(t, _nodebox(t.node, t.depth, t.color, opts, width: t.width)))
  if opts.theme.underline {
    // Die Unterstreichung ist eine eigene Linie in der Stärke der Kante, die
    // in sie mündet; als Rahmen des Kastens hätte sie eine andere Stärke und
    // läge um ihre halbe Dicke versetzt.
    let st = _stroke(t.depth - 1, t.color, opts) + (cap: "butt")
    let (a, b) = if vertical {
      ((cx - t.w / 2, cy - t.h / 2), (cx + t.w / 2, cy - t.h / 2))
    } else {
      (_xy(m, anchor(t, u), false), _xy(m0, anchor(t, u), false))
    }
    if opts.theme.hand == none { line(a, b, stroke: st) }
    else { _hand-line(((_pt(a.at(0)), _pt(a.at(1))), (_pt(b.at(0)), _pt(b.at(1)))), st, opts.theme.hand, _seed(_pt(a.at(0)), _pt(a.at(1)))) }
  }
}

// Kante aus der Wurzel zu einem Ast: verlässt die Wurzel in Richtung des
// Astes und kommt parallel zur Hauptachse an.
#let _root-edge(p1, m-inner, st, opts, vertical) = {
  import cetz.draw: bezier
  if opts.theme.edge != "curve" or vertical {
    // Senkrecht ist die S-Kurve mit Wendepunkt auf halber Höhe am ruhigsten.
    _edge((0pt, 0pt), p1, st, opts, vertical)
  } else {
    let (x1, y1) = p1
    let (c0, c1) = if vertical { ((0pt, y1 * 0.9), (x1, m-inner)) } else { ((x1 * 0.9, 0pt), (m-inner, y1)) }
    _path((0pt, 0pt), c0, c1, p1, st, opts)
  }
}

// Stapelt Äste auf u, zentriert um 0, und zeichnet sie samt Wurzelkante.
#let _draw-stack(side, dir, m-inner, m1, opts, vertical) = {
  let total = side.map(t => t.size).sum(default: 0pt) + opts.branch-gap * calc.max(side.len() - 1, 0)
  let cu = -total / 2
  for t in side {
    let tu = cu - t.lo
    let au = if opts.theme.underline and not vertical { tu + t.size-u / 2 } else { tu }
    _root-edge(_xy(m1, au, vertical), dir * m-inner, _stroke(0, t.color, opts), opts, vertical)
    _draw-tree(t, m1, tu, dir, opts, vertical)
    cu += t.size + opts.branch-gap
  }
}

// Kreisförmig: jeder Ast bekommt einen Winkel, sein Kasten liegt auf einem
// Kreis um die Wurzel, sein Teilbaum wächst waagerecht nach außen. Der
// Radius beginnt bei `root-gap` und wächst, bis sich keine zwei Teilbäume
// mehr überschneiden.
#let _draw-radial(trees, rm, start, opts) = {
  let n = trees.len()
  if n == 0 { return }
  let angles = range(n).map(i => start - i * 360deg / n)
  let dirs = angles.map(a => if calc.cos(a) >= 0 { 1 } else { -1 })
  // Innere Kante des Astkastens: seitlich liegt sie auf dem Kreispunkt; je
  // näher der Ast an der Senkrechten steht, desto weiter rückt der Kasten
  // über den Punkt, bis er direkt darüber bzw. darunter zentriert ist.
  let inner(i, r) = {
    let (a, d, t) = (angles.at(i), dirs.at(i), trees.at(i))
    let f = 1 - calc.min(1, calc.abs(calc.cos(a)) / 0.4)
    (px: r * calc.cos(a) - d * t.w / 2 * f, py: r * calc.sin(a))
  }
  // Rechteck eines Teilbaums bei Radius r: (x0, x1, y0, y1)
  let rect(i, r) = {
    let (d, t) = (dirs.at(i), trees.at(i))
    let (px, py) = inner(i, r)
    (x0: calc.min(px, px + d * t.extent), x1: calc.max(px, px + d * t.extent),
     y0: py - t.hi, y1: py - t.lo)
  }
  let overlaps(r) = {
    let gap = opts.branch-gap
    let rects = range(n).map(i => rect(i, r))
    // auch die Wurzel freihalten
    rects.push((x0: -rm.w / 2 - opts.root-gap / 2, x1: rm.w / 2 + opts.root-gap / 2,
                y0: -rm.h / 2 - gap, y1: rm.h / 2 + gap))
    for i in range(rects.len()) {
      for j in range(i + 1, rects.len()) {
        let (a, b) = (rects.at(i), rects.at(j))
        if a.x0 < b.x1 + gap and b.x0 < a.x1 + gap and a.y0 < b.y1 + gap and b.y0 < a.y1 + gap {
          return true
        }
      }
    }
    false
  }
  let r = calc.max(rm.w, rm.h) / 2 + opts.root-gap
  let steps = 0
  while overlaps(r) and steps < 400 { r += 4pt; steps += 1 }

  for i in range(n) {
    let (a, d, t) = (angles.at(i), dirs.at(i), trees.at(i))
    let (px, py) = inner(i, r)
    let st = _stroke(0, t.color, opts)
    if calc.abs(calc.cos(a)) < 0.2 and opts.theme.edge == "curve" {
      // Ast fast senkrecht über oder unter der Wurzel: die Kante kommt von
      // oben bzw. unten in der Kastenmitte an, statt seitlich einzuhaken.
      let cx = px + d * t.w / 2
      let ty = if py < 0pt { py + t.h / 2 } else { py - t.h / 2 }
      _path((0pt, 0pt), (0pt, ty / 2), (cx, ty / 2), (cx, ty), st, opts)
    } else {
      let ay = if opts.theme.underline { py - t.size-u / 2 } else { py }
      _root-edge((px, ay), px - d * opts.root-gap / 2, st, opts, false)
    }
    _draw-tree(t, px, -py, d, opts, false)
  }
}

/// Zeichnet die Mindmap.
///
/// - title: Beschriftung der Wurzel. Fehlt sie, gilt das erste positionale
///   Argument als Wurzel.
/// - ..branches: Äste der ersten Ebene, jeweils `branch(...)`, Content, oder
///   eine Typst-Liste, deren Punkte zu Ästen und deren verschachtelte Listen
///   zu Kindern werden.
/// - theme: Name eines Themes (`soft`, `outline`, `blocks`, `lines`,
///   `sketch`, `bubbles`, `hand`, `scribble`, `marker`, `pencil`) oder ein Dictionary, das einzelne Felder eines
///   Themes überschreibt (`base:` wählt das Ausgangstheme, sonst `soft`).
/// - layout: Anordnung der Äste um die Wurzel:
///   `"both"` rechts und links, `"right"` oder `"left"` einseitig,
///   `"down"` oder `"up"` als Baum von oben bzw. unten, `"radial"` im Kreis.
/// - start: Nur `radial`: Winkel des ersten Astes; die weiteren folgen im
///   Uhrzeigersinn.
/// - wobble: Stärke des Wackelns der handgezeichneten Themes als Faktor auf
///   deren `amplitude`; `0` zeichnet gerade, `2` doppelt so unruhig.
/// - palette: Name einer Palette (`poster`, `pastel`, `grayscale`, `mono`,
///   `plain`, `earth`, `ocean`, `sunset`, `forest`, `neon`), ein Array von
///   Farben oder ein Dictionary `(colors: ..., root: ...)`. Die Farben
///   gehen der Reihe nach an Äste ohne eigene `color`.
/// - root-fill: Farbe der Wurzel; `auto` nimmt die der Palette.
/// - tint: Wie stark die Astfarbe für die Kästen aufgehellt wird.
/// - tint-min: Mindesthelligkeit (0 bis 1) getönter Füllungen; dunkle
///   Palettenfarben werden so weit weiter aufgehellt.
/// - ink: Schriftfarbe; `auto` wählt je Kasten nach der Helligkeit seiner
///   Füllung zwischen `ink-dark` und `ink-light`.
/// - ink-dark, ink-light: Schrift auf heller bzw. dunkler Füllung.
/// - ink-threshold: Helligkeit (0 bis 1), unter der die helle Schrift gilt.
/// - scale: Schriftgröße relativ zur Umgebung, je Ebene (Wurzel, Äste,
///   Blätter, ...); der letzte Wert gilt für alle tieferen Ebenen.
/// - bold-depth: Ebenen (ab der Wurzel), die fett gesetzt werden.
/// - thickness: Linienstärke je Ebene der Verbindung (Wurzel→Ast, Ast→Blatt,
///   ...); der letzte Wert gilt für alle tieferen Ebenen.
/// - level-gap: Abstand zwischen Eltern- und Kindkasten in Wachstumsrichtung.
/// - root-gap: Abstand zwischen Wurzel und Ästen; bei `radial` der
///   Mindestradius.
/// - sibling-gap: Abstand zwischen Geschwistern quer zur Wachstumsrichtung.
/// - branch-gap: Abstand zwischen den Ästen der ersten Ebene.
/// - max-width: Ab dieser Breite wird eine Beschriftung umgebrochen;
///   `none` bricht nie um.
/// - inset: Innenabstand der Kästen.
#let brainroot(
  ..branches,
  title: none,
  theme: "soft",
  layout: "both",
  start: 60deg,
  wobble: 1,
  palette: "poster",
  root-fill: auto,
  tint: 60%,
  tint-min: 0.8,
  ink: auto,
  ink-dark: black,
  ink-light: white,
  ink-threshold: 0.55,
  scale: (1.3, 1.1, 1.0),
  bold-depth: 2,
  thickness: (3pt, 1.5pt),
  level-gap: 40pt,
  root-gap: 80pt,
  sibling-gap: 8pt,
  branch-gap: 24pt,
  max-width: 5cm,
  inset: (x: 10pt, y: 6pt),
) = context {
  let layouts = ("both", "right", "left", "down", "up", "radial")
  assert(layout in layouts, message: "brainroot: layout muss eines von " + layouts.join(", ") + " sein")
  let vertical = layout in ("down", "up")
  let theme = _theme(theme)
  if theme.hand != none {
    theme.hand.amplitude *= wobble
  }
  let palette = _palette(palette)
  let root-fill = if root-fill == auto { palette.root } else { root-fill }
  let opts = (
    theme: theme, root-fill: root-fill, tint: tint, tint-min: tint-min,
    ink: ink, ink-dark: ink-dark, ink-light: ink-light, ink-threshold: ink-threshold,
    scale: scale, bold-depth: bold-depth, thickness: thickness,
    level-gap: level-gap, root-gap: root-gap, sibling-gap: sibling-gap, branch-gap: branch-gap,
    max-width: max-width, inset: inset,
  )
  let args = branches.pos()
  let root = title
  if root == none {
    assert(args.len() > 0, message: "brainroot: Wurzel fehlt (title: ... oder erstes Argument)")
    root = args.first()
    args = args.slice(1)
  }
  let root-node = branch(root)
  let rm = _measure-node(root-node, 0, black, opts)

  let trees = args.map(_expand).flatten().enumerate().map(((i, b)) => {
    let b = _norm(b)
    let c = if b.color != none { b.color } else { palette.colors.at(calc.rem(i, palette.colors.len())) }
    _measure-tree(b, 1, c, opts, vertical)
  })

  cetz.canvas(length: 1pt, {
    import cetz.draw: *
    if layout == "radial" {
      _draw-radial(trees, rm, start, opts)
    } else if vertical {
      let dir = if layout == "down" { -1 } else { 1 }
      _draw-stack(trees, dir, rm.h / 2, dir * (rm.h / 2 + root-gap), opts, true)
    } else {
      let sides = _split(trees, branch-gap, layout)
      for (dir, side) in ((1, sides.right), (-1, sides.left)) {
        _draw-stack(side, dir, rm.w / 2, dir * (rm.w / 2 + root-gap), opts, false)
      }
    }
    // Die Wurzel zuletzt, damit sie über den Linien liegt.
    if opts.theme.hand != none { _hand-shape(0pt, 0pt, rm, 0, black, opts) }
    content((0, 0), _framed(rm, _nodebox(root-node, 0, black, opts, width: rm.width)))
  })
}
