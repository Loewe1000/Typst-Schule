// ═══════════════════════════════════════════════════════════════════
//  Bewertung: Wie gut passt eine Sitzverteilung zu den Wünschen?
// ═══════════════════════════════════════════════════════════════════

#import "internal/check.typ": fail

/// Standardgewichte der Bewertung. Einzelne Werte ändert
/// `sitzordnung(weights: (…))`.
///
/// - `adjacent`, `table`: Wert eines erfüllten Wunsches, je nachdem ob die
///   Wunschperson unmittelbar benachbart sitzt (nebeneinander, gegenüber
///   oder über Eck) oder am selben Gruppentisch weiter entfernt.
///   Der kleine Unterschied wirkt nur als Stichentscheid zwischen sonst
///   gleichwertigen Plänen.
/// - `ranks`: Gewicht von 1., 2. und 3. Wunsch – standardmäßig gleichwertig.
/// - `tiers`: Wert des ersten, zweiten und dritten *erfüllten* Wunsches eines
///   Schülers. Weil die Werte fallen, ist eine Sitzordnung, in der alle zwei
///   von drei Wünschen bekommen, mehr wert als eine, in der die einen drei und
///   die anderen einen bekommen. `(1.0, 1.0, 1.0)` schaltet das ab und zählt
///   nur die Gesamtzahl.
/// - `wish-count`: Faktor auf die Wunschpunkte je nachdem, wie viele Namen ein
///   Schüler *genannt* hat – einen, zwei, drei oder mehr. Der Gedanke: wer nur
///   einen Namen nennt, hat keine zweite Chance.
///
///   Standardmäßig aus, weil der Fairness-Bonus das schon leistet – er gilt je
///   Schüler einmal, unabhängig von der Länge seiner Liste. An einer echten
///   Klasse gemessen bekam das einzige Kind mit nur einem Wunsch diesen in
///   jeder Einstellung und bei jedem Seed; `(1.3, 1.15, 1.0)` kostete dafür im
///   Mittel anderthalb erfüllte Wünsche anderswo. Wer es dennoch will:
///   `weights: (wish-count: (1.3, 1.15, 1.0))`.
/// - `fairness`: Einmalbonus dafür, dass ein Schüler *überhaupt* einen
///   Wunsch erfüllt bekommt. Verhindert, dass wenige Schüler alle Wünsche
///   bekommen und andere leer ausgehen.
/// - `rejection`: Abzug, wenn eine abgelehnte Person am selben Tisch sitzt.
/// - `constraint`: Abzug für eine verletzte Vorgabe (`apart`, `together`). So
///   groß, dass die Suche solche Pläne immer verlässt; bleibt am Ende doch
///   eine Verletzung übrig, sind die Vorgaben nicht erfüllbar.
/// - `position`: Bonus je erfüllter Positionsachse (Tiefe vorne/mitte/hinten,
///   Seite links/mitte/rechts).
/// - `position-avoided`: Abzug je ausdrücklich gemiedener Zone (in der
///   Wunschliste z. B. `!mitte`), die doch zugeteilt wird.
#let default-weights = (
  adjacent: 1.0,
  table: 0.9,
  ranks: (1.0, 1.0, 1.0),
  tiers: (1.0, 0.7, 0.45),
  wish-count: (1.0, 1.0, 1.0),
  fairness: 2.0,
  rejection: -2.0,
  constraint: -1000.0,
  position: 0.5,
  position-avoided: -0.5,
)

/// Nimmt auch ein leeres Array als „keine Vorgaben" entgegen: wer alle
/// Einträge auskommentiert, schreibt in Typst versehentlich `()` statt `(:)`.
#let normalize-constraints(constraints, caller: "sitzordnung") = {
  if type(constraints) == dictionary { return constraints }
  if type(constraints) == array and constraints.len() == 0 { return (:) }
  fail(
    "typlace",
    caller,
    "`constraints` erwartet ein Dictionary, bekam `" + str(type(constraints)) + "` – zum Beispiel `(apart: ((\"A\", \"B\"),))` oder `(:)` für keine Vorgaben",
  )
}

