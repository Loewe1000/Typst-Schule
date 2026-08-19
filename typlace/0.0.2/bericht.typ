// ═══════════════════════════════════════════════════════════════════
//  Bericht: nachvollziehbar machen, wie gut der Plan passt
// ═══════════════════════════════════════════════════════════════════

/// Kurze Kennzahlenzeile zu einem Plan.
/// -> content
#let sitzplan-kennzahlen(plan) = {
  let s = plan.statistik
  let prozent = calc.round(s.quote * 100)
  [
    *#s.wuensche-erfuellt von #s.wuensche-gesamt Wünschen erfüllt (#prozent %)* ·
    #s.alle-erfuellt.len() Schüler mit allen Wünschen ·
    #s.ohne-wunsch.len() ohne jeden Wunsch ·
    Positionswünsche #s.position-erfuellt von #s.position-gesamt ·
    #plan.punkte-gerundet Punkte
  ]
}

/// Kreuztabelle: wie viele Schüler haben von ihren genannten Wünschen wie
/// viele bekommen? Eine Reihe je Anzahl genannter Wünsche, damit sich
/// „drei von drei“ und „einer von einem“ nicht vermischen.
///
/// Hervorgehoben sind die beiden Ränder: fett, wer alles bekommen hat, rot,
/// wer leer ausging.
/// -> content
#let _verteilungstabelle(verteilung) = {
  if verteilung.len() == 0 { return none }

  let reihen = verteilung.pairs().map(p => (int(p.at(0)), p.at(1))).sorted(key: x => x.at(0))
  let breite = calc.max(..reihen.map(x => x.at(0)))

  let zelle(genannt, erfuellt, anzahl) = {
    if erfuellt > genannt {
      []
    } else if anzahl == 0 {
      text(fill: luma(75%))[·]
    } else if erfuellt == genannt {
      strong[#anzahl]
    } else if erfuellt == 0 {
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
/// -> content
#let sitzplan-bericht(plan, details: true) = {
  let k = plan.kontext
  let s = plan.statistik
  let name-von(i) = k.schueler.at(i).name
  let prozent = calc.round(s.quote * 100)

  block(
    width: 100%,
    inset: 8pt,
    radius: 3pt,
    fill: luma(96%),
    [
      *Auswertung der Sitzordnung* (#plan.versuche Versuche,
      #plan.schritte Verbesserungen aus #plan.geprueft geprüften Tauschen#if "dauer" in plan and plan.dauer != none [, #plan.dauer])

      #table(
        columns: 2,
        stroke: none,
        inset: 3pt,
        [Erfüllte Wünsche], [#s.wuensche-erfuellt von #s.wuensche-gesamt (#prozent %)],
        [Schüler mit allen Wünschen], [#s.alle-erfuellt.len()],
        [Schüler ohne jeden Wunsch],
        [#if s.ohne-wunsch.len() == 0 { [keiner] } else { s.ohne-wunsch.join(", ") }],

        [Positionswünsche], [#s.position-erfuellt von #s.position-gesamt erfüllt],

        ..if s.ablehnungen-verletzt.len() > 0 {
          (
            [Abgelehnte Nachbarn],
            [#s.ablehnungen-verletzt.map(paar => paar.at(0) + " neben " + paar.at(1)).join("; ")],
          )
        } else { () },
        ..if s.position-unerfuellbar.len() > 0 {
          (
            [Im Raum nicht möglich],
            [#s.position-unerfuellbar.map(u => u.name + " wünscht „" + u.zone + "“").join("; ")],
          )
        } else { () }
      )

      #v(0.3em)
      #_verteilungstabelle(s.verteilung)
    ],
  )

  if plan.hinweise.len() > 0 {
    block(
      width: 100%,
      inset: 8pt,
      radius: 3pt,
      fill: rgb("#fff6e0"),
      [*Hinweise zur Wunschliste* #list(..plan.hinweise.map(h => [#h]))],
    )
  }

  if not details { return }

  let zeilen = ()
  for (i, d) in plan.details.enumerate() {
    let wuensche = k.wuensche.at(i)
    if wuensche.len() == 0 and k.ablehnungen.at(i).len() == 0 { continue }
    let erfuellt = d.erfuellt.map(e => e.schueler)
    let offen = wuensche.filter(w => w not in erfuellt)
    zeilen.push((
      name-von(i),
      str(d.erfuellt.len()) + " / " + str(wuensche.len()),
      if erfuellt.len() == 0 { "–" } else { erfuellt.map(name-von).join(", ") },
      if offen.len() == 0 { "–" } else { offen.map(name-von).join(", ") },
    ))
  }

  table(
    columns: (auto, auto, 1fr, 1fr),
    inset: 4pt,
    align: (left, center, left, left),
    stroke: 0.4pt + luma(70%),
    table.header([*Schüler*], [*erfüllt*], [*sitzt bei*], [*offen*]),
    ..zeilen.flatten().map(x => [#x])
  )
}
