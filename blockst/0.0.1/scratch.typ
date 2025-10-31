// ================================================================
// Scratch-Blöcke für Typst
//
// Dieses Paket rendert Scratch-ähnliche Blöcke und Reporter in Typst.
// Die Darstellung ist global über einen State konfigurierbar (Theme & Linienbreite).
//
// Schnellstart:
//   - Globale Optionen setzen:  #set-scratch(theme: "high-contrast", stroke-width: 1pt)
//   - Blöcke verwenden:         #bewegung[ ... ], #steuerung[ ... ], #ereignis[ ... ] usw.
//   - Reporter/Werte:            #zahl-oder-content(42, colors.bewegung) oder #bewegung-reporter[ ... ]
//
// Inhaltsverzeichnis (Sektionen):
//   1) Konfiguration & State
//   2) Assets & Icons
//   3) Farbpaletten (normal / high-contrast)
//   4) Theme-/Stroke-Helpers
//   5) Hilfsfunktionen für Benutzer (get-colors, get-stroke)
//   6) Geometrie & Layout-Konstanten
//   7) Pill-Primitives (Basis + Varianten)
//   8) Wert-/Content-Helfer
//   9) Blockpfade & Rendering (scratch-block, bedingung)
//  10) Kategorie-Wrapper (bewegung, aussehen, ...)
//  11) Ereignisse
//  12) Reporter (generisch + je Kategorie)
//  13) Kontrollstrukturen (wiederhole, falls, ...)
//  14) Bewegungsblöcke
//  15) Aussehen
//  16) Klang
//  17) Fühlen (Sensoren)
//  18) Variablen
//  19) Listen
//  20) Eigene Blöcke
//  21) Operatoren
// ================================================================

// ------------------------------------------------
// 1) Konfiguration & State
// ------------------------------------------------
// State für globale Scratch-Einstellungen
#let scratch-block-options = state("scratch-block-options", (
  theme: "normal", // "normal" oder "high-contrast"
  stroke-width: auto, // auto oder spezifische Länge (z.B. 1pt)
  scale: 100%, // Skalierung der Blöcke
))

// Funktion zum Setzen der globalen Scratch-Optionen
#let set-scratch(theme: auto, stroke-width: auto, scale: auto) = {
  scratch-block-options.update(current => {
    let new-state = current
    if theme != auto {
      new-state.theme = theme
    }
    if stroke-width != auto {
      new-state.stroke-width = stroke-width
    }
    if scale != auto {
      new-state.scale = scale
    }
    new-state
  })
}

