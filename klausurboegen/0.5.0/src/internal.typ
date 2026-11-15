// Interne Helfer von klausurboegen. Keine zugesicherte Schnittstelle: Namen und
// Signaturen dürfen sich in jeder Version ändern. Dokumente benutzen dieses
// Modul nicht; `klassenarbeit` erreicht darüber die Arbeit auf dem Bogen
// (`answer-sheet-pages`) und die Prüftabellen (`renamed-parameters`,
// `allowed-parameters`, `check-names`, `check-values`; die beiden letzten mit
// `prefix: "answer-sheets."` für die Schlüssel eines Dictionarys).
//
// Herkunft: Die Kopf-, Noten- und Tabellen-Helfer stammen aus dem Ast 0.0.4,
// das Seitenlayout (`is-fold-left`, `is-margin-left`, `writing-area`,
// `half-page`) aus dem Ast 0.0.5.
//
// Die Tabellen (Kopf, Notenschlüssel, Punktetabelle) setzt Typsts eingebautes
// `grid`, nicht mehr tablex: tablex braucht für seine Positionen mehrere
// Layout-Durchläufe, und in der Arbeit auf dem Bogen reichten die fünf von
// Typst dann nicht („document did not converge"). `grid` statt `table`, damit
// `set table`/`show table` eines Dokuments die Bögen wie bisher nicht berührt.
//
// `kariert` (aus @schule/patterns) wird nur im Funktionsrumpf importiert: So
// landet kein Name eines anderen Pakets in `klausurboegen.internal`. Die Prüffunktionen aus `internal/check.typ`
// (`fail`, `check-named`, `check-value` …) stehen dagegen auf Dateiebene und
// sind damit auch über dieses Modul erreichbar.

#import "internal/check.typ": check-named, check-not-empty, check-positional, check-type, check-value, fail

// ─── Prüftabellen ────────────────────────────────────────────────────────────

/// Paketname für die Fehlermeldungen.
#let package = "klausurboegen"

/// Alte Parameternamen von `klausurbögen` (0.0.1 bis 0.0.5) und ihr neuer Name.
/// `weißer-rand` steht gefaltet als `weisser-rand`; `move` hieß `mv` in
/// `klausurboegen-settings` von klassenarbeit 0.0.8.
#let renamed-parameters = (
  "exam": "title",
  "subexam": "subtitle",
  "students": "results",
  "sek1": "stage",
  "result": "overprint",
  "rand": "correction-margin",
  "scale": "grid-size",
  "sub": "continuation",
  "numbering": "subtask-numbering",
  "mv": "offset",
  "move": "offset",
  "weisser-rand": "correction-margin-blank",
  "result-table": "points-table",
  "vorschlag": "proposal",
  "line-stroke": "correction-margin-stroke",
  "muster": "pattern",
  "linienabstand": "line-height",
  "korrekturrand": "correction-margin-side",
  "vordruck": "points-table-preprinted",
  "namen": "overprint-name",
)

/// Vorgaben aller benannten Parameter von `klausurboegen`.
#let parameter-defaults = (
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
)

/// Alle gültigen benannten Parameter von `klausurboegen`.
#let allowed-parameters = parameter-defaults.keys()

/// Anzahl der Zählzeichen eines Typst-Nummerierungsmusters.
///
/// - pattern (str): Muster, zum Beispiel `"a)"` oder `"1.1"`
/// -> int
#let counting-symbol-count(pattern) = {
  let symbols = "1aAiIαΑ*①⓵一壹あいアイא가ㄱ١۱१০ক"
  pattern.clusters().filter(cluster => cluster in symbols).len()
}

/// Der neue Name samt Wert für einen alten Parameter, dessen Wert sich mit
/// dem Namen geändert hat (`sek1: true` → `stage: "sek-1"`). `none`, wenn der
/// Wert unverändert bleibt; dann genügt die Meldung „heißt jetzt" mit dem Namen.
///
/// - name (str): alter Name, bereits gefaltet
/// - value (any): übergebener Wert
/// -> str, none
#let renamed-with-value(name, value) = {
  let in-cm(length) = str(calc.round(length.cm(), digits: 3)) + "cm"
  if name == "sek1" and type(value) == bool {
    if value { "stage: \"sek-1\"" } else { "stage: \"sek-2\"" }
  } else if name == "scale" and type(value) in (int, float) {
    "grid-size: " + in-cm(value * 0.5cm)
  } else if name == "vorschlag" and value == false {
    "proposal: none"
  } else if name == "vordruck" and (value == "werte" or type(value) == bool) {
    if value == "werte" { "points-table-preprinted: true" } else { "points-table-preprinted: false" }
  } else if name == "numbering" and value != "a)" {
    "subtask-numbering: \"1.1\""
  } else if name == "muster" and value in ("kariert", "liniert") {
    if value == "kariert" { "pattern: \"squares\"" } else { "pattern: \"lines\"" }
  } else if name == "korrekturrand" and value in ("aussen", "außen", "innen") {
    if value == "innen" { "correction-margin-side: \"inside\"" } else { "correction-margin-side: \"outside\"" }
  } else if name in ("exam", "subexam") and value == "" {
    renamed-parameters.at(name) + ": none"
  } else {
    none
  }
}

