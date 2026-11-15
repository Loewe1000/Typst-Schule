// check.typ – gemeinsame Prüf- und Fehlermechanik der @schule-Pakete (ab 0.5.0)
//
// QUELLE: .github/namen/check.typ. Jedes Paket führt eine wortgleiche Kopie
// unter <paket>/0.5.0/src/internal/check.typ. Nie die Kopie ändern, sondern die
// Quelle, und danach neu kopieren; .github/scripts/check-sync.sh prüft die
// Gleichheit. Die Datei hat keine Importe und keinen State.
//
// Regeln dazu: plan-0.4/konvention.md, Abschnitt 8 (Fehlermeldungen) und 9
// (alte Namen). Jede Meldung hat die Form
//
//     <paket>.<funktion>: <was falsch ist> – <Abhilfe>
//
// API (alle Funktionen liefern `none` oder brechen mit `panic` ab):
//
//   fail(package, function, message)
//       Bricht ab mit "<package>.<function>: <message>". Einziger Ort für
//       `panic`. Für freie Meldungen (zweiter Weg, unzulässige Kombination).
//
//   check-named(package, function, named-args,
//               renamed: (:), removed: (:), allowed: (), what: "Parameter")
//       Für den Sink `..deprecated` und für Dictionaries. `named-args` ist ein
//       Dictionary oder ein `arguments`-Wert. Jeder Name, der nicht in
//       `allowed` steht, bricht ab:
//         renamed: (alt: "neu")      -> "`alt` heißt jetzt `neu`"
//                                       (auch `lösungen`, wenn `loesungen` drinsteht)
//         removed: (alt: "Hinweis")  -> "`alt` gibt es nicht mehr – Hinweis"
//         sonst                      -> "unbekannter Parameter `x` – meintest du `y`?"
//                                       oder "… – erlaubt: `a`, `b`"
//       `allowed` nennt alle gültigen Namen der Funktion (für den Vorschlag).
//       `what: "Schlüssel"` ändert das Wort in der Meldung (für Dictionaries).
//
//   check-value(package, function, name, value, allowed, renamed: (:))
//       Auswahl (Enum). `allowed` ist ein Array aus Werten (`none`, `auto`,
//       `"at-end"`, `true`) und Typen (`function`, `dictionary`).
//         renamed: (sofort: "in-place")                       -> "`solutions: "sofort"` heißt jetzt `"in-place"`"
//         renamed: (seite: (solutions: "at-end", solutions-pagebreak: "before"))
//                                                             -> "… heißt jetzt `solutions: "at-end", solutions-pagebreak: "before"`"
//         falsches Aus (`false`, `"none"`, `"false"`, `"keine"`, `""`)
//                                                             -> "`solutions: false` – das Aus ist `none`"
//         sonst -> "`points: "task"` ist kein gültiger Wert – meintest du `"tasks"`? erlaubt: …"
//       Ein deutscher Bausteinname als Wert (`"kariert"`) bekommt sein
//       Parameterwort (`"squares"`) als Vorschlag.
//
//   check-type(package, function, name, value, expected, example: none)
//       `expected` ist ein Typ oder ein Array aus Typen, `none` und `auto`.
//         -> "`gutter` erwartet eine Länge, bekam `2` (int) – zum Beispiel `2mm`"
//       Ist nur `bool` erlaubt und kommt `none`, `"false"` oder `""`:
//         -> "`print: none` – das Aus ist `false`"
//
//   check-not-empty(package, function, name, value, meaning)
//       Leerer Text. `meaning` ist die deutsche Bedeutung des Fehlens.
//         -> "`subtitle: ""` – für „kein Untertitel" `none` schreiben oder weglassen"
//
//   check-positional(package, function, positional-args, max: 0, min: 0, hint: none)
//       Überzählige (oder fehlende) Positionsargumente. `positional-args` ist
//       ein Array oder ein `arguments`-Wert.
//         -> "2 Positionsargumente, erlaubt ist höchstens 1 – <hint>"
//
//   stub(package, old, new)
//       Liefert eine Funktion für einen alten Funktionsnamen (src/removed.typ).
//       Jeder Aufruf bricht ab: "<package>.<old>: `old` heißt jetzt `new`".
//
// Vollständiges Beispiel für eine Funktion mit Sink (Paket `aufgaben`):
//
//   #import "internal/check.typ": fail, check-named, check-value, check-type, check-positional
//
//   /// Setzt eine Aufgabe.
//   ///
//   /// - title (content, none): Titel der Aufgabe
//   /// - method (str, none): Sozialform: `"individual"`, `"pair"`, `"group"`
//   /// - large (bool): große Überschrift
//   /// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
//   /// - body (content): Aufgabentext
//   /// -> content
//   #let aufgabe(title: none, method: none, large: true, ..deprecated, body) = {
//     // 1. Sink prüfen: zuerst Positionsargumente, dann Namen
//     check-positional("aufgaben", "aufgabe", deprecated,
//       hint: "Titel als zweites Inhaltsargument – `aufgabe(title: [...])[...]` schreiben")
//     check-named("aufgaben", "aufgabe", deprecated,
//       renamed: (titel: "title", sozialform: "method"),
//       removed: (farbe: "die Farbe bestimmt das Theme (`accent`)"),
//       allowed: ("title", "method", "large"))
//     // 2. Typen und Werte der deklarierten Parameter prüfen
//     check-type("aufgaben", "aufgabe", "title", title, (content, str, none))
//     check-type("aufgaben", "aufgabe", "large", large, bool)
//     check-value("aufgaben", "aufgabe", "method", method,
//       (none, "individual", "pair", "group"),
//       renamed: (EA: "individual", PA: "pair", GA: "group"))
//     // 3. Freie Meldungen über fail
//     if title == [] { fail("aufgaben", "aufgabe", "leerer Titel – `title` weglassen") }
//     // … eigentlicher Rumpf …
//     body
//   }
//
//   // src/removed.typ: alter Funktionsname als abbrechender Stub
//   #let lücke = stub("arbeitsblatt", "lücke", "luecke")
//
// So brechen dann ab:
//   #aufgabe(titel: [A])[…]               aufgaben.aufgabe: `titel` heißt jetzt `title`
//   #show: aufgabe.with(titel: [A])       dieselbe Meldung (der Sink fängt auch `.with`)
//   #aufgabe(titl: [A])[…]                aufgaben.aufgabe: unbekannter Parameter `titl` – meintest du `title`?
//   #aufgabe(method: "PA")[…]             aufgaben.aufgabe: `method: "PA"` heißt jetzt `"pair"`
//   #aufgabe[Titel][Rumpf]                aufgaben.aufgabe: 1 Positionsargument, erlaubt ist keines – Titel als …

