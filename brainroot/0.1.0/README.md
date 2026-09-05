# brainroot

`brainroot` draws two-sided mind maps: the root in the middle, branches to
the right and left, each branch in its own colour down to its leaves. The
layout is automatic and the boxes size themselves to their text.

## Usage

```typ
#import "@schule/brainroot:0.1.0": brainroot, branch

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
```

Every list item becomes a node, indented items become its children, to any
depth. To set the colour or side of a branch, write it as `branch(...)`:

```typ
#brainroot([Forms of energy],
  branch([Kinetic energy], [Motion], [Wind], color: red),
  branch([Elastic energy], [Stretching], side: left),
)
```

Both forms mix: a list and individual `branch` calls may stand side by side
as arguments.

## Parameters

`branch(label, ..kids, color: none, side: auto)`

- `color`: colour of the branch; `none` takes the next colour of the palette.
- `side`: `left` or `right` forces the side. Both only on the first level.

`brainroot(..branches, title: none, ...)`

- `title`: label of the root. Without it, the first positional argument is the root.
- `theme`: look of boxes and edges, see below. Default: `"soft"`.
- `layout`: arrangement, see below. Default: `"both"`.
- `start`: `radial` only, angle of the first branch. Default: `60deg`.
- `wobble`: strength of the wobble in hand-drawn themes, a factor on the theme's `amplitude`. Default: `1`.
- `palette`: name of a palette (see below), an array of colours, or `(colors: ..., root: ...)`. Default: `"poster"`.
- `root-fill`: colour of the root. Default: `auto`, the palette's.
- `tint`: how much the branch colour is lightened for the boxes. Default: `60%`.
- `tint-min`: minimum luminance (0 to 1) of tinted fills; dark colours are lightened further. Default: `0.8`.
- `ink`: text colour. Default: `auto`, then the fill's luminance decides between `ink-dark` (black) and `ink-light` (white); `ink-threshold` (0.55) is the boundary.
- `scale`: font size per level relative to the surroundings. Default: `(1.3, 1.1, 1.0)`.
- `bold-depth`: this many levels from the root are bold. Default: `2`.
- `thickness`: line width per level. Default: `(3pt, 1.5pt)`.
- `level-gap`, `root-gap`: distances along the direction of growth, parent to child and root to branch. Default: `40pt`, `80pt`.
- `sibling-gap`, `branch-gap`: distances across, between siblings and between first-level branches. Default: `8pt`, `24pt`.
- `max-width`: labels wider than this wrap. Default: `5cm`.
- `inset`: padding of the boxes.

## Layouts

| `layout` | |
| --- | --- |
| `both` | root in the middle, branches right and left (default) |
| `right`, `left` | all branches on one side |
| `down`, `up` | tree from top to bottom or bottom to top |
| `radial` | branches in a circle around the root, subtrees grow outward |

With `both` and no `side` given, the first branches go right until the right
side reaches about half the total height; the rest go left. The top-to-bottom
order is kept on both sides. With `radial` the first branch sits at `start`,
the others follow clockwise; the radius grows until no subtrees overlap.

## Palettes

| `palette` | |
| --- | --- |
| `poster` | bright and bold, like markers on a whiteboard (default) |
| `pastel` | soft, muted tones |
| `grayscale` | greys only |
| `mono` | one blue in varying lightness |
| `plain` | one dark ink for everything |
| `earth` | terracotta, ochre, olive, sand |
| `ocean` | turquoise, teal, sea green |
| `sunset` | red, orange, pink, violet |
| `forest` | green with a little brown |
| `neon` | loud, saturated colours |

Your own colours: `palette: (red, blue, green)`, or with a root colour
`palette: (colors: (red, blue), root: black)`.

## Themes

A theme decides how boxes and edges look. The colours still come from the
palette.

| Theme | Boxes | Edges |
| --- | --- | --- |
| `soft` | pastel fill, rounded corners | soft S-curves |
| `outline` | white with coloured border | curves |
| `blocks` | solid colour, white text, square | right angles |
| `lines` | no box, text on a coloured line | curves flowing into the line |
| `sketch` | thin border, no fill | dashed straight lines |
| `bubbles` | pills, pastel fill | straight lines |
| `hand` | like `soft`, hand-drawn | wobbly curves |
| `scribble` | no fill, drawn twice | wobbly curves |
| `marker` | solid colour, felt-tip | wide wobbly straight lines |
| `pencil` | thin, pencil | shaky right angles |

The four hand-drawn themes wobble every line after the TikZ decoration
`sketch`: along the path, with reproducible randomness. A handwriting font
such as "Patrick Hand" or "Kalam" suits them, either via
`set text(font: ...)` or the theme field `font`.

A dictionary overrides individual fields of a theme:

```typ
#brainroot(title: [Forms of energy],
  theme: (base: "outline", edge: "elbow", radius: 0pt), map)
```

Fields: `edge` (`"curve"`, `"elbow"`, `"straight"`), `fill` (`"tint"`,
`"solid"`, `"white"`, `"none"`), `stroke` (border width), `radius`,
`underline`, `dash` (`"solid"`, `"dashed"`, `"dotted"`), `font`, `root` with
overrides for the root only, and `hand`: `none` or a dictionary with
`amplitude` (excursion in pt), `wavelength` (in pt), `randomness`
(irregularity, 1 is a pure sine), `segment` (step in pt) and `passes` (how
often each line is drawn).

```typ
#brainroot(title: [Forms of energy], layout: "radial",
  theme: (base: "blocks", hand: (amplitude: 1, wavelength: 60), font: "Kalam"),
  map)
```

## Manual

The manual is available in [German](docs/) and English; both are built from
`docs/`.
