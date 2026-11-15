# Gutachten Migration: Konventionen A (Deutsch), B (Englisch), C (Regel-Hybrid)

Stand 2026-11-14. Blickwinkel: nur Migration. Kriterien: Anteil geänderter Aufrufstellen, Automatisierbarkeit per Codemod, Verwechslungsgefahr alt/neu, Aufwand für Doku/Beispiele/Tests/Themes, Risiko stiller Fehlverhalten, Rückwärtskompatibilität über die Compat-Tabelle. Ob Deutsch oder Englisch "schöner" ist, bewerte ich nicht.

Grundlage: die drei Entwürfe vollständig, `inventar/nutzung-ausserhalb.md`, `inventar/nutzung-im-repo.md`, `inventar/typst-technik.md`, `technik/codemod.py`, `technik/regeln.json`. Zusätzlich habe ich vier Stellen im Quelltext nachgelesen (nur lesend), weil alle drei Entwürfe sie als ungeprüft markieren oder falsch beschreiben: `aufgaben/0.3.1/aufgaben.typ` Z. 1075–1100, 1268–1295, 1315–1330 und `arbeitsblatt/0.4.0/src/arbeitsblatt.typ` Z. 283, 456–465, 705–716, 928, 1361.

## Ergebnis

| Entwurf | Punkte | Kurzurteil |
|---|---|---|
| **B Englisch** | **7,0** | Geringste Zahl geänderter Stellen, flachste Compat-Tabelle. Drei stille Brüche an Außenschnittstellen und ein Lint, der an den eigenen Signaturen scheitert. |
| A Deutsch | 5,5 | Größtes Volumen, aber fast nur 1:1-Umbenennungen und alt/neu auf einen Blick unterscheidbar. Zwei stille Layoutänderungen durch geänderte Vorgaben, eine Lücke bei Durchreich-Sinks. |
| C Regel-Hybrid | 3,5 | Mittleres Volumen, aber die meisten Struktur-, Typ- und Wertumkehrungen und die meisten Namen, die bleiben und etwas anderes bedeuten. |

Sieger aus Migrationssicht: **B**. Der Vorsprung ist kleiner, als die Prozentzahlen nahelegen (siehe "Einordnung").

## Befunde am Code, die alle drei Entwürfe betreffen

1. **`materialien: "seiten"` ist in allen drei Entwürfen falsch beschrieben.** Alle bilden den Wert auf `"einzelseiten"` bzw. `"page-per-task"` ab und erklären ihn als "am Dokumentende, je Aufgabe eine eigene Seite". Im Code (`aufgaben.typ` 1076–1080) wird Material bei `"seiten"` direkt nach der jeweiligen Aufgabe ausgegeben, davor `pagebreak(weak: true)`; am Dokumentende läuft nur `"seite"` und `"reinquetschen"` (`arbeitsblatt.typ` 711). `"seiten"` ist der Vorgabewert. Wer das neue Schema nach der Beschreibung baut, verschiebt in jedem Dokument mit Material die Ausgabe ans Ende, ohne Fehlermeldung.
2. **`custom-header: none` heißt heute "Standardkopf"** (`arbeitsblatt.typ` 456–465). In allen drei Entwürfen heißt `none` beim Nachfolger (`kopf`/`header`) "kein Kopf", der Standard wird `auto`. Eine reine Namensregel im Codemod macht aus `custom-header: none` ein Blatt ohne Kopf. Die Regel muss den Wert mit abbilden (`none` → Argument löschen). Keiner der Entwürfe nennt das in der Liste der nicht mechanischen Fälle.
3. **`"keine-summe"`** zeigt Punkte an Teilaufgaben und an Aufgaben nur, wenn sie keine Teilaufgaben haben (`aufgaben.typ` 1093–1100, 1191, 1221). B trifft das mit `"leaf"`. A (`anzeige: "alle", summe: false`) ist vertretbar, wenn `summe` die Aufgabensumme meint; im Entwurf steht das nicht. C (`anzeige: "aufgaben", summe: false`) ist falsch: es würde die Teilaufgabenpunkte ausblenden.
4. **`"sofort"` / `"folgend"` bei Lösungen**: `"sofort"` gibt nach jeder Teilaufgabe aus, `"folgend"` gesammelt nach der Aufgabe (1083–1089, 1272). A (`"direkt"` / `"aufgabe"`) und B (`"in-place"` / `"after-task"`) stimmen; die `[prüfen]`-Marken in A können weg.
5. **Tests sehen Layout nicht.** `tests/run.sh` vergleicht nur PDF-Text. Jede Wertumkehr und jede geänderte Vorgabe ist für die Tests unsichtbar.