// Parameterwörter der Bausteine (konvention.md 2.1b, wortgleich mit
// .github/namen/wortpaare.json). Für den Vorschlag bei deutschen Werten.
#let word-pairs = (
  "arbeitsblatt": ("worksheet",),
  "arbeitsblatt-einzeln": ("worksheet",),
  "klassenarbeit": ("exam",),
  "aufgabe": ("task", "tasks"),
  "teilaufgabe": ("subtask",),
  "teilaufgaben": ("subtasks",),
  "loesung": ("solution", "solutions"),
  "lsg": ("inline",),
  "erwartung": ("expectation", "expectations"),
  "luecke": ("blank",),
  "kariert": ("squares",),
  "liniert": ("lines",),
  "klausurboegen": ("answer-sheets",),
  "datensatz": ("dataset", "datasets"),
  "konstante": ("constant", "constants"),
)

/// Bricht mit einer Meldung im festen Format `<paket>.<funktion>: <meldung>` ab.
///
/// - package (str): Paketname, zum Beispiel `"aufgaben"`
/// - function (str): Funktionsname, zum Beispiel `"teilaufgabe"`
/// - message (str): Befund und Abhilfe, getrennt durch ` – `
/// -> none
#let fail(package, function, message) = panic(package + "." + function + ": " + message)

