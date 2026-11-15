// insert-a-word 0.5.0: alter und neuer Name zugleich (gewendeter Schalter).
// fehler: insert-a-word.insert-a-word: `hide-words` (alt) und `word-bank` (neu) zugleich – nur `word-bank` schreiben
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword, reset-iaword

#insert-a-word(hide-words: true, word-bank: false)[Die #iaword[Lücke].]
