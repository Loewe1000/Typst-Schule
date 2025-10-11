#import "@preview/zap:0.4.0" as zap
#import "@preview/unify:0.7.0": *
#import "@preview/zero:0.5.0": num as znum
#import "@schule/random:0.0.1": *

#let schaltkreis = zap.circuit

#let source(name, node, current: "dc", variant: "symbol", flipped: false, ..params) = {
  assert(current in ("dc", "ac"), message: "current must be ac or dc")
  assert(variant in ("symbol", "lines"), message: "variant must be 'symbol' or 'lines'")

  // New component style
  let style = (
    width: 1.0,
    height: 0.4,
    radius: 0.18,
  )

  // Drawing function
  let draw(ctx, position, style) = {
    if current == "dc" and variant == "lines" {
      zap.interface((-style.width * 0.1, -style.height), (style.width * 0.1, style.height), io: position.len() < 2)
      // Alternative Darstellung mit Strichen (lang und kurz)
      let long-line-height = 0.45
      let short-line-height = 0.25
      let line-spacing = 0.1
      let flipped-multiplier = if flipped { -1 } else { 1 }
      
      // Langer Strich (positiv)
      zap.draw.line(
        (flipped-multiplier * line-spacing, -long-line-height),
        (flipped-multiplier * line-spacing, long-line-height),
        stroke: (thickness: .8pt, paint: black)
      )
      
      // Kurzer Strich (negativ)
      zap.draw.line(
        (flipped-multiplier * -line-spacing, -short-line-height),
        (flipped-multiplier * -line-spacing, short-line-height),
        stroke: (thickness: .8pt, paint: black)
      )
    } else {
      zap.interface((-style.width * 0.4, -style.height / 2), (style.width * 0.4, style.height / 2), io: position.len() < 2)
      // Kreise für symbol-style und AC
      zap.draw.circle((-style.width * 0.4, 0), radius: style.radius, fill: white, ..style)
      zap.draw.circle((style.width * 0.4, 0), radius: style.radius, fill: white, ..style)
      
      if current == "dc" {
        // Standard DC: + und - Symbole
        let flipped-multiplier = if flipped { -1 } else { 1 }
        zap.draw.content((flipped-multiplier * style.width * 0.4, style.height), text(top-edge: "bounds", bottom-edge: "bounds", 12pt, $+$))
        zap.draw.content((flipped-multiplier * -style.width * 0.4, style.height), text(top-edge: "x-height", bottom-edge: "bounds", 12pt, $-$))
      } else if current == "ac" {
        // AC: Tilde (~)
        zap.draw.content((0, 0), text(12pt, $tilde$))
      }
    }
  }

  // Componant call
  zap.component("source", name, node, draw: draw, style: style, ..params)
}

#let multimeter(name, node, ..params) = {
  // New component style
  let style = (
    radius: .45,
    padding: .15,
  )

  // Drawing function
  let draw(ctx, position, style) = {
    zap.interface((-style.radius, -style.radius), (style.radius, style.radius), io: position.len() < 2)

    zap.draw.circle((0, 0), radius: style.radius, fill: white, stroke: black + .8pt)
    zap.draw.content((0, 0), schaltkreis({ zap.draw.line((45deg, -0.7 * style.radius), (45deg + 180deg, -0.8 * style.radius), mark: (end: (scale: 0.7, symbol: ">", fill: black, stroke: .8pt))) }))
  }

  // Componant call
  zap.component("multimeter", name, node, draw: draw, style: style, ..params)
}

#let lamp(name, node, ..params) = {
  // New component style
  let style = (
    radius: .45,
    padding: .15,
  )

  // Drawing function
  let draw(ctx, position, style) = {
    zap.interface((-style.radius, -style.radius), (style.radius, style.radius), io: position.len() < 2)

    // Kreis für die Glühlampe
    zap.draw.circle((0, 0), radius: style.radius, fill: white, stroke: black + .8pt)
    
    // X in der Mitte (zwei diagonale Linien)
    zap.draw.line((radius: style.radius, angle: 45deg), (radius: -style.radius, angle: 45deg), stroke: black + .8pt)
    zap.draw.line((radius: style.radius, angle: 135deg), (radius: -style.radius, angle: 135deg), stroke: black + .8pt)
  }

  // Componant call
  zap.component("lamp", name, node, draw: draw, style: style, ..params)
}