// ------------------------------------------------
// 2) Assets & Icons
// ------------------------------------------------
#let icons = (
  dropdown-arrow: bytes(
    "<svg id=\"Layer_1\" data-name=\"Layer 1\" xmlns=\"http://www.w3.org/2000/svg\" width=\"12.71\" height=\"8.79\" viewBox=\"0 0 12.71 8.79\"><title>dropdown-arrow</title><g opacity=\"0.1\"><path d=\"M12.71,2.44A2.41,2.41,0,0,1,12,4.16L8.08,8.08a2.45,2.45,0,0,1-3.45,0L0.72,4.16A2.42,2.42,0,0,1,0,2.44,2.48,2.48,0,0,1,.71.71C1,0.47,1.43,0,6.36,0S11.75,0.46,12,.71A2.44,2.44,0,0,1,12.71,2.44Z\" fill=\"#231f20\"/></g><path d=\"M6.36,7.79a1.43,1.43,0,0,1-1-.42L1.42,3.45a1.44,1.44,0,0,1,0-2c0.56-.56,9.31-0.56,9.87,0a1.44,1.44,0,0,1,0,2L7.37,7.37A1.43,1.43,0,0,1,6.36,7.79Z\" fill=\"#fff\"/></svg>",
  ),
  rotate-right: bytes(
    "<svg id=\"rotate-counter-clockwise\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><defs><style>.cls-1{fill:#3d79cc;}.cls-2{fill:#fff;}</style></defs><title>rotate-counter-clockwise</title><path class=\"cls-1\" d=\"M22.68,12.2a1.6,1.6,0,0,1-1.27.63H13.72a1.59,1.59,0,0,1-1.16-2.58l1.12-1.41a4.82,4.82,0,0,0-3.14-.77,4.31,4.31,0,0,0-2,.8,4.25,4.25,0,0,0-1.34,1.73,5.06,5.06,0,0,0,.54,4.62A5.58,5.58,0,0,0,12,17.74h0a2.26,2.26,0,0,1-.16,4.52A10.25,10.25,0,0,1,3.74,18,10.14,10.14,0,0,1,2.25,8.78,9.7,9.7,0,0,1,5.08,4.64,9.92,9.92,0,0,1,9.66,2.5a10.66,10.66,0,0,1,7.72,1.68l1.08-1.35a1.57,1.57,0,0,1,1.24-.6,1.6,1.6,0,0,1,1.54,1.21l1.7,7.37A1.57,1.57,0,0,1,22.68,12.2Z\"/><path class=\"cls-2\" d=\"M21.38,11.83H13.77a.59.59,0,0,1-.43-1l1.75-2.19a5.9,5.9,0,0,0-4.7-1.58,5.07,5.07,0,0,0-4.11,3.17A6,6,0,0,0,7,15.77a6.51,6.51,0,0,0,5,2.92,1.31,1.31,0,0,1-.08,2.62,9.3,9.3,0,0,1-7.35-3.82A9.16,9.16,0,0,1,3.17,9.12,8.51,8.51,0,0,1,5.71,5.4,8.76,8.76,0,0,1,9.82,3.48a9.71,9.71,0,0,1,7.75,2.07l1.67-2.1a.59.59,0,0,1,1,.21L22,11.08A.59.59,0,0,1,21.38,11.83Z\"/></svg>",
  ),
  rotate-left: bytes(
    "<svg id=\"rotate-clockwise\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><defs><style>.cls-1{fill:#3d79cc;}.cls-2{fill:#fff;}</style></defs><title>rotate-clockwise</title><path class=\"cls-1\" d=\"M20.34,18.21a10.24,10.24,0,0,1-8.1,4.22,2.26,2.26,0,0,1-.16-4.52h0a5.58,5.58,0,0,0,4.25-2.53,5.06,5.06,0,0,0,.54-4.62A4.25,4.25,0,0,0,15.55,9a4.31,4.31,0,0,0-2-.8A4.82,4.82,0,0,0,10.4,9l1.12,1.41A1.59,1.59,0,0,1,10.36,13H2.67a1.56,1.56,0,0,1-1.26-.63A1.54,1.54,0,0,1,1.13,11L2.85,3.57A1.59,1.59,0,0,1,4.38,2.4,1.57,1.57,0,0,1,5.62,3L6.7,4.35a10.66,10.66,0,0,1,7.72-1.68A9.88,9.88,0,0,1,19,4.81,9.61,9.61,0,0,1,21.83,9,10.08,10.08,0,0,1,20.34,18.21Z\"/><path class=\"cls-2\" d=\"M19.56,17.65a9.29,9.29,0,0,1-7.35,3.83,1.31,1.31,0,0,1-.08-2.62,6.53,6.53,0,0,0,5-2.92,6.05,6.05,0,0,0,.67-5.51,5.32,5.32,0,0,0-1.64-2.16,5.21,5.21,0,0,0-2.48-1A5.86,5.86,0,0,0,9,8.84L10.74,11a.59.59,0,0,1-.43,1H2.7a.6.6,0,0,1-.6-.75L3.81,3.83a.59.59,0,0,1,1-.21l1.67,2.1a9.71,9.71,0,0,1,7.75-2.07,8.84,8.84,0,0,1,4.12,1.92,8.68,8.68,0,0,1,2.54,3.72A9.14,9.14,0,0,1,19.56,17.65Z\"/></svg>",
  ),
  green-flag: bytes(
    "<svg id=\"Layer_1\" data-name=\"Layer 1\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 16.63 17.5\"><defs><style>.cls-1,.cls-2{fill:#4cbf56;stroke:#45993d;stroke-linecap:round;stroke-linejoin:round;}.cls-2{stroke-width:1.5px;}</style></defs><title>icon--green-flag</title><path class=\"cls-1\" d=\"M.75,2A6.44,6.44,0,0,1,8.44,2h0a6.44,6.44,0,0,0,7.69,0V12.4a6.44,6.44,0,0,1-7.69,0h0a6.44,6.44,0,0,0-7.69,0\"/><line class=\"cls-2\" x1=\"0.75\" y1=\"16.75\" x2=\"0.75\" y2=\"0.75\"/></svg>",
  ),
  repeat: bytes(
    "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<!-- Generator: Adobe Illustrator 21.0.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
<svg version=\"1.1\" id=\"repeat\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\"
	 viewBox=\"0 0 24 24\" style=\"enable-background:new 0 0 24 24;\" xml:space=\"preserve\">
<style type=\"text/css\">
	.st0{fill:#CF8B17;}
	.st1{fill:#FFFFFF;}
</style>
<path class=\"st0\" d=\"M23.3,11c-0.3,0.6-0.9,1-1.5,1h-1.6c-0.1,1.3-0.5,2.5-1.1,3.6c-0.9,1.7-2.3,3.2-4.1,4.1
	c-1.7,0.9-3.6,1.2-5.5,0.9c-1.8-0.3-3.5-1.1-4.9-2.3c-0.7-0.7-0.7-1.9,0-2.6c0.6-0.6,1.6-0.7,2.3-0.2H7c0.9,0.6,1.9,0.9,2.9,0.9
	s1.9-0.3,2.7-0.9c1.1-0.8,1.8-2.1,1.8-3.5h-1.5c-0.9,0-1.7-0.7-1.7-1.7c0-0.4,0.2-0.9,0.5-1.2l4.4-4.4c0.7-0.6,1.7-0.6,2.4,0L23,9.2
	C23.5,9.7,23.6,10.4,23.3,11z\"/>
<path class=\"st1\" d=\"M21.8,11h-2.6c0,1.5-0.3,2.9-1,4.2c-0.8,1.6-2.1,2.8-3.7,3.6c-1.5,0.8-3.3,1.1-4.9,0.8c-1.6-0.2-3.2-1-4.4-2.1
	c-0.4-0.3-0.4-0.9-0.1-1.2c0.3-0.4,0.9-0.4,1.2-0.1l0,0c1,0.7,2.2,1.1,3.4,1.1s2.3-0.3,3.3-1c0.9-0.6,1.6-1.5,2-2.6
	c0.3-0.9,0.4-1.8,0.2-2.8h-2.4c-0.4,0-0.7-0.3-0.7-0.7c0-0.2,0.1-0.3,0.2-0.4l4.4-4.4c0.3-0.3,0.7-0.3,0.9,0L22,9.8
	c0.3,0.3,0.4,0.6,0.3,0.9S22,11,21.8,11z\"/>
</svg>
",
  ),
)
// ------------------------------------------------
// 3) Farbpaletten (normal / high-contrast)
// ------------------------------------------------
// Standard Scratch-Farben (mit offizieller Blockly-Namenskonvention)
#let colors-normal = (
  text-color: rgb("#FFFFFF"),
  bewegung: (primary: rgb("#4C97FF"), secondary: rgb("#4280D7"), tertiary: rgb("#3373CC"), quaternary: rgb("#3373CC")),
  aussehen: (primary: rgb("#9966FF"), secondary: rgb("#855CD6"), tertiary: rgb("#774DCB"), quaternary: rgb("#774DCB")),
  klang: (primary: rgb("#CF63CF"), secondary: rgb("#C94FC9"), tertiary: rgb("#BD42BD"), quaternary: rgb("#BD42BD")),
  ereignisse: (primary: rgb("#FFBF00"), secondary: rgb("#E6AC00"), tertiary: rgb("#CC9900"), quaternary: rgb("#CC9900")),
  steuerung: (primary: rgb("#FFAB19"), secondary: rgb("#EC9C13"), tertiary: rgb("#CF8B17"), quaternary: rgb("#CF8B17")),
  fühlen: (primary: rgb("#5CB1D6"), secondary: rgb("#47A8D1"), tertiary: rgb("#2E8EB8"), quaternary: rgb("#2E8EB8")),
  operatoren: (primary: rgb("#59C059"), secondary: rgb("#46B946"), tertiary: rgb("#389438"), quaternary: rgb("#389438")),
  variablen: (primary: rgb("#FF8C1A"), secondary: rgb("#FF8000"), tertiary: rgb("#DB6E00"), quaternary: rgb("#DB6E00")),
  listen: (primary: rgb("#FF661A"), secondary: rgb("#FF5500"), tertiary: rgb("#E64D00"), quaternary: rgb("#E64D00")),
  eigene: (primary: rgb("#FF6680"), secondary: rgb("#FF4D6A"), tertiary: rgb("#FF3355"), quaternary: rgb("#FF3355")),
)

