// ═══════════════════════════════════════════════════════════════════
//  Daten: Wunschliste einlesen und prüfen
// ═══════════════════════════════════════════════════════════════════
//
//  Spaltenformat (Trennzeichen `|`):
//
//     Name | Position | Wunsch | Wunsch | !Ablehnung | ...
//
//  - Spalte 1: Name des Schülers (Pflicht)
//  - Spalte 2: Sitzwunsch im Raum, darf leer bleiben. Zwei unabhängige
//    Achsen, beliebig kombinierbar:
//        Tiefe: vorne | mitte | hinten   (v | m | h)
//        Seite: links | rechts           (l | r), Quermitte: mitte-quer
//    Verneinbar mit `!` oder „nicht": `!m`, `nicht mitte`, `!links`.
//    Beispiele: `v`, `v, l`, `!m`, `hinten rechts`, `nicht vorne`
//  - ab Spalte 3: beliebig viele Einträge; ein führendes `!` bedeutet
//    „möchte *nicht* neben dieser Person sitzen"
//
//  Beispiel:
//
//     Anna Meier|v|Ben Schulz|Clara Weiß|!Max Klein
//     Clara Weiß|!m|Anna Meier
//     Ben Schulz||Anna Meier
//     David Kern|h|

#import "internal/check.typ": fail, check-named, check-value, check-type, check-positional

// Neue Namen, die ausdrücklich gesetzt wurden (Wert weicht von der Vorgabe
// ab), zusammen mit dem Sink: so meldet `check-named` „alt und neu zugleich".
#let _gesetzt(deprecated, paare) = {
  let d = deprecated.named()
  for (name, paar) in paare {
    if paar.at(0) != paar.at(1) { d.insert(name, paar.at(0)) }
  }
  d
}

#let _positionen = (
  // Tiefe: Abstand zur Tafel
  "v": (axis: "depth", value: "front"),
  "vorne": (axis: "depth", value: "front"),
  "vorn": (axis: "depth", value: "front"),
  "m": (axis: "depth", value: "middle"),
  "mitte": (axis: "depth", value: "middle"),
  "mittig": (axis: "depth", value: "middle"),
  "h": (axis: "depth", value: "back"),
  "hinten": (axis: "depth", value: "back"),
  "hinter": (axis: "depth", value: "back"),
  // Seite: quer zur Blickrichtung, aus Schülersicht
  "l": (axis: "side", value: "left"),
  "links": (axis: "side", value: "left"),
  "r": (axis: "side", value: "right"),
  "rechts": (axis: "side", value: "right"),
  "mitte-quer": (axis: "side", value: "middle"),
  "quermitte": (axis: "side", value: "middle"),
  "seitenmitte": (axis: "side", value: "middle"),
)

#let _leere-position = (depth: none, side: none)
#let _leeres-meidet = (depth: (), side: ())

#let _verneinung = ("nicht", "kein", "keine", "nie", "bloß", "blos", "auf keinen fall")

#let _norm(s) = str(s).trim().replace(regex("\s+"), " ")
#let _key(s) = lower(_norm(s))

// ── Einlesen ───────────────────────────────────────────────────────

/// Rät das Spaltentrennzeichen. Tabellenprogramme exportieren je nach
/// Sprache und Einstellung mit `,`, `;` oder Tabulator; das Paket selbst
/// dokumentiert `|`. Gewählt wird das Zeichen, das in den meisten Zeilen
/// vorkommt, bei Gleichstand in der Reihenfolge | ; Tab , – so gewinnt ein
/// ausdrückliches `|` gegen Kommas, die in Namen stehen.
#let _trenner-erkennen(rows) = {
  let beste = "|"
  let bestwert = 0
  for kandidat in ("|", ";", "\t", ",") {
    let treffer = rows.filter(z => kandidat in z).len()
    if treffer > bestwert {
      bestwert = treffer
      beste = kandidat
    }
  }
  beste
}

