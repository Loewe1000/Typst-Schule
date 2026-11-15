// flashcards 0.5.0: `card` und `show-cards` auf A4. Drei Karten: Nummern
// „n/3", Kopfzeile, Fußzeile, Frage und Antwort erscheinen; die Antworten
// stehen auf der zweiten Seite mit vertauschten Spalten (2 vor 1).
// erwartet: Physik
// erwartet: Kinematik
// erwartet: Einheit der Kraft\?
// erwartet: 1/3
// erwartet: 3/3
// erwartet: Zurückwurf von Licht
// erwartet: 2/3 +1/3
// nicht: 4/3
#import "@schule/flashcards:0.5.0": card, show-cards
#set page(paper: "a4", margin: 0pt)

#card(header: [Physik], footer: [Kinematik])[Einheit der Geschwindigkeit?][Meter pro Sekunde]
#card(header: "Physik", footer: "Dynamik")[Einheit der Kraft?][Newton]
#card[Was ist Reflexion?][Zurückwurf von Licht an einer Grenzfläche.]

#show-cards()
