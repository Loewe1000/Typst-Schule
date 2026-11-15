# Gutachten aus Maintainer-Sicht: Konvention A, B, C

Stand 2026-11-14. Gelesen: alle drei Entwürfe vollständig, `nutzung-ausserhalb.md`, Auszüge aus `nutzung-im-repo.md` und `typst-technik.md`. Am Repo wurde nichts geändert.

Kriterien: (1) maschinelle Prüfbarkeit der Regel, (2) Zahl der Grenzfälle und Ausnahmen, (3) Konflikte mit Typst-Builtins und durchgereichten Fremd-APIs, (4) Zukunftsfähigkeit, (5) innere Widerspruchsfreiheit der vorgeschlagenen Signaturen. Der Umstellungsaufwand ist kein eigenes Kriterium (nichts bricht, Codemod existiert), fließt aber bei (4) ein, weil alte und neue Dokumente jahrelang nebeneinander gepflegt werden.

## Ergebnis

| Entwurf | Punkte | Kurzurteil |
|---|---|---|
| A Deutsch zuerst | 6,5 | sauberste Regel gegen Builtin-Überdeckung, aber dauerhafte Übersetzungsschicht vor Typst und mehrere Verstöße gegen die eigene Wertekonvention |
| **B Englisch zuerst** | **7** | einzige Regel ohne Sprachgrenze innerhalb eines Aufrufs; verliert Punkte durch die Alias-Schicht und durch Namen, die das eigene Lint ablehnen würde |
| C Regel-Hybrid | 4,5 | Kern der Regel (Durchreichtest) ist Urteilssache; überdeckt Builtins absichtlich; meiste Grenzfälle; mehrere Bedeutungen je Name |

Der Abstand zwischen B und A ist klein und hängt an einer Entscheidung, die nur der Autor treffen kann (siehe unten, Punkt 1 und 2). C scheidet aus Maintainer-Sicht klar aus.

Selbst geprüft mit Typst 0.15.1 (Testdateien unter `scratchpad/urteil-test/`):

- Ein Parameter `page: (:)` überdeckt die Funktion `page`; `set page(..page)` im Rumpf scheitert mit `expected function, found dictionary`. Mit `std.page`, `std.align`, `std.numbering`, `std.columns`, `std.label` kompiliert es.
- `#let e(..punkte, body)` funktioniert (`#e(2)[a]`, `#e[b]`).
- `title` und `symbol` sind in 0.15.1 Builtins; `#let aufgabe = task` als Alias und eine eigene Funktion `lines` kompilieren.

Nicht geprüft: die Wirkung der Options-Werte am Paketcode (siehe offene Entscheidung 5), das Verhalten von tidy/schuldocs bei Alias-Definitionen, und ob `task`/`lines`/`blank` in realen Dokumenten mit `: *`-Importen von cetz, gentle-clues oder colorful-boxes kollidieren.

---

## A: Deutsch zuerst (6,5)

**Prüfbarkeit: gut.** Eine Sprache, ein Regex, eine Positivliste. Preis: Weil der Lint Komposita nicht zerlegt, muss jedes zusammengesetzte Wort einzeln ins Glossar (`schriftgroesse`, `titelgroesse`, `beschriftungsgroesse`, `eintragsabstand`, `kopfabstand` …). "Ein Wort je Begriff" wird dadurch nur für ganze Wörter erzwungen, nicht für Wortbildung.

**Builtins: bester Entwurf.** R5 verbietet Parameter, die wie Typst-Funktionen heißen. Deutsche Namen überdecken praktisch nie etwas, auch nicht bei `: *`-Importen in 1474 Dokumenten.

**Fremd-APIs: schwächster Punkt.** Die Sprachgrenze läuft mitten durch einzelne Aufrufe:

- `#teilaufgaben(spalten: 2, inset: 5pt, align: left)`: deklariert deutsch, Sink englisch an `table`.
- `nebeneinander(ausrichtung: horizon, ..inhalte)`: `ausrichtung` ist deklariert, `align:` käme über den Sink ebenfalls bei `table` an. Der Entwurf sagt nicht, was dann gilt.
- `linie: (paint: …, thickness: 0.5pt)`, `seite: (margin: …)`, `versatz: (dx:, dy:)`: deutscher Name, englische Schlüssel.
- Seitenrand heißt im Kopf `seite: (margin: (top: …))`, in der Gestaltung `rand: (oben:, unten:, innen:, aussen:)`, und der Hook `hintergrund(druck:, oben:, rand:)` bekommt als `rand` wieder das Typst-Dictionary mit englischen Schlüsseln. Ein Begriff, drei Schreibweisen.
- Die Grenze wandert: Wertet das Paket später `inset` selbst aus, müsste es `innenabstand` heißen und bricht erneut (im Entwurf selbst als 8.4 genannt).

