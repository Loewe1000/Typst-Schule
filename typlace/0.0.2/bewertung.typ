// ═══════════════════════════════════════════════════════════════════
//  Bewertung: Wie gut passt eine Sitzverteilung zu den Wünschen?
// ═══════════════════════════════════════════════════════════════════

/// Standardgewichte der Bewertung.
///
/// - `direkt`, `tisch`: Wert eines erfüllten Wunsches, je nachdem ob die
///   Wunschperson unmittelbar benachbart sitzt (nebeneinander, gegenüber
///   oder über Eck) oder am selben Gruppentisch weiter entfernt.
///   Der kleine Unterschied wirkt nur als Stichentscheid zwischen sonst
///   gleichwertigen Plänen.
/// - `raenge`: Gewicht von 1., 2. und 3. Wunsch – standardmäßig gleichwertig.
/// - `stufen`: Wert des ersten, zweiten und dritten *erfüllten* Wunsches eines
///   Schülers. Weil die Werte fallen, ist eine Sitzordnung, in der alle zwei
///   von drei Wünschen bekommen, mehr wert als eine, in der die einen drei und
///   die anderen einen bekommen. `(1.0, 1.0, 1.0)` schaltet das ab und zählt
///   nur die Gesamtzahl.
/// - `wunschzahl`: Faktor auf die Wunschpunkte je nachdem, wie viele Namen ein
///   Schüler *genannt* hat – einen, zwei, drei oder mehr. Der Gedanke: wer nur
///   einen Namen nennt, hat keine zweite Chance.
///
///   Standardmäßig aus, weil der Fairness-Bonus das schon leistet – er gilt je
///   Schüler einmal, unabhängig von der Länge seiner Liste. An einer echten
///   Klasse gemessen bekam das einzige Kind mit nur einem Wunsch diesen in
///   jeder Einstellung und bei jedem Seed; `(1.3, 1.15, 1.0)` kostete dafür im
///   Mittel anderthalb erfüllte Wünsche anderswo. Wer es dennoch will:
///   `gewichte: (wunschzahl: (1.3, 1.15, 1.0))`.
/// - `fairness`: Einmalbonus dafür, dass ein Schüler *überhaupt* einen
///   Wunsch erfüllt bekommt. Verhindert, dass wenige Schüler alle Wünsche
///   bekommen und andere leer ausgehen.
/// - `ablehnung`: Abzug, wenn eine abgelehnte Person am selben Tisch sitzt.
/// - `hart`: Abzug für eine verletzte Vorgabe (`getrennt`, `zusammen`). So
///   groß, dass die Suche solche Pläne immer verlässt; bleibt am Ende doch
///   eine Verletzung übrig, sind die Vorgaben nicht erfüllbar.
/// - `position`: Bonus je erfüllter Positionsachse (Tiefe vorne/mitte/hinten,
///   Seite links/mitte/rechts).
/// - `position-meidet`: Abzug je ausdrücklich gemiedener Zone (z. B. `!mitte`),
///   die doch zugeteilt wird.
#let standard-gewichte = (
  direkt: 1.0,
  tisch: 0.9,
  raenge: (1.0, 1.0, 1.0),
  stufen: (1.0, 0.7, 0.45),
  wunschzahl: (1.0, 1.0, 1.0),
  fairness: 2.0,
  ablehnung: -2.0,
  hart: -1000.0,
  position: 0.5,
  position-meidet: -0.5,
)

/// Nimmt auch ein leeres Array als „keine Vorgaben" entgegen: wer alle
/// Einträge auskommentiert, schreibt in Typst versehentlich `()` statt `(:)`.
#let normalisiere-vorgaben(vorgaben) = {
  if type(vorgaben) == dictionary { return vorgaben }
  if type(vorgaben) == array and vorgaben.len() == 0 { return (:) }
  panic("typlace: `vorgaben` muss ein Dictionary sein, z. B. (getrennt: ((\"A\", \"B\"),)) – oder (:) für keine Vorgaben.")
}

