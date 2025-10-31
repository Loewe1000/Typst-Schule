#import "@schule/arbeitsblatt:0.2.4": *

/// Creates a new klassenarbeit (class test/exam)
///
/// - title (string): Title of the exam.
/// - subtitle (string): Subtitle of the exam.
/// - class (string): Class designation.
/// - date (string): Date of the exam.
/// - logo (content): Logo to display in header.
/// - teacher (string): Teacher name.
/// - student (string): Student name.
/// - table (array): Additional info table rows.
/// - stufe (string, boolean): "I" for Sekundarstufe I, "II" for Sekundarstufe II.
/// - info-table (boolean): Whether to show info table with name.
/// - erwartungen (boolean): Whether to show expectations/rubric.
/// - page-numbering (boolean): Whether to show page numbers.
/// - klausurboegen (boolean): Whether to generate exam sheets.
/// - ergebnisse (array): Student results for exam sheets.
/// - page-settings (dictionary): Additional page settings.
/// - klausurboegen (dictionary): Settings for exam sheet generation.
/// - ..args (any): Additional arguments passed to arbeitsblatt (e.g. font, math-font, font-size, figure-font-size, teilaufgabe-numbering, punkte, loesungen, materialien, etc.).
#let _ = counter("klassenarbeit")
#let klassenarbeit(
  subtitle: "",
  date: "",
  logo: "angela",
  teacher: "",
  student: "",
  name-field: "Name",
  info-table: false,
  page-numbering: true,
  klausurboegen: false,
  erwartungen: true,
  ..args,
  body,
) = context {
  // Counter ZUERST erhöhen, damit die ID korrekt ist
  counter("klassenarbeit").step()
  counter(page).update(1)
  
  // Hole die aktuelle Klassenarbeit-ID direkt als Zahl
  let current-ka-id = counter("klassenarbeit").get().first()
  let ka-label = label("ende-arbeitsblatt-id-" + str(current-ka-id))
  
  let table = if type(info-table) != bool and type(info-table) == array {
    info-table
  } else { () }
  let page-settings = args.named().at("page-settings", default: (:))
  let title = args.named().at("title", default: "")
  let class = args.named().at("class", default: "")
  // Extract font from args for internal use
  let font = args.named().at("font", default: "Myriad Pro")

  set page(
    footer: if page-numbering {
      context [
        #let current-page = counter(page).at(here()).at(0)
        #let end-page = counter(page).at(ka-label).at(0)
        #let last-page = end-page
        #if current-page <= end-page [
          #set text(8pt, font: font)
          #set align(right)
          Seite #current-page von #last-page
        ]
      ]
    },
  )

  let header(title: "", subtitle: "", class: "", date: "", teacher: "", logo: none) = {
    import "logos.typ": logos
    if logo in logos.keys() {
      logo = image(bytes(logos.at(logo)))
    }
    set text(font: font, hyphenate: true, lang: "de")
    std.table(
      columns: (2.5cm, 1fr, 2.5cm),
      align: center + horizon,
      stroke: none,
      inset: 3pt,
      ..if logo != none {
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
    print: true,
    header-ascent: 0%,
    custom-header: header(
      title: title,
      subtitle: subtitle,
      date: date,
      class: class,
      teacher: teacher,
      logo: logo,
    ),
    page-settings: final-page-settings,
    ..args,
  )

  if info-table != false and table != () {
    let table-cells = if type(table) == array and type(table.at(0)) == array {
      table
    } else {
      table.chunks(2)
    }.map(row => {
      (
        std.table.cell(
          inset: (left: 0pt, top: 6pt, bottom: 6pt, right: 6pt),
          [*#row.at(0):*],
        ),
        [#{
          row.at(1)
        }],
      )
    })

    if name-field != none { text(14pt, weight: "semibold")[#name-field: #h(0.25em) #student] }

    std.table(
      columns: (auto, 1fr),
      align: left,
      inset: 6pt,
      stroke: none,
      std.table.hline(stroke: 0.5pt + luma(200)),
      ..if table-cells.len() > 0 {
        table-cells.flatten()
      },
      std.table.hline(stroke: 0.5pt + luma(200)),
    )
  } else if name-field != none {
    text(14pt, weight: "semibold")[#name-field: #h(0.25em) #student]
    line(length: 100%, stroke: 0.5pt + luma(200))
  }

  body

  // Setze das Label mit der fixierten Klassenarbeit-ID
  [#metadata("ende-des-dokuments") #ka-label]


  if erwartungen == true {
    show-erwartungen(new-page: true)
  }

  [
    #if klausurboegen != false and type(klausurboegen) == dictionary {
      import "@schule/klausurboegen:0.0.3": *

      klausurbögen(
        exam: title,
        subexam: subtitle,
        teacher: teacher,
        class: class,
        date: date,
        sek1: if "stufe" in klausurboegen.keys() and klausurboegen.at("stufe") == "II" {
          false
        } else if "stufe" in klausurboegen.keys() and klausurboegen.at("stufe") == "I" {
          true
        } else {
          true
        },
        result: if "ergebnisse" in klausurboegen.keys() and klausurboegen.at("ergebnisse") != none {
          true
        } else {
          false
        },
        ..if "ergebnisse" in klausurboegen.keys() and klausurboegen.at("ergebnisse") != none {
          (students: ergebnisse)
        },
        ..klausurboegen,
      )
    }
  ]
}