## A Deutsch: 5,5

Volumen (Zahlen des Entwurfs, plausibel): 89 % der Kopfparameter, 96 % der `aufgabe`/`teilaufgabe`-Aufrufe, alle 1575 `minipage`, rund 20 000 Stellen bei vollständiger Anhebung, rund 5500 für die 360 Dokumente auf 0.3.x/0.4.0.

Stärken:
- Der heiße Pfad ist reine Wortersetzung: `title`→`titel`, `class`→`klasse`, `large`→`gross`, `number`→`nummeriert`, `workspace`→`arbeitsflaeche`, `minipage`→`nebeneinander`. Keine Typwechsel, keine Umkehr. Das kann `codemod.py` schon heute.
- Fast alles, was sich ändert, bekommt einen neuen Namen. Ein Dokument ist sichtbar alt oder neu; "gleicher Name, andere Bedeutung" kommt kaum vor.
- Das Theme-Dictionary aus 0.4.0 ist schon deutsch (`schrift`, `rand`, `kopf`, `fuss`, `marke`, `kasten`, `art`, `farbe`). A ändert dort am wenigsten; `<ab-meta>` (`titel`, `klasse`, `fach`) und `sys.inputs.vorschau` bleiben, externe Leser brechen nicht.
- Die 342 Altaufrufe `aufgabe(titel:)` passen ohne Änderung.

Abzüge:
- **Stille Layoutänderung 1:** `nebeneinander(abstand: 1.25em)` statt `minipage(spacing: 5mm)` (`arbeitsblatt.typ` 1361). 1575 Aufrufe bekommen einen anderen Spaltenabstand, Umbrüche können wandern.
- **Stille Layoutänderung 2:** `liniert(linienabstand: 8mm)` statt 1 cm. 259 Aufrufe verlieren 20 % Höhe. Im Entwurf nur als "[Vorgabe festlegen]" markiert.
- **Lücke bei Durchreich-Sinks:** `teilaufgaben(..eintraege)` und `nebeneinander(..inhalte)` reichen benannte Unbekannte an `table` weiter. Die alten Namen `columns` (36), `gutter` (14), `align` sind gültige `table`-Argumente; ein vom Codemod übersehenes `columns: 2` landet in der Tabelle statt eine "heißt jetzt"-Meldung auszulösen. Ebenso `qr-kasten(width:)` (66) → `stickybox`. Die Compat-Tabelle muss vor dem Durchreichen laufen; das steht nirgends.
- Nicht mechanisch: `aufgabe[Titel][Rumpf]` entfällt (Anteil an den 273 klammerlosen Aufrufen ungezählt), `lies-punkte` macht ein Positionsargument benannt (Sink kann Positionsargumente nicht abfangen), drei umgekehrte Schalter, `scale`→Länge, `teilaufgaben(tasks:)`→Spread.
- State-Schlüssel: nur der Variablenname ist genannt (`_zustand-optionen`), kein versionierter Schlüsselstring. Solange `mathematik` aufgaben 0.1.2 pinnt, teilen sich alt und neu `state("options")`.
- Doku, Templates, Tests, `AGENTS.md`: alles neu. Der Entwurf sagt selbst, dass 0.5.0 ehrlicher wäre als 0.4.1.

