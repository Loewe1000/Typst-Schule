#import "@schule/random:0.0.1": *
#import "@schule/physik:0.0.2": umrechnungseinheit

#let teilaufgaben(
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

#let tasks = teilaufgaben

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

  show math.equation: it => {
    show regex("\d+\.\d+"): num => num.text.replace(".", ",")
    it
  }

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

  // Hilfsfunktion: Konvertiere Farbangabe (kann int oder color sein)
  let resolve-color(clr) = {
    if type(clr) == int {
      // Index in colors-Array (1-basiert für Benutzer, aber 0-basiert intern)
      colors.at(calc.rem(clr - 1, colors.len()))
    } else {
      clr
    }
  }

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
      let strk = (thickness: line-width, paint: clr) // Label-Definition (position, content)

      if type(plot-def) == function or type(plot-def) == content {
        // Einfachste Form: nur Funktion oder Mathe-Content übergeben
        // Beispiel: #graphen($x^2$)
        term = to-func(plot-def)
      } else if type(plot-def) == dictionary {
        // Dictionary-Form mit allen Optionen
        // Beispiel: #graphen((term: $x^2$, color: red, domain: (-2, 2), label: ...))
        if "domain" in plot-def { domain = plot-def.domain }
        if "term" in plot-def { term = to-func(plot-def.term) }
        if "stroke" in plot-def { strk = plot-def.stroke }
        if "clr" in plot-def { strk.paint = resolve-color(plot-def.clr) }
        if "color" in plot-def { strk.paint = resolve-color(plot-def.color) }
        if "label" in plot-def { label = plot-def.label }
      } else {
        panic("Plot muss entweder eine Funktion/Content ($x^2$) oder ein Dictionary (term: $x^2$, color: ...) sein")
      }

      if term != none {
        processed-plots.push((domain: domain, term: term, label: label, stroke: strk))
      }
    }
  }

  // Verarbeite die Fills in ein einheitlichesFormat
  let processed-fills = ()

  // Normalisiere fills zu einem Array von Fill-Definitionen
  let fills-array = if type(fills) == dictionary {
    // Einzelnes Fill-Dictionary: (between: ($f$, $g$), ...)
    (fills,)
  } else if type(fills) == array and fills.len() == 2 and (type(fills.at(0)) == function or type(fills.at(0)) == content) and (type(fills.at(1)) == function or type(fills.at(1)) == content) {
    // Shortcut: zwei Funktionen direkt: ($f$, $g$)
    // Wird zu einem Fill zwischen diesen beiden Funktionen mit auto-domain
    ((between: (fills.at(0), fills.at(1)), domain: "auto"),)
  } else if type(fills) == content or type(fills) == function {
    // Shortcut: eine einzelne Funktion -> Fläche zwischen Funktion und x-Achse
    ((term: fills, domain: "auto"),)
  } else if type(fills) == array {
    fills
  } else {
    ()
  }

  if fills-array.len() > 0 {
    for (index, fill-def) in fills-array.enumerate() {
      let domain = (x.at(0), x.at(1)) // Standard-Domain
      let lower = none
      let upper = none
      let clr = colors.at(calc.rem(index, colors.len())).saturate(100%).lighten(60%).transparentize(50%) // Rotiere Farben, heller und transparent
      let auto-domain = false // Flag für automatische Domain-Berechnung

      if type(fill-def) == dictionary {
        // Dictionary-Form (einzige erlaubte Form)
        // Beispiel: (between: ($f$, $g$), domain: "auto", color: red)
        // oder: (term: $x^2$, domain: "auto", color: red)
        if "domain" in fill-def {
          if type(fill-def.domain) == str and fill-def.domain == "auto" {
            auto-domain = true
          } else {
            domain = fill-def.domain
          }
        }

        // Verarbeite "between" - zwei Funktionen
        if "between" in fill-def {
          let between-funcs = fill-def.between
          if type(between-funcs) == array and between-funcs.len() == 2 {
            lower = to-func(between-funcs.at(0))
            upper = to-func(between-funcs.at(1))
          } else {
            panic("'between' muss ein Array mit zwei Funktionen sein: between: ($f$, $g$)")
          }
        }

        // Verarbeite "term" - eine Funktion (füllt zur x-Achse)
        if "term" in fill-def {
          lower = x => 0
          upper = to-func(fill-def.term)
        }

        if "clr" in fill-def { clr = resolve-color(fill-def.clr) }
        if "color" in fill-def { clr = resolve-color(fill-def.color) }
        if "auto-domain" in fill-def { auto-domain = fill-def.at("auto-domain") }
      } else {
        panic("Fill muss ein Dictionary sein: (between: ($f$, $g$), domain: ..., color: ...) oder (term: $f$, domain: ..., color: ...)")
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
    // Normalisiere Eingabe zu einem Array von Datensatz-Definitionen
    let ds-array = if type(datensätze) == dictionary {
      // Einzelnes Dictionary: (x: x-ds, y: y-ds, marker: ..., color: ...)
      (datensätze,)
    } else if type(datensätze) == array and datensätze.len() == 2 {
      // Prüfe ob es ein einfaches Tupel (x, y) ist
      let first = datensätze.at(0)
      let second = datensätze.at(1)

      // Fall 1: Einfache Zahlen-Arrays (x-array, y-array)
      if type(first) == array and type(second) == array and first.len() > 0 and type(first.at(0)) != dictionary and type(first.at(0)) != array {
        let x_ds = (name: $x$, einheit: none, werte: first, prefix: "1")
        let y_ds = (name: $y$, einheit: none, werte: second, prefix: "1")
        ((x: x_ds, y: y_ds),)
        // Fall 2: Physik-Datensätze (x-ds, y-ds)
      } else if type(first) == dictionary and "werte" in first and type(second) == dictionary and "werte" in second {
        ((x: first, y: second),)
      } else {
        datensätze
      }
    } else if type(datensätze) == array {
      datensätze
    } else {
      ()
    }

    let ds-pairs = ()

    if ds-array.len() > 0 {
      for (index, ds-def) in ds-array.enumerate() {
        let x-ds = none
        let y-ds = none
        let opts = none

        if type(ds-def) == dictionary {
          // Dictionary-Form mit allen Optionen
          // Beispiel: (x: x-ds, y: y-ds, marker: "o", color: red)
          if "x" in ds-def and "y" in ds-def {
            x-ds = ds-def.x
            y-ds = ds-def.y
            // Extrahiere Optionen aus dem Dictionary
            opts = (
              marker: if "marker" in ds-def { ds-def.marker } else { "x" },
              color: if "color" in ds-def { ds-def.color } else if "clr" in ds-def { ds-def.clr } else { index + 1 },
            )
          } else {
            panic("Datensatz-Dictionary muss 'x' und 'y' Keys haben")
          }
        } else {
          panic("Datensatz muss entweder ein Tupel (x, y) oder ein Dictionary (x: x, y: y, marker: ...) sein")
        }

        if x-ds != none and y-ds != none {
          ds-pairs.push(((x-ds, y-ds), opts))
        }
      }
    }

    if ds-pairs.len() > 0 {
      // Sammle alle x- und y-Einheiten für Validierung
      let x-einheiten = ()
      let y-einheiten = ()

      for item in ds-pairs {
        let pair = item.at(0)
        let x-ds = pair.at(0)
        let y-ds = pair.at(1)
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
      let first-pair = ds-pairs.at(0).at(0)
      let first-x-ds = first-pair.at(0)
      let first-y-ds = first-pair.at(1)

      import "@preview/fancy-units:0.1.1": unit

      // Erstelle Labels nur wenn Einheiten vorhanden sind
      if first-x-einheit != none and first-x-einheit != "" {
        auto-x-label = [#first-x-ds.name in #unit(per-mode: "fraction")[#first-x-einheit]]
      } else {
        auto-x-label = first-x-ds.name
      }

      if first-y-einheit != none and first-y-einheit != "" {
        auto-y-label = [#first-y-ds.name in #unit(per-mode: "fraction")[#first-y-einheit]]
      } else {
        auto-y-label = first-y-ds.name
      }

      // Berechne automatische Achsenbereiche
      let all-x-vals = ()
      let all-y-vals = ()

      // Konvertiere Datensätze zu Punkten
      for (i, item) in ds-pairs.enumerate() {
        let pair = item.at(0)
        let opts = item.at(1)
        let x-ds = pair.at(0)
        let y-ds = pair.at(1)
        let points = ()

        // Optionen extrahieren mit Standardwerten
        let clr = colors.at(calc.rem(i, colors.len())) // Standard-Farbe
        let marker = "x" // Standard-Marker

        if opts != none {
          if type(opts) == dictionary {
            if "color" in opts { clr = resolve-color(opts.color) }
            if "clr" in opts { clr = resolve-color(opts.clr) }
            if "marker" in opts { marker = opts.marker }
          }
        }

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

        processed-data.push((points: points, clr: clr, marker: marker))
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
  if auto-x-range != none and (x == (-5, 5) or x == auto) {
    // (-5, 5) ist der Default, oder explizit auto
    x = auto-x-range
  }
  if auto-y-range != none and (y == (-5, 5) or y == auto) {
    // (-5, 5) ist der Default, oder explizit auto
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
    // Wenn x oder y auto sind, verwende einen Default-Wert
    let x-size = if x == auto { 10 } else { calc.abs(x.at(1) - x.at(0)) }
    let y-size = if y == auto { 10 } else { calc.abs(y.at(1) - y.at(0)) }
    (x-size, y-size)
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
      x-min: if x == auto { auto } else { x.at(0) },
      x-max: if x == auto { auto } else { x.at(1) },
      y-min: if y == auto { auto } else { y.at(0) },
      y-max: if y == auto { auto } else { y.at(1) },
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
              samples: samples,
              style: (fill: f.clr, stroke: none),
              f.lower,
              f.upper,
            )
          }
        }
        if annotations != {} {
          plot.annotate({
            annotations
          })
        }
        // Füge alle Plots hinzu
        if processed-plots.len() > 0 {
          for p in processed-plots {
            plot.add(
              style: (stroke: p.stroke),
              samples: samples,
              domain: p.domain,
              p.term,
            )
            if p.label != none and type(p.label) == dictionary {
              // Label-Dictionary mit Keys: x, content, fill, position, size, color
              assert("x" in p.label, message: "Label benötigt 'x' Key")
              assert("content" in p.label, message: "Label benötigt 'content' Key")

              let x-pos = p.label.x
              let y-pos = (p.term)(x-pos)
              let label-content = p.label.content
              let label-pos = if "position" in p.label { p.label.position } else { "tr" }
              let label-fill = if "fill" in p.label { p.label.fill } else { white }
              let label-size = if "size" in p.label { p.label.size } else { none }
              let label-color = if "color" in p.label { p.label.color } else { p.stroke.paint }
              let label-padding = if "padding" in p.label { p.label.padding } else { 1mm }

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
              } else {
                // br
                left + top
              }

              let dx = if label-pos.ends-with("l") { -1 * label-padding } else { 1 * label-padding }
              let dy = if label-pos.starts-with("t") { -1 * label-padding } else { 1 * label-padding }

              // Zweiter Punkt der orthogonalen Linie im Daten-Raum
              let ortho-point = (x-pos, y-pos)

              plot.annotate({
                content(
                  ortho-point,
                  box(
                    width: 0mm,
                    height: 0mm,
                    align(align-side, context {
                      let text-content = if label-size != none {
                        text(size: label-size, label-color, label-content)
                      } else {
                        text(label-color, label-content)
                      }
                      move(dx: dx, dy: dy, box(
                        fill: label-fill,
                        inset: 1mm,
                        width: measure(text-content).width + 2mm,
                        height: measure(text-content).height + 2mm,
                        text-content,
                      ))
                    }),
                  ),
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
              mark: d.marker,
              mark-style: (fill: d.clr, stroke: d.clr + 1.25pt),
            )
          }
        }
      },
    )
  })
}

// Steckbriefaufgaben: Bestimme Polynomfunktion aus gegebenen Bedingungen
#let steckbrief(..bedingungen, notation: "dec", precision: 1e-10) = {
  import "@preview/zero:0.5.0": num as znum
  
  // Hilfsfunktion: Formatiere Zahl für Ausgabe
  let format-number(value, digits: 2) = {
    if notation == "sci" {
      let exp = if value == 0 { 0 } else { calc.floor(calc.log(calc.abs(value), base: 10)) }
      let mantissa = value / calc.pow(10, exp)
      
      let clean-mantissa = if calc.round(mantissa, digits: 10) == calc.round(mantissa) {
        int(calc.round(mantissa))
      } else {
        mantissa
      }
      let mantissa_formatted = znum(str(clean-mantissa), decimal-separator:",", digits: digits)
      
      if exp == 0 {
        mantissa_formatted
      } else if exp == 1 {
        $#mantissa_formatted dot 10$
      } else {
        $#mantissa_formatted dot 10^#exp$
      }
    } else {
      if calc.round(value, digits: 10) == calc.round(value) {
        str(int(calc.round(value)))
      } else {
        znum(value, decimal-separator:",", digits: digits)
      }
    }
  }
  
  // Parse eine einzelne Bedingung wie "f(2)=3" oder "f'(-1)=0"
  let parse-bedingung(bedingung-str) = {
    // Entferne Leerzeichen
    let s = bedingung-str.replace(" ", "")
    
    // Bestimme Ableitungsgrad (Anzahl der Apostrophe ')
    let ableitung = 0
    for char in s.clusters() {
      if char == "'" {
        ableitung += 1
      }
    }
    
    // Extrahiere x-Wert zwischen Klammern
    let x-match = s.match(regex("\(([^)]+)\)"))
    assert(x-match != none, message: "Ungültiges Format: " + bedingung-str)
    let x-str = x-match.captures.at(0)
    
    // Parse x-Wert (kann negativ sein oder Bruch)
    let x-val = if x-str.contains("/") {
      let parts = x-str.split("/")
      float(parts.at(0)) / float(parts.at(1))
    } else {
      float(x-str)
    }
    
    // Extrahiere y-Wert nach =
    let y-match = s.match(regex("=(.+)$"))
    assert(y-match != none, message: "Kein '=' gefunden in: " + bedingung-str)
    let y-str = y-match.captures.at(0)
    
    // Parse y-Wert (kann negativ sein oder Bruch)
    let y-val = if y-str.contains("/") {
      let parts = y-str.split("/")
      float(parts.at(0)) / float(parts.at(1))
    } else {
      float(y-str)
    }
    
    (x: x-val, y: y-val, ableitung: ableitung)
  }
  
  // Parse alle Bedingungen
  let bedingungen-array = bedingungen.pos()
  let parsed = bedingungen-array.map(parse-bedingung)
  
  // Bestimme Grad des Polynoms (Anzahl Bedingungen - 1)
  let grad = parsed.len() - 1
  let n = grad + 1 // Anzahl Koeffizienten
  
  // Erstelle Gleichungssystem: Matrix A und Vektor b
  // Für f(x) = a·x^n + b·x^(n-1) + ... + d
  // Koeffizienten in umgekehrter Reihenfolge: [d, c, b, a] für f(x) = ax³ + bx² + cx + d
  
  let matrix = ()
  
  for bedingung in parsed {
    let row = ()
    let x = bedingung.x
    let abl = bedingung.ableitung
    
    // Erstelle Zeile für diese Bedingung
    // Für f(x): [x^0, x^1, x^2, ..., x^n]
    // Für f'(x): [0, 1, 2x, 3x^2, ..., n·x^(n-1)]
    // Für f''(x): [0, 0, 2, 6x, ..., n(n-1)·x^(n-2)]
    
    for i in range(n) {
      let koeff = 1
      let exponent = i
      
      // Berechne Koeffizient für Ableitung
      for d in range(abl) {
        if exponent == 0 {
          koeff = 0
          break
        }
        koeff = koeff * exponent
        exponent = exponent - 1
      }
      
      // Berechne x^exponent
      let wert = if koeff == 0 {
        0
      } else if exponent == 0 {
        koeff
      } else {
        koeff * calc.pow(x, exponent)
      }
      
      row.push(wert)
    }
    
    // Füge y-Wert als letzte Spalte hinzu
    row.push(bedingung.y)
    matrix.push(row)
  }
  
  // Löse Gleichungssystem mit Gauß-Elimination
  // Vorwärtselimination
  for i in range(n) {
    // Finde Pivot (größtes Element in Spalte i)
    let max-row = i
    for k in range(i + 1, n) {
      if calc.abs(matrix.at(k).at(i)) > calc.abs(matrix.at(max-row).at(i)) {
        max-row = k
      }
    }
    
    // Tausche Zeilen
    if max-row != i {
      (matrix.at(i), matrix.at(max-row)) = (matrix.at(max-row), matrix.at(i))
    }
    
    let pivot = matrix.at(i).at(i)
    if calc.abs(pivot) <= 1e-10 {
      // Matrix ist singulär - keine eindeutige Lösung
      return (
        error: "Matrix ist singulär - keine eindeutige Lösung. Bitte überprüfe die Bedingungen.",
        math: none,
        function: none,
        gleichungssystem: none,
        grad: grad,
        bedingungen: bedingungen-array,
      )
    }
    
    // Normalisiere Pivot-Zeile
    for j in range(i, n + 1) {
      matrix.at(i).at(j) = matrix.at(i).at(j) / pivot
    }
    
    // Eliminiere Spalte i in allen anderen Zeilen
    for k in range(n) {
      if k != i {
        let factor = matrix.at(k).at(i)
        for j in range(i, n + 1) {
          matrix.at(k).at(j) = matrix.at(k).at(j) - factor * matrix.at(i).at(j)
        }
      }
    }
  }
  
  // Extrahiere Lösung (letzte Spalte)
  let koeffizienten = matrix.map(row => row.last())
  
  // Erstelle Gleichungssystem für Ausgabe
  let gleichungssystem = ()
  for (idx, bedingung) in parsed.enumerate() {
    let x = bedingung.x
    let abl = bedingung.ableitung
    let terms = ()
    
    for i in range(grad, -1, step: -1) {
      let koeff-idx = i
      let exponent = i
      
      // Berechne Koeffizient für Ableitung
      let koeff-faktor = 1
      for d in range(abl) {
        if exponent == 0 {
          koeff-faktor = 0
          break
        }
        koeff-faktor = koeff-faktor * exponent
        exponent = exponent - 1
      }
      
      if koeff-faktor != 0 {
        // Berechne x^exponent
        let x-wert = if exponent == 0 {
          koeff-faktor
        } else {
          koeff-faktor * calc.pow(x, exponent)
        }
        
        // Formatiere Term
        let var-name = ("a", "b", "c", "d", "e", "f", "g", "h").at(grad - i)
        
        if calc.abs(x-wert - 1) < 0.01 {
          terms.push($#var-name$)
        } else if calc.abs(x-wert + 1) < 0.01 {
          terms.push($-#var-name$)
        } else {
          let x-str = format-number(x-wert)
          terms.push($#x-str dot #var-name$)
        }
      }
    }
    
    let y-str = format-number(bedingung.y)
    let equation = if terms.len() == 0 {
      $0 = #y-str$
    } else {
      terms.join($" " + " "$) + $ = #y-str$
    }
    
    gleichungssystem.push(equation)
  }
  
  // Erstelle Funktionsgleichung
  let format-polynom(koeff, digits: 2) = {
    let terms = ()
    for i in range(grad, -1, step: -1) {
      let k = koeff.at(i)
      if calc.abs(k) >= precision {
        let abs-k = calc.abs(k)
        let k-ist-eins = calc.abs(abs-k - 1) < 0.01
        
        let term = if i == 0 {
          // Konstanter Term
          let k-str = format-number(abs-k, digits: digits)
          $#k-str$
        } else if i == 1 {
          // x^1 Term
          if k-ist-eins {
            $x$
          } else {
            let k-str = format-number(abs-k, digits: digits)
            $#k-str dot x$
          }
        } else {
          // x^i Term (i >= 2)
          if k-ist-eins {
            $x^#i$
          } else {
            let k-str = format-number(abs-k, digits: digits)
            $#k-str dot x^#i$
          }
        }
        
        terms.push((term: term, is-negative: k < 0))
      }
    }
    
    if terms.len() == 0 {
      $f(x) = 0$
    } else {
      let eq = if terms.first().is-negative {
        $f(x) = -#terms.first().term$
      } else {
        $f(x) = #terms.first().term$
      }
      
      for term in terms.slice(1) {
        eq = if term.is-negative {
          $#eq - #term.term$
        } else {
          $#eq + #term.term$
        }
      }
      eq
    }
  }
  
  // Erstelle Funktion
  let f(x) = {
    let y = 0
    for i in range(n) {
      y = y + koeffizienten.at(i) * if i == 0 { 1 } else { calc.pow(x, i) }
    }
    y
  }
  
  // Erstelle Rückgabewert ähnlich wie bei Regressionen
  let result = (
    math: format-polynom(koeffizienten),
    math-digits: (digits) => format-polynom(koeffizienten, digits: digits),
    function: f,
    gleichungssystem: gleichungssystem,
  )
  
  // Füge Koeffizienten mit Namen hinzu
  let koeff-namen = ("a", "b", "c", "d", "e", "f", "g", "h")
  for i in range(grad + 1) {
    let name = koeff-namen.at(i)
    result.insert(name, koeffizienten.at(grad - i))
  }
  
  return result
}
