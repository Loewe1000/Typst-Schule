# Inventar: informatik 0.0.2, operatoren 0.0.1, patterns 0.0.2 (+ Diff zu 0.0.1), insert-a-word 0.0.3, random 0.0.1

Stand: 2026-11-14, Repo `/Users/alexander/Library/Application Support/typst/packages/schule` (nur gelesen).
Alle Dateien vollständig gelesen. Mit `typst 0.15.1` wurden einige Verhaltensfragen in einem Scratch-Verzeichnis
nachgeprüft (im Text als "getestet" markiert).

Legende Spalte **Art**: pos = positional (Pflicht), named = benannt mit Default, sink = `..args`.
Legende **Sprache**: de / en / gemischt / Abk. Schreibweise, wenn nicht kebab-case, steht dabei.

---

## 0. Übersicht

| Paket | Version | Entrypoint | Zeilen | öffentliche Namen | Namenssprache | Docstrings | README |
|---|---|---|---|---|---|---|---|
| informatik | 0.0.2 | `lib.typ` | 686 | 12 eigene + 6 Re-Exporte aus `@preview/blockst:0.1.0` | gemischt (de-Funktionen mit Umlaut, en-Funktionen, en-Parameter, de-Parameter) | ja (tidy-Stil, deutsch) | vorhanden, aber kaputt/veraltet |
| operatoren | 0.0.1 | `operatoren.typ` | 99 | 4 (2 Funktionen, 2 States) | gemischt (de-Funktionen, `fach` de, `language`/`text`/`bold` en) | ja | leer (0 Byte) |
| patterns | 0.0.2 | `patterns.typ` | 231 | 4 | gemischt (Paketname en, Funktionen de, Parameter en) | ja | leer |
| patterns | 0.0.1 | `patterns.typ` | 118 | 2 | wie oben | nein | leer |
| insert-a-word | 0.0.3 | `lib.typ` | 152 | 9 eigene + 11 Re-Exporte aus `@schule/random` | en, eine de-Ausnahme (`iaword-neu`) | ja | leer |
| random | 0.0.1 | `random.typ` | 59 | 11 | en, snake_case | nein (nur `//`-Kommentare, englisch) | leer |

`typst.toml`-Auffälligkeiten:

| Paket | description | repository | compiler | exclude |
|---|---|---|---|---|
| informatik 0.0.2 | deutscher Satz (ok) | ja | – | – |
| operatoren 0.0.1 | Platzhalter "Package for operatoren" | ja | – | – |
| patterns 0.0.1 | Platzhalter "Package for patterns" | **fehlt** | – | – |
| patterns 0.0.2 | Platzhalter "Package for patterns" | ja | – | – |
| insert-a-word 0.0.3 | Platzhalter "Package for insert-a-word" | ja | `0.12.0` (einziges Paket hier mit compiler-Angabe) | `["*.pdf", "example.typ"]` |
| random 0.0.1 | Platzhalter "Package for random" | **fehlt** | – | – |

---

## 1. informatik 0.0.2 — `informatik/0.0.2/lib.typ`

### 1.1 Importe / Re-Exporte

| Zeile | Import | Bemerkung |
|---|---|---|
| 5 | `#import "@preview/blockst:0.1.0": blockst, scratch, set-blockst, blockst-run-options, set-scratch-run, scratch-run` | Top-Level-Import, wird also von `lib.typ` re-exportiert. |
| 97 | `import "@preview/cetz:0.4.2": canvas, draw` (lokal in `häufigkeitsanalyse`) | |
| 98 | `import "@preview/cetz-plot:0.1.3": chart` (lokal) | |

Re-exportierte Namen (Z. 5): `blockst`, `scratch`, `set-blockst`, `blockst-run-options`, `set-scratch-run`, `scratch-run`.

**Widerspruch Kopfkommentar (Z. 1–3) zu Z. 5:** Der Kommentar nennt als Quelle `@schule/blockst:0.0.1` und als Namen
`blockst`, `blockst-run`, `scratch`, `set-blockst`, `set-scratch`, `set-blockst-run`, `executable`.
Tatsächlich importiert wird `@preview/blockst:0.1.0` mit `blockst-run-options`, `set-scratch-run`, `scratch-run`.
`blockst-run`, `set-scratch`, `set-blockst-run`, `executable` gibt es in 0.0.2 nicht.
Im Repo liegen `blockst/0.0.1`, `0.0.2`, `0.3.0`, `0.4.0`, `0.4.1` (Namensraum `@schule`); `@preview/blockst:0.1.0` ist gegenüber 0.4.x veraltet.
Z. 4 `// tidy-ignore` steht zwischen Docstring und Import.

### 1.2 Öffentliche Namen (Top-Level `#let`)

| Zeile | Name | Art | Sprache/Schreibweise |
|---|---|---|---|
| 15 | `bin2dec(zahl)` | Funktion | en-Abk. mit Ziffer (`2`), Parameter de |
| 36 | `dec2bin(zahl)` | Funktion | wie oben |
| 65 | `häufigkeitsanalyse(text)` | Funktion | de, **Umlaut ä** |
| 140 | `häufigkeitsanalyse-alt(text, rel: false, cetz: true)` | Funktion (Legacy) | de + Suffix `-alt`, Parameter Abk. |
| 169 | `caesar(key: none, keyword: none, advanced: false)` | Funktion (liefert Funktion oder Dict) | Eigenname, Parameter en |
| 314 | `mono(body)` | Funktion | en, sehr generischer Name |
| 331 | `vigenere(keyword, advanced: false)` | Funktion | Eigenname ohne Akzent (`vigenere`, nicht `vigenère`) |
| 420 | `rot13` | Variable (= `caesar(key: 13)`, also Funktion) | Abk. |
| 435 | `text-to-blocks(text, block-size: 5)` | Funktion | en |
| 472 | `atbash(advanced: false)` | Funktion | Eigenname |
| 524 | `hex2dec(hex)` | Funktion | en-Abk., Parameter en |
| 548 | `dec2hex(num)` | Funktion | en-Abk., Parameter en-Abk. |
| 579 | `ascii-table(ranges: (("a", "z"),), height: 5, variants: ("char", "dec"), colored: true)` | Funktion | en |

Keine States, keine Labels, keine privaten Top-Level-Namen (`_…`).

### 1.3 Signaturen im Detail

#### `bin2dec(zahl)` — Z. 15
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `zahl` | pos | – | str oder int (wird mit `str()` gewandelt) | de | Binärzahl, z. B. `"1010"` oder `1010` |

Rückgabe: int. Keine Validierung: alle Zeichen außer `"1"` zählen stillschweigend als 0 (getestet: `bin2dec("10x2")` läuft durch).

#### `dec2bin(zahl)` — Z. 36
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `zahl` | pos | – | int (≥ 0; `int(zahl)`) | de | Dezimalzahl |

Rückgabe: str. Negative Zahlen liefern `""` (keine Prüfung).

#### `häufigkeitsanalyse(text)` — Z. 65
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `text` | pos | – | str | en/de identisch (überdeckt builtin `text`) | zu analysierender Text |

Rückgabe-Dictionary (Z. 125–131), Schlüssel:

