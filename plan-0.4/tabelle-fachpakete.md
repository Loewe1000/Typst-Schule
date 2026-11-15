# Umbenennungstabelle Fachpakete und Hilfspakete

Stand 2026-11-15. Grundlage: `KONVENTION.md` (verbindlich) und die Inventare `mathematik.md`, `physik.md`, `informatik-kleinpakete.md`, `hilfspakete.md`. Am Repo wurde nichts geändert.

Geltungsbereich: mathematik 0.0.2, physik 0.0.2, informatik 0.0.2, operatoren 0.0.1, insert-a-word 0.0.3, random 0.0.1, energy-sketch 0.0.3; dazu die Entscheidung für options, typopst, summify, gutachten, flashcards, typlace, eduki, angela, abbozza, messwerttabellen. patterns steht in der Kern-Tabelle (Konvention A.7).

**Zielversion** aller sieben Pakete: 0.4.1 (Konvention 11.1). Die alten Versionsordner bleiben liegen.

**Entscheidung vom 2026-11-15 (Konvention: Kasten am Anfang, 2.1a, 9.3, Anhang B.1):** Die Bausteine behalten auf Dauer ihren deutschen Namen und haben keinen englischen Zwilling. In den Fachpaketen sind das `graphen`, `steckbrief`, `kreisdiagramm` (mathematik), `datensatz`, `messdaten`, `berechnung`, `messwerttabelle`, `schaltkreis`, `konstante` und die sechs Regressionen (physik), `haeufigkeitsanalyse` (informatik) und `operatoren-liste` (operatoren). Ihren Namen ändern nur die Bausteine, deren Schreibweise § 2.3 oder § 2.4 verletzt: `häufigkeitsanalyse` → `haeufigkeitsanalyse`, `lineare_regression` → `lineare-regression` und die fünf weiteren Regressionen. Die früheren englischen Zielnamen dieser Tabelle (`graph`, `function-profile`, `pie-chart`, `dataset`, `measurements`, `derived`, `measurement-table`, `linear-regression` und die fünf weiteren, `circuit`, `constant`, `frequency-analysis`, `operator-overview`) entfallen und stehen in `zwillinge.txt` (L27). Alles in den Klammern bleibt englisch wie ausgearbeitet: Parameter, Schlüssel, Enum-Werte, Ergebnis-Schlüssel. Englisch bleiben auch die Funktionen, die kein Baustein sind (Aktionen, Umwandlungen, Technikhelfer, Eigen- und Fremdnamen).

Lesart der Tabellen:

- **Art**: unverändert / umbenannt / Typ geändert / Default geändert / entfernt / neu / zusammengelegt / intern (wandert nach `internal`, 7.2).
- **Codemod**: ja = rein mechanisch; teilweise = nur bei Literalen im selben Aufruf, sonst Bericht; nein = nur Bericht, das Paket meldet beim Kompilieren „heißt jetzt". Schlüssel in Dictionary-Einträgen und Feldzugriffe sind höchstens „teilweise": der Codemod sieht sie nur, wenn das Dictionary als Literal im Aufruf bzw. die Kette zusammenhängend im Quelltext steht.
- **Begründung**: G-Nr. = Glossarzeile (Abschnitt 3), § = Abschnitt der Konvention, L-Nr. = Lint-Regel, AnhB = Anhang B.
- **[prüfen]** = Wirkung nicht am gerenderten PDF bestätigt; die Namensentscheidung gilt trotzdem.
- **[Lücke]** = das Wort oder der Begriff fehlt in `words-en.txt`, `names.txt` oder im Glossar; gesammelt in Abschnitt 11.
- Jede öffentliche Funktion mit benannten Parametern prüft Namen, Typen und Werte (8.4). Wo heute ein Sink Argumente verschluckt oder an ein Fremdpaket weiterreicht, steht das in der Zeile des Sinks.
- **Abfang alter Namen:** Jede Funktion, die einen benannten Parameter umbenennt oder verliert oder deren Positionsargumente sich ändern, trägt den Sink `..deprecated` (§ 4.4 Nr. 5 c), bei Funktionen mit eigenem Positions-Sink übernimmt `..args` oder `..cells` die Aufgabe. Ohne Sink meldete Typst nur „unexpected argument"; die Meldung „heißt jetzt" (§ 8.3, § 9.1) wäre nicht erzeugbar. Der Sink fängt auch überzählige Positionsargumente und nennt die neue Aufrufform, zum Beispiel ``physik.datensatz: drei Positionsargumente – `datensatz(values, name: …, unit: …)` schreiben``. Bei den Bausteinen, die ihren Namen behalten (`datensatz`, `berechnung`, `konstante`, `messwerttabelle`, `graphen` …), ist der Sink die einzige Stelle, die eine alte Aufrufform erkennt: Einen Stub „heißt jetzt“ gibt es dort nicht, weil alter und neuer Funktionsname gleich sind. Keinen Sink haben nur Funktionen, die nie einen benannten Parameter hatten und deren einziges Positionsargument bleibt (`bin-to-dec` und die drei anderen Zahlensysteme, `haeufigkeitsanalyse`, `iaword`, `reset-iaword`).
- Dieses Dokument wurde nach einer Prüfung überarbeitet; Abschnitt 14 nennt je Befund, was sich geändert hat, und am Ende die Einarbeitung der Entscheidung „deutsche Bausteine“.

---

## 1. mathematik 0.0.2 → 0.4.1

### 1.0 Öffentliche Namen

| alt | neu | Art | Codemod | Begründung |
|---|---|---|---|---|
| `graphen` | `graphen` | unverändert (Parameter geändert) | – | Baustein (Konvention 2.1a, AnhB B.1); der Plural bleibt wie im Bestand (2.1a „Form“) |
| `steckbrief` | `steckbrief` | unverändert (Parameter geändert) | – | Baustein (2.1a, AnhB B.1) |
| `kreisdiagramm` | `kreisdiagramm` | unverändert (Parameter geändert) | – | Baustein (2.1a, AnhB B.1) |
| `geogebra-cell` | `geogebra-cell` | unverändert (Parameter geändert) | – | `geogebra` steht in `names.txt`; `cell` [Lücke] |
| `geogebra-algebra` | `geogebra-algebra` | unverändert (Parameter geändert) | – | „Algebra" ist der Eigenname der GeoGebra-Ansicht; `algebra` nach `names.txt` [Lücke] |
| `geogebra-colors` | `internal.geogebra-palette` | intern | nein | Hilfswert der Zellen, kein Dokument braucht ihn; arbeitsblatt reicht ihn schon heute nicht weiter; Schlüssel `button` ist unbenutzt (F21) |
| `geogebra-button` | `internal.geogebra-menu-button` | intern | nein | wie oben; L5 verböte außerdem nichts, aber der Helfer ist nur Teil von `geogebra-cell(menu: true)` |
| `geogebra-approx-button` | `internal.geogebra-approximate-button` | intern | nein | `approx` ist keine erlaubte Abkürzung (§ 2.2) |
| `geogebra-style` | `geogebra-style` | unverändert | – | wird im Paket von `geogebra-algebra` aufgerufen (L1918), hat aber einen eigenen Docstring mit Dokumentbeispiel (L1840–1845) und wird in docs/content.typ Z. 436/456 als öffentliche Funktion vorgeführt; arbeitsblatt reicht es heute nicht durch; im Repo 1 Aufruf, außerhalb vom Inventar nicht gezählt (Zweifelsfall 13); `style` [Lücke] |
| `teilaufgaben` | eigene Kopie entfällt; Baustein `teilaufgaben` aus aufgaben | Definition verlagert (Name unverändert, Parameter geändert) | teilweise (Name bleibt; Parameter ja, Enum-Body nur Bericht) | AnhB B.1; doppelt zu arbeitsblatt 0.4.0 L1228 ff.; bindet aufgaben 0.1.2 (F5) |
| `tasks` | `teilaufgaben` (aus aufgaben) | umbenannt | teilweise (Name ja; Parameter ja, Enum-Body nur Bericht) | § 9.3: zweiter Name eines Bausteins, entfällt. Der abbrechende Stub liegt allein in arbeitsblatt (`arbeitsblatt.tasks`); mathematik und aufgaben haben keinen, bei Direktimport von mathematik greifen nur Codemod und `regeln.json`, sonst meldet Typst „unknown variable“ (Abschnitt 9.1). G4 verbietet `tasks` als Funktion; Alias von `teilaufgaben` (L62) mit denselben Parametern und demselben Enum-Body-Weg |
| `default_seed`, `m`, `a`, `lcg`, `low_cminstd_rand`, `low_cminstd_randint`, `step_seed`, `fisher_yates_shuffle`, `rand`, `randint`, `shuffle` | entfallen als Re-Export | entfernt | nein | § 7.1, L19: kein `import …: *`; mathematik benutzt keinen dieser Namen (F1) |
| `umrechnungseinheit` | entfällt als Re-Export; mathematik ruft `physik.internal.prefix-factor` | entfernt | nein | § 7.2 (F2) |

Keine States, Counter oder Labels in mathematik, heute wie künftig.

### 1.1 `teilaufgaben` (eigene Kopie) und `tasks` → Baustein `teilaufgaben` aus aufgaben (Konvention A.3)

```typ
// alt (mathematik.typ L23)
#let teilaufgaben(tasks: (), columns: auto, numbering: "a)", gutter: 1.25em, loesungen: (), ..args) = {
#let tasks = teilaufgaben
// neu: keine Definition in mathematik. Dokumente benutzen
#let teilaufgaben(items: (), item-solutions: (), columns: auto, numbering: "a)", gutter: 1.25em, align: left, inset: 0pt, ..deprecated) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `tasks:` | `items:` | umbenannt | – | ja | G78; der Parameter hieß wie der alte Zweitname der Funktion |
| `columns: auto` | `columns: auto` | unverändert | – | – | G36, W9 |
| `numbering: "a)"` | `numbering: "a)"` | unverändert (wird wirksam) | – | – | G39; heute ohne Wirkung (F4) |
| `gutter: 1.25em` | `gutter: 1.25em` | unverändert | – | – | G33 |
| `loesungen:` | `item-solutions:` | umbenannt | – | ja | G5, § 5.1 (gleicher Name, gleicher Typ) |
| `..args` positional (Enum-Body `+ a + b`) | entfällt | entfernt | `teilaufgaben[+ a + b]` → `teilaufgaben(items: ([a], [b]))` | teilweise | § 4.4 Nr. 4 ein Weg; außerhalb des Repos 0 von 56 Aufrufen |
| `..args` benannt (an `table()`) | `align`, `inset` deklariert; alles andere Fehler | entfernt | `row-gutter:` (2 Vorkommen) → Bericht | teilweise | § 4.4 Nr. 5, L16 |

### 1.2 `graphen` (Name unverändert, Parameter neu)

```typ
// alt (L97)
#let graphen(
  size: none, scale: 1, x: (-5, 5), y: (-5, 5), step: 1, x-step: none, y-step: none,
  x-label: [$x$], y-label: [$y$], grid: "both", x-grid: none, y-grid: none,
  line-width: 1.5pt, samples: 200, fills: (), datensätze: (), marks: (), ..args, annotations: {},
) = {
// neu
#let graphen(
  width: auto,          // W5 length; auto = 1cm je Achseneinheit
  height: auto,         // W5 length
  domain: auto,         // W7 mit W5: array (min, max) für beide Achsen oder (x: …, y: …); auto = (-5, 5), mit datasets deren Bereich
  step: auto,           // W7 mit W5: int | float | array (major, minor) | none für beide Achsen oder (x: …, y: …); auto = 1, mit datasets automatisch
  labels: auto,         // W5 array (x-Achse, y-Achse) aus content | auto | none
  grid-lines: "all",    // W7 mit W2: none | "major" | "minor" | "all" für beide Achsen oder (x: …, y: …)
  stroke: 1.5pt,        // W9 stroke; Vorgabe für alle Graphen
  sample-count: 200,    // int, Stützstellen je Graph
  areas: (),            // array aus dictionary
  datasets: (),         // array aus dictionary
  marks: (),            // array aus dictionary
  annotations: (),      // CeTZ-Zeichenbefehle
  ..args,               // positional: Graphen (content | function | dictionary); benannt: nur Abfang alter Namen
) = { }
```

Achsenpaare stehen als „Wert je Ziel" (W7) in **einem** Parameter mit den festen Schlüsseln `x` und `y`: `domain: (-5, 5)` gilt für beide Achsen, `domain: (x: (0, 10))` nur für die x-Achse; ein fehlender Schlüssel hat die Vorgabe des Parameters (`auto` bei `domain` und `step`, `"all"` bei `grid-lines`). Damit entfallen die sechs Namen `x`, `y`, `x-step`, `y-step`, `x-grid`, `y-grid` (und die im ersten Entwurf geplanten `x-domain`, `y-domain`), die paarweise nur Levenshtein-Abstand 1 hatten (§ 4.2, L10), und kein alter Name lebt mit neuer Bedeutung weiter: `x-step: none` hieß „erbt von `step`", ein neues `x-step: none` hätte „keine Teilstriche" geheißen. Die alten Namen sind reine „heißt jetzt"-Fälle.

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `size: none` | `width: auto`, `height: auto` | zusammengelegt mit `scale`, Typ geändert | `none` → Argument löschen; `(b, h)` → `width: b·s·1cm, height: h·s·1cm`; `n` → beide `n·s·1cm` (s = `scale`, sonst 1) | teilweise (Literale) | G31, G32; § 5.5 Längen sind nie nackte Zahlen |
| `scale: 1` | entfällt | entfernt | mit `size`: eingerechnet; ohne `size`: `width`/`height` = Achsenbereich · s · 1cm, nur wenn `x`/`y` Literale sind, sonst Bericht | teilweise | § 5.5 keine Faktoren; Markengröße bei s ≠ 1 **[prüfen]** |
| `x: (-5, 5)` | `domain: auto` (Schlüssel `x`) | umbenannt, zusammengelegt, Default geändert | Literal `(-5, 5)` → Argument löschen, **auch zusammen mit `datensätze`**: dort wirkt die Angabe heute nicht, weil der Code die Vorgabe als Sentinel vergleicht (L686–689) und den Datenbereich nimmt; `auto` → löschen; `(a, b)` → `domain: (x: (a, b))`; `x` und `y` im selben Aufruf → ein `domain: (x: …, y: …)`; Variable oder Ausdruck → übernehmen und Bericht (ein Wert `(-5, 5)` zusammen mit `datasets` gälte künftig wirklich) | teilweise (Literale) | G70; W7; Default `auto` ersetzt den Sentinel-Vergleich (F10) |
| `y: (-5, 5)` | `domain: auto` (Schlüssel `y`) | wie `x` | wie `x` (Sentinel L690–693) | teilweise (Literale) | wie `x` |
| `step: 1` | `step: auto` | Default geändert | Literal `1` → Argument löschen (ohne `datasets` ist `auto` = 1; mit `datensätze` gilt eine ausdrückliche `1` heute als „nicht gesetzt", L705–713); andere Werte bleiben; `none` bleibt „keine Teilstriche"; Variable → übernehmen und Bericht | teilweise (Literale) | G71; Sentinel `step == 1` (F10) |
| `x-step: none` | `step` (Schlüssel `x`) | zusammengelegt | `none` → Argument löschen (heute „erbt"); `v` → `step: (x: v)`; steht daneben `step: s` mit s ≠ 1 → `step: (x: v, y: s)`; steht daneben `step: 1` oder nichts → `step: (x: v)` (die y-Achse bleibt `auto`, wie heute) | teilweise (Literale, Kontextregel) | W7; § 5.1: `auto` = Paket entscheidet, `none` = nichts |
| `y-step: none` | `step` (Schlüssel `y`) | wie `x-step` | wie `x-step` | teilweise | wie `x-step` |
| `x-label: [$x$]` | `labels: auto` (1. Eintrag) | zusammengelegt | Literal `[$x$]` → `auto` (ohne `datasets` ist das die Vorgabe; mit `datensätze` gilt es heute als „nicht gesetzt" und die Datensatz-Beschriftung gewinnt, L694–697); `x-label: A, y-label: B` → `labels: (A, B)`; nur eines → `labels: (A, auto)` bzw. `(auto, B)`; `labels: (auto, auto)` → Argument löschen | teilweise (Literale) | G46 (`x-label` ist verbotenes Synonym); G44 `label` nie für Sichtbares; Sentinel `== [$x$]` entfällt (F10) |
| `y-label: [$y$]` | `labels: auto` (2. Eintrag) | zusammengelegt | Literal `[$y$]` → `auto` (L698–701); sonst siehe oben | teilweise (Literale) | G46 |
| `grid: "both"` | `grid-lines: "all"` | umbenannt, Wert umbenannt | `"both"` → löschen (Vorgabe); `"major"`, `"minor"` bleiben; `"none"`, `false` → `none`; `none` bleibt `none`; `true` → `"major"` (cetz-plot: `true` = Hauptgitter) **[prüfen]** | ja | § 4.5: `grid` steht in `dir(std)`, besteht den Durchreichtest nicht (der Wert geht an cetz-plot, nicht an Typsts `grid`) und hat keine Glossarzeile; `grid`, `lines`, `all` stehen in der Wortliste; § 5.2 (`"none"` verboten); `major`, `minor` [Lücke] |
| `x-grid: none` | `grid-lines` (Schlüssel `x`) | zusammengelegt | `none` → Argument löschen (heute „erbt"); `"none"`, `false` → `grid-lines: (x: none)`; `"both"` → `(x: "all")`; `true` → `(x: "major")`; steht daneben `grid: g` → `grid-lines: (x: …, y: g′)` | teilweise (Literale, Kontextregel) | W7; § 5.1, § 5.2 |
| `y-grid: none` | `grid-lines` (Schlüssel `y`) | wie `x-grid` | wie `x-grid` | teilweise | wie `x-grid` |
| `line-width: 1.5pt` | `stroke: 1.5pt` | umbenannt | Wert bleibt (eine Länge ist ein gültiger stroke) | ja | G30 |
| `samples: 200` | `sample-count: 200` | umbenannt | – | ja | G71 verbietet `samples` und schreibt `steps` vor; `steps` neben `step` in einer Signatur verletzt aber § 4.2/L10 (Abstand 1) und ist genau die Tippfehlerfalle, die L10 verhindern soll. Deshalb G38 `<ding>-count`; `sample` [Lücke]; Widerspruch G71 gegen L10 siehe Abschnitt 11 |
| `fills: ()` | `areas: ()` | umbenannt, Kurzformen entfernt | einzelnes Dictionary `d` → `(d,)`; `(f, g)` → `((between: (f, g), domain: "intersections"),)`; einzelne Funktion `f` → `((term: f, domain: "intersections"),)` | teilweise (Literale) | G27 belegt `fill` als Farbe, die Fläche braucht ein eigenes Wort `areas` [Lücke]; § 4.4 Nr. 4 |
| `datensätze: ()` | `datasets: ()` | umbenannt, Kurzformen entfernt | `(xs, ys)` → `((x: xs, y: ys),)`; einzelnes Dictionary `d` → `(d,)` | teilweise (Literale) | G69: Parameterwort `datasets` zum Baustein `datensatz` (2.1b); § 2.3 kein Umlaut; AnhB B.2 |
| `marks: ()` | `marks: ()` | unverändert (Einträge geändert) | Eintrag `(x, y)` → `(at: (x, y))`; Eintrag `((x, y), [P])` → `(at: (x, y), body: [P])`; einzelnes Dictionary `d` → `(d,)`; `marks: (1, 2)` (ein nacktes Zahlenpaar) → `((at: (1, 2)),)` | teilweise (Literale) | `marks` [Lücke]; `marks: (1, 2)` wird zur Laufzeit Fehler mit Abhilfe `((at: (1, 2)),)` statt stiller Leere (F9) |
| `..args` positional | `..args` positional | unverändert | – | – | § 4.4 Nr. 5 (a) |
| `..args` benannt (an `plot.plot()`) | Fehler „unbekannter Parameter" bzw. „heißt jetzt" für die alten Namen dieser Tabelle | entfernt | Bericht je Fundstelle | nein | § 4.4 Nr. 5, L16; im Repo kein Aufruf mit Fremdargumenten gefunden |
| `annotations: {}` | `annotations: ()` | Default geändert (gleichwertig), Stellung vor dem Sink | – | – | Numerus-Vermerk G; § 4.4 Nr. 1; wie `kariert(annotations: ())` |

Für alle folgenden Eintragstabellen gilt: Der Codemod benennt Schlüssel nur um, wenn das Dictionary als Literal im selben Aufruf steht. Ein `#let f1 = (term: …, color: 2)` oder `marks: punkte` sieht er nicht und meldet die Stelle im Bericht; den Rest fängt die Laufzeitprüfung der Eintragsschlüssel (§ 5.4, § 8.4) mit „heißt jetzt". Deshalb steht in der Spalte Codemod durchgehend „teilweise".

Graph-Definition (Positionsargument: content, function oder Dictionary):

