#import "@schule/schuldocs:0.3.1": info, show-code, show-example, show-module, tip, warning
#import "../src/lib.typ" as package

// Jedes Beispiel wird mit dem echten Baustein ausgewertet: Was hier steht,
// kompiliert auch. Der Baustein setzt eigene A3-Seiten und lässt sich deshalb
// nicht in das Handbuch einbetten; das Ergebnis wird verworfen.
#let example-scope = (klausurboegen: package.klausurboegen)
#let run(source) = {
  let _ = eval(source.text, mode: "markup", scope: example-scope)
}

/// Nur Quelltext, aber ausgeführt und damit geprüft.
#let example(source) = {
  run(source)
  show-code(source)
}

// Verkleinerte Ansicht eines leeren Bogens (Außen- und Innenseite), gesetzt
// mit denselben Helfern wie der Baustein.
#let sheet-preview(..args) = {
  let settings = package.internal.parameter-defaults + args.named()
  scale(22%, reflow: true, block(width: 42cm, height: 59.4cm, clip: true, stroke: 2pt + luma(120), {
    set block(spacing: 0pt)
    set text(12pt, font: "Myriad Pro")
    // Außen- und Innenseite sind im Baustein je eine A3-Seite hoch.
    show grid.where(columns: (21cm, 21cm)): it => block(width: 42cm, height: 29.7cm, stroke: 2pt + luma(120), it)
    package.internal.sheet(settings)
  }))
}

/// Quelltext und darunter die verkleinerte Ansicht des leeren Bogens.
#let example-with-preview(source) = {
  run(source)
  show-example(
    // Ohne die Importzeile: Sie würde die Ansicht durch den echten Baustein ersetzen.
    rendered: align(center, eval(
      source.text.split("\n").filter(line => not line.starts-with("#import")).join("\n"),
      mode: "markup",
      scope: (klausurboegen: sheet-preview),
    )),
    source: source,
  )
}

= Über dieses Paket

Das `klausurboegen`-Paket setzt *Klausurbögen im A3-Querformat*. Ein Bogen wird
beidseitig gedruckt und einmal in der Mitte gefaltet; so entstehen vier Seiten
im Format A4 mit Schreibfeld und Korrekturrand.

- Seite 1 trägt den Kopf: Logo, Titel, Datum, Klasse und Lehrkraft, darunter
  „Name:“ und „Ergebnis:“ und Platz für Punktetabelle, Note und Notenschlüssel.
- Das Schreibfeld ist kariert oder liniert (`pattern`).
- Der Korrekturrand liegt außen am Blattrand oder innen an der Falz
  (`correction-margin-side`).
- Der *Ergebnisdruck* (`overprint`) setzt nach der Korrektur Punktetabelle, Note
  und Notenschlüssel aus einer CSV-Datei auf die beschriebenen Bögen.
- Ohne Titel entsteht ein Blankobogen ohne Kopf und Seitenzahlen.

Der Baustein heißt deutsch wie sein Paket (`klausurboegen`), alles in den
Klammern ist englisch (`title`, `pattern`, `correction-margin` …). Wer von einer
älteren Version kommt, findet die Zuordnung im Abschnitt „Umstieg auf 0.5.0“.

#info[
  Das Paket setzt die Schrift *Myriad Pro* und eigene A3-Seiten ohne Rand.
  Gedruckt wird A3 quer, beidseitig, Wenden an der kurzen Kante.
]

= Schnellstart

#example-with-preview(```typ
#import "@schule/klausurboegen:0.5.0": klausurboegen

