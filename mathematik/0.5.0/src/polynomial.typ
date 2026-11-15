// Steckbriefaufgaben: Polynomfunktion aus Bedingungen.
#import "@preview/zero:0.5.0": num as zero-num
#import "internal/check.typ": fail, check-named, check-value, check-type, check-positional, show-value

// Formelzeichen der Koeffizienten, höchster Grad zuerst. `x` ist die Variable
// und fehlt deshalb.
#let coefficient-names = "abcdefghijklmnopqrstuvw".clusters()

// Rationale Arithmetik für exakte Bruchrechnung; ein Bruch ist (Zähler, Nenner).
#let rational-gcd(a, b) = {
  a = calc.abs(a)
  b = calc.abs(b)
  while b != 0 {
    let rest = calc.rem(a, b)
    a = b
    b = rest
  }
  a
}
#let rational(numerator, denominator) = {
  if numerator == 0 { return (0, 1) }
  let divisor = rational-gcd(numerator, denominator)
  let sign = if (numerator < 0) != (denominator < 0) { -1 } else { 1 }
  (sign * int(calc.abs(numerator) / divisor), int(calc.abs(denominator) / divisor))
}
#let rational-sub(a, b) = rational(a.at(0) * b.at(1) - b.at(0) * a.at(1), a.at(1) * b.at(1))
#let rational-mul(a, b) = rational(a.at(0) * b.at(0), a.at(1) * b.at(1))
#let rational-div(a, b) = rational(a.at(0) * b.at(1), a.at(1) * b.at(0))
#let rational-is-zero(a) = a.at(0) == 0
#let rational-is-negative(a) = a.at(0) < 0
#let rational-abs(a) = (calc.abs(a.at(0)), a.at(1))
#let rational-is-one(a) = a.at(0) == 1 and a.at(1) == 1
#let rational-is-larger(a, b) = calc.abs(a.at(0)) * b.at(1) > calc.abs(b.at(0)) * a.at(1)

// Text → Bruch, exakt: "3", "-1.5", "1/2".
#let text-to-rational(source) = {
  let source = source.trim()
  if source.contains("/") {
    let parts = source.split("/")
    rational-div(text-to-rational(parts.at(0)), text-to-rational(parts.at(1)))
  } else if source.contains("e") or source.contains("E") {
    let rounded = calc.round(float(source), digits: 10)
    if rounded == calc.round(rounded) { (int(rounded), 1) } else { text-to-rational(str(rounded)) }
  } else if source.contains(".") {
    let negative = source.starts-with("-")
    let digits = if negative { source.slice(1) } else { source }
    let parts = digits.split(".")
    let power = int(calc.pow(10, parts.at(1).len()))
    let numerator = int(parts.at(0)) * power + int(parts.at(1))
    rational(if negative { -numerator } else { numerator }, power)
  } else {
    (int(source), 1)
  }
}

#let float-to-rational(value) = {
  let rounded = calc.round(value, digits: 10)
  if rounded == calc.round(rounded) { (int(rounded), 1) } else { text-to-rational(str(rounded)) }
}

