#import "@schule/schuldocs:0.3.1": show-code, show-example, show-module, tip, warning
#import "../src/lib.typ" as informatik

// Jedes Beispiel wird aus seinem Quelltext gesetzt: Was hier steht, kompiliert.
#let names = dictionary(informatik)
#let example(source, ..args) = show-example(
  rendered: eval(source.text, mode: "markup", scope: names),
  source: source,
  width: 14cm,
  ..args,
)

= Über dieses Paket

Das `informatik`-Paket stellt Werkzeuge für den Informatikunterricht bereit:
klassische Chiffren, die Häufigkeitsanalyse, Umwandlungen zwischen
Zahlensystemen und eine ASCII-Tabelle.

Dieses Handbuch gliedert sich so:

+ *Schnellstart* -- der erste Aufruf
+ *Kryptographie* -- Caesar, Vigenère, ROT13, Atbash, Schlüsseltabelle
+ *Häufigkeitsanalyse* -- Buchstaben zählen, Diagramm setzen
+ *Zahlensysteme* -- Binär, Dezimal, Hexadezimal
+ *Tabellen und Textblöcke* -- ASCII-Tabelle, Fünferblöcke
+ *Scratch-Blöcke* -- kommen aus `blockst`
+ *Umstieg auf 0.5.0* -- alte und neue Namen
+ *Referenz* -- alle Funktionen mit ihren Parametern

= Schnellstart

#example(```typ
#import "@schule/informatik:0.5.0": caesar

Geheimtext: *#caesar("HALLO WELT", key: 3)*
```)

Alle Chiffren haben dieselbe Aufrufform: zuerst der Text, dann benannt der
Schlüssel.

Wer `arbeitsblatt` oder `klassenarbeit` ab 0.5.0 benutzt, bekommt die Funktionen
dieses Pakets von dort; nur `caesar-table` braucht die eigene Importzeile
`#import "@schule/informatik:0.5.0": caesar-table`.

= Kryptographie

== Caesar

`caesar(text, key: …)` verschlüsselt einen Text. Der Schlüssel ist eine
Verschiebung (Zahl) oder ein Schlüsselwort (Text); `inverse: true` entschlüsselt.

#example(```typ
Verschlüsselt: *#caesar("HALLO WELT", key: 3)* \
Entschlüsselt: *#caesar("KDOOR ZHOW", key: 3, inverse: true)*
```)

Groß- und Kleinschreibung bleiben erhalten; Ziffern, Leerzeichen und
Satzzeichen bleiben stehen.

=== Mit Schlüsselwort

Bei einem Schlüsselwort beginnt das Geheimtextalphabet mit dessen Buchstaben
(jeder nur einmal). Der Rest des Alphabets folgt ab dem letzten Buchstaben des
Schlüsselworts.

#example(```typ
*#caesar("HALLO WELT", key: "GEHEIM")*
```)

#warning[
  Ein Text als `key` ist immer ein Schlüsselwort. `key: "3"` ist deshalb ein
  Fehler; die Verschiebung um 3 heißt `key: 3`.
]

=== Chiffre mit festem Schlüssel

Soll derselbe Schlüssel mehrfach gelten, legt `.with` ihn fest:

#example(```typ
#let geheim = caesar.with(key: 7)
#let offen = caesar.with(key: 7, inverse: true)

*#geheim("HALLO WELT")* wird wieder zu *#offen(geheim("HALLO WELT"))*
```)

=== Schlüsseltabelle

`caesar-table(key: …)` setzt Klartextalphabet (KA) und Geheimtextalphabet (GA)
untereinander. Der Schlüssel hat dieselbe Form wie bei `caesar`.

#example(```typ
#set text(size: 9pt)
#caesar-table(key: 3)
#caesar-table(key: "INFORMATIK")
```)

== Vigenère

`vigenere(text, key: …)` verschiebt jeden Buchstaben um den zugehörigen
Buchstaben des Schlüsselworts. Vom Schlüsselwort zählen nur die Buchstaben A–Z.

#example(```typ
#let geheimtext = vigenere("HALLO WELT", key: "SCHLUESSEL")

