#import "@preview/fontawesome:0.6.0": *
#import "@preview/gentle-clues:1.2.0": *

// States
#let _state_aufgaben = state("aufgaben", ())
#let _state_current_material_aufgabe = state("current_material_aufgabe", 0)
#let _state_current_material_index = state("current_material_index", 0)
#let _state_in_loesung = state("in_loesung", false)
#let _state_current_aufgabe_index = state("current_aufgabe_index", -1)
#let _state_options = state(
  "options",
  (
    loesungen: "keine", //
    materialien: "seiten", // "keine", "sofort", "folgend", "seiten"
    workspaces: true,
    teilaufgabe-numbering: "a)",
    punkte: "aufgaben", // "keine", "aufgaben", "teilaufgaben", "alle", "keine-summe" oder Dictionary
    punkte-position: "ende", // "ende", "rand" (nur für Teilaufgaben relevant)
    punkte-template-aufgabe: punkte => [*#punkte BE*],
    punkte-template-teilaufgabe: punkte => [*[#punkte BE]*],
  ),
)

// Hilfsfunktion: Extrahiert punkte-anzeige aus opts.punkte (String oder Dictionary)
#let get-punkte-anzeige(opts) = {
  if type(opts.punkte) == dictionary {
    opts.punkte.at("anzeige", default: "aufgaben")
  } else {
    opts.punkte
  }
}

// Hilfsfunktion: Extrahiert punkte-position aus opts (aus Dictionary oder separat)
#let get-punkte-position(opts) = {
  if type(opts.punkte) == dictionary {
    opts.punkte.at("position", default: opts.at("punkte-position", default: "ende"))
  } else {
    opts.at("punkte-position", default: "ende")
  }
}
// Formatierungsfunktion für BE-Anzeige
#let format-punkte(teil: false, points) = {
  let opts = _state_options.get()
  let tpl = if teil == true {
    opts.punkte-template-teilaufgabe
  } else {
    opts.punkte-template-aufgabe
  }
  // Call the template function with points
  tpl(points)
}

// Counter
#let _counter_aufgaben = counter("aufgaben")

// Options management
/// Aktualisiert die globalen Optionen des Pakets.
///
/// Einzelne oder mehrere Optionen können als Dictionary übergeben werden.
/// Bereits gesetzte Optionen bleiben erhalten.
///
/// ```typ
/// #set-options((loesungen: "sofort"))
/// #set-options((punkte: "alle", workspaces: false))
/// ```
///
/// - options (dictionary): Dictionary mit zu ändernden Optionspaaren
/// -> none
#let set-options(options) = {
  _state_options.update(curr => {
    curr + options
  })
}

#let show-loesung(aufg, teil: false) = {
  context {
    let opts = _state_options.get()

    if teil == false and aufg.loesung.len() > 0 {
      _state_in_loesung.update(true)
      goal(
        title: [Lösung #{ aufg.nummer } #if (aufg.title != none and aufg.title != []) [-- #{ aufg.title } ]],
        accent-color: gray,
        breakable: true,
        {
          // Main solutions
          for l in aufg.loesung.filter(l => l.teil == 0) {
            l.body
          }

          // Sub-solutions
          if aufg.teile > 0 {
            let grouped = (:)
            for l in aufg.loesung.filter(l => l.teil > 0).sorted(key: l => l.teil) {
              let teil-key = str(l.teil)
              if teil-key not in grouped.keys() {
                grouped.insert(teil-key, ())
              }
              grouped.at(teil-key).push(l.body)
            }

            enum(
              numbering: if opts.teilaufgabe-numbering == "a)" { "a)" } else { n => numbering("1.1", aufg.nummer, n) },
              tight: false,
              ..grouped
                .pairs()
                .map(pair => {
                  let (teil, bodies) = pair
                  enum.item(int(teil), stack(spacing: 0.5em, ..bodies))
                }),
            )
          }
        },
      )
      _state_in_loesung.update(false)
    } else if aufg.loesung.filter(l => l.teil == teil).len() > 0 {
      _state_in_loesung.update(true)
      // Sub-solutions
      let loesung-bodies = aufg.loesung.filter(l => l.teil == teil).map(l => l.body)
      let teil-label = if opts.teilaufgabe-numbering == "a)" {
        numbering("a)", teil)
      } else {
        numbering("1.1", aufg.nummer, teil)
      }
      goal(
        breakable: true,
        title: [Lösung #if teil == 0 { { aufg.nummer } } else { teil-label }],
        accent-color: gray,
        stack(spacing: 0.5em, ..loesung-bodies),
      )
      _state_in_loesung.update(false)
    }
  }
}

// Zeigt Lösungen inline (ohne Goalbox), formatiert wie Aufgaben
#let show-loesung-inline(aufg) = {
  context {
    let opts = _state_options.get()
    if aufg.loesung.len() == 0 { return }

    block(
      width: 100%,
      above: 1.8em,
      below: 1em,
      spacing: 0pt,
      text(weight: "bold", size: 1.4em, [
        Lösung #{ aufg.nummer }
        #if aufg.title != none and aufg.title != [] [ $-$ #{ aufg.title }]
      ]),
    )

    // Hauptlösung (teil == 0)
    for l in aufg.loesung.filter(l => l.teil == 0) {
      l.body
    }

    // Teilaufgaben-Lösungen als Aufzählung
    if aufg.teile > 0 {
      let teil-loesungen = aufg.loesung.filter(l => l.teil > 0)
      if teil-loesungen.len() > 0 {
        let grouped = (:)
        for l in teil-loesungen.sorted(key: l => l.teil) {
          let teil-key = str(l.teil)
          if teil-key not in grouped.keys() {
            grouped.insert(teil-key, ())
          }
          grouped.at(teil-key).push(l.body)
        }
        enum(
          numbering: if opts.teilaufgabe-numbering == "a)" { "a)" } else { n => numbering("1.1", aufg.nummer, n) },
          tight: false,
          ..grouped
            .pairs()
            .map(pair => {
              let (teil, bodies) = pair
              enum.item(int(teil), stack(spacing: 0.5em, ..bodies))
            }),
        )
      }
    }
    v(1cm, weak: true)
  }
}

