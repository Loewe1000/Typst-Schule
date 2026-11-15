// insert-a-word 0.5.0: Lückentext mit Wortbank; ohne Lösungsoption bleiben die
// Lücken leer, jedes Wort steht genau einmal (in der Wortbank).
// erwartet: Der _* ?bellt
// erwartet: Hund
// erwartet: Katze
// nicht: Der Hund
// nicht: Hund.*Hund
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword, reset-iaword

#insert-a-word(leading: 1.8em, spacing: 2em, uniform-blanks: true)[
  Der #iaword[Hund] bellt.

  Die #iaword[Katze] miaut.
]
