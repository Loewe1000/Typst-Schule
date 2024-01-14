#import "@schule/aufgaben:0.0.1": *
#import "@schule/options:0.0.5"
#import "@schule/random:0.0.1": *
#import "@schule/insert-a-word:0.0.1": *
#import "@schule/energy-sketch:0.0.1": *
#import "@schule/mathematik:0.0.1": *

#import "@preview/cades:0.3.0": qr-code
#import "@preview/cetz:0.1.2": *
#import "@preview/colorful-boxes:1.2.0": *
#import "@preview/tablex:0.0.7": *
#import "@preview/unify:0.4.3": *

#let header(title: none, class: none, font-size: 16pt) = {
  text(font-size, font: "Myriad Pro", weight: "semibold")[#title]
  h(1fr)
  text(
    font-size,
    font: "Myriad Pro",
    weight: "semibold",
    fill: luma(130),
  )[#class]
  move(dy: -.4em, line(length: 100%, stroke: 0.5pt + luma(200)))
}

/// Creates a new arbeitsblatt
///
/// - title (string): Title of the document.
/// - class (string): Desired class ex. IF-11.
/// - paper (string): Page size.
/// - print (boolean): Difffernt margins for printing.
/// - font-size (length): Document font size.
/// - title-font-size (length): title font size.
/// - landscape (boolean): Page orientation.
/// - custom-header (module): Set a custom header
/// - header-ascent (percentage): Raise or lower the header
/// - page-settings (dicitonary): Optional arguments passed to page
/// - loesungen (string): To show solutions, use "seite", "folgend", "sofort"
/// - ..args (any): Optional arguments.
#let arbeitsblatt(
  title: "",
  class: "",
  paper: "a4",
  author: (),
  print: false,
  font-size: 12pt,
  title-font-size: 16pt,
  landscape: false,
  custom-header: none,
  header-ascent: 20%,
  page-settings: (),
  loesungen: none,
  ..args,
  body,
) = {
  // Set document title and authors in metadata
  if type(title) == str {
    set document(author: author, title: title)
  } else {
    set document(author: author)
  }

  // Set font and text properties
  set par(justify: true, leading: 0.65em)
  set text(font-size, font: "Myriad Pro", hyphenate: true, lang: "de")
  show math.equation: set text(font: "Fira Math")
  show math.equation: it => {
    show regex("\d+\.\d+"): it => {show ".": {","+h(0pt)}
        it}
    it
  }

  // Set page properties
  set page(
    paper: paper,
    flipped: landscape,
    header-ascent: header-ascent,
    margin: if print {
      (top: 2.2cm, inside: 2.25cm, outside: 1.25cm, bottom: 1.5cm)
    } else {
      (top: 2.2cm, x: 1.75cm, bottom: 1.5cm)
    },
    header: if custom-header == none {
      header(title: title, class: class, font-size: title-font-size)
    } else {
      custom-header
    },
    ..page-settings,
  )

  // To show solutions for exercises: use "loesungen: "sofort""
  options.addconfig("loesungen", default: "")
  options.parseconfig(loesungen: loesungen)

  // font-size for aufgaben, large and small
  show heading.where(level: 1): it => block[
    #set text(14pt, weight: 700)
    #it.body
    #v(4pt)
  ]

  show heading.where(level: 2): it => block[
    #set text(12pt, weight: 700)
    #it.body
  ]

  // Setting captions and numberings for figures
  set figure(numbering: "1")

  show figure: it => align(center)[
    #it.body
    #v(10pt, weak: true)
    #text(size: 9pt, [
      #grid(
        columns: 2,
        column-gutter: if it.numbering != none { 4pt } else { 0pt },
        [#if it.numbering != none [*M#it.counter.display(it.numbering)*:] ],
        [#if it.caption != none [#align(left, it.caption.body)]],
      )
    ])
  ]

  show ref: it => {
    let el = it.element
    if el != none and el.func() == figure {
      // Override figure references.
      [*M#numbering(el.numbering, ..counter(figure).at(el.location()))*]
    } else {
      // Other references as usual.
      it
    }
  }

  body

  // To show solutions on a seperate page
  if loesungen == "seite" {
    d_loesungen()
  }
}

/// Splits text into multiple columns
///
/// - columns (array): Definitions of columns.
/// - align (???): Alignment inside the column.
/// - ..args (any): Optional arguments.
#let minipage(columns: (1fr, 1fr), align: horizon, spacing: 5mm, ..args, body) = {
  table(
    stroke: none,
    columns: columns,
    align: align,
    inset: 0pt,
    column-gutter: spacing,
    ..args,
    body,
  )
}

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
            (0.75, autoheight - grid-size - key * items-spacing * grid-size),
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

#let icon-link(url, name) = {
  link(url)[#fa-external-link(fill: blue) #text(fill: blue, [#name])]
}

#let qrbox(url, name, width: 3cm, ..args) = {
  stickybox(width: width, ..args)[
    #qr-code(url, width: width - 0.5cm, background: rgb(255, 255, 255, 0))
    #align(center, text(size: 8pt, [
      #v(-1em)
      #icon-link(url, name)
    ]))
  ]
}

