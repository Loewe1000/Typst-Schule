#let angela-dark = rgb(40, 80, 155)
#let angela-light = rgb(150, 180, 221)

#let brief(
  body,
) = {
  show heading: set block(above: 2em, below: 1em)

  set page(
    "a4",
    margin: (top: 5cm, bottom: 2cm, left: 2.5cm, right: 2.5cm),
    header-ascent: 45%,
    header: [
      #stack(
        dir: ttb,
        spacing: 3mm,
        text(font: "Lucida Grande", size: 20pt, [Angelaschule Osnabrück]),
        text(
          font: "Arial",
          stretch: 75%,
          size: 8pt,
          [Staatlich anerkanntes Gymnasium der Schulstiftung im Bistum Osnabrück],
        ),
      )
      #box(width: 100%)[
        #place(top, dx: -2.5cm, dy: 0cm, line(stroke: angela-dark, length: 2 * 100%))
        #place(top + right, dx: 1.5mm, dy: -0.5cm, box(width: 3cm, height: 4cm, fill: white))
        #place(top + right, dx: 1cm, dy: -3cm, image("logo.svg", height: 4cm))
      ]
    ],
  )
  set text(size: 11pt, font: "Calibri", lang: "de")
  set par(leading: 0.75em, justify: true)
  set text(hyphenate: true)
  body
}
