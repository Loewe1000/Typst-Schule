#import "@schule/random:0.0.1": *

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
#let m-rand = counter("m-rand")

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
) = block()[
  #nbr.step()

  #locate(
    loc => [
      #let color = if clr == none {
        shuffle(colors, counter("m-rand").at(loc).at(0)).at(counter("nbr").at(loc).at(0))
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
  gutter: 1.25em,
  loesungen: (),
  ..args,
) = {
  tasks = if tasks.len() == 0 and args.pos() != none {
    let items = args.pos().at(0).children.filter(it => it.func() == enum.item).map(it => it.body)
    items
  } else { tasks }
  let row-amount = tasks.len()
  if columns != auto {
    row-amount = columns
  }
  import "@schule/aufgaben:0.1.2": loesung, teilaufgabe
  let tasks-show = ()
  for (key, task) in tasks.enumerate() {
    tasks-show.push(teilaufgabe()[
      #task
      #if loesungen.len() > key [
        #loesung[#loesungen.at(key)]
      ]
    ])
  }
  table(
    stroke: none,
    inset: 0mm,
    columns: (1fr,) * row-amount,
    column-gutter: gutter,
    row-gutter: gutter,
    ..tasks-show,
    ..args.named(),
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

#let graphen(
  size: none,
  x: (-5, 5),
  y: (-5, 5),
  step: 1,
  x-step: none,
  y-step: none,
  x-label: [$x$],
  y-label: [$y$],
  grid: "both",
  x-grid: none,
  y-grid: none,
  line-width: 1.5pt,
  samples: 200,
  fills: (),
  ..plots,
  annotations: {},
) = {
  import "@preview/cetz:0.4.2": *
  import "@preview/cetz-plot:0.1.3": *

  // Eigene Farbpalette mit 10 gut unterscheidbaren Farben für Plots
  let colors = (
    rgb("#1F77B4"), // Blau
    rgb("#D62728"), // Rot
    rgb("#2CA02C"), // Grün
    rgb("#FF7F0E"), // Orange
    rgb("#9467BD"), // Violett
    rgb("#8C564B"), // Braun
    rgb("#E377C2"), // Pink
    rgb("#7F7F7F"), // Grau
    rgb("#BCBD22"), // Olivgrün/Gelb
    rgb("#17BECF"), // Cyan
  )

  let plots = plots.pos()

  // Verarbeite die Plots in ein einheitliches Format
  let processed-plots = ()

  if plots.len() > 0 {
    // Array von Plot-Definitionen
    for (index, plot-def) in plots.enumerate() {
      let domain = (x.at(0), x.at(1)) // Standard-Domain
      let term = none
      let clr = colors.at(calc.rem(index, colors.len())) // Rotiere Farben
      let label = none // Label-Definition (position, content)

      if type(plot-def) == function {
        // Nur Funktion übergeben
        term = plot-def
      } else if type(plot-def) == array {
        // Tuple/Array: kann (term), (domain, term) oder (domain, term, color) sein
        // ODER (term, (label: ..., color: ...)) - Funktion + Dictionary mit Optionen
        if plot-def.len() == 1 {
          term = plot-def.at(0)
        } else if plot-def.len() == 2 {
          // Prüfe ob erstes Element eine Domain ist (Array) oder eine Funktion
          if type(plot-def.at(0)) == array {
            domain = plot-def.at(0)
            term = plot-def.at(1)
          } else if type(plot-def.at(0)) == function and type(plot-def.at(1)) == dictionary {
            // (func, (label: ..., color: ...))
            term = plot-def.at(0)
            let opts = plot-def.at(1)
            if "domain" in opts { domain = opts.domain }
            if "clr" in opts { clr = opts.clr }
            if "color" in opts { clr = opts.color }
            if "label" in opts { label = opts.label }
          } else {
            term = plot-def.at(0)
            clr = plot-def.at(1)
          }
        } else if plot-def.len() == 3 {
          // (domain, func, (options)) oder (domain, term, color)
          if type(plot-def.at(0)) == array and type(plot-def.at(2)) == dictionary {
            // (domain, func, (label: ..., color: ...))
            domain = plot-def.at(0)
            term = plot-def.at(1)
            let opts = plot-def.at(2)
            if "clr" in opts { clr = opts.clr }
            if "color" in opts { clr = opts.color }
            if "label" in opts { label = opts.label }
          } else {
            domain = plot-def.at(0)
            term = plot-def.at(1)
            clr = plot-def.at(2)
          }
        } else if plot-def.len() >= 4 {
          domain = plot-def.at(0)
          term = plot-def.at(1)
          clr = plot-def.at(2)
        }
      } else if type(plot-def) == dictionary {
        // Dictionary mit optionalen keys: domain, term, clr, label
        if "domain" in plot-def { domain = plot-def.domain }
        if "term" in plot-def { term = plot-def.term }
        if "clr" in plot-def { clr = plot-def.clr }
        if "color" in plot-def { clr = plot-def.color }
        if "label" in plot-def { label = plot-def.label }
      }

      if term != none {
        processed-plots.push((domain: domain, term: term, clr: clr, label: label))
      }
    }
  }

  // Verarbeite die Fills in ein einheitliches Format
  let processed-fills = ()

  // Normalisiere fills: wenn es direkt eine Funktion ist, mache es zu einem Array
  let fills-array = if type(fills) == function {
    (fills,)
  } else {
    fills
  }

  if fills-array.len() > 0 {
    for (index, fill-def) in fills-array.enumerate() {
      let domain = (x.at(0), x.at(1)) // Standard-Domain
      let lower = none
      let upper = none
      let clr = colors.at(calc.rem(index, colors.len())).saturate(100%).lighten(60%).transparentize(50%) // Rotiere Farben, heller und transparent

      if type(fill-def) == array {
        // Verschiedene Array-Formate:
        // (func) - eine Funktion, zweite ist x-Achse (x => 0)
        // (func1, func2) - zwei Funktionen
        // (domain, func1, func2) - mit Domain
        // (func1, func2, color) - mit Farbe
        // (domain, func1, func2, color) - vollständig

        if fill-def.len() == 1 {
          // Eine Funktion, zweite ist x-Achse
          if type(fill-def.at(0)) == function {
            lower = x => 0
            upper = fill-def.at(0)
          }
        } else if fill-def.len() == 2 {
          // Zwei Funktionen oder (func, color)
          if type(fill-def.at(0)) == function and type(fill-def.at(1)) == function {
            lower = fill-def.at(0)
            upper = fill-def.at(1)
          } else if type(fill-def.at(0)) == function {
            // (func, color)
            lower = x => 0
            upper = fill-def.at(0)
            clr = fill-def.at(1)
          }
        } else if fill-def.len() == 3 {
          // Prüfe ob erstes Element Domain ist (Array) oder Funktion
          if type(fill-def.at(0)) == array {
            // (domain, func1, func2) oder (domain, func, color)
            domain = fill-def.at(0)
            if type(fill-def.at(2)) == function {
              // (domain, func1, func2)
              lower = fill-def.at(1)
              upper = fill-def.at(2)
            } else {
              // (domain, func, color)
              lower = x => 0
              upper = fill-def.at(1)
              clr = fill-def.at(2)
            }
          } else if type(fill-def.at(0)) == function and type(fill-def.at(1)) == function {
            // (func1, func2, color)
            lower = fill-def.at(0)
            upper = fill-def.at(1)
            clr = fill-def.at(2)
          }
        } else if fill-def.len() >= 4 {
          // (domain, func1, func2, color)
          domain = fill-def.at(0)
          lower = fill-def.at(1)
          upper = fill-def.at(2)
          clr = fill-def.at(3)
        }
      } else if type(fill-def) == function {
        // Direkt eine Funktion übergeben
        lower = x => 0
        upper = fill-def
      } else if type(fill-def) == dictionary {
        // Dictionary mit optionalen keys: domain, lower, upper, clr
        if "domain" in fill-def { domain = fill-def.domain }
        if "lower" in fill-def { lower = fill-def.lower }
        if "upper" in fill-def { upper = fill-def.upper }
        if "func1" in fill-def { lower = fill-def.func1 }
        if "func2" in fill-def { upper = fill-def.func2 }
        if "func" in fill-def {
          upper = fill-def.func
          if lower == none { lower = x => 0 }
        }
        if "clr" in fill-def { clr = fill-def.clr }
        if "color" in fill-def { clr = fill-def.color }
      }

      if lower != none and upper != none {
        processed-fills.push((domain: domain, lower: lower, upper: upper, clr: clr))
      }
    }
  }

  // Bestimme die effektive size (int/float für beide Achsen oder Array)
  let (size-x, size-y) = if size == none {
    // Verwende x- und y-Range wenn size nicht angegeben ist
    (calc.abs(x.at(1) - x.at(0)), calc.abs(y.at(1) - y.at(0)))
  } else if type(size) == array {
    (size.at(0), size.at(1))
  } else {
    (size, size)
  }

  // Bestimme den effektiven x-step (Fallback auf step, wenn x-step none ist)
  let effective-x-step = if x-step == none { step } else { x-step }

  // Bestimme den effektiven y-step (Fallback auf step, wenn y-step none ist)
  let effective-y-step = if y-step == none { step } else { y-step }

  // Bestimme das effektive x-grid (Fallback auf grid, wenn x-grid none ist)
  let effective-x-grid = if x-grid == none { grid } else { x-grid }

  // Bestimme das effektive y-grid (Fallback auf grid, wenn y-grid none ist)
  let effective-y-grid = if y-grid == none { grid } else { y-grid }

  // Bestimme x-major-step und x-minor-step
  let (x-major-step, x-minor-step) = if type(effective-x-step) == array {
    (effective-x-step.at(0), effective-x-step.at(1))
  } else {
    (effective-x-step, effective-x-step / 2)
  }

  // Bestimme y-major-step und y-minor-step
  let (y-major-step, y-minor-step) = if type(effective-y-step) == array {
    (effective-y-step.at(0), effective-y-step.at(1))
  } else {
    (effective-y-step, effective-y-step / 2)
  }

  canvas({
    import draw: *
    set-style(
      axes: (
        tick: (offset: -50%, minor-offset: -25%, minor-length: 100%),
        grid: (
          stroke: (paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt),
          fill: none,
        ),
        minor-grid: (
          stroke: (paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt),
          fill: none,
        ),
        mark: (end: "straight"),
        x: (label: (anchor: "south-east", offset: -0.2)),
        y: (label: (anchor: "north-west", offset: -0.2)),
        overshoot: 8pt,
      ),
    )
    plot.plot(
      size: (size-x, size-y),
      name: "plot",
      axis-style: "school-book",
      x-grid: effective-x-grid,
      y-grid: effective-y-grid,
      x-tick-step: x-major-step,
      y-tick-step: y-major-step,
      x-minor-tick-step: x-minor-step,
      y-minor-tick-step: y-minor-step,
      x-label: x-label,
      y-label: y-label,
      x-min: x.at(0),
      x-max: x.at(1),
      y-min: y.at(0),
      y-max: y.at(1),
      {
        plot.add(
          style: (stroke: none),
          domain: (0, 5),
          x => x,
        )
        // Füge alle Fill-Betweens hinzu
        if processed-fills.len() > 0 {
          for f in processed-fills {
            plot.add-fill-between(
              domain: f.domain,
              style: (fill: f.clr, stroke: none),
              f.lower,
              f.upper,
            )
          }
        }
        // Füge alle Plots hinzu
        if processed-plots.len() > 0 {
          for p in processed-plots {
            plot.add(
              style: (stroke: p.clr + line-width),
              samples: samples,
              domain: p.domain,
              p.term,
            )
            if p.label != none and type(p.label) == array and p.label.len() >= 2 {
              let x-pos = p.label.at(0)
              let y-pos = (p.term)(x-pos)
              let label-content = p.label.at(1)
              
              // Optionale Seite (above/below) - Standard ist "above"
              let label-side = if p.label.len() >= 3 { p.label.at(2) } else { "above" }
              
              // Berechne Steigung numerisch für orthogonale Ausrichtung
              let h = 0.0001
              let slope = ((p.term)(x-pos + h) - (p.term)(x-pos - h)) / (2 * h)
              let angle = calc.atan(slope)
              
              // Orthogonaler Winkel (senkrecht zur Tangente)
              // Bei "below" drehe um 180°
              let ortho-angle = if label-side == "below" {
                angle - 90deg
              } else {
                angle + 90deg
              }
              
              plot.annotate({
                content((rel: (radius: 0.4, angle: ortho-angle), to: (x-pos, y-pos)), text(p.clr, label-content), anchor: "west")
              })
            }
          }
        }
        if annotations != {} {
          plot.annotate({
            annotations
          })
        }
      },
    )
  })
}