## B Englisch: 7,0

Volumen: rund 975 von 8530 Kopfparametern bei arbeitsblatt (11 %), 385 von 1460 bei klassenarbeit (26 %), mit Alias etwa 34 von 5100 `aufgabe`/`teilaufgabe`-Aufrufen. Feste Mindestkosten rund 400 Aufrufe (`qrbox`, `lücke`, `non-print-pagebreak`, `teilaufgaben`).

Stärken:
- Mit Abstand die wenigsten Stellen. Ein Kopf nur mit `class, title, font-size, paper, print, workspaces` braucht nur die neue Versionsnummer.
- Flachste Compat-Tabelle: "kein String-oder-Dictionary", `points-position` und `points-format` als Geschwister. Jede Regel ist `name → name` plus Wertliste.
- Durchreich-Sinks sind ungefährlich, weil die durchgereichten Namen (`columns`, `gutter`, `align`) gleich bleiben.
- Versionierte State-Schlüssel (`"schule/tasks/options@1"`) sind ausformuliert.

Abzüge:
- **Die 11 % sind zu niedrig gerechnet.** Nicht mitgezählt: `""` → `none` als Pflicht (`subtitle`, `date`, `teacher` in 106–107 Köpfen, viele davon vermutlich leer; ob `""` weiter angenommen wird, bleibt offen), die Wertänderung in jedem `loesungen:`-Vorkommen (483), Variantennamen in 113 Köpfen samt Override-Schlüsseln.
- **Die billigen Stellen sind die leichten, die teuren bleiben.** Was B ändert, sind Enum-Werte, Dictionary-Schlüssel (`erwartungen: (erreicht:)`, `klausurboegen: (…)`) und Variantennamen. Genau dafür reicht der Regex-Codemod nicht; es braucht das AST-Werkzeug.
- **Stiller Bruch 1:** `sys.inputs.vorschau == "alle"` → `preview == "all"`. Die VS-Code-Einstellung `tinymist.preview.sysInputs` und jedes Build-Skript mit `--input vorschau=alle` laufen weiter, zeigen aber nur noch eine Variante.
- **Stiller Bruch 2:** Bundle-Dateinamen mit englischen Variantennamen (`-loesung.pdf` → `-solutions.pdf`). Wer in eduki oder im Klassenarchiv auf die Dateien verweist, bekommt tote Verweise.
- **Stiller Bruch 3:** `<ab-meta>` → `<schule-worksheet-meta>` mit englischen Schlüsseln. Externe Leser finden kein Label und liefern leere Metadaten. Der Entwurf nennt das (8.13), entscheidet es aber nicht.
- **Höchster Aufwand im Paket selbst.** Jede deutsche Funktion wird intern umbenannt, das komplette Theme-Dictionary der frischen 0.4.0-Arbeit (8 Themes, Showcase, die offene Änderung an `themes.typ`) wird übersetzt, alle Enum-Werte, alle Assert-Texte. Die Doku muss zwölf Doppelnamen führen.
- Alt und neu sehen sich sehr ähnlich. Ob ein Dokument migriert ist, sieht man nur an der Versionsnummer; die "heißt jetzt"-Meldung muss das tragen.
- Der niedrige Preis hängt an den dauerhaften Aliasen. Ohne sie sind es 100 % der 5100 Aufrufe.

## C Regel-Hybrid: 3,5

Volumen: 45–52 % der Kopfparameter, mindestens 91 % der `aufgabe`/`teilaufgabe`-Aufrufe, 2573 umbenannte Funktionsaufrufe. Im Inhalt kaum billiger als A.

