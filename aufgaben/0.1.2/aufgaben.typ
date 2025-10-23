#import "@preview/fontawesome:0.2.1": *
#import "@preview/gentle-clues:1.2.0": *

// States
#let _state_aufgaben = state("aufgaben", ())
#let _state_current_material_aufgabe = state("current_material_aufgabe", 0)
#let _state_current_material_index = state("current_material_index", 0)
#let _state_options = state(
  "options",
  (
    loesungen: "keine", //
    materialien: "seiten", // "keine", "sofort", "folgend", "seiten"
    workspaces: true,
    teilaufgabe-numbering: "a)",
    punkte: "aufgaben", // "keine", "aufgaben", "teilaufgaben", "alle"
  ),
)

// Counter
#let _counter_aufgaben = counter("aufgaben")

// Options management
#let set-options(options) = {
  _state_options.update(curr => {
    curr + options
  })
}

#let show-loesung(aufg, teil: false) = {
  context {
    let opts = _state_options.get()

    if teil == false and aufg.loesung.len() > 0 {
      goal(
        title: [Lösung #{ aufg.nummer } #if (aufg.title != none and aufg.title != []) [-- #{ aufg.title } ]],
        accent-color: gray,
        {
          // Main solutions
          for l in aufg.loesung.filter(l => l.teil == 0) {
            l.body
          }

          // Sub-solutions
          if aufg.teile > 0 {
            let grouped = (:)
            for l in aufg.loesung.filter(l => l.teil > 0).sorted(key: l => l.teil) {
              let teil-key = str(l.teil)
              if teil-key not in grouped.keys() {
                grouped.insert(teil-key, ())
              }
              grouped.at(teil-key).push(l.body)
            }

            enum(
              numbering: if opts.teilaufgabe-numbering == "a)" { "a)" } else { n => numbering("1.1", aufg.nummer, n) },
              tight: false,
              ..grouped
                .pairs()
                .map(pair => {
                  let (teil, bodies) = pair
                  enum.item(int(teil), stack(spacing: 0.5em, ..bodies))
                }),
            )
          }
        },
      )
    } else if aufg.loesung.filter(l => l.teil == teil).len() > 0 {
      // Sub-solutions
      let loesung-bodies = aufg.loesung.filter(l => l.teil == teil).map(l => l.body)
      let teil-label = if opts.teilaufgabe-numbering == "a)" {
        numbering("a)", teil)
      } else {
        numbering("1.1", aufg.nummer, teil)
      }
      goal(
        title: [Lösung #if teil == 0 { { aufg.nummer } } else { teil-label }],
        accent-color: gray,
        stack(spacing: 0.5em, ..loesung-bodies),
      )
    }
  }
}

#let show-loesungen(curr: false, teil: false) = {
  context {
    let all = _state_aufgaben.get()
    if curr { all = (all.last(),) }

    if _state_options.get().loesungen == "seite" {
      pagebreak(weak: true)
    }
    for aufg in all {
      if aufg.loesung.len() > 0 {
        if _state_options.get().loesungen == "seiten" {
          page(show-loesung(aufg, teil: teil))
        } else if _state_options.get().loesungen in ("sofort", "folgend") {
          show-loesung(aufg, teil: teil)
        } else {
          show-loesung(aufg, teil: teil)
        }
      }
    }
  }
}

// Helper functions
#let get-points(aufg, teil: none) = {
  let all = _state_aufgaben.final()
  if aufg == none or aufg > all.len() { return 0 }

  let current = all.at(aufg - 1)
  if not "erwartungen" in current { return 0 }

  let erw = current.erwartungen
  if teil != none {
    erw = erw.filter(e => e.teil == teil)
  }

  return erw.fold(0, (sum, e) => sum + e.punkte)
}

