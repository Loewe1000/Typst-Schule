// Themes für @schule/arbeitsblatt (seit 0.4.0)
//
// Ein Theme ist ein Dictionary mit Darstellungsfunktionen. Es entsteht aus
// einer Theme-Funktion `(akzent, class) => dictionary`; `arbeitsblatt()`
// ruft sie mit der Fachfarbe (oder dem Parameter `akzent:`) und dem
// Klassenkürzel auf. Alle Einträge sind optional – fehlt einer, gilt die
// klassische Darstellung.
//
//   schrift       (text:, mathe:, groesse:, titel:)
//   rand          (top:, bottom:)                Seitenränder oben/unten
//   header-ascent Abstand Kopfzeile – Text
//   kopf          (title:, class:, copyright:, font-size:) => content
//   fuss          (duplex:) => content           nur in der Druckfassung
//   hintergrund   (print:, oben:, rand:) => content  Seitenhintergrund
//   marke         (nummer) => content            Nummer neben der ersten Zeile
//   marke-breite  length                         (Aufgaben ohne Titel)
//   aufgabe       (nummer:, titel:, icons:, punkte:, large:, number:) => content
//   teilaufgabe   (label) => content
//   loesung       (titel, body) => content
//   loesung-kopf  (titel) => content             Überschrift im Lösungsblatt
//   material-kopf (titel) => content
//   kasten        (art:, titel:, farbe:, breakable:, width:, body) => content
//   setup         body => content                weitere Show-Regeln
//
// Wiedererkennung: Alle Themes teilen dieselben Bausteine – Fachfarbe,
// Kopfzeile „Fach · Klasse“ über dem Titel, Klassenkürzel oben rechts,
// Seitenzahl unten außen und Aufgabennummer jeweils als gefüllte Marke in der
// Fachfarbe, Lösungen immer grün. Jedes Theme zeichnet sie auf seine Art.

#import "@preview/fontawesome:0.6.0": fa-icon

// ─── Gemeinsame Bausteine ────────────────────────────────────────────────────

/// Fachfarben nach Kürzel. Unbekannte Fächer bekommen das Mathe-Blau.
#let fachfarben = (
  MA: rgb("#2f6fb5"),
  PH: rgb("#d4572a"),
  IF: rgb("#13866f"),
  CH: rgb("#8b3fa3"),
  BI: rgb("#3f8a2c"),
  NW: rgb("#0e7f8c"),
  DE: rgb("#c0392b"),
  EN: rgb("#b5176d"),
  KLS: rgb("#5b6b7f"),
)
#let fachnamen = (
  MA: "Mathematik",
  PH: "Physik",
  IF: "Informatik",
  CH: "Chemie",
  BI: "Biologie",
  NW: "Naturwissenschaften",
  DE: "Deutsch",
  EN: "Englisch",
  KLS: "Klassenleitung",
)

#let _klartext(x) = {
  if x == none { "" } else if type(x) == str { x } else if type(x) == content {
    if x.func() == [ ].func() { " " } else if x.has("text") { x.text } else if x.has("children") {
      x.children.map(_klartext).join("", default: "")
    } else if x.has("body") { _klartext(x.body) } else { "" }
  } else { str(x) }
}

/// Zerlegt ein Klassenkürzel wie "MA-05", "PH-7" oder "IF-11".
#let kuerzel(class) = {
  // Nur Großbuchstaben: "if3" ist ein Kurs, kein Jahrgang 3.
  let m = _klartext(class).match(regex("^([A-Z]{2,3})-?0*(\d+)"))
  if m == none { (fach: none, name: none, jahrgang: none) } else {
    let fach = upper(m.captures.at(0))
    (fach: fach, name: fachnamen.at(fach, default: none), jahrgang: int(m.captures.at(1)))
  }
}

/// „Mathematik · Klasse 5“ – die Zeile über dem Titel.
#let kicker(class) = {
  let k = kuerzel(class)
  if k.name == none { none } else {
    let j = k.jahrgang
    if j < 5 or j > 13 { k.name } else { k.name + " · " + (if j >= 11 { "Jahrgang " } else { "Klasse " }) + str(j) }
  }
}

#let fachfarbe(class) = {
  let f = kuerzel(class).fach
  if f == none { fachfarben.MA } else { fachfarben.at(f, default: fachfarben.MA) }
}

// Kastenarten: Icon und Farbe (none = Akzentfarbe des Blatts).
#let _gruen = rgb("#2b9348")
#let _gelb = rgb("#a36a00")
#let _orange = rgb("#e3752a")
#let _rot = rgb("#c62e3a")
#let _violett = rgb("#6c4fb0")
#let _tuerkis = rgb("#0e8a8a")
#let _kasten-stil = (
  info: ("circle-info", none),
  memo: ("thumbtack", none),
  abstract: ("align-left", none),
  conclusion: ("flag-checkered", none),
  goal: ("bullseye", none),
  notify: ("bell", none),
  code: ("code", none),
  task: ("pencil", none),
  tip: ("lightbulb", _gelb),
  success: ("circle-check", _gruen),
  idea: ("lightbulb", _gelb),
  example: ("pen-to-square", _violett),
  question: ("circle-question", _orange),
  warning: ("triangle-exclamation", _orange),
  danger: ("bolt", _rot),
  error: ("circle-xmark", _rot),
  experiment: ("flask", _tuerkis),
)
#let kasten-stil(art, akzent, farbe: auto) = {
  let (icon, f) = _kasten-stil.at(art, default: ("circle-info", none))
  (icon: icon, farbe: if farbe != auto { farbe } else if f == none { akzent } else { f })
}

// Seitenzahl in der äußeren Ecke (bei einseitigem Druck immer rechts).
#let _aussen(duplex, inhalt) = context {
  let n = counter(page).get().first()
  if duplex and calc.even(n) { align(left, inhalt(n)) } else { align(right, inhalt(n)) }
}

// Linker/rechter Seitenrand der aktuellen Seite aus dem margin-Dictionary.
#let _seitenrand(m, n) = {
  if type(m) != dictionary { return (m, m) }
  if "inside" in m {
    let (i, o) = (m.inside, m.at("outside", default: m.inside))
    if calc.odd(n) { (i, o) } else { (o, i) }
  } else {
    let x = m.at("x", default: 1.75cm)
    (m.at("left", default: x), m.at("right", default: x))
  }
}

// Gefüllte Marke (Kachel) – Grundform für Kürzel, Seitenzahl und Nummer.
// Die Ziffern reichen von der Grundlinie bis zur Versalhöhe, so ist der
// Innenabstand oben und unten gleich.
// Alle em-Maße (breite, inset) beziehen sich auf `size`.
#let _marke(inhalt, fill: black, size: 1em, radius: 1.5pt, font: auto, weight: 700, breite: auto, inset: (x: 0.5em, y: 0.4em), stroke: none, farbe: white) = text(size, box(
  fill: fill,
  stroke: stroke,
  radius: radius,
  inset: inset,
  width: breite,
  align(center, text(fill: farbe, weight: weight, ..if font != auto { (font: font) }, top-edge: "cap-height", bottom-edge: "baseline", inhalt)),
))

