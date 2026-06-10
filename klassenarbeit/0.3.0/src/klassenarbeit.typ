#import "@schule/arbeitsblatt:0.3.0": *

#let _ka-counter = counter("klassenarbeit")

// Aktive Variante ("druck" | "loesung"). Als State, damit verschachtelte
// klassenarbeit()-Aufrufe (mehrere KAs in einer Datei) im Bundle die Variante
// des umgebenden Varianten-Dokuments erben.
#let _state_ka_variante = state("ka-variante", none)

/// Rendert die Klausurbögen als eigenständigen Inhalt (eigenes Dokument).
///
/// Ohne `ergebnisse` entsteht genau EIN leerer Bogen (z. B. zum Kopieren),
/// mit `ergebnisse` (Zeilen aus der Ergebnis-CSV inklusive Kopfzeile) ein
/// ausgefüllter Bogen pro Schüler.
#let _klausurboegen-inhalt(
  title: "",
  subtitle: "",
  teacher: "",
  class: "",
  date: "",
  einstellungen: (:),
) = {
  import "@schule/klausurboegen:0.0.3": klausurbögen

  let parameter = if type(einstellungen) == dictionary { einstellungen } else { (:) }
  let ergebnisse = parameter.at("ergebnisse", default: none)
  let _ = if "ergebnisse" in parameter { parameter.remove("ergebnisse") }
  let _ = if "show" in parameter { parameter.remove("show") }

  klausurbögen(
    exam: title,
    subexam: subtitle,
    teacher: teacher,
    class: class,
    date: date,
    result: ergebnisse != none,
    ..if ergebnisse != none { (students: ergebnisse) },
    ..parameter,
  )
}

