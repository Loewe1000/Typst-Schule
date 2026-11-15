#import "@schule/schuldocs:0.3.1": info, show-code, show-example, show-module, tip, warning
#import "@schule/aufgaben:0.5.0" as aufgaben
#import "../src/lib.typ" as package

// Ein Beispiel, das wirklich gesetzt wird: Der Quelltext wird mit den Namen
// des Pakets ausgewertet. Vorher beginnen Zählung, Optionen und Theme neu,
// damit jedes Beispiel für sich steht. Ganze Dokumente (mit
// `#show: arbeitsblatt.with(…)`) richten eine eigene Seite ein und lassen sich
// nicht einbetten; sie stehen als Quelltext da (`show-code`) und werden beim
// Bauen der Doku einzeln kompiliert.
#let example(source, width: 14cm, theme: none) = {
  let rendered = {
    aufgaben.reset-tasks()
    aufgaben.set-options(..aufgaben.internal.option-defaults)
    let resolved = if theme == none { none } else { package.internal.resolve-theme(theme, class: "MA-05") }
    // Das Theme wird nur hier, am Anfang jedes Beispiels, gesetzt (auch auf
    // `none`), nicht am Ende zurückgesetzt. Außerhalb der Beispiele setzt das
    // Handbuch keine Bausteine des Pakets.
    aufgaben.internal.theme-state.update(_ => resolved)
    {
      set text(
        font: (..if resolved != none { (resolved.font,) }, "Fira Sans", "New Computer Modern Sans", "DejaVu Sans"),
        size: if resolved != none { resolved.font-size } else { 11pt },
      )
      show: if resolved != none { resolved.setup } else { it => it }
      eval(source.text, mode: "markup", scope: dictionary(package))
    }
  }
  // Braucht schuldocs ab 0.3.1: Dort erkennt `show-example` die Website schon
  // im ersten Layout-Durchlauf. Mit 0.3.0 kostete das einen Durchlauf mehr,
  // und Beispiele mit Theme und Lösung an Ort und Stelle konvergierten nicht.
  show-example(rendered: rendered, source: source, width: width)
}

= Über dieses Paket

Das Paket `arbeitsblatt` ist die Vorlage der Schule-Pakete für Arbeitsblätter. Es richtet Seite, Schrift und Kopfzeile ein, setzt Aufgaben mit Lösungen, Material und Punkten und erzeugt aus einer Quelle mehrere Fassungen: die Druckfassung, die Bildschirmfassung und das Lösungsblatt.

Wer `arbeitsblatt` importiert, hat alles Nötige: Die Bausteine aus `aufgaben`, die Muster aus `patterns` und die Fachbausteine aus `mathematik`, `physik`, `informatik`, `operatoren`, `insert-a-word` und `energy-sketch` reicht das Paket weiter.

Die Bausteine heißen deutsch (`arbeitsblatt`, `aufgabe`, `teilaufgabe`, `loesung`, `luecke`, `lsg`, `kariert`). Alles in den Klammern ist englisch: Parameter, Werte und Optionen. Englisch sind auch Aktionen, Abfragen und Helfer (`set-options`, `has-solutions`, `minipage`, `conditional-pagebreak`).

Wer von einer älteren Version kommt, findet alle Namen im Abschnitt „Umstieg auf 0.5.0".

= Schnellstart

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(
  title: [Quadratische Funktionen],
  class: "MA-09",
  print: true,
  points: "all",
  solutions: "at-end",
  solutions-pagebreak: "before",
  shortcodes: "all",
)

#aufgabe(title: [Grundlagen])[
  + Bestimme die Nullstellen von $f(x) = x^2 - 4x + 3$.
    #erwartung(2)[beide Nullstellen korrekt]
    #loesung[$x_1 = 1$, $x_2 = 3$]

  + Beschreibe den Graphen in @graph.

  #material(caption: [Graph von $f$], label: <graph>)[
    #rect(width: 100%, height: 6cm)[Platzhalter]
  ]
]

= Anwendung

+ Skizziere den Graphen von $g(x) = -x^2 + 2x$.
  #erwartung(3)[Scheitelpunkt, Öffnung, Nullstellen]

  #workspace[#kariert(6)]
```)

`aufgabe` setzt eine Aufgabe, ein Listenpunkt `+ …` wird zur Teilaufgabe. Mit `shortcodes: "all"` wird auch eine Überschrift `= …` zur Aufgabe (Abschnitt „Kurzschreibweise"). Dieselbe Quelle liefert mit `solutions: none` das Blatt und mit `solutions: "only"` das Lösungsblatt; den Wechsel übernimmt der Bündel-Export (Abschnitt „Fassungen").

= Grundlagen

== Import

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *
```)

== Das kleinste Arbeitsblatt

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(title: [Quadratische Funktionen], class: "MA-09")

Hier beginnt der Inhalt des Arbeitsblatts.
```)

`title` steht links in der Kopfzeile, `class` rechts. Ein Klassenkürzel aus Fach und Jahrgang (`"MA-09"`, `"PH-7"`, `"IF-11"`) bestimmt mit einem Theme die Fachfarbe und die Zeile „Mathematik · Klasse 9".

== Druckfassung und Bildschirmfassung

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(
  title: [Bruchrechnung],
  class: "MA-06",
  print: true,   // feste Seiten, breiter Heftrand
  duplex: true,  // Heftrand wechselt für beidseitigen Druck
)

#aufgabe[Kürze $12/18$.]
```)

#tip[
  Ohne `print: true` ist die Seite so hoch wie ihr Inhalt: Das Blatt erscheint am Bildschirm als eine einzige Seite ohne Umbruch. Abstände mit `v(1fr)` werden dort zu einem kleinen festen Abstand.
]

`landscape: true` dreht das Blatt, `paper` wählt das Format (`"a4"`, `"a5"` …).

= Aufgaben, Lösungen, Material

Die Bausteine `aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung` und `material` kommen aus dem Paket `aufgaben`; dessen Handbuch beschreibt sie vollständig. Dieser Abschnitt zeigt, was die Vorlage dazu einstellt.

== Kurzschreibweise

Mit `shortcodes` werden Überschriften und nummerierte Listen zu Aufgaben und Teilaufgaben.

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(title: [Funktionen], shortcodes: "all")

= Quadratische Funktionen   // wie #aufgabe(title: [Quadratische Funktionen])[]

