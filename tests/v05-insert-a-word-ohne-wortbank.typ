// insert-a-word 0.5.0: `word-bank: false` lässt die Wortkästen weg.
// erwartet: Die Einheit ist
// nicht: Newton
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword, reset-iaword

#insert-a-word(word-bank: false)[
  Die Einheit ist #iaword[Newton].
]
