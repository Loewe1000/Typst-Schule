#import "@schule/schuldocs:0.3.1": info, show-code, show-example, show-module, tip, warning
#import "@preview/zap:0.4.0"
#import "../src/lib.typ" as physik

// Jedes Beispiel wird aus genau dem Quelltext gesetzt, der daneben steht:
// kompiliert das Handbuch, kompiliert auch jedes Beispiel.
#let scope = dictionary(physik) + (zap: zap)
#let example(source, width: 14cm) = show-example(
  rendered: eval(source.text, mode: "markup", scope: scope),
  source: source,
  width: width,
)

= Über dieses Paket

Das `physik`-Paket stellt Werkzeuge für den Physikunterricht bereit: Messwerttabellen, berechnete Messreihen, Regressionen, Schaltkreise und eine Sammlung von Naturkonstanten.

Die Bausteine tragen deutsche Namen (`datensatz`, `messwerttabelle`, `lineare-regression`, `schaltkreis`, `konstante`), alles in den Klammern ist englisch (`name:`, `unit:`, `digits:`).

Dieses Handbuch gliedert sich wie folgt:

+ *Schnellstart* -- erste Schritte
+ *Datensätze* -- Messreihen anlegen und berechnen
+ *Messwerttabellen* -- Tabellen setzen
+ *Regressionen* -- Ausgleichskurven mit Gleichung
+ *Schaltkreise* -- Schaltskizzen
+ *Konstanten* -- vordefinierte Naturkonstanten
+ *Fehlermeldungen* -- was das Paket bei falschen Angaben meldet
+ *Umstieg auf 0.5.0* -- alte und neue Namen
+ *Referenz* -- alle Funktionen mit ihren Parametern

= Schnellstart

#show-code(```typ
#import "@schule/physik:0.5.0": *

#let t = datensatz((0, 1, 2, 3, 4, 5), name: "Zeit", unit: "s")
#let s = datensatz((0, 1.2, 4.8, 10.8, 19.2, 30.0), name: "Weg", unit: "m")

#messwerttabelle(t, s)

#let fit = quadratische-regression(x: t, y: s)
Ausgleichskurve: #fit.math
```)

Wer `arbeitsblatt` oder `klassenarbeit` benutzt und dort nicht alle Namen von physik bekommt, importiert die fehlenden namentlich, zum Beispiel `#import "@schule/physik:0.5.0": source, lamp, ammeter, konstante`.

= Datensätze

Ein Datensatz ist eine Messreihe: Werte mit Bezeichnung und Einheit. Er ist die Zeile einer Messwerttabelle und die Eingabe für `berechnung` und die Regressionen. Angelegt wird er mit `datensatz`, `messdaten` oder `berechnung`.

== Messwerte angeben

Die Werte stehen vorn, alles andere ist benannt.

