// =============================================================================
// internal.typ – interne Schnittstelle von @schule/aufgaben 0.5.0
// =============================================================================
//
// Zugriff aus anderen @schule-Paketen ausschließlich als Modul:
//
//   #import "@schule/aufgaben:0.5.0" as aufgaben
//   aufgaben.internal.options-state.get().solutions
//
// `internal` nie namentlich importieren (kollidiert mit dem eigenen `internal`
// des importierenden Pakets) und nie weiterreichen. Dokumente benutzen dieses
// Modul nicht; es ist keine zugesicherte Schnittstelle und darf sich mit jeder
// Version ändern (konvention.md 7.2). Jeder State und jeder Counter des Pakets
// wird genau hier angelegt; im übrigen Quelltext steht kein `state("…")`.
//
// Kein Schlüssel wird mit einer älteren Paketversion geteilt: aufgaben 0.3.1
// (`state("options")`, `state("aufgaben")`, `figure(kind: "aufgabe")` …) und
// 0.5.0 stören sich im selben Dokument nicht.
//
// -----------------------------------------------------------------------------
// 1. STATES UND COUNTER  (Schlüsselmuster "schule/aufgaben/<name>@<schema>")
// -----------------------------------------------------------------------------
//
//   Name                        Schlüssel                                   Typ, Startwert, Bedeutung
//   options-state               "schule/aufgaben/options@1"                 dictionary, `option-defaults`: die elf
//                                                                           Optionen des Schemas (Abschnitt 2)
//   records-state               "schule/aufgaben/records@1"                 array aus Datensätzen (Abschnitt 3), ()
//   task-counter                "schule/aufgaben/task-counter@1"            counter mit zwei Ebenen:
//                                                                           (Aufgabennummer, Teilaufgabennummer)
//   task-index-state            "schule/aufgaben/task-index@1"              int, -1: Index der laufenden Aufgabe in
//                                                                           `records-state` (ab 0)
//   material-task-number-state  "schule/aufgaben/material-task-number@1"    int, 0: Nummer der Aufgabe, deren Material
//                                                                           gerade ausgegeben wird (0 = keines)
//   material-number-state       "schule/aufgaben/material-number@1"         int, 0: laufende Nummer des Materials
//                                                                           innerhalb dieser Aufgabe (ab 1)
//   in-solution-state           "schule/aufgaben/in-solution@1"             bool, false: gerade wird ein Lösungskasten
//                                                                           gesetzt (Shortcodes dort abschalten)
//   shown-task-count-state      "schule/aufgaben/shown-task-count@1"        int, 0: Anzahl der Aufgaben, deren Lösungen
//                                                                           `show-solutions(select: "pending")` schon
//                                                                           ausgegeben hat
//   in-task-state               "schule/aufgaben/in-task@1"                 bool, false: Rumpf einer `aufgabe` läuft
//   in-subtask-state            "schule/aufgaben/in-subtask@1"              bool, false: Rumpf einer `teilaufgabe` läuft
//   material-count-before-state "schule/aufgaben/material-count-before@1"   int, 0: Anzahl der Materialien der Aufgabe
//                                                                           vor der laufenden Teilaufgabe
//   theme-state                 "schule/aufgaben/theme@1"                   dictionary oder none, none: Theme-Vertrag
//                                                                           (Abschnitt 4)
//   print-state                 "schule/aufgaben/print@1"                   bool, false: Druckfassung? Geschrieben von
//                                                                           arbeitsblatt (`print-state.update(print)`),
//                                                                           gelesen über `aufgaben.is-print()`
//
//   Abbildungsarten (Werte von `figure(kind:)`, nie als Zeichenkette wiederholen):
//     task-figure-kind     = "task"      Kopf einer Aufgabe; Zähler = Aufgabennummer
//     subtask-figure-kind  = "subtask"   eine Teilaufgabe; Zähler wird je Aufgabe auf 0 gesetzt;
//                                        supplement "Teilaufgabe"
//     material-figure-kind = "material"  ein Material
//   Zähler dazu: `counter(figure.where(kind: task-figure-kind))` usw.
//
//   Reset-Marke: `reset-label` = <schule-aufgaben-reset> an `metadata("reset")`.
//   `reset-tasks()` setzt sie vor dem Zurücksetzen; der Stand von `records-state`
//   an dieser Stelle ist der Endstand des vorherigen Blocks (`final-records`).
//
// -----------------------------------------------------------------------------
// 2. OPTIONS-SCHEMA  (konvention.md Abschnitt 6)
// -----------------------------------------------------------------------------
//
//   option-schema    dictionary Optionsname → (default:, values: array)  bei Auswahlen
//                                             (default:, types: array)   bei allen anderen;
//                    bei Auswahlen zusätzlich `renamed:` (alter Wert → neuer Wert oder
//                    Dictionary Option → Wert, im Format von `check-value`)
//   option-names     array der elf Namen in Schema-Reihenfolge
//   option-defaults  dictionary Optionsname → Vorgabe (Startwert von `options-state`)
//   option-renames   dictionary alter Optionsname → neuer Name, für `check-named(renamed: …)`
//   option-removed   dictionary entfernter Optionsname → Hinweis, für `check-named(removed: …)`
//
//   Option               Werte                                               Vorgabe
//   solutions            none, "in-place", "after-task", "at-end", "only"    none
//   solutions-pagebreak  none, "before", "per-task"                          none
//   materials            none, "after-task", "at-end"                        "after-task"
//   materials-pagebreak  none, "before"                                      "before"
//   points               none, "tasks", "subtasks", "all"                    none
//   points-total         bool                                                true
//   points-position      "end", "margin"                                     "end"
//   points-format        auto, Funktion `points => content`,                 auto
//                        Dictionary (task: f, subtask: g)
//   workspaces           bool                                                true
//   shortcodes           none, "tasks", "subtasks", "all"                    "subtasks"
//   subtask-numbering    str, Typst-Muster mit einem oder zwei Zählzeichen   "a)"
//
//   Was aufgaben selbst auswertet:
//     solutions            "in-place": Lösung direkt nach jeder Teilaufgabe (und nach der Aufgabe);
//                          "after-task": gesammelt nach jeder Aufgabe; "only": nur Lösungen, der
//                          Aufgabentext wird unsichtbar gesetzt, Ausgabe über
//                          `show-solutions(select: "pending")`; "at-end": aufgaben gibt nichts von
//                          selbst aus, die Vorlage ruft am Dokumentende `show-solutions()`.
//     solutions-pagebreak  wirkt nur in `show-solutions()` und nur mit `solutions: "at-end"`:
//                          "before" = weicher Umbruch vor dem Block, "per-task" = jede Aufgabe auf
//                          eigener Seite (`page(…)`).
//     materials            "after-task": Material nach der Aufgabe (bzw. nach der Teilaufgabe, wenn
//                          sie nach dem Aufgabenrumpf steht); "at-end": aufgaben gibt nichts von
//                          selbst aus, die Vorlage ruft `show-materials()`.
//     materials-pagebreak  "before": mit "after-task" steht jeder Materialblock auf eigener Seite
//                          (weicher Umbruch davor und `page(…)`), mit "at-end" ein weicher Umbruch
//                          vor dem Block.
//     points               "tasks"/"all": Punkte im Aufgabenkopf; "subtasks"/"all": an Teilaufgaben.
//     points-total         false: keine Summe im Aufgabenkopf; Aufgaben ohne Teilaufgaben zeigen
//                          ihre Punkte stattdessen in einer Zeile nach der Aufgabe.
//     points-position      Punkte der Teilaufgabe am Zeilenende oder am rechten Seitenrand.
//     points-format        Vorlage für die Punkteanzeige, siehe `resolve-points-format`.
//     workspaces           Arbeitsflächen (`workspace:`) setzen oder weglassen.
//     subtask-numbering    siehe `subtask-number-text`.
//   `shortcodes` wertet aufgaben nicht aus; die Option steht im State, damit arbeitsblatt sie
//   dort liest (options-state.get().shortcodes).
//
//   Prüfen und Setzen:
//     check-options(package, function, options)
//         Prüft Typen und Werte eines Dictionary Optionsname → Wert und bricht mit einer Meldung
//         `<package>.<function>: …` ab (alte Werte: „heißt jetzt", falsches Aus, ungültiger Wert,
//         unzulässige Kombination `solutions-pagebreak: "per-task"` ohne `solutions: "at-end"`).
//         Die Kombination wird NUR unter den gemeinsam übergebenen Werten geprüft: Fehlt
//         `solutions` im Dictionary (oder ist es `unchanged`), gibt es keine Meldung, auch wenn
//         der State einen anderen Wert als "at-end" hat. Der State selbst wird nie geprüft;
//         "per-task" ist dort ohne "at-end" wirkungslos (Varianten schalten `solutions` getrennt). Einträge mit dem Wert `unchanged` und unbekannte
//         Schlüssel werden übersprungen: die NAMEN prüft der Aufrufer vorher selbst mit
//         `check-named(…, renamed: option-renames, removed: option-removed, allowed: …)`.
//         Für den Kopf von arbeitsblatt/klassenarbeit gedacht:
//           aufgaben.internal.check-options("arbeitsblatt", "arbeitsblatt", (solutions: solutions, …))
//     merge-options(current, changes)
//         Liefert `current` mit den Einträgen aus `changes` (ohne `unchanged`). `points-format` als
//         Dictionary wird schlüsselweise in den bisherigen Wert gemischt, alles andere ersetzt.
//     unchanged
//         Markierwert „nicht angegeben" (ein Label). Vorgabe aller Parameter von `set-options`.
//   Der öffentliche Weg zum Setzen ist `aufgaben.set-options(solutions: …, …)`; er prüft und ruft
//   `options-state.update(current => merge-options(current, changes))`.
//
// -----------------------------------------------------------------------------
// 3. DATENSATZ EINER AUFGABE  (Einträge von `records-state`)
// -----------------------------------------------------------------------------
//
//   (
//     task-number: int,            // Nummer der Aufgabe (ab 1)
//     title: content | str | none, // `[]` ist beim Anlegen schon zu `none` geworden
//     subtask-count: int,          // Anzahl der Teilaufgaben
//     solution-records: array,     // je (subtask-number: int, body: content); 0 = Aufgabe selbst
//     material-records: array,     // je (body: content)
//     expectation-records: array,  // je (subtask-number: int, body: content, points: int | float)
//   )
//
// -----------------------------------------------------------------------------
// 4. THEME-VERTRAG  (Schlüssel, die aufgaben aus `theme-state` liest)
// -----------------------------------------------------------------------------
//
//   `theme-state` hält `none` (klassische Darstellung) oder das Theme-Dictionary von arbeitsblatt
//   (konvention.md A.12). aufgaben liest daraus genau diese sieben Schlüssel (`theme-hook-names`);
//   fehlt einer, bleibt für ihn die klassische Darstellung. Die übrigen Schlüssel gehören
//   arbeitsblatt und werden dort geprüft; aufgaben prüft das Dictionary nicht.
//
//   task: (marker: none, title: none, icons: (), points: none, large: true) => content
//       Kopf einer Aufgabe. `marker`: `none` bei `number: false`, sonst die Aufgabennummer als
//       Inhalt (`[1]`, ohne das Wort „Aufgabe"); `title`: content | str | none; `icons`: array aus
//       content (enthält das Symbol aus `method`); `points`: fertig formatierter Inhalt oder `none`;
//       `large`: bool. Alle fünf werden benannt übergeben.
//   task-marker: task-number => content
//       Hängende Marke. Ist der Hook vorhanden, bekommen Aufgaben ohne Titel und ohne Label
//       (mit `number: true`) keine Kopfzeile, sondern diese Marke links neben der ersten Zeile.
//       `task-number`: int, positional.
//   task-marker-width: length
//       Einzug des Rumpfs bei hängender Marke. Vorgabe 2.2em.
//   subtask: marker => content
//       Marke einer Teilaufgabe („a)" oder der Wert von `marker:`), positional.
//   solution: (title: none, body) => content
//       Lösungskasten. `title` benannt (content), `body` positional.
//   solution-heading: title => content
//       Überschrift je Aufgabe im Lösungsblatt (`show-solutions(inline: true)`), positional.
//   material-heading: title => content
//       Überschrift „Material zu Aufgabe n", positional.
//
//   theme-hook-renames: alter Schlüssel (bis 0.3.1/arbeitsblatt 0.4.0) → neuer Schlüssel,
//   für die Prüfung des Theme-Dictionary in arbeitsblatt:
//     aufgabe → task, teilaufgabe → subtask, loesung → solution, loesung-kopf → solution-heading,
//     material-kopf → material-heading, marke → task-marker, marke-breite → task-marker-width
//   Parameter des alten Hooks `aufgabe`: nummer + number → marker, titel → title, punkte → points.
//
// -----------------------------------------------------------------------------
// 5. FUNKTIONEN  (alle, die State lesen, brauchen `context`)
// -----------------------------------------------------------------------------
//
//   fail(function, message)                          bricht ab mit "aufgaben.<function>: <message>"
//   theme-hook(name)                                 Eintrag des Themes oder none            [context]
//   keep-together(above: auto, below: auto, body)    Blöcke unter 9 cm nicht umbrechen
//   solution-callout(title: none, theme: auto, body) Lösungskasten (Hook `solution` oder goal-Kasten)
//   round-points(points)                             Summen auf zwei Stellen, ganze Zahlen als int
//   points-text(points)                              gerundet, mit Dezimalkomma (str oder int)
//   resolve-points-format(value, target)             Vorlagenfunktion für "task" | "subtask"
//   points-display(points, target: "task")           formatierte Punkte nach `points-format`  [context]
//   final-records()                                  Datensätze am Ende des laufenden Blocks  [context]
//   record-points(record, subtask-number: none)      Punktsumme eines Datensatzes
//   task-points(index, subtask-number: none)         Punktsumme der Aufgabe mit Index (ab 0)  [context]
//   right-text-edge()                                x des rechten Textrands oder none        [context]
//   counting-symbol-count(pattern)                   Anzahl der Zählzeichen eines Musters
//   subtask-number-text(task-number, subtask-number, pattern: auto)
//       Beschriftung einer Teilaufgabe nach `subtask-numbering` (einzige Stelle, die das Muster
//       auswertet): ein Zählzeichen → Teilnummer („b)"), zwei → Aufgabe und Teil („3.2").
//       `pattern: auto` liest die Option [context]; mit ausdrücklichem Muster ohne context.
//   expectation-rows(records, options, grouped: false, achieved: false)
//       Tabellenzellen des Erwartungshorizonts; liefert (rows, total).
//   is-flex-area(body)                               Block mit Bruchteilhöhe (`kariert(rows: 1fr)`)?
//   fixed-flex-area(body)                            flexible Fläche mit 3 cm je fr          [context]
//   task-solution(record, subtask-number: none, options: auto, theme: auto)
//                                                    Lösungskasten einer Aufgabe / Teilaufgabe
//   task-solution-inline(record)                     Lösungen einer Aufgabe im Lösungsblatt
//   task-materials(record, first-index: 0)           Materialblock einer Aufgabe
//
// Über `internal` sind außerdem die Funktionen aus `internal/check.typ` sichtbar, die diese Datei
// importiert (`check-named`, `check-value`, `check-type`); abhängige Pakete benutzen dafür ihre
// eigene Kopie von check.typ.
// =============================================================================

