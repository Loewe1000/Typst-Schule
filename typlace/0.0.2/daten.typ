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

#let _positionen = (
  // Tiefe: Abstand zur Tafel
  "v": (achse: "tiefe", wert: "vorne"),
  "vorne": (achse: "tiefe", wert: "vorne"),
  "vorn": (achse: "tiefe", wert: "vorne"),
  "m": (achse: "tiefe", wert: "mitte"),
  "mitte": (achse: "tiefe", wert: "mitte"),
  "mittig": (achse: "tiefe", wert: "mitte"),
  "h": (achse: "tiefe", wert: "hinten"),
  "hinten": (achse: "tiefe", wert: "hinten"),
  "hinter": (achse: "tiefe", wert: "hinten"),
  // Seite: quer zur Blickrichtung, aus Schülersicht
  "l": (achse: "seite", wert: "links"),
  "links": (achse: "seite", wert: "links"),
  "r": (achse: "seite", wert: "rechts"),
  "rechts": (achse: "seite", wert: "rechts"),
  "mitte-quer": (achse: "seite", wert: "mitte"),
  "quermitte": (achse: "seite", wert: "mitte"),
  "seitenmitte": (achse: "seite", wert: "mitte"),
)

#let _leere-position = (tiefe: none, seite: none)
#let _leeres-meidet = (tiefe: (), seite: ())

#let _verneinung = ("nicht", "kein", "keine", "nie", "bloß", "blos", "auf keinen fall")

#let _norm(s) = str(s).trim().replace(regex("\s+"), " ")
#let _key(s) = lower(_norm(s))

// ── Einlesen ───────────────────────────────────────────────────────

/// Rät das Spaltentrennzeichen. Tabellenprogramme exportieren je nach
/// Sprache und Einstellung mit `,`, `;` oder Tabulator; das Paket selbst
/// dokumentiert `|`. Gewählt wird das Zeichen, das in den meisten Zeilen
/// vorkommt, bei Gleichstand in der Reihenfolge | ; Tab , – so gewinnt ein
/// ausdrückliches `|` gegen Kommas, die in Namen stehen.
#let _trenner-erkennen(zeilen) = {
  let beste = "|"
  let bestwert = 0
  for kandidat in ("|", ";", "\t", ",") {
    let treffer = zeilen.filter(z => kandidat in z).len()
    if treffer > bestwert {
      bestwert = treffer
      beste = kandidat
    }
  }
  beste
}

