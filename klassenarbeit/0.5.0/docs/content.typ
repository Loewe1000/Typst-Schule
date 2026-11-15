#import "@schule/schuldocs:0.3.1": info, show-code, show-example, show-module, tip, warning
#import "@schule/aufgaben:0.5.0" as aufgaben
#import "../src/lib.typ" as package

// Jedes Beispiel wird mit dem echten Paket ausgewertet: Namen, Typen und Werte
// prüft `klassenarbeit` sofort, ein veraltetes Beispiel bricht also den Bau des
// Handbuchs ab. Die Vorlage richtet eigene Seiten ein und lässt sich nicht
// einbetten; das Ergebnis wird deshalb verworfen. Dateien (`image`, `csv`)
// gibt es beim Auswerten nicht, dafür stehen hier Platzhalter.
#let example-scope = (
  dictionary(package)
    + (
      image: (..args) => box(width: 1cm, height: 1cm),
      csv: (..args) => (("Name", "Note", "A1", "A2"), ("", "", "5", "2"), ("Mia", "2", "4", "2")),
    )
)
#let run(source) = {
  let _ = eval(source.text, mode: "markup", scope: example-scope)
}

/// Nur Quelltext, aber ausgeführt und damit geprüft.
#let example(source) = {
  run(source)
  show-code(source)
}

/// Quelltext und Ergebnis: Aufgaben, die sich einbetten lassen. Vorher
/// beginnen Zählung und Optionen neu, damit jedes Beispiel für sich steht.
#let task-example(source, points: "all", width: 14cm) = show-example(
  rendered: {
    aufgaben.reset-tasks()
    aufgaben.set-options(..aufgaben.internal.option-defaults, points: points)
    set text(font: ("Fira Sans", "New Computer Modern Sans", "DejaVu Sans"), size: 11pt)
    eval(source.text, mode: "markup", scope: example-scope)
  },
  source: source,
  width: width,
)

/// Der Kopf einer Klassenarbeit als Ansicht.
#let header-preview(..args) = {
  let font = ("Myriad Pro", "Fira Sans", "New Computer Modern Sans", "DejaVu Sans")
  let settings = (logo: auto, name-field: "Name", student: none) + args.named()
  let name-field = settings.remove("name-field")
  let student = settings.remove("student")
  let logo = package.internal.resolve-logo(settings.remove("logo"))
  // `show-example` setzt die Ansicht auf der Website als Bild (`html.frame`).
  show-example(
    rendered: {
      package.internal.exam-header(..settings, logo: logo, font: font)
      if name-field != none {
        set text(font: font)
        text(14pt, weight: "semibold")[#name-field: #h(0.25em) #student]
        v(-3pt)
        line(length: 100%, stroke: 0.5pt + luma(200))
      }
    },
    width: 16cm,
  )
}

= Über dieses Paket

Das Paket `klassenarbeit` ist die Vorlage der Schule-Pakete für Klassenarbeiten, Klausuren und Tests. Es baut auf `arbeitsblatt` auf: Aufgaben, Teilaufgaben, Lösungen, Material, Kästen, Lücken und Themes sind dieselben. Dazu kommt, was eine Prüfung braucht:

- ein Kopf mit Logo, Titel, Datum, Klasse und Lehrkraft, darunter das Namensfeld und eine Info-Tabelle,
- „Seite x von y“ unten rechts,
- die Punkte (BE) an Aufgaben und Teilaufgaben,
- der Erwartungshorizont aus allen `erwartung(…)` der Arbeit,
- ein Lösungsdokument und, auf Wunsch, Klausurbögen aus derselben Quelle.

Der Baustein heißt deutsch wie sein Paket (`klassenarbeit`). Alles in den Klammern ist englisch: Parameter, Werte und die Schlüssel der Dictionaries. Wer von einer älteren Version kommt, findet alle Namen im Abschnitt „Umstieg auf 0.5.0“.

Wer `klassenarbeit` importiert, braucht `arbeitsblatt` nicht zusätzlich: Das Paket reicht dessen ganze Oberfläche weiter (`aufgabe`, `teilaufgabe`, `loesung`, `erwartung`, `material`, `luecke`, `kariert`, `minipage`, die Kästen …). Ihre Beschreibung steht in den Handbüchern von `arbeitsblatt` und `aufgaben`.

= Schnellstart