// Harter, versetzter Schatten hinter einem Element mit natürlicher Größe
// (Kacheln). Braucht context für measure.
#let _schatten-box(inhalt, versatz: 2.5pt, farbe: black) = context {
  let m = measure(inhalt)
  box(width: m.width + versatz, height: m.height + versatz, baseline: versatz, {
    place(top + left, dx: versatz, dy: versatz, rect(width: m.width, height: m.height, fill: farbe, radius: 0pt))
    place(top + left, inhalt)
  })
}

// Dasselbe für einen Block über die volle Breite (nicht umbrechbar).
#let _schatten-block(inhalt, versatz: 4pt, farbe: black) = layout(platz => {
  let innen = block(width: platz.width - versatz, inhalt)
  let m = measure(innen)
  block(width: platz.width, height: m.height + versatz, breakable: false, {
    place(top + left, dx: versatz, dy: versatz, rect(width: m.width, height: m.height, fill: farbe))
    place(top + left, innen)
  })
})

// Lösung mit Bezeichnung in der ersten Zeile (spart Platz im Lösungsblatt).
#let _loesung-inline(titel, body, label-stil: it => it) = {
  label-stil(titel)
  h(0.6em)
  body
}

// ─── klar ────────────────────────────────────────────────────────────────────
// Sparsam und modern: Linien statt Flächen, viel Weißraum, quadratische
// Marken. Die Weiterentwicklung der 5a-Übungsblätter – tonerfreundlich.

#let klar(akzent, class) = {
  let tinte = luma(30)
  let kachel(inhalt, size: 1em) = _marke(inhalt, fill: akzent, size: size, breite: 1.65em, inset: (x: 0.3em, y: 0.42em))
  (
    name: "klar",
    schrift: (text: "Avenir Next", mathe: "Fira Math", groesse: 10.5pt, titel: 20pt),
    rand: (kopf-oben: 1.3cm, bottom: 1.8cm),
    header-ascent: 0.75cm,
    kopf: (title: none, class: none, copyright: none, font-size: 20pt) => {
      set par(justify: false)
      grid(
        columns: (1fr, auto),
        column-gutter: 1em,
        align: (left + bottom, right + bottom),
        stack(
          spacing: 0.55em,
          if kicker(class) != none { text(7.5pt, weight: 600, tracking: 0.14em, fill: akzent, upper(kicker(class))) },
          text(font-size, weight: 700, fill: tinte, title),
        ),
        _marke(class, fill: akzent, size: 10.5pt, inset: (x: 0.6em, y: 0.45em)),
      )
      v(0.5em)
      line(length: 100%, stroke: 0.7pt + luma(210))
    },
    fuss: (duplex: true) => _aussen(duplex, n => kachel(str(n), size: 9pt)),
    marke: n => move(dy: -0.64em, kachel(str(n), size: 1.2em)),
    marke-breite: 2.65em,
    aufgabe: (nummer: 1, titel: none, icons: (), punkte: none, large: true, number: true) => {
      set par(justify: false)
      let gr = if large { 1.2em } else { 1.05em }
      block(width: 100%, grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.6em,
        align: horizon,
        if number { kachel(str(nummer), size: gr) },
        text(gr, weight: 700, fill: tinte, {
          if icons.len() > 0 { text(fill: akzent, icons.join(h(0.3em))); h(0.4em) }
          titel
        }),
        if punkte != none { text(0.9em, fill: luma(110), punkte) },
      ))
    },
    teilaufgabe: lbl => text(weight: 700, fill: akzent, lbl),
    loesung: (titel, body) => block(
      width: 100%,
      breakable: true,
      fill: _gruen.lighten(93%),
      stroke: (left: 2.5pt + _gruen),
      inset: (left: 11pt, rest: 8pt),
      _loesung-inline(titel, body, label-stil: t => text(weight: 700, fill: _gruen.darken(15%), t)),
    ),
    loesung-kopf: titel => block(above: 1.8em, below: 1em, width: 100%, {
      text(1.3em, weight: 700, fill: tinte, titel)
      v(0.2em)
      line(length: 100%, stroke: 0.7pt + _gruen)
    }),
    material-kopf: titel => block(above: 1.6em, below: 0.9em, text(1.15em, weight: 700, fill: akzent, titel)),
    kasten: (art: "info", titel: none, farbe: auto, breakable: false, width: auto, body) => {
      let st = kasten-stil(art, akzent, farbe: farbe)
      let kopf = if titel != none {
        block(below: 0.6em, sticky: true, text(0.85em, weight: 700, fill: st.farbe.darken(10%), {
          fa-icon(st.icon, solid: true)
          h(0.45em)
          upper(titel)
        }))
      }
      let breite = if width == auto { 100% } else { width }
      if art == "memo" {
        // Merke: voller Rahmen, kräftiger Balken, leichte Fläche
        block(
          width: breite,
          breakable: breakable,
          fill: st.farbe.lighten(94%),
          stroke: (left: 4pt + st.farbe, rest: 0.7pt + st.farbe.lighten(30%)),
          inset: (left: 13pt, rest: 10pt),
          above: 1.2em,
          below: 1.2em,
          { kopf; body },
        )
      } else {
        block(
          width: breite,
          breakable: breakable,
          stroke: (left: 2pt + st.farbe),
          inset: (left: 12pt, y: 3pt),
          above: 1.2em,
          below: 1.2em,
          { kopf; body },
        )
      }
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(1.45em, weight: 700, fill: tinte, it.body))
      show heading.where(level: 2): it => block(above: 1.7em, below: 0.9em, sticky: true, grid(
        columns: (auto, 1fr),
        column-gutter: 0.6em,
        align: horizon,
        text(1.25em, weight: 700, fill: akzent, it.body), line(length: 100%, stroke: 0.8pt + akzent.lighten(50%)),
      ))
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(1em, weight: 700, fill: akzent, it.body))
      set table(stroke: 0.5pt + luma(185))
      set list(marker: text(fill: akzent, sym.square.filled.small))
      body
    },
  )
}

// ─── atlas ───────────────────────────────────────────────────────────────────
// Farbig wie ein modernes Schulbuch: Titelkarte in der Fachfarbe, getönte
// Karten mit Reitern, runde Ecken.

