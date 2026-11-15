# KONVENTION: Namen in den @schule-Paketen (verbindlich ab der Vereinheitlichungsversion)

> **Entschieden am 2026-11-15: deutsche Bausteine auf Dauer.**
>
> - Die Bausteine heißen deutsch wie die Pakete und sind auf Dauer die einzigen Namen: `arbeitsblatt`, `klassenarbeit`, `aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung`, `lsg`, `luecke`, `kariert`, `liniert`, `klausurboegen` (ASCII-Umschrift), dazu `arbeitsblatt-einzeln` und die Fachbausteine. Die abschließende Liste ist `bausteine-de.txt` (Abschnitt 2.1a, 34 Namen).
> - Es gibt keine englischen Zwillinge (`worksheet`, `exam`, `task`, `subtask`, `subtasks`, `solution`, `expectation`, `inline-solution`, `blank`, `squares`, `lines`, `answer-sheets` sind keine Funktionen) und keinen Alias-Block.
> - Alles in den Klammern bleibt englisch wie ausgearbeitet: Parameter, Dictionary-Schlüssel, Enum-Werte. Englisch bleiben auch Aktionen, Abfragen und Layout-Helfer.
> - Aufwand: Die rund 5100 Ersetzungen von `aufgabe` und `teilaufgabe` im Bestand entfallen, ebenso der Codemod-Schalter `--aliase`, der Test `aliase.typ` und die zweite Umstellung am Ende der Übergangsfrist. Erledigt sind damit die Kollision `task` ↔ gentle-clues und die Frage `task` oder `exercise` (frühere offene Entscheidungen 11.1 und 11.3).

Stand 2026-11-15. Gilt für arbeitsblatt, klassenarbeit, aufgaben, klausurboegen, patterns, mathematik, physik, informatik, operatoren, insert-a-word, random, energy-sketch. Grundlage ist der Jury-Sieger „B, Englisch zuerst" (19 Punkte, zwei von drei Gutachten), ergänzt um die übernommenen Ideen aus A und C und geändert durch die Entscheidung des Autors im Kasten oben: Aus B bleibt alles, was in den Klammern steht; die Bausteinnamen kommen aus dem Bestand. Alle von der Jury genannten Regelverstöße sind behoben; Anhang C führt den Nachweis je Punkt.

Dieses Dokument ändert nichts am Repo. Stellen, deren heutige Wirkung nicht am Code bestätigt wurde, tragen die Marke **[prüfen]**; die Namensregel gilt dort trotzdem.

Bezeichnungen in diesem Dokument: **Zielversion** = die Version, in der die Regeln erstmals gelten (Empfehlung 0.4.1, siehe 11.1). **Folgelinie** = die nächste Minor-Linie danach. **Baustein** = eine Funktion aus `bausteine-de.txt` (2.1a). **Parameterwort** = das englische Wort, das in Parametern, Schlüsseln und Werten für einen Baustein steht (2.1b).

---

## 1. Leitregel und Entscheidungsbaum

### 1.1 Leitregel

1. **Bausteine heißen deutsch wie die Pakete; alles andere, was man tippt, ist englisch; was man liest, ist deutsch.** Ein Funktionsname ist genau dann deutsch, wenn er in `bausteine-de.txt` steht (2.1a). Die Datei ist abschließend; das Lint prüft sie in beide Richtungen (L23, L27). Jeder andere Bezeichner (Funktion, Parameter, Schlüssel, Enum-Wert) ist englisch, ASCII, kebab-case. Kein Name mischt die Sprachen. Alles, was im PDF, in einer Fehlermeldung oder in der Doku steht, ist deutsch.
2. **Ein Begriff hat genau ein Wort je Rolle, und ein Wort hat genau einen Typ.** Der Baustein hat seinen deutschen Namen, in den Klammern steht sein englisches Parameterwort (2.1b); weitere Synonyme gibt es nicht. Das Wort steht im Glossar (Abschnitt 3) und wird überall gleich benutzt: im Kopf, in `set-options`, in Varianten, in Hooks.
3. **Heißt wie Typst, wenn es sich wie Typst verhält; aus ist `false` beim Schalter und `none` bei allem anderen.**

### 1.2 Entscheidungsbaum für einen neuen Namen

Die Schritte werden in dieser Reihenfolge durchlaufen. Der erste Treffer entscheidet.

```
1  Steht der Begriff im Glossar (Abschnitt 3)?
     ja  -> genau dieses Wort. Fertig.
2  Reicht das Paket den Wert unverändert an einen Typst-Parameter weiter,
   mit gleichem Typ und gleicher Wirkung (Durchreichtest)?
     ja  -> der Typst-Name (columns, gutter, inset, align, fill, stroke, width,
            height, numbering, caption, label, breakable, paper).
            Im Funktionsrumpf wird das gleichnamige Builtin als std.<name> geschrieben.
3  Ist es eine Untereinstellung einer bestehenden Option?
     ja  -> <option>-<aspekt> als flaches Geschwister (points-position).
            Aspekt aus: position, format, total, pagebreak, side, stroke, size, width, numbering.
4  Ist es eine neue Funktion, die den Bausteintest aus 2.1 besteht (B1 bis B3)?
     ja  -> deutscher Name des Schulbegriffs, ASCII-Umschrift, kebab-case.
            Eintrag in bausteine-de.txt und Zeile in der Wortpaar-Tabelle 2.1b
            (ein Diff = ein bewusster Baustein). Weiter bei 6.
5  Sonst: englisches Wort bilden.
     a) Wortart nach Abschnitt 4 (Helfer = Substantiv, Aktion = Verb-Präfix, Schalter = positiv).
     b) Numerus nach 4.2.
     c) Jedes Segment muss in words-en.txt stehen; fehlt eines, wird es dort
        und im Glossar eingetragen (ein Diff = eine bewusste Vokabel).
     d) Kein Segment aus der Verbotsliste 10/L4, keine Kollision nach 10/L12,
        kein Segment eines deutschen Bausteins (10/L27).
     e) Meint der Name einen Baustein, steht dessen Parameterwort aus 2.1b
        (task-number, nicht aufgabe-number und nicht exercise-number).
6  Typ festlegen nach Abschnitt 5 (genau eine der Formen W1 bis W9).
7  sig.py --lint laufen lassen. Rot heißt: Name ändern, nicht Regel ändern.
```

Bestandsschutz gibt es für neue Namen nicht. Alle Ausnahmen der Vergangenheit sind als Glossarzeilen festgeschrieben (zum Beispiel `landscape` statt Typsts `flipped`) und werden dadurch von Schritt 1 erfasst, nicht von Ermessen.

---

## 2. Sprache

### 2.1 Regel

Öffentliche Bezeichner sind englisch, ausgenommen die Bausteine. „Öffentlich" ist alles, was ein Dokument schreiben kann: Funktionsnamen, Parameternamen, Dictionary-Schlüssel, Enum-Werte, Variantennamen, exportierte Konstanten. Interne Namen (Abschnitt 7.2) sind immer englisch.

**Was ein Baustein ist.** Eine Funktion ist ein Baustein und heißt deutsch, wenn alle drei Bedingungen gelten:

| | Bedingung | Prüffrage |
|---|---|---|
| B1 | **Aufrufform.** Das Dokument schreibt die Funktion als `#name[…]`, `#name(…)` oder `#show: name.with(…)`, und sie liefert das benannte Ding selbst: Inhalt auf der Seite oder den Datenwert, den ein anderer Baustein setzt (`datensatz` für `messwerttabelle` und `graphen`). | Steht der Name im Dokument dort, wo das Ding erscheint oder entsteht? |
| B2 | **Schulbegriff.** Der Name ist das deutsche Wort, mit dem Lehrkräfte und Lernende das Ding benennen: ein Substantiv (`aufgabe`, `messwerttabelle`), bei Mustern das Adjektiv (`kariert`). Es steht so in Aufgabenstellungen, Heften oder Fachanforderungen. | Würde man das Wort im Unterricht sagen? |
| B3 | **Kein Ausschluss.** Der Name ist keine Aktion oder Abfrage, keine Umwandlung, kein Layout- oder Technikhelfer, kein Eigen- oder Fremdname (Tabelle unten). | Trifft eine Zeile der Ausschlusstabelle zu? |

Der Test entscheidet über die Aufnahme in `bausteine-de.txt`. Danach gilt allein die Datei: Was dort nicht steht, ist kein Baustein und heißt englisch, auch wenn jemand den Test anders läse.

**Was kein Baustein ist** (bleibt englisch):

| Art | Erkennungsmerkmal | Beispiele |
|---|---|---|
| Aktion, Abfrage | Verb-Präfix `show-`, `set-`, `reset-`, `get-`, `is-`, `has-`, `format-` | `show-solutions`, `set-options`, `reset-tasks`, `get-points`, `is-print`, `has-solutions`, `format-points`, `reset-iaword`, `is-flex-area` |
| Umwandlung | `<von>-to-<nach>` | `bin-to-dec`, `dec-to-hex`, `text-to-blocks` |
| Layout- und Technikhelfer | benennt eine Anordnung oder ein Werkzeug, keinen Schulbegriff | `workspace`, `minipage`, `conditional-pagebreak`, `flex-area`, `qr-code`, `qr-box`, `icon-link`, `ascii-table` |
| Kästen | die 15 Namen aus gentle-clues | `info`, `tip`, `memo`, `warning`, … (7.1) |
| Eigen- und Fremdnamen | Name eines Verfahrens, Produkts oder Fremdpakets | `caesar`, `vigenere`, `atbash`, `rot13`, `caesar-table`, `geogebra-cell`, `geogebra-algebra`, `geogebra-style`, `iaword`, `insert-a-word`, `energy-sketch`, `source`, `lamp`, `multimeter`, `ammeter`, `voltmeter`, `motor`, `generator`, `canvas`, `draw`, `plot`, `qty`, `num`, `unit` |
| Sprachgleiche Wörter | deutsch und englisch gleich geschrieben; laufen über `words-en.txt` | `material`, `operator` |
| Werte und Konstanten | kein Aufruf, sondern ein Wert | `themes`, `subject-accents`, `subject-names`, `constants`, `default-seed` |

**Keine Mischnamen.** Ein Name ist ganz deutsch (dann steht er als Ganzes in `bausteine-de.txt`) oder ganz englisch. Verboten sind `show-loesungen`, `reset-aufgaben`, `aufgabe-number`, `arbeitsblatt-single`, `loesung-heading`. Zusammengesetzte deutsche Bausteine sind eigene Listeneinträge (`arbeitsblatt-einzeln`, `lineare-regression`, `operatoren-liste`).

Deutsch sind ausschließlich die folgenden, abschließend aufgezählten Dinge:

| Was | Regel | Begründung |
|---|---|---|
| Paketnamen | deutsch oder englisch wie heute, ASCII: `arbeitsblatt`, `klassenarbeit`, `aufgaben`, `klausurboegen`, `mathematik`, `physik`, `informatik`, `operatoren`; `patterns`, `random`, `insert-a-word`, `energy-sketch` | Eigennamen. Umbenennen bräche die Versionslinien, `neue-version.sh` und jeden Pin. |
| Bausteine | genau die 30 Funktionsnamen aus `bausteine-de.txt` (2.1a), auf Dauer, ohne englischen Zwilling | Ein Baustein ist der Eigenname eines Schuldings wie der Paketname, aus dem er kommt. 5100 Aufrufe von `aufgabe` und `teilaufgabe` im Bestand bleiben, wie sie sind. |
| Eingefrorene Außenschnittstellen | Label `<ab-meta>` mit den Schlüsseln `titel`, `klasse`, `fach`, `thema`, `jahrgang`, `stufe`, `niveau`, `typ`, `stichworte`, `kerncurriculum`, `stand`; `--input vorschau=alle`; Dateinamen-Endungen der Bündelausgabe `-druck`, `-digital`, `-loesung`, `-zweifach`, `-klausurboegen` | Werden außerhalb des Repos gelesen (Materialbibliothek, eduki, VS-Code-Einstellung, Build-Skripte). Eine Umbenennung bräche still, ohne Fehlermeldung. |
| Eigennamen als Werte | Theme-Namen `klar`, `atlas`, `skizze`, `labor`, `kontur`, `leiste`, `riso`, `bauhaus`; Logo `angela`; Chiffren `caesar`, `vigenere`, `atbash`, `rot13`; `"sek-1"`, `"sek-2"`, `"ea"`, `"ga"` | Namen von Dingen, keine Wörter. Stehen in `names.txt`. |
| Daten | `class: "MA-05"`, Fachkürzel als Schlüssel von `subject-accents` (`MA`, `PH`), Physik-Konstanten (`k_B`, `N_A`), `subject: "Mathe"` in `operatoren-liste` | Inhalt, kein Bezeichner. |
| Ausgabe | Texte im PDF („Aufgabe 1", „Lösung", „BE", Kastentitel „Merke"), Fehlermeldungen, Docstrings, Doku, Kommentare | Leser sind deutschsprachig. |

Die eingefrorenen Außenschnittstellen werden aus den englischen Parametern erzeugt (`subject` schreibt `fach` nach `<ab-meta>`). Die Abbildung steht in einer einzigen Tabelle `internal.meta-keys` und in keiner Signatur.

### 2.1a Deutsche Bausteine (`bausteine-de.txt`)

Die Datei liegt neben `words-en.txt` und ist die einzige Quelle für Lint, Codemod und Doku. Eine Zeile je Name. Stand der Zielversion 0.5.0, 34 Namen (30 aus Kern und Fachpaketen, 4 aus den Hilfspaketen):

```
# Kern (13)
arbeitsblatt
arbeitsblatt-einzeln
klassenarbeit
aufgabe
teilaufgabe
teilaufgaben
loesung
erwartung
lsg
luecke
kariert
liniert
klausurboegen
# mathematik (3)
graphen
steckbrief
kreisdiagramm
# physik (12)
datensatz
messdaten
berechnung
messwerttabelle
lineare-regression
quadratische-regression
wurzel-regression
exponentielle-regression
potenz-regression
polynom-regression
schaltkreis
konstante
# informatik (1)
haeufigkeitsanalyse
# operatoren (1)
operatoren-liste
# typlace (2)
sitzordnung
wunschliste
# angela (1)
brief
# gutachten (1)
gutachten
```

