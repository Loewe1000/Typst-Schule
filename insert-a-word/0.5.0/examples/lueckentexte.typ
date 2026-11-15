#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword, reset-iaword
#import "@schule/aufgaben:0.5.0": set-options

= Erster Lückentext

#insert-a-word[
  "Der #iaword[Hund] bellt.
  Die #iaword[Katze] miaut.
  Ein #iaword[Auto] fährt."
  "Die #iaword[Banane] ist gelb.
  Ein #iaword[Apfel] ist meist rot oder grün.
  Das #iaword[Wasser] ist transparent."
]

= Größerer Zeilenabstand

#insert-a-word(leading: 2em)[
  Die zugeführte Energie ist #iaword[proportional] zur Zeit. Das erkennt man
  daran, dass der Quotient #iaword[$E slash t$] konstant ist und die Messwerte
  jeweils auf einer #iaword[Geraden] liegen. Die Steigung entspricht dabei
  #iaword[dem Energiestrom].
]

= Weite Wortbank, gleich breite Lücken

#insert-a-word(spacing: 4em, uniform-blanks: true)[
  Der #iaword[Widerstand] eines Leiters ist #iaword[proportional] zu seiner
  #iaword[Länge].
]

= Ohne Wortbank

#insert-a-word(word-bank: false)[
  Die Geschwindigkeit ist der Quotient aus #iaword[Weg] und #iaword[Zeit].
  Sie hat die Einheit #iaword[m/s].
]

= Mit Lösung

#set-options(solutions: "in-place")

#insert-a-word[
  Licht breitet sich geradlinig aus und wird an glatten Flächen
  #iaword[reflektiert]. An rauen Flächen tritt #iaword[Streuung] auf.
]

#set-options(solutions: none)

= Zweite Fassung

// Ab hier mischt das Paket wieder wie am Anfang des Dokuments.
#reset-iaword()

#insert-a-word[
  "Der #iaword[Hund] bellt.
  Die #iaword[Katze] miaut.
  Ein #iaword[Auto] fährt."
  "Die #iaword[Banane] ist gelb.
  Ein #iaword[Apfel] ist meist rot oder grün.
  Das #iaword[Wasser] ist transparent."
]
