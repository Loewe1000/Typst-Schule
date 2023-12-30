#import "@preview/tablex:0.0.4": tablex, colspanx, rowspanx, vlinex,
#import "@preview/cetz:0.1.2": *
#import "@schule/random:0.0.1": *

#let c_canvas = canvas
#let canvas(..args, body) = {
  c_canvas(..args, {import draw: * 
  set-style(
    axes: (
      fill: none, stroke: rgb("#000000"), tick: (
      fill: none,
      stroke: rgb("#000000"),
      length: 0.1,
      minor-length: 0.08,
      label: (offset: 0.1, angle: 0deg, anchor: auto), ),
      padding: 0,
      grid: (
        stroke: (paint: rgb("#AAAAAA").lighten(30%), dash: "solid"),
        fill: none ),
      ),)
  body})
}

#let fkt-plot(term, clr, x, y, size: 2.5, text-scale: 1, x-ticks: true, y-ticks: true) = text(size: text-scale * 1em, canvas(length: 1cm, {
  import draw: *
  plot.plot(size: (size, size),
    axis-style: "school-book",
    x-tick-step: if x-ticks {calc.ceil((x.at(1) - x.at(0)) / 8)} else {none},
    y-tick-step: if y-ticks {calc.ceil((y.at(1) - y.at(0)) / 8)} else {none},
    x-label:"",
    y-label:"",
    x-grid: "both",
    y-grid: "both",
    x-min: x.at(0)*0.99,
    x-max: x.at(1)*0.99,
    y-min: y.at(0)*0.99,
    y-max: y.at(1)*0.99,
    {
      plot.add(
        style:(stroke: clr + 1.5pt),
        domain: x,
        term
      )
    }
  )
  content(((size/2)+0.25, size - 0.2),[$y$])
  content((size - 0.2, (size/2)+0.25),[$x$])
}))

#let nbx(nmb, clr) = move(dx:-1mm, dy:-1mm,[#box(fill: clr, inset: 1.5mm, radius: (top-left:2mm, top-right:0mm, bottom-left:0mm, bottom-right:2mm))[#text(fill: white, [#nmb])]])

#let nbr = counter("nbr")
#let rand = counter("rand")

#let colors = (red, blue, green, purple, orange, maroon, yellow.darken(10%), aqua.darken(10%))

#let fkt-graph-card(fkt, clr:none, x: (-2,2), y: (-2,2), size: 2.5cm, text-scale: 1, x-ticks: true, y-ticks: true,) = block()[
  #nbr.step()
  
  #locate(loc => [
    #let color = if clr == none {shuffle(colors, counter("rand").at(loc).at(0)).at(counter("nbr").at(loc).at(0))} else {clr}
    #box(width: size+2pt, height: size+2pt, stroke: color+2pt, inset:1mm, fill: color.lighten(90%), radius: 2mm)[
      #place(center+horizon,fkt-plot(fkt, color, x, y, size: size / 1cm, text-scale: text-scale, x-ticks:x-ticks, y-ticks:y-ticks))
      #place(top+left,nbx(nbr.display(), color))
    ]
  ])
]

#let fkt-term-card(fkt, clr:rgb("#FFF099"), text-scale: 1) = box(stroke: clr.darken(10%).saturate(200%), inset:4mm, fill: clr, radius: 1mm)[
      #fkt
]