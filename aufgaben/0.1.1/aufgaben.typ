#import "@preview/fontawesome:0.1.0": *
#import "@preview/gentle-clues:1.1.0": *

// States
#let _state_aufgaben = state("aufgaben", ())
#let _state_options = state(
  "options",
  (
    loesungen: "keine", //
    workspaces: true,
    teilaufgabe-numbering: "a)",
    punkte: "alle", // "keine", "aufgaben", "teilaufgaben", "alle"
  ),
)

// Counter
#let _counter_aufgaben = counter("aufgaben")

// Options management
#let set_options(options) = {
  _state_options.update(curr => {
    curr + options
  })
}

#let show_loesung(aufg, teil: false) = {
  if teil == false and aufg.loesung.len() > 0 {
    goal(
      title: [Lösung #{aufg.nummer}],
      accent-color: gray,
      {
        // Main solutions
        for l in aufg.loesung.filter(l => l.teil == 0) {
          l.body
        }

        // Sub-solutions
        if aufg.teile > 0 {
          enum(
            numbering: "a)",
            tight: false,
            ..aufg.loesung.filter(l => l.teil > 0).sorted(key: l => l.teil).map(l => enum.item(l.teil, l.body)),
          )
        }
      },
    )
  } else if aufg.loesung.filter(l => l.teil == teil).len() > 0 {
    // Sub-solutions
    goal(
      title: [Lösung #if teil == 0 { {aufg.nummer} } else { numbering("a)", teil) }],
      accent-color: gray,
      {
        for l in aufg.loesung.filter(l => l.teil == teil) {
          l.body
        }
      },
    )
  }
}

#let show_loesungen(curr: false, teil: false) = {
  context {
    let all = _state_aufgaben.get()
    if curr { all = (all.last(),) }

    for aufg in all {
      if aufg.loesung.len() > 0 {
        if _state_options.get().loesungen == "seiten" {
          page(show_loesung(aufg, teil: teil))
        } else {
          show_loesung(aufg, teil: teil)
        }
      }
    }
  }
}

// Helper functions
#let get_points(aufg, teil: none) = {
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

// Main components
#let aufgabe(
  title: none,
  method: "",
  icons: (),
  large: false,
  number: true,
  workspace: none,
  label-ref: none,
  body,
) = {
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
        title: title,
        teile: 0,
        loesung: (),
        erwartungen: (),
      ))
      all
    })
  }

  // Render heading
  if title != none or number {
    context {
      let auf-head = heading(
        figure(
          kind: "aufgabe",
          supplement: none,
          text(
            if large { 14pt } else { 12pt },
            [
              #let nums = _counter_aufgaben.get()
              #if ic.len() > 0 { ic.join() }
              #if number { "Aufgabe " + str(nums.first()) }
              #if number and title != none [ $-$ ]
              #if title != none [#title]
              #h(1fr)
              // Gesamtpunkte der Aufgabe
              #let opts = _state_options.get()
              #if opts.punkte in ("aufgaben", "alle") {
                let points = get_points(_counter_aufgaben.get().at(0))
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
    block(width: 100%, inset: 0.5em)[#workspace]
  }
  // "sofort" solutions
  context if _state_options.final().loesungen == "sofort" {
    show_loesungen(curr: true, teil: 0)
  }
  // "folgend" solutions
  context if _state_options.final().loesungen == "folgend" {
    show_loesungen(curr: true)
  }
}

#let teilaufgabe(
  item-label: "a)",
  label-ref: none,
  workspace: none,
  body,
) = {
  _counter_aufgaben.step(level: 2)
  context {
    let curr_aufg = _counter_aufgaben.get().at(0)
    let curr_teil = _counter_aufgaben.get().at(1)

    // Update state
    _state_aufgaben.update(all => {
      all.at(curr_aufg - 1).teile += 1
      all
    })
    // Render

    let ta-enum = enum(
      start: curr_teil,
      numbering: n => context [
        #let opts = _state_options.get()
        #if opts.teilaufgabe-numbering == "a)" {
          numbering("a)", n)
        } else if opts.teilaufgabe-numbering == "1." {
          numbering("1.1", curr_aufg, n)
        }
      ],
      {
        body
        // Punkte der Teilaufgabe
        let opts = _state_options.get()
        if opts.punkte in ("teilaufgaben", "alle") {
          context {
            let points = get_points(
              _counter_aufgaben.get().at(0),
              teil: _counter_aufgaben.get().at(1),
            )
            if points > 0 {
              h(1fr)
              box(align(
                top + right,
                text(fill: black, size: 0.88em)[*[#points BE]*],
              ))
            }
          }
        }
        // Workspace
        if workspace != none and opts.workspaces {
          workspace
        }
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
    show_loesungen(curr: true, teil: curr_teil)
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

#let erwartung(text, punkte) = {
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
          text: text,
          punkte: punkte,
        ))
      all
    })
  }
}

// Solution pages
#let d_loesungen() = {
  pagebreak()
  show_loesungen()
}
