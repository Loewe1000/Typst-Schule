// operatoren – die beiden öffentlichen Funktionen.
#import "internal/check.typ": fail, check-named, check-value, check-type, check-not-empty, check-positional, nearest, show-names
#import "internal.typ": used, settings, subjects, languages, overview-label, render-operator, label-name, normalize-language, csv-path, overview-title

/// Markiert einen Operator im Aufgabentext und merkt ihn für die
/// Operatorenliste vor.
///
/// `name` ist der Schlüssel der Operatorenliste, also der Infinitiv aus den
/// Fachanforderungen (`"berechnen"`, `"grafisch darstellen"`); Groß- und
/// Kleinschreibung spielen keine Rolle. Steht im Satz eine andere Form, kommt
/// sie nach `caption`. Enthält das Dokument eine `operatoren-liste`, führt der
/// Operator als Link zu seiner Zeile dort; ohne Operatorenliste steht nur der
/// Text.
///
/// ```typ
/// #operator("berechnen", caption: [Berechne]) die Geschwindigkeit.
/// ```
///
/// - name (str): Name des Operators, wie er in der Operatorenliste steht
/// - caption (content, str, none): abweichender Anzeigetext; `none` zeigt `name`
/// - bold (auto, bool): Fettdruck; `auto` übernimmt die Einstellung `bold`
///   der `operatoren-liste`
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> content
#let operator(name, caption: none, bold: auto, ..deprecated) = {
  check-positional("operatoren", "operator", deprecated,
    hint: "der Anzeigetext ist benannt – `operator(\"berechnen\", caption: [Berechne])` schreiben")
  // Gesetzte neue Parameter gehen mit in die Prüfung, damit „alt und neu
  // zugleich" gemeldet wird.
  check-named("operatoren", "operator",
    deprecated.named()
      + if caption != none { (caption: caption) }
      + if bold != auto { (bold: bold) },
    renamed: (text: "caption"),
    allowed: ("caption", "bold"))
  if type(name) == content {
    fail("operatoren", "operator", "`name` ist der Name aus der Operatorenliste und erwartet einen Text (`str`), bekam Inhalt – `operator(\"berechnen\", caption: [Berechne])` schreiben")
  }
  check-type("operatoren", "operator", "name", name, str, example: "\"berechnen\"")
  if name.trim() == "" {
    fail("operatoren", "operator", "`name` ist leer – den Namen aus der Operatorenliste angeben, zum Beispiel `\"berechnen\"`")
  }
  check-not-empty("operatoren", "operator", "caption", caption, "kein abweichender Anzeigetext")
  check-type("operatoren", "operator", "caption", caption, (content, str, none))
  check-value("operatoren", "operator", "bold", bold, (auto, true, false), renamed: ("none": auto))

  used.update(names => {
    names.push(name)
    names
  })
  context {
    let effective = if bold == auto { settings.final().at("bold", default: false) } else { bold }
    let shown = render-operator(if caption == none { name } else { caption }, bold: effective)
    let targets = query(label-name(name))
    // Die Leerzeichen um den Operator setzt das Paket seit 0.0.1 mit.
    [
      #if targets.len() > 0 { link(targets.first().location(), shown) } else { shown }
    ]
  }
}

/// Setzt die Operatorenliste: eine alphabetisch sortierte Tabelle der im
/// Dokument mit `operator` markierten Operatoren und ihrer Definitionen.
///
/// Die Definitionen bringt das Paket mit (`Mathe.csv`, `Physik.csv` und die
/// italienischen Fassungen `Mathe-it.csv`, `Physik-it.csv` im Paketordner);
/// eine eigene CSV-Datei aus dem Dokumentordner kann das Paket nicht lesen.
/// Ein Operator, der im gewählten Fach nicht vorkommt, ist ein Fehler.
///
/// `bold` gilt für alle `operator`-Aufrufe des Dokuments, auch für die vor
/// der Operatorenliste. Es lässt sich nur hier einstellen; ein einzelner
/// Operator weicht mit `operator(bold: …)` davon ab.
///
/// ```typ
/// #operatoren-liste(subject: "Physik")
/// ```
///
/// - subject (str): Fach: `"Mathe"` oder `"Physik"`
/// - language (str): Sprache der Definitionen und der Überschrift: `"de"` oder `"it"`
/// - bold (bool): alle Operatoren im Fließtext fett setzen
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> content
#let operatoren-liste(subject: "Mathe", language: "de", bold: false, ..deprecated) = {
  check-positional("operatoren", "operatoren-liste", deprecated,
    hint: "das Fach benannt schreiben – `operatoren-liste(subject: \"Physik\")`")
  // Von der Vorgabe abweichende neue Parameter gehen mit in die Prüfung, damit
  // „alt und neu zugleich" gemeldet wird.
  check-named("operatoren", "operatoren-liste",
    deprecated.named()
      + if subject != "Mathe" { (subject: subject) }
      + if language != "de" { (language: language) }
      + if bold != false { (bold: bold) },
    renamed: (fach: "subject", "operator-text-bold": "bold"),
    allowed: ("subject", "language", "bold"))
  check-type("operatoren", "operatoren-liste", "subject", subject, str, example: "\"Mathe\"")
  check-value("operatoren", "operatoren-liste", "subject", subject, subjects)
  check-type("operatoren", "operatoren-liste", "language", language, str, example: "\"de\"")
  let language = normalize-language(language)
  check-value("operatoren", "operatoren-liste", "language", language, languages)
  check-type("operatoren", "operatoren-liste", "bold", bold, bool)

  // Schlüssel in Kleinbuchstaben, weil auch die Namen aus `operator` so
  // verglichen werden (`Physik.csv` schreibt „Hypothesen aufstellen" groß).
  // `titles` behält die Schreibweise der CSV-Datei für die Anzeige.
  let definitions = (:)
  let titles = (:)
  for row in csv(csv-path(subject, language), delimiter: ";") {
    definitions.insert(lower(row.at(0)), row.at(1))
    titles.insert(lower(row.at(0)), row.at(0))
  }

  [
    #context {
      settings.update(_ => (bold: bold))
      context [
        #let names = used.final().map(lower).dedup().sorted()
        #for name in names {
          if name not in definitions {
            let hit = nearest(name, definitions.keys())
            fail("operatoren", "operatoren-liste", "unbekannter Operator `\"" + name + "\"` für `subject: \"" + subject + "\"` – " + if hit != none { "meintest du `\"" + titles.at(hit) + "\"`? " } + "erlaubt: " + show-names(titles.values().map(title => "\"" + title + "\"")))
          }
        }
        #heading(depth: 1, overview-title(language))#overview-label
        #set text(10pt, hyphenate: false)
        // Wie bisher mit tablex: Eine Zeile wird nicht über den Seitenumbruch
        // getrennt.
        #set table.cell(breakable: false)
        #table(
          columns: (auto, 1fr),
          stroke: 0.5pt,
          ..names.map(name => (
            [#render-operator(titles.at(name), bold: true)#label-name(name)],
            [#definitions.at(name)],
          )).flatten(),
        )
        #v(5mm)
      ]
    }
  ]
}
