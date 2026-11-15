// ═══════════════════════════════════════════════════════════════════
//  Geometrie: Layout-String → Sitzplätze, Gruppentische, Zonen
// ═══════════════════════════════════════════════════════════════════

// ── Zeichenklassen ─────────────────────────────────────────────────
//
//   X x . _ ␣   freier Platz (unsichtbar)
//   P p         Lehrerpult
//   o O #       Tischkörper (Fläche, kein Sitzplatz)
//   T           Sitzplatz, Gruppentisch wird automatisch erkannt
//   1-9 a-z A-Z Sitzplatz mit expliziter Tischzugehörigkeit
//               (gleiches Zeichen = gleicher Gruppentisch)

#import "internal/check.typ": fail

#let free-chars = ("X", "x", ".", "_", " ")
#let desk-chars = ("P", "p")
#let table-chars = ("o", "O", "#")
#let auto-chars = ("T",)

#let _alnum = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".clusters()
#let _reserviert = free-chars + desk-chars + table-chars + auto-chars
#let table-ids = _alnum.filter(c => c not in _reserviert)

#let is-free(ch) = ch in free-chars
#let is-desk(ch) = ch in desk-chars
#let is-table(ch) = ch in table-chars
#let is-seat(ch) = ch in auto-chars or ch in table-ids

/// Zerlegt den Layout-String in eine Zeichenmatrix.
///
/// Führende und abschließende Leerzeichen jeder Zeile werden entfernt,
/// damit eingerückte mehrzeilige Strings wie erwartet funktionieren.
/// Kürzere Zeilen werden rechts mit `X` aufgefüllt.
#let layout-matrix(layout) = {
  let rows = layout.split("\n").map(z => z.trim()).filter(z => z != "")
  if rows.len() == 0 { return () }
  let columns = calc.max(..rows.map(z => z.clusters().len()))
  rows.map(z => {
    let cl = z.clusters()
    cl + ("X",) * (columns - cl.len())
  })
}

// ── Gruppentische bestimmen ────────────────────────────────────────

/// Ordnet jeder `T`-Zelle einen automatisch erkannten Tischnamen zu.
/// Über Kanten zusammenhängende `T`-Felder bilden einen Gruppentisch.
#let _auto-tische(matrix) = {
  let rows = matrix.len()
  let columns = matrix.at(0).len()
  let assignment = (:)
  let gesehen = (:)
  let naechste = 0

  for r in range(rows) {
    for c in range(columns) {
      if matrix.at(r).at(c) not in auto-chars { continue }
      let start = str(r) + "-" + str(c)
      if start in gesehen { continue }

      let name = "auto-" + str(naechste)
      naechste += 1
      gesehen.insert(start, true)
      let stapel = ((r, c),)

      while stapel.len() > 0 {
        let pos = stapel.pop()
        assignment.insert(str(pos.at(0)) + "-" + str(pos.at(1)), name)
        for versatz in ((1, 0), (-1, 0), (0, 1), (0, -1)) {
          let nr = pos.at(0) + versatz.at(0)
          let nc = pos.at(1) + versatz.at(1)
          if nr < 0 or nr >= rows or nc < 0 or nc >= columns { continue }
          let nk = str(nr) + "-" + str(nc)
          if matrix.at(nr).at(nc) in auto-chars and nk not in gesehen {
            gesehen.insert(nk, true)
            stapel.push((nr, nc))
          }
        }
      }
    }
  }
  assignment
}

// ── Vorderseite des Raumes ─────────────────────────────────────────

/// Ermittelt, an welcher Kante des Layouts „vorne" liegt.
/// Ohne Angabe entscheidet die Lage des Pults, sonst gilt `"top"`.
#let _vorderseite(matrix, front) = {
  if front != auto { return front }
  let rows = matrix.len()
  let columns = matrix.at(0).len()
  let rs = ()
  let cs = ()
  for r in range(rows) {
    for c in range(columns) {
      if is-desk(matrix.at(r).at(c)) {
        rs.push(r)
        cs.push(c)
      }
    }
  }
  if rs.len() == 0 { return "top" }
  let d-oben = calc.min(..rs)
  let d-unten = rows - 1 - calc.max(..rs)
  let d-links = calc.min(..cs)
  let d-rechts = columns - 1 - calc.max(..cs)
  let m = calc.min(d-oben, d-unten, d-links, d-rechts)
  if m == d-oben { "top" } else if m == d-unten { "bottom" } else if m == d-links { "left" } else { "right" }
}

