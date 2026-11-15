// insert-a-word 0.5.0: alter und neuer Name zugleich.
// fehler: insert-a-word.insert-a-word: `line-spacing` (alt) und `leading` (neu) zugleich – nur `leading` schreiben
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword, reset-iaword

#insert-a-word(line-spacing: 2em, leading: 1em)[Die #iaword[Lücke].]
