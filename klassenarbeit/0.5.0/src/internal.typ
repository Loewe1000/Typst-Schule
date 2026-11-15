// =============================================================================
// internal.typ – interne Schnittstelle von @schule/klassenarbeit 0.5.0
// =============================================================================
//
// Dokumente benutzen dieses Modul nicht; es ist keine zugesicherte
// Schnittstelle und darf sich mit jeder Version ändern (konvention.md 7.2).
// Jeder State und jeder Counter des Pakets wird genau hier angelegt.
//
//   exam-counter           counter "schule/klassenarbeit/exam-counter@1": laufende
//                          Nummer der Klassenarbeit im Dokument (ab 1)
//   variant-state          state "schule/klassenarbeit/variant@1": laufende Fassung
//                          (`"print"`, `"solutions"`) oder `none`. Eine zweite
//                          Klassenarbeit innerhalb der ersten erbt sie.
//   end-label(exam-id, variant)
//                          <schule-klassenarbeit-end-{id}-{variant}> an
//                          `metadata("schule/klassenarbeit/document-end")`
//   back-page-label(exam-id)
//                          <schule-klassenarbeit-back-page-{id}>: Ende der Aufgaben
//                          der Seiten 1 bis 3 bei `answer-sheet-pages`
//   logos                  Name → SVG-Quelltext der eingebauten Logos (`angela`)
//
//   exam-parameter-defaults  alle benannten Parameter von `klassenarbeit` mit Vorgabe
//   exam-parameter-names     ihre Namen
//   worksheet-option-names   die Parameter, die an `arbeitsblatt-einzeln` gehen
//   exam-renames, exam-removed, worksheet-only
//                          alte Namen → neue, entfernte Namen → Hinweis, Parameter,
//                          die es nur in `arbeitsblatt` gibt → Hinweis
//   renamed-with-value(name, value)   neuer Name samt neuem Wert für einen alten Namen
//   check-exam-names(deprecated, values)   prüft den Sink von `klassenarbeit`
//   check-exam-values(values)              prüft Typen, Werte und Kombinationen
//
//   resolve-logo(logo)     Logo als Inhalt (`auto` und `"angela"`: das Schullogo)
//   exam-header(…)         Kopf der Klassenarbeit
//   answer-sheets-variant(…)   die Fassung `"answer-sheets"` (nur die Klausurbögen)
//   exam-single(variant:, scope:, exam-id:, settings, body)
//                          genau eine Fassung (`"print"` oder `"solutions"`);
//                          `settings` ist das geprüfte Dictionary aller Kopfparameter
//
// Über `internal` sind außerdem die Prüffunktionen aus `internal/check.typ`
// und die Modulnamen der drei Nachbarpakete sichtbar, die diese Datei importiert.
// =============================================================================

#import "@schule/arbeitsblatt:0.5.0" as worksheet-package
#import "@schule/aufgaben:0.5.0" as task-package
#import "@schule/klausurboegen:0.5.0" as sheet-package
#import "internal/check.typ": (
  check-named, check-not-empty, check-positional, check-type, check-value, fail as check-fail, fold-name,
)
#import "internal/logos.typ": logos

#let package-name = "klassenarbeit"
#let function-name = "klassenarbeit"

/// Bricht mit `klassenarbeit.<function>: <message>` ab.
///
/// - function (str): Funktionsname
/// - message (str): Befund und Abhilfe, getrennt durch ` – `
/// -> none
#let fail(function, message) = check-fail(package-name, function, message)

// ----------------------------------------------------------------------------
// States, Counter, Labels
// ----------------------------------------------------------------------------

#let exam-counter = counter("schule/klassenarbeit/exam-counter@1")

// Laufende Fassung. Als State, damit eine verschachtelte Klassenarbeit
// (mehrere in einer Datei) im Bündel die Fassung des umgebenden Dokuments erbt.
#let variant-state = state("schule/klassenarbeit/variant@1", none)

#let end-label(exam-id, variant) = label("schule-klassenarbeit-end-" + str(exam-id) + "-" + variant)
#let back-page-label(exam-id) = label("schule-klassenarbeit-back-page-" + str(exam-id))

// ----------------------------------------------------------------------------
// Parametertabellen
// ----------------------------------------------------------------------------

#let variant-names = ("print", "solutions", "answer-sheets")
#let variant-renames = (druck: "print", loesung: "solutions", klausurboegen: "answer-sheets")

/// Alle benannten Parameter von `klassenarbeit` mit ihrer Vorgabe, in der
/// Reihenfolge der Signatur.
#let exam-parameter-defaults = (
  title: none,
  subtitle: none,
  class: none,
  date: none,
  teacher: none,
  student: none,
  logo: auto,
  name-field: "Name",
  name-repeat: false,
  info-table: none,
  page-counter: "restart",
  expectations: true,
  answer-sheets: false,
  answer-sheet-pages: false,
  solutions: none,
  solutions-pagebreak: none,
  materials: "after-task",
  materials-pagebreak: "before",
  points: none,
  points-total: true,
  points-position: "end",
  points-format: auto,
  workspaces: true,
  shortcodes: "subtasks",
  subtask-numbering: "a)",
  variants: auto,
  preview-variant: auto,
  filename: none,
  paper: "a4",
  landscape: false,
  duplex: true,
  page-settings: (:),
  theme: auto,
  accent: auto,
  font: auto,
  math-font: auto,
  font-size: auto,
  title-font-size: auto,
  figure-font-size: auto,
)

