#import "@preview/zero:0.5.0": num as znum
#import "@preview/fancy-units:0.1.1": unit

// Hilfsfunktion für wissenschaftliche Notation
#let format-number(value, notation: "dec", digits: 2) = {
  if notation == "sci" {
    let exp = if value == 0 { 0 } else { calc.floor(calc.log(calc.abs(value), base: 10)) }
    let mantissa = value / calc.pow(10, exp)
    let mantissa_formatted = znum(str(mantissa), decimal-separator:",", digits: digits)
    
    // Spezialfälle für Exponenten
    if exp == 0 {
      // 10^0 = 1 weglassen
      mantissa_formatted
    } else if exp == 1 {
      // 10^1 = 10 ohne Exponent
      $#mantissa_formatted dot 10$
    } else {
      // Normale wissenschaftliche Notation
      $#mantissa_formatted dot 10^#exp$
    }
  } else {
    znum(value, decimal-separator:",", digits: digits)
  }
}

// Hilfsfunktion zum Kombinieren von Einheiten in einem Bruch
#let combine-units(y_einheit, x_einheit, x_potenz: 1) = {
  if type(y_einheit) == str and type(x_einheit) == str {
    // Beide sind Strings
    // Prüfe, ob x_einheit einen Bruch enthält (z.B. "m/s")
    if x_einheit.contains("/") {
      // x_einheit ist bereits ein Bruch, z.B. "m/s"
      // Bei Potenzierung: (m/s)^n = m^n/s^n
      let parts = x_einheit.split("/")
      if parts.len() == 2 {
        let numerator = parts.at(0).trim()
        let denominator = parts.at(1).trim()
        if x_potenz == 1 {
          // N / (m/s) = Ns/m
          $frac(upright(#y_einheit) upright(#denominator), upright(#numerator))$
        } else {
          // N / (m/s)^3 = Ns^3/m^3
          $frac(upright(#y_einheit) upright(#denominator)^#x_potenz, upright(#numerator)^#x_potenz)$
        }
      } else {
        // Fallback: behandle wie normale Einheit
        if x_potenz == 1 {
          $frac(upright(#y_einheit), upright(#x_einheit))$
        } else {
          $frac(upright(#y_einheit), upright(#x_einheit)^#x_potenz)$
        }
      }
    } else {
      // x_einheit ist einfach, z.B. "m" oder "s"
      if x_potenz == 1 {
        $frac(upright(#y_einheit), upright(#x_einheit))$
      } else {
        $frac(upright(#y_einheit), upright(#x_einheit)^#x_potenz)$
      }
    }
  } else {
    // Mindestens eine ist content - baue manuell Math-Mode Bruch mit frac
    if x_potenz == 1 {
      if type(y_einheit) == content and type(x_einheit) == content {
        $frac(#y_einheit, #x_einheit)$
      } else if type(y_einheit) == content {
        $frac(#y_einheit, upright(#x_einheit))$
      } else if type(x_einheit) == content {
        $frac(upright(#y_einheit), #x_einheit)$
      } else {
        $frac(upright(#y_einheit), upright(#x_einheit))$
      }
    } else {
      if type(y_einheit) == content and type(x_einheit) == content {
        $frac(#y_einheit, #x_einheit^#x_potenz)$
      } else if type(y_einheit) == content {
        $frac(#y_einheit, upright(#x_einheit)^#x_potenz)$
      } else if type(x_einheit) == content {
        $frac(upright(#y_einheit), #x_einheit^#x_potenz)$
      } else {
        $frac(upright(#y_einheit), upright(#x_einheit)^#x_potenz)$
      }
    }
  }
}

// Allgemeine Regressionsfunktion
#let regression(
  x_param, 
  y_param, 
  algorithmus,
  format-function,
  koeffizienten-namen: (),
  min-punkte: 2,
  notation: "dec",
  precision: 1e-10
) = {
  let x_werte = ()
  let y_werte = ()
  let x_einheit = none
  let y_einheit = none
  let x_name = none
  let y_name = none
  
  // Prüfe ob Datensätze oder Arrays übergeben wurden
  if type(x_param) == dictionary and "werte" in x_param {
    // x_param ist ein Datensatz
    x_einheit = x_param.einheit
    x_name = x_param.name
    x_werte = x_param.werte
  } else {
    // x_param ist ein Array
    x_werte = x_param
  }
  
  if type(y_param) == dictionary and "werte" in y_param {
    // y_param ist ein Datensatz
    y_einheit = y_param.einheit
    y_name = y_param.name
    y_werte = y_param.werte
  } else {
    // y_param ist ein Array
    y_werte = y_param
  }
  
  // Filtere none/content Werte heraus
  let gueltige_paare = ()
  let min_len = calc.min(x_werte.len(), y_werte.len())
  for i in range(min_len) {
    let x_val = x_werte.at(i)
    let y_val = y_werte.at(i)
    if x_val != none and y_val != none and type(x_val) != content and type(y_val) != content {
      gueltige_paare.push((x_val, y_val))
    }
  }
  
  // Prüfen, ob genug Datenpunkte vorhanden sind
  assert(gueltige_paare.len() >= min-punkte, message: "Nicht genug gültige Datenpunkte für die Regression")

  // Führe den Algorithmus aus
  let koeffizienten = algorithmus(gueltige_paare)
  
  // Formatiere die Ausgabe
  let math_output = format-function(
    koeffizienten, 
    x_name: x_name, 
    y_name: y_name, 
    x_einheit: x_einheit, 
    y_einheit: y_einheit,
    notation: notation,
    precision: precision
  )
  
  // Erstelle Dictionary mit allen Koeffizienten
  let result = (math: math_output)
  for (i, name) in koeffizienten-namen.enumerate() {
    result.insert(name, koeffizienten.at(i))
  }
  
  return result
}

// Funktion für lineare Regression
#let lineare_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
  // Algorithmus für lineare Regression
  let algorithmus(gueltige_paare) = {
    let n = gueltige_paare.len()

    // Mittelwerte berechnen
    let x_summe = 0
    let y_summe = 0
    for paar in gueltige_paare {
      x_summe += paar.at(0)
      y_summe += paar.at(1)
    }
    let x_mittel = x_summe / n
    let y_mittel = y_summe / n

    // Steigung (m) berechnen: m = Σ((x_i - x̄)(y_i - ȳ)) / Σ((x_i - x̄)²)
    let zaehler = 0
    let nenner = 0

    for paar in gueltige_paare {
      let x_diff = paar.at(0) - x_mittel
      let y_diff = paar.at(1) - y_mittel
      zaehler += x_diff * y_diff
      nenner += x_diff * x_diff
    }

    let m = zaehler / nenner
    let b = y_mittel - m * x_mittel
    
    (m, b)
  }
  
  // Format-Funktion für lineare Regression
  let format-function(koeff, x_name: none, y_name: none, x_einheit: none, y_einheit: none, notation: "dec", precision: 1e-10) = {
    let m = koeff.at(0)
    let b = koeff.at(1)
    
    if x_einheit != none and y_einheit != none {
      // Mit Einheiten und Namen
      let m_str = format-number(m, notation: notation)
      let b_str = format-number(calc.abs(b), notation: notation)
      
      // Erstelle Steigungseinheit (y_einheit / x_einheit)
      let m_einheit_formatted = combine-units(y_einheit, x_einheit, x_potenz: 1)
      
      // Erstelle b-Einheit
      let b_einheit_formatted = if type(y_einheit) == content {
        y_einheit
      } else {
        unit(per-mode: "fraction")[#y_einheit]
      }
      
      // Baue Gleichung zusammen, berücksichtige precision
      let gleichung = $#y_name = #m_str #m_einheit_formatted dot #x_name$
      
      if calc.abs(b) >= precision {
        if b >= 0 {
          gleichung = $#gleichung + #b_str #b_einheit_formatted$
        } else {
          gleichung = $#gleichung - #b_str #b_einheit_formatted$
        }
      }
      
      gleichung
    } else {
      // Ohne Einheiten (klassische Form)
      let m_str = format-number(m, notation: notation)
      let b_str = format-number(calc.abs(b), notation: notation)
      
      // Baue Gleichung zusammen, berücksichtige precision
      let gleichung = $y = #m_str x$
      
      if calc.abs(b) >= precision {
        if b >= 0 {
          gleichung = $#gleichung + #b_str$
        } else {
          gleichung = $#gleichung - #b_str$
        }
      }
      
      gleichung
    }
  }
  
  let result = regression(
    x_param, 
    y_param, 
    algorithmus, 
    format-function,
    koeffizienten-namen: ("m", "b"),
    min-punkte: 2,
    notation: notation,
    precision: precision
  )
  
  // Füge function hinzu
  result.insert("function", (x) => { result.m * x + result.b })
  
  return result
}

// Funktion für quadratische Regression
#let quadratische_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
  // Algorithmus für quadratische Regression
  let algorithmus(gueltige_paare) = {
    let n = gueltige_paare.len()
    
    // 1. Berechne die Summen der Potenzen von x und y
    let sum_x = 0
    let sum_y = 0
    let sum_x_quadrat = 0
    let sum_x_kubik = 0
    let sum_x_hoch_4 = 0
    let sum_xy = 0
    let sum_x_quadrat_y = 0
    
    for paar in gueltige_paare {
      let x = paar.at(0)
      let y = paar.at(1)
      let x_2 = x * x
      let x_3 = x_2 * x
      let x_4 = x_3 * x
      
      sum_x += x
      sum_y += y
      sum_x_quadrat += x_2
      sum_x_kubik += x_3
      sum_x_hoch_4 += x_4
      sum_xy += x * y
      sum_x_quadrat_y += x_2 * y
    }
    
    // 2. Löse das System linearer Gleichungen mit der Cramerschen Regel
    // Das System lautet:
    // a * Σ(x^4) + b * Σ(x^3) + c * Σ(x^2) = Σ(x^2*y)
    // a * Σ(x^3) + b * Σ(x^2) + c * Σ(x)   = Σ(xy)
    // a * Σ(x^2) + b * Σ(x)   + c * n      = Σ(y)
    
    // Definiere die Koeffizientenmatrix (Matrix A)
    let A11 = sum_x_hoch_4
    let A12 = sum_x_kubik
    let A13 = sum_x_quadrat
    let A21 = sum_x_kubik
    let A22 = sum_x_quadrat
    let A23 = sum_x
    let A31 = sum_x_quadrat
    let A32 = sum_x
    let A33 = n
    
    // Definiere den Ergebnisvektor (Vektor B)
    let B1 = sum_x_quadrat_y
    let B2 = sum_xy
    let B3 = sum_y
    
    // Berechne die Determinante der Hauptmatrix A
    let det_A = (A11 * (A22 * A33 - A23 * A32) -
                 A12 * (A21 * A33 - A23 * A31) +
                 A13 * (A21 * A32 - A22 * A31))
    
    assert(det_A != 0, message: "Die Determinante ist null, eine eindeutige Lösung ist nicht möglich")
    
    // Berechne die Determinante für 'a' (det_Ax)
    let det_Ax = (B1 * (A22 * A33 - A23 * A32) -
                  A12 * (B2 * A33 - A23 * B3) +
                  A13 * (B2 * A32 - A22 * B3))
    
    // Berechne die Determinante für 'b' (det_Ay)
    let det_Ay = (A11 * (B2 * A33 - A23 * B3) -
                  B1 * (A21 * A33 - A23 * A31) +
                  A13 * (A21 * B3 - B2 * A31))
    
    // Berechne die Determinante für 'c' (det_Az)
    let det_Az = (A11 * (A22 * B3 - B2 * A32) -
                  A12 * (A21 * B3 - B2 * A31) +
                  B1 * (A21 * A32 - A22 * A31))
    
    // 3. Berechne die Koeffizienten a, b, und c
    let a = det_Ax / det_A
    let b = det_Ay / det_A
    let c = det_Az / det_A
    
    (a, b, c)
  }
  
  // Format-Funktion für quadratische Regression
  let format-function(koeff, x_name: none, y_name: none, x_einheit: none, y_einheit: none, notation: "dec", precision: 1e-10) = {
    let a = koeff.at(0)
    let b = koeff.at(1)
    let c = koeff.at(2)
    
    if x_einheit != none and y_einheit != none {
      // Mit Einheiten und Namen
      let a_str = format-number(a, notation: notation)
      let b_str = format-number(calc.abs(b), notation: notation)
      let c_str = format-number(calc.abs(c), notation: notation)
      
      // Erstelle Einheiten
      let a_einheit_formatted = combine-units(y_einheit, x_einheit, x_potenz: 2)
      let b_einheit_formatted = combine-units(y_einheit, x_einheit, x_potenz: 1)
      
      let c_einheit_formatted = if type(y_einheit) == content {
        y_einheit
      } else {
        unit(per-mode: "fraction")[#y_einheit]
      }
      
      // Baue die Gleichung zusammen, berücksichtige precision
      let gleichung = $#y_name = #a_str #a_einheit_formatted dot #x_name^2$
      
      if calc.abs(b) >= precision {
        if b >= 0 {
          gleichung = $#gleichung + #b_str #b_einheit_formatted dot #x_name$
        } else {
          gleichung = $#gleichung - #b_str #b_einheit_formatted dot #x_name$
        }
      }
      
      if calc.abs(c) >= precision {
        if c >= 0 {
          gleichung = $#gleichung + #c_str #c_einheit_formatted$
        } else {
          gleichung = $#gleichung - #c_str #c_einheit_formatted$
        }
      }
      
      gleichung
    } else {
      // Ohne Einheiten (klassische Form)
      let a_str = format-number(a, notation: notation)
      let b_str = format-number(calc.abs(b), notation: notation)
      let c_str = format-number(calc.abs(c), notation: notation)
      
      // Baue die Gleichung zusammen, berücksichtige precision
      let gleichung = $y = #a_str x^2$
      
      if calc.abs(b) >= precision {
        if b >= 0 {
          gleichung = $#gleichung + #b_str x$
        } else {
          gleichung = $#gleichung - #b_str x$
        }
      }
      
      if calc.abs(c) >= precision {
        if c >= 0 {
          gleichung = $#gleichung + #c_str$
        } else {
          gleichung = $#gleichung - #c_str$
        }
      }
      
      gleichung
    }
  }
  
  let result = regression(
    x_param, 
    y_param, 
    algorithmus, 
    format-function,
    koeffizienten-namen: ("a", "b", "c"),
    min-punkte: 3,
    notation: notation,
    precision: precision
  )
  
  // Füge function hinzu
  result.insert("function", (x) => { result.a * x * x + result.b * x + result.c })
  
  return result
}

// Funktion für Wurzel-Regression
#let wurzel_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
  // Algorithmus für Wurzel-Regression
  let algorithmus(gueltige_paare) = {
    // Überprüfen, ob alle x-Werte nicht-negativ sind
    for paar in gueltige_paare {
      assert(paar.at(0) >= 0, message: "Alle x-Werte müssen nicht-negativ sein für Wurzel-Regression")
    }
    
    let n = gueltige_paare.len()
    
    // 1. Transformiere x zu z = sqrt(x) und berechne die notwendigen Summen
    let sum_z = 0
    let sum_y = 0
    let sum_z_quadrat = 0
    let sum_zy = 0
    
    for paar in gueltige_paare {
      let x = paar.at(0)
      let y = paar.at(1)
      let z = calc.sqrt(x)
      
      sum_z += z
      sum_y += y
      sum_z_quadrat += z * z // Dies ist gleich x
      sum_zy += z * y
    }
    
    // 2. Löse das 2x2 System linearer Gleichungen
    // a * Σ(z^2) + b * Σ(z) = Σ(z*y)
    // a * Σ(z)   + b * n     = Σ(y)
    
    // Nenner der Lösungsformel (Determinante der Koeffizientenmatrix)
    let nenner = n * sum_z_quadrat - sum_z * sum_z
    
    assert(nenner != 0, message: "Eine eindeutige Lösung ist nicht möglich (Nenner ist null)")
    
    // Zähler für die Koeffizienten a und b
    let zaehler_a = n * sum_zy - sum_z * sum_y
    let zaehler_b = sum_y * sum_z_quadrat - sum_z * sum_zy
    
    // 3. Berechne die Koeffizienten a und b
    let a = zaehler_a / nenner
    let b = zaehler_b / nenner
    
    (a, b)
  }
  
  // Format-Funktion für Wurzel-Regression
  let format-function(koeff, x_name: none, y_name: none, x_einheit: none, y_einheit: none, notation: "dec", precision: 1e-10) = {
    let a = koeff.at(0)
    let b = koeff.at(1)
    
    if x_einheit != none and y_einheit != none {
      // Mit Einheiten und Namen
      let a_str = format-number(a, notation: notation)
      let b_str = format-number(calc.abs(b), notation: notation)
      
      // Erstelle Einheiten
      // a hat Einheit y_einheit / sqrt(x_einheit)
      let a_einheit_formatted = if type(y_einheit) == content and type(x_einheit) == content {
        $#y_einheit \/ sqrt(#x_einheit)$
      } else if type(y_einheit) == content {
        $#y_einheit \/ sqrt(upright(#x_einheit))$
      } else if type(x_einheit) == content {
        $upright(#y_einheit) \/ sqrt(#x_einheit)$
      } else {
        $#y_einheit / sqrt(#x_einheit)$
      }
      
      let b_einheit_formatted = if type(y_einheit) == content {
        y_einheit
      } else {
        unit(per-mode: "fraction")[#y_einheit]
      }
      
      // Baue die Gleichung zusammen, berücksichtige precision
      let gleichung = $#y_name = #a_str #a_einheit_formatted dot sqrt(#x_name)$
      
      if calc.abs(b) >= precision {
        if b >= 0 {
          gleichung = $#gleichung + #b_str #b_einheit_formatted$
        } else {
          gleichung = $#gleichung - #b_str #b_einheit_formatted$
        }
      }
      
      gleichung
    } else {
      // Ohne Einheiten (klassische Form)
      let a_str = format-number(a, notation: notation)
      let b_str = format-number(calc.abs(b), notation: notation)
      
      // Baue die Gleichung zusammen, berücksichtige precision
      let gleichung = $y = #a_str sqrt(x)$
      
      if calc.abs(b) >= precision {
        if b >= 0 {
          gleichung = $#gleichung + #b_str$
        } else {
          gleichung = $#gleichung - #b_str$
        }
      }
      
      gleichung
    }
  }
  
  let result = regression(
    x_param, 
    y_param, 
    algorithmus, 
    format-function,
    koeffizienten-namen: ("a", "b"),
    min-punkte: 2,
    notation: notation
  )
  
  // Füge function hinzu - mit Schutz vor negativen x-Werten
  result.insert("function", (x) => { 
    if x < 0 {
      return none
    }
    result.a * calc.sqrt(x) + result.b 
  })
  
  return result
}

// Funktion für Exponentielle Regression
#let exponentielle_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
  // Algorithmus für Exponentielle Regression
  let algorithmus(gueltige_paare) = {
    // Überprüfen, ob alle y-Werte positiv sind (da ln(y) berechnet wird)
    for paar in gueltige_paare {
      assert(paar.at(1) > 0, message: "Alle y-Werte müssen positiv sein für exponentielle Regression")
    }
    
    let n = gueltige_paare.len()
    
    // 1. Linearisierung des Modells:
    // y = b * e^(a*x)  =>  ln(y) = ln(b) + a*x
    // Wir führen eine lineare Regression für Y = a*x + B durch,
    // wobei Y = ln(y) und B = ln(b).
    
    // Transformiere y zu Y = ln(y) und berechne die notwendigen Summen
    let sum_x = 0
    let sum_y_log = 0
    let sum_x_quadrat = 0
    let sum_xy_log = 0
    
    for paar in gueltige_paare {
      let x = paar.at(0)
      let y = paar.at(1)
      let y_log = calc.ln(y)
      
      sum_x += x
      sum_y_log += y_log
      sum_x_quadrat += x * x
      sum_xy_log += x * y_log
    }
    
    // 2. Löse das 2x2 System linearer Gleichungen
    // a * Σ(x^2) + B * Σ(x) = Σ(x*ln(y))
    // a * Σ(x)   + B * n     = Σ(ln(y))
    
    // Nenner der Lösungsformel (Determinante der Koeffizientenmatrix)
    let nenner = n * sum_x_quadrat - sum_x * sum_x
    
    assert(nenner != 0, message: "Eine eindeutige Lösung ist nicht möglich (Nenner ist null)")
    
    // Zähler für die Koeffizienten a und B
    let zaehler_a = n * sum_xy_log - sum_x * sum_y_log
    let zaehler_B = sum_y_log * sum_x_quadrat - sum_x * sum_xy_log
    
    // 3. Berechne die Koeffizienten a und B
    let a = zaehler_a / nenner
    let B = zaehler_B / nenner
    
    // 4. Rücktransformation: Berechne b aus B
    // Da B = ln(b), ist b = e^B
    let b = calc.exp(B)
    
    (a, b)
  }
  
  // Format-Funktion für Exponentielle Regression
  let format-function(koeff, x_name: none, y_name: none, x_einheit: none, y_einheit: none, notation: "dec", precision: 1e-10) = {
    let a = koeff.at(0)
    let b = koeff.at(1)
    
    if x_einheit != none and y_einheit != none {
      // Mit Einheiten und Namen
      let a_str = format-number(a, notation: notation)
      let b_str = format-number(b, notation: notation)
      
      // Erstelle Einheiten
      // a hat Einheit 1 / x_einheit
      let a_einheit_formatted = if type(x_einheit) == content {
        $1 \/ #x_einheit$
      } else {
        unit(per-mode: "fraction")[1/#x_einheit]
      }
      
      let b_einheit_formatted = if type(y_einheit) == content {
        y_einheit
      } else {
        unit(per-mode: "fraction")[#y_einheit]
      }
      
      // Baue die Gleichung zusammen
      $#y_name = #b_str #b_einheit_formatted dot e^(#a_str #a_einheit_formatted dot #x_name)$
    } else {
      // Ohne Einheiten (klassische Form)
      let a_str = format-number(a, notation: notation)
      let b_str = format-number(b, notation: notation)
      
      $y = #b_str dot e^(#a_str x)$
    }
  }
  
  let result = regression(
    x_param, 
    y_param, 
    algorithmus, 
    format-function,
    koeffizienten-namen: ("a", "b"),
    min-punkte: 2,
    notation: notation
  )
  
  // Füge function hinzu
  result.insert("function", (x) => { 
    result.b * calc.exp(result.a * x)
  })
  
  return result
}

// Funktion für Polynom-Regression
#let polynom_regression(x_param, y_param, grad, notation: "dec", precision: 1e-10) = {
  // Algorithmus für Polynom-Regression
  let algorithmus(gueltige_paare) = {
    let n_punkte = gueltige_paare.len()
    let n_koeff = grad + 1
    
    // Prüfen, ob genug Datenpunkte vorhanden sind
    assert(n_punkte >= n_koeff, message: "Es werden mindestens " + str(n_koeff) + " Datenpunkte für Grad " + str(grad) + " benötigt")
    
    // 1. Berechne die Summen für die Matrix A und den Vektor B
    // A[i][j] = Σ(x^(i+j)), B[i] = Σ(y * x^i)
    
    // Hilfsfunktion: Berechne x^i sicher (x^0 = 1 für alle x)
    let pow_safe(x, i) = {
      if i == 0 {
        1
      } else {
        calc.pow(x, i)
      }
    }
    
    // Summen der x-Potenzen bis 2*grad berechnen
    let x_potenzen_summen = (2 * grad + 1) * (0,)
    for paar in gueltige_paare {
      let x = paar.at(0)
      for i in range(x_potenzen_summen.len()) {
        x_potenzen_summen.at(i) += pow_safe(x, i)
      }
    }
    
    // Summen von y * x^i berechnen
    let b_vektor = n_koeff * (0,)
    for i in range(n_koeff) {
      for paar in gueltige_paare {
        let x = paar.at(0)
        let y = paar.at(1)
        b_vektor.at(i) += y * pow_safe(x, i)
      }
    }
    
    // 2. Erstelle die erweiterte Koeffizientenmatrix [A|B]
    let matrix = ()
    for i in range(n_koeff) {
      let row = (n_koeff + 1) * (0,)
      for j in range(n_koeff) {
        row.at(j) = x_potenzen_summen.at(i + j)
      }
      row.at(-1) = b_vektor.at(i)
      matrix.push(row)
    }
    
    // 3. Löse das Gleichungssystem mit Gauß-Elimination
    
    // Vorwärtselimination (Erzeugung einer oberen Dreiecksmatrix)
    for i in range(n_koeff) {
      // Pivotsuche für numerische Stabilität
      let max_row = i
      for k in range(i + 1, n_koeff) {
        if calc.abs(matrix.at(k).at(i)) > calc.abs(matrix.at(max_row).at(i)) {
          max_row = k
        }
      }
      
      // Zeilen tauschen
      let temp = matrix.at(i)
      matrix.at(i) = matrix.at(max_row)
      matrix.at(max_row) = temp
      
      let pivot = matrix.at(i).at(i)
      assert(pivot != 0, message: "Matrix ist singulär, keine eindeutige Lösung")
      
      // Normalisiere Pivot-Zeile
      for j in range(i, n_koeff + 1) {
        matrix.at(i).at(j) = matrix.at(i).at(j) / pivot
      }
      
      // Eliminiere Spalte i in allen anderen Zeilen
      for k in range(n_koeff) {
        if i != k {
          let faktor = matrix.at(k).at(i)
          for j in range(i, n_koeff + 1) {
            matrix.at(k).at(j) = matrix.at(k).at(j) - faktor * matrix.at(i).at(j)
          }
        }
      }
    }
    
    // Die Koeffizienten sind nun in der letzten Spalte
    let koeffizienten = ()
    for row in matrix {
      koeffizienten.push(row.at(-1))
    }
    
    koeffizienten
  }
  
  // Format-Funktion für Polynom-Regression
  let format-function(koeff, x_name: none, y_name: none, x_einheit: none, y_einheit: none, notation: "dec", precision: 1e-10) = {
    if x_einheit != none and y_einheit != none {
      // Mit Einheiten und Namen
      let gleichung = none
      
      // Iteriere rückwärts von höchster zu niedrigster Potenz (x^n → x^0)
      for i in range(koeff.len() - 1, -1, step: -1) {
        let c = koeff.at(i)
        
        if calc.abs(c) < precision {
          continue  // Überspringe sehr kleine Koeffizienten
        }
        
        let c_str = format-number(calc.abs(c), notation: notation)
        
        // Erstelle Einheit für diesen Term
        let c_einheit_formatted = if i == 0 {
          // Konstanter Term
          if type(y_einheit) == content {
            y_einheit
          } else {
            unit(per-mode: "fraction")[#y_einheit]
          }
        } else {
          // x^i Term - verwende combine-units
          combine-units(y_einheit, x_einheit, x_potenz: i)
        }
        
        // Baue den Term zusammen
        let term = if i == 0 {
          $#c_str #c_einheit_formatted$
        } else if i == 1 {
          $#c_str #c_einheit_formatted dot #x_name$
        } else {
          $#c_str #c_einheit_formatted dot #x_name^#i$
        }
        
        // Füge Term zur Gleichung hinzu
        if gleichung == none {
          // Erster Term: verwende tatsächliches Vorzeichen
          gleichung = if c >= 0 {
            $#y_name = #term$
          } else {
            $#y_name = -#term$
          }
        } else {
          // Weitere Terme: füge mit + oder - hinzu
          gleichung = if c >= 0 {
            $#gleichung + #term$
          } else {
            $#gleichung - #term$
          }
        }
      }
      
      if gleichung == none {
        $#y_name = 0$
      } else {
        gleichung
      }
    } else {
      // Ohne Einheiten (klassische Form)
      let gleichung = none
      
      // Iteriere rückwärts von höchster zu niedrigster Potenz (x^n → x^0)
      for i in range(koeff.len() - 1, -1, step: -1) {
        let c = koeff.at(i)
        
        if calc.abs(c) < precision {
          continue  // Überspringe sehr kleine Koeffizienten
        }
        
        let c_str = format-number(calc.abs(c), notation: notation)
        
        // Baue den Term zusammen
        let term = if i == 0 {
          $#c_str$
        } else if i == 1 {
          $#c_str x$
        } else {
          $#c_str x^#i$
        }
        
        // Füge Term zur Gleichung hinzu
        if gleichung == none {
          // Erster Term: verwende tatsächliches Vorzeichen
          gleichung = if c >= 0 {
            $y = #term$
          } else {
            $y = -#term$
          }
        } else {
          // Weitere Terme: füge mit + oder - hinzu
          gleichung = if c >= 0 {
            $#gleichung + #term$
          } else {
            $#gleichung - #term$
          }
        }
      }
      
      if gleichung == none {
        $y = 0$
      } else {
        gleichung
      }
    }
  }
  
  // Erstelle Koeffizienten-Namen: c0, c1, c2, ...
  let koeff_namen = ()
  for i in range(grad + 1) {
    koeff_namen.push("c" + str(i))
  }
  
  let result = regression(
    x_param, 
    y_param, 
    algorithmus, 
    format-function,
    koeffizienten-namen: koeff_namen,
    min-punkte: grad + 1,
    notation: notation,
    precision: precision
  )
  
  // Füge function hinzu
  result.insert("function", (x) => { 
    let y = 0
    for i in range(grad + 1) {
      let c = result.at("c" + str(i))
      if i == 0 {
        y += c
      } else {
        y += c * calc.pow(x, i)
      }
    }
    y
  })
  
  return result
}