Abzüge:
- **Wertumkehr auf dem heißen Pfad:** `large: true` → `kompakt: false` an 1933 Stellen, im Theme-Hook ebenso. Ein Fehler in dieser einen Regel verändert jede Aufgabenüberschrift, und der Textvergleich der Tests bemerkt es nicht.
- **Typwechsel auf dem heißen Pfad:** `number: true|false` → `numbering: auto|none` (1710 Stellen).
- **Bool → `auto`/`none` ohne Namensgewinn:** `erwartungen: true/false` (96 Köpfe) und `klausurboegen` (91) müssen ihre Werte ändern, nur wegen Regel L7.
- **Gleicher Name, andere Bedeutung:**
  - `numbering` ist im Kopf das Teilaufgabenmuster, bei `aufgabe` der Schalter "mit Nummer", bei `teilaufgaben` und `klausurboegen` wieder das Muster. Im Kopf einer Dokumentvorlage liest man `numbering` als Seitennummerierung.
  - `kariert(width:)` bleibt als Name, wechselt von Kästchenzahl zu Länge. Die Spaltenzahl ist gar nicht mehr ausdrückbar (20 Aufrufe plus alle `kariert(4, 12)`).
  - `loesungen` und `materialien` sind zugleich Kopfparameter, Funktionen und (bei `teilaufgaben`) ein Array. Der Entwurf räumt ein, dass der Parameter die Funktion innerhalb von `arbeitsblatt` verdeckt.
  - `nummer` ist bei `teilaufgabe` eine frei gesetzte Marke (content), im Hook eine Zahl.
- **Strukturwechsel flach → geschachtelt:** `rand`, `line-stroke`, `weißer-rand` → `korrekturrand: (width:, stroke:, frei:)`, `page-settings` → `page`, `schrift.*` flach. Das kann eine `name → name`-Tabelle nicht ausdrücken; Codemod und Compat brauchen Sonderfälle, der Signatur-Snapshot sieht die Schlüssel nicht (8.8).
- `"keine-summe"` falsch abgebildet (siehe oben). `row-gutter` geht verloren. `gestaltung: none` entfällt, obwohl es heute der Vorgabewert von `theme` ist.
- `symbol`/`symbole` und `page` überdecken Typst-Namen; A verbietet genau das mit Begründung.
- Positiv: keine Durchreich-Sinks (L9), `inset`/`align` deklariert; `minipage`-Abstand bleibt 5 mm; versionierte State-Schlüssel.

## Einordnung des Vorsprungs von B

Kein Bestandsdokument bricht, weil alles gepinnt ist. Gehoben werden realistisch die rund 360 Dokumente auf 0.3.x/0.4.0. Für diese Menge sind auch A's rund 5500 Stellen ein Codemod-Lauf von Sekunden. Entscheidend ist deshalb weniger das Volumen als der nicht mechanische Rest und das, was still schiefgeht. Dort liegt B vor C, aber nur knapp vor A: A hat zwei geänderte Vorgaben und die Sink-Lücke (alle drei mit je einer Zeile behebbar), B hat drei Brüche an Außenschnittstellen (behebbar, wenn `vorschau`, Dateinamen und `<ab-meta>` deutsch bleiben). Wer B wählt, sollte genau diese drei Dinge aus der Übersetzung herausnehmen.

Zu bedenken außerhalb meines Kriteriums: Alles, was der Autor zuletzt selbst neu gebaut hat (Themes 0.4.0, klausurboegen 0.0.5 mit `muster`, `linienabstand`, `korrekturrand`, die Metadaten), ist deutsch. B übersetzt genau diese jüngste Arbeit zurück.

## Regelverstöße und Lücken im Sieger B

