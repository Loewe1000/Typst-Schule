// Funktionsgraphen im Koordinatensystem.
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": plot
#import "@preview/eqalc:0.1.3": math-to-str, get-variable
#import "@preview/fancy-units:0.1.1": unit as fancy-unit
#import "@schule/physik:0.5.0": internal as physik-internal
#import "internal/check.typ": fail, check-named, check-value, check-type, show-value

// Zehn gut unterscheidbare Farben; Graphen, Flächen und Messreihen nehmen sie
// der Reihe nach.
#let palette = (
  rgb("#1F77B4"), // Blau
  rgb("#D62728"), // Rot
  rgb("#2CA02C"), // Grün
  rgb("#FF7F0E"), // Orange
  rgb("#9467BD"), // Violett
  rgb("#8C564B"), // Braun
  rgb("#E377C2"), // Pink
  rgb("#7F7F7F"), // Grau
  rgb("#BCBD22"), // Olivgrün
  rgb("#17BECF"), // Cyan
)

#let palette-names = (
  "#1F77B4",
  "#D62728",
  "#2CA02C",
  "#FF7F0E",
  "#9467BD",
  "#8C564B",
  "#E377C2",
  "#7F7F7F",
  "#BCBD22",
  "#17BECF",
)

#let corners = ("top-left", "top-right", "bottom-left", "bottom-right")
#let old-corners = (tl: "top-left", tr: "top-right", bl: "bottom-left", br: "bottom-right")

// Lage einer Punktbeschriftung → CeTZ-Anker des Textes.
#let mark-anchors = (
  "top-right": "south-west",
  "top-left": "south-east",
  "bottom-right": "north-west",
  "bottom-left": "north-east",
  "top": "south",
  "bottom": "north",
  "right": "west",
  "left": "east",
)

// Alter Schlüssel `anchor` in `marks`: alter Wert → neue Lage mit demselben Bild.
#let old-anchors = (
  "south-west": "top-right",
  "south-east": "top-left",
  "north-west": "bottom-right",
  "north-east": "bottom-left",
  "south": "top",
  "north": "bottom",
  "west": "right",
  "east": "left",
  "tl": "bottom-left",
  "top-left": "bottom-left",
  "tr": "bottom-right",
  "top-right": "bottom-right",
  "bl": "top-left",
  "bottom-left": "top-left",
  "br": "top-right",
  "bottom-right": "top-right",
  "t": "bottom",
  "top": "bottom",
  "b": "top",
  "bottom": "top",
  "l": "left",
  "left": "left",
  "r": "right",
  "right": "right",
)

#let is-number(value) = type(value) in (int, float)
#let is-term(value) = type(value) in (function, content)
#let is-pair(value) = type(value) == array and value.len() == 2 and value.all(is-number)

#let stop(message) = fail("mathematik", "graphen", message)

// Der Palettenindex (`color: 2`) entfällt; die Meldung nennt die Farbe, die er meinte.
#let check-accent(name, value, allowed: (color, auto)) = {
  if type(value) == int {
    let hex = palette-names.at(calc.rem-euclid(value - 1, palette.len()))
    stop(
      "`"
        + name
        + ": "
        + str(value)
        + "` – der Palettenindex entfällt, die Farbe selbst schreiben: `"
        + name
        + ": rgb(\""
        + hex
        + "\")`",
    )
  }
  check-type("mathematik", "graphen", name, value, allowed)
}

// Ein Parameter, der ein Array aus Dictionaries erwartet, nimmt keine Kurzform an.
#let check-entries(name, value, example) = {
  if type(value) == dictionary {
    stop("`" + name + "` erwartet ein Array, bekam ein einzelnes Dictionary – in ein Array setzen: `" + name + ": ((…),)`")
  }
  check-type("mathematik", "graphen", name, value, array, example: example)
}

// „Wert je Ziel“: ein Wert für beide Achsen oder `(x: …, y: …)`.
#let axis-pair(value, default) = {
  if type(value) == dictionary {
    check-named("mathematik", "graphen", value, allowed: ("x", "y"), what: "Schlüssel")
    (x: value.at("x", default: default), y: value.at("y", default: default))
  } else {
    (x: value, y: value)
  }
}

// Zahl in Zentimetern als Text, zum Beispiel `7.5cm`.
#let centimeters(value) = str(calc.round(value, digits: 3)) + "cm"

