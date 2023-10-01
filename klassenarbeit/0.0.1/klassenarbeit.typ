#import "@schule/arbeitsblatt:0.0.5": *
#import "@preview/unify:0.4.0": *

#let header(title: "", class: "", date: "", teacher: "") = {
  set text(font: "Myriad Pro", hyphenate: true, lang: "de")
  tablex(
    columns: (1fr,) * 3,
    align: center + horizon,
    stroke: none,
    inset: 3pt,
    [],
    rowspanx(2)[#text(16pt, weight: "semibold")[#title]],
    cellx(align: right)[#date],
    [],
    cellx(align: right)[#class - #teacher] 
  )
  
  move(dy:-1em, line(length: 100%, stroke: 0.5pt + luma(200)))
}


#let klassenarbeit(title: "", class: "", date: "", teacher: "", font-size:12pt, ..args, body) = {

show: arbeitsblatt.with(
  title: title,
  font-size: font-size,
  custom-header: header(title: title, date: date, class: class, teacher: teacher),
  header-ascent: 0%,
)

text(14pt, weight: "semibold")[Name:]

tablex(
    columns: (auto, 1fr),
    align: left,
    auto-lines: false,
    inset: 8pt,
    hlinex(),
    [*Hinweise:*], [Die Lösungen sind nachvollziehbar und in einer sauberen äußeren Form anzufertigen. Skizzen werden mit Lineal und Bleistift angefertigt.],
    [*Hilfsmittel: *], [keine],
    [*Bearbeitungszeit:*], [45 Minuten],
    hlinex(),
  )

body
}