| alt (Schlüssel) | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `term` | `term` | unverändert | – | – | [Lücke] `term` |
| `domain` | `domain` | unverändert | Array `(min, max)` | – | G70 |
| `stroke` | `stroke` | unverändert | – | – | G30; `stroke` und `accent` zusammen dürfen nicht abstürzen (F7) |
| `color` | `accent` | umbenannt, Typ geändert | Farbe bleibt; int-Literal n → n-te Palettenfarbe als Literal, 1-basiert, über 10 hinaus umlaufend (1 `#1F77B4`, 2 `#D62728`, 3 `#2CA02C`, 4 `#FF7F0E`, 5 `#9467BD`, 6 `#8C564B`, 7 `#E377C2`, 8 `#7F7F7F`, 9 `#BCBD22`, 10 `#17BECF`); int als Variable → Bericht, zur Laufzeit Fehler „erwartet eine Farbe" | teilweise | G26/G27 verbieten `color`; W5 color, `auto` = Palettenfarbe nach Position. `accent`, weil die eine Farbe mehreres ableitet (Linie und Vorgabe der Beschriftung); im Docstring festhalten |
| `clr` | `accent` | zusammengelegt | wie `color` | teilweise | § 2.2 keine Abkürzung; ein Weg |
| `label` (Dictionary) | `labels` (Array aus Dictionary) | umbenannt, Typ geändert | `label: d` → `labels: (d′,)` | teilweise | G44, G46 („Kurvenbeschriftung") |

Kurvenbeschriftung (Eintrag in `labels` eines Graphen):

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `x` | `x` | unverändert | eine Zahl: Stelle auf der x-Achse (L856 `p.label.x`) | – | § 2.4 Achsenbezeichner. Der Schlüssel ist hier eine einzelne Zahl, in `datasets[]` und bei den Regressionen eine Zahlenreihe; das ist als Ausnahme von L6 für Achsenbezeichner in Abschnitt 11 beantragt [Lücke] |
| `content` | `body` | umbenannt | – | teilweise | G79 |
| `position: "tr"` | `position: "top-right"` | Werte umbenannt | `"tl"` → `"top-left"`, `"tr"` → `"top-right"`, `"bl"` → `"bottom-left"`, `"br"` → `"bottom-right"`; jeder andere Wert wird Fehler. Heute ergibt ein unbekannter Wert eine Mischform (Ausrichtung wie `"br"`, L881–883; Versatz nach erstem und letztem Buchstaben, L885–886). Steht im Altdokument schon ein ausgeschriebener Wert (`"top-left"` usw.), übernimmt der Codemod ihn nicht still, sondern meldet ihn: er sieht aus wie ein neuer Wert, wirkt heute aber anders, und die Laufzeitprüfung kann das nicht unterscheiden | teilweise | G72 Auswahl; § 2.2 keine Abkürzung; `left`, `right` [Lücke] |
| `fill: white` | `fill: white` | unverändert | – | – | G27 (Hintergrund des Textkastens) |
| `size: none` | `font-size: auto` | umbenannt | `none` → Argument löschen | teilweise | G49 |
| `color` | `text-fill: auto` | umbenannt | Farbe bleibt; `auto` = Farbe des Graphen | teilweise | G26 ist die Akzentfarbe, nicht jede Farbe; hier ist es die Textfarbe, die auch in `kreisdiagramm` und in `internal.badge` `text-fill` heißt (Typst: `text(fill:)`); int-Index war hier ein Absturz (F8) |
| `padding: 1mm` | `distance: 1mm` | umbenannt | – | teilweise | Der Wert ist kein Innenabstand: er verschiebt den Kasten um ±`padding` vom Kurvenpunkt (`dx`/`dy`, L865, L885–886); der Innenabstand ist fest `1mm` (L901). G35 `inset` wäre falsch, G74 `offset` verlangt `(dx:, dy:)`; `distance` [Lücke] |
| `angle: 0deg` | `rotation: 0deg` | umbenannt | – | teilweise | G75 |

Einträge in `areas` (heute `fills`):

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `term` | `term` | unverändert | – | – | – |
| `between` | `between` | unverändert | – | – | [Lücke] `between` |
| `domain` | `domain: auto` | Typ geändert | Array bleibt; `"auto"` → `"intersections"`; fehlt → wie heute x-Bereich | teilweise | § 5.1: `auto` heißt „Paket entscheidet", ein String `"auto"` ist kein `auto`; W8 Name statt Wert; `intersections` [Lücke] |
| `auto-domain: true` | `domain: "intersections"` | zusammengelegt | `true` → `domain: "intersections"`; `false` → löschen | teilweise | § 4.4 Nr. 4 ein Weg |
| `color`, `clr` | `fill` | umbenannt, zusammengelegt | Farbe bleibt; int-Literal → Palettenfarbe wie beim Graphen | teilweise | G27: Füllfarbe eines Elements heißt `fill`, `color` ist dort das verbotene Synonym; der Wert wird unverändert als Füllung gezeichnet (L374–375, L825) |

Einträge in `marks`:

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `position` (Koordinate) | `at` | umbenannt | nur wenn der Wert ein Array-Literal ist (Kontextregel, siehe unten) | teilweise (Kontextregel) | `position` ist die Lage (G72); `at` steht in der Wortliste |
| `pos` | `at` | zusammengelegt | – | teilweise | G72 verbietet `pos` |
| `content` | `body` | umbenannt | – | teilweise | G79 |
| `label` | `body` | zusammengelegt | – | teilweise | G44 |
| `anchor: "south-west"` | `position: "top-right"` | umbenannt, Werte geändert | CeTZ-Anker: `"south-west"` → `"top-right"`, `"south-east"` → `"top-left"`, `"north-west"` → `"bottom-right"`, `"north-east"` → `"bottom-left"`, `"south"` → `"top"`, `"north"` → `"bottom"`, `"west"` → `"right"`, `"east"` → `"left"`. Kürzel (heutiges Verhalten erhalten, F12; am Code L969–987 bestätigt): `"tl"`/`"top-left"` → `"bottom-left"`, `"tr"`/`"top-right"` → `"bottom-right"`, `"bl"`/`"bottom-left"` → `"top-left"`, `"br"`/`"bottom-right"` → `"top-right"`, `"t"`/`"top"` → `"bottom"`, `"b"`/`"bottom"` → `"top"`, `"l"`/`"left"` → `"left"`, `"r"`/`"right"` → `"right"`. Die Wertabbildung gilt nur am Schlüssel `anchor`, nie an `position` (Kontextregel) | teilweise (Kontextregel) | G72: ein Wort für die Lage einer Beschriftung, dieselben Werte wie bei der Kurvenbeschriftung |
| `padding: 2mm` | `distance: 2mm` | umbenannt | – | teilweise | derselbe Begriff wie bei der Kurvenbeschriftung (Abstand der Beschriftung vom Punkt), deshalb derselbe Name; intern bleibt es CeTZ-`padding` (L991); Vorgabe bleibt 2mm (L25) |
| `symbol: "x"` | `symbol: "x"` | unverändert | – | – | Punktsymbol; G77 sperrt `symbol` heute pauschal, die Freigabe für Zeichen (Formelzeichen, Punktsymbol, Schaltzeichen) ist in Abschnitt 11 beantragt [Lücke]. `mark` (erster Entwurf) entfällt: `marks` ist die Liste beschrifteter Punkte, `mark` darin wäre kein Singular davon gewesen und läge neben `marker` (G43) |
| `stroke: black` | `stroke: black` | unverändert | – | – | G30 |
| `fill: none` | `fill: none` | unverändert | – | – | G27 |
| `color`, `clr` | `accent` | umbenannt, zusammengelegt | wie beim Graphen (auch Palettenindex); heute gewinnt hier `clr`, sonst `color` (Inventar 5.4 Nr. 34) | teilweise | G26: eine Farbe für Rand und, wenn `fill` fehlt, Füllung des Symbols (L464–475) |

Kontextregel `position`/`anchor` in `marks[]`: Die flache Abbildung `position` → `at`, `anchor` → `position` wäre eine Tauschkette, also reihenfolgeabhängig und nicht idempotent, und die alte und die neue Wertemenge von `anchor`/`position` überschneiden sich mit vertauschter Bedeutung (alt `anchor: "top-right"` setzt den Text nach unten rechts). Deshalb:

1. Der Codemod bearbeitet einen `marks`-Eintrag in **einem** Durchgang: `position` wird nur dann zu `at`, wenn sein Wert ein Array-Literal ist; `anchor` wird zu `position` und nur dabei wird der Wert abgebildet. Ein `position` mit String-Wert ist schon neu und bleibt.
2. Laufzeitprüfung: `marks[].position` mit Array-Wert → ``mathematik.graphen: `position` heißt in `marks` jetzt `at` ``; `marks[].anchor` → ``… `anchor: "top-right"` heißt jetzt `position: "bottom-right"` `` (die Meldung nennt den abgebildeten Wert); `position` mit unbekanntem String → Liste der erlaubten Werte.
3. Abnahmekriterium: Codemod zweimal angewandt = einmal angewandt (Idempotenz-Test über alle Eintragstabellen).

Einträge in `datasets` (heute `datensätze`):

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `x` | `x` | unverändert | Datensatz aus physik oder Array aus Zahlen | – | § 2.4; derselbe Name und Typ wie `x:` der Regressionen |
| `y` | `y` | unverändert | – | – | wie `x` |
| `marker: "x"` | `symbol: "x"` | umbenannt | String bleibt; Dictionary `(symbol: s, k: v)` → `symbol: s` und `k: v` als eigene Schlüssel des Eintrags, soweit k `fill` oder `stroke` ist, sonst Bericht | teilweise | G43 belegt `marker` als Beschriftung statt Nummer; dasselbe Ding heißt bei `marks` ebenfalls `symbol` |
| `mark-style` | `fill`, `stroke` (Schlüssel des Eintrags) | zusammengelegt | `mark-style: (fill: f, stroke: s)` → `fill: f, stroke: s`; andere Schlüssel → Bericht; bei Doppelung gewinnt wie heute das `marker`-Dictionary (L934–948) | teilweise | ein Weg; dieselben Schlüssel wie in `marks[]` (`symbol`, `stroke`, `fill`, `accent`); G27, G30 |
| `color`, `clr` | `accent` | umbenannt, zusammengelegt | wie beim Graphen (auch Palettenindex) | teilweise | G26: eine Farbe für Rand und Füllung des Symbols (L932) |

Gelesene Schlüssel eines physik-Datensatzes: siehe 2.2 (`name`, `unit`, `prefix`, `values`).

### 1.3 `steckbrief` (Name unverändert, Parameter neu)

```typ
// alt (L1019)
#let steckbrief(..bedingungen, notation: "dec", precision: 1e-10) = {
// neu
#let steckbrief(
  notation: "decimal",  // W2 "decimal" | "scientific" | "fraction"
  tolerance: 1e-10,     // float; Betrag darunter gilt als 0
  ..args,               // positional: Bedingungen als str, zum Beispiel "f'(2)=0"; benannt: nur Abfang alter Namen
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `..bedingungen` positional | `..args` positional | umbenannt (Sink) | – | – | L16 Sink-Namen; § 2.1 englisch |
| `..bedingungen` benannt (verschluckt) | Fehler „unbekannter Parameter"; `precision` → „heißt jetzt `tolerance`" | entfernt | – | nein | § 4.4 Nr. 6 |
| `notation: "dec"` | `notation: "decimal"` | Werte umbenannt | `"dec"` → `"decimal"`, `"sci"` → `"scientific"`, `"frac"` → `"fraction"`; anderer Wert wird Fehler (heute wie `"dec"`) | ja | § 2.2 keine Abkürzung (`sci`, `frac`); `dec` bleibt den Zahlensystemen vorbehalten; `notation`, `decimal`, `scientific`, `fraction` [Lücke] |
| `precision: 1e-10` | `tolerance: 1e-10` | umbenannt | – | ja | G65/G66 verbieten `precision`; der Wert ist eine Nullschwelle, keine Stellenzahl, deshalb nicht `digits` (Zweifelsfall 3); `tolerance` [Lücke]; gilt künftig auch als Pivot-Schwelle (F15) |

Rückgabe-Dictionary:

| alt | neu | Art | Codemod | Begründung |
|---|---|---|---|---|
| `ansatz` | `ansatz` | unverändert | – | Lehnwort der englischen Mathematiksprache, nach `names.txt` [Lücke] |
| `math` | `math` | unverändert | – | Wortliste T; die ganze Gleichung im Formelsatz, in dieser Bedeutung auch bei den Regressionen (das Formelzeichen einer Konstante heißt `symbol`, 2.7) |
| `math-digits` | `math-digits` | unverändert | – | Funktion `digits => content`; G65 |
| `function` | `function` | unverändert | – | `function` ist in § 2.2 gestrichen (kam nur im entfallenen Funktionsnamen vor) und kommt als Ergebnis-Schlüssel zurück [Lücke] |
| `gleichungssystem` | `system` | umbenannt | nein (Feldzugriff) | § 2.1; [Lücke] `system` |
| `bedingungen` | `conditions` | umbenannt | nein | § 2.1; [Lücke] |
| `bedingungen-raw` | entfällt | entfernt | nein | der Aufrufer hat die Strings selbst |
| `bedingungen-system` | `condition-system` | umbenannt | nein | L11 Bestimmungswort im Singular |
| `gleichungssystem-raw` | `equations` | umbenannt | nein | Array aus content; [Lücke] |
| `bedingungen-system-raw` | `internal`, nicht im Ergebnis | entfernt | nein | Zwischenwert |
| `a` … `h` | `coefficients: (a: …, b: …, …)` | zusammengelegt | nein | § 2.4 kein einbuchstabiger Name; Formelzeichen sind Daten (§ 2.1) und stehen deshalb in einem eigenen Dictionary; behebt die Grenze bei acht Koeffizienten (F14) |
| `error` (nur Fehlerfall) | entfällt, Abbruch über `internal.fail` | entfernt | nein | § 8.1 kein Fehler als Rückgabewert (F16) |
| `grad` (nur Fehlerfall) | entfällt | entfernt | nein | wie `error` |

### 1.4 `kreisdiagramm` (Name unverändert, Parameter neu)

```typ
// alt (L1638)
#let kreisdiagramm(data, legend: "r", show-percentage: true, label-color: black, mode: "percent", ..args) = {
// neu
#let kreisdiagramm(
  items,                    // array aus Paaren (Beschriftung, Wert)
  legend: true,             // W1
  legend-position: "right", // W2 "right" | "left" | "top" | "bottom"
  labeled: true,            // W1 Wert auf dem Segment
  percent: true,            // W1 Wert mit Prozentzeichen
  text-fill: black,         // color
  accents: auto,            // W5 array aus color; auto = Palette des Pakets
  stroke: black,            // W9
  width: 5cm,               // length, Durchmesser
  ..deprecated,
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `data` (positional) | `items` (positional) | umbenannt | – | – (positional) | G78; dieselbe Gestalt wie `haeufigkeitsanalyse(…).items` |
| `legend: "r"` | `legend: true` + `legend-position: "right"` | Typ geändert, aufgeteilt | `"r"` → löschen; `"l"` → `legend-position: "left"`; `"t"` → `"top"`; `"b"` → `"bottom"`; `false` → `legend: false`; `true`, `none` → löschen (heute still „rechts"); Dictionary → Bericht | teilweise | G47 (`legend` ist bool), G72, § 5.1 kein Parameter ist Auswahl und Dictionary zugleich |
| `show-percentage: true` | `labeled: true` | umbenannt | – | ja | G46 Schalter `labeled`; der alte Name stimmt im Modus `"absolute"` nicht |
| `mode: "percent"` | `percent: true` | Typ geändert | `"percent"` → löschen; `"absolute"` → `percent: false`; anderer Wert wird Fehler | ja | W1 (zwei Zustände); `percent` [Lücke]; Wirkung heute nur ein angehängtes `%` (F19) |
| `label-color: black` | `text-fill: black` | umbenannt | – | ja | L4 Suffix `-color`; G44; Typst nennt die Textfarbe `fill`; derselbe Name wie in der Kurvenbeschriftung von `graphen` (1.2) |
| `..args: colors` | `accents: auto` | umbenannt, deklariert | – | ja | L4 (`colors` trägt den Typ im Namen); Plural von G26 wie `subject-accents`; nicht `fills`, weil `fills` in `graphen` der alte Name der Füllflächen ist und dort „heißt jetzt `areas`" meldet; `accents` [Lücke] |
| `..args: slice-style` | `accents` (wenn Array aus Farben), sonst Bericht | zusammengelegt | – | teilweise | § 4.4 Nr. 5 |
| `..args: stroke` | `stroke: black` | deklariert | – | – | G30 |
| `..args: radius` (Vorgabe 2.5) | `width: 5cm` | umbenannt, Typ geändert | `radius: r` → `width: 2·r·1cm` | ja (Literale) | G31, § 5.5 |
| `..args: gap` | entfällt | entfernt | Bericht | nein | Einheit unklar **[prüfen]**; bei Bedarf als `gutter` deklarieren (G33) |
| `..args: value-key`, `label-key` | entfallen | entfernt | Bericht | nein | `items` sind immer Paare |
| `..args: inner-label`, `outer-label` | entfallen | entfernt | Bericht | nein | Durchreichung an cetz-plot (§ 4.4 Nr. 5); `labeled`, `percent`, `text-fill` decken den dokumentierten Fall ab |
| `..args` sonst (verschluckt, F20) | Fehler „unbekannter Parameter" | entfernt | – | nein | § 4.4 Nr. 6 |

### 1.5 GeoGebra-Funktionen

```typ
// alt (L1864, L1903)
#let geogebra-cell(content, menu: true, approx: false) = [
#let geogebra-algebra(..cells, stroke: geogebra-colors.stroke + 0.5pt, columns: 1,
  inset: (left: 0.8em, top: 0.8em, bottom: 0.8em, right: 1.2em), last-has-approx: false) = {
// neu
#let geogebra-cell(menu: true, approximate: false, ..deprecated, body) = { }
#let geogebra-style(body) = { }
#let geogebra-algebra(
  stroke: 0.5pt + rgb("#DCDCDC"),
  columns: 1,
  inset: (left: 0.8em, top: 0.8em, bottom: 0.8em, right: 1.2em),
  approximate-last: false,
  ..cells,              // positional: Zellen; benannt: nur Abfang alter Namen
) = { }
```

| Funktion | alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|---|
| `geogebra-cell` | `content` (positional, vorn) | `body` (positional, zuletzt) | umbenannt | – | – | G79, § 4.4 Nr. 1 |
| `geogebra-cell` | `menu: true` | `menu: true` | unverändert | – | – | W1; `menu` [Lücke] |
| `geogebra-cell` | `approx: false` | `approximate: false` | umbenannt | – | ja | § 2.2 ausschreiben; [Lücke] |
| `geogebra-algebra` | `..cells` | `..cells` | unverändert; benannte Extras werden Fehler, `last-has-approx` „heißt jetzt" | – | – | L16 |
| `geogebra-algebra` | `stroke` | `stroke` | unverändert (Vorgabe als Literal, gleicher Wert) | – | – | W9 |
| `geogebra-algebra` | `columns: 1` | `columns: 1` | unverändert | – | – | W9 |
| `geogebra-algebra` | `inset` | `inset` | unverändert | – | – | W9 |
| `geogebra-algebra` | `last-has-approx: false` | `approximate-last: false` | umbenannt | – | ja | derselbe Wortstamm wie `approximate` der Zelle; `last` [Lücke] |
| `geogebra-button`, `geogebra-approx-button` | `size: 1.2em` | `internal.…(width: 1.2em)` | intern, umbenannt | – | nein | G31 |
| `geogebra-style` | `body` | `body` | unverändert | – | – | G79 |
| `geogebra-colors` | Schlüssel `primary`, `stroke`, `button` | `internal.geogebra-palette` mit `accent`, `stroke`; `button` entfällt | intern | – | nein | G26; `button` unbenutzt (F21) |

---

## 2. physik 0.0.2 → 0.4.1

### 2.0 Öffentliche Namen

| alt | neu | Art | Codemod | Begründung |
|---|---|---|---|---|
| `datensatz` | `datensatz` | unverändert (Parameter und Aufrufform geändert) | – | Baustein (2.1a, AnhB B.1); Parameterwort `dataset`, `datasets` (2.1b, G69) |
| `messdaten` | `messdaten` | unverändert (Parameter und Aufrufform geändert) | – | Baustein (2.1a, AnhB B.1) |
| `berechnung` | `berechnung` | unverändert (Parameter und Aufrufform geändert) | – | Baustein (2.1a, AnhB B.1) |
| `messwerttabelle` | `messwerttabelle` | unverändert (Parameter und Aufrufform geändert) | – | Baustein (2.1a, AnhB B.1); 122 Aufrufe behalten ihren Namen |
| `lineare_regression` | `lineare-regression` | umbenannt (nur Schreibweise) | ja | § 2.4 kein Unterstrich; der Baustein bleibt deutsch (2.1a, AnhB B.1); der alte Name ist Stub (§ 9.3) |
| `quadratische_regression` | `quadratische-regression` | umbenannt (nur Schreibweise) | ja | wie `lineare-regression` |
| `wurzel_regression` | `wurzel-regression` | umbenannt (nur Schreibweise) | ja | wie `lineare-regression` |
| `exponentielle_regression` | `exponentielle-regression` | umbenannt (nur Schreibweise) | ja | wie `lineare-regression` |
| `potenz_regression` | `potenz-regression` | umbenannt (nur Schreibweise) | ja | wie `lineare-regression` |
| `polynom_regression` | `polynom-regression` | umbenannt (nur Schreibweise) | ja | wie `lineare-regression` |
| `schaltkreis` | `schaltkreis` | unverändert | – | Baustein (2.1a, AnhB B.1); dass dahinter `zap.circuit` steht, ist Umsetzung |
| `source` | `source` | unverändert (Parameter geändert) | – | [Lücke] `source` |
| `simple-source` | entfällt; `source` | entfernt | ja | Alias mit gleicher Wirkung (Inventar 1.4); Stub (§ 9.3) |
| `multimeter`, `lamp`, `voltmeter`, `motor`, `generator` | gleich | unverändert | – | englisch: Zeichenbefehle innerhalb von `schaltkreis`, Fremdvokabular von zap (AnhB B.1); [Lücke] je Wort |
| `amperemeter` | `ammeter` | umbenannt | ja | Fremdvokabular von zap, kein Baustein (AnhB B.1); Stub (§ 9.3); [Lücke] |
| `konstante` | `konstante` | unverändert (Parameter und Aufrufform geändert) | – | Baustein (2.1a, AnhB B.1); Parameterwort `constant`, `constants` (2.1b) |
| `pk` | `constants` | umbenannt | teilweise | AnhB B.1: ein Wert, kein Aufruf, deshalb englisch (Parameterwort zu `konstante`); kein Stub möglich, nur `regeln.json` (§ 9.3); mechanisch nur als Name und in zusammenhängenden Ketten `pk.h.wert`; nach `#let h = pk.h` sind die Feldzugriffe nur ein Bericht |
| `zap` | entfällt als Re-Export; das Dokument importiert zap selbst (`#import "@preview/zap:0.4.0"`) | entfernt | ja (Importzeile ergänzen, wenn `zap.` im Dokument vorkommt) | Geändert am 2026-11-15 (Nachtrag in Abschnitt 14): `UMSETZUNG-0.5.0.md` Nr. 2 lässt Fremdnamen nur in arbeitsblatt zu, `fremdnamen.txt` enthält `zap` nicht, und sig.py L19 lehnt den Export ab. Kein Stub möglich (`zap` war ein Modul): ein Dokument ohne eigene Importzeile bekommt von Typst „unknown variable: zap“. Frühere Begründung: § 7.1; ein Schaltkreis braucht neben den eigenen Komponenten zaps Leitungen und Knoten (`zap.wire`, `zap.node`), deshalb muss das Dokument an `zap` kommen. Die Zahlen 21× `zap.draw`, 8× `zap.interface`, 7× `zap.component` stammen aus dem Paketquelltext (schaltkreise.typ), nicht aus Dokumenten; das Inventar `nutzung-ausserhalb.md` zählt `zap.` nicht (im Repo 1 Dokument mit `schaltkreis`) **[prüfen]** |
| `multiplikatoren` | `internal.prefix-factors` | intern | nein | § 7.2 |
| `umrechnungseinheit` | `internal.prefix-factor` (und `internal.convert-unit`) | intern | nein | § 7.2; einziger Fremdnutzer ist mathematik |
| `auto_einheit_anwenden` | `internal.apply-auto-prefix` | intern | nein | § 7.2, § 2.4 |
| `count_decimal_places` | entfällt | entfernt | nein | in 0.0.2 unbenutzt |
| `p_messwerttabelle` | `internal.render-measurement-table` | intern | nein | § 7.2 |
| `_kopf-einheit` | `internal.header-unit` | intern | nein | § 7.2, L19 kein `_name` |
| `format-number`, `format-unit`, `combine-units`, `format-equation-term`, `build-equation`, `format-simple-equation` | `internal.` gleicher Name | intern | nein | § 7.2 |
| `regression` | `internal.fit` | intern, umbenannt | nein | § 7.2; `regression` ist Segment von sechs Bausteinnamen (`lineare-regression` …) und darf nach L27(a) in keinem englischen Funktionsnamen stehen, auch nicht in `internal`; [Lücke] `fit` (Abschnitt 11 Nr. 14) |
| `qty`, `unit`, `add-macros`, `znum` | entfallen als Re-Export | entfernt | nein | L19; `qty`, `unit`, `num` kommen laut § 7.1 aus arbeitsblatt |
| `default_seed`, `m`, `a`, `lcg`, `low_cminstd_rand`, `low_cminstd_randint`, `step_seed`, `fisher_yates_shuffle`, `rand`, `randint`, `shuffle` | entfallen als Re-Export | entfernt | nein | L19; physik braucht nur `random-number` |

Keine States, Counter oder Labels.

### 2.1 `datensatz`, `messdaten` (Namen unverändert, Aufrufform neu)

```typ
// alt (messwerttabellen.typ Z. 19, Z. 45)
#let datensatz(name, einheit, werte, prefix: "1", max-digits: none, auto-einheit: false) = {
#let messdaten(name, einheit, anzahl-messwerte, prefix: "1") = (
// neu
#let datensatz(
  values,               // array, führendes Hauptargument
  name: none,           // W4 str | content
  unit: none,           // W4 str | content
  prefix: none,         // W5 str; none = kein Vorsatz, auto = Paket wählt
  digits: auto,         // W5 int; auto = Wert der Tabelle
  ..deprecated,         // fängt max-digits, auto-einheit und die alte Form mit drei Positionsargumenten
) = { }
#let messdaten(
  count,                // int, führendes Hauptargument
  name: none, unit: none, prefix: none,
  ..deprecated,
) = { }
```

| Funktion | alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|---|
| `datensatz` | `name` (1. Position) | `name:` | Art der Übergabe geändert | `datensatz(n, e, w)` → `datensatz(w, name: n, unit: e)` | ja | § 4.4 Nr. 2, L15 höchstens ein Positionsparameter |
| `datensatz` | `einheit` (2. Position) | `unit:` | umbenannt, benannt | siehe oben | ja | G67 |
| `datensatz` | `werte` (3. Position) | `values` (1. Position) | umbenannt | siehe oben | ja | G68 |
| `datensatz` | `prefix: "1"` | `prefix: none` | Default geändert | `"1"` → löschen; `""` → löschen (wirkt wie kein Vorsatz, Schlüssel `""` in `multiplikatoren` Z. 63; gilt heute aber als „gesetzter" Vorsatz und schaltet `auto-einheit` ab, Z. 21, siehe nächste Zeilen); `"k"`, `"m"`, `"u"`, … und `"e14"` bleiben; jeder andere String wird Fehler mit der Liste der erlaubten Vorsätze | ja | § 5.2 kein Sentinel-String; [Lücke] `prefix` |
| `datensatz` | `max-digits: none` | `digits: auto` | umbenannt, Default geändert | `none` → löschen (heute „erbt") | ja | G65; § 5.1 `auto` = Paket entscheidet |
| `datensatz` | `auto-einheit: false` | `prefix: auto` | zusammengelegt | `false` → löschen; `true` → `prefix: auto`, aber nur wenn im selben Aufruf kein `prefix` ≠ `"1"` steht; steht eines da (auch `""`), wird `auto-einheit` ersatzlos gelöscht, weil das gesetzte `prefix` schon heute gewinnt (Z. 21) und sonst ein doppeltes `prefix` entstünde | ja (Kontextregel) | § 2.1 (denglisch); eine Angabe, ein Weg |
| `messdaten` | `name`, `einheit` | `name:`, `unit:` | benannt, umbenannt | `messdaten(n, e, k)` → `messdaten(k, name: n, unit: e)` | ja | wie `datensatz` |
| `messdaten` | `anzahl-messwerte` (3. Position) | `count` (1. Position) | umbenannt | siehe oben | ja | G38, AnhB |
| `messdaten` | `prefix: "1"` | `prefix: none` | Default geändert | `"1"`, `""` → löschen | ja | wie `datensatz` |

### 2.2 Datensatz-Dictionary (Vertrag zwischen `datensatz`, `berechnung`, `messwerttabelle`, Regressionen und `mathematik.graphen`)

| alt | neu | Art | Begründung |
|---|---|---|---|
| `name` | `name` | unverändert | Wortliste B |
| `einheit` | `unit` | umbenannt | G67 |
| `prefix` (`"1"` = keiner) | `prefix` (`none` = keiner, `auto` = Paket wählt) | Typ geändert | § 5.2 |
| `werte` | `values` | umbenannt | G68 |
| `auto-einheit` | entfällt (steckt in `prefix: auto`) | zusammengelegt | – |
| `max-digits` | `digits` | umbenannt | G65 |

`berechnung` und `messdaten` liefern künftig dieselbe Schlüsselmenge wie `datensatz` (heute fehlen bei `messdaten` `max-digits` und `auto-einheit`, bei `berechnung` `auto-einheit`, messwerttabellen.typ Z. 375–381). Die Regressionen erkennen einen Datensatz am Schlüssel `values` (heute `werte`).

### 2.3 `berechnung` (Name unverändert, Aufrufform neu)

```typ
// alt (Z. 212)
#let berechnung(name, einheit, datensaetze, formel, prefix: "1", auto-einheit: true, fehler: 0, max-digits: none) = {
// neu
#let berechnung(
  formula,              // function mit 1 bis 5 Argumenten, führendes Hauptargument
  datasets: (),         // array aus Datensätzen
  name: none, unit: none,
  prefix: auto,         // W5; auto = Paket wählt (heutige Vorgabe), none = kein Vorsatz
  error: 0%,            // ratio, zufälliger relativer Fehler
  digits: auto,
  ..deprecated,         // fängt fehler, max-digits, auto-einheit und die alte Form mit vier Positionsargumenten
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `name`, `einheit` (Position 1, 2) | `name:`, `unit:` | benannt, umbenannt | `berechnung(n, e, d, f)` → `berechnung(f, datasets: d, name: n, unit: e)` | ja | L15, G67 |
| `datensaetze` (Position 3) | `datasets:` | umbenannt, benannt | einzelnes Dictionary `d` → `(d,)` | teilweise | G69: in den Klammern steht das Parameterwort `datasets`, nicht der Bausteinname (2.1b); Numerus-Vermerk; ein Weg |
| `formel` (Position 4) | `formula` (Position 1) | umbenannt | – | ja | § 2.1; [Lücke] |
| `prefix: "1"` | `prefix: auto` | Default geändert (gleiches Verhalten) | `"1"` → löschen; `""` → `prefix: none` (heute kein Vorsatz und Automatik aus, Z. 228; „löschen" wäre falsch, weil die neue Vorgabe `auto` ist); Vorsatzbuchstabe und `"e<n>"` bleiben; jeder andere String (heute über `float("1" + prefix)` gerechnet, Z. 322) → Bericht, zur Laufzeit Fehler mit der Liste der erlaubten Vorsätze | ja; freie Strings nur Bericht | L25: heutige Vorgabe ist „automatisch", weil `auto-einheit: true` |
| `auto-einheit: true` | `prefix` | zusammengelegt | `true` → löschen; `false` → `prefix: none`, aber nur wenn im selben Aufruf kein `prefix` ≠ `"1"` steht, sonst ersatzlos löschen (Z. 228) | ja (Kontextregel) | wie `datensatz` |
| `fehler: 0` | `error: 0%` | umbenannt, Default-Typ geändert | `0` → löschen; ratio bleibt; nackte Zahl `5` → Fehler „erwartet ein Verhältnis, zum Beispiel `5%`" | ja | § 5.5 Anteile sind ratio; behebt Inventar 7.1 Nr. 5; [Lücke] `error` |
| `max-digits: none` | `digits: auto` | umbenannt | `none` → löschen | ja | G65 |

Rückgabe: Datensatz-Dictionary nach 2.2.

### 2.4 `messwerttabelle` (Name unverändert, Parameter neu)

```typ
// alt (Z. 501)
#let messwerttabelle(..args, amount: auto, row-height: auto, header: none, width: 100%, max-digits: 2) = {
// neu
#let messwerttabelle(
  count: auto,          // W5 int, höchstens so viele Wertespalten je Teiltabelle
  row-height: auto,     // W5 length
  header: none,         // W4 array aus content
  width: 100%,
  digits: 2,
  ..args,               // positional: Datensätze (jedes Argument muss ein Datensatz-Dictionary sein); benannt: nur Abfang alter Namen
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `..args` positional (einzeln, als ein Array oder mehrere) | `..args` positional, nur einzeln | Kurzform entfernt | `messwerttabelle((a, b))` → `messwerttabelle(a, b)`; Variable `liste` → `..liste` | teilweise | § 4.4 Nr. 4, Nr. 5 (a) |
| `..args` benannt (verschluckt) | Fehler „unbekannter Parameter" bzw. „heißt jetzt" | entfernt | – | nein | § 4.4 Nr. 6 |
| zweites Positionsargument int (Form von messwerttabellen 0.0.1: `messwerttabelle(datensatze, max_wert_pro_tabelle, …)`) | `count:` | Art der Übergabe geändert | `messwerttabelle(DS, 5)` → `messwerttabelle(..DS, count: 5)`. Laufzeit: ein Positionsargument, das kein Datensatz-Dictionary ist, wird Fehler ``physik.messwerttabelle: Positionsargument `5` ist kein Datensatz – die Spaltenzahl steht in `count: 5` `` | teilweise (AST-Regel, int-Literal) | G38; ein Positionsparameter lässt sich nicht per Name abfangen, deshalb Typprüfung im Sink |
| `amount: auto` | `count: auto` | umbenannt | – | ja | G38 (`amount` verboten), AnhB |
| `row-height: auto` | `row-height: auto` | unverändert | – | – | [Lücke] `row` |
| `header: none` | `header: none` | unverändert | – | – | G81 |
| `width: 100%` | `width: 100%` | unverändert | – | – | G31 |
| `max-digits: 2` | `digits: 2` | umbenannt | – | ja | G65 |

### 2.5 Regressionen (`…_regression` → `…-regression`)

```typ
// alt (regressionen.typ Z. 205 bis 517)
#let lineare_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
#let quadratische_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
#let wurzel_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
#let exponentielle_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
#let potenz_regression(x_param, y_param, notation: "dec", precision: 1e-10) = {
#let polynom_regression(x_param, y_param, grad, notation: "dec", precision: 1e-10) = {
// neu (alle sechs gleich; degree nur bei polynom-regression)
#let lineare-regression(
  x: none,              // Datensatz | array aus Zahlen; Pflichtangabe (Form fehlt in § 5.1, Abschnitt 11 Nr. 4): none ist ein Fehler mit Beispielaufruf
  y: none,
  notation: "decimal",  // W2 "decimal" | "scientific"
  tolerance: 1e-10,
  ..deprecated,
) = { }
#let polynom-regression(x: none, y: none, degree: none, notation: "decimal", tolerance: 1e-10, ..deprecated) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `x_param` (1. Position) | `x:` | umbenannt, benannt | `f(a, b)` → `f(x: a, y: b)` | ja | AnhB (`x_param` → `x`); § 2.4; L15; derselbe Name wie in `datasets` von `graphen` |
| `y_param` (2. Position) | `y:` | umbenannt, benannt | siehe oben | ja | wie `x` |
| `grad` (3. Position) | `degree:` | umbenannt, benannt | `polynom_regression(a, b, 3)` → `polynom-regression(x: a, y: b, degree: 3)` | ja | AnhB |
| `notation: "dec"` | `notation: "decimal"` | Werte umbenannt | `"dec"` → `"decimal"`, `"sci"` → `"scientific"`; anderer Wert wird Fehler | ja | wie 1.3 |
| `precision: 1e-10` | `tolerance: 1e-10` | umbenannt | – | ja | G65/G66; Nullschwelle, keine Stellenzahl (Zweifelsfall 3) |

Ergebnis-Dictionary aller Regressionen:

| alt | neu | Art | Codemod | Begründung |
|---|---|---|---|---|
| `math` | `math` | unverändert | – | – |
| `math-digits` | `math-digits` | unverändert | – | G65 |
| `function` | `function` | unverändert | – | – |
| `m`, `b` (linear); `a`, `b`, `c` (quadratisch); `a`, `b` (Wurzel, exponentiell); `a`, `m` (Potenz); `c0` … `cn` (Polynom) | `coefficients: (m: …, b: …)` usw., Buchstaben unverändert | zusammengelegt | nein (Feldzugriff) | § 2.4; Formelzeichen sind Daten (§ 2.1); dieselbe Form wie bei `steckbrief` |

Der Sink `..deprecated` fängt `precision` und die alte Form mit Positionsargumenten: ``physik.lineare-regression: zwei Positionsargumente – `lineare-regression(x: …, y: …)` schreiben``. `x` und `y` haben als Paar Levenshtein-Abstand 1; § 2.4 erlaubt sie als Achsenbezeichner, die Ausnahme von L10 ist in Abschnitt 11 Nr. 3 beantragt.

Die uneinheitliche Buchstabenwahl (Inventar 5.2 Nr. 14: `m` einmal Steigung, einmal Exponent; Polynom aufsteigend, quadratisch absteigend) ist eine fachliche Entscheidung und wird hier nicht umbenannt; sie steht in Abschnitt 10.

### 2.6 Schaltkreis

```typ
// alt (schaltkreise.typ Z. 16 bis 234)
#let schaltkreis = zap.circuit
#let source(name, node, current: "dc", variant: "symbol", flipped: false, flipped-side: false, ..params) = {
#let simple-source(name, node, ..params) = source(name, node, variant: "symbol", ..params)
#let multimeter(name, node, ..params) = {     // ebenso lamp, amperemeter, voltmeter, motor, generator
// neu
#let schaltkreis = zap.circuit           // unverändert
#let source(
  name, node,
  current: "direct",    // W2 "direct" | "alternating"
  kind: "symbol",       // W2 "symbol" (Kreis mit Plus und Minus) | "bars" (langer und kurzer Strich)
  flipped: false,       // W1 Polarität vertauscht
  flipped-labels: false,// W1 Plus und Minus auf der anderen Seite des Symbols
  ..args,               // weitere Knoten und zap-Argumente, gehen an zap.component; die alten Namen variant, flipped-side werden vorher abgefangen
) = { }
#let multimeter(name, node, ..args) = { }     // ebenso lamp, ammeter, voltmeter, motor, generator
```

| Funktion | alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|---|
| alle Komponenten | `name` | `name` | unverändert | – | – | zap-Schnittstelle (Zweifelsfall 2) |
| alle Komponenten | `node` | `node` | unverändert | – | – | zap-Schnittstelle; [Lücke] `node` |
| alle Komponenten | `..params` | `..args` | umbenannt (Sink) | – | – | L16 Sink-Namen; Durchreichung an `zap.component` bleibt als benannte Ausnahme (Zweifelsfall 2) |
| `source` | `current: "dc"` | `current: "direct"` | Werte umbenannt | `"dc"` → `"direct"` (löschen, da Vorgabe); `"ac"` → `"alternating"` | ja | Name unverändert aus dem Bestand; in der Wortliste steht `current` nur in der Bedeutung „aktuell" (`select: "current"`), die Glossarzeile „Stromart" ist beantragt (Abschnitt 11 Nr. 6) [Lücke]. Werte: `dc`/`ac` stehen nicht in der abschließenden Abkürzungsliste § 2.2 und haben Abstand 1 (L10); `direct`, `alternating` [Lücke] (Zweifelsfall 12) |
| `source` | `variant: "symbol"` | `kind: "symbol"` | umbenannt, ein Wert umbenannt | `"symbol"` → löschen (Vorgabe); `"lines"` → `kind: "bars"` | ja | G58 belegt `variant` als Dokumentfassung; G25 `kind`; `"symbol"` setzt die Freigabe des Worts für Schaltzeichen voraus (Abschnitt 11 Nr. 1); `"lines"` ist das Parameterwort des Bausteins `liniert` (2.1b) und der Wert `pattern: "lines"` in `klausurboegen`, meint hier aber kein Linienmuster (§ 5.3); `bars` [Lücke] |
| `source` | `flipped: false` | `flipped: false` | unverändert | – | – | W1; [Lücke] `flipped` (G51 schließt nur Typsts `flipped` für das Querformat aus) |
| `source` | `flipped-side: false` | `flipped-labels: false` | umbenannt | – | ja | der alte Name beschreibt die Wirkung nicht (Inventar 5.3 Nr. 23); G46 `labels` |
| `simple-source` | `name`, `node`, `..params` | `source(name, node, ..args)` | entfernt | – | ja | Alias |

Die Fehlermeldungen Z. 29 und 30 („current must be ac or dc") werden deutsch und laufen über `internal.fail` (§ 8); die alten Werte `"dc"`, `"ac"`, `"lines"` bekommen „heißt jetzt".

### 2.7 Konstanten

```typ
// alt (konstanten.typ Z. 18, Z. 48)
#let konstante(name, wert, einheit, symbol: none, beschreibung: none) = (
#let pk = ( h: …, h_eV: …, e: …, c: …, g: …, G: …, k_B: …, N_A: …, R: …, epsilon_0: …, mu_0: …, m: (elektron: …, proton: …, neutron: …, u: …), v: (schall: …) )
// neu
#let konstante(
  value,                // float | str, führendes Hauptargument
  name: none,           // W4 str, Bezeichnung
  unit: none,           // W4 str | content
  symbol: none,         // W4 content, Formelzeichen
  ..deprecated,         // fängt beschreibung und die alte Form mit drei Positionsargumenten
) = { }
#let constants = ( h: …, h_eV: …, e: …, c: …, g: …, G: …, k_B: …, N_A: …, R: …, epsilon_0: …, mu_0: …, m_e: …, m_p: …, m_n: …, u: …, v_sound: … )
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `name` (1. Position) | `name:` | benannt | `konstante(n, w, e, symbol: s)` → `konstante(w, name: n, unit: e, symbol: s)` | ja | L15 |
| `wert` (2. Position) | `value` (1. Position) | umbenannt | – | ja | G68 |
| `einheit` (3. Position) | `unit:` | umbenannt, benannt | – | ja | G67 |
| `symbol: none` | `symbol: none` | unverändert | – | – | Formelzeichen. G77 sperrt `symbol` heute pauschal; die Glossarzeile „Zeichen → `symbol`" ist beantragt (Abschnitt 11 Nr. 1) [Lücke]. `math` (erster Entwurf) steht in `dir(std)`, besteht den Durchreichtest nicht, überdeckt im Rumpf `math.frac` (§ 4.5, L13) und bedeutet im Ergebnis der Regressionen die ganze Gleichung. Auch `symbol` steht in `dir(std)`; mit Glossarzeile ist es nach § 4.5 zulässig, im Rumpf dann `std.symbol` (Zweifelsfall 11) |
| `beschreibung: none` | entfällt | entfernt | Argument löschen | ja | wird heute verworfen (Inventar 7.1 Nr. 13) |
| Ergebnis `name` | `name` | unverändert | – | – | – |
| Ergebnis `wert` | `value` | umbenannt | `pk.h.wert` → `constants.h.value` | teilweise (nur zusammenhängende Kette ab `pk.`; nach `#let h = pk.h` Bericht) | G68 |
| Ergebnis `symbol` | `symbol` | unverändert | – | – | wie der Parameter |
| Ergebnis `einheit` | `unit` | umbenannt | – | teilweise (Kette) | G67 |
| Ergebnis `mit-einheit` | `qty` | umbenannt | `pk.h.mit-einheit` → `constants.h.qty` | teilweise (Kette) | § 2.1; `qty` ist erlaubte Abkürzung und meint Zahl mit Einheit |
| `pk.h`, `pk.h_eV`, `pk.e`, `pk.c`, `pk.g`, `pk.G`, `pk.k_B`, `pk.N_A`, `pk.R`, `pk.epsilon_0`, `pk.mu_0` | `constants.` gleicher Schlüssel | unverändert | – | ja (nur `pk` → `constants`) | § 2.1 Daten |
| `pk.m.elektron` | `constants.m_e` | umbenannt | – | teilweise (Kette) | deutsche Wörter als Schlüssel sind keine Daten; Formelzeichen wie bei `k_B` (aus `symbol:` im Quelltext Z. 63 bis 66) |
| `pk.m.proton` | `constants.m_p` | umbenannt | – | teilweise (Kette) | wie oben |
| `pk.m.neutron` | `constants.m_n` | umbenannt | – | teilweise (Kette) | wie oben |
| `pk.m.u` | `constants.u` | umbenannt | – | teilweise (Kette) | wie oben |
| `pk.v.schall` | `constants.v_sound` | umbenannt | – | teilweise (Kette) | dieselbe Begründung wie bei `m_e`: ein deutsches Wort als Schlüssel ist kein Formelzeichen. Das Zeichen im Quelltext (Z. 72) ist $v_"Schall"$; `v_Schall` behielte das deutsche Wort und einen Großbuchstaben mitten im Schlüssel. Der Schlüssel wird englisch, das gesetzte Zeichen bleibt (Zweifelsfall 9) |

### 2.8 Interne Helfer (heute exportiert, künftig `internal`)

| alt | neu | Parameter alt → neu |
|---|---|---|
| `multiplikatoren` (Schlüssel `"Q"` … `"q"`, `""`) | `internal.prefix-factors` | Schlüssel bleiben (Daten); die Doppelung `prefix_liste` entfällt |
| `umrechnungseinheit(wert, einheit)` | `internal.convert-unit(value, unit)`; für mathematik zusätzlich `internal.prefix-factor(prefix)` | `wert` → `value`, `einheit` → `unit` |
| `auto_einheit_anwenden(werte, einheit)` | `internal.apply-auto-prefix(values, unit)` | `werte` → `values`, `einheit` → `unit` |
| `count_decimal_places(wert)` | entfällt | – |
| `_kopf-einheit(prefix, einheit)` | `internal.header-unit(prefix, unit)` | `einheit` → `unit` |
| `p_messwerttabelle(datensatze, row-height: auto, header: none, max-digits: 2)` | `internal.render-measurement-table(datasets, row-height: auto, header: none, digits: 2)` | `datensatze` → `datasets`, `max-digits` → `digits` |
| `format-number(value, notation: "dec", digits: 2)` | `internal.format-number(value, notation: "decimal", digits: 2)` | Werte wie 1.3 |
| `format-unit(einheit)` | `internal.format-unit(unit)` | `einheit` → `unit` |
| `combine-units(y_einheit, x_einheit, x_potenz: 1)` | `internal.combine-units(y-unit, x-unit, x-power: 1)` | snake_case entfällt |
| `format-equation-term(koeff, koeff-einheit, x-name, x-potenz, is-first, notation, precision, digits: 2)` | `internal.format-equation-term(coefficient, unit: none, x-name: none, x-power: 1, notation: "decimal", tolerance: 1e-10, digits: 2)` | `is-first` entfällt (unbenutzt) |
| `build-equation(y-name, terms)` | `internal.build-equation(y-name, terms)` | unverändert |
| `format-simple-equation(y-name, koeffs, x-name, notation, precision, digits: 2)` | `internal.format-simple-equation(coefficients, y-name: none, x-name: none, notation: "decimal", tolerance: 1e-10, digits: 2)` | `koeffs` → `coefficients` |
| `regression(x_param, y_param, algorithmus, format-function, koeffizienten-namen: (), min-punkte: 2, notation: "dec", precision: 1e-10)` | `internal.fit(x, y, solve, format, coefficient-names: (), min-count: 2, notation: "decimal", tolerance: 1e-10)` | wie Spalte |
| Formatierer-Protokoll `x_name`, `y_name`, `x_einheit`, `y_einheit`, `notation`, `precision`, `digits` | `x-name`, `y-name`, `x-unit`, `y-unit`, `notation`, `tolerance`, `digits` | § 2.4 |

---

## 3. informatik 0.0.2 → 0.4.1

### 3.0 Öffentliche Namen

| alt | neu | Art | Codemod | Begründung |
|---|---|---|---|---|
| `bin2dec` | `bin-to-dec` | umbenannt | ja | AnhB B.1: Umwandlung, kein Baustein, deshalb englisch; § 2.4 keine Ziffer als Wort, § 4.1 Umwandlung |
| `dec2bin` | `dec-to-bin` | umbenannt | ja | AnhB |
| `hex2dec` | `hex-to-dec` | umbenannt | ja | AnhB |
| `dec2hex` | `dec-to-hex` | umbenannt | ja | AnhB |
| `häufigkeitsanalyse` | `haeufigkeitsanalyse` | umbenannt (nur Umschrift) | ja | § 2.3 kein Umlaut; der Baustein bleibt deutsch (2.1a, AnhB B.1); die alte Schreibweise ist Stub (§ 9.3) |
| `häufigkeitsanalyse-alt` | entfällt | entfernt | teilweise | AnhB B.1, § 9.3 (entfällt ohne Nachfolgefunktion; Ersatz ist ein Feldzugriff, 3.2) |
| `caesar` | `caesar` | unverändert (Aufrufform geändert) | teilweise | AnhB |
| – | `caesar-table` | neu | – | ersetzt `caesar(key: 3)()` und `rot13()`; § 4.1 zusammengesetzter englischer Helfer (`<merkmal>-<substantiv>`, gebaut wie `ascii-table`); kein Baustein (AnhB B.1). Fehlt in `tabelle-arbeitsblatt.md` 4.2; bis er dort steht, ergänzt der Codemod die Importzeile aus informatik (Abschnitt 9.2) |
| `vigenere` | `vigenere` | unverändert (Aufrufform geändert) | teilweise | AnhB |
| `atbash` | `atbash` | unverändert (Aufrufform geändert) | ja | AnhB |
| `rot13` | `rot13` | unverändert (Aufrufform geändert) | teilweise | `names.txt` |
| `text-to-blocks` | `text-to-blocks` | unverändert (Parameter geändert) | – | AnhB |
| `ascii-table` | `ascii-table` | unverändert (Parameter geändert) | – | AnhB |
| `mono` | `internal.mono` | intern | nein | generischer Name in jedem Arbeitsblatt-Namensraum, Schrift „SF Mono" fest; Dokumente schreiben `raw("…")` |
| `blockst`, `scratch`, `set-blockst`, `blockst-run-options`, `set-scratch-run`, `scratch-run` | entfallen als Re-Export | entfernt | teilweise (Importzeile ergänzen) | § 7.1; 47 Dokumente importieren `@preview/blockst` schon selbst; der Pin 0.1.0 ist veraltet |

Keine States, Counter oder Labels.

### 3.1 Zahlensysteme

```typ
// alt (lib.typ Z. 15, 36, 524, 548)
#let bin2dec(zahl) = {      #let dec2bin(zahl) = {      #let hex2dec(hex) = {      #let dec2hex(num) = {
// neu
#let bin-to-dec(value) = { }   #let dec-to-bin(value) = { }   #let hex-to-dec(value) = { }   #let dec-to-hex(value) = { }
```

| alt | neu | Art | Codemod | Begründung |
|---|---|---|---|---|
| `zahl` (bin2dec, dec2bin) | `value` | umbenannt (positional) | – | G68, AnhB |
| `hex` | `value` | umbenannt (positional) | – | G68 |
| `num` | `value` | umbenannt (positional) | – | G68 |

Ungültige Ziffern (`bin2dec("10x2")`, `hex2dec("zz")`) und negative Zahlen werden Fehler mit Abhilfe (§ 8.1 keine stille Übergehung).

### 3.2 `häufigkeitsanalyse` → `haeufigkeitsanalyse`

```typ
// alt (Z. 65, Z. 140)
#let häufigkeitsanalyse(text) = {
#let häufigkeitsanalyse-alt(text, rel: false, cetz: true) = {
// neu
#let haeufigkeitsanalyse(text) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `text` | `text` | unverändert | – | – | § 4.5 (`text` als Parameter erlaubt, Builtin als `std.text`), AnhB |
| Ergebnis `absolut` | `counts` | umbenannt | – | nein (Feldzugriff) | G38; [Lücke] Plural |
| Ergebnis `relativ` | `frequencies` | umbenannt | – | nein | [Lücke] `frequencies` (der Singular `frequency` ist in § 2.2 gestrichen). Die Werte sind Prozentzahlen als float von 0 bis 100 (Z. 85–87), keine `ratio`; das bleibt in dieser Runde so (eine Umstellung auf `ratio` nach § 5.5 änderte jede Weiterrechnung im Dokument) und steht im Docstring |
| Ergebnis `data` | `items` | umbenannt | – | nein | G78; Array aus Paaren `([Buchstabe], Prozentwert)`, gebaut aus `relativ` (Z. 89–92); passt als Hauptargument von `kreisdiagramm`, die Segmentgrößen sind dann die Prozentwerte |
| Ergebnis `diagramm` | `chart` | umbenannt | – | nein | `chart` ist in § 2.2 gestrichen (kam nur im entfallenen Funktionsnamen vor) und kommt als Ergebnis-Schlüssel zurück [Lücke] |
| Ergebnis `text` | `text` | unverändert | – | – | – |
| `häufigkeitsanalyse-alt(t)` | `haeufigkeitsanalyse(t).items` | entfernt | `rel: true, cetz: false` → `.frequencies`; `cetz: false` → `.counts`; sonst (auch mit `rel: true` allein) `.items`, das sind heute wie künftig relative Häufigkeiten in Prozent als Array aus Paaren `([Buchstabe], Wert)` (Z. 140–147) | teilweise | L4 |
| `rel:` | entfällt | entfernt | siehe oben | – | Schalter wechselt den Rückgabetyp |
| `cetz:` | entfällt | entfernt | siehe oben | – | wie `rel` |

### 3.3 Chiffren

```typ
// alt (Z. 169, 331, 420, 472)
#let caesar(key: none, keyword: none, advanced: false) = {     // liefert Funktion oder Dictionary
#let vigenere(keyword, advanced: false) = {
#let rot13 = caesar(key: 13)
#let atbash(advanced: false) = {
// neu: eine Aufrufform chiffre(text, key: …)
#let caesar(text, key: none, inverse: false, ..deprecated) = { }     // key: int (Verschiebung) | str (Schlüsselwort); Pflichtangabe
#let caesar-table(key: none, ..deprecated) = { }                     // Schlüsseltabelle als content; key wie bei caesar
#let vigenere(text, key: none, inverse: false, ..deprecated) = { }   // key: int | str, zulässig ist nur str; Pflichtangabe
#let atbash(text, ..deprecated) = { }
#let rot13(text, ..deprecated) = { }
```

| Funktion | alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|---|
| `caesar` | `key: none` | `key: none` | unverändert (int oder str), Bedeutung eines Ziffern-Strings geändert | `key: "3"` (String-Literal nur aus Ziffern) → `key: 3`: heute ist das eine Verschiebung um 3 (`int(key)`, Z. 223), künftig wäre ein str ein Schlüsselwort. Laufzeit: ein str ohne Buchstaben wird Fehler ``informatik.caesar: `key: "3"` ist kein Schlüsselwort – für eine Verschiebung `key: 3` schreiben`` | teilweise (Literale) | AnhB; [Lücke] `key`; Pflichtangabe (Abschnitt 11 Nr. 4) |
| `caesar` | `keyword: none` | `key` | zusammengelegt | `keyword: "K"` → `key: "K"`; beide gesetzt: `keyword` gewinnt wie heute | ja | AnhB (eine Aufrufform); W8 Wert oder str |
| `caesar` | `advanced: false` | entfällt | entfernt | `caesar(key: k, advanced: true)` → Bericht; Ersatz: `.encode` → `caesar.with(key: k)`, `.decode` → `caesar.with(key: k, inverse: true)`, `.table` → `caesar-table(key: k)`, `.geheimtext-alphabet` → `caesar("ABCDEFGHIJKLMNOPQRSTUVWXYZ", key: k)` | nein | Schalter wechselt den Rückgabetyp (Inventar 1.5 Nr. 8) |
| `caesar` | Rückgabe-Funktion, 1 Argument | `caesar(text, key:)` | Aufrufform geändert | `caesar(key: 3)("abc")` → `caesar("abc", key: 3)`; alleinstehend `caesar(key: 3)` → `caesar.with(key: 3)` | teilweise | AnhB; § 4.4 Nr. 2 |
| `caesar` | Rückgabe-Funktion, 2. Argument `true` | `inverse: true` | benannt | `caesar(key: 3)("abc", true)` → `caesar("abc", key: 3, inverse: true)` | teilweise | § 4.4 Nr. 3 kein bool als Positionsargument; § 4.1 kein Imperativ als Parametername, deshalb nicht `decode`; [Lücke] `inverse` |
| `caesar` | Rückgabe-Funktion, 0 Argumente | `caesar-table(key:)` | eigene Funktion | `caesar(key: 3)()` → `caesar-table(key: 3)` | teilweise (Importzeile, siehe 3.0) | ein Rückgabetyp je Funktion |
| `caesar` | Rückgabe-Funktion, benannte Argumente (verschluckt) | Fehler | entfernt | – | nein | § 4.4 Nr. 6 |
| `caesar` | Ergebnis-Schlüssel `encode`, `decode`, `table`, `key`, `keyword`, `alphabet`, `geheimtext-alphabet` | entfallen | entfernt | siehe `advanced` | nein | – |
| `vigenere` | `keyword` (positional) | `key:` | umbenannt, benannt | `vigenere("K")("abc")` → `vigenere("abc", key: "K")`; `vigenere("K")` → `vigenere.with(key: "K")` | teilweise | AnhB; `key` hat in allen drei Chiffren den Typ int oder str (L6), `vigenere` weist int mit Abhilfe zurück (Abschnitt 11 Nr. 5) |
| `vigenere` | `advanced: false` | entfällt | entfernt | Bericht | nein | wie `caesar` |
| `vigenere` | 2. Argument `true` | `inverse: true` | benannt | wie `caesar` | teilweise | wie `caesar` |
| `vigenere` | Ergebnis-Schlüssel `encode`, `decode`, `keyword` | entfallen | entfernt | – | nein | – |
| `atbash` | `advanced: false` | entfällt | entfernt | `atbash()("abc")` → `atbash("abc")`; `atbash()` alleinstehend → `atbash` | ja | AnhB |
| `atbash` | Ergebnis-Schlüssel `encode`, `decode` | entfallen | entfernt | – | nein | selbstinvers |
| `rot13` | `rot13("abc")` | `rot13("abc")` | unverändert | – | – | – |
| `rot13` | `rot13("abc", true)` (Entschlüsseln per zweitem Positionsargument, heute über die Rückgabe-Funktion von `caesar` möglich) | `rot13("abc")` | Aufrufform geändert | zweites Argument löschen (ROT13 ist selbstinvers); zur Laufzeit meldet der Sink das überzählige Argument | ja | § 4.4 Nr. 3 |
| `rot13` | `rot13()` (Tabelle) | `caesar-table(key: 13)` | Aufrufform geändert | – | teilweise (Importzeile, siehe 3.0) | ein Rückgabetyp |

### 3.4 `text-to-blocks`, `ascii-table`

```typ
// alt (Z. 435, Z. 579)
#let text-to-blocks(text, block-size: 5) = {
#let ascii-table(ranges: (("a", "z"),), height: 5, variants: ("char", "dec"), colored: true) = {
// neu
#let text-to-blocks(text, character-count: 5, ..deprecated) = { }
#let ascii-table(
  domains: (("a", "z"),),          // array aus Einzelzeichen oder Paaren (von, bis)
  rows: 5,                         // int, Zeilen je Spaltenblock
  fields: ("character", "dec"),    // array aus "character" | "dec" | "bin" | "hex"
  colored: true,                   // W1
  ..deprecated,
) = { }
```

| Funktion | alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|---|
| `text-to-blocks` | `text` | `text` | unverändert | – | – | § 4.5 |
| `text-to-blocks` | `block-size: 5` | `character-count: 5` | umbenannt | – | ja | § 5.5: `-size` ist nie eine Zahl; G38 `<ding>-count`; [Lücke] `character` |
| `ascii-table` | `ranges` | `domains` | umbenannt | – | ja | G70 (ein Begriff, ein Wort); [Lücke] Plural |
| `ascii-table` | `height: 5` | `rows: 5` | umbenannt | – | ja | G37; § 5.5 `height` ist nie int |
| `ascii-table` | `variants: ("char", "dec")` | `fields: ("character", "dec")` | umbenannt, Wert umbenannt | `"char"` → `"character"`; `"dec"`, `"bin"`, `"hex"` bleiben; unbekannter Wert wird Fehler (heute `[?]`) | ja | G58 belegt `variants`; `fields` steht in der Wortliste; § 2.2 `char` ist keine erlaubte Abkürzung |
| `ascii-table` | `colored: true` | `colored: true` | unverändert | – | – | W1; [Lücke] `colored` |

---

## 4. operatoren 0.0.1 → 0.4.1

```typ
// alt (operatoren.typ Z. 46, Z. 79)
#let operator(name, text: "", bold: none) = {
#let operatoren-liste(fach: "Mathe", language: "de", operator-text-bold: false) = [
// neu
#let operator(
  name,                 // str, Schlüssel der Operatorenliste
  caption: none,        // W4 str | content, abweichender Anzeigetext
  bold: auto,           // W5 bool; auto = Einstellung der Operatorenliste
  ..deprecated,
) = { }
#let operatoren-liste(
  subject: "Mathe",     // str, Daten: "Mathe" | "Physik"
  language: "de",       // str, Daten: "de" | "it"
  bold: false,          // W1 Fettdruck aller operator-Aufrufe im Dokument
  ..deprecated,
) = { }
```

| Funktion | alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|---|
| – | `operator` | `operator` | unverändert | – | – | sprachgleich, läuft über die Wortliste B (AnhB B.1) |
| – | `operatoren-liste` | `operatoren-liste` | unverändert (Parameter geändert) | – | – | Baustein (2.1a, AnhB B.1): „Operatorenliste“ ist der Begriff der Fachanforderungen; L4 (`-list`) gilt nur für englische Namen (Konvention Anhang C) |
| `operator` | `name` (positional) | `name` | unverändert, nur str | `operator[Berechne]` → Fehler mit Abhilfe `operator("berechnen", caption: [Berechne])` | nein | § 4.4 Nr. 2; die content-Form bricht heute ab (Inventar 2.8) |
| `operator` | `text: ""` | `caption: none` | umbenannt, Default geändert | `""` → löschen; sonst Wert bleibt (41 Vorkommen außerhalb) | ja | AnhB; § 5.2 leerer Text ist `none` |
| `operator` | `bold: none` | `bold: auto` | Default geändert | `none` → löschen; `true`, `false` bleiben | ja | AnhB; § 5.1 „erbt" ist `auto`; [Lücke] `bold` |
| `operatoren-liste` | `fach: "Mathe"` | `subject: "Mathe"` | umbenannt | Werte bleiben (Daten, Dateinamen der CSV) | ja | G16, AnhB |
| `operatoren-liste` | `language: "de"` | `language: "de"` | unverändert | – | – | G84 |
| `operatoren-liste` | `operator-text-bold: false` | `bold: false` | umbenannt | – | ja | AnhB; ein Name für eine Einstellung |

States, Labels, Helfer:

| alt | neu | Art | Begründung |
|---|---|---|---|
| `operatoren-state` (exportiert), Schlüssel `"operatoren"` | `internal.used`, Schlüssel `"schule/operatoren/used@1"` | intern | § 7.3, AnhB, L4 Suffix `-state` |
| `operatoren-config-state` (exportiert), Schlüssel `"operatoren-config"` | `internal.settings`, Schlüssel `"schule/operatoren/settings@1"` | intern | § 7.3; `settings` steht in der Wortliste |
| State-Feld `text-bold` | `bold` | umbenannt | derselbe Name wie der Parameter |
| Label `<-def>` | `<schule-operatoren-overview>` | umbenannt | § 7.3; `overview` meint den Baustein `operatoren-liste`, für den 2.1b noch kein Parameterwort führt: Wortpaar beantragt, bis dahin [Lücke] (Abschnitt 11 Nr. 15) |
| Label `<{op}-def>` | `<schule-operatoren-{slug(op)}>` | umbenannt | § 7.3; `operator` verlinkt künftig auf dieses Label statt auf den Listenanfang. Die Operatornamen kommen aus der CSV und enthalten Umlaute und Leerzeichen (`abschätzen`, `begründen`, `grafisch darstellen`); § 2.3 verbietet Umlaute auch in Labels. `slug` = `internal.label-name(name)`: erst `lower` (wie heute, operatoren.typ Z. 90), dann die Umschrift aus § 8.4 (`ä ö ü ß` → `ae oe ue ss`), dann Leerzeichen → `-`; also `<schule-operatoren-begruenden>`, `<schule-operatoren-grafisch-darstellen>`. `operator` und `operatoren-liste` benutzen dieselbe Funktion, sonst zeigt der Link aus `operator("Berechnen")` ins Leere |
| – | `internal.label-name(name)` | neu, intern | eine Stelle für die Label-Normalisierung |
| `_render-operator-text(text, bold: false)` | `internal.render-operator(body, bold: false)` | intern | L19 |
| `_normalisiere-sprache(language)` | `internal.normalize-language(language)` | intern | § 2.1 |
| `_csv-dateiname(fach, language)` | `internal.csv-path(subject, language)` | intern | G60 |
| `_operatorenlisten-titel(language)` | `internal.overview-title(language)` | intern | § 2.1; [Lücke] `overview` wie beim Label (Abschnitt 11 Nr. 15) |
| CSV-Dateien `Mathe.csv`, `Physik.csv`, `Mathe-it.csv`, `Physik-it.csv` | unverändert | unverändert | Daten (§ 2.1) |

---

## 5. insert-a-word 0.0.3 → 0.4.1

```typ
// alt (lib.typ Z. 26, 40, 101)
#let iaword-neu() = {
#let iaword(body) = {
#let insert-a-word(hide-words: false, line-spacing: 1.5em, item-spacing: 1em, show-solution: false, uniform-gaps: false, body) = {
// neu
#let reset-iaword() = { }
#let iaword(body) = { }
#let insert-a-word(
  word-bank: true,        // W1 Wortkästen unter dem Text
  leading: 1.5em,         // W9, geht an par(leading:)
  spacing: 1em,           // length, Abstand der Wortkästen
  uniform-blanks: false,  // W1 alle Lücken so breit wie das längste Wort
  ..deprecated,
  body,
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `iaword-neu` | `reset-iaword` | umbenannt | – | ja | AnhB, § 4.1 `reset-`. Auch arbeitsblatt ruft die Funktion auf (arbeitsblatt/0.4.0/src/arbeitsblatt.typ Z. 619, je Fassung eines Bündels) und importiert sie ab 0.4.1 namentlich; `reset-iaword` ist damit paketübergreifende Schnittstelle (Abschnitt 9.3) |
| `iaword` | `iaword` | unverändert | – | – | `names.txt` |
| `iaword(body)` | `body` | unverändert | – | – | G79 |
| `insert-a-word` | `insert-a-word` | unverändert | – | – | Funktionsname = Paketname (Eigenname, § 2.1) |
| `hide-words: false` | `word-bank: true` | umbenannt, gewendet | `false` → löschen; `true` → `word-bank: false` | ja | § 4.3 (einer der drei einmalig gewendeten Schalter), AnhB |
| `line-spacing: 1.5em` | `leading: 1.5em` | umbenannt | – | ja | § 1.2 Schritt 2 Durchreichtest (`par(leading:)`); `line-height` (G64) wäre eine andere Größe; [Lücke] `leading` |
| `item-spacing: 1em` | `spacing: 1em` | umbenannt | – | ja | G34, AnhB |
| `show-solution: false` | entfällt | entfernt | `false` → löschen; `true` → löschen und Bericht (folgt `has-solutions()`; im Dokument `set-options(solutions: "in-place")`) | teilweise | § 6 abhängige Funktionen, AnhB |
| `uniform-gaps: false` | `uniform-blanks: false` | umbenannt | – | ja | G11: Parameterwort `blank` zum Baustein `luecke` (2.1b); [Lücke] `uniform`, `blanks` |
| `body` | `body` | unverändert | – | – | G79 |

