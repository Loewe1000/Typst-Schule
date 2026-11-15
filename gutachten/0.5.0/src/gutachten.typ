// gutachten 0.5.0 – Gutachten über schriftliche Prüfungen.
#import "internal/check.typ": fail, check-named, check-type, check-not-empty, check-positional
#import "internal.typ"

// Benannte Argumente für `check-named`: der Sink und dazu jeder deklarierte
// Parameter, der von seiner Vorgabe abweicht. So erkennt die Prüfung „alt und
// neu zugleich“, obwohl der neue Name nicht im Sink landet. Grenze: Steht der
// neue Name ausdrücklich auf seiner Vorgabe, bleibt es bei „heißt jetzt“.
#let named-with-set(deprecated, values, defaults) = {
  let named = deprecated.named()
  for (key, value) in values {
    if value != defaults.at(key) { named.insert(key, value) }
  }
  named
}

/// Setzt die Angaben, die für alle Gutachten des Dokuments gelten: Fach,
/// Niveau, Kürzel der Lehrkraft, Gesamtpunktzahl, Schriften.
///
/// Der Aufruf ist Pflicht und ersetzt alle früheren Angaben; was fehlt, steht
/// wieder auf seiner Vorgabe. Er darf an beliebiger Stelle stehen, auch nach
/// den Gutachten, denn gelesen wird der Stand am Dokumentende.
///
/// ```typ
/// #set-options(subject: "Mathematik", level: "E", teacher: "SLZ", max-points: 100)
/// ```
///
/// - subject (str, content, none): Fach der Prüfung, steht im Kopf
/// - level (str, content, none): Kursniveau, zum Beispiel `"E"` oder `"G"`; steht im Kopf in Klammern
/// - teacher (str, content, none): Kürzel der Lehrkraft, steht im Kopf
/// - anonymous (bool): `true` ersetzt jeden Namen durch „Schüler“
/// - print (bool): `true` setzt eine Unterschriftslinie für die Zweitkorrektur statt des grauen Vermerks „Mit Korrektur und Bewertung einverstanden“
/// - max-points (int, float): erreichbare Bewertungseinheiten der ganzen Prüfung
/// - font (str, array, dictionary): Schrift des Textes, wie bei `text(font: …)`
/// - math-font (str, array, dictionary): Schrift der Formeln, wie bei `text(font: …)`
/// - year (int, str, content, auto): Abiturjahr im Kopf; `auto` nimmt das laufende Jahr
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> content
#let set-options(
  subject: none,
  level: none,
  teacher: none,
  anonymous: false,
  print: false,
  max-points: 1,
  font: "New Computer Modern Sans",
  math-font: "Fira Math",
  year: auto,
  ..deprecated,
) = {
  check-named(
    "gutachten",
    "set-options",
    named-with-set(
      deprecated,
      (subject: subject, level: level, teacher: teacher, anonymous: anonymous, max-points: max-points, year: year),
      (subject: none, level: none, teacher: none, anonymous: false, max-points: 1, year: auto),
    ),
    renamed: (
      fach: "subject",
      niveau: "level",
      kuerzel: "teacher",
      anonym: "anonymous",
      be: "max-points",
      jahr: "year",
    ),
    removed: (
      kurs: "seit 0.0.2 steht im Kopf nur noch Fach, Niveau und Kürzel; Angabe streichen",
      pruefer: "seit 0.0.2 steht im Kopf das Kürzel der Lehrkraft; `teacher: \"…\"` schreiben",
      korreferent: "seit 0.0.2 unterschreibt die Zweitkorrektur ohne Namen; Angabe streichen",
    ),
    allowed: ("subject", "level", "teacher", "anonymous", "print", "max-points", "font", "math-font", "year"),
  )
  check-positional("gutachten", "set-options", deprecated)
  check-not-empty("gutachten", "set-options", "subject", subject, "kein Fach")
  check-not-empty("gutachten", "set-options", "level", level, "kein Niveau")
  check-not-empty("gutachten", "set-options", "teacher", teacher, "kein Kürzel")
  check-type("gutachten", "set-options", "subject", subject, (str, content, none), example: "\"Mathematik\"")
  check-type("gutachten", "set-options", "level", level, (str, content, none), example: "\"E\"")
  check-type("gutachten", "set-options", "teacher", teacher, (str, content, none), example: "\"SLZ\"")
  check-type("gutachten", "set-options", "anonymous", anonymous, bool)
  check-type("gutachten", "set-options", "print", print, bool)
  check-type("gutachten", "set-options", "max-points", max-points, (int, float), example: "100")
  check-type("gutachten", "set-options", "font", font, (str, array, dictionary), example: "\"Libertinus Serif\"")
  check-type("gutachten", "set-options", "math-font", math-font, (str, array, dictionary), example: "\"Fira Math\"")
  check-type("gutachten", "set-options", "year", year, (int, str, content, auto), example: "2027")
  if max-points <= 0 {
    fail("gutachten", "set-options", "`max-points: " + repr(max-points) + "` – die Gesamtpunktzahl muss größer als 0 sein")
  }

  internal.options.update((
    subject: subject,
    level: level,
    teacher: teacher,
    anonymous: anonymous,
    print: print,
    max-points: max-points,
    font: font,
    math-font: math-font,
    year: year,
  ))
}

