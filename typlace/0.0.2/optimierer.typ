// ═══════════════════════════════════════════════════════════════════
//  Optimierer: die bestmögliche Sitzordnung suchen
// ═══════════════════════════════════════════════════════════════════
//
//  Verfahren: mehrere zufällige Startpläne, jeder davon durch lokale
//  Suche verbessert (Tausch zweier Plätze, solange es Punkte bringt).
//  Bewertet wird nur die Differenz eines Tauschs, nicht der ganze Plan.
//  Der beste Plan aus allen Versuchen gewinnt.
//
//  Alles ist deterministisch: gleicher `seed` → gleicher Plan.

#import "geometrie.typ": plaetze-analysieren
#import "daten.typ": schueler-pruefen, wunschliste
#import "wasm.typ": wasm-suchen
#import "bewertung.typ": (
  bewerte, kontext-erstellen, normalisiere-vorgaben, platz-von-schueler, punkte-schueler, standard-gewichte,
  statistik, tausch-delta,
)

// ── Zufall ─────────────────────────────────────────────────────────
// Bewusst ein einfacher, schneller LCG: der Optimierer zieht sehr viele
// Zahlen, und für Startpläne genügt gleichmäßige Streuung.

#let _m = 2147483648
#let _weiter(z) = calc.rem(z * 1103515245 + 12345, _m)

/// Zufallszahl aus [0, n).
///
/// Wichtig ist das Teilen durch 65536: bei einem linearen Kongruenzgenerator
/// mit Zweierpotenz-Modul sind die untersten Bits fast periodisch (das
/// unterste wechselt stur 0,1,0,1). `z % n` würde genau die verwenden und
/// die Startpläne einander ähnlicher machen, als sie sein sollten. Deshalb
/// die oberen Bits.
#let _wahl(z, n) = calc.rem(calc.floor(z / 65536), n)

#let _mischen(liste, zustand) = {
  let a = liste
  let z = zustand
  let i = a.len()
  while i > 1 {
    i -= 1
    z = _weiter(z)
    let j = _wahl(z, i + 1)
    let merk = a.at(i)
    a.at(i) = a.at(j)
    a.at(j) = merk
  }
  (liste: a, zustand: z)
}

// ── Harte Vorgaben in erlaubte Plätze übersetzen ───────────────────

#let _zonen-vorgaben = (
  "muss-vorne": (achse: "tiefe", wert: "vorne"),
  "muss-mitte": (achse: "tiefe", wert: "mitte"),
  "muss-hinten": (achse: "tiefe", wert: "hinten"),
  "muss-links": (achse: "seite", wert: "links"),
  "muss-rechts": (achse: "seite", wert: "rechts"),
)

/// Baut für jeden Schüler die Liste der Plätze, die er einnehmen darf,
/// sowie die fest vergebenen Plätze.
#let _spielraum(geo, kontext, vorgaben) = {
  let anzahl-p = geo.plaetze.len()
  let namen = kontext.schueler.map(s => s.name)
  let index-von = kontext.index-von

  let hole(name, quelle) = {
    if name in index-von { return index-von.at(name) }
    panic("typlace: Vorgabe „" + quelle + "“ nennt einen unbekannten Namen: " + name)
  }

  // feste Plätze
  let fest = range(kontext.anzahl-schueler).map(_ => none)
  let belegt-fest = (:)
  for (name, platz) in vorgaben.at("fest", default: (:)) {
    let i = hole(name, "fest")
    if platz < 0 or platz >= anzahl-p {
      panic("typlace: Platz " + str(platz) + " für " + name + " gibt es nicht (0 bis " + str(anzahl-p - 1) + ").")
    }
    if str(platz) in belegt-fest {
      panic("typlace: Platz " + str(platz) + " ist zweimal fest vergeben.")
    }
    belegt-fest.insert(str(platz), true)
    fest.at(i) = platz
  }

  // Zonenvorgaben
  let zonen = range(kontext.anzahl-schueler).map(_ => ())
  for (schluessel, bedingung) in _zonen-vorgaben {
    for name in vorgaben.at(schluessel, default: ()) {
      let i = hole(name, schluessel)
      zonen.at(i) = zonen.at(i) + (bedingung,)
    }
  }

  let erlaubt = range(kontext.anzahl-schueler).map(i => range(anzahl-p).map(p => {
    if fest.at(i) != none { return fest.at(i) == p }
    if str(p) in belegt-fest { return false }
    let zone = geo.plaetze.at(p).zone
    zonen.at(i).all(b => zone.at(b.achse) == b.wert)
  }))

  for (i, reihe) in erlaubt.enumerate() {
    if reihe.any(x => x) { continue }
    panic("typlace: Für " + namen.at(i) + " bleibt durch die Vorgaben kein Platz übrig.")
  }

  (erlaubt: erlaubt, fest: fest)
}

