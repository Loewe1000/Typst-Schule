// Interne Helfer von summify. Keine zugesicherte Schnittstelle:
// Namen und Gestalt dürfen sich in jeder Version ändern.
#import "internal/check.typ": fail, check-named, check-type, fold-name
#import "themes.typ": themes

/// Sichtbarkeit der Zelleninhalte (`false` = Lernmodus).
#let visible-state = state("schule/summify/visible@1", true)

/// Das aktive Thema.
#let theme-state = state("schule/summify/theme@1", themes.default)

/// Alte Schlüssel des Thema-Dictionary, je Gruppe: alt → neu.
#let theme-key-renames = (
  spacing: (content: "cell"),
  sizes: (
    title: (text: "font-size"),
    header: (text: "font-size"),
  ),
  typography: ("base-size": "font-size"),
)

/// Legt ein Dictionary rekursiv über ein anderes.
///
/// - base (dictionary): Ausgangswerte
/// - overrides (dictionary): Werte, die Vorrang haben
/// -> dictionary
#let merge(base, overrides) = {
  let result = base
  for (key, value) in overrides {
    if key in base and type(base.at(key)) == dictionary and type(value) == dictionary {
      result.insert(key, merge(base.at(key), value))
    } else {
      result.insert(key, value)
    }
  }
  result
}

/// Prüft die Schlüssel eines Thema-Dictionary (auch verschachtelt) gegen die
/// Gestalt des Themas `"default"`.
///
/// - function (str): Name der aufrufenden Funktion für die Meldung
/// - name (str): Name des geprüften Parameters oder Schlüssels
/// - value (dictionary): das zu prüfende Dictionary
/// - shape (dictionary): Vorbild mit allen erlaubten Schlüsseln
/// - renames (dictionary): alte Schlüssel dieser Ebene und der Ebenen darunter
/// - complete (bool): alle Schlüssel des Vorbilds müssen vorhanden sein
/// - path (str): Weg von der obersten Ebene bis hierher, zum Beispiel `"sizes.title."`
/// - parameter (str, none, auto): Parameter, in dem das Dictionary steht; `none` nennt ihn nicht, `auto` nimmt `name`
/// -> none
#let check-theme-keys(
  function,
  name,
  value,
  shape,
  renames: theme-key-renames,
  complete: false,
  path: "",
  parameter: auto,
) = {
  check-type("summify", function, name, value, dictionary)
  // Auf der obersten Ebene ist `name` der Parameter; die Funktion
  // `set-theme-overrides` nimmt die Gruppen selbst als Parameter.
  let parameter = if parameter != auto { parameter } else if name == function { none } else { name }
  // Alte Schlüssel mit ihrem ganzen Weg melden: `content` allein läse sich
  // wie eine Aussage über die Funktion `content`.
  let old-keys = renames.pairs().filter(p => type(p.last()) == str).to-dict()
  for key in value.keys() {
    let old = old-keys.keys().find(k => fold-name(k) == fold-name(key))
    if old != none {
      fail("summify", function,
        "Schlüssel `" + path + key + "`"
          + if parameter != none { " in `" + parameter + "`" } else { "" }
          + " heißt jetzt `" + path + old-keys.at(old) + "`")
    }
  }
  check-named("summify", function, value,
    renamed: old-keys,
    allowed: shape.keys(),
    what: "Schlüssel")
  for (key, expected) in shape {
    if key not in value {
      if complete {
        fail("summify", function,
          "im Thema fehlt der Schlüssel `" + key + "` in `" + name
            + "` – ein vollständiges Thema angeben oder einzelne Werte über `theme-overrides` ändern")
      }
    } else if type(expected) == dictionary {
      let below = renames.at(key, default: (:))
      check-theme-keys(function, key, value.at(key), expected,
        renames: if type(below) == dictionary { below } else { (:) },
        complete: complete,
        path: path + key + ".",
        parameter: parameter)
    }
  }
}

/// Liefert die State-Aktualisierung, die Überschreibungen über das aktive
/// Thema legt.
///
/// - function (str): Name der aufrufenden Funktion für die Meldung
/// - name (str): Name des Parameters für die Meldung
/// - overrides (dictionary): Teil-Dictionary eines Themas
/// -> content
#let apply-theme-overrides(function, name, overrides) = {
  check-theme-keys(function, name, overrides, themes.default)
  context {
    let current = theme-state.get()
    theme-state.update(merge(current, overrides))
  }
}