1. **Das Lint scheitert an B's eigenen Signaturen.** In `words-en.txt` fehlen `figure` (`figure-font-size`), `field` (`name-field`), `repeat` (`name-repeat`), `current` (`show-solutions(current:)`), `pages` (`sheet-pages`), `names`, `preprint`, `values`, `deprecated`, `args`, dazu fast alle Wörter aus 5.14 (`dataset`, `regression`, `circuit`, `frequency`, `degree`, `seed`, `word`, `bank`, `labels`).
2. **`rand` steht auf der Negativliste `words-de.txt`**, zugleich soll `random.rand` bleiben (5.14). Ebenso sind `art`, `stand`, `note`, `alle` englische Wörter bzw. Wortteile.
3. **`subject-color`, `subject-colors`** verletzen R4 ("kein Typ im Namen: `-color`").
4. **`parse-class`** benutzt ein Verb außerhalb der Liste aus R8 (`show set reset get has is format`).
5. **`number` hat zwei Typen:** bool in `task(number: true)`, `int | none` im Hook `task: (number: 1, …)`. Verstoß gegen R11 und eine Falle für Theme-Autoren.
6. **`solutions` hat drei Bedeutungen:** Ort im Kopf, Array in `subtasks(solutions:)`, Filter in `print-pagebreak(solutions: "only")`.
7. **`exam` dreifach:** neue Funktion, alter Parameter von `klausurbögen` (= Titel), Enum-Wert von `kind`.
8. **`points-format: f | (task:, subtask:)`** widerspricht der eigenen Festlegung "kein String oder Dictionary" dem Geist nach; als Ausnahme benannt, aber nicht begründet.
9. **Bestandsschutz gegen "Typst-Vokabular zuerst"** bei `landscape`, `page-settings`, `number` (eingeräumt in 8.10); die Regel ist damit nicht ohne Ermessen prüfbar, wie Abschnitt 1 behauptet.
10. **Aufwandsrechnung unvollständig:** `""` → `none`, Wertänderungen, Variantennamen und Override-Schlüssel fehlen in den 11 %.
11. **`custom-header: none` → `header: none`** kehrt die Bedeutung um; fehlt in der Regelliste.
12. **`materials: "page-per-task"`** ist gegen den Code falsch beschrieben (siehe oben).
13. **Alias-Mischbild im Wert:** `workspace: kariert(4)` (Alias) neben `answer-sheets: (pattern: "squares")`; für `"kariert"` als Wert gibt es keinen Alias, also zwei Wörter für dasselbe Muster im selben Dokument.
14. **Altname `stufe` im klassenarbeit-Kopf (80 Köpfe aus älteren Versionen)** ist nicht aufgelöst: Er steuerte dort den Notenschlüssel; eine Regel `stufe` → `stage` würde ihn zum Metadatum machen, und der Bogen fiele still auf `"sek-2"` zurück. Braucht eine eigene Regel (→ `answer-sheets: (stage: …)`) oder "entfernt"-Meldung. Gilt für A und C genauso, dort sogar ohne Namenswechsel.
15. **Keine Entscheidung zu 0.4.1 gegen 0.5.0**, obwohl 0.4.1 für die 58 Dokumente auf 0.4.0 hart bricht.

## Aus A und C übernehmen