// Alte Parameter von `graphen`, deren Abhilfe vom Wert abhängt. Alles Übrige
// meldet `check-named` danach.
#let check-old-arguments(named) = {
  let shown(name) = "`" + name + ": " + show-value(named.at(name)) + "`"

  if "size" in named {
    let size = named.size
    let scale = named.at("scale", default: 1)
    if size == none {
      stop("`size: none` gibt es nicht mehr – Argument löschen, `width: auto, height: auto` ist die Vorgabe")
    }
    if is-number(scale) and (is-number(size) or is-pair(size)) {
      let (width, height) = if is-number(size) { (size, size) } else { size }
      stop(
        shown("size")
          + (if "scale" in named { " mit " + shown("scale") } else { "" })
          + " heißt jetzt `width: "
          + centimeters(width * scale)
          + ", height: "
          + centimeters(height * scale)
          + "`",
      )
    }
  }
  if "scale" in named and "size" not in named {
    stop(
      shown("scale")
        + " gibt es nicht mehr – die Größe steht als Länge in `width` und `height` (bisher 1cm je Achseneinheit mal `scale`)",
    )
  }

  for axis in ("x", "y") {
    if axis in named {
      let value = named.at(axis)
      if value == auto {
        stop(shown(axis) + " gibt es nicht mehr – Argument löschen, `domain: auto` ist die Vorgabe")
      }
      if value == (-5, 5) and ("datensätze" in named or "datensaetze" in named or "datasets" in named) {
        stop(shown(axis) + " galt zusammen mit Datensätzen als nicht gesetzt – Argument löschen")
      }
      stop(shown(axis) + " heißt jetzt `domain: (" + axis + ": " + show-value(value) + ")`")
    }
    let step-name = axis + "-step"
    if step-name in named {
      let value = named.at(step-name)
      if value == none {
        stop(shown(step-name) + " gibt es nicht mehr – Argument löschen, die Achse folgt `step`")
      }
      stop(shown(step-name) + " heißt jetzt `step: (" + axis + ": " + show-value(value) + ")`")
    }
    let grid-name = axis + "-grid"
    if grid-name in named {
      let value = named.at(grid-name)
      if value == none {
        stop(shown(grid-name) + " gibt es nicht mehr – Argument löschen, die Achse folgt `grid-lines`")
      }
      let new = if value == "both" { "\"all\"" } else if value in ("none", false) { "none" } else if value == true {
        "\"major\""
      } else { show-value(value) }
      stop(shown(grid-name) + " heißt jetzt `grid-lines: (" + axis + ": " + new + ")`")
    }
  }

  if "grid" in named {
    let value = named.grid
    let new = if value == "both" { "\"all\"" } else if value in ("none", false, none) { "none" } else if value == true {
      "\"major\""
    } else { show-value(value) }
    stop(shown("grid") + " heißt jetzt `grid-lines: " + new + "`")
  }
}

// Zerlegt einen stroke in ein Dictionary seiner gesetzten Felder.
#let stroke-fields(value) = {
  let resolved = std.stroke(value)
  let fields = (:)
  for (key, field) in (
    paint: resolved.paint,
    thickness: resolved.thickness,
    cap: resolved.cap,
    join: resolved.join,
    dash: resolved.dash,
    miter-limit: resolved.miter-limit,
  ) {
    if field != auto { fields.insert(key, field) }
  }
  fields
}

// Macht aus Formelinhalt (`$x^2$`) eine Funktion. Ergänzt `math-to-str` um
// deutsche Schulschreibweisen: Dezimalkomma (0,5 x), Malpunkt, der weggelassen
// wird (x e^x, x(x-2), (x-1)(x+2)), und Beträge (|x|).
#let to-function(term) = {
  if type(term) != content { return term }
  let source = math-to-str(term)
    .replace(regex("(\d)\s*,\s*(\d)"), m => m.captures.at(0) + "." + m.captures.at(1))
    .replace(regex("\|([^|]*)\|"), m => "calc.abs(" + m.captures.at(0) + ")")
    // math-to-str klebt Variable und Funktion zusammen: „xcalc.sin(x)“
    .replace(regex("\b([a-zA-Z])(calc\.)"), m => m.captures.at(0) + "*" + m.captures.at(1))
  // Weggelassenes Mal: einzelne Variable oder `)` vor Variable, `(` oder `calc.`
  // (zweimal, damit auch überlappende Fälle wie „x x x“ erfasst werden)
  for _ in range(2) {
    source = source.replace(
      regex("(\b[a-zA-Z]\b|\))\s*(calc\.|\(|\b[a-zA-Z]\b)"),
      m => m.captures.at(0) + "*" + m.captures.at(1),
    )
  }
  let variable = get-variable(source)
  x => eval("let " + variable + " = " + repr(float(x)) + "; " + source)
}

// Teilt einen Bereich an Polstellen (Vorzeichenwechsel mit großem Sprung),
// damit keine senkrechten Verbindungslinien entstehen.
#let pole-segments(f, domain, span, count: 400) = {
  let (low, high) = domain
  let width = (high - low) / count
  // Leicht versetzt abtasten, damit z. B. x = 0 bei 1/x nicht genau getroffen wird
  let xs = range(count + 1).map(i => calc.min(low + (i + 1e-6) * width, high))
  let ys = xs.map(f)
  let segments = ()
  let start = low
  for i in range(count) {
    let (ya, yb) = (ys.at(i), ys.at(i + 1))
    if ya * yb < 0 and calc.abs(yb - ya) > 2 * span {
      // Polstelle eingrenzen
      let (a, b, fa) = (xs.at(i), xs.at(i + 1), ya)
      for _ in range(40) {
        let middle = (a + b) / 2
        let fm = f(middle)
        if fm * fa > 0 {
          a = middle
          fa = fm
        } else { b = middle }
      }
      if a > start { segments.push((start, a)) }
      start = b
    }
  }
  if high > start { segments.push((start, high)) }
  segments
}

