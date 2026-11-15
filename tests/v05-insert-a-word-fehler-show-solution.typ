// insert-a-word 0.5.0: der eigene Lösungsschalter ist entfallen.
// fehler: insert-a-word.insert-a-word: `show-solution` gibt es nicht mehr – die Lücken folgen der Lösungsoption des Dokuments – weglassen und im Dokument `set-options(solutions: "in-place")` schreiben
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword, reset-iaword

#insert-a-word(show-solution: true)[Die #iaword[Lücke].]
