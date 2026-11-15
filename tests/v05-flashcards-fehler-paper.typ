// flashcards 0.5.0: ungültiges Papierformat.
// fehler: flashcards.show-cards: `paper: "a5"` ist kein gültiger Wert – meintest du `"a4"`? erlaubt: `"a4"`, `"us-letter"`
#import "@schule/flashcards:0.5.0": card, show-cards
#card[Frage][Antwort]
#show-cards(paper: "a5")
