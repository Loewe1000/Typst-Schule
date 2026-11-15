// Kreisdiagramm.
#import "@preview/cetz:0.4.2": canvas
#import "@preview/cetz-plot:0.1.3": chart
#import "internal/check.typ": fail, check-named, check-value, check-type, check-positional, show-value

// Zehn Farben für die Segmente.
#let palette = (
  rgb("#4E9DC1"), // Blau
  rgb("#E1734D"), // Orange
  rgb("#90C370"), // Grün
  rgb("#847DA7"), // Violett
  rgb("#F5C55A"), // Gelb
  rgb("#E17D9D"), // Rosa
  rgb("#5BBFB3"), // Türkis
  rgb("#D4A574"), // Sand
  rgb("#9B9B9B"), // Grau
  rgb("#B48EAD"), // Lavendel
)

// Lage der Legende → Einstellungen von cetz-plot.
#let legend-settings = (
  right: (orientation: ttb, position: "east", anchor: "west", padding: 0.5, item: (spacing: .2)),
  left: (orientation: ttb, position: "west", anchor: "east", padding: 0.5, item: (spacing: .2)),
  top: (orientation: ltr, position: "north", anchor: "south", padding: 0.5, item: (spacing: .2)),
  bottom: (orientation: ltr, position: "south", anchor: "north", padding: 0.5, item: (spacing: .2)),
)

#let stop(message) = fail("mathematik", "kreisdiagramm", message)

// Alte Parameter, deren Abhilfe vom Wert abhängt. `legend` ist der neue
// Schalter, kann aber noch einen alten Wert tragen.
#let check-old-arguments(named, legend) = {
  let shown(name, value) = "`" + name + ": " + show-value(value) + "`"

  let old-positions = (r: "right", l: "left", t: "top", b: "bottom")
  if type(legend) == str {
    if legend in old-positions {
      stop(shown("legend", legend) + " heißt jetzt `legend-position: \"" + old-positions.at(legend) + "\"`")
    }
    stop(
      shown("legend", legend)
        + " – `legend` ist ein Schalter (`true` oder `false`), die Lage steht in `legend-position: \"right\"`, `\"left\"`, `\"top\"` oder `\"bottom\"`",
    )
  }
  if legend == none {
    stop("`legend: none` gibt es nicht mehr – Argument löschen (die Legende steht rechts) oder `legend: false` schreiben")
  }
  if type(legend) == dictionary {
    stop(
      "`legend` als Dictionary gibt es nicht mehr – `legend: true` und `legend-position: \"right\"`, `\"left\"`, `\"top\"` oder `\"bottom\"` schreiben",
    )
  }
  if "mode" in named {
    let mode = named.mode
    if mode == "percent" { stop(shown("mode", mode) + " heißt jetzt `percent: true`") }
    if mode == "absolute" { stop(shown("mode", mode) + " heißt jetzt `percent: false`") }
  }
  if "radius" in named and type(named.radius) in (int, float) {
    stop(
      shown("radius", named.radius)
        + " heißt jetzt `width: "
        + str(calc.round(2 * named.radius, digits: 3))
        + "cm` (der Durchmesser als Länge)",
    )
  }
}