#let show-erwartungen(grouped: false) = {
  context {
    let all = _state_aufgaben.final()
    let opts = _state_options.get()

    // Erstelle Tabellenzeilen
    let rows = ()

    for aufg in all {
      if "erwartungen" in aufg and aufg.erwartungen.len() > 0 {
        // Hauptzeile für die Aufgabe
        let aufg-title = if aufg.title != none and aufg.title != [] {
          aufg.title
        } else {
          []
        }
        let aufg-punkte = get-points(aufg.nummer)

        rows.push(table.cell(fill: gray.lighten(70%), strong[#aufg.nummer]))
        rows.push(table.cell(fill: gray.lighten(70%), strong[#if aufg-title != [] [#aufg-title]]))
        rows.push(table.cell(fill: gray.lighten(70%), strong[#aufg-punkte]))

        // Zeilen für Teilaufgaben/Erwartungen
        let grouped-erw = (:)
        for erw in aufg.erwartungen.sorted(key: e => e.teil) {
          let teil-key = str(erw.teil)
          if teil-key not in grouped-erw.keys() {
            grouped-erw.insert(teil-key, ())
          }
          grouped-erw.at(teil-key).push(erw)
        }

        for (teil-str, erwartungen) in grouped-erw.pairs().sorted(key: pair => int(pair.at(0))) {
          let teil = int(teil-str)
          let teil-label = if teil == 0 {
            []
          } else if opts.teilaufgabe-numbering == "a)" {
            numbering("a)", teil)
          } else {
            numbering("1.1", aufg.nummer, teil)
          }

          if grouped {
            // Grouped: Eine Zeile pro Teilaufgabe mit allen Erwartungen zusammengefasst
            let inhalt = erwartungen.map(e => e.text).join()
            let punkte = erwartungen.fold(0, (sum, e) => sum + e.punkte)

            rows.push(table.cell(align: top, teil-label))
            rows.push(align(left, inhalt))
            rows.push(align(center, str(punkte)))
          } else {
            // Ungrouped: Eine Zeile pro Erwartung
            for (idx, erw) in erwartungen.enumerate() {
              let show-label = if idx == 0 { teil-label } else { [] }
              let stroke-override = if idx < erwartungen.len() - 1 {
                // Keine untere Linie zwischen Erwartungen derselben Teilaufgabe
                (left: 0.5pt, right: 0.5pt, top: 0.5pt, bottom: none)
              } else if idx == erwartungen.len() - 1 {
                // Keine untere Linie zwischen Erwartungen derselben Teilaufgabe
                (left: 0.5pt, right: 0.5pt, top: none, bottom: 0.5pt)
              } else {
                0.5pt
              }
              let inset = if idx < erwartungen.len() - 1 {
                // Keine untere Linie zwischen Erwartungen derselben Teilaufgabe
                (bottom: 1pt)
              } else {
                8pt
              }

              rows.push(table.cell(align: top, stroke: stroke-override, inset: inset, show-label))
              rows.push(table.cell(align: left, stroke: stroke-override, inset: inset, erw.text))
              rows.push(table.cell(align: center, stroke: stroke-override, inset: inset, str(erw.punkte)))
            }
          }
        }
      }
    }

    if rows.len() > 0 {
      page(
        block(text(size: 1.25em, weight: "bold")[Erwartungshorizont]),
        table(
          columns: (auto, 1fr, auto),
          align: (center + horizon, left + horizon, center + horizon),
          inset: 8pt,
          stroke: 0.5pt,
          table.header(strong[Nr.], strong[Inhalt], strong[BE]),
          ..rows,
        ),
      )
    }
  }
}

#let show-bewertung(..args) = {
  let pos-args = args.pos()
  let punkte = true
  if pos-args.len() == 1 {
    punkte = pos-args.at(0)
  }
  context {
    let all = _state_aufgaben.final()
    let opts = _state_options.get()

    if all.len() == 0 { return }

    // Erstelle Header-Zeilen und Spalten
    let header-row1 = (table.cell(rowspan: 2, strong[Aufgabe]),)
    let header-row2 = ()
    let columns = (auto,)

    // Zeile für "mögliche Punkte"
    let moegliche-punkte-row = (text(0.9em, strong("mögliche Punkte")),)
    // Zeile für "erreichte Punkte"
    let erreichte-punkte-row = (text(0.9em, strong("erreichte Punkte")),)

    let gesamt-punkte = 0
    let cell-width = auto

    for aufg in all {
      let aufg-punkte = get-points(aufg.nummer)
      gesamt-punkte += aufg-punkte

      // Gruppiere Erwartungen nach Teilaufgaben
      let grouped-erw = (:)
      if "erwartungen" in aufg {
        for erw in aufg.erwartungen.sorted(key: e => e.teil) {
          let teil-key = str(erw.teil)
          if teil-key not in grouped-erw.keys() {
            grouped-erw.insert(teil-key, ())
          }
          grouped-erw.at(teil-key).push(erw)
        }
      }

      // Prüfe, ob es echte Teilaufgaben gibt (basierend auf aufg.teile)
      let hat-teilaufgaben = aufg.teile > 0

      // Wenn keine Teilaufgaben vorhanden: Erstelle trotzdem eine Spalte für die Hauptaufgabe
      if not hat-teilaufgaben {
        header-row1.push(table.cell(rowspan: 2, strong[A#aufg.nummer]))

        // Hole Punkte für die Hauptaufgabe (teil == 0)
        let teil-punkte = if "0" in grouped-erw.keys() {
          grouped-erw.at("0").fold(0, (sum, e) => sum + e.punkte)
        } else {
          0
        }

        // punkte: true => zeige Punkte, false => zeige leer, none => überspringe Zeile
        if punkte == true and teil-punkte > 0 {
          moegliche-punkte-row.push(table.cell([#teil-punkte]))
        } else if punkte == false {
          moegliche-punkte-row.push(table.cell([]))
        } else if punkte == true {
          moegliche-punkte-row.push(table.cell([]))
        }
        erreichte-punkte-row.push(table.cell([]))
        columns.push(cell-width)
        continue
      }

      // Hat Teilaufgaben: Erstelle Spalten für alle Teilaufgaben (1 bis aufg.teile)
      header-row1.push(table.cell(colspan: aufg.teile, strong[A#aufg.nummer]))

      // Iteriere über ALLE Teilaufgaben (nicht nur die mit Erwartungen)
      for teil-nr in range(1, aufg.teile + 1) {
        let teil-key = str(teil-nr)
        let teil-label = if opts.teilaufgabe-numbering == "a)" {
          numbering("a)", teil-nr)
        } else {
          numbering("1.1", aufg.nummer, teil-nr)
        }

        // Hole Punkte für diese Teilaufgabe (falls Erwartungen vorhanden)
        let teil-punkte = if teil-key in grouped-erw.keys() {
          grouped-erw.at(teil-key).fold(0, (sum, e) => sum + e.punkte)
        } else {
          0
        }

        header-row2.push(strong[#teil-label])
        // punkte: true => zeige Punkte, false => zeige leer, none => überspringe Zeile
        if punkte == true and teil-punkte > 0 {
          moegliche-punkte-row.push(table.cell([#teil-punkte]))
        } else if punkte == false {
          moegliche-punkte-row.push(table.cell([]))
        } else if punkte == true {
          moegliche-punkte-row.push(table.cell([]))
        }
        erreichte-punkte-row.push(table.cell([]))
        columns.push(cell-width)
      }
    }

    // Summen-Spalte
    header-row1.push(table.cell(rowspan: 2, fill: gray.lighten(70%), strong[$Sigma$]))
    columns.push(if cell-width == auto { auto } else { 1.25 * cell-width })
    // punkte: true => zeige Gesamtpunkte, false => zeige leer, none => überspringe Zeile
    if punkte == true {
      moegliche-punkte-row.push(table.cell(fill: gray.lighten(70%), strong[#if gesamt-punkte > 0 [#gesamt-punkte]]))
    } else if punkte == false {
      moegliche-punkte-row.push(table.cell(fill: gray.lighten(70%), []))
    }
    erreichte-punkte-row.push(table.cell(fill: gray.lighten(70%), []))

    // Erstelle Tabelle mit oder ohne "mögliche Punkte" Zeile
    if punkte != none {
      table(
        columns: columns,
        rows: (auto, auto, ..if cell-width == auto { (auto, auto) } else { (cell-width, cell-width) }),
        align: center + horizon,
        inset: 8pt,
        stroke: 0.5pt,
        ..header-row1,
        ..header-row2,
        ..moegliche-punkte-row,
        ..erreichte-punkte-row,
      )
    } else {
      table(
        columns: columns,
        rows: (auto, auto, if cell-width == auto { auto } else { cell-width }),
        align: center + horizon,
        inset: 8pt,
        stroke: 0.5pt,
        ..header-row1,
        ..header-row2,
        ..erreichte-punkte-row,
      )
    }
  }
}

// Material system
#let show-material(aufg) = {
  if aufg.materialien.len() > 0 {
    // Set current aufgabe for material numbering
    _state_current_material_aufgabe.update(aufg.nummer)
    block(width: 100%, below: 1em, above: 1.5em, text(14pt, weight: "bold")[Material zu Aufgabe #aufg.nummer]) // Materialüberschrift
    for (index, m) in aufg.materialien.enumerate() {
      // Set current material index (1-based)
      _state_current_material_index.update(index + 1)
      m.body
    }
  }
}

#let show-materialien(curr: false) = {
  set figure(numbering: "1", supplement: "Abb.")
  context {
    let all = _state_aufgaben.get()
    if curr { all = (all.last(),) }
    if _state_options.final().materialien == "seite" {
      pagebreak(weak: true)
    }
    for aufg in all {
      if aufg.materialien.len() > 0 {
        if _state_options.final().materialien == "seite" {
          show-material(aufg)
        } else if _state_options.final().materialien in ("sofort", "folgend") {
          show-material(aufg)
        } else {
          page(show-material(aufg))
        }
      }
    }
  }
}

#let material(body, caption: none, label: none) = {
  let mat = [#figure(
      align(left, body),
      caption: caption,
      kind: "material",
      supplement: none,
    ) #if label != none { std.label(label) }
    #v(-0.5em)
    #line(length: 100%, stroke: 0.5pt)
  ]
  context {
    let curr_aufg = _counter_aufgaben.get().at(0)

    _state_aufgaben.update(all => {
      all
        .at(curr_aufg - 1)
        .materialien
        .push((
          body: mat,
        ))
      all
    })
  }
}

// Main components
#let aufgabe(
  title: none,
  method: "",
  icons: (),
  large: true,
  number: true,
  workspace: none,
  label-ref: none,
  ..args,
) = {
  // Parse positional arguments
  let pos-args = args.pos()
  let body = none
  let actual-title = title

  if pos-args.len() == 1 {
    // Single argument: body
    body = pos-args.at(0)
  } else if pos-args.len() == 2 {
    // Two arguments: title, body
    actual-title = pos-args.at(0)
    body = pos-args.at(1)
  } else {
    panic("aufgabe expects 1 or 2 positional arguments")
  }

  _counter_aufgaben.step()
  counter(figure.where(kind: "teilaufgabe")).update(0)

  // Icon handling
  let ic = ()
  if method == "EA" { ic.push(fa-user-large()) }
  if method == "PA" { ic.push(fa-user-group()) }
  if method == "GA" { ic.push(fa-users()) }
  ic += icons

  // Update state
  context {
    let ct_aufgaben = _counter_aufgaben.get().at(0)
    _state_aufgaben.update(all => {
      all.push((
        nummer: ct_aufgaben,
        title: actual-title,
        teile: 0,
        loesung: (),
        materialien: (),
        erwartungen: (),
      ))
      all
    })
  }

  if (actual-title != none and actual-title != []) or number {
    context {
      let auf-head = block(
        width: 100%,
        below: 1em,
        figure(
          kind: "aufgabe",
          supplement: none,
          text(
            weight: "bold",
            size: if large { 1.25em } else { 1em },
            [
              #let nums = _counter_aufgaben.get()
              #if ic.len() > 0 { ic.join() }
              #if number { "Aufgabe " + str(nums.first()) }
              #if number and (actual-title != none and actual-title != []) [ $-$ ]
              #if actual-title != none [#actual-title]
              #h(1fr)
              // Gesamtpunkte der Aufgabe
              #let opts = _state_options.get()
              #if opts.punkte in ("aufgaben", "alle") {
                let points = get-points(_counter_aufgaben.get().at(0))
                if points > 0 {
                  [#points BE]
                }
              }
            ],
          ),
        ),
      )
      if label-ref != none [
        #auf-head #label(label-ref)
      ] else [
        #auf-head
      ]
    }
  }
  // Content
  body
  // Workspace
  context if workspace != none and _state_options.get().workspaces {
    block(width: 100%, inset: (x: 0em, y: 0.5em))[#workspace]
  }
  // "sofort" materials
  context if _state_options.final().materialien in ("sofort", "seiten", "folgend") and _state_aufgaben.get().last().materialien.len() > 0 {
    if _state_options.final().materialien == "seiten" {
      pagebreak(weak: true)
    }
    show-materialien(curr: true)
  }
  // "sofort" solutions
  context if _state_options.final().loesungen == "sofort" {
    show-loesungen(curr: true, teil: 0)
  }
  // "folgend" solutions
  context if _state_options.final().loesungen == "folgend" {
    show-loesungen(curr: true)
  }
}

#let teilaufgabe(
  item-label: none,
  label-ref: none,
  workspace: none,
  body,
) = {
  _counter_aufgaben.step(level: 2)
  context {
    let curr_aufg = _counter_aufgaben.get().at(0)
    let curr_teil = _counter_aufgaben.get().at(1, default: 1)

    // Update state
    _state_aufgaben.update(all => {
      all.at(curr_aufg - 1).teile += 1
      all
    })
    // Render

    let ta-enum = enum(
      start: curr_teil,
      numbering: n => context [
        #if item-label != none {
          item-label
        } else {
          let opts = _state_options.get()
          if opts.teilaufgabe-numbering == "a)" {
            numbering("a)", n)
          } else if opts.teilaufgabe-numbering == "1." {
            numbering("1.1", curr_aufg, n)
          } else {
            numbering("a)", n) // Fallback
          }
        }
      ],
      {
        box(
          width: 100%,
          {
            align(left, {
              body
              let opts = _state_options.get()
              if opts.punkte in ("teilaufgaben", "alle") {
                context {
                  let points = get-points(
                    _counter_aufgaben.get().at(0),
                    teil: _counter_aufgaben.get().at(1),
                  )
                  if points > 0 {
                    h(1fr)
                    box(
                      align(
                        top + right,
                        text(fill: black, size: 0.88em)[*[#points BE]*],
                      ),
                    )
                  }
                }
              }
              // Workspace
              if not workspace in (none, false) and opts.workspaces {
                workspace
              }
            })
          },
        )
      },
    )
    if label-ref != none [
      #figure(kind: "teilaufgabe", supplement: "Teilaufgabe", ta-enum, numbering: "a)") #label(label-ref)
    ] else [
      #figure(kind: "teilaufgabe", supplement: "Teilaufgabe", ta-enum, numbering: "a)")
    ]
  }
  context if _state_options.final().loesungen == "sofort" {
    let curr_aufg = _counter_aufgaben.get().at(0)
    let curr_teil = if _counter_aufgaben.get().len() > 1 {
      _counter_aufgaben.get().at(1)
    } else { 0 }
    show-loesungen(curr: true, teil: curr_teil)
  }
}

#let loesung(body) = {
  context {
    let curr_aufg = _counter_aufgaben.get().at(0)
    let curr_teil = if _counter_aufgaben.get().len() > 1 {
      _counter_aufgaben.get().at(1)
    } else { 0 }

    // Store solution
    _state_aufgaben.update(all => {
      all
        .at(curr_aufg - 1)
        .loesung
        .push((
          teil: curr_teil,
          body: body,
        ))
      all
    })
  }
}

#let erwartung(..args) = {
  let pos-args = args.pos()
  let body = none
  let punkte = 0

  if pos-args.len() == 1 {
    // Single argument: body
    body = pos-args.at(0)
  } else if pos-args.len() == 2 {
    // Two arguments: title, body
    punkte = pos-args.at(0)
    body = pos-args.at(1)
  } else {
    panic("aufgabe expects 1 or 2 positional arguments")
  }
  context {
    let curr_aufg = _counter_aufgaben.get().at(0)
    let curr_teil = if _counter_aufgaben.get().len() > 1 {
      _counter_aufgaben.get().at(1)
    } else { 0 }

    _state_aufgaben.update(all => {
      all
        .at(curr_aufg - 1)
        .erwartungen
        .push((
          teil: curr_teil,
          text: body,
          punkte: punkte,
        ))
      all
    })
  }
}
