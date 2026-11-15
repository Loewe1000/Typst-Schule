// Öffentliche Funktionen von @schule/aufgaben. States, Counter, Options-Schema,
// Theme-Vertrag und alle Helfer stehen in internal.typ.
#import "@preview/fontawesome:0.6.0": fa-user-group, fa-user-large, fa-users
#import "internal/check.typ": check-named, check-not-empty, check-positional, check-type, check-value, fail
#import "internal.typ": (
  check-options, expectation-rows, final-records, fixed-flex-area, in-solution-state, in-subtask-state, in-task-state,
  is-flex-area, keep-together, material-count-before-state, material-figure-kind, material-number-state,
  material-task-number-state, merge-options, option-names, option-removed, option-renames, options-state,
  points-display, points-text, print-state, record-points, records-state, reset-label, right-text-edge,
  shown-task-count-state, solution-callout, subtask-figure-kind, subtask-number-text, counting-symbol-count,
  task-counter, task-figure-kind, task-index-state, task-materials, task-points, task-solution,
  task-solution-inline, theme-hook, theme-state, unchanged,
)

// Benannte Argumente für `check-named`: der Sink, ergänzt um die deklarierten
// Parameter, die ausdrücklich gesetzt wurden. So entsteht die Meldung „alt und
// neu zugleich" (Konvention 8.3); ohne das landete der neue Name nie bei der
// Prüfung. `declared` ist Name → (Wert, Vorgabe); erkennbar ist ein Parameter
// nur, wenn sein Wert von der Vorgabe abweicht.
#let named-given(deprecated, declared) = {
  let given = deprecated.named()
  for (name, (value, default)) in declared {
    if value != default { given.insert(name, value) }
  }
  given
}

// Erstes Positionsargument des Sinks mit einem der Typen, sonst `none`.
// Für die Meldung „zweiter Weg" (Konvention 8.3), die ohne Zählbefund steht.
#let stray-positional(deprecated, ..types) = deprecated.pos().find(value => type(value) in types.pos())

/// Ändert Optionen des Pakets ab dieser Stelle im Dokument.
///
/// Jede Option ist ein benannter Parameter. Was nicht angegeben wird, bleibt,
/// wie es ist; `none` schaltet eine Auswahl ab, `points-format: auto` stellt
/// die Paketvorlage wieder her. Namen, Typen und Werte werden geprüft, ein
/// Tippfehler bricht mit einem Vorschlag ab.
///
/// Geprüft wird jeder Aufruf für sich. `solutions-pagebreak: "per-task"`
/// zusammen mit einem anderen `solutions` als `"at-end"` bricht deshalb nur
/// ab, wenn beide im selben Aufruf stehen; steht `solutions-pagebreak`
/// allein, bleibt es ohne `solutions: "at-end"` wirkungslos.
///
/// ```typ
/// #set-options(solutions: "in-place")
/// #set-options(points: "all", workspaces: false)
/// ```
///
/// - solutions (str, none): Lösungen: `none` (nicht zeigen), `"in-place"` (direkt nach jeder Teilaufgabe),
///   `"after-task"` (gesammelt nach jeder Aufgabe), `"at-end"` (gesammelt, Ausgabe mit `show-solutions()`),
///   `"only"` (nur Lösungen, der Aufgabentext entfällt). Start: `none`
/// - solutions-pagebreak (str, none): Umbruch bei `solutions: "at-end"`: `none`, `"before"` (Seitenumbruch vor
///   dem Lösungsblock), `"per-task"` (jede Aufgabe auf eigener Seite). Start: `none`
/// - materials (str, none): Material: `none` (nicht zeigen), `"after-task"` (nach der Aufgabe, zu der es
///   gehört), `"at-end"` (gesammelt, Ausgabe mit `show-materials()`). Start: `"after-task"`
/// - materials-pagebreak (str, none): `"before"`: Material steht auf eigener Seite (bei `"at-end"`:
///   Seitenumbruch vor dem Block); `none`: kein Umbruch. Start: `"before"`
/// - points (str, none): Punkteanzeige: `none`, `"tasks"` (an Aufgaben), `"subtasks"` (an Teilaufgaben),
///   `"all"` (an beiden). Start: `none`
/// - points-total (bool): `false`: keine Summe an Aufgaben mit Teilaufgaben; Aufgaben ohne Teilaufgaben
///   zeigen ihre Punkte weiter. Start: `true`
/// - points-position (str): Punkte der Teilaufgaben am Zeilenende (`"end"`) oder am Seitenrand (`"margin"`).
///   Start: `"end"`
/// - points-format (auto, function, dictionary): Vorlage der Punkteanzeige: eine Funktion `points => content`
///   für beide Ziele oder `(task: f, subtask: g)`; ein Dictionary ändert nur die genannten Ziele.
///   `auto` ist die Paketvorlage („*3 BE*“ und „*[3 BE]*“)
/// - workspaces (bool): Arbeitsflächen (`workspace:`) setzen. Start: `true`
/// - shortcodes (str, none): Kurzschreibweise für Aufgaben und Teilaufgaben in `arbeitsblatt`: `none`,
///   `"tasks"`, `"subtasks"`, `"all"`. Dieses Paket speichert die Option nur. Start: `"subtasks"`
/// - subtask-numbering (str): Typst-Muster für Teilaufgaben. Ein Zählzeichen bekommt die Teilnummer
///   (`"a)"` ergibt „b)“), zwei bekommen Aufgabe und Teil (`"1.1"` ergibt „3.2“). Der frühere Wert `"1."`
///   ist gesperrt und heißt jetzt `"1.1"`. Start: `"a)"`
/// - ..deprecated (arguments): fängt alte Namen und das frühere Dictionary ab, nimmt nichts an
/// -> content
#let set-options(
  solutions: unchanged,
  solutions-pagebreak: unchanged,
  materials: unchanged,
  materials-pagebreak: unchanged,
  points: unchanged,
  points-total: unchanged,
  points-position: unchanged,
  points-format: unchanged,
  workspaces: unchanged,
  shortcodes: unchanged,
  subtask-numbering: unchanged,
  ..deprecated,
) = {
  if stray-positional(deprecated, dictionary) != none {
    fail(
      "aufgaben",
      "set-options",
      "Dictionary als Argument – Schlüssel benannt schreiben (`set-options(solutions: \"in-place\")`) oder ein Dictionary mit `..` entpacken",
    )
  }
  check-positional("aufgaben", "set-options", deprecated)
  let changes = (
    solutions: solutions,
    solutions-pagebreak: solutions-pagebreak,
    materials: materials,
    materials-pagebreak: materials-pagebreak,
    points: points,
    points-total: points-total,
    points-position: points-position,
    points-format: points-format,
    workspaces: workspaces,
    shortcodes: shortcodes,
    subtask-numbering: subtask-numbering,
  )
  check-named(
    "aufgaben",
    "set-options",
    named-given(deprecated, changes.pairs().map(((name, value)) => (name, (value, unchanged))).to-dict()),
    renamed: option-renames,
    removed: option-removed,
    allowed: option-names,
  )
  check-options("aufgaben", "set-options", changes)
  options-state.update(current => merge-options(current, changes))
}

