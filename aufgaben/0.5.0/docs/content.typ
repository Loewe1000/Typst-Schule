#import "@schule/schuldocs:0.3.1": info, show-code, show-example, show-module, tip, warning
#import "../src/lib.typ" as aufgaben

// Ein Beispiel, das wirklich gesetzt wird: Der Quelltext wird mit den Namen
// des Pakets ausgewertet. Vorher beginnen Zählung und Optionen neu, damit
// jedes Beispiel für sich steht.
#let example(source, width: 14cm) = show-example(
  rendered: {
    aufgaben.reset-tasks()
    aufgaben.set-options(..aufgaben.internal.option-defaults)
    eval(source.text, mode: "markup", scope: dictionary(aufgaben))
  },
  source: source,
  width: width,
)

= Über dieses Paket

Das Paket `aufgaben` ist das Fundament der Schule-Pakete. Es setzt nummerierte Aufgaben und Teilaufgaben, sammelt Lösungen, Materialien und Erwartungen und erzeugt daraus Lösungsblätter, den Erwartungshorizont und die Punktetabelle. Die Vorlagen `arbeitsblatt` und `klassenarbeit` reichen alle Funktionen dieses Pakets weiter; wer eine der Vorlagen benutzt, importiert `aufgaben` nicht selbst.

Die Bausteine heißen deutsch (`aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung`). Alles in den Klammern ist englisch: Parameter, Werte und Optionen. Englisch sind auch die Aktionen und Abfragen (`set-options`, `show-solutions`, `get-points` …).

Wer von einer älteren Version kommt, findet alle Namen im Abschnitt „Umstieg auf 0.5.0“.

= Schnellstart

```typ
#import "@schule/aufgaben:0.5.0": *

#aufgabe[
  Berechne die Summe von 15 und 27.
]
#loesung[$15 + 27 = 42$]

#aufgabe(title: [Bruchrechnung])[
  Berechne $3/4 + 1/2$.

  #teilaufgabe[Bestimme den Hauptnenner. #erwartung(1)[Hauptnenner 4 erkannt]]
  #teilaufgabe[Addiere die Brüche. #erwartung(1)[Ergebnis $5/4$]]
]
```

Das Paket bindet zwei fremde Pakete ein, `fontawesome` für die Symbole der Sozialformen und `gentle-clues` für den Lösungskasten. Es reicht keinen ihrer Namen weiter.

= Aufgaben

== Einfache Aufgabe

`aufgabe` setzt eine nummerierte Aufgabe. Die Nummer zählt von selbst weiter.

#example(```typ
#aufgabe[
  Berechne die Summe von 15 und 27.
]
```)

== Titel, Größe, Nummer

Der Titel steht als `title:` in den Klammern, der Aufgabentext als Inhalt dahinter.

#example(```typ
#aufgabe(title: [Addition])[
  Berechne die Summe von 15 und 27.
]

#aufgabe(title: [Zusatz], large: false)[
  Kleinere Überschrift.
]

