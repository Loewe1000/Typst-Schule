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

#let zeichen-frei = ("X", "x", ".", "_", " ")
#let zeichen-pult = ("P", "p")
#let zeichen-koerper = ("o", "O", "#")
#let zeichen-auto = ("T",)

#let _alnum = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".clusters()
#let _reserviert = zeichen-frei + zeichen-pult + zeichen-koerper + zeichen-auto
#let tisch-ids = _alnum.filter(c => c not in _reserviert)

#let ist-frei(ch) = ch in zeichen-frei
#let ist-pult(ch) = ch in zeichen-pult
#let ist-koerper(ch) = ch in zeichen-koerper
#let ist-platz(ch) = ch in zeichen-auto or ch in tisch-ids

/// Zerlegt den Layout-String in eine Zeichenmatrix.
///
/// Führende und abschließende Leerzeichen jeder Zeile werden entfernt,
/// damit eingerückte mehrzeilige Strings wie erwartet funktionieren.
/// Kürzere Zeilen werden rechts mit `X` aufgefüllt.
#let layout-matrix(layout) = {
  let zeilen = layout.split("\n").map(z => z.trim()).filter(z => z != "")
  if zeilen.len() == 0 { return () }
  let spalten = calc.max(..zeilen.map(z => z.clusters().len()))
  zeilen.map(z => {
    let cl = z.clusters()
    cl + ("X",) * (spalten - cl.len())
  })
}

// ── Gruppentische bestimmen ────────────────────────────────────────

/// Ordnet jeder `T`-Zelle einen automatisch erkannten Tischnamen zu.
/// Über Kanten zusammenhängende `T`-Felder bilden einen Gruppentisch.
#let _auto-tische(matrix) = {
  let zeilen = matrix.len()
  let spalten = matrix.at(0).len()
  let zuordnung = (:)
  let gesehen = (:)
  let naechste = 0

  for r in range(zeilen) {
    for c in range(spalten) {
      if matrix.at(r).at(c) not in zeichen-auto { continue }
      let start = str(r) + "-" + str(c)
      if start in gesehen { continue }

      let name = "auto-" + str(naechste)
      naechste += 1
      gesehen.insert(start, true)
      let stapel = ((r, c),)

      while stapel.len() > 0 {
        let pos = stapel.pop()
        zuordnung.insert(str(pos.at(0)) + "-" + str(pos.at(1)), name)
        for versatz in ((1, 0), (-1, 0), (0, 1), (0, -1)) {
          let nr = pos.at(0) + versatz.at(0)
          let nc = pos.at(1) + versatz.at(1)
          if nr < 0 or nr >= zeilen or nc < 0 or nc >= spalten { continue }
          let nk = str(nr) + "-" + str(nc)
          if matrix.at(nr).at(nc) in zeichen-auto and nk not in gesehen {
            gesehen.insert(nk, true)
            stapel.push((nr, nc))
          }
        }
      }
    }
  }
  zuordnung
}

// ── Vorderseite des Raumes ─────────────────────────────────────────

/// Ermittelt, an welcher Kante des Layouts „vorne" liegt.
/// Ohne Angabe entscheidet die Lage des Pults, sonst gilt `oben`.
#let _vorderseite(matrix, vorne) = {
  if vorne != auto { return vorne }
  let zeilen = matrix.len()
  let spalten = matrix.at(0).len()
  let rs = ()
  let cs = ()
  for r in range(zeilen) {
    for c in range(spalten) {
      if ist-pult(matrix.at(r).at(c)) {
        rs.push(r)
        cs.push(c)
      }
    }
  }
  if rs.len() == 0 { return "oben" }
  let d-oben = calc.min(..rs)
  let d-unten = zeilen - 1 - calc.max(..rs)
  let d-links = calc.min(..cs)
  let d-rechts = spalten - 1 - calc.max(..cs)
  let m = calc.min(d-oben, d-unten, d-links, d-rechts)
  if m == d-oben { "oben" } else if m == d-unten { "unten" } else if m == d-links { "links" } else { "rechts" }
}

// ── Hauptfunktion ──────────────────────────────────────────────────

