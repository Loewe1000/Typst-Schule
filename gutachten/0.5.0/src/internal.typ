// Interne Helfer von gutachten. Keine zugesicherte Schnittstelle:
// Namen und Gestalt dürfen sich in jeder Version ändern.
//
// Der erste Teil trägt die States und Helfer des Gutachtens. Der zweite Teil
// („Erwartungshorizont“) ist die reparierte Fassung von `bewertung.typ` aus
// 0.0.2: Dort kompilierte die Datei unter Typst 0.15 nicht mehr
// (`locate(func)`, `type(s) == "state"`, tablex 0.0.5) und war über den
// Paketnamen nicht erreichbar.
#import "internal/check.typ": fail

// ---------------------------------------------------------------------------
// States (konvention.md 7.3: `schule/<paket>/<name>@<schema>`)
// ---------------------------------------------------------------------------

/// Angaben aus `set-options`: Dictionary mit `subject`, `level`, `teacher`,
/// `anonymous`, `print`, `max-points`, `font`, `math-font`, `year`. Ohne
/// Aufruf von `set-options` ist der Wert `none`.
#let options = state("schule/gutachten/options@1", none)

/// Der Prüfling des laufenden Gutachtens: `(first-name:, last-name:)`.
#let student = state("schule/gutachten/student@1", none)

/// Aufgaben aus `set-tasks`: Aufgabenname → `(max-points:, dative:, title:)`.
#let tasks = state("schule/gutachten/tasks@1", (:))

/// Summe der erreichten Punkte im laufenden Gutachten.
#let points = state("schule/gutachten/points@1", 0)

/// Erwartungen für den Erwartungshorizont. Jeder Eintrag:
/// `(task-number:, subtask-number:, text:, points:)`.
#let expectations = state("schule/gutachten/expectations@1", ())

/// Aufgaben für den Erwartungshorizont. Jeder Eintrag:
/// `(task-number:, subtask-count:, title:)`.
#let expectation-tasks = state("schule/gutachten/expectation-tasks@1", ())

// ---------------------------------------------------------------------------
// Helfer des Gutachtens
// ---------------------------------------------------------------------------

/// Platzhalter für den Namen, wenn `anonymous: true` gesetzt ist.
///
/// -> content
#let anonymous-placeholder() = emph[#text(fill: black)[Schüler]]

/// Punktzahl als Text: Dezimalkomma, ganze Zahlen unter 10 mit führender Null.
///
/// - value (int, float): Punktzahl
/// -> str
#let format-points(value) = {
  if type(value) == int and value >= 0 and value < 10 {
    "0" + str(value).replace(".", ",")
  } else {
    str(value).replace(".", ",")
  }
}

/// Liefert die endgültigen Angaben aus `set-options`; bricht ab, wenn
/// `set-options` im Dokument fehlt. Braucht `context`.
///
/// - function (str): Name der aufrufenden Funktion für die Meldung
/// -> dictionary
#let final-options(function) = {
  let value = options.final()
  if value == none {
    fail("gutachten", function, "die Angaben zum Gutachten fehlen – einmal `set-options(subject: ..., level: ..., teacher: ..., max-points: ...)` aufrufen")
  }
  value
}

/// Liefert den Prüfling des laufenden Gutachtens; bricht ab, wenn die Stelle
/// außerhalb von `gutachten` liegt. Braucht `context`.
///
/// - function (str): Name der aufrufenden Funktion für die Meldung
/// -> dictionary
#let current-student(function) = {
  let value = student.get()
  if value == none {
    fail("gutachten", function, "steht außerhalb eines Gutachtens – nur innerhalb von `gutachten(...)[...]` verwenden")
  }
  value
}

/// Name des Labels, das das Ende eines Gutachtens markiert (für „1 von 3“).
///
/// - value (dictionary): Prüfling `(first-name:, last-name:)`
/// -> str
#let pages-label(value) = "schule-gutachten-pages-" + value.first-name + "-" + value.last-name

// ---------------------------------------------------------------------------
// Erwartungshorizont (aus `bewertung.typ` 0.0.2, repariert)
// ---------------------------------------------------------------------------

/// Die Erwartungen einer Aufgabe oder Teilaufgabe. Braucht `context`.
///
/// - task-number (int, str): Nummer der Aufgabe
/// - subtask-number (int, none): Nummer der Teilaufgabe; `0` meint die Aufgabe selbst, `none` alle Teile
/// -> array
#let matching-expectations(task-number, subtask-number) = {
  expectations.final().filter(entry => (
    entry.task-number == task-number and (subtask-number == none or subtask-number == entry.subtask-number)
  ))
}

/// Vorgabe für `format` in `expectation-entries`: „Text (Punkte)“, je Zeile
/// eine Erwartung.
///
/// - text (content, str): Text der Erwartung
/// - points (int, float): Punkte der Erwartung
/// - last (bool): letzte Erwartung der Zelle
/// -> content
#let expectation-entry(text, points, last) = {
  if last [#text (#points)] else [#text (#points)\ ]
}

