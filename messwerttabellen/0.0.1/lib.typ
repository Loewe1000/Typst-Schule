#import "@schule/arbeitsblatt:0.1.6": *

// Definition der Datensatz-Struktur
#let datensatz(name, einheit, werte, prefix: "1") = (
  name: name,
  einheit: einheit,
  prefix: prefix,
  werte: werte,
)

// Definition der Datensatz-Struktur
#let messdaten(name, einheit, anzahl-messwerte, prefix: "1") = (
  name: name,
  einheit: einheit,
  prefix: prefix,
  werte: (anzahl-messwerte * ("",)),
)

#let multiplikatoren = (
  "G": 1e9,
  "M": 1e6,
  "k": 1e3,
  "": 1,
  "c": 1e-2,
  "m": 1e-3,
  "u": 1e-6,
  "n": 1e-9,
  "p": 1e-12,
)

// Funktion zur Umrechnung der Einheit
#let umrechnungseinheit(wert, einheit) = {
  for (k, v) in multiplikatoren {
    if calc.abs(wert) / v >= 1 {
      let umgerechneter_wert = wert / v
      return (v, k + einheit)
    }
  }
  (1, einheit)
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

// Funktion zur Berechnung von Werten basierend auf einem anderen Datensatz
#let berechnung(name, einheit, datensatz, formel, prefix: "1", max-digits: 2, auto-einheit: true, fehler: 0) = {
  let neue_werte = datensatz.werte.map(formel)
  if prefix != "1" {
    neue_werte = neue_werte.map(w => {w * float("1" + prefix)})
  } 
  if fehler != 0 {
    for (key, wert) in neue_werte.enumerate() {
      neue_werte.at(key) = wert * (1 + ((0.5 - rand(key)) * fehler / 100))
    }
  }
  if auto-einheit {
    let min-wert = none
    for (key, wert) in neue_werte.enumerate() {
      if key == 0 and calc.abs(wert) != 0 {
        min-wert = calc.abs(wert)
        break
      }
      if (min-wert == none or calc.abs(wert) < min-wert) and calc.abs(wert) != 0 {
        min-wert = calc.abs(wert)
      }
    }
    let (faktor, neue_einheit) = umrechnungseinheit(min-wert, einheit)
    let digits = calc.min(max-digits, calc.max(0, count_decimal_places(min-wert) - count_decimal_places(faktor)))
    neue_werte = neue_werte.map(wert => calc.round(wert / faktor, digits: digits))
    einheit = neue_einheit
  }
  (
    name: name,
    einheit: einheit,
    werte: neue_werte,
    prefix: prefix
  )
}

// Funktion zur Erstellung der Tabelle mit Styling für mehrere Datensätze
#let p_messwerttabelle(
  datensatze,
  row-height: auto,
  header: none,
) = tablex(
  stroke: 0.5pt,
  inset: 2.5mm,
  columns: (auto, ..(datensatze.at(0).werte.len()) * (1fr,)),
  rows: datensatze.len() * (row-height, ),
  align: (left + horizon, ..(datensatze.at(0).werte.len()) * (center + horizon,)),
  map-cells: c => {
    if c.x == 0 {
      c.fill = rgb(255,255,255).darken(5%)
    }
    if header != none {
      if c.y == 0 {
        c.fill = rgb(255,255,255).darken(5%)
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
      ((datensatz.name + " in " + if datensatz.prefix == "1" {unit(datensatz.einheit)} else {qty(datensatz.prefix, datensatz.einheit)}),
      ..datensatz.werte.map(x => $#x$))
    }

)

// Funktion zur Erstellung der Tabellen
#let messwerttabelle(datensatze, max_wert_pro_tabelle, row-height: auto, header: none, width: 100%) = {
  // Prüfen, ob die Daten aufgeteilt werden müssen
  let teile = ()
  let max = 0
  let max-key = 0
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
    daten.werte.chunks(max_wert_pro_tabelle).map(d => datensatz(daten.name, daten.einheit, d, prefix: daten.prefix))
  }

  let chunks-num = calc.ceil(datensatze.at(0).werte.len() / max_wert_pro_tabelle)
  for i in range(0, chunks-num) {
    for j in range(0, datensatze.len()) {
      teile.push(chunks.at(i + j * chunks-num))
    }
  }

  teile = teile.chunks(datensatze.len())

  for teil in teile {
    block(width: width, p_messwerttabelle(teil, row-height: row-height, header: header))
  }
}