/// Prüft die Namen eines Aufrufs: alte Namen brechen mit „heißt jetzt" ab
/// (mit neuem Wert, wo sich auch der Wert geändert hat), unbekannte mit
/// Tippfehlervorschlag.
///
/// Bekannte Grenze: „alt und neu zugleich" wird nur erkannt, wenn der neue
/// Name in `named` steht oder in `values` einen anderen Wert als die Vorgabe
/// trägt. `klausurboegen(rand: 4cm, correction-margin: 5cm)` meldet deshalb
/// nur „`rand` heißt jetzt `correction-margin`": Ein ausdrücklich
/// geschriebener Vorgabewert ist in der Funktion nicht von einem
/// weggelassenen Parameter zu unterscheiden. Für Dictionaries (`values` leer,
/// alle Schlüssel in `named`) gilt die Grenze nicht.
///
/// - package-name (str): Paketname für die Meldung
/// - function (str): Funktionsname für die Meldung
/// - named (dictionary): benannte Argumente, die nicht deklariert sind (der Sink), oder ein ganzes Dictionary von Schlüsseln
/// - values (dictionary): deklarierte Parameter, neuer Name → übergebener Wert
/// - prefix (str): steht in der Meldung vor jedem Namen, zum Beispiel `"answer-sheets."`; die Meldung spricht dann von Schlüsseln
/// -> none
#let check-names(package-name, function, named, values: (:), prefix: "") = {
  // Neue Namen, die der Aufruf sichtbar gesetzt hat: So meldet `check-named`
  // „alt und neu zugleich", obwohl der neue Name nicht im Sink landet.
  let given = named
  for (name, value) in values {
    if name in parameter-defaults and value != parameter-defaults.at(name) { given.insert(name, value) }
  }
  for (key, value) in named {
    let folded = key.replace("ß", "ss").replace("ä", "ae").replace("ö", "oe").replace("ü", "ue")
    if folded in renamed-parameters and renamed-parameters.at(folded) not in given {
      let new = renamed-with-value(folded, value)
      if new != none {
        fail(
          package-name,
          function,
          "`" + prefix + key + ": " + repr(value) + "` heißt jetzt `" + prefix + new + "`",
        )
      }
    }
  }
  if prefix == "" {
    check-named(package-name, function, given, renamed: renamed-parameters, allowed: allowed-parameters)
  } else {
    let prefixed(names) = names.map(name => prefix + name)
    check-named(
      package-name,
      function,
      prefixed(given.keys()).zip(given.values()).to-dict(),
      renamed: prefixed(renamed-parameters.keys()).zip(prefixed(renamed-parameters.values())).to-dict(),
      allowed: prefixed(allowed-parameters),
      what: "Schlüssel",
    )
  }
}

/// Prüft Typen und Werte der Parameter von `klausurboegen`. Geprüft wird, was
/// im Dictionary steht; fehlende Namen werden übersprungen.
///
/// - package-name (str): Paketname für die Meldung
/// - function (str): Funktionsname für die Meldung
/// - values (dictionary): neuer Name → Wert
/// - prefix (str): steht in der Meldung vor dem Namen, zum Beispiel `"answer-sheets."`
/// -> none
#let check-values(package-name, function, values, prefix: "") = {
  let texts = (
    title: "kein Titel",
    subtitle: "kein Untertitel",
    teacher: "keine Lehrkraft",
    class: "keine Klasse",
    date: "kein Datum",
    proposal: "kein Vorschlag",
  )
  for (name, meaning) in texts {
    if name not in values { continue }
    let value = values.at(name)
    if name == "proposal" and value == false {
      fail(package-name, function, "`" + prefix + "proposal: false` – das Aus ist `none`")
    }
    check-not-empty(package-name, function, prefix + name, value, meaning)
    check-type(package-name, function, prefix + name, value, (content, str, none))
  }
  if "logo" in values {
    check-not-empty(package-name, function, prefix + "logo", values.logo, "kein Logo")
    check-type(
      package-name,
      function,
      prefix + "logo",
      values.logo,
      (content, str, auto, none),
      example: "image(\"logo.svg\")",
    )
  }
  if "results" in values {
    let results = values.results
    check-type(package-name, function, prefix + "results", results, array, example: "csv(\"ergebnisse.csv\")")
    for (index, row) in results.enumerate() {
      if type(row) != array or row.any(cell => type(cell) != str) {
        fail(
          package-name,
          function,
          "`"
            + prefix
            + "results` erwartet CSV-Zeilen (Arrays aus Text), bekam als "
            + str(index + 1)
            + ". Zeile `"
            + repr(row)
            + "` – Kopfzeile, Maximalpunkte und je Schüler eine Zeile (Name, Note, Punkte …) übergeben, zum Beispiel `csv(\"ergebnisse.csv\")`",
        )
      }
    }
  }
  for name in ("overprint", "overprint-name", "continuation", "points-table", "correction-margin-blank") {
    if name in values { check-type(package-name, function, prefix + name, values.at(name), bool) }
  }
  if "points-table-preprinted" in values {
    let value = values.points-table-preprinted
    if value == "werte" {
      fail(package-name, function, "`" + prefix + "points-table-preprinted: \"werte\"` heißt jetzt `true`")
    }
    check-type(package-name, function, prefix + "points-table-preprinted", value, bool)
  }
  if "stage" in values {
    check-value(
      package-name,
      function,
      prefix + "stage",
      values.stage,
      ("sek-1", "sek-2"),
      renamed: ("I": "sek-1", "II": "sek-2", "true": "sek-1", "false": "sek-2"),
    )
  }
  if "subtask-numbering" in values {
    let value = values.subtask-numbering
    check-type(package-name, function, prefix + "subtask-numbering", value, str, example: "\"a)\"")
    if value == "1." {
      fail(package-name, function, "`" + prefix + "subtask-numbering: \"1.\"` heißt jetzt `\"1.1\"`")
    }
    if counting-symbol-count(value) not in (1, 2) {
      fail(
        package-name,
        function,
        "`"
          + prefix
          + "subtask-numbering: "
          + repr(value)
          + "` ist kein gültiger Wert – ein Zählzeichen für die Teilnummer (`\"a)\"`) oder zwei für Aufgabe und Teil (`\"1.1\"`) schreiben",
      )
    }
  }
  if "pattern" in values {
    check-value(package-name, function, prefix + "pattern", values.pattern, ("squares", "lines"))
  }
  if "grid-size" in values {
    let value = values.grid-size
    check-type(
      package-name,
      function,
      prefix + "grid-size",
      value,
      length,
      // Früher ein Faktor (`scale`): Faktor mal 0,5 cm.
      example: if type(value) in (int, float) { str(calc.round(value * 0.5, digits: 3)) + "cm" } else { "0.5cm" },
    )
  }
  for name in ("line-height", "correction-margin") {
    if name in values { check-type(package-name, function, prefix + name, values.at(name), length) }
  }
  if "correction-margin-side" in values {
    check-value(
      package-name,
      function,
      prefix + "correction-margin-side",
      values.correction-margin-side,
      ("inside", "outside"),
      renamed: (innen: "inside", aussen: "outside"),
    )
  }
  if "correction-margin-stroke" in values {
    check-type(
      package-name,
      function,
      prefix + "correction-margin-stroke",
      values.correction-margin-stroke,
      (stroke, length, color, gradient, tiling, dictionary),
      example: "1pt + red",
    )
  }
  if "offset" in values {
    let value = values.offset
    check-type(package-name, function, prefix + "offset", value, dictionary, example: "(dx: 1mm, dy: -2mm)")
    for (key, amount) in value {
      check-named(
        package-name,
        function,
        ((prefix + "offset." + key): amount),
        allowed: (prefix + "offset.dx", prefix + "offset.dy"),
        what: "Schlüssel",
      )
      // `move` nimmt auch Anteile (`50%`); die Meldung nennt die übliche Form.
      if type(amount) not in (length, relative, ratio) {
        check-type(package-name, function, prefix + "offset." + key, amount, length)
      }
    }
  }
}

