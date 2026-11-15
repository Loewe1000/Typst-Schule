// =============================================================================
// summify 0.5.0 – Zusammenfassungen und Spickzettel im Raster
// =============================================================================
#import "internal/check.typ": fail, check-named, check-value, check-type, check-not-empty, check-positional
#import "internal.typ": visible-state, theme-state, check-theme-keys, apply-theme-overrides
#import "themes.typ": themes

// Typen, die mehrere Parameter gemeinsam haben.
#let fill-types = (color, gradient, tiling, none, auto)

// Prüft ein Maß: Länge, Anteil oder beides zusammen, dazu die Typen aus `more`.
#let check-size(function, name, value, more: (), example: none) = {
  if type(value) not in (length, ratio) {
    check-type("summify", function, name, value, (relative, ..more), example: example)
  }
}

// -----------------------------------------------------------------------------
// Thema
// -----------------------------------------------------------------------------

/// Setzt das aktive Farbthema.
///
/// Wählt ein vordefiniertes Thema über seinen Namen oder setzt ein eigenes,
/// vollständiges Thema-Dictionary (Gestalt wie ein Eintrag von `themes`).
///
/// ```typ
/// #set-theme("modern-blue")
/// ```
///
/// - theme (str, dictionary): Name eines Themas aus `themes` oder ein vollständiges Thema-Dictionary
/// -> content
#let set-theme(theme) = {
  check-value("summify", "set-theme", "theme", theme, (..themes.keys(), dictionary))
  if type(theme) == str {
    theme-state.update(themes.at(theme))
  } else {
    check-theme-keys("set-theme", "theme", theme, themes.default, complete: true)
    theme-state.update(theme)
  }
}

/// Überschreibt einzelne Werte des aktiven Themas.
///
/// Jede Gruppe ist ein Teil-Dictionary; nur die genannten Schlüssel ändern
/// sich, alle anderen bleiben, wie das aktive Thema sie setzt.
///
/// ```typ
/// #set-theme-overrides(colors: (primary: red), sizes: (radius: 0pt))
/// ```
///
/// - colors (dictionary): Farben: `primary`, `on-primary`, `surface`, `border`
/// - spacing (dictionary): Abstände: `page` (`x`, `y`, `top`), `topic`, `section`, `cell`
/// - sizes (dictionary): Maße: `title` und `header` (je `height`, `font-size`), `border`, `radius`
/// - typography (dictionary): Schrift: `font`, `math-font`, `font-size`, `weights` (`title`, `header`)
/// - ..deprecated (arguments): fängt alte und unbekannte Namen ab, nimmt nichts an
/// -> content
#let set-theme-overrides(
  colors: (:),
  spacing: (:),
  sizes: (:),
  typography: (:),
  ..deprecated,
) = {
  check-positional("summify", "set-theme-overrides", deprecated,
    hint: "die Gruppen benannt schreiben, zum Beispiel `set-theme-overrides(colors: (primary: red))`")
  check-named("summify", "set-theme-overrides", deprecated,
    allowed: ("colors", "spacing", "sizes", "typography"))
  apply-theme-overrides("set-theme-overrides", "set-theme-overrides", (
    colors: colors,
    spacing: spacing,
    sizes: sizes,
    typography: typography,
  ))
}

// -----------------------------------------------------------------------------
// Vorlage
// -----------------------------------------------------------------------------