/// Liest eine Wunschliste ein, ohne die Namen zu prüfen.
///
/// - source (str, array): Entweder ein mehrzeiliger String oder das
///   Ergebnis von `csv("wuensche.csv", delimiter: "|")`. Da Pakete keine
///   fremden Dateien lesen dürfen, muss `csv()` im Dokument aufgerufen
///   werden.
/// - delimiter (auto, str): Spaltentrenner beim String-Format. `auto` erkennt
///   `|`, `;`, Tabulator oder `,` selbst.
/// - header-row (auto, bool): Erste Zeile überspringen. `auto` erkennt
///   eine Kopfzeile daran, dass sie mit „Name" beginnt.
/// - caller (str): Name der öffentlichen Funktion für Fehlermeldungen.
/// -> dictionary
#let parse-students(source, delimiter: auto, header-row: auto, caller: "wunschliste") = {
  let rohzeilen = if type(source) == str {
    let rows = source
      .replace("\u{feff}", "") // Byte-Order-Mark aus Excel-Exporten
      .split("\n")
      .map(z => z.trim())
      .filter(z => z != "" and not z.starts-with("//") and not z.starts-with("#"))
    let character = if delimiter == auto { _trenner-erkennen(rows) } else { delimiter }
    rows.map(z => z.split(character))
  } else if type(source) == array {
    source.map(z => {
      if type(z) == array { z } else if type(z) == dictionary { z.values() } else { (str(z),) }
    })
  } else {
    fail(
      "typlace",
      caller,
      "die Wunschliste muss ein Text (`str`) oder ein Array sein, bekam `" + str(type(source)) + "` – zum Beispiel `read(\"wuensche.csv\")` oder `csv(\"wuensche.csv\", delimiter: \"|\")`",
    )
  }

  // Leerzeilen aus Tabellenprogrammen bestehen nur aus Trennzeichen
  let rohzeilen = rohzeilen.filter(z => z.len() > 0 and z.any(f => _norm(f) != ""))
  let ohne-namen = rohzeilen.filter(z => _norm(z.at(0)) == "")
  if ohne-namen.len() > 0 {
    fail(
      "typlace",
      caller,
      str(ohne-namen.len())
        + " Zeile(n) haben keinen Namen in der ersten Spalte, tragen aber Wünsche: "
        + ohne-namen.map(z => z.map(_norm).filter(f => f != "").join("/")).join("; ")
        + " – den Namen in die erste Spalte schreiben",
    )
  }
  if rohzeilen.len() == 0 {
    fail("typlace", caller, "die Wunschliste ist leer – je Schüler eine Zeile `Name|Position|Wunsch|…` angeben")
  }

  let hat-kopf = if header-row == auto {
    let erste = _key(rohzeilen.at(0).at(0))
    erste in ("name", "schüler", "schueler", "schülerin", "nachname", "vorname")
  } else { header-row }
  let rows = if hat-kopf { rohzeilen.slice(1) } else { rohzeilen }

  let students = ()
  let notes = ()

  for z in rows {
    let name = _norm(z.at(0))
    let position = _leere-position
    let meidet = _leeres-meidet
    let rest = ()

    if z.len() > 1 and _norm(z.at(1)) != "" {
      let roh = _norm(z.at(1))
      let teile = roh.split(regex("[,;/]|\\s+")).filter(t => t != "")

      // Bindestrich-Schreibweisen wie „vorne-rechts" oder „v-r" auftrennen.
      // Der Bindestrich ist kein allgemeiner Trenner, weil `mitte-quer` und
      // `nicht-mitte` als Einheit gelesen werden müssen – deshalb wird erst
      // der ganze Ausdruck nachgeschlagen und nur ein unbekannter zerlegt.
      teile = {
        let aus = ()
        for t in teile {
          let kern = _key(t)
          let vorsatz = ""
          for v in ("!", "nicht-", "kein-", "keine-") {
            if kern.starts-with(v) {
              vorsatz = v
              kern = kern.slice(v.len())
            }
          }
          if kern in _positionen or not kern.contains("-") {
            aus.push(t)
          } else {
            for (i, stueck) in kern.split("-").filter(x => x != "").enumerate() {
              aus.push(if i == 0 { vorsatz + stueck } else { stueck })
            }
          }
        }
        aus
      }

      let erkannt = true
      let verneint = false
      let positiv = _leere-position
      let negativ = _leeres-meidet

      for t in teile {
        let k = _key(t)
        if k in _verneinung {
          verneint = true
          continue
        }
        for vorsatz in ("!", "nicht-", "kein-", "keine-") {
          if k.starts-with(vorsatz) {
            verneint = true
            k = k.slice(vorsatz.len())
          }
        }
        if k not in _positionen {
          erkannt = false
          break
        }
        let eintrag = _positionen.at(k)
        if verneint {
          negativ.insert(eintrag.axis, (negativ.at(eintrag.axis) + (eintrag.value,)).dedup())
        } else {
          positiv.insert(eintrag.axis, eintrag.value)
        }
        verneint = false
      }

      if erkannt {
        position = positiv
        meidet = negativ
      } else {
        // Positionsspalte fehlt offenbar: Feld als Wunsch werten
        rest.push(roh)
        notes.push(
          "Zeile „" + name + "“: „" + roh + "“ ist keine Positionsangabe (vorne/mitte/hinten/links/rechts, auch verneint) und wurde als Wunsch gewertet.",
        )
      }
    }
    if z.len() > 2 { rest += z.slice(2).map(_norm) }

    let wishes = ()
    let rejections = ()
    for eintrag in rest.filter(e => e != "") {
      if eintrag.starts-with("!") {
        let n = _norm(eintrag.slice(1))
        if n != "" { rejections.push(n) }
      } else {
        wishes.push(eintrag)
      }
    }

    students.push((
      name: name,
      position: position,
      position-avoided: meidet,
      wishes: wishes,
      rejections: rejections,
    ))
  }

  (students: students, notes: notes)
}

