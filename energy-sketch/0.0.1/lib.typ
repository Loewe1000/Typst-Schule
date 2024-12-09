#import "@preview/cetz:0.3.1": *

#let energy-sketch(energy-name, hide-letters: false, height: 3cm) = {
  let step = height / 10
  let width = 4 * step

  canvas({
    import draw: *

    for bar in range(energy-name.len()) {
      // Grid
      set-style(stroke: (paint: black.lighten(50%), thickness: 0.5pt))
      grid((width * bar, 0), (width * (bar + 1), height), step: step)

      // Black dividers between diagramms
      set-style(stroke: (paint: black, thickness: 1pt))
      rect((width * bar, 0), (width * (bar + 1), height))

      // Lines for letters
      set-style(stroke: (paint: black, thickness: 2pt))
      line(((width * bar) + 4pt, -1.2), ((width * (bar + 1)) - 4pt, -1.2))

      // Letters
      if not hide-letters {
        content(
          (width * bar + (width / 2), -1),
          [#text(16pt, weight: "bold", align(center)[#energy-name.at(bar, default: "")])],
          anchor: "bottom",
        )
      }
    }
  })
}