**Verstöße gegen die eigene Regel:**

1. `qr-kasten(breite:, url, text, ..weitere)` und `weblink(icon:, farbe:, url, text)` deklarieren `text`. Das verletzt R5 (keine Überdeckung) und R4 (`text→inhalt`). Die Fußnote "heißt in der Umsetzung `linktext`" macht die Signatur nicht regelkonform.
2. `nebeneinander(breiten: auto | Anzahl | Liste)`: `breiten: 2` ist eine Anzahl. 3.4 verlangt für Anzahlen ein Zählwort und für Maße `length`. In `teilaufgaben` heißt dieselbe Sache `spalten`.
3. `gestaltung: none` bedeutet "Standardgestaltung". Nach 3.1 heißt `none` "gibt es nicht", "Paket entscheidet" wäre `auto`.
4. `vordruck: none | "werte"` ist ein Enum mit einem Wert, nach 3.1 also ein `bool`.
5. `fuellfeld(anteil, zeichne)`: `zeichne` ist ein Imperativ außerhalb der vier erlaubten Vorsilben; `format` steht zugleich in der Lehnwortliste und in der Verbliste.
6. 3.3 verlangt einheitliche Wortart je Enum. `loesungen` hat `"direkt"` (Adverb), `"aufgabe"`, `"ende"`, `"seite"` (Singular), `"einzelseiten"` (Plural), `"nur"` (kein Ort).
7. `loesungen` bleibt doppelt belegt (Ort im Kopf, Array in `teilaufgaben`); im Entwurf eingeräumt.

**Stille Verhaltensänderungen, die keine Namensfragen sind:** `nebeneinander(abstand: 1.25em)` statt heute `spacing: 5mm` (1575 Aufrufe ändern ihr Layout), `linienabstand` überall 8mm statt 1cm in patterns (259 `liniert`-Aufrufe). Das gehört nicht in eine Umbenennungsversion.

**Zukunft:** Schließt eine Veröffentlichung unter gleichem Namen aus. Schwerer wiegt für den Alltag: Rund 1200 Dokumente bleiben auf alten Versionen mit `title`, `class`, `large`, `workspace`; neue Dokumente hätten ein vollständig anderes Vokabular (89 % der Kopfparameter, 96 % der Aufgabenaufrufe). Zwei Vokabulare über Jahre sind eine Dauerquelle für Fehlgriffe.

---

## B: Englisch zuerst (7)

**Prüfbarkeit: gut.** Positivliste, Negativliste, Eigennamen, Aliasliste; alles mechanisch. Zusätzliche strukturelle Regeln in R4 (kein `-only`, kein Typ im Namen, keine Ziffer als Wort) sind echte Lint-Regeln und fehlen in A und C. Die flachen Geschwister `points`, `points-position`, `points-format` sieht der Signatur-Snapshot; die Dictionaries von A und C (`punkte: (anzeige:, ort:, summe:, vorlage:)`) sieht er nicht.

**Fremd-APIs: bester Entwurf.** Deklarierte und durchgereichte Argumente haben dieselbe Sprache und meist denselben Namen (`columns`, `gutter`, `align`, `inset`, `stroke`, `fill`). Es gibt keine Übersetzungsschicht und keine wandernde Grenze.

**Builtins: schwächer als A.** `label`, `numbering`, `columns`, `align`, `stroke` als Parameter überdecken Builtins im Rumpf (lösbar mit `std.`, heute schon so). Englische Allerweltswörter als Funktionen (`task`, `lines`, `squares`, `blank`, `exam`, `solution`, `material`, `error`, `warning`) sind im `: *`-Import kollisionsanfälliger; gentle-clues hat selbst einen Kasten `task`.

**Verstöße gegen die eigene Regel** stehen im Abschnitt "Regelverstöße im Sieger".

**Zukunft:** Einziger Entwurf, der eine Veröffentlichung nicht verbaut, und der einzige, bei dem altes und neues Vokabular weitgehend gleich bleiben (17 von 40 Kopfparametern, alle häufigen Parameter von `aufgabe`/`teilaufgabe`). Der Preis sind erfundene Fachwörter (`expectation`, `answer-sheets`, `proposal`, `continuation`, `overprint`), die der einzige Nutzer nachschlagen muss.

