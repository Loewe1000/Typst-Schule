#let operatoren-state = state("operatoren", ())

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
/// -> content
#let operator(name, text: "") = {
  context operatoren-state.update(s => {
    s.push(str(name))
    s
  })
  [#if text == "" [#link(label("-def"), name)] else [#link(label("-def"), text)]]
}

/// Rendert eine alphabetisch sortierte Operatorenliste für das angegebene Fach.
///
/// Liest Operator-Definitionen aus einer CSV-Datei im Dokumentverzeichnis
/// (`Mathe.csv` oder `Physik.csv`). Nur die im Dokument verwendeten Operatoren
/// werden aufgelistet.
///
/// ```typ
/// #operatoren-liste(fach: "Physik")
/// ```
///
/// - fach (string): Fachname. Bestimmt die CSV-Datei. Verfügbar: `"Mathe"`, `"Physik"`. Standard: `"Mathe"`.
/// -> content
#let operatoren-liste(fach: "Mathe") = [
  #import "@preview/tablex:0.0.9": *
  #context {
    let operatoren-definitionen-array = csv(fach + ".csv", delimiter: ";")
    let operatoren-definitionen = (:)
    for operator in operatoren-definitionen-array {
      operatoren-definitionen.insert(operator.at(0), operator.at(1))
    }

    context [
      #let operatoren = operatoren-state.final().map(op => lower(op))
      #label("-def")
      = Operatorenliste
      #set text(10pt, hyphenate: false)
      #tablex(columns: (auto, 1fr), stroke: 0.5pt, ..operatoren.dedup().sorted().map(op => {
        ([*#op*], [#operatoren-definitionen.at(op) #label(op+"-def")])
      }).flatten())
      #v(5mm)
    ]
  }
]