// schuldocs — Vorlage für das gedruckte Handbuch
//
// Setzt den Körper der Dokumentation als PDF: Titelseite, Inhaltsverzeichnis,
// Kopf- und Fußzeile, Fließtext.

#import "config.typ": colors, fonts, pdf-mark, sizes

// Autorenliste als Text.
#let _join-authors(authors) = authors.map(a => str(a)).join(", ", last: " und ")

// Kopfzeile: links Paket und Version, rechts das laufende Kapitel.
#let _header(name, version) = context {
  let seiten = query(selector(heading.where(level: 1)).after(pdf-mark))
  let bisher = seiten.filter(h => h.location().page() <= here().page())
  let kapitel = if bisher.len() > 0 { bisher.last().body } else { none }

  set text(size: 8.5pt, fill: colors.muted, font: fonts.sans)
  block(width: 100%, {
    grid(
      columns: (1fr, auto),
      align: (left + bottom, right + bottom),
      [#name#if version != "" [ #sym.dot.c #version]],
      kapitel,
    )
    v(0.35em)
    line(length: 100%, stroke: 0.5pt + colors.rule)
  })
}

// Fußzeile: mittige Seitenzahl.
#let _footer() = context {
  set text(size: 9pt, fill: colors.muted, font: fonts.sans)
  align(center, counter(page).display("1"))
}

// Titelseite.
#let _title-page(name, version, authors, license, description, abstract, links) = page(
  header: none,
  footer: none,
  {
    v(4.2cm)
    block(width: 100%, {
      text(font: fonts.sans, size: 30pt, weight: 600, fill: colors.accent-deep, name)
      if version != "" {
        h(0.55em)
        text(font: fonts.sans, size: 13pt, fill: colors.muted, "Version " + version)
      }
    })
    v(0.7em)
    line(length: 100%, stroke: 0.9pt + colors.rule)
    v(1em)

    if description != "" and description != [] {
      block(width: 100%, text(size: 12.5pt, fill: colors.ink, description))
      v(0.8em)
    }
    if abstract != [] {
      block(width: 100%, abstract)
    }

    v(1fr)

    // Angaben zum Paket, links beschriftet.
    let zeile(label, wert) = (
      text(font: fonts.sans, size: 9pt, fill: colors.muted, upper(label)),
      text(size: 10pt, wert),
    )
    let zeilen = ()
    if authors.len() > 0 { zeilen += zeile("Autoren", _join-authors(authors)) }
    if license != "" { zeilen += zeile("Lizenz", license) }
    if links.len() > 0 {
      zeilen += zeile(
        "Verweise",
        links.map(l => link(l.at("url", default: ""), l.at("name", default: ""))).join(sym.space.en + sym.dot.c + sym.space.en),
      )
    }
    if zeilen.len() > 0 {
      line(length: 100%, stroke: 0.5pt + colors.rule)
      v(0.8em)
      grid(
        columns: (auto, 1fr),
        column-gutter: 1.4em,
        row-gutter: 0.7em,
        align: (left + top, left + top),
        ..zeilen,
      )
    }
  },
)

/// Setzt den Körper als Handbuch.
///
/// - name (string): Paketname
/// - version (string): Paketversion
/// - authors (array): Autoren
/// - license (string): Lizenz
/// - description (string): Kurzbeschreibung
/// - abstract (content): Fließtext für die Titelseite
/// - links (array): `(name: …, url: …)`
/// - body (content): Inhalt der Dokumentation
/// -> content
#let pdf-manual(
  name: "",
  version: "",
  authors: (),
  license: "",
  description: "",
  abstract: [],
  links: (),
  body,
) = {
  set page(
    paper: sizes.paper,
    margin: sizes.margin,
    header: _header(name, version),
    footer: _footer(),
  )
  set text(font: fonts.serif, size: sizes.text, fill: colors.ink, lang: "de")
  set par(justify: true, leading: sizes.leading, spacing: sizes.par-spacing)
  set list(indent: 0.6em, spacing: 0.7em)
  set enum(indent: 0.6em, spacing: 0.7em)
  set table(stroke: 0.5pt + colors.rule, inset: 0.55em)
  set terms(separator: [ — ], hanging-indent: 1.2em)

  // Nur äußere Verweise färben; Einträge im Inhaltsverzeichnis bleiben ruhig.
  show link: it => if type(it.dest) == str { text(fill: colors.accent, it) } else { it }

  // Überschriften: Grotesk, gezählt bis zur dritten Ebene.
  set heading(numbering: (..n) => if n.pos().len() <= 3 { numbering("1.1", ..n.pos()) })
  show heading: set text(font: fonts.sans, fill: colors.accent-deep, weight: 600)
  show heading: set block(below: 0.9em)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    block(above: 0em, below: 1.1em, {
      set text(size: 17pt)
      it
      v(0.3em)
      line(length: 100%, stroke: 0.6pt + colors.rule)
    })
  }
  show heading.where(level: 2): set text(size: 13pt, fill: colors.accent)
  show heading.where(level: 2): set block(above: 1.6em)
  show heading.where(level: 3): set text(size: 11.2pt)
  show heading.where(level: 3): set block(above: 1.3em)
  show heading.where(level: 4): set text(size: 10.5pt, fill: colors.ink)

  // Quelltext.
  show raw: set text(font: fonts.mono, size: sizes.code)
  show raw.where(block: true): it => block(
    width: 100%,
    fill: colors.surface,
    stroke: 0.5pt + colors.surface-edge,
    radius: 3pt,
    inset: (x: 0.8em, y: 0.7em),
    breakable: true,
    it,
  )
  show raw.where(block: false): it => box(
    fill: colors.surface,
    outset: (y: 0.25em),
    inset: (x: 0.25em),
    radius: 2pt,
    it,
  )

  show figure.caption: set text(size: 9.5pt, fill: colors.muted)

  _title-page(name, version, authors, license, description, abstract, links)

  counter(page).update(1)

  // Inhaltsverzeichnis — nur die Überschriften dieses Dokuments.
  {
    set heading(numbering: none, outlined: false)
    heading(level: 1)[Inhalt]
  }
  {
    show outline.entry.where(level: 1): set text(weight: 600)
    show outline.entry.where(level: 1): set block(above: 1.1em)
    outline(title: none, depth: 3, target: selector(heading).after(pdf-mark))
  }

  body
}
