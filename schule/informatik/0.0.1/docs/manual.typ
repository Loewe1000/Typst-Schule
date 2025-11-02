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
#gehe-schritt(schritt: 10)
#drehe-dich-um(grad: 15)
#drehe-dich-um(richtung: "links", grad: 15)
#gehe(zu: "Mauszeiger")
#gehe-zu(x: 0, y: 0)
#gleite-in(sek: 1, zu: "Mauszeiger")
#gleite-in-zu(sek: 1, x: 0, y: 0)
#setze-Richtung-auf(grad: 90)
#drehe-dich(zu: "Mauszeiger")

#ändere-x-um(schritt: 10)
#setze-x-auf(x: 0)
#ändere-y-um(schritt: 10)
#setze-y-auf(y: 0)

#pralle-vom-rand-ab()
#setze-drehtyp-auf(typ: "links-rechts")
#x-position()
#y-position()
#richtung()
```]

=== Aussehen (Lila)

#sourcecode[```typ
#sage(text: "Hallo!", sekunden: 2)
#sage(text: "Hallo!")
#denke(text: "Hmm...", sekunden: 2)
#denke(text: "Hmm...")

#wechsle-zu-kostüm(kostüm: "Kostüm2")
#wechsle-zum-nächsten-kostüm()
#wechsle-zu-bühnenbild(bild: "Hintergrund1")
#wechsle-zum-nächsten-bühnenbild()

#ändere-größe-um(wert: 10)
#setze-größe-auf(wert: 100)
#ändere-effekt(effekt: "Farbe", um: 25)
#setze-effekt(effekt: "Farbe", auf: 0)
#schalte-grafikeffekte-aus()
#zeige-dich()
#verstecke-dich()
#gehe-zu-ebene(ebene: "vorderster")
#gehe-ebenen-nach(vorne: true, schritte: 1)
#kostüm(eigenschaft: "Nummer")
#bühnenbild(eigenschaft: "Nummer")
#größe()
```]

=== Klang (Pink/Magenta)

#sourcecode[```typ
#spiele-klang(sound: "Meow")
#spiele-klang(sound: "Meow", ganz: false)
#stoppe-alle-klänge()
#ändere-klang-effekt(effekt: "Höhe", um: 10)
#setze-klang-effekt(effekt: "Höhe", auf: 100)
#schalte-klangeffekte-aus()
#ändere-lautstärke-um(wert: -10)
#setze-lautstärke-auf(wert: 100)
#lautstärke()
```]

=== Ereignisse (Gelb)

#sourcecode[```typ
#ereignis-grüne-flagge([])
#ereignis-taste("Leertaste", [])
#ereignis-figur-angeklickt([])
#ereignis-bühnenbild-wechselt-zu("Bühnenbild1", [])
#ereignis-über("Lautstärke", "10", [])
#ereignis-nachricht-empfangen("Nachricht1", [])

