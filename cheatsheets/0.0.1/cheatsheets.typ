#import "@schule/arbeitsblatt:0.1.4": *
//#import "@preview/tablex:0.0.8": *

#let cheatsheets(
  title: "",
  paper: "a3",
  grid: false,
  font-size: 12pt,
  landscape: false,
  page-settings: (margin: (top: 1cm + 6mm, bottom: 1cm - 6mm, left: 1cm, right: 1cm)),
  ..args,
  body,
) = {
  show: arbeitsblatt.with(
    title: title,
    class: "",
    paper: paper,
    print: true,
    landscape: landscape,
    font-size: font-size,
    custom-header: align(center + horizon, move(dy: 4mm, box(height: 12mm, inset: 3mm, [
      #text(20pt, [*#title*])
    ]))),
    page-settings: page-settings,
  )

  body
}

#let colors = (
  thema: (fill: black.lighten(30%), text: white),
  header: (fill: white.darken(15%)),
)

#let cs-grid(columns: 24 * (1fr,), rows: 20 * (2fr,), body, grid: false) = tablex(
  columns: columns,
  rows: rows,
  stroke: if grid { (thickness: 1pt, dash: "dashed", paint: gray) } else { none },
  ..body,
)

#let cs-item(title: "", body) = (if title != "" {
  table.cell(box(
    width: 100%,
    fill: colors.header.fill,
    stroke: (bottom: 1pt, top: 1pt + black),
    height: 6.5mm,
    align(center + horizon, text(weight: "bold", 10pt, title)),
  ))
}, table.cell(box(inset: 2mm, width: 100%, stroke: none, align(horizon, [#body]))))

#let cs-item-grid(columns: 2 * (1fr,), rows: 1, body, small: false) = box(
  stroke: (top: 1pt + black),
  height: if small { auto } else { 100% },
  tablex(
    columns: columns,
    rows: if small { auto } else { auto },
    row-gutter: 1fr,
    auto-lines: false,
    ..for i in range(0, body.len()) {
      if i != 0 and i != body.len() {
        (vlinex(),)
      } else {
        ((),)
      }
    },
    inset: (bottom: 2mm),
    ..for i in range(0, body.len()) {
      (table(
        row-gutter: 1fr,
        stroke: none,
        inset: 0mm,
        ..body.at(i).flatten(),
        table.cell([]),
      ),)
    },
  ),
)

#let cs-box(title, c, r, body) = colspanx(
  c,
  rowspanx(
    r,
    box(
      height: 100% - 6mm,
      width: 100% - 2mm,
      stroke: black + 1pt,
      inset: (top: 0.5pt, left: 0.5pt, right: 0.5pt),
      radius: (bottom-right: 10pt, top-right: 10pt, bottom-left: 10pt),
    )[
      #place(
        top + left,
        dx: -0.5pt,
        dy: -6mm - 0.5pt,
        [
          #box(
            fill: colors.thema.fill,
            height: 6mm,
            inset: (left: 2mm, right: 2mm),
            stroke: black,
            radius: (top-right: 5pt, top-left: 5pt),
            align(horizon, text(fill: colors.thema.text, weight: "bold", 12pt, title)),
          )
        ],
      )
      #box(
        radius: (bottom-right: 9pt, top-right: 9pt, bottom-left: 9pt),
        inset: (top: -0.5pt),
        clip: true,
        body,
      )
    ],
  ),
)

#let cs-v-stack(columns: 2 * (1fr,), body) = move(dy: 4mm, tablex(
  auto-hlines: false,
  row-gutter: 1fr,
  columns: columns,
  inset: 0mm,
  map-cells: c => {
    if c.y == 1 {
      c.inset = (bottom: 2mm)
    }
    c
  },
  ..body.map(x => x.at(0)),
  ..body.map(x => x.at(1)),
))