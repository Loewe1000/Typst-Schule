#import "@schule/aufgaben:0.1.1": *
#import "@schule/random:0.0.1": *
#import "@schule/insert-a-word:0.0.2": *
#import "@schule/energy-sketch:0.0.2": *
#import "@schule/mathematik:0.0.2": tasks
#import "@schule/patterns:0.0.1": *
#import "@schule/messwerttabellen:0.0.1": datensatz, messdaten, messwerttabelle, berechnung
#import "@schule/operatoren:0.0.1": operator, operatoren-liste
#import "@preview/fontawesome:0.5.0": *
#import "@preview/cades:0.3.0": qr-code
#import "@preview/cetz:0.3.4": *
#import "@preview/cetz-plot:0.1.1": *
#import "@preview/codly:1.2.0": *
#import "@preview/colorful-boxes:1.3.1": *
#import "@preview/tablex:0.0.9": *
#import "@preview/unify:0.7.1": *

#let print-state = state("print", false)
#let material-counter = counter("material")

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
  font: "Myriad Pro",
  math-font: "Fira Math",
  title-font-size: 16pt,
  figure-font-size: 9pt,
  landscape: false,
  custom-header: none,
  teilaufgabe-numbering: "a)",
  header-ascent: 20%,
  page-settings: (),
  loesungen: "false",
  copyright: none,
  punkte: "keine",
  ..args,
  body,
) = {
  // Set document title and authors in metadata
  // Set font and text properties
  set par(justify: true, leading: 0.65em, linebreaks: "optimized")

  set text(font-size, font: font, hyphenate: true, lang: "de")
  show math.equation: set text(font: math-font)
  show math.equation: it => {
    show regex("\d+\.\d+"): it => {
      show ".": {
        "," + h(0pt)
      }
      it
    }
    it
  }

  set heading(
    numbering: "1.",
    supplement: none,
  )

  show ref: it => {
    let el = it.element
    if el != none and el.func() == figure and el.kind in (image, table) {
      let material-counter = counter(figure.where(kind: image)).at(el.location()).first() + counter(figure.where(kind: table)).at(el.location()).first()
      "M" + numbering("1a", counter("material").at(el.location()).first(), material-counter)
    } else if el != none and el.func() == figure and el.kind == "teilaufgabe" {
      context {
        if _state_options.get().at("teilaufgabe-numbering", default: "1.") == "1." {
          numbering("1.1", counter(figure.where(kind: "aufgabe")).at(el.location()).first(), counter(figure.where(kind: "teilaufgabe")).at(el.location()).first())
        } else if _state_options.get().at("teilaufgabe-numbering", default: "1.") == "a)" {
          numbering("a)", counter(figure.where(kind: "teilaufgabe")).at(el.location()).first())
        }
      }
    } else {
      // Other references as usual.
      it
    }
  }

  let header(title: none, class: none, font-size: 16pt, copyright: none) = {
    text(font-size, font: font, weight: "semibold")[#title]
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
    "punkte": punkte,
    "print": print,
    "teilaufgabe-numbering": teilaufgabe-numbering,
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
  set figure(numbering: "1", supplement: none)
  show figure.where(kind: image).or(figure.where(kind: table)): it => {
    context {
      let header_count = counter("material").get().first()
      let thm_count = counter(figure.where(kind: image)).at(it.location()).first() + counter(figure.where(kind: table)).at(it.location()).first()
      let thm_num = if header_count > 0 {
        "M" + numbering("1a", header_count, thm_count)
      } else {
        "M" + numbering("1.", thm_count)
      }
      set align(left)
      align(center)[
        #it.body
        #v(10pt, weak: true)
        #text(
          size: figure-font-size,
          [
            #grid(
              columns: 2,
              column-gutter: if it.numbering != none {
                4pt
              } else {
                0pt
              },
              align: top,
              strong(thm_num), [#if it.caption != none [#align(left, it.caption.body)]],
            )
          ],
        )
      ]
    }
  }

  show figure.where(kind: "teilaufgabe"): it => align(
    left,
    [
      #it.body
    ],
  )

  show: codly-init.with()
  codly(display-name: false)
  set raw(syntaxes: "processing.sublime-syntax")

  body

  // To show solutions on a seperate page
  if loesungen in ("seite", "seiten") {
    d_loesungen()
  }
}

#let material(nummer) = {
  counter("material").update(nummer)
  counter(figure.where(kind: image)).update(0)
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

#let icon-link(url, name, icon: emoji.chain) = {//fa-external-link(fill: blue)
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

#let workspace(height: 5cm, body) = {
  context {
    let options = _state_options.get()
    if options.at("workspaces", default: false) {
      body
    }
  }
}
