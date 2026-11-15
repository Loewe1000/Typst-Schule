#import "@preview/cetz:0.5.2": canvas
#import "internal/check.typ": fail, check-named, check-value, check-type, check-positional, show-value
#import "internal.typ": normalize-labels, resolve-layout, resolve-style, energy-column

/// Zeichnet Energiekonten: je Energieform eine karierte Spalte mit Linie und Beschriftung darunter.
///
/// Das Raster jeder Spalte hat immer zehn Zeilen; Spaltenbreite, Strichstärken
/// und Schriftgröße folgen aus der Höhe. Gezeichnet wird mit CeTZ.
///
/// ```typ
/// #energy-sketch(($E_"kin"$, $E_"pot"$, $E_"ges"$), height: 5cm)
/// ```
///
/// - labels (array): Beschriftungen der Spalten, je Spalte ein Eintrag (Inhalt, Text oder `none`). Mindestens ein Eintrag.
/// - labeled (bool): Setzt die Beschriftungen unter die Spalten. Mit `false` bleiben nur die Linien stehen, etwa damit die Klasse die Energieformen selbst einträgt.
/// - height (length): Höhe des Rasters, größer als `0pt`.
/// - gutter (length): Abstand zwischen zwei Spalten, mindestens `0pt`.
/// - ..deprecated (arguments): Fängt alte Namen ab (`hide-letters`, `gap`) und meldet den neuen; nimmt nichts an.
/// -> content
#let energy-sketch(
  labels,
  labeled: true,
  height: 3cm,
  gutter: 0pt,
  ..deprecated,
) = {
  // 1. Sink: Positionsargumente, alte Werte, alte und unbekannte Namen
  check-positional("energy-sketch", "energy-sketch", deprecated,
    hint: "alle Beschriftungen in ein Array schreiben: `energy-sketch((\"A\", \"B\"))`")
  let old = deprecated.named()
  // Alt und neu zugleich: der neue Name ist ein deklarierter Parameter und
  // landet nicht im Sink; erkennbar ist das nur, wenn er von der Vorgabe abweicht.
  if "gap" in old and gutter != 0pt {
    fail("energy-sketch", "energy-sketch", "`gap` (alt) und `gutter` (neu) zugleich – nur `gutter` schreiben")
  }
  if "hide-letters" in old and labeled != true {
    fail("energy-sketch", "energy-sketch", "`hide-letters` (alt) und `labeled` (neu) zugleich – nur `labeled` schreiben")
  }
  if "hide-letters" in old and type(old.at("hide-letters")) == bool {
    check-value("energy-sketch", "energy-sketch", "hide-letters", old.at("hide-letters"), (),
      renamed: ("true": (labeled: false), "false": (labeled: true)))
  }
  check-named("energy-sketch", "energy-sketch", deprecated,
    renamed: ("hide-letters": "labeled", gap: "gutter"),
    allowed: ("labeled", "height", "gutter"))

  // 2. Typen und Wertebereiche
  let labels = normalize-labels(labels)
  check-type("energy-sketch", "energy-sketch", "labeled", labeled, bool)
  check-type("energy-sketch", "energy-sketch", "height", height, length, example: "3cm")
  if height <= 0pt {
    fail("energy-sketch", "energy-sketch",
      "`height: " + show-value(height) + "` ist nicht größer als `0pt` – eine positive Länge angeben, zum Beispiel `3cm`")
  }
  check-type("energy-sketch", "energy-sketch", "gutter", gutter, length, example: "6pt")
  if gutter < 0pt {
    fail("energy-sketch", "energy-sketch",
      "`gutter: " + show-value(gutter) + "` ist negativ – `0pt` oder eine positive Länge angeben, zum Beispiel `6pt`")
  }

  let layout = resolve-layout(labels.len(), height, gutter: gutter)
  let style = resolve-style(layout)

  canvas({
    for (column-index, label) in labels.enumerate() {
      energy-column(
        layout,
        style,
        column-index,
        label,
        labeled: labeled,
      )
    }
  })
}
