#import "@schule/schuldocs:0.2.0": show-example, show-module, show-code

= Über dieses Paket

Das `operatoren`-Paket verwaltet *Operatoren in Klausur- und Abituraufgaben*:
Operatoren werden inline markiert, intern gespeichert und am Ende des Dokuments
automatisch als tabellarische Referenzliste ausgegeben — mit der jeweiligen
Fachdefinition aus einer CSV-Datei.

Typischer Workflow:

1. Operatoren im Aufgabentext mit `#operator[Berechne]` markieren.
2. Am Ende des Dokuments `#operatoren-liste(fach: "Physik")` einfügen.
3. Typst erzeugt automatisch eine alphabetisch sortierte Tabelle
   aller verwendeten Operatoren mit ihren Definitionen.

Verfügbare Fächer: *Mathe* und *Physik* (CSV-Dateien im Paket enthalten).
Eigene Fächer können durch eine eigene CSV-Datei ergänzt werden.

= Schnellstart

#show-code[```typ
#import "@schule/operatoren:0.0.1": operator, operatoren-liste

// In den Aufgaben:
= Aufgabe 1

#operator[Berechne] den Wert des Ausdrucks $3x^2 - 5x + 2$ für $x = 3$.

= Aufgabe 2

#operator[Beschreibe] qualitativ den Verlauf des $v$-$t$-Diagramms.

= Aufgabe 3

#operator[Erkläre] das Superpositionsprinzip.

= Aufgabe 4

#operator[Leite] die Formel $E_"kin" = 1/2 m v^2$ aus $W = F dot s$ her.

// Am Ende des Dokuments automatisch generierte Operatorenliste:
#operatoren-liste(fach: "Physik")
```]

= Operatoren markieren

`#operator[Name]` markiert einen Operator und speichert ihn intern für die Liste.
Der Operator-Text erscheint im Fließtext als Link zur Definition in der Operatorenliste:

#show-code[```typ
// Einfache Markierung:
#operator[Berechne] die Geschwindigkeit nach $t = 5 "s"$.

// Mit alternativem Linktext (z. B. wenn der Operator im Satz flektiert wird):
#operator("berechne", text: "Berechnung")   // Zeigt "Berechnung", verlinkt "berechne"
#operator("beschreibe", text: "Beschreibung")

// Mehrere Operatoren in einer Aufgabe:
#operator[Skizziere] und #operator[beschrifte] den Graphen.
```]

== Alternativer Linktext

Wenn der Operator im Satz nicht in der Grundform vorkommt, kann mit `text:` ein
alternativer Anzeigetext gesetzt werden, während der `name`-Parameter die interne
Zuordnung zur CSV steuert:

#show-code[```typ
// Aufgabe: "Leiten Sie die Formel her …"
Leiten Sie (#operator("herleiten", text: "Herleitung")) die Formel …

// Aufgabe: "Zeichnen Sie …"
#operator("skizzieren", text: "Zeichnen Sie") den $v$-$t$-Graphen.
```]

= Operatorenliste

`#operatoren-liste(fach: ...)` erzeugt am Ende des Dokuments automatisch
eine `= Operatorenliste`-Überschrift und eine alphabetisch sortierte Tabelle
aller im Dokument verwendeten Operatoren:

#show-code[```typ
// Mathematik-Operatoren (Mathe.csv):
#operatoren-liste(fach: "Mathe")

// Physik-Operatoren (Physik.csv):
#operatoren-liste(fach: "Physik")
```]

Die Tabelle enthält in der linken Spalte den Operator (fett) und in der rechten Spalte
die Fach-Definition aus der CSV-Datei. Jeder Operator ist intern verlinkt
(Ziel der `#operator[...]`-Links im Text).

= Verfügbare Fächer

Das Paket enthält folgende CSV-Dateien:

#show-code[```
Mathe.csv   — Operatoren für den Mathematikunterricht
Physik.csv  — Operatoren für den Physikunterricht
```]

Die CSV-Dateien müssen sich im *selben Verzeichnis wie die kompilierte Typst-Datei*
befinden (oder per Symlink erreichbar sein), da Typst relative CSV-Pfade
aus dem Dokumentverzeichnis auflöst.

Bei Verwendung im `@schule/arbeitsblatt`-Template die CSV-Dateien ins Projektverzeichnis kopieren:

#show-code[```bash
cp "$(typst-pkg locate @schule/operatoren)/Mathe.csv" ./
```]

= Eigene Operatoren-CSV

Für andere Fächer (z. B. Biologie, Chemie, Geschichte) kann eine eigene CSV-Datei
angelegt werden. Format: *Semikolon-getrennt*, erste Spalte = Operator (Kleinbuchstaben),
zweite Spalte = Definition:

#show-code[```csv
angeben;Für die Angabe bzw. Nennung ist keine Begründung notwendig.
nennen;Für die Angabe bzw. Nennung ist keine Begründung notwendig.
beschreiben;Bei einer Beschreibung kommt einer sprachlich angemessenen Formulierung …
erklären;Der Sachverhalt ist darzulegen und kausal zu begründen.
berechnen;Eine mathematische Lösung ist gefordert. Der Rechenweg ist anzugeben.
zeichnen;Eine maßstabsgerechte, beschriftete Darstellung ist gefordert.
```]

Verwendung:

#show-code[```typ
#operatoren-liste(fach: "Biologie")  // liest Biologie.csv aus dem Dokumentverzeichnis
```]

= API-Referenz

#show-module(read("../operatoren.typ"), name: "operatoren")