- **A: Export-Disziplin R7 mit `fremdfunktionen.txt`** (erlaubte Fremdnamen als geprüfte Liste) und das Verbot, Typst-Builtins zu überdecken (R5).
- **A: Umlaut-Faltung in der Fehlermeldung** (`lösungen` → "schreibt sich `loesungen`"); für B sinngemäß bei den zwölf Aliasen.
- **A: Levenshtein-Abstand 1 innerhalb einer Signatur oder Werteliste als Lint-Fehler** (allgemeiner als B's Plural-`s`-Regel).
- **A: gezielte Meldung für das falsche "aus"** (`loesungen: false` → "schreibe `none`") statt der allgemeinen Werteliste.
- **A: `seitenumbruch(druck:, loesung:)` als eine Funktion** statt zweier, die sich nur durch eine Verneinung unterscheiden; in B wäre das `pagebreak-if(print:, solutions:)` o. ä.
- **A: deutsche Schnittstellen nach außen lassen** (`<ab-meta>`-Schlüssel, `vorschau=alle`, Variantennamen in Dateinamen).
- **C: keine Durchreich-Sinks (L9)**; `inset`, `align` deklarieren, Sink nur für Altnamen oder Positionslisten. Schließt die Lücke aus A grundsätzlich.
- **C: L10** (Schlüssel des Options-States = Kopfparameter gleichen Namens) und **L5** (gleicher Parametername → gleicher Typ) als Lint.
- **C: Durchreichtest** als Aufnahmekriterium für Typst-Wörter; B kann damit seine Bestandsschutz-Ausnahmen begründen oder streichen.
- **C: Kurzform-Regel "String = Wert des ersten Schlüssels"** nur dann, falls doch ein Dictionary bleibt.
- Nicht übernehmen: C's `large` → `kompakt`, `number` → `numbering`, bool → `auto`/`none`; A's geänderte Vorgaben für `abstand` und `linienabstand`.

## Was für jede Variante vor dem ersten Codemod-Lauf nötig ist

1. `regeln.json` um Wertregeln mit Kontext erweitern (`custom-header: none` → löschen; Material-Werte getrennt von Lösungs-Werten).
2. AST-Werkzeug (`astdump`) statt Regex für Dictionary-Schlüssel, `set-options`, Variantennamen.
3. Compat-Tabelle auch an Options-Dictionaries und vor jedem Durchreichen an `table`/`stickybox`/zebra.
4. Tests: Version parametrisieren, je Altname ein `// fehler:`-Test, mindestens Seitenzahl-Vergleich vorher/nachher an 20–30 echten Dokumenten, weil der Textvergleich Layout nicht sieht.
5. Äste klausurboegen 0.0.4/0.0.5 zusammenführen und Pins heben, bevor umbenannt wird; sonst zwei Regeltabellen.

## Entscheidungen, die nur der Autor treffen kann

1. Versionsnummer: 0.4.1 (bricht für die 58 Dokumente auf 0.4.0 trotz gleicher Linie) oder 0.5.0.
2. Sollen überhaupt Bestandsdokumente gehoben werden, und welche: nur die rund 360 auf 0.3.x/0.4.0, oder nur bei Wiederverwendung? Davon hängt ab, wie viel der Volumenvorteil von B wert ist.
3. Alte Namen: harter Fehler mit "heißt jetzt" oder stille Annahme mit `--input streng=1`? Bei B zusätzlich: Aliase dauerhaft oder befristet.
4. Bleiben die Außenschnittstellen deutsch (`<ab-meta>`-Schlüssel, `vorschau=alle`, Variantennamen in PDF-Dateinamen), auch wenn die API englisch wird?
5. Dürfen sich Vorgaben ändern (`minipage`-Abstand 5 mm, `liniert` 1 cm, `figure-font-size` 9 pt, `logo: "angela"`), oder gilt "gleiches Dokument, gleiches PDF" als Abnahmekriterium?
6. Was soll `materialien: "seiten"` künftig bedeuten: wie heute (nach jeder Aufgabe, neue Seite) oder wie in den Entwürfen beschrieben (am Dokumentende)?
7. Bleibt `aufgabe[Titel][Rumpf]` erlaubt (B) oder entfällt es (A, C)? Der Anteil an den 273 klammerlosen Aufrufen ist nicht gezählt.
8. Wildcard-Re-Export kappen: Welche Fremdnamen (`stickybox` 45 Aufrufe, `canvas`, `draw`, `fa-*`, `qty`) bleiben sichtbar? Das bricht beim Anheben unabhängig von der Sprache.
9. Altname `stufe` im klassenarbeit-Kopf: auf den Notenschlüssel des Bogens abbilden oder als entfernt melden?
10. Die zuletzt deutsch gebauten Teile (Theme-Dictionary, klausurboegen 0.0.5, Metadaten): mit übersetzen (B konsequent) oder als deutsche Insel stehen lassen?
