// Interne Namen von mathematik. Keine zugesicherte Schnittstelle: Dokumente
// benutzen sie nicht, und sie dürfen sich in jeder Version ändern.

/// Farben der GeoGebra-Oberfläche: `accent` (Lila der Schaltflächen) und
/// `stroke` (Hellgrau der Rahmen).
#let geogebra-palette = (
  accent: rgb("#6557D2"),
  stroke: rgb("#DCDCDC"),
)

/// Die drei senkrechten Punkte am rechten Rand einer GeoGebra-Zelle.
///
/// - width (length): Breite des Zeichens
/// -> content
#let geogebra-menu-button(width: 1.2em) = image(
  bytes(
    "<svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24'><rect width='24' height='24' fill='none'/><circle cx='12' cy='6' r='1.5' fill='#808080'/><circle cx='12' cy='12' r='1.5' fill='#808080'/><circle cx='12' cy='18' r='1.5' fill='#808080'/></svg>",
  ),
  width: width,
)

/// Die lila Schaltfläche „≈“ (Näherungswert) einer GeoGebra-Zelle.
///
/// - width (length): Breite und Höhe der Schaltfläche
/// -> content
#let geogebra-approximate-button(width: 1.2em) = box(
  width: width,
  height: width,
  fill: geogebra-palette.accent,
  radius: 5%,
  align(center + horizon)[
    #text(
      0.8em,
      top-edge: "bounds",
      bottom-edge: "bounds",
      white,
    )[$approx$]
  ],
)