---

## C: Regel-Hybrid (4,5)

**Prüfbarkeit: nur scheinbar.** Der Lint prüft Listenzugehörigkeit. Was in T steht, entscheidet der Durchreichtest, und der ist Ermessen. Vom Entwurf selbst als umstritten genannt: `title`, `numbering`, `rows`, `header`. T3 (`font-size`, `title-size`, `caption-size`, `math-font`) besteht den eigenen Namenstest nicht. `flipped` wird absichtlich nicht aufgenommen, obwohl es beide Tests besteht. Das ist Gewohnheitsrecht mit Liste.

**Builtins: schlechtester Entwurf.** T ist per Definition die Menge der Builtin-Namen. `arbeitsblatt(page: (:), header:, numbering:, …)` überdeckt `page` und `numbering` im Rumpf (Fehler oben nachgestellt). Dazu `symbol`/`symbole` als deutsches D-Wort, das zufällig ein Typst-Builtin ist.

**Mehrfachbedeutungen (Verstöße gegen das eigene L5):**

- `numbering`: im Kopf das Muster für Teilaufgaben (ohne Besitzer, obwohl R5 "schachteln" verlangt), in `aufgabe(numbering: auto | none)` ein An/Aus-Schalter, in `teilaufgaben` wieder das Muster.
- `loesungen`: Kopfparameter (Ort), Funktion `loesungen()` (Sammelausgabe), Parameter von `teilaufgaben` (Array). Der Parameter überdeckt in `arbeitsblatt` die Funktion.
- `teil`: `none | int` in `loesungen()` und `punktzahl()`, aber `bool` in `punktanzeige(punkte, teil: false)`.
- `width` in `kariert` wechselt bei gleichem Namen die Bedeutung (Kästchenzahl → Länge). Die Kästchenzahl ist danach gar nicht mehr einstellbar, obwohl `columns` in T steht (20 Aufrufe im Bestand).

**Weitere Schwächen:**

- L7 erzwingt `erwartungen: auto | none | dict` und `klausurboegen: none | auto | dict`. `auto` heißt laut 3.1 "Paket entscheidet", hier aber "an". 187 Kopfwerte ändern sich nur für diese Regel.
- Sichtbare Nähte in fast jeder Signatur: `title` neben `untertitel`, `header` (Parameter) neben `kopf` (Hook), `header-ascent` neben `kopf-oben`, `fill` neben `akzent` und `hintergrund`.
- `position` und `ort` stehen beide in D.
- `klausurboegen` nennt `vordruck` und `namen` nur im Fließtext, nicht in der Signatur.
- Die Liste ist an Typst 0.15.1 gebunden und muss bei jedem Typst-Update gegengeprüft werden.

**Stärken, die bleiben:** Schlüssel der Gestaltung heißen wie die Kopfparameter; Hook-Regel; `auswahl:` statt dreier Funktionen; `inset`/`align` deklariert statt im Sink; die Lint-Regeln L5, L7, L10.

---

## Sieger: B, mit Auflagen

B gewinnt bei Fremd-APIs, Zukunft und Vokabular-Kontinuität, und hat die schärfsten strukturellen Lint-Regeln. Es gewinnt nicht bei Builtin-Sicherheit (A) und nicht bei innerer Sauberkeit: Der Entwurf verstößt an mehr Stellen gegen sein eigenes Lint, als ein Entwurf mit diesem Anspruch dürfte.

### Regelverstöße und Lücken im Sieger