/// Richtet eine Zusammenfassung im Rasterformat ein.
///
/// Setzt Seite, Schrift und Thema. Der Inhalt füllt genau eine Seite und wird
/// mit `beside`, `below`, `topic`, `section` und `cell` gegliedert. Gedacht
/// für `#show: summify.with(…)`.
///
/// ```typ
/// #show: summify.with(title: [Mechanik], theme: "modern-blue")
///
/// #beside[
///   #topic(title: [Kinematik])[#cell[$s = v dot t$]]
/// ][
///   #topic(title: [Dynamik])[#cell[$F = m dot a$]]
/// ]
/// ```
///
/// - title (content, str, none): Titel in der Kopfzeile; `none` lässt die Kopfzeile leer
/// - paper (str): Papierformat wie bei `page`
/// - landscape (bool): Querformat
/// - visible (bool): Inhalte der Zellen zeigen; `false` blendet sie aus (Lernmodus), der Platz bleibt frei
/// - theme (str, dictionary, none): Name eines Themas aus `themes` oder ein vollständiges Thema-Dictionary; `none` lässt das aktive Thema stehen
/// - theme-overrides (dictionary): einzelne Werte, die über das Thema gelegt werden, mit den Gruppen `colors`, `spacing`, `sizes`, `typography`
/// - ..deprecated (arguments): fängt alte und unbekannte Namen ab, nimmt nichts an
/// - body (content): Inhalt der Zusammenfassung
/// -> content
#let summify(
  title: none,
  paper: "a3",
  landscape: true,
  visible: true,
  theme: "default",
  theme-overrides: (:),
  ..deprecated,
  body,
) = {
  check-positional("summify", "summify", deprecated,
    hint: "nur der Inhalt steht ohne Namen, alles andere benannt (`title: [...]`)")
  let old-hide = deprecated.named().at("hide-content", default: none)
  check-named("summify", "summify", deprecated,
    renamed: (
      flipped: "landscape",
      hide-content: "visible" + if type(old-hide) == bool { ": " + repr(not old-hide) } else { "" },
    ),
    allowed: ("title", "paper", "landscape", "visible", "theme", "theme-overrides"))
  check-not-empty("summify", "summify", "title", title, "kein Titel")
  check-type("summify", "summify", "title", title, (content, str, none))
  check-type("summify", "summify", "paper", paper, str, example: "\"a4\"")
  check-type("summify", "summify", "landscape", landscape, bool)
  check-type("summify", "summify", "visible", visible, bool)
  check-value("summify", "summify", "theme", theme, (none, ..themes.keys(), dictionary))
  if type(theme) == dictionary {
    check-theme-keys("summify", "theme", theme, themes.default, complete: true)
  }
  check-theme-keys("summify", "theme-overrides", theme-overrides, themes.default)

  context {
    // Thema setzen, falls angegeben
    if theme != none {
      set-theme(theme)
    }

    // Überschreibungen über das Thema legen
    if theme-overrides != (:) {
      apply-theme-overrides("summify", "theme-overrides", theme-overrides)
    }

    let theme-config = theme-state.get()

    set text(
      size: theme-config.typography.font-size,
      font: theme-config.typography.font,
      hyphenate: true,
    )

    set par(justify: true)

    show math.equation: set text(font: theme-config.typography.math-font)

    set page(
      paper,
      flipped: landscape,
      margin: (
        top: theme-config.spacing.page.top,
        x: theme-config.spacing.page.x,
        y: theme-config.spacing.page.y,
      ),
      header-ascent: 0mm,
      header: std.align(
        center + horizon,
        text(
          20pt,
          weight: theme-config.typography.weights.title,
          title,
        ),
      ),
    )

    visible-state.update(visible)

    box(height: 100%, width: 100%, body)
  }
}

// -----------------------------------------------------------------------------
// Anordnung im Raster
// -----------------------------------------------------------------------------

// Prüft die gemeinsamen Parameter der Anordnungsfunktionen. `lines-hint` ist
// die Abhilfe für das alte `lines:` bei den Funktionen ohne `dividers`; in
// 0.1.0 reichten sie den Namen ungenannt an `compose` durch.
#let check-arrangement(function, gutter, ratios, cells, allowed, lines-hint: none) = {
  if "dividers" in allowed {
    check-named("summify", function, cells,
      renamed: (gap: "gutter", lines: "dividers"),
      allowed: allowed)
  } else {
    check-named("summify", function, cells,
      renamed: (gap: "gutter"),
      removed: (lines: lines-hint),
      allowed: allowed)
  }
  check-size(function, "gutter", gutter, more: (fraction, auto), example: "2mm")
  // wie `columns`/`rows` von `grid`: Liste, Anzahl oder ein einzelnes Maß
  check-type("summify", function, "ratios", ratios,
    (array, int, length, ratio, relative, fraction, auto, none), example: "(2fr, 1fr)")
}

