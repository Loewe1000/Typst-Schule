#import "@schule/aufgaben:0.0.1": *
#import "@schule/options:0.0.5"
//#import "@preview/metro:0.1.0": *
#import "@preview/cetz:0.1.2": *
#import "@preview/tablex:0.0.6": *
#import "@schule/random:0.0.1": *
#import "@preview/codetastic:0.2.2": qrcode

#let header(title: none, class: none, font-size: 16pt) = {
  text(font-size,font: "Myriad Pro", weight: "semibold")[#title]
  h(1fr) 
  text(font-size, font: "Myriad Pro", weight: "semibold", fill: luma(130))[#class] 
  move(dy:-.4em, line(length: 100%, stroke: 0.5pt + luma(200)))
}

#let arbeitsblatt(title: "", class: "", paper:"a4", print:false, font-size:12pt, header-font-size:16pt, landscape: false, custom-header: none, header-ascent: 20%, page-settings:(), ..args, body) = {
  // Set the document's basic properties.
  if type(title) == str {
    set document(author: "Alexander Schulz", title: title)
  }
  set page(paper: paper, 
  flipped: landscape,
  ..if print {
    (margin: (top: 2.2cm, inside: 2.25cm, outside: 1.25cm, bottom: 1.5cm))
  } else {
    (margin: (top: 2.2cm, x: 1.75cm, bottom: 1.5cm))
  },
  header: if custom-header != none {
    custom-header
  } else {
    header(title: title, class: class, font-size:header-font-size)
  },
  header-ascent: header-ascent,
  ..page-settings
  )

  /*metro-setup(
    output-decimal-marker: ",",
    //per-mode: "fraction", 
    quantity-product: sym.space,
    exponent-product: sym.dot
  )*/

  /*show math.equation: it => {
    show regex("\d+\.\d+"): it => {show ".": {","+h(0pt)}
        it}
    it
  }*/

  show math.equation: set text(font: "Fira Math")

  options.addconfig("loesungen", default:"")
  options.parseconfig(..args)

  show heading.where(
    level: 1
  ): it => block[
    #set text(14pt, weight: 700)
    #it.body
    #v(4pt)
  ]

  show heading.where(
    level: 2
  ): it => block[
    #set text(12pt, weight: 700)
    #it.body
  ]

  // Main body
  set par(justify: true, leading: 0.65em)

  set text(font-size, font: "Myriad Pro", hyphenate: true, lang: "de")

  set figure(numbering: none)

  show figure: it => align(center)[
    #it.body
    #v(10pt, weak: true)
    #text(size:9pt,[
     #grid(columns: 2, column-gutter: if it.numbering != none {4pt} else {0pt},
        [#if it.numbering != none [*M#it.counter.display(it.numbering)*:] ],
        [#align(left, it.caption.body)]
      ) 
    ])
    ]

  show ref: it => {
    let el = it.element
    if el != none and el.func() == figure {
      // Override figure references.
      [*M#numbering(
        el.numbering,
        ..counter(figure).at(el.location())
      )*]
    } else {
      // Other references as usual.
      it
    }
  }
  body
  
}

 
#let centering(body) = {
  align(center, body)
}

#let minipage(columns:(1fr,1fr), align: horizon, spacing: 5mm, ..args, body) = {
  table(stroke: none,
    columns:columns,
    align: align,
    inset: 0pt,
    column-gutter: spacing,
     ..args, body)
}

#let kariert(height: 1, width: auto, cnt: (), cnt-spacing: 1.5cm, grid-size: 0.5cm) = {
  layout(size => {
    let autoheight
    if cnt.len() != 0 and height == 1 {
      autoheight = cnt.len() * 1.5cm - grid-size
    } else {
      autoheight = height
    }
    canvas(length:grid-size,{ import draw: *
    set-style(stroke: (paint: black.lighten(50%), thickness: 0.5pt))
    if width != auto {
      grid((0,0), (width,autoheight))
    } else {
      grid((0,0), (calc.round((size.width/grid-size)),autoheight))
    }
    if cnt.len() != 0 {
      for (key, item) in cnt.enumerate() {
        content((0.75,autoheight - grid-size - key * cnt-spacing),[#box(fill: white, inset: 4pt)[#item]],anchor: "left")
      }
    }
    })
  })
}

#let liniert(rows: 1, width: auto, lineheight: 1cm) = {
  move(dy: lineheight * 0.5)[
  #layout(size => {
    canvas(length:lineheight,{ import draw: *
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

#let klausurbogen(start-even: false, pages:1, rand: 6cm, inline: false) = {
  if inline {
    layout(size => {
      place(dx: -1.75cm - 6cm, kariert(height:size.height, width: 21cm))
    })
  } else {
    locate((loc) => [
        #if start-even and calc.rem(loc.position().page,2) == 1 {
          page(header:none,[])
        }
        #for _ in range(pages) {
          page(paper: "a4", 
            margin: (top: 0cm, inside:0cm, outside:rand, bottom: 0cm), 
            header: none,
            [#layout(size => {    
              kariert(height:size.height)
            })]
        )
        }
      ]) 
  }
}

#let tasks(tasks:(), amount:auto, numbering:"a)", gutter:20pt, loesungen:()) = {
  let row-amount = tasks.len()
  if amount != auto {
    row-amount = amount
  }
  let tasks-show = ()
  for (key, task) in tasks.enumerate() {
    tasks-show.push([
      #teilaufgabe(numb:numbering)[
        #task
        #if loesungen.len() > key [
          #loesung[#loesungen.at(key)]
        ]
      ]
    ])
  }

  grid(columns: (1fr,) * row-amount, column-gutter: gutter, row-gutter: gutter,
  ..tasks-show)
  
}


#let gap(body) = {
  box(move(dy:6pt)[
    #box(stroke: (bottom: 0.5pt + luma(130)), inset: (x: 8pt, y: 0pt))[
      #hide(body) #label("gap")
    ]
  ])
}

#let gap-text(hide-gaps: false, body) = {
  let colors = (rgb("#B3D4EC"), rgb("#D5E3B5"), rgb("#EEAA95"), rgb("#FAD3AD"), rgb("#CBADC8"), rgb("#FFE3A8"))

  align(center,
  locate(loc => {
  let elems = query(<gap>, loc)
  if not hide-gaps {
    for (index,word) in shuffle(elems, 42).enumerate() [
      #h(0.4em)
      #box(
        block(
          fill: colors.at(calc.rem(index ,colors.len())),
          inset: 8pt,
          radius: 4pt)[#word.body]
      )
      #h(0.4em)
    ]
  }
  })
  
  )
  par(leading: 1.5em, body)
}

#let qrbox(url, name, width: 3cm, ..args) = {
  stickybox(width: width, ..args)[
    #qrcode(url, colors: (rgb(255,255,255,0), black), width: width - 0.5cm, quiet-zone: 0)
    #centering[
      #text(size:8pt,[
        #link(url)[#fa-external-link(fill:blue) #text(fill:blue,[#name])]
      ])
    ]
  ]
}

#let icon-link(url, name) = {
  link(url)[#fa-external-link(fill:blue) #text(fill:blue,[#name])]
}