#let exam-parameter-names = exam-parameter-defaults.keys()

/// Die Parameter, die unverändert an `arbeitsblatt-einzeln` gehen.
#let worksheet-option-names = (
  "title",
  "class",
  "paper",
  "landscape",
  "duplex",
  "page-settings",
  "theme",
  "accent",
  "font",
  "math-font",
  "font-size",
  "title-font-size",
  "figure-font-size",
  ..task-package.internal.option-names,
)

/// Alte Kopfparameter (klassenarbeit 0.0.x bis 0.4.0) und ihr neuer Name.
#let exam-renames = (
  ..task-package.internal.option-renames,
  page-numbering: "page-counter",
  klausurboegen: "answer-sheets",
  erwartungen: "expectations",
  punkte-template: "points-format",
  varianten: "variants",
  variante: "preview-variant",
  dateiname: "filename",
  akzent: "accent",
  schueler: "student",
  header-font-size: "title-font-size",
  bogen: "answer-sheet-pages",
  table: "info-table",
  header-ascent: "page-settings: (header-ascent: …)",
)

#let metadata-hint = "Bibliotheks-Metadaten (`subject`, `topic`, …) gibt es nur in `arbeitsblatt`"

/// Entfernte Kopfparameter und die Abhilfe.
#let exam-removed = (
  print: "eine Klassenarbeit ist immer Druckfassung",
  custom-header: "der Kopf entsteht aus `title`, `subtitle`, `class`, `date`, `teacher`, `logo`; ein eigener Kopf ist der Theme-Hook `header`",
  scope: "die Kennung der Fassung setzt `klassenarbeit` selbst",
  copyright: "`copyright-url` gibt es nur in `arbeitsblatt`",
  zweifach: "zwei Seiten je Bogen (`two-up`) gibt es nur in `arbeitsblatt`",
  fach: metadata-hint,
  thema: metadata-hint,
  jahrgang: metadata-hint,
  niveau: metadata-hint,
  typ: metadata-hint,
  stichworte: metadata-hint,
  kerncurriculum: metadata-hint,
  stand: metadata-hint,
  vorschau-alle: "die Vorschau wählt `preview-variant`",
  bewertung: "die Punkteübersicht ist `show-points-table()`, die Spalte zum Eintragen `expectations: (achieved: true)`",
  ergebnisse: "die Ergebnisse stehen in `answer-sheets: (results: …, overprint: true)`",
  klausurboegen-settings: "die Einstellungen der Bögen stehen in `answer-sheets: (…)`",
)

/// Parameter von `arbeitsblatt`, die `klassenarbeit` nicht annimmt.
#let worksheet-only = (
  header: "der Kopf entsteht aus `title`, `subtitle`, `class`, `date`, `teacher`, `logo`",
  two-up: "zwei Seiten je Bogen gibt es nur in `arbeitsblatt`",
  copyright-url: "den QR-Code in der Kopfzeile gibt es nur in `arbeitsblatt`",
  variant-overrides: "die Fassungen einer Klassenarbeit sind fest: `\"print\"`, `\"solutions\"`, `\"answer-sheets\"`",
  subject: metadata-hint,
  topic: metadata-hint,
  years: metadata-hint,
  stage: "Bibliotheks-Metadaten gibt es nur in `arbeitsblatt`; der Notenschlüssel der Bögen steht in `answer-sheets: (stage: \"sek-1\")`",
  level: metadata-hint,
  kind: metadata-hint,
  keywords: metadata-hint,
  curriculum: metadata-hint,
  revision: metadata-hint,
)

/// Schlüssel von `expectations: (…)`: die Parameter von `show-expectations`.
#let expectation-keys = ("select", "blocks", "grouped", "achieved")
#let expectation-renames = (erreicht: "achieved", alle: "select", teile: "blocks")
#let expectation-removed = (
  "expectations.show": "`expectations: false` schaltet den Erwartungshorizont ab",
  "expectations.new-page": "der Erwartungshorizont beginnt immer auf einer neuen Seite",
)

/// Schlüssel von `answer-sheet-pages: (…)`: die Parameter von
/// `klausurboegen.internal.answer-sheet-pages` und zwei eigene.
#let sheet-page-keys = (
  "title",
  "subtitle",
  "teacher",
  "class",
  "date",
  "logo",
  "stage",
  "continuation",
  "points-table",
  "points-table-preprinted",
  "proposal",
  "subtask-numbering",
  "offset",
  "task-points",
  "back-page",
  "margin",
  "header-spacing",
  "back-page-tasks",
  "points-table-subtasks",
)
#let sheet-page-renames = (
  exam: "title",
  subexam: "subtitle",
  sek1: "stage",
  sub: "continuation",
  result-table: "points-table",
  vorschlag: "proposal",
  numbering: "subtask-numbering",
  mv: "offset",
  aufgaben: "task-points",
  tabelle: "points-table-preprinted",
  rueckseite: "back-page",
  abstand: "header-spacing",
  seite4: "back-page-tasks",
  teilaufgaben: "points-table-subtasks",
)

// ----------------------------------------------------------------------------
// Prüfung der Namen
// ----------------------------------------------------------------------------