#example(```typ
#let t = datensatz((0, 1, 2, 3, 4, 5), name: "Zeit", unit: "s")
#messwerttabelle(t)
```)

== Vorsätze

`prefix` setzt einen SI-Vorsatz vor die Einheit. Die Werte stehen dann in dieser Einheit: `prefix: "m"` mit `unit: "A"` heißt, dass die Zahlen Milliampere sind. Mit `prefix: auto` wählt das Paket den Vorsatz so, dass der kleinste Wert zwischen 1 und 1000 liegt, und rechnet die Werte um. Eine Zehnerpotenz schreibt man als `"e14"`.

#example(```typ
#let i = datensatz((1.2, 4.7, 10.2), name: "I", unit: "A", prefix: "m")
#let u = datensatz((0.0015, 0.003, 0.0045), name: "U", unit: "V", prefix: auto)
#let f = datensatz((5.2, 6.1, 7.4), name: "f", unit: "Hz", prefix: "e14")
#messwerttabelle(i, u, f)
```)

Erlaubt sind `none` (kein Vorsatz), `auto` und die Vorsätze `"Q"`, `"R"`, `"Y"`, `"Z"`, `"E"`, `"P"`, `"T"`, `"G"`, `"M"`, `"k"`, `"c"`, `"m"`, `"u"` (Mikro), `"n"`, `"p"`, `"f"`, `"a"`, `"z"`, `"y"`, `"r"`, `"q"`. Andere Vorsätze (Hekto, Dezi) schreibt man direkt in die Einheit: `unit: "hPa"`.

== Leere Messreihen zum Ausfüllen

`messdaten` legt eine Messreihe mit leeren Zellen an.

#example(```typ
#messwerttabelle(
  messdaten(5, name: "Zeit", unit: "s"),
  messdaten(5, name: "Weg", unit: "m"),
  row-height: 9mm,
)
```)

== Berechnete Messreihen

`berechnung` leitet eine Messreihe aus anderen ab. Die Formel steht vorn und bekommt je Datensatz in `datasets` ein Argument.

#example(```typ
#let t = datensatz((1.0, 2.0, 3.0, 4.0), name: "Zeit", unit: "s")
#let t2 = berechnung(t => t * t, datasets: (t,), name: "Zeit²", unit: "s²")
#messwerttabelle(t, t2)
```)

Die Formel rechnet in Basiseinheiten: Ein Datensatz in Milliampere kommt in Ampere an, und das Ergebnis wird als Wert in der Basiseinheit der Zieleinheit erwartet. Den Vorsatz des Ergebnisses wählt das Paket selbst (`prefix: auto`); mit `prefix: none` bleibt die Einheit, wie sie angegeben ist.

#example(```typ
#let u = datensatz((1.5, 3.0, 4.5), name: "U", unit: "V")
#let i = datensatz((2, 4.1, 5.9), name: "I", unit: "A", prefix: "m")
#let p = berechnung((u, i) => u * i, datasets: (u, i), name: "P", unit: "W")
#let r = berechnung((u, i) => u / i, datasets: (u, i), name: "R", unit: "ohm", prefix: none, digits: 0)
#messwerttabelle(u, i, p, r)
```)

#tip[
  Mit `error: 5%` streut `berechnung` die Werte zufällig um bis zu 2,5 % nach oben und unten. So entstehen aus einer Formel „Messwerte" für eine Auswertungsaufgabe.
]

#warning[
  Der Vorsatz wird am Anfang der Einheit erkannt, ohne die Einheit zu kennen: `"mA"` ist Milliampere, aber auch `"m/s"` wird als „Milli" gelesen und `"min"` ebenso. Für solche Einheiten in `berechnung` die Einheit als Inhalt angeben (`unit: [m/s]`), dann wird nichts umgerechnet.
]

= Messwerttabellen

`messwerttabelle` setzt die übergebenen Datensätze untereinander, vorn die Bezeichnung mit Einheit. Die Datensätze stehen als einzelne Positionsargumente; eine Liste wird mit `..liste` übergeben.

#example(```typ
#let x = datensatz((1.0, 2.0, 3.0, 4.0, 5.0), name: "Zeit", unit: "s")
#let y = datensatz((1.5, 6.0, 13.5, 24.0, 37.5), name: "Weg", unit: "m")
#messwerttabelle(x, y)
```)

== Nachkommastellen

`digits` gilt für die ganze Tabelle; ein Datensatz mit eigener Angabe behält sie.

#example(```typ
#let x = datensatz((1.25, 2.5, 3.75), name: "x", unit: "cm")
#let y = datensatz((0.1234, 0.2345, 0.3456), name: "y", unit: "N", digits: 3)
#messwerttabelle(x, y, digits: 1)
```)

== Lange Messreihen teilen, Kopfzeile

`count` begrenzt die Wertespalten je Teiltabelle, `header` setzt eine Kopfzeile über die Wertespalten.

#example(```typ
#let n = datensatz((1, 2, 3, 4, 5, 6), name: "Messung")
#let l = datensatz((12.1, 12.3, 11.9, 12.0, 12.2, 12.1), name: "Länge", unit: "cm")
#messwerttabelle(n, l, count: 3, header: ([A], [B], [C]))
```)

= Regressionen

Alle Regressionen bekommen die Messreihen benannt als `x:` und `y:`, entweder als Datensatz oder als Liste aus Zahlen. Das Ergebnis ist ein Dictionary:

- `math` -- die Gleichung als Inhalt; mit Einheiten, wenn beide Datensätze eine Einheit haben
- `math-digits` -- Funktion `digits => content` für dieselbe Gleichung mit anderer Stellenzahl
- `coefficients` -- die Koeffizienten unter ihrem Formelzeichen, zum Beispiel `(m: …, b: …)`
- `function` -- die Funktion `x => y`, zum Beispiel für `graphen` aus mathematik

#table(
  columns: (auto, auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Funktion*], [*Gleichung*], [*`coefficients`*]),
  [`lineare-regression`], [$y = m x + b$], [`m`, `b`],
  [`quadratische-regression`], [$y = a x^2 + b x + c$], [`a`, `b`, `c`],
  [`wurzel-regression`], [$y = a sqrt(x) + b$], [`a`, `b`],
  [`exponentielle-regression`], [$y = b dot e^(a x)$], [`a`, `b`],
  [`potenz-regression`], [$y = a dot x^m$], [`a`, `m`],
  [`polynom-regression`], [$y = c_0 + c_1 x + … + c_n x^n$], [`c0`, `c1`, …],
)

== Lineare Regression

#example(```typ
#let t = datensatz((1.0, 2.0, 3.0, 4.0, 5.0), name: $t$, unit: "s")
#let s = datensatz((2.1, 4.0, 5.9, 8.1, 9.8), name: $s$, unit: "m")
#let fit = lineare-regression(x: t, y: s)
#fit.math