// ── Prüfen und Namen auflösen ──────────────────────────────────────

/// Sucht zu einem geschriebenen Namen den passenden Klassenlisten-Eintrag.
/// Reihenfolge: exakt (unabhängig von Groß-/Kleinschreibung), dann
/// eindeutiger Präfix, dann eindeutiger Vorname.
#let _aufloesen(geschrieben, names) = {
  let k = _key(geschrieben)
  let exakt = names.filter(n => _key(n) == k)
  if exakt.len() == 1 { return exakt.first() }

  let praefix = names.filter(n => _key(n).starts-with(k) or k.starts-with(_key(n)))
  if praefix.len() == 1 { return praefix.first() }

  let vorname = k.split(" ").at(0)
  let treffer = names.filter(n => _key(n).split(" ").at(0) == vorname)
  if treffer.len() == 1 { return treffer.first() }

  none
}

/// Prüft Aufbau und Namen einer Wunschliste, ohne sie zu verändern: die
/// Schlüssel des Dictionaries (`students`, `notes`), die Schlüssel jedes
/// Eintrags und die Zonenwerte. Alte deutsche Namen (`wuensche`, `tiefe`,
/// `"vorne"`) würden sonst still übergangen.
///
/// Liefert `(students:, notes:)` mit genau den übergebenen Einträgen.
///
/// - data (dictionary, array): Ergebnis von `parse-students` oder von
///   `wunschliste`, oder direkt ein Array von Schüler-Dictionaries.
/// - caller (str): Name der öffentlichen Funktion für Fehlermeldungen.
/// -> dictionary
#let check-entries(data, caller: "wunschliste") = {
  if type(data) == dictionary {
    check-named(
      "typlace",
      caller,
      data,
      what: "Schlüssel",
      renamed: (schueler: "students", hinweise: "notes"),
      allowed: ("students", "notes"),
    )
    if "students" not in data {
      fail("typlace", caller, "der Wunschliste fehlt der Schlüssel `students` – das Ergebnis von `wunschliste(...)` übergeben")
    }
  }
  let eingang = if type(data) == dictionary { data.students } else { data }
  let notes = if type(data) == dictionary { data.at("notes", default: ()) } else { () }
  check-type("typlace", caller, "students", eingang, array, example: "((name: \"Anna\", wishes: (\"Ben\",)),)")
  check-type("typlace", caller, "notes", notes, array, example: "()")

  for s in eingang {
    check-type("typlace", caller, "students", s, dictionary, example: "(name: \"Anna\", wishes: (\"Ben\",))")
    check-named(
      "typlace",
      caller,
      s,
      what: "Schlüssel",
      renamed: (wuensche: "wishes", ablehnungen: "rejections", "position-meidet": "position-avoided"),
      allowed: ("name", "position", "position-avoided", "wishes", "rejections"),
    )
    if "name" not in s {
      fail("typlace", caller, "einem Eintrag der Wunschliste fehlt der Schlüssel `name` – `(name: \"Anna\", …)` schreiben")
    }
    for schluessel in ("wishes", "rejections") {
      check-type("typlace", caller, schluessel, s.at(schluessel, default: ()), array, example: "(\"Ben\",)")
    }
    for schluessel in ("position", "position-avoided") {
      let zonen = s.at(schluessel, default: (:))
      check-type("typlace", caller, schluessel, zonen, dictionary, example: if schluessel == "position" {
        "(depth: \"front\", side: \"left\")"
      } else { "(depth: (\"middle\",), side: ())" })
      check-named(
        "typlace",
        caller,
        zonen,
        what: "Schlüssel",
        renamed: (tiefe: "depth", seite: "side"),
        allowed: ("depth", "side"),
      )
      for (achse, erlaubt, alt) in (
        ("depth", ("front", "middle", "back"), (vorne: "front", mitte: "middle", hinten: "back")),
        ("side", ("left", "middle", "right"), (links: "left", mitte: "middle", rechts: "right")),
      ) {
        let eintrag = zonen.at(achse, default: none)
        let werte = if schluessel == "position" { (eintrag,) } else if eintrag == none { () } else { eintrag }
        for w in werte {
          check-value("typlace", caller, achse, w, if schluessel == "position" { (none,) } else { () } + erlaubt, renamed: alt)
        }
      }
    }
  }

  (students: eingang, notes: notes)
}

