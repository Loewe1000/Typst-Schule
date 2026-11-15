// insert-a-word 0.5.0: falscher Typ für `spacing`, lesbare Meldung.
// fehler: insert-a-word.insert-a-word: `spacing` erwartet eine Länge, einen Anteil (`%`) oder einen Bruchteil (`fr`), bekam `1` (int) – zum Beispiel `1em`
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword, reset-iaword

#insert-a-word(spacing: 1)[Die #iaword[Lücke].]
