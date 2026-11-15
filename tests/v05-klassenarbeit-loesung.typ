// Die Fassung "solutions": Lösungen statt Aufgabentext, dann der Erwartungshorizont.
// erwartet: Lösung 1
// erwartet: Die Antwort ist 42
// erwartet: Erwartungshorizont
// nicht: Wie lautet die Antwort
#import "@schule/klassenarbeit:0.5.0": *
#show: klassenarbeit.with(title: [K], preview-variant: "solutions")
#aufgabe(title: [Frage])[Wie lautet die Antwort? #erwartung(1)[42] #loesung[Die Antwort ist 42]]