// ── Startplan ──────────────────────────────────────────────────────

/// Erzeugt einen zufälligen, aber zulässigen Startplan. Schüler mit den
/// wenigsten erlaubten Plätzen kommen zuerst dran, sonst blockieren die
/// freizügigen Schüler die knappen Plätze.
#let _startplan(kontext, spielraum, zustand) = {
  let anzahl-p = kontext.anzahl-plaetze
  let zuordnung = range(anzahl-p).map(_ => none)
  let belegt = range(anzahl-p).map(_ => false)
  let z = zustand

  for (i, p) in spielraum.fest.enumerate() {
    if p == none { continue }
    zuordnung.at(p) = i
    belegt.at(p) = true
  }

  let offen = range(kontext.anzahl-schueler).filter(i => spielraum.fest.at(i) == none)
  let gemischt = _mischen(offen, z)
  z = gemischt.zustand
  let reihenfolge = gemischt.liste.sorted(key: i => spielraum.erlaubt.at(i).filter(x => x).len())

  for i in reihenfolge {
    let frei = range(anzahl-p).filter(p => not belegt.at(p) and spielraum.erlaubt.at(i).at(p))
    if frei.len() == 0 {
      panic("typlace: Die Vorgaben lassen sich nicht alle gleichzeitig erfüllen.")
    }
    z = _weiter(z)
    let p = frei.at(_wahl(z, frei.len()))
    zuordnung.at(p) = i
    belegt.at(p) = true
  }

  (zuordnung: zuordnung, zustand: z)
}

// ── Lokale Suche ───────────────────────────────────────────────────

/// Tauscht so lange Plätze, wie das Punkte bringt (erste Verbesserung
/// wird sofort übernommen). Betrachtet werden nur Plätze, an denen noch
/// etwas offen ist – erfüllte Schüler kommen nur als Tauschpartner vor.
#let _verbessern(kontext, zuordnung, spielraum, beweglich, max-schritte, zustand) = {
  let z = zustand
  let platz-von = platz-von-schueler(kontext, zuordnung)
  let schritte = 0
  let geprueft = 0
  let weiter = true

  let wunsch-achsen = kontext.schueler.map(s => {
    let p = s.at("position", default: (:))
    ("tiefe", "seite").filter(a => p.at(a, default: none) != none).len()
  })

  while weiter and schritte < max-schritte {
    weiter = false

    // Plätze mit offenem Potenzial bestimmen
    let interessant = ()
    for p in beweglich {
      let i = zuordnung.at(p)
      if i == none {
        interessant.push(p)
        continue
      }
      let d = punkte-schueler(kontext, platz-von, i)
      let offen = kontext.wuensche.at(i).len() - d.erfuellt.len()
      if (
        offen > 0
          or d.verletzt.len() > 0
          or d.hart-verletzt > 0
          or d.position-verletzt > 0
          or wunsch-achsen.at(i) - d.position > 0
      ) {
        interessant.push(p)
      }
    }
    if interessant.len() == 0 { break }

    let m = _mischen(interessant, z)
    z = m.zustand
    let m2 = _mischen(beweglich, z)
    z = m2.zustand

    for p in m.liste {
      for q in m2.liste {
        if p == q { continue }
        let i = zuordnung.at(p)
        let j = zuordnung.at(q)
        if i == none and j == none { continue }
        if i != none and not spielraum.erlaubt.at(i).at(q) { continue }
        if j != none and not spielraum.erlaubt.at(j).at(p) { continue }

        geprueft += 1
        let t = tausch-delta(kontext, zuordnung, platz-von, p, q)
        if t.delta > 1e-6 {
          zuordnung = t.zuordnung
          platz-von = t.platz-von
          schritte += 1
          weiter = true
          if schritte >= max-schritte { break }
        }
      }
      if schritte >= max-schritte { break }
    }
  }

  (zuordnung: zuordnung, zustand: z, schritte: schritte, geprueft: geprueft)
}

