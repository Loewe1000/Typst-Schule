// gutachten 0.5.0: ohne `set-options` bricht `gutachten` mit Abhilfe ab.
// fehler: gutachten.gutachten: die Angaben zum Gutachten fehlen – einmal `set-options(subject: ..., level: ..., teacher: ..., max-points: ...)` aufrufen
#import "@schule/gutachten:0.5.0": *

#gutachten(first-name: "Anna", last-name: "Bauer")[Text]
