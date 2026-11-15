# Urteil aus Sicht der Lehrkraft (Alltagsnutzung, iPad, Kollegium ohne Typst-Vorwissen)

Stand 2026-11-14. Gelesen: die drei Konventionsentwürfe vollständig, `inventar/nutzung-ausserhalb.md` vollständig, `inventar/nutzung-im-repo.md` in Auszügen (Kurzfassung und Häufigkeitstabelle). Die übrigen zehn Inventare habe ich nicht gegengelesen; Aussagen über heutige Signaturen stammen aus den Entwürfen selbst und sind nicht am Code geprüft.

Kriterien: (1) Merkbarkeit ohne Nachschlagen, (2) Vorhersagbarkeit, (3) Tippaufwand, (4) Lesbarkeit des Dokumentkopfs, (5) Verträglichkeit mit Typst-Doku und Autovervollständigung neben `table`, `grid`, `text`.

## Ergebnis

| Entwurf | Punkte | Kurzurteil |
|---|---|---|
| A Deutsch zuerst | 6,0 | am besten vorhersagbar, aber am meisten Tipparbeit und ein täglicher Sprachwechsel an der Typst-Grenze |
| B Englisch zuerst | 5,0 | am wenigsten Tipparbeit und beste Typst-Nähe, aber die Schulbegriffe muss ich im eigenen Glossar nachschlagen |
| C Regel-Hybrid | 6,5 | trifft, wie ich tatsächlich denke (Layout in Typst-Wörtern, Schule auf Deutsch), hat aber die meisten handwerklichen Fehler im Detail |

**Sieger: C, knapp und nur mit den unten genannten Korrekturen.** Ohne sie läge A vorn.

## Derselbe Kopf in drei Fassungen

```typ
// A
#show: arbeitsblatt.with(titel: "Brüche", klasse: "MA-05", schriftgroesse: 11pt,
  papier: "a4", druck: true, arbeitsflaechen: false, loesungen: "einzelseiten")
// B
#show: arbeitsblatt.with(title: "Brüche", class: "MA-05", font-size: 11pt,
  paper: "a4", print: true, workspaces: false, solutions: "page-per-task")
// C
#show: arbeitsblatt.with(title: "Brüche", klasse: "MA-05", font-size: 11pt,
  paper: "a4", druck: true, arbeitsflaechen: false, loesungen: "einzelseiten")
```

Und die häufigste Zeile überhaupt (2480 Aufrufe `teilaufgabe`, 2435 davon mit Arbeitsfläche):

```typ
#teilaufgabe(arbeitsflaeche: kariert(4))[...]   // A und C: 14 Zeichen statt 9
#teilaufgabe(workspace: kariert(4))[...]        // B mit Alias: unverändert
```

## A: Deutsch zuerst (6,0)

Stärken
- Eine Regel, die auch eine Kollegin ohne Typst-Kenntnis anwenden kann: Es ist immer das deutsche Wort. `titel`, `klasse`, `datum`, `lehrkraft`, `druck`, `querformat` rate ich richtig, ohne nachzusehen.
- Die Kästen heißen, wie sie im PDF heißen: `merke`, `tipp`, `achtung`, `beispiel`. Das ist die beste Einzelidee für das Kollegium.
- Saubere Wertekonvention: `klausurboegen: false | true | (…)` und `erwartungen: true | false | (…)` sind genau das, was man erwartet.
- R5 (keine Überdeckung von Typst-Namen) und die Levenshtein-Regel gegen `variante`/`varianten` und `"seite"`/`"seiten"`.
- Ehrlichste Kostenrechnung (89 % der Kopfparameter, 96 % der Aufgabenaufrufe).