#let format-rational(value) = {
  let (numerator, denominator) = value
  if denominator == 1 { $#str(numerator)$ } else if numerator < 0 {
    $-frac(#str(-numerator), #str(denominator))$
  } else { $frac(#str(numerator), #str(denominator))$ }
}

// Zahl im gewählten Zahlenformat.
#let format-number(value, notation, digits: 2) = {
  if notation == "fraction" {
    format-rational(float-to-rational(value))
  } else if notation == "scientific" {
    let exponent = if value == 0 { 0 } else { calc.floor(calc.log(calc.abs(value), base: 10)) }
    let mantissa = value / calc.pow(10, exponent)
    let clean = if calc.round(mantissa, digits: 10) == calc.round(mantissa) {
      int(calc.round(mantissa))
    } else {
      mantissa
    }
    let shown = zero-num(str(clean), decimal-separator: ",", digits: digits)
    if exponent == 0 {
      shown
    } else if exponent == 1 {
      $#shown dot 10$
    } else {
      $#shown dot 10^#exponent$
    }
  } else if calc.round(value, digits: 10) == calc.round(value) {
    str(int(calc.round(value)))
  } else {
    zero-num(value, decimal-separator: ",", digits: digits)
  }
}

// Zerlegt eine Bedingung wie "f(2)=3" oder "f'(-1)=0" in Stelle, Wert (beide
// als Text mit Dezimalpunkt) und Ableitungsgrad.
#let parse-condition(condition) = {
  let example = "zum Beispiel `\"f'(2)=0\"`"
  if type(condition) != str {
    fail(
      "mathematik",
      "steckbrief",
      "Bedingung `" + show-value(condition) + "` (" + repr(type(condition)) + ") ist kein Text – " + example,
    )
  }
  let source = condition.replace(" ", "")
  let order = source.clusters().filter(cluster => cluster == "'").len()
  let x-match = source.match(regex("\(([^)]+)\)"))
  if x-match == none {
    fail("mathematik", "steckbrief", "Bedingung `" + show-value(condition) + "` nennt keine Stelle in Klammern – " + example)
  }
  let y-match = source.match(regex("=(.+)$"))
  if y-match == none {
    fail("mathematik", "steckbrief", "Bedingung `" + show-value(condition) + "` hat kein `=` – " + example)
  }
  // Dezimalkomma annehmen
  let x-text = x-match.captures.at(0).replace(",", ".")
  let y-text = y-match.captures.at(0).replace(",", ".")
  let number = regex("^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?(/[+-]?(\d+\.?\d*|\.\d+))?$")
  for entry in (x-text, y-text) {
    if entry.match(number) == none {
      fail(
        "mathematik",
        "steckbrief",
        "Bedingung `" + show-value(condition) + "`: `" + entry + "` ist keine Zahl – Zahlen wie `2`, `-1,5` oder `1/2` schreiben",
      )
    }
  }
  (x: x-text, y: y-text, order: order)
}

#let text-to-float(source) = {
  if source.contains("/") {
    let parts = source.split("/")
    float(parts.at(0)) / float(parts.at(1))
  } else {
    float(source)
  }
}

// Faktor und Exponent, die beim `order`-fachen Ableiten von x^exponent entstehen.
#let derive-power(exponent, order) = {
  let factor = 1
  for _ in range(order) {
    if exponent == 0 { return (0, 0) }
    factor = factor * exponent
    exponent = exponent - 1
  }
  (factor, exponent)
}