// Hoher Kontrast Variante (Offizielle Scratch High-Contrast-Farben)
#let colors-high-contrast = (
  text-color: rgb("#000000"),
  bewegung: (primary: rgb("#80B5FF"), secondary: rgb("#B3D2FF"), tertiary: rgb("#3373CC"), quaternary: rgb("#CCE1FF")),
  aussehen: (primary: rgb("#CCB3FF"), secondary: rgb("#DDCCFF"), tertiary: rgb("#774DCB"), quaternary: rgb("#EEE5FF")),
  klang: (primary: rgb("#E19DE1"), secondary: rgb("#FFB3FF"), tertiary: rgb("#BD42BD"), quaternary: rgb("#FFCCFF")),
  ereignisse: (primary: rgb("#FFD966"), secondary: rgb("#FFECB3"), tertiary: rgb("#CC9900"), quaternary: rgb("#FFF2CC")),
  steuerung: (primary: rgb("#FFBE4C"), secondary: rgb("#FFDA99"), tertiary: rgb("#CF8B17"), quaternary: rgb("#FFE3B3")),
  fühlen: (primary: rgb("#85C4E0"), secondary: rgb("#AED8EA"), tertiary: rgb("#2E8EB8"), quaternary: rgb("#C2E2F0")),
  operatoren: (primary: rgb("#7ECE7E"), secondary: rgb("#B5E3B5"), tertiary: rgb("#389438"), quaternary: rgb("#DAF1DA")),
  variablen: (primary: rgb("#FFA54C"), secondary: rgb("#FFCC99"), tertiary: rgb("#DB6E00"), quaternary: rgb("#FFE5CC")),
  listen: (primary: rgb("#FF9966"), secondary: rgb("#FFCAB0"), tertiary: rgb("#E64D00"), quaternary: rgb("#FFDDCC")),
  eigene: (primary: rgb("#FF99AA"), secondary: rgb("#FFCCD5"), tertiary: rgb("#FF3355"), quaternary: rgb("#FFE5EA")),
)

// ------------------------------------------------
// 4) Theme-/Stroke-Helpers
// ------------------------------------------------
// Hilfsfunktionen zum Auslesen der Farben und Stroke-Dicke aus den Optionen
#let get-colors-from-options(options) = {
  if options.theme == "high-contrast" {
    colors-high-contrast
  } else {
    colors-normal
  }
}

#let get-stroke-from-options(options) = {
  if options.stroke-width != auto {
    options.stroke-width
  } else if options.theme == "high-contrast" {
    1.0pt
  } else {
    0.5pt
  }
}

// ------------------------------------------------
// 5) Hilfsfunktionen für Benutzer (benötigen context!)
// ------------------------------------------------
// Hilfsfunktion: Gibt das aktuelle colors-Dictionary zurück (benötigt context!)
// Verwendung: #context { let colors = get-colors(); bedingung(colorschema: colors.operatoren)[] }
#let get-colors() = {
  let options = scratch-block-options.get()
  get-colors-from-options(options)
}

// Hilfsfunktion: Gibt die aktuelle Stroke-Dicke zurück (benötigt context!)
#let get-stroke() = {
  let options = scratch-block-options.get()
  get-stroke-from-options(options)
}

// ------------------------------------------------
// 6) Geometrie & Layout-Konstanten
// ------------------------------------------------
// Notch (Auskerbung/Puzzle-Verbinder) Dimensionen
#let notch-height = 1.5mm              // Vertikale Höhe der Auskerbung
#let notch-inner-width = 2.2mm         // Breite des flachen Mittelteils
#let notch-curve-control = 0.75mm      // Bézierkurven-Kontrollpunkt für Rundung
#let notch-spacing = 1.3mm             // Horizontaler Abstand vor/nach Notch
#let notch-total-width = notch-inner-width + 2 * (notch-height + notch-curve-control)  // Gesamtbreite inkl. Kurven
#let notch-reserved-space = notch-inner-width + notch-spacing  // Reservierter Platz in Breitenberechnungen (Approximation)

// Block-Dimensionen
#let block-height = 10mm
#let corner-radius = 0.75mm
#let block-offset-y = 1.5mm  // Vertikaler Offset für Anweisungsblöcke
#let block-left-indent = 5 * corner-radius  // Linker Einzug für Notch (≈3.75mm)

// Hat (Kappe) Dimensionen für Ereignis-Block
#let hat-cp1-x = 4mm
#let hat-cp1-y = 3.1mm
#let hat-cp2-x = 5.2mm

// Pill Dimensionen
#let pill-height = 6mm
#let pill-inset-x = 2.5mm
#let pill-inset-y = 1.25mm
#let pill-spacing = pill-inset-x * 0.66

// Layout
#let content-inset = 5pt

