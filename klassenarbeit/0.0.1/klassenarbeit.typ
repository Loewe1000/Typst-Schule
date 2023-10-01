#import "@schule/arbeitsblatt:0.0.5": *
#import "@preview/unify:0.4.0": *

#let header(title: "", class: "", date: "", teacher: "", logo:[]) = {
  set text(font: "Myriad Pro", hyphenate: true, lang: "de")
  tablex(
    columns: (1fr,) * 3,
    row: (1fr,) * 2,
    align: center + horizon,
    stroke: none,
    inset: 3pt,
    ..if logo != [] {
    (rowspanx(2, align: left+horizon, inset: 0pt)[#text(16pt, weight: "semibold")[#box(height: 1cm)[#logo]]],
    rowspanx(2)[#text(16pt, weight: "semibold")[#title]],
    cellx(align: right+horizon)[#date],
    cellx(align: right+horizon)[#class - #teacher])
    } else {
    ([],
    rowspanx(2)[#text(16pt, weight: "semibold")[#title]],
    cellx(align: right+horizon)[#date],
    [],
    cellx(align: right+horizon)[#class - #teacher] )
    }
  )
  
  move(dy:-1em, line(length: 100%, stroke: 0.5pt + luma(200)))
}


#let klassenarbeit(title: "", class: "", date: "", logo: "", teacher: "", font-size:12pt, ..args, body) = {

show: arbeitsblatt.with(
  title: title,
  font-size: font-size,
  custom-header: header(title: title, date: date, class: class, teacher: teacher, logo: logo),
  header-ascent: 0%,
)

text(14pt, weight: "semibold")[Name:]

tablex(
    columns: (auto, 1fr),
    align: left,
    auto-lines: false,
    inset: 8pt,
    hlinex(),
    cellx(inset:0pt, box(inset: (top: 8pt, left:0pt, bottom:8pt, right: 8pt))[*Hinweise:*]), [Die Lösungen sind nachvollziehbar und in einer sauberen äußeren Form anzufertigen. Skizzen werden mit Lineal und Bleistift angefertigt.],
    cellx(inset:0pt, box(inset: (top: 8pt, left:0pt, bottom:8pt, right: 8pt))[*Hingsmittel:*]), [keine],
    cellx(inset:0pt, box(inset: (top: 8pt, left:0pt, bottom:8pt, right: 8pt))[*Bearbeitungszeit:*]), [45 Minuten],
    hlinex(),
  )

body
}