Festlegungen zur Liste:

- **Form.** Der Name ist der heutige Name im Bestand, in ASCII-Umschrift und kebab-case. Numerus und Wortart bleiben, wie sie sind (`graphen` im Plural, `kariert` als Adjektiv, `lsg` als Kürzel); Abschnitt 4.1 bildet deutsche Namen nicht um.
- **Geändert gegenüber heute** werden nur Schreibweisen, die 2.3 und 2.4 verletzen: `lücke` → `luecke`, `klausurbögen` → `klausurboegen`, `häufigkeitsanalyse` → `haeufigkeitsanalyse`, `lineare_regression` → `lineare-regression` und die fünf weiteren Regressionen. Die alten Schreibweisen sind abbrechende Stubs (9.3).
- **`arbeitsblatt-einzeln`** steht in der Liste, weil `worksheet-single` als englischer Zwilling entfällt und ein Mischname verboten ist.
- **Neuer Baustein** nur über Schritt 4 des Entscheidungsbaums: Eintrag hier, Zeile in 2.1b, Zeile im Glossar oder in Anhang B. Kein Baustein bekommt je einen zweiten Namen.
- Die Einzelbegründung je Fachbaustein und je englisch bleibendem Fachnamen steht in Anhang B.
- **Hilfspakete (Nachtrag 0.5.0).** `sitzordnung` und `wunschliste` (typlace), `brief` (angela) und `gutachten` (gutachten) haben den Bausteintest bestanden; die Begründung steht in `tabelle-typlace.md` (E1, E2), `tabelle-angela.md` (Abschnitt 1) und `tabelle-gutachten.md` (Abschnitt 1). `gutachten` heißt wie sein Paket, wie `klassenarbeit` und `klausurboegen`. `gutachten` definiert außerdem eine eigene Funktion `aufgabe` (Baustein aus dem Kern, zweite Definition). Die englischen Zwillinge `seating`, `wishes`, `letter` und `report` werden nicht als Funktion exportiert; in `zwillinge.txt`, `wortpaare.json` und `word-pairs` von `check.typ` sind die vier Bausteine noch nachzutragen.

### 2.1b Baustein ↔ Wort in Parametern

Der Baustein ist ein Eigenname und wird nicht übersetzt; in den Klammern steht ein gewöhnliches Wort, und Wörter in den Klammern sind englisch (Leitregel 1). Deshalb heißt die Funktion `teilaufgabe`, der Parameter aber `subtask-numbering`: Der Parameter benennt nicht die Funktion, sondern die Sache, und für die Sache gibt es in den Klammern genau ein englisches Wort. Ein deutsches Segment in einem Parameter (`teilaufgabe-numbering`) wäre ein Mischname; ein eingedeutschter Parameter (`teilaufgaben-nummerierung`) öffnete die Klammern wieder für beide Sprachen.

Die Tabelle ist abschließend und maschinenlesbar (`wortpaare.json`). Wer in einem Parameter, Schlüssel, Wert, Hook, State-Schlüssel oder Aktionsnamen einen Baustein meint, schreibt das Parameterwort dieser Zeile und kein anderes.

| Baustein | Parameterwort | Vorkommen des Parameterworts |
|---|---|---|
| `arbeitsblatt`, `arbeitsblatt-einzeln` | `worksheet` | `kind: "worksheet"` |
| `klassenarbeit` | `exam` | `kind: "exam"` |
| `aufgabe` | `task`, Plural `tasks` | `task-number`, `points: "tasks"`, `shortcodes: "tasks"`, `"after-task"`, `"per-task"`, `target: "task"`, `reset-tasks`, Hook `task`, `task-marker` |
| `teilaufgabe` | `subtask` | `subtask-numbering`, `subtask-number`, `target: "subtask"`, Hook `subtask` |
| `teilaufgaben` | `subtasks` | `points: "subtasks"`, `shortcodes: "subtasks"` |
| `loesung` | `solution`, Plural `solutions` | `solutions`, `solutions-pagebreak`, `item-solutions`, `solutions-visible`, `show-solutions`, `has-solutions`, Hook `solution`, `solution-heading`, Variante `"solutions"` |
| `lsg` | `inline` | `show-solutions(inline: true)`, `internal.solution-inline` |
| `erwartung` | `expectation`, Plural `expectations` | `expectations`, `show-expectations` |
| `luecke` | `blank` | `uniform-blanks` (insert-a-word) |
| `kariert` | `squares` | `pattern: "squares"` |
| `liniert` | `lines` | `pattern: "lines"` |
| `klausurboegen` | `answer-sheets` | `answer-sheets: (…)` in `klassenarbeit`, Variante `"answer-sheets"` |
| `datensatz` | `dataset`, Plural `datasets` | `datasets:` in `graphen` und `berechnung` |
| `konstante` | `constant`, Plural `constants` | Wert `constants` |
| `sitzordnung` | `seating` | `seating-report`, `seating-summary` (typlace) |
| `wunschliste` | `wishes` | `max-wishes`, Schlüssel `wishes`, `wishes-total`, `wishes-fulfilled` (typlace) |
| `brief`, `gutachten` | – (noch keines vergeben) | wie unten |
| `graphen`, `steckbrief`, `kreisdiagramm`, `messdaten`, `berechnung`, `messwerttabelle`, die sechs Regressionen, `schaltkreis`, `haeufigkeitsanalyse`, `operatoren-liste` | – (noch keines vergeben) | Braucht ein Parameter das Wort, wird es zuerst hier eingetragen. |

`material` und `operator` sind sprachgleich: Funktion und Parameterwort sind dasselbe Wort (`materials`, `show-materials`, `material-heading`).

### 2.2 Erlaubte englische Wörter (`words-en.txt`)

Jedes Segment jedes öffentlichen Namens und jedes Enum-Werts muss in dieser Liste stehen; ausgenommen sind allein die Funktionsnamen aus `bausteine-de.txt`, die als Ganzes gelten. Die Begründung eines Worts ist seine Gruppe. Kein Wort steht zugleich hier und als Segment in `bausteine-de.txt` (L27).

Die Parameterwörter der Bausteine (`worksheet`, `exam`, `task`, `subtask`, `solution`, `expectation`, `blank`, `squares`, `lines`, `answer`, `sheets`) stehen in der Liste, weil sie in Parametern, Schlüsseln und Enum-Werten vorkommen (2.1b), nicht als Funktionsnamen. Gestrichen sind die Wörter, die nur in den entfallenen englischen Funktionsnamen der Fachpakete vorkamen: `graph`, `pie`, `chart`, `function`, `profile`, `derived`, `measurement`, `measurements`, `linear`, `quadratic`, `root`, `exponential`, `power`, `polynomial`, `regression`, `frequency`, `analysis`, `circuit`, `constant`, `overview`, `single`. Braucht ein Parameter eines davon, kommt es mit einem eigenen Diff zurück.

**Gruppe T: Typst-Wörter.** Begründung: Das Paket reicht den Wert an Typst weiter oder benennt dasselbe Ding wie Typst; die Typst-Doku gilt weiter.

```
align background body bottom breakable caption columns fill font footer gutter header
height inside inset label margin math numbering outside page pagebreak paper rows size
stroke table text title top width
```

**Gruppe B: Bestand.** Begründung: Das Wort ist heute schon der Name, regelkonform und im Bestand häufig (Zahl = Vorkommen außerhalb des Repos, soweit gezählt).

```
class (1187)  print (714)  workspace (3541)  workspaces (682)  large (1933)  number (1710)
duplex  landscape (152)  theme  settings (page-settings 164)  minipage (1575)  icon  icons
method  subtitle  date  teacher  student  logo  name  field  repeat  info  figure
items  annotations  grid  line  tight  inline  grouped  compact  scope  setup  url  link
qr  code  box  canvas  draw  plot  unit  qty  num  show  set  reset  get  format  new
copyright  shortcodes  points  variant  variants  material  operator  seed  shuffle  language
```

**Gruppe N: neu, ersetzt ein deutsches oder verstümmeltes Wort.** Begründung je Wort: die Zeile des Glossars, die es einführt.

```
accent achieved all answer area ascent bank before bin blank blocks callout
conditional constants continuation correction count current curriculum dataset
datasets dec default degree descent digital digits domain end exam expectation
expectations filename flex group has heading hex
index individual introduction consolidation is item keywords kind labeled labels legend
level lines materials only options overlay overprint pages pair pattern
pending per place position possible practice preview proposal quiet zone random
integer reserve fallback results revision rotation select sheet sheets shown side
significant solution solutions squares stage stations step steps subject subtask
subtasks subtotals target task tasks to topic total two up value values visible word
worksheet year years after at in boundaries cells continuous counter fa fields grade
keys marker offset overrides path records restart spacing units used
```

Sink-Namen (kein Dokument schreibt sie): `args`, `cells`, `deprecated`.

Abkürzungen sind nur diese: `qr url id csv ascii hex dec bin min max num qty`. Alles andere wird ausgeschrieben (`current` statt `curr`, `index` statt `idx`, `subtask-number` statt `teil`/`ta`, `offset` statt `mv`).

`names.txt` (Eigennamen und Lehnwörter, als Segment erlaubt): `angela atbash atlas bauhaus caesar geogebra iaword klar kontur labor leiste riso rot13 skizze vigenere ea ga a4 a5 a3`, dazu als ganze Werte `sek-1` und `sek-2`.

Eine deutsche Negativliste gibt es nicht. Die beiden Positivlisten (`bausteine-de.txt` für Funktionen, `words-en.txt` für alles andere) genügen, und das Verzeichnis alter Namen ist die Compat-Tabelle (Abschnitt 9).

### 2.3 Umlaut-Regel

Kein Umlaut und kein ß in irgendeinem Bezeichner, Enum-Wert, Schlüssel, State-Schlüssel, Label oder Dateinamen des Pakets. In den deutschen Namen aus 2.1 gilt die Umschrift `ae`, `oe`, `ue`, `ss` (`klausurboegen`, `luecke`, `loesung`, `haeufigkeitsanalyse`). Ein Baustein mit Umlaut wird nicht zusätzlich exportiert: `lücke` und `klausurbögen` sind keine zweiten Namen, sondern abbrechende Stubs (9.3). Begründung: Paket- und Dateinamen müssen ohnehin ASCII sein; `größe` und `groesse` sind für Typst zwei verschiedene Namen, und Typst kann davor nicht warnen; im Bestand ist die Umschrift die Mehrheit (`#loesung(` 85, `#lösung(` 0).

Text im PDF und in Fehlermeldungen behält Umlaute. Die Fehlermeldung faltet Umlaute, bevor sie nachschlägt (8.4).

### 2.4 Schreibweise

Jeder Bezeichner und jeder Enum-Wert passt auf `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`. Kein Unterstrich, kein Großbuchstabe, keine Ziffer als Wort (`bin-to-dec`, nicht `bin2dec`), kein einbuchstabiger Name. Ausnahmen: Typst-Nummerierungsmuster als Werte (`"a)"`, `"1.1"`), Daten nach 2.1 und Achsenbezeichner in Formeln (`x`, `y` als Parameter in mathematik und physik).

---

## 3. Glossar: ein Begriff, ein Wort

Verbindlich für alle Pakete. Bei einem Baustein nennt die dritte Spalte zwei Dinge: den deutschen Funktionsnamen (aus `bausteine-de.txt`) und das englische Parameterwort (2.1b). Der Funktionsname gilt nur für die Funktion, das Parameterwort nur in den Klammern und in Aktionsnamen. Die letzte Spalte nennt, was heute im Code oder in früheren Entwürfen dafür steht und nicht mehr vorkommen darf; „als Funktion" heißt: das Wort ist als Parameterwort erlaubt, aber kein Funktionsname. Maschinenlesbar ist das Glossar als `glossar.json` mit den Feldern `baustein`, `wort`, `typ`, `verboten`, `verboten-als-funktion`.