// Schnittstelle zweier Funktionen in einem Intervall (Bisektion); `none`,
// wenn es dort keinen Vorzeichenwechsel gibt.
#let find-intersection(f, g, low, high, tolerance: 0.0001, steps: 50) = {
  let difference(x) = f(x) - g(x)
  let a = low
  let b = high
  let fa = difference(a)
  let fb = difference(b)

  if fa * fb > 0 { return none }
  if calc.abs(fa) < tolerance { return a }
  if calc.abs(fb) < tolerance { return b }

  let step = 0
  while calc.abs(b - a) > tolerance and step < steps {
    let middle = (a + b) / 2
    let fm = difference(middle)
    if calc.abs(fm) < tolerance { return middle }
    if fm * fa < 0 {
      b = middle
      fb = fm
    } else {
      a = middle
      fa = fm
    }
    step += 1
  }
  (a + b) / 2
}

// Alle Schnittstellen zweier Funktionen in einem Intervall, durch Abtasten.
#let find-intersections(f, g, low, high, count: 100) = {
  let found = ()
  let width = (high - low) / count
  for i in range(count) {
    let a = low + i * width
    let hit = find-intersection(f, g, a, a + width, tolerance: 0.0001)
    if hit != none and not found.any(x => calc.abs(x - hit) < 0.001) {
      found.push(hit)
    }
  }
  found
}

// Ein Positionsargument von `graphen` → (term, domain, stroke, labels).
#let resolve-graph(definition, index, base-stroke) = {
  let default-accent = palette.at(calc.rem(index, palette.len()))
  if is-term(definition) {
    let fields = base-stroke
    if "paint" not in fields { fields.insert("paint", default-accent) }
    return (term: to-function(definition), domain: auto, stroke: fields, labels: ())
  }
  if type(definition) != dictionary {
    stop(
      "Positionsargument `"
        + show-value(definition)
        + "` ("
        + repr(type(definition))
        + ") ist kein Graph – einen Term (`$x^2$`), eine Funktion (`x => x * x`) oder ein Dictionary (`(term: $x^2$, accent: red)`) übergeben",
    )
  }
  check-named(
    "mathematik",
    "graphen",
    definition,
    renamed: (color: "accent", clr: "accent", label: "labels"),
    allowed: ("term", "domain", "stroke", "accent", "labels"),
    what: "Schlüssel",
  )
  if "term" not in definition {
    stop("Graph ohne `term` – den Funktionsterm angeben: `(term: $x^2$)`")
  }
  if not is-term(definition.term) {
    check-type("mathematik", "graphen", "term", definition.term, (content, function), example: "$x^2$")
  }
  let domain = definition.at("domain", default: auto)
  if domain != auto and not is-pair(domain) {
    stop("`domain: " + show-value(domain) + "` ist kein Bereich – zwei Zahlen schreiben: `domain: (0, 3)`")
  }
  let accent = definition.at("accent", default: auto)
  check-accent("accent", accent)

  let fields = if "stroke" in definition {
    check-type("mathematik", "graphen", "stroke", definition.stroke, (length, color, stroke, dictionary), example: "2pt + red")
    let own = stroke-fields(definition.stroke)
    // `accent` gewinnt gegen die Farbe im Strich (wie `color` in 0.0.2).
    if accent != auto { own.insert("paint", accent) }
    own
  } else {
    let own = base-stroke
    if accent != auto {
      own.insert("paint", accent)
    } else if "paint" not in own {
      own.insert("paint", default-accent)
    }
    own
  }

  let labels = definition.at("labels", default: ())
  check-entries("labels", labels, "((x: 2, body: $f$),)")
  let resolved-labels = ()
  for label in labels {
    if type(label) != dictionary {
      stop(
        "Eintrag `"
          + show-value(label)
          + "` in `labels` eines Graphen ist kein Dictionary – zum Beispiel `(x: 2, body: $f$)`",
      )
    }
    check-named(
      "mathematik",
      "graphen",
      label,
      renamed: (content: "body", size: "font-size", color: "text-fill", padding: "distance", angle: "rotation"),
      allowed: ("x", "body", "position", "fill", "font-size", "text-fill", "distance", "rotation"),
      what: "Schlüssel",
    )
    if "x" not in label {
      stop("Beschriftung eines Graphen ohne `x` – die Stelle angeben: `(x: 2, body: $f$)`")
    }
    if "body" not in label {
      stop("Beschriftung eines Graphen ohne `body` – den Text angeben: `(x: 2, body: $f$)`")
    }
    check-type("mathematik", "graphen", "x", label.x, (int, float), example: "(x: 2, body: $f$)")
    let position = label.at("position", default: "top-right")
    check-value("mathematik", "graphen", "position", position, corners, renamed: old-corners)
    let font-size = label.at("font-size", default: auto)
    check-type("mathematik", "graphen", "font-size", font-size, (length, auto))
    let text-fill = label.at("text-fill", default: auto)
    check-accent("text-fill", text-fill)
    let distance = label.at("distance", default: 1mm)
    check-type("mathematik", "graphen", "distance", distance, length)
    let rotation = label.at("rotation", default: 0deg)
    check-type("mathematik", "graphen", "rotation", rotation, angle)
    resolved-labels.push((
      x: label.x,
      body: label.body,
      position: position,
      fill: label.at("fill", default: white),
      font-size: font-size,
      text-fill: if text-fill != auto { text-fill } else { fields.at("paint", default: black) },
      distance: distance,
      rotation: rotation,
    ))
  }

  (term: to-function(definition.term), domain: domain, stroke: fields, labels: resolved-labels)
}

