#import "@schule/patterns:0.0.1": kariert

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
) = [

  #set page(paper: "a3", margin: 0cm, flipped: true, header: none, footer: none)
  #set text(12pt, font: "Myriad Pro")

  #let real-rand = rand
  #if not weißer-rand {
    rand = 0cm
  }

  #let klausurbogen(result: false, name: "", note-content: [], student-table: [], grade-table: [], mv: mv, sub: sub, vorschlag: vorschlag, line-stroke: line-stroke) = [
    #let insetPageNumber = 6mm

    #let header(title: "", subtitle: "", class: "", date: "", teacher: "", logo: []) = {
      set text(font: "Myriad Pro", hyphenate: true, lang: "de")
      import "@preview/tablex:0.0.9": tablex, rowspanx, cellx,
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

    #let heigth = if sub and result-table {
      6cm
    } else if sub {
      3cm
    } else {
      8cm
    }
    #table(stroke: none, inset: 0cm, rows: 1fr, columns: 2 * (1fr,),
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
          #box(
            inset: (top: 7mm, left: 4mm, right: 10mm),
            height: heigth,
            [
              #if result {
                hide(header(title: exam, subtitle: subexam, date: date, class: class, teacher: teacher, logo: image("logo.svg")))
              } else {
                header(title: exam, subtitle: subexam, date: date, class: class, teacher: teacher, logo: image("logo.svg"))
              }
              #box(inset: (top: -1mm))[
                #table(inset: (top: 0pt, left: 0pt, right: 0pt, bottom: 3mm), stroke: none, columns: (auto, 1fr, auto, 1fr), align: (left, left, left, center),
                  [#if not result [#text(14pt, weight: "semibold")[Name:]]],
                  ..if not result {
                    ([],)
                  },
                  [#text(14pt, weight: "semibold")[
                      #if not sub [#if not result [Ergebnis:]] else if not vorschlag == false [#if not result [#h(1fr)#vorschlag:]#h(2cm)]
                    ]],if not result {
                    table.hline(stroke: 0.5pt + gray)
                  },
                  [#if result and not sub [#note-content] ]
                )
              ]
              #student-table
              #if not sub [
                #grade-table
              ]
            ],
          )
        ]
        #table(stroke: none /*0.5pt+rgb(129,129,129)*/, inset: 0cm, rows: 1fr, columns: (1fr, rand),
      [
        #if not result {place(top+left,kariert(height: 30cm - if sub and result-table {6cm} else if sub {3cm} else {8cm} - 0.5cm, grid-size: scale*0.5cm))}
      ],
    )
        #if not result and exam != "" {
          place(bottom + right, [#box(inset: insetPageNumber, [#box(fill: white, text(size: 16pt, [*1*]))])])
        }
        #if not weißer-rand and not result {
          place(top + right, line(stroke: line-stroke, start: (-real-rand, 0% + heigth + 5mm), end: (-real-rand, 100%)))
        }
      ]
    )
    #if not result [
      #table(stroke: none, inset: 0cm, rows: 1fr, columns: 2 * (1fr,),
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
          #table(stroke: none /*0.5pt+rgb(129,129,129)*/, inset: 0cm, rows: 1fr, columns: (1fr, rand),
      [
        #place(top+left, kariert(height: 30cm, grid-size: scale*0.5cm))
      ],
      [

      ]
    )
          #if exam != "" [#place(bottom + right, [#box(inset: insetPageNumber, [#box(fill: white, text(size: 16pt, [*3*]))])])]
          #if not weißer-rand and not result {
            place(top + right, line(stroke: line-stroke, start: (-real-rand, 0%), end: (-real-rand, 100%)))
          }
        ]
      )
    ]
  ]

  #let print-color = white
  #if result {
    print-color = black
  }
  //#set text(12pt, fill: print-color, font: "Myriad Pro")

  #let gradeBoundaries(maxPoints: 100) = {
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
          } + 2pt,
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
          } + 1pt,
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

  #let note-display(percentage: 0.9462, note: 6) = {
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

  #let studentHeader(name: "Max Mustermann", percentage: 0.8462, note: 6) = {
    grid(
      gutter: 10pt,
      [#text(12pt)[#name]],
      [#grid(
          columns: (auto, 1fr, auto),
          text(12pt)[#exam], [], text(12pt, gray, weight: "semibold")[#date],
        )
        #place(center, dy: -1em, note-display(percentage: percentage, note: note))]
    )
  }

  #let createTable(cols: none, maxPoints: none, achievedPoints: none, result: false) = {
    import "@preview/tablex:0.0.9": tablex, colspanx, rowspanx, cellx
    let headerRow = ()
    let subtaskRow = ()
    let numberOfColumns = 0
    let alphabet-i = "abcdefghijklmnopqrstuvwxyz"

    let subtasks = cols.values().filter(x => x != 0).len() > 0
    for (key, value) in cols {
      if (value > 1) {
        headerRow.push(colspanx(value)[*#key*])
        for subtask in range(0, value) {
          if sek1 {
            subtaskRow.push(alphabet-i.at(subtask) + ")")
          } else {
            if numbering == "a)" {
              subtaskRow.push([#{
                  alphabet-i.at(subtask)
                })])
            } else {
              subtaskRow.push([#{
                  subtask + 1
                }])
            }
          }
        }
      } else {
        if subtasks {
          headerRow.push(rowspanx(2)[*#key*])
        } else {
          headerRow.push([*#key*])
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
            [*Aufgabe*],
            ..headerRow,
            [$sum$],
            ..subtaskRow.map(x => [*#x*]),
            text(size: 8pt, [*mögliche Punkte*]),
            ..maxPoints.map(x => if result {
              cellx(inset: 0mm, text(size: 10pt, fill: black, str(x).replace(".", ",")))
            }),
            if result {
              cellx(inset: 0mm, text(size: 10pt, fill: black, str(maxPoints.sum()).replace(".", ",")))
            },
            text(size: 8pt, [*erreichte Punkte*]),
            ..if result {
              achievedPoints.map(x => cellx(inset: 0mm, text(size: 10pt, fill: black, str(x).replace(".", ","))))
            },
            if result {
              cellx(inset: 0mm, text(size: 10pt, fill: black, str(achievedPoints.sum()).replace(".", ",")))
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
            rowspanx(2)[*Aufgabe*],
            ..headerRow,
            rowspanx(2)[$sum$],
            ..subtaskRow.map(x => [*#x*]),
            text(size: 8pt, [*mögliche Punkte*]),
            ..maxPoints.map(x => if result {
              cellx(inset: 0mm, text(size: 10pt, fill: black, str(x).replace(".", ",")))
            }),
            if result {
              cellx(inset: 0mm, text(size: 10pt, fill: black, str(maxPoints.sum()).replace(".", ",")))
            },
            text(size: 8pt, [*erreichte Punkte*]),
            ..if result {
              achievedPoints.map(x => cellx(inset: 0mm, text(size: 10pt, fill: black, str(x).replace(".", ","))))
            },
            if result {
              cellx(inset: 0mm, text(size: 10pt, fill: black, str(achievedPoints.sum()).replace(".", ",")))
            },
          ),
        )
      }
    }
  }

  #v(1fr)
  #{
    let cols = (:)
    let maxPoints = ()
    if exam != "" {
      if students.len() == 0 {
        klausurbogen(result: result, name: "", note-content: [], student-table: createTable(cols: cols, maxPoints: 1, achievedPoints: 1, result: result), grade-table: gradeBoundaries(maxPoints: 1))
      } else {
        for (key, value) in students.enumerate() {
          if (key == 0) {
            let n = 2
            while (n < value.len()) {
              if (value.at(n).contains(".")) {
                let aufgabe = str(value.at(n).split(".").at(0))
                cols.insert(aufgabe, cols.at(aufgabe) + 1) //
              } else if (value.at(n).contains(" ")) {
                let aufgabe = value.at(n).split(" ").at(0)
                cols.insert(aufgabe, cols.at(aufgabe) + 1)
              } else {
                cols.insert(value.at(n), 0)
              }
              n = n + 1
            }
          } else if (key == 1) {
            let n = 2

            while (n < value.len()) {
              if (not value.at(n).contains(" ")) {
                maxPoints.push(float(value.at(n)))
              }
              n += 1
            }
          } else {
            let name = value.at(0)
            let note = value.at(1)
            let n = 2
            let points = ()

            while (n < value.len()) {
              if (not value.at(n).contains(" ") and value.at(n) != "") {
                points.push(float(value.at(n)))
              } else if (not value.at(n).contains(" ")) {
                points.push(0)
              }
              n += 1
            }


            klausurbogen(
              result: result,
              name: name,
              mv: mv,
              note-content: note-display(percentage: points.sum() / maxPoints.sum(), note: note),
              student-table: createTable(cols: cols, maxPoints: maxPoints, achievedPoints: points, result: result),
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