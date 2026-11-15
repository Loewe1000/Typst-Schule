// Verweise auf Teilaufgaben folgen subtask-numbering (zwei Zählzeichen: Aufgabe.Teil).
// erwartet: 1\.1 x
// erwartet: Verweis: Teilaufgabe 1\.2
#import "@schule/aufgaben:0.5.0": *
#set-options(subtask-numbering: "1.1")
#aufgabe(title: [T])[#teilaufgabe(label: <ta>)[x] #teilaufgabe(label: <tb>)[y]]
Verweis: @tb
