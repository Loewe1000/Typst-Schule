# Konvention C: Regelbasierter Hybrid (Typst-Wörter englisch, alles andere deutsch)

Entwurf für die 0.4.x-Linie der `@schule`-Pakete (Zielversion 0.4.1 in arbeitsblatt, klassenarbeit, aufgaben; Hilfspakete ziehen mit der jeweils nächsten freien Nummer nach). Faktenbasis: die Inventare unter `scratchpad/inventar/`. Am Repo wurde nichts geändert.

Leitgedanke in einem Satz: **Wie etwas aussieht, sagt man in Typst-Wörtern; was es in der Schule ist, sagt man auf Deutsch; ein Name ist nie beides.**

---

## 1. Sprachregel, Umlaute, Schreibweise

### 1.1 Die Regel

> **R1 (Zeichen).** Jeder Name (Funktion, Parameter, Dictionary-Schlüssel, Enum-Wert, State-Schlüssel) passt auf `^_?[a-z][a-z0-9]*(-[a-z0-9]+)*$`. Also kebab-case, nur ASCII, keine Umlaute, kein ß, kein snake_case, kein camelCase.
>
> **R2 (Typst-Wort).** Ein Name ist **englisch genau dann, wenn er in der Liste T steht**. In T kommt ein Name nur, wenn beide Tests bestanden sind:
> 1. *Namenstest:* Der Name existiert buchstabengleich als benannter Parameter oder Funktion der Typst-Standardbibliothek (oder ist eines der vier Komposita aus T3).
> 2. *Durchreichtest:* Der Wert hat hier denselben Typ und dieselbe Wirkung wie dort; man könnte ihn unverändert an den gleichnamigen Typst-Parameter weitergeben.
>
> **R3 (Pflicht).** Steht ein Begriff in T, **muss** er so heißen. Deutsche Synonyme dafür sind verboten (Liste V).
>
> **R4 (Deutsch).** Jeder andere Name besteht ausschließlich aus Wörtern der Liste D (deutsches Wörterbuch des Projekts, inklusive der im Duden geführten Lehnwörter wie `duplex`, `logo`, `info`, `code`, `qr`).
>
> **R5 (keine Mischung).** Ein Name ist entweder ein ganzer T-Eintrag oder besteht nur aus D-Wörtern. Braucht ein Typst-Wort einen deutschen Besitzer, wird **geschachtelt statt zusammengesetzt**: `korrekturrand: (width: 5cm)`, nicht `korrekturrand-width` und nicht `randbreite`.

Ein Lint braucht dafür keine Sprachkenntnis: Name an `-` zerlegen, ganzen Namen in T suchen, sonst jedes Segment in D suchen, V-Treffer melden.

### 1.2 Liste T (geschlossen; Erweiterung nur per Review mit beiden Tests)

**T1 – Einzelwörter (wörtliche Typst-Parameter/-Funktionen):**

| Name | Typst-Herkunft | Typ hier |
|---|---|---|
| `title` | `document(title:)`, `outline(title:)`, `title()` | content, str, none |
| `body` | Konvention aller Elementfunktionen | content |
| `label` | Typ `label`, `ref`, `figure` | label, str, none |
| `caption` | `figure(caption:)` | content, none |
| `paper` | `page(paper:)` | str |
| `page` | Funktion `page` | dictionary mit `page`-Argumenten |
| `header` | `page(header:)` | `auto`, `none`, content |
| `margin` | `page(margin:)` | length oder dictionary (`top`, `bottom`, `inside`, `outside`, `left`, `right`, `x`, `y`, `rest`) |
| `font` | `text(font:)` | str, array, auto |
| `columns` | `grid(columns:)` | auto, int, array |
| `rows` | `grid(rows:)` | int, fraction |
| `gutter` | `grid(gutter:)` | length |
| `width`, `height` | `block`, `box`, `image` | auto, length, ratio |
| `fill` | `block(fill:)`, `text(fill:)` | color, none |
| `stroke` | `line(stroke:)` | stroke |
| `align` | `grid(align:)` | alignment |
| `inset` | `block(inset:)` | length, dictionary |
| `numbering` | `enum(numbering:)`, `heading(numbering:)` | `auto`, `none`, Numbering-Muster |
| `breakable` | `block(breakable:)` | bool |
| `angle` | `rotate(angle:)` | angle |
| `dx`, `dy` | `move(dx:, dy:)` | length |

**T2 – wörtliche Typst-Bindestrichnamen:** `header-ascent`, `footer-descent`, `column-gutter`, `row-gutter`.

**T3 – vier Komposita „Typst-Ding + Typst-Eigenschaft“** (einzige Namen in T, die nicht wörtlich in Typst vorkommen; siehe Schwäche 8.2): `font-size`, `title-size`, `caption-size`, `math-font`.

Mehr gibt es nicht. Insbesondere stehen **nicht** in T: `class`, `print`, `date`, `theme`, `workspace`, `subtitle`, `teacher`, `landscape`, `flipped`, `tight`, `spacing`, `color`, `size` (allein), `show`, `set`, `get`, `reset`, `link`, `icon`.

### 1.3 Liste V (verbotene Wörter und ihr Ersatz)

Der Lint meldet diese Segmente mit Ersatzvorschlag.

| verboten | stattdessen | Grund |
|---|---|---|
| `titel` | `title` | R3 |
| `breite`, `hoehe` | `width`, `height` | R3 |
| `spalten`, `zeilen` | `columns`, `rows` | R3 |
| `farbe`, `color` | `fill` (Füllung/Textfarbe) oder `akzent` (Leitfarbe) | R3 / ein Wort je Begriff |
| `schrift`, `schriftgroesse`, `size` | `font`, `font-size` | R3 |
| `rand` (allein) | `margin` (Seitenrand) oder `korrekturrand` | R3 |
| `beschriftung` | `caption` | R3 |
| `nummerierung` | `numbering` | R3 |
| `class` | `klasse` | Durchreichtest scheitert (`math.class` ist etwas anderes) |
| `print` | `druck` | kein Typst-Parameter |
| `workspace`, `workspaces` | `arbeitsflaeche`, `arbeitsflaechen` | kein Typst-Parameter |
| `theme`, `themes` | `gestaltung`, `gestaltungen` | kein Typst-Begriff |
| `teacher`, `student`, `date`, `subtitle` | `lehrkraft`, `schueler`, `datum`, `untertitel` | kein Typst-Parameter bzw. Typ passt nicht (`document(date:)` ist `datetime`) |
| `landscape`, `flipped` | `querformat` | `landscape` ist kein Typst-Name; `flipped` bleibt über `page: (flipped: true)` erreichbar |
| `points`, `be` | `punkte` | ein Wort je Begriff |
| `show`, `set`, `get`, `reset`, `format`, `is`, `no`, `non`, `only`, `custom`, `settings`, `options`, `template`, `item`, `items`, `tasks`, `curr`, `idx`, `mv`, `sub`, `lsg`, `aufg`, `opts` | deutsche Wörter laut Abschnitt 2 | R4, keine Abkürzungen |
| `keine`, `false` (als String), `aus`, `nein` | `none` bzw. `false` | Abschnitt 3 |

### 1.4 Liste D (Kernwörterbuch, Auszug der festen Begriffe)

`aufgabe, teilaufgabe, loesung, material, erwartung, punkte, arbeitsflaeche, klasse, lehrkraft, schueler, datum, untertitel, fach, thema, jahrgang, stufe, niveau, typ, stichworte, stand, druck, digital, duplex, zweifach, querformat, variante, vorschau, dateiname, datei, gestaltung, akzent, kopf, fuss, hintergrund, kasten, marke, einzug, kurzformen, sozialform, symbol, kompakt, nummer, teil, auswahl, ort, anzeige, position, summe, vorlage, muster, raster, kariert, liniert, eintraege, eintragsabstand, zeichnung, luecke, verdeckt, platz, sonst, eng, nebeneinander, seitenumbruch, seitenzahlen, namensfeld, infotabelle, logo, klausurboegen, korrekturrand, seite, frei, ergebnisse, ergebnisdruck, notenbereich, punktetabelle, vorschlag, versatz, erwartungshorizont, bewertungstabelle, punktzahl, punktanzeige, optionen, setzen, zuruecksetzen, ist, quelle, regeln, qr, code, verweis, info, merke, tipp, frage, achtung, fehler, beispiel, ziel, idee, experiment, mitteilung, gefahr, einfuehrung, zusammenfassung, erledigt`

Abkürzungen sind nur als Enum-Werte und nur aus der Liste A erlaubt: `ea`, `pa`, `ga` (Sozialform), `sek-1`, `sek-2`, `a3`–`a6`, `qr`.

