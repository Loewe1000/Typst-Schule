# Inventar: `arbeitsblatt/0.4.0/src/themes.typ`

Quelle: `/Users/alexander/Library/Application Support/typst/packages/schule/arbeitsblatt/0.4.0/src/themes.typ` (1164 Zeilen, vollständig gelesen, Arbeitsstand inkl. uncommitteter Änderung).
Zeilennummern beziehen sich auf den Arbeitsstand (nicht HEAD).

Legende Sprache: de = deutsch, en = englisch, mix = gemischt, abk = Abkürzung. Art: pos = positional, named = benannt, sink = `..args`.

---

## 0. Überblick

- Die Datei definiert **8 Themes** (`klar`, `atlas`, `skizze`, `labor`, `kontur`, `leiste`, `riso`, `bauhaus`), jedes als Funktion `(akzent, class) => dictionary`.
- Dazu gemeinsame Bausteine (Fachfarben, Kürzel-Parser, Kicker, Kastenstil, Marken, Schatten).
- Einziger externer Import: `@preview/fontawesome:0.6.0` (`fa-icon`), Z. 30. Keine `@schule`-Importe.
- Konsumenten:
  - `arbeitsblatt/0.4.0/src/arbeitsblatt.typ:45` importiert nur `themes, _theme-aufloesen`.
  - `aufgaben/0.3.1/aufgaben.typ:27-31` liest das aufgelöste Theme-Dictionary aus `state("ab-theme")` über `_theme-hook(name)`.
- Paket-Entrypoint ist `src/arbeitsblatt.typ` (typst.toml Z. 4). Über `#import "@schule/arbeitsblatt:0.4.0": *` sind aus dieser Datei daher **nur** `themes` und `_theme-aufloesen` erreichbar (Typst exportiert importierte Namen mit; der Unterstrich schützt nicht). Alle anderen öffentlichen Namen dieser Datei (`fachfarben`, `fachnamen`, `kuerzel`, `kicker`, `fachfarbe`, `kasten-stil`, `klar` … `bauhaus`) sind für Paketnutzer **nicht** direkt erreichbar, nur `themes.klar` usw.

### Uncommittete Änderung (`git diff`)

Betrifft nur das Theme `atlas`:

| Zeile (neu) | Änderung |
|---|---|
| 297-300 | lokale Funktion `reiter(titel, farbe, icon)` bekommt neuen benannten Parameter `rand: none` (Strichstärke) plus dreizeiligen Kommentar |
| 302 | neu: `stroke: if rand == none { none } else { rand + farbe }` |
| 379 | Aufruf erweitert: `reiter(..., st.icon, rand: if memo { 1.5pt } else { none })` |

Rein kosmetischer Fix (Reiter bündig mit Kastenrand beim Merke-Kasten). Neuer Parametername `rand` ist deutsch und kollidiert semantisch mit dem Theme-Schlüssel `rand` (dort = Seitenränder, hier = Strichstärke) und mit dem `hintergrund`-Parameter `rand:` (dort = margin-Dictionary).

---

## 1. Öffentliche Namen (Top-Level `#let` ohne Unterstrich)

| Zeile | Name | Art | Über Paket erreichbar? |
|---|---|---|---|
| 35 | `fachfarben` | Dictionary (Konstante) | nein |
| 46 | `fachnamen` | Dictionary (Konstante) | nein |
| 67 | `kuerzel(class)` | Funktion | nein |
| 77 | `kicker(class)` | Funktion | nein |
| 85 | `fachfarbe(class)` | Funktion | nein |
| 116 | `kasten-stil(art, akzent, farbe: auto)` | Funktion | nein |
| 183 | `klar(akzent, class)` | Theme-Funktion | nur als `themes.klar` |
| 294 | `atlas(akzent, class)` | Theme-Funktion | nur als `themes.atlas` |
| 410 | `skizze(akzent, class)` | Theme-Funktion | nur als `themes.skizze` |
| 547 | `labor(akzent, class)` | Theme-Funktion | nur als `themes.labor` |
| 657 | `kontur(akzent, class)` | Theme-Funktion | nur als `themes.kontur` |
| 780 | `leiste(akzent, class)` | Theme-Funktion | nur als `themes.leiste` |
| 896 | `riso(akzent, class)` | Theme-Funktion | nur als `themes.riso` |
| 1020 | `bauhaus(akzent, class)` | Theme-Funktion | nur als `themes.bauhaus` |
| 1138 | `themes` | Dictionary Name → Theme-Funktion | **ja** (re-exportiert) |

### Private Namen (Top-Level mit Unterstrich)

| Zeile | Name | Signatur (wörtlich) |
|---|---|---|
| 58 | `_klartext` | `_klartext(x)` |
| 91-96 | `_gruen`, `_gelb`, `_orange`, `_rot`, `_violett`, `_tuerkis` | Farbkonstanten |
| 97 | `_kasten-stil` | Dictionary art → `(icon-name, farbe-oder-none)` |
| 122 | `_aussen` | `_aussen(duplex, inhalt)` |
| 128 | `_seitenrand` | `_seitenrand(m, n)` |
| 143 | `_marke` | `_marke(inhalt, fill: black, size: 1em, radius: 1.5pt, font: auto, weight: 700, breite: auto, inset: (x: 0.5em, y: 0.4em), stroke: none, farbe: white)` |
| 154 | `_schatten-box` | `_schatten-box(inhalt, versatz: 2.5pt, farbe: black)` |
| 163 | `_schatten-block` | `_schatten-block(inhalt, versatz: 4pt, farbe: black)` |
| 173 | `_loesung-inline` | `_loesung-inline(titel, body, label-stil: it => it)` |
| 1151 | `_theme-aufloesen` | `_theme-aufloesen(theme, akzent, class)` — **faktisch öffentlich**, da von `arbeitsblatt.typ:45` importiert und per `*` weitergereicht |