/// Der neue Name samt neuem Wert für einen alten Kopfparameter, dessen Wert
/// sich mit dem Namen geändert hat (`page-numbering: false` →
/// `page-counter: none`). `none`, wenn der Wert bleibt; dann nennt die Meldung
/// nur den neuen Namen.
///
/// - name (str): alter Name, bereits gefaltet
/// - value (any): übergebener Wert
/// -> str, none
#let renamed-with-value(name, value) = {
  let schema = task-package.internal.option-schema
  // Wert einer Option des Schemas: das alte Aus, dann die alten Werte.
  let option(new) = {
    if value in (false, none, "keine", "false", "none") { return new + ": none" }
    if type(value) != str { return none }
    let target = schema.at(new).at("renamed", default: (:)).at(value, default: none)
    if target == none {
      none
    } else if type(target) == dictionary {
      target.pairs().map(((key, entry)) => key + ": " + repr(entry)).join(", ")
    } else {
      new + ": " + repr(target)
    }
  }
  let variant(old) = if type(old) == str { variant-renames.at(old, default: old) } else { old }
  if name == "page-numbering" {
    if value == true or value == "reset" {
      "page-counter: \"restart\""
    } else if value == false {
      "page-counter: none"
    } else if value == "continuous" {
      "page-counter: \"continuous\""
    }
  } else if name == "loesungen" {
    option("solutions")
  } else if name == "materialien" {
    option("materials")
  } else if name == "punkte" and type(value) == dictionary {
    // `(anzeige: a, position: p)` → zwei Parameter (Tabelle 1.2)
    let parts = ()
    if "anzeige" in value {
      let display = value.anzeige
      let target = if display in (false, none, "keine", "false", "none") {
        none
      } else {
        schema.points.renamed.at(if type(display) == str { display } else { "" }, default: display)
      }
      parts.push(if type(target) == dictionary {
        target.pairs().map(((key, entry)) => key + ": " + repr(entry)).join(", ")
      } else {
        "points: " + repr(target)
      })
    }
    if "position" in value {
      let position = value.position
      parts.push(
        "points-position: "
          + repr(schema.points-position.renamed.at(if type(position) == str { position } else { "" }, default: position)),
      )
    }
    if parts.len() > 0 { parts.join(", ") }
  } else if name == "punkte" {
    option("points")
  } else if name == "aufgaben-shortcodes" {
    option("shortcodes")
  } else if name == "teilaufgabe-numbering" and value == "1." {
    "subtask-numbering: \"1.1\""
  } else if name == "varianten" and type(value) == str {
    "variants: " + repr((variant(value),))
  } else if name == "varianten" and type(value) == array and value.any(entry => entry in variant-renames) {
    "variants: " + repr(value.map(variant))
  } else if name == "variante" and value in variant-renames {
    "preview-variant: " + repr(variant(value))
  } else if name == "erwartungen" and value in ("keine", "false", "none", none) {
    "expectations: false"
  } else if name == "erwartungen" and type(value) == dictionary and value.at("show", default: true) == false {
    "expectations: false"
  } else if name == "klausurboegen" and type(value) == dictionary and value.at("show", default: true) == false {
    "answer-sheets: false"
  } else {
    none
  }
}

/// Prüft den Sink von `klassenarbeit`: Positionsargumente, alte Namen (mit
/// neuem Wert, wo sich auch der Wert geändert hat), entfernte und unbekannte.
///
/// Bekannte Grenze: „alt und neu zugleich" wird nur erkannt, wenn der neue
/// Name einen anderen Wert als seine Vorgabe trägt. `klassenarbeit(points:
/// none, punkte: "alle")` meldet deshalb „`punkte: "alle"` heißt jetzt
/// `points: "all"`": Ein ausdrücklich geschriebener Vorgabewert ist in der
/// Funktion nicht von einem weggelassenen Parameter zu unterscheiden. Wer der
/// Meldung folgt und den neuen Namen doppelt schreibt, bekommt von Typst
/// „duplicate argument".
///
/// - deprecated (arguments): der Sink
/// - values (dictionary): deklarierte Parameter → übergebener Wert
/// -> none
#let check-exam-names(deprecated, values) = {
  let given = deprecated.named()
  // Was sichtbar gesetzt ist (von der Vorgabe abweicht), geht in die
  // Namensprüfung ein: So entsteht die Meldung „alt und neu zugleich".
  let visible = given
  for (name, value) in values {
    if value != exam-parameter-defaults.at(name) { visible.insert(name, value) }
  }
  for (key, value) in given {
    let folded = fold-name(key)
    if folded == "stufe" {
      fail(
        function-name,
        "`stufe` gibt es nicht mehr – "
          + if value in ("I", "II", false) {
            "der Notenschlüssel steht in `answer-sheets: (stage: \"sek-1\")`"
          } else {
            "Bibliotheks-Metadaten gibt es nur in `arbeitsblatt`"
          },
      )
    }
    if folded == "custom-header" or key in exam-removed { continue }
    if key in worksheet-only {
      fail(function-name, "`" + key + "` gibt es in `klassenarbeit` nicht – " + worksheet-only.at(key))
    }
    if folded in exam-renames and exam-renames.at(folded) not in visible {
      let new = renamed-with-value(folded, value)
      if new != none {
        fail(function-name, "`" + key + ": " + repr(value) + "` heißt jetzt `" + new + "`")
      }
    }
  }
  check-named(
    package-name,
    function-name,
    visible,
    renamed: exam-renames,
    removed: exam-removed,
    allowed: exam-parameter-names,
  )
  // Zuletzt die Positionsargumente: Mit `#show: klassenarbeit.with(titel: …)`
  // soll zuerst der alte Name gemeldet werden.
  check-positional(
    package-name,
    function-name,
    deprecated,
    hint: "außer dem Inhalt alle Angaben benannt schreiben, zum Beispiel `title: [...]`",
  )
}