Verschlüsselt: *#geheimtext* \
Entschlüsselt: *#vigenere(geheimtext, key: "SCHLUESSEL", inverse: true)*
```)

== ROT13

`rot13(text)` ist die Caesar-Chiffre mit der Verschiebung 13. Sie ist
selbstinvers: Zweimal angewendet ergibt sie wieder den Klartext. Die
Schlüsseltabelle dazu setzt `caesar-table(key: 13)`.

#example(```typ
Verschlüsselt: *#rot13("Hallo Welt")* \
Zurück: *#rot13(rot13("Hallo Welt"))*
```)

== Atbash

`atbash(text)` spiegelt das Alphabet (A↔Z, B↔Y, …) und ist ebenfalls
selbstinvers.

#example(```typ
Verschlüsselt: *#atbash("HALLO WELT")* \
Zurück: *#atbash(atbash("HALLO WELT"))*
```)

= Häufigkeitsanalyse

Der Baustein `haeufigkeitsanalyse(text)` zählt die Buchstaben A–Z eines Textes
(Groß- und Kleinbuchstaben zusammen) und liefert ein Dictionary mit den
Zählungen und einem fertigen Säulendiagramm.

#example(```typ
#let analysis = haeufigkeitsanalyse(
  "DIES IST EIN BEISPIELTEXT FUER DIE HAEUFIGKEITSANALYSE",
)
#analysis.chart
```)

Das Ergebnis hat diese Schlüssel:

#table(
  columns: (auto, auto, 1fr),
  [*Schlüssel*], [*Typ*], [*Bedeutung*],
  [`counts`], [dictionary], [absolute Häufigkeit je Buchstabe, `A` bis `Z`],
  [`frequencies`], [dictionary], [relative Häufigkeit je Buchstabe in Prozent, als Kommazahl von 0 bis 100],
  [`items`], [array], [die relativen Häufigkeiten als Paare `([Buchstabe], Prozentwert)`],
  [`chart`], [content], [das Säulendiagramm],
  [`text`], [str], [der übergebene Text],
)

Mit den Zählungen lässt sich weiterrechnen, hier die drei häufigsten Buchstaben:

#example(```typ
#let analysis = haeufigkeitsanalyse("Dies ist ein Geheimtext")
#let top = analysis.counts.pairs().sorted(key: pair => -pair.at(1)).slice(0, 3)

