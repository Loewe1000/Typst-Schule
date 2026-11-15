#import "@schule/flashcards:0.5.0": card, show-cards

// Die Karten füllen die ganze Seite: Papier wie in `show-cards`, kein Rand.
#set page(paper: "a4", margin: 0pt)

#card(header: [Fach], footer: [Thema])[Frage auf der Vorderseite?][
  Antwort auf der Rückseite.
]

#card(header: [Fach], footer: [Thema])[Zweite Frage?][
  Zweite Antwort.
]

// Setzt alle Karten: je Bogen eine Seite Fragen, eine Seite Antworten.
// Beidseitig drucken und an der langen Kante wenden.
#show-cards(paper: "a4")
