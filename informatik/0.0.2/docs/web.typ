#import "@preview/manifesto:0.1.1": *

#let pkg = toml("../typst.toml")

#show: it => template(
  it,
  toml: pkg,
  universe: "https://typst.app/universe/package/informatik",
  notices: (
    [Entwickelt für das Schule-Typst-Ökosystem],
  ),
  links: (
    (name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),
  ),
)

= Über dieses Paket

Das `informatik`-Paket stellt Hilfsfunktionen für den Informatikunterricht bereit: klassische Verschlüsselungsverfahren, Zahlensystem-Konvertierungen, Häufigkeitsanalysen und Scratch-Blockdiagramme.

Dieses Manual gliedert sich wie folgt:

+ *Installation & Import* -- Erste Schritte
+ *Kryptographie* -- Caesar, Vigenère, Rot13, Atbash
+ *Zahlensysteme* -- Binär, Hexadezimal, ASCII
+ *Häufigkeitsanalysen* -- Buchstabenhäufigkeiten
+ *Scratch-Blöcke* -- Scratch-Blockdiagramme
+ *Funktionsreferenz* -- Vollständige API-Dokumentation

== Installation & Import

```typ
#import "@schule/informatik:0.0.2": *
```

Für Scratch-Blöcke wird `blockst` benötigt:

```typ
#import "@schule/informatik:0.0.2": scratch

#blockst[
  #import scratch.de: *  // Deutsche Scratch-Blöcke
  // ... Scratch-Code
]
```

= Kryptographie

== Caesar-Verschlüsselung

Verschiebt jeden Buchstaben um einen festen Wert:

```typ
// Einfache Anwendung auf „HALLO":
#caesar(3)      // Gibt eine Kodier-Funktion zurück

// Fortgeschrittener Modus (Tabelle):
#let c = caesar(3, advanced: true)
// c.encode("HALLO") → "KDOOR"
// c.decode("KDOOR") → "HALLO"
```

Mit `keyword` wird ein Schlüsselwort statt einer Zahl verwendet:

```typ
#let c = caesar(keyword: "GEHEIM", advanced: true)
```

== Vigenère-Verschlüsselung

Polyalphabetische Substitution mit einem Schlüsselwort:

```typ
// Einfache Anwendung:
#vigenere("SCHLUESSEL")

// Fortgeschrittener Modus:
#let v = vigenere("SCHLUESSEL", advanced: true)
// v.encode("HALLO WELT")
// v.decode("...")
// v.grid          → Vigenère-Quadrat als Tabelle
```

== ROT13

Spezialfall von Caesar mit Verschiebung 13:

```typ
#rot13("Hallo Welt")
// → "Uryyb Jryg"
```

== Atbash

Spiegelt das Alphabet (A↔Z, B↔Y, …):

```typ
// Einfache Anwendung:
#atbash()

// Fortgeschrittener Modus:
#let a = atbash(advanced: true)
// a.encode("HALLO")
// a.decode("HSOOL")
```

= Zahlensysteme

== Dezimal ↔ Binär

```typ
#dec2bin(42)     // → "101010"
#bin2dec("101010")  // → 42
```

== Dezimal ↔ Hexadezimal

```typ
#dec2hex(255)    // → "FF"
#hex2dec("FF")   // → 255
```

== ASCII-Tabelle

```typ
// Tabelle mit 16 Zeilen (Standard):
#ascii-table()

// Eigene Zeilenzahl:
#ascii-table(height: 32)
```

Zeigt druckbare ASCII-Zeichen (32–127) mit Dezimal- und Hex-Werten.

#schema(
  {
    import "/lib.typ": ascii-table
    ascii-table(height: 4)
  },
  code: ```typ
  #ascii-table(height: 4)
  ```,
  width: 14cm,
)

== Text in Blöcke

```typ
#text-to-blocks("HALLO")
// Zeigt jeden Buchstaben als einzelnen Kasten
```

#schema(
  {
    import "/lib.typ": text-to-blocks
    text-to-blocks("HALLO")
  },
  code: ```typ
  #text-to-blocks("HALLO")
  ```,
  width: 14cm,
)

Nützlich für Verschlüsselungsübungen auf dem Arbeitsblatt.

= Häufigkeitsanalysen

Analysiert die Buchstabenhäufigkeiten in einem Text:

```typ
#let analyse = häufigkeitsanalyse("Das ist ein Beispieltext.")

// Zugriff auf die Ergebnisse:
analyse.absolut    // Dictionary: Buchstabe → absolute Häufigkeit
analyse.relativ    // Dictionary: Buchstabe → relative Häufigkeit (0–1)
analyse.diagramm   // Balkendiagramm als content
analyse.data       // Rohdaten (Array)
```

Beispiel-Nutzung:

```typ
// Diagramm direkt einbinden:
#let a = häufigkeitsanalyse("GEHEIMTEXT")
#a.diagramm

// Tabelle der relativen Häufigkeiten:
#for (buchstabe, häufigkeit) in a.relativ {
  [#buchstabe: #{calc.round(häufigkeit * 100, digits: 1)}%]
}
```

#schema(
  {
    import "/lib.typ": häufigkeitsanalyse
    let a = häufigkeitsanalyse("GEHEIMTEXT")
    a.diagramm
  },
  code: ```typ
  #let a = häufigkeitsanalyse("GEHEIMTEXT")
  #a.diagramm
  ```,
  width: 14cm,
)

= Scratch-Blöcke

