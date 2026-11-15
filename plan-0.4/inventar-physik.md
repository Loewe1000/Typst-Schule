# Inventar: physik 0.0.2, messwerttabellen 0.0.1, energy-sketch 0.0.3

Stand: 2026-11-14. Nur gelesen, nichts am Repo geändert. Alle Zeilennummern beziehen sich auf die jeweils genannte Datei unter
`/Users/alexander/Library/Application Support/typst/packages/schule/`.

Gelesene Dateien (vollständig):

| Datei | Zeilen |
|---|---|
| `physik/0.0.2/lib.typ` | 5 |
| `physik/0.0.2/messwerttabellen.typ` | 571 |
| `physik/0.0.2/regressionen.typ` | 616 |
| `physik/0.0.2/schaltkreise.typ` | 254 |
| `physik/0.0.2/konstanten.typ` | 74 |
| `physik/0.0.2/typst.toml` | 8 |
| `messwerttabellen/0.0.1/lib.typ` | 258 |
| `messwerttabellen/0.0.1/typst.toml` | 7 |
| `energy-sketch/0.0.3/lib.typ` | 157 |
| `energy-sketch/0.0.3/README.md`, `example.typ`, `typst.toml` | 44 / 41 / 11 |

Mit `typst 0.15.1` nachgeprüft (Testdateien nur im Scratchpad): tatsächliche Exportliste von `@schule/physik:0.0.2` und die unter "Fehler" als **bestätigt** markierten Punkte.

Spalte "Sprache": de = deutsch, en = englisch, mix = gemischt, abk = Abkürzung. Spalte "Art": pos = positional, named = benannt, sink = `..args`.

---

## 0. Kurzüberblick Namenskonventionen

| Bereich | Funktionsnamen | Parameternamen | Trennzeichen |
|---|---|---|---|
| physik/messwerttabellen.typ | de (`datensatz`, `messdaten`, `berechnung`, `messwerttabelle`) + Hilfsfunktionen de mit snake_case (`auto_einheit_anwenden`) + en snake_case (`count_decimal_places`) + Präfix-Kürzel (`p_messwerttabelle`) | pos. de (`name, einheit, werte, formel`), benannt gemischt: `prefix`, `max-digits`, `amount`, `row-height`, `header`, `width` (en) neben `auto-einheit` (denglisch), `fehler`, `anzahl-messwerte`, `datensaetze` (de) | kebab-case bei Parametern, snake_case bei Funktionen und lokalen Variablen |
| physik/regressionen.typ | öffentliche API de snake_case (`lineare_regression`), Hilfsfunktionen en kebab-case (`format-number`, `combine-units`, `build-equation`) | `x_param`, `y_param` (snake, en/abk), `notation`, `precision`, `digits` (en), `grad` (de), `koeffizienten-namen`, `min-punkte` (de, kebab), `x_einheit`, `y_einheit`, `x_potenz`, `x_name` (snake, de/mix) | gemischt kebab/snake in derselben Signatur |
| physik/schaltkreise.typ | `schaltkreis` (de), sonst en (`source`, `simple-source`, `multimeter`, `lamp`, `motor`, `generator`) bzw. international (`amperemeter`, `voltmeter`) | durchgehend en (`name, node, current, variant, flipped, flipped-side, ..params`) | kebab-case |
| physik/konstanten.typ | `konstante` (de), `pk` (abk) | de (`name, wert, einheit, symbol, beschreibung`) | Dictionary-Keys: kebab (`mit-einheit`) und snake (`k_B`, `N_A`, `h_eV`, `epsilon_0`, `mu_0`) |
| messwerttabellen 0.0.1 | wie physik, älterer Stand | zusätzlich `max_wert_pro_tabelle` (snake, positional) statt `amount` | gemischt |
| energy-sketch 0.0.3 | en (`energy-sketch`) | en (`energy-name`, `hide-letters`, `height`, `gap`) | kebab-case; Fehlermeldungen de |

---

## 1. physik 0.0.2

### 1.1 `lib.typ` (Entrypoint)

```typ
1  #import "@preview/zap:0.4.0" as zap
2  #import "schaltkreise.typ": *
3  #import "messwerttabellen.typ": *
4  #import "regressionen.typ": *
5  #import "konstanten.typ": *
```

Keine eigenen Definitionen. Alles wird per `*` weitergereicht, **einschließlich der Importe der Unterdateien** (Typst reicht importierte Bindungen weiter).

Tatsächliche Exportliste von `@schule/physik:0.0.2` (per `dictionary(modul).keys()` ermittelt, in dieser Reihenfolge):

| Name | Herkunft | gewollt öffentlich? |
|---|---|---|
| `zap` | lib.typ:1 / schaltkreise.typ:1 (Modul `@preview/zap:0.4.0`) | ja (arbeitsblatt importiert es) |
| `schaltkreis`, `source`, `simple-source`, `multimeter`, `lamp`, `amperemeter`, `voltmeter`, `motor`, `generator` | schaltkreise.typ | ja |
| `qty`, `unit`, `add-macros` | messwerttabellen.typ:1 (`@preview/fancy-units:0.1.1`) | **Leck** |
| `znum` | messwerttabellen.typ:2 / regressionen.typ:1 (`@preview/zero:0.5.0`, `num as znum`) | **Leck** |
| `default_seed`, `m`, `a`, `lcg`, `low_cminstd_rand`, `low_cminstd_randint`, `step_seed`, `fisher_yates_shuffle`, `rand`, `randint`, `shuffle` | messwerttabellen.typ:3 (`@schule/random:0.0.1: *`) | **Leck** (besonders die Einbuchstaben-Namen `m` und `a`) |
| `datensatz`, `messdaten`, `berechnung`, `messwerttabelle` | messwerttabellen.typ | ja |
| `multiplikatoren`, `umrechnungseinheit`, `auto_einheit_anwenden`, `count_decimal_places`, `p_messwerttabelle`, `_kopf-einheit` | messwerttabellen.typ | intern gemeint, aber exportiert (`umrechnungseinheit` wird von `mathematik 0.0.2` benutzt) |
| `format-number`, `format-unit`, `combine-units`, `format-equation-term`, `build-equation`, `format-simple-equation`, `regression` | regressionen.typ | intern gemeint, aber exportiert |
| `lineare_regression`, `quadratische_regression`, `wurzel_regression`, `exponentielle_regression`, `potenz_regression`, `polynom_regression` | regressionen.typ | ja |
| `konstante`, `pk` | konstanten.typ | ja |

`typst.toml`: name `physik`, version `0.0.2`, entrypoint `lib.typ`, Beschreibung deutsch, license MIT, repository `https://github.com/Loewe1000/Typst-Schule`. Kein `compiler`-Feld (energy-sketch hat eines).

Importierte Fremdpakete in physik 0.0.2: `@preview/zap:0.4.0`, `@preview/fancy-units:0.1.1`, `@preview/zero:0.5.0`, `@preview/tablex:0.0.9` (lokal in `p_messwerttabelle`, Z. 404; tablex ist seit Typst 0.11 durch die eingebaute `table` überholt), `@schule/random:0.0.1`.

---

### 1.2 `messwerttabellen.typ`

Importe: Z. 1 `fancy-units:0.1.1` (`qty, unit, add-macros`), Z. 2 `zero:0.5.0` (`num as znum`), Z. 3 `@schule/random:0.0.1: *`.

Z. 5–8: `#add-macros(u: sym.mu, ohm: sym.Omega)` auf Modulebene. Der Rückgabewert (State-Update als Content) wird in einem importierten Modul nie platziert und bleibt wirkungslos (**bestätigt**: `datensatz("R", "ohm", …)` erscheint im Tabellenkopf wörtlich als "ohm"). Der Workaround `_kopf-einheit` (Z. 386) ersetzt deshalb `u` von Hand durch `µ`; `ohm` wird nirgends ersetzt.