+ Berechne die Nullstellen.   // wie #teilaufgabe[Berechne die Nullstellen.]
+ Bestimme den Scheitelpunkt.
```)

#table(
  columns: (auto, 1fr),
  [*Wert*], [*Wirkung*],
  [`"subtasks"`], [`+ Text` wird eine Teilaufgabe (Vorgabe)],
  [`"tasks"`], [`= Titel` wird eine Aufgabe],
  [`"all"`], [beides],
  [`none`], [keine Kurzschreibweise],
)

Die Option lässt sich mit `set-options(shortcodes: none)` auch mitten im Dokument ändern, etwa für eine gewöhnliche nummerierte Liste.

== Lösungen

`loesung[…]` sammelt eine Lösung; `solutions` bestimmt, ob und wo sie erscheint.

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(title: [Addition], solutions: "at-end", solutions-pagebreak: "before")

#aufgabe[
  Berechne $3 + 4$.
  #loesung[Das Ergebnis ist $7$.]
]
```)

#table(
  columns: (auto, 1fr),
  [*`solutions`*], [*Wirkung*],
  [`none`], [keine Lösungen (Vorgabe)],
  [`"in-place"`], [direkt nach jeder Teilaufgabe],
  [`"after-task"`], [gesammelt nach jeder Aufgabe],
  [`"at-end"`], [gesammelt am Ende des Dokuments],
  [`"only"`], [nur die Lösungen, der Aufgabentext entfällt],
)

#table(
  columns: (auto, 1fr),
  [*`solutions-pagebreak`*], [*Wirkung (nur mit `solutions: "at-end"`)*],
  [`none`], [die Lösungen schließen direkt an (Vorgabe)],
  [`"before"`], [Seitenumbruch vor dem Lösungsteil],
  [`"per-task"`], [die Lösung jeder Aufgabe auf einer eigenen Seite],
)

== Material

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(title: [Graphen], print: true)

#aufgabe[
  Beschreibe den Graphen in @verlauf.
  #material(caption: [Verlauf der Temperatur], label: <verlauf>)[
    #rect(width: 100%, height: 4cm)[Diagramm]
  ]
]
```)

Material bekommt die Kennung „M1-A" (Aufgabe 1, erstes Material); ein Verweis `@verlauf` setzt sie ein. `materials: "after-task"` (Vorgabe) setzt das Material nach der Aufgabe, `"at-end"` am Dokumentende, `none` gar nicht. Mit `materials-pagebreak: "before"` (Vorgabe) steht es auf einer eigenen Seite, mit `none` im Fluss.

== Punkte und Erwartungen

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(title: [Energie], points: "all")

#aufgabe(title: [Energieerhaltung])[
  + Nenne drei Energieformen. #erwartung(3)[je Energieform ein Punkt]
  + Erkläre den Energieerhaltungssatz. #erwartung(2)[Aussage und Beispiel]
]

#show-points-table()
```)

`points` zeigt die Punkte an den Aufgaben (`"tasks"`), an den Teilaufgaben (`"subtasks"`) oder an beiden (`"all"`). `points-total: false` lässt die Summe im Aufgabenkopf weg, `points-position: "margin"` setzt die Punkte der Teilaufgaben an den Seitenrand, `points-format` ändert die Schreibweise. `subtask-numbering` nummeriert die Teilaufgaben, zum Beispiel `"a)"` oder `"1.1"`.

== Optionen mitten im Dokument

Alle Optionen des Kopfs, die Aufgaben betreffen, ändert `set-options` ab der Stelle, an der es steht.

#example(```typ
#set-options(solutions: "in-place", points: "subtasks")
#aufgabe(title: [Kopfrechnen])[
  #teilaufgabe[$7 dot 8$ #erwartung(1)[56] #loesung[$56$]]
]
```)

== Abfragen

`has-solutions()` und `is-print()` sagen, welche Fassung gerade gesetzt wird. Beide brauchen `context`.

#example(```typ
#context if has-solutions() [Fassung mit Lösungen] else [Blatt ohne Lösungen]

#context if is-print() [Druckfassung] else [Bildschirmfassung]
```)

= Lücken und Lösungen im Text

== `luecke`

Eine Lücke ist eine Linie, so breit wie ihr Inhalt. Ohne Lösungen bleibt sie leer; sind Lösungen sichtbar, steht das Wort auf der Linie.

#example(```typ
Die Hauptstadt von Frankreich ist #luecke[Paris].
Der Wert beträgt #luecke(tight: true)[42].

#set-options(solutions: "in-place")
Die Hauptstadt von Frankreich ist #luecke[Paris].
```)

== `lsg`

`lsg[…]` zeigt Inhalt nur mit sichtbaren Lösungen, und zwar an Ort und Stelle statt im Lösungskasten. Ohne Lösungen bleibt der Platz frei, damit sich Blatt und Lösung nicht verschieben.

#example(```typ
#table(columns: 3, [$x$], [1], [2], [$x^2$], lsg[1], lsg[4])

#set-options(solutions: "in-place")
#table(columns: 3, [$x$], [1], [2], [$x^2$], lsg[1], lsg[4])
```)

`reserve: false` gibt den Platz frei (für Beschriftungen, die im Blatt fehlen sollen). `fallback` setzt im Blatt anderen Inhalt, etwa Schreiblinien, wo die Lösung einen Satz zeigt:

#example(```typ
#lsg(fallback: liniert(2))[Die Graphen sind an der $y$-Achse gespiegelt.]
```)

= Arbeitsflächen

Der Baustein `kariert` setzt Kästchen, `liniert` Schreiblinien (Paket `patterns`). Als `workspace:` einer Aufgabe oder Teilaufgabe oder in `workspace[…]` entfallen sie mit `workspaces: false`; die vordefinierte Lösungsfassung schaltet sie ab.

#example(```typ
#aufgabe(workspace: kariert(3))[Zeichne ein Rechteck mit $a = 3 "cm"$ und $b = 1 "cm"$.]

Freie Fläche unabhängig von einer Aufgabe:
#workspace[#liniert(2)]
```)

= Kästen

Fünfzehn Kästen heben Inhalte hervor: `info`, `memo`, `tip`, `warning`, `example`, `question`, `goal`, `idea`, `abstract`, `conclusion`, `success`, `error`, `danger`, `experiment`, `notify`. Alle haben dieselben vier Parameter.

#example(```typ
#info[Größen bestehen aus Maßzahl und Maßeinheit.]

#memo(title: [Merksatz])[
  Zur nächstkleineren Einheit multiplizierst du mit der Umrechnungszahl.
]

#warning(title: none)[Ohne Titelzeile.]