Schwächen
- Tippaufwand an den häufigsten Stellen: `arbeitsflaeche` (rund 3500-mal), `schriftgroesse` (1133 Köpfe mit `font-size`), `teilaufgaben-nummerierung`, `beschriftungsgroesse`, `kaestchengroesse`, `setze-aufgaben-zurueck`. Auf dem iPad sind das lange Wörter mit `ae/oe/ue`, die die Autokorrektur gern „repariert“.
- Täglicher Sprachwechsel im selben Dokument: `#nebeneinander(breiten: 2)` neben `#grid(columns: 2)`, `kariert(hoehe: 3cm)` neben `#image(height: 3cm)`. Die Typst-Autovervollständigung und die Typst-Doku helfen mir bei `breite`, `ausrichtung`, `linie`, `hintergrund` nicht; ich muss zwei Vokabulare für dieselbe Sache vorhalten.
- Die Regel ist an der Durchreichgrenze nicht vorhersagbar: `#teilaufgaben(spalten: 2, inset: 5pt)`, `#qr-kasten(breite: 3cm, rotation: 5deg)`, `seite: (margin: 1cm)`, `versatz: (dx: …)`. Ob ein Argument deklariert (deutsch) oder durchgereicht (englisch) ist, sehe ich dem Aufruf nicht an.
- Übersetzungen, die Typst-Kenner in die Irre führen: `anker` statt `label` (in Typst schreibe ich weiter `<name>` und `@name`), `linie` für `stroke`, `hintergrund` für `fill`, `inhalt` für `body`.
- Eigener Regelbruch: `nebeneinander(breiten: auto | Anzahl | Liste)` nimmt eine Anzahl unter dem Wort „Breiten“, obwohl 3.4 sagt, Anzahlen heißen `spalten`. `kariert(4, 12)` meint Zeilen und Spalten, `liniert(4, 5cm)` Zeilen und Breite.
- `loesungen: "direkt" | "aufgabe"` ersetzt die eingeführten `"sofort"`/`"folgend"` ohne Not (und ist als [prüfen] markiert); `loesungen: "aufgabe"` neben `punkte: "aufgaben"` ist ein neuer Ein-Buchstaben-Abstand über Optionen hinweg.
- Imperative `zeige-loesungen`, `setze-optionen`, `lies-punkte` lesen sich wie Scratch, nicht wie Deutsch.
- Größter Bruch mit dem eigenen Muskelgedächtnis: `title`, `class`, `font-size`, `paper`, `print`, `large`, `number`, `workspace` ändern sich alle.

## B: Englisch zuerst (5,0)

Stärken
- Kürzeste Namen, geringster Umbau (rund 11 % der Kopfparameter, unter 1 % der Aufgabenaufrufe mit Alias). Was ich seit 1300 Dokumenten tippe, bleibt: `title`, `class`, `font-size`, `paper`, `print`, `workspace`, `large`, `number`.
- Beste Nähe zu Typst: `columns`, `gutter`, `inset`, `fill`, `stroke`, `caption`, `label`, `breakable` heißen wie dort; die Typst-Doku gilt weiter.
- Flache Geschwister statt „String oder Dictionary“: `points`, `points-position`, `points-format`. Das ist auf dem iPad leichter zu tippen und erscheint in der Signatur-Doku.
- Gute Detailregeln: leerer Text ist `none`, `logo: auto`, versionierte State-Schlüssel, Kollisionslint gegen `std`/cetz/gentle-clues.

