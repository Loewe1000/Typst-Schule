#import "../../../schuldocs/0.1.0/lib.typ": show-example, show-module, show-code
#import "@preview/gentle-clues:1.2.0": tip

= Über dieses Paket

Das `informatik`-Paket stellt Hilfsfunktionen für den Informatikunterricht bereit:
klassische Verschlüsselungsverfahren, Zahlensystem-Konvertierungen,
Häufigkeitsanalysen und Scratch-Blockdiagramme.

Dieses Manual gliedert sich wie folgt:

+ *Schnellstart* -- Erste Schritte
+ *Kryptographie* -- Caesar, Vigenère, ROT13, Atbash
+ *Zahlensysteme* -- Binär, Hexadezimal, ASCII-Tabelle, Textblöcke
+ *Häufigkeitsanalysen* -- Buchstabenhäufigkeiten mit Diagramm
+ *Scratch-Blöcke* -- Scratch-Blockdiagramme mit `blockst`
+ *API-Referenz* -- Vollständige Funktionsdokumentation

= Schnellstart

```typ
#import "@schule/informatik:0.0.2": *
```

#show-example(
  rendered: {
    import "../lib.typ": caesar
    let c = caesar(key: 3)
    [Enkodiert: *#c("HALLO WELT")*]
  },
  source: ```typ
  #import "@schule/informatik:0.0.2": caesar
  #let c = caesar(key: 3)
  Enkodiert: *#c("HALLO WELT")*
  ```,
  width: 14cm,
)

= Kryptographie

== Caesar-Verschlüsselung

Die `caesar`-Funktion erstellt eine Verschlüsselungsfunktion, die mit einem
numerischen Schlüssel oder einem Schlüsselwort konfiguriert wird.

=== Einfacher Modus

#show-example(
  rendered: {
    import "../lib.typ": caesar
    let c = caesar(key: 3)
    [Kodiert: *#c("HALLO WELT")* \ Dekodiert: *#c("KDOOR ZHOW", true)*]
  },
  source: ```typ
  #let c = caesar(key: 3)
  Kodiert: *#c("HALLO WELT")*
  Dekodiert: *#c("KDOOR ZHOW", true)*
  ```,
  width: 14cm,
)

=== Schlüsseltabelle

Ohne Argumente gibt die Caesar-Funktion die Schlüsseltabelle aus:

#show-example(
  rendered: {
    import "../lib.typ": caesar
    caesar(key: 3)()
  },
  source: ```typ
  #caesar(key: 3)()
  ```,
  width: 14cm,
)

=== Mit Schlüsselwort

```typ
#let c = caesar(keyword: "GEHEIM")
#c("HALLO")
```

=== Erweiterter Modus

Im erweiterten Modus (`advanced: true`) wird ein Dictionary zurückgegeben:

```typ
#let c = caesar(key: 7, advanced: true)
#(c.encode)("HALLO WELT")
#(c.decode)("OHSSV DLSA")
#c.table
```

== Vigenère-Verschlüsselung

Polyalphabetische Substitution mit einem Schlüsselwort:

#show-example(
  rendered: {
    import "../lib.typ": vigenere
    let v = vigenere("SCHLUESSEL")
    let encoded = v("HALLO WELT")
    [Kodiert: *#encoded* \ Dekodiert: *#v(encoded, true)*]
  },
  source: ```typ
  #let v = vigenere("SCHLUESSEL")
  #let encoded = v("HALLO WELT")
  Kodiert: *#encoded*
  Dekodiert: *#v(encoded, true)*
  ```,
  width: 14cm,
)

#tip[
  Im erweiterten Modus (`advanced: true`) gibt `vigenere` ein Dictionary
  `(encode: function, decode: function, keyword: string)` zurück.
]

== ROT13

ROT13 ist ein vorkonfigurierter Caesar-Chiffre mit Verschiebung 13.
Da ROT13 selbst-invers ist, wird dieselbe Funktion zum En- und Dekodieren verwendet:

#show-example(
  rendered: {
    import "../lib.typ": rot13
    [ROT13("Hallo Welt") = *#rot13("Hallo Welt")* \ Zurück: *#rot13(rot13("Hallo Welt"))*]
  },
  source: ```typ
  ROT13("Hallo Welt") = *#rot13("Hallo Welt")*
  Zurück: *#rot13(rot13("Hallo Welt"))*
  ```,
  width: 14cm,
)

== Atbash

Atbash spiegelt das Alphabet (A↔Z, B↔Y, …). Die Funktion ist symmetrisch:

#show-example(
  rendered: {
    import "../lib.typ": atbash
    let a = atbash()
    [Kodiert: *#a("HALLO WELT")* \ Dekodiert: *#a(a("HALLO WELT"))*]
  },
  source: ```typ
  #let a = atbash()
  Kodiert: *#a("HALLO WELT")*
  Dekodiert: *#a(a("HALLO WELT"))*
  ```,
  width: 14cm,
)

= Zahlensysteme

== Binär ↔ Dezimal