#### Datensatz-Dictionary (zentrale Datenstruktur, auch von regressionen.typ und mathematik gelesen)

| Key | Typ | gesetzt von | Sprache | Bemerkung |
|---|---|---|---|---|
| `name` | str / content | datensatz, messdaten, berechnung | de/en | Tabellenkopf, Variablenname in Regressionsgleichung |
| `einheit` | str / content / none | alle | de | String wird auf SI-Präfix am Anfang geparst |
| `prefix` | str | alle | en | `"1"` = kein Präfix (Sentinel), `"k"`, `"m"`, `"u"` …, oder `"e14"` = Faktor 10^14 |
| `werte` | array (int/float/none/content/`""`) | alle | de | `messdaten` füllt mit `""` |
| `auto-einheit` | bool | nur `datensatz` | mix | fehlt bei `messdaten` und `berechnung` (dort schon angewendet) |
| `max-digits` | int / none | `datensatz`, `berechnung` | en | fehlt bei `messdaten` |

#### `datensatz` (Z. 19)

```typ
#let datensatz(name, einheit, werte, prefix: "1", max-digits: none, auto-einheit: false) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `name` | pos | – | str, content | de/en | Bezeichnung im Tabellenkopf |
| `einheit` | pos | – | str, content, (none) | de | Einheit; String wird als fancy-units-Ausdruck gesetzt |
| `werte` | pos | – | array von Zahlen / none / content | de | Messwerte |
| `prefix` | named | `"1"` | `"1"`, Schlüssel aus `multiplikatoren` (`"Q" … "q"`), `"e<int>"` | en | SI-Präfix bzw. Zehnerpotenz der Kopf-Einheit; setzt `auto-einheit` außer Kraft (Z. 21–23) |
| `max-digits` | named | `none` | int, none | en, kebab | Nachkommastellen; none = Wert der Tabelle |
| `auto-einheit` | named | `false` | bool | mix (en+de), kebab | automatische Präfixwahl (wird erst in `messwerttabelle` Z. 525 angewendet) |

Rückgabe: Dictionary `(name, einheit, prefix, werte, auto-einheit, max-digits)`.

#### `messdaten` (Z. 45)

```typ
#let messdaten(name, einheit, anzahl-messwerte, prefix: "1") = (
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `name` | pos | – | str, content | de/en | Bezeichnung |
| `einheit` | pos | – | str, content | de | Einheit |
| `anzahl-messwerte` | pos | – | int | de, kebab | Anzahl leerer Zellen |
| `prefix` | named | `"1"` | wie oben | en | Präfix |

Rückgabe: `(name, einheit, prefix, werte: n * ("",))`. Kein `max-digits`, kein `auto-einheit`.

#### `multiplikatoren` (Z. 52) – öffentliche Variable

Dictionary Präfix → Faktor. Schlüssel: `"Q","R","Y","Z","E","P","T","G","M","k","","c","m","u","n","p","f","a","z","y","r","q"`. `"u"` = Mikro. Kein `"h"`, `"da"`, `"d"`. Dieselbe Tabelle steht noch einmal als lokale Liste `prefix_liste` in `umrechnungseinheit` (Z. 107–130) – Dopplung.

#### `umrechnungseinheit` (Z. 78)

```typ
#let umrechnungseinheit(wert, einheit) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `wert` | pos | – | int, float (sonst Rückgabe `(1, einheit)`) | de | Referenzwert für die Präfixwahl |
| `einheit` | pos | – | str (sonst unverändert) | de | Einheit, ggf. mit Präfix |

Rückgabe: `(faktor, neue_einheit)`. Von `mathematik/0.0.2/mathematik.typ:2` importiert und dort Z. 636–645 als `umrechnungseinheit(1, x-ds.einheit)` bzw. `umrechnungseinheit(1, x-ds.prefix)` aufgerufen.

#### `auto_einheit_anwenden` (Z. 146)

```typ
#let auto_einheit_anwenden(werte, einheit) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `werte` | pos | – | array | de | Werte |
| `einheit` | pos | – | str (content → keine Änderung) | de | Einheit |

Rückgabe `(werte, einheit)`. snake_case, intern gemeint.

#### `count_decimal_places` (Z. 181)

```typ
#let count_decimal_places(wert) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `wert` | pos | – | Zahl, content | de | Zahl, deren Nachkommastellen gezählt werden |

Englischer snake_case-Name mit deutschem Parameter. **In physik 0.0.2 nirgends aufgerufen** (toter Code; in messwerttabellen 0.0.1 Z. 145 noch benutzt).

#### `berechnung` (Z. 212)

```typ
#let berechnung(name, einheit, datensaetze, formel, prefix: "1", auto-einheit: true, fehler: 0, max-digits: none) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `name` | pos | – | str, content | de/en | Bezeichnung |
| `einheit` | pos | – | str, content | de | Zieleinheit |
| `datensaetze` | pos | – | dictionary oder array von dictionaries (max. 5) | de, Umlaut als `ae` | Eingabe-Datensätze |
| `formel` | pos | – | function mit 1–5 Argumenten | de | Rechenvorschrift auf Basiseinheiten |
| `prefix` | named | `"1"` | wie `datensatz`, zusätzlich beliebiger String `x` → `float("1" + x)` (Z. 322) | en | Präfix der Zieleinheit |
| `auto-einheit` | named | `true` | bool | mix | automatische Präfixwahl; wird bei zusammengesetzter Einheit oder gesetztem `prefix` abgeschaltet |
| `fehler` | named | `0` | ratio (z. B. `5%`); `0` (int) als "aus" | de | zufälliger relativer Fehler |
| `max-digits` | named | `none` | int, none | en | Nachkommastellen |

Rückgabe: `(name, einheit, werte, prefix, max-digits)`.
Fehlermeldung Z. 308 (de, `panic`): "Zu viele Parameter für die Formel. Maximal 5 Datensätze unterstützt."

#### `_kopf-einheit` (Z. 386)

```typ
#let _kopf-einheit(prefix, einheit) = {
```

Privat gemeint (Unterstrich), wird aber durch `*` exportiert. Parameter `prefix` (en), `einheit` (de), beide positional.

#### `p_messwerttabelle` (Z. 398)

```typ
#let p_messwerttabelle(
  datensatze,
  row-height: auto,
  header: none,
  max-digits: 2,
) = [
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `datensatze` | pos | – | array von Datensätzen | de, Umlaut **ersatzlos** gestrichen (`datensatze`, nicht `datensaetze`) | Zeilen der Tabelle |
| `row-height` | named | `auto` | auto, length | en | Zeilenhöhe |
| `header` | named | `none` | none, array von content | en | Kopfzeile |
| `max-digits` | named | `2` | int | en | Nachkommastellen |

Interner Renderer mit Präfix `p_` (vermutlich "privat"), eigene Konvention neben `_kopf-einheit`. Feste Werte: `stroke: 0.5pt`, `inset: 2.5mm`, Kopf-/Randfarbe `rgb(255,255,255).darken(5%)`, Dezimaltrennzeichen `","` – nichts davon konfigurierbar, keine Anbindung an Themes.

#### `messwerttabelle` (Z. 501)

```typ
#let messwerttabelle(..args, amount: auto, row-height: auto, header: none, width: 100%, max-digits: 2) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `..args` | sink (nur `.pos()` ausgewertet) | – | Datensätze einzeln, ein Array von Datensätzen oder ein einzelner Datensatz | en | Zeilen |
| `amount` | named | `auto` | auto, int | en | maximale Wertespalten je Teiltabelle |
| `row-height` | named | `auto` | auto, length | en | Zeilenhöhe |
| `header` | named | `none` | none, array | en | zusätzliche Kopfzeile |
| `width` | named | `100%` | length, ratio | en | Breite des umgebenden `block` |
| `max-digits` | named | `2` | int | en | globale Nachkommastellen |

