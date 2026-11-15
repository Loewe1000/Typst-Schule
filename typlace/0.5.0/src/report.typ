// ═══════════════════════════════════════════════════════════════════
//  Bericht: nachvollziehbar machen, wie gut der Plan passt
// ═══════════════════════════════════════════════════════════════════

#import "internal/check.typ": check-named, check-type, check-positional

// Zonen heißen in den Daten englisch, im Bericht deutsch.
#let _zonen-namen = (front: "vorne", middle: "mitte", back: "hinten", left: "links", right: "rechts")

/// Kurze Kennzahlenzeile zu einer Sitzordnung: erfüllte Wünsche,
/// Positionswünsche und Punktzahl.
///
/// - plan (dictionary): Ergebnis von `sitzordnung()`.
/// -> content
#let seating-summary(plan) = {
  check-type("typlace", "seating-summary", "plan", plan, dictionary, example: "sitzordnung(layout, wishes)")
  let s = plan.statistics
  let prozent = calc.round(s.rate * 100)
  [
    *#s.wishes-fulfilled von #s.wishes-total Wünschen erfüllt (#prozent %)* ·
    #s.all-fulfilled.len() Schüler mit allen Wünschen ·
    #s.unfulfilled.len() ohne jeden Wunsch ·
    Positionswünsche #s.position-fulfilled von #s.position-total ·
    #plan.points-rounded Punkte
  ]
}

/// Kreuztabelle: wie viele Schüler haben von ihren genannten Wünschen wie
/// viele bekommen? Eine Reihe je Anzahl genannter Wünsche, damit sich
/// „drei von drei“ und „einer von einem“ nicht vermischen.
///
/// Hervorgehoben sind die beiden Ränder: fett, wer alles bekommen hat, rot,
/// wer leer ausging.
/// -> content
#let _verteilungstabelle(distribution) = {
  if distribution.len() == 0 { return none }

  let reihen = distribution.pairs().map(p => (int(p.at(0)), p.at(1))).sorted(key: x => x.at(0))
  let breite = calc.max(..reihen.map(x => x.at(0)))

  let zelle(genannt, fulfilled, anzahl) = {
    if fulfilled > genannt {
      []
    } else if anzahl == 0 {
      text(fill: luma(75%))[·]
    } else if fulfilled == genannt {
      strong[#anzahl]
    } else if fulfilled == 0 {
      text(fill: rgb("#a03020"))[#anzahl]
    } else {
      [#anzahl]
    }
  }

  let leer-ausgegangen = reihen.any(r => r.at(1).at(0, default: 0) > 0)

  table(
    columns: (auto,) + (1.6em,) * (breite + 1),
    stroke: none,
    inset: 3pt,
    align: (right,) + (center,) * (breite + 1),
    text(size: 0.85em, fill: luma(40%))[davon erfüllt:],
    ..range(breite + 1).map(e => text(size: 0.85em, fill: luma(40%))[#e]),
    ..reihen
      .map(r => {
        let genannt = r.at(0)
        let zahlen = r.at(1)
        let kopf = ([#genannt #if genannt == 1 [Wunsch] else [Wünsche] genannt],)
        kopf + range(breite + 1).map(e => zelle(genannt, e, zahlen.at(e, default: 0)))
      })
      .flatten()
  )
}

/// Ausführlicher Bericht zu einer Sitzordnung: je Schüler, welche Wünsche
/// erfüllt sind und welche nicht, dazu alle Auffälligkeiten.
///
/// - plan (dictionary): Ergebnis von `sitzordnung()`.
/// - details (bool): Tabelle je Schüler ausgeben.
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> content
#let seating-report(plan, details: true, ..deprecated) = {
  check-positional("typlace", "seating-report", deprecated, hint: "nur der Plan steht vorn – `details: false` benannt schreiben")
  check-named("typlace", "seating-report", deprecated, allowed: ("details",))
  check-type("typlace", "seating-report", "plan", plan, dictionary, example: "sitzordnung(layout, wishes)")
  check-type("typlace", "seating-report", "details", details, bool)
  let k = plan.problem
  let s = plan.statistics
  let name-von(i) = k.students.at(i).name
  let prozent = calc.round(s.rate * 100)

  block(
    width: 100%,
    inset: 8pt,
    radius: 3pt,
    fill: luma(96%),
    [
      *Auswertung der Sitzordnung* (#plan.attempts Versuche,
      #plan.steps Verbesserungen aus #plan.checked geprüften Tauschen#if "duration" in plan and plan.duration != none [, #plan.duration])

      #table(
        columns: 2,
        stroke: none,
        inset: 3pt,
        [Erfüllte Wünsche], [#s.wishes-fulfilled von #s.wishes-total (#prozent %)],
        [Schüler mit allen Wünschen], [#s.all-fulfilled.len()],
        [Schüler ohne jeden Wunsch],
        [#if s.unfulfilled.len() == 0 { [keiner] } else { s.unfulfilled.join(", ") }],

        [Positionswünsche], [#s.position-fulfilled von #s.position-total erfüllt],

        ..if s.rejections-violated.len() > 0 {
          (
            [Abgelehnte Nachbarn],
            [#s.rejections-violated.map(paar => paar.at(0) + " neben " + paar.at(1)).join("; ")],
          )
        } else { () },
        ..if s.position-impossible.len() > 0 {
          (
            [Im Raum nicht möglich],
            [#s.position-impossible.map(u => u.name + " wünscht „" + _zonen-namen.at(u.zone, default: u.zone) + "“").join("; ")],
          )
        } else { () }
      )

      #v(0.3em)
      #_verteilungstabelle(s.distribution)
    ],
  )

  if plan.notes.len() > 0 {
    block(
      width: 100%,
      inset: 8pt,
      radius: 3pt,
      fill: rgb("#fff6e0"),
      [*Hinweise zur Wunschliste* #list(..plan.notes.map(h => [#h]))],
    )
  }

  if not details { return }

  let rows = ()
  for (i, d) in plan.details.enumerate() {
    let wishes = k.wishes.at(i)
    if wishes.len() == 0 and k.rejections.at(i).len() == 0 { continue }
    let fulfilled = d.fulfilled.map(e => e.student)
    let offen = wishes.filter(w => w not in fulfilled)
    rows.push((
      name-von(i),
      str(d.fulfilled.len()) + " / " + str(wishes.len()),
      if fulfilled.len() == 0 { "–" } else { fulfilled.map(name-von).join(", ") },
      if offen.len() == 0 { "–" } else { offen.map(name-von).join(", ") },
    ))
  }

  table(
    columns: (auto, auto, 1fr, 1fr),
    inset: 4pt,
    align: (left, center, left, left),
    stroke: 0.4pt + luma(70%),
    table.header([*Schüler*], [*erfüllt*], [*sitzt bei*], [*offen*]),
    ..rows.flatten().map(x => [#x])
  )
}
