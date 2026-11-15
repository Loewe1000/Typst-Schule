#import "@schule/schuldocs:0.3.1": show-example, show-module, show-code

// Ein Beispiel, das die Doku selbst ausführt: Der gezeigte Quelltext ist
// genau der, der gesetzt wird, samt Importzeile. Die Überschrift der
// Operatorenliste rückt auf die sechste Ebene; so bleibt sie aus
// Inhaltsverzeichnis und Kapitelzählung heraus und löst im Handbuch keinen
// Seitenumbruch aus.
#let example(code) = show-example(
  source: code,
  rendered: {
    set heading(offset: 5, outlined: false, bookmarked: false, numbering: none)
    show heading: it => block(above: 1.2em, below: 0.8em, text(1.25em, weight: "bold", it.body))
    eval(code.text, mode: "markup")
  },
)

// Die Operatoren eines Fachs, wie sie in der CSV-Datei des Pakets stehen.
#let names(file) = csv("../" + file, delimiter: ";").map(row => row.at(0)).sorted()

= Über dieses Paket

Das `operatoren`-Paket verwaltet *Operatoren in Klausur- und Abituraufgaben*:
Ein Operator wird im Aufgabentext markiert, und am Ende des Dokuments steht
die Operatorenliste, eine Tabelle der verwendeten Operatoren mit ihrer
Definition aus den Fachanforderungen.

Der Ablauf:

1. Operatoren im Aufgabentext mit `#operator("berechnen", caption: [Berechne])` markieren.
2. Am Ende des Dokuments `#operatoren-liste(subject: "Physik")` einfügen.
3. Die Tabelle enthält genau die verwendeten Operatoren, alphabetisch
   sortiert; jeder Operator im Text führt als Link zu seiner Zeile.

Das Paket bringt die Definitionen für *Mathe* und *Physik* mit, jeweils auf
Deutsch und Italienisch.

= Schnellstart

#example(```typ
#import "@schule/operatoren:0.5.0": operator, operatoren-liste

#operator("berechnen", caption: [Berechne]) die Geschwindigkeit nach $t = 5 "s"$.

#operator("beschreiben", caption: [Beschreibe]) den Verlauf des $t$-$v$-Diagramms.

#operator("herleiten", caption: [Leite]) die Formel $E_"kin" = 1/2 m v^2$ aus $W = F dot s$ her
und #operator("skizzieren", caption: [skizziere]) den Graphen.

#operatoren-liste(subject: "Physik")
```)

Die Operatorenliste sammelt die Operatoren des ganzen Dokuments. In diesem
Handbuch stehen deshalb in der Tabelle oben auch die Operatoren der späteren
Beispiele.

= Operatoren markieren

`operator` bekommt den Namen des Operators als Text, und zwar so, wie er in
der Operatorenliste steht: als Infinitiv (`"berechnen"`,
`"grafisch darstellen"`). Groß- und Kleinschreibung spielen keine Rolle. Ohne
weitere Angabe steht dieser Name im Text:

#example(```typ
#import "@schule/operatoren:0.5.0": operator

Bitte #operator("berechnen") Sie den Wert und #operator("Begründen") Sie Ihr Vorgehen.
```)

== Anderer Anzeigetext

In einer Aufgabe steht der Operator meist in einer anderen Form (»Berechne«,
»Leiten Sie … her«). Diese Form kommt nach `caption`, als Text oder als Inhalt:

#example(```typ
#import "@schule/operatoren:0.5.0": operator

#operator("berechnen", caption: [Berechne]) die Masse.
#operator("skizzieren", caption: "Skizzieren Sie") den Aufbau.
```)

Die Inhaltsform `#operator[Berechne]` gibt es nicht: Das Paket könnte aus
»Berechne« den Namen `berechnen` nicht ableiten. Wer sie schreibt, bekommt
eine Fehlermeldung mit der richtigen Schreibweise.

== Fettdruck

`bold: true` setzt einen einzelnen Operator fett, `bold: false` setzt ihn
normal. Die Vorgabe `auto` übernimmt die Einstellung der Operatorenliste
(nächster Abschnitt).

#example(```typ
#import "@schule/operatoren:0.5.0": operator

#operator("berechnen", caption: [Berechne], bold: true) die Masse
und #operator("beschreiben", caption: [beschreibe], bold: false) den Aufbau.
```)

== Ohne Operatorenliste

Enthält das Dokument keine `operatoren-liste`, setzt `operator` nur den Text,
ohne Link. Die Namen werden dann auch nicht geprüft.

= Operatorenliste

`operatoren-liste` setzt die Überschrift »Operatorenliste« und darunter die
Tabelle. `subject` wählt das Fach:

#show-code(```typ
#import "@schule/operatoren:0.5.0": operator, operatoren-liste

#operator("zeigen", caption: [Zeige]), dass die Funktion monoton wächst.

#operatoren-liste(subject: "Mathe")
```)

Die Vorgabe ist `subject: "Mathe"`. Ein Operator, den das gewählte Fach nicht
kennt, bricht mit einer Meldung ab, die die erlaubten Namen nennt.

== Fettdruck im ganzen Dokument

`bold: true` an der Operatorenliste setzt alle Operatoren im Fließtext fett,
auch die, die vor der Liste stehen. Diese Einstellung gibt es nur hier; ein
einzelner Operator weicht mit `operator(bold: false)` davon ab.

#show-code(```typ
#import "@schule/operatoren:0.5.0": operator, operatoren-liste

