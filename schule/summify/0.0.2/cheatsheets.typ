#import "@schule/arbeitsblatt:0.2.1": *

// Grundlegende Farbdefinitionen
#let theme-colors = (
  block: (
    background: black.lighten(30%),
    text: white,
  ),
)

#let str(height) = {(auto, height)}
#let _s_hide-content = state("hide", false)

// Hauptfunktion für die Übersicht
#let create-overview(
  title: "",
  paper: "a3",
  show-grid: false,
  font-size: 12pt,
  landscape: true,
  hide-content: false,
  page-settings: (margin: (top: 1cm + 6mm, bottom: 1cm - 6mm, left: 1cm, right: 1cm)),
  body,
) = {
  show: arbeitsblatt.with(
    title: title,
    paper: paper,
    print: true,
    landscape: landscape,
    font-size: font-size,
    custom-header: align(
      center + horizon,
      move(
        dy: 4mm,
        box(height: 12mm, inset: 3mm, text(20pt, weight: "bold", title)),
      ),
    ),
    page-settings: page-settings,
  )
  _s_hide-content.update(hide-content)


  body
}

#let cs-box(body) = box(inset: 2mm, width: 100%, context if _s_hide-content.get() { hide(body)} else {body})

// Erstellt einen Block mit Titel
#let create-topic-block(
  title,
  width: 100%,
  height: 100%,
  body,
) = {
  box(
    width: width,
    height: height - 6mm, // Platz für den Titel
    stroke: black + 1pt,
    inset: (top: 0.5pt, left: 0pt, right: 0pt, bottom: 0pt),
    radius: (bottom-right: 10pt, top-right: 10pt, bottom-left: 10pt),
  )[
    // Titel-Box mit altem Styling
    #place(
      top + left,
      dy: -6mm - 0.5pt,
      box(
        fill: theme-colors.block.background,
        height: 6mm,
        inset: (left: 2mm, right: 2mm, top: 0pt, bottom: 0pt),
        stroke: black,
        radius: (top-right: 5pt, top-left: 5pt),
        align(
          horizon,
          text(
            fill: theme-colors.block.text,
            weight: "bold",
            size: 12pt,
            title,
          ),
        ),
      ),
    )

    // Inhalt-Box mit altem Styling
    #box(
      height: 100%,
      width: 100%,
      radius: (bottom-right: 10pt, top-right: 10pt, bottom-left: 10pt),
      inset: (top: -0.5pt, bottom: 0pt, left: 0pt, right: 0pt),
      clip: true,
      body,
    )
  ]
}


#let cs-header(title) = box(
  width: 100%,
  fill: white.darken(15%),
  stroke: (x: 0pt, y: 1pt),
  height: 6.5mm,
  inset: 0mm,
  align(
    center + horizon,
    text(
      weight: "bold",
      size: 10pt,
      title,
    ),
  ),
)

// Erstellt ein Unterkapitel mit Titel
#let create-subtopic(
  title,
) = {
  if title != "" { cs-header(title) }
}

// Flexibler Stack (Basisfunktion)
#let cs-stack(
  direction: "vertical",
  cs-type: "topic",
  ratios: none,
  ..children,
) = {
  let (cols, rows) = if direction == "horizontal" {
    let cols = if ratios == none {
      children.pos().len() * (1fr,)
    } else {
      ratios
    }
    (cols, 1)
  } else {
    let rows = if ratios == none {
      children.pos().len() * (1fr,)
    } else {
      ratios
    }
    (1, rows)
  }

  let style = if cs-type == "topic" {
    (
      stroke: none,
      inset: 0mm,
      column-gutter: 6mm,
      row-gutter: 3mm,
    )
  } else {
    (
      stroke: if direction == "vertical" { (y: 1pt) } else { (x: 1pt) },
      inset: (left: 0.25pt, right: 0.25pt, top: 0pt, bottom: 0pt),
      column-gutter: 0mm,
      row-gutter: 0mm,
    )
  }

  grid(
    columns: cols,
    rows: rows,
    align: horizon,
    inset: style.inset,
    stroke: style.stroke,
    column-gutter: style.column-gutter,
    row-gutter: style.row-gutter,
    ..children.pos()
  )
}

// Wrapper für vertikalen Topic-Stack
#let v-stack(ratios: none, ..children) = {
  cs-stack(
    direction: "vertical",
    cs-type: "topic",
    ratios: ratios,
    ..children,
  )
}

// Wrapper für horizontalen Topic-Stack
#let h-stack(ratios: none, ..children) = {
  cs-stack(
    direction: "horizontal",
    cs-type: "topic",
    ratios: ratios,
    ..children,
  )
}

// Wrapper für vertikalen Subtopic-Stack
#let subtopic-v-stack(ratios: none, ..children) = {
  cs-stack(
    direction: "vertical",
    cs-type: "subtopic",
    ratios: ratios,
    ..children,
  )
}

// Wrapper für horizontalen Subtopic-Stack
#let subtopic-h-stack(ratios: none, ..children) = {
  cs-stack(
    direction: "horizontal",
    cs-type: "subtopic",
    ratios: ratios,
    ..children,
  )
}