| Nr. | Begriff | verbindlicher Name | Typ | verbotene Synonyme (heute im Code) |
|---|---|---|---|---|
| 1 | Arbeitsblatt (Vorlage) | Baustein `arbeitsblatt`, `arbeitsblatt-einzeln`; Parameterwort `worksheet` | Funktion | `ab`; `worksheet`, `worksheet-single` als Funktion |
| 2 | Klassenarbeit, Klausur (Vorlage) | Baustein `klassenarbeit`; Parameterwort `exam` | Funktion | `ka`; `exam` als Funktion; `exam:` als Titel im Klausurbogen |
| 3 | Aufgabe | Baustein `aufgabe`; Parameterwort `task` | Funktion | `aufg`, `aufgaben-` als Präfix, `exercise`; `task` als Funktion |
| 4 | Teilaufgabe | Baustein `teilaufgabe`, Sammlung `teilaufgaben`; Parameterwort `subtask`, `subtasks` | Funktion | `teil`, `ta`, `tasks` als Funktion (0.2.x), `sub`, `teilaufgabe-` als Präfix; `subtask`, `subtasks` als Funktion |
| 5 | Lösung | Baustein `loesung`; Parameterwort `solution`, Option `solutions` | Funktion, Auswahl | `lösung`, `loesungen`, `show-solution`, `loesungsmodus`; `solution` als Funktion |
| 6 | Lösung im Fließtext | Baustein `lsg`; Parameterwort `inline` | Funktion | `inline-solution` als Funktion |
| 7 | Erwartung (Erwartungshorizont) | Baustein `erwartung`; Parameterwort `expectation`, Option `expectations` | Funktion, Merkmal | `erwartungen`, `bewertung`; `expectation` als Funktion |
| 8 | Punkte (BE) | `points` | int, float; als Option Auswahl | `punkte`, `be`, `BE` |
| 9 | Material | `material`, Option `materials` | Funktion, Auswahl | `materialien` |
| 10 | Arbeitsfläche | `workspace`, Option `workspaces` | content, bool | `platz`, `arbeitsflaeche` |
| 11 | Lücke | Baustein `luecke`; Parameterwort `blank` | Funktion | `lücke`, `lueck`, `gap`; `blank` als Funktion |
| 12 | Klausurbogen | Baustein `klausurboegen`; Parameterwort und Merkmal `answer-sheets` | Funktion, Merkmal | `klausurbögen`, `bogen`, `klausurboegen-settings`, `klausurboegen:` als Parameter; `answer-sheets` als Funktion |
| 13 | Titel | `title` | content, none | `titel`, `exam`, `name` (als Linktext) |
| 14 | Untertitel | `subtitle` | content, none | `subexam`, `untertitel` |
| 15 | Klasse, Kurs | `class` | str, none | `klasse` |
| 16 | Fach | `subject` | str, none | `fach` |
| 17 | Thema | `topic` | str, none | `thema` |
| 18 | Datum | `date` | str, content, none | – (Vorgabe `"09.10.2023"` entfällt) |
| 19 | Lehrkraft | `teacher` | str, content, none | – (Vorgabe `"SLZ"` entfällt) |
| 20 | Schülerin, Schüler | `student` | str, content, none | `schueler`, `students` als Notendaten |
| 21 | Jahrgang | `years` | array aus int | `jahrgang`, `grades` |
| 22 | Note, Notengrenze | `grade`, `grade-boundaries` | – | `note`, `gradeBoundaries` |
| 23 | Schulstufe | `stage` | `"sek-1"`, `"sek-2"` | `stufe`, `sek1` |
| 24 | Anforderungsniveau | `level` | Auswahl | `niveau` |
| 25 | Art, Sorte | `kind` | Auswahl | `typ`, `art` |
| 26 | Akzentfarbe | `accent` | color, auto | `akzent`, `farbe`, `accent-color`, `color` |
| 27 | Füllfarbe eines Elements | `fill` | color, none | `fill-color`, `dark-color`, `color`, `farbe` |
| 28 | Hintergrundfarbe hinter einer eigenen Füllung | `background-fill` | color, none | `light-color`, `background` (qr-code), `hintergrund` |
| 29 | Seitenhintergrund (Hook) | `background` | Hook | `hintergrund` |
| 30 | Linie, Rahmen | `stroke`, mit Ziel `<ziel>-stroke` | stroke | `line-stroke`, `linie` |
| 31 | Breite | `width` | length, fraction, auto | `breite`, `width` als Kästchenzahl |
| 32 | Höhe | `height` | length, fraction, auto | `hoehe` |
| 33 | Abstand zwischen Spalten oder Zellen | `gutter` | length | `spacing` (minipage), `abstand` |
| 34 | Abstand zwischen gestapelten Einträgen | `spacing` | length | `item-spacing`, `items-spacing` als Länge |
| 35 | Innenabstand | `inset` | length, dictionary | – |
| 36 | Spalten (Anzahl oder Typst-Spaltenangabe) | `columns` | wie Typst | `spalten`, `width` (kariert) |
| 37 | Zeilen (Anzahl) | `rows`, je Eintrag `item-rows` | int | `zeilen`, `items-spacing` als Anzahl |
| 38 | Anzahl | `count`, mit Ding `<ding>-count` | int | `anzahl`, `amount`, `n`, `cnt`, `anzahl-messwerte`, `max_wert_pro_tabelle` |
| 39 | Nummerierungsmuster | `numbering`, mit Ziel `subtask-numbering`, `page-numbering` | str | `teilaufgabe-numbering` |
| 40 | Nummer anzeigen | `number` | bool | – |
| 41 | Nummer als Zahl | `task-number`, `subtask-number` | int | `aufg`, `teil`, `nummer` |
| 42 | Position in einer Liste, ab 0 | `index` | int | `idx` |
| 43 | Beschriftung statt Nummer | `marker` | content, none | `item-label`, `marke`, `nummer` |
| 44 | Verweisziel | `label` | label, str, none | – (nie für Sichtbares) |
| 45 | Bildunterschrift | `caption` | content, none | `beschriftung` |
| 46 | Achsen- und Kurvenbeschriftung | `labels`, Schalter `labeled` | array, bool | `energy-name`, `hide-letters`, `x-label` neben `beschriftung` |
| 47 | Legende | `legend` | bool, content | `legende` |
| 48 | Schrift | `font`, `math-font` | str, array, auto | `schrift`, `schrift.text`, `schrift.mathe` |
| 49 | Schriftgröße | `font-size`, mit Ziel `title-font-size`, `figure-font-size` | length, auto | `schrift.groesse`, `schrift.titel`, `header-font-size`, `größe` |
| 50 | Papier | `paper` | str | – |
| 51 | Querformat | `landscape` | bool | – (Typsts `flipped` wird nicht benutzt) |
| 52 | Seitenrand | `margin` | dictionary wie Typst | `rand`, `margins` |
| 53 | Korrekturrand | `correction-margin` und Geschwister | length | `rand`, `korrekturrand`, `weißer-rand`, `line-stroke` |
| 54 | Kopf, Fuß | `header`, `footer` | content, auto, none | `custom-header`, `kopf`, `fuss` |
| 55 | Druckfassung | `print` | bool | `druck`, `print-state` |
| 56 | Doppelseitig | `duplex` | bool | – |
| 57 | Zwei Seiten je Bogen | `two-up` | bool | `zweifach` |
| 58 | Variante | `variants`, eine davon `preview-variant` | array, str | `varianten`, `variante`, `vorschau-alle` |
| 59 | Dateiname | `filename` | str, none | `dateiname` |
| 60 | Dateipfad | `path` | str | `datei` |
| 61 | Gestaltung | `theme` | auto, str, dictionary, Funktion | `"standard"` als Wert |
| 62 | Muster einer Arbeitsfläche | Bausteine `kariert`, `liniert`; Parameter `pattern` mit den Werten `"squares"`, `"lines"` | Funktion, Auswahl | `muster`; `"kariert"`, `"liniert"` als Werte; `squares`, `lines` als Funktion |
| 63 | Kästchengröße | `grid-size` | length | `scale` (Faktor), `raster` |
| 64 | Zeilenabstand (Linienabstand) | `line-height` | length | `linienabstand`, `lineheight`, `raster` |
| 65 | Nachkommastellen | `digits` | int | `precision`, `round`, `nachkommastellen`, `stellen` |
| 66 | Geltende Stellen | `significant-digits` | int | `precision` in zweiter Bedeutung |
| 67 | Einheit | `unit`, mehrere `units` | str, content | `einheit`, `einheiten` |
| 68 | Wert, Werte | `value`, `values` | – | `wert`, `werte`, `zahl`, `num`, `hex` als Parametername |
| 69 | Datensatz | Baustein `datensatz`; Parameterwort `dataset`, `datasets` | Funktion, Array | `datensätze`, `datensaetze` als Parameter; `dataset` als Funktion |
| 70 | Wertebereich | `domain` | array | `bereich`, `x-min`/`x-max` einzeln |
| 71 | Schrittweite, Schrittzahl | `step`, `steps` | float, int | `schritte`, `samples` |
| 72 | Position (Ort an einem Ding) | `position`, als Geschwister `<option>-position` | Auswahl | `pos`, `ort`, `anzeige`-Schlüssel `position` |
| 73 | Seite (links, rechts, innen, außen) | `side` | Auswahl | `korrekturrand` als Seitenangabe |
| 74 | Verschiebung | `offset` | dictionary `(dx:, dy:)` | `mv`, `versatz` |
| 75 | Drehung | `rotation` | angle | `angle` |
| 76 | Kasten (Merke, Tipp) | `callout` | Hook, Familie | `kasten`, clue |
| 77 | Symbol vor einem Text | `icon`, mehrere `icons` | content | `symbol`, `symbole` |
| 78 | Einträge einer Liste | `items` | array | `tasks:`, `eintraege` |
| 79 | Inhalt | `body` (positional, zuletzt) | content | `inhalt`, `content`, `text`, `name` |
| 80 | Inhalt über einem Muster | `overlay` | content, none | `content` (kariert) |
| 81 | Kopfzeile einer Tabelle | `header` | array | `kopfzeile` |
| 82 | Ergebnisse (Notendaten) | `results` | array | `ergebnisse`, `students`, `result` |
| 83 | Vorschlag (Abitur) | `proposal` | str, content, none | `vorschlag` |
| 84 | Sprache | `language` | str | `lang` |
| 85 | Zufalls-Startwert | `seed` | int | `default_seed` |
| 86 | Auswahl aus Gesammeltem | `select` | Auswahl | `curr`, `alle`, eigene Funktion `show-offene-` |
| 87 | Stand (Datum der Überarbeitung) | `revision` | str, none | `stand` |
| 88 | Stichworte, Kerncurriculum | `keywords`, `curriculum` | array | `stichworte`, `kerncurriculum` |
| 89 | Sozialform | `method` | Auswahl | Werte `"EA"`, `"PA"`, `"GA"`, `""` |
| 90 | Kurzcodes | `shortcodes` | Auswahl | `aufgaben-shortcodes` |

Numerus-Vermerk: Ein Name mit der Vorgabe `()` oder `(:)` steht im Plural (`items`, `icons`, `years`, `keywords`, `results`, `annotations`, `variants`, `labels`). `points` ist ein Pluralwort der Sache und gilt als Singular.

---

## 4. Grammatik

### 4.1 Funktionsnamen

| Art | Muster | Beispiele |
|---|---|---|
| Deutscher Baustein (Vorlage, Ding, Datenwert) | der Name aus `bausteine-de.txt`, unverändert | `arbeitsblatt`, `klassenarbeit`, `aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung`, `lsg`, `luecke`, `kariert`, `liniert`, `klausurboegen`, `graphen`, `messwerttabelle` |
| Englischer Helfer, der ein Ding setzt | Substantiv im Singular | `material`, `workspace`, `minipage`, `operator`, `source` |
| Zusammengesetzter englischer Helfer | `<merkmal>-<substantiv>` | `qr-code`, `qr-box`, `icon-link`, `conditional-pagebreak`, `flex-area`, `ascii-table`, `caesar-table` |
| Aktion: Gesammeltes ausgeben | `show-<plural>` | `show-solutions`, `show-materials`, `show-expectations`, `show-points-table` |
| Aktion: Zustand setzen, zurücksetzen | `set-<plural>`, `reset-<plural>` | `set-options`, `reset-tasks`, `reset-iaword` |
| Abfrage eines Werts | `get-<substantiv>` | `get-points` |
| Abfrage eines Wahrheitswerts | `is-<adjektiv>`, `has-<plural>` | `is-print`, `has-solutions`, `is-flex-area` |
| Umwandlung | `<von>-to-<nach>`, `format-<substantiv>` | `bin-to-dec`, `text-to-blocks`, `format-points` |

Die Grammatik dieser Tabelle gilt für englische Namen. Deutsche Bausteine werden nicht gebildet, sondern aus der Liste genommen; Numerus und Wortart sind dort festgelegt (2.1a).

Das Verb steht immer vorn. Erlaubte Verben: `show set reset get has is format`. Kein Imperativ als Parametername (`draw` ist nur als cetz-Modul erlaubt). Sammelausgaben des Kerns tragen immer `show-`.

**Aktionen und Abfragen sind rein englisch.** Hinter dem Verb steht das Parameterwort aus 2.1b, nie der deutsche Baustein: `show-solutions`, nicht `show-loesungen`; `reset-tasks`, nicht `reset-aufgaben`; `format-points`, nicht `format-punkte`. Damit sind Baustein und Aktion schon an der Sprache zu unterscheiden (`loesung` setzt eine Lösung, `show-solutions` gibt die gesammelten aus). Geprüft für alle Aktionen und Abfragen dieses Dokuments: `set-options`, `reset-tasks`, `show-solutions`, `show-materials`, `show-expectations`, `show-points-table`, `get-points`, `format-points`, `has-solutions`, `is-print`, `is-flex-area`, `reset-iaword` enthalten kein Segment aus `bausteine-de.txt`. Das Lint hält das fest (L27).

`operatoren-liste` gibt zwar Gesammeltes aus, ist aber als Baustein gelistet: „Operatorenliste" ist selbst der Schulbegriff, und der Name hat kein Verb-Präfix (Anhang B).

### 4.2 Singular und Plural

- Singular: ein Ding, ein Wert, ein Inhalt (`title`, `workspace`, `marker`, `label`, `unit`).
- Plural: Sammlung (Array, Dictionary), Dokumentoption über alle Vorkommen (`solutions`, `materials`, `workspaces`, `shortcodes`), Zählgröße (`rows`, `columns`, `steps`, `digits`).
- Bestimmungswort im Kompositum steht im Singular (`subtask-numbering`, `item-rows`, `solution-heading`, `material-heading`). Einzige Ausnahme: das Geschwister einer Option trägt deren vollen Namen als Präfix (`points-format`, `solutions-pagebreak`, `materials-pagebreak`). Das Lint erkennt die Ausnahme daran, dass das Präfix in derselben Signatur als Parameter steht.
- Zwei Namen derselben Signatur und zwei Werte derselben Auswahl haben mindestens Levenshtein-Abstand 2. Geschwister mit Präfix sind davon ausgenommen, wenn der Rest sich um mindestens 2 unterscheidet.

### 4.3 Schalter sind positiv

Ein bool-Parameter benennt, was bei `true` da ist oder gilt: `print`, `duplex`, `landscape`, `two-up`, `workspaces`, `large`, `number`, `tight`, `reserve`, `grouped`, `achieved`, `compact`, `labeled`, `breakable`, `points-total`. Verboten sind die Präfixe `no- non- not- hide- without- disable-`, das Suffix `-only` und jeder Schalter, der eine Abwesenheit beschreibt. Ein Schalter wird bei der Umbenennung nie umgedreht: `large` bleibt `large`, `number` bleibt `number`. Die drei heutigen Negativschalter werden einmalig gewendet: `headless: true` wird `title: none`, `hide-words: false` wird `word-bank: true`, `hide-letters: false` wird `labeled: true`.

### 4.4 Reihenfolge und Art der Argumente

