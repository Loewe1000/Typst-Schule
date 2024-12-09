#import "@schule/arbeitsblatt:0.1.7": *
#import "./bewertung.typ": *

#let header(title: "", subtitle: "", class: "", date: "", teacher: "", logo: []) = {
  set text(font: "Myriad Pro", hyphenate: true, lang: "de")
  tablex(
    columns: (2.5cm, 1fr, 2.5cm),
    row: (1fr,) * 2,
    align: center + horizon,
    stroke: none,
    inset: 3pt,
    ..if logo != [] {
      (
        rowspanx(
          2,
          align: left + horizon,
          inset: 0pt,
        )[#text(16pt, weight: "semibold")[#box(height: 1cm)[#logo]]],
        rowspanx(2)[#stack(
            spacing: 2mm,
            text(16pt, weight: "semibold")[#title],
            text(12pt, weight: "regular")[#subtitle],
          )],
        cellx(align: right + horizon)[#text(11pt, weight: "regular")[#date]],
        cellx(
          align: right + horizon,
        )[#text(11pt, weight: "regular")[#class - #teacher]],
      )
    } else {
      (
        [],
        rowspanx(2)[#text(16pt, weight: "semibold")[#title]],
        cellx(align: right + horizon)[#date],
        [],
        cellx(align: right + horizon)[#class - #teacher],
      )
    },
  )

  move(dy: -1em, line(length: 100%, stroke: 0.5pt + luma(200)))
}

#let klassenarbeit(
  title: "",
  subtitle: "",
  class: "",
  date: "",
  logo: "",
  teacher: "",
  schueler: "",
  font-size: 12pt,
  table: (),
  stufe: false,
  loesungen: none,
  erwartungen: false,
  bewertung: false,
  print: true,
  page-numbering: true,
  klausurboegen: false,
  ergebnisse: none,
  klausurboegen-settings: (sub: false, numbering: "a)", rand: 6cm, weißer-rand: true),
  ..args,
  body,
) = {
  set page(footer: if page-numbering {
    [
      #set align(right)
      #set text(8pt, font: "Myriad Pro")
      Seite
      #counter(page).display("1 von 1", both: true)
    ]
  })

  show: arbeitsblatt.with(
    title: title,
    font-size: font-size,
    print: print,
    header-ascent: 0%,
    custom-header: header(
      title: title,
      subtitle: subtitle,
      date: date,
      class: class,
      teacher: teacher,
      logo: logo,
    ),
    //loesungen: false,
    ..args,
  )

  text(14pt, weight: "semibold")[Name:#h(0.25em) #schueler] 

  tablex(
    columns: (auto, 1fr),
    align: left,
    auto-lines: false,
    inset: 6pt,
    stroke: 0.5pt,
    hlinex(),
    ..if table.len() > 0 {
      range(0, table.len()).map(key => ((cellx(
        inset: (left: 0pt, top: 6pt, bottom: 6pt, right: 6pt),
        [*#{ table.at(key).at(0) }:*],
      ), [#{ table.at(key).at(1) }]))).flatten()
    },
    hlinex(),
  )

  body
  if bewertung == true {
    d_ew_bewertung()
  }
  [
    #if loesungen == "seite" {
      d_loesungen()
    }
    #if erwartungen == true {
      if stufe == "II" {
        d_ew_oberstufe()
      } else if stufe == "I" {
        d_ew_unterstufe()
      }
    }

    #if klausurboegen {
      import "@schule/klausurboegen:0.0.2": *

      klausurbögen(
        exam: title,
        subexam: subtitle,
        teacher: teacher,
        class: class,
        date: date,
        sek1: if stufe == "II" { false } else if stufe == "I" { true },
        result: if ergebnisse != none { true } else { false },
        ..if ergebnisse != none { (students: ergebnisse) },
        ..klausurboegen-settings,
      )
    }
  ]
}