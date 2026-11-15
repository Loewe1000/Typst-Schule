// Themes für @schule/arbeitsblatt (seit 0.4.0, Vertrag in englischen Namen seit 0.5.0)
//
// Ein Theme ist ein Dictionary mit Darstellungsfunktionen. Es entsteht aus
// einer Theme-Funktion `(accent: auto, class: none) => dictionary`;
// `arbeitsblatt` ruft sie mit der Fachfarbe (oder dem Parameter `accent:`) und
// dem Klassenkürzel auf. Alle Einträge sind optional – fehlt einer, gilt die
// klassische Darstellung. Schlüssel und Hook-Signaturen stehen am Kopf von
// internal.typ (Abschnitt 3) und im Handbuch, Abschnitt „Themes".
//
// Wiedererkennung: Alle Themes teilen dieselben Bausteine – Fachfarbe,
// Kopfzeile „Fach · Klasse" über dem Titel, Klassenkürzel oben rechts,
// Seitenzahl unten außen und Aufgabennummer jeweils als gefüllte Marke in der
// Fachfarbe, Lösungen immer grün. Jedes Theme zeichnet sie auf seine Art.

#import "@preview/fontawesome:0.6.0": fa-icon
#import "@schule/aufgaben:0.5.0" as aufgaben
#import "internal.typ": (
  badge, callout-style, class-accent, copyright-code, outside-aligned, palette, plain-text, shadow-block, shadow-box,
  side-margins, solution-inline, subject-accents, subject-line, subject-names,
)

// Der QR-Code aus `copyright-url` neben einem Element der Kopfzeile. Ohne
// Adresse bleibt das Element, wie es ist.
#let with-copyright(url, fill: luma(110), body) = if url == none { body } else {
  grid(columns: 2, column-gutter: 0.5em, align: horizon, copyright-code(url, size: 1.5em, fill: fill), body)
}

// ─── klar ────────────────────────────────────────────────────────────────────
// Sparsam und modern: Linien statt Flächen, viel Weißraum, quadratische
// Marken. Die Weiterentwicklung der 5a-Übungsblätter – tonerfreundlich.

#let klar(accent: auto, class: none) = {
  let sheet-accent = if accent == auto { class-accent(class) } else { accent }
  let ink = luma(30)
  let tile(size: 1em, body) = badge(body, fill: sheet-accent, size: size, width: 1.65em, inset: (x: 0.3em, y: 0.42em))
  (
    name: "klar",
    font: "Avenir Next",
    math-font: "Fira Math",
    font-size: 10.5pt,
    title-font-size: 20pt,
    margin: (bottom: 1.8cm),
    header-top: 1.3cm,
    header-ascent: 0.75cm,
    header: (title: none, class: none, copyright-url: none, font-size: auto) => {
      let font-size = if font-size == auto { 20pt } else { font-size }
      set par(justify: false)
      grid(
        columns: (1fr, auto),
        column-gutter: 1em,
        align: (left + bottom, right + bottom),
        stack(
          spacing: 0.55em,
          if subject-line(class) != none { text(7.5pt, weight: 600, tracking: 0.14em, fill: sheet-accent, upper(subject-line(class))) },
          text(font-size, weight: 700, fill: ink, title),
        ),
        with-copyright(copyright-url, badge(class, fill: sheet-accent, size: 10.5pt, inset: (x: 0.6em, y: 0.45em))),
      )
      v(0.5em)
      line(length: 100%, stroke: 0.7pt + luma(210))
    },
    footer: (duplex: true) => outside-aligned(duplex: duplex, n => tile(str(n), size: 9pt)),
    task-marker: task-number => move(dy: -0.64em, tile(str(task-number), size: 1.2em)),
    task-marker-width: 2.65em,
    task: (marker: none, title: none, icons: (), points: none, large: true) => {
      set par(justify: false)
      let head-size = if large { 1.2em } else { 1.05em }
      block(width: 100%, grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.6em,
        align: horizon,
        if marker != none { tile(marker, size: head-size) },
        text(head-size, weight: 700, fill: ink, {
          if icons.len() > 0 { text(fill: sheet-accent, icons.join(h(0.3em))); h(0.4em) }
          title
        }),
        if points != none { text(0.9em, fill: luma(110), points) },
      ))
    },
    subtask: marker => text(weight: 700, fill: sheet-accent, marker),
    solution: (title: none, body) => block(
      width: 100%,
      breakable: true,
      fill: palette.green.lighten(93%),
      stroke: (left: 2.5pt + palette.green),
      inset: (left: 11pt, rest: 8pt),
      solution-inline(title: title, body, marker-style: t => text(weight: 700, fill: palette.green.darken(15%), t)),
    ),
    solution-heading: title => block(above: 1.8em, below: 1em, width: 100%, {
      text(1.3em, weight: 700, fill: ink, title)
      v(0.2em)
      line(length: 100%, stroke: 0.7pt + palette.green)
    }),
    material-heading: title => block(above: 1.6em, below: 0.9em, text(1.15em, weight: 700, fill: sheet-accent, title)),
    callout: (kind: "info", title: none, accent: auto, breakable: false, width: auto, body) => {
      let style = callout-style(kind, worksheet-accent: sheet-accent, accent: accent)
      let heading = if title != none {
        block(below: 0.6em, sticky: true, text(0.85em, weight: 700, fill: style.accent.darken(10%), {
          fa-icon(style.icon-name, solid: true)
          h(0.45em)
          upper(title)
        }))
      }
      let width = if width == auto { 100% } else { width }
      if kind == "memo" {
        // Merke: voller Rahmen, kräftiger Balken, leichte Fläche
        block(
          width: width,
          breakable: breakable,
          fill: style.accent.lighten(94%),
          stroke: (left: 4pt + style.accent, rest: 0.7pt + style.accent.lighten(30%)),
          inset: (left: 13pt, rest: 10pt),
          above: 1.2em,
          below: 1.2em,
          { heading; body },
        )
      } else {
        block(
          width: width,
          breakable: breakable,
          stroke: (left: 2pt + style.accent),
          inset: (left: 12pt, y: 3pt),
          above: 1.2em,
          below: 1.2em,
          { heading; body },
        )
      }
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(1.45em, weight: 700, fill: ink, it.body))
      show heading.where(level: 2): it => block(above: 1.7em, below: 0.9em, sticky: true, grid(
        columns: (auto, 1fr),
        column-gutter: 0.6em,
        align: horizon,
        text(1.25em, weight: 700, fill: sheet-accent, it.body), line(length: 100%, stroke: 0.8pt + sheet-accent.lighten(50%)),
      ))
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(1em, weight: 700, fill: sheet-accent, it.body))
      set table(stroke: 0.5pt + luma(185))
      set list(marker: text(fill: sheet-accent, sym.square.filled.small))
      body
    },
  )
}

