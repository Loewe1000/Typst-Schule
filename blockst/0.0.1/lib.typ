// =====================================================
// Scratch-Blöcke: Container-Funktion und Sprachmodule
// =====================================================

#import "scratch.typ": scratch-block-options

// Container-Funktion für Scratch-Blöcke
// Verwendung: #blockst[#import scratch.de: * ...]
#let blockst(
  theme: auto,
  scale: auto,
  body,
) = context {
  // Hole aktuelle Optionen aus dem State
  let current-opts = scratch-block-options.get()

  // Verwende State-Werte, wenn auto übergeben wurde
  let final-theme = if theme == auto {
    current-opts.at("theme", default: "normal")
  } else {
    theme
  }

  let final-scale = if scale == auto {
    current-opts.at("scale", default: 100%)
  } else {
    scale
  }

  // Rendere Body mit Skalierung
  block(above: 2em, std.scale(final-scale, reflow: true, body))
}

// Globale Einstellungen für Scratch-Blöcke
// Verwendung: #set-blockst(theme: "dark", scale: 80%)
#let set-blockst(
  theme: none,
  scale: none,
) = {
  scratch-block-options.update(old => {
    let new-opts = old
    if theme != none {
      new-opts.insert("theme", theme)
    }
    if scale != none {
      new-opts.insert("scale", scale)
    }
    new-opts
  })
}

// State für blockst-run Optionen
#let blockst-run-options = state("blockst-run-options", (:))

// Globale Einstellungen für blockst-run
// Verwendung: #set-blockst-run(zeige-gitter: 50, zeige-achsen: true)
#let set-blockst-run(
  breite: none,
  hoehe: none,
  start-x: none,
  start-y: none,
  start-angle: none,
  start-farbe: none,
  start-dicke: none,
  einheit: none,
  hintergrund: none,
  zeige-achsen: none,
  zeige-gitter: none,
  zeige-rahmen: none,
  zeige-cursor: none,
) = {
  blockst-run-options.update(old => {
    let new-opts = old
    if breite != none { new-opts.insert("breite", breite) }
    if hoehe != none { new-opts.insert("hoehe", hoehe) }
    if start-x != none { new-opts.insert("start-x", start-x) }
    if start-y != none { new-opts.insert("start-y", start-y) }
    if start-angle != none { new-opts.insert("start-angle", start-angle) }
    if start-farbe != none { new-opts.insert("start-farbe", start-farbe) }
    if start-dicke != none { new-opts.insert("start-dicke", start-dicke) }
    if einheit != none { new-opts.insert("einheit", einheit) }
    if hintergrund != none { new-opts.insert("hintergrund", hintergrund) }
    if zeige-achsen != none { new-opts.insert("zeige-achsen", zeige-achsen) }
    if zeige-gitter != none { new-opts.insert("zeige-gitter", zeige-gitter) }
    if zeige-rahmen != none { new-opts.insert("zeige-rahmen", zeige-rahmen) }
    if zeige-cursor != none { new-opts.insert("zeige-cursor", zeige-cursor) }
    new-opts
  })
}

// Sprachmodule als Sub-Module
#import "lang/de.typ" as de
#import "lang/en.typ" as en

// Scratch-Namespace mit Sprachmodulen
#let scratch = (
  de: de,
  en: en,
)

// =====================================================
// Ausführbare Scratch-Umgebung (Turtle Graphics)
// =====================================================

#import "executable.typ"

