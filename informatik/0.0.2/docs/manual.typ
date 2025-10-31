#import "@preview/mantys:1.0.2": *

#import "../lib.typ" as info

#import "@preview/codly:1.3.0": *

#import "@schule/blockst:0.0.1": de, set-blockst

#show: mantys(
  name: "informatik",
  version: "0.0.2",
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
    scope: (informatik: info, de: de),
    imports: (informatik: "*", de: "*"),
  ),
)

#set text(lang: "de")

= Über dieses Paket

Das #package[informatik] Paket ist eine umfassende Lösung für den Informatikunterricht. Es kombiniert praktische Kryptographie- und Kodierungsfunktionen mit einem vollständigen visuellen System zur Darstellung von Scratch-Programmierblöcken.

Dieses Manual gliedert sich wie folgt:
1. *Installation und Import* -- Erste Schritte
2. *Kryptographie* -- Verschlüsselungsalgorithmen
3. *Kodierung* -- Zahlensysteme und Zeichensätze
4. *Häufigkeitsanalyse* -- Textanalyse für Kryptoanalyse
5. *Scratch-Blöcke* -- Visuelle Programmierung
6. *Funktionsreferenz* -- Vollständige API-Dokumentation

= Installation und Import

== Paket importieren

Das Paket kann einfach importiert werden:

#sourcecode[```typ
#import "@schule/informatik:0.0.1": *
```]

== Abhängigkeiten

Das Paket nutzt folgende externe Pakete:
- #package[cetz] (0.4.2) -- Für Diagramme in Häufigkeitsanalysen
- #package[cetz-plot] (0.1.3) -- Für Plot-Funktionen

#pagebreak(weak: true)
= Kryptographie

== Caesar-Verschlüsselung

=== Einfacher Modus

Im einfachen Modus gibt die Funktion direkt eine Verschlüsselungsfunktion zurück:

#example[```typ
// Funktion mit Schlüssel 3 erstellen
#let caesar3 = caesar(key: 3)

// Verschlüsseln
#caesar3("HALLO")
// Ausgabe: KDOOR
```]

=== Erweiterter Modus

Im erweiterten Modus gibt die Funktion ein Objekt mit `encode()` und `decode()` Methoden zurück:

#example[```typ
#let cipher = caesar(key: 3, advanced: true)

#(cipher.encode)("HALLO")    // KDOOR
#(cipher.decode)("KDOOR")     // HALLO
```]

=== Mit Schlüsselwort

Caesar-Verschlüsselung mit Schlüsselwort-Alphabet:

#example[```typ
#let cipher = caesar(keyword: "SCHLUESSEL", advanced: true)

#(cipher.encode)("HALLO")
#(cipher.decode)((cipher.encode)("HALLO"))
```]

== Vigenère-Verschlüsselung

=== Einfacher Modus

#example[```typ
#let vig = vigenere("SCHLUESSEL")

#vig("HALLO WELT")
```]

=== Erweiterter Modus

#example[```typ
#let cipher = vigenere("SCHLUESSEL", advanced: true)

#(cipher.encode)("HALLO WELT")
#(cipher.decode)((cipher.encode)("HALLO WELT"))
```]

== ROT13

ROT13 ist eine spezielle Caesar-Verschlüsselung mit Verschiebung 13:

#example[```typ
#rot13("HALLO")
// Ausgabe: UNYYB

// ROT13 ist selbst-invers
#rot13(rot13("HALLO"))
// Ausgabe: HALLO
```]

== Atbash

Atbash spiegelt das Alphabet (A↔Z, B↔Y, C↔X, ...):

#example[```typ
// Erweiterter Modus
#let cipher = atbash(advanced: true)
#(cipher.encode)("HALLO")
#(cipher.decode)((cipher.encode)("HALLO"))
```]

= Kodierung

== Binäre Zahlen

=== Dezimal zu Binär

#example[```typ
#dec2bin(42)
// Ausgabe: 101010

#dec2bin(255)
// Ausgabe: 11111111
```]

=== Binär zu Dezimal

#example[```typ
#bin2dec("101010")
// Ausgabe: 42

