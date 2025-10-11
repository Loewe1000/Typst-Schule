
// Was ist items? Gibts da nicht schönere Variablennamen?
#let kariert(
  rows: 1,
  width: auto,
  items: (),
  items-spacing: 2,
  grid-size: 0.5cm,
  height: none,
  line-stroke: (paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt),
  fill-color: white,
  ..args,
) = {
  // Unterstütze positionale Argumente für rows und width
  let effective-rows = if args.pos().len() > 0 {
    args.pos().at(0)
  } else {
    rows
  }
  
  let effective-width = if args.pos().len() > 1 {
    args.pos().at(1)
  } else {
    width
  }
  
  layout(size => {
    let autoheight
    if items.len() != 0 and effective-rows == 1 {
      autoheight = items.len() * 1.5cm - grid-size
    } else {
      if height != none {
        autoheight = height
      } else {
        autoheight = effective-rows * grid-size
      }
    }
    import "@preview/cetz:0.4.2": *
    canvas(
      length: grid-size,
      {
        import draw: *

        set-style(stroke: line-stroke)

        if effective-width != auto {
          rect((0, 0), (effective-width, autoheight), ..if fill-color != none { (fill: fill-color) })
          grid((0, 0), (effective-width, autoheight))
        } else {
          rect(
            (0, 0),
            (calc.round((size.width / grid-size)), autoheight),
            ..if fill-color != none { (fill: fill-color) },
          )
          grid((0, 0), (calc.round((size.width / grid-size)), autoheight))
        }

        if items.len() != 0 {
          for (key, item) in items.enumerate() {
            content(
              (0.75, autoheight + grid-size - (key + 1) * items-spacing * grid-size),
              [#box(fill: white, inset: 4pt)[#item]],
              anchor: "west",
            )
          }
        }
      },
    )
  })
}

#let liniert(
  rows: 1,
  width: auto,
  lineheight: 1cm,
  line-stroke: (paint: black.lighten(50%), thickness: 0.5pt),
  ..args,
) = {
  // Unterstütze positionales Argument für rows
  let effective-rows = if args.pos().len() > 0 {
    args.pos().at(0)
  } else {
    rows
  }

  let effective-width = if args.pos().len() > 1 and type(args.pos().at(1)) == length {
    args.pos().at(1)
  } else {
    width
  }
  
  move(dy: lineheight * 0.5)[
    #layout(size => {
      import "@preview/cetz:0.4.2": *
      canvas(
        length: lineheight,
        {
          import draw: *
          set-style(stroke: line-stroke)
          if effective-width != auto {
            for row in range(effective-rows) {
              line((0, row), (effective-width, row))
            }
          } else {
            for row in range(effective-rows) {
              line((0, row), (size.width, row))
            }
          }
        },
      )
    })
  ]

  // Set some spacing under the rows
  v(1em * (lineheight / 1cm))
}