#sende-nachricht-an-alle("Nachricht1")
#sende-nachricht-an-alle("Nachricht1", wait: true)
```]

=== Steuerung (Orange)

#sourcecode[```typ
#warte(1)
#wiederhole(anzahl: 10, body: [])
#wiederhole-fortlaufend([])
#falls([], dann: [], sonst: [])
#falls([], dann: [])
#warte-bis([])
#wiederhole-bis([], body: [])
#stoppe("alles")
#wenn-ich-als-klon-entstehe([])
#erstelle-klon-von()
#lösche-diesen-klon()
```]

=== Fühlen (Hellblau)

#sourcecode[```typ
#wird-berührt(element: "Mauszeiger")
#wird-farbe-berührt(color: rgb("#36B7CE"))
#farbe-berührt(color: (rgb("#83FEF3"), rgb("#CB6622")))
#entfernung-von(objekt: "Mauszeiger")
#frage(text: "Wie heißt du?")
#antwort()
#taste-gedrückt(taste: "Leertaste")
#maustaste-gedrückt()
#maus-x-position()
#maus-y-position()
#setze-ziehbarkeit-auf(modus: "ziehbar")
#lautstärke-fühlen()
#stoppuhr()
#setze-stoppuhr-zurück()
#von(eigenschaft: "Bühnenbildnummer", objekt: "Bühne")
#zeit(einheit: "Jahr")
#tage-seit-2000()
#benutzername()
```]

=== Operatoren (Grün)

#sourcecode[```typ
#plus(arg1: 5, arg2: 3)
#minus(arg1: 10, arg2: 4)
#mal(arg1: 3, arg2: 7)
#geteilt(arg1: 20, arg2: 4)
#zufallszahl(von: 1, bis: 10)
#größer-als(50, 25)
#kleiner-als(10, 50)
#gleich(42, 42)
#und(`bedingung>`, `bedingung>`, nested: (true, true))
#oder(`bedingung>`, `bedingung>`, nested: (true, true))
#nicht(`bedingung>`, nested: true)
#verbinde("Hallo ", "Welt")
#zeichen(position: 1, von: "Apfel")
#länge-von(text: "Apfel")
#enthält(text: "Apfel", zeichen: "a")
#modulo(12, 5)
#gerundet(3.7)
#betrag-von(operation: "Betrag", zahl: -5)
```]

=== Variablen (Orange)

#sourcecode[```typ
#setze-variable-auf(name: "Punkte", wert: 0)
#ändere-variable-um(name: "Punkte", wert: 1)
#zeige-variable(name: "Punkte")
#verstecke-variable(name: "Punkte")
#variable("Punkte")
```]

=== Listen (Rot)

#sourcecode[```typ
#füge-zu-hinzu(wert: "Ding", liste: "Test")
#lösche-aus(index: 1, liste: "Test")
#lösche-alles-aus(liste: "Test")
#füge-bei-in-ein(wert: "Ding", index: 1, liste: "Test")
#ersetze-element-von-durch(index: 1, liste: "Test", wert: "Neues Ding")
#element-von(index: 1, liste: "Test")
#nummer-von-in(wert: "Ding", liste: "Test")
#länge-von-liste("Test")
#liste-enthält(liste: "Test", wert: "Ding")
#zeige-liste(liste: "Test")
#verstecke-liste(liste: "Test")
```]

=== Eigene Blöcke (Pink)

#sourcecode[```typ
#definiere([mein Block], ([parameter1], [parameter2]))
```]
#pagebreak(weak: true)
== Verschachtelte Strukturen

Blöcke können verschachtelt werden, z.B. in Wiederholungen und Bedingungen:

#example[```typ
#set-scratch(theme: "normal")

#ereignis-grüne-flagge([
  #wiederhole(anzahl: 10, body: [
    #gehe(zu: "Zufallsposition")
    #falls(wird-berührt(element: "Wand", nested: true), dann: [
      #drehe-dich-um(grad: 180)
    ])
  ])
])
```]

== Komplettes Programm

#example[```typ
#set-scratch(theme: "normal")

