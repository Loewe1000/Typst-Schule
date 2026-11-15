#import "@schule/schuldocs:0.3.1": show-example, show-module, show-code
#import "../src/lib.typ" as summify-lib

// Setzt ein Beispiel aus seinem Quelltext: was im Handbuch steht, wird auch
// ausgeführt. Jedes Beispiel beginnt mit dem Thema "default" und sichtbaren
// Inhalten; die Höhe ersetzt die Seite, die `summify` sonst vorgibt.
#let example(source, height: 4.5cm, visible: true) = show-example(
  rendered: {
    summify-lib.set-theme("default")
    summify-lib.internal.visible-state.update(visible)
    set text(font: "New Computer Modern Sans", size: 10pt)
    block(height: height, width: 100%, breakable: false, eval(
      source.text,
      mode: "markup",
      scope: dictionary(summify-lib),
    ))
  },
  source: source,
)

= Über dieses Paket

Das `summify`-Paket setzt Zusammenfassungen und Spickzettel für den Unterricht:
eine Seite (in der Vorgabe A3 quer), gegliedert in farbige Themenboxen mit
Abschnitten und Zellen. Es eignet sich für Formelsammlungen, Abitur-Zusammenfassungen
und die Vorbereitung auf Klausuren.

Die Bestandteile:

- `summify(…)` richtet Seite, Kopfzeile und Thema ein.
- `topic(…)` ist eine Themenbox mit farbigem Reiter.
- `section[…]` ist eine Abschnittsüberschrift innerhalb einer Themenbox.
- `cell[…]` ist eine Zelle mit Inhalt, auf Wunsch mit eigener Überschrift.
- `beside` und `below` ordnen Themenboxen nebeneinander und untereinander an.
- `cell-columns` und `cell-rows` ordnen Zellen an und ziehen Trennlinien dazwischen.
- `themes` enthält die vordefinierten Farbthemen `"default"`, `"modern-blue"`,
  `"warm-sunset"` und `"dark-pro"`.

Wer von einer älteren Version kommt, findet die Zuordnung der Namen im
Abschnitt „Umstieg auf 0.5.0".

= Schnellstart

`summify` richtet die ganze Seite ein und wird deshalb als Show-Regel an den
Anfang des Dokuments gesetzt. Der Inhalt füllt genau eine Seite:

#show-code[```typ
#import "@schule/summify:0.5.0": *

#show: summify.with(
  title: [Physik – Mechanik],
  theme: "modern-blue",
)

#beside[
  #topic(title: [Kinematik])[
    #section[Gleichförmige Bewegung]
    #cell[$s = v dot t$]
    #section[Gleichmäßig beschleunigte Bewegung]
    #cell[$s = 1/2 a t^2$]
    #cell[$v = a dot t$]
  ]
][
  #topic(title: [Dynamik])[
    #section[Newtonsche Gesetze]
    #cell[
      1. #emph[Trägheitsprinzip]: Kein $F$, kein $a$\
      2. $F = m dot a$\
      3. Actio = Reactio
    ]
    #section[Arbeit und Energie]
    #cell[$W = F dot s dot cos(alpha)$]
    #cell[$E_"kin" = 1/2 m v^2$]
  ]
]
```]

Die folgenden Beispiele zeigen jeweils nur den Teil unterhalb der Show-Regel.

= Themenboxen, Abschnitte, Zellen

Eine Themenbox (`topic`) fasst einen Bereich zusammen. Darin wechseln sich
Abschnittsüberschriften (`section`) und Zellen (`cell`) ab:

#example(```typ
#topic(title: [Mechanik])[
  #section[Newtonsche Gesetze]
  #cell[$F = m dot a$]
  #section[Energie]
  #cell[$E_"kin" = 1/2 m v^2$]
]
```)

Eine Zelle kann ihre Überschrift selbst mitbringen (`title`) und ihren Inhalt
ausrichten (`align`):

#example(```typ
#topic(title: [Kinematik])[
  #cell(title: [Geschwindigkeit], align: center)[$v = s / t$]
]
```)

Ohne `title` entfällt der Reiter der Themenbox. Höhe und Breite lassen sich
festlegen, ebenso Füllung, Rahmen und Eckenradius; ohne Angabe bestimmt sie das
Thema:

#example(```typ
#topic(height: 2cm, width: 60%, stroke: 1.5pt + blue, radius: 2pt)[
  #cell[Ohne Reiter, mit eigenem Rahmen]
]

