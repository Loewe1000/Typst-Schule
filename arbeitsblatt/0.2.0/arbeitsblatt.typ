#import "@schule/aufgaben:0.1.0": *
#import "@schule/random:0.0.1": *
#import "@schule/insert-a-word:0.0.2": *
#import "@schule/energy-sketch:0.0.2": *
#import "@schule/mathematik:0.0.1": *
#import "@schule/patterns:0.0.1": *
#import "@schule/messwerttabellen:0.0.1": datensatz, messdaten, messwerttabelle, berechnung
#import "@schule/operatoren:0.0.1": operator, operatoren-liste
#import "@preview/fontawesome:0.5.0": *
#import "@preview/cades:0.3.0": qr-code
#import "@preview/cetz:0.3.1": *
#import "@preview/cetz-plot:0.1.0": *
#import "@preview/codly:1.0.0": *
#import "@preview/colorful-boxes:1.3.1": *
#import "@preview/tablex:0.0.8": *
#import "@preview/unify:0.6.0": *

#let print-state = state("print", false)

/// Creates a new arbeitsblatt
///
/// - title (string): Title of the document.
/// - class (string): Desired class ex. IF-11.
/// - paper (string): Page size.
/// - print (boolean): Difffernt margins for printing.
/// - equal-margins (boolean): A document for used in printing but not intended for attaching in a physical folder
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
  equal-margins: false,
  duplex: true,
  workspaces: false,
  font-size: 12pt,
  title-font-size: 16pt,
  landscape: false,
  custom-header: none,
  header-ascent: 20%,
  page-settings: (),
  loesungen: "false",
  copyright: none,
  ..args,
  body,
) = {
  // Set document title and authors in metadata
  // Set font and text properties
  set par(justify: true, leading: 0.65em, linebreaks: "optimized")

  set text(font-size, font: "Myriad Pro", hyphenate: true, lang: "de")
  show math.equation: set text(font: "Fira Math")
  show math.equation: it => {
    show regex("\d+\.\d+"): it => {
      show ".": {
        "," + h(0pt)
      }
      it
    }
    it
  }

  let header(title: none, class: none, font-size: 16pt, copyright: none) = {
    text(font-size, font: "Myriad Pro", weight: "semibold")[#title]
    h(1fr)

    if copyright != none {
      box(qr-code(copyright, width: 0.9em, color: luma(130)))
      h(0.5em)
    }


    text(
      font-size,
      font: "Myriad Pro",
      weight: "semibold",
      fill: luma(130),
    )[#class]
    move(dy: -.4em, line(length: 100%, stroke: 0.5pt + luma(200)))
  }

  // Set page properties
  set page(
    paper: paper,
    ..if not print {
      if landscape {
        (width: auto)
      } else {
        (height: auto)
      }
    },
    flipped: landscape,
    header-ascent: header-ascent,
    margin: if print {
      if landscape {
        (top: 2.2cm + 1.5cm, x: 1.75cm, bottom: 1cm)
      } else {
        if duplex {
          (top: 2.2cm, inside: 2.25cm, outside: 1.25cm, bottom: 1cm)
        } else {
          if equal-margins {
            (top: 2.2cm, x: 1.75cm, bottom: 1.75cm)
          } else {
            (top: 2.2cm, left: 2.25cm, right: 1.25cm, bottom: 1cm)
          }
        }
      }
    } else {
      (top: 2.2cm, x: 1.75cm, bottom: 1cm)
    },
    header: if custom-header == none {
      header(title: title, class: class, font-size: title-font-size, copyright: copyright)
    } else {
      custom-header
    },
    ..page-settings,
  )

  set_options((
    "loesungen": loesungen,
    "workspaces": workspaces,
    "punkte": "keine",
    "print": print
  ))

  print-state.update(_ => {
    print
  })

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
    #text(
      size: 9pt,
      [
        #grid(
          columns: 2,
          column-gutter: if it.numbering != none {
            4pt
          } else {
            0pt
          },
          align: top,
          [#if it.numbering != none [*M#counter("aufgaben").get().at(0).#counter(figure).display()*:] ], [#if it.caption != none [#align(left, it.caption.body)]],
        )
      ],
    )
  ]

  show ref: it => {
    let el = it.element
    if el != none and el.func() == figure {
      // Override figure references.
      [*M#counter("aufgaben").get().at(0).#numbering(el.numbering, ..counter(figure).at(el.location()))*]
    } else {
      // Other references as usual.
      it
    }
  }

  show: codly-init.with()
  codly(display-name: false)
  set raw(syntaxes: "processing.sublime-syntax")

  body

  // To show solutions on a seperate page
  if loesungen in ("seite", "seiten") {
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
      body
    },
  )
}

#let print-pagebreak() = {
  context {
    let print = print-state.get()
    if print {
      pagebreak()
    }
  }
}

#let non-print-pagebreak() = {
  context {
    let print = print-state.get()
    if not print {
      pagebreak()
    }
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

#let icon-link(url, name, icon: fa-external-link(fill: blue)) = {
  link(url)[#icon #text(fill: blue, [#name])]
}

#let qrbox(url, name, width: 3cm, ..args) = {
  stickybox(width: width, ..args)[
    #qr-code(url, width: width - 0.5cm, background: rgb(255, 255, 255, 0))
    #align(
      center,
      text(
        size: 8pt,
        [
          #v(-1em)
          #icon-link(url, name)
        ],
      ),
    )
  ]
}

#let mono(body) = text(font: "SF Mono", body)