/// Bereitet Schülerdaten und Geometrie für die Bewertung auf.
///
/// Wandelt alle Namen in Indizes um und legt Rückwärtskanten an
/// (wer hat *mich* gewünscht), damit der Optimierer nach einem Platztausch
/// nur die tatsächlich betroffenen Schüler neu bewerten muss.
///
/// -> dictionary
#let build-problem(geometry, students, weights: (:), constraints: (:), position-share: auto) = {
  let g = default-weights + weights
  let constraints = normalize-constraints(constraints)

  let index-of = (:)
  for (i, s) in students.enumerate() { index-of.insert(s.name, i) }

  let n = students.len()
  let wishes = students.map(s => s.at("wishes", default: ()).map(w => index-of.at(w)))
  let rejections = students.map(s => s.at("rejections", default: ()).map(w => index-of.at(w)))

  // Positionsgewicht aus dem gewünschten Anteil herleiten.
  //
  // Gefragt ist „wie viel Prozent der erreichbaren Punkte sollen aus
  // Positionswünschen kommen". Dafür wird der höchstmögliche soziale Ertrag
  // der Klasse ausgerechnet (alle Wünsche direkt erfüllt, jeder mit
  // Fairness-Bonus) und das Positionsgewicht so gesetzt, dass die
  // Positionsterme genau den gewünschten Anteil daran ausmachen.
  if position-share != auto {
    let anteil = if type(position-share) == ratio { position-share / 100% } else { float(position-share) }
    if anteil < 0 or anteil >= 1 {
      fail(
        "typlace",
        "sitzordnung",
        "`position-share` muss zwischen `0%` und `100%` liegen (`100%` selbst nicht, sonst zählten Wünsche gar nicht mehr) – zum Beispiel `20%`",
      )
    }

    let sozial-max = 0.0
    for ws in wishes {
      for rang in range(ws.len()) {
        let rg = if rang < g.ranks.len() { g.ranks.at(rang) } else { g.ranks.last() }
        // Die fallenden Stufen gehören in den Höchstwert, sonst stimmt der
        // eingestellte Prozentsatz nicht mehr.
        let stufe = if rang < g.tiers.len() { g.tiers.at(rang) } else { g.tiers.last() }
        sozial-max += rg * stufe * g.adjacent
      }
      if ws.len() > 0 { sozial-max += g.fairness }
    }

    let positions-terme = 0
    for s in students {
      for axis in ("depth", "side") {
        if s.at("position", default: (:)).at(axis, default: none) != none { positions-terme += 1 }
        positions-terme += s.at("position-avoided", default: (:)).at(axis, default: ()).len()
      }
    }

    if positions-terme > 0 and sozial-max > 0 {
      let value = if anteil == 0 { 0.0 } else { anteil / (1 - anteil) * sozial-max / positions-terme }
      g.insert("position", value)
      g.insert("position-avoided", -value)
    }
  }

  // Harte Vorgaben der Lehrkraft: Paare, die (nicht) an denselben
  // Gruppentisch dürfen. Beidseitig eingetragen.
  let paare(schluessel) = {
    let liste = range(n).map(_ => ())
    for paar in constraints.at(schluessel, default: ()) {
      let a = index-of.at(paar.at(0), default: none)
      let b = index-of.at(paar.at(1), default: none)
      if a == none or b == none {
        fail(
          "typlace",
          "sitzordnung",
          "die Vorgabe `" + schluessel + "` nennt einen unbekannten Namen: " + paar.map(str).join(" / ") + " – Namen wie in der Wunschliste schreiben",
        )
      }
      liste.at(a) = (liste.at(a) + (b,)).dedup()
      liste.at(b) = (liste.at(b) + (a,)).dedup()
    }
    liste
  }
  let apart = paare("apart")
  let together = paare("together")

  // Rückwärtskanten: Schüler, deren Punktzahl sich ändert,
  // wenn Schüler i den Platz wechselt.
  let reverse = range(n).map(_ => ())
  for (i, liste) in wishes.enumerate() {
    for w in liste {
      reverse.at(w) = reverse.at(w) + (i,)
    }
  }
  for source in (rejections, apart, together) {
    for (i, liste) in source.enumerate() {
      for w in liste {
        if i not in reverse.at(w) { reverse.at(w) = reverse.at(w) + (i,) }
      }
    }
  }

  (
    geometry: geometry,
    students: students,
    index-of: index-of,
    wishes: wishes,
    rejections: rejections,
    apart: apart,
    together: together,
    reverse: reverse,
    weights: g,
    student-count: n,
    seat-count: geometry.seats.len(),
  )
}

