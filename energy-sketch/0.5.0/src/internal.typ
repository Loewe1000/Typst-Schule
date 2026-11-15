// Interne Helfer von energy-sketch. Keine zugesicherte Schnittstelle:
// Namen und Gestalt dürfen sich in jeder Version ändern.
//
// Importe stehen in den Funktionsrümpfen, damit das Modul `internal` nur die
// elf Helfer trägt und weder `draw` (CeTZ) noch die Prüffunktionen weiterreicht.

/// Zahl der Rasterzeilen je Spalte.
#let rows = 10

/// Begrenzt eine Länge nach unten und oben.
///
/// - value (length): Ausgangswert
/// - min (length, none): Untergrenze
/// - max (length, none): Obergrenze
/// -> length
#let clamp-length(value, min: none, max: none) = {
  let at-least-min = if min != none and value < min { min } else { value }
  if max != none and at-least-min > max { max } else { at-least-min }
}

/// Prüft die Beschriftungen und gibt sie unverändert zurück.
///
/// - labels (array): Beschriftungen der Spalten
/// -> array
#let normalize-labels(labels) = {
  import "internal/check.typ": fail, check-type
  check-type("energy-sketch", "energy-sketch", "labels", labels, array,
    example: "(\"A\", \"B\")")
  if labels.len() == 0 {
    fail("energy-sketch", "energy-sketch",
      "`labels` ist leer – mindestens eine Beschriftung angeben, zum Beispiel `(\"A\", \"B\")`")
  }
  labels
}

/// Berechnet alle Maße des Diagramms aus Spaltenzahl und Höhe.
///
/// - column-count (int): Zahl der Spalten
/// - height (length): Höhe des Rasters
/// - gutter (length): Abstand zwischen zwei Spalten
/// - rows (int): Zahl der Rasterzeilen
/// -> dictionary
#let resolve-layout(column-count, height, gutter: 0pt, rows: rows) = {
  let vertical-step = height / rows
  let bar-width = 4 * vertical-step
  let horizontal-margin = clamp-length(
    vertical-step * 0.75,
    min: 2pt,
    max: bar-width / 3,
  )

  (
    column-count: column-count,
    rows: rows,
    height: height,
    gutter: gutter,
    column-span: bar-width + gutter,
    vertical-step: vertical-step,
    bar-width: bar-width,
    label-width: bar-width - 2 * horizontal-margin,
    label-line-y: -1.6 * vertical-step,
    label-y: -1.35 * vertical-step,
    horizontal-margin: horizontal-margin,
  )
}

/// Leitet Strichstärken und Schriftgröße aus den Maßen ab.
///
/// - layout (dictionary): Ergebnis von `resolve-layout`
/// -> dictionary
#let resolve-style(layout) = (
  grid-stroke: (
    paint: black.lighten(50%),
    thickness: clamp-length(layout.vertical-step * 0.08, min: 0.35pt, max: 0.5pt),
  ),
  border-stroke: (
    paint: black,
    thickness: clamp-length(layout.vertical-step * 0.18, min: 0.75pt, max: 1pt),
  ),
  baseline-stroke: (
    paint: black,
    thickness: clamp-length(layout.vertical-step * 0.35, min: 1pt, max: 2pt),
  ),
  label-size: clamp-length(layout.vertical-step * 0.95, min: 9pt, max: 16pt),
)

/// Liefert die waagerechten Koordinaten einer Spalte.
///
/// - layout (dictionary): Ergebnis von `resolve-layout`
/// - column-index (int): Nummer der Spalte, ab 0
/// -> dictionary
#let column-geometry(layout, column-index) = {
  let x-start = layout.column-span * column-index
  (
    x-start: x-start,
    x-end: x-start + layout.bar-width,
    center-x: x-start + layout.bar-width / 2,
  )
}

/// Zeichnet das Raster einer Spalte.
///
/// - layout (dictionary): Ergebnis von `resolve-layout`
/// - style (dictionary): Ergebnis von `resolve-style`
/// - geometry (dictionary): Ergebnis von `column-geometry`
/// -> array
#let column-grid(layout, style, geometry) = {
  import "@preview/cetz:0.5.2": draw
  draw.set-style(stroke: style.grid-stroke)
  draw.grid(
    (geometry.x-start, 0pt),
    (geometry.x-end, layout.height),
    step: layout.vertical-step,
  )
}

/// Zeichnet den Rahmen einer Spalte.
///
/// - layout (dictionary): Ergebnis von `resolve-layout`
/// - style (dictionary): Ergebnis von `resolve-style`
/// - geometry (dictionary): Ergebnis von `column-geometry`
/// -> array
#let column-frame(layout, style, geometry) = {
  import "@preview/cetz:0.5.2": draw
  draw.set-style(stroke: style.border-stroke)
  draw.rect((geometry.x-start, 0pt), (geometry.x-end, layout.height))
}

/// Zeichnet die Linie unter einer Spalte, auf der die Beschriftung steht.
///
/// - layout (dictionary): Ergebnis von `resolve-layout`
/// - style (dictionary): Ergebnis von `resolve-style`
/// - geometry (dictionary): Ergebnis von `column-geometry`
/// -> array
#let column-label-line(layout, style, geometry) = {
  import "@preview/cetz:0.5.2": draw
  draw.set-style(stroke: style.baseline-stroke)
  draw.line(
    (geometry.x-start + layout.horizontal-margin, layout.label-line-y),
    (geometry.x-end - layout.horizontal-margin, layout.label-line-y),
  )
}

/// Setzt die Beschriftung einer Spalte.
///
/// - layout (dictionary): Ergebnis von `resolve-layout`
/// - style (dictionary): Ergebnis von `resolve-style`
/// - geometry (dictionary): Ergebnis von `column-geometry`
/// - label (content, str, none): Beschriftung
/// -> array
#let column-label(layout, style, geometry, label) = {
  import "@preview/cetz:0.5.2": draw
  let normalized-label = if label == none { [] } else { label }

  draw.content(
    (geometry.center-x, layout.label-y),
    [
      #set text(size: style.label-size, weight: "bold")
      #box(width: layout.label-width, align(center)[#normalized-label])
    ],
    anchor: "south",
  )
}

/// Zeichnet eine ganze Spalte: Raster, Rahmen, Linie und Beschriftung.
///
/// - layout (dictionary): Ergebnis von `resolve-layout`
/// - style (dictionary): Ergebnis von `resolve-style`
/// - column-index (int): Nummer der Spalte, ab 0
/// - label (content, str, none): Beschriftung
/// - labeled (bool): Beschriftung setzen
/// -> array
#let energy-column(layout, style, column-index, label, labeled: true) = {
  let geometry = column-geometry(layout, column-index)
  column-grid(layout, style, geometry)
  column-frame(layout, style, geometry)
  column-label-line(layout, style, geometry)

  if labeled {
    column-label(layout, style, geometry, label)
  }
}
