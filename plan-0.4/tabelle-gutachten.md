# Umbenennungstabelle: gutachten 0.0.2 → 0.5.0

Stand 2026-11-15. Grundlage: `UMSETZUNG-0.5.0.md` (Vorrang), `konvention.md`
(K, Glossar = G), `inventar-hilfspakete.md` Abschnitt 4 und der Quelltext
`gutachten/0.0.2/gutachten.typ` (290 Zeilen) und `bewertung.typ` (338 Zeilen).
Die Namen aus 0.0.1 (andere Oberfläche: `gutachten-optionen`, `sachgebiet`,
`pflichtteil`) sind als Abfang berücksichtigt, weil 3 von 9 Dokumenten
außerhalb des Repos noch 0.0.1 pinnen.

**Ergebnis in einem Satz:** Die Bausteine `gutachten` und `aufgabe` und der
Wert `name` behalten ihre Namen; die drei Mischnamen `set-gutachten-infos`,
`set-aufgaben`, `bewertungsskala` werden `set-options`, `set-tasks`,
`format-grade`; alles in den Klammern wird englisch; die vier States bekommen
das Paketpräfix; `bewertung.typ` ist repariert und liegt in `internal`.

## 1. Signaturen

```typ
// alt (gutachten/0.0.2/gutachten.typ)
#import "@preview/unify:0.7.0": *                                   // Z. 1, ungenutzt, aber weitergereicht
#let set-gutachten-infos(fach: "", niveau: "", kürzel: "", anonym: false, print: false, be: 1,
  font: "New Computer Modern Sans", math-font: "Fira Math", jahr: auto) = { }   // Z. 22
#let name = context { }                                              // Z. 54
#let set-aufgaben(aufgaben) = { }                                    // Z. 74
#let bewertungsskala(prozent) = { }                                  // Z. 86
#let aufgabe(name, punkte, body) = { }                               // Z. 129
#let gutachten(vorname: "Max", nachname: "Mustermann", wahl: (), body) = { }   // Z. 166

// neu (gutachten/0.5.0/src/gutachten.typ, exportiert von src/lib.typ)
#let set-options(subject: none, level: none, teacher: none, anonymous: false, print: false, max-points: 1,
  font: "New Computer Modern Sans", math-font: "Fira Math", year: auto, ..deprecated) = { }
#let name = context { }
#let set-tasks(..deprecated, tasks) = { }
#let format-grade(share, ..deprecated) = { }
#let aufgabe(task-name, points: none, ..deprecated, body) = { }
#let gutachten(first-name: "Max", last-name: "Mustermann", selected-tasks: (), ..deprecated, body) = { }
```

## 2. Tabelle

### 2.1 Funktionen und Werte

