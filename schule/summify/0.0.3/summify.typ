
// =============================================================================
// Cheatsheet System for Typst
// A modular system for creating well-structured summaries and overviews
// =============================================================================

// -----------------------------------------------------------------------------
// Basic Configuration
// -----------------------------------------------------------------------------

// State management for hideable content
#let _state-sf-hide-content = state("cs-hide", false)
#let _state-sf-theme = state(
  "cs-theme",
  (
    colors: (
      topic: (
        background: black.lighten(30%),
        text: white,
      ),
      block: (
        header-background: white.darken(15%),
        text: white,
      ),
    ),
    font: (
      size: 12pt,
      family: "New Computer Modern Sans",
    ),
    spacing: (
      topic-gap: 4mm,
      subtopic-gap: 0mm,
      title-height: 6mm,
      header-height: 6.5mm,
    ),
  ),
)

// -----------------------------------------------------------------------------
// Main Functions
// -----------------------------------------------------------------------------

// Creates a new overview page with customizable layout and styling
#let summify(
  title: "",
  paper: "a3",
  show-grid: false,
  flipped: true,
  hide-content: false,
  body,
) = {
  context {
    set text(size: _state-sf-theme.get().font.size, font: _state-sf-theme.get().font.family)
    set page(
      paper,
      flipped: flipped,
      margin: (top: 2cm, x: 1cm, y: 1cm),
      header-ascent: 0mm,
      header: [
        #align(center + horizon, text(20pt, weight: "bold", title))
      ],
    )
    _state-sf-hide-content.update(hide-content)
    box(height: 100%, width: 100%, body)
  }
}

// -----------------------------------------------------------------------------
// Subtitles and Layout Helpers
// -----------------------------------------------------------------------------

// Creates a header for subsections with consistent styling
#let section-header(title) = {
  align(
    top,
    box(
      width: 100%,
      fill: _state-sf-theme.get().colors.block.header-background,
      stroke: (x: 0pt, y: 1pt),
      height: _state-sf-theme.get().spacing.header-height,
      inset: 0mm,
      align(
        center + horizon,
        text(
          weight: "bold",
          size: 10pt,
          title,
        ),
      ),
    ),
  )
}

// Base box with optional content hiding functionality
#let content-block(title: none, inset: 2mm, body) = {
  align(
    horizon,
    (
      context if _state-sf-hide-content.get() [
        #if title != none { section-header(title) }
        #v(0mm, weak: true)
        #hide(box(inset: inset, width: 100%, body))
        #v(0mm, weak: true)
      ] else [
        #if title != none { }
        #section-header(title)
        #v(0mm, weak: true)
        #box(inset: inset, width: 100%, body)
        #v(0mm, weak: true)
      ]
    ),
  )
}

// -----------------------------------------------------------------------------
// Topic Blocks and Layout
// -----------------------------------------------------------------------------

// Creates a topic block with title and customizable dimensions
#let topic-block(
  title: none,
  height: 100%,
  width: 100%,
  body,
) = {
  context {
    let title-height = _state-sf-theme.get().spacing.title-height
    box(
      stroke: black + 1pt,
      height: height - title-height,
      width: width,
      inset: (top: 0.5pt, left: 0pt, right: 0pt, bottom: 0pt),
      radius: if title != none { (bottom-right: 10pt, top-right: 10pt, bottom-left: 10pt) } else { 10pt },
    )[
      // Title area
      #if title != none {
        place(
          top + left,
          dy: -title-height - 0.5pt,
          box(
            fill: _state-sf-theme.get().colors.topic.background,
            height: title-height,
            inset: (left: 2mm, right: 2mm, top: 0pt, bottom: 0pt),
            stroke: black,
            radius: (top-right: 5pt, top-left: 5pt),
            align(horizon, text(fill: _state-sf-theme.get().colors.topic.text, weight: "bold", size: 12pt, title)),
          ),
        )
      }

      // Content area
      #box(
        //height: 100%,
        width: 100%,
        radius: if title != none { (bottom-right: 10pt, top-right: 10pt, bottom-left: 10pt) } else { 10pt },
        inset: (top: -0.5pt, bottom: 0pt, left: 0pt, right: 0pt),
        clip: true,
        body,
      )
    ]
  }
}

// -----------------------------------------------------------------------------
// Layout System
// -----------------------------------------------------------------------------

// Base stack function for flexible layouts
// Supports both vertical and horizontal stacking with customizable ratios
#let stack(
  direction: "vertical",
  stack-type: "topic",
  ratios: none,
  ..children,
) = {
  let (cols, rows) = if direction == "horizontal" {
    (if ratios == none { children.pos().len() * (1fr,) } else { ratios }, 1)
  } else {
    (1, if ratios == none { children.pos().len() * (1fr,) } else { ratios })
  }

  let style = if stack-type == "topic" {
    (
      stroke: none,
      inset: 0mm,
      column-gutter: context _state-sf-theme.get().spacing.topic-gap,
      row-gutter: context _state-sf-theme.get().spacing.subtopic-gap,
    )
  } else {
    (
      stroke: if direction == "vertical" { (y: 1pt) } else { (x: 1pt) },
      inset: (left: 0.25pt, right: 0.25pt, top: 0pt, bottom: 0pt),
      column-gutter: 0mm,
      row-gutter: 0mm,
    )
  }

  context grid(
    columns: cols,
    rows: rows,
    align: horizon,
    inset: style.inset,
    stroke: style.stroke,
    column-gutter: if stack-type == "topic" {
      _state-sf-theme.get().spacing.topic-gap
    } else {
      _state-sf-theme.get().spacing.subtopic-gap
    },
    row-gutter: if stack-type == "topic" {
      _state-sf-theme.get().spacing.topic-gap
    } else {
      _state-sf-theme.get().spacing.subtopic-gap
    },
    ..children.pos()
  )
}

// Helper functions for various stack layouts
// Vertical stack for main content organization
#let stack-vertical(ratios: none, ..children) = {
  stack(direction: "vertical", stack-type: "topic", ratios: ratios, ..children)
}

// Horizontal stack for side-by-side content
#let stack-horizontal(ratios: none, ..children) = {
  stack(direction: "horizontal", stack-type: "topic", ratios: ratios, ..children)
}

// Vertical stack for sections within topics
#let stack-section-vertical(ratios: none, ..children) = {
  stack(direction: "vertical", stack-type: "subtopic", ratios: ratios, ..children)
}

// Horizontal stack for sections within topics
#let stack-section-horizontal(ratios: none, ..children) = {
  stack(direction: "horizontal", stack-type: "subtopic", ratios: ratios, ..children)
}