/// Vorname des Prüflings im laufenden Gutachten, für den Fließtext. Mit
/// `anonymous: true` steht dort „Schüler“. Ein Wert, keine Funktion: `#name`
/// ohne Klammern.
///
/// ```typ
/// #aufgabe("Aufgabe 1", points: 24)[#name löst die Aufgabe vollständig.]
/// ```
#let name = context {
  let student = internal.current-student("name")
  if internal.final-options("name").anonymous {
    internal.anonymous-placeholder()
  } else {
    student.first-name
  }
}

/// Legt die Aufgaben der Prüfung fest: je Aufgabenname die erreichbaren
/// Bewertungseinheiten.
///
/// Der Aufgabenname ist der Schlüssel; `aufgabe` und `selected-tasks` greifen
/// darüber zu. Erlaubte Schlüssel je Aufgabe: `max-points` (erreichbare
/// Bewertungseinheiten), `dative` (Name im Dativ für den Satz „In … erreicht
/// …“, ohne Angabe der Aufgabenname) und `title` (Thema, das `selected-tasks`
/// hinter dem Namen nennt).
///
/// ```typ
/// #set-tasks((
///   "Aufgabe 1": (max-points: 30, dative: "Aufgabe 1"),
///   "Aufgabe 2": (max-points: 20, title: "Analysis"),
/// ))
/// ```
///
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - tasks (dictionary): Aufgabenname → `(max-points:, dative:, title:)`
/// -> content
#let set-tasks(..deprecated, tasks) = {
  check-positional("gutachten", "set-tasks", deprecated.pos() + (tasks,), max: 1, hint: "alle Aufgaben in ein einziges Dictionary schreiben: `set-tasks((\"Aufgabe 1\": (max-points: 30)))`")
  check-named("gutachten", "set-tasks", deprecated, allowed: ())
  check-type("gutachten", "set-tasks", "tasks", tasks, dictionary, example: "(\"Aufgabe 1\": (max-points: 30))")
  for (task-name, entry) in tasks {
    if type(entry) != dictionary {
      fail("gutachten", "set-tasks", "der Eintrag `" + task-name + "` ist kein Dictionary – `\"" + task-name + "\": (max-points: " + repr(entry) + ")` schreiben")
    }
    check-named(
      "gutachten",
      "set-tasks",
      entry,
      renamed: (be: "max-points", dativ: "dative", name: "title"),
      allowed: ("max-points", "dative", "title"),
      what: "Schlüssel",
    )
    if "max-points" in entry {
      check-type("gutachten", "set-tasks", "max-points", entry.max-points, (int, float), example: "30")
    }
  }

  internal.tasks.update(tasks)
}