#let atlas(akzent, class) = {
  let tinte = luma(30)
  let kachel(inhalt, size: 1em) = _marke(inhalt, fill: akzent, size: size, radius: 0.35em, breite: 1.75em, inset: (x: 0.3em, y: 0.45em))
  let reiter(titel, farbe, icon) = block(below: 0pt, sticky: true, box(
    fill: farbe,
    radius: (top: 5pt),
    inset: (x: 9pt, y: 5pt),
    text(0.85em, weight: 700, fill: white, {
      if icon != none { fa-icon(icon, solid: true); h(0.4em) }
      titel
    }),
  ))
  (
    name: "atlas",
    schrift: (text: "Myriad Pro", mathe: "Fira Math", groesse: 11pt, titel: 21pt),
    rand: (kopf-oben: 1.45cm, bottom: 1.8cm),
    header-ascent: 1.25cm,
    hintergrund: (print: true, oben: 3.6cm, rand: (:)) => context {
      // Titelkarte genau über dem Satzspiegel, oben 0,9 cm Abstand zur
      // Blattkante, unten 0,6 cm unter dem Kopf (header-ascent 1,25 cm).
      let (l, r) = _seitenrand(rand, here().page())
      let h = oben - 0.65cm - 0.9cm
      place(top + left, dx: l, dy: 0.9cm, block(
        width: 100% - l - r,
        height: h,
        fill: akzent,
        radius: 7pt,
        clip: true,
        {
          place(top + right, dx: 1.3cm, dy: -1.7cm, circle(radius: 2.4cm, fill: white.transparentize(88%)))
          place(bottom + right, dx: -3.4cm, dy: 0.9cm, circle(radius: 1.2cm, fill: white.transparentize(90%)))
        },
      ))
    },
    kopf: (title: none, class: none, copyright: none, font-size: 21pt) => {
      set par(justify: false)
      block(width: 100%, inset: (x: 0.5cm), grid(
        columns: (1fr, auto),
        column-gutter: 1em,
        align: (left + bottom, right + bottom),
        stack(
          spacing: 0.5em,
          if kicker(class) != none { text(8pt, weight: 600, tracking: 0.1em, fill: white.transparentize(15%), upper(kicker(class))) },
          text(font-size, weight: 700, fill: white, title),
        ),
        box(fill: white, radius: 0.35em, inset: (x: 0.65em, y: 0.45em), text(11pt, weight: 700, fill: akzent, top-edge: "cap-height", bottom-edge: "baseline", class)),
      ))
    },
    fuss: (duplex: true) => _aussen(duplex, n => kachel(str(n), size: 9pt)),
    marke: n => move(dy: -0.68em, kachel(str(n), size: 1.2em)),
    marke-breite: 2.75em,
    aufgabe: (nummer: 1, titel: none, icons: (), punkte: none, large: true, number: true) => {
      set par(justify: false)
      let gr = if large { 1.2em } else { 1.07em }
      block(width: 100%, grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.6em,
        align: horizon,
        if number { kachel(str(nummer), size: gr) },
        text(gr, weight: 700, fill: tinte, {
          if icons.len() > 0 { text(fill: akzent, icons.join(h(0.3em))); h(0.4em) }
          titel
        }),
        if punkte != none { box(fill: akzent.lighten(85%), radius: 1em, inset: (x: 0.6em, y: 0.3em), text(0.85em, weight: 700, fill: akzent.darken(20%), punkte)) },
      ))
    },
    teilaufgabe: lbl => text(weight: 700, fill: akzent, lbl),
    loesung: (titel, body) => block(
      width: 100%,
      breakable: true,
      fill: _gruen.lighten(88%),
      radius: 6pt,
      inset: (x: 11pt, y: 8pt),
      _loesung-inline(titel, body, label-stil: t => text(weight: 700, fill: _gruen.darken(20%), [#fa-icon("check", solid: true)#h(0.35em)#t])),
    ),
    loesung-kopf: titel => block(above: 1.8em, below: 1em, box(fill: _gruen.darken(10%), radius: 6pt, inset: (x: 11pt, y: 7pt), text(1.2em, weight: 700, fill: white, titel))),
    material-kopf: titel => block(above: 1.6em, below: 0.9em, text(1.2em, weight: 700, fill: akzent, titel)),
    kasten: (art: "info", titel: none, farbe: auto, breakable: false, width: auto, body) => {
      let st = kasten-stil(art, akzent, farbe: farbe)
      let memo = art == "memo"
      block(width: if width == auto { 100% } else { width }, breakable: breakable, above: 1.2em, below: 1.2em, {
        if titel != none { reiter(titel, if memo { st.farbe.darken(15%) } else { st.farbe }, st.icon) }
        block(
          width: 100%,
          breakable: breakable,
          fill: if memo { white } else { st.farbe.lighten(88%) },
          stroke: if memo { 1.5pt + st.farbe.darken(15%) } else { none },
          radius: if titel != none { (top-left: 0pt, rest: 7pt) } else { 7pt },
          inset: 11pt,
          body,
        )
      })
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(1.6em, weight: 700, fill: akzent, it.body))
      show heading.where(level: 2): it => block(above: 1.7em, below: 0.9em, sticky: true, stack(
        spacing: 0.4em,
        text(1.45em, weight: 700, fill: akzent, it.body),
        box(width: 2.5em, height: 3pt, fill: akzent, radius: 1.5pt),
      ))
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(1.05em, weight: 700, fill: akzent, it.body))
      set table(stroke: 0.6pt + akzent.lighten(55%))
      set list(marker: text(fill: akzent, sym.bullet))
      body
    },
  )
}

// ─── skizze ──────────────────────────────────────────────────────────────────
// Verspielt für die Unterstufe: Handschrift-Überschriften, Titel auf
// Klebeband, Kürzel als schräger Zettel, gestrichelte Kästen, Namensfeld.