1. **Reihenfolge in der Signatur:** führendes Hauptargument (höchstens eines), benannte Parameter, zuletzt `body`.
2. **Positional ist nur:** der Inhalt `body`; höchstens ein führendes Hauptargument, dessen Typ sich vom Inhalt unterscheidet (`erwartung(2)[…]`, `kariert(4)`, `liniert(3)`, `get-points(1)`, `qr-code("https://…")`, `icon-link(url)[Text]`); eine Liste gleichartiger Inhalte (`minipage[a][b]`).
3. **Benannt ist alles andere**, jeder Schalter und jede Auswahl. Kein bool, kein `none`, kein Dictionary als Positionsargument.
4. **Ein Weg je Angabe.** Der Titel einer Aufgabe steht nur in `title:`; `aufgabe[Titel][Rumpf]` ist ein Fehler mit Abhilfe. Die Punkte einer Erwartung stehen nur vorn; `erwartung(points: 2)[…]` ist ein Fehler mit Abhilfe (heute still 0 Punkte). Die Spaltenzahl von `kariert` steht nur in `columns:`.
5. **Sink (`..args`) nur in drei Fällen:** (a) Liste gleichartiger Positionsargumente, (b) optionales führendes Hauptargument, (c) `..deprecated` als Abfang alter Namen (Abschnitt 9). Es gibt keinen Durchreich-Sink an Fremdfunktionen (`table`, `stickybox`, zebra). Was durchgereicht werden soll, wird deklariert (`inset`, `align`, `rotation`, `quiet-zone`). Einzige Ausnahme: `page-settings: (:)` geht als Ganzes an `set page`.
6. **Jeder Sink wird geprüft:** überzählige Positionsargumente und unbekannte benannte führen zu einer Meldung nach Abschnitt 8.
7. **Hooks** (Funktionen im Theme-Dictionary) sind Schlüssel und deshalb englisch. Ein Hook, der einen Baustein zeichnet, trägt dessen Parameterwort aus 2.1b (`task` zeichnet `aufgabe`, `subtask` zeichnet `teilaufgabe`, `solution` zeichnet `loesung`); ein Hook, der einen Kopfparameter zeichnet, trägt dessen Namen (`header`, `footer`). Er bekommt dieselben Parameternamen wie der Baustein oder Kopfparameter, benannt, und `body` zuletzt. Ein Hook mit genau einem Argument bekommt es positional.

### 4.5 Keine Überdeckung

- Keine eigene Funktion und kein exportierter Name heißt wie ein Name aus `std`.
- Ein Parameter darf wie ein Typst-Builtin heißen, wenn er den Durchreichtest besteht oder im Glossar steht (`title`, `label`, `numbering`, `columns`, `align`, `stroke`, `text`, `header`, `footer`, `figure`). Dann gilt im ganzen Paket: dieses Builtin wird nur als `std.<name>` geschrieben.
- Kein Parameter heißt wie eine Funktion desselben Pakets. Für die Bausteine folgt das schon aus der Sprachtrennung (kein Parameter heißt `aufgabe`). Unter den englischen Funktionen betrifft die Regel `material`, `workspace`, `minipage`, `operator`: Kein Parameter desselben Pakets heißt so (die Option heißt `materials`; `workspace:` ist ein Parameter in aufgaben, die Funktion `workspace` gehört zu arbeitsblatt).
- Die bloßen Parameterwörter `task`, `subtask`, `solution` sind als Parameternamen frei, werden aber nicht ohne Zusatz benutzt, weil sie keinen Typ erkennen ließen: `task-number` (int), `subtask-number` (int), `item-solutions` (Array). Als Schlüssel stehen sie nur im Theme-Dictionary (Hooks).

---

## 5. Wertekonvention

### 5.1 Die zulässigen Formen

Jeder Parameter hat genau eine Grundform. Das Lint prüft den Typkommentar der Signatur gegen diese Tabelle.

| Form | Wofür | Typ | Aus | Beispiele |
|---|---|---|---|---|
| W1 Schalter | an oder aus, kein dritter Zustand | `bool` | `false` | `print`, `duplex`, `workspaces`, `number`, `large` |
| W2 Auswahl | benannte Möglichkeiten | String-Enum, dazu `none` | `none` | `solutions`, `points`, `shortcodes`, `pattern`, `kind` |
| W3 Wert | Länge, Zahl, Farbe, Inhalt, Array | der Typ | – | `width`, `count`, `items` |
| W4 Wert, der fehlen darf | wie W3 | Typ oder `none` | `none` | `title`, `workspace`, `marker`, `proposal` |
| W5 Wert mit Paketvorgabe | Paket oder Theme bestimmt sinnvoll selbst | Typ oder `auto` | – | `accent`, `font`, `font-size`, `columns`, `logo`, `header` |
| W6 Merkmal mit Einstellungen | eine Funktion des Pakets, die an- und abgeschaltet und eingestellt wird | `false`, `true` oder Dictionary | `false` | `expectations`, `answer-sheets` |
| W7 Wert je Ziel | derselbe Wert für mehrere feste Ziele, wie Typsts `inset` | Wert oder Dictionary mit festen Schlüsseln | – | `points-format: f` oder `(task: f, subtask: g)`, `inset` |
| W8 Name statt Wert | ein eingetragener Name steht für den Wert | Wert oder `str` | – | `theme: "klar"`, `logo: "angela"`, `paper: "a4"`, `font` |
| W9 wie Typst | Parameter besteht den Durchreichtest | genau der Typ des Typst-Parameters | wie Typst | `columns` in `minipage`, `stroke`, `margin`, `numbering` |

Festlegungen:

- `auto` und `none` dürfen zu W3, W7, W8 und W9 hinzutreten (das ergibt W4 und W5). `auto` heißt immer „das Paket oder das Theme entscheidet", `none` heißt immer „nichts". `auto` bedeutet nie „an".
- **Bei W8 darf der Wert selbst ein Dictionary oder eine Funktion sein, die das Dictionary liefert** (`theme`). Das ist die einzige Stelle mit einer Funktion als Wert neben den Hooks und `points-format`.
- **Kein Parameter ist zugleich Auswahl und Einstellungs-Dictionary** (`punkte: "alle"` oder `(anzeige:, position:)`). Untereinstellungen werden flache Geschwister mit dem Optionsnamen als Präfix.
- **W6 kennt keinen Schlüssel `show`.** Ein Dictionary heißt „an". Seine Schlüssel sind genau die benannten Parameter der zugehörigen Funktion und werden mit derselben Tabelle geprüft.
- **Gleicher Name, gleicher Grundtyp in allen Funktionen aller Pakete.** `auto` und `none` zählen dabei nicht. Deshalb `number` (bool) und `task-number` (int), `solutions` (Auswahl) und `item-solutions` (Array), `background` (Hook) und `background-fill` (Farbe), `level` (Niveau) und `target` (Ziel von `format-points`).

### 5.2 Das eine „aus"

`false` bei W1 und W6, `none` überall sonst. Verboten als Aus: `"none"`, `"false"`, `"keine"`, `""`, `false` für eine Auswahl, `none` für einen Schalter. Leerer Text ist `none`, nie `""`. Die Prüfung nennt bei jedem falschen Aus das richtige (8.3).

### 5.3 Enum-Werte

Englisch, kebab-case, ohne Verneinung. Ein Wert benennt, was gezeigt wird oder wo, nie, was fehlt (`"keine-summe"` wird `points-total: false`). Vordefinierte Variantennamen sind Enum-Werte: `"print"`, `"digital"`, `"solutions"`, `"two-up"`, `"answer-sheets"`.

**Enum-Werte sind englisch, auch wenn sie einen Baustein meinen.** Der Wert ist dann das Parameterwort aus 2.1b, nie der deutsche Bausteinname: `kind: "exam"` (nicht `"klassenarbeit"`), `pattern: "squares"` (nicht `"kariert"`), Variante `"answer-sheets"`, `points: "subtasks"`, `target: "task"`. Eine Ausnahme gibt es nicht; ein deutscher Bausteinname als Wert bekommt die Meldung „ungültiger Wert" mit dem englischen Vorschlag (8.3).

**Kein Enum, wo der Baustein selbst übergeben werden kann.** Nimmt ein Parameter den Inhalt einer Fläche auf, bekommt er den Baustein als Wert und keine Auswahl: `workspace: kariert(4)`, `workspace: liniert(3)`; ein `workspace-pattern: "squares"` daneben gibt es nicht. Ein Muster-Enum steht nur dort, wo die Funktion das Muster selbst über eine Fläche legt, deren Größe das Dokument nicht kennt. Das ist heute genau ein Parameter: `pattern` in `klausurboegen` (und im gleichnamigen Dictionary `answer-sheets: (pattern: …)` von `klassenarbeit`), mit den Geschwistern `grid-size` und `line-height`. Das Paar `pattern: "squares"` und `kariert(4)` im selben Dokument ist damit kein Mischbild zweier Namen für eine Funktion, sondern Wert und Baustein nach Leitregel 1.

### 5.4 Dictionaries

- Schlüssel folgen denselben Regeln wie Parameter und werden geprüft, auch verschachtelt.
- Ein Dictionary, das an Typst geht, hat Typsts Schlüssel (`margin: (top:, bottom:, inside:, outside:)`, `stroke: (paint:, thickness:)`, `offset: (dx:, dy:)`).
- Ein Dictionary des Pakets hat nie gemischtsprachige Schlüssel.
- Schlüssel des Theme-Dictionary heißen exakt wie die gleichbedeutenden Kopfparameter (`font`, `math-font`, `font-size`, `title-font-size`, `margin`). Es gibt kein verschachteltes `fonts`.
- Die Schlüssel des Options-States sind genau die Namen der Kopfparameter.

### 5.5 Einheiten

- Längen sind Typst-Längen oder `fr`, nie nackte Zahlen. Ein Parameter, der auf `width`, `height`, `gutter`, `spacing`, `inset`, `margin`, `-size`, `-height`, `-width`, `offset` endet, hat nie den Typ int oder float.
- Anzahlen sind int und heißen `rows`, `columns`, `count`, `steps`, `digits` oder `<ding>-rows`, `<ding>-count`.
- Faktoren gibt es im Kern nicht (`scale: 1` wird `grid-size: 0.5cm`).
- Winkel sind `angle`, Anteile `ratio`, Punkte int oder float.
- **Eine Umbenennung ändert keine Vorgabe.** `minipage` behält `gutter: 5mm`, `liniert` behält `line-height: 1cm`. Abnahmekriterium: gleiches Dokument, gleiches PDF.

---

## 6. Gemeinsames Options-Schema

Das Schema wird einmal in aufgaben definiert und geprüft (`internal.option-schema`). `arbeitsblatt`, `arbeitsblatt-einzeln`, `klassenarbeit`, `set-options` und die Varianten-Overrides benutzen dieselben Namen, Typen und Werte. Die Optionen sind Parameter und deshalb englisch, auch wo sie einen Baustein meinen (`solutions`, `points: "subtasks"`, `subtask-numbering`; Wortpaare in 2.1b). Jede Vorlage deklariert alle Optionen in ihrer Signatur; eine abweichende Vorgabe ist dort sichtbar.

| Option | Form | Werte | Vorgabe arbeitsblatt, aufgaben | Vorgabe klassenarbeit |
|---|---|---|---|---|
| `solutions` | W2 | `none`, `"in-place"`, `"after-task"`, `"at-end"`, `"only"` | `none` | `none` |
| `solutions-pagebreak` | W2 | `none`, `"before"`, `"per-task"` | `none` | `none` |
| `materials` | W2 | `none`, `"after-task"`, `"at-end"` | `"after-task"` | `"after-task"` |
| `materials-pagebreak` | W2 | `none`, `"before"` | `"before"` | `"before"` |
| `points` | W2 | `none`, `"tasks"`, `"subtasks"`, `"all"` | `none` | `"tasks"` |
| `points-total` | W1 | `true`, `false` | `true` | `true` |
| `points-position` | W2 | `"end"`, `"margin"` | `"end"` | `"end"` |
| `points-format` | W7 | `auto`, Funktion `points => content`, `(task: f, subtask: g)` | `auto` | `auto` |
| `workspaces` | W1 | `true`, `false` | `true` | `true` |
| `shortcodes` | W2 | `none`, `"tasks"`, `"subtasks"`, `"all"` | `"subtasks"` | `"subtasks"` |
| `subtask-numbering` | W9 | Typst-Muster, zum Beispiel `"a)"`, `"1.1"` | `"a)"` | `"a)"` |

Bedeutung der Werte:

| Wert | Bedeutung | heute |
|---|---|---|
| `solutions: "in-place"` | Lösung direkt nach jeder Teilaufgabe | `"sofort"` |
| `solutions: "after-task"` | gesammelt nach jeder Aufgabe | `"folgend"` |
| `solutions: "at-end"` | gesammelt am Dokumentende | `"reinquetschen"`, `"seite"`, `"seiten"` |
| `solutions: "only"` | nur Lösungen, der Aufgabentext entfällt | `"nur"` |
| `solutions-pagebreak: "before"` | Seitenumbruch vor dem Lösungsblock | `"seite"` |
| `solutions-pagebreak: "per-task"` | zusätzlich je Aufgabe eine neue Seite; nur mit `"at-end"` **[prüfen]** | `"seiten"` |
| `materials: "after-task"` | Material nach der Aufgabe, zu der es gehört | `"sofort"`, `"folgend"`, `"seiten"` |
| `materials: "at-end"` | gesammelt am Dokumentende | `"reinquetschen"`, `"seite"` |
| `materials-pagebreak: "before"` | Seitenumbruch (weich) vor jedem Materialblock | `"seiten"`, `"seite"` |
| `points: "all"` | Punkte an Aufgaben und Teilaufgaben | `"alle"` |
| `points-total: false` | keine Summe an Aufgaben, die Teilaufgaben haben; Aufgaben ohne Teilaufgaben zeigen ihre Punkte weiter | `"keine-summe"` (= `points: "all", points-total: false`) |
| `subtask-numbering: "1.1"` | Aufgabe.Teil | `"1."` **[prüfen]** |