// ─── atlas ───────────────────────────────────────────────────────────────────
// Farbig wie ein modernes Schulbuch: Titelkarte in der Fachfarbe, getönte
// Karten mit Reitern, runde Ecken.

#let atlas(accent: auto, class: none) = {
  let sheet-accent = if accent == auto { class-accent(class) } else { accent }
  let ink = luma(30)
  let tile(size: 1em, body) = badge(body, fill: sheet-accent, size: size, radius: 0.35em, width: 1.75em, inset: (x: 0.3em, y: 0.45em))
  // stroke: Strichstärke des Kastens darunter. Der Reiter bekommt denselben Strich,
  // damit seine linke Kante bündig mit dem Kastenrand abschließt (sonst steht der
  // halbe Strich des Kastens unter der runden Reiter-Ecke hervor).
  let tab(title: none, fill: black, icon-name: none, stroke: none) = block(below: 0pt, sticky: true, box(
    fill: fill,
    stroke: if stroke == none { none } else { stroke + fill },
    radius: (top: 5pt),
    inset: (x: 9pt, y: 5pt),
    text(0.85em, weight: 700, fill: white, {
      if icon-name != none { fa-icon(icon-name, solid: true); h(0.4em) }
      title
    }),
  ))
  (
    name: "atlas",
    font: "Myriad Pro",
    math-font: "Fira Math",
    font-size: 11pt,
    title-font-size: 21pt,
    margin: (bottom: 1.8cm),
    header-top: 1.45cm,
    header-ascent: 1.25cm,
    background: (print: true, margin: (:), header-top: 3.6cm) => context {
      // Titelkarte genau über dem Satzspiegel, header-top 0,9 cm Abstand zur
      // Blattkante, unten 0,6 cm unter dem Kopf (header-ascent 1,25 cm).
      let (l, r) = side-margins(margin, here().page())
      let h = header-top - 0.65cm - 0.9cm
      place(top + left, dx: l, dy: 0.9cm, block(
        width: 100% - l - r,
        height: h,
        fill: sheet-accent,
        radius: 7pt,
        clip: true,
        {
          place(top + right, dx: 1.3cm, dy: -1.7cm, circle(radius: 2.4cm, fill: white.transparentize(88%)))
          place(bottom + right, dx: -3.4cm, dy: 0.9cm, circle(radius: 1.2cm, fill: white.transparentize(90%)))
        },
      ))
    },
    header: (title: none, class: none, copyright-url: none, font-size: auto) => {
      let font-size = if font-size == auto { 21pt } else { font-size }
      set par(justify: false)
      block(width: 100%, inset: (x: 0.5cm), grid(
        columns: (1fr, auto),
        column-gutter: 1em,
        align: (left + bottom, right + bottom),
        stack(
          spacing: 0.5em,
          if subject-line(class) != none { text(8pt, weight: 600, tracking: 0.1em, fill: white.transparentize(15%), upper(subject-line(class))) },
          text(font-size, weight: 700, fill: white, title),
        ),
        with-copyright(copyright-url, fill: white, box(fill: white, radius: 0.35em, inset: (x: 0.65em, y: 0.45em), text(11pt, weight: 700, fill: sheet-accent, top-edge: "cap-height", bottom-edge: "baseline", class))),
      ))
    },
    footer: (duplex: true) => outside-aligned(duplex: duplex, n => tile(str(n), size: 9pt)),
    task-marker: task-number => move(dy: -0.68em, tile(str(task-number), size: 1.2em)),
    task-marker-width: 2.75em,
    task: (marker: none, title: none, icons: (), points: none, large: true) => {
      set par(justify: false)
      let head-size = if large { 1.2em } else { 1.07em }
      block(width: 100%, grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.6em,
        align: horizon,
        if marker != none { tile(marker, size: head-size) },
        text(head-size, weight: 700, fill: ink, {
          if icons.len() > 0 { text(fill: sheet-accent, icons.join(h(0.3em))); h(0.4em) }
          title
        }),
        if points != none { box(fill: sheet-accent.lighten(85%), radius: 1em, inset: (x: 0.6em, y: 0.3em), text(0.85em, weight: 700, fill: sheet-accent.darken(20%), points)) },
      ))
    },
    subtask: marker => text(weight: 700, fill: sheet-accent, marker),
    solution: (title: none, body) => block(
      width: 100%,
      breakable: true,
      fill: palette.green.lighten(88%),
      radius: 6pt,
      inset: (x: 11pt, y: 8pt),
      solution-inline(title: title, body, marker-style: t => text(weight: 700, fill: palette.green.darken(20%), [#fa-icon("check", solid: true)#h(0.35em)#t])),
    ),
    solution-heading: title => block(above: 1.8em, below: 1em, box(fill: palette.green.darken(10%), radius: 6pt, inset: (x: 11pt, y: 7pt), text(1.2em, weight: 700, fill: white, title))),
    material-heading: title => block(above: 1.6em, below: 0.9em, text(1.2em, weight: 700, fill: sheet-accent, title)),
    callout: (kind: "info", title: none, accent: auto, breakable: false, width: auto, body) => {
      let style = callout-style(kind, worksheet-accent: sheet-accent, accent: accent)
      let memo = kind == "memo"
      block(width: if width == auto { 100% } else { width }, breakable: breakable, above: 1.2em, below: 1.2em, {
        if title != none { tab(title: title, fill: if memo { style.accent.darken(15%) } else { style.accent }, icon-name: style.icon-name, stroke: if memo { 1.5pt } else { none }) }
        block(
          width: 100%,
          breakable: breakable,
          fill: if memo { white } else { style.accent.lighten(88%) },
          stroke: if memo { 1.5pt + style.accent.darken(15%) } else { none },
          radius: if title != none { (top-left: 0pt, rest: 7pt) } else { 7pt },
          inset: 11pt,
          body,
        )
      })
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(1.6em, weight: 700, fill: sheet-accent, it.body))
      show heading.where(level: 2): it => block(above: 1.7em, below: 0.9em, sticky: true, stack(
        spacing: 0.4em,
        text(1.45em, weight: 700, fill: sheet-accent, it.body),
        box(width: 2.5em, height: 3pt, fill: sheet-accent, radius: 1.5pt),
      ))
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(1.05em, weight: 700, fill: sheet-accent, it.body))
      set table(stroke: 0.6pt + sheet-accent.lighten(55%))
      set list(marker: text(fill: sheet-accent, sym.bullet))
      body
    },
  )
}

