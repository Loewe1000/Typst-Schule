#import "@preview/mantys:1.0.2": *

#import "../lib.typ" as info

#import "@preview/codly:1.3.0": *

#show: mantys(
  name: "informatik",
  version: "0.0.1",
  authors: (
    "Lukas Köhl",
    "Alexander Schulz",
  ),
  license: "MIT",
  description: "Ein umfassendes Paket für den Informatikunterricht mit Funktionen für Kryptographie, Zahlensysteme, Häufigkeitsanalysen und Scratch-Visualisierungen.",

  abstract: [
    Das `informatik` Paket bietet eine umfassende Sammlung von Funktionen für den Informatikunterricht. Es ermöglicht die Implementierung klassischer Verschlüsselungsverfahren (Caesar, Vigenère, Atbash), Konvertierungen zwischen Zahlensystemen (Binär, Dezimal, Hexadezimal), Häufigkeitsanalysen von Texten und die Erstellung von ASCII-Tabellen. Das Paket integriert auch Scratch-Visualisierungen für den Einstieg in die Programmierung.
  ],

  examples-scope: (
    scope: (informatik: info),
    imports: (informatik: "*"),
  ),
)

#show: codly-init.with()
#codly(number-format: none)

#pagebreak(weak: true)
= Über das Paket <sec:about>

Das `informatik` Paket ist eine umfassende Lösung für den Informatikunterricht. Es wurde entwickelt, um Lehrkräften leistungsstarke Werkzeuge für Kryptographie, Zahlensysteme, Textanalysen und visuelle Programmierung zu bieten.

Dieses Manual ist eine vollständige Referenz aller Funktionen des `informatik` Pakets.

== Terminologie

In diesem Manual werden folgende Begriffe verwendet:

- *Verschlüsselung*: Umwandlung von Klartext in Geheimtext
- *Entschlüsselung*: Umwandlung von Geheimtext zurück in Klartext
- *Zahlensystem*: Basis zur Darstellung von Zahlen (Binär, Dezimal, Hexadezimal)
- *Häufigkeitsanalyse*: Statistische Auswertung von Buchstabenhäufigkeiten
- *ASCII*: American Standard Code for Information Interchange
- *Scratch*: Visuelle Programmiersprache für Einsteiger

== Module

Das Paket besteht aus folgenden Bereichen:

- *Kryptographie*: Caesar, Vigenère, Atbash, ROT13
- *Zahlensysteme*: Binär ↔ Dezimal ↔ Hexadezimal
- *Textanalyse*: Häufigkeitsanalyse mit Visualisierung
- *ASCII-Tabellen*: Flexible Zeichenübersichten
- *Scratch*: Visuelle Programmierblöcke (im scratch.typ Modul)

== Abhängigkeiten

Das Paket nutzt folgende externe Pakete:
- `@preview/cetz`: Für Diagramme und Visualisierungen

= Schnelleinstieg <sec:quickstart>

Für den schnellen Einstieg importieren Sie das Paket und nutzen die Verschlüsselungsfunktionen:

Caesar-Verschlüsselung:

#example[```
#let c = caesar(key: 3)
#c("HALLO WELT")        // → "KDOOR ZHOW"
```]

#example[```
#let c = caesar(key: 3)
#c("KDOOR ZHOW", true)  // → "HALLO WELT"
```]

Vigenère-Verschlüsselung:

#example[```
#let v = vigenere("SCHLUESSEL")
#v("GEHEIMTEXT")        // Verschlüsseln
```]

Zahlensysteme:

#example[```
#bin2dec("1010")  // → 10
```]

#example[```
#dec2hex(255)     // → "FF"
```]

Häufigkeitsanalyse:

#example[```
#let hf = häufigkeitsanalyse("Beispieltext")
#hf.diagramm
```]

== Erste Schritte

1. *Installation*: Importieren Sie das Paket
2. *Kryptographie*: Erstellen Sie Verschlüsselungsobjekte
3. *Konvertierung*: Nutzen Sie Zahlensystem-Funktionen
4. *Analyse*: Führen Sie Häufigkeitsanalysen durch
5. *Visualisierung*: Erstellen Sie ASCII-Tabellen und Diagramme

= Kryptographie <sec:cryptography>

== Caesar-Chiffre <sec:caesar>

Die Caesar-Chiffre verschiebt jeden Buchstaben um eine feste Anzahl im Alphabet.

=== Einfacher Modus

Im einfachen Modus gibt `caesar()` eine Funktion zurück:

#example[```
// Erstellen mit numerischem Schlüssel
#let c = caesar(key: 3)