// Notch-Pfade (für Puzzle-Verbinder unten)
#let notch-path = (
  curve.cubic((-notch-curve-control, 0mm), (-notch-height, notch-height), (-notch-height - notch-curve-control, notch-height), relative: true),
  curve.line((-notch-inner-width, 0mm), relative: true),
  curve.cubic((-notch-curve-control, 0mm), (-notch-height, -notch-height), (-notch-height - notch-curve-control, -notch-height), relative: true),
)

// Invertierte Notch-Pfade (für Puzzle-Verbinder oben)
#let inverted-notch-path = (
  curve.cubic((notch-curve-control, 0mm), (notch-height, notch-height), (notch-height + notch-curve-control, notch-height), relative: true),
  curve.line((notch-inner-width, 0mm), relative: true),
  curve.cubic((notch-curve-control, 0mm), (notch-height, -notch-height), (notch-height + notch-curve-control, -notch-height), relative: true),
)

// ------------------------------------------------
// 7) Pill-Primitives (Basis + Varianten)
// ------------------------------------------------
// Interne Basis-Funktion für alle Pills
// Akzeptiert explizite colors und stroke-thickness Parameter
#let _pill-base-internal(
  fill: white,
  stroke: auto,
  text-color: auto,
  radius: 50%,
  inset: 0mm,
  height: auto,
  dropdown: false,
  body,
  colors: colors-normal,
  stroke-thickness: 0.5pt,
) = {
  // Standard-Stroke wenn auto
  let final-stroke = if stroke == auto {
    (paint: black, thickness: stroke-thickness)
  } else {
    stroke
  }

  // Automatische Textfarbe:
  // - Bei expliziter Angabe: verwende die angegebene Farbe
  // - Bei weißem Hintergrund: verwende dunkelgrau (normal) oder schwarz (high-contrast)
  // - Bei farbigem Hintergrund: verwende Theme-Farbe (weiß für normal, schwarz für high-contrast)
  let final-text-color = if text-color != auto {
    text-color
  } else if fill == white or fill == rgb("#FFFFFF") {
    // Weiße Pills brauchen dunkle Schrift
    if colors == colors-high-contrast {
      black // Schwarz bei high-contrast
    } else {
      rgb("#575E75") // Dunkelgrau bei normal
    }
  } else {
    colors.text-color // Theme-Farbe für farbige Hintergründe
  }

  set text(font: "Helvetica Neue", weight: 500)
  box(
    fill: fill,
    stroke: final-stroke,
    radius: radius,
    height: auto,
    inset: inset,
    align(horizon, if dropdown {
      context {
        let height = measure(body).height
        let height = if height < pill-height {
          pill-height
        } else {
          height
        }
        let width = pill-inset-x
        stack(dir: ltr, spacing: pill-spacing, box(height: height, text(final-text-color, body)), image(icons.dropdown-arrow, height: 2mm))
      }
    } else {
      context [
        #let height = measure(body).height
        #let height = if height < pill-height {
          pill-height
        } else {
          height
        }
        #box(height: height, text(final-text-color, body))
      ]
    }),
  )
}

// Öffentliche Basis-Funktion für alle Pills (nutzt State)
#let _pill-base(
  fill: white,
  stroke: auto,
  text-color: auto,
  radius: 50%,
  inset: 0mm,
  height: auto,
  dropdown: false,
  body,
) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  _pill-base-internal(
    fill: fill,
    stroke: stroke,
    text-color: text-color,
    radius: radius,
    inset: inset,
    height: height,
    dropdown: dropdown,
    body,
    colors: colors,
    stroke-thickness: stroke-thickness,
  )
}

// Weiße Input-Pills (feste Höhe 8.4mm, keine Insets)
// Hinweis: Textfarbe wird abhängig von Theme/Hintergrund automatisch gewählt.
#let pill-round(body, stroke: auto, inset: (x: 1.3 * pill-inset-x, y: 1mm), fill: white, text-color: auto) = _pill-base(
  fill: fill,
  stroke: stroke,
  text-color: text-color,
  radius: 50%,
  inset: inset,
  height: auto,
  dropdown: false,
  body,
)

// Farbige Reporter-Pills (auto-höhe, reduzierte Insets, Mindesthöhe 0.8 * block-height)
#let pill-reporter(body, fill: white, stroke: auto, text-color: auto, dropdown: false, inline: false) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  
  // Mindesthöhe für Reporter
  let min-height = 0.8 * block-height
  
  // Body mit Mindesthöhe vorbereiten
  let prepared-body = context {
    let measured = measure(body)
    if measured.height < min-height {
      box(height: min-height, align(horizon, body))
    } else {
      body
    }
  }
  
  _pill-base-internal(
    fill: fill,
    stroke: stroke,
    text-color: text-color,
    radius: 50%,
    inset: if inline {
      (x: pill-inset-x, y: 0.7 * pill-inset-y)
    } else {
      (x: 0.4 * pill-inset-x, y: 0.7 * pill-inset-y)
    },
    height: if inline { 100% } else { auto },
    dropdown: dropdown,
    prepared-body,
    colors: colors,
    stroke-thickness: stroke-thickness,
  )
}

// Rechteckige Dropdown-Pills (auto-höhe, reduzierte Insets)
#let pill-rect(body, fill: white, stroke: auto, text-color: auto, dropdown: false, inline: false) = _pill-base(
  fill: fill,
  stroke: stroke,
  text-color: text-color,
  radius: 10%,
  inset: (x: 0.75 * pill-inset-x, y: if inline { 0mm } else { 0.75 * pill-inset-y }),
  height: 0.5 * pill-height,
  dropdown: dropdown,
  body,
)

// Farb-Pills (für Farbauswahl)
#let pill-color(body, fill: white) = context {
  let options = scratch-block-options.get()
  let stroke-thickness = get-stroke-from-options(options)

  _pill-base(
    fill: fill,
    stroke: white + stroke-thickness,
    text-color: auto,
    radius: 50%,
    inset: 0mm,
    height: 1.2 * pill-height,
    dropdown: false,
    body,
  )
}