#topic(title: [Eigene Farbe], height: 2cm, fill: green.darken(20%))[
  #section(fill: green.lighten(80%), height: 5mm)[Abschnitt]
]
```)

= Anordnung

== Themenboxen: `beside` und `below`

`beside` setzt seine Inhalte nebeneinander, `below` untereinander. Der Abstand
kommt aus dem Thema (`spacing.topic`) oder aus `gutter`; `ratios` verteilt
den Platz wie die Spaltenangabe von `grid`:

#example(```typ
#beside(ratios: (2fr, 1fr))[
  #topic(title: [Breit])[#cell[zwei Drittel]]
][
  #topic(title: [Schmal])[#cell[ein Drittel]]
]
```)

#example(height: 6cm, ```typ
#below(gutter: 2mm)[
  #topic(title: [Oben])[#cell[erste Zeile]]
][
  #topic(title: [Unten])[#cell[zweite Zeile]]
]
```)

== Zellen: `cell-columns` und `cell-rows`

Innerhalb einer Themenbox ordnen `cell-columns` und `cell-rows` Zellen an und
ziehen Trennlinien dazwischen. Der Abstand kommt hier aus `spacing.section`:

#example(```typ
#topic(title: [Bewegungen])[
  #cell-columns[
    #cell(title: [Weg])[$s = v dot t$]
  ][
    #cell(title: [Geschwindigkeit])[$v = a dot t$]
  ]
]
```)

#example(```typ
#topic(title: [Newton])[
  #cell-rows[
    #cell[Trägheitsprinzip]
  ][
    #cell[$F = m dot a$]
  ][
    #cell[Actio = Reactio]
  ]
]
```)

== Die allgemeine Form: `cell-grid`

Die vier Funktionen oben sind Kurzformen von `cell-grid`. Dort sind Richtung
und Trennlinien frei wählbar:

#example(```typ
#cell-grid(direction: "horizontal", dividers: true, gutter: 4mm)[
  #topic(title: [Links])[#cell[a]]
][
  #topic(title: [Rechts])[#cell[b]]
]
```)

= Lernmodus

Mit `visible: false` blendet `summify` die Inhalte aller Zellen aus. Rahmen,
Abschnitte und Überschriften bleiben stehen, der Platz bleibt frei – so wird
aus der Zusammenfassung ein Blatt zum Ausfüllen:

#show-code[```typ
#import "@schule/summify:0.5.0": *

#show: summify.with(
  title: [Physik – zum Ausfüllen],
  theme: "warm-sunset",
  visible: false,
)

#topic(title: [Mechanik])[
  #cell(title: [Kraft])[$F = m dot a$]
  #cell(title: [Impuls])[$p = m dot v$]
]
```]

Eine einzelne Zelle kann davon abweichen: `visible: true` zeigt sie auch im
Lernmodus, `visible: false` versteckt sie immer.

#example(visible: false, ```typ
#topic(title: [Mechanik])[
  #cell-columns[
    #cell(title: [Kraft])[$F = m dot a$]
  ][
    #cell(title: [Impuls], visible: true)[$p = m dot v$]
  ]
]
```)

= Themen

== Vordefinierte Themen

`theme` nimmt den Namen eines Themas aus `themes`:

#show-code[```typ
#import "@schule/summify:0.5.0": *

#show: summify.with(
  title: [Meine Zusammenfassung],
  theme: "modern-blue",
)

