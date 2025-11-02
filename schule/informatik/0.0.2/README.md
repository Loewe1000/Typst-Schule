# Informatik Paket für Typst# Informatik Paket für Typst



Ein Typst-Paket mit Funktionen für den Informatikunterricht.Ein Typst-Paket mit Funktionen für den Informatikunterricht.



## Installation## In#### `häufigkeitsanalyse(text, rel: false, cetz: true)`

Führt eine Häufigkeitsanalyse von Buchstaben durch.

```typ

#import "@preview/schule-informatik:0.0.1": *```typ

```// Für CeTZ-Diagramme

#häufigkeitsanalyse("Ein Beispieltext", rel: true)

**Hinweis:** Die Funktion `hf-diagramm()` benötigt das CeTZ-Paket für Diagramme (wird automatisch importiert).

// Als Dictionary

## Funktionen#häufigkeitsanalyse("Ein Beispieltext", cetz: false)

```

### Zahlenkonvertierung

#### `hf-diagramm(data)`

#### `bin2dec(zahl)`Erstellt ein Säulendiagramm aus Häufigkeitsdaten (benötigt CeTZ).

Konvertiert eine Binärzahl (als String oder Zahl) zu Dezimal.

```typ

```typ#let data = häufigkeitsanalyse("Beispieltext", rel: true, cetz: true)

#bin2dec("1010") // 10#hf-diagramm(data)

#bin2dec(1101)   // 13```

```

#### `text-to-blocks(text, block-size: 5)`

#### `dec2bin(zahl)`Teilt Text in Blöcke fester Größe auf.

Konvertiert eine Dezimalzahl zu Binär.

```typ

```typ#text-to-blocks("DIESISTEINTEST")      // "DIESI STEIN TEST"

#dec2bin(10)  // "1010"#text-to-blocks("HELLOWORLD", block-size: 3)  // "HEL LOW ORL D"

#dec2bin(255) // "11111111"```

```

#### `ascii-table(ranges: ((("a", "z"),)), height: 5)`

#### `hex2dec(hex)`Erstellt eine ASCII-Tabelle für angegebene Zeichenbereiche.

Konvertiert Hexadezimal zu Dezimal.

```typ

```typ// Kleinbuchstaben

#hex2dec("FF")   // 255#ascii-table(ranges: ((("a", "z"),)))

#hex2dec("A1")   // 161

```// Großbuchstaben und Ziffern

#ascii-table(ranges: ((("A", "Z"), ("0", "9"))), height: 6)

#### `dec2hex(num)`

Konvertiert Dezimal zu Hexadezimal.// Nur Ziffern

#ascii-table(ranges: ((("0", "9"),)), height: 2)

```typ```

#dec2hex(255)  // "FF"#import "@preview/schule-informatik:0.0.1": *

#dec2hex(161)  // "A1"```

```

## Funktionen

### Kryptographie

### Zahlenkonvertierung

#### `caesar(key: none, keyword: none)`

Erstellt ein Caesar-Chiffre-Objekt mit Methoden.#### `bin2dec(zahl)`

Konvertiert eine Binärzahl (als String oder Zahl) zu Dezimal.

**Einfache Verschiebung:**

```typ```typ

#let c1 = caesar(key: 3)#bin2dec("1010") // 10

#(c1.encode)("KLARTEXT")     // "NODUWHAW"#bin2dec(1101)   // 13

#(c1.decode)("NODUWHAW")     // "KLARTEXT"```

#c1.table                     // Zeigt Alphabete als Tabelle

```#### `dec2bin(zahl)`

Konvertiert eine Dezimalzahl zu Binär.

**Mit Schlüsselwort:**

```typ```typ

#let c2 = caesar(keyword: "GEHEIM")#dec2bin(10)  // "1010"

#(c2.encode)("ATTACK AT DAWN")  // Verschlüsselt mit Schlüsselwort#dec2bin(255) // "11111111"

#c2.table                        // Zeigt Alphabete```

