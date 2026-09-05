// brainroot -- two-sided mind maps with coloured branches.
//
// The root sits in the middle, the branches spread to the right and left,
// and every branch carries its own colour down to its leaves. The layout is
// a simple "tidy tree": every subtree gets as much room as its children
// need and is centred on its parent.

#import "@preview/cetz:0.4.2"

/// A branch of the mind map.
///
/// - label: label of the node (content or string).
/// - ..kids: children; either further `branch(...)` calls or plain content,
///   which then counts as a leaf without children of its own.
/// - color: colour of the branch. Only read on the first level; below it
///   every node inherits the colour of its parent. `none` takes the next
///   colour from the palette.
/// - side: `left`, `right` or `auto`. Only read on the first level.
#let branch(label, ..kids, color: none, side: auto) = (
  brainroot-node: true,
  label: label,
  kids: kids.pos(),
  color: color,
  side: side,
)

// Anything that is not a branch becomes a leaf.
#let _norm(k) = if type(k) == dictionary and k.at("brainroot-node", default: false) { k } else { branch(k) }

// --- Lists as input --------------------------------------------------------
//
// In markup a list is a sequence of `list.item` elements; only when laid
// out do they become a `list`. Both forms are understood here.

#let _is-item(c) = type(c) == content and c.func() in (list.item, enum.item)
#let _is-list(c) = type(c) == content and c.func() in (list, enum)
#let _is-blank(c) = type(c) == content and c.func() in (parbreak, [ ].func())

// Splits the body of a list item into label and nested items: whatever is
// not a list item stays label; every nested item becomes a child.
#let _from-item(item) = {
  let body = item.body
  let parts = if body.func() == [].func() { body.children } else { (body,) }
  let label = ()
  let kids = ()
  for p in parts {
    if _is-item(p) {
      kids.push(_from-item(p))
    } else if _is-list(p) {
      kids += p.children.map(_from-item)
    } else if kids.len() == 0 {
      label.push(p)
    }
  }
  // Whitespace at the edges of the label only gets in the way.
  while label.len() > 0 and _is-blank(label.first()) { label = label.slice(1) }
  while label.len() > 0 and _is-blank(label.last()) { label = label.slice(0, -1) }
  branch(label.join(), ..kids)
}

// If the argument is a list or a sequence of list items, yields its items
// as branches; otherwise the argument itself as a single branch.
#let _expand(arg) = {
  if _is-list(arg) {
    arg.children.map(_from-item)
  } else if _is-item(arg) {
    (_from-item(arg),)
  } else if type(arg) == content and arg.func() == [].func() and arg.children.any(_is-item) and arg.children.all(c => _is-item(c) or _is-list(c) or _is-blank(c)) {
    arg.children.filter(c => not _is-blank(c)).map(_expand).flatten()
  } else {
    (arg,)
  }
}

// --- Palettes --------------------------------------------------------------
//
// Every palette: eight branch colours, handed out in order, and a colour for
// the root. Boxes get the branch colour lightened by `tint`.

#let palettes = (
  // Bright and bold, like markers on a whiteboard.
  poster: (colors: (rgb("#e8321e"), rgb("#f5a623"), rgb("#f2c230"), rgb("#3fc728"),
                    rgb("#1fc2ee"), rgb("#9b3fd6"), rgb("#f78fc0"), rgb("#2a7de1")),
           root: rgb("#7f9bff")),
  // Soft pastel, muted tones.
  pastel: (colors: (rgb("#e28f8f"), rgb("#e9b97a"), rgb("#d6cf7a"), rgb("#8fc79a"),
                    rgb("#7fb8d4"), rgb("#a99adb"), rgb("#d9a0c8"), rgb("#8fbfb5")),
           root: rgb("#9aa6d6")),
  // Greys only: steps from dark to medium.
  grayscale: (colors: (rgb("#222222"), rgb("#555555"), rgb("#333333"), rgb("#777777"),
                       rgb("#444444"), rgb("#888888"), rgb("#2b2b2b"), rgb("#666666")),
              root: rgb("#111111")),
  // One hue, blue, in varying lightness.
  mono: (colors: (rgb("#0b3d91"), rgb("#2a62c2"), rgb("#1749a8"), rgb("#4d80d6"),
                  rgb("#0f2f6e"), rgb("#6e9be0"), rgb("#1f56b5"), rgb("#3a70cc")),
         root: rgb("#082a66")),
  // Plain: one dark ink for everything, as if drawn with a fountain pen.
  plain: (colors: (rgb("#1a1a1a"),), root: rgb("#1a1a1a")),
  // Earth tones: terracotta, ochre, olive, sand.
  earth: (colors: (rgb("#b5532a"), rgb("#c98b2e"), rgb("#7a7a2f"), rgb("#8c5a3c"),
                   rgb("#a3762b"), rgb("#5d6b3a"), rgb("#c47a54"), rgb("#6b4e35")),
          root: rgb("#4e3a2a")),
  // Sea: turquoise, teal, sea green.
  ocean: (colors: (rgb("#0c7c8c"), rgb("#1ea8b5"), rgb("#155e75"), rgb("#2bb39a"),
                   rgb("#0e4d64"), rgb("#4cc3d2"), rgb("#1b8a7d"), rgb("#3b6fa0")),
          root: rgb("#0b3a4a")),
  // Evening sky: red, orange, pink, violet.
  sunset: (colors: (rgb("#c72c41"), rgb("#ee6f3b"), rgb("#f2a541"), rgb("#d9436b"),
                    rgb("#8e3b8f"), rgb("#f07f6f"), rgb("#b02a5c"), rgb("#e88d3a")),
           root: rgb("#5b1f4a")),
  // Forest: green with a little brown.
  forest: (colors: (rgb("#2d6a4f"), rgb("#40916c"), rgb("#1b4332"), rgb("#74a57f"),
                    rgb("#6b8e23"), rgb("#8a6e3a"), rgb("#52b788"), rgb("#3e5c3a")),
           root: rgb("#1b4332")),
  // Neon: loud, saturated colours.
  neon: (colors: (rgb("#ff2079"), rgb("#00e5ff"), rgb("#aaff00"), rgb("#ffe600"),
                  rgb("#ff6a00"), rgb("#b026ff"), rgb("#00ff9c"), rgb("#ff3cac")),
         root: rgb("#1a1a2e")),
)

