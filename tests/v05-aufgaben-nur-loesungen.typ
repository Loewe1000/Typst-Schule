// solutions: "only": der Aufgabentext entfällt, @label-Verweise auf Aufgaben brechen nicht ab.
// erwartet: Lösung 1 − Titel
// erwartet: Siehe 1
// nicht: Aufgabentext
#import "@schule/aufgaben:0.5.0": *
#set-options(solutions: "only")
#aufgabe(title: [Titel], label: <a1>)[Aufgabentext #loesung[Siehe @a1]]
#show-solutions(select: "pending")
