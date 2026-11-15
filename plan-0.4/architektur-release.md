# Architektur- und Release-Plan für die Linie 0.4.x der @schule-Pakete

Stand 2026-11-15 (Fassung nach der Prüfung durch zwei Prüfer und nach der Entscheidung des Autors vom 2026-11-15 „deutsche Bausteine auf Dauer"; was sich jeweils geändert hat, steht im Prüfprotokoll am Ende). Gilt zusammen mit `KONVENTION.md` (Namen) und den vier Tabellen `tabelle-arbeitsblatt.md`, `tabelle-aufgaben.md`, `tabelle-klassenarbeit.md` (mit klausurboegen und patterns) und `tabelle-fachpakete.md` (alt → neu je Paket). Dieser Plan ändert nichts am Repo; er beschreibt, in welcher Reihenfolge und mit welchen Werkzeugen der Umbau geschieht.

Begriffe in diesem Plan:

- **Zug**: eine gemeinsame Versionsnummer der Linie (0.4.1, 0.4.2, …). Ein Zug ist die Menge der Paketversionen, die zusammen getestet und zusammen eingefroren wurden. **Alle dreizehn Zugpakete tragen in jedem Zug dieselbe Nummer** (2.3).
- **Zugpakete**: die dreizehn Pakete aus `[zug].pakete` in `.github/buendel.toml`. Prüfbefehle und Skripte bestimmen die Ordner eines Zugs immer aus dieser Liste, nie über den Glob `*/0.4.1`: Der träfe auch das Submodul `blockst/0.4.1` (Universe-Paket, kein Zugpaket). In diesem Plan steht `$ZUG_SRC` für die Ausgabe von `pins-pruefen.py --ordner src` (die dreizehn Ordner `<paket>/<zug>/src`) und `$ZUG` für `pins-pruefen.py --ordner`.
- **Kernbündel**: `kern`, `aufgaben`, `arbeitsblatt`, `klassenarbeit`, `klausurboegen`, `patterns`. Die Unterscheidung zu den Fachpaketen bestimmt nur noch die Reihenfolge im Umbau und die Sollbruchstelle in Abschnitt 5, nicht mehr die Versionsnummern.
- **Fachpakete**: `mathematik`, `physik`, `informatik`, `operatoren`, `insert-a-word`, `random`, `energy-sketch`.
- **Rohling**: der frisch kopierte Versionsordner 0.4.1 mit noch alten Namen.
- **Baustein**: eine Funktion aus `.github/namen/bausteine-de.txt` (KONVENTION 2.1a, 30 Namen). Bausteine heißen auf Dauer deutsch (`arbeitsblatt`, `klassenarbeit`, `aufgabe`, `teilaufgabe`, `loesung`, `kariert`, `klausurboegen`, …) und haben keinen englischen Zweitnamen; einen Aliasblock und Übergangsnamen gibt es nicht.
- **Parameterwort**: das englische Wort, das in Parametern, Schlüsseln, Enum-Werten, Hooks, State-Schlüsseln und Aktionsnamen für einen Baustein steht (`task` für `aufgabe`, `solution` für `loesung`, `squares` für `kariert`, `answer-sheets` für `klausurboegen`; KONVENTION 2.1b, `wortpaare.json`). Wo in diesem Plan `task`, `subtask`, `solution`, `expectation`, `exam`, `worksheet`, `blank`, `squares`, `lines` oder `answer-sheets` steht, ist immer das Parameterwort gemeint, nie eine Funktion.
- **Stub**: abbrechende Funktion für einen alten Funktionsnamen in `src/removed.typ` (KONVENTION 9.3), Meldung „heißt jetzt".
- Größen: **S** bis ein halber Tag, **M** ein bis zwei Tage, **L** drei bis fünf Tage (eine Person mit Assistenz).
- **[prüfen]**: am Code noch nicht bestätigt. **[geprüft]**: heute mit Typst 0.15.1 nachgestellt.

Pfade ohne führenden Schrägstrich sind relativ zum Repo `/Users/alexander/Library/Application Support/typst/packages/schule`.

---

## 1. Zielbild der Paketlandschaft

### 1.1 Abhängigkeitsgraph im Zug 0.4.1

Alle Pakete des Zugs tragen 0.4.1. Jeder Pfeil ist ein namentlicher Import mit fester Version.

```
kern 0.4.1                (keine Importe, kein State, kein Counter)
 ▲
 ├─ random 0.4.1
 ├─ patterns 0.4.1        → @preview/cetz
 ├─ energy-sketch 0.4.1   → @preview/cetz
 ├─ operatoren 0.4.1      → @preview/tablex
 ├─ aufgaben 0.4.1        → @preview/fontawesome (namentlich), gentle-clues nur falls der Lösungskasten es braucht
 ├─ physik 0.4.1          → random; @preview: zap, fancy-units, zero, tablex
 ├─ informatik 0.4.1      → @preview/blockst, cetz, cetz-plot
 ├─ mathematik 0.4.1      → random, physik (nur physik.internal für die Einheitenumrechnung);
 │                          @preview: cetz, cetz-plot, eqalc, zero, fancy-units
 │                          KEIN Import von aufgaben mehr (eigene teilaufgaben/tasks entfallen)
 ├─ insert-a-word 0.4.1   → random, aufgaben (nur has-solutions)
 ├─ klausurboegen 0.4.1   → patterns (kariert, liniert statt Nachbau)
 ├─ arbeitsblatt 0.4.1    → aufgaben, patterns, random, insert-a-word, energy-sketch,
 │                          mathematik, physik, informatik, operatoren; @preview wie heute
 └─ klassenarbeit 0.4.1   → arbeitsblatt, aufgaben, klausurboegen
```

Regeln zum Graphen:

1. **Keine Raute mit zwei Versionen.** In der transitiven Hülle jedes Zugpakets kommt jedes @schule-Paket in genau einer Version vor. Das beseitigt die heutigen Doppel-Instanzen (mathematik → aufgaben 0.1.2, klausurboegen → patterns 0.0.1, arbeitsblatt → energy-sketch 0.0.2). Weil jedes Zugpaket `kern` importiert und `kern` jede Zugnummer bekommt, folgt daraus zwingend: Jedes Zugpaket fährt jeden Zug mit (2.3). Geprüft von `pins-pruefen.py` (3e).
2. **Import beim Eigentümer.** klassenarbeit importiert aufgaben direkt (für `set-options`, `show-solutions`, `show-expectations`, `aufgaben.internal`), nicht über arbeitsblatt. Die Pin-Prüfung stellt sicher, dass es dieselbe Version ist.
3. **Externe Pakete bleiben auf den heutigen Versionen** (cetz 0.4.2, cetz-plot 0.1.3, zero 0.5.0, fontawesome 0.6.0, gentle-clues 1.2.0, unify 0.8.1, tablex 0.0.9, blockst 0.1.0). Einzige Ausnahme: energy-sketch 0.4.1 entsteht aus 0.0.3 (cetz 0.5.2); arbeitsblatt hängt heute an 0.0.2 (cetz 0.3.1). Diese eine Hebung wird in Phase 3 als eigener Schritt geprüft (1 Dokument im Bestand nutzt das Paket direkt).
4. Jede `typst.toml` des Zugs trägt ein `compiler`-Feld. Vorgabe ist `"0.15.0"`. Heute haben die Manifeste von arbeitsblatt, klassenarbeit und aufgaben kein solches Feld und laden deshalb auf jeder Typst-Version; mit dem Feld verweigert ein älterer Compiler das Paket ganz. Die Typst-Version der iPad-App Typist steht in keinem Inventar; sie wird in Phase 0 festgestellt. Liegt sie unter 0.15, entscheidet der Autor: Wert auf die tatsächlich nötige Mindestversion senken oder die Einschränkung in README und `UMSTELLUNG.md` nennen.

### 1.2 Gemeinsames Kernpaket: ja, klein und zustandslos

**Entscheidung: Es gibt ein neues Paket `@schule/kern`.** Es enthält nur reine Funktionen und Daten:

| Inhalt | Datei | Herkunft |
|---|---|---|
| `fail(package, function, message)` | `kern/0.4.1/src/fail.typ` | KONVENTION 8.1, 8.2 |
| `check(package, function, named, …)`: Namen, Typen, Werte, alte Namen, alte Werte, Tippfehlervorschlag (bei Enum-Werten auch vom deutschen Bausteinnamen zum Parameterwort), Umlaut-Faltung | `kern/0.4.1/src/check.typ` | `technik/compat.typ` |
| `rules`: die eingelesene Umbenennungstabelle samt Wortpaaren (`wordpairs`) | `kern/0.4.1/regeln.json`, eingelesen in `src/rules.typ` | 3a |
| Einstieg mit namentlichen Exporten | `kern/0.4.1/src/lib.typ` | – |

Begründung:

- **Eine Quelle für die Laufzeit.** Ein Typst-Paket kann nur Dateien aus dem eigenen Ordner lesen (`read("@schule/…")` schlägt fehl, Technik-Inventar Abschnitt 6). Liegt `regeln.json` in `kern`, lesen Laufzeitprüfung, Codemod und Lint dieselbe Datei. Ohne Kernpaket müsste die Tabelle in zwölf Pakete kopiert werden. Regeln, die nur der Codemod braucht, liegen außerhalb des eingefrorenen Paketordners (3a).
- **Ein Meldungsformat.** `<paket>.<funktion>: <Befund> – <Abhilfe>` entsteht an genau einer Stelle; L21 wird damit prüfbar.
- **Leaf-Pakete brauchen die Prüfung auch.** `random`, `patterns`, `physik` importieren aufgaben nicht und sollen es nicht. Der einzige gemeinsame Vorfahr ist ein eigenes Paket.
- **Kosten sind gemessen klein.** 2000 Prüfaufrufe kosten 0,05 s.

Bedingungen, die das Kernpaket ungefährlich halten:

- `kern` legt keinen State, keinen Counter, kein Label an und importiert nichts. Lint-Regel K1: kein `state(`, `counter(`, `query(`, `import "@` in `kern/`. Zwei Kernversionen im selben Dokument kommen innerhalb eines Zugs nicht vor (Regel 1); geraten sie über einen gemischten Import doch zusammen, stören sie sich nicht, weil `kern` nichts teilt.
- `kern` wird in Dokumenten nie importiert. Jedes Paket bindet es in seiner `src/internal.typ` und reicht es gebunden weiter: `#let fail = kern.fail.with("aufgaben")`, `#let check = kern.check.with("aufgaben")`. Damit bleibt KONVENTION 7.2 und 8.4 wörtlich richtig (`internal.check`, `internal.fail`).
- Das Options-Schema (KONVENTION 6) steht als Daten in `regeln.json` unter `schemas.options`; aufgaben stellt es als `aufgaben.internal.option-schema` bereit. Die States dazu gehören aufgaben, nicht kern.
- `kern` kennt keinen Schalter `--input streng=1` mehr und hat keine Datei `strict.typ`: Es gibt keine Übergangsnamen, die er zum Fehler machen müsste (KONVENTION 9.3).

Verworfen: (a) die Prüfung in jedes Paket kopieren und per CI auf Gleichheit prüfen (zwölf Kopien, zwölf Ausschnitte der Tabelle); (b) alles in aufgaben legen (dann müssten `random` und `patterns` aufgaben importieren); (c) das alte Paket `options` wiederbeleben (nutzt `locate`, läuft unter 0.15 nicht).

`kern` ist ein dreizehntes Paket und in KONVENTION 2.1 noch nicht als Paketname aufgeführt; das ist dort nachzutragen. `kern` hat keine Oberfläche für Dokumente: Es bekommt eine `README.md`, aber kein `src/internal.typ` und kein `docs/docs.typ`.

### 1.3 Öffentliche Oberfläche und Re-Exporte

Jedes Zugpaket bekommt `src/lib.typ` (Einstieg laut `typst.toml`) und, außer `kern`, `src/internal.typ`. In Paketquelltext steht kein `import …: *` mehr.

**Was arbeitsblatt 0.4.1 exportiert.** Maßgeblich ist die wörtliche Namensliste `.github/namen/exporte/arbeitsblatt.txt` (eine Zeile je Name mit Herkunftspaket), eingecheckt und vom Lint gegen `dictionary(lib)` geprüft. Sie wird aus `tabelle-arbeitsblatt.md` Abschnitt 4.1 bis 4.3 übertragen. Die folgende Tabelle fasst sie zusammen; bei einem Widerspruch gilt die Datei.

| Gruppe | Namen | Quelle |
|---|---|---|
| eigene | Bausteine `arbeitsblatt`, `arbeitsblatt-einzeln`, `luecke`, `lsg`; englisch `minipage`, `workspace`, `conditional-pagebreak`, `qr-code`, `qr-box`, `icon-link`, die 15 Kästen, `themes`, `subject-accents`, `subject-names`, `callout-style` und die übrigen laut `tabelle-arbeitsblatt.md` | arbeitsblatt |
| Aufgaben | alle öffentlichen Namen von aufgaben: Bausteine `aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung`; sprachgleich `material`; Aktionen und Abfragen `set-options`, `show-…`, `get-points`, `format-points`, `has-solutions`, `is-print`, `reset-tasks` | aufgaben |
| Muster | Bausteine `kariert`, `liniert`; englisch `flex-area`, `is-flex-area` | patterns |
| Fachpakete | aus mathematik `graphen`, `steckbrief`, `kreisdiagramm`, `geogebra-algebra`, `geogebra-cell`; aus physik `datensatz`, `messdaten`, `berechnung`, `messwerttabelle`, `constants`, die sechs Regressionen (`lineare-`, `quadratische-`, `wurzel-`, `exponentielle-`, `polynom-`, `potenz-regression`), `schaltkreis`; aus informatik `bin-to-dec`, `dec-to-bin`, `hex-to-dec`, `dec-to-hex`, `haeufigkeitsanalyse`, `caesar`, `vigenere`, `atbash`, `rot13`, `ascii-table`, `text-to-blocks`; aus operatoren `operator`, `operatoren-liste`; aus insert-a-word `insert-a-word`, `iaword`, `reset-iaword`; aus energy-sketch `energy-sketch`; aus random `random-number`, `random-integer`, `shuffle`, `default-seed` | jeweiliges Paket |
| Fremdnamen | `canvas`, `draw`, `plot`, `qty`, `num`, `unit`, `stickybox`, `fa-icon` | `.github/namen/fremdnamen.txt` |
| Stubs alter Funktionsnamen | die abbrechenden Funktionen aus `removed.typ` nach KONVENTION 9.3: eigene (`lücke`, `qrbox`, `tasks`, `print-pagebreak`, `non-print-pagebreak`, …) und, namentlich re-exportiert, die der durchgereichten Pakete (`show-loesungen`, `reset-aufgaben`, `loesungsmodus`, `flex-feld`, `häufigkeitsanalyse`, `lineare_regression`, `bin2dec`, `iaword-neu`, …). Englische Zwillinge (`.github/namen/zwillinge.txt`) bekommen keinen Stub und werden nie exportiert | Eigentümerpaket |
| intern | Modul `internal` | – |

Die Familie bleibt also über `#import "@schule/arbeitsblatt:0.4.1": *` erreichbar. Grund: 1201 von 1457 Dokumenten importieren nur arbeitsblatt und benutzen daraus `operator` (348 Aufrufe), `messwerttabelle` (122), `iaword` (160), `graphen` (32). Diese Aufrufe bleiben beim Anheben wörtlich stehen; nur ihre Parameter ändern sich. Ein zweiter Import je Fachpaket wäre für den Autor Mehrarbeit ohne Gewinn. Der Preis: Alle dreizehn Pakete fahren jeden Zug mit (2.3).

Festlegungen zu den strittigen Stellen der Liste:

- **physik.** arbeitsblatt reicht `schaltkreis` durch, die zap-Bauteile (`source`, `multimeter`, `lamp`, `ammeter`, `voltmeter`, `motor`, `generator`) aber nicht (tabelle-arbeitsblatt Zweifelsfall 7). Wer einen Schaltkreis zeichnet, importiert die Bauteile aus physik: `#import "@schule/physik:0.4.1": source, lamp`. Dieselbe Zugnummer macht das gefahrlos; der Codemod fügt die Zeile ein (Herkunft in `herkunft.json`). Ob stattdessen die Bauteile mit durchgereicht werden (dann mit Einträgen in `kollisionen-erlaubt.txt`, weil `source`, `lamp`, `motor` Allerweltsnamen sind), ist eine offene Entscheidung für Phase 0.
- **insert-a-word.** Durchgereicht werden nur die drei öffentlichen Funktionen. Die heute exportierten States und der Counter (`iaword-list` usw.) wandern nach `insert-a-word.internal` (1.4).
- **informatik.** Die sechs blockst-Namen (`blockst`, `scratch`, `set-blockst`, `blockst-run-options`, `set-scratch-run`, `scratch-run`) entfallen als Re-Export; 47 Dokumente importieren `@preview/blockst` schon selbst, für die übrigen fügt der Codemod die Importzeile ein.
- **Widerspruch zwischen den Tabellen.** `tabelle-fachpakete.md` (Abschnitt 9, „Folge von § 7.1") sagt, arbeitsblatt exportiere keinen Namen eines Fachpakets; `tabelle-arbeitsblatt.md` 4.2 reicht sie namentlich durch. Dieser Plan folgt `tabelle-arbeitsblatt.md` 4.2; der Satz in `tabelle-fachpakete.md` ist beim Übertragen nach `regeln.json` zu streichen.

klassenarbeit 0.4.1 exportiert dieselbe Liste plus den eigenen Baustein `klassenarbeit`, `logos` und die eigenen Stubs, ebenfalls namentlich (`.github/namen/exporte/klassenarbeit.txt`). Die Funktion `klausurboegen` gibt es nur im Paket klausurboegen (dort auch der Stub `klausurbögen`); in `klassenarbeit` steht dafür der Parameter `answer-sheets: (…)`, der das Parameterwort trägt. aufgaben, patterns und die Fachpakete exportieren nur Eigenes, ihre eigenen Stubs und `internal`.

Wem ein Baustein gehört: Jeder Name aus `bausteine-de.txt` wird von genau einem Paket definiert (L23 a). Im Kern sind das aufgaben fünf (`aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung`), patterns zwei (`kariert`, `liniert`), klausurboegen einer, arbeitsblatt vier (`arbeitsblatt`, `arbeitsblatt-einzeln`, `luecke`, `lsg`), klassenarbeit einer. Jedes andere Paket re-exportiert den Namen per Import beim Eigentümer und bindet ihn nicht neu; `#let x = aufgabe` im Exportblock wäre ein Alias und ist verboten (L23 c). So ist `arbeitsblatt.aufgabe` dasselbe Objekt wie `aufgaben.aufgabe` (K3). Die Fehlermeldung nennt das Eigentümerpaket und den deutschen Funktionsnamen (`aufgaben.aufgabe: …`), auch wenn das Dokument nur arbeitsblatt importiert. Dasselbe gilt für die Stubs (`aufgaben.show-loesungen: …`).

**Was nicht mehr durchgereicht wird** (heute rund 5480 Namen): alles Übrige aus cetz, cetz-plot, fontawesome (`fa-*` außer `fa-icon`), gentle-clues (`clue`, der Kasten `task`, …; weil es auch keine eigene Funktion `task` gibt, ist `#task[…]` nach dem Anheben ein gewöhnlicher Typst-Fehler „unknown variable" und keine still geänderte Bedeutung), codly, zebra, eqalc, zero, unify, colorful-boxes (außer `stickybox`), dazu `a`, `m`, `lcg` aus random, die zap-Bauteile aus physik (`zap`, `source`, `simple-source`, `multimeter`, `lamp`, `amperemeter`, `voltmeter`, `motor`, `generator`), die sechs blockst-Namen aus informatik und die States von insert-a-word.

**Wie Dokumente an Fremdpakete kommen:**

1. Das Dokument importiert selbst: `#import "@preview/cetz:0.4.2"`.
2. Die Version muss zur Version passen, die arbeitsblatt benutzt, sonst vertragen sich `canvas` (aus arbeitsblatt) und `cetz.draw.*` (aus dem Dokument) nicht. Deshalb erzeugt `.github/scripts/fremdpakete.py` aus den Importzeilen von `arbeitsblatt/<zug>/src/lib.typ` die Datei `.github/namen/fremdpakete.json` (Paket → Version → Namen). Sie speist die Tabelle „Fremdpakete und ihre Versionen" in der Doku und den Codemod.
3. Der Codemod (3c) fügt beim Anheben eines Dokuments fehlende Importzeilen ein: Er kennt aus `.github/namen/herkunft.json` für jeden früher durchgereichten Namen das Ursprungspaket samt Version. Benutzt ein Dokument einen solchen Namen, ohne ihn selbst zu definieren oder zu importieren, schreibt er `#import "@preview/<paket>:<version>": <namen>` hinter den @schule-Import.

Kollisionsschutz über Paketgrenzen (Ergänzung zu L12): Die Vereinigung der Exporte aller Zugpakete ist kollisionsfrei, außer derselbe Name ist dasselbe Objekt (Re-Export). Heute kollidieren zum Beispiel `mono` (arbeitsblatt und informatik) und `qty`/`num`/`unit` (arbeitsblatt über unify, physik über fancy-units). In 0.4.1 exportiert physik keine eigenen `qty`, `num`, `unit`.

Kollisionen mit Fremdimporten im Dokument: 1474 von 1576 Importen sind Wildcards, und neben arbeitsblatt stehen im Bestand am häufigsten tablex (244 Dateien), unify (55), blockst (47), pinit (39), mannot (19), metro (16; exportiert selbst `qty`, `num`, `unit`), codly (16), dazu die Nicht-Zugpakete summify (15 Dokumente zusammen mit arbeitsblatt), typstage, abbozza, eduki. L12 in der Fassung der KONVENTION prüft nur gegen std, cetz, cetz-plot, fontawesome, colorful-boxes und gentle-clues. Der Plan erweitert die Prüfmenge: `.github/namen/mitimporte.json` nennt die 15 häufigsten Fremdpakete aus `nutzung-ausserhalb.md` und die genannten Nicht-Zugpakete mit den Versionen des Bestands; `fremdpakete.py` schreibt ihre Exportmengen dazu, und das Lint meldet jeden neuen Export eines Zugpakets, der dort vorkommt und nicht in `kollisionen-erlaubt.txt` steht. Der Codemod berichtet je Dokument die tatsächlich kollidierenden Namen (3c).

### 1.4 State-Schlüssel-Schema

Muster nach KONVENTION 7.3: `schule/<paket>/<name>@<schema>`. Jeder State entsteht genau einmal in der `src/internal.typ` des Eigentümers.

| heute | Zug 0.4.1 | Eigentümer |
|---|---|---|
| `state("options")`, dazu roh `state("options", (:))` an drei Stellen in arbeitsblatt | `schule/aufgaben/options@1` | aufgaben |
| `state("aufgaben")` | `schule/aufgaben/records@1` | aufgaben |
| `counter("aufgaben")` | `schule/aufgaben/task-counter@1` | aufgaben |
| `"current_material_aufgabe"`, `"current_material_index"` | `schule/aufgaben/material-position@1` (ein Dictionary) | aufgaben |
| `"in_loesung"`, `"in_aufgabe"`, `"in_teilaufgabe"` | `schule/aufgaben/context@1` (ein Dictionary `(solution:, task:, subtask:)`) | aufgaben |
| `"current_aufgabe_index"`, `"loesungen_gezeigt"`, `"ta_material_vorher"` | `schule/aufgaben/progress@1` | aufgaben |
| `"ab-theme"` | `schule/aufgaben/theme@1` | aufgaben (arbeitsblatt schreibt über `internal.set-theme`) |
| `"ab-scope"` | `schule/arbeitsblatt/scope@1` | arbeitsblatt |
| `state("print")` (doppelt zu `options.print`) | entfällt; `print` steht nur in `options@1` | – |
| `"ka-variante"`, `counter("klassenarbeit")` | `schule/klassenarbeit/variant@1`, `schule/klassenarbeit/exam-counter@1` | klassenarbeit |
| States in operatoren | `schule/operatoren/used@1`, `schule/operatoren/config@1` | operatoren |
| insert-a-word: `"iaword-list"` | `schule/insert-a-word/words@1` (`internal.words`) | insert-a-word |
| insert-a-word: `counter("iaword-counter")` | `schule/insert-a-word/block-counter@1` (`internal.block-counter`) | insert-a-word |
| insert-a-word: `"iaword-uniform"`, `"iaword-start"` | `schule/insert-a-word/uniform@1`, `schule/insert-a-word/start@1` | insert-a-word |
| insert-a-word: `"iaword-solution"` (nur geschrieben), `"iaword-show"` (ersetzt durch `aufgaben.has-solutions()`) | entfallen | – |
| Figure-Kinds `"aufgabe"`, `"teilaufgabe"`, `"material"` | `"task"`, `"subtask"`, `"material"` (Werte, also Parameterwörter nach KONVENTION 2.1b; die Bausteine dazu heißen weiter `aufgabe` und `teilaufgabe`); Supplement bleibt deutsch. Öffentlich, weil ein Dokument `figure.where(kind: …)` schreiben kann (tabelle-aufgaben Zweifelsfall 8) | aufgaben |
| Labels `<_ab-start-{scope}>`, `<_ab-ende-{scope}>`, `<_zweifach-oben>`, `<_zweifach-ende>` | `<schule-arbeitsblatt-start-{scope}>`, `<schule-arbeitsblatt-end-{scope}>`, `<schule-arbeitsblatt-two-up-top>`, `<schule-arbeitsblatt-two-up-end>` | arbeitsblatt |
| `label("ende-arbeitsblatt-id-<id>-<variante>")`, `metadata("ende-des-dokuments")` | nach `tabelle-klassenarbeit.md` (Präfix `schule-klassenarbeit-`) | klassenarbeit |
| Label `<_aufgaben-reset>` | `<schule-aufgaben-reset>` | aufgaben |
| `<ab-meta>` | unverändert (eingefroren) | arbeitsblatt |

Regeln:

- `@<schema>` wird erhöht, sobald sich die Gestalt des Werts ändert (Schlüssel dazu, weg, umbenannt, anderer Typ). Eine reine Wertänderung erhöht nicht.
- Die Zusammenlegung mehrerer States zu einem Dictionary geschieht nur, wo alle Schreibstellen im selben Paket liegen. Ist das im Einzelfall aufwendiger als gedacht, bleibt es bei einem State je altem State mit neuem Schlüssel; der Schlüssel folgt trotzdem dem Muster.
- Alte Paketversionen (Schlüssel `"options"`) und neue (`schule/aufgaben/options@1`) teilen sich nichts mehr. Ein Dokument, das alt und neu mischt, bekommt zwei getrennte Aufgabenwelten. Ganz getrennt sind sie nicht: `reset-aufgaben` alter Versionen setzt die Zähler der Bild- und Tabellen-Figures global zurück. Die Mischung wird deshalb gemeldet, und zwar auf zwei Wegen (die nächsten beiden Punkte).
- **Schlüssel sind mehr als States.** Jeder String in `state("…")`, `counter("…")`, `figure(kind: "…")`, `label("…")` und jedes `<…>`-Label im Paketquelltext steht mit Eigentümer in `regeln.json` unter `keys`. Lint-Regel K4 prüft das; ein Zugriff aus einem anderen Paket ist nur laut `intern-vertrag.json` erlaubt. Für `figure.where(kind: "aufgabe"|"teilaufgabe")` in Dokumenten hat der Codemod eine Regel und einen Berichtseintrag; ein Golddokument (`ab-verweise.typ`) verweist auf Aufgabe, Teilaufgabe und Material.
- **Versionsmarke gegen gemischte Züge (neu mit neu):** `aufgaben.internal.version-marker` setzt `metadata((package: "aufgaben", version: "0.4.1"))<schule-aufgaben-version>`. `aufgabe`, `arbeitsblatt`, `klassenarbeit` und jeder Baustein eines anderen Pakets, der aufgaben befragt (insert-a-word), setzen die Marke. `arbeitsblatt` und `klassenarbeit` fragen sie am Dokumentende ab; bei mehr als einer Version: ``arbeitsblatt.arbeitsblatt: zwei Versionen von aufgaben im Dokument (`0.4.1`, `0.4.2`) – alle @schule-Importe auf denselben Zug heben``.
- **Altprüfung gegen Pakete vor 0.4.1 (alt mit neu):** Die Versionsmarke setzen nur Pakete ab 0.4.1. Ein altes Paket neben einem neuen bleibt damit unsichtbar [geprüft, `pruefung/mach/m1.typ`: neues Paket plus `@schule/mathematik:0.0.2` mit `teilaufgaben` ergibt genau eine Marke, obwohl `counter("aufgaben").final()` = (0, 2) ist]. Gerade solche Kombinationen stehen im Bestand (arbeitsblatt+informatik 21, arbeitsblatt+mathematik 11, klassenarbeit+informatik 8, klassenarbeit+random 7, arbeitsblatt+physik 4). `arbeitsblatt` und `klassenarbeit` prüfen deshalb am Dokumentende zusätzlich die alten Schlüssel: `state("aufgaben", ()).final().len() > 0`, `counter("aufgaben").final() != (0,)`, `query(figure.where(kind: "aufgabe")).len() > 0`, `state("iaword-list", ()).final().len() > 0`. Trifft eines zu: ``arbeitsblatt.arbeitsblatt: ein @schule-Paket vor 0.4.1 ist im Dokument – alle @schule-Importe auf den Zug heben``. Wichtig: den Anfangswert `()` angeben. `state("aufgaben").final()` ohne Anfangswert bricht in `aufgaben.typ:945` mit „type none has no method push" ab, weil Typst die Updates mit dem Anfangswert des abfragenden Handles nachspielt [geprüft]. Ein altes Fachpaket, das die alte Aufgabenwelt nicht benutzt (etwa nur `graphen` aus mathematik 0.0.2), löst nichts aus. Test: `tests/zug/arbeitsblatt-altpaket.typ` (arbeitsblatt 0.4.1 plus mathematik 0.0.2 mit `teilaufgaben`, erwartet die Meldung).

### 1.5 Schnittstelle arbeitsblatt ↔ aufgaben ↔ klassenarbeit

Zugriff zwischen Paketen läuft nur über das Modul `internal` des Eigentümers. Die Namen, die ein anderes Paket benutzen darf, stehen in `.github/namen/intern-vertrag.json`; das Lint meldet jeden Zugriff `<paket>.internal.<name>`, der dort fehlt (Regel K2).

**`aufgaben.internal` (Vertrag):**

| Name | Art | ersetzt heute | Nutzer |
|---|---|---|---|
| `option-schema` | Dictionary (aus `kern.rules.schemas.options`) | Wertelisten in `_pruefe` | arbeitsblatt, klassenarbeit |
| `get-options()` | kontextuelle Funktion → Dictionary | `_state_options.get()`, `state("options", (:))` | arbeitsblatt, insert-a-word |
| `init-options(dictionary)` | Funktion → content; setzt den vollen Satz am Dokumentanfang, geprüft | `_state_options.update(…)` in arbeitsblatt | arbeitsblatt, klassenarbeit |
| `set-theme(dictionary)`, `theme-hook(name)` | Funktionen | `_state_theme`, `_theme-hook` | arbeitsblatt |
| `records()` | kontextuelle Funktion → Array | `_state_aufgaben` | arbeitsblatt (Shortcodes, Verweise) |
| `task-counter` | Counter | `_counter_aufgaben` | arbeitsblatt |
| `material-position()` | kontextuelle Funktion → `(task-number:, index:)` | `_state_current_material_*` | arbeitsblatt (Beschriftung „M1-A") |
| `in-solution()` | kontextuelle Funktion → bool | `_state_in_loesung` | arbeitsblatt |
| `version-marker` | content | – | arbeitsblatt, klassenarbeit, insert-a-word |

Öffentlich bleibt alles, was auch ein Dokument schreiben darf (`set-options`, `reset-tasks`, `show-solutions(select: "pending")`, `show-expectations`, `has-solutions`, `is-print`).

**`arbeitsblatt.internal` (Vertrag für klassenarbeit):**

| Name | ersetzt heute |
|---|---|
| `resolve-theme(theme, accent: auto, class: none)` | `_theme-aufloesen` (klassenarbeit.typ:86) |
| `scope()` | `_state_ab_scope` (klassenarbeit.typ:319) |
| `theme-keys` | zweite Kopie des Theme-Vertrags im Kommentar von aufgaben.typ:22–26 |

`reset-iaword` (heute `iaword-neu()`, von arbeitsblatt.typ:619 aufgerufen) ist öffentlich; dafür braucht es keinen Vertragseintrag. Die States von insert-a-word liest kein anderes Paket.

`arbeitsblatt-einzeln(scope: …)` ist öffentlich und der einzige Weg, auf dem klassenarbeit ein Blatt setzt.

**Kein blindes Durchreichen mehr.** `klassenarbeit` deklariert alle Parameter aus KONVENTION A.2, prüft sie mit `internal.check` unter dem Präfix `klassenarbeit.klassenarbeit` (Funktion heißt wie das Paket, das Wort steht bewusst zweimal; KONVENTION 8.2) und reicht sie namentlich an `arbeitsblatt-einzeln` weiter. Typst kann Signaturen nicht erzeugen; „aus einer Parametertabelle erzeugt" (KONVENTION A.1) heißt deshalb: Die Signaturen sind von Hand geschrieben, und L17 prüft sie gegen `regeln.json` (`schemas.options`, `schemas.page`, `schemas.design`).

**Theme-Vertrag.** Die Schlüssel und Hook-Signaturen aus KONVENTION A.12 stehen als `schemas.theme` in `regeln.json`. arbeitsblatt prüft jedes aufgelöste Theme-Dictionary dagegen (unbekannter Schlüssel ist ein Fehler, alter Schlüssel `kopf` meldet „heißt jetzt `header`", alter Hook-Schlüssel `aufgabe` meldet „heißt jetzt `task`"). aufgaben liest nur über `internal.theme-hook(name)` und kennt die Hooknamen `task`, `task-marker`, `subtask`, `solution`, `solution-heading`, `material-heading` und den Wert-Schlüssel `task-marker-width`. Hooks sind Schlüssel und deshalb englisch; sie tragen das Parameterwort des Bausteins, den sie zeichnen (`task` für `aufgabe`, `subtask` für `teilaufgabe`, `solution` für `loesung`; KONVENTION A.12, L18). Deutsche Hook-Namen gibt es nicht; sie schlagen in L27 an.

**Grenze der Theme-Prüfung.** Prüfbar sind nur die Schlüssel. Hooks sind Funktionen des Nutzers mit benannten Parametern (heute `kopf(title:, class:, copyright:, font-size:)`, `aufgabe(nummer:, titel:, icons:, punkte:, large:, number:)`, `kasten(art:, titel:, farbe:, …)`), und Typst kann die Parameter einer Funktion nicht abfragen (typst-technik.md Abschnitt 6). Ruft das Paket einen alten Nutzer-Hook mit den neuen Namen auf, entsteht ein nackter Fehler „unexpected argument" aus dem Paketinneren. Eigene Themes entstehen laut Doku als Funktion (`(akzent, class) => themes.klar(akzent, class) + (…)`); das ist kein Dictionary-Literal. Auch der Positionsparameter `akzent` der Theme-Funktionen ändert sich. Gegenmaßnahmen:

1. Der Codemod erkennt ein Lambda-Literal als Wert eines bekannten Theme-Schlüssels und benennt dessen Parameter um; alles andere (Theme aus einer Variablen, aus einer anderen Datei) kommt in den Bericht: „eigenes Theme von Hand prüfen".
2. In Phase 1 wird im Korpus gezählt, wie viele der 37 `theme`-Köpfe kein String sind. Die Zahl steht im Korpus-Bericht und bestimmt, ob Punkt 1 reicht.
3. `UMSTELLUNG.md` führt die nackte Meldung wörtlich mit Ursache und Abhilfe („Hook-Parameter heißen jetzt …"); ein Test (`tests/zug/arbeitsblatt-theme-althook.typ`) hält den Wortlaut fest.
4. Golddokument `ab-theme-abgeleitet.typ` mit einem abgeleiteten Theme.

---

## 2. Versionsschema

### 2.1 Nummern

| Paket | heute höchste | Zug 0.4.1 | Bemerkung |
|---|---|---|---|
| kern | – | **0.4.1** | neu; beginnt bei der Zugnummer |
| arbeitsblatt | 0.4.0 | **0.4.1** | |
| klassenarbeit | 0.4.0 | **0.4.1** | |
| aufgaben | 0.3.1 | **0.4.1** | überspringt 0.3.2 bis 0.4.0 |
| klausurboegen | 0.0.5 | **0.4.1** | führt 0.0.4 und 0.0.5 zusammen |
| patterns | 0.0.2 | **0.4.1** | |
| mathematik, physik, informatik | 0.0.2 | **0.4.1** | |
| insert-a-word, energy-sketch | 0.0.3 | **0.4.1** | |
| operatoren, random | 0.0.1 | **0.4.1** | |

Begründung für 0.4.1 statt 0.5.0: Wunsch des Autors, in allen Paketen frei, `neue-version.sh` verlangt eine Nummer über der höchsten, und kein Bestandsdokument bricht, weil jedes exakt pinnt. Der Nachteil (Namensbruch in der Patch-Stelle gegenüber 0.4.0) wird durch die „heißt jetzt"-Meldungen und den Codemod aufgefangen. Er ist mit der Entscheidung vom 2026-11-15 kleiner geworden: Er betrifft nur noch Parameter, Schlüssel, Werte und die wenigen Funktionsnamen aus KONVENTION 9.3, nicht mehr die Bausteinaufrufe (rund 5100 Aufrufe von `aufgabe` und `teilaufgabe` im Bestand bleiben stehen). Die Sprünge bei aufgaben und den kleinen Paketen haben ein Vorbild (0.2.x wurde 2026-06 übersprungen).

### 2.2 Was mit 0.4.0 geschieht

1. Die uncommittete Änderung in `arbeitsblatt/0.4.0/src/themes.typ` (Theme `atlas`, bündige Reiter-Kante) wird committet oder verworfen; das entscheidet der Autor. Wird sie committet, reist sie in den Rohling 0.4.1 mit.
2. Danach werden alle bestehenden Versionsordner der Zugpakete und der Archivpakete in `eingefroren.json` eingetragen (2.5). Fünf davon gelten bis zur Freigabe des Zugs als **Vorlagenordner** und dürfen nur über `bestandskorrektur.sh` geändert werden (Abschnitt 5, „Korrekturen am Bestand während des Umbaus"): `arbeitsblatt/0.4.0`, `klassenarbeit/0.4.0`, `aufgaben/0.3.1`, `klausurboegen/0.0.5`, `patterns/0.0.2`. Alle übrigen sind sofort hart eingefroren. 47 und 11 Dokumente pinnen 0.4.0; sie laufen unverändert weiter.
3. 0.4.0 bekommt keine Doku-Reparatur und keine Namensänderung. In `arbeitsblatt/0.4.0/README.md` und `klassenarbeit/0.4.0/README.md` wird vor dem Einfrieren eine Zeile ergänzt: „Nachfolger ist 0.4.1 mit einheitlichen Namen; Umstellung mit `.github/scripts/umstellen.py`."
4. Die Website zeigt für arbeitsblatt künftig 0.4.1 als neueste Version; 0.3.1, 0.3.2 und 0.4.0 bleiben wie heute ohne gebaute Doku.

### 2.3 Folgeversionen

- Die Zugnummer steigt immer um eine Patch-Stelle: 0.4.2, 0.4.3, …
- **Alle dreizehn Zugpakete bekommen jede Zugnummer**, auch wenn sich in einem davon nichts geändert hat. Dann stimmt die eine Zahl, die der Autor tippt, immer für alle, und Regel 1 aus 1.1 ist ohne Ausnahme erfüllbar. Die frühere Fassung („ein Fachpaket überspringt Nummern, physik 0.4.1 → 0.4.4") ist gestrichen: Sie widersprach Regel 1, weil ein stehengebliebenes physik `kern 0.4.1` importiert hätte, während arbeitsblatt 0.4.2 `kern 0.4.2` importiert; bei insert-a-word wären zusätzlich zwei Versionen von aufgaben zusammengekommen (Abbruch durch die Versionsmarke). Verworfene Alternative: `kern` von Regel 1 ausnehmen; das hätte zwei `regeln.json` im selben Dokument bedeutet und für insert-a-word trotzdem nicht gereicht.
- Der Preis sind dreizehn neue Ordner je Zug (ein unverändertes Paket ist eine Kopie mit gehobenen Pins). `neuer-zug.sh` macht das zu einem Befehl; der CHANGELOG eines unveränderten Pakets bekommt die Zeile „keine Änderung, fährt mit".
- Welche Pakete einen Zug bilden, steht in `.github/buendel.toml` (3e). Diese Datei ist die Wahrheit; Skripte und CI lesen sie.
- Ein Hotfix an einem eingefrorenen Zug ist ein neuer Zug. Es gibt keine Änderung in place.

### 2.4 Regel für künftige Änderungen in 0.4.x

Maßstab: **Ein Dokument, das mit Zug n kompiliert, kompiliert mit Zug n+1, nachdem nur die Importversion gehoben wurde, und ergibt dieselben Seiten.**

| In einem 0.4.x-Zug erlaubt | Erst in 0.5.0 |
|---|---|
| Fehlerkorrektur; ändert sie sichtbar die Ausgabe, steht sie im CHANGELOG unter „Verhalten" | einen öffentlichen Namen umbenennen oder entfernen |
| neue Funktion (ein neuer Baustein nur mit Eintrag in `bausteine-de.txt` und `wortpaare.json`), neuer Parameter, neuer Enum-Wert, neues Theme, neuer Theme-Hook (alles durch das Lint) | Typ oder Bedeutung eines Parameters ändern |
| neuer Eintrag in `fremdnamen.txt` | einen Eintrag aus `fremdnamen.txt` oder einer Exportliste streichen |
| Vorgabe ändern, wenn `regeln.json` sie unter `defaults-changed` nennt und das CHANGELOG sie unter „Verhalten" führt; nur zur Fehlerkorrektur | eine Vorgabe aus Geschmack ändern |
| State-Gestalt ändern mit erhöhtem `@<schema>` | Compat-Einträge und Stubs aus `removed.typ` löschen |
| zusätzliche Compat-Einträge für übersehene alte Namen (Laufzeit: erst im nächsten Zug; Codemod: sofort über `regeln-codemod.json`, 3a) | einen Schalter umdrehen |
| Doku, Tests, Werkzeuge | einen Positionsparameter verschieben |

In keiner Linie erlaubt: einem Baustein einen zweiten Namen geben oder einen englischen Zwilling aus `zwillinge.txt` exportieren (KONVENTION 2.1a, L23, L27).

Durchgesetzt wird das von `sig.py --vergleich <vorzug>` (3d): Zwischen zwei Zügen derselben Minor-Linie sind nur Zugänge erlaubt. Für den ersten Zug 0.4.1 gibt es keinen Vorzug; dort gilt statt des Vergleichs die L24-Prüfung gegen die alten Snapshots (3d).

Fehlt für einen übersehenen alten Namen der Laufzeit-Eintrag, liefert die Prüfung bis zum nächsten Zug nur den Tippfehlervorschlag; der Codemod kennt den Namen trotzdem, sobald er in `regeln-codemod.json` steht.

### 2.5 Einfrieren auch für @schule-eigene Pakete

Heute gilt „eingefroren" nur für Universe-Pakete, und es wird nicht gelebt (aufgaben 0.3.0 wurde neunmal nachträglich geändert). Neu:

- Datei `.github/eingefroren.json`: je Versionsordner der Git-Tree-Hash (`git rev-parse HEAD:<paket>/<version>`), dazu für die fünf Vorlagenordner (2.2) das Feld `"vorlage": true` und eine Liste `"korrekturen"` (Datum, Commit, Begründung). Submodule (`blockst`, `typstage`) stehen nicht darin; für sie liefert der Befehl einen Commit statt eines Trees, und sie werden von Regel 1/2 der Versionsprüfung abgedeckt.
- `versionen-pruefen.py` bekommt Regel 3: Der aktuelle Tree-Hash jedes dort genannten Ordners muss übereinstimmen. Braucht kein Netz. `rev-parse` sieht nur eingecheckte Stände; lokal prüft Regel 3 deshalb zusätzlich `git status --porcelain -- <ordner>` für jeden eingetragenen Ordner (nicht leer = Fehler). So fällt die gewohnte Änderung in place schon vor dem Commit auf.
- `neuer-zug.sh --einfrieren <zug>` trägt alle Ordner des Zugs ein und setzt das Tag `zug-<nummer>`.
- README, Abschnitt „Versionen", bekommt den Satz: „Ab Zug 0.4.1 ist jede Version eines Zugpakets eingefroren, sobald der Zug freigegeben ist."

### 2.6 Archivierte Pakete

Kein Ordner wird gelöscht, weil alte Dokumente und alte Paketversionen sie importieren (messwerttabellen von arbeitsblatt 0.1.7–0.2.2 und 5 Dokumenten, gutachten von 9, flashcards von 1, options von arbeitsblatt ≤ 0.1.9).

| Paket | Maßnahme |
|---|---|
| `options`, `typopst`, `messwerttabellen`, `flashcards`, `gutachten` | Datei `<paket>/ARCHIV.md` (ein Absatz: abgelöst durch …, keine neuen Versionen); Eintrag unter `[archiv]` in `buendel.toml`; alle Ordner eingefroren; Karte in `.github/scripts/index.html` entfernt oder als „archiviert" markiert; von Lint und Snapshot ausgenommen |
| `klausurboegen/0.0.4`, `klassenarbeit/0.3.1` (Seitenast) | bleiben, eingefroren; ihr Funktionsumfang geht in 0.4.1 auf |
| `typstage-geogebra/` (untracked Rest) | lokal löschen |
| `abbozza`, `angela`, `eduki`, `summify`, `typlace`, `schuldocs`, `blockst`, `typstage` | nicht Teil des Zugs, unverändert (Abschnitt 7) |

---

## 3. Werkzeuge

Alle Skripte liegen in `.github/scripts/`, alle Datenlisten in `.github/namen/`, Snapshots in `.github/snapshots/`. Jedes Werkzeug hat Selbsttests unter `tests/werkzeug/`.

### 3a Zentrale Umbenennungstabelle

| | |
|---|---|
| Datei Laufzeit | `kern/<zug>/regeln.json` (die des höchsten Zugs gilt für Laufzeit, Codemod und Lint; mit dem Zug eingefroren) |
| Datei Codemod-Zusätze | `.github/namen/regeln-codemod.json` (nicht eingefroren): `context`-Regeln, alte Namen aus Versionen vor den Vorlagenständen (0.2.x: `luecke(breite:)`, `lueck`, `aufg`, `ta`, `kaestchen`, `schreiblinien`, `tabelle`), Herkunft für Fremdimporte, nachträglich gefundene alte Namen. `umstellen.py` liest beide Dateien; `regeln.py --pruefen` prüft sie zusammen auf Widerspruchsfreiheit |
| Schema | `.github/namen/regeln.schema.json` |
| Prüfer und Generator | `.github/scripts/regeln.py` |
| Eingabe einmalig | die vier `tabelle-*.md` aus dem Entwurf (arbeitsblatt, aufgaben, klassenarbeit mit klausurboegen und patterns, fachpakete mit den sieben Fachpaketen), von Hand übertragen; danach ist die JSON-Datei die Quelle und die Tabellen sind Ausgabe |
| Ausgabe | `regeln.py --pruefen` (Exit 0/1), `regeln.py --markdown > UMSTELLUNG.md` (Umstellungsanleitung je Paket), `regeln.py --fehlertests tests/zug/compat/` (erzeugt je Eintrag eine Testdatei mit `// fehler:`) |

Aufbau (die Einträge sind Beispiele für die Form; maßgeblich für den Inhalt sind die `tabelle-*.md`):

```json
{
  "schema": 1,
  "train": "0.4.1",
  "wordpairs": { "aufgabe": ["task", "tasks"], "kariert": ["squares"], "klausurboegen": ["answer-sheets"], "…": [] },
  "schemas": {
    "options": { "solutions": { "form": "W2", "values": [null, "in-place", "after-task", "at-end", "only"] }, "…": {} },
    "page": {}, "design": {}, "theme": {}
  },
  "packages": {
    "arbeitsblatt": {
      "functions": {
        "arbeitsblatt": {
          "use": ["options", "page", "design"],
          "params": { "title": { "form": "W4", "type": ["str", "content"] } },
          "renamed": { "loesungen": "solutions", "akzent": "accent", "header-font-size": "title-font-size" },
          "values": { "loesungen": { "\"sofort\"": { "solutions": "\"in-place\"" },
                                     "\"seite\"": { "solutions": "\"at-end\"", "solutions-pagebreak": "\"before\"" } } },
          "removed": { "<alter-parameter>": "<Hinweis, was stattdessen gilt>", "<alter-parameter-2>": { "hint": "…", "replace": { "<neu>": "<wert>" } } },
          "context": [ { "when": { "param": "custom-header", "value": "none" }, "do": "delete" } ],
          "defaults-changed": { "title": ["\"\"", "none"] },
          "positional": []
        }
      },
      "functions-renamed": { "qrbox": "qr-box", "lücke": "luecke" },
      "functions-removed": { "<alter-funktionsname>": "<Hinweis, was stattdessen gilt>" }
    }
  },
  "keys": {
    "schule/aufgaben/options@1": { "owner": "aufgaben", "kind": "state", "was": ["options"] },
    "task": { "owner": "aufgaben", "kind": "figure-kind", "was": ["aufgabe"] },
    "schule-aufgaben-reset": { "owner": "aufgaben", "kind": "label", "was": ["_aufgaben-reset"] }
  }
}
```

Zum Beispiel: `header-font-size` (1063 Köpfe in Altversionen) ist nach `tabelle-arbeitsblatt.md` **umbenannt** nach `title-font-size` [prüfen], nicht entfernt; als `removed` bräuchte fast jedes Altdokument Handarbeit. Ein `removed`-Eintrag für einen Parameter kann einen eindeutigen Ersatz tragen (`replace`); dann schreibt der Codemod um, sonst löscht er das Argument und führt es im Bericht (3c).

Zu den Funktionsnamen: Schlüssel unter `functions` sind die Namen der Zielversion, bei Bausteinen also die deutschen (`arbeitsblatt`, `aufgabe`, `kariert`). Ein Feld `alias` gibt es nicht mehr. `functions-renamed` enthält nur noch die Fälle aus KONVENTION 9.3: Umschrift eines Bausteins (`lücke` → `luecke`, `klausurbögen` → `klausurboegen`, `häufigkeitsanalyse` → `haeufigkeitsanalyse`, `lineare_regression` → `lineare-regression` und die fünf weiteren) und alte Namen, die kein Baustein sind und englisch werden (`qrbox` → `qr-box`, `show-loesungen` → `show-solutions`, `reset-aufgaben` → `reset-tasks`, `flex-feld` → `flex-area`, `tasks` → `teilaufgaben`, …). Eine Zeile `aufgabe` → `task` oder `kariert` → `squares` gibt es nicht. Die Regel `lücke` → `luecke` trägt in `regeln-codemod.json` die Bedingung „kein dokumenteigenes `#let luecke` oder `#let lücke`" (32 Aufrufe `#luecke(` im Bestand gehören zu dokumenteigenen Funktionen). `wordpairs` ist die Kopie von `.github/namen/wortpaare.json`, die `kern` zur Laufzeit lesen kann (ein Paket liest nur den eigenen Ordner); `regeln.py --pruefen` hält beide gleich.

Abnahme:

1. `regeln.py --pruefen` ist grün: gültig gegen das Schema; jeder neue Name besteht L1 bis L5; jeder Schlüssel unter `functions` steht in `bausteine-de.txt` oder besteht L2; kein Schlüssel und kein Ziel in `functions-renamed` steht in `zwillinge.txt` (L27); `wordpairs` deckt sich mit `wortpaare.json`; kein alter Name ist zugleich ein neuer Name derselben Funktion; jedes Ziel in `renamed` und `values` steht in `params` oder einem benutzten Schema.
2. Für jedes der zwölf umzubenennenden Pakete gibt es eine Tabelle; jede ihrer Zeilen hat einen Eintrag (Zählvergleich je Paket, von `regeln.py --abgleich <tabelle>` ausgegeben); und jeder öffentliche Name und jeder Parameter der alten Snapshots (3d) kommt in einer Tabelle vor (`regeln.py --deckung .github/snapshots/`). Damit ist das Kriterium auch für die sieben Fachpakete nicht leer erfüllt.
3. Alle Pflichteinträge aus KONVENTION 9.2 sind vorhanden.
4. `kern` liest die Datei mit `json("../regeln.json")`; ein Probedokument kompiliert.

### 3b Compat-Schicht in Typst

| | |
|---|---|
| Dateien | `kern/<zug>/src/check.typ`, `fail.typ`, `rules.typ`, `lib.typ`; je Paket `src/internal.typ` mit den gebundenen `check` und `fail` |
| Eingabe | Paketname, Funktionsname, `arguments` des Aufrufs (deklarierte Werte plus Sink `..deprecated`) |
| Ausgabe | nichts oder Abbruch mit einer der 16 Meldungsarten aus KONVENTION 8.3 (neu darunter: „alter Funktionsname" und „deutscher Bausteinname als Wert"). Das Präfix nennt den deutschen Funktionsnamen: `aufgaben.teilaufgabe`, `arbeitsblatt.arbeitsblatt`, `klassenarbeit.klassenarbeit`, `klausurboegen.klausurboegen` |

Verhalten:

- Ein alter Name wird **nie still angenommen**. Die stille Abbildung aus dem Prototyp (`streng: false`) entfällt.
- Abbrechende Funktionen für alte **Funktionsnamen** (`qrbox`, `lücke`, `non-print-pagebreak`, …) erzeugt jedes Paket aus `rules.packages.<paket>.functions-renamed` und `functions-removed` in einem Block `src/removed.typ`. Typst kann Namen nicht dynamisch binden; der Block ist deshalb geschriebener Code, und `regeln.py --removed <paket>` gibt ihn aus. Das Lint prüft, dass Block und Tabelle übereinstimmen. Englische Zwillinge (`worksheet`, `task`, `squares`, … laut `zwillinge.txt`) bekommen keinen Stub: Es gab sie in keiner veröffentlichten Version; wer sie schreibt, bekommt Typsts „unknown variable". Alte **Parameter** stehen nie in `removed.typ`, sondern in `regeln.json` unter `renamed` oder `removed` der jeweiligen Funktion und werden von `check` gemeldet.
- **Aliase gibt es nicht**, auch nicht für Funktionen. Jeder Baustein wird im Paket des Eigentümers genau einmal definiert (Aufteilung in 1.3); andere Pakete re-exportieren den Namen, sie binden ihn nicht neu. Der frühere Aliasblock (`#let aufgabe = if kern.strict { … } else { task }`), `kern.strict` und `--input streng=1` entfallen ersatzlos.
- Enum-Werte sind ausnahmslos englisch, auch wenn sie einen Baustein meinen (`pattern: "squares"`, `kind: "exam"`, Variante `"answer-sheets"`). Ein deutscher Bausteinname als Wert bekommt die Meldung „ist kein gültiger Wert" mit dem Parameterwort als Vorschlag (``klausurboegen.klausurboegen: `pattern: "kariert"` ist kein gültiger Wert – meintest du `"squares"`?``); `check` schlägt dazu in `rules.wordpairs` nach. Wo der Baustein selbst übergeben werden kann, gibt es kein Enum (`workspace: kariert(4)`, kein `workspace-pattern`); das Muster-Enum steht nur noch in `klausurboegen` bzw. `answer-sheets: (pattern: …)`.
- Dieselbe Prüfung läuft für `set-options`, `variant-overrides`, W6-Dictionaries (`expectations`, `answer-sheets`) und das Theme-Dictionary.

Abnahme:

1. Für jede Meldungsart aus KONVENTION 8.3 gibt es einen Test in `tests/zug/kern-*.typ` mit dem wörtlichen Text, darunter `kern-alter-funktionsname.typ` und `kern-baustein-als-wert.typ`.
2. Für jeden Eintrag unter `renamed`, `values`, `removed`, `functions-renamed`, `functions-removed` gibt es einen erzeugten Fehlertest (3a), und alle sind grün.
3. `rg 'panic\(|assert\(|assert\.(eq|ne)\(' $ZUG_SRC` findet Treffer nur in `kern/0.4.1/src/fail.typ`.
4. Laufzeit: ein Dokument mit 2000 Aufgaben kompiliert höchstens 0,2 s langsamer als ohne Prüfung.

### 3c Codemod für Nutzerdokumente

**Empfehlung: AST auf `typst-syntax`, nicht Regex.** Der Regex-Prototyp (`technik/codemod.py`) findet weder Dictionary-Schlüssel (`#let opts = (loesungen: …)`), noch `set-options((…))`, noch Bezeichner im Mathemodus, und er hat im ersten Anlauf Fließtext umbenannt. Der AST-Prototyp (`technik/astdump`, 40 Zeilen Rust, offline in 5,9 s gebaut) liefert byte-genaue Bereiche und schließt Fließtext, Kommentare, Strings und Raw von selbst aus.

| | |
|---|---|
| Positionsgeber | `.github/scripts/astdump/` (Rust, `typst-syntax`; Ausgabe JSON: Aufrufe mit benannten Argumenten samt Wertart und Literaltext, Spreads, Dictionary-Literale mit Schlüsseln, Bezeichner in Code und Mathe, Importzeilen, `#let`-Bindungen) |
| Regelanwender | `.github/scripts/umstellen.py` (Python, ersetzt von hinten nach vorn) |
| Eingabe | `.typ`-Dateien oder Ordner; `kern/<zug>/regeln.json`; `.github/namen/herkunft.json`; `.github/namen/fremdpakete.json`; `.github/buendel.toml` |
| Ausgabe | ohne Schalter ein Diff; `--schreiben` ändert die Datei und legt `<datei>.typ.vor-0.4.1` ab; `--bericht <json>` listet je Datei alles, was von Hand zu prüfen ist |
| Schalter | `--zug 0.4.1`, `--pakete a,b` (nur Regeln dieser Pakete; für den schrittweisen Umbau), `--pruefen` (kompiliert vorher und nachher und vergleicht nach 4.1; schreibt nichts), `--pins` (hebt nur das Muster `@schule/<zugpaket>:<x.y.z>` in Nicht-Typst-Dateien: `.toml`, `.json`, `.py`, `.md`; für eduki, 10.3) |

Was er tut, in dieser Reihenfolge:

1. **Importversion heben.** Jede Zeile `#import "@schule/<zugpaket>:<alt>"` bekommt die Zugnummer aus `buendel.toml`, alle @schule-Importe eines Dokuments gemeinsam. Untergrenze der Quellversionen: arbeitsblatt ab **0.2.3**, klassenarbeit ab 0.1.2, aufgaben ab 0.1.0. arbeitsblatt 0.2.0 bis 0.2.2 (5 + 108 + 59 Dokumente) importieren `messwerttabellen` mit anderer Signatur (`messwerttabelle(datensatze, max_wert_pro_tabelle, …)` gegen physik `messwerttabelle(..args, amount: …)`, 122 Aufrufe in 54 Dateien); dafür gibt es keine Regel. Diese Dokumente laufen mit ihrem Pin weiter, werden nicht angefasst und im Bericht genannt; `UMSTELLUNG.md` sagt das. Sollen sie doch erfasst werden, sind es `context`-Regeln in `regeln-codemod.json` (ohne neuen Zug möglich).
2. Funktionsnamen, aber nur die aus `functions-renamed` (KONVENTION 9.3): an `#name`, `name(`, `name[`, `name.with`, in Importlisten und im Mathemodus. Das sind die Umschrift-Fälle (`lücke` → `luecke`, `klausurbögen` → `klausurboegen`, `häufigkeitsanalyse` → `haeufigkeitsanalyse`, die sechs Regressionen mit Bindestrich) und die englisch werdenden Helfer, Aktionen und Umwandlungen (`qrbox`, `show-loesungen`, `reset-aufgaben`, `flex-feld`, `bin2dec`, `rand`, …). **Bausteinaufrufe bleiben stehen:** `aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung`, `lsg`, `kariert`, `liniert`, `arbeitsblatt`, `klassenarbeit` und die Fachbausteine werden nicht angefasst; die rund 5100 Ersetzungen von `aufgabe` und `teilaufgabe` entfallen. `lücke` → `luecke` (119 Aufrufe) nur, wenn das Dokument kein eigenes `#let luecke` und kein eigenes `#let lücke` hat; jede solche Stelle steht im Bericht. Einen Schalter `--aliase` gibt es nicht mehr.
3. Benannte Argumente je Funktion (`renamed`), auch in `.with(…)`. Entfernte Parameter (`removed`): mit eindeutigem Ersatz (`replace`) umschreiben, sonst das Argument löschen und im Bericht führen.
4. Literalwerte (`values`), auch wenn aus einem Wert zwei Optionen werden.
5. Kontextregeln (`context`): Argument löschen, Positionsargument zu benanntem machen (`kariert(4, 12)`), `""` löschen, Dictionary auftrennen (`varianten: (name: (…))`).
6. Dictionary-Schlüssel, wenn das Dictionary nachweislich an eine bekannte Funktion geht: Literal direkt im Aufruf, in `set-options((…))`, oder `#let x = (…)` mit genau einer Verwendung als `..x` in einem bekannten Aufruf derselben Datei. Theme: Schlüssel eines Theme-Dictionary-Literals; ist der Wert eines bekannten Hook-Schlüssels ein Lambda-Literal, werden dessen Parameter umbenannt (1.5). `figure.where(kind: "aufgabe"|"teilaufgabe")` wird auf die neuen Kind-Werte gesetzt.
7. Fehlende Fremdimporte einfügen (1.3).
8. Bericht schreiben: Spread mit unbekannter Herkunft, dynamische Werte, `sys.inputs`-Weichen, `import … as`, eigene Wrapper (`#let meine-aufgabe(..a) = aufgabe(..a)`), im Dokument definierte Namen, die einem neuen Export gleichen (`#let luecke = …`, `#let workspace = …`), Theme aus Variable oder Funktion („eigenes Theme von Hand prüfen"), gelöschte `removed`-Argumente. Für **jeden** Wildcard-Import eines anderen Pakets, gleich ob er vor oder nach dem @schule-Import steht, die tatsächlich kollidierenden Namen (aus `mitimporte.json` und `fremdpakete.json`): Steht der Fremdimport davor, überdeckt ein arbeitsblatt-Export (`material`, `workspace`, `info`, `plot`, `draw`, `qty`, `num`, `unit`) still den Fremdnamen; steht er danach, ist es umgekehrt. Die früheren Kandidaten `lines`, `squares`, `blank`, `task`, `exam`, `solution` sind keine Exporte mehr und fallen aus dieser Liste.

Nach dem Lauf kann `typstyle` formatieren; der Codemod selbst ändert kein Layout des Quelltexts.

Abnahme:

1. Fixtures `tests/werkzeug/umstellen/*.typ` mit `*.erwartet.typ` und `*.bericht.json`: alle Fälle aus `technik/t5a.typ` plus je ein Fall je Kontextregel aus KONVENTION 9.2, je ein Fall Theme-Lambda, `figure.where`, `removed` mit und ohne Ersatz, Wildcard-Fremdimport davor und danach, `lücke` mit und ohne dokumenteigenes `#let luecke`, und ein Dokument, das nur Bausteinaufrufe ohne alte Parameter enthält (erwartet: bis auf die Importzeile byte-gleich). Für `--pins` je eine Fixture je Dateityp (toml, json, py, md) mit Ködern (`@preview/…`, Nicht-Zugpaket `@schule/summify`).
2. Idempotent: ein zweiter Lauf ergibt keinen Diff.
3. Kein Byte in Strings, Kommentaren, Raw-Blöcken und Fließtext ändert sich (Test mit Ködern).
4. Alle Dateien unter `tests/gold/alt/` kompilieren nach `umstellen.py` ohne Handarbeit mit dem Zug und bestehen den Goldvergleich (4.1). Einen zweiten Weg (früher: ohne `--aliase` über die Übergangsnamen) gibt es nicht mehr; ein Lauf genügt.
5. Exit-Code 0 ohne offene Punkte, 2 mit Berichtseinträgen, 1 bei Syntaxfehlern.

Hinweis zur Parser-Version: Im Cargo-Cache liegt `typst-syntax 0.14.2`; es liest alle drei Kernpakete fehlerfrei. Sobald Netz da ist, wird auf die zu Typst 0.15 passende Version gehoben und die Fixtures laufen erneut. Meldet der Parser in einer Datei einen Syntaxfehler, fasst der Codemod sie nicht an.

### 3d Signatur-Snapshot und Namens-Lint

| | |
|---|---|
| Skript | `.github/scripts/sig.py` (Signaturen kommen aus `astdump --let`, nicht mehr aus dem Klammerzähler des Prototyps) |
| Eingabe | `<paket>/<version>/src/*.typ`; exportierte Menge per `typst eval 'import "@schule/<paket>:<version>" as m; dictionary(m).keys()'`; `words-en.txt`, `names.txt`, `bausteine-de.txt`, `wortpaare.json`, `zwillinge.txt`, `glossar.json` (mit dem Feld `verboten-als-funktion`), `fremdnamen.txt`, `kollisionen-erlaubt.txt`, `exporte/<paket>.txt`, `intern-vertrag.json` (alle in `.github/namen/`); `regeln.json` |
| Ausgabe | `sig.py --snapshot <paket> <version>` → `.github/snapshots/<paket>-<version>.json` (Funktionen, Parameter, Art, Vorgabe, Typkommentar, Docstring-Parameter, exportierte Namen); `sig.py --lint <zug>` → Zeilen `datei:zeile: name: L<nr> <text>`; `sig.py --vergleich <zug-alt> <zug-neu>` → Zugänge, Abgänge, Änderungen |
| CI | `.github/workflows/namen.yml`: Snapshot neu erzeugen und mit dem eingecheckten vergleichen (Diff = Fehler mit dem Hinweis „Snapshot bewusst erneuern"); `--lint` für den höchsten Zug; `--vergleich` gegen den Vorzug mit der Regel aus 2.4. Nennt `buendel.toml` keinen Vorzug (`[zug].vorzug` fehlt, also beim ersten Zug 0.4.1), entfällt der Vergleich; stattdessen läuft die L24-Prüfung gegen die alten Snapshots. Der Workflow baut `astdump` mit `cargo build --release` (Rust-Toolchain über `dtolnay/rust-toolchain`, Cargo-Cache) |

Lint-Regeln: L1 bis L27 aus KONVENTION 10, dazu K1 (kern zustandslos), K2 (Zugriff auf `internal` nur laut Vertrag), K3 (Exporte aller Zugpakete kollisionsfrei, derselbe Name ist dasselbe Objekt), K4 (jeder Schlüssel-String von `state`, `counter`, `figure(kind:)`, `label` und jedes `<…>`-Label steht in `regeln.json` unter `keys`). L12 läuft mit der erweiterten Prüfmenge aus `mitimporte.json` (1.3). L26 prüft die Docstrings in allen `src`-Dateien eines Pakets, nicht nur im Einstieg.

Die Sprachgrenze bewachen zwei Regeln. **L23 „Bausteinliste"** (früher „Aliasblock") gleicht `bausteine-de.txt` in beide Richtungen mit den Exporten ab: jeder der 30 Namen ist von genau einem Paket definiert; jede andere exportierte Funktion besteht L2, ist also englisch; kein Listenname ist an eine andere exportierte Funktion gebunden (kein Alias); jeder Listenname hat eine Zeile in `wortpaare.json`. **L27 „Sprachtrennung"** verbietet Mischnamen (`show-loesungen`, `aufgabe-number`, `pattern: "kariert"`), Wörter, die zugleich in `words-en.txt` und als Segment in `bausteine-de.txt` stehen, und jeden Export aus `zwillinge.txt`. `removed.typ` ist von L1 und L27 ausgenommen. L2, L3, L12, L14, L17, L18 und L19 laufen in der Fassung der KONVENTION vom 2026-11-15 (L2 nimmt Bausteine als Ganzes aus; L17 nennt `arbeitsblatt`, `arbeitsblatt-einzeln`, `klassenarbeit`; `kollisionen-erlaubt.txt` enthält `task` nicht mehr).

Weil das Lint am Anfang rot ist, gibt es `.github/namen/lint-offen.txt`: die Liste der bekannten Verstöße je Paket. CI schlägt fehl, wenn ein Verstoß dazukommt oder wenn ein behobener noch in der Liste steht. Am Ende ist die Datei leer und wird gelöscht.

Abnahme:

1. Vor dem Umbau: Snapshots der heutigen Stände aller zwölf Pakete sind eingecheckt (`arbeitsblatt-0.4.0.json`, `aufgaben-0.3.1.json`, …) und decken sich mit der Laufzeitliste (aufgaben: 19 öffentliche Namen). Dazu Snapshots der im Bestand stark genutzten Altstände: arbeitsblatt 0.2.4 und 0.3.2, klassenarbeit 0.1.2 und 0.3.1, klausurboegen 0.0.4.
2. `tests/werkzeug/lint/` enthält je Regel eine Datei, die genau diese Regel verletzt, und eine, die sie besteht; für L23 je Teilregel (a) bis (d) ein Paar, für L27 je Teilregel (a) bis (d) ein Paar.
3. Am Ende: `sig.py --lint 0.4.1` meldet nichts; `lint-offen.txt` existiert nicht mehr.
4. L24 ist erfüllt: Jeder Name aus der **Vereinigung** der alten Snapshots (Punkt 1), der im neuen fehlt, steht in `regeln.json` oder `regeln-codemod.json`.

### 3e Bündel-Skript

| | |
|---|---|
| Manifest | `.github/buendel.toml` |
| Skript | `.github/scripts/neuer-zug.sh <nummer> [--erststart] [--einfrieren] [--trocken]`; `neue-version.sh` bleibt als Teilskript und wird repariert |
| Prüfer | `.github/scripts/pins-pruefen.py` (`--ordner [src]` gibt die Ordner des Zugs aus) |
| Bestandskorrektur | `.github/scripts/bestandskorrektur.sh` (Abschnitt 5) |
| iPad | `.github/scripts/ipad-abgleich.sh [--trocken]` |

`buendel.toml`:

```toml
[zug]
nummer = "0.4.1"
# vorzug = "0.4.1"     # fehlt beim ersten Zug; ab 0.4.2 gesetzt
pakete = ["kern", "aufgaben", "arbeitsblatt", "klassenarbeit", "klausurboegen", "patterns",
          "mathematik", "physik", "informatik", "operatoren", "insert-a-word", "random", "energy-sketch"]

[erststart]            # nur für 0.4.1: aus welcher Version der Rohling entsteht
arbeitsblatt = "0.4.0"
klassenarbeit = "0.4.0"
aufgaben = "0.3.1"
klausurboegen = "0.0.5"   # 0.0.4 wird in Schritt 3.2 von Hand eingearbeitet
patterns = "0.0.2"
mathematik = "0.0.2"
physik = "0.0.2"
informatik = "0.0.2"
insert-a-word = "0.0.3"
energy-sketch = "0.0.3"
operatoren = "0.0.1"
random = "0.0.1"
# kern hat keine Vorlage und wird in 3.1 neu angelegt

[abhaengigkeiten]      # von pins-pruefen.py gegen die Importzeilen geprüft
insert-a-word = ["kern", "random", "aufgaben"]
# …

[archiv]
pakete = ["options", "typopst", "messwerttabellen", "flashcards", "gutachten"]
```

Eine Tabelle `[versionen]` je Paket gibt es nicht mehr: Alle Zugpakete tragen `[zug].nummer`.

Reparaturen an `neue-version.sh`:

- kopiert nur von Git verfolgte Dateien (`git ls-files <ordner>`), also keine `aufgaben.typ.orig` und keine `.DS_Store`;
- Schalter `--vorlage <version>`;
- lässt die Pins fremder @schule-Pakete in Ruhe; das macht `neuer-zug.sh`.

**Normalfall `neuer-zug.sh 0.4.2`** (ab dem zweiten Zug):

1. Für jedes der dreizehn Pakete `neue-version.sh <paket> 0.4.2` (Vorlage: der Vorzug).
2. `[zug].nummer` und `[zug].vorzug` in `buendel.toml` fortschreiben.
3. In allen neuen Ordnern jede Stelle `@schule/<zugpaket>:<x.y.z>` auf die Zugnummer setzen: in `.typ`, `README.md`, `.py`, `.sh`, `.toml`, in `docs/`, `template/`, `showcase/`.
4. `tests/zug/` genauso umstellen.
5. `regeln.json` im neuen `kern` bekommt `"train": "0.4.2"`.
6. Je Paket einen Abschnitt `## 0.4.2` in `<paket>/CHANGELOG.md` anlegen (Rubriken: Neu, Behoben, Verhalten; Vorbelegung „keine Änderung, fährt mit").
7. Snapshots des neuen Zugs als Kopie der alten anlegen.
8. `pins-pruefen.py`, `tests/run.sh`, `sig.py --lint` ausführen.

**Erststart `neuer-zug.sh 0.4.1 --erststart`** (einmalig, Phase 3.1): Die Vorlagen kommen aus `[erststart]`, also aus zwölf verschiedenen Nummern. Das Skript kopiert, setzt nur die **eigene** Versionsnummer in `typst.toml` und lässt jeden Pin auf ein anderes @schule-Paket unverändert (der Rohling importiert weiter aufgaben 0.3.1, patterns 0.0.1 usw.). Schritt 8 beschränkt sich auf `tests/run.sh`, weil `pins-pruefen.py` und das Lint am Rohling zwangsläufig rot sind (Wildcard-Importe, drei Rauten). Das Heben der Pins ist ein eigener, getrennt geprüfter Schritt (3.3).

`pins-pruefen.py` prüft: Jede Importzeile eines Zugpakets auf ein Zugpaket nennt die Zugnummer; keine Raute mit zwei Versionen; die tatsächlichen Importe entsprechen `[abhaengigkeiten]`; kein Zyklus; kein `import …: *` auf ein @schule-Paket.

`ipad-abgleich.sh` kopiert die dreizehn Ordner des Zugs nach `iCloud~P0int~Typist/Documents/LocalPackages/schule` (dort liegen 71 vendorierte Versionen); alte Ordner bleiben. `--trocken` listet nur, was kopiert würde. Vor dem ersten Lauf ist zu klären, wie @preview-Abhängigkeiten in Typist ankommen (Download durch die App oder ebenfalls vendoriert); das Ergebnis steht im Kopfkommentar des Skripts (Phase 0).

Abnahme:

1. **In Phase 2** (es gibt noch keinen Zug): Selbsttest an einem Mini-Repo unter `tests/werkzeug/zug/` mit drei Spielpaketen: `--erststart` legt Rohlinge an und lässt fremde Pins stehen; der Normalfall hebt alle Pins; `--einfrieren` schreibt `eingefroren.json`; `pins-pruefen.py` erkennt eine Raute, einen Zyklus und einen Wildcard-Import; `ipad-abgleich.sh --trocken` listet die richtigen Ordner.
2. **In Phase 3.1** im Wegwerf-Klon: `neuer-zug.sh 0.4.1 --erststart` legt zwölf Rohlinge und `buendel.toml` an, `git status` zeigt nur neue Ordner und `buendel.toml`, und die 19 Tests laufen gegen die Rohlinge.
3. **Nach Phase 8** (steht auch in der Definition of Done): `neuer-zug.sh 0.4.2` in einem Wegwerf-Klon ohne weitere Handgriffe; danach sind Tests, Lint, Pin-Prüfung und Doku-Build grün, `git status` zeigt nur neue Ordner, `buendel.toml`, `tests/zug/`, Snapshots und CHANGELOGs, und `grep -rn '@schule/[a-z-]*:0\.4\.1' $ZUG` (Ordner des Zugs 0.4.2) findet nichts.
4. `neuer-zug.sh --einfrieren 0.4.1` trägt alle Ordner in `eingefroren.json` ein; eine **eingecheckte** Probeänderung in einem davon lässt `versionen-pruefen.py` scheitern, eine nicht eingecheckte lässt die lokale Prüfung (`git status --porcelain`) scheitern.

### 3f Doku-Build mit ausgeführten Beispielen

Drei Teile:

1. **`schuldocs` 0.3.1** (eigene Linie, kein Zugpaket): neue Funktion `example(code, scope: (:))`. Sie zeigt den Quelltext und setzt ihn mit `eval(code.text, mode: "markup", scope: scope)`; der Code steht nur noch einmal da. `eval` kann @schule-Pakete importieren [geprüft]. `show-example(rendered:, source:)` bleibt für Fälle, die `eval` nicht kann (Seitenvorlagen wie `#show: arbeitsblatt.with(…)`, relative Dateipfade); diese Fälle deckt Teil 2 ab.
2. **`.github/scripts/doku-beispiele.py`**: zieht aus `docs/content.typ`, `docs/docs.typ`, `README.md`, `template/*.typ`, `showcase/*.typ` und den Docstrings jedes Zugpakets jeden Codeblock, der mit `#import "@schule/` beginnt (und jede Template-Datei als Ganzes), schreibt ihn in ein Temp-Verzeichnis und kompiliert ihn mit dem Paketpfad von `tests/run.sh`. Ein Block mit dem Kommentar `// fehler: <text>` muss mit diesem Text scheitern. Ausgabe: Liste `datei:zeile: ok|FEHLER <meldung>`; Exit 1 bei einem Fehler.
3. **`build.sh --streng <zug>`**: Lässt sich die Doku eines Pakets des genannten Zugs nicht bauen, endet der Lauf mit Exit 1. Für alte Versionen bleibt es bei der Warnung. Die Workflows `build-docs.yml` und `tests.yml` rufen `--streng` mit dem Zug aus `buendel.toml` auf.

Dazu: `arbeitsblatt/0.4.1/docs/docs.typ` entsteht neu (schuldocs 0.3.1); `web.typ` und `manual.typ` (schuldocs 0.1.0, mantys) werden im Zugordner gelöscht.

Abnahme:

1. `doku-beispiele.py` findet in den heutigen Ständen die bekannten Fehler aus dem Inventar (`klausurboegen: (stufe: "I")`, `materialien: "reingequetscht"`, Schnellstart mit `<graph>`, `punkte: "aufgabe"` im Template). Das ist der Test des Werkzeugs.
2. Für den Zug 0.4.1: null Fehler; jedes Zugpaket außer `kern` hat `docs/docs.typ` (für `random` neu anzulegen, heute ohne `docs/`); `build.sh --streng 0.4.1` endet mit 0 und erzeugt für diese zwölf Pakete `index.html` und PDF. Bekannte Abstürze dokumentierter Beispiele (klausurboegen: `students` erwartet CSV-Zeilen) sind in `bekannte-fehler.md` (Abschnitt 7 Nr. 10) als „in 0.4.1 behoben (Grund: Doku muss bauen)" geführt.
3. L26: Jede öffentliche Funktion hat einen Docstring, dessen Parameterliste zur Signatur passt (heute 84 von 138); geprüft in allen `src`-Dateien. Die API-Referenz entsteht über `show-module(read("../src/<datei>.typ"))` je Datei; nach der Aufteilung in `lib`/`arbeitsblatt`/`themes`/`callouts`/`blocks` zählt jede `docs.typ` ihre Module neu auf. Die Anker `{modul}-{funktionsname}` der Website bleiben für die Bausteine gleich und ändern sich nur für die Funktionen aus KONVENTION 9.3 und durch die neue Dateiaufteilung; alte Links von außen gibt es laut Inventar nicht.
4. In `docs/` des Zugs steht kein alter Name mehr: `umstellen.py` über `docs/`, `template/`, `README.md` ergibt keinen Diff.

---

## 4. Testplan

### 4.1 Goldstandard: gleiches Dokument, gleiche Seiten

Vergleichsstufen, von `.github/scripts/gold.py vergleiche <a.pdf> <b.pdf>` ausgegeben:

| Stufe | Vergleich | Mittel |
|---|---|---|
| S1 | Seitenzahl und Seitenformat | `pdfinfo` |
| S2 | Text je Seite, Leerraum zusammengezogen | `pdftotext -layout` |
| S3 | Position jedes Worts, Toleranz 0,5 pt; die Zeilen `CreationDate`/`ModDate` der Ausgabe werden ausgeblendet (im Probelauf waren sonst alle 16 Dokumente „verschieden", ohne sie alle gleich) | `pdftotext -bbox` |
| S4 | Bild je Seite, nur für Theme- und Klausurbogen-Dokumente, **nur lokal** | `typst compile --format png --ppi 72`, `compare -metric AE -fuzz 2%` (ImageMagick); Schwelle: höchstens 0,1 % abweichende Pixel je Seite |

„Gleich" heißt in diesem Plan überall **S1 bis S3 ohne Abweichung**; S4 zusätzlich, wo angegeben. Wo nur S1 und S2 verlangt sind, steht es ausdrücklich da.

**Keine eingecheckte Referenz, gleiche Umgebung auf beiden Seiten.** Die Pakete setzen Systemschriften (`"Myriad Pro"`, `"Futura"`, `"SF Mono"`, über die Themes weitere); CI läuft auf `ubuntu-latest` ohne diese Schriften und pinnt heute Typst 0.15.0, lokal läuft 0.15.1. Eine auf dem Mac erzeugte, eingecheckte Referenz wiche in CI schon ab, bevor ein Name geändert ist. Die heutigen 19 Tests merken das nicht, weil sie nur Text prüfen. Deshalb kompiliert `gold.py` in jedem Lauf **beide Seiten in derselben Umgebung** und vergleicht sie direkt: links das Golddokument mit den alten Pins (die alten Ordner sind eingefroren, die linke Seite ist also immer verfügbar), rechts die Pin- oder Codemod-Fassung. In CI greift auf beiden Seiten dieselbe Ersatzschrift; der Vergleich bleibt gültig, prüft dort aber S1 bis S3 mit Ersatzschrift. S4 und der Lauf mit den echten Schriften geschehen lokal vor jedem Phasenende. `tests.yml` wird auf Typst 0.15.1 gehoben und bekommt `poppler-utils`; ImageMagick braucht CI nicht.

**Golddokumente** (synthetisch, im Repo, laufen in CI): `tests/gold/alt/*.typ`, rund 30 Dateien mit den alten Namen und festen Pins auf die eingefrorenen Stände (arbeitsblatt 0.4.0, klassenarbeit 0.4.0, aufgaben 0.3.1, klausurboegen 0.0.5 und 0.0.4, patterns 0.0.2, Fachpakete). Sie entstehen **vor** dem Umbau und decken ab, was die 19 heutigen Tests nicht abdecken:

| Datei (Auswahl) | deckt ab |
|---|---|
| `ab-loesungen-<modus>.typ` (sechs Dateien) | `loesungen`: `"sofort"`, `"folgend"`, `"seite"`, `"seiten"`, `"nur"`, `"reinquetschen"` |
| `ab-materialien-<modus>.typ` | alle `materialien`-Modi |
| `ab-punkte-<modus>.typ` | `"aufgaben"`, `"teilaufgaben"`, `"alle"`, `"keine-summe"`, `(anzeige:, position: "rand")` |
| `ab-theme-<name>.typ` (acht Dateien, S4) | jedes Theme mit Aufgabe, Teilaufgabe, Lösung, Material, drei Kästen |
| `ab-theme-abgeleitet.typ` (S4) | eigenes Theme als Funktion mit überschriebenem Hook (1.5) |
| `ab-verweise.typ` | Verweise auf Aufgabe, Teilaufgabe, Material; `figure.where(kind: …)` (1.4) |
| `ab-kasten.typ` | alle 15 Kästen mit `title`, `accent-color`, `headless` |
| `ab-elemente.typ` | `minipage`, `lücke`, `lsg`, `teilaufgaben`, `qrbox`, `icon-link`, `workspace`, `print-pagebreak`, `non-print-pagebreak` |
| `ab-zweifach.typ`, `ab-landscape.typ`, `ab-custom-header.typ` | Seitenlayout |
| `ab-meta.typ` | `<ab-meta>`: Vergleich per `typst eval 'query(<ab-meta>)'` statt PDF |
| `ab-buendel/` | Bundle-Export, siehe 4.4 |
| `ka-voll.typ`, `ka-erwartungen.typ`, `ka-bewertung.typ` | Kopf, Infotabelle, Erwartungshorizont, Bewertungstabelle |
| `ka-klausurboegen-kariert.typ`, `-liniert.typ`, `-bogen.typ` (S4) | `variante: "klausurboegen"`, Ast 0.0.5 und Ast 0.0.4 |
| `fach-mathe.typ`, `fach-physik.typ`, `fach-informatik.typ`, `fach-operatoren.typ`, `fach-iaword.typ`, `fach-energie.typ` | je Fachpaket die öffentlichen Funktionen mit festem `seed` |
| `patterns.typ` | `kariert`, `liniert` mit `rows`, `height`, `items`, `annotations`, `1fr` |

Ablauf `gold.py` (jeder Schritt kompiliert links die unveränderte Datei aus `tests/gold/alt/` mit den alten Pins, rechts die genannte Fassung, im selben Lauf):

1. `gold.py selbst`: links gegen links. Erwartung: gleich. Das ist der Test des Werkzeugs und der Nachweis, dass die Umgebung deterministisch ist (Phase 1).
2. `gold.py pin`: rechts dieselbe Datei, nur die Pins in einer Temp-Kopie auf den Rohling gehoben. Erwartung: gleich. (Stufe G0, Phase 3.)
3. `gold.py umbau [--pakete …]`: rechts `umstellen.py --zug 0.4.1 [--pakete …]` auf eine Temp-Kopie, kompiliert mit dem Zug. Erwartung: gleich. (Stufe G1, Phasen 4 bis 7.) Den früheren zweiten Lauf `--ohne-aliase` gibt es nicht mehr, weil es keine Übergangsnamen gibt.
4. Abweichungen sind nur erlaubt, wenn sie in `tests/gold/abweichungen.toml` stehen, mit Datei, Stufe und Begründung, und im CHANGELOG unter „Verhalten". Jeder Eintrag verweist auf eine Zeile in `bekannte-fehler.md` mit der Entscheidung „in 0.4.1 behoben" (Abschnitt 7 Nr. 10) oder auf R1.

### 4.2 Korpus-Test mit echten Bestandsdokumenten

Echte Dokumente enthalten Schülerdaten und liegen außerhalb des Repos. Der Korpus-Test läuft deshalb nur lokal, auf Kopien, und nichts davon wird committet.

| | |
|---|---|
| Skript | `.github/scripts/korpus.sh` |
| Quelle | `~/Documents/klassenarchiv-quellen` (935 Dateien, lokal vollständig) und `~/Documents/GitHub/eduki` (286); Cloud-Platzhalter werden nie gelesen |
| Arbeitskopie | `~/Library/Caches/schule-korpus/<datum>/` (ganze Ordner, damit Bilder und `#include` mitkommen) |
| Auswahl | **Klasse A**: alle Dokumente auf arbeitsblatt 0.4.0 (47), klassenarbeit 0.4.0 (11), arbeitsblatt 0.3.2 (313), 0.3.0/0.3.1 (23), klassenarbeit 0.3.x (11). **Klasse B**: **alle** lokal vorhandenen Dokumente ab der Untergrenze des Codemods (3c), also arbeitsblatt 0.2.3 (17) und 0.2.4 (339), alle klassenarbeit 0.1.2 (29) und die übrigen klassenarbeit-Stände ab 0.1.2. Keine Stichprobe: Der Lauf ist automatisch, eine Stichprobe spart nichts und überlässt alte Namen dem Zufall. Dokumente auf arbeitsblatt 0.2.0 bis 0.2.2 (172) liegen unter der Untergrenze und werden nur gezählt |
| Ablauf je Dokument | (1) Original mit altem Pin kompilieren; scheitert das, zählt es als „vorher defekt" und fällt aus der Wertung. (2) `umstellen.py --schreiben --bericht`. (3) mit 0.4.1 kompilieren. (4) `gold.py vergleiche`. |
| Ausgabe | `bericht.html` und `bericht.json` in der Arbeitskopie: je Dokument Status `gleich`, `Text gleich, Lage verschieden`, `Seitenzahl verschieden`, `Fehler` (mit Meldung), `Handarbeit` (Berichtseinträge des Codemods), dazu die Spalten „Kollisionen" (Namen aus Wildcard-Fremdimporten, 3c) und „Theme" (String, Literal, sonstiges) |

**Basislauf (Phase 1.5).** Ob eine feste Schwelle erreichbar ist, wurde nie gemessen, und für Dokumente auf 0.3.x zählten Unterschiede 0.3.2 → 0.4.0 (auto-Schriftvorgaben, Theme-Nebenwirkungen, klassenarbeit 0.3.2 hängt an arbeitsblatt 0.3.0, gedrehte `korrekturrand`-Vorgabe) sonst als Fehler des Umbaus. Deshalb misst der Basislauf vor dem Umbau: jedes Klasse-A-Dokument mit seinem Original-Pin gegen dasselbe Dokument mit nur auf 0.4.0 (bzw. die heutigen Vorlagenstände) gehobenem Pin. Das Ergebnis je Stufe (S1, S2, S3) und je Gruppe steht in `basislauf.json` neben dem Bericht.

Abnahme:

- Klasse A, Dokumente auf 0.4.0 (58): 100 % kompilieren nach Codemod plus den im Bericht genannten Handgriffen; 100 % gleich (S1 bis S3); jede Abweichung ist einer Zeile in `abweichungen.toml` zugeordnet.
- Klasse A, Dokumente auf 0.3.x (347): 100 % kompilieren; auf jeder Stufe **nicht schlechter als der Basislauf** (dieselben Dokumente gleich, die im Basislauf gleich waren). Ein Dokument, das schon im Basislauf abwich, zählt nicht gegen den Umbau.
- Klasse B: mindestens 90 % kompilieren ohne Handarbeit; jeder Fehler ist eine „heißt jetzt"- oder „gibt es nicht mehr"-Meldung, kein nackter Typst-Fehler aus dem Paketinneren (einzige geführte Ausnahme: Hook-Parameter eigener Themes, 1.5). Seitengleichheit wird berichtet, ist aber kein Kriterium (zwischen 0.2.4 und 0.4.x liegen echte Layoutänderungen).
- Jede Fehlermeldung, die im Korpus öfter als zweimal auftritt und keine Abhilfe nennt, führt zu einem neuen Eintrag: vor der Freigabe in `regeln.json`, danach in `regeln-codemod.json` (Laufzeit-Eintrag im nächsten Zug).

### 4.3 Tests je Paket

Alle Tests des Zugs liegen in `tests/zug/` und pinnen die Zugnummer aus `buendel.toml` (von `neuer-zug.sh` nachgezogen). `tests/run.sh` durchsucht heute nur `tests/*.typ`; künftig läuft es über eine **feste Ordnerliste** (`tests/zug`, `tests/zug/compat`, `tests/alt`), nicht rekursiv, sonst kompilierte es auch die Codemod- und Lint-Fixtures unter `tests/werkzeug` (Dateien mit alten Namen und absichtlichen Verstößen) und `tests/gold/alt`. Neu: `// fehler:` wie bisher, `// seiten: <n>` und `// eingabe: <schlüssel>=<wert>` (etwa `vorschau=alle`). Die Werkzeugtests haben einen eigenen Aufruf (`bash tests/werkzeug/run.sh`). Die 19 heutigen Tests wandern nach `tests/alt/` und laufen weiter gegen die eingefrorenen Versionen (Schutz gegen Typst-Updates).

| Paket | Tests in `tests/zug/` |
|---|---|
| kern | je Meldungsart ein Test; Levenshtein-Grenzen; Umlaut-Faltung; alter Funktionsname; deutscher Bausteinname als Wert mit englischem Vorschlag; `rules` lädt |
| random | gleiche Zahlenfolge wie 0.0.1 bei gleichem `seed` (Goldvergleich); `shuffle`; alte Namen `rand`, `randint` melden „heißt jetzt" |
| patterns | `kariert`, `liniert` mit `rows` als int und als `fr`; `height` und `rows` zugleich ist ein Fehler; `kariert(4, 12)` meldet die Abhilfe `kariert(4, columns: 12)`; `flex-area`; `flex-feld` meldet „heißt jetzt" |
| energy-sketch, operatoren, insert-a-word | öffentliche Funktionen; `word-bank`, `labeled` als gewendete Schalter; insert-a-word folgt `has-solutions()` |
| physik, informatik, mathematik | je öffentlicher Funktion ein Aufruf mit Textprüfung; Regressionen mit festen Daten; `bin-to-dec` und Geschwister; `graphen` mit `domain`, `step`; die alten Schreibweisen `häufigkeitsanalyse` und `lineare_regression` melden „heißt jetzt"; mathematik importiert aufgaben nicht mehr (`pins-pruefen.py`) |
| aufgaben | das Options-Schema vollständig: jeder Wert jeder Option, jede unzulässige Kombination; `set-options` mit Tippfehler; `aufgabe[Titel][Rumpf]` und `erwartung(points: 2)` als Fehler; `show-loesungen`, `reset-aufgaben` melden „heißt jetzt"; `show-solutions(select:)`, `show-expectations`, `show-points-table`; `get-points`; Verweise und Labels |
| arbeitsblatt | Kopfparameter; der eigene Stub `tasks` meldet „heißt jetzt `teilaufgaben`"; Varianten und Bundle (4.4); Themes (jeder Schlüssel, unbekannter Schlüssel, alter Schlüssel, eigenes Theme mit altem Hook: dokumentierte Meldung); Kästen; exportierte Namensmenge = `exporte/arbeitsblatt.txt`; gemischte Züge lösen die Versionsmarken-Meldung aus; ein Paket vor 0.4.1 löst die Altprüfung aus (`arbeitsblatt-altpaket.typ`, 1.4); Verweise auf Aufgabe, Teilaufgabe, Material |
| klassenarbeit | alle Parameter aus A.2; Fehlerpräfix ist `klassenarbeit.klassenarbeit`, nicht `arbeitsblatt.…`; `expectations` und `answer-sheets` als W6; zwei Klassenarbeiten in einer Datei; Seitenzählung |
| klausurboegen | `pattern`, `grid-size`, `line-height`, `correction-margin` und Geschwister, `overprint`, `continuation`, `stage`; `pattern: "kariert"` meldet den englischen Vorschlag `"squares"`; Durchreichung aus `klassenarbeit`; `klausurbögen` meldet „heißt jetzt" |
| Bausteine | genau eine Datei `tests/zug/bausteine.typ` ruft jeden der 30 Namen aus `bausteine-de.txt` einmal auf (importiert dazu klassenarbeit, klausurboegen und die Fachpakete) und prüft `arbeitsblatt.aufgabe == aufgaben.aufgabe`; `tests/zug/zwilling.typ` schreibt `#task[…]` und erwartet Typsts „unknown variable". Den früheren Test `aliase.typ` gibt es nicht |
| Compat | `tests/zug/compat/*.typ`, erzeugt aus `regeln.json` (3a) |

### 4.4 Bundle-Export

`tests/gold/alt/ab-buendel/` und `tests/zug/buendel/`: ein Arbeitsblatt und eine Klassenarbeit, kompiliert mit `--format bundle --features bundle`. Geprüft wird die Dateiliste des Ausgabeordners (`<dateiname>-druck.pdf`, `-digital.pdf`, `-loesung.pdf`, `-zweifach.pdf`; bei der Klassenarbeit die heutigen Namen einschließlich „ - Lösung.pdf" und „ - Klausurbögen.pdf") und je Datei S1 bis S3 gegen die im selben Lauf erzeugte Fassung mit den alten Pins. Dazu ein Lauf mit `--input vorschau=alle` als gewöhnliches PDF.

### 4.5 Was vor dem Umbau fertig sein muss

In dieser Reihenfolge, alles gegen die alten Stände:

1. Snapshots der heutigen Signaturen und Exportmengen (3d, Abnahme 1), dazu `herkunft.json`.
2. `tests/gold/alt/` und `gold.py selbst` (links gegen links, lokal und in CI gleich).
3. Verhaltensnachweise für jede **[prüfen]**-Marke der KONVENTION als Golddokument: Wirkung von `loesungen: "seiten"` ohne `at-end`; `teilaufgabe-numbering: "1."` gegenüber `"1.1"`; `loesungen-only: true` bei `print-pagebreak`; `vordruck: "werte"` in klausurboegen 0.0.4. Das Ergebnis geht als Korrektur in `regeln.json`.
4. Korpus-Lauf Schritt 1 (Originale kompilieren), damit „vorher defekt" feststeht; Basislauf (4.2); Zählung der `theme`-Köpfe, die kein String sind.
5. `doku-beispiele.py` gegen die heutigen Stände (zeigt die bekannten Fehler).
6. `bekannte-fehler.md`: jede Zeile der Fehlerlisten der Inventare mit Entscheidung (Abschnitt 7 Nr. 10).

---

## 5. Arbeitspakete

**Wo gearbeitet wird.** Phase 0 und Phase 1 geschehen auf `main` und werden dort eingecheckt: Sie fügen nur Werkzeuge, Tests und `eingefroren.json` hinzu und ändern keinen Paketquelltext. Damit gilt die Einfrier-Prüfung auf `main`, bevor der Umbau beginnt. Erst danach wird der Zweig `linie-0.4` abgezweigt (Phasen 2 bis 9). Das Repo ist zugleich der lebende Paketpfad; alte Versionsordner werden auf dem Zweig nicht angefasst, die täglichen Dokumente des Autors laufen deshalb auch bei ausgechecktem Zweig weiter. Bis zur Freigabe pinnt kein echtes Dokument 0.4.1.

**Korrekturen am Bestand während des Umbaus.** Die Vorlagenordner wurden bisher laufend in place geändert (aufgaben/0.3.0 neun Commits; seit Oktober zehn Commits in arbeitsblatt/0.4.0, aufgaben/0.3.1, klassenarbeit/0.4.0, klausurboegen/0.0.5), 0.4.0 trägt 58 Unterrichtsdokumente, und die nächste freie Nummer 0.4.1 ist bis zur Freigabe vom Umbau belegt. Ein Fehler in einer Klassenarbeit muss in dieser Zeit behebbar sein, ohne dass er im Rohling fehlt. Dafür gibt es genau einen Weg:

1. `bestandskorrektur.sh <paket>/<version> "<Begründung>"` ist nur für die fünf Vorlagenordner aus 2.2 erlaubt. Die Änderung wird auf `main` gemacht und eingecheckt.
2. Das Skript erneuert den Tree-Hash in `eingefroren.json` und trägt Datum, Commit und Begründung unter `korrekturen` ein. Ohne diesen Eintrag schlägt die Versionsprüfung fehl.
3. Es überträgt denselben Commit auf `linie-0.4` in den Ordner 0.4.1 (`git format-patch`, Pfad umgeschrieben; nach dem Strukturumbau von Hand, das Skript öffnet dann nur den Patch) und trägt die Korrektur in `linie-0.4:UMBAU-NOTIZEN.md` ein.
4. Es ruft `gold.py pin` bzw. `gold.py umbau` auf. Weil es keine eingecheckte Referenz gibt (4.1), ist die linke Seite automatisch der korrigierte Bestand.
5. Alles, was keine dringende Korrektur ist, wird nicht in place geändert, sondern in `UMBAU-NOTIZEN.md` für 0.4.1 notiert.

Mit `neuer-zug.sh --einfrieren 0.4.1` (Phase 9) verlieren die fünf Ordner das Feld `vorlage` und sind hart eingefroren.

**Takt.** Jeder Umbenennungsschritt (Phasen 4 bis 7) folgt demselben Ablauf:

```
1  Regeln des Pakets in regeln.json eintragen, regeln.py --pruefen
2  Quelltext des Pakets umbauen (lib.typ, internal.typ, Namen, check, Docstrings)
3  umstellen.py --pakete <paket> über: abhängige Pakete des Zugs, tests/zug, docs, template
4  gold.py umbau --pakete <bisher fertige>   → alle Golddokumente gleich
5  sig.py --snapshot, sig.py --lint          → lint-offen.txt schrumpft
6  tests/run.sh                              → grün
7  ein Commit je Paket
```

Was ein Umbenennungsschritt seit der Entscheidung vom 2026-11-15 umfasst: Parameter, Dictionary-Schlüssel, Enum-Werte, Aktionen, Abfragen und Helfer. Die Bausteinfunktionen selbst behalten ihren deutschen Namen; umbenannt werden nur die Schreibweisen mit Umlaut oder Unterstrich (`lücke`, `klausurbögen`, `häufigkeitsanalyse`, sechs Regressionen).

Regel zu Schritt 4: **Kein Zwischenstand darf ein Golddokument rot lassen.** Der Codemod kann nur Statisches umstellen. Reicht ein Paket Werte dynamisch an ein anderes weiter (Optionen von arbeitsblatt an aufgaben, das Nutzer-Dictionary von klassenarbeit an klausurboegen, Theme-Hooks), werden beide Seiten in **einem** Commit mit **einem** Goldlauf umgestellt. Das betrifft drei Stellen: 6.1 (Optionsschnitt), 7.1/7.2 (klausurboegen mit `klassenarbeit`), 5.5/6.3 (Theme-Hooks). Eine vorläufige Übersetzungsschicht alt → neu gibt es nicht.

**Abbruchkriterium jeder Phase:** Der Zweig bleibt lauffähig (`gold.py` auf dem zuletzt erreichten Stand gleich, `tests/run.sh` grün), `main` ist unberührt. Gelingt das am Phasenende nicht, werden die Commits der Phase zurückgenommen.

### Phase 0: Entscheiden und Aufräumen (M) – auf `main`

| | |
|---|---|
| Ziel | sauberer Ausgangspunkt, keine offene Grundsatzfrage |
| Schritte | (1) Entscheidungen aus KONVENTION 11: Zwei der früheren sechs sind am 2026-11-15 getroffen und eingearbeitet (frühere Nr. 1: deutsche Bausteine auf Dauer, kein englischer Zwilling, kein Aliasblock; frühere Nr. 3: `task` oder `exercise` ist damit erledigt, ebenso die Kollision mit gentle-clues). Zu treffen und einzutragen bleiben die vier neu nummerierten: 11.1 Versionsnummer, 11.2 durchgereichte Fremdnamen, 11.3 Härte gegen zweite Wege, 11.4 klausurboegen-Ast 0.0.4. (2) Zusätzlich entscheiden: Kernpaket `kern` (1.2), Familien-Re-Export samt zap-Bauteilen (1.3), Zugregel „alle dreizehn" (2.3), Umfang (Sollbruchstelle, unten), Untergrenze des Codemods (3c). (3) `arbeitsblatt/0.4.0/src/themes.typ` committen oder verwerfen. (4) `aufgaben/0.3.1/aufgaben.typ.orig` und `typstage-geogebra/` löschen. (5) README-Zeile „Nachfolger 0.4.1" in die beiden 0.4.0-READMEs. (6) Typst-Version der iPad-App Typist feststellen und klären, wie @preview-Pakete dort ankommen; Ergebnis in 1.1 Regel 4 und im Kopf von `ipad-abgleich.sh` eintragen. (7) eduki-Repo sichten: Was ist „der Build", und verdrahtet dessen Python-Skript Bundle-Dateinamen, `<ab-meta>` oder `--input`-Werte (alte Optionswerte wie `loesungen`)? Ergebnis in R4. |
| Dateien | `KONVENTION.md` (Entwurf), `arbeitsblatt/0.4.0/src/themes.typ`, zwei READMEs |
| Abhängig von | – |
| Abnahme | `git status` sauber; `bash tests/run.sh` 19 von 19; Entscheidungen schriftlich (die zwei getroffenen stehen im Kasten am Anfang der KONVENTION); Typist-Version bekannt |

### Phase 1: Sicherheitsnetz (8,5 bis 13,5 Tage) – auf `main`

| | |
|---|---|
| Ziel | Jede spätere Abweichung fällt auf; der Bestand ist eingefroren, bevor der Zweig entsteht |
| Schritte | 1.1 `astdump` ins Repo, um `--let` und JSON-Ausgabe erweitert (M). 1.2 `sig.py --snapshot` für alle heutigen Stände und die Altstände aus 3d, `herkunft.json` (S). 1.3 `gold.py` (Vergleich im selben Lauf, 4.1) und `tests/gold/alt/` (L). 1.4 Verhaltensnachweise zu den [prüfen]-Marken (M). 1.5 `korpus.sh`, Schritt 1 des Korpus-Laufs, Basislauf, Zählung der Theme-Köpfe (M). 1.6 `doku-beispiele.py`; `bekannte-fehler.md` aus den Fehlerlisten der Inventare (S). 1.7 `eingefroren.json` und Regel 3 in `versionen-pruefen.py` samt lokaler `git status`-Prüfung; alle bestehenden Ordner der Zugpakete und der Archivpakete eintragen, fünf als Vorlage; `bestandskorrektur.sh` (S). 1.8 `tests/run.sh` auf feste Ordnerliste, `// seiten:`, `// eingabe:`; heutige Tests nach `tests/alt/`; `tests.yml` auf Typst 0.15.1 und mit `poppler-utils` (S). |
| Dateien | `.github/scripts/{astdump/,sig.py,gold.py,korpus.sh,doku-beispiele.py,versionen-pruefen.py,bestandskorrektur.sh}`, `.github/snapshots/`, `.github/namen/{herkunft.json,bekannte-fehler.md}`, `.github/eingefroren.json`, `.github/workflows/tests.yml`, `tests/` |
| Abhängig von | Phase 0 |
| Parallel | 1.1/1.2, 1.3/1.4, 1.5, 1.6, 1.7/1.8 sind vier unabhängige Stränge |
| Abnahme | 4.5 Punkte 1 bis 6 erfüllt; `gold.py selbst` gleich, lokal und in CI; CI auf `main` grün mit den neuen Schritten; eine eingecheckte Probeänderung in `arbeitsblatt/0.4.0` ohne `bestandskorrektur.sh` lässt die Versionsprüfung scheitern, eine nicht eingecheckte die lokale Prüfung. **Danach wird `linie-0.4` abgezweigt.** |

### Phase 2: Werkzeuge und Kernpaket (7,5 bis 12,5 Tage)

| | |
|---|---|
| Ziel | Tabelle, Prüfung, Codemod, Lint und Bündel-Skript stehen, bevor ein Name geändert wird |
| Schritte | 2.0 Deckungsabgleich: jeder öffentliche Name und Parameter der alten Snapshots kommt in einer der vier `tabelle-*.md` vor; Lücken in der jeweiligen Tabelle nachtragen; Widerspruch zwischen `tabelle-fachpakete.md` Abschnitt 9 und `tabelle-arbeitsblatt.md` 4.2 bereinigen (S). 2.1 `regeln.schema.json`, `regeln.py`; die vier Tabellen (in der Fassung mit deutschen Bausteinen) nach `regeln.json` und `regeln-codemod.json` übertragen, zunächst im Entwurfsordner (M). 2.2 Wortlisten nach `.github/namen/`: `words-en.txt` (ohne die 21 Wörter der entfallenen englischen Fachfunktionsnamen), `names.txt`, `bausteine-de.txt`, `wortpaare.json`, `zwillinge.txt`, `glossar.json` (mit `verboten-als-funktion`), `fremdnamen.txt`, `kollisionen-erlaubt.txt` (ohne `task`), `mitimporte.json` (S). 2.3 `sig.py --lint` mit L1 bis L27 (darunter L23 Bausteinliste, L27 Sprachtrennung), K1 bis K4; `lint-offen.txt` als Anfangsbestand (M). 2.4 `umstellen.py` mit Fixtures, einschließlich `--pins`; ohne Schalter `--aliase`, Funktionsumbenennung nur für `functions-renamed` (L). 2.5 `buendel.toml`, `neuer-zug.sh` (Normalfall und `--erststart`), `pins-pruefen.py`, `ipad-abgleich.sh`, Reparatur von `neue-version.sh` (M). 2.6 `.github/workflows/namen.yml` mit Rust-Schritt (S). |
| Dateien | `.github/scripts/`, `.github/namen/`, `.github/buendel.toml`, `.github/workflows/namen.yml`, `tests/werkzeug/` |
| Abhängig von | Phase 1 (astdump, Snapshots); 2.1 braucht 2.0 |
| Parallel | 2.1/2.2, 2.3, 2.4, 2.5 |
| Abnahme | Abnahmekriterien 3a, 3c (Punkte 1 bis 3, 5), 3d (Punkte 1, 2), 3e (Punkt 1: Selbsttest am Mini-Repo). Die volle Abnahme „0.4.2 aus 0.4.1" steht nur in Abschnitt 8. |

### Phase 3: Rohlinge und Strukturumbau mit alten Namen (7,5 bis 12,5 Tage)

| | |
|---|---|
| Ziel | Der Zug 0.4.1 existiert, hat die neue Struktur und die neuen Abhängigkeiten, aber noch jeden alten Namen. Goldstufe G0. |
| Schritte | 3.1 `neuer-zug.sh 0.4.1 --erststart`: zwölf Rohlinge mit unveränderten Fremdpins; `kern/0.4.1` neu anlegen (`typst.toml`, `src/`, `regeln.json` aus 2.1, Tests aus 3b); `gold.py pin` (nur eigene Nummer gehoben) gleich (M). 3.2 klausurboegen: 0.0.4 und 0.0.5 in `klausurboegen/0.4.1` zusammenführen, noch mit alten Namen (`bogen-seiten`, `klausurbogen-arbeit`, `vordruck`, `namen`, `muster`, `linienabstand`, `korrekturrand`); klassenarbeit 0.4.1 bekommt `bogen:` aus 0.3.1 zurück (M). Das ist gegenüber 0.4.0 wiedergewonnener Funktionsumfang und hängt an der Entscheidung KONVENTION 11.4, früher 11.6 (Abschnitt 7 Nr. 1). 3.3 Pins heben, jede Hebung mit eigenem `gold.py pin`-Lauf: alle Zugpakete untereinander auf 0.4.1; mathematik ohne eigenes `teilaufgaben`/`tasks` und ohne aufgaben-Import; klausurboegen → patterns des Zugs; arbeitsblatt → energy-sketch des Zugs (S). 3.4 Je Paket `src/lib.typ` mit namentlichen Importen und Exporten und `src/internal.typ`; `entrypoint` und `compiler` in `typst.toml`. Die Exportliste enthält in diesem Schritt noch **alle** Namen, die das Paket heute weiterreicht und die im Korpus oder in den Golddokumenten vorkommen (aus `herkunft.json` und einer Zählung über den Korpus); der Rest fällt weg (L). 3.5 States, Counter, Labels und Figure-Kinds auf die neuen Schlüssel (1.4), Zugriff zwischen Paketen nur über `internal` (1.5); `print-state` entfällt; rohe `state("options", (:))` entfallen (M). 3.6 Versionsmarke und Altprüfung (S). 3.7 iPad-Probelauf mit den Rohlingen: `ipad-abgleich.sh`, ein Arbeitsblatt und eine Klassenarbeit in Typist kompilieren (S). |
| Dateien | alle `<zugpaket>/0.4.1/`, `kern/0.4.1/`, `.github/buendel.toml` |
| Abhängig von | Phasen 1, 2 |
| Parallel | 3.2 neben 3.3; 3.4 je Paket parallel; 3.5 nach 3.4 |
| Abnahme | 3e Punkt 2; `gold.py pin` gleich für alle Golddokumente (Abweichungen nur aus 3.2 und 3.3, einzeln begründet); Korpus Klasse A mit nur gehobenem Pin: nicht schlechter als der Basislauf (4.2); `pins-pruefen.py` grün; `rg 'import "@[^"]*": \*' $ZUG_SRC` ohne Treffer; `rg '_state_\|_counter_' $ZUG` ohne Treffer; `rg '(state\|counter)\(\s*"' $ZUG_SRC` trifft nur `internal.typ`; L19, L20, K4 aus `lint-offen.txt` verschwunden; iPad-Probelauf bestanden |

Dieser Schritt trennt die zwei Fehlerquellen: Bricht etwas in Phase 3, liegt es an Struktur, Pins oder Exporten. Bricht etwas ab Phase 4, liegt es an einem Namen.

**Entscheidungspunkt nach Phase 3 (Sollbruchstelle).** Hier liegt der gemessene Aufwand der Phasen 1 bis 3 vor (Plan: 23,5 bis 38,5 Tage). Liegt er über dem oberen Wert, wählt der Autor Schnitt B statt des vollen Umfangs:

- **Schnitt A (Vorgabe):** alles in Zug 0.4.1, ein einziger Namensbruch.
- **Schnitt B:** Zug 0.4.1 enthält das Kernbündel mit den neuen Parametern und Werten, dazu insert-a-word und random (sie hängen an aufgaben bzw. sind klein); mathematik, physik, informatik, operatoren, energy-sketch fahren strukturell umgebaut (Phase 3) mit ihren **alten Parametern und alten Schreibweisen** (`häufigkeitsanalyse`, `lineare_regression`, …) mit und stehen als dokumentierte Ausnahme in `lint-offen.txt`. Ihre Umbenennung (4.3 bis 4.7) kommt in Zug 0.4.2. Das ist die einzige zugelassene Ausnahme von 2.4 („umbenennen erst in 0.5.0"), steht im CHANGELOG, und Dokumente mit Fachpaket-Aufrufen brauchen einen zweiten Codemod-Lauf. Spart vor der ersten Freigabe 4 bis 7 Tage aus Phase 4 und den Doku-Anteil dieser fünf Pakete aus Phase 8.

### Phase 4: Blattpakete umbenennen (6 bis 10 Tage)

| Paket | nach | Größe | Besonderes |
|---|---|---|---|
| 4.1 random | Phase 3 | S | `a`, `m`, `lcg` nach `internal`; gleiche Zahlenfolge; `docs/` neu |
| 4.2 patterns | Phase 3 | M | `kariert`, `liniert` behalten ihren Namen; `scale` gibt es hier nicht, aber `width` als Kästchenzahl wird `columns`; Positionsargument 2 wird benannt (`kariert(4, columns: 12)`); `flex-feld`, `ist-flex-feld` werden `flex-area`, `is-flex-area` (Stubs) |
| 4.3 energy-sketch | Phase 3 | S | `labeled` gewendet |
| 4.4 operatoren | Phase 3 | S | `operatoren-liste` behält den Namen, Parameter englisch (`subject`, `bold`); States umbenannt |
| 4.5 physik | 4.1 | M | `datensatz`, `messdaten`, `berechnung`, `messwerttabelle`, `schaltkreis`, `konstante` behalten ihren Namen; snake_case weg (sechs Regressionen mit Bindestrich, Stubs); `pk` → `constants`; `amperemeter` → `ammeter`; Helfer nach `internal`; `digits` für drei alte Namen; keine eigenen `qty`, `num`, `unit` im Export |
| 4.6 informatik | Phase 3 | M | `häufigkeitsanalyse` → `haeufigkeitsanalyse` (nur Umschrift, Stub), Zahlumwandlungen `bin-to-dec` und Geschwister, eine Aufrufform für Chiffren; blockst-Re-Export entfällt; README (383 Zeilen) neu aus den Docstrings |
| 4.7 mathematik | 4.1, 4.5 | M | `graphen`, `steckbrief`, `kreisdiagramm` behalten ihren Namen; Umlaut-Parameter (`datensätze:` → `datasets:`, `größe:` → `size:`); Unter-Dictionaries `fills`/`marks`/`datasets` nach `tabelle-fachpakete.md` |
| 4.9 insert-a-word | Phase 5 | S | `reset-iaword`, `word-bank`, folgt `has-solutions()`; States nach `internal` |

klausurboegen (früher 4.8) steht jetzt als 7.1 in Phase 7, weil klassenarbeit das Nutzer-Dictionary dynamisch an `klausurbögen(…)` durchreicht (klassenarbeit.typ Z. 25–40). 4.1 bis 4.4 und 4.6 laufen parallel; 4.5 und 4.7 folgen ihren Vorgängern. Die Größen bleiben trotz der Entscheidung vom 2026-11-15 stehen: Der Funktionsname war in jedem dieser Schritte der kleinste Teil; Parameter, Werte, Prüfung, `lib`/`internal`, Docstrings und Doku bleiben. Abnahme je Paket: der Takt oben, dazu `docs/docs.typ` baut mit `build.sh --streng`, jede öffentliche Funktion hat einen Docstring.

### Phase 5: aufgaben, Bausteine und Aktionen (2 bis 4,5 Tage)

| | |
|---|---|
| Ziel | Bausteine und Aktionen nach KONVENTION A.3 bis A.5. Das Options-Schema bleibt in dieser Phase beim alten Stand (es wandert nach 6.1). |
| Schritte | 5.3 Bausteine `aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung` und das sprachgleiche `material`: Die Namen bleiben (`teilaufgaben` zieht aus arbeitsblatt nach aufgaben um, tabelle-aufgaben 1.3; arbeitsblatt re-exportiert den Namen danach nur noch), die Signaturen werden A.3 und A.4 (Parameter englisch: `title`, `method`, `workspace`, `marker`, `label`, `items`, `item-solutions`, …; Punkte nur positional); zweite Wege werden Fehler mit Abhilfe; kein Aliasblock (S bis M, früher M: Die Umbenennung der fünf Funktionen im Quelltext und in allen abhängigen Paketen und der Aliasblock entfallen). 5.4 Aktionen und Abfragen (`show-solutions(select:)` ersetzt drei Funktionen, `show-points-table`, `get-points`, `format-points`, `has-solutions`, `is-print`; alle rein englisch mit dem Parameterwort hinter dem Verb, die alten Mischnamen `show-loesungen`, `show-offene-loesungen`, `show-materialien`, `show-erwartungen`, `show-bewertung`, `reset-aufgaben`, `format-punkte`, `loesungsmodus` als Stubs) (M). 5.5 Theme-Hooks: aufgaben liest die **neuen** Hooknamen; wird zusammen mit 6.3 in einem Commit ausgeführt (S). |
| Dateien | `aufgaben/0.4.1/src/*`, `kern/0.4.1/regeln.json`, `tests/zug/aufgaben-*`, abhängig: `arbeitsblatt/0.4.1`, `klassenarbeit/0.4.1`, `insert-a-word/0.4.1` (statische Namen der Aktionen und Parameter, per Codemod; die Bausteinaufrufe bleiben stehen) |
| Abhängig von | Phase 3; unabhängig von Phase 4 (aufgaben importiert kein Blattpaket) und deshalb parallel dazu |
| Abnahme | Takt; alle Golddokumente gleich, auch die mit `#show: arbeitsblatt.with(loesungen: …)` (die Optionen sind noch alt); `rg '(state\|counter)\(\s*"' aufgaben/0.4.1/src` trifft nur `internal.typ` |

Die Nummern 5.1 und 5.2 sind nach 6.1 gewandert.

### Phase 6: arbeitsblatt (13 bis 23 Tage)

| | |
|---|---|
| Ziel | Optionsschnitt, Vorlagen, Bausteine, Kästen, Themes und Exporte nach KONVENTION 6, 7.1, A.1, A.8 bis A.12 |
| Schritte | **6.1 Optionsschnitt, ein Arbeitspaket mit einem Commit und einem Goldlauf** (5,5 bis 9,5 Tage). arbeitsblatt prüft die alten Optionswerte heute selbst (arbeitsblatt.typ Z. 312–319), ruft `set-options(("loesungen": loesungen, …))` (Z. 573) und verzweigt auf `loesungen in ("seite", "seiten", "reinquetschen")` (Z. 711–715, 1179, 1307, 1330); der Codemod kann diese dynamische Weitergabe nicht umstellen. Deshalb gemeinsam: (a) aufgaben: `internal.option-schema`, `init-options`, `get-options`; `set-options` mit deklarierten Parametern und `auto` = unverändert (früher 5.1, M). (b) aufgaben: Wertabbildung, aus `loesungen` werden `solutions` und `solutions-pagebreak`, aus `materialien` `materials` und `materials-pagebreak`, aus `punkte` vier Geschwister; zuerst nur an der Eingangsstelle übersetzen (neuer Name → alte interne Logik), dann die Logik selbst umschreiben, Goldlauf nach beiden Teilschritten (früher 5.2, L). (c) arbeitsblatt: `arbeitsblatt`, `arbeitsblatt-einzeln` mit Signatur A.1, Prüfung über das Schema, Verzweigungen auf die neuen Werte; Metadaten englisch mit deutscher Ausgabe nach `<ab-meta>` über `internal.meta-keys` (M). (d) klassenarbeit: Regeln für die durchgereichten Kopfparameter von `klassenarbeit` in `regeln.json` (klassenarbeit reicht bis Phase 7 blind an `arbeitsblatt-einzeln` durch, die neuen Namen kommen also an) und Anpassung der Stellen in klassenarbeit.typ, die Optionen selbst lesen (S). 6.2 Varianten: `variants`, `variant-overrides`, `preview-variant`, `filename`; Variantennamen englisch, Dateiendungen deutsch und eingefroren; `--input vorschau=alle` unverändert (M). 6.3 Theme-Vertrag: Schlüssel und Hooks in `themes.typ` nach A.12 (acht Themes), Prüfung gegen `schemas.theme`, `internal.resolve-theme`; Codemod-Regel für Hook-Lambdas; zusammen mit 5.5 (L). 6.4 Kästen: 15 eigene Funktionen mit der Signatur A.11, ohne Durchreich-Sink (M). 6.5 Bausteine und Helfer: `luecke` (Umschrift von `lücke`, Stub), `lsg` (Name bleibt), `minipage`, `conditional-pagebreak`, `qr-code`, `qr-box`, `icon-link`, `workspace` (M). 6.6 Exportliste auf den Endstand kürzen (1.3); `fremdnamen.txt`; `fremdpakete.py`; namentlicher Re-Export der Bausteine und Stubs der durchgereichten Pakete (kein Aliasblock, keine Neubindung); `removed.typ` mit den eigenen Stubs (darunter `tasks` → `teilaufgaben`, der Stub gehört arbeitsblatt, nicht aufgaben); Abgleich gegen `bausteine-de.txt` und `zwillinge.txt` (M). 6.7 L13: jedes Builtin, das als Parametername vorkommt, im Rumpf als `std.<name>` (S, mechanisch, lint-geführt). |
| Dateien | `arbeitsblatt/0.4.1/src/{lib,internal,arbeitsblatt,themes,callouts,blocks,removed}.typ` (Aufteilung der heutigen `arbeitsblatt.typ` nach Sachgebiet; die Datei mit der Seitenvorlage behält den Namen des Bausteins wie `klassenarbeit.typ`, damit der Website-Anker `arbeitsblatt-arbeitsblatt` bleibt), `aufgaben/0.4.1/src/*` (6.1), `klassenarbeit/0.4.1/src/klassenarbeit.typ` (6.1 d), `showcase/`, `.github/namen/exporte/arbeitsblatt.txt` |
| Abhängig von | Phasen 4, 5 |
| Parallel | 6.3, 6.4, 6.5 untereinander, nach 6.1 |
| Abnahme | Takt; nach 6.1 alle Golddokumente gleich, einschließlich `ab-loesungen-*`, `ab-materialien-*`, `ab-punkte-*` und `ka-*`; L17 erfüllt; für jede Option jeder Wert getestet; alle Theme-Golddokumente gleich auf S4 (lokal); Bundle-Test (4.4) gleich; exportierte Menge = Exportliste; L12, L13, L18, L23 (Bausteinliste), L27 (Sprachtrennung) erfüllt |

### Phase 7: klausurboegen und klassenarbeit (4 bis 7 Tage)

| | |
|---|---|
| Ziel | `klausurboegen` nach A.6 und `klassenarbeit` nach A.2, ohne blindes Durchreichen und ohne Zugriff auf `_`-Namen |
| Schritte | **7.1 und 7.2 in einem Commit mit einem Goldlauf.** 7.1 klausurboegen (früher 4.8): benutzt `kariert` und `liniert` aus patterns; Signatur A.6; `scale` → `grid-size`; die Funktion heißt `klausurboegen` (Stub für `klausurbögen`); das Muster-Enum bleibt englisch (`pattern: "squares" | "lines"`), `pattern: "kariert"` meldet den Vorschlag (M). 7.2 `klassenarbeit`: Signatur deklarieren, Prüfung unter `klassenarbeit.klassenarbeit`, namentliche Weitergabe an `arbeitsblatt-einzeln`; die Parameter `expectations` und `answer-sheets` als W6, geprüft mit den Tabellen von `show-expectations` und `klausurboegen`; der alte Kopfparameter `klausurboegen: (…)` wird `answer-sheets: (…)` (der Parameter trägt das Parameterwort, nicht den Bausteinnamen); damit stellt der Codemod auch die Schlüssel des Nutzer-Dictionary (`muster`, `linienabstand`, `korrekturrand`) um, weil die Regel dafür zu `klassenarbeit.klassenarbeit` gehört (M). 7.3 Leere Texte: `""` wird `none`; persönliche Vorgaben (`"SLZ"`, `"PH1"`, Datum) entfallen (S). 7.4 Exportliste (kein Aliasblock; `klassenarbeit` ist der Baustein selbst); Einträge in `regeln.json` für die alten Kopfparameter: `stufe`, `table`, `klausurboegen-settings`, `ergebnisse`, `bewertung` entfernt mit Hinweis; `bogen` → `answer-sheet-pages` (umbenannt, nicht entfernt); `removed.typ` von klausurboegen nur für alte Funktionsnamen (`klausurbögen` → `klausurboegen`; `bogen-seiten`, `klausurbogen-arbeit` als `functions-removed` mit Hinweis); klassenarbeit hat dafür keine eigenen Stubs (S). 7.5 Bundle-Dateinamen unverändert; der Fehler „content-Titel ergibt `Klassenarbeit 1.pdf`" wird nach der Entscheidung in `bekannte-fehler.md` behandelt (S). |
| Dateien | `klausurboegen/0.4.1/src/*`, `klassenarbeit/0.4.1/src/*`, `template/ka.typ` |
| Abhängig von | Phase 6, 4.2 |
| Abnahme | Takt; die drei Klausurbogen-Golddokumente gleich (S4 lokal); `rg '\.\.args' klassenarbeit/0.4.1/src` ohne Treffer; ein Tippfehler in einem Kopfparameter meldet `klassenarbeit.klassenarbeit: …` |

### Phase 8: Doku und Vorlagen (8 bis 14 Tage)

| | |
|---|---|
| Ziel | Jede Doku baut, jedes Beispiel läuft, kein alter Name steht mehr im Zug |
| Schritte | 8.1 schuldocs 0.3.1 mit `example` (M). 8.2 `arbeitsblatt/0.4.1/docs/docs.typ` neu; `content.typ` nachziehen: Themes, Kästen, Metadaten, `lsg`, Varianten (L). 8.3 `content.typ` der übrigen Pakete: `umstellen.py`, dann von Hand Options-Tabellen und Fließtext (die Bausteinnamen in Fließtext, Überschriften und Beispielen bleiben stehen, nachzuziehen sind Parameter und Werte); Tabellen der Optionen kommen aus `regeln.py --markdown`; je Paket die `show-module`-Liste in `docs.typ` an die neue Dateiaufteilung anpassen; `docs/` für random neu anlegen (M bis kleines L, 1 bis 3 Tage; früher M bis L). 8.4 READMEs und CHANGELOGs je Paket (auch `kern/README.md`); `UMSTELLUNG.md` im Repo-Root aus `regeln.py --markdown`, mit den Abschnitten „Was gleich bleibt" (Bausteinaufrufe), „Untergrenze", „eigene Themes", „Fremdimporte und Kollisionen" (M). 8.5 `template/ab.typ`, `template/ka.typ` nur mit den Namen der Zielversion (deutsche Bausteine, englische Parameter, wie KONVENTION A.0); Kommentare mit den erlaubten Werten aus `regeln.json` (S). 8.6 `.github/scripts/index.html`: Karte für `random` (heute ohne), Hinweis auf `kern` ohne eigene Doku, Archivpakete markiert, Beschreibungen (S). 8.7 `typst.toml` der kleinen Pakete: echte `description` statt Platzhalter (S). 8.8 Root-`README.md`: Abschnitte „Versionen" (Zug, Einfrieren), „Namen" (Verweis auf die Konvention), „Umstellen" (S). |
| Abhängig von | Phasen 4 bis 7; 8.1 kann ab Phase 2 parallel laufen |
| Parallel | je Paket |
| Abnahme | Abnahmekriterien 3f; 3e Punkt 3 (`neuer-zug.sh 0.4.2` im Wegwerf-Klon) |

### Phase 9: Freigabe des Zugs 0.4.1 (1,5 bis 2,5 Tage)

| | |
|---|---|
| Schritte | **9.0 Probelauf vor dem Einfrieren, ohne an einem Original zu schreiben (M):** `umstellen.py --pruefen` über alle 58 Dokumente auf 0.4.0 und über eine Kopie aller 286 eduki-Dokumente; iPad-Test mit dem Zweigstand (`ipad-abgleich.sh`, ein Arbeitsblatt, eine Klassenarbeit). Jeder hier gefundene Fehler wird noch im Zug 0.4.1 behoben; nach dem Einfrieren kostete er einen Zug 0.4.2. (1) Voller Korpus-Lauf, Schwellen aus 4.2. (2) Definition of Done, Teil „Freigabe" (Abschnitt 8) abhaken. (3) `linie-0.4` nach `main`. (4) `neuer-zug.sh --einfrieren 0.4.1`, Tag `zug-0.4.1`; die fünf Vorlagenordner werden hart eingefroren. (5) Website-Build prüfen. (6) Zweiten Klon `~/Documents/GitHub/Typst-Schule` auf `main` ziehen. |
| Abhängig von | Phasen 3 bis 8 |
| Abnahme | CI auf `main` grün; Website zeigt 0.4.1 für alle Zugpakete außer `kern`; `eingefroren.json` enthält den Zug |

### Phase 10: Umstellung außerhalb des Repos (M, danach laufend)

Reihenfolge nach Nutzen. Jeder Schritt schreibt außerhalb des Repos und wird vom Autor ausgelöst. Abnahme ist Teil „Umfeld" der Definition of Done; er gehört nicht zur Freigabe des Zugs.

| Nr. | Was | Vorgehen | Abnahme |
|---|---|---|---|
| 10.1 | iPad: `iCloud~P0int~Typist/Documents/LocalPackages/schule` | `ipad-abgleich.sh` kopiert die dreizehn Ordner des Zugs dorthin; alte Ordner bleiben (Probelauf schon in 3.7 und 9.0) | ein Testdokument mit `@schule/arbeitsblatt:0.4.1` kompiliert in Typist |
| 10.2 | Dokumente auf 0.4.0 (47 + 11) | `umstellen.py --schreiben` (in 9.0 schon mit `--pruefen` durchgespielt); Sicherungsdatei bleibt daneben | jedes kompiliert mit 0.4.1; Bericht ohne offene Punkte |
| 10.3 | `~/Documents/GitHub/eduki` (286 Dokumente, Pins in 8 `material.toml`, 2 JSON, 1 Python, 2 Markdown; darunter informatik 0.0.1 und arbeitsblatt 0.3.2). Einziger Bestand, der nach außen geht | eigener Zweig; Codemod über die `.typ`; `umstellen.py --pins` hebt die Versionsangaben in den übrigen Dateien; Build des eduki-Repos (was das ist, steht seit Phase 0 fest) | eduki-Build grün; `gold.py` über **alle 286** Dokumente (alter Pin gegen umgestellt), jede Abweichung einzeln freigegeben |
| 10.4 | `~/Documents/GitHub/AO/AGENTS.md` und andere Agenten-Anleitungen | Parameter, Werte, Aktionsnamen und Version von Hand auf 0.4.1 (die Bausteinnamen stimmen schon); Verweis auf `UMSTELLUNG.md` | `rg 'arbeitsblatt:0\.2\.4' AGENTS.md` ohne Treffer |
| 10.5 | Vorlagen des Autors für neue Dokumente (Snippets, Kopiervorlagen) | auf `template/ab.typ` und `template/ka.typ` des Zugs umstellen | neue Dokumente entstehen mit 0.4.1 |
| 10.6 | `~/Documents/GitHub/typstage-app` | nur prüfen: verdrahtet ist `@schule/typstage:0.2.0`, kein Zugpaket. `rg '@schule/(arbeitsblatt\|klassenarbeit\|aufgaben)' typstage-app` | kein Treffer, sonst Pins heben |
| 10.7 | Klassenarchiv (`klassenarchiv-quellen`, Cloud; 4643 Cloud-Dateien wurden nie gelesen) | **keine Massenumstellung.** Ein Dokument wird umgestellt, wenn es das nächste Mal bearbeitet wird; die Sicherungsdatei kann danach gelöscht werden. Dabei gefundene alte Namen kommen in `regeln-codemod.json` (kein neuer Zug nötig) | – |

### Was parallel geht (Überblick)

```
main:       Phase 0 ─► Phase 1 (vier Stränge) ─► Abzweig linie-0.4
linie-0.4:  Phase 2 (vier Stränge) ─► Phase 3 ─► Entscheidungspunkt Schnitt A/B
                 │ 8.1 schuldocs
Phase 3 ─┬─► 4.1 random ─► 4.5 physik ─► 4.7 mathematik ──────────┐
         ├─► 4.2 patterns ───────────────────────────────────────┤
         ├─► 4.3 energy-sketch, 4.4 operatoren, 4.6 informatik ──┤
         └─► Phase 5 aufgaben (Bausteine, Aktionen) ─► 4.9 iaword┤
                                                                 ▼
             Phase 6: 6.1 Optionsschnitt (aufgaben + arbeitsblatt + klassenarbeit, ein Commit)
                      ─► 6.2 … 6.7 (5.5 mit 6.3 in einem Commit)
                                                                 ▼
             Phase 7: 7.1 klausurboegen + 7.2 klassenarbeit (ein Commit) ─► 7.3 … 7.5
             Phase 8 je Paket, sobald das Paket fertig ist
                                                                 ▼
             Phase 9: 9.0 Probelauf ─► Freigabe ─► Phase 10
```

Parallele Stränge helfen nur, wenn Assistenz parallel arbeitet; für eine Person allein zählt die Summe.

### Gesamtumfang

Gerechnet aus den Teilgrößen (S = 0,5, M = 1 bis 2, L = 3 bis 5 Tage; eine Person mit Assistenz). Die frühere Angabe „rund sechs Wochen" passte nicht zu den eigenen Teilgrößen. Nach der Entscheidung vom 2026-11-15 (deutsche Bausteine) sind nur die Stellen neu gerechnet, an denen die Funktionsumbenennung ein eigener Posten war: 5.3 und 8.3.

| Phase | Teilgrößen | Tage |
|---|---|---|
| 0 | 2 S + Entscheidungen | 1 bis 2 |
| 1 | 3 M + 1 L + 5 S | 8,5 bis 13,5 |
| 2 | 3 M + 1 L + 3 S | 7,5 bis 12,5 |
| 3 | 3 M + 1 L + 3 S | 7,5 bis 12,5 |
| 4 (ohne klausurboegen) | 4 M + 4 S | 6 bis 10 |
| 5 | 1 M + 1 S bis M + 1 S | 2 bis 4,5 |
| 6 | 6.1: 2 M + 1 L + 1 S; Rest: 4 M + 1 L + 1 S | 13 bis 23 |
| 7 | 2 M + 3 S, dazu 0,5 bis 1,5 Tage Reserve für den gemeinsamen Commit | 4 bis 7 |
| 8 | 2 M + 1 L + 4 S, dazu 8.3 mit 1 bis 3 Tagen | 8 bis 14 |
| 9 | 1 M + 1 S | 1,5 bis 2,5 |
| **Summe bis zur Freigabe** | | **rund 59 bis 102 Arbeitstage** |

Das sind 12 bis 20 Arbeitswochen in Vollzeit, neben dem Unterricht entsprechend länger. Die Entscheidung für deutsche Bausteine spart im Repo also wenig (einen halben Tag in Phase 5, bis zu zwei Tage in Phase 8, dazu je Umbenennungsschritt einen Goldlauf): Der Aufwand steckt in Struktur, Parametern, Optionsschnitt, Themes und Doku, nicht im Funktionsnamen. Der Gewinn liegt im Bestand: Die rund 5100 Ersetzungen von `aufgabe` und `teilaufgabe` entfallen, die Diffs beim Anheben werden kleiner, die Kollisionsfläche neuer Exporte schrumpft (R10), und die zweite Umstellung am Ende einer Übergangsfrist findet nie statt. Folgerungen: (1) Der Entscheidungspunkt nach Phase 3 ist verbindlich. (2) Phasen 0 und 1 sind für sich nützlich (Einfrieren, Goldvergleich, Snapshots) und bleiben auf `main`, auch wenn der Umbau danach nicht weitergeht. (3) Schnitt B verkürzt den Weg zur ersten Freigabe um etwa eine bis zwei Wochen; eine größere Kürzung gibt es nur, wenn der Umfang auf das Kernbündel begrenzt und der Familien-Re-Export der Fachpakete für 0.4.1 eingefroren wird, wie er ist.

---

## 6. Risiken und Gegenmaßnahmen

| Nr. | Risiko | Woran man es merkt | Gegenmaßnahme |
|---|---|---|---|
| R1 | **Stille Verhaltensänderung durch geänderte Vorgabe.** Betroffen: `""` → `none` (sechs Parameter), `logo: "angela"` → `auto`, `klausurboegen`-Vorgaben `"SLZ"`, `"PH1"`, Datum, `custom-header: none` (heute Standardkopf, künftig hieße `header: none` „kein Kopf"), `materialien: "seiten"`, `erwartung(points: 2)` (heute still 0 Punkte), gewendete Schalter `word-bank`, `labeled`, `title: none` statt `headless` | Goldvergleich S1 bis S3 | L25 mit der Liste `defaults-changed`; je Eintrag ein Golddokument, das die Vorgabe ausdrücklich nicht setzt; Kontextregeln im Codemod; CHANGELOG „Verhalten" |
| R2 | **State-Kollision zweier Paketversionen im selben Dokument** (direkter Import eines Fachpakets aus einem anderen Zug; altes mathematik neben neuem arbeitsblatt) | zweite Aufgabenzählung, Lösungen fehlen, `has-solutions()` falsch | Schlüssel mit Paket und `@schema`; keine Raute im Zug (`pins-pruefen.py`); zwei Züge ab 0.4.1: Versionsmarke mit Fehlermeldung am Dokumentende; **Paket vor 0.4.1 neben neuem: die Versionsmarke greift dort nicht, dafür die Altprüfung über die alten Schlüssel (1.4)**; Codemod hebt alle @schule-Importe eines Dokuments gemeinsam. Restlücke: ein altes Fachpaket, das die alte Aufgabenwelt nicht benutzt, bleibt unbemerkt und ist dann auch unschädlich |
| R3 | **Themes-Vertrag** läuft zwischen arbeitsblatt und aufgaben auseinander; eigene Themes in Dokumenten (37 Köpfe nutzen `theme`) tragen alte Schlüssel oder alte Hook-Parameter | Kopf oder Kasten fehlt ohne Fehler; bei alten Hook-Parametern ein nackter Fehler „unexpected argument" | ein Vertrag in `regeln.json` (`schemas.theme`); Prüfung der **Schlüssel** jedes aufgelösten Dictionary, alter Schlüssel meldet „heißt jetzt"; Umstellung von 5.5 und 6.3 in einem Commit; Bildvergleich S4 je Theme; Codemod stellt Theme-Dictionary-Literale und Hook-Lambdas um. **Nicht abgedeckt: Hook-Signaturen sind zur Laufzeit nicht prüfbar** (1.5); dafür Zählung im Korpus, Berichtseintrag, dokumentierte Meldung in `UMSTELLUNG.md` |
| R4 | **Bundle-Export** bricht: Dateinamen, `scope`-Kennungen, `reset-tasks` je Variante, `vorschau=alle`, Build-Skripte außerhalb des Repos | fehlende oder umbenannte PDF im Ausgabeordner | Dateiendungen und `--input vorschau` eingefroren (KONVENTION 2.1); Test 4.4 vergleicht die Dateiliste; eduki-Build als externer Prüfstein (Probelauf 9.0, Umstellung 10.3). Was das eduki-Buildskript verdrahtet (`--input`, Dateinamen, Query-Schlüssel), wird in Phase 0 erhoben und hier nachgetragen: **[offen bis Phase 0]** |
| R5 | **Doku-Drift** kehrt zurück | Beispiel in der Doku kompiliert nicht | `doku-beispiele.py` und `build.sh --streng` in CI; `example` mit einmal geschriebenem Code; Options-Tabellen aus `regeln.json` erzeugt; L26 |
| R6 | **Codemod übersieht Indirektes** (Spread, Wrapper, dynamische Werte) | Fehler beim ersten Kompilieren | das ist die geplante zweite Stufe: „heißt jetzt"-Meldung statt stiller Annahme; Bericht des Codemods; `--pruefen` |
| R7 | **Fehlerort zeigt ins Paket**, bei Show-Regeln fehlt die Nutzerdatei ganz | Meldung ohne Zeile | Meldung nennt immer Paket, Funktion, alten und neuen Namen; `umstellen.py` zeigt die Stelle im Diff |
| R8 | **Builtin wird durch Parameternamen überdeckt** (`text`, `table`, `columns`, `align`, `label`, `numbering`, `header`, `footer`, `figure`, `stroke`) | Fehler nur auf selten benutzten Pfaden | L13 (lint-geführt), dazu je Funktion mindestens ein Test, der jeden Parameter einmal setzt |
| R9 | **Wegfall der 5480 durchgereichten Namen** trifft Dokumente, die sie unbemerkt nutzen | `unknown variable` nach dem Anheben | `herkunft.json`; Codemod fügt Importe ein; Zählung im Korpus vor dem Kürzen der Exportliste (3.4, 6.6); häufige Namen kommen notfalls in `fremdnamen.txt` |
| R10 | **Neue Exporte kollidieren mit Namen im Dokument oder mit Fremdimporten.** Seit der Entscheidung vom 2026-11-15 kleiner: `lines`, `squares`, `blank`, `task`, `exam`, `solution` sind keine Exporte mehr, und ein späteres `#import "@preview/gentle-clues…": *` überdeckt keinen eigenen `task`. Es bleiben englische Helfer und Kästen (`material`, `workspace`, `info`, `tip`, …), `qty`, `num`, `unit` gegenüber einem früheren `@preview/metro: *` und dokumenteigene Definitionen (`#let luecke`, R20) | falsche Funktion wird aufgerufen, meist mit Typfehler | L12 mit der erweiterten Prüfmenge `mitimporte.json` (tablex, unify, blockst, pinit, mannot, metro, codly, summify, typstage, abbozza, eduki u. a.); `kollisionen-erlaubt.txt` ohne `task`; Codemod meldet lokale Definitionen und **jeden** Wildcard-Fremdimport mit den tatsächlich kollidierenden Namen, gleich in welcher Reihenfolge; Spalte „Kollisionen" im Korpus-Bericht; Abschnitt in `UMSTELLUNG.md` |
| R11 | **Eingefrorenes wird weiter in place geändert** (Gewohnheit: aufgaben 0.3.0 neunmal; zehn Commits seit Oktober in den Vorlagenordnern) | Bestandsdokument sieht plötzlich anders aus; Korrektur fehlt im Rohling | Tree-Hash-Prüfung auf `main` schon ab Phase 1, lokal zusätzlich `git status --porcelain`; für die fünf Vorlagenordner der eine erlaubte Weg `bestandskorrektur.sh`, der die Korrektur in den Zug überträgt (Abschnitt 5); `neuer-zug.sh` macht einen neuen Zug zu einem einzigen Befehl |
| R12 | **Zusammenführung klausurboegen 0.0.4/0.0.5** ändert einen der beiden Äste | Goldvergleich der drei Klausurbogen-Dokumente | Zusammenführung mit alten Namen in Phase 3, vor jeder Umbenennung; S4 |
| R13 | **Parser-Version** (`typst-syntax 0.14.2` gegen Typst 0.15.1) | Syntaxfehler in einer Datei, die Typst annimmt | Codemod fasst Dateien mit Parserfehler nicht an und meldet sie; Hebung des Parsers, sobald möglich |
| R14 | **Schülerdaten im Korpus** geraten ins Repo oder in CI | – | Korpus nur unter `~/Library/Caches`, nie im Repo; CI benutzt nur synthetische Golddokumente; `.gitignore`-Eintrag für `korpus*/` |
| R15 | **Hebung energy-sketch** (cetz 0.3.1 → 0.5.2) und andere Pin-Hebungen ändern Zeichnungen | S4 des Golddokuments `fach-energie.typ` | eigener Schritt 3.3 mit eigenem `gold.py pin`-Lauf je Hebung (der Erststart 3.1 lässt die Pins stehen); bei Abweichung bleibt energy-sketch 0.4.1 auf dem Stand 0.0.2 |
| R16 | **Umfang**: die Linie bleibt halb fertig liegen wie 0.4.0. Die Summe der Teilgrößen ergibt rund 59 bis 102 Arbeitstage, nicht sechs Wochen | Zweig lebt monatelang | Phasen 0 und 1 landen auf `main` und nützen für sich; nach Phase 3 ist der Zug in sich lauffähig; Entscheidungspunkt nach Phase 3 mit Schnitt B; kein Zwischenstand lässt ein Golddokument rot (gemeinsame Commits 6.1, 7.1/7.2, 5.5/6.3); Abbruchkriterium je Phase; Freigabe erst nach Abschnitt 8, Teil „Freigabe" |
| R17 | **CI und lokale Umgebung weichen ab** (Schriften, Typst 0.15.0 gegen 0.15.1, fehlende Programme) | Goldvergleich in CI rot, lokal grün, oder umgekehrt | keine eingecheckte Referenz; beide Seiten im selben Lauf (4.1); CI auf 0.15.1; `gold.py selbst` als Umgebungstest; S4 nur lokal |
| R18 | **iPad**: Typist läuft auf einer älteren Typst-Version oder findet @preview-Pakete nicht | Paket lädt in Typist nicht (`compiler`-Feld) | Version in Phase 0 feststellen; Probelauf mit den Rohlingen (3.7) und vor dem Einfrieren (9.0); `compiler` nach Befund setzen oder Einschränkung dokumentieren |
| R19 | **Regeltabelle im eingefrorenen Paket**: ein übersehener alter Name bräuchte einen neuen Zug | Dokument scheitert mit Tippfehlervorschlag statt „heißt jetzt" | `regeln-codemod.json` außerhalb des Pakets (3a); Laufzeit-Eintrag im nächsten Zug; L24 gegen die Vereinigung der Altsnapshots |
| R20 | **`lücke` → `luecke` trifft dokumenteigene Funktionen.** 119 Aufrufe von `lücke` stehen 32 Aufrufen `#luecke(` gegenüber, die zu im Dokument definierten Funktionen gehören; nach dem Anheben exportiert das Paket selbst `luecke` | Dokument ruft nach dem Codemod die falsche `luecke` auf, oder der Stub `lücke` bricht ab | Codemod benennt nur um, wenn das Dokument kein eigenes `#let luecke` und kein `#let lücke` hat, und führt jede Stelle im Bericht (KONVENTION 9.3); Fixture für beide Fälle (3c); eine dokumenteigene Definition nach dem Import überdeckt den Paketnamen wie bisher; Zählung im Korpus-Bericht |
| R21 | **Die Sprachgrenze verwischt mit der Zeit**: ein englischer Zweitname für einen Baustein, ein Mischname (`show-loesungen`, `aufgabe-number`), ein deutscher Enum-Wert (`pattern: "kariert"`) oder ein Baustein, der nicht in der Liste steht | zwei Schreibweisen für dasselbe Ding in Doku und Dokumenten | `bausteine-de.txt` ist abschließend und wird in beide Richtungen geprüft (L23); L27 mit `zwillinge.txt` und `wortpaare.json`; ein neuer Baustein ist ein Diff in drei Dateien; die Laufzeit meldet den deutschen Wert mit englischem Vorschlag; `tests/zug/bausteine.typ` |
| R22 | **Die vier `tabelle-*.md` oder `prototyp-regeln.json` tragen noch englische Bausteinnamen**, wenn sie nach `regeln.json` übertragen werden | `regeln.py --pruefen` meldet einen Funktionsschlüssel aus `zwillinge.txt` | Abnahme 1 in 3a prüft jeden Funktionsschlüssel gegen `bausteine-de.txt` und `zwillinge.txt`; die Übertragung (2.1) beginnt erst, wenn die Tabellen nachgezogen sind |

---

## 7. Was ausdrücklich nicht Teil von 0.4.x ist

1. Keine neuen Funktionen, keine neuen Themes, keine Gestaltungsänderung. 0.4.1 ist 0.4.0 mit neuer Struktur und neuen Namen in den Klammern (die Bausteine heißen wie bisher); jede sichtbare Abweichung steht in `abweichungen.toml`. Eine benannte Ausnahme: Die Zusammenführung des Seitenasts klausurboegen 0.0.4 / klassenarbeit 0.3.1 (`bogen:` → `answer-sheet-pages`) bringt gegenüber 0.4.0 Funktionsumfang zurück; sie hängt an der Entscheidung KONVENTION 11.4 (früher 11.6).
2. Keine Umbenennung von Paketen und keine Zusammenlegung von Paketen (außer dem neuen `kern`).
3. Keine Veröffentlichung auf Typst Universe.
4. `typstage`, `blockst`, `schuldocs` (außer der Funktion `example` in 0.3.1), `summify`, `eduki` (Paket), `abbozza`, `angela`, `typlace` bleiben unberührt.
5. Keine Hebung externer Pakete (cetz 0.5.x, codly 2, zero 0.7, gentle-clues 1.3, zap 0.6), kein Ersatz von tablex durch `table`, keine Vereinheitlichung von unify und fancy-units. Das sind Verhaltensänderungen und gehören in eine eigene Linie.
6. Keine Rückportierung in alte Versionsordner; kein Löschen alter Ordner.
7. Keine Massenumstellung des Klassenarchivs und keine Arbeit an Cloud-Platzhaltern; keine Unterstützung des Codemods für Dokumente vor arbeitsblatt 0.2.3 (0.2.0 bis 0.2.2 hängen an `messwerttabellen`), vor klassenarbeit 0.1.2 und vor aufgaben 0.1.0.
8. Kein Löschen der Compat-Tabelle und der Stubs in `removed.typ` (beides 0.5.0 und später). Keine englischen Zweitnamen für Bausteine, weder in 0.4.x noch später; Übergangsnamen, die man entfernen könnte, gibt es nicht.
9. Keine englische Ausgabe im PDF, keine englische Doku, keine Mehrsprachigkeit.
10. Keine Fehlerkorrekturen, die nicht für die Umbenennung nötig sind. Damit die Grenze prüfbar ist, gibt es `.github/namen/bekannte-fehler.md` (im Entwurf `entwurf/fehlerliste.md`, angelegt in Phase 1.6): je Befund der Fehlerlisten der Inventare (aufgaben Abschnitt 8, klassenarbeit/klausurboegen Abschnitt 4 mit 37 Punkten, mathematik 7, themes 8, dazu die Abschnitte „zu behebende Fehler" der vier Tabellen) eine Zeile mit genau einer Entscheidung: „in 0.4.1 behoben (Grund: API)", „in 0.4.1 behoben (Grund: Doku muss bauen)", „bleibt, 0.4.2" oder „entfällt mit dem Code". `abweichungen.toml` darf nur Einträge enthalten, die dort als „in 0.4.1 behoben" stehen oder unter R1 fallen. Der Plan selbst überschreitet die Grenze an benannten Stellen: `erwartung(points: 2)` (R1), das abstürzende klausurboegen-Doku-Beispiel (3f), der Dateiname bei content-Titel (7.5, Entscheidung des Autors). Beispiele für „bleibt, 0.4.2": toter `copyright`-Parameter im Kopf-Hook, `reset-aufgaben` lässt drei States aus.
11. Kein Warnkanal über den Schriftarten-Trick und kein sichtbarer „VERALTET"-Hinweis im PDF.
12. Die eingefrorenen Außenschnittstellen (`<ab-meta>` samt deutscher Schlüssel, `--input vorschau=alle`, Dateiendungen) werden nicht angefasst.

---

## 8. Definition of Done der Linie 0.4.x (Zug 0.4.1)

Jeder Punkt ist ein Befehl oder eine Datei. Die Liste hat drei Teile: **Freigabe** wird in Phase 9 vor dem Zusammenführen und Einfrieren abgehakt, **Freigabe vollzogen** unmittelbar danach; **Umfeld** ist die Abnahme von Phase 10 und liegt nach dem Einfrieren. `$ZUG_SRC` und `$ZUG` wie in den Begriffen (Ordner laut `buendel.toml`, nie `*/0.4.1`).

### Teil 1: Freigabe (vor dem Einfrieren)

**Struktur**

- [ ] `.github/buendel.toml` nennt dreizehn Zugpakete mit der Nummer 0.4.1; `python3 .github/scripts/pins-pruefen.py` endet mit 0.
- [ ] Jedes Zugpaket hat `src/lib.typ`, `README.md`, `CHANGELOG.md` und ein `compiler`-Feld; jedes außer `kern` hat `src/internal.typ` und `docs/docs.typ`.
- [ ] `rg 'import "@[^"]+": \*' $ZUG_SRC` ohne Treffer.
- [ ] `rg '#let _' $ZUG_SRC` ohne Treffer; `rg '(state|counter)\(\s*"' $ZUG_SRC` trifft nur `internal.typ` (eingebaute Zähler wie `counter(page)`, `counter(heading)`, `counter(figure.where(…))` sind nicht gemeint); jeder Schlüssel passt auf `^schule/<paket>/[a-z-]+@[0-9]+$`; K4 grün (auch Labels, Figure-Kinds, insert-a-word).
- [ ] `rg 'panic\(|assert\(|assert\.(eq|ne)\(' $ZUG_SRC` trifft nur `kern/0.4.1/src/fail.typ`.
- [ ] Die exportierte Menge von arbeitsblatt und klassenarbeit ist genau die eingecheckte Exportliste (heute 5526 Namen, dann wenige hundert).
- [ ] `klassenarbeit/0.4.1` benutzt von arbeitsblatt und aufgaben nur öffentliche Namen und Namen aus `intern-vertrag.json`.

**Namen**

- [ ] `python3 .github/scripts/sig.py --lint 0.4.1` meldet nichts; `.github/namen/lint-offen.txt` existiert nicht (bei Schnitt B: enthält nur die fünf benannten Fachpakete).
- [ ] `python3 .github/scripts/regeln.py --pruefen` endet mit 0 (beide Regeldateien); jede Zeile der vier `tabelle-*.md` hat einen Eintrag; `regeln.py --deckung` ohne Lücke.
- [ ] Jeder Name der alten Snapshots (Vereinigung, 3d), der im neuen fehlt, steht in einer Regeldatei (L24).
- [ ] Bausteinliste: `.github/namen/bausteine-de.txt` nennt 30 Namen; jeder ist von genau einem Zugpaket definiert und exportiert, keiner ist ein zweites Mal gebunden, jeder hat eine Zeile in `wortpaare.json` (L23); `tests/zug/bausteine.typ` ist grün.
- [ ] Sprachtrennung: kein Name aus `.github/namen/zwillinge.txt` wird exportiert, kein Mischname und kein deutscher Enum-Wert im Zug (L27); `tests/zug/zwilling.typ` scheitert wie erwartet mit „unknown variable"; `rg 'kern\.strict|inputs.*streng' $ZUG_SRC` ohne Treffer.

**Tests**

- [ ] `bash tests/run.sh` grün: `tests/zug/` (alle Pakete, alle Meldungsarten, alle Compat-Einträge, Altprüfung), `tests/alt/`; `bash tests/werkzeug/run.sh` grün.
- [ ] `python3 .github/scripts/gold.py umbau` meldet für alle Golddokumente „gleich" (S1 bis S3), lokal mit den echten Schriften zusätzlich S4, wo markiert; `tests/gold/abweichungen.toml` enthält nur begründete Einträge, jeder steht im CHANGELOG unter „Verhalten" und in `bekannte-fehler.md`.
- [ ] Bundle-Test (4.4) grün.
- [ ] Korpus-Lauf: Klasse A auf 0.4.0 100 % kompiliert und 100 % gleich (S1 bis S3, Abweichungen in `abweichungen.toml`); Klasse A auf 0.3.x 100 % kompiliert und nicht schlechter als der Basislauf; Klasse B (alle lokalen Dokumente ab der Untergrenze) mindestens 90 % ohne Handarbeit; `bericht.html` liegt vor.
- [ ] Probelauf 9.0: `umstellen.py --pruefen` über die 58 Dokumente auf 0.4.0 und die Kopie der 286 eduki-Dokumente ohne unerklärte Abweichung; iPad-Test mit dem Zweigstand bestanden.

**Werkzeuge**

- [ ] `umstellen.py`: Fixtures grün (auch `--pins`), idempotent; `umstellen.py` über `docs/`, `template/`, `README.md`, `tests/zug/` des Zugs ergibt keinen Diff; die Fixture „nur Bausteinaufrufe" bleibt bis auf die Importzeile byte-gleich.
- [ ] `neuer-zug.sh 0.4.2` läuft in einem Wegwerf-Klon ohne Handgriff bis grün (3e Punkt 3).
- [ ] `.github/workflows/namen.yml`, `tests.yml`, `build-docs.yml`, `versionen.yml` grün auf dem Zweig.

**Doku**

- [ ] `bash .github/scripts/build.sh --streng 0.4.1` endet mit 0 für die zwölf Pakete mit Doku.
- [ ] `python3 .github/scripts/doku-beispiele.py` meldet null Fehler.
- [ ] Jede öffentliche Funktion hat einen Docstring, der zur Signatur passt (L26, alle `src`-Dateien).
- [ ] `UMSTELLUNG.md` und die Options-Tabellen sind aus `regeln.json` erzeugt (`regeln.py --markdown | diff - UMSTELLUNG.md` leer).
- [ ] Archivpakete tragen `ARCHIV.md`; Root-`README.md` beschreibt Zug, Einfrieren und Umstellen.

### Teil 2: Freigabe vollzogen (Phase 9, Schritte 3 bis 6)

- [ ] `linie-0.4` ist in `main`; die vier Workflows sind auf `main` grün.
- [ ] `.github/eingefroren.json` enthält alle Ordner des Zugs und alle älteren Ordner der Zugpakete, kein Ordner trägt mehr `vorlage`; Tag `zug-0.4.1` gesetzt.
- [ ] Die Website zeigt für jedes Zugpaket außer `kern` 0.4.1.

### Teil 3: Umfeld (Abnahme von Phase 10, nach dem Einfrieren)

- [ ] iPad-Kopie enthält die dreizehn Ordner; ein Testdokument kompiliert dort.
- [ ] Die 58 Dokumente auf 0.4.0 sind umgestellt und kompilieren mit 0.4.1; die Bausteinaufrufe darin sind unverändert.
- [ ] eduki: Dokumente und Pins auf 0.4.1, Build grün, `gold.py` über alle 286 Dokumente ausgewertet.
- [ ] `AGENTS.md` in AO nennt 0.4.1, die deutschen Bausteine und die neuen Parameter, Werte und Aktionen.

---

## Anhang: Punkte, die die KONVENTION berühren

Diese Stellen des Plans gehen über den Wortlaut der KONVENTION hinaus und sollten dort nachgetragen oder entschieden werden.

1. **Paketname `kern`** fehlt in der Liste der Paketnamen (2.1) und im Geltungsbereich.
2. **L19 und 7.1** sagen „eigene Namen"; gemeint sein muss „Namen der Zugpakete laut Exportliste", sonst dürfte arbeitsblatt nicht einmal `aufgabe` exportieren. Der Plan liest es so und führt die Exportliste als Datei.
3. **„Aus einer Parametertabelle erzeugt" (A.1)** ist in Typst nicht möglich; der Plan ersetzt es durch handgeschriebene Signaturen plus L17.
4. **Vier neue Lint-Regeln** K1 (kern zustandslos), K2 (`internal`-Vertrag), K3 (Exporte der Zugpakete kollisionsfrei), K4 (Labels und Figure-Kinds sind Schlüssel wie States; L20 nennt nur `state(` und `counter(`).
5. **Abbrechende Funktionen für alte Funktionsnamen.** Erledigt durch die Fassung vom 2026-11-15: KONVENTION 7.1, 9.3 und L19 nennen die Stubs aus `removed.typ` jetzt als Teil der Exporte. Offen bleibt nur Punkt 8 (Re-Export der Stubs).
6. **`internal` als Funktionen statt nackter States** (`get-options()` statt `options-state`): Die KONVENTION nennt als Beispiel `aufgaben.internal.options-state`; der Plan empfiehlt Funktionen, weil sich dann die State-Gestalt ändern kann, ohne dass arbeitsblatt mitgeändert werden muss.
7. **Wörter für `internal`-Namen und Werkzeug-Dateien**: `internal`-Namen sind laut 7.2 von der Glossarpflicht befreit; Skript- und Listennamen im Repo bleiben deutsch wie bisher (`neue-version.sh`, `regeln.json`, `fremdnamen.txt`).
8. **Bausteine und Stubs je Paket.** Die frühere Frage „zwölf Übergangsnamen in jedem Paket" ist mit der Entscheidung vom 2026-11-15 erledigt; L23 (a) regelt den Eigentümer je Baustein. Zu ergänzen ist: Auch die Stubs gehören dem Eigentümerpaket und werden von arbeitsblatt und klassenarbeit re-exportiert, nicht neu gebunden; die Meldung nennt dann das Eigentümerpaket (`aufgaben.show-loesungen: …`), während 9.3 nur `<paket>.<alt>` sagt.
9. **Durchgereichte @schule-Namen.** 7.1 und L19 nennen nur Eigenes, Stubs, `internal`, Fremdnamen (und für klassenarbeit „alles, was arbeitsblatt exportiert"). Der Familien-Re-Export (1.3, `tabelle-arbeitsblatt.md` 4.2) fehlt dort; `tabelle-fachpakete.md` Abschnitt 9 folgert aus 7.1 das Gegenteil.
10. **L12 prüft zu wenig.** Die Prüfmenge nennt cetz, cetz-plot, fontawesome, colorful-boxes, gentle-clues; die im Bestand häufigsten Mitimporte (tablex, unify, blockst, pinit, mannot, metro, codly) und die Nicht-Zugpakete (summify, typstage, abbozza, eduki) fehlen.
11. **L20 und 7.3** regeln nur `state(` und `counter(`. Labels, `metadata`-Marken und `figure(kind:)` sind ebenso geteilte Schlüssel; der Wert von `kind` ist öffentlich und im Glossar nicht geregelt.
12. **L24** vergleicht mit dem „Snapshot der Vorversion"; für den ersten Zug braucht es die Vereinigung mehrerer Altstände (0.2.4, 0.3.2, 0.4.0 …).
13. **A.12 / L18**: Hook-Signaturen sind zur Laufzeit nicht prüfbar; die KONVENTION sollte das sagen und die Parameter der Hooks als Teil der Compat-Tabelle führen (nur Codemod).
14. **9.2 Umfang**: Die Untergrenze der unterstützten Quellversionen (arbeitsblatt 0.2.3 wegen `messwerttabellen`) steht nicht in der KONVENTION.
15. **9.4 Nr. 1** nennt das Heben der Pins als Schritt vor dem Codemod, sagt aber nicht, dass der Rohling zuerst mit unveränderten Pins entsteht.
16. **1.1 Regel 4 / Manifest**: Die KONVENTION sagt nichts zum `compiler`-Feld; die Typist-Version entscheidet über den Wert.
17. **Wortpaare zur Laufzeit.** 8.4 verlangt, dass die Prüfung bei Enum-Werten in `wortpaare.json` nachschlägt. Ein Paket liest nur den eigenen Ordner; der Plan führt deshalb eine Kopie als `wordpairs` in `kern/<zug>/regeln.json` und lässt `regeln.py --pruefen` beide gleich halten (3a).
18. **Paketzahl.** 11.1 spricht von „allen zwölf Paketen"; mit `kern` sind es dreizehn (Punkt 1).
19. **`kern.strict` entfällt.** Mit den Übergangsnamen fällt der einzige Zweck von `--input streng=1` weg; der Plan streicht `strict.typ` aus dem Kernpaket (1.2, 3b). Die KONVENTION sagt das in 9.3 schon; hier nur als Folge für die Dateiliste.

---

## Prüfprotokoll

Zwei Prüfer (Machbarkeit: M1 bis M14; Lücken: L1 bis L21, Nummern in der Reihenfolge der Befundliste) haben die Fassung vom 2026-11-14 geprüft. Jeder Befund wurde gegen Inventar, Tabellen und Quelltext nachgeschlagen. Ergebnis: 35 Befunde, 35 übernommen (davon 5 mit Abweichung von der vorgeschlagenen Korrektur), 0 verworfen. Die Fassung vor der Prüfung liegt unter `scratchpad/arbeit/architektur-release.vor-pruefung.md`.

**Machbarkeit**

| Nr. | Befund (kurz) | Ergebnis |
|---|---|---|
| M1 | Zugregel („Fachpaket überspringt Nummern") widerspricht der Rautenregel, weil jedes Paket `kern` importiert | übernommen: alle dreizehn Pakete bekommen jede Zugnummer; `--geaendert` und `[versionen]` gestrichen (1.1, 2.3, 3e). |
| M2 | Eingecheckte Goldreferenz vom Mac scheitert in CI (Schriften, Typst 0.15.0) | übernommen: bestätigt (`Myriad Pro`, `Futura`, `SF Mono` im Quelltext, `tests.yml` pinnt 0.15.0); keine Referenz mehr, beide Seiten im selben Lauf, S4 nur lokal, Datumszeilen ausgeblendet (4.1). |
| M3 | Phasen 5/6 und 4.8/7 sind über dynamisch durchgereichte Optionen nicht trennbar | übernommen: bestätigt an arbeitsblatt.typ Z. 312–319, 573, 711 und klassenarbeit.typ Z. 25–40; Optionsschnitt als ein Commit 6.1, klausurboegen als 7.1 zusammen mit `klassenarbeit` (7.2); keine Übersetzungsschicht. |
| M4 | Versionsmarke erkennt Pakete vor 0.4.1 nicht | übernommen: Altprüfung über die alten Schlüssel mit Anfangswert `()` in 1.4, R2 berichtigt, Test ergänzt. |
| M5 | 3e-Abnahme 1 ist in Phase 2 nicht erfüllbar | übernommen: Phase 2 prüft nur den Selbsttest am Mini-Repo; die volle Abnahme steht nach Phase 8 und in Abschnitt 8. |
| M6 | `neuer-zug.sh 0.4.1` hebt die Pins schon in 3.1, 3.3 ist dann kein eigener Schritt | übernommen: Modus `--erststart` lässt fremde Pins stehen und führt nur `tests/run.sh` aus; 3.3 hebt mit eigenem Goldlauf. |
| M7 | Einfrier-Prüfung entsteht erst auf dem Zweig, `main` bleibt ungeschützt | übernommen: Phasen 0 und 1 auf `main`, Abzweig danach; Weg für Korrekturen über `bestandskorrektur.sh` und `UMBAU-NOTIZEN.md`. |
| M8 | `rg 'state\(\|counter\('` trifft auch `counter(page)` und `counter(figure…)` | übernommen: bestätigt (5 + 3 + 8 + 7 Treffer); Muster auf Zeichenketten-Schlüssel eingeschränkt, `assert.(eq\|ne)(` ergänzt. |
| M9 | State-Tabelle ohne insert-a-word | übernommen: Zeilen nach `tabelle-fachpakete.md` Abschnitt 5 ergänzt; abweichend vom Vorschlag kein Vertragseintrag, weil `reset-iaword` öffentlich ist. |
| M10 | `gold.py umbau` ohne `--aliase` scheitert unter `streng=1` | übernommen: `--aliase` in 4.1, 3c und im Takt; zusätzlicher Lauf `--ohne-aliase` ohne `streng=1`. Überholt am 2026-11-15: `--aliase`, `--ohne-aliase` und `streng=1` gibt es nicht mehr. |
| M11 | arbeitsblatt kann nicht alle zwölf Übergangsnamen liefern; Neubindung je Paket verletzt K3 | übernommen: Eigentümer je Übergangsname, Re-Export statt Neubindung, arbeitsblatt zehn, klassenarbeit elf (1.3, 3b); KONVENTION-Nachtrag 8. Überholt am 2026-11-15: Es gibt keine Übergangsnamen mehr; geblieben ist die Regel „Eigentümer definiert, andere re-exportieren". |
| M12 | Glob `*/0.4.1` trifft das Submodul `blockst/0.4.1` | übernommen: bestätigt (Ordner existiert); alle Prüfbefehle über `$ZUG_SRC`/`$ZUG` aus `buendel.toml`. |
| M13 | Tree-Hash sieht nur eingecheckte Stände; Submodule liefern Commits | übernommen: Abnahme auf eingecheckte Probeänderung, lokal zusätzlich `git status --porcelain`, Submodule nicht in `eingefroren.json` (2.5, 3e). |
| M14 | `run.sh` rekursiv, kein Vorzug für 0.4.1, random ohne Doku und Karte | übernommen: feste Ordnerliste, Vergleich entfällt ohne `[zug].vorzug`, Karte und `docs/` für random; abweichend keine Karte für `kern` (keine Doku). |

**Lücken**

| Nr. | Befund (kurz) | Ergebnis |
|---|---|---|
| L1 | Widerspruch im Zugmodell (wie M1) | übernommen: Fassung (a), alle dreizehn fahren mit; der vorgeschlagene Test „zwei kern-Versionen" entfällt, weil der Fall im Zug nicht mehr vorkommt. |
| L2 | Altpakete setzen keine Versionsmarke (wie M4), States nicht ganz getrennt | übernommen: Altprüfung mit vier Abfragen, Hinweis auf `reset-aufgaben` und die Figure-Zähler, Test `arbeitsblatt-altpaket.typ`. |
| L3 | Kein Weg für Korrekturen am Bestand während des Umbaus | übernommen: fünf Vorlagenordner mit `bestandskorrektur.sh` (Hash erneuern, Begründung, Übertrag in den Zug, Goldlauf); hart eingefroren erst mit der Freigabe. |
| L4 | Goldreferenz über Maschinen hinweg, fehlende Programme in CI, S4 ohne Schwelle (wie M2) | übernommen: Vergleich im selben Lauf; S4 nur lokal mit Schwelle 0,1 % bei `-fuzz 2%`; Rust-Schritt in `namen.yml`, `poppler-utils` in `tests.yml`; kein eingecheckter Schriftsatz. |
| L5 | Zwischenzustände zwischen den Phasen nicht lauffähig (wie M3) | übernommen: Variante „gemeinsamer Schritt" statt Adapter; Regel „kein Zwischenstand lässt ein Golddokument rot" im Takt. |
| L6 | Definition of Done und Phase 9/10 zirkulär; Einfrieren vor dem ersten echten Dokument | übernommen: DoD in Freigabe, Vollzug und Umfeld geteilt; Probelauf 9.0 (58 Dokumente, eduki-Kopie, iPad) vor dem Einfrieren. |
| L7 | Gesamtschätzung passt nicht zu den Teilgrößen | übernommen: neu gerechnet (rund 60 bis 104 Arbeitstage), Tabelle je Phase, Entscheidungspunkt nach Phase 3 mit Schnitt B, Abbruchkriterium je Phase, R16 berichtigt. |
| L8 | Tabellen für die sieben Fachpakete fehlen | teilweise übernommen: `tabelle-fachpakete.md` (1253 Zeilen, sieben Pakete) liegt inzwischen vor, ein Arbeitspaket der Größe L ist deshalb nicht nötig; übernommen sind der Deckungsabgleich gegen die Snapshots (2.0, 3a Abnahme 2) und der Verweis auf vier Tabellen. |
| L9 | Regeltabelle liegt im eingefrorenen Paket | übernommen: `regeln-codemod.json` außerhalb des Pakets für Codemod-Zusätze; Laufzeit-Einträge im nächsten Zug (2.4, 3a, R19). |
| L10 | Unterstützung breiter versprochen als geprüft (0.2.0–0.2.2, `messwerttabellen`, Stichprobe) | übernommen: Untergrenze arbeitsblatt 0.2.3 (bestätigt: nur 0.2.0–0.2.2 importieren `messwerttabellen`), Klasse B ohne Stichprobe, Snapshots der Altstände, L24 gegen die Vereinigung. |
| L11 | Schwelle 98 % uneinheitlich und ungemessen | übernommen: Basislauf in Phase 1.5; Schwelle „nicht schlechter als der Basislauf" für 0.3.x, 100 % für 0.4.0; „gleich" heißt überall S1 bis S3. |
| L12 | Exportliste widersprüchlich (physik-Bauteile, `default-seed`, iaword-States, blockst) | übernommen: wörtliche Liste nach `tabelle-arbeitsblatt.md` 4.2, vier Festlegungen in 1.3; ob die zap-Bauteile doch durchgereicht werden, bleibt Entscheidung des Autors. |
| L13 | Labels, Metadaten-Marken und Figure-Kinds fehlen in der Schlüsseltabelle | übernommen: Zeilen in 1.4, `keys` in `regeln.json`, Lint-Regel K4, Codemod-Regel für `figure.where`, Golddokument `ab-verweise.typ`. |
| L14 | 3e-Abnahme zur falschen Zeit, Erststart ungeklärt (wie M5, M6) | übernommen: Mini-Repo-Selbsttest, `--erststart` mit `[erststart]`-Tabelle, L24 statt `--vergleich` für den ersten Zug. |
| L15 | Kollisionsschutz deckt die häufigsten Mitimporte nicht | übernommen: `mitimporte.json`, erweiterte L12-Prüfmenge, Codemod-Bericht für jeden Wildcard-Fremdimport, Spalte im Korpus-Bericht (1.3, 3c, R10). |
| L16 | Theme-Prüfung erfasst keine Hook-Signaturen | übernommen: Grenze in 1.5 und R3 benannt; Lambda-Regel im Codemod, Zählung im Korpus, dokumentierte Meldung, Golddokument. |
| L17 | Typist-Version unbekannt, `compiler`-Feld sperrt ältere Compiler, iPad-Test zu spät | übernommen: bestätigt (kein `compiler`-Feld in den drei Kernmanifesten); Feststellung in Phase 0, Probeläufe 3.7 und 9.0, `ipad-abgleich.sh --trocken` (R18). |
| L18 | eduki: `--pins` unbeschrieben, nur 10 von 286 geprüft, Build unbekannt | übernommen: `--pins` in 3c mit Fixtures, `gold.py` über alle 286, Sichtung des Buildskripts in Phase 0, eduki-Umstellung im Teil „Umfeld". |
| L19 | `removed.typ` für Parameter, `bogen` als entfernt, `header-font-size` im Beispiel | übernommen: 7.4 berichtigt (`bogen` → `answer-sheet-pages`), Ausnahme in Abschnitt 7 Nr. 1, JSON-Beispiel angeglichen, `removed` mit `replace` im Codemod. |
| L20 | DoD verlangt Dateien ohne Arbeitspaket (kern-Doku, random-Doku, `show-module`-Listen) | übernommen: `kern` ohne `internal.typ` und `docs.typ`; random-Doku und `show-module`-Listen in 8.3; L26 über alle `src`-Dateien. |
| L21 | Grenze „keine Fehlerkorrekturen" nicht prüfbar | übernommen: `bekannte-fehler.md` mit einer Entscheidung je Inventarbefund (Phase 1.6); `abweichungen.toml` verweist darauf (Abschnitt 7 Nr. 10). |

**Offen geblieben und dem Autor vorzulegen** (Phase 0): Schnitt A oder B; zap-Bauteile über arbeitsblatt durchreichen oder nicht; Wert des `compiler`-Felds nach der Typist-Version; Untergrenze 0.2.3 oder `context`-Regeln für `messwerttabelle`; Umgang mit dem Dateinamen-Fehler bei content-Titel (7.5); ob `bogen:` in 0.4.1 zurückkommt (KONVENTION 11.4, früher 11.6).

**2026-11-15: Entscheidung deutsche Bausteine eingearbeitet.** Der Autor hat entschieden (KONVENTION, Kasten am Anfang; frühere offene Punkte 11.1 und 11.3), dass die Bausteine auf Dauer nur deutsch heißen (`arbeitsblatt`, `klassenarbeit`, `aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung`, `lsg`, `luecke`, `kariert`, `liniert`, `klausurboegen`, dazu `arbeitsblatt-einzeln` und die Fachbausteine) und dass es weder englische Zwillinge noch einen Aliasblock gibt; alles in den Klammern sowie Aktionen, Abfragen und Helfer bleiben englisch wie ausgearbeitet. In diesem Plan tragen deshalb alle Signaturen, Exportlisten, Fehlerpräfixe, Tests und das JSON-Beispiel in 3a die deutschen Funktionsnamen; gestrichen sind die Übergangsnamen, `kern.strict` und `--input streng=1`, der Codemod-Schalter `--aliase`, der Goldlauf `--ohne-aliase`, der Test `aliase.typ` und der Eintrag `task` in `kollisionen-erlaubt.txt`. Neu sind die Listen `bausteine-de.txt`, `wortpaare.json` und `zwillinge.txt`, die Lint-Regeln L23 „Bausteinliste" und L27 „Sprachtrennung", die Tests `bausteine.typ` und `zwilling.typ`, zwei Meldungsarten (alter Funktionsname, deutscher Bausteinname als Wert), die Risiken R20 bis R22 und drei Nachträge im Anhang (17 bis 19). Der Codemod benennt nur noch die Funktionen aus KONVENTION 9.3 um (`lücke` → `luecke` unter Bedingung, `klausurbögen` → `klausurboegen`, `häufigkeitsanalyse`, sechs Regressionen, dazu die englisch werdenden Helfer und Aktionen); die rund 5100 Ersetzungen von `aufgabe` und `teilaufgabe` entfallen. Neu gerechnet sind nur 5.3 (S bis M statt M) und 8.3 (1 bis 3 statt 1 bis 5 Tage), die Summe sinkt von rund 60 bis 104 auf rund 59 bis 102 Arbeitstage (genau 59,5 bis 103,5 auf 59 bis 101,5); alle übrigen Größen bleiben, weil der Funktionsname dort der kleinste Teil der Arbeit war. Dabei berichtigt: Die Teilgrößen-Spalte von Phase 8 nannte „3 M", gerechnet waren schon vorher 2 M. Nicht nachgezogen sind in diesem Schritt die vier `tabelle-*.md` und `prototyp-regeln.json` (eigene Arbeitsschritte; R22).

**2026-11-15: Nachprüfung nach der Entscheidung deutsche Bausteine.** Ein Prüfer meldete zehn Befunde; neun sind berechtigt und eingearbeitet, der zehnte war die Gegenprobe ohne Befund. (1) M3 nannte noch `exam` als Funktion; jetzt `klassenarbeit` (7.2). (2) Der Stub `tasks` → `teilaufgaben` gehört arbeitsblatt (Quelltext `arbeitsblatt/0.4.0/src/arbeitsblatt.typ` Z. 1263, tabelle-aufgaben 1.3, tabelle-arbeitsblatt 1.10): in 1.3 zu den eigenen Stubs verschoben, im Testplan von aufgaben nach arbeitsblatt, in den Schritten von 5.3 nach 6.6. (3) `tasks` aus den Codemod-Zusätzen „vor den Vorlagenständen" gestrichen; der Name hat einen Laufzeit-Stub in `regeln.json`. (4) 5.3: `material` ist sprachgleich und kein Baustein, entfallen wäre die Umbenennung von fünf Funktionen, `points` ist kein benannter Parameter; der Umzug von `teilaufgaben` aus arbeitsblatt nach aufgaben steht jetzt im Schritt. (5) Aufwand Phase 5 ist 2 bis 4,5 Tage, die Summe 59 bis 101,5, also rund 59 bis 102 Arbeitstage. (6) Die Datei mit der Seitenvorlage heißt `src/arbeitsblatt.typ`, nicht `worksheet.typ`; `worksheet` bleibt damit im ganzen Plan Parameterwort. (7) „Baustein" steht nur noch für Funktionen aus `bausteine-de.txt`: Teilskript, Teile, Funktion `example`; das Golddokument heißt `ab-elemente.typ`. (8) `task-marker-width` ist Wert-Schlüssel, kein Hook. (9) 7.4 nennt klausurboegen als Eigentümer der drei Stubs. Nichts verworfen. Der Hinweis zu konvention.md (Folgearbeit-Absatz in Abschnitt 11 führt `architektur-release.md` noch als nicht nachgezogen) ist dem Autor gemeldet; konvention.md wurde nicht geändert.
