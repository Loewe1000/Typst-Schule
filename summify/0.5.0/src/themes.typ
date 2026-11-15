// summify – vordefinierte Farbthemen.

/// Vordefinierte Farbthemen für Summify.
///
/// Verfügbare Namen: `"modern-blue"`, `"warm-sunset"`, `"dark-pro"`, `"default"`.
/// Jedes Thema ist ein Dictionary mit den Gruppen `colors`, `spacing`, `sizes`
/// und `typography`.
///
/// ```typ
/// #show: summify.with(theme: "modern-blue")
/// ```
///
/// -> dictionary
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
      page: (x: 1cm, y: 1cm, top: 1cm),
      topic: 4mm,
      section: 0mm,
      cell: 2mm,
    ),
    sizes: (
      title: (height: 6mm, font-size: 12pt),
      header: (height: 6.5mm, font-size: 9pt),
      border: 1.5pt,
      radius: 8pt,
    ),
    typography: (
      font: "New Computer Modern Sans",
      math-font: "New Computer Modern Math",
      font-size: 12pt,
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
      page: (x: 1cm, y: 1cm, top: 1cm),
      topic: 5mm,
      section: 1mm,
      cell: 3mm,
    ),
    sizes: (
      title: (height: 7mm, font-size: 13pt),
      header: (height: 7mm, font-size: 11pt),
      border: 2pt,
      radius: 12pt,
    ),
    typography: (
      font: "New Computer Modern Sans",
      math-font: "New Computer Modern Math",
      font-size: 12pt,
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
      page: (x: 1cm, y: 1cm, top: 1cm),
      topic: 3mm,
      section: 0mm,
      cell: 2mm,
    ),
    sizes: (
      title: (height: 6mm, font-size: 11pt),
      header: (height: 6mm, font-size: 10pt),
      border: 1pt,
      radius: 6pt,
    ),
    typography: (
      font: "New Computer Modern Sans",
      math-font: "New Computer Modern Math",
      font-size: 11pt,
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
      page: (x: 1cm, y: 1cm, top: 1cm),
      topic: 4mm,
      section: 0mm,
      cell: 2mm,
    ),
    sizes: (
      title: (height: 6mm, font-size: 11pt),
      header: (height: 5.5mm, font-size: 9pt),
      border: 1pt,
      radius: 10pt,
    ),
    typography: (
      font: "New Computer Modern Sans",
      math-font: "New Computer Modern Math",
      font-size: 12pt,
      weights: (title: "bold", header: "bold"),
    ),
  ),
)
