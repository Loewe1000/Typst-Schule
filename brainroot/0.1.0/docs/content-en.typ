#import "@schule/schuldocs:0.2.0": show-example, show-module, show-code

= About this package

A mind map the way it grows on a whiteboard: one term in the middle, the
headings to its right and left, the examples behind them. `brainroot` sets
such a map from a nested list. Every branch gets a colour it passes down to
its leaves; the boxes are filled with a lighter shade of that colour, the
connections run as soft curves.

The package builds on *CeTZ*. Boxes are measured, so they follow the font of
the surrounding document.

= Quick start

#show-code[```typ
#import "@schule/brainroot:0.1.0": brainroot, branch
```]

The simplest input is a list: every item becomes a node, indented items its
children.

#show-example(
  rendered: {
    import "../lib.typ": *
    set text(size: 8pt)
    brainroot(title: [Forms of energy])[
      - Kinetic energy
        - Motion
        - Wind
      - Elastic energy
        - Stretching
      - Thermal energy
        - Fire
      - Potential energy
        - Gravity
        - Weight
    ]
  },
  source: ```typ
#brainroot(title: [Forms of energy])[
  - Kinetic energy
    - Motion
    - Wind
  - Elastic energy
    - Stretching
  - Thermal energy
    - Fire
  - Potential energy
    - Gravity
    - Weight
]
  ```,
  width: 100%,
)

To describe a branch in more detail, write it as `branch(label, ..children)`.
A child is then either content, a leaf, or another `branch(...)`. A list and
`branch` calls may stand side by side; without `title` the first argument is
the root.

= Sides and colours

Left alone, `brainroot` distributes the branches itself: the first ones go
right until the right side is about half as tall as all branches together,
the rest go left. `side: left` or `side: right` pins a branch, `color` gives
it its own colour instead of the next one from the palette.

#show-example(
  rendered: {
    import "../lib.typ": *
    set text(size: 8pt)
    brainroot([Photosynthesis], root-fill: green.lighten(50%), max-width: 3cm,
      branch([Light reaction], branch([Photolysis], [Water is split]), [ATP], side: right),
      branch([Dark reaction], [Calvin cycle], [Glucose], color: purple),
      branch([Requirements], [Light], [Water], [CO₂], side: left),
    )
  },
  source: ```typ
#brainroot([Photosynthesis], root-fill: green.lighten(50%), max-width: 3cm,
  branch([Light reaction], branch([Photolysis], [Water is split]), [ATP], side: right),
  branch([Dark reaction], [Calvin cycle], [Glucose], color: purple),
  branch([Requirements], [Light], [Water], [CO₂], side: left),
)
  ```,
  width: 100%,
)

= Layouts

`layout` decides how the branches sit around the root. `both` is the
two-sided map from above, `right` and `left` put everything on one side.
`down` and `up` set a tree from top to bottom or the other way round, like an
org chart; `radial` spreads the branches in a circle, the subtrees grow
horizontally outward.

#let map = [
  - Kinetic energy
    - Motion
    - Wind
  - Elastic energy
    - Stretching
  - Thermal energy
    - Fire
  - Potential energy
    - Gravity
    - Weight
]

#show-example(
  rendered: {
    import "../lib.typ": *
    set text(size: 8pt)
    brainroot(title: [Forms of energy], layout: "down", map)
  },
  source: ```typ
#brainroot(title: [Forms of energy], layout: "down", map)
  ```,
  width: 100%,
)

#show-example(
  rendered: {
    import "../lib.typ": *
    set text(size: 8pt)
    brainroot(title: [Forms of energy], layout: "radial", map,
      branch([Pressure]), branch([Radiation], [Light]))
  },
  source: ```typ
