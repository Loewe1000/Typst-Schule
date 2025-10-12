#import "@preview/zap:0.4.0" as zap

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
        stroke: (thickness: .8pt, paint: black),
      )

      // Kurzer Strich (negativ)
      zap.draw.line(
        (flipped-multiplier * -line-spacing, -short-line-height),
        (flipped-multiplier * -line-spacing, short-line-height),
        stroke: (thickness: .8pt, paint: black),
      )
    } else {
      zap.interface((-style.width * 0.4 - style.radius, -style.height / 2), (style.width * 0.4 + style.radius, style.height / 2), io: position.len() < 2)
      // Kreise für symbol-style und AC
      zap.draw.circle((-style.width * 0.4, 0), radius: style.radius, ..style)
      zap.draw.circle((style.width * 0.4, 0), radius: style.radius, ..style)

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

    zap.draw.circle((0, 0), radius: style.radius, stroke: black + .8pt)
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
    zap.draw.circle((0, 0), radius: style.radius, stroke: black + .8pt)

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
    zap.draw.circle((0, 0), radius: style.radius, stroke: black + .8pt)

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
    zap.draw.circle((0, 0), radius: style.radius, stroke: black + .8pt)

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
    zap.draw.circle((0, 0), radius: style.radius, stroke: black + .8pt)

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
    zap.draw.circle((0, 0), radius: style.radius, stroke: black + .8pt)

    // "G" in der Mitte
    zap.draw.content((0, 0), text(12pt, [G]))
  }

  // Componant call
  zap.component("generator", name, node, draw: draw, style: style, ..params)
}