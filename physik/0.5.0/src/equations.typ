// Interne Helfer für die Regressionen: Zahlen, Einheiten und Gleichungen
// setzen, Daten anpassen. Erreichbar über `physik.internal`; keine
// zugesicherte Schnittstelle.
#import "@preview/zero:0.5.0": num as zero-num
#import "@preview/fancy-units:0.1.1": unit as fancy-unit
#import "internal/check.typ": fail, check-named, check-positional, check-type, check-value

/// Setzt eine Zahl dezimal oder in wissenschaftlicher Schreibweise.
///
/// - value (int, float): die Zahl
/// - notation (str): `"decimal"` oder `"scientific"`
/// - digits (int): Nachkommastellen
/// -> content, str
#let format-number(value, notation: "decimal", digits: 2) = {
  if notation == "scientific" {
    let exponent = if value == 0 { 0 } else { calc.floor(calc.log(calc.abs(value), base: 10)) }
    let mantissa = value / calc.pow(10, exponent)

    // Ganzzahlige Mantisse ohne Nachkommastellen
    let clean-mantissa = if calc.round(mantissa, digits: 10) == calc.round(mantissa) {
      int(calc.round(mantissa))
    } else {
      mantissa
    }
    let shown = zero-num(str(clean-mantissa), decimal-separator: ",", digits: digits)

    if exponent == 0 {
      shown
    } else if exponent == 1 {
      $#shown dot 10$
    } else {
      $#shown dot 10^#exponent$
    }
  } else {
    if calc.round(value, digits: 10) == calc.round(value) {
      // ganzzahlig: keine Nachkommastellen
      str(int(calc.round(value)))
    } else {
      zero-num(value, decimal-separator: ",", digits: digits)
    }
  }
}

/// Setzt eine Einheit; Inhalt bleibt unverändert.
///
/// - unit (str, content, none): die Einheit
/// -> content, none
#let format-unit(unit) = {
  if unit == none {
    none
  } else if type(unit) == content {
    unit
  } else {
    fancy-unit(per-mode: "fraction")[#unit]
  }
}