// ----------------------------------------------------------------------------
// Prüfung der Werte
// ----------------------------------------------------------------------------

// Ein Merkmal mit Einstellungen (W6): `true`, `false` oder ein Dictionary.
#let check-feature(name, value, example) = {
  if value == none or value in ("none", "false", "keine", "") {
    fail(function-name, "`" + name + ": " + repr(value) + "` – das Aus ist `false`")
  }
  if type(value) not in (bool, dictionary) {
    fail(
      function-name,
      "`"
        + name
        + "` erwartet `true`, `false` oder ein Dictionary, bekam `"
        + repr(value)
        + "` ("
        + repr(type(value))
        + ") – zum Beispiel `"
        + name
        + ": "
        + example
        + "`",
    )
  }
}

// Schlüssel eines Dictionary mit vorangestelltem Parameternamen prüfen.
#let check-keys(prefix, settings, renamed: (:), removed: (:), allowed: ()) = {
  let prefixed(names) = names.map(name => prefix + name)
  check-named(
    package-name,
    function-name,
    prefixed(settings.keys()).zip(settings.values()).to-dict(),
    renamed: prefixed(renamed.keys()).zip(prefixed(renamed.values())).to-dict(),
    removed: removed,
    allowed: prefixed(allowed),
    what: "Schlüssel",
  )
}