Benannte Argumente im Sink (`args.named()`) werden stillschweigend verworfen: ein Tippfehler wie `max-digit: 3` erzeugt keinen Fehler. **Keine Optionsprüfung** in der ganzen Datei.

---

### 1.3 `regressionen.typ`

Importe: Z. 1 `zero:0.5.0` (`num as znum`), Z. 2 `fancy-units:0.1.1` (`unit`).

#### Hilfsfunktionen (öffentlich exportiert, kein Unterstrich)

`format-number` (Z. 4)

```typ
#let format-number(value, notation: "dec", digits: 2) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `value` | pos | – | int, float | en | Zahl |
| `notation` | named | `"dec"` | `"dec"`, `"sci"` (alles andere wirkt wie `"dec"`, ungeprüft) | en | Zahlschreibweise |
| `digits` | named | `2` | int | en | Nachkommastellen (an `znum(digits:)`) |

`format-unit` (Z. 36)

```typ
#let format-unit(einheit) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `einheit` | pos | – | none, content, str | de | Einheit → `unit(per-mode: "fraction")` |

`combine-units` (Z. 46)

```typ
#let combine-units(y_einheit, x_einheit, x_potenz: 1) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `y_einheit` | pos | – | str, content | de, snake | Einheit der y-Größe |
| `x_einheit` | pos | – | str, content | de, snake | Einheit der x-Größe |
| `x_potenz` | named | `1` | int | de, snake | Exponent im Nenner |

Englischer kebab-Funktionsname mit deutschen snake_case-Parametern.

`format-equation-term` (Z. 71)

```typ
#let format-equation-term(koeff, koeff-einheit, x-name, x-potenz, is-first, notation, precision, digits: 2) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `koeff` | pos | – | float | de, abk | Koeffizient |
| `koeff-einheit` | pos | – | content | de, kebab | Einheit des Koeffizienten |
| `x-name` | pos | – | content, str | mix, kebab | Variablenname |
| `x-potenz` | pos | – | int | de, kebab | Exponent |
| `is-first` | pos | – | bool | en | **unbenutzt** |
| `notation` | pos | – | `"dec"`, `"sci"` | en | hier positional, sonst überall named |
| `precision` | pos | – | float | en | Schwelle; hier positional, sonst named |
| `digits` | named | `2` | int | en | Nachkommastellen |

Rückgabe `(skip: true)` oder `(skip: false, term:, is-negative:)`. Hier `x-potenz` (kebab), in `combine-units` `x_potenz` (snake).

`build-equation` (Z. 103)

```typ
#let build-equation(y-name, terms) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `y-name` | pos | – | content, str | mix | linke Seite |
| `terms` | pos | – | array von `(term, is-negative, skip)` | en | Summanden |

`format-simple-equation` (Z. 118)

```typ
#let format-simple-equation(y-name, koeffs, x-name, notation, precision, digits: 2) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `y-name` | pos | – | – | mix | **unbenutzt** (Ausgabe ist fest `y = …`) |
| `koeffs` | pos | – | array | de, abk, Plural mit en-`s` | Koeffizienten, höchste Potenz zuerst |
| `x-name` | pos | – | content | mix | Variablenname |
| `notation` | pos | – | `"dec"`, `"sci"` | en | |
| `precision` | pos | – | float | en | |
| `digits` | named | `2` | int | en | |

`regression` (Z. 148) – generischer Kern

```typ
#let regression(x_param, y_param, algorithmus, format-function, koeffizienten-namen: (), min-punkte: 2, notation: "dec", precision: 1e-10) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `x_param` | pos | – | Datensatz-Dictionary (mit `werte`) oder Array | en/abk, snake | x-Daten |
| `y_param` | pos | – | dito | en/abk, snake | y-Daten |
| `algorithmus` | pos | – | function `paare => koeffizienten` | de | Rechenkern |
| `format-function` | pos | – | function `(koeff, x_name:, y_name:, x_einheit:, y_einheit:, notation:, precision:, digits:)` | en, kebab | Formatierer |
| `koeffizienten-namen` | named | `()` | array von str | de, kebab | Schlüssel der Koeffizienten im Ergebnis |
| `min-punkte` | named | `2` | int | mix (en `min` + de), kebab | Mindestzahl gültiger Paare |
| `notation` | named | `"dec"` | `"dec"`, `"sci"` | en | |
| `precision` | named | `1e-10` | float | en | Terme mit Betrag darunter entfallen |

Fehlermeldung Z. 169 (de, `assert`): "Nicht genug gültige Datenpunkte".

Protokoll des Formatierers (benannte Argumente, snake_case, gemischt): `x_name`, `y_name` (en), `x_einheit`, `y_einheit` (de), `notation`, `precision`, `digits` (en).

#### Ergebnis-Dictionary aller Regressionen

| Key | Typ | Sprache | Bemerkung |
|---|---|---|---|
| `math` | content | en | Gleichung mit 2 Nachkommastellen |
| `math-digits` | function `digits => content` | en, kebab | Gleichung mit wählbaren Stellen |
| `function` | function `x => y` | en | ausgewertete Funktion |
| Koeffizienten | float | – | je Regression verschieden benannt, siehe unten |

#### Öffentliche Regressionen

`lineare_regression` (Z. 205)

```typ
#let lineare_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
```

`quadratische_regression` (Z. 251)

```typ
#let quadratische_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
```

`wurzel_regression` (Z. 305)

```typ
#let wurzel_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
```

`exponentielle_regression` (Z. 368)

```typ
#let exponentielle_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
```

`potenz_regression` (Z. 445)

```typ
#let potenz_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
```

`polynom_regression` (Z. 517)

```typ
#let polynom_regression(x_param, y_param, grad, notation: "dec", precision: 1e-10) = {
```

Gemeinsame Parametertabelle (gilt für alle sechs):

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `x_param` | pos | – | Datensatz-Dictionary oder Array von Zahlen | en/abk, snake | x-Daten |
| `y_param` | pos | – | dito | en/abk, snake | y-Daten |
| `grad` (nur `polynom_regression`) | pos | – | int | de | Polynomgrad |
| `notation` | named | `"dec"` | `"dec"`, `"sci"` (ungeprüft) | en | Zahlschreibweise |
| `precision` | named | `1e-10` | float | en | Schwelle zum Weglassen von Termen (keine Rundungsgenauigkeit!) |

| Funktion | Modell | Koeffizienten-Keys | Reihenfolge | min. Punkte | Fehlermeldungen (alle de, `assert`) |
|---|---|---|---|---|---|
| `lineare_regression` | y = m·x + b | `m`, `b` | höchste Potenz zuerst | 2 | – (Division durch 0 bei identischen x ungeprüft, Z. 221) |
| `quadratische_regression` | y = a·x² + b·x + c | `a`, `b`, `c` | höchste zuerst | 3 | Z. 268 "Determinante ist null" |
| `wurzel_regression` | y = a·√x + b | `a`, `b` | – | 2 | Z. 307 "x-Werte müssen nicht-negativ sein", Z. 318 "Keine eindeutige Lösung" |
| `exponentielle_regression` | y = b·e^(a·x) | `a` (Exponent), `b` (Vorfaktor) | – | 2 | Z. 370 "y-Werte müssen positiv sein", Z. 381 "Keine eindeutige Lösung" |
| `potenz_regression` | y = a·x^m | `a` (Vorfaktor), `m` (Exponent) | – | 2 | Z. 448 "x-Werte müssen positiv sein", Z. 449 "y-Werte müssen positiv sein", Z. 461 "Keine eindeutige Lösung" |
| `polynom_regression` | y = c0 + c1·x + … | `c0` … `c{grad}` | **niedrigste zuerst** | grad+1 | Z. 520 "Benötige mindestens N Datenpunkte", Z. 549 "Matrix singulär" |

---

### 1.4 `schaltkreise.typ`

Import: Z. 1 `@preview/zap:0.4.0 as zap`.

`schaltkreis` (Z. 16) – Variable, Alias

```typ
#let schaltkreis = zap.circuit
```

Deutscher Alias für eine englische Fremdfunktion; Signatur ist die von `zap.circuit`. (In physik 0.0.1 Z. 6: `zap.canvas`.)

`source` (Z. 28)

```typ
#let source(name, node, current: "dc", variant: "symbol", flipped: false, flipped-side: false, ..params) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `name` | pos | – | str | en/de | Komponentenname in zap |
| `node` | pos | – | zap-Koordinate | en | erster Knoten; weitere Knoten über `..params` |
| `current` | named | `"dc"` | `"dc"`, `"ac"` (geprüft) | en | Gleich-/Wechselspannung |
| `variant` | named | `"symbol"` | `"symbol"`, `"lines"` (geprüft) | en | Kreise mit +/− oder Strich-Symbol |
| `flipped` | named | `false` | bool | en | Polarität tauschen |
| `flipped-side` | named | `false` | bool | en, kebab | +/− unter statt über dem Symbol (nur `variant: "symbol"`, `current: "dc"`) |
| `..params` | sink | – | beliebige zap-Argumente (pos. und benannt) | en | an `zap.component` |

