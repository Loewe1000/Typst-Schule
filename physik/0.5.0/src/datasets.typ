// Datensätze und Messwerttabelle.
#import "@schule/random:0.0.1": rand
#import "internal/check.typ": fail, check-named, check-type, check-not-empty, show-value
#import "units.typ": check-prefix, prefix-factor, split-unit-prefix, convert-unit, apply-auto-prefix, render-measurement-table

// Altes `auto-einheit`: die Abhilfe hängt vom Wert und vom gesetzten `prefix`
// ab, deshalb vor `check-named` und nicht über `renamed`.
// `default` ist die alte Vorgabe der Funktion (datensatz: false, berechnung: true),
// `unset` sind die Werte von `prefix`, die als „nicht gesetzt" gelten.
#let check-auto-unit(function, deprecated, prefix, default: false, unset: ()) = {
  let named = deprecated.named()
  if "auto-einheit" not in named { return }
  let value = named.at("auto-einheit")
  if type(value) != bool { return }
  let shown = "`auto-einheit: " + repr(value) + "`"
  if prefix not in unset {
    fail("physik", function, shown + " gibt es nicht mehr – Argument löschen, das gesetzte `prefix` gilt")
  }
  if value == default {
    let now = if default { "`prefix: auto`" } else { "`prefix: none`" }
    fail("physik", function, shown + " gibt es nicht mehr – Argument löschen, " + now + " ist die Vorgabe")
  }
  fail("physik", function, shown + " heißt jetzt " + if value { "`prefix: auto`" } else { "`prefix: none`" })
}

/// Legt eine Messreihe an: eine Zeile der Messwerttabelle, zugleich Eingabe
/// für `berechnung`, die Regressionen und `graphen` aus mathematik.
///
/// Das Ergebnis ist ein Dictionary mit den Schlüsseln `name`, `unit`,
/// `prefix`, `values` und `digits`.
///
/// ```typ
/// #let t = datensatz((0, 1, 2, 3), name: "Zeit", unit: "s")
/// #let s = datensatz((0, 1.2, 4.8, 10.8), name: "Weg", unit: "m")
/// #messwerttabelle(t, s)
/// ```
///
/// - values (array): Messwerte als Zahlen; `none` oder Inhalt ergibt eine leere bzw. frei gesetzte Zelle
/// - name (str, content, none): Bezeichnung im Tabellenkopf
/// - unit (str, content, none): Einheit, zum Beispiel `"m/s"` oder `$Omega$`
/// - prefix (none, auto, str): SI-Vorsatz vor der Einheit: `none` = keiner, `auto` = das Paket wählt ihn passend zu den Werten, sonst `"k"`, `"m"`, `"u"` … oder eine Zehnerpotenz wie `"e14"`
/// - digits (auto, int): Nachkommastellen; `auto` übernimmt den Wert der Tabelle
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> dictionary
#let datensatz(values, name: none, unit: none, prefix: none, digits: auto, ..deprecated) = {
  if deprecated.pos().len() > 0 {
    fail(
      "physik",
      "datensatz",
      str(deprecated.pos().len() + 1)
        + " Positionsargumente, erlaubt ist eines – Name und Einheit benannt schreiben: `datensatz(values, name: …, unit: …)`",
    )
  }
  check-auto-unit("datensatz", deprecated, prefix, default: false, unset: (none, "1"))
  check-named(
    "physik",
    "datensatz",
    deprecated,
    renamed: ("max-digits": "digits", "auto-einheit": "prefix: auto", einheit: "unit", werte: "values"),
    allowed: ("name", "unit", "prefix", "digits"),
  )
  check-type("physik", "datensatz", "values", values, array, example: "datensatz((0, 1.5, 3), name: \"Zeit\", unit: \"s\")")
  check-type("physik", "datensatz", "name", name, (str, content, none))
  check-not-empty("physik", "datensatz", "name", name, "keine Bezeichnung")
  check-not-empty("physik", "datensatz", "unit", unit, "keine Einheit")
  check-type("physik", "datensatz", "unit", unit, (str, content, none), example: "\"m/s\"")
  check-prefix("datensatz", prefix, allowed: (none, auto), renamed: ("1": none))
  check-type("physik", "datensatz", "digits", digits, (int, auto))

  (
    name: name,
    unit: unit,
    prefix: prefix,
    values: values,
    digits: digits,
  )
}

