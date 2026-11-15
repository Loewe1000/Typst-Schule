// flashcards 0.5.0 – öffentliche Funktionen.
#import "internal/check.typ": check-named, check-value, check-type, check-not-empty, check-positional
#import "internal.typ": cards, formats, sheets

/// Legt eine Lernkarte an: vorn die Frage, hinten die Antwort.
///
/// Die Karte erscheint nicht an der Stelle des Aufrufs. `show-cards` setzt alle
/// Karten des Dokuments in der Reihenfolge ihrer Aufrufe und nummeriert sie
/// („3/8“).
///
/// ```typ
/// #card(header: [Physik], footer: [Klasse 10])[Was ist Energie?][
///   Die Fähigkeit, Arbeit zu verrichten.
/// ]
/// ```
///
/// - header (content, str, none): Kopfzeile der Vorderseite, zum Beispiel das Fach; steht in Kapitälchen neben der Kartennummer
/// - footer (content, str, none): Fußzeile der Vorderseite, zum Beispiel das Thema; steht kursiv unten rechts
/// - ..deprecated (arguments): fängt alte Namen und überzählige Argumente ab, nimmt nichts an
/// - question (content, str): Frage auf der Vorderseite
/// - answer (content, str): Antwort auf der Rückseite
/// -> content
#let card(header: none, footer: none, ..deprecated, question, answer) = {
  // Frage und Antwort mitzählen, damit die Meldung nennt, was im Aufruf steht.
  check-positional("flashcards", "card", deprecated.pos() + (question, answer), max: 2,
    hint: "Kopf- und Fußzeile stehen benannt vor Frage und Antwort – `card(header: [...], footer: [...])[Frage][Antwort]` schreiben")
  check-named("flashcards", "card", deprecated,
    allowed: ("header", "footer"))
  check-type("flashcards", "card", "header", header, (content, str, none))
  check-type("flashcards", "card", "footer", footer, (content, str, none))
  check-not-empty("flashcards", "card", "header", header, "keine Kopfzeile")
  check-not-empty("flashcards", "card", "footer", footer, "keine Fußzeile")
  check-type("flashcards", "card", "question", question, (content, str))
  check-type("flashcards", "card", "answer", answer, (content, str))
  cards.update(all => all + ((header: header, footer: footer, question: question, answer: answer),))
}

/// Setzt alle Lernkarten des Dokuments als Druckbögen: acht Karten je Seite
/// (2 Spalten, 4 Zeilen), abwechselnd eine Seite Fragen und eine Seite
/// Antworten.
///
/// Die Karten füllen die ganze Seite. Das Dokument stellt Papier und Rand
/// selbst ein, passend zu `paper`:
///
/// ```typ
/// #set page(paper: "a4", margin: 0pt)
/// #card(header: [Physik], footer: [Optik])[Was ist Reflexion?][
///   Zurückwurf von Licht an einer Grenzfläche.
/// ]
/// #show-cards()
/// ```
///
/// Die Stelle des Aufrufs ist frei: Es erscheinen auch Karten, die erst
/// danach angelegt werden.
///
/// - paper (str): Papierformat, nach dem sich Kartengröße und Schrift richten: `"a4"` (Karte 105 mm × 74,25 mm) oder `"us-letter"` (Karte 4,25 in × 2,75 in, Frage fett und oben)
/// - ..deprecated (arguments): fängt alte Namen und überzählige Argumente ab, nimmt nichts an
/// -> content
#let show-cards(paper: "a4", ..deprecated) = {
  check-positional("flashcards", "show-cards", deprecated,
    hint: "das Papierformat benannt schreiben (`paper: \"a4\"`)")
  check-named("flashcards", "show-cards", deprecated,
    allowed: ("paper",))
  check-value("flashcards", "show-cards", "paper", paper, formats.keys())
  context sheets(formats.at(paper), cards.final())
}