### 1.5 Umlaut-Regel: `ae/oe/ue/ss`

Entscheidung: **ASCII-Umschrift, ohne Ausnahme und ohne Alias.** `luecke`, `loesung`, `klausurboegen`, `arbeitsflaeche`, `fuss`, `zuruecksetzen`.

Begründung:
1. **Ein Name, eine Schreibweise an allen Orten.** Derselbe Begriff erscheint als Paketname, Importpfad, Dateiname, Funktionsname, Parameter, Enum-Wert, Variantenname und `--input`-Wert. Paket- und Dateinamen sind ASCII. Heute heißt das Paket `klausurboegen`, die Funktion `klausurbögen`, der Parameter `klausurboegen`, der Wert `"klausurboegen"`. Nur die ASCII-Form kann überall gleich sein.
2. **Kein doppelter Variantenraum.** `größe` und `groesse` sind für Typst verschiedene Namen (`unexpected argument`). Zusätzlich gibt es `ü` in zwei Unicode-Formen (NFC/NFD, etwa nach Kopieren aus Dateinamen unter macOS); der Fehler ist dann unsichtbar.
3. **Bestand.** `loesungen` steht in 483 Köpfen, `loesung` in 85 Aufrufen, `#lösung(` kommt 0-mal vor. Die Umlaut-Namen sind die Minderheit (`lücke` 111, `klausurbögen` 0 direkte Aufrufe, `weißer-rand`, `häufigkeitsanalyse`).
4. **Prüfbarkeit.** R1 ist ein einziger regulärer Ausdruck.
5. **Tastatur.** iPad-App (Typist), fremde Rechner, Terminal und `sys.inputs` funktionieren ohne Umlaut-Eingabe.

Preis: `arbeitsflaeche`, `zuruecksetzen` und `fuss` sehen unschön aus, und 111 `#lücke(`-Aufrufe ändern sich. Sichtbarer Text (Überschriften, PDF-Dateinamen wie `… - Lösung.pdf`, Fehlermeldungen) behält echte Umlaute.

### 1.6 Schreibweise

- kebab-case überall, auch bei internen Namen und State-Schlüsseln (`_zustand-optionen`, Schlüssel `"schule/aufgaben/optionen@1"`).
- Interne Namen beginnen mit `_` und stehen in einer Datei `intern.typ`, die der Entrypoint nicht per `*` weiterreicht. Zugriffe anderer Pakete laufen über einen expliziten Import von `intern`, nie über das Wildcard-Leck.
- Der Entrypoint re-exportiert nur ausdrücklich benannte Namen. Fremdpakete (cetz, fontawesome, gentle-clues …) werden nicht mehr mit `*` durchgereicht; ihre Namen unterliegen der Regel nicht.

### 1.7 Lint (Erweiterung von `technik/sig.py --lint`)

Eingabe: Signatur-Snapshot (`sig.py --json`) plus eine Datei `namen.toml` mit T, V, D, A und den Enum-Wertelisten.

| Nr. | Prüfung | Mechanik |
|---|---|---|
| L1 | Zeichenvorrat | Regex aus R1 |
| L2 | Sprache | ganzer Name ∈ T, sonst alle Segmente ∈ D |
| L3 | keine Mischung | ein Segment ∈ T-Wortschatz und Name ∉ T → Fehler |
| L4 | verbotene Wörter | Segment ∈ V → Fehler mit Ersatz |
| L5 | fester Begriff | gleicher Parametername in zwei Funktionen → gleicher Typ-Vermerk im Docstring |
| L6 | Enum-Werte | deutsch/ASCII/kebab; kein Wert ∈ {`keine`, `false`, `aus`, `nein`, `""`} |
| L7 | Typmischung | kein Parameter dokumentiert `bool` zusammen mit `str` oder `dictionary` |
| L8 | Schalter | bool-Parameter beginnen nicht mit `kein`, `ohne`, `nicht`, `no`, `non`, `hide` |
| L9 | Sink | `..` nur als `..veraltet` (Altnamen-Abfang) oder dokumentierte Positionsliste |
| L10 | Options-Schlüssel | Schlüssel des Options-States = Kopfparameter gleichen Namens |

Was der Lint nicht kann: den Durchreichtest (Typ und Wirkung) prüfen und deutsche Zusammensetzungen durchschauen (siehe 8.3).

---

## 2. Grammatik der Namen

### 2.1 Funktionen

| Art | Muster | Beispiele |
|---|---|---|
| Dokumentvorlage (für `#show:`) | Substantiv, Name der Dokumentart | `arbeitsblatt`, `klassenarbeit`, `klausurboegen` |
| Baustein (setzt mitgebrachten Inhalt) | Substantiv Singular | `aufgabe`, `teilaufgabe`, `loesung`, `material`, `erwartung`, `luecke`, `arbeitsflaeche`, `merke`, `tipp` |
| Behälter für mehrere Bausteine | Substantiv Plural bzw. Adverb der Anordnung | `teilaufgaben`, `nebeneinander` |
| Sammelausgabe (setzt gesammelten Inhalt an dieser Stelle, wie `outline()`) | Substantiv Plural oder Sammelwort | `loesungen()`, `materialien()`, `erwartungshorizont()`, `bewertungstabelle()` |
| Formgeber (verändert Darstellung des Inhalts) | Partizip/Adjektiv | `kariert`, `liniert`, `verdeckt` |
| Aktion ohne Ausgabe (ändert Zustand) | `<objekt>-<infinitiv>` | `optionen-setzen(...)`, `aufgaben-zuruecksetzen()` |
| Abfrage (liefert Wert, braucht `context`) | Substantiv des Werts | `punktzahl(...)`, `punktanzeige(...)` |
| Prädikat (liefert bool) | `ist-<zustand>` | `ist-loesungsfassung()`, `ist-druckfassung()` |

Die englischen Präfixe `show-`, `set-`, `get-`, `reset-`, `format-` entfallen vollständig. `show` und `set` sind in Typst Schlüsselwörter für Regeln, keine Funktionspräfixe; der Namenstest scheitert.

### 2.2 Singular und Plural

- Funktion im Singular = ein Baustein; im Plural = Behälter oder Sammelausgabe.
- Parameter im Singular = ein Wert (`klasse`, `arbeitsflaeche`, `variante`); im Plural = Array **oder** Kopfschalter, der alle Bausteine dieser Art betrifft (`loesungen`, `materialien`, `punkte`, `arbeitsflaechen`, `varianten`, `stichworte`, `jahrgaenge`).
- Enum-Werte: Singular benennt einen Ort oder eine Form (`"seite"`, `"rand"`), Plural eine Menge von Bausteinen (`"aufgaben"`, `"teilaufgaben"`).
- Zwei Namen dürfen sich nicht nur durch das Plural-Suffix unterscheiden, wenn sie im selben Aufruf vorkommen können (`"seite"`/`"seiten"`, `variante`/`varianten` entfallen deshalb).

### 2.3 Schalter

- Positiv formuliert; `true` bedeutet „ist da / ist so“. Der Standardwert darf `true` sein.
- Kein `kein-`, `ohne-`, `non-`, `hide-`, `-only`. Aus `sub: true` (schaltet etwas ab) wird `notenbereich: true`.
- Zwei Funktionen, die sich nur durch eine Verneinung unterscheiden, werden zu einer mit Parameter (`print-pagebreak`/`non-print-pagebreak` → `seitenumbruch(druck:)`).

### 2.4 Feste Wörter (ein Wort je Begriff, paketübergreifend)