Das Paket integriert das `blockst`-Paket für Scratch-ähnliche Blockdiagramme.

== Grundlegende Verwendung

```typ
#import "@schule/informatik:0.0.2": scratch

#blockst[
  #import scratch.de: *

  #wiederhole(10)[
    #gehe(10)
    #drehe-rechts(15)
  ]
]
```

== Verfügbare Themen

```typ
#set-scratch(theme: "scratch3")   // Scratch 3.0-Optik (Standard)
#set-scratch(theme: "scratch2")   // Scratch 2.0-Optik
#set-scratch(stroke-width: 1.5pt) // Strichbreite der Blöcke
```

== Bewegungsblöcke

#table(
  columns: (1fr, auto),
  stroke: 0.5pt + luma(180),
  table.header([*Block*], [*Typst-Code*]),
  [Gehe 10 Schritte], [`#gehe(10)`],
  [Drehe rechts], [`#drehe-rechts(15)`],
  [Drehe links], [`#drehe-links(15)`],
  [Pralle vom Rand], [`#pralle-vom-rand-ab()`],
  [Setze x-Position], [`#setze-x(0)`],
  [Setze y-Position], [`#setze-y(0)`],
  [Gehe zu x/y], [`#gehe-zu-xy(x: 0, y: 0)`],
)

== Kontrollblöcke

#table(
  columns: (1fr, auto),
  stroke: 0.5pt + luma(180),
  table.header([*Block*], [*Typst-Code*]),
  [Wiederhole n-mal], [`#wiederhole(10)[...]`],
  [Wiederhole bis], [`#wiederhole-bis(bedingung)[...]`],
  [Wenn … dann], [`#falls(bedingung)[...]`],
  [Wenn … sonst], [`#falls-sonst(bedingung)[...][...]`],
  [Warte], [`#warte(1)`],
  [Stoppe alles], [`#stoppe-alles()`],
)

== Variablen und Operatoren

```typ
#setze-variable("Punkte", 0)
#ändere-variable("Punkte", 1)

// Operatoren:
#addiere(3, 4)
#subtrahiere(10, 3)
#multipliziere(2, 5)
#dividiere(10, 2)
```

== Vollständiges Scratch-Beispiel

```typ
#import "@schule/informatik:0.0.2": scratch

#blockst[
  #import scratch.de: *

  #wenn-flag-geklickt()
  #setze-variable("Schritt", 0)
  #wiederhole-bis[#gleich(#variable("Schritt"), 36)][
    #gehe(10)
    #drehe-rechts(10)
    #ändere-variable("Schritt", 1)
    #warte(0.1)
  ]
  #stoppe-alles()
]
```

= Anwendungsbeispiele

== Kryptographie-Arbeitsblatt

```typ
#import "@schule/informatik:0.0.2": *
#import "@schule/arbeitsblatt:0.2.4": *

#show: arbeitsblatt.with(title: "Caesar-Verschlüsselung", class: "7a")

= Aufwärmen

Verschlüssle "HALLO" mit dem Caesar-Chiffre (Schlüssel = 3):

#text-to-blocks("HALLO")
#text-to-blocks("     ")  // Leerraum für die Antwort

= Analyse

Analysiere den folgenden Geheimtext:

#let analyse = häufigkeitsanalyse("KHOOR ZRUOG")
#analyse.diagramm

Vergleiche mit typischen deutschen Buchstabenhäufigkeiten.
```

== Zahlensysteme-Übung

```typ
#aufgabe[
  Konvertiere zwischen den Zahlensystemen.

  #teilaufgabe[
    $42_("dez")$ = #lücke[101010] $_(2)$
    
    Lösung: `#dec2bin(42)`
  ]

  #teilaufgabe[
    $"FF"_("hex")$ = #lücke[255] $_("dez")$
    
    Lösung: `#hex2dec("FF")`
  ]
]
```

= Funktionsreferenz

== Kryptographie

#table(
  columns: (auto, auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Funktion*], [*Parameter*], [*Rückgabe*]),
  [`caesar(key, keyword, advanced)`], [Schlüssel (1–25) oder Schlüsselwort], [Funktion oder `{encode, decode}`],
  [`vigenere(keyword, advanced)`], [Schlüsselwort], [Funktion oder `{encode, decode, grid}`],
  [`rot13(text)`], [Text], [Verschlüsselter Text],
  [`atbash(advanced)`], [—], [Funktion oder `{encode, decode}`],
)

== Zahlensysteme

#table(
  columns: (auto, auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Funktion*], [*Parameter*], [*Rückgabe*]),
  [`dec2bin(n)`], [Ganzzahl], [Binärstring],
  [`bin2dec(s)`], [Binärstring], [Ganzzahl],
  [`dec2hex(n)`], [Ganzzahl], [Hexadezimalstring],
  [`hex2dec(s)`], [Hexadezimalstring], [Ganzzahl],
  [`ascii-table(height)`], [Zeilenzahl (Standard: 16)], [ASCII-Tabelle],
  [`text-to-blocks(text)`], [Zeichenkette], [Darstellung als Blöcke],
)

== Analyse

#table(
  columns: (auto, auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Funktion*], [*Parameter*], [*Rückgabe*]),
  [`häufigkeitsanalyse(text)`], [Beliebiger Text], [`{absolut, relativ, diagramm, data}`],
)

== Scratch

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Funktion*], [*Beschreibung*]),
  [`set-scratch(theme, stroke-width)`], [Globales Scratch-Thema setzen],
  [`scratch`], [Import-Objekt für `blockst`],
)
