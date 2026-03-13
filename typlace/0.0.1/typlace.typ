/// Erstellt ein Tischlayout für einen Klassenraum.
///
/// Der Layout-String verwendet folgende Zeichen:
/// - `X` = freier Platz (unsichtbar)
/// - `T` = ein Tisch / Sitzplatz
/// - `P` = Teil eines großen Pultes (alle `P`-Zeichen werden zu einem
///         einzigen Block mit `colspan` und `rowspan` zusammengeführt)
///
/// Die Namen werden *vor* der Rotation zeilenweise (links→rechts, oben→unten)
/// auf die `T`-Plätze verteilt und drehen sich anschließend mit dem Layout mit.
///
/// - layout (str): Mehrzeiliger String mit dem Raumlayout.
/// - namen (array): Namen, die auf die Sitzplätze verteilt werden.
/// - tisch-breite (length): Breite einer einzelnen Tischzelle.
/// - tisch-hoehe (length): Höhe einer einzelnen Tischzelle.
/// - tisch-farbe (color): Füllfarbe der Tische.
/// - pult-farbe (color): Füllfarbe des Lehrerpults.
/// - rotation (int): Rotation in Grad (0, 90, 180 oder 270, jeweils im Uhrzeigersinn).
/// -> content
#let typlace(
  layout,
  namen: (),
  tisch-breite: 2cm,
  tisch-hoehe: 1.2cm,
  tisch-farbe: rgb("#cce0f5"),
  pult-farbe: rgb("#6b4c2a"),
  rotation: 0,
) = {
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

  let rows = layout.split("\n").filter(r => r.trim() != "")
  if rows.len() == 0 { return }

  let orig-cols = calc.max(..rows.map(r => r.len()))
  let char-matrix = rows.map(r => (r + "X" * (orig-cols - r.len())).clusters())

  // ── Namen VOR der Rotation zuweisen ────────────────────────────────
  // Ergebnis: Matrix aus (zeichen, name)-Tupeln

  let assign-result = char-matrix.fold(
    (mat: (), idx: 0),
    (state, row) => {
      let row-result = row.fold(
        (cells: (), idx: state.idx),
        (s, ch) => {
          if ch == "T" {
            let name = if s.idx < namen.len() { namen.at(s.idx) } else { "" }
            (cells: s.cells + ((ch, name),), idx: s.idx + 1)
          } else {
            (cells: s.cells + ((ch, ""),), idx: s.idx)
          }
        },
      )
      (mat: state.mat + (row-result.cells,), idx: row-result.idx)
    },
  )
  let full-matrix = assign-result.mat

  // ── Rotation anwenden ──────────────────────────────────────────────

  let times = if rotation == 90 { 1 } else if rotation == 180 { 2 } else if rotation == 270 { 3 } else { 0 }
  let rotated = rotate-matrix(full-matrix, times)

  let nrows = rotated.len()
  let ncols = rotated.at(0).len()

  // Bei 90°/270° Breite und Höhe tauschen
  let (zell-breite, zell-hoehe) = if calc.rem(times, 2) == 1 {
    (tisch-hoehe, tisch-breite)
  } else {
    (tisch-breite, tisch-hoehe)
  }

  // ── P-Block Bounding-Box ermitteln ─────────────────────────────────
  // Alle zusammenhängenden P-Zeichen werden als EIN Block mit
  // colspan + rowspan dargestellt.

  let p-info = range(nrows).fold(
    (min-r: nrows, max-r: -1, min-c: ncols, max-c: -1, has-p: false),
    (state, r) => {
      range(ncols).fold(state, (s, c) => {
        if rotated.at(r).at(c).first() == "P" {
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
      let ch = entry.first()
      let name = entry.last()

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
          fill: pult-farbe,
          stroke: 0.5pt + pult-farbe.darken(30%),
          align: center + horizon,
          inset: 3pt,
          text(fill: white, weight: "bold", size: 0.85em, "Pult"),
        ),)
      } else if ch == "T" {
        a + (grid.cell(
          fill: tisch-farbe,
          stroke: 0.5pt + tisch-farbe.darken(40%),
          align: center + horizon,
          inset: 3pt,
          text(size: 0.75em, name),
        ),)
      } else {
        // X – freier Platz
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