Schwächen
- Genau die Namen, die heute schon gutes Deutsch und unstrittig sind, werden übersetzt: `loesungen` (483 Köpfe), `erwartungen` (96), `klausurboegen` (91), `varianten` (113), `dateiname`, `punkte`. Der Entwurf repariert, was nicht kaputt ist.
- Die Schulbegriffe sind Erfindungen, die ich nachschlagen müsste: `expectations`, `answer-sheets`, `correction-margin`, `correction-side`, `proposal`, `continuation`, `overprint`, `two-up`, `show-pending-solutions`, `level: "consolidation"`, `kind: "stations"`, `revision`, `grades` (Jahrgänge, nicht Noten).
- Werte werden länger und fremder: `loesungen: "seiten"` wird `solutions: "page-per-task"`, `"reinquetschen"` wird `"appended"`, `"keine-summe"` wird `"leaf"` (Informatikerjargon).
- Die zwölf Aliase erhalten das Mischbild, das weg soll: `#show: arbeitsblatt.with(solutions: "in-place")`, `#teilaufgaben(items: …, solutions: …)`, `#klausurboegen(correction-side: "outside")`. Für das Kollegium ist nicht vorhersagbar, dass `aufgabe` geht, `loesungen:` aber nicht. Zwei Namen für dieselbe Funktion in Doku, Beispielen und Fehlermeldungen.
- Paketname und Funktion fallen auseinander (`@schule/arbeitsblatt` → `worksheet`).
- Eigene Regelbrüche: `number` ist in `task` ein bool und im Theme-Hook `int | none`; `points` ist Kopf-Auswahl, Zahl in `expectation(points: 0)` und Argument von `format-points`; `task[Titel][Rumpf]` und `subtasks(items: …)` behalten je zwei Wege; `stage: "sek-1"` und Theme-Namen bleiben deutsch; `landscape` gegen Typsts `flipped`.
- Englische Allerweltswörter (`task`, `lines`, `squares`, `blank`, `exam`, `points`) stoßen bei 1474 `: *`-Importen leichter mit eigenen Variablen zusammen.
- Englische Metadatenschlüssel brechen externe Leser von `<ab-meta>`.
- Der Hauptnutzen (Veröffentlichung) wird nach eigener Aussage von niemandem abgerufen.

## C: Regel-Hybrid (6,5)

Stärken
- Die Regel entspricht meiner Praxis: Wo ich ohnehin Typst schreibe, heißt es wie in Typst (`columns`, `width`, `height`, `gutter`, `fill`, `stroke`, `align`, `inset`, `caption`, `label`, `paper`, `font`). Die Typst-Autovervollständigung und -Doku passen; `#nebeneinander(columns: 2, gutter: 5mm)` und `#grid(columns: 2, gutter: 5mm)` sehen gleich aus.
- Was Schule ist, bleibt deutsch und großteils unverändert: `loesungen`, `materialien`, `punkte`, `erwartungen`, `klausurboegen`, `varianten`, `dateiname`, `stufe`, `fach`. Werte `"sofort"`, `"folgend"`, `"seite"`, `"nur"` bleiben; nur die echten Stolpersteine ändern sich (`"seiten"` → `"einzelseiten"`, `"reinquetschen"` → `"ende"`).
- Der Kopf liest sich gut und behält die Hälfte der Vorkommen (`title` 1186, `font-size` 1133, `paper` 1128).
- Kästen deutsch (`merke`, `tipp`), `seitenumbruch(druck:)`, `ist-druckfassung()`.

Schwächen
- Für jemanden ohne Typst-Kenntnis ist die Sprache eines Namens nicht vorhersagbar: `title`, aber `untertitel`; `font`, aber `gestaltung`; `header`, aber Hook `kopf`. Das räumt der Entwurf selbst ein (8.1, 8.5). Ohne die „heißt jetzt“-Meldungen über Liste V wäre das für das Kollegium nicht tragbar.
- Im Inhalt kaum billiger als A: `class`, `print`, `workspace(s)`, `large`, `number`, `minipage` wechseln alle; `arbeitsflaeche` bleibt lang.
- Die meisten Detailfehler der drei Entwürfe (siehe nächste Liste).

## Regelverstöße und Lücken im Sieger C

