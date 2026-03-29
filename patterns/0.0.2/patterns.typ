
// Was ist items? Gibts da nicht schönere Variablennamen?
/// Erstellt ein kariertes Schreibfeld.
///
/// Zeichnet ein kariertes Raster mit optionalen Beschriftungen und Annotationen.
/// Positionale Argumente werden unterstützt: erstes Argument = `rows`, zweites = `width`.
///
/// ```typ
/// #kariert(rows: 10, grid-size: 0.5cm)
/// ```
///
/// - rows (int): Anzahl der Zeilen. Standard: `1`.
/// - width (length): Breite des Felds. Standard: `auto` (verfügbare Breite).
/// - items (array): Liste von Einträgen, die im Raster platziert werden. Standard: `()`.
/// - items-spacing (int): Zeilenabstand zwischen Items in Rastereinheiten. Standard: `2`.
/// - grid-size (length): Größe einer Rasterzelle. Standard: `0.5cm`.
/// - height (length): Höhe des Felds (überschreibt `rows`). Standard: `none`.
/// - annotations (array): CeTZ-Annotationen, die über dem Raster gezeichnet werden. Standard: `()`.
/// - line-stroke (stroke): Strichstil der Gitterlinien. Standard: hellgrau, 0.5pt.
/// - fill-color (color): Hintergrundfarbe des Felds. Standard: `white`.
/// - content (content): Inhalt, der über dem Raster angezeigt wird. Standard: `[]`.
/// - ..args (any): Positionale Argumente: erstes = `rows`, zweites = `width`.
/// -> content
#let kariert(
  rows: 1,
  width: auto,
  items: (),
  items-spacing: 2,
  grid-size: 0.5cm,
  height: none,
  annotations: (),
  line-stroke: (paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt),
  fill-color: white,
  content: [],
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
      autoheight = (items.len() * items-spacing) * grid-size
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
        import draw:

        draw.set-style(stroke: line-stroke)

        if effective-width != auto {
          draw.rect((0, 0), (effective-width, autoheight), ..if fill-color != none { (fill: fill-color) })
          draw.grid(
            (0, 0),
            (effective-width, autoheight),
          )
        } else {
          draw.rect(
            (0, 0),
            (calc.round((size.width / grid-size)), autoheight),
            ..if fill-color != none { (fill: fill-color) },
          )
          draw.grid(
            (0, 0),
            (calc.round((size.width / grid-size)), autoheight),
          )
        }

        if items.len() != 0 {
          for (key, item) in items.enumerate() {
            draw.content(
              (0.75, autoheight - (key * items-spacing + 1) * grid-size),
              [#box(fill: white, inset: 4pt)[#item]],
              anchor: "west",
            )
          }
        }
        if content != [] {
          draw.content(
            (grid-size, autoheight),
            [#box(inset: (y: 2 / 3 * grid-size), width: if effective-width != auto { effective-width * grid-size } else { calc.round((size.width / grid-size)) * grid-size - 2 * grid-size }, content)],
            anchor: "north-west",
          )
        }
        annotations
      },
    )
  })
}

/// Erstellt ein liniertes Schreibfeld.
///
/// Zeichnet horizontale Linien mit einstellbarem Zeilenabstand.
/// Positionale Argumente werden unterstützt: erstes Argument = `rows`, zweites = `width`.
///
/// ```typ
/// #liniert(rows: 5, line-height: 1cm)
/// ```
///
/// - rows (int): Anzahl der Zeilen. Standard: `1`.
/// - width (length): Breite des Felds. Standard: `auto` (verfügbare Breite).
/// - items (array): Liste von Einträgen auf den Linien. Standard: `()`.
/// - items-spacing (int): Abstand zwischen Items in Zeileneinheiten. Standard: `1`.
/// - line-height (length): Höhe einer Zeile. Standard: `1cm`.
/// - line-stroke (stroke): Strichstil der Linien. Standard: schwarz 50% aufgehellt, 0.5pt.
/// - ..args (any): Positionale Argumente: erstes = `rows`, zweites = `width`.
/// -> content
#let liniert(
  rows: 1,
  width: auto,
  items: (),
  items-spacing: 1,
  line-height: 1cm,
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

  // Wenn items übergeben werden, Zeilenanzahl aus items und spacing berechnen
  if items.len() != 0 {
    effective-rows = items.len() * items-spacing
  }

  move(dy: line-height * 0.5)[
    #layout(size => {
      import "@preview/cetz:0.4.2": *
      canvas(
        length: line-height,
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

          // Items auf den Linien platzieren
          if items.len() != 0 {
            for (key, item) in items.enumerate() {
              content(
                (0.1, (effective-rows - 1) - key * items-spacing),
                [#item],
                anchor: "south-west",
              )
            }
          }
        },
      )
    })
  ]

  // Set some spacing under the rows
  v(1em * (line-height / 1cm))
}