| Schlüssel | Typ | Sprache | Bedeutung |
|---|---|---|---|
| `absolut` | dict A–Z → int | de | absolute Häufigkeiten |
| `relativ` | dict A–Z → float (Prozent, 0–100) | de | relative Häufigkeiten |
| `data` | array `(([A], wert), …)` | **en** | Daten für cetz-plot (relative Werte) |
| `diagramm` | content | de | Säulendiagramm (fest: `size: (11, 4)`, Farbe `#008000`, `length: 1cm`) |
| `text` | str | en/de | Eingabetext |

Nur A–Z werden gezählt (Umlaute, ß fallen weg). Diagrammgröße/-farbe nicht konfigurierbar.

#### `häufigkeitsanalyse-alt(text, rel: false, cetz: true)` — Z. 140
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `text` | pos | – | str | – | Text |
| `rel` | named | `false` | bool | Abk. (en/de) | relative statt absolute Häufigkeiten (nur wenn `cetz: false`) |
| `cetz` | named | `true` | bool | Eigenname (Bibliothek als Schaltername) | `true`: Array für CeTZ, sonst Dict |

Legacy-Wrapper. Rückgabetyp wechselt je nach Schalter (array / dictionary).

#### `caesar(key: none, keyword: none, advanced: false)` — Z. 169
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `key` | named | `none` | int / none (`int(key)`, mod 26) | en | Verschiebung |
| `keyword` | named | `none` | str / none | en | Schlüsselwort; hat Vorrang vor `key` |
| `advanced` | named | `false` | bool | en | `true`: Dict statt Funktion zurückgeben |

Rückgabe einfach (`advanced: false`): Funktion `simple-function(..args)` (Z. 278):
- 0 Positionsargumente → Schlüsseltabelle (content)
- 1 Argument → verschlüsseln
- 2 Argumente und zweites `== true` → entschlüsseln (**positionaler Bool** als Modus-Schalter)
- benannte Argumente werden eingesammelt (`named-args`, Z. 280) und nie benutzt; getestet: `caesar(key: 3)("abc", decode: true)` verschlüsselt stillschweigend.

Rückgabe erweitert (`advanced: true`), Dict (Z. 299–307):

| Schlüssel | Typ | Sprache |
|---|---|---|
| `encode` | function(klartext) | en |
| `decode` | function(geheimtext) | en |
| `table` | content (kein Funktionsaufruf) | en |
| `key` | Durchreichung | en |
| `keyword` | Durchreichung (Original, nicht bereinigt) | en |
| `alphabet` | str | en/de |
| `geheimtext-alphabet` | str | **de** |

Tabellenkopf-Kürzel fest im Code: `*KA*` (Klartextalphabet), `*GA*` (Geheimtextalphabet) (Z. 263–264).
Fehler: `panic("Entweder 'key' oder 'keyword' muss angegeben werden!")` (Z. 226, deutsch).

#### `mono(body)` — Z. 314
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `body` | pos | – | content | en | Inhalt in "SF Mono" |

Schrift fest verdrahtet (`"SF Mono"`, nur macOS), keine Ausweichschrift, kein Parameter.

#### `vigenere(keyword, advanced: false)` — Z. 331
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `keyword` | **pos** | – | str | en | Schlüsselwort (nur A–Z bleiben) |
| `advanced` | named | `false` | bool | en | Dict statt Funktion |

Einfache Rückgabe: Funktion; 0 Argumente → `panic("Mindestens ein Text-Argument erforderlich!")` (Z. 389); 2. Argument `true` → entschlüsseln.
Erweitert: Dict `(encode, decode, keyword)` — hier ist `keyword` das **bereinigte** Schlüsselwort (bei `caesar` das Original).
Fehler: `panic("Schlüsselwort muss mindestens einen Buchstaben enthalten!")` (Z. 336).

#### `rot13` — Z. 420
Variable, `caesar(key: 13)`; Aufruf `rot13("Hallo")`, `rot13()` liefert die Tabelle.

#### `text-to-blocks(text, block-size: 5)` — Z. 435
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `text` | pos | – | str | – | Text (nur A–Z, a–z bleiben) |
| `block-size` | named | `5` | int | en | Zeichen je Block |

Rückgabe laut Docstring `content`, tatsächlich `str` (`blocks.join(" ")`).

#### `atbash(advanced: false)` — Z. 472
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `advanced` | named | `false` | bool | en | Dict `(encode, decode)` statt Funktion |

Muss immer erst aufgerufen werden: `atbash()("HALLO")` — im Gegensatz zu `rot13("…")`.
Fehler: `panic("Mindestens ein Text-Argument erforderlich!")` (Z. 497).

#### `hex2dec(hex)` — Z. 524
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `hex` | pos | – | str (oder int, `str(hex)`) | en-Abk. | Hexadezimalstring |

Ungültige Zeichen werden stillschweigend übersprungen (getestet `hex2dec("zz")` → 0).

#### `dec2hex(num)` — Z. 548
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `num` | pos | – | int ≥ 0 | en-Abk. | Dezimalzahl |

#### `ascii-table(ranges: (("a", "z"),), height: 5, variants: ("char", "dec"), colored: true)` — Z. 579
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `ranges` | named | `(("a", "z"),)` | array aus str (Einzelzeichen) oder 2er-Arrays `(start, end)` | en | Zeichenbereiche |
| `height` | named | `5` | **int** (Zeilenzahl, keine Länge!) | en | Zeilen je Spaltenblock |
| `variants` | named | `("char", "dec")` | array aus String-Enum `"char"`, `"dec"`, `"bin"`, `"hex"` | en | anzuzeigende Spalten |
| `colored` | named | `true` | bool | en | farbige vs. graue Spaltenhintergründe |

String-Enum `variants` → fest verdrahtete deutsche Spaltenköpfe: `"char"`→"Zeichen", `"dec"`→"Dezimal", `"bin"`→"Binär", `"hex"`→"Hex"; unbekannter Wert → `upper(variant)` als Kopf und `[?]` als Zelle (keine Fehlermeldung, Z. 630–632, 662–664).
Ungültige `ranges`-Einträge (weder str noch 2er-Array) werden stillschweigend ignoriert (Z. 583–591).
Farbpalette (10 Farben) und Graupalette (4) fest im Code (Z. 598–616).

### 1.4 Validierung / Fehlermeldungen (informatik)

| Zeile | Meldung | Sprache |
|---|---|---|
| 226 | `Entweder 'key' oder 'keyword' muss angegeben werden!` | de (nennt en-Parameternamen) |
| 336 | `Schlüsselwort muss mindestens einen Buchstaben enthalten!` | de |
| 389, 497 | `Mindestens ein Text-Argument erforderlich!` | de |

Keine Prüfung unbekannter Optionen; alle Meldungen per `panic`, ohne Funktionsnamen-Präfix (anders als z. B. `klausurbögen: …` in klausurboegen 0.0.5).

### 1.5 Inkonsistenzen (informatik)

