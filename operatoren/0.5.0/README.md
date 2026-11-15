# operatoren

Markiert Operatoren im Aufgabentext und setzt am Ende des Dokuments die
Operatorenliste: eine Tabelle der verwendeten Operatoren mit ihrer Definition
aus den Fachanforderungen. Das Paket bringt die Definitionen für Mathe und
Physik mit, auf Deutsch und Italienisch.

```typ
#import "@schule/operatoren:0.5.0": operator, operatoren-liste

#operator("berechnen", caption: [Berechne]) die Geschwindigkeit nach $t = 5 "s"$.

#operator("skizzieren", caption: [Skizziere]) den Graphen.

#operatoren-liste(subject: "Physik")
```

`operator(name, caption: none, bold: auto)` bekommt den Namen des Operators,
wie er in der Operatorenliste steht (`"berechnen"`), und auf Wunsch den Text,
der im Satz stehen soll. `operatoren-liste(subject: "Mathe", language: "de",
bold: false)` setzt die Tabelle; `bold: true` setzt alle Operatoren im Text
fett.

Umstieg von älteren Versionen: Namen siehe Handbuch, Abschnitt Umstieg.
