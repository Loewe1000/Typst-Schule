#import "@preview/zero:0.5.0": num as znum
#import "@preview/fancy-units:0.1.1": unit

#let format-number(value, notation: "dec", digits: 2) = {
  if notation == "sci" {
    let exp = if value == 0 { 0 } else { calc.floor(calc.log(calc.abs(value), base: 10)) }
    let mantissa = value / calc.pow(10, exp)
    let mantissa_formatted = znum(str(mantissa), decimal-separator:",", digits: digits)
    
    if exp == 0 {
      mantissa_formatted
    } else if exp == 1 {
      $#mantissa_formatted dot 10$
    } else {
      $#mantissa_formatted dot 10^#exp$
    }
  } else {
    znum(value, decimal-separator:",", digits: digits)
  }
}

#let format-unit(einheit) = {
  if type(einheit) == content { einheit } else { unit(per-mode: "fraction")[#einheit] }
}

#let combine-units(y_einheit, x_einheit, x_potenz: 1) = {
  let make-frac(y, x, pow) = {
    let y-part = if type(y) == content { y } else { $upright(#y)$ }
    let x-part = if type(x) == content { x } else { $upright(#x)$ }
    if pow == 1 { $frac(#y-part, #x-part)$ } else { $frac(#y-part, #x-part^#pow)$ }
  }
  
  if type(y_einheit) == str and type(x_einheit) == str and x_einheit.contains("/") {
    let parts = x_einheit.split("/")
    if parts.len() == 2 {
      let num = parts.at(0).trim()
      let den = parts.at(1).trim()
      if x_potenz == 1 {
        $frac(upright(#y_einheit) upright(#den), upright(#num))$
      } else {
        $frac(upright(#y_einheit) upright(#den)^#x_potenz, upright(#num)^#x_potenz)$
      }
    } else {
      make-frac(y_einheit, x_einheit, x_potenz)
    }
  } else {
    make-frac(y_einheit, x_einheit, x_potenz)
  }
}

#let format-equation-term(koeff, koeff-einheit, x-name, x-potenz, is-first, notation, precision) = {
  if calc.abs(koeff) < precision { return (skip: true) }
  
  let koeff-str = format-number(calc.abs(koeff), notation: notation)
  let term = if x-potenz == 0 {
    $#koeff-str #koeff-einheit$
  } else if x-potenz == 1 {
    $#koeff-str #koeff-einheit dot #x-name$
  } else {
    $#koeff-str #koeff-einheit dot #x-name^#x-potenz$
  }
  
  (skip: false, term: term, is-negative: koeff < 0)
}

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

#let format-simple-equation(y-name, koeffs, x-name, notation, precision) = {
  let strs = koeffs.map(k => format-number(calc.abs(k), notation: notation))
  let eq = $y = #strs.at(0) #x-name^#(koeffs.len() - 1)$
  
  for (i, k) in koeffs.slice(1).enumerate() {
    let pow = koeffs.len() - 2 - i
    if calc.abs(k) >= precision {
      let term = if pow == 0 { strs.at(i + 1) } else if pow == 1 { $#strs.at(i + 1) x$ } else { $#strs.at(i + 1) x^#pow$ }
      eq = if k >= 0 { $#eq + #term$ } else { $#eq - #term$ }
    }
  }
  eq
}

#let regression(x_param, y_param, algorithmus, format-function, koeffizienten-namen: (), min-punkte: 2, notation: "dec", precision: 1e-10) = {
  let extract-data(param) = {
    if type(param) == dictionary and "werte" in param {
      (werte: param.werte, einheit: param.einheit, name: param.name)
    } else {
      (werte: param, einheit: none, name: none)
    }
  }
  
  let x_data = extract-data(x_param)
  let y_data = extract-data(y_param)
  
  let gueltige_paare = ()
  for i in range(calc.min(x_data.werte.len(), y_data.werte.len())) {
    let x_val = x_data.werte.at(i)
    let y_val = y_data.werte.at(i)
    if x_val != none and y_val != none and type(x_val) != content and type(y_val) != content {
      gueltige_paare.push((x_val, y_val))
    }
  }
  
  assert(gueltige_paare.len() >= min-punkte, message: "Nicht genug gültige Datenpunkte")

  let koeffizienten = algorithmus(gueltige_paare)
  let math_output = format-function(koeffizienten, x_name: x_data.name, y_name: y_data.name, 
    x_einheit: x_data.einheit, y_einheit: y_data.einheit, notation: notation, precision: precision)
  
  let result = (math: math_output)
  for (i, name) in koeffizienten-namen.enumerate() {
    result.insert(name, koeffizienten.at(i))
  }
  return result
}

#let lineare_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
  let algorithmus(paare) = {
    let n = paare.len()
    let (sx, sy) = (0, 0)
    for p in paare { sx += p.at(0); sy += p.at(1) }
    let (mx, my) = (sx / n, sy / n)
    let (num, den) = (0, 0)
    for p in paare {
      let dx = p.at(0) - mx
      let dy = p.at(1) - my
      num += dx * dy
      den += dx * dx
    }
    let m = num / den
    (m, my - m * mx)
  }
  
  let format-func(koeff, x_name: none, y_name: none, x_einheit: none, y_einheit: none, notation: "dec", precision: 1e-10) = {
    if x_einheit != none and y_einheit != none {
      let terms = (
        format-equation-term(koeff.at(0), combine-units(y_einheit, x_einheit), x_name, 1, true, notation, 1e-20),
        format-equation-term(koeff.at(1), format-unit(y_einheit), x_name, 0, false, notation, precision),
      )
      build-equation(y_name, terms.filter(t => not t.skip))
    } else {
      format-simple-equation(y_name, koeff, $x$, notation, precision)
    }
  }
  
  let result = regression(x_param, y_param, algorithmus, format-func, 
    koeffizienten-namen: ("m", "b"), min-punkte: 2, notation: notation, precision: precision)
  result.insert("function", (x) => result.m * x + result.b)
  result
}

#let quadratische_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
  let algorithmus(paare) = {
    let n = paare.len()
    let (sx, sy, sx2, sx3, sx4, sxy, sx2y) = (0, 0, 0, 0, 0, 0, 0)
    for p in paare {
      let (x, y) = (p.at(0), p.at(1))
      let (x2, x3, x4) = (x*x, x*x*x, x*x*x*x)
      sx += x; sy += y; sx2 += x2; sx3 += x3; sx4 += x4; sxy += x*y; sx2y += x2*y
    }
    
    let det_A = sx4 * (sx2 * n - sx * sx) - sx3 * (sx3 * n - sx * sx2) + sx2 * (sx3 * sx - sx2 * sx2)
    assert(det_A != 0, message: "Determinante ist null")
    
    let det_Ax = sx2y * (sx2 * n - sx * sx) - sx3 * (sxy * n - sx * sy) + sx2 * (sxy * sx - sx2 * sy)
    let det_Ay = sx4 * (sxy * n - sx * sy) - sx2y * (sx3 * n - sx * sx2) + sx2 * (sx3 * sy - sxy * sx2)
    let det_Az = sx4 * (sx2 * sy - sxy * sx) - sx3 * (sx3 * sy - sxy * sx2) + sx2y * (sx3 * sx - sx2 * sx2)
    
    (det_Ax / det_A, det_Ay / det_A, det_Az / det_A)
  }
  
  let format-func(koeff, x_name: none, y_name: none, x_einheit: none, y_einheit: none, notation: "dec", precision: 1e-10) = {
    if x_einheit != none and y_einheit != none {
      let terms = (
        format-equation-term(koeff.at(0), combine-units(y_einheit, x_einheit, x_potenz: 2), x_name, 2, true, notation, 1e-20),
        format-equation-term(koeff.at(1), combine-units(y_einheit, x_einheit), x_name, 1, false, notation, precision),
        format-equation-term(koeff.at(2), format-unit(y_einheit), x_name, 0, false, notation, precision),
      )
      build-equation(y_name, terms.filter(t => not t.skip))
    } else {
      format-simple-equation(y_name, koeff, $x$, notation, precision)
    }
  }
  
  let result = regression(x_param, y_param, algorithmus, format-func,
    koeffizienten-namen: ("a", "b", "c"), min-punkte: 3, notation: notation, precision: precision)
  result.insert("function", (x) => result.a * x * x + result.b * x + result.c)
  result
}

#let wurzel_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
  let algorithmus(paare) = {
    for p in paare { assert(p.at(0) >= 0, message: "x-Werte müssen nicht-negativ sein") }
    let n = paare.len()
    let (sz, sy, sz2, szy) = (0, 0, 0, 0)
    for p in paare {
      let z = calc.sqrt(p.at(0))
      sz += z; sy += p.at(1); sz2 += z * z; szy += z * p.at(1)
    }
    let den = n * sz2 - sz * sz
    assert(den != 0, message: "Keine eindeutige Lösung")
    ((n * szy - sz * sy) / den, (sy * sz2 - sz * szy) / den)
  }
  
  let format-func(koeff, x_name: none, y_name: none, x_einheit: none, y_einheit: none, notation: "dec", precision: 1e-10) = {
    let (a, b) = (koeff.at(0), koeff.at(1))
    let a_str = format-number(a, notation: notation)
    let b_str = format-number(calc.abs(b), notation: notation)
    
    if x_einheit != none and y_einheit != none {
      let a_einheit = if type(y_einheit) == content and type(x_einheit) == content {
        $#y_einheit \/ sqrt(#x_einheit)$
      } else if type(y_einheit) == content {
        $#y_einheit \/ sqrt(upright(#x_einheit))$
      } else if type(x_einheit) == content {
        $upright(#y_einheit) \/ sqrt(#x_einheit)$
      } else {
        $upright(#y_einheit) / sqrt(upright(#x_einheit))$
      }
      
      let eq = $#y_name = #a_str #a_einheit dot sqrt(#x_name)$
      if calc.abs(b) >= precision {
        let b_einheit = format-unit(y_einheit)
        eq = if b >= 0 { $#eq + #b_str #b_einheit$ } else { $#eq - #b_str #b_einheit$ }
      }
      eq
    } else {
      let eq = $y = #a_str sqrt(x)$
      if calc.abs(b) >= precision {
        eq = if b >= 0 { $#eq + #b_str$ } else { $#eq - #b_str$ }
      }
      eq
    }
  }
  
  let result = regression(x_param, y_param, algorithmus, format-func,
    koeffizienten-namen: ("a", "b"), min-punkte: 2, notation: notation, precision: precision)
  result.insert("function", (x) => if x < 0 { none } else { result.a * calc.sqrt(x) + result.b })
  result
}

#let exponentielle_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
  let algorithmus(paare) = {
    for p in paare { assert(p.at(1) > 0, message: "y-Werte müssen positiv sein") }
    let n = paare.len()
    let (sx, sy_log, sx2, sxy_log) = (0, 0, 0, 0)
    for p in paare {
      let (x, y_log) = (p.at(0), calc.ln(p.at(1)))
      sx += x; sy_log += y_log; sx2 += x * x; sxy_log += x * y_log
    }
    let den = n * sx2 - sx * sx
    assert(den != 0, message: "Keine eindeutige Lösung")
    let a = (n * sxy_log - sx * sy_log) / den
    let B = (sy_log * sx2 - sx * sxy_log) / den
    (a, calc.exp(B))
  }
  
  let format-func(koeff, x_name: none, y_name: none, x_einheit: none, y_einheit: none, notation: "dec", precision: 1e-10) = {
    let (a, b) = (koeff.at(0), koeff.at(1))
    let a_str = format-number(a, notation: notation)
    let b_str = format-number(b, notation: notation)
    
    if x_einheit != none and y_einheit != none {
      let a_einheit = if type(x_einheit) == content {
        $1 \/ #x_einheit$
      } else {
        unit(per-mode: "fraction")[1/#x_einheit]
      }
      let b_einheit = format-unit(y_einheit)
      $#y_name = #b_str #b_einheit dot e^(#a_str #a_einheit dot #x_name)$
    } else {
      $y = #b_str dot e^(#a_str x)$
    }
  }
  
  let result = regression(x_param, y_param, algorithmus, format-func,
    koeffizienten-namen: ("a", "b"), min-punkte: 2, notation: notation, precision: precision)
  result.insert("function", (x) => result.b * calc.exp(result.a * x))
  result
}

#let potenz_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
  let algorithmus(paare) = {
    for p in paare { 
      assert(p.at(0) > 0, message: "x-Werte müssen positiv sein")
      assert(p.at(1) > 0, message: "y-Werte müssen positiv sein")
    }
    let n = paare.len()
    let (sx_log, sy_log, sx_log2, sxy_log) = (0, 0, 0, 0)
    for p in paare {
      let (x_log, y_log) = (calc.ln(p.at(0)), calc.ln(p.at(1)))
      sx_log += x_log; sy_log += y_log; sx_log2 += x_log * x_log; sxy_log += x_log * y_log
    }
    let den = n * sx_log2 - sx_log * sx_log
    assert(den != 0, message: "Keine eindeutige Lösung")
    let m = (n * sxy_log - sx_log * sy_log) / den
    let B = (sy_log * sx_log2 - sx_log * sxy_log) / den
    (calc.exp(B), m)
  }
  
  let format-func(koeff, x_name: none, y_name: none, x_einheit: none, y_einheit: none, notation: "dec", precision: 1e-10) = {
    let (a, m) = (koeff.at(0), koeff.at(1))
    let a_str = format-number(a, notation: notation)
    let m_str = format-number(m, notation: notation)
    
    if x_einheit != none and y_einheit != none {
      let a_einheit = if type(y_einheit) == content and type(x_einheit) == content {
        $frac(#y_einheit, #x_einheit^#m_str)$
      } else if type(y_einheit) == content {
        $frac(#y_einheit, upright(#x_einheit)^#m_str)$
      } else if type(x_einheit) == content {
        $frac(upright(#y_einheit), #x_einheit^#m_str)$
      } else {
        $frac(upright(#y_einheit), upright(#x_einheit)^#m_str)$
      }
      
      $#y_name = #a_str #a_einheit dot #x_name^#m_str$
    } else {
      $y = #a_str dot x^#m_str$
    }
  }
  
  let result = regression(x_param, y_param, algorithmus, format-func,
    koeffizienten-namen: ("a", "m"), min-punkte: 2, notation: notation, precision: precision)
  result.insert("function", (x) => if x <= 0 { none } else { result.a * calc.pow(x, result.m) })
  result
}

#let polynom_regression(x_param, y_param, grad, notation: "dec", precision: 1e-10) = {
  let algorithmus(paare) = {
    let n_koeff = grad + 1
    assert(paare.len() >= n_koeff, message: "Benötige mindestens " + str(n_koeff) + " Datenpunkte")
    
    let pow_safe(x, i) = if i == 0 { 1 } else { calc.pow(x, i) }
    
    let x_pow_sums = (2 * grad + 1) * (0,)
    let b_vec = n_koeff * (0,)
    
    for p in paare {
      let x = p.at(0)
      for i in range(x_pow_sums.len()) { x_pow_sums.at(i) += pow_safe(x, i) }
      for i in range(n_koeff) { b_vec.at(i) += p.at(1) * pow_safe(x, i) }
    }
    
    let matrix = ()
    for i in range(n_koeff) {
      let row = (n_koeff + 1) * (0,)
      for j in range(n_koeff) { row.at(j) = x_pow_sums.at(i + j) }
      row.at(-1) = b_vec.at(i)
      matrix.push(row)
    }
    
    for i in range(n_koeff) {
      let max_row = i
      for k in range(i + 1, n_koeff) {
        if calc.abs(matrix.at(k).at(i)) > calc.abs(matrix.at(max_row).at(i)) { max_row = k }
      }
      (matrix.at(i), matrix.at(max_row)) = (matrix.at(max_row), matrix.at(i))
      
      let pivot = matrix.at(i).at(i)
      assert(pivot != 0, message: "Matrix singulär")
      
      for j in range(i, n_koeff + 1) { matrix.at(i).at(j) /= pivot }
      for k in range(n_koeff) {
        if i != k {
          let factor = matrix.at(k).at(i)
          for j in range(i, n_koeff + 1) { matrix.at(k).at(j) -= factor * matrix.at(i).at(j) }
        }
      }
    }
    
    matrix.map(row => row.last())
  }
  
  let format-func(koeff, x_name: none, y_name: none, x_einheit: none, y_einheit: none, notation: "dec", precision: 1e-10) = {
    if x_einheit != none and y_einheit != none {
      let terms = ()
      for i in range(koeff.len() - 1, -1, step: -1) {
        let einheit = if i == 0 { format-unit(y_einheit) } else { combine-units(y_einheit, x_einheit, x_potenz: i) }
        terms.push(format-equation-term(koeff.at(i), einheit, x_name, i, terms.len() == 0, notation, precision))
      }
      build-equation(y_name, terms.filter(t => not t.skip))
    } else {
      let terms = ()
      for i in range(koeff.len() - 1, -1, step: -1) {
        if calc.abs(koeff.at(i)) >= precision {
          let c_str = format-number(calc.abs(koeff.at(i)), notation: notation)
          let term = if i == 0 { $#c_str$ } else if i == 1 { $#c_str x$ } else { $#c_str x^#i$ }
          terms.push((term: term, is-negative: koeff.at(i) < 0, skip: false))
        }
      }
      if terms.len() == 0 { $y = 0$ } else { build-equation($y$, terms) }
    }
  }
  
  let koeff_namen = range(grad + 1).map(i => "c" + str(i))
  let result = regression(x_param, y_param, algorithmus, format-func,
    koeffizienten-namen: koeff_namen, min-punkte: grad + 1, notation: notation, precision: precision)
  result.insert("function", (x) => {
    let y = 0
    for i in range(grad + 1) {
      y += result.at("c" + str(i)) * if i == 0 { 1 } else { calc.pow(x, i) }
    }
    y
  })
  result
}