1. **Gleiche Sache, drei Parameternamen:** `bin2dec(zahl)` Z. 15 / `dec2bin(zahl)` Z. 36 (de) vs. `hex2dec(hex)` Z. 524 vs. `dec2hex(num)` Z. 548 (en).
2. **Funktionsnamen de/en gemischt:** `häufigkeitsanalyse` (Z. 65, de mit Umlaut) neben `text-to-blocks` (Z. 435), `ascii-table` (Z. 579), `mono` (Z. 314).
3. **Dict-Schlüssel gemischt:** `absolut`, `relativ`, `diagramm` (de) neben `data`, `text` (Z. 125–131); `encode`, `decode`, `table`, `key`, `keyword`, `alphabet` (en) neben `geheimtext-alphabet` (de) (Z. 299–307).
4. **positional vs. named für dasselbe:** `caesar(keyword: …)` Z. 169 (named) vs. `vigenere(keyword, …)` Z. 331 (positional).
5. **`keyword` im Rückgabe-Dict:** bei `caesar` Original (Z. 304), bei `vigenere` bereinigt (Z. 405).
6. **Aufrufform uneinheitlich:** `rot13("x")` (Variable) vs. `atbash()("x")` (Fabrik) vs. `caesar(key: 3)("x")` vs. `vigenere("K")("x")`.
7. **Entschlüsseln per positionalem `true`** (Z. 285, 390) statt benanntem Schalter; benannte Argumente werden verschluckt (Z. 280).
8. **`advanced: bool`** schaltet den Rückgabetyp (Funktion ↔ Dict) – in allen drei Chiffren (Z. 169, 331, 472); `häufigkeitsanalyse-alt` schaltet Rückgabetyp über `cetz`/`rel` (Z. 140).
9. **`height`** bedeutet hier Zeilenzahl (int, Z. 579); in `patterns.kariert` ist `height` eine Länge und die Zeilenzahl heißt `rows`.
10. **Docstring-Rückgabetypen falsch:** `text-to-blocks` "-> content" (Z. 434), liefert str; `caesar`/`vigenere`/`atbash` "-> function", liefern bei `advanced: true` ein Dict; `rot13` "-> function" ok.
11. Umlaut im Bezeichner nur bei `häufigkeitsanalyse(-alt)`; `vigenere` ohne Akzent.

### 1.6 Kopplungen (informatik)

- `arbeitsblatt` 0.2.4, 0.3.0, 0.3.1, 0.3.2, 0.4.0: `#import "@schule/informatik:0.0.2": *` (0.4.0: `src/arbeitsblatt.typ` Z. 9). Damit landen **alle** Namen aus 1.2 inkl. `mono`, `text-to-blocks`, `scratch`, `blockst` im Namensraum jedes Arbeitsblatts und jeder Klassenarbeit (`klassenarbeit 0.4.0` importiert `@schule/arbeitsblatt:0.4.0: *`).
- informatik selbst importiert kein `@schule`-Paket; extern `@preview/blockst:0.1.0`, `@preview/cetz:0.4.2`, `@preview/cetz-plot:0.1.3`.
- Docs (`docs/content.typ`) nutzen `@schule/schuldocs:0.3.0`.

### 1.7 Altlasten / Fehler (informatik)