| Begriff | Wort | Liste | ersetzt heute |
|---|---|---|---|
| Titel | `title` | T | `title`, `titel`, `exam` |
| Untertitel | `untertitel` | D | `subtitle`, `subexam` |
| Klasse/Kurs | `klasse` | D | `class` |
| Lehrkraft | `lehrkraft` | D | `teacher` |
| Datum (freier Text) | `datum` | D | `date` |
| Schülername | `schueler` | D | `student` |
| Leitfarbe | `akzent` | D | `akzent`, `accent-color`, `farbe` (Hook) |
| Füll-/Textfarbe | `fill` | T | `color`, `fill-color`, `dark-color` |
| Linienstil | `stroke` | T | `line-stroke` |
| Breite, Höhe | `width`, `height` | T | `width`, `height`, `rand` (Breite), `hoehe` |
| Abstand zwischen Spalten/Zellen | `gutter` | T | `gutter`, `spacing` (minipage) |
| Seitenrand | `margin` | T | `rand.*`, `page-settings.margin` |
| Rastermaß (Kästchen, Zeilenabstand) | `raster` | D | `grid-size`, `line-height`, `lineheight`, `linienabstand`, `scale` |
| Nummerierungsmuster | `numbering` | T | `numbering`, `teilaufgabe-numbering` |
| konkrete Nummer/Marke | `nummer` | D | `nummer`, `item-label`, `number` (bool) |
| Lösung | `loesung` / `loesungen` | D | `loesung`, `lsg`, `solution` |
| Punkte | `punkte` | D | `punkte`, `points`, `be` |
| Arbeitsfläche | `arbeitsflaeche` / `arbeitsflaechen` | D | `workspace`, `workspaces` |
| Druckfassung | `druck` | D | `print`, `print-state` |
| Schrift | `font`, `math-font` | T | `font`, `schrift.text`, `schrift.mathe` |
| Schriftgröße | `font-size`, `title-size`, `caption-size` | T3 | `font-size`, `title-font-size`, `header-font-size`, `figure-font-size`, `schrift.groesse`, `schrift.titel` |
| Gestaltung | `gestaltung` | D | `theme` |
| Kopfzeilen-Inhalt | `header` | T | `custom-header` |
| Kopf-/Fuß-Hook | `kopf`, `fuss` | D | `kopf`, `fuss` |
| Typst-Seitenargumente | `page` | T | `page-settings` |
| Symbol | `symbol` / `symbole` | D | `icon`, `icons` |
| Teilaufgaben-Index | `teil` | D | `teil` (vier Bedeutungen) |
| Darstellungsvorlage (Funktion) | `vorlage` | D | `punkte-template*` |
| kleinere Darstellung | `kompakt` | D | `large` (umgekehrt), `compact` |
| Variante | `varianten`, `vorschau` | D | `varianten`, `variante`, `vorschau-alle` |

---

## 3. Wertekonvention

### 3.1 Typ je Schalterart

| Situation | Typ | Beispiel |
|---|---|---|
| echte Ja/Nein-Eigenschaft | `bool` | `druck`, `duplex`, `querformat`, `zweifach`, `arbeitsflaechen`, `kompakt`, `eng`, `breakable` |
| „Paket entscheidet“ (Standard aus Gestaltung, Fach, Kontext) | `auto` | `akzent: auto`, `font-size: auto`, `varianten: auto`, `header: auto` |
| „nichts davon“ bei allem, was nicht bool ist | `none` | `loesungen: none`, `punkte: none`, `title: none`, `arbeitsflaeche: none` |
| drei oder mehr Zustände, oder zwei Zustände ohne Ja/Nein-Sinn | String-Enum | `loesungen: "seite"`, `muster: "kariert"` |
| Einschalten mit Einstellungen | `none` \| `auto` \| dictionary | `klausurboegen: (muster: "liniert")`, `erwartungen: (erreicht: true)` |
| Kurzform/Langform (wie Typst `margin`, `stroke`) | Enum-String \| dictionary; der String ist der Wert des ersten Schlüssels | `punkte: "alle"` = `punkte: (anzeige: "alle")` |

### 3.2 Ein einziges „aus“

- bool-Parameter: `false`.
- Alle anderen: `none`.
- Nie ein String (`"keine"`, `"false"`, `""`), nie `false` bei einem Parameter, der sonst Strings, Inhalte oder Dictionaries nimmt. Kein Dictionary-Schlüssel `show`.
- Kein Parameter mischt `bool` mit `str` oder `dictionary` (L7). Damit entfallen `page-numbering: true | "reset"`, `klausurboegen: false | (…)`, `erwartungen: true | (…)`, `info-table: false | (…)`, `vorschlag: false | [..]`, `workspace: false`.

### 3.3 Enum-Werte

- Deutsch, ASCII, kebab-case, kleingeschrieben: `"einzelseiten"`, `"fortlaufend"`, `"sek-1"`, `"pa"`.
- Ausnahme: Werte, die Typst selbst definiert, bleiben Typst (`paper: "a4"`, Numbering-Muster `"a)"`, `"1.1"`).
- Jeder Enum-Parameter wird geprüft. Meldungsformat einheitlich: ``paket: funktion(`parameter`): ungültiger Wert <repr> – erlaubt: …``. Altnamen: ``arbeitsblatt: `class` heißt ab 0.4.1 `klasse` ``.

### 3.4 Einheiten

- Längen sind immer Typst-Längen (`5mm`, `1.25em`). Nackte Zahlen bedeuten nie Zentimeter.
- Zählwerte sind `int` und tragen das Gezählte im Namen oder in der Doku: `rows: 4`, `eintragsabstand: 2` (Rasterschritte).
- `width` ist überall eine Länge. `kariert(width: 12)` als Kästchenzahl entfällt.
- Faktoren entfallen zugunsten von Längen (`scale: 1` → `raster: 0.5cm`).

### 3.5 Positional und benannt

- `body` steht in der Definition immer **zuletzt** und ist positional.
- Davor positional nur Pflicht- oder Hauptargumente in fester Reihenfolge: `erwartung(punkte, body)`, `verweis(url, body)`, `qr-kasten(url, body)`, `qr-code(url)`, `punktzahl(aufgabe)`.
- Alles Optionale ist benannt. Kein Wert darf zugleich benannt und positional übergeben werden (`aufgabe[Titel][Text]` entfällt, `title:` bleibt).
- Variable Kinderlisten wie in `grid`: `teilaufgaben(..inhalte)`, `nebeneinander(..inhalte)`.
- Einzige Kurzform: bei `kariert` und `liniert` darf das erste Positionsargument `rows` ersetzen (`kariert(4)`), weil das die häufigste Schreibweise ist.
- Einstellungen werden benannt übergeben, nie als positionales Dictionary: `optionen-setzen(loesungen: "sofort")`.
- Ein Sink `..veraltet` am Ende der benannten Parameter dient nur dazu, alte Namen mit „heißt jetzt“ abzuweisen und Tippfehler mit Vorschlag zu melden (Muster `technik/compat.typ`).

---

## 4. Options-Schema für Lösungen, Material, Punkte, Arbeitsflächen

Gilt wortgleich in `arbeitsblatt(...)`, `klassenarbeit(...)` und `optionen-setzen(...)` (aufgaben). Die Prüfung liegt in `aufgaben`, damit sie auch ohne `arbeitsblatt` wirkt. State-Schlüssel und Kopfparameter heißen gleich (L10).

| Option | Typ | Werte | Standard |
|---|---|---|---|
| `loesungen` | `none` \| Enum | `"sofort"`, `"folgend"`, `"ende"`, `"seite"`, `"einzelseiten"`, `"nur"` | `none` |
| `materialien` | `none` \| Enum | `"sofort"`, `"ende"`, `"seite"`, `"einzelseiten"` | `"einzelseiten"` |
| `punkte` | `none` \| Enum \| dictionary | Kurzform = `anzeige` | `none` |
| `punkte.anzeige` | Enum | `"aufgaben"`, `"teilaufgaben"`, `"alle"` | `"aufgaben"` |
| `punkte.position` | Enum | `"ende"`, `"rand"` | `"ende"` |
| `punkte.summe` | bool | Gesamtsumme zeigen | `true` |
| `punkte.vorlage` | `auto` \| Funktion \| dictionary | `punkte => content` oder `(aufgabe: fn, teilaufgabe: fn)` | `auto` |
| `arbeitsflaechen` | bool | | `true` |
| `numbering` | Numbering-Muster | ein Zähler = nur Teil (`"a)"`), zwei Zähler = Aufgabe.Teil (`"1.1"`) | `"a)"` |
| `druck` | bool | | `false` |

Abbildung der alten Werte:

| alt | neu |
|---|---|
| `loesungen: "false"`, `"keine"`, `false`, `none` | `loesungen: none` |
| `loesungen: "sofort"`, `"folgend"`, `"seite"`, `"nur"` | unverändert |
| `loesungen: "seiten"` | `"einzelseiten"` |
| `loesungen: "reinquetschen"` | `"ende"` |
| `materialien: "keine"`, `"false"`, `false` | `none` |
| `materialien: "folgend"` | `"sofort"` (war schon ein Alias) |
| `materialien: "seiten"` | `"einzelseiten"` |
| `punkte: "keine"` | `none` |
| `punkte: "keine-summe"` | `(anzeige: "aufgaben", summe: false)` |
| `punkte-position: "rand"` | `punkte: (position: "rand")` |
| `punkte-template: fn` (klassenarbeit), `punkte-template-aufgabe/-teilaufgabe` | `punkte: (vorlage: fn)` bzw. `(vorlage: (aufgabe: fn, teilaufgabe: fn))` |
| `teilaufgabe-numbering: "1."` | `numbering: "1.1"` |