#top.map(pair => [#pair.at(0): #pair.at(1)-mal]).join[, ]
```)

= Zahlensysteme

Vier Umwandlungen nach dem Muster `<von>-to-<nach>`. Zahlen im Binär- und
Hexadezimalsystem sind Texte, Dezimalzahlen sind Zahlen.

#example(```typ
#table(
  columns: 2,
  [*Aufruf*], [*Ergebnis*],
  [`dec-to-bin(42)`], [#dec-to-bin(42)],
  [`bin-to-dec("101010")`], [#bin-to-dec("101010")],
  [`dec-to-hex(255)`], [#dec-to-hex(255)],
  [`hex-to-dec("FF")`], [#hex-to-dec("FF")],
)
```)

#tip[
  Ungültige Ziffern (`bin-to-dec("10x2")`, `hex-to-dec("zz")`) und negative
  Zahlen sind ein Fehler mit Abhilfe; sie werden nicht still übergangen. Wie
  bisher zählt von einer Kommazahl nur der ganzzahlige Anteil
  (`dec-to-bin(3.7)` ergibt `"11"`), und der leere Text ergibt bei
  `bin-to-dec` und `hex-to-dec` die Zahl 0.
]

= Tabellen und Textblöcke

== ASCII-Tabelle

`ascii-table` setzt eine Tabelle für einzelne Zeichen oder Zeichenbereiche.
`domains` nennt die Bereiche, `rows` die Zeilen je Spaltenblock, `fields` die
Spalten je Zeichen.

#example(```typ
#ascii-table(
  domains: (("A", "E"),),
  rows: 5,
  fields: ("character", "dec", "hex", "bin"),
)
```)

Ohne `domains` und `fields` erscheinen die Kleinbuchstaben mit Zeichen und
Dezimalwert:

#example(```typ
#ascii-table(rows: 7)
```)

#tip[
  Mögliche Spalten in `fields`: `"character"` (Zeichen), `"dec"` (Dezimal),
  `"hex"` (Hexadezimal), `"bin"` (Binär). Ein Bereich in `domains` ist ein
  einzelnes Zeichen (`"a"`) oder ein Paar `("a", "z")`. Mit `colored: false`
  sind die Spalten grau statt farbig hinterlegt.
]

#example(```typ
#ascii-table(
  domains: (("0", "9"), "+", "-"),
  rows: 4,
  fields: ("character", "bin"),
  colored: false,
)
```)

== Text in Blöcken

`text-to-blocks` schreibt die Buchstaben eines Textes in Blöcken fester Länge,
wie bei Geheimtexten üblich. Alles außer Buchstaben entfällt.

#example(```typ
Fünferblöcke: *#text-to-blocks("HALLO WELT HEUTE")* \
Dreierblöcke: *#text-to-blocks("HALLO WELT HEUTE", character-count: 3)*
```)

= Scratch-Blöcke

Bis 0.0.2 reichte dieses Paket die Namen `blockst`, `scratch`, `set-blockst`,
`blockst-run-options`, `set-scratch-run` und `scratch-run` aus dem Paket
`blockst` weiter. Ab 0.5.0 importiert das Dokument sie selbst:

#example(```typ
#import "@preview/blockst:0.1.0": blockst, scratch, set-blockst

#set-blockst(scale: 70%)
#blockst[
  #import scratch.de: *
  #wiederhole(anzahl: 3)[
    #gehe(schritte: 10)
    #drehe-rechts(grad: 15)
  ]
]
```)

Alles Weitere steht im Handbuch von `blockst`.

= Umstieg auf 0.5.0 <umstieg>

Mit 0.5.0 haben alle Pakete des Ökosystems einheitliche Namen bekommen. Alte
Namen brechen mit einer Meldung ab, die den neuen Namen nennt, zum Beispiel
#raw("informatik.bin2dec: `bin2dec` heißt jetzt `bin-to-dec`").

== Funktionen

#table(
  columns: (1fr, 1fr),
  [*alt*], [*neu*],
  [`bin2dec`], [`bin-to-dec`],
  [`dec2bin`], [`dec-to-bin`],
  [`hex2dec`], [`hex-to-dec`],
  [`dec2hex`], [`dec-to-hex`],
  [`häufigkeitsanalyse`], [`haeufigkeitsanalyse`],
  [`häufigkeitsanalyse-alt(t)`], [`haeufigkeitsanalyse(t).items`],
  [`häufigkeitsanalyse-alt(t, cetz: false)`], [`haeufigkeitsanalyse(t).counts`],
  [`häufigkeitsanalyse-alt(t, cetz: false, rel: true)`], [`haeufigkeitsanalyse(t).frequencies`],
  [`mono[…]`], [entfällt; `raw("…")` oder `text(font: "SF Mono")[…]` schreiben],
  [`blockst`, `scratch`, `set-blockst`, `blockst-run-options`, `set-scratch-run`, `scratch-run`], [werden nicht mehr weitergereicht; aus `@preview/blockst` importieren],
)

== Chiffren: eine Aufrufform

Die Chiffren liefern keine Funktion und kein Dictionary mehr, sondern direkt
den Text. Der Schalter `advanced` entfällt.

#table(
  columns: (1fr, 1fr),
  [*alt*], [*neu*],
  [`caesar(key: 3)("abc")`], [`caesar("abc", key: 3)`],
  [`caesar(key: 3)("abc", true)`], [`caesar("abc", key: 3, inverse: true)`],
  [`caesar(keyword: "K")("abc")`], [`caesar("abc", key: "K")`],
  [`caesar(key: "3")`], [`key: 3` (ein Text ist immer ein Schlüsselwort)],
  [`caesar(key: 3)()`], [`caesar-table(key: 3)`],
  [`#let c = caesar(key: 3)`], [`#let c = caesar.with(key: 3)`],
  [`vigenere("K")("abc")`], [`vigenere("abc", key: "K")`],
  [`vigenere("K")("abc", true)`], [`vigenere("abc", key: "K", inverse: true)`],
  [`#let v = vigenere("K")`], [`#let v = vigenere.with(key: "K")`],
  [`atbash()("abc")`], [`atbash("abc")`],
  [`rot13("abc", true)`], [`rot13("abc")`],
  [`rot13()`], [`caesar-table(key: 13)`],
  [`caesar(key: 3, advanced: true).encode`], [`caesar.with(key: 3)`],
  [`caesar(key: 3, advanced: true).decode`], [`caesar.with(key: 3, inverse: true)`],
  [`caesar(key: 3, advanced: true).table`], [`caesar-table(key: 3)`],
  [`caesar(key: 3, advanced: true).geheimtext-alphabet`], [`caesar("ABCDEFGHIJKLMNOPQRSTUVWXYZ", key: 3)`],
)