/// Bereitet Schülerdaten und Geometrie für die Bewertung auf.
///
/// Wandelt alle Namen in Indizes um und legt Rückwärtskanten an
/// (wer hat *mich* gewünscht), damit der Optimierer nach einem Platztausch
/// nur die tatsächlich betroffenen Schüler neu bewerten muss.
///
/// -> dictionary
#let kontext-erstellen(geo, schueler, gewichte: (:), vorgaben: (:), position-anteil: auto) = {
  let g = standard-gewichte + gewichte
  let vorgaben = normalisiere-vorgaben(vorgaben)

  let index-von = (:)
  for (i, s) in schueler.enumerate() { index-von.insert(s.name, i) }

  let n = schueler.len()
  let wuensche = schueler.map(s => s.at("wuensche", default: ()).map(w => index-von.at(w)))
  let ablehnungen = schueler.map(s => s.at("ablehnungen", default: ()).map(w => index-von.at(w)))

  // Positionsgewicht aus dem gewünschten Anteil herleiten.
  //
  // Gefragt ist „wie viel Prozent der erreichbaren Punkte sollen aus
  // Positionswünschen kommen". Dafür wird der höchstmögliche soziale Ertrag
  // der Klasse ausgerechnet (alle Wünsche direkt erfüllt, jeder mit
  // Fairness-Bonus) und das Positionsgewicht so gesetzt, dass die
  // Positionsterme genau den gewünschten Anteil daran ausmachen.
  if position-anteil != auto {
    let anteil = if type(position-anteil) == ratio { position-anteil / 100% } else { float(position-anteil) }
    if anteil < 0 or anteil >= 1 {
      panic("typlace: position-anteil muss zwischen 0% und 100% liegen (100% selbst nicht, sonst zählten Wünsche gar nicht mehr).")
    }

    let sozial-max = 0.0
    for ws in wuensche {
      for rang in range(ws.len()) {
        let rg = if rang < g.raenge.len() { g.raenge.at(rang) } else { g.raenge.last() }
        // Die fallenden Stufen gehören in den Höchstwert, sonst stimmt der
        // eingestellte Prozentsatz nicht mehr.
        let stufe = if rang < g.stufen.len() { g.stufen.at(rang) } else { g.stufen.last() }
        sozial-max += rg * stufe * g.direkt
      }
      if ws.len() > 0 { sozial-max += g.fairness }
    }

    let positions-terme = 0
    for s in schueler {
      for achse in ("tiefe", "seite") {
        if s.at("position", default: (:)).at(achse, default: none) != none { positions-terme += 1 }
        positions-terme += s.at("position-meidet", default: (:)).at(achse, default: ()).len()
      }
    }

    if positions-terme > 0 and sozial-max > 0 {
      let wert = if anteil == 0 { 0.0 } else { anteil / (1 - anteil) * sozial-max / positions-terme }
      g.insert("position", wert)
      g.insert("position-meidet", -wert)
    }
  }

  // Harte Vorgaben der Lehrkraft: Paare, die (nicht) an denselben
  // Gruppentisch dürfen. Beidseitig eingetragen.
  let paare(schluessel) = {
    let liste = range(n).map(_ => ())
    for paar in vorgaben.at(schluessel, default: ()) {
      let a = index-von.at(paar.at(0), default: none)
      let b = index-von.at(paar.at(1), default: none)
      if a == none or b == none {
        panic("typlace: Vorgabe „" + schluessel + "“ nennt einen unbekannten Namen: " + paar.map(str).join(" / "))
      }
      liste.at(a) = (liste.at(a) + (b,)).dedup()
      liste.at(b) = (liste.at(b) + (a,)).dedup()
    }
    liste
  }
  let getrennt = paare("getrennt")
  let zusammen = paare("zusammen")

  // Rückwärtskanten: Schüler, deren Punktzahl sich ändert,
  // wenn Schüler i den Platz wechselt.
  let rueckwaerts = range(n).map(_ => ())
  for (i, liste) in wuensche.enumerate() {
    for w in liste {
      rueckwaerts.at(w) = rueckwaerts.at(w) + (i,)
    }
  }
  for quelle in (ablehnungen, getrennt, zusammen) {
    for (i, liste) in quelle.enumerate() {
      for w in liste {
        if i not in rueckwaerts.at(w) { rueckwaerts.at(w) = rueckwaerts.at(w) + (i,) }
      }
    }
  }

  (
    geo: geo,
    schueler: schueler,
    index-von: index-von,
    wuensche: wuensche,
    ablehnungen: ablehnungen,
    getrennt: getrennt,
    zusammen: zusammen,
    rueckwaerts: rueckwaerts,
    gewichte: g,
    anzahl-schueler: n,
    anzahl-plaetze: geo.plaetze.len(),
  )
}

