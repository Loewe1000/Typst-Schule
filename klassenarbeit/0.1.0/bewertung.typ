#import "@schule/klausurboegen:0.0.3": *

#let __s_erwartungen = state("erwartungen", ())
#let __s_aufgaben = state("aufgaben", ())


#let ew_verteilung_oberstufe = (
  .0,
  .20,
  .27,
  .33,
  .40,
  .45,
  .50,
  .55,
  .60,
  .65,
  .70,
  .75,
  .80,
  .85,
  .90,
  .95,
)
#let ew_namen_oberstufe = (
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
)

#let ew_verteilung_unterstufe = (
  .0,
  .20,
  .27,
  .33,
  .40,
  .45,
  .50,
  .55,
  .60,
  .65,
  .70,
  .75,
  .80,
  .85,
  .90,
  .95,
)
#let ew_namen_unterstufe = (
  "6",
  "5-",
  "5",
  "5+",
  "4-",
  "4",
  "4+",
  "3-",
  "3",
  "3+",
  "2-",
  "2",
  "2+",
  "1-",
  "1",
  "1+",
)

#let ew_verteilung_ohne_tendenz = (
  .0,
  .20,
  .40,
  .55,
  .70,
  .85,
)
#let ew_namen_ohne_tendenz = (
  "6",
  "5",
  "4",
  "3",
  "2",
  "1",
)

#let d_ew() = [
  #pagebreak()
  = Erwartungshorizont <erwartungshorizont>

  #let cell-highlight-color = rgb("#F2F2F2")
  #context {
    let aufgaben = __s_aufgaben.final()
    let zellen = aufgaben
      .map(aufg => {
        let cells = (
          table.cell(fill: cell-highlight-color)[*#{ aufg.nummer }*],
          table.cell(fill: cell-highlight-color)[_#{ aufg.title }_],
          table.cell(fill: cell-highlight-color)[#aufg.erwartungen.map(a => a.punkte).sum(default: 0)],
        )

        if aufg.teile == 0 {
          cells.push(([], d_ew_text(aufg.nummer, teil: none), d_ew_punkte(aufg.nummer, teil: none)))
        }

        for i in range(aufg.teile) {
          cells.push([#context [
              #let opts = state("options").get()
              #if opts.teilaufgabe-numbering == "a)" {
                numbering("a)", i + 1)
              } else if opts.teilaufgabe-numbering == "1." {
                numbering("1.1", aufg.nummer, i + 1)
              }
            ]])
          cells.push(table.cell(inset: (x: 1.5mm, y: 2mm), [#aufg.erwartungen.filter(e => e.teil == i + 1).map(e => e.text).join("")]))
          cells.push(table.cell(inset: 2mm, [#aufg.erwartungen.filter(e => e.teil == i + 1).map(e => e.punkte).sum()]))
        }

        cells
      })
      .flatten()
    table(columns: (auto, 1fr, auto), align: (center + horizon, left + horizon, center), table.cell(fill: cell-highlight-color)[*Aufg.*], table.cell(
        fill: cell-highlight-color,
      )[*Die Schüler:innen #sym.dots.h*], table.cell(fill: cell-highlight-color)[*mögli. \ Punkte*], ..zellen, table.cell(colspan:2, align: right, [*Summe*]),[*#aufgaben.map(a => a.erwartungen.map(e => e.punkte).sum()).sum()*], )
  }
]