/// Rechnet einen Anteil der erreichten Punkte in die Note der Oberstufe um
/// und liefert sie als Text, zum Beispiel `"gut (11 Punkte)"`.
///
/// ```typ
/// #format-grade(0.75) // gut (11 Punkte)
/// ```
///
/// - share (float, int): Anteil der erreichten an den erreichbaren Punkten, von `0.0` bis `1.0`
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> str
#let format-grade(share, ..deprecated) = {
  check-positional("gutachten", "format-grade", deprecated.pos() + (share,), max: 1, hint: "nur den Anteil übergeben: `format-grade(0.75)`")
  check-named("gutachten", "format-grade", deprecated, allowed: ())
  check-type("gutachten", "format-grade", "share", share, (float, int), example: "0.75")

  let scale = (
    (share: 0.95, grade: "sehr gut (15 Punkte)"),
    (share: 0.9, grade: "sehr gut (14 Punkte)"),
    (share: 0.85, grade: "sehr gut (13 Punkte)"),
    (share: 0.8, grade: "gut (12 Punkte)"),
    (share: 0.75, grade: "gut (11 Punkte)"),
    (share: 0.7, grade: "gut (10 Punkte)"),
    (share: 0.65, grade: "befriedigend (09 Punkte)"),
    (share: 0.6, grade: "befriedigend (08 Punkte)"),
    (share: 0.55, grade: "befriedigend (07 Punkte)"),
    (share: 0.5, grade: "ausreichend (06 Punkte)"),
    (share: 0.45, grade: "ausreichend (05 Punkte)"),
    (share: 0.4, grade: "ausreichend (04 Punkte)"),
    (share: 0.33, grade: "mangelhaft (03 Punkte)"),
    (share: 0.27, grade: "mangelhaft (02 Punkte)"),
    (share: 0.2, grade: "mangelhaft (01 Punkt)"),
    (share: 0.0, grade: "ungenügend (00 Punkte)"),
  )
  let index = 0
  while index < scale.len() {
    if share >= scale.at(index).share {
      return scale.at(index).grade
    }
    index += 1
  }
}

/// Setzt den Abschnitt zu einer Aufgabe: Überschrift, Kommentar und den Satz
/// „In … erreicht … insgesamt … von … Bewertungseinheiten.“ Die erreichten
/// Punkte gehen in die Gesamtsumme des Gutachtens ein.
///
/// ```typ
/// #aufgabe("Aufgabe 1", points: 24)[Kommentar zur Aufgabe]
/// ```
///
/// - task-name (str): Name der Aufgabe, wie er in `set-tasks` als Schlüssel steht; wird zur Überschrift
/// - points (int, float, none): erreichte Bewertungseinheiten; die Angabe ist Pflicht
/// - ..deprecated (arguments): fängt alte Schreibweisen ab, nimmt nichts an
/// - body (content): Kommentar zur Bearbeitung
/// -> content
#let aufgabe(task-name, points: none, ..deprecated, body) = {
  check-named(
    "gutachten",
    "aufgabe",
    named-with-set(deprecated, (points: points), (points: none)),
    renamed: (punkte: "points"),
    allowed: ("points",),
  )
  check-positional("gutachten", "aufgabe", deprecated.pos() + (task-name,), max: 1, hint: "die erreichten Punkte benannt schreiben: `aufgabe(\"Aufgabe 1\", points: 24)[...]`")
  check-type("gutachten", "aufgabe", "task-name", task-name, str, example: "\"Aufgabe 1\"")
  if points == none {
    fail("gutachten", "aufgabe", "`points` fehlt – die erreichten Punkte angeben: `aufgabe(\"" + task-name + "\", points: 24)[...]`")
  }
  check-type("gutachten", "aufgabe", "points", points, (int, float), example: "24")

  [
    = #task-name

    #body

    #context par[
      #let student = internal.current-student("aufgabe")
      #let anonymous = internal.final-options("aufgabe").anonymous
      #let student-display = if anonymous {
        internal.anonymous-placeholder()
      } else {
        student.at("first-name")
      }
      #let tasks = internal.tasks.get()
      #if task-name not in tasks {
        fail("gutachten", "aufgabe", "unbekannte Aufgabe `" + task-name + "` – in `set-tasks` eintragen" + if tasks.len() > 0 { "; bekannt: " + tasks.keys().map(key => "`" + key + "`").join(", ") } else { "" })
      }
      #let entry = tasks.at(task-name)
      #if "max-points" not in entry {
        fail("gutachten", "aufgabe", "die Aufgabe `" + task-name + "` hat kein `max-points` – in `set-tasks` ergänzen: `\"" + task-name + "\": (max-points: 30)`")
      }
      #let max-points = entry.max-points
      #let name-dative = entry.at("dative", default: task-name)
      #internal.points.update(sum => { points + sum })
      In #name-dative erreicht #student-display insgesamt *#internal.format-points(points)* von *#internal.format-points(max-points)* Bewertungseinheiten.
    ]
  ]
}