Vorbehalt: Die Zuordnung `"reinquetschen"` → `"ende"` (am Dokumentende ohne Seitenumbruch) und `"seiten"` → `"einzelseiten"` (je Aufgabe eigene Seite) folgt der Lesart der Inventare; die genaue Wirkung von `"reinquetschen"` ist dort nicht beschrieben und muss vor der Umsetzung am Code bestätigt werden.

Auf Bausteinebene: `aufgabe(arbeitsflaeche: none | content)`, `teilaufgabe(arbeitsflaeche: none | content)`; frei stehend `arbeitsflaeche(body)`. Der Kopfschalter `arbeitsflaechen: false` blendet alle drei aus.

Variantenvorlagen: `druck: (druck: true)`, `digital: (druck: false)`, `loesung: (druck: true, loesungen: "nur", arbeitsflaechen: false)`, `zweifach: (druck: true, zweifach: true)`; in klassenarbeit zusätzlich `klausurboegen`. Unbekannte Variantennamen sind ein Fehler.

---

## 5. Neue Signaturen

### 5.1 `arbeitsblatt`

```typ
#let arbeitsblatt(
  // Kopf
  title: none,
  klasse: none,
  quelle: none,              // URL, erscheint als QR-Code im Kopf
  header: auto,              // auto | none | content
  // Fassung und Papier
  druck: false,
  duplex: true,
  zweifach: false,
  paper: "a4",
  querformat: false,
  page: (:),                 // weitere Argumente für `set page`, auch header-ascent
  // Aufgabenoptionen (Abschnitt 4)
  loesungen: none,
  materialien: "einzelseiten",
  punkte: none,
  arbeitsflaechen: true,
  numbering: "a)",
  kurzformen: "teilaufgaben", // none | "aufgaben" | "teilaufgaben" | "alle"
  // Gestaltung
  gestaltung: "standard",    // Name | Funktion | dictionary
  akzent: auto,
  font: auto,
  math-font: auto,
  font-size: auto,
  title-size: auto,
  caption-size: auto,
  // Ausgabe
  varianten: auto,           // auto | str | array | dictionary
  vorschau: auto,            // auto | "alle" | Variantenname
  dateiname: none,
  // Metadaten
  fach: none,
  thema: none,
  jahrgaenge: (),
  stufe: none,               // none | "sek-1" | "sek-2"
  niveau: none,              // none | "einfuehrung" | "vertiefung" | "ea" | "ga"
  typ: none,
  stichworte: (),
  kerncurriculum: (),
  stand: none,
  ..veraltet,
  body,
)
```

`arbeitsblatt-einzeln` wird zu `_arbeitsblatt-einzeln` in `intern.typ` (zusätzlicher Parameter `kennung` statt `scope`). Die Parameterliste wird einmal als Dictionary gepflegt, nicht mehr dreifach.

### 5.2 `klassenarbeit`

```typ
#let klassenarbeit(
  // Kopf
  title: none,
  untertitel: none,
  klasse: none,
  datum: none,
  lehrkraft: none,
  logo: "angela",            // Name | content | none
  schueler: none,
  namensfeld: "Name",        // str | content | none
  namensfeld-wiederholt: false,
  infotabelle: none,         // none | array aus (Schlüssel, Wert)-Paaren
  seitenzahlen: "neu",       // none | "neu" | "fortlaufend"
  // Bestandteile
  erwartungen: auto,         // none | auto | (gruppiert:, erreicht:, bloecke:)
  klausurboegen: none,       // none | auto | dictionary mit klausurboegen-Parametern
  // Aufgabenoptionen (Abschnitt 4)
  loesungen: none,
  materialien: "einzelseiten",
  punkte: none,
  arbeitsflaechen: true,
  numbering: "a)",
  kurzformen: "teilaufgaben",
  // Gestaltung und Papier
  gestaltung: "standard",
  akzent: auto,
  font: auto,
  math-font: auto,
  font-size: auto,
  title-size: auto,
  caption-size: auto,
  paper: "a4",
  duplex: true,
  page: (:),
  // Ausgabe
  varianten: auto,           // auto = ("druck", "loesung"); zusätzlich "klausurboegen"
  vorschau: auto,
  dateiname: none,
  // Metadaten wie arbeitsblatt
  fach: none, thema: none, jahrgaenge: (), stufe: none, niveau: none,
  typ: none, stichworte: (), kerncurriculum: (), stand: none,
  ..veraltet,
  body,
)
```

`title` und `klasse` sind echte Parameter. `druck`, `header`, `zweifach`, `querformat` gibt es hier nicht (die Klassenarbeit ist immer eine Druckfassung mit eigenem Kopf); wer sie übergibt, bekommt eine Meldung mit dem Präfix `klassenarbeit:`.

### 5.3 Bausteine aus `aufgaben`

```typ
#let aufgabe(
  title: none,
  numbering: auto,           // auto | none (ohne Nummer)
  kompakt: false,            // kleinere Überschrift
  sozialform: none,          // none | "ea" | "pa" | "ga"
  symbole: (),
  arbeitsflaeche: none,
  label: none,
  ..veraltet,
  body,
)

#let teilaufgabe(
  nummer: auto,              // auto | content (eigene Marke statt a), b))
  arbeitsflaeche: none,
  label: none,
  ..veraltet,
  body,
)

#let teilaufgaben(
  columns: auto,
  numbering: auto,           // auto = Kopfoption
  gutter: 1.25em,
  align: auto,
  inset: 0pt,
  loesungen: (),             // Lösungen in Reihenfolge der Inhalte
  ..inhalte,                 // mehrere Inhalte oder ein Inhalt mit `+`-Liste
)

#let loesung(body)
#let erwartung(..punkte, body)   // höchstens ein Positionsargument (int | float) vor body
#let material(caption: none, label: none, body)
#let arbeitsflaeche(body)
```

### 5.4 Ehemalige `show-`/`set-`/`get-`-Familie

```typ
#let optionen-setzen(
  loesungen: auto, materialien: auto, punkte: auto,
  arbeitsflaechen: auto, numbering: auto, druck: auto,   // auto = unverändert lassen
)
#let aufgaben-zuruecksetzen()

#let loesungen(
  auswahl: "alle",           // "alle" | "aktuelle" | "offene"
  teil: none,                // none | int
  kasten: true,
)
#let materialien(auswahl: "alle")           // "alle" | "aktuelle"
#let erwartungshorizont(
  gruppiert: false,
  erreicht: false,
  neue-seite: false,
  bloecke: none,             // none = aktueller Block | auto = alle | array = alle mit diesen Überschriften
)
#let bewertungstabelle(
  moegliche-punkte: "zeigen", // none | "zeigen" | "leer"
  kompakt: false,
  teilsummen: false,
)

#let punktzahl(aufgabe, teil: none)          // braucht context
#let punktanzeige(punkte, teil: false)       // braucht context
#let ist-loesungsfassung()                   // braucht context
#let ist-druckfassung()                      // braucht context
```

Nach `intern.typ` wandern ohne öffentlichen Ersatz: `show-loesung`, `show-loesung-inline`, `show-material`, `get-punkte-anzeige`, `get-punkte-position`, `print-state`, alle `_state_*`.

### 5.5 `klausurboegen`

```typ
#let klausurboegen(
  title: none,
  untertitel: none,
  klasse: none,
  datum: none,
  lehrkraft: none,
  ergebnisse: none,          // none = ein Blankobogen | Zeilen (Kopf, Maximalpunkte, je Schüler)
  ergebnisdruck: false,      // nur Tabelle und Note zum Überdrucken
  stufe: "sek-2",            // "sek-1" | "sek-2" (Notenschlüssel)
  numbering: "a)",
  muster: "kariert",         // "kariert" | "liniert"
  raster: auto,              // auto = 0.5cm kariert, 8mm liniert
  korrekturrand: (seite: "aussen", width: 5cm, frei: true, stroke: 1pt + rgb("FF0613")),
  notenbereich: true,
  punktetabelle: true,
  vorschlag: none,           // none | content
  versatz: (dx: 0cm, dy: 0cm),
  ..veraltet,
)
```

`korrekturrand` kennt die Kurzform `"aussen"` | `"innen"` (= Schlüssel `seite`). Persönliche Standardwerte (`"SLZ"`, `"PH1"`, `"09.10.2023"`) entfallen. Die nur in 0.0.4 vorhandenen Teile werden mit denselben Regeln übernommen: `bogenseiten(...)`, `klausurbogen-arbeit(...)`, `vordruck`, `namen`.

### 5.6 Muster, Lücken, Layout, QR