/// Faktor für einen Schüler, der `anzahl` Namen genannt hat.
#let _wunschzahl-faktor(g, anzahl) = {
  let tabelle = g.at("wunschzahl", default: (1.0,))
  if anzahl <= 0 { return 1.0 }
  if anzahl <= tabelle.len() { tabelle.at(anzahl - 1) } else { tabelle.last() }
}

/// Wert einer Beziehung zwischen zwei Plätzen: `direkt`, `tisch` oder 0.
#let _beziehungswert(kontext, p, q) = {
  let art = kontext.geo.beziehung.at(p).at(q)
  if art == "direkt" { kontext.gewichte.direkt } else if art == "tisch" { kontext.gewichte.tisch } else { 0.0 }
}

/// Punkte eines einzelnen Schülers bei gegebener Platzbelegung.
///
/// - platz-von (array): Für jeden Schülerindex der Platzindex (oder `none`).
/// -> dictionary
#let punkte-schueler(kontext, platz-von, i) = {
  let leer = (
    punkte: 0.0,
    punkte-position: 0.0,
    erfuellt: (),
    verletzt: (),
    position: 0,
    position-verletzt: 0,
    hart-verletzt: 0,
  )
  let p = platz-von.at(i)
  if p == none { return leer }

  let g = kontext.gewichte
  let summe = 0.0
  let sozial = 0.0
  let erfuellt = ()
  let verletzt = ()

  for (rang, w) in kontext.wuensche.at(i).enumerate() {
    let q = platz-von.at(w)
    if q == none { continue }
    let wert = _beziehungswert(kontext, p, q)
    if wert <= 0.0 { continue }
    let rg = if rang < g.raenge.len() { g.raenge.at(rang) } else { g.raenge.last() }
    // Jeder weitere erfüllte Wunsch desselben Schülers zählt weniger
    let stufe = if erfuellt.len() < g.stufen.len() { g.stufen.at(erfuellt.len()) } else { g.stufen.last() }
    let punkte = rg * wert * stufe
    sozial += punkte
    erfuellt.push((schueler: w, art: kontext.geo.beziehung.at(p).at(q), punkte: punkte))
  }
  if erfuellt.len() > 0 { sozial += g.fairness }
  summe += _wunschzahl-faktor(g, kontext.wuensche.at(i).len()) * sozial

  for a in kontext.ablehnungen.at(i) {
    let q = platz-von.at(a)
    if q == none { continue }
    let wert = _beziehungswert(kontext, p, q)
    if wert <= 0.0 { continue }
    summe += g.ablehnung * wert
    verletzt.push((schueler: a, art: kontext.geo.beziehung.at(p).at(q), punkte: g.ablehnung * wert))
  }

  // Harte Vorgaben: verletzte Paarbedingungen kosten so viel, dass die
  // Suche jeden zulässigen Plan vorzieht.
  let tisch-von(x) = kontext.geo.plaetze.at(x).tisch
  let hart-verletzt = 0
  for x in kontext.at("getrennt", default: ()).at(i, default: ()) {
    let q = platz-von.at(x)
    if q != none and tisch-von(p) == tisch-von(q) { hart-verletzt += 1 }
  }
  for x in kontext.at("zusammen", default: ()).at(i, default: ()) {
    let q = platz-von.at(x)
    if q != none and tisch-von(p) != tisch-von(q) { hart-verletzt += 1 }
  }
  summe += hart-verletzt * g.hart

  // Positionswünsche auf beiden Achsen: Tiefe (vorne/mitte/hinten)
  // und Seite (links/mitte/rechts), jeweils gewünscht oder gemieden.
  let zone = kontext.geo.plaetze.at(p).zone
  let s-i = kontext.schueler.at(i)
  let wunsch-pos = s-i.at("position", default: (:))
  let meidet = s-i.at("position-meidet", default: (:))
  let pos-ok = 0
  let pos-verletzt = 0
  let pos-punkte = 0.0

  for achse in ("tiefe", "seite") {
    let hier = zone.at(achse)
    if wunsch-pos.at(achse, default: none) == hier {
      pos-ok += 1
      pos-punkte += g.position
    }
    if hier in meidet.at(achse, default: ()) {
      pos-verletzt += 1
      pos-punkte += g.position-meidet
    }
  }

  summe += pos-punkte

  (
    punkte: summe,
    punkte-position: pos-punkte,
    erfuellt: erfuellt,
    verletzt: verletzt,
    position: pos-ok,
    position-verletzt: pos-verletzt,
    hart-verletzt: hart-verletzt,
  )
}

