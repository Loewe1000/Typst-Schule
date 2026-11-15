// Die sechs Regressionen.
#import "@preview/fancy-units:0.1.1": unit as fancy-unit
#import "internal/check.typ": fail, check-type
#import "equations.typ": format-number, format-unit, combine-units, format-equation-term, build-equation, format-simple-equation, check-fit-arguments, fit, has-units

/// Lineare Regression $y = m x + b$.
///
/// Das Ergebnis ist ein Dictionary:
/// - `math`: die Gleichung als Inhalt, mit Einheiten, wenn beide Datensätze eine haben
/// - `math-digits`: Funktion `digits => content`, dieselbe Gleichung mit anderer Stellenzahl
/// - `coefficients`: `(m: …, b: …)`, Steigung und Achsenabschnitt
/// - `function`: Funktion `x => y`, zum Beispiel für `graphen`
///
/// ```typ
/// #let t = datensatz((1, 2, 3, 4), name: $t$, unit: "s")
/// #let s = datensatz((2.1, 3.9, 6.2, 7.8), name: $s$, unit: "m")
/// #let fit = lineare-regression(x: t, y: s)
/// #fit.math
/// ```
///
/// - x (dictionary, array, none): x-Werte als Datensatz oder Liste aus Zahlen; Pflichtangabe
/// - y (dictionary, array, none): y-Werte als Datensatz oder Liste aus Zahlen; Pflichtangabe
/// - notation (str): Zahlschreibweise: `"decimal"` oder `"scientific"`
/// - tolerance (float): Nullschwelle; ein Summand mit kleinerem Koeffizienten entfällt
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> dictionary
#let lineare-regression(x: none, y: none, notation: "decimal", tolerance: 1e-10, ..deprecated) = {
  let caller = "lineare-regression"
  check-fit-arguments(caller, x, y, notation, tolerance, deprecated, example: "lineare-regression(x: t, y: s)")

  let solve(pairs) = {
    let n = pairs.len()
    let (sx, sy) = (0, 0)
    for p in pairs {
      sx += p.at(0)
      sy += p.at(1)
    }
    let (mx, my) = (sx / n, sy / n)
    let (numerator, denominator) = (0, 0)
    for p in pairs {
      let dx = p.at(0) - mx
      let dy = p.at(1) - my
      numerator += dx * dy
      denominator += dx * dx
    }
    if denominator == 0 {
      fail("physik", caller, "alle x-Werte sind gleich, die Gerade ist nicht bestimmt – verschiedene x-Werte angeben")
    }
    let m = numerator / denominator
    (m, my - m * mx)
  }

  let format(k, x-name: none, y-name: none, x-unit: none, y-unit: none, notation: "decimal", tolerance: 1e-10, digits: 2) = {
    if has-units(x-unit, y-unit) {
      let terms = (
        format-equation-term(k.at(0), unit: combine-units(y-unit, x-unit), x-name: x-name, x-power: 1, notation: notation, tolerance: 1e-20, digits: digits),
        format-equation-term(k.at(1), unit: format-unit(y-unit), x-name: x-name, x-power: 0, notation: notation, tolerance: tolerance, digits: digits),
      )
      build-equation(y-name, terms.filter(t => not t.skip))
    } else {
      format-simple-equation(k, notation: notation, tolerance: tolerance, digits: digits)
    }
  }

  let result = fit(x, y, solve, format, coefficient-names: ("m", "b"), min-count: 2, notation: notation, tolerance: tolerance, caller: caller)
  let c = result.coefficients
  result.insert("function", x => c.m * x + c.b)
  result
}