Die heutige Vorgabe `materialien: "seiten"` ist damit `materials: "after-task", materials-pagebreak: "before"`: Material steht nach der jeweiligen Aufgabe auf einer neuen Seite (so im Code, `aufgaben.typ` 1076–1080), nicht am Dokumentende. `"per-task"` ohne `"at-end"` ist ein Fehler.

Dieselben Wörter an jeder Stelle:

| Stelle | Schreibweise |
|---|---|
| Dokumentkopf | `#show: arbeitsblatt.with(solutions: "in-place", points: "all")` |
| mitten im Dokument | `set-options(solutions: "only")`; deklarierte Parameter, `auto` heißt „unverändert" |
| eigene Variante | `variant-overrides: (kontrolle: (solutions: "at-end", workspaces: false))` |
| vordefinierte Variante | `variants: ("print", "solutions")`; `"solutions"` = `print: true, solutions: "only", workspaces: false` |
| Abfragen | `has-solutions()`, `is-print()` |
| Umbruch nur in einer Fassung | `conditional-pagebreak(print: true)`, `conditional-pagebreak(solutions-visible: true)` |
| abhängige Funktionen | `lsg`, `luecke`, insert-a-word folgen `has-solutions()`; ein eigener Schalter `show-solution` entfällt |

Merkmale mit Einstellungen in `klassenarbeit` (Form W6). Der Parameter heißt `answer-sheets`, der Baustein dahinter `klausurboegen`; die Schlüssel des Dictionary sind dessen benannte Parameter:

```typ
expectations: true                                  // an (Vorgabe)
expectations: false                                 // aus
expectations: (achieved: true, grouped: true)       // an, mit Einstellungen
answer-sheets: (pattern: "lines", correction-margin-side: "outside")
```

---

## 7. Öffentliche Oberfläche

### 7.1 Exporte

- Jedes Paket hat eine Einstiegsdatei `src/lib.typ`. Sie importiert und exportiert ausschließlich namentlich. `import …: *` ist in Paketquelltext verboten.
- Exportiert werden: die eigenen öffentlichen Funktionen und Konstanten (deutsche Bausteine und englische Namen); das Modul `internal`; die Fremdnamen aus `fremdnamen.txt`; solange die Compat-Tabelle läuft, die abbrechenden Stubs alter Funktionsnamen (9.3). Übergangsnamen oder Aliase gibt es nicht.
- **`fremdnamen.txt`** ist die geprüfte, abschließende Liste bewusst durchgereichter Fremdnamen. Startbestand für arbeitsblatt: `canvas`, `draw` (cetz), `plot` (cetz-plot), `qty`, `num`, `unit` (Einheiten-Wrapper), `stickybox` (colorful-boxes, 45 Aufrufe im Bestand), `fa-icon` (fontawesome). Alles andere importiert das Dokument selbst. Der Kasten `task` aus gentle-clues kollidiert mit keinem eigenen Namen mehr (es gibt keine Funktion `task`); er steht trotzdem nicht im Startbestand, weil kein Bestand ihn belegt. `#task[…]` ist damit ein gewöhnlicher Typst-Fehler „unknown variable" und keine still geänderte Bedeutung.
- klassenarbeit exportiert alles, was arbeitsblatt exportiert, namentlich; aufgaben exportiert nur Eigenes.
- Die 15 Kästen (`abstract`, `info`, `question`, `memo`, `conclusion`, `tip`, `success`, `warning`, `error`, `example`, `goal`, `idea`, `experiment`, `notify`, `danger`) sind eigene Funktionen von arbeitsblatt mit einer gemeinsamen Signatur (Anhang A.11).
- Das Lint prüft die tatsächlich exportierte Namensmenge (per `typst eval` auf `dictionary(lib)`), nicht nur `#let` im Quelltext.

### 7.2 Interne Namen

- Interne Namen stehen in `src/internal.typ` und werden als ein einziges Modul `internal` exportiert. Zugriff zwischen Paketen läuft nur darüber (`aufgaben.internal.options-state`).
- Der Unterstrich als Privat-Marke entfällt; er schützt in Typst nichts. `_state_ab_scope`, `_state_options`, `_counter_aufgaben` und `state("options")` gibt es nicht mehr.
- Interne Namen folgen Abschnitt 2.4 (englisch, kebab-case), aber ohne Glossarpflicht.
- Was in `internal` steht, ist keine zugesicherte Schnittstelle und darf sich in jeder Version ändern. Dokumente benutzen es nicht.

### 7.3 State, Counter, Labels

| Art | Muster | Beispiele |
|---|---|---|
| State- und Counter-Schlüssel | `schule/<paketname>/<name>@<schema>` | `"schule/aufgaben/options@1"`, `"schule/aufgaben/records@1"`, `"schule/aufgaben/task-counter@1"`, `"schule/arbeitsblatt/scope@1"`, `"schule/operatoren/used@1"` |
| neue Labels des Pakets | `<schule-<paketname>-<name>>` | `<schule-aufgaben-task-1>` |
| eingefrorenes Label | `<ab-meta>` mit deutschen Schlüsseln | unverändert, siehe 2.1 |

`<paketname>` ist der echte Paketname (`aufgaben`, nicht `tasks`). `<schema>` wird erhöht, sobald sich die Gestalt des gespeicherten Werts ändert; so teilen sich zwei Paketversionen im selben Dokument nie einen State mit verschiedener Gestalt. Jeder State wird genau einmal in `internal.typ` angelegt; im übrigen Quelltext steht kein `state("…")` und kein `counter("…")`.

---

## 8. Fehlermeldungen

### 8.1 Sprache und Mechanik

Deutsch, ganze Sätze sind nicht nötig. Namen und Werte stehen in Backticks und sind die echten Bezeichner: der deutsche Bausteinname, die englischen Parameter und Werte. Erzeugt werden Meldungen nur über `internal.fail(function, message)`; `panic` und `assert` mit freiem Text gibt es im Paketquelltext nicht. Kein Fehler wird als Rückgabewert (`error`-Feld) gemeldet, keine falsche Eingabe wird still übergangen.

### 8.2 Festes Format

```
<paket>.<funktion>: <was falsch ist> – <Abhilfe>
```

`<paket>` ist der Paketname, `<funktion>` der Funktionsname, bei einem Baustein also der deutsche (`aufgaben.teilaufgabe`). Heißt die Funktion wie ihr Paket, steht das Wort zweimal (`arbeitsblatt.arbeitsblatt`, `klassenarbeit.klassenarbeit`, `klausurboegen.klausurboegen`); eine Kurzform gibt es nicht, damit das Format eine einzige Regel hat. Der Halbgeviertstrich trennt Befund und Abhilfe. Die Abhilfe fehlt nie.

### 8.3 Die Meldungsarten (abschließend)

| Fall | Meldung |
|---|---|
| unbekannter Parameter | ``arbeitsblatt.arbeitsblatt: unbekannter Parameter `solutoins` – meintest du `solutions`?`` |
| unbekannt, kein naher Treffer | ``aufgaben.teilaufgabe: unbekannter Parameter `farbe` – erlaubt: `marker`, `workspace`, `label` `` |
| alter Name | ``arbeitsblatt.arbeitsblatt: `loesungen` heißt jetzt `solutions` `` |
| alter Wert | ``arbeitsblatt.arbeitsblatt: `solutions: "sofort"` heißt jetzt `"in-place"` `` |
| alter Wert, der zwei Optionen wird | ``arbeitsblatt.arbeitsblatt: `solutions: "seite"` heißt jetzt `solutions: "at-end", solutions-pagebreak: "before"` `` |
| alt und neu zugleich | ``arbeitsblatt.arbeitsblatt: `loesungen` (alt) und `solutions` (neu) zugleich – nur `solutions` schreiben`` |
| entfernt | ``klassenarbeit.klassenarbeit: `stufe` gibt es nicht mehr – der Notenschlüssel steht in `answer-sheets: (stage: "sek-1")` `` |
| falsches Aus | ``arbeitsblatt.arbeitsblatt: `solutions: false` – das Aus ist `none` `` |
| leerer Text | ``klassenarbeit.klassenarbeit: `subtitle: ""` – für „kein Untertitel" `none` schreiben oder weglassen`` |
| ungültiger Wert | ``aufgaben.set-options: `points: "task"` ist kein gültiger Wert – meintest du `"tasks"`? erlaubt: `none`, `"tasks"`, `"subtasks"`, `"all"` `` |
| falscher Typ | ``arbeitsblatt.minipage: `gutter` erwartet eine Länge, bekam `2` (int) – zum Beispiel `2mm` `` |
| Umlaut | ``arbeitsblatt.arbeitsblatt: `lösungen` heißt jetzt `solutions` `` |
| zweiter Weg | ``aufgaben.aufgabe: Titel als zweites Inhaltsargument – `aufgabe(title: [...])[...]` schreiben`` |
| alter Funktionsname | ``arbeitsblatt.lücke: `lücke` heißt jetzt `luecke` `` |
| deutscher Bausteinname als Wert | ``klausurboegen.klausurboegen: `pattern: "kariert"` ist kein gültiger Wert – meintest du `"squares"`? erlaubt: `"squares"`, `"lines"` `` |
| unzulässige Kombination | ``aufgaben.set-options: `solutions-pagebreak: "per-task"` wirkt nur mit `solutions: "at-end"` – eines von beiden ändern`` |

### 8.4 Pflicht zur Prüfung

- Jede öffentliche Funktion mit benannten Parametern prüft Namen, Typen und Werte über dieselbe Tabelle (`internal.check`, hervorgegangen aus `technik/compat.typ`). Das gilt auch für `set-options`, Varianten-Overrides, W6-Dictionaries, das Theme-Dictionary und jeden Sink.
- Tippfehlervorschlag: Levenshtein-Abstand höchstens `max(2, Länge / 3)`; gesucht wird in den erlaubten Namen und in den alten Namen der Compat-Tabelle. Bei Enum-Werten wird zusätzlich über `wortpaare.json` nachgeschlagen: Ein deutscher Bausteinname als Wert bekommt sein Parameterwort als Vorschlag.
- Umlaut-Faltung: Vor dem Nachschlagen werden `ä ö ü ß` zu `ae oe ue ss`. `lösungen` findet so den alten Namen `loesungen` und bekommt die „heißt jetzt"-Meldung.
- Die Prüfung läuft vor jeder Weitergabe an Typst oder ein Fremdpaket.
- Für jede Zeile der Compat-Tabelle und jede Meldungsart gibt es einen Test (`// fehler: <erwarteter Text>`).

---

## 9. Umgang mit alten Namen

### 9.1 Grundsatz

Bestandsdokumente pinnen ihre Version und brechen nicht; die alten Versionsordner bleiben. Wer ein Dokument auf die Zielversion hebt, benutzt den Codemod. Er stellt um, was in den Klammern steht (Parameter, Schlüssel, Werte), und die wenigen Funktionsnamen aus 9.3; die Bausteinaufrufe selbst bleiben stehen. Die rund 5100 Ersetzungen von `aufgabe` und `teilaufgabe` entfallen. Was der Codemod übersieht, meldet das Paket beim ersten Kompilieren mit „heißt jetzt". Typst hat keine Warnungen, deshalb gilt: **Ein alter Name wird nie still angenommen.**

### 9.2 Compat-Tabelle

Eine Datei `regeln.json` ist die einzige Quelle für Laufzeitprüfung (`internal.check`), Codemod und Lint. Je Funktion enthält sie:

| Feld | Inhalt | Wirkung zur Laufzeit |
|---|---|---|
| `renamed` | alter Parametername → neuer Name | Fehler „heißt jetzt" |
| `values` | je Parameter: alter Wert → neuer Wert oder neue Wertgruppe (mehrere Optionen) | Fehler „heißt jetzt" |
| `removed` | alter Name → Hinweistext | Fehler „gibt es nicht mehr – …" |
| `context` | Wertregeln, die vom Namen abhängen | nur Codemod |

Pflichteinträge mit Kontext (nicht durch reine Namensersetzung lösbar):