/// Setzt alle Zähler und Zustände der Aufgaben zurück.
///
/// Nötig für den Bündel-Export (Typst 0.15): Dort sind States und Counter
/// global über alle Dokumente des Bündels. Damit jede Variante wieder bei
/// Aufgabe 1 beginnt und sich Aufgaben, Lösungen und Erwartungen nicht über
/// die Varianten hinweg ansammeln, steht der Aufruf am Anfang jedes
/// Varianten-Dokuments. Mehrere Klassenarbeiten in einer Datei trennt er in
/// Blöcke mit eigenen Punkten. Optionen, Theme und Druckmodus bleiben.
///
/// Setzt auch die Zähler der Bild- und Tabellen-Abbildungen (`figure` mit
/// `kind: image` und `kind: table`) auf 0.
///
/// ```typ
/// #reset-tasks()
/// ```
///
/// -> content
#let reset-tasks() = {
  // Marke VOR dem Zurücksetzen: Der Zustand an dieser Stelle ist der Endstand
  // des vorherigen Blocks (siehe `internal.final-records`).
  [#metadata("reset") #reset-label]
  task-counter.update((0, 0))
  counter(figure.where(kind: task-figure-kind)).update(0)
  counter(figure.where(kind: subtask-figure-kind)).update(0)
  counter(figure.where(kind: material-figure-kind)).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  records-state.update(())
  task-index-state.update(-1)
  material-task-number-state.update(0)
  material-number-state.update(0)
  in-solution-state.update(false)
  shown-task-count-state.update(0)
  in-task-state.update(false)
  in-subtask-state.update(false)
  material-count-before-state.update(0)
}

/// Sind Lösungen eingeschaltet (`solutions` ist nicht `none`)?
///
/// Braucht `context`.
///
/// ```typ
/// #context if has-solutions() [Fassung mit Lösungen]
/// ```
///
/// -> bool
#let has-solutions() = options-state.get().solutions != none

/// Wird die Druckfassung gesetzt?
///
/// Den Druckmodus setzt die Vorlage (`arbeitsblatt(print: true)`); ohne
/// Vorlage ist er `false`. Braucht `context`.
///
/// ```typ
/// #context if is-print() [Druckfassung] else [Bildschirmfassung]
/// ```
///
/// -> bool
#let is-print() = print-state.get()

// Rumpf von `show-solutions` ohne eigenen `context` (braucht `context`).
// `aufgabe` und `teilaufgabe` rufen ihn aus dem `context` heraus auf, in dem
// sie die Option `solutions` schon gelesen haben. Mit `select: "current"`
// reicht er Optionen und Theme an den Lösungskasten weiter. So liegen zwischen
// der Option und dem fertigen Kasten nicht vier ineinander entstehende
// `context`-Ebenen, sondern eine: Typst gibt einem Dokument fünf Durchläufe,
// und jede solche Ebene verbraucht einen.
// Mit "all" liest jeder Kasten weiter selbst: Ein `set-options` im Rumpf einer
// Lösung gilt dann wie bisher für die folgenden Kästen. Sein `context` hält
// aber nur den Index der Aufgabe und die Stelle dieses Aufrufs fest und holt
// den Datensatz von dort (`records-state.at(…)`, derselbe Wert wie hier). Mit
// dem Datensatz selbst im `context` bekäme der Kasten in jedem Durchlauf, in
// dem sich die Datensätze noch ändern, eine neue Stelle im Dokument, läse die
// Optionen dort einen Durchlauf zu spät und verbrauchte so einen der fünf
// („value of state options did not converge").
#let solutions-here(select, subtask-number, inline) = {
  let records = records-state.get()
  // ohne umgebende aufgabe(): nichts
  if select == "current" { records = if records.len() > 0 { (records.last(),) } else { () } }
  let options = options-state.get()
  let at-end = options.solutions == "at-end"
  let call-site = here()
  let solution-box(index, record) = if select == "current" {
    task-solution(record, subtask-number: subtask-number, options: options, theme: theme-state.get())
  } else {
    context {
      let records = records-state.at(call-site)
      if index < records.len() {
        task-solution(
          records.at(index),
          subtask-number: subtask-number,
          options: options-state.get(),
          theme: theme-state.get(),
        )
      }
    }
  }

  if not inline and at-end and options.solutions-pagebreak == "before" {
    pagebreak(weak: true)
  }
  for (index, record) in records.enumerate() {
    if record.solution-records.len() > 0 {
      if inline {
        task-solution-inline(record)
      } else if at-end and options.solutions-pagebreak == "per-task" {
        page(solution-box(index, record))
      } else {
        solution-box(index, record)
      }
    }
  }
}

/// Gibt Lösungen aus, die mit `loesung` erfasst wurden.
///
/// Die Vorlagen rufen die Funktion selbst auf; im Dokument braucht man sie
/// nur, wenn Lösungen an einer bestimmten Stelle stehen sollen.
///
/// `select: "pending"` gibt alle Aufgaben aus, deren Lösungen dieser Aufruf
/// noch nicht gezeigt hat, immer in der Form des Lösungsblatts (wie
/// `inline: true`) und unabhängig von der Option `solutions`. Jede Aufgabe
/// erscheint so höchstens einmal.
///
/// ```typ
/// #show-solutions()
/// #show-solutions(select: "current", subtask-number: 2)
/// #show-solutions(select: "pending")
/// ```
///
/// - select (str): `"all"` (alle Aufgaben), `"current"` (nur die zuletzt begonnene Aufgabe),
///   `"pending"` (alle noch nicht gezeigten, als Lösungsblatt)
/// - subtask-number (int, none): nur die Lösung dieser Teilaufgabe (0 = Lösung zur Aufgabe selbst);
///   `none` zeigt die ganze Aufgabe
/// - inline (bool): ohne Kasten, gesetzt wie eine Aufgabe (Lösungsblatt)
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> content
#let show-solutions(select: "all", subtask-number: none, inline: false, ..deprecated) = {
  check-positional("aufgaben", "show-solutions", deprecated)
  check-named(
    "aufgaben",
    "show-solutions",
    named-given(deprecated, (select: (select, "all"), subtask-number: (subtask-number, none))),
    renamed: (curr: "select", teil: "subtask-number"),
    allowed: ("select", "subtask-number", "inline"),
  )
  check-value(
    "aufgaben",
    "show-solutions",
    "select",
    select,
    ("all", "current", "pending"),
    renamed: ("true": "current", "false": "all"),
  )
  if subtask-number == false {
    fail("aufgaben", "show-solutions", "`subtask-number: false` – das Aus ist `none`")
  }
  check-type("aufgaben", "show-solutions", "subtask-number", subtask-number, (int, none))
  check-type("aufgaben", "show-solutions", "inline", inline, bool)

  if select == "pending" {
    if subtask-number != none {
      fail(
        "aufgaben",
        "show-solutions",
        "`subtask-number` wirkt nicht mit `select: \"pending\"` – eines von beiden weglassen",
      )
    }
    context {
      let records = records-state.get()
      for index in range(shown-task-count-state.get(), records.len()) {
        task-solution-inline(records.at(index))
      }
    }
    context shown-task-count-state.update(records-state.get().len())
    return
  }

  context solutions-here(select, subtask-number, inline)
}

// Rumpf von `show-materials` ohne eigenen `context` (braucht `context`).
// `aufgabe` ruft ihn aus dem `context` heraus auf, in dem sie die Option
// `materials` schon gelesen hat: So entsteht das Material nach der Aufgabe
// eine `context`-Ebene früher, und Material, das selbst mehrere Durchläufe
// braucht (Tabellen und Zeichnungen fremder Pakete), bleibt innerhalb der
// fünf Durchläufe von Typst.
#let materials-here(select) = {
  let records = records-state.get()
  // ohne umgebende aufgabe(): nichts
  if select == "current" { records = if records.len() > 0 { (records.last(),) } else { () } }
  let options = options-state.get()
  let own-page = options.materials-pagebreak == "before"
  if options.materials == "at-end" and own-page {
    pagebreak(weak: true)
  }
  for record in records {
    if record.material-records.len() > 0 {
      if options.materials == "after-task" and own-page {
        page(task-materials(record))
      } else {
        task-materials(record)
      }
    }
  }
}

