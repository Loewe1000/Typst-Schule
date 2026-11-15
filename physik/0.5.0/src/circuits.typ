// Schaltkreis und eigene Schaltzeichen auf der Grundlage von zap.
#import "@preview/zap:0.4.0": circuit, component, interface, draw
#import "internal/check.typ": check-named, check-type, check-value, nearest
#import "components.typ": round-style, lettered-component

/// Setzt eine Schaltskizze. `schaltkreis` ist `circuit` aus dem Paket zap:
/// im Rumpf stehen die Schaltzeichen dieses Pakets (`source`, `lamp`,
/// `ammeter` …) und alles, was zap selbst mitbringt (`zap.wire`,
/// `zap.resistor` …). Für die zap-Namen importiert das Dokument zap selbst.
///
/// ```typ
/// #import "@preview/zap:0.4.0"
/// #schaltkreis({
///   source("q", (0, 0), (0, 3))
///   lamp("l", (3, 0), (3, 3))
///   zap.wire("q.out", "l.out")
///   zap.wire("q.in", "l.in")
/// })
/// ```
///
/// -> content
#let schaltkreis = circuit

/// Zeichnet eine Spannungsquelle in einen `schaltkreis`.
///
/// - name (str): Name des Bauteils; unter ihm sind die Anschlüsse erreichbar (`"q.in"`, `"q.out"`)
/// - node (any): erster Knoten (zap-Koordinate); ein zweiter folgt als weiteres Positionsargument
/// - current (str): Stromart: `"direct"` (Gleichstrom) oder `"alternating"` (Wechselstrom)
/// - kind (str): Darstellung bei Gleichstrom: `"symbol"` (zwei Kreise mit Plus und Minus) oder `"bars"` (langer und kurzer Strich)
/// - flipped (bool): Polarität vertauschen
/// - flipped-labels (bool): Plus und Minus auf die andere Seite des Symbols setzen
/// - ..args (arguments): weitere Knoten und zap-Argumente (`label`, `scale`, `stroke` …), gehen unverändert an `zap.component`; alte Namen und Tippfehler der eigenen Parameter brechen vorher ab
/// -> content
#let source(
  name,
  node,
  current: "direct",
  kind: "symbol",
  flipped: false,
  flipped-labels: false,
  ..args,
) = {
  // Alte Namen abfangen; alles andere geht an zap.
  let old-names = (variant: "kind", "flipped-side": "flipped-labels")
  let given = args.named()
  let old = (:)
  // Namen, die zap.component selbst kennt; sie sind nie ein Tippfehler.
  let zap-names = ("draw", "label", "i", "f", "u", "n", "position", "scale", "rotate", "debug", "style", "stroke", "fill", "wires", "radius", "width", "height", "padding")
  let own-names = ("current", "kind", "flipped", "flipped-labels")
  for key in given.keys() {
    if key in old-names {
      old.insert(key, given.at(key))
    } else if key not in zap-names and nearest(key, own-names + old-names.keys()) != none {
      // Tippfehler eines eigenen Namens: nicht an zap durchreichen
      old.insert(key, given.at(key))
    }
  }
  if kind != "symbol" { old.insert("kind", kind) }
  if flipped-labels != false { old.insert("flipped-labels", flipped-labels) }
  check-named("physik", "source", old, renamed: old-names, allowed: own-names)
  check-value("physik", "source", "current", current, ("direct", "alternating"), renamed: (dc: "direct", ac: "alternating"))
  check-value("physik", "source", "kind", kind, ("symbol", "bars"), renamed: (lines: "bars"))
  check-type("physik", "source", "flipped", flipped, bool)
  check-type("physik", "source", "flipped-labels", flipped-labels, bool)

  let style = (
    width: 1.0,
    height: 0.4,
    radius: 0.18,
  )

  let sketch(ctx, position, style) = {
    if current == "direct" and kind == "bars" {
      interface((-style.width * 0.1, -style.height), (style.width * 0.1, style.height), io: position.len() < 2)
      // langer und kurzer Strich
      let long-height = 0.45
      let short-height = 0.25
      let spacing = 0.1
      let direction = if flipped { -1 } else { 1 }

      // langer Strich (Pluspol)
      draw.line(
        (direction * spacing, -long-height),
        (direction * spacing, long-height),
        stroke: (thickness: .8pt, paint: black),
      )

      // kurzer Strich (Minuspol)
      draw.line(
        (direction * -spacing, -short-height),
        (direction * -spacing, short-height),
        stroke: (thickness: .8pt, paint: black),
      )
    } else {
      interface((-style.width * 0.4 - style.radius, -style.height / 2), (style.width * 0.4 + style.radius, style.height / 2), io: position.len() < 2)
      // zwei Anschlusskreise
      draw.circle((-style.width * 0.4, 0), radius: style.radius, ..style)
      draw.circle((style.width * 0.4, 0), radius: style.radius, ..style)

      if current == "direct" {
        // Gleichstrom: Plus und Minus
        let direction = if flipped { -1 } else { 1 }
        let height = if flipped-labels { -style.height } else { style.height }
        draw.content((direction * style.width * 0.4, height), text(top-edge: "bounds", bottom-edge: "bounds", 12pt, $+$))
        draw.content((direction * -style.width * 0.4, height), text(top-edge: "x-height", bottom-edge: "bounds", 12pt, $-$))
      } else {
        // Wechselstrom: Tilde
        draw.content((0, 0), text(12pt, $tilde$))
      }
    }
  }

  let rest = arguments(..args.pos(), ..given.pairs().filter(((key, value)) => key not in old-names).to-dict())
  component("source", name, node, draw: sketch, style: style, ..rest)
}