/// Ordnet Inhalte in einem Raster nebeneinander oder untereinander an.
///
/// Grundlage für `beside`, `below`, `cell-columns` und `cell-rows`: die
/// Richtung ist wählbar, Trennlinien lassen sich zuschalten.
///
/// ```typ
/// #cell-grid(direction: "horizontal", dividers: true)[Links][Rechts]
/// ```
///
/// - direction (str): Richtung: `"horizontal"` (nebeneinander) oder `"vertical"` (untereinander)
/// - dividers (bool): Trennlinien zwischen den Inhalten
/// - gutter (length, relative, fraction, auto): Abstand zwischen den Inhalten; `auto` nimmt `spacing.topic` aus dem Thema
/// - ratios (array, int, length, relative, fraction, auto, none): Spaltenbreiten oder Zeilenhöhen wie `columns` und `rows` von `grid`, zum Beispiel `(2fr, 1fr)`; `none` teilt gleichmäßig
/// - ..cells (content): die anzuordnenden Inhalte
/// -> content
#let cell-grid(
  direction: "horizontal",
  dividers: false,
  gutter: auto,
  ratios: none,
  ..cells,
) = {
  check-arrangement("cell-grid", gutter, ratios, cells, ("direction", "dividers", "gutter", "ratios"))
  check-value("summify", "cell-grid", "direction", direction, ("horizontal", "vertical"))
  check-type("summify", "cell-grid", "dividers", dividers, bool)

  context {
    let theme = theme-state.get()
    let items = cells.pos()

    let count = items.len()

    let (columns, rows) = if direction == "horizontal" {
      (if ratios == none { count * (1fr,) } else { ratios }, auto)
    } else {
      (auto, if ratios == none { count * (1fr,) } else { ratios })
    }

    let gutter-value = if gutter == auto { theme.spacing.topic } else { gutter }

    // Trennlinien zwischen den Inhalten einfügen
    let items-with-lines = ()
    for (i, item) in items.enumerate() {
      items-with-lines.push(item)
      if direction == "horizontal" and dividers and i < count - 1 {
        items-with-lines.push(grid.vline())
      }
      if direction == "vertical" and dividers and i < count - 1 {
        items-with-lines.push(grid.hline())
      }
    }

    grid(
      columns: columns,
      rows: rows,
      inset: (x: 0.25pt, y: 0pt),
      column-gutter: if direction == "horizontal" { gutter-value } else { 0pt },
      row-gutter: if direction == "vertical" { gutter-value } else { 0pt },
      ..items-with-lines
    )
  }
}

/// Ordnet Inhalte nebeneinander an, ohne Trennlinien.
///
/// Gedacht für Themenboxen (`topic`).
///
/// ```typ
/// #beside(ratios: (1fr, 2fr))[Links][Rechts]
/// ```
///
/// - gutter (length, relative, fraction, auto): Abstand zwischen den Inhalten; `auto` nimmt `spacing.topic` aus dem Thema
/// - ratios (array, int, length, relative, fraction, auto, none): Spaltenbreiten wie `columns` von `grid`; `none` teilt gleichmäßig
/// - ..cells (content): die anzuordnenden Inhalte
/// -> content
#let beside(gutter: auto, ratios: none, ..cells) = {
  check-arrangement("beside", gutter, ratios, cells, ("gutter", "ratios"),
    lines-hint: "Trennlinien setzt `cell-grid(direction: \"horizontal\", dividers: true)`")
  cell-grid(direction: "horizontal", gutter: gutter, ratios: ratios, ..cells.pos())
}