// ─── skizze ──────────────────────────────────────────────────────────────────
// Verspielt für die Unterstufe: Handschrift-Überschriften, Titel auf
// Klebeband, Kürzel als schräger Zettel, gestrichelte Kästen, Namensfeld.

#let skizze(accent: auto, class: none) = {
  let sheet-accent = if accent == auto { class-accent(class) } else { accent }
  let display-font = "Playpen Sans"
  let ink = luma(35)
  let note-yellow = rgb("#ffe27a")
  let tape(width, height, fill) = {
    // Klebeband mit gezackten Enden
    let z = 6
    let dy = height / z
    let left-points = range(z + 1).map(i => (if calc.even(i) { 0pt } else { 3pt }, i * dy))
    let right-points = range(z + 1).rev().map(i => (width - (if calc.even(i) { 0pt } else { 3pt }), i * dy))
    polygon(fill: fill, ..left-points, ..right-points)
  }
  // Nummer als handgezeichnet wirkender Klecks
  let blot(size: 1em, body) = text(size, box(width: 2em, height: 2em, rotate(-6deg, box(
    width: 100%,
    height: 100%,
    fill: sheet-accent,
    radius: (top-left: 55%, top-right: 45%, bottom-right: 60%, bottom-left: 40%),
    align(center + horizon, rotate(6deg, text(font: display-font, 0.85em, weight: 700, fill: white, body))),
  ))))
  (
    name: "skizze",
    font: "SF Pro Rounded",
    math-font: "Fira Math",
    font-size: 11pt,
    title-font-size: 21pt,
    margin: (bottom: 1.8cm),
    header-top: 1.1cm,
    header-ascent: 0.7cm,
    header: (title: none, class: none, copyright-url: none, font-size: auto) => {
      let font-size = if font-size == auto { 21pt } else { font-size }
      set par(justify: false)
      let title = text(font: display-font, font-size, weight: 700, fill: ink, title)
      grid(
        columns: (1fr, auto),
        column-gutter: 1.2em,
        align: (left + bottom, right + bottom),
        stack(
          spacing: 0.55em,
          // Fachzeile links, Namensfeld rechts – nur auf der ersten Seite
          // Namensfeld füllt die Zeile bis zur Spalte des Kürzel-Zettels
          grid(
            columns: (auto, 1fr),
            column-gutter: 2.5em,
            text(font: display-font, 8.5pt, weight: 500, fill: sheet-accent, if subject-line(class) != none { subject-line(class) }),
            context if counter(page).get().first() == 1 {
              text(font: display-font, 9pt, fill: luma(90))[Name: #box(width: 1fr, line(length: 100%, stroke: (paint: luma(120), thickness: 0.8pt, dash: "dotted")))]
            },
          ),
          layout(available => {
            let m = measure(title)
            let b = calc.min((m.width + 1.2em).to-absolute(), available.width)
            box(rotate(-1deg, reflow: true, box({
              place(top + left, dx: -0.6em, dy: 0.25em, tape(b, m.height + 0.25em, sheet-accent.lighten(82%)))
              title
            })))
          }),
        ),
        with-copyright(copyright-url, rotate(3deg, reflow: true, box(
          fill: sheet-accent,
          inset: (x: 0.8em, top: 0.7em, bottom: 0.6em),
          text(font: display-font, 12pt, weight: 700, fill: white, class),
        ))),
      )
    },
    footer: (duplex: true) => outside-aligned(duplex: duplex, n => blot(str(n), size: 9pt)),
    task-marker: task-number => move(dy: -0.9em, blot(str(task-number), size: 1.25em)),
    task-marker-width: 3.15em,
    task: (marker: none, title: none, icons: (), points: none, large: true) => {
      set par(justify: false)
      let head-size = if large { 1.25em } else { 1.1em }
      block(width: 100%, grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.6em,
        align: horizon,
        if marker != none { blot(marker, size: head-size) },
        text(font: display-font, head-size, weight: 600, fill: ink, {
          if icons.len() > 0 { text(fill: sheet-accent, icons.join(h(0.3em))); h(0.4em) }
          title
        }),
        if points != none { text(font: display-font, 0.9em, fill: luma(110), points) },
      ))
    },
    subtask: marker => text(font: display-font, weight: 700, fill: sheet-accent.darken(10%), marker),
    solution: (title: none, body) => block(
      width: 100%,
      breakable: true,
      fill: palette.green.lighten(92%),
      stroke: (paint: palette.green, thickness: 1.2pt, dash: "dashed"),
      radius: 10pt,
      inset: (x: 11pt, y: 9pt),
      solution-inline(title: title, body, marker-style: t => text(font: display-font, weight: 700, fill: palette.green.darken(20%), [#fa-icon("check", solid: true)#h(0.35em)#t])),
    ),
    solution-heading: title => block(above: 1.8em, below: 1em, text(font: display-font, 1.35em, weight: 700, fill: palette.green.darken(15%), title)),
    material-heading: title => block(above: 1.6em, below: 0.9em, text(font: display-font, 1.2em, weight: 700, fill: sheet-accent, title)),
    callout: (kind: "info", title: none, accent: auto, breakable: false, width: auto, body) => {
      let style = callout-style(kind, worksheet-accent: sheet-accent, accent: accent)
      let heading = if title != none {
        block(below: 0.6em, sticky: true, text(font: display-font, 0.95em, weight: 700, fill: style.accent.darken(15%), {
          fa-icon(style.icon-name, solid: true)
          h(0.4em)
          title
        }))
      }
      let memo = kind == "memo"
      // Merke als gelber Zettel; Warnungen mit durchgezogenem Rand
      let frame-stroke = if memo { 1pt + note-yellow.darken(30%) } else if kind in ("warning", "danger", "error") {
        1.4pt + style.accent
      } else { (paint: style.accent.lighten(15%), thickness: 1.2pt, dash: "dashed") }
      block(
        width: if width == auto { 100% } else { width },
        breakable: breakable,
        fill: if memo { note-yellow.lighten(50%) } else { style.accent.lighten(93%) },
        stroke: frame-stroke,
        radius: if memo { 2pt } else { 10pt },
        inset: (x: 13pt, y: 11pt),
        above: 1.2em,
        below: 1.2em,
        { heading; body },
      )
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(font: display-font, 1.5em, weight: 700, fill: ink, it.body))
      show heading.where(level: 2): it => block(above: 1.7em, below: 0.9em, sticky: true, text(font: display-font, 1.35em, weight: 700, fill: sheet-accent.darken(10%), highlight(
        fill: sheet-accent.lighten(82%),
        top-edge: "x-height",
        bottom-edge: -0.15em,
        extent: 0.15em,
        it.body,
      )))
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(font: display-font, 1.05em, weight: 700, fill: sheet-accent, it.body))
      set table(stroke: 0.6pt + sheet-accent.lighten(45%))
      set list(marker: text(fill: sheet-accent, sym.star.filled))
      body
    },
  )
}