// ── Hauptfunktion ──────────────────────────────────────────────────

/// Analysiert ein Layout und liefert alle Informationen, die der
/// Optimierer und die Bewertung brauchen.
///
/// - layout (str): Layout-String des Raumes.
/// - front (auto, str): Vorderseite: `auto` (aus Pultlage), `"top"`,
///   `"bottom"`, `"left"` oder `"right"`.
/// - perspective (str): `"student"` – links/rechts aus Sicht der nach vorne
///   blickenden Klasse (Standard), oder `"plan"` – wie gezeichnet.
/// - caller (str): Name der öffentlichen Funktion für Fehlermeldungen.
/// -> dictionary
#let analyze-layout(layout, front: auto, perspective: "student", caller: "sitzordnung") = {
  let matrix = layout-matrix(layout)
  if matrix.len() == 0 {
    fail("typlace", caller, "das Layout enthält keine Zeilen – mindestens eine Zeile mit Sitzplätzen (`T`) angeben")
  }
  let rows = matrix.len()
  let columns = matrix.at(0).len()

  let auto-zuordnung = _auto-tische(matrix)
  let side = _vorderseite(matrix, front)

  // Sitzplätze in Lesereihenfolge (links→rechts, oben→unten).
  // Der Index ist zugleich die Position im `names`-Array von typlace().
  let roh = ()
  for r in range(rows) {
    for c in range(columns) {
      let ch = matrix.at(r).at(c)
      if not is-seat(ch) { continue }
      let table = if ch in auto-chars {
        auto-zuordnung.at(str(r) + "-" + str(c))
      } else {
        "table-" + ch
      }
      roh.push((index: roh.len(), row: r, column: c, character: ch, table: table))
    }
  }
  if roh.len() == 0 {
    fail("typlace", caller, "das Layout enthält keine Sitzplätze – Plätze mit `T` oder einem Tischzeichen (`1`–`9`, `a`–`z`) eintragen")
  }

  // ── Zonen ────────────────────────────────────────────────────────
  //
  //  Tiefe (depth): front / middle / back – Abstand zur Vorderseite des Raumes
  //  Seite (side):  left / middle / right – quer dazu
  //
  //  Die Seite wird standardmäßig aus *Schülersicht* bestimmt (Blick nach
  //  vorne), nicht aus Sicht des gezeichneten Plans. Sitzt das Pult unten
  //  im Layout, ist „links" für die Schüler also die rechte Seite des
  //  Ausdrucks. Mit `perspective: "plan"` wird stattdessen die
  //  Zeichenrichtung verwendet.
  let tiefe-wert(p) = {
    if side == "top" { p.row } else if side == "bottom" { rows - 1 - p.row } else if side == "left" {
      p.column
    } else { columns - 1 - p.column }
  }
  let quer-wert(p) = {
    if perspective == "plan" {
      if side in ("top", "bottom") { p.column } else { p.row }
    } else if side == "top" {
      p.column
    } else if side == "bottom" {
      columns - 1 - p.column
    } else if side == "left" {
      rows - 1 - p.row
    } else {
      p.row
    }
  }

  // Die Zonen gelten für den *Gruppentisch als Ganzes*: ein Tisch liegt
  // vorne, in der Mitte oder hinten – nicht seine einzelnen Sitzreihen.
  // Sonst läge ein Blocktisch mit Kopfplätzen in zwei Zonen gleichzeitig.
  let tisch-mittel(wert-fn) = {
    let summe = (:)
    let anzahl = (:)
    for p in roh {
      summe.insert(p.table, summe.at(p.table, default: 0) + wert-fn(p))
      anzahl.insert(p.table, anzahl.at(p.table, default: 0) + 1)
    }
    let mittel = (:)
    for (t, w) in summe { mittel.insert(t, calc.round(w / anzahl.at(t), digits: 3)) }
    mittel
  }

  // Verteilt die Tische auf drei Bänder. Bei nur zwei Tischreihen gibt es
  // kein Mittelband, bei einer einzigen liegen alle in der Mitte.
  let baender(mittel, names) = {
    let werte = mittel.values().dedup().sorted()
    let k = werte.len()
    let band-von-wert = (:)
    for (i, w) in werte.enumerate() {
      let name = if k == 1 {
        names.at(1)
      } else if k == 2 {
        names.at(if i == 0 { 0 } else { 2 })
      } else {
        names.at(calc.min(2, calc.floor(i * 3 / k)))
      }
      band-von-wert.insert(str(w), name)
    }
    let je-tisch = (:)
    for (t, w) in mittel { je-tisch.insert(t, band-von-wert.at(str(w))) }
    je-tisch
  }

  let tiefe-zone = baender(tisch-mittel(tiefe-wert), ("front", "middle", "back"))
  let quer-zone = baender(tisch-mittel(quer-wert), ("left", "middle", "right"))

  let seats = roh.map(p => (
    index: p.index,
    row: p.row,
    column: p.column,
    character: p.character,
    table: p.table,
    distance: tiefe-wert(p),
    zone: (depth: tiefe-zone.at(p.table), side: quer-zone.at(p.table)),
  ))

  // Tische → Plätze
  let tables = (:)
  for p in seats {
    tables.insert(p.table, tables.at(p.table, default: ()) + (p.index,))
  }

  // Beziehungsmatrix
  //   "adjacent" – am selben Tisch und unmittelbar benachbart
  //                (nebeneinander, gegenüber oder über Eck)
  //   "table"    – am selben Gruppentisch, aber weiter entfernt
  //   "far"      – an verschiedenen Tischen
  let n = seats.len()
  let relations = range(n).map(i => range(n).map(j => {
    if i == j {
      "self"
    } else if seats.at(i).table != seats.at(j).table {
      "far"
    } else {
      let dr = seats.at(i).row - seats.at(j).row
      let dc = seats.at(i).column - seats.at(j).column
      if dr * dr + dc * dc <= 2 { "adjacent" } else { "table" }
    }
  }))

  (
    matrix: matrix,
    rows: rows,
    columns: columns,
    front: side,
    seats: seats,
    tables: tables,
    zones: (
      depth: seats.map(p => p.zone.depth).dedup(),
      side: seats.map(p => p.zone.side).dedup(),
    ),
    relations: relations,
  )
}

/// Liefert die Zellen, die als Tischkörper (Fläche eines Gruppentisches)
/// gezeichnet werden sollen: freie Zellen, die auf zwei gegenüber-
/// liegenden Seiten an Sitzplätze *desselben* Tisches grenzen.
#let table-cells(geometry) = {
  let tisch-an = (:)
  for p in geometry.seats { tisch-an.insert(str(p.row) + "-" + str(p.column), p.table) }

  let treffer = (:)
  for r in range(geometry.rows) {
    for c in range(geometry.columns) {
      let ch = geometry.matrix.at(r).at(c)
      if is-table(ch) {
        treffer.insert(str(r) + "-" + str(c), true)
        continue
      }
      if not is-free(ch) { continue }
      let paare = (
        (str(r - 1) + "-" + str(c), str(r + 1) + "-" + str(c)),
        (str(r) + "-" + str(c - 1), str(r) + "-" + str(c + 1)),
      )
      for paar in paare {
        let a = tisch-an.at(paar.at(0), default: none)
        let b = tisch-an.at(paar.at(1), default: none)
        if a != none and a == b {
          treffer.insert(str(r) + "-" + str(c), true)
          break
        }
      }
    }
  }
  treffer
}