#aufgabe(title: [Bonusaufgabe], number: false)[
  Diese Aufgabe hat keine Nummer.
]
```)

`large: true` ist die Vorgabe (Überschrift in 1.4em, sonst 1.2em). Einen leeren Titel gibt es nicht: Wer keinen Titel will, lässt `title` weg.

== Sozialform und Symbole

`method` setzt ein Symbol für die Sozialform vor die Überschrift, `icons` weitere Symbole.

#example(```typ
#aufgabe(method: "individual")[Einzelarbeit]
#aufgabe(method: "pair")[Partnerarbeit]
#aufgabe(method: "group", icons: (sym.star.filled,))[Gruppenarbeit]
```)

== Teilaufgaben

#example(```typ
#aufgabe(title: [Quadratische Gleichungen])[
  Löse die Gleichungen.

  #teilaufgabe[$x^2 - 5x + 6 = 0$]
  #teilaufgabe[$2x^2 + 7x - 4 = 0$]
  #teilaufgabe(marker: [★])[$x^2 - 9 = 0$]
]
```)

`marker` ersetzt die Nummer einer einzelnen Teilaufgabe durch eine eigene Beschriftung.

=== Nummerierung

Die Option `subtask-numbering` ist ein Typst-Muster. Hat es ein Zählzeichen, bekommt es die Nummer der Teilaufgabe; hat es zwei, bekommt es die Nummer der Aufgabe und die der Teilaufgabe.

#example(```typ
#set-options(subtask-numbering: "1.1")
#aufgabe(title: [Dezimal])[
  #teilaufgabe[erste Teilaufgabe]
  #teilaufgabe[zweite Teilaufgabe]
]
```)

#table(
  columns: (auto, 1fr),
  [*Muster*], [*Ergebnis in Aufgabe 3*],
  [`"a)"` (Start)], [a), b), c) …],
  [`"(i)"`], [(i), (ii), (iii) …],
  [`"1.1"`], [3.1, 3.2, 3.3 …],
  [`"1a)"`], [3a), 3b), 3c) …],
)

=== Mehrere Teilaufgaben im Raster

`teilaufgaben` setzt mehrere Teilaufgaben nebeneinander. Die Lösungen stehen in derselben Reihenfolge in `item-solutions`.

#example(```typ
#aufgabe(title: [Kopfrechnen])[
  #teilaufgaben(
    columns: 3,
    items: ([$2 + 3$], [$5 dot 7$], [$12 - 4$], [$9 : 3$], [$4^2$], [$sqrt(49)$]),
    item-solutions: ([$5$], [$35$], [$8$], [$3$], [$16$], [$7$]),
  )
]
```)

Mit einem anderen Muster als `"a)"` entstehen schlichte, so nummerierte Einträge, die den Zähler der Teilaufgaben nicht verändern, zum Beispiel eine Liste innerhalb einer Teilaufgabe:

```typ
#aufgabe[
  #teilaufgabe[
    Entscheide jeweils.
    #teilaufgaben(numbering: "i)", items: ([wahr oder falsch], [wahr oder falsch]))
  ]
]
```

=== Verweise

`label` setzt eine Marke an Aufgabe oder Teilaufgabe. Der Verweis folgt der Nummerierung.

```typ
#aufgabe(title: [Gleichung], label: <gleichung>)[
  #teilaufgabe(label: <umformen>)[Forme um.]
  #teilaufgabe[Nutze das Ergebnis aus @umformen.]
]

Siehe Aufgabe @gleichung.
```

== Arbeitsflächen

`workspace` setzt eine Arbeitsfläche unter die Aufgabe oder Teilaufgabe. Die Option `workspaces: false` lässt alle Arbeitsflächen weg, zum Beispiel in der Fassung mit Lösungen.

#example(```typ
#aufgabe(workspace: rect(width: 100%, height: 1.5cm))[
  Löse die Gleichung $3x + 7 = 22$.
]
```)

```typ
#set-options(workspaces: false)
#aufgabe[#teilaufgabe(workspace: v(3cm))[Zeichne ein Koordinatensystem.]]
```

Eine Fläche mit Bruchteilhöhe (ein `block(height: 1fr)`, etwa `kariert(rows: 1fr)` aus `patterns`) teilt sich den freien Platz der Seite mit anderen solchen Flächen.

= Lösungen

`loesung` erfasst eine Lösung. Sie gehört zur zuletzt begonnenen Teilaufgabe, sonst zur zuletzt begonnenen Aufgabe. Ob und wo sie erscheint, bestimmt die Option `solutions`.

#example(```typ
#set-options(solutions: "in-place")
#aufgabe(title: [Rechnen])[
  #teilaufgabe[Berechne $7 dot 8$. #loesung[$7 dot 8 = 56$]]
  #teilaufgabe[Berechne $50 - 17$. #loesung[$50 - 17 = 33$]]
]
```)

#table(
  columns: (auto, 1fr),
  [*`solutions`*], [*Wirkung*],
  [`none` (Start)], [Lösungen werden erfasst, aber nicht gezeigt.],
  [`"in-place"`], [Die Lösung steht direkt nach jeder Teilaufgabe.],
  [`"after-task"`], [Alle Lösungen einer Aufgabe stehen gesammelt nach der Aufgabe.],
  [`"at-end"`], [Die Lösungen stehen gesammelt dort, wo `show-solutions()` steht. Die Vorlagen setzen den Aufruf ans Dokumentende.],
  [`"only"`], [Nur Lösungen: Der Aufgabentext entfällt. Die Ausgabe übernimmt `show-solutions(select: "pending")`.],
)

Für `"at-end"` gibt es `solutions-pagebreak`: `"before"` beginnt den Lösungsblock auf einer neuen Seite, `"per-task"` setzt jede Aufgabe auf eine eigene Seite. Beide wirken nur mit `"at-end"`. Wer `solutions-pagebreak: "per-task"` im selben Aufruf mit einem anderen `solutions` schreibt, bekommt eine Meldung; allein gesetzt bleibt die Option ohne `"at-end"` wirkungslos, damit eine Fassung ohne Lösungen dieselbe Einstellung behalten kann.

#example(```typ
#set-options(solutions: "after-task")
#aufgabe(title: [Rechnen])[
  Vorüberlegung. #loesung[Punkt vor Strich beachten.]
  #teilaufgabe[Berechne $2 + 3 dot 4$. #loesung[$14$]]
  #teilaufgabe[Berechne $(2 + 3) dot 4$. #loesung[$20$]]
]
```)

== Lösungen an einer bestimmten Stelle

```typ
#aufgabe[Berechne $7 dot 8$. #loesung[$56$]]