// Alte pill() Funktion als Wrapper für Kompatibilität
#let pill(..args, type: "round", stroke: auto, text-color: auto, body, dropdown: false, inset: auto, height: auto, fill: white) = {
  if type == "round" {
    pill-round(body, stroke: stroke, fill: fill, text-color: text-color)
  } else if type == "single" or type == "reporter" {
    pill-reporter(body, fill: fill, stroke: stroke, text-color: text-color, dropdown: dropdown)
  } else if type == "rect" {
    pill-rect(body, fill: fill, stroke: stroke, text-color: text-color, dropdown: dropdown)
  } else if type == "color" {
    pill-color(body, fill: fill)
  }
}
// ------------------------------------------------
// 8) Wert-/Content-Helfer
// ------------------------------------------------
// Helper-Funktion: Wert oder Content
// Wandelt einfache Werte (String, Int, Float) in Pills um,
// lässt Content (Blöcke, Reporter, etc.) unverändert
#let zahl-oder-content(value, colorschema) = {
  let value-type = type(value)
  if value-type == str or value-type == int or value-type == float {
    context {
      let options = scratch-block-options.get()
      let stroke-thickness = get-stroke-from-options(options)

      pill-round(str(value), stroke: colorschema.tertiary + stroke-thickness, inset: (x: 1.3 * pill-inset-x, y: 0.5mm))
    }
  } else {
    value
  }
}

// ------------------------------------------------
// 9) Blockpfade & Rendering (scratch-block, bedingung)
// ------------------------------------------------
#let block-path(height, width, type, top-notch: true, bottom-notch: true) = {
  return (
    ereignis: (
      curve.line((0mm, 0mm), relative: true),
      curve.quad((hat-cp1-x, -hat-cp1-y), (block-height, -hat-cp1-y), relative: true),
      curve.quad((hat-cp2-x, 0mm), (block-height, hat-cp1-y), relative: true),
      curve.line((width - 2 * block-height - corner-radius, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, height - 2 * corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + corner-radius + notch-spacing + notch-total-width, 0mm), relative: true),
      ..notch-path,
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, -corner-radius), relative: true),
      curve.close(),
    ),
    definiere: (
      curve.quad((0mm, -5 * corner-radius), (5 * corner-radius, -5 * corner-radius), relative: true),
      curve.line((width - 10 * corner-radius, 0mm), relative: true),
      curve.quad((5 * corner-radius, 0mm), (5 * corner-radius, 5 * corner-radius), relative: true),
      curve.line((0mm, height - corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + corner-radius + notch-total-width + notch-spacing, 0mm), relative: true),
      ..notch-path,
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, -corner-radius), relative: true),
      curve.close(),
    ),
    anweisung: (
      curve.line((0mm, -block-offset-y + corner-radius), relative: true),
      curve.quad((0mm, -corner-radius), (corner-radius, -corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..if top-notch {
        (inverted-notch-path,)
      } else {
        (curve.line((notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((width - block-left-indent - notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, +block-offset-y - corner-radius), relative: true),
      curve.line((0mm, height - block-offset-y - corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, -corner-radius), relative: true),
      curve.close(),
    ),
    bedingung: (
      curve.move((0.5 * height, 0mm)),
      curve.line((width - 0.5 * height, 0mm), relative: true),
      curve.line((0.5 * height, -0.5 * height), relative: true),
      curve.line((-0.5 * height, -0.5 * height), relative: true),
      curve.line((-width + 0.5 * height, 0mm), relative: true),
      curve.line((-0.5 * height, 0.5 * height), relative: true),
      curve.line((0.5 * height, 0.5 * height), relative: true),
    ),
    loop-header: (
      curve.line((0mm, -block-offset-y + corner-radius), relative: true),
      curve.quad((0mm, -corner-radius), (corner-radius, -corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..inverted-notch-path,
      curve.line((width - block-left-indent - notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, +block-offset-y - corner-radius), relative: true),
      curve.line((0mm, height - block-offset-y - corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + 3 * notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, corner-radius), relative: true),
    ),
    loop-footer: (
      curve.quad((0mm, corner-radius), (corner-radius, corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..inverted-notch-path,
      curve.line((width - block-left-indent - 3 * notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, 3mm), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + 1 * notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, -corner-radius), relative: true),
      curve.close(),
    ),
    falls-header: (
      curve.line((0mm, -block-offset-y + corner-radius), relative: true),
      curve.quad((0mm, -corner-radius), (corner-radius, -corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..if top-notch {
        (inverted-notch-path,)
      } else {
        (curve.line((notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((width - block-left-indent - notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, +block-offset-y - corner-radius), relative: true),
      curve.line((0mm, height - block-offset-y - corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + 3 * notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, corner-radius), relative: true),
    ),
    falls-middle: (
      curve.quad((0mm, corner-radius), (corner-radius, corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..if top-notch {
        (inverted-notch-path,)
      } else {
        (curve.line((notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((width - block-left-indent - 3 * notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, height - corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + 3 * notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, corner-radius), relative: true),
    ),
    falls-footer: (
      curve.quad((0mm, corner-radius), (corner-radius, corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..if top-notch {
        (inverted-notch-path,)
      } else {
        (curve.line((notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((width - block-left-indent - 3 * notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, 3mm), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + 1 * notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, -corner-radius), relative: true),
      curve.close(),
    ),
  ).at(type, default: "anweisung")
}


// Interne Funktion für Scratch-Blöcke (akzeptiert explizite colors und stroke-thickness)
#let scratch-block-internal(colorschema, type: "ereignis", top-notch: true, bottom-notch: true, dx: 0mm, dy: 0mm, body, children-array, colors, stroke-thickness) = block(
  above: 0em + if (type == "ereignis" or type == "definiere") { 6mm } else { 0mm },
  below: 0mm + if (type == "ereignis" or type == "definiere") { 6mm } else { 0mm },
)[
  #set text(font: "Helvetica Neue", colors.text-color, weight: 500)
  #let content-box = align(horizon, box(
    inset: content-inset,
    height: if type == "definiere" { 1.5 * block-height } else { auto },
    [
      #context [
        #let content-height = measure(body).height
        #let min-height = 0.75 * block-height
        #box(body, height: calc.max(content-height, min-height))
      ]
    ],
  ))
  #context [
    #let (width, height) = measure(content-box)
    #place(top + left, dx: dx, dy: dy)[
      #curve(
        fill: colorschema.primary,
        stroke: (paint: colorschema.tertiary, thickness: stroke-thickness),
        ..block-path(height, width, type, bottom-notch: bottom-notch, top-notch: top-notch),
      )
    ]
  ]
  #content-box
  #v(dy, weak: true)
  #if children-array.len() != none {
    for child in children-array {
      if std.type(child) == content {
        child
      }
    }
  }
]

// Öffentliche Funktion für Scratch-Blöcke (nutzt State)
#let scratch-block(colorschema: auto, type: "ereignis", top-notch: true, bottom-notch: true, dx: 0mm, dy: 0mm, body, ..children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  let final-colorschema = if colorschema == auto { colors.bewegung } else { colorschema }

  scratch-block-internal(
    final-colorschema,
    type: type,
    top-notch: top-notch,
    bottom-notch: bottom-notch,
    dx: dx,
    dy: dy,
    body,
    children.pos(),
    colors,
    stroke-thickness,
  )
}

// Bedingung (Diamant-Form für boolesche Werte)
#let bedingung(colorschema: auto, type: "bedingung", body, nested: false) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  let final-colorschema = if colorschema == auto { colors.steuerung } else { colorschema }

  set text(font: "Helvetica Neue", colors.text-color, weight: 500)
  box([
    // nested kann bool (beide Seiten gleich) oder (left, right) array sein
    #let nested-type = std.type(nested)
    #let (nested-left, nested-right) = if nested-type == array {
      (nested.at(0), nested.at(1))
    } else {
      (nested, nested)
    }
    #let x-inset-left = if nested-left { -0.5 } else { -0.1 }
    #let x-inset-right = if nested-right { -0.25 } else { -0.05 }
    #let content-box = if body != [] {
      let body = if std.type(body) != array { (body,) } else { body }
      box(inset: (left: pill-inset-x * x-inset-left, right: pill-inset-x * x-inset-right, y: pill-inset-y), align(horizon, [
        #grid(
          columns: (body.len() * 2 + 1) * (auto,),
          column-gutter: 1fr,
          align: center + horizon,
          h(pill-spacing),
          ..body.map(x => { (x, h(0.25em)) }).flatten(),
          h(pill-spacing),
        )
      ]))
    } else { box(height: pill-height, width: pill-height) }

    #context [
      #let (width, height) = measure(content-box, height: auto)
      #let height = if height < block-height and body != [] {
        block-height * 0.9
      } else if height < block-height {
        pill-height
      } else {
        height
      }
      #place(bottom + left)[
        #if body != [] {
          curve(
            fill: final-colorschema.primary,
            stroke: (paint: final-colorschema.tertiary, thickness: stroke-thickness),
            ..block-path(height, width, type),
          )
        } else {
          curve(
            fill: final-colorschema.tertiary,
            stroke: none,
            ..block-path(pill-height, pill-height, type),
          )
        }
      ]
      #box(width: width + 0.5 * height, height: height, align(horizon, content-box))
    ]
  ])
}

// ------------------------------------------------
// 10) Kategorie-Wrapper (bewegung, aussehen, klang, fühlen, steuerung, variablen, listen, eigene)
// ------------------------------------------------
#let bewegung(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.bewegung,
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}

#let aussehen(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.aussehen,
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}

#let klang(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.klang,
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}

#let fühlen(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.fühlen,
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}

#let steuerung(body, bottom-notch: true) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.steuerung,
    type: "anweisung",
    dy: block-offset-y,
    bottom-notch: bottom-notch,
    body,
  )
}

#let variablen(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.variablen,
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}