/// Quadratische Regression $y = a x^2 + b x + c$.
///
/// Das Ergebnis hat die Schlüssel `math`, `math-digits`, `function` und
/// `coefficients: (a: …, b: …, c: …)`.
///
/// ```typ
/// #let fit = quadratische-regression(x: (0, 1, 2, 3), y: (0.1, 1.1, 3.9, 9.2))
/// #fit.math
/// ```
///
/// - x (dictionary, array, none): x-Werte als Datensatz oder Liste aus Zahlen; Pflichtangabe
/// - y (dictionary, array, none): y-Werte als Datensatz oder Liste aus Zahlen; Pflichtangabe
/// - notation (str): Zahlschreibweise: `"decimal"` oder `"scientific"`
/// - tolerance (float): Nullschwelle; ein Summand mit kleinerem Koeffizienten entfällt
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> dictionary
#let quadratische-regression(x: none, y: none, notation: "decimal", tolerance: 1e-10, ..deprecated) = {
  let caller = "quadratische-regression"
  check-fit-arguments(caller, x, y, notation, tolerance, deprecated, example: "quadratische-regression(x: t, y: s)")

  let solve(pairs) = {
    let n = pairs.len()
    let (sx, sy, sx2, sx3, sx4, sxy, sx2y) = (0, 0, 0, 0, 0, 0, 0)
    for p in pairs {
      let (x, y) = (p.at(0), p.at(1))
      let (x2, x3, x4) = (x * x, x * x * x, x * x * x * x)
      sx += x
      sy += y
      sx2 += x2
      sx3 += x3
      sx4 += x4
      sxy += x * y
      sx2y += x2 * y
    }

    let det = sx4 * (sx2 * n - sx * sx) - sx3 * (sx3 * n - sx * sx2) + sx2 * (sx3 * sx - sx2 * sx2)
    if det == 0 {
      fail("physik", caller, "die Parabel ist nicht eindeutig bestimmt – mindestens drei verschiedene x-Werte angeben")
    }

    let det-a = sx2y * (sx2 * n - sx * sx) - sx3 * (sxy * n - sx * sy) + sx2 * (sxy * sx - sx2 * sy)
    let det-b = sx4 * (sxy * n - sx * sy) - sx2y * (sx3 * n - sx * sx2) + sx2 * (sx3 * sy - sxy * sx2)
    let det-c = sx4 * (sx2 * sy - sxy * sx) - sx3 * (sx3 * sy - sxy * sx2) + sx2y * (sx3 * sx - sx2 * sx2)

    (det-a / det, det-b / det, det-c / det)
  }

  let format(k, x-name: none, y-name: none, x-unit: none, y-unit: none, notation: "decimal", tolerance: 1e-10, digits: 2) = {
    if has-units(x-unit, y-unit) {
      let terms = (
        format-equation-term(k.at(0), unit: combine-units(y-unit, x-unit, x-power: 2), x-name: x-name, x-power: 2, notation: notation, tolerance: 1e-20, digits: digits),
        format-equation-term(k.at(1), unit: combine-units(y-unit, x-unit), x-name: x-name, x-power: 1, notation: notation, tolerance: tolerance, digits: digits),
        format-equation-term(k.at(2), unit: format-unit(y-unit), x-name: x-name, x-power: 0, notation: notation, tolerance: tolerance, digits: digits),
      )
      build-equation(y-name, terms.filter(t => not t.skip))
    } else {
      format-simple-equation(k, notation: notation, tolerance: tolerance, digits: digits)
    }
  }

  let result = fit(x, y, solve, format, coefficient-names: ("a", "b", "c"), min-count: 3, notation: notation, tolerance: tolerance, caller: caller)
  let c = result.coefficients
  result.insert("function", x => c.a * x * x + c.b * x + c.c)
  result
}

