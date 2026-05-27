#import "@preview/unify:0.7.0": *

/// Setzt globale Gutachten-Metadaten (Fach, Niveau, Lehrkraft-Kürzel usw.).
///
/// Speichert die Metadaten in einem Typst-State, der von den Gutachten-Funktionen
/// ausgelesen wird. Muss vor dem ersten `#gutachten`-Aufruf gesetzt werden.
///
/// ```typ
/// #set-gutachten-infos(fach: "Mathematik", niveau: "E", kürzel: "SLZ")
/// ```
///
/// - fach (string): Fachname der Prüfung. Standard: `""`.
/// - niveau (string): Kursniveau, z. B. `"E"` (erhöht) oder `"G"` (grundlegend). Standard: `""`.
/// - kürzel (string): Kürzel der Lehrkraft. Standard: `""`.
/// - anonym (bool): Anonymisiert die Namensanzeige im Dokument. Standard: `false`.
/// - print (bool): Druckmodus (reduzierte Farben). Standard: `false`.
/// - be (int): Maximale Bewertungseinheiten. Standard: `1`.
/// - font (string): Hauptschriftart. Standard: `"New Computer Modern Sans"`.
/// - math-font (string): Schriftart für mathematische Formeln. Standard: `"Fira Math"`.
/// - jahr (int): Prüfungsjahr (Header-Angabe). Standard: aktuelles Jahr.
/// -> none
#let set-gutachten-infos(
  fach: "",
  niveau: "",
  kürzel: "",
  anonym: false,
  print: false,
  be: 1,
  font: "New Computer Modern Sans",
  math-font: "Fira Math",
  jahr: auto,
) = state("gutachten-infos").update((
  fach: fach,
  niveau: niveau,
  kürzel: kürzel,
  anonym: anonym,
  print: print,
  be: be,
  font: font,
  math-font: math-font,
  jahr: jahr,
))

#let _anonym-name-placeholder() = emph[#text(fill: black)[Schüler]]

#let _format-punkte-wert(punkte) = {
  if type(punkte) == int and punkte >= 0 and punkte < 10 {
    "0" + str(punkte).replace(".", ",")
  } else {
    str(punkte).replace(".", ",")
  }
}

#let name = context {
  let schüler = state("schüler").get()
  let anonym = state("gutachten-infos").final().anonym
  if anonym {
    _anonym-name-placeholder()
  } else {
    schüler.vorname
  }
}

/// Definiert die Aufgaben mit ihren maximalen Bewertungseinheiten.
///
/// Speichert das Aufgaben-Dictionary im State für spätere Auswertung.
///
/// ```typ
/// #set-aufgaben(("Aufgabe 1": (be: 30), "Aufgabe 2": (be: 20)))
/// ```
///
/// - aufgaben (dictionary): Dictionary der Form `("Aufgabe 1": (be: 30), ...)`.
/// -> none
#let set-aufgaben(aufgaben) = state("aufgaben").update(aufgaben)

/// Berechnet die Notenstufe anhand des erreichten Prozentsatzes (NRW-Abiturskala).
///
/// Gibt eine lesbare Zeichenkette mit Note und Punktzahl zurück.
///
/// ```typ
/// #bewertungsskala(0.75)  // "gut (11 Punkte)"
/// ```
///
/// - prozent (float): Erreichter Prozentsatz (0.0 bis 1.0).
/// -> string
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
    (prozent: 0.65, punkte: "befriedigend (09 Punkte)"),
    (prozent: 0.6, punkte: "befriedigend (08 Punkte)"),
    (prozent: 0.55, punkte: "befriedigend (07 Punkte)"),
    (prozent: 0.5, punkte: "ausreichend (06 Punkte)"),
    (prozent: 0.45, punkte: "ausreichend (05 Punkte)"),
    (prozent: 0.4, punkte: "ausreichend (04 Punkte)"),
    (prozent: 0.33, punkte: "mangelhaft (03 Punkte)"),
    (prozent: 0.27, punkte: "mangelhaft (02 Punkte)"),
    (prozent: 0.2, punkte: "mangelhaft (01 Punkt)"),
    (prozent: 0.0, punkte: "ungenügend (00 Punkte)"),
  )
  let index = 0
  while index < skala.len() {
    if prozent >= skala.at(index).prozent {
      return skala.at(index).punkte
    }
    index += 1
  }
}