#let _palette(p) = {
  if type(p) == str {
    assert(p in palettes, message: "brainroot: unknown palette \"" + p + "\", expected one of " + palettes.keys().join(", "))
    palettes.at(p)
  } else if type(p) == array {
    (colors: p, root: rgb("#7f9bff"))
  } else if type(p) == dictionary {
    (colors: palettes.poster.colors, root: rgb("#7f9bff")) + p
  } else {
    panic("brainroot: palette must be a name, an array of colours or a dictionary (colors, root)")
  }
}

// --- Themes ----------------------------------------------------------------
//
// A theme decides how boxes and edges look; the colours still come from
// the palette. Fields:
//   edge      "curve" | "elbow" | "straight"   routing of the edges
//   fill      "tint" | "solid" | "white" | "none"   fill of the boxes
//   stroke    border width of the boxes (0pt = no border)
//   radius    corner radius (may be relative, 50% = pill)
//   underline true: no box, the text sits on a coloured line and the edges
//             flow into that line
//   dash      dash pattern of the edges ("solid", "dashed", "dotted")
//   font      font of the labels; `none` inherits from the document
//   hand      `none`, or a dictionary for hand-drawn lines:
//               amplitude   excursion of the wobble in pt
//               wavelength  length of one wave in pt
//               randomness  irregularity of the rhythm (1 = pure sine)
//               segment     step along the path in pt
//               passes      how often each line is drawn (2 = "scribbled")
//   root      overrides for the root only (fill, stroke, radius)

#let themes = (
  // Pastel boxes, soft S-curves -- the whiteboard original.
  soft: (edge: "curve", fill: "tint", stroke: 0pt, radius: 8pt, underline: false, dash: "solid",
         root: (fill: "solid")),
  // White boxes with a coloured border, curves.
  outline: (edge: "curve", fill: "white", stroke: 1pt, radius: 6pt, underline: false, dash: "solid",
            root: (fill: "solid", stroke: 0pt)),
  // Solid colour, white text, right angles: org-chart look.
  blocks: (edge: "elbow", fill: "solid", stroke: 0pt, radius: 0pt, underline: false, dash: "solid",
           root: (:)),
  // No boxes: the text sits on its line, the classic mind map.
  lines: (edge: "curve", fill: "none", stroke: 0pt, radius: 0pt, underline: true, dash: "solid",
          root: (fill: "solid", radius: 6pt)),
  // Sketch: dashed straight lines, thin border, no fill.
  sketch: (edge: "straight", fill: "none", stroke: 0.8pt, radius: 3pt, underline: false, dash: "dashed",
           root: (fill: "white", stroke: 1.5pt)),
  // Pills and straight connections.
  bubbles: (edge: "straight", fill: "tint", stroke: 1pt, radius: 50%, underline: false, dash: "solid",
            root: (fill: "solid")),
  // Hand-drawn: like `soft`, but every line wobbles slightly.
  hand: (edge: "curve", fill: "tint", stroke: 1pt, radius: 8pt, underline: false, dash: "solid",
         hand: (amplitude: 0.6, wavelength: 80, randomness: 2, segment: 1.5, passes: 1),
         root: (fill: "solid")),
  // Scribbled: no fill, every line drawn twice.
  scribble: (edge: "curve", fill: "none", stroke: 0.7pt, radius: 6pt, underline: false, dash: "solid",
             hand: (amplitude: 0.9, wavelength: 50, randomness: 2.5, segment: 1.5, passes: 2),
             root: (fill: "white", stroke: 1pt)),
  // Felt-tip: solid colour, wide straight strokes with a long wobble.
  marker: (edge: "straight", fill: "solid", stroke: 0pt, radius: 4pt, underline: false, dash: "solid",
           hand: (amplitude: 1.2, wavelength: 120, randomness: 2, segment: 2, passes: 1),
           root: (:)),
  // Pencil: thin lines with a fine tremor, right angles.
  pencil: (edge: "elbow", fill: "white", stroke: 0.6pt, radius: 2pt, underline: false, dash: "solid",
           hand: (amplitude: 0.35, wavelength: 30, randomness: 3, segment: 1, passes: 1),
           root: (stroke: 1pt)),
)

