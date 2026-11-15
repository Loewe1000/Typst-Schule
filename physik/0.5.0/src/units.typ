// Interne Helfer für Vorsätze, Einheiten und den Satz der Messwerttabelle.
// Erreichbar über `physik.internal`; keine zugesicherte Schnittstelle.
#import "@preview/fancy-units:0.1.1": unit as fancy-unit
#import "@preview/zero:0.5.0": num as zero-num
#import "internal/check.typ": fail, check-value, show-value

/// SI-Vorsätze mit ihrem Faktor, von groß nach klein.
#let prefix-factors = (
  "Q": 1e30, // Quetta
  "R": 1e27, // Ronna
  "Y": 1e24, // Yotta
  "Z": 1e21, // Zetta
  "E": 1e18, // Exa
  "P": 1e15, // Peta
  "T": 1e12, // Tera
  "G": 1e9, // Giga
  "M": 1e6, // Mega
  "k": 1e3, // Kilo
  "": 1,
  "c": 1e-2, // Zenti
  "m": 1e-3, // Milli
  "u": 1e-6, // Mikro (μ)
  "n": 1e-9, // Nano
  "p": 1e-12, // Piko
  "f": 1e-15, // Femto
  "a": 1e-18, // Atto
  "z": 1e-21, // Zepto
  "y": 1e-24, // Yokto
  "r": 1e-27, // Ronto
  "q": 1e-30, // Quekto
)

/// Prüft, ob ein Vorsatz die Form `"e<n>"` hat (Zehnerpotenz, zum Beispiel `"e14"`).
///
/// - prefix (any): der zu prüfende Wert
/// -> bool
#let is-power-prefix(prefix) = type(prefix) == str and prefix.match(regex("^e-?\\d+$")) != none

/// Prüft den Wert von `prefix` und bricht bei einem ungültigen Vorsatz ab.
///
/// - function (str): Name der aufrufenden Funktion
/// - prefix (any): der übergebene Wert
/// - allowed (array): erlaubte Sonderwerte neben den Vorsätzen (`none`, `auto`)
/// - renamed (dictionary): alte Werte und ihr Ersatz
/// -> none
#let check-prefix(function, prefix, allowed: (none, auto), renamed: (:)) = {
  if is-power-prefix(prefix) { return }
  let letters = prefix-factors.keys().filter(key => key != "")
  if type(prefix) == str and prefix != "" and prefix not in letters and prefix not in renamed {
    fail(
      "physik",
      function,
      "`prefix: "
        + show-value(prefix)
        + "` ist kein gültiger Vorsatz – erlaubt: "
        + (allowed.map(repr) + letters.map(repr)).map(entry => "`" + entry + "`").join(", ")
        + ", `\"e<n>\"` (Zehnerpotenz, zum Beispiel `\"e14\"`); einen anderen Vorsatz direkt in `unit` schreiben",
    )
  }
  check-value("physik", function, "prefix", prefix, allowed + letters, renamed: renamed)
}

/// Faktor eines Vorsatzes: `none` und `auto` liefern 1, `"k"` liefert 1000,
/// `"e14"` liefert 10^14.
///
/// - prefix (none, auto, str): Vorsatz wie in `datensatz(prefix: …)`
/// -> int, float
#let prefix-factor(prefix) = {
  if prefix == none or prefix == auto {
    1
  } else if is-power-prefix(prefix) {
    calc.pow(10, int(prefix.slice(1)))
  } else if prefix in prefix-factors {
    prefix-factors.at(prefix)
  } else {
    1
  }
}

/// Trennt einen Vorsatz vom Anfang einer Einheit. Einbuchstabige Einheiten und
/// `"kg"` haben keinen Vorsatz.
///
/// - unit (any): Einheit; nur Text wird zerlegt
/// -> array
#let split-unit-prefix(unit) = {
  if unit != none and type(unit) == str and unit.len() > 1 and unit != "kg" {
    for (key, factor) in prefix-factors {
      if key != "" and unit.starts-with(key) {
        return (factor, unit.slice(key.len()))
      }
    }
  }
  (1, unit)
}

/// Wählt zu einem Wert den Vorsatz, mit dem er zwischen 1 und 1000 liegt.
/// Liefert `(Faktor, neue Einheit)`; die Werte sind durch den Faktor zu teilen.
///
/// - value (int, float): Vergleichswert, üblicherweise der kleinste Betrag
/// - unit (str, content, none): Einheit, mit oder ohne Vorsatz
/// -> array
#let convert-unit(value, unit) = {
  if type(value) != float and type(value) != int {
    return (1, unit)
  }
  if calc.abs(value) == 0 {
    return (1, unit)
  }

  // Hat die Einheit schon einen Vorsatz, wird zuerst auf die Basiseinheit gerechnet.
  let (current-factor, base-unit) = split-unit-prefix(unit)
  let base-value = value * current-factor

  for (key, factor) in prefix-factors {
    let scaled = calc.abs(base-value) / factor
    if scaled >= 1 and scaled < 1000 {
      let new-unit = if key == "" { base-unit } else { key + base-unit }
      return (factor / current-factor, new-unit)
    }
  }

  // Sehr große oder sehr kleine Zahlen: Basiseinheit ohne Vorsatz.
  (1 / current-factor, base-unit)
}