States und Counter (heute alle exportiert, künftig nur in `internal`):

| alt (Variable = Schlüssel) | neu | Art |
|---|---|---|
| `iaword-list`, `"iaword-list"` | `internal.words`, `"schule/insert-a-word/words@1"` | intern |
| `iaword-solution`, `"iaword-solution"` | entfällt (wird nur geschrieben, nie gelesen) | entfernt |
| `iaword-counter`, `counter("iaword-counter")` | `internal.block-counter`, `"schule/insert-a-word/block-counter@1"` | intern |
| `iaword-uniform`, `"iaword-uniform"` | `internal.uniform`, `"schule/insert-a-word/uniform@1"` | intern |
| `iaword-start`, `"iaword-start"` | `internal.start`, `"schule/insert-a-word/start@1"` | intern |
| `iaword-show`, `"iaword-show"` | entfällt (ersetzt durch `aufgaben.has-solutions()`) | entfernt |
| Re-Exporte aus random (11 Namen) | entfallen; intern `import "@schule/random:0.4.1": shuffle` | entfernt |

---

## 6. random 0.0.1 → 0.4.1

```typ
// alt (random.typ Z. 3 bis 59)
#let default_seed = 42
#let m = calc.pow(2, 32) - 1
#let a = 48271
#let lcg(seed, steps: 100) = {
#let low_cminstd_rand(seed: default_seed) = {
#let low_cminstd_randint(start, end, seed: default_seed) = {
#let step_seed(cur_seed) = {
#let fisher_yates_shuffle(arr, seed) = {
#let rand(seed) = …
#let randint(start, end, seed) = …
#let shuffle(arr, seed) = …
// neu
#let default-seed = 42
#let random-number(seed: default-seed, ..deprecated) = { }           // float in [0, 1)
#let random-integer(domain, seed: default-seed, ..deprecated) = { }  // domain: (min, max), beide einschließlich
#let shuffle(items, seed: default-seed, ..deprecated) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `default_seed` | `default-seed` | umbenannt | – | ja | AnhB, § 2.4 |
| `rand(seed)` | `random-number(seed: default-seed)` | umbenannt, Parameter benannt mit Vorgabe (neu) | `rand(s)` → `random-number(seed: s)` | ja | AnhB; G85; § 4.4 Nr. 3; die Vorgabe gibt `default-seed` einen Zweck |
| `randint(start, end, seed)` | `random-integer(domain, seed: default-seed)` | umbenannt, Parameter zusammengelegt | `randint(a, b, s)` → `random-integer((a, b), seed: s)` | ja | AnhB; G70 (Grenzen nicht einzeln); L15 |
| `start`, `end` | `domain` (Array) | zusammengelegt | siehe oben | ja | G70 |
| `shuffle(arr, seed)` | `shuffle(items, seed: default-seed)` | Parameter umbenannt, `seed` benannt | `shuffle(x, s)` → `shuffle(x, seed: s)` | ja | AnhB; G78; § 2.2 `arr` ist keine erlaubte Abkürzung |
| `m` | `internal.modulus` | intern | – | nein | AnhB; § 2.4 kein einbuchstabiger Name |
| `a` | `internal.multiplier` | intern | – | nein | wie `m` |
| `lcg(seed, steps: 100)` | `internal.lcg(seed, steps: 100)` | intern | – | nein | AnhB |
| `low_cminstd_rand(seed: default_seed)` | `internal.minstd-number(seed)` | intern | – | nein | § 7.2, § 2.4 |
| `low_cminstd_randint(start, end, seed: default_seed)` | `internal.minstd-integer(domain, seed)` | intern | – | nein | wie oben |
| `step_seed(cur_seed)` | `internal.next-seed(seed)` | intern | – | nein | AnhB; § 2.2 `cur` |
| `fisher_yates_shuffle(arr, seed)` | `internal.fisher-yates-shuffle(items, seed)` | intern | – | nein | AnhB |

Der Sink `..deprecated` fängt die alte Positionsform: `shuffle(x, s)` und `random-integer(a, b, s)` melden die neue Schreibweise mit `seed:` bzw. `(a, b)`; `rand` und `randint` sind Stubs (Abschnitt 9.1).

Keine States. 18 Dokumente außerhalb importieren random 0.0.1 direkt; sie bleiben auf ihrem Pin.

---

## 7. energy-sketch 0.0.3 → 0.4.1

```typ
// alt (lib.typ Z. 134)
#let energy-sketch(energy-name, hide-letters: false, height: 3cm, gap: 0pt) = {
// neu
#let energy-sketch(
  labels,               // array aus str | content | none, führendes Hauptargument
  labeled: true,        // W1 Beschriftungen unter den Spalten
  height: 3cm,
  gutter: 0pt,          // length, Abstand zwischen den Spalten
  ..deprecated,
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `energy-sketch` | `energy-sketch` | unverändert | – | – | Funktionsname = Paketname (Eigenname) |
| `energy-name` (positional) | `labels` (positional) | umbenannt | – | – (positional) | G46, AnhB; Numerus |
| `hide-letters: false` | `labeled: true` | umbenannt, gewendet | `false` → löschen; `true` → `labeled: false` | ja | § 4.3, G46, AnhB |
| `height: 3cm` | `height: 3cm` | unverändert | – | – | G32 |
| `gap: 0pt` | `gutter: 0pt` | umbenannt | – | ja | G33 |
| `canvas`, `draw` (Re-Export aus cetz 0.5.2) | entfallen | entfernt | – | nein | L19; arbeitsblatt reicht `canvas`, `draw` selbst durch (§ 7.1) |
| `_energy-sketch-rows` | `internal.rows` | intern | – | nein | L19 |
| `_clamp-length(value, min: none, max: none)` | `internal.clamp-length(value, min: none, max: none)` | intern | – | nein | L19 |
| `_normalize-energy-names(energy-name)` | `internal.normalize-labels(labels)` | intern | – | nein | G46 |
| `_validate-energy-sketch-options(hide-letters, height, gap)` | entfällt, ersetzt durch `internal.check` | entfernt | – | nein | § 8.4 |
| `_resolve-layout(column-count, height, gap: 0pt, rows: …)` | `internal.resolve-layout(column-count, height, gutter: 0pt, rows: …)` | intern | – | nein | G33 |
| `_resolve-style(layout)`, `_column-geometry(layout, column-index)` | `internal.` gleicher Name ohne `_` | intern | – | nein | L19 |
| `_draw-column-grid`, `_draw-column-frame`, `_draw-column-label-line`, `_draw-column-label`, `_draw-energy-column(…, hide-letters: false)` | `internal.column-grid`, `column-frame`, `column-label-line`, `column-label`, `energy-column(…, labeled: true)` | intern | – | nein | § 4.1 kein Imperativ außerhalb der Verbliste |
| Layout-Schlüssel `gap` | `gutter` | umbenannt | – | – | G33; übrige interne Schlüssel bleiben, `total-width` entfällt (unbenutzt) |

