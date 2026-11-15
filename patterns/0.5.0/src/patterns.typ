// patterns – karierte und linierte Schreibfelder, flexible Felder

#import "internal/check.typ": check-named, check-not-empty, check-type, fail
#import "internal.typ": draw-flex-lines, draw-lines, draw-squares, leading-rows, named-except-rows, with-changed-names

/// Ein Feld, das sich wie `v(1fr)` den freien Platz der Seite mit anderen
/// flexiblen Feldern teilt (`1fr`, `2fr` …). `body` bekommt die tatsächliche
/// Höhe und zeichnet das Feld. In `teilaufgabe(workspace: …)` holt das
/// Aufgabenpaket solche Felder aus der Teilaufgabe heraus, damit sie
/// mitteilen können.
///
/// ```typ
/// #flex-area(1fr, height => rect(width: 100%, height: height))
/// ```
///
/// - height (fraction): Anteil am freien Platz, zum Beispiel `1fr`
/// - body (function): Zeichenfunktion `length => content`; bekommt die tatsächliche Höhe
/// -> content
#let flex-area(height, body) = {
  check-type("patterns", "flex-area", "height", height, fraction)
  check-type("patterns", "flex-area", "body", body, function, example: "height => rect(height: height)")
  block(
    height: height,
    width: 100%,
    breakable: false,
    // Beim Ausmessen (unbegrenzte Höhe) erst einmal klein zeichnen
    layout(size => body(if size.height.pt() > 100000 { 1cm } else { size.height })),
  )
}

/// Ist `body` ein flexibles Feld (ein Block, dessen Höhe ein Anteil wie `1fr` ist)?
///
/// ```typ
/// #is-flex-area(kariert(1fr))  // true
/// #is-flex-area(kariert(4))    // false
/// ```
///
/// - body (any): der zu prüfende Wert
/// -> bool
#let is-flex-area(body) = (
  type(body) == content and body.func() == block and type(body.at("height", default: auto)) == fraction
)

/// Erstellt ein kariertes Schreibfeld.
///
/// Die Zeilenzahl steht vorn ohne Namen; ohne Angabe ist es eine Zeile. Statt
/// der Zeilenzahl kann `height` eine feste Höhe geben. Ein Anteil wie `1fr`
/// macht das Feld flexibel: Es teilt sich den freien Platz der Seite mit
/// anderen flexiblen Feldern.
///
/// ```typ
/// #kariert(10)
/// #kariert(4, grid-size: 1cm, columns: 8)
/// #kariert(height: 3cm)
/// #kariert(1fr)   // teilt sich den freien Platz der Seite
/// ```
///
/// - columns (int, auto): Breite in Kästchen. `auto`: die verfügbare Breite. Nicht zusammen mit `width`.
/// - width (length, auto): Breite als Länge. `auto`: die verfügbare Breite. Nicht zusammen mit `columns`.
/// - height (length, auto): Feste Höhe statt der Zeilenzahl; beides zugleich ist ein Fehler.
/// - grid-size (length): Kantenlänge eines Kästchens.
/// - items (array): Beschriftungen, die im Raster untereinander stehen. Bei einer Zeile (der Vorgabe) ergibt sich die Höhe des Felds aus ihnen.
/// - item-rows (int): Kästchen je Beschriftung.
/// - annotations (array, none): CeTZ-Elemente, die über dem Raster gezeichnet werden; die Einheit ist ein Kästchen. Ein Zeichenblock ohne Elemente (`none`) zeichnet nichts.
/// - overlay (content, str, none): Inhalt, der oben links über dem Raster steht. `none`: kein Inhalt.
/// - stroke (stroke, auto): Stil der Gitterlinien. `auto`: die Vorgabe von CeTZ.
/// - fill (color, gradient, tiling, none): Hintergrund des Felds.
/// - ..args (arguments): Die Zeilenzahl als einziges Positionsargument: eine ganze Zahl oder ein Anteil wie `1fr`, Vorgabe `1`. Alte Namen werden hier abgefangen.
/// -> content
#let kariert(
  columns: auto,
  width: auto,
  height: auto,
  grid-size: 0.5cm,
  items: (),
  item-rows: 2,
  annotations: (),
  overlay: none,
  stroke: (paint: rgb("#AAAAAA").lighten(10%), thickness: 0.5pt),
  fill: white,
  ..args,
) = {
  // 1. Sink prüfen: alte und unbekannte Namen, dann die Zeilenzahl vorn
  let renamed = (
    "items-spacing": "item-rows",
    "line-stroke": "stroke",
    "fill-color": "fill",
    "content": "overlay",
  )
  check-named(
    "patterns",
    "kariert",
    with-changed-names(
      named-except-rows(args),
      renamed,
      (item-rows: item-rows, stroke: stroke, fill: fill, overlay: overlay),
      (
        item-rows: 2,
        stroke: (paint: rgb("#AAAAAA").lighten(10%), thickness: 0.5pt),
        fill: white,
        overlay: none,
      ),
    ),
    renamed: renamed,
    removed: (cnt: "hatte nie eine Wirkung, das Argument löschen"),
    allowed: (
      "columns",
      "width",
      "height",
      "grid-size",
      "items",
      "item-rows",
      "annotations",
      "overlay",
      "stroke",
      "fill",
    ),
  )
  let leading = leading-rows(
    "kariert",
    args,
    "die Breite steht in `columns:` (Kästchen) oder `width:` (Länge)",
  )
  // 2. Typen der deklarierten Parameter prüfen
  check-type("patterns", "kariert", "columns", columns, (int, auto))
  check-type("patterns", "kariert", "grid-size", grid-size, length)
  if type(width) == int {
    fail(
      "patterns",
      "kariert",
      "`width` erwartet eine Länge, bekam `" + repr(width) + "` (int) – die Kästchenzahl steht in `columns:`",
    )
  }
  if type(width) == float {
    // Bisher zählte eine Kommazahl Kästchen; `columns` nimmt nur ganze Zahlen.
    fail(
      "patterns",
      "kariert",
      "`width` erwartet eine Länge, bekam `"
        + repr(width)
        + "` (float) – Kästchenzahl mal Kästchengröße schreiben, hier `width: "
        + str(calc.round((width * grid-size).cm(), digits: 2))
        + "cm"
        + "`",
    )
  }
  check-type("patterns", "kariert", "width", width, (length, auto))
  if height == none {
    fail("patterns", "kariert", "`height: none` – weglassen, die Vorgabe ist `auto`")
  }
  check-type("patterns", "kariert", "height", height, (length, auto))
  check-type("patterns", "kariert", "items", items, array)
  check-type("patterns", "kariert", "item-rows", item-rows, int)
  // Ein Zeichenblock ohne Elemente wertet zu `none` aus und zeichnet nichts.
  check-type(
    "patterns",
    "kariert",
    "annotations",
    annotations,
    (array, none),
    example: "{ draw.line((0, 0), (4, 2)) }",
  )
  check-not-empty("patterns", "kariert", "overlay", overlay, "kein Inhalt")
  if overlay == [] {
    fail("patterns", "kariert", "`overlay: []` – für „kein Inhalt\" `none` schreiben oder weglassen")
  }
  check-type("patterns", "kariert", "overlay", overlay, (content, str, none))
  check-type(
    "patterns",
    "kariert",
    "stroke",
    stroke,
    (std.stroke, length, color, gradient, tiling, dictionary, none, auto),
  )
  check-type("patterns", "kariert", "fill", fill, (color, gradient, tiling, none))
  // 3. Unzulässige Kombinationen
  if columns != auto and width != auto {
    fail("patterns", "kariert", "`columns` und `width` zugleich – nur eines von beiden schreiben")
  }
  if leading.given and height != auto {
    fail("patterns", "kariert", "Zeilenzahl und `height` zugleich – nur eines von beiden schreiben")
  }

  let rows = leading.rows
  let breadth = if columns != auto { columns } else { width }

  if type(rows) == fraction {
    return flex-area(rows, available => draw-squares(
      calc.max(1, calc.floor(available / grid-size)),
      breadth,
      auto,
      grid-size,
      items,
      item-rows,
      annotations,
      overlay,
      stroke,
      fill,
    ))
  }

  draw-squares(rows, breadth, height, grid-size, items, item-rows, annotations, overlay, stroke, fill)
}