```typ
#let kariert(
  rows: 1,                   // int | fraction; auch als erstes Positionsargument
  width: auto,               // auto | length
  height: auto,              // auto | length (hat Vorrang vor rows)
  raster: 0.5cm,
  eintraege: (),
  eintragsabstand: 2,        // in Rasterschritten
  zeichnung: none,           // CeTZ-Befehle über dem Raster
  stroke: 0.5pt + rgb("#AAAAAA").lighten(10%),
  fill: white,
  ..kurz,                    // höchstens: rows positional, Inhalt als body
)

#let liniert(
  rows: 1,
  width: auto,
  height: auto,
  raster: 1cm,
  eintraege: (),
  eintragsabstand: 1,
  stroke: 0.5pt + black.lighten(50%),
  ..kurz,
)

#let luecke(eng: false, body)
#let verdeckt(platz: true, sonst: none, body)

#let nebeneinander(columns: auto, align: horizon, gutter: 5mm, ..inhalte)

#let seitenumbruch(
  druck: auto,               // auto = immer | true = nur Druckfassung | false = nur Digitalfassung
  loesung: auto,             // auto = immer | true = nur im Lösungsblatt | false = nur außerhalb
)

#let qr-code(url, width: auto, fill: black, hintergrund: none)
#let qr-kasten(url, width: 3cm, angle: 0deg, fill: auto, body)
#let verweis(url, symbol: emoji.chain, fill: blue, body)
```

`flex-feld` und `ist-flex-feld` wandern nach `intern.typ` (`_fuellfeld`, `_ist-fuellfeld`); aufgaben importiert sie von dort statt sie zu kopieren.

Kästen (heute englische gentle-clues-Namen): `info`, `merke`, `tipp`, `frage`, `achtung`, `fehler`, `beispiel`, `ziel`, `idee`, `experiment`, `mitteilung`, `gefahr`, `einfuehrung`, `zusammenfassung`, `erledigt`, je mit

```typ
#let merke(title: auto, akzent: auto, symbol: auto, breakable: false, width: auto, body)
// title: none = ohne Kopfzeile (ersetzt headless: true)
```

Nachrichtlich (kein Kernpaket): `insert-a-word` → `lueckentext(woerter: true, loesung: auto, einheitlich: false, body)` und `lueckenwort(body)`; `reset`-Gegenstück `luecken-zuruecksetzen()`.

### 5.7 Gestaltungs-Dictionary (ehemals Theme)

Regel: Schlüssel, deren Wert unverändert an Typst geht, heißen wie in Typst und wie der gleichnamige Kopfparameter. Schlüssel, die das Paket aufruft (Hooks), sind deutsch und heißen wie der Baustein, den sie zeichnen. Der verschachtelte Schlüssel `schrift` entfällt.

| Schlüssel | Typ / Signatur | ersetzt |
|---|---|---|
| `name` | str | `name` |
| `font`, `math-font` | str, array | `schrift.text`, `schrift.mathe` |
| `font-size`, `title-size`, `caption-size` | length | `schrift.groesse`, `schrift.titel`, – |
| `margin` | dictionary `(top:, bottom:, inside:, outside:)` | `rand.top`, `rand.bottom`, `rand.innen`, `rand.aussen` |
| `kopf-oben` | length | `rand.kopf-oben` |
| `header-ascent`, `footer-descent` | length, ratio | unverändert |
| `kopf` | `(title:, klasse:, quelle:, title-size:) => content` | `kopf(title:, class:, copyright:, font-size:)` |
| `fuss` | `(duplex:) => content` | unverändert |
| `hintergrund` | `(druck:, margin:) => content` | `hintergrund(print:, oben:, rand:)` |
| `marke` | `(nummer) => content` | unverändert |
| `einzug` | length | `marke-breite` |
| `aufgabe` | `(nummer:, title:, symbole:, punkte:, kompakt:) => content`; `nummer: none` = ohne Nummer | `aufgabe(nummer:, titel:, icons:, punkte:, large:, number:)` |
| `teilaufgabe` | `(nummer) => content` | `teilaufgabe(lbl)` |
| `loesung` | `(title:, body) => content` | `loesung(titel, body)` |
| `loesung-kopf` | `(title) => content` | `loesung-kopf(titel)` |
| `material-kopf` | `(title) => content` | `material-kopf(titel)` |
| `kasten` | `(art:, title:, akzent:, breakable:, width:, body) => content` | `kasten(art:, titel:, farbe:, breakable:, width:, body)` |
| `regeln` | `body => content` | `setup` |

Hook-Regel: Ein Hook bekommt dieselben Parameternamen wie der öffentliche Baustein, `body` positional zuletzt, alles andere benannt (Ausnahme: Hooks mit genau einem Argument nehmen es positional).

Gestaltungsfunktion: `(akzent:, klasse:) => dictionary` (benannt statt positional). Sammlung: `gestaltungen` (Dictionary Name → Funktion). Namen: `"standard"`, `"klar"`, `"atlas"`, `"skizze"`, `"labor"`, `"kontur"`, `"leiste"`, `"riso"`, `"bauhaus"`. `gestaltung: none` entfällt (es gibt kein Blatt ohne Gestaltung).

Werte von `art`: `"info"`, `"merke"`, `"tipp"`, `"frage"`, `"achtung"`, `"fehler"`, `"beispiel"`, `"ziel"`, `"idee"`, `"experiment"`, `"mitteilung"`, `"gefahr"`, `"einfuehrung"`, `"zusammenfassung"`, `"erledigt"` (gleich den Funktionsnamen).

---

## 6. Tabelle alt → neu für jeden Parameter der Kernfunktionen

Spalte „ändert?“: **nein** = Name und Werte gleich; **Wert** = Name gleich, Werte/Typ anders; **ja** = Name anders; **entf.** = entfällt.

### 6.1 `arbeitsblatt(...)`

| alt | neu | ändert? |
|---|---|---|
| `title: ""` | `title: none` | nein (Standardwert) |
| `class: ""` | `klasse: none` | ja |
| `paper: "a4"` | `paper: "a4"` | nein |
| `print: false` | `druck: false` | ja |
| `duplex: true` | `duplex: true` | nein |
| `workspaces: true` | `arbeitsflaechen: true` | ja |
| `theme: none` | `gestaltung: "standard"` | ja |
| `akzent: auto` | `akzent: auto` | nein |
| `font-size: auto` | `font-size: auto` | nein |
| `font: auto` | `font: auto` | nein |
| `math-font: auto` | `math-font: auto` | nein |
| `title-font-size: auto` (bis 0.3.x auch `header-font-size`) | `title-size: auto` | ja |
| `figure-font-size: 9pt` | `caption-size: auto` | ja |
| `landscape: false` | `querformat: false` | ja |
| `custom-header: none` | `header: auto` | ja |
| `teilaufgabe-numbering: "a)"` | `numbering: "a)"` | ja |
| `page-settings: (:)` | `page: (:)` | ja |
| `header-ascent` (über `..args`) | `page: (header-ascent: …)` | ja |
| `loesungen: "false"` | `loesungen: none` | Wert |
| `materialien: "seiten"` | `materialien: "einzelseiten"` | Wert |
| `punkte: "keine"` | `punkte: none` | Wert |
| `aufgaben-shortcodes: "teilaufgaben"` | `kurzformen: "teilaufgaben"` | ja |
| `copyright: none` | `quelle: none` | ja |
| `zweifach: false` | `zweifach: false` | nein |
| `varianten: auto` | `varianten: auto` | nein |
| `vorschau-alle: true` | `vorschau: auto` (`"alle"`) | ja |
| `dateiname: none` | `dateiname: none` | nein |
| `fach`, `thema`, `stufe`, `niveau`, `typ`, `stichworte`, `kerncurriculum`, `stand` | gleich | nein |
| `jahrgang: ()` | `jahrgaenge: ()` | ja |
| `scope` (nur `-einzeln`) | `kennung` (intern) | ja |
| `..args` | `..veraltet` (nur Altnamen-Abfang) | ja |
| `body` | `body` | nein |

### 6.2 `klassenarbeit(...)`