#let _theme-defaults = (font: none, hand: none)

#let _theme(t) = {
  if type(t) == str {
    assert(t in themes, message: "brainroot: unknown theme \"" + t + "\", expected one of " + themes.keys().join(", "))
    _theme-defaults + themes.at(t)
  } else if type(t) == dictionary {
    // A dictionary overrides individual fields of `soft`; `hand` and
    // `root` are merged field by field.
    let base = _theme-defaults + themes.at(t.at("base", default: "soft"))
    let hand = if type(t.at("hand", default: none)) == dictionary {
      (if base.hand == none { (:) } else { base.hand }) + t.hand
    } else { t.at("hand", default: base.hand) }
    base + t + (root: base.root + t.at("root", default: (:)), hand: hand)
  } else {
    panic("brainroot: theme must be a string or a dictionary")
  }
}

// --- Drawing a single node -------------------------------------------------

// Perceived luminance of a colour, 0 dark to 1 light.
#let _luma(c) = {
  let (r, g, b, ..) = rgb(c).components().map(v => v / 100%)
  0.299 * r + 0.587 * g + 0.114 * b
}

// Fill of a box after the theme field `fill`. Tinted fills are lightened
// by `tint` and then further until they are at least `tint-min` light:
// otherwise an almost black ink only yields a medium grey on which text
// reads poorly.
#let _fill(mode, color, opts) = {
  if mode == "solid" { color }
  else if mode == "white" { white }
  else if mode == "tint" {
    let f = color.lighten(opts.tint)
    let n = 0
    while _luma(f) < opts.tint-min and n < 4 { f = f.lighten(30%); n += 1 }
    f
  } else { none }
}

// Text colour for a fill: `ink` applies when set; with `auto` the luminance
// of the fill decides whether dark or light text reads better. Without a
// fill it is the dark one.
#let _ink(fill, opts) = {
  if opts.ink != auto { opts.ink }
  else if fill == none { opts.ink-dark }
  else if _luma(fill) < opts.ink-threshold { opts.ink-light }
  else { opts.ink-dark }
}

#let _nodebox(node, depth, color, opts, width: auto) = {
  let th = opts.theme
  let root = depth == 0
  let spec = if root { th + th.root } else { th }
  let color = if root { opts.root-fill } else { color }
  let scale = opts.scale.at(calc.min(depth, opts.scale.len() - 1))
  let weight = if depth < opts.bold-depth { "bold" } else { "regular" }
  let fill = _fill(spec.fill, color, opts)
  let ink = _ink(fill, opts)
  let stroke = if spec.underline and not root { none }
    else if spec.stroke == 0pt { none } else { spec.stroke + color }
  // Hand-drawn: the box itself stays invisible, `_hand-shape` draws its
  // outline as a wobbly path underneath. Size and padding stay the same so
  // the layout holds.
  let drawn = th.hand == none
  let label = text(weight: weight, size: 1em * scale, fill: ink, node.label)
  let label = if th.font != none { text(font: th.font, label) } else { label }
  box(
    width: width,
    fill: if drawn { fill } else { none },
    stroke: if drawn { stroke } else { none },
    radius: if spec.underline and not root { 0pt } else { spec.radius },
    inset: opts.inset,
    label,
  )
}

// CeTZ measures `content` with its own text edges (cap-height, baseline)
// and therefore places the box a few points too high. A block with the
// fixed size measured here takes that decision away from CeTZ: it is
// centred exactly where the edges and the hand-drawn shape expect it.
#let _framed(t, body) = block(width: t.w, height: t.h, body)

// Fill and border of a node as `_nodebox` picks them -- for the hand-drawn
// path.
#let _node-paint(depth, color, opts) = {
  let th = opts.theme
  let root = depth == 0
  let spec = if root { th + th.root } else { th }
  let color = if root { opts.root-fill } else { color }
  let fill = _fill(spec.fill, color, opts)
  let stroke = if spec.underline and not root { none }
    else if spec.stroke == 0pt { none } else { spec.stroke + color }
  (fill: fill, stroke: stroke, radius: if spec.underline and not root { 0pt } else { spec.radius })
}

// --- Hand-drawn lines ------------------------------------------------------
//
// After the TikZ decoration `sketch` (tex.stackexchange.com/a/445690): a
// path is walked in steps of `segment` pt, every point is offset
// perpendicular to the path by `amplitude * sin(2πt/wavelength)`, where t
// performs a random walk with step `randomness^rand`. `rand` comes from the
// PGF generator (Park-Miller with Schrage's trick), so the same seed gives
// the same wobble as in LaTeX. All computed in Typst: a mind map has only a
// few dozen short paths, which needs no plugin.