#show-example(
  rendered: {
    import "../lib.typ": bin2dec, dec2bin
    table(
      columns: 2,
      [*Ausdruck*], [*Ergebnis*],
      [`dec2bin(42)`], [#dec2bin(42)],
      [`dec2bin(255)`], [#dec2bin(255)],
      [`bin2dec("1010")`], [#str(bin2dec("1010"))],
      [`bin2dec("11111111")`], [#str(bin2dec("11111111"))],
    )
  },
  source: ```typ
  #dec2bin(42)         // → "101010"
  #dec2bin(255)        // → "11111111"
  #bin2dec("1010")     // → 10
  #bin2dec("11111111") // → 255
  ```,
  width: 14cm,
)

== Hexadezimal ↔ Dezimal

#show-example(
  rendered: {
    import "../lib.typ": hex2dec, dec2hex
    table(
      columns: 2,
      [*Ausdruck*], [*Ergebnis*],
      [`dec2hex(255)`], [#dec2hex(255)],
      [`dec2hex(42)`], [#dec2hex(42)],
      [`hex2dec("FF")`], [#str(hex2dec("FF"))],
      [`hex2dec("2A")`], [#str(hex2dec("2A"))],
    )
  },
  source: ```typ
  #dec2hex(255)   // → "FF"
  #dec2hex(42)    // → "2A"
  #hex2dec("FF")  // → 255
  #hex2dec("2A")  // → 42
  ```,
  width: 14cm,
)

== ASCII-Tabelle

Die `ascii-table`-Funktion rendert eine formatierte ASCII-Tabelle:

#show-example(
  rendered: {
    import "../lib.typ": ascii-table
    ascii-table(ranges: (("A", "E"),), height: 5, variants: ("char", "dec", "hex", "bin"))
  },
  source: ```typ
  #ascii-table(
    ranges: (("A", "E"),),
    height: 5,
    variants: ("char", "dec", "hex", "bin"),
  )
  ```,
  width: 14cm,
)

#tip[
  Verfügbare Varianten: `"char"` (Zeichen), `"dec"` (Dezimal), `"hex"` (Hexadezimal), `"bin"` (Binär).
  Mit `colored: false` werden keine Farbhintergründe verwendet.
]

== Text in Blöcke

Teilt Text in Gruppen fester Größe auf -- nützlich für Kryptographie-Aufgaben:

#show-example(
  rendered: {
    import "../lib.typ": text-to-blocks
    [5er-Blöcke: *#text-to-blocks("HALLO WELT HEUTE")* \ 3er-Blöcke: *#text-to-blocks("HALLO WELT HEUTE", block-size: 3)*]
  },
  source: ```typ
  5er-Blöcke: *#text-to-blocks("HALLO WELT HEUTE")*
  3er-Blöcke: *#text-to-blocks("HALLO WELT HEUTE", block-size: 3)*
  ```,
  width: 14cm,
)

= Häufigkeitsanalysen

Die `häufigkeitsanalyse`-Funktion analysiert die Buchstabenhäufigkeiten im Text
und gibt ein Dictionary mit absoluten/relativen Häufigkeiten sowie einem
Säulendiagramm zurück.

#show-example(
  rendered: {
    import "../lib.typ": häufigkeitsanalyse
    let hf = häufigkeitsanalyse("DIES IST EIN BEISPIELTEXT FUER DIE HAEUFIGKEITSANALYSE")
    hf.diagramm
  },
  source: ```typ
  #let hf = häufigkeitsanalyse("DIES IST EIN BEISPIELTEXT...")
  #hf.diagramm
  ```,
  width: 14cm,
)

Das zurückgegebene Dictionary enthält:

#table(
  columns: (auto, auto, 1fr),
  [*Schlüssel*], [*Typ*], [*Beschreibung*],
  [`absolut`], [dictionary], [Absolute Häufigkeiten pro Buchstabe],
  [`relativ`], [dictionary], [Relative Häufigkeiten in Prozent],
  [`diagramm`], [content], [Säulendiagramm (CeTZ)],
  [`data`], [array], [Rohdaten: `(([Buchstabe], Wert), …)`],
  [`text`], [string], [Der ursprüngliche Eingabetext],
)

```typ
#let hf = häufigkeitsanalyse("Geheimtext")
// Häufigste Buchstaben:
#hf.absolut.pairs().sorted(key: p => -p.at(1)).slice(0, 5)
```

= Scratch-Blöcke

Das Paket re-exportiert das `blockst`-Paket für Scratch-ähnliche Blockdiagramme.
Folgende Symbole stehen direkt zur Verfügung:

#table(
  columns: (auto, 1fr),
  [*Symbol*], [*Beschreibung*],
  [`blockst`], [Umgebung für Scratch-Blöcke],
  [`blockst-run`], [Scratch-Blöcke mit Ausführungs-Indikator],
  [`scratch`], [Namespace mit `.de`-Unterobjekt für deutsche Block-Namen],
  [`set-blockst`], [Globale Konfiguration für `blockst`-Umgebung],
  [`set-scratch`], [Globale Konfiguration für Scratch-Blöcke],
  [`set-blockst-run`], [Globale Konfiguration für `blockst-run`],
  [`executable`], [Einzelner ausführbarer Block],
)

== Grundlegende Verwendung

#show-example(
  rendered: {
    import "../lib.typ": blockst, scratch, set-blockst
    set-blockst(scale: 70%)
    blockst[
      #import scratch.de: *
      #wiederhole(anzahl: 3)[
        #gehe(schritte: 10)
        #drehe-rechts(grad: 15)
      ]
    ]
  },
  source: ```typ
  #import "@schule/informatik:0.0.2": blockst, scratch, set-blockst

  #set-blockst(scale: 70%)
  #blockst[
    #import scratch.de: *
    #wiederhole(anzahl: 3)[
      #gehe(schritte: 10)
      #drehe-rechts(grad: 15)
    ]
  ]
  ```,
  width: 14cm,
)

#tip[
  Mit `#import scratch.de: *` werden alle deutschen Scratch-Block-Namen importiert.
  Weitere Themen und Konfigurationsmöglichkeiten sind in der `blockst`-Dokumentation
  beschrieben.
]

= API-Referenz

#show-module(read("../lib.typ"), name: "informatik")
