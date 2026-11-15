// klausurboegen – der Baustein `klausurboegen`
//
// Zusammengeführt aus den Ästen 0.0.4 (Ergebnisdruck mit Vordruck und Namen,
// Filter für leere CSV-Zeilen) und 0.0.5 (liniertes Schreibfeld, Lage des
// Korrekturrands, Seitenlayout). Die Helfer stehen in `internal.typ`.

#import "internal/check.typ": check-positional, fail
#import "internal.typ": (
  check-names, check-values, grade-boundaries, grade-display, points-table-content, sheet,
)

/// Erstellt Klausurbögen im A3-Querformat: einmal falten ergibt vier Seiten
/// mit Schreibfeld und Korrekturrand. Seite 1 trägt den Kopf mit Namenszeile
/// und Platz für Punktetabelle, Note und Notenschlüssel.
///
/// Ohne `title` entsteht ein Blankobogen ohne Kopf und Seitenzahlen. Mit
/// `results` (den Zeilen einer CSV-Datei) und `overprint: true` entsteht je
/// Schülerin und Schüler eine Seite, die nur Punktetabelle, Note und
/// Notenschlüssel enthält: Sie wird auf die beschriebenen Bögen gedruckt.
///
/// ```typ
/// #klausurboegen(
///   title: "Mathematik", subtitle: "Analysis",
///   class: "10a", teacher: "MÜ", date: "15.03.2026",
/// )
/// ```
///
/// - title (content, str, none): Titel im Kopf. `none`: Blankobogen ohne Kopf und Seitenzahlen.
/// - subtitle (content, str, none): Untertitel unter dem Titel.
/// - teacher (content, str, none): Kürzel oder Name der Lehrkraft.
/// - class (content, str, none): Klasse oder Kurs.
/// - date (content, str, none): Datum der Arbeit.
/// - logo (content, str, auto, none): Logo links im Kopf, zum Beispiel `image("logo.svg")`. `auto`: das Schullogo des Pakets. `none`: kein Logo; dann entfällt auch der Untertitel.
/// - results (array): Braucht `title`. Zeilen einer CSV-Datei, zum Beispiel `csv("ergebnisse.csv")`: Kopfzeile, Zeile der Maximalpunkte, dann je Schüler eine Zeile. Spalte 1 ist der Name, Spalte 2 die Note, ab Spalte 3 stehen die Aufgaben. Teilaufgaben heißen in der Kopfzeile `"A1 a)"` oder `"A1.1"`. Eine leere Zelle zählt 0 Punkte, Zellen mit Leerzeichen und leere Zeilen werden übersprungen. Je Schülerzeile entsteht ein Bogen.
/// - overprint (bool): Ergebnisdruck: nur Punktetabelle, Note und Notenschlüssel zum Überdrucken der beschriebenen Bögen. Braucht `results` und `title`.
/// - overprint-name (bool): Setzt beim Ergebnisdruck den Namen aus Spalte 1 klein über „Name:“, zur Kontrolle der Reihenfolge. Wirkt nur mit `overprint`.
/// - stage (str): `"sek-1"` (Noten 1 bis 6) oder `"sek-2"` (15 bis 0 Punkte); bestimmt den Notenschlüssel.
/// - continuation (bool): Folgebogen ohne Ergebnisbereich: kleinerer Kopf, kein „Ergebnis:“, keine Note.
/// - points-table (bool): Platz für die Punktetabelle im Kopf des Folgebogens. Wirkt nur mit `continuation`.
/// - points-table-preprinted (bool): Die Punktetabelle steht schon auf dem Bogen (Arbeit direkt auf dem Bogen mit Vordruck); der Ergebnisdruck setzt dann nur erreichte Punkte, Summe, Note und Notenschlüssel. Wirkt nur mit `overprint`.
/// - proposal (content, str, none): Beschriftung rechts in der Namenszeile des Folgebogens, zum Beispiel `"Vorschlag A"`. Wirkt nur mit `continuation`.
/// - subtask-numbering (str): Typst-Muster für die Teilaufgaben der Punktetabelle. Ein Zählzeichen bekommt die Teilnummer (`"a)"`); bei zweien (`"1.1"`) zählt nur der Teil für die Teilaufgabe. `"1."` ist vorerst gesperrt (früher gleichbedeutend mit `"1.1"`). Mit `stage: "sek-1"` stehen immer Buchstaben.
/// - pattern (str): Schreibfeld: `"squares"` (kariert) oder `"lines"` (liniert).
/// - grid-size (length): Kantenlänge eines Kästchens bei `pattern: "squares"`.
/// - line-height (length): Zeilenabstand bei `pattern: "lines"`.
/// - correction-margin (length): Breite des Korrekturrands.
/// - correction-margin-side (str): Lage des Korrekturrands: `"outside"` (am Blattrand, geschrieben wird an der Falz) oder `"inside"` (an der Falz).
/// - correction-margin-stroke (stroke): Linie, die den Korrekturrand abgrenzt. Wirkt nur mit `correction-margin-blank: false`.
/// - correction-margin-blank (bool): Der Korrekturrand bleibt weiß. `false`: Das Muster läuft durch, eine Linie grenzt den Rand ab.
/// - offset (dictionary): Verschiebung `(dx:, dy:)` von Tabelle, Note und Notenschlüssel beim Ergebnisdruck, zum Ausgleich des Druckers.
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> content
#let klausurboegen(
  title: none,
  subtitle: none,
  teacher: none,
  class: none,
  date: none,
  logo: auto,
  results: (),
  overprint: false,
  overprint-name: false,
  stage: "sek-2",
  continuation: false,
  points-table: true,
  points-table-preprinted: false,
  proposal: none,
  subtask-numbering: "a)",
  pattern: "squares",
  grid-size: 0.5cm,
  line-height: 8mm,
  correction-margin: 5cm,
  correction-margin-side: "outside",
  correction-margin-stroke: 1pt + rgb("FF0613"),
  correction-margin-blank: true,
  offset: (dx: 0cm, dy: 0cm),
  ..deprecated,
) = [
  #let settings = (
    title: title,
    subtitle: subtitle,
    teacher: teacher,
    class: class,
    date: date,
    logo: logo,
    results: results,
    overprint: overprint,
    overprint-name: overprint-name,
    stage: stage,
    continuation: continuation,
    points-table: points-table,
    points-table-preprinted: points-table-preprinted,
    proposal: proposal,
    subtask-numbering: subtask-numbering,
    pattern: pattern,
    grid-size: grid-size,
    line-height: line-height,
    correction-margin: correction-margin,
    correction-margin-side: correction-margin-side,
    correction-margin-stroke: correction-margin-stroke,
    correction-margin-blank: correction-margin-blank,
    offset: offset,
  )
  #{
    // 1. Sink prüfen: zuerst die Namen, dann die Positionsargumente. Mit
    // `#show: klausurboegen.with(exam: …)` ist der Dokumentrumpf ein
    // Positionsargument; der alte Name soll dann trotzdem gemeldet werden.
    check-names("klausurboegen", "klausurboegen", deprecated.named(), values: settings)
    check-positional(
      "klausurboegen",
      "klausurboegen",
      deprecated,
      hint: "`klausurboegen` nimmt keinen Rumpf – Werte benannt schreiben und als `#klausurboegen(title: …)` aufrufen, nicht mit `#show:`",
    )
    // 2. Typen und Werte der deklarierten Parameter prüfen
    check-values("klausurboegen", "klausurboegen", settings)
  }

  #set page(paper: "a3", margin: 0cm, flipped: true, header: none, footer: none)
  #set text(12pt, font: "Myriad Pro")

  #v(1fr)
  #{
    let function = "klausurboegen"
    // Punktezelle als Zahl; alles andere bekommt eine Meldung statt Typsts „invalid float".
    let points-number(cell, row-name, column-name) = {
      if cell.match(regex("^[+-]?(\\d+\\.?\\d*|\\.\\d+)$")) == none {
        fail(
          "klausurboegen",
          function,
          "`results`: `"
            + repr(cell)
            + "` in der Zeile `"
            + row-name
            + "`, Spalte `"
            + column-name
            + "`, ist keine Zahl – Punkte mit Dezimalpunkt schreiben, zum Beispiel `\"3.5\"`",
        )
      }
      float(cell)
    }

    let columns = (:)
    let max-points = ()
    // Leere Zeilen (z. B. am Ende der CSV) ignorieren; leere Kopfspalten
    // (abschließendes Komma der CSV) werden in den Schleifen übersprungen.
    let rows = results.filter(row => row.len() > 1 and row.any(cell => cell.trim() != ""))
    if title == none and overprint {
      fail(
        "klausurboegen",
        function,
        "`overprint: true` ohne `title` – der Ergebnisdruck braucht denselben Kopf wie der leere Bogen, `title` angeben",
      )
    }
    if title == none and rows.len() > 0 {
      fail(
        "klausurboegen",
        function,
        "`results` ohne `title` – der Blankobogen hat keine Namenszeile; `title` angeben oder `results` weglassen",
      )
    }
    if title != none {
      if rows.len() == 0 {
        if overprint {
          fail("klausurboegen", function, "`overprint: true` ohne `results` – Ergebniszeilen übergeben")
        }
        sheet(settings)
      } else if overprint and rows.len() < 3 {
        fail(
          "klausurboegen",
          function,
          "`overprint: true` mit "
            + str(rows.len())
            + if rows.len() == 1 { " Zeile" } else { " Zeilen" }
            + " in `results` – Kopfzeile, Maximalpunkte und je Schüler eine Zeile übergeben",
        )
      } else {
        // Erste Zeile: Kopfzeile bestimmt die Spaltenstruktur
        let header-row = rows.at(0)
        let n = 2
        while (n < header-row.len()) {
          let header-cell = header-row.at(n)
          if header-cell.trim() == "" {
            n = n + 1
            continue
          }

          // Teilaufgaben erkennen
          let is-subtask = false
          let main-task = ""

          // Muster: "A1 a)", "A2 b)" usw., alle Buchstaben von a) bis z)
          if header-cell.contains(" ") and header-cell.match(regex("[a-z]\)$")) != none {
            is-subtask = true
            main-task = header-cell.split(" ").at(0)
          } // Muster: "A1.1", "A2.2" usw.
          else if header-cell.contains(".") and header-cell.split(".").len() == 2 {
            let parts = header-cell.split(".")
            if parts.at(1).match(regex("^\d+$")) != none {
              is-subtask = true
              main-task = parts.at(0)
            }
          }

          if is-subtask and main-task != "" {
            if main-task not in columns {
              columns.insert(main-task, 1)
            } else {
              columns.at(main-task) = columns.at(main-task) + 1
            }
          } else {
            // Hauptaufgabe ohne Teilaufgaben
            columns.insert(header-cell, 0)
          }
          n = n + 1
        }

        // Punkte einer Zeile: nur Spalten, die keine Hauptaufgabe mit
        // Teilaufgaben sind; Zellen mit Leerzeichen werden übersprungen.
        let row-points(row, row-name, empty-is-zero) = {
          let points = ()
          let n = 2
          while (n < row.len() and n < header-row.len()) {
            let header-cell = header-row.at(n)
            if header-cell.trim() == "" {
              n += 1
              continue
            }
            let is-main-task-with-subtasks = false
            for (task-name, subtask-count) in columns {
              if subtask-count > 0 and header-cell == task-name {
                is-main-task-with-subtasks = true
                break
              }
            }
            let cell = row.at(n)
            if not is-main-task-with-subtasks and not cell.contains(" ") {
              if empty-is-zero and cell == "" {
                points.push(0)
              } else {
                points.push(points-number(cell, row-name, header-cell))
              }
            }
            n += 1
          }
          points
        }

        for (index, row) in rows.enumerate() {
          if (index == 1) {
            // Zweite Zeile: Maximalpunkte
            max-points = row-points(row, "Maximalpunkte", false)
          } else if (index > 1) {
            // Ab der dritten Zeile: je Schüler ein Bogen
            let name = row.at(0)
            let grade = row.at(1)
            let achieved-points = row-points(row, name, true)

            if not overprint {
              sheet(settings, name: name)
            } else {
              if max-points.len() == 0 or max-points.sum() == 0 {
                fail(
                  "klausurboegen",
                  function,
                  "`results`: die Zeile der Maximalpunkte (2. Zeile) ergibt 0 Punkte – ab Spalte 3 die erreichbaren Punkte je Aufgabe eintragen",
                )
              }
              if not continuation and (
                grade.match(regex("^[+-]?\\d+$")) == none or (stage == "sek-1" and int(grade) not in range(1, 7))
              ) {
                fail(
                  "klausurboegen",
                  function,
                  "`results`: Note `"
                    + repr(grade)
                    + "` in der Zeile `"
                    + name
                    + "` – in Spalte 2 "
                    + if stage == "sek-1" { "die Note als ganze Zahl von 1 bis 6" } else {
                      "die Notenpunkte als ganze Zahl"
                    }
                    + " eintragen",
                )
              }
              sheet(
                settings,
                overprint: true,
                name: name,
                grade-content: grade-display(
                  percentage: achieved-points.sum(default: 0) / max-points.sum(),
                  grade: grade,
                  stage: stage,
                  continuation: continuation,
                  offset: offset,
                ),
                points-content: points-table-content(
                  columns: columns,
                  max-points: max-points,
                  achieved-points: achieved-points,
                  overprint: true,
                  stage: stage,
                  subtask-numbering: subtask-numbering,
                  offset: offset,
                  part: if points-table-preprinted { "values" } else { "all" },
                ),
                grade-table: grade-boundaries(
                  max-points: max-points.sum(),
                  stage: stage,
                  overprint: true,
                  offset: offset,
                ),
              )
            }
          }
        }
      }
    } else {
      sheet(settings)
    }
  }
]
