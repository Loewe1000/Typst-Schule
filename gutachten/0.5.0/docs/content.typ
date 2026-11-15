#import "@schule/schuldocs:0.3.1": show-code, show-module

= Über dieses Paket

Das `gutachten`-Paket setzt *Gutachten über schriftliche Prüfungen*, wie sie
im Abitur zu jeder Arbeit geschrieben werden. Es führt den Namen des
Prüflings im Kopf, zählt die erreichten Bewertungseinheiten (BE) der Aufgaben
zusammen und rechnet die Summe in die Note der Oberstufe um (0 bis 15 Punkte).

Das Paket stellt sechs Namen bereit:

- `set-options(...)` — Angaben für alle Gutachten des Dokuments: Fach, Niveau, Kürzel, Gesamtpunktzahl, Schriften.
- `set-tasks(...)` — die Aufgaben der Prüfung mit ihren erreichbaren Bewertungseinheiten.
- `gutachten(...)[...]` — das Gutachten für einen Prüfling: Kopf, Inhalt, Summe, Note, Unterschriftszeilen.
- `aufgabe(...)[...]` — der Abschnitt zu einer Aufgabe mit den erreichten Bewertungseinheiten.
- `name` — der Vorname des Prüflings für den Fließtext (ein Wert, ohne Klammern).
- `format-grade(...)` — rechnet einen Anteil in die Note um, zum Beispiel `"gut (11 Punkte)"`.

Die Namen der Funktionen `gutachten` und `aufgabe` sind deutsch, alles in den
Klammern ist englisch. Texte im PDF sind deutsch.

= Schnellstart

Ein vollständiges Gutachten:

#show-code[```typ
#import "@schule/gutachten:0.5.0": *

// 1. Angaben für alle Gutachten
#set-options(
  subject: "Physik",
  level: "E",
  teacher: "MS",
  max-points: 100,   // Gesamtpunktzahl der Prüfung
)

// 2. Aufgaben mit ihren erreichbaren Bewertungseinheiten
#set-tasks((
  "Aufgabe 1": (max-points: 30),
  "Aufgabe 2": (max-points: 40),
  "Aufgabe 3": (max-points: 30),
))

// 3. Gutachten für eine Schülerin
#gutachten(first-name: "Anna", last-name: "Bauer")[
  #aufgabe("Aufgabe 1", points: 25)[
    #name beschreibt die Bewegung korrekt. Volle Punktzahl für Teilaufgabe a).
  ]
  #aufgabe("Aufgabe 2", points: 35)[
    Formeln korrekt angewendet. Kleiner Rechenfehler in b).
  ]
  #aufgabe("Aufgabe 3", points: 28)[
    Interpretation vollständig und präzise.
  ]
]
```]

Am Ende des Gutachtens steht: „Insgesamt erreicht der Prüfling *88* von *100*
Bewertungseinheiten (88 %). Daher bewerte ich die Arbeit mit *sehr gut (13
Punkte)*.“ Darunter folgen die Unterschriftszeilen.

= Angaben für alle Gutachten

`set-options` setzt die Angaben, die in allen Gutachten des Dokuments gelten.
Der Aufruf ist Pflicht; ohne ihn bricht `gutachten` mit einer Meldung ab.

#show-code[```typ
#import "@schule/gutachten:0.5.0": set-options