// Ein Eintrag in `areas` → (domain, lower, upper, fill).
#let resolve-area(definition, index, x-range, sample-count) = {
  if type(definition) != dictionary {
    stop(
      "Eintrag `"
        + show-value(definition)
        + "` in `areas` ist kein Dictionary – zum Beispiel `(term: $x^2$, domain: (0, 2))` oder `(between: ($f$, $g$), domain: \"intersections\")`",
    )
  }
  if "auto-domain" in definition {
    if definition.at("auto-domain") == false {
      stop("`auto-domain: false` gibt es nicht mehr – Schlüssel löschen")
    }
    stop("`auto-domain: true` heißt jetzt `domain: \"intersections\"`")
  }
  check-named(
    "mathematik",
    "graphen",
    definition,
    renamed: (color: "fill", clr: "fill"),
    allowed: ("term", "between", "domain", "fill"),
    what: "Schlüssel",
  )
  if "term" in definition and "between" in definition {
    stop("`term` und `between` zugleich in einem Eintrag von `areas` – nur eines schreiben")
  }
  if "term" not in definition and "between" not in definition {
    stop(
      "Eintrag in `areas` ohne `term` und ohne `between` – `(term: $f$)` für die Fläche zur x-Achse oder `(between: ($f$, $g$))` schreiben",
    )
  }
  let (lower, upper) = if "between" in definition {
    let between = definition.between
    if type(between) != array or between.len() != 2 or not between.all(is-term) {
      stop("`between: " + show-value(between) + "` – zwei Terme oder Funktionen angeben: `between: ($f$, $g$)`")
    }
    (to-function(between.at(0)), to-function(between.at(1)))
  } else {
    if not is-term(definition.term) {
      check-type("mathematik", "graphen", "term", definition.term, (content, function), example: "$x^2$")
    }
    (x => 0, to-function(definition.term))
  }

  let fill = definition.at(
    "fill",
    default: palette.at(calc.rem(index, palette.len())).saturate(100%).lighten(60%).transparentize(50%),
  )
  check-accent("fill", fill, allowed: (color, gradient, tiling))

  let domain = definition.at("domain", default: auto)
  if type(domain) == str {
    check-value(
      "mathematik",
      "graphen",
      "domain",
      domain,
      (auto, "intersections", array),
      renamed: ("auto": "intersections"),
    )
    // Grenzen sind die äußersten Schnittstellen im x-Bereich
    let hits = find-intersections(lower, upper, x-range.at(0), x-range.at(1), count: sample-count)
    domain = if hits.len() >= 2 {
      let sorted = hits.sorted()
      (sorted.first(), sorted.last())
    } else if hits.len() == 1 {
      // Nur eine Schnittstelle: bis zum näheren Rand des x-Bereichs
      let middle = (x-range.at(0) + x-range.at(1)) / 2
      if middle < hits.at(0) { (x-range.at(0), hits.at(0)) } else { (hits.at(0), x-range.at(1)) }
    } else {
      x-range
    }
  } else if domain == auto {
    domain = x-range
  } else if not is-pair(domain) {
    stop(
      "`domain: "
        + show-value(domain)
        + "` in `areas` ist kein Bereich – zwei Zahlen (`domain: (0, 3)`) oder `domain: \"intersections\"` schreiben",
    )
  }

  (domain: domain, lower: lower, upper: upper, fill: fill)
}

// Ein Eintrag in `marks` → (at, body, anchor, distance, symbol, stroke, fill).
#let resolve-mark(definition) = {
  if type(definition) == array {
    if is-pair(definition) {
      stop(
        "Eintrag `"
          + show-value(definition)
          + "` in `marks` ist kein Dictionary – `(at: "
          + show-value(definition)
          + ")` schreiben",
      )
    }
    if definition.len() == 2 and is-pair(definition.at(0)) {
      stop(
        "Eintrag `"
          + show-value(definition)
          + "` in `marks` ist kein Dictionary – `(at: "
          + show-value(definition.at(0))
          + ", body: […])` schreiben",
      )
    }
  }
  if type(definition) != dictionary {
    stop("Eintrag `" + show-value(definition) + "` in `marks` ist kein Dictionary – zum Beispiel `(at: (1, 2), body: [P])`")
  }
  if "anchor" in definition {
    let old = definition.anchor
    if type(old) == str and old in old-anchors {
      stop("`anchor: " + show-value(old) + "` heißt jetzt `position: \"" + old-anchors.at(old) + "\"`")
    }
    stop(
      "`anchor: "
        + show-value(old)
        + "` gibt es nicht mehr – die Lage der Beschriftung steht in `position`: "
        + mark-anchors.keys().map(key => "`\"" + key + "\"`").join(", "),
    )
  }
  if "position" in definition and type(definition.position) == array {
    stop("`position` heißt in `marks` jetzt `at`")
  }
  check-named(
    "mathematik",
    "graphen",
    definition,
    renamed: (pos: "at", content: "body", label: "body", padding: "distance", color: "accent", clr: "accent"),
    allowed: ("at", "body", "position", "distance", "symbol", "stroke", "fill", "accent"),
    what: "Schlüssel",
  )
  if "at" not in definition {
    stop("Eintrag in `marks` ohne `at` – den Punkt angeben: `(at: (1, 2), body: [P])`")
  }
  if not is-pair(definition.at("at")) {
    stop("`at: " + show-value(definition.at("at")) + "` ist kein Punkt – zwei Zahlen schreiben: `at: (1, 2)`")
  }
  let position = definition.at("position", default: "top-right")
  check-value("mathematik", "graphen", "position", position, mark-anchors.keys())
  let distance = definition.at("distance", default: 2mm)
  check-type("mathematik", "graphen", "distance", distance, length)
  let symbol = definition.at("symbol", default: "x")
  check-type("mathematik", "graphen", "symbol", symbol, str, example: "\"x\", \"o\" oder \"square\"")

  let mark-stroke = definition.at("stroke", default: black)
  let mark-fill = definition.at("fill", default: none)
  if "accent" in definition {
    check-accent("accent", definition.accent, allowed: (color,))
    mark-stroke = definition.accent
    if mark-fill == none { mark-fill = definition.accent }
  }

  (
    at: definition.at("at"),
    body: definition.at("body", default: none),
    anchor: mark-anchors.at(position),
    distance: distance,
    symbol: symbol,
    stroke: mark-stroke,
    // Ohne eigene Füllung trägt das Symbol die Farbe seines Rands.
    fill: if mark-fill != none { mark-fill } else {
      let paint = std.stroke(mark-stroke).paint
      if paint == auto { black } else { paint }
    },
  )
}

