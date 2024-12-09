#import "@schule/random:0.0.1": *

// Definiert einen Zustand für die Liste der Wörter
#let iaword-list = state("iaword-list", ())

// Definiert einen Zähler zur Verfolgung der Wortpositionen
#let iaword-counter = counter("iaword-counter")

// Funktion zur Erstellung eines Wort-Elements
#let iaword(body) = {
  context {
    let position = iaword-counter.get() // Aktuelle Position abrufen
    iaword-list.update(words => {
      words.push((position.at(0), body)) // Fügt (Position, Wort) zur Liste hinzu
      words
    })
  }
  box()[
    #move(dy: 4pt)[
      // Zeichnet eine Linie unter dem Wort basierend auf der Wortbreite
      #context line(length: measure(body).width + 3em, stroke: 0.5pt + luma(130))
    ]

    // TODO: Option zum Anzeigen der Lösung hinzufügen
    // #place(center, dy: -8pt, body)
  ]
}

// Funktion zum Einfügen eines Wortes mit Anpassungsoptionen
#let insert-a-word(hide-words: false, line-spacing: 1.5em, body) = {
  // Definiert eine Farbpalette für die Wort-Boxen
  let colors = (
    rgb("#B3D4EC"), // Hellblau
    rgb("#D5E3B5"), // Hellgrün
    rgb("#EEAA95"), // Hellrot/Orange
    rgb("#FAD3AD"), // Aprikose
    rgb("#CBADC8"), // Hellviolett
    rgb("#FFE3A8"), // Hellgelb
  )

  context {
    let position = iaword-counter.get().at(0) // Aktuelle Zählerposition
    // Filtert Wörter, die zur nächsten Position gehören
    let words = iaword-list.final().filter(word => word.at(0) == position + 1)

    if not hide-words and words.len() > 0 {
      let shuffled = shuffle(words, position) // Zufällige Reihenfolge der Wörter
      let shuffled-colors = shuffle(colors, position) // Zufällige Reihenfolge der Farben

      // Erstellt eine Box für jedes Wort mit zugewiesener Farbe
      for (index, word) in shuffled.enumerate() [
        #box(
          fill: shuffled-colors.at(calc.rem(index, colors.len())), // Farbe aus Palette
          inset: 8pt, // Innenabstand
          radius: 4pt, // Abgerundete Ecken
          [#word.at(1)], // Einfügtes Wort
        )
      ]
    }

    iaword-counter.step() // Erhöht den Zähler für die nächste Position
  }

  par(leading: line-spacing, body) // Formatiert den Text mit festem Zeilenabstand
}