/// Setzt alle Erwartungen einer Aufgabe oder Teilaufgabe.
///
/// - task-number (int, str): Nummer der Aufgabe
/// - subtask-number (int, none): Nummer der Teilaufgabe; `0` meint die Aufgabe selbst, `none` alle Teile
/// - format (function): `(text, points, last) => content`
/// -> content
#let expectation-entries(task-number, subtask-number: 0, format: expectation-entry) = context {
  let entries = matching-expectations(task-number, subtask-number)
  for (index, entry) in entries.enumerate() {
    format(entry.text, entry.points, index == entries.len() - 1)
  }
}

/// Setzt die Texte aller Erwartungen einer Aufgabe oder Teilaufgabe, jede mit
/// führenden Auslassungspunkten („… berechnet die Steigung“).
///
/// - task-number (int, str): Nummer der Aufgabe
/// - subtask-number (int, none): Nummer der Teilaufgabe; `0` meint die Aufgabe selbst, `none` alle Teile
/// -> content
#let expectation-texts(task-number, subtask-number: 0) = expectation-entries(
  task-number,
  subtask-number: subtask-number,
  format: (text, points, last) => {
    if last [#sym.dots #text] else [#sym.dots #text\ ]
  },
)

/// Setzt die Punktsumme der Erwartungen einer Aufgabe oder Teilaufgabe.
///
/// - task-number (int, str): Nummer der Aufgabe
/// - subtask-number (int, none): Nummer der Teilaufgabe; `0` meint die Aufgabe selbst, `none` alle Teile
/// - format (function): `points => content`; die Vorgabe lässt 0 Punkte leer
/// -> content
#let expectation-points(task-number, subtask-number: 0, format: points => if points > 0 [#points] else []) = context {
  format(matching-expectations(task-number, subtask-number).fold(0, (sum, entry) => sum + entry.points))
}

/// Setzt die Punktsumme aller Erwartungen des Dokuments.
///
/// - format (function): `points => content`
/// -> content
#let expectation-total(format: points => [#points]) = context {
  format(expectations.final().fold(0, (sum, entry) => sum + entry.points))
}

/// Notengrenzen der Oberstufe als Anteile (0 bis 15 Punkte).
#let grade-boundaries-sek-2 = (
  .0,
  .20, .27, .33,
  .40, .45, .50,
  .55, .60, .65,
  .70, .75, .80,
  .85, .90, .95,
)

/// Notennamen der Oberstufe, passend zu `grade-boundaries-sek-2`.
#let grade-names-sek-2 = (
  0,
  1, 2, 3,
  4, 5, 6,
  7, 8, 9,
  10, 11, 12,
  13, 14, 15,
)

/// Notengrenzen der Unter- und Mittelstufe als Anteile (6 bis 1+).
#let grade-boundaries-sek-1 = (
  .0,
  .20, .27, .33,
  .40, .45, .50,
  .55, .60, .65,
  .70, .75, .80,
  .85, .90, .95,
)

/// Notennamen der Unter- und Mittelstufe, passend zu `grade-boundaries-sek-1`.
#let grade-names-sek-1 = (
  "6",
  "5-", "5", "5+",
  "4-", "4", "4+",
  "3-", "3", "3+",
  "2-", "2", "2+",
  "1-", "1", "1+",
)

/// Notengrenzen ohne Tendenz als Anteile (6 bis 1).
#let grade-boundaries-plain = (
  .0,
  .20,
  .40,
  .55,
  .70,
  .85,
)

/// Notennamen ohne Tendenz, passend zu `grade-boundaries-plain`.
#let grade-names-plain = (
  "6",
  "5",
  "4",
  "3",
  "2",
  "1",
)

