#import "@local/aufgaben:0.0.1": *
#import "@local/options:0.0.5"
#import "@preview/cetz:0.0.1"

#let header(title: none, class: none) = {
  text(16pt,font: "Myriad Pro", weight: "semibold")[#title]
  h(1fr) 
  text(16pt, font: "Myriad Pro", weight: "semibold", fill: luma(130))[#class] 
  move(dy:-.4em, line(length: 100%, stroke: 0.5pt + luma(200)))
}

#let arbeitsblatt(title: "", class: "", ..args, body) = {
  // Set the document's basic properties.
  set document(author: "Lukas Köhl", title: title)
  set page(paper: "a4", 
  margin: (top: 2.2cm, x: 1.75cm, bottom: 1.5cm), 
  header: header(title: title, class: class),
  header-ascent: 20%
  )

  options.addconfig("loesungen", default:"")
  options.parseconfig(..args)

  show heading: it => block[
    #set text(12pt, weight: 700)
    #it.body
    #v(4pt)
  ]
  
  set enum(numbering: "a)")

  // Main body
  set par(justify: true, leading: 1em)
  set text(10pt, font: "Myriad Pro")
  
  body
  
}

#let kariert(height: 1, width: auto) = {
  layout(size => {
    cetz.canvas(length:0.5cm,{ import cetz.draw: *
    set-style(stroke: (paint: black.lighten(50%), thickness: 0.5pt))
    if width != auto {
      grid((0,0), (width,height))
    } else {
      grid((0,0), (calc.round((size.width/0.5cm)),height))
    }
    })
  })
}

#let liniert(rows: 1, width: auto, lineheight: 1cm) = {
  move(dy: lineheight * 0.5)[
  #layout(size => {
    cetz.canvas(length:lineheight,{ import cetz.draw: *
    set-style(stroke: (paint: black.lighten(50%), thickness: 0.5pt))
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
}


#let tasks(tasks:(), amount:auto) = {
  let row-amount = tasks.len()
  if amount != auto {
    row-amount = amount
  } 
  grid(columns: (1fr,) * row-amount, column-gutter: 20pt, row-gutter: 15pt, ..tasks.map(task => {teilaufgabe(task)}))
} 