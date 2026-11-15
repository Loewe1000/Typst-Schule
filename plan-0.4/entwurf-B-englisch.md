# Konvention B: Englisch zuerst (Entwurf für die 0.4.x-Linie von @schule)

Stand 2026-11-14. Faktenbasis: die zwölf Inventare unter `scratchpad/inventar/` und die Prototypen unter `scratchpad/technik/`. Am Repo wurde nichts geändert.

Geltungsbereich: gemeinsame Nummer **0.4.1** für arbeitsblatt, klassenarbeit, aufgaben, klausurboegen, patterns (Kernbündel), mitgezogen mathematik, physik, informatik, operatoren, insert-a-word, random, energy-sketch. 0.4.0 (arbeitsblatt, klassenarbeit) bleibt als eingefrorene Themes-Version liegen.

## Der Ansatz in einem Absatz

Jeder öffentliche Name (Funktion, Parameter, Dictionary-Schlüssel, Enum-Wert, State-Schlüssel, Label, `sys.inputs`-Schlüssel) ist englisch, ASCII, kebab-case und stammt aus einem festen Glossar. Deutsch bleiben nur: Paketnamen, eine Liste von zwölf dokumentierten Funktions-Aliasen (`aufgabe`, `teilaufgabe`, …), Eigennamen (Theme-Namen, `angela`), Daten (Fachkürzel `MA-05`) und alles, was im PDF steht (Ausgabetexte, Fehlermeldungen, Doku).

Warum das die stärkste der möglichen Regeln ist:

1. **Es ist die einzige Regel, die sich ohne Ermessensspielraum prüfen lässt.** „Fachbegriffe deutsch, Layout englisch" (der heutige Zustand laut `historie-versionen.md` 1.3) verlangt bei jedem neuen Namen eine Einordnung, und genau daran sind `theme` + `akzent`, `loesungen-only`, `punkte-template`, `teilaufgabe-numbering` entstanden. „Alles englisch" hat keine Grenzfälle innerhalb eines Namens.
2. **Der größte Teil der meistbenutzten Namen ist schon englisch.** Die sechs häufigsten gültigen Kopfparameter (`class`, `title`, `font-size`, `paper`, `print`, `workspaces`) und alle häufigen Parameter von `aufgabe`/`teilaufgabe` (`large` 1933, `number` 1710, `title` 1623, `workspace` 1106 + 2435) sind englisch. Die deutsche Alternative müsste über 9000 Aufrufstellen anfassen, diese hier unter 1500 (Abschnitt 7).
3. **Typst selbst und alle Fremdpakete sind englisch.** `page-settings`, `numbering`, `columns`, `gutter`, `label`, `caption`, `fill`, `stroke` werden 1:1 an Typst durchgereicht; ein deutscher Name davor wäre eine Übersetzungsschicht, die gepflegt werden muss.
4. **Die Richtung ist bei den Universe-Paketen bereits entschieden** (typstage, blockst: Kommentare, Vorgaben und Kataloge wurden 2026-08/09 auf Englisch umgestellt). Ein später veröffentlichtes `worksheet`-Paket bräuchte keine zweite Umbenennung.
5. **Das Umlautproblem verschwindet**, statt geregelt werden zu müssen (`lücke`/`luecke`/`lueck`, `klausurbögen`/`klausurboegen`, `weißer-rand`, `"aussen"`/`"außen"`).

---

## 1. Sprachregeln (lint-fähig)

### R1 Zeichenvorrat und Schreibweise

Jeder öffentliche Bezeichner und jeder Enum-Wert passt auf

```
^[a-z][a-z0-9]*(-[a-z0-9]+)*$
```

Also: nur ASCII-Kleinbuchstaben und Ziffern, Wörter mit Bindestrich getrennt (kebab-case). Kein Unterstrich, kein Großbuchstabe, kein Umlaut, kein ß. Ausnahmen, die das Lint kennt:

- Namen, die mit `_` beginnen (intern, siehe R7), danach gilt derselbe Ausdruck.
- Typst-Numbering-Muster als Werte (`"a)"`, `"1.1"`).
- Daten, die keine Namen sind: Fachkürzel in `class: "MA-05"`, Schlüssel von `subject-colors` (`MA`, `PH`, …), Konstantenschlüssel der Physik (`k_B`, `N_A`).

Begründung kebab-case: seit 2025-10 entschieden (Commits `9973943`, `33971d6`), Typst-Standard, einzige Schreibweise ohne Reibung (`typst-technik.md` 1). Folge aus dem Mathemodus-Test: Funktionen, die in Formeln ohne `#` stehen, müssen einwortig sein; im Kern betrifft das keine.

### R2 Umlaut-Regel

**Keine Umlaute und kein ß in irgendeinem Namen**, auch nicht in Aliasen, Enum-Werten, Dictionary-Schlüsseln, State-Schlüsseln, Labels, Dateinamen. Wo ein deutsches Wort als Alias oder Paketname stehen bleibt, gilt die Umschrift `ae`, `oe`, `ue`, `ss`.

Begründung:

- Paket- und Dateinamen müssen ohnehin ASCII sein (`klausurboegen`). Mit Umlauten im Code gäbe es dauerhaft zwei Schreibweisen derselben Sache.
- `größe` und `groesse` sind für Typst verschiedene Namen (`t1f.typ`: `unexpected argument: größe`). Jeder Umlaut verdoppelt den Raum möglicher Tippfehler, und Typst hat keine Warnung dafür.
- Die Bestandszahlen: `#loesung(` 85 Aufrufe, `#lösung(` 0; `#lücke(` 111, aber daneben schon `#luecke(` 32 und `#lueck(` 58. Die Umschrift ist die Mehrheit.
- Eingabe auf iPad (Typist-App mit vendorierter Paketkopie), fremden Tastaturen, in Shell-Aufrufen (`--input`), in `grep`/Codemod ohne Unicode-Normalisierungsfragen.
- Im englischen Ansatz kommen Umlaute in kanonischen Namen gar nicht vor; die Regel betrifft nur die zwölf Aliase und drei Paketnamen.

Nicht betroffen: Text im PDF und Namen der Bundle-Ausgabedateien (`… - Lösung.pdf`). Das ist Inhalt, kein Bezeichner.

### R3 Wortlisten

Das Lint zerlegt jeden öffentlichen Namen an `-` in Segmente und prüft sie gegen vier Dateien (Vorschlag: `tools/naming/*.txt`, ein Wort je Zeile). Dieselben Dateien speisen `sig.py --lint`.

**`words-en.txt` (Glossar, Positivliste).** Jedes Segment muss hier stehen. Startbestand:

```
accent achieved after align all annotations answer appended area ascent background blank
block blocks body box breakable callout caption cell class code color colors columns
compact consolidation continuation continuous copyright correction count curriculum date
descent digital draw duplex end exam expectation expectations fallback filename fill flex
font fonts footer format get grades grid group grouped gutter has header heading height
icon icons index individual info inline inset introduction is item items keywords kind
label landscape large leaf level line lines link logo margin margins marker material
materials math method name new number numbering offset only options outside inside
overlay overprint page pagebreak pair paper path pattern pending place points position
possible practice preview print proposal qr reserve reset restart results revision rows
ruled scope set settings setup sheets shortcodes show side single size solution solutions
squares stage stations stroke student subject subtask subtasks subtitle subtotals table
task tasks teacher text theme themes tight title titles top bottom topic two up url
variant variants visible width workspace workspaces worksheet
canvas cells in per sheet shown to
```

Ein neues Segment darf nur zusammen mit einem Eintrag in dieser Datei eingeführt werden (Diff = bewusste Vokabel-Erweiterung).

**`words-de.txt` (Negativliste).** Kein Segment darf hier stehen. Enthält nur eindeutig deutsche Wörter samt Umschrift, damit Wörter, die in beiden Sprachen gleich sind (`material`, `operator`, `name`, `text`, `format`, `variant`), keinen Fehlalarm geben:

```
abstand akzent alle alt anzeige arbeit arbeitsblatt art aufgabe aufgaben aufloesen aussen
bewertung blatt bogen boegen breite datei dateiname datensatz datensaetze druck einheit
einstellungen einzeln ende ergebnis ergebnisse erreicht erwartung erwartungen fach farbe
feld folgend fuss groesse hintergrund hoehe inhalt innen jahrgang kariert kasten keine
kerncurriculum klasse klassenarbeit klausur klausurbogen klausurboegen kopf korrekturrand
kuerzel linien linienabstand liniert loesung loesungen loesungsmodus luecke lsg marke
materialien muster namen neu niveau note nummer nur oben offene platz punkte rand
reinquetschen schrift seite seiten sofort sonst spalten stand stichworte stufe summe teil
teile teilaufgabe teilaufgaben thema titel typ unten variante varianten versatz vorschau
vorschlag weisser werte zeichne zeilen zweifach
```

**`names.txt` (Eigennamen und Lehnwörter, erlaubt).**

```
angela atbash atlas bauhaus caesar cetz geogebra iaword kicker klar kontur labor leiste
minipage riso rot13 scratch skizze vigenere zap sek ea ga
```

(`sek`, `ea`, `ga` nur als Enum-Werte `"sek-1"`, `"sek-2"`, `"ea"`, `"ga"`; das sind Namen der niedersächsischen Schulstruktur, keine Wörter.)

**`aliases-de.txt` (die einzigen deutschen öffentlichen Namen, je Zeile `alias = kanonisch`).**

```
arbeitsblatt   = worksheet
klassenarbeit  = exam
aufgabe        = task
teilaufgabe    = subtask
teilaufgaben   = subtasks
loesung        = solution
erwartung      = expectation
lsg            = inline-solution
luecke         = blank
kariert        = squares
liniert        = lines
klausurboegen  = answer-sheets
```

`material` ist in beiden Sprachen gleich und braucht keinen Alias.

### R4 Was das Lint zusätzlich ablehnt