#tip(accent: purple, width: 8cm)[Eigene Farbe, feste Breite.]
```)

#table(
  columns: (auto, 1fr),
  [*Parameter*], [*Bedeutung*],
  [`title`], [Titel; `auto` setzt den deutschen Standardtitel („Info", „Merke", „Tipp" …), `none` lässt die Titelzeile weg],
  [`accent`], [Farbe des Kastens; `auto` nimmt die Farbe der Kastenart oder des Themes],
  [`breakable`], [`true` erlaubt den Umbruch über den Seitenwechsel],
  [`width`], [Breite; `auto` ist die volle Breite],
)

Ohne Theme zeichnet das Paket `gentle-clues` die Kästen wie bis 0.3.x. Ein Theme zeichnet sie in seiner eigenen Form:

#example(theme: "klar", ```typ
#memo[Zur nächstkleineren Einheit multiplizierst du.]
#tip[Rechne zuerst in dieselbe Einheit um.]
```)

= Themes

`theme` wählt die Gestaltung des ganzen Blatts. Alle Befehle bleiben gleich.

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(
  title: [Größen umrechnen],
  class: "MA-05",
  print: true,
  theme: "klar",
  // accent: rgb("#8b3fa3"),   // eigene Farbe statt der Fachfarbe
)

#aufgabe(title: [Längen umrechnen])[
  + $4 "m" =$ #luecke[400] cm
  + $3 "km" =$ #luecke[3000] m
]
```)

#table(
  columns: (auto, 1fr),
  [*`theme`*], [*Charakter*],
  [`auto`], [klassisch wie bis 0.3.x (Vorgabe)],
  [`"klar"`], [sparsam und modern, Linien statt Flächen, tonerfreundlich],
  [`"atlas"`], [farbig wie ein Schulbuch, Titelkarte, Karten mit Reitern],
  [`"skizze"`], [verspielt für die Unterstufe, Handschrift, Klebeband, Namensfeld],
  [`"labor"`], [technisch für MINT, Monospace-Marken, Messskala],
  [`"kontur"`], [plakativ, dicke schwarze Rahmen, harte Schatten, Versalien],
  [`"leiste"`], [Leiste in der Fachfarbe an der Außenkante mit Kürzel und Seitenzahl],
  [`"riso"`], [Zweifarbdruck-Optik (Fachfarbe und Pink), versetzter Titel, Raster],
  [`"bauhaus"`], [geometrisch: Kreis, Quadrat, Dreieck als Nummern],
)

Gemeinsam in allen Themes: die Fachfarbe aus dem Klassenkürzel (`MA` blau, `PH` orange, `IF` grün, `CH` violett, `BI` grün, `NW` türkis, `DE` rot, `EN` magenta; `accent` setzt eine eigene), die Zeile „Fach · Klasse" über dem Titel, Kürzel, Seitenzahl und Aufgabennummer als gefüllte Marken, Lösungen in Grün. Aufgaben ohne Titel bekommen ihre Nummer neben die erste Zeile. Kurze Aufgaben (unter 9 cm) werden mit einem Theme nicht über den Seitenwechsel gerissen. Ausdrücklich gesetzte Schriftparameter (`font`, `font-size` …) haben Vorrang vor dem Theme.

Dieselbe Aufgabe in vier Themes:

#example(theme: "klar", ```typ
#set-options(solutions: "in-place")
#aufgabe(title: [Längen umrechnen])[
  #teilaufgabe[$4 "m" =$ #luecke[400] cm #loesung[400 cm]]
]
#memo[Von Meter zu Zentimeter: mal 100.]
```)

#example(theme: "atlas", ```typ
#set-options(solutions: "in-place")
#aufgabe(title: [Längen umrechnen])[
  #teilaufgabe[$4 "m" =$ #luecke[400] cm #loesung[400 cm]]
]
#memo[Von Meter zu Zentimeter: mal 100.]
```)

#example(theme: "kontur", ```typ
#set-options(solutions: "in-place")
#aufgabe(title: [Längen umrechnen])[
  #teilaufgabe[$4 "m" =$ #luecke[400] cm #loesung[400 cm]]
]
#memo[Von Meter zu Zentimeter: mal 100.]
```)

#example(theme: "bauhaus", ```typ
#set-options(solutions: "in-place")
#aufgabe(title: [Längen umrechnen])[
  #teilaufgabe[$4 "m" =$ #luecke[400] cm #loesung[400 cm]]
]
#memo[Von Meter zu Zentimeter: mal 100.]
```)

`showcase/render.sh` im Paketordner setzt ein ganzes Beispielblatt in allen Themes.

== Eigene Themes

Ein Theme ist ein Dictionary. Jeder Schlüssel ist freiwillig; was fehlt, bleibt klassisch. So ändert ein Dictionary mit einem einzigen Eintrag nur die Marke der Teilaufgaben:

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(
  title: [Eigenes Theme],
  theme: (subtask: marker => text(fill: red, weight: "bold", marker)),
)

#aufgabe[
  + Erste Teilaufgabe
  + Zweite Teilaufgabe
]
```)