#set-options(
  subject: "Mathematik",              // Fach im Kopf
  level: "G",                         // Kursniveau, steht im Kopf in Klammern
  teacher: "AB",                      // Kürzel der Lehrkraft
  max-points: 100,                    // Gesamtpunktzahl der Prüfung
  year: 2027,                         // Abiturjahr; ohne Angabe das laufende Jahr
  anonymous: false,                   // true: „Schüler“ statt jedes Namens
  print: false,                       // true: Unterschriftslinie für die Zweitkorrektur
  font: "New Computer Modern Sans",   // Schrift des Textes
  math-font: "Fira Math",             // Schrift der Formeln
)
```]

- `max-points` ist die Gesamtpunktzahl der Prüfung. Sie wird nicht aus den
  Aufgaben berechnet, weil bei Wahlaufgaben nicht jede Aufgabe zählt. Die
  Vorgabe `1` ist nur ein Platzhalter; ohne Angabe stimmen Prozentwert und
  Note nicht.
- `print: false` setzt über die rechte Unterschriftszeile den grauen Vermerk
  „Mit Korrektur und Bewertung einverstanden“. `print: true` setzt an seine
  Stelle eine Linie zum Ausfüllen von Hand.
- `anonymous: true` ersetzt Vor- und Nachname überall durch „Schüler“: im
  Kopf, im Satz zur Aufgabenwahl, in den Punktesätzen und bei `#name`.
- Ein weiterer Aufruf von `set-options` ersetzt alle Angaben; was dort fehlt,
  steht wieder auf seiner Vorgabe. Es gilt der letzte Aufruf im Dokument.

Die Schriften „New Computer Modern Sans“ und „Fira Math“ müssen auf dem
Rechner installiert sein; fehlt eine, warnt Typst und nimmt eine
Ersatzschrift.

= Aufgaben festlegen

`set-tasks` bekommt ein Dictionary: Der Schlüssel ist der Aufgabenname, der
Wert nennt die erreichbaren Bewertungseinheiten. `aufgabe` greift über den
Namen darauf zu, deshalb müssen beide gleich geschrieben sein.

#show-code[```typ
#import "@schule/gutachten:0.5.0": set-tasks

#set-tasks((
  "Aufgabe 1": (max-points: 20),
  "Aufgabe 2A": (max-points: 30, title: "Analysis"),
  "Aufgabe 2B": (max-points: 30, title: "Stochastik"),
  "Pflichtteil": (max-points: 50, dative: "dem Pflichtteil"),
))
```]

Schlüssel je Aufgabe:

#table(
  columns: (auto, auto, 1fr),
  table.header([*Schlüssel*], [*Typ*], [*Bedeutung*]),
  [`max-points`], [int, float], [erreichbare Bewertungseinheiten der Aufgabe],
  [`dative`], [str, content], [Name im Dativ für den Satz „In *dem Pflichtteil* erreicht …“; ohne Angabe steht der Aufgabenname],
  [`title`], [str, content], [Thema der Aufgabe; `selected-tasks` nennt es hinter dem Namen („Aufgabe 2A: Analysis“)],
)

= Gutachten schreiben

`gutachten` setzt für jeden Prüfling ein eigenes Gutachten mit eigenem Kopf
und eigener Seitenzählung („1 von 2“). Mehrere Gutachten stehen einfach
hintereinander. `aufgabe` setzt die Überschrift, den Kommentar und den Satz
mit den erreichten Bewertungseinheiten; die Punkte aller Aufgaben werden
zusammengezählt.

#show-code[```typ
#import "@schule/gutachten:0.5.0": *

#set-options(subject: "Mathematik", level: "E", teacher: "AB", max-points: 80)

#set-tasks((
  "Aufgabe 1": (max-points: 20),
  "Aufgabe 2": (max-points: 30, title: "Analysis"),
  "Aufgabe 3": (max-points: 30, title: "Stochastik"),
  "Aufgabe 4": (max-points: 30, title: "Geometrie"),
))

#gutachten(first-name: "Max", last-name: "Mustermann")[
  #aufgabe("Aufgabe 1", points: 18)[#name hat die Aufgabe größtenteils korrekt bearbeitet.]
  #aufgabe("Aufgabe 2", points: 27)[Kleiner Fehler bei der Einheit.]
  #aufgabe("Aufgabe 3", points: 22.5)[Die Begründung in c) fehlt.]
]

