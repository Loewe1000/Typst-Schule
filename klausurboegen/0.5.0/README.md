# klausurboegen

Klausurbögen im A3-Querformat zum Falten: kariertes oder liniertes Schreibfeld
mit Korrekturrand, Kopf mit Namenszeile und ein Ergebnisdruck, der
Punktetabelle, Note und Notenschlüssel aus einer CSV-Datei auf die
beschriebenen Bögen setzt.

```typ
#import "@schule/klausurboegen:0.5.0": klausurboegen

// leerer Bogen mit Kopf
#klausurboegen(
  title: "Physik",
  subtitle: "Schwingungen und Wellen",
  teacher: "MÜ",
  class: "Q1",
  date: "15.05.2026",
)

// liniert, Korrekturrand an der Falz
#klausurboegen(title: "Deutsch", pattern: "lines", correction-margin-side: "inside")

// Blankobogen ohne Kopf
#klausurboegen()
```

Der Ergebnisdruck braucht dieselben Kopfangaben und die Zeilen einer CSV-Datei
(`results: csv("ergebnisse.csv")`, dazu `overprint: true`); das Handbuch
beschreibt den Aufbau der Datei.

Öffentlicher Name: `klausurboegen`. Der Baustein heißt deutsch, alles in den
Klammern ist englisch. Gebraucht wird die Schrift Myriad Pro.

Umstieg von älteren Versionen: Namen siehe Handbuch, Abschnitt „Umstieg auf 0.5.0“.
