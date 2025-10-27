#import "@preview/fancy-units:0.1.1": qty, unit, add-macros
#import "@preview/zero:0.5.0": num as znum
#import "@schule/random:0.0.1": *

#add-macros(
  u: sym.mu,
  ohm: sym.Omega,
)

// Definition der Datensatz-Struktur (ohne auto-einheit, kommt später)
#let datensatz(name, einheit, werte, prefix: "1", max-digits: none, auto-einheit: false) = {
  // Wenn ein expliziter prefix gesetzt ist, deaktiviere auto-einheit
  if prefix != "1" {
    auto-einheit = false
  }
  
  // Werte speichern (auto-einheit wird später in apply_auto_einheit angewendet)
  let result = (
    name: name,
    einheit: einheit,
    prefix: prefix,
    werte: werte,
    auto-einheit: auto-einheit,  // Temporär speichern
    max-digits: max-digits,
  )
  
  result
}

// Definition der Datensatz-Struktur
#let messdaten(name, einheit, anzahl-messwerte, prefix: "1") = (
  name: name,
  einheit: einheit,
  prefix: prefix,
  werte: (anzahl-messwerte * ("",)),
)

#let multiplikatoren = (
  "Q": 1e30,   // Quetta
  "R": 1e27,   // Ronna
  "Y": 1e24,   // Yotta
  "Z": 1e21,   // Zetta
  "E": 1e18,   // Exa
  "P": 1e15,   // Peta
  "T": 1e12,   // Tera
  "G": 1e9,    // Giga
  "M": 1e6,    // Mega
  "k": 1e3,    // Kilo
  "": 1,
  "c": 1e-2,   // Zenti
  "m": 1e-3,   // Milli
  "u": 1e-6,   // Mikro (μ)
  "n": 1e-9,   // Nano
  "p": 1e-12,  // Piko
  "f": 1e-15,  // Femto
  "a": 1e-18,  // Atto
  "z": 1e-21,  // Zepto
  "y": 1e-24,  // Yokto
  "r": 1e-27,  // Ronto
  "q": 1e-30,  // Quekto
)

// Funktion zur Umrechnung der Einheit
#let umrechnungseinheit(wert, einheit) = {
  // Debug: Prüfe Eingabewerte
  if type(wert) != float and type(wert) != int {
    return (1, einheit)
  }
  if calc.abs(wert) == 0 {
    return (1, einheit)
  }

  // Erst prüfen, ob die Einheit bereits einen Prefix hat
  let basis_einheit = einheit
  let aktueller_prefix_wert = 1

  // Erkenne aktuellen Prefix in der Einheit - aber nicht bei einzelnen Buchstaben!
  if type(einheit) == str and einheit.len() > 1 {
    for (prefix_key, prefix_value) in multiplikatoren {
      if prefix_key != "" and einheit.starts-with(prefix_key) {
        aktueller_prefix_wert = prefix_value
        basis_einheit = einheit.slice(prefix_key.len())
        break
      }
    }
  }

  // Wert in Basiseinheit umrechnen
  let wert_in_basis = wert * aktueller_prefix_wert

  // Suche den besten Prefix für die Darstellung (von groß zu klein)
  let prefix_liste = (
    ("Q", 1e30),  // Quetta
    ("R", 1e27),  // Ronna
    ("Y", 1e24),  // Yotta
    ("Z", 1e21),  // Zetta
    ("E", 1e18),  // Exa
    ("P", 1e15),  // Peta
    ("T", 1e12),  // Tera
    ("G", 1e9),   // Giga
    ("M", 1e6),   // Mega
    ("k", 1e3),   // Kilo
    ("", 1),
    ("c", 1e-2),  // Zenti
    ("m", 1e-3),  // Milli
    ("u", 1e-6),  // Mikro
    ("n", 1e-9),  // Nano
    ("p", 1e-12), // Piko
    ("f", 1e-15), // Femto
    ("a", 1e-18), // Atto
    ("z", 1e-21), // Zepto
    ("y", 1e-24), // Yokto
    ("r", 1e-27), // Ronto
    ("q", 1e-30), // Quekto
  )

  for (prefix_key, prefix_value) in prefix_liste {
    let neuer_wert = calc.abs(wert_in_basis) / prefix_value
    if neuer_wert >= 1 and neuer_wert < 1000 {
      let neue_einheit = if prefix_key == "" { basis_einheit } else { prefix_key + basis_einheit }
      return (prefix_value / aktueller_prefix_wert, neue_einheit)
    }
  }

  // Fallback: Wenn keine passende Einheit gefunden wurde, nutze Basiseinheit ohne Präfix
  // (Dies tritt bei sehr großen oder sehr kleinen Zahlen auf)
  return (1 / aktueller_prefix_wert, basis_einheit)
}