/// Prüft Typen, Werte und Kombinationen aller Parameter von `klassenarbeit`
/// und meldet unter `klassenarbeit.klassenarbeit`, bevor irgendein Wert an
/// `arbeitsblatt`, `aufgaben` oder `klausurboegen` weitergeht.
///
/// - values (dictionary): Parameter → Wert (alle Parameter)
/// -> none
#let check-exam-values(values) = {
  let package = package-name
  let function = function-name

  // Kopf
  let texts = (
    subtitle: "kein Untertitel",
    date: "kein Datum",
    teacher: "keine Lehrkraft",
    student: "kein Name",
    name-field: "kein Namensfeld",
  )
  for (name, meaning) in texts {
    check-not-empty(package, function, name, values.at(name), meaning)
    check-type(package, function, name, values.at(name), (str, content, none))
  }
  check-value(package, function, "logo", values.logo, (auto, none, content, ..logos.keys()))
  check-type(package, function, "name-repeat", values.name-repeat, bool)

  let info-table = values.info-table
  if info-table == false {
    fail(function, "`info-table: false` – das Aus ist `none`")
  }
  let pairs-example = "info-table: (([Hilfsmittel], [Taschenrechner]), ([Zeit], [45 Minuten]))"
  check-type(package, function, "info-table", info-table, (array, none), example: pairs-example)
  if info-table != none and info-table.any(row => type(row) != array or row.len() != 2) {
    fail(
      function,
      "`info-table` erwartet Paare `(Beschriftung, Wert)`, bekam `"
        + repr(info-table.find(row => type(row) != array or row.len() != 2))
        + "` – zum Beispiel `"
        + pairs-example
        + "`",
    )
  }

  check-value(
    package,
    function,
    "page-counter",
    values.page-counter,
    (none, "restart", "continuous"),
    renamed: ("true": "restart", reset: "restart"),
  )

  // Erwartungshorizont
  let expectations = values.expectations
  check-feature("expectations", expectations, "(achieved: true)")
  if type(expectations) == dictionary {
    check-keys(
      "expectations.",
      expectations,
      renamed: expectation-renames,
      removed: expectation-removed,
      allowed: expectation-keys,
    )
    let select = expectations.at("select", default: "current")
    let blocks = expectations.at("blocks", default: ())
    check-value(
      package,
      function,
      "expectations.select",
      select,
      ("current", "all"),
      renamed: ("true": "all", "false": "current"),
    )
    check-type(package, function, "expectations.blocks", blocks, array, example: "([Teil A], [Teil B])")
    for name in ("grouped", "achieved") {
      check-type(package, function, "expectations." + name, expectations.at(name, default: false), bool)
    }
    if blocks.len() > 0 and select != "all" {
      fail(
        function,
        "`expectations.blocks` wirkt nur mit `select: \"all\"` – `select: \"all\"` ergänzen oder `blocks` weglassen",
      )
    }
  }

  // Klausurbögen
  let answer-sheets = values.answer-sheets
  check-feature("answer-sheets", answer-sheets, "(pattern: \"lines\")")
  if type(answer-sheets) == dictionary {
    if "show" in answer-sheets {
      fail(
        function,
        "`answer-sheets.show` gibt es nicht mehr – `answer-sheets: false` schaltet die Bögen ab, ein Dictionary schaltet sie ein",
      )
    }
    if "ergebnisse" in answer-sheets {
      fail(function, "`answer-sheets.ergebnisse` heißt jetzt `answer-sheets.results`, dazu `overprint: true`")
    }
    if "stufe" in answer-sheets {
      let stage = answer-sheets.stufe
      fail(
        function,
        "`answer-sheets.stufe` heißt jetzt `answer-sheets.stage`"
          + if stage in ("I", "II") { ": `stage: \"sek-" + str(stage.len()) + "\"`" } else { "" },
      )
    }
    sheet-package.internal.check-names(package, function, answer-sheets, prefix: "answer-sheets.")
    sheet-package.internal.check-values(package, function, answer-sheets, prefix: "answer-sheets.")
  }

  // Arbeit direkt auf dem Bogen
  let sheet-pages = values.answer-sheet-pages
  check-feature("answer-sheet-pages", sheet-pages, "(stage: \"sek-1\")")
  if type(sheet-pages) == dictionary {
    let rule = "der Seitenrand steht in `answer-sheet-pages: (margin: (top:, bottom:, x:))`"
    // Alte Schlüssel, deren Wert sich mit dem Namen geändert hat
    // (`sek1: true` → `stage: "sek-1"`): derselbe Wertpfad wie bei `answer-sheets`.
    for (key, value) in sheet-pages {
      if key in sheet-page-renames and sheet-page-renames.at(key) not in sheet-pages {
        let new = sheet-package.internal.renamed-with-value(key, value)
        if new != none and new.starts-with(sheet-page-renames.at(key) + ":") {
          fail(
            function,
            "`answer-sheet-pages." + key + ": " + repr(value) + "` heißt jetzt `answer-sheet-pages." + new + "`",
          )
        }
      }
    }
    check-keys(
      "answer-sheet-pages.",
      sheet-pages,
      renamed: sheet-page-renames,
      removed: ("answer-sheet-pages.rand": rule, "answer-sheet-pages.unten": rule),
      allowed: sheet-page-keys,
    )
    sheet-package.internal.check-values(package, function, sheet-pages, prefix: "answer-sheet-pages.")
    if "back-page" in sheet-pages and "back-page-tasks" in sheet-pages {
      fail(
        function,
        "`answer-sheet-pages.back-page` und `back-page-tasks` zugleich – eines von beiden angeben",
      )
    }
    if "back-page-tasks" in sheet-pages {
      check-type(
        package,
        function,
        "answer-sheet-pages.back-page-tasks",
        sheet-pages.back-page-tasks,
        content,
        example: "[#aufgabe[…]]",
      )
    }
    if "points-table-subtasks" in sheet-pages {
      check-type(
        package,
        function,
        "answer-sheet-pages.points-table-subtasks",
        sheet-pages.points-table-subtasks,
        bool,
      )
    }
  }

  // Fassungen und Ausgabe
  let variants = values.variants
  let variant-example = "(\"print\", \"solutions\")"
  if type(variants) == str and variants in variant-renames {
    fail(
      function,
      "`variants: " + repr(variants) + "` heißt jetzt `variants: " + repr((variant-renames.at(variants),)) + "`",
    )
  }
  check-type(package, function, "variants", variants, (auto, array), example: variant-example)
  if variants != auto {
    for name in variants {
      check-value(package, function, "variants", name, variant-names, renamed: (druck: "print"))
    }
  }
  check-value(
    package,
    function,
    "preview-variant",
    values.preview-variant,
    (auto, ..variant-names),
    renamed: (druck: "print"),
  )
  check-not-empty(package, function, "filename", values.filename, "kein eigener Dateiname")
  check-type(package, function, "filename", values.filename, (str, none))

  // Unterschlüssel von `points-format` mit dem Parameternamen davor melden
  // (Tabelle 1.4), bevor die gemeinsame Prüfung sie ohne Präfix nennt.
  if type(values.points-format) == dictionary {
    check-keys(
      "points-format.",
      values.points-format,
      renamed: (aufgabe: "task", teilaufgabe: "subtask"),
      allowed: ("task", "subtask"),
    )
  }

  // Alles, was an `arbeitsblatt-einzeln` geht (Typen, Auswahlen, Kombinationen).
  worksheet-package.internal.check-worksheet-options(
    package,
    function,
    worksheet-option-names.map(name => (name, values.at(name))).to-dict(),
  )
}

// ----------------------------------------------------------------------------
// Kopf
// ----------------------------------------------------------------------------

/// Löst `logo` auf: `auto` und ein Name aus `logos` sind das eingebaute Logo.
///
/// - logo (content, str, auto, none): Logo
/// -> content, none
#let resolve-logo(logo) = {
  if logo == auto { logo = "angela" }
  if type(logo) == str { image(bytes(logos.at(logo))) } else { logo }
}