Die sieben Prüfmeldungen Z. 11 bis 21 bekommen das Format `energy-sketch.energy-sketch: … – …` (§ 8.2) mit den neuen Namen.

---

## 8. Hilfspakete: mitziehen, unverändert lassen oder archivieren

„Archivieren" heißt: der Ordner bleibt liegen (alte arbeitsblatt-Versionen und gepinnte Dokumente verweisen darauf), `typst.toml` und README bekommen den Vermerk „archiviert, wird nicht weiterentwickelt", keine Zielversion, keine Doku, keine Tests. Gelöscht wird nichts.

| Paket | Entscheidung | Begründung |
|---|---|---|
| options 0.0.5 | archivieren | kompiliert unter Typst 0.15.1 nicht (`locate(func)`, String-Typvergleiche); nur von arbeitsblatt 0.0.2 bis 0.1.3 und aufgaben 0.0.1 importiert; teilt die State-Schlüssel `"@options"`/`"@config"` mit typopst. Nachfolger ist `aufgaben.internal.option-schema` (§ 6). |
| typopst 0.0.1 | archivieren | wie options; nur von arbeitsblatt 0.1.4 bis 0.1.9 und aufgaben 0.0.2 bis 0.0.4 importiert. |
| messwerttabellen 0.0.1 | archivieren | durch physik abgelöst, gleiche Namen mit unverträglichen Signaturen; 5 Dokumente und arbeitsblatt 0.1.7 bis 0.2.2 pinnen es. `max_wert_pro_tabelle` ist dort der zweite **Positions**parameter (`messwerttabelle(datensatze, max_wert_pro_tabelle, …)`, lib.typ Z. 224) und lässt sich deshalb nicht per Name abfangen. Wird ein solches Dokument gehoben, greift die AST-Regel `messwerttabelle(DS, N, …)` → `messwerttabelle(..DS, count: N, …)`; übersieht der Codemod die Stelle, meldet der Sink von `messwerttabelle` das Positionsargument, das kein Datensatz ist, mit der Abhilfe `count:` (2.4). 0.0.1 hat außerdem `lineare_regression(x_werte, y_werte)` und `berechnung(name, einheit, datensatz, formel, …)`; beide haben dieselbe Stellung der Argumente wie in physik 0.0.2 und laufen über dieselben AST-Regeln, `datensatz` hat dort noch kein `auto-einheit`. |
| flashcards 0.0.1 | archivieren | kompiliert nicht; übernommene Fremdvorlage ohne Bezug zu den Kernpaketen; ein Dokument. |
| gutachten 0.0.2 | unverändert lassen; `bewertung.typ` archivieren | der Entrypoint kompiliert und wird von 9 Dokumenten benutzt (108 Aufrufe), hat aber keine Verbindung zu den Kernpaketen; Konvention Anhang B gibt gutachten keine Zielversion. `bewertung.typ` ist eine verwaiste, nicht kompilierende Kopie aus klassenarbeit. Wer das Paket später anfasst, wendet die Konvention ganz an (die States `"aufgaben"`, `"punkte"`, `"schüler"` verletzen § 7.3 und § 2.3). |
| summify 0.1.0 | unverändert lassen | eigenständige Vorlage, API schon englisch und kebab-case, 31 Dokumente; kein Paket des Geltungsbereichs importiert sie. Getrennt zu beheben (0.1.1, keine Umbenennungsversion): `content(hide:)` überdeckt das Builtin `hide`, der Lernmodus bricht ab. Bei einer späteren Angleichung: `flipped` → `landscape` (G51), `title: ""` → `none`, `hide-content`/`hide` → ein Name, `align-content` → `align`. |
| typlace 0.0.2 | unverändert lassen | in sich geschlossen, durchgehend deutsch mit Umschrift und Paketpräfix in den Meldungen, in Gebrauch für Sitzordnungen; kein Kernpaket hängt daran. Die Leitregel (englische Bezeichner) träfe hier etwa 60 Namen ohne Nutzen für die Kernpakete; das wäre eine eigene Runde. |
| eduki 0.1.0 | unverändert lassen | Außenschnittstelle der eduki-Pipeline (`material.toml` pinnt eduki 0.1.0); API englisch; getrennt zu beheben: fehlendes `return` in `fill-height-with-text`. |
| angela 0.0.1 | unverändert lassen | Briefvorlage mit einem Parameter `body`; nichts umzubenennen, was Dokumente tippen. Der Logo-Name `"angela"` der Kernpakete ist davon unabhängig. |
| abbozza 0.0.1 | unverändert lassen | eigenständig, englisch, 4 Dokumente; hängt an cetz 0.3.4 und reicht es per `*` durch, das ist eine Pflegeaufgabe, keine Namensfrage. |

