// =============================================================================
// Summify 0.1.0 - Cheatsheet System for Typst
// A modular grid-based system for creating structured summaries
// =============================================================================

// -----------------------------------------------------------------------------
// Theme System
// -----------------------------------------------------------------------------

#let _state-hide-content = state("summify-hide", false)

// Predefined Themes
#let themes = (
  // Modern Blue - Professional and clean
  "modern-blue": (
    colors: (
      primary: rgb("#2563eb"), // Vibrant blue
      on-primary: white,
      surface: rgb("#eff6ff"), // Light blue tint
      border: rgb("#1e40af"), // Darker blue
    ),
    spacing: (
      page: (x: 1cm, y: 1cm, top: 2cm),
      topic: 4mm,
      section: 0mm,
      content: 2mm,
    ),
    sizes: (
      title: (height: 6mm, text: 12pt),
      header: (height: 6.5mm, text: 9pt),
      border: 1.5pt,
      radius: 8pt,
    ),
    typography: (
      font: "New Computer Modern Sans",
      math-font: "New Computer Modern Math",
      base-size: 12pt,
      weights: (title: "bold", header: "bold"),
    ),
  ),
  // Warm Sunset - Energetic and creative
  "warm-sunset": (
    colors: (
      primary: rgb("#f59e0b"), // Amber/orange
      on-primary: rgb("#451a03"), // Dark brown
      surface: rgb("#fef3c7"), // Light amber
      border: rgb("#b45309"), // Dark orange
    ),
    spacing: (
      page: (x: 1cm, y: 1cm, top: 2cm),
      topic: 5mm,
      section: 1mm,
      content: 3mm,
    ),
    sizes: (
      title: (height: 7mm, text: 13pt),
      header: (height: 7mm, text: 11pt),
      border: 2pt,
      radius: 12pt,
    ),
    typography: (
      font: "New Computer Modern Sans",
      math-font: "New Computer Modern Math",
      base-size: 12pt,
      weights: (title: "bold", header: "semibold"),
    ),
  ),
  // Dark Professional - Elegant and modern
  "dark-pro": (
    colors: (
      primary: rgb("#18181b"), // Almost black
      on-primary: rgb("#fafafa"), // Off-white
      surface: rgb("#27272a"), // Dark gray
      border: rgb("#71717a"), // Medium gray
    ),
    spacing: (
      page: (x: 1cm, y: 1cm, top: 2cm),
      topic: 3mm,
      section: 0mm,
      content: 2mm,
    ),
    sizes: (
      title: (height: 6mm, text: 11pt),
      header: (height: 6mm, text: 10pt),
      border: 1pt,
      radius: 6pt,
    ),
    typography: (
      font: "New Computer Modern Sans",
      math-font: "New Computer Modern Math",
      base-size: 11pt,
      weights: (title: "bold", header: "medium"),
    ),
  ),
  // Default theme (same as original)
  "default": (
    colors: (
      primary: black.lighten(30%),
      on-primary: white,
      surface: white.darken(15%),
      border: black,
    ),
    spacing: (
      page: (x: 1cm, y: 1cm, top: 2cm),
      topic: 4mm,
      section: 0mm,
      content: 2mm,
    ),
    sizes: (
      title: (height: 6mm, text: 11pt),
      header: (height: 5.5mm, text: 9pt),
      border: 1pt,
      radius: 10pt,
    ),
    typography: (
      font: "New Computer Modern Sans",
      math-font: "New Computer Modern Math",
      base-size: 12pt,
      weights: (title: "bold", header: "bold"),
    ),
  ),
)

#let _state-theme = state("summify-theme", themes.default)

// Helper function to merge dictionaries recursively
#let _merge-dict(base, override) = {
  let result = base
  for (key, value) in override {
    if key in base and type(base.at(key)) == dictionary and type(value) == dictionary {
      // Recursively merge nested dictionaries
      result.insert(key, _merge-dict(base.at(key), value))
    } else {
      // Override or add the value
      result.insert(key, value)
    }
  }
  result
}

// Set theme function
#let set-theme(theme) = {
  if type(theme) == str {
    // Theme by name
    if theme in themes {
      _state-theme.update(themes.at(theme))
    } else {
      panic("Unknown theme: " + theme + ". Available themes: " + themes.keys().join(", "))
    }
  } else if type(theme) == dictionary {
    // Custom theme dictionary
    _state-theme.update(theme)
  } else {
    panic("Theme must be a string (theme name) or dictionary (custom theme)")
  }
}

// Update specific theme parameters
#let update-theme(..params) = context {
  let current = _state-theme.get()
  let updates = params.named()
  let merged = _merge-dict(current, updates)
  _state-theme.update(merged)
}

// -----------------------------------------------------------------------------
// Main Document Setup
// -----------------------------------------------------------------------------

#let summify(
  title: "",
  paper: "a3",
  flipped: true,
  hide-content: false,
  theme: "default",
  theme-overrides: (:),
  body,
) = context {
  // Set the theme if provided
  if theme != none {
    set-theme(theme)
  }

  // Apply theme overrides if provided
  if theme-overrides != (:) {
    update-theme(..theme-overrides)
  }

  let theme-config = _state-theme.get()

  set text(
    size: theme-config.typography.base-size,
    font: theme-config.typography.font,
    hyphenate: true,
  )

  set par(justify: true)

  show math.equation: set text(font: theme-config.typography.math-font)

  set page(
    paper,
    flipped: flipped,
    margin: (
      top: theme-config.spacing.page.top,
      x: theme-config.spacing.page.x,
      y: theme-config.spacing.page.y,
    ),
    header-ascent: 0mm,
    header: align(
      center + horizon,
      text(
        20pt,
        weight: theme-config.typography.weights.title,
        title,
      ),
    ),
  )

  _state-hide-content.update(hide-content)

  box(height: 100%, width: 100%, body)
}