/// Rendert eine Aufgabe mit automatischem Punktetracking.
///
/// Gibt eine Aufgabenüberschrift aus und verfolgt die erreichten Punkte
/// des Schülers im internen State.
///
/// ```typ
/// #aufgabe("Aufgabe 1", 24)[Kommentar zur Aufgabe]
/// ```
///
/// - name (string): Aufgabenname (muss mit einem Schlüssel in `set-aufgaben` übereinstimmen).
/// - punkte (int): Erreichte Punkte des Schülers.
/// - body (content): Inhalt der Aufgabe (Korrekturen, Anmerkungen).
/// -> content
#let aufgabe(name, punkte, body) = [
  = #name

  #body

  #context par[
    #let schüler = state("schüler").get()
    #let anonym = state("gutachten-infos").final().anonym
    #let schüler-anzeige = if anonym {
      _anonym-name-placeholder()
    } else {
      schüler.at("vorname")
    }
    #let be = state("aufgaben").get().at(name).be
    #state("punkte").update(i => { punkte + i })
    In #name erreicht #schüler-anzeige insgesamt *#_format-punkte-wert(punkte)* von *#_format-punkte-wert(be)* Bewertungseinheiten.
  ]
]

/// Erstellt ein vollständiges Gutachten für einen Schüler.
///
/// Richtet Seitenlayout, Kopfzeile mit Logo und Unterschriftszeile ein.
/// Wertet die Punkte aus allen `#aufgabe`-Aufrufen automatisch aus.
///
/// ```typ
/// #gutachten(vorname: "Max", nachname: "Mustermann")[
///   #aufgabe("Aufgabe 1", 24)[...]
/// ]
/// ```
///
/// - vorname (string): Vorname des Schülers. Standard: `"Max"`.
/// - nachname (string): Nachname des Schülers. Standard: `"Mustermann"`.
/// - wahl (array): Themenwahl (optional, z. B. `("A1", "B2")`). Standard: `()`.
/// - body (content): Aufgaben-Inhalte (`aufgabe()`-Aufrufe).
/// -> content
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
    #let anonym = gutachten-infos.anonym
    #let vorname-anzeige = if anonym { _anonym-name-placeholder() } else { vorname }
    #let voller-name = if anonym {
      _anonym-name-placeholder()
    } else {
      emph[#vorname #nachname]
    }

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
          [Gutachten über die schriftliche Prüfung von \ #voller-name],
          [Abitur #if gutachten-infos.jahr == auto { int(datetime.today().display("[year]")) } else { gutachten-infos.jahr } \ #gutachten-infos.fach (#gutachten-infos.niveau) - #gutachten-infos.kürzel],
        )
        #v(-3mm)
        #line(length: 100%, stroke: 1.5pt)
      ],
    )


    #if wahl.len() > 0 [
      #context [
        #vorname-anzeige wählt #if type(wahl) == array {
          wahl.map(
            a => {
              let aufgaben-eintrag = state("aufgaben").get().at(a, default: (name: ""))
              let aufgaben-name = if type(aufgaben-eintrag) == dictionary {
                aufgaben-eintrag.at("name", default: "")
              } else {
                ""
              }
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
                  let aufgaben-eintrag = state("aufgaben").get().at(a, default: (name: ""))
                  let aufgaben-name = if type(aufgaben-eintrag) == dictionary {
                    aufgaben-eintrag.at("name", default: "")
                  } else {
                    ""
                  }
                  emph[#a#if aufgaben-name != "" [: #aufgaben-name]]
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
        #let print = state("gutachten-infos").final().print

        #v(1em)

        Insgesamt erreicht der Prüfling *#_format-punkte-wert(punkte)* von *#_format-punkte-wert(be)* Bewertungseinheiten ($#calc.round(100 * punkte / be, digits: 1)$%).\
        Daher bewerte ich die Arbeit mit\
        #align(center)[*#bewertungsskala(punkte / be)*.]

        #v(1cm)

        #grid(
          columns: (1fr, 5em, 1fr), rows: 1cm, row-gutter: 0.5em,
          [], [], if print { grid.cell(stroke: (bottom: 1pt), []) } else { grid.cell([#text(gray)[_Mit Korrektur und Bewertung einverstanden_]]) },
          grid.cell(stroke: (bottom: 1pt), []), [], grid.cell(stroke: (bottom: 1pt), []),
          text(9pt, [Ort, Datum, Unterschrift]), [], text(9pt, [Ort, Datum, Unterschrift])
        )
      ]
    ]
    //#label()
    #context [
      #let schüler = state("schüler").get()
      #label(schüler.vorname + "-" + schüler.nachname + "-pages")
    ]
  ]
]