```

### Kryptographie

**Hinweis:** Funktionen mit Parametern benötigen Klammern: `(c1.encode)("TEXT")`. Properties wie `table` und `keyword` sind direkt als Content verfügbar und brauchen keine Klammern.

#### `caesar(key: none, keyword: none)`

#### `vigenere(keyword)`Erstellt ein Caesar-Chiffre-Objekt mit Methoden.

Erstellt ein Vigenère-Chiffre-Objekt.

**Einfache Verschiebung:**

```typ```typ

#let v = vigenere("SCHLUESSEL")#let c1 = caesar(key: 3)

#(v.encode)("KLARTEXT")#(c1.encode)("KLARTEXT")     // "NODUWHAW"

#(v.decode)("GEHEIMTEXT")#(c1.decode)("NODUWHAW")     // "KLARTEXT"

```#c1.table                     // Zeigt Alphabete als Tabelle

```

#### `atbash`

Atbash-Chiffre (A↔Z, B↔Y, etc.). Verschlüsseln und Entschlüsseln sind identisch.**Mit Schlüsselwort:**

```typ

```typ#let c2 = caesar(keyword: "GEHEIM")

#(atbash.encode)("HELLO")  // "SVOOL"#(c2.encode)("ATTACK AT DAWN")  // Verschlüsselt mit Schlüsselwort

#(atbash.decode)("SVOOL")  // "HELLO"#c2.table                        // Zeigt Alphabete

``````



#### `rot13`**Hinweis:** Funktionen mit Parametern benötigen Klammern: `(c1.encode)("TEXT")`. Properties wie `table` und `keyword` sind direkt als Content verfügbar und brauchen keine Klammern.

Vordefinierte ROT13-Chiffre (Caesar mit Verschiebung 13).

#### `vigenere(keyword)`

```typErstellt ein Vigenère-Chiffre-Objekt.

#(rot13.encode)("HELLO")  // "URYYB"

#(rot13.decode)("URYYB")  // "HELLO"```typ

```#let v = vigenere("SCHLUESSEL")

#(v.encode)("KLARTEXT")

### Textanalyse#(v.decode)("GEHEIMTEXT")

```

#### `häufigkeitsanalyse(text, rel: false, cetz: true)`

Führt eine Häufigkeitsanalyse von Buchstaben durch.#### `atbash`

Atbash-Chiffre (A↔Z, B↔Y, etc.). Verschlüsseln und Entschlüsseln sind identisch.

```typ

// Für CeTZ-Diagramme (Array von Tupeln)```typ

#let data = häufigkeitsanalyse("Ein Beispieltext", rel: true, cetz: true)#(atbash.encode)("HELLO")  // "SVOOL"

#(atbash.decode)("SVOOL")  // "HELLO"

// Als Dictionary```

#let dict = häufigkeitsanalyse("Ein Beispieltext", rel: false, cetz: false)

```#### `rot13`

Vordefinierte ROT13-Chiffre (Caesar mit Verschiebung 13).

#### `hf-diagramm(data)`

Erstellt ein Säulendiagramm aus Häufigkeitsdaten (benötigt CeTZ).```typ

#(rot13.encode)("HELLO")  // "URYYB"

```typ#(rot13.decode)("URYYB")  // "HELLO"

#let data = häufigkeitsanalyse("Beispieltext", rel: true, cetz: true)```

#hf-diagramm(data)

```### Zahlenkonvertierung (erweitert)



#### `text-to-blocks(text, block-size: 5)`#### `hex2dec(hex)`

Teilt Text in Blöcke fester Größe auf.Konvertiert Hexadezimal zu Dezimal.



```typ```typ

#text-to-blocks("DIESISTEINTEST")             // "DIESI STEIN TEST"#hex2dec("FF")   // 255

#text-to-blocks("HELLOWORLD", block-size: 3)  // "HEL LOW ORL D"#hex2dec("A1")   // 161

``````



#### `ascii-table(ranges: ((("a", "z"),)), height: 5)`#### `dec2hex(num)`

Erstellt eine ASCII-Tabelle für angegebene Zeichenbereiche.Konvertiert Dezimal zu Hexadezimal.



```typ```typ

// Kleinbuchstaben#dec2hex(255)  // "FF"

#ascii-table(ranges: ((("a", "z"),)))#dec2hex(161)  // "A1"

```