#show-solutions()                                        // alle, im Kasten
#show-solutions(select: "current")                       // nur die letzte Aufgabe
#show-solutions(select: "current", subtask-number: 1)    // nur deren Teilaufgabe a)
#show-solutions(inline: true)                            // als Lösungsblatt, ohne Kasten
#show-solutions(select: "pending")                       // was noch nicht gezeigt wurde
```

Ein Lösungsblatt entsteht mit `solutions: "only"`. Der Aufgabentext entfällt, und unter der Überschrift „Lösung 1 − Rechnen“ stehen die Lösungen der Teilaufgaben als Liste a), b):

```typ
#set-options(solutions: "only")
#aufgabe(title: [Rechnen])[
  Dieser Text entfällt.
  #teilaufgabe[Berechne $7 dot 8$. #loesung[$56$]]
  #teilaufgabe[Berechne $50 - 17$. #loesung[$33$]]
]
#show-solutions(select: "pending")
```

Die Abfrage `has-solutions()` sagt, ob Lösungen eingeschaltet sind:

```typ
#set-options(solutions: "in-place")
#context if has-solutions() [Fassung mit Lösungen]
```

= Material

`material` erfasst ein Material und ordnet es der zuletzt begonnenen Aufgabe zu.

#example(```typ
#set-options(materials-pagebreak: none)
#aufgabe(title: [Textanalyse])[
  Analysiere den Text.
  #material(caption: [Auszug aus „Faust I“])[Habe nun, ach! Philosophie, Juristerei und Medizin …]
]
```)

#table(
  columns: (auto, auto, 1fr),
  [*`materials`*], [*`materials-pagebreak`*], [*Wirkung*],
  [`"after-task"` (Start)], [`"before"` (Start)], [Material steht nach der Aufgabe auf einer eigenen Seite.],
  [`"after-task"`], [`none`], [Material steht direkt nach der Aufgabe.],
  [`"at-end"`], [`"before"`], [Material steht gesammelt dort, wo `show-materials()` steht, nach einem Seitenumbruch.],
  [`"at-end"`], [`none`], [Wie zuvor, ohne Seitenumbruch.],
  [`none`], [], [Material wird erfasst, aber nicht gezeigt.],
)

```typ
#set-options(materials: "at-end", materials-pagebreak: none)
#aufgabe(title: [Quelle])[Lies den Text. #material(caption: [Quelle])[…]]