1. **`auto` als „an“.** `klausurboegen: none | auto | (…)` und `erwartungen: auto | none | (…)`. Wer Klausurbögen will, soll `klausurboegen: auto` schreiben. Das widerspricht der eigenen Definition von `auto` („Paket entscheidet“) und der Erwartung aus 91 + 96 Köpfen mit `true`. Ursache ist das Lint-Dogma L7 (kein bool neben Dictionary).
2. **`numbering` ist überladen und besteht den eigenen Durchreichtest nicht.** In `aufgabe(numbering: auto | none)` ist es ein Schalter, kein Muster (1710 Aufrufe `number:`). Im Kopf von `arbeitsblatt` meint ein nacktes `numbering: "a)"` die Teilaufgaben; das errät niemand (Seiten? Aufgaben?).
3. **T3 ist Gewohnheitsrecht.** `font-size`, `title-size`, `caption-size` sind keine Typst-Namen und untereinander ungleich gebaut (`font-size`, aber nicht `title-font-size`).
4. **`teil` bleibt.** Abkürzung trotz „keine Abkürzungen“, dazu zwei Typen: `punktzahl(aufgabe, teil: none | int)` und `punktanzeige(punkte, teil: false)`. Das verletzt L5.
5. **`loesungen` hat drei Bedeutungen**: Kopfoption (Ort), Array in `teilaufgaben(loesungen: (…))`, Funktion `loesungen()`. Im Dokument unterscheiden sich `#loesung[…]` und `#loesungen()` nur im Plural, was 2.2 eigentlich verbietet; im Paket verdeckt der Parameter die Funktion.
6. **Parameter überdecken Typst-Funktionen im Paketrumpf**: `page`, `align`, `columns`, `numbering`, `label`. A hat dafür R5, C nichts (es bräuchte durchgehend `std.page` usw.).
7. **Gemischte Dictionaries**: `korrekturrand: (seite: "aussen", width: 5cm, frei: true, stroke: …)`; `qr-code(fill: black, hintergrund: none)`; `header-ascent` neben `kopf-oben`. `frei: true` ist ohne Doku nicht zu verstehen. Verschachtelte Dictionaries sind auf dem iPad mühsam und tauchen in keiner Signatur auf.
8. **Willkür bei Lehnwörtern**: `duplex` gilt als deutsch, `landscape` wird zu `querformat`, Typsts `flipped` kommt absichtlich nicht in T (R3 ausgesetzt).
9. **Umgedrehter Schalter**: `large: true` → `kompakt: false` (1933 Aufrufe, Codemod muss Werte invertieren); `kompakt` hat in `bewertungstabelle` eine andere Bedeutung.
10. **Unglückliche Wörter**: `symbole` (Typst hat den Typ `symbol` und `sym`; `icons` ist eingeführt), `verdeckt` für `lsg` (127 Aufrufe, in der Lösungsfassung ist nichts verdeckt), `verweis` für `icon-link`, `seitenzahlen: "neu"`, `raster` zugleich für Kästchengröße und Linienabstand, `eintragsabstand: 2` ist eine Anzahl, heißt aber Abstand.
11. **Verlorene Funktion**: `kariert(width:)` ist nur noch eine Länge; die Kästchenzahl in der Breite (20 Aufrufe, bisher auch zweites Positionsargument) hat keinen Nachfolger. A und B haben `spalten` bzw. `columns`.
12. **`qr-kasten(angle:)`** bricht 83 Aufrufe mit `rotation:`, nur um ein T-Wort zu erzwingen.
13. **Verbstellung uneinheitlich**: `optionen-setzen`, `aufgaben-zuruecksetzen` (Verb hinten), aber `ist-loesungsfassung` (Verb vorn).
14. **Lücken**: Fachpakete (physik, informatik, mathematik, operatoren, random, energy-sketch) fehlen ganz; der Ast klausurboegen 0.0.4 ist ein Satz; `gestaltung: "standard"` als Stringvorgabe, während `gestaltung: none` entfällt; Vorbehalt zu `"reinquetschen"` ist offen.

## Was von A und B übernommen werden sollte

