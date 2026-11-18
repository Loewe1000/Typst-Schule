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

#import "internal/check.typ": fail, check-named, check-value, check-type, check-not-empty, check-positional
#import "geometry.typ": analyze-layout
#import "data.typ": check-entries, check-students, parse-students
#import "wasm.typ": wasm-search
#import "scoring.typ": (
  score-plan, build-problem, normalize-constraints, seat-of-students, student-score, default-weights,
  statistics, swap-delta,
)

// ── Alte und neue Namen zugleich ───────────────────────────────────

// Neue Namen, die ausdrücklich gesetzt wurden (Wert weicht von der Vorgabe
// ab), zusammen mit dem Sink: so meldet `check-named` „alt und neu zugleich".
#let _gesetzt(deprecated, paare) = {
  let d = deprecated.named()
  for (name, paar) in paare {
    if paar.at(0) != paar.at(1) { d.insert(name, paar.at(0)) }
  }
  d
}

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
  "must-front": (axis: "depth", value: "front"),
  "must-middle": (axis: "depth", value: "middle"),
  "must-back": (axis: "depth", value: "back"),
  "must-left": (axis: "side", value: "left"),
  "must-right": (axis: "side", value: "right"),
)

/// Baut für jeden Schüler die Liste der Plätze, die er einnehmen darf,
/// sowie die fest vergebenen Plätze.
#let _spielraum(geometry, problem, constraints) = {
  let anzahl-p = geometry.seats.len()
  let names = problem.students.map(s => s.name)
  let index-of = problem.index-of

  let hole(name, source) = {
    if name in index-of { return index-of.at(name) }
    fail(
      "typlace",
      "sitzordnung",
      "die Vorgabe `" + source + "` nennt einen unbekannten Namen: " + name + " – Namen wie in der Wunschliste schreiben",
    )
  }

  // feste Plätze
  let fixed = range(problem.student-count).map(_ => none)
  let belegt-fest = (:)
  for (name, platz) in constraints.at("fixed", default: (:)) {
    let i = hole(name, "fixed")
    if platz < 0 or platz >= anzahl-p {
      fail(
        "typlace",
        "sitzordnung",
        "Platz " + str(platz) + " für " + name + " gibt es nicht – erlaubt sind 0 bis " + str(anzahl-p - 1) + " (`typlace(number: true)` zeigt die Nummern)",
      )
    }
    if str(platz) in belegt-fest {
      fail("typlace", "sitzordnung", "Platz " + str(platz) + " ist in `fixed` zweimal vergeben – einen der beiden Einträge ändern")
    }
    belegt-fest.insert(str(platz), true)
    fixed.at(i) = platz
  }

  // Zonenvorgaben
  let zones = range(problem.student-count).map(_ => ())
  for (schluessel, bedingung) in _zonen-vorgaben {
    for name in constraints.at(schluessel, default: ()) {
      let i = hole(name, schluessel)
      zones.at(i) = zones.at(i) + (bedingung,)
    }
  }

  let allowed = range(problem.student-count).map(i => range(anzahl-p).map(p => {
    if fixed.at(i) != none { return fixed.at(i) == p }
    if str(p) in belegt-fest { return false }
    let zone = geometry.seats.at(p).zone
    zones.at(i).all(b => zone.at(b.axis) == b.value)
  }))

  for (i, reihe) in allowed.enumerate() {
    if reihe.any(x => x) { continue }
    fail("typlace", "sitzordnung", "für " + names.at(i) + " bleibt durch die Vorgaben kein Platz übrig – Vorgaben in `constraints` lockern")
  }

  (allowed: allowed, fixed: fixed)
}

// ── Startplan ──────────────────────────────────────────────────────

