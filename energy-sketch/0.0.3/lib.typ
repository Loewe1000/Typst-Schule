#import "@preview/cetz:0.5.2": canvas, draw

#let _energy-sketch-rows = 10

#let _clamp-length(value, min: none, max: none) = {
  let at-least-min = if min != none and value < min { min } else { value }
  if max != none and at-least-min > max { max } else { at-least-min }
}

#let _normalize-energy-names(energy-name) = {
  assert(type(energy-name) == array, message: "`energy-name` muss ein Array sein.")
  assert(energy-name.len() > 0, message: "`energy-name` darf nicht leer sein.")
  energy-name
}

#let _validate-energy-sketch-options(hide-letters, height, gap) = {
  assert(type(hide-letters) == bool, message: "`hide-letters` muss ein bool sein.")
  assert(type(height) == length, message: "`height` muss eine Länge sein.")
  assert(height > 0pt, message: "`height` muss größer als 0pt sein.")
  assert(type(gap) == length, message: "`gap` muss eine Länge sein.")
  assert(gap >= 0pt, message: "`gap` muss größer oder gleich 0pt sein.")
}

#let _resolve-layout(column-count, height, gap: 0pt, rows: _energy-sketch-rows) = {
  let vertical-step = height / rows
  let bar-width = 4 * vertical-step
  let horizontal-margin = _clamp-length(
    vertical-step * 0.75,
    min: 2pt,
    max: bar-width / 3,
  )

  (
    column-count: column-count,
    rows: rows,
    height: height,
    gap: gap,
    column-span: bar-width + gap,
    total-width: column-count * bar-width + if column-count > 1 { (column-count - 1) * gap } else { 0pt },
    vertical-step: vertical-step,
    bar-width: bar-width,
    label-width: bar-width - 2 * horizontal-margin,
    label-line-y: -1.6 * vertical-step,
    label-y: -1.35 * vertical-step,
    horizontal-margin: horizontal-margin,
  )
}

#let _resolve-style(layout) = (
  grid-stroke: (
    paint: black.lighten(50%),
    thickness: _clamp-length(layout.vertical-step * 0.08, min: 0.35pt, max: 0.5pt),
  ),
  border-stroke: (
    paint: black,
    thickness: _clamp-length(layout.vertical-step * 0.18, min: 0.75pt, max: 1pt),
  ),
  baseline-stroke: (
    paint: black,
    thickness: _clamp-length(layout.vertical-step * 0.35, min: 1pt, max: 2pt),
  ),
  label-size: _clamp-length(layout.vertical-step * 0.95, min: 9pt, max: 16pt),
)

#let _column-geometry(layout, column-index) = {
  let x-start = layout.column-span * column-index
  (
    x-start: x-start,
    x-end: x-start + layout.bar-width,
    center-x: x-start + layout.bar-width / 2,
  )
}

#let _draw-column-grid(layout, style, geometry) = {
  draw.set-style(stroke: style.grid-stroke)
  draw.grid(
    (geometry.x-start, 0pt),
    (geometry.x-end, layout.height),
    step: layout.vertical-step,
  )
}

#let _draw-column-frame(layout, style, geometry) = {
  draw.set-style(stroke: style.border-stroke)
  draw.rect((geometry.x-start, 0pt), (geometry.x-end, layout.height))
}

#let _draw-column-label-line(layout, style, geometry) = {
  draw.set-style(stroke: style.baseline-stroke)
  draw.line(
    (geometry.x-start + layout.horizontal-margin, layout.label-line-y),
    (geometry.x-end - layout.horizontal-margin, layout.label-line-y),
  )
}

#let _draw-column-label(layout, style, geometry, label) = {
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

#let _draw-energy-column(layout, style, column-index, label, hide-letters: false) = {
  let geometry = _column-geometry(layout, column-index)
  _draw-column-grid(layout, style, geometry)
  _draw-column-frame(layout, style, geometry)
  _draw-column-label-line(layout, style, geometry)

  if not hide-letters {
    _draw-column-label(layout, style, geometry, label)
  }
}

/// Erstellt ein Energieniveau-Diagramm mit beschrifteten Spalten.
///
/// Jede Energieform erhält eine karierte Spalte mit Basislinie und Beschriftung.
/// Das Diagramm basiert auf CeTZ und ist ideal für Energiebetrachtungen im Physikunterricht.
///
/// ```typ
/// #energy-sketch(($E_"kin"$, $E_"pot"$, $E_"ges"$), height: 5cm)
/// ```
///
/// - energy-name (array): Array mit Beschriftungen der Energiespalten (Typst-Content oder Strings).
/// - hide-letters (bool): Blendet die Beschriftungen aus. Nützlich für Lückentext-Aufgaben. Standard: `false`.
/// - height (length): Gesamthöhe jedes Balkens. Das Raster umfasst immer 10 Zeilen. Standard: `3cm`.
/// - gap (length): Abstand zwischen zwei Energiespalten. Standard: `0pt`.
/// -> content
#let energy-sketch(
  energy-name,
  hide-letters: false,
  height: 3cm,
  gap: 0pt,
) = {
  let energy-names = _normalize-energy-names(energy-name)
  _validate-energy-sketch-options(hide-letters, height, gap)

  let layout = _resolve-layout(energy-names.len(), height, gap: gap)
  let style = _resolve-style(layout)

  canvas({
    for (column-index, label) in energy-names.enumerate() {
      _draw-energy-column(
        layout,
        style,
        column-index,
        label,
        hide-letters: hide-letters,
      )
    }
  })
}