#brainroot(title: [Forms of energy], layout: "radial", map,
  branch([Pressure]), branch([Radiation], [Light]))
  ```,
  width: 100%,
)

With `radial` the first branch sits at `start` (default `60deg`), the others
follow clockwise. The radius begins at `root-gap` and grows until no two
subtrees overlap.

= Palettes

`palette` provides the colours of the branches and the root; the boxes get
the branch colour lightened by `tint`. Ten palettes are built in, all shown
with the same map:

#let palettes = (
  poster: [Bright and bold, like markers on a whiteboard. The default.],
  pastel: [Soft, muted tones.],
  grayscale: [Greys only, for black-and-white printing.],
  mono: [One blue in varying lightness.],
  plain: [One dark ink for everything, as if drawn with a fountain pen.],
  earth: [Earth tones: terracotta, ochre, olive, sand.],
  ocean: [Sea: turquoise, teal, sea green.],
  sunset: [Evening sky: red, orange, pink, violet.],
  forest: [Forest: green with a little brown.],
  neon: [Loud, saturated colours.],
)
#for (name, description) in palettes [
  == #raw(name)
  #description
  #show-example(
    rendered: {
      import "../lib.typ": *
      set text(size: 8pt)
      brainroot(title: [Forms of energy], palette: name, map)
    },
    source: raw(lang: "typ", "#brainroot(title: [Forms of energy], palette: \"" + name + "\", map)"),
    width: 100%,
  )
]

Your own colours go in as an array, `palette: (red, blue, green)`, or with a
root colour as a dictionary, `palette: (colors: (red, blue), root: black)`.
`root-fill` overrides the root colour in any case.

= Themes

A theme decides how boxes and edges look; the colours still come from the
palette. Ten are built in:

#for (name, description) in (
  soft: [Pastel boxes with rounded corners, soft S-curves. The whiteboard original.],
  outline: [White boxes with a coloured border, curves.],
  blocks: [Solid square boxes with white text, right angles: org-chart look.],
  lines: [No boxes: the text sits on its coloured line and the edges flow into it. The classic mind map.],
  sketch: [Thin border without fill, dashed straight lines.],
  bubbles: [Pills with pastel fill and straight connections.],
  hand: [Like `soft`, but hand-drawn: every line wobbles slightly.],
  scribble: [Scribbled: no fill, every line drawn twice.],
  marker: [Felt-tip: solid colour, wide straight strokes with a long wobble.],
  pencil: [Pencil: thin lines with a fine tremor, right angles.],
) [
  == #raw(name)
  #description
  #show-example(
    rendered: {
      import "../lib.typ": *
      set text(size: 8pt)
      brainroot(title: [Forms of energy], theme: name, map)
    },
    source: raw(lang: "typ", "#brainroot(title: [Forms of energy], theme: \"" + name + "\", map)"),
    width: 100%,
  )
]

== Hand-drawn

The themes `hand`, `scribble`, `marker` and `pencil` wobble every line after
the pattern of the TikZ decoration `sketch`: the path is walked in small
steps, every point is offset perpendicular to it by a slowly running sine
wave whose rhythm is set by a random walk. The randomness is reproducible,
the same map looks the same on every compile. A handwriting font such as
"Patrick Hand" or "Kalam" suits it; set it with `set text(font: ...)` or the
theme field `font`.

`wobble` sets the strength: `wobble: 0.5` wobbles half as much, `wobble: 2`
twice. The field `hand` controls the wobble in detail: `amplitude`
(excursion in pt), `wavelength` (in pt), `randomness` (irregularity, 1 is a
pure sine), `segment` (step in pt) and `passes` (how often each line is
drawn). Any theme can be made hand-drawn with it:

#show-example(
  rendered: {
    import "../lib.typ": *
    set text(size: 8pt, font: "Patrick Hand")
    brainroot(title: [Forms of energy],
      theme: (base: "blocks", hand: (amplitude: 1, wavelength: 60, randomness: 2, segment: 1.5, passes: 1)),
      map)
  },
  source: ```typ
#set text(font: "Patrick Hand")
#brainroot(title: [Forms of energy],
  theme: (base: "blocks", hand: (amplitude: 1, wavelength: 60, randomness: 2, segment: 1.5, passes: 1)),
  map)
  ```,
  width: 100%,
)

== Adapting a theme

A dictionary overrides individual fields; `base` picks the starting theme,
otherwise `soft`. Fields: `edge` (`"curve"`, `"elbow"`, `"straight"`),
`fill` (`"tint"`, `"solid"`, `"white"`, `"none"`), `stroke`, `radius`,
`underline`, `dash`, `font`, `hand` and `root` with overrides for the root
only. `layout` puts all branches on one side.

#show-example(
  rendered: {
    import "../lib.typ": *
    set text(size: 8pt)
    brainroot(title: [Forms of energy], layout: "right",
      theme: (base: "outline", edge: "elbow", radius: 0pt), map)
  },
  source: ```typ
#brainroot(title: [Forms of energy], layout: "right",
  theme: (base: "outline", edge: "elbow", radius: 0pt), map)
  ```,
  width: 100%,
)

= Appearance

- `ink` is the text colour. With `auto`, every box picks between `ink-dark`
  and `ink-light` by the luminance of its fill; `ink-threshold` sets the
  boundary. That keeps the text readable on dark palettes such as
  `grayscale` or `mono`.
- `scale` gives the font size per level relative to the surroundings,
  `bold-depth` the number of bold levels from the root.
- `thickness` gives the line width per level; the last value holds for all
  deeper levels.
- `tint` lightens the branch colour for the boxes; `tint-min` makes sure that
  even dark palette colours yield light boxes. `root-fill` colours the root.
- `level-gap` and `root-gap` are the distances along the direction of growth
  (parent to child, root to branch), `sibling-gap` and `branch-gap` those
  across (between siblings, between first-level branches).
- `max-width` limits the width of a label; longer text wraps. `none` never
  wraps.
- `inset` is the padding of the boxes.

= Functions

#show-module("../lib.typ")