// -----------------------------------------------------------------------------
// Grid Composition Functions
// -----------------------------------------------------------------------------

#let compose(
  direction: "horizontal",
  lines: false,
  gap: auto,
  ratios: none,
  ..children,
) = context {
  let theme = _state-theme.get()
  let items = children.pos()

  let count = items.len()

  let (cols, rows) = if direction == "horizontal" {
    (if ratios == none { count * (1fr,) } else { ratios }, auto)
  } else {
    (auto, if ratios == none { count * (1fr,) } else { ratios })
  }

  let gap-value = if gap == auto { theme.spacing.topic } else { gap }

  // Insert horizontal/vertical lines between children
  let items-with-lines = ()
  for (i, item) in items.enumerate() {
    items-with-lines.push(item)
    if direction == "horizontal" and lines and i < count - 1 {
      items-with-lines.push(grid.vline())
    }
    if direction == "vertical" and lines and i < count - 1 {
      items-with-lines.push(grid.hline())
    }
  }

  grid(
    columns: cols,
    rows: rows,
    inset: (x: 0.25pt, y: 0pt),
    column-gutter: if direction == "horizontal" { gap-value } else { 0pt },
    row-gutter: if direction == "vertical" { gap-value } else { 0pt },
    ..items-with-lines
  )
}

#let beside(gap: auto, ratios: none, ..children) = {
  compose(direction: "horizontal", gap: gap, ratios: ratios, ..children)
}

#let below(gap: auto, ratios: none, ..children) = {
  compose(direction: "vertical", gap: gap, ratios: ratios, ..children)
}

#let cols(gap: auto, ratios: none, ..children) = context {
  let gap-val = if gap == auto { _state-theme.get().spacing.section } else { gap }
  compose(direction: "horizontal", gap: gap-val, ratios: ratios, lines: true, ..children)
}

#let rows(gap: auto, ratios: none, ..children) = context {
  let gap-val = if gap == auto { _state-theme.get().spacing.section } else { gap }
  compose(direction: "vertical", gap: gap-val, ratios: ratios, lines: true, ..children)
}

// -----------------------------------------------------------------------------
// Content Blocks
// -----------------------------------------------------------------------------

#let topic(
  title: none,
  height: 100%,
  width: 100%,
  fill: auto,
  stroke: auto,
  radius: auto,
  body,
) = context {
  let theme = _state-theme.get()

  let fill-val = if fill == auto { theme.colors.primary } else { fill }
  let stroke-val = if stroke == auto { theme.colors.border + theme.sizes.border } else { stroke }
  let radius-val = if radius == auto { theme.sizes.radius } else { radius }
  let title-height = theme.sizes.title.height

  // Calculate actual content height
  let content-height = height - if title != none { title-height } else { 0pt }

  // Main container - using stack for seamless connection
  if title != none {
    stack(
      dir: ttb,
      spacing: 0pt,
      // Title tab
      box(
        fill: fill-val,
        height: title-height,
        width: auto,
        stroke: stroke-val,
        radius: (top-left: radius-val, top-right: radius-val),
        inset: (left: 3mm, right: 3mm, y: 1mm),
        align(left + horizon, text(
          fill: theme.colors.on-primary,
          theme.sizes.title.text,
          weight: theme.typography.weights.title,
          title,
        )),
      ),
      // Content box with border and clipping
      box(
        width: width,
        height: content-height,
        stroke: stroke-val,
        radius: (bottom-left: radius-val, bottom-right: radius-val, top-right: radius-val),
        clip: true,
        body,
      ),
    )
  } else {
    // No title - just the content box
    box(
      width: width,
      height: height,
      stroke: stroke-val,
      radius: radius-val,
      clip: true,
      body,
    )
  }
}

#let section(title, fill: auto, height: auto) = context {
  let theme = _state-theme.get()

  let fill-val = if fill == auto { theme.colors.surface } else { fill }
  let height-val = if height == auto { theme.sizes.header.height } else { height }

  // Simple rect with stroke at bottom
  rect(
    width: 100%,
    height: height-val,
    fill: fill-val,
    stroke: (bottom: 1pt, top: 1pt),
    inset: (left: 2mm, right: 2mm),
    align(left + horizon, text(
      size: theme.sizes.header.text,
      weight: theme.typography.weights.header,
      title,
    )),
  )
}

#let content(
  title: none,
  inset: auto,
  align-content: left,
  hide: auto,
  body,
) = {
  // For rows(): if there's a title, we need to span it across the row with the body below
  // For cols(): title and body are separate cells side-by-side

  context {
    let theme = _state-theme.get()
    let inset-val = if inset == auto { theme.spacing.content } else { inset }
    let should-hide = if hide == auto { _state-hide-content.get() } else { hide }

    let body-box = if should-hide {
      hide(box(
        inset: inset-val,
        width: 100%,
        stroke: none,
        align(horizon + align-content, body),
      ))
    } else {
      box(
        inset: inset-val,
        width: 100%,
        stroke: none,
        align(horizon + align-content, body),
      )
    }

    // Return as grid.cell with internal grid for title+body layout
    if title != none {
      grid.cell(
        grid(
          align: horizon,
          columns: (100%,),
          rows: (auto, 1fr),
          row-gutter: 0pt,
          section(title),
          body-box,
        ),
      )
    } else {
      grid.cell(align: horizon, body-box)
    }
  }
}

