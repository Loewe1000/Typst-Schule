// Nachbildung der Algebra-Ansicht von GeoGebra.
#import "internal.typ": geogebra-menu-button, geogebra-approximate-button
#import "internal/check.typ": check-named, check-type, check-positional

/// Setzt Formeln wie in der GeoGebra-Oberfläche: aufrecht, serifenlos und
/// abgesetzt, in der Schrift „New Computer Modern Sans Math“.
///
/// ```typ
/// #geogebra-style[
///   $g(t) = v + t u$
/// ]
/// ```
///
/// - body (content): Inhalt, dessen Formeln im GeoGebra-Stil gesetzt werden
/// -> content
#let geogebra-style(body) = {
  show math.equation: it => {
    show text: set text(font: "New Computer Modern Sans Math")
    set text(font: "New Computer Modern Sans Math", weight: "regular")
    math.upright(math.display(it))
  }
  set align(left)
  body
}

/// Setzt eine einzelne Zelle der Algebra-Ansicht mit ihren Schaltflächen.
///
/// ```typ
/// #geogebra-cell(approximate: true)[$f(x) = x^2$]
/// ```
///
/// - menu (bool): die drei Punkte am rechten Rand zeigen
/// - approximate (bool): die lila Schaltfläche „≈“ (Näherungswert) zeigen
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt der Zelle, üblicherweise eine Formel
/// -> content
#let geogebra-cell(menu: true, approximate: false, ..deprecated, body) = {
  check-positional(
    "mathematik",
    "geogebra-cell",
    deprecated,
    hint: "eine Zelle hat genau einen Inhalt; mehrere Zellen setzt `geogebra-algebra`",
  )
  check-named(
    "mathematik",
    "geogebra-cell",
    deprecated,
    renamed: (approx: "approximate"),
    allowed: ("menu", "approximate"),
  )
  check-type("mathematik", "geogebra-cell", "menu", menu, bool)
  check-type("mathematik", "geogebra-cell", "approximate", approximate, bool)

  [
    #let button-dx = 1em
    #let button-dy = -0.4em
    #if menu {
      place(right, dx: button-dx, dy: button-dy, geogebra-menu-button())
    }
    #if approximate {
      place(bottom + right, dx: button-dx - 0.4em, dy: 0.4em, geogebra-approximate-button())
    }
    #body
    #if approximate {
      v(-0.4em)
    }
  ]
}

/// Setzt die Algebra-Ansicht von GeoGebra: eine Tabelle aus Zellen im
/// GeoGebra-Stil. Jede Zelle bekommt die drei Punkte am rechten Rand.
///
/// ```typ
/// #geogebra-algebra(
///   $v = vec(2, 1, 5)$,
///   $u = vec(1, -1, 3)$,
///   $P = (3, 1, -3)$,
///   approximate-last: true,
/// )
/// ```
///
/// - stroke (none, length, color, stroke, dictionary): Rahmen der Tabelle
/// - columns (auto, int, relative, fraction, array): Spalten wie bei `table`
/// - inset (relative, dictionary): Innenabstand der Zellen
/// - approximate-last (bool): die letzte Zelle bekommt die Schaltfläche „≈“
/// - ..cells (arguments): Positionsargumente sind die Zellen; benannte Argumente nimmt der Sink nicht an, er fängt nur alte Namen ab
/// -> content
#let geogebra-algebra(
  stroke: 0.5pt + rgb("#DCDCDC"),
  columns: 1,
  inset: (left: 0.8em, top: 0.8em, bottom: 0.8em, right: 1.2em),
  approximate-last: false,
  ..cells,
) = {
  check-named(
    "mathematik",
    "geogebra-algebra",
    cells,
    renamed: ("last-has-approx": "approximate-last"),
    allowed: ("stroke", "columns", "inset", "approximate-last"),
  )
  check-type("mathematik", "geogebra-algebra", "approximate-last", approximate-last, bool)
  check-type("mathematik", "geogebra-algebra", "stroke", stroke, (length, color, std.stroke, dictionary, none), example: "0.5pt + gray")
  check-type("mathematik", "geogebra-algebra", "columns", columns, (int, length, relative, ratio, fraction, array, auto), example: "2")
  check-type("mathematik", "geogebra-algebra", "inset", inset, (length, relative, ratio, dictionary), example: "0.8em")

  let entries = cells.pos()
  let rows = entries
    .enumerate()
    .map(((index, cell)) => geogebra-cell(
      menu: true,
      approximate: approximate-last and index == entries.len() - 1,
      cell,
    ))

  geogebra-style[
    #table(
      stroke: stroke,
      columns: columns,
      inset: inset,
      ..rows,
    )
  ]
}