/// Erstellt ein liniertes Schreibfeld.
///
/// Die Zeilenzahl steht vorn ohne Namen; ohne Angabe ist es eine Zeile. Ein
/// Anteil wie `1fr` macht das Feld flexibel (siehe `kariert`); die Linien
/// verteilen sich dann gleichmäßig über die ganze Höhe.
///
/// ```typ
/// #liniert(5)
/// #liniert(3, line-height: 1.5cm, width: 8cm)
/// #liniert(2fr)   // teilt sich den freien Platz der Seite
/// ```
///
/// - width (length, auto): Breite des Felds. `auto`: die verfügbare Breite.
/// - line-height (length): Höhe einer Zeile.
/// - items (array): Beschriftungen auf den Linien. Mit Beschriftungen ergibt sich die Zeilenzahl aus ihnen, die Angabe vorn zählt dann nicht.
/// - item-rows (int): Zeilen je Beschriftung.
/// - stroke (stroke, auto): Stil der Linien. `auto`: die Vorgabe von CeTZ und Typst.
/// - ..args (arguments): Die Zeilenzahl als einziges Positionsargument: eine ganze Zahl oder ein Anteil wie `1fr`, Vorgabe `1`. Alte Namen werden hier abgefangen.
/// -> content
#let liniert(
  width: auto,
  line-height: 1cm,
  items: (),
  item-rows: 1,
  stroke: (paint: black.lighten(50%), thickness: 0.5pt),
  ..args,
) = {
  // 1. Sink prüfen: alte und unbekannte Namen, dann die Zeilenzahl vorn
  let renamed = (
    "items-spacing": "item-rows",
    "lineheight": "line-height",
    "line-stroke": "stroke",
  )
  check-named(
    "patterns",
    "liniert",
    with-changed-names(
      named-except-rows(args),
      renamed,
      (item-rows: item-rows, line-height: line-height, stroke: stroke),
      (item-rows: 1, line-height: 1cm, stroke: (paint: black.lighten(50%), thickness: 0.5pt)),
    ),
    renamed: renamed,
    allowed: ("width", "line-height", "items", "item-rows", "stroke"),
  )
  let leading = leading-rows("liniert", args, "die Breite steht in `width:` (Länge)")
  // 2. Typen der deklarierten Parameter prüfen
  check-type("patterns", "liniert", "line-height", line-height, length)
  check-type(
    "patterns",
    "liniert",
    "width",
    width,
    (length, auto),
    example: if type(width) in (int, float) { str(calc.round((width * line-height).cm(), digits: 2)) + "cm" } else { "8cm" },
  )
  check-type("patterns", "liniert", "items", items, array)
  check-type("patterns", "liniert", "item-rows", item-rows, int)
  check-type(
    "patterns",
    "liniert",
    "stroke",
    stroke,
    (std.stroke, length, color, gradient, tiling, dictionary, none, auto),
  )

  let rows = leading.rows

  if type(rows) == fraction and items.len() == 0 {
    return flex-area(rows, available => draw-flex-lines(available, width, line-height, stroke))
  }

  draw-lines(rows, width, line-height, items, item-rows, stroke)
}
