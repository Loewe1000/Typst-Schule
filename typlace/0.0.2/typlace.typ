#import "geometrie.typ": (
  ist-frei, ist-koerper, ist-platz, ist-pult, koerper-zellen, layout-matrix, plaetze-analysieren, tisch-ids,
)
#import "daten.typ": schueler-lesen, schueler-pruefen, wunschliste
#import "optimierer.typ": sitzordnung
#import "wasm.typ": wasm-suchen
#import "bericht.typ": sitzplan-bericht, sitzplan-kennzahlen
#import "bewertung.typ": (
  bewerte, kontext-erstellen, normalisiere-vorgaben, platz-von-schueler, punkte-schueler, punkte-wert, standard-gewichte, statistik, tausch-delta,
)

/// Erstellt ein Tischlayout für einen Klassenraum.
///
/// Der Layout-String verwendet folgende Zeichen:
/// - `X` (auch `x`, `.`, `_`) = freier Platz (unsichtbar)
/// - `T` = ein Sitzplatz; über Kanten zusammenhängende `T` bilden
///         automatisch einen Gruppentisch
/// - `1`–`9`, `a`–`z`, `A`–`Z` = ein Sitzplatz mit ausdrücklicher
///         Tischzugehörigkeit: gleiches Zeichen = gleicher Gruppentisch
///         (nützlich für Blocktische mit Kopfplätzen, die sich im Raster
///         nur diagonal berühren)
/// - `o` (auch `O`, `#`) = Tischfläche ohne Sitzplatz
/// - `P` = Teil eines großen Pultes (alle `P`-Zeichen werden zu einem
///         einzigen Block mit `colspan` und `rowspan` zusammengeführt)
///
/// Leerraum am Zeilenanfang und -ende wird ignoriert, eingerückte
/// mehrzeilige Strings funktionieren also unverändert.
///
/// Die Namen werden *vor* der Rotation zeilenweise (links→rechts, oben→unten)
/// auf die Sitzplätze verteilt und drehen sich anschließend mit dem Layout mit.
///
/// - layout (str): Mehrzeiliger String mit dem Raumlayout.
/// - namen (array): Namen, die auf die Sitzplätze verteilt werden.
/// - tisch-breite (length): Breite einer einzelnen Tischzelle.
/// - tisch-hoehe (length): Höhe einer einzelnen Tischzelle.
/// - tisch-farbe (color): Füllfarbe der Sitzplätze.
/// - pult-farbe (color): Füllfarbe des Lehrerpults.
/// - nummern (bool): Platznummern klein mit anzeigen. Diese Nummern sind
///   es, die in der Vorgabe `fest` verwendet werden.
/// - koerper-farbe (auto, color, none): Füllfarbe der Tischflächen zwischen
///   den Sitzplätzen eines Gruppentisches. `none` schaltet sie ab.
/// - rotation (int): Rotation in Grad (0, 90, 180 oder 270, jeweils im Uhrzeigersinn).
/// -> content
#let typlace(
  layout,
  namen: (),
  tisch-breite: 2cm,
  tisch-hoehe: 1.2cm,
  tisch-farbe: rgb("#cce0f5"),
  pult-farbe: rgb("#6b4c2a"),
  koerper-farbe: auto,
  nummern: false,
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

  let char-matrix = layout-matrix(layout)
  if char-matrix.len() == 0 { return }

  // Tischflächen bestimmen: freie Zellen zwischen Sitzplätzen desselben
  // Gruppentisches werden als Tischkörper gezeichnet.
  let koerper = if koerper-farbe == none { (:) } else { koerper-zellen(plaetze-analysieren(layout)) }

  let orig-rows = char-matrix.len()
  let orig-cols = char-matrix.at(0).len()

  // ── Namen VOR der Rotation zuweisen ────────────────────────────────
  // Ergebnis: Matrix aus (art, name)-Tupeln mit art ∈ platz | pult | koerper | frei

  let full-matrix = ()
  let idx = 0
  for r in range(orig-rows) {
    let zeile = ()
    for c in range(orig-cols) {
      let ch = char-matrix.at(r).at(c)
      if ist-platz(ch) {
        let name = if idx < namen.len() { namen.at(idx) } else { "" }
        zeile.push(("platz", name, idx))
        idx += 1
      } else if ist-pult(ch) {
        zeile.push(("pult", "", -1))
      } else if str(r) + "-" + str(c) in koerper {
        zeile.push(("koerper", "", -1))
      } else {
        zeile.push(("frei", "", -1))
      }
    }
    full-matrix.push(zeile)
  }

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

  let fuellung = if koerper-farbe == auto { tisch-farbe.desaturate(70%).darken(6%) } else { koerper-farbe }

  // ── P-Block Bounding-Box ermitteln ─────────────────────────────────
  // Alle zusammenhängenden P-Zeichen werden als EIN Block mit
  // colspan + rowspan dargestellt.

  let p-info = range(nrows).fold(
    (min-r: nrows, max-r: -1, min-c: ncols, max-c: -1, has-p: false),
    (state, r) => {
      range(ncols).fold(state, (s, c) => {
        if rotated.at(r).at(c).at(0) == "pult" {
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
      let art = entry.at(0)
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
          fill: pult-farbe,
          stroke: 0.5pt + pult-farbe.darken(30%),
          align: center + horizon,
          inset: 3pt,
          text(fill: white, weight: "bold", size: 0.85em, "Pult"),
        ),)
      } else if art == "platz" {
        a + (grid.cell(
          fill: tisch-farbe,
          stroke: 0.5pt + tisch-farbe.darken(40%),
          align: center + horizon,
          inset: 3pt,
          {
            if nummern {
              place(top + left, text(size: 0.5em, fill: luma(45%), str(nummer)))
            }
            text(size: 0.75em, name)
          },
        ),)
      } else if art == "koerper" {
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
