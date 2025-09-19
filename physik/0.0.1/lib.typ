#import "@preview/zap:0.2.1" as zap
#import "@preview/unify:0.7.0": *
#import "@preview/zero:0.5.0": num as znum
#import "@schule/random:0.0.1": *

#let schaltkreis = zap.canvas

#let simple-source(name, node, current: "dc", flipped: false, flipped-side: false, ..params) = {
  assert(current in ("dc", "ac"), message: "current must be ac or dc")

  // New component style
  let style = (
    width: 1.0,
    height: 0.4,
    radius: 0.15,
  )

  // Drawing function
  let draw(ctx, position, style) = {
    zap.interface((-style.width * 0.4, -style.height / 2), (style.width * 0.4, style.height / 2), io: position.len() < 2)

    zap.draw.circle((-style.width * 0.4, 0), radius: style.radius, fill: white, ..style)
    zap.draw.circle((style.width * 0.4, 0), radius: style.radius, fill: white, ..style)
    if current == "dc" {
      let flipped = if flipped { -1 } else { 1 }
      let flipped-side = if flipped-side { -style.height } else { style.height }
      zap.draw.content((flipped * style.width * 0.4, flipped-side), text(top-edge: "bounds", bottom-edge: "bounds", 12pt, $+$))
      zap.draw.content((flipped * -style.width * 0.4, flipped-side), text(top-edge: "x-height", bottom-edge: "bounds", 12pt, $-$))
    }
  }

  // Componant call
  zap.component("square", name, node, draw: draw, style: style, ..params)
}

#let multimeter(name, node, ..params) = {
  // New component style
  let style = (
    radius: .53 * 0.75,
    padding: .15,
  )

  // Drawing function
  let draw(ctx, position, style) = {
    zap.interface((-style.radius, -style.radius), (style.radius, style.radius), io: position.len() < 2)

    zap.draw.circle((0, 0), radius: 0.1, fill: white, ..style)
    zap.draw.content((0, 0), schaltkreis({ zap.draw.line((45deg, -0.8 * style.radius), (45deg + 180deg, -0.8 * style.radius), mark: (end: (symbol: ">", fill: black))) }))
  }

  // Componant call
  zap.component("square", name, node, draw: draw, style: style, ..params)
}

// Definition der Datensatz-Struktur
#let datensatz(name, einheit, werte, prefix: "1", max-digits: none) = (
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

// Funktion für lineare Regression
#let lineare_regression(x_werte, y_werte) = {
  // Prüfen, ob die Arrays die gleiche Länge haben
  assert(x_werte.len() == y_werte.len(), message: "x_werte und y_werte müssen die gleiche Länge haben")
  assert(x_werte.len() >= 2, message: "Mindestens 2 Datenpunkte erforderlich")

  let n = x_werte.len()

  // Mittelwerte berechnen
  let x_mittel = x_werte.sum() / n
  let y_mittel = y_werte.sum() / n

  // Steigung (a) berechnen: a = Σ((x_i - x̄)(y_i - ȳ)) / Σ((x_i - x̄)²)
  let zaehler = 0
  let nenner = 0

  for i in range(n) {
    let x_diff = x_werte.at(i) - x_mittel
    let y_diff = y_werte.at(i) - y_mittel
    zaehler += x_diff * y_diff
    nenner += x_diff * x_diff
  }

  let a = zaehler / nenner
  let b = y_mittel - a * x_mittel

  // Gleichung als Content zurückgeben
  (m: a, b: b)
}

#let regressionen = (
  lineare_regression: lineare_regression,
)

// Funktion zur Berechnung von Werten basierend auf einem anderen Datensatz
#let berechnung(name, einheit, datensatz, formel, prefix: "1", auto-einheit: true, fehler: 0) = {
  // Erst die ursprünglichen Werte mit dem Multiplikator der Einheit umrechnen
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
    if datensatz.einheit != none {
      for (prefix_key, prefix_value) in multiplikatoren {
        if prefix_key != "" and datensatz.einheit.starts-with(prefix_key) {
          datensatz_multiplikator = datensatz_multiplikator * prefix_value
          break
        }
      }
    }

    return wert * datensatz_multiplikator
  })

  let neue_werte = umgerechnete_werte.map(formel)
  if prefix != "1" {
    let prefix_factor = if prefix.starts-with("e") {
      calc.pow(10, int(prefix.slice(1)))
    } else if prefix in multiplikatoren {
      multiplikatoren.at(prefix)
    } else {
      float("1" + prefix)
    }
    neue_werte = neue_werte.map(w => { w / prefix_factor })
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
    let digits = calc.max(0, count_decimal_places(min-wert) - count_decimal_places(faktor))
    neue_werte = neue_werte.map(wert => wert / faktor)
    einheit = neue_einheit
  }
  (
    name: name,
    einheit: einheit,
    werte: neue_werte,
    prefix: prefix,
    max-digits: none,
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

      (
        (datensatz.name + if datensatz.einheit != none { " in " + if datensatz.prefix == "1" { unit(datensatz.einheit) } else { qty(datensatz.prefix, datensatz.einheit) } }),
        ..datensatz.werte.map(x => if x != "" { $#znum(x, decimal-separator: ",", round: (mode: "places", precision: max-digits, pad: has_decimals, direction: "nearest"))$ }),
      )
    },
  )]

// Funktion zur Erstellung der Tabellen
#let messwerttabelle(datensatze, max_wert_pro_tabelle, row-height: auto, header: none, width: 100%, max-digits: 2) = {
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