1. **R4 "kein Typ im Namen" gegen eigene Namen.** `subject-color`, `subject-colors` (Suffix `-color`), `operator-list` (Suffix `-list`).
2. **Kästen nicht ausbuchstabiert.** "Die 15 Kasten-Funktionen bleiben" lässt deren Parameter offen: `accent-color:` (17 Aufrufe) verletzt R4, `headless: true` ist ein Negativschalter (R10). Der Hook heißt schon `callout(accent:, …)`, die Funktionen nicht.
3. **R9 "Bestimmungswort Singular".** `solutions-heading`, `materials-heading`, `answer-sheets` als Bestimmungswort in Variantenwerten; nur `points` ist ausgenommen.
4. **Wortlisten widersprechen den Signaturen.** `rand` steht in `words-de.txt` (verboten), `random.rand` soll bleiben. `current` fehlt in `words-en.txt`, wird aber in `show-solutions(current:)` benutzt; ebenso fehlen `preprint`, `names`, `labels`, `labeled`, `word`, `bank` und das gesamte Vokabular aus 5.14.
5. **R11 "ein Wort je Begriff" gegen die Alias-Schicht.** Zwölf Funktionen heißen dauerhaft doppelt. Doku, Vorlagen und Tests schreiben `#task`, alle realen Dokumente `#aufgabe`: Der Alias-Pfad ist dann der meistbenutzte und der am wenigsten getestete. Ergebnis im Dokument ist `#aufgabe(title: …, workspace: kariert(4))`, also das heutige Mischbild.
6. **R12 "kein String oder Dictionary"** gegen `variants: auto | str | array | dictionary`, `theme: none | str | function | dictionary`, `columns: auto | int | array`, `points-format: f | (task:, subtask:)`. Nur der letzte Fall ist als Ausnahme benannt.
7. **R14 "ein Weg".** Drei Angaben sind positional und benannt möglich: Titel von `task`, `points` von `expectation`, `rows`/`columns` von `squares`. A und C lassen je einen Weg zu.
8. **`number` mit zwei Typen.** `task(number: true)` ist `bool`, im Hook `task: (number: 1, …)` ist es `int | none`.
9. **`grades` doppelt belegt.** Kopfparameter `grades: ()` meint Jahrgänge, intern `grade-boundaries` meint Notengrenzen.
10. **`solutions` dreifach belegt.** Ort im Kopf, Array in `subtasks(solutions:)`, Filter in `print-pagebreak(solutions: "only")`.
11. **Gestaltung und Kopf benennen dasselbe verschieden.** Kopf `font`, `math-font`, `font-size`, `title-font-size`; Gestaltung `fonts: (text:, math:, size:, title-size:)`. `margin` und `margins` stehen beide im Glossar. `header-ascent` ist in der Gestaltung ein eigener Schlüssel, im Kopf nur über `page-settings` erreichbar.
12. **`fill` und `background` überschneiden sich.** `squares(fill: white)` ist der Hintergrund der Fläche, `qr-code(background:)` ebenfalls; `qr-code(fill:)` ist dagegen die Vordergrundfarbe.
13. **Vorgabe von klassenarbeit geht verloren.** "Standardwerte stehen nur in aufgaben" und `points: none` dort; heute hat klassenarbeit `punkte: "aufgaben"`. `exam` deklariert `points-format`, aber nicht `points`. Entweder ändert sich das Verhalten still, oder die Aussage stimmt nicht.
14. **`gestaltung`-Aus.** `theme: none` heißt "Standard"; nach R12 wäre das `auto`.
15. **State-Schlüssel.** `"schule/tasks/options@1"` nennt ein Paket `tasks`, das `aufgaben` heißt.
16. **Externe Schnittstelle.** `<ab-meta>` mit deutschen Schlüsseln wird außerhalb gelesen; der Entwurf benennt das Problem, löst es aber nicht.

### Aus A und C zu übernehmen

Aus A:

- R5 als Lint: keine eigene *Funktion* und kein Sink-Name wie ein Builtin; Parameter, die absichtlich wie Typst heißen (`label`, `numbering`, `columns`, `align`), nur mit der Pflicht, im Rumpf `std.` zu schreiben.
- Export-Lint auf der tatsächlich exportierten Namensmenge per `typst eval`, nicht nur auf `#let` im Quelltext.
- Umlaut-Faltung in der Fehlermeldung (`lösungen` → "schreibt sich …") und die gezielte Meldung für das falsche Aus (`solutions: false`).
- Levenshtein-Abstand 1 innerhalb einer Signatur oder Werteliste als Lint-Fehler; Glossar mit Numerus-Vermerk (Vorgabe `()` verlangt Plural).
- `seitenumbruch(druck:, loesung:)` als eine Funktion mit zwei Dreiwert-Parametern statt `print-pagebreak`/`digital-pagebreak` mit überladenem `solutions:`. Englisch etwa `conditional-pagebreak(print: auto, solutions: auto)`.
- Kästen: `title: none` statt `headless: true`; gemeinsame Signatur aller Kästen.
- Abweichende Vorgaben einer Vorlage stehen sichtbar in deren Signatur (Tabelle A 4.4).
- Ein Weg je Angabe: Titel nur benannt, Punkte von `expectation` nur vorn.
- Die `[prüfen]`-Markierungen und der Hinweis, die Umbenennung als 0.5.0 zu veröffentlichen.

Aus C:

