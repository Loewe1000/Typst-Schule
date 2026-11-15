#import "internal/check.typ": fail, check-named, check-type, check-positional
#import "geometry.typ": analyze-layout, is-desk, is-seat, layout-matrix, table-cells

// Zellmaße gehen unverändert an `grid(columns:, rows:)`.
#let _track = (length, ratio, relative, fraction)

// Neue Namen, die ausdrücklich gesetzt wurden (Wert weicht von der Vorgabe
// ab), zusammen mit dem Sink: so meldet `check-named` „alt und neu zugleich".
#let _gesetzt(deprecated, paare) = {
  let d = deprecated.named()
  for (name, paar) in paare {
    if paar.at(0) != paar.at(1) { d.insert(name, paar.at(0)) }
  }
  d
}

/// Zeichnet den Sitzplan eines Klassenraums aus einem Layout-String.
///
/// Der Layout-String verwendet folgende Zeichen:
///
/// / `X`, auch `x`, `.`, `_`: freier Platz (unsichtbar)
/// / `T`: ein Sitzplatz; über Kanten zusammenhängende `T` bilden
///   automatisch einen Gruppentisch
/// / `1`–`9`, `a`–`z`, `A`–`Z`: ein Sitzplatz mit ausdrücklicher
///   Tischzugehörigkeit; gleiches Zeichen = gleicher Gruppentisch
///   (nützlich für Blocktische mit Kopfplätzen, die sich im Raster
///   nur diagonal berühren)
/// / `o`, auch `O`, `#`: Tischfläche ohne Sitzplatz
/// / `P`: Teil des Lehrerpults; alle `P`-Zeichen werden zu einem
///   einzigen Block zusammengeführt
///
/// Leerraum am Zeilenanfang und -ende wird ignoriert, eingerückte
/// mehrzeilige Strings funktionieren also unverändert.
///
/// Die Namen werden *vor* der Drehung zeilenweise (links→rechts, oben→unten)
/// auf die Sitzplätze verteilt und drehen sich anschließend mit dem Layout mit.
///
/// - layout (str): Mehrzeiliger String mit dem Raumlayout.
/// - names (array): Namen, die auf die Sitzplätze verteilt werden.
/// - cell-width (length, ratio, relative, fraction, auto): Breite einer
///   einzelnen Tischzelle (Spaltenmaß des Rasters).
/// - cell-height (length, ratio, relative, fraction, auto): Höhe einer
///   einzelnen Tischzelle (Zeilenmaß des Rasters).
/// - seat-fill (color): Füllfarbe der Sitzplätze.
/// - desk-fill (color): Füllfarbe des Lehrerpults.
/// - table-fill (auto, color, gradient, tiling, none): Füllung der Tischflächen zwischen
///   den Sitzplätzen eines Gruppentisches. `auto` leitet sie aus `seat-fill`
///   ab, `none` schaltet sie ab.
/// - number (bool): Platznummern klein mit anzeigen. Diese Nummern sind
///   es, die in der Vorgabe `fixed` von `sitzordnung` verwendet werden.
/// - rotation (angle): Drehung im Uhrzeigersinn: `0deg`, `90deg`, `180deg`
///   oder `270deg`.
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> content
#let typlace(
  layout,
  names: (),
  cell-width: 2cm,
  cell-height: 1.2cm,
  seat-fill: rgb("#cce0f5"),
  desk-fill: rgb("#6b4c2a"),
  table-fill: auto,
  number: false,
  rotation: 0deg,
  ..deprecated,
) = {
  check-positional(
    "typlace",
    "typlace",
    deprecated,
    hint: "nur das Layout steht vorn – die Namen als `names: (…)` schreiben",
  )
  check-named(
    "typlace",
    "typlace",
    _gesetzt(deprecated, (
      names: (names, ()),
      cell-width: (cell-width, 2cm),
      cell-height: (cell-height, 1.2cm),
      seat-fill: (seat-fill, rgb("#cce0f5")),
      desk-fill: (desk-fill, rgb("#6b4c2a")),
      table-fill: (table-fill, auto),
      number: (number, false),
    )),
    renamed: (
      namen: "names",
      tisch-breite: "cell-width",
      tisch-hoehe: "cell-height",
      tisch-farbe: "seat-fill",
      pult-farbe: "desk-fill",
      koerper-farbe: "table-fill",
      nummern: "number",
    ),
    allowed: ("names", "cell-width", "cell-height", "seat-fill", "desk-fill", "table-fill", "number", "rotation"),
  )
  check-type("typlace", "typlace", "layout", layout, str, example: "\"TT.TT\\n..P..\"")
  check-type("typlace", "typlace", "names", names, array, example: "(\"Anna\", \"Ben\")")
  for (name, wert, beispiel) in (("cell-width", cell-width, "2cm"), ("cell-height", cell-height, "1.2cm")) {
    if wert != auto and type(wert) not in _track {
      fail(
        "typlace",
        "typlace",
        "`" + name + "` erwartet eine Länge, einen Anteil, einen Bruchteil (`fr`) oder `auto`, bekam `"
          + repr(wert) + "` (" + str(type(wert)) + ") – zum Beispiel `" + beispiel + "`",
      )
    }
  }
  check-type("typlace", "typlace", "seat-fill", seat-fill, color, example: "rgb(\"#cce0f5\")")
  check-type("typlace", "typlace", "desk-fill", desk-fill, color, example: "rgb(\"#6b4c2a\")")
  check-type("typlace", "typlace", "table-fill", table-fill, (color, gradient, tiling, auto, none), example: "luma(85%)")
  check-type("typlace", "typlace", "number", number, bool)
  check-type("typlace", "typlace", "rotation", rotation, angle, example: "90deg")
  // Vierteldrehungen im Uhrzeigersinn; jede andere Angabe ist ein Fehler
  // (bis 0.0.2 wurde sie still als 0 gelesen).
  let grad = calc.rem(calc.rem(calc.round(rotation.deg(), digits: 6), 360) + 360, 360)
  if grad not in (0, 90, 180, 270) {
    fail(
      "typlace",
      "typlace",
      "`rotation: " + repr(rotation) + "` ist keine Vierteldrehung – erlaubt: `0deg`, `90deg`, `180deg`, `270deg`",
    )
  }

  // ── Matrixrotation ──────────────────────────────────────────────────

  // Einmalige 90°-Uhrzeigersinn-Rotation
  let rotate-90cw(m) = {
    let nrows = m.len()
    if nrows == 0 { return m }
    let ncols = m.at(0).len()
    range(ncols).map(c => range(nrows).map(r => m.at(nrows - 1 - r).at(c)))
  }

  let rotate-matrix(m, times) = {
    range(times).fold(m, (acc, _) => rotate-90cw(acc))
  }

  // ── Layout einlesen ─────────────────────────────────────────────────

  let char-matrix = layout-matrix(layout)
  if char-matrix.len() == 0 { return }

  // Tischflächen bestimmen: freie Zellen zwischen Sitzplätzen desselben
  // Gruppentisches werden als Tischkörper gezeichnet.
  let koerper = if table-fill == none { (:) } else { table-cells(analyze-layout(layout, caller: "typlace")) }

  let orig-rows = char-matrix.len()
  let orig-cols = char-matrix.at(0).len()

  // ── Namen VOR der Rotation zuweisen ────────────────────────────────
  // Ergebnis: Matrix aus (kind, name, nummer)-Tupeln mit kind ∈ seat | desk | table | free

  let full-matrix = ()
  let idx = 0
  for r in range(orig-rows) {
    let row = ()
    for c in range(orig-cols) {
      let ch = char-matrix.at(r).at(c)
      if is-seat(ch) {
        let name = if idx < names.len() { names.at(idx) } else { "" }
        row.push(("seat", name, idx))
        idx += 1
      } else if is-desk(ch) {
        row.push(("desk", "", -1))
      } else if str(r) + "-" + str(c) in koerper {
        row.push(("table", "", -1))
      } else {
        row.push(("free", "", -1))
      }
    }
    full-matrix.push(row)
  }

  // ── Rotation anwenden ──────────────────────────────────────────────

  let times = int(grad / 90)
  let rotated = rotate-matrix(full-matrix, times)

  let nrows = rotated.len()
  let ncols = rotated.at(0).len()

  // Bei 90°/270° Breite und Höhe tauschen
  let (zell-breite, zell-hoehe) = if calc.rem(times, 2) == 1 {
    (cell-height, cell-width)
  } else {
    (cell-width, cell-height)
  }

  let fuellung = if table-fill == auto { seat-fill.desaturate(70%).darken(6%) } else { table-fill }

  // ── P-Block Bounding-Box ermitteln ─────────────────────────────────
  // Alle zusammenhängenden P-Zeichen werden als EIN Block mit
  // colspan + rowspan dargestellt.

  let p-info = range(nrows).fold(
    (min-r: nrows, max-r: -1, min-c: ncols, max-c: -1, has-p: false),
    (state, r) => {
      range(ncols).fold(state, (s, c) => {
        if rotated.at(r).at(c).at(0) == "desk" {
          (
            min-r: calc.min(s.min-r, r),
            max-r: calc.max(s.max-r, r),
            min-c: calc.min(s.min-c, c),
            max-c: calc.max(s.max-c, c),
            has-p: true,
          )
        } else { s }
      })
    },
  )

  let p-colspan = if p-info.has-p { p-info.max-c - p-info.min-c + 1 } else { 0 }
  let p-rowspan = if p-info.has-p { p-info.max-r - p-info.min-r + 1 } else { 0 }

  // ── Rasterzellen aufbauen ──────────────────────────────────────────
  // Zellen in Lesereihenfolge (zeilenweise); Positionen, die vom
  // P-Block per rowspan/colspan abgedeckt werden, werden übersprungen.

  let cells = range(nrows).fold((), (acc, r) => {
    range(ncols).fold(acc, (a, c) => {
      let entry = rotated.at(r).at(c)
      let kind = entry.at(0)
      let name = entry.at(1)
      let nummer = entry.at(2)

      // Liegt diese Zelle im P-Block?
      let in-p-box = p-info.has-p and r >= p-info.min-r and r <= p-info.max-r and c >= p-info.min-c and c <= p-info.max-c
      let is-p-origin = p-info.has-p and r == p-info.min-r and c == p-info.min-c

      if in-p-box and not is-p-origin {
        // Von rowspan/colspan des P-Blocks abgedeckt → überspringen
        a
      } else if is-p-origin {
        // P-Block emittieren
        a + (grid.cell(
          colspan: p-colspan,
          rowspan: p-rowspan,
          fill: desk-fill,
          stroke: 0.5pt + desk-fill.darken(30%),
          align: center + horizon,
          inset: 3pt,
          text(fill: white, weight: "bold", size: 0.85em, "Pult"),
        ),)
      } else if kind == "seat" {
        a + (grid.cell(
          fill: seat-fill,
          stroke: 0.5pt + seat-fill.darken(40%),
          align: center + horizon,
          inset: 3pt,
          {
            if number {
              place(top + left, text(size: 0.5em, fill: luma(45%), str(nummer)))
            }
            text(size: 0.75em, name)
          },
        ),)
      } else if kind == "table" {
        a + (grid.cell(
          fill: fuellung,
          stroke: none,
          [],
        ),)
      } else {
        // freier Platz
        a + (grid.cell(
          fill: none,
          stroke: none,
          [],
        ),)
      }
    })
  })

  grid(
    columns: (zell-breite,) * ncols,
    rows: (zell-hoehe,) * nrows,
    gutter: 2pt,
    ..cells,
  )
}