#topic(title: [Thema])[#cell[Inhalt]]
```]

#table(
  columns: (auto, 1fr),
  table.header([*Name*], [*Charakter*]),
  [`"default"`], [Grau und Schwarz, schlicht],
  [`"modern-blue"`], [kräftiges Blau, sachlich],
  [`"warm-sunset"`], [Bernstein und Orange, größere Radien],
  [`"dark-pro"`], [fast schwarze Reiter, dunkle Abschnittsleisten],
)

#example(```typ
#beside[
  #set-theme("modern-blue")
  #topic(title: [modern-blue])[#section[Abschnitt] #cell[Inhalt]]
][
  #set-theme("warm-sunset")
  #topic(title: [warm-sunset])[#section[Abschnitt] #cell[Inhalt]]
][
  #set-theme("dark-pro")
  #topic(title: [dark-pro])[#section[Abschnitt] #cell[Inhalt]]
]
```)

== Einzelne Werte überschreiben

`theme-overrides` legt einzelne Werte über das gewählte Thema. Angegeben wird
nur, was sich ändert:

#show-code[```typ
#import "@schule/summify:0.5.0": *

#show: summify.with(
  title: [Physik],
  theme: "modern-blue",
  theme-overrides: (
    colors: (primary: rgb("#e74c3c")),  // rote Reiter
    sizes: (radius: 0pt),               // eckige Boxen
  ),
)

#topic(title: [Thema])[#cell[Inhalt]]
```]

Mitten im Dokument leisten `set-theme` und `set-theme-overrides` dasselbe; sie
gelten für alles, was danach kommt:

#example(```typ
#beside[
  #topic(title: [Vorher])[#section[Abschnitt] #cell[Inhalt]]
][
  #set-theme-overrides(
    colors: (primary: rgb("#e74c3c"), surface: rgb("#fde2e2")),
    sizes: (radius: 0pt),
  )
  #topic(title: [Nachher])[#section[Abschnitt] #cell[Inhalt]]
]
```)

== Aufbau eines Themas

Ein Thema ist ein Dictionary mit vier Gruppen. Unbekannte Schlüssel sind ein
Fehler; ein eigenes Thema für `theme` oder `set-theme` muss alle Schlüssel
enthalten.

#table(
  columns: (auto, auto, 1fr),
  table.header([*Gruppe*], [*Schlüssel*], [*Bedeutung*]),
  [`colors`], [`primary`], [Füllung der Reiter],
  [], [`on-primary`], [Textfarbe auf den Reitern],
  [], [`surface`], [Füllung der Abschnittsleisten],
  [], [`border`], [Rahmenfarbe der Themenboxen],
  [`spacing`], [`page`], [Seitenränder: `(x: …, y: …, top: …)`],
  [], [`topic`], [Abstand in `beside`, `below`, `cell-grid`],
  [], [`section`], [Abstand in `cell-columns`, `cell-rows`],
  [], [`cell`], [Innenabstand der Zellen],
  [`sizes`], [`title`], [Reiter: `(height: …, font-size: …)`],
  [], [`header`], [Abschnittsleiste: `(height: …, font-size: …)`],
  [], [`border`], [Rahmenstärke],
  [], [`radius`], [Eckenradius],
  [`typography`], [`font`, `math-font`], [Schrift für Text und Formeln],
  [], [`font-size`], [Grundschriftgröße],
  [], [`weights`], [Schriftstärken: `(title: …, header: …)`],
)

Ein eigenes Thema entsteht am einfachsten aus einem vorhandenen:

#show-code[```typ
#import "@schule/summify:0.5.0": *

#let forest = themes.default
#(forest.colors = (
  primary: rgb("#166534"),
  on-primary: white,
  surface: rgb("#dcfce7"),
  border: rgb("#14532d"),
))

#show: summify.with(title: [Biologie], theme: forest)

