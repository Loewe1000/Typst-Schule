// Häufigkeitsanalyse der Buchstaben A–Z mit Säulendiagramm.
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": chart
#import "internal/check.typ": check-type

/// Zählt die Buchstaben A–Z eines Textes und setzt dazu ein Säulendiagramm.
///
/// Groß- und Kleinbuchstaben werden zusammengezählt; Umlaute, ß, Ziffern und
/// Satzzeichen zählen nicht. Das Ergebnis ist ein Dictionary:
///
/// - `counts`: absolute Häufigkeit je Buchstabe (Dictionary `A` bis `Z`)
/// - `frequencies`: relative Häufigkeit je Buchstabe in Prozent, als
///   Kommazahl von 0 bis 100 (kein `ratio`)
/// - `items`: die relativen Häufigkeiten als Array aus Paaren
///   `([Buchstabe], Prozentwert)`, etwa für ein eigenes Diagramm
/// - `chart`: das fertige Säulendiagramm
/// - `text`: der übergebene Text
///
/// ```typ
/// #let analysis = haeufigkeitsanalyse("Hallo Welt")
/// #analysis.chart
/// ```
///
/// - text (str): Text, dessen Buchstaben gezählt werden
/// -> dictionary
#let haeufigkeitsanalyse(text) = {
  check-type("informatik", "haeufigkeitsanalyse", "text", text, str, example: "\"Hallo Welt\"")

  let counts = (:)
  for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".codepoints() {
    counts.insert(char, 0)
  }
  for char in text.codepoints() {
    let letter = upper(char)
    if letter in counts.keys() {
      counts.at(letter) += 1
    }
  }

  let total = counts.values().sum()

  let frequencies = (:)
  for (letter, count) in counts {
    frequencies.insert(letter, if total > 0 { 100.0 * count / total } else { 0.0 })
  }

  let items = ()
  for (letter, frequency) in frequencies {
    items.push(([#letter], frequency))
  }

  let column-chart = canvas(
    length: 1cm,
    {
      draw.set-style(
        axis: (
          y: (
            tick: (stroke: none),
            stroke: none,
          ),
        ),
      )
      chart.columnchart(
        items,
        size: (11, 4),
        bar-style: (
          fill: rgb("#008000"),
          stroke: none,
        ),
        y-tick-step: none,
      )
    },
  )

  (
    counts: counts,
    frequencies: frequencies,
    items: items,
    chart: column-chart,
    text: text,
  )
}
