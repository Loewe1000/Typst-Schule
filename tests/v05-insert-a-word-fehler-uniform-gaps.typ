// insert-a-word 0.5.0: alter Parametername, auch über `with`.
// fehler: insert-a-word.insert-a-word: `uniform-gaps` heißt jetzt `uniform-blanks`
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword, reset-iaword

#show: insert-a-word.with(uniform-gaps: true)
Die #iaword[Lücke].
