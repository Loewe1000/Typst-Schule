#import "@schule/patterns:0.0.1": kariert

// ─── Kopf des Bogens ─────────────────────────────────────────────────────────
//
// Kopf und Namenszeile stehen hier einmal, damit der klassische Bogen
// (`klausurbögen`) und die Arbeit auf dem Bogen (`bogen-seiten`) dieselbe
// Geometrie haben. Nur so trifft der Ergebnisdruck (`result: true`) auch auf
// eine Arbeit, die direkt auf den Bogen gedruckt wurde.

#let _bogen-kopf(title: "", subtitle: "", class: "", date: "", teacher: "", logo: [], result: false) = {
  set text(font: "Myriad Pro", hyphenate: true, lang: "de")
  import "@preview/tablex:0.0.9": cellx, rowspanx, tablex
  tablex(
    columns: (2.5cm, 1fr, 2.5cm),
    row: (1fr,) * 2,
    align: center + horizon,
    stroke: none,
    inset: 3pt,
    ..if logo != [] {
      (
        rowspanx(2, align: left + horizon, inset: 0pt)[#text(16pt, weight: "semibold")[#box(height: 1cm)[#logo]]],
        rowspanx(2)[#stack(spacing: 2mm, text(16pt, weight: "semibold")[#title], text(12pt, weight: "regular")[#subtitle])],
        cellx(align: right + horizon)[#date],
        cellx(align: right + horizon)[#class - #teacher],
      )
    } else {
      (
        [],
        rowspanx(2)[#text(16pt, weight: "semibold")[#title]],
        cellx(align: right + horizon)[#date],
        [],
        cellx(align: right + horizon)[#class - #teacher],
      )
    },
  )

  if result {
    move(dy: -1em, line(length: 100%, stroke: 0.5pt + white))
  } else {
    move(dy: -1em, line(length: 100%, stroke: 0.5pt + luma(200)))
  }
}

#let _bogen-namenszeile(result: false, sub: false, vorschlag: false, note-content: [], name: none) = box(inset: (top: -1mm))[
  #table(
    inset: (top: 0pt, left: 0pt, right: 0pt, bottom: 3mm),
    stroke: none,
    columns: (auto, 1fr, auto, 1fr),
    align: (left, left, left, center),
    [#if not result [#text(14pt, weight: "semibold")[Name:]] else if name != none {
      // Der Name steht ganz klein und grau über dem vorgedruckten „Name:", nicht
      // auf der Schreiblinie, damit er den handschriftlichen Namen nicht
      // überdruckt. Mit `place`, damit Note und Tabelle nicht verrutschen.
      place(dy: -3.5mm, box(width: 100mm, text(7pt, fill: luma(40%))[#name]))
    }],
    ..if not result {
      ([],)
    },
    [#text(14pt, weight: "semibold")[
      #if not sub [#if not result [Ergebnis:]] else if not vorschlag == false [#if not result [#h(1fr)#vorschlag:]#h(2cm)]
    ]],
    if not result {
      table.hline(stroke: 0.5pt + gray)
    },
    [#if result and not sub [#note-content] ],
  )
]


// Der Kopfbereich von Seite 1: Kopf, Namenszeile, Punktetabelle, Notenschlüssel.
// Derselbe Aufbau für den leeren Bogen, den Ergebnisdruck und die Arbeit auf
// dem Bogen — so liegen Tabelle und Note bei allen an derselben Stelle.
#let _bogen-kopfbox(kopf: [], namenszeile: [], student-table: [], grade-table: [], sub: false, heigth: auto) = box(
  inset: (top: 7mm, left: 4mm, right: 10mm),
  height: heigth,
  [
    #kopf
    #namenszeile
    #student-table
    #if not sub [
      #grade-table
    ]
  ],
)

// Höhe des Kopfbereichs auf Seite 1, wie im klassischen Bogen.
#let _bogen-kopfhoehe(sub: false, result-table: true) = if sub and result-table {
  6cm
} else if sub {
  3cm
} else {
  8cm
}

// ─── Tabellen und Note des Ergebnisdrucks ────────────────────────────────────
//
// Früher innere Funktionen von `klausurbögen`; herausgehoben, damit die Arbeit
// auf dem Bogen (`bogen-seiten`) dieselbe Tabelle an dieselbe Stelle setzen kann.

#let _notentabelle(maxPoints: 100, sek1: false, result: false, mv: (dx: 0cm, dy: 0cm)) = {
  let print-color = if result { black } else { white }
  import "@preview/tablex:0.0.9": tablex, vlinex
  let gradeBordersSek1 = (0.875, 0.75, 0.625, 0.5, 0.2, 0)
  let gradeBordersSek2 = (0.95, 0.90, 0.85, 0.80, 0.75, 0.70, 0.65, 0.60, 0.55, 0.50, 0.45, 0.40, 0.33, 0.27, 0.20, 0)
  let gradeRegions = ()
  let lastLowerBound = 0
  let gradeBorders = ()
  let grades = ()

  if sek1 {
    gradeBorders = gradeBordersSek1
    grades = range(1, 7).map(x => [*#x*])
  } else {
    gradeBorders = gradeBordersSek2
    grades = range(0, 16).map(x => [*#x*]).rev()
  }

  let seperationLines = ()

  for (index, value) in gradeBorders.enumerate() {
    let calculatedBorder = value * maxPoints
    let roundedBorder = calc.round(2 * value * maxPoints, digits: 0) / 2

    if (roundedBorder < calculatedBorder) {
      roundedBorder += 0.5
    }

    let upperBound
    let lowerBound

    if (index == 0) {
      upperBound = maxPoints
    } else {
      upperBound = lastLowerBound - 0.5
    }

    lowerBound = roundedBorder
    lastLowerBound = lowerBound


    if sek1 {
      gradeRegions.push(text(fill: black, (str(upperBound) + " - " + str(lowerBound)).replace(".", ",")))
    } else {
      gradeRegions.push(text(fill: black, size: 9pt, par(leading: 0.6em, [#str(lowerBound).replace(".", ",")])))
      seperationLines = (1, 4, 7, 10, 13, 16).map(x => vlinex(
        x: x,
        stroke: if result {
          black.lighten(50%)
        } else {
          white
        }
          + 2pt,
      ))
    }
  }

  set text(9pt)
  if result {
    move(
      ..mv,
      tablex(
        columns: (auto,) + (1fr,) * gradeBorders.len(),
        inset: 6pt,
        stroke: if result {
          print-color
        } else {
          print-color
        }
          + 1pt,
        align: center + horizon,
        ..seperationLines,
        [*Note*],
        ..grades,
        [#if sek1 [*Punktegrenzen*] else [*Punktegrenze $>=$*] ],
        ..if result {
          gradeRegions
        },
      ),
    )
  }
}

#let _note-anzeige(percentage: 0.9462, note: 6, sek1: false, sub: false, mv: (dx: 0cm, dy: 0cm)) = {
  if not sub {
    let finelinerRed = rgb("E90817")

    let grade
    if (sek1) {
      let grades = ("sehr gut", "gut", "befriedigend", "ausreichend", "mangelhaft", "ungenügend")
      grade = grades.at(int(note) - 1)
    } else {
      if (int(note) < 10) {
        grade = note
      } else {
        grade = note
      }

      if (int(note) == 1) {
        grade += [ Punkt]
      } else {
        grade += [ Punkte]
      }
    }

    let gradeInPercent = calc.round(percentage * 100, digits: 2)
    let stringGradeInPercent = str(gradeInPercent).replace(".", ",")
    let nachkomma = stringGradeInPercent.split(",")
    if (nachkomma.len() == 1) {
      stringGradeInPercent += ",00"
    } else {
      if (nachkomma.at(1).len() == 1) {
        stringGradeInPercent += "0"
      }
    }
    move(..mv, text(14pt, finelinerRed, weight: "bold")[#stringGradeInPercent % #h(2mm) $eq.est$ #h(2mm) #grade])
  }
}

#let _punktetabelle(cols: none, maxPoints: none, achievedPoints: none, result: false, sek1: false, numbering: "a)", mv: (dx: 0cm, dy: 0cm), teil: "alles") = {
  // teil: "alles" druckt die ganze Tabelle (klassischer Ergebnisdruck),
  // "rahmen" nur Linien, Köpfe und mögliche Punkte (Vordruck auf der Arbeit),
  // "werte" nur die erreichten Punkte und ihre Summe (Ergebnisdruck auf einen
  // Bogen mit Vordruck). Ausgeblendetes wird mit `hide` gesetzt, damit die
  // Tabelle in allen drei Fällen genau gleich groß ist.
  assert(teil in ("alles", "rahmen", "werte"), message: "teil: \"alles\", \"rahmen\" oder \"werte\"")
  let print-color = if result and teil != "werte" { black } else { white }
  let R(x) = if teil == "werte" { hide(x) } else { x }
  let W(x) = if teil == "rahmen" { hide(x) } else { x }
  import "@preview/tablex:0.0.9": cellx, colspanx, rowspanx, tablex
  let headerRow = ()
  let subtaskRow = ()
  let numberOfColumns = 0
  let alphabet-i = "abcdefghijklmnopqrstuvwxyz"

  let subtasks = cols.values().filter(x => x != 0).len() > 0
  for (key, value) in cols {
    if (value > 1) {
      headerRow.push(colspanx(value)[#R[*#key*]])
      for subtask in range(0, value) {
        if sek1 {
          subtaskRow.push(alphabet-i.at(subtask) + ")")
        } else {
          if numbering == "a)" {
            subtaskRow.push([#{ alphabet-i.at(subtask) })])
          } else {
            subtaskRow.push([#{
              subtask + 1
            }])
          }
        }
      }
    } else {
      if subtasks {
        headerRow.push(rowspanx(2)[#R[*#key*]])
      } else {
        headerRow.push(R[*#key*])
      }
    }

    if (value == 0) {
      numberOfColumns += 1
    }
    numberOfColumns += value
  }
  if result {
    if not subtasks {
      move(
        ..mv,
        tablex(
          columns: (auto,) + (1fr,) * (numberOfColumns + 1),
          inset: 6pt,
          stroke: if result {
            print-color + 1pt
          } else {
            print-color + 1pt
          },
          align: horizon + center,
          R[*Aufgabe*],
          ..headerRow,
          R[$sum$],
          ..subtaskRow.map(x => R[*#x*]),
          R(text(size: 8pt, [*mögliche Punkte*])),
          ..maxPoints.map(x => if result {
            cellx(inset: 0mm, R(text(size: 10pt, fill: black, str(x).replace(".", ","))))
          }),
          if result {
            cellx(inset: 0mm, R(text(size: 10pt, fill: black, str(maxPoints.sum()).replace(".", ","))))
          },
          R(text(size: 8pt, [*erreichte Punkte*])),
          ..if result {
            achievedPoints.map(x => cellx(inset: 0mm, W(text(size: 10pt, fill: black, str(x).replace(".", ",")))))
          },
          if result {
            cellx(inset: 0mm, W(text(size: 10pt, fill: black, str(achievedPoints.sum()).replace(".", ","))))
          },
        ),
      )
    } else {
      import "@preview/tablex:0.0.9": tablex
      move(
        ..mv,
        tablex(
          columns: (auto,) + (1fr,) * (numberOfColumns + 1),
          inset: 6pt,
          stroke: if result {
            print-color + 1pt
          } else {
            print-color + 1pt
          },
          align: horizon + center,
          map-cols: (col, cells) => cells.map(c => if c == none {
            c
          } else {
            (
              ..c,
              fill: if col > numberOfColumns {
                if result {
                  print-color.lighten(90%)
                } else {
                  print-color
                }
              },
            )
          }),
          rowspanx(2)[#R[*Aufgabe*]],
          ..headerRow,
          rowspanx(2)[#R[$sum$]],
          ..subtaskRow.map(x => R[*#x*]),
          R(text(size: 8pt, [*mögliche Punkte*])),
          ..maxPoints.map(x => if result {
            cellx(inset: 0mm, R(text(size: 10pt, fill: black, str(x).replace(".", ","))))
          }),
          if result {
            cellx(inset: 0mm, R(text(size: 10pt, fill: black, str(maxPoints.sum()).replace(".", ","))))
          },
          R(text(size: 8pt, [*erreichte Punkte*])),
          ..if result {
            achievedPoints.map(x => cellx(inset: 0mm, W(text(size: 10pt, fill: black, str(x).replace(".", ",")))))
          },
          if result {
            cellx(inset: 0mm, W(text(size: 10pt, fill: black, str(achievedPoints.sum()).replace(".", ","))))
          },
        ),
      )
    }
  }
}


/// Erstellt personalisierte Klausurbögen im A3-Querformat für eine ganze Klasse.
///
/// Für jeden Schüler im `students`-Array wird ein eigener Klausurbogen erzeugt.
/// Das karierte Schreibfeld wird automatisch aus `@schule/patterns` importiert.
///
/// ```typ
/// #klausurbögen(
///   exam: "Mathematik", class: "10a", date: "15.03.2025",
///   students: ("Max Mustermann", "Erika Musterfrau"),
/// )
/// ```
///
/// - exam (string): Fachname der Klausur. Standard: `""`.
/// - subexam (string): Untertitel / Thema der Klausur. Standard: `""`.
/// - teacher (string): Kürzel oder Name der Lehrkraft. Standard: `"SLZ"`.
/// - class (string): Klassenbezeichnung. Standard: `"PH1"`.
/// - date (string): Datum der Klausur. Standard: `"09.10.2023"`.
/// - students (array): Array mit Schülernamen. Standard: `()`.
/// - sek1 (bool): Sek-I-Modus (kleineres Feld). Standard: `false`.
/// - result (bool): Ergebnisseite generieren. Standard: `false`.
/// - rand (length): Randbreite für das Schreibfeld. Standard: `5cm`.
/// - scale (float): Skalierungsfaktor. Standard: `1`.
/// - sub (bool): Unterpunkt-Modus. Standard: `false`.
/// - numbering (string): Nummerierungsformat für Unterpunkte. Standard: `"a)"`.
/// - mv (dictionary): Verschiebung `(dx: ..., dy: ...)`. Standard: `(dx: 0cm, dy: 0cm)`.
/// - weißer-rand (bool): Weißen Rand verwenden (für farbige Seiten). Standard: `true`.
/// - result-table (bool): Ergebnistabelle anzeigen. Standard: `true`.
/// - vorschlag (bool): Korrekturvorschlag-Modus. Standard: `false`.
/// - line-stroke (stroke): Strichstärke und Farbe der Linien. Standard: `1pt + rgb("FF0613")`.
/// - vordruck (bool, str): Nur mit `result: true`, für Arbeiten, die mit
///   `bogen-seiten` direkt auf den Bogen gedruckt wurden. Standardmäßig ist dort
///   nur der Platz für die Tabelle frei; der Ergebnisdruck setzt dann die ganze
///   Tabelle, die Note und den Notenschlüssel an genau diese Stelle (wie
///   `false`). `"werte"`: Die Tabelle wurde mit `bogen-seiten(tabelle: true)`
///   schon mitgedruckt; dann nur erreichte Punkte, Summe, Note und
///   Notenschlüssel. Standard: `false`.
/// - namen (bool): Nur mit `result: true`. Druckt den Namen aus der ersten
///   Spalte klein hinter „Name:", zur Kontrolle der Reihenfolge beim Drucken.
///   Standard: `false`.
/// -> content
#let klausurbögen(
  exam: "",
  subexam: "",
  teacher: "SLZ",
  class: "PH1",
  date: "09.10.2023",
  students: (),
  sek1: false,
  result: false,
  rand: 5cm,
  scale: 1,
  sub: false,
  numbering: "a)",
  mv: (dx: 0cm, dy: 0cm),
  weißer-rand: true,
  result-table: true,
  vorschlag: false,
  line-stroke: 1pt + rgb("FF0613"),
  vordruck: false,
  namen: false,
) = [

  #set page(paper: "a3", margin: 0cm, flipped: true, header: none, footer: none)
  #set text(12pt, font: "Myriad Pro")

  #let real-rand = rand
  #if not weißer-rand {
    rand = 0cm
  }

  #let klausurbogen(result: false, name: "", note-content: [], student-table: [], grade-table: [], mv: mv, sub: sub, vorschlag: vorschlag, line-stroke: line-stroke) = [
    #let insetPageNumber = 6mm

    #let header(title: "", subtitle: "", class: "", date: "", teacher: "", logo: []) = _bogen-kopf(
      title: title, subtitle: subtitle, class: class, date: date, teacher: teacher, logo: logo, result: result,
    )

    #let heigth = if sub and result-table {
      6cm
    } else if sub {
      3cm
    } else {
      8cm
    }
    #table(
      stroke: none,
      inset: 0cm,
      rows: 1fr,
      columns: 2 * (1fr,),
      [
        #table(
          stroke: none,
          inset: 0cm,
          rows: 1fr,
          columns: (rand, 1fr),
          [

          ],
          [
            #if not result {
              place(top + right, kariert(height: 30cm, grid-size: scale * 0.5cm))
            }
          ],
        )
        #if not result and exam != "" {
          place(bottom + left, [#box(inset: insetPageNumber, [#box(fill: white, text(size: 16pt, [*4*]))])])
        }
        #if not weißer-rand and not result {
          place(top + left, line(stroke: line-stroke, start: (real-rand, 0%), end: (real-rand, 100%)))
        }
      ],
      [
        #if exam != "" [
          #_bogen-kopfbox(
            heigth: heigth,
            sub: sub,
            kopf: if result {
              hide(header(title: exam, subtitle: subexam, date: date, class: class, teacher: teacher, logo: image("logo.svg")))
            } else {
              header(title: exam, subtitle: subexam, date: date, class: class, teacher: teacher, logo: image("logo.svg"))
            },
            namenszeile: _bogen-namenszeile(result: result, sub: sub, vorschlag: vorschlag, note-content: note-content,
              name: if result and namen and name != "" { name } else { none }),
            student-table: student-table,
            grade-table: grade-table,
          )
        ]
        #table(
          stroke: none /*0.5pt+rgb(129,129,129)*/, inset: 0cm, rows: 1fr, columns: (1fr, rand),
          [
            #if not result { place(top + left, kariert(height: 30cm - if sub and result-table { 6cm } else if sub { 3cm } else { 8cm } - 0.5cm, grid-size: scale * 0.5cm)) }
          ],
        )
        #if not result and exam != "" {
          place(bottom + right, [#box(inset: insetPageNumber, [#box(fill: white, text(size: 16pt, [*1*]))])])
        }
        #if not weißer-rand and not result {
          place(top + right, line(stroke: line-stroke, start: (-real-rand, 0% + heigth + 5mm), end: (-real-rand, 100%)))
        }
      ],
    )
    #if not result [
      #table(
        stroke: none,
        inset: 0cm,
        rows: 1fr,
        columns: 2 * (1fr,),
        [
          #table(
            stroke: none,
            inset: 0cm,
            rows: 1fr,
            columns: (rand, 1fr),
            [

            ],
            [
              #place(top + right, kariert(height: 30cm, grid-size: scale * 0.5cm))
            ],
          )
          #if exam != "" [#place(bottom + left, [#box(inset: insetPageNumber, [#box(fill: white, text(size: 16pt, [*2*]))])])]
          #if not weißer-rand and not result {
            place(top + left, line(stroke: line-stroke, start: (real-rand, 0%), end: (real-rand, 100%)))
          }
        ],
        [
          #table(
            stroke: none /*0.5pt+rgb(129,129,129)*/, inset: 0cm, rows: 1fr, columns: (1fr, rand),
            [
              #place(top + left, kariert(height: 30cm, grid-size: scale * 0.5cm))
            ],
            [

            ]
          )
          #if exam != "" [#place(bottom + right, [#box(inset: insetPageNumber, [#box(fill: white, text(size: 16pt, [*3*]))])])]
          #if not weißer-rand and not result {
            place(top + right, line(stroke: line-stroke, start: (-real-rand, 0%), end: (-real-rand, 100%)))
          }
        ],
      )
    ]
  ]

  #let print-color = white
  #if result {
    print-color = black
  }
  //#set text(12pt, fill: print-color, font: "Myriad Pro")

  #let gradeBoundaries(maxPoints: 100) = _notentabelle(maxPoints: maxPoints, sek1: sek1, result: result, mv: mv)

  #let note-display(percentage: 0.9462, note: 6) = _note-anzeige(percentage: percentage, note: note, sek1: sek1, sub: sub, mv: mv)

  #let studentHeader(name: "Max Mustermann", percentage: 0.8462, note: 6) = {
    grid(
      gutter: 10pt,
      [#text(12pt)[#name]],
      [#grid(
          columns: (auto, 1fr, auto),
          text(12pt)[#exam], [], text(12pt, gray, weight: "semibold")[#date],
        )
        #if not sub [
          #place(center, dy: -1em, note-display(percentage: percentage, note: note))]
      ],
    )
  }

  #let createTable(cols: none, maxPoints: none, achievedPoints: none, result: false) = _punktetabelle(
    cols: cols, maxPoints: maxPoints, achievedPoints: achievedPoints, result: result,
    sek1: sek1, numbering: numbering, mv: mv, teil: if vordruck == "werte" { "werte" } else { "alles" },
  )

  #v(1fr)
  #{
    let cols = (:)
    let maxPoints = ()
    // Leere Zeilen (z. B. am Ende der CSV) ignorieren; leere Kopfspalten
    // (abschließendes Komma der CSV) werden in den Schleifen übersprungen.
    let students = students.filter(r => r.len() > 1 and r.any(c => c.trim() != ""))
    if exam != "" {
      if students.len() == 0 {
        klausurbogen(result: result, name: "", note-content: [], student-table: createTable(cols: cols, maxPoints: 1, achievedPoints: 1, result: result), grade-table: gradeBoundaries(maxPoints: 1))
      } else {
        // Erste Zeile: Header-Analyse für Spaltenstruktur
        if students.len() > 0 {
          let headerRow = students.at(0)
          let n = 2
          while (n < headerRow.len()) {
            let headerCell = headerRow.at(n)
            if headerCell.trim() == "" { n = n + 1; continue }

            // Erkenne Teilaufgaben durch verschiedene Muster
            let isSubtask = false
            let mainTask = ""

            // Muster: "A1 a)", "A2 b)", etc. - alle Buchstaben von a) bis z)
            if headerCell.contains(" ") and headerCell.match(regex("[a-z]\)$")) != none {
              isSubtask = true
              mainTask = headerCell.split(" ").at(0)
            } // Muster: "A1.1", "A2.2", etc.
            else if headerCell.contains(".") and headerCell.split(".").len() == 2 {
              let parts = headerCell.split(".")
              if parts.at(1).match(regex("^\d+$")) != none {
                isSubtask = true
                mainTask = parts.at(0)
              }
            }

            if isSubtask and mainTask != "" {
              // Ist eine Teilaufgabe
              if mainTask not in cols {
                cols.insert(mainTask, 1)
              } else {
                cols.at(mainTask) = cols.at(mainTask) + 1
              }
            } else {
              // Ist eine Hauptaufgabe ohne Teilaufgaben
              cols.insert(headerCell, 0)
            }
            n = n + 1
          }
        }

        for (key, value) in students.enumerate() {
          if (key == 1) {
            // Zweite Zeile: Maximalpunkte - nur für Spalten sammeln, die auch in der Struktur verwendet werden
            let headerRow = students.at(0)
            let n = 2
            let tempPoints = ()
            while (n < value.len() and n < headerRow.len()) {
              let headerCell = headerRow.at(n)
              if headerCell.trim() == "" { n += 1; continue }

              // Nur Punkte für Spalten sammeln, die keine Hauptaufgaben mit Teilaufgaben sind
              let isMainTaskWithSubtasks = false
              for (taskName, subtaskCount) in cols {
                if subtaskCount > 0 and headerCell == taskName {
                  isMainTaskWithSubtasks = true
                  break
                }
              }

              if not isMainTaskWithSubtasks and not value.at(n).contains(" ") {
                tempPoints.push(float(value.at(n)))
              }
              n += 1
            }
            maxPoints = tempPoints
          } else if (key > 1) {
            // Ab dritter Zeile: Schülerdaten - gleiche Logik wie bei Maximalpunkten
            let name = value.at(0)
            let note = value.at(1)
            let headerRow = students.at(0)
            let n = 2
            let tempPoints = ()

            while (n < value.len() and n < headerRow.len()) {
              let headerCell = headerRow.at(n)
              if headerCell.trim() == "" { n += 1; continue }

              // Nur Punkte für Spalten sammeln, die keine Hauptaufgaben mit Teilaufgaben sind
              let isMainTaskWithSubtasks = false
              for (taskName, subtaskCount) in cols {
                if subtaskCount > 0 and headerCell == taskName {
                  isMainTaskWithSubtasks = true
                  break
                }
              }

              if not isMainTaskWithSubtasks and not value.at(n).contains(" ") and value.at(n) != "" {
                tempPoints.push(float(value.at(n)))
              } else if not isMainTaskWithSubtasks and not value.at(n).contains(" ") {
                tempPoints.push(0)
              }
              n += 1
            }

            klausurbogen(
              result: result,
              name: name,
              mv: mv,
              note-content: note-display(percentage: tempPoints.sum() / maxPoints.sum(), note: note),
              student-table: createTable(cols: cols, maxPoints: maxPoints, achievedPoints: tempPoints, result: result),
              grade-table: gradeBoundaries(maxPoints: maxPoints.sum()),
            )
          }
        }
      }
    } else {
      klausurbogen(result: false)
    }
  }
]

// ─── Eine Arbeit direkt auf dem Bogen ────────────────────────────────────────
//
// Statt Karopapier stehen die Aufgaben selbst auf dem Bogen, ohne
// Korrekturrand. Der A3-Bogen wird als zweispaltige Seite gesetzt, der Text
// fließt Spalte für Spalte:
//
//   Bogen 1 (außen):  | Seite 4 | Seite 1 |
//   Bogen 2 (innen):  | Seite 2 | Seite 3 |
//
// Die linke Spalte des ersten Bogens ist die Rückseite (Seite 4). Sie kommt im
// Satz zuerst und bekommt deshalb festen Inhalt (`rueckseite`); danach springt
// der Text in die rechte Spalte, also auf Seite 1, und läuft von dort über
// Seite 2 nach Seite 3. So stehen die Aufgaben in der richtigen Reihenfolge,
// und Nummerierung und Punktezählung stimmen. Aufgaben auf Seite 4 gehen
// deshalb nicht: Sie kämen im Satz vor Seite 2 und würden falsch gezählt.
//
// Oben auf Seite 1 steht der Kopfbereich des klassischen Bogens. Die
// Punktetabelle darin ist dieselbe wie beim Ergebnisdruck und steht an genau
// derselben Stelle: Dafür wird der Kopfbereich zweimal übereinander gesetzt —
// einmal genau so, wie ihn der Ergebnisdruck aufbaut (Kopf und Note
// unsichtbar, von der Tabelle nur Linien, Köpfe und mögliche Punkte), und
// darüber der sichtbare Kopf mit der Namenszeile. Später druckt
// `klausurbögen(result: true, vordruck: true)` die erreichten Punkte, die Note
// und den Notenschlüssel in die freien Stellen.
//
// Gedruckt wird A3 quer, beidseitig, Wenden an der kurzen Kante; dann einmal
// in der Mitte falten.

/// Seiteneinstellungen und Satzanfang für eine Arbeit auf dem Klausurbogen.
///
/// Gibt ein Dictionary zurück:
/// - `page`: Argumente für `set page(..)` (A3 quer, zwei Spalten, Kopfbereich
///   und Seitenzahlen im Hintergrund)
/// - `gutter`: Spaltenabstand für `set columns(gutter: ..)` — zweimal `rand`,
///   damit auch zum Falz hin `rand` Platz bleibt
/// - `anfang`: Inhalt, der vor den Aufgaben stehen muss (Rückseite,
///   Spaltenwechsel, Platz für den Kopfbereich)
///
/// Für eine Arbeit ohne weiteres Paket gibt es die Vorlage
/// `klausurbogen-arbeit`, die das alles setzt.
///
/// - exam, subexam, teacher, class, date, sek1, sub, result-table, vorschlag,
///   numbering, mv: wie bei `klausurbögen`. Für den späteren Ergebnisdruck
///   müssen sie dort genauso gesetzt werden, sonst stimmt die Lage nicht.
/// - aufgaben (array, none): Spalten der Punktetabelle als Paare
///   `(name, punkte)`, z. B. `(("1", 4), ("2", 6))`, oder mit Teilaufgaben
///   `(name, (punkte-a, punkte-b, …))`, z. B. `(("A1", (3, 4, 5)), ("A2", 5))`.
///   Mit Teilaufgaben ist die Tabelle (und die freie Box) höher, so wie beim
///   Ergebnisdruck aus einer CSV mit Teilaufgabenspalten. `none` lässt den
///   Platz frei.
/// - rueckseite (content, auto): Inhalt von Seite 4. `auto` = „Platz für
///   Nebenrechnungen". Keine nummerierten Aufgaben!
/// - rand (length): Rand oben, außen und zum Falz hin. Standard: `12mm`.
/// - unten (length): Rand unten (Platz für die Seitenzahl). Standard: `16mm`.
/// - abstand (length): Abstand zwischen Kopfbereich und erster Aufgabe.
/// -> dictionary
#let bogen-seiten(
  exam: "",
  subexam: "",
  teacher: "",
  class: "",
  date: "",
  sek1: false,
  sub: false,
  result-table: true,
  vorschlag: false,
  numbering: "a)",
  mv: (dx: 0cm, dy: 0cm),
  aufgaben: none,
  tabelle: false,
  rueckseite: auto,
  rand: 12mm,
  unten: 16mm,
  abstand: 4mm,
) = {
  let hoehe = _bogen-kopfhoehe(sub: sub, result-table: result-table)
  let logo = image("logo.svg")

  // Punktetabelle und Notenschlüssel wie im Ergebnisdruck
  // Leer auch im ersten Layoutdurchlauf, in dem ein Paket die Aufgaben noch
  // nicht gezählt hat; Typst setzt danach noch einmal mit den echten Werten.
  //
  // `tabelle: false` (Standard): Auf dem Bogen steht nur eine ganz feine,
  // gestrichelte Box um den Platz von Tabelle und Notenschlüssel; beides kommt
  // erst mit dem Ergebnisdruck. Die Box nimmt keinen Platz ein (`outset`), und
  // zwischen Tabelle und Notenschlüssel liegt derselbe Blockabstand wie im
  // Ergebnisdruck — die Lage stimmt also auf den Millimeter.
  // `tabelle: true`: Linien, Köpfe und mögliche Punkte schon auf dem Bogen.
  let (punktetabelle, notentabelle) = if aufgaben == none or aufgaben.len() == 0 { ([], []) } else {
    let cols = (:)
    // Eine Aufgabe ist (name, punkte) oder (name, (punkte je Teilaufgabe …)).
    // Mit Teilaufgaben bekommt die Tabelle eine zweite Kopfzeile und eine
    // Spalte je Teilaufgabe — so wie der Ergebnisdruck aus einer CSV mit
    // Teilaufgaben ("A1 a)" …) sie baut. Die Box wird dadurch passend größer.
    for (name, p) in aufgaben { cols.insert(str(name), if type(p) == array { p.len() } else { 0 }) }
    let maximal = aufgaben.map(a => a.at(1)).flatten()
    let t = _punktetabelle(cols: cols, maxPoints: maximal, achievedPoints: maximal,
      result: true, sek1: sek1, numbering: numbering, mv: mv, teil: "rahmen")
    let n = hide(_notentabelle(maxPoints: maximal.sum(), sek1: sek1, result: true, mv: mv))
    if tabelle { (t, n) } else {
      (
        block(width: 100%, radius: 2mm, outset: (x: 2mm, y: 2mm),
          stroke: (paint: luma(60%), thickness: 0.6pt, dash: "dashed"), {
            hide(t)
            n
            // Der Hinweis steht genau in der Mitte der Box. Er ist so hell, dass
            // er unter dem späteren Ergebnisdruck nicht stört.
            place(center + horizon, text(size: 9pt, fill: luma(55%))[Bitte frei lassen])
          }),
        [],
      )
    }
  }

  // Der Kopfbereich, wie ihn der Ergebnisdruck aufbaut.
  let wie-ergebnis(h) = _bogen-kopfbox(
    heigth: h,
    sub: sub,
    kopf: hide(_bogen-kopf(title: exam, subtitle: subexam, date: date, class: class,
      teacher: teacher, logo: logo, result: true)),
    namenszeile: _bogen-namenszeile(result: true, sub: sub, vorschlag: vorschlag,
      note-content: hide(_note-anzeige(percentage: 1, note: 1, sek1: sek1, sub: sub, mv: mv))),
    student-table: punktetabelle,
    grade-table: notentabelle,
  )
  // Darüber der sichtbare Kopf mit Namenszeile, wie auf dem leeren Bogen.
  let sichtbar = _bogen-kopfbox(
    heigth: hoehe,
    sub: sub,
    kopf: _bogen-kopf(title: exam, subtitle: subexam, date: date, class: class,
      teacher: teacher, logo: logo),
    namenszeile: _bogen-namenszeile(sub: sub, vorschlag: vorschlag),
  )

  // `page.width` ist die Breite des ungedrehten Papiers; bei `flipped` ist
  // die Breite des Bogens die Höhe.
  let bogenbreite() = if page.flipped { page.height } else { page.width }

  let nummer(n) = box(inset: 6mm, box(fill: white,
    text(size: 16pt, font: "Myriad Pro", [*#n*])))

  // Der Bogen, auf dem wir sind, ist die physische Seite — unabhängig davon,
  // ob ein Paket den Seitenzähler zurücksetzt.
  let hintergrund = context {
    let bogen = here().page()
    let halb = bogenbreite() / 2
    if bogen == 1 {
      place(top + left, dx: halb, box(width: halb, wie-ergebnis(hoehe)))
      place(top + left, dx: halb, box(width: halb, sichtbar))
      place(bottom + left, nummer(4))
      place(bottom + right, nummer(1))
    } else if bogen == 2 {
      place(bottom + left, nummer(2))
      place(bottom + right, nummer(3))
    } else {
      place(center + horizon, box(fill: white, inset: 8mm, text(fill: red, weight: "bold",
        size: 20pt)[Die Arbeit passt nicht auf einen Klausurbogen: \
        Aufgaben dürfen nur auf den Seiten 1 bis 3 stehen.]))
    }
  }

  let anfang = {
    if rueckseite == auto {
      text(size: 9pt, fill: luma(55%))[Platz für Nebenrechnungen]
      kariert(rows: 52)
    } else {
      rueckseite
    }
    colbreak()
    // Seite 1 beginnt unter dem Kopfbereich. Die 8 cm sind nötig: Darin druckt
    // der Ergebnisdruck (`vordruck`) unter die Tabelle den Notenschlüssel, der
    // bis etwa 75 mm reicht. Braucht die Tabelle mehr Platz, rückt der Anfang
    // weiter nach unten.
    context {
      let h = measure(box(width: bogenbreite() / 2, wie-ergebnis(auto))).height
      v(calc.max(hoehe, h) - rand + abstand)
    }
  }

  (
    page: (
      paper: "a3",
      flipped: true,
      margin: (top: rand, bottom: unten, x: rand),
      columns: 2,
      header: none,
      footer: none,
      background: hintergrund,
    ),
    gutter: 2 * rand,
    anfang: anfang,
  )
}

/// Vorlage für eine Arbeit auf dem Klausurbogen, ohne weiteres Paket.
///
/// ```typ
/// #show: klausurbogen-arbeit.with(exam: "Klassenarbeit 1", class: "5a",
///   date: "01.10.2026", teacher: "SLZ", sek1: true,
///   aufgaben: (("1", 4), ("2", 6), ("3", 5)))
/// ```
///
/// Alle Argumente wie bei `bogen-seiten`.
/// -> content
#let klausurbogen-arbeit(..args, body) = {
  let b = bogen-seiten(..args)
  set page(..b.page)
  set columns(gutter: b.gutter)
  set text(12pt, font: "Myriad Pro", lang: "de")
  b.anfang
  body
}