#klausurboegen(
  title: "Physik",
  subtitle: "Schwingungen und Wellen",
  teacher: "MÜ",
  class: "Q1",
  date: "15.05.2026",
)
```)

Die Ansicht zeigt oben die Außenseite (links Seite 4, rechts Seite 1 mit dem
Kopf) und unten die Innenseite (Seiten 2 und 3). Das PDF enthält einen Bogen,
also zwei A3-Seiten; gedruckt wird er so oft, wie Bögen gebraucht werden.

Wer mit `@schule/klassenarbeit` arbeitet, schaltet die Bögen dort mit
`answer-sheets: true` ein und braucht keinen eigenen Import; Titel, Klasse,
Datum und Lehrkraft kommen dann aus der Klassenarbeit.

= Der leere Bogen

== Blankobogen

Ohne `title` entsteht ein Bogen ohne Kopf und ohne Seitenzahlen:

#example-with-preview(```typ
#klausurboegen()
```)

== Kopf

`title`, `subtitle`, `teacher`, `class` und `date` füllen den Kopf. `logo: auto`
setzt das Schullogo des Pakets; ein eigenes Bild kommt als
`logo: image("logo.svg")`, `logo: none` lässt das Logo weg (dann entfällt auch
der Untertitel).

#example(```typ
#klausurboegen(
  title: "Mathematik",
  class: "9b",
  teacher: "SD",
  date: "20.03.2026",
  logo: none,
)
```)

== Liniert oder kariert

`pattern: "lines"` liniert das Schreibfeld, `line-height` ist der
Zeilenabstand. Bei `pattern: "squares"` (der Vorgabe) bestimmt `grid-size` die
Kantenlänge eines Kästchens.

#example-with-preview(```typ
#klausurboegen(
  title: "Deutsch",
  subtitle: "Erörterung",
  class: "10a",
  date: "12.10.2026",
  pattern: "lines",
  line-height: 9mm,
)
```)

#example(```typ
#klausurboegen(title: "Mathematik", grid-size: 0.6cm)
```)

== Korrekturrand

Der Korrekturrand ist 5 cm breit und liegt außen am Blattrand; geschrieben wird
innen an der Falz. `correction-margin` ändert die Breite,
`correction-margin-side: "inside"` legt den Rand an die Falz.

Mit `correction-margin-blank: false` läuft das Muster durch, und eine Linie
grenzt den Rand ab. Ihr Aussehen bestimmt `correction-margin-stroke`.

#example-with-preview(```typ
#klausurboegen(
  title: "Englisch",
  class: "10a",
  correction-margin: 4cm,
  correction-margin-side: "inside",
  correction-margin-blank: false,
  correction-margin-stroke: 1pt + blue,
)
```)

== Folgebogen

`continuation: true` setzt einen Folgebogen ohne Ergebnisbereich: Der Kopf ist
kleiner, „Ergebnis:“ und der Platz für Note und Notenschlüssel entfallen.
`points-table: false` lässt auch den Platz für die Punktetabelle weg; der
Schalter wirkt nur auf dem Folgebogen. `proposal` beschriftet die Namenszeile
rechts, zum Beispiel bei Abiturvorschlägen.

#example-with-preview(```typ
#klausurboegen(
  title: "Physik",
  class: "Q2",
  continuation: true,
  points-table: false,
  proposal: "Vorschlag A",
)
```)

= Ergebnisdruck

Nach der Korrektur kommen die beschriebenen Bögen noch einmal in den Drucker:
`overprint: true` setzt je Schülerin und Schüler eine Seite, die nur
Punktetabelle, Note und Notenschlüssel enthält, genau an den freien Stellen von
Seite 1. Die Reihenfolge der Seiten ist die der Zeilen in `results`.

== Die Ergebnisse

`results` sind die Zeilen einer CSV-Datei, im Dokument also
`results: csv("ergebnisse.csv")`:

#show-code(```
Name,Note,A1 a),A1 b),A2,A3
,,3,4,5,8
Anna Bauer,12,3,3.5,4,7
Ben Fischer,7,1,,4,6
```)

- Zeile 1 ist die Kopfzeile. Spalte 1 ist der Name, Spalte 2 die Note, ab
  Spalte 3 stehen die Aufgaben.
- Teilaufgaben heißen in der Kopfzeile `A1 a)` oder `A1.1`; sie werden in der
  Tabelle unter ihrer Aufgabe zusammengefasst.
- Zeile 2 enthält die erreichbaren Punkte.
- Jede weitere Zeile ist eine Schülerin oder ein Schüler. Eine leere Zelle
  zählt 0 Punkte, Punkte stehen mit Dezimalpunkt (`3.5`).
- Leere Zeilen und Spalten ohne Kopf werden übersprungen, ebenso Zellen, die
  ein Leerzeichen enthalten.

#example(```typ
#let rows = (
  ("Name", "Note", "A1 a)", "A1 b)", "A2", "A3"),
  ("", "", "3", "4", "5", "8"),
  ("Anna Bauer", "12", "3", "3.5", "4", "7"),
  ("Ben Fischer", "7", "1", "", "4", "6"),
)