| Muster | Beispiel heute | Grund |
|---|---|---|
| Negativ-Präfix `no-`, `non-`, `not-`, `hide-`, `without-`, `disable-` | `non-print-pagebreak`, `hide-words`, `hide-letters` | Positivschalter (R10) |
| Suffix `-only` | `loesungen-only` | Filter als Wert, nicht als Name (5.11) |
| Präfix `custom-`, `my-`; Suffix `-alt`, `-old`, `-neu`, `-2` | `custom-header`, `häufigkeitsanalyse-alt`, `iaword-neu` | sagt nichts über die Sache |
| Typ im Namen: `-color`, `-state`, `-dict`, `-list`, `-flag`, `-str` | `fill-color`, `light-color`, `print-state`, `operatoren-state` | Typ steht in der Doku; Farbe heißt `fill`/`stroke`/`accent` |
| Abkürzungen außerhalb der Liste `qr url id csv ascii hex dec bin min max` | `curr`, `idx`, `aufg`, `opts`, `cnt`, `mv`, `sub`, `sek1`, `lbl`, `c_canvas` | ausschreiben |
| Ziffer als Wort | `bin2dec`, `hex2dec` | `bin-to-dec` (wie `text-to-blocks`) |
| Einbuchstabige öffentliche Namen | `a`, `m` (random) | Namensraum |
| Der Schlüssel `show` in Options-Dictionaries | `erwartungen: (show: false)` | Typst-Schlüsselwort, nur im Dictionary schreibbar; ersetzt durch `false` (R12) |
| Derselbe Name als Funktion und als Parameter derselben Funktion | `tasks` | Verwechslung |
| Zwei Parameter einer Signatur, die sich nur im Plural-`s` unterscheiden | `variante`/`varianten` | ein Buchstabe Unterschied |
| Zwei Enum-Werte eines Parameters, die sich nur in einem Buchstaben unterscheiden | `"seite"`/`"seiten"` | dito |

### R5 Aliase