#let listen(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.listen,
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}

#let eigene(body, dark: false) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: if dark {
      (primary: colors.eigene.secondary, tertiary: colors.eigene.tertiary)
    } else {
      colors.eigene
    },
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}


// ------------------------------------------------
// 11) Ereignisse
// ------------------------------------------------
#let ereignis(body, children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "ereignis",
    body,
    children,
  )
}

// Wenn die grüne Flagge angeklickt wird
#let ereignis-grüne-flagge(children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "ereignis",
    grid(
      columns: 3,
      gutter: 0.5em,
      align: horizon,
      [Wenn], box(image(icons.green-flag)), [angeklickt wird],
    ),
    children,
  )
}

// Wenn Taste <taste> gedrückt wird
#let ereignis-taste(taste, children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "ereignis",
    stack(dir: ltr, spacing: 1.5mm, "Wenn", pill-rect(taste, fill: colors.ereignisse.primary, stroke: colors.ereignisse.tertiary + stroke-thickness, dropdown: true), "gedrückt wird"),
    children,
  )
}

// Wenn die Figur angeklickt wird
#let ereignis-figur-angeklickt(children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "ereignis",
    stack(dir: ltr, spacing: 1.5mm, "Wenn diese Figur angeklickt wird"),
    children,
  )
}

// Wenn das Bühnenbild zu <name> wechselt
#let ereignis-bühnenbild-wechselt-zu(taste, children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "ereignis",
    stack(dir: ltr, spacing: 1.5mm, "Wenn das Bühnenbild zu", pill-rect(taste, fill: colors.ereignisse.primary, stroke: colors.ereignisse.tertiary + stroke-thickness, dropdown: true), "wechselt"),
    children,
  )
}