// Eine Messreihe aus `datasets`: Datensatz aus physik oder Zahlenreihe.
#let resolve-series(value, axis) = {
  if type(value) == array {
    return (name: if axis == "x" { $x$ } else { $y$ }, unit: none, prefix: none, values: value)
  }
  if type(value) == dictionary and "values" in value {
    return value
  }
  if type(value) == dictionary and "werte" in value {
    stop(
      "`"
        + axis
        + "` ist ein Datensatz aus physik 0.0.2 (Schlüssel `werte`) – `datensatz` aus `@schule/physik:0.5.0` benutzen",
    )
  }
  stop(
    "`"
      + axis
      + ": "
      + show-value(value)
      + "` ist keine Messreihe – einen `datensatz` aus physik oder ein Array aus Zahlen angeben",
  )
}

// Ein Eintrag in `datasets` → (x, y, symbol, style, accent).
#let resolve-dataset(definition, index) = {
  if type(definition) != dictionary {
    stop(
      "Eintrag `"
        + show-value(definition)
        + "` in `datasets` ist kein Dictionary – zum Beispiel `(x: t, y: s)` oder `(x: (0, 1, 2), y: (0, 1, 4))`",
    )
  }
  if type(definition.at("marker", default: none)) == dictionary {
    stop(
      "`marker` als Dictionary gibt es nicht mehr – das Symbol steht in `symbol`, `fill` und `stroke` stehen direkt im Eintrag: `(x: …, y: …, symbol: \"o\", fill: white)`",
    )
  }
  check-named(
    "mathematik",
    "graphen",
    definition,
    renamed: (marker: "symbol", "mark-style": "fill: …, stroke: …", color: "accent", clr: "accent"),
    allowed: ("x", "y", "symbol", "fill", "stroke", "accent"),
    what: "Schlüssel",
  )
  if "x" not in definition or "y" not in definition {
    stop("Eintrag in `datasets` ohne `x` oder `y` – beide Messreihen angeben: `(x: t, y: s)`")
  }
  let accent = definition.at("accent", default: auto)
  check-accent("accent", accent)
  if accent == auto { accent = palette.at(calc.rem(index, palette.len())) }
  let symbol = definition.at("symbol", default: "x")
  check-type("mathematik", "graphen", "symbol", symbol, str, example: "\"x\", \"o\" oder \"square\"")

  let style = (fill: accent, stroke: accent + 1.25pt)
  if "fill" in definition { style.insert("fill", definition.fill) }
  if "stroke" in definition { style.insert("stroke", definition.stroke) }

  (
    x: resolve-series(definition.x, "x"),
    y: resolve-series(definition.y, "y"),
    symbol: symbol,
    style: style,
  )
}

// Achsenbeschriftung aus einem Datensatz: „Name in Einheit“.
#let series-label(series, fallback) = {
  let name = if series.at("name", default: none) == none { fallback } else { series.name }
  let unit = series.at("unit", default: none)
  if unit != none and unit != "" {
    [#name in #fancy-unit(per-mode: "fraction")[#unit]]
  } else {
    name
  }
}

