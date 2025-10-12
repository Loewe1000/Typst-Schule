#import "@schule/random:0.0.1": *
#import "@schule/physik:0.0.2": umrechnungseinheit

#let tasks(
  tasks: (),
  columns: auto,
  numbering: "a)",
  gutter: 1.25em,
  loesungen: (),
  ..args,
) = {
  tasks = if tasks.len() == 0 and args.pos() != none {
    let items = args.pos().at(0).children.filter(it => it.func() == enum.item).map(it => it.body)
    items
  } else { tasks }
  let row-amount = tasks.len()
  if columns != auto {
    row-amount = columns
  }
  import "@schule/aufgaben:0.1.2": loesung, teilaufgabe
  let tasks-show = ()
  for (key, task) in tasks.enumerate() {
    tasks-show.push(teilaufgabe()[
      #task
      #if loesungen.len() > key [
        #loesung[#loesungen.at(key)]
      ]
    ])
  }
  table(
    stroke: none,
    inset: 0mm,
    columns: (1fr,) * row-amount,
    column-gutter: gutter,
    row-gutter: gutter,
    ..tasks-show,
    ..args.named(),
  )
}

#let graphen(
  size: none,
  scale: 1,
  x: (-5, 5),
  y: (-5, 5),
  step: 1,
  x-step: none,
  y-step: none,
  x-label: [$x$],
  y-label: [$y$],
  grid: "both",
  x-grid: none,
  y-grid: none,
  line-width: 1.5pt,
  samples: 200,
  fills: (),
  datensätze: (),
  ..plots,
  annotations: {},
) = {
  import "@preview/cetz:0.4.2": *
  import "@preview/cetz-plot:0.1.3": *
  import "@preview/eqalc:0.1.3": math-to-func

  // Eigene Farbpalette mit 10 gut unterscheidbaren Farben für Plots
  let colors = (
    rgb("#1F77B4"), // Blau
    rgb("#D62728"), // Rot
    rgb("#2CA02C"), // Grün
    rgb("#FF7F0E"), // Orange
    rgb("#9467BD"), // Violett
    rgb("#8C564B"), // Braun
    rgb("#E377C2"), // Pink
    rgb("#7F7F7F"), // Grau
    rgb("#BCBD22"), // Olivgrün/Gelb
    rgb("#17BECF"), // Cyan
  )

  let plots = plots.pos()

  // Hilfsfunktion: Konvertiere content (Mathe) oder function zu function
  let to-func(term) = {
    if type(term) == function {
      term
    } else if type(term) == content {
      math-to-func(term)
    } else {
      term
    }
  }

  // Hilfsfunktion: Finde Schnittpunkt zweier Funktionen mit Bisection-Methode
  // Gibt none zurück wenn kein Schnittpunkt gefunden wurde
  let find-intersection(f, g, x-min, x-max, tolerance: 0.0001, max-iterations: 50) = {
    let diff(x) = f(x) - g(x)
    let a = x-min
    let b = x-max

    let fa = diff(a)
    let fb = diff(b)

    // Prüfe ob Vorzeichenwechsel existiert
    if fa * fb > 0 {
      return none // Kein Schnittpunkt in diesem Intervall
    }

    // Spezialfall: Einer der Randpunkte ist bereits der Schnittpunkt
    if calc.abs(fa) < tolerance {
      return a
    }
    if calc.abs(fb) < tolerance {
      return b
    }

    // Bisection-Algorithmus
    let iteration = 0
    while calc.abs(b - a) > tolerance and iteration < max-iterations {
      let mid = (a + b) / 2
      let fmid = diff(mid)

      if calc.abs(fmid) < tolerance {
        return mid
      }

      if fmid * fa < 0 {
        b = mid
        fb = fmid
      } else {
        a = mid
        fa = fmid
      }

      iteration += 1
    }

    return (a + b) / 2
  }

  // Hilfsfunktion: Finde alle Schnittpunkte durch Sampling
  let find-all-intersections(f, g, x-min, x-max, samples: 100) = {
    let intersections = ()
    let step = (x-max - x-min) / samples

    for i in range(samples) {
      let x1 = x-min + i * step
      let x2 = x1 + step

      // Versuche Schnittpunkt in diesem Segment zu finden
      let intersection = find-intersection(f, g, x1, x2, tolerance: 0.0001)

      if intersection != none {
        // Verhindere Duplikate (z.B. an Segment-Grenzen)
        let is-duplicate = intersections.any(x => calc.abs(x - intersection) < 0.001)
        if not is-duplicate {
          intersections.push(intersection)
        }
      }
    }

    return intersections
  }

  // Verarbeite die Plots in ein einheitliches Format
  let processed-plots = ()

  if plots.len() > 0 {
    // Array von Plot-Definitionen
    for (index, plot-def) in plots.enumerate() {
      let domain = (x.at(0), x.at(1)) // Standard-Domain
      let term = none
      let clr = colors.at(calc.rem(index, colors.len())) // Rotiere Farben
      let label = none // Label-Definition (position, content)

      if type(plot-def) == function or type(plot-def) == content {
        // Nur Funktion oder Mathe-Content übergeben
        term = to-func(plot-def)
      } else if type(plot-def) == array {
        // Tuple/Array: kann (term), (domain, term) oder (domain, term, color) sein
        // ODER (term, (label: ..., color: ...)) - Funktion + Dictionary mit Optionen
        if plot-def.len() == 1 {
          term = to-func(plot-def.at(0))
        } else if plot-def.len() == 2 {
          // Prüfe ob erstes Element eine Domain ist (Array) oder eine Funktion/Content
          if type(plot-def.at(0)) == array {
            domain = plot-def.at(0)
            term = to-func(plot-def.at(1))
          } else if (type(plot-def.at(0)) == function or type(plot-def.at(0)) == content) and type(plot-def.at(1)) == dictionary {
            // (func/content, (label: ..., color: ...))
            term = to-func(plot-def.at(0))
            let opts = plot-def.at(1)
            if "domain" in opts { domain = opts.domain }
            if "clr" in opts { clr = opts.clr }
            if "color" in opts { clr = opts.color }
            if "label" in opts { label = opts.label }
          } else {
            term = to-func(plot-def.at(0))
            clr = plot-def.at(1)
          }
        } else if plot-def.len() == 3 {
          // (domain, func, (options)) oder (domain, term, color)
          if type(plot-def.at(0)) == array and type(plot-def.at(2)) == dictionary {
            // (domain, func, (label: ..., color: ...))
            domain = plot-def.at(0)
            term = to-func(plot-def.at(1))
            let opts = plot-def.at(2)
            if "clr" in opts { clr = opts.clr }
            if "color" in opts { clr = opts.color }
            if "label" in opts { label = opts.label }
          } else {
            domain = plot-def.at(0)
            term = to-func(plot-def.at(1))
            clr = plot-def.at(2)
          }
        } else if plot-def.len() >= 4 {
          domain = plot-def.at(0)
          term = to-func(plot-def.at(1))
          clr = plot-def.at(2)
        }
      } else if type(plot-def) == dictionary {
        // Dictionary mit optionalen keys: domain, term, clr, label
        if "domain" in plot-def { domain = plot-def.domain }
        if "term" in plot-def { term = to-func(plot-def.term) }
        if "clr" in plot-def { clr = plot-def.clr }
        if "color" in plot-def { clr = plot-def.color }
        if "label" in plot-def { label = plot-def.label }
      }

      if term != none {
        processed-plots.push((domain: domain, term: term, clr: clr, label: label))
      }
    }
  }

  // Verarbeite die Fills in ein einheitliches Format
  let processed-fills = ()

  // Normalisiere fills: wenn es direkt eine Funktion oder Content ist, mache es zu einem Array
  // Erkenne auch einzelne Fill-Definitionen: wenn erstes Element ein Array (Domain) ist
  let fills-array = if type(fills) == function or type(fills) == content {
    // Direkt eine Funktion/Content ohne Array-Klammern: $f$ → mache zu Array
    ((fills,),)
  } else if type(fills) == array and fills.len() == 1 and (type(fills.at(0)) == function or type(fills.at(0)) == content) {
    // Ein einzelnes Element das eine Funktion ist: ($f$) → ist bereits richtig gewickelt
    (fills,)
  } else if type(fills) == array and fills.len() > 0 and type(fills.at(0)) == array {
    // Erstes Element ist Array (Domain) → könnte einzelner Fill sein
    // Prüfe ob es ein einzelner Fill ist: (domain, func1, func2) oder (domain, func1, func2, color)
    if fills.len() >= 3 and (type(fills.at(1)) == function or type(fills.at(1)) == content) and (type(fills.at(2)) == function or type(fills.at(2)) == content) {
      // Einzelner Fill: (domain, func1, func2, ...)
      (fills,)
    } else {
      fills
    }
  } else if type(fills) == array and fills.len() == 2 and (type(fills.at(0)) == function or type(fills.at(0)) == content) and (type(fills.at(1)) == function or type(fills.at(1)) == content) {
    // Zwei Funktionen direkt: ($f$, $g$) → einzelner Fill mit auto-domain
    (fills,)
  } else if (
    type(fills) == array
      and fills.len() == 3
      and fills.at(0) == "auto"
      and (type(fills.at(1)) == function or type(fills.at(1)) == content)
      and (type(fills.at(2)) == function or type(fills.at(2)) == content)
  ) {
    // ("auto", $f$, $g$) → einzelner Fill mit explizit auto-domain
    (fills,)
  } else {
    fills
  }

  if fills-array.len() > 0 {
    for (index, fill-def) in fills-array.enumerate() {
      let domain = (x.at(0), x.at(1)) // Standard-Domain
      let lower = none
      let upper = none
      let clr = colors.at(calc.rem(index, colors.len())).saturate(100%).lighten(60%).transparentize(50%) // Rotiere Farben, heller und transparent
      let auto-domain = false // Flag für automatische Domain-Berechnung

      if type(fill-def) == array {
        // Verschiedene Array-Formate:
        // (func) - eine Funktion, zweite ist x-Achse (x => 0)
        // (func1, func2) - zwei Funktionen → auto-domain!
        // ("auto", func1, func2) - explizit auto-domain
        // (domain, func1, func2) - mit Domain
        // (func1, func2, color) - mit Farbe
        // (domain, func1, func2, color) - vollständig

        if fill-def.len() == 1 {
          // Eine Funktion/Content, zweite ist x-Achse → auto-domain zwischen Nullstellen
          if type(fill-def.at(0)) == function or type(fill-def.at(0)) == content {
            lower = x => 0
            upper = to-func(fill-def.at(0))
            auto-domain = true // Automatisch zwischen Nullstellen füllen
          }
        } else if fill-def.len() == 2 {
          // Zwei Funktionen oder (func, color)
          if (type(fill-def.at(0)) == function or type(fill-def.at(0)) == content) and (type(fill-def.at(1)) == function or type(fill-def.at(1)) == content) {
            lower = to-func(fill-def.at(0))
            upper = to-func(fill-def.at(1))
            auto-domain = true // Automatische Domain-Erkennung
          } else if type(fill-def.at(0)) == function or type(fill-def.at(0)) == content {
            // (func, color)
            lower = x => 0
            upper = to-func(fill-def.at(0))
            clr = fill-def.at(1)
          }
        } else if fill-def.len() == 3 {
          // Prüfe ob erstes Element Domain ist (Array/String) oder Funktion/Content
          if type(fill-def.at(0)) == str and fill-def.at(0) == "auto" {
            // ("auto", func1, func2) - explizit auto
            lower = to-func(fill-def.at(1))
            upper = to-func(fill-def.at(2))
            auto-domain = true
          } else if type(fill-def.at(0)) == array {
            // (domain, func1, func2) oder (domain, func, color)
            domain = fill-def.at(0)
            if type(fill-def.at(2)) == function or type(fill-def.at(2)) == content {
              // (domain, func1, func2)
              lower = to-func(fill-def.at(1))
              upper = to-func(fill-def.at(2))
            } else {
              // (domain, func, color)
              lower = x => 0
              upper = to-func(fill-def.at(1))
              clr = fill-def.at(2)
            }
          } else if (type(fill-def.at(0)) == function or type(fill-def.at(0)) == content) and (type(fill-def.at(1)) == function or type(fill-def.at(1)) == content) {
            // (func1, func2, color)
            lower = to-func(fill-def.at(0))
            upper = to-func(fill-def.at(1))
            clr = fill-def.at(2)
            auto-domain = true // Automatische Domain-Erkennung
          }
        } else if fill-def.len() >= 4 {
          // (domain, func1, func2, color) oder ("auto", func1, func2, color)
          if type(fill-def.at(0)) == str and fill-def.at(0) == "auto" {
            lower = to-func(fill-def.at(1))
            upper = to-func(fill-def.at(2))
            clr = fill-def.at(3)
            auto-domain = true
          } else {
            domain = fill-def.at(0)
            lower = to-func(fill-def.at(1))
            upper = to-func(fill-def.at(2))
            clr = fill-def.at(3)
          }
        }
      } else if type(fill-def) == function or type(fill-def) == content {
        // Direkt eine Funktion/Content übergeben
        lower = x => 0
        upper = to-func(fill-def)
      } else if type(fill-def) == dictionary {
        // Dictionary mit optionalen keys: domain, lower, upper, clr, auto-domain
        if "domain" in fill-def {
          if type(fill-def.domain) == str and fill-def.domain == "auto" {
            auto-domain = true
          } else {
            domain = fill-def.domain
          }
        }
        if "lower" in fill-def { lower = to-func(fill-def.lower) }
        if "upper" in fill-def { upper = to-func(fill-def.upper) }
        if "func1" in fill-def { lower = to-func(fill-def.func1) }
        if "func2" in fill-def { upper = to-func(fill-def.func2) }
        if "func" in fill-def {
          upper = to-func(fill-def.func)
          if lower == none { lower = x => 0 }
        }
        if "clr" in fill-def { clr = fill-def.clr }
        if "color" in fill-def { clr = fill-def.color }
        if "auto-domain" in fill-def { auto-domain = fill-def.at("auto-domain") }
      }

      // Automatische Domain-Berechnung wenn gewünscht
      if auto-domain and lower != none and upper != none {
        let intersections = find-all-intersections(lower, upper, x.at(0), x.at(1), samples: samples)

        if intersections.len() >= 2 {
          // Nutze die äußersten Schnittpunkte (kleinster und größter x-Wert)
          let sorted = intersections.sorted()
          domain = (sorted.first(), sorted.last())
        } else if intersections.len() == 1 {
          // Nur ein Schnittpunkt gefunden - nutze x-Range als Fallback
          // Prüfe welche Seite zu füllen ist
          let mid-x = (x.at(0) + x.at(1)) / 2
          if mid-x < intersections.at(0) {
            domain = (x.at(0), intersections.at(0))
          } else {
            domain = (intersections.at(0), x.at(1))
          }
        }
        // Wenn keine Schnittpunkte: Behalte Standard-Domain
      }

      if lower != none and upper != none {
        processed-fills.push((domain: domain, lower: lower, upper: upper, clr: clr))
      }
    }
  }

  // Verarbeite die Datensätze (aus dem Physikpaket) in Punkte
  let processed-data = ()
  let auto-x-label = none
  let auto-y-label = none
  let auto-x-range = none
  let auto-y-range = none

  if datensätze != () {
    // Normalisiere Eingabe: kann Tupel (x, y) oder Array von Tupeln ((x1, y1), (x2, y2)) sein
    let ds-pairs = ()

    if type(datensätze) == array and datensätze.len() > 0 {
      // Prüfe ob es ein einzelnes Paar (x, y) ist oder mehrere Paare
      if type(datensätze.at(0)) == dictionary and "werte" in datensätze.at(0) {
        // Erstes Element ist ein Datensatz
        if datensätze.len() == 2 and type(datensätze.at(1)) == dictionary and "werte" in datensätze.at(1) {
          // Einzelnes Paar: (x, y)
          ds-pairs = ((datensätze.at(0), datensätze.at(1)),)
        } else if datensätze.len() > 2 {
          // Mehrere y-Datensätze mit gleichem x: (x, y1, y2, ...)
          let x-ds = datensätze.at(0)
          for i in range(1, datensätze.len()) {
            ds-pairs.push((x-ds, datensätze.at(i)))
          }
        }
      } else if type(datensätze.at(0)) == array and datensätze.at(0).len() == 2 {
        // Array von Paaren: ((x1, y1), (x2, y2))
        ds-pairs = datensätze
      }
    }

    if ds-pairs.len() > 0 {
      // Sammle alle x- und y-Einheiten für Validierung
      let x-einheiten = ()
      let y-einheiten = ()

      for (x-ds, y-ds) in ds-pairs {
        x-einheiten.push(x-ds.einheit)
        y-einheiten.push(y-ds.einheit)
      }

      // Validiere dass alle x-Einheiten gleich sind
      let first-x-einheit = x-einheiten.at(0)
      for xe in x-einheiten {
        if xe != first-x-einheit {
          panic("Alle x-Datensätze müssen die gleiche Einheit haben!")
        }
      }

      // Validiere dass alle y-Einheiten gleich sind
      let first-y-einheit = y-einheiten.at(0)
      for ye in y-einheiten {
        if ye != first-y-einheit {
          panic("Alle y-Datensätze müssen die gleiche Einheit haben!")
        }
      }

      // Setze automatische Achsenbeschriftungen
      let first-x-ds = ds-pairs.at(0).at(0)
      let first-y-ds = ds-pairs.at(0).at(1)

      import "@preview/fancy-units:0.1.1": unit
      auto-x-label = [#first-x-ds.name in #unit[#first-x-einheit]]
      auto-y-label = [#first-y-ds.name in #unit[#first-y-einheit]]

      // Berechne automatische Achsenbereiche
      let all-x-vals = ()
      let all-y-vals = ()

      // Konvertiere Datensätze zu Punkten
      for (i, pair) in ds-pairs.enumerate() {
        let x-ds = pair.at(0)
        let y-ds = pair.at(1)
        let points = ()

        // Ermittele Multiplikator aus der Einheit (z.B. mA → 1e-3)
        // umrechnungseinheit gibt (faktor, neue_einheit) zurück
        let (x-mult, _) = umrechnungseinheit(1, x-ds.einheit)
        let (y-mult, _) = umrechnungseinheit(1, y-ds.einheit)

        // Berücksichtige auch den prefix-Parameter falls vorhanden
        if "prefix" in x-ds and x-ds.prefix != "1" {
          let (prefix-mult, _) = umrechnungseinheit(1, x-ds.prefix)
          x-mult = x-mult / prefix-mult
        }
        if "prefix" in y-ds and y-ds.prefix != "1" {
          let (prefix-mult, _) = umrechnungseinheit(1, y-ds.prefix)
          y-mult = y-mult / prefix-mult
        }

        // Erstelle Punkte aus x- und y-Werten
        // Werte werden mit dem Multiplikator multipliziert um in Basiseinheiten zu kommen
        let min-len = calc.min(x-ds.werte.len(), y-ds.werte.len())
        for j in range(min-len) {
          let x-val = x-ds.werte.at(j)
          let y-val = y-ds.werte.at(j)

          // Überspringe none/content Werte
          if type(x-val) != content and x-val != none and type(y-val) != content and y-val != none {
            points.push((x-val * x-mult, y-val * y-mult))
            all-x-vals.push(x-val * x-mult)
            all-y-vals.push(y-val * y-mult)
          }
        }

        let clr = colors.at(calc.rem(i, colors.len())) // Rotiere Farben
        processed-data.push((points: points, clr: clr))
      }

      // Berechne Achsenbereiche mit etwas Padding (10%)
      if all-x-vals.len() > 0 {
        let x-min = calc.min(..all-x-vals)
        let x-max = calc.max(..all-x-vals)
        let x-range = x-max - x-min
        let x-padding = x-range * 0.1
        auto-x-range = (x-min - x-padding, x-max + x-padding)
      }

      if all-y-vals.len() > 0 {
        let y-min = calc.min(..all-y-vals)
        let y-max = calc.max(..all-y-vals)
        let y-range = y-max - y-min
        let y-padding = y-range * 0.1
        auto-y-range = (y-min - y-padding, y-max + y-padding)
      }
    }
  }

  // Überschreibe automatische Werte nur wenn nicht explizit gesetzt
  if auto-x-range != none and x == (-5, 5) {
    // (-5, 5) ist der Default
    x = auto-x-range
  }
  if auto-y-range != none and y == (-5, 5) {
    // (-5, 5) ist der Default
    y = auto-y-range
  }
  if auto-x-label != none and x-label == [$x$] {
    // [$x$] ist der Default
    x-label = auto-x-label
  }
  if auto-y-label != none and y-label == [$y$] {
    // [$y$] ist der Default
    y-label = auto-y-label
  }

  // Wenn Datensätze übergeben wurden und keine eigenen Steps definiert sind, setze auto
  let auto-x-tick-step = none
  let auto-y-tick-step = none
  if datensätze != () {
    if x-step == none and step == 1 {
      // Nur wenn keine eigenen Steps definiert
      auto-x-tick-step = auto
    }
    if y-step == none and step == 1 {
      // Nur wenn keine eigenen Steps definiert
      auto-y-tick-step = auto
    }
  }

  // Bestimme die effektive size (int/float für beide Achsen oder Array)
  let (size-x, size-y) = if size == none {
    // Verwende x- und y-Range wenn size nicht angegeben ist
    (calc.abs(x.at(1) - x.at(0)), calc.abs(y.at(1) - y.at(0)))
  } else if type(size) == array {
    (size.at(0), size.at(1))
  } else {
    (size, size)
  }

  // Bestimme den effektiven x-step (Fallback auf step, wenn x-step none ist)
  let effective-x-step = if auto-x-tick-step != none {
    auto-x-tick-step
  } else if x-step == none {
    step
  } else {
    x-step
  }

  // Bestimme den effektiven y-step (Fallback auf step, wenn y-step none ist)
  let effective-y-step = if auto-y-tick-step != none {
    auto-y-tick-step
  } else if y-step == none {
    step
  } else {
    y-step
  }

  // Bestimme das effektive x-grid (Fallback auf grid, wenn x-grid none ist)
  let effective-x-grid = if x-grid == none { grid } else { x-grid }

  // Bestimme das effektive y-grid (Fallback auf grid, wenn y-grid none ist)
  let effective-y-grid = if y-grid == none { grid } else { y-grid }

  // Bestimme x-major-step und x-minor-step
  let (x-major-step, x-minor-step) = if effective-x-step == auto {
    (auto, auto)
  } else if type(effective-x-step) == array {
    (effective-x-step.at(0), effective-x-step.at(1))
  } else {
    (effective-x-step, effective-x-step / 2)
  }

  // Bestimme y-major-step und y-minor-step
  let (y-major-step, y-minor-step) = if effective-y-step == auto {
    (auto, auto)
  } else if type(effective-y-step) == array {
    (effective-y-step.at(0), effective-y-step.at(1))
  } else {
    (effective-y-step, effective-y-step / 2)
  }

  canvas(length: scale * 1cm, {
    import draw: *
    set-style(
      axes: (
        tick: (offset: -50%, minor-offset: -25%, minor-length: 100%),
        grid: (
          stroke: (paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt),
          fill: none,
        ),
        minor-grid: (
          stroke: (paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt),
          fill: none,
        ),
        mark: (end: "straight"),
        x: (label: (anchor: "south-east", offset: -0.2)),
        y: (label: (anchor: "north-west", offset: -0.2)),
        overshoot: 8pt,
      ),
    )
    plot.plot(
      size: (size-x, size-y),
      name: "plot",
      axis-style: "school-book",
      x-grid: effective-x-grid,
      y-grid: effective-y-grid,
      x-tick-step: x-major-step,
      y-tick-step: y-major-step,
      x-minor-tick-step: x-minor-step,
      y-minor-tick-step: y-minor-step,
      x-label: x-label,
      y-label: y-label,
      x-min: x.at(0),
      x-max: x.at(1),
      y-min: y.at(0),
      y-max: y.at(1),
      {
        plot.add(
          style: (stroke: none),
          domain: (0, 5),
          x => x,
        )
        // Füge alle Fill-Betweens hinzu
        if processed-fills.len() > 0 {
          for f in processed-fills {
            plot.add-fill-between(
              domain: f.domain,
              style: (fill: f.clr, stroke: none),
              f.lower,
              f.upper,
            )
          }
        }
        // Füge alle Plots hinzu
        if processed-plots.len() > 0 {
          for p in processed-plots {
            plot.add(
              style: (stroke: p.clr + line-width),
              samples: samples,
              domain: p.domain,
              p.term,
            )
            if p.label != none and type(p.label) == array and p.label.len() >= 2 {
              let x-pos = p.label.at(0)
              let y-pos = (p.term)(x-pos)
              let label-content = p.label.at(1)

              // Optionale Position (tl/tr/bl/br) - Standard ist "tr" (top-right)
              let label-pos = if p.label.len() >= 3 { p.label.at(2) } else { "tr" }

              // Extrahiere Richtung: t/b für above/below, l/r für anchor
              let label-side = if label-pos.starts-with("t") { "above" } else { "below" }
              let anchor-side = if label-pos.ends-with("l") { "east" } else { "west" }
              
              // Bestimme Alignment basierend auf Position
              // tl: right + bottom, tr: left + bottom, bl: right + top, br: left + top
              let align-side = if label-pos == "tl" {
                right + bottom
              } else if label-pos == "tr" {
                left + bottom
              } else if label-pos == "bl" {
                right + top
              } else { // br
                left + top
              }

              // Berechne zwei Punkte auf der Kurve für die Tangentenrichtung
              let h = 0.1
              let pt1-x = x-pos - h
              let pt1-y = (p.term)(pt1-x)
              let pt2-x = x-pos + h
              let pt2-y = (p.term)(pt2-x)
              
              // Berechne die visuelle Steigung im Canvas-Raum
              // Transformiere Daten-Differenzen in Canvas-Differenzen
              let x-range = x.at(1) - x.at(0)
              let y-range = y.at(1) - y.at(0)
              
              // Delta im Daten-Raum
              let dx-data = pt2-x - pt1-x
              let dy-data = pt2-y - pt1-y
              
              // Delta im Canvas-Raum (berücksichtigt size und range)
              let dx-canvas = dx-data / x-range * size-x
              let dy-canvas = dy-data / y-range * size-y
              
              // Orthogonaler Vektor im Canvas-Raum: drehe um 90°
              // Wenn (dx, dy) die Tangente ist, dann ist (-dy, dx) orthogonal
              let ortho-dx-canvas = -dy-canvas
              let ortho-dy-canvas = dx-canvas
              
              // Transformiere zurück in Daten-Raum
              let ortho-dx-data = ortho-dx-canvas / size-x * x-range
              let ortho-dy-data = ortho-dy-canvas / size-y * y-range
              
              // Normalisiere auf eine sinnvolle Länge im Daten-Raum
              let ortho-length = calc.sqrt(ortho-dx-data * ortho-dx-data + ortho-dy-data * ortho-dy-data)
              let desired-length = x-range * 0.1 // 10% der x-range
              ortho-dx-data = ortho-dx-data / ortho-length * desired-length
              ortho-dy-data = ortho-dy-data / ortho-length * desired-length
              
              // Bei "below" kehre Richtung um
              if label-side == "below" {
                ortho-dx-data = -ortho-dx-data
                ortho-dy-data = -ortho-dy-data
              }
              
              // Zweiter Punkt der orthogonalen Linie im Daten-Raum
              let ortho-point = (rel: (ortho-dx-data * 100cm, ortho-dy-data * 100cm), to: (x-pos, y-pos))

              plot.annotate({
                content(
                  ortho-point,
                  box(width: 0mm, height: 0mm, align(align-side, context box(fill: white, width: measure(text(p.clr, label-content)).width, height: measure(text(p.clr, label-content)).height, text(p.clr, label-content)))),
                  padding: 0mm,
                )
              })
            }
          }
        }
        // Füge alle Datenpunkte hinzu
        if processed-data.len() > 0 {
          for d in processed-data {
            plot.add(
              d.points,
              style: (stroke: none),
              mark: "x",
              mark-style: (fill: d.clr, stroke: d.clr + 1.25pt),
            )
          }
        }
        if annotations != {} {
          plot.annotate({
            annotations
          })
        }
      },
    )
  })
}