/// Faktor für einen Schüler, der `anzahl` Namen genannt hat.
#let _wunschzahl-faktor(g, anzahl) = {
  let tabelle = g.at("wish-count", default: (1.0,))
  if anzahl <= 0 { return 1.0 }
  if anzahl <= tabelle.len() { tabelle.at(anzahl - 1) } else { tabelle.last() }
}

/// Wert einer Beziehung zwischen zwei Plätzen: `direkt`, `tisch` oder 0.
#let _beziehungswert(problem, p, q) = {
  let kind = problem.geometry.relations.at(p).at(q)
  if kind == "adjacent" { problem.weights.adjacent } else if kind == "table" { problem.weights.table } else { 0.0 }
}

/// Punkte eines einzelnen Schülers bei gegebener Platzbelegung.
///
/// - seat-of (array): Für jeden Schülerindex der Platzindex (oder `none`).
/// -> dictionary
#let student-score(problem, seat-of, i) = {
  let leer = (
    points: 0.0,
    position-points: 0.0,
    fulfilled: (),
    violated: (),
    position: 0,
    position-violated: 0,
    constraints-violated: 0,
  )
  let p = seat-of.at(i)
  if p == none { return leer }

  let g = problem.weights
  let summe = 0.0
  let sozial = 0.0
  let fulfilled = ()
  let violated = ()

  for (rang, w) in problem.wishes.at(i).enumerate() {
    let q = seat-of.at(w)
    if q == none { continue }
    let value = _beziehungswert(problem, p, q)
    if value <= 0.0 { continue }
    let rg = if rang < g.ranks.len() { g.ranks.at(rang) } else { g.ranks.last() }
    // Jeder weitere erfüllte Wunsch desselben Schülers zählt weniger
    let stufe = if fulfilled.len() < g.tiers.len() { g.tiers.at(fulfilled.len()) } else { g.tiers.last() }
    let points = rg * value * stufe
    sozial += points
    fulfilled.push((student: w, kind: problem.geometry.relations.at(p).at(q), points: points))
  }
  if fulfilled.len() > 0 { sozial += g.fairness }
  summe += _wunschzahl-faktor(g, problem.wishes.at(i).len()) * sozial

  for a in problem.rejections.at(i) {
    let q = seat-of.at(a)
    if q == none { continue }
    let value = _beziehungswert(problem, p, q)
    if value <= 0.0 { continue }
    summe += g.rejection * value
    violated.push((student: a, kind: problem.geometry.relations.at(p).at(q), points: g.rejection * value))
  }

  // Harte Vorgaben: verletzte Paarbedingungen kosten so viel, dass die
  // Suche jeden zulässigen Plan vorzieht.
  let tisch-von(x) = problem.geometry.seats.at(x).table
  let constraints-violated = 0
  for x in problem.at("apart", default: ()).at(i, default: ()) {
    let q = seat-of.at(x)
    if q != none and tisch-von(p) == tisch-von(q) { constraints-violated += 1 }
  }
  for x in problem.at("together", default: ()).at(i, default: ()) {
    let q = seat-of.at(x)
    if q != none and tisch-von(p) != tisch-von(q) { constraints-violated += 1 }
  }
  summe += constraints-violated * g.constraint

  // Positionswünsche auf beiden Achsen: Tiefe (vorne/mitte/hinten)
  // und Seite (links/mitte/rechts), jeweils gewünscht oder gemieden.
  let zone = problem.geometry.seats.at(p).zone
  let s-i = problem.students.at(i)
  let wunsch-pos = s-i.at("position", default: (:))
  let meidet = s-i.at("position-avoided", default: (:))
  let pos-ok = 0
  let pos-verletzt = 0
  let pos-punkte = 0.0

  for axis in ("depth", "side") {
    let hier = zone.at(axis)
    if wunsch-pos.at(axis, default: none) == hier {
      pos-ok += 1
      pos-punkte += g.position
    }
    if hier in meidet.at(axis, default: ()) {
      pos-verletzt += 1
      pos-punkte += g.position-avoided
    }
  }

  summe += pos-punkte

  (
    points: summe,
    position-points: pos-punkte,
    fulfilled: fulfilled,
    violated: violated,
    position: pos-ok,
    position-violated: pos-verletzt,
    constraints-violated: constraints-violated,
  )
}