Mitgezogen wird keines der zehn Pakete.

---

## 9. Öffentliche Oberfläche ab 0.4.1

Jedes Paket: Einstieg `src/lib.typ`, nur namentliche Importe und Exporte, Modul `internal` (§ 7.1, § 7.2).

| Paket | exportiert | `fremdnamen.txt` | wird intern | Re-Exporte entfallen |
|---|---|---|---|---|
| mathematik | `graphen`, `steckbrief`, `kreisdiagramm`, `geogebra-cell`, `geogebra-algebra`, `geogebra-style`, `internal` | leer | `geogebra-palette`, `geogebra-menu-button`, `geogebra-approximate-button` | 11 Namen aus random; `umrechnungseinheit`; `teilaufgaben`, `tasks` |
| physik | `datensatz`, `messdaten`, `berechnung`, `messwerttabelle`, `lineare-regression`, `quadratische-regression`, `wurzel-regression`, `exponentielle-regression`, `potenz-regression`, `polynom-regression`, `schaltkreis`, `source`, `multimeter`, `lamp`, `ammeter`, `voltmeter`, `motor`, `generator`, `konstante`, `constants`, `internal` | leer | alle Helfer aus 2.8 | `zap`; `qty`, `unit`, `add-macros`, `znum`; 11 Namen aus random; `simple-source` |
| informatik | `bin-to-dec`, `dec-to-bin`, `hex-to-dec`, `dec-to-hex`, `haeufigkeitsanalyse`, `caesar`, `caesar-table`, `vigenere`, `atbash`, `rot13`, `text-to-blocks`, `ascii-table`, `internal` | leer | `mono` | 6 Namen aus blockst; `häufigkeitsanalyse-alt` |
| operatoren | `operator`, `operatoren-liste`, `internal` | leer | beide States, vier Helfer | – |
| insert-a-word | `insert-a-word`, `iaword`, `reset-iaword`, `internal` | leer | vier States und Counter | 11 Namen aus random |
| random | `default-seed`, `random-number`, `random-integer`, `shuffle`, `internal` | leer | `modulus`, `multiplier`, `lcg`, `minstd-number`, `minstd-integer`, `next-seed`, `fisher-yates-shuffle` | – |
| energy-sketch | `energy-sketch`, `internal` | leer | elf Helfer; der zwölfte `_`-Name `_validate-energy-sketch-options` entfällt (ersetzt durch `internal.check`) | `canvas`, `draw` |

Dazu exportiert jedes Paket seine abbrechenden Stubs (9.1), solange die Compat-Tabelle läuft.

### 9.1 Abbrechende Stubs alter Funktionsnamen

Ein Stub ist eine Funktion mit dem alten Namen, die jeden Aufruf mit ``<paket>.<alt>: `<alt>` heißt jetzt `<neu>` `` abbricht (§ 9.3). Er steht im Fachpaket in `src/removed.typ`; das Lint nimmt diese Datei von L1 und L27 aus, deshalb sind auch Namen mit Umlaut oder Unterstrich möglich. arbeitsblatt reicht genau die Stubs weiter, deren Namen es bisher durchreichte (`tabelle-arbeitsblatt.md` 4.3 verweist für diese Liste hierher).

Einen Stub bekommt nur ein Name, der sich ändert. Die Bausteine, die ihren Namen behalten (`graphen`, `steckbrief`, `kreisdiagramm`, `datensatz`, `messdaten`, `berechnung`, `messwerttabelle`, `schaltkreis`, `konstante`, `operatoren-liste`), haben keinen; ihre alten Parameter und Aufrufformen fängt der Sink (Lesart am Anfang). Die englischen Zwillinge bekommen ebenfalls keinen Stub: Es gab sie in keiner veröffentlichten Version, wer sie schreibt, bekommt Typsts „unknown variable" (§ 9.3).

| Paket | Stub → Meldung nennt | über arbeitsblatt durchgereicht |
|---|---|---|
| mathematik | – (alle drei Bausteine behalten ihren Namen; `tasks` hat seinen Stub in arbeitsblatt, nicht hier) | – |
| physik | `lineare_regression` → `lineare-regression`; `quadratische_regression` → `quadratische-regression`; `wurzel_regression` → `wurzel-regression`; `exponentielle_regression` → `exponentielle-regression`; `potenz_regression` → `potenz-regression`; `polynom_regression` → `polynom-regression`; `simple-source` → `source`; `amperemeter` → `ammeter` | alle. Die Meldungen zu `simple-source` und `amperemeter` nennen zusätzlich die Importzeile, solange arbeitsblatt `source` und `ammeter` nicht durchreicht |
| informatik | `häufigkeitsanalyse` → `haeufigkeitsanalyse`; `bin2dec` → `bin-to-dec`; `dec2bin` → `dec-to-bin`; `hex2dec` → `hex-to-dec`; `dec2hex` → `dec-to-hex`; `mono` → „gibt es nicht mehr – `raw("…")` schreiben" | alle sechs (`mono` steht schon in `tabelle-arbeitsblatt.md` 4.3) |
| operatoren | – (`operatoren-liste` behält seinen Namen) | – |
| insert-a-word | `iaword-neu` → `reset-iaword` | ja |
| random | `rand` → `random-number`; `randint` → `random-integer` | beide |
| energy-sketch | – | – |

