# physik

Werkzeuge für den Physikunterricht in Typst: Messwerttabellen aus Datensätzen, berechnete Messreihen, sechs Regressionen mit gesetzter Gleichung, Schaltzeichen für Schaltkreise und eine Sammlung von Naturkonstanten.

Die Bausteine haben deutsche Namen (`datensatz`, `messdaten`, `berechnung`, `messwerttabelle`, `lineare-regression` …, `schaltkreis`, `konstante`), alles in den Klammern ist englisch.

## Import

```typ
#import "@schule/physik:0.5.0": *
```

## Beispiel

```typ
#import "@schule/physik:0.5.0": *

#let t = datensatz((1, 2, 3, 4, 5), name: "Zeit", unit: "s")
#let s = datensatz((1.2, 4.8, 10.8, 19.2, 30.0), name: "Weg", unit: "m")
#let v = berechnung((s, t) => s / t, datasets: (s, t), name: "Tempo", unit: [m/s])

#messwerttabelle(t, s, v)

#let fit = quadratische-regression(x: t, y: s)
Ausgleichskurve: #fit.math

#constants.g.symbol = #constants.g.qty
```

Für Schaltkreise kommen die eigenen Schaltzeichen (`source`, `lamp`, `ammeter`, `voltmeter`, `multimeter`, `motor`, `generator`) aus diesem Paket, Leitungen und alle weiteren Bauteile aus [zap](https://typst.app/universe/package/zap), das das Dokument selbst importiert.

## Umstieg von älteren Versionen

Namen siehe Handbuch, Abschnitt „Umstieg auf 0.5.0". Alte Namen brechen beim Kompilieren mit einer Meldung ab, die den neuen Namen nennt.