#import "internal/check.typ": fail as check-fail, check-named, check-value, check-type

#let package-name = "aufgaben"

/// Bricht mit `aufgaben.<function>: <message>` ab.
///
/// - function (str): Funktionsname
/// - message (str): Befund und Abhilfe, getrennt durch ` – `
/// -> none
#let fail(function, message) = check-fail(package-name, function, message)

// ----------------------------------------------------------------------------
// Options-Schema
// ----------------------------------------------------------------------------

/// Markierwert „nicht angegeben" (Vorgabe aller Parameter von `set-options`).
#let unchanged = <schule-aufgaben-unchanged>

/// Paketvorlagen für die Punkteanzeige (`points-format: auto`).
#let default-points-format = (
  task: points => [*#points BE*],
  subtask: points => [*[#points BE]*],
)

#let option-schema = (
  solutions: (
    default: none,
    values: (none, "in-place", "after-task", "at-end", "only"),
    renamed: (
      sofort: "in-place",
      folgend: "after-task",
      nur: "only",
      reinquetschen: "at-end",
      seite: (solutions: "at-end", solutions-pagebreak: "before"),
      seiten: (solutions: "at-end", solutions-pagebreak: "per-task"),
    ),
  ),
  solutions-pagebreak: (default: none, values: (none, "before", "per-task")),
  materials: (
    default: "after-task",
    values: (none, "after-task", "at-end"),
    renamed: (
      sofort: (materials: "after-task", materials-pagebreak: none),
      folgend: (materials: "after-task", materials-pagebreak: none),
      seiten: (materials: "after-task", materials-pagebreak: "before"),
      seite: (materials: "at-end", materials-pagebreak: "before"),
      reinquetschen: (materials: "at-end", materials-pagebreak: none),
    ),
  ),
  materials-pagebreak: (default: "before", values: (none, "before")),
  points: (
    default: none,
    values: (none, "tasks", "subtasks", "all"),
    renamed: (
      aufgaben: "tasks",
      teilaufgaben: "subtasks",
      alle: "all",
      keine-summe: (points: "all", points-total: false),
    ),
  ),
  points-total: (default: true, types: (bool,)),
  points-position: (default: "end", values: ("end", "margin"), renamed: (ende: "end", rand: "margin")),
  points-format: (default: auto, types: (auto, function, dictionary)),
  workspaces: (default: true, types: (bool,)),
  shortcodes: (
    default: "subtasks",
    values: (none, "tasks", "subtasks", "all"),
    renamed: (aufgaben: "tasks", teilaufgaben: "subtasks", alle: "all"),
  ),
  subtask-numbering: (default: "a)", types: (str,)),
)

#let option-names = option-schema.keys()

#let option-defaults = option-schema.pairs().map(((name, entry)) => (name, entry.default)).to-dict()

#let option-renames = (
  loesungen: "solutions",
  materialien: "materials",
  punkte: "points",
  punkte-position: "points-position",
  punkte-template-aufgabe: "points-format: (task: …)",
  punkte-template-teilaufgabe: "points-format: (subtask: …)",
  teilaufgabe-numbering: "subtask-numbering",
  aufgaben-shortcodes: "shortcodes",
)

