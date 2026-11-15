# informatik

Werkzeuge für den Informatikunterricht in Typst: klassische Chiffren (Caesar,
Vigenère, Atbash, ROT13) mit Schlüsseltabelle, Häufigkeitsanalyse mit
Säulendiagramm, Umwandlungen zwischen Binär-, Dezimal- und Hexadezimalzahlen,
ASCII-Tabelle und Textblöcke.

## Import

```typ
#import "@schule/informatik:0.5.0": *
```

## Beispiel

```typ
#import "@schule/informatik:0.5.0": *

Geheimtext: #caesar("HALLO WELT", key: 3) \
Klartext: #caesar("KDOOR ZHOW", key: 3, inverse: true)

#caesar-table(key: 3)

#vigenere("HALLO WELT", key: "LEMON"), #rot13("Hallo"), #atbash("HALLO")

#dec-to-bin(42), #bin-to-dec("101010"), #dec-to-hex(255), #hex-to-dec("FF")

#ascii-table(domains: (("A", "E"),), fields: ("character", "dec", "hex", "bin"))

#text-to-blocks("HALLO WELT HEUTE", character-count: 5)

#let analysis = haeufigkeitsanalyse("Dies ist ein Beispieltext")
#analysis.chart
```

## Funktionen

| Funktion | Zweck |
|---|---|
| `caesar(text, key:, inverse:)` | Caesar-Chiffre; `key` ist Verschiebung (Zahl) oder Schlüsselwort (Text) |
| `caesar-table(key:)` | Schlüsseltabelle der Caesar-Chiffre |
| `vigenere(text, key:, inverse:)` | Vigenère-Chiffre mit Schlüsselwort |
| `atbash(text)`, `rot13(text)` | selbstinverse Chiffren |
| `haeufigkeitsanalyse(text)` | Buchstaben zählen; Ergebnis mit `counts`, `frequencies`, `items`, `chart`, `text` |
| `bin-to-dec`, `dec-to-bin`, `hex-to-dec`, `dec-to-hex` | Zahlensysteme |
| `ascii-table(domains:, rows:, fields:, colored:)` | ASCII-Tabelle |
| `text-to-blocks(text, character-count:)` | Text in Blöcken fester Länge |

Die Scratch-Blöcke aus `blockst` reicht das Paket nicht mehr weiter:
`#import "@preview/blockst:0.1.0": blockst, scratch` schreiben.

## Umstieg von älteren Versionen

Namen siehe Handbuch, Abschnitt Umstieg. Alte Namen brechen mit einer Meldung
ab, die den neuen nennt (`bin2dec` heißt jetzt `bin-to-dec`).