/// Faltet einen Namen für den Vergleich: Kleinbuchstaben, `ä ö ü ß` zu
/// `ae oe ue ss`, Unterstrich zu Bindestrich.
///
/// - name (str): Name oder Wert
/// -> str
#let fold-name(name) = {
  lower(name)
    .replace("ä", "ae")
    .replace("ö", "oe")
    .replace("ü", "ue")
    .replace("ß", "ss")
    .replace("_", "-")
}

/// Levenshtein-Abstand zweier Zeichenketten.
///
/// - first (str): erste Zeichenkette
/// - second (str): zweite Zeichenkette
/// -> int
#let edit-distance(first, second) = {
  let a = first.clusters()
  let b = second.clusters()
  let previous = range(b.len() + 1)
  for (i, ca) in a.enumerate() {
    let current = (i + 1,)
    for (j, cb) in b.enumerate() {
      current.push(calc.min(
        previous.at(j + 1) + 1,
        current.at(j) + 1,
        previous.at(j) + if ca == cb { 0 } else { 1 },
      ))
    }
    previous = current
  }
  previous.last()
}

/// Sucht den nächsten Namen. Der Abstand darf höchstens `max(2, Länge / 3)`
/// sein und muss kleiner sein als die Länge des Namens.
///
/// - name (str): der geschriebene Name
/// - candidates (array): Namen, unter denen gesucht wird
/// -> str, none
#let nearest(name, candidates) = {
  let folded = fold-name(name)
  let length = folded.clusters().len()
  let limit = calc.max(2, calc.floor(length / 3))
  let best = none
  let best-distance = limit + 1
  for candidate in candidates {
    if type(candidate) != str { continue }
    let distance = edit-distance(folded, fold-name(candidate))
    if distance < best-distance and distance < length {
      best = candidate
      best-distance = distance
    }
  }
  best
}

/// Schreibt einen Wert so, wie er im Dokument steht (gekürzt).
///
/// - value (any): beliebiger Wert
/// -> str
#let show-value(value) = {
  let text = repr(value).clusters()
  if text.len() > 40 { text.slice(0, 39).join() + "…" } else { text.join() }
}

/// Schreibt eine Liste von Namen in Backticks.
///
/// - names (array): Namen
/// -> str
#let show-names(names) = names.map(n => "`" + n + "`").join(", ")

/// Prüft benannte Argumente aus einem Sink oder die Schlüssel eines
/// Dictionary. Alte Namen brechen mit „heißt jetzt" ab, entfernte mit einem
/// Hinweis, unbekannte mit einem Tippfehlervorschlag.
///
/// - package (str): Paketname
/// - function (str): Funktionsname
/// - named-args (dictionary, arguments): die zu prüfenden benannten Argumente
/// - renamed (dictionary): alter Name → neuer Name
/// - removed (dictionary): alter Name → Hinweistext (die Abhilfe)
/// - allowed (array): alle gültigen Namen; was hier steht, wird angenommen
/// - what (str): Wort in der Meldung, `"Parameter"` oder `"Schlüssel"`
/// -> none
#let check-named(
  package,
  function,
  named-args,
  renamed: (:),
  removed: (:),
  allowed: (),
  what: "Parameter",
) = {
  let given = if type(named-args) == arguments { named-args.named() } else { named-args }
  for key in given.keys() {
    if key in allowed { continue }
    let folded = fold-name(key)
    let old = if key in renamed { key } else if folded in renamed { folded } else { none }
    if old != none {
      let new = renamed.at(old)
      if new in given {
        fail(package, function, "`" + key + "` (alt) und `" + new + "` (neu) zugleich – nur `" + new + "` schreiben")
      }
      fail(package, function, "`" + key + "` heißt jetzt `" + new + "`")
    }
    let gone = if key in removed { key } else if folded in removed { folded } else { none }
    if gone != none {
      fail(package, function, "`" + key + "` gibt es nicht mehr – " + removed.at(gone))
    }
    let hit = nearest(key, allowed + renamed.keys())
    if hit != none and hit in renamed and hit not in allowed { hit = renamed.at(hit) }
    let help = if hit != none {
      "meintest du `" + hit + "`?"
    } else if allowed.len() > 0 {
      "erlaubt: " + show-names(allowed)
    } else {
      "weglassen, `" + function + "` kennt keine benannten Argumente"
    }
    let article = if what == "Parameter" or what == "Schlüssel" { "unbekannter " } else { "unbekannt: " }
    fail(package, function, article + what + " `" + key + "` – " + help)
  }
}