// Verschlüsseln
#c("HALLO")  // → "KDOOR"
```]

Entschlüsseln:

#example[```
#let c = caesar(key: 3)
#c("KDOOR", true)  // → "HALLO"
```]

Substitutions-Tabelle anzeigen:

#example[```
#let c = caesar(key: 3)
#c()
```]

=== Erweiterter Modus

Im erweiterten Modus erhalten Sie ein Dictionary mit Methoden:

```typ
#let c = caesar(key: 3, advanced: true)

// Verschlüsseln
#(c.encode)("HALLO")  // → "KDOOR"

// Entschlüsseln
#(c.decode)("KDOOR")  // → "HALLO"

// Tabelle anzeigen
#c.table

// Zugriff auf Eigenschaften
#c.key                    // → 3
#c.alphabet               // → "ABC...XYZ"
#c.geheimtext-alphabet    // → "DEF...ABC"
```

=== Schlüsselwort-basierte Caesar-Chiffre

Statt einer Zahl kann auch ein Schlüsselwort verwendet werden:

```typ
#let c = caesar(keyword: "GEHEIM")

#c("KLARTEXT")  // Verschlüsseln mit Schlüsselwort-Alphabet
```

Das Schlüsselwort wird ohne Duplikate ins Alphabet eingefügt, der Rest folgt danach:

```
Klartext:    A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
Geheimtext:  G E H I M A B C D F J K L N O P Q R S T U V W X Y Z
```

== Vigenère-Chiffre <sec:vigenere>

Die Vigenère-Chiffre ist eine polyalphabetische Substitution mit einem Schlüsselwort.

=== Einfacher Modus

#example[```
#let v = vigenere("SCHLUESSEL")

// Verschlüsseln
#v("KLARTEXT")  // → "CBICJFEAJ"
```]

Entschlüsseln:

#example[```
#let v = vigenere("SCHLUESSEL")
#v("CBICJFEAJ", true)  // → "KLARTEXT"
```]

=== Erweiterter Modus

```typ
#let v = vigenere("SCHLUESSEL", advanced: true)

// Verschlüsseln
#(v.encode)("KLARTEXT")

// Entschlüsseln
#(v.decode)("CBICJFEAJ")

// Schlüsselwort abrufen
#v.keyword  // → "SCHLUESSEL"
```

=== Funktionsweise

Jeder Buchstabe wird mit dem entsprechenden Buchstaben des Schlüsselworts verschoben:

```
Klartext:      K  L  A  R  T  E  X  T
Schlüssel:     S  C  H  L  U  E  S  S
Verschoben um: 18 2  7  11 20 4  18 18
Geheimtext:    C  B  I  C  J  F  E  A
```

== Atbash-Chiffre <sec:atbash>

Die Atbash-Chiffre spiegelt das Alphabet (A↔Z, B↔Y, C↔X, ...):

```typ
#let a = atbash()

// Verschlüsseln (identisch mit Entschlüsseln)
#a("HALLO")  // → "SZOOL"
#a("SZOOL")  // → "HALLO"
```

Erweiterter Modus:

```typ
#let a = atbash(advanced: true)

#(a.encode)("HALLO")  // → "SZOOL"
#(a.decode)("SZOOL")  // → "HALLO"
```

== ROT13 <sec:rot13>

ROT13 ist ein Spezialfall der Caesar-Chiffre mit Verschiebung 13:

```typ
// ROT13 ist vordefiniert
#rot13("HALLO")        // → "UNYYY"
#rot13("UNYYY", true)  // → "HALLO"
```

Da ROT13 eine Verschiebung um 13 verwendet, ist Verschlüsseln identisch mit Entschlüsseln:

```typ
#rot13("GEHEIM")  // → "TRURVZ"
#rot13("TRURVZ")  // → "GEHEIM"
```

== Hilfsfunktionen <sec:crypto-helpers>

=== Text in Blöcke aufteilen

```typ
#text-to-blocks("DIESISTEINTEST")
// → "DIESI STEIN TEST"