/// Liest eine Wunschliste ein.
///
/// - quelle (str, array): Entweder ein mehrzeiliger String oder das
///   Ergebnis von `csv("wuensche.csv", delimiter: "|")`. Da Pakete keine
///   fremden Dateien lesen dürfen, muss `csv()` im Dokument aufgerufen
///   werden.
/// - trenner (auto, str): Spaltentrenner beim String-Format. `auto` erkennt
///   `|`, `;`, Tabulator oder `,` selbst.
/// - kopfzeile (auto, bool): Erste Zeile überspringen. `auto` erkennt
///   eine Kopfzeile daran, dass sie mit „Name" beginnt.
/// -> dictionary
#let schueler-lesen(quelle, trenner: auto, kopfzeile: auto) = {
  let rohzeilen = if type(quelle) == str {
    let zeilen = quelle
      .replace("\u{feff}", "") // Byte-Order-Mark aus Excel-Exporten
      .split("\n")
      .map(z => z.trim())
      .filter(z => z != "" and not z.starts-with("//") and not z.starts-with("#"))
    let zeichen = if trenner == auto { _trenner-erkennen(zeilen) } else { trenner }
    zeilen.map(z => z.split(zeichen))
  } else if type(quelle) == array {
    quelle.map(z => {
      if type(z) == array { z } else if type(z) == dictionary { z.values() } else { (str(z),) }
    })
  } else {
    panic("typlace: Die Wunschliste muss ein String oder ein Array sein (z. B. aus csv(..., delimiter: \"|\")).")
  }

  // Leerzeilen aus Tabellenprogrammen bestehen nur aus Trennzeichen
  let rohzeilen = rohzeilen.filter(z => z.len() > 0 and z.any(f => _norm(f) != ""))
  let ohne-namen = rohzeilen.filter(z => _norm(z.at(0)) == "")
  if ohne-namen.len() > 0 {
    panic(
      "typlace: "
        + str(ohne-namen.len())
        + " Zeile(n) haben keinen Namen in der ersten Spalte, tragen aber Wünsche: "
        + ohne-namen.map(z => z.map(_norm).filter(f => f != "").join("/")).join("; "),
    )
  }
  if rohzeilen.len() == 0 { panic("typlace: Die Wunschliste ist leer.") }

  let hat-kopf = if kopfzeile == auto {
    let erste = _key(rohzeilen.at(0).at(0))
    erste in ("name", "schüler", "schueler", "schülerin", "nachname", "vorname")
  } else { kopfzeile }
  let zeilen = if hat-kopf { rohzeilen.slice(1) } else { rohzeilen }

  let schueler = ()
  let hinweise = ()

  for z in zeilen {
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
          negativ.insert(eintrag.achse, (negativ.at(eintrag.achse) + (eintrag.wert,)).dedup())
        } else {
          positiv.insert(eintrag.achse, eintrag.wert)
        }
        verneint = false
      }

      if erkannt {
        position = positiv
        meidet = negativ
      } else {
        // Positionsspalte fehlt offenbar: Feld als Wunsch werten
        rest.push(roh)
        hinweise.push(
          "Zeile „" + name + "“: „" + roh + "“ ist keine Positionsangabe (vorne/mitte/hinten/links/rechts, auch verneint) und wurde als Wunsch gewertet.",
        )
      }
    }
    if z.len() > 2 { rest += z.slice(2).map(_norm) }

    let wuensche = ()
    let ablehnungen = ()
    for eintrag in rest.filter(e => e != "") {
      if eintrag.starts-with("!") {
        let n = _norm(eintrag.slice(1))
        if n != "" { ablehnungen.push(n) }
      } else {
        wuensche.push(eintrag)
      }
    }

    schueler.push((
      name: name,
      position: position,
      position-meidet: meidet,
      wuensche: wuensche,
      ablehnungen: ablehnungen,
    ))
  }

  (schueler: schueler, hinweise: hinweise)
}

// ── Prüfen und Namen auflösen ──────────────────────────────────────

/// Sucht zu einem geschriebenen Namen den passenden Klassenlisten-Eintrag.
/// Reihenfolge: exakt (unabhängig von Groß-/Kleinschreibung), dann
/// eindeutiger Präfix, dann eindeutiger Vorname.
#let _aufloesen(geschrieben, namen) = {
  let k = _key(geschrieben)
  let exakt = namen.filter(n => _key(n) == k)
  if exakt.len() == 1 { return exakt.first() }

  let praefix = namen.filter(n => _key(n).starts-with(k) or k.starts-with(_key(n)))
  if praefix.len() == 1 { return praefix.first() }

  let vorname = k.split(" ").at(0)
  let treffer = namen.filter(n => _key(n).split(" ").at(0) == vorname)
  if treffer.len() == 1 { return treffer.first() }

  none
}