#let option-removed = (
  print: "der Druckmodus ist keine Option des Schemas; Abfrage mit `is-print()`",
)

/// Anzahl der Zählzeichen in einem Typst-Nummerierungsmuster.
///
/// - pattern (str): Muster, zum Beispiel `"a)"` oder `"1.1"`
/// -> int
#let counting-symbol-count(pattern) = {
  let symbols = "1aAiIαΑ*①⓵一壹あいアイא가ㄱ١۱१০ক"
  pattern.clusters().filter(cluster => cluster in symbols).len()
}

/// Prüft Typen und Werte eines Dictionary Optionsname → Wert gegen das Schema.
/// Einträge mit `unchanged` und unbekannte Schlüssel werden übersprungen.
///
/// - package (str): Paketname für die Meldung
/// - function (str): Funktionsname für die Meldung
/// - options (dictionary): Optionsname → Wert
/// -> none
#let check-options(package, function, options) = {
  for (name, value) in options {
    if value == unchanged or name not in option-schema { continue }
    let entry = option-schema.at(name)
    if name == "points" and type(value) == dictionary {
      check-fail(
        package,
        function,
        "`points` als Dictionary gibt es nicht mehr – `points: \"all\", points-position: \"margin\"` als zwei Optionen schreiben",
      )
    }
    if "values" in entry {
      check-value(package, function, name, value, entry.values, renamed: entry.at("renamed", default: (:)))
    } else if name == "points-format" {
      check-type(package, function, name, value, entry.types, example: "(task: p => [#p BE], subtask: p => [(#p)])")
      if type(value) == dictionary {
        check-named(
          package,
          function,
          value,
          renamed: (aufgabe: "task", teilaufgabe: "subtask"),
          allowed: ("task", "subtask"),
          what: "Schlüssel",
        )
        for (target, format) in value {
          check-type(package, function, "points-format." + target, format, (std.function, auto), example: "p => [#p BE]")
        }
      }
    } else if name == "subtask-numbering" {
      check-type(package, function, name, value, entry.types, example: "\"a)\"")
      if value == "1." {
        check-fail(package, function, "`subtask-numbering: \"1.\"` heißt jetzt `\"1.1\"`")
      }
      if counting-symbol-count(value) not in (1, 2) {
        check-fail(
          package,
          function,
          "`subtask-numbering: "
            + repr(value)
            + "` ist kein gültiger Wert – ein Zählzeichen für die Teilnummer (`\"a)\"`) oder zwei für Aufgabe und Teil (`\"1.1\"`) schreiben",
        )
      }
    } else {
      check-type(package, function, name, value, entry.types)
    }
  }
  let pagebreak = options.at("solutions-pagebreak", default: unchanged)
  let solutions = options.at("solutions", default: unchanged)
  if pagebreak == "per-task" and solutions != unchanged and solutions != "at-end" {
    check-fail(
      package,
      function,
      "`solutions-pagebreak: \"per-task\"` wirkt nur mit `solutions: \"at-end\"` – eines von beiden ändern",
    )
  }
}