#text-to-blocks("HELLOWORLD", block-size: 3)
// → "HEL LOW ORL D"
```

Diese Funktion ist nützlich für die lesbare Darstellung von Geheimtexten.

= Zahlensysteme <sec:number-systems>

== Binär ↔ Dezimal <sec:binary-decimal>

=== Binär zu Dezimal

```typ
#bin2dec("1010")    // → 10
#bin2dec("11111111") // → 255
#bin2dec(1101)      // → 13 (funktioniert auch mit Zahlen)
```

=== Dezimal zu Binär

```typ
#dec2bin(10)   // → "1010"
#dec2bin(255)  // → "11111111"
#dec2bin(0)    // → "0"
```

== Hexadezimal ↔ Dezimal <sec:hex-decimal>

=== Hexadezimal zu Dezimal

```typ
#hex2dec("FF")   // → 255
#hex2dec("A1")   // → 161
#hex2dec("10")   // → 16
```

=== Dezimal zu Hexadezimal

```typ
#dec2hex(255)  // → "FF"
#dec2hex(161)  // → "A1"
#dec2hex(16)   // → "10"
```

== Kombinierte Konvertierungen <sec:combined-conversions>

Für Konvertierungen zwischen Binär und Hexadezimal nutzen Sie Dezimal als Zwischenschritt:

```typ
// Binär → Hexadezimal
#let binär = "11111111"
#let dezimal = bin2dec(binär)
#let hex = dec2hex(dezimal)
// "11111111" → 255 → "FF"

// Hexadezimal → Binär
#let hex = "FF"
#let dezimal = hex2dec(hex)
#let binär = dec2bin(dezimal)
// "FF" → 255 → "11111111"
```

= Häufigkeitsanalyse <sec:frequency-analysis>

Die Häufigkeitsanalyse ist ein wichtiges Werkzeug der Kryptanalyse.

== Grundlegende Verwendung <sec:freq-basic>

#example[```
#let hf = häufigkeitsanalyse("Dies ist ein Beispieltext für die Häufigkeitsanalyse")

// Säulendiagramm
#hf.diagramm
```]

Absolute Häufigkeiten:

#example[```
#let hf = häufigkeitsanalyse("ABCABC")

// Zeige nur die Häufigkeiten von A, B, C
A: #hf.absolut.at("A") \
B: #hf.absolut.at("B") \
C: #hf.absolut.at("C")
```]

Relative Häufigkeiten (Prozent):

#example[```
#let hf = häufigkeitsanalyse("AABBBC")

E: #hf.relativ.at("E")% \
A: #hf.relativ.at("A")% \
B: #hf.relativ.at("B")% \
C: #hf.relativ.at("C")%
```]

== Eigenschaften <sec:freq-properties>

Das Ergebnis von `häufigkeitsanalyse()` ist ein Dictionary mit:

- `absolut`: Dictionary mit absoluten Häufigkeiten für A-Z
- `relativ`: Dictionary mit relativen Häufigkeiten (0-100%)
- `diagramm`: Fertiges Säulendiagramm als Content
- `data`: Array für CeTZ im Format `(([A], wert), ([B], wert), ...)`
- `text`: Der ursprüngliche Eingabetext

== Visualisierung <sec:freq-visualization>

Das Paket erstellt automatisch ein grünes Säulendiagramm:

```typ
#let text = "AAABBBCCCDDDEEEFFFGGGHHHIIIJJJKKKLLLMMMNNNOOO"
#let hf = häufigkeitsanalyse(text)

#hf.diagramm
```

Für eigene Visualisierungen nutzen Sie `hf.data`:

```typ
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": chart

#let hf = häufigkeitsanalyse("Beispieltext")

#canvas({
  chart.columnchart(
    hf.data,
    size: (15, 6),
    bar-style: (fill: blue, stroke: none)
  )
})
```

== Anwendung in der Kryptanalyse <sec:freq-cryptanalysis>

Häufigkeitsanalysen helfen beim Brechen von Substitutionschiffren:

```typ
#let geheimtext = "KDOOR ZHOW"
#let hf = häufigkeitsanalyse(geheimtext)

// Häufigste Buchstaben anzeigen
#hf.relativ