// ─── labor ───────────────────────────────────────────────────────────────────
// Technisch für MINT und Informatik: umrandete Titelleiste mit Messskala,
// Monospace-Marken („A1“), Kästen wie Datenblätter.

#let labor(accent: auto, class: none) = {
  let sheet-accent = if accent == auto { class-accent(class) } else { accent }
  let display-font = "Fira Code"
  let night = rgb("#1c2230")
  let ink = luma(25)
  let tag(fill: sheet-accent, size: 0.8em, body) = badge(body, fill: fill, size: size, font: display-font, weight: 600, inset: (x: 0.45em, y: 0.38em))
  (
    name: "labor",
    font: "Fira Sans",
    math-font: "Fira Math",
    font-size: 10.5pt,
    title-font-size: 18pt,
    margin: (bottom: 1.8cm),
    header-top: 1.1cm,
    header-ascent: 0.7cm,
    header: (title: none, class: none, copyright-url: none, font-size: auto) => {
      let font-size = if font-size == auto { 18pt } else { font-size }
      set par(justify: false)
      block(width: 100%, stroke: 0.9pt + night, radius: 3pt, inset: (x: 12pt, y: 10pt), grid(
        columns: (1fr, auto),
        column-gutter: 1em,
        align: (left + horizon, right + horizon),
        stack(
          spacing: 0.55em,
          if subject-line(class) != none { text(font: display-font, 7.5pt, weight: 500, tracking: 0.04em, fill: sheet-accent, upper(subject-line(class).replace(" · ", " / "))) },
          text(font-size, weight: 600, fill: ink, title),
        ),
        with-copyright(copyright-url, tag(class, size: 10pt)),
      ))
      v(-0.4em)
      // Messskala unter der Leiste, auf die Satzbreite beschnitten
      layout(available => box(width: 100%, height: 4pt, {
        for i in range(0, int(available.width / 3mm) + 1) {
          place(left + top, dx: i * 3mm, line(
            start: (0pt, 0pt),
            end: (0pt, if calc.rem(i, 5) == 0 { 4pt } else { 2pt }),
            stroke: 0.4pt + luma(160),
          ))
        }
      }))
    },
    footer: (duplex: true) => outside-aligned(duplex: duplex, n => context tag([#n/#counter(page).final().first()], size: 8pt)),
    task-marker: task-number => move(dy: -0.36em, tag([A#task-number], size: 0.98em)),
    task-marker-width: 2.9em,
    task: (marker: none, title: none, icons: (), points: none, large: true) => {
      set par(justify: false)
      let head-size = if large { 1.15em } else { 1.05em }
      block(width: 100%, grid(
        columns: (auto, auto, 1fr, auto),
        column-gutter: 0.6em,
        align: horizon,
        if marker != none { tag([A#marker], size: head-size * 0.85) },
        text(head-size, weight: 600, fill: ink, {
          if icons.len() > 0 { text(fill: sheet-accent, icons.join(h(0.3em))); h(0.4em) }
          title
        }),
        line(length: 100%, stroke: (paint: luma(185), thickness: 0.6pt, dash: "dotted")),
        if points != none { text(font: display-font, 0.8em, fill: sheet-accent, points) },
      ))
    },
    subtask: marker => text(font: display-font, 0.92em, weight: 600, fill: sheet-accent, tracking: -0.08em, marker),
    solution: (title: none, body) => block(
      width: 100%,
      breakable: true,
      stroke: (left: 2pt + palette.green, rest: 0.5pt + palette.green.lighten(40%)),
      fill: palette.green.lighten(95%),
      radius: 2pt,
      inset: (left: 10pt, rest: 8pt),
      solution-inline(title: title, body, marker-style: t => text(font: display-font, 0.85em, weight: 600, fill: palette.green.darken(25%), [▸ #t])),
    ),
    solution-heading: title => block(above: 1.8em, below: 1em, width: 100%, {
      text(font: display-font, 1.1em, weight: 600, fill: palette.green.darken(10%), "// ")
      text(1.2em, weight: 600, fill: ink, title)
    }),
    material-heading: title => block(above: 1.6em, below: 0.9em, text(1.1em, weight: 600, fill: sheet-accent, title)),
    callout: (kind: "info", title: none, accent: auto, breakable: false, width: auto, body) => {
      let style = callout-style(kind, worksheet-accent: sheet-accent, accent: accent)
      let memo = kind == "memo"
      block(
        width: if width == auto { 100% } else { width },
        breakable: breakable,
        above: 1.2em,
        below: 1.2em,
        stroke: if memo { 1.4pt + style.accent } else { 0.7pt + style.accent.lighten(25%) },
        radius: 2pt,
        fill: if memo { style.accent.lighten(93%) } else { white },
        inset: (x: 11pt, y: 10pt),
        {
          if title != none {
            block(below: 0.6em, sticky: true, {
              tag(upper(title), fill: style.accent, size: 0.75em)
            })
          }
          body
        },
      )
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(1.4em, weight: 600, fill: ink, it.body))
      show heading.where(level: 2): it => block(above: 1.7em, below: 0.9em, sticky: true, {
        text(font: display-font, 1.15em, weight: 600, fill: sheet-accent, "// ")
        text(1.3em, weight: 600, fill: ink, it.body)
      })
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(1em, weight: 600, fill: sheet-accent, it.body))
      set table(stroke: 0.5pt + luma(170))
      set list(marker: text(font: display-font, fill: sheet-accent, [›]))
      show raw: set text(font: display-font)
      body
    },
  )
}

// ─── kontur ──────────────────────────────────────────────────────────────────
// Plakativ: dicke schwarze Rahmen, harte versetzte Schatten in der
// Fachfarbe, fette Futura in Versalien. Wirkt auch als Schwarz-Weiß-Kopie.

#let kontur(accent: auto, class: none) = {
  let sheet-accent = if accent == auto { class-accent(class) } else { accent }
  let display-font = "Futura"
  let ink = luma(15)
  let frame-stroke = 1.4pt + ink
  // Versalien mit echtem ẞ („GRÖẞEN“ statt „GRÖSSEN“)
  // (upper() wandelt vor jeder Show-Regel um, darum über den Klartext)
  let uppercase(body) = {
    let plain = plain-text(body)
    if plain != none and plain != "" { upper(plain.replace("ß", "ẞ")) } else { upper(body) }
  }
  let tile(size: 1em, body) = shadow-box(
    badge(body, fill: sheet-accent, size: size, radius: 0pt, font: display-font, stroke: frame-stroke, width: 1.75em * 1, inset: (x: 0.3em, y: 0.42em)),
    fill: ink,
  )
  (
    name: "kontur",
    font: "Helvetica Neue",
    math-font: "Fira Math",
    font-size: 10.5pt,
    title-font-size: 26pt,
    margin: (bottom: 1.8cm),
    header-top: 1.25cm,
    header-ascent: 0.8cm,
    header: (title: none, class: none, copyright-url: none, font-size: auto) => {
      let font-size = if font-size == auto { 26pt } else { font-size }
      set par(justify: false, leading: 0.35em)
      grid(
        columns: (1fr, auto),
        column-gutter: 1em,
        align: (left + bottom, right + bottom),
        stack(
          spacing: 0.7em,
          if subject-line(class) != none {
            box(fill: ink, inset: (x: 0.5em, y: 0.4em), text(7.5pt, weight: 700, tracking: 0.12em, fill: white, top-edge: "cap-height", bottom-edge: "baseline", upper(subject-line(class))))
          },
          text(font: display-font, font-size, weight: 700, fill: ink, uppercase(title)),
        ),
        with-copyright(copyright-url, fill: ink, shadow-box(
          badge(class, fill: sheet-accent, size: 11pt, radius: 0pt, font: display-font, stroke: frame-stroke, inset: (x: 0.6em, y: 0.5em)),
          fill: ink,
          distance: 3pt,
        )),
      )
      v(0.55em)
      line(length: 100%, stroke: 3pt + ink)
    },
    footer: (duplex: true) => outside-aligned(duplex: duplex, n => tile(str(n), size: 9pt)),
    task-marker: task-number => move(dy: -0.66em, tile(str(task-number), size: 1.15em)),
    task-marker-width: 2.75em,
    task: (marker: none, title: none, icons: (), points: none, large: true) => {
      set par(justify: false)
      let head-size = if large { 1.15em } else { 1.05em }
      block(width: 100%, grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.65em,
        align: horizon,
        if marker != none { tile(marker, size: head-size) },
        text(font: display-font, head-size, weight: 700, fill: ink, tracking: 0.02em, {
          if icons.len() > 0 { icons.join(h(0.3em)); h(0.4em) }
          if title != none { uppercase(title) }
        }),
        if points != none { box(stroke: frame-stroke, inset: (x: 0.5em, y: 0.3em), text(0.85em, weight: 700, points)) },
      ))
    },
    subtask: marker => text(weight: 700, fill: sheet-accent.darken(10%), marker),
    // Lösung: der Schatten als dicke Kante rechts/unten – bleibt umbrechbar
    // und schließt bündig mit den Kästen (Rahmen + Schatten) ab.
    solution: (title: none, body) => block(
      width: 100%,
      breakable: true,
      fill: palette.green.lighten(88%),
      stroke: { let g = palette.green.darken(25%); (left: 1.4pt + g, top: 1.4pt + g, right: 4pt + g, bottom: 4pt + g) },
      inset: (left: 10pt, right: 12pt, top: 8pt, bottom: 10pt),
      solution-inline(title: title, body, marker-style: t => text(weight: 700, fill: palette.green.darken(30%), t)),
    ),
    solution-heading: title => block(above: 1.8em, below: 1em, text(font: display-font, 1.3em, weight: 700, fill: ink, upper(title))),
    material-heading: title => block(above: 1.6em, below: 0.9em, text(font: display-font, 1.15em, weight: 700, upper(title))),
    callout: (kind: "info", title: none, accent: auto, breakable: false, width: auto, body) => {
      let style = callout-style(kind, worksheet-accent: sheet-accent, accent: accent)
      let memo = kind == "memo"
      let inner = block(
        width: 100%,
        breakable: breakable,
        fill: if memo { sheet-accent.lighten(88%) } else { white },
        stroke: frame-stroke,
        inset: (x: 12pt, y: 10pt),
        {
          if title != none {
            block(below: 0.65em, sticky: true, box(fill: style.accent, stroke: frame-stroke, inset: (x: 0.5em, y: 0.38em), text(
              font: display-font,
              0.82em,
              weight: 700,
              tracking: 0.06em,
              fill: white,
              top-edge: "cap-height",
              bottom-edge: "baseline",
              [#fa-icon(style.icon-name, solid: true)#h(0.4em)#upper(title)],
            )))
          }
          body
        },
      )
      let width = if width == auto { 100% } else { width }
      block(width: width, above: 1.3em, below: 1.4em, if breakable { inner } else {
        shadow-block(inner, fill: if memo { ink } else { style.accent })
      })
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(font: display-font, 1.6em, weight: 700, fill: ink, uppercase(it.body)))
      show heading.where(level: 2): it => block(above: 1.7em, below: 0.9em, sticky: true, text(font: display-font, 1.4em, weight: 700, fill: ink, tracking: 0.02em, highlight(
        fill: sheet-accent.lighten(65%),
        top-edge: "x-height",
        bottom-edge: -0.12em,
        extent: 0.18em,
        uppercase(it.body),
      )))
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(font: display-font, 1.05em, weight: 700, uppercase(it.body)))
      set table(stroke: 0.9pt + ink)
      set list(marker: text(fill: ink, sym.square.filled.small))
      body
    },
  )
}

// ─── leiste ──────────────────────────────────────────────────────────────────
// Kennung am Rand: eine Leiste in der Fachfarbe an der Außenkante trägt
// Kürzel, Fach und Seitenzahl. Der Inhalt bleibt luftig, Nummern sind round-badge.

#let leiste(accent: auto, class: none) = {
  let sheet-accent = if accent == auto { class-accent(class) } else { accent }
  let display-font = "Montserrat"
  let ink = luma(30)
  let band-width = 0.75cm
  let round-badge(size: 1em, body) = text(size, box(width: 1.85em, height: 1.85em, fill: sheet-accent, radius: 50%, align(center + horizon, text(
    font: display-font,
    0.95em,
    weight: 700,
    fill: white,
    body,
  ))))
  (
    name: "leiste",
    font: "Lato",
    math-font: "Lato Math",
    font-size: 10.5pt,
    title-font-size: 22pt,
    // aussen 2,75 cm: Satzspiegel 21 − 2,25 − 2,75 = 16,0 cm, ein Vielfaches von
    // 5 mm – Kästchenfelder schließen bündig ab.
    margin: (bottom: 1.4cm, outside: 2.75cm),
    header-top: 1.3cm,
    header-ascent: 0.8cm,
    background: (print: true, margin: (:), header-top: 3cm) => context {
      let n = here().page()
      // Außenkante: bei beidseitigem Druck auf geraden Seiten links
      let on-left = type(margin) == dictionary and "inside" in margin and calc.even(n)
      // Relativ platzieren: page.width ignoriert `flipped` (Querformat)
      // Helle Leiste (wenig Toner), Kürzel und Seitenzahl als gefüllte Marken
      place(if on-left { top + left } else { top + right }, dx: if on-left { 0.85cm } else { -0.85cm }, dy: 1cm, block(width: band-width, height: 100% - 2cm, fill: sheet-accent.lighten(78%), radius: 2pt, {
        place(top + center, dy: 0.3cm, box(fill: sheet-accent, radius: 1.5pt, inset: (x: 0.28em, y: 0.45em), rotate(
          -90deg,
          reflow: true,
          text(font: display-font, 8.5pt, weight: 700, fill: white, top-edge: "cap-height", bottom-edge: "baseline", class),
        )))
        if print {
          place(bottom + center, dy: -0.3cm, box(width: 1.75em, height: 1.75em, fill: sheet-accent, radius: 50%, align(center + horizon, text(
            font: display-font,
            8.5pt,
            weight: 700,
            fill: white,
            str(n),
          ))))
        }
      }))
    },
    header: (title: none, class: none, copyright-url: none, font-size: auto) => {
      let font-size = if font-size == auto { 22pt } else { font-size }
      set par(justify: false, leading: 0.45em)
      let lines = stack(
        spacing: 0.6em,
        if subject-line(class) != none { text(font: display-font, 7.5pt, weight: 700, tracking: 0.16em, fill: sheet-accent, upper(subject-line(class))) },
        text(font: display-font, font-size, weight: 700, fill: ink, bottom-edge: "descender", title),
        box(width: 2.6cm, height: 3pt, fill: sheet-accent, radius: 1.5pt),
      )
      // Das Kürzel steht in der Randleiste; der QR-Code sitzt rechts oben.
      if copyright-url == none { lines } else {
        grid(columns: (1fr, auto), column-gutter: 1em, align: (left + bottom, right + top), lines, copyright-code(copyright-url, size: 1.5em, fill: luma(110)))
      }
    },
    task-marker: task-number => move(dy: -0.74em, round-badge(str(task-number), size: 1.15em)),
    task-marker-width: 2.75em,
    task: (marker: none, title: none, icons: (), points: none, large: true) => {
      set par(justify: false)
      let head-size = if large { 1.15em } else { 1.05em }
      block(width: 100%, grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.6em,
        align: horizon,
        if marker != none { round-badge(marker, size: head-size) },
        text(font: display-font, head-size, weight: 700, fill: ink, {
          if icons.len() > 0 { text(fill: sheet-accent, icons.join(h(0.3em))); h(0.4em) }
          title
        }),
        if points != none { text(font: display-font, 0.8em, weight: 700, fill: sheet-accent, points) },
      ))
    },
    subtask: marker => text(font: display-font, 0.9em, weight: 700, fill: sheet-accent, marker),
    solution: (title: none, body) => block(
      width: 100%,
      breakable: true,
      fill: palette.green.lighten(92%),
      stroke: (top: 2.5pt + palette.green),
      inset: (x: 10pt, y: 8pt),
      solution-inline(title: title, body, marker-style: t => text(font: display-font, 0.9em, weight: 700, fill: palette.green.darken(20%), t)),
    ),
    solution-heading: title => block(above: 1.8em, below: 1em, text(font: display-font, 1.3em, weight: 700, fill: palette.green.darken(15%), title)),
    material-heading: title => block(above: 1.6em, below: 0.9em, text(font: display-font, 1.1em, weight: 700, fill: sheet-accent, title)),
    callout: (kind: "info", title: none, accent: auto, breakable: false, width: auto, body) => {
      let style = callout-style(kind, worksheet-accent: sheet-accent, accent: accent)
      let memo = kind == "memo"
      block(
        width: if width == auto { 100% } else { width },
        breakable: breakable,
        fill: style.accent.lighten(if memo { 86% } else { 93% }),
        stroke: (top: (if memo { 5pt } else { 3pt }) + style.accent),
        inset: (x: 12pt, top: 10pt, bottom: 11pt),
        above: 1.3em,
        below: 1.3em,
        {
          if title != none {
            block(below: 0.6em, sticky: true, text(font: display-font, 0.75em, weight: 700, tracking: 0.1em, fill: style.accent.darken(15%), [#fa-icon(style.icon-name, solid: true)#h(0.5em)#upper(title)]))
          }
          body
        },
      )
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(font: display-font, 1.5em, weight: 700, fill: ink, it.body))
      show heading.where(level: 2): it => block(above: 1.8em, below: 0.9em, sticky: true, {
        box(width: 0.55em, height: 0.55em, fill: sheet-accent, radius: 50%)
        h(0.5em)
        text(font: display-font, 1.3em, weight: 700, fill: ink, it.body)
      })
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(font: display-font, 1em, weight: 700, fill: sheet-accent, it.body))
      set table(stroke: (x, y) => (bottom: 0.5pt + luma(180), top: if y == 0 { 1.2pt + sheet-accent } else { 0.5pt + luma(180) }))
      set list(marker: text(fill: sheet-accent, sym.circle.filled.small))
      body
    },
  )
}

// ─── riso ────────────────────────────────────────────────────────────────────
// Wie im Zweifarbdruck (Risograph): Fachfarbe plus Pink, leicht versetzter
// Titel, Rasterpunkte, kräftige Slab-Schrift.

#let riso(accent: auto, class: none) = {
  let sheet-accent = if accent == auto { class-accent(class) } else { accent }
  let display-font = "Rockwell"
  let pink = rgb("#ff4f9a")
  let ink = luma(25)
  let halftone(fill, spacing: 2.2mm, radius: 0.42mm) = tiling(size: (spacing, spacing), place(dx: spacing / 2 - radius, dy: spacing / 2 - radius, circle(radius: radius, fill: fill)))
  // Zwei „Druckfarben“ übereinander, die zweite leicht verrutscht
  let doubled(offset: (dx: 1.6pt, dy: 1.3pt), draw) = box({
    place(top + left, dx: offset.dx, dy: offset.dy, draw(pink.transparentize(45%)))
    draw(sheet-accent.darken(8%))
  })
  // Marke mit Rasterschatten in Pink (in S/W ein gepunkteter Schatten,
  // kein Doppelbild)
  let rounded-badge(size: 1em, body) = text(size, box(width: 1.75em + 4.5pt, height: 1.75em + 4.5pt, {
    place(top + left, dx: 4.5pt, dy: 4.5pt, rect(width: 1.75em, height: 1.75em, radius: 0.3em, fill: halftone(pink, spacing: 1.1mm, radius: 0.33mm)))
    place(top + left, box(width: 1.75em, height: 1.75em, fill: sheet-accent, radius: 0.3em, align(center + horizon, text(
      font: display-font,
      0.9em,
      weight: 700,
      fill: white,
      body,
    ))))
  }))
  (
    name: "riso",
    font: "PT Sans",
    math-font: "Fira Math",
    font-size: 11pt,
    title-font-size: 27pt,
    margin: (bottom: 1.8cm),
    header-top: 1.2cm,
    header-ascent: 0.75cm,
    header: (title: none, class: none, copyright-url: none, font-size: auto) => {
      let font-size = if font-size == auto { 27pt } else { font-size }
      set par(justify: false, leading: 0.4em)
      grid(
        columns: (1fr, auto),
        column-gutter: 1em,
        align: (left + bottom, right + bottom),
        stack(
          spacing: 0.6em,
          if subject-line(class) != none { text(8pt, weight: 700, tracking: 0.14em, fill: pink.darken(25%), upper(subject-line(class))) },
          doubled(c => text(font: display-font, font-size, weight: 700, fill: c, title)),
        ),
        with-copyright(copyright-url, box({
          place(top + left, dx: 4.5pt, dy: 4.5pt, badge(class, fill: halftone(pink, spacing: 1.1mm, radius: 0.33mm), text-fill: rgb(0, 0, 0, 0), size: 11pt, radius: 0.3em, font: display-font, inset: (x: 0.6em, y: 0.5em)))
          badge(class, fill: sheet-accent, size: 11pt, radius: 0.3em, font: display-font, inset: (x: 0.6em, y: 0.5em))
        })),
      )
      v(0.4em)
      rect(width: 100%, height: 3.5mm, fill: halftone(pink.transparentize(30%)), stroke: none)
    },
    footer: (duplex: true) => outside-aligned(duplex: duplex, n => rounded-badge(str(n), size: 9pt)),
    task-marker: task-number => move(dy: -0.66em, rounded-badge(str(task-number), size: 1.15em)),
    task-marker-width: 2.95em,
    task: (marker: none, title: none, icons: (), points: none, large: true) => {
      set par(justify: false)
      let head-size = if large { 1.2em } else { 1.08em }
      block(width: 100%, grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.6em,
        align: horizon,
        if marker != none { rounded-badge(marker, size: head-size) },
        text(font: display-font, head-size, weight: 700, fill: ink, {
          if icons.len() > 0 { text(fill: sheet-accent, icons.join(h(0.3em))); h(0.4em) }
          title
        }),
        if points != none { text(font: display-font, 0.85em, weight: 700, fill: pink.darken(25%), points) },
      ))
    },
    subtask: marker => text(font: display-font, weight: 700, fill: sheet-accent.darken(8%), marker),
    solution: (title: none, body) => block(
      width: 100%,
      breakable: true,
      fill: palette.green.lighten(88%),
      inset: (x: 10pt, y: 8pt),
      solution-inline(title: title, body, marker-style: t => text(font: display-font, weight: 700, fill: palette.green.darken(25%), t)),
    ),
    solution-heading: title => block(above: 1.8em, below: 1em, text(font: display-font, 1.4em, weight: 700, fill: palette.green.darken(20%), title)),
    material-heading: title => block(above: 1.6em, below: 0.9em, text(font: display-font, 1.15em, weight: 700, fill: sheet-accent, title)),
    callout: (kind: "info", title: none, accent: auto, breakable: false, width: auto, body) => {
      let style = callout-style(kind, worksheet-accent: sheet-accent, accent: accent)
      let memo = kind == "memo"
      let tone = if memo { pink } else { style.accent }
      let thickness = if memo { 1.8pt } else { 1.2pt }
      block(
        width: if width == auto { 100% } else { width },
        breakable: breakable,
        stroke: thickness + style.accent,
        // Innenabstand = Rahmenbreite: die Flächen innen überdecken den Rahmen nicht
        inset: thickness,
        above: 1.3em,
        below: 1.3em,
        {
          set block(spacing: 0pt)
          if title != none {
            block(width: 100%, sticky: true, fill: halftone(tone.transparentize(if memo { 45% } else { 55% })), inset: (x: 8pt, y: 5pt), box(
              fill: white,
              inset: (x: 4pt, y: 3pt),
              text(font: display-font, 0.95em, weight: 700, fill: style.accent.darken(15%), [#fa-icon(style.icon-name, solid: true)#h(0.45em)#title]),
            ))
          }
          block(width: 100%, breakable: breakable, fill: style.accent.lighten(94%), inset: 10pt, {
            set block(spacing: 1.2em)
            body
          })
        },
      )
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(font: display-font, 1.6em, weight: 700, fill: ink, it.body))
      show heading.where(level: 2): it => block(above: 1.8em, below: 0.9em, sticky: true, text(font: display-font, 1.45em, weight: 700, fill: ink, highlight(
        fill: pink.lighten(55%),
        top-edge: "x-height",
        bottom-edge: -0.12em,
        extent: 0.15em,
        it.body,
      )))
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(font: display-font, 1.05em, weight: 700, fill: sheet-accent, it.body))
      set table(stroke: 0.7pt + sheet-accent.lighten(20%))
      set list(marker: text(fill: sheet-accent, sym.square.filled.small))
      body
    },
  )
}

// ─── bauhaus ─────────────────────────────────────────────────────────────────
// Geometrisch: Kreis, Quadrat und Dreieck als Signet und Aufgabennummern,
// Viertelkreise in den Kastenecken, Gill Sans.

#let bauhaus(accent: auto, class: none) = {
  let sheet-accent = if accent == auto { class-accent(class) } else { accent }
  let display-font = "Gill Sans"
  let ink = luma(25)
  let frame-gray = luma(70)
  // Nummernform wechselt: 1 Kreis, 2 Quadrat, 3 Dreieck, 4 Kreis …
  let shape(task-number, size: 1em, body) = text(size, box(width: 1.9em, height: 1.9em, {
    let k = calc.rem(task-number - 1, 3)
    if k == 0 { place(circle(radius: 0.95em, fill: sheet-accent)) }
    else if k == 1 { place(dx: 0.1em, dy: 0.1em, rect(width: 1.7em, height: 1.7em, fill: sheet-accent)) }
    // Das Dreieck ragt etwas über das Feld hinaus, damit die Ziffer so groß
    // wie in Kreis und Quadrat sein kann; sie sitzt tiefer (Schwerpunkt)
    else { place(polygon(fill: sheet-accent, (0.95em, -0.35em), (2.25em, 1.95em), (-0.35em, 1.95em))) }
    // Ziffern in Futura: die Gill-Sans-„1“ ist von einem „I“ kaum zu unterscheiden
    place(center + horizon, dy: if k == 2 { 0.38em } else { 0em }, text(font: "Futura", 0.9em, weight: 700, fill: white, body))
  }))
  let quarter(fill, radius: 0.9cm) = box(width: radius, height: radius, clip: true, place(dx: -radius, dy: -radius, circle(radius: radius, fill: fill)))
  (
    name: "bauhaus",
    font: "Gill Sans",
    math-font: "Fira Math",
    font-size: 11.5pt,
    title-font-size: 25pt,
    margin: (bottom: 1.8cm),
    header-top: 1.2cm,
    header-ascent: 0.8cm,
    header: (title: none, class: none, copyright-url: none, font-size: auto) => {
      let font-size = if font-size == auto { 25pt } else { font-size }
      set par(justify: false, leading: 0.4em)
      grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.9em,
        align: (left + bottom, left + bottom, right + bottom),
        // Signet: Kreis, Quadrat, Dreieck
        box(width: 1.5cm, height: 1.5cm, {
          place(top + left, circle(radius: 0.48cm, fill: sheet-accent))
          place(bottom + left, dx: 0.1cm, rect(width: 0.6cm, height: 0.6cm, fill: frame-gray))
          place(bottom + right, polygon(fill: sheet-accent.lighten(45%), (0.35cm, 0cm), (0.7cm, 0.62cm), (0cm, 0.62cm)))
        }),
        stack(
          spacing: 0.55em,
          if subject-line(class) != none { text(font: display-font, 8.5pt, weight: 600, tracking: 0.16em, fill: sheet-accent, upper(subject-line(class))) },
          text(font: display-font, font-size, weight: 700, fill: ink, title),
        ),
        with-copyright(copyright-url, badge(class, fill: sheet-accent, size: 11pt, radius: 0pt, font: display-font, inset: (x: 0.6em, y: 0.5em))),
      )
      v(0.55em)
      grid(columns: (35%, 1fr), line(length: 100%, stroke: 4pt + sheet-accent), line(length: 100%, stroke: 1pt + frame-gray))
    },
    footer: (duplex: true) => outside-aligned(duplex: duplex, n => shape(1, str(n), size: 8.5pt)),
    task-marker: task-number => move(dy: -0.72em, shape(task-number, str(task-number), size: 1.1em)),
    task-marker-width: 2.75em,
    task: (marker: none, title: none, icons: (), points: none, large: true) => {
      set par(justify: false)
      let head-size = if large { 1.2em } else { 1.08em }
      block(width: 100%, grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.6em,
        align: horizon,
        // Die Form wechselt mit der Nummer; der Hook bekommt nur die fertige Marke.
        if marker != none { shape(aufgaben.internal.task-counter.get().first(), marker, size: head-size * 0.95) },
        text(font: display-font, head-size, weight: 700, fill: ink, {
          if icons.len() > 0 { text(fill: sheet-accent, icons.join(h(0.3em))); h(0.4em) }
          title
        }),
        if points != none { text(font: display-font, 0.9em, weight: 600, fill: sheet-accent, points) },
      ))
    },
    subtask: marker => text(font: display-font, weight: 700, fill: sheet-accent, marker),
    solution: (title: none, body) => block(
      width: 100%,
      breakable: true,
      fill: palette.green.lighten(90%),
      inset: (left: 0.8cm, rest: 8pt),
      {
        place(top + left, dx: -0.8cm, dy: -8pt, quarter(palette.green, radius: 0.5cm))
        solution-inline(title: title, body, marker-style: t => text(font: display-font, weight: 700, fill: palette.green.darken(25%), t))
      },
    ),
    solution-heading: title => block(above: 1.8em, below: 1em, text(font: display-font, 1.35em, weight: 700, fill: palette.green.darken(20%), title)),
    material-heading: title => block(above: 1.6em, below: 0.9em, text(font: display-font, 1.15em, weight: 700, fill: sheet-accent, title)),
    callout: (kind: "info", title: none, accent: auto, breakable: false, width: auto, body) => {
      let style = callout-style(kind, worksheet-accent: sheet-accent, accent: accent)
      let memo = kind == "memo"
      block(
        width: if width == auto { 100% } else { width },
        breakable: breakable,
        fill: style.accent.lighten(if memo { 88% } else { 94% }),
        stroke: if memo { (bottom: 3pt + style.accent) } else { none },
        inset: (left: 1.15cm, right: 12pt, y: 11pt),
        above: 1.3em,
        below: 1.3em,
        {
          // Viertelkreis in der Ecke, darin das Symbol
          place(top + left, dx: -1.15cm, dy: -11pt, {
            quarter(style.accent)
            place(top + left, dx: 0.17cm, dy: 0.15cm, text(9pt, fill: white, fa-icon(style.icon-name, solid: true)))
          })
          if title != none {
            block(below: 0.6em, sticky: true, text(font: display-font, 0.95em, weight: 700, fill: style.accent.darken(15%), upper(title)))
          }
          body
        },
      )
    },
    setup: body => {
      show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, text(font: display-font, 1.6em, weight: 700, fill: ink, it.body))
      show heading.where(level: 2): it => block(above: 1.8em, below: 0.9em, sticky: true, {
        // Balken: kommt im Nummernwechsel (Kreis, Quadrat, Dreieck) nicht vor
        box(width: 1.1em, height: 0.32em, fill: sheet-accent, baseline: -0.12em)
        h(0.5em)
        text(font: display-font, 1.4em, weight: 700, fill: ink, it.body)
      })
      show heading.where(level: 3): it => block(above: 1.2em, below: 0.6em, text(font: display-font, 1.05em, weight: 700, fill: sheet-accent, it.body))
      set table(stroke: 0.6pt + frame-gray)
      set list(marker: text(fill: sheet-accent, sym.square.filled.small))
      // Gill Sans hat eine kleine x-Höhe; Fira Math in 90 % passt dazu
      show math.equation.where(block: false): set text(size: 0.9em)
      body
    },
  )
}

// ─── Verzeichnis ─────────────────────────────────────────────────────────────

/// Die eingebauten Themes: Name → Theme-Funktion `(accent: auto, class: none) => dictionary`.
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