| alt | Regel |
|---|---|
| `custom-header: none` | Argument löschen (heute Standardkopf; `header: none` hieße „kein Kopf") |
| `custom-header: <inhalt>` | `header: <inhalt>` |
| `loesungen: "seite"`, `"seiten"`, `"reinquetschen"` | zwei Optionen nach Abschnitt 6 |
| `materialien: "seiten"` | Argument löschen (ist die Vorgabe) |
| `punkte: "keine-summe"` | `points: "all", points-total: false` |
| `punkte: (anzeige:, position:)` | `points`, `points-position` |
| `large:`, `number:` | bleiben, Wert bleibt |
| `stufe` im Kopf von klassenarbeit | entfernt, mit Hinweis auf `answer-sheets: (stage: …)` |
| `klausurboegen: (…)` im Kopf von klassenarbeit | `answer-sheets: (…)`; der Parameter trägt das Parameterwort, nicht den Bausteinnamen |
| `kariert(4, 12)` | `kariert(4, columns: 12)` |
| `scale: 1` (`klausurboegen`) | `grid-size: 0.5cm` (Faktor mal 0.5cm) |
| `sek1: true` | `stage: "sek-1"` |
| `""` bei `title`, `subtitle`, `date`, `teacher`, `student`, `method` | Argument löschen |
| `erwartungen: (show: false)` | `expectations: false` |
| `varianten: (name: (…))` | `variants: ("name",)` und `variant-overrides: (name: (…))` |

Umfang: alle Namen aus 0.3.x und 0.4.0, dazu die häufigen älteren (`header-font-size` 1063, `titel:` bei `aufgabe` 342, `stufe` 80, `table` 68, `klausurboegen-settings` 38, `ergebnisse`, `bewertung`, `bogen`).

Laufzeit der Tabelle: Zielversion und Folgelinie. Danach werden die Einträge gelöscht; ein alter Name ist dann ein gewöhnlicher unbekannter Parameter mit Tippfehlervorschlag.

### 9.3 Keine Aliase; alte Funktionsnamen

- **Es gibt keine Aliase.** Nicht für Parameter, Schlüssel und Werte, und nicht für Funktionen. Der frühere Block von zwölf Übergangsnamen ist gestrichen: Die deutschen Namen sind keine Übergangsnamen mehr, sondern die Namen (2.1a), und die englischen Zwillinge werden nie exportiert. Es entfallen die Befristung, `--input streng=1`, der Codemod-Schalter `--aliase` und der Test `aliase.typ`.
- **Englische Zwillinge bekommen keinen Stub.** `worksheet`, `exam`, `task`, `subtask`, `subtasks`, `solution`, `expectation`, `inline-solution`, `blank`, `squares`, `lines`, `answer-sheets` gab es in keiner veröffentlichten Version; wer sie schreibt, bekommt Typsts „unknown variable". Das Lint stellt sicher, dass keiner dieser Namen exportiert wird (L27).
- **Bausteine ändern ihren Namen nur, wo die Schreibweise 2.3 oder 2.4 verletzt.** Der alte Name ist ein abbrechender Stub, solange die Compat-Tabelle läuft:

| alt | neu | Hinweis |
|---|---|---|
| `lücke` | `luecke` | 119 Aufrufe im Bestand. Der Codemod benennt nur um, wenn das Dokument kein eigenes `#let luecke` und kein eigenes `#let lücke` hat (32 Aufrufe `#luecke(` im Bestand gehören zu dokumenteigenen Funktionen); jede Stelle steht im Bericht. |
| `klausurbögen` | `klausurboegen` | Funktionsname gleich Paketname. |
| `häufigkeitsanalyse` | `haeufigkeitsanalyse` | `häufigkeitsanalyse-alt` entfällt ohne Ersatz. |
| `lineare_regression`, `quadratische_regression`, `wurzel_regression`, `exponentielle_regression`, `potenz_regression`, `polynom_regression` | `lineare-regression`, `quadratische-regression`, `wurzel-regression`, `exponentielle-regression`, `potenz-regression`, `polynom-regression` | Unterstrich nach 2.4. |

- **Unverändert bleiben** alle übrigen Bausteine: `arbeitsblatt`, `arbeitsblatt-einzeln`, `klassenarbeit`, `aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung`, `lsg`, `kariert`, `liniert`, `graphen`, `steckbrief`, `kreisdiagramm`, `datensatz`, `messdaten`, `berechnung`, `messwerttabelle`, `schaltkreis`, `konstante`, `operatoren-liste`. Ihre Parameter ändern sich nach den Tabellen.
- **Alte Namen, die kein Baustein sind, werden englisch** und sind als abbrechende Stubs mit „heißt jetzt" definiert, solange die Compat-Tabelle läuft:

| alt | neu | Art |
|---|---|---|
| `tasks` (Alias von `teilaufgaben`, 0.2.x) | `teilaufgaben` | zweiter Name eines Bausteins, entfällt |
| `qrbox` | `qr-box` | Layout-Helfer |
| `print-pagebreak`, `non-print-pagebreak` | `conditional-pagebreak(print: true)`, `conditional-pagebreak(print: false)` | Layout-Helfer |
| `flex-feld`, `ist-flex-feld` | `flex-area`, `is-flex-area` | Layout-Helfer, Abfrage |
| `loesungsmodus` | `has-solutions` | Abfrage |
| `show-loesungen`, `show-offene-loesungen` | `show-solutions`, `show-solutions(select: "pending")` | Aktion |
| `show-materialien`, `show-erwartungen`, `show-bewertung` | `show-materials`, `show-expectations`, `show-points-table` | Aktion |
| `reset-aufgaben` | `reset-tasks` | Aktion |
| `format-punkte` | `format-points` | Umwandlung |
| `iaword-neu` | `reset-iaword` | Aktion |
| `pk` | `constants` | Wert; kein Stub möglich, nur `regeln.json` unter `removed` |
| `amperemeter`, `simple-source` | `ammeter`, `source` | Fremdvokabular von zap |
| `bin2dec`, `dec2bin`, `hex2dec`, `dec2hex` | `bin-to-dec`, `dec-to-bin`, `hex-to-dec`, `dec-to-hex` | Umwandlung |
| `rand`, `randint` | `random-number`, `random-integer` | Helfer |

- Ein Stub steht in einem eigenen Block `src/removed.typ`, den das Lint von L1 und L27 ausnimmt (`lücke` mit Umlaut, `lineare_regression` mit Unterstrich, `show-loesungen` als Mischname). Er nimmt keine Argumente an und bricht mit ``<paket>.<alt>: `<alt>` heißt jetzt `<neu>` `` ab.
- Doku, Vorlagen (`ab.typ`, `ka.typ`), Tests und Beispiele schreiben nur die Namen der Zielversion.

### 9.4 Werkzeuge vor dem ersten Codemod-Lauf

1. klausurboegen 0.0.4 und 0.0.5 zusammenführen; Pins heben (mathematik → aufgaben, klausurboegen → patterns, arbeitsblatt → energy-sketch).
2. AST-Werkzeug auf `typst-syntax` für Dictionary-Schlüssel, Variantennamen und `set-options`; Regex nur für Kopfzeilen mit Literalwerten.
3. Tests mit parametrisierter Version; Seitenzahl-Vergleich vorher und nachher an 20 bis 30 echten Dokumenten, weil der Textvergleich Layout nicht sieht.
4. Bericht über Stellen, die kein Codemod findet (Spread `..opts`, dynamische Werte, `sys.inputs`-Weichen, eigene Wrapper).

---

## 10. Lint-Regeln

Prüfbar durch `sig.py --lint` auf dem Signatur-Snapshot (Namen, Vorgaben, Typkommentare), den Wortlisten (`words-en.txt`, `names.txt`, `bausteine-de.txt`, `wortpaare.json`) und der exportierten Namensmenge. Jede Regel liefert Datei, Zeile, Name und Regelnummer.

| Nr. | Regel | Prüfung |
|---|---|---|
| L1 | Zeichenvorrat | Jeder öffentliche Name und Enum-Wert passt auf `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`; Ausnahmen nur aus `names.txt` und Nummerierungsmuster. |
| L2 | Wortliste | Jedes Segment steht in `words-en.txt` oder `names.txt`. Ausgenommen sind allein Funktionsnamen, die als Ganzes in `bausteine-de.txt` stehen. |
| L3 | Glossar | Kein Name ist ein verbotenes Synonym aus Abschnitt 3 (Spalte 5, maschinenlesbar als `glossar.json`). Einträge „als Funktion" (`verboten-als-funktion`) werden nur gegen exportierte Funktionsnamen geprüft, die übrigen gegen alle Namen und Segmente. |
| L4 | Verbotene Affixe | Präfixe `no- non- not- hide- without- disable- custom- my-`; Suffixe `-only -alt -old -neu -new -2 -color -state -dict -list -array -flag -str`; Segment `show` als Dictionary-Schlüssel. |
| L5 | Abkürzungen | Kein Segment mit weniger als vier Buchstaben außer denen aus 2.2 und Wörtern der Wortliste. |
| L6 | Ein Name, ein Typ | Derselbe Parametername hat in allen Funktionen aller Pakete denselben Grundtyp (ohne `auto`, `none`). |
| L7 | Zulässige Form | Der Typkommentar jedes Parameters entspricht genau einer Form W1 bis W9. Insbesondere: keine Mischung `bool` mit `str` außer W6; kein `str` mit Dictionary außer W8. |
| L8 | Das eine Aus | W1 und W6 haben nie die Vorgabe `none`; W2, W4 nie `false`; keine Vorgabe `""`, `"none"`, `"false"`, `"keine"`. |
| L9 | Numerus | Vorgabe `()` oder `(:)` verlangt Plural; W1 verlangt keinen Plural außer bei Optionen aus Abschnitt 6. |
| L10 | Abstand | Innerhalb einer Signatur und innerhalb einer Werteliste haben zwei Namen Levenshtein-Abstand von mindestens 2. |
| L11 | Bestimmungswort | Erstes Segment eines Kompositums ist kein Plural, außer es ist ein Parameter derselben Signatur. |
| L12 | Kollision | Kein exportierter Name steht in `dir(std)`, in den Exporten von cetz, cetz-plot, fontawesome, colorful-boxes, gentle-clues, außer er steht in `fremdnamen.txt` oder in `kollisionen-erlaubt.txt` (mit Begründung; Startbestand: `question`, `info`, `tip`, `memo` und die übrigen Kastennamen gegenüber gentle-clues; `task` steht nicht mehr darin, weil es keine eigene Funktion `task` gibt). |
| L13 | Builtin im Rumpf | Für jeden Parameternamen, der in `dir(std)` steht, kommt der bare Name im Paketquelltext nicht als Aufruf vor; nur `std.<name>(`. |
| L14 | Parameter gegen eigene Funktion | Kein Parameter und kein Schlüssel heißt wie eine exportierte Funktion desselben Pakets. Für Bausteine folgt das aus L27. |
| L15 | Reihenfolge | `body` ist der letzte Parameter; höchstens ein weiterer Positionsparameter; kein Positionsparameter mit Vorgabe vom Typ bool, none oder Dictionary. |
| L16 | Sinks | Ein Sink heißt `deprecated`, `cells`, `items` oder `args`; im Rumpf wird kein Sink mit `..` an eine Fremdfunktion weitergegeben. |
| L17 | Options-Schema | Die Schlüssel des Options-States, die Parameter von `set-options` und die Schema-Parameter von `arbeitsblatt`, `arbeitsblatt-einzeln`, `klassenarbeit` sind dieselbe Menge mit denselben Typen. |
| L18 | Theme | Jeder Schlüssel des Theme-Dictionary ist ein Kopfparameter oder ein Hook; jeder Schlüssel ist englisch (L2); jeder Hook heißt wie ein Kopfparameter, wie das Parameterwort eines Bausteins (`wortpaare.json`) oder ist ein Kompositum daraus (`task-marker`, `solution-heading`) und hat nur Parameternamen, die der gezeichnete Baustein oder Kopfparameter auch hat. |
| L19 | Exporte | Kein `import …: *` und kein `#let _name` im Paketquelltext; die exportierte Menge ist genau: eigene Namen (Bausteine und englische Namen), `internal`, `fremdnamen.txt`, die Stubs aus `removed.typ`. |
| L20 | State-Schlüssel | Jeder Schlüssel von `state(` und `counter(` passt auf `^schule/<paket>/[a-z-]+@[0-9]+$` und steht in `internal.typ`. |
| L21 | Fehlermechanik | Kein `panic(` und kein `assert(` außerhalb von `internal.fail`; jede Meldung beginnt mit `<paket>.<funktion>: ` und enthält ` – `. |
| L22 | Einheiten | Parameter mit Längen-Endung (5.5) haben keine Vorgabe vom Typ int oder float; `rows`, `columns`, `count`, `steps`, `digits` keine Länge. |
| L23 | Bausteinliste | Abgleich in beide Richtungen: (a) Jeder Name aus `bausteine-de.txt` wird von genau einem Paket als Funktion definiert und exportiert (Durchreichen durch arbeitsblatt und klassenarbeit zählt nicht als zweite Definition). (b) Jede exportierte Funktion, die nicht in `bausteine-de.txt` steht, besteht L2, ist also englisch. (c) Kein Name der Liste ist an eine andere exportierte Funktion gebunden (`#let x = aufgabe` im Exportblock ist ein Alias und verboten). (d) Jeder Name der Liste hat genau eine Zeile in `wortpaare.json`. |
| L24 | Compat-Deckung | Jeder Name, der im Snapshot der Vorversion steht und im neuen fehlt, steht in `regeln.json` unter `renamed` oder `removed`; für jeden Eintrag existiert ein Fehlertest. |
| L25 | Vorgaben unverändert | Jeder umbenannte Parameter hat dieselbe Vorgabe wie sein Vorgänger, außer `regeln.json` nennt die Änderung ausdrücklich (`"" → none`, `"angela" → auto`). |
| L26 | Docstring | Jede öffentliche Funktion hat einen Docstring, dessen Parameterliste mit der Signatur übereinstimmt (tidy liest ihn; Beispiele werden von `tests/run.sh` kompiliert). |
| L27 | Sprachtrennung | (a) Kein Parameter, Schlüssel, Enum-Wert, Hook und kein englischer Funktionsname enthält ein Segment eines Namens aus `bausteine-de.txt` (`show-loesungen`, `aufgabe-number`, `pattern: "kariert"` schlagen an); dasselbe gilt für den `<name>`-Teil von State-Schlüsseln und Labels. Nicht geprüft werden der Paketname in State-Schlüsseln und Labels (7.3: `schule/operatoren/…`), Paketnamen überhaupt und die eingefrorenen Außenschnittstellen aus 2.1 (`-loesung`, `-klausurboegen`). (b) Kein Wort steht zugleich in `words-en.txt` und als Segment in `bausteine-de.txt`. (c) Kein exportierter Funktionsname ist ein englischer Zwilling: die Liste `zwillinge.txt` (`worksheet`, `worksheet-single`, `exam`, `task`, `subtask`, `subtasks`, `solution`, `expectation`, `inline-solution`, `blank`, `squares`, `lines`, `answer-sheets`, `graph`, `function-profile`, `pie-chart`, `dataset`, `measurements`, `derived`, `measurement-table`, `linear-regression`, `quadratic-regression`, `root-regression`, `exponential-regression`, `power-regression`, `polynomial-regression`, `circuit`, `constant`, `frequency-analysis`, `operator-overview`) hat mit den Exporten keine Schnittmenge. (d) Meint ein Segment einen Baustein, ist es dessen Parameterwort aus `wortpaare.json`; andere Übersetzungen (`exercise`, `gap`, `grid` für kariert) stehen im Glossar als verboten. Ausgenommen ist `removed.typ`. |

---

## 11. Offene Entscheidungen für den Autor

**Entschieden am 2026-11-15 und hier herausgenommen:**

- Frühere Nr. 1, „Übergangsnamen befristet oder deutsche Bausteine auf Dauer": entschieden für die Alternative. Die Bausteine heißen auf Dauer nur deutsch, ohne englischen Zwilling; alles andere bleibt englisch (Leitregel 1, 2.1, 2.1a, 9.3). Die dort verlangte Sonderregel für `pattern: "squares"` neben `kariert(4)` steht in 5.3.
- Frühere Nr. 3, „`task` oder `exercise`, und die übersetzten Fachwörter": erledigt. Es gibt keine Funktion `task` und keine Kollision mit gentle-clues mehr. Als Parameterwort bleibt `task` (2.1b); `exercise` ist im Glossar verboten. Die Fachwörter `expectation`, `answer-sheets`, `proposal`, `correction-margin` stehen nur noch in den Klammern.

Die übrigen Entscheidungen, neu nummeriert (in Klammern die frühere Nummer, auf die ältere Unterlagen verweisen):

1. **Versionsnummer** (früher 2). Empfehlung: 0.4.1 in allen zwölf Paketen (in allen frei; 0.4.0 bleibt als eingefrorene Themes-Baustelle liegen; jedes Dokument pinnt). Alternative: 0.5.0, weil 0.4.0 → 0.4.1 für die 58 Dokumente auf 0.4.0 ein Namensbruch innerhalb einer Minor-Linie ist. Der Bruch ist kleiner geworden: Er betrifft nur noch Parameter, Werte und die Namen aus 9.3, nicht mehr die Bausteinaufrufe. Die Regeln sind von der Nummer unabhängig.
2. **Durchgereichte Fremdnamen** (früher 4). Empfehlung: die acht Namen aus 7.1 (`canvas`, `draw`, `plot`, `qty`, `num`, `unit`, `stickybox`, `fa-icon`). Alternative: gar keine; jedes Dokument importiert cetz und colorful-boxes selbst. Das ist sauberer, kostet aber beim Anheben in mehreren hundert Dokumenten eine Importzeile. Der gentle-clues-Kasten `task` könnte jetzt kollisionsfrei aufgenommen werden; die Empfehlung lässt ihn weg.
3. **Härte gegen zweite Wege** (früher 5). Empfehlung: `aufgabe[Titel][Rumpf]`, `erwartung(points: 2)`, `""` als leerer Text und `kariert(4, 12)` sind Fehler mit Abhilfe; der Codemod schreibt sie um. Alternative: `aufgabe[Titel][Rumpf]` bleibt erlaubt (Anteil an den 273 klammerlosen Aufrufen ist nicht gezählt) und `""` wird wie `none` angenommen; dann bekommen 4.4 Nr. 4 und 5.2 je eine benannte Ausnahme.
4. **klausurboegen: Was aus dem Ast 0.0.4 überlebt** (früher 6). Empfehlung: `bogen-seiten` und `klausurbogen-arbeit` gehen nach `internal`; `namen` wird `name-fields: true`; `vordruck: "werte"` wird der Schalter `overprint: true` zugeschlagen, falls die Wirkung dieselbe ist **[prüfen]**. Alternative: beide Äste als getrennte Bausteine `klausurboegen` und `bogen-seiten` führen; `bogen-seiten` käme dann in `bausteine-de.txt`. Die Zusammenführung muss vor der Umbenennung geschehen (9.4).

Folgearbeit aus der Entscheidung (kein offener Punkt, aber noch nicht getan): Die vier Umbenennungstabellen, ihre JSON-Anhänge, `prototyp-regeln.json` und `architektur-release.md` nennen noch die englischen Bausteinnamen und die Übergangsnamen und werden nach diesem Dokument neu geschrieben.

---

## Anhang A: Verbindliche Signaturen des Kerns

Typkommentare nennen die Form aus 5.1. `..deprecated` ist der Abfang nach 9.2 und nimmt nichts an. Funktionsnamen aus `bausteine-de.txt` sind deutsch, alle Parameter englisch.

### A.0 Beispiel in der endgültigen Schreibweise

```typ
#import "@schule/arbeitsblatt:0.4.1": *

#show: arbeitsblatt.with(
  title: [Lineare Funktionen],
  class: "MA-08",
  solutions: "at-end",
  points: "all",
  subtask-numbering: "a)",
)

#aufgabe(title: [Steigung bestimmen], method: "pair")[
  Gegeben ist die Gerade durch $A(0|1)$ und $B(2|5)$.

  #teilaufgabe(workspace: kariert(6))[
    Berechne die Steigung $m$.
    #erwartung(2)[Steigungsdreieck oder Formel, $m = 2$]
    #loesung[$m = (5 - 1)/(2 - 0) = 2$]
  ]

  #teilaufgabe(workspace: liniert(2))[
    Die Gerade schneidet die $y$-Achse bei #luecke[1]. Begründe. #lsg[$b = 1$]
  ]
]

#show-points-table()
```

Deutsch sind darin nur die Funktionsnamen vor der Klammer und der Text; in den Klammern steht kein deutsches Wort.

### A.1 `arbeitsblatt`, `arbeitsblatt-einzeln` (arbeitsblatt)

```typ
#let arbeitsblatt(
  // Kopf
  title: none,                  // W4 str | content
  class: none,                  // W4 str | content; "MA-05" bestimmt die Fachfarbe
  header: auto,                 // W5 content; none = kein Kopf
  copyright-url: none,          // W4 str
  // Seite
  paper: "a4",                  // W9
  landscape: false,             // W1
  print: false,                 // W1
  duplex: true,                 // W1
  two-up: false,                // W1
  page-settings: (:),           // W9, geht an set page; auch header-ascent
  // Gestaltung
  theme: auto,                  // W8 str | dictionary | function
  accent: auto,                 // W5 color
  font: auto,                   // W5 str | array
  math-font: auto,              // W5
  font-size: auto,              // W5 length
  title-font-size: auto,        // W5
  figure-font-size: auto,       // W5
  // Options-Schema (Abschnitt 6)
  solutions: none,
  solutions-pagebreak: none,
  materials: "after-task",
  materials-pagebreak: "before",
  points: none,
  points-total: true,
  points-position: "end",
  points-format: auto,
  workspaces: true,
  shortcodes: "subtasks",
  subtask-numbering: "a)",
  // Varianten und Ausgabe
  variants: auto,               // W5 array aus str
  variant-overrides: (:),       // W3 dictionary: Name -> Optionen; Sonderschlüssel path
  preview-variant: auto,        // W5 str; "all" zeigt alle
  filename: none,               // W4 str
  // Metadaten (werden deutsch nach <ab-meta> geschrieben)
  subject: none,
  topic: none,
  years: (),
  stage: none,                  // W2 "sek-1" | "sek-2"
  level: none,                  // W2 "introduction" | "consolidation" | "ea" | "ga"
  kind: none,                   // W2 "worksheet" | "practice" | "stations" | "exam"
  keywords: (),
  curriculum: (),
  revision: none,               // W4 str "JJJJ-MM-TT"
  ..deprecated,
  body,
) = { }
```

`arbeitsblatt-einzeln` hat dieselben Parameter ohne `variants`, `variant-overrides`, `preview-variant`, `filename`, dafür `scope: none`. Beide Signaturen werden aus einer Parametertabelle erzeugt.

### A.2 `klassenarbeit` (klassenarbeit)

```typ
#let klassenarbeit(
  title: none,
  subtitle: none,
  class: none,
  date: none,
  teacher: none,
  student: none,
  logo: auto,                   // W8 content | str; auto = Schullogo, none = keins
  name-field: "Name",           // W4 str | content
  name-repeat: false,           // W1
  info-table: none,             // W4 array aus Paaren
  page-numbering: "restart",    // W2 "restart" | "continuous"
  expectations: true,           // W6
  answer-sheets: false,         // W6; Schlüssel = Parameter von klausurboegen
  // Options-Schema mit der abweichenden Vorgabe points
  solutions: none,
  solutions-pagebreak: none,
  materials: "after-task",
  materials-pagebreak: "before",
  points: "tasks",
  points-total: true,
  points-position: "end",
  points-format: auto,
  workspaces: true,
  shortcodes: "subtasks",
  subtask-numbering: "a)",
  variants: auto,               // W5 array aus "print", "solutions", "answer-sheets"
  preview-variant: auto,
  filename: none,
  // Seite und Gestaltung wie arbeitsblatt-einzeln, ohne print, header, scope
  paper: "a4", landscape: false, duplex: true, page-settings: (:),
  theme: auto, accent: auto, font: auto, math-font: auto,
  font-size: auto, title-font-size: auto, figure-font-size: auto,
  ..deprecated,
  body,
) = { }
```

### A.3 `aufgabe`, `teilaufgabe`, `teilaufgaben` (aufgaben)

```typ
#let aufgabe(
  title: none,                  // W4 content
  method: none,                 // W2 "individual" | "pair" | "group"
  icons: (),
  large: true,
  number: true,
  workspace: none,              // W4 content, zum Beispiel kariert(4)
  label: none,                  // W4 label | str
  ..deprecated,
  body,
) = { }

#let teilaufgabe(
  marker: none,                 // W4 content; ersetzt a), b)
  workspace: none,
  label: none,
  ..deprecated,
  body,
) = { }

#let teilaufgaben(
  items: (),                    // array aus content
  item-solutions: (),           // array aus content, in der Reihenfolge der items
  columns: auto,                // W9
  numbering: "a)",              // W9
  gutter: 1.25em,
  align: left,                  // W9
  inset: 0pt,                   // W9
  ..deprecated,
) = { }
```

### A.4 `loesung`, `erwartung`, `material`

```typ
#let loesung(body) = { }
#let erwartung(..args) = { }          // [body] oder (points, [body]); points: int | float
#let material(caption: none, label: none, body) = { }
```

### A.5 Aktionen und Abfragen (aufgaben)

Rein englisch (4.1): Verb und Parameterwort, kein deutscher Baustein als Wortteil.

```typ
#let set-options(
  solutions: auto, solutions-pagebreak: auto, materials: auto, materials-pagebreak: auto,
  points: auto, points-total: auto, points-position: auto, points-format: auto,
  workspaces: auto, shortcodes: auto, subtask-numbering: auto,   // auto = unverändert
  ..deprecated,
) = { }
#let reset-tasks() = { }

#let show-solutions(
  select: "all",                // W2 "all" | "current" | "pending"
  subtask-number: none,         // W4 int
  inline: false,
) = { }
#let show-materials(select: "all") = { }          // "all" | "current"
#let show-expectations(
  blocks: auto,                 // W5 array aus str; none = ungeteilt, auto = alle Blöcke
  grouped: false,
  achieved: false,
) = { }
#let show-points-table(
  possible: "shown",            // W2 "shown" | "blank"
  compact: false,
  subtotals: false,
) = { }

#let get-points(task-number, subtask-number: none, index: none) = { }
#let format-points(points, target: "task") = { }  // target: "task" | "subtask"
#let has-solutions() = { }
#let is-print() = { }
```

### A.6 `klausurboegen` (klausurboegen)

```typ
#let klausurboegen(
  title: none,
  subtitle: none,
  teacher: none,
  class: none,
  date: none,
  logo: auto,
  results: (),                  // CSV-Zeilen
  overprint: false,             // nur Tabelle und Note zum Überdrucken
  stage: "sek-2",               // bestimmt den Notenschlüssel
  continuation: false,          // Folgebogen ohne Ergebnisbereich
  points-table: true,
  proposal: none,
  subtask-numbering: "a)",
  pattern: "squares",           // W2 "squares" | "lines"; Enum-Wert englisch (5.3), gemeint sind kariert und liniert
  grid-size: 0.5cm,
  line-height: 8mm,
  correction-margin: 5cm,
  correction-margin-side: "outside",   // W2 "inside" | "outside"
  correction-margin-stroke: 1pt + rgb("FF0613"),
  correction-margin-blank: true,       // W1 weißer Rand ohne Muster
  offset: (dx: 0cm, dy: 0cm),
  ..deprecated,
) = { }
```

### A.7 `kariert`, `liniert`, Flex-Helfer (patterns)

```typ
#let kariert(
  rows,                         // int | fraction, führendes Hauptargument
  columns: auto,                // W5 int
  height: auto,                 // W5 length; statt rows, beides zugleich ist ein Fehler
  grid-size: 0.5cm,
  items: (),
  item-rows: 2,
  annotations: (),
  overlay: none,
  stroke: (paint: rgb("#AAAAAA").lighten(10%), thickness: 0.5pt),
  fill: white,
  ..deprecated,
) = { }

#let liniert(
  rows,
  width: auto,
  line-height: 1cm,
  items: (),
  item-rows: 1,
  stroke: (paint: black.lighten(50%), thickness: 0.5pt),
  ..deprecated,
) = { }

#let flex-area(height, body) = { }     // height: fraction; body: length => content
#let is-flex-area(body) = { }
```

### A.8 `luecke`, `lsg`, `workspace`, `minipage`

```typ
#let luecke(tight: false, body) = { }
#let lsg(reserve: true, fallback: none, body) = { }
#let workspace(body) = { }
#let minipage(
  columns: auto,                // W9 auto | int | array
  align: horizon,               // W9
  gutter: 5mm,
  inset: 0pt,                   // W9
  ..cells,                      // nur positional
) = { }
```

### A.9 Seitenumbruch

```typ
#let conditional-pagebreak(
  print: auto,                  // W5 bool: true = nur Druck, false = nur digital
  solutions-visible: auto,      // W5 bool: true = nur wenn Lösungen sichtbar sind
  weak: false,                  // W9
  to: none,                     // W9
) = { }
```

Ersetzt `print-pagebreak` (`print: true`) und `non-print-pagebreak` (`print: false`); `loesungen-only: true` wird `solutions-visible: true` **[prüfen]**.

### A.10 QR und Links

```typ
#let qr-code(url, width: auto, quiet-zone: true, fill: black, background-fill: none) = { }
#let qr-box(url, width: 3cm, rotation: auto, body) = { }
#let icon-link(url, icon: auto, fill: blue, body) = { }
```

### A.11 Kästen

```typ
#let info(
  title: auto,                  // W5 content; none = ohne Titelzeile
  accent: auto,
  breakable: false,
  width: auto,
  ..deprecated,
  body,
) = { }
```

Alle 15 Kästen haben genau diese Signatur. Der Hook `callout` bekommt zusätzlich `kind` mit dem Funktionsnamen als Wert.

### A.12 Theme-Dictionary

```typ
#let theme-keys = (
  name: "klar",
  font: auto, math-font: auto, font-size: auto, title-font-size: auto,
  margin: (top: 0cm, bottom: 0cm, inside: 0cm, outside: 0cm),
  header-top: 0cm,
  header-ascent: 0cm,
  footer-descent: 0cm,
  task-marker-width: 0cm,
  header: (title: none, class: none, copyright-url: none, font-size: auto) => { },
  footer: (duplex: true) => { },
  background: (print: true, margin: (:), header-top: 0cm) => { },
  task: (marker: none, title: none, icons: (), points: none, large: true) => { },
  task-marker: task-number => { },
  subtask: marker => { },
  solution: (title: none, body) => { },
  solution-heading: title => { },
  material-heading: title => { },
  callout: (kind: "info", title: none, accent: auto, breakable: false, width: auto, body) => { },
  setup: body => { },
)
```

Alle Schlüssel und Hooks des Theme-Dictionary sind englisch, weil sie Schlüssel sind (Leitregel 1). Die Hooks `task`, `task-marker`, `subtask`, `solution`, `solution-heading` tragen das Parameterwort des Bausteins, den sie zeichnen (`aufgabe`, `teilaufgabe`, `loesung`; 2.1b, 4.4 Nr. 7); deutsche Hook-Namen (`aufgabe:`, `loesung:`) gibt es nicht und sie schlagen in L27 an.

Eine Theme-Funktion hat die Form `(accent: auto, class: none) => dictionary`. Unbekannte Schlüssel sind ein Fehler. Öffentliche Namen aus `themes.typ`: `themes`, `subject-accents` (Dictionary Fachkürzel → Farbe), `subject-names`, `callout-style`; die Zerlegung des Klassen-Strings liegt in `internal`.

---

## Anhang B: Fachpakete (gleiche Regeln)

### B.1 Entscheidung je Funktionsname

Maßstab ist der Bausteintest aus 2.1 (B1 Aufrufform, B2 Schulbegriff, B3 kein Ausschluss). „deutsch" heißt: Eintrag in `bausteine-de.txt`.

| Paket | heute | Zielname | Sprache | Begründung |
|---|---|---|---|---|
| mathematik | `graphen` | `graphen` | deutsch | Setzt Funktionsgraphen ins Koordinatensystem; „Graph" ist Schulbegriff; 32 Aufrufe bleiben. |
| mathematik | `steckbrief` | `steckbrief` | deutsch | „Steckbriefaufgabe" ist der Fachbegriff für das Bestimmen einer Funktion aus Bedingungen. |
| mathematik | `kreisdiagramm` | `kreisdiagramm` | deutsch | Schulbegriff der Stochastik, setzt das Diagramm. |
| mathematik | `geogebra-cell`, `geogebra-algebra`, `geogebra-style` | unverändert | englisch | Produktname plus englisches Wort; bildet die GeoGebra-Oberfläche nach, kein Schulbegriff (B3 Fremdname). |
| mathematik | `teilaufgaben`, `tasks` (eigene Kopien) | entfallen | – | Der Baustein `teilaufgaben` kommt aus aufgaben; `tasks` ist ein Stub (9.3). |
| physik | `datensatz` | `datensatz` | deutsch | Datenbaustein nach B1: liefert die Messreihe, die `messwerttabelle` und `graphen` setzen; Parameterwort `dataset`. |
| physik | `messdaten` | `messdaten` | deutsch | Leere Messreihe zum Ausfüllen; gleiche Familie wie `datensatz`. |
| physik | `berechnung` | `berechnung` | deutsch | Berechnete Spalte einer Messwerttabelle; das englische `derived` war kein Substantiv und kein Schulwort. |
| physik | `messwerttabelle` | `messwerttabelle` | deutsch | Schulbegriff, setzt die Tabelle; 122 Aufrufe bleiben. |
| physik | `lineare_regression`, `quadratische_regression`, `wurzel_regression`, `exponentielle_regression`, `potenz_regression`, `polynom_regression` | `lineare-regression`, `quadratische-regression`, `wurzel-regression`, `exponentielle-regression`, `potenz-regression`, `polynom-regression` | deutsch | Schulbegriff der Auswertung; gehören zur Familie `datensatz`. Der Unterstrich muss nach 2.4 ohnehin weg, die Sprache bleibt. |
| physik | `schaltkreis` | `schaltkreis` | deutsch | Schulbegriff, setzt die Schaltskizze. Dass dahinter `zap.circuit` steht, ist Umsetzung. |
| physik | `source`, `lamp`, `multimeter`, `voltmeter`, `motor`, `generator`; `amperemeter` → `ammeter`; `simple-source` → `source` | englisch | englisch | Zeichenbefehle innerhalb von `schaltkreis` neben `zap.wire` und `zap.node`: Fremdvokabular von zap wie `draw.line` in einem `canvas` (B3). |
| physik | `konstante` | `konstante` | deutsch | Datenbaustein wie `datensatz`: legt eine Naturkonstante mit Wert und Einheit an. |
| physik | `pk` | `constants` | englisch | Ein Wert, kein Aufruf (B1 nicht erfüllt); exportierte Konstanten sind englisch wie `themes` und `default-seed`. Parameterwort zu `konstante`. |
| informatik | `häufigkeitsanalyse` | `haeufigkeitsanalyse` | deutsch | Schulbegriff der Kryptologie, setzt das Diagramm; nur die Umlaut-Umschrift ändert sich. `häufigkeitsanalyse-alt` entfällt. |
| informatik | `bin2dec`, `dec2bin`, `hex2dec`, `dec2hex` | `bin-to-dec`, `dec-to-bin`, `hex-to-dec`, `dec-to-hex` | englisch | Umwandlungen (B3); `bin`, `dec`, `hex` sind internationale Kürzel. |
| informatik | `caesar`, `vigenere`, `atbash`, `rot13` | unverändert | Eigenname | Namen der Verfahren, in `names.txt`. |
| informatik | – | `caesar-table` | englisch | Eigenname plus englisches Wort, gebaut wie `ascii-table`; neu, kein Bestand. |
| informatik | `ascii-table`, `text-to-blocks` | unverändert | englisch | Technikhelfer und Umwandlung, heute schon englisch. |
| operatoren | `operator` | `operator` | sprachgleich | Deutsch und englisch dasselbe Wort; läuft über `words-en.txt`. |
| operatoren | `operatoren-liste` | `operatoren-liste` | deutsch | „Operatorenliste" ist der Begriff der Fachanforderungen; Substantiv ohne Verb-Präfix; der frühere Zielname `operator-overview` entfällt. |
| insert-a-word | `insert-a-word`, `iaword` | unverändert | Eigenname | Funktionsname gleich Paketname bzw. dessen Kürzel (`names.txt`). |
| insert-a-word | `iaword-neu` | `reset-iaword` | englisch | Aktion (B3). |
| random | `rand`, `randint`, `shuffle`, `default_seed` | `random-number`, `random-integer`, `shuffle`, `default-seed` | englisch | Technikhelfer, kein Schulbegriff. |
| energy-sketch | `energy-sketch` | unverändert | Eigenname | Funktionsname gleich Paketname. |
| patterns | `kariert`, `liniert` | unverändert | deutsch | Kernbausteine (2.1a). |
| patterns | `flex-feld`, `ist-flex-feld` | `flex-area`, `is-flex-area` | englisch | Layout-Helfer für Muster- und Theme-Autoren und eine Abfrage mit `is-` (B3); kein Dokument benennt damit ein Schulding. |

### B.2 Parameter und Werte (unverändert englisch)

| Paket | alt → neu |
|---|---|
| mathematik | in `graphen`: `datensätze:` → `datasets:`; `legende:` → `legend:`; `beschriftung:` → `caption:` oder `labels:` je nach Sache; `größe:` → `size:`. In `steckbrief` und `kreisdiagramm` nach `tabelle-fachpakete.md`. |
| physik | in `datensatz`, `messdaten`, `berechnung`, `messwerttabelle`, den Regressionen und `konstante`: `einheit:` → `unit:`; `einheiten:` → `units:`; `precision:`, `round:`, `nachkommastellen:` → `digits:`; `grad` → `degree:`; `x_param` → `x`; `kopfzeile:` → `header:`; `anzahl-messwerte`, `amount:` → `count:`; Helfer nach `internal` |
| informatik | Parameter `zahl`, `hex`, `num` → `value` (positional); alle Chiffren in derselben Aufrufform `chiffre(text, key: …)` |
| operatoren | `operatoren-liste(fach:, language:, operator-text-bold:)` → `operatoren-liste(subject:, language:, bold:)`; `operator(name, text:, bold:)` → `operator(name, caption: none, bold: auto)`; State `"schule/operatoren/used@1"` |
| insert-a-word | `hide-words: false` → `word-bank: true`; `item-spacing` → `spacing`; `show-solution` entfällt (folgt `has-solutions()`) |
| random | `a`, `m`, `lcg`, `step_seed`, `fisher_yates_shuffle` nach `internal` |
| energy-sketch | `energy-name` → `labels`; `hide-letters: false` → `labeled: true` |
| patterns | siehe A.7; `klausurboegen` benutzt `liniert` und `kariert` statt eines Nachbaus |

Tote Pakete (`options`, `typopst`, `messwerttabellen`, `flashcards`, `gutachten`) bekommen keine Zielversion.

---

## Anhang C: Nachweis zu den Beanstandungen der Jury am Sieger

| Beanstandung | Behebung |
|---|---|
| `subject-color`, `subject-colors`, `operator-list` verletzen „kein Typ im Namen" | `subject-accents`; L4. `operator-list` entfällt samt Beanstandung: Der Baustein behält seinen deutschen Namen `operatoren-liste` (Anhang B); L4 gilt für englische Namen |
| Kästen nicht ausbuchstabiert, `accent-color`, `headless` | A.11: gemeinsame Signatur, `accent`, `title: none` |
| Plural als Bestimmungswort (`solutions-heading`, `materials-heading`) | `solution-heading`, `material-heading`; Geschwister-Ausnahme in 4.2 und L11 |
| Wortliste deckt die eigenen Signaturen nicht; `rand` verboten und benutzt | Liste 2.2 vollständig für alle Namen dieses Dokuments; Negativliste gestrichen; `rand` → `random-number` |
| Aliase verdoppeln zwölf Namen auf Dauer | entschieden am 2026-11-15: Es gibt je Baustein nur den deutschen Namen, keinen Zwilling und keinen Aliasblock (2.1a, 9.3, L23, L27) |
| „kein String oder Dictionary" verletzt durch `variants`, `theme`, `columns` | Formen W1 bis W9 abschließend; `variants` (Array) und `variant-overrides` getrennt; `theme` ist W8; `columns` ist W9 |
| Titel, Punkte, Zeilen und Spalten auf zwei Wegen | 4.4 Nr. 4 |
| `number` mit zwei Typen | `number` (bool), `task-number` (int); Hook `task` bekommt `marker` |
| `grades` doppelt belegt | `years` für Jahrgänge, `grade` für Noten |
| `solutions` dreifach belegt | `solutions` nur Auswahl; `item-solutions`; `solutions-visible` |
| `exam` dreifach belegt | `exam` ist nur noch Enum-Wert (`kind: "exam"`); die Funktion heißt `klassenarbeit`; alter Parameter `exam` steht in der Compat-Tabelle |
| Theme und Kopf benennen dasselbe verschieden; `margin` und `margins` | 5.4 und A.12: gleiche Schlüssel, nur `margin` |
| `fill` und `background` überschneiden sich | Glossar 27 bis 29: `fill`, `background-fill`, Hook `background` |
| Vorgabe `points` von klassenarbeit geht verloren | Abschnitt 6, Spalte „Vorgabe klassenarbeit"; A.2 deklariert alle Schema-Optionen |
| `theme: none` für „Standard" | `theme: auto` |
| State-Schlüssel nennt ein Paket `tasks` | 7.3: echter Paketname |
| `<ab-meta>`, `vorschau=alle`, Dateinamen ungelöst | 2.1: eingefrorene Außenschnittstellen, deutsch |
| Builtin-Überdeckung ungeregelt | 4.5, L12 bis L14 |
| `parse-class` mit Verb außerhalb der Liste | nach `internal` verschoben |
| `points-format` als unbegründete Ausnahme | Form W7 (wie Typsts `inset`) |
| Bestandsschutz macht die Regel ermessensabhängig | 1.2: Bestandsnamen sind Glossarzeilen, für neue Namen gibt es keinen Bestandsschutz |
| `""` → `none`, Wertänderungen, Variantennamen fehlen in der Rechnung | 9.2 Pflichteinträge; die frühere Zahl „11 %" wird nicht übernommen |
| `custom-header: none` kehrt die Bedeutung um | 9.2: Argument löschen |
| `materials: "page-per-task"` falsch beschrieben | Abschnitt 6 nach dem Code: `"after-task"` mit `materials-pagebreak: "before"` |
| `"leaf"` als Erfindung | `points: "all"` mit `points-total: false` |
| Alias-Mischbild im Wert (`kariert(4)` neben `pattern: "squares"`) | kein Alias mehr: `kariert` ist der Baustein, `"squares"` sein Parameterwort als Enum-Wert. Feste Regel in 5.3 (Enum-Werte englisch; kein Enum, wo der Baustein übergeben werden kann), Wortpaar in 2.1b |
| Altname `stufe` in klassenarbeit | 8.3 und 9.2: entfernt, mit Hinweis |
| keine Entscheidung zur Versionsnummer | 11.1 |
| umgedrehte Schalter, geänderte Vorgaben (aus A und C nicht übernehmen) | 4.3, 5.5, L25 |
| (neu, aus der Entscheidung) festes Mischbild `#aufgabe(title:, workspace: kariert(4))` | gewollt und als Regel gefasst: deutsch vor der Klammer, englisch in der Klammer (Leitregel 1); die Grenze ist `bausteine-de.txt`, geprüft durch L23 und L27 |