// Hilfsfunktion: Automatische Einheitenumrechnung für ein Array von Werten
#let auto_einheit_anwenden(werte, einheit) = {
  // Nur bei String-Einheiten anwenden
  if type(einheit) != str {
    return (werte, einheit)
  }
  
  // Finde den kleinsten nicht-null Wert
  let min-wert = none
  for wert in werte {
    if type(wert) != content and wert != none and calc.abs(wert) != 0 {
      if min-wert == none or calc.abs(wert) < min-wert {
        min-wert = calc.abs(wert)
      }
    }
  }

  // Wenn ein minimaler Wert gefunden wurde, rechne um
  if min-wert != none {
    let (faktor, neue_einheit) = umrechnungseinheit(min-wert, einheit)
    if neue_einheit != none and neue_einheit != "" and faktor != 1 {
      let neue_werte = werte.map(wert => {
        if type(wert) == content or wert == none {
          return wert
        }
        return wert / faktor
      })
      return (neue_werte, neue_einheit)
    }
  }
  
  // Keine Änderung
  return (werte, einheit)
}

// Funktion zur Berechnung der Anzahl der Nachkommastellen
#let count_decimal_places(wert) = {
  if type(wert) == content {
    return 0
  }
  let wert_str = str(wert)
  if wert_str.contains(".") {
    wert_str.split(".").at(1).len()
  } else {
    0
  }
}