// selected-tasks: Welche Aufgaben hat die Schülerin gewählt?
#gutachten(
  first-name: "Lena",
  last-name: "Braun",
  selected-tasks: ("Aufgabe 2", "Aufgabe 4"),
)[
  #aufgabe("Aufgabe 1", points: 20)[Volle Punktzahl.]
  #aufgabe("Aufgabe 2", points: 29)[Sehr gute Bearbeitung.]
  #aufgabe("Aufgabe 4", points: 24)[Teilweise unvollständig.]
]
```]

Mit `selected-tasks` beginnt das Gutachten mit dem Satz „Lena wählt _Aufgabe
2: Analysis_ und _Aufgabe 4: Geometrie_.“ Sind die Aufgaben nach
Prüfungsteilen geordnet, nimmt `selected-tasks` ein Dictionary:

#show-code[```typ
#import "@schule/gutachten:0.5.0": *

#set-options(subject: "Mathematik", level: "E", teacher: "AB", max-points: 60)

#set-tasks((
  "1A": (max-points: 30, title: "Analysis"),
  "2B": (max-points: 30, title: "Stochastik"),
))

#gutachten(
  first-name: "Lena",
  last-name: "Braun",
  selected-tasks: ("Pflichtteil": ("1A",), "Wahlteil": ("2B",)),
)[
  #aufgabe("1A", points: 21)[Der Ansatz stimmt, die Rechnung bricht ab.]
  #aufgabe("2B", points: 30)[Volle Punktzahl.]
]
```]

Das ergibt „Lena wählt im Pflichtteil _1A: Analysis_ und im Wahlteil _2B:
Stochastik_.“

Punktzahlen stehen mit Dezimalkomma im Text (`22.5` wird „22,5“), ganze Zahlen
unter 10 zweistellig („08“). Auch Dezimalzahlen in Formeln bekommen im
Gutachten ein Komma.

= Note berechnen

`format-grade` rechnet einen Anteil zwischen `0.0` und `1.0` in die Note der
Oberstufe um und liefert sie als Text. `gutachten` benutzt die Funktion für
den Schlusssatz; im Dokument steht sie für eigene Sätze oder Übersichten
bereit.

#show-code[```typ
#import "@schule/gutachten:0.5.0": format-grade

#format-grade(0.95)   // sehr gut (15 Punkte)
#format-grade(0.72)   // gut (10 Punkte)
#format-grade(0.50)   // ausreichend (06 Punkte)
#format-grade(0.30)   // mangelhaft (02 Punkte)
#format-grade(0.00)   // ungenügend (00 Punkte)

// Punkte durch Gesamtpunkte:
#let share = 72 / 100
#format-grade(share)  // gut (10 Punkte)
```]

Die Skala:

#show-code[```
≥ 95 %  → sehr gut  (15)      ≥ 55 % → befriedigend (07)
≥ 90 %  → sehr gut  (14)      ≥ 50 % → ausreichend  (06)
≥ 85 %  → sehr gut  (13)      ≥ 45 % → ausreichend  (05)
≥ 80 %  → gut       (12)      ≥ 40 % → ausreichend  (04)
≥ 75 %  → gut       (11)      ≥ 33 % → mangelhaft   (03)
≥ 70 %  → gut       (10)      ≥ 27 % → mangelhaft   (02)
≥ 65 %  → befriedigend (09)   ≥ 20 % → mangelhaft   (01)
≥ 60 %  → befriedigend (08)   < 20 % → ungenügend   (00)
```]

= Fehlermeldungen

Jede Funktion prüft ihre Argumente und bricht mit einer deutschen Meldung ab,
die den Fehler und die Abhilfe nennt:

#show-code[```
gutachten.set-options: `fach` heißt jetzt `subject`
gutachten.gutachten: unbekannter Parameter `vornam` – meintest du `first-name`?
gutachten.aufgabe: unbekannte Aufgabe `Aufgabe 9` – in `set-tasks` eintragen; bekannt: `Aufgabe 1`
gutachten.aufgabe: `points` fehlt – die erreichten Punkte angeben: `aufgabe("Aufgabe 1", points: 24)[...]`
gutachten.aufgabe: 2 Positionsargumente, erlaubt ist höchstens 1 – die erreichten Punkte benannt schreiben: `aufgabe("Aufgabe 1", points: 24)[...]`
gutachten.set-tasks: unbekannter Schlüssel `thema` – erlaubt: `max-points`, `dative`, `title`
gutachten.gutachten: `selected-tasks`: der Prüfungsteil `Wahlteil` braucht eine Liste – `("Wahlteil": ("2A",))` schreiben
gutachten.set-options: `subject: ""` – für „kein Fach" `none` schreiben oder weglassen
```]

= Erwartungshorizont (intern)

Bis 0.0.2 lag dem Paket eine Datei `bewertung.typ` mit Helfern für
Erwartungshorizont, Bewertungstabelle und Notenspiegel bei. Sie war über den
Paketnamen nicht erreichbar und kompilierte unter Typst 0.15 nicht mehr. In
0.5.0 ist sie repariert und liegt im Modul `internal`. `internal` ist keine
zugesicherte Schnittstelle: Namen und Gestalt dürfen sich in jeder Version
ändern, und das Gutachten selbst füllt die Daten dafür nicht. Wer die Helfer
benutzt, trägt Aufgaben und Erwartungen selbst ein:

#show-code[```typ
#import "@schule/gutachten:0.5.0": internal