Soll das Theme die Fachfarbe und das Klassenkürzel kennen, schreibt man eine Funktion `(accent: auto, class: none) => dictionary`. `arbeitsblatt` ruft sie mit der Akzentfarbe (der Fachfarbe oder dem Wert von `accent:`) und dem Wert von `class:` auf. Ist im Dokument kein Titel oder keine Klasse gesetzt, bekommen die Theme-Funktion und der Hook `header` dafür wie bis 0.4.0 den leeren Text `""`, nicht `none`.

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#let mein-theme(accent: auto, class: none) = (
  name: "mein-theme",
  font: "Libertinus Serif",
  font-size: 11pt,
  title-font-size: 20pt,
  margin: (bottom: 1.8cm),
  header-top: 1.2cm,
  header-ascent: 0.8cm,
  header: (title: none, class: none, copyright-url: none, font-size: auto) => {
    text(font-size, weight: "bold", fill: accent, title)
    h(1fr)
    class
    line(length: 100%, stroke: 1pt + accent)
  },
  footer: (duplex: true) => align(center, context counter(page).display()),
  task: (marker: none, title: none, icons: (), points: none, large: true) => {
    text(if large { 1.2em } else { 1.05em }, weight: "bold", fill: accent)[
      #if marker != none [Aufgabe #marker]
      #if title != none [· #title]
      #h(1fr) #points
    ]
  },
  subtask: marker => text(fill: accent, weight: "bold", marker),
  solution: (title: none, body) => block(
    width: 100%,
    inset: 8pt,
    fill: green.lighten(90%),
    [*#title* #h(0.5em) #body],
  ),
  callout: (kind: "info", title: none, accent: auto, breakable: false, width: auto, body) => {
    let style = callout-style(kind, worksheet-accent: subject-accents.MA, accent: accent)
    block(
      width: if width == auto { 100% } else { width },
      breakable: breakable,
      stroke: (left: 3pt + style.accent),
      inset: (left: 10pt, y: 4pt),
      [#if title != none [*#title* \ ] #body],
    )
  },
)

#show: arbeitsblatt.with(title: [Eigenes Theme], class: "PH-09", print: true, theme: mein-theme, points: "all")

#aufgabe(title: [Kräfte])[
  + Nenne die Einheit der Kraft. #erwartung(1)[Newton]
]
#memo[Kraft ist Masse mal Beschleunigung.]
```)

Die Schlüssel eines Themes:

#table(
  columns: (auto, 1fr),
  [*Schlüssel*], [*Bedeutung und Vorgabe ohne Eintrag*],
  [`name`], [Name des Themes],
  [`font`, `math-font`], [Text- und Formelschrift (`"Myriad Pro"`, `"Fira Math"`)],
  [`font-size`, `title-font-size`], [Grundschrift und Titelgröße (`12pt`, `16pt`)],
  [`margin`], [Ränder als Dictionary mit `top`, `bottom`, `inside`, `outside` (2,3 cm im Druck, sonst 2,2 cm; 1 cm; 2,25 cm; 1,25 cm)],
  [`header-top`], [Abstand von der Blattkante zum Kopf (`1.2cm`); gilt mit dem Hook `header`, der obere Rand ergibt sich dann aus der gemessenen Kopfhöhe],
  [`header-ascent`], [Abstand zwischen Kopf und Text (`0.8cm` mit dem Hook `header`, sonst `20%`)],
  [`footer-descent`], [Abstand zwischen Text und Fuß (`30%`)],
  [`task-marker-width`], [Einzug bei hängender Aufgabennummer (`2.2em`)],
)

Die Hooks, also die Funktionen eines Themes:

#table(
  columns: (auto, 1fr),
  [*Hook*], [*Signatur und Aufgabe*],
  [`header`], [`(title: none, class: none, copyright-url: none, font-size: auto) => content` – die Kopfzeile; `font-size` ist die Titelgröße],
  [`footer`], [`(duplex: true) => content` – die Fußzeile, nur in der Druckfassung],
  [`background`], [`(print: true, margin: (:), header-top: 0cm) => content` – Seitenhintergrund; `margin` ist das margin-Dictionary der Seite, `header-top` ihr oberer Rand],
  [`task`], [`(marker: none, title: none, icons: (), points: none, large: true) => content` – Kopf einer Aufgabe; `marker` ist die Nummer als Inhalt oder `none`, `points` der fertig formatierte Punktetext oder `none`],
  [`task-marker`], [`task-number => content` – Nummer neben der ersten Zeile bei Aufgaben ohne Titel],
  [`subtask`], [`marker => content` – Marke einer Teilaufgabe],
  [`solution`], [`(title: none, body) => content` – Lösungskasten],
  [`solution-heading`], [`title => content` – Überschrift je Aufgabe im Lösungsblatt],
  [`material-heading`], [`title => content` – Überschrift „Material zu Aufgabe n"],
  [`callout`], [`(kind: "info", title: none, accent: auto, breakable: false, width: auto, body) => content` – die Kästen; `kind` ist der Name der Kastenfunktion],
  [`setup`], [`body => content` – weitere Set- und Show-Regeln für das ganze Blatt],
)

Für eigene Themes sind drei Namen öffentlich: `callout-style(kind, worksheet-accent: …, accent: …)` liefert Symbolname (`icon-name`, für `fa-icon`) und Farbe (`accent`) einer Kastenart, `subject-accents` die Fachfarben nach Kürzel und `subject-names` die Fachnamen.

#example(```typ
#let style = callout-style("warning")
#box(fill: style.accent, inset: 4pt, text(fill: white)[#fa-icon(style.icon-name) Achtung])
#h(1em)
#box(fill: subject-accents.PH, inset: 4pt, text(fill: white, subject-names.PH))
```)

#info[
  Unbekannte Schlüssel in einem Theme sind ein Fehler mit Vorschlag (``unbekannter Schlüssel `heder` – meintest du `header`?``). Mit einem Theme-Dictionary statt einer Funktion wirkt `accent:` nicht, weil das Dictionary seine Farben schon enthält.
]

= Fassungen

== Bündel-Export

Mit Typst 0.15 erzeugt eine Quelldatei mehrere Ausgabedateien:

#show-code(```bash
typst compile --features bundle --format bundle ab.typ ausgabe/
```)

Ohne weitere Angabe entstehen `digital.pdf` und `loesung.pdf`. `variants` wählt die Fassungen:

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(
  title: [Quadratische Funktionen],
  class: "MA-09",
  variants: ("print", "digital", "solutions"),
  filename: "quadratische-funktionen",
)

#aufgabe[Berechne die Nullstellen von $x^2 - 4$. #loesung[$x = plus.minus 2$]]
```)

#table(
  columns: (auto, auto, 1fr),
  [*Fassung*], [*Datei*], [*Bedeutung*],
  [`"print"`], [`druck.pdf`], [Druckfassung: feste Seiten, Heftrand, Arbeitsflächen],
  [`"digital"`], [`digital.pdf`], [Bildschirmfassung: eine endlose Seite],
  [`"solutions"`], [`loesung.pdf`], [Lösungsblatt: nur die Lösungen, Drucklayout, ohne Arbeitsflächen],
  [`"two-up"`], [`zweifach.pdf`], [Kopiervorlage: jede Seite zweimal auf einem Bogen],
)

`filename` setzt einen Vorsatz vor die Dateinamen (`quadratische-funktionen-druck.pdf`).

`variant-overrides` ändert je Fassung einzelne Kopfparameter und legt eigene Fassungen an. Jeder Kopfparameter außer den vier Bündelparametern ist erlaubt; der Schlüssel `path` ersetzt den Ausgabepfad einer Fassung ganz.

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(
  title: [Bruchrechnung],
  variants: ("print", "solutions", "kontrolle"),
  variant-overrides: (
    print: (points: "all"),
    kontrolle: (print: true, solutions: "in-place", workspaces: false, path: "lehrkraft.pdf"),
  ),
)