#let _rng-next(z) = {
  let t = 69621 * calc.rem(z, 30845) - 23902 * calc.quo(z, 30845)
  if t < 0 { t + 2147483647 } else { t }
}
#let _rng-seed(seed) = {
  let z = calc.rem(seed, 2147483647)
  if z <= 0 { z + 2147483646 } else { z }
}
// Uniform on [-1, 1], quantised to five decimals as in TeX.
#let _rng-rand(z) = (calc.rem(z, 200001) - 100000) / 100000

// Wobbles a polyline (points as (x, y) in pt, plain numbers). Returns the
// new points. `closed` closes at the start point.
#let _wobble(pts, hand, seed, closed: false) = {
  let pts = if closed { pts + (pts.first(),) } else { pts }
  let total = range(1, pts.len()).map(i => {
    let (ax, ay) = pts.at(i - 1)
    let (bx, by) = pts.at(i)
    calc.sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
  }).sum(default: 0.0)
  let z = _rng-seed(seed)
  let t = 0.0
  let out = (pts.first(),)
  let carry = 0.0     // leftover step from the previous segment
  let done = 0.0      // length walked so far
  let off = 0.0
  for i in range(1, pts.len()) {
    let (ax, ay) = pts.at(i - 1)
    let (bx, by) = pts.at(i)
    let (dx, dy) = (bx - ax, by - ay)
    let len = calc.sqrt(dx * dx + dy * dy)
    if len < 1e-9 { continue }
    let (tx, ty) = (dx / len, dy / len)
    let (nx, ny) = (-ty, tx)
    let d = carry
    while d <= len {
      z = _rng-next(z)
      t = calc.rem(t + calc.pow(hand.randomness, _rng-rand(z)), hand.wavelength)
      off = calc.sin(2 * calc.pi * t / hand.wavelength * 1rad) * hand.amplitude
      // Closed paths: the offset fades out before closing, otherwise a notch
      // remains at the start point.
      if closed { off *= calc.min(1, (total - done - d) / (4 * hand.segment)) }
      out.push((ax + tx * d + nx * off, ay + ty * d + ny * off))
      d += hand.segment
    }
    carry = d - len
    done += len
  }
  if closed { out.push(pts.first()) } else {
    let (ax, ay) = pts.at(pts.len() - 2)
    let (bx, by) = pts.last()
    let (dx, dy) = (bx - ax, by - ay)
    let len = calc.max(calc.sqrt(dx * dx + dy * dy), 1e-9)
    out.push((bx - dy / len * off, by + dx / len * off))
  }
  out
}

// A seed from coordinates, so every line wobbles differently while the
// result stays reproducible.
#let _seed(..xs) = {
  let h = 7
  for x in xs.pos() { h = calc.rem(h * 31 + int(calc.round(calc.abs(x) * 10)), 1000003) }
  h + 1
}

#let _pt(l) = if type(l) == length { l.pt() } else { float(l) }

// Cubic Bézier curve as a polyline.
#let _flatten-bezier(p0, c0, c1, p1, n: 24) = range(n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  let (a, b, c, d) = (u * u * u, 3 * u * u * t, 3 * u * t * t, t * t * t)
  (a * p0.at(0) + b * c0.at(0) + c * c1.at(0) + d * p1.at(0),
   a * p0.at(1) + b * c0.at(1) + c * c1.at(1) + d * p1.at(1))
})

// Rounded rectangle around (cx, cy) as a polyline.
#let _rounded-rect(cx, cy, w, h, r, n: 6) = {
  let r = calc.min(r, w / 2, h / 2)
  if r <= 0.01 {
    return ((cx - w / 2, cy - h / 2), (cx + w / 2, cy - h / 2), (cx + w / 2, cy + h / 2), (cx - w / 2, cy + h / 2))
  }
  let corner(x, y, a0) = range(n + 1).map(i => {
    let a = a0 + 90deg * i / n
    (x + r * calc.cos(a), y + r * calc.sin(a))
  })
  let out = corner(cx + w / 2 - r, cy - h / 2 + r, -90deg)
  out += corner(cx + w / 2 - r, cy + h / 2 - r, 0deg)
  out += corner(cx - w / 2 + r, cy + h / 2 - r, 90deg)
  out += corner(cx - w / 2 + r, cy - h / 2 + r, 180deg)
  out
}

// Draws a polyline (numbers in pt) hand-drawn, in `passes` layers.
#let _hand-line(pts, st, hand, seed, closed: false, fill: none) = {
  import cetz.draw: line
  for p in range(hand.passes) {
    let q = _wobble(pts, hand, seed + 977 * p, closed: closed)
    line(..q, close: closed, stroke: st, fill: if p == 0 { fill } else { none })
  }
}

// The outline of a node as a wobbly path, at (cx, cy) given as lengths.
#let _hand-shape(cx, cy, t, depth, color, opts) = {
  let paint = _node-paint(depth, color, opts)
  let (w, h) = (_pt(t.w), _pt(t.h))
  let r = if type(paint.radius) == ratio { calc.min(w, h) * paint.radius / 100% } else { _pt(paint.radius) }
  let pts = _rounded-rect(_pt(cx), _pt(cy), w, h, r)
  let st = if paint.stroke == none { none } else { paint.stroke }
  if st == none and paint.fill == none { return }
  _hand-line(pts, st, opts.theme.hand, _seed(_pt(cx), _pt(cy), w, h), closed: true, fill: paint.fill)
}