#example(```typ
#import "@schule/klassenarbeit:0.5.0": *

#show: klassenarbeit.with(
  title: [Klassenarbeit Nr. 2],
  subtitle: [Quadratische Funktionen],
  class: [9a],
  date: [15.03.2026],
  teacher: [MÜ],
  points: "all",
)

#aufgabe(title: [Nullstellen])[
  Gegeben ist $f(x) = x^2 - 5x + 6$.
  #teilaufgabe[
    Bestimme die Nullstellen.
    #erwartung(3)[beide Nullstellen berechnet]
    #loesung[$x_1 = 2$, $x_2 = 3$]
  ]
  #teilaufgabe[
    Skizziere den Graphen.
    #erwartung(2)[Parabel durch beide Nullstellen]
    #erwartung(1)[Scheitelpunkt eingezeichnet]
  ]
]
```)

Daraus entsteht die Klassenarbeit mit Kopf, Namensfeld und Seitenzahl und, auf einer eigenen Seite am Ende, der Erwartungshorizont. Der Kopf sieht so aus:

#header-preview(
  title: [Klassenarbeit Nr. 2],
  subtitle: [Quadratische Funktionen],
  class: [9a],
  date: [15.03.2026],
  teacher: [MÜ],
)

Eine Klassenarbeit ist immer Druckfassung: feste Seiten im Format A4, Ränder von 1 cm oben und unten und 1,5 cm links und rechts.

= Kopf

== Titel, Klasse, Datum, Lehrkraft

Alle Angaben sind Text oder Inhalt und dürfen fehlen. `title` steht groß in der Mitte, `subtitle` darunter, `date` rechts oben, `class` und `teacher` rechts darunter.

#example(```typ
#show: klassenarbeit.with(
  title: "Klassenarbeit Nr. 1",
  subtitle: "Bruchrechnung und Dezimalzahlen",
  class: "6b",
  date: "22.01.2026",
  teacher: "SLZ",
)
```)

„Nichts“ ist `none` oder das Weglassen, nie der leere Text: `subtitle: ""` bricht mit einem Hinweis ab.

== Logo

Ohne Angabe (`logo: auto`) steht links das Schullogo. Ein eigenes Logo ist beliebiger Inhalt, `none` lässt es weg. Ohne Logo entfällt auch der Untertitel.

#example(```typ
#show: klassenarbeit.with(
  title: [Test],
  logo: image("logo.svg"),
)
```)

#example(```typ
#show: klassenarbeit.with(
  title: [Test],
  logo: none,
)
```)

#header-preview(title: [Test], logo: none, date: [22.01.2026], class: [6b])

Dasselbe Logo steht auch auf den Klausurbögen (`answer-sheets`).

== Namensfeld

Unter dem Kopf steht „Name:“ mit einer Linie. `name-field` ändert die Beschriftung (den Doppelpunkt setzt das Paket), `none` lässt das Feld weg. `student` trägt einen Namen schon ein, zum Beispiel für vorbereitete Kopien.

#example(```typ
#show: klassenarbeit.with(
  title: [Test],
  name-field: "Name, Klasse",
  student: "Mia Schneider, 6b",
)
```)

Mit `name-repeat: true` steht das Namensfeld im Kopf jeder Seite, nicht nur auf der ersten.

#example(```typ
#show: klassenarbeit.with(
  title: [Test],
  name-repeat: true,
)
```)

== Info-Tabelle

`info-table` setzt unter das Namensfeld eine Tabelle mit Angaben zur Arbeit. Jeder Eintrag ist ein Paar aus Beschriftung und Wert; die Beschriftung steht fett mit Doppelpunkt.

#example(```typ
#show: klassenarbeit.with(
  title: [Test],
  info-table: (
    ([Hilfsmittel], [Taschenrechner, Formelsammlung]),
    ([Bearbeitungszeit], [90 Minuten]),
  ),
)
```)

Ohne Tabelle bleibt der Parameter weg (`info-table: none`).

= Aufgaben, Punkte und Lösungen

Aufgaben werden wie in `arbeitsblatt` geschrieben. Die Punkte einer Aufgabe ergeben sich aus ihren `erwartung(…)`.

#task-example(```typ
#aufgabe(title: [Funktionsanalyse])[
  #teilaufgabe[
    Bestimme die Nullstellen von $f(x) = x^2 - 4$.
    #erwartung(2)[Nullstellen $x = plus.minus 2$]
  ]
  #teilaufgabe[
    Skizziere den Graphen.
    #erwartung(1)[Form der Parabel]
    #erwartung(1)[Scheitelpunkt eingezeichnet]
  ]
]
```)

Die Optionen heißen wie in `arbeitsblatt` und `set-options`:

#table(
  columns: (auto, auto, 1fr),
  table.header[*Parameter*][*Vorgabe*][*Werte*],
  [`points`], [`none`], [`none`, `"tasks"` (an Aufgaben), `"subtasks"` (an Teilaufgaben), `"all"`],
  [`points-total`], [`true`], [Summe im Aufgabenkopf zeigen],
  [`points-position`], [`"end"`], [`"end"` (am Zeilenende), `"margin"` (am Seitenrand)],
  [`points-format`], [`auto`], [eine Funktion `points => content` oder `(task: f, subtask: g)`],
  [`solutions`], [`none`], [`none`, `"in-place"`, `"after-task"`, `"at-end"`, `"only"`],
  [`solutions-pagebreak`], [`none`], [`none`, `"before"`, `"per-task"` (nur mit `solutions: "at-end"`)],
  [`materials`], [`"after-task"`], [`none`, `"after-task"`, `"at-end"`],
  [`materials-pagebreak`], [`"before"`], [`"before"` (Material auf eigener Seite), `none`],
  [`workspaces`], [`true`], [Arbeitsflächen setzen],
  [`shortcodes`], [`"subtasks"`], [`none`, `"tasks"`, `"subtasks"`, `"all"`],
  [`subtask-numbering`], [`"a)"`], [Typst-Muster, zum Beispiel `"a)"` oder `"1.1"`],
)

#example(```typ
#show: klassenarbeit.with(
  title: [Test],
  points: "all",
  points-format: (task: points => [*#points Punkte*]),
  materials: "at-end",
  subtask-numbering: "1.1",
)
```)

`points-format` gilt nur für diese Klassenarbeit; eine zweite in derselben Datei beginnt wieder mit der Paketvorlage („*3 BE*“ und „*[3 BE]*“).

#info[
  Lösungen gehören in der Regel nicht in die Arbeit, sondern in das Lösungsdokument: Die Fassung `"solutions"` zeigt sie von selbst (Abschnitt „Fassungen“). `solutions` braucht deshalb selten einen anderen Wert als `none`.
]

= Erwartungshorizont

Mit `expectations: true`, der Vorgabe, sammelt das Paket alle `erwartung(…)` der Arbeit und setzt daraus auf einer eigenen Seite am Ende den Erwartungshorizont mit Punkten und Summe. Im Bündel steht er nur im Lösungsdokument. `expectations: false` lässt ihn weg.

Ein Dictionary schaltet ihn ein und nimmt die Parameter von `show-expectations`:

#table(
  columns: (auto, auto, 1fr),
  table.header[*Schlüssel*][*Vorgabe*][*Bedeutung*],
  [`achieved`], [`false`], [„\_ / X“ in der Spalte BE, zum Eintragen der erreichten Punkte],
  [`grouped`], [`false`], [alle Erwartungen einer Teilaufgabe in einer Zeile],
  [`select`], [`"current"`], [`"all"`: ein gemeinsamer Horizont über alle Klassenarbeiten der Datei],
  [`blocks`], [`()`], [Zwischenüberschriften der Teile bei `select: "all"`],
)

#example(```typ
#show: klassenarbeit.with(
  title: [Test],
  expectations: (achieved: true, grouped: true),
)
```)

Die Seiten des Erwartungshorizonts tragen keine Seitenzahl und zählen nicht mit.

= Fassungen

Aus einer Quelle entstehen bis zu drei Dokumente:

#table(
  columns: (auto, auto, 1fr),
  table.header[*Fassung*][*Datei im Bündel*][*Inhalt*],
  [`"print"`], [`<Name>.pdf`], [die Klassenarbeit],
  [`"solutions"`], [`<Name> - Lösung.pdf`], [Lösungen statt Aufgabentext, danach der Erwartungshorizont],
  [`"answer-sheets"`], [`<Name> - Klausurbögen.pdf`], [nur die Klausurbögen; nur mit `answer-sheets`],
)

== Bündel-Export

#show-code(```bash
typst compile --features bundle --format bundle ka.typ ausgabe/
```)

`<Name>` ist `filename`, sonst der Text von `title`, sonst „Klassenarbeit 1“. `variants` wählt die Fassungen; ohne Angabe sind es `("print", "solutions")`. Sind die Klausurbögen eingeschaltet, kommt `"answer-sheets"` immer dazu, auch zu einer ausdrücklichen Liste. Wer die Bögen-Datei nicht will, schreibt `answer-sheets: false`.

#example(```typ
#show: klassenarbeit.with(
  title: [Klassenarbeit Nr. 2],
  filename: "ka2-9a",
  variants: ("print",),
)
```)

== Einzelnes Dokument

Ein gewöhnliches `typst compile` und die Vorschau im Editor zeigen genau eine Fassung, ohne Angabe die Klassenarbeit. `preview-variant` wählt eine andere:

#example(```typ
#show: klassenarbeit.with(
  title: [Klassenarbeit Nr. 2],
  preview-variant: "solutions",
)
```)

= Klausurbögen

`answer-sheets` erzeugt zur Klassenarbeit die passenden Klausurbögen (A3 quer, gefaltet) als eigene Fassung. Titel, Untertitel, Klasse, Datum, Lehrkraft, Logo und `subtask-numbering` kommen aus der Klassenarbeit.

#example(```typ
#show: klassenarbeit.with(
  title: [Klassenarbeit Nr. 2],
  class: [9a],
  answer-sheets: true,
)
```)

Ein Dictionary schaltet die Bögen ein und nimmt die Parameter des Bausteins `klausurboegen`; sie stehen im Handbuch von `klausurboegen`. Die wichtigsten:

#example(```typ
#show: klassenarbeit.with(
  title: [Klassenarbeit Nr. 2],
  class: [9a],
  answer-sheets: (
    stage: "sek-1",                   // Noten 1 bis 6; Vorgabe "sek-2" (15 bis 0 Punkte)
    pattern: "lines",                 // liniert; Vorgabe "squares" (kariert)
    line-height: 8mm,                 // Zeilenabstand bei "lines"
    correction-margin-side: "inside", // Korrekturrand an der Falz; Vorgabe "outside"
  ),
)
```)

== Ergebnisdruck

Nach der Korrektur setzt der Ergebnisdruck Punktetabelle, Note und Notenschlüssel auf die beschriebenen Bögen. Dazu bekommt das Dictionary die Zeilen einer CSV-Datei (`results`) und `overprint: true`; die Gestalt der Datei beschreibt das Handbuch von `klausurboegen`.

#example(```typ
#show: klassenarbeit.with(
  title: [Klassenarbeit Nr. 2],
  class: [9a],
  answer-sheets: (
    results: csv("ergebnisse.csv"),
    overprint: true,
  ),
  preview-variant: "answer-sheets",
)
```)

= Arbeit direkt auf dem Klausurbogen

Mit `answer-sheet-pages` steht die Arbeit selbst auf dem Klausurbogen: A3 quer, beidseitig, einmal gefaltet. Oben auf Seite 1 stehen Kopf, Namenszeile und der Platz für Punktetabelle, Note und Notenschlüssel, darunter beginnen die Aufgaben und laufen über die Seiten 2 und 3. Seite 4 bleibt für Nebenrechnungen. Das Lösungsdokument bleibt A4; einen Erwartungshorizont gibt es auf dem Bogen nicht.

#example(```typ
#show: klassenarbeit.with(
  title: [Klassenarbeit Nr. 2],
  class: [9a],
  points: "all",
  answer-sheet-pages: true,
)
```)

Ein Dictionary schaltet das Merkmal ein:

#table(
  columns: (auto, auto, 1fr),
  table.header[*Schlüssel*][*Vorgabe*][*Bedeutung*],
  [`stage`], [`"sek-2"`], [`"sek-1"` oder `"sek-2"`; bestimmt den Notenschlüssel],
  [`points-table-preprinted`], [`false`], [Linien, Köpfe und mögliche Punkte der Punktetabelle schon auf den Bogen drucken; muss beim späteren Ergebnisdruck gleich stehen],
  [`points-table-subtasks`], [`true`], [eine Spalte je Teilaufgabe; `false`: nur Aufgabensummen],
  [`back-page`], [`auto`], [Inhalt von Seite 4; `auto` = „Platz für Nebenrechnungen“],
  [`back-page-tasks`], [–], [Aufgaben für Seite 4; sie werden hinter denen der Seiten 1 bis 3 nummeriert und stehen in der Lösung am Ende],
  [`margin`], [`(top: 12mm, bottom: 16mm, x: 12mm)`], [Seitenrand: eine Länge oder ein Dictionary mit `top`, `bottom`, `x`],
  [`header-spacing`], [`4mm`], [Abstand zwischen Kopfbereich und erster Aufgabe],
  [`offset`], [`(dx: 0cm, dy: 0cm)`], [Verschiebung von Tabelle und Note, zum Ausgleich des Druckers],
  [`continuation`, `points-table`, `proposal`], [], [Folgebogen, wie beim Baustein `klausurboegen`],
)

#example(```typ
#show: klassenarbeit.with(
  title: [Klassenarbeit Nr. 2],
  class: [9a],
  points: "all",
  answer-sheet-pages: (
    stage: "sek-1",
    back-page-tasks: [
      #aufgabe(title: [Zusatz])[
        Begründe deine Antwort.
        #erwartung(3)[Begründung]
      ]
    ],
  ),
)
```)

`back-page` und `back-page-tasks` zugleich sind ein Fehler. Passt die Arbeit nicht auf die Seiten 1 bis 3, steht auf dem dritten Bogen ein roter Hinweis.

= Seite und Gestaltung

== Seitenzahlen

`page-counter` bestimmt die Zählung von „Seite x von y“:

- `"restart"` (Vorgabe): Jede Klassenarbeit beginnt bei Seite 1.
- `"continuous"`: Mehrere Klassenarbeiten einer Datei zählen durch.
- `none`: keine Seitenzahlen.

#example(```typ
#show: klassenarbeit.with(
  title: [Test],
  page-counter: none,
)
```)

== Ränder und Papier

`page-settings` reicht weitere Argumente an `set page`. Ein eigenes `margin` ersetzt die Ränder der Klassenarbeit; `header-ascent` ist der Abstand zwischen Kopf und Text (Vorgabe 14 pt).

#example(```typ
#show: klassenarbeit.with(
  title: [Test],
  landscape: true,
  page-settings: (
    margin: (top: 2cm, bottom: 2cm, x: 2.5cm),
  ),
)
```)

== Schrift

#example(```typ
#show: klassenarbeit.with(
  title: [Test],
  font: "Libertinus Serif",
  math-font: "New Computer Modern Math",
  font-size: 11pt,
  figure-font-size: 9pt,
)
```)

Ohne Angabe gelten „Myriad Pro“, „Fira Math“ und 12 pt.

== Themes

`theme` und `accent` wirken wie in `arbeitsblatt`: Das Theme gestaltet Aufgaben, Kästen, Lösungen und Schrift. Kopf, Ränder, Fußzeile und Seitenhintergrund bleiben die der Klassenarbeit.

#example(```typ
#show: klassenarbeit.with(
  title: [Test],
  class: "MA-09",
  theme: "klar",
  accent: rgb("#1d4ed8"),
)
```)

= Mehrere Klassenarbeiten in einer Datei

Als Funktion aufgerufen, setzt `klassenarbeit` eine Arbeit nach der anderen, zum Beispiel Teil A ohne und Teil B mit Hilfsmitteln. Jede zählt ihre Aufgaben und Punkte für sich. `expectations: (select: "all")` an der letzten setzt einen gemeinsamen Erwartungshorizont.

#example(```typ
#import "@schule/klassenarbeit:0.5.0": *