Von A
- `false | true | Dictionary` für Merkmale mit Einstellungen (`klausurboegen`, `erwartungen`) statt `none | auto`.
- R5: kein deklarierter Parameter und keine Funktion überdeckt ein im Paket benutztes Typst-Builtin, oder das Paket schreibt konsequent `std.`.
- `icon` / `icons` statt `symbol` / `symbole`.
- `lsg` als festes Kurzwort behalten.
- `nummeriert: true` und `gross: true` als positive, nicht umgedrehte Schalter statt `numbering: auto | none` und `kompakt`.
- `teilaufgabe` statt `teil` in allen Parametern; `kennung` für die eigene Marke einer Teilaufgabe.
- Ein Verb-Affix für Sammelausgaben statt nackter Plurale (`loesungen-zeigen` passend zu `optionen-setzen`, oder A's `zeige-loesungen`), damit `#loesung` und `#loesungen` nicht kollidieren.
- `spalten`-Entsprechung für die Kästchenzahl in `kariert` (im Hybrid: `columns`).
- Umlaut-Faltung in Fehlermeldungen (`lösungen` → „schreibt sich `loesungen`“), Levenshtein-Lint innerhalb einer Signatur, Glossar mit Numerus.
- `vorschau-variante` statt eines mehrdeutigen `vorschau: auto | "alle" | Name`; `rotation` im Sink von `qr-kasten` belassen.
- Getrennte Wörter `kaestchengroesse` und `linienabstand` (oder kürzere), nicht ein `raster` für beides.

Von B
- Flache Geschwister statt „String oder Dictionary“: `punkte`, `punkte-position`, `punkte-vorlage`; entsprechend flache Korrekturrand-Parameter. Das verlangt eine Lockerung von R5 in C.
- „Bestandsschutz“ als ausdrückliche Regel: Ein Name, der schon regelkonform, eindeutig und häufig ist, bleibt.
- `logo: auto` für das Schullogo, `none` für keins; leerer Text ist immer `none`.
- `erwartung(punkte: 2)[…]` zusätzlich annehmen (heute still 0 Punkte).
- Kollisionslint neuer Namen gegen `std`, cetz, cetz-plot, gentle-clues, fontawesome.
- `--input streng=1` und Veraltet-Bericht für das, was der Codemod nicht findet.
- Hinweis auf externe Leser der Metadaten (`<ab-meta>`): Schlüssel dort nicht umbenennen, ohne die Leser mitzuziehen.

## Entscheidungen, die nur der Autor treffen kann

1. Ist das Kollegium wirklich Zielgruppe? Wenn ja, wiegt die Unvorhersagbarkeit von C schwerer und A rückt auf; wenn der Autor praktisch allein tippt, gewinnt C klarer (und B wird diskutabel).
2. `class` → `klasse` (1187 Köpfe) und `print` → `druck` (714): hinnehmen oder als Bestandsschutz-Ausnahme stehen lassen?
3. `arbeitsflaeche` (14 Zeichen, rund 3500-mal): so lassen, ein kürzeres deutsches Wort wählen oder `workspace` behalten?
4. `large` / `number` in `aufgabe`: `gross` / `nummeriert`, oder C's `kompakt` / `numbering`?
5. `minipage` (1575 Aufrufe) → `nebeneinander`, oder bleibt der LaTeX-Name?
6. Kopfoption für das Teilaufgabenmuster: nacktes `numbering`, `teilaufgaben-numbering` (Mischname, verletzt R5 von C) oder deutsch?
7. Inhalt der Liste T: gehören `title` und `font-size` hinein? Davon hängen rund 4300 Stellen ab.
8. Umschrift `ae/oe/ue/ss` empfehlen alle drei; die Bestätigung (111 `#lücke(`) fehlt noch.
9. `theme` → `gestaltung`, obwohl 0.4.0 `theme` und `akzent` gerade erst eingeführt hat (37 Köpfe)?
10. Versionsnummer: 0.4.1 trotz vollständigem Namensbruch gegenüber 0.4.0, oder 0.5.0?
11. Wildcard-Re-Exporte kappen (`stickybox` 45 Aufrufe, `canvas`, `fa-*`): Das ändert für Nutzer mehr als jede Umbenennung.
12. Werte von `loesungen`: `"sofort"` / `"folgend"` behalten (C) oder neu benennen (A, B)? Vorher die tatsächliche Wirkung von `"reinquetschen"`, `"folgend"` und `"keine-summe"` am Code klären.
13. Verbform der Sammelausgaben und Aktionen (`zeige-…`, `…-zeigen`, oder nackter Plural).
14. Zusammenführung der klausurboegen-Äste 0.0.4 und 0.0.5 und Umfang der Fachpakete in dieser Runde.