- **README.md kaputt** (identisch zu 0.0.1, 8907 Byte): Zeilen sind ineinander verschachtelt (z. B. Z. 15 `#import "@preview/schule-informatik:0.0.1": *```typ`), nennt Paket `@preview/schule-informatik:0.0.1`, die nicht existierende Funktion `hf-diagramm(data)` und die alte Signatur `häufigkeitsanalyse(text, rel:, cetz:)`.
- Kopfkommentar Z. 1–3 falsch (siehe 1.1).
- `häufigkeitsanalyse-alt` (Z. 140): Legacy-Wrapper.
- `caesar`: `named-args` ungenutzt (Z. 280); `else`-Zweig Z. 291–293 unerreichbar; ebenso implizites `none` in `vigenere` unerreichbar.
- **Bug:** `text-to-blocks("")` bzw. Text ohne Buchstaben → `clean` ist `none` (`.join("")` auf leerem Array), Fehler "type none has no method `codepoints`" (Z. 440, getestet).
- `caesar(keyword: "123")` (keine Buchstaben): fällt auf unverändertes Alphabet zurück, kein Fehler (Z. 218–220) – anders als `vigenere`, das panict.
- `mono`: Schrift "SF Mono" fest.
- `informatik/0.0.1`: enthielt eigenes `scratch.typ` (91 kB, 179 Top-Level-`#let`) und `docs/manual.typ`; in 0.0.2 durch blockst ersetzt. `lib.typ` 0.0.1 hat dieselben 12 Signaturen wie 0.0.2.
- Dreifach kopierter Block für `table.cell(fill: if colored {…} else {…})` (Z. 633, 665, 670).

---

## 2. operatoren 0.0.1 — `operatoren/0.0.1/operatoren.typ`

### 2.1 Importe
- Z. 80: `#import "@preview/tablex:0.0.9": *` (lokal in `operatoren-liste`; tablex ist seit nativen Typst-Tabellen veraltet).
- Kein `@schule`-Import.

### 2.2 Öffentliche Namen

| Zeile | Name | Art | Sprache |
|---|---|---|---|
| 1 | `operatoren-state` = `state("operatoren", ())` | State (öffentlich, ohne `_`) | de + en-Suffix `-state` (gemischt) |
| 2 | `operatoren-config-state` = `state("operatoren-config", (text-bold: false,))` | State (öffentlich) | gemischt |
| 46 | `operator(name, text: "", bold: none)` | Funktion | de/en identisch |
| 79 | `operatoren-liste(fach: "Mathe", language: "de", operator-text-bold: false)` | Funktion | de |

Private Helfer:

| Zeile | Name | Sprache |
|---|---|---|
| 4 | `_render-operator-text(text, bold: false)` | en |
| 8 | `_normalisiere-sprache(language)` | de-Name, en-Parameter |
| 10 | `_csv-dateiname(fach, language)` | de-Name, Parameter de + en |
| 21 | `_operatorenlisten-titel(language)` | de-Name, en-Parameter |

### 2.3 Signaturen

#### `operator(name, text: "", bold: none)` — Z. 46
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `name` | pos | – | laut Docstring content; **funktioniert nur mit str** (`str(name)` Z. 48) | en/de | Operatorname = Schlüssel in der CSV |
| `text` | named | `""` | str/content; `""` = `name` verwenden | en (überdeckt builtin `text`) | abweichender Anzeigetext |
| `bold` | named | `none` | bool / none (none = globale Einstellung) | en | Fettdruck im Fließtext |

#### `operatoren-liste(fach: "Mathe", language: "de", operator-text-bold: false)` — Z. 79
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `fach` | named | `"Mathe"` | str, faktisch Enum `"Mathe"`, `"Physik"` (= CSV-Dateiname, Groß-/Kleinschreibung exakt) | **de** | Fach |
| `language` | named | `"de"` | String-Enum `"de"`, `"it"` (wird `lower`+`trim` normalisiert) | **en** | Sprache von CSV und Überschrift |
| `operator-text-bold` | named | `false` | bool | en (gemischt mit de-Wort "operator") | globale Fettschrift für `operator()` |

### 2.4 Schlüssel, States, Labels, Daten

| Ding | Wert | Zeile |
|---|---|---|
| State-Name | `"operatoren"` (Array der verwendeten Operatornamen als str) | 1 |
| State-Name | `"operatoren-config"`, Dict mit Schlüssel `text-bold` | 2 |
| Label der Liste | `<-def>` (`label("-def")`) | 56, 58, 91 |
| Label je Operator | `<{op}-def>`, z. B. `<berechnen-def>` | 95 |
| CSV-Dateien | `Mathe.csv` (21 Zeilen), `Physik.csv` (39), `Mathe-it.csv` (21), `Physik-it.csv` (40) | – |
| CSV-Format | `;`-getrennt, kein Kopf, Spalte 0 = Operator (klein, Infinitiv, z. B. `berechnen`, `grafisch darstellen`), Spalte 1 = Definition | 83 |
| Dateinamenskonvention | de: `{fach}.csv`; it: `{fach}-it.csv` (asymmetrisch, kein `-de`) | 12–15 |
| Überschriften | `[Operatorenliste]` / `[Elenco degli operatori]` | 24, 26 |

Derselbe Schalter hat drei Namen: Parameter `operator-text-bold` (Z. 79) → State-Schlüssel `text-bold` (Z. 2, 82) → lokaler Override `bold` (Z. 46).

### 2.5 Validierung / Fehlermeldungen

| Zeile | Meldung | Sprache |
|---|---|---|
| 17, 28 | `Unbekannte Sprache '<x>'. Verfügbar: de, it.` (panic, doppelt implementiert) | de |
| 83 | unbekanntes `fach` → Typst-Fehler "file not found" (keine eigene Meldung) | en (Compiler) |
| 95 | Operator nicht in CSV → "dictionary does not contain key …" (getestet) | en (Compiler) |

### 2.6 Inkonsistenzen (operatoren)

1. `fach` (de) neben `language` (en) in derselben Signatur (Z. 79).
2. `operator-text-bold` / `text-bold` / `bold` für dieselbe Einstellung (Z. 79, 2, 46).
3. `bold: none` (= erben) hier, sonst im Repo meist `auto` für "erben"; `text: ""` als "nicht gesetzt" statt `none`/`auto`.
4. Globale Darstellungsoption wird an `operatoren-liste` übergeben, wirkt aber auf `operator()` im ganzen Dokument (über `.final()`); wer die Liste nicht setzt, kann global nichts einstellen.
5. Paket-/State-Name Plural `operatoren`, Funktion Singular `operator`, Liste `operatoren-liste`; Helfer `_operatorenlisten-titel` (zusammengeschrieben) vs. `operatoren-liste` (Bindestrich).
6. States öffentlich ohne `_` (`operatoren-state`), in aufgaben 0.3.1 heißen States `_state_options` (privat, snake_case).

### 2.7 Kopplungen (operatoren)

- `arbeitsblatt` 0.1.7–0.4.0: `#import "@schule/operatoren:0.0.1": operator, operatoren-liste` (0.4.0: `src/arbeitsblatt.typ` Z. 37). Einziger gezielter (nicht `*`) Import der fünf Pakete; States werden nicht weitergereicht. Keine Parameter-Durchreichung (arbeitsblatt umhüllt die Funktionen nicht).
- Docs: `@schule/schuldocs:0.3.0`.

### 2.8 Altlasten / Fehler (operatoren)

- **Bug (getestet):** `#operator[Berechne]` – die im Docstring (Z. 38) und in `docs/content.typ` (Z. 12, 28–60) gezeigte Form – bricht ab: `str(name)` mit content → "expected integer, … or string, found content" (Z. 48). Nur `#operator("berechnen")` funktioniert.
- **Bug:** Doku-Beispiele verwenden Imperative (`Berechne`, `Beschreibe`, `Leite`), die CSV-Schlüssel sind Infinitive (`berechnen`, …). `lower("Berechne")` = `berechne` steht nicht in der CSV → Fehler Z. 95. Korrekt wäre `#operator("berechnen", text: "Berechne")`.
- **Bug/Halbfertig:** Link zeigt immer auf `<-def>` (Listenanfang, Z. 56/58), die Einzel-Labels `<op-def>` (Z. 95) werden nie angesprungen. Ohne `operatoren-liste` im Dokument: "label `<-def>` does not exist" (getestet).
- Docstring Z. 66 und `docs/content.typ` Z. 132 behaupten, die CSV werde "aus dem Dokumentverzeichnis" gelesen (`fach: "Biologie"` → eigene `Biologie.csv`). `csv()` in Z. 83 löst relativ zur Paketdatei auf; eigene Fächer gehen so nicht.
- `-it`-CSVs ohne Akzente (`e necessaria`, `proprieta`) – ASCII-Transliteration.
- `Physik-it.csv` 40 Zeilen vs. `Physik.csv` 39 (Abgleich nötig).
- Sprachprüfung doppelt (Z. 10–19 und 21–30).
- `context operatoren-state.update(…)` (Z. 47) – `context` überflüssig; `operatoren-config-state.update` innerhalb `context` (Z. 82).
- README leer; description Platzhalter.

---

## 3. patterns 0.0.2 — `patterns/0.0.2/patterns.typ`

### 3.1 Importe
- Z. 88 und 198: `import "@preview/cetz:0.4.2": *` (lokal). Kein `@schule`-Import.

### 3.2 Öffentliche Namen

| Zeile | Name | Art | Sprache |
|---|---|---|---|
| 7 | `flex-feld(hoehe, zeichne)` | Funktion (Helfer, aber öffentlich) | gemischt (`flex` en + `feld` de), Parameter de, **`hoehe` mit oe** |
| 16 | `ist-flex-feld(inhalt)` | Prädikat (öffentlich) | gemischt, Parameter de |
| 43 | `kariert(rows: 1, width: auto, items: (), items-spacing: 2, grid-size: 0.5cm, height: none, annotations: (), line-stroke: …, fill-color: white, content: [], ..args)` | Funktion | Name de, Parameter en |
| 155 | `liniert(rows: 1, width: auto, items: (), items-spacing: 1, line-height: 1cm, line-stroke: …, ..args)` | Funktion | Name de, Parameter en |

### 3.3 Signaturen

#### `flex-feld(hoehe, zeichne)` — Z. 7
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `hoehe` | pos | – | fraction (`1fr` …) | de, **ae/oe-Schreibweise** (sonst im Repo Umlaute: `häufigkeitsanalyse`, `lücke`, `klausurbögen`) | Anteil am freien Platz |
| `zeichne` | pos | – | function(length) → content | de | Zeichen-Callback, bekommt tatsächliche Höhe |

Magische Zahl: beim Ausmessen (`size.height.pt() > 100000`) wird `1cm` angenommen (Z. 12).

#### `ist-flex-feld(inhalt)` — Z. 16
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `inhalt` | pos | – | any | de | zu prüfender Inhalt |

Konvention: "flexibles Feld" = `block` mit `height` vom Typ `fraction`.

#### `kariert(...)` — Z. 43–55 (wörtlich)
```typ
#let kariert(
  rows: 1,
  width: auto,
  items: (),
  items-spacing: 2,
  grid-size: 0.5cm,
  height: none,
  annotations: (),
  line-stroke: (paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt),
  fill-color: white,
  content: [],
  ..args,
) = {
```
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `rows` | named (auch 1. Positionsarg.) | `1` | int oder fraction (`1fr`) | en | Zeilenzahl in Kästchen bzw. Anteil am Restplatz |
| `width` | named (auch 2. Positionsarg.) | `auto` | auto oder **Zahl in Kästchen** (Docstring sagt `length` – falsch, s. u.) | en | Breite |
| `items` | named | `()` | array aus content | en | Einträge, die untereinander ins Raster gesetzt werden |
| `items-spacing` | named | `2` | int/float, Einheit **Kästchen** | en (Plural `items-`) | Abstand der Einträge |
| `grid-size` | named | `0.5cm` | length | en | Kästchengröße |
| `height` | named | `none` | length / none | en | Höhe als Länge, überschreibt `rows` |
| `annotations` | named | `()` | CeTZ-Zeichenbefehle | en | Zusatzzeichnung über dem Raster |
| `line-stroke` | named | `(paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt)` | stroke/dict | en | Linienstil |
| `fill-color` | named | `white` | color / none | en | Hintergrund |
| `content` | named | `[]` | content | en (überdeckt cetz `content`, darum `import draw:` + `draw.` Z. 92) | Text über dem Raster |
| `..args` | sink | – | pos 0 → `rows`, pos 1 → `width`; weitere und **alle unbekannten benannten Argumente werden stillschweigend verschluckt** | – | Positionskurzform |

#### `liniert(...)` — Z. 155–163 (wörtlich)
```typ
#let liniert(
  rows: 1,
  width: auto,
  items: (),
  items-spacing: 1,
  line-height: 1cm,
  line-stroke: (paint: black.lighten(50%), thickness: 0.5pt),
  ..args,
) = {
```
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `rows` | named (auch 1. Positionsarg.) | `1` | int oder fraction | en | Zeilenzahl bzw. Anteil |
| `width` | named (auch 2. Positionsarg., **nur wenn `length`**) | `auto` | auto oder length | en | Breite |
| `items` | named | `()` | array aus content | en | Einträge auf den Linien |
| `items-spacing` | named | `1` | int, Einheit **Zeilen** | en | Abstand der Einträge |
| `line-height` | named | `1cm` | length | en | Zeilenhöhe |
| `line-stroke` | named | `(paint: black.lighten(50%), thickness: 0.5pt)` | stroke/dict | en | Linienstil |
| `..args` | sink | – | pos 0 → `rows`, pos 1 → `width`; Rest und unbekannte benannte verschluckt | – | |

Kein `height`, `fill-color`, `content`, `annotations` (anders als `kariert`).

### 3.4 Validierung
Keine. Durch `..args` werden Tippfehler (`grid-sice: …`, altes `lineheight: …`) ohne Meldung ignoriert. Keine eigenen Fehlermeldungen im Paket.

### 3.5 Inkonsistenzen (patterns)

1. **`width` hat zwei Einheiten:** `kariert` erwartet Kästchenzahl (wird als CeTZ-Koordinate und in `effective-width * grid-size` Z. 126 benutzt); `liniert` erwartet `length` (Z. 171, 204–206). Getestet: `kariert(3, 5cm, content: [x])` → "cannot multiply length with length" (Z. 126); `liniert(3, 10)` ignoriert die 10 stillschweigend (Z. 171).
2. **Positionsargument 2** wird bei `kariert` ungeprüft übernommen (Z. 63), bei `liniert` nur bei Typ `length` (Z. 171).
3. **Zellgröße heißt verschieden:** `grid-size` (kariert, Default 0.5cm) vs. `line-height` (liniert, Default 1cm). klausurboegen 0.0.5 nennt dasselbe `linienabstand` (Default 8mm).
4. **`items-spacing` Default 2 (Kästchen) vs. 1 (Zeilen)**; insert-a-word nennt Vergleichbares `item-spacing` (Singular, `length`).
5. **Höhe dreifach:** `rows` (Anzahl), `height` (Länge, nur kariert), `rows: 1fr` (Bruchteil). Docstring Z. 36 "überschreibt `rows`" stimmt nicht bei gesetzten `items` und `rows == 1` (Z. 79–80: items gewinnen) und nicht bei `rows: 1fr` (Z. 72–73: `height` wird beim rekursiven Aufruf gar nicht weitergegeben).
6. **`rows: 1fr` + `items`:** kariert unterstützt die Kombination (Z. 69–74), liniert schaltet die Flex-Variante bei `items` ab (Z. 177) und fällt auf feste Zeilen zurück.
7. Deutsche Funktionsnamen (`kariert`, `liniert`, `flex-feld`, `ist-flex-feld`) mit durchweg englischen Parametern bei den Mustern, aber deutschen Parametern (`hoehe`, `zeichne`, `inhalt`) bei den Flex-Helfern; Paketname englisch (`patterns`).
8. `fill-color`/`line-stroke`: Typ-Suffix im Namen (`-color`, `-stroke`), sonst Typst-üblich `fill`/`stroke`.
9. String-Enum `"kariert"`/`"liniert"` existiert parallel als `muster:` in klausurboegen 0.0.5 (Z. 55, 59) und klassenarbeit 0.4.0 (`template/ka.typ` Z. 13) – dort eigene Implementierung, nicht `patterns`.
10. Spacing nach dem Feld: `liniert` hängt `v(1em * (line-height / 1cm))` an (Z. 230) und verschiebt um halbe Zeilenhöhe (Z. 196); `kariert` nicht; die Flex-Variante von `liniert` (Z. 180–188) ebenfalls nicht.

### 3.6 Diff patterns 0.0.1 → 0.0.2

| Thema | 0.0.1 | 0.0.2 |
|---|---|---|
| öffentliche Namen | `kariert`, `liniert` | zusätzlich `flex-feld`, `ist-flex-feld` |
| `liniert`-Parameter | `lineheight: 1cm` (Z. 77, **ohne Bindestrich**) | `line-height: 1cm` (Z. 160) – **stille Umbenennung**, altes `lineheight:` wird wegen `..args` kommentarlos ignoriert |
| `liniert` neu | – | `items: ()`, `items-spacing: 1` |
| `kariert` neu | – | `content: []` |
| `rows` | nur int | int oder fraction (`1fr`) |
| `kariert` items-Höhe | `items.len() * 1.5cm - grid-size` (Z. 31) | `(items.len() * items-spacing) * grid-size` (Z. 80) |
| `kariert` item-Position | `autoheight + grid-size - (key + 1) * items-spacing * grid-size` (Z. 62) | `autoheight - (key * items-spacing + 1) * grid-size` (Z. 117) |
| cetz-Import in `kariert` | `import draw: *` | `import draw:` + Präfix `draw.` (wegen Parameter `content`) |
| Docstrings | keine | tidy-Stil |
| typst.toml | ohne `repository` | mit `repository` |

Nutzer: `patterns:0.0.1` in arbeitsblatt 0.1.4–0.2.3; `patterns:0.0.2` ab arbeitsblatt 0.2.4.
Noch älter: `liniert(rows: 1, width: auto, lineheight: 1cm)` war bis arbeitsblatt 0.1.3 direkt in `arbeitsblatt.typ` definiert (z. B. 0.0.7 Z. 143, 0.1.3 Z. 214).

### 3.7 Kopplungen (patterns)

- `arbeitsblatt` 0.2.4–0.4.0: `#import "@schule/patterns:0.0.2": *` (0.4.0 Z. 5) → `kariert`, `liniert`, `flex-feld`, `ist-flex-feld` für Nutzer sichtbar. Kein Wrapper, keine Parameter-Durchreichung.
- **Implizite Kopplung zu aufgaben 0.3.1:** `aufgaben.typ` Z. 867 `_ist-flex-workspace(ws)` ist eine **wörtliche Kopie** von `patterns.ist-flex-feld` (Z. 16–18), weil aufgaben `patterns` nicht importiert. Der Vertrag "Block mit `height: fraction`" verbindet `kariert(rows: 1fr)` mit `aufgabe(workspace: …)`/`teilaufgabe(workspace: …)` (aufgaben Z. 1065–1072, 1242–1267) und `_flex-fest` (Z. 871: 3 cm je `fr` bei `page.height == auto`). Der Kommentar in patterns Z. 5 verweist auf `teilaufgabe(workspace: …)`.
- `arbeitsblatt.workspace(height: 5cm, body)` (0.4.0 Z. 1492) ist ein weiterer Behälter; dort heißt die Höhe `height` (length) – passt zu `kariert(height:)`, nicht zu `rows`.
- Docs: `@schule/schuldocs:0.3.0`.

### 3.8 Altlasten / Fehler (patterns)

- Z. 2 `// Was ist items? Gibts da nicht schönere Variablennamen?` – offene Notiz des Autors, steht seit 0.0.2 fälschlich über dem Docstring von `flex-feld`.
- Docstring `kariert.width (length)` falsch (siehe 3.5.1); Docstring `kariert.height … überschreibt rows` unvollständig.
- Doppelte Zweige für `effective-width != auto` / `auto` in beiden Funktionen (Z. 96–112, 204–212).
- Englischer Restkommentar `// Set some spacing under the rows` (Z. 229) zwischen deutschen Kommentaren.
- Beschriftungs-Box für items fest `fill: white, inset: 4pt` (Z. 118), unabhängig von `fill-color`.
- README leer.

---

## 4. insert-a-word 0.0.3 — `insert-a-word/0.0.3/lib.typ`

### 4.1 Importe / Re-Exporte
- Z. 1: `#import "@schule/random:0.0.1": *` → **re-exportiert alle 11 Namen von random** (`default_seed`, `m`, `a`, `lcg`, `low_cminstd_rand`, `low_cminstd_randint`, `step_seed`, `fisher_yates_shuffle`, `rand`, `randint`, `shuffle`). Gebraucht wird nur `shuffle` (Z. 128, 129).

### 4.2 Öffentliche Namen

| Zeile | Name | Art | Sprache |
|---|---|---|---|
| 4 | `iaword-list` = `state("iaword-list", ())` | State: Array aus `(blocknummer, body)` | en, Abk. `ia` |
| 5 | `iaword-solution` = `state("iaword-solution", ())` | State (wird nur geschrieben) | en |
| 8 | `iaword-counter` = `counter("iaword-counter")` | Counter (Blocknummer) | en |
| 11 | `iaword-uniform` = `state("iaword-uniform", false)` | State | en |
| 16 | `iaword-start` = `state("iaword-start", 0)` | State | en |
| 19 | `iaword-show` = `state("iaword-show", false)` | State | en |
| 26 | `iaword-neu()` | Funktion | **gemischt** (en-Präfix + de `neu`) |
| 40 | `iaword(body)` | Funktion | en-Abk. ("insert-a-word") |
| 101 | `insert-a-word(hide-words: false, line-spacing: 1.5em, item-spacing: 1em, show-solution: false, uniform-gaps: false, body)` | Funktion | en |

Alle States/Counter sind öffentlich (kein `_`) und gelangen über `arbeitsblatt` (`import … : *`) in den Nutzer-Namensraum.

### 4.3 Signaturen

#### `iaword-neu()` — Z. 26
Keine Parameter. Setzt `iaword-start` auf den aktuellen Zählerstand (Seed-Basis je Bundle-Fassung).

#### `iaword(body)` — Z. 40
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `body` | pos | – | content | en | das Lückenwort |

Fest verdrahtet: Lückenbreite = Wortbreite + `3em` (Z. 53–58), Linie `0.5pt + luma(130)`, Lösungsfarbe `red` (Z. 66), `dy: 4pt`.

#### `insert-a-word(...)` — Z. 101 (wörtlich)
```typ
#let insert-a-word(hide-words: false, line-spacing: 1.5em, item-spacing: 1em, show-solution: false, uniform-gaps: false, body) = {
```
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `hide-words` | named | `false` | bool | en, **Negativ-Schalter** | Wortkästen ausblenden |
| `line-spacing` | named | `1.5em` | length (→ `par(leading:)`) | en | Zeilenabstand des Textes |
| `item-spacing` | named | `1em` | length | en, Singular (patterns: `items-spacing`) | Abstand zwischen Wortkästen |
| `show-solution` | named | `false` | bool | en, Positiv-Schalter | Lösungswörter rot in die Lücken |
| `uniform-gaps` | named | `false` | bool | en | alle Lücken so breit wie das längste Wort |
| `body` | pos (nach den benannten) | – | content | en | Text mit `#iaword[…]` |

Fest verdrahtet: 6 Kastenfarben (Z. 106–113), `inset: 8pt`, `radius: 4pt`, Ausrichtung zentriert.

### 4.4 Schlüssel / Konventionen
- State-/Counter-Namen = Variablennamen: `"iaword-list"`, `"iaword-solution"`, `"iaword-counter"`, `"iaword-uniform"`, `"iaword-start"`, `"iaword-show"`.
- Zuordnung Wort ↔ Block über Zählerstand (`position + 1`, Z. 125); Seed = `position - iaword-start.get()` (Z. 123).
- Keine Labels/Queries mehr (0.0.1 nutzte `label("iaword" + str(counter))`).

### 4.5 Validierung
Keine; keine Fehlermeldungen. `iaword` außerhalb von `insert-a-word` wird nicht erkannt (Wort landet in der Liste des "nächsten" Blocks).

### 4.6 Inkonsistenzen (insert-a-word)

1. `hide-words` (negativ) neben `show-solution` (positiv) in einer Signatur (Z. 101).
2. `iaword-neu` (de) als einzige deutsche Funktion zwischen englischen Namen; arbeitsblatt hat daneben `reset-aufgaben()` (en-Verb + de-Substantiv) für dieselbe Art Vorgang (arbeitsblatt 0.4.0 Z. 615/619).
3. `show-solution: bool` ist **nicht** an die globale Lösungsoption gekoppelt (aufgaben/arbeitsblatt: `loesungen` als String-Enum, u. a. `"nur"`, `"keine"`; Lösungen dort deutsch `loesung`/`lsg`). Gleiches Konzept: en + bool hier, de + String dort.
4. `item-spacing` (Singular, length) vs. `patterns.items-spacing` (Plural, Zahl); `line-spacing` hier = Absatz-`leading`, in patterns heißt die Zeilenhöhe `line-height`.
5. Paketname = Funktionsname `insert-a-word`, Präfix der Hilfsnamen `iaword` (Abk.); deutsches Gegenstück in arbeitsblatt heißt `lücke(body, tight: false)` (0.4.0 Z. 1145) – **zweite, unabhängige Lücken-Funktion** mit anderem Aussehen (2em Einzug statt +3em, kein Lösungsmodus).
6. `body` ist letzter positionaler Parameter nach benannten – in Typst üblich, aber Doku-Reihenfolge weicht ab.

### 4.7 Kopplungen (insert-a-word)

- importiert `@schule/random:0.0.1` (einzige vorhandene Version).
- `arbeitsblatt` 0.2.3–0.4.0: `#import "@schule/insert-a-word:0.0.3": *`; arbeitsblatt 0.3.2 Z. 543 / 0.4.0 Z. 619 ruft `iaword-neu()` je Fassung auf. Veraltete Importe: arbeitsblatt 0.1.0–0.1.9 → `insert-a-word:0.0.1`, 0.2.0–0.2.2 → `0.0.2`.
- Keine Parameter-Durchreichung aus arbeitsblatt (insb. kein Durchreichen von `loesungen` an `show-solution`).

### 4.8 Altlasten / Fehler (insert-a-word)

- `iaword-solution` (Z. 5) wird in Z. 118–121 beschrieben, aber nirgends gelesen → toter State. Zudem `solution.insert(position, show-solution)` auf Array: fügt an Index ein, schlägt fehl, wenn `position > len` (z. B. nach Zählersprüngen).
- Z. 76–77: `// TODO: Option zum Anzeigen der Lösung hinzufügen` + auskommentiertes `#place(...)` – erledigt (es gibt `show-solution`), Kommentar veraltet.
- `iaword-uniform.update(...)` und `set par(leading: …)` wirken über den Block hinaus (State bleibt gesetzt; `set par` nur bis Funktionsende).
- `example.typ` (114 Zeilen): Großteil auskommentiert (Z. 10–59), kennt `show-solution`/`uniform-gaps` nicht; in `typst.toml` per `exclude` ausgenommen.
- README leer; description Platzhalter.
- Versionsgeschichte: 0.0.1 `insert-a-word(hide-words: false, line-spacing: 1.5em, body, key: 0, font-size: 12pt)` und `iaword(body, key: 0)`, `iaword-counter` als `state`; 0.0.2 `insert-a-word(hide-words: false, line-spacing: 1.5em, item-spacing: 1em, body)`; 0.0.3 + `show-solution`, `uniform-gaps`, `iaword-neu`, `iaword-start`, `iaword-show`, `iaword-uniform`, `iaword-solution`. Parameter `key`, `font-size` sind entfallen.

---

## 5. random 0.0.1 — `random/0.0.1/random.typ`

### 5.1 Importe
Keine.

### 5.2 Öffentliche Namen (alle Top-Level, **snake_case**, englisch)

| Zeile | Name | Art | Bemerkung |
|---|---|---|---|
| 3 | `default_seed` = `42` | Variable | snake_case |
| 8 | `m` = `calc.pow(2, 32) - 1` | Variable | **einbuchstabig, öffentlich** |
| 9 | `a` = `48271` | Variable | **einbuchstabig, öffentlich** |
| 11 | `lcg(seed, steps: 100)` | Funktion | Abk. |
| 24 | `low_cminstd_rand(seed: default_seed)` | Funktion | snake_case |
| 32 | `low_cminstd_randint(start, end, seed: default_seed)` | Funktion | snake_case |
| 40 | `step_seed(cur_seed)` | Funktion | snake_case |
| 45 | `fisher_yates_shuffle(arr, seed)` | Funktion | snake_case |
| 57 | `rand(seed)` | Funktion ("INTERFACE") | en-Abk.; kollidiert sprachlich mit de "Rand" |
| 58 | `randint(start, end, seed)` | Funktion ("INTERFACE") | en-Abk. |
| 59 | `shuffle(arr, seed)` | Funktion ("INTERFACE") | en |

### 5.3 Signaturen

#### `lcg(seed, steps: 100)` — Z. 11
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `seed` | pos | – | int | en | Startwert |
| `steps` | named | `100` | int | en | Iterationen |

Rückgabe float in [0, 1).

#### `low_cminstd_rand(seed: default_seed)` — Z. 24
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `seed` | **named** | `42` | int | en | Startwert |

#### `low_cminstd_randint(start, end, seed: default_seed)` — Z. 32
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `start` | pos | – | int | en | untere Grenze (inklusiv) |
| `end` | pos | – | int | en | obere Grenze (inklusiv) |
| `seed` | **named** | `42` | int | en | Startwert |

#### `step_seed(cur_seed)` — Z. 40
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `cur_seed` | pos | – | int | en, Abk. + snake_case | aktueller Seed → nächster Seed |

#### `fisher_yates_shuffle(arr, seed)` — Z. 45
| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `arr` | pos | – | array | en-Abk. | zu mischendes Array |
| `seed` | pos | – | int | en | Startwert |

#### `rand(seed)` — Z. 57 · `randint(start, end, seed)` — Z. 58 · `shuffle(arr, seed)` — Z. 59
| Funktion | Parameter | Art | Default | Typ | Bedeutung |
|---|---|---|---|---|---|
| `rand` | `seed` | pos | – | int | Zufallszahl in [0, 1) |
| `randint` | `start`, `end`, `seed` | pos, pos, **pos** | – | int | ganze Zufallszahl, Grenzen inklusiv |
| `shuffle` | `arr`, `seed` | pos, pos | – | array, int | Permutation |

### 5.4 Validierung
Keine. Seed `0` liefert in `lcg` konstant 0 (keine Prüfung).

### 5.5 Inkonsistenzen (random)

1. **Einziges Paket mit snake_case** (`default_seed`, `low_cminstd_rand`, `step_seed`, `cur_seed`, `fisher_yates_shuffle`, lokale `new_seed`, `new_array`); alle anderen vier Pakete nutzen kebab-case.
2. `seed` named mit Default in `low_cminstd_rand`/`low_cminstd_randint` (Z. 24, 32), aber positional ohne Default in `rand`/`randint`/`shuffle` (Z. 57–59) und `lcg` (Z. 11).
3. Einrückung 4 Leerzeichen, alle anderen Pakete 2.
4. Kommentare englisch, Rest des Repos deutsch.
5. Interne Implementierungsnamen sind genauso öffentlich wie die drei "INTERFACE"-Funktionen; kein `_`-Präfix.

### 5.6 Kopplungen (random)

Importiert mit `: *` von:
- `insert-a-word` 0.0.1, 0.0.2, 0.0.3 (Z. 1) – nutzt `shuffle`
- `arbeitsblatt` 0.0.5 – 0.4.0 (0.4.0 `src/arbeitsblatt.typ` Z. 2)
- `mathematik` 0.0.1 (Z. 2), 0.0.2 (Z. 1)
- `physik` 0.0.1 (`lib.typ` Z. 4), 0.0.2 (`messwerttabellen.typ` Z. 3)
- `messwerttabellen` 0.0.1 (`lib.typ` Z. 3)

Folge (getestet mit `#import "@schule/arbeitsblatt:0.4.0": *`): **`a`, `m`, `default_seed`, `lcg`, `mono` sind im Nutzerdokument definiert.** Ein Schüler-/Lehrerdokument, das `#a` oder `#m` schreibt, bekommt 48271 bzw. 4294967295 statt eines Fehlers. `rand` (Zufallszahl) überlagert sich begrifflich mit "Rand" (Seitenrand): arbeitsblatt 0.4.0 `themes.typ` benutzt `rand` als lokale Variable für den Seitenrand (Z. 318) und `_seitenrand` (Z. 128).

### 5.7 Altlasten / Fehler (random)

- Offenbar übernommener Fremdcode (englische Kommentare, snake_case); keine Lizenz-/Quellenangabe.
- Z. 1: abgebrochener Satz `…isn't even state of the art, but` .
- Z. 6–7: doppelter Kommentar ("an implementation of minstd_rand" / "equivalent to minstd_rand").
- Z. 8: Kommentar "m is lowered to 2^16 - 1" widerspricht dem Code `calc.pow(2, 32) - 1` (minstd wäre 2^31 − 1).
- Z. 30–31: Kommentar "if no start is specified, it is assumed to be 0 … end … 10" – es gibt keine Defaults.
- Z. 38: Kommentar "INTERFACE: generates n random numbers …" steht über `step_seed`, das etwas anderes tut; die beschriebene Funktion fehlt.
- README leer; description Platzhalter; kein `repository`.
- Seit Typst es `@preview/suiji` u. Ä. gibt, ist das Paket ein Kandidat für Ersatz oder für `_`-Privatisierung.

---

## 6. Paketübergreifende Befunde (für den Umbenennungsplan)

### 6.1 Gleiche Sache, verschiedene Namen

| Konzept | Vorkommen |
|---|---|
| Zeilen-/Kästchengröße | `patterns.kariert(grid-size: 0.5cm)`, `patterns.liniert(line-height: 1cm)`, patterns 0.0.1 `lineheight`, klausurboegen 0.0.5 `linienabstand: 8mm`, `insert-a-word(line-spacing: 1.5em)` (dort Absatz-leading) |
| Abstand zwischen Einträgen | `patterns.items-spacing` (Zahl; Default 2 bzw. 1), `insert-a-word.item-spacing` (length, 1em) |
| Höhe | `kariert(rows:)` int/fr, `kariert(height:)` length, `flex-feld(hoehe)` fraction, `ascii-table(height:)` int = Zeilen, `arbeitsblatt.workspace(height:)` length |
| Breite | `kariert(width)` Kästchenzahl, `liniert(width)` length |
| Lösung anzeigen | `insert-a-word(show-solution: bool)` vs. `loesungen: "…"` (aufgaben/arbeitsblatt) |
| Lücke | `iaword[…]` (insert-a-word) vs. `lücke[…]` (arbeitsblatt 0.4.0 Z. 1145) |
| Zurücksetzen | `iaword-neu()` vs. `reset-aufgaben()` |
| Sprache | `operatoren-liste(language: "de")` – einziger Sprachparameter der fünf Pakete |
| Fettschrift | `operator(bold:)`, `operatoren-liste(operator-text-bold:)`, State-Key `text-bold` |
| Text-Parameter | `text` (informatik, operatoren – überdeckt builtin), `body` (mono, iaword, insert-a-word), `inhalt` (ist-flex-feld), `content` (kariert), `klartext`/`geheimtext` (lokal), `name` (operator) |
| Zahl-Parameter | `zahl`, `num`, `hex` |
| "erben/nicht gesetzt" | `bold: none`, `text: ""`, `width: auto`, `height: none`, `key: none` |
| Muster-Enum | Funktionsnamen `kariert`/`liniert` (patterns) vs. `muster: "kariert" | "liniert"` (klausurboegen, klassenarbeit) |

### 6.2 Schreibweisen

| Stil | Wo |
|---|---|
| kebab-case | informatik, operatoren, patterns, insert-a-word |
| snake_case | random komplett; aufgaben `_state_options` (nur als Vergleich) |
| Umlaut im Bezeichner | `häufigkeitsanalyse`, `häufigkeitsanalyse-alt` (informatik); `lücke`, `klausurbögen` (andere Pakete) |
| ae/oe/ue statt Umlaut | `hoehe` (patterns Z. 7); `loesungen`, `klausurboegen` (Paketordner) in anderen Paketen |
| Ziffer im Namen | `bin2dec`, `dec2bin`, `hex2dec`, `dec2hex`, `rot13` |
| Typ-Suffix | `line-stroke`, `fill-color`, `operatoren-state`, `operatoren-config-state` |

### 6.3 Namensraum-Verschmutzung über `import …: *`

`arbeitsblatt 0.4.0` importiert random, insert-a-word, patterns, informatik jeweils mit `*` (Z. 2, 3, 5, 9); `klassenarbeit 0.4.0` importiert `arbeitsblatt 0.4.0: *`. Dadurch sind im Nutzerdokument u. a. sichtbar:
`a`, `m`, `default_seed`, `lcg`, `low_cminstd_rand`, `low_cminstd_randint`, `step_seed`, `fisher_yates_shuffle`, `rand`, `randint`, `shuffle`, `mono`, `text-to-blocks`, `ascii-table`, `caesar`, `vigenere`, `atbash`, `rot13`, `bin2dec`, `dec2bin`, `hex2dec`, `dec2hex`, `häufigkeitsanalyse`, `häufigkeitsanalyse-alt`, `blockst`, `scratch`, `set-blockst`, `blockst-run-options`, `set-scratch-run`, `scratch-run`, `kariert`, `liniert`, `flex-feld`, `ist-flex-feld`, `iaword`, `iaword-neu`, `insert-a-word`, `iaword-list`, `iaword-solution`, `iaword-counter`, `iaword-uniform`, `iaword-start`, `iaword-show`, sowie (gezielt) `operator`, `operatoren-liste`.

### 6.4 Importierte Versionen (Stand der Abnehmer)

| Abnehmer | random | insert-a-word | patterns | informatik | operatoren |
|---|---|---|---|---|---|
| arbeitsblatt 0.4.0 | 0.0.1 | 0.0.3 | 0.0.2 | 0.0.2 | 0.0.1 |
| arbeitsblatt 0.2.4 – 0.3.2 | 0.0.1 | 0.0.3 | 0.0.2 | 0.0.2 | 0.0.1 |
| arbeitsblatt 0.2.3 | 0.0.1 | 0.0.3 | **0.0.1** | – | 0.0.1 |
| arbeitsblatt 0.2.0 – 0.2.2 | 0.0.1 | **0.0.2** | **0.0.1** | – | 0.0.1 |
| arbeitsblatt 0.1.x | 0.0.1 | **0.0.1** | 0.0.1 (ab 0.1.4) | – | 0.0.1 (ab 0.1.7) |
| aufgaben 0.3.1 | – | – | – (kopiert `ist-flex-feld`) | – | – |
| klassenarbeit 0.4.0 | über arbeitsblatt 0.4.0 | dito | dito | dito | dito |
| mathematik 0.0.1/0.0.2, physik 0.0.1/0.0.2, messwerttabellen 0.0.1 | 0.0.1 | – | – | – | – |
| informatik 0.0.2 | – | – | – | – | – (extern `@preview/blockst:0.1.0`, veraltet ggü. `@schule/blockst` 0.4.1) |

Externe Abhängigkeiten der fünf Pakete: `@preview/cetz:0.4.2` (informatik, patterns), `@preview/cetz-plot:0.1.3` (informatik), `@preview/tablex:0.0.9` (operatoren, veraltet), `@preview/blockst:0.1.0` (informatik).

### 6.5 Validierung im Überblick

| Paket | prüft unbekannte Optionen | eigene Fehlermeldungen | Sprache |
|---|---|---|---|
| informatik | nein | 4 × `panic` (Z. 226, 336, 389, 497) | de |
| operatoren | nur `language` (Z. 17, 28) | 2 × `panic` (gleicher Text) | de |
| patterns | nein, `..args` verschluckt alles | keine | – |
| insert-a-word | nein | keine | – |
| random | nein | keine | – |

Keine der Meldungen trägt ein Paket-/Funktionspräfix; keine nutzt `assert(…, message:)` wie klausurboegen 0.0.5 Z. 59.

### 6.6 Sonstige Altlasten im Repo-Umfeld
- `aufgaben/0.3.1/aufgaben.typ.orig` (untracked, laut `git status`) – nicht Teil dieser fünf Pakete, aber Altlast.
- In den fünf Paketen selbst keine `.orig`-Dateien.
- Leere READMEs: operatoren, patterns (beide Versionen), insert-a-word (alle Versionen), random.