/// Bildet die Einheit eines Koeffizienten als Bruch aus y-Einheit und
/// x-Einheit (mit Potenz).
///
/// - y-unit (str, content): Einheit der y-Werte
/// - x-unit (str, content): Einheit der x-Werte
/// - x-power (int): Potenz der x-Einheit
/// -> content
#let combine-units(y-unit, x-unit, x-power: 1) = {
  let make-frac(y, x, power) = {
    let y-part = if type(y) == content { y } else { $upright(#y)$ }
    let x-part = if type(x) == content { x } else { $upright(#x)$ }
    if power == 1 { $frac(#y-part, #x-part)$ } else { $frac(#y-part, #x-part^#power)$ }
  }

  if type(y-unit) == str and type(x-unit) == str and x-unit.contains("/") {
    let parts = x-unit.split("/")
    if parts.len() == 2 {
      let numerator = parts.at(0).trim()
      let denominator = parts.at(1).trim()
      if x-power == 1 {
        $frac(upright(#y-unit) upright(#denominator), upright(#numerator))$
      } else {
        $frac(upright(#y-unit) upright(#denominator)^#x-power, upright(#numerator)^#x-power)$
      }
    } else {
      make-frac(y-unit, x-unit, x-power)
    }
  } else {
    make-frac(y-unit, x-unit, x-power)
  }
}

/// Setzt einen Summanden einer Gleichung mit Einheit. Liefert
/// `(skip: true)`, wenn der Koeffizient unter der Nullschwelle liegt, sonst
/// `(skip: false, term: …, is-negative: …)`.
///
/// - coefficient (int, float): Koeffizient
/// - unit (content, none): Einheit des Koeffizienten
/// - x-name (str, content, none): Bezeichnung der x-Größe
/// - x-power (int): Potenz der x-Größe; 0 = konstanter Summand
/// - notation (str): `"decimal"` oder `"scientific"`
/// - tolerance (float): Nullschwelle
/// - digits (int): Nachkommastellen
/// -> dictionary
#let format-equation-term(
  coefficient,
  unit: none,
  x-name: none,
  x-power: 1,
  notation: "decimal",
  tolerance: 1e-10,
  digits: 2,
) = {
  if calc.abs(coefficient) < tolerance { return (skip: true) }

  // Ein Koeffizient nahe 1 oder -1 wird nicht ausgeschrieben.
  let magnitude = calc.abs(coefficient)
  let is-one = calc.abs(magnitude - 1) < 0.01
  let shown = if is-one { "" } else { format-number(magnitude, notation: notation, digits: digits) }

  let term = if x-power == 0 {
    // konstanter Summand: Koeffizient immer zeigen
    let constant = format-number(magnitude, notation: notation, digits: digits)
    $#constant #unit$
  } else if x-power == 1 {
    if is-one {
      $#unit dot #x-name$
    } else {
      $#shown #unit dot #x-name$
    }
  } else {
    if is-one {
      $#unit dot #x-name^#x-power$
    } else {
      $#shown #unit dot #x-name^#x-power$
    }
  }

  (skip: false, term: term, is-negative: coefficient < 0)
}

/// Fügt Summanden aus `format-equation-term` zu einer Gleichung zusammen.
///
/// - y-name (str, content, none): linke Seite der Gleichung
/// - terms (array): Summanden, der höchste zuerst
/// -> content
#let build-equation(y-name, terms) = {
  if terms.len() == 0 { return $#y-name = 0$ }

  let equation = if terms.first().is-negative {
    $#y-name = -#terms.first().term$
  } else {
    $#y-name = #terms.first().term$
  }

  for term in terms.slice(1) {
    equation = if term.is-negative { $#equation - #term.term$ } else { $#equation + #term.term$ }
  }
  equation
}

/// Setzt ein Polynom ohne Einheiten in der Form $y = …$, Koeffizienten in
/// absteigender Ordnung.
///
/// - coefficients (array): Koeffizienten, der höchste zuerst
/// - x-name (content): Variable
/// - notation (str): `"decimal"` oder `"scientific"`
/// - tolerance (float): Nullschwelle für alle Summanden nach dem ersten
/// - digits (int): Nachkommastellen
/// -> content
#let format-simple-equation(
  coefficients,
  x-name: $x$,
  notation: "decimal",
  tolerance: 1e-10,
  digits: 2,
) = {
  let shown = coefficients.map(k => format-number(calc.abs(k), notation: notation, digits: digits))

  // erster Summand: x^1 wird als x geschrieben, das Vorzeichen bleibt erhalten
  let first-power = coefficients.len() - 1
  let equation = if coefficients.at(0) < 0 {
    if first-power == 0 {
      $y = -#shown.at(0)$
    } else if first-power == 1 {
      $y = -#shown.at(0) #x-name$
    } else {
      $y = -#shown.at(0) #x-name^#first-power$
    }
  } else {
    if first-power == 0 {
      $y = #shown.at(0)$
    } else if first-power == 1 {
      $y = #shown.at(0) #x-name$
    } else {
      $y = #shown.at(0) #x-name^#first-power$
    }
  }

  for (i, k) in coefficients.slice(1).enumerate() {
    let power = coefficients.len() - 2 - i
    if calc.abs(k) >= tolerance {
      let term = if power == 0 {
        shown.at(i + 1)
      } else if power == 1 {
        $#shown.at(i + 1) #x-name$
      } else {
        $#shown.at(i + 1) #x-name^#power$
      }
      equation = if k >= 0 { $#equation + #term$ } else { $#equation - #term$ }
    }
  }
  equation
}

/// Sind beide Einheiten angegeben? Nur dann trägt die Gleichung Einheiten.
///
/// - x-unit (str, content, none): Einheit der x-Werte
/// - y-unit (str, content, none): Einheit der y-Werte
/// -> bool
#let has-units(x-unit, y-unit) = x-unit != none and x-unit != "" and y-unit != none and y-unit != ""

/// Prüft die gemeinsamen Argumente der Regressionen und bricht bei alten
/// Namen, alten Werten und fehlenden Angaben ab.
///
/// - caller (str): Name der Regression
/// - x (any): der übergebene Wert von `x`
/// - y (any): der übergebene Wert von `y`
/// - notation (any): der übergebene Wert von `notation`
/// - tolerance (any): der übergebene Wert von `tolerance`
/// - deprecated (arguments): der Sink der Regression
/// - example (str): Beispielaufruf für die Abhilfe
/// - allowed (array): alle benannten Parameter der Regression
/// -> none
#let check-fit-arguments(
  caller,
  x,
  y,
  notation,
  tolerance,
  deprecated,
  example: "",
  allowed: ("x", "y", "notation", "tolerance"),
) = {
  check-positional("physik", caller, deprecated, hint: "die Messreihen benannt schreiben: `" + example + "`")
  check-named(
    "physik",
    caller,
    deprecated,
    renamed: (precision: "tolerance", grad: "degree"),
    allowed: allowed,
  )
  for (name, value) in (x: x, y: y) {
    if value == none {
      fail("physik", caller, "`" + name + "` fehlt – `" + example + "` schreiben")
    }
    check-type("physik", caller, name, value, (array, dictionary), example: "(1, 2, 3)")
    if type(value) == dictionary and "values" not in value {
      fail("physik", caller, "`" + name + "` ist kein Datensatz – einen Datensatz aus `datensatz` oder eine Liste aus Zahlen übergeben")
    }
  }
  check-value(
    "physik",
    caller,
    "notation",
    notation,
    ("decimal", "scientific"),
    renamed: (dec: "decimal", sci: "scientific"),
  )
  check-type("physik", caller, "tolerance", tolerance, (float, int), example: "1e-10")
}

/// Passt eine Funktion an Messwerte an und setzt ihre Gleichung.
///
/// Liefert `(math: …, math-digits: …, coefficients: (…))`.
///
/// - x (dictionary, array): x-Datensatz oder Liste aus Zahlen
/// - y (dictionary, array): y-Datensatz oder Liste aus Zahlen
/// - solve (function): bekommt die gültigen Wertepaare, liefert die Koeffizienten als Liste
/// - format (function): setzt die Gleichung aus den Koeffizienten; benannte Argumente `x-name`, `y-name`, `x-unit`, `y-unit`, `notation`, `tolerance`, `digits`
/// - coefficient-names (array): Schlüssel der Koeffizienten im Ergebnis
/// - min-count (int): Mindestzahl gültiger Wertepaare
/// - notation (str): `"decimal"` oder `"scientific"`
/// - tolerance (float): Nullschwelle
/// - caller (str): Name der Regression für Fehlermeldungen
/// -> dictionary
#let fit(
  x,
  y,
  solve,
  format,
  coefficient-names: (),
  min-count: 2,
  notation: "decimal",
  tolerance: 1e-10,
  caller: "fit",
) = {
  let extract(data) = {
    if type(data) == dictionary and "values" in data {
      (values: data.values, unit: data.at("unit", default: none), name: data.at("name", default: none))
    } else {
      (values: data, unit: none, name: none)
    }
  }

  let x-data = extract(x)
  let y-data = extract(y)

  let pairs = ()
  for i in range(calc.min(x-data.values.len(), y-data.values.len())) {
    let x-value = x-data.values.at(i)
    let y-value = y-data.values.at(i)
    let is-number(value) = type(value) in (int, float, decimal)
    if is-number(x-value) and is-number(y-value) {
      pairs.push((x-value, y-value))
    }
  }

  if pairs.len() < min-count {
    fail(
      "physik",
      caller,
      (if pairs.len() == 1 { "1 gültiges Wertepaar" } else { str(pairs.len()) + " gültige Wertepaare" })
        + ", nötig sind mindestens "
        + str(min-count)
        + " – mehr Messwerte angeben; leere Zellen zählen nicht",
    )
  }

  let coefficients = solve(pairs)
  let math-digits(digits) = format(
    coefficients,
    x-name: x-data.name,
    y-name: y-data.name,
    x-unit: x-data.unit,
    y-unit: y-data.unit,
    notation: notation,
    tolerance: tolerance,
    digits: digits,
  )

  let named = (:)
  for (i, name) in coefficient-names.enumerate() {
    named.insert(name, coefficients.at(i))
  }
  (math: math-digits(2), math-digits: math-digits, coefficients: named)
}
