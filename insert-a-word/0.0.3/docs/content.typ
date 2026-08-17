#import "@schule/schuldocs:0.2.0": show-example, show-module, show-code

= Über dieses Paket

Das `insert-a-word`-Paket erstellt interaktive *Lückentext-Aufgaben*, bei denen die
einzusetzenden Wörter automatisch in zufälliger Reihenfolge als farbige Wort-Boxen
über dem Text erscheinen. Schülerinnen und Schüler suchen das passende Wort aus der
Liste und tragen es in die Lücke ein.

Besonderheiten des Systems:

- Die Wörter werden *automatisch* aus dem Text extrahiert — keine manuelle Wortliste nötig.
- Die Reihenfolge der Wort-Boxen ist *zufällig* (basierend auf `@schule/random`).
- Lückenbreiten passen sich an die Wortlänge an oder können einheitlich gesetzt werden.
- Mit `show-solution: true` werden die Lücken in Rot mit dem korrekten Wort gefüllt —
  ideal zum Erstellen von Lösungsseiten.
- Mehrere unabhängige `insert-a-word`-Blöcke auf einem Blatt sind möglich.

Einsatzgebiete: Physik-Definitionen, Grammatikübungen, Fachvokabular, Lese-/Hörverständnis.

= Schnellstart

#show-example(
  rendered: {
    import "../lib.typ": insert-a-word, iaword
    insert-a-word[
      Die Energie ist #iaword[proportional] zur Zeit.
      Der Quotient $E slash t$ ist konstant und die Kurve ist eine #iaword[Gerade].
    ]
  },
  source: ```typ
#import "@schule/insert-a-word:0.0.3": insert-a-word, iaword

#insert-a-word[
  Die Energie ist #iaword[proportional] zur Zeit.
  Der Quotient $E slash t$ ist konstant und die Kurve ist eine #iaword[Gerade].
]
  ```,
)

Jedes `#iaword[Wort]` erzeugt gleichzeitig:
1. Eine farbige Wort-Box in der Liste über dem Text.
2. Eine Unterstrich-Lücke an der Position im Text.

= Optionen

== Lösung anzeigen

Mit `show-solution: true` werden die Lücken ausgefüllt und in Rot dargestellt.
Diese Option eignet sich für Lehrkraft-Exemplare oder Selbstkontrollbögen:

#show-example(
  rendered: {
    import "../lib.typ": insert-a-word, iaword
    insert-a-word(show-solution: true)[
      Licht breitet sich gradlinig aus und wird an glatten Flächen #iaword[reflektiert].
      An rauen Flächen tritt #iaword[Streuung] auf.
    ]
  },
  source: ```typ
#insert-a-word(show-solution: true)[
  Licht breitet sich gradlinig aus und wird an glatten Flächen #iaword[reflektiert].
  An rauen Flächen tritt #iaword[Streuung] auf.
]
  ```,
)

== Einheitliche Lückenbreite

Standardmäßig richtet sich die Lückenbreite nach der Länge des einzusetzenden Wortes.
Mit `uniform-gaps: true` erhalten alle Lücken die Breite des längsten Wortes —
so lassen sich keine Rückschlüsse aus der Lückenbreite ziehen:

#show-example(
  rendered: {
    import "../lib.typ": insert-a-word, iaword
    insert-a-word(uniform-gaps: true)[
      Der #iaword[Widerstand] eines Leiters ist #iaword[proportional] zu seiner #iaword[Länge].
    ]
  },
  source: ```typ
#insert-a-word(uniform-gaps: true)[
  Der #iaword[Widerstand] eines Leiters ist #iaword[proportional] zu seiner #iaword[Länge].
]
  ```,
)

== Wortliste ausblenden

Mit `hide-words: true` wird die Wort-Box-Liste ausgeblendet. Dieser Modus eignet sich
für Varianten ohne Hilfestellung oder für den reinen Lösungsbogen:

#show-code[```typ
#insert-a-word(hide-words: true)[
  Die Geschwindigkeit ist der Quotient aus #iaword[Weg] und #iaword[Zeit].
  Sie hat die Einheit #iaword[m/s].
]
```]

= Mathematische Ausdrücke als Wörter

`#iaword[...]` akzeptiert beliebigen Typst-Content, also auch Formeln:

#show-example(
  rendered: {
    import "../lib.typ": insert-a-word, iaword
    insert-a-word[
      Die Formel lautet #iaword[$F = m a$].
      Die Einheit der Kraft ist #iaword[$"N" = "kg" dot "m/s"^2$].
    ]
  },
  source: ```typ
#insert-a-word[
  Die Formel lautet #iaword[$F = m a$].
  Die Einheit der Kraft ist #iaword[$"N" = "kg" dot "m/s"^2$].
]
  ```,
)

= Parameter

#show-code[```typ
// Äußerer Block
#insert-a-word(
  hide-words: false,     // bool: Wort-Boxen über dem Text ausblenden
  line-spacing: 1.5em,   // length: vertikaler Abstand zwischen den Wort-Boxen
  item-spacing: 1em,     // length: horizontaler Abstand zwischen den Wort-Boxen
  show-solution: false,  // bool: Lösungswörter in Rot in die Lücken einsetzen
  uniform-gaps: false,   // bool: Alle Lücken so breit wie das längste Wort
)[
  … Text mit #iaword[Wörtern] …
]

// Wort-Markierung im Text
#iaword(body)  // body: content — das einzusetzende Wort (beliebiger Typst-Content)
```]

= API-Referenz

#show-module(read("../lib.typ"), name: "insert-a-word")