/// Ordnet Inhalte untereinander an, ohne Trennlinien.
///
/// Gedacht für Themenboxen (`topic`).
///
/// ```typ
/// #below(ratios: (auto, 1fr))[Oben][Unten]
/// ```
///
/// - gutter (length, relative, fraction, auto): Abstand zwischen den Inhalten; `auto` nimmt `spacing.topic` aus dem Thema
/// - ratios (array, int, length, relative, fraction, auto, none): Zeilenhöhen wie `rows` von `grid`; `none` teilt gleichmäßig
/// - ..cells (content): die anzuordnenden Inhalte
/// -> content
#let below(gutter: auto, ratios: none, ..cells) = {
  check-arrangement("below", gutter, ratios, cells, ("gutter", "ratios"),
    lines-hint: "Trennlinien setzt `cell-grid(direction: \"vertical\", dividers: true)`")
  cell-grid(direction: "vertical", gutter: gutter, ratios: ratios, ..cells.pos())
}

/// Ordnet Zellen nebeneinander an, mit Trennlinien dazwischen.
///
/// Gedacht für Zellen (`cell`) innerhalb einer Themenbox.
///
/// ```typ
/// #cell-columns(ratios: (1fr, 1fr))[#cell[Links]][#cell[Rechts]]
/// ```
///
/// - gutter (length, relative, fraction, auto): Abstand zwischen den Zellen; `auto` nimmt `spacing.section` aus dem Thema
/// - ratios (array, int, length, relative, fraction, auto, none): Spaltenbreiten wie `columns` von `grid`; `none` teilt gleichmäßig
/// - ..cells (content): die anzuordnenden Zellen
/// -> content
#let cell-columns(gutter: auto, ratios: none, ..cells) = {
  check-arrangement("cell-columns", gutter, ratios, cells, ("gutter", "ratios"),
    lines-hint: "`cell-columns` setzt immer Trennlinien; ohne sie `cell-grid(direction: \"horizontal\")` schreiben")
  context {
    let gutter-value = if gutter == auto { theme-state.get().spacing.section } else { gutter }
    cell-grid(direction: "horizontal", gutter: gutter-value, ratios: ratios, dividers: true, ..cells.pos())
  }
}

/// Ordnet Zellen untereinander an, mit Trennlinien dazwischen.
///
/// Gedacht für Zellen (`cell`) innerhalb einer Themenbox.
///
/// ```typ
/// #cell-rows[#cell[Oben]][#cell[Unten]]
/// ```
///
/// - gutter (length, relative, fraction, auto): Abstand zwischen den Zellen; `auto` nimmt `spacing.section` aus dem Thema
/// - ratios (array, int, length, relative, fraction, auto, none): Zeilenhöhen wie `rows` von `grid`; `none` teilt gleichmäßig
/// - ..cells (content): die anzuordnenden Zellen
/// -> content
#let cell-rows(gutter: auto, ratios: none, ..cells) = {
  check-arrangement("cell-rows", gutter, ratios, cells, ("gutter", "ratios"),
    lines-hint: "`cell-rows` setzt immer Trennlinien; ohne sie `cell-grid(direction: \"vertical\")` schreiben")
  context {
    let gutter-value = if gutter == auto { theme-state.get().spacing.section } else { gutter }
    cell-grid(direction: "vertical", gutter: gutter-value, ratios: ratios, dividers: true, ..cells.pos())
  }
}

// -----------------------------------------------------------------------------
// Inhaltsblöcke
// -----------------------------------------------------------------------------