/// Legt eine leere Messreihe an, in die Schülerinnen und Schüler ihre Werte
/// eintragen. Das Ergebnis hat dieselben Schlüssel wie bei `datensatz`.
///
/// ```typ
/// #messwerttabelle(
///   messdaten(5, name: "Zeit", unit: "s"),
///   messdaten(5, name: "Weg", unit: "m"),
/// )
/// ```
///
/// - count (int): Anzahl der leeren Zellen
/// - name (str, content, none): Bezeichnung im Tabellenkopf
/// - unit (str, content, none): Einheit
/// - prefix (none, str): SI-Vorsatz vor der Einheit; `none` = keiner
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> dictionary
#let messdaten(count, name: none, unit: none, prefix: none, ..deprecated) = {
  if deprecated.pos().len() > 0 {
    fail(
      "physik",
      "messdaten",
      str(deprecated.pos().len() + 1)
        + " Positionsargumente, erlaubt ist eines – Name und Einheit benannt schreiben: `messdaten(count, name: …, unit: …)`",
    )
  }
  check-named(
    "physik",
    "messdaten",
    deprecated,
    renamed: ("anzahl-messwerte": "count", einheit: "unit"),
    allowed: ("name", "unit", "prefix"),
  )
  check-type("physik", "messdaten", "count", count, int, example: "messdaten(5, name: \"Zeit\", unit: \"s\")")
  check-type("physik", "messdaten", "name", name, (str, content, none))
  check-not-empty("physik", "messdaten", "name", name, "keine Bezeichnung")
  check-not-empty("physik", "messdaten", "unit", unit, "keine Einheit")
  check-type("physik", "messdaten", "unit", unit, (str, content, none), example: "\"m/s\"")
  check-prefix("messdaten", prefix, allowed: (none,), renamed: ("1": none))

  (
    name: name,
    unit: unit,
    prefix: prefix,
    values: (count * ("",)),
    digits: auto,
  )
}