Validierung (einzige in physik mit Wertelisten), Meldungen **englisch**:
- Z. 29 "current must be ac or dc"
- Z. 30 "variant must be 'symbol' or 'lines'"

`simple-source` (Z. 94) – Alias

```typ
#let simple-source(name, node, ..params) = source(name, node, variant: "symbol", ..params)
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `name` | pos | – | str | en | |
| `node` | pos | – | zap-Koordinate | en | |
| `..params` | sink | – | alles, was `source` annimmt | en | |

Kompatibilitätsname aus physik 0.0.1; `variant: "symbol"` ist ohnehin Default, ein übergebenes `variant: "lines"` überschreibt es sogar (bestätigt) – der Alias ist also funktional identisch mit `source`.

`multimeter` (Z. 96), `lamp` (Z. 121), `amperemeter` (Z. 150), `voltmeter` (Z. 178), `motor` (Z. 206), `generator` (Z. 234) – identische Signatur:

```typ
#let multimeter(name, node, ..params) = {
#let lamp(name, node, ..params) = {
#let amperemeter(name, node, ..params) = {
#let voltmeter(name, node, ..params) = {
#let motor(name, node, ..params) = {
#let generator(name, node, ..params) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `name` | pos | – | str | en | Komponentenname |
| `node` | pos | – | zap-Koordinate | en | Knoten |
| `..params` | sink | – | zap-Argumente | en | an `zap.component` |

zap-Komponenten-IDs (Strings, erster Parameter von `zap.component`): `"source"`, `"multimeter"`, `"lamp"`, `"amperemeter"`, `"voltmeter"`, `"motor"`, `"generator"`. Style-Dictionaries: `source` → `(width: 1.0, height: 0.4, radius: 0.18)`; alle Rundsymbole → `(radius: .45, padding: .15)`. Strichstärke `.8pt`, Farbe `black`, Buchstabengröße `12pt` fest verdrahtet.

Sprachlich: `amperemeter` ist die deutsche Schreibweise (en `ammeter`), `lamp`/`source` englisch, `schaltkreis` deutsch.

---

### 1.5 `konstanten.typ`

Import: Z. 1 `fancy-units:0.1.1` (`qty, unit`).

`konstante` (Z. 18)

```typ
#let konstante(name, wert, einheit, symbol: none, beschreibung: none) = (
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `name` | pos | – | str | de/en | Name |
| `wert` | pos | – | str (wird zu float) | de | Zahlenwert |
| `einheit` | pos | – | content, str | de | Einheit |
| `symbol` | named | `none` | content, none | de/en | Formelzeichen |
| `beschreibung` | named | `none` | str, none | de | **wird verworfen** (nicht im Ergebnis) |

Rückgabe-Keys: `name`, `wert` (float), `symbol`, `einheit` (content), `mit-einheit` (content). Der Docstring Z. 47 nennt nur vier Felder (ohne `name`).

`pk` (Z. 48) – öffentliche Variable, Dictionary

| Schlüssel | Konstante | Schreibweise |
|---|---|---|
| `h` | Planck-Konstante | |
| `h_eV` | Planck-Konstante in eV | snake + camel; **nicht im Docstring** |
| `e` | Elementarladung | |
| `c` | Lichtgeschwindigkeit | |
| `g` | Erdbeschleunigung | |
| `G` | Gravitationskonstante | Groß/Klein unterscheidet `g`/`G` |
| `k_B` | Boltzmann-Konstante | snake |
| `N_A` | Avogadro-Konstante | snake |
| `R` | Gaskonstante | |
| `epsilon_0` | elektrische Feldkonstante | snake, en ausgeschrieben |
| `mu_0` | magnetische Feldkonstante | snake |
| `m.elektron`, `m.proton`, `m.neutron`, `m.u` | Massen | verschachtelt, de ausgeschrieben |
| `v.schall` | Schallgeschwindigkeit | verschachtelt, de |

---

## 2. messwerttabellen 0.0.1 (`lib.typ`)

`typst.toml`: name `messwerttabellen`, version `0.0.1`, Beschreibung "Package for messwerttabellen" (en/de-Mix), kein repository. README leer.

Importe: Z. 1 `@preview/unify:0.7.0: *` (in physik 0.0.2 durch fancy-units ersetzt), Z. 2 `zero:0.5.0`, Z. 3 `@schule/random:0.0.1: *`, Z. 165 `tablex:0.0.9`.

Öffentliche Namen: alles aus `unify` (`num`, `qty`, `unit`, `numrange`, `qtyrange` …), `znum`, alles aus `random` (inkl. `m`, `a`), dazu:

| Name | Zeile | Signatur (wörtlich) |
|---|---|---|
| `datensatz` | 6 | `#let datensatz(name, einheit, werte, prefix: "1", max-digits: none) = (` |
| `messdaten` | 14 | `#let messdaten(name, einheit, anzahl-messwerte, prefix: "1") = (` |
| `multiplikatoren` | 21 | Dictionary, nur `"G","M","k","","c","m","u","n","p"` |
| `umrechnungseinheit` | 34 | `#let umrechnungseinheit(wert, einheit) = {` |
| `count_decimal_places` | 45 | `#let count_decimal_places(wert) = {` |
| `lineare_regression` | 58 | `#let lineare_regression(x_werte, y_werte) = {` |
| `berechnung` | 88 | `#let berechnung(name, einheit, datensatz, formel, prefix: "1", auto-einheit: true, fehler: 0) = {` |
| `p_messwerttabelle` | 159 | `#let p_messwerttabelle(datensatze, row-height: auto, header: none, max-digits: 2) = [` |
| `messwerttabelle` | 224 | `#let messwerttabelle(datensatze, max_wert_pro_tabelle, row-height: auto, header: none, width: 100%, max-digits: 2) = {` |

### Parametertabellen

`datensatz` (Z. 6)

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `name` | pos | – | str | de/en | |
| `einheit` | pos | – | str, none | de | |
| `werte` | pos | – | array | de | |
| `prefix` | named | `"1"` | str | en | |
| `max-digits` | named | `none` | – | en | **angenommen, aber verworfen** (nicht im Ergebnis) |

`messdaten` (Z. 14): identisch zu physik 0.0.2.

`umrechnungseinheit` (Z. 34): `wert`, `einheit` positional; anderer Algorithmus als in physik (hängt Präfix einfach vor die Einheit, lokale Variable `umgerechneter_wert` Z. 37 unbenutzt).

`lineare_regression` (Z. 58)

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `x_werte` | pos | – | array von Zahlen | de, snake | x-Werte (kein Datensatz-Dictionary!) |
| `y_werte` | pos | – | array von Zahlen | de, snake | y-Werte |