/// Zeichnet Funktionsgraphen in ein Koordinatensystem.
///
/// Die Positionsargumente sind die Graphen: ein Term im Formelsatz (`$x^2$`),
/// eine Funktion (`x => x * x`) oder ein Dictionary mit den Schlüsseln
/// `term`, `domain` (Bereich `(von, bis)`), `stroke`, `accent` (Farbe von
/// Linie und Beschriftung, gewinnt gegen eine Farbe in `stroke`; `auto` =
/// Palettenfarbe nach Position) und `labels`
/// (Array aus Beschriftungen mit `x`, `body`, `position`, `fill`, `font-size`,
/// `text-fill`, `distance`, `rotation`).
///
/// ```typ
/// #graphen($x^2$, $2 x - 1$, domain: (x: (-3, 3), y: (-2, 10)))
/// ```
///
/// - width (auto, length): Breite des Koordinatensystems; `auto` = 1cm je Einheit der x-Achse
/// - height (auto, length): Höhe des Koordinatensystems; `auto` = 1cm je Einheit der y-Achse
/// - domain (auto, array, dictionary): Achsenbereich `(von, bis)` für beide Achsen oder je Achse als `(x: …, y: …)`; `auto` = `(-5, 5)`, mit `datasets` deren Bereich
/// - step (auto, int, float, array, dictionary, none): Schrittweite der Teilstriche für beide Achsen oder je Achse als `(x: …, y: …)`; ein Array ist `(Hauptschritt, Nebenschritt)`, `none` = keine Teilstriche, `auto` = 1, mit `datasets` wählt das Paket
/// - labels (auto, array): Achsenbeschriftungen `(x-Achse, y-Achse)`; ein Eintrag ist Inhalt, Text, `none` oder `auto` ($x$ und $y$, mit `datasets` deren Name und Einheit)
/// - grid-lines (none, str, dictionary): Gitterlinien für beide Achsen oder je Achse als `(x: …, y: …)`: `"all"`, `"major"`, `"minor"` oder `none`
/// - stroke (length, color, stroke, dictionary): Strich aller Graphen; nennt er keine Farbe, bekommt jeder Graph seine Palettenfarbe
/// - sample-count (int): Stützstellen je Graph und Fläche; mehr ergibt glattere Kurven
/// - areas (array): Flächen als Array aus Dictionaries mit `term` (Fläche zwischen Graph und x-Achse) oder `between` (zwei Terme), dazu `domain` (`(von, bis)`, `auto` = der in `domain` angegebene x-Bereich, sonst `(-5, 5)`, oder `"intersections"` = zwischen den äußersten Schnittstellen) und `fill`
/// - datasets (array): Messreihen als Array aus Dictionaries mit `x` und `y` (je ein `datensatz` aus physik oder ein Array aus Zahlen), dazu `symbol`, `fill`, `stroke` und `accent` (Farbe für Rand und Füllung des Symbols)
/// - marks (array): beschriftete Punkte als Array aus Dictionaries mit `at` (Punkt `(x, y)`), `body`, `position` (Lage der Beschriftung: `"top-right"`, `"top-left"`, `"bottom-right"`, `"bottom-left"`, `"top"`, `"bottom"`, `"left"`, `"right"`), `distance`, `symbol`, `stroke`, `fill` und `accent`
/// - annotations (array, none): CeTZ-Zeichenbefehle in den Koordinaten des Diagramms, zum Beispiel `{ draw.line((0, 0), (2, 3)) }` mit `draw` aus cetz
/// - ..args (arguments): Positionsargumente sind die Graphen; benannte Argumente nimmt der Sink nicht an, er fängt nur alte Namen ab
/// -> content
#let graphen(
  width: auto,
  height: auto,
  domain: auto,
  step: auto,
  labels: auto,
  grid-lines: "all",
  stroke: 1.5pt,
  sample-count: 200,
  areas: (),
  datasets: (),
  marks: (),
  annotations: (),
  ..args,
) = {
  // 1. Sink: alte Namen und unbekannte Parameter
  check-old-arguments(args.named())
  check-named(
    "mathematik",
    "graphen",
    args,
    renamed: (
      size: "width: …, height: …",
      "x-label": "labels: (…, auto)",
      "y-label": "labels: (auto, …)",
      "line-width": "stroke",
      samples: "sample-count",
      fills: "areas",
      datensaetze: "datasets",
    ),
    allowed: (
      "width",
      "height",
      "domain",
      "step",
      "labels",
      "grid-lines",
      "stroke",
      "sample-count",
      "areas",
      "datasets",
      "marks",
      "annotations",
    ),
  )

  // 2. Typen und Werte
  for (name, value) in (width: width, height: height) {
    check-type("mathematik", "graphen", name, value, (length, auto), example: "8cm")
    if value != auto and value.em != 0 {
      stop("`" + name + ": " + show-value(value) + "` – eine Länge ohne `em` angeben, zum Beispiel `8cm`")
    }
  }
  check-type("mathematik", "graphen", "domain", domain, (array, dictionary, auto), example: "(-5, 5) oder (x: (0, 10))")
  let domains = axis-pair(domain, auto)
  for (axis, value) in domains {
    if value != auto and not is-pair(value) {
      stop("`domain` der " + axis + "-Achse ist `" + show-value(value) + "` – zwei Zahlen schreiben: `(-5, 5)`")
    }
  }
  check-type(
    "mathematik",
    "graphen",
    "step",
    step,
    (int, float, array, dictionary, none, auto),
    example: "1, (1, 0.5) oder (x: 2)",
  )
  let steps = axis-pair(step, auto)
  for (axis, value) in steps {
    if value != auto and value != none and not is-number(value) and not is-pair(value) {
      stop(
        "`step` der "
          + axis
          + "-Achse ist `"
          + show-value(value)
          + "` – eine Zahl, `(Hauptschritt, Nebenschritt)`, `none` oder `auto` schreiben",
      )
    }
  }
  check-type("mathematik", "graphen", "labels", labels, (array, auto), example: "([$t$ in s], [$s$ in m])")
  if labels != auto and labels.len() != 2 {
    stop(
      "`labels` hat "
        + str(labels.len())
        + (if labels.len() == 1 { " Eintrag" } else { " Einträge" })
        + " – genau zwei schreiben: `labels: (x-Achse, y-Achse)`, zum Beispiel `([$t$], auto)`",
    )
  }
  if labels != auto {
    for entry in labels {
      check-type("mathematik", "graphen", "labels", entry, (content, str, auto, none), example: "([$t$ in s], auto)")
    }
  }
  let grid-values = (none, "major", "minor", "all")
  let grid-renamed = (both: "all", "true": "major")
  check-value("mathematik", "graphen", "grid-lines", grid-lines, grid-values + (dictionary,), renamed: grid-renamed)
  let grids = axis-pair(grid-lines, "all")
  for (axis, value) in grids {
    check-value("mathematik", "graphen", "grid-lines." + axis, value, grid-values, renamed: grid-renamed)
  }
  check-type("mathematik", "graphen", "stroke", stroke, (length, color, std.stroke, dictionary), example: "1.5pt")
  check-type("mathematik", "graphen", "sample-count", sample-count, int)
  if is-term(areas) or (type(areas) == array and areas.len() == 2 and areas.all(is-term)) {
    stop(
      "die Kurzform von `areas` gibt es nicht mehr – ausschreiben: `areas: ((term: $f$, domain: \"intersections\"),)` oder `areas: ((between: ($f$, $g$), domain: \"intersections\"),)`",
    )
  }
  check-entries("areas", areas, "((term: $x^2$, domain: (0, 2)),)")
  if (
    type(datasets) == array
      and datasets.len() == 2
      and datasets.all(entry => type(entry) == array or (type(entry) == dictionary and "x" not in entry))
  ) {
    stop("die Kurzform `(x-Werte, y-Werte)` von `datasets` gibt es nicht mehr – `datasets: ((x: …, y: …),)` schreiben")
  }
  check-entries("datasets", datasets, "((x: t, y: s),)")
  if is-pair(marks) {
    stop("`marks: " + show-value(marks) + "` ist ein nacktes Zahlenpaar – `marks: ((at: " + show-value(marks) + "),)` schreiben")
  }
  check-entries("marks", marks, "((at: (1, 2), body: [P]),)")
  check-type("mathematik", "graphen", "annotations", annotations, (array, none), example: "{ draw.line((0, 0), (2, 3)) }")

  // Dezimalkomma in den Achsenzahlen
  show math.equation: it => {
    show regex("\d+\.\d+"): number => number.text.replace(".", ",")
    it
  }

  // 3. Messreihen: Punkte, Achsenbereich und Achsenbeschriftung
  let series = datasets.enumerate().map(((index, definition)) => resolve-dataset(definition, index))
  let point-sets = ()
  let data-ranges = (x: none, y: none)
  let data-labels = (x: none, y: none)
  if series.len() > 0 {
    for axis in ("x", "y") {
      let units = series.map(entry => entry.at(axis).at("unit", default: none))
      if units.dedup().len() > 1 {
        stop(
          "die "
            + axis
            + "-Messreihen haben verschiedene Einheiten ("
            + units.dedup().map(unit => "`" + show-value(unit) + "`").join(", ")
            + ") – alle in derselben Einheit angeben",
        )
      }
      data-labels.insert(axis, series-label(series.first().at(axis), if axis == "x" { $x$ } else { $y$ }))
    }
    let all-values = (x: (), y: ())
    for entry in series {
      // Werte mit Vorsatz (`prefix: "m"`) in die Einheit der Achse umrechnen
      let x-factor = physik-internal.prefix-factor(entry.x.at("prefix", default: none))
      let y-factor = physik-internal.prefix-factor(entry.y.at("prefix", default: none))
      let points = ()
      for (x-value, y-value) in entry.x.values.zip(entry.y.values) {
        // Leere und frei gesetzte Zellen überspringen
        if is-number(x-value) and is-number(y-value) {
          points.push((x-value * x-factor, y-value * y-factor))
          all-values.x.push(x-value * x-factor)
          all-values.y.push(y-value * y-factor)
        }
      }
      // Eine Messreihe ohne Zahlen (zum Beispiel aus `messdaten`) zeichnet nichts.
      if points.len() > 0 {
        point-sets.push((points: points, symbol: entry.symbol, style: entry.style))
      }
    }
    // Achsenbereich mit 10 % Rand
    for axis in ("x", "y") {
      let values = all-values.at(axis)
      if values.len() > 0 {
        let low = calc.min(..values)
        let high = calc.max(..values)
        let margin = (high - low) * 0.1
        data-ranges.insert(axis, (low - margin, high + margin))
      }
    }
  }

  // 4. Achsen: Bereich, Beschriftung, Schritte, Gitter, Größe
  let ranges = (:)
  let axis-labels = (:)
  let ticks = (:)
  let decimals = (:)
  for (index, axis) in ("x", "y").enumerate() {
    let axis-range = if domains.at(axis) != auto {
      domains.at(axis)
    } else if data-ranges.at(axis) != none {
      data-ranges.at(axis)
    } else {
      (-5, 5)
    }
    ranges.insert(axis, axis-range)

    let label = if labels == auto { auto } else { labels.at(index) }
    if label == auto {
      label = if data-labels.at(axis) != none { data-labels.at(axis) } else if axis == "x" { [$x$] } else { [$y$] }
    }
    axis-labels.insert(axis, label)

    // (Hauptschritt, Nebenschritt); `auto` überlässt die Wahl cetz-plot
    let value = steps.at(axis)
    if value == auto and datasets.len() == 0 { value = 1 }
    let tick = if value == auto {
      (auto, auto)
    } else if value == none {
      (none, none)
    } else if type(value) == array {
      (value.at(0), value.at(1))
    } else {
      (value, value / 2)
    }
    ticks.insert(axis, tick)

    // Nachkommastellen der Achsenzahlen: zwei wie bisher; nur ein sehr kleiner
    // Bereich mit automatischem Schritt braucht mehr, sonst stünde dieselbe
    // Zahl mehrfach an der Achse.
    let span = calc.abs(axis-range.at(1) - axis-range.at(0))
    let digits = if value == auto and span > 0 and span < 0.5 {
      calc.max(2, int(calc.ceil(-calc.log(span))) + 2)
    } else {
      2
    }
    decimals.insert(axis, digits)
  }
  let plot-grid(value) = if value == none { false } else if value == "all" { "both" } else { value }
  let plot-width = if width == auto { calc.abs(ranges.x.at(1) - ranges.x.at(0)) } else { width / 1cm }
  let plot-height = if height == auto { calc.abs(ranges.y.at(1) - ranges.y.at(0)) } else { height / 1cm }

  // 5. Graphen, Flächen, Punkte
  let base-stroke = stroke-fields(stroke)
  let graphs = args.pos().enumerate().map(((index, definition)) => resolve-graph(definition, index, base-stroke))
  // Flächen richten sich wie in 0.0.2 nach dem angegebenen x-Bereich, nicht
  // nach dem Bereich der Messreihen.
  let area-range = if domains.x != auto { domains.x } else { (-5, 5) }
  let resolved-areas = areas
    .enumerate()
    .map(((index, definition)) => resolve-area(definition, index, area-range, sample-count))
  let resolved-marks = marks.map(resolve-mark)

  canvas(length: 1cm, {
    draw.set-style(
      axes: (
        tick: (offset: -50%, minor-offset: -25%, minor-length: 100%),
        grid: (
          stroke: (paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt),
          fill: none,
        ),
        minor-grid: (
          stroke: (paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt),
          fill: none,
        ),
        mark: (end: "straight"),
        x: (label: (anchor: "south-east", offset: -0.2)),
        y: (label: (anchor: "north-west", offset: -0.2)),
        overshoot: 8pt,
      ),
    )
    plot.plot(
      size: (plot-width, plot-height),
      name: "plot",
      axis-style: "school-book",
      x-grid: plot-grid(grids.x),
      y-grid: plot-grid(grids.y),
      x-tick-step: ticks.x.at(0),
      y-tick-step: ticks.y.at(0),
      x-minor-tick-step: ticks.x.at(1),
      y-minor-tick-step: ticks.y.at(1),
      x-decimals: decimals.x,
      y-decimals: decimals.y,
      x-label: axis-labels.x,
      y-label: axis-labels.y,
      x-min: ranges.x.at(0),
      x-max: ranges.x.at(1),
      y-min: ranges.y.at(0),
      y-max: ranges.y.at(1),
      {
        plot.add(
          style: (stroke: none),
          domain: (0, 5),
          x => x,
        )
        for area in resolved-areas {
          plot.add-fill-between(
            domain: area.domain,
            samples: sample-count,
            style: (fill: area.fill, stroke: none),
            area.lower,
            area.upper,
          )
        }
        if annotations != none and annotations != () {
          plot.annotate(annotations)
        }
        for graph in graphs {
          let graph-domain = if graph.domain != auto { graph.domain } else { ranges.x }
          for segment in pole-segments(graph.term, graph-domain, calc.abs(ranges.y.at(1) - ranges.y.at(0))) {
            plot.add(
              style: (stroke: graph.stroke),
              samples: sample-count,
              domain: segment,
              graph.term,
            )
          }
          for label in graph.labels {
            // Beschriftung nicht außerhalb des y-Bereichs setzen (sonst wächst die Grafik)
            let y-value = calc.clamp((graph.term)(label.x), calc.min(..ranges.y), calc.max(..ranges.y))
            let alignment = (
              "top-left": right + bottom,
              "top-right": left + bottom,
              "bottom-left": right + top,
              "bottom-right": left + top,
            ).at(label.position)
            let dx = if label.position.ends-with("left") { -1 * label.distance } else { label.distance }
            let dy = if label.position.starts-with("top") { -1 * label.distance } else { label.distance }

            plot.annotate({
              draw.content(
                (label.x, y-value),
                angle: label.rotation,
                box(
                  width: 0mm,
                  height: 0mm,
                  align(alignment, context {
                    let body = if label.font-size != auto {
                      text(size: label.font-size, label.text-fill, label.body)
                    } else {
                      text(label.text-fill, label.body)
                    }
                    move(dx: dx, dy: dy, box(
                      fill: label.fill,
                      inset: 1mm,
                      width: measure(body).width + 2mm,
                      height: measure(body).height + 2mm,
                      body,
                    ))
                  }),
                ),
                padding: 0mm,
              )
            })
          }
        }
        for points in point-sets {
          plot.add(
            points.points,
            style: (stroke: none),
            mark: points.symbol,
            mark-style: points.style,
          )
        }
        if resolved-marks.len() > 0 {
          plot.annotate({
            for mark in resolved-marks {
              draw.mark(
                mark.at("at"),
                (rel: (0, 0.00001)),
                symbol: mark.symbol,
                stroke: mark.stroke,
                fill: mark.fill,
              )
              if mark.body != none {
                draw.content(mark.at("at"), anchor: mark.anchor, padding: mark.distance, mark.body)
              }
            }
          })
        }
      },
    )
  })
}
