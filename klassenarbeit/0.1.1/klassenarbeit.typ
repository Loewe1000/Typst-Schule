#import "@schule/arbeitsblatt:0.2.4": *
#import "./bewertung.typ": *

#let __s_punkte = state("punkte", "keine")

#let klassenarbeit(
  title: "",
  subtitle: "",
  class: "",
  date: "",
  logo: "",
  teacher: "",
  schueler: "",
  font: "Myriad Pro",
  math-font: "Fira Math",
  font-size: 12pt,
  figure-font-size: 12pt,
  table: (),
  stufe: false,
  loesungen: none,
  materialien: none,
  info-table: true,
  erwartungen: false,
  teilaufgabe-numbering: "1.", // "a)" "1."
  punkte: "keine",
  bewertung: false,
  page-numbering: true,
  klausurboegen: false,
  ergebnisse: none,
  page-settings: (:),
  klausurboegen-settings: (sub: false, numbering: "a)", rand: 6cm, weißer-rand: true),
  ..args,
  body,
) = {
  set page(
    footer: if page-numbering {
      [
        #set align(right)
        #set text(8pt, font: font)
        Seite
        #context counter(page).display("1 von 1", both: true)
      ]
    },
  )

  let header(title: "", subtitle: "", class: "", date: "", teacher: "", logo: []) = {
    set text(font: font, hyphenate: true, lang: "de")
    std.table(
      columns: (2.5cm, 1fr, 2.5cm),
      align: center + horizon,
      stroke: none,
      inset: 3pt,
      ..if logo != [] {
        (
          std.table.cell(rowspan: 2, align: left + horizon, inset: 0pt)[#text(16pt, weight: "semibold")[#box(height: 1cm)[#logo]]],
          std.table.cell(rowspan: 2)[#stack(
            spacing: 0mm,
            text(16pt, weight: "semibold")[#title],

            if subtitle != "" {
              v(2mm)
              text(12pt, weight: "regular")[#subtitle]
            },
          )],
          std.table.cell(align: right + horizon)[#text(11pt, weight: "regular")[#date]],
          std.table.cell(align: right + horizon)[#text(11pt, weight: "regular")[#class - #teacher]],
        )
      } else {
        (
          [],
          std.table.cell(rowspan: 2)[#text(16pt, weight: "semibold")[#title]],
          std.table.cell(align: right + horizon)[#date],
          [],
          std.table.cell(align: right + horizon)[#class - #teacher],
        )
      },
    )

    move(dy: -1em, line(length: 100%, stroke: 0.5pt + luma(200)))
  }

  // Standard-Margin für Klassenarbeiten definieren
  let klassenarbeit-margin = (top: 1cm, bottom: 1cm, left: 1.5cm, right: 1.5cm)

  // Alle page-settings zusammenstellen
  let final-page-settings = page-settings
  if "margin" not in page-settings.keys() {
    final-page-settings.insert("margin", klassenarbeit-margin)
  }

  show: arbeitsblatt.with(
    title: title,
    font-size: font-size,
    print: true,
    header-ascent: 0%,
    font: font,
    math-font: math-font,
    figure-font-size: figure-font-size,
    punkte: punkte,
    teilaufgabe-numbering: teilaufgabe-numbering,
    page-settings: final-page-settings,
    custom-header: header(
      title: title,
      subtitle: subtitle,
      date: date,
      class: class,
      teacher: teacher,
      logo: logo,
    ),
    loesungen: loesungen,
    materialien: materialien,
    ..args,
  )

  if info-table {
    text(14pt, weight: "semibold")[Name:#h(0.25em) #schueler]

    std.table(
      columns: (auto, 1fr),
      align: left,
      inset: 6pt,
      stroke: none,
      std.table.hline(stroke: 0.5pt),
      ..if table.len() > 0 {
        range(0, table.len())
          .map(key => (
            (
              std.table.cell(
                inset: (left: 0pt, top: 6pt, bottom: 6pt, right: 6pt),
                [*#{ table.at(key).at(0) }:*],
              ),
              [#{
                table.at(key).at(1)
              }],
            )
          ))
          .flatten()
      },
      std.table.hline(stroke: 0.5pt),
    )
  }

  body
  if bewertung == true {
    d_ew_bewertung()
  }
  [
    #if erwartungen == true {
      d_ew()
    }

    #if klausurboegen {
      import "@schule/klausurboegen:0.0.3": *

      klausurbögen(
        exam: title,
        subexam: subtitle,
        teacher: teacher,
        class: class,
        date: date,
        sek1: if stufe == "II" {
          false
        } else if stufe == "I" {
          true
        },
        result: if ergebnisse != none {
          true
        } else {
          false
        },
        ..if ergebnisse != none {
          (students: ergebnisse)
        },
        ..klausurboegen-settings,
      )
    }
  ]
}