Steigung: #calc.round(fit.coefficients.m, digits: 3),
Wert bei 6: #calc.round((fit.function)(6), digits: 2)
```)

== Quadratische Regression

#example(```typ
#let fit = quadratische-regression(
  x: (0, 1, 2, 3, 4),
  y: (0.1, 1.3, 4.9, 10.7, 19.4),
)
#fit.math \
#(fit.math-digits)(4)
```)

== Wurzel-Regression

#example(```typ
#let l = datensatz((0.2, 0.4, 0.6, 0.8), name: $l$, unit: "m")
#let p = datensatz((0.9, 1.27, 1.55, 1.8), name: $T$, unit: "s")
#wurzel-regression(x: l, y: p).math
```)

== Exponentielle Regression

#example(```typ
#let fit = exponentielle-regression(x: (0, 1, 2, 3), y: (2, 2.9, 4.6, 6.7))
#fit.math
```)

== Potenz-Regression

#example(```typ
#let fit = potenz-regression(x: (1, 2, 3, 4), y: (2, 7.9, 18.2, 31.8))
#fit.math
```)

== Polynom-Regression

Der Grad steht in `degree`.

#example(```typ
#let fit = polynom-regression(
  x: (0, 1, 2, 3, 4),
  y: (1, 2.1, 8.8, 28.3, 65),
  degree: 3,
)
#fit.math
```)

== Zahlschreibweise

`notation: "scientific"` setzt die Koeffizienten mit Zehnerpotenz. `tolerance` ist die Nullschwelle: Ein Summand, dessen Koeffizient im Betrag kleiner ist, entfällt.

#example(```typ
#let fit = lineare-regression(
  x: (1, 2, 3),
  y: (1500, 3100, 4400),
  notation: "scientific",
)
#fit.math
```)

= Schaltkreise

`schaltkreis` setzt eine Schaltskizze und ist `circuit` aus dem Paket #link("https://typst.app/universe/package/zap")[zap]. Das Paket bringt eigene Schaltzeichen in Schulschreibweise mit; Leitungen (`zap.wire`), Knoten (`zap.node`) und alle weiteren Bauteile kommen aus zap. Dafür importiert das Dokument zap selbst.

#example(```typ
#import "@preview/zap:0.4.0"
#schaltkreis({
  source("q", (0, 0), (0, 3))
  lamp("l", (3, 0), (3, 3))
  ammeter("a", (0, 3), (3, 3))
  zap.wire((0, 0), (3, 0))
})
```)

== Schaltzeichen

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Funktion*], [*Bauteil*]),
  [`source`], [Spannungsquelle, Gleich- oder Wechselstrom],
  [`lamp`], [Glühlampe (Kreis mit Kreuz)],
  [`ammeter`], [Amperemeter (Kreis mit A)],
  [`voltmeter`], [Voltmeter (Kreis mit V)],
  [`multimeter`], [Multimeter (Kreis mit Zeiger)],
  [`motor`], [Motor (Kreis mit M)],
  [`generator`], [Generator (Kreis mit G)],
)

== Spannungsquellen

#example(```typ
#schaltkreis({
  source("a", (0, 0), (0, 2))
  source("b", (2, 0), (2, 2), kind: "bars")
  source("c", (4, 0), (4, 2), current: "alternating")
  source("d", (6, 0), (6, 2), flipped: true)
  source("e", (8, 0), (8, 2), flipped-labels: true)
})
```)

Von links: die Vorgabe (`current: "direct"`, `kind: "symbol"`), `kind: "bars"`, `current: "alternating"`, `flipped: true` (Polarität vertauscht) und `flipped-labels: true` (Plus und Minus auf der anderen Seite).

= Konstanten

`constants` enthält vordefinierte Naturkonstanten. Jeder Eintrag hat die Schlüssel `name`, `value` (Zahl zum Rechnen), `symbol`, `unit` und `qty` (gesetzter Wert mit Einheit).

#example(```typ
#constants.c.name: #constants.c.symbol = #constants.c.qty