#operator("berechnen", caption: [Berechne]) die Masse.

#operatoren-liste(subject: "Physik", bold: true)
```)

== Sprache

`language: "it"` nimmt die italienischen Definitionen und die Überschrift
»Elenco degli operatori«. Die Operatoren heißen dann wie in der italienischen
Liste:

#show-code(```typ
#import "@schule/operatoren:0.5.0": operator, operatoren-liste

#operator("calcolare", caption: [Calcola]) la velocità.

#operatoren-liste(subject: "Physik", language: "it")
```)

= Verfügbare Operatoren

Die Definitionen liegen als CSV-Dateien im Paket (`Mathe.csv`, `Physik.csv`,
`Mathe-it.csv`, `Physik-it.csv`). Das Paket liest nur diese Dateien; eine
eigene CSV-Datei im Ordner des Dokuments kann es nicht lesen, weil Typst
Pfade relativ zum Paket auflöst. Für ein weiteres Fach muss die Datei ins
Paket.

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  table.header([*`subject`, `language`*], [*Operatoren*]),
  [`"Mathe"`, `"de"`], names("Mathe.csv").join(", "),
  [`"Physik"`, `"de"`], names("Physik.csv").join(", "),
  [`"Mathe"`, `"it"`], names("Mathe-it.csv").join(", "),
  [`"Physik"`, `"it"`], names("Physik-it.csv").join(", "),
)

= Umstieg auf 0.5.0

Mit 0.5.0 heißen alle Parameter englisch; die beiden Funktionen behalten ihren
Namen. Ein alter Name bricht mit einer Meldung ab, die den neuen nennt, zum
Beispiel ``operatoren.operator: `text` heißt jetzt `caption` ``.

#table(
  columns: (auto, auto, auto, 1fr),
  stroke: 0.5pt,
  table.header([*Funktion*], [*bis 0.0.1*], [*ab 0.5.0*], [*Hinweis*]),
  [`operator`], [`text: "…"`], [`caption: "…"`], [umbenannt],
  [`operator`], [`text: ""`], [weglassen], [kein Anzeigetext ist `none`; `caption: ""` ist ein Fehler],
  [`operator`], [`bold: none`], [weglassen oder `bold: auto`], [»wie die Operatorenliste« ist `auto`],
  [`operatoren-liste`], [`fach: "Physik"`], [`subject: "Physik"`], [umbenannt, Werte unverändert],
  [`operatoren-liste`], [`language: "it"`], [`language: "it"`], [unverändert],
  [`operatoren-liste`], [`operator-text-bold: true`], [`bold: true`], [umbenannt],
)

Die Zeile `#operator("berechnen", text: "Berechne")` heißt jetzt
`#operator("berechnen", caption: "Berechne")`. Die Inhaltsform
`#operator[Berechne]` aus dem alten Handbuch brach schon in 0.0.1 ab; richtig
ist `#operator("berechnen", caption: [Berechne])`.

Die beiden States sind nicht mehr öffentlich, und die Labels heißen anders.
Das betrifft nur Dokumente, die darauf selbst zugegriffen haben:

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  table.header([*bis 0.0.1*], [*ab 0.5.0*]),
  [`operatoren-state`], [intern: `internal.used`, Schlüssel `"schule/operatoren/used@1"`],
  [`operatoren-config-state`], [intern: `internal.settings`, Schlüssel `"schule/operatoren/settings@1"`, Feld `bold` statt `text-bold`],
  [`<-def>`], [`<schule-operatoren-overview>`, an der Überschrift der Operatorenliste],
  [`<berechnen-def>`], [`<schule-operatoren-berechnen>`, an der Zeile des Operators. Umlaute werden umschrieben, Leerzeichen zu Bindestrichen: `<schule-operatoren-abschaetzen>`, `<schule-operatoren-grafisch-darstellen>`],
)

Was sich außer den Namen ändert:

- Der Link eines Operators führt zu seiner Zeile in der Operatorenliste, nicht
  mehr zum Anfang der Liste.
- Ohne Operatorenliste setzt `operator` den Text ohne Link; bisher brach das
  Dokument ab.
- Ein unbekanntes Fach, eine unbekannte Sprache und ein Operator, den das Fach
  nicht kennt, brechen mit einer deutschen Meldung ab, die die erlaubten Werte
  nennt.
- Unbekannte Parameter werden abgelehnt, mit Vorschlag bei Tippfehlern.
- Die Tabelle setzt Typsts eingebaute `table`; das Paket braucht `tablex` nicht
  mehr. Schriftbild und Seitenumbruch bleiben gleich: Eine Zeile der Liste wird
  weiterhin nicht über zwei Seiten getrennt.
- Der Physik-Operator »Hypothesen aufstellen« lässt sich benutzen; bisher brach
  er wegen des großen Anfangsbuchstabens in der Liste ab.
- Steht ein alter Name neben dem neuen (`text` und `caption`), nennt die
  Meldung beide.

= API-Referenz

#show-module(read("../src/operator.typ"), name: "operatoren")