#klassenarbeit(
  title: [Klausur – Teil A],
  page-counter: "continuous",
  expectations: false,
  filename: "klausur-teil-a",
)[
  #aufgabe(title: [Ohne Hilfsmittel])[
    Berechne $3/4 + 1/8$.
    #erwartung(2)[Ergebnis $7/8$]
  ]
]

#klassenarbeit(
  title: [Klausur – Teil B],
  page-counter: "continuous",
  expectations: (select: "all", blocks: ([Teil A – ohne Hilfsmittel], [Teil B – mit Hilfsmitteln])),
  filename: "klausur-teil-b",
)[
  #aufgabe(title: [Mit Taschenrechner])[
    Berechne $sqrt(2)$ auf drei Stellen.
    #erwartung(1)[1,414]
  ]
]
```)

Im Bündel braucht jede Klassenarbeit einen eigenen Dateinamen (`filename` oder verschiedene Titel).

= Fehlermeldungen

Das Paket prüft jeden Parameter, bevor es etwas setzt. Die Meldungen haben immer dieselbe Form: Paket und Funktion, was falsch ist, und die Abhilfe.

#show-code(```
klassenarbeit.klassenarbeit: unbekannter Parameter `titl` – meintest du `title`?
klassenarbeit.klassenarbeit: `erwartungen` heißt jetzt `expectations`
klassenarbeit.klassenarbeit: `points: "alle"` heißt jetzt `"all"`
klassenarbeit.klassenarbeit: `page-counter: false` – das Aus ist `none`
klassenarbeit.klassenarbeit: `subtitle: ""` – für „kein Untertitel" `none` schreiben oder weglassen
klassenarbeit.klassenarbeit: unbekannter Schlüssel `answer-sheets.patern` – meintest du `answer-sheets.pattern`?
```)

= Umstieg auf 0.5.0

Mit 0.5.0 haben alle Schule-Pakete einheitliche Namen bekommen. `klassenarbeit` heißt weiter so; alles in den Klammern ist jetzt englisch. Am gesetzten Ergebnis ändert sich nichts außer den Punkten unter „Was sich sonst geändert hat“.

Ein alter Name wird nie still übergangen: Das Paket bricht mit einer Meldung ab, die den neuen Namen nennt, wo es geht samt neuem Wert, zum Beispiel ``klassenarbeit.klassenarbeit: `page-numbering: false` heißt jetzt `page-counter: none` ``.

Stehen der alte und der neue Name zugleich im Kopf, verlangt die Meldung, nur den neuen zu schreiben. Eine Grenze: Trägt der neue Name ausdrücklich seinen Vorgabewert (`points: none, punkte: "alle"`), sieht das Paket nur den alten Namen und meldet „heißt jetzt“; dann den alten Eintrag löschen und den Wert beim neuen Namen eintragen.

== Kopfparameter

#table(
  columns: (1fr, 1fr, 1.6fr),
  table.header[*bis 0.4.0*][*ab 0.5.0*][*Werte*],
  [`title: ""`, `subtitle: ""`, `class: ""`, `date: ""`, `teacher: ""`, `student: ""`], [Namen unverändert, Vorgabe `none`], [`""` → weglassen],
  [`schueler` (0.0.x)], [`student`], [],
  [`logo: "angela"`], [`logo: auto`], [`"angela"` bleibt gültig; `""` → `none`; ein unbekannter Name ist ein Fehler],
  [`name-field`, `name-repeat`], [unverändert], [],
  [`info-table: false`], [`info-table: none`], [`false` → weglassen; nur noch Paare: `(a, b, c, d)` → `((a, b), (c, d))`],
  [`table: (…)` (bis 0.1.1)], [`info-table: (…)`], [],
  [`page-numbering: true`], [`page-counter: "restart"`], [`true`, `"reset"` → `"restart"` (weglassen); `"continuous"` bleibt; `false` → `none`],
  [`erwartungen`], [`expectations`], [`true`, `false`, Dictionary; Schlüssel unten],
  [`klausurboegen`], [`answer-sheets`], [`true`, `false`, Dictionary; Schlüssel unten],
  [`bogen` (0.3.1)], [`answer-sheet-pages`], [Schlüssel unten],
  [`punkte-template`], [`points-format`], [`none` → weglassen; `(aufgabe: f, teilaufgabe: g)` → `(task: f, subtask: g)`],
  [`varianten`], [`variants`], [`"druck"` → `"print"`, `"loesung"` → `"solutions"`, `"klausurboegen"` → `"answer-sheets"`; nur noch als Array: `"druck"` → `("print",)`],
  [`variante`], [`preview-variant`], [Werte wie bei `variants`],
  [`dateiname`], [`filename`], [],
  [`akzent`], [`accent`], [],
  [`theme: none`], [`theme: auto`], [`none`, `"standard"` → weglassen],
  [`header-font-size`], [`title-font-size`], [],
  [`header-ascent: x`], [`page-settings: (header-ascent: x)`], [],
  [`paper`, `landscape`, `duplex`, `page-settings`, `font`, `math-font`, `font-size`, `title-font-size`, `figure-font-size`, `workspaces`], [unverändert], [],
)

== Optionen für Aufgaben

#table(
  columns: (1fr, 1fr, 1.6fr),
  table.header[*bis 0.4.0*][*ab 0.5.0*][*Werte*],
  [`loesungen`], [`solutions`, `solutions-pagebreak`], [`"keine"` → weglassen; `"sofort"` → `"in-place"`; `"folgend"` → `"after-task"`; `"reinquetschen"` → `"at-end"`; `"seite"` → `solutions: "at-end", solutions-pagebreak: "before"`; `"seiten"` → `solutions: "at-end", solutions-pagebreak: "per-task"`; `"nur"` → `"only"`],
  [`materialien`], [`materials`, `materials-pagebreak`], [`"seiten"` → weglassen; `"sofort"`, `"folgend"` → `materials: "after-task", materials-pagebreak: none`; `"seite"` → `"at-end"`; `"reinquetschen"` → `materials: "at-end", materials-pagebreak: none`; `"keine"` → `none`],
  [`punkte`], [`points`, `points-total`, `points-position`], [`"keine"` → weglassen; `"aufgaben"` → `"tasks"`; `"teilaufgaben"` → `"subtasks"`; `"alle"` → `"all"`; `"keine-summe"` → `points: "all", points-total: false`; `(anzeige: a, position: "rand")` → `points: a, points-position: "margin"`],
  [`aufgaben-shortcodes`], [`shortcodes`], [`"keine"` → `none`; `"aufgaben"` → `"tasks"`; `"teilaufgaben"` → weglassen; `"alle"` → `"all"`],
  [`teilaufgabe-numbering`], [`subtask-numbering`], [`"1."` → `"1.1"`],
)

== Schlüssel in `expectations`

#table(
  columns: (1fr, 1fr, 1.6fr),
  table.header[*bis 0.4.0*][*ab 0.5.0*][*Werte*],
  [`erreicht`], [`achieved`], [],
  [`grouped`], [unverändert], [],
  [`alle: true`], [`select: "all"`], [`alle: false` → weglassen],
  [`teile`], [`blocks`], [wirkt nur mit `select: "all"`; sonst weglassen],
  [`"show": false`], [`expectations: false`], [`"show": true` → Schlüssel weglassen],
  [`new-page`], [entfällt], [der Erwartungshorizont beginnt immer auf einer neuen Seite],
)

== Schlüssel in `answer-sheets`

Die Schlüssel sind die Parameter des Bausteins `klausurboegen`; die ganze Zuordnung steht in dessen Handbuch.

#table(
  columns: (1fr, 1fr, 1.6fr),
  table.header[*bis 0.4.0*][*ab 0.5.0*][*Werte*],
  [`muster`], [`pattern`], [`"kariert"` → `"squares"`, `"liniert"` → `"lines"`],
  [`linienabstand`], [`line-height`], [],
  [`korrekturrand`], [`correction-margin-side`], [`"aussen"` → `"outside"`, `"innen"` → `"inside"`],
  [`rand`], [`correction-margin`], [],
  [`weißer-rand`], [`correction-margin-blank`], [],
  [`line-stroke`], [`correction-margin-stroke`], [],
  [`scale`], [`grid-size`], [Faktor → Länge: `scale: 1` → `grid-size: 0.5cm`],
  [`sek1: true`, `stufe: "I"`], [`stage: "sek-1"`], [`sek1: false`, `stufe: "II"` → weglassen (`"sek-2"`)],
  [`ergebnisse: x`], [`results: x, overprint: true`], [],
  [`students`, `result`], [`results`, `overprint`], [],
  [`exam`, `subexam`], [`title`, `subtitle`], [],
  [`sub`, `result-table`, `vorschlag`], [`continuation`, `points-table`, `proposal`], [],
  [`numbering`], [`subtask-numbering`], [],
  [`mv`], [`offset`], [],
  [`vordruck`, `namen` (0.3.1)], [`points-table-preprinted`, `overprint-name`], [],
  [`"show": false`], [`answer-sheets: false`], [],
)

== Schlüssel in `answer-sheet-pages` (0.3.1: `bogen`)

#table(
  columns: (1fr, 1fr, 1.6fr),
  table.header[*0.3.1*][*ab 0.5.0*][*Werte*],
  [`sek1`], [`stage`], [`true` → `"sek-1"`],
  [`sub`, `result-table`, `vorschlag`, `numbering`, `mv`], [`continuation`, `points-table`, `proposal`, `subtask-numbering`, `offset`], [],
  [`tabelle`], [`points-table-preprinted`], [],
  [`teilaufgaben`], [`points-table-subtasks`], [],
  [`rueckseite`], [`back-page`], [],
  [`seite4`], [`back-page-tasks`], [],
  [`rand: r`, `unten: u`], [`margin: (top: r, bottom: u, x: r)`], [],
  [`abstand`], [`header-spacing`], [],
)

== Was es nicht mehr gibt

#table(
  columns: (1fr, 1.4fr),
  table.header[*bis 0.4.0*][*stattdessen*],
  [`print`], [entfällt; eine Klassenarbeit ist immer Druckfassung],
  [`custom-header`], [entfällt; der Kopf entsteht aus `title`, `subtitle`, `class`, `date`, `teacher`, `logo`],
  [`copyright`, `zweifach`], [gibt es nur in `arbeitsblatt` (`copyright-url`, `two-up`)],
  [`fach`, `thema`, `jahrgang`, `niveau`, `typ`, `stichworte`, `kerncurriculum`, `stand`], [Bibliotheks-Metadaten gibt es nur in `arbeitsblatt`],
  [`stufe: "I"` (bis 0.1.1)], [`answer-sheets: (stage: "sek-1")`],
  [`ergebnisse`, `klausurboegen-settings` (bis 0.1.1)], [Schlüssel in `answer-sheets: (…)`],
  [`bewertung` (0.0.x)], [`show-points-table()`; die Spalte zum Eintragen ist `expectations: (achieved: true)`],
  [`lücke`, `show-erwartungen`, `show-bewertung`, `reset-aufgaben` und die übrigen alten Funktionsnamen], [`luecke`, `show-expectations`, `show-points-table`, `reset-tasks` …; jeder alte Name bricht mit dem neuen ab. Die Liste steht in den Handbüchern von `arbeitsblatt` und `aufgaben`],
  [alles aus cetz, cetz-plot, fontawesome, gentle-clues, codly … außer `canvas`, `draw`, `plot`, `qty`, `num`, `unit`, `stickybox`, `fa-icon`], [das Dokument importiert das Paket selbst, zum Beispiel `#import "@preview/cetz:0.4.2"`],
)