#show-materials()                    // alle Materialien
#show-materials(select: "current")   // nur die der letzten Aufgabe
```

#info[
  Dieses Paket setzt Materialien als Abbildungen ohne eigene Bezeichnung. Die Bezeichnung „M1-A“ und passende Verweise ergänzt die Vorlage `arbeitsblatt`.
]

= Punkte und Bewertung

== Erwartungen

`erwartung` erfasst, was erwartet wird, und wie viele Punkte es dafür gibt. Die Punkte stehen als Zahl vorn; ohne Zahl zählt die Erwartung 0 Punkte.

#example(```typ
#aufgabe(title: [Bruchrechnung])[
  Berechne $3/4 + 1/2$.
]
#erwartung(1)[Hauptnenner ermittelt]
#erwartung(1.5)[Brüche erweitert und addiert]
#erwartung[Rechenweg ist nachvollziehbar]
#show-expectations()
```)

== Punkte an Aufgaben und Teilaufgaben

#example(```typ
#set-options(points: "all")
#aufgabe(title: [Kreis])[
  #teilaufgabe[Berechne den Umfang. #erwartung(2)[$U = 2 pi r$]]
  #teilaufgabe[Berechne die Fläche. #erwartung(3)[$A = pi r^2$]]
]
```)

#table(
  columns: (auto, 1fr),
  [*Option*], [*Wirkung*],
  [`points: none` (Start)], [keine Punkte],
  [`points: "tasks"`], [Summe im Kopf jeder Aufgabe],
  [`points: "subtasks"`], [Punkte an jeder Teilaufgabe],
  [`points: "all"`], [beides],
  [`points-total: false`], [keine Summe im Kopf; Aufgaben ohne Teilaufgaben zeigen ihre Punkte weiter, damit nichts doppelt steht],
  [`points-position: "margin"`], [Punkte der Teilaufgaben am rechten Seitenrand statt am Zeilenende],
  [`points-format`], [Vorlage der Anzeige, siehe unten],
)

#tip[
  Die Vorlage `klassenarbeit` beginnt mit `points: "tasks"`, `arbeitsblatt` und dieses Paket mit `points: none`.
]

`points-format` nimmt eine Funktion für beide Ziele oder ein Dictionary mit den Schlüsseln `task` und `subtask`; `auto` ist die Paketvorlage.

#example(```typ
#set-options(points: "all", points-format: (task: p => [#p Punkte], subtask: p => [(#p P.)]))
#aufgabe(title: [Kreis])[
  #teilaufgabe[Berechne den Umfang. #erwartung(2)[$U = 2 pi r$]]
  #teilaufgabe[Berechne die Fläche. #erwartung(3)[$A = pi r^2$]]
]
```)

== Punkte abfragen

```typ
#aufgabe(title: [Kreis])[
  #teilaufgabe[Umfang #erwartung(2)[$U = 2 pi r$]]
]
#context [
  Aufgabe 1 hat #get-points(1) Punkte, Teilaufgabe a) hat #get-points(1, subtask-number: 1).
  Formatiert: #format-points(get-points(1)) und #format-points(2, target: "subtask").
]
```

== Erwartungshorizont

#example(```typ
#aufgabe(title: [Kreis])[
  #teilaufgabe[Umfang #erwartung(1)[Formel] #erwartung(1)[Ergebnis]]
  #teilaufgabe[Fläche #erwartung(3)[Formel und Ergebnis]]
]
#show-expectations(grouped: true, achieved: true)
```)

#table(
  columns: (auto, auto, 1fr),
  [*Parameter*], [*Vorgabe*], [*Wirkung*],
  [`select`], [`"current"`], [`"all"` fasst alle Blöcke des Dokuments zusammen (siehe unten)],
  [`blocks`], [`()`], [Zwischenüberschriften der Blöcke bei `select: "all"`],
  [`grouped`], [`false`], [alle Erwartungen einer Teilaufgabe in einer Zeile],
  [`achieved`], [`false`], [`__ / X` statt `X`, zum Eintragen],
)

Soll der Erwartungshorizont auf einer eigenen Seite stehen, gehört `#pagebreak(weak: true)` vor und nach den Aufruf.

=== Mehrere Blöcke in einer Datei

`reset-tasks()` beginnt einen neuen Block: Die Zählung startet wieder bei Aufgabe 1, und Punkte, Tabellen und Erwartungshorizont beziehen sich auf den Block. `show-expectations(select: "all")` fasst am Ende alle Blöcke zusammen.

```typ
#aufgabe(title: [Kopfrechnen])[Rechne. #erwartung(4)[richtig gerechnet]]

#reset-tasks()
#aufgabe(title: [Sachaufgabe])[Löse. #erwartung(6)[Ansatz und Ergebnis]]

#show-expectations(select: "all", blocks: ([Teil A -- ohne Hilfsmittel], [Teil B -- mit Hilfsmitteln]))
```

Das Ergebnis hat je Block eine Zwischenüberschrift mit Zwischensumme (hier 4 und 6) und am Ende die Zeile „Gesamtsumme“ (10).