/// Liefert `current` mit den Einträgen aus `changes`. `points-format` als
/// Dictionary wird schlüsselweise in den bisherigen Wert gemischt.
///
/// - current (dictionary): bisherige Optionen
/// - changes (dictionary): Optionsname → neuer Wert; `unchanged` wird übergangen
/// -> dictionary
#let merge-options(current, changes) = {
  let merged = current
  for (name, value) in changes {
    if value == unchanged { continue }
    if name == "points-format" and type(value) == dictionary {
      let before = current.at("points-format", default: auto)
      let base = if type(before) == dictionary { before } else if type(before) == function {
        (task: before, subtask: before)
      } else { (:) }
      merged.insert(name, base + value)
    } else {
      merged.insert(name, value)
    }
  }
  merged
}

// ----------------------------------------------------------------------------
// States, Counter, Kennungen
// ----------------------------------------------------------------------------

#let records-state = state("schule/aufgaben/records@1", ())
#let options-state = state("schule/aufgaben/options@1", option-defaults)
#let task-counter = counter("schule/aufgaben/task-counter@1")
#let task-index-state = state("schule/aufgaben/task-index@1", -1)
#let material-task-number-state = state("schule/aufgaben/material-task-number@1", 0)
#let material-number-state = state("schule/aufgaben/material-number@1", 0)
#let in-solution-state = state("schule/aufgaben/in-solution@1", false)
#let shown-task-count-state = state("schule/aufgaben/shown-task-count@1", 0)
#let in-task-state = state("schule/aufgaben/in-task@1", false)
#let in-subtask-state = state("schule/aufgaben/in-subtask@1", false)
#let material-count-before-state = state("schule/aufgaben/material-count-before@1", 0)
#let theme-state = state("schule/aufgaben/theme@1", none)
#let print-state = state("schule/aufgaben/print@1", false)