== Was sich sonst geändert hat

- Jeder Parameter ist deklariert und geprüft. Ein Tippfehler im Kopf, ein falscher Typ oder ein überzähliges Positionsargument bricht mit einer Meldung von `klassenarbeit.klassenarbeit` ab; bisher wurden manche Angaben still übergangen (`info-table: true`, `klausurboegen: "ja"`, `erwartungen: "keine"`).
- Im Bündel bekommt die Datei ihren Namen auch aus einem Titel, der als Inhalt geschrieben ist (`title: [Klassenarbeit Nr. 2]`); bisher hieß sie dann „Klassenarbeit 1.pdf“.
- `logo` und `subtask-numbering` der Klassenarbeit gelten auch für die Klausurbögen: Mit `logo: none` haben die Bögen kein Logo, ein eigenes Logo steht auch dort.
- `points-format` als Dictionary mit nur einem Schlüssel lässt den anderen bei der Paketvorlage, auch nach einer früheren Klassenarbeit mit eigener Vorlage.
- Die Schlüssel `"show"` und `new-page` in `expectations` gibt es nicht mehr.
- `klassenarbeit` reicht nur noch weiter, was `arbeitsblatt` 0.5.0 exportiert.

Unverändert bleiben die Vorgaben, auch `points: none`: Ohne Angabe zeigt die Klassenarbeit keine Punkte.

== Für Paketautoren

Internes steht im Modul `internal` (`klassenarbeit.internal.exam-single`, `exam-header`, `answer-sheets-variant`, `exam-counter`, `variant-state` …); der Kopf von `src/internal.typ` beschreibt es. Die Schnittstelle ist nicht zugesichert. Der Zähler der Klassenarbeiten heißt `"schule/klassenarbeit/exam-counter@1"`, die Marke am Ende einer Arbeit `<schule-klassenarbeit-end-<id>-<variant>>`.

= Referenz

Erzeugt aus den Kommentaren von `src/klassenarbeit.typ` und damit immer auf dem Stand der Quelle.

#show-module(read("../src/klassenarbeit.typ"), name: "klassenarbeit", only: ("klassenarbeit",))