| alt | neu | ändert? |
|---|---|---|
| `title` (über `..args`) | `title: none` | nein |
| `class` (über `..args`) | `klasse: none` | ja |
| `subtitle: ""` | `untertitel: none` | ja |
| `date: ""` | `datum: none` | ja |
| `logo: "angela"` | `logo: "angela"` | nein |
| `teacher: ""` | `lehrkraft: none` | ja |
| `student: ""` | `schueler: none` | ja |
| `name-field: "Name"` | `namensfeld: "Name"` | ja |
| `name-repeat: false` | `namensfeld-wiederholt: false` | ja |
| `info-table: false` (bis 0.1.x `table`) | `infotabelle: none` | ja |
| `page-numbering: true` | `seitenzahlen: "neu"` (`"reset"` → `"neu"`, `"continuous"` → `"fortlaufend"`, `false` → `none`) | ja |
| `klausurboegen: false` | `klausurboegen: none` (`true` → `auto`) | Wert |
| `klausurboegen.show` | entfällt (`none`) | entf. |
| `klausurboegen.ergebnisse` | `klausurboegen.ergebnisse` | nein |
| `klausurboegen-settings` (alt) | in `klausurboegen: (…)` | ja |
| `erwartungen: true` | `erwartungen: auto` (`false` → `none`) | Wert |
| `erwartungen.show`, `.new-page` | entfallen | entf. |
| `erwartungen.grouped` | `erwartungen.gruppiert` | ja |
| `erwartungen.erreicht` | `erwartungen.erreicht` | nein |
| `erwartungen.alle`, `.teile` | `erwartungen.bloecke` | ja |
| `punkte-template: none` | `punkte: (vorlage: …)` | ja |
| `varianten: auto` | `varianten: auto` | nein |
| `variante: auto` | `vorschau: auto` | ja |
| `dateiname: none` | `dateiname: none` | nein |
| durchgereichte arbeitsblatt-Optionen | wie 6.1, jetzt deklariert | wie 6.1 |
| `print`, `custom-header`, `scope` (bisher still überschreibbar) | nicht mehr annehmbar | entf. |
| `body` | `body` | nein |

### 6.3 `aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung`, `material`

| Funktion | alt | neu | ändert? |
|---|---|---|---|
| `aufgabe` | `title: none` | `title: none` | nein |
| | Titel als 1. von 2 Positionsargumenten | nur `title:` | entf. |
| | `method: ""` (`"EA"`, `"PA"`, `"GA"`) | `sozialform: none` (`"ea"`, `"pa"`, `"ga"`) | ja |
| | `icons: ()` | `symbole: ()` | ja |
| | `large: true` | `kompakt: false` (umgekehrt) | ja |
| | `number: true` | `numbering: auto` (`false` → `none`) | ja |
| | `workspace: none` | `arbeitsflaeche: none` | ja |
| | `label: none` | `label: none` | nein |
| | `..args` (Rumpf) | `body` | nein (Aufruf gleich) |
| `teilaufgabe` | `item-label: none` | `nummer: auto` | ja |
| | `label: none` | `label: none` | nein |
| | `workspace: none` (auch `false`) | `arbeitsflaeche: none` | ja |
| | `body` | `body` | nein |
| `teilaufgaben` | `tasks: ()` | `..inhalte` (positional) | ja |
| | `columns: auto` | `columns: auto` | nein |
| | `numbering: "a)"` | `numbering: auto` | nein (Standardwert) |
| | `gutter: 1.25em` | `gutter: 1.25em` | nein |
| | `loesungen: ()` | `loesungen: ()` | nein |
| | `..args` benannt → `table()` (`inset`, `align`, `row-gutter`) | `inset`, `align` deklariert; `row-gutter` über `gutter` | nein / entf. |
| | Alias `tasks` | entfällt | entf. |
| `loesung` | `body` | `body` | nein |
| `erwartung` | `..args` (Punkte und Rumpf in beliebiger Reihenfolge) | `(..punkte, body)` in fester Reihenfolge | nein (übliche Form bleibt) |
| `material` | `body`, `caption: none`, `label: none` | gleich (body in der Definition zuletzt) | nein |

### 6.4 Ehemalige `show-`/`set-`/`get-`-Familie

| alt | neu | ändert? |
|---|---|---|
| `set-options(options)` (Dictionary positional) | `optionen-setzen(loesungen:, materialien:, punkte:, arbeitsflaechen:, numbering:, druck:)` | ja |
| Options-Schlüssel `loesungen`, `materialien`, `punkte` | gleich | Wert |
| Options-Schlüssel `workspaces` | `arbeitsflaechen` | ja |
| Options-Schlüssel `teilaufgabe-numbering` | `numbering` | ja |
| Options-Schlüssel `punkte-position` | `punkte.position` | ja |
| Options-Schlüssel `punkte-template-aufgabe`, `-teilaufgabe` | `punkte.vorlage.aufgabe`, `.teilaufgabe` | ja |
| Options-Schlüssel `print` | `druck` | ja |
| `reset-aufgaben()` | `aufgaben-zuruecksetzen()` | ja |
| `show-loesungen(curr: false, …)` | `loesungen(auswahl: "alle" \| "aktuelle", …)` | ja |
| `show-loesungen(teil: false)` | `loesungen(teil: none)` | Wert |
| `show-loesungen(inline: false)` | `loesungen(kasten: true)` (umgekehrt) | ja |
| `show-offene-loesungen()` | `loesungen(auswahl: "offene")` | ja |
| `show-loesung(aufg, teil:)`, `show-loesung-inline(aufg)` | intern | entf. |
| `show-materialien(curr: false)` | `materialien(auswahl: "alle" \| "aktuelle")` | ja |
| `show-material(aufg, start:)` | intern | entf. |
| `show-erwartungen(grouped:)` | `erwartungshorizont(gruppiert:)` | ja |
| `show-erwartungen(new-page:)` | `erwartungshorizont(neue-seite:)` | ja |
| `show-erwartungen(erreicht:)` | `erwartungshorizont(erreicht:)` | ja (Funktionsname) |
| `show-erwartungen(alle:, teile:)` | `erwartungshorizont(bloecke: none \| auto \| array)` | ja |
| `show-bewertung(<pos> true/false/none)` | `bewertungstabelle(moegliche-punkte: "zeigen" \| "leer" \| none)` | ja |
| `show-bewertung(compact:)` | `bewertungstabelle(kompakt:)` | ja |
| `show-bewertung(full:)` | `bewertungstabelle(teilsummen:)` | ja |
| `get-points(aufg, teil: none)` | `punktzahl(aufgabe, teil: none)` | ja |
| `get-points(idx:)` | intern | entf. |
| `format-punkte(teil: false, points)` | `punktanzeige(punkte, teil: false)` | ja |
| `get-punkte-anzeige(opts)`, `get-punkte-position(opts)` | intern | entf. |
| `loesungsmodus()` | `ist-loesungsfassung()` | ja |
| `print-state` | intern; `ist-druckfassung()` | ja |

### 6.5 `klausurbögen`

| alt | neu | ändert? |
|---|---|---|
| Funktion `klausurbögen` | `klausurboegen` | ja |
| `exam: ""` | `title: none` | ja |
| `subexam: ""` | `untertitel: none` | ja |
| `teacher: "SLZ"` | `lehrkraft: none` | ja |
| `class: "PH1"` | `klasse: none` | ja |
| `date: "09.10.2023"` | `datum: none` | ja |
| `students: ()` | `ergebnisse: none` | ja |
| `sek1: false` | `stufe: "sek-2"` (`true` → `"sek-1"`) | ja |
| `result: false` | `ergebnisdruck: false` | ja |
| `rand: 5cm` | `korrekturrand: (width: 5cm)` | ja |
| `scale: 1` | `raster: auto` (Länge) | ja |
| `sub: false` | `notenbereich: true` (umgekehrt) | ja |
| `numbering: "a)"` | `numbering: "a)"` | nein |
| `mv: (dx:, dy:)` | `versatz: (dx:, dy:)` | ja |
| `weißer-rand: true` | `korrekturrand: (frei: true)` | ja |
| `result-table: true` | `punktetabelle: true` | ja |
| `vorschlag: false` | `vorschlag: none` | Wert |
| `line-stroke: 1pt + rot` | `korrekturrand: (stroke: …)` | ja |
| `muster: "kariert"` | `muster: "kariert"` | nein |
| `linienabstand: 8mm` | `raster: auto` | ja |
| `korrekturrand: "aussen"` (Alias `"außen"`) | `korrekturrand: "aussen"` oder `(seite: "aussen")`; Alias entfällt | nein |

### 6.6 `kariert`, `liniert`, `lücke`, `lsg`, `workspace`, `minipage`, Seitenumbrüche, QR