#let amperemeter(name, node, ..params) = {
  // New component style
  let style = (
    radius: .45,
    padding: .15,
  )

  // Drawing function
  let draw(ctx, position, style) = {
    zap.interface((-style.radius, -style.radius), (style.radius, style.radius), io: position.len() < 2)

    // Kreis für das Amperemeter
    zap.draw.circle((0, 0), radius: style.radius, fill: white, stroke: black + .8pt)
    
    // "A" in der Mitte
    zap.draw.content((0, 0), text(12pt, [A]))
  }

  // Componant call
  zap.component("amperemeter", name, node, draw: draw, style: style, ..params)
}

#let voltmeter(name, node, ..params) = {
  // New component style
  let style = (
    radius: .45,
    padding: .15,
  )

  // Drawing function
  let draw(ctx, position, style) = {
    zap.interface((-style.radius, -style.radius), (style.radius, style.radius), io: position.len() < 2)

    // Kreis für das Voltmeter
    zap.draw.circle((0, 0), radius: style.radius, fill: white, stroke: black + .8pt)
    
    // "V" in der Mitte
    zap.draw.content((0, 0), text(12pt, [V]))
  }

  // Componant call
  zap.component("voltmeter", name, node, draw: draw, style: style, ..params)
}

#let motor(name, node, ..params) = {
  // New component style
  let style = (
    radius: .45,
    padding: .15,
  )

  // Drawing function
  let draw(ctx, position, style) = {
    zap.interface((-style.radius, -style.radius), (style.radius, style.radius), io: position.len() < 2)

    // Kreis für den Motor
    zap.draw.circle((0, 0), radius: style.radius, fill: white, stroke: black + .8pt)
    
    // "M" in der Mitte
    zap.draw.content((0, 0), text(12pt, [M]))
  }

  // Componant call
  zap.component("motor", name, node, draw: draw, style: style, ..params)
}

#let generator(name, node, ..params) = {
  // New component style
  let style = (
    radius: .45,
    padding: .15,
  )

  // Drawing function
  let draw(ctx, position, style) = {
    zap.interface((-style.radius, -style.radius), (style.radius, style.radius), io: position.len() < 2)

    // Kreis für den Generator
    zap.draw.circle((0, 0), radius: style.radius, fill: white, stroke: black + .8pt)
    
    // "G" in der Mitte
    zap.draw.content((0, 0), text(12pt, [G]))
  }

  // Componant call
  zap.component("generator", name, node, draw: draw, style: style, ..params)
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
  if einheit.len() > 1 {
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
    ("G", 1e9),
    ("M", 1e6), 
    ("k", 1e3),
    ("", 1),
    ("c", 1e-2),
    ("m", 1e-3),
    ("u", 1e-6),
    ("n", 1e-9),
    ("p", 1e-12)
  )
  
  for (prefix_key, prefix_value) in prefix_liste {
    let neuer_wert = calc.abs(wert_in_basis) / prefix_value
    if neuer_wert >= 1 and neuer_wert < 1000 {
      let neue_einheit = if prefix_key == "" { basis_einheit } else { prefix_key + basis_einheit }
      return (prefix_value / aktueller_prefix_wert, neue_einheit)
    }
  }
  
  // Fallback: verwende den kleinsten Prefix (pico)
  let neue_einheit = "p" + basis_einheit
  return (1e-12 / aktueller_prefix_wert, neue_einheit)
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

// Funktion zur Berechnung von Werten basierend auf einem oder mehreren Datensätzen
#let berechnung(name, einheit, datensaetze, formel, prefix: "1", auto-einheit: true, fehler: 0) = {
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
  if einheit != none and einheit.len() > 1 {
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
      neue_werte.at(key) = wert * (1 + ((0.5 - rand(key)) * fehler / 100))
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
#let messwerttabelle(datensatze, amount: auto, row-height: auto, header: none, width: 100%, max-digits: 2) = {
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
