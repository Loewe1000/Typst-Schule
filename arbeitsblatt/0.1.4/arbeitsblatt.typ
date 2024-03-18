#import "@schule/typopst:0.0.1": *
#import "@schule/aufgaben:0.0.2": *
#import "@schule/random:0.0.1": *
#import "@schule/insert-a-word:0.0.1": *
#import "@schule/energy-sketch:0.0.1": *
#import "@schule/mathematik:0.0.1": *
#import "@schule/patterns:0.0.1": *  

#import "@preview/cades:0.3.0": qr-code
#import "@preview/cetz:0.2.2": *
#import "@preview/colorful-boxes:1.3.1": *
#import "@preview/tablex:0.0.8": *
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
  print: false,
  font-size: 12pt,
  title-font-size: 16pt,
  landscape: false,
  custom-header: none,
  header-ascent: 20%,
  page-settings: (),
  loesungen: "false",
  ..args,
  body,
) = {
  // Set document title and authors in metadata

  // Set font and text properties
  set par(justify: true, leading: 0.65em, linebreaks: "optimized")

  set text(font-size, font: "Myriad Pro", hyphenate: true, lang: "de")
  show math.equation: set text(font: "STIX Two Math")
  show math.equation: it => {
    show regex("\d+\.\d+"): it => {show ".": {","+h(0pt)}
        it}
    it
  }

  // Set page properties
  set page(
    paper: paper,
    ..if not print {(height: auto)} ,
    flipped: landscape,
    header-ascent: header-ascent,
    margin: if print {
      if landscape {
        (top: 2.2cm + 1.5cm, x: 1.75cm, bottom: 1cm)
      } else {
        (top: 2.2cm, inside: 2.25cm, outside: 1.25cm, bottom: 1cm)
      }
    } else {
      (top: 2.2cm, x: 1.75cm, bottom: 1cm)
    },
    header: if custom-header == none {
      header(title: title, class: class, font-size: title-font-size)
    } else {
      custom-header
    },
    ..page-settings,
  )

  // To show solutions for exercises: use "loesungen: "sofort""
  options.add-argument("loesungen", default: "")
  options.add-argument("print", default: "false")

  options.parseconfig(loesungen: loesungen, print: if print {"true"} else {"false"} )

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

  // In CeTZ-Diagrammen keine gestrichelten Linien mehr haben
  // + Position der Achsenbeschriftungen innen statt außen

  #let c_canvas = canvas
  #let canvas(..args, body) = {
    c_canvas(
      ..args,
      {
        import draw: *
        set-style(
          axes: (
            grid: (
              stroke: (paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt),
              fill: none,
            ),
            minor-grid: (
              stroke: (paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt),
              fill: none,
            ),
            mark: (end: ">"),
            x: (label: (anchor: "south-east", offset: -0.2)),
            y: (label: (anchor: "north-west", offset: -0.2)),
          ),
        )
        body
      },
    )
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


#let icon-link(url, name, icon:fa-external-link(fill: blue)) = {
  link(url)[#icon #text(fill: blue, [#name])]
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