// Vergleich mit deutscher Sprache:
// E: ~17%, N: ~10%, I: ~8%, S: ~7%, R: ~7%
```

= ASCII-Tabellen <sec:ascii-tables>

== Grundlegende Tabellen <sec:ascii-basic>

Kleinbuchstaben a-z:

#example[```
#ascii-table(ranges: ((("a", "z"),)), height: 9)
```]

Großbuchstaben A-Z:

#example[```
#ascii-table(ranges: ((("A", "Z"),)), height: 9)
```]

Ziffern 0-9:

#example[```
#ascii-table(ranges: ((("0", "9"),)), height: 5)
```]

== Mehrere Bereiche <sec:ascii-multiple>

```typ
// Groß- und Kleinbuchstaben
#ascii-table(ranges: ((("A", "Z"), ("a", "z"))))

// Buchstaben und Ziffern
#ascii-table(ranges: ((("A", "Z"), ("0", "9"))))

// Einzelne Zeichen einschließen
#ascii-table(ranges: ((" ", "!", "?", ("A", "Z"))))
```

== Darstellungsvarianten <sec:ascii-variants>

Nur Zeichen und Dezimalwert:

#example[```
#ascii-table(
  ranges: ((("a", "z"),)),
  variants: ("char", "dec"),
  height: 9,
)
```]

Mit Binärdarstellung:

#example[```
#ascii-table(
  ranges: ((("A", "J"),)),
  variants: ("char", "dec", "bin"),
  height: 5,
)
```]

Mit Hexadezimaldarstellung:

#example[```
#ascii-table(
  ranges: ((("0", "9"),)),
  variants: ("char", "dec", "hex"),
  height: 5
)
```]

Alle Darstellungen:

#example[```
#ascii-table(
  ranges: ((("A", "F"),)),
  variants: ("char", "dec", "bin", "hex"),
  height: 3
)
```]

== Layout-Anpassungen <sec:ascii-layout>

```typ
// Höhe der Tabelle (Anzahl Zeilen)
#ascii-table(
  ranges: ((("a", "z"),)),
  height: 10  // Standard: 5
)

// Ohne Farben (Graustufig)
#ascii-table(
  ranges: ((("A", "Z"),)),
  colored: false
)

