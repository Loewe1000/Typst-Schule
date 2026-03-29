#import "../../../schuldocs/0.1.0/lib.typ": show-example, show-module, show-code

= Über dieses Paket

Das `klausurboegen`-Paket erzeugt *personalisierte Klausurbögen* im A3-Querformat
für ganze Schulklassen auf einen Schlag. Für jede Schülerin / jeden Schüler wird
automatisch ein eigener Bogen mit Namen, Schuljahrgang, Lehrkraft, Datum und
(optional) einer Ergebnistabelle generiert.

Besonderheiten:

- A3 quer, kein Seitenrand (randlos für professionellen Druck).
- Personalisierte Kopfzeile mit Name, Klasse, Lehrkraft und Datum.
- Wahlweise kariertes oder liniertes Schreibfeld.
- Sek-I-Modus mit vereinfachtem Layout.
- Optionale Ergebnistabelle für Teilaufgaben.
- Benötigt die Schriftart *Myriad Pro*.
- Nutzt `@schule/patterns:0.0.1` für kariertes Papier.

= Schnellstart

#show-code[```typ
#import "@schule/klausurboegen:0.0.3": klausurbögen

#klausurbögen(
  exam: "Physik",
  subexam: "Schwingungen und Wellen",
  teacher: "Fr. Müller",
  class: "Q1",
  date: "15.05.2025",
  students: (
    "Anna Bauer",
    "Ben Fischer",
    "Clara Hoffmann",
    "David Klein",
    "Eva Lange",
  ),
)
```]

Es wird für jede Schülerin / jeden Schüler eine vollständige A3-Seite erzeugt.
Die Bögen können direkt an einen A3-Drucker übergeben werden.

= Varianten

== Sek-I-Modus

Für Klassen der Sekundarstufe I vereinfacht `sek1: true` das Layout:

#show-code[```typ
#klausurbögen(
  exam: "Mathematik",
  subexam: "Quadratische Gleichungen",
  teacher: "Hr. Schmid",
  class: "9b",
  date: "20.03.2025",
  students: ("Lena Braun", "Max Meier", "Nora Wolf"),
  sek1: true,   // Vereinfachtes Layout für Sekundarstufe I
)
```]

== Ergebnistabelle

Mit `result-table: true` wird eine Tabelle für Punkte pro Teilaufgabe eingefügt:

#show-code[```typ
#klausurbögen(
  exam: "Chemie",
  subexam: "Oxidation und Reduktion",
  teacher: "Fr. Koch",
  class: "11",
  date: "01.06.2025",
  students: ("Ali Demir", "Bea Horn"),
  result-table: true,   // Ergebnistabelle anzeigen
  sub: true,            // Teilaufgaben-Nummerierung aktivieren
  numbering: "a)",      // Nummerierungsformat für Teilaufgaben
)
```]

== Angepasste Linienfarbe

Standardmäßig werden die Korrekturlinien in Rot gezeichnet. Die Farbe ist konfigurierbar:

#show-code[```typ
#klausurbögen(
  exam: "Englisch",
  subexam: "Reading Comprehension",
  teacher: "Hr. Lang",
  class: "10a",
  date: "10.04.2025",
  students: ("Sara Fischer", "Tom Kern"),
  line-stroke: 1pt + blue,   // Blaue Korrekturlinien
)
```]

== Zufällige Aufgabenverteilung

Mit `rand: true` werden Aufgaben zufällig auf die Bögen verteilt (Varianten A/B):

#show-code[```typ
#klausurbögen(
  exam: "Mathematik",
  subexam: "Stochastik",
  teacher: "Fr. Bauer",
  class: "12",
  date: "25.01.2025",
  students: ("Anna Bauer", "Ben Fischer", "Clara Müller"),
  rand: 5cm,   // Breite der Aufgabenvariantenfelder
)
```]

= Parameter

#show-code[```typ
#klausurbögen(
  exam: "",            // str: Fachbezeichnung (z. B. "Physik")
  subexam: "",         // str: Thema / Klausurtitel
  teacher: "SLZ",      // str: Kürzel oder Name der Lehrkraft
  class: "PH1",        // str: Klassen-/Kursbezeichnung
  date: "09.10.2023",  // str: Datum im Format "TT.MM.JJJJ"
  students: (),        // array: Liste der Schülernamen (je ein Bogen pro Eintrag)
  sek1: false,         // bool: Sek-I-Modus (vereinfachtes Layout)
  result: false,       // bool: Ergebnisfeld anzeigen
  rand: 5cm,           // length: Breite des Zufallsaufgabenbereichs
  scale: 1,            // float: Skalierungsfaktor des gesamten Bogens
  sub: false,          // bool: Teilaufgaben-Felder aktivieren
  numbering: "a)",     // str: Nummerierungsformat für Teilaufgaben
  mv: (dx: 0cm, dy: 0cm),  // dict: Manuelle Verschiebung (Feinpositionierung)
  weißer-rand: true,   // bool: Weißen Rand am Blattrand erzeugen
  result-table: true,  // bool: Ergebnistabelle am Kopf des Bogens anzeigen
  vorschlag: false,    // bool: Lehrerkopie / Korrekturvorschlag
  line-stroke: 1pt + rgb("FF0613"),  // stroke: Farbe und Stärke der Korrekturlinien
)
```]

= Hinweise

- Das Paket erzeugt *A3-Seiten* (42 × 29,7 cm). Ein A3-fähiger Drucker oder
  ein PDF-A3-Export ist erforderlich.
- Die Schriftart *Myriad Pro* muss auf dem System installiert sein.
  Alternativ kann eine ähnliche serifenlose Schrift systemweit als Fallback gesetzt werden.
- Jede Schülerin / jeder Schüler belegt genau eine Seite im erzeugten PDF.
- Das Paket nutzt intern `@schule/patterns:0.0.1` für das karierte Schreibfeld.

= API-Referenz

#show-module(read("../klausurboegen.typ"), name: "klausurboegen")