/// Analysiert ein Layout und liefert alle Informationen, die der
/// Optimierer und die Bewertung brauchen.
///
/// - layout (str): Layout-String des Raumes.
/// - vorne (auto, str): Vorderseite: `auto` (aus Pultlage), `"oben"`,
///   `"unten"`, `"links"` oder `"rechts"`.
/// - perspektive (str): `"schueler"` – links/rechts aus Sicht der nach vorne
///   blickenden Klasse (Standard), oder `"plan"` – wie gezeichnet.
/// -> dictionary
#let plaetze-analysieren(layout, vorne: auto, perspektive: "schueler") = {
  let matrix = layout-matrix(layout)
  if matrix.len() == 0 { panic("typlace: Das Layout enthält keine Zeilen.") }
  let zeilen = matrix.len()
  let spalten = matrix.at(0).len()

  let auto-zuordnung = _auto-tische(matrix)
  let seite = _vorderseite(matrix, vorne)

  // Sitzplätze in Lesereihenfolge (links→rechts, oben→unten).
  // Der Index ist zugleich die Position im `namen`-Array von typlace().
  let roh = ()
  for r in range(zeilen) {
    for c in range(spalten) {
      let ch = matrix.at(r).at(c)
      if not ist-platz(ch) { continue }
      let tisch = if ch in zeichen-auto {
        auto-zuordnung.at(str(r) + "-" + str(c))
      } else {
        "tisch-" + ch
      }
      roh.push((index: roh.len(), zeile: r, spalte: c, zeichen: ch, tisch: tisch))
    }
  }
  if roh.len() == 0 { panic("typlace: Das Layout enthält keine Sitzplätze.") }

  // ── Zonen ────────────────────────────────────────────────────────
  //
  //  Tiefe: vorne / mitte / hinten – Abstand zur Vorderseite des Raumes
  //  Seite: links / mitte / rechts – quer dazu
  //
  //  Die Seite wird standardmäßig aus *Schülersicht* bestimmt (Blick nach
  //  vorne), nicht aus Sicht des gezeichneten Plans. Sitzt das Pult unten
  //  im Layout, ist „links" für die Schüler also die rechte Seite des
  //  Ausdrucks. Mit `perspektive: "plan"` wird stattdessen die
  //  Zeichenrichtung verwendet.
  let tiefe-wert(p) = {
    if seite == "oben" { p.zeile } else if seite == "unten" { zeilen - 1 - p.zeile } else if seite == "links" {
      p.spalte
    } else { spalten - 1 - p.spalte }
  }
  let quer-wert(p) = {
    if perspektive == "plan" {
      if seite in ("oben", "unten") { p.spalte } else { p.zeile }
    } else if seite == "oben" {
      p.spalte
    } else if seite == "unten" {
      spalten - 1 - p.spalte
    } else if seite == "links" {
      zeilen - 1 - p.zeile
    } else {
      p.zeile
    }
  }

  // Die Zonen gelten für den *Gruppentisch als Ganzes*: ein Tisch liegt
  // vorne, in der Mitte oder hinten – nicht seine einzelnen Sitzreihen.
  // Sonst läge ein Blocktisch mit Kopfplätzen in zwei Zonen gleichzeitig.
  let tisch-mittel(wert-fn) = {
    let summe = (:)
    let anzahl = (:)
    for p in roh {
      summe.insert(p.tisch, summe.at(p.tisch, default: 0) + wert-fn(p))
      anzahl.insert(p.tisch, anzahl.at(p.tisch, default: 0) + 1)
    }
    let mittel = (:)
    for (t, w) in summe { mittel.insert(t, calc.round(w / anzahl.at(t), digits: 3)) }
    mittel
  }

  // Verteilt die Tische auf drei Bänder. Bei nur zwei Tischreihen gibt es
  // kein Mittelband, bei einer einzigen liegen alle in der Mitte.
  let baender(mittel, namen) = {
    let werte = mittel.values().dedup().sorted()
    let k = werte.len()
    let band-von-wert = (:)
    for (i, w) in werte.enumerate() {
      let name = if k == 1 {
        namen.at(1)
      } else if k == 2 {
        namen.at(if i == 0 { 0 } else { 2 })
      } else {
        namen.at(calc.min(2, calc.floor(i * 3 / k)))
      }
      band-von-wert.insert(str(w), name)
    }
    let je-tisch = (:)
    for (t, w) in mittel { je-tisch.insert(t, band-von-wert.at(str(w))) }
    je-tisch
  }

  let tiefe-zone = baender(tisch-mittel(tiefe-wert), ("vorne", "mitte", "hinten"))
  let quer-zone = baender(tisch-mittel(quer-wert), ("links", "mitte", "rechts"))

  let plaetze = roh.map(p => (
    index: p.index,
    zeile: p.zeile,
    spalte: p.spalte,
    zeichen: p.zeichen,
    tisch: p.tisch,
    abstand: tiefe-wert(p),
    zone: (tiefe: tiefe-zone.at(p.tisch), seite: quer-zone.at(p.tisch)),
  ))

  // Tische → Plätze
  let tische = (:)
  for p in plaetze {
    tische.insert(p.tisch, tische.at(p.tisch, default: ()) + (p.index,))
  }

  // Beziehungsmatrix
  //   "direkt" – am selben Tisch und unmittelbar benachbart
  //              (nebeneinander, gegenüber oder über Eck)
  //   "tisch"  – am selben Gruppentisch, aber weiter entfernt
  //   "fern"   – an verschiedenen Tischen
  let n = plaetze.len()
  let beziehung = range(n).map(i => range(n).map(j => {
    if i == j {
      "selbst"
    } else if plaetze.at(i).tisch != plaetze.at(j).tisch {
      "fern"
    } else {
      let dr = plaetze.at(i).zeile - plaetze.at(j).zeile
      let dc = plaetze.at(i).spalte - plaetze.at(j).spalte
      if dr * dr + dc * dc <= 2 { "direkt" } else { "tisch" }
    }
  }))

  (
    matrix: matrix,
    zeilen: zeilen,
    spalten: spalten,
    vorne: seite,
    plaetze: plaetze,
    tische: tische,
    zonen: (
      tiefe: plaetze.map(p => p.zone.tiefe).dedup(),
      seite: plaetze.map(p => p.zone.seite).dedup(),
    ),
    beziehung: beziehung,
  )
}

/// Liefert die Zellen, die als Tischkörper (Fläche eines Gruppentisches)
/// gezeichnet werden sollen: freie Zellen, die auf zwei gegenüber-
/// liegenden Seiten an Sitzplätze *desselben* Tisches grenzen.
#let koerper-zellen(geo) = {
  let tisch-an = (:)
  for p in geo.plaetze { tisch-an.insert(str(p.zeile) + "-" + str(p.spalte), p.tisch) }

  let treffer = (:)
  for r in range(geo.zeilen) {
    for c in range(geo.spalten) {
      let ch = geo.matrix.at(r).at(c)
      if ist-koerper(ch) {
        treffer.insert(str(r) + "-" + str(c), true)
        continue
      }
      if not ist-frei(ch) { continue }
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
