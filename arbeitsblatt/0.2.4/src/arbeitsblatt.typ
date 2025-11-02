#import "@schule/aufgaben:0.1.2": *
#import "@schule/random:0.0.1": *
#import "@schule/insert-a-word:0.0.3": *
#import "@schule/energy-sketch:0.0.2": *
#import "@schule/patterns:0.0.1": *
#import "@preview/eqalc:0.1.3": *
#import "@preview/zero:0.5.0": *
#import "@schule/mathematik:0.0.2": graphen, teilaufgaben, steckbrief, kreisdiagramm
#import "@schule/informatik:0.0.2": *
#import "@schule/physik:0.0.2": (
  // Tabellen und Daten
  berechnung,
  datensatz,
  messdaten,
  messwerttabelle,
  pk,
  // Regression
  lineare_regression,
  quadratische_regression,
  wurzel_regression,
  exponentielle_regression,
  polynom_regression,
  potenz_regression,
  // Schaltkreis-Basis
  schaltkreis,
  zap,
  // Komponenten
  source,
  multimeter,
  lamp,
  amperemeter,
  voltmeter,
  motor,
  generator,
)
#import "@schule/operatoren:0.0.1": operator, operatoren-liste
#import "@preview/fontawesome:0.6.0": *
#import "@preview/rustycure:0.1.0": qr-code
#import "@preview/cetz:0.4.2": *
#import "@preview/cetz-plot:0.1.2": *
#import "@preview/codly:1.3.0": *
#import "@preview/colorful-boxes:1.4.3": *
#import "@preview/fancy-units:0.1.1": add-macros, fancy-units-configure, num, qty, unit

#let qty_old = qty