// The words of a label, provided it consists of text only; otherwise
// `none`. Needed to know the width of the longest word: a box must not
// shrink below it, or the word sticks out.
#let _words(c) = {
  if type(c) == str { return c.split() }
  if type(c) != content { return none }
  if c.func() == text { return c.text.split() }
  if c.func() == [ ].func() { return () }
  if c.func() == [].func() {
    let out = ()
    for p in c.children {
      let w = _words(p)
      if w == none { return none }
      out += w
    }
    return out
  }
  if c.has("body") { return _words(c.body) }
  none
}

// Measures a node. If the label is wider than `max-width` it wraps; a
// bisection then finds the smallest width at which the wrapping does not
// grow further, so the box is no wider than its longest line. The lower
// bound is the longest word; if it cannot be determined the box stays at
// `max-width`. If even the longest word is wider than `max-width`, the
// natural width stays: a cut-off word would be worse than a wide box.
// Must be called inside `context`.
#let _measure-node(node, depth, color, opts) = {
  let natural = measure(_nodebox(node, depth, color, opts))
  if opts.max-width == none or natural.width <= opts.max-width {
    return (w: natural.width, h: natural.height, width: auto)
  }
  let words = _words(node.label)
  let floor = if words == none { opts.max-width } else {
    words.map(w => measure(_nodebox((label: w), depth, color, opts)).width).fold(0pt, calc.max)
  }
  if floor > opts.max-width {
    return (w: natural.width, h: natural.height, width: auto)
  }
  let wrapped = measure(_nodebox(node, depth, color, opts, width: opts.max-width))
  let lo = floor
  let hi = opts.max-width
  for _ in range(7) {
    let mid = (lo + hi) / 2
    let m = measure(_nodebox(node, depth, color, opts, width: mid))
    if m.height <= wrapped.height { hi = mid } else { lo = mid }
  }
  (w: hi, h: wrapped.height, width: hi)
}

// --- Layout ----------------------------------------------------------------
//
// All layouts work in two axes: the main axis m, along which the tree
// grows, and the cross axis u, along which siblings stand side by side.
// Horizontal layouts (both, right, left, radial) have m = x and u pointing
// down; vertical ones (down, up) have m = y and u = x pointing right.
// `dir` is the sign of the direction of growth on m.

// Size of a box on the two axes.
#let _sizes(m, vertical) = if vertical { (m: m.h, u: m.w) } else { (m: m.w, u: m.h) }

// Annotates a subtree with sizes and places its children. Result:
//   w, h, width   size of the node's own box
//   size-m/-u     the same on the axes
//   kids          the children, each with `du`: offset on u from the centre
//   contour       per depth below this node (lo, hi): how far the subtree
//                 reaches on u before and behind the centre on that level
//                 (lo negative)
//   lo, hi        the same over all levels; size = hi - lo
//   extent        extent of the subtree on m, from its own box on
//
// Siblings are not stacked as blocks but by contour: the next child moves
// up as far as it collides with the previous one on no level. So a leaf
// without children stays close to its neighbour, even if that one has a
// deep subtree.
#let _measure-tree(node, depth, color, opts, vertical) = {
  let m = _measure-node(node, depth, color, opts)
  let sz = _sizes(m, vertical)
  let kids = node.kids.map(k => _measure-tree(_norm(k), depth + 1, color, opts, vertical))

  let placed = ()
  let merged = ()   // contour of the children placed so far, absolute on u
  for k in kids {
    let u = 0pt
    if placed.len() > 0 {
      u = -1e9 * 1pt
      let d = 0
      while d < merged.len() and d < k.contour.len() {
        let limit = merged.at(d).hi + opts.sibling-gap - k.contour.at(d).lo
        if limit > u { u = limit }
        d += 1
      }
    }
    placed.push(k + (du: u))
    let d = 0
    while d < k.contour.len() {
      let c = (lo: u + k.contour.at(d).lo, hi: u + k.contour.at(d).hi)
      if d < merged.len() {
        merged.at(d) = (lo: calc.min(merged.at(d).lo, c.lo), hi: calc.max(merged.at(d).hi, c.hi))
      } else {
        merged.push(c)
      }
      d += 1
    }
  }

  // Parent centred between first and last child.
  let shift = if placed.len() > 0 { (placed.first().du + placed.last().du) / 2 } else { 0pt }
  placed = placed.map(k => k + (du: k.du - shift))
  merged = merged.map(c => (lo: c.lo - shift, hi: c.hi - shift))

  let contour = ((lo: -sz.u / 2, hi: sz.u / 2),) + merged
  let lo = contour.map(c => c.lo).fold(0pt, calc.min)
  let hi = contour.map(c => c.hi).fold(0pt, calc.max)
  let extent = sz.m + if kids.len() > 0 { opts.level-gap + kids.map(k => k.extent).fold(0pt, calc.max) } else { 0pt }
  (
    node: node, depth: depth, color: color, kids: placed,
    w: m.w, h: m.h, width: m.width, size-m: sz.m, size-u: sz.u,
    contour: contour, lo: lo, hi: hi, size: hi - lo, extent: extent,
  )
}