// Kompakte Darstellung
#ascii-table(
  ranges: ((("0", "9"),)),
  height: 2,
  variants: ("char", "dec")
)
```

== Praktische Beispiele <sec:ascii-examples>

=== Druckbare ASCII-Zeichen

```typ
#ascii-table(
  ranges: (((33, 126),)),  // ! bis ~
  height: 15,
  variants: ("char", "dec", "hex")
)
```

=== Vergleichstabelle

```typ
// Groß- und Kleinbuchstaben nebeneinander
#grid(
  columns: 2,
  column-gutter: 1em,
  [
    *Großbuchstaben*
    #ascii-table(ranges: ((("A", "Z"),)))
  ],
  [
    *Kleinbuchstaben*
    #ascii-table(ranges: ((("a", "z"),)))
  ]
)
```

= API-Referenz <sec:api-reference>

== Kryptographie-Funktionen

#command("caesar")[
  Erstellt eine Caesar-Chiffre mit Verschiebung oder Schlüsselwort.

  #argument("key", types: "integer", default: none)[
    Numerischer Schlüssel für die Verschiebung (0-25).
  ]

  #argument("keyword", types: "string", default: none)[
    Schlüsselwort für alphabetbasierte Verschiebung.
  ]

  #argument("advanced", types: "boolean", default: false)[
    Wenn `true`, gibt ein Dictionary mit Methoden zurück. Wenn `false`, gibt eine aufrufbare Funktion zurück.
  ]

  Im einfachen Modus (`advanced: false`):
  - `c(text)`: Verschlüsselt Text
  - `c(text, true)`: Entschlüsselt Text
  - `c()`: Zeigt Substitutions-Tabelle

  Im erweiterten Modus (`advanced: true`):
  - `c.encode(text)`: Verschlüsselt Text
  - `c.decode(text)`: Entschlüsselt Text
  - `c.table`: Substitutions-Tabelle als Content
  - `c.key`: Numerischer Schlüssel
  - `c.keyword`: Schlüsselwort (falls verwendet)
  - `c.alphabet`: Klartext-Alphabet
  - `c.geheimtext-alphabet`: Geheimtext-Alphabet

  #sourcecode[```typ
  // Mit Schlüssel
  #let c = caesar(key: 3)
  #c("HALLO")        // → "KDOOR"
  #c("KDOOR", true)  // → "HALLO"
  
  // Mit Schlüsselwort
  #let c2 = caesar(keyword: "GEHEIM")
  #c2("TEXT")
  
  // Erweitert
  #let c3 = caesar(key: 13, advanced: true)
  #(c3.encode)("TEST")
  #c3.table
  ```]
]

#command("vigenere")[
  Erstellt eine Vigenère-Chiffre mit Schlüsselwort.

  #argument("keyword", types: "string", default: none)[
    Schlüsselwort für die polyalphabetische Substitution (erforderlich).
  ]

  #argument("advanced", types: "boolean", default: false)[
    Wenn `true`, gibt ein Dictionary mit Methoden zurück.
  ]

  Im einfachen Modus:
  - `v(text)`: Verschlüsselt Text
  - `v(text, true)`: Entschlüsselt Text

  Im erweiterten Modus:
  - `v.encode(text)`: Verschlüsselt Text
  - `v.decode(text)`: Entschlüsselt Text
  - `v.keyword`: Das verwendete Schlüsselwort

  #sourcecode[```typ
  #let v = vigenere("SCHLUESSEL")
  #v("KLARTEXT")        // Verschlüsseln
  #v("...", true)       // Entschlüsseln
  ```]
]

#command("atbash")[
  Erstellt eine Atbash-Chiffre (Alphabet-Spiegelung).

  #argument("advanced", types: "boolean", default: false)[
    Wenn `true`, gibt ein Dictionary mit Methoden zurück.
  ]

  Da Atbash symmetrisch ist, sind Verschlüsseln und Entschlüsseln identisch.

  #sourcecode[```typ
  #let a = atbash()
  #a("HALLO")  // → "SZOOL"
  #a("SZOOL")  // → "HALLO"
  ```]
]

#command("rot13")[
  Vordefinierte Caesar-Chiffre mit Verschiebung 13.

  Dies ist eine Konstante, keine Funktion. Verwendung identisch zu `caesar(key: 13)`.

  #sourcecode[```typ
  #rot13("TEST")  // Verschlüsseln
  ```]
]

== Zahlensystem-Funktionen

#command("bin2dec")[
  Konvertiert Binärzahl zu Dezimal.

  #argument("zahl", types: "string, integer", default: none)[
    Binärzahl als String oder Integer.
  ]

  #sourcecode[```typ
  #bin2dec("1010")    // → 10
  #bin2dec(11111111)  // → 255
  ```]
]

#command("dec2bin")[
  Konvertiert Dezimalzahl zu Binär.

  #argument("zahl", types: "integer", default: none)[
    Dezimalzahl.
  ]

  #sourcecode[```typ
  #dec2bin(10)   // → "1010"
  #dec2bin(255)  // → "11111111"
  ```]
]

#command("hex2dec")[
  Konvertiert Hexadezimalzahl zu Dezimal.

  #argument("hex", types: "string", default: none)[
    Hexadezimalzahl als String.
  ]

  #sourcecode[```typ
  #hex2dec("FF")  // → 255
  #hex2dec("A1")  // → 161
  ```]
]

#command("dec2hex")[
  Konvertiert Dezimalzahl zu Hexadezimal.

  #argument("num", types: "integer", default: none)[
    Dezimalzahl.
  ]

  #sourcecode[```typ
  #dec2hex(255)  // → "FF"
  #dec2hex(161)  // → "A1"
  ```]
]

== Textanalyse-Funktionen

#command("häufigkeitsanalyse")[
  Führt eine Häufigkeitsanalyse von Buchstaben durch.

  #argument("text", types: "string", default: none)[
    Der zu analysierende Text.
  ]

  Gibt ein Dictionary mit folgenden Keys zurück:
  - `absolut`: Dictionary mit absoluten Häufigkeiten (A-Z)
  - `relativ`: Dictionary mit relativen Häufigkeiten in % (A-Z)
  - `diagramm`: Fertiges Säulendiagramm als Content
  - `data`: Array für CeTZ im Format `(([A], wert), ...)`
  - `text`: Ursprünglicher Eingabetext

  #sourcecode[```typ
  #let hf = häufigkeitsanalyse("Beispieltext")
  #hf.absolut.at("E")  // Absolute Häufigkeit von E
  #hf.relativ.at("E")  // Relative Häufigkeit von E in %
  #hf.diagramm         // Visualisierung
  ```]
]

#command("text-to-blocks")[
  Teilt Text in Blöcke fester Größe auf.

  #argument("text", types: "string", default: none)[
    Der aufzuteilende Text.
  ]

  #argument("block-size", types: "integer", default: 5)[
    Größe der Blöcke (Anzahl Zeichen).
  ]

  #sourcecode[```typ
  #text-to-blocks("DIESISTEINTEST")
  // → "DIESI STEIN TEST"
  
  #text-to-blocks("HELLOWORLD", block-size: 3)
  // → "HEL LOW ORL D"
  ```]
]

== ASCII-Funktionen

#command("ascii-table")[
  Erstellt eine ASCII-Tabelle für angegebene Zeichenbereiche.

  #argument("ranges", types: "array", default: ((("a", "z"),)))[
    Array von Zeichenbereichen. Jeder Bereich ist ein Tupel `(start, end)` oder ein einzelnes Zeichen.
  ]

  #argument("height", types: "integer", default: 5)[
    Anzahl der Zeilen in der Tabelle.
  ]

  #argument("variants", types: "array", default: ("char", "dec"))[
    Darstellungsvarianten. Mögliche Werte: `"char"`, `"dec"`, `"bin"`, `"hex"`.
  ]

  #argument("colored", types: "boolean", default: true)[
    Wenn `true`, werden Spalten farbig hinterlegt. Wenn `false`, Graustufendarstellung.
  ]

  #sourcecode[```typ
  // Kleinbuchstaben mit Dezimal und Hex
  #ascii-table(
    ranges: ((("a", "z"),)),
    variants: ("char", "dec", "hex"),
    height: 7
  )
  
  // Großbuchstaben ohne Farbe
  #ascii-table(
    ranges: ((("A", "Z"),)),
    colored: false
  )
  ```]
]

= Integration mit anderen Paketen <sec:integration>

== Mit Aufgaben-Paket <sec:with-tasks>

Vollständige Integration für Informatik-Aufgaben:

```typ
#import "@schule/informatik:0.0.1": *
#import "@schule/aufgaben:0.1.2": *