#let reset-label = <schule-aufgaben-reset>
#let task-figure-kind = "task"
#let subtask-figure-kind = "subtask"
#let material-figure-kind = "material"

// ----------------------------------------------------------------------------
// Theme
// ----------------------------------------------------------------------------

#let theme-hook-names = (
  "task",
  "task-marker",
  "task-marker-width",
  "subtask",
  "solution",
  "solution-heading",
  "material-heading",
)

#let theme-hook-renames = (
  aufgabe: "task",
  teilaufgabe: "subtask",
  loesung: "solution",
  loesung-kopf: "solution-heading",
  material-kopf: "material-heading",
  marke: "task-marker",
  marke-breite: "task-marker-width",
)

/// Eintrag des Themes oder `none` (braucht `context`).
///
/// - name (str): Schlüssel, zum Beispiel `"task"`
/// -> any
#let theme-hook(name) = {
  let theme = theme-state.get()
  if type(theme) == dictionary { theme.at(name, default: none) } else { none }
}

/// Mit Theme: kurze Blöcke (unter 9 cm) nicht über den Seitenwechsel reißen.
///
/// - above (auto, length): Abstand davor
/// - below (auto, length): Abstand danach
/// - body (content): Inhalt
/// -> content
#let keep-together(above: auto, below: auto, body) = block(above: above, below: below, width: 100%, layout(size => {
  let height = measure(block(width: size.width, body)).height
  if height < 9cm { block(breakable: false, width: 100%, body) } else { body }
}))

/// Lösungskasten: Hook `solution` des Themes, sonst ein grauer goal-Kasten.
///
/// - title (content, none): Überschrift des Kastens
/// - theme (auto, dictionary, none): Theme; `auto` liest den Zustand selbst (eigener `context`). Wer es
///   schon gelesen hat, reicht es herein und spart eine Schachtelungsebene (siehe `task-solution`).
/// - body (content): Inhalt
/// -> content
#let solution-callout(title: none, theme: auto, body) = {
  // Import im Rumpf: Der Fremdname `goal` soll nicht über `internal` sichtbar sein.
  import "@preview/gentle-clues:1.2.0": goal
  let callout(theme) = {
    let hook = if type(theme) == dictionary { theme.at("solution", default: none) } else { none }
    if hook == none { goal(title: title, accent-color: gray, breakable: true, body) } else { hook(title: title, body) }
  }
  if theme == auto { context callout(theme-state.get()) } else { callout(theme) }
}

// ----------------------------------------------------------------------------
// Punkte
// ----------------------------------------------------------------------------

/// Rundet Summen aus Kommazahlen auf zwei Stellen; ganze Zahlen als int.
///
/// - points (int, float): Punktzahl
/// -> int, float
#let round-points(points) = if type(points) == float {
  let rounded = calc.round(points, digits: 2)
  if calc.fract(rounded) == 0 { int(rounded) } else { rounded }
} else { points }