/// Themenbox mit farbiger Titelleiste.
///
/// Rahmen für einen thematischen Bereich der Zusammenfassung: oben ein
/// farbiger Reiter mit dem Titel, darunter der umrandete Inhalt.
///
/// ```typ
/// #topic(title: [Kinematik])[#cell[Inhalt]]
/// ```
///
/// - title (content, str, none): Titel im Reiter; `none` lässt den Reiter weg
/// - height (length, relative): Höhe der Box samt Reiter
/// - width (length, relative, fraction, auto): Breite des Inhaltsbereichs
/// - fill (color, gradient, tiling, none, auto): Füllung des Reiters; `auto` nimmt `colors.primary` aus dem Thema
/// - stroke (stroke, length, color, dictionary, none, auto): Rahmenlinie; `auto` nimmt `colors.border` und `sizes.border` aus dem Thema
/// - radius (length, relative, dictionary, auto): Eckenradius; `auto` nimmt `sizes.radius` aus dem Thema. Ein Dictionary mit einzelnen Ecken (wie bei `box`) geht nur ohne `title`
/// - ..deprecated (arguments): fängt alte und unbekannte Namen ab, nimmt nichts an
/// - body (content): Inhalt der Themenbox
/// -> content
#let topic(
  title: none,
  height: 100%,
  width: 100%,
  fill: auto,
  stroke: auto,
  radius: auto,
  ..deprecated,
  body,
) = {
  check-positional("summify", "topic", deprecated,
    hint: "Titel als zweites Inhaltsargument – `topic(title: [...])[...]` schreiben")
  check-named("summify", "topic", deprecated,
    allowed: ("title", "height", "width", "fill", "stroke", "radius"))
  check-not-empty("summify", "topic", "title", title, "kein Titel")
  check-type("summify", "topic", "title", title, (content, str, none))
  check-size("topic", "height", height, example: "10cm")
  check-size("topic", "width", width, more: (fraction, auto))
  check-type("summify", "topic", "fill", fill, fill-types)
  check-type("summify", "topic", "stroke", stroke,
    (std.stroke, length, color, gradient, tiling, dictionary, none, auto), example: "1pt + black")
  check-size("topic", "radius", radius, more: (dictionary, auto), example: "4pt")
  if title != none and type(radius) == dictionary {
    fail("summify", "topic",
      "`radius` als Dictionary neben `title` – mit Titel ein einzelnes Maß angeben, zum Beispiel `radius: 4pt`")
  }

  context {
    let theme = theme-state.get()

    let fill-value = if fill == auto { theme.colors.primary } else { fill }
    let stroke-value = if stroke == auto { theme.colors.border + theme.sizes.border } else { stroke }
    let radius-value = if radius == auto { theme.sizes.radius } else { radius }
    let title-height = theme.sizes.title.height

    // Höhe des Inhaltsbereichs ohne den Reiter
    let body-height = height - if title != none { title-height } else { 0pt }

    if title != none {
      // Reiter und Inhalt lückenlos übereinander
      stack(
        dir: ttb,
        spacing: 0pt,
        box(
          fill: fill-value,
          height: title-height,
          width: auto,
          stroke: stroke-value,
          radius: (top-left: radius-value, top-right: radius-value),
          inset: (left: 3mm, right: 3mm, y: 1mm),
          std.align(left + horizon, text(
            fill: theme.colors.on-primary,
            theme.sizes.title.font-size,
            weight: theme.typography.weights.title,
            title,
          )),
        ),
        box(
          width: width,
          height: body-height,
          stroke: stroke-value,
          radius: (bottom-left: radius-value, bottom-right: radius-value, top-right: radius-value),
          clip: true,
          body,
        ),
      )
    } else {
      // Ohne Titel nur der Inhaltsbereich
      box(
        width: width,
        height: height,
        stroke: stroke-value,
        radius: radius-value,
        clip: true,
        body,
      )
    }
  }
}