// Großbuchstaben und Ziffern

#ascii-table(ranges: ((("A", "Z"), ("0", "9"))), height: 6)### Textanalyse



// Nur Ziffern#### `häufigkeitsanalyse(text, rel: false, cetz: true)`

#ascii-table(ranges: ((("0", "9"),)), height: 2)Führt eine Häufigkeitsanalyse von Buchstaben durch.

```

```typ

### Hilfsfunktionen// Für CeTZ-Diagramme

#häufigkeitsanalyse("Ein Beispieltext", rel: true)

#### `mono(body)`

Formatiert Text in Monospace-Schrift (SF Mono).// Als Dictionary

#häufigkeitsanalyse("Ein Beispieltext", cetz: false)

```typ```

#mono[Dies ist Monospace-Text]

```#### `text-to-blocks(text, block-size: 5)`

Teilt Text in Blöcke fester Größe auf.

## Legacy-Funktionen

```typ

Die folgenden Funktionen sind für Abwärtskompatibilität verfügbar:#text-to-blocks("DIESISTEINTEST")      // "DIESISTEIN TEST"

#text-to-blocks("HELLOWORLD", block-size: 3)  // "HEL LOW ORL D"

- `caesar-table(schlüssel)` → Verwende stattdessen `caesar(key: schlüssel).table````

- `caesar-schluessel-table(schlüssel)` → Verwende stattdessen `caesar(keyword: schlüssel).table`

### Hilfsfunktionen

## Beispiele

#### `mono(body)`

```typFormatiert Text in Monospace-Schrift (SF Mono).

#import "@preview/schule-informatik:0.0.1": *

```typ

// Binärkonvertierung#mono[Dies ist Monospace-Text]

Die Zahl #bin2dec("1111") in Dezimal ist 15. \```

Die Zahl #dec2bin(42) in Binär ist 101010.

## Legacy-Funktionen

// Caesar-Verschlüsselung

#let caesar3 = caesar(key: 3)Die folgenden Funktionen sind für Abwärtskompatibilität verfügbar:

Klartext: "HELLO WORLD" \

Geheimtext: #(caesar3.encode)("HELLO WORLD")- `caesar-table(schlüssel)` → Verwende stattdessen `caesar(key: schlüssel).table`

- `caesar-schluessel-table(schlüssel)` → Verwende stattdessen `caesar(keyword: schlüssel).table`

#caesar3.table

## Beispiele

// Vigenère

#let v = vigenere("KEY")```typ

Verschlüsselt: #(v.encode)("SECRET MESSAGE")#import "@preview/schule-informatik:0.0.1": *



// Häufigkeitsanalyse mit Diagramm// Binärkonvertierung

#let text = "Dies ist ein langer Beispieltext für die Häufigkeitsanalyse"Die Zahl #bin2dec("1111") in Dezimal ist 15. \

#let freq-data = häufigkeitsanalyse(text, rel: true, cetz: true)Die Zahl #dec2bin(42) in Binär ist 101010.

#hf-diagramm(freq-data)

// Caesar-Verschlüsselung

// ASCII-Tabelle#let caesar3 = caesar(key: 3)

#ascii-table(ranges: ((("A", "Z"), ("0", "9"))), height: 6)Klartext: "HELLO WORLD" \

```Geheimtext: #(caesar3.encode)("HELLO WORLD")



## Lizenz#caesar3.table



Dieses Paket ist frei verfügbar für Bildungszwecke.// Vigenère

#let v = vigenere("KEY")
Verschlüsselt: #(v.encode)("SECRET MESSAGE")

// Häufigkeitsanalyse
#let text = "Dies ist ein langer Beispieltext für die Häufigkeitsanalyse"
#let freq-data = häufigkeitsanalyse(text, rel: true, cetz: true)
#hf-diagramm(freq-data)

// ASCII-Tabelle
#ascii-table(ranges: ((("A", "Z"), ("0", "9"))), height: 6)
```
