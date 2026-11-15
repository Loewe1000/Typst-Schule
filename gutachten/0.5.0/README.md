# gutachten

Gutachten über schriftliche Abiturprüfungen für Typst: Kopf mit Name, Fach
und Kürzel, je Aufgabe ein Abschnitt mit den erreichten Bewertungseinheiten,
am Ende Gesamtpunktzahl, Note der Oberstufe und Unterschriftszeilen.

## Import

```typ
#import "@schule/gutachten:0.5.0": set-options, set-tasks, gutachten, aufgabe, name, format-grade
```

## Beispiel

```typ
#import "@schule/gutachten:0.5.0": *

#set-options(subject: "Physik", level: "E", teacher: "MS", max-points: 100)

#set-tasks((
  "Aufgabe 1": (max-points: 30),
  "Aufgabe 2": (max-points: 40),
  "Aufgabe 3": (max-points: 30),
))

#gutachten(first-name: "Anna", last-name: "Bauer")[
  #aufgabe("Aufgabe 1", points: 25)[#name beschreibt die Bewegung korrekt.]
  #aufgabe("Aufgabe 2", points: 35)[Kleiner Rechenfehler in b).]
  #aufgabe("Aufgabe 3", points: 28)[Interpretation vollständig und präzise.]
]
```

Benötigt die Schriften „New Computer Modern Sans" und „Fira Math" (oder eigene
über `font` und `math-font`); fehlt eine, warnt Typst und nimmt eine
Ersatzschrift.

Umstieg von älteren Versionen: Namen siehe Handbuch, Abschnitt Umstieg.