/// Abschnittsüberschrift innerhalb einer Themenbox.
///
/// Setzt eine farbige Leiste über die volle Breite mit der Beschriftung.
///
/// ```typ
/// #section[Gleichförmige Bewegung]
/// ```
///
/// - fill (color, gradient, tiling, none, auto): Füllung der Leiste; `auto` nimmt `colors.surface` aus dem Thema
/// - height (length, relative, fraction, auto): Höhe der Leiste; `auto` nimmt `sizes.header.height` aus dem Thema
/// - ..deprecated (arguments): fängt alte und unbekannte Namen ab, nimmt nichts an
/// - body (content, str, none): Beschriftung des Abschnitts; `none` setzt eine leere Leiste
/// -> content
#let section(fill: auto, height: auto, ..deprecated, body) = {
  check-positional("summify", "section", deprecated,
    hint: "nur die Beschriftung steht ohne Namen – der Inhalt des Abschnitts folgt danach in `cell[...]`")
  if "title" in deprecated.named() {
    fail("summify", "section", "Beschriftung als `title:` – `section[...]` schreiben")
  }
  check-named("summify", "section", deprecated, allowed: ("fill", "height"))
  check-type("summify", "section", "fill", fill, fill-types)
  check-size("section", "height", height, more: (fraction, auto), example: "6mm")
  check-type("summify", "section", "body", body, (content, str, none), example: "[Text]")

  context {
    let theme = theme-state.get()

    let fill-value = if fill == auto { theme.colors.surface } else { fill }
    let height-value = if height == auto { theme.sizes.header.height } else { height }

    rect(
      width: 100%,
      height: height-value,
      fill: fill-value,
      stroke: (bottom: 1pt, top: 1pt),
      inset: (left: 2mm, right: 2mm),
      std.align(left + horizon, text(
        size: theme.sizes.header.font-size,
        weight: theme.typography.weights.header,
        body,
      )),
    )
  }
}

/// Zelle mit Inhalt innerhalb einer Themenbox.
///
/// Setzt den Inhalt mit Innenabstand, auf Wunsch unter einer eigenen
/// Abschnittsüberschrift. Im Lernmodus (`visible: false`) bleibt der Platz
/// frei, die Überschrift bleibt stehen.
///
/// ```typ
/// #cell(title: [Formel])[$ v = s / t $]
/// ```
///
/// - title (content, str, none): Überschrift der Zelle, gesetzt wie `section`; `none` lässt sie weg
/// - inset (length, relative, dictionary, auto): Innenabstand; `auto` nimmt `spacing.cell` aus dem Thema
/// - align (alignment): waagerechte Ausrichtung des Inhalts
/// - visible (bool, auto): Inhalt zeigen; `auto` folgt `visible` von `summify`
/// - ..deprecated (arguments): fängt alte und unbekannte Namen ab, nimmt nichts an
/// - body (content): Inhalt der Zelle
/// -> content
#let cell(
  title: none,
  inset: auto,
  align: left,
  visible: auto,
  ..deprecated,
  body,
) = {
  check-positional("summify", "cell", deprecated,
    hint: "Überschrift als zweites Inhaltsargument – `cell(title: [...])[...]` schreiben")
  let old = deprecated.named()
  let old-hide = old.at("hide", default: auto)
  check-named("summify", "cell", deprecated,
    renamed: (
      align-content: "align",
      hide: "visible: " + if type(old-hide) == bool { repr(not old-hide) } else { "auto" },
    ),
    allowed: ("title", "inset", "align", "visible"))
  check-not-empty("summify", "cell", "title", title, "keine Überschrift")
  check-type("summify", "cell", "title", title, (content, str, none))
  check-size("cell", "inset", inset, more: (dictionary, auto), example: "2mm")
  check-type("summify", "cell", "align", align, alignment)
  check-type("summify", "cell", "visible", visible, (bool, auto), example: "false")

  context {
    let theme = theme-state.get()
    let inset-value = if inset == auto { theme.spacing.cell } else { inset }
    let shown = if visible == auto { visible-state.get() } else { visible }

    let body-box = box(
      inset: inset-value,
      width: 100%,
      stroke: none,
      std.align(horizon + align, body),
    )
    if not shown {
      body-box = hide(body-box)
    }

    // Als Rasterzelle zurückgeben; mit Überschrift liegt ein eigenes Raster darin
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
