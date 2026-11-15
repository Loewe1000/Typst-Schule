# angela

Briefvorlage der Angelaschule Osnabrück für Typst: Briefkopf mit Schulname,
Logo und blauer Linie, dazu die beiden Schulfarben `angela-dark` und
`angela-light`.

## Import

```typ
#import "@schule/angela:0.5.0": brief, angela-dark, angela-light
```

## Beispiel

```typ
#import "@schule/angela:0.5.0": brief

#show: brief

Sehr geehrte Eltern,

am 12. November findet der Elternsprechtag statt.

Mit freundlichen Grüßen

Die Schulleitung
```

Benötigt die Schriften „Lucida Grande", „Arial" und „Calibri"; fehlt eine,
warnt Typst und nimmt eine Ersatzschrift.

Umstieg von älteren Versionen: Namen siehe Handbuch, Abschnitt Umstieg.