== Punktetabelle

#example(```typ
#aufgabe(title: [Kreis])[
  #teilaufgabe[Umfang #erwartung(2)[Formel]]
  #teilaufgabe[Fläche #erwartung(3)[Formel]]
]
#aufgabe(title: [Zusatz])[Begründe. #erwartung(4)[Begründung]]
#show-points-table()
```)

```typ
#aufgabe(title: [Kreis])[Berechne. #erwartung(2)[Formel]]
#show-points-table(possible: "fields")     // Zeile „mögliche Punkte“ mit leeren Feldern
#show-points-table(possible: none)         // ohne diese Zeile
#show-points-table(compact: true, subtotals: true)
```

= Optionen

`set-options` ändert Optionen ab der Stelle, an der es steht. Jede Option ist ein benannter Parameter; was nicht genannt wird, bleibt, wie es ist.

```typ
#set-options(solutions: "at-end", solutions-pagebreak: "before", points: "all")
#set-options(workspaces: false)
```

Die Vorlagen `arbeitsblatt` und `klassenarbeit` haben dieselben Optionen mit denselben Namen und Werten in ihrem Kopf.

#table(
  columns: (auto, auto, 1fr),
  [*Option*], [*Start*], [*Werte*],
  [`solutions`], [`none`], [`none`, `"in-place"`, `"after-task"`, `"at-end"`, `"only"`],
  [`solutions-pagebreak`], [`none`], [`none`, `"before"`, `"per-task"` (wirken mit `solutions: "at-end"`)],
  [`materials`], [`"after-task"`], [`none`, `"after-task"`, `"at-end"`],
  [`materials-pagebreak`], [`"before"`], [`none`, `"before"`],
  [`points`], [`none`], [`none`, `"tasks"`, `"subtasks"`, `"all"`],
  [`points-total`], [`true`], [`true`, `false`],
  [`points-position`], [`"end"`], [`"end"`, `"margin"`],
  [`points-format`], [`auto`], [`auto`, Funktion `points => content`, `(task: f, subtask: g)`],
  [`workspaces`], [`true`], [`true`, `false`],
  [`shortcodes`], [`"subtasks"`], [`none`, `"tasks"`, `"subtasks"`, `"all"`; ausgewertet von `arbeitsblatt`],
  [`subtask-numbering`], [`"a)"`], [Typst-Muster mit einem oder zwei Zählzeichen],
)

Das Aus einer Auswahl ist immer `none`, das Aus eines Schalters `false`. Ein Tippfehler in einem Namen oder Wert bricht mit einer Meldung ab, die den richtigen Namen vorschlägt, zum Beispiel:

#show-code(```
aufgaben.set-options: unbekannter Parameter `solutoins` – meintest du `solutions`?
aufgaben.set-options: `points: "task"` ist kein gültiger Wert – meintest du `"tasks"`? erlaubt: `none`, `"tasks"`, `"subtasks"`, `"all"`
```)

= Umstieg auf 0.5.0

Mit 0.5.0 haben alle Schule-Pakete einheitliche Namen bekommen. Die Bausteine behalten ihren deutschen Namen; alles in den Klammern und alle Aktionen sind englisch. Am Aussehen der Dokumente ändert sich nichts.

Ein alter Name wird nie still übergangen: Das Paket bricht mit einer Meldung ab, die den neuen Namen nennt, zum Beispiel ``aufgaben.aufgabe: `titel` heißt jetzt `title` `` oder ``aufgaben.set-options: `solutions: "sofort"` heißt jetzt `"in-place"` ``. Stehen alter und neuer Name im selben Aufruf, heißt es ``aufgaben.aufgabe: `titel` (alt) und `title` (neu) zugleich – nur `title` schreiben``.

#warning[
  Zwei Vorgaben sind anders als in 0.3.1. Ohne Vorlage zeigt das Paket keine Punkte mehr (`points: none` statt `"aufgaben"`); wer die Summe im Aufgabenkopf will, schreibt `#set-options(points: "tasks")`. Und die fremden Pakete `fontawesome` und `gentle-clues` werden nicht mehr weitergereicht; wer deren Funktionen braucht, importiert sie im Dokument selbst.
]

== Funktionen