/// Punktzahl eines Schülers – nur die Zahl, ohne Detailangaben.
///
/// Inhaltlich identisch mit `punkte-schueler`, aber ohne die Listen für den
/// Bericht. Der Optimierer ruft das hunderttausendfach auf, und das Anlegen
/// der Arrays kostet dort mehr als die eigentliche Rechnung.
#let punkte-wert(kontext, platz-von, i) = {
  let p = platz-von.at(i)
  if p == none { return 0.0 }

  let g = kontext.gewichte
  let bez = kontext.geo.beziehung.at(p)
  let plaetze = kontext.geo.plaetze
  let summe = 0.0
  let sozial = 0.0
  let treffer = 0

  for (rang, w) in kontext.wuensche.at(i).enumerate() {
    let q = platz-von.at(w)
    if q == none { continue }
    let art = bez.at(q)
    let wert = if art == "direkt" { g.direkt } else if art == "tisch" { g.tisch } else { 0.0 }
    if wert <= 0.0 { continue }
    let rg = if rang < g.raenge.len() { g.raenge.at(rang) } else { g.raenge.last() }
    let stufe = if treffer < g.stufen.len() { g.stufen.at(treffer) } else { g.stufen.last() }
    sozial += rg * wert * stufe
    treffer += 1
  }
  if treffer > 0 { sozial += g.fairness }
  summe += _wunschzahl-faktor(g, kontext.wuensche.at(i).len()) * sozial

  for a in kontext.ablehnungen.at(i) {
    let q = platz-von.at(a)
    if q == none { continue }
    let art = bez.at(q)
    let wert = if art == "direkt" { g.direkt } else if art == "tisch" { g.tisch } else { 0.0 }
    if wert > 0.0 { summe += g.ablehnung * wert }
  }

  let tisch = plaetze.at(p).tisch
  for x in kontext.getrennt.at(i) {
    let q = platz-von.at(x)
    if q != none and plaetze.at(q).tisch == tisch { summe += g.hart }
  }
  for x in kontext.zusammen.at(i) {
    let q = platz-von.at(x)
    if q != none and plaetze.at(q).tisch != tisch { summe += g.hart }
  }

  let zone = plaetze.at(p).zone
  let s-i = kontext.schueler.at(i)
  let wunsch-pos = s-i.position
  let meidet = s-i.position-meidet
  for achse in ("tiefe", "seite") {
    let hier = zone.at(achse)
    if wunsch-pos.at(achse, default: none) == hier { summe += g.position }
    if hier in meidet.at(achse, default: ()) { summe += g.position-meidet }
  }

  summe
}

/// Wandelt eine Platzbelegung in die Umkehrung Schüler → Platz.
#let platz-von-schueler(kontext, zuordnung) = {
  let platz-von = range(kontext.anzahl-schueler).map(_ => none)
  for (p, s) in zuordnung.enumerate() {
    if s != none { platz-von.at(s) = p }
  }
  platz-von
}

/// Bewertet eine vollständige Sitzverteilung.
///
/// - zuordnung (array): Für jeden Platzindex der Schülerindex oder `none`.
/// -> dictionary
#let bewerte(kontext, zuordnung) = {
  let platz-von = platz-von-schueler(kontext, zuordnung)
  let details = range(kontext.anzahl-schueler).map(i => punkte-schueler(kontext, platz-von, i))
  (
    punkte: details.fold(0.0, (a, d) => a + d.punkte),
    details: details,
    zuordnung: zuordnung,
    platz-von: platz-von,
  )
}