| Funktion | alt | neu | ändert? |
|---|---|---|---|
| `kariert` | `rows: 1` (auch 1. Positionsarg.) | `rows: 1` (auch 1. Positionsarg.) | nein |
| | `width: auto` (Kästchenzahl; auch 2. Positionsarg.) | `width: auto` (Länge; nur benannt) | Wert |
| | `items: ()` | `eintraege: ()` | ja |
| | `items-spacing: 2` | `eintragsabstand: 2` | ja |
| | `grid-size: 0.5cm` | `raster: 0.5cm` | ja |
| | `height: none` | `height: auto` | nein (Standardwert) |
| | `annotations: ()` | `zeichnung: none` | ja |
| | `line-stroke: …` | `stroke: …` | ja |
| | `fill-color: white` | `fill: white` | ja |
| | `content: []` | Inhalt als `body` | ja |
| | `..args` (schluckt Unbekanntes) | `..kurz` (geprüft) | ja |
| `liniert` | `rows: 1` | `rows: 1` | nein |
| | `width: auto` | `width: auto` | nein |
| | `items: ()` | `eintraege: ()` | ja |
| | `items-spacing: 1` | `eintragsabstand: 1` | ja |
| | `line-height: 1cm` (0.0.1: `lineheight`) | `raster: 1cm` | ja |
| | `line-stroke: …` | `stroke: …` | ja |
| | – | `height: auto` (neu, wie kariert) | – |
| `flex-feld(hoehe, zeichne)`, `ist-flex-feld(inhalt)` | intern `_fuellfeld`, `_ist-fuellfeld` | | entf. |
| `lücke` | Funktion `lücke` | `luecke` | ja |
| | `body` | `body` | nein |
| | `tight: false` | `eng: false` | ja |
| `lsg` | Funktion `lsg` | `verdeckt` | ja |
| | `body`, `platz: true`, `sonst: none` | gleich | nein |
| `workspace` | Funktion `workspace` | `arbeitsflaeche` | ja |
| | `height: 5cm` (wirkungslos) | entfällt | entf. |
| | `body` | `body` | nein |
| `minipage` | Funktion `minipage` | `nebeneinander` | ja |
| | `columns: auto` | `columns: auto` | nein |
| | `align: horizon` | `align: horizon` | nein |
| | `spacing: 5mm` | `gutter: 5mm` | ja |
| | `..args` | `..inhalte` | nein |
| `print-pagebreak()` | `seitenumbruch(druck: true)` | | ja |
| `non-print-pagebreak()` | `seitenumbruch(druck: false)` | | ja |
| `…(loesungen-only: true)` | `seitenumbruch(…, loesung: true)` | | ja |
| `qr-code` | `..args` (URL, `width`) | `url`, `width: auto` | nein |
| | `dark-color: black` | `fill: black` | ja |
| | `light-color: transparent`, `background: none` | `hintergrund: none` | ja |
| | `alt: ""` (wirkungslos) | entfällt | entf. |
| `qrbox` | Funktion `qrbox` | `qr-kasten` | ja |
| | `url`, `name` (positional) | `url`, `body` | nein (Aufruf gleich) |
| | `width: 3cm` | `width: 3cm` | nein |
| | `rotation:` (über `..args` an stickybox) | `angle: 0deg` | ja |
| `icon-link` | Funktion `icon-link` | `verweis` | ja |
| | `url`, `name` | `url`, `body` | nein (Aufruf gleich) |
| | `icon: emoji.chain` | `symbol: emoji.chain` | ja |
| | `color: blue` | `fill: blue` | ja |
| Kästen | `abstract`, `memo`, `tip`, `question`, `warning`, `error`, `example`, `goal`, `idea`, `notify`, `danger`, `conclusion`, `success` | `einfuehrung`, `merke`, `tipp`, `frage`, `achtung`, `fehler`, `beispiel`, `ziel`, `idee`, `mitteilung`, `gefahr`, `zusammenfassung`, `erledigt` | ja |
| | `info`, `experiment` | gleich | nein |
| | `title:` | `title:` | nein |
| | `accent-color:` | `akzent:` | ja |
| | `icon:` | `symbol:` | ja |
| | `headless: true` | `title: none` | ja |
| | `breakable:`, `width:` | gleich | nein |
| `tasks`, `c_canvas`, `mono` | entfallen (`mono` bleibt in informatik) | | entf. |

Die Schlüssel des Gestaltungs-Dictionarys und die Hook-Parameter stehen mit alt → neu in Abschnitt 5.7.

---

## 7. Umstellungsaufwand

Bestandsdokumente pinnen ihre Version; nichts bricht. Die Zahlen gelten für den Fall, dass ein Dokument aktiv auf 0.4.x gehoben wird. Quelle: `inventar/nutzung-ausserhalb.md` (1457 gelesene Dokumente; Zählung per Klammer-Parser, Einzelwerte ± wenige).

### 7.1 Dokumentköpfe

**arbeitsblatt (1204 Köpfe, 8509 gezählte Parameter in den Rängen bis 6 Vorkommen):**

| | Parameter | Vorkommen |
|---|---|---|
| Name bleibt | `title` 1186, `font-size` 1133, `paper` 1128, `loesungen` 390, `varianten` 113, `dateiname` 60, `duplex` 33, `font` 27, `punkte` 13, `materialien` 3, `zweifach` 2 | 4088 (48 %) |
| Name ändert sich | `class` 1187, `header-font-size` 1063, `print` 714, `workspaces` 682, `aufgaben-shortcodes` 253, `page-settings` 164, `landscape` 152, `custom-header` 130, `theme` 37, `title-font-size` 19, `subtitle` 12, `teilaufgabe-numbering` 6, `figure-font-size` 2 | 4421 (52 %) |

- `header-font-size` (1063) heißt schon in 0.4.0 anders und wäre in jeder Konvention fällig. Ohne ihn: 3358 von 7446 = **45 %** der Kopfparameter.
- Auf Dokumentebene ist praktisch **jeder Kopf betroffen** (1187 von 1204 = 99 %), weil `class` fast überall steht.
- Ein typischer Kopf (`class, title, font-size, paper, print, workspaces, loesungen`): 3 von 7 Namen ändern sich, dazu gegebenenfalls der Wert von `loesungen`.
- Wertänderungen ohne Namensänderung: `loesungen` (483 Köpfe in beiden Paketen) bei `"false"`, `"keine"`, `false`, `"seiten"`, `"reinquetschen"`; wie viele das sind, ist nicht gezählt.

**klassenarbeit (109 Köpfe, 1463 gezählte Parameter):**

| | Parameter | Vorkommen |
|---|---|---|
| Name bleibt | `title` 108, `font-size` 106, `erwartungen` 96, `loesungen` 93, `klausurboegen` 91, `logo` 83, `stufe` 80, `punkte` 39, `dateiname` 17, `paper` 12 | 725 (50 %) |
| Name ändert sich | `class` 108, `teacher` 107, `date` 107, `subtitle` 106, `table` 68, `print` 44, `klausurboegen-settings` 38, `info-table` 29, `aufgaben-shortcodes` 22, `ergebnisse` 20, `punkte-template` 18, `page-settings` 12, `header-font-size` 12, `workspaces` 10, `teilaufgabe-numbering` 9, `figure-font-size` 9, `bewertung` 8, `bogen` 7, `name-repeat` 4 | 738 (50 %) |

- Davon stammen `table`, `klausurboegen-settings`, `ergebnisse`, `bewertung`, `bogen` (141) aus alten Versionen und sind ohnehin fällig.
- Zusätzlich Wertänderung bei `klausurboegen` (91) und `erwartungen` (96): `true` → `auto`, `false` → `none`. Das ist der Preis der Regel „kein bool neben dictionary“.
- Jeder Kopf ist betroffen (`class`, `teacher`, `date`, `subtitle` stehen in 97–99 %).

### 7.2 Inhaltsaufrufe

**`aufgabe` (2340 Aufrufe mit Klammer, 273 ohne) und `teilaufgabe` (2480):**

| Funktion | benannte Argumente gesamt | bleiben | ändern sich |
|---|---|---|---|
| `aufgabe` | 6751 | `title` 1623, `label` 6 = 1629 (24 %) | `large` 1933, `number` 1710, `workspace` 1106, `titel` 342 (Altform), `icon` 20, Rest 11 = 5122 (76 %) |
| `teilaufgabe` | 2480 | `label` 4 (0,2 %) | `workspace` 2435, `item-label` 30, Rest 11 = 2476 (99,8 %) |

- Von den rund 4820 Aufrufen mit Argumenten sind **mindestens 91 %** betroffen (untere Schranke: 1933 `large` + 2435 `workspace`).
- Die Funktionsnamen `aufgabe` und `teilaufgabe` selbst bleiben.
- Drei Wörter tragen fast die ganze Last: `workspace(s)` (3541 Argumente + 692 Köpfe + 118 Funktionsaufrufe), `large` (1933), `number` (1710). Bei `large: true` und `number: true` genügt Löschen.
- Die 273 Aufrufe `#aufgabe[…]` ohne Klammer bleiben, sofern sie nicht die Zwei-Inhalte-Form (Titel, Rumpf) nutzen; deren Anteil ist nicht gezählt.

**Übrige Paketfunktionen (9627 gezählte Aufrufe):**

