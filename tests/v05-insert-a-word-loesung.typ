// insert-a-word 0.5.0: Die Lücken folgen der Lösungsoption von aufgaben
// (`has-solutions()`): mit Lösungen steht das Wort auch in der Lücke, danach
// wieder nicht.
// erwartet: ALPHA An rauen Flächen tritt Streuung auf
// erwartet: ^ ?Zeit$
// erwartet: Weg durch ?\.
// nicht: durch Zeit
#import "@schule/insert-a-word:0.5.0": insert-a-word, iaword, reset-iaword
#import "@schule/aufgaben:0.5.0": set-options

#set-options(solutions: "in-place")
#insert-a-word(word-bank: false)[
  ALPHA An rauen Flächen tritt #iaword[Streuung] auf.
]
#insert-a-word[
  An rauen Flächen tritt #iaword[Streuung] auf.
]
#set-options(solutions: none)
#reset-iaword()
#insert-a-word[
  Weg durch #iaword[Zeit].
]
