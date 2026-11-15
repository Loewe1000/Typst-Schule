// insert-a-word 0.5.0: `spacing` nimmt Länge, Anteil und Bruchteil (wie 0.0.3).
// erwartet: Newton
// erwartet: Die Einheit ist
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword, reset-iaword

#insert-a-word(spacing: 10%)[Die Einheit ist #iaword[Newton].]
#insert-a-word(spacing: 1fr)[Die Einheit ist #iaword[Newton].]
#insert-a-word(spacing: 5% + 2mm)[Die Einheit ist #iaword[Newton].]
