#import "@schule/random:0.0.1": shuffle
#import "@schule/aufgaben:0.5.0": has-solutions
#import "internal/check.typ": fail, check-named, check-type, check-positional, fold-name
#import "internal.typ": words, block-counter, uniform, start, palette, blank-padding, blank-stroke, solution-fill

/// Beginnt die Zählung der Lückentexte neu, zum Beispiel zu Beginn jeder
/// Fassung eines Bündels. Die Wortlisten bleiben getrennt, gemischt wird wie
/// in einem einzelnen Dokument. `arbeitsblatt` ruft das selbst auf.
///
/// ```typ
/// #reset-iaword()
/// ```
///
/// -> content
#let reset-iaword() = context start.update(block-counter.get().at(0))

/// Markiert ein Wort für den Lückentext.
///
/// Ersetzt das Wort durch eine Linie und meldet es für die Wortbank an.
/// Gehört in den Rumpf von `insert-a-word`. Sind im Dokument Lösungen
/// eingeschaltet (`set-options(solutions: …)` aus aufgaben, arbeitsblatt oder
/// klassenarbeit), steht das Wort rot auf der Linie.
///
/// ```typ
/// Der #iaword[Hund] bellt.
/// ```
///
/// - body (content): das einzusetzende Wort (beliebiger Inhalt, auch eine Formel)
/// -> content
#let iaword(body) = {
  context {
    let position = block-counter.get() // Nummer des laufenden Blocks
    words.update(entries => {
      entries.push((position.at(0), body)) // (Blocknummer, Wort) anhängen
      entries
    })

    // Lückenbreite: nach dem eigenen Wort oder nach dem längsten des Blocks
    let width = if uniform.get() {
      let entries = words.final().filter(entry => entry.at(0) == position.at(0))
      if entries.len() > 0 {
        calc.max(..entries.map(entry => measure(entry.at(1)).width)) + blank-padding
      } else {
        measure(body).width + blank-padding
      }
    } else {
      measure(body).width + blank-padding
    }

    box()[
      #if has-solutions() [
        // Mit Lösungen steht das Wort auf der Linie
        #move(dy: 4pt)[
          #place(bottom, dy: -4pt, box(height: 0cm, width: width, align(center, text(solution-fill, body))))
          #line(length: width, stroke: blank-stroke)
        ]
      ] else [
        #move(dy: 4pt)[
          #line(length: width, stroke: blank-stroke)
        ]
      ]
    ]
  }
}