#internal.expectation-tasks.update((
  (task-number: 1, subtask-count: 2, title: "Kinematik"),
  (task-number: 2, subtask-count: 0, title: "Felder"),
))
#internal.expectations.update((
  (task-number: 1, subtask-number: 1, text: [berechnet die Geschwindigkeit], points: 4),
  (task-number: 1, subtask-number: 2, text: [zeichnet das Diagramm], points: 6),
  (task-number: 2, subtask-number: 0, text: [beschreibt das Feld], points: 10),
))

#internal.points-table()        // Bewertungstabelle
#internal.grade-table()         // Notenspiegel der Oberstufe
#internal.expectations-sek-2()  // Erwartungshorizont der Oberstufe, eigene Seite
```]

= Umstieg auf 0.5.0

Version 0.5.0 ändert Namen, nicht das Ergebnis: Dasselbe Gutachten sieht nach
dem Umstieg genauso aus wie mit 0.0.2. Die Funktionen `gutachten` und
`aufgabe` und der Wert `name` behalten ihre Namen; alles in den Klammern ist
jetzt englisch. Ein alter Name bricht beim Kompilieren mit einer Meldung ab,
die den neuen nennt.

*Funktionen*

#table(
  columns: (1fr, 1fr),
  table.header([*alt (0.0.2)*], [*neu (0.5.0)*]),
  [`#import "@schule/gutachten:0.0.2": *`], [`#import "@schule/gutachten:0.5.0": *`],
  [`set-gutachten-infos(...)`], [`set-options(...)`],
  [`set-aufgaben((...))`], [`set-tasks((...))`],
  [`bewertungsskala(0.75)`], [`format-grade(0.75)`],
  [`gutachten(...)[...]`], [`gutachten(...)[...]` (Name unverändert)],
  [`aufgabe("Aufgabe 1", 24)[...]`], [`aufgabe("Aufgabe 1", points: 24)[...]`],
  [`name`], [`name` (unverändert)],
)

*Parameter von `set-options` (früher `set-gutachten-infos`)*

#table(
  columns: (1fr, 1fr, 1.4fr),
  table.header([*alt*], [*neu*], [*Hinweis*]),
  [`fach: ""`], [`subject: none`], [leerer Text ist ein Fehler; `none` oder weglassen. Der Kopf sieht ohne Angabe aus wie bisher],
  [`niveau: ""`], [`level: none`], [wie `subject`],
  [`kürzel: ""`], [`teacher: none`], [wie `subject`],
  [`anonym: false`], [`anonymous: false`], [],
  [`print: false`], [`print: false`], [unverändert],
  [`be: 1`], [`max-points: 1`], [Gesamtpunktzahl der Prüfung],
  [`font`, `math-font`], [`font`, `math-font`], [unverändert],
  [`jahr: auto`], [`year: auto`], [Zahl, Text oder Inhalt],
)