// Distributes the first-level branches to right and left. Explicitly set
// sides stay; the others fill the right side first until it holds at least
// half the total height, the rest goes left. The order (top to bottom) is
// kept on both sides.
#let _split(trees, gap, layout) = {
  if layout == "right" { return (right: trees, left: ()) }
  if layout == "left" { return (right: (), left: trees) }
  let total = trees.map(t => t.size).sum(default: 0pt) + gap * calc.max(trees.len() - 1, 0)
  let right = ()
  let left = ()
  let right-h = 0pt
  let fixed-right = trees.filter(t => t.node.side == right).map(t => t.size).sum(default: 0pt)
  for t in trees {
    if t.node.side == right {
      right.push(t)
    } else if t.node.side == left {
      left.push(t)
    } else if right-h + fixed-right + t.size / 2 <= total / 2 {
      right.push(t)
      right-h += t.size + gap
    } else {
      left.push(t)
    }
  }
  (right: right, left: left)
}

// --- Drawing ---------------------------------------------------------------

#let _stroke(depth, color, opts) = (
  paint: color,
  thickness: opts.thickness.at(calc.min(depth, opts.thickness.len() - 1)),
  cap: "round",
  join: "round",
  dash: opts.theme.dash,
)

// From axis coordinates (m, u) to (x, y).
#let _xy(m, u, vertical) = if vertical { (u, m) } else { (m, -u) }

// Draws the edge with the control points in the theme's routing; hand-drawn
// it is first flattened to a polyline and then wobbled.
#let _path(p0, c0, c1, p1, st, opts) = {
  import cetz.draw: bezier, line
  let hand = opts.theme.hand
  if hand == none {
    if opts.theme.edge == "curve" {
      bezier(p0, p1, c0, c1, stroke: st)
    } else if opts.theme.edge == "elbow" {
      line(p0, c0, c1, p1, stroke: st)
    } else {
      line(p0, p1, stroke: st)
    }
  } else {
    let n(p) = (_pt(p.at(0)), _pt(p.at(1)))
    let pts = if opts.theme.edge == "curve" {
      _flatten-bezier(n(p0), n(c0), n(c1), n(p1))
    } else if opts.theme.edge == "elbow" {
      (n(p0), n(c0), n(c1), n(p1))
    } else {
      (n(p0), n(p1))
    }
    _hand-line(pts, st, hand, _seed(..n(p0), ..n(p1)))
  }
}

// An edge from p0 to p1 in the theme's routing; the curve runs parallel to
// the main axis at both ends.
// (`st` instead of `stroke`: cetz.draw exports a function of that name.)
#let _edge(p0, p1, st, opts, vertical) = {
  import cetz.draw: bezier, line
  let (x0, y0) = p0
  let (x1, y1) = p1
  let (c0, c1) = if vertical {
    let mid = (y0 + y1) / 2
    ((x0, mid), (x1, mid))
  } else {
    let mid = (x0 + x1) / 2
    ((mid, y0), (mid, y1))
  }
  _path(p0, c0, c1, p1, st, opts)
}

// Draws a subtree whose box has its inner edge at m and is centred at u.
// With `underline` in a horizontal layout the edges sit on the baseline of
// the text, otherwise at the centre of the box.
#let _draw-tree(t, m, u, dir, opts, vertical) = {
  import cetz.draw: *
  let ul = opts.theme.underline and not vertical
  let anchor(tree, cu) = if ul { cu + tree.size-u / 2 } else { cu }
  let m0 = m + dir * t.size-m
  let m1 = m0 + dir * opts.level-gap
  for k in t.kids {
    let ku = u + k.du
    _edge(_xy(m0, anchor(t, u), vertical), _xy(m1, anchor(k, ku), vertical),
      _stroke(k.depth - 1, t.color, opts), opts, vertical)
    _draw-tree(k, m1, ku, dir, opts, vertical)
  }
  // The box after the edges, so it covers their ends.
  let (cx, cy) = _xy(m + dir * t.size-m / 2, u, vertical)
  if opts.theme.hand != none { _hand-shape(cx, cy, t, t.depth, t.color, opts) }
  content((cx, cy), _framed(t, _nodebox(t.node, t.depth, t.color, opts, width: t.width)))
  if opts.theme.underline {
    // The underline is a line of its own in the width of the edge flowing
    // into it; as a box border it would have a different width and sit
    // offset by half its thickness.
    let st = _stroke(t.depth - 1, t.color, opts) + (cap: "butt")
    let (a, b) = if vertical {
      ((cx - t.w / 2, cy - t.h / 2), (cx + t.w / 2, cy - t.h / 2))
    } else {
      (_xy(m, anchor(t, u), false), _xy(m0, anchor(t, u), false))
    }
    if opts.theme.hand == none { line(a, b, stroke: st) }
    else { _hand-line(((_pt(a.at(0)), _pt(a.at(1))), (_pt(b.at(0)), _pt(b.at(1)))), st, opts.theme.hand, _seed(_pt(a.at(0)), _pt(a.at(1)))) }
  }
}