/// Punktzahl eines Schülers – nur die Zahl, ohne Detailangaben.
///
/// Inhaltlich identisch mit `student-score`, aber ohne die Listen für den
/// Bericht. Der Optimierer ruft das hunderttausendfach auf, und das Anlegen
/// der Arrays kostet dort mehr als die eigentliche Rechnung.
#let student-points(problem, seat-of, i) = {
  let p = seat-of.at(i)
  if p == none { return 0.0 }

  let g = problem.weights
  let bez = problem.geometry.relations.at(p)
  let seats = problem.geometry.seats
  let summe = 0.0
  let sozial = 0.0
  let treffer = 0

  for (rang, w) in problem.wishes.at(i).enumerate() {
    let q = seat-of.at(w)
    if q == none { continue }
    let kind = bez.at(q)
    let value = if kind == "adjacent" { g.adjacent } else if kind == "table" { g.table } else { 0.0 }
    if value <= 0.0 { continue }
    let rg = if rang < g.ranks.len() { g.ranks.at(rang) } else { g.ranks.last() }
    let stufe = if treffer < g.tiers.len() { g.tiers.at(treffer) } else { g.tiers.last() }
    sozial += rg * value * stufe
    treffer += 1
  }
  if treffer > 0 { sozial += g.fairness }
  summe += _wunschzahl-faktor(g, problem.wishes.at(i).len()) * sozial

  for a in problem.rejections.at(i) {
    let q = seat-of.at(a)
    if q == none { continue }
    let kind = bez.at(q)
    let value = if kind == "adjacent" { g.adjacent } else if kind == "table" { g.table } else { 0.0 }
    if value > 0.0 { summe += g.rejection * value }
  }

  let table = seats.at(p).table
  for x in problem.apart.at(i) {
    let q = seat-of.at(x)
    if q != none and seats.at(q).table == table { summe += g.constraint }
  }
  for x in problem.together.at(i) {
    let q = seat-of.at(x)
    if q != none and seats.at(q).table != table { summe += g.constraint }
  }

  let zone = seats.at(p).zone
  let s-i = problem.students.at(i)
  let wunsch-pos = s-i.position
  let meidet = s-i.position-avoided
  for axis in ("depth", "side") {
    let hier = zone.at(axis)
    if wunsch-pos.at(axis, default: none) == hier { summe += g.position }
    if hier in meidet.at(axis, default: ()) { summe += g.position-avoided }
  }

  summe
}

/// Wandelt eine Platzbelegung in die Umkehrung Schüler → Platz.
#let seat-of-students(problem, assignment) = {
  let seat-of = range(problem.student-count).map(_ => none)
  for (p, s) in assignment.enumerate() {
    if s != none { seat-of.at(s) = p }
  }
  seat-of
}

/// Bewertet eine vollständige Sitzverteilung.
///
/// - assignment (array): Für jeden Platzindex der Schülerindex oder `none`.
/// -> dictionary
#let score-plan(problem, assignment) = {
  let seat-of = seat-of-students(problem, assignment)
  let details = range(problem.student-count).map(i => student-score(problem, seat-of, i))
  (
    points: details.fold(0.0, (a, d) => a + d.points),
    details: details,
    assignment: assignment,
    seat-of: seat-of,
  )
}