*Schlüssel in `set-tasks` (früher `set-aufgaben`)*

#table(
  columns: (1fr, 1fr, 1.4fr),
  table.header([*alt*], [*neu*], [*Hinweis*]),
  [`be: 30`], [`max-points: 30`], [erreichbare Bewertungseinheiten der Aufgabe],
  [`dativ: "…"`], [`dative: "…"`], [],
  [`name: "…"`], [`title: "…"`], [Thema der Aufgabe],
)

*Parameter von `gutachten` und `aufgabe`*

#table(
  columns: (1fr, 1fr, 1.4fr),
  table.header([*alt*], [*neu*], [*Hinweis*]),
  [`vorname: "Max"`], [`first-name: "Max"`], [],
  [`nachname: "Mustermann"`], [`last-name: "Mustermann"`], [],
  [`wahl: ()`], [`selected-tasks: ()`], [Array oder Dictionary wie bisher],
  [`aufgabe(name, punkte)[...]`], [`aufgabe(name, points: punkte)[...]`], [die erreichten Punkte stehen benannt],
)

*Was sonst anders ist*

- Das Paket reicht `@preview/unify` nicht mehr weiter. Wer `qty`, `num` oder
  `unit` im Gutachten benutzt, importiert unify selbst.
- Fehlt `set-options`, fehlt eine Aufgabe in `set-tasks` oder steht `#name`
  außerhalb eines Gutachtens, bricht das Paket mit einer deutschen Meldung ab
  (bisher ein roher Typst-Fehler).
- `set-tasks` prüft die Schlüssel jeder Aufgabe. Erlaubt sind `max-points`,
  `dative` und `title`; ein anderer Schlüssel (`thema: "…"`) bricht ab, 0.0.2
  überging ihn still. Ebenso bricht ein Eintrag ab, der kein Dictionary ist
  (`"Aufgabe 1": 30`), und ein `max-points`, das keine Zahl ist.
- `selected-tasks` prüft seine Gestalt: Aufgabennamen als Text, im Dictionary
  je Prüfungsteil eine Liste (`("Wahlteil": ("2A",))`, mit Komma).
- Die Namen aus 0.0.1 (`gutachten-optionen`, `sachgebiet`, `pflichtteil`,
  `geschlecht:`, `prüfer:`, `korreferent:`) brechen mit einem Hinweis ab; die
  Funktionen dazu gibt es seit 0.0.2 nicht mehr.
- `bewertung.typ` ist repariert und liegt im Modul `internal` (Abschnitt
  „Erwartungshorizont“).

Ein Gutachten aus 0.0.2 und dasselbe in 0.5.0:

#show-code[```typ
#import "@schule/gutachten:0.0.2": *

#set-gutachten-infos(fach: "Physik", niveau: "E", kürzel: "MS", be: 100)
#set-aufgaben(("Aufgabe 1": (be: 30)))
#gutachten(vorname: "Anna", nachname: "Bauer", wahl: ("Aufgabe 1",))[
  #aufgabe("Aufgabe 1", 25)[Kommentar]
]
```]

#show-code[```typ
#import "@schule/gutachten:0.5.0": *

#set-options(subject: "Physik", level: "E", teacher: "MS", max-points: 100)
#set-tasks(("Aufgabe 1": (max-points: 30)))
#gutachten(first-name: "Anna", last-name: "Bauer", selected-tasks: ("Aufgabe 1",))[
  #aufgabe("Aufgabe 1", points: 25)[Kommentar]
]
```]

= API-Referenz

#show-module(read("../src/gutachten.typ"), name: "gutachten")
