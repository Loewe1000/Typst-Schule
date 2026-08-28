// schuldocs — Beispiele und Quelltext
//
// Beide Ausgaben eines Bündellaufs entstehen aus demselben Inhalt. Im Handbuch
// wird ein gesetztes Beispiel ganz normal umbrochen; im HTML-Export gibt es
// kein Seitenlayout, dort muss es in `html.frame(…)` stehen. Andernfalls
// verwirft Typst die Anordnung und warnt („pad was ignored during HTML
// export"). Die Weiche stellt `doc-target()`.
//
// Das Aussehen der Website kommt aus `docs.css`, das des Handbuchs aus
// `theme-pdf.typ` — beide geben Codeblöcken bereits ihre Fläche. Hier entsteht
// nur der Aufbau, auf der Website über diese Klassen:
//
//   .sd-example          Hülle um ein Beispiel
//   .sd-example--split     zusätzlich bei `side-by-side: true`
//   .sd-example-code     der Quelltext-Teil (enthält <pre><code>)
//   .sd-example-render   der gesetzte Teil (enthält <svg> aus html.frame)
//   .sd-code             freistehender Quelltext aus `show-code`

#import "config.typ": colors, doc-target

// Breite des gesetzten Teils im HTML-Export, wenn `width: auto` gilt. Dort gibt
// es keine Textbreite, an der sich `auto` ausrichten könnte.
#let _web-width = 14cm

// Nur echte Längen taugen als Rahmenbreite im HTML-Export; `auto` und Anteile
// beziehen sich auf eine Umgebung, die es dort nicht gibt.
#let _frame-width(width, side-by-side) = {
  if type(width) == length { width } else if side-by-side { _web-width / 2 } else { _web-width }
}

// Zeichenketten werden als Typst-Quelltext gesetzt, fertige Blöcke bleiben, wie
// sie sind.
#let _as-raw(body) = {
  if body == none { none } else if type(body) == str { raw(body, block: true, lang: "typ") } else { body }
}

// Fläche für das gesetzte Beispiel im Handbuch. Der Quelltext daneben bekommt
// sein Aussehen von der Vorlage (getönte Fläche); das Ergebnis steht in einem
// weißen Feld mit dünnem Rand. Der geringe Abstand hält beides zusammen.
#let _render-pane(body, spacing: 0.5em) = block(
  width: 100%,
  breakable: true,
  spacing: spacing,
  radius: 3pt,
  stroke: 0.6pt + colors.surface-edge,
  inset: (x: 0.8em, y: 0.8em),
  body,
)

/// Zeigt ein Beispiel: den Quelltext und das damit gesetzte Ergebnis.
///
/// Der gesetzte Teil wird nicht ausgeführt, sondern fertig übergeben — so
/// bleibt das Beispiel in beiden Ausgaben dasselbe:
///
/// ```typ
/// #show-example(
///   rendered: {
///     import "../src/lib.typ": aufgabe
///     aufgabe[Berechne 15 + 27.]
///   },
///   source: ```typ
///   #aufgabe[Berechne 15 + 27.]
///   ```,
///   width: 14cm,
/// )
/// ```
///
/// Im Handbuch folgt dem Quelltext dicht darunter das Ergebnis in einem eigenen
/// Feld; der Quelltext trägt dabei das Aussehen, das die Vorlage allen
/// Codeblöcken gibt. Im HTML-Export stehen beide Teile in `<div>`-Elementen,
/// das Ergebnis in `html.frame(…)`, weil es sonst verloren ginge.
///
/// - rendered (content): Das gesetzte Ergebnis.
/// - source (raw, string): Der zugehörige Quelltext.
/// - width (auto, length): Breite des gesetzten Teils. `auto` bedeutet im
///   Handbuch die volle Textbreite und auf der Website 14 cm.
/// - side-by-side (bool): Quelltext und Ergebnis nebeneinander statt
///   untereinander.
/// - ..rest (any): Wird nicht ausgewertet; hält ältere Aufrufe am Leben.
/// -> content
#let show-example(
  rendered: none,
  source: none,
  width: auto,
  side-by-side: false,
  ..rest,
) = context {
  let code = _as-raw(source)
  if code == none and rendered == none { return none }

  if doc-target() == "web" {
    let classes = "sd-example" + if side-by-side { " sd-example--split" } else { "" }
    html.div(
      class: classes,
      {
        if code != none {
          html.div(class: "sd-example-code", code)
        }
        if rendered != none {
          html.div(
            class: "sd-example-render",
            html.frame(block(width: _frame-width(width, side-by-side), rendered)),
          )
        }
      },
    )
  } else {
    // Handbuch: normaler Satz, kein `html.frame`. Beide Teile dürfen umbrechen,
    // damit lange Beispiele nicht aus der Seite laufen.
    let inner-width = if width == auto { 100% } else { width }
    let rendered-part = if rendered != none { block(width: inner-width, rendered) } else { none }

    if side-by-side and code != none and rendered-part != none {
      grid(
        columns: (1fr, 1fr),
        column-gutter: 0.6em,
        align: top,
        code,
        _render-pane(rendered-part, spacing: 0pt),
      )
    } else {
      if code != none { code }
      if rendered-part != none {
        _render-pane(rendered-part, spacing: if code == none { auto } else { 0.5em })
      }
    }
  }
}

/// Zeigt Quelltext, ohne ihn auszuführen.
///
/// Auf der Website entsteht `<pre><code>` — auswählbarer Text, kein Bild.
///
/// ```typ
/// #show-code(```typ
/// #import "@schule/aufgaben:0.3.0": *
/// ```)
/// ```
///
/// - body (raw, string): Der Quelltext.
/// - ..rest (any): Wird nicht ausgewertet; hält ältere Aufrufe am Leben.
/// -> content
#let show-code(body, ..rest) = context {
  let code = _as-raw(body)
  if code == none {
    none
  } else if doc-target() == "web" {
    html.div(class: "sd-code", code)
  } else {
    // Im Handbuch gibt die Vorlage Codeblöcken ihr Aussehen; ein zweiter Rahmen
    // hier würde nur doppelt zeichnen.
    code
  }
}