#set_options((loesungen: "folgend"))

#aufgabe(title: [Caesar-Verschlüsselung])[
  Verschlüsseln Sie den Text "HALLO" mit einem Caesar-Shift von 3.
  
  #loesung[
    #let c = caesar(key: 3)
    
    Verschlüsselt: #c("HALLO")
    
    Substitutions-Tabelle:
    #c()
  ]
]

#aufgabe(title: [Zahlensystemkonvertierung])[
  Konvertieren Sie die Binärzahl 11010110 in Dezimal und Hexadezimal.
  
  #loesung[
    Binär: `11010110`
    
    #let dez = bin2dec("11010110")
    Dezimal: #dez
    
    #let hex = dec2hex(dez)
    Hexadezimal: #hex
  ]
]
```

== Mit Mathematik-Paket <sec:with-math>

Nutzung für statistische Auswertungen:

```typ
#import "@schule/informatik:0.0.1": *
#import "@schule/mathematik:0.0.2": graphen

#let text = "DIES IST EIN SEHR LANGER BEISPIELTEXT FÜR DIE HÄUFIGKEITSANALYSE"
#let hf = häufigkeitsanalyse(text)

// Diagramm anzeigen
#hf.diagramm

// Benutzerdefinierter Graph mit relativen Häufigkeiten
// (erfordert manuelle Konvertierung der Daten)
```

= Fehlerbehebung <sec:troubleshooting>

== Häufige Probleme

=== Verschlüsselung funktioniert nicht korrekt

- Stellen Sie sicher, dass Groß-/Kleinschreibung beachtet wird
- Sonderzeichen werden nicht verschlüsselt (nur A-Z)
- Verwenden Sie `upper()` für einheitliche Verarbeitung

=== Zahlensystem-Konvertierung gibt falsche Ergebnisse

- Binärzahlen müssen als Strings übergeben werden: `"1010"` nicht `1010`
- Hexadezimalzahlen müssen Großbuchstaben sein
- Überprüfen Sie auf führende Nullen

=== Häufigkeitsanalyse zeigt keine Daten

- Der Text muss Buchstaben enthalten (A-Z)
- Zahlen und Sonderzeichen werden ignoriert
- Verwenden Sie `hf.absolut` um zu prüfen, welche Buchstaben erkannt wurden

=== ASCII-Tabelle zeigt falsche Zeichen

- Ranges müssen als Tupel `(start, end)` angegeben werden
- Überprüfen Sie die height-Einstellung
- Verwenden Sie `variants` um gewünschte Spalten anzuzeigen

= Lizenz und Beiträge <sec:license>

Das Paket steht unter der MIT-Lizenz und ist Teil der `@schule` Paketfamilie.

Entwickelt von Lukas Köhl und Alexander Schulz.

#pagebreak(weak: true)
= Scratch (WIP) <sec:scratch>

Die Scratch-Integration ist derzeit als WIP verfügbar. Sie bietet visuelle Blöcke (Ereignisse, Bewegung, Aussehen, Klang, Fühlen, Operatoren, Variablen, Listen) sowie Kontrollstrukturen und eigene Blöcke. API kann sich ändern.

== Grundprinzip <sec:scratch-basics>

- Blöcke sind Content-Bausteine: Du setzt sie einfach untereinander.
- Ereignisblöcke haben eine „Kappe“, Anweisungsblöcke einen Steck-Notch oben und unten, Bedingungen sind rautenförmig, Reporter pill-förmig.

Ein einfaches Skript: Start-Ereignis mit drei Bewegungsanweisungen.

#example[```typ
#ereignis([Wenn gestartet], [
  #gehe-schritt(schritt: 10)
  #drehe-dich-um(richtung: "rechts", grad: 15)
  #gleite-in(sek: 1, zu: "Zufallsposition")
])
```]

== Schleifen und Verzweigungen <sec:scratch-control>

Wiederhole-Schleife mit Blockkörper:

#example[```typ
#wiederhole(anzahl: 10, loop-body: [
  #gehe-schritt(schritt: 5)
  #drehe-dich-um(richtung: "rechts", grad: 15)
])
```]

If/Else mit Bedingung (Rautenblock) und dann/sonst-Körpern:

#example[```typ
#falls(
  taste-gedrückt(taste: "Leertaste"),
  dann-body: [#sage(text: "Jump!")],
  sonst-body: [#sage(text: "...")]
)
```]

== Reporter und Bedingungen <sec:scratch-reporters>

Reporter liefern Werte (z. B. Größe, Mausposition) und können in Bedingungen oder anderen Blöcken verschachtelt werden.

#example[```typ
#größer-als(
  stoppuhr(),
  50,
)
```]

Weitere Beispiele: `maus-x-position()`, `maus-y-position()`, `antwort()` nach `frage(...)`, `lautstärke()` u. a.

== Variablen und Listen <sec:scratch-variables-lists>

Variablen anlegen/ändern/anzeigen und Listen manipulieren:

#example[```typ
#setze-variable-auf(name: "score", wert: 0)
#ändere-variable-um(name: "score", wert: 1)
#füge-zu-hinzu(wert: "Apfel", liste: "Inventar")
#element-von(index: 1, liste: "Inventar")
```]

== Eigene Blöcke <sec:scratch-custom>

Eigene Anweisungsblöcke mit Platzhaltern und „Definiere“-Kopf:

#example[```typ
// Signatur definieren (Label mit Platzhaltern)
#let gib-zurück = eigener-block("gib", eigene-eingabe("Zahl"), "zurück")