#aufgabe[Kürze $12/18$. #erwartung(1)[$2/3$] #loesung[$2/3$]]
```)

#info[
  Bei einem gewöhnlichen `typst compile` entsteht genau ein Dokument mit den Angaben des Kopfs; `variants` wirkt dort nicht.
]

#warning[
  Der Bündel-Export ist in Typst 0.15 noch experimentell und wird mit `--features bundle` (oder `TYPST_FEATURES=bundle`) eingeschaltet.
]

== Zwei Kopien je Bogen

`two-up: true` (oder die Fassung `"two-up"`) legt jede Seite zweimal auf einen Bogen der nächsten Größe und zieht eine gestrichelte Schnittlinie dazwischen. Aus einem A5-Blatt wird so die A4-Kopiervorlage für zwei Exemplare.

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(
  title: [Kurzcheck Bruchrechnung],
  class: "MA-06",
  paper: "a5",
  landscape: true,
  print: true,
  two-up: true,
)

#aufgabe[Kürze $12/18$.]
```)

Die Lage ergibt sich aus dem Format: A5 quer steht zweimal untereinander auf A4 hoch, A5 hoch zweimal nebeneinander auf A4 quer. Möglich sind `paper: "a6"`, `"a5"` und `"a4"`. Der Seitenumbruch ist derselbe wie in der einfachen Fassung; `pagebreak()` und `page[…]` ohne Argumente wirken wie gewohnt.

#info[
  `two-up` verlangt `print: true`, denn die Bildschirmfassung hat eine endlos hohe Seite. Die vordefinierte Fassung `"two-up"` setzt beides.
]

#warning[
  Beide Hälften eines Bogens sind gleich; die Aufgaben beginnen in jeder Kopie bei 1. `page(…)` mit Argumenten (etwa `page(fill: aqua)[…]`) ist mit `two-up` nicht möglich. Seitenumbrüche in einem `context`-Block kann das Paket nicht vorab zählen; reicht der Platz der Messung dann nicht, bricht es mit einer Meldung ab.
]

== Alle Fassungen in der Vorschau

Die Vorschau im Editor zeigt ein Dokument. Mit `preview-variant` zeigt sie die Fassungen des Bündels:

#table(
  columns: (auto, 1fr),
  [*`preview-variant`*], [*Wirkung*],
  [`auto`], [alle Fassungen hintereinander, wenn der Editor den System-Input `vorschau=alle` setzt; sonst ein Dokument (Vorgabe)],
  [`"all"`], [immer alle Fassungen hintereinander],
  [`"solutions"` oder ein anderer Name], [genau diese Fassung],
  [`none`], [nie, auch nicht mit `vorschau=alle`],
)

In VS Code mit Tinymist genügt für `vorschau=alle` eine Zeile in den Einstellungen:

#show-code(```json
"tinymist.preview.sysInputs": { "vorschau": "alle" }
```)

Auf der Kommandozeile entspricht das `typst compile --input vorschau=alle`.

#warning[
  `"all"` und ein Name wirken auch bei einem gewöhnlichen `typst compile`: Die Lösungen stehen dann in der erzeugten Datei. Vor dem Kopieren gehört die Angabe wieder heraus; mit `auto` und dem System-Input kann das nicht passieren.
]

= Kopfzeile und Seite

== Kopfzeile

Die Kopfzeile zeigt links den Titel, rechts die Klasse. `header` ersetzt sie durch eigenen Inhalt; `header: none` lässt sie weg.

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(
  header: [
    #text(14pt, weight: "bold")[Gymnasium Musterstadt]
    #h(1fr)
    Klasse 9a
    #move(dy: -.4em, line(length: 100%, stroke: 0.5pt + luma(200)))
  ],
  page-settings: (header-ascent: 12%),
)

Inhalt
```)

`copyright-url` setzt einen kleinen QR-Code in die Kopfzeile, zum Beispiel für die Lizenz- oder Quellenangabe:

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(
  title: [Arbeitsblatt],
  class: "MA-07",
  copyright-url: "https://example.org/material/ab-001",
)

Inhalt
```)

== Seite und Schrift

`page-settings` geht an `set page`: Ränder, Spalten, `header-ascent` und alles Weitere.

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(
  title: [Zweispaltig],
  print: true,
  page-settings: (margin: (top: 3cm, bottom: 2cm, x: 2cm), columns: 2),
  font: "Libertinus Serif",
  font-size: 11pt,
  title-font-size: 18pt,
)

#lorem(80)
```)

`font`, `math-font`, `font-size`, `title-font-size` und `figure-font-size` stehen auf `auto`: Dann gelten die Werte des Themes, ohne Theme Myriad Pro in 12 pt, Fira Math, ein Titel in 16 pt und Bildunterschriften in 9 pt.

= Helfer

== Spalten nebeneinander

#example(```typ
#minipage(columns: (1fr, 2fr), gutter: 1cm)[
  Linke Spalte
][
  Rechte Spalte, doppelt so breit
]

#minipage[Spalte 1][Spalte 2][Spalte 3]
```)

Ohne `columns` bekommt jeder Inhalt eine gleich breite Spalte. `gutter` ist der Abstand zwischen Spalten und zwischen Zeilen, `align` die Ausrichtung in den Zellen (Vorgabe `horizon`).

== QR-Codes und Links

#example(```typ
#minipage(columns: 3)[
  #qr-code("https://typst.app", width: 2cm)
][
  #qr-box("https://typst.app", width: 3cm)[Typst-App]
][
  #icon-link("https://typst.app")[Zur Typst-App]

  #icon-link("https://github.com", icon: emoji.cat, fill: black)[GitHub]
]
```)

`qr-code` setzt den bloßen Code mit durchsichtigem Hintergrund, `qr-box` einen Zettel mit Code und Link, `icon-link` einen Link mit Symbol.

== Seitenumbruch je Fassung

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(title: [Umbrüche], print: true)

Erste Seite der Druckfassung
#conditional-pagebreak(print: true)              // nur in der Druckfassung
#conditional-pagebreak(print: false)             // nur am Bildschirm
#conditional-pagebreak(solutions-visible: true)  // nur mit sichtbaren Lösungen
Zweite Seite der Druckfassung
```)

= Zeichnen, Einheiten und weitergereichte Namen

== Zeichnen mit cetz

`canvas` ist die Zeichenfläche von cetz mit den Achsen der Schule-Pakete (Teilstriche nach innen, graues Gitter, Pfeilspitzen). `draw` und `plot` sind die Module aus cetz und cetz-plot.

#example(```typ
#canvas(length: 0.7cm, {
  draw.line((0, 0), (4, 2))
  draw.circle((4, 2), radius: 0.3)
  draw.content((2, 0), [Beschriftung])
})