Die alten Formen beginnen mit einem Aufruf ohne Text. Das Paket meldet dafür
die neue Form, zum Beispiel
#raw("informatik.caesar: der Text fehlt – `caesar(\"abc\", key: 3)` schreiben; die Schlüsseltabelle setzt `caesar-table(key: 3)`, eine Chiffre mit festem Schlüssel `caesar.with(key: 3)`").
Stehen `keyword` und `key` zugleich im Aufruf, verlangt die Meldung, nur `key`
zu schreiben.

== Parameter, Werte und Ergebnis-Schlüssel

#table(
  columns: (auto, 1fr, 1fr),
  [*wo*], [*alt*], [*neu*],
  [Zahlensysteme], [`zahl`, `hex`, `num` (Positionsargument)], [`value` (Positionsargument, im Aufruf unverändert)],
  [`text-to-blocks`], [`block-size: 5`], [`character-count: 5`],
  [`ascii-table`], [`ranges:`], [`domains:`],
  [`ascii-table`], [`height:`], [`rows:`],
  [`ascii-table`], [`variants:`], [`fields:`],
  [`ascii-table`], [Wert `"char"`], [Wert `"character"`],
  [`haeufigkeitsanalyse`], [Ergebnis `.absolut`], [`.counts`],
  [`haeufigkeitsanalyse`], [Ergebnis `.relativ`], [`.frequencies`],
  [`haeufigkeitsanalyse`], [Ergebnis `.data`], [`.items`],
  [`haeufigkeitsanalyse`], [Ergebnis `.diagramm`], [`.chart`],
)

== Strenger als bisher

- Ungültige Ziffern und negative Zahlen in den Umwandlungen sind ein Fehler.
- Ein Schlüsselwort ohne Buchstaben ist bei `caesar` ein Fehler (wie schon bei `vigenere`).
- Unbekannte Spalten in `fields` und ungültige Bereiche in `domains` sind ein
  Fehler; früher erschien `?` oder der Bereich fehlte still. Das gilt auch für
  einen rückwärts geschriebenen Bereich (`("z", "a")`) und für leere `domains`
  oder `fields`.
- `text-to-blocks` liefert für einen Text ohne Buchstaben `""`, statt abzubrechen.
- Unbekannte benannte Argumente sind bei den Chiffren, `text-to-blocks` und
  `ascii-table` ein Fehler mit Vorschlag. Die übrigen Funktionen haben keine
  benannten Argumente; dort meldet Typst selbst „unexpected argument“.

= Referenz

== Chiffren

#show-module(
  read("../src/ciphers.typ"),
  name: "informatik",
  only: ("caesar", "caesar-table", "vigenere", "atbash", "rot13"),
)

== Häufigkeitsanalyse

#show-module(read("../src/analysis.typ"), name: "informatik", only: ("haeufigkeitsanalyse",))

== Zahlensysteme

#show-module(
  read("../src/numbers.typ"),
  name: "informatik",
  only: ("bin-to-dec", "dec-to-bin", "hex-to-dec", "dec-to-hex"),
)

== Tabellen und Textblöcke

#show-module(read("../src/tables.typ"), name: "informatik", only: ("text-to-blocks", "ascii-table"))