#bin2dec("11111111")
// Ausgabe: 255
```]

== Hexadezimale Zahlen

=== Dezimal zu Hexadezimal

#example[```typ
#dec2hex(42)
// Ausgabe: 2A

#dec2hex(255)
// Ausgabe: FF
```]

=== Hexadezimal zu Dezimal

#example[```typ
#hex2dec("2A")
// Ausgabe: 42

#hex2dec("FF")
// Ausgabe: 255
```]

== ASCII-Tabelle

Erstellt eine vollständige ASCII-Tabelle:

#example[```typ
#ascii-table(height: 9)
```]

Die Tabelle zeigt alle druckbaren ASCII-Zeichen mit ihren Dezimal-, Hexadezimal- und Binärwerten.

== Text zu Blöcken

Konvertiert Text in formatierte Blöcke (z.B. für binäre Darstellung):

#example[```typ
#text-to-blocks("ZIBOIUSDFNGIZSDFOIZSDBIOFIJSDIFBLSIDF")
```]

= Häufigkeitsanalyse

Die Häufigkeitsanalyse ist ein wichtiges Werkzeug für die Kryptoanalyse:

#sourcecode[```typ
#let analyse = häufigkeitsanalyse("HALLO WELT DIES IST EIN TEST")

// Absolute Häufigkeiten
#analyse.absolut

// Relative Häufigkeiten
#analyse.relativ

// Diagramm anzeigen
#analyse.diagramm
```]

== Rückgabewerte

Die Funktion gibt ein Dictionary zurück mit:

- `absolut`: Dictionary mit absoluten Häufigkeiten (z.B. `E: 5`, `L: 3`)
- `relativ`: Dictionary mit relativen Häufigkeiten in Prozent (z.B. `E: 0.25`, `L: 0.15`)
- `diagramm`: Visualisiertes Balkendiagramm (CeTZ-Content)
- `data`: Rohdaten als Array für eigene Plots

#example[```typ
#let text = "DIESISTEINBEISPIELTEXTFUERDIEANALYSE"
#let analyse = häufigkeitsanalyse(text)

// Häufigste Buchstaben finden
#let sortiert = analyse.absolut.pairs().sorted(key: p => -p.at(1))

Die häufigsten Buchstaben: #sortiert.slice(0, 5)
```]

= Scratch-Blöcke

== Grundlagen

Das Paket bietet vollständige Unterstützung für die Darstellung von Scratch-Programmierblöcken mit allen Kategorien und visuellen Stilen.

=== Konfiguration

Vor der Verwendung sollte das Theme konfiguriert werden:

#sourcecode[```typ
// Standard-Theme
#set-scratch(theme: "normal")

// Oder High-Contrast-Theme
#set-scratch(theme: "high-contrast")

// Mit dicker Umrandung
#set-scratch(theme: "normal", stroke-width: 2pt)
```]

=== Verfügbare Themes

- `"normal"`: Standard-Farbschema von Scratch
- `"high-contrast"`: Kontrastreiche Farben für bessere Lesbarkeit

== Block-Kategorien

=== Bewegung (Blau)

#sourcecode[```typ
#gehe(schritte: 10)
#drehe-rechts(grad: 15)
#drehe-links(grad: 15)
#gehe-zu-position("Mauszeiger")
#gehe-zu(x: 0, y: 0)
#gleite-zu-position(sekunden: 1, "Mauszeiger")
#gleite-zu(sekunden: 1, x: 0, y: 0)
#setze-richtung(grad: 90)
#drehe-zu("Mauszeiger")

#aendere-x(aenderung: 10)
#setze-x(x: 0)
#aendere-y(aenderung: 10)
#setze-y(y: 0)

#pralle-vom-rand-ab()
#setze-drehtyp(typ: "links-rechts")
#x-position()
#y-position()
#richtung()
```]

=== Aussehen (Lila)

#sourcecode[```typ
#sage-fuer-sekunden("Hallo!", sekunden: 2)
#sage("Hallo!")
#denke-fuer-sekunden("Hmm...", sekunden: 2)
#denke("Hmm...")