/// Kopf der Klassenarbeit: Logo, Titel mit Untertitel, Datum, Klasse und
/// Lehrkraft. Mit `name-line` wiederholt er darunter das Namensfeld.
///
/// - title (content, str, none): Titel
/// - subtitle (content, str, none): Untertitel (nur mit Logo)
/// - class (content, str, none): Klasse
/// - date (content, str, none): Datum
/// - teacher (content, str, none): Lehrkraft
/// - logo (content, none): fertig aufgelöstes Logo
/// - font (str, array): Schrift des Kopfs
/// - name-line (content, none): Namensfeld für die Wiederholung auf jeder Seite
/// -> content
#let exam-header(
  title: none,
  subtitle: none,
  class: none,
  date: none,
  teacher: none,
  logo: none,
  font: "Myriad Pro",
  name-line: none,
) = {
  set text(font: font, hyphenate: true, lang: "de")
  // Fehlende Angaben als leerer Text, nicht als nichts: Eine leere Zelle wäre
  // niedriger als eine Textzeile, der Kopf ohne Datum also kürzer als bis 0.4.0.
  let shown(value) = if value == none { "" } else { value }
  let title = shown(title)
  let date = shown(date)
  let class-and-teacher = if class != none and teacher != none [#class - #teacher] else [#shown(class)#shown(teacher)]
  table(
    columns: (2.5cm, 1fr, 2.5cm),
    align: center + horizon,
    stroke: none,
    inset: 3pt,
    ..if logo != none {
      (
        table.cell(rowspan: 2, align: left + horizon, inset: (rest: 0pt, bottom: 4pt))[#text(
          16pt,
          weight: "semibold",
        )[#box(height: 1cm)[#logo]]],
        table.cell(rowspan: 2)[#stack(
          spacing: 0mm,
          text(16pt, weight: "semibold")[#title],

          if subtitle != none {
            v(2mm)
            text(12pt, weight: "regular")[#subtitle]
          },
        )],
        table.cell(align: right + horizon)[#text(11pt, weight: "regular")[#date]],
        table.cell(align: right + horizon)[#text(11pt, weight: "regular")[#class-and-teacher]],
      )
    } else {
      (
        [],
        table.cell(rowspan: 2)[#text(16pt, weight: "semibold")[#title]],
        table.cell(align: right + horizon)[#date],
        [],
        table.cell(align: right + horizon)[#class-and-teacher],
      )
    },
    table.hline(stroke: 0.5pt + luma(200)),
    ..if name-line != none {
      (
        table.cell(align: left + horizon, inset: (x: 0pt, y: 14pt))[#name-line],
        table.hline(stroke: 0.5pt + luma(200)),
      )
    },
  )
}

// ----------------------------------------------------------------------------
// Fassungen
// ----------------------------------------------------------------------------

// Das Logo für die Bögen: `auto` und `"angela"` sind dort das Schullogo des
// Pakets klausurboegen.
#let sheet-logo(logo) = if logo == auto or type(logo) == str { auto } else { logo }

/// Die Fassung `"answer-sheets"`: nur die Klausurbögen, als eigenes Dokument.
///
/// Ohne `results` in `settings` entsteht genau ein leerer Bogen (zum
/// Kopieren), mit `results` und `overprint: true` der Ergebnisdruck je
/// Schülerin und Schüler. `settings` gewinnt gegen die übrigen Argumente.
///
/// - title (content, str, none): Titel der Klassenarbeit
/// - subtitle (content, str, none): Untertitel
/// - teacher (content, str, none): Lehrkraft
/// - class (content, str, none): Klasse
/// - date (content, str, none): Datum
/// - logo (content, str, auto, none): Logo der Klassenarbeit
/// - subtask-numbering (str): Nummerierung der Teilaufgaben
/// - settings (dictionary): geprüfte Schlüssel von `answer-sheets: (…)`
/// -> content
#let answer-sheets-variant(
  title: none,
  subtitle: none,
  teacher: none,
  class: none,
  date: none,
  logo: auto,
  subtask-numbering: "a)",
  settings: (:),
) = sheet-package.klausurboegen(
  title: title,
  subtitle: subtitle,
  teacher: teacher,
  class: class,
  date: date,
  logo: sheet-logo(logo),
  subtask-numbering: subtask-numbering,
  ..settings,
)

// Setzt Zähler und Datensätze der Aufgaben zurück wie `reset-tasks()`, aber
// ohne dessen Reset-Marke: Die Aufgaben der Rückseite (`back-page-tasks`)
// bilden keinen eigenen Block.
#let rewind-tasks() = {
  let tasks = task-package.internal
  tasks.task-counter.update((0, 0))
  counter(figure.where(kind: tasks.task-figure-kind)).update(0)
  counter(figure.where(kind: tasks.subtask-figure-kind)).update(0)
  counter(figure.where(kind: tasks.material-figure-kind)).update(0)
  tasks.records-state.update(())
  tasks.task-index-state.update(-1)
  tasks.material-task-number-state.update(0)
  tasks.material-number-state.update(0)
  tasks.shown-task-count-state.update(0)
  tasks.material-count-before-state.update(0)
}

/// Setzt genau eine Fassung der Klassenarbeit: `"print"` ist die Arbeit
/// selbst, `"solutions"` das Lösungsdokument (Lösungen statt Aufgabentext,
/// Erwartungshorizont am Ende). Klausurbögen sind nie Teil dieses Dokuments.
///
/// - variant (str): `"print"` oder `"solutions"`
/// - scope (str, none): Kennung der Fassung im Bündel; `none` = einzelnes Dokument
/// - exam-id (int): laufende Nummer der Klassenarbeit im Dokument
/// - settings (dictionary): alle Kopfparameter von `klassenarbeit`, geprüft
/// - body (content): die Arbeit
/// -> content
#let exam-single(variant: "print", scope: none, exam-id: 1, settings, body) = context {
  variant-state.update(variant)
  let tasks = task-package.internal
  let worksheets = worksheet-package.internal

  let title = settings.title
  let subtitle = settings.subtitle
  let class = settings.class
  let date = settings.date
  let teacher = settings.teacher
  let name-field = settings.name-field
  let name-repeat = settings.name-repeat
  let page-counter = settings.page-counter
  let info-table = if settings.info-table == none { () } else { settings.info-table }

  // Ende-Marke je Fassung: Im Bündel steht der Inhalt in mehreren Dokumenten,
  // die Labels müssen deshalb je Fassung eindeutig sein.
  let end = end-label(exam-id, variant)

  // Druckfassung direkt auf dem Klausurbogen (A3, gefaltet). Die Lösung
  // bleibt ein A4-Dokument für die Lehrkraft.
  let on-sheet = settings.answer-sheet-pages != false and variant == "print"

  // Theme: gestaltet Aufgaben, Kästen, Lösungen und Schrift. Kopf, Ränder,
  // Fußzeile und Seitenhintergrund bleiben die der Klassenarbeit – eine
  // Titelkarte oder Randleiste würde mit Logo, „Seite x von y" und den engeren
  // Rändern kollidieren.
  let theme = worksheets.resolve-theme(
    settings.theme,
    accent: settings.accent,
    class: if class == none { "" } else { class },
    package: package-name,
    function: function-name,
  )
  if theme != none {
    for key in ("header", "footer", "background", "margin", "header-ascent") {
      let _ = theme.remove(key, default: none)
    }
  }
  let font = if settings.font != auto { settings.font } else if theme != none {
    theme.at("font", default: "Myriad Pro")
  } else { "Myriad Pro" }
  font = (..if type(font) == array { font } else { (font,) }, "Fira Sans", "New Computer Modern Sans", "DejaVu Sans")

  let name-line = if name-field != none {
    text(14pt, weight: "semibold")[#name-field: #h(0.25em) #settings.student]
  }

  set page(
    footer: if page-counter != none {
      context [
        #let current-page = counter(page).at(here()).at(0)
        #let end-page = counter(page).at(end).at(0)
        // Bei "continuous": die letzte Seite der LETZTEN Klassenarbeit im
        // Dokument. Im Bündel (scope gesetzt) ist jede Klassenarbeit ein
        // eigenes Dokument, die Labels sind aber global – dort zählt nur das
        // eigene Ende.
        #let last-page = if page-counter == "continuous" and scope == none {
          let last-end = end-label(exam-counter.final().first(), variant)
          // Im Bündel kann die letzte Klassenarbeit in einem anderen
          // Dokument liegen; dann auf das eigene Ende zurückfallen.
          if query(last-end).len() > 0 {
            counter(page).at(last-end).at(0)
          } else {
            end-page
          }
        } else {
          end-page
        }
        // Physische Seite vergleichen: Seiten nach dem Ende (zum Beispiel
        // der Erwartungshorizont) bekommen keine Seitenzahl.
        #if here().page() <= locate(end).page() [
          #set text(8pt, font: font)
          #set align(right)
          Seite #current-page von #last-page
        ]
      ]
    },
  )

  // Fester Abstand zwischen Kopf und Inhalt – auf JEDER Seite, unabhängig von
  // `name-repeat`. Er steht in `header-ascent`; der obere Rand wächst um
  // denselben Betrag, damit der Kopf weiter am oberen Rand (1 cm) beginnt.
  let header-gap = 14pt
  let page-settings = settings.page-settings
  if "margin" not in page-settings {
    page-settings.insert("margin", (top: 1cm, bottom: 1cm, left: 1.5cm, right: 1.5cm))
  }
  if type(page-settings.margin) == dictionary {
    let margin = page-settings.margin
    margin.insert(
      "top",
      margin.at("top", default: margin.at("y", default: margin.at("rest", default: 1cm))) + header-gap,
    )
    page-settings.insert("margin", margin)
  }
  if "header-ascent" not in page-settings {
    page-settings.insert("header-ascent", header-gap)
  }

  // Auf dem Klausurbogen kommen Seiten, Kopfbereich und Punktetabelle aus
  // klausurboegen. Die Tabelle hat eine Spalte je Aufgabe; die Namen ("1",
  // "2", …) sind die Spaltenköpfe der Ergebnis-CSV für den Ergebnisdruck.
  //
  // `back-page-tasks`: Aufgaben für die Rückseite (Seite 4). Sie stehen im
  // Satz vor Seite 1, sind aber die letzten Aufgaben:
  // - Vor ihnen springen Zähler und Aufgabenindex hinter die Aufgaben der
  //   Seiten 1 bis 3. Deren Anzahl liest die Marke am Ende der Arbeit ab.
  // - Nach ihnen wird alles zurückgesetzt; Seite 1 beginnt mit Aufgabe 1.
  // - Am Ende der Arbeit werden sie unsichtbar ein zweites Mal gesetzt. So
  //   stehen sie auch in der Aufgabenliste an der richtigen Stelle, und
  //   Punkte, Tabelle und Erwartungen passen.
  // In der Lösung (und ohne Bogen) folgen sie einfach am Ende.
  let sheet-settings = if type(settings.answer-sheet-pages) == dictionary { settings.answer-sheet-pages } else { (:) }
  let back-page-tasks = sheet-settings.remove("back-page-tasks", default: none)
  // Vorgabe `true`: eine Spalte je Teilaufgabe, wie der Ergebnisdruck aus
  // einer CSV mit Teilaufgaben ("A1 a)" …). `false`: nur Aufgabensummen.
  let with-subtasks = sheet-settings.remove("points-table-subtasks", default: true)
  let back-page-end = back-page-label(exam-id)
  let sheet = if on-sheet {
    if back-page-tasks != none {
      sheet-settings.insert("back-page", {
        context {
          let marks = query(back-page-end)
          let count = if marks.len() > 0 { tasks.task-counter.at(marks.first().location()).first() } else { 0 }
          tasks.task-counter.update((count, 0))
          tasks.task-index-state.update(count - 1)
        }
        back-page-tasks
        rewind-tasks()
      })
    }
    let task-points = tasks.records-state.final().sorted(key: record => record.task-number).map(record => {
      let expectations = record.expectation-records
      let total = expectations.fold(0, (sum, entry) => sum + entry.points)
      let parts = expectations
        .map(entry => entry.at("subtask-number", default: 0))
        .filter(number => number != none and number > 0)
        .dedup()
        .sorted()
      if with-subtasks and parts.len() > 0 {
        (
          str(record.task-number),
          parts.map(number => expectations
            .filter(entry => entry.at("subtask-number", default: 0) == number)
            .fold(0, (sum, entry) => sum + entry.points)),
        )
      } else {
        (str(record.task-number), total)
      }
    })
    sheet-package.internal.answer-sheet-pages(
      title: title,
      subtitle: subtitle,
      class: class,
      date: date,
      teacher: teacher,
      logo: sheet-logo(settings.logo),
      subtask-numbering: settings.subtask-numbering,
      task-points: task-points,
      ..sheet-settings,
    )
  }

  // Immer beide Vorlagen der Punkteanzeige setzen (ohne Angabe die
  // Paketvorlage), damit die Vorlage einer vorherigen Klassenarbeit nicht
  // weiterwirkt.
  let points-format = settings.points-format
  if type(points-format) == dictionary {
    points-format = (task: points-format.at("task", default: auto), subtask: points-format.at("subtask", default: auto))
  }

  let options = worksheet-option-names.map(name => (name, settings.at(name))).to-dict()
  options.points-format = points-format
  if theme != none { options.theme = theme }
  if variant == "solutions" {
    options.solutions = "only"
    options.solutions-pagebreak = none
  }
  if on-sheet {
    options.paper = "a3"
    options.landscape = true
  }

  options.page-settings = if on-sheet { sheet.page } else { page-settings }

  // Nur auf dem Bogen: Sonst gilt, was das Dokument mit
  // `#set columns(gutter: …)` gesetzt hat (wie in 0.4.0).
  set columns(gutter: sheet.gutter) if on-sheet

  show: worksheet-package.arbeitsblatt-einzeln.with(
    ..options,
    print: true,
    header: if on-sheet { none } else {
      exam-header(
        title: title,
        subtitle: subtitle,
        date: date,
        class: class,
        teacher: teacher,
        logo: resolve-logo(settings.logo),
        font: font,
        name-line: if name-repeat { name-line },
      )
    },
    scope: scope,
  )

  // Seitenzähler nur mit "restart" zurücksetzen. Erst hier, nach dem
  // `set page` aus arbeitsblatt-einzeln: Sonst landet die Änderung auf der
  // vorherigen Seite, sobald zwischen zwei Klassenarbeiten Inhalt steht.
  if page-counter == "restart" {
    counter(page).update(1)
  }

  if on-sheet {
    // Der Name steht im Kopfbereich des Bogens.
    sheet.preamble
  } else if info-table.len() > 0 {
    let cells = info-table.map(row => (
      table.cell(inset: (left: 0pt, top: 6pt, bottom: 6pt, right: 6pt), [*#row.at(0):*]),
      [#row.at(1)],
    ))

    if not name-repeat and name-field != none {
      name-line
      v(14pt, weak: true)
    }

    table(
      columns: (auto, 1fr),
      align: left,
      inset: 6pt,
      stroke: none,
      table.hline(stroke: 0.5pt + luma(200)),
      ..cells.flatten(),
      table.hline(stroke: 0.5pt + luma(200)),
    )
  } else if not name-repeat and name-field != none {
    name-line
    v(-3pt)
    line(length: 100%, stroke: 0.5pt + luma(200))
    v(6pt)
  }

  body

  if back-page-tasks != none {
    if on-sheet {
      [#metadata(none) #back-page-end]
      place(hide(back-page-tasks))
    } else {
      back-page-tasks
    }
  }

  // Lösungsdokument: restliche Lösungen VOR dem Erwartungshorizont ausgeben
  // (die Ausgabe am Dokumentende zeigt sie nicht noch einmal).
  context if variant == "solutions" {
    task-package.show-solutions(select: "pending")
  }

  [#metadata("schule/klassenarbeit/document-end") #end]

  // Erwartungshorizont: im Bündel nur im Lösungsdokument, sonst am Ende des
  // Dokuments. Der Scope-State erkennt auch eine verschachtelte Klassenarbeit
  // innerhalb eines Dokuments des Bündels. Auf dem Klausurbogen nie: Er hat
  // genau vier Seiten.
  let expectations = settings.expectations
  let expectation-settings = if type(expectations) == dictionary { expectations } else { (:) }
  context if expectations != false and not on-sheet and (variant == "solutions" or worksheets.scope-state.get() == none) {
    // Die Seiten des Erwartungshorizonts zählen nicht zur Klassenarbeit: Am
    // Ende des Horizonts (noch auf dessen letzter Seite) den Zähler auf das
    // Ende der Arbeit zurücksetzen, damit eine folgende Klassenarbeit mit
    // "continuous" lückenlos weiterzählt.
    page({
      task-package.show-expectations(..expectation-settings)
      context counter(page).update(counter(page).at(end).first())
    })
  }
}