// Edge from the root to a branch: leaves the root towards the branch and
// arrives parallel to the main axis.
#let _root-edge(p1, m-inner, st, opts, vertical) = {
  import cetz.draw: bezier
  if opts.theme.edge != "curve" or vertical {
    // Vertically the S-curve with its inflection at half height is calmest.
    _edge((0pt, 0pt), p1, st, opts, vertical)
  } else {
    let (x1, y1) = p1
    let (c0, c1) = if vertical { ((0pt, y1 * 0.9), (x1, m-inner)) } else { ((x1 * 0.9, 0pt), (m-inner, y1)) }
    _path((0pt, 0pt), c0, c1, p1, st, opts)
  }
}

// Stacks branches on u, centred around 0, and draws them with their root edge.
#let _draw-stack(side, dir, m-inner, m1, opts, vertical) = {
  let total = side.map(t => t.size).sum(default: 0pt) + opts.branch-gap * calc.max(side.len() - 1, 0)
  let cu = -total / 2
  for t in side {
    let tu = cu - t.lo
    let au = if opts.theme.underline and not vertical { tu + t.size-u / 2 } else { tu }
    _root-edge(_xy(m1, au, vertical), dir * m-inner, _stroke(0, t.color, opts), opts, vertical)
    _draw-tree(t, m1, tu, dir, opts, vertical)
    cu += t.size + opts.branch-gap
  }
}

// Radial: every branch gets an angle, its box sits on a circle around the
// root, its subtree grows horizontally outward. The radius starts at
// `root-gap` and grows until no two subtrees overlap.
#let _draw-radial(trees, rm, start, opts) = {
  let n = trees.len()
  if n == 0 { return }
  let angles = range(n).map(i => start - i * 360deg / n)
  let dirs = angles.map(a => if calc.cos(a) >= 0 { 1 } else { -1 })
  // Inner edge of the branch box: to the sides it sits on the circle point;
  // the closer the branch is to vertical, the further the box moves over
  // the point, until it is centred directly above or below it.
  let inner(i, r) = {
    let (a, d, t) = (angles.at(i), dirs.at(i), trees.at(i))
    let f = 1 - calc.min(1, calc.abs(calc.cos(a)) / 0.4)
    (px: r * calc.cos(a) - d * t.w / 2 * f, py: r * calc.sin(a))
  }
  // Rectangle of a subtree at radius r: (x0, x1, y0, y1)
  let rect(i, r) = {
    let (d, t) = (dirs.at(i), trees.at(i))
    let (px, py) = inner(i, r)
    (x0: calc.min(px, px + d * t.extent), x1: calc.max(px, px + d * t.extent),
     y0: py - t.hi, y1: py - t.lo)
  }
  let overlaps(r) = {
    let gap = opts.branch-gap
    let rects = range(n).map(i => rect(i, r))
    // keep the root clear as well
    rects.push((x0: -rm.w / 2 - opts.root-gap / 2, x1: rm.w / 2 + opts.root-gap / 2,
                y0: -rm.h / 2 - gap, y1: rm.h / 2 + gap))
    for i in range(rects.len()) {
      for j in range(i + 1, rects.len()) {
        let (a, b) = (rects.at(i), rects.at(j))
        if a.x0 < b.x1 + gap and b.x0 < a.x1 + gap and a.y0 < b.y1 + gap and b.y0 < a.y1 + gap {
          return true
        }
      }
    }
    false
  }
  let r = calc.max(rm.w, rm.h) / 2 + opts.root-gap
  let steps = 0
  while overlaps(r) and steps < 400 { r += 4pt; steps += 1 }

  for i in range(n) {
    let (a, d, t) = (angles.at(i), dirs.at(i), trees.at(i))
    let (px, py) = inner(i, r)
    let st = _stroke(0, t.color, opts)
    if calc.abs(calc.cos(a)) < 0.2 and opts.theme.edge == "curve" {
      // Branch almost straight above or below the root: the edge arrives at
      // the centre of the box from above or below instead of hooking in
      // from the side.
      let cx = px + d * t.w / 2
      let ty = if py < 0pt { py + t.h / 2 } else { py - t.h / 2 }
      _path((0pt, 0pt), (0pt, ty / 2), (cx, ty / 2), (cx, ty), st, opts)
    } else {
      let ay = if opts.theme.underline { py - t.size-u / 2 } else { py }
      _root-edge((px, ay), px - d * opts.root-gap / 2, st, opts, false)
    }
    _draw-tree(t, px, -py, d, opts, false)
  }
}

