#import "internal/check.typ": check-named, check-positional

/// Dunkelblau der Angelaschule, `rgb(40, 80, 155)`. Farbe der Linie im Briefkopf.
#let angela-dark = rgb(40, 80, 155)

/// Hellblau der Angelaschule, `rgb(150, 180, 221)`. Zum Beispiel für Flächen.
#let angela-light = rgb(150, 180, 221)

/// Briefvorlage der Angelaschule Osnabrück.
///
/// Richtet eine A4-Seite mit dem Briefkopf der Angelaschule ein (Schulname,
/// Logo, blaue Linie). Der Schulname steht in *Lucida Grande*, der Brieftext
/// in *Calibri* 11pt, im Blocksatz mit Silbentrennung.
/// Wird mit `#show: brief` eingebunden und kennt keine Einstellungen.
///
/// ```typ
/// #show: brief
/// ```
///
/// - ..deprecated (arguments): nimmt nichts an; jedes benannte oder überzählige Argument bricht mit einer Meldung ab
/// - body (content): der Brief
/// -> content
#let brief(..deprecated, body) = {
  check-positional("angela", "brief", deprecated,
    hint: "`brief` nimmt nur den Brief selbst an – als `#show: brief` einbinden")
  check-named("angela", "brief", deprecated, allowed: ())

  show heading: set block(above: 2em, below: 1em)

  set page(
    "a4",
    margin: (top: 5cm, bottom: 2cm, left: 2.5cm, right: 2.5cm),
    header-ascent: 35%,
    header: [
      #stack(
        dir: ttb,
        spacing: 3mm,
        text(font: "Lucida Grande", size: 20pt, [Angelaschule Osnabrück]),
        text(
          font: "Arial",
          stretch: 75%,
          size: 8pt,
          [Staatlich anerkanntes Gymnasium der Schulstiftung im Bistum Osnabrück],
        ),
      )
      #box(width: 100%)[
        #place(top, dx: -2.5cm, dy: 0cm, line(stroke: angela-dark, length: 2 * 100%))
        #place(top + right, dx: 1.5mm, dy: -0.5cm, box(width: 3cm, height: 4cm, fill: white))
        #place(top + right, dx: 1cm, dy: -3cm, image("../logo.svg", height: 4cm))
      ]
    ],
  )
  set text(size: 11pt, font: "Calibri", lang: "de")
  set par(leading: 0.75em, justify: true)
  set text(hyphenate: true)
  body
}