| alt | neu | Art | Begründung |
|---|---|---|---|
| `gutachten` (Funktion) | `gutachten` | unverändert; Baustein | Bausteintest K 2.1: B1 (`#gutachten(...)[...]` setzt das Gutachten), B2 („Gutachten" ist das Wort der Prüfungsordnung und der Lehrkräfte), B3 (keine Aktion, kein Helfer). Die Funktion heißt wie ihr Paket (wie `klausurboegen`, `klassenarbeit`); das Lint lässt das ohne Listeneintrag zu. Kein englischer Zwilling. |
| `aufgabe` (Funktion) | `aufgabe` | unverändert; Baustein | Steht in `bausteine-de.txt`. Siehe Zweifelsfall 1 (zweite Definition neben aufgaben). |
| `name` (Wert, context-Inhalt) | `name` | unverändert | Englisch, in `words-en.txt` (Gruppe B), kein Name aus `std`. Siehe Zweifelsfall 2. |
| `set-gutachten-infos` | `set-options` | umbenannt, Stub | Mischname (K 2.1 „Keine Mischnamen"), „infos" ist kein Wort der Liste. K 4.1: Zustand setzen ist `set-<plural>`; `set-options` ist der Name, den aufgaben für dieselbe Sache benutzt. |
| `set-aufgaben` | `set-tasks` | umbenannt, Stub | Mischname. Hinter dem Verb steht das Parameterwort des Bausteins `aufgabe` (K 2.1b, K 4.1: `reset-tasks`, nicht `reset-aufgaben`). |
| `bewertungsskala` | `format-grade` | umbenannt, Stub | Kein Baustein: liefert einen Text aus einer Zahl, also eine Umwandlung (K 2.1 Ausschlusstabelle, K 4.1 `format-<substantiv>`). `grade` ist G 22. |
| `@preview/unify:0.7.0` mit `*` | entfällt | entfernt | Ungenutzt; K 7.1 verbietet Wildcard-Durchreichung, `qty`/`num`/`unit` reicht nur arbeitsblatt weiter. Kein Stub möglich (Fremdnamen); steht im Handbuch unter Umstieg. |
| Einstiegsdatei `gutachten.typ` | `src/lib.typ`, Implementierung `src/gutachten.typ` | Struktur | K 7.1. |
| `image("logo.svg")` | `image("../logo.svg")` | intern | `logo.svg` bleibt im Paketwurzelordner. |
| – | `src/removed.typ` | neu | Stubs: `set-gutachten-infos`, `set-aufgaben`, `bewertungsskala` (0.0.2), `gutachten-optionen`, `sachgebiet`, `pflichtteil` (0.0.1). |
| – | Modul `internal` | neu | States, Helfer und der reparierte Erwartungshorizont (2.6). |

### 2.2 `set-options` (früher `set-gutachten-infos`)

| alt | neu | Art | Begründung |
|---|---|---|---|
| `fach: ""` | `subject: none` | umbenannt, Vorgabe `""` → `none` | G 16. K 5.2, L8: leerer Text ist `none`. Im Kopf steht bei `none` wie bisher bei `""` nichts („ () - "); gleiches PDF, weil der Kopf `none` als leeren Text setzt (`shown` in `gutachten`): Ein leerer Text hält das Leerzeichen daneben fest, `none` nicht, und ohne diese Umsetzung rutschte die rechtsbündige Zeile um eine Leerzeichenbreite (5,68pt). `subject: ""` ist ein Fehler mit Abhilfe (K 9.2, UMSETZUNG „zweite Wege"). |
| `niveau: ""` | `level: none` | umbenannt, Vorgabe `""` → `none` | G 24. Typ hier str oder Inhalt (freier Text im Kopf, zum Beispiel `"E"`), keine Auswahl; siehe Zweifelsfall 5. |
| `kürzel: ""` | `teacher: none` | umbenannt, Vorgabe `""` → `none` | G 19 (Lehrkraft), K 2.3 (Umlaut). Die Faltung fängt `kürzel` und `kuerzel`. |
| `anonym: false` | `anonymous: false` | umbenannt | Schalter, positiv (K 4.3): benennt, was bei `true` gilt. Wort neu. |
| `print: false` | `print: false` | unverändert | G 55. |
| `be: 1` | `max-points: 1` | umbenannt | G 8 verbietet `be`. `points` allein ist im Paket die *erreichte* Punktzahl (`aufgabe(points:)`); die *erreichbare* heißt überall `max-points` (hier und als Schlüssel in `set-tasks`), wie in klausurboegen (`grade-boundaries(max-points:)`). `max` ist eine zugelassene Abkürzung (K 2.2). Vorgabe `1` bleibt (L25). |
| `font`, `math-font` | `font`, `math-font` | unverändert | G 48. Typ wie bei `text(font: …)`: str, Array oder Dictionary `(name:, covers:)`. |
| `jahr: auto` | `year: auto` | umbenannt | Wort der Liste; `years` (G 21) ist der Jahrgang als Array, `year` das Abiturjahr als Zahl. Typ int, str oder Inhalt (0.0.2 setzte den Wert ungeprüft in den Kopf; `jahr: [2027]` kompilierte). |
| – | `..deprecated` | Sink ergänzt | K 4.4 Nr. 5c, K 8.4. |

Nur in 0.0.1 (`gutachten-optionen`, `gutachten`): `kurs`, `prüfer`,
`korreferent` → entfernt mit Hinweis (seit 0.0.2 ohne Entsprechung).

### 2.3 `set-tasks` (früher `set-aufgaben`)

| alt | neu | Art | Begründung |
|---|---|---|---|
| `aufgaben` (positional, Dictionary) | `tasks` (positional) | umbenannt | Parameterwort im Plural (K 2.1b). Bleibt positional, siehe Zweifelsfall 3. |
| Schlüssel `be` | `max-points` | umbenannt | wie 2.2. |
| Schlüssel `dativ` | `dative` | umbenannt | englisch (K 2.1); Wort neu. |
| Schlüssel `name` | `title` | umbenannt | G 13: Es ist das Thema der Aufgabe („Analysis"), das hinter dem Aufgabennamen steht, kein Name. |
| – | `..deprecated` | Sink ergänzt | K 4.4 Nr. 6. |

Die Schlüssel werden geprüft (K 5.4), alte brechen mit „heißt jetzt" ab.

### 2.4 `aufgabe`

| alt | neu | Art | Begründung |
|---|---|---|---|
| `name` (1. Positionsargument) | `task-name` (führendes Hauptargument) | umbenannt | Der Schlüssel aus `set-tasks`; `name` wäre im Rumpf der exportierte Wert `name`. Für Dokumente unsichtbar (positional). |
| `punkte` (2. Positionsargument) | `points:` (benannt, Pflicht) | umbenannt, positional → benannt | G 8. K 4.4 Nr. 2: höchstens ein führendes Hauptargument. `aufgabe("Aufgabe 1", 24)[…]` bricht mit Abhilfe ab; fehlt `points`, ebenfalls. Siehe Zweifelsfall 4. |
| `body` | `body` | unverändert | G 79. |
| – | `..deprecated` | Sink ergänzt | fängt das alte zweite Positionsargument und `punkte:`. |

### 2.5 `gutachten`

| alt | neu | Art | Begründung |
|---|---|---|---|
| `vorname: "Max"` | `first-name: "Max"` | umbenannt | englisch; `name` Gruppe B, `first` neu. |
| `nachname: "Mustermann"` | `last-name: "Mustermann"` | umbenannt | englisch. |
| `wahl: ()` | `selected-tasks: ()` | umbenannt | Plural wegen Vorgabe `()` (L9); `tasks` ist das Parameterwort. `select` (G 86) ist eine Auswahl aus Gesammeltem mit festen Werten und passt nicht; `tasks:` allein ist in G 78 als Synonym von `items` verboten. Array oder Dictionary wie bisher. |
| `body` | `body` | unverändert | |
| – | `..deprecated` | Sink ergänzt | |

Nur in 0.0.1: `name:` (Nachname) → `last-name`; `geschlecht`, `jahr`, `fach`,
`niveau`, `kurs`, `prüfer`, `korreferent`, `BE` → entfernt mit Hinweis, wo die
Angabe jetzt steht.

### 2.6 States, Labels, interne Namen

| alt | neu | Art |
|---|---|---|
| `state("gutachten-infos")` | `internal.options` = `state("schule/gutachten/options@1", none)` | K 7.3 |
| `state("schüler")`, Felder `vorname`, `nachname` | `internal.student` = `state("schule/gutachten/student@1", none)`, Felder `first-name`, `last-name` | K 7.3, K 2.3 |
| `state("aufgaben")` (Dictionary) | `internal.tasks` = `state("schule/gutachten/tasks@1", (:))` | K 7.3; kollidierte mit aufgaben 0.3.1 und mit `bewertung.typ` |
| `state("punkte")` | `internal.points` = `state("schule/gutachten/points@1", 0)` | K 7.3 |
| Label `<vorname>-<nachname>-pages` | `<schule-gutachten-pages-<vorname>-<nachname>>` | K 7.3 |
| `_anonym-name-placeholder` | `internal.anonymous-placeholder` | K 7.2 |
| `_format-punkte-wert` | `internal.format-points` | K 7.2 |
| – | `internal.final-options`, `internal.current-student`, `internal.pages-label` | neu (Fehlermeldung statt rohem Typst-Fehler) |

`bewertung.typ` (in 0.0.2 nicht über den Paketnamen erreichbar, unter Typst
0.15 nicht kompilierbar) → `src/internal.typ`, repariert:

| alt | neu (`internal.…`) | Reparatur |
|---|---|---|
| `__s_erwartungen` = `state("erwartungen", ())` | `expectations` = `state("schule/gutachten/expectations@1", ())` | |
| `__s_aufgaben` = `state("aufgaben", ())` | `expectation-tasks` = `state("schule/gutachten/expectation-tasks@1", ())` | eigener Name, weil `tasks` das Dictionary des Gutachtens ist |
| Eintrag `(aufgabe, teil, text, punkte)` | `(task-number, subtask-number, text, points)` | G 41, G 8 |
| Eintrag `(nummer, teile, title)` | `(task-number, subtask-count, title)` | G 41, G 38 |
| `__foreach`, `__foreach_erw` | `matching-expectations(task-number, subtask-number)` | `locate`, `type(s) == "state"`, `assert` entfallen; `context` |
| `__d__erwartung` | `expectation-entry` | |
| `d_ew_erwartungen(aufg, teil: 0, format:)` | `expectation-entries(task-number, subtask-number: 0, format:)` | |
| `d_ew_text` | `expectation-texts(task-number, subtask-number: 0)` | war `.with(format: …)`; `format` ist dort fest |
| `d_ew_punkte(aufg, teil: 0, format:)` | `expectation-points(task-number, subtask-number: 0, format:)` | `locate` → `context` |
| `d_ew_gesamt(format:)` | `expectation-total(format:)` | `locate` → `context` |
| `ew_verteilung_oberstufe`, `ew_namen_oberstufe` | `grade-boundaries-sek-2`, `grade-names-sek-2` | G 22, G 23 |
| `ew_verteilung_unterstufe`, `ew_namen_unterstufe` | `grade-boundaries-sek-1`, `grade-names-sek-1` | |
| `ew_verteilung_ohne_tendenz`, `ew_namen_ohne_tendenz` | `grade-boundaries-plain`, `grade-names-plain` | |
| `d_ew_notenspiegel(verteilung:, namen:)` | `grade-table(boundaries:, names:)` | `assert` → `fail` |
| `d_ew_unterstufe()` | `expectations-sek-1()` | tablex → `table`/`table.cell` |
| `d_ew_oberstufe()` | `expectations-sek-2()` | tablex → `table`/`table.cell` |
| `d_ew_bewertung()` | `points-table()` | tablex → `table`/`table.cell` |
| Labels `<erwartungshorizont>`, `<bewertung>` | `<schule-gutachten-expectations>`, `<schule-gutachten-points-table>` | K 7.3 |
| `@preview/tablex:0.0.5`, `@schule/klausurboegen:0.0.2` | entfallen | tablex lädt unter 0.15 nicht; klausurboegen war ungenutzt |

Vorgaben, die bleiben (gleiches Dokument, gleiches PDF): Schriften, `be`/
`max-points: 1`, `print: false`, `anonym`/`anonymous: false`, `"Max"`,
`"Mustermann"`, Seitenränder `(top: 3cm, y: 3cm)`, `header-ascent: 20%`, alle
Texte im PDF, die Notenskala.

## 3. Fehlermeldungen

| Aufruf | Meldung |
|---|---|
| `#set-options(fach: "Physik")` | ``gutachten.set-options: `fach` heißt jetzt `subject` `` |
| `#set-options(kürzel: "MS")` | ``gutachten.set-options: `kürzel` heißt jetzt `teacher` `` |
| `#set-options(subject: "")` | ``gutachten.set-options: `subject: ""` – für „kein Fach" `none` schreiben oder weglassen`` |
| `#set-options(xyzzy: 1)` | ``gutachten.set-options: unbekannter Parameter `xyzzy` – erlaubt: `subject`, `level`, … `` |
| `#set-gutachten-infos(…)` | ``gutachten.set-gutachten-infos: `set-gutachten-infos` heißt jetzt `set-options` `` |
| `#set-aufgaben(…)` | ``gutachten.set-aufgaben: `set-aufgaben` heißt jetzt `set-tasks` `` |
| `#bewertungsskala(0.75)` | ``gutachten.bewertungsskala: `bewertungsskala` heißt jetzt `format-grade` `` |
| `#set-tasks(("A": (be: 30)))` | ``gutachten.set-tasks: `be` heißt jetzt `max-points` `` |
| `#gutachten(vorname: "A")[…]` | ``gutachten.gutachten: `vorname` heißt jetzt `first-name` `` |
| `#gutachten(wahl: (…))[…]` | ``gutachten.gutachten: `wahl` heißt jetzt `selected-tasks` `` |
| `#gutachten(vornam: "A")[…]` | ``gutachten.gutachten: unbekannter Parameter `vornam` – meintest du `first-name`?`` |
| `#gutachten(geschlecht: "m")[…]` | ``gutachten.gutachten: `geschlecht` gibt es nicht mehr – seit 0.0.2 nennt das Gutachten den Vornamen ohne Anrede; Angabe streichen`` |
| `#aufgabe("Aufgabe 1", 24)[…]` | ``gutachten.aufgabe: 2 Positionsargumente, erlaubt ist höchstens 1 – die erreichten Punkte benannt schreiben: `aufgabe("Aufgabe 1", points: 24)[...]` `` |
| `#set-tasks((…), (…))` | ``gutachten.set-tasks: 2 Positionsargumente, erlaubt ist höchstens 1 – alle Aufgaben in ein einziges Dictionary schreiben: `set-tasks(("Aufgabe 1": (max-points: 30)))` `` |
| `#format-grade(0.5, 0.6)` | ``gutachten.format-grade: 2 Positionsargumente, erlaubt ist höchstens 1 – nur den Anteil übergeben: `format-grade(0.75)` `` |
| `#set-options(subject: "P", fach: "Q")` | ``gutachten.set-options: `fach` (alt) und `subject` (neu) zugleich – nur `subject` schreiben`` |
| `#set-tasks(("A": (max-points: 10, thema: "x")))` | ``gutachten.set-tasks: unbekannter Schlüssel `thema` – erlaubt: `max-points`, `dative`, `title` `` |
| `#gutachten(selected-tasks: ("W": "A"))[…]` | ``gutachten.gutachten: `selected-tasks`: der Prüfungsteil `W` braucht eine Liste – `("W": ("A",))` schreiben`` |
| `#gutachten(selected-tasks: (1, 2))[…]` | ``gutachten.gutachten: `selected-tasks` enthält `1` (integer) – Aufgabennamen als Text schreiben: `("Aufgabe 2", "Aufgabe 4")` `` |
| `#aufgabe("Aufgabe 1")[…]` | ``gutachten.aufgabe: `points` fehlt – die erreichten Punkte angeben: `aufgabe("Aufgabe 1", points: 24)[...]` `` |
| `#aufgabe("Aufgabe 9", points: 1)[…]` | ``gutachten.aufgabe: unbekannte Aufgabe `Aufgabe 9` – in `set-tasks` eintragen; bekannt: `Aufgabe 1` `` |
| `#gutachten(…)[…]` ohne `set-options` | ``gutachten.gutachten: die Angaben zum Gutachten fehlen – einmal `set-options(subject: ..., level: ..., teacher: ..., max-points: ...)` aufrufen`` |
| `#name` außerhalb | ``gutachten.name: steht außerhalb eines Gutachtens – nur innerhalb von `gutachten(...)[...]` verwenden`` |
| `#sachgebiet(…)[…]` | ``gutachten.sachgebiet: `sachgebiet` gibt es seit 0.0.2 nicht mehr – die Aufgaben in `set-tasks` eintragen und je Aufgabe `aufgabe("…", points: …)[...]` schreiben`` |

Gezählt werden die Positionsargumente samt dem Pflichtargument (`tasks`,
`share`, `task-name`), ohne den Inhalt in eckigen Klammern; so stimmt die Zahl
in der Meldung mit dem Aufruf überein. Die Namen werden vor den
Positionsargumenten geprüft, damit `#show: set-options.with(fach: …)` den
neuen Namen nennt und nicht den Inhalt der Show-Regel zählt.

„Alt und neu zugleich" erkennen `set-options`, `gutachten` und `aufgabe`,
indem sie `check-named` neben dem Sink jeden deklarierten Parameter mitgeben,
der von seiner Vorgabe abweicht (`named-with-set` in `src/gutachten.typ`).
Bekannte Grenze: Steht der neue Name ausdrücklich auf seiner Vorgabe
(`set-options(max-points: 1, be: 5)`, `print` gibt es alt wie neu), lautet die
Meldung „heißt jetzt"; sie nennt auch dann den richtigen Namen.

Bekannte Grenze: `#format-grade(prozent: 0.5)` und `#set-tasks()` melden
Typsts eigenes `missing argument`, weil das Pflichtargument vor dem Rumpf
geprüft wird (wie `brief()` in angela).

Neue Prüfungen, die bisher ein roher Typst-Fehler waren (kein Dokument, das
kompilierte, ist betroffen): fehlendes `set-options`, unbekannte Aufgabe,
Aufgabe ohne `max-points`, `#name` außerhalb, `max-points <= 0` (bisher
Division durch null), Typen der Parameter, Gestalt von `selected-tasks`
(Aufgabennamen als Text, je Prüfungsteil eine Liste; bisher `type string has
no method map` oder `expected string, found integer`).

Strenger als bisher (Dokumente, die mit 0.0.2 kompilierten, brechen jetzt mit
Abhilfe ab):

- Ein Eintrag in `set-tasks`, der kein Dictionary ist (`"A": 30`), bricht
  sofort ab; bisher scheiterte erst `aufgabe("A", …)` daran.
- Ein Schlüssel, den `set-tasks` nicht kennt (`"A": (be: 10, thema: "x")`),
  bricht als unbekannter Schlüssel ab; 0.0.2 überging ihn still (K 5.4: keine
  falsche Eingabe wird still übergangen).
- `max-points` je Aufgabe muss int oder float sein; 0.0.2 setzte auch einen
  Text (`be: "30"`) ungeprüft in den Satz. Ebenso `year`: int, str oder
  Inhalt, kein float.
- `subject: ""`, `level: ""`, `teacher: ""` (die alten Vorgaben, ausdrücklich
  geschrieben) sind Fehler mit Abhilfe (2.2).

Nicht strenger, obwohl geprüft: `year`, `subject`, `level`, `teacher` nehmen
auch Inhalt, `font` und `math-font` auch ein Dictionary oder ein Array aus
Dictionaries, wie `text(font: …)`.

## 4. Zweifelsfälle

1. **`aufgabe` zum zweiten Mal.** `aufgabe` steht in `bausteine-de.txt` und
   gehört dort zu aufgaben; L23a verlangt genau ein definierendes Paket.
   gutachten definiert seit 0.0.2 eine eigene Funktion gleichen Namens mit
   anderer Signatur. Sie umzubenennen (etwa `kommentar`) wäre ein neuer
   Baustein ohne Bestand und bräche die Aufrufe im Bestand außerhalb des Repos ohne
   Gewinn; ein englischer Name wäre ein Zwilling. Entscheidung: Name bleibt,
   die Signatur folgt K 4.4. Wer gutachten und arbeitsblatt im selben
   Dokument braucht, importiert namentlich. Der Autor kann anders entscheiden.
2. **`name` als exportierter Wert.** Das Inventar nennt ihn kollisionsträchtig
   (`import: *`), und G 20 führt den Prüfling als `student`. Dagegen: Der Name
   besteht L1, L2 und L12; für einen Wert gibt es keinen abbrechenden Stub mit
   Funktionsform (möglich wäre nur `context fail(…)` wie in flashcards), und
   `#name` steht in jedem Gutachtentext. Entscheidung: bleibt. Alternative:
   `student-name` mit `name` als abbrechendem Wert in `removed.typ`.
3. **`set-tasks(tasks)` positional.** K 4.4 Nr. 3 will kein Dictionary als
   Positionsargument; benannt hieße der Parameter aber `tasks:`, und das
   verbietet G 78 als Synonym für `items`. Das Dictionary ist hier das eine
   führende Hauptargument (K 4.4 Nr. 2), die Aufrufform bleibt, wie sie ist.
   Alternative: `set-options(tasks: …)`; das änderte, dass Aufgaben und
   Angaben getrennt neu gesetzt werden können.
4. **`aufgabe("Aufgabe 1", points: 24)` statt zwei Positionsargumenten.**
   Folgt K 4.4 Nr. 2 und UMSETZUNG „zweite Wege sind Fehler mit Abhilfe". Es
   ist die einzige Änderung, die jede Aufgabenzeile eines Bestandsdokuments
   trifft (Regel im Anhang unter `kontext`). Alternative mit weniger
   Umstellung: zweites Positionsargument beibehalten und die Regel als benannte
   Ausnahme führen.
5. **`level` als freier Text.** G 24 führt `level` als Auswahl. Hier steht der
   Wert unverändert im Kopf (`"E"`, `"G"`, `"eA"`, `"LK"`); eine Auswahl würde
   Bestandsdokumente brechen. Der Grundtyp ist damit str, nicht Enum; L6 ist
   an dieser Stelle verletzt.
6. **`bewertung.typ` nach `internal`, nicht öffentlich.** Die Datei war in
   0.0.2 nicht importierbar (die Doku nannte eine ungültige Importzeile), und
   nichts im Paket füllt ihre States. Eine öffentliche Fassung bräuchte neue
   Funktionen zum Eintragen von Aufgaben und Erwartungen, also neues
   Verhalten. Entscheidung: reparieren, Namen nach K 7.2, erreichbar als
   `gutachten.internal.…` ohne Zusicherung. Der Autor entscheidet, ob daraus
   eine öffentliche Oberfläche wird oder ob der Teil entfällt (klassenarbeit
   deckt Erwartungshorizont und Bewertungstabelle ab).

## 5. Hinweise an die Konvention

- `gutachten` ist ein Baustein, der wie sein Paket heißt; nachzutragen in
  K 2.1a/2.1b und `wortpaare.json` (Parameterwort keines; bei Bedarf
  `report`), Zwilling `report`.
- Neue Wörter in `words-en-zusatz.txt`: `anonymous`, `first`, `selected`,
  `dative`.
- `konvention.md` (Zeile 1133) nennt gutachten unter „tote Pakete ohne Zielversion";
  UMSETZUNG-0.5.0.md hat das überholt.

## 6. Maschinenlesbarer Anhang

**Lesart** wie in den anderen Tabellen: `funktionen` = alte → neue
Funktionsnamen (Stub und Codemod), `parameter` = `renamed`, `schluessel` =
`renamed` für Dictionary-Schlüssel, `entfernt` = `removed`, `kontext` =
Regeln, die nicht durch Namensersetzung lösbar sind.

```json
{
  "paket": "gutachten",
  "von": "0.0.2",
  "nach": "0.5.0",
  "import": {
    "@schule/gutachten:0.0.2": "@schule/gutachten:0.5.0",
    "@schule/gutachten:0.0.1": "@schule/gutachten:0.5.0"
  },
  "funktionen": {
    "set-gutachten-infos": "set-options",
    "set-aufgaben": "set-tasks",
    "bewertungsskala": "format-grade",
    "gutachten-optionen": "set-options"
  },
  "bausteine-unveraendert": ["gutachten", "aufgabe"],
  "bausteine-neu": {
    "gutachten": { "parameterwort": [], "zwilling": "report" }
  },
  "werte-unveraendert": ["name"],
  "parameter": {
    "set-options": {
      "fach": "subject",
      "niveau": "level",
      "kuerzel": "teacher",
      "anonym": "anonymous",
      "be": "max-points",
      "jahr": "year"
    },
    "set-tasks": {},
    "format-grade": {},
    "aufgabe": {
      "punkte": "points"
    },
    "gutachten": {
      "vorname": "first-name",
      "nachname": "last-name",
      "name": "last-name",
      "wahl": "selected-tasks"
    }
  },
  "schluessel": {
    "set-tasks": {
      "be": "max-points",
      "dativ": "dative",
      "name": "title"
    }
  },
  "werte": {},
  "entfernt": {
    "set-options": {
      "kurs": "seit 0.0.2 steht im Kopf nur noch Fach, Niveau und Kürzel; Angabe streichen",
      "pruefer": "seit 0.0.2 steht im Kopf das Kürzel der Lehrkraft; `teacher: \"…\"` schreiben",
      "korreferent": "seit 0.0.2 unterschreibt die Zweitkorrektur ohne Namen; Angabe streichen"
    },
    "gutachten": {
      "geschlecht": "seit 0.0.2 nennt das Gutachten den Vornamen ohne Anrede; Angabe streichen",
      "jahr": "steht jetzt in `set-options(year: …)`",
      "fach": "steht jetzt in `set-options(subject: …)`",
      "niveau": "steht jetzt in `set-options(level: …)`",
      "be": "steht jetzt in `set-options(max-points: …)`",
      "kurs": "seit 0.0.2 steht im Kopf nur noch Fach, Niveau und Kürzel; Angabe streichen",
      "pruefer": "steht jetzt als Kürzel in `set-options(teacher: …)`",
      "korreferent": "seit 0.0.2 unterschreibt die Zweitkorrektur ohne Namen; Angabe streichen"
    },
    "funktionen": {
      "sachgebiet": "gibt es seit 0.0.2 nicht mehr – die Aufgaben in `set-tasks` eintragen und je Aufgabe `aufgabe(\"…\", points: …)[...]` schreiben",
      "pflichtteil": "gibt es seit 0.0.2 nicht mehr – die Aufgaben in `set-tasks` eintragen und je Aufgabe `aufgabe(\"…\", points: …)[...]` schreiben"
    },
    "fremdnamen": ["qty", "num", "unit", "und alle weiteren Namen aus @preview/unify:0.7.0"]
  },
  "kontext": [
    { "alt": "aufgabe(<name>, <punkte>)[…]", "neu": "aufgabe(<name>, points: <punkte>)[…]", "regel": "zweites Positionsargument wird benannt" },
    { "alt": "fach: \"\", niveau: \"\", kürzel: \"\"", "neu": "Argument löschen", "regel": "leerer Text ist die Vorgabe none" },
    { "alt": "#import \"@schule/gutachten:0.0.2\": * mit Aufrufen von qty, num, unit", "neu": "zusätzlich #import \"@preview/unify:0.7.0\": qty, num, unit", "regel": "unify wird nicht mehr weitergereicht" }
  ],
  "vorgaben-geaendert": {
    "set-options.subject": ["\"\"", "none"],
    "set-options.level": ["\"\"", "none"],
    "set-options.teacher": ["\"\"", "none"]
  },
  "erlaubt": {
    "set-options": ["subject", "level", "teacher", "anonymous", "print", "max-points", "font", "math-font", "year"],
    "set-tasks": [],
    "set-tasks.<eintrag>": ["max-points", "dative", "title"],
    "format-grade": [],
    "aufgabe": ["points"],
    "gutachten": ["first-name", "last-name", "selected-tasks"]
  },
  "positionsargumente": {
    "set-options": { "min": 0, "max": 0 },
    "set-tasks": { "min": 1, "max": 1 },
    "format-grade": { "min": 1, "max": 1 },
    "aufgabe": { "min": 1, "max": 1, "body": true },
    "gutachten": { "min": 0, "max": 0, "body": true }
  },
  "stubs": ["set-gutachten-infos", "set-aufgaben", "bewertungsskala", "gutachten-optionen", "sachgebiet", "pflichtteil"],
  "states": {
    "gutachten-infos": "schule/gutachten/options@1",
    "schüler": "schule/gutachten/student@1",
    "aufgaben": "schule/gutachten/tasks@1",
    "punkte": "schule/gutachten/points@1",
    "erwartungen": "schule/gutachten/expectations@1",
    "aufgaben (bewertung.typ)": "schule/gutachten/expectation-tasks@1"
  },
  "labels": {
    "<vorname>-<nachname>-pages": "schule-gutachten-pages-<vorname>-<nachname>",
    "erwartungshorizont": "schule-gutachten-expectations",
    "bewertung": "schule-gutachten-points-table"
  },
  "intern": {
    "_anonym-name-placeholder": "internal.anonymous-placeholder",
    "_format-punkte-wert": "internal.format-points",
    "d_ew_erwartungen": "internal.expectation-entries",
    "d_ew_text": "internal.expectation-texts",
    "d_ew_punkte": "internal.expectation-points",
    "d_ew_gesamt": "internal.expectation-total",
    "d_ew_notenspiegel": "internal.grade-table",
    "d_ew_unterstufe": "internal.expectations-sek-1",
    "d_ew_oberstufe": "internal.expectations-sek-2",
    "d_ew_bewertung": "internal.points-table",
    "ew_verteilung_oberstufe": "internal.grade-boundaries-sek-2",
    "ew_namen_oberstufe": "internal.grade-names-sek-2",
    "ew_verteilung_unterstufe": "internal.grade-boundaries-sek-1",
    "ew_namen_unterstufe": "internal.grade-names-sek-1",
    "ew_verteilung_ohne_tendenz": "internal.grade-boundaries-plain",
    "ew_namen_ohne_tendenz": "internal.grade-names-plain"
  },
  "woerter-neu": ["anonymous", "first", "selected", "dative"],
  "oeffentlich": ["set-options", "set-tasks", "name", "format-grade", "aufgabe", "gutachten", "internal"]
}
```
