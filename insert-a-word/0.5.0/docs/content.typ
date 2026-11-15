#import "@schule/schuldocs:0.3.1": show-example, show-module, show-code

// Ein Beispiel, das die Doku selbst ausführt: Der gezeigte Quelltext ist
// genau der, der gesetzt wird, samt Importzeile.
#let example(code) = show-example(
  source: code,
  rendered: eval(code.text, mode: "markup"),
)

= Über dieses Paket

Das `insert-a-word`-Paket setzt *Lückentexte mit Wortbank*: Die einzusetzenden
Wörter erscheinen in gemischter Reihenfolge als farbige Wortkästen über dem
Text, im Text steht an ihrer Stelle eine Linie. Schülerinnen und Schüler
suchen das passende Wort aus und tragen es ein.

- Die Wörter werden im Text markiert; eine eigene Wortliste ist nicht nötig.
- Die Reihenfolge der Wortkästen ist gemischt, aber bei jedem Kompilieren
  dieselbe.
- Die Lücken sind so breit wie ihr Wort oder auf Wunsch alle gleich breit.
- Sind im Dokument Lösungen eingeschaltet, stehen die Wörter rot in den
  Lücken.
- Mehrere Lückentexte in einem Dokument bleiben getrennt.

= Schnellstart

#example(```typ
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword

#insert-a-word[
  Die Energie ist #iaword[proportional] zur Zeit.
  Der Quotient $E slash t$ ist konstant und die Kurve ist eine #iaword[Gerade].
]
```)

Jedes `#iaword[Wort]` erzeugt zweierlei:
+ einen farbigen Wortkasten in der Wortbank über dem Text,
+ eine Linie an seiner Stelle im Text.

`iaword` gehört in den Rumpf von `insert-a-word`. Wer `arbeitsblatt` oder
`klassenarbeit` benutzt, bekommt beide Funktionen von dort und braucht keine
eigene Importzeile.

= Optionen

== Gleich breite Lücken

In der Vorgabe richtet sich die Breite einer Lücke nach ihrem Wort. Mit
`uniform-blanks: true` sind alle Lücken eines Blocks so breit wie das längste
Wort; die Breite verrät dann nichts mehr:

#example(```typ
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword

#insert-a-word(uniform-blanks: true)[
  Der #iaword[Widerstand] eines Leiters ist #iaword[proportional] zu seiner #iaword[Länge].
]
```)

== Ohne Wortbank

Mit `word-bank: false` entfallen die Wortkästen, zum Beispiel für eine
Fassung ohne Hilfe:

#example(```typ
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword

#insert-a-word(word-bank: false)[
  Die Geschwindigkeit ist der Quotient aus #iaword[Weg] und #iaword[Zeit].
  Sie hat die Einheit #iaword[m/s].
]
```)

== Abstände

`leading` ist der Zeilenabstand im Lückentext (er geht an `par(leading:)`),
`spacing` der Abstand zwischen den Wortkästen (eine Länge, auch ein Anteil
wie `10%` oder ein Bruchteil wie `1fr`):

#example(```typ
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword

#insert-a-word(leading: 2em, spacing: 3em)[
  Der #iaword[Hund] bellt. Die #iaword[Katze] miaut. Ein #iaword[Auto] fährt.
  Die #iaword[Banane] ist gelb, das #iaword[Wasser] ist durchsichtig.
]
```)

= Lösungen

Einen eigenen Lösungsschalter hat `insert-a-word` nicht. Die Lücken folgen der
Lösungsoption des Dokuments: Sobald `solutions` nicht `none` ist, stehen die
Wörter rot auf den Linien. Gesetzt wird die Option mit `set-options` aus
`aufgaben` oder in der Vorlage, zum Beispiel
`#show: arbeitsblatt.with(solutions: "at-end")`.

#example(```typ
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword
#import "@schule/aufgaben:0.5.0": set-options

#set-options(solutions: "in-place")

#insert-a-word[
  Licht breitet sich geradlinig aus und wird an glatten Flächen #iaword[reflektiert].
  An rauen Flächen tritt #iaword[Streuung] auf.
]

#set-options(solutions: none)
```)

Die letzte Zeile schaltet die Lösungen wieder aus; ohne sie blieben sie für
den Rest des Dokuments an.

= Formeln als Wörter

`iaword` nimmt beliebigen Inhalt, also auch Formeln:

#example(```typ
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword

#insert-a-word[
  Die Formel lautet #iaword[$F = m a$].
  Die Einheit der Kraft ist #iaword[$"N" = "kg" dot "m/s"^2$].
]
```)

= Mehrere Fassungen in einem Dokument

Die Reihenfolge der Wortkästen hängt daran, der wievielte Lückentext des
Dokuments gesetzt wird. Stehen mehrere Fassungen desselben Blatts in einer
Datei, beginnt `reset-iaword()` die Zählung neu; jede Fassung mischt dann wie
ein einzelnes Dokument. `arbeitsblatt` ruft das je Fassung selbst auf.

#example(```typ
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword, reset-iaword

#let blatt = insert-a-word[
  Der #iaword[Hund] bellt. Die #iaword[Katze] miaut. Ein #iaword[Auto] fährt.
]

// erste Fassung
#reset-iaword()
#blatt

// zweite Fassung: dieselbe Reihenfolge der Wortkästen
#reset-iaword()
#blatt
```)

= Alle Parameter

#show-code(```typ
#insert-a-word(
  word-bank: true,        // bool: Wortkästen über dem Text zeigen
  leading: 1.5em,         // length: Zeilenabstand im Text
  spacing: 1em,           // length, auch `10%` oder `1fr`: Abstand zwischen den Wortkästen
  uniform-blanks: false,  // bool: alle Lücken so breit wie das längste Wort
)[
  Text mit #iaword[Wörtern]
]
```)

Ein unbekannter Parameter bricht mit einer Meldung ab, die den richtigen
nennt:

#show-code(```
insert-a-word.insert-a-word: unbekannter Parameter `wordbank` – meintest du `word-bank`?
```)

= Umstieg auf 0.5.0

Mit 0.5.0 heißen die Parameter einheitlich; `insert-a-word` und `iaword`
behalten ihren Namen. Ein alter Name bricht mit einer Meldung ab, die den
neuen nennt:

#show-code(```
insert-a-word.insert-a-word: `line-spacing` heißt jetzt `leading`
```)

#table(
  columns: (auto, auto, 1fr, 1fr),
  stroke: 0.5pt,
  table.header([*Funktion*], [*bis 0.0.3*], [*ab 0.5.0*], [*Hinweis*]),
  [`iaword-neu`], [`iaword-neu()`], [`reset-iaword()`], [umbenannt],
  [`iaword`], [`iaword[Wort]`], [`iaword[Wort]`], [unverändert],
  [`insert-a-word`], [`hide-words: true`], [`word-bank: false`], [umbenannt und gewendet],
  [`insert-a-word`], [`hide-words: false`], [weglassen], [die Vorgabe ist `word-bank: true`],
  [`insert-a-word`], [`line-spacing: 2em`], [`leading: 2em`], [umbenannt],
  [`insert-a-word`], [`item-spacing: 2em`], [`spacing: 2em`], [umbenannt],
  [`insert-a-word`], [`uniform-gaps: true`], [`uniform-blanks: true`], [umbenannt],
  [`insert-a-word`], [`show-solution: true`], [weglassen; im Dokument `set-options(solutions: "in-place")`], [entfernt: Die Lücken folgen der Lösungsoption des Dokuments],
  [`insert-a-word`], [`show-solution: false`], [weglassen], [entfernt],
)

Aus

#show-code(```typ
#import "@schule/insert-a-word:0.0.3": *

#insert-a-word(hide-words: true, line-spacing: 2em, show-solution: true)[
  Der #iaword[Hund] bellt.
]
```)

wird

#show-code(```typ
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword
#import "@schule/aufgaben:0.5.0": set-options

#set-options(solutions: "in-place")
#insert-a-word(word-bank: false, leading: 2em)[
  Der #iaword[Hund] bellt.
]
```)

Was sonst entfällt, betrifft nur Dokumente, die darauf selbst zugegriffen
haben:

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt,
  table.header([*bis 0.0.3*], [*ab 0.5.0*]),
  [`iaword-list`], [intern: `internal.words`, Schlüssel `"schule/insert-a-word/words@1"`],
  [`iaword-counter`], [intern: `internal.block-counter`, Schlüssel `"schule/insert-a-word/block-counter@1"`],
  [`iaword-uniform`], [intern: `internal.uniform`, Schlüssel `"schule/insert-a-word/uniform@1"`],
  [`iaword-start`], [intern: `internal.start`, Schlüssel `"schule/insert-a-word/start@1"`],
  [`iaword-solution`, `iaword-show`], [entfallen; ob Lösungen gezeigt werden, sagt `has-solutions()` aus `aufgaben`],
  [`shuffle`, `rand`, `randint` und acht weitere Namen aus `random`], [werden nicht mehr weitergereicht; bei Bedarf `#import "@schule/random:0.0.1": shuffle`],
)

`internal` ist keine zugesicherte Schnittstelle und kann sich mit jeder
Version ändern.

= Referenz

#show-module(read("../src/insert-a-word.typ"), name: "insert-a-word")