#let weight = 2.5 * constants.g.value
Gewichtskraft: #calc.round(weight, digits: 1) N
```)

#table(
  columns: (auto, auto, 1fr, auto),
  stroke: 0.5pt + luma(180),
  table.header([*Schlüssel*], [*Zeichen*], [*Bezeichnung*], [*Wert*]),
  ..physik.constants.pairs().map(((key, entry)) => (raw("constants." + key), entry.symbol, entry.name, entry.qty)).flatten(),
)

Eine eigene Konstante legt `konstante` an. Der Wert steht vorn; als Text bleiben alle Stellen erhalten.

#example(```typ
#let au = konstante("1.495978707e11", name: "Astronomische Einheit", unit: [m], symbol: $"AE"$)
#au.name: #au.symbol = #au.qty
```)

= Fehlermeldungen

Jede Funktion prüft ihre Angaben. Eine Meldung nennt Paket und Funktion, den Befund und die Abhilfe:

#show-code(```
physik.datensatz: unbekannter Parameter `nam` – meintest du `name`?
physik.messwerttabelle: `amount` heißt jetzt `count`
physik.berechnung: `error` erwartet einen Anteil, bekam `5` (int) – zum Beispiel `5%`
physik.messwerttabelle: Positionsargument `5` ist kein Datensatz – die Spaltenzahl steht in `count: 5`
```)

= Umstieg auf 0.5.0 <umstieg>

Mit 0.5.0 haben alle Pakete einheitliche Namen: Die Bausteine bleiben deutsch, alles in den Klammern ist englisch. Am gesetzten Dokument ändert sich nichts. Alte Namen brechen beim Kompilieren mit einer Meldung ab, die den neuen Namen nennt.

== Aufrufe

#table(
  columns: (1fr, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*bisher (0.0.2)*], [*jetzt (0.5.0)*]),
  [`datensatz("Zeit", "s", (0, 1, 2))`], [`datensatz((0, 1, 2), name: "Zeit", unit: "s")`],
  [`messdaten("Zeit", "s", 5)`], [`messdaten(5, name: "Zeit", unit: "s")`],
  [`berechnung("v", "m/s", (s, t), (s, t) => s / t)`], [`berechnung((s, t) => s / t, datasets: (s, t), name: "v", unit: "m/s")`],
  [`berechnung("A", "m²", a, a => a * a)`], [`berechnung(a => a * a, datasets: (a,), name: "A", unit: "m²")`],
  [`messwerttabelle((a, b))`], [`messwerttabelle(a, b)` oder `messwerttabelle(..liste)`],
  [`lineare_regression(t, s)`], [`lineare-regression(x: t, y: s)`],
  [`polynom_regression(t, s, 3)`], [`polynom-regression(x: t, y: s, degree: 3)`],
  [`konstante("Name", "9.81", [m/s²], symbol: $g$)`], [`konstante("9.81", name: "Name", unit: [m/s²], symbol: $g$)`],
  [`simple-source("q", …)`], [`source("q", …)`],
  [`amperemeter("a", …)`], [`ammeter("a", …)`],
  [`zap.wire(…)` über physik], [`#import "@preview/zap:0.4.0"` im Dokument, dann `zap.wire(…)`],
)

== Funktionen und Werte

#table(
  columns: (1fr, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*bisher*], [*jetzt*]),
  [`lineare_regression`], [`lineare-regression`],
  [`quadratische_regression`], [`quadratische-regression`],
  [`wurzel_regression`], [`wurzel-regression`],
  [`exponentielle_regression`], [`exponentielle-regression`],
  [`potenz_regression`], [`potenz-regression`],
  [`polynom_regression`], [`polynom-regression`],
  [`simple-source`], [`source`],
  [`amperemeter`], [`ammeter`],
  [`pk`], [`constants`],
  [`pk.m.elektron`, `pk.m.proton`, `pk.m.neutron`, `pk.m.u`], [`constants.m_e`, `constants.m_p`, `constants.m_n`, `constants.u`],
  [`pk.v.schall`], [`constants.v_sound`],
  [`qty`, `unit`, `znum`, `rand`, `shuffle` … (durchgereichte Fremdnamen)], [entfallen; das Dokument importiert sie selbst oder bekommt `qty`, `unit`, `num` aus arbeitsblatt],
  [`multiplikatoren`, `umrechnungseinheit`, `format-number` … (Helfer)], [nur noch unter `internal`, ohne Zusicherung],
)

== Parameter