#topic(title: [Ökosystem Wald])[#section[Stockwerke] #cell[Inhalt]]
```]

= Fehlermeldungen

Jede Funktion prüft ihre Argumente. Ein unbekannter Name bricht mit einem
Vorschlag ab, ein Name aus einer älteren Version mit dem neuen Namen:

#show-code[```
summify.summify: unbekannter Parameter `titel` – meintest du `title`?
summify.summify: `flipped` heißt jetzt `landscape`
summify.content: `content` heißt jetzt `cell`
summify.cell-grid: `direction: "diagonal"` ist kein gültiger Wert – erlaubt: `"horizontal"`, `"vertical"`
```]

= Umstieg auf 0.5.0

Version 0.5.0 ändert nur Namen; ein Dokument sieht nach dem Umstieg genauso aus
wie vorher. Wer einen alten Namen schreibt, bekommt beim Kompilieren die
Meldung „heißt jetzt" mit dem neuen Namen.

== Funktionen

#table(
  columns: (1fr, 1fr),
  table.header([*bis 0.1.0*], [*ab 0.5.0*]),
  [`content[…]`], [`cell[…]`],
  [`cols[…][…]`], [`cell-columns[…][…]`],
  [`rows[…][…]`], [`cell-rows[…][…]`],
  [`compose(…)[…][…]`], [`cell-grid(…)[…][…]`],
  [`update-theme(colors: (…))`], [`set-theme-overrides(colors: (…))`],
  [`summify`, `topic`, `section`, `beside`, `below`, `set-theme`, `themes`], [unverändert],
)

== Parameter

#table(
  columns: (3fr, 2fr, 2fr),
  table.header([*Funktion*], [*bis 0.1.0*], [*ab 0.5.0*]),
  [`summify`], [`flipped: true`], [`landscape: true`],
  [], [`hide-content: true`], [`visible: false`],
  [], [`title: ""`], [`title: none` oder weglassen],
  [`cell` (alt `content`)], [`align-content: center`], [`align: center`],
  [], [`hide: true`], [`visible: false`],
  [], [`hide: false`], [`visible: true`],
  [`beside`, `below`, `cell-columns`, `cell-rows`, `cell-grid`], [`gap: 2mm`], [`gutter: 2mm`],
  [`cell-grid` (alt `compose`)], [`lines: true`], [`dividers: true`],
  [`beside`, `below`], [`lines: true`], [`cell-grid(direction: …, dividers: true)`],
  [`cell-columns`, `cell-rows`], [`lines: false`], [`cell-grid(direction: …)`],
)

== Schlüssel im Thema

#table(
  columns: (1fr, 1fr),
  table.header([*bis 0.1.0*], [*ab 0.5.0*]),
  [`spacing: (content: …)`], [`spacing: (cell: …)`],
  [`sizes: (title: (text: …))`], [`sizes: (title: (font-size: …))`],
  [`sizes: (header: (text: …))`], [`sizes: (header: (font-size: …))`],
  [`typography: (base-size: …)`], [`typography: (font-size: …)`],
)

Die Meldung nennt den ganzen Weg des Schlüssels:

#show-code[```
summify.summify: Schlüssel `spacing.content` in `theme-overrides` heißt jetzt `spacing.cell`
```]

== Was sich sonst geändert hat

- Der Lernmodus funktioniert: in 0.1.0 brach `hide-content: true` mit einem
  Fehler ab.
- Unbekannte Parameter, unbekannte Schlüssel im Thema und ein unbekannter Wert
  für `direction` sind Fehler; früher wurden sie still übergangen.
- `beside`, `below`, `cell-columns` und `cell-rows` nehmen nur noch `gutter`
  und `ratios`. In 0.1.0 reichten sie jeden weiteren Namen ungenannt an
  `compose` weiter, `beside(lines: true)` setzte also Trennlinien. Dafür steht
  jetzt `cell-grid(direction: "horizontal", dividers: true)`; die Meldung zu
  `lines` nennt den passenden Aufruf.
- `topic(radius: …)` nimmt ein Dictionary mit einzelnen Ecken weiterhin nur
  ohne `title`; mit Titel kommt statt eines Typst-Fehlers eine eigene Meldung.
- Wer `#import "@schule/summify:0.5.0": *` schreibt, bekommt für die
  Übergangszeit auch die alten Namen `content`, `cols`, `rows`, `compose` und
  `update-theme` – als Funktionen, die mit „heißt jetzt" abbrechen.

= API-Referenz

#show-module(
  read("../src/summify.typ"),
  name: "summify",
  sort: false,
  only: (
    "summify", "topic", "section", "cell",
    "beside", "below", "cell-columns", "cell-rows", "cell-grid",
    "set-theme", "set-theme-overrides",
  ),
)

#show-module(read("../src/themes.typ"), name: "summify-themes")