// ── Hauptfunktion ──────────────────────────────────────────────────

// Zwei Sätze, weil ein Startplan im Plugin rund 7 ms kostet und in Typst
// rund 600 ms. An einer 30er-Klasse gemessen: mehr Startpläne bringen
// weiterhin Punkte (20 Versuche 118,5 – 100 Versuche 119,4 – 2000 Versuche
// 121,8), das lohnt sich also, solange es nichts kostet. In reinem Typst
// bleiben die Zahlen klein, sonst wartet man Minuten.
#let _budget = (
  wasm: (
    schnell: (versuche: 50, max-schritte: 400),
    normal: (versuche: 300, max-schritte: 800),
    gruendlich: (versuche: 2000, max-schritte: 1500),
  ),
  typst: (
    schnell: (versuche: 6, max-schritte: 300),
    normal: (versuche: 12, max-schritte: 600),
    gruendlich: (versuche: 30, max-schritte: 1500),
  ),
)

/// Sucht die Sitzordnung, die am besten zu den Wünschen passt.
///
/// - layout (str): Layout-String des Raumes.
/// - schueler (str, array, dictionary): Wunschliste – roher Text, das
///   Ergebnis von `csv(..., delimiter: "|")` oder von `wunschliste()`.
/// - vorgaben (dictionary): Harte Vorgaben der Lehrkraft:
///   `fest` (Name → Platznummer), `muss-vorne`, `muss-mitte`, `muss-hinten`,
///   `muss-links`, `muss-rechts` (je eine Namensliste), `getrennt` und
///   `zusammen` (je eine Liste von Namenspaaren).
/// - gewichte (dictionary): Abweichungen von `standard-gewichte`.
/// - position-anteil (auto, ratio, float): Wie viel Gewicht die Sitzwünsche
///   im Raum (vorne/hinten/links/rechts) gegenüber den Wünschen nach
///   Mitschülern bekommen. `20%` heißt: ein Fünftel der erreichbaren Punkte
///   stammt aus Positionswünschen. Überschreibt `position` in `gewichte`.
/// - seed (int): Startwert des Zufalls. Anderer Seed = anderer Vorschlag.
/// - qualitaet (str): `"schnell"`, `"normal"` oder `"gruendlich"`.
/// - versuche (auto, int): Anzahl Startpläne; überschreibt `qualitaet`.
/// - max-schritte (auto, int): Verbesserungsschritte je Versuch.
/// - dauer (none, str): Rechenzeit als Text für den Bericht. Typst hat keine
///   Uhr, die Zeit muss also von außen kommen – siehe `sitzplan.sh`.
/// - vorrang (array): Namen, die diesmal möglichst *alle* Wünsche bekommen
///   sollen – typischerweise die, die im letzten Plan nur einen Teil hatten.
///   Der Bericht schlägt diese Liste für den nächsten Plan vor. Wie stark,
///   regelt `gewichte: (vorrang: …)` (Standard 4).
/// - vorplaene (array): Ergebnisse früherer Pläne, je `json("Plan-11.json")`
///   (geschrieben von `sitzplan.sh`, Inhalt von `sitzplan-ergebnis`). Wer in
///   *keinem* davon alle Wünsche bekommen hat, kommt automatisch auf die
///   Vorrang-Liste. Kinder, die in einem Vorplan fehlen, zählen dort nicht.
/// - niemand-leer (bool): Ein Plan, in dem jemand ganz ohne Wunsch bleibt,
///   wird nur genommen, wenn sich keiner ohne finden lässt. Die Suche hängt
///   dafür so lange weitere Blöcke von `versuche` Startplänen an, bis jeder
///   mindestens einen Wunsch hat oder `max-versuche` erreicht ist.
/// - max-versuche (auto, int): Obergrenze für `niemand-leer`, Standard
///   zwanzigmal `versuche`.
/// - motor (str): `"wasm"` rechnet im mitgelieferten Plugin (Standard),
///   `"typst"` in reinem Typst. Beide führen dieselbe Suche aus und liefern
///   bei gleichem Seed denselben Plan; die Typst-Fassung ist die lesbare
///   Referenz, an der sich das Plugin messen lassen muss.
/// -> dictionary
#let sitzordnung(
  layout,
  schueler,
  vorgaben: (:),
  gewichte: (:),
  position-anteil: auto,
  seed: 42,
  qualitaet: "normal",
  versuche: auto,
  max-schritte: auto,
  vorne: auto,
  perspektive: "schueler",
  streng: true,
  dauer: none,
  motor: "wasm",
  vorrang: (),
  vorplaene: (),
  niemand-leer: false,
  max-versuche: auto,
) = {
  if motor not in _budget {
    panic("typlace: motor muss \"wasm\" oder \"typst\" sein.")
  }
  if qualitaet not in _budget.at(motor) {
    panic("typlace: qualitaet muss \"schnell\", \"normal\" oder \"gruendlich\" sein.")
  }
  let vorgaben = normalisiere-vorgaben(vorgaben)
  let stufe = _budget.at(motor).at(qualitaet)
  let anzahl-versuche = if versuche == auto { stufe.versuche } else { versuche }
  let grenze = if max-schritte == auto { stufe.max-schritte } else { max-schritte }
  let obergrenze = if max-versuche == auto { 20 * anzahl-versuche } else { max-versuche }

  let geo = plaetze-analysieren(layout, vorne: vorne, perspektive: perspektive)

  let daten = if type(schueler) == dictionary and "schueler" in schueler {
    schueler
  } else if type(schueler) == str {
    wunschliste(schueler, plaetze: geo.plaetze.len(), streng: streng)
  } else {
    schueler-pruefen(schueler, plaetze: geo.plaetze.len(), streng: streng)
  }

  // Vorrang aus früheren Plänen ableiten und mit der Hand-Liste vereinen.
  if type(vorrang) == str { vorrang = (vorrang,) }
  if type(vorplaene) == dictionary { vorplaene = (vorplaene,) }
  let aus-vorplaenen = ()
  if vorplaene.len() > 0 {
    for s in daten.schueler {
      let bekannt = vorplaene.filter(v => s.name in v.at("schueler", default: (:)))
      if bekannt.len() == 0 { continue }
      let nie-alle = bekannt.all(v => {
        let e = v.schueler.at(s.name)
        e.genannt > 0 and e.erfuellt < e.genannt
      })
      if nie-alle and s.name not in vorrang { aus-vorplaenen.push(s.name) }
    }
  }
  let vorrang = vorrang + aus-vorplaenen

  let kontext = kontext-erstellen(
    geo,
    daten.schueler,
    gewichte: gewichte,
    vorgaben: vorgaben,
    position-anteil: position-anteil,
    vorrang: vorrang,
  )
  let spielraum = _spielraum(geo, kontext, vorgaben)
  let beweglich = range(geo.plaetze.len()).filter(p => not spielraum.fest.contains(p))

  let bestes = none
  let geprueft-gesamt = 0
  let laeufe = 0
  let z = calc.rem(calc.abs(seed) + 1, _m)

  if motor == "wasm" {
    let w = wasm-suchen(
      kontext,
      geo,
      spielraum,
      versuche: anzahl-versuche,
      max-schritte: grenze,
      seed: seed,
      niemand-leer: niemand-leer,
      max-versuche: obergrenze,
    )
    let ergebnis = bewerte(kontext, w.zuordnung)
    // Gegenprobe: Typst bewertet den gelieferten Plan unabhängig nach. Weicht
    // das ab, passen die beiden Fassungen nicht mehr zusammen – dann lieber
    // abbrechen als still falsch rechnen.
    if calc.abs(w.punkte - ergebnis.punkte) > 0.001 {
      panic(
        "typlace: Das WASM-Plugin meldet "
          + str(w.punkte)
          + " Punkte, die Nachrechnung in Typst ergibt "
          + str(ergebnis.punkte)
          + ". Bitte mit motor: \"typst\" arbeiten und den Fehler melden.",
      )
    }
    bestes = ergebnis + (schritte: w.schritte)
    geprueft-gesamt = w.geprueft
    laeufe = w.laeufe
  }

  // Leer ausgegangene Schüler eines bewerteten Plans zählen.
  let leere(ergebnis) = range(kontext.anzahl-schueler)
    .filter(i => kontext.wuensche.at(i).len() > 0 and ergebnis.details.at(i).erfuellt.len() == 0)
    .len()

  // Gleiche Blocklogik wie im Plugin (rust/src/lib.rs, `rechne`).
  let suchen = motor == "typst"
  while suchen {
    for _ in range(anzahl-versuche) {
      let start = _startplan(kontext, spielraum, z)
      z = start.zustand
      let lauf = _verbessern(kontext, start.zuordnung, spielraum, beweglich, grenze, z)
      z = lauf.zustand
      geprueft-gesamt += lauf.geprueft
      let ergebnis = bewerte(kontext, lauf.zuordnung)
      let l = if niemand-leer { leere(ergebnis) } else { 0 }
      if bestes == none or l < bestes.leer or (l == bestes.leer and ergebnis.punkte > bestes.punkte) {
        bestes = ergebnis + (versuch: laeufe, schritte: lauf.schritte, leer: l)
      }
      laeufe += 1
    }
    if not niemand-leer or bestes == none or bestes.leer == 0 or laeufe >= obergrenze or anzahl-versuche == 0 {
      suchen = false
    }
  }

  let stat = statistik(kontext, bestes)
  if stat.vorgaben-verletzt > 0 {
    panic(
      "typlace: Die Vorgaben „getrennt“/„zusammen“ lassen sich mit diesem Raum nicht alle einhalten ("
        + str(stat.vorgaben-verletzt)
        + " Verletzungen im besten gefundenen Plan).",
    )
  }

  (
    namen: bestes.zuordnung.map(i => if i == none { "" } else { kontext.schueler.at(i).name }),
    zuordnung: bestes.zuordnung,
    platz-von: bestes.platz-von,
    punkte: bestes.punkte,
    punkte-gerundet: calc.round(bestes.punkte, digits: 1),
    details: bestes.details,
    statistik: stat,
    hinweise: daten.hinweise,
    kontext: kontext,
    geo: geo,
    seed: seed,
    dauer: dauer,
    versuche: laeufe,
    versuche-block: anzahl-versuche,
    niemand-leer: niemand-leer,
    vorplaene: vorplaene.len(),
    schritte: bestes.schritte,
    geprueft: geprueft-gesamt,
  )
}