#wechsle-zu-kostuem(kostuem: "Kostüm2")
#naechstes-kostuem()
#wechsle-zu-buehnenbild(buehnenbild: "Hintergrund1")
#naechstes-buehnenbild()

#aendere-groesse(aenderung: 10)
#setze-groesse(groesse: 100)
#aendere-effekt("Farbe", aenderung: 25)
#setze-effekt("Farbe", wert: 0)
#schalte-grafikeffekte-aus()
#zeige-dich()
#verstecke-dich()
#gehe-zu-ebene("vorderster")
#gehe-ebenen(anzahl: 1, richtung: "vor")
#kostuem-eigenschaft("Nummer")
#buehnenbild-eigenschaft("Nummer")
#groesse()
```]

=== Klang (Pink/Magenta)

#sourcecode[```typ
#spiele-klang-ganz("Meow")
#spiele-klang("Meow")
#stoppe-alle-klaenge()
#aendere-klangeffekt("Höhe", aenderung: 10)
#setze-klangeffekt("Höhe", wert: 100)
#schalte-klangeffekte-aus()
#aendere-lautstaerke(aenderung: -10)
#setze-lautstaerke(lautstaerke: 100)
#lautstaerke()
```]

=== Ereignisse (Gelb)

#sourcecode[```typ
#wenn-gruene-flagge-geklickt([])
#wenn-taste-gedrueckt("Leertaste", [])
#wenn-diese-figur-angeklickt([])
#wenn-buehnenbildwechsel("Bühnenbild1", [])
#wenn-ueberschreitet("Lautstärke", "10", [])
#wenn-nachricht-empfangen("Nachricht1", [])

#sende-nachricht("Nachricht1")
#sende-nachricht-und-warte("Nachricht1")
```]

=== Steuerung (Orange)

#sourcecode[```typ
#warte(dauer: 1)
#wiederhole(anzahl: 10, [])
#wiederhole-fortlaufend([])
#falls-sonst([], [], [])
#falls([], [])
#warte-bis([])
#wiederhole-bis([], [])
#stoppe("alles")
#wenn-ich-als-klon-entstehe([])
#erzeuge-klon("mir selbst")
#loesche-diesen-klon()
```]

=== Fühlen (Hellblau)

#sourcecode[```typ
#wird-beruehrt("Mauszeiger")
#wird-farbe-beruehrt(rgb("#36B7CE"))
#farbe-beruehrt-farbe(rgb("#83FEF3"), rgb("#CB6622"))
#entfernung-von("Mauszeiger")
#frage("Wie heißt du?")
#antwort()
#taste-gedrueckt("Leertaste")
#maustaste-gedrueckt()
#maus-x()
#maus-y()
#setze-ziehbarkeit("ziehbar")
#lautstaerke-fuehlen()
#stoppuhr()
#setze-stoppuhr-zurueck()
#eigenschaft-von("Bühnenbildnummer", "Bühne")
#aktuell("Jahr")
#tage-seit-2000()
#benutzername()
```]

=== Operatoren (Grün)

#sourcecode[```typ
#addiere(5, 3)
#subtrahiere(10, 4)
#multipliziere(3, 7)
#dividiere(20, 4)
#zufallszahl(von: 1, bis: 10)
#groesser-als(50, 25)
#kleiner-als(10, 50)
#gleich(42, 42)
#und(`bedingung>`, `bedingung>`)
#oder(`bedingung>`, `bedingung>`)
#nicht(`bedingung>`)
#verbinde("Hallo ", "Welt")
#zeichen-von(1, "Apfel")
#laenge-von("Apfel")
#enthaelt("Apfel", "a")
#modulo(12, 5)
#runde(3.7)
#mathematik("Betrag", -5)
```]

=== Variablen (Orange)

#sourcecode[```typ
#setze-variable("Punkte", 0)
#aendere-variable("Punkte", 1)
#zeige-variable("Punkte")
#verstecke-variable("Punkte")
```]

=== Listen (Rot)

#sourcecode[```typ
#fuege-zu-liste-hinzu("Ding", "Test")
#entferne-aus-liste(1, "Test")
#entferne-alles-aus-liste("Test")
#fuege-bei-ein("Ding", 1, "Test")
#ersetze-element(1, "Test", "Neues Ding")
#element-von-liste(1, "Test")
#nummer-von-element("Ding", "Test")
#laenge-von-liste("Test")
#liste-enthaelt("Test", "Ding")
#zeige-liste("Test")
#verstecke-liste("Test")
```]

=== Eigene Blöcke (Pink)

#sourcecode[```typ
#definiere([mein Block], ([parameter1], [parameter2]))
```]
#pagebreak(weak: true)
== Verschachtelte Strukturen

Blöcke können verschachtelt werden, z.B. in Wiederholungen und Bedingungen:

#set-blockst(theme: "normal", scale: 70%)

#example[```typ
#blockst[
  #import scratch.de: *

  #wenn-gruene-flagge-geklickt([
  #wiederhole(anzahl: 10, [
    #gehe-zu-position("Zufallsposition")
    #falls(wird-beruehrt("Wand"), [
      #drehe-rechts(grad: 180)
    ])
  ])
])

]
```]

== Komplettes Programm

#example[```typ