#table(
  columns: (auto, 1fr),
  [*bis 0.3.1*], [*ab 0.5.0*],
  [`aufgabe`, `teilaufgabe`, `loesung`, `erwartung`, `material`], [unverändert],
  [`teilaufgaben` (aus `arbeitsblatt`)], [`teilaufgaben`, jetzt in diesem Paket],
  [`set-options((…))`], [`set-options(…)` mit benannten Optionen],
  [`reset-aufgaben()`], [`reset-tasks()`],
  [`show-loesungen()`], [`show-solutions()`],
  [`show-offene-loesungen()`], [`show-solutions(select: "pending")`],
  [`show-materialien()`], [`show-materials()`],
  [`show-erwartungen()`], [`show-expectations()`],
  [`show-bewertung()`], [`show-points-table()`],
  [`format-punkte(…)`], [`format-points(…)`],
  [`get-points(…)`], [unverändert, neue Parameternamen],
  [`show-loesung`, `show-loesung-inline`, `show-material`], [entfallen; `show-solutions(select: "current")`, `show-solutions(inline: true)`, `show-materials(select: "current")`],
  [`get-punkte-anzeige`, `get-punkte-position`], [entfallen; die Werte stehen in den Optionen `points` und `points-position`],
  [–], [neu: `has-solutions()`, `is-print()`],
)

== Parameter

#table(
  columns: (auto, auto, 1fr),
  [*Funktion*], [*bis 0.3.1*], [*ab 0.5.0*],
  [`aufgabe`], [`aufgabe[Titel][Text]`], [`aufgabe(title: [Titel])[Text]`],
  [`aufgabe`], [`titel:` (vor 0.3)], [`title:`],
  [`aufgabe`], [`method: "EA"`, `"PA"`, `"GA"`], [`method: "individual"`, `"pair"`, `"group"`],
  [`aufgabe`], [`method: ""`, `title: ""`, `workspace: false`], [Argument weglassen (`none`)],
  [`teilaufgabe`], [`item-label:`], [`marker:`; `marker: ""` setzt wie bisher eine Teilaufgabe ohne sichtbare Marke],
  [`teilaufgabe`], [`workspace: false`], [Argument weglassen (`none`)],
  [`teilaufgaben`], [`tasks:`], [`items:`],
  [`teilaufgaben`], [`loesungen:`], [`item-solutions:`],
  [`teilaufgaben`], [`teilaufgaben[+ a + b]`], [`teilaufgaben(items: ([a], [b]))`],
  [`teilaufgaben`], [`row-gutter:` und andere Argumente von `table`], [entfallen; `gutter` gilt für Spalten und Zeilen, `align` und `inset` bleiben],
  [`erwartung`], [`erwartung([Text], 2)`], [`erwartung(2)[Text]`],
  [`show-solutions`], [`curr: true`], [`select: "current"`],
  [`show-solutions`], [`teil: 2`, `teil: false`], [`subtask-number: 2`, weglassen (`none`)],
  [`show-materials`], [`curr: true`], [`select: "current"`],
  [`show-expectations`], [`erreicht:`], [`achieved:`],
  [`show-expectations`], [`alle: true`], [`select: "all"`],
  [`show-expectations`], [`teile:`], [`blocks:`],
  [`show-expectations`], [`new-page: true`], [entfällt; `#pagebreak(weak: true)` vor und nach dem Aufruf],
  [`show-points-table`], [`show-bewertung(false)`], [`show-points-table(possible: "fields")`],
  [`show-points-table`], [`show-bewertung(none)`], [`show-points-table(possible: none)`],
  [`show-points-table`], [`full:`], [`subtotals:`],
  [`get-points`], [`teil:`], [`subtask-number:`],
  [`get-points`], [`idx:`], [`index:`],
  [`get-points`], [`get-points(none, idx: 0)`], [`get-points(1, index: 0)`; die Aufgabennummer ist eine ganze Zahl, `none` ist ein Fehler],
  [`material`], [`caption: ""`], [Argument weglassen (`none`); der leere Text ist jetzt ein Fehler],
  [`format-points`], [`format-punkte(teil: true, 3)`], [`format-points(3, target: "subtask")`],
)

== Optionen und Werte