/// Punktzahl für die Anzeige: gerundet und mit Dezimalkomma.
///
/// - points (int, float): Punktzahl
/// -> int, str
#let points-text(points) = {
  let rounded = round-points(points)
  if type(rounded) == float { str(rounded).replace(".", ",") } else { rounded }
}

/// Vorlagenfunktion `points => content` für ein Ziel.
///
/// - value (auto, function, dictionary): Wert der Option `points-format`
/// - target (str): `"task"` oder `"subtask"`
/// -> function
#let resolve-points-format(value, target) = {
  let format = if type(value) == dictionary { value.at(target, default: auto) } else { value }
  if format == auto { default-points-format.at(target) } else { format }
}

/// Formatierte Punkte nach der Option `points-format` (braucht `context`).
///
/// - points (int, float): Punktzahl
/// - target (str): `"task"` oder `"subtask"`
/// -> content
#let points-display(points, target: "task") = {
  let format = resolve-points-format(options-state.get().points-format, target)
  format(points-text(points))
}

/// Datensätze am Ende des laufenden Blocks (bis zum nächsten `reset-tasks()`),
/// statt des Endstands des ganzen Dokuments (braucht `context`).
///
/// -> array
#let final-records() = {
  let following = query(selector(reset-label).after(here()))
  if following.len() > 0 {
    records-state.at(following.first().location())
  } else {
    records-state.final()
  }
}

/// Punktsumme eines Datensatzes.
///
/// - record (dictionary): Datensatz einer Aufgabe
/// - subtask-number (int, none): nur diese Teilaufgabe (0 = Aufgabe selbst); `none` = alles
/// -> int, float
#let record-points(record, subtask-number: none) = {
  let expectations = record.at("expectation-records", default: ())
  if subtask-number != none {
    expectations = expectations.filter(entry => entry.subtask-number == subtask-number)
  }
  round-points(expectations.fold(0, (sum, entry) => sum + entry.points))
}

/// Punktsumme der Aufgabe mit dem Index `index` im laufenden Block (braucht `context`).
///
/// - index (int): Index der Aufgabe, ab 0
/// - subtask-number (int, none): nur diese Teilaufgabe; `none` = Summe der Aufgabe
/// -> int, float
#let task-points(index, subtask-number: none) = {
  let records = final-records()
  if index < 0 or index >= records.len() { return 0 }
  record-points(records.at(index), subtask-number: subtask-number)
}

/// x-Position des rechten Textrands der aktuellen Seite (absolut) oder `none`,
/// wenn sich der Seitenrand nicht bestimmen lässt. Berücksichtigt
/// `inside`/`outside` (braucht `context`).
///
/// -> length, none
#let right-text-edge() = {
  let width = page.width
  if type(width) != length { return none }
  let margin = page.margin
  let right = if type(margin) == dictionary {
    if "right" in margin { margin.right } else if "outside" in margin or "inside" in margin {
      let odd = calc.odd(here().page())
      let left-binding = page.binding == auto or page.binding == left
      if odd == left-binding { margin.at("outside", default: margin.at("rest", default: none)) } else {
        margin.at("inside", default: margin.at("rest", default: none))
      }
    } else { margin.at("x", default: margin.at("rest", default: none)) }
  } else { margin }
  if type(right) == relative { right = right.length + right.ratio * width } else if type(right) == ratio {
    right = right * width
  }
  if type(right) != length { return none }
  width - right
}

// ----------------------------------------------------------------------------
// Nummerierung der Teilaufgaben
// ----------------------------------------------------------------------------

/// Beschriftung einer Teilaufgabe nach `subtask-numbering`: Ein Muster mit
/// einem Zählzeichen bekommt die Teilnummer (`"a)"` → „b)"), eines mit zweien
/// Aufgabennummer und Teilnummer (`"1.1"` → „3.2").
///
/// - task-number (int): Nummer der Aufgabe
/// - subtask-number (int): Nummer der Teilaufgabe, ab 1
/// - pattern (auto, str): Muster; `auto` liest die Option (braucht dann `context`)
/// -> content, str
#let subtask-number-text(task-number, subtask-number, pattern: auto) = {
  let pattern = if pattern == auto { options-state.get().subtask-numbering } else { pattern }
  if counting-symbol-count(pattern) >= 2 {
    numbering(pattern, task-number, subtask-number)
  } else {
    numbering(pattern, subtask-number)
  }
}

// ----------------------------------------------------------------------------
// Erwartungshorizont
// ----------------------------------------------------------------------------