- Deutsche Aliase gibt es **nur für Funktionsnamen** und nur für die zwölf in `aliases-de.txt`. Niemals für Parameter, Dictionary-Schlüssel, Enum-Werte, die `show-`/`set-`/`get-`-Familie oder Theme-Schlüssel.
- Ein Alias ist ein schlichtes `#let aufgabe = task` am Ende der Einstiegsdatei, in einem Block, den das Lint mit `aliases-de.txt` vergleicht (jede Zeile genau einmal, nichts darüber hinaus).
- Aliase sind dauerhaft und dokumentiert, keine Übergangslösung. Die Doku führt jede Funktion unter dem englischen Namen und nennt den Alias in einer Zeile („auch: `aufgabe`"). Beispiele, Templates und Tests schreiben englisch.
- Alte Namen, die **kein** Alias sind (`loesungen:`, `tasks`, `qrbox`, `lücke`, `non-print-pagebreak`), werden nicht still angenommen. Benannte Altparameter fängt die Sink-Tabelle aus `compat.typ` ab und bricht mit `arbeitsblatt: \`loesungen\` heißt jetzt \`solutions\`` ab; alte Werte entsprechend (`"sofort"` heißt jetzt `"in-place"`). Typst hat keine Warn-API, deshalb ist ein klarer Fehler ehrlicher als stille Annahme.

### R6 Was deutsch bleibt (und warum das kein Widerspruch ist)

| Ebene | Sprache | Beispiel |
|---|---|---|
| Paketnamen | deutsch, ASCII | `@schule/arbeitsblatt`, `@schule/klausurboegen` |
| Funktions-Aliase | deutsch, ASCII, genau zwölf | `aufgabe` |
| Eigennamen | wie sie sind | Themes `klar`, `skizze`; Logo `angela` |
| Daten | wie sie sind | `class: "MA-05"`, `subject: "Mathematik"` |
| Ausgabe im PDF | deutsch | „Aufgabe 1", „Lösung", „BE", „Seite 2 von 4", Kastentitel „Merke" |
| Fehlermeldungen | deutsch, Namen in Backticks englisch | ``aufgaben: ungültiger Wert für `solutions`: "sofort" – heißt jetzt "in-place"`` |
| Docstrings, Doku, Kommentare | deutsch | |

Ein Muster für alle Meldungen: `<paket>: \`<name>\`: <was falsch ist> – erlaubt: <liste>` bzw. `… heißt jetzt \`<neu>\``. Immer `assert`, nie `panic`.

### R7 Öffentlich und intern

- Jedes Paket bekommt eine Einstiegsdatei `src/lib.typ`, die **nur explizit** importiert und exportiert. Kein `import …: *` in Paketen (heute 5526 durchgereichte Namen, darunter `a` und `m`).
- Interne Namen stehen in `src/internal.typ` und werden als **ein** Modulname `internal` exportiert. Paketübergreifender Zugriff läuft ausschließlich darüber (`aufgaben.internal.options-state`), nicht mehr über `_state_ab_scope` und `state("options", (:))`.
- Interne Namen folgen R1 und R3 ebenso (englisch, kebab), nur ohne Glossarzwang. `_state_snake_case` entfällt.
- State-, Counter- und Label-Schlüssel tragen Paket und Schemaversion: `"schule/tasks/options@1"`, `"schule/tasks/records@1"`, `"schule/worksheet/scope@1"`, `<schule-worksheet-meta>`. Das trennt 0.4.1 sauber von älteren Paketversionen im selben Dokument (States werden über Versionen per Schlüsselstring geteilt).

---

## 2. Grammatik der Namen

### R8 Funktionen

| Art | Muster | Beispiele |
|---|---|---|
| Baustein, der etwas setzt | Substantiv, Singular | `task`, `subtask`, `solution`, `expectation`, `material`, `workspace`, `blank`, `minipage` |
| Baustein, der mehrere gleichartige setzt | Substantiv, Plural | `subtasks`, `squares`, `lines`, `answer-sheets` |
| Dokument-Vorlage (`#show: x.with(…)`) | Substantiv, Singular | `worksheet`, `exam` |
| Gesammeltes ausgeben | `show-<plural>` | `show-solutions`, `show-materials`, `show-expectations`, `show-points-table` |
| Zustand setzen | `set-<plural>` | `set-options` |
| Zustand zurücksetzen | `reset-<plural>` | `reset-tasks` |
| Wert abfragen (braucht `context`) | `get-<substantiv>` | `get-points` |
| Wahrheitswert abfragen | `has-…` / `is-…` | `has-solutions`, `is-flex-area` |
| Wert formatieren | `format-<substantiv>` | `format-points` |
| Typst-Element mit Bedingung | `<bedingung>-<element>` | `print-pagebreak`, `digital-pagebreak` |
| Zusammengesetzter Baustein | `<merkmal>-<substantiv>` | `inline-solution`, `qr-code`, `qr-box`, `icon-link` |

Verben außerhalb von `show set reset get has is format` gibt es in öffentlichen Namen nicht.

### R9 Singular und Plural

- **Singular:** ein Ding, ein Wert, ein Inhalt (`title`, `workspace: content`, `label`, `marker`, `variant`).
- **Plural:** Sammlung (Array/Dictionary), Dokumentoption, die alle Vorkommen betrifft, und Zählgrößen (`items`, `icons`, `keywords`, `grades`, `variants`, `workspaces: bool`, `solutions`, `materials`, `points`, `rows`, `columns`).
- **Bestimmungswort im Kompositum immer Singular:** `subtask-numbering`, `item-rows`, `points-format` (Ausnahme: `points` ist ein Pluraletantum der Sache „Punkte").
- Nie zwei Parameter in einer Signatur, die sich nur im `s` unterscheiden (R4). Deshalb `preview-variant` neben `variants`.

### R10 Schalter sind positiv

Ein bool-Parameter benennt, was bei `true` **da ist oder gilt**: `print`, `duplex`, `landscape`, `two-up`, `workspaces`, `large`, `number`, `tight`, `reserve`, `grouped`, `achieved`, `compact`, `name-repeat`, `preview-all`, `blank-margin`, `continuation`. Kein Parameter und keine Funktion beschreibt eine Abwesenheit. `hide-words: false` wird `word-bank: true`, `hide-letters: false` wird `labels` + `labeled: true`, `non-print-pagebreak` wird `digital-pagebreak`, `sub: true` (schaltet den Ergebnisbereich ab) wird `continuation: true` (Folgebogen).

### R11 Ein Wort je Begriff (paketübergreifend)

| Begriff | Wort | gilt für / ersetzt |
|---|---|---|
| Arbeitsblatt | `worksheet` | `arbeitsblatt`, `ab` |
| Klassenarbeit, Klausur | `exam` | `klassenarbeit`, `ka`, `exam:` (klausurbögen, dort Titel) |
| Aufgabe | `task` | `aufgabe`, `aufg`, `aufgaben-` |
| Teilaufgabe | `subtask` | `teilaufgabe`, `teil`, `ta`, `tasks` |
| Lösung | `solution` / `solutions` | `loesung`, `loesungen`, `lsg`, `show-solution` |
| Erwartung(shorizont) | `expectation` / `expectations` | `erwartung`, `erwartungen` |
| Material | `material` / `materials` | `materialien` |
| Punkte (BE) | `points` | `punkte`, `be`, `points` |
| Arbeitsfläche | `workspace` / `workspaces` | bleibt |
| Lücke | `blank` | `lücke`, `luecke`, `lueck` |
| Klausurbogen | `answer-sheets` | `klausurbögen`, `klausurboegen`, `bogen` |
| Titel / Untertitel | `title` / `subtitle` | `titel`, `exam`, `subexam` |
| Klasse, Kurs | `class` | `klasse` |
| Lehrkraft / Schüler | `teacher` / `student` | `schueler` |
| Fach / Thema / Jahrgang | `subject` / `topic` / `grades` | `fach`, `thema`, `jahrgang` |
| Schulstufe / Anforderungsniveau | `stage` / `level` | `stufe`, `sek1`, `niveau` |
| Art, Sorte | `kind` | `typ`, `art` (wie `figure(kind:)`) |
| Akzentfarbe | `accent` | `akzent`, `farbe`, `accent-color` |
| Flächen- und Textfarbe | `fill` | `fill-color`, `color`, `dark-color`, `farbe` |
| Hintergrund | `background` | `light-color`, `hintergrund` |
| Linie, Rahmen | `stroke` | `line-stroke`; mit Ziel als Präfix: `margin-stroke` |
| Breite / Höhe (immer Länge, `auto` oder `fr`) | `width` / `height` | `breite`, `hoehe` |
| Anzahl Zeilen / Spalten (immer Zahl) | `rows` / `columns` | `kariert(width:)` in Kästchen |
| Kästchengröße / Zeilenhöhe | `grid-size` / `line-height` | `scale`, `linienabstand`, `lineheight` |
| Abstand zwischen Zellen/Spalten | `gutter` | `spacing` (minipage) |
| Abstand zwischen gestapelten Einträgen | `spacing` | `item-spacing` (insert-a-word) |
| Innenabstand | `inset` | |
| Seitenrand | `margin` / `margins` | `rand` (Theme) |
| Korrekturrand | `correction-margin`, `correction-side` | `rand`, `korrekturrand`, `weißer-rand` |
| Nummerierung (Typst-Muster) | `numbering`, mit Ziel: `subtask-numbering`, `page-numbering` | `teilaufgabe-numbering` |
| Nummer anzeigen (bool) | `number` | |
| Beschriftung statt Nummer | `marker` | `item-label`, `marke` |
| Verweisziel | `label` | bleibt; nie für Sichtbares |
| Schrift / Schriftgröße | `font`, `math-font` / `font-size`, `<ziel>-font-size` | `schrift.*` |
| Kopf / Fuß | `header` / `footer` | `custom-header`, `kopf`, `fuss` |
| Druck / Digital | `print` (bool); Varianten `"print"`, `"digital"` | `druck` |
| Doppelseitig / zweifach auf Bogen | `duplex` / `two-up` | `zweifach` |
| Variante | `variant` / `variants` | `variante`, `varianten` |
| Dateiname / Pfad | `filename` / `path` | `dateiname`, `datei` |
| Vorschau | `preview` | `vorschau` |
| Muster (kariert/liniert) | `pattern`; Werte und Funktionen `squares`, `lines` | `muster`, `kariert`, `liniert` |
| Kasten (Merke, Tipp, …) | `callout` | `kasten`, clue |
| Einträge einer Liste | `items` | `tasks:` |
| Inhalt | `body` (positional, letztes) | `inhalt`, `content`, `text` |
| aktuelle(r) | `current` | `curr` |
| Index (0-basiert) | `index` | `idx` |
| Ergebnisse (Notendaten) | `results` | `ergebnisse`, `students` + `result` |
| Vorschlag (Abitur) | `proposal` | `vorschlag` |

Typst-Vokabular hat Vorrang: wo Typst für die Sache ein Wort hat (`columns`, `gutter`, `inset`, `fill`, `stroke`, `numbering`, `label`, `caption`, `breakable`, `kind`, `header`, `footer`, `margin`), wird dieses benutzt. Bestandsschutz: ein Name, der heute schon englisch, kebab und eindeutig ist, bleibt (`landscape` statt `flipped`, `paper`, `page-settings`, `minipage`, `duplex`, `large`, `number`).

---

## 3. Wertekonvention

### R12 Welcher Typ wofür

| Situation | Typ | Aus | Beispiel |
|---|---|---|---|
| Etwas ist an oder aus, ein dritter Zustand ist nicht denkbar | `bool` | `false` | `print`, `duplex`, `workspaces`, `number` |
| Auswahl aus benannten Möglichkeiten (drei oder mehr Zustände, oder zwei, die nicht „an/aus" sind) | String-Enum | `none` | `solutions`, `points`, `shortcodes`, `page-numbering`, `pattern` |
| Wert, den Paket oder Theme sinnvoll selbst bestimmen kann | Wert oder `auto` | – | `accent`, `font`, `font-size`, `header`, `logo`, `columns` |
| Inhalt oder Wert, der fehlen darf | Wert oder `none` | `none` | `title`, `workspace`, `label`, `marker`, `info-table`, `proposal` |
| Funktion mit eigenen Einstellungen | `false` \| `true` \| Dictionary | `false` | `expectations`, `answer-sheets` |
| Wert je Ziel (Typst-Muster wie `inset: 5pt` \| `(x:, y:)`) | Wert \| Dictionary mit festen Schlüsseln | – | `points-format: f` \| `(task: f, subtask: g)` |

Festlegungen:

- **Ein einziges Aus je Typ:** `false` bei bool und bei „Funktion mit Einstellungen", `none` überall sonst. Strings wie `"none"`, `"false"`, `"keine"`, `""` als Aus sind verboten; ebenso `false` für eine Auswahl und `none` für einen Schalter. Die Prüfung nennt das richtige Aus im Fehlertext.
- **`auto` heißt „bestimme selbst", `none` heißt „nichts".** `logo: auto` setzt das Schullogo, `logo: none` keins. `header: auto` setzt den Kopf des Themes, `header: none` keinen.
- **Kein „String oder Dictionary"** für dieselbe Option (`punkte: "alle"` | `(anzeige:, position:)`). Untereinstellungen werden flache Geschwister mit gemeinsamem Präfix: `points`, `points-position`, `points-format`.
- **Dictionary bei „Funktion mit Einstellungen" heißt immer „an".** Kein `show`-Schlüssel. Unbekannte Schlüssel werden mit derselben Tabelle geprüft wie Parameter.
- **Leerer Text ist `none`**, nie `""` (`title`, `subtitle`, `date`, `teacher`, `student`, `method`). Persönliche Vorgaben (`"SLZ"`, `"PH1"`, `"09.10.2023"`) entfallen.
- **Enum-Werte sind englisch, kebab-case, ohne Verneinung** und benennen, was gezeigt wird oder wo (`"in-place"`, `"page-per-task"`), nie, was fehlt (`"keine-summe"`).
- **Typen werden geprüft.** Jede öffentliche Funktion mit Optionen läuft durch dieselbe Tabelle (`compat.typ`: erlaubt, umbenannt, entfernt, Levenshtein-Vorschlag), auch `set-options` und verschachtelte Dictionaries.

### R13 Einheiten

- Längen sind immer Typst-Längen (`cm`, `mm`, `pt`, `em`) oder `fr`; nie nackte Zahlen. Ein Parameter namens `width`, `height`, `gutter`, `spacing`, `inset`, `size`, `margin`, `-size`, `-height`, `-width` hat nie den Typ int/float.
- Anzahlen sind immer int und heißen `rows`, `columns`, `count` oder `<ding>-rows`. Deshalb `squares(columns: 12)` statt `kariert(width: 12)` und `item-rows: 2` statt `items-spacing: 2`.
- Faktoren (`scale: 1`) gibt es im Kern nicht; die Größe steht als Länge da (`grid-size: 0.5cm`).
- Punkte sind int oder float, Prozentwerte `ratio`.

### R14 Positional und benannt

- **Positional** sind nur: der Inhalt (`body`, immer das letzte Positionsargument), höchstens ein führendes Hauptargument, das einen anderen Typ als der Inhalt hat oder selbsterklärend ist (`expectation(2)[…]`, `squares(4)`, `get-points(1)`, `qr-code("https://…")`, `icon-link(url)[Text]`), und gleichartige Listen über einen Sink (`minipage[a][b]`).
- **Benannt** ist alles andere, insbesondere jeder Schalter und jede Auswahl. Kein Dreiwert-Schalter als Positionsargument (`show-bewertung(none)`), kein Dictionary als Positionsargument (`set-options((…))`).
- In der Signatur steht `body` als letzter Parameter nach den benannten (`subtask(marker: none, workspace: none, label: none, body)`). Für Aufrufer ändert die Stellung benannter Parameter nichts.
- Wo ein Titel sowohl positional als auch benannt möglich ist (`task[Titel][Rumpf]`, 273 Aufrufe im Bestand), bleibt das; beides zugleich ist ein Fehler statt stiller Vorrang.
- Jeder Sink wird geprüft: überzählige Positionsargumente und unbekannte benannte führen zu einer Meldung.

---

## 4. Options-Schema für Lösungen, Material, Punkte, Arbeitsflächen

Ein Schema, das arbeitsblatt, aufgaben und klassenarbeit wörtlich teilen. Definiert und geprüft wird es **einmal** in aufgaben (`internal.option-schema`), `worksheet` und `exam` reichen nur durch. Standardwerte stehen ebenfalls nur dort (heute: `loesungen` `"false"` in arbeitsblatt, `"keine"` in aufgaben; `punkte` `"keine"` gegen `"aufgaben"`).

### 4.1 Ortsvokabular (gemeinsam für Lösungen und Material)

| Wert | Bedeutung | heute Lösungen | heute Material |
|---|---|---|---|
| `none` | nicht ausgeben | `"keine"`, `"false"`, `false`, `none` | `"keine"`, `"false"`, `false`, `none` |
| `"in-place"` | an Ort und Stelle (Lösung direkt nach der Teilaufgabe, Material dort, wo es steht) | `"sofort"` | `"sofort"`, `"folgend"` |
| `"after-task"` | gesammelt nach jeder Aufgabe | `"folgend"` | – |
| `"appended"` | am Dokumentende, ohne Seitenumbruch | `"reinquetschen"` | `"reinquetschen"` |
| `"new-page"` | am Dokumentende, auf einer neuen Seite | `"seite"` | `"seite"` |
| `"page-per-task"` | am Dokumentende, je Aufgabe eine eigene Seite | `"seiten"` | `"seiten"` |
| `"only"` | nur Lösungen, Aufgabentext entfällt | `"nur"` | – |

`"seite"`/`"seiten"` (ein Buchstabe Unterschied) wird zu `"new-page"`/`"page-per-task"`. Der heutige Alias `materialien: "folgend"` (= `"sofort"`) entfällt.

### 4.2 Die Optionen

| Option | Typ | Werte | Standard |
|---|---|---|---|
| `solutions` | Auswahl | `none`, `"in-place"`, `"after-task"`, `"appended"`, `"new-page"`, `"page-per-task"`, `"only"` | `none` |
| `materials` | Auswahl | `none`, `"in-place"`, `"appended"`, `"new-page"`, `"page-per-task"` | `"page-per-task"` |
| `points` | Auswahl | `none`, `"tasks"`, `"subtasks"`, `"all"`, `"leaf"` | `none` |
| `points-position` | Auswahl | `"end"`, `"margin"` | `"end"` |
| `points-format` | Wert je Ziel | `auto`, Funktion `points => content`, `(task: f, subtask: g)` | `auto` (= `[*n BE*]` / `[*[n BE]*]`) |
| `workspaces` | bool | `true`, `false` | `true` |
| `subtask-numbering` | Typst-Muster | `"a)"`, `"1.1"` | `"a)"` |
| `shortcodes` | Auswahl | `none`, `"tasks"`, `"subtasks"`, `"all"` | `"subtasks"` |

`"leaf"` ersetzt `"keine-summe"`: Punkte stehen dort, wo sie vergeben werden (an Teilaufgaben, und an Aufgaben nur, wenn sie keine Teilaufgaben haben). `"1.1"` ersetzt `"1."`, das heute schon „Aufgabe.Teil" bedeutet, aber wie ein anderes Muster aussieht.

Die unterschiedlichen Standardwerte von `solutions` (`none`) und `materials` (`"page-per-task"`) bleiben, sind aber dokumentiert: Material gehört zum Blatt, Lösungen nicht.

### 4.3 Dieselben Wörter an allen Stellen

| Stelle | Schreibweise |
|---|---|
| Dokumentkopf | `worksheet.with(solutions: "in-place", points: "all")` |
| mitten im Dokument | `set-options(solutions: "only")` (benannte Argumente, geprüft) |
| Variante | `variants: (key: (solutions: "only", workspaces: false))` |
| vordefinierte Varianten | `"print"`, `"digital"`, `"solutions"` (= `print: true, solutions: "only", workspaces: false`), `"two-up"`; klassenarbeit zusätzlich `"answer-sheets"` |
| Abfrage | `has-solutions()` |
| Umbruch nur in einer Fassung | `print-pagebreak(solutions: "only")` |
| insert-a-word | folgt `has-solutions()`; `show-solution:` entfällt als eigener Schalter |
| `inline-solution` / `blank` | folgen `has-solutions()` |
| Kommandozeile | `--input preview=all` |

### 4.4 Funktionen mit Einstellungen (klassenarbeit)

```typ
expectations: true                                   // an, Standard
expectations: false                                  // aus
expectations: (achieved: true, grouped: true)        // an, mit Einstellungen
answer-sheets: (pattern: "lines", correction-side: "outside", results: csv("noten.csv"))
```

Schlüssel von `expectations`: genau die benannten Parameter von `show-expectations` ohne `new-page`. Schlüssel von `answer-sheets`: genau die benannten Parameter von `answer-sheets(…)` ohne die fünf Kopfangaben, die `exam` selbst liefert.

---

## 5. Neue Signaturen (wörtlich)

Kommentare nennen den Typ, wo er nicht aus dem Standardwert folgt. `..deprecated` ist der geprüfte Sink für Altnamen (R5); er nimmt nichts an, sondern erzeugt die „heißt jetzt"-Meldung.

### 5.1 `worksheet` (Alias `arbeitsblatt`)

```typ
#let worksheet(
  // Kopf
  title: none,                 // none | str | content
  class: none,                 // none | str | content; "MA-05" bestimmt die Fachfarbe
  header: auto,                // auto | none | content
  copyright-url: none,         // none | str; erzeugt den QR-Code im Kopf
  // Seite
  paper: "a4",
  landscape: false,
  print: false,
  duplex: true,
  two-up: false,
  page-settings: (:),          // an `set page`; auch `header-ascent`
  // Gestaltung
  theme: none,                 // none | str | function | dictionary
  accent: auto,                // auto | color
  font: auto,                  // auto | str | array
  math-font: auto,
  font-size: auto,             // auto | length
  title-font-size: auto,
  figure-font-size: auto,
  // Aufgaben (Schema aus Abschnitt 4)
  solutions: none,
  materials: "page-per-task",
  points: none,
  points-position: "end",
  points-format: auto,
  workspaces: true,
  subtask-numbering: "a)",
  shortcodes: "subtasks",
  // Varianten und Ausgabe
  variants: auto,              // auto | str | array | dictionary
  preview-all: true,
  filename: none,
  // Metadaten
  subject: none,
  topic: none,
  grades: (),
  stage: none,                 // none | "sek-1" | "sek-2"
  level: none,                 // none | "introduction" | "consolidation" | "ea" | "ga"
  kind: none,                  // none | "worksheet" | "practice" | "stations" | "exam"
  keywords: (),
  curriculum: (),
  revision: none,              // none | "JJJJ-MM-TT"
  ..deprecated,
  body,
) = { … }

#let arbeitsblatt = worksheet
```

`worksheet-single(…)` hat dieselben Parameter ohne `variants`, `preview-all`, `filename`, dafür `scope: none`. Beide Signaturen werden aus **einer** Parametertabelle erzeugt bzw. gegen sie geprüft (heute dreifach gepflegt).

Varianten-Dictionary: Schlüssel = Variantenname, Wert = Overrides mit denselben Parameternamen; Sonderschlüssel `path` (ganzer Ausgabepfad, heute `datei`). Unbekannte Variantennamen ohne Overrides sind ein Fehler (heute: stille Variante ohne Lösungen).

### 5.2 `exam` (Alias `klassenarbeit`)

```typ
#let exam(
  title: none,
  subtitle: none,
  class: none,
  date: none,
  teacher: none,
  student: none,
  logo: auto,                  // auto | none | content
  name-field: "Name",          // none | str | content
  name-repeat: false,
  info-table: none,            // none | array aus Paaren
  page-numbering: "restart",   // none | "restart" | "continuous"
  expectations: true,          // false | true | dictionary
  answer-sheets: false,        // false | true | dictionary
  points-format: auto,
  variants: auto,              // auto | str | array aus "print", "solutions", "answer-sheets"
  preview-variant: auto,       // auto | "print" | "solutions" | "answer-sheets"
  filename: none,
  ..worksheet-args,            // geprüft gegen die Parametertabelle von worksheet-single
  body,
) = { … }

#let klassenarbeit = exam
```

`title` und `class` sind jetzt deklariert. `print`, `header`, `scope` darf der Nutzer nicht mehr überschreiben (Fehler mit Präfix `klassenarbeit:`). `logo: auto` ist das Schullogo; der Schlüsselstring `"angela"` entfällt als Standardwert, bleibt als Eigenname im `logos`-Dictionary.

### 5.3 `task`, `subtask`, `subtasks` (Aliase `aufgabe`, `teilaufgabe`, `teilaufgaben`)

```typ
#let task(
  title: none,                 // auch als erstes von zwei Positionsargumenten
  method: none,                // none | "individual" | "pair" | "group"
  icons: (),
  large: true,
  number: true,
  workspace: none,             // none | content
  label: none,                 // none | label | str
  ..args,                      // [body] oder [title][body]
) = { … }

#let subtask(
  marker: none,                // none | content; ersetzt a), b)
  workspace: none,
  label: none,
  body,
) = { … }

#let subtasks(
  columns: auto,               // auto | int
  numbering: "a)",
  gutter: 1.25em,
  items: (),                   // array aus content; alternativ ein Enum als body
  solutions: (),               // array aus content, in Reihenfolge der items
  ..args,                      // [body]; benannte → table()
) = { … }

#let aufgabe = task
#let teilaufgabe = subtask
#let teilaufgaben = subtasks
```

### 5.4 `solution`, `expectation`, `material` (Aliase `loesung`, `erwartung`)

```typ
#let solution(body) = { … }

#let expectation(
  points: 0,                   // int | float; auch als führendes Positionsargument
  ..args,                      // [body] oder (points, [body])
) = { … }

#let material(
  caption: none,
  label: none,
  body,
) = { … }

#let loesung = solution
#let erwartung = expectation
```

Die Reihenfolge `erwartung[Text](2)` (Inhalt vor Punkten) entfällt; `expectation(points: 2)[…]` wird neu angenommen (heute still 0 Punkte).

### 5.5 `show-`/`set-`/`get-`-Familie (aufgaben)

```typ
#let set-options(..options) = { … }       // nur benannte, geprüft gegen das Schema aus 4.2
#let reset-tasks() = { … }

#let show-solutions(
  current: false,              // nur die zuletzt angelegte Aufgabe
  subtask: none,               // none | int
  inline: false,
) = { … }
#let show-pending-solutions() = { … }
#let show-materials(current: false) = { … }
#let show-expectations(
  grouped: false,
  new-page: false,
  achieved: false,
  all-blocks: false,
  block-titles: (),
) = { … }
#let show-points-table(
  possible: "shown",           // none | "shown" | "blank"
  compact: false,
  subtotals: false,
) = { … }

#let get-points(
  task,                        // int (1-basiert) | none
  subtask: none,               // none | int
  index: none,                 // none | int (0-basiert)
) = { … }
#let format-points(level: "task", points) = { … }   // level: "task" | "subtask"
#let has-solutions() = { … }
```

Nach `internal` verschoben (nicht mehr öffentlich): `show-loesung`, `show-loesung-inline`, `show-material`, `get-punkte-anzeige`, `get-punkte-position`, alle States und Counter, `print-state`.

### 5.6 `answer-sheets` (Alias `klausurboegen`)

```typ
#let answer-sheets(
  title: none,
  subtitle: none,
  teacher: none,
  class: none,
  date: none,
  logo: auto,
  results: (),                 // CSV-Zeilen: Kopfzeile, Maximalpunkte, je Schüler eine Zeile
  overprint: false,            // nur Tabelle und Note zum Überdrucken
  stage: "sek-2",              // "sek-1" | "sek-2"; bestimmt den Notenschlüssel
  continuation: false,         // Folgebogen ohne Ergebnisbereich
  points-table: true,          // nur mit continuation wirksam
  proposal: none,              // none | str | content
  subtask-numbering: "a)",
  pattern: "squares",          // "squares" | "lines"
  grid-size: 0.5cm,
  line-height: 8mm,
  correction-margin: 5cm,
  correction-side: "outside",  // "inside" | "outside"
  blank-margin: true,
  margin-stroke: 1pt + rgb("FF0613"),
  offset: (dx: 0cm, dy: 0cm),
) = { … }

#let klausurboegen = answer-sheets
```

Aus dem Ast 0.0.4 werden zusammengeführt und gleich benannt: `vordruck` → `preprint: none | "values"`, `namen` → `names: false`, `bogen-seiten` → `sheet-pages`, `klausurbogen-arbeit` → `sheet-exam`. Die camelCase-Helfer (`gradeBoundaries`, `createTable`, `studentHeader`) gehen in `internal` auf (`grade-boundaries`, `points-table`).

### 5.7 `squares`, `lines` (Aliase `kariert`, `liniert`), Flex-Helfer

```typ
#let squares(
  rows: 1,                     // int | fraction; auch als 1. Positionsargument
  columns: auto,               // auto | int; auch als 2. Positionsargument
  height: none,                // none | length; statt rows
  grid-size: 0.5cm,
  items: (),
  item-rows: 2,                // Kästchenzeilen je Eintrag
  annotations: (),
  overlay: none,               // none | content über dem Raster
  stroke: (paint: rgb("#AAAAAA").lighten(10%), thickness: 0.5pt),
  fill: white,
  ..args,
) = { … }

#let lines(
  rows: 1,                     // int | fraction; auch als 1. Positionsargument
  width: auto,                 // auto | length; auch als 2. Positionsargument
  line-height: 1cm,
  items: (),
  item-rows: 1,
  stroke: (paint: black.lighten(50%), thickness: 0.5pt),
  ..args,
) = { … }

#let flex-area(height, draw) = { … }      // height: fraction; draw: length => content
#let is-flex-area(body) = { … }

#let kariert = squares
#let liniert = lines
```

### 5.8 `blank`, `inline-solution` (Aliase `luecke`, `lsg`)

```typ
#let blank(tight: false, body) = { … }
#let inline-solution(
  reserve: true,               // Platz im Schülerblatt freihalten
  fallback: none,              // none | content; Ersatzinhalt im Schülerblatt
  body,
) = { … }

#let luecke = blank
#let lsg = inline-solution
```

### 5.9 `workspace`, `minipage`

```typ
#let workspace(body) = { … }               // der tote Parameter `height` entfällt
#let minipage(
  columns: auto,               // auto | int | array aus Breiten
  align: horizon,
  gutter: 5mm,
  ..cells,                     // positional = Spalteninhalte; benannte → table()
) = { … }
```

### 5.10 Umbruch-Helfer

```typ
#let print-pagebreak(solutions: auto, ..args) = { … }
#let digital-pagebreak(solutions: auto, ..args) = { … }
```

`solutions: auto` heißt „in jeder Fassung"; ein Wert oder Array aus dem Ortsvokabular (4.1) beschränkt den Umbruch auf Dokumente mit diesem Lösungsmodus. `print-pagebreak(loesungen-only: true)` wird `print-pagebreak(solutions: "only")`. `..args` geht an `pagebreak()` (`weak`, `to`).

### 5.11 QR und Links

```typ
#let qr-code(
  ..args,                      // Inhalt + Argumente für zebra (width, quiet-zone, …)
  fill: black,
  background: none,            // none = transparent
) = { … }
#let qr-box(url, width: 3cm, ..args, body) = { … }
#let icon-link(url, icon: emoji.chain, fill: blue, body) = { … }
```

`qrbox` und `qr-code` schreiben sich jetzt gleich. Das zweite Positionsargument (`name`) ist der Inhalt und heißt `body`; Aufrufe bleiben gleich (`#icon-link("https://…")[Text]`, `#qr-box("https://…")[Text]`).

### 5.12 Theme-Dictionary

```
name                 str
fonts                (text:, math:, size:, title-size:)
margins              (top:, bottom:, inside:, outside:, header-top:)
header-ascent        length
footer-descent       length | ratio
header               (title:, class:, copyright-url:, font-size:) => content
footer               (duplex:) => content
background           (print:, top:, margins:) => content
task                 (number:, title:, icons:, points:, large:) => content
task-marker          (number) => content
task-marker-width    length
subtask              (marker) => content
solution             (title, body) => content
solutions-heading    (title) => content
materials-heading    (title) => content
callout              (kind:, title:, accent:, breakable:, width:, body) => content
setup                body => content
```

Hook-Signaturen wörtlich:

```typ
header: (title: none, class: none, copyright-url: none, font-size: auto) => { … }
footer: (duplex: true) => { … }
background: (print: true, top: 2.3cm, margins: (:)) => { … }
task: (number: 1, title: none, icons: (), points: none, large: true) => { … }
      // number: int | none; none ersetzt den früheren Schalter `number: false`
task-marker: number => { … }
subtask: marker => { … }
solution: (title, body) => { … }
solutions-heading: title => { … }
materials-heading: title => { … }
callout: (kind: "info", title: none, accent: auto, breakable: false, width: auto, body) => { … }
setup: body => { … }
```

Theme-Funktion: `(accent, class) => dictionary` (positional, wie heute). Theme-Namen bleiben Eigennamen: `klar`, `atlas`, `skizze`, `labor`, `kontur`, `leiste`, `riso`, `bauhaus`. `theme: "standard"` entfällt (`none` genügt). Unbekannte Schlüssel im Theme-Dictionary sind ein Fehler.

Bausteine in `themes.typ`: `fachfarben` → `subject-colors`, `fachnamen` → `subject-names`, `kuerzel` → `parse-class` (Rückgabe `(subject:, name:, grade:)`), `fachfarbe` → `subject-color`, `kasten-stil` → `callout-style(kind, accent, fill: auto)`, `kicker` bleibt, `_theme-aufloesen` → `internal.resolve-theme`.

Die 15 Kasten-Funktionen (`info`, `memo`, `tip`, …) und die 17 `kind`-Werte sind bereits englisch und bleiben.

### 5.13 Übrige Namen im Kern

| alt | neu |
|---|---|
| `loesungsmodus()` | `has-solutions()` |
| `tasks` (Alias) | entfällt |
| `c_canvas` | `cetz-canvas` |
| `canvas`, `qty`, `num`, `unit`, `mono`, `themes` | bleiben |
| `print-state` | `internal.print-state` (einzige Quelle: Options-State) |
| `<ab-meta>` mit Schlüsseln `titel`, `klasse`, `fach`, … | `<schule-worksheet-meta>` mit `title`, `class`, `subject`, `topic`, `grades`, `stage`, `level`, `kind`, `keywords`, `curriculum`, `revision` |
| `sys.inputs.vorschau == "alle"` | `sys.inputs.preview == "all"` |
| Bundle-Dateien `<dateiname>-<variante>.pdf` | `<filename>-<variant>.pdf` mit den englischen Variantennamen; klassenarbeit behält die lesbaren Namen `… - Lösung.pdf` (Inhalt, kein Bezeichner) |

### 5.14 Nachgezogene Pakete (Kurzfassung, gleiche Regeln)

| Paket | alt → neu |
|---|---|
| mathematik | `graphen` → `graph`, `steckbrief` → `function-profile`, `kreisdiagramm` → `pie-chart`, `datensätze:` → `datasets:`; `teilaufgaben`/`tasks` entfallen dort (kommen aus arbeitsblatt); Pin aufgaben 0.1.2 → 0.4.1 |
| physik | `datensatz` → `dataset`, `messdaten` → `measurements`, `berechnung` → `derived`, `messwerttabelle` → `measurement-table`, `lineare_regression` → `linear-regression` (ebenso `quadratic-`, `root-`, `exponential-`, `power-`, `polynomial-regression`), `schaltkreis` → `circuit`, `konstante` → `constant`, `pk` → `constants`; `x_param` → `x`, `grad` → `degree`; Helfer nach `internal` |
| informatik | `häufigkeitsanalyse` → `frequency-analysis` (`-alt` entfällt), `bin2dec` → `bin-to-dec` usw., `zahl` → `value`; `caesar`, `vigenere`, `atbash`, `rot13`, `ascii-table`, `text-to-blocks` bleiben |
| operatoren | `operatoren-liste(fach:, language:, operator-text-bold:)` → `operator-list(subject:, language:, bold:)`; `operator(name, text:, bold:)` → `operator(name, label: none, bold: auto)` |
| insert-a-word | `iaword-neu` → `reset-iaword`, `hide-words` → `word-bank: true`, `item-spacing` → `spacing`, `show-solution` entfällt (folgt `has-solutions()`), States nach `internal` |
| random | `default_seed` → `default-seed`; `rand`, `randint`, `shuffle` bleiben; `a`, `m`, `lcg`, `low_cminstd_*`, `step_seed`, `fisher_yates_shuffle` nach `internal` |
| energy-sketch | `energy-name` → `labels`, `hide-letters: false` → `labeled: true`; Pin in arbeitsblatt 0.0.2 → 0.4.1 |
| patterns | Pin in klausurboegen 0.0.1 → 0.4.1; `answer-sheets` nutzt `lines` statt Nachbau |

---

## 6. Tabelle alt → neu für jeden Parameter der Kernfunktionen

Spalte „ändert sich?" meint den Namen, den ein Aufrufer schreibt. Geänderte Werte oder Standardwerte stehen in der Bemerkung.

### 6.1 `arbeitsblatt` / `arbeitsblatt-einzeln` → `worksheet` / `worksheet-single`

| alt | neu | ändert sich? | Bemerkung |
|---|---|---|---|
| `title` | `title` | nein | Standard `""` → `none` |
| `class` | `class` | nein | Standard `""` → `none` |
| `paper` | `paper` | nein | wird geprüft |
| `print` | `print` | nein | |
| `duplex` | `duplex` | nein | |
| `workspaces` | `workspaces` | nein | |
| `theme` | `theme` | nein | Wert `"standard"` entfällt |
| `akzent` | `accent` | ja | |
| `font-size` | `font-size` | nein | |
| `font` | `font` | nein | |
| `math-font` | `math-font` | nein | |
| `title-font-size` | `title-font-size` | nein | |
| `figure-font-size` | `figure-font-size` | nein | Standard `9pt` → `auto` |
| `landscape` | `landscape` | nein | |
| `custom-header` | `header` | ja | Standard `none` → `auto`; `none` = kein Kopf |
| `teilaufgabe-numbering` | `subtask-numbering` | ja | Wert `"1."` → `"1.1"` |
| `page-settings` | `page-settings` | nein | nimmt `header-ascent` auf |
| `loesungen` | `solutions` | ja | Werte siehe 6.14 |
| `materialien` | `materials` | ja | Werte siehe 6.14 |
| `punkte` (String) | `points` | ja | Werte siehe 6.14 |
| `punkte: (anzeige:)` | `points` | ja | Dictionary-Form entfällt |
| `punkte: (position:)` | `points-position` | ja | |
| – (nur klassenarbeit `punkte-template`) | `points-format` | neu | |
| `aufgaben-shortcodes` | `shortcodes` | ja | Werte siehe 6.14 |
| `copyright` | `copyright-url` | ja | |
| `zweifach` | `two-up` | ja | |
| `scope` (nur `-einzeln`) | `scope` | nein | |
| `varianten` | `variants` | ja | Variantennamen siehe 6.14 |
| Override-Schlüssel `datei` | `path` | ja | |
| `vorschau-alle` | `preview-all` | ja | |
| `dateiname` | `filename` | ja | |
| `fach` | `subject` | ja | |
| `thema` | `topic` | ja | |
| `jahrgang` | `grades` | ja | |
| `stufe` | `stage` | ja | |
| `niveau` | `level` | ja | Werte siehe 6.14 |
| `typ` | `kind` | ja | Werte siehe 6.14 |
| `stichworte` | `keywords` | ja | |
| `kerncurriculum` | `curriculum` | ja | |
| `stand` | `revision` | ja | |
| `..args` (`header-ascent`) | `page-settings: (header-ascent: …)` | ja | Sink-Ausnahme entfällt |
| `body` | `body` | nein | |

Bilanz: 17 Namen bleiben, 23 ändern sich. Die 17 unveränderten sind die mit Abstand meistbenutzten (Abschnitt 7).

### 6.2 `klassenarbeit` → `exam`

| alt | neu | ändert sich? | Bemerkung |
|---|---|---|---|
| `title` (aus `..args`) | `title` | nein | jetzt deklariert |
| `class` (aus `..args`) | `class` | nein | jetzt deklariert |
| `subtitle` | `subtitle` | nein | `""` → `none` |
| `date` | `date` | nein | `""` → `none` |
| `logo` | `logo` | nein | Standard `"angela"` → `auto` |
| `teacher` | `teacher` | nein | `""` → `none` |
| `student` | `student` | nein | `""` → `none` |
| `name-field` | `name-field` | nein | |
| `name-repeat` | `name-repeat` | nein | |
| `info-table` | `info-table` | nein | Aus: `false` → `none`; `true` ist ein Fehler |
| `page-numbering` | `page-numbering` | nein | `true`/`"reset"` → `"restart"`, `false` → `none` |
| `klausurboegen` | `answer-sheets` | ja | Schlüssel siehe 6.3 |
| `erwartungen` | `expectations` | ja | Schlüssel siehe 6.3 |
| `punkte-template` | `points-format` | ja | Schlüssel `aufgabe`/`teilaufgabe` → `task`/`subtask` |
| `varianten` | `variants` | ja | |
| `variante` | `preview-variant` | ja | |
| `dateiname` | `filename` | ja | |
| `..args` | `..worksheet-args` | – | Namen wie 6.1 |
| `body` | `body` | nein | |

### 6.3 Schlüssel der Dictionaries `erwartungen` / `klausurboegen`

| alt | neu | ändert sich? |
|---|---|---|
| `erwartungen.show` | entfällt (`expectations: false`) | ja |
| `erwartungen.new-page` | entfällt (war wirkungslos) | ja |
| `erwartungen.grouped` | `grouped` | nein |
| `erwartungen.erreicht` | `achieved` | ja |
| `erwartungen.alle` | `all-blocks` | ja |
| `erwartungen.teile` | `block-titles` | ja |
| `klausurboegen.show` | entfällt (`answer-sheets: false`) | ja |
| `klausurboegen.ergebnisse` | `results` | ja |
| `klausurboegen.<rest>` | wie 6.9 | |

### 6.4 `aufgabe` → `task`

| alt | neu | ändert sich? | Bemerkung |
|---|---|---|---|
| `title` | `title` | nein | |
| `method` | `method` | nein | `""` → `none`; `"EA"`/`"PA"`/`"GA"` → `"individual"`/`"pair"`/`"group"` |
| `icons` | `icons` | nein | |
| `large` | `large` | nein | |
| `number` | `number` | nein | |
| `workspace` | `workspace` | nein | `false` ist ein Fehler |
| `label` | `label` | nein | |
| `..args` | `..args` | nein | |

### 6.5 `teilaufgabe` → `subtask`

| alt | neu | ändert sich? |
|---|---|---|
| `item-label` | `marker` | ja |
| `label` | `label` | nein |
| `workspace` | `workspace` | nein |
| `body` | `body` | nein |

### 6.6 `teilaufgaben` → `subtasks`

| alt | neu | ändert sich? |
|---|---|---|
| `tasks` | `items` | ja |
| `columns` | `columns` | nein |
| `numbering` | `numbering` | nein |
| `gutter` | `gutter` | nein |
| `loesungen` | `solutions` | ja |
| `..args` | `..args` | nein |

### 6.7 `loesung`, `erwartung`, `material` → `solution`, `expectation`, `material`

| Funktion | alt | neu | ändert sich? |
|---|---|---|---|
| `loesung` | `body` | `body` | nein |
| `erwartung` | `..args` (`body` \| `punkte, body` \| `body, punkte`) | `points:` + `..args` (`body` \| `points, body`) | nein für `erwartung(2)[…]`; ja für die Reihenfolge `body, punkte` |
| `material` | `body` | `body` | nein |
| `material` | `caption` | `caption` | nein |
| `material` | `label` | `label` | nein |

### 6.8 `show-`/`set-`/`get-`-Familie

| alt | neu | ändert sich? |
|---|---|---|
| `set-options(options)` | `set-options(..options)` | ja (Form: benannte Argumente; Schlüssel wie 6.1) |
| `reset-aufgaben()` | `reset-tasks()` | ja |
| `show-loesungen` | `show-solutions` | ja |
| – `curr` | `current` | ja |
| – `teil` (`false` \| int) | `subtask` (`none` \| int) | ja |
| – `inline` | `inline` | nein |
| `show-offene-loesungen()` | `show-pending-solutions()` | ja |
| `show-materialien` | `show-materials` | ja |
| – `curr` | `current` | ja |
| `show-erwartungen` | `show-expectations` | ja |
| – `grouped` | `grouped` | nein |
| – `new-page` | `new-page` | nein |
| – `erreicht` | `achieved` | ja |
| – `alle` | `all-blocks` | ja |
| – `teile` | `block-titles` | ja |
| `show-bewertung` | `show-points-table` | ja |
| – `..args` (`true` \| `false` \| `none`) | `possible` (`"shown"` \| `"blank"` \| `none`) | ja |
| – `compact` | `compact` | nein |
| – `full` | `subtotals` | ja |
| `get-points` | `get-points` | nein |
| – `aufg` (positional) | `task` (positional) | nein |
| – `teil` | `subtask` | ja |
| – `idx` | `index` | ja |
| `format-punkte` | `format-points` | ja |
| – `teil: false` | `level: "task"` | ja |
| – `points` | `points` | nein |
| `show-loesung(aufg, teil:)` | `internal` | ja (nicht mehr öffentlich) |
| `show-loesung-inline(aufg)` | `internal` | ja |
| `show-material(aufg, start:)` | `internal` | ja |
| `get-punkte-anzeige(opts)` | `internal` | ja |
| `get-punkte-position(opts)` | entfällt (toter Code) | ja |
| Options-Schlüssel `punkte-position` | `points-position` | ja |
| Options-Schlüssel `punkte-template-aufgabe` / `-teilaufgabe` | `points-format: (task:, subtask:)` | ja |

### 6.9 `klausurbögen` → `answer-sheets`

| alt | neu | ändert sich? | Bemerkung |
|---|---|---|---|
| `exam` | `title` | ja | |
| `subexam` | `subtitle` | ja | |
| `teacher` | `teacher` | nein | Standard `"SLZ"` → `none` |
| `class` | `class` | nein | Standard `"PH1"` → `none` |
| `date` | `date` | nein | Standard `"09.10.2023"` → `none` |
| `students` | `results` | ja | |
| `sek1` | `stage` | ja | `true` → `"sek-1"`, `false` → `"sek-2"` |
| `result` | `overprint` | ja | |
| `rand` | `correction-margin` | ja | |
| `scale` | `grid-size` | ja | Faktor → Länge (`1` → `0.5cm`) |
| `sub` | `continuation` | ja | |
| `numbering` | `subtask-numbering` | ja | |
| `mv` | `offset` | ja | |
| `weißer-rand` | `blank-margin` | ja | |
| `result-table` | `points-table` | ja | |
| `vorschlag` | `proposal` | ja | Aus: `false` → `none` |
| `line-stroke` | `margin-stroke` | ja | |
| `muster` | `pattern` | ja | `"kariert"` → `"squares"`, `"liniert"` → `"lines"` |
| `linienabstand` | `line-height` | ja | |
| `korrekturrand` | `correction-side` | ja | `"aussen"`/`"außen"` → `"outside"`, `"innen"` → `"inside"` |
| – | `logo` | neu | |

### 6.10 `kariert`, `liniert`, Flex-Helfer → `squares`, `lines`

| Funktion | alt | neu | ändert sich? |
|---|---|---|---|
| `kariert` | `rows` | `rows` | nein |
| `kariert` | `width` (Kästchenzahl) | `columns` | ja |
| `kariert` | `items` | `items` | nein |
| `kariert` | `items-spacing` | `item-rows` | ja |
| `kariert` | `grid-size` | `grid-size` | nein |
| `kariert` | `height` | `height` | nein |
| `kariert` | `annotations` | `annotations` | nein |
| `kariert` | `line-stroke` | `stroke` | ja |
| `kariert` | `fill-color` | `fill` | ja |
| `kariert` | `content` | `overlay` | ja |
| `kariert` | `..args` | `..args` | nein (jetzt geprüft) |
| `liniert` | `rows` | `rows` | nein |
| `liniert` | `width` (Länge) | `width` | nein |
| `liniert` | `items` | `items` | nein |
| `liniert` | `items-spacing` | `item-rows` | ja |
| `liniert` | `line-height` | `line-height` | nein |
| `liniert` | `line-stroke` | `stroke` | ja |
| `liniert` | `..args` | `..args` | nein |
| `flex-feld` | `hoehe` (pos.) | `height` (pos.) | nein (positional) |
| `flex-feld` | `zeichne` (pos.) | `draw` (pos.) | nein (positional) |
| `ist-flex-feld` | `inhalt` (pos.) | `body` (pos.) | nein (positional) |

### 6.11 `lücke`, `lsg`, `workspace`, `minipage`

| Funktion | alt | neu | ändert sich? |
|---|---|---|---|
| `lücke` → `blank` | `body` | `body` | nein |
| | `tight` | `tight` | nein |
| `lsg` → `inline-solution` | `body` | `body` | nein |
| | `platz` | `reserve` | ja |
| | `sonst` | `fallback` | ja |
| `workspace` | `height` | entfällt (war wirkungslos) | ja |
| | `body` | `body` | nein |
| `minipage` | `columns` | `columns` | nein |
| | `align` | `align` | nein |
| | `spacing` | `gutter` | ja |
| | `..args` | `..cells` | nein |

### 6.12 Umbruch-Helfer, QR, Links

| Funktion | alt | neu | ändert sich? |
|---|---|---|---|
| `print-pagebreak` | (Name) | `print-pagebreak` | nein |
| | `loesungen-only: true` | `solutions: "only"` | ja |
| `non-print-pagebreak` | (Name) | `digital-pagebreak` | ja |
| | `loesungen-only: true` | `solutions: "only"` | ja |
| `qr-code` | `..args` | `..args` | nein |
| | `light-color` | `background` | ja |
| | `dark-color` | `fill` | ja |
| | `alt` | entfällt (war wirkungslos) | ja |
| | `background` | `background` | nein |
| `qrbox` → `qr-box` | `url` (pos.) | `url` (pos.) | nein |
| | `name` (pos.) | `body` (pos.) | nein |
| | `width` | `width` | nein |
| | `..args` | `..args` | nein |
| `icon-link` | `url` (pos.) | `url` (pos.) | nein |
| | `name` (pos.) | `body` (pos.) | nein |
| | `icon` | `icon` | nein |
| | `color` | `fill` | ja |

### 6.13 Theme-Dictionary und Hooks

| alt | neu | ändert sich? |
|---|---|---|
| `name` | `name` | nein |
| `schrift` | `fonts` | ja |
| `schrift.text` | `fonts.text` | nein (Unterschlüssel) |
| `schrift.mathe` | `fonts.math` | ja |
| `schrift.groesse` | `fonts.size` | ja |
| `schrift.titel` | `fonts.title-size` | ja |
| `rand` | `margins` | ja |
| `rand.top` | `margins.top` | nein |
| `rand.bottom` | `margins.bottom` | nein |
| `rand.innen` | `margins.inside` | ja |
| `rand.aussen` | `margins.outside` | ja |
| `rand.kopf-oben` | `margins.header-top` | ja |
| `header-ascent` | `header-ascent` | nein |
| `footer-descent` | `footer-descent` | nein |
| `kopf` | `header` | ja |
| – `title`, `class`, `font-size` | gleich | nein |
| – `copyright` | `copyright-url` | ja |
| `fuss` | `footer` | ja |
| – `duplex` | `duplex` | nein |
| `hintergrund` | `background` | ja |
| – `print` | `print` | nein |
| – `oben` | `top` | ja |
| – `rand` | `margins` | ja |
| `marke` | `task-marker` | ja |
| `marke-breite` | `task-marker-width` | ja |
| `aufgabe` | `task` | ja |
| – `nummer` | `number` (int \| none) | ja |
| – `titel` | `title` | ja |
| – `icons` | `icons` | nein |
| – `punkte` | `points` | ja |
| – `large` | `large` | nein |
| – `number` (bool) | entfällt (in `number: none` aufgegangen) | ja |
| `teilaufgabe` | `subtask` | ja |
| `loesung` | `solution` | ja |
| `loesung-kopf` | `solutions-heading` | ja |
| `material-kopf` | `materials-heading` | ja |
| `kasten` | `callout` | ja |
| – `art` | `kind` | ja |
| – `titel` | `title` | ja |
| – `farbe` | `accent` | ja |
| – `breakable`, `width`, `body` | gleich | nein |
| `setup` | `setup` | nein |
| Theme-Funktion `(akzent, class)` | `(accent, class)` | nein (positional) |

### 6.14 Enum-Werte

| Parameter | alt | neu |
|---|---|---|
| `solutions` | `"keine"`, `"false"`, `false`, `none` | `none` |
| | `"sofort"` | `"in-place"` |
| | `"folgend"` | `"after-task"` |
| | `"reinquetschen"` | `"appended"` |
| | `"seite"` | `"new-page"` |
| | `"seiten"` | `"page-per-task"` |
| | `"nur"` | `"only"` |
| `materials` | `"keine"`, `"false"`, `false`, `none` | `none` |
| | `"sofort"`, `"folgend"` | `"in-place"` |
| | `"reinquetschen"` | `"appended"` |
| | `"seite"` | `"new-page"` |
| | `"seiten"` | `"page-per-task"` |
| `points` | `"keine"` | `none` |
| | `"aufgaben"` | `"tasks"` |
| | `"teilaufgaben"` | `"subtasks"` |
| | `"alle"` | `"all"` |
| | `"keine-summe"` | `"leaf"` |
| `points-position` | `"ende"` / `"rand"` | `"end"` / `"margin"` |
| `shortcodes` | `"keine"` / `"aufgaben"` / `"teilaufgaben"` / `"alle"` | `none` / `"tasks"` / `"subtasks"` / `"all"` |
| `subtask-numbering` | `"a)"` / `"1."` | `"a)"` / `"1.1"` |
| `variants` | `"druck"` / `"digital"` / `"loesung"` / `"zweifach"` / `"klausurboegen"` | `"print"` / `"digital"` / `"solutions"` / `"two-up"` / `"answer-sheets"` |
| `page-numbering` | `true`, `"reset"` / `"continuous"` / `false` | `"restart"` / `"continuous"` / `none` |
| `method` | `""` / `"EA"` / `"PA"` / `"GA"` | `none` / `"individual"` / `"pair"` / `"group"` |
| `stage` | `"sek-1"` / `"sek-2"` | unverändert |
| `level` | `"einfuehrung"` / `"vertiefung"` / `"ea"` / `"ga"` | `"introduction"` / `"consolidation"` / `"ea"` / `"ga"` |
| `kind` (Metadatum) | `"arbeitsblatt"` / `"uebung"` / `"stationsarbeit"` / `"klausur"` | `"worksheet"` / `"practice"` / `"stations"` / `"exam"` |
| `pattern` | `"kariert"` / `"liniert"` | `"squares"` / `"lines"` |
| `correction-side` | `"aussen"`, `"außen"` / `"innen"` | `"outside"` / `"inside"` |
| `theme` | `"standard"` | `none` |
| `callout`-`kind` | 17 englische Werte | unverändert |

---

## 7. Umstellungsaufwand

Vorweg: Kein Bestandsdokument bricht, weil jedes Dokument seine Version exakt pinnt und die alten Versionsordner liegen bleiben. Die Zahlen sagen, was anfällt, **wenn** ein Dokument auf 0.4.1 gehoben wird. Datenbasis: `nutzung-ausserhalb.md` (1204 `arbeitsblatt.with`-Köpfe, 109 `klassenarbeit.with`-Köpfe, 1457 Dokumente). Die Zählung ist ein Klammer-Parser, Einzelwerte ±wenige. Wie viele Köpfe mindestens einen betroffenen Parameter haben, lässt sich aus den Aggregatzahlen nur eingrenzen, nicht exakt bestimmen; die Rohdaten je Datei liegen nicht vor.

### 7.1 Kopfzeilen arbeitsblatt (1204 Köpfe, rund 8530 benannte Parameter)

| Parameter | Dateien | durch diese Konvention geändert? |
|---|---|---|
| `class` | 1187 | nein |
| `title` | 1186 | nein |
| `font-size` | 1133 | nein |
| `paper` | 1128 | nein |
| `header-font-size` | 1063 | Altname aus Versionen vor 0.3; muss bei jeder Anhebung zu `title-font-size` werden, unabhängig von der Konvention |
| `print` | 714 | nein |
| `workspaces` | 682 | nein |
| `loesungen` | 390 | **ja**, Name und Wert |
| `aufgaben-shortcodes` | 253 | **ja**, Name und Wert |
| `page-settings` | 164 | nein |
| `landscape` | 152 | nein |
| `custom-header` | 130 | **ja** |
| `varianten` | 113 | **ja**, Name und Variantennamen |
| `dateiname` | 60 | **ja** |
| `theme` | 37 | nein |
| `duplex` | 33 | nein |
| `font` | 27 | nein |
| `title-font-size` | 19 | nein |
| `punkte` | 13 | **ja** |
| `teilaufgabe-numbering` | 6 | **ja** |
| `materialien`, `zweifach`, Metadaten | 3 + 2 + 5 | **ja** |

- Geänderte Parametervorkommen: 390 + 253 + 130 + 113 + 60 + 13 + 6 + 10 ≈ **975 von rund 8530 (11 %)**.
- Rechnet man das ohnehin fällige `header-font-size` mit: rund 2040 von 8530 (24 %).
- Betroffene Köpfe (mindestens ein geänderter Name): **mindestens 390 von 1204 (32 %)**, weil so viele `loesungen` setzen; höchstens rund 975 (81 %), wenn sich die geänderten Parameter nie überschneiden würden. Realistisch dürfte es etwa die Hälfte sein.
- Die sechs häufigsten Parameter (`class`, `title`, `font-size`, `paper`, `print`, `workspaces`) bleiben. Ein Kopf, der nur diese nutzt, braucht außer der Versionsnummer keine Änderung.
- Der Funktionsname ändert sich nur, wenn man will: `#show: arbeitsblatt.with(…)` bleibt über den Alias gültig. Wer konsequent englisch schreibt, ändert zusätzlich 1204-mal ein Wort.

### 7.2 Kopfzeilen klassenarbeit (109 Köpfe, rund 1460 benannte Parameter)

- Unverändert: `title` 108, `class` 108, `teacher` 107, `date` 107, `subtitle` 106, `font-size` 106, `logo` 83, `print` 44, `info-table` 29, `paper`, `page-settings`, `workspaces`, `name-repeat`.
- Geändert: `erwartungen` 96, `loesungen` 93, `klausurboegen` 91, `punkte` 39, `aufgaben-shortcodes` 22, `punkte-template` 18, `dateiname` 17, `teilaufgabe-numbering` 9 = **385 von rund 1460 (26 %)**.
- Altnamen, die ohnehin wegmüssen: `stufe` 80, `table` 68, `klausurboegen-settings` 38, `ergebnisse` 20, `header-font-size` 12, `bewertung` 8, `bogen` 7.
- Betroffene Köpfe: **mindestens 96 von 109 (88 %)**, praktisch alle. Bei klassenarbeit ist der Kopf deutscher als bei arbeitsblatt.

### 7.3 Inhaltsaufrufe

| Aufruf | Anzahl | geändert mit Alias | geändert bei englischem Namen |
|---|---|---|---|
| `#aufgabe(` + `#aufgabe[` | 2340 + 273 | 4 (`method`-Werte) | alle 2613 (ein Wort) |
| `#teilaufgabe(` | 2480 | 30 (`item-label` → `marker`) | alle 2480 (ein Wort) |
| `#erwartung(` | 823 | 0 | 823 |
| `#loesung(` | 85 | 0 | 85 |
| `#minipage(` | 1575 | nur Aufrufe mit `spacing:` (im Bestand unter den Top-Parametern nicht gezählt, also wenige) | dito |
| `#liniert(` / `#kariert(` | 259 / 234 | `items-spacing` 4 + 37, `width` bei kariert 20 | alle 493 |
| `#icon-link(` | 204 | wenige (`color:`) | dito |
| `#lsg(` | 127 | Aufrufe mit `platz:`/`sonst:` | 127 |
| `#qrbox(` | 125 | **alle 125** (kein Alias) | 125 |
| `#lücke(` | 111 | **alle 111** (Umlaut entfällt: `luecke` oder `blank`) | 111 |
| `#non-print-pagebreak(` | 106 | **alle 106** | 106 |
| `#teilaufgaben(` | 56 | **alle 56** (`tasks:` 56, `loesungen:` 35) | 56 |
| `#workspace(` | 118 | 0 | 0 |
| `#print-pagebreak(` | 21 | 0 | 0 |

- Für die rund 5100 Aufrufe von `aufgabe`/`teilaufgabe` gilt: **mit Alias ändern sich etwa 34 (unter 1 %)**, weil deren häufige Parameter (`large`, `number`, `title`, `workspace`) schon englisch sind. Die 342 Aufrufe mit `titel:` stammen aus älteren Versionen und müssen bei jeder Anhebung zu `title:` werden.
- Ohne Alias, also rein englisch geschrieben: **100 % der rund 5100 Aufrufe** ändern ihr erstes Wort. Das ist rein mechanisch (`#aufgabe` → `#task`, `#teilaufgabe` → `#subtask`) und für den AST-Codemod der einfachste Fall.
- Feste Mindestkosten unabhängig vom Alias: rund 400 Aufrufe (`qrbox` 125, `lücke` 111, `non-print-pagebreak` 106, `teilaufgaben` 56).

### 7.4 Werkzeuge und sonstige Arbeit

- Eine Regeltabelle (`regeln.json`: Name alt → neu samt Wertabbildung) speist Laufzeitprüfung (`compat.typ`), Codemod und Lint. Sie ist identisch mit Abschnitt 6.
- Der Regex-Codemod reicht für `#show: x.with(name: "literal")`. Für die Wertumstellung (`"sofort"` → `"in-place"`) und Dictionary-Schlüssel (`erwartungen: (erreicht: true)`) ist das AST-Werkzeug auf `typst-syntax` nötig (lokal in Sekunden baubar). Spread (`..opts`), dynamische Werte (`loesungen: modus`), `sys.inputs`-Weichen und eigene Wrapper findet kein Codemod; dafür gibt es `--input streng=1` und den Veraltet-Bericht.
- Paketseitig: 12 Pakete, alle Docstrings, 19 Tests (pinnen Versionen, müssen kopiert und umgeschrieben werden), zwei Templates (`ab.typ`, `ka.typ`), die Doku (Beispiele werden nicht ausgeführt, also von Hand), Showcase, `AGENTS.md` im Repo AO, die vendorierte iPad-Kopie, `material.toml`-Pins in eduki, und jedes Werkzeug, das `<ab-meta>` mit deutschen Schlüsseln liest.

---

## 8. Schwächen und Grenzfälle

1. **Die englischen Fachwörter sind zum Teil Erfindungen.** Für `aufgabe`, `loesung`, `arbeitsblatt` gibt es gute Entsprechungen. Für „Erwartungshorizont" (`expectation`; im Englischen eher *mark scheme* oder *rubric*), „Klausurbogen" (`answer-sheets`), „Korrekturrand" (`correction-margin`), „Vorschlag" (`proposal`), „BE" und „Sozialform" gibt es keine, die eine deutsche Lehrkraft spontan wüsste. Der Autor muss sein eigenes Glossar nachschlagen; das ist das Gegenteil von „nachvollziehbar", solange er der einzige Nutzer ist.
2. **`task` oder `exercise`.** Die Wahl ist nicht zwingend. Für `task` spricht: kurz, `subtask`/`subtasks` bilden eine Familie, klausurboegen nutzt intern schon `subtask`. Dagegen: gentle-clues exportiert einen Kasten `task` („Aufgabe"), der heute über die Wildcard-Kette sichtbar ist, und `tasks` war bis 0.2.x der Name von `teilaufgaben` mit dem Parameter `tasks:`. In 0.4.1 bedeutet `task` also etwas anderes als `tasks` in 0.2.x. `exercise`/`subexercise` wäre kollisionsfrei, aber lang und sperrig bei 5100 Aufrufen.
3. **Paketname und Funktionsname fallen auseinander.** `#import "@schule/arbeitsblatt:0.4.1": *` und dann `#show: worksheet.with(…)`. Pakete umzubenennen (`@schule/worksheet`) würde die Versionslinie, `neue-version.sh`, die Website-Weiterleitung und alle Pins brechen; es bleibt deshalb bei deutschen Paketnamen und einer sichtbaren Naht.
4. **Die Aliase erhalten genau das Mischbild, das beseitigt werden soll.** Wer `#aufgabe(title: …, workspace: squares(4))` schreibt, hat weiter deutsch und englisch in einer Zeile, nur jetzt nach Regel (Funktions-Alias deutsch, alles andere englisch). Ohne Aliase kostet die Umstellung 100 % der Aufrufe statt unter 1 %. Zwölf Namen existieren doppelt, die Doku muss sich für einen entscheiden, und in gemeinsam bearbeiteten Dateien stehen beide Formen nebeneinander.
5. **Englische Allerweltswörter kollidieren leichter.** `task`, `lines`, `squares`, `blank`, `exam`, `solution`, `points`, `material` können mit eigenen Variablen des Nutzers und mit anderen `*`-Importen zusammenstoßen (1474 von 1576 Importen sind `: *`; cetz, gentle-clues und colorful-boxes werden in hunderten Dokumenten zusätzlich direkt importiert). Deutsche Namen waren fast von selbst kollisionsfrei. Das Lint muss neue Namen gegen `std`, cetz, cetz-plot, gentle-clues und fontawesome prüfen.
6. **Enum-Werte werden länger und für den Autor weniger sprechend.** `loesungen: "seiten"` wird `solutions: "page-per-task"`. Gewonnen wird Eindeutigkeit (`"seite"`/`"seiten"`), verloren Kürze. Wertumbenennungen sind zudem die Stelle, an der der Codemod am ehesten etwas übersieht (dynamische Werte, `sys.inputs`).
7. **Kein sanfter Übergang.** Typst kann nicht warnen. Alte Parameternamen brechen in 0.4.1 hart mit „heißt jetzt …". Die 47 arbeitsblatt- und 11 klassenarbeit-Dokumente auf 0.4.0 sind nicht in Gefahr, weil sie 0.4.0 pinnen, aber „eben die Versionsnummer hochziehen" geht ohne Codemod in etwa der Hälfte der Arbeitsblätter und in fast allen Klassenarbeiten nicht.
8. **API-Sprache und Dokumentsprache fallen auseinander.** Im PDF steht „Aufgabe 1", „Lösung", „BE"; in der Quelle `task`, `solution`, `points`. Fehlermeldungen sind deutsch mit englischen Namen in Backticks. Das ist bei jedem lokalisierten Paket so, bleibt aber ein dauerhafter Bruch und macht die Volltextsuche im eigenen Bestand zweisprachig.
9. **Deutsche Reste, die sich nicht übersetzen lassen:** Fachkürzel im `class`-String (`MA-05`), `"sek-1"`/`"sek-2"`, `"ea"`/`"ga"`, Theme-Namen (`klar`, `skizze`, `leiste`, `kontur`), `angela`, die Einheit „BE", Paketnamen. Die Eigennamenliste braucht Pflege und ist die Stelle, an der die Regel aufweichen kann.
10. **Bestandsschutz widerspricht an drei Stellen „Typst-Vokabular zuerst":** `landscape` (Typst: `flipped`), `number` als bool neben Typsts `numbering`, `page-settings` (kein Typst-Begriff). Die Entscheidung fiel für die Nutzungszahlen (152, 1710, 164), nicht für die reine Lehre.
11. **Doppelbedeutungen bleiben:** `solutions` ist im Kopf eine Auswahl (wo Lösungen erscheinen) und in `subtasks(solutions: (…))` ein Array von Inhalten. `header` ist Parameter von `worksheet` und Hook-Schlüssel im Theme. `title` in `answer-sheets` meint den Titel der Arbeit, nicht des Bogens. `points-format` erlaubt Funktion oder Dictionary; das ist die eine bewusst zugelassene Typ-Vereinigung neben „Funktion mit Einstellungen".
12. **Zwei Aus-Werte statt einem.** `false` für Schalter, `none` für Auswahlen. Ein einziges Aus für alles wäre nur mit `none` als bool-Ersatz möglich und stünde gegen Typst. Die Prüfung muss deshalb bei jedem falschen Aus das richtige nennen.
13. **Metadaten sind eine externe Schnittstelle.** `<ab-meta>` mit `titel`, `klasse`, `fach` wird von Werkzeugen außerhalb des Repos gelesen (Materialbibliothek, eduki). Englische Schlüssel brechen diese Leser; entweder beide Labels eine Zeit lang parallel schreiben oder die Leser mit umstellen. Das ist die einzige Stelle, an der eine Doppelausgabe vertretbar ist.
14. **Die Wortlisten sind kein Beweis für gutes Englisch.** Das Lint prüft Zugehörigkeit zum Glossar, nicht Sinn. `block-titles`, `item-rows`, `preview-variant`, `points-table` sind regelkonform, aber Geschmackssache. Wörter, die in beiden Sprachen gleich geschrieben werden (`material`, `operator`, `variant`, `format`, `name`, `text`, `start`), lassen sich per Liste nicht zuordnen.
15. **Voraussetzungen, die mit Sprache nichts zu tun haben, aber vorher erledigt sein müssen:** die Äste klausurboegen 0.0.4 und 0.0.5 zusammenführen (sonst zwei Umbenennungstabellen), die veralteten Pins heben (mathematik → aufgaben 0.1.2, klausurboegen → patterns 0.0.1, arbeitsblatt → energy-sketch 0.0.2), Wildcard-Re-Exporte abschaffen. Der dritte Punkt ändert für Nutzer mehr als jede Umbenennung: Namen wie `stickybox` (45 Aufrufe), `canvas`, `draw`, `fa-*` müssen dann bewusst re-exportiert werden, sonst fehlen sie.
16. **Der Nutzen hängt an einer Veröffentlichung, die nicht geplant ist.** Auf Universe stehen nur blockst und typstage. Solange arbeitsblatt, klassenarbeit und aufgaben im Namensraum `@schule` bleiben und einen Hauptnutzer haben, zahlt dieser Ansatz für Anschlussfähigkeit, die niemand abruft. Was bleibt, ist der innere Gewinn: eine prüfbare Regel, kein Umlautproblem, und die geringste Zahl geänderter Aufrufstellen im Bestand.
