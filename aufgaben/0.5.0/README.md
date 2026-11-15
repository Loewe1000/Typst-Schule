# aufgaben

Aufgaben und Teilaufgaben für den Schulunterricht: Lösungen, Materialien, Erwartungshorizont und Punktetabelle. Das Paket ist das Fundament der Vorlagen `arbeitsblatt` und `klassenarbeit`, die alle seine Funktionen weiterreichen.

## Import

```typ
#import "@schule/aufgaben:0.5.0": *
```

## Beispiel

```typ
#import "@schule/aufgaben:0.5.0": *

#set-options(solutions: "in-place", points: "all")

#aufgabe(title: [Bruchrechnung], method: "pair")[
  Berechne $3/4 + 1/2$.

  #teilaufgabe[Bestimme den Hauptnenner. #loesung[4] #erwartung(1)[Hauptnenner 4]]
  #teilaufgabe[Addiere die Brüche. #loesung[$5/4$] #erwartung(2)[Ergebnis $5/4$]]
]

#show-points-table()
#show-expectations()
```

Die Bausteine heißen deutsch (`aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung`), alles in den Klammern ist englisch. Optionen setzt `set-options(…)`; die Vorlagen haben dieselben Optionen im Kopf.

## Umstieg von älteren Versionen

Namen siehe Handbuch, Abschnitt „Umstieg auf 0.5.0“. Alte Namen und Werte brechen mit einer Meldung ab, die den neuen Namen nennt (``aufgaben.set-options: `loesungen` heißt jetzt `solutions` ``).