// Funktion zur Berechnung von Werten basierend auf einem oder mehreren Datensätzen
#let berechnung(name, einheit, datensaetze, formel, prefix: "1", auto-einheit: true, fehler: 0, max-digits: none) = {
  // Wenn ein expliziter prefix gesetzt ist, deaktiviere auto-einheit
  if prefix != "1" {
    auto-einheit = false
  }
  
  // Unterstützung für einzelnen Datensatz (Rückwärtskompatibilität)
  let datensatz_liste = if type(datensaetze) == array { datensaetze } else { (datensaetze,) }

  // Schritt 1: Alle Eingabewerte in Basiseinheiten umrechnen (VOR der Berechnung)
  let alle_umgerechneten_werte = ()

  for datensatz in datensatz_liste {
    let umgerechnete_werte = datensatz.werte.map(wert => {
      if type(wert) == content or wert == none {
        return wert
      }

      // Multiplikator für die Einheit des Datensatzes finden
      let datensatz_multiplikator = 1
      if datensatz.prefix != "1" {
        if datensatz.prefix.starts-with("e") {
          datensatz_multiplikator = calc.pow(10, int(datensatz.prefix.slice(1)))
        } else if datensatz.prefix in multiplikatoren {
          datensatz_multiplikator = multiplikatoren.at(datensatz.prefix)
        }
      }

      // Zusätzlich prüfen, ob die Einheit selbst einen Prefix enthält
      if datensatz.einheit != none and type(datensatz.einheit) == str {
        for (prefix_key, prefix_value) in multiplikatoren {
          if prefix_key != "" and datensatz.einheit.starts-with(prefix_key) {
            datensatz_multiplikator = datensatz_multiplikator * prefix_value
            break
          }
        }
      }

      return wert * datensatz_multiplikator
    })
    alle_umgerechneten_werte.push(umgerechnete_werte)
  }

  // Schritt 2: Formel anwenden (arbeitet mit Basiseinheiten)
  let neue_werte = ()

  // Bestimme die Anzahl der Werte (sollte für alle Datensätze gleich sein)
  let anzahl_werte = alle_umgerechneten_werte.at(0).len()

  for i in range(anzahl_werte) {
    // Extrahiere die i-ten Werte aus allen Datensätzen
    let parameter_werte = ()
    let hat_leeren_wert = false

    for j in range(alle_umgerechneten_werte.len()) {
      let wert = alle_umgerechneten_werte.at(j).at(i)
      if type(wert) == content or wert == none {
        hat_leeren_wert = true
        break
      }
      parameter_werte.push(wert)
    }

    // Wenn einer der Parameter leer ist, überspringe diese Berechnung
    if hat_leeren_wert {
      neue_werte.push(none)
    } else {
      // Rufe die Formel mit allen Parametern auf
      if parameter_werte.len() == 1 {
        neue_werte.push(formel(parameter_werte.at(0)))
      } else if parameter_werte.len() == 2 {
        neue_werte.push(formel(parameter_werte.at(0), parameter_werte.at(1)))
      } else if parameter_werte.len() == 3 {
        neue_werte.push(formel(parameter_werte.at(0), parameter_werte.at(1), parameter_werte.at(2)))
      } else if parameter_werte.len() == 4 {
        neue_werte.push(formel(parameter_werte.at(0), parameter_werte.at(1), parameter_werte.at(2), parameter_werte.at(3)))
      } else if parameter_werte.len() == 5 {
        neue_werte.push(formel(parameter_werte.at(0), parameter_werte.at(1), parameter_werte.at(2), parameter_werte.at(3), parameter_werte.at(4)))
      } else {
        // Fallback für mehr Parameter - kann bei Bedarf erweitert werden
        panic("Zu viele Parameter für die Formel. Maximal 5 Datensätze unterstützt.")
      }
    }
  }

  // Schritt 3: Ergebnis in Zieleinheit umrechnen (NACH der Berechnung)
  // Multiplikator für die Zieleinheit finden
  let ziel_multiplikator = 1
  if prefix != "1" {
    if prefix.starts-with("e") {
      ziel_multiplikator = calc.pow(10, int(prefix.slice(1)))
    } else if prefix in multiplikatoren {
      ziel_multiplikator = multiplikatoren.at(prefix)
    } else {
      ziel_multiplikator = float("1" + prefix)
    }
  }

  // Zusätzlich prüfen, ob die Zieleinheit selbst einen Prefix enthält
  if einheit != none and type(einheit) == str and einheit.len() > 1 {
    for (prefix_key, prefix_value) in multiplikatoren {
      if prefix_key != "" and einheit.starts-with(prefix_key) {
        ziel_multiplikator = ziel_multiplikator * prefix_value
        break
      }
    }
  }

  // Ergebnis in Zieleinheit umrechnen
  neue_werte = neue_werte.map(w => { w / ziel_multiplikator })

  // Schritt 4: Fehler hinzufügen falls gewünscht
  if fehler != 0 {
    for (key, wert) in neue_werte.enumerate() {
      neue_werte.at(key) = wert * (1 + ((0.5 - rand(key)) * (fehler/1%) / 100))
    }
  }

  // Schritt 5: Automatische Einheitenumrechnung (optional)
  if auto-einheit {
    let min-wert = none
    for (key, wert) in neue_werte.enumerate() {
      if type(wert) == content or wert == none {
        continue
      }
      if calc.abs(wert) != 0 {
        if min-wert == none or calc.abs(wert) < min-wert {
          min-wert = calc.abs(wert)
        }
      }
    }

    if min-wert != none {
      let (faktor, neue_einheit) = umrechnungseinheit(min-wert, einheit)
      // Debug: Prüfe ob neue_einheit gültig ist
      if neue_einheit != none and neue_einheit != "" and faktor != 1 {
        neue_werte = neue_werte.map(wert => {
          if type(wert) == content or wert == none {
            return wert
          }
          return wert / faktor
        })
        einheit = neue_einheit
      }
    }
  }
  (
    name: name,
    einheit: einheit,
    werte: neue_werte,
    prefix: prefix,
    max-digits: max-digits,
  )
}