`set-options` nimmt kein Dictionary mehr, sondern benannte Optionen: aus `set-options((loesungen: "sofort"))` wird `set-options(solutions: "in-place")`. Ein vorhandenes Dictionary mit neuen Namen lässt sich mit `set-options(..optionen)` übergeben.

#table(
  columns: (auto, 1fr),
  [*bis 0.3.1*], [*ab 0.5.0*],
  [`loesungen: "keine"`], [`solutions: none`],
  [`loesungen: "sofort"`], [`solutions: "in-place"`],
  [`loesungen: "folgend"`], [`solutions: "after-task"`],
  [`loesungen: "reinquetschen"`], [`solutions: "at-end"`],
  [`loesungen: "seite"`], [`solutions: "at-end", solutions-pagebreak: "before"`],
  [`loesungen: "seiten"`], [`solutions: "at-end", solutions-pagebreak: "per-task"`],
  [`loesungen: "nur"`], [`solutions: "only"`],
  [`materialien: "keine"`], [`materials: none`],
  [`materialien: "seiten"` (Vorgabe)], [`materials: "after-task", materials-pagebreak: "before"` (Vorgabe)],
  [`materialien: "sofort"`, `"folgend"`], [`materials: "after-task", materials-pagebreak: none`],
  [`materialien: "seite"`], [`materials: "at-end", materials-pagebreak: "before"`],
  [`materialien: "reinquetschen"`], [`materials: "at-end", materials-pagebreak: none`],
  [`punkte: "keine"`], [`points: none`],
  [`punkte: "aufgaben"`], [`points: "tasks"`],
  [`punkte: "teilaufgaben"`], [`points: "subtasks"`],
  [`punkte: "alle"`], [`points: "all"`],
  [`punkte: "keine-summe"`], [`points: "all", points-total: false`],
  [`punkte: (anzeige: "alle", position: "rand")`], [`points: "all", points-position: "margin"`],
  [`punkte-position: "ende"`, `"rand"`], [`points-position: "end"`, `"margin"`],
  [`punkte-template-aufgabe: f`], [`points-format: (task: f)`],
  [`punkte-template-teilaufgabe: g`], [`points-format: (subtask: g)`],
  [`teilaufgabe-numbering: "a)"`], [`subtask-numbering: "a)"`],
  [`teilaufgabe-numbering: "1."`], [`subtask-numbering: "1.1"`],
  [`workspaces`], [unverändert],
  [`aufgaben-shortcodes` (in `arbeitsblatt`)], [`shortcodes`],
)

== Für Paket- und Theme-Autoren

Die Namen mit Unterstrich (`_state_options`, `_counter_aufgaben`, `_theme-hook` …) gibt es nicht mehr. Was andere Schule-Pakete brauchen, steht im Modul `internal` (`aufgaben.internal.options-state`, `aufgaben.internal.theme-state` …); die Beschreibung steht am Kopf von `src/internal.typ`. Dokumente benutzen `internal` nicht, und es kann sich mit jeder Version ändern. Die States haben neue Schlüssel (`"schule/aufgaben/options@1"` …), sodass sich 0.5.0 und ältere Versionen im selben Dokument nicht stören.

Die Abbildungsarten heißen `figure(kind: "task")` und `figure(kind: "subtask")` (bisher `"aufgabe"`, `"teilaufgabe"`). Wer in einem Dokument `figure.where(kind: "teilaufgabe")` schreibt, muss den Wert anpassen; eine Meldung ist dafür nicht möglich.

Die Schlüssel des Themes, die dieses Paket liest:

#table(
  columns: (auto, 1fr),
  [*bis 0.3.1*], [*ab 0.5.0*],
  [`aufgabe: (nummer:, titel:, icons:, punkte:, large:, number:) => …`], [`task: (marker:, title:, icons:, points:, large:) => …`; `marker` ist `none` oder die Nummer als Inhalt],
  [`teilaufgabe: label => …`], [`subtask: marker => …`],
  [`loesung: (titel, body) => …`], [`solution: (title: none, body) => …`],
  [`loesung-kopf: titel => …`], [`solution-heading: title => …`],
  [`material-kopf: titel => …`], [`material-heading: title => …`],
  [`marke: nummer => …`], [`task-marker: task-number => …`],
  [`marke-breite`], [`task-marker-width`],
)

= Referenz

#show-module(read("../src/aufgaben.typ"), name: "aufgaben")
