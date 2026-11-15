// operatoren 0.5.0: Eine lange Operatorenliste auf kleiner Seite trennt keine
// Zeile über den Seitenumbruch (wie tablex in 0.0.1). Mit trennbaren Zellen
// wären es 4 statt 5 Seiten.
// erwartet: Seiten: 5
// erwartet: Operatorenliste
#import "@schule/operatoren:0.5.0": operator, operatoren-liste
#set page(paper: "a5")

#let names = csv("/operatoren/0.5.0/Mathe.csv", delimiter: ";").map(row => row.at(0))
#for (i, name) in names.enumerate() [
  #operator(name) #i. #lorem(8)

]

#operatoren-liste(bold: true)

#context [Seiten: #counter(page).final().first()]
