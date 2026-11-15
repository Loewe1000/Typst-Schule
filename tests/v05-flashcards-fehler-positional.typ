// flashcards 0.5.0: die Aufrufform aus 0.0.1 mit vier Positionsargumenten
// (Kopfzeile, Fußzeile, Frage, Antwort) bricht mit der neuen Schreibweise ab.
// fehler: flashcards.card: 4 Positionsargumente, erlaubt ist höchstens 2 – Kopf- und Fußzeile stehen benannt vor Frage und Antwort – `card(header: [...], footer: [...])[Frage][Antwort]` schreiben
#import "@schule/flashcards:0.5.0": card, show-cards
#card[Physik][Klasse 10][Was ist Energie?][Die Fähigkeit, Arbeit zu verrichten.]
#show-cards()