/// Berechnet eine Messreihe aus einer oder mehreren anderen.
///
/// Die Formel bekommt die Werte in Basiseinheiten (`"mA"` wird zu A, `"uC"`
/// zu C) und liefert den Wert in der Basiseinheit des Ergebnisses; erst danach
/// wird in die Zieleinheit umgerechnet. Eine Formel, die selbst mit `1e-6`
/// umrechnet, rechnet deshalb doppelt. Zusammengesetzte Einheiten mit `/`,
/// `^`, `·`, `²`, `³` bekommen keinen automatischen Vorsatz. Leere Zellen der
/// Eingabe ergeben leere Zellen im Ergebnis.
///
/// ```typ
/// #let t = datensatz((1, 2, 3, 4), name: "Zeit", unit: "s")
/// #let s = datensatz((2, 8, 18, 32), name: "Weg", unit: "m")
/// #let v = berechnung((s, t) => s / t, datasets: (s, t), name: "Tempo", unit: "m/s")
/// #messwerttabelle(t, s, v)
/// ```
///
/// - formula (function): Rechenvorschrift mit je einem Argument pro Datensatz, zum Beispiel `(s, t) => s / t`
/// - datasets (array): ein bis fünf Datensätze, deren Werte die Formel der Reihe nach bekommt
/// - name (str, content, none): Bezeichnung im Tabellenkopf
/// - unit (str, content, none): Zieleinheit der berechneten Werte
/// - prefix (auto, none, str): SI-Vorsatz der Zieleinheit: `auto` = das Paket wählt ihn passend zu den Werten, `none` = keiner, sonst `"k"`, `"m"`, `"u"` … oder `"e14"`
/// - error (ratio): zufälliger relativer Fehler, um Messwerte zu simulieren, zum Beispiel `5%`
/// - digits (auto, int): Nachkommastellen; `auto` übernimmt den Wert der Tabelle
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> dictionary
#let berechnung(
  formula,
  datasets: (),
  name: none,
  unit: none,
  prefix: auto,
  error: 0%,
  digits: auto,
  ..deprecated,
) = {
  if deprecated.pos().len() > 0 {
    fail(
      "physik",
      "berechnung",
      str(deprecated.pos().len() + 1)
        + " Positionsargumente, erlaubt ist eines – die Formel zuerst, alles andere benannt: `berechnung(formula, datasets: (…), name: …, unit: …)`",
    )
  }
  check-auto-unit("berechnung", deprecated, prefix, default: true, unset: (auto, "1"))
  check-named(
    "physik",
    "berechnung",
    deprecated,
    renamed: (
      fehler: "error",
      "max-digits": "digits",
      "auto-einheit": "prefix",
      einheit: "unit",
      datensaetze: "datasets",
      formel: "formula",
    ),
    allowed: ("datasets", "name", "unit", "prefix", "error", "digits"),
  )
  check-type(
    "physik",
    "berechnung",
    "formula",
    formula,
    function,
    example: "berechnung((s, t) => s / t, datasets: (s, t), name: \"Tempo\", unit: \"m/s\")",
  )
  if type(datasets) == dictionary {
    fail("physik", "berechnung", "`datasets` erwartet eine Liste, bekam einen einzelnen Datensatz – `datasets: (d,)` schreiben")
  }
  check-type("physik", "berechnung", "datasets", datasets, array, example: "(s, t)")
  if datasets.len() == 0 {
    fail("physik", "berechnung", "`datasets` ist leer – mindestens einen Datensatz angeben, zum Beispiel `datasets: (t,)`")
  }
  if datasets.len() > 5 {
    fail("physik", "berechnung", str(datasets.len()) + " Datensätze in `datasets`, erlaubt sind höchstens 5 – die Rechnung in zwei Schritte teilen")
  }
  for dataset in datasets {
    if type(dataset) != dictionary or "values" not in dataset {
      fail(
        "physik",
        "berechnung",
        "Eintrag `" + show-value(dataset) + "` in `datasets` ist kein Datensatz – Datensätze mit `datensatz`, `messdaten` oder `berechnung` anlegen",
      )
    }
  }
  check-type("physik", "berechnung", "name", name, (str, content, none))
  check-not-empty("physik", "berechnung", "name", name, "keine Bezeichnung")
  check-not-empty("physik", "berechnung", "unit", unit, "keine Einheit")
  check-type("physik", "berechnung", "unit", unit, (str, content, none), example: "\"m/s\"")
  check-prefix("berechnung", prefix, allowed: (auto, none), renamed: ("1": auto))
  check-type("physik", "berechnung", "error", error, ratio, example: "5%")
  check-type("physik", "berechnung", "digits", digits, (int, auto))

  // Zusammengesetzte Einheiten bekommen keinen automatischen Vorsatz.
  let compound = (
    type(unit) == str
      and (
        unit.contains("/") or unit.contains("·") or unit.contains("^") or unit.contains("²") or unit.contains("³")
      )
  )
  let auto-prefix = prefix == auto and not compound

  // Leere Zellen (zum Ausfüllen) und frei gesetzter Inhalt sind keine Zahlen.
  let is-blank(value) = value == none or value == "" or type(value) == content

  // Schritt 1: Eingabewerte in Basiseinheiten umrechnen
  let inputs = datasets.map(dataset => {
    let factor = prefix-factor(dataset.at("prefix", default: none)) * split-unit-prefix(dataset.at("unit", default: none)).at(0)
    dataset.values.map(value => if is-blank(value) { none } else { value * factor })
  })

  // Schritt 2: Formel anwenden; eine leere Zelle der Eingabe bleibt leer
  let results = ()
  for i in range(inputs.at(0).len()) {
    let arguments = inputs.map(values => values.at(i, default: none))
    if none in arguments {
      results.push(none)
    } else {
      results.push(formula(..arguments))
    }
  }

  // Schritt 3: Ergebnis in die Zieleinheit umrechnen
  let target-factor = prefix-factor(prefix) * split-unit-prefix(unit).at(0)
  results = results.map(value => if value == none { none } else { value / target-factor })

  // Schritt 4: zufälliger Fehler
  if error != 0% {
    for (key, value) in results.enumerate() {
      if value != none {
        results.at(key) = value * (1 + ((0.5 - rand(key)) * (error / 1%) / 100))
      }
    }
  }

  // Schritt 5: automatischer Vorsatz (ohne Einheit steht er allein, wie bisher)
  if auto-prefix {
    let smallest = none
    for value in results {
      if value == none or type(value) == content {
        continue
      }
      if calc.abs(value) != 0 {
        if smallest == none or calc.abs(value) < smallest {
          smallest = calc.abs(value)
        }
      }
    }

    if smallest != none {
      let (factor, new-unit) = convert-unit(smallest, if unit == none { "" } else { unit })
      if new-unit != none and new-unit != "" and factor != 1 {
        results = results.map(value => {
          if value == none or type(value) == content {
            return value
          }
          return value / factor
        })
        unit = new-unit
      }
    }
  }

  (
    name: name,
    unit: unit,
    // Ein automatisch gewählter Vorsatz steckt schon in `unit` und `values`.
    prefix: if prefix == auto { none } else { prefix },
    values: results,
    digits: digits,
  )
}

