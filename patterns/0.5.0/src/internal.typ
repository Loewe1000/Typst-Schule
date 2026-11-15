// Interne Helfer von patterns. Keine zugesicherte Schnittstelle: Namen und
// Signaturen dürfen sich in jeder Version ändern.

// CeTZ wird nur in den Funktionsrümpfen importiert: So landet kein Name aus
// CeTZ in `patterns.internal`.
#import "internal/check.typ": fail

/// Die benannten Argumente des Sinks ohne `rows`: Die übrigen Namen prüft
/// `check-named`, `rows:` bekommt in `leading-rows` seine eigene Meldung.
///
/// - args (arguments): der Sink der Funktion
/// -> dictionary
#let named-except-rows(args) = {
  let named = args.named()
  if "rows" in named { let _ = named.remove("rows") }
  named
}

/// Ergänzt die Namen des Sinks um die neuen Namen, die der Aufruf sichtbar
/// gesetzt hat (Wert weicht von der Vorgabe ab). So meldet `check-named`
/// „alt und neu zugleich", obwohl der neue Name ein deklarierter Parameter
/// ist und nicht im Sink landet.
///
/// - named (dictionary): die benannten Argumente des Sinks
/// - renamed (dictionary): alter Name → neuer Name
/// - values (dictionary): neuer Name → übergebener Wert
/// - defaults (dictionary): neuer Name → Vorgabe
/// -> dictionary
#let with-changed-names(named, renamed, values, defaults) = {
  for (old, new) in renamed {
    if old in named and new in values and values.at(new) != defaults.at(new) {
      named.insert(new, values.at(new))
    }
  }
  named
}

/// Liest das optionale führende Hauptargument `rows` aus dem Sink und lehnt
/// alles Weitere ab: `rows:` mit Namen und ein zweites Positionsargument.
///
/// - function (str): Funktionsname für die Meldung (`"kariert"`, `"liniert"`)
/// - args (arguments): der Sink der Funktion
/// - second (str): Abhilfe für ein zweites Positionsargument
/// -> dictionary
#let leading-rows(function, args, second) = {
  let named = args.named()
  if "rows" in named {
    fail("patterns", function, "`rows` steht vorn ohne Namen – `" + function + "(" + repr(named.rows) + ")` schreiben")
  }
  let positional = args.pos()
  if positional.len() > 1 {
    fail("patterns", function, "zweites Positionsargument – " + second)
  }
  let given = positional.len() == 1
  let rows = if given { positional.first() } else { 1 }
  if type(rows) != int and type(rows) != fraction {
    fail(
      "patterns",
      function,
      "die Zeilenzahl vorn erwartet eine ganze Zahl oder einen Anteil wie `1fr`, bekam `"
        + repr(rows)
        + "` ("
        + repr(type(rows))
        + ") – zum Beispiel `"
        + function
        + "(4)`",
    )
  }
  (rows: rows, given: given)
}

/// Zeichnet ein kariertes Feld mit fester Zeilenzahl oder fester Höhe.
///
/// - rows (int): Zeilenzahl
/// - breadth (int, length, auto): Breite in Kästchen, als Länge oder die verfügbare Breite
/// - height (length, auto): feste Höhe statt der Zeilenzahl
/// - grid-size (length): Kantenlänge eines Kästchens
/// - items (array): Beschriftungen
/// - item-rows (int): Kästchen je Beschriftung
/// - annotations (array, none): CeTZ-Elemente über dem Raster
/// - overlay (content, str, none): Inhalt über dem Raster
/// - stroke (stroke, auto): Linienstil
/// - fill (color, none): Hintergrund
/// -> content
#let draw-squares(rows, breadth, height, grid-size, items, item-rows, annotations, overlay, stroke, fill) = layout(size => {
  import "@preview/cetz:0.4.2": canvas, draw
  let total-height = if items.len() != 0 and rows == 1 {
    (items.len() * item-rows) * grid-size
  } else if height != auto {
    height
  } else {
    rows * grid-size
  }
  let right = if breadth != auto { breadth } else { calc.round(size.width / grid-size) }
  canvas(
    length: grid-size,
    {
      draw.set-style(stroke: stroke)

      draw.rect((0, 0), (right, total-height), ..if fill != none { (fill: fill) })
      draw.grid((0, 0), (right, total-height))

      for (index, item) in items.enumerate() {
        draw.content(
          (0.75, total-height - (index * item-rows + 1) * grid-size),
          [#box(fill: white, inset: 4pt)[#item]],
          anchor: "west",
        )
      }
      if overlay != none {
        let overlay-width = if type(breadth) == length {
          breadth
        } else if breadth != auto {
          breadth * grid-size
        } else {
          right * grid-size - 2 * grid-size
        }
        draw.content(
          (grid-size, total-height),
          [#box(inset: (y: 2 / 3 * grid-size), width: overlay-width, overlay)],
          anchor: "north-west",
        )
      }
      annotations
    },
  )
})

/// Zeichnet ein liniertes Feld mit fester Zeilenzahl.
///
/// - rows (int): Zeilenzahl
/// - width (length, auto): Breite
/// - line-height (length): Zeilenhöhe
/// - items (array): Beschriftungen
/// - item-rows (int): Zeilen je Beschriftung
/// - stroke (stroke, auto): Linienstil
/// -> content
#let draw-lines(rows, width, line-height, items, item-rows, stroke) = {
  import "@preview/cetz:0.4.2": canvas, draw
  // Mit Beschriftungen ergibt sich die Zeilenzahl aus ihnen.
  let rows = if items.len() != 0 { items.len() * item-rows } else { rows }

  move(dy: line-height * 0.5)[
    #layout(size => {
      let right = if width != auto { width } else { size.width }
      canvas(
        length: line-height,
        {
          draw.set-style(stroke: stroke)
          for row in range(rows) {
            draw.line((0, row), (right, row))
          }
          for (index, item) in items.enumerate() {
            draw.content(
              (0.1, (rows - 1) - index * item-rows),
              [#item],
              anchor: "south-west",
            )
          }
        },
      )
    })
  ]

  // Abstand unter den Zeilen
  v(1em * (line-height / 1cm))
}

/// Zeichnet die Linien eines flexiblen linierten Felds: Sie verteilen sich
/// gleichmäßig über die ganze Höhe, die letzte sitzt am unteren Rand.
///
/// - height (length): tatsächliche Höhe des Felds
/// - width (length, auto): Breite
/// - line-height (length): gewünschte Zeilenhöhe
/// - stroke (stroke, auto): Linienstil
/// -> content
#let draw-flex-lines(height, width, line-height, stroke) = {
  let count = calc.max(1, int(calc.round(height / line-height)))
  let distance = height / count
  block(height: height, width: if width != auto { width } else { 100% }, {
    for index in range(count) {
      // `auto`: Typsts eigene Vorgabe für Linien
      place(top + left, dy: distance * (index + 1), line(length: 100%, ..if stroke != auto { (stroke: stroke) }))
    }
  })
}
