// Verweise auf Teilaufgaben folgen teilaufgabe-numbering.
// erwartet: Verweis: Teilaufgabe 1\.2
#import "@schule/aufgaben:0.3.1": *
#set-options((teilaufgabe-numbering: "1."))
#aufgabe[T][#teilaufgabe(label: <ta>)[x] #teilaufgabe(label: <tb>)[y]]
Verweis: @tb