#let skizze(akzent, class) = {
  let hand = "Playpen Sans"
  let tinte = luma(35)
  let notizgelb = rgb("#ffe27a")
  let klebeband(breite, hoehe, fill) = {
    // Klebeband mit gezackten Enden
    let z = 6
    let dy = hoehe / z
    let links = range(z + 1).map(i => (if calc.even(i) { 0pt } else { 3pt }, i * dy))
    let rechts = range(z + 1).rev().map(i => (breite - (if calc.even(i) { 0pt } else { 3pt }), i * dy))
    polygon(fill: fill, ..links, ..rechts)
  }
  // Nummer als handgezeichnet wirkender Klecks
  let klecks(inhalt, size: 1em) = text(size, box(width: 2em, height: 2em, rotate(-6deg, box(
    width: 100%,
    height: 100%,
    fill: akzent,
    radius: (top-left: 55%, top-right: 45%, bottom-right: 60%, bottom-left: 40%),
    align(center + horizon, rotate(6deg, text(font: hand, 0.85em, weight: 700, fill: white, inhalt))),
  ))))
  (
    name: "skizze",
    schrift: (text: "SF Pro Rounded", mathe: "Fira Math", groesse: 11pt, titel: 21pt),
    rand: (kopf-oben: 1.1cm, bottom: 1.8cm),
    header-ascent: 0.7cm,
    kopf: (title: none, class: none, copyright: none, font-size: 21pt) => {
      set par(justify: false)
      let titel = text(font: hand, font-size, weight: 700, fill: tinte, title)
      grid(
        columns: (1fr, auto),
        column-gutter: 1.2em,
        align: (left + bottom, right + bottom),
        stack(
          spacing: 0.55em,
          // Kicker links, Namensfeld rechts – nur auf der ersten Seite
          // Namensfeld füllt die Zeile bis zur Spalte des Kürzel-Zettels
          grid(
            columns: (auto, 1fr),
            column-gutter: 2.5em,
            text(font: hand, 8.5pt, weight: 500, fill: akzent, if kicker(class) != none { kicker(class) }),
            context if counter(page).get().first() == 1 {
              text(font: hand, 9pt, fill: luma(90))[Name: #box(width: 1fr, line(length: 100%, stroke: (paint: luma(120), thickness: 0.8pt, dash: "dotted")))]
            },
          ),
          layout(platz => {
            let m = measure(titel)
            let b = calc.min((m.width + 1.2em).to-absolute(), platz.width)
            box(rotate(-1deg, reflow: true, box({
              place(top + left, dx: -0.6em, dy: 0.25em, klebeband(b, m.height + 0.25em, akzent.lighten(82%)))
              titel
            })))
          }),
        ),
        rotate(3deg, reflow: true, box(
          fill: akzent,
          inset: (x: 0.8em, top: 0.7em, bottom: 0.6em),
          text(font: hand, 12pt, weight: 700, fill: white, class),
        )),
      )
    },
    fuss: (duplex: true) => _aussen(duplex, n => klecks(str(n), size: 9pt)),
    marke: n => move(dy: -0.9em, klecks(str(n), size: 1.25em)),
    marke-breite: 3.15em,
    aufgabe: (nummer: 1, titel: none, icons: (), punkte: none, large: true, number: true) => {
      set par(justify: false)
      let gr = if large { 1.25em } else { 1.1em }
      block(width: 100%, grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.6em,
        align: horizon,
        if number { klecks(str(nummer), size: gr) },
        text(font: hand, gr, weight: 600, fill: tinte, {
          if icons.len() > 0 { text(fill: akzent, icons.join(h(0.3em))); h(0.4em) }
          titel
        }),
        if punkte != none { text(font: hand, 0.9em, fill: luma(110), punkte) },
      ))
    },
    teilaufgabe: lbl => text(font: hand, weight: 700, fill: akzent.darken(10%), lbl),
    loesung: (titel, body) => block(
      width: 100%,
      breakable: true,
      fill: _gruen.lighten(92%),
      stroke: (paint: _gruen, thickness: 1.2pt, dash: "dashed"),
      radius: 10pt,
      inset: (x: 11pt, y: 9pt),
      _loesung-inline(titel, body, label-stil: t => text(font: hand, weight: 700, fill: _gruen.darken(20%), [#fa-icon("check", solid: true)#h(0.35em)#t])),
    ),
    loesung-kopf: titel => block(above: 1.8em, below: 1em, text(font: hand, 1.35em, weight: 700, fill: _gruen.darken(15%), titel)),
    material-kopf: titel => block(above: 1.6em, below: 0.9em, text(font: hand, 1.2em, weight: 700, fill: akzent, titel)),
    kasten: (art: "info", titel: none, farbe: auto, breakable: false, width: auto, body) => {
      let st = kasten-stil(art, akzent, farbe: farbe)
      let kopf = if titel != none {
        block(below: 0.6em, sticky: true, text(font: hand, 0.95em, weight: 700, fill: st.farbe.darken(15%), {
          fa-icon(st.icon, solid: true)
          h(0.4em)
          titel
        }))
      }
      let memo = art == "memo"
      // Merke als gelber Zettel; Warnungen mit durchgezogenem Rand
      let rahmen = if memo { 1pt + notizgelb.darken(30%) } else if art in ("warning", "danger", "error") {
        1.4pt + st.farbe
      } else { (paint: st.farbe.lighten(15%), thickness: 1.2pt, dash: "dashed") }
      block(
        width: if width == auto { 100% } else { width },
        breakable: breakable,
        fill: if memo { notizgelb.lighten(50%) } else { st.farbe.lighten(93%) },
        stroke: rahmen,
        radius: if memo { 2pt } else { 10pt },
        inset: (x: 13pt, y: 11pt),
        above: 1.2em,
        below: 1.2em,
        { kopf; body },
      )
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(font: hand, 1.5em, weight: 700, fill: tinte, it.body))
      show heading.where(level: 2): it => block(above: 1.7em, below: 0.9em, sticky: true, text(font: hand, 1.35em, weight: 700, fill: akzent.darken(10%), highlight(
        fill: akzent.lighten(82%),
        top-edge: "x-height",
        bottom-edge: -0.15em,
        extent: 0.15em,
        it.body,
      )))
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(font: hand, 1.05em, weight: 700, fill: akzent, it.body))
      set table(stroke: 0.6pt + akzent.lighten(45%))
      set list(marker: text(fill: akzent, sym.star.filled))
      body
    },
  )
}

// ─── labor ───────────────────────────────────────────────────────────────────
// Technisch für MINT und Informatik: umrandete Titelleiste mit Messskala,
// Monospace-Marken („A1“), Kästen wie Datenblätter.