/// Setzt das Gutachten für einen Prüfling: Kopf mit Logo, Name, Abiturjahr,
/// Fach und Kürzel, Seitenzahl „1 von 3“, darunter der Inhalt, am Ende die
/// Gesamtpunktzahl, die Note und die Unterschriftszeilen.
///
/// Die Punkte kommen aus den `aufgabe`-Aufrufen im Inhalt, die
/// Gesamtpunktzahl aus `set-options(max-points: …)`. Jedes Gutachten beginnt
/// mit Seite 1.
///
/// ```typ
/// #gutachten(first-name: "Max", last-name: "Mustermann")[
///   #aufgabe("Aufgabe 1", points: 24)[...]
/// ]
/// ```
///
/// - first-name (str): Vorname des Prüflings
/// - last-name (str): Nachname des Prüflings
/// - selected-tasks (array, dictionary): gewählte Aufgaben für den Satz „… wählt …“: Aufgabennamen als Array oder nach Prüfungsteil geordnet als Dictionary `("Wahlteil": ("2A", "3B"))`; leer lässt den Satz weg
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt des Gutachtens, in der Regel `aufgabe`-Aufrufe
/// -> content
#let gutachten(
  first-name: "Max",
  last-name: "Mustermann",
  selected-tasks: (),
  ..deprecated,
  body,
) = {
  check-named(
    "gutachten",
    "gutachten",
    named-with-set(
      deprecated,
      (first-name: first-name, last-name: last-name, selected-tasks: selected-tasks),
      (first-name: "Max", last-name: "Mustermann", selected-tasks: ()),
    ),
    renamed: (vorname: "first-name", nachname: "last-name", name: "last-name", wahl: "selected-tasks"),
    removed: (
      geschlecht: "seit 0.0.2 nennt das Gutachten den Vornamen ohne Anrede; Angabe streichen",
      jahr: "steht jetzt in `set-options(year: …)`",
      fach: "steht jetzt in `set-options(subject: …)`",
      niveau: "steht jetzt in `set-options(level: …)`",
      be: "steht jetzt in `set-options(max-points: …)`",
      kurs: "seit 0.0.2 steht im Kopf nur noch Fach, Niveau und Kürzel; Angabe streichen",
      pruefer: "steht jetzt als Kürzel in `set-options(teacher: …)`",
      korreferent: "seit 0.0.2 unterschreibt die Zweitkorrektur ohne Namen; Angabe streichen",
    ),
    allowed: ("first-name", "last-name", "selected-tasks"),
  )
  check-positional("gutachten", "gutachten", deprecated, hint: "Vor- und Nachname benannt schreiben: `gutachten(first-name: \"Max\", last-name: \"Mustermann\")[...]`")
  check-type("gutachten", "gutachten", "first-name", first-name, str, example: "\"Max\"")
  check-type("gutachten", "gutachten", "last-name", last-name, str, example: "\"Mustermann\"")
  check-type("gutachten", "gutachten", "selected-tasks", selected-tasks, (array, dictionary), example: "(\"Aufgabe 2\", \"Aufgabe 4\")")
  if type(selected-tasks) == array {
    for task-name in selected-tasks {
      if type(task-name) != str {
        fail("gutachten", "gutachten", "`selected-tasks` enthält `" + repr(task-name) + "` (" + str(type(task-name)) + ") – Aufgabennamen als Text schreiben: `(\"Aufgabe 2\", \"Aufgabe 4\")`")
      }
    }
  } else {
    for (part, part-tasks) in selected-tasks {
      if type(part-tasks) != array {
        fail("gutachten", "gutachten", "`selected-tasks`: der Prüfungsteil `" + part + "` braucht eine Liste – `(\"" + part + "\": (" + repr(part-tasks) + ",))` schreiben")
      }
      for task-name in part-tasks {
        if type(task-name) != str {
          fail("gutachten", "gutachten", "`selected-tasks`: der Prüfungsteil `" + part + "` enthält `" + repr(task-name) + "` (" + str(type(task-name)) + ") – Aufgabennamen als Text schreiben: `(\"" + part + "\": (\"Aufgabe 2\",))`")
        }
      }
    }
  }

  [
    #internal.student.update((first-name: first-name, last-name: last-name))
    #internal.points.update(0)
    #counter(page).update(1)

    #context [

      #let options = internal.final-options("gutachten")
      #let anonymous = options.anonymous
      // `none` steht im Kopf als leerer Text, wie die Vorgabe `""` in 0.0.2:
      // Der leere Text hält das benachbarte Leerzeichen fest, `none` nicht.
      #let shown(value) = if value == none { "" } else { value }
      #let first-name-display = if anonymous { internal.anonymous-placeholder() } else { first-name }
      #let full-name = if anonymous {
        internal.anonymous-placeholder()
      } else {
        emph[#first-name #last-name]
      }

      #set text(font: options.font, lang: "de")
      #show math.equation: set text(font: options.math-font)
      #set par(justify: true)
      #show math.equation: it => {
        show regex("\d+\.\d+"): it => {
          show ".": {
            "," + h(0pt)
          }
          it
        }
        it
      }

      #set page(
        header-ascent: 20%,
        numbering: (i, n) => {
          context [
            #let student = internal.student.get()
            #i von #counter(page).at(label(internal.pages-label(student))).at(0)
          ]
        },
        margin: (top: 3cm, y: 3cm),
        header: [
          #grid(
            columns: (auto, 1fr, auto),
            align: (left + top, center + horizon, right + horizon),
            image("../logo.svg", height: 1.3cm),
            [Gutachten über die schriftliche Prüfung von \ #full-name],
            [Abitur #if options.year == auto { int(datetime.today().display("[year]")) } else { options.year } \ #shown(options.subject) (#shown(options.level)) - #shown(options.teacher)],
          )
          #v(-3mm)
          #line(length: 100%, stroke: 1.5pt)
        ],
      )


      #if selected-tasks.len() > 0 [
        #context [
          #let task-display(task-name) = {
            let entry = internal.tasks.get().at(task-name, default: (title: none))
            let task-title = if type(entry) == dictionary {
              entry.at("title", default: none)
            } else {
              none
            }
            emph[#task-name#if task-title != none and task-title != "" [: #task-title]]
          }
          #first-name-display wählt #if type(selected-tasks) == array {
            selected-tasks.map(task-display).join(", ", last: " und ") + "."
          } else if type(selected-tasks) == dictionary {
            let keys = selected-tasks.keys()
            keys.map(
              key => {
                "im " + key + " "
                selected-tasks.at(key).map(task-display).join(", ", last: " und ")
              },
            ).join(", ", last: " und ") + "."
          }
        ]
      ]

      #body

      #box[
        #context [
          #let max-points = internal.final-options("gutachten").max-points
          #let points = internal.points.get()
          #let print = internal.final-options("gutachten").print

          #v(1em)

          Insgesamt erreicht der Prüfling *#internal.format-points(points)* von *#internal.format-points(max-points)* Bewertungseinheiten ($#calc.round(100 * points / max-points, digits: 1)$%).\
          Daher bewerte ich die Arbeit mit\
          #align(center)[*#format-grade(points / max-points)*.]

          #v(1cm)

          #grid(
            columns: (1fr, 5em, 1fr), rows: 1cm, row-gutter: 0.5em,
            [], [], if print { grid.cell(stroke: (bottom: 1pt), []) } else { grid.cell([#text(gray)[_Mit Korrektur und Bewertung einverstanden_]]) },
            grid.cell(stroke: (bottom: 1pt), []), [], grid.cell(stroke: (bottom: 1pt), []),
            text(9pt, [Ort, Datum, Unterschrift]), [], text(9pt, [Ort, Datum, Unterschrift])
          )
        ]
      ]
      #context [
        #let student = internal.student.get()
        #label(internal.pages-label(student))
      ]
    ]
  ]
}