#canvas(length: 0.6cm, {
  plot.plot(size: (6, 4), axis-style: "school-book", x-tick-step: 1, y-tick-step: 2, {
    plot.add(x => x * x, domain: (-2, 2))
  })
})
```)

Wer mehr aus cetz braucht (`cetz.canvas` mit `baseline`, `cetz.matrix` …), importiert das Paket selbst: `#import "@preview/cetz:0.4.2"`.

== Zahlen und Einheiten

#example(```typ
#qty[9.81][m/s^2] #h(1em) #qty("230", "V") #h(1em) #num[12345.678] #h(1em) #unit[N/m^2]

#qty("60", "km/h", per: "symbol")
```)

`qty`, `num` und `unit` setzen Zahlen mit Dezimalkomma und Einheiten aufrecht. Brüche in Einheiten erscheinen als Bruch; `per: "symbol"` setzt den Schrägstrich.

== Was das Paket weiterreicht

#table(
  columns: (auto, 1fr),
  [*Paket*], [*Namen*],
  [`aufgaben`], [`aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung`, `material`, `set-options`, `reset-tasks`, `show-solutions`, `show-materials`, `show-expectations`, `show-points-table`, `get-points`, `format-points`, `has-solutions`, `is-print`],
  [`patterns`], [`kariert`, `liniert`, `flex-area`, `is-flex-area`],
  [`insert-a-word`], [`insert-a-word`, `iaword`, `reset-iaword`],
  [`energy-sketch`], [`energy-sketch`],
  [`mathematik`], [`graphen`, `steckbrief`, `kreisdiagramm`, `geogebra-algebra`, `geogebra-cell`],
  [`physik`], [`datensatz`, `messdaten`, `berechnung`, `messwerttabelle`, `lineare-regression`, `quadratische-regression`, `wurzel-regression`, `exponentielle-regression`, `potenz-regression`, `polynom-regression`, `schaltkreis`, `constants`],
  [`informatik`], [`haeufigkeitsanalyse`, `bin-to-dec`, `dec-to-bin`, `hex-to-dec`, `dec-to-hex`, `caesar`, `vigenere`, `atbash`, `rot13`, `ascii-table`, `text-to-blocks`],
  [`operatoren`], [`operator`, `operatoren-liste`],
  [fremde Pakete], [`canvas`, `draw` (cetz), `plot` (cetz-plot), `qty`, `num`, `unit` (unify), `stickybox` (colorful-boxes), `fa-icon` (fontawesome)],
)

Alles andere aus fremden Paketen importiert das Dokument selbst, und zwar namentlich oder als Modul:

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *
#import "@preview/colorful-boxes:1.4.3": colorbox, slanted-colorbox
#import "@preview/gentle-clues:1.2.0": code
#import "@preview/zero:0.5.0" as zero

#colorbox(title: [Hinweis])[Text]
```)

#warning[
  Ein Wildcard-Import von `gentle-clues` oder `zero` nach dem Import von `arbeitsblatt` (`#import "@preview/gentle-clues:1.2.0": *`) überdeckt die fünfzehn Kästen dieses Pakets beziehungsweise `num`, ohne dass Typst es meldet. Deshalb namentlich oder als Modul importieren.
]

= Angaben für die Materialbibliothek

Die Vorlage schreibt unsichtbare Metadaten in das Dokument, die sich mit `typst query` auslesen lassen:

#show-code(```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(
  title: [Potentielle Energie],
  class: "PH-09",
  subject: "physik",
  topic: "physik/energie/potentielle-energie",
  years: (9, 11),
  stage: "sek-1",
  level: "introduction",
  kind: "worksheet",
  keywords: ("Energie", "Höhe"),
  revision: "2026-11-15",
)

Inhalt
```)

#show-code(```bash
typst query ab.typ '<ab-meta>' --field value
```)

Das Label `<ab-meta>` und seine Schlüssel sind eine Schnittstelle nach außen und bleiben deutsch: `titel`, `klasse`, `fach`, `thema`, `jahrgang`, `stufe`, `niveau`, `typ`, `stichworte`, `kerncurriculum`, `stand`. Auch die Werte von `niveau` und `typ` stehen dort deutsch (`level: "introduction"` wird `niveau: "einfuehrung"`, `kind: "worksheet"` wird `typ: "arbeitsblatt"`).

#table(
  columns: (auto, 1fr),
  [*Parameter*], [*Werte*],
  [`stage`], [`"sek-1"`, `"sek-2"`],
  [`level`], [`"introduction"`, `"consolidation"`, `"ea"`, `"ga"`],
  [`kind`], [`"worksheet"`, `"practice"`, `"stations"`, `"exam"`],
)

= Umstieg auf 0.5.0

Mit 0.5.0 haben alle Schule-Pakete einheitliche Namen bekommen. Die Bausteine behalten ihren deutschen Namen; alles in den Klammern und alle Aktionen sind englisch. Am Aussehen der Dokumente ändert sich bis auf die unten genannten Punkte nichts.

Ein alter Name wird nie still übergangen: Das Paket bricht mit einer Meldung ab, die den neuen Namen nennt, zum Beispiel ``arbeitsblatt.arbeitsblatt: `loesungen` heißt jetzt `solutions` `` oder ``arbeitsblatt.arbeitsblatt: `solutions: "seite"` heißt jetzt `solutions: "at-end", solutions-pagebreak: "before"` ``. Tippfehler bekommen einen Vorschlag (``unbekannter Parameter `solutoins` – meintest du `solutions`?``).

== Funktionen

#table(
  columns: (auto, 1fr),
  [*bis 0.4.0*], [*ab 0.5.0*],
  [`arbeitsblatt`, `arbeitsblatt-einzeln`, `lsg`, `minipage`, `workspace`, `icon-link`, `qr-code`, `canvas`, `qty`, `num`, `unit`, die fünfzehn Kästen], [Name unverändert, neue Parameternamen (unten)],
  [`lücke`], [`luecke`],
  [`loesungsmodus()`], [`has-solutions()`],
  [`print-state.get()`], [`is-print()`],
  [`tasks(…)`], [`teilaufgaben(…)`],
  [`print-pagebreak()`], [`conditional-pagebreak(print: true)`],
  [`non-print-pagebreak()`], [`conditional-pagebreak(print: false)`],
  [`qrbox(url, "Text")`], [`qr-box(url)[Text]`],
  [`mono[…]`], [entfällt; `text(font: "SF Mono")[…]`],
  [`c_canvas`], [entfällt; `cetz.canvas` nach `#import "@preview/cetz:0.4.2"`],
  [`reset-aufgaben`, `show-loesungen`, `show-materialien`, `show-erwartungen`, `show-bewertung`, `format-punkte`], [`reset-tasks`, `show-solutions`, `show-materials`, `show-expectations`, `show-points-table`, `format-points` (Handbuch von `aufgaben`)],
)