// Interpreter für ausführbare Blöcke
#let blockst-run(
  breite: auto,
  hoehe: auto,
  start-x: auto,
  start-y: auto,
  start-angle: auto,
  start-farbe: auto,
  start-dicke: auto,
  einheit: auto,
  hintergrund: auto,
  zeige-achsen: auto,
  zeige-gitter: auto,
  zeige-rahmen: auto,
  zeige-cursor: auto,
  ..befehle,
) = context {
  import "@preview/cetz:0.4.2": canvas, draw

  // Hole globale Optionen
  let opts = blockst-run-options.get()

  // Verwende Parameter falls angegeben, sonst globale Option, sonst Default
  let get-option(param, global-key, default) = {
    if param != auto { param } else { opts.at(global-key, default: default) }
  }

  let breite = get-option(breite, "breite", 480)
  let hoehe = get-option(hoehe, "hoehe", 360)
  let start-x = get-option(start-x, "start-x", 0)
  let start-y = get-option(start-y, "start-y", 0)
  let start-angle = get-option(start-angle, "start-angle", 90)
  let start-farbe = get-option(start-farbe, "start-farbe", rgb("#1A1AFF"))
  let start-dicke = get-option(start-dicke, "start-dicke", 0.5)
  let einheit = get-option(einheit, "einheit", 1)
  let hintergrund = get-option(hintergrund, "hintergrund", none)
  let zeige-achsen = get-option(zeige-achsen, "zeige-achsen", false)
  let zeige-gitter = get-option(zeige-gitter, "zeige-gitter", false)
  let zeige-rahmen = get-option(zeige-rahmen, "zeige-rahmen", true)
  let zeige-cursor = get-option(zeige-cursor, "zeige-cursor", true)

  // Sammle alle Befehle aus den Argumenten
  let commands-array = befehle.pos()

  // Wenn ein einziges Content-Element übergeben wurde, evaluiere es
  if commands-array.len() == 1 and type(commands-array.first()) == content {
    // Das ist ein Code-Block wie { import executable: *; stift-ein(); ... }
    // Wir können den Inhalt nicht direkt extrahieren, also müssen wir
    // die executable Funktionen so umbauen, dass sie ihren Output sammeln
    // ODER der User muss ein Array zurückgeben
    // Für jetzt: Fehler ausgeben wenn kein Array kam
    panic("blockst-run benötigt ein Array von Befehlen. Schreibe am Ende des Blocks das befehle-Array zurück, z.B.: `let befehle = (); befehle.push(stift-ein()); ...; befehle`")
  }

  // Flatten falls verschachtelte Arrays
  let flatten(arr) = {
    let result = ()
    for item in arr {
      if type(item) == array {
        result += flatten(item)
      } else {
        result.push(item)
      }
    }
    result
  }

  let commands = flatten(commands-array)

  // Hilfsfunktion: Evaluiere einen Wert (kann Dictionary oder direkter Wert sein)
  let eval-value(val, state, vars) = {
    if type(val) == dictionary and "type" in val {
      if val.type == "get" {
        // Hole State-Eigenschaft
        state.at(val.property, default: 0)
      } else if val.type == "get-var" {
        // Hole Variable
        vars.at(val.name, default: 0)
      } else if val.type == "add" {
        eval-value(val.a, state, vars) + eval-value(val.b, state, vars)
      } else if val.type == "subtract" {
        eval-value(val.a, state, vars) - eval-value(val.b, state, vars)
      } else if val.type == "multiply" {
        eval-value(val.a, state, vars) * eval-value(val.b, state, vars)
      } else if val.type == "divide" {
        let b = eval-value(val.b, state, vars)
        if b != 0 { eval-value(val.a, state, vars) / b } else { 0 }
      } else if val.type == "random" {
        // Vereinfachte Zufallszahl (deterministisch für Typst)
        let range-size = val.to - val.from + 1
        val.from + calc.rem(calc.abs(calc.sin(state.x * 123.456)), range-size)
      } else if val.type == "mod" {
        calc.rem(eval-value(val.a, state, vars), eval-value(val.b, state, vars))
      } else if val.type == "round" {
        calc.round(eval-value(val.value, state, vars))
      } else if val.type == "greater" {
        eval-value(val.a, state, vars) > eval-value(val.b, state, vars)
      } else if val.type == "less" {
        eval-value(val.a, state, vars) < eval-value(val.b, state, vars)
      } else if val.type == "equals" {
        eval-value(val.a, state, vars) == eval-value(val.b, state, vars)
      } else if val.type == "and" {
        eval-value(val.a, state, vars) and eval-value(val.b, state, vars)
      } else if val.type == "or" {
        eval-value(val.a, state, vars) or eval-value(val.b, state, vars)
      } else if val.type == "not" {
        not eval-value(val.a, state, vars)
      } else {
        0
      }
    } else {
      val
    }
  }

  // Wrapper mit Scratch-Style Rahmen
  box(
    clip: true,
    stroke: 1pt + rgb("#e0e0e0"),
    radius: 2pt,
    inset: 0pt,
    fill: hintergrund,
    canvas(length: einheit * 1cm / 100, {
      import draw: *

      // Hintergrund (falls gewünscht)
      if hintergrund != none {
        rect((-breite / 2, -hoehe / 2), (breite / 2, hoehe / 2), fill: hintergrund, stroke: none)
      }

      // Gitter
      if zeige-gitter != false {
        let grid-step = if type(zeige-gitter) == int { zeige-gitter } else { 10 }
        // Berechne Start-Position so dass (0,0) auf einem Gitterpunkt liegt
        // und das Gitter den gesamten sichtbaren Bereich abdeckt
        let start-x = calc.floor(-breite / 2 / grid-step) * grid-step
        let start-y = calc.floor(-hoehe / 2 / grid-step) * grid-step
        let end-x = calc.ceil(breite / 2 / grid-step) * grid-step
        let end-y = calc.ceil(hoehe / 2 / grid-step) * grid-step
        grid(
          (start-x, start-y),
          (end-x, end-y),
          step: grid-step,
          stroke: (paint: rgb("#d0d0d0"), thickness: 0.3pt),
          fill: none,
        )
      }

      // Achsen
      if zeige-achsen {
        line((-breite / 2, 0), (breite / 2, 0), stroke: (paint: gray, dash: "dashed", thickness: 0.5pt))
        line((0, -hoehe / 2), (0, hoehe / 2), stroke: (paint: gray, dash: "dashed", thickness: 0.5pt))
      }

      // Initialer State
      let state = (
        x: start-x,
        y: start-y,
        angle: start-angle,
        pen-down: false,
        color: start-farbe,
        size: start-dicke,
      )

      let vars = (:)

      // Sammle alle Zeichenbefehle
      let draw-commands = ()

      // Interpretiere jeden Befehl und sammle Zeichnungen
      for cmd in commands {
        if type(cmd) != dictionary or "type" not in cmd {
          continue
        }

        let cmd-type = cmd.type

        // BEWEGUNG
        if cmd-type == "move" {
          let steps = eval-value(cmd.steps, state, vars)
          let rad = state.angle * calc.pi / 180
          let dx = steps * calc.cos(rad)
          let dy = steps * calc.sin(rad)
          let new-x = state.x + dx
          let new-y = state.y + dy

          if state.pen-down {
            draw-commands.push((
              type: "line",
              from: (state.x, state.y),
              to: (new-x, new-y),
              stroke: (paint: state.color, thickness: state.size * 1pt),
            ))
          }

          state.x = new-x
          state.y = new-y
        } else if cmd-type == "turn-right" {
          state.angle -= eval-value(cmd.degrees, state, vars)
        } else if cmd-type == "turn-left" {
          state.angle += eval-value(cmd.degrees, state, vars)
        } else if cmd-type == "set-direction" {
          state.angle = eval-value(cmd.angle, state, vars)
        } else if cmd-type == "goto" {
          let new-x = eval-value(cmd.x, state, vars)
          let new-y = eval-value(cmd.y, state, vars)

          if state.pen-down {
            draw-commands.push((
              type: "line",
              from: (state.x, state.y),
              to: (new-x, new-y),
              stroke: (paint: state.color, thickness: state.size * 1pt),
            ))
          }

          state.x = new-x
          state.y = new-y
        } else if cmd-type == "set-x" {
          let new-x = eval-value(cmd.x, state, vars)

          if state.pen-down {
            draw-commands.push((
              type: "line",
              from: (state.x, state.y),
              to: (new-x, state.y),
              stroke: (paint: state.color, thickness: state.size * 1pt),
            ))
          }

          state.x = new-x
        } else if cmd-type == "set-y" {
          let new-y = eval-value(cmd.y, state, vars)

          if state.pen-down {
            draw-commands.push((
              type: "line",
              from: (state.x, state.y),
              to: (state.x, new-y),
              stroke: (paint: state.color, thickness: state.size * 1pt),
            ))
          }

          state.y = new-y
        } else if cmd-type == "change-x" {
          let dx = eval-value(cmd.dx, state, vars)
          let new-x = state.x + dx

          if state.pen-down {
            draw-commands.push((
              type: "line",
              from: (state.x, state.y),
              to: (new-x, state.y),
              stroke: (paint: state.color, thickness: state.size * 1pt),
            ))
          }

          state.x = new-x
        } else if cmd-type == "change-y" {
          let dy = eval-value(cmd.dy, state, vars)
          let new-y = state.y + dy

          if state.pen-down {
            draw-commands.push((
              type: "line",
              from: (state.x, state.y),
              to: (state.x, new-y),
              stroke: (paint: state.color, thickness: state.size * 1pt),
            ))
          }

          state.y = new-y

          // MALSTIFT
        } else if cmd-type == "clear" {
          // Canvas wird neu gezeichnet, kein explizites Clear nötig
        } else if cmd-type == "stamp" {
          // Zeichne einen kleinen Kreis an aktueller Position
          draw-commands.push((
            type: "circle",
            center: (state.x, state.y),
            radius: state.size * 2,
            fill: state.color,
          ))
        } else if cmd-type == "pen-down" {
          state.pen-down = true
        } else if cmd-type == "pen-up" {
          state.pen-down = false
        } else if cmd-type == "set-color" {
          state.color = cmd.color
        } else if cmd-type == "set-size" {
          state.size = eval-value(cmd.size, state, vars)
        } else if cmd-type == "change-size" {
          state.size += eval-value(cmd.delta, state, vars)

          // VARIABLEN
        } else if cmd-type == "set-var" {
          vars.insert(cmd.name, eval-value(cmd.value, state, vars))
        } else if cmd-type == "change-var" {
          let current = vars.at(cmd.name, default: 0)
          vars.insert(cmd.name, current + eval-value(cmd.delta, state, vars))

          // AUSGABE (für Debugging)
        } else if cmd-type == "say" or cmd-type == "think" {
          // Zeige Text an aktueller Position
          draw-commands.push((
            type: "text",
            position: (state.x, state.y + 5),
            text: cmd.message,
          ))
        }
      }

      // Kombiniere zusammenhängende Linien zu Pfaden
      let combined-paths = ()
      let current-path = ()
      let current-stroke = none

      for draw-cmd in draw-commands {
        if draw-cmd.type == "line" {
          // Prüfe ob diese Linie an den aktuellen Pfad anschließt
          let can-extend = current-path.len() > 0 and current-stroke == draw-cmd.stroke and current-path.last() == draw-cmd.from

          if can-extend {
            // Erweitere aktuellen Pfad
            current-path.push(draw-cmd.to)
          } else {
            // Speichere bisherigen Pfad
            if current-path.len() > 0 {
              combined-paths.push((points: current-path, stroke: current-stroke))
            }
            // Starte neuen Pfad
            current-path = (draw-cmd.from, draw-cmd.to)
            current-stroke = draw-cmd.stroke
          }
        } else {
          // Nicht-Linien-Befehl: speichere bisherigen Pfad
          if current-path.len() > 0 {
            combined-paths.push((points: current-path, stroke: current-stroke))
            current-path = ()
            current-stroke = none
          }
          combined-paths.push(draw-cmd)
        }
      }

      // Speichere letzten Pfad
      if current-path.len() > 0 {
        combined-paths.push((points: current-path, stroke: current-stroke))
      }

      // Zeichne alle kombinierten Pfade
      for path in combined-paths {
        if "points" in path {
          // Kombinierter Pfad
          line(..path.points, stroke: path.stroke)
        } else if path.type == "circle" {
          circle(path.center, radius: path.radius, fill: path.fill, stroke: none)
        } else if path.type == "text" {
          content(path.position, [#path.text], anchor: "south")
        }
      }

      // Zeige Turtle-Cursor an finaler Position
      if zeige-cursor {
        import "scratch.typ": icons

        on-layer(0, {
          // Pencil SVG zeigt nach oben, Scratch 90° ist rechts
          // Also: rotation = state.angle - 90
          let rotation = state.angle - 90

          // Skaliere Pencil auf ca. 25 Einheiten Höhe (für bessere Sichtbarkeit)
          let pencil-height = 25

          content(
            (state.x, state.y),
            angle: rotation * 1deg,
            image(icons.pencil, height: pencil-height * 1pt),
            anchor: "south-west",
          )
        })
      }
    }),
  )
}

// Scratch-Blöcke: Legacy-Import (für Abwärtskompatibilität)
#import "scratch.typ": *