/// Rendert genau ein Klassenarbeit-Dokument (eine Variante).
///
/// Interne Funktion; wird vom Dispatcher `klassenarbeit()` pro Variante
/// aufgerufen. `variante: "druck"` entspricht der bisherigen Klassenarbeit,
/// `variante: "loesung"` erzeugt das Lösungsdokument (Lösungen inline,
/// Erwartungshorizont am Ende). Klausurbögen sind NIE Teil dieses Dokuments.
#let _klassenarbeit-einzeln(
  variante: "druck",
  scope: none,
  ka-id: 1,
  subtitle: "",
  date: "",
  logo: "angela",
  teacher: "",
  student: "",
  name-field: "Name",
  name-repeat: false,
  info-table: false,
  page-numbering: true,
  erwartungen: true,
  punkte-template: none,
  ..args,
  body,
) = context {
  _state_ka_variante.update(variante)

  // Page-Counter nur zurücksetzen wenn page-numbering == true oder "reset"
  if page-numbering == true or page-numbering == "reset" {
    counter(page).update(1)
  }

  // Variantenspezifisches Ende-Label (im Bundle existiert der Inhalt in
  // mehreren Dokumenten, Labels müssen daher pro Variante eindeutig sein)
  let ka-label = label("ende-arbeitsblatt-id-" + str(ka-id) + "-" + variante)

  let table = if type(info-table) != bool and type(info-table) == array {
    info-table
  } else { () }
  let page-settings = args.named().at("page-settings", default: (:))
  let title = args.named().at("title", default: "")
  let class = args.named().at("class", default: "")
  // Extract font from args for internal use
  let font = args.named().at("font", default: "Myriad Pro")
  let math-font = args.named().at("math-font", default: "Fira Math")
  font = (font, "Fira Sans", "New Computer Modern Sans", "DejaVu Sans")
  math-font = (math-font, "New Computer Modern Sans Math")

  let name-field-block = {
    if name-field != none {
      text(14pt, weight: "semibold")[#name-field: #h(0.25em) #student]
    }
  }

  set page(
    footer: if page-numbering != false {
      context [
        #let current-page = counter(page).at(here()).at(0)
        #let end-page = counter(page).at(ka-label).at(0)
        // Bei "continuous": Hole die letzte Seite der LETZTEN Klassenarbeit im Dokument
        #let last-page = if page-numbering == "continuous" {
          let total-ka = _ka-counter.final().first()
          let last-ka-label = label("ende-arbeitsblatt-id-" + str(total-ka) + "-" + variante)
          // Guard: Im Bundle kann die letzte KA in einem anderen
          // Varianten-Dokument liegen; dann auf das eigene Ende zurückfallen.
          if query(last-ka-label).len() > 0 {
            counter(page).at(last-ka-label).at(0)
          } else {
            end-page
          }
        } else {
          end-page
        }
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
          std.table.cell(rowspan: 2, align: left + horizon, inset: (rest: 0pt, bottom: 4pt))[#text(16pt, weight: "semibold")[#box(height: 1cm)[#logo]]],
          std.table.cell(rowspan: 2)[#stack(
            spacing: 0mm,
            text(16pt, weight: "semibold")[#title],

            if subtitle != "" {
              v(2mm)
              text(12pt, weight: "regular")[#subtitle]
            },
          )],
          std.table.cell(align: right + horizon)[#text(11pt, weight: "regular")[#date]],
          std.table.cell(align: right + horizon)[#text(11pt, weight: "regular")[#if class != "" and teacher != "" [#class - #teacher] else [#class#teacher]]],
        )
      } else {
        (
          [],
          std.table.cell(rowspan: 2)[#text(16pt, weight: "semibold")[#title]],
          std.table.cell(align: right + horizon)[#date],
          [],
          std.table.cell(align: right + horizon)[#if class != "" and teacher != "" [#class - #teacher] else [#class#teacher]],
        )
      },
      std.table.hline(stroke: 0.5pt + luma(200)),
      ..if name-repeat {
        (
          std.table.cell(align: left + horizon, inset: (x: 0pt, y: 14pt))[#name-field-block],
          std.table.hline(stroke: 0.5pt + luma(200)),
        )
      },
    )
  }

  // Fester Abstand zwischen Kopfzeilen-Unterkante und Inhalt – auf JEDER
  // Seite, unabhängig von name-repeat. Wird über header-ascent realisiert;
  // der obere Rand wird um denselben Betrag erhöht, damit die Kopfzeile
  // weiterhin beim eigentlichen oberen Rand (Standard: 1cm) beginnt.
  let kopf-abstand = 14pt

  // Standard-Margin für Klassenarbeiten definieren
  let klassenarbeit-margin = (top: 1cm, bottom: 1cm, left: 1.5cm, right: 1.5cm)

  // Alle page-settings zusammenstellen
  let final-page-settings = page-settings
  if "margin" not in page-settings.keys() {
    final-page-settings.insert("margin", klassenarbeit-margin)
  }
  // Kopf-Abstand auf den oberen Rand aufschlagen
  if type(final-page-settings.margin) == dictionary {
    let m = final-page-settings.margin
    m.insert("top", m.at("top", default: 1cm) + kopf-abstand)
    final-page-settings.insert("margin", m)
  }

  // Handle punkte-template parameter
  if punkte-template != none {
    if type(punkte-template) == function {
      // Beide Templates gleich setzen
      set-options((
        punkte-template-aufgabe: punkte-template,
        punkte-template-teilaufgabe: punkte-template,
      ))
    } else if type(punkte-template) == dictionary {
      // Individuell setzen
      let opts-update = (:)
      if "aufgabe" in punkte-template.keys() {
        opts-update.insert("punkte-template-aufgabe", punkte-template.aufgabe)
      }
      if "teilaufgabe" in punkte-template.keys() {
        opts-update.insert("punkte-template-teilaufgabe", punkte-template.teilaufgabe)
      }
      if opts-update.keys().len() > 0 {
        set-options(opts-update)
      }
    }
  }

  show: arbeitsblatt-einzeln.with(
    title: title,
    print: true,
    header-ascent: kopf-abstand,
    custom-header: header(
      title: title,
      subtitle: subtitle,
      date: date,
      class: class,
      teacher: teacher,
      logo: logo,
    ),
    page-settings: final-page-settings,
    scope: scope,
    ..(
      args.named()
        + if variante == "loesung" { (loesungen: "nur") } else { (:) }
    ),
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

    if not name-repeat {
      if name-field != none {
        text(14pt, weight: "semibold")[#name-field: #h(0.25em) #student]
        v(14pt, weak: true)
      }
    }

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
  } else if not name-repeat {
    if name-field != none {
      name-field-block
      v(-3pt)
      line(length: 100%, stroke: 0.5pt + luma(200))
      v(6pt)
    }
  }

  body

  // Lösungsdokument: restliche Lösungen VOR dem Erwartungshorizont ausgeben
  // (idempotent, die Ausgabe am Dokumentende zeigt sie nicht erneut)
  context if variante == "loesung" {
    show-offene-loesungen()
  }

  // Setze das Label mit der fixierten Klassenarbeit-ID
  [#metadata("ende-des-dokuments") #ka-label]

  // Erwartungshorizont: im Bundle nur im Lösungsdokument, im Einzelmodus
  // wie bisher am Ende des Dokuments. Der Scope-State erkennt auch
  // verschachtelte KAs innerhalb eines Bundle-Varianten-Dokuments.
  context if erwartungen == true and (variante == "loesung" or _state_ab_scope.get() == none) {
    show-erwartungen(new-page: true)
  }
}

/// Erstellt eine Klassenarbeit (Klausur/Test).
///
/// Beim Bundle-Export (Typst 0.15+, `typst compile --features bundle
/// --format bundle`) erzeugt ein Aufruf automatisch mehrere Dateien:
///
/// - `{Name}.pdf` – die Klassenarbeit selbst (Druckfassung)
/// - `{Name} - Lösung.pdf` – Lösungen inline plus Erwartungshorizont
/// - `{Name} - Klausurbögen.pdf` – nur wenn `klausurboegen` aktiviert ist:
///   ohne `ergebnisse` EIN leerer Bogen, mit `ergebnisse` (CSV-Zeilen) ein
///   ausgefüllter Bogen pro Schüler. Klausurbögen sind NIE Teil der
///   Klassenarbeits-Datei selbst.
///
/// `{Name}` ist `dateiname` bzw. der `title`. Außerhalb des Bundles entsteht
/// genau ein Dokument; über `variante:` kann dann gewählt werden, welches.
///
/// - title (string): Title of the exam.
/// - subtitle (string): Subtitle of the exam.
/// - class (string): Class designation.
/// - date (string): Date of the exam.
/// - logo (content): Logo to display in header.
/// - teacher (string): Teacher name.
/// - student (string): Student name.
/// - table (array): Additional info table rows.
/// - info-table (boolean): Whether to show info table with name.
/// - name-repeat (boolean): Whether to repeat the student name field in the page header on every page.
/// - erwartungen (boolean): Whether to show expectations/rubric (im Bundle: nur im Lösungsdokument).
/// - page-numbering (boolean, string): Page numbering mode:
///   - `true` or `"reset"`: Show page numbers, reset counter for each klassenarbeit (default).
///   - `"continuous"`: Show page numbers, continue numbering across multiple klassenarbeiten.
///   - `false`: No page numbers.
/// - klausurboegen (boolean, dictionary): Klausurbögen aktivieren. Als
///   Dictionary mit Einstellungen für `klausurbögen()`; der Schlüssel
///   `ergebnisse` (CSV-Zeilen inkl. Kopfzeile) erzeugt ausgefüllte Bögen.
/// - varianten (auto, array): Bundle-Varianten aus `"druck"`, `"loesung"`,
///   `"klausurboegen"`. `auto` → `("druck", "loesung")`, plus
///   `"klausurboegen"` falls `klausurboegen` aktiviert ist. Standard: `auto`.
/// - variante (auto, string): Nur außerhalb des Bundles: welche Variante das
///   einzelne Dokument zeigt (`"druck"`, `"loesung"` oder
///   `"klausurboegen"`). `auto` → `"druck"` (wie bisher). Standard: `auto`.
/// - dateiname (string, none): Basisname der Bundle-Dateien; Standard ist der
///   `title`. Bei mehreren Klassenarbeiten in einer Datei muss er eindeutig
///   sein. Standard: `none`.
/// - page-settings (dictionary): Additional page settings.
/// - punkte-template (function, dictionary): Template for BE (points) display. Can be a function for both aufgabe and teilaufgabe, or a dictionary with keys "aufgabe" and "teilaufgabe" for individual templates. Example: `punkte => [*#punkte BE*]` or `(aufgabe: punkte => [*#punkte BE*], teilaufgabe: punkte => [_(#punkte BE)_])`.
/// - ..args (any): Additional arguments passed to arbeitsblatt (e.g. font, math-font, font-size, figure-font-size, teilaufgabe-numbering, punkte, loesungen, materialien, etc.).
#let klassenarbeit(
  subtitle: "",
  date: "",
  logo: "angela",
  teacher: "",
  student: "",
  name-field: "Name",
  name-repeat: false,
  info-table: false,
  page-numbering: true,
  klausurboegen: false,
  erwartungen: true,
  punkte-template: none,
  varianten: auto,
  variante: auto,
  dateiname: none,
  ..args,
  body,
) = {
  // Counter ZUERST erhöhen, damit die ID korrekt ist
  _ka-counter.step()

  context {
    let ka-id = _ka-counter.get().first()
    let title = args.named().at("title", default: "")
    let class = args.named().at("class", default: "")

    let gemeinsam = (
      ka-id: ka-id,
      subtitle: subtitle,
      date: date,
      logo: logo,
      teacher: teacher,
      student: student,
      name-field: name-field,
      name-repeat: name-repeat,
      info-table: info-table,
      page-numbering: page-numbering,
      erwartungen: erwartungen,
      punkte-template: punkte-template,
    ) + args.named()

    let boegen-einstellungen = if type(klausurboegen) == dictionary { klausurboegen } else { (:) }
    let boegen-aktiv = (
      klausurboegen != false
        and (type(klausurboegen) != dictionary or klausurboegen.at("show", default: true) == true)
    )

    if target() == "bundle" {
      let basisname = if dateiname != none {
        dateiname
      } else if type(title) == str and title != "" {
        title
      } else {
        "Klassenarbeit " + str(ka-id)
      }

      let liste = if varianten == auto {
        ("druck", "loesung")
      } else if type(varianten) == str {
        (varianten,)
      } else {
        varianten
      }
      if boegen-aktiv and "klausurboegen" not in liste {
        liste = liste + ("klausurboegen",)
      }

      for name in liste {
        if name == "druck" {
          document(
            basisname + ".pdf",
            ..if title not in ("", none) { (title: [#title]) },
            _klassenarbeit-einzeln(
              variante: "druck",
              scope: "ka-" + str(ka-id) + "-druck",
              ..gemeinsam,
              body,
            ),
          )
        } else if name == "loesung" {
          document(
            basisname + " - Lösung.pdf",
            title: [#title – Lösung],
            _klassenarbeit-einzeln(
              variante: "loesung",
              scope: "ka-" + str(ka-id) + "-loesung",
              ..gemeinsam,
              body,
            ),
          )
        } else if name == "klausurboegen" {
          document(
            basisname + " - Klausurbögen.pdf",
            title: [#title – Klausurbögen],
            _klausurboegen-inhalt(
              title: title,
              subtitle: subtitle,
              teacher: teacher,
              class: class,
              date: date,
              einstellungen: boegen-einstellungen,
            ),
          )
        } else {
          panic("Unbekannte Klassenarbeit-Variante: " + repr(name))
        }
      }
    } else {
      // Variante bestimmen: explizit > vom umgebenden Varianten-Dokument
      // geerbt (verschachtelte KA im Bundle) > "druck"
      let geerbt = _state_ka_variante.get()
      let v = if variante != auto {
        variante
      } else if geerbt != none {
        geerbt
      } else {
        "druck"
      }
      if v == "klausurboegen" {
        _klausurboegen-inhalt(
          title: title,
          subtitle: subtitle,
          teacher: teacher,
          class: class,
          date: date,
          einstellungen: boegen-einstellungen,
        )
      } else if v in ("druck", "loesung") {
        _klassenarbeit-einzeln(variante: v, scope: none, ..gemeinsam, body)
      } else {
        panic("Unbekannte Klassenarbeit-Variante: " + repr(v))
      }
    }
  }
}