#let labor(akzent, class) = {
  let mono = "Fira Code"
  let nacht = rgb("#1c2230")
  let tinte = luma(25)
  let tag(inhalt, fill: akzent, size: 0.8em) = _marke(inhalt, fill: fill, size: size, font: mono, weight: 600, inset: (x: 0.45em, y: 0.38em))
  (
    name: "labor",
    schrift: (text: "Fira Sans", mathe: "Fira Math", groesse: 10.5pt, titel: 18pt),
    rand: (kopf-oben: 1.1cm, bottom: 1.8cm),
    header-ascent: 0.7cm,
    kopf: (title: none, class: none, copyright: none, font-size: 18pt) => {
      set par(justify: false)
      block(width: 100%, stroke: 0.9pt + nacht, radius: 3pt, inset: (x: 12pt, y: 10pt), grid(
        columns: (1fr, auto),
        column-gutter: 1em,
        align: (left + horizon, right + horizon),
        stack(
          spacing: 0.55em,
          if kicker(class) != none { text(font: mono, 7.5pt, weight: 500, tracking: 0.04em, fill: akzent, upper(kicker(class).replace(" · ", " / "))) },
          text(font-size, weight: 600, fill: tinte, title),
        ),
        tag(class, size: 10pt),
      ))
      v(-0.4em)
      // Messskala unter der Leiste, auf die Satzbreite beschnitten
      layout(platz => box(width: 100%, height: 4pt, {
        for i in range(0, int(platz.width / 3mm) + 1) {
          place(left + top, dx: i * 3mm, line(
            start: (0pt, 0pt),
            end: (0pt, if calc.rem(i, 5) == 0 { 4pt } else { 2pt }),
            stroke: 0.4pt + luma(160),
          ))
        }
      }))
    },
    fuss: (duplex: true) => _aussen(duplex, n => context tag([#n/#counter(page).final().first()], size: 8pt)),
    marke: n => move(dy: -0.36em, tag([A#n], size: 0.98em)),
    marke-breite: 2.9em,
    aufgabe: (nummer: 1, titel: none, icons: (), punkte: none, large: true, number: true) => {
      set par(justify: false)
      let gr = if large { 1.15em } else { 1.05em }
      block(width: 100%, grid(
        columns: (auto, auto, 1fr, auto),
        column-gutter: 0.6em,
        align: horizon,
        if number { tag([A#nummer], size: gr * 0.85) },
        text(gr, weight: 600, fill: tinte, {
          if icons.len() > 0 { text(fill: akzent, icons.join(h(0.3em))); h(0.4em) }
          titel
        }),
        line(length: 100%, stroke: (paint: luma(185), thickness: 0.6pt, dash: "dotted")),
        if punkte != none { text(font: mono, 0.8em, fill: akzent, punkte) },
      ))
    },
    teilaufgabe: lbl => text(font: mono, 0.92em, weight: 600, fill: akzent, tracking: -0.08em, lbl),
    loesung: (titel, body) => block(
      width: 100%,
      breakable: true,
      stroke: (left: 2pt + _gruen, rest: 0.5pt + _gruen.lighten(40%)),
      fill: _gruen.lighten(95%),
      radius: 2pt,
      inset: (left: 10pt, rest: 8pt),
      _loesung-inline(titel, body, label-stil: t => text(font: mono, 0.85em, weight: 600, fill: _gruen.darken(25%), [▸ #t])),
    ),
    loesung-kopf: titel => block(above: 1.8em, below: 1em, width: 100%, {
      text(font: mono, 1.1em, weight: 600, fill: _gruen.darken(10%), "// ")
      text(1.2em, weight: 600, fill: tinte, titel)
    }),
    material-kopf: titel => block(above: 1.6em, below: 0.9em, text(1.1em, weight: 600, fill: akzent, titel)),
    kasten: (art: "info", titel: none, farbe: auto, breakable: false, width: auto, body) => {
      let st = kasten-stil(art, akzent, farbe: farbe)
      let memo = art == "memo"
      block(
        width: if width == auto { 100% } else { width },
        breakable: breakable,
        above: 1.2em,
        below: 1.2em,
        stroke: if memo { 1.4pt + st.farbe } else { 0.7pt + st.farbe.lighten(25%) },
        radius: 2pt,
        fill: if memo { st.farbe.lighten(93%) } else { white },
        inset: (x: 11pt, y: 10pt),
        {
          if titel != none {
            block(below: 0.6em, sticky: true, {
              tag(upper(titel), fill: st.farbe, size: 0.75em)
            })
          }
          body
        },
      )
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(1.4em, weight: 600, fill: tinte, it.body))
      show heading.where(level: 2): it => block(above: 1.7em, below: 0.9em, sticky: true, {
        text(font: mono, 1.15em, weight: 600, fill: akzent, "// ")
        text(1.3em, weight: 600, fill: tinte, it.body)
      })
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(1em, weight: 600, fill: akzent, it.body))
      set table(stroke: 0.5pt + luma(170))
      set list(marker: text(font: mono, fill: akzent, [›]))
      show raw: set text(font: mono)
      body
    },
  )
}

// ─── kontur ──────────────────────────────────────────────────────────────────
// Plakativ: dicke schwarze Rahmen, harte versetzte Schatten in der
// Fachfarbe, fette Futura in Versalien. Wirkt auch als Schwarz-Weiß-Kopie.

#let kontur(akzent, class) = {
  let disp = "Futura"
  let schwarz = luma(15)
  let rahmen = 1.4pt + schwarz
  // Versalien mit echtem ẞ („GRÖẞEN“ statt „GRÖSSEN“)
  // (upper() wandelt vor jeder Show-Regel um, darum über den Klartext)
  let versal(x) = {
    let t = _klartext(x)
    if t != "" { upper(t.replace("ß", "ẞ")) } else { upper(x) }
  }
  let kachel(inhalt, size: 1em) = _schatten-box(
    _marke(inhalt, fill: akzent, size: size, radius: 0pt, font: disp, stroke: rahmen, breite: 1.75em * 1, inset: (x: 0.3em, y: 0.42em)),
    farbe: schwarz,
  )
  (
    name: "kontur",
    schrift: (text: "Helvetica Neue", mathe: "Fira Math", groesse: 10.5pt, titel: 26pt),
    rand: (kopf-oben: 1.25cm, bottom: 1.8cm),
    header-ascent: 0.8cm,
    kopf: (title: none, class: none, copyright: none, font-size: 26pt) => {
      set par(justify: false, leading: 0.35em)
      grid(
        columns: (1fr, auto),
        column-gutter: 1em,
        align: (left + bottom, right + bottom),
        stack(
          spacing: 0.7em,
          if kicker(class) != none {
            box(fill: schwarz, inset: (x: 0.5em, y: 0.4em), text(7.5pt, weight: 700, tracking: 0.12em, fill: white, top-edge: "cap-height", bottom-edge: "baseline", upper(kicker(class))))
          },
          text(font: disp, font-size, weight: 700, fill: schwarz, versal(title)),
        ),
        _schatten-box(
          _marke(class, fill: akzent, size: 11pt, radius: 0pt, font: disp, stroke: rahmen, inset: (x: 0.6em, y: 0.5em)),
          farbe: schwarz,
          versatz: 3pt,
        ),
      )
      v(0.55em)
      line(length: 100%, stroke: 3pt + schwarz)
    },
    fuss: (duplex: true) => _aussen(duplex, n => kachel(str(n), size: 9pt)),
    marke: n => move(dy: -0.66em, kachel(str(n), size: 1.15em)),
    marke-breite: 2.75em,
    aufgabe: (nummer: 1, titel: none, icons: (), punkte: none, large: true, number: true) => {
      set par(justify: false)
      let gr = if large { 1.15em } else { 1.05em }
      block(width: 100%, grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.65em,
        align: horizon,
        if number { kachel(str(nummer), size: gr) },
        text(font: disp, gr, weight: 700, fill: schwarz, tracking: 0.02em, {
          if icons.len() > 0 { icons.join(h(0.3em)); h(0.4em) }
          if titel != none { versal(titel) }
        }),
        if punkte != none { box(stroke: rahmen, inset: (x: 0.5em, y: 0.3em), text(0.85em, weight: 700, punkte)) },
      ))
    },
    teilaufgabe: lbl => text(weight: 700, fill: akzent.darken(10%), lbl),
    // Lösung: der Schatten als dicke Kante rechts/unten – bleibt umbrechbar
    // und schließt bündig mit den Kästen (Rahmen + Schatten) ab.
    loesung: (titel, body) => block(
      width: 100%,
      breakable: true,
      fill: _gruen.lighten(88%),
      stroke: { let g = _gruen.darken(25%); (left: 1.4pt + g, top: 1.4pt + g, right: 4pt + g, bottom: 4pt + g) },
      inset: (left: 10pt, right: 12pt, top: 8pt, bottom: 10pt),
      _loesung-inline(titel, body, label-stil: t => text(weight: 700, fill: _gruen.darken(30%), t)),
    ),
    loesung-kopf: titel => block(above: 1.8em, below: 1em, text(font: disp, 1.3em, weight: 700, fill: schwarz, upper(titel))),
    material-kopf: titel => block(above: 1.6em, below: 0.9em, text(font: disp, 1.15em, weight: 700, upper(titel))),
    kasten: (art: "info", titel: none, farbe: auto, breakable: false, width: auto, body) => {
      let st = kasten-stil(art, akzent, farbe: farbe)
      let memo = art == "memo"
      let innen = block(
        width: 100%,
        breakable: breakable,
        fill: if memo { akzent.lighten(88%) } else { white },
        stroke: rahmen,
        inset: (x: 12pt, y: 10pt),
        {
          if titel != none {
            block(below: 0.65em, sticky: true, box(fill: st.farbe, stroke: rahmen, inset: (x: 0.5em, y: 0.38em), text(
              font: disp,
              0.82em,
              weight: 700,
              tracking: 0.06em,
              fill: white,
              top-edge: "cap-height",
              bottom-edge: "baseline",
              [#fa-icon(st.icon, solid: true)#h(0.4em)#upper(titel)],
            )))
          }
          body
        },
      )
      let breite = if width == auto { 100% } else { width }
      block(width: breite, above: 1.3em, below: 1.4em, if breakable { innen } else {
        _schatten-block(innen, farbe: if memo { schwarz } else { st.farbe })
      })
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(font: disp, 1.6em, weight: 700, fill: schwarz, versal(it.body)))
      show heading.where(level: 2): it => block(above: 1.7em, below: 0.9em, sticky: true, text(font: disp, 1.4em, weight: 700, fill: schwarz, tracking: 0.02em, highlight(
        fill: akzent.lighten(65%),
        top-edge: "x-height",
        bottom-edge: -0.12em,
        extent: 0.18em,
        versal(it.body),
      )))
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(font: disp, 1.05em, weight: 700, versal(it.body)))
      set table(stroke: 0.9pt + schwarz)
      set list(marker: text(fill: schwarz, sym.square.filled.small))
      body
    },
  )
}

// ─── leiste ──────────────────────────────────────────────────────────────────
// Kennung am Rand: eine Leiste in der Fachfarbe an der Außenkante trägt
// Kürzel, Fach und Seitenzahl. Der Inhalt bleibt luftig, Nummern sind rund.

#let leiste(akzent, class) = {
  let disp = "Montserrat"
  let tinte = luma(30)
  let band-b = 0.75cm
  let rund(inhalt, size: 1em) = text(size, box(width: 1.85em, height: 1.85em, fill: akzent, radius: 50%, align(center + horizon, text(
    font: disp,
    0.95em,
    weight: 700,
    fill: white,
    inhalt,
  ))))
  (
    name: "leiste",
    schrift: (text: "Lato", mathe: "Lato Math", groesse: 10.5pt, titel: 22pt),
    // aussen 2,75 cm: Satzspiegel 21 − 2,25 − 2,75 = 16,0 cm, ein Vielfaches von
    // 5 mm – Kästchenfelder schließen bündig ab.
    rand: (kopf-oben: 1.3cm, bottom: 1.4cm, aussen: 2.75cm),
    header-ascent: 0.8cm,
    hintergrund: (print: true, oben: 3cm, rand: (:)) => context {
      let n = here().page()
      // Außenkante: bei beidseitigem Druck auf geraden Seiten links
      let links = type(rand) == dictionary and "inside" in rand and calc.even(n)
      // Relativ platzieren: page.width ignoriert `flipped` (Querformat)
      // Helle Leiste (wenig Toner), Kürzel und Seitenzahl als gefüllte Marken
      place(if links { top + left } else { top + right }, dx: if links { 0.85cm } else { -0.85cm }, dy: 1cm, block(width: band-b, height: 100% - 2cm, fill: akzent.lighten(78%), radius: 2pt, {
        place(top + center, dy: 0.3cm, box(fill: akzent, radius: 1.5pt, inset: (x: 0.28em, y: 0.45em), rotate(
          -90deg,
          reflow: true,
          text(font: disp, 8.5pt, weight: 700, fill: white, top-edge: "cap-height", bottom-edge: "baseline", class),
        )))
        if print {
          place(bottom + center, dy: -0.3cm, box(width: 1.75em, height: 1.75em, fill: akzent, radius: 50%, align(center + horizon, text(
            font: disp,
            8.5pt,
            weight: 700,
            fill: white,
            str(n),
          ))))
        }
      }))
    },
    kopf: (title: none, class: none, copyright: none, font-size: 22pt) => {
      set par(justify: false, leading: 0.45em)
      stack(
        spacing: 0.6em,
        if kicker(class) != none { text(font: disp, 7.5pt, weight: 700, tracking: 0.16em, fill: akzent, upper(kicker(class))) },
        text(font: disp, font-size, weight: 700, fill: tinte, bottom-edge: "descender", title),
        box(width: 2.6cm, height: 3pt, fill: akzent, radius: 1.5pt),
      )
    },
    marke: n => move(dy: -0.74em, rund(str(n), size: 1.15em)),
    marke-breite: 2.75em,
    aufgabe: (nummer: 1, titel: none, icons: (), punkte: none, large: true, number: true) => {
      set par(justify: false)
      let gr = if large { 1.15em } else { 1.05em }
      block(width: 100%, grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.6em,
        align: horizon,
        if number { rund(str(nummer), size: gr) },
        text(font: disp, gr, weight: 700, fill: tinte, {
          if icons.len() > 0 { text(fill: akzent, icons.join(h(0.3em))); h(0.4em) }
          titel
        }),
        if punkte != none { text(font: disp, 0.8em, weight: 700, fill: akzent, punkte) },
      ))
    },
    teilaufgabe: lbl => text(font: disp, 0.9em, weight: 700, fill: akzent, lbl),
    loesung: (titel, body) => block(
      width: 100%,
      breakable: true,
      fill: _gruen.lighten(92%),
      stroke: (top: 2.5pt + _gruen),
      inset: (x: 10pt, y: 8pt),
      _loesung-inline(titel, body, label-stil: t => text(font: disp, 0.9em, weight: 700, fill: _gruen.darken(20%), t)),
    ),
    loesung-kopf: titel => block(above: 1.8em, below: 1em, text(font: disp, 1.3em, weight: 700, fill: _gruen.darken(15%), titel)),
    material-kopf: titel => block(above: 1.6em, below: 0.9em, text(font: disp, 1.1em, weight: 700, fill: akzent, titel)),
    kasten: (art: "info", titel: none, farbe: auto, breakable: false, width: auto, body) => {
      let st = kasten-stil(art, akzent, farbe: farbe)
      let memo = art == "memo"
      block(
        width: if width == auto { 100% } else { width },
        breakable: breakable,
        fill: st.farbe.lighten(if memo { 86% } else { 93% }),
        stroke: (top: (if memo { 5pt } else { 3pt }) + st.farbe),
        inset: (x: 12pt, top: 10pt, bottom: 11pt),
        above: 1.3em,
        below: 1.3em,
        {
          if titel != none {
            block(below: 0.6em, sticky: true, text(font: disp, 0.75em, weight: 700, tracking: 0.1em, fill: st.farbe.darken(15%), [#fa-icon(st.icon, solid: true)#h(0.5em)#upper(titel)]))
          }
          body
        },
      )
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(font: disp, 1.5em, weight: 700, fill: tinte, it.body))
      show heading.where(level: 2): it => block(above: 1.8em, below: 0.9em, sticky: true, {
        box(width: 0.55em, height: 0.55em, fill: akzent, radius: 50%)
        h(0.5em)
        text(font: disp, 1.3em, weight: 700, fill: tinte, it.body)
      })
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(font: disp, 1em, weight: 700, fill: akzent, it.body))
      set table(stroke: (x, y) => (bottom: 0.5pt + luma(180), top: if y == 0 { 1.2pt + akzent } else { 0.5pt + luma(180) }))
      set list(marker: text(fill: akzent, sym.circle.filled.small))
      body
    },
  )
}

// ─── riso ────────────────────────────────────────────────────────────────────
// Wie im Zweifarbdruck (Risograph): Fachfarbe plus Pink, leicht versetzter
// Titel, Rasterpunkte, kräftige Slab-Schrift.

#let riso(akzent, class) = {
  let disp = "Rockwell"
  let pink = rgb("#ff4f9a")
  let tinte = luma(25)
  let raster(f, d: 2.2mm, r: 0.42mm) = tiling(size: (d, d), place(dx: d / 2 - r, dy: d / 2 - r, circle(radius: r, fill: f)))
  // Zwei „Druckfarben“ übereinander, die zweite leicht verrutscht
  let doppelt(baue, dx: 1.6pt, dy: 1.3pt) = box({
    place(top + left, dx: dx, dy: dy, baue(pink.transparentize(45%)))
    baue(akzent.darken(8%))
  })
  // Marke mit Rasterschatten in Pink (in S/W ein gepunkteter Schatten,
  // kein Doppelbild)
  let kreis(inhalt, size: 1em) = text(size, box(width: 1.75em + 4.5pt, height: 1.75em + 4.5pt, {
    place(top + left, dx: 4.5pt, dy: 4.5pt, rect(width: 1.75em, height: 1.75em, radius: 0.3em, fill: raster(pink, d: 1.1mm, r: 0.33mm)))
    place(top + left, box(width: 1.75em, height: 1.75em, fill: akzent, radius: 0.3em, align(center + horizon, text(
      font: disp,
      0.9em,
      weight: 700,
      fill: white,
      inhalt,
    ))))
  }))
  (
    name: "riso",
    schrift: (text: "PT Sans", mathe: "Fira Math", groesse: 11pt, titel: 27pt),
    rand: (kopf-oben: 1.2cm, bottom: 1.8cm),
    header-ascent: 0.75cm,
    kopf: (title: none, class: none, copyright: none, font-size: 27pt) => {
      set par(justify: false, leading: 0.4em)
      grid(
        columns: (1fr, auto),
        column-gutter: 1em,
        align: (left + bottom, right + bottom),
        stack(
          spacing: 0.6em,
          if kicker(class) != none { text(8pt, weight: 700, tracking: 0.14em, fill: pink.darken(25%), upper(kicker(class))) },
          doppelt(c => text(font: disp, font-size, weight: 700, fill: c, title)),
        ),
        box({
          place(top + left, dx: 4.5pt, dy: 4.5pt, _marke(class, fill: raster(pink, d: 1.1mm, r: 0.33mm), farbe: rgb(0, 0, 0, 0), size: 11pt, radius: 0.3em, font: disp, inset: (x: 0.6em, y: 0.5em)))
          _marke(class, fill: akzent, size: 11pt, radius: 0.3em, font: disp, inset: (x: 0.6em, y: 0.5em))
        }),
      )
      v(0.4em)
      rect(width: 100%, height: 3.5mm, fill: raster(pink.transparentize(30%)), stroke: none)
    },
    fuss: (duplex: true) => _aussen(duplex, n => kreis(str(n), size: 9pt)),
    marke: n => move(dy: -0.66em, kreis(str(n), size: 1.15em)),
    marke-breite: 2.95em,
    aufgabe: (nummer: 1, titel: none, icons: (), punkte: none, large: true, number: true) => {
      set par(justify: false)
      let gr = if large { 1.2em } else { 1.08em }
      block(width: 100%, grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.6em,
        align: horizon,
        if number { kreis(str(nummer), size: gr) },
        text(font: disp, gr, weight: 700, fill: tinte, {
          if icons.len() > 0 { text(fill: akzent, icons.join(h(0.3em))); h(0.4em) }
          titel
        }),
        if punkte != none { text(font: disp, 0.85em, weight: 700, fill: pink.darken(25%), punkte) },
      ))
    },
    teilaufgabe: lbl => text(font: disp, weight: 700, fill: akzent.darken(8%), lbl),
    loesung: (titel, body) => block(
      width: 100%,
      breakable: true,
      fill: _gruen.lighten(88%),
      inset: (x: 10pt, y: 8pt),
      _loesung-inline(titel, body, label-stil: t => text(font: disp, weight: 700, fill: _gruen.darken(25%), t)),
    ),
    loesung-kopf: titel => block(above: 1.8em, below: 1em, text(font: disp, 1.4em, weight: 700, fill: _gruen.darken(20%), titel)),
    material-kopf: titel => block(above: 1.6em, below: 0.9em, text(font: disp, 1.15em, weight: 700, fill: akzent, titel)),
    kasten: (art: "info", titel: none, farbe: auto, breakable: false, width: auto, body) => {
      let st = kasten-stil(art, akzent, farbe: farbe)
      let memo = art == "memo"
      let f = if memo { pink } else { st.farbe }
      let w = if memo { 1.8pt } else { 1.2pt }
      block(
        width: if width == auto { 100% } else { width },
        breakable: breakable,
        stroke: w + st.farbe,
        // Innenabstand = Rahmenbreite: die Flächen innen überdecken den Rahmen nicht
        inset: w,
        above: 1.3em,
        below: 1.3em,
        {
          set block(spacing: 0pt)
          if titel != none {
            block(width: 100%, sticky: true, fill: raster(f.transparentize(if memo { 45% } else { 55% })), inset: (x: 8pt, y: 5pt), box(
              fill: white,
              inset: (x: 4pt, y: 3pt),
              text(font: disp, 0.95em, weight: 700, fill: st.farbe.darken(15%), [#fa-icon(st.icon, solid: true)#h(0.45em)#titel]),
            ))
          }
          block(width: 100%, breakable: breakable, fill: st.farbe.lighten(94%), inset: 10pt, {
            set block(spacing: 1.2em)
            body
          })
        },
      )
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(font: disp, 1.6em, weight: 700, fill: tinte, it.body))
      show heading.where(level: 2): it => block(above: 1.8em, below: 0.9em, sticky: true, text(font: disp, 1.45em, weight: 700, fill: tinte, highlight(
        fill: pink.lighten(55%),
        top-edge: "x-height",
        bottom-edge: -0.12em,
        extent: 0.15em,
        it.body,
      )))
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(font: disp, 1.05em, weight: 700, fill: akzent, it.body))
      set table(stroke: 0.7pt + akzent.lighten(20%))
      set list(marker: text(fill: akzent, sym.square.filled.small))
      body
    },
  )
}

// ─── bauhaus ─────────────────────────────────────────────────────────────────
// Geometrisch: Kreis, Quadrat und Dreieck als Signet und Aufgabennummern,
// Viertelkreise in den Kastenecken, Gill Sans.

#let bauhaus(akzent, class) = {
  let disp = "Gill Sans"
  let tinte = luma(25)
  let grau = luma(70)
  // Nummernform wechselt: 1 Kreis, 2 Quadrat, 3 Dreieck, 4 Kreis …
  let form(n, inhalt, size: 1em) = text(size, box(width: 1.9em, height: 1.9em, {
    let k = calc.rem(n - 1, 3)
    if k == 0 { place(circle(radius: 0.95em, fill: akzent)) }
    else if k == 1 { place(dx: 0.1em, dy: 0.1em, rect(width: 1.7em, height: 1.7em, fill: akzent)) }
    // Das Dreieck ragt etwas über das Feld hinaus, damit die Ziffer so groß
    // wie in Kreis und Quadrat sein kann; sie sitzt tiefer (Schwerpunkt)
    else { place(polygon(fill: akzent, (0.95em, -0.35em), (2.25em, 1.95em), (-0.35em, 1.95em))) }
    // Ziffern in Futura: die Gill-Sans-„1“ ist von einem „I“ kaum zu unterscheiden
    place(center + horizon, dy: if k == 2 { 0.38em } else { 0em }, text(font: "Futura", 0.9em, weight: 700, fill: white, inhalt))
  }))
  let viertel(f, r: 0.9cm) = box(width: r, height: r, clip: true, place(dx: -r, dy: -r, circle(radius: r, fill: f)))
  (
    name: "bauhaus",
    schrift: (text: "Gill Sans", mathe: "Fira Math", groesse: 11.5pt, titel: 25pt),
    rand: (kopf-oben: 1.2cm, bottom: 1.8cm),
    header-ascent: 0.8cm,
    kopf: (title: none, class: none, copyright: none, font-size: 25pt) => {
      set par(justify: false, leading: 0.4em)
      grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.9em,
        align: (left + bottom, left + bottom, right + bottom),
        // Signet: Kreis, Quadrat, Dreieck
        box(width: 1.5cm, height: 1.5cm, {
          place(top + left, circle(radius: 0.48cm, fill: akzent))
          place(bottom + left, dx: 0.1cm, rect(width: 0.6cm, height: 0.6cm, fill: grau))
          place(bottom + right, polygon(fill: akzent.lighten(45%), (0.35cm, 0cm), (0.7cm, 0.62cm), (0cm, 0.62cm)))
        }),
        stack(
          spacing: 0.55em,
          if kicker(class) != none { text(font: disp, 8.5pt, weight: 600, tracking: 0.16em, fill: akzent, upper(kicker(class))) },
          text(font: disp, font-size, weight: 700, fill: tinte, title),
        ),
        _marke(class, fill: akzent, size: 11pt, radius: 0pt, font: disp, inset: (x: 0.6em, y: 0.5em)),
      )
      v(0.55em)
      grid(columns: (35%, 1fr), line(length: 100%, stroke: 4pt + akzent), line(length: 100%, stroke: 1pt + grau))
    },
    fuss: (duplex: true) => _aussen(duplex, n => form(1, str(n), size: 8.5pt)),
    marke: n => move(dy: -0.72em, form(n, str(n), size: 1.1em)),
    marke-breite: 2.75em,
    aufgabe: (nummer: 1, titel: none, icons: (), punkte: none, large: true, number: true) => {
      set par(justify: false)
      let gr = if large { 1.2em } else { 1.08em }
      block(width: 100%, grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.6em,
        align: horizon,
        if number { form(nummer, str(nummer), size: gr * 0.95) },
        text(font: disp, gr, weight: 700, fill: tinte, {
          if icons.len() > 0 { text(fill: akzent, icons.join(h(0.3em))); h(0.4em) }
          titel
        }),
        if punkte != none { text(font: disp, 0.9em, weight: 600, fill: akzent, punkte) },
      ))
    },
    teilaufgabe: lbl => text(font: disp, weight: 700, fill: akzent, lbl),
    loesung: (titel, body) => block(
      width: 100%,
      breakable: true,
      fill: _gruen.lighten(90%),
      inset: (left: 0.8cm, rest: 8pt),
      {
        place(top + left, dx: -0.8cm, dy: -8pt, viertel(_gruen, r: 0.5cm))
        _loesung-inline(titel, body, label-stil: t => text(font: disp, weight: 700, fill: _gruen.darken(25%), t))
      },
    ),
    loesung-kopf: titel => block(above: 1.8em, below: 1em, text(font: disp, 1.35em, weight: 700, fill: _gruen.darken(20%), titel)),
    material-kopf: titel => block(above: 1.6em, below: 0.9em, text(font: disp, 1.15em, weight: 700, fill: akzent, titel)),
    kasten: (art: "info", titel: none, farbe: auto, breakable: false, width: auto, body) => {
      let st = kasten-stil(art, akzent, farbe: farbe)
      let memo = art == "memo"
      block(
        width: if width == auto { 100% } else { width },
        breakable: breakable,
        fill: st.farbe.lighten(if memo { 88% } else { 94% }),
        stroke: if memo { (bottom: 3pt + st.farbe) } else { none },
        inset: (left: 1.15cm, right: 12pt, y: 11pt),
        above: 1.3em,
        below: 1.3em,
        {
          // Viertelkreis in der Ecke, darin das Symbol
          place(top + left, dx: -1.15cm, dy: -11pt, {
            viertel(st.farbe)
            place(top + left, dx: 0.17cm, dy: 0.15cm, text(9pt, fill: white, fa-icon(st.icon, solid: true)))
          })
          if titel != none {
            block(below: 0.6em, sticky: true, text(font: disp, 0.95em, weight: 700, fill: st.farbe.darken(15%), upper(titel)))
          }
          body
        },
      )
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(font: disp, 1.6em, weight: 700, fill: tinte, it.body))
      show heading.where(level: 2): it => block(above: 1.8em, below: 0.9em, sticky: true, {
        // Balken: kommt im Nummernwechsel (Kreis, Quadrat, Dreieck) nicht vor
        box(width: 1.1em, height: 0.32em, fill: akzent, baseline: -0.12em)
        h(0.5em)
        text(font: disp, 1.4em, weight: 700, fill: tinte, it.body)
      })
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(font: disp, 1.05em, weight: 700, fill: akzent, it.body))
      set table(stroke: 0.6pt + grau)
      set list(marker: text(fill: akzent, sym.square.filled.small))
      // Gill Sans hat eine kleine x-Höhe; Fira Math in 90 % passt dazu
      show math.equation.where(block: false): set text(size: 0.9em)
      body
    },
  )
}

// ─── Verzeichnis ─────────────────────────────────────────────────────────────

#let themes = (
  klar: klar,
  atlas: atlas,
  skizze: skizze,
  labor: labor,
  kontur: kontur,
  leiste: leiste,
  riso: riso,
  bauhaus: bauhaus,
)

/// Löst den `theme`-Parameter auf: `none`/"standard" → klassisch (none),
/// Name → eingebautes Theme, Funktion → eigenes Theme, Dictionary → fertig.
#let _theme-aufloesen(theme, akzent, class) = {
  if theme == none or theme == "standard" { return none }
  let a = if akzent == auto { fachfarbe(class) } else { akzent }
  if type(theme) == str {
    assert(theme in themes, message: "Unbekanntes Theme " + repr(theme) + ". Verfügbar: standard, " + themes.keys().join(", "))
    (themes.at(theme))(a, class)
  } else if type(theme) == function {
    theme(a, class)
  } else if type(theme) == dictionary {
    theme
  } else {
    panic("theme muss none, ein Name, eine Funktion oder ein Dictionary sein, erhalten: " + repr(theme))
  }
}
