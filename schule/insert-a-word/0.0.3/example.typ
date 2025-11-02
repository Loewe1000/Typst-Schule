#import "lib.typ": *

// = Beispiel: Einfache Verwendung von iaword und insert-a-word

// Hier ein kurzer Text, in dem wir einige Wörter mit "iaword" markieren:

// Nun verwenden wir "insert-a-word", um diese Wörter an einer anderen Stelle anzuzeigen.
// Die Wörter werden zufällig angeordnet und in farbigen Boxen dargestellt:

// #insert-a-word(
//   // hide-words: false => Wörter werden sichtbar dargestellt
//   hide-words: false,
//   line-spacing: 1.8em,
// )[

// Dieser Absatz kommt nach der Wortanzeige.
// Man sieht oben die drei eingefügten Wörter als farbige Boxen.

// #iaword[Zufall]
// ]

// //-------------------------------------
// // Beispiel mit hide-words: true
// //-------------------------------------
// #insert-a-word(hide-words: false)[
//   Die zugeführte Energie ist #iaword[proportional] zur Zeit. Das erkennt man
//   daran, dass der Quotient #iaword[E/t] konstant ist und die Messwerte jeweils auf
//   einer #iaword[Geraden] liegen. Die Steigung entspricht dabei #iaword[dem Energiestrom].
// ]


// = Zweites Beispiel: Wörter verstecken

// In diesem Beispiel verwenden wir "hide-words: true", um die gesammelten Wörter nicht darzustellen:

// Fügen wir wieder ein paar Wörter ein:


// Diesmal zeigen wir die Wörter nicht an:

// #insert-a-word(hide-words: true)[
//   Auch wenn die Wörter nun nicht als Boxen erscheinen, wurden sie intern erfasst.
//   Dieser Absatz zeigt einfach ganz normalen Text an, ohne die zuvor versteckten Wörter.
//   #iaword[Geheimnis]
//   #iaword[Phänomen]
//   #iaword[Abstraktion]
// ]

// = Drittes Beispiel: Mehrere Runden von Wörtern

// Jede Aufruf-Reihe von "iaword" und anschließendem "insert-a-word" bildet eine eigene Runde.

// #insert-a-word()[
//   Dies ist der Text nach Runde 1.
//   #iaword[Apfel] #iaword[Banane]
// ]


// #insert-a-word(hide-words: false)[
//   Dies ist der Text nach Runde 2, nun erscheinen die neuen Wörter separat von Runde 1.

//   #iaword[Kirsche] #iaword[Melone] #iaword[Traube]
// ]

= Erster Lückentext

#insert-a-word(hide-words: false)[
  "Der #iaword[Hund] bellt.
  Die #iaword[Katze] miaut.
  Ein #iaword[Auto] fährt."
  "Die #iaword[Banane] ist gelb.
  Ein #iaword[Apfel] ist meist rot oder grün.
  Das #iaword[Wasser] ist transparent."
]


= Zweiter Lückentext

#insert-a-word(hide-words: false, line-spacing: 2em)[
  "Die #iaword[Banane] ist gelb.
  Ein #iaword[Apfel] ist meist rot oder grün.
  Das #iaword[Wasser] ist transparent."
  "Die #iaword[Banane] ist gelb.
  Ein #iaword[Apfel] ist meist rot oder grün.
  Das #iaword[Wasser] ist transparent."
  "Die #iaword[Banane] ist gelb.
  Ein #iaword[Apfel] ist meist rot oder grün.
  Das #iaword[Wasser] ist transparent."
  "Die #iaword[Banane] ist gelb.
  Ein #iaword[Apfel] ist meist rot oder grün.
  Das #iaword[Wasser] ist transparent."
  "Die #iaword[Banane] ist gelb.
  Ein #iaword[Apfel] ist meist rot oder grün.
  Das #iaword[Wasser] ist transparent."
]


= Dritter Lückentext

#insert-a-word(hide-words: false, item-spacing: 4em)[
  "Der #iaword[Hund] bellt.
  Die #iaword[Katze] miaut.
  Ein #iaword[Auto] fährt."
  "Die #iaword[Banane] ist gelb.
  Ein #iaword[Apfel] ist meist rot oder grün.
  Das #iaword[Wasser] ist transparent."
  "Die #iaword[Banane] ist gelb.
  Ein #iaword[Apfel] ist meist rot oder grün.
  Das #iaword[Wasser] ist transparent."
  "Die #iaword[Banane] ist gelb.
  Ein #iaword[Apfel] ist meist rot oder grün.
  Das #iaword[Wasser] ist transparent."
]

