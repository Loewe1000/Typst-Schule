// Interne Namen von operatoren. Keine zugesicherte Schnittstelle: Was hier
// steht, darf sich in jeder Version ändern. Dokumente benutzen es nicht.

/// Die im Dokument verwendeten Operatoren (Array aus `str`, in der
/// Reihenfolge der Aufrufe von `operator`).
#let used = state("schule/operatoren/used@1", ())

/// Einstellungen, die `operatoren-liste` für alle `operator`-Aufrufe setzt.
#let settings = state("schule/operatoren/settings@1", (bold: false))

/// Die Fächer, für die das Paket Operatoren mitbringt.
#let subjects = ("Mathe", "Physik")

/// Die Sprachen, in denen die Definitionen vorliegen.
#let languages = ("de", "it")

/// Label am Anfang der Operatorenliste.
#let overview-label = label("schule-operatoren-overview")

/// Setzt den Text eines Operators, auf Wunsch fett.
///
/// - body (content, str): der Text
/// - bold (bool): fett setzen
/// -> content
#let render-operator(body, bold: false) = {
  if bold { strong(body) } else { body }
}

/// Bildet aus einem Operatornamen das Label seiner Zeile in der
/// Operatorenliste: Kleinbuchstaben, `ä ö ü ß` zu `ae oe ue ss`, Leerzeichen
/// zu Bindestrich. `operator` und `operatoren-liste` benutzen beide diese
/// Funktion, sonst zeigt der Link ins Leere.
///
/// - name (str): Operatorname, zum Beispiel `"grafisch darstellen"`
/// -> label
#let label-name(name) = {
  let slug = lower(name)
    .replace("ä", "ae")
    .replace("ö", "oe")
    .replace("ü", "ue")
    .replace("ß", "ss")
    .replace(regex("\s+"), "-")
  label("schule-operatoren-" + slug)
}

/// Vereinheitlicht einen Sprachcode: ohne Rand, in Kleinbuchstaben.
///
/// - language (str): Sprachcode
/// -> str
#let normalize-language(language) = lower(language.trim())

/// Pfad der CSV-Datei eines Fachs, relativ zu `src/`.
///
/// - subject (str): Fach, `"Mathe"` oder `"Physik"`
/// - language (str): vereinheitlichter Sprachcode, `"de"` oder `"it"`
/// -> str
#let csv-path(subject, language) = {
  "../" + subject + if language == "de" { "" } else { "-" + language } + ".csv"
}

/// Überschrift der Operatorenliste in der gewählten Sprache.
///
/// - language (str): vereinheitlichter Sprachcode, `"de"` oder `"it"`
/// -> content
#let overview-title(language) = {
  if language == "it" { [Elenco degli operatori] } else { [Operatorenliste] }
}