/// Setzt den Notenspiegel: Note, Prozent und Punktschwelle, berechnet aus der
/// Punktsumme aller Erwartungen.
///
/// - boundaries (array): Notengrenzen als Anteile, aufsteigend
/// - names (array): Notennamen, gleich viele wie `boundaries`
/// -> content
#let grade-table(boundaries: grade-boundaries-sek-2, names: grade-names-sek-2) = context {
  if boundaries.len() != names.len() {
    fail("gutachten", "internal.grade-table", "`boundaries` hat " + str(boundaries.len()) + " Einträge, `names` hat " + str(names.len()) + " – beide Listen gleich lang machen")
  }

  let total = expectations.final().fold(0, (sum, entry) => sum + entry.points)

  let cells = ([Note],)
  for name in names.rev() {
    cells.push([#name])
  }
  cells.push([Prozent])
  for boundary in boundaries.rev() {
    cells.push([#{ calc.round(boundary * 100) }%])
  }
  cells.push([Schwelle])
  for boundary in boundaries.rev() {
    cells.push([#{ calc.floor(total * boundary) }])
  }

  set text(size: 8pt)
  table(
    columns: boundaries.len() + 1,
    fill: white,
    align: center + horizon,
    ..cells
  )
}

// Füllfarbe der Kopf- und Summenzellen.
#let highlight-fill = luma(240)

// Ausrichtung der Zellen im Erwartungshorizont.
#let expectations-align(column, row) = {
  if column in (0, 2, 3) { center + horizon } else if row == 0 { horizon } else { left }
}

// Kopf- und Fußzeile des Erwartungshorizonts um die Zellen der Aufgaben.
#let expectations-table(cells) = table(
  columns: (auto, 1fr, auto),
  inset: 7pt,
  align: expectations-align,
  table.cell(fill: highlight-fill)[*Aufg.*],
  table.cell(fill: highlight-fill)[Die Schülerin / Der Schüler #sym.dots.h],
  table.cell(fill: highlight-fill)[*mögl. \ Punkte*],
  ..cells,
  table.cell(fill: highlight-fill)[],
  table.cell(fill: highlight-fill)[
    #set align(right)
    *Insgesamt*:
  ],
  table.cell(fill: highlight-fill)[*#expectation-total()*],
)

/// Setzt den Erwartungshorizont der Unter- und Mittelstufe auf einer neuen
/// Seite: je Aufgabe eine Zeile, je Teilaufgabe eine Zeile „a)“, „b)“ …
///
/// -> content
#let expectations-sek-1() = [
  #pagebreak()
  = Erwartungshorizont <schule-gutachten-expectations>

  #context {
    let cells = expectation-tasks
      .final()
      .map(task => {
        let cells = (
          [*#{ task.task-number }*],
          [#expectation-texts(task.task-number)],
          [#expectation-points(task.task-number)],
        )

        for index in range(task.subtask-count) {
          cells.push(numbering("a)", index + 1))
          cells.push(expectation-texts(task.task-number, subtask-number: index + 1))
          cells.push(expectation-points(task.task-number, subtask-number: index + 1))
        }

        cells
      })
      .flatten()

    expectations-table(cells)
  }
]

/// Setzt den Erwartungshorizont der Oberstufe auf einer eigenen Seite: je
/// Aufgabe eine Kopfzeile mit Titel und Summe, je Teilaufgabe eine Zeile
/// „1.1“, „1.2“ …
///
/// -> content
#let expectations-sek-2() = page()[
  = Erwartungshorizont <schule-gutachten-expectations>

  #context {
    let cells = expectation-tasks
      .final()
      .map(task => {
        let cells = (
          table.cell(fill: highlight-fill)[*#{ task.task-number }*],
          table.cell(fill: highlight-fill)[_#{ task.title }_],
          table.cell(fill: highlight-fill)[*#expectation-points(task.task-number, subtask-number: none)*],
        )

        if task.subtask-count == 0 {
          cells.push([])
          cells.push(expectation-texts(task.task-number, subtask-number: none))
          cells.push(expectation-points(task.task-number, subtask-number: none))
        }

        for index in range(task.subtask-count) {
          cells.push([#{ task.task-number }.#{ numbering("1", index + 1) }])
          cells.push(expectation-texts(task.task-number, subtask-number: index + 1))
          cells.push(expectation-points(task.task-number, subtask-number: index + 1))
        }

        cells
      })
      .flatten()

    expectations-table(cells)
  }
]

/// Setzt die Bewertungstabelle: je Aufgabe und Teilaufgabe eine Spalte mit den
/// möglichen Punkten und einer leeren Zeile für die erreichten Punkte.
///
/// -> content
#let points-table() = box(width: 100%)[
  #set align(center)
  = Bewertung <schule-gutachten-points-table>

  #context {
    let entries = expectation-tasks.final()

    let number-cells = entries
      .map(task => {
        let cells = (table.cell(fill: highlight-fill)[*#{ task.task-number }*],)
        for index in range(task.subtask-count) {
          cells.push(table.cell(fill: white)[#{ task.task-number }.#{ numbering("1", index + 1) }])
        }
        cells
      })
      .flatten()

    let possible-cells = entries
      .map(task => {
        let cells = (
          table.cell(fill: highlight-fill)[*#expectation-points(task.task-number, subtask-number: none)*],
        )
        for index in range(task.subtask-count) {
          cells.push(table.cell(fill: white)[#expectation-points(task.task-number, subtask-number: index + 1)])
        }
        cells
      })
      .flatten()

    let achieved-cells = entries
      .map(task => {
        let cells = (table.cell(fill: highlight-fill)[],)
        for index in range(task.subtask-count) {
          cells.push(table.cell(fill: white)[])
        }
        cells
      })
      .flatten()

    align(center, table(
      columns: (1.9cm, ..(number-cells.len() * (auto,)), 1.5cm),
      inset: 7pt,
      stroke: 1pt + black,
      align: (column, row) => {
        if column == 0 { left + horizon } else { horizon + center }
      },
      table.cell(fill: highlight-fill)[*Aufgabe*],
      ..number-cells,
      table.cell(fill: highlight-fill)[*Insgesamt*:],
      table.cell(fill: highlight-fill)[*mögl. \ Punkte*],
      ..possible-cells,
      table.cell(fill: highlight-fill)[*#expectation-total()*],
      table.cell(fill: highlight-fill)[*Punkte*],
      ..achieved-cells,
      table.cell(fill: highlight-fill)[#v(6mm)],
    ))
  }
]