/// Prüft den Wert einer Auswahl. Alte Werte brechen mit „heißt jetzt" ab,
/// ein falsches Aus mit dem richtigen, alles andere mit Vorschlag und Liste.
///
/// - package (str): Paketname
/// - function (str): Funktionsname
/// - name (str): Name des Parameters
/// - value (any): der übergebene Wert
/// - allowed (array): gültige Werte (`none`, `"at-end"`) und Typen (`function`)
/// - renamed (dictionary): alter Wert → neuer Wert oder Dictionary Option → Wert
/// -> none
#let check-value(package, function, name, value, allowed, renamed: (:)) = {
  for entry in allowed {
    if value == entry and type(value) == type(entry) { return }
    if type(entry) == type and type(value) == entry { return }
  }
  let shown = "`" + name + ": " + show-value(value) + "`"
  // alter Wert
  let key = if type(value) == str { value } else { repr(value) }
  let old = if key in renamed { key } else if fold-name(key) in renamed { fold-name(key) } else { none }
  if old != none {
    let new = renamed.at(old)
    let text = if type(new) == dictionary {
      new.pairs().map(((k, v)) => k + ": " + repr(v)).join(", ")
    } else {
      repr(new)
    }
    fail(package, function, shown + " heißt jetzt `" + text + "`")
  }
  // falsches Aus
  let off-words = ("none", "false", "keine", "")
  if none in allowed and (value == false or value in off-words) {
    fail(package, function, shown + " – das Aus ist `none`")
  }
  if false in allowed and none not in allowed and (value == none or value in off-words) {
    fail(package, function, shown + " – das Aus ist `false`")
  }
  // ungültiger Wert
  let words = allowed.filter(entry => type(entry) == str)
  let hit = none
  if type(value) == str {
    for word in word-pairs.at(fold-name(value), default: ()) {
      if hit == none and word in words { hit = word }
    }
    if hit == none { hit = nearest(value, words) }
  }
  let list = allowed.map(entry => "`" + repr(entry) + "`").join(", ")
  fail(
    package,
    function,
    shown + " ist kein gültiger Wert – " + if hit != none { "meintest du `" + repr(hit) + "`? " } + "erlaubt: " + list,
  )
}

