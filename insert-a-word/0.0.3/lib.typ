#import "@schule/random:0.0.1": *

// Definiert einen Zustand für die Liste der Wörter
#let iaword-list = state("iaword-list", ())
#let iaword-solution = state("iaword-solution", ())

// Definiert einen Zähler zur Verfolgung der Wortpositionen
#let iaword-counter = counter("iaword-counter")

// Definiert einen Zustand für einheitliche Lückengrößen
#let iaword-uniform = state("iaword-uniform", false)

// Funktion zur Erstellung eines Wort-Elements
/// Markiert ein Wort für die Lückentext-Aufgabe.
///
/// Ersetzt das Wort durch eine Linie und registriert es für die Wortliste.
/// Muss innerhalb eines `#insert-a-word`-Blocks verwendet werden.
///
/// ```typ
/// Der #iaword[Hund] bellt.
/// ```
///
/// - body (content): Das einzusetzende Wort (beliebiger Typst-Content).
/// -> content
#let iaword(body) = {
  context {
    let position = iaword-counter.get() // Aktuelle Position abrufen
    iaword-list.update(words => {
      words.push((position.at(0), body)) // Fügt (Position, Wort) zur Liste hinzu
      words
    })

    // Lückenbreite berechnen (entweder individuell oder so groß wie das längste Wort im aktuellen Block)
    let is-uniform = iaword-uniform.get()
    let final-width = if is-uniform {
      let current-words = iaword-list.final().filter(w => w.at(0) == position.at(0))
      if current-words.len() > 0 {
        calc.max(..current-words.map(w => measure(w.at(1)).width)) + 3em
      } else {
        measure(body).width + 3em
      }
    } else {
      measure(body).width + 3em
    }

    box()[
      #if iaword-solution.final().at(position.at(0) - 1) [
        // Wenn Lösung angezeigt werden soll, wird das Wort sichtbar gemacht
        #move(dy: 4pt)[
          // Zeichnet eine Linie unter dem Wort basierend auf der berechneten Breite
          #place(bottom, dy: -4pt, box(height: 0cm, width: final-width, align(center, text(red, body))))
          #line(length: final-width, stroke: 0.5pt + luma(130))
        ]
      ] else [
        #move(dy: 4pt)[
          // Zeichnet eine Linie basierend auf der berechneten Breite
          #line(length: final-width, stroke: 0.5pt + luma(130))
        ]
      ]

      // TODO: Option zum Anzeigen der Lösung hinzufügen
      // #place(center, dy: -8pt, body)
    ]
  }
}

// Funktion zum Einfügen eines Wortes mit Anpassungsoptionen
/// Erstellt eine Lückentext-Aufgabe mit gemischten Wortboxen.
///
/// Über dem Text erscheinen farbige Wortboxen in zufälliger Reihenfolge.
/// Im Text ersetzen Lückenlinien die mit `#iaword` markierten Wörter.
///
/// ```typ
/// #insert-a-word[
///   Der #iaword[Hund] bellt. Die #iaword[Katze] miaut.
/// ]
/// ```
///
/// - hide-words (bool): Blendet die Wortboxen aus. Standard: `false`.
/// - line-spacing (length): Zeilenabstand im Text. Standard: `1.5em`.
/// - item-spacing (length): Abstand zwischen den Wortboxen. Standard: `1em`.
/// - show-solution (bool): Zeigt die Lösung im Text an. Standard: `false`.
/// - uniform-gaps (bool): Einheitliche Lückenbreite für alle Wörter. Standard: `false`.
/// - body (content): Der Lückentext mit `#iaword`-Markierungen.
/// -> content
#let insert-a-word(hide-words: false, line-spacing: 1.5em, item-spacing: 1em, show-solution: false, uniform-gaps: false, body) = {
  // Option für einheitliche Lücken speichern
  iaword-uniform.update(uniform-gaps)

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

    iaword-solution.update(solution => {
      solution.insert(position, show-solution) // Speichert, ob die Lösung angezeigt werden soll
      solution
    })
    // Filtert Wörter, die zur nächsten Position gehören
    let words = iaword-list.final().filter(word => word.at(0) == position + 1)

    if not hide-words and words.len() > 0 {
      let shuffled = shuffle(words, position) // Zufällige Reihenfolge der Wörter
      let shuffled-colors = shuffle(colors, position) // Zufällige Reihenfolge der Farben

      align(
        center,
        // Erstellt eine Box für jedes Wort mit zugewiesener Farbe
        for (index, word) in shuffled.enumerate() {
          h(item-spacing / 2)
          box(
            fill: shuffled-colors.at(calc.rem(index, colors.len())), // Farbe aus Palette
            inset: 8pt, // Innenabstand
            radius: 4pt, // Abgerundete Ecken
            [#word.at(1)], // Einfügtes Wort
          )
          h(item-spacing / 2)
        },
      )
    }

    iaword-counter.step() // Erhöht den Zähler für die nächste Position
  }

  set par(leading: line-spacing) // Setzt den Zeilenabstand für den Text
  body
}