/// Tabellenzellen des Erwartungshorizonts für eine Liste von Datensätzen.
///
/// - records (array): Datensätze
/// - options (dictionary): Optionen (gelesen wird `subtask-numbering`)
/// - grouped (bool): Erwartungen einer Teilaufgabe in einer Zeile
/// - achieved (bool): `__ / X` statt `X`
/// -> array
#let expectation-rows(records, options, grouped: false, achieved: false) = {
  let rows = ()
  let total = 0
  let shown(points) = if achieved { [#h(1em) / #points-text(points)] } else { [$#points-text(points)$] }
  let shaded = gray.lighten(70%)

  for record in records {
    let expectations = record.at("expectation-records", default: ())
    if expectations.len() == 0 { continue }
    let title = if record.title != none and record.title != [] { record.title } else { [] }
    let task-total = expectations.fold(0, (sum, entry) => sum + entry.points)
    total += task-total

    // Kompakt: kein Titel und keine Teilaufgaben. Bei genau einer Teilaufgabe
    // braucht es die Kopfzeile, sonst fehlt die Nummer.
    let compact = title == [] and record.subtask-count == 0

    if not compact {
      let stroke-task = (left: 0.5pt, right: 0.5pt, top: 1pt, bottom: 0.5pt)
      rows.push(table.cell(fill: shaded, stroke: stroke-task, strong[#record.task-number]))
      rows.push(table.cell(stroke: stroke-task, strong[#if title != [] [#title]]))
      rows.push(table.cell(fill: shaded, stroke: stroke-task, strong[#shown(task-total)]))
    }

    let by-subtask = (:)
    for entry in expectations.sorted(key: entry => entry.subtask-number) {
      let key = str(entry.subtask-number)
      if key not in by-subtask.keys() {
        by-subtask.insert(key, ())
      }
      by-subtask.at(key).push(entry)
    }

    for (key, entries) in by-subtask.pairs().sorted(key: pair => int(pair.at(0))) {
      let subtask-number = int(key)
      let marker = if subtask-number == 0 {
        // Im Kompaktmodus: Aufgabennummer statt leer
        if compact { strong[#record.task-number] } else { [] }
      } else {
        subtask-number-text(record.task-number, subtask-number, pattern: options.subtask-numbering)
      }

      if grouped {
        // Eine Zeile je Teilaufgabe mit allen Erwartungen
        let body = stack(spacing: 2 * 6pt, ..entries.map(entry => entry.body))
        let points = entries.fold(0, (sum, entry) => sum + entry.points)
        let inset = (y: 6pt)
        if compact and subtask-number == 0 {
          let stroke-top = (left: 0.5pt, right: 0.5pt, top: 1pt, bottom: 0.5pt)
          rows.push(table.cell(align: top, inset: inset, stroke: stroke-top, fill: shaded, marker))
          rows.push(table.cell(align: left, inset: inset, stroke: stroke-top, body))
          rows.push(table.cell(align: center, inset: inset, stroke: stroke-top, fill: shaded, strong[#shown(points)]))
        } else {
          rows.push(table.cell(align: top, inset: inset, marker))
          rows.push(table.cell(align: left, inset: inset, body))
          rows.push(table.cell(align: center, inset: inset, shown(points)))
        }
      } else {
        // Eine Zeile je Erwartung
        for (position, entry) in entries.enumerate() {
          let shown-marker = if position == 0 { marker } else { [] }
          let stroke-row = if position == 0 {
            (left: 0.5pt, right: 0.5pt, top: 0.5pt, bottom: none)
          } else if position < entries.len() - 1 {
            (left: 0.5pt, right: 0.5pt, top: none, bottom: none)
          } else {
            (left: 0.5pt, right: 0.5pt, top: none, bottom: 0.5pt)
          }
          let inset = (y: 6pt)
          if compact and subtask-number == 0 {
            if position == 0 { stroke-row = (left: 0.5pt, right: 0.5pt, top: 1pt, bottom: none) }
            rows.push(table.cell(align: top, stroke: stroke-row, inset: inset, fill: shaded, shown-marker))
            rows.push(table.cell(align: top + left, stroke: stroke-row, inset: inset, entry.body))
            rows.push(table.cell(
              align: top + center,
              stroke: stroke-row,
              inset: inset,
              fill: shaded,
              strong[#shown(entry.points)],
            ))
          } else {
            rows.push(table.cell(align: top, stroke: stroke-row, inset: inset, shown-marker))
            rows.push(table.cell(align: top + left, stroke: stroke-row, inset: inset, entry.body))
            rows.push(table.cell(align: top + center, stroke: stroke-row, inset: inset, shown(entry.points)))
          }
        }
      }
    }
  }

  (rows, total)
}

// ----------------------------------------------------------------------------
// Arbeitsflächen
// ----------------------------------------------------------------------------

/// Ist die Arbeitsfläche ein flexibles Feld (`kariert(rows: 1fr)` o. Ä., ein
/// Block mit Bruchteilhöhe)? Solche Felder stehen im Textfluss, nur dort teilen
/// sie sich den freien Platz der Seite.
///
/// - body (any): die Arbeitsfläche
/// -> bool
#let is-flex-area(body) = (
  type(body) == content and body.func() == block and type(body.at("height", default: auto)) == fraction
)

/// Seiten mit automatischer Höhe (Digitalfassung) haben keinen freien Platz zum
/// Teilen: Dort bekommt ein flexibles Feld 3 cm je `fr`.
///
/// - body (content): flexible Arbeitsfläche
/// -> content
#let fixed-flex-area(body) = block(height: body.height / 1fr * 3cm, width: 100%, body)

// ----------------------------------------------------------------------------
// Lösungen und Material einer Aufgabe
// ----------------------------------------------------------------------------

// Lösungen der Teilaufgaben als Aufzählung im Schema der Teilaufgaben.
#let subtask-solution-list(record, pattern) = {
  let by-subtask = (:)
  for entry in record.solution-records.filter(entry => entry.subtask-number > 0).sorted(key: entry => entry.subtask-number) {
    let key = str(entry.subtask-number)
    if key not in by-subtask.keys() {
      by-subtask.insert(key, ())
    }
    by-subtask.at(key).push(entry.body)
  }
  enum(
    numbering: if counting-symbol-count(pattern) >= 2 {
      n => numbering(pattern, record.task-number, n)
    } else { pattern },
    tight: false,
    ..by-subtask.pairs().map(((key, bodies)) => enum.item(int(key), stack(spacing: 0.5em, ..bodies))),
  )
}

/// Lösungskasten einer Aufgabe oder einer ihrer Teilaufgaben.
///
/// Ohne `options` und `theme` liest der Kasten beide Zustände selbst, in einem
/// eigenen `context`. Jeder `context`, der erst im Ergebnis eines anderen
/// entsteht, kostet Typst einen weiteren Durchlauf, und nach fünf ist Schluss
/// („document did not converge"). Wer schon in einem `context` steht, reicht
/// beide deshalb herein: Dann entsteht hier keine weitere Ebene.
///
/// - record (dictionary): Datensatz der Aufgabe
/// - subtask-number (int, none): `none` = ganze Aufgabe mit allen Teilen,
///   0 = nur die Lösung zur Aufgabe selbst, n = nur Teilaufgabe n
/// - options (auto, dictionary): Optionen; `auto` liest `options-state`
/// - theme (auto, dictionary, none): Theme; `auto` liest `theme-state`
/// -> content
#let task-solution(record, subtask-number: none, options: auto, theme: auto) = {
  let solution(options, theme) = {
    let solutions = record.solution-records

    if subtask-number == none and solutions.len() > 0 {
      in-solution-state.update(true)
      solution-callout(
        title: [Lösung #{ record.task-number } #if (record.title != none and record.title != []) [-- #{ record.title } ]],
        theme: theme,
        {
          for entry in solutions.filter(entry => entry.subtask-number == 0) {
            entry.body
          }
          if record.subtask-count > 0 {
            subtask-solution-list(record, options.subtask-numbering)
          }
        },
      )
      in-solution-state.update(false)
    } else if solutions.filter(entry => entry.subtask-number == subtask-number).len() > 0 {
      in-solution-state.update(true)
      let bodies = solutions.filter(entry => entry.subtask-number == subtask-number).map(entry => entry.body)
      // 0: Lösung zur ganzen Aufgabe; numbering("a)", 0) gäbe eine Warnung.
      let marker = if subtask-number == 0 { none } else {
        subtask-number-text(record.task-number, subtask-number, pattern: options.subtask-numbering)
      }
      solution-callout(
        title: [Lösung #if subtask-number == 0 { { record.task-number } } else { marker }],
        theme: theme,
        // Eine einzelne Lösung ohne stack: so kann ein Theme die Bezeichnung in
        // dieselbe Zeile setzen.
        if bodies.len() == 1 { bodies.first() } else { stack(spacing: 0.5em, ..bodies) },
      )
      in-solution-state.update(false)
    }
  }
  if options == auto or theme == auto {
    context solution(
      if options == auto { options-state.get() } else { options },
      if theme == auto { theme-state.get() } else { theme },
    )
  } else {
    solution(options, theme)
  }
}

/// Lösungen einer Aufgabe ohne Kasten, gesetzt wie eine Aufgabe (Lösungsblatt).
///
/// - record (dictionary): Datensatz der Aufgabe
/// -> content
#let task-solution-inline(record) = context {
  let options = options-state.get()
  if record.solution-records.len() == 0 { return }

  let hook = theme-hook("solution-heading")
  let has-title = record.title != none and record.title != []
  if hook != none {
    hook([Lösung #{ record.task-number }#if has-title [ -- #{ record.title }]])
  } else {
    block(
      width: 100%,
      above: 1.8em,
      below: 1em,
      spacing: 0pt,
      text(weight: "bold", size: 1.4em, [
        Lösung #{ record.task-number }
        #if has-title [ $-$ #{ record.title }]
      ]),
    )
  }

  for entry in record.solution-records.filter(entry => entry.subtask-number == 0) {
    entry.body
  }

  if record.subtask-count > 0 and record.solution-records.filter(entry => entry.subtask-number > 0).len() > 0 {
    subtask-solution-list(record, options.subtask-numbering)
  }
  v(1cm, weak: true)
}

/// Materialblock einer Aufgabe mit Überschrift.
///
/// - record (dictionary): Datensatz der Aufgabe
/// - first-index (int): Anzahl der schon gesetzten Materialien dieser Aufgabe
///   (Index des ersten hier gesetzten, ab 0)
/// -> content
#let task-materials(record, first-index: 0) = {
  if record.material-records.len() > 0 {
    material-task-number-state.update(record.task-number)
    context {
      let hook = theme-hook("material-heading")
      if hook != none { hook[Material zu Aufgabe #record.task-number] } else {
        block(width: 100%, below: 1em, above: 1.5em, text(14pt, weight: "bold")[Material zu Aufgabe #record.task-number])
      }
    }
    for (position, entry) in record.material-records.enumerate() {
      material-number-state.update(first-index + position + 1)
      entry.body
    }
  }
}