Rückgabe nur `(m:, b:)` – kein `math`, kein `function`. Fehlermeldungen de: Z. 60 "x_werte und y_werte müssen die gleiche Länge haben", Z. 61 "Mindestens 2 Datenpunkte erforderlich". Kommentar Z. 83 ("Gleichung als Content zurückgeben") stimmt nicht.

`berechnung` (Z. 88)

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `name` | pos | – | str | de/en | |
| `einheit` | pos | – | str | de | |
| `datensatz` | pos | – | **ein** Dictionary (Singular; verdeckt die Funktion `datensatz`) | de | Eingabe |
| `formel` | pos | – | function mit 1 Argument | de | |
| `prefix` | named | `"1"` | str | en | |
| `auto-einheit` | named | `true` | bool | mix | |
| `fehler` | named | `0` | **Zahl in Prozent** (`fehler / 100`, Z. 130) | de | in physik 0.0.2 dagegen ratio |

Kein `max-digits`; Ergebnis setzt `max-digits: none` fest (Z. 154).

`messwerttabelle` (Z. 224)

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `datensatze` | pos | – | array von Datensätzen (zwingend Array) | de, Umlaut gestrichen | |
| `max_wert_pro_tabelle` | pos, **Pflicht** | – | int | de, snake | in physik 0.0.2 → `amount: auto` (named, en) |
| `row-height` | named | `auto` | | en | |
| `header` | named | `none` | | en | |
| `width` | named | `100%` | | en | |
| `max-digits` | named | `2` | | en | |

### Verhältnis zu physik

`messwerttabellen 0.0.1` ist der Vorläufer von `physik/0.0.2/messwerttabellen.typ` (und von `physik/0.0.1/lib.typ`, das Tabellen, eine `lineare_regression(x_werte, y_werte)` und ein Dictionary `regressionen` in einer Datei vereinte). Gleiche Namen, **inkompatible Signaturen**:

| Sache | messwerttabellen 0.0.1 | physik 0.0.1 | physik 0.0.2 |
|---|---|---|---|
| Aufruf Tabelle | `messwerttabelle(datensatze, max_wert_pro_tabelle, …)` | `messwerttabelle(datensatze, amount: auto, …)` | `messwerttabelle(..args, amount: auto, …)` |
| `berechnung` Eingabe | `datensatz` (einer) | `datensaetze` | `datensaetze` (1–5) |
| `fehler` | Prozentzahl | (wie 0.0.1) | ratio |
| `lineare_regression` | `(x_werte, y_werte)` → `(m, b)` | dito + `regressionen`-Dictionary | `(x_param, y_param, notation:, precision:)` → `(math, math-digits, m, b, function)` |
| Einheitensatz | unify | unify | fancy-units |
| `datensatz(max-digits:)` | verworfen | – | wirksam |
| `datensatz(auto-einheit:)` | – | – | vorhanden |
| Schaltkreis | – | `schaltkreis = zap.canvas`, `simple-source`, `multimeter` (zap 0.2.1) | `zap.circuit`, 8 Komponenten (zap 0.4.0) |

Benutzt wird messwerttabellen 0.0.1 nur noch von alten arbeitsblatt-Versionen (0.1.7, 0.1.8, 0.1.9, 0.2.0, 0.2.1, 0.2.2). arbeitsblatt 0.2.3 nutzt physik 0.0.1; ab 0.2.4 physik 0.0.2. Für 0.4.x ist das Paket reine Altlast.

---

## 3. energy-sketch 0.0.3 (`lib.typ`)

`typst.toml`: name `energy-sketch`, version `0.0.3`, `compiler = "0.12"`, `exclude = ["*.pdf", "example.typ"]`, Beschreibung **englisch** ("Energy level grid diagrams for physics and chemistry worksheets"), repository gesetzt. README deutsch.

Import: Z. 1 `@preview/cetz:0.5.2: canvas, draw` – beide Namen werden bei `import "@schule/energy-sketch:0.0.3": *` mit exportiert (`canvas`, `draw`); arbeitsblatt importiert energy-sketch mit `*` und danach `@preview/cetz:0.4.2: *`.

Einzige gewollt öffentliche Funktion:

`energy-sketch` (Z. 134)

