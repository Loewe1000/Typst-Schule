#import "@preview/tablex:0.0.8": *

#let operatoren-state = state("operatoren", ())

#let operator(name, text: "") = {
  context operatoren-state.update(s => {
    s.push(str(name))
    s
  })
  [#if text == "" [#link(label("-def"), emph(name))] else [#link(label("-def"), emph(text))]]
}

#let operatoren-liste(fach: "Mathe") = [
  #context {
    let operatoren-definitionen-array = csv(fach + ".csv")
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