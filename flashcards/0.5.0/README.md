# flashcards

Lernkarten zum Ausdrucken: acht Karten je Seite (2 Spalten, 4 Zeilen), auf
einer Seite die Fragen, auf der nächsten die Antworten. Beidseitig gedruckt
liegt jede Antwort hinter ihrer Frage. Für A4 und US-Letter.

```typ
#import "@schule/flashcards:0.5.0": card, show-cards

#set page(paper: "a4", margin: 0pt)

#card(header: [Physik], footer: [Kinematik])[Einheit der Geschwindigkeit?][
  $[v] = "m/s"$
]
#card(header: [Physik], footer: [Dynamik])[Einheit der Kraft?][
  $[F] = "N"$
]

#show-cards()
```

| Funktion | Zweck |
|---|---|
| `card(header: none, footer: none)[Frage][Antwort]` | legt eine Karte an |
| `show-cards(paper: "a4")` | setzt alle Karten als Druckbögen; `paper: "us-letter"` für US-Letter |

Eine Vorlage zum Kopieren liegt in `template/lernkarten.typ`, ein größeres
Beispiel in `examples/physik-mathe.typ`.

Umstieg von älteren Versionen: Namen siehe Handbuch, Abschnitt Umstieg.