/// Prüft die eingelesenen Schülerdaten und löst alle Wunsch- und
/// Ablehnungsnamen gegen die Klassenliste auf.
///
/// - daten (dictionary, array): Ergebnis von `schueler-lesen` oder direkt
///   ein Array von Schüler-Dictionaries.
/// - plaetze (int, none): Anzahl verfügbarer Sitzplätze zur Gegenprüfung.
/// - max-wuensche (int): Wünsche je Schüler; überzählige werden verworfen.
/// - streng (bool): Bei unbekannten Namen abbrechen statt nur zu warnen.
/// -> dictionary
#let schueler-pruefen(daten, plaetze: none, max-wuensche: 3, streng: true) = {
  let eingang = if type(daten) == dictionary { daten.schueler } else { daten }
  let hinweise = if type(daten) == dictionary { daten.at("hinweise", default: ()) } else { () }

  let namen = eingang.map(s => s.name)

  // Doppelte Namen sind fatal: Wünsche wären nicht mehr zuzuordnen.
  let gesehen = (:)
  let doppelt = ()
  for n in namen {
    let k = _key(n)
    if k in gesehen { doppelt.push(n) } else { gesehen.insert(k, true) }
  }
  if doppelt.len() > 0 {
    panic(
      "typlace: Doppelte Namen in der Wunschliste: "
        + doppelt.dedup().join(", ")
        + ". Bitte durch Nachnamen oder Anfangsbuchstaben eindeutig machen.",
    )
  }

  if plaetze != none and eingang.len() > plaetze {
    panic(
      "typlace: "
        + str(eingang.len())
        + " Schüler, aber nur "
        + str(plaetze)
        + " Sitzplätze im Layout.",
    )
  }

  let unbekannt = ()
  let schueler = ()

  // Closures dürfen in Typst keine äußeren Variablen ändern, deshalb gibt
  // `loese` Meldungen zurück, statt sie selbst zu sammeln.
  let loese(liste, art, eigener-name) = {
    let ergebnis = ()
    let fehlt = ()
    let meldungen = ()
    for w in liste {
      let treffer = _aufloesen(w, namen)
      if treffer == none {
        fehlt.push("„" + w + "“ (" + art + " von " + eigener-name + ")")
      } else if _key(treffer) == _key(eigener-name) {
        meldungen.push(eigener-name + ": Selbstnennung „" + w + "“ wurde entfernt.")
      } else if treffer not in ergebnis {
        ergebnis.push(treffer)
      }
    }
    (liste: ergebnis, unbekannt: fehlt, hinweise: meldungen)
  }

  for s in eingang {
    let w-roh = loese(s.at("wuensche", default: ()), "Wunsch", s.name)
    let a-roh = loese(s.at("ablehnungen", default: ()), "Ablehnung", s.name)
    unbekannt += w-roh.unbekannt + a-roh.unbekannt
    hinweise += w-roh.hinweise + a-roh.hinweise

    let wuensche = w-roh.liste
    let ablehnungen = a-roh.liste

    if wuensche.len() > max-wuensche {
      hinweise.push(
        s.name + ": " + str(wuensche.len()) + " Wünsche angegeben, nur die ersten " + str(max-wuensche) + " zählen.",
      )
      wuensche = wuensche.slice(0, max-wuensche)
    }
    // Wer abgelehnt wird, kann nicht gleichzeitig gewünscht sein.
    let konflikt = wuensche.filter(w => w in ablehnungen)
    if konflikt.len() > 0 {
      hinweise.push(s.name + ": " + konflikt.join(", ") + " gleichzeitig gewünscht und abgelehnt – Ablehnung gilt.")
      wuensche = wuensche.filter(w => w not in ablehnungen)
    }

    schueler.push((
      name: s.name,
      position: _leere-position + s.at("position", default: (:)),
      position-meidet: _leeres-meidet + s.at("position-meidet", default: (:)),
      wuensche: wuensche,
      ablehnungen: ablehnungen,
    ))
  }

  if unbekannt.len() > 0 {
    let text = "typlace: Diese Namen stehen nicht in der Klassenliste: " + unbekannt.join("; ") + "."
    if streng {
      panic(text + " Bitte Schreibweise angleichen oder streng: false setzen.")
    } else {
      hinweise.push(text + " Sie wurden ignoriert.")
    }
  }

  (schueler: schueler, hinweise: hinweise)
}

/// Bequemer Einzelaufruf: einlesen und prüfen in einem Schritt.
#let wunschliste(quelle, trenner: auto, kopfzeile: auto, plaetze: none, max-wuensche: 3, streng: true) = {
  schueler-pruefen(
    schueler-lesen(quelle, trenner: trenner, kopfzeile: kopfzeile),
    plaetze: plaetze,
    max-wuensche: max-wuensche,
    streng: streng,
  )
}