/// Wurzel-Regression $y = a sqrt(x) + b$. Alle x-Werte müssen größer oder
/// gleich null sein.
///
/// Das Ergebnis hat die Schlüssel `math`, `math-digits`, `function` und
/// `coefficients: (a: …, b: …)`. `function` liefert für negative x `none`.
///
/// ```typ
/// #let fit = wurzel-regression(x: (0, 1, 4, 9), y: (1, 3.1, 4.9, 7))
/// #fit.math
/// ```
///
/// - x (dictionary, array, none): x-Werte als Datensatz oder Liste aus Zahlen; Pflichtangabe
/// - y (dictionary, array, none): y-Werte als Datensatz oder Liste aus Zahlen; Pflichtangabe
/// - notation (str): Zahlschreibweise: `"decimal"` oder `"scientific"`
/// - tolerance (float): Nullschwelle; ein Summand mit kleinerem Koeffizienten entfällt
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> dictionary
#let wurzel-regression(x: none, y: none, notation: "decimal", tolerance: 1e-10, ..deprecated) = {
  let caller = "wurzel-regression"
  check-fit-arguments(caller, x, y, notation, tolerance, deprecated, example: "wurzel-regression(x: t, y: s)")

  let solve(pairs) = {
    for p in pairs {
      if p.at(0) < 0 {
        fail("physik", caller, "x-Wert `" + repr(p.at(0)) + "` ist negativ – die Wurzel-Regression braucht x-Werte ab 0")
      }
    }
    let n = pairs.len()
    let (sz, sy, sz2, szy) = (0, 0, 0, 0)
    for p in pairs {
      let z = calc.sqrt(p.at(0))
      sz += z
      sy += p.at(1)
      sz2 += z * z
      szy += z * p.at(1)
    }
    let denominator = n * sz2 - sz * sz
    if denominator == 0 {
      fail("physik", caller, "alle x-Werte sind gleich, die Kurve ist nicht bestimmt – verschiedene x-Werte angeben")
    }
    ((n * szy - sz * sy) / denominator, (sy * sz2 - sz * szy) / denominator)
  }

  let format(k, x-name: none, y-name: none, x-unit: none, y-unit: none, notation: "decimal", tolerance: 1e-10, digits: 2) = {
    let (a, b) = (k.at(0), k.at(1))
    let a-shown = format-number(a, notation: notation, digits: digits)
    let b-shown = format-number(calc.abs(b), notation: notation, digits: digits)

    if has-units(x-unit, y-unit) {
      let a-unit = if type(y-unit) == content and type(x-unit) == content {
        $#y-unit \/ sqrt(#x-unit)$
      } else if type(y-unit) == content {
        $#y-unit \/ sqrt(upright(#x-unit))$
      } else if type(x-unit) == content {
        $upright(#y-unit) \/ sqrt(#x-unit)$
      } else {
        $upright(#y-unit) / sqrt(upright(#x-unit))$
      }

      let equation = $#y-name = #a-shown #a-unit dot sqrt(#x-name)$
      if calc.abs(b) >= tolerance {
        let b-unit = format-unit(y-unit)
        equation = if b >= 0 { $#equation + #b-shown #b-unit$ } else { $#equation - #b-shown #b-unit$ }
      }
      equation
    } else {
      let equation = $y = #a-shown sqrt(x)$
      if calc.abs(b) >= tolerance {
        equation = if b >= 0 { $#equation + #b-shown$ } else { $#equation - #b-shown$ }
      }
      equation
    }
  }

  let result = fit(x, y, solve, format, coefficient-names: ("a", "b"), min-count: 2, notation: notation, tolerance: tolerance, caller: caller)
  let c = result.coefficients
  result.insert("function", x => if x < 0 { none } else { c.a * calc.sqrt(x) + c.b })
  result
}

/// Exponentielle Regression $y = b dot e^(a x)$. Alle y-Werte müssen
/// positiv sein.
///
/// Das Ergebnis hat die Schlüssel `math`, `math-digits`, `function` und
/// `coefficients: (a: …, b: …)`.
///
/// ```typ
/// #let fit = exponentielle-regression(x: (0, 1, 2, 3), y: (2, 2.9, 4.6, 6.7))
/// #fit.math
/// ```
///
/// - x (dictionary, array, none): x-Werte als Datensatz oder Liste aus Zahlen; Pflichtangabe
/// - y (dictionary, array, none): y-Werte als Datensatz oder Liste aus Zahlen; Pflichtangabe
/// - notation (str): Zahlschreibweise: `"decimal"` oder `"scientific"`
/// - tolerance (float): Nullschwelle; ohne Wirkung auf diese Gleichung
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> dictionary
#let exponentielle-regression(x: none, y: none, notation: "decimal", tolerance: 1e-10, ..deprecated) = {
  let caller = "exponentielle-regression"
  check-fit-arguments(caller, x, y, notation, tolerance, deprecated, example: "exponentielle-regression(x: t, y: s)")

  let solve(pairs) = {
    for p in pairs {
      if p.at(1) <= 0 {
        fail("physik", caller, "y-Wert `" + repr(p.at(1)) + "` ist nicht positiv – die exponentielle Regression braucht y-Werte über 0")
      }
    }
    let n = pairs.len()
    let (sx, sy-log, sx2, sxy-log) = (0, 0, 0, 0)
    for p in pairs {
      let (x, y-log) = (p.at(0), calc.ln(p.at(1)))
      sx += x
      sy-log += y-log
      sx2 += x * x
      sxy-log += x * y-log
    }
    let denominator = n * sx2 - sx * sx
    if denominator == 0 {
      fail("physik", caller, "alle x-Werte sind gleich, die Kurve ist nicht bestimmt – verschiedene x-Werte angeben")
    }
    let a = (n * sxy-log - sx * sy-log) / denominator
    let b-log = (sy-log * sx2 - sx * sxy-log) / denominator
    (a, calc.exp(b-log))
  }

  let format(k, x-name: none, y-name: none, x-unit: none, y-unit: none, notation: "decimal", tolerance: 1e-10, digits: 2) = {
    let (a, b) = (k.at(0), k.at(1))

    // Ein Koeffizient nahe 1 wird nicht ausgeschrieben.
    let a-is-one = calc.abs(a - 1) < 0.01
    let a-shown = if a-is-one { "" } else { format-number(a, notation: notation, digits: digits) }
    let b-is-one = calc.abs(b - 1) < 0.01
    let b-shown = if b-is-one { "" } else { format-number(b, notation: notation, digits: digits) }

    if has-units(x-unit, y-unit) {
      let a-unit = if type(x-unit) == content {
        $1 \/ #x-unit$
      } else {
        fancy-unit(per-mode: "fraction")[1/#x-unit]
      }
      let b-unit = format-unit(y-unit)

      if b-is-one and a-is-one {
        $#y-name = #b-unit dot e^(#a-unit dot #x-name)$
      } else if b-is-one {
        $#y-name = #b-unit dot e^(#a-shown #a-unit dot #x-name)$
      } else if a-is-one {
        $#y-name = #b-shown #b-unit dot e^(#a-unit dot #x-name)$
      } else {
        $#y-name = #b-shown #b-unit dot e^(#a-shown #a-unit dot #x-name)$
      }
    } else {
      if b-is-one and a-is-one {
        $y = e^x$
      } else if b-is-one {
        $y = e^(#a-shown x)$
      } else if a-is-one {
        $y = #b-shown dot e^x$
      } else {
        $y = #b-shown dot e^(#a-shown x)$
      }
    }
  }

  let result = fit(x, y, solve, format, coefficient-names: ("a", "b"), min-count: 2, notation: notation, tolerance: tolerance, caller: caller)
  let c = result.coefficients
  result.insert("function", x => c.b * calc.exp(c.a * x))
  result
}

/// Potenz-Regression $y = a dot x^m$. Alle x- und y-Werte müssen positiv sein.
///
/// Das Ergebnis hat die Schlüssel `math`, `math-digits`, `function` und
/// `coefficients: (a: …, m: …)`. `function` liefert für x ≤ 0 `none`.
///
/// ```typ
/// #let fit = potenz-regression(x: (1, 2, 3, 4), y: (2, 7.9, 18.2, 31.8))
/// #fit.math
/// ```
///
/// - x (dictionary, array, none): x-Werte als Datensatz oder Liste aus Zahlen; Pflichtangabe
/// - y (dictionary, array, none): y-Werte als Datensatz oder Liste aus Zahlen; Pflichtangabe
/// - notation (str): Zahlschreibweise: `"decimal"` oder `"scientific"`
/// - tolerance (float): Nullschwelle; ohne Wirkung auf diese Gleichung
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> dictionary
#let potenz-regression(x: none, y: none, notation: "decimal", tolerance: 1e-10, ..deprecated) = {
  let caller = "potenz-regression"
  check-fit-arguments(caller, x, y, notation, tolerance, deprecated, example: "potenz-regression(x: t, y: s)")

  let solve(pairs) = {
    for p in pairs {
      if p.at(0) <= 0 {
        fail("physik", caller, "x-Wert `" + repr(p.at(0)) + "` ist nicht positiv – die Potenz-Regression braucht x-Werte über 0")
      }
      if p.at(1) <= 0 {
        fail("physik", caller, "y-Wert `" + repr(p.at(1)) + "` ist nicht positiv – die Potenz-Regression braucht y-Werte über 0")
      }
    }
    let n = pairs.len()
    let (sx-log, sy-log, sx-log2, sxy-log) = (0, 0, 0, 0)
    for p in pairs {
      let (x-log, y-log) = (calc.ln(p.at(0)), calc.ln(p.at(1)))
      sx-log += x-log
      sy-log += y-log
      sx-log2 += x-log * x-log
      sxy-log += x-log * y-log
    }
    let denominator = n * sx-log2 - sx-log * sx-log
    if denominator == 0 {
      fail("physik", caller, "alle x-Werte sind gleich, die Kurve ist nicht bestimmt – verschiedene x-Werte angeben")
    }
    let m = (n * sxy-log - sx-log * sy-log) / denominator
    let a-log = (sy-log * sx-log2 - sx-log * sxy-log) / denominator
    (calc.exp(a-log), m)
  }

  let format(k, x-name: none, y-name: none, x-unit: none, y-unit: none, notation: "decimal", tolerance: 1e-10, digits: 2) = {
    let (a, m) = (k.at(0), k.at(1))
    let a-is-one = calc.abs(a - 1) < 0.01
    let m-shown = format-number(m, notation: notation, digits: digits)

    if has-units(x-unit, y-unit) {
      let a-unit = if type(y-unit) == content and type(x-unit) == content {
        $frac(#y-unit, #x-unit^#m-shown)$
      } else if type(y-unit) == content {
        $frac(#y-unit, upright(#x-unit)^#m-shown)$
      } else if type(x-unit) == content {
        $frac(upright(#y-unit), #x-unit^#m-shown)$
      } else {
        $frac(upright(#y-unit), upright(#x-unit)^#m-shown)$
      }

      if a-is-one {
        $#y-name = #a-unit dot #x-name^#m-shown$
      } else {
        let a-shown = format-number(a, notation: notation, digits: digits)
        $#y-name = #a-shown #a-unit dot #x-name^#m-shown$
      }
    } else {
      if a-is-one {
        $y = x^#m-shown$
      } else {
        let a-shown = format-number(a, notation: notation, digits: digits)
        $y = #a-shown dot x^#m-shown$
      }
    }
  }

  let result = fit(x, y, solve, format, coefficient-names: ("a", "m"), min-count: 2, notation: notation, tolerance: tolerance, caller: caller)
  let c = result.coefficients
  result.insert("function", x => if x <= 0 { none } else { c.a * calc.pow(x, c.m) })
  result
}

/// Polynom-Regression $y = c_0 + c_1 x + … + c_n x^n$ vom Grad `degree`.
/// Braucht mindestens `degree + 1` gültige Wertepaare.
///
/// Das Ergebnis hat die Schlüssel `math`, `math-digits`, `function` und
/// `coefficients: (c0: …, c1: …, …)`, aufsteigend nach der Potenz.
///
/// ```typ
/// #let fit = polynom-regression(x: (0, 1, 2, 3, 4), y: (1, 2.1, 8.8, 28.3, 65), degree: 3)
/// #fit.math
/// ```
///
/// - x (dictionary, array, none): x-Werte als Datensatz oder Liste aus Zahlen; Pflichtangabe
/// - y (dictionary, array, none): y-Werte als Datensatz oder Liste aus Zahlen; Pflichtangabe
/// - degree (int, none): Grad des Polynoms, zum Beispiel `3`; Pflichtangabe
/// - notation (str): Zahlschreibweise: `"decimal"` oder `"scientific"`
/// - tolerance (float): Nullschwelle; ein Summand mit kleinerem Koeffizienten entfällt
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> dictionary
#let polynom-regression(x: none, y: none, degree: none, notation: "decimal", tolerance: 1e-10, ..deprecated) = {
  let caller = "polynom-regression"
  check-fit-arguments(
    caller,
    x,
    y,
    notation,
    tolerance,
    deprecated,
    example: "polynom-regression(x: t, y: s, degree: 3)",
    allowed: ("x", "y", "degree", "notation", "tolerance"),
  )
  if degree == none {
    fail("physik", caller, "`degree` fehlt – `polynom-regression(x: t, y: s, degree: 3)` schreiben")
  }
  check-type("physik", caller, "degree", degree, int, example: "3")
  if degree < 0 {
    fail("physik", caller, "`degree: " + str(degree) + "` ist negativ – einen Grad ab 0 angeben, zum Beispiel `degree: 3`")
  }

  let solve(pairs) = {
    let count = degree + 1
    let power(x, i) = if i == 0 { 1 } else { calc.pow(x, i) }

    let power-sums = (2 * degree + 1) * (0,)
    let right-side = count * (0,)

    for p in pairs {
      let x = p.at(0)
      for i in range(power-sums.len()) { power-sums.at(i) += power(x, i) }
      for i in range(count) { right-side.at(i) += p.at(1) * power(x, i) }
    }

    let matrix = ()
    for i in range(count) {
      let row = (count + 1) * (0,)
      for j in range(count) { row.at(j) = power-sums.at(i + j) }
      row.at(-1) = right-side.at(i)
      matrix.push(row)
    }

    for i in range(count) {
      let pivot-row = i
      for k in range(i + 1, count) {
        if calc.abs(matrix.at(k).at(i)) > calc.abs(matrix.at(pivot-row).at(i)) { pivot-row = k }
      }
      (matrix.at(i), matrix.at(pivot-row)) = (matrix.at(pivot-row), matrix.at(i))

      let pivot = matrix.at(i).at(i)
      if pivot == 0 {
        fail("physik", caller, "das Polynom ist nicht eindeutig bestimmt – mindestens " + str(count) + " verschiedene x-Werte angeben oder `degree` verkleinern")
      }

      for j in range(i, count + 1) { matrix.at(i).at(j) /= pivot }
      for k in range(count) {
        if i != k {
          let factor = matrix.at(k).at(i)
          for j in range(i, count + 1) { matrix.at(k).at(j) -= factor * matrix.at(i).at(j) }
        }
      }
    }

    matrix.map(row => row.last())
  }

  let format(k, x-name: none, y-name: none, x-unit: none, y-unit: none, notation: "decimal", tolerance: 1e-10, digits: 2) = {
    if has-units(x-unit, y-unit) {
      let terms = ()
      for i in range(k.len() - 1, -1, step: -1) {
        let unit = if i == 0 { format-unit(y-unit) } else { combine-units(y-unit, x-unit, x-power: i) }
        terms.push(format-equation-term(k.at(i), unit: unit, x-name: x-name, x-power: i, notation: notation, tolerance: tolerance, digits: digits))
      }
      build-equation(y-name, terms.filter(t => not t.skip))
    } else {
      let terms = ()
      for i in range(k.len() - 1, -1, step: -1) {
        if calc.abs(k.at(i)) >= tolerance {
          let magnitude = calc.abs(k.at(i))
          let is-one = calc.abs(magnitude - 1) < 0.01

          let term = if i == 0 {
            // konstanter Summand: immer zeigen
            let shown = format-number(magnitude, notation: notation, digits: digits)
            $#shown$
          } else if i == 1 {
            if is-one {
              $x$
            } else {
              let shown = format-number(magnitude, notation: notation, digits: digits)
              $#shown x$
            }
          } else {
            if is-one {
              $x^#i$
            } else {
              let shown = format-number(magnitude, notation: notation, digits: digits)
              $#shown x^#i$
            }
          }
          terms.push((term: term, is-negative: k.at(i) < 0, skip: false))
        }
      }
      if terms.len() == 0 { $y = 0$ } else { build-equation($y$, terms) }
    }
  }

  let names = range(degree + 1).map(i => "c" + str(i))
  let result = fit(x, y, solve, format, coefficient-names: names, min-count: degree + 1, notation: notation, tolerance: tolerance, caller: caller)
  let c = result.coefficients
  result.insert("function", x => {
    let y = 0
    for i in range(degree + 1) {
      y += c.at("c" + str(i)) * if i == 0 { 1 } else { calc.pow(x, i) }
    }
    y
  })
  result
}