/// Bestimmt eine Polynomfunktion aus Bedingungen (Steckbriefaufgabe).
///
/// Die Positionsargumente sind die Bedingungen als Text: `"f(2)=3"`,
/// `"f'(-1)=0"`, `"f''(0)=6"`, `"f(1/2)=0,5"`. Die Zahl der Striche ist der
/// Grad der Ableitung, der Grad des Polynoms ist die Zahl der Bedingungen
/// minus 1. Legen die Bedingungen die Funktion nicht eindeutig fest, bricht
/// die Funktion mit einer Meldung ab.
///
/// Das Ergebnis ist ein Dictionary mit den Schlüsseln
/// - `ansatz`: allgemeine Funktionsgleichung $f(x) = a x^n + …$,
/// - `math`: Funktionsgleichung mit den berechneten Koeffizienten,
/// - `math-digits`: Funktion `digits => content`, wie `math` mit gewählter Stellenzahl,
/// - `function`: Funktion `x => f(x)` zum Rechnen und für `graphen`,
/// - `conditions`: die Bedingungen im Formelsatz (Array),
/// - `condition-system`: die Bedingungen untereinander,
/// - `equations`: die Gleichungen des Gleichungssystems (Array),
/// - `system`: das Gleichungssystem untereinander,
/// - `coefficients`: die Koeffizienten als Dictionary `(a: …, b: …, …)`, höchster Grad zuerst.
///
/// ```typ
/// #let sb = steckbrief("f(0)=1", "f'(0)=0", "f(1)=0")
/// #sb.math
/// ```
///
/// - notation (str): Zahlenformat der Koeffizienten: `"decimal"`, `"scientific"` oder `"fraction"` (exakte Brüche)
/// - tolerance (float, int): Betrag, unter dem eine Zahl als 0 gilt
/// - ..args (arguments): Positionsargumente sind die Bedingungen als Text; benannte Argumente nimmt der Sink nicht an, er fängt nur alte Namen ab
/// -> dictionary
#let steckbrief(notation: "decimal", tolerance: 1e-10, ..args) = {
  check-named(
    "mathematik",
    "steckbrief",
    args,
    renamed: (precision: "tolerance"),
    allowed: ("notation", "tolerance"),
  )
  check-value(
    "mathematik",
    "steckbrief",
    "notation",
    notation,
    ("decimal", "scientific", "fraction"),
    renamed: (dec: "decimal", sci: "scientific", frac: "fraction"),
  )
  check-type("mathematik", "steckbrief", "tolerance", tolerance, (float, int), example: "1e-10")
  let conditions = args.pos()
  check-positional(
    "mathematik",
    "steckbrief",
    conditions,
    min: 1,
    max: coefficient-names.len(),
    hint: "Bedingungen als Text angeben, zum Beispiel `steckbrief(\"f(0)=1\", \"f'(0)=0\")`",
  )

  let parsed = conditions.map(parse-condition)
  let degree = parsed.len() - 1
  let count = degree + 1 // Anzahl der Koeffizienten

  // Gleichungssystem: je Bedingung eine Zeile [x^0, x^1, …, x^n | y],
  // bei Ableitungen die abgeleiteten Potenzen.
  let matrix = ()
  for condition in parsed {
    let x = text-to-float(condition.x)
    let row = ()
    for i in range(count) {
      let (factor, exponent) = derive-power(i, condition.order)
      row.push(if factor == 0 { 0 } else if exponent == 0 { factor } else { factor * calc.pow(x, exponent) })
    }
    row.push(text-to-float(condition.y))
    matrix.push(row)
  }

  // Gauß-Elimination mit Zeilentausch
  for i in range(count) {
    let pivot-row = i
    for k in range(i + 1, count) {
      if calc.abs(matrix.at(k).at(i)) > calc.abs(matrix.at(pivot-row).at(i)) {
        pivot-row = k
      }
    }
    if pivot-row != i {
      (matrix.at(i), matrix.at(pivot-row)) = (matrix.at(pivot-row), matrix.at(i))
    }
    let pivot = matrix.at(i).at(i)
    if calc.abs(pivot) <= tolerance {
      fail(
        "mathematik",
        "steckbrief",
        "die Bedingungen legen die Funktion nicht eindeutig fest (das Gleichungssystem hat keine eindeutige Lösung) – Bedingungen prüfen",
      )
    }
    for j in range(i, count + 1) {
      matrix.at(i).at(j) = matrix.at(i).at(j) / pivot
    }
    for k in range(count) {
      if k != i {
        let factor = matrix.at(k).at(i)
        for j in range(i, count + 1) {
          matrix.at(k).at(j) = matrix.at(k).at(j) - factor * matrix.at(i).at(j)
        }
      }
    }
  }
  let coefficients = matrix.map(row => row.last())

  // Dasselbe mit Brüchen für exakte Koeffizienten
  let exact-coefficients = if notation == "fraction" {
    let exact = ()
    for condition in parsed {
      let x = text-to-rational(condition.x)
      let row = ()
      for i in range(count) {
        let (factor, exponent) = derive-power(i, condition.order)
        row.push(if factor == 0 { (0, 1) } else if exponent == 0 { (factor, 1) } else {
          let power = (1, 1)
          for _ in range(exponent) { power = rational-mul(power, x) }
          rational-mul((factor, 1), power)
        })
      }
      row.push(text-to-rational(condition.y))
      exact.push(row)
    }
    for i in range(count) {
      let pivot-row = i
      for k in range(i + 1, count) {
        if rational-is-larger(exact.at(k).at(i), exact.at(pivot-row).at(i)) {
          pivot-row = k
        }
      }
      if pivot-row != i {
        (exact.at(i), exact.at(pivot-row)) = (exact.at(pivot-row), exact.at(i))
      }
      let pivot = exact.at(i).at(i)
      for j in range(i, count + 1) {
        exact.at(i).at(j) = rational-div(exact.at(i).at(j), pivot)
      }
      for k in range(count) {
        if k != i {
          let factor = exact.at(k).at(i)
          if not rational-is-zero(factor) {
            for j in range(i, count + 1) {
              exact.at(k).at(j) = rational-sub(exact.at(k).at(j), rational-mul(factor, exact.at(i).at(j)))
            }
          }
        }
      }
    }
    exact.map(row => row.last())
  } else { () }

  let number(value, digits: 2) = format-number(value, notation, digits: digits)

  // Gleichungen des Systems, einzeln und als Zeilen einer Matrix
  let equations = ()
  let system-rows = ()
  let widest-row = 0
  for condition in parsed {
    let x = text-to-float(condition.x)
    let terms = ()
    let cells = ()
    for i in range(degree, -1, step: -1) {
      let (factor, exponent) = derive-power(i, condition.order)
      if factor != 0 {
        let value = if exponent == 0 { factor } else { factor * calc.pow(x, exponent) }
        let name = coefficient-names.at(degree - i)
        let term = if calc.abs(calc.abs(value) - 1) < 0.01 {
          $#name$
        } else {
          let shown = number(calc.abs(value))
          $#shown#name$
        }
        if terms.len() == 0 {
          cells.push(if value < 0 { $-#term$ } else { term })
        } else {
          cells.push(if value < 0 { $-$ } else { $+$ })
          cells.push(term)
        }
        terms.push((term: term, negative: value < 0))
      }
    }

    let right-side = number(text-to-float(condition.y))
    widest-row = calc.max(widest-row, cells.len())
    system-rows.push((cells: cells, right-side: right-side))
    equations.push(if terms.len() == 0 {
      $0 = #right-side$
    } else {
      let equation = if terms.first().negative { $-#terms.first().term$ } else { terms.first().term }
      for entry in terms.slice(1) {
        equation = if entry.negative { $#equation - #entry.term$ } else { $#equation + #entry.term$ }
      }
      $#equation = #right-side$
    })
  }
  let system-layout = system-rows.map(row => {
    row.cells + ([],) * (widest-row - row.cells.len()) + ($=$, row.right-side)
  })

  // Die Bedingungen als eigenes System
  let condition-rows = parsed.map(condition => {
    let primes = if condition.order == 0 { [] } else { math.primes(condition.order) }
    (
      $f^#primes (#number(text-to-float(condition.x)))$,
      $ = $,
      $#number(text-to-float(condition.y))$,
    )
  })

  let ansatz = {
    let equation = none
    for i in range(degree, -1, step: -1) {
      let name = coefficient-names.at(degree - i)
      let term = if i == 0 { $#name$ } else if i == 1 { $#name\x$ } else { $#name\x^#i$ }
      equation = if equation == none { $f(x) = #term$ } else { $#equation + #term$ }
    }
    equation
  }

  // Funktionsgleichung aus Termen (term, negative)
  let join-equation(terms) = {
    if terms.len() == 0 { return $f(x) = 0$ }
    let equation = if terms.first().negative { $f(x) = -#terms.first().term$ } else { $f(x) = #terms.first().term$ }
    for entry in terms.slice(1) {
      equation = if entry.negative { $#equation - #entry.term$ } else { $#equation + #entry.term$ }
    }
    equation
  }

  let format-polynomial(digits: 2) = {
    let terms = ()
    for i in range(degree, -1, step: -1) {
      let value = coefficients.at(i)
      if calc.abs(value) >= tolerance {
        let size = calc.abs(value)
        let is-one = calc.abs(size - 1) < 0.01
        let shown = number(size, digits: digits)
        let term = if i == 0 {
          $#shown$
        } else if i == 1 {
          if is-one { $x$ } else { $#shown dot x$ }
        } else {
          if is-one { $x^#i$ } else { $#shown dot x^#i$ }
        }
        terms.push((term: term, negative: value < 0))
      }
    }
    join-equation(terms)
  }

  let format-exact-polynomial() = {
    let terms = ()
    for i in range(degree, -1, step: -1) {
      let value = exact-coefficients.at(i)
      if not rational-is-zero(value) {
        let size = rational-abs(value)
        let is-one = rational-is-one(size)
        let term = if i == 0 {
          format-rational(size)
        } else if i == 1 {
          if is-one { $x$ } else { $#format-rational(size) x$ }
        } else {
          if is-one { $x^#i$ } else { $#format-rational(size) x^#i$ }
        }
        terms.push((term: term, negative: rational-is-negative(value)))
      }
    }
    join-equation(terms)
  }

  let evaluate(x) = {
    let y = 0
    for i in range(count) {
      y = y + coefficients.at(i) * if i == 0 { 1 } else { calc.pow(x, i) }
    }
    y
  }

  let named-coefficients = (:)
  for i in range(count) {
    named-coefficients.insert(coefficient-names.at(i), coefficients.at(degree - i))
  }

  (
    ansatz: ansatz,
    math: if notation == "fraction" { format-exact-polynomial() } else { format-polynomial() },
    math-digits: digits => if notation == "fraction" { format-exact-polynomial() } else {
      format-polynomial(digits: digits)
    },
    function: evaluate,
    conditions: conditions.map(condition => eval("$" + condition + "$")),
    condition-system: [$mat(delim: "|", column-gap: #0.2em, align: #right, ..#condition-rows)$],
    equations: equations,
    system: [$mat(delim: "|", column-gap: #0.2em, align: #right, ..#system-layout)$],
    coefficients: named-coefficients,
  )
}