/// Setzt Datensätze als Messwerttabelle: je Datensatz eine Zeile, vorn die
/// Bezeichnung mit Einheit.
///
/// Hat ein Datensatz mehr Werte als `count`, wird die Tabelle in mehrere
/// Teiltabellen untereinander geteilt.
///
/// ```typ
/// #let t = datensatz((0, 1, 2, 3), name: "Zeit", unit: "s")
/// #let s = datensatz((0, 1.2, 4.8, 10.8), name: "Weg", unit: "m")
/// #messwerttabelle(t, s)
/// ```
///
/// - count (auto, int): höchstens so viele Wertespalten je Teiltabelle; `auto` = alle Werte in einer Tabelle
/// - row-height (auto, length): Zeilenhöhe
/// - header (none, array): Kopfzeile über den Wertespalten, je Spalte ein Eintrag
/// - width (relative, auto): Breite der Tabelle
/// - digits (int): Nachkommastellen für Datensätze ohne eigene Angabe
/// - ..args (arguments): die Datensätze als Positionsargumente (aus `datensatz`, `messdaten`, `berechnung`); benannte Argumente nimmt der Sink nicht an
/// -> content
#let messwerttabelle(count: auto, row-height: auto, header: none, width: 100%, digits: 2, ..args) = {
  check-named(
    "physik",
    "messwerttabelle",
    args,
    renamed: (amount: "count", "max-digits": "digits"),
    allowed: ("count", "row-height", "header", "width", "digits"),
  )
  let datasets = args.pos()
  if datasets.len() == 0 {
    fail("physik", "messwerttabelle", "kein Datensatz – mindestens einen übergeben, zum Beispiel `messwerttabelle(t, s)`")
  }
  for dataset in datasets {
    if type(dataset) == array {
      fail(
        "physik",
        "messwerttabelle",
        "Positionsargument ist eine Liste – Datensätze einzeln übergeben: `messwerttabelle(a, b)` oder `messwerttabelle(..liste)`",
      )
    }
    if type(dataset) == int {
      fail(
        "physik",
        "messwerttabelle",
        "Positionsargument `" + str(dataset) + "` ist kein Datensatz – die Spaltenzahl steht in `count: " + str(dataset) + "`",
      )
    }
    if type(dataset) != dictionary or "values" not in dataset {
      fail(
        "physik",
        "messwerttabelle",
        "Positionsargument `" + show-value(dataset) + "` ist kein Datensatz – Datensätze mit `datensatz`, `messdaten` oder `berechnung` anlegen",
      )
    }
  }
  check-type("physik", "messwerttabelle", "count", count, (int, auto))
  if count != auto and count < 1 {
    fail("physik", "messwerttabelle", "`count: " + str(count) + "` ist kleiner als 1 – mindestens eine Wertespalte je Teiltabelle, zum Beispiel `count: 5`")
  }
  check-type("physik", "messwerttabelle", "row-height", row-height, (length, auto, relative, ratio, fraction), example: "1cm")
  check-type("physik", "messwerttabelle", "header", header, (array, none), example: "([1], [2], [3])")
  check-type("physik", "messwerttabelle", "width", width, (ratio, length, relative, auto), example: "100%")
  check-type("physik", "messwerttabelle", "digits", digits, int)

  // Automatischen Vorsatz anwenden
  datasets = datasets.map(dataset => {
    if dataset.at("prefix", default: none) == auto {
      let (values, unit) = apply-auto-prefix(dataset.values, dataset.at("unit", default: none))
      dataset.values = values
      dataset.unit = unit
      dataset.prefix = none
    }
    dataset
  })

  // Alle Datensätze auf die Länge des längsten bringen
  let column-count = if count == auto { datasets.at(0).values.len() } else { count }
  let longest = calc.max(..datasets.map(dataset => dataset.values.len()))
  if longest == 0 {
    fail("physik", "messwerttabelle", "die Datensätze haben keine Werte – mindestens einen Wert angeben")
  }
  if column-count < 1 {
    fail("physik", "messwerttabelle", "der erste Datensatz hat keine Werte – ihm Werte geben oder die Spaltenzahl mit `count: 5` festlegen")
  }
  if header != none and header.len() > calc.min(column-count, longest) {
    fail(
      "physik",
      "messwerttabelle",
      "`header` hat " + str(header.len()) + " Einträge, die Tabelle aber nur " + str(calc.min(column-count, longest)) + " Wertespalten – überzählige Einträge entfernen",
    )
  }
  datasets = datasets.map(dataset => {
    while dataset.values.len() < longest {
      dataset.values.push(none)
    }
    dataset
  })

  // In Teiltabellen mit höchstens `column-count` Spalten zerlegen
  let part-count = calc.ceil(longest / column-count)
  for part in range(part-count) {
    let rows = datasets.map(dataset => {
      dataset.values = dataset.values.chunks(column-count).at(part)
      dataset
    })
    block(width: width, render-measurement-table(rows, row-height: row-height, header: header, digits: digits))
  }
}