/// Setzt einen Lückentext mit Wortbank.
///
/// Über dem Text erscheinen die mit `iaword` markierten Wörter als farbige
/// Wortkästen in gemischter Reihenfolge; im Text steht an ihrer Stelle eine
/// Linie. Ob die Lösung in den Lücken steht, folgt der Lösungsoption des
/// Dokuments (`set-options(solutions: …)`); einen eigenen Schalter gibt es
/// nicht.
///
/// ```typ
/// #insert-a-word[
///   Der #iaword[Hund] bellt. Die #iaword[Katze] miaut.
/// ]
/// ```
///
/// - word-bank (bool): Wortkästen über dem Text zeigen
/// - leading (length): Zeilenabstand im Text (geht an `par(leading:)`)
/// - spacing (length, relative, ratio, fraction): Abstand zwischen den Wortkästen
/// - uniform-blanks (bool): alle Lücken so breit wie das längste Wort
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): der Lückentext mit `iaword`-Markierungen
/// -> content
#let insert-a-word(
  word-bank: true,
  leading: 1.5em,
  spacing: 1em,
  uniform-blanks: false,
  ..deprecated,
  body,
) = {
  check-positional("insert-a-word", "insert-a-word", deprecated,
    hint: "der Lückentext ist das einzige Positionsargument – `insert-a-word(…)[Text mit #iaword[Wort]]` schreiben")
  // Alt und neu zugleich: Der neue Name ist ein deklarierter Parameter und
  // landet nie im Sink. Erkennbar ist die doppelte Angabe deshalb nur, wenn der
  // neue Wert von der Vorgabe abweicht.
  let given = (
    "hide-words": ("word-bank", word-bank != true),
    "line-spacing": ("leading", leading != 1.5em),
    "item-spacing": ("spacing", spacing != 1em),
    "uniform-gaps": ("uniform-blanks", uniform-blanks != false),
  )
  for (key, value) in deprecated.named() {
    let old = fold-name(key)
    if old in given and given.at(old).at(1) {
      let new = given.at(old).at(0)
      fail("insert-a-word", "insert-a-word",
        "`" + key + "` (alt) und `" + new + "` (neu) zugleich – nur `" + new + "` schreiben")
    }
    // `hide-words` wurde gewendet: Die Meldung nennt den neuen Wert mit.
    if old == "hide-words" and value == true {
      fail("insert-a-word", "insert-a-word", "`" + key + ": true` heißt jetzt `word-bank: false`")
    }
    if old == "hide-words" and value == false {
      fail("insert-a-word", "insert-a-word",
        "`" + key + ": false` heißt jetzt `word-bank: true` – das ist die Vorgabe, weglassen genügt")
    }
    // `show-solution` ist entfallen: Die Abhilfe hängt vom Wert ab.
    if old == "show-solution" and value == false {
      fail("insert-a-word", "insert-a-word",
        "`" + key + ": false` gibt es nicht mehr – weglassen (die Lücken folgen der Lösungsoption des Dokuments)")
    }
  }
  check-named("insert-a-word", "insert-a-word", deprecated,
    renamed: (
      "hide-words": "word-bank",
      "line-spacing": "leading",
      "item-spacing": "spacing",
      "uniform-gaps": "uniform-blanks",
    ),
    removed: (
      "show-solution": "die Lücken folgen der Lösungsoption des Dokuments – weglassen und im Dokument `set-options(solutions: \"in-place\")` schreiben",
    ),
    allowed: ("word-bank", "leading", "spacing", "uniform-blanks"))
  check-type("insert-a-word", "insert-a-word", "word-bank", word-bank, bool)
  check-type("insert-a-word", "insert-a-word", "leading", leading, length)
  // Eigene Meldung: `h` nimmt Länge, Anteil und Bruchteil; die Typliste von
  // check-type läse sich hier holprig.
  if type(spacing) not in (length, relative, ratio, fraction) {
    fail("insert-a-word", "insert-a-word",
      "`spacing` erwartet eine Länge, einen Anteil (`%`) oder einen Bruchteil (`fr`), bekam `"
        + repr(spacing) + "` (" + repr(type(spacing)) + ") – zum Beispiel `1em`")
  }
  check-type("insert-a-word", "insert-a-word", "uniform-blanks", uniform-blanks, bool)

  // Lückenbreite für die `iaword` dieses Blocks merken
  uniform.update(uniform-blanks)

  context {
    let position = block-counter.get().at(0) // Zählerstand vor diesem Block
    let seed = position - start.get()
    // Die Wörter dieses Blocks (er bekommt die nächste Nummer)
    let entries = words.final().filter(entry => entry.at(0) == position + 1)

    if word-bank and entries.len() > 0 {
      let shuffled = shuffle(entries, seed) // gemischte Wörter
      let shuffled-palette = shuffle(palette, seed) // gemischte Farben

      align(
        center,
        for (index, entry) in shuffled.enumerate() {
          h(spacing / 2)
          box(
            fill: shuffled-palette.at(calc.rem(index, palette.len())),
            inset: 8pt,
            radius: 4pt,
            [#entry.at(1)],
          )
          h(spacing / 2)
        },
      )
    }

    block-counter.step() // ab hier läuft der Rumpf unter der neuen Nummer
  }

  set par(leading: leading)
  body
}
