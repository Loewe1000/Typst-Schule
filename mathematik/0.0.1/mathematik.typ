#import "@preview/tablex:0.0.7": tablex, colspanx, rowspanx, vlinex,
#import "@preview/cetz:0.1.2": *
#import "@schule/random:0.0.1": *
#import "@schule/aufgaben:0.0.2": teilaufgabe

#let c_canvas = canvas
#let canvas(..args, body) = {
  c_canvas(..args, {
    import draw: *
    set-style(axes: (fill: none, stroke: rgb("#000000"), tick: (
      fill: none,
      stroke: rgb("#000000"),
      length: 0.1,
      minor-length: 0.08,
      label: (offset: 0.1, angle: 0deg, anchor: auto),
    ), padding: 0, grid: (
      stroke: (paint: rgb("#AAAAAA").lighten(30%), dash: "solid"),
      fill: none,
    )))
    body
  })
}

#let fkt-plot(
  term,
  clr,
  x,
  y,
  size: 2.5,
  text-scale: 1,
  x-ticks: true,
  y-ticks: true,
) = text(
  size: text-scale * 1em,
  canvas(
    length: 1cm,
    {
      import draw: *
      plot.plot(
        size: (size, size),
        axis-style: "school-book",
        x-tick-step: if x-ticks { calc.ceil((x.at(1) - x.at(0)) / 8) } else { none },
        y-tick-step: if y-ticks { calc.ceil((y.at(1) - y.at(0)) / 8) } else { none },
        x-label: "",
        y-label: "",
        x-grid: "both",
        y-grid: "both",
        x-min: x.at(0) * 0.99,
        x-max: x.at(1) * 0.99,
        y-min: y.at(0) * 0.99,
        y-max: y.at(1) * 0.99,
        {
          plot.add(style: (stroke: clr + 1.5pt), domain: x, term)
        },
      )
      content(((size / 2) + 0.25, size - 0.2), [$y$])
      content((size - 0.2, (size / 2) + 0.25), [$x$])
    },
  ),
)

#let nbx(nmb, clr) = move(
  dx: -1mm,
  dy: -1mm,
  [#box(
      fill: clr,
      inset: 1.5mm,
      radius: (top-left: 2mm, top-right: 0mm, bottom-left: 0mm, bottom-right: 2mm),
    )[#text(fill: white, [#nmb])]],
)

#let nbr = counter("nbr")
#let rand = counter("rand")

#let colors = (
  red,
  blue,
  green,
  purple,
  orange,
  maroon,
  yellow.darken(10%),
  aqua.darken(10%),
)

#let fkt-graph-card(
  fkt,
  clr: none,
  x: (-2, 2),
  y: (-2, 2),
  size: 2.5cm,
  text-scale: 1,
  x-ticks: true,
  y-ticks: true,
) = block(
  )[
  #nbr.step()

  #locate(
    loc => [
      #let color = if clr == none {
        shuffle(colors, counter("rand").at(loc).at(0)).at(counter("nbr").at(loc).at(0))
      } else { clr }
      #box(
        width: size + 2pt,
        height: size + 2pt,
        stroke: color + 2pt,
        inset: 1mm,
        fill: color.lighten(90%),
        radius: 2mm,
      )[
        #place(center + horizon, fkt-plot(
          fkt,
          color,
          x,
          y,
          size: size / 1cm,
          text-scale: text-scale,
          x-ticks: x-ticks,
          y-ticks: y-ticks,
        ))
        #place(top + left, nbx(nbr.display(), color))
      ]
    ],
  )
]

#let fkt-term-card(fkt, clr: rgb("#FFF099"), text-scale: 1) = box(
  stroke: clr.darken(10%).saturate(200%),
  inset: 4mm,
  fill: clr,
  radius: 1mm,
)[
  #fkt
]

#let tasks(
  tasks: (),
  columns: auto,
  numbering: "a)",
  gutter: 10pt,
  loesungen: (),
  ..args,
) = {
  let row-amount = tasks.len()
  if columns != auto {
    row-amount = columns
  }
  let tasks-show = ()
  for (key, task) in tasks.enumerate() {
    tasks-show.push(teilaufgabe(numb: numbering)[
      #task
      #if loesungen.len() > key [
        #loesung[#loesungen.at(key)]
      ]
    ])
  }

  table(
    stroke: none,
    columns: (1fr,) * row-amount,
    column-gutter: gutter,
    row-gutter: gutter,
    ..tasks-show,
    ..args,
  )
}

#let ti-btn(name, color: white) = [
  #let fill-color = none
  #let text-color = black
  #if color == white {
    fill-color = white
  } else if color == red {
    fill-color = rgb("#E7001A")
    text-color = white
  } else if color == black {
    fill-color = black
    text-color = white
  } else if color == blue {
    fill-color = rgb("#A4C8DE")
    text-color = black
  } else {
    fill-color = color
  }
  #box(
    height: 0em,
  )[
    #move(
      dy: -1.2mm + 0.75pt / 2,
      box(
        fill: fill-color,
        width: 11mm,
        height: 4.8mm,
        stroke: 0.75pt,
        radius: 1mm,
      )[
        #align(
          center + horizon,
          [
            #text(9pt, text-color, font: "Open Sans", weight: 600, tracking: -0.4pt, [
              #name
            ])
          ],
        )
      ],
    )
  ]
]

#let ti-ctrl-btn(name) = [
  #let text-color = rgb("#A4C8DE")
  #text(9pt, text-color.darken(20%), font: "Open Sans", weight: 600, tracking: -0.4pt, [
    #name
  ])
]

#let ti-mnu(name) = [#box(
    height: 0em,
    move(
      dy: -1.125mm,
      box(
        fill: rgb("#008AD8"),
        height: 4.5mm,
        radius: 10%,
        inset: (left: 2mm, right: 2mm),
      )[#align(
          center + horizon,
          move(dy: 0mm, text(9pt, white, font: "Open Sans", weight: 400, [
    #name
  ])),
        )],
    ),
  )
  #h(1pt)
]