#blockst[
  #import scratch.de: *

  #wenn-gruene-flagge-geklickt([
    #setze-variable("Punkte", 0)
    #wiederhole-fortlaufend([
      #falls(taste-gedrueckt("Leertaste"), [
        #aendere-variable("Punkte", 1)
        #sage-fuer-sekunden("Punkt!", sekunden: 0.5)
      ])
      #warte(dauer: 0.1)
    ])
  ])
]
```]
#pagebreak(weak: true)
= Funktionsreferenz

== Kryptographie

#command("caesar", arg("key"), arg(keyword: "none"), arg(advanced: false))
#command("vigenere", arg("keyword"), arg(advanced: false))
#command("rot13", arg("text"))
#command("atbash", arg(advanced: false))

== Kodierung

#command("dec2bin", arg("number"))
#command("bin2dec", arg("binary"))
#command("dec2hex", arg("number"))
#command("hex2dec", arg("hex"))
#command("ascii-table", arg(ranges: (("a", "z"),)), arg(height: 5), arg(variants: ("char", "dec")), arg(colored: true))
#command("text-to-blocks", arg("text"))

== Häufigkeitsanalyse

#command("häufigkeitsanalyse", arg("text"))

#pagebreak(weak: true)

== Scratch-Blöcke

=== Konfiguration

#command("set-scratch", arg(theme: "normal"), arg(stroke-width: 1pt))

=== Bewegung

#command("gehe", arg(schritte: 10))
#command("drehe-rechts", arg(grad: 15))
#command("drehe-links", arg(grad: 15))
#command("gehe-zu-position", arg("zu"))
#command("gehe-zu", arg(x: 0), arg(y: 0))
#command("gleite-zu-position", arg(sekunden: 1), arg("zu"))
#command("gleite-zu", arg(sekunden: 1), arg(x: 0), arg(y: 0))
#command("setze-richtung", arg(grad: 90))
#command("drehe-zu", arg("zu"))
#command("aendere-x", arg(aenderung: 10))
#command("setze-x", arg(x: 0))
#command("aendere-y", arg(aenderung: 10))
#command("setze-y", arg(y: 0))
#command("pralle-vom-rand-ab", ..args())
#command("setze-drehtyp", arg(typ: "links-rechts"))
#command("x-position", ..args())
#command("y-position", ..args())
#command("richtung", ..args())

=== Aussehen

#command("sage-fuer-sekunden", arg("nachricht"), arg(sekunden: 2))
#command("sage", arg("nachricht"))
#command("denke-fuer-sekunden", arg("nachricht"), arg(sekunden: 2))
#command("denke", arg("nachricht"))
#command("wechsle-zu-kostuem", arg(kostuem: "Kostüm2"))
#command("naechstes-kostuem", ..args())
#command("wechsle-zu-buehnenbild", arg(buehnenbild: "Hintergrund1"))
#command("naechstes-buehnenbild", ..args())
#command("aendere-groesse", arg(aenderung: 10))
#command("setze-groesse", arg(groesse: 100))
#command("aendere-effekt", arg("effekt"), arg(aenderung: 25))
#command("setze-effekt", arg("effekt"), arg(wert: 0))
#command("schalte-grafikeffekte-aus", ..args())
#command("zeige-dich", ..args())
#command("verstecke-dich", ..args())
#command("gehe-zu-ebene", arg("ebene"))
#command("gehe-ebenen", arg(anzahl: 1), arg("richtung"))
#command("kostuem-eigenschaft", arg("eigenschaft"))
#command("buehnenbild-eigenschaft", arg("eigenschaft"))
#command("groesse", ..args())

=== Klang

#command("spiele-klang-ganz", arg("klang"))
#command("spiele-klang", arg("klang"))
#command("stoppe-alle-klaenge", ..args())
#command("aendere-klangeffekt", arg("effekt"), arg(aenderung: 10))
#command("setze-klangeffekt", arg("effekt"), arg(wert: 100))
#command("schalte-klangeffekte-aus", ..args())
#command("aendere-lautstaerke", arg(aenderung: -10))
#command("setze-lautstaerke", arg(lautstaerke: 100))
#command("lautstaerke", ..args())

=== Ereignisse

#command("wenn-gruene-flagge-geklickt", arg("children"))
#command("wenn-taste-gedrueckt", arg("taste"), arg("children"))
#command("wenn-diese-figur-angeklickt", arg("children"))
#command("wenn-buehnenbildwechsel", arg("szene"), arg("children"))
#command("wenn-ueberschreitet", arg("element"), arg("wert"), arg("children"))
#command("wenn-nachricht-empfangen", arg("nachricht"), arg("children"))
#command("sende-nachricht", arg("nachricht"))
#command("sende-nachricht-und-warte", arg("nachricht"))
#command("wenn-ich-als-klon-entstehe", arg("children"))
#command("erzeuge-klon", arg("klon"))

=== Steuerung

#command("warte", arg(dauer: 1))
#command("wiederhole", arg(anzahl: 10), arg("body"))
#command("wiederhole-fortlaufend", arg("body"))
#command("wiederhole-bis", arg("bedingung"), arg("body"))
#command("falls", arg("bedingung"), arg("body"))
#command("falls-sonst", arg("bedingung"), arg("dann"), arg("sonst"))
#command("warte-bis", arg("bedingung"))
#command("stoppe", arg("option"))
#command("loesche-diesen-klon", ..args())

=== Fühlen

#command("wird-beruehrt", arg("objekt"))
#command("wird-farbe-beruehrt", arg("farbe"))
#command("farbe-beruehrt-farbe", arg("farbe1"), arg("farbe2"))
#command("taste-gedrueckt", arg("taste"))
#command("maustaste-gedrueckt", ..args())
#command("frage", arg("frage"))
#command("antwort", ..args())
#command("entfernung-von", arg("objekt"))
#command("maus-x", ..args())
#command("maus-y", ..args())
#command("setze-ziehbarkeit", arg("modus"))
#command("lautstaerke-fuehlen", ..args())
#command("stoppuhr", ..args())
#command("setze-stoppuhr-zurueck", ..args())
#command("eigenschaft-von", arg("eigenschaft"), arg("objekt"))
#command("aktuell", arg("zeiteinheit"))
#command("tage-seit-2000", ..args())
#command("benutzername", ..args())

=== Operatoren

#command("addiere", arg("zahl1"), arg("zahl2"))
#command("subtrahiere", arg("zahl1"), arg("zahl2"))
#command("multipliziere", arg("zahl1"), arg("zahl2"))
#command("dividiere", arg("zahl1"), arg("zahl2"))
#command("modulo", arg("zahl1"), arg("zahl2"))
#command("zufallszahl", arg(von: 1), arg(bis: 10))
#command("groesser-als", arg("operand1"), arg("operand2"))
#command("kleiner-als", arg("operand1"), arg("operand2"))
#command("gleich", arg("operand1"), arg("operand2"))
#command("und", arg("operand1"), arg("operand2"))
#command("oder", arg("operand1"), arg("operand2"))
#command("nicht", arg("operand"))
#command("verbinde", arg("string1"), arg("string2"))
#command("zeichen-von", arg("position"), arg("text"))
#command("laenge-von", arg("text"))
#command("enthaelt", arg("text1"), arg("text2"))
#command("runde", arg("zahl"))
#command("mathematik", arg("operator"), arg("zahl"))

=== Variablen

#command("setze-variable", arg("variable"), arg("wert"))
#command("aendere-variable", arg("variable"), arg("wert"))
#command("zeige-variable", arg("variable"))
#command("verstecke-variable", arg("variable"))

=== Listen

#command("fuege-zu-liste-hinzu", arg("element"), arg("liste"))
#command("entferne-aus-liste", arg("index"), arg("liste"))
#command("entferne-alles-aus-liste", arg("liste"))
#command("fuege-bei-ein", arg("element"), arg("index"), arg("liste"))
#command("ersetze-element", arg("index"), arg("liste"), arg("element"))
#command("element-von-liste", arg("index"), arg("liste"))
#command("nummer-von-element", arg("element"), arg("liste"))
#command("laenge-von-liste", arg("liste"))
#command("liste-enthaelt", arg("liste"), arg("element"))
#command("zeige-liste", arg("liste"))
#command("verstecke-liste", arg("liste"))

=== Eigene Blöcke

#command("definiere", arg("label"), arg("..children"))
#command("eigener-block", arg("..body"))
#command("eigene-eingabe", arg("text"))
#command("parameter", arg("name"))

= Beispielsammlung

== Kryptoanalyse

#example[```typ
// Text verschlüsseln
#let geheim = caesar(key: 3)("HALLO WELT")