/// Punktedifferenz beim Tausch zweier *Plätze* – ohne den ganzen Plan neu
/// zu bewerten. Der Optimierer prüft damit sehr viele Tausche pro Sekunde.
/// Einer der Plätze darf frei sein; dann zieht der andere Schüler um.
///
/// - p, q (int): die beiden Platzindizes.
/// -> dictionary
#let swap-delta(problem, assignment, seat-of, p, q) = {
  let i = assignment.at(p)
  let j = assignment.at(q)
  if i == none and j == none { return (delta: 0.0, seat-of: seat-of, assignment: assignment) }

  // Betroffen sind die beiden Umziehenden und alle, die einen von ihnen
  // gewünscht, abgelehnt oder als Vorgabe verknüpft haben.
  let betroffen = ()
  for s in (i, j) {
    if s == none { continue }
    if s not in betroffen { betroffen.push(s) }
    for r in problem.reverse.at(s) {
      if r not in betroffen { betroffen.push(r) }
    }
  }

  let vorher = betroffen.fold(0.0, (a, s) => a + student-points(problem, seat-of, s))

  let neu = seat-of
  if i != none { neu.at(i) = q }
  if j != none { neu.at(j) = p }

  let nachher = betroffen.fold(0.0, (a, s) => a + student-points(problem, neu, s))

  let neue-zuordnung = assignment
  neue-zuordnung.at(p) = j
  neue-zuordnung.at(q) = i

  (delta: nachher - vorher, seat-of: neu, assignment: neue-zuordnung)
}

// ── Auswertung ─────────────────────────────────────────────────────

/// Fasst ein Bewertungsergebnis in Kennzahlen zusammen.
/// -> dictionary
#let statistics(problem, ergebnis) = {
  let gesamt = problem.wishes.fold(0, (a, w) => a + w.len())
  let fulfilled = ergebnis.details.fold(0, (a, d) => a + d.fulfilled.len())
  let ohne = ()
  let alle = ()
  let mit-pos = 0
  let pos-gesamt = 0
  let pos-verletzt-gesamt = 0
  let unerfuellbar = ()
  let hart-gesamt = 0
  let punkte-pos = 0.0
  let distribution = (:)
  let violated = ()

  for (i, d) in ergebnis.details.enumerate() {
    let name = problem.students.at(i).name
    if problem.wishes.at(i).len() > 0 and d.fulfilled.len() == 0 { ohne.push(name) }
    if problem.wishes.at(i).len() > 0 and d.fulfilled.len() == problem.wishes.at(i).len() { alle.push(name) }
    let s-i = problem.students.at(i)
    for axis in ("depth", "side") {
      let gewuenscht = s-i.at("position", default: (:)).at(axis, default: none)
      if gewuenscht != none {
        pos-gesamt += 1
        // Wunsch nach einer Zone, die es im Raum gar nicht gibt
        // (z. B. „mitte" bei nur zwei Tischreihen)
        if gewuenscht not in problem.geometry.zones.at(axis) {
          unerfuellbar.push((name: problem.students.at(i).name, zone: gewuenscht))
        }
      }
      pos-gesamt += s-i.at("position-avoided", default: (:)).at(axis, default: ()).len()
    }
    mit-pos += d.position
    pos-verletzt-gesamt += d.position-violated
    hart-gesamt += d.constraints-violated
    punkte-pos += d.position-points
    // Verteilung als Kreuztabelle: je Zahl genannter Wünsche eine Reihe,
    // darin die Anzahl Schüler nach Zahl der erfüllten Wünsche. Der Index
    // im Array ist also die Zahl der erfüllten Wünsche.
    let genannt = problem.wishes.at(i).len()
    if genannt > 0 {
      let schluessel = str(genannt)
      let reihe = distribution.at(schluessel, default: (0,) * (genannt + 1))
      reihe.at(d.fulfilled.len()) += 1
      distribution.insert(schluessel, reihe)
    }
    for v in d.violated {
      violated.push((name, problem.students.at(v.student).name))
    }
  }

  (
    points: ergebnis.points,
    wishes-total: gesamt,
    wishes-fulfilled: fulfilled,
    rate: if gesamt > 0 { fulfilled / gesamt } else { 1.0 },
    all-fulfilled: alle,
    unfulfilled: ohne,
    position-total: pos-gesamt,
    position-fulfilled: mit-pos,
    position-violated: pos-verletzt-gesamt,
    position-impossible: unerfuellbar,
    rejections-violated: violated,
    constraints-violated: hart-gesamt,
    distribution: distribution,
    position-points: punkte-pos,
    wish-points: ergebnis.points - punkte-pos,
  )
}
