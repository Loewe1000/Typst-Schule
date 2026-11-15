// Interne Helfer von flashcards. Keine zugesicherte Schnittstelle:
// Namen und Gestalt dürfen sich in jeder Version ändern.

/// Alle Karten des Dokuments in der Reihenfolge ihrer Aufrufe. Jeder Eintrag
/// ist ein Dictionary mit `header`, `footer`, `question` und `answer`.
#let cards = state("schule/flashcards/cards@1", ())

/// Zahl der Karten je Seite (2 Spalten mal 4 Zeilen).
#let cards-per-page = 8

/// Schriftgröße von Kopfzeile, Fußzeile und Kartennummer.
#let base-size = 11pt

/// Linienfarbe des Schnittrasters.
#let cut-paint = luma(200).darken(30%).lighten(50%)

/// Maße und Schrift je Papierformat. `question-text` und `answer-text` gehen
/// an `text`, `question-place` an `place`.
#let formats = (
  "a4": (
    width: 210mm,
    height: 297mm,
    question-text: (size: 12pt),
    question-place: (alignment: horizon + center),
    answer-text: (size: 12pt),
  ),
  "us-letter": (
    width: 8.5in,
    height: 11in,
    question-text: (size: base-size * 1.25, weight: "bold"),
    question-place: (alignment: top + center, dy: 1.5cm),
    answer-text: (size: base-size * 1.25),
  ),
)

/// Breite und Höhe einer Karte: eine halbe Seitenbreite, ein Viertel der
/// Seitenhöhe.
///
/// - format (dictionary): Eintrag aus `formats`
/// -> dictionary
#let card-size(format) = (width: format.width / 2, height: format.height / 4)

/// Setzt die Vorderseite einer Karte: Kopfzeile mit Nummer, Frage, Fußzeile.
///
/// - format (dictionary): Eintrag aus `formats`
/// - item (dictionary): Karte mit `header`, `footer`, `question`, `answer`
/// - number (int): Nummer der Karte, ab 1
/// - total (int): Zahl aller Karten
/// -> content
#let question-side(format, item, number, total) = {
  let (width, height) = card-size(format)
  let (alignment, ..offset) = format.question-place
  box(width: width, height: height, {
    place(top + center, dy: 0.5cm, float: true,
      box(width: width - 1cm)[
        #text(size: base-size)[
          #smallcaps[#item.header] #h(0.5fr) #number/#total
        ]
      ]
    )
    place(alignment, ..offset,
      box(inset: (x: 1cm, y: 0.5cm), [
        #text(..format.question-text)[ #item.question ]
      ])
    )
    place(
      bottom + right, dx: -0.5cm, dy: -0.5cm, float: true,
      text(size: base-size, style: "italic")[#item.footer],
    )
  })
}

/// Setzt die Rückseite einer Karte: Nummer und Antwort.
///
/// - format (dictionary): Eintrag aus `formats`
/// - item (dictionary): Karte mit `header`, `footer`, `question`, `answer`
/// - number (int): Nummer der Karte, ab 1
/// - total (int): Zahl aller Karten
/// -> content
#let answer-side(format, item, number, total) = {
  let (width, height) = card-size(format)
  box(width: width, height: height, {
    place(
      top + right, dx: -0.5cm, dy: 0.5cm, float: true,
      [
        #set align(right)
        #text(size: base-size)[#number/#total]
      ]
    )
    place(horizon + center,
      box(inset: (x: 1cm, y: 0.5cm), [
        #set align(left)
        #text(..format.answer-text)[#item.answer]
      ])
    )
  })
}

/// Setzt eine Seite: bis zu acht Kartenseiten im Schnittraster.
///
/// - format (dictionary): Eintrag aus `formats`
/// - sides (array): Kartenseiten in Lesereihenfolge
/// -> content
#let sheet(format, sides) = {
  let (width, height) = card-size(format)
  table(
    columns: (width, width), rows: height,
    inset: 0pt,
    stroke: (
      thickness: 0.5pt, dash: "dashed", cap: "round",
      paint: cut-paint,
    ),
    ..sides
  )
}

/// Setzt alle Karten: je Bogen eine Seite Fragen und eine Seite Antworten.
/// Auf der Antwortseite sind die beiden Spalten vertauscht, damit beim
/// beidseitigen Druck jede Antwort hinter ihrer Frage liegt.
///
/// - format (dictionary): Eintrag aus `formats`
/// - items (array): Karten in der Reihenfolge des Dokuments
/// -> content
#let sheets(format, items) = {
  let total = items.len()
  let questions = items.enumerate().map(((index, item)) => question-side(format, item, index + 1, total))
  let answers = items.enumerate().map(((index, item)) => answer-side(format, item, index + 1, total))
  // Ungerade Kartenzahl: die letzte Zeile mit einer leeren Zelle auffüllen.
  if calc.odd(total) {
    questions.push([])
    answers.push([])
  }
  let mirrored = answers.chunks(2).map(pair => pair.rev()).flatten()

  let question-pages = questions.chunks(cards-per-page)
  let answer-pages = mirrored.chunks(cards-per-page)
  for page-index in range(question-pages.len()) {
    sheet(format, question-pages.at(page-index))
    pagebreak()
    sheet(format, answer-pages.at(page-index))
  }
}