---

## 2. Signaturen und Parameter

### 2.1 `fachfarben` (Z. 35-45) und `fachnamen` (Z. 46-56)

Schlüssel (identisch in beiden): `MA`, `PH`, `IF`, `CH`, `BI`, `NW`, `DE`, `EN`, `KLS` (Großbuchstaben-Kürzel, 2-3 Zeichen).

| Schlüssel | Farbe | Name |
|---|---|---|
| MA | `rgb("#2f6fb5")` | "Mathematik" |
| PH | `rgb("#d4572a")` | "Physik" |
| IF | `rgb("#13866f")` | "Informatik" |
| CH | `rgb("#8b3fa3")` | "Chemie" |
| BI | `rgb("#3f8a2c")` | "Biologie" |
| NW | `rgb("#0e7f8c")` | "Naturwissenschaften" |
| DE | `rgb("#c0392b")` | "Deutsch" |
| EN | `rgb("#b5176d")` | "Englisch" |
| KLS | `rgb("#5b6b7f")` | "Klassenleitung" |

### 2.2 `kuerzel(class)` (Z. 67)

```typst
#let kuerzel(class) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `class` | pos | – | str / content / none | en | Klassenkürzel wie "MA-05", "PH-7", "IF-11" |

Rückgabe: Dictionary `(fach:, name:, jahrgang:)` (alle de). Regex `^([A-Z]{2,3})-?0*(\d+)`. Bei Nichttreffer alle drei `none`.

### 2.3 `kicker(class)` (Z. 77)

```typst
#let kicker(class) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `class` | pos | – | wie oben | en | Klassenkürzel |

Rückgabe: `none` oder String „Mathematik · Klasse 5“ / „… · Jahrgang 11“ (ab 11 „Jahrgang“, 5-10 „Klasse“, außerhalb 5-13 nur Fachname). Funktionsname `kicker` = englischer Typografie-Fachbegriff.

### 2.4 `fachfarbe(class)` (Z. 85)

```typst
#let fachfarbe(class) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `class` | pos | – | wie oben | en | Klassenkürzel; unbekannt → `fachfarben.MA` |

### 2.5 `kasten-stil(art, akzent, farbe: auto)` (Z. 116)

```typst
#let kasten-stil(art, akzent, farbe: auto) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `art` | pos | – | str-Enum (siehe 3.3), unbekannt → `("circle-info", none)` | de | Kastenart |
| `akzent` | pos | – | color | de | Akzentfarbe des Blatts |
| `farbe` | named | `auto` | auto / color | de | Überschreibt die Farbe der Kastenart |

Rückgabe: `(icon: str, farbe: color)` — Schlüssel `icon` en, `farbe` de.

### 2.6 `_klartext(x)` (Z. 58)

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `x` | pos | – | none/str/content/any | – | wandelt Content in String |

### 2.7 `_aussen(duplex, inhalt)` (Z. 122)

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `duplex` | pos | – | bool | en | beidseitiger Druck |
| `inhalt` | pos | – | function `n => content` | de | zeichnet die Seitenzahl |

### 2.8 `_seitenrand(m, n)` (Z. 128)

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `m` | pos | – | length oder margin-Dictionary (`inside`/`outside`/`x`/`left`/`right`) | abk | Seitenränder |
| `n` | pos | – | int | abk | Seitennummer |

Fallback `1.75cm` hart codiert (Z. 134).

### 2.9 `_marke(...)` (Z. 143)

```typst
#let _marke(inhalt, fill: black, size: 1em, radius: 1.5pt, font: auto, weight: 700, breite: auto, inset: (x: 0.5em, y: 0.4em), stroke: none, farbe: white) = text(size, box(
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `inhalt` | pos | – | content | de | Text der Marke |
| `fill` | named | `black` | color / tiling | en | Hintergrundfarbe |
| `size` | named | `1em` | length | en | Schriftgröße |
| `radius` | named | `1.5pt` | length | en | Eckenradius |
| `font` | named | `auto` | auto / str | en | Schrift |
| `weight` | named | `700` | int | en | Schriftstärke |
| `breite` | named | `auto` | auto / length | de | Breite (anderswo heißt dasselbe `width`) |
| `inset` | named | `(x: 0.5em, y: 0.4em)` | dict | en | Innenabstand |
| `stroke` | named | `none` | stroke | en | Rahmen |
| `farbe` | named | `white` | color | de | **Textfarbe** (anderswo ist `farbe` die Kasten-/Schattenfarbe) |

### 2.10 `_schatten-box(inhalt, versatz: 2.5pt, farbe: black)` (Z. 154) / `_schatten-block(inhalt, versatz: 4pt, farbe: black)` (Z. 163)

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `inhalt` | pos | – | content | de | Element |
| `versatz` | named | `2.5pt` (box) / `4pt` (block) | length | de | Schattenversatz |
| `farbe` | named | `black` | color | de | Schattenfarbe |

### 2.11 `_loesung-inline(titel, body, label-stil: it => it)` (Z. 173)

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `titel` | pos | – | content | de | Bezeichnung („Lösung 1a“) |
| `body` | pos | – | content | en | Inhalt |
| `label-stil` | named | `it => it` | function | mix (en+de) | Stil der Bezeichnung |

### 2.12 Theme-Funktionen (Z. 183, 294, 410, 547, 657, 780, 896, 1020)

Alle acht wörtlich: `#let <name>(akzent, class) = {`

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `akzent` | pos | – | color | de | Akzent-/Fachfarbe |
| `class` | pos | – | str / content | en | Klassenkürzel (wird für `kicker(class)` gefangen) |