== Kopfparameter von `arbeitsblatt`

#table(
  columns: (auto, 1fr),
  [*bis 0.4.0*], [*ab 0.5.0*],
  [`title: ""`, `class: ""`], [weglassen (`none`)],
  [`akzent:`], [`accent:`],
  [`theme: none`, `theme: "standard"`], [weglassen (`theme: auto`)],
  [`custom-header: [..]`], [`header: [..]`],
  [`custom-header: none`], [weglassen; `header: none` heißt jetzt „kein Kopf"],
  [`header-ascent: 12%`], [`page-settings: (header-ascent: 12%)`],
  [`copyright:`], [`copyright-url:`],
  [`zweifach:`], [`two-up:`],
  [`teilaufgabe-numbering: "a)"`, `"1."`], [`subtask-numbering: "a)"`, `"1.1"`],
  [`aufgaben-shortcodes: "alle"`, `"aufgaben"`, `"teilaufgaben"`, `"keine"`], [`shortcodes: "all"`, `"tasks"`, `"subtasks"`, `none`],
  [`loesungen: "keine"`, `"false"`, `false`], [weglassen (`solutions: none`)],
  [`loesungen: "sofort"`], [`solutions: "in-place"`],
  [`loesungen: "folgend"`], [`solutions: "after-task"`],
  [`loesungen: "reinquetschen"`], [`solutions: "at-end"`],
  [`loesungen: "seite"`], [`solutions: "at-end", solutions-pagebreak: "before"`],
  [`loesungen: "seiten"`], [`solutions: "at-end", solutions-pagebreak: "per-task"`],
  [`loesungen: "nur"`], [`solutions: "only"`],
  [`materialien: "seiten"`], [weglassen (`materials: "after-task", materials-pagebreak: "before"`)],
  [`materialien: "sofort"`, `"folgend"`], [`materials-pagebreak: none`],
  [`materialien: "seite"`], [`materials: "at-end"`],
  [`materialien: "reinquetschen"`], [`materials: "at-end", materials-pagebreak: none`],
  [`materialien: "keine"`], [`materials: none`],
  [`punkte: "keine"`], [weglassen (`points: none`)],
  [`punkte: "aufgaben"`, `"teilaufgaben"`, `"alle"`], [`points: "tasks"`, `"subtasks"`, `"all"`],
  [`punkte: "keine-summe"`], [`points: "all", points-total: false`],
  [`punkte: (anzeige: "alle", position: "rand")`], [`points: "all", points-position: "margin"`],
  [`varianten: ("druck", "digital", "loesung", "zweifach")`], [`variants: ("print", "digital", "solutions", "two-up")`],
  [`varianten: "druck"`], [`variants: ("print",)`],
  [`varianten: (druck: (punkte: "alle"), lehrer: (…))`], [`variants: ("print", "lehrer"), variant-overrides: (print: (points: "all"), lehrer: (…))`],
  [Override-Schlüssel `datei:`], [`path:`],
  [`vorschau-alle: true`], [weglassen (`preview-variant: auto`)],
  [`vorschau-alle: false`], [`preview-variant: none`],
  [`dateiname:`], [`filename:`],
  [`fach:`, `thema:`, `jahrgang:`, `stufe:`], [`subject:`, `topic:`, `years:`, `stage:`],
  [`niveau: "einfuehrung"`, `"vertiefung"`], [`level: "introduction"`, `"consolidation"`],
  [`typ: "arbeitsblatt"`, `"uebung"`, `"stationsarbeit"`, `"klausur"`], [`kind: "worksheet"`, `"practice"`, `"stations"`, `"exam"`],
  [`stichworte:`, `kerncurriculum:`, `stand:`], [`keywords:`, `curriculum:`, `revision:`],
  [`header-font-size:`, `subtitle:`, `erwartungen:`, `klausurboegen:` (seit 0.1.0 wirkungslos)], [entfallen; Titelgröße: `title-font-size`],
)

Die Dateinamen des Bündels bleiben deutsch (`druck.pdf`, `digital.pdf`, `loesung.pdf`, `zweifach.pdf`), ebenso `--input vorschau=alle` und `<ab-meta>`.

== Übrige Parameter

#table(
  columns: (auto, auto, 1fr),
  [*Funktion*], [*bis 0.4.0*], [*ab 0.5.0*],
  [`lsg`], [`platz:`, `sonst:`], [`reserve:`, `fallback:`],
  [`minipage`], [`spacing:`], [`gutter:`],
  [`minipage`], [weitere Argumente von `table` (`stroke`, `row-gutter` …)], [entfallen; `inset` und `align` bleiben],
  [`icon-link`], [`icon-link(url, "Text", color: red)`], [`icon-link(url, fill: red)[Text]`],
  [`qr-code`], [`dark-color:`, `light-color:`, `background:`], [`fill:`, `background-fill:`],
  [`qr-code`], [`alt:`], [entfällt (war wirkungslos)],
  [`qr-box`], [weitere Argumente von `stickybox`], [entfallen; `rotation` bleibt],
  [`workspace`], [`height:`], [entfällt (war wirkungslos)],
  [`conditional-pagebreak`], [`loesungen-only: true`], [`solutions-visible: true` (gilt für jede sichtbare Lösung)],
  [Kästen], [`headless: true`], [`title: none`],
  [Kästen], [`accent-color:`], [`accent:`],
  [Kästen], [`icon:` und weitere Argumente von gentle-clues], [entfallen],
  [`teilaufgaben`], [`tasks:`, `loesungen:`], [`items:`, `item-solutions:`],
  [`canvas`], [weitere Argumente von cetz (`baseline`, `debug` …)], [entfallen; `length` und `padding` bleiben],
  [`qty`, `num`, `unit`], [weitere Argumente von unify (`thousandsep` …)], [entfallen; `per` bleibt],
)

== Themes