/// Erzeugt einen zufälligen, aber zulässigen Startplan. Schüler mit den
/// wenigsten erlaubten Plätzen kommen zuerst dran, sonst blockieren die
/// freizügigen Schüler die knappen Plätze.
#let _startplan(problem, scope, zustand) = {
  let anzahl-p = problem.seat-count
  let assignment = range(anzahl-p).map(_ => none)
  let belegt = range(anzahl-p).map(_ => false)
  let z = zustand

  for (i, p) in scope.fixed.enumerate() {
    if p == none { continue }
    assignment.at(p) = i
    belegt.at(p) = true
  }

  let offen = range(problem.student-count).filter(i => scope.fixed.at(i) == none)
  let gemischt = _mischen(offen, z)
  z = gemischt.zustand
  let reihenfolge = gemischt.liste.sorted(key: i => scope.allowed.at(i).filter(x => x).len())

  for i in reihenfolge {
    let frei = range(anzahl-p).filter(p => not belegt.at(p) and scope.allowed.at(i).at(p))
    if frei.len() == 0 {
      fail("typlace", "sitzordnung", "die Vorgaben lassen sich nicht alle gleichzeitig erfüllen – Vorgaben in `constraints` lockern")
    }
    z = _weiter(z)
    let p = frei.at(_wahl(z, frei.len()))
    assignment.at(p) = i
    belegt.at(p) = true
  }

  (assignment: assignment, zustand: z)
}

// ── Lokale Suche ───────────────────────────────────────────────────

/// Tauscht so lange Plätze, wie das Punkte bringt (erste Verbesserung
/// wird sofort übernommen). Betrachtet werden nur Plätze, an denen noch
/// etwas offen ist – erfüllte Schüler kommen nur als Tauschpartner vor.
#let _verbessern(problem, assignment, scope, beweglich, max-steps, zustand) = {
  let z = zustand
  let seat-of = seat-of-students(problem, assignment)
  let steps = 0
  let checked = 0
  let weiter = true

  let wunsch-achsen = problem.students.map(s => {
    let p = s.at("position", default: (:))
    ("depth", "side").filter(a => p.at(a, default: none) != none).len()
  })

  while weiter and steps < max-steps {
    weiter = false

    // Plätze mit offenem Potenzial bestimmen
    let interessant = ()
    for p in beweglich {
      let i = assignment.at(p)
      if i == none {
        interessant.push(p)
        continue
      }
      let d = student-score(problem, seat-of, i)
      let offen = problem.wishes.at(i).len() - d.fulfilled.len()
      if (
        offen > 0
          or d.violated.len() > 0
          or d.constraints-violated > 0
          or d.position-violated > 0
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
        let i = assignment.at(p)
        let j = assignment.at(q)
        if i == none and j == none { continue }
        if i != none and not scope.allowed.at(i).at(q) { continue }
        if j != none and not scope.allowed.at(j).at(p) { continue }

        checked += 1
        let t = swap-delta(problem, assignment, seat-of, p, q)
        if t.delta > 1e-6 {
          assignment = t.assignment
          seat-of = t.seat-of
          steps += 1
          weiter = true
          if steps >= max-steps { break }
        }
      }
      if steps >= max-steps { break }
    }
  }

  (assignment: assignment, zustand: z, steps: steps, checked: checked)
}

// ── Hauptfunktion ──────────────────────────────────────────────────

// Zwei Sätze, weil ein Startplan im Plugin rund 7 ms kostet und in Typst
// rund 600 ms. An einer 30er-Klasse gemessen: mehr Startpläne bringen
// weiterhin Punkte (20 Versuche 118,5 – 100 Versuche 119,4 – 2000 Versuche
// 121,8), das lohnt sich also, solange es nichts kostet. In reinem Typst
// bleiben die Zahlen klein, sonst wartet man Minuten.
#let _budget = (
  wasm: (
    fast: (attempts: 50, max-steps: 400),
    normal: (attempts: 300, max-steps: 800),
    thorough: (attempts: 2000, max-steps: 1500),
  ),
  typst: (
    fast: (attempts: 6, max-steps: 300),
    normal: (attempts: 12, max-steps: 600),
    thorough: (attempts: 30, max-steps: 1500),
  ),
)