/// Gibt Lösungen aus, die zuvor mit `loesung()` registriert wurden.
///
/// Wird automatisch aufgerufen, wenn `loesungen` auf `"folgend"`, `"seite"` oder
/// `"seiten"` gesetzt ist. Kann auch manuell aufgerufen werden.
///
/// - curr (boolean): Wenn `true`, wird nur die Lösung der zuletzt erstellten Aufgabe angezeigt. Default: `false`
/// - teil (boolean): Wenn eine Zahl, werden nur Lösungen der angegebenen Teilaufgabe angezeigt. Default: `false`
/// - inline (boolean): Wenn `true`, werden Lösungen ohne Goalbox direkt wie Aufgaben formatiert. Default: `false`
/// -> content
#let show-loesungen(curr: false, teil: false, inline: false) = {
  context {
    let all = _state_aufgaben.get()
    if curr { all = (all.last(),) }

    if not inline and _state_options.get().loesungen == "seite" {
      pagebreak(weak: true)
    }
    for aufg in all {
      if aufg.loesung.len() > 0 {
        if inline {
          show-loesung-inline(aufg)
        } else if _state_options.get().loesungen == "seiten" {
          page(show-loesung(aufg, teil: teil))
        } else if _state_options.get().loesungen in ("sofort", "folgend") {
          show-loesung(aufg, teil: teil)
        } else {
          show-loesung(aufg, teil: teil)
        }
      }
    }
  }
}

// Helper functions
/// Gibt die Gesamtpunktzahl einer Aufgabe oder Teilaufgabe zurück.
///
/// Muss in einem `context`-Block aufgerufen werden, da es auf den finalen
/// Dokumentzustand zugreift.
///
/// ```typ
/// #context [Aufgabe 1 hat #get-points(1) Punkte.]
/// #context [Teilaufgabe 2a hat #get-points(2, teil: 1) Punkte.]
/// ```
///
/// - aufg (integer): Aufgabennummer (1-basiert)
/// - teil (integer): Teilaufgabennummer (1-basiert); `none` für Gesamtpunkte der Aufgabe. Default: `none`
/// -> integer
#let get-points(aufg, teil: none, idx: none) = {
  let all = _state_aufgaben.final()
  let current = if idx != none {
    if idx < 0 or idx >= all.len() { return 0 }
    all.at(idx)
  } else {
    if aufg == none or aufg > all.len() { return 0 }
    all.at(aufg - 1)
  }
  if not "erwartungen" in current { return 0 }

  let erw = current.erwartungen
  if teil != none {
    erw = erw.filter(e => e.teil == teil)
  }

  return erw.fold(0, (sum, e) => sum + e.punkte)
}