// Wenn <Element> einen Schwellwert überschreitet (z. B. Lautstärke > 10)
#let ereignis-über(element, wert, children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "ereignis",
    stack(dir: ltr, spacing: 1.5mm, "Wenn", pill-rect(element, fill: colors.ereignisse.primary, stroke: colors.ereignisse.tertiary + stroke-thickness, dropdown: true), ">", zahl-oder-content(
      wert,
      colors.ereignisse,
    )),
    children,
  )
}

// Wenn ich eine Nachricht empfange
#let ereignis-nachricht-empfangen(nachricht, children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "ereignis",
    stack(dir: ltr, spacing: 1.5mm, "Wenn ich", pill-rect(nachricht, fill: colors.ereignisse.primary, stroke: colors.ereignisse.tertiary + stroke-thickness, dropdown: true), "empfange"),
    children,
  )
}

#let ereignis-anweisung(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}

#let sende-nachricht-an-alle(nachricht, wait: false) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  ereignis-anweisung(
    stack(dir: ltr, spacing: 1.5mm, "sende", pill-reporter(nachricht, fill: colors.ereignisse.secondary, stroke: colors.ereignisse.tertiary + stroke-thickness, dropdown: true, inline: true), if wait {
      "an alle und warte"
    } else { "an alle" }),
  )
}

// Wenn ich als Klon entstehe (Ereignis-Form mit Steuerung-Farben)
#let wenn-ich-als-klon-entstehe(children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.steuerung,
    type: "ereignis",
    [Wenn ich als Klon entstehe],
    children,
  )
}

#let erstelle-klon-von(element: "mir selbst") = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  steuerung(
    stack(dir: ltr, spacing: 1.5mm, "erstelle Klon von", pill-reporter(element, fill: colors.steuerung.secondary, stroke: colors.steuerung.tertiary + stroke-thickness, dropdown: true, inline: true)),
  )
}

// ------------------------------------------------
// 12) Reporter (generisch + je Kategorie)
// ------------------------------------------------
// Reporter-Blöcke (Werte)
// Allgemeine Reporter-Funktion für alle Kategorien
// Optional: dropdown-content rendert einen In-Reporter-Dropdown rechts.
#let reporter(colorschema: auto, body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  let final-colorschema = if colorschema == auto { colors.aussehen } else { colorschema }

  pill-reporter(
    fill: final-colorschema.primary,
    stroke: final-colorschema.tertiary + stroke-thickness,
    text-color: colors.text-color,
    if dropdown-content != none {
      pill-round(fill: none, stroke: none, text-color: colors.text-color, inset: (x: 0mm, y: 0.5mm), stack(dir: ltr, spacing: pill-spacing, box(inset: (left: pill-inset-x), body), pill-reporter(
        dropdown-content,
        fill: final-colorschema.secondary,
        stroke: final-colorschema.tertiary + stroke-thickness,
        text-color: colors.text-color,
        dropdown: true,
        inline: true,
      )))
    } else {
      pill-round(body, fill: none, stroke: none, text-color: colors.text-color, inset: (x: 1.5mm, y: 0.5mm))
    },
  )
}

// Bewegungs-Reporter
#let bewegung-reporter(body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  reporter(
    colorschema: colors.bewegung,
    body,
    dropdown-content: dropdown-content,
  )
}

// Aussehen-Reporter
#let aussehen-reporter(body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  reporter(
    colorschema: colors.aussehen,
    body,
    dropdown-content: dropdown-content,
  )
}

// Klang-Reporter
#let klang-reporter(body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  reporter(
    colorschema: colors.klang,
    body,
    dropdown-content: dropdown-content,
  )
}

// Fühlen-Reporter
#let fühlen-reporter(body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  reporter(
    colorschema: colors.fühlen,
    body,
    dropdown-content: dropdown-content,
  )
}

// Variablen-Reporter
#let variablen-reporter(body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  reporter(
    colorschema: colors.variablen,
    body,
    dropdown-content: dropdown-content,
  )
}

// Listen-Reporter
#let listen-reporter(body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  reporter(
    colorschema: colors.listen,
    body,
    dropdown-content: dropdown-content,
  )
}

// Eigene-Reporter (für Platzhalter/Reporter in eigenen Blöcken)
#let eigene-reporter(body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  reporter(
    colorschema: colors.eigene,
    body,
    dropdown-content: dropdown-content,
  )
}

// Parameter-Reporter (pink) für eigene Block-Parameter
// Nutzung: #parameter("Anzahl")
// Verwendet die gleichen Insets wie eigene-eingabe() für konsistente Höhe
#let parameter(name) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  pill-round(name, fill: colors.eigene.primary, stroke: colors.eigene.tertiary + stroke-thickness)
}

