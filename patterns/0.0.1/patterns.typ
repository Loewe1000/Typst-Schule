#import "@preview/cetz:0.2.1": *

// Was ist items? Gibts da nicht schönere Variablennamen?
#let kariert(
  rows: 1,
  width: auto,
  items: (),
  items-spacing: 2,
  grid-size: 0.5cm,
  height: none,
  line-stroke: (paint: black.lighten(50%), thickness: 0.5pt),
) = {
  layout(size => {
    let autoheight
    if items.len() != 0 and rows == 1 {
      autoheight = items.len() * 1.5cm - grid-size
    } else {
      if height != none {
        autoheight = height
      } else {
        autoheight = rows * grid-size
      }
    }
    canvas(length: grid-size, {
      import draw: *

      set-style(stroke: line-stroke)

      if width != auto {
        grid((0, 0), (width, autoheight))
        rect((0, 0), (width, autoheight))
      } else {
        grid((0, 0), (calc.round((size.width / grid-size)), autoheight))
        rect((0, 0), (calc.round((size.width / grid-size)), autoheight))
      }

      if items.len() != 0 {
        for (key, item) in items.enumerate() {
          content(
            (0.75, autoheight + grid-size - (key+1) * items-spacing * grid-size),
            [#box(fill: white, inset: 4pt)[#item]],
            anchor: "left",
          )
        }
      }
    })
  })
}

#let liniert(
  rows: 1,
  width: auto,
  lineheight: 1cm,
  line-stroke: (paint: black.lighten(50%), thickness: 0.5pt),
) = {
  move(dy: lineheight * 0.5)[
    #layout(size => {
      canvas(length: lineheight, {
        import draw: *
        set-style(stroke: line-stroke)
        if width != auto {
          for row in range(rows) {
            line((0, row), (width, row))
          }
        } else {
          for row in range(rows) {
            line((0, row), (size.width, row))
          }
        }
      })
    })
  ]

  // Set some spacing under the rows
  v(1em * (lineheight / 1cm))
}