/// Prüft den Typ eines Werts.
///
/// - package (str): Paketname
/// - function (str): Funktionsname
/// - name (str): Name des Parameters
/// - value (any): der übergebene Wert
/// - expected (type, array): erlaubter Typ oder Array aus Typen, `none`, `auto`
/// - example (str, none): Beispiel für die Abhilfe, ohne Backticks
/// -> none
#let check-type(package, function, name, value, expected, example: none) = {
  let types = if type(expected) == array { expected } else { (expected,) }
  types = types.map(entry => if type(entry) == type { entry } else { type(entry) })
  if type(value) in types { return }
  if types == (bool,) and (value == none or value in ("none", "false", "keine", "")) {
    fail(package, function, "`" + name + ": " + show-value(value) + "` – das Aus ist `false`")
  }
  let words = (
    "length": "eine Länge",
    "relative": "eine Länge oder einen Anteil",
    "ratio": "einen Anteil",
    "fraction": "einen Bruchteil (`fr`)",
    "angle": "einen Winkel",
    "int": "eine ganze Zahl",
    "float": "eine Zahl",
    "str": "einen Text (`str`)",
    "content": "Inhalt",
    "bool": "`true` oder `false`",
    "array": "eine Liste",
    "dictionary": "ein Dictionary",
    "color": "eine Farbe",
    "stroke": "eine Linie (`stroke`)",
    "alignment": "eine Ausrichtung",
    "function": "eine Funktion",
    "label": "ein Label",
    "none": "`none`",
    "auto": "`auto`",
  )
  let examples = (
    "length": "5mm",
    "relative": "50%",
    "ratio": "50%",
    "fraction": "1fr",
    "angle": "90deg",
    "int": "2",
    "float": "1.5",
    "str": "\"Text\"",
    "content": "[Text]",
    "bool": "true",
    "array": "(1, 2)",
    "dictionary": "(a: 1)",
    "color": "blue",
    "stroke": "1pt + black",
    "alignment": "left",
    "function": "x => x",
    "label": "<name>",
    "none": "none",
    "auto": "auto",
  )
  let type-name(entry) = if entry == type(none) { "none" } else if entry == type(auto) { "auto" } else { repr(entry) }
  let wanted = types.map(entry => words.at(type-name(entry), default: "`" + type-name(entry) + "`")).join(" oder ")
  let help = if example != none {
    example
  } else if length in types and type(value) in (int, float) {
    repr(value) + "mm"
  } else {
    examples.at(type-name(types.first()), default: type-name(types.first()))
  }
  fail(
    package,
    function,
    "`" + name + "` erwartet " + wanted + ", bekam `" + show-value(value) + "` (" + type-name(type(value)) + ") – zum Beispiel `" + help + "`",
  )
}

/// Lehnt leeren Text ab; „nichts" ist `none`.
///
/// - package (str): Paketname
/// - function (str): Funktionsname
/// - name (str): Name des Parameters
/// - value (any): der übergebene Wert
/// - meaning (str): deutsche Bedeutung des Fehlens, zum Beispiel `"kein Untertitel"`
/// -> none
#let check-not-empty(package, function, name, value, meaning) = {
  if value == "" {
    fail(package, function, "`" + name + ": \"\"` – für „" + meaning + "\" `none` schreiben oder weglassen")
  }
}

/// Prüft die Anzahl der Positionsargumente eines Sinks.
///
/// - package (str): Paketname
/// - function (str): Funktionsname
/// - positional-args (array, arguments): die Positionsargumente des Sinks
/// - max (int): höchste erlaubte Anzahl
/// - min (int): kleinste erlaubte Anzahl
/// - hint (str, none): Abhilfe; ohne Angabe ein allgemeiner Text
/// -> none
#let check-positional(package, function, positional-args, max: 0, min: 0, hint: none) = {
  let given = if type(positional-args) == arguments { positional-args.pos() } else { positional-args }
  let count = given.len()
  let counted = str(count) + if count == 1 { " Positionsargument" } else { " Positionsargumente" }
  if count > max {
    let limit = if max == 0 { "erlaubt ist keines" } else { "erlaubt ist höchstens " + str(max) }
    let help = if hint != none {
      hint
    } else if max == 0 {
      "Werte benannt schreiben (`name: wert`)"
    } else {
      "überzählige Argumente entfernen oder benannt schreiben"
    }
    fail(package, function, counted + ", " + limit + " – " + help)
  }
  if count < min {
    let help = if hint != none { hint } else { "fehlendes Argument ergänzen" }
    fail(package, function, counted + ", erwartet mindestens " + str(min) + " – " + help)
  }
}

/// Liefert den abbrechenden Stub für einen alten Funktionsnamen.
///
/// - package (str): Paketname
/// - old (str): alter Funktionsname
/// - new (str): neuer Name oder neue Schreibweise des Aufrufs
/// -> function
#let stub(package, old, new) = (..args) => fail(package, old, "`" + old + "` heißt jetzt `" + new + "`")