#table(
  columns: (auto, 1fr),
  [*bis 0.4.0*], [*ab 0.5.0*],
  [Theme-Funktion `(akzent, class) => …`], [`(accent: auto, class: none) => …`],
  [`schrift: (text:, mathe:, groesse:, titel:)`], [`font:`, `math-font:`, `font-size:`, `title-font-size:` direkt im Theme],
  [`rand: (top:, bottom:, innen:, aussen:)`], [`margin: (top:, bottom:, inside:, outside:)`],
  [`rand: (kopf-oben: …)`], [`header-top: …` direkt im Theme],
  [`kopf: (title:, class:, copyright:, font-size:) => …`], [`header: (title:, class:, copyright-url:, font-size:) => …`],
  [`fuss`, `hintergrund`], [`footer`, `background`],
  [`hintergrund: (print:, oben:, rand:) => …`], [`background: (print:, margin:, header-top:) => …`],
  [`marke: n => …`, `marke-breite`], [`task-marker: task-number => …`, `task-marker-width`],
  [`aufgabe: (nummer:, titel:, icons:, punkte:, large:, number:) => …`], [`task: (marker:, title:, icons:, points:, large:) => …`; `marker` ist die Nummer als Inhalt oder `none`],
  [`teilaufgabe: lbl => …`], [`subtask: marker => …`],
  [`loesung: (titel, body) => …`], [`solution: (title: none, body) => …`],
  [`loesung-kopf`, `material-kopf`], [`solution-heading`, `material-heading`],
  [`kasten: (art:, titel:, farbe:, breakable:, width:, body) => …`], [`callout: (kind:, title:, accent:, breakable:, width:, body) => …`],
)

Typst kann die Signatur einer Funktion nicht vorab prüfen. Hat eine Theme-Funktion oder ein Hook noch die alte Signatur, meldet deshalb Typst selbst den Fehler, ohne Hinweis auf den neuen Namen:

#table(
  columns: (auto, 1fr),
  [*Meldung von Typst*], [*Ursache und Abhilfe*],
  [`missing argument: akzent`], [Theme-Funktion mit Positionsparametern; `(accent: auto, class: none) => …` schreiben],
  [`unexpected argument: accent`], [Theme-Funktion ohne den benannten Parameter `accent`],
  [`unexpected argument: copyright-url`], [Hook `header` nennt noch `copyright:`],
  [`unexpected argument: margin` oder `header-top`], [Hook `background` nennt noch `rand:` und `oben:`],
  [`unexpected argument: marker`, `title` oder `points`], [Hook `task` nennt noch `nummer:`, `titel:`, `punkte:`, `number:`],
  [`missing argument: body` oder `unexpected argument: title`], [Hook `solution` nimmt den Titel noch als Positionsargument; `(title: none, body) => …` schreiben],
  [`unexpected argument: kind`, `title` oder `accent`], [Hook `callout` nennt noch `art:`, `titel:`, `farbe:`],
)

== Was nicht mehr weitergereicht wird

Bis 0.4.0 standen durch `#import "@schule/arbeitsblatt:0.4.0": *` alle Namen von cetz, cetz-plot, codly, colorful-boxes, fontawesome, gentle-clues, zero, eqalc und der Schwesterpakete im Dokument. Ab 0.5.0 reicht das Paket nur die Namen aus dem Abschnitt „Was das Paket weiterreicht" weiter. Wer etwas anderes benutzt, importiert es selbst:

#table(
  columns: (auto, 1fr),
  [*Benutzt*], [*Import im Dokument*],
  [`colorbox`, `slanted-colorbox`, `outline-colorbox`], [`#import "@preview/colorful-boxes:1.4.3": colorbox, slanted-colorbox`],
  [`code`, `task`, `clue`, `quotation` (Kästen)], [`#import "@preview/gentle-clues:1.2.0": code`],
  [`fa-arrow-right` und andere Kurzformen], [`fa-icon("arrow-right")` oder `#import "@preview/fontawesome:0.6.0": fa-arrow-right`],
  [`cetz.matrix`, `cetz.vector`, `chart`], [`#import "@preview/cetz:0.4.2"`, `#import "@preview/cetz-plot:0.1.3": chart`],
  [`codly(…)`, `local(…)`], [`#import "@preview/codly:1.3.0": codly, local`],
  [zero, eqalc], [`#import "@preview/zero:0.5.0" as zero`, `#import "@preview/eqalc:0.1.3": …`],
  [Bauteile für `schaltkreis` (`source`, `lamp`, `ammeter` …)], [`#import "@schule/physik:0.5.0": source, lamp, ammeter`],
  [`rand`, `randint`, `shuffle`], [`#import "@schule/random:0.0.1": rand, randint, shuffle`],
  [`blockst`, `scratch`], [`#import "@preview/blockst:…"` oder `@schule/informatik` direkt],
)

== Was sich am Ergebnis ändert

- `luecke` zeigt mit sichtbaren Lösungen das Lösungswort auf der Linie; `lücke` ließ die Linie auch in der Lösungsfassung leer.
- `minipage(gutter: …)` gilt für Spalten und Zeilen; `spacing` galt nur zwischen Spalten. Betroffen sind Aufrufe mit mehr Inhalten als Spalten.
- `conditional-pagebreak(solutions-visible: true)` wirkt bei jeder sichtbaren Lösung; `loesungen-only: true` wirkte nur im reinen Lösungsblatt.
- `two-up: true` ohne `print: true` und mit `paper: "a3"` ist ein Fehler.
- Mit einem Theme zeichnet die Kopfzeile den QR-Code aus `copyright-url`, und `two-up` benutzt den `header-ascent` des Themes.
- Ein Kasten ohne Inhalt (`#info()`) ist ein Fehler.
- `kind` und `level` nehmen nur noch die genannten Werte an.

== Für Paketautoren

Internes steht im Modul `internal` (`arbeitsblatt.internal.scope-state`, `resolve-theme`, die Parametertabelle `worksheet-parameters` …); der Kopf von `src/internal.typ` beschreibt die Schnittstelle, die `klassenarbeit` benutzt. Sie ist nicht zugesichert und kann sich mit jeder Version ändern. Dokumente benutzen sie nicht.

Die Kopfparameter von `arbeitsblatt` und `arbeitsblatt-einzeln` stehen einmal in `src/internal/parameters.typ`; Signaturen und Docstrings schreibt `scripts/signaturen.py`.

= Referenz

== Vorlagen

#show-module(read("../src/worksheet.typ"), name: "arbeitsblatt", only: ("arbeitsblatt", "arbeitsblatt-einzeln"), sort: false)

== Helfer

#show-module(
  read("../src/helpers.typ"),
  name: "helpers",
  only: (
    "luecke", "lsg", "workspace", "minipage", "conditional-pagebreak", "qr-code", "qr-box", "icon-link", "canvas", "qty",
    "num", "unit",
  ),
  sort: false,
)

== Kästen

Alle fünfzehn Kästen haben die Signatur von `info`.

#show-module(read("../src/callouts.typ"), name: "callouts", only: ("info",))

== Themes

#show-module(read("../src/internal.typ"), name: "themes", only: ("callout-style", "subject-accents", "subject-names"))