- Schlüssel der Gestaltung heißen exakt wie die gleichbedeutenden Kopfparameter (`font`, `math-font`, `font-size`, `margin`), kein verschachteltes `fonts`.
- Hook-Regel: Ein Hook bekommt dieselben Parameternamen wie der öffentliche Baustein, `body` zuletzt; Gestaltungsfunktion mit benannten Argumenten `(accent:, class:)`.
- `show-solutions(select: "all" | "current" | "pending")` statt `current: bool` plus eigener Funktion `show-pending-solutions`; ebenso `show-expectations(blocks: none | auto | array)` statt `all-blocks` plus `block-titles`.
- `set-options` mit deklarierten Parametern (`auto` = unverändert) statt Sink, damit der Signatur-Snapshot sie sieht.
- `inset` und `align` in `subtasks` deklarieren statt durchreichen.
- Lint-Regeln L5 (gleicher Parametername, gleicher Typ in allen Funktionen), L7 (keine bool/str-Mischung, mit Ausnahme "Funktion mit Einstellungen") und L10 (Options-Schlüssel = Kopfparameter).
- `is-print()` als öffentliches Prädikat neben `has-solutions()`.

### Entscheidungen, die nur der Autor treffen kann

1. **Sprache.** Ist eine Weitergabe (Universe, Kollegium außerhalb der eigenen Schule, englischsprachige Mitautoren) ein Ziel der nächsten Jahre? Wenn nein, ist A eine vertretbare Wahl und der Punktvorsprung von B gegenstandslos. Wenn ja oder offen, B.
2. **Alias-Politik bei B.** Drei Möglichkeiten: (a) englisch kanonisch plus zwölf deutsche Aliase wie im Entwurf; (b) die zwölf Fachbausteine sind kanonisch deutsch und haben keinen englischen Zwilling, alles andere ist englisch; (c) rein englisch ohne Alias, 100 % der Aufrufe ändern ihr erstes Wort. Aus Maintainer-Sicht ist (b) am ehrlichsten: Es beschreibt, was tatsächlich geschrieben wird, und die Regel bleibt syntaktisch prüfbar (Funktionsnamen aus fester Liste deutsch, Parameter/Schlüssel/Werte englisch).
3. **Versionsnummer.** 0.4.1 (58 Dokumente auf 0.4.0 erleben in derselben Minor-Linie einen Namensbruch) oder 0.5.0.
4. **Vokabular.** `task` oder `exercise`; Wörter für Erwartungshorizont, Klausurbogen, Vorschlag, Sozialform, BE; `grades` für Jahrgänge.
5. **Semantik der Options-Werte am Code bestätigen.** Die drei Entwürfe bilden `punkte: "keine-summe"` dreifach verschieden ab: A auf `(anzeige: "alle", summe: false)`, B auf `"leaf"`, C auf `(anzeige: "aufgaben", summe: false)`. Ebenso unbestätigt: `"sofort"` gegen `"folgend"`, `"reinquetschen"`.
6. **`points` flach oder als Dictionary.**
7. **Vorgaben, die das Layout ändern.** Zeilenabstand 8mm oder 1cm, Spaltenabstand 5mm oder 1.25em, `punkte`-Vorgabe in klassenarbeit, Leertext `""` oder `none`.
8. **Fremd-Exporte.** Welche Namen bleiben nach dem Ende der Wildcard-Re-Exporte bewusst durchgereicht (`stickybox` 45 Aufrufe, `canvas`, `draw`, `fa-*`, gentle-clues-Kästen)?
9. **`<ab-meta>`.** Schlüssel umbenennen, parallel ausgeben oder deutsch lassen; hängt an den externen Lesern (Materialbibliothek, eduki).
10. **klausurboegen.** Welche Teile aus 0.0.4 (`bogen-seiten`, `klausurbogen-arbeit`, `vordruck`, `namen`) überleben die Zusammenführung mit 0.0.5?
11. **Paketnamen und tote Pakete.** Bleiben `patterns`, `insert-a-word`, `random`, `energy-sketch` englisch neben `arbeitsblatt`, `aufgaben`? Werden `options`, `typopst`, `messwerttabellen`, `flashcards`, `gutachten` entfernt?
12. **Umfang der Migration.** Nur die rund 360 Dokumente auf 0.3.x/0.4.0 oder der ganze Bestand.
13. **`aufgabe[Titel][Rumpf]`.** Zweiweg-Form behalten (273 Aufrufe ohne Klammer, Anteil mit zwei Inhalten nicht gezählt) oder streichen.