/// Gibt Materialien aus, die mit `material` erfasst wurden.
///
/// Mit `materials: "after-task"` geschieht das von selbst nach jeder Aufgabe.
///
/// ```typ
/// #show-materials()
/// #show-materials(select: "current")
/// ```
///
/// - select (str): `"all"` (alle Aufgaben) oder `"current"` (nur die zuletzt begonnene Aufgabe)
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> content
#let show-materials(select: "all", ..deprecated) = {
  check-positional("aufgaben", "show-materials", deprecated)
  check-named(
    "aufgaben",
    "show-materials",
    named-given(deprecated, (select: (select, "all"))),
    renamed: (curr: "select"),
    allowed: ("select",),
  )
  check-value(
    "aufgaben",
    "show-materials",
    "select",
    select,
    ("all", "current"),
    renamed: ("true": "current", "false": "all"),
  )
  context materials-here(select)
}

/// Summe der Punkte einer Aufgabe oder Teilaufgabe.
///
/// Gezählt werden die Punkte der mit `erwartung` erfassten Erwartungen, und
/// zwar am Ende des laufenden Blocks: Der Wert stimmt schon im Aufgabenkopf.
/// Braucht `context`.
///
/// ```typ
/// #context [Aufgabe 1 hat #get-points(1) Punkte.]
/// #context [Teilaufgabe 2 a) hat #get-points(2, subtask-number: 1) Punkte.]
/// ```
///
/// - task-number (int): Nummer der Aufgabe, ab 1; steht als einziges Argument ohne Namen
/// - subtask-number (int, none): nur diese Teilaufgabe (ab 1; 0 = Punkte direkt an der Aufgabe);
///   `none` ist die Summe der ganzen Aufgabe
/// - index (int, none): Stelle der Aufgabe im Dokument, ab 0; hat Vorrang vor `task-number`
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> int, float
#let get-points(task-number, subtask-number: none, index: none, ..deprecated) = {
  check-positional("aufgaben", "get-points", deprecated, hint: "nur die Aufgabennummer steht ohne Namen")
  check-named(
    "aufgaben",
    "get-points",
    named-given(deprecated, (subtask-number: (subtask-number, none), index: (index, none))),
    renamed: (teil: "subtask-number", idx: "index"),
    allowed: ("subtask-number", "index"),
  )
  check-type("aufgaben", "get-points", "task-number", task-number, int, example: "1")
  check-type("aufgaben", "get-points", "subtask-number", subtask-number, (int, none))
  check-type("aufgaben", "get-points", "index", index, (int, none))
  if index != none { return task-points(index, subtask-number: subtask-number) }
  if task-number < 1 { return 0 }
  task-points(task-number - 1, subtask-number: subtask-number)
}

/// Setzt eine Punktzahl mit der Vorlage aus der Option `points-format`.
///
/// Kommazahlen werden auf zwei Stellen gerundet und mit Dezimalkomma
/// geschrieben. Braucht `context`.
///
/// ```typ
/// #context format-points(3)
/// #context format-points(1.5, target: "subtask")
/// ```
///
/// - points (int, float): Punktzahl
/// - target (str): Vorlage für `"task"` (Aufgabe) oder `"subtask"` (Teilaufgabe)
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> content
#let format-points(points, target: "task", ..deprecated) = {
  check-positional("aufgaben", "format-points", deprecated, hint: "nur die Punktzahl steht ohne Namen")
  check-named(
    "aufgaben",
    "format-points",
    named-given(deprecated, (target: (target, "task"))),
    renamed: (teil: "target"),
    allowed: ("target",),
  )
  check-type("aufgaben", "format-points", "points", points, (int, float), example: "3")
  check-value(
    "aufgaben",
    "format-points",
    "target",
    target,
    ("task", "subtask"),
    renamed: ("true": "subtask", "false": "task"),
  )
  points-display(points, target: target)
}