/// Zeichnet ein Multimeter (Kreis mit Zeiger) in einen `schaltkreis`.
///
/// - name (str): Name des Bauteils
/// - node (any): erster Knoten (zap-Koordinate)
/// - ..args (arguments): weitere Knoten und zap-Argumente, gehen unverändert an `zap.component`
/// -> content
#let multimeter(name, node, ..args) = {
  let sketch(ctx, position, style) = {
    interface((-style.radius, -style.radius), (style.radius, style.radius), io: position.len() < 2)

    draw.circle((0, 0), radius: style.radius, stroke: black + .8pt)
    draw.content((0, 0), schaltkreis({ draw.line((45deg, -0.7 * style.radius), (45deg + 180deg, -0.8 * style.radius), mark: (end: (scale: 0.7, symbol: ">", fill: black, stroke: .8pt))) }))
  }

  component("multimeter", name, node, draw: sketch, style: round-style, ..args)
}

/// Zeichnet eine Glühlampe (Kreis mit Kreuz) in einen `schaltkreis`.
///
/// - name (str): Name des Bauteils
/// - node (any): erster Knoten (zap-Koordinate)
/// - ..args (arguments): weitere Knoten und zap-Argumente, gehen unverändert an `zap.component`
/// -> content
#let lamp(name, node, ..args) = {
  let sketch(ctx, position, style) = {
    interface((-style.radius, -style.radius), (style.radius, style.radius), io: position.len() < 2)

    draw.circle((0, 0), radius: style.radius, stroke: black + .8pt)

    // Kreuz aus zwei Diagonalen
    draw.line((radius: style.radius, angle: 45deg), (radius: -style.radius, angle: 45deg), stroke: black + .8pt)
    draw.line((radius: style.radius, angle: 135deg), (radius: -style.radius, angle: 135deg), stroke: black + .8pt)
  }

  component("lamp", name, node, draw: sketch, style: round-style, ..args)
}

/// Zeichnet ein Amperemeter (Kreis mit A) in einen `schaltkreis`.
///
/// - name (str): Name des Bauteils
/// - node (any): erster Knoten (zap-Koordinate)
/// - ..args (arguments): weitere Knoten und zap-Argumente, gehen unverändert an `zap.component`
/// -> content
#let ammeter(name, node, ..args) = lettered-component("amperemeter", [A], name, node, args)

/// Zeichnet ein Voltmeter (Kreis mit V) in einen `schaltkreis`.
///
/// - name (str): Name des Bauteils
/// - node (any): erster Knoten (zap-Koordinate)
/// - ..args (arguments): weitere Knoten und zap-Argumente, gehen unverändert an `zap.component`
/// -> content
#let voltmeter(name, node, ..args) = lettered-component("voltmeter", [V], name, node, args)

/// Zeichnet einen Motor (Kreis mit M) in einen `schaltkreis`.
///
/// - name (str): Name des Bauteils
/// - node (any): erster Knoten (zap-Koordinate)
/// - ..args (arguments): weitere Knoten und zap-Argumente, gehen unverändert an `zap.component`
/// -> content
#let motor(name, node, ..args) = lettered-component("motor", [M], name, node, args)

/// Zeichnet einen Generator (Kreis mit G) in einen `schaltkreis`.
///
/// - name (str): Name des Bauteils
/// - node (any): erster Knoten (zap-Koordinate)
/// - ..args (arguments): weitere Knoten und zap-Argumente, gehen unverändert an `zap.component`
/// -> content
#let generator(name, node, ..args) = lettered-component("generator", [G], name, node, args)