/// Prüft die eingelesenen Schülerdaten und löst alle Wunsch- und
/// Ablehnungsnamen gegen die Klassenliste auf.
///
/// - data (dictionary, array): Ergebnis von `parse-students` oder direkt
///   ein Array von Schüler-Dictionaries mit den Schlüsseln `name`,
///   `position`, `position-avoided`, `wishes` und `rejections`.
/// - seat-count (int, none): Anzahl verfügbarer Sitzplätze zur Gegenprüfung.
/// - max-wishes (int): Wünsche je Schüler; überzählige werden verworfen.
/// - strict (bool): Bei unbekannten Namen abbrechen statt nur zu warnen.
/// - caller (str): Name der öffentlichen Funktion für Fehlermeldungen.
/// -> dictionary
#let check-students(data, seat-count: none, max-wishes: 3, strict: true, caller: "wunschliste") = {
  let geprueft = check-entries(data, caller: caller)
  let eingang = geprueft.students
  let notes = geprueft.notes

  let names = eingang.map(s => s.name)

  // Doppelte Namen sind fatal: Wünsche wären nicht mehr zuzuordnen.
  let gesehen = (:)
  let doppelt = ()
  for n in names {
    let k = _key(n)
    if k in gesehen { doppelt.push(n) } else { gesehen.insert(k, true) }
  }
  if doppelt.len() > 0 {
    fail(
      "typlace",
      caller,
      "doppelte Namen in der Wunschliste: "
        + doppelt.dedup().join(", ")
        + " – durch Nachnamen oder Anfangsbuchstaben eindeutig machen",
    )
  }

  if seat-count != none and eingang.len() > seat-count {
    fail(
      "typlace",
      caller,
      str(eingang.len())
        + " Schüler, aber nur "
        + str(seat-count)
        + " Sitzplätze im Layout – Plätze im Layout ergänzen oder die Wunschliste kürzen",
    )
  }

  let unbekannt = ()
  let students = ()

  // Closures dürfen in Typst keine äußeren Variablen ändern, deshalb gibt
  // `loese` Meldungen zurück, statt sie selbst zu sammeln.
  let loese(liste, kind, eigener-name) = {
    let ergebnis = ()
    let fehlt = ()
    let meldungen = ()
    for w in liste {
      let treffer = _aufloesen(w, names)
      if treffer == none {
        fehlt.push("„" + w + "“ (" + kind + " von " + eigener-name + ")")
      } else if _key(treffer) == _key(eigener-name) {
        meldungen.push(eigener-name + ": Selbstnennung „" + w + "“ wurde entfernt.")
      } else if treffer not in ergebnis {
        ergebnis.push(treffer)
      }
    }
    (liste: ergebnis, unbekannt: fehlt, notes: meldungen)
  }

  for s in eingang {
    let w-roh = loese(s.at("wishes", default: ()), "Wunsch", s.name)
    let a-roh = loese(s.at("rejections", default: ()), "Ablehnung", s.name)
    unbekannt += w-roh.unbekannt + a-roh.unbekannt
    notes += w-roh.notes + a-roh.notes

    let wishes = w-roh.liste
    let rejections = a-roh.liste

    if wishes.len() > max-wishes {
      notes.push(
        s.name + ": " + str(wishes.len()) + " Wünsche angegeben, nur die ersten " + str(max-wishes) + " zählen.",
      )
      wishes = wishes.slice(0, max-wishes)
    }
    // Wer abgelehnt wird, kann nicht gleichzeitig gewünscht sein.
    let konflikt = wishes.filter(w => w in rejections)
    if konflikt.len() > 0 {
      notes.push(s.name + ": " + konflikt.join(", ") + " gleichzeitig gewünscht und abgelehnt – Ablehnung gilt.")
      wishes = wishes.filter(w => w not in rejections)
    }

    students.push((
      name: s.name,
      position: _leere-position + s.at("position", default: (:)),
      position-avoided: _leeres-meidet + s.at("position-avoided", default: (:)),
      wishes: wishes,
      rejections: rejections,
    ))
  }

  if unbekannt.len() > 0 {
    let text = "typlace: Diese Namen stehen nicht in der Klassenliste: " + unbekannt.join("; ") + "."
    if strict {
      fail(
        "typlace",
        caller,
        "diese Namen stehen nicht in der Klassenliste: "
          + unbekannt.join("; ")
          + " – Schreibweise angleichen oder `strict: false` setzen",
      )
    } else {
      notes.push(text + " Sie wurden ignoriert.")
    }
  }

  (students: students, notes: notes)
}