/// Setzt ein Kreisdiagramm aus Paaren `(Beschriftung, Wert)`.
///
/// ```typ
/// #kreisdiagramm(
///   (("Äpfel", 35), ("Birnen", 45), ("Kirschen", 20)),
///   legend-position: "bottom",
/// )
/// ```
///
/// - items (array): Segmente als Array aus Paaren `(Beschriftung, Wert)`
/// - legend (bool): Legende zeigen
/// - legend-position (str): Lage der Legende: `"right"`, `"left"`, `"top"` oder `"bottom"`
/// - labeled (bool): den Wert auf jedes Segment schreiben
/// - percent (bool): hinter den Wert ein Prozentzeichen setzen; die Werte selbst werden nicht umgerechnet
/// - text-fill (color): Textfarbe der Werte auf den Segmenten
/// - accents (auto, array): Farben der Segmente der Reihe nach; `auto` = Palette des Pakets
/// - stroke (none, length, color, stroke, dictionary): Rand der Segmente
/// - width (length): Durchmesser des Kreises
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> content
#let kreisdiagramm(
  items,
  legend: true,
  legend-position: "right",
  labeled: true,
  percent: true,
  text-fill: black,
  accents: auto,
  stroke: black,
  width: 5cm,
  ..deprecated,
) = {
  check-positional(
    "mathematik",
    "kreisdiagramm",
    deprecated,
    hint: "alle Segmente in ein Array setzen: `kreisdiagramm(((\"A\", 30), (\"B\", 70)))`",
  )
  check-old-arguments(deprecated.named(), legend)
  check-named(
    "mathematik",
    "kreisdiagramm",
    deprecated,
    renamed: (
      "show-percentage": "labeled",
      "label-color": "text-fill",
      mode: "percent",
      colors: "accents",
      "slice-style": "accents",
      radius: "width",
    ),
    removed: (
      gap: "die Segmente liegen ohne Lücke aneinander",
      "value-key": "`items` sind immer Paare `(Beschriftung, Wert)`",
      "label-key": "`items` sind immer Paare `(Beschriftung, Wert)`",
      "inner-label": "`labeled`, `percent` und `text-fill` bestimmen die Beschriftung der Segmente",
      "outer-label": "`labeled`, `percent` und `text-fill` bestimmen die Beschriftung der Segmente",
    ),
    allowed: ("legend", "legend-position", "labeled", "percent", "text-fill", "accents", "stroke", "width"),
  )
  check-type("mathematik", "kreisdiagramm", "items", items, array, example: "((\"Äpfel\", 35), (\"Birnen\", 45))")
  for item in items {
    if type(item) != array or item.len() != 2 or type(item.at(1)) not in (int, float) {
      stop(
        "Eintrag `"
          + show-value(item)
          + "` in `items` ist kein Paar aus Beschriftung und Zahl – zum Beispiel `(\"Äpfel\", 35)`",
      )
    }
  }
  check-type("mathematik", "kreisdiagramm", "legend", legend, bool)
  check-value(
    "mathematik",
    "kreisdiagramm",
    "legend-position",
    legend-position,
    legend-settings.keys(),
    renamed: (r: "right", l: "left", t: "top", b: "bottom"),
  )
  check-type("mathematik", "kreisdiagramm", "labeled", labeled, bool)
  check-type("mathematik", "kreisdiagramm", "percent", percent, bool)
  check-type("mathematik", "kreisdiagramm", "text-fill", text-fill, color)
  check-type("mathematik", "kreisdiagramm", "accents", accents, (array, auto), example: "(blue, red, green)")
  check-type("mathematik", "kreisdiagramm", "stroke", stroke, (length, color, std.stroke, dictionary, none), example: "black")
  check-type("mathematik", "kreisdiagramm", "width", width, length, example: "5cm")
  if width.em != 0 {
    stop("`width: " + show-value(width) + "` – eine Länge ohne `em` angeben, zum Beispiel `5cm`")
  }

  let inner-label = if not labeled {
    (content: none)
  } else if percent {
    (content: (value, label) => [#text(text-fill, str(value) + "%")], radius: 130%)
  } else {
    (content: (value, label) => [#text(text-fill, str(value))], radius: 130%)
  }

  canvas({
    chart.piechart(
      items,
      value-key: 1,
      label-key: 0,
      // Ohne Beschriftung setzt cetz-plot keine Legende.
      legend: if legend { legend-settings.at(legend-position) } else { (label: none) },
      stroke: stroke,
      radius: width / 2cm,
      gap: 0,
      slice-style: if accents == auto { palette } else { accents },
      inner-label: inner-label,
      outer-label: (content: none),
    )
  })
}