#scale(75%, reflow: true)[
  #ereignis-grüne-flagge([
    #setze-variable-auf(name: [Punkte], wert:0)
    #wiederhole-fortlaufend([
      #falls(taste-gedrückt(taste: "Leertaste"), dann: [
        #ändere-variable-um(name: [Punkte], wert: 1)
        #sage(text: [Punkt!], sekunden: 0.5)
      ])
      #warte(0.1)
    ])
  ])
]
```]
#pagebreak(weak: true)
= Funktionsreferenz

== Kryptographie

#command("caesar", arg("key"), arg(keyword: "none"), arg(advanced: false))[
  Caesar-Verschlüsselung mit Verschiebung oder Schlüsselwort-Alphabet.

  #argument("key", types: ("integer", none), default: none)[
    Verschiebung im Alphabet (1-25). Bei `keyword` wird dieser Parameter ignoriert.
  ]

  #argument("keyword", types: ("string", none), default: none)[
    Schlüsselwort für Alphabet-Substitution. Erstellt ein modifiziertes Alphabet beginnend mit dem Schlüsselwort (ohne Duplikate), gefolgt von den restlichen Buchstaben.
  ]

  #argument("advanced", types: "boolean", default: false)[
    - `false`: Gibt Verschlüsselungsfunktion zurück (nur encode)
    - `true`: Gibt Objekt mit `.encode()` und `.decode()` zurück
  ]
]

#command("vigenere", arg("keyword"), arg(advanced: false))[
  Vigenère-Verschlüsselung mit polyalphabetischer Substitution.

  #argument("keyword", types: "string")[
    Schlüsselwort für die Verschlüsselung.
  ]

  #argument("advanced", types: "boolean", default: false)[
    - `false`: Gibt Verschlüsselungsfunktion zurück
    - `true`: Gibt Objekt mit `.encode()` und `.decode()` zurück
  ]
]
#pagebreak(weak: true)
#command("rot13", arg("text"))[
  ROT13-Verschlüsselung (Caesar mit Verschiebung 13). Selbst-invers: `rot13(rot13(x)) == x`.

  #argument("text", types: "string")[
    Zu verschlüsselnder/entschlüsselnder Text.
  ]
]

#command("atbash", arg(advanced: false))[
  Atbash-Verschlüsselung (Alphabet-Spiegelung).

  #argument("advanced", types: "boolean", default: false)[
    - `false`: Gibt Verschlüsselungsfunktion zurück
    - `true`: Gibt Objekt mit `.encode()` und `.decode()` zurück
  ]
]

== Kodierung

#command("dec2bin", arg("number"))[
  Konvertiert Dezimalzahl zu Binär.

  #argument("number", types: "integer")[
    Dezimalzahl (nicht-negativ).
  ]
]

#command("bin2dec", arg("binary"))[
  Konvertiert Binärzahl zu Dezimal.

  #argument("binary", types: "string")[
    Binärzahl als String (nur 0 und 1).
  ]
]

#command("dec2hex", arg("number"))[
  Konvertiert Dezimalzahl zu Hexadezimal.

  #argument("number", types: "integer")[
    Dezimalzahl (nicht-negativ).
  ]
]

#command("hex2dec", arg("hex"))[
  Konvertiert Hexadezimalzahl zu Dezimal.

  #argument("hex", types: "string")[
    Hexadezimalzahl als String (0-9, A-F).
  ]
]

#command("ascii-table", arg(ranges: (("a", "z"),)), arg(height: 5), arg(variants: ("char", "dec")), arg(colored: true))[
  Erstellt eine ASCII-Tabelle mit konfigurierbaren Zeichenbereichen und Darstellungsoptionen.

  #argument("ranges", types: "array", default: (("a", "z"),))[
    Array von Zeichenbereichen. Jeder Eintrag kann sein:
    - Ein einzelnes Zeichen als String: `"A"`
    - Ein Tupel `(start, end)` für einen Bereich: `("a", "z")`, `("0", "9")`
    
    Beispiele:
    - `(("a", "z"),)` -- Kleinbuchstaben a-z
    - `(("A", "Z"), ("a", "z"))` -- Groß- und Kleinbuchstaben
    - `(("0", "9"), ("A", "F"))` -- Hexadezimalziffern
  ]

  #argument("height", types: "integer", default: 5)[
    Anzahl der Zeilen in der Tabelle. Die Spaltenanzahl wird automatisch berechnet.
  ]

  #argument("variants", types: "array", default: ("char", "dec"))[
    Array von Darstellungsvarianten. Verfügbare Werte:
    - `"char"`: Das Zeichen selbst
    - `"dec"`: Dezimalwert (ASCII-Code)
    - `"hex"`: Hexadezimalwert
    - `"bin"`: Binärwert
    
    Beispiel: `("char", "dec", "hex", "bin")` zeigt alle vier Varianten.
  ]

  #argument("colored", types: "boolean", default: true)[
    - `true`: Farbige Header (Blau, Rot, Grün, Orange, etc.)
    - `false`: Graustufige Header
  ]
]

#command("text-to-blocks", arg("text"))[
  Konvertiert Text in formatierte Blöcke für visuelle Darstellung.

  #argument("text", types: "string")[
    Text, der in Blöcke aufgeteilt werden soll.
  ]
]

== Häufigkeitsanalyse

#command("häufigkeitsanalyse", arg("text"))[
  Analysiert die Häufigkeit von Buchstaben in einem Text.

  #argument("text", types: "string")[
    Zu analysierender Text. Nur Buchstaben werden gezählt (Groß-/Kleinschreibung ignoriert).
  ]

  Rückgabe: Dictionary mit:
  - `absolut`: Dictionary mit absoluten Häufigkeiten (z.B. `(E: 5, A: 3)`)
  - `relativ`: Dictionary mit relativen Häufigkeiten (z.B. `(E: 25%, A: 15%)`)
  - `diagramm`: Balkendiagramm als CeTZ-Content
  - `data`: Array mit `(buchstabe, häufigkeit)` Paaren für eigene Plots
]

== Scratch-Blöcke

=== Konfiguration

#command("set-scratch", arg(theme: "normal"), arg(stroke-width: 1pt))[
  Konfiguriert das globale Theme für Scratch-Blöcke.

  #argument("theme", types: "string", default: "normal")[
    `"normal"` oder `"high-contrast"`
  ]

  #argument("stroke-width", types: "length", default: 1pt)[
    Dicke der Block-Umrandungen.
  ]
]

=== Bewegung

#command("gehe-schritt", arg(schritt: 10))[Block: Gehe _schritt_ Schritte vorwärts.]
#command("drehe-dich-um", arg(richtung: "rechts"), arg(grad: 15))[Block: Drehe dich um _grad_ Grad in _richtung_ ("rechts" oder "links").]
#command("gehe", arg(zu: "Zufallsposition"))[Block: Gehe zu Position _zu_ (z.B. "Mauszeiger", "Zufallsposition").]
#command("gehe-zu", arg(x: 0), arg(y: 0))[Block: Gehe zu Position x: _x_, y: _y_.]
#command("gleite-in", arg(sek: 1), arg(zu: "Zufallsposition"))[Block: Gleite in _sek_ Sekunden zu _zu_.]
#pagebreak(weak: true)
#command("gleite-in-zu", arg(sek: 1), arg(x: 0), arg(y: 0))[Block: Gleite in _sek_ Sekunden zu x: _x_, y: _y_.]
#command("setze-Richtung-auf", arg(grad: 90))[Block: Setze Richtung auf _grad_ Grad.]
#command("drehe-dich", arg(zu: "Mauszeiger"))[Block: Drehe dich zu _zu_.]
#command("ändere-x-um", arg(schritt: 10))[Block: Ändere x um _schritt_.]
#command("setze-x-auf", arg(x: 0))[Block: Setze x auf _x_.]
#command("ändere-y-um", arg(schritt: 10))[Block: Ändere y um _schritt_.]
#command("setze-y-auf", arg(y: 0))[Block: Setze y auf _y_.]
#command("pralle-vom-rand-ab", ..args())[Block: Pralle vom Rand ab.]
#command("setze-drehtyp-auf", arg(typ: "links-rechts"))[Block: Setze Drehtyp auf _typ_.]
#command("x-position", ..args())[Reporter: x-Position der Figur.]
#command("y-position", ..args())[Reporter: y-Position der Figur.]
#command("richtung", ..args())[Reporter: Richtung der Figur in Grad.]

=== Aussehen

#command("sage", arg(text: "Hallo!"), arg(sekunden: none))[Block: Sage _text_ (optional für _sekunden_ Sekunden).]
#command("denke", arg(text: "Hmm..."), arg(sekunden: none))[Block: Denke _text_ (optional für _sekunden_ Sekunden).]
#command("wechsle-zu-kostüm", arg(kostüm: "Kostüm2"))[Block: Wechsle zu Kostüm _kostüm_.]
#command("wechsle-zum-nächsten-kostüm", ..args())[Block: Wechsle zum nächsten Kostüm.]
#command("wechsle-zu-bühnenbild", arg(bild: "Hintergrund1"))[Block: Wechsle zu Bühnenbild _bild_.]
#pagebreak(weak: true)
#command("wechsle-zum-nächsten-bühnenbild", ..args())[Block: Wechsle zum nächsten Bühnenbild.]
#command("ändere-größe-um", arg(wert: 10))[Block: Ändere Größe um _wert_.]
#command("setze-größe-auf", arg(wert: 100))[Block: Setze Größe auf _wert_ %.]
#command("ändere-effekt", arg(effekt: "Farbe"), arg(um: 25))[Block: Ändere Effekt _effekt_ um _um_.]
#command("setze-effekt", arg(effekt: "Farbe"), arg(auf: 0))[Block: Setze Effekt _effekt_ auf _auf_.]
#command("schalte-grafikeffekte-aus", ..args())[Block: Schalte Grafikeffekte aus.]
#command("zeige-dich", ..args())[Block: Zeige dich.]
#command("verstecke-dich", ..args())[Block: Verstecke dich.]
#command("gehe-zu-ebene", arg(ebene: "vorderster"))[Block: Gehe zu Ebene _ebene_.]
#command("gehe-ebenen-nach", arg(vorne: true), arg(schritte: 1))[Block: Gehe _schritte_ Ebenen nach vorne/hinten.]
#command("kostüm", arg(eigenschaft: "Nummer"))[Reporter: Kostüm-Eigenschaft _eigenschaft_.]
#command("bühnenbild", arg(eigenschaft: "Nummer"))[Reporter: Bühnenbild-Eigenschaft _eigenschaft_.]
#command("größe", ..args())[Reporter: Größe der Figur in %.]

=== Klang

#command("spiele-klang", arg(sound: "Meow"), arg(ganz: true))[Block: Spiele Klang _sound_ (ganz oder bis fertig je nach _ganz_).]
#command("stoppe-alle-klänge", ..args())[Block: Stoppe alle Klänge.]
#command("ändere-klang-effekt", arg(effekt: "Höhe"), arg(um: 10))[Block: Ändere Klangeffekt _effekt_ um _um_.]
#command("setze-klang-effekt", arg(effekt: "Höhe"), arg(auf: 100))[Block: Setze Klangeffekt _effekt_ auf _auf_.]
#pagebreak(weak: true)
#command("schalte-klangeffekte-aus", ..args())[Block: Schalte Klangeffekte aus.]
#command("ändere-lautstärke-um", arg(wert: -10))[Block: Ändere Lautstärke um _wert_.]
#command("setze-lautstärke-auf", arg(wert: 100))[Block: Setze Lautstärke auf _wert_ %.]
#command("lautstärke", ..args())[Reporter: Aktuelle Lautstärke.]

=== Ereignisse

#command("ereignis-grüne-flagge", arg("children"))[Event-Block: Wenn grüne Flagge angeklickt. _children_ enthält die auszuführenden Blöcke.]
#command("ereignis-taste", arg("taste"), arg("children"))[Event-Block: Wenn Taste _taste_ gedrückt wird.]
#command("ereignis-figur-angeklickt", arg("children"))[Event-Block: Wenn diese Figur angeklickt wird.]
#command("ereignis-bühnenbild-wechselt-zu", arg("taste"), arg("children"))[Event-Block: Wenn Bühnenbild zu _taste_ wechselt.]
#command("ereignis-über", arg("element"), arg("wert"), arg("children"))[Event-Block: Wenn _element_ über _wert_ liegt.]
#command("ereignis-nachricht-empfangen", arg("nachricht"), arg("children"))[Event-Block: Wenn Nachricht _nachricht_ empfangen wird.]
#command("sende-nachricht-an-alle", arg("nachricht"), arg(wait: false))[Block: Sende Nachricht _nachricht_ an alle (warte optional).]
#command("wenn-ich-als-klon-entstehe", arg("children"))[Event-Block: Wenn ich als Klon entstehe.]
#command("erstelle-klon-von", arg(element: "mir selbst"))[Block: Erstelle Klon von _element_.]

=== Steuerung

#command("warte", arg("sekunde"))[Block: Warte _sekunde_ Sekunden.]
#command("wiederhole", arg(anzahl: 10), arg(body: none))[Block: Wiederhole _anzahl_ mal, führe _body_ aus.]
#command("wiederhole-fortlaufend", arg("body"))[Block: Wiederhole _body_ unendlich.]
#pagebreak(weak: true)
#command("wiederhole-bis", arg("bdg"), arg(body: none))[Block: Wiederhole _body_ bis Bedingung _bdg_ wahr ist.]
#command("falls", arg("bdg"), arg(dann: none), arg(sonst: none))[Block: Falls Bedingung _bdg_, dann _dann_, sonst _sonst_.]
#command("warte-bis", arg("bdg"))[Block: Warte bis Bedingung _bdg_ wahr ist.]
#command("stoppe", arg("element"))[Block: Stoppe _element_ ("alles", "dieses Skript", etc.).]
#command("lösche-diesen-klon", ..args())[Block: Lösche diesen Klon.]

=== Fühlen

#command("wird-berührt", arg(element: "Mauszeiger"), arg(nested: false))[Sensor-Block: Berühre _element_? _nested_ für Verwendung in Bedingungen.]
#command("wird-farbe-berührt", arg(color: rgb("#36B7CE")), arg(nested: false))[Sensor-Block: Berühre Farbe _color_?]
#command("farbe-berührt", arg(color: (rgb("#83FEF3"), rgb("#CB6622"))), arg(nested: false))[Sensor-Block: Farbe _color.0_ berührt Farbe _color.1_?]
#command("taste-gedrückt", arg(taste: "Leertaste"), arg(nested: false))[Sensor-Block: Taste _taste_ gedrückt?]
#command("maustaste-gedrückt", arg(nested: false))[Sensor-Block: Maustaste gedrückt?]
#command("frage", arg(text: "Wie heißt du?"))[Block: Frage _text_ und warte auf Antwort.]
#command("antwort", ..args())[Reporter: Antwort auf letzte Frage.]
#command("entfernung-von", arg(objekt: "Mauszeiger"))[Reporter: Entfernung von _objekt_.]
#command("maus-x-position", ..args())[Reporter: x-Position des Mauszeigers.]
#command("maus-y-position", ..args())[Reporter: y-Position des Mauszeigers.]
#command("setze-ziehbarkeit-auf", arg(modus: "ziehbar"))[Block: Setze Ziehbarkeit auf _modus_.]
#command("lautstärke-fühlen", ..args())[Reporter: Aktuelle Lautstärke (Mikrofon).]
#pagebreak(weak: true)
#command("stoppuhr", ..args())[Reporter: Stoppuhr-Wert.]
#command("setze-stoppuhr-zurück", ..args())[Block: Setze Stoppuhr zurück.]
#command("von", arg(eigenschaft: "Bühnenbildnummer"), arg(objekt: "Bühne"))[Reporter: _eigenschaft_ von _objekt_.]
#command("zeit", arg(einheit: "Jahr"))[Reporter: Aktuelle Zeit in _einheit_.]
#command("tage-seit-2000", ..args())[Reporter: Tage seit 1.1.2000.]
#command("benutzername", ..args())[Reporter: Scratch-Benutzername.]

=== Operatoren

#command("plus", arg(arg1: "  "), arg(arg2: "  "))[Operator: _arg1_ + _arg2_.]
#command("minus", arg(arg1: "  "), arg(arg2: "  "))[Operator: _arg1_ - _arg2_.]
#command("mal", arg(arg1: "  "), arg(arg2: "  "))[Operator: _arg1_ × _arg2_.]
#command("geteilt", arg(arg1: "  "), arg(arg2: "  "))[Operator: _arg1_ ÷ _arg2_.]
#command("modulo", arg("arg1"), arg("arg2"))[Operator: Rest von _arg1_ ÷ _arg2_.]
#command("zufallszahl", arg(von: 1), arg(bis: 10))[Operator: Zufallszahl von _von_ bis _bis_.]
#command("größer-als", arg("arg1"), arg("arg2"), arg(nested: false))[Operator: _arg1_ > _arg2_.]
#command("kleiner-als", arg("arg1"), arg("arg2"), arg(nested: false))[Operator: _arg1_ < _arg2_.]
#command("gleich", arg("arg1"), arg("arg2"), arg(nested: false))[Operator: _arg1_ = _arg2_.]
#command("und", arg("arg1"), arg("arg2"), arg(nested: (false, false)))[Operator: _arg1_ und _arg2_. _nested_ ist Tupel für beide Argumente.]
#command("oder", arg("arg1"), arg("arg2"), arg(nested: (false, false)))[Operator: _arg1_ oder _arg2_. _nested_ ist Tupel für beide Argumente.]
#pagebreak(weak: true)
#command("nicht", arg("arg1"), arg(nested: false))[Operator: nicht _arg1_.]
#command("verbinde", arg("text1"), arg("text2"))[Operator: Verbinde _text1_ und _text2_.]
#command("zeichen", arg(position: 1), arg(von: "Apfel"))[Operator: Zeichen _position_ von _von_.]
#command("länge-von", arg(text: "Apfel"))[Operator: Länge von _text_.]
#command("enthält", arg(text: "Apfel"), arg(zeichen: "a"), arg(nested: false))[Operator: _text_ enthält _zeichen_?]
#command("gerundet", arg("zahl"))[Operator: Runde _zahl_.]
#command("betrag-von", arg(operation: "Betrag"), arg("zahl"))[Operator: _operation_ von _zahl_ (Betrag, Wurzel, sin, cos, etc.).]

=== Variablen

#command("setze-variable-auf", arg(name: "my variable"), arg(wert: 0))[Block: Setze Variable _name_ auf _wert_.]
#command("ändere-variable-um", arg(name: "my variable"), arg(wert: 1))[Block: Ändere Variable _name_ um _wert_.]
#command("zeige-variable", arg(name: "my variable"))[Block: Zeige Variable _name_.]
#command("verstecke-variable", arg(name: "my variable"))[Block: Verstecke Variable _name_.]
#command("variable", arg("name"))[Reporter: Wert der Variable _name_.]

=== Listen

#command("füge-zu-hinzu", arg(wert: "Ding"), arg(liste: "Test"))[Block: Füge _wert_ zu Liste _liste_ hinzu.]
#command("lösche-aus", arg(index: 1), arg(liste: "Test"))[Block: Lösche Element _index_ aus Liste _liste_.]
#command("lösche-alles-aus", arg(liste: "Test"))[Block: Lösche alle Elemente aus Liste _liste_.]
#command("füge-bei-in-ein", arg(wert: "Ding"), arg(index: 1), arg(liste: "Test"))[Block: Füge _wert_ an Position _index_ in Liste _liste_ ein.]
#command("ersetze-element-von-durch", arg(index: 1), arg(liste: "Test"), arg(wert: "Ding"))[Block: Ersetze Element _index_ von Liste _liste_ durch _wert_.]
#command("element-von", arg(index: 1), arg(liste: "Test"))[Reporter: Element _index_ von Liste _liste_.]
#command("nummer-von-in", arg(wert: "Ding"), arg(liste: "Test"))[Reporter: Nummer von _wert_ in Liste _liste_.]
#command("länge-von-liste", arg("liste"))[Reporter: Länge von Liste _liste_.]
#command("liste-enthält", arg(liste: "Test"), arg(wert: "Ding"), arg(nested: false))[Reporter: Liste _liste_ enthält _wert_?]
#command("zeige-liste", arg(liste: "Test"))[Block: Zeige Liste _liste_.]
#command("verstecke-liste", arg(liste: "Test"))[Block: Verstecke Liste _liste_.]

=== Eigene Blöcke

#command("definiere", arg("label"), arg("..children"))[Block: Definiere eigenen Block mit Label _label_ und Parametern in _children_.]
#command("eigener-block", arg("..body"))[Erzeugt einen eigenen Anweisungsblock mit Text und Platzhaltern aus _body_.]
#command("eigene-eingabe", arg("text"))[Weißer Argument-Platzhalter für eigene Blöcke mit Text _text_.]
#command("parameter", arg("name"))[Parameter-Reporter (pink) für eigene Block-Parameter _name_.]

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
#ereignis-grüne-flagge([
  #wiederhole-fortlaufend([
    #gehe(zu: "Mauszeiger")
    #warte(0.1)
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
#ereignis-grüne-flagge([
  #setze-variable-auf(name: [Punkte], wert: 0)
  #setze-variable-auf(name: [Level], wert: 1)
  #gehe(zu: "Zufallsposition")
])

#ereignis-figur-angeklickt([
  #ändere-variable-um(name: [Punkte], wert: 1)
  #spiele-klang(sound: [Pop])
  #falls(
    größer-als(variable([Punkte]), 10),
    dann: [
      #ändere-variable-um(name: [Level], wert: 1)
      #setze-variable-auf(name: [Punkte], wert: 0)
      #sage(text: [Level Up!], sekunden: 2)
    ]
  )
  #gehe(zu: "Zufallsposition")
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
