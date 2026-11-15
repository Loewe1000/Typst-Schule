// Interne Namen von insert-a-word. Keine zugesicherte Schnittstelle: Was hier
// steht, darf sich in jeder Version ändern. Dokumente benutzen es nicht.
//
// Jeder State und der Counter des Pakets wird genau hier angelegt. Kein
// Schlüssel wird mit einer älteren Paketversion geteilt: insert-a-word 0.0.3
// (`state("iaword-list")`, `counter("iaword-counter")` …) und 0.5.0 stören
// sich im selben Dokument nicht.

/// Die markierten Wörter des Dokuments: Array aus Paaren
/// `(Blocknummer, Wort)`. `iaword` hängt an, `insert-a-word` liest den
/// Endstand und filtert nach der Nummer seines Blocks.
#let words = state("schule/insert-a-word/words@1", ())

/// Zählt die Lückentexte des Dokuments. Während der Rumpf des n-ten Blocks
/// gesetzt wird, steht der Zähler auf n; darüber finden Wörter ihren Block.
#let block-counter = counter("schule/insert-a-word/block-counter@1")

/// Ob die Lücken des laufenden Blocks gleich breit sind (`uniform-blanks`).
#let uniform = state("schule/insert-a-word/uniform@1", false)

/// Zählerstand zu Beginn des laufenden Dokuments (`reset-iaword`). Die
/// Mischreihenfolge hängt an der Nummer des Blocks im Dokument, nicht an der
/// laufenden Nummer; sonst mischte jede Fassung eines Bündels anders.
#let start = state("schule/insert-a-word/start@1", 0)

/// Farben der Wortkästen; je Block gemischt und reihum vergeben.
#let palette = (
  rgb("#B3D4EC"), // Hellblau
  rgb("#D5E3B5"), // Hellgrün
  rgb("#EEAA95"), // Hellrot/Orange
  rgb("#FAD3AD"), // Aprikose
  rgb("#CBADC8"), // Hellviolett
  rgb("#FFE3A8"), // Hellgelb
)

/// Breite einer Lücke über die Breite des Wortes hinaus.
#let blank-padding = 3em

/// Strich der Lücke.
#let blank-stroke = 0.5pt + luma(130)

/// Farbe des eingesetzten Lösungsworts.
#let solution-fill = red
