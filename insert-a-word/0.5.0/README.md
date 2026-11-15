# insert-a-word

Setzt Lückentexte mit Wortbank: Die im Text markierten Wörter werden zu
Lücken und erscheinen in gemischter Reihenfolge als farbige Wortkästen über
dem Text.

```typ
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword

#insert-a-word[
  Der #iaword[Hund] bellt. Die #iaword[Katze] miaut.
]
```

`insert-a-word(word-bank: true, leading: 1.5em, spacing: 1em,
uniform-blanks: false)[…]` setzt den Block, `iaword[Wort]` markiert ein Wort,
`reset-iaword()` beginnt die Zählung der Lückentexte neu (für mehrere
Fassungen in einer Datei). Sind im Dokument Lösungen eingeschaltet
(`set-options(solutions: "in-place")` aus `aufgaben`, `arbeitsblatt` oder
`klassenarbeit`), stehen die Wörter rot in den Lücken.

Umstieg von älteren Versionen: Namen siehe Handbuch, Abschnitt Umstieg.
