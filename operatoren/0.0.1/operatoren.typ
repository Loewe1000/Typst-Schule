#let operatoren-state = state("operatoren", ())
#let operatoren-config-state = state("operatoren-config", (text-bold: false,))

#let _render-operator-text(text, bold: false) = {
  if bold { strong(text) } else { text }
}

#let _normalisiere-sprache(language) = lower(str(language).trim())

#let _csv-dateiname(fach, language) = {
  let lang = _normalisiere-sprache(language)
  if lang == "de" {
    fach + ".csv"
  } else if lang == "it" {
    fach + "-it.csv"
  } else {
    panic("Unbekannte Sprache '" + str(language) + "'. Verfügbar: de, it.")
  }
}

#let _operatorenlisten-titel(language) = {
  let lang = _normalisiere-sprache(language)
  if lang == "de" {
    [Operatorenliste]
  } else if lang == "it" {
    [Elenco degli operatori]
  } else {
    panic("Unbekannte Sprache '" + str(language) + "'. Verfügbar: de, it.")
  }
}

/// Markiert einen Operator im Text und verlinkt ihn mit der Operatorenliste.
///
/// Der Operator wird automatisch zur internen Liste hinzugefügt und
/// am Dokumentende in der Operatorenliste angezeigt.
///
/// ```typ
/// #operator[Berechne] die Geschwindigkeit.
/// ```
///
/// - name (content): Der Operator-Name (z. B. `[Berechne]`).
/// - text (string): Alternativer Linktext (optional). Standard: `""` (= `name` wird verwendet).
/// - bold (boolean, none): Optionaler Override für den Linktext. Bei `none`
///   wird die globale Einstellung aus `operatoren-liste(operator-text-bold: ...)` genutzt.
/// -> content
#let operator(name, text: "", bold: none) = {
  context operatoren-state.update(s => {
    s.push(str(name))
    s
  })
  context {
    let global-bold = operatoren-config-state.final().at("text-bold", default: false)
    let effective-bold = if bold == none { global-bold } else { bold }
    [
      #if text == "" {
        link(label("-def"), _render-operator-text(name, bold: effective-bold))
      } else {
        link(label("-def"), _render-operator-text(text, bold: effective-bold))
      }
    ]
  }
}

/// Rendert eine alphabetisch sortierte Operatorenliste für das angegebene Fach.
///
/// Liest Operator-Definitionen aus einer CSV-Datei im Dokumentverzeichnis
/// (`Mathe.csv` oder `Physik.csv`). Nur die im Dokument verwendeten Operatoren
/// werden aufgelistet.
///
/// ```typ
/// #operatoren-liste(fach: "Physik", language: "de")
/// ```
///
/// - fach (string): Fachname. Bestimmt die CSV-Datei. Verfügbar: `"Mathe"`, `"Physik"`. Standard: `"Mathe"`.
/// - language (string): Sprachcode für CSV und Überschrift. Verfügbar: `"de"`, `"it"`. Standard: `"de"`.
/// - operator-text-bold (boolean): Globale Darstellung von `#operator(...)` im Fließtext.
///   Standard: `false`.
/// -> content
#let operatoren-liste(fach: "Mathe", language: "de", operator-text-bold: false) = [
  #import "@preview/tablex:0.0.9": *
  #context {
    operatoren-config-state.update(_ => (text-bold: operator-text-bold,))
    let operatoren-definitionen-array = csv(_csv-dateiname(fach, language), delimiter: ";")
    let operatoren-definitionen = (:)
    for operator in operatoren-definitionen-array {
      operatoren-definitionen.insert(operator.at(0), operator.at(1))
    }

    context [
      #let operatoren = operatoren-state.final().map(op => lower(op))
      #label("-def")
      = #_operatorenlisten-titel(language)
      #set text(10pt, hyphenate: false)
      #tablex(columns: (auto, 1fr), stroke: 0.5pt, ..operatoren.dedup().sorted().map(op => {
        ([#_render-operator-text(op, bold: true)], [#operatoren-definitionen.at(op) #label(op+"-def")])
      }).flatten())
      #v(5mm)
    ]
  }
]