/// Punktedifferenz beim Tausch zweier *Plätze* – ohne den ganzen Plan neu
/// zu bewerten. Der Optimierer prüft damit sehr viele Tausche pro Sekunde.
/// Einer der Plätze darf frei sein; dann zieht der andere Schüler um.
///
/// - p, q (int): die beiden Platzindizes.
/// -> dictionary
#let tausch-delta(kontext, zuordnung, platz-von, p, q) = {
  let i = zuordnung.at(p)
  let j = zuordnung.at(q)
  if i == none and j == none { return (delta: 0.0, platz-von: platz-von, zuordnung: zuordnung) }

  // Betroffen sind die beiden Umziehenden und alle, die einen von ihnen
  // gewünscht, abgelehnt oder als Vorgabe verknüpft haben.
  let betroffen = ()
  for s in (i, j) {
    if s == none { continue }
    if s not in betroffen { betroffen.push(s) }
    for r in kontext.rueckwaerts.at(s) {
      if r not in betroffen { betroffen.push(r) }
    }
  }

  let vorher = betroffen.fold(0.0, (a, s) => a + punkte-wert(kontext, platz-von, s))

  let neu = platz-von
  if i != none { neu.at(i) = q }
  if j != none { neu.at(j) = p }

  let nachher = betroffen.fold(0.0, (a, s) => a + punkte-wert(kontext, neu, s))

  let neue-zuordnung = zuordnung
  neue-zuordnung.at(p) = j
  neue-zuordnung.at(q) = i

  (delta: nachher - vorher, platz-von: neu, zuordnung: neue-zuordnung)
}

// ── Auswertung ─────────────────────────────────────────────────────

/// Fasst ein Bewertungsergebnis in Kennzahlen zusammen.
/// -> dictionary
#let statistik(kontext, ergebnis) = {
  let gesamt = kontext.wuensche.fold(0, (a, w) => a + w.len())
  let erfuellt = ergebnis.details.fold(0, (a, d) => a + d.erfuellt.len())
  let ohne = ()
  let alle = ()
  let mit-pos = 0
  let pos-gesamt = 0
  let pos-verletzt-gesamt = 0
  let unerfuellbar = ()
  let hart-gesamt = 0
  let punkte-pos = 0.0
  let verteilung = (:)
  let verletzt = ()

  for (i, d) in ergebnis.details.enumerate() {
    let name = kontext.schueler.at(i).name
    if kontext.wuensche.at(i).len() > 0 and d.erfuellt.len() == 0 { ohne.push(name) }
    if kontext.wuensche.at(i).len() > 0 and d.erfuellt.len() == kontext.wuensche.at(i).len() { alle.push(name) }
    let s-i = kontext.schueler.at(i)
    for achse in ("tiefe", "seite") {
      let gewuenscht = s-i.at("position", default: (:)).at(achse, default: none)
      if gewuenscht != none {
        pos-gesamt += 1
        // Wunsch nach einer Zone, die es im Raum gar nicht gibt
        // (z. B. „mitte" bei nur zwei Tischreihen)
        if gewuenscht not in kontext.geo.zonen.at(achse) {
          unerfuellbar.push((name: kontext.schueler.at(i).name, zone: gewuenscht))
        }
      }
      pos-gesamt += s-i.at("position-meidet", default: (:)).at(achse, default: ()).len()
    }
    mit-pos += d.position
    pos-verletzt-gesamt += d.position-verletzt
    hart-gesamt += d.hart-verletzt
    punkte-pos += d.punkte-position
    // Verteilung als Kreuztabelle: je Zahl genannter Wünsche eine Reihe,
    // darin die Anzahl Schüler nach Zahl der erfüllten Wünsche. Der Index
    // im Array ist also die Zahl der erfüllten Wünsche.
    let genannt = kontext.wuensche.at(i).len()
    if genannt > 0 {
      let schluessel = str(genannt)
      let reihe = verteilung.at(schluessel, default: (0,) * (genannt + 1))
      reihe.at(d.erfuellt.len()) += 1
      verteilung.insert(schluessel, reihe)
    }
    for v in d.verletzt {
      verletzt.push((name, kontext.schueler.at(v.schueler).name))
    }
  }

  (
    punkte: ergebnis.punkte,
    wuensche-gesamt: gesamt,
    wuensche-erfuellt: erfuellt,
    quote: if gesamt > 0 { erfuellt / gesamt } else { 1.0 },
    alle-erfuellt: alle,
    ohne-wunsch: ohne,
    position-gesamt: pos-gesamt,
    position-erfuellt: mit-pos,
    position-verletzt: pos-verletzt-gesamt,
    position-unerfuellbar: unerfuellbar,
    ablehnungen-verletzt: verletzt,
    vorgaben-verletzt: hart-gesamt,
    verteilung: verteilung,
    punkte-aus-position: punkte-pos,
    punkte-aus-wuenschen: ergebnis.punkte - punkte-pos,
  )
}