Kein Stub, nur Eintrag in `regeln.json` (der Codemod ersetzt den Namen; wer ihn übersieht, bekommt Typsts „unknown variable"):

| Grund | Namen |
|---|---|
| Helfer, der nach `internal` wandert oder entfällt; § 9.3 zählt die Stubs auf und nennt keinen davon; kein Aufruf in Dokumenten bekannt | `auto_einheit_anwenden`, `count_decimal_places`, `p_messwerttabelle`, `_kopf-einheit`; `low_cminstd_rand`, `low_cminstd_randint`, `step_seed`, `fisher_yates_shuffle`; die vier `_`-Helfer von operatoren; die zwölf `_`-Namen von energy-sketch |
| entfällt ohne Nachfolgefunktion (§ 9.3) | `häufigkeitsanalyse-alt`; der Ersatz ist ein Feldzugriff auf das Ergebnis von `haeufigkeitsanalyse` (3.2), den der Codemod einsetzt |
| kein Aufruf, sondern ein Wert (ein Funktions-Stub gäbe bei `pk.h.wert` nur Typsts Meldung zum Feldzugriff; § 9.3 nennt `pk` ausdrücklich) | `pk`, `default_seed`, `multiplikatoren`, `geogebra-colors`, `operatoren-state`, `operatoren-config-state`, die sechs States und Counter von insert-a-word, `m`, `a` |
| Name gehört einem anderen Paket | `teilaufgaben` ist der Baustein aus aufgaben, mathematik definiert ihn nicht mehr; `tasks` ist der Stub in arbeitsblatt (`arbeitsblatt.tasks`, „heißt jetzt `teilaufgaben`"; § 9.3, `tabelle-arbeitsblatt.md` 1.10/4.3); aufgaben und mathematik haben keinen. Wer mathematik direkt importiert und `tasks` oder `teilaufgaben` ruft, bekommt Typsts „unknown variable“; diese Dokumente stellt der Codemod um (JSON `funktionen`) |
| unbenutzter Helfer | `geogebra-button`, `geogebra-approx-button`, `umrechnungseinheit`, `lcg` |

Die sechs Regressionen und `häufigkeitsanalyse` bekommen damit die „heißt jetzt"-Meldung, die der erste Entwurf ihnen wegen L1 versagt hatte: § 9.3 nennt sie ausdrücklich und nimmt `removed.typ` von L1 aus. `tabelle-arbeitsblatt.md` 4.3 ist daran anzugleichen (Abschnitt 11 Nr. 12).

### 9.2 Wie Dokumente die Namen bekommen

arbeitsblatt (und damit klassenarbeit) reicht die Fachpaket-Namen **namentlich** durch; maßgeblich ist die Liste in `tabelle-arbeitsblatt.md` 4.2, der auch `architektur-release.md` folgt. Die Aussage des ersten Entwurfs, kein Fachpaket-Name werde durchgereicht, ist zurückgenommen. Ein Dokument mit `#import "@schule/arbeitsblatt:0.4.1": *` bekommt also ohne eigene Importzeile:

| Paket | über arbeitsblatt (Stand `tabelle-arbeitsblatt.md` 4.2) | nicht über arbeitsblatt, eigene Importzeile nötig |
|---|---|---|
| mathematik | `graphen`, `steckbrief`, `kreisdiagramm`, `geogebra-algebra`, `geogebra-cell` | `geogebra-style` (auch heute nicht durchgereicht) |
| physik | `datensatz`, `messdaten`, `berechnung`, `messwerttabelle`, `constants`, die sechs Regressionen (`lineare-regression` …), `schaltkreis` | `source`, `multimeter`, `lamp`, `ammeter`, `voltmeter`, `motor`, `generator` (heute durchgereicht, arbeitsblatt/0.4.0/src/arbeitsblatt.typ Z. 24–36; in `tabelle-arbeitsblatt.md` unter `reexporte-entfallen`); `konstante` (wurde nie durchgereicht); `zap` kommt nicht mehr aus physik, sondern aus `@preview/zap:0.4.0` (2.0) |
| informatik | `bin-to-dec`, `dec-to-bin`, `hex-to-dec`, `dec-to-hex`, `haeufigkeitsanalyse`, `caesar`, `vigenere`, `atbash`, `rot13`, `ascii-table`, `text-to-blocks` | `caesar-table` (neu; fehlt in 4.2) |
| operatoren | `operator`, `operatoren-liste` | – |
| insert-a-word | `insert-a-word`, `iaword`, `reset-iaword` | – (4.2 nennt „die übrigen öffentlichen `iaword-*`"; es gibt keine, alle States sind intern) |
| random | `random-number`, `random-integer`, `shuffle`, `default-seed` | – |
| energy-sketch | `energy-sketch` | – |

Abgleich mit `tabelle-arbeitsblatt.md` 4.2, der dort nachzutragen ist (diese Tabelle ändert die Nachbartabelle nicht):

1. **`caesar-table`** in die informatik-Zeile aufnehmen. Sonst erzeugt der Codemod aus `caesar(key: 3)()` und `rot13()` in Dokumenten, die nur arbeitsblatt importieren, einen ungebundenen Namen. Bis dahin ergänzt die Codemod-Regel die Importzeile `#import "@schule/informatik:0.4.1": caesar-table` und ist deshalb „teilweise".
2. **Schaltkreis-Komponenten und `zap`**: `schaltkreis` wird durchgereicht, die Komponenten nicht; ein Schaltkreis ohne `source`, `lamp` usw. ist nicht zeichenbar. Entweder die sieben Komponenten und `zap` in 4.2 aufnehmen oder `schaltkreis` dort streichen. Bis dahin ergänzt der Codemod `#import "@schule/physik:0.4.1": source, lamp, …` nach den benutzten Namen und, wenn `zap.` vorkommt, `#import "@preview/zap:0.4.0"` (2.0, Nachtrag in Abschnitt 14).
3. **`konstante`** ist bewusst nicht in 4.2 (eigene Konstanten sind selten; wer sie braucht, importiert physik).
4. Der Zusatz „die übrigen öffentlichen `iaword-*`" in 4.2 ist gegenstandslos.

Übrige entfallene Namen:

| Name | Weg |
|---|---|
| `teilaufgaben` (früher eigene Kopie in mathematik, dort auch als `tasks`) | Baustein aus aufgaben, über arbeitsblatt oder klassenarbeit; `tasks` ist Stub |
| `a`, `m`, `lcg` usw. | gar nicht mehr; `random.internal` ist keine zugesicherte Schnittstelle |
| `qty`, `unit`, `num` | aus arbeitsblatt (`fremdnamen.txt`, § 7.1) oder direkt aus fancy-units |
| `scratch`, `blockst` usw. | `#import "@preview/blockst:<version>": scratch` (so schon in 47 Dokumenten) |
| `canvas`, `draw` | aus arbeitsblatt (`fremdnamen.txt`) oder direkt aus cetz |
| `mono` | `raw("…")` oder `text(font: …)` |
| `zap` | `#import "@preview/zap:0.4.0"` im Dokument (physik reicht es ab 0.5.0 nicht mehr weiter) |

Dokumente, die ein Fachpaket direkt importieren (18 Dokumente random 0.0.1, 5 messwerttabellen 0.0.1), bekommen beim Heben die namentliche Importzeile des Fachpakets auf 0.4.1.

### 9.3 Pins zwischen den Paketen ab 0.4.1

| Paket | importiert | Zweck |
|---|---|---|
| mathematik | `@schule/physik:0.4.1` (`internal`) | Vorsatz-Faktor für `datasets`; der Pin auf aufgaben 0.1.2 und der Import von random entfallen |
| physik | `@schule/random:0.4.1` (`random-number`) | `berechnung(error:)` |
| insert-a-word | `@schule/random:0.4.1` (`shuffle`), `@schule/aufgaben:0.4.1` (`has-solutions`) | Wortbank mischen; Lösungen zeigen |
| informatik, operatoren, random, energy-sketch | kein `@schule`-Paket | – |
| arbeitsblatt (Gegenrichtung) | aus insert-a-word 0.4.1 namentlich `reset-iaword` (neben `insert-a-word`, `iaword`) | arbeitsblatt ruft `iaword-neu()` selbst auf, je Fassung eines Bündels (arbeitsblatt/0.4.0/src/arbeitsblatt.typ Z. 619; Docstring insert-a-word lib.typ Z. 23). `reset-iaword` ist damit paketübergreifende Schnittstelle und nicht nur ein Dokumentname; mit `tabelle-arbeitsblatt.md` abzugleichen |

### 9.4 States, Counter, Labels im Überblick

| Paket | alt | neu |
|---|---|---|
| operatoren | `state("operatoren")`, `state("operatoren-config")`, `<-def>`, `<{op}-def>` | `"schule/operatoren/used@1"`, `"schule/operatoren/settings@1"`, `<schule-operatoren-overview>` ([Lücke] `overview`, Abschnitt 11 Nr. 15), `<schule-operatoren-{slug(op)}>` mit `slug` = `internal.label-name` (Abschnitt 4) |
| insert-a-word | `"iaword-list"`, `"iaword-solution"`, `counter("iaword-counter")`, `"iaword-uniform"`, `"iaword-start"`, `"iaword-show"` | `"schule/insert-a-word/words@1"`, –, `"schule/insert-a-word/block-counter@1"`, `"schule/insert-a-word/uniform@1"`, `"schule/insert-a-word/start@1"`, – |
| mathematik, physik, informatik, random, energy-sketch | keine | keine |

### 9.5 Feste Gestaltung

Theme-Schlüssel gibt es in den sieben Paketen nicht (kein Paket liest das Theme-Dictionary). Die folgende Gestaltung ist fest verdrahtet und bleibt es in dieser Runde; eine Anbindung an `theme` wäre eine neue Funktion, keine Umbenennung:

| Paket | fest |
|---|---|
| mathematik | Zehn-Farben-Palette von `graphen` (L128–139) und die Palette von `kreisdiagramm`; „New Computer Modern Sans Math" und die GeoGebra-Farben (`internal.geogebra-palette`) |
| physik | Tabellenfarben in `messwerttabelle`; Strichstärke `.8pt` und Schriftgröße `12pt` der Schaltkreis-Komponenten (schaltkreise.typ) |
| informatik | „SF Mono" (`internal.mono`); Säulenfarbe `#008000` im Diagramm von `haeufigkeitsanalyse` (lib.typ Z. 112–115); Spaltenfarben und Grautöne in `ascii-table` (Z. 601–620) |
| insert-a-word | Sechs-Farben-Palette der Wortkästen, `inset: 8pt`, `radius: 4pt`, Lösungsfarbe `red`, Linienfarbe `luma(130)` (lib.typ Z. 66–72, 106–113, 138–139) |
| operatoren, random, energy-sketch | keine Farben oder Schriften außer Schwarz und der Dokumentschrift |

---

## 10. Im Zuge der Umbenennung zu behebende Fehler und Altlasten (nur API)

mathematik (`mathematik/0.0.2/mathematik.typ`):

| Fundstelle | Befund | Behebung in 0.4.1 |
|---|---|---|
| L1 | `import "@schule/random:0.0.1": *` exportiert `m`, `a` und neun weitere Namen, keiner wird benutzt | Import streichen |
| L2 | `umrechnungseinheit` wird ungewollt öffentlich | über `physik.internal` |
| L23–61, L39 | `teilaufgaben`: Absturz ohne Inhalt, `numbering` wirkungslos, fester Pin auf aufgaben 0.1.2 | eigene Kopie entfällt; der Baustein `teilaufgaben` kommt aus aufgaben |
| L115, L812 | benannte Argumente gehen ungeprüft an `plot.plot()` und können alles überschreiben | Sink prüfen, Fehler |
| L303–305 | `stroke` zusammen mit `color` stürzt ab | `accent` setzt die Farbe des stroke, auch wenn er selbst `paint` nennt (wie bisher `color`, L303–305); nur der Absturz bei `stroke: red + 2pt` entfällt. Geändert am 2026-11-15, siehe Nachtrag „Abnahme mathematik 0.5.0“ |
| L686–713 | ausdrückliche Angabe der Vorgabewerte (`x: (-5, 5)`, `step: 1`, `x-label: [$x$]`) wird zusammen mit `datensätze` still überschrieben | Vorgabe `auto`; der Codemod löscht die Literale, damit das PDF gleich bleibt |
| L383 | `x: auto` mit `fills` und `domain: "auto"` stürzt ab | `domain: auto` wird vor der Schnittpunktsuche aufgelöst |
| L413–417 | `marks: (1, 2)` wird still verworfen | Fehler mit Abhilfe `((at: (1, 2)),)` |
| L428–476, L851 | unbekannte Formen in `marks` und ein `label` falschen Typs werden still ignoriert | Fehler |
| L687–715 | Vergleich mit den Vorgaben als Sentinel | Vorgabe `auto` für `domain`, `step`, `labels` |
| L861–886, L969–987 | Lage einer Beschriftung dreifach verschieden benannt, Kürzel bei `marks` vertikal als Anker gelesen; unbekannte Werte der Kurvenbeschriftung ergeben eine Mischform | ein Parameter `position` mit ausgeschriebenen Werten; Abbildung erhält das heutige Bild (am Code bestätigt, am PDF **[prüfen]**); unbekannte Werte werden Fehler |
| L1247 | Pivot-Schwelle fest `1e-10`, Parameter wird ignoriert | `tolerance` benutzen |
| L1249–1256 | Fehlerfall als Dictionary mit anderer Schlüsselmenge | Abbruch über `internal.fail` |
| L1374, L1445, L1609 | Koeffizienten nur `a` bis `h`, der sechste heißt `f` wie die Funktion | `coefficients`-Dictionary; die Buchstabenfolge über `h` hinaus und der Zusammenfall mit `f` sind beim Umbau festzulegen |
| L1136–1154 | `steckbrief("f(0)=0,5")` scheitert am Dezimalkomma, `graphen` versteht es | Komma annehmen |
| L1719 | `mode: "percent"` rechnet nicht in Prozent um | Name `percent` beschreibt nur das Zeichen; im Docstring festhalten oder Anteile wirklich berechnen (Entscheidung des Autors, ändert sonst das PDF) |
| L1776–1784 | unbekannte benannte Argumente an `kreisdiagramm` werden verschluckt; `colors` wirkt, steht aber nirgends | Sink prüfen; `accents` deklarieren |
| L1802, L1811 | `geogebra-colors.button` unbenutzt | Schlüssel entfällt |
| L1005–1006, L73, L94, L1631–1635 | Docstrings nennen falsche Typen und unvollständige Schlüssel | L26 Docstring = Signatur |

physik (`physik/0.0.2/`):

| Fundstelle | Befund | Behebung |
|---|---|---|
| `lib.typ` 1–5 | vier `*`-Importe reichen 16 fremde und 13 interne Namen durch | namentliche Exporte |
| `messwerttabellen.typ` 5–8 | `add-macros` wirkungslos, `"ohm"` erscheint wörtlich | Ersetzung in `internal.header-unit` |
| 19, 45, 212 | `prefix: "1"` als Sentinel, daneben `""` und `"e14"` | `none`, `auto`; `"e<n>"` bleibt als dokumentierter Wert |
| 19 gegen 212 | `auto-einheit` mit verschiedener Vorgabe | bleibt verschieden, aber sichtbar als `prefix: none` und `prefix: auto` |
| 93–101, 257–264, 328–335 | Vorsatz-Erkennung ohne Einheitenkenntnis (`"m/s"`, `"mol"`, `"Pa"`, `"min"` werden skaliert; `"mkg"`) | Erkennung nur gegen eine Liste bekannter Einheiten; berührt die Bedeutung von `unit` und `prefix`, vor der Freigabe klären |
| 284–293, 338 | `berechnung` bricht bei leeren Werten und bei `messdaten` ab | `none` und leere Zellen durchreichen |
| 343 | `fehler: 5` wirft einen Typfehler, Vorgabe ist int | `error: 0%`, Typprüfung mit Abhilfe |
| 424–429 | `header` mit zu vielen Einträgen zerstört die Tabelle | Längenprüfung |
| 501–520 | drei Eingabeformen, benannte Argumente verschluckt | eine Form, Sink geprüft |
| 404 | tablex 0.0.9 | eingebaute `table` |
| `regressionen.typ` 118–146 | Vorzeichen des führenden Koeffizienten geht verloren, `y-name` unbenutzt | beim Umbau der Formatierer beheben |
| 221 | keine Prüfung auf identische x-Werte | Meldung wie bei den anderen Regressionen |
| 228, 280 gegen 568 | führender Term mit fester Schwelle `1e-20` statt des Parameters | `tolerance` |
| 237, 290, 353, 430, 499, 606 | Koeffizienten je Regression verschieden benannt und geordnet | offen: Buchstaben bleiben als Daten unter `coefficients`; Vereinheitlichung wäre eine fachliche Entscheidung |
| `schaltkreise.typ` 29–30 | englische Meldungen | deutsch, `internal.fail` |
| 85–94 | Docstring von `multimeter` steht über `simple-source` | mit dem Entfall von `simple-source` richten |
| `konstanten.typ` 18–24, 47 | `beschreibung` wird verworfen, `h_eV` und `name` fehlen im Docstring | Parameter entfällt; Docstring |
| mathematik L641/645 | `umrechnungseinheit(1, prefix)` liefert Faktor 1 statt des Vorsatz-Faktors | `physik.internal.prefix-factor(prefix)` |

informatik (`informatik/0.0.2/lib.typ`):

| Fundstelle | Befund | Behebung |
|---|---|---|
| Z. 1–5 | Kopfkommentar nennt ein anderes Paket und andere Namen als der Import; Pin `@preview/blockst:0.1.0` veraltet | Re-Export entfällt |
| Z. 15–36, 524–548 | ungültige Ziffern und negative Zahlen werden still übergangen | Fehler mit Abhilfe |
| Z. 140 | `häufigkeitsanalyse-alt` wechselt den Rückgabetyp über zwei Schalter | entfällt |
| Z. 169, 331, 472 | `advanced` wechselt den Rückgabetyp; vier Aufrufformen für vier Chiffren | eine Aufrufform |
| Z. 218–220 | `caesar(keyword: "123")` fällt still auf das unveränderte Alphabet zurück | Fehler wie bei `vigenere` |
| Z. 280, 285, 390 | Entschlüsseln per positionalem `true`, benannte Argumente verschluckt | `inverse: true`, Prüfung |
| Z. 434, 440 | `text-to-blocks("")` stürzt ab; Docstring nennt `content`, geliefert wird `str` | leeren Text abfangen; Docstring |
| Z. 583–591, 630–632, 662–664 | ungültige Bereiche und unbekannte Spalten werden still ignoriert | Fehler |
| README.md | zerschossen, nennt `@preview/schule-informatik:0.0.1` und `hf-diagramm` | neu schreiben |

operatoren (`operatoren/0.0.1/operatoren.typ`):

| Fundstelle | Befund | Behebung |
|---|---|---|
| Z. 38, 48 | `#operator[Berechne]` aus Docstring und Doku bricht ab; Doku benutzt Imperative, die CSV Infinitive | `name` ist str; Fehlermeldung nennt `operator("berechnen", caption: [Berechne])` |
| Z. 56, 58, 95 | Link zeigt immer auf den Listenanfang; ohne Operatorenliste „label does not exist" | Link auf das Label des Operators; ohne Operatorenliste kein Link |
| Z. 79, 82 | die globale Einstellung `bold` lässt sich nur über die Operatorenliste setzen | bleibt so (AnhB), im Docstring festhalten |
| Z. 83, 95 | unbekanntes Fach oder unbekannter Operator gibt eine Compiler-Meldung | `internal.fail` mit Liste der erlaubten Werte |
| Z. 66 | Docstring behauptet, die CSV komme aus dem Dokumentverzeichnis | Docstring richten |
| Z. 80 | tablex 0.0.9 | eingebaute `table` |

insert-a-word, random, energy-sketch:

| Fundstelle | Befund | Behebung |
|---|---|---|
| `insert-a-word/0.0.3/lib.typ` Z. 1 | `*`-Import reicht elf random-Namen durch | namentlich `shuffle` |
| Z. 5, 118–121 | State `iaword-solution` wird nur geschrieben; `insert` kann fehlschlagen | State entfällt |
| Z. 101 | `show-solution` ist nicht an die Lösungsoption gekoppelt | folgt `has-solutions()` |
| Z. 76–77 | erledigtes TODO mit auskommentiertem Code | löschen |
| `random/0.0.1/random.typ` Z. 8–9 | `m`, `a` öffentlich; Kommentar widerspricht dem Code | `internal` |
| Z. 24, 32 gegen 57–59 | `seed` einmal benannt mit Vorgabe, einmal positional | überall benannt mit `default-seed` |
| `energy-sketch/0.0.3/lib.typ` Z. 1 | `canvas`, `draw` werden mit exportiert | namentlicher Import ohne Re-Export |
| Z. 3–109 | zwölf `_`-Namen sind über `*` öffentlich | elf nach `internal`, `_validate-energy-sketch-options` entfällt |
| `arbeitsblatt/0.4.0/src/arbeitsblatt.typ` Z. 4 | Pin auf energy-sketch 0.0.2 (cetz 0.3.1) | Pin heben (§ 9.4 Nr. 1) |

---

## 11. Lücken in Glossar und Wortlisten

Begriffe ohne Glossarzeile (nach der Leitregel entschieden):

| Begriff | gewähltes Wort | wo |
|---|---|---|
| Zahlschreibweise | `notation` mit `"decimal"`, `"scientific"`, `"fraction"` | `steckbrief`, Regressionen |
| Nullschwelle | `tolerance` | `steckbrief`, Regressionen (Anhang B nennt fälschlich `digits`) |
| Zeichen (Formelzeichen, Punktsymbol, Schaltzeichen) | `symbol` | `konstante`, `constants.*`, `marks[]`, `datasets[]`, Wert `kind: "symbol"` von `source` |
| Stützstellen eines Graphen | `sample-count` | `graphen` |
| Gitterlinien eines Diagramms | `grid-lines` | `graphen` |
| Abstand einer Beschriftung von ihrem Punkt | `distance` | `graphen` (`labels[]` eines Graphen, `marks[]`) |
| Füllfläche unter oder zwischen Graphen | `areas` | `graphen` |
| Schnittpunkt-Grenzen | `domain: "intersections"` | `graphen` |
| Farbliste eines Diagramms | `accents` | `kreisdiagramm` (wie `subject-accents`) |
| Koeffizienten | `coefficients` (Dictionary mit Formelzeichen als Daten) | `steckbrief`, Regressionen |
| SI-Vorsatz | `prefix` | `datensatz`, `messdaten`, `berechnung` |
| Zufälliger relativer Fehler | `error` | `berechnung` |
| Rechenvorschrift | `formula` | `berechnung` |
| Stromart | `current` mit `"direct"`, `"alternating"` | `source` |
| Umkehrung einer Chiffre | `inverse` | `caesar`, `vigenere` |
| Schlüssel einer Chiffre | `key` (int oder str) | `caesar`, `caesar-table`, `vigenere` |
| Fettdruck | `bold` | operatoren (steht in Anhang B, fehlt in der Wortliste) |
| Zeilenabstand eines Absatzes | `leading` (Typst-Wort) | `insert-a-word` |
| Lagewerte | `"left"`, `"right"` und die vier Ecken | `position`, `legend-position` |

Fehlende oder widersprüchliche Regeln der Konvention (die Tabelle setzt die jeweils genannte Entscheidung voraus; `KONVENTION.md` wurde nicht geändert):

1. **G77 sperrt `symbol` pauschal.** Gebraucht wird eine Glossarzeile „Zeichen (Formelzeichen, Punktsymbol, Schaltzeichen) → `symbol`" und die Einengung von G77 auf „Symbol vor einem Text → `icon`". `symbol` steht in `dir(std)`; als Parameter (`konstante(symbol:)`) braucht es deshalb zusätzlich die Aufnahme in die Liste von § 4.5 (im Rumpf dann `std.symbol`). Die Alternative `math` des ersten Entwurfs bräuchte denselben Nachtrag (`math` steht ebenfalls in `dir(std)` und besteht den Durchreichtest nicht), überdeckte im Rumpf `math.frac` und hieße bei den Regressionen etwas anderes (ganze Gleichung). Lehnt der Autor den Nachtrag ab, gibt es für das Formelzeichen kein regelkonformes Wort.
2. **G71 gegen L10.** G71 schreibt `step` (Schrittweite) und `steps` (Schrittzahl) vor; stehen beide in einer Signatur, verletzen sie § 4.2/L10 (Abstand 1). Diese Tabelle weicht für die Stützstellen auf `sample-count` (G38) aus. G71 braucht den Zusatz „nie beide in einer Signatur; dann `<ding>-count`".
3. **Achsenbezeichner `x`, `y` gegen L10 und L6.** § 2.4 erlaubt sie als Parameter in mathematik und physik; als Paar haben sie Abstand 1 (L10), und `x` ist in `datasets[]` und bei den Regressionen eine Zahlenreihe, in der Kurvenbeschriftung eine einzelne Zahl (L6). Gebraucht wird je eine ausdrückliche Ausnahme für die Achsenbezeichner. Als Segment (`x-domain` usw.) kommen sie nach der Umstellung auf W7 nicht mehr vor; die im ersten Entwurf beantragte L5-Ausnahme entfällt.
4. **Benannte Pflichtangabe hat keine Form W1 bis W9.** `x:`, `y:`, `degree:` der Regressionen und `key:` der Chiffren sind benannt (L15) und Pflicht. Vorgabe ist `none`, obwohl `none` laut § 5.1 immer „nichts" heißt und W4 „darf fehlen" bedeutet. Gebraucht wird eine Form „Pflichtangabe, benannt": Vorgabe `none`, Typkommentar „Pflicht", Abbruch über `internal.fail` mit Beispielaufruf.
5. **`key` hat zwei Typen.** Bei `caesar` und `caesar-table` int (Verschiebung) oder str (Schlüsselwort), bei `vigenere` nur str. Für L6 wird `key` einheitlich als „int | str" geführt; `vigenere` weist int mit Abhilfe zurück.
6. **`current` hat zwei Bedeutungen.** In der Wortliste steht es als Wert „aktuell" (`select: "current"`); als Parametername von `source` meint es die Stromart (unverändert aus dem Bestand). Gebraucht wird die Glossarzeile „Stromart → `current`", sonst bliebe nur `current-kind` neben `kind`.
7. **§ 4.4 Nr. 5 kennt als Durchreichung nur `page-settings`.** Die zap-Komponenten (`source`, `lamp`, …) müssen die Signatur `(name, node, ..args)` von zap behalten, sonst lassen sie sich nicht neben zaps eigenen Komponenten benutzen. Eine benannte Ausnahme für Komponenten fremder Zeichenumgebungen fehlt (auch L15, L16).
8. **W8 kennt als Name nur `str`**; der Palettenindex (`color: 2`) hat keine zulässige Form und entfällt.
9. **Funktionsname gleich Paketname** (`insert-a-word`, `energy-sketch`) ist nicht als Ausnahme von L2 genannt; die Segmente `insert`, `a`, `word`, `energy`, `sketch` stehen in keiner Liste.
10. **Anhang B sagt `precision:` → `digits:`**; in den Regressionen und in `steckbrief` ist `precision` aber eine Schwelle. Anhang B braucht dort `tolerance`.
11. **§ 7.1 nennt für die Fachpakete keine `fremdnamen.txt`**; physik braucht `zap`. § 7.1 nennt außerdem als Export von arbeitsblatt nur Eigenes (Bausteine und englische Namen), `internal`, acht Fremdnamen und die Stubs; die namentliche Durchreichung der `@schule`-Fachpakete (`tabelle-arbeitsblatt.md` 4.2, dort [Lücke 2]) steht nicht in § 7.1 und in L19.
12. **Stubs und L1: erledigt.** § 9.3 nimmt `src/removed.typ` von L1 und L27 aus und nennt `lineare_regression` (mit den fünf weiteren) und `häufigkeitsanalyse` ausdrücklich als abbrechende Stubs; Abschnitt 9.1 folgt dem. `tabelle-arbeitsblatt.md` 4.3 hatte Stubs für Namen, die § 2.4 verletzen, verneint und ist anzugleichen. Nicht geregelt bleibt, ob auch `häufigkeitsanalyse-alt` und die Helfer mit Unterstrich einen Stub bekommen; diese Tabelle gibt ihnen keinen.
13. **§ 9.2 hat kein Feld für Rückgabe-Schlüssel, State-Schlüssel und Labels.** Diese Tabelle benutzt dafür wie `tabelle-arbeitsblatt.md` die Zusatzfelder `rueckgabe`, `states`, `labels`.
14. **In § 2.2 gestrichene Wörter, die in den Klammern weiter gebraucht werden.** Mit den englischen Funktionsnamen sind 21 Wörter aus `words-en.txt` gefallen. Zwei davon sind Ergebnis-Schlüssel dieser Tabelle und kommen mit eigenem Diff zurück: `function` (`steckbrief`, Regressionen) und `chart` (`haeufigkeitsanalyse`). `overview` steht nur noch im Label `<schule-operatoren-overview>` und im internen Helfer `overview-title`; es fehlt nicht nur in der Wortliste, sondern als Wortpaar (Nr. 15). `measurement` und `power` kommen nur in `internal` vor (`render-measurement-table`, `x-power`) und brauchen keinen Eintrag, solange L2 interne Namen nicht prüft. `regression` ist ein anderer Fall: Es ist Segment von sechs Namen in `bausteine-de.txt`, darf deshalb nach L27(b) nie in `words-en.txt` stehen und nach L27(a) in keinem englischen Funktionsnamen vorkommen, und § 7.2 verlangt auch für interne Namen Englisch. Der interne Helfer heißt deshalb `internal.fit` (Abschnitt 2, 2.8, JSON); `fit` braucht denselben bedingten Eintrag wie `measurement` und `power`.
15. **Für `operatoren-liste` fehlt das Parameterwort.** Konvention 2.1b führt für den Baustein keines („noch keines vergeben“), L27(d) verlangt aber für jedes Segment, das einen Baustein meint, das Wort aus `wortpaare.json`, und L27(a) bezieht den `<name>`-Teil von Labels ein. Das Label `<schule-operatoren-overview>` und der Helfer `internal.overview-title` meinen den Baustein. Beantragt: Wortpaar `operatoren-liste` ↔ `overview` in 2.1b und `wortpaare.json`, dazu Wiederaufnahme von `overview` in `words-en.txt` (in § 2.2 gestrichen). Bis dahin sind Label und Helfer [Lücke].

Neue Einträge für `words-en.txt` (Gruppe T): `leading`, `symbol`.
Neue Einträge (Gruppe N): `accents` `alternating` `ammeter` `approximate` `areas` `bars` `between` `blanks` `bold` `cell` `character` `chart` `coefficients` `colored` `condition` `conditions` `counts` `decimal` `direct` `distance` `domains` `equations` `error` `flipped` `formula` `fraction` `frequencies` `function` `generator` `intersections` `inverse` `key` `lamp` `last` `left` `major` `marks` `menu` `minor` `motor` `multimeter` `node` `notation` `percent` `prefix` `right` `row` `sample` `scientific` `source` `style` `system` `term` `tolerance` `uniform` `voltmeter`.
Gegenüber dem ersten Entwurf entfallen: `fills`, `mark`, `terminals`.
Neue Einträge für `names.txt`: `ansatz`, `algebra` (GeoGebra-Ansicht), `zap`, `insert-a-word`, `energy-sketch`. `dc` und `ac` entfallen (die Werte heißen `"direct"`, `"alternating"`; `names.txt` ist für Eigennamen und Lehnwörter, nicht für Abkürzungen, und die Abkürzungsliste in § 2.2 ist abschließend).

---

## 12. Maschinenlesbarer Anhang

Lesart (dieselbe wie in `tabelle-arbeitsblatt.md` Abschnitt 8 und `tabelle-klassenarbeit.md`, damit sich die Anhänge zu der einen `regeln.json` aus § 9.2 zusammenführen lassen):

- Schlüssel in `parameter`, `werte` und `rueckgabe` sind die **alten** Funktionsnamen, mit dem Paket qualifiziert (`paket.altname`), so wie der Codemod sie im Dokument sieht; `funktionen` bildet auf die neuen ab. Ziele in `internal` heißen `paket.internal.name`.
- Bausteine, die ihren Namen behalten (`mathematik.graphen`, `physik.datensatz`, `operatoren.operatoren-liste` …), stehen nicht in `funktionen`; ihr Schlüssel ist alter und neuer Name zugleich. In `funktionen` stehen von den Bausteinen nur die Umschriften (sechs Regressionen, `häufigkeitsanalyse`) und der Paketwechsel `mathematik.teilaufgaben` → `aufgaben.teilaufgaben` (Name unverändert). Ein englischer Bausteinname kommt im Anhang nirgends als Ziel vor; `sig.py --lint` prüft das gegen `zwillinge.txt` (L27).
- Schlüssel in Dictionary-Einträgen heißen `funktion.parameter[]` mit dem **alten** Parameternamen (`mathematik.graphen.fills[]`); `args[]` sind die Positionsargumente.
- Ziel `a.b` = Schlüssel `b` im Wert des Parameters `a` (W7 oder Ergebnis-Dictionary); Ziel als Array = wird zu mehreren Argumenten oder Schlüsseln; `labels[0]` = erster Eintrag des Arrays.
- In `werte` steht `"*"` für jeden anderen Wert, `null` für „Argument löschen", `$v` für den alten Wert; ein Verweis `"@paletten/…"` zieht die dort stehende Abbildung heran (gilt nur für int-Literale).
- Jeder alte Name steht an genau einer Stelle: unter `parameter`/`rueckgabe` (Meldung „heißt jetzt") **oder** unter `entfernt` („gibt es nicht mehr"), nie an beiden. Ein `werte`-Eintrag zu einem entfernten Namen ist nur die Löschregel des Codemods.
- `kontext` enthält die Regeln, die sich nicht als Namens- oder Wertersetzung schreiben lassen (Feld `context` in § 9.2, nur Codemod). Ein Kontext-Eintrag geht einer `parameter`- oder `werte`-Regel desselben Namens vor; `"nur-kontext": true` heißt, dass die Namen nie als reine Ersetzung angewandt werden dürfen (deshalb fehlen `position` und `anchor` von `marks[]` in `parameter`).
- Die Zusatzfelder `neu`, `stubs`, `import-noetig`, `rueckgabe`, `paletten`, `states`, `state-felder`, `labels` ergänzen das Schema aus § 9.2 (wie in `tabelle-arbeitsblatt.md`).
- Positionsparameter stehen nicht in `parameter`: ein Positionsparameter kann in Typst nicht benannt übergeben werden, ein Abfang per Name löste nie aus. Ihre Umstellung steht in der AST-Tabelle unter dem JSON; zur Laufzeit meldet der Sink überzählige Positionsargumente mit der neuen Aufrufform.

```json
{
  "funktionen": {
    "mathematik.teilaufgaben": "aufgaben.teilaufgaben",
    "mathematik.tasks": "aufgaben.teilaufgaben",
    "mathematik.geogebra-colors": "mathematik.internal.geogebra-palette",
    "mathematik.geogebra-button": "mathematik.internal.geogebra-menu-button",
    "mathematik.geogebra-approx-button": "mathematik.internal.geogebra-approximate-button",
    "physik.lineare_regression": "physik.lineare-regression",
    "physik.quadratische_regression": "physik.quadratische-regression",
    "physik.wurzel_regression": "physik.wurzel-regression",
    "physik.exponentielle_regression": "physik.exponentielle-regression",
    "physik.potenz_regression": "physik.potenz-regression",
    "physik.polynom_regression": "physik.polynom-regression",
    "physik.simple-source": "physik.source",
    "physik.amperemeter": "physik.ammeter",
    "physik.pk": "physik.constants",
    "physik.multiplikatoren": "physik.internal.prefix-factors",
    "physik.umrechnungseinheit": "physik.internal.convert-unit",
    "physik.auto_einheit_anwenden": "physik.internal.apply-auto-prefix",
    "physik.p_messwerttabelle": "physik.internal.render-measurement-table",
    "physik.format-number": "physik.internal.format-number",
    "physik.format-unit": "physik.internal.format-unit",
    "physik.combine-units": "physik.internal.combine-units",
    "physik.format-equation-term": "physik.internal.format-equation-term",
    "physik.build-equation": "physik.internal.build-equation",
    "physik.format-simple-equation": "physik.internal.format-simple-equation",
    "physik.regression": "physik.internal.fit",
    "informatik.bin2dec": "informatik.bin-to-dec",
    "informatik.dec2bin": "informatik.dec-to-bin",
    "informatik.hex2dec": "informatik.hex-to-dec",
    "informatik.dec2hex": "informatik.dec-to-hex",
    "informatik.häufigkeitsanalyse": "informatik.haeufigkeitsanalyse",
    "informatik.mono": "informatik.internal.mono",
    "operatoren.operatoren-state": "operatoren.internal.used",
    "operatoren.operatoren-config-state": "operatoren.internal.settings",
    "insert-a-word.iaword-neu": "insert-a-word.reset-iaword",
    "insert-a-word.iaword-list": "insert-a-word.internal.words",
    "insert-a-word.iaword-counter": "insert-a-word.internal.block-counter",
    "insert-a-word.iaword-uniform": "insert-a-word.internal.uniform",
    "insert-a-word.iaword-start": "insert-a-word.internal.start",
    "random.default_seed": "random.default-seed",
    "random.rand": "random.random-number",
    "random.randint": "random.random-integer",
    "random.m": "random.internal.modulus",
    "random.a": "random.internal.multiplier",
    "random.lcg": "random.internal.lcg",
    "random.low_cminstd_rand": "random.internal.minstd-number",
    "random.low_cminstd_randint": "random.internal.minstd-integer",
    "random.step_seed": "random.internal.next-seed",
    "random.fisher_yates_shuffle": "random.internal.fisher-yates-shuffle"
  },
  "neu": ["informatik.caesar-table"],
  "stubs": [
    "physik.lineare_regression", "physik.quadratische_regression", "physik.wurzel_regression", "physik.exponentielle_regression", "physik.potenz_regression", "physik.polynom_regression",
    "physik.simple-source", "physik.amperemeter",
    "informatik.häufigkeitsanalyse", "informatik.bin2dec", "informatik.dec2bin", "informatik.hex2dec", "informatik.dec2hex", "informatik.mono",
    "insert-a-word.iaword-neu", "random.rand", "random.randint"
  ],
  "import-noetig": {
    "physik": ["source", "multimeter", "lamp", "ammeter", "voltmeter", "motor", "generator", "konstante"],
    "informatik": ["caesar-table"],
    "mathematik": ["geogebra-style"]
  },
  "parameter": {
    "mathematik.teilaufgaben": {"tasks": "items", "loesungen": "item-solutions"},
    "mathematik.tasks": {"tasks": "items", "loesungen": "item-solutions"},
    "mathematik.graphen": {
      "size": ["width", "height"],
      "x": "domain.x",
      "y": "domain.y",
      "x-step": "step.x",
      "y-step": "step.y",
      "x-label": "labels[0]",
      "y-label": "labels[1]",
      "grid": "grid-lines",
      "x-grid": "grid-lines.x",
      "y-grid": "grid-lines.y",
      "line-width": "stroke",
      "samples": "sample-count",
      "fills": "areas",
      "datensätze": "datasets"
    },
    "mathematik.graphen.args[]": {"color": "accent", "clr": "accent", "label": "labels"},
    "mathematik.graphen.args[].label": {"content": "body", "size": "font-size", "color": "text-fill", "padding": "distance", "angle": "rotation"},
    "mathematik.graphen.fills[]": {"color": "fill", "clr": "fill", "auto-domain": "domain"},
    "mathematik.graphen.marks[]": {"pos": "at", "content": "body", "label": "body", "padding": "distance", "color": "accent", "clr": "accent"},
    "mathematik.graphen.datensätze[]": {"marker": "symbol", "mark-style": ["fill", "stroke"], "color": "accent", "clr": "accent"},
    "mathematik.steckbrief": {"precision": "tolerance"},
    "mathematik.kreisdiagramm": {"legend": ["legend", "legend-position"], "show-percentage": "labeled", "mode": "percent", "label-color": "text-fill", "colors": "accents", "slice-style": "accents", "radius": "width"},
    "mathematik.geogebra-cell": {"approx": "approximate"},
    "mathematik.geogebra-algebra": {"last-has-approx": "approximate-last"},
    "mathematik.geogebra-button": {"size": "width"},
    "mathematik.geogebra-approx-button": {"size": "width"},
    "physik.datensatz": {"max-digits": "digits", "auto-einheit": "prefix"},
    "physik.berechnung": {"fehler": "error", "max-digits": "digits", "auto-einheit": "prefix"},
    "physik.messwerttabelle": {"amount": "count", "max-digits": "digits"},
    "physik.lineare_regression": {"precision": "tolerance"},
    "physik.quadratische_regression": {"precision": "tolerance"},
    "physik.wurzel_regression": {"precision": "tolerance"},
    "physik.exponentielle_regression": {"precision": "tolerance"},
    "physik.potenz_regression": {"precision": "tolerance"},
    "physik.polynom_regression": {"precision": "tolerance"},
    "physik.source": {"variant": "kind", "flipped-side": "flipped-labels"},
    "informatik.caesar": {"keyword": "key"},
    "informatik.text-to-blocks": {"block-size": "character-count"},
    "informatik.ascii-table": {"ranges": "domains", "height": "rows", "variants": "fields"},
    "operatoren.operator": {"text": "caption"},
    "operatoren.operatoren-liste": {"fach": "subject", "operator-text-bold": "bold"},
    "insert-a-word.insert-a-word": {"hide-words": "word-bank", "line-spacing": "leading", "item-spacing": "spacing", "uniform-gaps": "uniform-blanks"},
    "energy-sketch.energy-sketch": {"hide-letters": "labeled", "gap": "gutter"}
  },
  "rueckgabe": {
    "mathematik.steckbrief": {"gleichungssystem": "system", "bedingungen": "conditions", "bedingungen-system": "condition-system", "gleichungssystem-raw": "equations", "a": "coefficients.a", "b": "coefficients.b", "c": "coefficients.c", "d": "coefficients.d", "e": "coefficients.e", "f": "coefficients.f", "g": "coefficients.g", "h": "coefficients.h"},
    "mathematik.geogebra-colors": {"primary": "accent"},
    "physik.datensatz": {"einheit": "unit", "werte": "values", "max-digits": "digits"},
    "physik.messdaten": {"einheit": "unit", "werte": "values", "max-digits": "digits"},
    "physik.berechnung": {"einheit": "unit", "werte": "values", "max-digits": "digits"},
    "physik.lineare_regression": {"m": "coefficients.m", "b": "coefficients.b"},
    "physik.quadratische_regression": {"a": "coefficients.a", "b": "coefficients.b", "c": "coefficients.c"},
    "physik.wurzel_regression": {"a": "coefficients.a", "b": "coefficients.b"},
    "physik.exponentielle_regression": {"a": "coefficients.a", "b": "coefficients.b"},
    "physik.potenz_regression": {"a": "coefficients.a", "m": "coefficients.m"},
    "physik.polynom_regression": {"c<n>": "coefficients.c<n>"},
    "physik.konstante": {"wert": "value", "einheit": "unit", "mit-einheit": "qty"},
    "physik.pk.*": {"wert": "value", "einheit": "unit", "mit-einheit": "qty"},
    "physik.pk": {"m.elektron": "m_e", "m.proton": "m_p", "m.neutron": "m_n", "m.u": "u", "v.schall": "v_sound"},
    "informatik.häufigkeitsanalyse": {"absolut": "counts", "relativ": "frequencies", "data": "items", "diagramm": "chart"}
  },
  "paletten": {
    "mathematik.graphen": {"1": "rgb(\"#1F77B4\")", "2": "rgb(\"#D62728\")", "3": "rgb(\"#2CA02C\")", "4": "rgb(\"#FF7F0E\")", "5": "rgb(\"#9467BD\")", "6": "rgb(\"#8C564B\")", "7": "rgb(\"#E377C2\")", "8": "rgb(\"#7F7F7F\")", "9": "rgb(\"#BCBD22\")", "10": "rgb(\"#17BECF\")", "n>10": "((n - 1) mod 10) + 1"}
  },
  "werte": {
    "mathematik.graphen.size": {"none": null, "*": "width: $b * $scale * 1cm, height: $h * $scale * 1cm"},
    "mathematik.graphen.x": {"(-5, 5)": null, "auto": null, "*": "domain: (x: $v)"},
    "mathematik.graphen.y": {"(-5, 5)": null, "auto": null, "*": "domain: (y: $v)"},
    "mathematik.graphen.step": {"1": null},
    "mathematik.graphen.x-step": {"none": null, "*": "step: (x: $v)"},
    "mathematik.graphen.y-step": {"none": null, "*": "step: (y: $v)"},
    "mathematik.graphen.x-label": {"[$x$]": "labels: (auto, $y)", "*": "labels: ($v, $y)"},
    "mathematik.graphen.y-label": {"[$y$]": "labels: ($x, auto)", "*": "labels: ($x, $v)"},
    "mathematik.graphen.grid": {"\"both\"": null, "\"none\"": "none", "false": "none", "true": "\"major\""},
    "mathematik.graphen.x-grid": {"none": null, "\"both\"": "grid-lines: (x: \"all\")", "\"none\"": "grid-lines: (x: none)", "false": "grid-lines: (x: none)", "true": "grid-lines: (x: \"major\")", "*": "grid-lines: (x: $v)"},
    "mathematik.graphen.y-grid": {"none": null, "\"both\"": "grid-lines: (y: \"all\")", "\"none\"": "grid-lines: (y: none)", "false": "grid-lines: (y: none)", "true": "grid-lines: (y: \"major\")", "*": "grid-lines: (y: $v)"},
    "mathematik.graphen.fills": {"$d (dictionary)": "($d,)", "$f (function)": "((term: $f, domain: \"intersections\"),)", "($f, $g)": "((between: ($f, $g), domain: \"intersections\"),)"},
    "mathematik.graphen.datensätze": {"$d (dictionary)": "($d,)", "($x, $y)": "((x: $x, y: $y),)"},
    "mathematik.graphen.marks": {"$d (dictionary)": "($d,)", "($x, $y) (zwei Zahlen)": "((at: ($x, $y)),)"},
    "mathematik.graphen.marks[]": {"($x, $y)": "(at: ($x, $y))", "(($x, $y), $b)": "(at: ($x, $y), body: $b)"},
    "mathematik.graphen.args[].color": "@paletten/mathematik.graphen",
    "mathematik.graphen.args[].clr": "@paletten/mathematik.graphen",
    "mathematik.graphen.fills[].color": "@paletten/mathematik.graphen",
    "mathematik.graphen.fills[].clr": "@paletten/mathematik.graphen",
    "mathematik.graphen.marks[].color": "@paletten/mathematik.graphen",
    "mathematik.graphen.marks[].clr": "@paletten/mathematik.graphen",
    "mathematik.graphen.datensätze[].color": "@paletten/mathematik.graphen",
    "mathematik.graphen.datensätze[].clr": "@paletten/mathematik.graphen",
    "mathematik.graphen.args[].label.position": {"\"tl\"": "\"top-left\"", "\"tr\"": "\"top-right\"", "\"bl\"": "\"bottom-left\"", "\"br\"": "\"bottom-right\""},
    "mathematik.graphen.args[].label.size": {"none": null},
    "mathematik.graphen.fills[].domain": {"\"auto\"": "\"intersections\""},
    "mathematik.graphen.fills[].auto-domain": {"true": "domain: \"intersections\"", "false": null},
    "mathematik.graphen.marks[].anchor": {
      "\"south-west\"": "\"top-right\"", "\"south-east\"": "\"top-left\"", "\"north-west\"": "\"bottom-right\"", "\"north-east\"": "\"bottom-left\"",
      "\"south\"": "\"top\"", "\"north\"": "\"bottom\"", "\"west\"": "\"right\"", "\"east\"": "\"left\"",
      "\"tl\"": "\"bottom-left\"", "\"top-left\"": "\"bottom-left\"", "\"tr\"": "\"bottom-right\"", "\"top-right\"": "\"bottom-right\"",
      "\"bl\"": "\"top-left\"", "\"bottom-left\"": "\"top-left\"", "\"br\"": "\"top-right\"", "\"bottom-right\"": "\"top-right\"",
      "\"t\"": "\"bottom\"", "\"top\"": "\"bottom\"", "\"b\"": "\"top\"", "\"bottom\"": "\"top\"",
      "\"l\"": "\"left\"", "\"left\"": "\"left\"", "\"r\"": "\"right\"", "\"right\"": "\"right\""
    },
    "mathematik.steckbrief.notation": {"\"dec\"": "\"decimal\"", "\"sci\"": "\"scientific\"", "\"frac\"": "\"fraction\""},
    "mathematik.kreisdiagramm.legend": {"\"r\"": null, "\"l\"": "legend-position: \"left\"", "\"t\"": "legend-position: \"top\"", "\"b\"": "legend-position: \"bottom\"", "true": null, "none": null},
    "mathematik.kreisdiagramm.mode": {"\"percent\"": null, "\"absolute\"": "percent: false"},
    "mathematik.kreisdiagramm.radius": {"*": "width: 2 * $v * 1cm"},
    "physik.datensatz.prefix": {"\"1\"": null, "\"\"": null},
    "physik.datensatz.max-digits": {"none": null},
    "physik.datensatz.auto-einheit": {"true": "prefix: auto", "false": null},
    "physik.messdaten.prefix": {"\"1\"": null, "\"\"": null},
    "physik.berechnung.prefix": {"\"1\"": null, "\"\"": "none"},
    "physik.berechnung.auto-einheit": {"true": null, "false": "prefix: none"},
    "physik.berechnung.fehler": {"0": null},
    "physik.berechnung.max-digits": {"none": null},
    "physik.lineare_regression.notation": {"\"dec\"": "\"decimal\"", "\"sci\"": "\"scientific\""},
    "physik.quadratische_regression.notation": {"\"dec\"": "\"decimal\"", "\"sci\"": "\"scientific\""},
    "physik.wurzel_regression.notation": {"\"dec\"": "\"decimal\"", "\"sci\"": "\"scientific\""},
    "physik.exponentielle_regression.notation": {"\"dec\"": "\"decimal\"", "\"sci\"": "\"scientific\""},
    "physik.potenz_regression.notation": {"\"dec\"": "\"decimal\"", "\"sci\"": "\"scientific\""},
    "physik.polynom_regression.notation": {"\"dec\"": "\"decimal\"", "\"sci\"": "\"scientific\""},
    "physik.source.current": {"\"dc\"": "\"direct\"", "\"ac\"": "\"alternating\""},
    "physik.source.variant": {"\"symbol\"": null, "\"lines\"": "kind: \"bars\""},
    "informatik.caesar.key": {"\"<nur Ziffern>\"": "<int-Literal>"},
    "informatik.ascii-table.variants": {"\"char\"": "\"character\""},
    "operatoren.operator.text": {"\"\"": null},
    "operatoren.operator.bold": {"none": null},
    "insert-a-word.insert-a-word.hide-words": {"false": null, "true": "word-bank: false"},
    "insert-a-word.insert-a-word.show-solution": {"false": null, "true": null},
    "energy-sketch.energy-sketch.hide-letters": {"false": null, "true": "labeled: false"}
  },
  "kontext": [
    {"alt": "graphen(x: A, y: B)", "regel": "ein Argument domain: (x: A, y: B); Literal (-5, 5) oder auto je Achse weglassen; bleibt nichts übrig: Argument löschen"},
    {"alt": "graphen(x: V) oder (y: V) oder (step: V) mit V kein Literal", "regel": "übernehmen und Bericht: der Wert der alten Vorgabe galt zusammen mit datensätze als nicht gesetzt"},
    {"alt": "graphen(step: S, x-step: X, y-step: Y)", "regel": "step: (x: X, y: Y); fehlt X oder Y, tritt S an seine Stelle, außer S ist 1 oder fehlt (dann Schlüssel weglassen)"},
    {"alt": "graphen(x-label: A, y-label: B)", "regel": "labels: (A, B); [$x$] bzw. [$y$] oder fehlend wird auto; labels: (auto, auto) löschen"},
    {"alt": "graphen(grid: G, x-grid: X, y-grid: Y)", "regel": "grid-lines: (x: X', y: Y'); fehlt X oder Y, tritt G' an seine Stelle; ohne x-grid und y-grid: grid-lines: G'"},
    {"alt": "graphen(size: S, scale: F)", "regel": "width, height aus S mal F mal 1cm; scale ohne size nur bei Literalen für x und y, sonst Bericht"},
    {"alt": "graphen(marks: (… (position: ARRAY, anchor: A) …))", "regel": "at: ARRAY, position: A' in einem Durchgang; position nur bei Array-Literal umbenennen; Wertabbildung nur am Schlüssel anchor", "nur-kontext": true},
    {"alt": "graphen(datensätze: (… (marker: (symbol: S, fill: F, stroke: T), mark-style: (fill: G)) …))", "regel": "symbol: S, fill: F, stroke: T; das marker-Dictionary gewinnt gegen mark-style; andere Schlüssel: Bericht"},
    {"alt": "Dictionary-Einträge von graphen, die nicht als Literal im Aufruf stehen", "regel": "nur Bericht; die Laufzeitprüfung meldet die Schlüssel"},
    {"alt": "args[].label.position mit ausgeschriebenem Wert (\"top-left\" usw.)", "regel": "nicht übernehmen, Bericht: wirkt heute als Mischform"},
    {"alt": "datensatz(…, prefix: P, auto-einheit: A) mit P nicht \"1\"", "regel": "auto-einheit ersatzlos löschen (prefix gewinnt heute, Z. 21); P \"\" ebenfalls löschen"},
    {"alt": "berechnung(…, prefix: P, auto-einheit: A) mit P nicht \"1\"", "regel": "auto-einheit ersatzlos löschen (Z. 228); P \"\" wird prefix: none"},
    {"alt": "berechnung(…, prefix: P) mit P weder \"1\", \"\", Vorsatzbuchstabe noch e<n>", "regel": "Bericht; zur Laufzeit Fehler mit Liste der erlaubten Vorsätze"},
    {"alt": "messwerttabelle(DS, N, …) mit N int (Form von messwerttabellen 0.0.1)", "regel": "messwerttabelle(..DS, count: N, …)"},
    {"alt": "caesar(ARGS)() und rot13()", "regel": "caesar-table(ARGS) bzw. caesar-table(key: 13); Importzeile für caesar-table ergänzen, solange arbeitsblatt den Namen nicht durchreicht"},
    {"alt": "rot13(T, true)", "regel": "rot13(T) (selbstinvers)"},
    {"alt": "pk.<k>.<feld> als Kette im Quelltext", "regel": "constants.<k'>.<feld'>; #let h = pk.h und spätere Feldzugriffe: Bericht"},
    {"alt": "insert-a-word(show-solution: true)", "regel": "Argument löschen und Bericht: folgt has-solutions(); im Dokument set-options(solutions: \"in-place\")"}
  ],
  "states": {
    "operatoren": "schule/operatoren/used@1",
    "operatoren-config": "schule/operatoren/settings@1",
    "iaword-list": "schule/insert-a-word/words@1",
    "iaword-solution": null,
    "iaword-counter": "schule/insert-a-word/block-counter@1",
    "iaword-uniform": "schule/insert-a-word/uniform@1",
    "iaword-start": "schule/insert-a-word/start@1",
    "iaword-show": null
  },
  "state-felder": {
    "operatoren-config": {"text-bold": "bold"}
  },
  "labels": {
    "-def": "schule-operatoren-overview",
    "{op}-def": "schule-operatoren-{label-name(op)}"
  },
  "entfernt": [
    "mathematik.default_seed", "mathematik.m", "mathematik.a", "mathematik.lcg", "mathematik.low_cminstd_rand", "mathematik.low_cminstd_randint", "mathematik.step_seed", "mathematik.fisher_yates_shuffle", "mathematik.rand", "mathematik.randint", "mathematik.shuffle", "mathematik.umrechnungseinheit",
    "mathematik.graphen.scale",
    "mathematik.steckbrief().bedingungen-raw", "mathematik.steckbrief().bedingungen-system-raw", "mathematik.steckbrief().error", "mathematik.steckbrief().grad",
    "mathematik.kreisdiagramm.gap", "mathematik.kreisdiagramm.value-key", "mathematik.kreisdiagramm.label-key", "mathematik.kreisdiagramm.inner-label", "mathematik.kreisdiagramm.outer-label",
    "mathematik.geogebra-colors().button",
    "physik.qty", "physik.unit", "physik.add-macros", "physik.znum", "physik.default_seed", "physik.m", "physik.a", "physik.lcg", "physik.low_cminstd_rand", "physik.low_cminstd_randint", "physik.step_seed", "physik.fisher_yates_shuffle", "physik.rand", "physik.randint", "physik.shuffle",
    "physik.count_decimal_places", "physik._kopf-einheit", "physik.datensatz().auto-einheit", "physik.konstante.beschreibung", "physik.format-equation-term.is-first",
    "informatik.häufigkeitsanalyse-alt", "informatik.caesar.advanced", "informatik.vigenere.advanced", "informatik.atbash.advanced",
    "informatik.caesar().encode", "informatik.caesar().decode", "informatik.caesar().table", "informatik.caesar().key", "informatik.caesar().keyword", "informatik.caesar().alphabet", "informatik.caesar().geheimtext-alphabet",
    "informatik.vigenere().encode", "informatik.vigenere().decode", "informatik.vigenere().keyword", "informatik.atbash().encode", "informatik.atbash().decode",
    "informatik.blockst", "informatik.scratch", "informatik.set-blockst", "informatik.blockst-run-options", "informatik.set-scratch-run", "informatik.scratch-run",
    "operatoren._render-operator-text", "operatoren._normalisiere-sprache", "operatoren._csv-dateiname", "operatoren._operatorenlisten-titel",
    "insert-a-word.insert-a-word.show-solution", "insert-a-word.iaword-solution", "insert-a-word.iaword-show",
    "insert-a-word.default_seed", "insert-a-word.m", "insert-a-word.a", "insert-a-word.lcg", "insert-a-word.low_cminstd_rand", "insert-a-word.low_cminstd_randint", "insert-a-word.step_seed", "insert-a-word.fisher_yates_shuffle", "insert-a-word.rand", "insert-a-word.randint", "insert-a-word.shuffle",
    "energy-sketch.canvas", "energy-sketch.draw",
    "energy-sketch._energy-sketch-rows", "energy-sketch._clamp-length", "energy-sketch._normalize-energy-names", "energy-sketch._validate-energy-sketch-options", "energy-sketch._resolve-layout", "energy-sketch._resolve-style", "energy-sketch._column-geometry", "energy-sketch._draw-column-grid", "energy-sketch._draw-column-frame", "energy-sketch._draw-column-label-line", "energy-sketch._draw-column-label", "energy-sketch._draw-energy-column"
  ]
}
```

Nicht als Tabelle abbildbar und deshalb eigene Codemod-Regeln (AST, § 9.4 Nr. 2):

| Regel | Muster |
|---|---|
| Positionsargumente physik | `datensatz(n, e, w, …)` → `datensatz(w, name: n, unit: e, …)`; `messdaten(n, e, k)` → `messdaten(k, name: n, unit: e)`; `berechnung(n, e, d, f, …)` → `berechnung(f, datasets: d, name: n, unit: e, …)`; `konstante(n, w, e, …)` → `konstante(w, name: n, unit: e, …)`; Regressionen `f(a, b)` → `f(x: a, y: b)`, `polynom_regression(a, b, g)` → `…(x: a, y: b, degree: g)` |
| messwerttabellen 0.0.1 | `messwerttabelle(DS, N, …)` mit zweitem Positionsargument vom Typ int → `messwerttabelle(..DS, count: N, …)`; `lineare_regression(xs, ys)` und `berechnung(n, e, d, f)` wie oben (gleiche Stellung der Argumente) |
| Chiffren | `caesar(ARGS)(t)` → `caesar(t, ARGS)`; `caesar(ARGS)(t, true)` → `caesar(t, ARGS, inverse: true)`; `caesar(ARGS)()` → `caesar-table(ARGS)`; `caesar(ARGS)` allein → `caesar.with(ARGS)`; `key: "3"` (String-Literal nur aus Ziffern) → `key: 3`; `vigenere(k)(t)` → `vigenere(t, key: k)`; `atbash()(t)` → `atbash(t)`; `rot13()` → `caesar-table(key: 13)`; `rot13(t, true)` → `rot13(t)` |
| random | `rand(s)` → `random-number(seed: s)`; `randint(a, b, s)` → `random-integer((a, b), seed: s)`; `shuffle(x, s)` → `shuffle(x, seed: s)` |
| Feldketten | `pk.<k>.<feld>` nach `rueckgabe` (`physik.pk`, `physik.pk.*`), nur als zusammenhängende Kette; Zugriffe auf Ergebnisse (`sb.a`, `reg.m`, `ha.absolut`, `h.wert` nach `#let h = pk.h`) nur als Bericht |
| Importzeilen | nur für Namen aus `import-noetig` (Abschnitt 9.2): je benutztem Namen eine namentliche Importzeile des Fachpakets auf 0.4.1 ergänzen. Alle anderen Fachpaket-Namen kommen über arbeitsblatt. Dokumente, die ein Fachpaket schon direkt importieren, bekommen dessen Zeile auf 0.4.1 gehoben |
| `graphen` | `size` und `scale` zusammen auswerten; `x`/`y` zu einem `domain`, `step`/`x-step`/`y-step` zu einem `step`, `grid`/`x-grid`/`y-grid` zu einem `grid-lines`, `x-label`/`y-label` zu einem `labels` zusammenführen; Kurzformen von `fills`, `datensätze`, `marks`; `marker` und `mark-style` auflösen; `position`/`anchor` in `marks[]` in einem Durchgang (siehe `kontext`) |
| Dictionary-Einträge | Schlüssel in Einträgen von `graphen` nur umbenennen, wenn das Dictionary als Literal im selben Aufruf steht; sonst Bericht. Palettenindex nur bei int-Literal |
| Idempotenz | Abnahmekriterium für alle Regeln: Codemod zweimal angewandt = einmal angewandt (eigener Test; betrifft vor allem `position`/`anchor` und die Lagewerte) |

---

## 13. Zweifelsfälle und Entscheidung

1. **Fachpaket-Namen über arbeitsblatt.** Entschieden nach `tabelle-arbeitsblatt.md` 4.2 und `architektur-release.md`: arbeitsblatt reicht die Fachpaket-Namen namentlich durch; Dokumente mit `operator` (348 Aufrufe), `iaword` (160), `messwerttabelle` (122) brauchen keine eigene Importzeile. Eine Importzeile ergänzt der Codemod nur für die Namen aus `import-noetig` (Schaltkreis-Komponenten, `zap`, `konstante`, `caesar-table`). Offen für den Abgleich der Nachbartabelle: `caesar-table` und die Schaltkreis-Komponenten in 4.2 aufnehmen (Abschnitt 9.2).
2. **zap-Komponenten.** `source(name, node, ..args)` hat zwei Positionsparameter und reicht den Sink an `zap.component` weiter (gegen L15, L16, § 4.4 Nr. 5). Entscheidung: benannte Ausnahme „Komponente einer fremden Zeichenumgebung behält deren Signatur", sonst wären die Komponenten neben zaps eigenen nicht benutzbar. Die eigenen benannten Parameter und ihre alten Namen werden vor der Weitergabe geprüft.
3. **`precision`.** Anhang B bildet es auf `digits` ab; im Code ist es die Schwelle, unter der ein Term entfällt. Entscheidung: `tolerance` (neues Wort), `math-digits` bleibt für die Stellenzahl. `digits` stünde sonst für zwei verschiedene Größen (L6).
4. **`graphen`: `size` und `scale`.** Zahl in Canvas-Einheiten mal Faktor. Entscheidung: `width`, `height` als Längen, `scale` entfällt (§ 5.5). Preis: `scale` ohne `size` ist nur umrechenbar, wenn die Achsenbereiche als Literale dastehen; die Markengröße bei `scale` ≠ 1 ist zu prüfen. Alternative: ein Parameter für die Länge einer Achseneinheit (bräuchte ein neues Wort).
5. **`graphen`: Achsenpaare.** Entscheidung: „Wert je Ziel" (W7) in `domain`, `step`, `grid-lines` mit den Schlüsseln `x`, `y` statt sechs Einzelnamen. Das beseitigt die L10-Verstöße, die L5-Ausnahme für `x-`/`y-` als Segment und den Bedeutungswechsel von `none` bei `x-step`/`x-grid`. Preis: `domain: (x: (0, 10))` ist länger als `x: (0, 10)`. `labels` bleibt ein Array `(x-Achse, y-Achse)`, weil G46 den Typ so festlegt; das ist neben den drei W7-Parametern eine zweite Schreibweise für „je Achse". Alternative für den Autor: `labels: (x: …, y: …)` und G46 anpassen.
6. **Sentinel-Vorgaben in `graphen`.** `x: (-5, 5)`, `y: (-5, 5)`, `step: 1`, `x-label: [$x$]`, `y-label: [$y$]` gelten heute zusammen mit `datensätze` als „nicht gesetzt". Entscheidung: Der Codemod löscht diese Literale immer (ohne Datensätze sind sie die Vorgabe, mit Datensätzen wirkungslos); das PDF bleibt gleich. Steht der Wert in einer Variablen, kann weder Codemod noch Laufzeit den Fall erkennen; er steht im Bericht.
7. **Farben und Kurzformen in `graphen`.** `color`/`clr` werden je nach Sache `accent` (eine Farbe für mehreres: Graph, `datasets[]`, `marks[]`), `fill` (Fläche in `areas[]`) oder `text-fill` (Kurvenbeschriftung); der Palettenindex als int entfällt, weil keine Form W1 bis W9 ihn trägt (der Codemod setzt bei int-Literalen die Palettenfarbe ein). Die Kurzformen `fills: (f, g)`, `datensätze: (xs, ys)`, `marks: ((x, y), …)` entfallen nach § 4.4 Nr. 4. Alternative: Kurzformen als benannte Ausnahme behalten; sie sind für die Lehrkraft bequemer.
8. **Chiffren.** Anhang B verlangt `chiffre(text, key: …)`. Entscheidung: `inverse: true` statt eines Verbs `decode` (§ 4.1), `advanced` entfällt, die Tabelle wird `caesar-table`, die Fabrikform heißt `caesar.with(key: 3)`. Der Codemod schafft nur den direkten Doppelaufruf. `key: "3"` war eine Verschiebung und wird als int geschrieben; ein String ohne Buchstaben ist künftig ein Fehler mit Abhilfe.
9. **Einbuchstabige Ergebnis-Schlüssel.** Koeffizienten (`a`, `m`, `c0`) und Konstanten (`h`, `k_B`) sind Formelzeichen. Entscheidung: als Daten behandeln (§ 2.1), Koeffizienten aber in ein eigenes Dictionary `coefficients` legen, damit die festen Schlüssel prüfbar bleiben; `pk.m.elektron` wird `constants.m_e`, `pk.v.schall` wird `constants.v_sound` (ein deutsches Wort als Schlüssel ist kein Formelzeichen; `v_s` wäre konsequenter, aber nicht selbsterklärend; das gesetzte Zeichen bleibt $v_"Schall"$). Die fachlich uneinheitliche Buchstabenwahl der Regressionen bleibt offen.
10. **Positionsargumente in physik.** `datensatz(name, einheit, werte)` hat drei, die Regressionen zwei. Entscheidung nach L15: ein Hauptargument (`values`, `count`, `formula`, `value`), der Rest benannt; bei den Regressionen `x:` und `y:` benannt und Pflicht (Vorgabe `none` mit Fehlermeldung, Form in Abschnitt 11 beantragt), ebenso `degree:`. Das ist der größte sichtbare Umbau an den 122 Tabellenaufrufen, aber per Codemod machbar; jede dieser Funktionen trägt `..deprecated` und meldet die alte Positionsform mit der neuen Schreibweise.
11. **`symbol`.** Formelzeichen (`konstante`), Punktsymbol (`marks[]`, `datasets[]`) und der Wert `kind: "symbol"` von `source` heißen `symbol`, obwohl G77 das Wort sperrt. Die Notlösungen des ersten Entwurfs (`math`, `mark`, `"terminals"`) hatten je einen eigenen Regelverstoß (§ 4.5 und doppelte Bedeutung von `math`; `mark` kein Singular von `marks`). Die Entscheidung setzt den Glossar-Nachtrag aus Abschnitt 11 Nr. 1 voraus; ohne ihn ist die Stelle offen.
12. **`source`.** `variant` (G58) wird `kind` mit `"symbol"`/`"bars"` (`"lines"` ist das Parameterwort des Bausteins `liniert` und meinte hier etwas anderes, § 5.3), `flipped-side` wird `flipped-labels`; die Stromart bleibt `current`, ihre Werte werden ausgeschrieben (`"direct"`, `"alternating"`), weil die Abkürzungsliste in § 2.2 abschließend ist und `"dc"`/`"ac"` nur Abstand 1 haben. Alternative für den Autor: `dc`, `ac` als Fachkürzel in § 2.2 aufnehmen und von L10 ausnehmen; dann bleibt die Zeile unverändert.
13. **`geogebra-style`.** Bleibt öffentlich: Es hat einen Docstring mit Dokumentbeispiel und wird in der Doku vorgeführt; intern bräuchte nur `geogebra-algebra` es. Alternative: nach `internal`, wenn die Zählung im Korpus 0 Aufrufe ergibt (das Inventar `nutzung-ausserhalb.md` zählt den Namen nicht).
14. **Deutsche Bausteine in den Fachpaketen (Entscheidung des Autors, 2026-11-15).** Welche Fachfunktion deutsch bleibt, entscheidet allein `bausteine-de.txt` (Konvention 2.1a; Begründung je Name in Anhang B.1). Folge für diese Tabelle: Bei zehn der 17 Fachbausteine sind alter und neuer Funktionsname gleich, bei sieben (sechs Regressionen, `haeufigkeitsanalyse`) ändert sich nur die Schreibweise. Ob ein Aufruf alt oder neu ist, erkennt der Codemod bei gleichem Namen nur an den Argumenten (`datensatz(n, e, w)` hat drei Positionsargumente, die neue Form eines); die Regeln sind so geschrieben, dass die neue Form kein Muster der alten trifft (Idempotenz, Abschnitt 12). In den Klammern steht nie der Bausteinname, sondern sein Parameterwort (`datasets:` in `graphen` und `berechnung`, Wert `constants`); `datensatz:` als Parameter wäre nach L14 und L27 ein Verstoß.

---

## 14. Prüfprotokoll

Zwei Prüfer (Vollständigkeit V1 bis V22, Regeltreue R1 bis R14) haben den ersten Entwurf dieser Tabelle geprüft. Jeder Befund wurde gegen Inventar und Quelltext nachgesehen. Ergebnis: 36 Befunde, 36 übernommen (davon fünf mit abweichender Korrektur oder ohne einen Teilpunkt), keiner ganz verworfen.

| Nr. | Schwere | Befund (kurz) | Ergebnis |
|---|---|---|---|
| V1 | hoch | Widerspruch zu `tabelle-arbeitsblatt.md` 4.2 (Durchreichung), fehlende Stub-Liste | übernommen: Abschnitt 9.2 folgt jetzt 4.2, Stub-Liste in 9.1, Abweichungen (`caesar-table`, Komponenten, `konstante`, `iaword-*`) als Abgleichpunkte benannt. |
| V2 | hoch | Sentinel-Vorgaben `x`, `y`, `step`, `x-label`, `y-label` mit `datensätze` | übernommen (am Code L686–713 bestätigt): Die Literale der alten Vorgabe werden immer gelöscht; das gilt mit und ohne Datensätze, eine eigene Kontextbedingung ist deshalb nicht nötig; Variablen stehen im Bericht. |
| V3 | hoch | `max_wert_pro_tabelle` ist Positionsparameter | übernommen (messwerttabellen/0.0.1/lib.typ Z. 224): JSON-Eintrag entfernt, AST-Regel und Laufzeitprüfung im Sink, 0.0.1-Formen von `lineare_regression` und `berechnung` genannt. |
| V4 | mittel | L10: `step`/`steps`, `dc`/`ac`, Achsenpaare | übernommen: `sample-count`, W7 für die Achsenpaare, `"direct"`/`"alternating"`; Ausnahme für `x`/`y` beantragt. |
| V5 | mittel | Kurvenbeschriftung `x` (Zahl) gegen `x` als Datenreihe, falsche L6-Begründung | übernommen in der Variante „Ausnahme": `x` bleibt, die L6-Ausnahme für Achsenbezeichner steht in Abschnitt 11; `at` wurde nicht gewählt, weil es in `marks[]` ein Zahlenpaar ist und denselben Typkonflikt hätte. Die falsche Begründung an `x` → `domain` ist entfallen. |
| V6 | mittel | `padding` der Kurvenbeschriftung ist Versatz, kein Innenabstand | übernommen (L865, L885–886, L901): `distance`; derselbe Name auch für `marks[].padding`, weil es für den Benutzer derselbe Begriff ist. |
| V7 | mittel | JSON ohne Koeffizienten der Regressionen, ohne `berechnung`/`messdaten` | übernommen: Feld `rueckgabe`. |
| V8 | mittel | JSON: Doppeleinträge, Palette nur an einer Stelle, `marks` falsch geschlüsselt, Kurzformen fehlen | übernommen: alle vier Punkte. |
| V9 | mittel | JSON: `_`-Helfer, States, Labels, `text-bold`, `size`, `primary` fehlen | übernommen: alle `_`-Namen einheitlich unter `entfernt` (auch `physik._kopf-einheit`), Felder `states`, `state-felder`, `labels`, `rueckgabe`. |
| V10 | mittel | Signaturen ohne `..deprecated` | übernommen für alle Funktionen, die einen benannten Parameter oder ein Positionsargument verlieren; nicht für `haeufigkeitsanalyse` (hatte nie benannte Parameter; `häufigkeitsanalyse-alt` ist eine andere Funktion). |
| V11 | mittel | `prefix`: `""`, freie Strings, Doppelung mit `auto-einheit` | übernommen (Z. 21, 228, 322): Wertregeln und Kontextregel ergänzt. |
| V12 | mittel | `data` enthält relative Prozentwerte | übernommen (lib.typ Z. 82–91): Text berichtigt, Typ von `frequencies` vermerkt. |
| V13 | mittel | Label mit Umlaut und ohne `lower` | übernommen: `internal.label-name` mit `lower`, Umschrift und `-`. |
| V14 | niedrig | `geogebra-style` wird von `geogebra-algebra` gebraucht und ist dokumentiert | übernommen: bleibt öffentlich (Zweifelsfall 13). |
| V15 | niedrig | `zap`-Zahlen stammen aus dem Paketquelltext | übernommen: Formulierung berichtigt; eine Dokumentzählung gibt das Inventar nicht her, das steht jetzt so da. |
| V16 | niedrig | zwölf statt elf interne Helfer | übernommen. |
| V17 | niedrig | auch `berechnung` liefert andere Schlüsselmenge | übernommen (Z. 375–381). |
| V18 | niedrig | bool-Werte bei `grid`, `x-grid`, `y-grid` | übernommen, `true` → `"major"` mit [prüfen]. |
| V19 | niedrig | `caesar(key: "3")`, `rot13(t, true)` | übernommen (Z. 223). |
| V20 | niedrig | Liste der festen Gestaltung unvollständig | übernommen: Abschnitt 9.5. |
| V21 | niedrig | arbeitsblatt ruft `iaword-neu()` selbst | übernommen (arbeitsblatt.typ Z. 619): Abschnitt 5 und 9.3. |
| V22 | niedrig | unbekannte `position`-Werte sind Mischform | übernommen; ausgeschriebene Alt-Werte gehen in den Bericht. |
| R1 | hoch | wie V1; `caesar-table`, `konstante`, `ammeter` fehlen in der arbeitsblatt-Liste | übernommen: Importzeile nur für Namen aus `import-noetig`; die Codemod-Regel für `caesar(…)()` und `rot13()` ist „teilweise", bis 4.2 `caesar-table` aufnimmt. |
| R2 | hoch | Tauschkette `position`/`anchor` in `marks[]` | übernommen (L447, L969–987): Kontextregel in einem Durchgang, Laufzeitmeldungen, Idempotenz-Test. |
| R3 | hoch | fehlende Sinks, Positionsformen ohne Meldung | übernommen wie V10; ohne Sink bleiben nur die vier Zahlensystem-Funktionen (ein Positionsparameter, nie ein benannter; dort gibt es keinen alten Namen abzufangen) und `haeufigkeitsanalyse`. |
| R4 | mittel | L10 in `graphen`, bei den Regressionen, bei `"dc"`/`"ac"` | übernommen wie V4; für `dc`/`ac` die regelkonforme Variante (ausschreiben). |
| R5 | mittel | `none` mit neuer Bedeutung bei `x-step`, `x-grid` | übernommen: durch W7 gibt es die vier Namen nicht mehr. |
| R6 | mittel | `grid`, `math` überdecken Builtins; `math` und `mark` doppeldeutig | übernommen: `grid-lines` (ohne Nachtrag regelkonform, deshalb nicht die Glossarzeile für `grid`), `symbol` statt `math` und `mark` (setzt den Glossar-Nachtrag voraus). |
| R7 | mittel | `accent` für Textfarbe und Füllfarbe | übernommen: `text-fill`, `fill`; `accent` nur, wo eine Farbe mehreres ableitet. |
| R8 | mittel | JSON nach neuen Namen geschlüsselt, Doppeleinträge, L24-Lücken | übernommen bis auf zwei Teilpunkte: `prefix_liste` ist ein lokales `let` in `auto_einheit_anwenden` (messwerttabellen.typ Z. 107), kein exportierter Name, also kein Eintrag; die Umbenennung von Positionsparametern (random) ist für Aufrufer unsichtbar und steht deshalb nur in der AST-Tabelle. |
| R9 | mittel | Codemod „ja" bei Dictionary-Einträgen, `tasks`, `pk`-Kette, Palettenindex | übernommen: „teilweise", Regel „nur Literale im selben Aufruf". |
| R10 | mittel | wie V13 | übernommen. |
| R11 | niedrig | `fills` in `kreisdiagramm` neu, in `graphen` alt | übernommen: `accents`. |
| R12 | niedrig | Wert `"lines"` ist das Parameterwort des Bausteins `liniert` (2.1b), meint hier aber kein Linienmuster | übernommen: `"bars"`; der andere Wert wird wieder `"symbol"`. |
| R13 | niedrig | benannte Pflichtangabe ohne Form; `key` mit zwei Typen | übernommen: Abschnitt 11 Nr. 4 und 5. |
| R14 | niedrig | `current` doppelt belegt; `v_Schall` | übernommen: Glossarzeile beantragt, Begründung berichtigt; `v_sound` statt `v_Schall`. |

### Nachtrag 2026-11-15: Entscheidung deutsche Bausteine eingearbeitet

Der Autor hat entschieden, dass die Bausteine auf Dauer nur ihren deutschen Namen tragen (Konvention: Kasten am Anfang, 2.1a, 9.3, Anhang B.1). Diese Tabelle ist danach durchgehend nachgezogen: `graphen`, `steckbrief`, `kreisdiagramm`, `datensatz`, `messdaten`, `berechnung`, `messwerttabelle`, `schaltkreis`, `konstante` und `operatoren-liste` stehen in jeder Signatur, Tabellenzeile, Meldung und im JSON-Anhang als „unverändert"; nur die sechs Regressionen (`…_regression` → `…-regression`) und `häufigkeitsanalyse` → `haeufigkeitsanalyse` bleiben Umbenennungen wegen der Schreibweise. Parameter, Schlüssel, Enum-Werte, Ergebnis-Schlüssel und die englischen Nicht-Bausteine (`bin-to-dec`, `caesar-table`, `source`, `ammeter`, `constants`, `reset-iaword`, `random-number` …) sind unverändert geblieben. Abschnitt 9.1 ist neu: Stubs gibt es nur noch für Namen, die sich ändern, darunter jetzt auch die Regressionen und `häufigkeitsanalyse`, die § 9.3 ausdrücklich nennt (frühere Lücke 11 Nr. 12 erledigt); aus `funktionen` und `stubs` im JSON sind die zehn namensgleichen Bausteine gestrichen, `mathematik.teilaufgaben` und `mathematik.tasks` zeigen auf `aufgaben.teilaufgaben`. Neu aufgenommen sind Zweifelsfall 14 (alte und neue Aufrufform bei gleichem Namen) und Lücke 11 Nr. 14 (`function`, `chart` sind in § 2.2 gestrichen, werden aber als Ergebnis-Schlüssel gebraucht). Am Paketcode und an den Nachbartabellen wurde nichts geändert; `tabelle-arbeitsblatt.md` 4.2 und 4.3 müssen die deutschen Namen und die neue Stub-Liste übernehmen.

### Nachtrag 2026-11-15: Nachprüfung der Wortwahl „Baustein“

„Baustein“ ist seit der Entscheidung ein definierter Begriff (Name aus `bausteine-de.txt`, Konvention 2.1a). Acht Befunde dazu, alle berechtigt und eingearbeitet:

| Nr. | Befund | Ergebnis |
|---|---|---|
| B1 | `caesar-table` als „zusammengesetzter Baustein“ begründet | übernommen: „zusammengesetzter englischer Helfer“, kein Baustein (§ 4.1, AnhB B.1). |
| B2 | „Baustein“ für `geogebra-colors`, `geogebra-button`, Überschrift 1.5 und die zap-Komponenten | übernommen: „Hilfswert“, „Helfer“, „GeoGebra-Funktionen“, „Komponente(n) fremder Zeichenumgebungen“ (1, 1.5, 11 Nr. 7, 13 Nr. 2). |
| B3 | „§ 6 abhängige Bausteine“ bei `show-solution` | übernommen: „abhängige Funktionen“ wie in § 6. |
| B4 | R12 nennt `"lines"` einen Baustein | übernommen: R12 nennt `lines` das Parameterwort von `liniert`. |
| B5 | `overview` in Label und `internal.overview-title` ohne Wortpaar; Prosa „Übersicht“ | übernommen: Wortpaar `operatoren-liste` ↔ `overview` beantragt (11 Nr. 15), Label und Helfer als [Lücke] markiert, Prosa heißt „Operatorenliste“. |
| B6 | `internal.regression` enthält ein Segment aus `bausteine-de.txt` (L27) | übernommen: der Helfer heißt `internal.fit` (2, 2.8, JSON `funktionen`); 11 Nr. 14 berichtigt. |
| B7 | Lesart des Anhangs verschweigt `mathematik.teilaufgaben` in `funktionen` | übernommen: Paketwechsel in der Lesart genannt. |
| B8 | Stub `tasks`: „dort bzw. in arbeitsblatt“, mathematik laut Zeile 1 mit Stub, laut 9.1 ohne | übernommen: Stub liegt allein in arbeitsblatt; Folge für den Direktimport von mathematik steht in 1 und 9.1. JSON `stubs` bleibt ohne `mathematik.tasks`. |

### Nachtrag 2026-11-15: Abnahme physik 0.5.0

| Nr. | Befund der Abnahme | Ergebnis |
|---|---|---|
| P1 | `zap` wird von physik 0.5.0 nicht exportiert, 2.0 verlangte den Export | Tabelle geändert (2.0, 9, 9.2, JSON `import-noetig`): `zap` entfällt als Re-Export, das Dokument importiert `@preview/zap:0.4.0` selbst. Grund: `UMSETZUNG-0.5.0.md` Nr. 2 und L19. Der Codemod ergänzt die Importzeile, wenn `zap.` im Dokument vorkommt (nicht mehr über `import-noetig`, weil die Zeile nicht auf physik zeigt). Offen für den Autor: Wer `zap` lieber über physik bekommt, muss `fremdnamen.txt` und sig.py (`FREMDNAMEN_PAKETE`) erweitern. |
| P2 | Ω für `"ohm"`, Minuszeichen des führenden Koeffizienten, Längenprüfung von `header` seien Verhaltensänderungen ohne Auftrag | verworfen: alle drei stehen in Abschnitt 10 (physik) als zu behebende Fehler; `UMSETZUNG-0.5.0.md` Nr. 4 erlaubt Behebungen, die die Tabelle verlangt. |
| P3 | `auto-einheit`: die Meldung „heißt jetzt“ hing nicht vom Wert ab | übernommen: die Laufzeitmeldung folgt jetzt der Wertabbildung aus 2.1 und 2.3 (Wert, alte Vorgabe, gesetztes `prefix`). |
| P4 | `name: ""`, `unit: ""` wurden still angenommen | übernommen (§ 5.2): Fehler mit Abhilfe in `datensatz`, `messdaten`, `berechnung`, `konstante`. Codemod: `""` als Name oder Einheit in der alten Positionsform wird nicht übernommen (Argument entfällt). |
| P5 | `berechnung` mit `unit: none` und `prefix: auto` bekommt keinen Vorsatz mehr (0.0.2: Kopf „in m“, Werte umgerechnet) | nicht in Abschnitt 10 verlangt, also in der Gesamtabnahme zurückgenommen (gleiches Dokument, gleiches PDF): ohne Einheit wählt `prefix: auto` in `berechnung` und in `messwerttabelle` wieder einen Vorsatz, der allein im Kopf steht („n in m“). Test `tests/v05-physik-berechnung-ohne-einheit.typ`. Ob das auf Dauer so bleiben soll, entscheidet der Autor. |

### Nachtrag 2026-11-15: Abnahme mathematik 0.5.0

| Nr. | Befund der Abnahme | Entscheidung |
|---|---|---|
| M1 | Abschnitt 10, Zeile L303–305 verlangte „`accent` setzt nur die Farbe eines stroke ohne `paint`“. In 0.0.2 überschrieb `color` die Farbe eines stroke-Dictionaries; die Zeile hätte also ein bisher funktionierendes Bild geändert (UMSETZUNG Nr. 4). | Zeile berichtigt: `accent` gewinnt wie bisher `color`. Am PNG-Vergleich alt/neu bestätigt. |
| M2 | Flächen in `areas` ohne `domain` und mit `domain: "intersections"` nahmen neben Messreihen den Bereich der Messreihen. 0.0.2 nahm den Parameter `x` vor dem Überschreiben durch die Messreihen (L339, L383–396), ohne Angabe also `(-5, 5)`. | Altes Bild erhalten: der x-Bereich einer Fläche ist `domain.x` von `graphen`, sonst `(-5, 5)`. Abschnitt 10, Zeile L383 bleibt erfüllt (`x: auto` gibt es nicht mehr). |
| M3 | Abschnitt 10, letzte Zeile bei physik (mathematik L641/645): der Vorsatz-Faktor wird jetzt eingerechnet (40 mA stehen bei 0,04 A; 0.0.2 zeigte 40 an der Achse „in A“). Das ändert das PDF von Dokumenten mit `prefix` an einem Datensatz in `graphen`. | Bleibt, weil die Tabelle den Fehler ausdrücklich zur Behebung nennt; im Handbuch von mathematik 0.5.0 unter „Was sich sonst geändert hat“ genannt. Entscheidung des Autors offen. Bei automatischem Schritt und einem Achsenbereich unter 0,5 setzt `graphen` mehr Nachkommastellen, damit keine Zahl doppelt an der Achse steht. |
