#import "../../../schuldocs/0.1.0/lib.typ": show-example, show-module, show-code

= Über dieses Paket

Das `gutachten`-Paket ist ein vollständiges *Bewertungssystem für Klausuren und Abiturprüfungen*.
Es verwaltet Schülerdaten, Aufgaben mit Bewertungseinheiten (BE), automatische Punktesummen
und die Umrechnung in Noten nach der Bewertungsskala (0 – 15 Punkte).

Kernfunktionen:

- `set-gutachten-infos(...)` — Globale Konfiguration (Fach, Niveau, Lehrkraft-Kürzel, Schriftarten).
- `set-aufgaben(...)` — Definition der Aufgaben mit jeweiliger BE-Anzahl.
- `gutachten(...)` — Äußerer Container pro Schüler (setzt Seite und Kopfzeile).
- `aufgabe(...)` — Aufgabensektion mit automatischem Punkteabgleich.
- `bewertungsskala(...)` — Konvertiert eine Prozentangabe in eine Note (0–15-Punkte-Skala).

Das zugehörige `bewertung.typ` stellt zusätzliche Hilfsfunktionen für
Erwartungshorizonte und Bewertungsbögen bereit.

= Schnellstart

Ein vollständiges Minimal-Gutachten:

#show-code[```typ
#import "@schule/gutachten:0.0.2": *

// 1. Globale Konfiguration
#set-gutachten-infos(
  fach: "Physik",
  niveau: "E",
  kürzel: "MS",
  print: true,
  be: 100,   // Gesamtpunktzahl
)

// 2. Aufgaben mit BE definieren
#set-aufgaben((
  "Aufgabe 1": (be: 30),
  "Aufgabe 2": (be: 40),
  "Aufgabe 3": (be: 30),
))

// 3. Gutachten für eine Schülerin
#gutachten(vorname: "Anna", nachname: "Bauer")[
  #aufgabe("Aufgabe 1", 25)[
    Anna beschreibt die Bewegung korrekt. Volle Punktzahl für Teilaufgabe a).
  ]
  #aufgabe("Aufgabe 2", 35)[
    Formeln korrekt angewendet. Kleiner Rechenfehler in b).
  ]
  #aufgabe("Aufgabe 3", 28)[
    Interpretation vollständig und präzise.
  ]
]
```]

= Konfiguration

Die Funktion `set-gutachten-infos` setzt globale Metadaten, die in allen
nachfolgenden `gutachten(...)`-Aufrufen gelten:

#show-code[```typ
#set-gutachten-infos(
  fach: "Mathematik",    // str: Fachbezeichnung
  niveau: "G",           // str: Kursniveau (z. B. "G", "E", "LK", "GK")
  kürzel: "AB",          // str: Lehrkraft-Kürzel
  print: false,          // bool: Druckmodus (true = Seitenränder für Heftung)
  be: 100,               // int: Gesamtzahl der Bewertungseinheiten
  font: "New Computer Modern Sans",   // str: Schriftart für Fließtext
  math-font: "Fira Math",             // str: Schriftart für Formeln
)
```]

= Aufgaben definieren

Das Dictionary der `set-aufgaben`-Funktion ordnet jedem Aufgabennamen
eine maximale BE-Anzahl zu. Die Schlüssel müssen mit den Namen der
`aufgabe(...)`-Aufrufe übereinstimmen:

#show-code[```typ
#set-aufgaben((
  "Aufgabe 1": (be: 20),
  "Aufgabe 2": (be: 30),
  "Aufgabe 3": (be: 25),
  "Aufgabe 4": (be: 25),
))
```]

= Gutachten erstellen

`gutachten(...)` erzeugt für jede Schülerin / jeden Schüler einen eigenen
Gutachtenabschnitt mit personalisierten Kopfzeilen. `aufgabe(...)` innerhalb
des Gutachtens zählt die Punkte automatisch zusammen:

#show-code[```typ
// Mehrere Gutachten hintereinander:
#gutachten(vorname: "Max", nachname: "Mustermann")[
  #aufgabe("Aufgabe 1", 18)[Max hat die Aufgabe größtenteils korrekt bearbeitet.]
  #aufgabe("Aufgabe 2", 27)[Kleiner Fehler bei der Einheit.]
]

#gutachten(vorname: "Lena", nachname: "Braun", wahl: ("Aufgabe 2", "Aufgabe 4"))[
  // wahl: Welche Aufgaben hat die Schülerin gewählt? (für Wahlaufgaben)
  #aufgabe("Aufgabe 2", 29)[Sehr gute Bearbeitung.]
  #aufgabe("Aufgabe 4", 24)[Teilweise unvollständig.]
]
```]

= Bewertungsskala

Die Funktion `bewertungsskala(prozent)` gibt die Noten-Bezeichnung (0–15-Punkte-System)
für eine gegebene Prozentzahl zurück:

#show-code[```typ
// Beispiele:
#bewertungsskala(0.95)   // → "sehr gut (15 Punkte)"
#bewertungsskala(0.72)   // → "gut (10 Punkte)"
#bewertungsskala(0.50)   // → "ausreichend (06 Punkte)"
#bewertungsskala(0.30)   // → "mangelhaft (02 Punkte)"
#bewertungsskala(0.00)   // → "ungenügend (00 Punkte)"

// In der Praxis: Punkte / Gesamtpunkte:
#let ergebnis = 72 / 100
#bewertungsskala(ergebnis)   // → "gut (10 Punkte)"
```]

Die vollständige Skala (NRW):

#show-code[```
≥ 95 %  → sehr gut  (15)      ≥ 55 % → befriedigend (07)
≥ 90 %  → sehr gut  (14)      ≥ 50 % → ausreichend  (06)
≥ 85 %  → sehr gut  (13)      ≥ 45 % → ausreichend  (05)
≥ 80 %  → gut       (12)      ≥ 40 % → ausreichend  (04)
≥ 75 %  → gut       (11)      ≥ 33 % → mangelhaft   (03)
≥ 70 %  → gut       (10)      ≥ 27 % → mangelhaft   (02)
≥ 65 %  → befriedigend (09)   ≥ 20 % → mangelhaft   (01)
≥ 60 %  → befriedigend (08)   < 20 % → ungenügend   (00)
```]

= Bewertungsbogen (`bewertung.typ`)

Das Paket enthält zusätzlich `bewertung.typ` mit Hilfsfunktionen für
tabellarische Erwartungshorizonte und Notenbögen:

#show-code[```typ
// Bewertungsbogen (separates Template):
#import "@schule/gutachten:0.0.2/bewertung.typ": *
#import "@schule/gutachten:0.0.2": set-gutachten-infos, set-aufgaben

#set-gutachten-infos(fach: "Physik", niveau: "E", kürzel: "MS", be: 100)

#set-aufgaben((
  "Aufgabe 1": (be: 30),
  "Aufgabe 2": (be: 40),
  "Aufgabe 3": (be: 30),
))

// Bewertungsbögen für alle Schülerinnen und Schüler
// (Funktionen aus bewertung.typ verwenden die gesetzten States)
```]

= API-Referenz

#show-module(read("../gutachten.typ"), name: "gutachten")