#table(
  columns: (auto, 1fr, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Funktion*], [*bisher*], [*jetzt*]),
  [`datensatz`], [`max-digits: 2`], [`digits: 2`],
  [], [`max-digits: none`], [weglassen (`digits: auto`)],
  [], [`auto-einheit: true`], [`prefix: auto`; steht schon ein `prefix` da, nur löschen],
  [], [`auto-einheit: false`], [weglassen],
  [], [`prefix: "1"`, `prefix: ""`], [weglassen (`prefix: none`)],
  [`messdaten`], [`prefix: "1"`], [weglassen (`prefix: none`)],
  [`berechnung`], [`fehler: 5%`], [`error: 5%`],
  [], [`max-digits: 2`], [`digits: 2`],
  [], [`auto-einheit: false`, `prefix: ""`], [`prefix: none`; steht schon ein `prefix` da, `auto-einheit` nur löschen],
  [], [`auto-einheit: true`, `prefix: "1"`], [weglassen (`prefix: auto`)],
  [`messwerttabelle`], [`amount: 5`], [`count: 5`],
  [], [`max-digits: 2`], [`digits: 2`],
  [Regressionen], [`precision: 1e-10`], [`tolerance: 1e-10`],
  [], [`notation: "dec"`], [`notation: "decimal"`],
  [], [`notation: "sci"`], [`notation: "scientific"`],
  [`source`], [`current: "dc"`], [`current: "direct"`],
  [], [`current: "ac"`], [`current: "alternating"`],
  [], [`variant: "symbol"`], [`kind: "symbol"`],
  [], [`variant: "lines"`], [`kind: "bars"`],
  [], [`flipped-side: true`], [`flipped-labels: true`],
  [`konstante`], [`beschreibung: "…"`], [entfällt (wurde nie verwendet)],
  [alle], [Name oder Einheit `""`], [weglassen oder `none`],
)

== Schlüssel in Ergebnissen

#table(
  columns: (auto, 1fr, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Ergebnis von*], [*bisher*], [*jetzt*]),
  [`datensatz`, `messdaten`, `berechnung`], [`einheit`, `werte`, `max-digits`], [`unit`, `values`, `digits`],
  [], [`auto-einheit`], [entfällt (steckt in `prefix: auto`)],
  [`lineare-regression`], [`r.m`, `r.b`], [`r.coefficients.m`, `r.coefficients.b`],
  [`quadratische-regression`], [`r.a`, `r.b`, `r.c`], [`r.coefficients.a` …],
  [`polynom-regression`], [`r.c0`, `r.c1` …], [`r.coefficients.c0` …],
  [`konstante`, `constants.*`], [`wert`, `einheit`, `mit-einheit`], [`value`, `unit`, `qty`],
)

== Was sich sonst geändert hat

- Die Kurzform `messwerttabelle((a, b))` mit einer Liste entfällt; benannte Argumente, die die Funktion nicht kennt, sind ein Fehler statt wirkungslos.
- Ein `header` mit mehr Einträgen als Wertespalten ist ein Fehler.
- `berechnung` lässt leere Zellen der Eingabe leer, auch die aus `messdaten`.
- Hat eine Regressionsgleichung ohne Einheiten einen negativen ersten Koeffizienten, steht das Minuszeichen jetzt da.
- Die Einheit `"ohm"` erscheint im Tabellenkopf als Ω.
- Ein leerer Text als Name oder Einheit (`name: ""`, `unit: ""`) ist ein Fehler; für „keine Angabe“ steht `none` oder das Argument fehlt.
- `konstante` prüft einen als Text übergebenen Wert: `konstante("abc")` bricht mit einer Meldung des Pakets ab.
- `source` lehnt Tippfehler seiner eigenen Parameter ab (`varient`, `curent`), statt sie an zap weiterzugeben. Alle anderen benannten Argumente der Schaltzeichen gehen weiterhin ungeprüft an zap.
- Die Messwerttabelle setzt Typsts eingebautes `grid`; das Paket braucht `tablex` nicht mehr. Maße und Schriftbild bleiben gleich. In der getönten Bezeichnungsspalte sind die waagerechten Linien jetzt so stark wie die übrigen (0,5 pt); bisher verdeckte die Tönung der nächsten Zeile ihre untere Hälfte, auf dem Bildschirm fehlten sie dadurch stellenweise.

= Referenz

== Datensätze und Messwerttabelle
#show-module(read("../src/datasets.typ"), name: "datasets", scope: scope)

== Regressionen
#show-module(read("../src/regressions.typ"), name: "regressions", scope: scope)

== Schaltkreise
#show-module(read("../src/circuits.typ"), name: "circuits", scope: scope)

== Konstanten
#show-module(read("../src/constants.typ"), name: "constants", scope: scope)