/// Zeigt den Erwartungshorizont als formatierte Tabelle an.
///
/// Listet alle Erwartungen mit Teilaufgabenzuordnung und Punktzahlen auf.
/// Am Ende wird eine Zeile mit der Gesamtpunktzahl angezeigt.
///
/// - grouped (boolean): Wenn `true`, werden alle Erwartungen einer Teilaufgabe in einer Zeile zusammengefasst. Default: `false`
/// - new-page (boolean): Wenn `true`, wird der Erwartungshorizont auf einer neuen Seite gestartet. Default: `false`
/// - erreicht (boolean): Wenn `true`, wird `__ / X` statt `X` angezeigt (für eintragbare Punktzahlen). Default: `false`
/// -> content
#let show-erwartungen(grouped: false, new-page: false, erreicht: false) = {
  context {
    let all = _state_aufgaben.final()
    let opts = _state_options.get()

    // Erstelle Tabellenzeilen
    let rows = ()
    // Gesamtsumme über alle Aufgaben sammeln
    let gesamt-punkte = 0

    for aufg in all {
      if "erwartungen" in aufg and aufg.erwartungen.len() > 0 {
        // Hauptzeile für die Aufgabe
        let aufg-title = if aufg.title != none and aufg.title != [] {
          aufg.title
        } else {
          []
        }
        let aufg-punkte = aufg.erwartungen.fold(0, (sum, e) => sum + e.punkte)
        // Zur Gesamtsumme addieren
        gesamt-punkte += aufg-punkte

        // Prüfe ob Kompaktmodus (kein Titel und keine echten Teilaufgaben)
        let kompakt = aufg-title == [] and aufg.teile <= 1

        // Nur Kopfzeile hinzufügen wenn NICHT im Kompaktmodus
        if not kompakt {
          // Dickere obere Linie für jede neue Aufgabe
          // Graue erste und letzte Spalte, weiße mittlere Spalte
          let stroke-aufg = (left: 0.5pt, right: 0.5pt, top: 1pt, bottom: 0.5pt)
          rows.push(table.cell(fill: gray.lighten(70%), stroke: stroke-aufg, strong[#aufg.nummer]))
          rows.push(table.cell(stroke: stroke-aufg, strong[#if aufg-title != [] [#aufg-title]]))
          rows.push(table.cell(fill: gray.lighten(70%), stroke: stroke-aufg, strong[#if erreicht {[#h(1em) / #aufg-punkte]} else {[$#aufg-punkte$]}]))
        }

        // Zeilen für Teilaufgaben/Erwartungen
        let grouped-erw = (:)
        for erw in aufg.erwartungen.sorted(key: e => e.teil) {
          let teil-key = str(erw.teil)
          if teil-key not in grouped-erw.keys() {
            grouped-erw.insert(teil-key, ())
          }
          grouped-erw.at(teil-key).push(erw)
        }

        for (teil-str, erwartungen) in grouped-erw.pairs().sorted(key: pair => int(pair.at(0))) {
          let teil = int(teil-str)
          let teil-label = if teil == 0 {
            // Im Kompaktmodus: Aufgabennummer statt leer
            if kompakt { strong[#aufg.nummer] } else { [] }
          } else if opts.teilaufgabe-numbering == "a)" {
            numbering("a)", teil)
          } else {
            numbering("1.1", aufg.nummer, teil)
          }

          if grouped {
            // Grouped: Eine Zeile pro Teilaufgabe mit allen Erwartungen zusammengefasst
            // Inhalte als Stack mit kleinem Abstand, damit ausreichend vertikaler Raum entsteht
            let inhalt = stack(spacing: 2 * 6pt, ..erwartungen.map(e => e.text))
            let punkte = erwartungen.fold(0, (sum, e) => sum + e.punkte)

            // Konsistente Zellformatierung wie im ungrouped-Zweig: überall table.cell verwenden
            // und ein einheitliches inset setzen, damit die Zeile nicht „zusammengedrückt" wirkt
            let inset = (y: 6pt)

            // Im Kompaktmodus (teil == 0): graue erste und letzte Spalte + dickere obere Linie
            if kompakt and teil == 0 {
              let stroke-top = (left: 0.5pt, right: 0.5pt, top: 1pt, bottom: 0.5pt)
              rows.push(table.cell(align: top, inset: inset, stroke: stroke-top, fill: gray.lighten(70%), teil-label))
              rows.push(table.cell(align: left, inset: inset, stroke: stroke-top, inhalt))
              rows.push(table.cell(align: center, inset: inset, stroke: stroke-top, fill: gray.lighten(70%), strong[#if erreicht {[#h(1em) / #punkte]} else {[$str(punkte)$]}]))
            } else {
              rows.push(table.cell(align: top, inset: inset, teil-label))
              rows.push(table.cell(align: left, inset: inset, inhalt))
              rows.push(table.cell(align: center, inset: inset, if erreicht {[#h(1em) / #punkte]} else {[$str(punkte)$]}))
            }
          } else {
            // Ungrouped: Eine Zeile pro Erwartung
            for (idx, erw) in erwartungen.enumerate() {
              let show-label = if idx == 0 { teil-label } else { [] }

              // Basis-Stroke
              let stroke-override = if idx == 0 {
                (left: 0.5pt, right: 0.5pt, top: 0.5pt, bottom: none)
              } else if idx < erwartungen.len() - 1 {
                // Keine untere Linie zwischen Erwartungen derselben Teilaufgabe
                (left: 0.5pt, right: 0.5pt, top: none, bottom: none)
              } else if idx == erwartungen.len() - 1 {
                // Keine untere Linie zwischen Erwartungen derselben Teilaufgabe
                (left: 0.5pt, right: 0.5pt, top: none, bottom: 0.5pt)
              } else {
                0.5pt
              }

              // Einheitlicher, etwas größerer vertikaler Innenabstand für alle Zeilen
              let inset = (y: 6pt)

              // Im Kompaktmodus (teil == 0 und erste Erwartung): dickere obere Linie + graue erste/letzte Spalte
              if kompakt and teil == 0 and idx == 0 {
                stroke-override = (left: 0.5pt, right: 0.5pt, top: 1pt, bottom: none)
                rows.push(table.cell(align: top, stroke: stroke-override, inset: inset, fill: gray.lighten(70%), show-label))
                rows.push(table.cell(align: top + left, stroke: stroke-override, inset: inset, erw.text))
                rows.push(table.cell(align: top + center, stroke: stroke-override, inset: inset, fill: gray.lighten(70%), strong[#if erreicht {[#h(1em) / #erw.punkte]} else {[$str(erw.punkte)$]}]))
              } else if kompakt and teil == 0 {
                // Weitere Erwartungen im Kompaktmodus: nur graue Spalten
                rows.push(table.cell(align: top, stroke: stroke-override, inset: inset, fill: gray.lighten(70%), show-label))
                rows.push(table.cell(align: top + left, stroke: stroke-override, inset: inset, erw.text))
                rows.push(table.cell(align: top + center, stroke: stroke-override, inset: inset, fill: gray.lighten(70%), strong[#if erreicht {[#h(1em) / #erw.punkte]} else {[$str(erw.punkte)$]}]))
              } else {
                // Normal: keine besonderen Formatierungen
                rows.push(table.cell(align: top, stroke: stroke-override, inset: inset, show-label))
                rows.push(table.cell(align: top + left, stroke: stroke-override, inset: inset, erw.text))
                rows.push(table.cell(align: top + center, stroke: stroke-override, inset: inset, if erreicht {[#h(1em) / #erw.punkte]} else {[$str(erw.punkte)$]}))
              }
            }
          }
        }
      }
    }

    // Schlusszeile mit Gesamtsumme der Punkte hinzufügen (nur wenn es überhaupt Zeilen gibt)
    if rows.len() > 0 {
      let stroke-summe = (left: 0.5pt, right: 0.5pt, top: 1pt, bottom: 0.5pt)
      rows.push(table.cell(fill: gray.lighten(70%), stroke: stroke-summe, strong[$Sigma$]))
      rows.push(table.cell(stroke: stroke-summe, strong[Summe]))
      rows.push(table.cell(fill: gray.lighten(70%), stroke: stroke-summe, strong[#if erreicht {[#h(1em) / #gesamt-punkte]} else {[#gesamt-punkte]}]))
    }

    if rows.len() > 0 {
      let element = if new-page { page } else { block }
      element[
        #block(text(size: 1.25em, weight: "bold")[Erwartungshorizont])
        #table(
          columns: (auto, 1fr, auto),
          align: (center + horizon, left + horizon, center + horizon),
          inset: 8pt,
          stroke: 0.5pt,
          table.header(strong[Nr.], strong[Inhalt], strong[BE]),
          ..rows,
        )
      ]
    }
  }
}

/// Zeigt eine Bewertungstabelle mit Aufgaben- und Teilaufgabenspalten an.
///
/// Das erste Positionsargument steuert die Anzeige der möglichen Punkte:
/// `true` = mit möglichen Punkten (Standard), `false` = leere Felder, `none` = nur erreichte-Punkte-Zeile.
///
/// - ..args (any): Optionales erstes Positionsargument: `true`, `false` oder `none` für Punkte-Anzeige
/// - compact (boolean): Kompaktere Darstellung mit kleinerem Text und schmaleren Zeilen. Default: `false`
/// - full (boolean): Zeigt zusätzliche Gesamtspalte pro Aufgabe bei Aufgaben mit Teilaufgaben. Default: `false`
/// -> content
#let show-bewertung(..args, compact: false, full: false) = {
  let pos-args = args.pos()
  let punkte = true
  if pos-args.len() == 1 {
    punkte = pos-args.at(0)
  }
  context {
    let all = _state_aufgaben.final()
    let opts = _state_options.get()

    if all.len() == 0 { return }

    // Konfiguration
    let thick-stroke = 1pt  // Dicker Strich zwischen Spaltengruppen
    
    // Erstelle Header-Zeilen und Spalten
    let text-size = if compact { 0.9em } else { 1em }
    let row-height = if compact { 0.9cm } else { 1cm }
    let header-row1 = (table.cell(rowspan: 2, fill: gray.lighten(70%), text(if compact { 0.8 * text-size } else { text-size }, strong[Aufgabe])),)
    let header-row2 = ()
    let columns = (auto,)

    // Zeile für "mögliche Punkte"
    let moegliche-punkte-row = (table.cell(fill: gray.lighten(70%), text(if compact { 0.65em } else { 0.9em }, strong(if compact { "mögl. \nPunkte" } else { "mögliche Punkte" }))),)
    // Zeile für "erreichte Punkte"
    let erreichte-punkte-row = (table.cell(fill: gray.lighten(70%), text(if compact { 0.65em } else { 0.9em }, strong(if compact { "Punkte" } else { "erreichte Punkte" }))),)

    let gesamt-punkte = 0
    let cell-width = auto

    for aufg in all {
      let aufg-punkte = if "erwartungen" in aufg { aufg.erwartungen.fold(0, (sum, e) => sum + e.punkte) } else { 0 }
      gesamt-punkte += aufg-punkte

      // Gruppiere Erwartungen nach Teilaufgaben
      let grouped-erw = (:)
      if "erwartungen" in aufg {
        for erw in aufg.erwartungen.sorted(key: e => e.teil) {
          let teil-key = str(erw.teil)
          if teil-key not in grouped-erw.keys() {
            grouped-erw.insert(teil-key, ())
          }
          grouped-erw.at(teil-key).push(erw)
        }
      }

      // Prüfe, ob es echte Teilaufgaben gibt (basierend auf aufg.teile)
      // Zusätzliche Absicherung: Prüfe, ob es tatsächlich Erwartungen mit teil > 0 gibt
      // (behebt Timing-Problem bei der letzten Aufgabe)
      let hat-teilaufgaben = aufg.teile > 0 and aufg.teile != none
      if hat-teilaufgaben and grouped-erw.keys().filter(k => k != "0").len() == 0 {
        hat-teilaufgaben = false
      }

      // Wenn keine Teilaufgaben vorhanden: Erstelle trotzdem eine Spalte für die Hauptaufgabe
      if not hat-teilaufgaben {
        let left-stroke = thick-stroke
        header-row1.push(table.cell(rowspan: 2, stroke: (left: left-stroke), fill: if full { gray.lighten(70%) } else { white }, inset: (x: 12pt, y: 8pt), text(text-size, strong[#aufg.nummer])))

        // Hole Punkte für die Hauptaufgabe (teil == 0)
        let teil-punkte = if "0" in grouped-erw.keys() {
          grouped-erw.at("0").fold(0, (sum, e) => sum + e.punkte)
        } else {
          0
        }

        // punkte: true => zeige Punkte, false => zeige leer, none => überspringe Zeile
        if punkte == true and teil-punkte > 0 {
          moegliche-punkte-row.push(table.cell(stroke: (left: left-stroke), fill: if full { gray.lighten(70%) } else { white }, text(text-size, if full { strong[#teil-punkte] } else { [#teil-punkte] })))
        } else if punkte == false {
          moegliche-punkte-row.push(table.cell(stroke: (left: left-stroke), fill: if full { gray.lighten(70%) } else { white }, []))
        } else if punkte == true {
          moegliche-punkte-row.push(table.cell(stroke: (left: left-stroke), fill: if full { gray.lighten(70%) } else { white }, []))
        }
        erreichte-punkte-row.push(table.cell(stroke: (left: left-stroke), fill: if full { gray.lighten(70%) } else { white }, []))
        columns.push(cell-width)
        continue
      } else {
        // Hat Teilaufgaben: Erstelle Spalten für alle Teilaufgaben (1 bis aufg.teile)
        let colspan-value = if full { aufg.teile + 1 } else { aufg.teile }
        let left-stroke = thick-stroke
        header-row1.push(table.cell(stroke: (bottom: none, left: left-stroke), fill: if full { gray.lighten(70%) } else { white }, colspan: colspan-value, text(text-size, strong[#aufg.nummer])))

        // Wenn full: true, füge Gesamtpunkte-Spalte vor den Teilaufgaben ein
        if full {
          header-row2.push(table.cell(stroke: (top: none, left: left-stroke), fill: gray.lighten(70%), text(text-size, [])))
          if punkte == true {
            moegliche-punkte-row.push(table.cell(stroke: (left: left-stroke), fill: gray.lighten(70%), text(text-size, strong[$#aufg-punkte$])))
          } else if punkte == false {
            moegliche-punkte-row.push(table.cell(stroke: (left: left-stroke), fill: gray.lighten(70%), []))
          } else if punkte == true {
            moegliche-punkte-row.push(table.cell(stroke: (left: left-stroke), fill: gray.lighten(70%), []))
          }
          erreichte-punkte-row.push(table.cell(stroke: (left: left-stroke), fill: gray.lighten(70%), []))
          columns.push(cell-width)
        }

        // Iteriere über ALLE Teilaufgaben (nicht nur die mit Erwartungen)
        for teil-nr in range(1, aufg.teile + 1) {
          let teil-key = str(teil-nr)
          let teil-label = if opts.teilaufgabe-numbering == "a)" {
            numbering("a)", teil-nr)
          } else {
            numbering("1.1", aufg.nummer, teil-nr)
          }

          // Hole Punkte für diese Teilaufgabe (falls Erwartungen vorhanden)
          let teil-punkte = if teil-key in grouped-erw.keys() {
            grouped-erw.at(teil-key).fold(0, (sum, e) => sum + e.punkte)
          } else {
            0
          }

          // Setze linken Strich für die erste Teilaufgabe
          // Bei full: true nur normaler Strich (weil schon die Summen-Spalte den dicken Strich hat)
          let teil-left-stroke = if teil-nr == 1 and not full { left-stroke } else { 0.5pt }
          header-row2.push(table.cell(stroke: (left: teil-left-stroke), text(text-size, strong[#teil-label])))
          // punkte: true => zeige Punkte, false => zeige leer, none => überspringe Zeile
          if punkte == true and teil-punkte > 0 {
            moegliche-punkte-row.push(table.cell(stroke: (left: teil-left-stroke), text(text-size, [$#teil-punkte$])))
          } else if punkte == false {
            moegliche-punkte-row.push(table.cell(stroke: (left: teil-left-stroke), []))
          } else if punkte == true {
            moegliche-punkte-row.push(table.cell(stroke: (left: teil-left-stroke), []))
          }
          erreichte-punkte-row.push(table.cell(stroke: (left: teil-left-stroke), []))
          columns.push(cell-width)
        }
      }
    }

    // Summen-Spalte
    header-row1.push(table.cell(rowspan: 2, stroke: (left: thick-stroke), fill: gray.lighten(70%), text(text-size, strong[$Sigma$])))
    columns.push(if cell-width == auto { auto } else { 1.25 * cell-width })
    // punkte: true => zeige Gesamtpunkte, false => zeige leer, none => überspringe Zeile
    if punkte == true {
      moegliche-punkte-row.push(table.cell(stroke: (left: thick-stroke), fill: gray.lighten(70%), text(text-size, strong[#if gesamt-punkte > 0 [#gesamt-punkte]])))
    } else if punkte == false {
      moegliche-punkte-row.push(table.cell(stroke: (left: thick-stroke), fill: gray.lighten(70%), []))
    }
    erreichte-punkte-row.push(table.cell(stroke: (left: thick-stroke), fill: gray.lighten(70%), []))

    // Erstelle Tabelle mit oder ohne "mögliche Punkte" Zeile
    let table-inset = if compact { 5pt } else { 8pt }
    if punkte != none {
      table(
        columns: columns,
        rows: (auto, auto, row-height, row-height),
        align: center + horizon,
        inset: table-inset,
        stroke: 0.5pt,
        ..header-row1,
        ..header-row2,
        ..moegliche-punkte-row,
        ..erreichte-punkte-row,
      )
    } else {
      table(
        columns: columns,
        rows: (auto, auto, row-height, row-height),
        align: center + horizon,
        inset: table-inset,
        stroke: 0.5pt,
        ..header-row1,
        ..header-row2,
        ..erreichte-punkte-row,
      )
    }
  }
}

// Material system
#let show-material(aufg) = {
  if aufg.materialien.len() > 0 {
    // Set current aufgabe for material numbering
    _state_current_material_aufgabe.update(aufg.nummer)
    block(width: 100%, below: 1em, above: 1.5em, text(14pt, weight: "bold")[Material zu Aufgabe #aufg.nummer]) // Materialüberschrift
    for (index, m) in aufg.materialien.enumerate() {
      // Set current material index (1-based)
      _state_current_material_index.update(index + 1)
      m.body
    }
  }
}

/// Gibt Materialien aus, die zuvor mit `material()` registriert wurden.
///
/// Wird automatisch aufgerufen, wenn `materialien` auf `"sofort"` oder `"seiten"` gesetzt ist.
/// Kann auch manuell aufgerufen werden.
///
/// - curr (boolean): Wenn `true`, wird nur das Material der zuletzt erstellten Aufgabe angezeigt. Default: `false`
/// -> content
#let show-materialien(curr: false) = {
  context {
    let all = _state_aufgaben.get()
    if curr { all = (all.last(),) }
    if _state_options.final().materialien == "seite" {
      pagebreak(weak: true)
    }
    for aufg in all {
      if aufg.materialien.len() > 0 {
        if _state_options.final().materialien == "seiten" {
          page(show-material(aufg))
        } else {
          show-material(aufg)
        }
      }
    }
  }
}

/// Registriert ein Material und ordnet es der aktuellen Aufgabe zu.
///
/// Materialien werden automatisch mit M{Nr}-{Buchstabe} beschriftet (z. B. M1-A).
/// Der Anzeigemodus wird über `set-options((materialien: ...))` gesteuert.
///
/// - body (content): Inhalt des Materials
/// - caption (content): Beschriftung des Materials. Default: `none`
/// - label (label): Label zur Referenzierung mit `@`. Default: `none`
/// -> none
#let material(body, caption: none, label: none) = {
  let mat = [#figure(
      align(left, body),
      caption: caption,
      kind: "material",
      supplement: none,
    ) #if label != none { if type(label) == std.label { label } else { std.label(label) } }
    #v(-0.5em)
    #line(length: 100%, stroke: 0.5pt)
  ]
  context {
    _state_aufgaben.update(all => {
      if all.len() > 0 {
        all
          .at(-1)
          .materialien
          .push((
            body: mat,
          ))
      }
      all
    })
  }
}

// Main components
/// Erstellt eine nummerierte Aufgabe.
///
/// Die Aufgabe erhält automatisch eine fortlaufende Nummer. Als Positionsargumente
/// werden entweder nur der Rumpf (`body`) oder erst Titel dann Rumpf erwartet.
///
/// ```typ
/// #aufgabe[Berechne die Summe von 15 und 27.]
/// #aufgabe[Mein Titel][Aufgabentext hier]
/// #aufgabe(title: "Addition")[Berechne ...]
/// ```
///
/// - title (content): Titel der Aufgabe. Default: `none`
/// - method (string): Sozialform: `"EA"` (Einzelarbeit), `"PA"` (Partnerarbeit), `"GA"` (Gruppenarbeit). Default: `""`
/// - icons (array): Array mit zusätzlichen Icons (z. B. `(emoji.lightbulb,)`). Default: `()`
/// - large (boolean): Größere Überschrift (1.4em statt 1.2em). Default: `true`
/// - number (boolean): Aufgabennummer anzeigen. Default: `true`
/// - workspace (content): Optionaler Arbeitsbereich für Schülerantworten (z. B. `v(3cm)`). Default: `none`
/// - label (label): Label zur Referenzierung mit `@`. Default: `none`
/// - ..args (content): Pflicht-Positionsargumente: entweder `body` oder `title, body`
/// -> content
#let aufgabe(
  title: none,
  method: "",
  icons: (),
  large: true,
  number: true,
  workspace: none,
  label: none,
  ..args,
) = {
  // Parse positional arguments
  let pos-args = args.pos()
  let body = none
  let actual-title = title

  if pos-args.len() == 1 {
    // Single argument: body
    body = pos-args.at(0)
  } else if pos-args.len() == 2 {
    // Two arguments: title, body
    actual-title = pos-args.at(0)
    body = pos-args.at(1)
  } else {
    panic("aufgabe expects 1 or 2 positional arguments")
  }

  _counter_aufgaben.step()
  _counter_aufgaben.update(n => (n, 0)) // Reset sublevel to 0
  counter(figure.where(kind: "teilaufgabe")).update(0)

  // Icon handling
  let ic = ()
  if method == "EA" { ic.push(fa-user-large()) }
  if method == "PA" { ic.push(fa-user-group()) }
  if method == "GA" { ic.push(fa-users()) }
  ic += icons

  // Update state
  context {
    let ct_aufgaben = _counter_aufgaben.get().at(0)
    _state_aufgaben.update(all => {
      all.push((
        nummer: ct_aufgaben,
        title: actual-title,
        teile: 0,
        loesung: (),
        materialien: (),
        erwartungen: (),
      ))
      all
    })
    _state_current_aufgabe_index.update(i => i + 1)
  }

  if (actual-title != none and actual-title != []) or number {
    context {
      if _state_options.get().loesungen == "nur" { return }
      let auf-head = figure(
        kind: "aufgabe",
        supplement: none,
        gap: 0pt,
        text(
          weight: "bold",
          size: if large { 1.4em } else { 1.2em },
          [
            #let nums = _counter_aufgaben.get()
            #if ic.len() > 0 { ic.join() }
            #if number { "Aufgabe " + str(nums.first()) }
            #if number and (actual-title != none and actual-title != []) [ $-$ ]
            #if actual-title != none [#actual-title]
            #h(1fr)
            #let opts = _state_options.get()
            #if get-punkte-anzeige(opts) in ("aufgaben", "alle") {
              let points = get-points(none, idx: _state_current_aufgabe_index.get())
              if points > 0 {
                format-punkte(teil: false, points)
              }
            }
          ],
        ),
      )
      if label != none [
        #block(
          width: 100%,
          above: 1.8em,
          below: 1em,
          spacing: 0pt,
          [
            #auf-head
            #if type(label) == std.label { label } else { std.label(label) }
          ],
        )
      ] else [
        #block(
          width: 100%,
          above: 1.8em,
          below: 1em,
          spacing: 0pt,
          auf-head,
        )
      ]
    }
  }
  // Content - nur wenn body nicht leer ist
  // Im "nur"-Modus: body unsichtbar layouten, damit loesung()/erwartung() registriert werden
  context {
    if _state_options.get().loesungen == "nur" {
      if body != none and body != [] { place(hide(body)) }
    } else if body != none and body != [] {
      body
    }
  }
  // Workspace
  context if workspace != none and _state_options.get().workspaces and _state_options.get().loesungen != "nur" {
    block(width: 100%, inset: (x: 0em, y: 0.5em))[#workspace]
  }
  // "sofort" materials
  context if _state_options.final().materialien in ("sofort", "seiten", "folgend") and _state_aufgaben.get().last().materialien.len() > 0 and _state_options.final().loesungen != "nur" {
    if _state_options.final().materialien == "seiten" {
      pagebreak(weak: true)
    }
    show-materialien(curr: true)
  }
  // "sofort" solutions
  context if _state_options.final().loesungen == "sofort" {
    show-loesungen(curr: true, teil: 0)
  }
  // "folgend" solutions
  context if _state_options.final().loesungen == "folgend" {
    show-loesungen(curr: true)
  }
  // "nur" solutions: Lösungen inline ohne Goalbox anzeigen
  context if _state_options.final().loesungen == "nur" {
    show-loesungen(curr: true, inline: true)
  }
  // "keine-summe" mode: Zeige Punkte nur bei Aufgaben ohne Teilaufgaben
  context if get-punkte-anzeige(_state_options.get()) == "keine-summe" {
    let curr_idx = _state_current_aufgabe_index.get()
    let curr_aufg = _state_aufgaben.get().at(curr_idx)
    // Nur anzeigen, wenn es KEINE Teilaufgaben gibt
    if curr_aufg.teile == 0 {
      let points = get-points(none, idx: curr_idx)
      if points > 0 {
        block(text(weight: "bold", size: 1.4em, h(1fr) + format-punkte(teil: false, points)))
      }
    }
  }
  // Abstand nach der Aufgabe (nach allem: Workspace, Materialien, Lösungen)
  v(1cm, weak: true)
}

/// Erstellt eine Teilaufgabe innerhalb einer `aufgabe()`.
///
/// Teilaufgaben werden automatisch nach dem in `set-options((teilaufgabe-numbering: ...))` 
/// konfigurierten Schema nummeriert (Standard: `"a)"`).
///
/// - item-label (content): Benutzerdefinierte Beschriftung statt automatischer Nummerierung. Default: `none`
/// - label (label): Label zur Referenzierung mit `@`. Default: `none`
/// - workspace (content): Optionaler Arbeitsbereich für diese Teilaufgabe. Default: `none`
/// - body (content): Inhalt der Teilaufgabe
/// -> content
#let teilaufgabe(
  item-label: none,
  label: none,
  workspace: none,
  body,
) = {
  _counter_aufgaben.step(level: 2)
  
  // State-Update AUSSERHALB des context-Blocks
  context {
    _state_aufgaben.update(all => {
      if all.len() > 0 {
        all.at(-1).teile += 1
      }
      all
    })
  }
  
  // Rendering in separatem context-Block
  context {
    let curr_aufg = _counter_aufgaben.get().at(0)
    let curr_teil = _counter_aufgaben.get().at(1, default: 1)
    let curr_idx = _state_current_aufgabe_index.get()

    let opts = _state_options.get()
    // Inline-Berechnung für bessere Kompatibilität
    let punkte-anzeige = if type(opts.punkte) == dictionary {
      opts.punkte.at("anzeige", default: "aufgaben")
    } else {
      opts.punkte
    }
    let punkte-position = if type(opts.punkte) == dictionary {
      opts.punkte.at("position", default: opts.at("punkte-position", default: "ende"))
    } else {
      opts.at("punkte-position", default: "ende")
    }
    
    let ta-enum = enum(
      start: curr_teil,
      numbering: n => context [
        #if item-label != none {
          item-label
        } else {
          let opts = _state_options.get()
          if opts.teilaufgabe-numbering == "a)" {
            numbering("a)", n)
          } else if opts.teilaufgabe-numbering == "1." {
            numbering("1.1", curr_aufg, n)
          } else {
            numbering("a)", n) // Fallback
          }
        }
      ],
      {
        box(
          width: 100%,
          {
            align(left, {
              // Punkte am Rand (außerhalb des Dokuments, am rechten Seitenrand)
              if punkte-anzeige in ("teilaufgaben", "alle", "keine-summe") and punkte-position == "rand" {
                // Punkte werden am Ende des Dokuments berechnet und mit place am Rand platziert
                context {
                  let points = get-points(
                    none,
                    teil: _counter_aufgaben.get().at(1),
                    idx: curr_idx,
                  )
                  if points > 0 {
                    // Platziere Punkte am rechten Rand (außerhalb des Textbereichs), linksbündig
                    place(
                      right,
                      dx: 2mm, // In den rechten Rand hinein
                      box(
                        width: 0cm,
                        align(left, text(fill: black, size: 0.88em, hyphenate: false)[#box(width: 2cm, [#format-punkte(teil: true, points)])])
                      )
                    )
                  }
                }
                body
              } else if punkte-position == "rand" {
                // position ist "rand", aber keine Teilaufgaben-Punkte aktiviert -> nur body
                body
              } else {
                // position ist "ende" -> body wird hier gerendert
                body
              }
              // Punkte am Ende (Standard-Verhalten)
              if punkte-anzeige in ("teilaufgaben", "alle", "keine-summe") and punkte-position == "ende" {
                context {
                  let points = get-points(
                    none,
                    teil: _counter_aufgaben.get().at(1),
                    idx: curr_idx,
                  )
                  if points > 0 {
                    h(1fr)
                    box(
                      align(
                        top + right,
                        text(fill: black, size: 0.88em)[#format-punkte(teil: true, points)],
                      ),
                    )
                  }
                }
              }
              // Workspace
              if not workspace in (none, false) and opts.workspaces {
                workspace
              }
            })
          },
        )
      },
    )
    if label != none [
      #figure(kind: "teilaufgabe", supplement: "Teilaufgabe", ta-enum, numbering: "a)") #if type(label) == std.label { label } else { std.label(label) }
    ] else [
      #figure(kind: "teilaufgabe", supplement: "Teilaufgabe", ta-enum, numbering: "a)")
    ]
  }
  context if _state_options.final().loesungen == "sofort" {
    let curr_aufg = _counter_aufgaben.get().at(0)
    let curr_teil = if _counter_aufgaben.get().len() > 1 {
      _counter_aufgaben.get().at(1)
    } else { 0 }
    show-loesungen(curr: true, teil: curr_teil)
  }
}

/// Registriert eine Lösung für die aktuelle Aufgabe oder Teilaufgabe.
///
/// Die Lösung wird automatisch der zuletzt erstellten Aufgabe oder Teilaufgabe
/// zugeordnet. Der Anzeigemodus wird über `set-options((loesungen: ...))` gesteuert.
///
/// - body (content): Inhalt der Lösung
/// -> none
#let loesung(body) = {
  context {
    let curr_teil = if _counter_aufgaben.get().len() > 1 {
      _counter_aufgaben.get().at(1)
    } else { 0 }

    // Store solution
    _state_aufgaben.update(all => {
      if all.len() > 0 {
        all
          .at(-1)
          .loesung
          .push((
            teil: curr_teil,
            body: body,
          ))
      }
      all
    })
  }
}

/// Registriert eine Erwartung mit optionaler Punktzahl für die aktuelle Aufgabe oder Teilaufgabe.
///
/// Als Positionsargumente werden entweder nur der Beschreibungstext oder
/// erst die Punktzahl (int/float) dann der Beschreibungstext erwartet.
///
/// ```typ
/// #erwartung[Antwort ist nachvollziehbar begründet]
/// #erwartung(2)[Ergebnis korrekt berechnet]
/// ```
///
/// - ..args (any): Positionsargumente: optionale Punktzahl (integer oder float) + Beschreibungstext (content)
/// -> none
#let erwartung(..args) = {
  let pos-args = args.pos()
  let body = none
  let punkte = 0

  if pos-args.len() == 1 {
    // Single argument: body
    body = pos-args.at(0)
  } else if pos-args.len() == 2 {
    // Two arguments: title, body
    if type(pos-args.at(0)) in (int, float) {
      punkte = pos-args.at(0)
      body = pos-args.at(1)
    } else if type(pos-args.at(1)) in (int, float) {
      body = pos-args.at(0)
      punkte = pos-args.at(1)
    } else {
      panic("erwartung expects the second positional argument to be points (int or float)")
    }
  } else {
    panic("aufgabe expects 1 or 2 positional arguments")
  }
  context {
    let curr_teil = if _counter_aufgaben.get().len() > 1 {
      _counter_aufgaben.get().at(1)
    } else { 0 }

    _state_aufgaben.update(all => {
      if all.len() > 0 {
        all
          .at(-1)
          .erwartungen
          .push((
            teil: curr_teil,
            text: body,
            punkte: punkte,
          ))
      }
      all
    })
  }
}