/// Liest eine Wunschliste ein und prüft sie: Die Namen in den Wünschen und
/// Ablehnungen werden gegen die Klassenliste (erste Spalte) aufgelöst.
///
/// Das Ergebnis ist ein Dictionary mit den Schlüsseln `students` (je Schüler
/// `name`, `position`, `position-avoided`, `wishes`, `rejections`) und
/// `notes` (Hinweise zur Liste). Es geht unverändert an `sitzordnung`.
///
/// Spaltenformat (Trennzeichen `|`): `Name|Position|Wunsch|Wunsch|!Ablehnung`.
/// Die Positionsangaben in der Liste sind Daten und bleiben deutsch
/// (`vorne`, `mitte`, `hinten`, `links`, `rechts`, kurz `v`, `m`, `h`, `l`, `r`).
///
/// - source (str, array): Entweder ein mehrzeiliger String (etwa aus
///   `read("wuensche.csv")`) oder das Ergebnis von
///   `csv("wuensche.csv", delimiter: "|")`. Da Pakete keine fremden Dateien
///   lesen dürfen, muss die Datei im Dokument gelesen werden.
/// - delimiter (auto, str): Spaltentrenner beim String-Format. `auto` erkennt
///   `|`, `;`, Tabulator oder `,` selbst.
/// - header-row (auto, bool): Erste Zeile überspringen. `auto` erkennt
///   eine Kopfzeile daran, dass sie mit „Name" beginnt.
/// - seat-count (int, none): Anzahl verfügbarer Sitzplätze zur Gegenprüfung.
/// - max-wishes (int): Wünsche je Schüler; überzählige werden verworfen.
/// - strict (bool): Bei unbekannten Namen abbrechen statt nur zu warnen.
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> dictionary
#let wunschliste(
  source,
  delimiter: auto,
  header-row: auto,
  seat-count: none,
  max-wishes: 3,
  strict: true,
  ..deprecated,
) = {
  check-positional(
    "typlace",
    "wunschliste",
    deprecated,
    hint: "nur die Wunschliste steht vorn – alles andere benannt schreiben (`delimiter: \";\"`)",
  )
  check-named(
    "typlace",
    "wunschliste",
    _gesetzt(deprecated, (
      delimiter: (delimiter, auto),
      header-row: (header-row, auto),
      seat-count: (seat-count, none),
      max-wishes: (max-wishes, 3),
      strict: (strict, true),
    )),
    renamed: (
      trenner: "delimiter",
      kopfzeile: "header-row",
      plaetze: "seat-count",
      max-wuensche: "max-wishes",
      streng: "strict",
    ),
    allowed: ("delimiter", "header-row", "seat-count", "max-wishes", "strict"),
  )
  check-type("typlace", "wunschliste", "source", source, (str, array), example: "read(\"wuensche.csv\")")
  check-type("typlace", "wunschliste", "delimiter", delimiter, (str, auto), example: "\";\"")
  check-type("typlace", "wunschliste", "header-row", header-row, (bool, auto))
  check-type("typlace", "wunschliste", "seat-count", seat-count, (int, none), example: "30")
  check-type("typlace", "wunschliste", "max-wishes", max-wishes, int, example: "3")
  check-type("typlace", "wunschliste", "strict", strict, bool)
  check-students(
    parse-students(source, delimiter: delimiter, header-row: header-row),
    seat-count: seat-count,
    max-wishes: max-wishes,
    strict: strict,
  )
}
