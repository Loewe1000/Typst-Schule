// Interne Helfer für die runden Schaltzeichen.
#import "@preview/zap:0.4.0": component, interface, draw

// Gemeinsame Form der runden Schaltzeichen: Kreis mit Radius 0,45.
#let round-style = (
  radius: .45,
  padding: .15,
)

// Schaltzeichen aus Kreis und Buchstabe (A, V, M, G).
#let lettered-component(kind, letter, name, node, args) = {
  let sketch(ctx, position, style) = {
    interface((-style.radius, -style.radius), (style.radius, style.radius), io: position.len() < 2)
    draw.circle((0, 0), radius: style.radius, stroke: black + .8pt)
    draw.content((0, 0), text(12pt, letter))
  }
  component(kind, name, node, draw: sketch, style: round-style, ..args)
}