// Funktion zur Erstellung der Tabelle mit Styling für mehrere Datensätze
#let p_messwerttabelle(
  datensatze,
  row-height: auto,
  header: none,
  max-digits: 2,
) = [
  #import "@preview/tablex:0.0.9": *
  #tablex(
    stroke: 0.5pt,
    inset: 2.5mm,
    columns: (auto, ..(datensatze.at(0).werte.len()) * (1fr,)),
    rows: datensatze.len() * (row-height,),
    align: (left + horizon, ..(datensatze.at(0).werte.len()) * (center + horizon,)),
    map-cells: c => {
      if c.x == 0 {
        c.fill = rgb(255, 255, 255).darken(5%)
      }
      if header != none {
        if c.y == 0 {
          c.fill = rgb(255, 255, 255).darken(5%)
        }
      }
      c
    },

    // Kopfzeilen und Datenzeilen der Tabelle
    ..if header != none {
      while header.len() < datensatze.at(0).werte.len() {
        header.push([])
      }
      ([],) + header.map(c => strong(c))
    },

    ..for datensatz in datensatze {
      // Prüfen, ob irgendein Wert echte Nachkommastellen hat
      let has_decimals = false
      for wert in datensatz.werte {
        if type(wert) != content and wert != none {
          let wert_str = str(wert)
          if wert_str.contains(".") {
            let decimal_part = wert_str.split(".").at(1)
            // Prüfen, ob die Nachkommastellen nicht nur aus Nullen bestehen
            let only_zeros = true
            for char in decimal_part {
              if char != "0" {
                only_zeros = false
                break
              }
            }
            if not only_zeros {
              has_decimals = true
              break
            }
          }
        }
      }

      // Verwende max-digits aus dem Datensatz, falls vorhanden, sonst den globalen Wert
      let datensatz_max_digits = if "max-digits" in datensatz and datensatz.max-digits != none {
        datensatz.max-digits
      } else {
        max-digits
      }

      (
        (datensatz.name + if datensatz.einheit != none and datensatz.einheit != "" { 
          " in " + if type(datensatz.einheit) == content {
            // Bei content (z.B. $Omega$) direkt ausgeben ohne qty
            datensatz.einheit
          } else if datensatz.prefix == "1" { 
            unit(per-mode: "fraction")[#datensatz.einheit] 
          } else { 
            // Bei prefix != "1": Verwende unit[] mit manuell kombiniertem Prefix
            // statt qty[], um fancy-units Fehler zu vermeiden
            unit(per-mode: "fraction")[#(datensatz.prefix + datensatz.einheit)]
          } 
        }),
        ..datensatz.werte.map(x => {
          // Leere oder fehlende Zellen leer lassen, Content direkt ausgeben, Zahlen formatieren
          if x == none or x == "" { [] }
          else if type(x) == content { x }
          else { $#znum(x, decimal-separator: ",", round: (mode: "places", precision: datensatz_max_digits, pad: has_decimals, direction: "nearest"))$ }
        }),
      )
    },
  )]

// Funktion zur Erstellung der Tabellen
#let messwerttabelle(..args, amount: auto, row-height: auto, header: none, width: 100%, max-digits: 2) = {
  // Extrahiere positionale Argumente
  let datensatze = args.pos()
  
  // Prüfe verschiedene Eingabe-Formate:
  // 1. Einzelner Datensatz: messwerttabelle(dataset)
  // 2. Array von Datensätzen: messwerttabelle((d1, d2, d3))
  // 3. Mehrere Datensätze: messwerttabelle(d1, d2, d3)
  
  if datensatze.len() == 1 {
    let first = datensatze.at(0)
    // Wenn ein einzelnes Argument ein Array ist, verwende es
    if type(first) == array {
      datensatze = first
    }
    // Wenn ein einzelnes Argument ein Dictionary mit "werte" ist, mache Array daraus
    else if type(first) == dictionary and "werte" in first {
      datensatze = (first,)
    }
  }
  // Wenn mehrere Argumente übergeben wurden, verwende sie direkt als Array
  // (bereits in datensatze durch args.pos())
  
  // Auto-Einheit auf alle Datensätze anwenden, falls aktiviert
  datensatze = datensatze.map(ds => {
    if "auto-einheit" in ds and ds.auto-einheit {
      let (neue_werte, neue_einheit) = auto_einheit_anwenden(ds.werte, ds.einheit)
      let result = ds
      result.werte = neue_werte
      result.einheit = neue_einheit
      result
    } else {
      ds
    }
  })
  
  // Prüfen, ob die Daten aufgeteilt werden müssen
  let teile = ()
  let max = 0
  let max-key = 0
  let max_wert_pro_tabelle = if amount == auto { datensatze.at(0).werte.len() } else { amount }
  for (key, daten) in datensatze.enumerate() {
    if daten.werte.len() > max {
      max = daten.werte.len()
      max-key = key
    }
  }

  for (key, daten) in datensatze.enumerate() {
    while datensatze.at(key).werte.len() < max {
      datensatze.at(key).werte.push(none)
    }
  }

  let chunks = for daten in datensatze {
    daten.werte.chunks(max_wert_pro_tabelle).map(d => datensatz(daten.name, daten.einheit, d, prefix: daten.prefix, max-digits: daten.at("max-digits", default: none)))
  }

  let chunks-num = calc.ceil(datensatze.at(0).werte.len() / max_wert_pro_tabelle)
  for i in range(0, chunks-num) {
    for j in range(0, datensatze.len()) {
      teile.push(chunks.at(i + j * chunks-num))
    }
  }

  teile = teile.chunks(datensatze.len())

  for teil in teile {
    block(width: width, p_messwerttabelle(teil, row-height: row-height, header: header, max-digits: max-digits))
  }
}