/// Wendet den automatisch gewählten Vorsatz auf eine Wertereihe an.
/// Liefert `(Werte, Einheit)`; eine Einheit als Inhalt bleibt unverändert,
/// ohne Einheit (`none`) steht der gewählte Vorsatz allein.
///
/// - values (array): Werte; `none` und Inhalt bleiben stehen
/// - unit (str, content, none): Einheit
/// -> array
#let apply-auto-prefix(values, unit) = {
  // Ohne Einheit (`none`) wird wie bisher mit der leeren Einheit gerechnet:
  // der Vorsatz steht dann allein im Kopf.
  let given = unit
  if unit == none { unit = "" }
  if type(unit) != str {
    return (values, unit)
  }

  let smallest = none
  for value in values {
    if type(value) != content and value != none and calc.abs(value) != 0 {
      if smallest == none or calc.abs(value) < smallest {
        smallest = calc.abs(value)
      }
    }
  }

  if smallest != none {
    let (factor, new-unit) = convert-unit(smallest, unit)
    if new-unit != none and new-unit != "" and factor != 1 {
      let scaled = values.map(value => {
        if type(value) == content or value == none {
          return value
        }
        return value / factor
      })
      return (scaled, new-unit)
    }
  }

  (values, given)
}

/// Setzt die Einheit im Tabellenkopf. `prefix: "e14"` steht für den Faktor
/// 10^14; ein führendes `u` wird zu µ, `ohm` zu Ω.
///
/// - prefix (none, auto, str): Vorsatz des Datensatzes
/// - unit (str): Einheit als Text
/// -> content
#let header-unit(prefix, unit) = {
  let spell(text) = if type(text) == str {
    let micro = if text.len() > 1 and text.starts-with("u") { "µ" + text.slice(1) } else { text }
    micro.replace("ohm", "Ω")
  } else {
    text
  }
  if prefix == none or prefix == auto {
    fancy-unit(per-mode: "fraction")[#spell(unit)]
  } else if prefix.starts-with("e") {
    [$10^(#prefix.slice(1))$ #fancy-unit(per-mode: "fraction")[#spell(unit)]]
  } else {
    fancy-unit(per-mode: "fraction")[#spell(prefix + unit)]
  }
}

/// Setzt eine Teiltabelle aus Datensätzen gleicher Länge.
///
/// - datasets (array): Datensätze
/// - row-height (auto, length): Zeilenhöhe
/// - header (none, array): Kopfzeile über den Wertespalten
/// - digits (int): Nachkommastellen, wenn der Datensatz keine eigenen nennt
/// -> content
#let render-measurement-table(
  datasets,
  row-height: auto,
  header: none,
  digits: 2,
) = [
  // Eingebautes `grid` statt tablex: tablex braucht für seine Positionen
  // mehrere Layout-Durchläufe; in Material oder Lösungen einer Aufgabe
  // reichten Typsts fünf dann nicht („document did not converge"). `grid`
  // statt `table`, damit `set table`/`show table` eines Dokuments oder Themes
  // die Messwerttabelle wie bisher nicht berührt.
  #grid(
    stroke: 0.5pt,
    inset: 2.5mm,
    columns: (auto, ..(datasets.at(0).values.len()) * (1fr,)),
    rows: datasets.len() * (row-height,),
    align: (left + horizon, ..(datasets.at(0).values.len()) * (center + horizon,)),
    // Bezeichnungsspalte und Kopfzeile sind getönt.
    fill: (x, y) => if x == 0 or (header != none and y == 0) { rgb(255, 255, 255).darken(5%) },

    // Kopfzeile und Datenzeilen
    ..if header != none {
      while header.len() < datasets.at(0).values.len() {
        header.push([])
      }
      ([],) + header.map(c => strong(c))
    },

    ..for dataset in datasets {
      // Hat irgendein Wert echte Nachkommastellen?
      let has-decimals = false
      for value in dataset.values {
        if type(value) != content and value != none {
          let shown = str(value)
          if shown.contains(".") {
            let decimals = shown.split(".").at(1)
            if decimals.trim("0") != "" {
              has-decimals = true
              break
            }
          }
        }
      }

      // Stellenzahl des Datensatzes, sonst die der Tabelle
      let own-digits = dataset.at("digits", default: auto)
      let dataset-digits = if own-digits == auto or own-digits == none { digits } else { own-digits }
      let name = dataset.at("name", default: none)
      let unit = dataset.at("unit", default: none)

      (
        (
          (if name == none { [] } else { name })
            + if unit != none and unit != "" {
              (
                " in "
                  + if type(unit) == content {
                    // Inhalt (zum Beispiel $Omega$) unverändert setzen
                    unit
                  } else {
                    header-unit(dataset.at("prefix", default: none), unit)
                  }
              )
            }
        ),
        ..dataset.values.map(x => {
          // Leere Zellen leer lassen, Inhalt unverändert setzen, Zahlen formatieren
          if x == none or x == "" { [] } else if type(x) == content { x } else {
            $#zero-num(x, decimal-separator: ",", round: (mode: "places", precision: dataset-digits, pad: has-decimals, direction: "nearest"))$
          }
        }),
      )
    },
  )]