- Funktionsname bleibt bei 73 %: `aufgabe`, `teilaufgabe`, `erwartung` 823, `operator` 348, `liniert` 259, `kariert` 234, `info` 156, `loesung` 85, `teilaufgaben` 56, `material` 11.
- Funktionsname ändert sich bei 2573 Aufrufen (27 %): `minipage` 1575, `icon-link` 204, `iaword` 160, `lsg` 127, `qrbox` 125, `workspace` 118, `lücke` 111, `non-print-pagebreak` 106, `insert-a-word` 26, `print-pagebreak` 21.
- Benannte Argumente aller gezählten Inhaltsfunktionen: 10 293, davon bleiben 2383 (23 %): `title` 1779, `rows` 263, `height` 106, `width` 128, `columns` 36, `loesungen` 35, `gutter` 14, `inset` 12, `caption` 7, `label` 17 u. a.

### 7.3 Einordnung

- Der Hybrid rettet im Kopf die Hälfte der Vorkommen (`title`, `font-size`, `paper`, `font`), im Inhalt aber nur ein Viertel, weil die häufigsten Inhaltsparameter (`workspace`, `large`, `number`) keine Typst-Wörter sind.
- Gegenüber einer rein deutschen Konvention spart er rund 6000 Stellen (`title` 3073, `font-size` 1239, `paper` 1140, Layoutwörter rund 600). Gegenüber einer rein englischen kostet er grob geschätzt 11 000 bis 12 000 Stellen mehr (dort blieben `class`, `print`, `workspace(s)`, `large`, `number`, `minipage` stehen, dafür fielen `loesungen`, `varianten`, `aufgaben-shortcodes` an). Beide Vergleichszahlen sind Überschläge aus den Tabellen oben, keine eigene Zählung.
- Fast alles ist eine 1:1-Ersetzung auf Token-Ebene und damit Sache des Codemods (`technik/codemod.py`, `regeln.json`). Handarbeit bleibt bei: Spread (`..opts`), `set-options`, `large`/`number` mit Variablen als Wert, `kariert(width:)` in Kästchen, Zwei-Inhalte-Form von `aufgabe`, `punkte`/`punkte-template`, `klausurboegen`-Dictionaries.
- Etwa 25 Ersetzungsregeln decken über 95 % der Stellen ab.

---

## 8. Schwächen und Grenzfälle

### 8.1 Gemischte Geschwister
Die Regel erzeugt Signaturen, in denen englische und deutsche Namen nebeneinanderstehen: `title` neben `untertitel`, `font` neben `gestaltung`, `header` (Inhalt) neben dem Hook `kopf`, `header-ascent` neben `kopf-oben`. Die Mischung ist jetzt begründet und prüfbar, aber sie bleibt sichtbar. Wer „einheitlich“ als „eine Sprache“ versteht, bekommt das hier nicht.

### 8.2 `font-size` ist kein Typst-Name
Typst kennt `text(size:)`, nicht `font-size`. T3 (`font-size`, `title-size`, `caption-size`, `math-font`) ist eine bewusste Ausnahme vom Namenstest, getragen von 1239 Köpfen mit `font-size`. Streng nach Regel hieße es `text: (size: 12pt)` oder deutsch `schriftgroesse`. T3 muss auf diese vier Einträge begrenzt bleiben, sonst wird aus der Regel wieder Gewohnheitsrecht.

### 8.3 Deutsche Zusammensetzungen unterlaufen die Wortliste
`untertitel` enthält „Titel“, `eintragsabstand` enthält „Abstand“, `punktetabelle` enthält „Tabelle“. Der Lint prüft Segmente zwischen Bindestrichen und kann Wortbildung nicht sehen. R5 („schachteln statt zusammensetzen“) verhindert das nur bei Disziplin im Review. `randbreite` käme technisch durch.

### 8.4 Der Durchreichtest ist Urteilssache
Ob `title` einer Aufgabe „dasselbe“ ist wie `document(title:)`, ob `numbering: none` bei `aufgabe` dem Typst-Sinn entspricht, ob `rows: 4` (Zeilenzahl) zu `grid(rows:)` passt: Das entscheidet ein Mensch einmal bei der Aufnahme in T. Maschinell prüfbar ist nur die Liste, nicht ihre Begründung. Umstrittene Aufnahmen: `title`, `numbering`, `rows`, `header`.

### 8.5 Wer Typst nicht kennt, kann die Sprache nicht vorhersagen
Die Regel verlangt, 30 Typst-Wörter zu kennen. Für den Autor kein Problem, für Kolleginnen und Kollegen, die nur Vorlagen ausfüllen, schon: Sie müssen `klasse`, aber `title` schreiben. Abhilfe ist nur die Fehlermeldung (`titel` → „heißt `title`“) über Liste V.

### 8.6 Die häufigsten Parameter wechseln trotzdem
`class` (1295 Köpfe), `workspace` (3541), `large` (1933), `number` (1710), `print` (758), `minipage` (1575). Der Hybrid ist im Inhalt kaum billiger als eine rein deutsche Konvention (7.3).

### 8.7 ASCII-Umschrift
`arbeitsflaeche` wird in fast jeder Teilaufgabe getippt und ist 14 Zeichen lang; `fuss` und `zuruecksetzen` lesen sich holprig; `aussen` verliert das ß. Umlaut-Aliase gibt es bewusst nicht (ein Name, eine Schreibweise).

### 8.8 Verschachtelung kostet Bequemlichkeit
`korrekturrand: (width: 5cm)`, `punkte: (vorlage: …)` und `page: (header-ascent: …)` sind länger als flache Parameter, werden vom Signatur-Snapshot nicht erfasst und brauchen eigene Prüfungen an der Stelle, wo das Dictionary gelesen wird.

### 8.9 Typst kann sich ändern
Benennt Typst einen Parameter um oder entfernt ihn, verliert ein T-Wort seine Begründung. Die Liste ist an Typst 0.15.1 gebunden und muss bei jedem Typst-Update gegengeprüft werden.

### 8.10 Einzelne Grenzfälle und ihre Entscheidung

| Fall | Entscheidung | Rest-Unbehagen |
|---|---|---|
| `class` | `klasse` | teuerste Einzelumbenennung im Kopf |
| `print` | `druck` (bool) | – |
| `workspaces` | `arbeitsflaechen` / `arbeitsflaeche` | lang; `platz` wäre kürzer, ist aber in `verdeckt(platz:)` belegt |
| `teacher`, `date` | `lehrkraft`, `datum` | `date` existiert in Typst, aber als `datetime`; fällt, sobald jemand ein echtes Datum will |
| `theme` | `gestaltung` | `themes` → `gestaltungen`; 47 + 11 Dokumente auf 0.4.0 nutzen schon `theme` |
| `show-`/`set-`/`get-`/`reset-` | entfallen; Substantiv, `…-setzen`, `ist-…` | `loesungen` ist zugleich Kopfparameter und Funktion; innerhalb von `arbeitsblatt` verdeckt der Parameter die Funktion (Modul qualifiziert importieren) |
| `loesungen` in `teilaufgaben` (Array) und im Kopf (Ort) | gleiches Wort, verschiedener Typ | verstößt gegen L5; bewusst hingenommen wegen 35 + 483 Vorkommen |
| `landscape` | `querformat`, nicht `flipped` | R3 wird hier nicht angewandt: `flipped` steht absichtlich nicht in T |
| `tight` (Lücke) | `eng` | Typst kennt `tight` für Listen; Bedeutung zu weit entfernt |
| `spacing` (minipage) | `gutter` | – |
| `number: false` | `numbering: none` | Typ wechselt von bool zu `auto`/`none` |
| `large` | `kompakt` (umgekehrt) | Codemod muss Wert invertieren |
| `lsg` | `verdeckt` | der Bezug zu „Lösung“ steht nicht mehr im Namen |
| `minipage` | `nebeneinander` | 1575 Aufrufe; LaTeX-Kenner suchen den alten Namen |
| `icon-link` | `verweis` | „Verweis“ ist im Schuljargon doppeldeutig |
| `copyright` | `quelle` | Bedeutung (URL für QR-Code) bleibt erklärungsbedürftig |
| `custom-header` | `header: auto \| none \| content` | Hook heißt weiter `kopf` (8.1) |
| `page-settings` | `page` | Parameter trägt den Namen einer Typst-Funktion |
| gentle-clues-Kästen | deutsche Namen | `info` und `experiment` sind zufällig in beiden Sprachen gleich |
| Paketnamen `patterns`, `insert-a-word`, `random`, `energy-sketch` | hier nicht umbenannt | verletzen R4; Umbenennung von Paketen ist eine eigene Entscheidung |
| Fremdnamen (`canvas`, `qty`, `num`, `unit`, `fa-*`) | nicht Gegenstand der Regel | die eigene Überschreibung von `canvas` bleibt ein offener Punkt |
| `kerncurriculum` (Array, Singular) | bleibt als Sammelbegriff | Ausnahme von 2.2 |
