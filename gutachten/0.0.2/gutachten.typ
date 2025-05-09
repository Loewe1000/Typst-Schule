#import "@preview/unify:0.7.0": *

#let set-gutachten-infos(
  fach: "",
  niveau: "",
  kürzel: "",
  be: 1,
  font: "New Computer Modern Sans",
  math-font: "Fira Math",
) = state("gutachten-infos").update((
  fach: fach,
  niveau: niveau,
  kürzel: kürzel,
  be: be,
  font: font,
  math-font: math-font,
))

#let name = context state("schüler").get().vorname

#let set-aufgaben(aufgaben) = state("aufgaben").update(aufgaben)

#let bewertungsskala(
  prozent,
) = {
  let skala = (
    (prozent: 0.95, punkte: "sehr gut (15 Punkte)"),
    (prozent: 0.9, punkte: "sehr gut (14 Punkte)"),
    (prozent: 0.85, punkte: "sehr gut (13 Punkte)"),
    (prozent: 0.8, punkte: "gut (12 Punkte)"),
    (prozent: 0.75, punkte: "gut (11 Punkte)"),
    (prozent: 0.7, punkte: "gut (10 Punkte)"),
    (prozent: 0.65, punkte: "befriedigend (9 Punkte)"),
    (prozent: 0.6, punkte: "befriedigend (8 Punkte)"),
    (prozent: 0.55, punkte: "befriedigend (7 Punkte)"),
    (prozent: 0.5, punkte: "ausreichend (6 Punkte)"),
    (prozent: 0.45, punkte: "ausreichend (5 Punkte)"),
    (prozent: 0.4, punkte: "ausreichend (4 Punkte)"),
    (prozent: 0.33, punkte: "mangelhaft (3 Punkte)"),
    (prozent: 0.27, punkte: "mangelhaft (2 Punkte)"),
    (prozent: 0.2, punkte: "mangelhaft (1 Punkt)"),
    (prozent: 0.0, punkte: "ungenügend (0 Punkte)"),
  )
  let index = 0
  while index < skala.len() {
    if prozent >= skala.at(index).prozent {
      return skala.at(index).punkte
    }
    index += 1
  }
}

#let aufgabe(name, punkte, body) = [
  = #name

  #body

  #context par[
    #let schüler = state("schüler").get()
    #let be = state("aufgaben").get().at(name).be
    #state("punkte").update(state("punkte").get() + punkte)
    In #name erreicht #schüler.at("vorname") insgesamt *$#punkte$* von *$#be$* Bewertungseinheiten.
  ]
]

#let gutachten(
  vorname: "Max",
  nachname: "Mustermann",
  wahl: (),
  body,
) = [
  #state("schüler").update((vorname: vorname, nachname: nachname))
  #state("punkte").update(0)
  #counter(page).update(1)
  #context [

    #let gutachten-infos = state("gutachten-infos").final()

    #set text(font: gutachten-infos.font, lang: "de")
    #show math.equation: set text(font: gutachten-infos.math-font)
    #set par(justify: true)
    #show math.equation: it => {
      show regex("\d+\.\d+"): it => {
        show ".": {
          "," + h(0pt)
        }
        it
      }
      it
    }

    #set page(
      header-ascent: 20%,
      numbering: (i, n) => {
        context [
          #let schüler = state("schüler").get()
          #let label-name = schüler.vorname + "-" + schüler.nachname + "-pages"
          #i von #counter(page).at(label(label-name)).at(0)
        ]
      },
      margin: (top: 3cm, y: 3cm),
      header: [
        #grid(
          columns: (auto, 1fr, auto),
          align: (left + top, center + horizon, right + horizon),
          image("logo.svg", height: 1.3cm),
          [Gutachten über die schriftliche Prüfung von \ *#vorname #nachname*],
          [Abitur 2025 \ #gutachten-infos.fach (#gutachten-infos.niveau) - #gutachten-infos.kürzel],
        )
        #v(-3mm)
        #line(length: 100%, stroke: 1.5pt)
      ],
    )


    #if wahl.len() > 0 [
      #context [
        #vorname wählt #if type(wahl) == array {
          wahl.map(
            a => {
              let aufgaben-name = state("aufgaben").get().at(a).name
              emph[#a#if aufgaben-name != "" [: #aufgaben-name]]
            },
          ).join(", ", last: " und ") + "."
        } else if type(wahl) == dictionary {
          let keys = wahl.keys()
          keys.map(
            key => {
              "im " + key + " "
              wahl.at(key).map(
                a => {
                  let aufgaben-name = state("aufgaben").get().at(a, default: a)
                  emph[#a#if type(aufgaben-name) == dictionary and aufgaben-name.at("name", default: "") != "" [: #aufgaben-name]]
                },
              ).join(", ", last: " und ")
            },
          ).join(", ", last: " und ") + "."
        }
      ]
    ]

    #body

    #box[
      #context [
        #let be = state("gutachten-infos").final().be
        #let punkte = state("punkte").get()

        #v(1em)

        Insgesamt erreicht der Prüfling *$#punkte$* von *$#be$* Bewertungseinheiten ($#calc.round(100 * punkte / be, digits: 1)$%).\
        Daher bewerte ich die Arbeit mit\
        #align(center)[*#bewertungsskala(punkte / be)*.]
      ]

      #v(1cm)

      #grid(
        columns: (1fr, 5em, 1fr), rows: 1cm, row-gutter: 0.5em,
        [], [], [#text(gray)[_Mit Korrektur und Bewertung einverstanden_]],
        grid.cell(stroke: (bottom: 1pt), []), [], grid.cell(stroke: (bottom: 1pt), []),
        text(9pt, [Ort, Datum, Unterschrift]), [], text(9pt, [Ort, Datum, Unterschrift])
      )
    ]
    //#label()
    #context [
      #let schüler = state("schüler").get()
      #label(schüler.vorname + "-" + schüler.nachname + "-pages")
    ]
  ]
]