// Häufigkeitsanalyse durchführen
#let analyse = häufigkeitsanalyse(geheim)

#analyse.diagramm

// Vergleich mit deutscher Sprache
Die häufigsten Buchstaben im Deutschen: E, N, I, S, R, A, T
```]

== Scratch-Tutorial

#example[```typ
#set-scratch(theme: "normal")

// Programm: Figur folgt Mauszeiger
#wenn-gruene-flagge-geklickt([
  #wiederhole-fortlaufend([
    #gehe-zu-position("Mauszeiger")
    #warte(dauer: 0.1)
  ])
])
```]

== Zahlensystem-Konverter

#example[```typ
#let zahl = 42

#table(
  columns: 2,
  [*System*], [*Wert*],
  [Dezimal], [#zahl],
  [Binär], [#dec2bin(zahl)],
  [Hexadezimal], [#dec2hex(zahl)],
)
```]

== Komplettes Scratch-Spiel

#example[```typ
#set-scratch(theme: "normal")

// Initialisierung und Spiel-Logik
#scale(60%, reflow: true)[
#wenn-gruene-flagge-geklickt([
  #setze-variable("Punkte", 0)
  #setze-variable("Level", 1)
  #gehe-zu-position("Zufallsposition")
])

#wenn-diese-figur-angeklickt([
  #aendere-variable("Punkte", 1)
  #spiele-klang("Pop")
  #falls-sonst(
    groesser-als("Punkte", 10),
    [
      #aendere-variable("Level", 1)
      #setze-variable("Punkte", 0)
      #sage-fuer-sekunden("Level Up!", sekunden: 2)
    ],
    []
  )
  #gehe-zu-position("Zufallsposition")
])]
```]

= Zusammenfassung

Das #package[informatik] Paket bietet:

- ✓ Kryptographie: Caesar, Vigenère, ROT13, Atbash
- ✓ Kodierung: Binär, Hexadezimal, ASCII
- ✓ Häufigkeitsanalyse mit Diagrammen
- ✓ Vollständiges Scratch-Block-System mit allen Kategorien
- ✓ Theme-Unterstützung (Normal, High-Contrast)
- ✓ Verschachtelte Block-Strukturen
- ✓ Integration mit Aufgaben- und Arbeitsblatt-Paketen

Das Paket ist ideal für Informatik-Lehrkräfte, die Kryptographie, Zahlensysteme und visuelle Programmierung unterrichten möchten.