// ─── Kopf des Bogens ─────────────────────────────────────────────────────────
//
// Kopf und Namenszeile stehen hier einmal, damit der leere Bogen
// (`klausurboegen`) und die Arbeit auf dem Bogen (`answer-sheet-pages`)
// dieselbe Geometrie haben. Nur so trifft der Ergebnisdruck (`overprint: true`)
// auch auf eine Arbeit, die direkt auf den Bogen gedruckt wurde.

/// Löst `logo` auf: `auto` ist das Schullogo des Pakets.
///
/// - logo (content, str, auto, none): Logo
/// -> content, str, none
#let resolve-logo(logo) = if logo == auto { image("../logo.svg") } else { logo }

/// Kopfzeile des Bogens: Logo, Titel und Untertitel, Datum, Klasse und Lehrkraft.
///
/// - title (content, str, none): Titel
/// - subtitle (content, str, none): Untertitel (erscheint nur mit Logo)
/// - class (content, str, none): Klasse
/// - date (content, str, none): Datum
/// - teacher (content, str, none): Lehrkraft
/// - logo (content, str, none): Logo; `none`: keins
/// - overprint (bool): Ergebnisdruck; die Trennlinie ist dann weiß
/// -> content
#let sheet-header(
  title: none,
  subtitle: none,
  class: none,
  date: none,
  teacher: none,
  logo: none,
  overprint: false,
) = {
  set text(font: "Myriad Pro", hyphenate: true, lang: "de")
  // Ein fehlender Text wird als leerer Text gesetzt, nicht als nichts: Eine
  // leere Zeile hat eine Höhe, und der Kopf soll ohne Untertitel genauso hoch
  // sein wie bisher mit `subexam: ""`.
  let text-or-empty(value) = if value == none { "" } else { value }
  let (title, subtitle, class, date, teacher) = (title, subtitle, class, date, teacher).map(text-or-empty)
  grid(
    columns: (2.5cm, 1fr, 2.5cm),
    align: center + horizon,
    stroke: none,
    inset: 3pt,
    ..if logo != none {
      (
        grid.cell(rowspan: 2, align: left + horizon, inset: 0pt)[#text(16pt, weight: "semibold")[#box(height: 1cm)[#logo]]],
        grid.cell(rowspan: 2)[#stack(spacing: 2mm, text(16pt, weight: "semibold")[#title], text(
          12pt,
          weight: "regular",
        )[#subtitle])],
        grid.cell(align: right + horizon)[#date],
        grid.cell(align: right + horizon)[#class - #teacher],
      )
    } else {
      (
        [],
        grid.cell(rowspan: 2)[#text(16pt, weight: "semibold")[#title]],
        grid.cell(align: right + horizon)[#date],
        [],
        grid.cell(align: right + horizon)[#class - #teacher],
      )
    },
  )

  if overprint {
    move(dy: -1em, line(length: 100%, stroke: 0.5pt + white))
  } else {
    move(dy: -1em, line(length: 100%, stroke: 0.5pt + luma(200)))
  }
}

/// Namenszeile unter dem Kopf: „Name:", „Ergebnis:" oder der Vorschlag, beim
/// Ergebnisdruck die Note.
///
/// - overprint (bool): Ergebnisdruck
/// - continuation (bool): Folgebogen ohne Ergebnisbereich
/// - proposal (content, str, none): Beschriftung des Vorschlags auf dem Folgebogen
/// - grade-content (content): Note für den Ergebnisdruck
/// - name (content, str, none): Schülername, klein über „Name:" (nur Ergebnisdruck)
/// -> content
#let name-line(overprint: false, continuation: false, proposal: none, grade-content: [], name: none) = box(
  inset: (top: -1mm),
)[
  #table(
    inset: (top: 0pt, left: 0pt, right: 0pt, bottom: 3mm),
    stroke: none,
    columns: (auto, 1fr, auto, 1fr),
    align: (left, left, left, center),
    [#if not overprint [#text(14pt, weight: "semibold")[Name:]] else if name != none {
        // Der Name steht ganz klein und grau über dem vorgedruckten „Name:", nicht
        // auf der Schreiblinie, damit er den handschriftlichen Namen nicht
        // überdruckt. Mit `place`, damit Note und Tabelle nicht verrutschen.
        place(dy: -3.5mm, box(width: 100mm, text(7pt, fill: luma(40%))[#name]))
      }],
    ..if not overprint {
      ([],)
    },
    [#text(14pt, weight: "semibold")[
      #if not continuation [#if not overprint [Ergebnis:]] else if proposal != none [#if not overprint [#h(1fr)#proposal:]#h(2cm)]
    ]],
    if not overprint {
      table.hline(stroke: 0.5pt + gray)
    },
    [#if overprint and not continuation [#grade-content] ],
  )
]

/// Der Kopfbereich von Seite 1: Kopf, Namenszeile, Punktetabelle,
/// Notenschlüssel. Derselbe Aufbau für den leeren Bogen, den Ergebnisdruck und
/// die Arbeit auf dem Bogen; so liegen Tabelle und Note bei allen an derselben
/// Stelle.
///
/// - header (content): Kopfzeile
/// - name-line-content (content): Namenszeile
/// - points-content (content): Punktetabelle
/// - grade-table (content): Notenschlüssel
/// - continuation (bool): Folgebogen; der Notenschlüssel entfällt
/// - height (length, auto): Höhe des Kopfbereichs
/// -> content
#let header-box(
  header: [],
  name-line-content: [],
  points-content: [],
  grade-table: [],
  continuation: false,
  height: auto,
) = box(
  inset: (top: 7mm, left: 4mm, right: 10mm),
  height: height,
  [
    #header
    #name-line-content
    #points-content
    #if not continuation [
      #grade-table
    ]
  ],
)

/// Höhe des Kopfbereichs auf Seite 1.
///
/// - continuation (bool): Folgebogen ohne Ergebnisbereich
/// - points-table (bool): Platz für die Punktetabelle (wirkt nur mit `continuation`)
/// -> length
#let header-height(continuation: false, points-table: true) = if continuation and points-table {
  6cm
} else if continuation {
  3cm
} else {
  8cm
}

// ─── Tabellen und Note des Ergebnisdrucks ────────────────────────────────────

/// Notenschlüssel als Tabelle (nur beim Ergebnisdruck sichtbar).
///
/// - max-points (int, float): erreichbare Punkte
/// - stage (str): `"sek-1"` (Noten 1 bis 6) oder `"sek-2"` (15 bis 0 Punkte)
/// - overprint (bool): Ergebnisdruck
/// - offset (dictionary): Verschiebung `(dx:, dy:)`
/// -> content
#let grade-boundaries(max-points: 100, stage: "sek-2", overprint: false, offset: (dx: 0cm, dy: 0cm)) = {
  let print-color = if overprint { black } else { white }
  let borders-sek-1 = (0.875, 0.75, 0.625, 0.5, 0.2, 0)
  let borders-sek-2 = (0.95, 0.90, 0.85, 0.80, 0.75, 0.70, 0.65, 0.60, 0.55, 0.50, 0.45, 0.40, 0.33, 0.27, 0.20, 0)
  let regions = ()
  let last-lower-bound = 0
  let borders = ()
  let grades = ()

  if stage == "sek-1" {
    borders = borders-sek-1
    grades = range(1, 7).map(x => [*#x*])
  } else {
    borders = borders-sek-2
    grades = range(0, 16).map(x => [*#x*]).rev()
  }

  let separation-lines = ()

  for (index, value) in borders.enumerate() {
    let calculated-border = value * max-points
    let rounded-border = calc.round(2 * value * max-points, digits: 0) / 2

    if (rounded-border < calculated-border) {
      rounded-border += 0.5
    }

    let upper-bound
    let lower-bound

    if (index == 0) {
      upper-bound = max-points
    } else {
      upper-bound = last-lower-bound - 0.5
    }

    lower-bound = rounded-border
    last-lower-bound = lower-bound

    if stage == "sek-1" {
      regions.push(text(fill: black, (str(upper-bound) + " - " + str(lower-bound)).replace(".", ",")))
    } else {
      regions.push(text(fill: black, size: 9pt, par(leading: 0.6em, [#str(lower-bound).replace(".", ",")])))
      separation-lines = (1, 4, 7, 10, 13, 16).map(x => grid.vline(
        x: x,
        stroke: if overprint {
          black.lighten(50%)
        } else {
          white
        }
          + 2pt,
      ))
    }
  }

  set text(9pt)
  if overprint {
    let boundaries = grid(
      columns: (auto,) + (1fr,) * borders.len(),
      inset: 6pt,
      stroke: print-color + 1pt,
      align: center + horizon,
      ..separation-lines,
      [*Note*],
      ..grades,
      [#if stage == "sek-1" [*Punktegrenzen*] else [*Punktegrenze $>=$*] ],
      ..regions,
    )
    move(
      ..offset,
      // `grid` verlängert jede Linie an beiden Enden um ihre halbe Dicke; die
      // 2 pt dicken Trennlinien stünden damit oben und unten 0,5 pt über den
      // 1 pt dicken Rahmen hinaus. Abgeschnitten wird oben und unten an dessen
      // Außenkante; links und rechts bleibt Luft, dort steht nichts über.
      if separation-lines.len() > 0 { block(clip: true, outset: (x: 2pt, y: 0.5pt), boundaries) } else { boundaries },
    )
  }
}

/// Prozentsatz und Note in Rot, für die Namenszeile des Ergebnisdrucks.
///
/// - percentage (float): Anteil der erreichten Punkte, 0 bis 1
/// - grade (str): Note (Sek I: `"1"` bis `"6"`) oder Notenpunkte
/// - stage (str): `"sek-1"` oder `"sek-2"`
/// - continuation (bool): Folgebogen; dort steht keine Note
/// - offset (dictionary): Verschiebung `(dx:, dy:)`
/// -> content
#let grade-display(
  percentage: 0.9462,
  grade: "6",
  stage: "sek-2",
  continuation: false,
  offset: (dx: 0cm, dy: 0cm),
) = {
  if not continuation {
    let fineliner-red = rgb("E90817")

    let grade-text
    if stage == "sek-1" {
      let words = ("sehr gut", "gut", "befriedigend", "ausreichend", "mangelhaft", "ungenügend")
      grade-text = words.at(int(grade) - 1)
    } else {
      grade-text = grade
      if (int(grade) == 1) {
        grade-text += [ Punkt]
      } else {
        grade-text += [ Punkte]
      }
    }

    let percent = calc.round(percentage * 100, digits: 2)
    let percent-text = str(percent).replace(".", ",")
    let decimals = percent-text.split(",")
    if (decimals.len() == 1) {
      percent-text += ",00"
    } else {
      if (decimals.at(1).len() == 1) {
        percent-text += "0"
      }
    }
    move(..offset, text(14pt, fineliner-red, weight: "bold")[#percent-text % #h(2mm) $eq.est$ #h(2mm) #grade-text])
  }
}

/// Beschriftung einer Teilaufgabe in der Punktetabelle. Vom Muster zählt nur
/// der Teil für die Teilaufgabe: `"a)"` → „b)", `"1.1"` → „2". In der Sek I
/// stehen immer Buchstaben.
///
/// - pattern (str): `subtask-numbering`
/// - index (int): Teilaufgabe, ab 0
/// - stage (str): `"sek-1"` oder `"sek-2"`
/// -> str
#let subtask-label(pattern, index, stage) = {
  if stage == "sek-1" { return numbering("a)", index + 1) }
  let symbols = "1aAiIαΑ*①⓵一壹あいアイא가ㄱ١۱१০ক"
  let clusters = pattern.clusters()
  let positions = range(clusters.len()).filter(position => clusters.at(position) in symbols)
  let part = if positions.len() >= 2 { clusters.slice(positions.at(1)).join() } else { pattern }
  numbering(part, index + 1)
}

/// Punktetabelle des Ergebnisdrucks.
///
/// `part: "all"` druckt die ganze Tabelle (gewöhnlicher Ergebnisdruck),
/// `"frame"` nur Linien, Köpfe und mögliche Punkte (Vordruck auf der Arbeit),
/// `"values"` nur die erreichten Punkte und ihre Summe (Ergebnisdruck auf
/// einen Bogen mit Vordruck). Ausgeblendetes wird mit `hide` gesetzt, damit
/// die Tabelle in allen drei Fällen genau gleich groß ist.
///
/// - columns (dictionary): Aufgabenname → Zahl der Teilaufgaben (0: keine)
/// - max-points (array): mögliche Punkte je Spalte
/// - achieved-points (array): erreichte Punkte je Spalte
/// - overprint (bool): Ergebnisdruck; ohne ihn entsteht nichts
/// - stage (str): `"sek-1"` oder `"sek-2"`
/// - subtask-numbering (str): Muster für die Teilaufgaben
/// - offset (dictionary): Verschiebung `(dx:, dy:)`
/// - part (str): `"all"`, `"frame"` oder `"values"`
/// -> content
#let points-table-content(
  columns: (:),
  max-points: (),
  achieved-points: (),
  overprint: false,
  stage: "sek-2",
  subtask-numbering: "a)",
  offset: (dx: 0cm, dy: 0cm),
  part: "all",
) = {
  check-value(
    package,
    "internal.points-table-content",
    "part",
    part,
    ("all", "frame", "values"),
    renamed: (alles: "all", rahmen: "frame", werte: "values"),
  )
  let print-color = if overprint and part != "values" { black } else { white }
  let framed(x) = if part == "values" { hide(x) } else { x }
  let valued(x) = if part == "frame" { hide(x) } else { x }
  let header-row = ()
  let subtask-row = ()
  let column-count = 0

  let has-subtasks = columns.values().filter(x => x != 0).len() > 0
  for (key, count) in columns {
    if (count > 1) {
      header-row.push(grid.cell(colspan: count)[#framed[*#key*]])
      for subtask in range(0, count) {
        subtask-row.push(subtask-label(subtask-numbering, subtask, stage))
      }
    } else {
      if has-subtasks {
        header-row.push(grid.cell(rowspan: 2)[#framed[*#key*]])
      } else {
        header-row.push(framed[*#key*])
      }
    }

    if (count == 0) {
      column-count += 1
    }
    column-count += count
  }
  let number-cell(x, wrap) = grid.cell(inset: 0mm, wrap(text(size: 10pt, fill: black, str(x).replace(".", ","))))
  if overprint {
    if not has-subtasks {
      move(
        ..offset,
        grid(
          columns: (auto,) + (1fr,) * (column-count + 1),
          inset: 6pt,
          stroke: print-color + 1pt,
          align: horizon + center,
          framed[*Aufgabe*],
          ..header-row,
          framed[$sum$],
          ..subtask-row.map(x => framed[*#x*]),
          framed(text(size: 8pt, [*mögliche Punkte*])),
          ..max-points.map(x => number-cell(x, framed)),
          number-cell(max-points.sum(), framed),
          framed(text(size: 8pt, [*erreichte Punkte*])),
          ..achieved-points.map(x => number-cell(x, valued)),
          number-cell(achieved-points.sum(), valued),
        ),
      )
    } else {
      move(
        ..offset,
        grid(
          columns: (auto,) + (1fr,) * (column-count + 1),
          inset: 6pt,
          stroke: print-color + 1pt,
          align: horizon + center,
          // Die Summenspalte ist getönt.
          fill: (x, _) => if x > column-count { print-color.lighten(90%) },
          grid.cell(rowspan: 2)[#framed[*Aufgabe*]],
          ..header-row,
          grid.cell(rowspan: 2)[#framed[$sum$]],
          ..subtask-row.map(x => framed[*#x*]),
          framed(text(size: 8pt, [*mögliche Punkte*])),
          ..max-points.map(x => number-cell(x, framed)),
          number-cell(max-points.sum(), framed),
          framed(text(size: 8pt, [*erreichte Punkte*])),
          ..achieved-points.map(x => number-cell(x, valued)),
          number-cell(achieved-points.sum(), valued),
        ),
      )
    }
  }
}

// ─── Seitenlayout des Bogens ─────────────────────────────────────────────────
//
// Seiten des gefalteten Bogens: links außen 4, rechts außen 1 (Vorderseite),
// innen links 2, innen rechts 3. Die Falz liegt bei 1 und 3 links, bei 2 und 4
// rechts.

/// Liegt die Falz bei dieser Seite links?
///
/// - page-number (int): Seite des gefalteten Bogens, 1 bis 4
/// -> bool
#let is-fold-left(page-number) = page-number in (1, 3)

/// Liegt der Korrekturrand bei dieser Seite links?
///
/// - page-number (int): Seite des gefalteten Bogens, 1 bis 4
/// - side (str): `"inside"` (an der Falz) oder `"outside"` (am Blattrand)
/// -> bool
#let is-margin-left(page-number, side: "outside") = if side == "inside" {
  is-fold-left(page-number)
} else {
  not is-fold-left(page-number)
}

/// Schreibfeld einer Seite, an der Falz ausgerichtet.
///
/// - page-number (int): Seite des gefalteten Bogens, 1 bis 4
/// - height (length): Höhe des Felds
/// - pattern (str): `"squares"` oder `"lines"`
/// - grid-size (length): Kantenlänge eines Kästchens
/// - line-height (length): Zeilenabstand der Linierung
/// -> content
#let writing-area(page-number, height, pattern: "squares", grid-size: 0.5cm, line-height: 8mm) = place(
  top + if is-fold-left(page-number) { left } else { right },
  if pattern == "lines" {
    // Bewusste Abweichung von konvention.md („`klausurboegen` benutzt
    // `liniert` und `kariert` statt eines Nachbaus"): gleiches PDF geht vor.
    // Nicht `patterns.liniert`: Dessen Linien liegen anders (halbe Zeile
    // Vorschub, Abstand darunter); der Bogen soll aussehen wie in 0.0.5.
    let count = calc.floor((height - 1cm) / line-height)
    box(width: 100%, height: height, for index in range(1, count + 1) {
      place(top + left, dy: index * line-height, line(length: 100%, stroke: 0.5pt + luma(150)))
    })
  } else {
    import "@schule/patterns:0.5.0": kariert
    kariert(height: height + 0.3cm, grid-size: grid-size)
  },
)

/// Eine Hälfte des A3-Bogens: Schreibfeld ab `top`, Korrekturrand, Seitenzahl.
///
/// - page-number (int): Seite des gefalteten Bogens, 1 bis 4
/// - settings (dictionary): alle Parameter von `klausurboegen`
/// - overprint (bool): Ergebnisdruck; Schreibfeld und Rand entfallen
/// - top (length): Beginn des Schreibfelds unter dem Kopfbereich
/// - header (content, none): Kopfbereich (nur Seite 1)
/// - number (bool): Seitenzahl setzen (nur mit Titel)
/// -> content
#let half-page(page-number, settings, overprint: false, top: 0cm, header: none, number: true) = block(
  width: 100%,
  height: 100%,
  {
    let inset-page-number = 6mm
    // Ohne weißen Rand läuft das Muster durch, eine Linie markiert den Rand.
    let margin = if settings.correction-margin-blank { settings.correction-margin } else { 0cm }
    let margin-left = is-margin-left(page-number, side: settings.correction-margin-side)
    let area = writing-area(
      page-number,
      29.7cm - top,
      pattern: settings.pattern,
      grid-size: settings.grid-size,
      line-height: settings.line-height,
    )
    header
    if not overprint {
      place(std.top + left, dy: top, grid(
        columns: if margin-left { (margin, 1fr) } else { (1fr, margin) },
        rows: 29.7cm - top,
        ..if margin-left { ([], area) } else { (area, []) },
      ))
      if not settings.correction-margin-blank {
        let x = if margin-left { settings.correction-margin } else { 21cm - settings.correction-margin }
        place(std.top + left, line(stroke: settings.correction-margin-stroke, start: (x, top), end: (x, 100%)))
      }
    }
    if number and settings.title != none {
      place(
        bottom + if is-fold-left(page-number) { right } else { left },
        box(inset: inset-page-number, box(fill: white, text(size: 16pt, [*#page-number*]))),
      )
    }
  },
)

/// Ein ganzer Bogen: Außenseite (Seiten 4 und 1) und, außer beim
/// Ergebnisdruck, Innenseite (Seiten 2 und 3).
///
/// - settings (dictionary): alle Parameter von `klausurboegen`
/// - overprint (bool): Ergebnisdruck: nur Tabelle, Note und Notenschlüssel
/// - name (str): Schülername (für `overprint-name`)
/// - grade-content (content): Note für die Namenszeile
/// - points-content (content): Punktetabelle
/// - grade-table (content): Notenschlüssel
/// -> content
#let sheet(settings, overprint: false, name: "", grade-content: [], points-content: [], grade-table: []) = [
  #let height = header-height(continuation: settings.continuation, points-table: settings.points-table)

  #let header = if settings.title != none {
    let visible = sheet-header(
      title: settings.title,
      subtitle: settings.subtitle,
      date: settings.date,
      class: settings.class,
      teacher: settings.teacher,
      logo: resolve-logo(settings.logo),
      overprint: overprint,
    )
    header-box(
      height: height,
      continuation: settings.continuation,
      header: if overprint { hide(visible) } else { visible },
      name-line-content: name-line(
        overprint: overprint,
        continuation: settings.continuation,
        proposal: settings.proposal,
        grade-content: grade-content,
        name: if overprint and settings.overprint-name and name != "" { name } else { none },
      ),
      points-content: points-content,
      grade-table: grade-table,
    )
  }

  #grid(
    columns: (21cm, 21cm),
    rows: 1fr,
    half-page(4, settings, overprint: overprint, number: not overprint),
    half-page(
      1,
      settings,
      overprint: overprint,
      top: if settings.title != none { height + 5mm } else { 0cm },
      header: header,
      number: not overprint,
    ),
  )
  #if not overprint {
    grid(
      columns: (21cm, 21cm),
      rows: 1fr,
      half-page(2, settings), half-page(3, settings),
    )
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
// Satz zuerst und bekommt deshalb festen Inhalt (`back-page`); danach springt
// der Text in die rechte Spalte, also auf Seite 1, und läuft von dort über
// Seite 2 nach Seite 3. So stehen die Aufgaben in der richtigen Reihenfolge,
// und Nummerierung und Punktezählung stimmen. Aufgaben auf Seite 4 gehen
// deshalb nicht: Sie kämen im Satz vor Seite 2 und würden falsch gezählt.
//
// Oben auf Seite 1 steht der Kopfbereich des leeren Bogens. Die Punktetabelle
// darin ist dieselbe wie beim Ergebnisdruck und steht an genau derselben
// Stelle: Dafür wird der Kopfbereich zweimal übereinander gesetzt, einmal
// genau so, wie ihn der Ergebnisdruck aufbaut (Kopf und Note unsichtbar, von
// der Tabelle nur Linien, Köpfe und mögliche Punkte), und darüber der
// sichtbare Kopf mit der Namenszeile. Später druckt
// `klausurboegen(overprint: true)` die erreichten Punkte, die Note und den
// Notenschlüssel in die freien Stellen.
//
// Gedruckt wird A3 quer, beidseitig, Wenden an der kurzen Kante; dann einmal
// in der Mitte falten.

/// Seiteneinstellungen und Satzanfang für eine Arbeit auf dem Klausurbogen.
///
/// Gibt ein Dictionary zurück:
/// - `page`: Argumente für `set page(..)` (A3 quer, zwei Spalten, Kopfbereich
///   und Seitenzahlen im Hintergrund)
/// - `gutter`: Spaltenabstand für `set columns(gutter: ..)`, zweimal der
///   seitliche Rand, damit auch zur Falz hin so viel Platz bleibt
/// - `preamble`: Inhalt, der vor den Aufgaben stehen muss (Rückseite,
///   Spaltenwechsel, Platz für den Kopfbereich)
///
/// - title (content, str, none): Titel
/// - subtitle (content, str, none): Untertitel
/// - teacher (content, str, none): Lehrkraft
/// - class (content, str, none): Klasse
/// - date (content, str, none): Datum
/// - logo (content, str, auto, none): Logo; `auto`: das Schullogo
/// - stage (str): `"sek-1"` oder `"sek-2"`; bestimmt den Notenschlüssel
/// - continuation (bool): Folgebogen ohne Ergebnisbereich
/// - points-table (bool): Platz für die Punktetabelle (wirkt nur mit `continuation`)
/// - points-table-preprinted (bool): Linien, Köpfe und mögliche Punkte schon auf den Bogen drucken; muss beim späteren `klausurboegen(overprint: true)` gleich stehen
/// - proposal (content, str, none): Beschriftung des Vorschlags auf dem Folgebogen
/// - subtask-numbering (str): Muster für die Teilaufgaben der Punktetabelle
/// - offset (dictionary): Verschiebung `(dx:, dy:)` von Tabelle und Note
/// - task-points (array): Spalten der Punktetabelle als Paare `(name, points)` oder, mit Teilaufgaben, `(name, (points-a, points-b, …))`. Leer: der Platz bleibt frei
/// - back-page (content, str, auto): Inhalt von Seite 4. `auto`: „Platz für Nebenrechnungen". Keine nummerierten Aufgaben
/// - margin (length, dictionary): Seitenrand, eine Länge oder `(top:, bottom:, x:)`
/// - header-spacing (length): Abstand zwischen Kopfbereich und erster Aufgabe
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> dictionary
#let answer-sheet-pages(
  title: none,
  subtitle: none,
  teacher: none,
  class: none,
  date: none,
  logo: auto,
  stage: "sek-2",
  continuation: false,
  points-table: true,
  points-table-preprinted: false,
  proposal: none,
  subtask-numbering: "a)",
  offset: (dx: 0cm, dy: 0cm),
  task-points: (),
  back-page: auto,
  margin: (top: 12mm, bottom: 16mm, x: 12mm),
  header-spacing: 4mm,
  ..deprecated,
) = {
  let function = "internal.answer-sheet-pages"
  let rule = "der Seitenrand steht in `margin: (top:, bottom:, x:)`"
  check-positional(package, function, deprecated)
  check-named(
    package,
    function,
    deprecated,
    renamed: (
      "exam": "title",
      "subexam": "subtitle",
      "sek1": "stage",
      "sub": "continuation",
      "result-table": "points-table",
      "vorschlag": "proposal",
      "numbering": "subtask-numbering",
      "mv": "offset",
      "aufgaben": "task-points",
      "tabelle": "points-table-preprinted",
      "rueckseite": "back-page",
      "abstand": "header-spacing",
    ),
    removed: (rand: rule, unten: rule),
    allowed: (
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
    ),
  )
  check-values(package, function, (
    title: title,
    subtitle: subtitle,
    teacher: teacher,
    class: class,
    date: date,
    logo: logo,
    stage: stage,
    continuation: continuation,
    points-table: points-table,
    points-table-preprinted: points-table-preprinted,
    proposal: proposal,
    subtask-numbering: subtask-numbering,
    offset: offset,
  ))
  if task-points == none {
    fail(package, function, "`task-points: none` – weglassen, die Vorgabe ist `()`")
  }
  check-type(package, function, "task-points", task-points, array, example: "((\"1\", 4), (\"2\", (3, 3)))")
  for entry in task-points {
    if (
      type(entry) != array
        or entry.len() != 2
        or type(entry.at(1)) not in (int, float, array)
        or (type(entry.at(1)) == array and entry.at(1).any(points => type(points) not in (int, float)))
    ) {
      fail(
        package,
        function,
        "`task-points` erwartet Paare `(name, points)`, bekam `"
          + repr(entry)
          + "` – zum Beispiel `((\"1\", 4), (\"2\", (3, 3)))`",
      )
    }
  }
  check-type(package, function, "back-page", back-page, (content, str, auto))
  check-type(package, function, "margin", margin, (length, dictionary), example: "(top: 12mm, bottom: 16mm, x: 12mm)")
  if type(margin) == dictionary {
    // Das Paket rechnet mit den drei Werten (Spaltenabstand, Vorschub); andere
    // Schlüssel von Typst gibt es hier deshalb nicht.
    for (key, amount) in margin {
      check-named(
        package,
        function,
        (("margin." + key): amount),
        allowed: ("margin.top", "margin.bottom", "margin.x"),
        what: "Schlüssel",
      )
      check-type(package, function, "margin." + key, amount, length)
    }
  }
  check-type(package, function, "header-spacing", header-spacing, length)

  let margin = if type(margin) == length {
    (top: margin, bottom: margin, x: margin)
  } else {
    (top: 12mm, bottom: 16mm, x: 12mm) + margin
  }

  let height = header-height(continuation: continuation, points-table: points-table)
  let logo = resolve-logo(logo)

  // Punktetabelle und Notenschlüssel wie im Ergebnisdruck.
  // Leer auch im ersten Layoutdurchlauf, in dem ein Paket die Aufgaben noch
  // nicht gezählt hat; Typst setzt danach noch einmal mit den echten Werten.
  //
  // `points-table-preprinted: false` (Vorgabe): Auf dem Bogen steht nur eine
  // ganz feine, gestrichelte Box um den Platz von Tabelle und Notenschlüssel;
  // beides kommt erst mit dem Ergebnisdruck. Die Box nimmt keinen Platz ein
  // (`outset`), und zwischen Tabelle und Notenschlüssel liegt derselbe
  // Blockabstand wie im Ergebnisdruck; die Lage stimmt also auf den Millimeter.
  // `points-table-preprinted: true`: Linien, Köpfe und mögliche Punkte schon
  // auf dem Bogen.
  let (points-content, grade-table) = if task-points.len() == 0 { ([], []) } else {
    let columns = (:)
    // Eine Aufgabe ist (name, points) oder (name, (points je Teilaufgabe …)).
    // Mit Teilaufgaben bekommt die Tabelle eine zweite Kopfzeile und eine
    // Spalte je Teilaufgabe, so wie der Ergebnisdruck aus einer CSV mit
    // Teilaufgaben ("A1 a)" …) sie baut. Die Box wird dadurch passend größer.
    for (name, points) in task-points {
      columns.insert(str(name), if type(points) == array { points.len() } else { 0 })
    }
    let maximum = task-points.map(entry => entry.at(1)).flatten()
    let table-frame = points-table-content(
      columns: columns,
      max-points: maximum,
      achieved-points: maximum,
      overprint: true,
      stage: stage,
      subtask-numbering: subtask-numbering,
      offset: offset,
      part: "frame",
    )
    let boundaries = hide(grade-boundaries(max-points: maximum.sum(), stage: stage, overprint: true, offset: offset))
    if points-table-preprinted { (table-frame, boundaries) } else {
      (
        block(
          width: 100%,
          radius: 2mm,
          outset: (x: 2mm, y: 2mm),
          stroke: (paint: luma(60%), thickness: 0.6pt, dash: "dashed"),
          {
            hide(table-frame)
            boundaries
            // Der Hinweis steht genau in der Mitte der Box. Er ist so hell, dass
            // er unter dem späteren Ergebnisdruck nicht stört.
            place(center + horizon, text(size: 9pt, fill: luma(55%))[Bitte frei lassen])
          },
        ),
        [],
      )
    }
  }

  // Der Kopfbereich, wie ihn der Ergebnisdruck aufbaut.
  let as-overprint(box-height) = header-box(
    height: box-height,
    continuation: continuation,
    header: hide(sheet-header(
      title: title,
      subtitle: subtitle,
      date: date,
      class: class,
      teacher: teacher,
      logo: logo,
      overprint: true,
    )),
    name-line-content: name-line(
      overprint: true,
      continuation: continuation,
      proposal: proposal,
      grade-content: hide(grade-display(
        percentage: 1,
        grade: "1",
        stage: stage,
        continuation: continuation,
        offset: offset,
      )),
    ),
    points-content: points-content,
    grade-table: grade-table,
  )
  // Darüber der sichtbare Kopf mit Namenszeile, wie auf dem leeren Bogen.
  let visible = header-box(
    height: height,
    continuation: continuation,
    header: sheet-header(title: title, subtitle: subtitle, date: date, class: class, teacher: teacher, logo: logo),
    name-line-content: name-line(continuation: continuation, proposal: proposal),
  )

  // `page.width` ist die Breite des ungedrehten Papiers; bei `flipped` ist
  // die Breite des Bogens die Höhe.
  let sheet-width() = if page.flipped { page.height } else { page.width }

  let page-number(n) = box(inset: 6mm, box(fill: white, text(size: 16pt, font: "Myriad Pro", [*#n*])))

  // Der Bogen, auf dem wir sind, ist die physische Seite, unabhängig davon,
  // ob ein Paket den Seitenzähler zurücksetzt.
  let background = context {
    let sheet-number = here().page()
    let half = sheet-width() / 2
    if sheet-number == 1 {
      place(top + left, dx: half, box(width: half, as-overprint(height)))
      place(top + left, dx: half, box(width: half, visible))
      place(bottom + left, page-number(4))
      place(bottom + right, page-number(1))
    } else if sheet-number == 2 {
      place(bottom + left, page-number(2))
      place(bottom + right, page-number(3))
    } else {
      place(center + horizon, box(fill: white, inset: 8mm, text(
        fill: red,
        weight: "bold",
        size: 20pt,
      )[Die Arbeit passt nicht auf einen Klausurbogen: \
        Aufgaben dürfen nur auf den Seiten 1 bis 3 stehen.]))
    }
  }

  let preamble = {
    if back-page == auto {
      import "@schule/patterns:0.5.0": kariert
      text(size: 9pt, fill: luma(55%))[Platz für Nebenrechnungen]
      kariert(52)
    } else {
      back-page
    }
    colbreak()
    // Seite 1 beginnt unter dem Kopfbereich. Die 8 cm sind nötig: Darin druckt
    // der Ergebnisdruck unter die Tabelle den Notenschlüssel, der bis etwa
    // 75 mm reicht. Braucht die Tabelle mehr Platz, rückt der Anfang weiter
    // nach unten.
    context {
      let needed = measure(box(width: sheet-width() / 2, as-overprint(auto))).height
      v(calc.max(height, needed) - margin.top + header-spacing)
    }
  }

  (
    page: (
      paper: "a3",
      flipped: true,
      margin: (top: margin.top, bottom: margin.bottom, x: margin.x),
      columns: 2,
      header: none,
      footer: none,
      background: background,
    ),
    gutter: 2 * margin.x,
    preamble: preamble,
  )
}

/// Vorlage für eine Arbeit auf dem Klausurbogen, ohne weiteres Paket.
/// Dokumente erreichen sie über `klassenarbeit(answer-sheet-pages: …)`.
///
/// - ..args (arguments): alle Argumente wie bei `answer-sheet-pages`
/// - body (content): die Arbeit
/// -> content
#let exam-on-sheet(..args, body) = {
  let pages = answer-sheet-pages(..args)
  set page(..pages.page)
  set columns(gutter: pages.gutter)
  set text(12pt, font: "Myriad Pro", lang: "de")
  pages.preamble
  body
}
