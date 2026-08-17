// schuldocs — gemeinsame Grundwerte
//
// Farben, Maße, Schriften und der Ausgabe-Zustand. Dieses Modul hat keine
// Abhängigkeiten und darf von allen anderen Modulen geladen werden.

/// Version des Pakets.
#let version = "0.2.0"

// ─── Ausgabe-Zustand ────────────────────────────────────────────────────────

// Welche Ausgabe gerade gesetzt wird. `docs()` setzt den Wert zu Beginn jedes
// Dokuments; er ist auch innerhalb von `html.frame` verlässlich, anders als
// `target()`, das dort fälschlich `"paged"` meldet.
#let target-state = state("schuldocs-target", "pdf")

/// Liefert die gerade gesetzte Ausgabe: `"web"` oder `"pdf"`.
///
/// Muss innerhalb von `context` stehen, weil der Wert aus einem Zustand kommt.
/// Verlässlich auch innerhalb von `html.frame` — im Unterschied zu `target()`.
///
/// ```typ
/// #context {
///   if doc-target() == "web" { html.frame(zeichnung) } else { zeichnung }
/// }
/// ```
/// -> string
#let doc-target() = target-state.get()

// Marke am Anfang des PDF-Dokuments. Beide Ausgaben liegen in einem einzigen
// Introspektions-Raum: `query(heading)` sieht die Überschriften beider
// Durchgänge. Über diese Marke trennt sich, was zu welcher Ausgabe gehört —
// die Website fragt `.before(…)`, das Handbuch `.after(…)`.
#let pdf-mark = <schuldocs-pdf-anfang>

// ─── Farben ─────────────────────────────────────────────────────────────────

// Ruhige, sachliche Farbwelt. Der Akzent ist dasselbe Blau, das die alte
// Web-Dokumentation für Überschriften benutzt hat.
#let colors = (
  ink: rgb("#16191d"), // Fließtext
  muted: rgb("#5b6670"), // Nebentext, Kopf- und Fußzeile
  accent: rgb("#14537f"), // Überschriften, Verweise
  accent-deep: rgb("#0c4a6e"), // Titelseite, Betonung
  rule: rgb("#d5dbe1"), // Linien
  surface: rgb("#f4f6f8"), // Flächen hinter Quelltext
  surface-edge: rgb("#e3e8ed"), // Rand dieser Flächen
)

// ─── Schriften ──────────────────────────────────────────────────────────────

// Die letzte Angabe jeder Kette ist eine von Typst mitgelieferte Schrift,
// damit das Handbuch überall gleich baut.
#let fonts = (
  serif: ("Libertinus Serif",),
  sans: ("Inter", "Source Sans 3", "Noto Sans", "Helvetica Neue", "Libertinus Serif"),
  mono: ("DejaVu Sans Mono",),
)

// ─── Maße ───────────────────────────────────────────────────────────────────

#let sizes = (
  paper: "a4",
  margin: (top: 2.6cm, bottom: 2.4cm, x: 2.6cm),
  text: 10.5pt,
  leading: 0.72em,
  par-spacing: 1.1em,
  code: 0.92em,
)

// Name der Stilvorlage neben der Website.
#let css-name = "docs.css"