/// Zeigt den Erwartungshorizont als Tabelle.
///
/// Jede mit `erwartung` erfasste Erwartung steht mit Teilaufgabe und Punkten
/// in einer Zeile, am Ende die Summe.
///
/// Mit `select: "all"` entsteht ein gemeinsamer Erwartungshorizont über alle
/// Blöcke des Dokuments (zum Beispiel Teil A und Teil B als zwei
/// Klassenarbeiten in einer Datei, getrennt durch `reset-tasks()`): je Block
/// eine Zwischenüberschrift und eine Zwischensumme, am Ende die Gesamtsumme.
///
/// ```typ
/// #show-expectations()
/// #show-expectations(select: "all", blocks: ([Teil A -- ohne Hilfsmittel], [Teil B -- mit Hilfsmitteln]))
/// ```
///
/// - select (str): `"current"` (der laufende Block) oder `"all"` (alle Blöcke des Dokuments)
/// - blocks (array): Zwischenüberschriften der Blöcke für `select: "all"`; fehlende werden als „Teil A“,
///   „Teil B“ ergänzt
/// - grouped (bool): alle Erwartungen einer Teilaufgabe in einer Zeile
/// - achieved (bool): `__ / X` statt `X`, zum Eintragen der erreichten Punkte
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> content
#let show-expectations(select: "current", blocks: (), grouped: false, achieved: false, ..deprecated) = {
  check-positional("aufgaben", "show-expectations", deprecated)
  check-named(
    "aufgaben",
    "show-expectations",
    named-given(deprecated, (select: (select, "current"), blocks: (blocks, ()), achieved: (achieved, false))),
    renamed: (erreicht: "achieved", alle: "select", teile: "blocks"),
    removed: (new-page: "`#pagebreak(weak: true)` vor und nach dem Aufruf schreiben"),
    allowed: ("select", "blocks", "grouped", "achieved"),
  )
  check-value(
    "aufgaben",
    "show-expectations",
    "select",
    select,
    ("current", "all"),
    renamed: ("true": "all", "false": "current"),
  )
  check-type("aufgaben", "show-expectations", "blocks", blocks, array, example: "([Teil A], [Teil B])")
  check-type("aufgaben", "show-expectations", "grouped", grouped, bool)
  check-type("aufgaben", "show-expectations", "achieved", achieved, bool)
  if blocks.len() > 0 and select != "all" {
    fail(
      "aufgaben",
      "show-expectations",
      "`blocks` wirkt nur mit `select: \"all\"` – `select: \"all\"` ergänzen oder `blocks` weglassen",
    )
  }
  let all-blocks = select == "all"
  context {
    let options = options-state.get()
    let rows = ()
    let total = 0
    let stroke-sum = (left: 0.5pt, right: 0.5pt, top: 1pt, bottom: 0.5pt)
    let shown(points) = if achieved { [#h(1em) / #points-text(points)] } else { [#points-text(points)] }
    let shaded = gray.lighten(70%)

    if all-blocks {
      // Endstand jedes Blocks: an jeder Reset-Marke steht der Stand des
      // vorherigen Blocks, am Dokumentende der des letzten.
      let record-blocks = query(reset-label).map(mark => records-state.at(mark.location()))
      record-blocks.push(records-state.final())
      record-blocks = record-blocks.filter(records => records.any(record => record.expectation-records.len() > 0))
      for (position, records) in record-blocks.enumerate() {
        let (block-rows, block-total) = expectation-rows(records, options, grouped: grouped, achieved: achieved)
        let title = blocks.at(position, default: [Teil #numbering("A", position + 1)])
        rows.push(table.cell(colspan: 3, fill: gray.lighten(40%), stroke: stroke-sum, align: left, strong(title)))
        rows += block-rows
        rows.push(table.cell(fill: shaded, stroke: stroke-sum, strong[$Sigma$]))
        rows.push(table.cell(stroke: stroke-sum, strong[Summe #title]))
        rows.push(table.cell(fill: shaded, stroke: stroke-sum, strong(shown(block-total))))
        total += block-total
      }
    } else {
      (rows, total) = expectation-rows(final-records(), options, grouped: grouped, achieved: achieved)
    }

    // Schlusszeile mit der Summe (nur wenn es überhaupt Zeilen gibt)
    if rows.len() > 0 {
      let stroke-total = if all-blocks { (left: 0.5pt, right: 0.5pt, top: 2pt, bottom: 0.5pt) } else { stroke-sum }
      rows.push(table.cell(fill: shaded, stroke: stroke-total, strong[$Sigma$]))
      rows.push(table.cell(stroke: stroke-total, strong(if all-blocks [Gesamtsumme] else [Summe])))
      rows.push(table.cell(fill: shaded, stroke: stroke-total, strong(shown(total))))
      block[
        #block(text(size: 1.25em, weight: "bold")[Erwartungshorizont])
        #table(
          columns: (auto, 1fr, auto),
          align: (center + horizon, left + horizon, center + horizon),
          inset: 8pt,
          stroke: 0.5pt,
          table.header(strong[Nr.], strong[Inhalt], strong[BE]),
          ..rows,
        )
      ]
    }
  }
}

/// Zeigt die Punktetabelle: je Aufgabe und Teilaufgabe eine Spalte, darunter
/// die möglichen und die erreichten Punkte.
///
/// ```typ
/// #show-points-table()
/// #show-points-table(possible: "fields", compact: true)
/// ```
///
/// - possible (str, none): Zeile „mögliche Punkte“: `"shown"` (Punkte eingetragen), `"fields"` (leere Felder
///   zum Eintragen), `none` (die Zeile entfällt)
/// - compact (bool): kleinere Schrift und schmalere Zeilen
/// - subtotals (bool): zusätzliche Spalte mit der Zwischensumme je Aufgabe mit Teilaufgaben
/// - ..deprecated (arguments): fängt alte Namen und das frühere Positionsargument ab, nimmt nichts an
/// -> content
#let show-points-table(possible: "shown", compact: false, subtotals: false, ..deprecated) = {
  if deprecated.pos().len() == 1 {
    fail(
      "aufgaben",
      "show-points-table",
      "Zeile „mögliche Punkte“ als Positionsargument – benannt schreiben: `possible: \"shown\"`, `possible: \"fields\"` oder `possible: none`",
    )
  }
  check-positional("aufgaben", "show-points-table", deprecated)
  check-named(
    "aufgaben",
    "show-points-table",
    named-given(deprecated, (subtotals: (subtotals, false))),
    renamed: (full: "subtotals"),
    allowed: ("possible", "compact", "subtotals"),
  )
  check-value(
    "aufgaben",
    "show-points-table",
    "possible",
    possible,
    (none, "shown", "fields"),
    renamed: ("true": "shown", "false": "fields", blank: "fields"),
  )
  check-type("aufgaben", "show-points-table", "compact", compact, bool)
  check-type("aufgaben", "show-points-table", "subtotals", subtotals, bool)
  context {
    let records = final-records()
    let options = options-state.get()

    if records.len() == 0 { return }

    let thick-stroke = 1pt // dicker Strich zwischen Spaltengruppen
    let shaded = gray.lighten(70%)
    let tint = if subtotals { shaded } else { white }

    let text-size = if compact { 0.9em } else { 1em }
    let row-height = if compact { 0.9cm } else { 1cm }
    let header-row-1 = (
      table.cell(
        rowspan: 2,
        fill: shaded,
        text(if compact { 0.8 * text-size } else { text-size }, strong[Aufgabe]),
      ),
    )
    let header-row-2 = ()
    let columns = (auto,)

    let possible-row = (
      table.cell(
        fill: shaded,
        text(if compact { 0.65em } else { 0.9em }, strong(if compact { "mögl. \nPunkte" } else { "mögliche Punkte" })),
      ),
    )
    let achieved-row = (
      table.cell(
        fill: shaded,
        text(if compact { 0.65em } else { 0.9em }, strong(if compact { "Punkte" } else { "erreichte Punkte" })),
      ),
    )

    let total = 0
    let cell-width = auto

    for record in records {
      let expectations = record.at("expectation-records", default: ())
      let task-total = expectations.fold(0, (sum, entry) => sum + entry.points)
      total += task-total

      let by-subtask = (:)
      for entry in expectations.sorted(key: entry => entry.subtask-number) {
        let key = str(entry.subtask-number)
        if key not in by-subtask.keys() {
          by-subtask.insert(key, ())
        }
        by-subtask.at(key).push(entry)
      }

      // Echte Teilaufgaben nur, wenn es auch Erwartungen an Teilaufgaben gibt.
      let has-subtasks = record.subtask-count > 0
      if has-subtasks and by-subtask.keys().filter(key => key != "0").len() == 0 {
        has-subtasks = false
      }

      if not has-subtasks {
        // Keine Teilaufgaben: eine Spalte für die Aufgabe
        let left-stroke = thick-stroke
        header-row-1.push(table.cell(
          rowspan: 2,
          stroke: (left: left-stroke),
          fill: tint,
          inset: (x: 12pt, y: 8pt),
          text(text-size, strong[#record.task-number]),
        ))

        let own-points = if "0" in by-subtask.keys() {
          by-subtask.at("0").fold(0, (sum, entry) => sum + entry.points)
        } else {
          0
        }

        if possible == "shown" and own-points > 0 {
          possible-row.push(table.cell(stroke: (left: left-stroke), fill: tint, text(text-size, if subtotals {
            strong[#points-text(own-points)]
          } else { [#points-text(own-points)] })))
        } else if possible != none {
          possible-row.push(table.cell(stroke: (left: left-stroke), fill: tint, []))
        }
        achieved-row.push(table.cell(stroke: (left: left-stroke), fill: tint, []))
        columns.push(cell-width)
        continue
      } else {
        // Mit Teilaufgaben: Spalten für alle Teilaufgaben. Punkte direkt an
        // der Aufgabe bekommen eine eigene Spalte „–", damit die Spalten die
        // Summe ergeben.
        let own-points = if "0" in by-subtask.keys() {
          by-subtask.at("0").fold(0, (sum, entry) => sum + entry.points)
        } else { 0 }
        let own-column = own-points > 0
        let colspan = record.subtask-count + (if subtotals { 1 } else { 0 }) + (if own-column { 1 } else { 0 })
        let left-stroke = thick-stroke
        header-row-1.push(table.cell(
          stroke: (bottom: none, left: left-stroke),
          fill: tint,
          colspan: colspan,
          text(text-size, strong[#record.task-number]),
        ))

        // Zwischensumme vor den Teilaufgaben
        if subtotals {
          header-row-2.push(table.cell(stroke: (top: none, left: left-stroke), fill: shaded, text(text-size, [])))
          if possible == "shown" {
            possible-row.push(table.cell(stroke: (left: left-stroke), fill: shaded, text(
              text-size,
              strong[$#points-text(task-total)$],
            )))
          } else if possible == "fields" {
            possible-row.push(table.cell(stroke: (left: left-stroke), fill: shaded, []))
          }
          achieved-row.push(table.cell(stroke: (left: left-stroke), fill: shaded, []))
          columns.push(cell-width)
        }

        if own-column {
          let own-stroke = if subtotals { 0.5pt } else { left-stroke }
          header-row-2.push(table.cell(stroke: (left: own-stroke), text(text-size, strong[–])))
          if possible == "shown" {
            possible-row.push(table.cell(stroke: (left: own-stroke), text(text-size, [$#points-text(own-points)$])))
          } else if possible == "fields" {
            possible-row.push(table.cell(stroke: (left: own-stroke), []))
          }
          achieved-row.push(table.cell(stroke: (left: own-stroke), []))
          columns.push(cell-width)
        }

        // alle Teilaufgaben, nicht nur die mit Erwartungen
        for subtask-number in range(1, record.subtask-count + 1) {
          let key = str(subtask-number)
          let marker = subtask-number-text(record.task-number, subtask-number, pattern: options.subtask-numbering)
          let subtask-points = if key in by-subtask.keys() {
            by-subtask.at(key).fold(0, (sum, entry) => sum + entry.points)
          } else {
            0
          }

          // Dicker Strich links nur an der ersten Spalte der Aufgabe
          let subtask-stroke = if subtask-number == 1 and not subtotals and not own-column { left-stroke } else { 0.5pt }
          header-row-2.push(table.cell(stroke: (left: subtask-stroke), text(text-size, strong[#marker])))
          if possible == "shown" and subtask-points > 0 {
            possible-row.push(table.cell(stroke: (left: subtask-stroke), text(
              text-size,
              [$#points-text(subtask-points)$],
            )))
          } else if possible != none {
            possible-row.push(table.cell(stroke: (left: subtask-stroke), []))
          }
          achieved-row.push(table.cell(stroke: (left: subtask-stroke), []))
          columns.push(cell-width)
        }
      }
    }

    // Summenspalte
    header-row-1.push(table.cell(
      rowspan: 2,
      stroke: (left: thick-stroke),
      fill: shaded,
      text(text-size, strong[$Sigma$]),
    ))
    columns.push(if cell-width == auto { auto } else { 1.25 * cell-width })
    if possible == "shown" {
      possible-row.push(table.cell(stroke: (left: thick-stroke), fill: shaded, text(
        text-size,
        strong[#if total > 0 [#points-text(total)]],
      )))
    } else if possible == "fields" {
      possible-row.push(table.cell(stroke: (left: thick-stroke), fill: shaded, []))
    }
    achieved-row.push(table.cell(stroke: (left: thick-stroke), fill: shaded, []))

    table(
      columns: columns,
      rows: (auto, auto, row-height, row-height),
      align: center + horizon,
      inset: if compact { 5pt } else { 8pt },
      stroke: 0.5pt,
      ..header-row-1,
      ..header-row-2,
      ..if possible != none { possible-row },
      ..achieved-row,
    )
  }
}

/// Erfasst ein Material und ordnet es der zuletzt begonnenen Aufgabe zu.
///
/// Wo das Material erscheint, bestimmen die Optionen `materials` und
/// `materials-pagebreak`. Dieses Paket setzt das Material als Abbildung
/// (`figure(kind: "material")`) ohne eigene Bezeichnung; die Bezeichnung
/// „M1-A“ und die Verweise darauf ergänzt die Vorlage `arbeitsblatt`.
///
/// ```typ
/// #aufgabe(title: [Textanalyse])[Analysiere den Text.]
/// #material(caption: [Auszug aus „Faust I“])[Habe nun, ach! Philosophie …]
/// ```
///
/// - caption (content, str, none): Beschriftung des Materials
/// - label (label, str, none): Marke für Verweise mit `@`
/// - ..deprecated (arguments): fängt unbekannte Namen ab, nimmt nichts an
/// - body (content): Inhalt des Materials
/// -> content
#let material(caption: none, label: none, ..deprecated, body) = {
  check-positional("aufgaben", "material", deprecated, hint: "nur der Inhalt steht ohne Namen")
  check-named("aufgaben", "material", deprecated, allowed: ("caption", "label"))
  check-not-empty("aufgaben", "material", "caption", caption, "keine Beschriftung")
  check-type("aufgaben", "material", "caption", caption, (content, str, none))
  check-type("aufgaben", "material", "label", label, (std.label, str, none), example: "<quelle>")
  let entry = [#figure(
      align(left, body),
      caption: caption,
      kind: material-figure-kind,
      supplement: none,
    ) #if label != none { if type(label) == std.label { label } else { std.label(label) } }
    #v(-0.5em)
    #line(length: 100%, stroke: 0.5pt)
  ]
  context {
    records-state.update(records => {
      if records.len() > 0 {
        records.at(-1).material-records.push((body: entry))
      }
      records
    })
  }
}

/// Setzt eine nummerierte Aufgabe.
///
/// Die Aufgabe bekommt eine fortlaufende Nummer. Lösungen (`loesung`),
/// Erwartungen (`erwartung`) und Materialien (`material`) im Rumpf oder nach
/// der Aufgabe gehören zu ihr.
///
/// ```typ
/// #aufgabe[Berechne die Summe von 15 und 27.]
/// #aufgabe(title: [Addition], method: "pair")[Berechne …]
/// ```
///
/// - title (content, str, none): Titel der Aufgabe
/// - method (str, none): Sozialform als Symbol: `"individual"` (Einzelarbeit), `"pair"` (Partnerarbeit),
///   `"group"` (Gruppenarbeit)
/// - icons (array): weitere Symbole vor der Überschrift, zum Beispiel `(emoji.lightbulb,)`
/// - large (bool): große Überschrift (1.4em statt 1.2em)
/// - number (bool): Aufgabennummer zeigen
/// - workspace (content, none): Arbeitsfläche unter der Aufgabe, zum Beispiel `v(3cm)`; entfällt mit
///   `workspaces: false`
/// - label (label, str, none): Marke für Verweise mit `@`
/// - ..deprecated (arguments): fängt alte Namen und den früheren Titel als Positionsargument ab, nimmt
///   nichts an
/// - body (content): Aufgabentext
/// -> content
#let aufgabe(
  title: none,
  method: none,
  icons: (),
  large: true,
  number: true,
  workspace: none,
  label: none,
  ..deprecated,
  body,
) = {
  if deprecated.pos().len() == 1 and stray-positional(deprecated, content, str) != none {
    fail("aufgaben", "aufgabe", "Titel als zweites Inhaltsargument – `aufgabe(title: [...])[...]` schreiben")
  }
  check-positional("aufgaben", "aufgabe", deprecated, hint: "nur der Aufgabentext steht ohne Namen")
  check-named(
    "aufgaben",
    "aufgabe",
    named-given(deprecated, (title: (title, none))),
    renamed: (titel: "title"),
    allowed: ("title", "method", "icons", "large", "number", "workspace", "label"),
  )
  check-not-empty("aufgaben", "aufgabe", "title", title, "kein Titel")
  check-type("aufgaben", "aufgabe", "title", title, (content, str, none))
  check-value(
    "aufgaben",
    "aufgabe",
    "method",
    method,
    (none, "individual", "pair", "group"),
    renamed: (EA: "individual", PA: "pair", GA: "group"),
  )
  check-type("aufgaben", "aufgabe", "icons", icons, array, example: "(emoji.lightbulb,)")
  check-type("aufgaben", "aufgabe", "large", large, bool)
  check-type("aufgaben", "aufgabe", "number", number, bool)
  if workspace == false {
    fail("aufgaben", "aufgabe", "`workspace: false` – das Aus ist `none`")
  }
  check-type("aufgaben", "aufgabe", "workspace", workspace, (content, none), example: "v(3cm)")
  check-type("aufgaben", "aufgabe", "label", label, (std.label, str, none), example: "<aufgabe-1>")

  // `[]` ist „kein Titel"
  let title = if title == [] { none } else { title }
  let attach-label(body) = if label == none { body } else {
    [#body #if type(label) == std.label { label } else { std.label(label) }]
  }

  // "only": Lösungen der VORHERIGEN Aufgaben zeigen, bevor die neue beginnt.
  // So sind auch Lösungen erfasst, die nach dem aufgabe()-Aufruf kamen (z. B.
  // von Shortcode-Teilaufgaben außerhalb des Rumpfs). Die letzte Aufgabe gibt
  // die Vorlage am Dokumentende aus.
  context if options-state.get().solutions == "only" {
    show-solutions(select: "pending")
  }

  task-counter.step()
  task-counter.update(n => (n, 0)) // Teilaufgaben wieder ab 0
  counter(figure.where(kind: subtask-figure-kind)).update(0)

  let symbols = ()
  if method == "individual" { symbols.push(fa-user-large()) }
  if method == "pair" { symbols.push(fa-user-group()) }
  if method == "group" { symbols.push(fa-users()) }
  symbols += icons

  context {
    let task-number = task-counter.get().at(0)
    records-state.update(records => {
      records.push((
        task-number: task-number,
        title: title,
        subtask-count: 0,
        solution-records: (),
        material-records: (),
        expectation-records: (),
      ))
      records
    })
    task-index-state.update(index => index + 1)
  }
  in-task-state.update(true)

  // Hängende Marke: Ein Theme mit `task-marker` setzt bei Aufgaben ohne Titel
  // die Nummer neben die erste Textzeile statt in eine eigene Kopfzeile.
  let hanging() = theme-hook("task-marker") != none and title == none and number and label == none

  if title != none or number {
    context {
      let options = options-state.get()
      if options.solutions == "only" {
        // Unsichtbarer Anker, damit `@label`-Verweise (z. B. in Lösungen) auch
        // im Lösungsdokument funktionieren und der Zähler weiterläuft.
        place(hide(attach-label(figure(kind: task-figure-kind, supplement: none, []))))
        return
      }
      if hanging() {
        // Zähler wie bei der Kopf-Abbildung weiterschalten (Verweise „1.1")
        counter(figure.where(kind: task-figure-kind)).step()
        return
      }
      let hook = theme-hook("task")
      let with-points = options.points in ("tasks", "all") and options.points-total
      let head = figure(
        kind: task-figure-kind,
        supplement: none,
        gap: 0pt,
        if hook != none {
          let points = if with-points { task-points(task-index-state.get()) } else { 0 }
          align(left, hook(
            marker: if number { [#str(task-counter.get().first())] } else { none },
            title: title,
            icons: symbols,
            points: if points > 0 { points-display(points, target: "task") } else { none },
            large: large,
          ))
        } else {
          text(
            weight: "bold",
            size: if large { 1.4em } else { 1.2em },
            [
              #if symbols.len() > 0 { symbols.join() }
              #if number { "Aufgabe " + str(task-counter.get().first()) }
              #if number and title != none [ $-$ ]
              #if title != none [#title]
              #h(1fr)
              #if with-points {
                let points = task-points(task-index-state.get())
                if points > 0 {
                  points-display(points, target: "task")
                }
              }
            ],
          )
        },
      )
      if label != none [
        #block(
          width: 100%,
          above: 1.8em,
          below: 1em,
          spacing: 0pt,
          // Mit Theme: Kopf nie allein am Seitenende
          sticky: hook != none,
          [
            #head
            #if type(label) == std.label { label } else { std.label(label) }
          ],
        )
      ] else [
        #block(
          width: 100%,
          above: 1.8em,
          below: 1em,
          spacing: 0pt,
          // Mit Theme: Kopf nie allein am Seitenende
          sticky: hook != none,
          head,
        )
      ]
    }
  }
  // Rumpf. Mit "only" unsichtbar setzen, damit loesung() und erwartung()
  // trotzdem erfasst werden.
  context {
    if options-state.get().solutions == "only" {
      if body != none and body != [] { place(hide(body)) }
    } else if hanging() {
      let theme = theme-state.get()
      let width = theme.at("task-marker-width", default: 2.2em)
      // block mit inset statt pad: pad wäre nur so breit wie sein Inhalt,
      // zentrierte Tabellen säßen dann zu weit links.
      keep-together(above: 1.8em, below: 1em, block(width: 100%, inset: (left: width), {
        place(top + left, dx: -width, (theme.at("task-marker"))(task-counter.get().first()))
        if body != none { body }
      }))
    } else if body != none and body != [] {
      if theme-state.get() != none { keep-together(above: 1em, block(width: 100%, body)) } else { body }
    }
  }
  // Arbeitsfläche
  context if workspace != none and options-state.get().workspaces and options-state.get().solutions != "only" {
    if not is-flex-area(workspace) {
      block(width: 100%, inset: (x: 0em, y: 0.5em))[#workspace]
    } else if page.height == auto {
      block(width: 100%, inset: (x: 0em, y: 0.5em), fixed-flex-area(workspace))
    } else {
      // im Textfluss, damit sie sich den freien Platz mit anderen teilt
      block(height: workspace.height, width: 100%, above: 0.5em, below: 0.5em, workspace)
    }
  }
  // Material nach der Aufgabe
  context {
    let options = options-state.get()
    if (
      options.materials == "after-task"
        and records-state.get().last().material-records.len() > 0
        and options.solutions != "only"
    ) {
      if options.materials-pagebreak == "before" {
        pagebreak(weak: true)
      }
      materials-here("current")
    }
  }
  // Lösungen an Ort und Stelle
  context if options-state.get().solutions == "in-place" {
    solutions-here("current", 0, false)
  }
  // Lösungen nach der Aufgabe
  context if options-state.get().solutions == "after-task" {
    solutions-here("current", none, false)
  }
  // "only": Die Lösungen dieser Aufgabe erscheinen erst beim Beginn der
  // nächsten Aufgabe bzw. am Dokumentende (siehe oben).
  // Ohne Summe im Kopf: Punkte nur bei Aufgaben ohne Teilaufgaben, nach der Aufgabe
  context {
    let options = options-state.get()
    if options.points in ("tasks", "all") and not options.points-total {
      let index = task-index-state.get()
      // Endstand des Blocks: Teilaufgaben, die erst nach dem Aufgabenrumpf
      // kommen (Shortcodes), sind sonst noch nicht gezählt.
      let record = final-records().at(index)
      if record.subtask-count == 0 {
        let points = task-points(index)
        if points > 0 {
          block(text(weight: "bold", size: 1.4em, h(1fr) + points-display(points, target: "task")))
        }
      }
    }
  }
  in-task-state.update(false)
  // Abstand nach der Aufgabe (nach allem: Arbeitsfläche, Material, Lösungen)
  v(1cm, weak: true)
}

/// Setzt eine Teilaufgabe innerhalb einer `aufgabe`.
///
/// Teilaufgaben werden nach der Option `subtask-numbering` nummeriert
/// (Start: a), b), c) …).
///
/// ```typ
/// #aufgabe(title: [Gleichungen])[
///   #teilaufgabe[$x^2 - 5x + 6 = 0$]
///   #teilaufgabe(marker: [★])[$x^2 - 9 = 0$]
/// ]
/// ```
///
/// - marker (content, str, none): eigene Beschriftung statt der Nummer; `none` setzt die gewöhnliche Nummer
/// - workspace (content, none): Arbeitsfläche unter der Teilaufgabe; entfällt mit `workspaces: false`
/// - label (label, str, none): Marke für Verweise mit `@`
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Text der Teilaufgabe
/// -> content
#let teilaufgabe(marker: none, workspace: none, label: none, ..deprecated, body) = {
  check-positional("aufgaben", "teilaufgabe", deprecated, hint: "nur der Text der Teilaufgabe steht ohne Namen")
  check-named(
    "aufgaben",
    "teilaufgabe",
    named-given(deprecated, (marker: (marker, none))),
    renamed: (item-label: "marker"),
    allowed: ("marker", "workspace", "label"),
  )
  // `marker: ""` bleibt erlaubt: eine Teilaufgabe ohne sichtbare Marke wie
  // `item-label: ""` in 0.3.1 (`none` hieße „die gewöhnliche Nummer").
  check-type("aufgaben", "teilaufgabe", "marker", marker, (content, str, none))
  if workspace == false {
    fail("aufgaben", "teilaufgabe", "`workspace: false` – das Aus ist `none`")
  }
  check-type("aufgaben", "teilaufgabe", "workspace", workspace, (content, none), example: "v(3cm)")
  check-type("aufgaben", "teilaufgabe", "label", label, (std.label, str, none), example: "<teil-a>")

  task-counter.step(level: 2)

  context {
    records-state.update(records => {
      if records.len() > 0 {
        records.at(-1).subtask-count += 1
      }
      records
    })
  }

  context {
    let records = records-state.get()
    material-count-before-state.update(if records.len() > 0 { records.last().material-records.len() } else { 0 })
  }
  in-subtask-state.update(true)
  context {
    let task-number = task-counter.get().at(0)
    let subtask-number = task-counter.get().at(1, default: 1)
    let index = task-index-state.get()

    let options = options-state.get()
    let with-points = options.points in ("subtasks", "all")
    let at-margin = options.points-position == "margin"

    let item = enum(
      start: subtask-number,
      numbering: n => context [
        #let shown = if marker != none { marker } else { subtask-number-text(task-number, n) }
        #let hook = theme-hook("subtask")
        #if hook != none { hook(shown) } else { shown }
      ],
      {
        // block statt box: Die Nummer steht an der ersten Zeile, auch wenn die
        // Teilaufgabe mit einer Tabelle oder Abbildung beginnt.
        block(
          width: 100%,
          {
            align(left, {
              // Punkte am rechten Seitenrand (außerhalb des Textbereichs)
              if with-points and at-margin {
                context {
                  let points = task-points(index, subtask-number: task-counter.get().at(1))
                  if points > 0 {
                    // linksbündig am Seitenrand, auch wenn die Teilaufgabe in
                    // einem schmaleren Container (z. B. einer grid-Spalte) steht
                    let shown = align(left, text(fill: black, size: 0.88em, hyphenate: false)[#box(
                        width: 2cm,
                        [#points-display(points, target: "subtask")],
                      )])
                    let edge = right-text-edge()
                    if edge == none {
                      place(right, dx: 2mm, box(width: 0cm, shown))
                    } else {
                      place(top + left, dx: edge - here().position().x + 2mm, box(width: 0cm, shown))
                    }
                  }
                }
              }
              body
              // Punkte am Zeilenende
              if with-points and not at-margin {
                context {
                  let points = task-points(index, subtask-number: task-counter.get().at(1))
                  if points > 0 {
                    // Mindestabstand, damit die Punkte nicht am letzten Wort kleben
                    h(1.5em)
                    h(1fr)
                    box(
                      align(
                        top + right,
                        text(fill: black, size: 0.88em)[#points-display(points, target: "subtask")],
                      ),
                    )
                  }
                }
              }
              // Arbeitsfläche
              if workspace != none and options.workspaces {
                if not is-flex-area(workspace) { workspace } else if page.height == auto { fixed-flex-area(workspace) }
              }
            })
          },
        )
      },
    )
    // Verweise (`@label`) im selben Schema wie die Teilaufgabe selbst
    let reference-numbering = if counting-symbol-count(options.subtask-numbering) >= 2 {
      (..n) => subtask-number-text(task-number, subtask-number, pattern: options.subtask-numbering)
    } else { options.subtask-numbering }
    let shown = if label != none [
      #figure(kind: subtask-figure-kind, supplement: "Teilaufgabe", item, numbering: reference-numbering) #if type(label) == std.label { label } else { std.label(label) }
    ] else [
      #figure(kind: subtask-figure-kind, supplement: "Teilaufgabe", item, numbering: reference-numbering)
    ]
    // "only": unsichtbar setzen, damit loesung() und erwartung() im Rumpf
    // trotzdem erfasst werden (wie in aufgabe()).
    if options.solutions == "only" {
      place(hide(shown))
    } else {
      shown
      if is-flex-area(workspace) and options.workspaces and page.height != auto {
        // eingerückt wie der Inhalt der Teilaufgabe
        block(height: workspace.height, width: 100%, inset: (left: 1.6em), above: 0.4em, below: 0.6em, workspace)
      }
    }
  }
  in-subtask-state.update(false)
  context if options-state.get().solutions == "in-place" {
    let subtask-number = if task-counter.get().len() > 1 { task-counter.get().at(1) } else { 0 }
    solutions-here("current", subtask-number, false)
  }
  // Teilaufgabe nach dem Aufgabenrumpf (z. B. Shortcode `+ …` nach `= Titel`):
  // Die Ausgabe am Ende von aufgabe() ist schon gelaufen, daher Lösungen
  // ("after-task") und Material dieser Teilaufgabe hier ausgeben.
  context {
    let options = options-state.get()
    let records = records-state.get()
    if not in-task-state.get() and options.solutions != "only" and records.len() > 0 {
      let subtask-number = task-counter.get().at(1, default: 0)
      if options.solutions == "after-task" {
        solutions-here("current", subtask-number, false)
      }
      if options.materials == "after-task" {
        let record = records.last()
        let before = material-count-before-state.get()
        let added = record.material-records.slice(calc.min(before, record.material-records.len()))
        if added.len() > 0 {
          let shown = task-materials((..record, material-records: added), first-index: before)
          if options.materials-pagebreak == "before" { page(shown) } else { shown }
        }
      }
    }
  }
}

/// Erfasst eine Lösung für die laufende Aufgabe oder Teilaufgabe.
///
/// Die Lösung gehört zur zuletzt begonnenen Teilaufgabe, sonst zur zuletzt
/// begonnenen Aufgabe. Ob und wo sie erscheint, bestimmt die Option
/// `solutions`.
///
/// ```typ
/// #aufgabe[Berechne $7 dot 8$.]
/// #loesung[$7 dot 8 = 56$]
/// ```
///
/// - body (content): Inhalt der Lösung
/// -> content
#let loesung(body) = {
  context {
    let options = options-state.get()
    let subtask-number = if task-counter.get().len() > 1 { task-counter.get().at(1) } else { 0 }
    let in-task = in-task-state.get()
    let in-subtask = in-subtask-state.get()

    // Außerhalb jeder Aufgabe, oder im Aufgabenrumpf nach einer Teilaufgabe
    // (dann ist deren Lösungsausgabe schon vorbei): an Ort und Stelle zeigen,
    // statt die Lösung einer Aufgabe zuzuordnen, deren Ausgabe schon lief.
    let free = (
      not in-task
        and not in-subtask
        and (
          options.solutions in ("in-place", "after-task")
            or (options.solutions == "only" and records-state.get().len() == 0)
        )
    )
    let after-subtask = in-task and not in-subtask and subtask-number > 0 and options.solutions == "in-place"
    if free or after-subtask {
      let title = if after-subtask {
        [Lösung #subtask-number-text(task-counter.get().at(0), subtask-number, pattern: options.subtask-numbering)]
      } else [Lösung]
      solution-callout(title: title, theme: theme-state.get(), body)
      return
    }

    records-state.update(records => {
      if records.len() > 0 {
        records.at(-1).solution-records.push((subtask-number: subtask-number, body: body))
      }
      records
    })
  }
}

/// Erfasst eine Erwartung für die laufende Aufgabe oder Teilaufgabe.
///
/// Die Punkte stehen als Zahl vorn, die Beschreibung als Inhalt dahinter.
/// Ohne Zahl zählt die Erwartung 0 Punkte. Aus den Erwartungen entstehen die
/// Punkteanzeige, `show-expectations` und `show-points-table`.
///
/// ```typ
/// #erwartung(2)[Ergebnis korrekt berechnet]
/// #erwartung[Antwort ist nachvollziehbar begründet]
/// ```
///
/// - ..args (arguments): `[Beschreibung]` oder `(Punkte)[Beschreibung]`; Punkte als `int` oder `float`
/// -> content
#let erwartung(..args) = {
  for name in args.named().keys() {
    if name in ("punkte", "points") {
      fail(
        "aufgaben",
        "erwartung",
        "Punkte als benanntes Argument `" + name + "` – als Zahl vorn schreiben: `erwartung(2)[...]`",
      )
    }
  }
  check-named("aufgaben", "erwartung", args)
  check-positional(
    "aufgaben",
    "erwartung",
    args,
    min: 1,
    max: 2,
    hint: "`erwartung[...]` oder `erwartung(2)[...]` schreiben",
  )
  let positional = args.pos()
  let body = positional.last()
  let points = 0
  if positional.len() == 2 {
    if type(body) in (int, float) {
      fail("aufgaben", "erwartung", "Punkte als zweites Argument – die Zahl steht vorn: `erwartung(2)[...]`")
    }
    points = positional.first()
    check-type("aufgaben", "erwartung", "points", points, (int, float), example: "2")
  }
  if type(body) in (int, float) {
    fail("aufgaben", "erwartung", "die Beschreibung fehlt – `erwartung(" + repr(body) + ")[...]` schreiben")
  }
  context {
    let subtask-number = if task-counter.get().len() > 1 { task-counter.get().at(1) } else { 0 }
    records-state.update(records => {
      if records.len() > 0 {
        records.at(-1).expectation-records.push((subtask-number: subtask-number, body: body, points: points))
      }
      records
    })
  }
}

/// Setzt mehrere Teilaufgaben in einem Raster.
///
/// Mit `numbering: "a)"` sind die Einträge echte Teilaufgaben (`teilaufgabe`)
/// und folgen der Option `subtask-numbering`. Jedes andere Muster (etwa
/// `"i)"`) setzt schlichte, so nummerierte Einträge, die den Zähler der
/// Teilaufgaben nicht verändern.
///
/// ```typ
/// #aufgabe[
///   #teilaufgaben(columns: 2, items: ([$2 + 3$], [$5 dot 7$]), item-solutions: ([$5$], [$35$]))
/// ]
/// ```
///
/// - items (array): die Teilaufgaben, je ein Inhalt
/// - item-solutions (array): Lösungen in der Reihenfolge der `items`
/// - columns (auto, int): Anzahl der Spalten; `auto` setzt alle nebeneinander
/// - numbering (str, function): `"a)"` für echte Teilaufgaben, sonst ein Typst-Muster oder eine Funktion
///   `nummer => inhalt` für schlichte Einträge
/// - gutter (length, relative, ratio, fraction): Abstand zwischen Spalten und zwischen Zeilen
/// - align (auto, alignment, array, function): Ausrichtung in den Zellen wie bei `table`; `auto` übernimmt
///   die Umgebung
/// - inset (length, relative, ratio, dictionary, array, function): Innenabstand der Zellen wie bei `table`
/// - ..deprecated (arguments): fängt alte Namen und die frühere Aufzählung als Inhalt ab, nimmt nichts an
/// -> content
#let teilaufgaben(
  items: (),
  item-solutions: (),
  columns: auto,
  numbering: "a)",
  gutter: 1.25em,
  align: auto,
  inset: 0pt,
  ..deprecated,
) = {
  if stray-positional(deprecated, content) != none {
    fail("aufgaben", "teilaufgaben", "Aufzählung als Inhalt – die Teilaufgaben als `items: ([...], [...])` schreiben")
  }
  check-positional("aufgaben", "teilaufgaben", deprecated)
  check-named(
    "aufgaben",
    "teilaufgaben",
    named-given(deprecated, (items: (items, ()), item-solutions: (item-solutions, ()))),
    renamed: (tasks: "items", loesungen: "item-solutions"),
    removed: (
      row-gutter: "`gutter` gilt für Spalten und Zeilen",
      column-gutter: "`gutter` gilt für Spalten und Zeilen",
      stroke: "für ein eigenes Raster `table` oder `grid` mit `teilaufgabe` in den Zellen schreiben",
      fill: "für ein eigenes Raster `table` oder `grid` mit `teilaufgabe` in den Zellen schreiben",
      rows: "für ein eigenes Raster `table` oder `grid` mit `teilaufgabe` in den Zellen schreiben",
    ),
    allowed: ("items", "item-solutions", "columns", "numbering", "gutter", "align", "inset"),
  )
  check-type("aufgaben", "teilaufgaben", "items", items, array, example: "([...], [...])")
  check-type("aufgaben", "teilaufgaben", "item-solutions", item-solutions, array, example: "([...], [...])")
  check-type("aufgaben", "teilaufgaben", "columns", columns, (auto, int), example: "2")
  check-type("aufgaben", "teilaufgaben", "numbering", numbering, (str, function), example: "\"a)\"")
  // Länge, Anteil und ihre Summe sind in Typst drei Typen; die Meldung nennt sie einmal.
  if type(gutter) not in (length, relative, ratio, fraction) {
    check-type("aufgaben", "teilaufgaben", "gutter", gutter, (relative, fraction), example: "1em")
  }
  check-type(
    "aufgaben",
    "teilaufgaben",
    "align",
    align,
    (auto, alignment, array, function),
    example: "center",
  )
  if type(inset) not in (length, relative, ratio, dictionary, array, function) {
    check-type("aufgaben", "teilaufgaben", "inset", inset, (relative, dictionary, array, function), example: "5pt")
  }

  let cells = ()
  for (position, item) in items.enumerate() {
    let solution = if item-solutions.len() > position [#loesung[#item-solutions.at(position)]]
    if numbering == "a)" {
      cells.push(teilaufgabe[#item #solution])
    } else {
      // Eigene Nummerierung (etwa "i)" für eine Liste innerhalb einer
      // Teilaufgabe): schlichte Einträge, die keine Teilaufgabe mitzählen.
      cells.push(grid(
        columns: (auto, 1fr),
        column-gutter: 0.4em,
        std.numbering(numbering, position + 1),
        [#item #solution],
      ))
    }
  }
  table(
    stroke: none,
    inset: inset,
    align: align,
    columns: (1fr,) * (if columns != auto { columns } else { items.len() }),
    column-gutter: gutter,
    row-gutter: gutter,
    ..cells,
  )
}
