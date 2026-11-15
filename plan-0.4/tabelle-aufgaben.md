# Umbenennungstabelle `@schule/aufgaben` 0.3.1 → Zielversion (0.4.1)

Stand 2026-11-15 (nach adversarialer Prüfung überarbeitet, siehe Abschnitt 8 „Prüfprotokoll"). Faktenbasis: `inventar-aufgaben.md` und der Quelltext `aufgaben/0.3.1/aufgaben.typ` (Zeilennummern beziehen sich darauf). Regelverweise meinen `konvention.md` in der Fassung vom 2026-11-15 (deutsche Bausteine auf Dauer; K = Abschnitt, G = Glossarzeile, L = Lint-Regel, A = Anhang A, W1–W9 = Wertformen aus K 5.1).

Spalte „Codemod": **ja** = reine Namens- oder Literalersetzung; **AST** = nur mit dem AST-Werkzeug aus K 9.4 (Argumente umstellen, Dictionary auflösen); **teils** = nur bei Literalwerten, sonst Laufzeitmeldung; **nein** = Handarbeit, das Paket meldet „heißt jetzt" oder „gibt es nicht mehr"; **Bericht** = der Codemod ändert nichts, er listet die Fundstellen (K 9.4 Nr. 4).

Abweichungen von KONVENTION Anhang A, die diese Tabelle nach der Prüfung bewusst enthält (alle in Abschnitt 6 begründet, alle als Nachtrag an KONVENTION gemeldet): `..deprecated` in sieben weiteren Signaturen (Zweifelsfall 11); `show-expectations(select:, blocks:)` statt `blocks: auto | none | array` (Zweifelsfall 1); Wert `"fields"` statt `"blank"` bei `possible` (Zweifelsfall 6); Vorgabe `unchanged` statt `auto` in `set-options` (Zweifelsfall 13); `subtask-numbering` als W3 mit Paketregel statt W9 (Zweifelsfall 12).

Am Repo wurde nichts geändert.

> **Entscheidung vom 2026-11-15 eingearbeitet (K Kasten am Anfang, K 2.1a, K 9.3).** Die Bausteine dieses Pakets heißen auf Dauer deutsch und behalten ihren Namen: `aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung`. Englische Zwillinge (`task`, `subtask`, `subtasks`, `solution`, `expectation`) gibt es nicht als Funktionen, ebenso wenig Aliase oder Übergangsnamen. Alles in den Klammern bleibt englisch wie ausgearbeitet: Parameter, Schlüssel, Enum-Werte, Hooks; englisch bleiben auch die Aktionen und Abfragen (`set-options`, `reset-tasks`, `show-solutions`, …). Die Wörter `task`, `subtask`, `solution`, `expectation` kommen in dieser Tabelle deshalb nur noch als Parameterwörter vor (K 2.1b): in Parameternamen, Enum-Werten, Hook- und State-Namen. Die Bausteinaufrufe im Bestand (rund 5100 für `aufgabe` und `teilaufgabe`) bleiben stehen; der Codemod stellt nur um, was in den Klammern steht, und die Aktionsnamen.

Übersicht der 19 öffentlichen Funktionen:

| # | alt (Zeile) | neu | Verbleib |
|---|---|---|---|
| 1 | `aufgabe` (896) | `aufgabe` | öffentlich, Baustein, Name bleibt; Parameter und Werte neu |
| 2 | `teilaufgabe` (1122) | `teilaufgabe` | öffentlich, Baustein, Name bleibt; Parameter neu |
| 3 | `loesung` (1310) | `loesung` | öffentlich, Baustein, Name bleibt |
| 4 | `erwartung` (1363) | `erwartung` | öffentlich, Baustein, Name bleibt; Aufrufform strenger |
| 5 | `material` (838) | `material` | öffentlich, Name bleibt |
| 6 | `set-options` (113) | `set-options` | öffentlich, Name bleibt, Aufrufform neu |
| 7 | `reset-aufgaben` (133) | `reset-tasks` | öffentlich |
| 8 | `show-loesungen` (299) | `show-solutions` | öffentlich |
| 9 | `show-offene-loesungen` (279) | `show-solutions(select: "pending")` | zusammengelegt mit 8 |
| 10 | `show-materialien` (810) | `show-materials` | öffentlich |
| 11 | `show-erwartungen` (534) | `show-expectations` | öffentlich |
| 12 | `show-bewertung` (595) | `show-points-table` | öffentlich |
| 13 | `get-points` (373) | `get-points` | öffentlich, Name bleibt |
| 14 | `format-punkte` (86) | `format-points` | öffentlich |
| 15 | `show-loesung` (151) | `internal.task-solution` | intern |
| 16 | `show-loesung-inline` (215) | `internal.task-solution-inline` | intern |
| 17 | `show-material` (785) | `internal.task-materials` | intern |
| 18 | `get-punkte-anzeige` (56) | – | entfernt (Option ist flach) |
| 19 | `get-punkte-position` (65) | – | entfernt (toter Code) |

Neu in aufgaben: der Baustein `teilaufgaben` (aus arbeitsblatt und mathematik hierher, A.3; der Name bleibt), `has-solutions`, `is-print` (A.5).

---

## 1. Funktionen

### 1.1 `aufgabe` (Name bleibt)

```typ
// alt (Z. 896)
#let aufgabe(
  title: none,
  method: "",
  icons: (),
  large: true,
  number: true,
  workspace: none,
  label: none,
  ..args,
) = {
```

```typ
// neu (A.3)
#let aufgabe(
  title: none,                  // W4 content | str
  method: none,                 // W2 "individual" | "pair" | "group"
  icons: (),                    // W3 array aus content
  large: true,                  // W1
  number: true,                 // W1
  workspace: none,              // W4 content
  label: none,                  // W4 label | str
  ..deprecated,
  body,
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `aufgabe` | `aufgabe` | unverändert (Baustein, deutsch auf Dauer) | – | – (kein Aufruf wird angefasst; der Codemod ändert nur die Argumente) | G3, K 2.1a, K 9.3 („unverändert bleiben") |
| `task` (Kasten aus gentle-clues 1.2.0, heute über `*` durchgereicht, Standardtitel „Aufgabe") | – | entfernt (der Re-Export entfällt, 3.3). Der Name bekommt keine neue Bedeutung: Es gibt keine eigene Funktion dieses Namens, eine stille Änderung ist damit ausgeschlossen | der Aufruf des Kastens in Dokumenten mit @schule-Import → ein Kasten von arbeitsblatt (A.11) oder `clue` aus gentle-clues, Entscheidung je Fundstelle | Bericht (K 9.4 Nr. 4). Ein übersehener Aufruf endet in Typsts `unknown variable: task` (englisch, ohne „heißt jetzt"; einen Stub gibt es dafür nicht). Bestand: 0 Treffer für den Kastenaufruf mit `#` (mit Klammer oder Inhaltsblock) in den lokal lesbaren Dokumenten mit @schule-Import (`klassenarchiv-quellen`, `eduki`; gezählt am 2026-11-15, Cloud-Platzhalter ungelesen, Aufrufe im Code-Modus nicht gezählt) | K 7.1 (gewöhnlicher Typst-Fehler, Kasten wird nicht durchgereicht), K 9.3, L27c |
| `title:` | `title:` | unverändert | `""` → Argument löschen; neu Fehler „leerer Text". Heute ist `""` nicht „kein Titel": nur `none` und `[]` werden abgefangen (Z. 964, 1007), mit `""` erscheint „Aufgabe n −" mit hängendem Strich, bei `number: false` ein leerer Kopfblock. Das Löschen ändert also das PDF (Fehlerbehebung, im JSON unter `pdf-aenderungen`). `[]` wird wie bisher als „kein Titel" behandelt | teils | G13, K 5.2, K 9.2 Pflichteintrag |
| `titel:` (nur Versionen vor 0.3, 342 Vorkommen) | `title:` | umbenannt | – | ja | G13, K 9.2 Umfang |
| `method:` | `method:` | Typ geändert, Default geändert | `""` → Argument löschen (`none`); `"EA"` → `"individual"`; `"PA"` → `"pair"`; `"GA"` → `"group"`; jeder andere String: heute still ignoriert, neu Fehler „ungültiger Wert" | ja (Literale) | G89, K 5.2 (das eine Aus), K 5.3; Vorgabenwechsel `"" → none` ist in K L25 ausdrücklich erlaubt |
| `icons:` | `icons:` | unverändert | – | – | G77, Plural wegen Vorgabe `()` (L9) |
| `large:` | `large:` | unverändert | Wert bleibt | – | K 4.3, K 9.2 („bleiben, Wert bleibt") |
| `number:` | `number:` | unverändert | Wert bleibt | – | G40 |
| `workspace:` | `workspace:` | Typ geändert (`false` fällt weg) | `false` → Argument löschen. Heute setzt `aufgabe` dafür den Text „false" (Z. 1065–1067); das Löschen ändert das PDF (Fehlerbehebung, `pdf-aenderungen`). Neu Fehler „falsches Aus", Abhilfe `none` | teils | G10, K 5.2 |
| `label:` | `label:` | unverändert | – | – | G44 |
| `..args` (1 Positionsargument: Rumpf) | `body` | Typ geändert (Sink → deklarierter Parameter) | – | – (Aufrufstelle bleibt gleich) | K 4.4 Nr. 1, L15 |
| `..args` (2 Positionsargumente: Titel, Rumpf) | – | entfernt | `aufgabe[T][R]` → `aufgabe(title: [T])[R]` | AST | K 4.4 Nr. 4 „ein Weg je Angabe"; Meldung „zweiter Weg" (K 8.3) |
| `..args` (benannte Argumente; heute still verschluckt, weil Z. 904–920 nur `args.pos()` lesen: `titel:`, `punkte:`, Tippfehler wie `tilte:` kompilieren ohne Meldung und ohne Wirkung) | `..deprecated` | Typ geändert (Fehler statt Verschlucken) | `titel:` → `title:` („heißt jetzt"); alles andere „unbekannter Parameter" mit Vorschlag | ja (`titel`), sonst nein | K 4.4 Nr. 6, K 9.2 Umfang. Folge: ein von 0.2.x gehobenes Dokument mit `titel:` hat unter 0.3.1 keinen Titel und bekommt ihn in der Zielversion zurück (PDF ändert sich gegenüber 0.3.1) |
| – | `..deprecated` | neu | fängt `titel`, alte Werte, unbekannte Namen | – | K 4.4 Nr. 5c, K 9.2 |

### 1.2 `teilaufgabe` (Name bleibt)

```typ
// alt (Z. 1122)
#let teilaufgabe(
  item-label: none,
  label: none,
  workspace: none,
  body,
) = {
```

```typ
// neu (A.3)
#let teilaufgabe(
  marker: none,                 // W4 content; ersetzt a), b)
  workspace: none,              // W4 content
  label: none,                  // W4 label | str
  ..deprecated,
  body,
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `teilaufgabe` | `teilaufgabe` | unverändert (Baustein) | – | – | G4, K 2.1a, K 9.3 |
| `item-label:` | `marker:` | umbenannt | –; `marker: ""` bleibt erlaubt (Teilaufgabe ohne sichtbare Marke wie bisher `item-label: ""`; `none` hieße „die gewöhnliche Nummer", ein Fehler „leerer Text" hätte also keine richtige Abhilfe) | ja (30 Vorkommen) | G43; `label` ist nie Sichtbares (G44); gleiches PDF (K 5.5) |
| `label:` | `label:` | unverändert (Position in der Signatur getauscht, benannt, daher ohne Wirkung) | – | – | G44 |
| `workspace:` | `workspace:` | Typ geändert (`false` fällt weg) | `false` → Argument löschen; heute wie `none` behandelt (Z. 1242), neu Fehler „falsches Aus" | teils | G10, K 5.2 |
| `body` | `body` | unverändert | – | – | G79 |
| – | `..deprecated` | neu | fängt `item-label` | – | K 9.2 |

### 1.3 `teilaufgaben` (neu in aufgaben, Name bleibt)

Heute nicht in aufgaben 0.3.1: `teilaufgaben` liegt in arbeitsblatt (Z. 1209 ff.) und veraltet in mathematik. Nach A.3 und Anhang B gehört die Funktion künftig hierher; die Parametertabelle (`tasks:` → `items:`, `loesungen:` → `item-solutions:`) steht in der Tabelle für arbeitsblatt.

```typ
// neu (A.3)
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

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| – (arbeitsblatt `teilaufgaben`) | `teilaufgaben` | neu in diesem Paket; der Name bleibt (Baustein) | – | – (Aufrufe bleiben; Parameter siehe arbeitsblatt) | G4, K 2.1a (Numerus bleibt wie im Bestand) |
| `tasks` (zweiter Name von `teilaufgaben` aus 0.2.x, heute in arbeitsblatt und mathematik) | `teilaufgaben` | entfällt als Funktionsname; abbrechender Stub mit „heißt jetzt". Der Stub liegt in arbeitsblatt (`arbeitsblatt.tasks`, Tabelle arbeitsblatt 1.10); aufgaben exportiert keinen Namen `tasks` und hatte in 0.3.1 nie einen | – | ja; die Regel steht nur in der Tabelle arbeitsblatt, nicht in diesem JSON | K 9.3 (kein Baustein hat einen zweiten Namen), L23c |

### 1.4 `loesung` (Name bleibt)

```typ
// alt (Z. 1310)
#let loesung(body) = {
// neu (A.4)
#let loesung(body) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `loesung` | `loesung` | unverändert (Baustein) | – | – | G5, K 2.1a |
| `body` | `body` | unverändert | – | – | G79 |

### 1.5 `erwartung` (Name bleibt)

```typ
// alt (Z. 1363)
#let erwartung(..args) = {
// neu (A.4)
#let erwartung(..args) = { }          // [body] oder (points, [body]); points: int | float
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `erwartung` | `erwartung` | unverändert (Baustein) | – | – | G7, K 2.1a |
| `..args`: `[body]` | `..args`: `[body]` | unverändert | 0 Punkte wie bisher | – | K 4.4 Nr. 5b (optionales führendes Hauptargument) |
| `..args`: `punkte, [body]` | `..args`: `points, [body]` | unverändert | – | – | K 4.4 Nr. 2 |
| `..args`: `[body], punkte` (Punkte hinten, Z. 1376–1378) | – | entfernt | `erwartung([T], 2)` → `erwartung(2)[T]` | AST | K 4.4 Nr. 4: Punkte stehen nur vorn |
| benannte Argumente (heute still verschluckt, `erwartung(punkte: 2)[…]` = 0 Punkte) | – | entfernt (Fehler) | `punkte: 2`, `points: 2` → führendes Positionsargument | AST | K 4.4 Nr. 4 und Nr. 6; Meldung „zweiter Weg" |

Der Sink heißt weiter `args` (L16) und wird vollständig geprüft: mehr als zwei Positionsargumente, falscher Typ vorn, jedes benannte Argument.

### 1.6 `material`

```typ
// alt (Z. 838)
#let material(body, caption: none, label: none) = {
// neu (A.4, dazu ..deprecated, Zweifelsfall 11)
#let material(caption: none, label: none, ..deprecated, body) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `material` | `material` | unverändert | – | – | G9 |
| `body` (erster Parameter) | `body` (letzter Parameter) | unverändert (nur Reihenfolge in der Signatur; positional, Aufrufstellen bleiben gültig) | – | – | K 4.4 Nr. 1, L15 |
| `caption:` | `caption:` | unverändert | `""` → Argument löschen; neu Fehler „leerer Text" (`none` ist „keine Beschriftung") | teils | G45, Durchreichtest, K 5.2 |
| – | `..deprecated` | neu | fängt unbekannte benannte Argumente; ohne Sink bräche Typst selbst mit `unexpected argument` ab (englisch, ohne Vorschlag) | – | K 8.4, K 4.4 Nr. 5c; Abweichung von A.4 (Zweifelsfall 11) |
| `label:` | `label:` | unverändert | – | – | G44 |

### 1.7 `set-options`

```typ
// alt (Z. 113)
#let set-options(options) = {
```

```typ
// neu (A.5; Vorgabe `unchanged` statt `auto`, Zweifelsfall 13)
#let set-options(
  solutions: unchanged, solutions-pagebreak: unchanged,
  materials: unchanged, materials-pagebreak: unchanged,
  points: unchanged, points-total: unchanged, points-position: unchanged, points-format: unchanged,
  workspaces: unchanged, shortcodes: unchanged, subtask-numbering: unchanged,
  ..deprecated,
) = { }
// unchanged = internal.unchanged, Markierwert für „nicht angegeben". Kein Dokument schreibt ihn.
// `auto` (Paketvorlage bei points-format) und `none` behalten ihre Bedeutung aus K 5.1.
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `set-options` | `set-options` | unverändert | – | – | K 4.1 `set-<plural>` |
| `options` (Dictionary, positional) | elf deklarierte benannte Parameter | Typ geändert | `set-options((k: v))` → `set-options(k: v)` mit Schlüssel- und Wertabbildung aus Abschnitt 2.1; `set-options(d)` mit Variable → `set-options(..d)` (Schlüssel in `d` von Hand). Wichtig: in `set-options` wird kein Argument gelöscht, auch wenn der Wert die Vorgabe ist (2.2, Spalte „in `set-options`") | AST (Literal-Dictionary); nein (Variable) | K 4.4 Nr. 3 (kein Dictionary positional), K 6, L17 |
| – | `..deprecated` | neu | fängt alle alten Schlüssel und ein Positionsargument („Dictionary als Argument – Schlüssel benannt schreiben") | – | K 9.2 |
| – | Vorgabe `unchanged` (alle elf Parameter) | neu | ein fehlendes Argument lässt die Option, wie sie ist; `set-options(points-format: auto)` stellt die Paketvorlage wieder her, `set-options(solutions: none)` schaltet ab | – | K 5.1 (`auto` heißt immer „das Paket entscheidet"); A.5 und K 6 schreiben `auto` = unverändert, damit hätte `auto` am selben Parameter zwei Bedeutungen (Zweifelsfall 13) |
| fremder Schlüssel `"print"` (arbeitsblatt Z. 578; im Repo nirgends gelesen) | – | entfernt aus dem Options-State | arbeitsblatt setzt `aufgaben.internal.print-state` (löst den eigenen `print-state` von arbeitsblatt Z. 180 ab, siehe 2.4); Abfrage `is-print()` | nein (Paketquelltext) | K 6, L17 (Schema-Menge ist geschlossen) |

### 1.8 `reset-aufgaben` → `reset-tasks`

```typ
// alt (Z. 133)
#let reset-aufgaben() = {
// neu (A.5)
#let reset-tasks() = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `reset-aufgaben` | `reset-tasks` | umbenannt | – | ja; alter Name ist ein Stub in `src/removed.typ` und bricht mit „heißt jetzt" ab (K 9.3) | G3 (Parameterwort `tasks`), K 4.1 `reset-<plural>` und „Aktionen sind rein englisch" |

### 1.9 `show-loesungen` und `show-offene-loesungen` → `show-solutions`

```typ
// alt (Z. 299, 279)
#let show-loesungen(curr: false, teil: false, inline: false) = {
#let show-offene-loesungen() = {
```

```typ
// neu (A.5, dazu ..deprecated, Zweifelsfall 11)
#let show-solutions(
  select: "all",                // W2 "all" | "current" | "pending"
  subtask-number: none,         // W4 int
  inline: false,                // W1
  ..deprecated,
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `show-loesungen` | `show-solutions` | umbenannt | – | ja | G5, K 4.1 `show-<plural>` |
| `show-offene-loesungen()` | `show-solutions(select: "pending")` | zusammengelegt | ganzer Aufruf; gibt wie bisher die noch nicht gezeigten Aufgaben in der Form „inline" aus und zählt den State weiter | ja (ganzer Aufruf, keine Namensersetzung: `show-solutions()` allein hieße `select: "all"`) | G86 (verbotenes Synonym „eigene Funktion `show-offene-`") |
| `curr:` | `select:` | umbenannt, Typ geändert (bool → Auswahl) | `false` → Argument löschen (`"all"`); `true` → `"current"` | ja (Literale) | G86, W2 |
| `teil:` | `subtask-number:` | umbenannt, Typ geändert, Default geändert | `false` → Argument löschen (`none`); Zahl bleibt (0 = Aufgabe selbst, n = Teilaufgabe n) | ja (Literale) | G41, K 5.2 (`none` statt `false`), K 4.5 (das bloße Parameterwort `subtask` steht nie ohne Zusatz) |
| `inline:` | `inline:` | unverändert | – | – | Wortliste Gruppe B, W1 |
| – | `..deprecated` | neu | fängt `curr`, `teil` („heißt jetzt") und unbekannte Namen | – | K 8.4, K 9.2; Abweichung von A.5 (Zweifelsfall 11) |

### 1.10 `show-materialien` → `show-materials`

```typ
// alt (Z. 810)
#let show-materialien(curr: false) = {
// neu (A.5, dazu ..deprecated, Zweifelsfall 11)
#let show-materials(select: "all", ..deprecated) = { }          // "all" | "current"
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `show-materialien` | `show-materials` | umbenannt | – | ja | G9, K 4.1 |
| `curr:` | `select:` | umbenannt, Typ geändert | `false` → Argument löschen; `true` → `"current"` | ja (Literale) | G86; gleicher Name, gleicher Typ wie in `show-solutions` (L6) |
| – | `..deprecated` | neu | fängt `curr` | – | K 8.4, K 9.2 |

### 1.11 `show-erwartungen` → `show-expectations`

```typ
// alt (Z. 534)
#let show-erwartungen(grouped: false, new-page: false, erreicht: false, alle: false, teile: ()) = {
```

```typ
// neu (weicht von A.5 ab, Zweifelsfall 1)
#let show-expectations(
  select: "current",            // W2 "current" | "all"
  blocks: (),                   // W3 array aus str | content: Zwischenüberschriften der Blöcke
  grouped: false,               // W1
  achieved: false,              // W1
  ..deprecated,
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `show-erwartungen` | `show-expectations` | umbenannt | – | ja | G7, K 4.1 |
| `grouped:` | `grouped:` | unverändert | – | – | K 4.3 |
| `erreicht:` | `achieved:` | umbenannt | Wert bleibt | ja | K 4.3 (Liste der Schalter), K 6 (`expectations: (achieved:, grouped:)`) |
| `alle:` | `select:` | umbenannt, Typ geändert (bool → Auswahl); Vorgabe bleibt | `false` oder kein `alle` → Argument löschen (`"current"`: nur der aktuelle Block, ungeteilt, Z. 561); `true` → `"all"` (alle Blöcke des Dokuments mit Zwischenüberschrift und Blocksumme, Z. 543–558) | ja (Literale) | G86: `select` ist das Wort für „Auswahl aus Gesammeltem", `alle` steht dort als verbotenes Synonym; gleicher Name und Grundtyp wie in `show-solutions`, `show-materials` (L6). Die Vorgabe ist hier `"current"`, dort `"all"`: jede Funktion behält ihre heutige Vorgabe (K 5.5, L25) |
| `teile:` | `blocks:` | umbenannt | Array bleibt (Vorgabe `()`); fehlende Überschriften werden weiter als „Teil A", „Teil B" ergänzt. `teile` ohne `alle: true` war wirkungslos → Argument löschen; neu ist `blocks` ohne `select: "all"` eine „unzulässige Kombination" (K 8.3) | ja (mit `alle: true`); AST (Löschen ohne `alle: true`) | Plural wegen Vorgabe `()` (L9); `teile` ist viertes Wort für „Teil" (Inventar 5.2 Nr. 12). `blocks` hat weder `none` noch `auto` (L7: eine Form; K 5.1: `none` heißt „nichts") |
| `new-page:` | – | entfernt | `true` → `#pagebreak(weak: true)` vor und nach dem Aufruf (heute `page[…]`, eigene Seite); `false` → Argument löschen | AST (Aufruf als eigene Anweisung); nein in Ausdrücken | A.5 führt den Parameter nicht (W6: die Schlüssel von `expectations: (…)` sind genau diese Parameter). Siehe Zweifelsfall 2 |
| – | `..deprecated` | neu | fängt `erreicht`, `alle`, `teile` („heißt jetzt") und `new-page` („gibt es nicht mehr") | – | K 8.4, K 9.2; ohne Sink käme Typsts `unexpected argument` (Zweifelsfall 11) |

### 1.12 `show-bewertung` → `show-points-table`

```typ
// alt (Z. 595)
#let show-bewertung(..args, compact: false, full: false) = {
```

```typ
// neu (A.5; Wert "fields" statt "blank" und ..deprecated, Zweifelsfälle 6 und 11)
#let show-points-table(
  possible: "shown",            // W2 "shown" | "fields"; none = Zeile entfällt
  compact: false,               // W1
  subtotals: false,             // W1
  ..deprecated,
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `show-bewertung` | `show-points-table` | umbenannt | – | ja | G7 (`bewertung` verboten), K 4.1 (Beispiel) |
| `..args` (genau ein Positionsargument, Z. 598–600) | `possible:` | umbenannt, Typ geändert (Dreiwert-bool positional → Auswahl benannt) | kein Argument oder `true` → Argument löschen (`"shown"`: mögliche Punkte eingetragen); `false` → `"fields"` (Zeile mit leeren Feldern zum Eintragen); `none` → `none` (Zeile entfällt) | AST | K 4.4 Nr. 3 (kein bool, kein `none` positional), W2 mit `none` als Aus; zum Wert `"fields"` siehe Zweifelsfall 6 |
| `..args` (zwei oder mehr Positionsargumente: heute werden alle ignoriert, auch das erste, Wirkung wie `true`; benannte Argumente im Sink: still verschluckt) | `..deprecated` | entfernt (Fehler) | zwei oder mehr Positionsargumente → alle löschen (wertgleich); unbekannte benannte Argumente → Bericht | AST (löschen) / nein | K 4.4 Nr. 6; kein Durchreich-Sink, nur `..deprecated` (Zweifelsfall 11) |
| `compact:` | `compact:` | unverändert | – | – | K 4.3 |
| `full:` | `subtotals:` | umbenannt | Wert bleibt | ja | A.5; benennt, was bei `true` da ist (Zwischensummen-Spalte je Aufgabe, Z. 593, 684), K 4.3; Wort steht in `words-en.txt` Gruppe N. Zur Spannung mit L9 (Schalter im Plural) siehe Zweifelsfall 15 |

### 1.13 `get-points`

```typ
// alt (Z. 373)
#let get-points(aufg, teil: none, idx: none) = {
// neu (A.5, dazu ..deprecated, Zweifelsfall 11)
#let get-points(task-number, subtask-number: none, index: none, ..deprecated) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `get-points` | `get-points` | unverändert | – | – | K 4.1 `get-<substantiv>` |
| `aufg` (positional) | `task-number` (positional) | umbenannt (nur in Signatur und Doku) | `none` als Positionsargument (fünf interne Aufrufe: Z. 990, 1012, 1101 sowie mit `teil:` Z. 1194, 1223) entfällt; intern `internal.task-points(index, subtask-number: none)` | – (Aufrufstellen unverändert) | G41, K 4.4 Nr. 3 |
| `teil:` | `subtask-number:` | umbenannt | Wert bleibt (`none` = Summe der Aufgabe, 0 = Aufgabe selbst, n = Teilaufgabe n) | ja | G41 |
| `idx:` | `index:` | umbenannt | Wert bleibt (ab 0); hat weiter Vorrang vor `task-number` | ja | G42 |
| – | `..deprecated` | neu | fängt `teil`, `idx`; `aufg` steht nicht in `renamed`, weil der Parameter nie benannt schreibbar war und `task-number` es auch nicht ist (ein benanntes `aufg:` ist ein unbekannter Parameter; im JSON-Anhang deshalb gestrichen). `task-number` ist `int`, `none` bricht mit „falscher Typ" ab. Der Funktionsname bleibt, alte Aufrufe landen also direkt in der neuen Funktion; ohne Sink endet `get-points(1, teil: 2)` in Typsts `unexpected argument: teil` (geprüft in `pruefung/auf/t2.typ`) | – | K 8.1, K 8.4, L24; Abweichung von A.5 (Zweifelsfall 11) |

### 1.14 `format-punkte` → `format-points`

```typ
// alt (Z. 86)
#let format-punkte(teil: false, points) = {
// neu (A.5, dazu ..deprecated, Zweifelsfall 11)
#let format-points(points, target: "task", ..deprecated) = { }  // target: "task" | "subtask"
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `format-punkte` | `format-points` | umbenannt | – | ja | G8, K 4.1 `format-<substantiv>` |
| `points` (positional, nach dem benannten) | `points` (führend) | unverändert | – | – | G8, K 4.4 Nr. 1 |
| `teil:` | `target:` | umbenannt, Typ geändert (bool → Auswahl) | `false` → Argument löschen (`"task"`); `true` → `"subtask"`. Die Argumente müssen nicht umgestellt werden: Typst nimmt benannte vor positionalen (`format-points(target: "subtask", 3)` läuft, `pruefung/auf/t3.typ`) | ja (Literale) | K 5.1 letzter Punkt (`target` = Ziel von `format-points`); Werte heißen wie die Schlüssel von `points-format` (W7). `target` steht in `dictionary(std)` (Typst 0.15.1) und hat keine Glossarzeile: nach K 4.5 eine Glossarlücke (Abschnitt 7); im Paketquelltext nur `std.target` (L13) |
| – | `..deprecated` | neu | fängt `teil` | – | K 8.4, K 9.2 (Zweifelsfall 11) |

### 1.15 `show-loesung` → `internal.task-solution`

```typ
// alt (Z. 151)
#let show-loesung(aufg, teil: false) = {
// neu (intern)
#let task-solution(record, subtask-number: none) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `show-loesung` | `internal.task-solution` | umbenannt, intern | öffentlicher Ersatz: `show-solutions(select: "current")` | nein (außerhalb nicht benutzt); alter Name bricht mit „gibt es nicht mehr – `show-solutions(select: …)`" ab | K 7.2; nimmt einen Datensatz, also keine Dokument-API |
| `aufg` (Datensatz) | `record` | umbenannt | – | – | K 2.2 (`aufg` ist Abkürzung); `records` in Wortliste N |
| `teil:` | `subtask-number:` | umbenannt, Default geändert | `false` → `none`; Zahl bleibt | – | G41, K 5.2 |

### 1.16 `show-loesung-inline` → `internal.task-solution-inline`

```typ
// alt (Z. 215)
#let show-loesung-inline(aufg) = {
// neu (intern)
#let task-solution-inline(record) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `show-loesung-inline` | `internal.task-solution-inline` | umbenannt, intern | öffentlicher Ersatz: `show-solutions(inline: true)` | nein; alter Name bricht ab | K 7.2 |
| `aufg` | `record` | umbenannt | – | – | wie 1.15 |

### 1.17 `show-material` → `internal.task-materials`

```typ
// alt (Z. 785)
#let show-material(aufg, start: 0) = {
// neu (intern)
#let task-materials(record, first-index: 0) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `show-material` | `internal.task-materials` | umbenannt, intern | öffentlicher Ersatz: `show-materials(select: "current")` | nein; alter Name bricht ab | K 7.2; außerdem Levenshtein-Abstand 1 zu `show-materials` (K 4.2) |
| `aufg` | `record` | umbenannt | – | – | wie 1.15 |
| `start:` | `first-index:` | umbenannt | Wert bleibt (Anzahl der schon gesetzten Materialien = Index des ersten, ab 0) | – | G42; `offset` ist als Dictionary `(dx:, dy:)` vergeben (G74, L6). Glossarlücke, siehe Abschnitt 7 |

### 1.18 `get-punkte-anzeige`, `get-punkte-position`

```typ
// alt (Z. 56, 65)
#let get-punkte-anzeige(opts) = {
#let get-punkte-position(opts) = {
// neu: entfällt
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `get-punkte-anzeige` | – | entfernt | intern `options.points` (Option ist nicht mehr zugleich String und Dictionary) | nein; bricht ab mit „gibt es nicht mehr – die Anzeige steht in der Option `points`" | K 5.1 („kein Parameter ist zugleich Auswahl und Einstellungs-Dictionary") |
| `get-punkte-position` | – | entfernt | intern `options.points-position` | nein; bricht ab | toter Code (Inventar 8, Z. 65–71) |
| `opts` | – | entfernt | – | – | Abkürzung (K 2.2) |

### 1.19 Neue Abfragen

```typ
// neu (A.5)
#let has-solutions() = { }      // options.solutions != none; braucht context
#let is-print() = { }           // internal.print-state.get(); braucht context
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| – (Dokumente lesen heute `state("options")` oder arbeitsblatts `loesungsmodus`) | `has-solutions` | neu | – | siehe arbeitsblatt | K 4.1 `has-<plural>`, K 6 |
| – (Dokumente lesen heute arbeitsblatts `print-state.get()`: 89 Aufrufe in 51 lokal gelesenen Dokumenten; der Schlüssel `"print"` im Options-State wird nirgends gelesen) | `is-print` | neu | `print-state.get()` → `is-print()` | ja (Regel steht in der Tabelle arbeitsblatt, hier im JSON unter `kontext`) | K 4.1 `is-<adjektiv>`, K 6 |

---

## 2. Optionen, Werte, Schlüssel

### 2.1 Options-State (Z. 41–53) → `internal.option-schema`

```typ
// alt
(
  loesungen: "keine",
  materialien: "seiten",
  workspaces: true,
  teilaufgabe-numbering: "a)",
  punkte: "aufgaben",
  punkte-position: "ende",
  punkte-template-aufgabe: punkte => [*#punkte BE*],
  punkte-template-teilaufgabe: punkte => [*[#punkte BE]*],
)
```

```typ
// neu (K 6, Spalte „Vorgabe arbeitsblatt, aufgaben")
(
  solutions: none,
  solutions-pagebreak: none,
  materials: "after-task",
  materials-pagebreak: "before",
  points: none,
  points-total: true,
  points-position: "end",
  points-format: auto,          // auto = (task: p => [*#p BE*], subtask: p => [*[#p BE]*])
  workspaces: true,
  shortcodes: "subtasks",
  subtask-numbering: "a)",
)
```

Das ist der Startwert des States. In `set-options` hat jeder dieser Parameter die Vorgabe `internal.unchanged` (1.7); `points-format: auto` heißt überall „Paketvorlage".

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `loesungen` | `solutions` + `solutions-pagebreak` | umbenannt, Typ geändert (ein Enum → zwei Auswahlen), Default `"keine"` → `none` (gleiche Wirkung) | siehe 2.2 | ja (Literale); teils (zwei Optionen) | G5, K 6, K 5.2 |
| `materialien` | `materials` + `materials-pagebreak` | umbenannt, Typ geändert, Default `"seiten"` → `"after-task"` + `"before"` (gleiche Wirkung) | siehe 2.2 | ja (Literale) | G9, K 6 |
| `workspaces` | `workspaces` | unverändert | – | – | G10 |
| `teilaufgabe-numbering` | `subtask-numbering` | umbenannt, Typ geändert (zwei feste Werte → Typst-Muster als str mit Paketregel: W3, nicht W9) | Regel: Enthält das Muster ein Zählzeichen, bekommt es die Teilnummer (`"a)"` → „b)"); enthält es zwei, bekommt es Aufgabennummer und Teilnummer (`"1.1"` → „3.2"); mehr als zwei ist ein „ungültiger Wert". `"a)"` bleibt; `"1."` → `"1.1"`. Solange die Compat-Tabelle läuft, ist `"1."` gesperrt (Fehler „`subtask-numbering: "1."` heißt jetzt `"1.1"`"), danach ist es ein gewöhnliches Muster („2."); der Docstring nennt die Sperre. Andere Werte: heute stiller Rückfall auf `"a)"` bzw. `"1.1"` (Inventar 5.2 Nr. 23), neu nach der Regel ausgewertet | ja (Literale) | G39, K 9.1. K 6 führt die Option als W9; der Durchreichtest scheitert aber (`numbering("a)", 1, 2)` ergibt „a)b)", `numbering("1.1", 2)` ergibt „2", `pruefung/auf/t1.typ`), siehe Zweifelsfall 12 |
| `punkte` (String) | `points` + `points-total` | umbenannt, Typ geändert, **Default geändert** (`"aufgaben"` → `none`) | siehe 2.2 | ja (Literale) | G8, K 6; zur Vorgabe siehe Zweifelsfall 3 |
| `punkte` (Dictionary `(anzeige:, position:)`) | `points`, `points-position` | Typ geändert (Dictionary → flache Geschwister) | `anzeige: x` → `points: <x abgebildet>`; `position: y` → `points-position: <y abgebildet>`. Fehlt `anzeige`, gilt heute `"aufgaben"` (Z. 58, 1154; arbeitsblatt Z. 314), nicht der Stand des States: `punkte: (position: "rand")` → `points: "tasks", points-position: "margin"`. Fehlt `position`, entsteht kein `points-position`; dann gilt ein daneben stehendes `punkte-position` (Z. 66–67, 1158–1159). Stehen `punkte.position` und `punkte-position` beide da, gewinnt `punkte.position`, der Codemod streicht das andere | AST | K 5.1, K 9.2 Pflichteintrag |
| `punkte.anzeige` | `points` | zusammengelegt | wie `punkte` | AST | wie oben |
| `punkte.position` | `points-position` | zusammengelegt | wie `punkte-position` | AST | G72 |
| `punkte-position` | `points-position` | umbenannt | `"ende"` → `"end"`; `"rand"` → `"margin"` | ja | G72, K 1.2 Schritt 3 |
| `punkte-template-aufgabe` | `points-format` (Schlüssel `task`) | zusammengelegt, Typ geändert (Funktion → W7) | `punkte-template-aufgabe: f` → `points-format: (task: f)`; Default `auto` = heutige Vorlage | AST | K 6, W7 |
| `punkte-template-teilaufgabe` | `points-format` (Schlüssel `subtask`) | zusammengelegt | `punkte-template-teilaufgabe: g` → `points-format: (subtask: g)`; beide zusammen → `(task: f, subtask: g)`; beide gleich → `points-format: f` | AST | K 6, W7 |
| – | `points-total` | neu | entsteht aus `"keine-summe"` | – | K 6, K 5.3 (kein Wert, der etwas Fehlendes benennt) |
| – | `solutions-pagebreak` | neu | entsteht aus `"seite"`, `"seiten"` | – | K 6 |
| – | `materials-pagebreak` | neu | entsteht aus `"seite"`, `"seiten"` | – | K 6 |
| – (arbeitsblatt `aufgaben-shortcodes`) | `shortcodes` | neu in aufgaben | Werte siehe Tabelle arbeitsblatt | siehe arbeitsblatt | G90, L17: der Options-State hält das ganze Schema |
| `"print"` (Fremdschlüssel, arbeitsblatt Z. 578, nie gelesen) | – | entfernt | `internal.print-state` (2.4) | nein (Paketquelltext) | L17 |

### 2.2 Enum-Werte

**Optionen des Schemas.** Die Abbildung hängt davon ab, wo der Wert steht:

- **Im Kopf** (`arbeitsblatt`, `arbeitsblatt-einzeln`, `klassenarbeit`) ist ein fehlendes Argument die Vorgabe der Vorlage. Ein Wert, der dieser Vorgabe entspricht, darf gelöscht werden. Maßgeblich sind die Tabellen arbeitsblatt und klassenarbeit (bei `klassenarbeit` ist die Vorgabe von `points` eine andere); die Spalte unten gilt für `arbeitsblatt`.
- **In `set-options` und in `variant-overrides`** heißt ein fehlendes Argument „unverändert" (1.7). Heute setzt `set-options((loesungen: "keine"))` den Wert aktiv (Z. 113–117, `curr + options`). Deshalb löscht der Codemod dort nie ein Argument, und bei jedem Wert, der zu zwei Optionen gehört, schreibt er beide Geschwister aus: ein früherer Aufruf oder der Kopf kann das Geschwister gesetzt haben.

| Stelle | alter Wert | neu im Kopf (`arbeitsblatt`) | neu in `set-options`, `variant-overrides` | Codemod | Begründung |
|---|---|---|---|---|---|
| `loesungen` | `"keine"` | Argument löschen (= `solutions: none`) | `solutions: none` | ja | K 5.2 |
| `loesungen` (nur über arbeitsblatt) | `false`, `"false"`, `none` | Argument löschen | `solutions: none` | ja | K 5.2 |
| `loesungen` | `"sofort"` | `solutions: "in-place"` | `solutions: "in-place", solutions-pagebreak: none` | ja | K 6 |
| `loesungen` | `"folgend"` | `solutions: "after-task"` | `solutions: "after-task", solutions-pagebreak: none` | ja | K 6 |
| `loesungen` | `"seite"` | `solutions: "at-end", solutions-pagebreak: "before"` | wie im Kopf | ja | K 6, K 9.2 |
| `loesungen` | `"seiten"` | `solutions: "at-end", solutions-pagebreak: "per-task"` | wie im Kopf | ja | K 6; Abstand `"seite"`/`"seiten"` war 1 (L10) |
| `loesungen` | `"nur"` | `solutions: "only"` | `solutions: "only", solutions-pagebreak: none` | ja | K 6 |
| `loesungen` (nur über arbeitsblatt) | `"reinquetschen"` | `solutions: "at-end"` | `solutions: "at-end", solutions-pagebreak: none` | ja | K 6, K 9.2 („zwei Optionen") |
| `materialien` | `"keine"` | `materials: none` | `materials: none` | ja | K 5.2 |
| `materialien` (nur über arbeitsblatt) | `false`, `"false"`, `none` | `materials: none` | `materials: none` | ja | K 5.2 |
| `materialien` | `"sofort"` | `materials: "after-task", materials-pagebreak: none` | wie im Kopf | ja | K 6 |
| `materialien` | `"folgend"` | `materials: "after-task", materials-pagebreak: none` | wie im Kopf | ja | K 6; heute schon Alias von `"sofort"` (Z. 1076, 1290) |
| `materialien` | `"seiten"` | Argument löschen (= Vorgabe `"after-task"` + `"before"`) | `materials: "after-task", materials-pagebreak: "before"` | ja im Kopf; in `set-options`/Varianten ausdrücklicher Wert | K 9.2 Pflichteintrag (gilt nur für den Kopf, siehe Zweifelsfall 13) |
| `materialien` | `"seite"` | `materials: "at-end", materials-pagebreak: "before"` | wie im Kopf | ja | K 6 |
| `materialien` (nur über arbeitsblatt) | `"reinquetschen"` | `materials: "at-end", materials-pagebreak: none` | wie im Kopf | ja | K 6 |
| `punkte`, `punkte.anzeige` | `"keine"` | `points: none` | `points: none` | ja | K 5.2 |
| `punkte`, `punkte.anzeige` | `"aufgaben"` | `points: "tasks"` | `points: "tasks", points-total: true` | ja | K 6 |
| `punkte`, `punkte.anzeige` | `"teilaufgaben"` | `points: "subtasks"` | `points: "subtasks", points-total: true` | ja | K 6 |
| `punkte`, `punkte.anzeige` | `"alle"` | `points: "all"` | `points: "all", points-total: true` | ja | K 6 |
| `punkte`, `punkte.anzeige` | `"keine-summe"` | `points: "all", points-total: false` | wie im Kopf | ja | K 6, K 9.2 |
| `punkte-position`, `punkte.position` | `"ende"` | `points-position: "end"` | wie im Kopf | ja | K 6 |
| `punkte-position`, `punkte.position` | `"rand"` | `points-position: "margin"` | wie im Kopf | ja | K 6 |
| `teilaufgabe-numbering` | `"a)"` | `"a)"` | wie im Kopf | – | K 2.4 (Muster sind Werte) |
| `teilaufgabe-numbering` | `"1."` | `"1.1"` | wie im Kopf | ja | Regel in 2.1; `"1."` ist während der Compat-Laufzeit gesperrt (Zweifelsfall 12) |

**Übrige Werte** (hängen nicht vom Ort ab):

| Stelle | alter Wert | neu | Art | Codemod | Begründung |
|---|---|---|---|---|---|
| `aufgabe(method:)` | `""` | `none` (Argument löschen) | Wert geändert | ja | K 5.2, K 9.2 |
| `aufgabe(method:)` | `"EA"` | `"individual"` | umbenannt | ja | G89 |
| `aufgabe(method:)` | `"PA"` | `"pair"` | umbenannt | ja | G89 |
| `aufgabe(method:)` | `"GA"` | `"group"` | umbenannt | ja | G89 |
| `aufgabe(title:)` | `""` | Argument löschen | Wert geändert; **PDF ändert sich** (heute „Aufgabe n −") | ja | K 5.2, K 9.2 |
| `aufgabe(workspace:)` | `false` | Argument löschen | Wert geändert; **PDF ändert sich** (heute Text „false") | ja | K 5.2 |
| `teilaufgabe(workspace:)` | `false` | Argument löschen | Wert geändert, wertgleich (Z. 1242) | ja | K 5.2 |
| `show-bewertung(<pos>)` (genau ein Argument) | `true` | `possible: "shown"` (Argument löschen) | Typ geändert | AST | W2 |
| `show-bewertung(<pos>)` (genau ein Argument) | `false` | `possible: "fields"` | Typ geändert | AST | W2, K 5.3 |
| `show-bewertung(<pos>)` (genau ein Argument) | `none` | `possible: none` | Typ geändert | AST | W2, `none` ist das Aus |
| `show-loesung(teil:)`, `show-loesungen(teil:)` | `false` | `subtask-number: none` | Wert geändert | ja | K 5.2 |
| `show-loesung(teil:)`, `show-loesungen(teil:)` | int | int | unverändert | – | G41 |
| `get-points(teil:)` | `none`, int | `none`, int | unverändert | – | G41 |
| `show-loesungen(curr:)`, `show-materialien(curr:)` | `false` / `true` | `select: "all"` / `"current"` | Typ geändert | ja | G86 |
| `show-erwartungen(alle:)` | `false` / `true` | `select: "current"` / `"all"` | Typ geändert | ja | G86 |
| `format-punkte(teil:)` | `false` / `true` | `target: "task"` / `"subtask"` | Typ geändert | ja | K 5.1 |

Neue Werte ohne Vorgänger: `select: "pending"` bei `show-solutions` (ersetzt die Funktion `show-offene-loesungen`).

### 2.3 Datensatz einer Aufgabe (Z. 945–952, 1340–1344, 1394–1398)

Nur intern (`internal.records-state`); kein Dokument schreibt die Schlüssel. Die Gestalt ändert sich, deshalb neuer State-Schlüssel mit `@1` (K 7.3).

```typ
// alt
(nummer: ct_aufgaben, title: actual-title, teile: 0, loesung: (), materialien: (), erwartungen: ())
// neu
(task-number: 1, title: none, subtask-count: 0,
 solution-records: (), material-records: (), expectation-records: ())
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `nummer` | `task-number` | umbenannt | – | – | G41 |
| `title` | `title` | unverändert | `[]` wird beim Anlegen zu `none` normalisiert (heute erst beim Hook-Aufruf, Z. 994) | – | G13 |
| `teile` | `subtask-count` | umbenannt | – | – | G38 `<ding>-count` |
| `loesung` | `solution-records` | umbenannt | – | – | L6: `solutions` ist Auswahl; Bestimmungswort im Singular (K 4.2) |
| `loesung[].teil` | `subtask-number` | umbenannt | 0 = Aufgabe selbst | – | G41 |
| `loesung[].body` | `body` | unverändert | – | – | G79 |
| `materialien` | `material-records` | umbenannt | – | – | L6: `materials` ist Auswahl |
| `materialien[].body` | `body` | unverändert | – | – | G79 |
| `erwartungen` | `expectation-records` | umbenannt | – | – | L6: `expectations` ist W6 |
| `erwartungen[].teil` | `subtask-number` | umbenannt | – | – | G41 |
| `erwartungen[].text` | `body` | umbenannt | – | – | G79 (`text` verboten); gleicher Name wie im Lösungseintrag |
| `erwartungen[].punkte` | `points` | umbenannt | – | – | G8 |

### 2.4 States, Counter, Variablen

Alle werden genau einmal in `src/internal.typ` angelegt (K 7.3, L20). Kein Schlüssel wird mit einer älteren Paketversion geteilt.

| alt (Variable) | alter Schlüssel | neu (`internal.…`) | neuer Schlüssel | Art | Begründung |
|---|---|---|---|---|---|
| `_state_aufgaben` | `state("aufgaben")` | `records-state` | `"schule/aufgaben/records@1"` | umbenannt | K 7.3 (Beispiel) |
| `_state_options` | `state("options")` | `options-state` | `"schule/aufgaben/options@1"` | umbenannt | K 7.2 (Beispiel) |
| `_counter_aufgaben` | `counter("aufgaben")` | `task-counter` | `"schule/aufgaben/task-counter@1"` | umbenannt | K 7.3 (Beispiel) |
| `_state_current_aufgabe_index` | `"current_aufgabe_index"` | `task-index-state` | `"schule/aufgaben/task-index@1"` | umbenannt | G42 (ab 0), `current` entfällt als Füllwort |
| `_state_current_material_aufgabe` | `"current_material_aufgabe"` | `material-task-number-state` | `"schule/aufgaben/material-task-number@1"` | umbenannt | G41 |
| `_state_current_material_index` | `"current_material_index"` | `material-number-state` | `"schule/aufgaben/material-number@1"` | umbenannt | Wert zählt ab 1, also `number`, nicht `index` (G41, G42) |
| `_state_in_loesung` | `"in_loesung"` | `in-solution-state` | `"schule/aufgaben/in-solution@1"` | umbenannt | G5 |
| `_state_loesungen_gezeigt` | `"loesungen_gezeigt"` | `shown-task-count-state` | `"schule/aufgaben/shown-task-count@1"` | umbenannt | der Wert ist die Anzahl der Aufgaben, deren Lösungen schon ausgegeben sind (Z. 282–287): G38 `<ding>-count`; Bestimmungswort im Singular (K 4.2) |
| `_state_in_aufgabe` | `"in_aufgabe"` | `in-task-state` | `"schule/aufgaben/in-task@1"` | umbenannt | G3 |
| `_state_in_teilaufgabe` | `"in_teilaufgabe"` | `in-subtask-state` | `"schule/aufgaben/in-subtask@1"` | umbenannt | G4 |
| `_state_ta_material_vorher` | `"ta_material_vorher"` | `material-count-before-state` | `"schule/aufgaben/material-count-before@1"` | umbenannt | der Wert ist die Anzahl der Materialien vor der Teilaufgabe (Z. 1142): G38; K 2.2 (`ta` ist Abkürzung), K 4.2 (Singular) |
| `_state_theme` | `"ab-theme"` | `theme-state` | `"schule/aufgaben/theme@1"` | umbenannt | K 7.3: echter Paketname des Besitzers |
| `print-state` (arbeitsblatt Z. 180, öffentlich ohne Unterstrich; geschrieben Z. 582, gelesen Z. 1306, 1329), dazu der Fremdschlüssel `"print"` im Options-State (arbeitsblatt Z. 578, nie gelesen) | `state("print", false)` | `print-state` | `"schule/aufgaben/print@1"` | zusammengelegt, umgezogen von arbeitsblatt nach aufgaben | L17, A.5 (`is-print` liegt in aufgaben). Es gibt künftig genau einen Print-State; arbeitsblatt legt keinen eigenen mehr an (3.2) |

Zu den Namen: Alle 13 tragen das Suffix `-state` bzw. `-counter`, das L4 als Affix verbietet, und `print-state` steht in G55 wörtlich als verbotenes Synonym für `print` (L3). K 7.2 gibt aber selbst `internal.options-state` als Beispiel und nimmt interne Namen von der Glossarpflicht aus. Diese Tabelle folgt K 7.2 und K 7.3; der Widerspruch ist in Abschnitt 7 gemeldet.

Weitere Kennungen:

| alt | neu | Art | Codemod | Begründung |
|---|---|---|---|---|
| Label `<_aufgaben-reset>` an `metadata("aufgaben-reset")` (Z. 136) | `<schule-aufgaben-reset>` an `metadata("reset")` | umbenannt | – (kein Dokument fragt das Label ab) | K 7.3 Labelmuster |
| `figure(kind: "aufgabe")` | `figure(kind: "task")` | umbenannt; **bricht still** (ein Selektor mit altem Wert trifft nichts mehr, eine Fehlermeldung ist nicht möglich) | ja (Literale): `figure.where(kind: "aufgabe")` und `.kind == "aufgabe"` → neuer Wert; alles andere Bericht. Bestand: 0 Treffer in den lokal lesbaren Dokumenten (gezählt 2026-11-15) | K 2.1 (ein Dokument kann `figure.where(kind: …)` schreiben), G3; im Paket als `internal.task-figure-kind`; Glossarlücke und Zweifelsfall 8 |
| `figure(kind: "teilaufgabe", supplement: "Teilaufgabe")` | `figure(kind: "subtask", supplement: "Teilaufgabe")` | umbenannt (Supplement bleibt deutsch, Ausgabe); **bricht still** wie oben | ja (Literale), Rest Bericht; 0 Treffer im lokalen Bestand. Im Repo hängen drei Stellen von arbeitsblatt daran (3.2) | G4, K 2.1; im Paket als `internal.subtask-figure-kind` |
| `figure(kind: "material")` | `figure(kind: "material")` | unverändert | – | G9 |

### 2.5 Interne Hilfsfunktionen (heute mit Unterstrich, per `*` sichtbar)

| alt | neu (`internal.…`) | Art | Begründung |
|---|---|---|---|
| `_theme-hook(name)` | `theme-hook(name)` | umbenannt | K 7.2 |
| `_zusammen(inhalt, above: auto, below: auto)` | `keep-together(above: auto, below: auto, body)` | umbenannt | G79 (`inhalt` → `body`, zuletzt) |
| `_loesung-kasten(titel, body)` | `solution-callout(title: none, body)` | umbenannt | G76, gleiche Parameter wie Hook `solution` |
| `_be-runden(p)` | `round-points(points)` | umbenannt | G8 (`be` verboten) |
| `_be-anzeige(p)` | `points-text(points)` | umbenannt | G8 |
| `_aufgaben-final()` | `final-records()` | umbenannt | Wortliste (`records`) |
| `_rechter-textrand()` | `right-text-edge()` | umbenannt | K 2.4 |
| `_erwartungen-zeilen(all, opts, grouped, erreicht)` | `expectation-rows(records, options, grouped: false, achieved: false)` | umbenannt; Schalter benannt | K 4.4 Nr. 3 |
| `_ist-flex-workspace(ws)` | `is-flex-area(body)` | umbenannt | A.7 (gleicher Name wie in patterns), K 4.1 `is-<adjektiv>` |
| `_flex-fest(ws)` | `fixed-flex-area(body)` | umbenannt | A.7 |
| – | `task-points(index, subtask-number: none)` | neu | ersetzt die fünf internen Aufrufe `get-points(none, idx: …)` (Z. 990, 1012, 1101) und `get-points(none, teil: …, idx: …)` (Z. 1194, 1223) |
| – (Musterlogik dreifach: Z. 1171–1177, Lösungen/Horizont/Tabelle, arbeitsblatt Z. 391–398) | `subtask-number-text(task-number, subtask-number)` | neu | wertet `subtask-numbering` nach der Regel aus 2.1 aus; einzige Stelle |
| – | `unchanged` | neu | Markierwert „nicht angegeben" als Vorgabe in `set-options` (1.7) |
| – (Zeichenketten `"aufgabe"`, `"teilaufgabe"` an sechs Stellen) | `task-figure-kind`, `subtask-figure-kind` | neu | Konstanten für `figure(kind:)`; arbeitsblatt benutzt sie statt eigener Literale (3.2) |
| – | `fail(function, message)`, `check(…)`, `option-schema` | neu | K 8.1, K 8.4, K 6 |

Ob die Wortliste (L2) und die Verbliste (K 4.1) für Namen in `internal` gelten, lässt KONVENTION offen; siehe Abschnitt 7. Diese Tabelle wendet auf `internal` nur K 2.4 an (K 7.2).

### 2.6 Theme-Hooks (Schlüssel in `internal.theme-state`, Z. 19–31, 962, 992–999, 1053, 1057)

Die neuen Namen folgen A.12 wörtlich. Hooks sind Schlüssel des Theme-Dictionary und deshalb englisch; sie tragen das Parameterwort des Bausteins, den sie zeichnen (K 2.1b, K 4.4 Nr. 7): der Hook `task` zeichnet den Baustein `aufgabe`, `subtask` zeichnet `teilaufgabe`, `solution` zeichnet `loesung`. Die rechte Spalte nennt also Schlüssel, keine Funktionen. Zwei Dinge sind für den Codemod wichtig: (1) Ein Hook-Name ist ein Dictionary-Schlüssel und braucht das AST-Werkzeug (K 9.4 Nr. 2). (2) Die Parameter des Hooks `aufgabe` sind Parameterdeklarationen einer Closure, deren Namen im Rumpf als Variablen benutzt werden (themes.typ Z. 210–223: `… titel … if punkte != none { … punkte }`). Sie lassen sich nicht durch Namensersetzung umbenennen; der Prototyp `technik/codemod.py` kennt nur benannte Argumente in Aufrufen. Die acht `aufgabe`-Hooks werden deshalb als Ganzes von Hand umgestellt.

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `aufgabe` (Hook, Schlüssel) | `task` (Hook, Schlüssel) | umbenannt | – | AST (Dictionary-Schlüssel; nur themes.typ und eigene Theme-Dictionaries) | A.12 |
| Hook `aufgabe`: `nummer:` + `number:` | Hook `task`: `marker:` | zusammengelegt, Typ geändert (int + bool → content oder `none`) | `number: false` → `marker: none`; sonst `marker:` = Aufgabennummer als Inhalt (`[1]`); im Theme `if number { kachel(str(nummer)) }` → `if marker != none { kachel(marker) }` | nein (Theme-Code von Hand, 8 Themes: themes.typ Z. 210, 349, 473, 585, 701, 832, 945, 1066) | A.12, Anhang C („Hook `task` bekommt `marker`"); weicht von G43 ab (Zweifelsfall 4) |
| Hook `aufgabe`: `titel:` | Hook `task`: `title:` | umbenannt | – | nein (Closure-Parameter, von Hand zusammen mit `marker`) | A.12, G13 |
| Hook `aufgabe`: `icons:` | Hook `task`: `icons:` | unverändert | enthält weiter das Icon aus `method` | – | G77 |
| Hook `aufgabe`: `punkte:` | Hook `task`: `points:` | umbenannt | Wert weiter fertig formatierter Inhalt oder `none` | nein (Closure-Parameter, von Hand) | A.12; Grundtyp content weicht von G8 ab (Zweifelsfall 4) |
| Hook `aufgabe`: `large:` | Hook `task`: `large:` | unverändert | – | – | K 4.3 |
| Hook `teilaufgabe`, Argument `label` | Hook `subtask`, Argument `marker` | umbenannt (Schlüssel; das eine Argument bleibt positional, der Parametername in der Closure ist frei) | – | AST (Schlüssel) | A.12, G43 |
| Hook `loesung`, Argumente `titel, body` | Hook `solution`, Argumente `title: none, body` | umbenannt, `titel` positional → `title` benannt | – | nein (Theme-Code von Hand) | A.12 |
| Hook `loesung-kopf`, Argument `titel` | Hook `solution-heading`, Argument `title` | umbenannt (Schlüssel; Argument positional) | – | AST (Schlüssel) | A.12, K 4.2 (Bestimmungswort im Singular) |
| Hook `material-kopf`, Argument `titel` | Hook `material-heading`, Argument `title` | umbenannt (Schlüssel; Argument positional) | – | AST (Schlüssel) | A.12 |
| Hook `marke`, Argument `nummer` | Hook `task-marker`, Argument `task-number` | umbenannt (Schlüssel; Argument positional) | Vorhandensein schaltet weiter die hängende Darstellung ein | AST (Schlüssel) | A.12, G41 |
| `marke-breite` | `task-marker-width` | umbenannt | Länge, Vorgabe `2.2em` bleibt | AST (Schlüssel) | A.12, G31 |

Die Hook-Namen sind durch die Neufassung von K 4.4 Nr. 7 und L18 gedeckt: Ein Hook heißt wie das Parameterwort eines Bausteins oder ist ein Kompositum daraus (`task-marker`, `solution-heading`). Zwei Reste passen weiter nicht zusammen: (1) L18 verlangt, dass ein Hook nur Parameternamen hat, die der gezeichnete Baustein auch hat; der Baustein `aufgabe` hat aber weder `marker` noch `points`, und `loesung(body)` hat kein `title`. (2) `material-heading` ist ein Kompositum aus `material`, das kein Baustein ist und nicht in `wortpaare.json` steht. Diese Tabelle begründet die Hooks deshalb mit A.12; der Rest des Widerspruchs ist in Abschnitt 7 gemeldet.

Unbekannte Schlüssel im Theme-Dictionary sind künftig ein Fehler (A.12, L18); heute werden sie ignoriert.

---

## 3. Öffentliche Oberfläche

### 3.1 Künftig exportiert (`src/lib.typ`, namentlich)

Eigene Namen (17):

```
aufgabe  teilaufgabe  teilaufgaben  loesung  erwartung  material
set-options  reset-tasks
show-solutions  show-materials  show-expectations  show-points-table
get-points  format-points  has-solutions  is-print
internal
```

`internal` ist nach K 7.1 in jedem @schule-Paket exportiert. Bei `: *`-Importen aus zwei Paketen (1474 von 1576 Importen im Bestand) überschreibt das zuletzt importierte `internal` das frühere ohne Meldung (geprüft in `pruefung/auf/t4.typ`). Für Dokumente ist das folgenlos, solange sie `internal` nicht benutzen (K 7.2); für Paketquelltext gilt die Importregel in 3.2. Hinweis an KONVENTION in Abschnitt 7.

Die fünf Bausteine `aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung` stehen in `bausteine-de.txt` (K 2.1a) und werden hier genau einmal definiert (L23a); arbeitsblatt und klassenarbeit reichen sie namentlich durch. `material` ist sprachgleich und läuft über `words-en.txt`. Übergangsnamen und Aliase gibt es nicht (K 9.3): Kein Baustein ist an einen zweiten Namen gebunden (L23c), und keiner der englischen Zwillinge aus `zwillinge.txt` wird exportiert (L27c). Wer einen davon schreibt, bekommt Typsts „unknown variable"; einen Stub gibt es dafür nicht.

Abbrechende Altnamen (Stubs in `src/removed.typ`), solange die Compat-Tabelle läuft (K 9.3, L24): `reset-aufgaben`, `show-loesungen`, `show-offene-loesungen`, `show-materialien`, `show-erwartungen`, `show-bewertung`, `format-punkte`, `show-loesung`, `show-loesung-inline`, `show-material`, `get-punkte-anzeige`, `get-punkte-position`.

### 3.2 Künftig intern (`src/internal.typ`, Zugriff nur als `aufgaben.internal.…`)

- Alle 12 States und Counter aus 2.4 und `print-state`.
- Alle Hilfsfunktionen aus 2.5, darunter `task-points`, `subtask-number-text`, `unchanged`, `task-figure-kind`, `subtask-figure-kind`.
- Die drei Renderer `task-solution`, `task-solution-inline`, `task-materials`.
- `option-schema`, `check`, `fail`.

Importregel für Paketquelltext: arbeitsblatt, klassenarbeit und mathematik importieren aufgaben als Modul (`#import "@schule/aufgaben:0.4.1" as aufgaben`) und greifen mit `aufgaben.internal.…` zu; `internal` wird nie namentlich importiert, sonst kollidiert es mit dem eigenen `internal` des Pakets. arbeitsblatt und klassenarbeit reichen `aufgaben.internal` nicht durch.

Folgen für andere Pakete (heutige Zugriffe laut Inventar Abschnitt 6 und Quelltext):

| heute in arbeitsblatt 0.4.0 | künftig |
|---|---|
| `_state_options` (Z. 391, 397, 1494), `state("options", (:))` (Z. 1179, 1307, 1330) | `aufgaben.internal.options-state`; kein roher `state("…")` (L20) |
| `_state_aufgaben` (Z. 711, 715) | `aufgaben.internal.records-state` |
| `_state_current_material_aufgabe`, `_state_current_material_index` (Z. 378, 379, 656, 657) | `aufgaben.internal.material-task-number-state`, `…material-number-state` |
| `_counter_aufgaben` (Z. 383, 661) | `aufgaben.internal.task-counter` |
| `_state_theme` (Z. 616, 1522) | `aufgaben.internal.theme-state` |
| `_state_in_loesung` (Z. 695) | `aufgaben.internal.in-solution-state` |
| `set-options(("print": print, …))` (Z. 573–580) | `set-options(…)` mit Schema-Namen, ohne `print` |
| `print-state` = `state("print", false)` (Z. 180; geschrieben Z. 582, gelesen Z. 1306, 1329) | kein eigener Print-State mehr: arbeitsblatt schreibt `aufgaben.internal.print-state.update(print)` und liest `aufgaben.is-print()`. `print-state` wird nicht mehr exportiert. Dokumente: `print-state.get()` → `is-print()` (89 Aufrufe in 51 lokal gelesenen Dokumenten; Codemod-Regel in der Tabelle arbeitsblatt). Ein übersehener Aufruf endet in Typsts `unknown variable: print-state`, weil ein State-Name keine „heißt jetzt"-Meldung tragen kann **[prüfen: in Tabelle arbeitsblatt als bekannte Lücke von K 9.1 führen]** |
| `el.kind == "teilaufgabe"` (Z. 389), `counter(figure.where(kind: "aufgabe" / "teilaufgabe"))` (Z. 394–398), `show figure.where(kind: "teilaufgabe")` (Z. 679) | `aufgaben.internal.task-figure-kind`, `aufgaben.internal.subtask-figure-kind` statt Zeichenketten; der Nummerntext (Z. 391–398) kommt aus `aufgaben.internal.subtask-number-text(…)`. Ohne diese Umstellung fielen Verweise `@label` auf Teilaufgaben ohne Meldung auf Typsts Standarddarstellung zurück |
| `src/themes.typ`: acht Theme-Dictionaries mit den Hooks `aufgabe`, `teilaufgabe`, `loesung`, `loesung-kopf`, `material-kopf`, `marke`, `marke-breite` | Schlüssel und Closure-Parameter nach 2.6 (von Hand) |
| `show-offene-loesungen()`, `show-materialien()`, `show-loesungen()` (Z. 707, 712, 716) | `show-solutions(select: "pending")`, `show-materials()`, `show-solutions()` |
| `reset-aufgaben()` (Z. 615) | `reset-tasks()` |

| heute in klassenarbeit 0.4.0 (`src/klassenarbeit.typ`) | künftig |
|---|---|
| `set-options((punkte-template-aufgabe: …, punkte-template-teilaufgabe: …))` (Z. 217–220; einzige Stelle im Repo, die diese Schlüssel setzt) | `set-options(points-format: (task: f, subtask: g))` |
| `show-offene-loesungen()` (Z. 305) | `show-solutions(select: "pending")` |
| `show-erwartungen(..einstellungen)` (Z. 314–327; reicht die Schlüssel `grouped`, `erreicht`, `alle`, `teile` durch und entfernt `show` und `new-page`) | `show-expectations(..einstellungen)` mit den Schlüsseln `select`, `blocks`, `grouped`, `achieved` (W6: genau die Parameter der Funktion); das Entfernen von `show` und `new-page` entfällt. Die Vorgabe bleibt „aktueller Block" |
| `_state_ab_scope` und weitere Zugriffe | siehe Tabelle klassenarbeit |

| heute anderswo | künftig |
|---|---|
| `mathematik/0.0.2/mathematik.typ` Z. 39: `import "@schule/aufgaben:0.1.2": loesung, teilaufgabe` | Pin heben (K 9.4 Nr. 1); `loesung`, `teilaufgabe` aus der Zielversion (die Namen bleiben); die eigene Kopie von `teilaufgaben` dort entfällt zugunsten von `aufgaben.teilaufgaben` (1.3) |
| `tests/aufgaben-*.typ` (fünf der sieben Dateien pinnen aufgaben direkt und benutzen `set-options((…))`, `show-bewertung()`, `show-erwartungen()`, `get-points(0)`) | neue Aufrufformen; `set-options(points: "tasks")` wegen der neuen Vorgabe (Zweifelsfall 3) |
| `tests/ka-*.typ` (`ka-erwartungen-alle`, `ka-punkte-template`) | `expectations: (select: "all", blocks: (…))`, `points-format: (…)`; maßgeblich Tabelle klassenarbeit |

### 3.3 Entfallende Re-Exporte

| heute | künftig | Ersatz für Nutzer |
|---|---|---|
| `#import "@preview/fontawesome:0.6.0": *` (Z. 1), alle `fa-*`-Namen | entfällt; aufgaben importiert nur `fa-user-large`, `fa-user-group`, `fa-users` namentlich und exportiert sie nicht | `fa-icon` kommt über arbeitsblatt (`fremdnamen.txt`, K 7.1); alles andere: `#import "@preview/fontawesome:0.6.0": fa-…` im Dokument |
| `#import "@preview/gentle-clues:1.2.0": *` (Z. 2), alle Clue-Funktionen einschließlich des Kastens `task` | entfällt, auch für den Kasten `task`: Es gibt keine eigene Funktion dieses Namens, ein übersehener Aufruf endet in Typsts `unknown variable: task` und bekommt keine andere Bedeutung (1.1, K 7.1); aufgaben importiert nur `goal` namentlich (für den Lösungskasten ohne Theme) | die 15 Kästen sind eigene Funktionen von arbeitsblatt (K 7.1, A.11); wer `clue` selbst braucht: `#import "@preview/gentle-clues:1.2.0": clue` |
| alle Namen mit Unterstrich (22 Stück, Inventar 1.2) | nicht mehr exportiert; nur noch unter `internal` | keiner; Dokumente benutzen `internal` nicht (K 7.2). Abfragen: `has-solutions()`, `is-print()`, `get-points(…)` |

aufgaben exportiert nur Eigenes (K 7.1).

---

## 4. Fehler und Altlasten, die mit der Umbenennung behoben werden (nur API)

| Nr. | Fundstelle | Befund | Behebung |
|---|---|---|---|
| 1 | Z. 113–117 | `set-options` prüft weder Schlüssel noch Werte; `loesungen: "sofrt"` schaltet still ab | deklarierte Parameter, `internal.check` mit Tippfehlervorschlag (K 8.4) |
| 2 | Z. 1363–1384 | `erwartung(punkte: 2)[…]` ergibt still 0 Punkte; Reihenfolge der Argumente beliebig | Sink geprüft, Punkte nur vorn (K 4.4 Nr. 4, Nr. 6) |
| 3 | Z. 1383 | Fehlermeldung in `erwartung` nennt `aufgabe` (Kopie von Z. 919); Z. 1380 sachlich ungenau; alle drei Meldungen englisch | `internal.fail("erwartung", …)` (Meldung beginnt mit `aufgaben.erwartung: `), deutsch, Format K 8.2 |
| 4 | Z. 595–600 | `show-bewertung` verschluckt benannte Argumente im Sink und überzählige Positionsargumente | `possible:` deklariert; kein Durchreich-Sink, nur `..deprecated`, der jedes übrige Argument meldet |
| 5 | Z. 687–693 | dritter Zweig `else if punkte == true` unerreichbar; `none` nur zufällig „Zeile weglassen" | Auswahl `possible` mit drei benannten Zuständen |
| 6 | Z. 914–917 | positionaler Titel überschreibt `title:` still | Fehler „zweiter Weg" (K 8.3) |
| 7 | Z. 898, 936–938 | `method: "XY"` wird still ignoriert; Aus ist `""` | W2 mit Prüfung; Aus ist `none` |
| 8 | Z. 1065 gegen Z. 1242 | `workspace: false` wird in `teilaufgabe` wie `none` behandelt, in `aufgabe` als Text gesetzt | in beiden Fehler „falsches Aus" (K 5.2) |
| 9 | Z. 48–49, 56–71, 1153–1162 | Punkteanzeige doppelt konfigurierbar (String oder Dictionary, dazu `punkte-position`); Logik dreifach vorhanden; `get-punkte-position` tot | flache Optionen `points`, `points-total`, `points-position`; beide Helfer entfallen |
| 10 | Z. 1171–1177 gegen Z. 177, 198–202, 255, 439–443, 713–717, 1329, 1251–1253 | `teilaufgabe-numbering`: Rückfall bei unbekanntem Wert ist an der Teilaufgabe `"a)"`, in Lösungen, Erwartungshorizont und Tabelle `"1.1"`; `"1."` bedeutet `"1.1"` | `subtask-numbering` ist ein Typst-Muster mit einer Paketregel (2.1), ausgewertet an genau einer Stelle (`internal.subtask-number-text`), kein Rückfall; `"1."` wird während der Compat-Laufzeit mit „heißt jetzt `"1.1"`" abgewiesen |
| 11 | Z. 292–297 | Doc von `show-loesungen` nennt `teil (boolean)` und beschreibt eine Zahl | `subtask-number: none` (W4 int); Docstring aus der Signatur (L26) |
| 12 | Z. 360–372 | Doc von `get-points` ohne `idx` | `index` dokumentiert (L26) |
| 13 | Z. 151, 299 gegen Z. 373 | `teil: false` gegen `teil: none` für „kein Wert"; `teil` hat vier Bedeutungen | überall `subtask-number: none`; `target` für die Vorlagenwahl; `subtask-count` für die Anzahl; `blocks` für die Überschriften der Abschnitte |
| 14 | Z. 22–26, 962, 1053, 1057 | Hooks `marke`, `marke-breite` benutzt, aber nicht dokumentiert; Hook `aufgabe` hat `nummer` und `number` nebeneinander | A.12: `task-marker`, `task-marker-width`, `marker`; Theme-Dictionary wird geprüft (L18) |
| 15 | Z. 947 gegen Z. 994 gegen Z. 37 | derselbe Titel heißt `title` (Datensatz), `titel` (Hook), `titel` (Helfer) | überall `title` |
| 16 | Z. 949–951, 1343, 1397 | Datensatz `loesung` Singular neben `materialien`, `erwartungen`; Einträge `body` gegen `text` | `solution-records`, `material-records`, `expectation-records`; überall `body` |
| 17 | Z. 5–14, 27, 41, 98 | State-Schlüssel ohne Paketpräfix (`"options"`, `"aufgaben"`, `"in_loesung"`), geteilt mit allen Altversionen; `state("aufgaben")` und `counter("aufgaben")` gleichnamig | Schlüssel nach K 7.3 |
| 18 | Z. 1–2 | `*`-Importe reichen fontawesome und gentle-clues an alle abhängigen Pakete durch (darunter ein fremder `task`) | namentliche Importe, keine Re-Exporte (L19) |
| 19 | arbeitsblatt Z. 578 und Z. 180 | `"print"` als Fremdschlüssel im Options-State (nie gelesen), daneben ein zweiter, öffentlicher `print-state` in arbeitsblatt | ein State `internal.print-state` in aufgaben, Abfrage `is-print()` |
| 20 | Z. 133–149 | `reset-aufgaben` lässt `_state_in_aufgabe`, `_state_in_teilaufgabe`, `_state_ta_material_vorher` aus | `reset-tasks` setzt alle States aus 2.4 außer Optionen, Theme und Print zurück |
| 21 | Z. 141–142 | `reset-aufgaben` setzt auch die globalen Zähler für `image`- und `table`-Abbildungen zurück | Verhalten bleibt (gleiches PDF, K 5.5), wird aber im Docstring genannt |
| 22 | Z. 831 | Doc von `material` verspricht „M1-A"; die Beschriftung entsteht erst in arbeitsblatt über zwei nur geschriebene States | Docstring berichtigt; die beiden States sind benannte Einträge von `internal` statt verdeckter Schnittstelle |
| 23 | Z. 279, 926 | `show-offene-loesungen` wirkt unabhängig vom Modus, Doc behauptet „im Lösungsmodus `"nur"`" | `show-solutions(select: "pending")`, Docstring nennt die Wirkung |
| 24 | Z. 86 | `format-punkte(teil: false, points)`: benannt vor positional, de neben en; braucht `context`, undokumentiert | `format-points(points, target:)`, Docstring nennt `context` |
| 25 | `docs/content.typ` Z. 23, 35, 315 | Doku der 0.3.1 zeigt `@schule/aufgaben:0.3.0` und den nicht vorhandenen Wert `"reingequetscht"` | Beispiele mit den Namen der Zielversion (deutsche Bausteine, englische Parameter), von `tests/run.sh` kompiliert (L26) |
| 26 | `klassenarbeit/0.4.0/docs/content.typ` Z. 289, 480; `mathematik/0.0.2` Z. 39 | veraltete Pins auf aufgaben 0.3.0 und 0.1.2; mit den neuen State-Schlüsseln teilen sie nichts mehr mit der Zielversion | Pins heben (K 9.4 Nr. 1); `teilaufgaben` kommt aus aufgaben |
| 27 | `aufgaben/0.3.1/aufgaben.typ.orig`, leeres `README.md`, `typst.toml` ohne `compiler` | Sicherungsrest und fehlende Metadaten | nicht in den Zielversionsordner übernehmen; `compiler = "0.15.0"` setzen; Einstieg `src/lib.typ` (K 7.1) |
| 28 | Z. 904–920 | `aufgabe` verschluckt benannte Argumente im Sink: `titel:` (342 Vorkommen aus Altversionen), `punkte:`, Tippfehler wie `tilte:` werden in 0.3.1 still ignoriert | `..deprecated` wird geprüft: `titel` „heißt jetzt `title`", sonst „unbekannter Parameter" |
| 29 | Z. 964, 1007 | `title: ""` gilt nicht als „kein Titel": „Aufgabe n −" mit hängendem Strich | Fehler „leerer Text"; Codemod löscht das Argument (PDF ändert sich) |
| 30 | Z. 598–600 | `show-bewertung` wertet das Positionsargument nur aus, wenn es genau eines ist; bei zweien gilt still `true` | `possible:` benannt; jedes Positionsargument ist ein Fehler |
| 31 | Z. 1171–1177, arbeitsblatt Z. 389–398, 679 | die Abbildungsarten `"aufgabe"`, `"teilaufgabe"` stehen als Zeichenketten in zwei Paketen | Konstanten `internal.task-figure-kind`, `internal.subtask-figure-kind` |

---

## 5. Maschinenlesbarer Anhang

Die vier verlangten Schlüssel sind `funktionen`, `parameter`, `werte`, `entfernt`. Zusätzlich: `bausteine` (die deutschen Funktionsnamen dieses Pakets aus `bausteine-de.txt`; der Codemod benennt sie nie um), `intern`, `vorgaben` (ausdrückliche Vorgabenwechsel nach L25), `kontext` (Regeln nur für den Codemod, K 9.2), `schluessel` (Hooks, Datensatz, States), `werte-kopf`, `nur-kontext`, `pdf-aenderungen`, `vorrang`.

Lesart:

- `funktionen` und `parameter` enthalten nur reine Namensersetzungen; ein Eintrag mit gleichem Namen links und rechts heißt „bleibt". Das gilt für die vier Bausteine, die es in 0.3.1 schon gibt (`aufgabe`, `teilaufgabe`, `loesung`, `erwartung`); `teilaufgaben` ist neu in diesem Paket und steht deshalb nur unter `bausteine` und `neu` (Regeln in der Tabelle arbeitsblatt). Einen Schlüssel `aliase` gibt es nicht mehr. Die Schlüssel unter `parameter`, `werte` und `vorgaben` sind die Funktionsnamen der Version 0.3.1. Was zusammengelegt wird oder vom Aufruf abhängt, steht ausschließlich unter `kontext` und ist unter `nur-kontext` aufgezählt.
- **Ein `kontext`-Eintrag geht einer `funktionen`-, `parameter`- oder `werte`-Regel desselben Namens vor.**
- Ein Wert vom Typ Objekt unter `werte` bedeutet: ein alter Wert wird zu mehreren Optionen.
- `null` als Zielwert bedeutet: Argument löschen. Unter `werte."set-options.*"` kommt `null` nicht vor (ein fehlendes Argument heißt dort „unverändert"); das Löschen von Vorgabewerten steht getrennt unter `werte-kopf` und gilt nur im Dokumentkopf.
- `pdf-aenderungen` nennt die Regeln, die das PDF gegenüber 0.3.1 ändern.

```json
{
  "paket": "aufgaben",
  "von": "0.3.1",
  "funktionen": {
    "aufgabe": "aufgabe",
    "teilaufgabe": "teilaufgabe",
    "loesung": "loesung",
    "erwartung": "erwartung",
    "material": "material",
    "set-options": "set-options",
    "reset-aufgaben": "reset-tasks",
    "show-loesungen": "show-solutions",
    "show-materialien": "show-materials",
    "show-erwartungen": "show-expectations",
    "show-bewertung": "show-points-table",
    "get-points": "get-points",
    "format-punkte": "format-points"
  },
  "bausteine": [
    "aufgabe",
    "teilaufgabe",
    "teilaufgaben",
    "loesung",
    "erwartung"
  ],
  "intern": {
    "show-loesung": "internal.task-solution",
    "show-loesung-inline": "internal.task-solution-inline",
    "show-material": "internal.task-materials",
    "_state_aufgaben": "internal.records-state",
    "_state_options": "internal.options-state",
    "_counter_aufgaben": "internal.task-counter",
    "_state_current_aufgabe_index": "internal.task-index-state",
    "_state_current_material_aufgabe": "internal.material-task-number-state",
    "_state_current_material_index": "internal.material-number-state",
    "_state_in_loesung": "internal.in-solution-state",
    "_state_loesungen_gezeigt": "internal.shown-task-count-state",
    "_state_in_aufgabe": "internal.in-task-state",
    "_state_in_teilaufgabe": "internal.in-subtask-state",
    "_state_ta_material_vorher": "internal.material-count-before-state",
    "_state_theme": "internal.theme-state",
    "_theme-hook": "internal.theme-hook",
    "_zusammen": "internal.keep-together",
    "_loesung-kasten": "internal.solution-callout",
    "_be-runden": "internal.round-points",
    "_be-anzeige": "internal.points-text",
    "_aufgaben-final": "internal.final-records",
    "_rechter-textrand": "internal.right-text-edge",
    "_erwartungen-zeilen": "internal.expectation-rows",
    "_ist-flex-workspace": "internal.is-flex-area",
    "_flex-fest": "internal.fixed-flex-area",
    "print-state (arbeitsblatt)": "internal.print-state"
  },
  "parameter": {
    "aufgabe": {
      "title": "title",
      "titel": "title",
      "method": "method",
      "icons": "icons",
      "large": "large",
      "number": "number",
      "workspace": "workspace",
      "label": "label"
    },
    "teilaufgabe": {
      "item-label": "marker",
      "label": "label",
      "workspace": "workspace"
    },
    "material": {
      "caption": "caption",
      "label": "label"
    },
    "set-options": {
      "loesungen": "solutions",
      "materialien": "materials",
      "workspaces": "workspaces",
      "teilaufgabe-numbering": "subtask-numbering",
      "punkte": "points",
      "punkte-position": "points-position"
    },
    "show-loesungen": {
      "curr": "select",
      "teil": "subtask-number",
      "inline": "inline"
    },
    "show-materialien": {
      "curr": "select"
    },
    "show-erwartungen": {
      "grouped": "grouped",
      "erreicht": "achieved",
      "alle": "select",
      "teile": "blocks"
    },
    "show-bewertung": {
      "compact": "compact",
      "full": "subtotals"
    },
    "get-points": {
      "teil": "subtask-number",
      "idx": "index"
    },
    "format-punkte": {
      "teil": "target",
      "points": "points"
    },
    "show-loesung": {
      "aufg": "record",
      "teil": "subtask-number"
    },
    "show-loesung-inline": {
      "aufg": "record"
    },
    "show-material": {
      "aufg": "record",
      "start": "first-index"
    }
  },
  "werte": {
    "aufgabe.method": {
      "\"\"": null,
      "\"EA\"": "\"individual\"",
      "\"PA\"": "\"pair\"",
      "\"GA\"": "\"group\""
    },
    "aufgabe.title": {
      "\"\"": null
    },
    "aufgabe.workspace": {
      "false": null
    },
    "teilaufgabe.workspace": {
      "false": null
    },
    "set-options.loesungen": {
      "\"keine\"": "none",
      "false": "none",
      "\"false\"": "none",
      "none": "none",
      "\"sofort\"": {
        "solutions": "\"in-place\"",
        "solutions-pagebreak": "none"
      },
      "\"folgend\"": {
        "solutions": "\"after-task\"",
        "solutions-pagebreak": "none"
      },
      "\"nur\"": {
        "solutions": "\"only\"",
        "solutions-pagebreak": "none"
      },
      "\"reinquetschen\"": {
        "solutions": "\"at-end\"",
        "solutions-pagebreak": "none"
      },
      "\"seite\"": {
        "solutions": "\"at-end\"",
        "solutions-pagebreak": "\"before\""
      },
      "\"seiten\"": {
        "solutions": "\"at-end\"",
        "solutions-pagebreak": "\"per-task\""
      }
    },
    "set-options.materialien": {
      "\"keine\"": "none",
      "false": "none",
      "\"false\"": "none",
      "none": "none",
      "\"seiten\"": {
        "materials": "\"after-task\"",
        "materials-pagebreak": "\"before\""
      },
      "\"sofort\"": {
        "materials": "\"after-task\"",
        "materials-pagebreak": "none"
      },
      "\"folgend\"": {
        "materials": "\"after-task\"",
        "materials-pagebreak": "none"
      },
      "\"seite\"": {
        "materials": "\"at-end\"",
        "materials-pagebreak": "\"before\""
      },
      "\"reinquetschen\"": {
        "materials": "\"at-end\"",
        "materials-pagebreak": "none"
      }
    },
    "set-options.punkte": {
      "\"keine\"": "none",
      "\"aufgaben\"": {
        "points": "\"tasks\"",
        "points-total": "true"
      },
      "\"teilaufgaben\"": {
        "points": "\"subtasks\"",
        "points-total": "true"
      },
      "\"alle\"": {
        "points": "\"all\"",
        "points-total": "true"
      },
      "\"keine-summe\"": {
        "points": "\"all\"",
        "points-total": "false"
      }
    },
    "set-options.punkte-position": {
      "\"ende\"": "\"end\"",
      "\"rand\"": "\"margin\""
    },
    "set-options.teilaufgabe-numbering": {
      "\"a)\"": "\"a)\"",
      "\"1.\"": "\"1.1\""
    },
    "show-loesungen.curr": {
      "false": null,
      "true": "\"current\""
    },
    "show-loesungen.teil": {
      "false": null
    },
    "show-materialien.curr": {
      "false": null,
      "true": "\"current\""
    },
    "show-erwartungen.alle": {
      "false": null,
      "true": "\"all\""
    },
    "show-bewertung.0": {
      "true": null,
      "false": "\"fields\"",
      "none": "none"
    },
    "format-punkte.teil": {
      "false": null,
      "true": "\"subtask\""
    },
    "show-loesung.teil": {
      "false": "none"
    }
  },
  "werte-kopf": {
    "_hinweis": "Gilt nur für Argumente von arbeitsblatt, arbeitsblatt-einzeln (und, soweit die Vorgabe dort gleich ist, klassenarbeit); maßgeblich sind die Tabellen arbeitsblatt und klassenarbeit. null = Argument löschen. Unter set-options.* und in variant-overrides steht nie null bei einer Schema-Option, weil ein fehlendes Argument dort \"unverändert\" heißt.",
    "arbeitsblatt.loesungen": {
      "\"keine\"": null,
      "false": null,
      "\"false\"": null,
      "none": null,
      "\"sofort\"": "\"in-place\"",
      "\"folgend\"": "\"after-task\"",
      "\"nur\"": "\"only\"",
      "\"reinquetschen\"": "\"at-end\"",
      "\"seite\"": {
        "solutions": "\"at-end\"",
        "solutions-pagebreak": "\"before\""
      },
      "\"seiten\"": {
        "solutions": "\"at-end\"",
        "solutions-pagebreak": "\"per-task\""
      }
    },
    "arbeitsblatt.materialien": {
      "\"keine\"": "none",
      "false": "none",
      "\"false\"": "none",
      "none": "none",
      "\"seiten\"": null,
      "\"sofort\"": {
        "materials": "\"after-task\"",
        "materials-pagebreak": "none"
      },
      "\"folgend\"": {
        "materials": "\"after-task\"",
        "materials-pagebreak": "none"
      },
      "\"seite\"": {
        "materials": "\"at-end\"",
        "materials-pagebreak": "\"before\""
      },
      "\"reinquetschen\"": {
        "materials": "\"at-end\"",
        "materials-pagebreak": "none"
      }
    },
    "arbeitsblatt.punkte": {
      "\"keine\"": "none",
      "\"aufgaben\"": "\"tasks\"",
      "\"teilaufgaben\"": "\"subtasks\"",
      "\"alle\"": "\"all\"",
      "\"keine-summe\"": {
        "points": "\"all\"",
        "points-total": "false"
      }
    }
  },
  "vorgaben": {
    "aufgabe.method": {
      "alt": "\"\"",
      "neu": "none",
      "wirkung": "gleich"
    },
    "set-options.loesungen": {
      "alt": "\"keine\"",
      "neu": "none",
      "wirkung": "gleich"
    },
    "set-options.materialien": {
      "alt": "\"seiten\"",
      "neu": "materials: \"after-task\", materials-pagebreak: \"before\"",
      "wirkung": "gleich"
    },
    "set-options.punkte": {
      "alt": "\"aufgaben\"",
      "neu": "none",
      "wirkung": "anders, nur ohne arbeitsblatt/klassenarbeit"
    },
    "set-options.punkte-template-aufgabe": {
      "alt": "punkte => [*#punkte BE*]",
      "neu": "points-format: auto",
      "wirkung": "gleich"
    },
    "set-options.punkte-template-teilaufgabe": {
      "alt": "punkte => [*[#punkte BE]*]",
      "neu": "points-format: auto",
      "wirkung": "gleich"
    },
    "show-loesungen.teil": {
      "alt": "false",
      "neu": "none",
      "wirkung": "gleich"
    },
    "show-loesungen.curr": {
      "alt": "false",
      "neu": "select: \"all\"",
      "wirkung": "gleich"
    },
    "show-materialien.curr": {
      "alt": "false",
      "neu": "select: \"all\"",
      "wirkung": "gleich"
    },
    "show-erwartungen.alle": {
      "alt": "false",
      "neu": "select: \"current\"",
      "wirkung": "gleich"
    },
    "show-bewertung.0": {
      "alt": "true",
      "neu": "possible: \"shown\"",
      "wirkung": "gleich"
    },
    "format-punkte.teil": {
      "alt": "false",
      "neu": "target: \"task\"",
      "wirkung": "gleich"
    },
    "show-loesung.teil": {
      "alt": "false",
      "neu": "none",
      "wirkung": "gleich"
    },
    "set-options.* (jedes Argument)": {
      "alt": "fehlender Schlüssel im Dictionary = unverändert",
      "neu": "Vorgabe internal.unchanged",
      "wirkung": "gleich"
    }
  },
  "kontext": [
    {
      "alt": "Aufruf des Kastens task aus gentle-clues (über * durchgereicht)",
      "neu": "Kasten von arbeitsblatt oder clue; je Fundstelle",
      "bedingung": "Datei importiert ein @schule-Paket; der Re-Export entfällt, ein übersehener Aufruf endet in Typsts unknown variable (kein Stub, keine neue Bedeutung)",
      "werkzeug": "bericht"
    },
    {
      "alt": "aufgabe[T][R]",
      "neu": "aufgabe(title: [T])[R]",
      "werkzeug": "ast"
    },
    {
      "alt": "erwartung(B, P)",
      "neu": "erwartung(P, B)",
      "bedingung": "P ist Zahl-Literal",
      "werkzeug": "ast"
    },
    {
      "alt": "erwartung(punkte: P, B)",
      "neu": "erwartung(P, B)",
      "werkzeug": "ast"
    },
    {
      "alt": "set-options((k: v, ...))",
      "neu": "set-options(k: v, ...)",
      "bedingung": "Werte nach werte.set-options.*, nie nach werte-kopf; kein Argument löschen",
      "werkzeug": "ast"
    },
    {
      "alt": "set-options(d)",
      "neu": "set-options(..d)",
      "bedingung": "d ist kein Literal; Schlüssel in d melden",
      "werkzeug": "bericht"
    },
    {
      "alt": "punkte: (anzeige: A, position: P)",
      "neu": "points: A', points-position: P'",
      "werkzeug": "ast"
    },
    {
      "alt": "punkte: (position: P)",
      "neu": "points: \"tasks\", points-position: P'",
      "bedingung": "anzeige fehlt: heutiger Rückfall \"aufgaben\"",
      "werkzeug": "ast"
    },
    {
      "alt": "punkte: (anzeige: A)",
      "neu": "points: A'",
      "bedingung": "position fehlt: ein daneben stehendes punkte-position bleibt und wird nach parameter/werte abgebildet",
      "werkzeug": "ast"
    },
    {
      "alt": "punkte: (..., position: P), punkte-position: Q",
      "neu": "points-position: P'",
      "bedingung": "punkte.position gewinnt; punkte-position: Q streichen",
      "werkzeug": "ast"
    },
    {
      "alt": "punkte-template-aufgabe: F, punkte-template-teilaufgabe: G",
      "neu": "points-format: (task: F, subtask: G)",
      "werkzeug": "ast"
    },
    {
      "alt": "punkte-template-aufgabe: F",
      "neu": "points-format: (task: F)",
      "bedingung": "nur dieser Schlüssel",
      "werkzeug": "ast"
    },
    {
      "alt": "punkte-template-teilaufgabe: G",
      "neu": "points-format: (subtask: G)",
      "bedingung": "nur dieser Schlüssel",
      "werkzeug": "ast"
    },
    {
      "alt": "show-offene-loesungen()",
      "neu": "show-solutions(select: \"pending\")",
      "bedingung": "ganzer Aufruf",
      "werkzeug": "regex"
    },
    {
      "alt": "show-bewertung(X)",
      "neu": "show-points-table(possible: X')",
      "bedingung": "genau ein Positionsargument; X' nach werte.show-bewertung.0",
      "werkzeug": "ast"
    },
    {
      "alt": "show-bewertung(X, Y, ...)",
      "neu": "show-points-table(...)",
      "bedingung": "zwei oder mehr Positionsargumente: heute alle ignoriert, alle löschen",
      "werkzeug": "ast"
    },
    {
      "alt": "show-erwartungen(teile: T, ...) ohne alle: true",
      "neu": "show-expectations(...)",
      "bedingung": "teile war wirkungslos, Argument löschen",
      "werkzeug": "ast"
    },
    {
      "alt": "show-erwartungen(alle: true, teile: T)",
      "neu": "show-expectations(select: \"all\", blocks: T)",
      "werkzeug": "ast"
    },
    {
      "alt": "show-erwartungen(new-page: true, ...)",
      "neu": "pagebreak(weak: true); show-expectations(...); pagebreak(weak: true)",
      "bedingung": "Aufruf ist eigene Anweisung; sonst Bericht",
      "werkzeug": "ast"
    },
    {
      "alt": "show-erwartungen(new-page: false, ...)",
      "neu": "show-expectations(...)",
      "werkzeug": "ast"
    },
    {
      "alt": "materialien: \"seiten\"",
      "neu": "(Argument löschen)",
      "bedingung": "nur im Kopf von arbeitsblatt, arbeitsblatt-einzeln, klassenarbeit; in set-options und variant-overrides gilt werte.set-options.materialien",
      "werkzeug": "regex"
    },
    {
      "alt": "figure.where(kind: \"aufgabe\" | \"teilaufgabe\"), .kind == \"aufgabe\" | \"teilaufgabe\"",
      "neu": "\"task\" | \"subtask\"",
      "bedingung": "nur Literale; alles andere Bericht (bricht sonst still)",
      "werkzeug": "regex"
    },
    {
      "alt": "print-state.get()",
      "neu": "is-print()",
      "bedingung": "maßgeblich Tabelle arbeitsblatt",
      "werkzeug": "regex"
    }
  ],
  "schluessel": {
    "theme": {
      "_hinweis": "Hooks sind Schlüssel des Theme-Dictionary und englisch (Parameterwort des gezeichneten Bausteins, wortpaare.json); keine Funktionsnamen. Schlüssel: AST-Werkzeug (Dictionary-Schlüssel). Parameter des Hooks aufgabe: von Hand, 8 Themes.",
      "aufgabe": {
        "neu": "task",
        "werkzeug": "ast"
      },
      "aufgabe.nummer": {
        "neu": "task.marker",
        "werkzeug": "hand",
        "regel": "number: false -> marker: none; sonst marker: [nummer]"
      },
      "aufgabe.number": {
        "neu": "task.marker",
        "werkzeug": "hand",
        "regel": "number: false -> marker: none; sonst marker: [nummer]"
      },
      "aufgabe.titel": {
        "neu": "task.title",
        "werkzeug": "hand",
        "regel": "Closure-Parameter; im Rumpf des Hooks als Variable benutzt"
      },
      "aufgabe.icons": {
        "neu": "task.icons",
        "werkzeug": "-"
      },
      "aufgabe.punkte": {
        "neu": "task.points",
        "werkzeug": "hand",
        "regel": "Closure-Parameter; im Rumpf des Hooks als Variable benutzt"
      },
      "aufgabe.large": {
        "neu": "task.large",
        "werkzeug": "-"
      },
      "teilaufgabe": {
        "neu": "subtask",
        "werkzeug": "ast"
      },
      "teilaufgabe.0 (label)": {
        "neu": "subtask.0 (marker)",
        "werkzeug": "-"
      },
      "loesung": {
        "neu": "solution",
        "werkzeug": "hand"
      },
      "loesung.0 (titel)": {
        "neu": "solution.title",
        "werkzeug": "hand",
        "regel": "positional -> benannt"
      },
      "loesung.1 (body)": {
        "neu": "solution.body",
        "werkzeug": "-"
      },
      "loesung-kopf": {
        "neu": "solution-heading",
        "werkzeug": "ast"
      },
      "loesung-kopf.0 (titel)": {
        "neu": "solution-heading.0 (title)",
        "werkzeug": "-"
      },
      "material-kopf": {
        "neu": "material-heading",
        "werkzeug": "ast"
      },
      "material-kopf.0 (titel)": {
        "neu": "material-heading.0 (title)",
        "werkzeug": "-"
      },
      "marke": {
        "neu": "task-marker",
        "werkzeug": "ast"
      },
      "marke.0 (nummer)": {
        "neu": "task-marker.0 (task-number)",
        "werkzeug": "-"
      },
      "marke-breite": {
        "neu": "task-marker-width",
        "werkzeug": "ast"
      }
    },
    "datensatz": {
      "nummer": "task-number",
      "title": "title",
      "teile": "subtask-count",
      "loesung": "solution-records",
      "loesung.teil": "solution-records.subtask-number",
      "loesung.body": "solution-records.body",
      "materialien": "material-records",
      "materialien.body": "material-records.body",
      "erwartungen": "expectation-records",
      "erwartungen.teil": "expectation-records.subtask-number",
      "erwartungen.text": "expectation-records.body",
      "erwartungen.punkte": "expectation-records.points"
    },
    "states": {
      "aufgaben": "schule/aufgaben/records@1",
      "options": "schule/aufgaben/options@1",
      "counter:aufgaben": "schule/aufgaben/task-counter@1",
      "current_aufgabe_index": "schule/aufgaben/task-index@1",
      "current_material_aufgabe": "schule/aufgaben/material-task-number@1",
      "current_material_index": "schule/aufgaben/material-number@1",
      "in_loesung": "schule/aufgaben/in-solution@1",
      "loesungen_gezeigt": "schule/aufgaben/shown-task-count@1",
      "in_aufgabe": "schule/aufgaben/in-task@1",
      "in_teilaufgabe": "schule/aufgaben/in-subtask@1",
      "ta_material_vorher": "schule/aufgaben/material-count-before@1",
      "ab-theme": "schule/aufgaben/theme@1",
      "print (arbeitsblatt, state(\"print\"))": "schule/aufgaben/print@1",
      "options.print (Fremdschlüssel, nie gelesen)": "schule/aufgaben/print@1"
    },
    "labels": {
      "_aufgaben-reset": "schule-aufgaben-reset"
    },
    "figure-kind": {
      "_hinweis": "Enum-Werte, englisch (Parameterwort, K 5.3); bricht still; Literale ersetzen, Rest Bericht",
      "aufgabe": "task",
      "teilaufgabe": "subtask",
      "material": "material"
    }
  },
  "neu": [
    "teilaufgaben (Baustein, neu in diesem Paket; bisher arbeitsblatt)",
    "has-solutions",
    "is-print",
    "set-options.solutions-pagebreak",
    "set-options.materials-pagebreak",
    "set-options.points-total",
    "set-options.shortcodes",
    "show-solutions.select=\"pending\"",
    "show-points-table.possible=none",
    "..deprecated in aufgabe, teilaufgabe, teilaufgaben, material, set-options, show-solutions, show-materials, show-expectations, show-points-table, get-points, format-points",
    "internal.print-state",
    "internal.task-points",
    "internal.subtask-number-text",
    "internal.unchanged",
    "internal.task-figure-kind",
    "internal.subtask-figure-kind",
    "internal.fail",
    "internal.check",
    "internal.option-schema"
  ],
  "entfernt": [
    "get-punkte-anzeige",
    "get-punkte-position",
    "show-loesung (öffentlich)",
    "show-loesung-inline (öffentlich)",
    "show-material (öffentlich)",
    "show-offene-loesungen (als eigene Funktion)",
    "show-erwartungen.new-page",
    "aufgabe: Titel als erstes von zwei Positionsargumenten",
    "erwartung: Punkte als zweites Positionsargument",
    "erwartung: benannte Argumente",
    "show-bewertung: Positionsargument",
    "set-options: Dictionary als Positionsargument",
    "set-options.punkte als Dictionary (anzeige, position)",
    "Options-Schlüssel print",
    "Re-Export fontawesome:0.6.0 (*)",
    "Re-Export gentle-clues:1.2.0 (*), darunter der Kasten task (kein Stub)",
    "alle Namen mit führendem Unterstrich",
    "aufgabe: benannte Argumente im Sink (still verschluckt)",
    "show-bewertung: benannte Argumente im Sink (still verschluckt)",
    "print-state (Export von arbeitsblatt)",
    "set-options.teilaufgabe-numbering=\"1.\" (gesperrt, solange die Compat-Tabelle läuft)"
  ],
  "vorrang": "Ein kontext-Eintrag geht einer funktionen-, parameter- oder werte-Regel desselben Namens vor. Die unter \"nur-kontext\" aufgezählten Funktionen und Parameter dürfen nie als reine Namensersetzung angewandt werden.",
  "nur-kontext": {
    "funktionen": [
      "show-offene-loesungen"
    ],
    "parameter": {
      "set-options": [
        "punkte-template-aufgabe",
        "punkte-template-teilaufgabe",
        "punkte (wenn der Wert ein Dictionary ist)"
      ],
      "show-erwartungen": [
        "teile (ohne alle: true)",
        "new-page"
      ],
      "show-bewertung": [
        "0 (Positionsargument)"
      ]
    }
  },
  "pdf-aenderungen": {
    "_hinweis": "Regeln, deren Anwendung das PDF gegenüber 0.3.1 ändert (Fehlerbehebungen); der Codemod meldet jede Fundstelle.",
    "aufgabe.title=\"\"": "heute \"Aufgabe n −\" mit hängendem Strich (Z. 1007), künftig kein Titel",
    "aufgabe.workspace=false": "heute Text \"false\" (Z. 1065–1067), künftig keine Arbeitsfläche",
    "aufgabe.titel (aus Versionen vor 0.3)": "in 0.3.1 still verschluckt (kein Titel), künftig title: gesetzt"
  }
}
```

---

## 6. Zweifelsfälle und Entscheidungen

1. **`show-expectations`: `select` und `blocks` statt `blocks: auto | none | array`.** A.5 schreibt `blocks: auto` vor („auto = alle Blöcke, none = ungeteilt"). Das verstößt gegen vier Regeln zugleich: G86 legt für „Auswahl aus Gesammeltem" das Wort `select` fest und nennt `alle` als verbotenes Synonym; `blocks: none` zeigte den aktuellen Block, hieße also nicht „nichts" (K 5.1); `auto | none | array` sind drei Zustände in einem Parameter (L7); die Vorgabe kippte von „aktueller Block" (Z. 534, 561) auf „alle" (K 5.5, L25), und in Dateien mit mehreren Klassenarbeiten käme der ganze Horizont mehrfach. **Entscheidung (geändert nach Prüfung):** `select: "current" | "all"` mit Vorgabe `"current"`, `blocks: ()` nur noch als Array der Zwischenüberschriften. Kein Vorgabenwechsel, kein Sonderfall im Codemod. A.5, K 6 (Beispiel `expectations: (…)`) und die Tabelle klassenarbeit müssen nachgezogen werden (Nachtrag).
2. **`new-page` hat keinen Nachfolger.** A.5 führt ihn nicht, und W6 verlangt, dass die Schlüssel von `expectations: (…)` genau die Parameter von `show-expectations` sind. klassenarbeit 0.4.0 entfernt `new-page` schon heute aus dem Dictionary (Z. 321). **Entscheidung:** entfernt, Meldung „`new-page` gibt es nicht mehr – `#pagebreak(weak: true)` davor schreiben" (möglich nur, weil die Signatur `..deprecated` hat, Zweifelsfall 11). Falls doch gewünscht, hieße er nach K 1.2 Schritt 3 `pagebreak: "before"`.
3. **Vorgabe `points` ohne arbeitsblatt.** K 6 nennt für „arbeitsblatt, aufgaben" `points: none`; der State in aufgaben hat heute `"aufgaben"` (Z. 48), arbeitsblatt überschreibt mit `"keine"` (arbeitsblatt Z. 288). Betroffen sind nur Dokumente, die aufgaben direkt importieren (im Repo `tests/aufgaben-*.typ`). **Entscheidung:** `none` nach K 6, als ausdrücklicher Vorgabenwechsel in `regeln.json`; die fünf Tests bekommen `set-options(points: "tasks")`.
4. **`marker` im Hook `task`.** A.12 fasst `nummer` (int) und `number` (bool) zu `marker` zusammen, nennt aber den Typ nicht. Die Themes bauen heute `kachel(str(nummer))` oder `[A#nummer]`. **Entscheidung:** `marker` ist `none` bei `number: false`, sonst die nackte Nummer als Inhalt (`[1]`), nie „Aufgabe 1"; das Wort „Aufgabe" setzt das Theme. Der Hook `task-marker` bekommt weiter die Zahl (`task-number`). **Offen nach Prüfung:** A.12 gibt `marker` damit zwei Bedeutungen (G43: „Beschriftung statt Nummer" beim Baustein `teilaufgabe`; im Hook `task` die Nummer selbst, daneben der Hook `task-marker` mit derselben Nummer als int), und `points` hat im Hook den Grundtyp content, sonst Zahl oder Auswahl (L6). Sauberer wäre `task: (task-number: none, title: none, icons: (), points-text: none, large: true)`. Diese Tabelle bleibt bei A.12 und Anhang C, weil beide die Hook-Signatur ausdrücklich festlegen; die Änderung ist als Nachtrag vorgeschlagen und kostet nichts zusätzlich, da die acht Hooks ohnehin von Hand umgestellt werden.
5. **`get-points(task-number, …, index:)`.** A.5 behält `index` neben dem Pflichtargument; die einzigen Nutzer sind fünf interne Aufrufe `get-points(none, idx: …)` (Z. 990, 1012, 1101; mit `teil:` Z. 1194, 1223), die gegen K 4.4 Nr. 3 verstoßen. **Entscheidung:** Signatur nach A.5 (dazu `..deprecated`); intern `internal.task-points(index, subtask-number: none)`, das alle fünf Aufrufe abdeckt. Empfehlung: `index` in der Folgelinie aus der öffentlichen Signatur streichen.
6. **Werte von `possible`.** A.5 nennt `"shown"` und `"blank"`; heute gibt es zusätzlich `none` = Zeile „mögliche Punkte" entfällt (Z. 592). **Entscheidung:** `possible: none` nach W2 („dazu `none`"); kein dritter Enum-Wert. **Geändert nach Prüfung:** `"blank"` wird `"fields"`. `blank` ist das Parameterwort des Bausteins `luecke` (G11, K 2.1b), und ein Enum-Wert trägt ein Parameterwort nur, wenn er genau diesen Baustein meint (K 5.3, L27d); außerdem benennt `"blank"`, was fehlt. `"fields"` (Wortliste N) benennt, was da ist: leere Felder zum Eintragen. A.5 muss nachgezogen werden (Nachtrag).
7. **`show-solutions(select: "pending")` und `inline`.** `show-offene-loesungen` gibt immer in der Form „inline" aus (Z. 284); `show-loesungen` nur mit `inline: true`. **Entscheidung:** `"pending"` setzt die Inline-Form voraus und ignoriert `inline` nicht still: `select: "pending", inline: false` bleibt erlaubt und gleichbedeutend, im Docstring genannt; `subtask-number` zusammen mit `"pending"` ist eine „unzulässige Kombination" (K 8.3).
8. **Werte von `figure(kind:)`.** Ein Dokument kann `figure.where(kind: "teilaufgabe")` schreiben, also ist der Wert öffentlich (K 2.1), das Glossar regelt ihn nicht. **Entscheidung:** `"task"`, `"subtask"`, `"material"` (die Parameterwörter aus K 2.1b, ohne Paketpräfix; Enum-Werte sind auch dann englisch, wenn sie einen Baustein meinen, K 5.3; `"aufgabe"` und `"teilaufgabe"` als Wert schlügen in L27a an); Supplement bleibt deutsch. Nebenwirkung erwünscht: Abbildungszähler werden nicht mehr mit Altversionen im selben Dokument geteilt. **Ergänzt nach Prüfung:** Die Umbenennung bricht still, ein Selektor mit altem Wert trifft einfach nichts mehr. Das ist die Begründung, mit der K 2.1 andere Kennungen einfriert. Die Tabelle bleibt bei der Umbenennung, weil der lokale Bestand keinen einzigen Treffer hat und die drei abhängigen Stellen in arbeitsblatt (Z. 389, 394–398, 679) künftig über `internal.task-figure-kind`/`subtask-figure-kind` laufen; der Codemod ersetzt Literale und berichtet den Rest. Alternative für den Autor: die beiden Werte wie `<ab-meta>` einfrieren.
9. **`materials-pagebreak: "before"` gegen heutiges `"seiten"`.** Heute: weicher Umbruch davor und zusätzlich `page(…)` um das Material (Z. 1077–1080, 819), also auch ein Umbruch danach. K 6 beschreibt nur „davor". **Entscheidung:** Wirkung bleibt wie heute (gleiches PDF, K 5.5); der Docstring sagt „Material steht auf eigener Seite". **[prüfen]** ob K 6 den Wert deshalb treffender `"per-task"` nennen sollte; bis dahin gilt `"before"`.
10. **Datensatz-Schlüssel der Sammlungen.** `solutions`, `materials`, `expectations` wären naheliegend, sind aber als Auswahl bzw. W6 vergeben (L6: ein Name, ein Typ). **Entscheidung:** `solution-records`, `material-records`, `expectation-records`; intern, daher ohne Glossarzeile.
11. **`..deprecated` in sieben weiteren Signaturen.** A.4/A.5 geben `material`, `show-solutions`, `show-materials`, `show-expectations`, `show-points-table`, `get-points`, `format-points` ohne Sink an. Ohne Sink bricht Typst bei einem alten Namen selbst ab (`get-points(1, teil: 2)` → `error: unexpected argument: teil`, englisch, ohne „heißt jetzt"; geprüft in `pruefung/auf/t2.typ`). Dann sind K 8.1/8.2 (deutsch, festes Format), K 8.4 (jede Funktion prüft Namen), K 9.1 und L24 (Fehlertest je Compat-Eintrag) nicht erfüllbar, und die in 1.9 bis 1.14 zugesagten Meldungen können nicht entstehen. **Entscheidung:** alle sieben bekommen `..deprecated` (K 4.4 Nr. 5c erlaubt es). `loesung`, `reset-tasks`, `has-solutions`, `is-print` haben keine benannten Parameter und keinen alten Namen und bleiben ohne Sink. Anhang A muss nachgezogen werden (Nachtrag).
12. **`subtask-numbering` ist nicht W9.** K 6 führt die Option als W9 („Typst-Muster"). Der Durchreichtest scheitert: Das Paket muss je Muster entscheiden, ob es (Teilnummer) oder (Aufgabennummer, Teilnummer) übergibt. **Entscheidung:** W3 str mit der Regel aus 2.1 (ein Zählzeichen: Teilnummer; zwei: Aufgabe und Teil). Für `"1."`: Der alte Wert ist als Muster gültig und hieße „2."; heute bedeutet er „1.2". Still annehmen widerspräche K 9.1. Also ist `"1."` während der Compat-Laufzeit gesperrt („heißt jetzt `"1.1"`") und wird erst danach ein gewöhnliches Muster. Das `[prüfen]` aus K 6 ist damit für diese Tabelle aufgelöst.
13. **`set-options`: „nicht angegeben" ist nicht `auto`, und Löschen gilt nur im Kopf.** (a) A.5 und K 6 sagen „`auto` heißt unverändert", das Schema sagt bei `points-format` „`auto` = Paketvorlage". Derselbe Wert hätte am selben Parameter zwei Bedeutungen (K 5.1), und mit `set-options` ließe sich die Paketvorlage nicht wiederherstellen. **Entscheidung:** Vorgabe aller elf Parameter ist der interne Markierwert `internal.unchanged`. (b) Der Pflichteintrag aus K 9.2 „`materialien: "seiten"` → Argument löschen" ist nur im Kopf wertgleich. In `set-options` und in `variant-overrides` setzt der alte Aufruf den Wert aktiv; gelöscht bliebe ein früheres `"at-end"` oder `"in-place"` stehen. **Entscheidung:** zwei Spalten in 2.2, im JSON `werte` (nie `null` für Schema-Optionen) und `werte-kopf`.
14. **`target` ist ein Name aus `std`.** Von den neuen Parameternamen stehen `title`, `label`, `columns`, `numbering`, `align`, `target` in `dictionary(std)` (Typst 0.15.1). `target` reicht nichts durch und hat keine Glossarzeile, nur die Erwähnung in K 5.1. **Entscheidung:** Name bleibt (A.5 und K 5.1 nennen ihn ausdrücklich); als Glossarlücke gemeldet; im Paket gilt L13 (`std.target`).
15. **`subtotals` bleibt.** Vorgeschlagen war `task-total` (Singular, Wort `total` wie in `points-total`). Verworfen: `subtotals` steht in A.5 und eigens in der Wortliste N; „Zwischensumme je Aufgabe" ist ein anderer Begriff als die Gesamtsumme, die `points-total` schaltet, und `task-total` läse sich als „Summe der Aufgaben". Die Spannung zu L9 (Schalter im Plural, keine Option aus Abschnitt 6) ist als Nachtrag gemeldet.

---

## 7. Gemeldete Glossarlücken und Regelkonflikte

| Lücke | hier entschieden als |
|---|---|
| Wert von `figure(kind:)` für Aufgabe und Teilaufgabe | `"task"`, `"subtask"` (Zweifelsfall 8) |
| Seitenumbruch vor dem Erwartungshorizont (`new-page`) | entfernt; sonst `pagebreak` als Aspekt (Zweifelsfall 2) |
| Ablage von `print` für `is-print()`: A.5 legt die Abfrage in aufgaben, K 6 hat `print` nicht im Schema; arbeitsblatt hat heute einen eigenen öffentlichen `print-state` | ein State `internal.print-state` in aufgaben, Schlüssel `"schule/aufgaben/print@1"`; arbeitsblatt legt keinen an |
| Zählversatz („ab welchem Eintrag", `start:`); `offset` ist als `(dx:, dy:)` belegt | `first-index` (intern) |
| Typ von `marker` im Hook `task` | content oder `none` (Zweifelsfall 4) |
| Sonderwert 0 bei `subtask-number` („die Aufgabe selbst, nicht eine Teilaufgabe") | bleibt 0; im Docstring genannt |
| Dritter Zustand von `possible` | `none` (Zweifelsfall 6) |
| Typ von `blocks`: A.5 sagt „array aus str", heute sind es Inhalte (`[Teil A -- ohne Hilfsmittel]`) | array aus str oder content |
| Flex-Erkennung: A.7 legt `is-flex-area` nach patterns, aufgaben hat eine eigene Kopie und importiert kein `@schule`-Paket | `internal.is-flex-area` in aufgaben, gleicher Name; zusammenführen, sobald aufgaben patterns importieren darf |
| Wert der Reset-Marke (`metadata("aufgaben-reset")`) | `metadata("reset")` am Label `<schule-aufgaben-reset>` |
| Namen der zwölf States über die drei Beispiele aus K 7.3 hinaus | Tabelle 2.4 |
| „Ziel einer Formatierung" (`target`): Name aus `std`, keine Glossarzeile (K 4.5) | `target` bleibt, Auswahl `"task"` \| `"subtask"`; Glossarzeile fehlt (Zweifelsfall 14) |
| Markierwert „nicht angegeben" in `set-options` | `internal.unchanged` (Zweifelsfall 13) |

Regelkonflikte in KONVENTION, die diese Tabelle nicht selbst auflösen kann:

| Konflikt | Behandlung hier |
|---|---|
| A.12 gegen K 4.4 Nr. 7 und L18 (Fassung vom 2026-11-15): Die Hook-Namen sind jetzt gedeckt (Parameterwort eines Bausteins oder Kompositum daraus). Offen bleiben die Parameter: der Hook `task` hat `marker` und `points`, der Hook `solution` hat `title`, die Bausteine `aufgabe` und `loesung` haben sie nicht. Außerdem ist `material-heading` ein Kompositum aus `material`, das nicht in `wortpaare.json` steht | Tabelle folgt A.12; Begründungsspalte in 2.6 nennt A.12. Vorschlag: L18 um „oder in A.12 aufgeführt" erweitern und `material` als sprachgleiches Wort dort nennen |
| A.12 gegen G43 und L6: `marker` im Hook `task` ist die Nummer, nicht „Beschriftung statt Nummer"; `points` im Hook ist content | Tabelle folgt A.12; Alternative in Zweifelsfall 4 |
| L3 (G55 verbietet `print-state`) und L4 (Suffix `-state`) gegen K 7.2/K 7.3, die `internal.options-state` selbst als Beispiel geben | Tabelle folgt K 7.2: L3 und L4 gelten nicht für Namen in `internal`. Sonst wären alle 13 Namen aus 2.4 regelwidrig |
| Geltung von L2 (Wortliste), L5 und der Verbliste aus K 4.1 für `internal`: K 2.1 sagt „interne Namen folgen derselben Regel", K 7.2 sagt „nur Abschnitt 2.4, ohne Glossarpflicht" | Tabelle wendet auf `internal` nur K 2.4 an. Andernfalls fehlen in `words-en.txt`: `first`, `keep`, `together`, `round`, `right`, `edge`, `fixed`, `final`, `hook`, `record`, `option`, `schema`, `check`, `fail`, `unchanged`, `state`; `keep` und `round` wären Verben außerhalb von K 4.1 |
| K 7.1: jedes Paket exportiert `internal`; bei `: *` aus zwei Paketen gewinnt still das zuletzt importierte. `internal` steht nicht in `words-en.txt` (L2) | Importregel in 3.2 (Pakete importieren aufgaben als Modul, reichen `aufgaben.internal` nicht durch) |
| K 5.1 („`auto` heißt immer: das Paket entscheidet") gegen K 6 und A.5 („`auto` heißt unverändert" in `set-options`) | `internal.unchanged` (Zweifelsfall 13) |
| K 9.2 Pflichteintrag „`materialien: "seiten"` → Argument löschen" gilt nur im Kopf, nicht in `set-options` und `variant-overrides` | getrennte Regeln (2.2, `werte-kopf`) |
| K 6: `subtask-numbering` als W9, besteht den Durchreichtest nicht; `"1."` → `"1.1"` steht dort mit `[prüfen]` | W3 mit Paketregel; `"1."` befristet gesperrt (Zweifelsfall 12) |
| A.4/A.5: sieben Signaturen ohne `..deprecated` gegen K 8.4, K 9.1, L24 | `..deprecated` ergänzt (Zweifelsfall 11) |
| A.5 `show-expectations(blocks: auto)` gegen G86, K 5.1, K 5.5, L7 | `select` + `blocks` (Zweifelsfall 1) |
| A.5 `possible: "blank"` gegen K 5.3 und G11 | `"fields"` (Zweifelsfall 6) |
| A.5 `subtotals` (Schalter im Plural) gegen L9 | bleibt nach A.5 (Zweifelsfall 15) |
| K 9.1 („nie still", Meldung „heißt jetzt") ist für drei Dinge technisch nicht erfüllbar. Still bricht nur noch eines: `figure(kind:)`-Selektoren. Die beiden anderen enden in Typsts `unknown variable` ohne „heißt jetzt": der State-Name `print-state` und der Kasten `task` aus gentle-clues, dessen Re-Export entfällt. Eine stille Bedeutungsänderung von `task` gibt es seit der Entscheidung vom 2026-11-15 nicht mehr | Codemod-Bericht bzw. Literalersetzung; in 1.1, 2.4, 3.2, 3.3 gekennzeichnet |

---

## 8. Prüfprotokoll

Zwei Prüfer (Vollständigkeit 13, Regeltreue 17), 30 Befunde. Jeder wurde gegen `aufgaben/0.3.1/aufgaben.typ`, `arbeitsblatt/0.4.0/src/arbeitsblatt.typ`, `arbeitsblatt/0.4.0/src/themes.typ`, `klassenarbeit/0.4.0/src/klassenarbeit.typ` und die Inventare geprüft. Ergebnis: 28 übernommen (zwei davon, R7 und R11, mit eigener Lösung in einem Teilpunkt), 1 teilweise übernommen (R9), 1 verworfen (R15).

| Nr. | Prüfer, Schwere | Befund | Ergebnis |
|---|---|---|---|
| V1 | Vollständigkeit, hoch | „Argument löschen" bei `loesungen: "keine"`, `materialien: "seiten"` ist in `set-options` nicht wertgleich | übernommen: Z. 113–117 (`curr + options`) bestätigt; 2.2 hat zwei Spalten, JSON trennt `werte` und `werte-kopf`, in `set-options` werden immer beide Geschwister geschrieben (auch `points-total`). |
| V2 | Vollständigkeit, mittel | `aufgabe` verschluckt benannte Argumente | übernommen: Z. 904–920 lesen nur `args.pos()`; Zeile in 1.1, Abschnitt 4 Nr. 28, `pdf-aenderungen`. |
| V3 | Vollständigkeit, mittel | Rückfälle im Dictionary `punkte` fehlen | übernommen: Z. 58, 66–67, 1154, 1158–1159 bestätigt; 2.1 und drei `kontext`-Einträge ergänzt. |
| V4 | Vollständigkeit, mittel | JSON führt Zusammenlegungen als Umbenennungen | übernommen: Einträge aus `funktionen`/`parameter` entfernt, `nur-kontext` und Vorrangregel ergänzt. |
| V5 | Vollständigkeit, mittel | Vorgänger von `internal.print-state` falsch | übernommen: arbeitsblatt Z. 180, 582, 1306, 1329 bestätigt; 2.4, 3.2, JSON berichtigt; zusätzlich 89 Aufrufe `print-state.get()` im lokalen Bestand gezählt. |
| V6 | Vollständigkeit, mittel | 3.2 nennt nur arbeitsblatt | übernommen: klassenarbeit (Z. 217–220, 305, 314–327), themes.typ, mathematik, Tests ergänzt; `show-expectations` mit den Schlüsseln der neuen Signatur. |
| V7 | Vollständigkeit, mittel | JSON `schluessel.theme` unvollständig | übernommen: alle Hook-Argumente mit Werkzeug je Eintrag. |
| V8 | Vollständigkeit, niedrig | „7 Themes" | übernommen: acht `aufgabe`-Hooks in themes.typ gezählt. |
| V9 | Vollständigkeit, niedrig | `get-points(none, idx:)` hat fünf Aufrufstellen | übernommen: Z. 990, 1012, 1101, 1194, 1223 bestätigt. |
| V10 | Vollständigkeit, niedrig | `show-bewertung` wertet nur genau ein Positionsargument aus | übernommen: Z. 598–600 bestätigt; 1.12, 2.2, `kontext` mit Bedingung, Abschnitt 4 Nr. 30. |
| V11 | Vollständigkeit, niedrig | Z. 577 statt 578 | übernommen: `"print": print` steht in Z. 578. |
| V12 | Vollständigkeit, niedrig | `title: ""` und `workspace: false` ändern das PDF | übernommen: Z. 1007 und 1065–1067 bestätigt; 1.1, 2.2, `pdf-aenderungen`. |
| V13 | Vollständigkeit, niedrig | Lücken in `vorgaben` und `neu` | übernommen: `show-loesung.teil` und die internen Namen ergänzt. |
| R1 | Regeltreue, hoch | wie V1, dazu uneinheitliches `null`/`"none"` | übernommen: zusammen mit V1; unter `set-options.*` steht kein `null` mehr. |
| R2 | Regeltreue, hoch | sieben Signaturen ohne `..deprecated` | übernommen: Typst bricht sonst selbst mit `unexpected argument` ab; alle sieben ergänzt, Zweifelsfall 11, Nachtrag zu A.4/A.5. |
| R3 | Regeltreue, hoch | `blocks: auto/none` statt `select` | übernommen: `select: "current" \| "all"`, `blocks: ()`; Vorgabe bleibt, Zweifelsfall 1, Nachtrag zu A.5. |
| R4 | Regeltreue, mittel | fremdes `task` aus gentle-clues bekommt still neue Bedeutung | übernommen: Zeile in 1.1, `kontext`-Regel (Bericht), 3.3; Bestand gezählt: 0 Treffer lokal. Am 2026-11-15 überholt: Es gibt keine eigene Funktion dieses Namens mehr, der Befund ist gegenstandslos; geblieben ist der Bericht über den entfallenden Re-Export. |
| R5 | Regeltreue, mittel | Hook-Parameter sind Closure-Parameter, nicht automatisierbar | übernommen: themes.typ Z. 210–223 bestätigt; Codemod-Spalte in 2.6 auf „nein" bzw. „AST (Schlüssel)". |
| R6 | Regeltreue, mittel | wie V4 | übernommen: zusammen mit V4; 1.9 nennt „ganzer Aufruf, keine Namensersetzung". |
| R7 | Regeltreue, mittel | `figure(kind:)` bricht still, abhängige Stellen fehlen | übernommen: arbeitsblatt Z. 389, 394–398, 679 in 3.2; Codemod-Spalte in 2.4; Umbenennung bleibt (0 Treffer im Bestand), Einfrieren als Alternative in Zweifelsfall 8. |
| R8 | Regeltreue, mittel | `subtask-numbering` ist nicht W9; `"1."` lebt mit neuer Bedeutung weiter | übernommen: W3 mit ausgeschriebener Regel; `"1."` befristet gesperrt; `[prüfen]` aufgelöst, Zweifelsfall 12. |
| R9 | Regeltreue, mittel | Hook-Namen verletzen K 4.4 Nr. 7/L18; `marker` und `points` doppeldeutig | teilweise übernommen: Begründung auf A.12 umgestellt und Konflikt gemeldet; die Hook-Signatur selbst bleibt nach A.12 und Anhang C, weil beide sie ausdrücklich festlegen. Der Vorschlag `task-number`/`points-text` steht als Alternative in Zweifelsfall 4. |
| R10 | Regeltreue, mittel | Wert `"blank"` ist Glossarwort und benennt Fehlendes | übernommen: `"fields"`; Zweifelsfall 6, Nachtrag zu A.5. |
| R11 | Regeltreue, mittel | `print-state` verbotenes Synonym, Suffix `-state`, Plural als Bestimmungswort | übernommen: Konflikt L3/L4 gegen K 7.2 gemeldet; `shown-task-count-state`, `material-count-before-state` (beide States halten eine Anzahl, Z. 282–287, 1142); arbeitsblatts `print-state` als Altzeile. Abweichung vom Vorschlag: ein State-Name kann nicht mit „heißt jetzt" abbrechen, deshalb Codemod-Regel `print-state.get()` → `is-print()`. |
| R12 | Regeltreue, niedrig | `target` ist ein Name aus `std` | übernommen als Glossarlücke: Name bleibt (A.5, K 5.1), Zweifelsfall 14, L13 gilt. |
| R13 | Regeltreue, niedrig | `internal` kollidiert zwischen Paketen | übernommen: Hinweis in 3.1, Importregel in 3.2, Nachtrag zu K 7.1. |
| R14 | Regeltreue, niedrig | `auto` hat in `set-options` zwei Bedeutungen | übernommen: `internal.unchanged` als Vorgabe aller elf Parameter, Zweifelsfall 13. |
| R15 | Regeltreue, niedrig | `subtotals` → `task-total` | verworfen: `subtotals` steht in A.5 und in der Wortliste, meint die Zwischensumme (anderer Begriff als `points-total`), und `task-total` wäre missverständlich; die Spannung zu L9 ist gemeldet (Zweifelsfall 15). |
| R16 | Regeltreue, niedrig | `kontext`-Regel für `format-punkte` unnötig | übernommen: Eintrag gestrichen; benannte Argumente dürfen vor positionalen stehen. |
| R17 | Regeltreue, niedrig | Wortliste für interne Namen uneinheitlich behandelt | übernommen: Bemerkung zu `first` gestrichen, Geltungsfrage als eine Zeile in Abschnitt 7. |

**2026-11-15: Entscheidung deutsche Bausteine eingearbeitet.** Die Tabelle folgt jetzt der Entscheidung des Autors (KONVENTION, Kasten am Anfang, 2.1a, 2.1b, 9.3): `aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung` und `erwartung` behalten ihren Namen auf Dauer, und die englischen Zwillinge kommen als Funktionsnamen nicht mehr vor. Geändert sind dafür die Übersicht, die Signaturen und Kopfzeilen in 1.1 bis 1.5, die Exportliste in 3.1 (der Block der Übergangsnamen ist gestrichen), die Beispiele und Kontextregeln sowie der JSON-Anhang (`funktionen` mit gleichem Namen links und rechts, `bausteine` statt `aliase`, `werte-kopf` unter `arbeitsblatt.*`). Die Spalten „Art" und „Codemod" nennen für die Bausteine jetzt „unverändert" und „–"; der Schalter `--aliase` und die Übergangsfrist kommen nicht mehr vor. Unverändert englisch sind alle Parameter, Schlüssel, Enum-Werte (auch `figure(kind: "task")`), Hooks, State-Namen und die Aktionen und Abfragen. Die Zeile zum Kasten `task` aus gentle-clues beschreibt keinen stillen Bedeutungswechsel mehr, sondern einen entfallenden Re-Export, der in Typsts `unknown variable` endet; der Verweis auf `kollisionen-erlaubt.txt` ist gestrichen. Neu aufgenommen ist in 1.3 der Verweis auf den Stub `tasks` → `teilaufgaben` aus K 9.3 (der Stub liegt in arbeitsblatt, nicht in aufgaben), und der Hook-Konflikt in 2.6 und Abschnitt 7 ist auf den Rest verkürzt, den die Neufassung von L18 offen lässt.

**2026-11-15: Nachprüfung der Einarbeitung.** Ein Prüfer hat die Datei gegen die Entscheidung geprüft (fünf Befunde, einer davon ein Ergebnisvermerk ohne Mangel). Englische Bausteinnamen als Funktionen, eingedeutschte Parameter und Reste der Alias-Mechanik hat er nicht gefunden. Die vier Restunschärfen sind alle übernommen, verworfen wurde keiner:

| Nr. | Befund | Ergebnis |
|---|---|---|
| N1 | Ergebnisvermerk: keine Verstöße gegen die Entscheidung | keine Änderung nötig. |
| N2 | 1.3 nennt den Stub `tasks`, ohne zu sagen, in welchem Paket er liegt; Stubliste in 3.1 und JSON führen ihn nicht | übernommen: `aufgaben/0.3.1/aufgaben.typ` hat kein `tasks`, der Alias steht in arbeitsblatt Z. 1263. Die Zeile in 1.3 und der Absatz oben nennen jetzt arbeitsblatt als Ort des Stubs; Stubliste und JSON bleiben ohne `tasks`. |
| N3 | Lesart des JSON sagt „alle Bausteine", unter `funktionen` stehen nur vier | übernommen: Lesart nennt die vier Bausteine aus 0.3.1 und verweist für `teilaufgaben` auf `bausteine` und `neu`. |
| N4 | `vorrang` spricht von einem Kennzeichen `"nur-kontext": true`, das kein Eintrag trägt | übernommen: Text verweist auf das Objekt `nur-kontext`. |
| N5 | Kopf nennt die Pfade `entwurf/KONVENTION.md` und `inventar/aufgaben.md`, die es nicht gibt | übernommen: `konvention.md` (Fassung vom 2026-11-15) und `inventar-aufgaben.md`. |
