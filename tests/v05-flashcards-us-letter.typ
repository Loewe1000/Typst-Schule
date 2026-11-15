// flashcards 0.5.0: `show-cards(paper: "us-letter")` darf vor den Karten
// stehen und setzt trotzdem alle; neun Karten ergeben zwei Bögen.
// erwartet: Frage 1
// erwartet: Antwort 9
// erwartet: 9/9
// erwartet: Thema
#import "@schule/flashcards:0.5.0": card, show-cards
#set page(paper: "us-letter", margin: 0pt)

#show-cards(paper: "us-letter")

#for n in range(1, 10) {
  card(header: [Fach], footer: [Thema])[Frage #n][Antwort #n]
}