### 2.13 `themes` (Z. 1138-1147)

Dictionary mit Schlüsseln `klar`, `atlas`, `skizze`, `labor`, `kontur`, `leiste`, `riso`, `bauhaus` (alle de bzw. Eigennamen, klein, ein Wort). Variablenname `themes` ist en. Achtung: `typstage` exportiert ebenfalls ein `themes` (anderes Paket, anderer Inhalt).

### 2.14 `_theme-aufloesen(theme, akzent, class)` (Z. 1151)

```typst
#let _theme-aufloesen(theme, akzent, class) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `theme` | pos | – | `none` / `"standard"` / Name (str) / function / dictionary | en | Theme-Auswahl |
| `akzent` | pos | – | `auto` / color | de | `auto` → `fachfarbe(class)` |
| `class` | pos | – | str / content | en | Klassenkürzel |

Rückgabe: `none` (klassische Darstellung) oder Theme-Dictionary. Name mix: `theme` (en) + `aufloesen` (de, ae-Umschrift... hier `oe`).

### 2.15 Lokale Hilfsfunktionen in den Themes (nicht exportiert)

| Theme | Zeile | Signatur (wörtlich) |
|---|---|---|
| klar | 185 | `kachel(inhalt, size: 1em)` |
| atlas | 296 | `kachel(inhalt, size: 1em)` |
| atlas | 300 | `reiter(titel, farbe, icon, rand: none)` |
| skizze | 414 | `klebeband(breite, hoehe, fill)` |
| skizze | 423 | `klecks(inhalt, size: 1em)` |
| labor | 551 | `tag(inhalt, fill: akzent, size: 0.8em)` |
| kontur | 663 | `versal(x)` |
| kontur | 667 | `kachel(inhalt, size: 1em)` |
| leiste | 784 | `rund(inhalt, size: 1em)` |
| riso | 900 | `raster(f, d: 2.2mm, r: 0.42mm)` |
| riso | 902 | `doppelt(baue, dx: 1.6pt, dy: 1.3pt)` |
| riso | 908 | `kreis(inhalt, size: 1em)` |
| bauhaus | 1025 | `form(n, inhalt, size: 1em)` |
| bauhaus | 1035 | `viertel(f, r: 0.9cm)` |

Lokale Konstanten: `tinte` (klar/atlas/skizze/labor/leiste/riso/bauhaus), `schwarz` (kontur statt `tinte`), `hand` (skizze), `mono`, `nacht` (labor), `disp` (kontur, leiste, riso, bauhaus; en-Abk.), `rahmen` (kontur), `band-b` (leiste, mix/abk), `notizgelb` (skizze), `pink` (riso, en), `grau` (bauhaus).

---

## 3. Struktur der Theme-Dictionaries

### 3.1 Dokumentierter Vertrag (Dateikopf Z. 9-23, wörtlich)

```
schrift       (text:, mathe:, groesse:, titel:)
rand          (top:, bottom:)                Seitenränder oben/unten
header-ascent Abstand Kopfzeile – Text
kopf          (title:, class:, copyright:, font-size:) => content
fuss          (duplex:) => content           nur in der Druckfassung
hintergrund   (print:, oben:, rand:) => content  Seitenhintergrund
marke         (nummer) => content            Nummer neben der ersten Zeile
marke-breite  length                         (Aufgaben ohne Titel)
aufgabe       (nummer:, titel:, icons:, punkte:, large:, number:) => content
teilaufgabe   (label) => content
loesung       (titel, body) => content
loesung-kopf  (titel) => content             Überschrift im Lösungsblatt
material-kopf (titel) => content
kasten        (art:, titel:, farbe:, breakable:, width:, body) => content
setup         body => content                weitere Show-Regeln
```

### 3.2 Tatsächliche Schlüssel (Soll/Ist, Konsument)

| Schlüssel | Typ / Hook-Signatur (wörtlich aus den Themes) | Sprache | Konsument (Datei:Zeile) | Default beim Konsumenten | Im Kopfkommentar? |
|---|---|---|---|---|---|
| `name` | str (= Theme-Name) | en/de | **niemand** (kein Lesezugriff gefunden) | – | **nein** |
| `schrift` | dict `(text:, mathe:, groesse:, titel:)` | de | arbeitsblatt.typ:331-335 | `(:)` | ja |
| `schrift.text` | str (Fontname) | en/de | :332 → Parameter `font` | `"Myriad Pro"` | ja |
| `schrift.mathe` | str (Fontname) | de | :333 → Parameter `math-font` | `"Fira Math"` | ja |
| `schrift.groesse` | length | de (oe-Umschrift: `groesse`) | :334 → Parameter `font-size` | `12pt` | ja |
| `schrift.titel` | length | de | :335 → Parameter `title-font-size` | `16pt` | ja |
| `rand` | dict | de | arbeitsblatt.typ:487 | `(:)` | ja, aber mit falschen Schlüsseln |
| `rand.top` | length | en | :488 | `2.3cm` (print) / `2.2cm` | ja — **von keinem Theme gesetzt** |
| `rand.kopf-oben` | length | de | :503 | `1.2cm` | **nein** (nur in Kommentar arbeitsblatt.typ:496) |
| `rand.bottom` | length | en | :505 | `1cm` | ja |
| `rand.innen` | length | de | :492 | `2.25cm` | **nein**; von keinem Theme gesetzt |
| `rand.aussen` | length | de (ss statt ß) | :493 | `1.25cm` | **nein**; nur `leiste` setzt es |
| `header-ascent` | length | en (Typst-Begriff) | :503, :545-546 | `0.8cm` | ja |
| `footer-descent` | length/ratio | en | :553 | `30%` | **nein**; von keinem Theme gesetzt |
| `kopf` | `(title: none, class: none, copyright: none, font-size: <pt>) => content` | Schlüssel de, Parameter en | :456-460 | – | ja |
| `fuss` | `(duplex: true) => content` | Schlüssel de (ss), Parameter en | :552-553 (nur `print`) | – | ja |
| `hintergrund` | `(print: true, oben: <cm>, rand: (:)) => content` | Schlüssel de; Parameter mix (`print` en, `oben`/`rand` de) | :555-557 | – | ja |
| `marke` | `n => content` (pos.) | de | aufgaben.typ:962 ff. | – | ja (dort `(nummer)`) |
| `marke-breite` | length (em) | de | aufgaben.typ:1053 | `2.2em` | ja |
| `aufgabe` | `(nummer: 1, titel: none, icons: (), punkte: none, large: true, number: true) => content` | mix: `nummer`,`titel`,`punkte` de; `icons`,`large`,`number` en | aufgaben.typ:982-999 | – | ja |
| `teilaufgabe` | `lbl => content` (pos.) | de; Param abk-en | aufgaben.typ:1179 | – | ja (dort `(label)`) |
| `loesung` | `(titel, body) => content` (pos.) | de; `body` en | aufgaben.typ:37-40 | – | ja |
| `loesung-kopf` | `titel => content` (pos.) | de | aufgaben.typ:220 | – | ja |
| `material-kopf` | `titel => content` (pos.) | de | aufgaben.typ:790 | – | ja |
| `kasten` | `(art: "info", titel: none, farbe: auto, breakable: false, width: auto, body) => content` | mix: `art`,`titel`,`farbe` de; `breakable`,`width`,`body` en | arbeitsblatt.typ:1521-1536 | – | ja |
| `setup` | `body => content` | en | arbeitsblatt.typ:617 | – | ja |

### 3.3 Parameter der Hook-Funktionen (gilt für alle Themes)

**`kopf`**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `title` | named | `none` | content/str | en | Blatttitel |
| `class` | named | `none` | content/str | en | Klassenkürzel |
| `copyright` | named | `none` | content/str | en | **in keinem Theme verwendet** |
| `font-size` | named | 20/21/21/18/26/22/27/25 pt je Theme | length | en | Titelgröße (entspricht `schrift.titel`, im Aufrufer `title-font-size`) |

**`fuss`**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `duplex` | named | `true` | bool | en | beidseitiger Druck |

**`hintergrund`** (nur `atlas`, `leiste`)

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `print` | named | `true` | bool | en | Druckfassung? |
| `oben` | named | `3.6cm` (atlas) / `3cm` (leiste) | length | de | oberer Seitenrand |
| `rand` | named | `(:)` | margin-dict | de | Seitenränder (Typst-Schlüssel `inside`/`outside`/`left`/`right`/`x`) |

**`aufgabe`**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `nummer` | named | `1` | int | de | Aufgabennummer |
| `titel` | named | `none` | content/none | de | Aufgabentitel |
| `icons` | named | `()` | array content | en | Icons vor dem Titel |
| `punkte` | named | `none` | content/none | de | formatierte Punkte |
| `large` | named | `true` | bool | en | große Überschrift |
| `number` | named | `true` | bool | en | Nummer anzeigen (Schalter!) — neben `nummer` (Wert) |

**`kasten`**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `art` | named | `"info"` | str-Enum | de | Kastenart |
| `titel` | named | `none` | content/none | de | Titel; `none` = ohne Kopf |
| `farbe` | named | `auto` | auto/color | de | Farbe überschreiben |
| `breakable` | named | `false` | bool | en | umbrechbar |
| `width` | named | `auto` | auto/length/ratio | en | Breite |
| `body` | pos | – | content | en | Inhalt |

Übersetzung im Aufrufer (arbeitsblatt.typ:1527-1535): Nutzerparameter `title` → `titel`, `headless: true` → `titel: none`, `accent-color` → `farbe`, `breakable` → `breakable`, `width` → `width`. Alle anderen gentle-clues-Argumente werden mit Theme **stillschweigend verworfen**.

### 3.4 String-Enum `art` (`_kasten-stil`, Z. 97-115)

| art | Icon (FontAwesome) | Farbe |
|---|---|---|
| `info` | circle-info | Akzent |
| `memo` | thumbtack | Akzent |
| `abstract` | align-left | Akzent |
| `conclusion` | flag-checkered | Akzent |
| `goal` | bullseye | Akzent |
| `notify` | bell | Akzent |
| `code` | code | Akzent |
| `task` | pencil | Akzent |
| `tip` | lightbulb | `_gelb` #a36a00 |
| `success` | circle-check | `_gruen` #2b9348 |
| `idea` | lightbulb | `_gelb` |
| `example` | pen-to-square | `_violett` #6c4fb0 |
| `question` | circle-question | `_orange` #e3752a |
| `warning` | triangle-exclamation | `_orange` |
| `danger` | bolt | `_rot` #c62e3a |
| `error` | circle-xmark | `_rot` |
| `experiment` | flask | `_tuerkis` #0e8a8a |

Alle 17 Werte sind **englisch** (aus gentle-clues übernommen), während der Parameter `art` und die deutschen Titel (`_kasten-titel` in arbeitsblatt.typ:1507: „Merke“, „Tipp“ …) deutsch sind. Sonderbehandlung: `art == "memo"` in jedem Theme; `art in ("warning", "danger", "error")` nur in `skizze` (Z. 511).

### 3.5 Schlüssel je Theme (Matrix)

x = gesetzt, – = fehlt.

| Schlüssel | klar | atlas | skizze | labor | kontur | leiste | riso | bauhaus |
|---|---|---|---|---|---|---|---|---|
| `name` | 187 | 311 | 431 | 553 | 672 | 792 | 919 | 1037 |
| `schrift` | 188 | 312 | 432 | 554 | 673 | 793 | 920 | 1038 |
| `rand` | 189 | 313 | 433 | 555 | 674 | 796 | 921 | 1039 |
| `header-ascent` | 190 | 314 | 434 | 556 | 675 | 797 | 922 | 1040 |
| `hintergrund` | – | 315 | – | – | – | 798 | – | – |
| `kopf` | 191 | 332 | 435 | 557 | 676 | 821 | 923 | 1041 |
| `fuss` | 207 | 346 | 470 | 582 | 698 | **–** | 942 | 1063 |
| `marke` | 208 | 347 | 471 | 583 | 699 | 830 | 943 | 1064 |
| `marke-breite` | 209 | 348 | 472 | 584 | 700 | 831 | 944 | 1065 |
| `aufgabe` | 210 | 349 | 473 | 585 | 701 | 832 | 945 | 1066 |
| `teilaufgabe` | 225 | 364 | 488 | 601 | 716 | 847 | 960 | 1081 |
| `loesung` | 226 | 365 | 489 | 602 | 719 | 848 | 961 | 1082 |
| `loesung-kopf` | 234 | 373 | 498 | 611 | 727 | 856 | 968 | 1092 |
| `material-kopf` | 239 | 374 | 499 | 615 | 728 | 857 | 969 | 1093 |
| `kasten` | 240 | 375 | 500 | 616 | 729 | 858 | 970 | 1094 |
| `setup` | 274 | 391 | 526 | 638 | 759 | 877 | 999 | 1118 |
| `footer-descent` | – | – | – | – | – | – | – | – |

`leiste` hat bewusst kein `fuss` (Seitenzahl steckt in `hintergrund`, nur wenn `print`).

### 3.6 Werte je Theme

| Theme | `schrift.text` | `schrift.mathe` | `schrift.groesse` | `schrift.titel` | `rand` | `header-ascent` | `marke-breite` | Zusatzschrift |
|---|---|---|---|---|---|---|---|---|
| klar | "Avenir Next" | "Fira Math" | 10.5pt | 20pt | `(kopf-oben: 1.3cm, bottom: 1.8cm)` | 0.75cm | 2.65em | – |
| atlas | "Myriad Pro" | "Fira Math" | 11pt | 21pt | `(kopf-oben: 1.45cm, bottom: 1.8cm)` | 1.25cm | 2.75em | – |
| skizze | "SF Pro Rounded" | "Fira Math" | 11pt | 21pt | `(kopf-oben: 1.1cm, bottom: 1.8cm)` | 0.7cm | 3.15em | "Playpen Sans" |
| labor | "Fira Sans" | "Fira Math" | 10.5pt | 18pt | `(kopf-oben: 1.1cm, bottom: 1.8cm)` | 0.7cm | 2.9em | "Fira Code" |
| kontur | "Helvetica Neue" | "Fira Math" | 10.5pt | 26pt | `(kopf-oben: 1.25cm, bottom: 1.8cm)` | 0.8cm | 2.75em | "Futura" |
| leiste | "Lato" | "Lato Math" | 10.5pt | 22pt | `(kopf-oben: 1.3cm, bottom: 1.4cm, aussen: 2.75cm)` | 0.8cm | 2.75em | "Montserrat" |
| riso | "PT Sans" | "Fira Math" | 11pt | 27pt | `(kopf-oben: 1.2cm, bottom: 1.8cm)` | 0.75cm | 2.95em | "Rockwell" |
| bauhaus | "Gill Sans" | "Fira Math" | 11.5pt | 25pt | `(kopf-oben: 1.2cm, bottom: 1.8cm)` | 0.8cm | 2.75em | "Gill Sans", "Futura" (Ziffern) |

Der Default von `kopf.font-size` wiederholt in jedem Theme den Wert von `schrift.titel` (doppelte Pflege: Z. 188/191, 312/332, 432/435, 554/557, 673/676, 793/821, 920/923, 1038/1041).

Aufgabennummer-Format: `str(nummer)` überall, außer `labor`: `[A#nummer]` (Z. 583, 592). Seitenzahl: `str(n)`, außer `labor`: `n/gesamt` (Z. 582).

`setup` je Theme: Show-Regeln `heading.where(level: 1|2|3)`, `set table(stroke: …)`, `set list(marker: …)`; zusätzlich `labor`: `show raw: set text(font: mono)` (Z. 647), `bauhaus`: `show math.equation.where(block: false): set text(size: 0.9em)` (Z. 1130).

---

## 4. State-, Label-, Query-Konventionen

- In `themes.typ` selbst: **kein** State, kein Label, keine Query. Nur `counter(page)` (Z. 123, 450, 582) und `here().page()` (Z. 318, 799).
- Das aufgelöste Dictionary wird von `arbeitsblatt.typ:616` in `_state_theme` geschrieben; der State ist in `aufgaben/0.3.1/aufgaben.typ:27` als `state("ab-theme", none)` definiert (State-Schlüssel `"ab-theme"`: Abkürzung + en).
- Theme-Auswahl-Strings: `"standard"` (= `none`), `"klar"`, `"atlas"`, `"skizze"`, `"labor"`, `"kontur"`, `"leiste"`, `"riso"`, `"bauhaus"`.

## 5. Validierung und Fehlermeldungen

| Zeile | Prüfung | Meldung (wörtlich) | Sprache |
|---|---|---|---|
| 1155 | `assert(theme in themes, …)` | `"Unbekanntes Theme " + repr(theme) + ". Verfügbar: standard, " + themes.keys().join(", ")` | de |
| 1162 | `panic(...)` bei falschem Typ | `"theme muss none, ein Name, eine Funktion oder ein Dictionary sein, erhalten: " + repr(theme)` | de |

Nicht geprüft:

- Schlüssel eines eigenen Theme-Dictionaries (Tippfehler wie `kopf-open`, `fuß`, `lösung` werden stillschweigend ignoriert → klassische Darstellung).
- Unbekannte `art` in `kasten-stil` (Z. 117: Fallback auf `info`).
- Unbekanntes Fach in `fachfarbe` (Z. 87: Fallback Mathe-Blau) und in `kicker` (→ `none`).
- Rückgabetyp einer eigenen Theme-Funktion.
- `akzent` (Typ color) wird nicht geprüft.

---

## 6. Inkonsistenzen (mit Zeile)

### 6.1 Dokumentation ↔ Code

1. **Z. 10** dokumentiert `rand (top:, bottom:)`, alle Themes setzen aber `kopf-oben:` und `bottom:` (Z. 189, 313, 433, 555, 674, 796, 921, 1039); `top` setzt keines. Der Konsument kennt zusätzlich `innen`, `aussen` (arbeitsblatt.typ:492-493) – undokumentiert.
2. **Z. 15** dokumentiert `marke (nummer)`, implementiert als `n => …` (Z. 208 u. a.); **Z. 18** `teilaufgabe (label)`, implementiert als `lbl => …` (Z. 225 u. a.). Unkritisch (positional), aber drei Namen für dasselbe.
3. Schlüssel `name` (Z. 187 u. a.) ist im Kopfkommentar nicht aufgeführt und wird nirgends gelesen.
4. `footer-descent` wird gelesen (arbeitsblatt.typ:553), ist aber weder dokumentiert noch gesetzt.
5. Kommentar Z. 4 sagt „Theme-Funktion `(akzent, class) => dictionary`“; Kommentar in aufgaben.typ:22-26 dokumentiert denselben Vertrag ein zweites Mal (dort ohne `marke`, `marke-breite`, `kasten`, `kopf` …) – zwei Stellen, die auseinanderlaufen können.

### 6.2 Sprachmischung innerhalb einer Signatur/Struktur

6. `rand`-Dictionary: `kopf-oben` (de) neben `bottom` (en) im selben Literal (Z. 189 ff.); `leiste` Z. 796: `kopf-oben`, `bottom`, `aussen`. Konsument: `top`/`bottom` (en) vs. `innen`/`aussen`/`kopf-oben` (de).
7. Theme-Schlüssel: 13 deutsche (`schrift`, `rand`, `kopf`, `fuss`, `hintergrund`, `marke`, `marke-breite`, `aufgabe`, `teilaufgabe`, `loesung`, `loesung-kopf`, `material-kopf`, `kasten`) neben englischen `header-ascent`, `footer-descent`, `setup`, `name`.
8. `kopf`-Hook: deutscher Schlüssel, ausschließlich englische Parameter `title`, `class`, `copyright`, `font-size` (Z. 191). `aufgabe`-Hook dagegen: `titel` (de) statt `title` (Z. 210). Derselbe Begriff heißt also in `kopf` `title`, in `aufgabe`/`kasten`/`loesung`/`loesung-kopf`/`material-kopf` `titel`.
9. `aufgabe`-Hook (Z. 210 u. a.): `nummer`, `titel`, `punkte` (de) + `icons`, `large`, `number` (en). Besonders heikel: `nummer` (Wert, int) und `number` (Schalter, bool) in derselben Signatur.
10. `kasten`-Hook (Z. 240 u. a.): `art`, `titel`, `farbe` (de) + `breakable`, `width`, `body` (en). Im Aufrufer heißen dieselben Dinge `title`, `accent-color`, `headless` (arbeitsblatt.typ:1528-1532) → drei Namensschichten: Nutzer `accent-color` → Hook `farbe` → Theme-Akzent `akzent`.
11. `hintergrund`-Hook (Z. 315, 798): `print` (en) + `oben`, `rand` (de).
12. `schrift`: `text` (en/neutral), `mathe`, `groesse`, `titel` (de); im Aufrufer `font`, `math-font`, `font-size`, `title-font-size` (en). Zusätzlich heißt die Titelgröße im `kopf`-Hook `font-size` (obwohl es `title-font-size` ist; `font-size` ist im Aufrufer die Grundschrift!).
13. `_marke` (Z. 143): `fill`, `size`, `radius`, `font`, `weight`, `inset`, `stroke` (en) + `breite`, `farbe` (de). `breite` hier vs. `width` im `kasten`-Hook.
14. `_loesung-inline` (Z. 173): `titel` (de), `body` (en), `label-stil` (mix).
15. `_theme-aufloesen` (Z. 1151): Name mix; Parameter `theme` (en), `akzent` (de), `class` (en).
16. Theme-Funktionen `(akzent, class)`: de + en in einer zweistelligen Signatur. `class` meint durchgehend das *Klassenkürzel/Kurskürzel* inkl. Fach („MA-05“), nicht die Klasse.
17. `kasten-stil` gibt `(icon:, farbe:)` zurück (Z. 118) – en + de.
18. `art`-Enum-Werte englisch (`"memo"`, `"tip"`, `"warning"` …), Parametername und Titel deutsch (Z. 97-115).

### 6.3 Dieselbe Sache, verschiedene Namen

19. Farbe: `akzent` (Theme-Parameter), `farbe` (Kasten-Hook, Schatten, `kasten-stil`), `fill` (`_marke`, `klebeband` Z. 414, `tag` Z. 551), `f` (`raster` Z. 900, `viertel` Z. 1035, Z. 973), `c` (Z. 932). In `_marke` bedeutet `farbe` die **Textfarbe**, `fill` die Fläche – in `_schatten-box` ist `farbe` die Fläche.
20. Breite: `breite` (`_marke`, `klebeband`, lokale Variable Z. 249/754), `width` (Kasten-Hook), `band-b` (Z. 783), `marke-breite` (Theme-Schlüssel).
21. Nummern-Marke: sechs lokale Namen für dieselbe Rolle – `kachel` (klar 185, atlas 296, kontur 667), `klecks` (skizze 423), `tag` (labor 551), `rund` (leiste 784), `kreis` (riso 908 – zeichnet ein abgerundetes Quadrat, keinen Kreis), `form` (bauhaus 1025, andere Signatur `form(n, inhalt, size:)`).
22. Textfarbe: `tinte` in 7 Themes, `schwarz` in `kontur` (Z. 659).
23. Displayschrift: `hand` (skizze), `mono` (labor), `disp` (kontur/leiste/riso/bauhaus).
24. Seitenrand: `rand` (Theme-Schlüssel, Dictionary mit eigenen Schlüsseln), `rand` (hintergrund-Parameter, Typst-margin-Dictionary mit `inside`/`outside`), `rand` (neuer `reiter`-Parameter, Strichstärke, Z. 300), `rahmen` (Strich, Z. 511, 660), `_seitenrand` (Z. 128), `_aussen` (Z. 122). Drei verschiedene Bedeutungen von `rand` in einer Datei.
25. Kopf/Header: `kopf` (Schlüssel), `header-ascent`, `kopf-oben`, im Aufrufer `custom-header`, `header-height`, `kopfzeile`.
26. Größe: `size` (alle Marken-Helfer), `groesse` (schrift), `font-size` (kopf), `gr` (lokal Z. 212 u. a.).
27. Kürzel: Funktion `kuerzel(class)` liefert `fach` – der Parameter heißt `class`, im Kommentar „Klassenkürzel“; in arbeitsblatt.typ:404 ist `kuerzel` zusätzlich eine lokale Variable für „A“/„T“ (Abbildung/Tabelle) – Namenskollision in der Bedeutung.

### 6.4 Umlaut-Umschrift

28. `groesse`, `loesung`, `loesung-kopf`, `kuerzel`, `_gruen`, `_tuerkis`, `_theme-aufloesen`, `hoehe` (ae/oe/ue-Umschrift); `fuss`, `aussen`, `_aussen` (ss statt ß). Konsistent umschrieben, aber Kommentare/Meldungen nutzen echte Umlaute. Fehlermeldung Z. 1155 enthält „Verfügbar“.

### 6.5 Typ-/Default-Uneinheitlichkeit

29. `farbe: auto` (Kasten, Z. 116, 240) vs. `(icon, none)` in `_kasten-stil`, wo `none` „Akzentfarbe“ bedeutet (Z. 98-105) – `auto` und `none` für dieselbe Aussage „nimm den Standard“.
30. `theme: none` und `theme: "standard"` sind gleichbedeutend (Z. 1152) – Alias; `"standard"` ist kein Schlüssel in `themes`, taucht aber in der Fehlermeldung als verfügbar auf.
31. `rand: none` (reiter, Z. 300) als „kein Strich“ vs. `stroke: none` in `_marke`.
32. Einheiten gemischt für gleichartige Maße: `marke-breite` in em, `rand`/`header-ascent` in cm, Kasten-`inset` in pt (klar 257) bzw. cm (bauhaus 1102), `above`/`below` der Kästen 1.2em (klar, atlas, skizze, labor) vs. 1.3em (leiste, riso, bauhaus) vs. 1.3em/1.4em (kontur Z. 755).
33. `versatz`-Default 2.5pt (`_schatten-box`) vs. 4pt (`_schatten-block`); in riso zusätzlich hart 4.5pt (Z. 908-909, 935).
34. `weight: 700` (Zahl) durchgehend, im übrigen Paket `"bold"` (aufgaben.typ:792).
35. Hooks uneinheitlich positional/named: `kopf`, `fuss`, `hintergrund`, `aufgabe` nur benannt; `marke`, `teilaufgabe`, `loesung`, `loesung-kopf`, `material-kopf`, `setup` nur positional; `kasten` benannt + positionales `body` am Ende. `loesung(titel, body)` positional vs. `kasten(titel: …, body)` benannt für dieselbe Art Argument.
36. Singular/Plural: `icons` (Plural, Array) vs. `punkte` (Plural, aber ein fertig formatierter Content oder `none`).
37. `number`/`large` sind Positiv-Schalter; im Kasten-Aufrufer ist `headless` ein Negativ-Schalter, der im Hook zu `titel: none` wird (arbeitsblatt.typ:1531).
38. `kontur` versalisiert Titel über `versal()` (echtes ẞ, Z. 663-666), aber `loesung-kopf`, `material-kopf` und der Kastentitel nutzen dort einfaches `upper(titel)` (Z. 727, 728, 748) → „GRÖSSEN“ statt „GRÖẞEN“ in genau diesen Stellen.
39. `kontur`-`aufgabe` (Z. 710): Icons ohne `text(fill: akzent, …)`, alle anderen Themes färben Icons in der Akzentfarbe.
40. `labor`-`aufgabe` hat vier Spalten `(auto, auto, 1fr, auto)` (Z. 589) – bei `number: false` rückt `if number {…}` als `none`-Zelle trotzdem in die erste Spalte (wie bei den anderen), unkritisch, aber abweichendes Raster.
41. `bauhaus`-`fuss` ruft `form(1, …)` (Z. 1063) – Seitenzahl immer Kreis; `marke`/`aufgabe` wechseln die Form nach Nummer.

---

## 7. Kopplungen

| Was | Wohin | Name dort |
|---|---|---|
| `schrift.text/mathe/groesse/titel` | `arbeitsblatt()`-Parameter | `font`, `math-font`, `font-size`, `title-font-size` (arbeitsblatt.typ:332-335; nur wenn diese `auto`) |
| `kopf(title:, class:, copyright:, font-size:)` | Aufruf arbeitsblatt.typ:460 | `title`, `class`, `copyright`, `title-font-size` → `font-size`; entfällt bei `custom-header` |
| `fuss(duplex:)` | arbeitsblatt.typ:553 | `duplex`; nur bei `print` |
| `hintergrund(print:, oben:, rand:)` | arbeitsblatt.typ:557 | `print`, berechnetes `oben`, `seiten-margin` |
| `rand.*`, `header-ascent`, `footer-descent` | `set page(margin:, header-ascent:, footer-descent:)` | arbeitsblatt.typ:487-553; Nutzer kann `header-ascent` per `..args` übersteuern (einziger erlaubter Sink-Schlüssel, :322) |
| `setup` | `show: th.setup` | arbeitsblatt.typ:617 |
| `kasten` | `_kasten(art, ..args)` → 15 Wrapper `abstract`, `info`, `question`, `memo`, `conclusion`, `tip`, `success`, `warning`, `error`, `example`, `goal`, `idea`, `experiment`, `notify`, `danger` | arbeitsblatt.typ:1521-1553 |
| ganzes Dictionary | `@schule/aufgaben:0.3.1` über `state("ab-theme")` | Hooks `aufgabe`, `teilaufgabe`, `loesung`, `loesung-kopf`, `material-kopf`, `marke`, `marke-breite` (aufgaben.typ:27-40, 220, 790, 962, 982, 1053, 1179) |
| `@schule/klassenarbeit:0.4.0` | importiert `@schule/arbeitsblatt:0.4.0: *` (klassenarbeit.typ:1) | erbt `themes`, `_theme-aufloesen` transitiv |

Importierte Versionen in dieser Datei: nur `@preview/fontawesome:0.6.0` (identisch zu arbeitsblatt.typ:38). Keine veralteten `@schule`-Versionen in `themes.typ` selbst.

Schriften (Systemabhängigkeiten, nicht im Paket): Avenir Next, Myriad Pro, SF Pro Rounded, Playpen Sans, Fira Sans, Fira Code, Fira Math, Helvetica Neue, Futura, Lato, Lato Math, Montserrat, PT Sans, Rockwell, Gill Sans. Mehrere davon sind macOS-/Adobe-gebunden.

---

## 8. Altlasten, tote Teile, Auffälligkeiten

1. **Toter Schlüssel `name`** in allen acht Themes (Z. 187, 311, 431, 553, 672, 792, 919, 1037): nirgends gelesen.
2. **Toter Parameter `copyright`** im `kopf`-Hook aller Themes (Z. 191, 332, 435, 557, 676, 821, 923, 1041): wird übergeben, aber nie gezeichnet → mit Theme verschwindet der Copyright-Hinweis.
3. **Tote Enum-Einträge `task` und `code`** in `_kasten-stil` (Z. 104-105): arbeitsblatt.typ definiert dafür keinen `_kasten`-Wrapper (Z. 1539-1553 enthalten 15 Arten ohne `task`/`code`); die beiden Arten erreichen den Theme-Hook nie.
4. **Redundantes `upper()`** in `kuerzel` Z. 71: Regex erlaubt ohnehin nur `[A-Z]`.
5. **Hilfsfunktionen für Theme-Autoren nicht exportiert**: Der Kopfkommentar und die Doku (arbeitsblatt.typ:977) bewerben eigene Themes als Funktion `(akzent, class) => dictionary`, aber `kasten-stil`, `kicker`, `fachfarbe`, `kuerzel`, `fachfarben` sowie die eingebauten Theme-Funktionen sind über das Paket nicht importierbar (nur `themes` und `_theme-aufloesen`). Ein eigenes Theme kann also weder die Fachzeile noch die Kastenfarben wiederverwenden, und ein Theme lässt sich nur per `(akzent, class) => themes.klar(akzent, class) + (…)` ableiten.
6. `_theme-aufloesen` ist als privat markiert, wird aber modulübergreifend importiert und landet per `*` im öffentlichen Namensraum des Pakets (und damit auch von `klassenarbeit`).
7. Bei `theme` als fertigem Dictionary (Z. 1159-1160) wird `akzent` ignoriert – undokumentiert.
8. `kicker` Z. 81: Jahrgang außerhalb 5-13 liefert nur den Fachnamen; `kuerzel` matcht `KLS` (Klassenleitung), `kicker("KLS-5")` ergibt „Klassenleitung · Klasse 5“.
9. Kommentar Z. 34 „Unbekannte Fächer bekommen das Mathe-Blau“ – stiller Fallback statt Hinweis.
10. `_seitenrand` Z. 134: hart codierter Fallback `1.75cm`, der denselben Wert wie arbeitsblatt.typ:494/500 dupliziert.
11. `kopf.font-size`-Default dupliziert `schrift.titel` in jedem Theme (siehe 3.6).
12. Kasten-Grundgerüst (`let st = kasten-stil(...)`, `let memo = art == "memo"`, `width: if width == auto { 100% } else { width }`) achtfach kopiert (Z. 241-249, 376-378, 501-515, 617-620, 730-754, 859-862, 971-976, 1095-1098); ebenso das `aufgabe`-Raster (8 Kopien, Z. 210-224 usw.) und die drei `heading`-Show-Regeln.
13. Uncommittete Änderung an `atlas` (siehe Abschnitt 0) ist noch nicht versioniert.
14. Im Repo (außerhalb dieser Datei) liegt `aufgaben/0.3.1/aufgaben.typ.orig` als unversionierte Altlast (git status).
15. Keine auskommentierten Codevarianten in `themes.typ`; keine `.orig`-Datei neben `themes.typ`.
