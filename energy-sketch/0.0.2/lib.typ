#import "@preview/cetz:0.3.1": canvas, draw

#let energy-sketch(
  energy-name,
  hide-letters: false,
  height: 3cm,
) = {
  // Konstante Parameter
  let steps = 10
  let vertical-step = height / steps
  let bar-width = 4 * vertical-step

  // Farb- und Stilkonstanten
  let grid-color = black.lighten(50%)
  let border-color = black
  let line-color = black
  let grid-thickness = 0.5pt
  let border-thickness = 1pt
  let base-line-thickness = 2pt
  let label-font-size = 16pt

  // Positionen und Abstände als Konstante
  let label-line-y = -1.2
  let label-y = -1
  let horizontal-margin = 4pt

  canvas({
    import draw: *

    for bar-index in range(energy-name.len()) {
      let x-start = bar-width * bar-index
      let x-end = bar-width * (bar-index + 1)

      // Gitter zeichnen
      set-style(stroke: (paint: grid-color, thickness: grid-thickness))
      grid((x-start, 0), (x-end, height), step: vertical-step)

      // Rahmen
      set-style(stroke: (paint: border-color, thickness: border-thickness))
      rect((x-start, 0), (x-end, height))

      // Linie für die Beschriftung
      set-style(stroke: (paint: line-color, thickness: base-line-thickness))
      line((x-start + horizontal-margin, label-line-y), (x-end - horizontal-margin, label-line-y))

      // Beschriftung, falls nicht ausgeblendet
      if not hide-letters {
        let energy-label = energy-name.at(bar-index, default: "")
        content(
          (x-start + bar-width / 2, label-y),
          [#text(label-font-size, weight: "bold", align(center)[#energy-label])],
          anchor: "south",
        )
      }
    }
  })
}