```typ
#let energy-sketch(
  energy-name,
  hide-letters: false,
  height: 3cm,
  gap: 0pt,
) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `energy-name` | pos | – | **array** (nicht leer) von str/content/none | en, kebab, **Singular für ein Array** | Spaltenbeschriftungen |
| `hide-letters` | named | `false` | bool (geprüft) | en, Negativ-Schalter; "letters" meint Beschriftungen | Beschriftungen ausblenden (Linie bleibt) |
| `height` | named | `3cm` | length > 0pt (geprüft) | en | Höhe des Rasters (immer 10 Zeilen) |
| `gap` | named | `0pt` | length >= 0pt (geprüft) | en | Abstand zwischen Spalten |

Mit Unterstrich, aber durch `*` exportiert: `_energy-sketch-rows` (Z. 3, = 10), `_clamp-length(value, min: none, max: none)` (Z. 5), `_normalize-energy-names(energy-name)` (Z. 10), `_validate-energy-sketch-options(hide-letters, height, gap)` (Z. 16), `_resolve-layout(column-count, height, gap: 0pt, rows: _energy-sketch-rows)` (Z. 24), `_resolve-style(layout)` (Z. 49), `_column-geometry(layout, column-index)` (Z. 65), `_draw-column-grid`, `_draw-column-frame`, `_draw-column-label-line` (Z. 74/83/88, je `(layout, style, geometry)`), `_draw-column-label(layout, style, geometry, label)` (Z. 96), `_draw-energy-column(layout, style, column-index, label, hide-letters: false)` (Z. 109).

Interne Dictionary-Keys (alle en, kebab): Layout `column-count, rows, height, gap, column-span, total-width, vertical-step, bar-width, label-width, label-line-y, label-y, horizontal-margin`; Style `grid-stroke, border-stroke, baseline-stroke, label-size`; Geometrie `x-start, x-end, center-x`. `total-width` wird berechnet, aber nie gelesen. `rows` ist intern parametrierbar, in der öffentlichen Signatur nicht.

Validierung (Meldungen **deutsch**, Parameternamen englisch in Backticks):
- Z. 11 "`energy-name` muss ein Array sein."
- Z. 12 "`energy-name` darf nicht leer sein."
- Z. 17 "`hide-letters` muss ein bool sein."
- Z. 18 "`height` muss eine Länge sein."
- Z. 19 "`height` muss größer als 0pt sein."
- Z. 20 "`gap` muss eine Länge sein."
- Z. 21 "`gap` muss größer oder gleich 0pt sein."

Vorgänger: 0.0.1 `energy-sketch(energy-name, hide-letters: false, height: 3cm)` (cetz 0.3.1, `import ...: *`), 0.0.2 gleiche Signatur (cetz 0.3.1), 0.0.3 zusätzlich `gap`, cetz 0.5.2, saubere Struktur.

---

## 4. Validierung – Gesamtbild

| Ort | Was wird geprüft | Sprache der Meldung |
|---|---|---|
| physik/messwerttabellen.typ | nur Z. 308 (mehr als 5 Datensätze, `panic`) | de |
| physik/regressionen.typ | Datenmenge und numerische Vorbedingungen (Z. 169, 268, 307, 318, 370, 381, 448, 449, 461, 520, 549) | de |
| physik/schaltkreise.typ | `current`, `variant` (Z. 29, 30) | **en** |
| physik/konstanten.typ | nichts | – |
| messwerttabellen 0.0.1 | Z. 60, 61 | de |
| energy-sketch 0.0.3 | alle vier Parameter (Typ und Bereich) | de |

Nicht geprüft: `notation` (jeder andere String als `"sci"` gilt als `"dec"`), `prefix` (unbekannter String landet in `float("1" + prefix)` mit kryptischem Typst-Fehler oder wird bei Eingabe-Datensätzen still ignoriert, Z. 246–252), `fehler`-Typ, `amount`, Länge von `header`, Typ der Datensätze, benannte Argumente im Sink von `messwerttabelle`. Eine zentrale Optionsprüfung wie in arbeitsblatt/aufgaben (Commit 4e49bf7) gibt es in diesen Paketen nicht.

---

## 5. Inkonsistenzen (konkret)

### 5.1 Sprache und Schreibweise

1. Funktionsnamen der öffentlichen API in drei Stilen: snake_case de (`lineare_regression` regressionen.typ:205, `quadratische_regression` :251, `wurzel_regression` :305, `exponentielle_regression` :368, `potenz_regression` :445, `polynom_regression` :517), kebab-case en (`simple-source` schaltkreise.typ:94, `energy-sketch` lib.typ:134), einwortig de (`datensatz`, `messdaten`, `berechnung`, `messwerttabelle`, `schaltkreis`, `konstante`). Typst-Konvention und der Rest des Repos nutzen kebab-case.
2. Hilfsfunktionen: `auto_einheit_anwenden` (messwerttabellen.typ:146, de snake), `count_decimal_places` (:181, en snake), `umrechnungseinheit` (:78, de), `format-number`/`combine-units`/`build-equation` (regressionen.typ:4/46/103, en kebab), `p_messwerttabelle` (:398, Präfix `p_`), `_kopf-einheit` (:386, Präfix `_`). Drei verschiedene "privat"-Konventionen (kein Präfix, `p_`, `_`).
3. de/en-Mischung innerhalb einer Signatur:
   - messwerttabellen.typ:19 `datensatz(name, einheit, werte, prefix:, max-digits:, auto-einheit:)` – de positional, en benannt, plus Hybrid `auto-einheit`.
   - messwerttabellen.typ:212 `berechnung(…, datensaetze, formel, prefix:, auto-einheit:, fehler:, max-digits:)`.
   - messwerttabellen.typ:501 `messwerttabelle(..args, amount:, row-height:, header:, width:, max-digits:)` – deutscher Funktionsname, ausschließlich englische Parameter.
   - regressionen.typ:148 `regression(x_param, y_param, algorithmus, format-function, koeffizienten-namen:, min-punkte:, notation:, precision:)`.
   - regressionen.typ:46 `combine-units(y_einheit, x_einheit, x_potenz:)`; :71 `format-equation-term(koeff, koeff-einheit, x-name, x-potenz, is-first, notation, precision, digits:)`.
   - regressionen.typ:517 `polynom_regression(x_param, y_param, grad, notation:, precision:)`.
4. snake_case und kebab-case für dieselbe Sache: `x_potenz` (regressionen.typ:46) vs. `x-potenz` (:71); `x_name`/`y_name` (:172, :225) vs. `x-name`/`y-name` (:71, :103, :118); `x_einheit` (:46) vs. `koeff-einheit` (:71); `max-digits` (Parameter) vs. `datensatz_max_digits` (messwerttabellen.typ:456); `min-wert` (:153) neben `neue_einheit`, `wert_in_basis` in derselben Funktion.
5. Umlaute: `datensaetze` (messwerttabellen.typ:212, `ae`) vs. `datensatze` (:399, :503, Umlaut gestrichen). In messwerttabellen 0.0.1 heißt der Parameter `datensatz` (:88) bzw. `datensatze` (:224).
6. Abkürzungen ohne System: `koeff`, `koeffs`, `koeffizienten`, `koeffizienten-namen`, `koeff_namen` (regressionen.typ:71, 118, 171, 148, 606); `pk` (konstanten.typ:48); `x_param` (heißt in 0.0.1 `x_werte`).
7. `pk`-Schlüssel mischen `_` (`k_B`, `N_A`, `h_eV`, `epsilon_0`, `mu_0`), kebab im Ergebnis (`mit-einheit`) und verschachtelte deutsche Wörter (`m.elektron`, `v.schall`). `m` und `v` sind Gruppen, alle anderen Einbuchstaben-Keys sind Konstanten (konstanten.typ:50–73).
8. Fehlermeldungen: de in messwerttabellen/regressionen/energy-sketch, **en** in schaltkreise.typ:29–30.
9. Paketnamen: `physik`, `messwerttabellen` (de) vs. `energy-sketch` (en); `typst.toml`-Beschreibung de (physik 0.0.2), en (energy-sketch), Mischmasch (messwerttabellen).
10. Schaltkreis-Komponenten: `schaltkreis` de, `source`/`lamp`/`motor`/`generator` en, `amperemeter` de-Schreibweise – innerhalb eines Aufrufs `schaltkreis({ source(...); amperemeter(...) })`.

### 5.2 Dieselbe Sache, verschieden benannt

11. Nachkommastellen: `max-digits` (messwerttabellen.typ:19, 212, 400, 501) vs. `digits` (regressionen.typ:4, 71, 118, `math-digits`) vs. `precision` in `znum(round: (precision: …))` (:477). Zugleich bedeutet `precision` in den Regressionen (:148, 205 …) etwas ganz anderes (Nullschwelle für Terme).
12. Anzahl: `anzahl-messwerte` (messwerttabellen.typ:45), `amount` (:501), `max_wert_pro_tabelle` (messwerttabellen 0.0.1:224), `min-punkte` (regressionen.typ:148), `grad` – "Messwerte", "Werte", "Punkte", "Paare" (`gueltige_paare` :160) für dieselben Einträge.
13. Daten-Argument: `werte` (datensatz), `datensaetze` (berechnung), `datensatze` (p_messwerttabelle), `..args` (messwerttabelle), `x_param`/`y_param` (Regressionen), `x_werte`/`y_werte` (0.0.1).
14. Koeffizienten-Benennung je Regression anders und teils widersprüchlich: linear `m, b`; quadratisch `a, b, c`; Wurzel `a, b`; exponentiell `a` = Exponent, `b` = Vorfaktor; Potenz `a` = Vorfaktor, `m` = Exponent; Polynom `c0…cn` aufsteigend, während quadratisch absteigend benennt (regressionen.typ:237, 290, 353, 430, 499, 606). `m` heißt einmal Steigung, einmal Exponent. `polynom_regression(…, 2).c2` entspricht `quadratische_regression(…).a`.
15. Ergebnis-Keys `math`, `math-digits`, `function` sind englisch, die Funktionen und Datensatz-Keys (`werte`, `einheit`) deutsch.
16. Zeilenhöhe `row-height` (messwerttabelle) vs. `height` (energy-sketch) – verschiedene Dinge, aber kein gemeinsames Schema für Maße; `width: 100%` nur bei `messwerttabelle`.
17. Beschriftung: `name` (datensatz, Komponenten), `energy-name` (energy-sketch, obwohl Array), `header` (messwerttabelle), intern `label` (energy-sketch lib.typ:96), `hide-letters` meint dieselben Labels.

### 5.3 Schalter-Typen, Sentinels, Defaults

18. `prefix: "1"` als Sentinel für "kein Präfix" (messwerttabellen.typ:19, 45, 212) statt `none`/`auto`; gleichzeitig ist `""` der Schlüssel für Faktor 1 in `multiplikatoren` (:63). Dritte Kodierung: `"e14"` für Zehnerpotenzen (:247, :317, :390). Vierte: beliebiger String → `float("1" + prefix)` (:322), nur beim Ziel, nicht bei Eingaben.
19. `auto-einheit` Default `false` in `datensatz` (:19), `true` in `berechnung` (:212).
20. `max-digits` Default `none` (datensatz, berechnung) vs. `2` (messwerttabelle, p_messwerttabelle); `digits: 2` (Regressionen) ist dagegen `znum(digits:)` und nicht dasselbe Rundungsverfahren wie `round: (mode: "places")`.
21. `fehler: 0` – Default ist int, erwartet wird ratio (`fehler/1%`, :343); in messwerttabellen 0.0.1:130 Prozentzahl. `fehler: 5` wirft in 0.0.2 "cannot divide integer by ratio" (**bestätigt**).
22. `amount: auto` (auto = alle Spalten) vs. `header: none` (none = keine) vs. `max-digits: none` (none = erben) – drei Bedeutungen für "nicht gesetzt".
23. Positiv/Negativ: `hide-letters` (energy-sketch lib.typ:136) ist ein Negativ-Schalter; `flipped`/`flipped-side` (schaltkreise.typ:28) sind zwei Bools, wobei `flipped-side` nicht "Seite gespiegelt", sondern "Zeichen unten" bedeutet; `auto-einheit` ist Positiv-Schalter.
24. String-Enums nur englische Kürzel (`"dc"/"ac"`, `"symbol"/"lines"`, `"dec"/"sci"`), während arbeitsblatt/aufgaben deutsche Enum-Werte nutzen (z. B. `"kariert"`).
25. positional vs. named uneinheitlich: `notation`, `precision` sind in `format-equation-term` (:71) und `format-simple-equation` (:118) positional, in `regression` und allen öffentlichen Regressionen named; `grad` positional (:517); `max_wert_pro_tabelle` positional (0.0.1) → `amount` named (0.0.2); `anzahl-messwerte` positional mit kebab-Namen.
26. Singular/Plural: `energy-name` für ein Array (lib.typ:135, intern sofort `energy-names` :140); `datensatz` als Parametername für ein Dictionary in 0.0.1:88 vs. `datensaetze` in 0.0.2; Dateiname `messwerttabellen.typ`/`regressionen.typ`/`schaltkreise.typ` Plural, Funktionen Singular.
27. Eingabeformen von `messwerttabelle`: drei Varianten (einzeln, Array, mehrere) Z. 505–520; `berechnung` nimmt Dictionary oder Array, aber keinen Sink.

### 5.4 Doppelungen

28. Präfixtabelle doppelt: `multiplikatoren` (messwerttabellen.typ:52–75) und `prefix_liste` (:107–130).
29. Präfix-Erkennung dreifach implementiert: `umrechnungseinheit` :93–101, `berechnung` Eingabe :257–264, `berechnung` Ziel :328–335.
30. Auto-Einheit doppelt: `auto_einheit_anwenden` (:146–178) und fast wortgleich in `berechnung` Schritt 5 (:348–374).
31. Sechs praktisch identische Rundsymbol-Komponenten (schaltkreise.typ:96–254), nur Buchstabe/ID verschieden; `amperemeter`, `voltmeter`, `motor`, `generator` unterscheiden sich um ein Zeichen.
32. `format-func` in jeder Regression mit identischem Bedingungskopf `x_einheit != none and x_einheit != "" and …` (:226, 278, 327, 398, 472, 564); der einheitenlose Polynomzweig (:572–602) dupliziert `format-simple-equation`.
33. `simple-source` ist Alias von `source` (schaltkreise.typ:94).
34. `messwerttabellen 0.0.1` dupliziert physik (siehe Abschnitt 2); `physik 0.0.1` liegt ebenfalls noch im Repo.
35. `quadratische_regression` ist Spezialfall von `polynom_regression(…, 2)` mit anderer Koeffizientenbenennung und eigenem Löser (Cramer statt Gauß).

---

## 6. Kopplungen

### 6.1 Wer importiert was

| Importeur | Import | Bemerkung |
|---|---|---|
| `arbeitsblatt/0.4.0/src/arbeitsblatt.typ:10–36` (ebenso 0.2.4, 0.3.0, 0.3.1, 0.3.2) | `@schule/physik:0.0.2`: `berechnung, datensatz, messdaten, messwerttabelle, pk, lineare_regression, quadratische_regression, wurzel_regression, exponentielle_regression, polynom_regression, potenz_regression, schaltkreis, zap, source, simple-source, multimeter, lamp, amperemeter, voltmeter, motor, generator` | explizite Liste; `konstante`, `umrechnungseinheit`, `multiplikatoren` fehlen darin. Reine Weiterreichung an Arbeitsblatt-Nutzer, keine Parameter-Durchreichung |
| `arbeitsblatt/0.4.0/src/arbeitsblatt.typ:4` | `@schule/energy-sketch:0.0.2: *` | **veraltet** – 0.0.3 (mit `gap`, cetz 0.5.2) existiert; 0.0.2 zieht cetz 0.3.1 nach, arbeitsblatt selbst importiert Z. 40 `cetz:0.4.2: *` (drei cetz-Versionen im Spiel: 0.3.1, 0.4.2, 0.5.2) |
| `mathematik/0.0.2/mathematik.typ:2` | `@schule/physik:0.0.2: umrechnungseinheit` | benutzt Z. 636–645 für `graphen` mit Datensätzen; liest außerdem die Datensatz-Keys `name`, `einheit`, `prefix`, `werte` (Z. 568–654). Rückrichtung: arbeitsblatt importiert aus mathematik `graphen` |
| `mathematik/0.0.2/docs/content.typ:208, 219` | `@schule/physik:0.0.2: datensatz` | Doku |
| `arbeitsblatt/0.2.3` | `@schule/physik:0.0.1` (`…, regressionen, zap, schaltkreis, multimeter, simple-source`) | alt |
| `arbeitsblatt/0.1.7–0.2.2` | `@schule/messwerttabellen:0.0.1` | alt |
| `arbeitsblatt/0.1.0–0.1.9` | `@schule/energy-sketch:0.0.1`; 0.2.0–0.4.0 → `0.0.2` | alt |

### 6.2 Was physik selbst importiert

| Datei | Import | Bemerkung |
|---|---|---|
| messwerttabellen.typ:3 | `@schule/random:0.0.1: *` | gebraucht wird nur `rand(seed)` (Z. 343); der Stern exportiert `m`, `a`, `default_seed` usw. weiter. arbeitsblatt importiert random ebenfalls mit `*` |
| lib.typ:1, schaltkreise.typ:1 | `@preview/zap:0.4.0` | doppelt importiert |
| messwerttabellen.typ:1, regressionen.typ:2, konstanten.typ:1 | `@preview/fancy-units:0.1.1` | |
| messwerttabellen.typ:2, regressionen.typ:1 | `@preview/zero:0.5.0` | arbeitsblatt importiert `zero:0.5.0: *` zusätzlich selbst |
| messwerttabellen.typ:404 | `@preview/tablex:0.0.9` | veraltetes Paket |

### 6.3 Implizite Schnittstellen (ohne Import, aber vertraglich)

- Datensatz-Dictionary (`name`, `einheit`, `prefix`, `werte`, `auto-einheit`, `max-digits`) ist die Schnittstelle zwischen `datensatz`/`berechnung`, `messwerttabelle`, allen Regressionen (`extract-data`, regressionen.typ:149–155 prüft auf den Key `werte`) und `mathematik.graphen`. Eine Umbenennung der Keys trifft alle vier.
- Regressions-Ergebnis (`function`, `math`, Koeffizienten) wird typischerweise an Plot-Funktionen in mathematik/arbeitsblatt weitergegeben.
- Keine Anbindung an Themes/Optionen von arbeitsblatt (Farben, Strichstärken, Schrift fest verdrahtet); keine States, keine Labels, keine Queries in den drei Paketen.

---

## 7. Fehler und Altlasten

### 7.1 Fehler (mit typst 0.15.1 bestätigt, sofern markiert)

1. **bestätigt** – `berechnung` bricht bei leeren Werten ab: `none` wird in Z. 293 eingefügt, Z. 338 teilt dann `none / ziel_multiplikator` → "cannot divide none by integer". Der Leere-Zellen-Pfad (Z. 284–293, 351, 366) ist damit unerreichbar. Auch `messdaten` → `berechnung` scheitert ("cannot divide string by integer"), weil `""` weder `none` noch content ist.
2. **bestätigt** – Präfix-Erkennung ohne Einheitenkenntnis (Z. 257–264, 328–335, 93–101): jede String-Einheit mit mehr als einem Zeichen, die mit einem Präfixbuchstaben beginnt, wird skaliert. `"m/s"` → Faktor 1e-3, `"mol"` → 1e-3, `"Pa"` → 1e15 (Peta), ebenso `"min"`, `"cd"`, `"Gy"`, `"ft"`. Nur `"kg"` ist ausgenommen. Der Docstring Z. 201 ("Einheiten mit `/` … werden nicht skaliert") trifft nur auf die Auto-Einheit zu, nicht auf die Eingabe-Umrechnung.
3. **bestätigt** – `datensatz("m", "kg", …, auto-einheit: true)` ergibt die Einheit `"mkg"`: `umrechnungseinheit` nimmt `kg` als Basis und hängt ein Präfix davor (Z. 93, 135).
4. **bestätigt** – `format-simple-equation` (regressionen.typ:118–146) verliert das Vorzeichen des führenden Koeffizienten (`calc.abs` Z. 119, kein Minus beim ersten Term) und ignoriert `y-name` und den Koeffizienten-1-Fall. `lineare_regression((1,2,3), (-2,-4.1,-6)).math` zeigt "y = 2x − 0,03". Betrifft alle einheitenlosen Aufrufe von `lineare_regression` und `quadratische_regression`.
5. **bestätigt** – `fehler: 5` (Schreibweise aus 0.0.1) wirft in 0.0.2 einen Typfehler (Z. 343); Default `0` ist selbst kein ratio.
6. **bestätigt** – `header` mit mehr Einträgen als Wertespalten zerschießt die Tabelle (Z. 424–429 füllt nur auf, kürzt nicht). Bei geteilten Tabellen (`amount`) bekommt jede Teiltabelle denselben Header.
7. **bestätigt** – `add-macros` (messwerttabellen.typ:5–8) wirkungslos; `"ohm"` wird wörtlich gesetzt, mit Präfix `"kohm"`.
8. `wurzel_regression`/`exponentielle_regression` formatieren `a` mit Vorzeichen, aber ohne Sonderfall für negatives `a` im Einheitenzweig (Z. 324, 338); `exponentielle_regression` prüft `a ≈ 1` ohne Betrag, `a ≈ −1` wird ausgeschrieben – uneinheitlich zu `format-equation-term`.
9. `format-equation-term`: führender Term in `lineare_regression`/`quadratische_regression` bekommt fest die Schwelle `1e-20` statt `precision` (Z. 228, 280), in `polynom_regression` dagegen `precision` (Z. 568).
10. `lineare_regression`: keine Prüfung auf `den == 0` (Z. 221) – identische x-Werte geben einen rohen Divisionsfehler statt einer Meldung wie bei den anderen Regressionen.
11. `messwerttabelle`: Chunk-Berechnung nutzt `datensatze.at(0)` für `amount: auto` **vor** dem Auffüllen auf die Maximallänge (Z. 541 vs. 549–553); ist der erste Datensatz kürzer als ein späterer, wird unnötig geteilt. `max-key` (Z. 540, 545) wird nie gelesen. Beim Zerlegen (Z. 556) geht `auto-einheit` verloren (unkritisch, weil vorher angewendet).
12. Docstring-Verrutscher schaltkreise.typ:85–94: der Kommentar "Zeichnet ein Multimeter …" steht über `simple-source`; `multimeter` (Z. 96) hat keinen Docstring.
13. `konstante(beschreibung:)` wird angenommen und verworfen (konstanten.typ:18–24); `pk.h_eV` fehlt im Docstring.
14. mathematik 0.0.2 Z. 641/645 ruft `umrechnungseinheit(1, x-ds.prefix)` mit einem Präfix statt einer Einheit auf; für einbuchstabige Präfixe liefert die Funktion `(1.0, "k")` (bestätigt), für `umrechnungseinheit(1, "mA")` ebenfalls Faktor 1.0 – die Kopplung liefert also nicht den erwarteten Multiplikator. Gehört zum mathematik-Inventar, hängt aber an der physik-Signatur.

### 7.2 Toter und überflüssiger Code

- `count_decimal_places` (messwerttabellen.typ:181) – in 0.0.2 unbenutzt.
- `is-first` (regressionen.typ:71), `y-name` in `format-simple-equation` (:118), `precision`-Parameter in den `format-func` von Wurzel/Exponential/Potenz teils unbenutzt.
- `max-key` (messwerttabellen.typ:540), `total-width` (energy-sketch lib.typ:39), `umgerechneter_wert` (messwerttabellen 0.0.1:37), `digits` (messwerttabellen 0.0.1:145).
- Kommentare "Debug: …" (messwerttabellen.typ:79, 363), "Temporär speichern" (:31), "Rückwärtskompatibilität" (:232), Tippfehler "Componant call" (schaltkreise.typ, 7×), "New component style" (7×).
- `physik/0.0.2/README.md` und `messwerttabellen/0.0.1/README.md` sind leer (0 Byte).
- `energy-sketch/0.0.3/example.pdf` liegt im Paketordner (per `exclude` vom Paket ausgenommen).
- Ganze Pakete als Altlast: `messwerttabellen/0.0.1`, `physik/0.0.1`, `energy-sketch/0.0.1`, `energy-sketch/0.0.2` (letztere noch von arbeitsblatt 0.4.0 importiert).
- Keine `.orig`-Dateien in den drei Paketordnern (die im Git-Status genannte `aufgaben/0.3.1/aufgaben.typ.orig` gehört zu einem anderen Paket).

---

## 8. Entscheidungspunkte für den Umbenennungsplan (aus dem Befund abgeleitet)

1. Exportfläche von physik begrenzen: Unterdateien gezielt statt per `*` importieren, damit `m`, `a`, `unit`, `qty`, `znum`, `rand` … nicht mehr durchgereicht werden; interne Helfer einheitlich mit `_`.
2. Eine Schreibweise für Funktionsnamen (kebab-case): `lineare_regression` → `lineare-regression` usw.; alte Namen ggf. als Aliase für eine Übergangsversion.
3. Eine Sprache je Ebene festlegen: derzeit deutsche Funktionsnamen und Datensatz-Keys mit englischen Layout-Parametern (`amount`, `row-height`, `header`, `width`, `max-digits`, `prefix`, `notation`, `precision`, `digits`) und englischen Ergebnis-Keys (`math`, `function`).
4. Begriffe zusammenführen: Nachkommastellen (`max-digits`/`digits`), Schwelle (`precision`), Anzahl (`amount`/`anzahl-messwerte`/`min-punkte`), Daten-Argument (`werte`/`datensaetze`/`datensatze`/`x_param`).
5. Sentinels vereinheitlichen: `prefix: "1"` → `none`/`auto`; `fehler` als ratio mit Default `0%`; `auto`/`none`-Semantik festlegen.
6. Koeffizienten-Schema der Regressionen vereinheitlichen (Reihenfolge und Buchstaben).
7. Schaltkreis-Komponenten: Sprache festlegen (zap-nah englisch oder deutsch), `simple-source` streichen, Rundsymbole über eine gemeinsame Fabrik.
8. `energy-sketch`: `energy-name` (Array, Singular) und `hide-letters` (Negativ-Schalter, "letters") umbenennen; arbeitsblatt auf 0.0.3 heben oder Paket in physik aufnehmen.
9. `messwerttabellen 0.0.1` und `physik 0.0.1` als abgelöst kennzeichnen.
10. Fehler aus 7.1 (insbesondere 1, 2, 4) vor oder mit der Umbenennung beheben, da sie die Signaturen (`prefix`, `einheit`-Parsing) berühren.