#klausurboegen(
  title: "Physik",
  subtitle: "Schwingungen und Wellen",
  teacher: "MÜ",
  class: "Q1",
  date: "15.05.2026",
  results: rows,
  overprint: true,
)
```)

#warning[
  Titel, `stage`, `continuation` und `points-table` müssen beim Ergebnisdruck
  so stehen wie beim Druck der leeren Bögen, sonst stimmt die Lage nicht.
]

== Notenschlüssel

`stage` bestimmt den Notenschlüssel: `"sek-2"` (die Vorgabe) rechnet mit 15 bis
0 Punkten, `"sek-1"` mit den Noten 1 bis 6 und setzt das Notenwort („gut“).

#example(```typ
#klausurboegen(
  title: "Mathematik",
  class: "9b",
  stage: "sek-1",
  results: (
    ("Name", "Note", "A1", "A2", "A3"),
    ("", "", "6", "6", "8"),
    ("Lena Braun", "2", "5", "5", "7"),
  ),
  overprint: true,
)
```)

== Teilaufgaben, Name und Lage

`subtask-numbering` ist das Muster für die Teilaufgaben der Tabelle: `"a)"`
setzt Buchstaben, `"1.1"` Ziffern (von einem Muster mit zwei Zählzeichen zählt
nur der Teil für die Teilaufgabe). Mit `stage: "sek-1"` stehen immer Buchstaben.

`overprint-name: true` setzt den Namen aus Spalte 1 klein über „Name:“, zur
Kontrolle der Reihenfolge beim Drucken. `offset` verschiebt Tabelle, Note und
Notenschlüssel und gleicht so den Drucker aus.

#example(```typ
#klausurboegen(
  title: "Chemie",
  class: "11",
  results: (
    ("Name", "Note", "A1.1", "A1.2", "A2"),
    ("", "", "4", "4", "8"),
    ("Ali Demir", "9", "3", "2", "6"),
  ),
  overprint: true,
  overprint-name: true,
  subtask-numbering: "1.1",
  offset: (dx: 1mm, dy: -0.5mm),
)
```)

== Arbeit direkt auf dem Bogen

`@schule/klassenarbeit` kann eine Arbeit direkt auf den Bogen setzen
(`answer-sheet-pages`). Steht dort die Punktetabelle schon als Vordruck auf dem
Bogen, setzt `points-table-preprinted: true` beim Ergebnisdruck nur noch die
erreichten Punkte, die Summe, die Note und den Notenschlüssel.

#example(```typ
#klausurboegen(
  title: "Klassenarbeit 1",
  class: "5a",
  stage: "sek-1",
  results: (
    ("Name", "Note", "1", "2"),
    ("", "", "4", "6"),
    ("Mia Wolf", "1", "4", "5.5"),
  ),
  overprint: true,
  points-table-preprinted: true,
)
```)

= Umstieg auf 0.5.0

Version 0.5.0 führt die Äste 0.0.4 (Vordruck, Namen, Arbeit auf dem Bogen) und
0.0.5 (liniert, Lage des Korrekturrands) zusammen und gibt allen Parametern
einheitliche englische Namen. Das gesetzte Ergebnis bleibt gleich. Jeder alte
Name bricht mit einer Meldung ab, die den neuen nennt, zum Beispiel:

#show-code(```
klausurboegen.klausurboegen: `exam` heißt jetzt `title`
klausurboegen.klausurboegen: `sek1: true` heißt jetzt `stage: "sek-1"`
```)

== Baustein

#table(
  columns: (auto, 1fr),
  table.header[*alt*][*neu*],
  [`klausurbögen(…)`], [`klausurboegen(…)`],
  [`bogen-seiten(…)`, `klausurbogen-arbeit` (0.0.4)],
  [nicht mehr öffentlich; die Arbeit direkt auf dem Bogen schaltet `klassenarbeit(answer-sheet-pages: …)` ein],
)

== Parameter

#table(
  columns: (auto, auto, 1fr),
  table.header[*alt*][*neu*][*Werte*],
  [`exam: ""`], [`title: none`], [`""` → weglassen],
  [`subexam: ""`], [`subtitle: none`], [`""` → weglassen],
  [`teacher: "SLZ"`], [`teacher: none`], [die Vorgabe entfällt; wer sie braucht, schreibt `teacher: "SLZ"`],
  [`class: "PH1"`], [`class: none`], [die Vorgabe entfällt; sonst `class: "PH1"` schreiben],
  [`date: "09.10.2023"`], [`date: none`], [die Vorgabe entfällt; sonst das Datum schreiben],
  [–], [`logo: auto`], [neu: `auto` ist das bisherige Schullogo],
  [`students`], [`results`], [unverändert: die Zeilen der CSV-Datei],
  [`sek1: false`], [`stage: "sek-2"`], [`true` → `"sek-1"`, `false` → weglassen],
  [`result`], [`overprint`], [unverändert],
  [`namen` (0.0.4)], [`overprint-name`], [unverändert],
  [`sub`], [`continuation`], [unverändert],
  [`result-table`], [`points-table`], [unverändert],
  [`vordruck` (0.0.4)], [`points-table-preprinted`], [`"werte"` → `true`; `false` und `true` → weglassen],
  [`vorschlag: false`], [`proposal: none`], [`false` → weglassen; Text bleibt],
  [`numbering: "a)"`], [`subtask-numbering: "a)"`], [`"1."` und jeder andere Wert → `"1.1"`],
  [`muster: "kariert"`], [`pattern: "squares"`], [`"kariert"` → `"squares"`, `"liniert"` → `"lines"`],
  [`scale: 1`], [`grid-size: 0.5cm`], [Faktor mal 0,5 cm: `1.2` → `0.6cm`],
  [`linienabstand`], [`line-height`], [unverändert],
  [`rand`], [`correction-margin`], [unverändert],
  [`korrekturrand: "aussen"`],
  [`correction-margin-side: "outside"`],
  [`"aussen"`, `"außen"` → `"outside"`, `"innen"` → `"inside"`],

  [`line-stroke`], [`correction-margin-stroke`], [unverändert],
  [`weißer-rand`], [`correction-margin-blank`], [unverändert],
  [`mv`], [`offset`], [unverändert, Schlüssel `dx` und `dy`],
)

== Was sich sonst geändert hat

- Die persönlichen Vorgaben `"SLZ"`, `"PH1"` und `"09.10.2023"` gibt es nicht
  mehr. Wer sie bisher nicht angegeben hat und einen Titel setzt, ergänzt sie
  für das gleiche Ergebnis.
- Falsche Eingaben brechen mit einer Meldung ab statt mit einem Fehler aus dem
  Inneren: eine Namensliste in `results`, Punkte mit Komma, `overprint: true`
  ohne Ergebnisse, unbekannte Parameter.
- `overprint: true` mit weniger als drei Zeilen in `results` (Kopfzeile,
  Maximalpunkte, mindestens eine Schülerzeile) bricht ab; bisher entstand eine
  leere Seite.
- `overprint: true` oder `results` ohne `title` bricht ab; bisher entstand
  stillschweigend ein einzelner Blankobogen, Ergebnisse und Ergebnisdruck
  wurden übergangen.
- Leere Zeilen in `results` werden übersprungen (bisher nur im Ast 0.0.4).
- `subtask-numbering: "1."` ist vorerst gesperrt; gemeint war `"1.1"`.
- Kopf, Punktetabelle und Notenschlüssel setzt Typsts eingebautes `grid`; das
  Paket braucht `tablex` nicht mehr. Maße und Schriftbild bleiben gleich. In
  der getönten Summenspalte der Punktetabelle sind die waagerechten Linien
  jetzt so stark wie die übrigen (1 pt); bisher verdeckte die Tönung der
  nächsten Zeile ihre untere Hälfte.

= Hinweise

- Das Paket erzeugt *A3-Seiten* (42 × 29,7 cm) ohne Rand. Ein Drucker für A3
  ist nötig; Ränder, die er nicht bedruckt, schneiden das Muster ab.
- Die Schrift *Myriad Pro* muss installiert sein, sonst setzt Typst eine
  Ersatzschrift und warnt.
- Ein leerer Bogen sind zwei Seiten im PDF (außen und innen), ein Ergebnisdruck
  ist eine Seite je Schülerin und Schüler.
- Das karierte Schreibfeld kommt aus `@schule/patterns:0.5.0`.

= API-Referenz

#show-module(read("../src/klausurboegen.typ"), name: "klausurboegen")