// ------------------------------------------------
// 13) Kontrollstrukturen (Grundgerüst + Blöcke)
// ------------------------------------------------
// Gemeinsame Hilfsfunktion für Schleifen- und Bedingungs-Blöcke
#let conditional-block(
  header-label,
  first-body: none, // Der erste Körper (Schleifeninhalt oder "dann"-Zweig)
  middle-notch: false,
  middle-label: none, // Das "sonst"-Label (nur bei falls-Block)
  second-body: none, // Der zweite Körper (nur "sonst"-Zweig bei falls-Block)
  bottom-notch: true,
  first-inset-notch: true,
  second-inset-notch: true,
  block-type: "loop", // "loop" oder "falls"
) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  block(
    above: 0em,
    below: 0mm,
  )[
    #set text(font: "Helvetica Neue", colors.text-color, weight: 500)

    #let first-body = if first-body not in (none, []) {
      first-body
    } else { box(height: 0.5 * block-height, width: 0cm) }

    #let second-body = if second-body not in (none, []) {
      second-body
    } else { box(height: 0.5 * block-height, width: 0cm) }

    #let header-box = align(horizon, box(inset: content-inset, height: auto, header-label))
    #let middle-box = if middle-label != none {
      align(horizon, box(inset: content-inset, height: 0.5 * block-height + corner-radius, middle-label))
    } else { none }

    #context [
      #let header-box-sizes = measure(header-box)
      #let middle-box-sizes = if middle-box != none { measure(middle-box) } else { none }

      #let header-height = if header-box-sizes.height > block-height {
        header-box-sizes.height
      } else {
        block-height
      }

      #let middle-height = if middle-box-sizes != none {
        if middle-box-sizes.height > 0.5 * block-height {
          middle-box-sizes.height
        } else {
          block-height
        }
      } else { 0mm }

      #let first-body-sizes = measure(first-body)
      #let second-body-sizes = measure(second-body)

      #let first-height = if first-body != none { first-body-sizes.height - corner-radius - corner-radius } else { 0mm }
      #let second-height = if second-body != none { second-body-sizes.height - corner-radius - corner-radius } else { 0mm }

      // Pfad-Präfix basierend auf Block-Typ
      #let path-prefix = if block-type == "falls" { "falls" } else { "loop" }

      // Header und Körper zeichnen
      #place(top + left, dy: block-offset-y)[
        #curve(
          fill: colors.steuerung.primary,
          stroke: (paint: colors.steuerung.tertiary, thickness: stroke-thickness),
          ..block-path(header-height, header-box-sizes.width, path-prefix + "-header"),
          curve.line((0mm, first-height), relative: true),
          ..if middle-label != none {
            (
              ..block-path(middle-height, header-box-sizes.width, path-prefix + "-middle", bottom-notch: first-inset-notch),
              curve.line((0mm, second-height), relative: true),
            )
          },
          ..block-path(header-height, header-box-sizes.width, path-prefix + "-footer", bottom-notch: bottom-notch, top-notch: second-inset-notch),
        )
      ]
      #if block-type == "loop" {
        place(bottom + left, dx: header-box-sizes.width - 0.5 * block-height)[
          #image(icons.repeat, height: 0.5 * block-height)
        ]
      }

      // Content rendern - jedes Element mit seiner eigenen Höhe
      #box(height: header-height, header-box)
      #block(
        above: 0em,
        below: 0em,
        inset: (bottom: if middle-label == none { 3mm + 2 * corner-radius } else { corner-radius }),
        move(dx: 2 * notch-spacing, first-body),
      )
      #if middle-label != none {
        box(height: middle-height, middle-box)
        block(
          above: 0em,
          below: 0em,
          inset: (bottom: 3mm + 2 * corner-radius),
          move(dx: 2 * notch-spacing, second-body),
        )
      }
    ]
  ]
}

// Wiederhole n-mal
#let wiederhole(anzahl: 10, body: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  conditional-block(
    [#stack(dir: ltr, spacing: 1.5mm, "wiederhole", zahl-oder-content(anzahl, colors.steuerung), "mal")],
    first-body: body,
  )
}

// Wiederhole bis Bedingung
#let wiederhole-bis(bdg, body: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  conditional-block(
    [#stack(dir: ltr, spacing: 1.5mm, "wiederhole bis", if bdg != [] { bdg } else { bedingung(colorschema: colors.steuerung, []) })],
    first-body: body,
  )
}

// Wiederhole fortlaufend (Endlosschleife)
#let wiederhole-fortlaufend(body) = conditional-block(
  [#stack(dir: ltr, spacing: 1.5mm, "wiederhole fortlaufend")],
  first-body: body,
  bottom-notch: false,
)

// Falls-Dann-Sonst Block
#let falls(bdg, dann: none, sonst: none, dann-end: false, sonst-end: false) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  conditional-block(
    [#stack(dir: ltr, spacing: 1.5mm, "falls", if bdg != [] { bdg } else { bedingung(colorschema: colors.steuerung, []) }, ", dann")],
    first-body: dann,
    middle-label: if sonst != none { [#stack(dir: ltr, spacing: 1.5mm, "sonst")] } else { none },
    second-body: sonst,
    block-type: "falls",
    first-inset-notch: not sonst-end,
    second-inset-notch: not dann-end,
  )
}


// ------------------------------------------------
// 20) Eigene Blöcke
// ------------------------------------------------
// Eigene Blöcke
// Weißer Argument-Platzhalter für eigene Blöcke
#let eigene-eingabe(text) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  pill-round(text, stroke: colors.eigene.tertiary + stroke-thickness)
}

// Erzeugt einen eigenen Anweisungsblock mit Text und Platzhaltern.
// Verwendung:
//   #let mein-block = eigener-block("drehe", eigene-eingabe("Grad"))
//   #mein-block(45)[ ... ]
#let eigener-block(..body) = {
  let items = body.pos()
  return (dark: true, ..values) => context {
    let options = scratch-block-options.get()
    let colors = get-colors-from-options(options)
    let stroke-thickness = get-stroke-from-options(options)

    eigene(dark: dark, {
      let values = values.pos()
      stack(
        dir: ltr,
        spacing: 1.5mm,
        ..if values.len() == 0 {
          for item in items {
            if std.type(item) == str {
              (item,)
            } else if std.type(item) == dictionary {
              (pill-round(stroke: colors.eigene.tertiary, fill: colors.eigene.primary, text-color: colors.text-color, item.name),)
            } else {
              (pill-round(stroke: colors.eigene.tertiary, fill: colors.eigene.primary, text-color: colors.text-color, str("number or text")),)
            }
          }
        } else {
          let key = 0
          for item in items {
            if std.type(item) == str {
              (item,)
            } else {
              (zahl-oder-content(values.at(calc.rem(key, values.len())), colors.eigene),)
              key += 1
            }
          }
        },
      )
    })
  }
}

// Kopf einer eigenen Block-Definition inkl. Label (Signatur)
#let definiere(block-label, ..children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.eigene,
    type: "definiere",
    dy: 2.5 * corner-radius,
    stack(
      dir: ltr,
      spacing: 1.5mm,
      "Definiere",
      block-label(dark: true),
    ),
    ..children,
  )
}