#let qty(..args) = {
  add-macros(
    u: sym.mu,
    ohm: sym.Omega,
  )
  let positional = args.pos()
  if positional.len() == 2 and type(positional.at(0)) in (str, int, float) and type(positional.at(1)) == str {
    let named = args.named()
    if named != () {
      return qty_old(..named)[#positional.at(0)][#positional.at(1)]
    }
    return qty_old[#positional.at(0)][#positional.at(1)]
  } else {
    return qty_old(..args)
  }
}

#let num_old = num

#let num(..args) = {
  add-macros(
    u: sym.mu,
    ohm: sym.Omega,
  )
  let positional = args.pos()
  if positional.len() == 1 and type(positional.at(0)) in (str, int, float) {
    let named = args.named()
    if named != () {
      return num_old(..named)[#positional.at(0)]
    }
    return num_old[#positional.at(0)]
  } else {
    return num_old(..args)
  }
}

#let unit_old = unit

#let unit(..args) = {
  add-macros(
    u: sym.mu,
    ohm: sym.Omega,
  )
  let positional = args.pos()
  if positional.len() == 1 and type(positional.at(0)) in (str, int, float) {
    let named = args.named()
    if named != () {
      return unit_old(..named)[#positional.at(0)]
    }
    return unit_old[#positional.at(0)]
  } else {
    return unit_old(..args)
  }
}

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
/// - teilaufgabe-numbering (string): Numbering of sub-tasks, either "a)" or "1."
/// - workspaces (boolean): Whether to include workspaces for tasks.
/// - font (string): Main document font.
/// - math-font (string): Math font.
/// - figure-font-size (length): Font size for figure captions.
/// - materialien (string): To show materials, use "seiten", "folgend", "sofort"
/// - punkte (string): To show points, use "keine", "aufgaben", "teilaufgaben", "alle"
/// - aufgaben-shortcode (string): To show tasks and sub-tasks as shortcodes, use "false", "aufgaben", "teilaufgaben", "alle"
/// - page-settings (dicitonary): Optional arguments passed to page
/// - loesungen (string): To show solutions, use "seite", "folgend", "sofort"
/// - ..args (any): Optional arguments.
#let arbeitsblatt(
  title: "",
  class: "",
  paper: "a4",
  print: false,
  duplex: true,
  workspaces: true,
  font-size: 12pt,
  font: "Myriad Pro",
  math-font: "Fira Math",
  title-font-size: 16pt,
  figure-font-size: 9pt,
  landscape: false,
  custom-header: none,
  teilaufgabe-numbering: "a)",
  page-settings: (:),
  loesungen: "false",
  materialien: "seiten",
  punkte: "keine",
  aufgaben-shortcodes: "alle",
  copyright: none,
  ..args,
  body,
) = {
  // Set document title and authors in metadata
  // Set font and text properties
  set par(justify: true, leading: 0.65em, linebreaks: "optimized")

  set text(font-size, font: font, hyphenate: true, lang: "de")
  show math.equation: it => {
    show text: it2 => {
      set text(font: font)
      it2
    }
    set text(font: math-font)
    it
  }

  show math.equation: it => {
    show regex("\d+\.\d+"): num => num.text.replace(".", ",")
    it
  }

  set heading(
    numbering: "1.",
    supplement: none,
  )

  show ref: it => {
    let el = it.element
    if el != none and el.func() == figure and el.kind == "material" {
      context {
        let current-aufgabe = _state_current_material_aufgabe.at(el.location())
        let material-index = _state_current_material_index.at(el.location())

        // Fallback falls nicht in Material-Sektion
        if current-aufgabe == 0 {
          current-aufgabe = _counter_aufgaben.get().at(0)
          material-index = counter(figure.where(kind: "material")).at(el.location()).first()
        }

        "M" + str(current-aufgabe) + "-" + numbering("A", material-index)
      }
    } else if el != none and el.func() == figure and el.kind == "teilaufgabe" {
      context {
        if _state_options.get().at("teilaufgabe-numbering", default: "1.") == "1." {
          numbering(
            "1.1",
            counter(figure.where(kind: "aufgabe")).at(el.location()).first(),
            counter(figure.where(kind: "teilaufgabe")).at(el.location()).first(),
          )
        } else if _state_options.get().at("teilaufgabe-numbering", default: "1.") == "a)" {
          numbering("a)", counter(figure.where(kind: "teilaufgabe")).at(el.location()).first())
        }
      }
    } else if el != none and el.func() == figure and (el.kind == image or el.kind == table) {
      "A" + it
    } else {
      // Other references as usual.
      it
    }
  }

  let header(title: none, class: none, font-size: 16pt, copyright: none) = {
    text(font-size, font: font, weight: "semibold")[#title]
    h(1fr)

    if copyright != none {
      box(qr-code(copyright, width: 0.9em, dark-color: "#828282"))
      h(0.5em)
    }

    text(
      font-size,
      font: font,
      weight: "semibold",
      fill: luma(130),
    )[#class]
    move(dy: -.4em, line(length: 100%, stroke: 0.5pt + luma(200)))
  }

  context {
    let header-height = measure(custom-header, width: page.width).height
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
      header-ascent: if "header-ascent" in args.named().keys() {
        args.named().at("header-ascent")
      } else {
        20%
      },
      // Margin-Logik: Prüfe zuerst page-settings.margin, dann Standard-Margins
      margin: if "margin" in page-settings.keys() {
        // Wenn explizit ein Margin in page-settings gesetzt wurde, verwende dieses
        let top = if type(page-settings.margin) == dictionary { page-settings.margin.at("top", default: 0cm) } else {
          page-settings.margin
        }
        let values = page-settings.margin
        let _ = if type(values) == dictionary {
          values.remove("top")
          values.insert("top", top + header-height)
        }
        values
      } else {
        // Ansonsten verwende die Standard-Margins basierend auf print/landscape/duplex
        if print {
          if landscape {
            (top: 2.3cm + header-height, x: 1.75cm, bottom: 1cm)
          } else {
            if duplex {
              (top: 2.3cm + header-height, inside: 2.25cm, outside: 1.25cm, bottom: 1cm)
            } else {
              (top: 2.3cm + header-height, left: 2.25cm, right: 1.25cm, bottom: 1cm)
            }
          }
        } else {
          (top: 2.2cm + header-height, x: 1.75cm, bottom: 1cm)
        }
      },
      header: if custom-header == none {
        header(title: title, class: class, font-size: title-font-size, copyright: copyright)
      } else {
        custom-header
      },
      // Alle anderen page-settings außer margin anwenden
      ..{
        let filtered-settings = (:)
        for (key, value) in page-settings.pairs() {
          if key != "margin" {
            filtered-settings.insert(key, value)
          }
        }
        filtered-settings
      },
    )

    set-options((
      "loesungen": loesungen,
      "materialien": materialien,
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
      #set text(1.25em, weight: 700)
      #it.body
      #v(4pt)
    ]

    show heading.where(level: 2): it => block[
      #set text(1em, weight: 700)
      #it.body
    ]

    // Setting captions and numberings for figures
    set figure(numbering: "1", supplement: none)

    show figure: it => {
      let type = repr(it.kind)
      let supplement = ("image": "A", "table": "T").at(type, default: "M")
      let number = counter(figure.where(kind: it.kind)).get().first()
      context {
        align(center)[
          #it.body
          #if it.caption != none {
            v(5pt)
            align(left, grid(
              columns: 2,
              column-gutter: 0.5em,
              text(size: figure-font-size, grid(
                columns: 2,
                align: top,
                column-gutter: 0.25em,
                [*#supplement#number:*], it.caption,
              )),
            ))
          }
        ]
      }
    }

    show figure.where(kind: "material"): it => {
      context {
        let current-aufgabe = _state_current_material_aufgabe.get()
        let material-index = _state_current_material_index.get()

        // Fallback falls nicht in Material-Sektion
        if current-aufgabe == 0 {
          current-aufgabe = _counter_aufgaben.get().at(0)
          material-index = counter(figure.where(kind: "material")).at(it.location()).first()
        }

        let thm_num = "M" + str(current-aufgabe) + "-" + numbering("A", material-index)

        align(center)[
          #it.body
          #v(5pt)
          #align(left, grid(
            columns: 2,
            column-gutter: 0.5em,
            text(size: figure-font-size, strong(thm_num) + ":"), text(size: figure-font-size, it.caption),
          ))
        ]
      }
    }

    show figure.where(kind: "teilaufgabe"): it => align(
      left,
      box(width: 100%, [
        #it.body
      ]),
    )

    show: codly-init.with()
    codly(display-name: false)
    set raw(syntaxes: "processing.sublime-syntax")

    show heading.where(level: 1): it => if aufgaben-shortcodes in ("alle", "aufgaben") {
      set text(font-size, weight: 700)
      aufgabe(title: it.body, large: true)[]
    } else { it }
    show enum.item: it => context {
      if aufgaben-shortcodes in ("alle", "teilaufgaben") and not _state_in_loesung.get() {
        teilaufgabe(it.body)
      } else {
        it
      }
    }

    fancy-units-configure(per-mode: "fraction", decimal-separator: ",")
    add-macros(
      u: sym.mu,
      ohm: sym.Omega,
    )

    body

    // To show materials on a separate page
    context if materialien in ("seite", "reinquetschen") and _state_aufgaben.final().len() > 0 {
      show-materialien()
    }
    // To show solutions on a seperate page
    context if loesungen in ("seite", "seiten", "reinquetschen") and _state_aufgaben.final().len() > 0 {
      show-loesungen()
    }
  }
}

#let lücke(body, tight: false) = {
  box(
    move(
      dy: 0.33em,
      box(
        stroke: (bottom: 0.5pt),
        [
          #if not tight {
            h(2em)
          }
          #hide(body)
        ],
      ),
    ),
  )
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
#let minipage(columns: auto, align: horizon, spacing: 5mm, ..args) = {
  // Sammle alle Body-Argumente
  let bodies = args.pos()

  // Bestimme die Anzahl der Spalten automatisch, wenn nicht angegeben
  let effective-columns = if columns == auto {
    // Erstelle Array mit 1fr für jede übergebene Body
    (1fr,) * bodies.len()
  } else {
    columns
  }

  table(
    stroke: none,
    columns: effective-columns,
    align: align,
    inset: 0pt,
    column-gutter: spacing,
    ..args.named(),
    ..bodies,
  )
}

#let icon-link(url, name, icon: emoji.chain, color: blue) = {
  //fa-external-link(fill: blue)
  link(url)[#icon #text(fill: color, [#name])]
}

#let qrbox(url, name, width: 3cm, ..args) = {
  stickybox(width: width, ..args)[
    #set align(center)
    #qr-code(url, width: 0.75 * width, light-color: "#ffffff00", quiet-zone: false, alt: "QR-Code")
    #align(
      center,
      context {
        let text-size = 12pt
        let content-link = text(text-size, icon-link(url, name))
        let icon = true
        while measure(text(size: text-size, icon-link(url, name))).width > 0.8 * width and text-size > 10pt {
          text-size = text-size - 0.1pt
          content-link = text(text-size, icon-link(url, name))
        }
        if text-size <= 10pt {
          content-link = text(text-size, blue, link(url, name))
          icon = false
          while measure(text(size: text-size, link(url, name))).width < 0.8 * width and text-size < 12pt {
            text-size = text-size + 0.1pt
            content-link = text(text-size, blue, link(url, name))
          }
        }
        text(
          size: text-size,
          [
            #v(-1em)
            #v(0.05 * width)
            #content-link
            #if icon { v(0.05 * width) }
          ],
        )
      },
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