// Kopf der Definition ausgeben
#definiere(gib-zurück)
```]
Im Label können auch Reporter verschachtelt werden, z. B. `eigene-reporter("Wert")`.

== Darstellung und Barrierefreiheit <sec:scratch-accessibility>

- Farben folgen den Scratch-Kategorien. Eine High-Contrast-Variante ist im Modul vorbereitet, aktuell jedoch intern deaktiviert (WIP). In einer künftigen Version wird ein Schalter bereitgestellt.
- Typografie: Helvetica Neue, klare Konturen, an Vorbild angelehnte Geometrie (Kappe, Notch, Rauten, Pills).

== API-Überblick (WIP) <sec:scratch-api>

Wichtige verfügbare Funktionen. Alle stammen aus dem `scratch`-Modul und werden über `@schule/informatik` re-exportiert:

- Blöcke (Content):
  - `ereignis(body, children)` – Ereigniskopf mit Kappe; `children` enthält die nachfolgenden Blöcke als Content.
  - `bewegung(body)`, `aussehen(body)`, `klang(body)`, `fühlen(body)`, `variablen(body)`, `listen(body)` – farbcodierte Anweisungen.
  - Kontrollstrukturen: `wiederhole(anzahl: 10, loop-body: none)`, `falls(bedingung, dann-body: none, sonst-body: none)`.

- Vorgefertigte Befehlsblöcke (Auswahl):
  - Bewegung: `gehe-zu(x, y)`, `gleite-in(sek, zu)`, `setze-Richtung-auf(grad)`, `gehe(zu)`, `drehe-dich-um(richtung, grad)`, `ändere-x-um`, `setze-x-auf`, `ändere-y-um`, `setze-y-auf`, `pralle-vom-rand-ab`.
  - Aussehen: `sage(text, sekunden)`, `denke(text, sekunden)`, `wechsle-zu-kostüm(kostüm)`, `wechsle-zum-nächsten-kostüm`, `ändere-größe-um`, `setze-größe-auf`, `ändere-effekt`, `setze-effekt`, `schalte-grafikeffekte-aus`, `zeige-dich`, `verstecke-dich`.
  - Klang: `spiele-klang(sound, ganz)`, `stoppe-alle-klänge`, `ändere-klang-effekt`, `setze-klang-effekt`, `schalte-klangeffekte-aus`, `ändere-lautstärke-um`, `setze-lautstärke-auf`.
  - Fühlen: `frage(text)`, `setze-ziehbarkeit-auf(modus)`, `setze-stoppuhr-zurück` u. a.
  - Variablen/Listen: `setze-variable-auf`, `ändere-variable-um`, `zeige-variable`, `verstecke-variable`, `füge-zu-hinzu`, `lösche-aus`, `lösche-alles-aus`, `füge-bei-in-ein`, `ersetze-element-von-durch`, `zeige-liste`, `verstecke-liste`.

- Reporter (Werte, pill-förmig):
  - Aussehen: `kostüm(eigenschaft)`, `bühnenbild(eigenschaft)`, `größe()`
  - Klang: `lautstärke()`
  - Fühlen: `entfernung-von(objekt)`, `antwort()`, `maus-x-position()`, `maus-y-position()`, `stoppuhr()`, `von-bühne(eigenschaft, objekt)`, `zeit(einheit)`, `tage-seit-2000()`, `benutzername()`
  - Listen: `element-von(index, liste)`, `nummer-von-in(wert, liste)`, `länge-von-liste(liste)`
  - Operatoren: `plus(a, b)`, `minus(a, b)`, `mal(a, b)`, `geteilt(a, b)`, `zufallszahl(von, bis)`, `modulo(a, b)`, `gerundet(zahl)`, `betrag-von(operation, zahl)`, `verbinde(text1, text2)`, `zeichen(position, von)`, `länge-von(text)`

- Bedingungen (Rauten, boolesch):
  - Fühlen: `taste-gedrückt(taste, nested)`, `maustaste-gedrückt(nested)`, `wird-mauszeiger-berührt(nested)`, `wird-farbe-berührt(color, nested)`, `farbe-berührt((c1, c2), nested)`
  - Operatoren: `größer-als(a, b, nested)`, `kleiner-als(a, b, nested)`, `gleich(a, b, nested)`, `und(a, b, nested)`, `oder(a, b, nested)`, `nicht(a, nested)`

- Pills (Inputs):
  - `pill-round(text)`, `pill-reporter(text)`, `pill-rect(text)`, `pill-color(" ", fill: rgb("#36B7CE"))`

Hinweise:
- `ereignis` nimmt genau einen `children`-Parameter entgegen. Um mehrere Anweisungen zu übergeben, fassen Sie sie in einem Content-Block `[...]` zusammen (siehe Beispiele).
- Farben und Kontraste sind an Scratch angelehnt; Geometrie (Kappe, Notch, Rauten) folgt dem Look & Feel.