/// Draws the mind map.
///
/// - title: label of the root. Without it, the first positional argument
///   is the root.
/// - ..branches: first-level branches, each a `branch(...)`, content, or a
///   Typst list whose items become branches and whose nested lists become
///   children.
/// - theme: name of a theme (`soft`, `outline`, `blocks`, `lines`, `sketch`,
///   `bubbles`, `hand`, `scribble`, `marker`, `pencil`) or a dictionary that
///   overrides individual fields of a theme (`base:` picks the starting
///   theme, otherwise `soft`).
/// - layout: arrangement of the branches around the root: `"both"` right
///   and left, `"right"` or `"left"` one-sided, `"down"` or `"up"` as a tree
///   from the top or bottom, `"radial"` in a circle.
/// - start: `radial` only: angle of the first branch; the others follow
///   clockwise.
/// - wobble: strength of the wobble in hand-drawn themes as a factor on
///   their `amplitude`; `0` draws straight, `2` twice as restless.
/// - palette: name of a palette (`poster`, `pastel`, `grayscale`, `mono`,
///   `plain`, `earth`, `ocean`, `sunset`, `forest`, `neon`), an array of
///   colours or a dictionary `(colors: ..., root: ...)`. The colours go in
///   order to branches without a `color` of their own.
/// - root-fill: colour of the root; `auto` takes the palette's.
/// - tint: how much the branch colour is lightened for the boxes.
/// - tint-min: minimum luminance (0 to 1) of tinted fills; dark palette
///   colours are lightened further to reach it.
/// - ink: text colour; `auto` picks per box between `ink-dark` and
///   `ink-light` by the luminance of its fill.
/// - ink-dark, ink-light: text on light and dark fills respectively.
/// - ink-threshold: luminance (0 to 1) below which the light text applies.
/// - scale: font size relative to the surroundings, per level (root,
///   branches, leaves, ...); the last value holds for all deeper levels.
/// - bold-depth: levels (from the root) set in bold.
/// - thickness: line width per level of connection (root→branch,
///   branch→leaf, ...); the last value holds for all deeper levels.
/// - level-gap: distance between parent and child box along the direction
///   of growth.
/// - root-gap: distance between root and branches; with `radial` the
///   minimum radius.
/// - sibling-gap: distance between siblings across the direction of growth.
/// - branch-gap: distance between the first-level branches.
/// - max-width: labels wider than this wrap; `none` never wraps.
/// - inset: padding of the boxes.
#let brainroot(
  ..branches,
  title: none,
  theme: "soft",
  layout: "both",
  start: 60deg,
  wobble: 1,
  palette: "poster",
  root-fill: auto,
  tint: 60%,
  tint-min: 0.8,
  ink: auto,
  ink-dark: black,
  ink-light: white,
  ink-threshold: 0.55,
  scale: (1.3, 1.1, 1.0),
  bold-depth: 2,
  thickness: (3pt, 1.5pt),
  level-gap: 40pt,
  root-gap: 80pt,
  sibling-gap: 8pt,
  branch-gap: 24pt,
  max-width: 5cm,
  inset: (x: 10pt, y: 6pt),
) = context {
  let layouts = ("both", "right", "left", "down", "up", "radial")
  assert(layout in layouts, message: "brainroot: layout must be one of " + layouts.join(", "))
  let vertical = layout in ("down", "up")
  let theme = _theme(theme)
  if theme.hand != none {
    theme.hand.amplitude *= wobble
  }
  let palette = _palette(palette)
  let root-fill = if root-fill == auto { palette.root } else { root-fill }
  let opts = (
    theme: theme, root-fill: root-fill, tint: tint, tint-min: tint-min,
    ink: ink, ink-dark: ink-dark, ink-light: ink-light, ink-threshold: ink-threshold,
    scale: scale, bold-depth: bold-depth, thickness: thickness,
    level-gap: level-gap, root-gap: root-gap, sibling-gap: sibling-gap, branch-gap: branch-gap,
    max-width: max-width, inset: inset,
  )
  let args = branches.pos()
  let root = title
  if root == none {
    assert(args.len() > 0, message: "brainroot: root missing (title: ... or first argument)")
    root = args.first()
    args = args.slice(1)
  }
  let root-node = branch(root)
  let rm = _measure-node(root-node, 0, black, opts)

  let trees = args.map(_expand).flatten().enumerate().map(((i, b)) => {
    let b = _norm(b)
    let c = if b.color != none { b.color } else { palette.colors.at(calc.rem(i, palette.colors.len())) }
    _measure-tree(b, 1, c, opts, vertical)
  })

  cetz.canvas(length: 1pt, {
    import cetz.draw: *
    if layout == "radial" {
      _draw-radial(trees, rm, start, opts)
    } else if vertical {
      let dir = if layout == "down" { -1 } else { 1 }
      _draw-stack(trees, dir, rm.h / 2, dir * (rm.h / 2 + root-gap), opts, true)
    } else {
      let sides = _split(trees, branch-gap, layout)
      for (dir, side) in ((1, sides.right), (-1, sides.left)) {
        _draw-stack(side, dir, rm.w / 2, dir * (rm.w / 2 + root-gap), opts, false)
      }
    }
    // The root last, so it lies on top of the lines.
    if opts.theme.hand != none { _hand-shape(0pt, 0pt, rm, 0, black, opts) }
    content((0, 0), _framed(rm, _nodebox(root-node, 0, black, opts, width: rm.width)))
  })
}