/// Sucht die Sitzordnung, die am besten zu den Wünschen passt.
///
/// Das Ergebnis ist ein Dictionary. Die wichtigsten Schlüssel: `names`
/// (Namen in Platzreihenfolge, direkt an `typlace(names: …)` weiterreichen),
/// `points`, `statistics`, `details`, `notes`, `geometry` und `problem`.
///
/// - layout (str): Layout-String des Raumes.
/// - students (str, array, dictionary): Wunschliste – roher Text, das
///   Ergebnis von `csv(..., delimiter: "|")` oder von `wunschliste()`.
/// - constraints (dictionary): Harte Vorgaben der Lehrkraft:
///   `fixed` (Name → Platznummer), `must-front`, `must-middle`, `must-back`,
///   `must-left`, `must-right` (je eine Namensliste), `apart` und
///   `together` (je eine Liste von Namenspaaren).
/// - weights (dictionary): Abweichungen von `default-weights`.
/// - position-share (auto, ratio, float): Wie viel Gewicht die Sitzwünsche
///   im Raum (vorne/hinten/links/rechts) gegenüber den Wünschen nach
///   Mitschülern bekommen. `20%` heißt: ein Fünftel der erreichbaren Punkte
///   stammt aus Positionswünschen. Überschreibt `position` in `weights`.
/// - seed (int): Startwert des Zufalls. Anderer Seed = anderer Vorschlag.
/// - quality (str): Suchaufwand: `"fast"`, `"normal"` oder `"thorough"`.
/// - attempts (auto, int): Anzahl Startpläne; überschreibt `quality`.
/// - max-steps (auto, int): Verbesserungsschritte je Versuch.
/// - front (auto, str): Vorderseite des Raumes im Layout: `"top"`,
///   `"bottom"`, `"left"` oder `"right"`. `auto` liest sie aus der Lage
///   des Pults.
/// - perspective (str): `"student"` – links und rechts aus Sicht der nach
///   vorne blickenden Klasse; `"plan"` – wie gezeichnet.
/// - strict (bool): Bei unbekannten Namen in der Wunschliste abbrechen
///   statt nur einen Hinweis zu notieren.
/// - duration (none, str, content, int, float): Rechenzeit für den Bericht,
///   am besten als Text mit Einheit (`"0,4 s"`); eine Zahl erscheint
///   unverändert. Typst hat keine Uhr, die Zeit muss also von außen kommen.
/// - engine (str): `"wasm"` rechnet im mitgelieferten Plugin (Standard),
///   `"typst"` in reinem Typst. Beide führen dieselbe Suche aus und liefern
///   bei gleichem Seed denselben Plan; die Typst-Fassung ist die lesbare
///   Referenz, an der sich das Plugin messen lassen muss.
/// - priority (array): Namen, die diesmal möglichst *alle* Wünsche bekommen
///   sollen. Wie stark, regelt `weights: (priority: …)` (Standard 4).
/// - previous (array, dictionary): Ergebnisse früherer Pläne, je
///   `json("Plan-11.json")` – der Inhalt von `seating-result`, den
///   `typst eval 'query(<seating-result>).first().value' --in Plan-11.typ`
///   herausholt. Wer in *keinem* davon alle Wünsche bekommen hat, kommt
///   automatisch zu `priority` dazu. Kinder, die in einem Vorplan fehlen,
///   zählen dort nicht. Liest auch die Dateien von typlace 0.0.2.
/// - nobody-empty (bool): Ein Plan, in dem jemand ganz ohne Wunsch bleibt,
///   wird nur genommen, wenn sich keiner ohne finden lässt. Die Suche hängt
///   dafür weitere Blöcke von `attempts` Startplänen an, bis jeder
///   mindestens einen Wunsch hat oder `max-attempts` erreicht ist.
/// - max-attempts (auto, int): Obergrenze für `nobody-empty`, Standard
///   zwanzigmal `attempts`.
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> dictionary
#let sitzordnung(
  layout,
  students,
  constraints: (:),
  weights: (:),
  position-share: auto,
  seed: 42,
  quality: "normal",
  attempts: auto,
  max-steps: auto,
  front: auto,
  perspective: "student",
  strict: true,
  duration: none,
  engine: "wasm",
  priority: (),
  previous: (),
  nobody-empty: false,
  max-attempts: auto,
  ..deprecated,
) = {
  let fn = "sitzordnung"
  check-positional(
    "typlace",
    fn,
    deprecated,
    hint: "nur Layout und Wunschliste stehen vorn – alles andere benannt schreiben (`seed: 7`)",
  )
  check-named(
    "typlace",
    fn,
    _gesetzt(deprecated, (
      constraints: (constraints, (:)),
      weights: (weights, (:)),
      position-share: (position-share, auto),
      quality: (quality, "normal"),
      attempts: (attempts, auto),
      max-steps: (max-steps, auto),
      front: (front, auto),
      perspective: (perspective, "student"),
      strict: (strict, true),
      duration: (duration, none),
      engine: (engine, "wasm"),
      priority: (priority, ()),
      previous: (previous, ()),
      nobody-empty: (nobody-empty, false),
      max-attempts: (max-attempts, auto),
    )),
    renamed: (
      vorgaben: "constraints",
      gewichte: "weights",
      position-anteil: "position-share",
      qualitaet: "quality",
      versuche: "attempts",
      max-schritte: "max-steps",
      vorne: "front",
      perspektive: "perspective",
      streng: "strict",
      dauer: "duration",
      motor: "engine",
      vorrang: "priority",
      vorplaene: "previous",
      niemand-leer: "nobody-empty",
      max-versuche: "max-attempts",
    ),
    allowed: (
      "constraints",
      "weights",
      "position-share",
      "seed",
      "quality",
      "attempts",
      "max-steps",
      "front",
      "perspective",
      "strict",
      "duration",
      "engine",
      "priority",
      "previous",
      "nobody-empty",
      "max-attempts",
    ),
  )
  check-type("typlace", fn, "layout", layout, str, example: "\"TT.TT\\n..P..\"")
  check-type("typlace", fn, "students", students, (str, array, dictionary), example: "read(\"wuensche.csv\")")
  check-type("typlace", fn, "weights", weights, dictionary, example: "(position: 1.5)")
  check-type("typlace", fn, "position-share", position-share, (ratio, float, int, auto), example: "20%")
  check-type("typlace", fn, "seed", seed, int, example: "42")
  check-type("typlace", fn, "attempts", attempts, (int, auto), example: "100")
  check-type("typlace", fn, "max-steps", max-steps, (int, auto), example: "500")
  check-type("typlace", fn, "strict", strict, bool)
  check-type("typlace", fn, "duration", duration, (str, content, int, float, none), example: "\"0,4 s\"")
  check-not-empty("typlace", fn, "duration", duration, "keine Rechenzeit")
  check-value("typlace", fn, "engine", engine, ("wasm", "typst"))
  check-type("typlace", fn, "priority", priority, (array, str), example: "(\"Lotta\", \"Juri\")")
  check-type("typlace", fn, "previous", previous, (array, dictionary), example: "(json(\"Plan-11.json\"),)")
  check-type("typlace", fn, "nobody-empty", nobody-empty, bool)
  check-type("typlace", fn, "max-attempts", max-attempts, (int, auto), example: "10000")
  check-value(
    "typlace",
    fn,
    "quality",
    quality,
    ("fast", "normal", "thorough"),
    renamed: (schnell: "fast", gruendlich: "thorough"),
  )
  check-value(
    "typlace",
    fn,
    "front",
    front,
    (auto, "top", "bottom", "left", "right"),
    renamed: (oben: "top", unten: "bottom", links: "left", rechts: "right"),
  )
  check-value("typlace", fn, "perspective", perspective, ("student", "plan"), renamed: (schueler: "student"))
  check-named(
    "typlace",
    fn,
    weights,
    what: "Schlüssel",
    renamed: (
      direkt: "adjacent",
      tisch: "table",
      raenge: "ranks",
      stufen: "tiers",
      wunschzahl: "wish-count",
      ablehnung: "rejection",
      hart: "constraint",
      position-meidet: "position-avoided",
      vorrang: "priority",
    ),
    allowed: default-weights.keys(),
  )
  let constraints = normalize-constraints(constraints)
  check-named(
    "typlace",
    fn,
    constraints,
    what: "Schlüssel",
    renamed: (
      fest: "fixed",
      muss-vorne: "must-front",
      muss-mitte: "must-middle",
      muss-hinten: "must-back",
      muss-links: "must-left",
      muss-rechts: "must-right",
      getrennt: "apart",
      zusammen: "together",
    ),
    allowed: ("fixed", "must-front", "must-middle", "must-back", "must-left", "must-right", "apart", "together"),
  )
  for (schluessel, wert) in constraints {
    if schluessel == "fixed" {
      check-type("typlace", fn, schluessel, wert, dictionary, example: "(\"Ben Schulz\": 3)")
    } else {
      check-type("typlace", fn, schluessel, wert, array, example: if schluessel in ("apart", "together") {
        "((\"Max\", \"Moritz\"),)"
      } else { "(\"Eva Lang\",)" })
    }
  }
  let stufe = _budget.at(engine).at(quality)
  let anzahl-versuche = if attempts == auto { stufe.attempts } else { attempts }
  let grenze = if max-steps == auto { stufe.max-steps } else { max-steps }
  let obergrenze = if max-attempts == auto { 20 * anzahl-versuche } else { max-attempts }

  let geometry = analyze-layout(layout, front: front, perspective: perspective)

  let data = if type(students) == dictionary and "students" in students {
    // Ergebnis von `wunschliste()` oder ein selbst gebautes Dictionary: die
    // Namen sind schon aufgelöst und bleiben, wie sie sind. Geprüft werden
    // nur die Schlüssel und Zonenwerte, damit alte Namen nicht still
    // übergangen werden.
    check-entries(students, caller: fn)
  } else if type(students) == str or (type(students) == array and students.any(z => type(z) != dictionary)) {
    // Roher Text oder Zeilen aus `csv(...)`: erst einlesen, dann prüfen.
    // (Bis 0.0.2 scheiterten csv-Zeilen hier, obwohl sie dokumentiert waren.)
    check-students(
      parse-students(students, caller: fn),
      seat-count: geometry.seats.len(),
      strict: strict,
      caller: fn,
    )
  } else {
    check-students(students, seat-count: geometry.seats.len(), strict: strict, caller: fn)
  }

  // Vorrang: Hand-Liste plus alle, die in keinem Vorplan alle Wünsche hatten.
  let priority = if type(priority) == str { (priority,) } else { priority }
  let previous = if type(previous) == dictionary { (previous,) } else { previous }
  let alle-namen = data.students.map(s => s.name)
  for name in priority {
    if name not in alle-namen {
      fail("typlace", fn, "`priority` nennt " + name + ", das steht nicht in der Wunschliste – Schreibweise prüfen")
    }
  }
  // Eintrag eines Schülers in einem Vorplan: 0.5.0 schreibt `students` mit
  // `fulfilled`/`named`, 0.0.2 schrieb `schueler` mit `erfuellt`/`genannt`.
  let eintrag(v, name) = {
    let neu = v.at("students", default: (:))
    if name in neu { return (neu.at(name).fulfilled, neu.at(name).named) }
    let alt = v.at("schueler", default: (:))
    if name in alt { return (alt.at(name).erfuellt, alt.at(name).genannt) }
    none
  }
  let aus-vorplaenen = ()
  for name in alle-namen {
    let bekannt = previous.map(v => eintrag(v, name)).filter(e => e != none)
    if bekannt.len() == 0 or name in priority { continue }
    if bekannt.all(e => e.at(1) > 0 and e.at(0) < e.at(1)) { aus-vorplaenen.push(name) }
  }
  let priority = priority + aus-vorplaenen

  let problem = build-problem(
    geometry,
    data.students,
    weights: weights,
    constraints: constraints,
    position-share: position-share,
    priority: priority,
  )
  let scope = _spielraum(geometry, problem, constraints)
  let beweglich = range(geometry.seats.len()).filter(p => not scope.fixed.contains(p))

  let bestes = none
  let geprueft-gesamt = 0
  let laeufe = 0
  let z = calc.rem(calc.abs(seed) + 1, _m)

  if engine == "wasm" {
    let w = wasm-search(
      problem,
      geometry,
      scope,
      attempts: anzahl-versuche,
      max-steps: grenze,
      seed: seed,
      nobody-empty: nobody-empty,
      max-attempts: obergrenze,
    )
    let ergebnis = score-plan(problem, w.assignment)
    // Gegenprobe: Typst bewertet den gelieferten Plan unabhängig nach. Weicht
    // das ab, passen die beiden Fassungen nicht mehr zusammen – dann lieber
    // abbrechen als still falsch rechnen.
    if calc.abs(w.points - ergebnis.points) > 0.001 {
      fail(
        "typlace",
        fn,
        "das WASM-Plugin meldet "
          + str(w.points)
          + " Punkte, die Nachrechnung in Typst ergibt "
          + str(ergebnis.points)
          + " – mit `engine: \"typst\"` arbeiten und den Fehler melden",
      )
    }
    bestes = ergebnis + (steps: w.steps)
    geprueft-gesamt = w.checked
    laeufe = w.runs
  }

  // Leer ausgegangene Schüler eines bewerteten Plans zählen.
  let leere(ergebnis) = range(problem.student-count)
    .filter(i => problem.wishes.at(i).len() > 0 and ergebnis.details.at(i).fulfilled.len() == 0)
    .len()

  // Gleiche Blocklogik wie im Plugin (rust/src/lib.rs, `rechne`).
  let suchen = engine == "typst"
  while suchen {
    for _ in range(anzahl-versuche) {
      let start = _startplan(problem, scope, z)
      z = start.zustand
      let lauf = _verbessern(problem, start.assignment, scope, beweglich, grenze, z)
      z = lauf.zustand
      geprueft-gesamt += lauf.checked
      let ergebnis = score-plan(problem, lauf.assignment)
      let l = if nobody-empty { leere(ergebnis) } else { 0 }
      if bestes == none or l < bestes.empty or (l == bestes.empty and ergebnis.points > bestes.points) {
        bestes = ergebnis + (attempt: laeufe, steps: lauf.steps, empty: l)
      }
      laeufe += 1
    }
    if not nobody-empty or bestes == none or bestes.empty == 0 or laeufe >= obergrenze or anzahl-versuche == 0 {
      suchen = false
    }
  }

  let stat = statistics(problem, bestes)
  if stat.constraints-violated > 0 {
    fail(
      "typlace",
      fn,
      "die Vorgaben `apart`/`together` lassen sich mit diesem Raum nicht alle einhalten ("
        + str(stat.constraints-violated)
        + " Verletzungen im besten gefundenen Plan) – Vorgaben lockern oder das Layout ändern",
    )
  }

  (
    names: bestes.assignment.map(i => if i == none { "" } else { problem.students.at(i).name }),
    assignment: bestes.assignment,
    seat-of: bestes.seat-of,
    points: bestes.points,
    points-rounded: calc.round(bestes.points, digits: 1),
    details: bestes.details,
    statistics: stat,
    notes: data.notes,
    problem: problem,
    geometry: geometry,
    seed: seed,
    duration: duration,
    attempts: laeufe,
    attempts-block: anzahl-versuche,
    nobody-empty: nobody-empty,
    previous: previous.len(),
    steps: bestes.steps,
    checked: geprueft-gesamt,
  )
}
