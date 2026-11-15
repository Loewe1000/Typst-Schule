# Umbenennungstabelle: klassenarbeit, klausurboegen, patterns

Stand 2026-11-15 (nach adversarialer Prüfung überarbeitet, siehe Abschnitt 9 „Prüfprotokoll"). Grundlage: `KONVENTION.md` (verbindlich), `inventar/klassenarbeit-klausurboegen.md`, `inventar/informatik-kleinpakete.md` (Abschnitt 3), dazu der Quelltext von `klassenarbeit/0.4.0`, `klassenarbeit/0.3.1` (Ast mit `bogen:`), der Signaturen von `klassenarbeit/0.0.5` bis `0.3.2` (für die Kontextregeln nach Quellversion), `klausurboegen/0.0.4`, `klausurboegen/0.0.5`, `patterns/0.0.1`, `patterns/0.0.2`. Am Repo wurde nichts geändert.

**Bausteinnamen (Entscheidung vom 2026-11-15, K 1.1, K 2.1a, K 9.3).** Die Bausteine dieser Tabelle heißen auf Dauer deutsch: `klassenarbeit`, `klausurboegen`, `kariert`, `liniert` (dazu aus den Nachbarpaketen `arbeitsblatt`, `arbeitsblatt-einzeln`, `aufgabe`, `luecke` …). Englische Zwillinge (`exam`, `answer-sheets`, `squares`, `lines` als Funktionen) und Übergangsnamen gibt es nicht. An Funktionsnamen ändert sich in dieser Tabelle nur `klausurbögen` → `klausurboegen` (Umschrift) sowie `flex-feld` → `flex-area` und `ist-flex-feld` → `is-flex-area` (keine Bausteine, deshalb englisch). Alles in den Klammern bleibt englisch wie ausgearbeitet: `answer-sheets:` als Parameter und Variante, `pattern: "squares" | "lines"`, `kind: "exam"`. Interne Namen (`internal.exam-single`, `internal.answer-sheets-variant` …) sind nach K 7.2 immer englisch und tragen das Parameterwort aus K 2.1b.

Zielversion für alle drei Pakete: **0.4.1** (KONVENTION 11.1). Für klausurboegen (heute 0.0.5) und patterns (heute 0.0.2) ist das ein Sprung; beide Nummern sind frei.

Abkürzungen in der Spalte „Begründung": **G n** = Glossar Nr. n (KONVENTION 3), **K x.y** = Abschnitt der Konvention, **A.n** = Anhang A, **Wn** = Wertform (K 5.1), **Ln** = Lint-Regel (K 10). K 11.4 ist die frühere Nr. 11.6 (klausurboegen, Ast 0.0.4).

Spalte „Codemod": **ja** = reine Namens- oder Literalersetzung; **ja (AST)** = braucht das AST-Werkzeug (Dictionary-Schlüssel, Umstellen von Argumenten); **teilweise** = nur bei Literalwerten, sonst Bericht; **teilweise (Kontext)** = hängt von anderen Argumenten desselben Aufrufs oder von der Quellversion des Dokuments ab (die Version aus der Importzeile `@schule/klassenarbeit:x.y.z`), steht im Anhang unter `kontext`; **nein** = von Hand.

Per Kompilieren mit Typst 0.15.1 nachgeprüft (Probedateien nur im Scratchpad, danach gelöscht):

- klassenarbeit 0.4.0 zeigt ohne `punkte:` **keine** BE an (wirksame Vorgabe ist `"keine"` aus `arbeitsblatt-einzeln`, nicht `"aufgaben"`).
- `kariert()`, `kariert(height: 2cm)`, `kariert(items: …)`, `liniert()` laufen ohne `rows`. `kariert(items-spacing: 1.5)` läuft, auch mit `items`. `liniert(items-spacing: 1.5)` läuft **ohne** `items` (der Wert wird dann nicht gelesen); `liniert(items: ([a], [b]), items-spacing: 1.5)` bricht ab (`expected integer, found float`, patterns.typ 209), weil erst Z. 192–194 `items.len() * items-spacing` bildet.
- `kariert(2, width: 5cm)` und `kariert(2, 5cm)` laufen und sind 5 cm breit; `kariert(2, width: 12)` ist 12 Kästchen = 6 cm breit. `width` nimmt in `kariert` heute also Länge **und** Kästchenzahl. Nur zusammen mit `content` bricht eine Länge ab (`cannot multiply length with length`, patterns.typ 126).
- `liniert(rows: 2, width: 10)` läuft (benannt wird auch eine Zahl angenommen, Einheit Zeilenhöhen); `liniert(3, 10)` läuft, die Zahl wird ignoriert; `liniert(3, 5cm)` ist 5 cm breit.
- klausurboegen 0.0.4: `vordruck: true` druckt die ganze Tabelle (wie `false`); nur `vordruck: "werte"` druckt allein die erreichten Punkte.

**Quellversion.** Die Namen aus älteren Versionen gehören zum Compat-Umfang (K 9.2), ihre Vorgaben und Bedeutungen weichen aber ab (belegt an den Signaturen 0.0.5, 0.0.8, 0.1.0, 0.1.1, 0.1.2, 0.3.0–0.3.2). Der Codemod liest deshalb die Version aus der Importzeile. Für Quellen bis 0.1.1 sichern die Kontextregeln, dass kein Merkmal neu an- oder abgeschaltet wird (Bögen, Erwartungshorizont, BE-Anzeige, Info-Tabelle, Logo); „gleiches PDF" (K 5.5) ist dort nicht erreichbar, weil Kopf und Erwartungshorizont anders gesetzt wurden. Das Abnahmekriterium gilt für Quellen ab 0.3.0 (Zweifelsfall 13).

---

## 1. klassenarbeit 0.4.0 → 0.4.1

### 1.1 `klassenarbeit` (Funktionsname bleibt)

Alt (wörtlich, `src/klassenarbeit.typ` 384–402):

```typ
#let klassenarbeit(
  subtitle: "",
  date: "",
  logo: "angela",
  teacher: "",
  student: "",
  name-field: "Name",
  name-repeat: false,
  info-table: false,
  page-numbering: true,
  klausurboegen: false,
  erwartungen: true,
  punkte-template: none,
  varianten: auto,
  variante: auto,
  dateiname: none,
  ..args,
  body,
) = {
```

Neu (A.2, die Kurzzeile „Seite und Gestaltung" ausgeschrieben; eine Zeile geht über A.2 hinaus, eine weicht von A.2 ab, beide sind markiert):

```typ
#let klassenarbeit(
  // Kopf
  title: none,                  // W4 str | content
  subtitle: none,               // W4 str | content
  class: none,                  // W4 str | content
  date: none,                   // W4 str | content
  teacher: none,                // W4 str | content
  student: none,                // W4 str | content
  logo: auto,                   // W8 content | str; auto = Schullogo, none = keins
  name-field: "Name",           // W4 str | content; none = kein Namensfeld
  name-repeat: false,           // W1
  info-table: none,             // W4 array aus Paaren
  page-counter: "restart",      // W2 "restart" | "continuous"; none = keine Seitenzahlen. WEICHT VON A.2 AB (dort page-numbering), Zweifelsfall 2
  // Merkmale mit Einstellungen
  expectations: true,           // W6; Schlüssel = Parameter von show-expectations (select, blocks, grouped, achieved)
  answer-sheets: false,         // W6; Schlüssel = Parameter des Bausteins klausurboegen
  answer-sheet-pages: false,    // W6; ÜBER A.2 HINAUS (Zweifelsfall 6): Arbeit direkt auf dem Bogen
  // Options-Schema (K 6), abweichende Vorgabe: points
  solutions: none,
  solutions-pagebreak: none,
  materials: "after-task",
  materials-pagebreak: "before",
  points: "tasks",
  points-total: true,
  points-position: "end",
  points-format: auto,          // W7 auto | function | (task: f, subtask: g)
  workspaces: true,
  shortcodes: "subtasks",
  subtask-numbering: "a)",
  // Varianten und Ausgabe
  variants: auto,               // W5 array aus "print", "solutions", "answer-sheets"
  preview-variant: auto,        // W5 "print" | "solutions" | "answer-sheets"
  filename: none,               // W4 str
  // Seite und Gestaltung wie arbeitsblatt-einzeln, ohne print, header, scope
  paper: "a4",
  landscape: false,
  duplex: true,
  page-settings: (:),           // W9, geht an set page; auch header-ascent
  theme: auto,
  accent: auto,
  font: auto,
  math-font: auto,
  font-size: auto,
  title-font-size: auto,
  figure-font-size: auto,
  ..deprecated,
  body,
) = { }
```

#### Deklarierte Parameter von heute

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `klassenarbeit` (Funktion) | `klassenarbeit` | unverändert (Baustein, deutsch auf Dauer) | – | – (nichts umzustellen) | G 2, K 2.1a, K 9.3 (kein englischer Zwilling `exam`, kein Alias; `exam` ist nur Parameterwort, etwa `kind: "exam"`) |
| `subtitle: ""` | `subtitle: none` | Default geändert | `""` → Argument löschen | ja | G 14, K 5.2 (leerer Text ist `none`), K 9.2 |
| `date: ""` | `date: none` | Default geändert | `""` → Argument löschen | ja | G 18, K 5.2 |
| `logo: "angela"` | `logo: auto` | Default geändert, Typ präzisiert (W8) | `"angela"` → Argument löschen (bleibt als Name gültig); `none` → `none`; `""` (0.0.x) → `none`; content bleibt; unbekannter String ist neu ein Fehler (heute als Text gesetzt) | ja | A.2, W8, L25 nennt `"angela" → auto` ausdrücklich |
| `teacher: ""` | `teacher: none` | Default geändert | `""` → Argument löschen | ja | G 19, K 5.2 |
| `student: ""` | `student: none` | Default geändert | `""` → Argument löschen | ja | G 20, K 5.2 |
| `name-field: "Name"` | `name-field: "Name"` | unverändert | `none` bleibt „kein Namensfeld"; Doppelpunkt setzt weiter das Paket | – | A.2, W4 |
| `name-repeat: false` | `name-repeat: false` | unverändert | – | – | A.2, W1 |
| `info-table: false` | `info-table: none` | Typ geändert, Default geändert | **Quelle ab 0.1.2:** `false` → Argument löschen; `true` → Fehler (dort wirkungslos); Array aus Paaren bleibt; flaches Array `(a, b, c, d)` → `((a, b), (c, d))`. **Quelle 0.0.8–0.1.1:** dort ist `info-table` ein bool-Schalter mit Vorgabe `true` (0.1.1 Z. 49, 146 `if info-table { … }`) und `table` trägt die Daten; Regel unter „Namen aus älteren Versionen" | teilweise (Kontext: Quellversion; Literal-Arrays per AST) | A.2 (W4 „array aus Paaren"), K 5.2 (das Aus ist `none`), K 4.4 Nr. 4 (ein Weg) |
| `page-numbering: true` | `page-counter: "restart"` | umbenannt, Typ geändert (W2); Wirkung der Vorgabe unverändert | `true` → Argument löschen; `"reset"` → `page-counter: "restart"` (bzw. löschen); `"continuous"` → `page-counter: "continuous"`; `false` → `page-counter: none`. Laufzeit: ``klassenarbeit.klassenarbeit: `page-numbering` heißt jetzt `page-counter` `` | ja | Leitregel („ein Wort, ein Typ"; heißt wie Typst, verhält sich wie Typst), G 39 (`page-numbering` ist das Nummerierungsmuster, str), L6, K 5.2, L7; **weicht von A.2 ab**, Zweifelsfall 2 |
| `klausurboegen: false` | `answer-sheets: false` | umbenannt, Typ geprüft (W6) | `false`/`true` bleiben; Dictionary: Schlüssel nach 1.2; `(show: false, …)` → `false`; alles andere (`none`, `"ja"`) ist neu ein Fehler. Quelle bis 0.1.1: nur bool; das eine Dictionary entsteht dort aus `klausurboegen-settings`, `ergebnisse` und `stufe` (siehe unten), und **nur wenn die Bögen aktiv sind** | ja (AST für das Dictionary); teilweise (Kontext) für Quellen bis 0.1.1 | G 12, K 2.1b und K 9.2 (der Parameter trägt das Parameterwort `answer-sheets`, nicht den Bausteinnamen `klausurboegen`), W6 (ein Dictionary heißt „an“) |
| `erwartungen: true` | `expectations: true` | umbenannt, Typ geprüft (W6) | `true`/`false` bleiben; Dictionary: Schlüssel nach 1.3; `(show: false)` → `false`. **Strings** (wirken heute wie aus, weil nur `== true` zählt; lokal 13 Köpfe `"keine"`, 1 Kopf `"true"`, alle 0.0.x/0.1.x): `"keine"`, `"false"` → `false`; `"true"` → `false` mit Bericht. **Quellversion:** bis 0.1.1 war die Vorgabe `false` → fehlt das Argument, ergänzt der Codemod `expectations: false`; in 0.0.2–0.0.8 erscheint der Horizont nur mit `stufe: "I"` oder `"II"` (`d_ew_unterstufe`/`d_ew_oberstufe`) → `erwartungen: true` ohne eine solche `stufe` wird `expectations: false` mit Bericht; bis 0.3.1 zählt nur `== true`, ein Dictionary schaltet den Horizont dort ab → `expectations: false` mit Bericht | ja (AST) ab 0.3.2; teilweise (Kontext) davor | G 7, W6, K 5.2, K 9.2, L25 |
| `punkte-template: none` | `points-format: auto` | umbenannt, Default geändert in der Schreibweise | `none` → Argument löschen; Funktion bleibt; `(aufgabe: f, teilaufgabe: g)` → `(task: f, subtask: g)` | ja (AST) | K 6 (W7), G 3, G 4 |
| `varianten: auto` | `variants: auto` | umbenannt, Typ geändert (nur Array) | `"druck"` → `"print"`, `"loesung"` → `"solutions"`, `"klausurboegen"` → `"answer-sheets"`; einzelner String `"druck"` → `("print",)` | ja | G 58, K 5.3, W5 |
| `variante: auto` | `preview-variant: auto` | umbenannt | Werte wie bei `variants` | ja | G 58, L10 (heute ein Buchstabe Abstand zu `varianten`) |
| `dateiname: none` | `filename: none` | umbenannt | – | ja | G 59 |
| `..args` | `..deprecated` | Typ geändert | nimmt nichts mehr an; jedes benannte Argument, das nicht deklariert ist, und jedes überzählige Positionsargument ist ein Fehler nach K 8.3 mit Präfix `klassenarbeit.klassenarbeit:` | – | K 4.4 Nr. 5 (kein Durchreich-Sink), Nr. 6 |
| `body` | `body` | unverändert | – | – | G 79 |

#### Heute über `..args` an `arbeitsblatt-einzeln` gereicht (jetzt deklariert oder entfernt)

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `title` (aus `..args`, in arbeitsblatt `""`) | `title: none` | neu deklariert, Default geändert | `""` → Argument löschen | ja | G 13, A.2; behebt Inventar 3.7/42 |
| `class` (aus `..args`, `""`) | `class: none` | neu deklariert, Default geändert | `""` → Argument löschen | ja | G 15, A.2 |
| `paper` | `paper: "a4"` | neu deklariert, unverändert | – | – | G 50, W9 |
| `landscape` | `landscape: false` | neu deklariert, unverändert | – | – | G 51 |
| `duplex` | `duplex: true` | neu deklariert, unverändert | – | – | G 56 |
| `page-settings` | `page-settings: (:)` | neu deklariert, unverändert | Standardränder `(top: 1cm, bottom: 1cm, left: 1.5cm, right: 1.5cm)` und `+14pt` oben bleiben | – | K 4.4 Nr. 5 (einzige Durchreich-Ausnahme) |
| `header-ascent` (Sonderfall in `..args`) | Schlüssel in `page-settings: (header-ascent: …)` | zusammengelegt | `header-ascent: x` → `page-settings: (header-ascent: x)` | ja (AST) | A.1-Kommentar „auch header-ascent" |
| `theme: none` | `theme: auto` | neu deklariert, Default geändert | `none` → Argument löschen; `"standard"` → Argument löschen | ja | G 61, Anhang C („theme: none für Standard") |
| `akzent` | `accent: auto` | umbenannt | – | ja | G 26 |
| `font`, `math-font` | `font: auto`, `math-font: auto` | neu deklariert, unverändert | – | – | G 48 |
| `font-size`, `title-font-size` | `font-size: auto`, `title-font-size: auto` | neu deklariert, unverändert | – | – | G 49 |
| `figure-font-size: 9pt` | `figure-font-size: auto` | neu deklariert; Default nach A.1 (`auto` löst zu 9pt auf **[prüfen]**) | Quelle 0.0.8–0.1.1: Vorgabe dort 12pt → fehlt das Argument, ergänzt der Codemod `figure-font-size: 12pt` | teilweise (Kontext: Quellversion) | G 49, A.2, L25 |
| `workspaces` | `workspaces: true` | neu deklariert, unverändert | – | – | K 6 |
| `loesungen` | `solutions`, `solutions-pagebreak` | umbenannt, ein Wert wird zwei Optionen | `"keine"`, `"false"`, `false`, `none` → Argument löschen; `"sofort"` → `"in-place"`; `"folgend"` → `"after-task"`; `"reinquetschen"` → `"at-end"`; `"seite"` → `solutions: "at-end", solutions-pagebreak: "before"`; `"seiten"` → `solutions: "at-end", solutions-pagebreak: "per-task"`; `"nur"` → `"only"` | ja | G 5, K 6, K 9.2 |
| `materialien` | `materials`, `materials-pagebreak` | umbenannt | `"seiten"` → Argument löschen (Vorgabe); `"sofort"`, `"folgend"` → `materials: "after-task", materials-pagebreak: none`; `"seite"` → `materials: "at-end"`; `"reinquetschen"` → `materials: "at-end", materials-pagebreak: none`; `"keine"`, `"false"`, `false` → `materials: none` | ja | G 9, K 6 |
| `punkte` | `points`, `points-total`, `points-position` | umbenannt, **Default geändert** (in allen Quellversionen wirksam `"keine"`, neu `"tasks"`) | `"keine"` → `none`; `"aufgaben"` → Argument löschen; `"teilaufgaben"` → `"subtasks"`; `"alle"` → `"all"`; `"keine-summe"` → `points: "all", points-total: false`; `(anzeige: a, position: p)` → `points: a′, points-position: p′` mit `"ende"` → `"end"`, `"rand"` → `"margin"`; **fehlt `punkte` im alten Kopf, ergänzt der Codemod `points: none` – ohne Versionsbedingung**: die Vorgabe war immer `"keine"` (0.0.8 Z. 23, 0.1.0 Z. 24, 0.1.1 Z. 52; ab 0.1.2 aus arbeitsblatt, 0.2.4 Z. 220; vor 0.0.8 gab es keine BE-Anzeige). Lokal 53 Köpfe ohne `punkte`, davon 51 aus 0.0.x/0.1.x | teilweise (Kontext: fehlendes Argument; AST) | G 8, K 6 (Spalte „Vorgabe klassenarbeit"), L25; Zweifelsfall 3 |
| `aufgaben-shortcodes` | `shortcodes` | umbenannt | `"keine"` → `none`; `"aufgaben"` → `"tasks"`; `"teilaufgaben"` → Argument löschen; `"alle"` → `"all"` | ja | G 90, K 6 |
| `teilaufgabe-numbering` | `subtask-numbering` | umbenannt | `"a)"` bleibt; `"1."` → `"1.1"`; Regel und befristete Sperre von `"1."` wie in der aufgaben-Tabelle 2.1 (dort W3 mit Paketregel statt W9, Zweifelsfall 12) | ja | G 39, K 6 |
| `print` | – | entfernt | `print: true` → Argument löschen; `print: false` → Fehler: ``klassenarbeit.klassenarbeit: `print` gibt es nicht mehr – eine Klassenarbeit ist immer Druckfassung`` | teilweise (`true` ja, `false` Bericht) | A.2 („ohne print"); behebt Inventar 4.1/6. Im Bestand 44 Köpfe |
| `custom-header` | – | entfernt | Fehler: ``… `custom-header` gibt es nicht mehr – der Kopf entsteht aus `title`, `subtitle`, `class`, `date`, `teacher`, `logo`; ein eigener Kopf ist der Theme-Hook `header` `` | nein (1 Kopf im Bestand) | A.2 („ohne header"), G 54, L4 (`custom-`) |
| `scope` | – (nur `internal`) | entfernt | Fehler mit Hinweis „intern" | nein (kein Vorkommen) | A.2 („ohne scope") |
| `copyright` | – | entfernt | Fehler: ``… `copyright` gibt es nicht mehr – `copyright-url` gibt es nur in `arbeitsblatt` `` | nein | A.2 deklariert es nicht |
| `zweifach` | – | entfernt | Fehler: ``… `zweifach` gibt es nicht mehr – zwei Seiten je Bogen (`two-up`) gibt es nur in `arbeitsblatt` `` | nein | A.2 deklariert `two-up` nicht; klassenarbeit kennt die Variante `"zweifach"` schon heute nicht |
| `fach`, `thema`, `jahrgang`, `niveau`, `typ`, `stichworte`, `kerncurriculum`, `stand`, dazu `stufe` als Bildungsstufe (`"sek-1"` \| `"sek-2"` \| `none`, arbeitsblatt 0.4.0 Z. 297, 596, 1018) | – | entfernt | Fehler: ``… `fach` gibt es nicht mehr – Bibliotheks-Metadaten (`subject`, `topic`, …) gibt es nur in `arbeitsblatt` ``. `<ab-meta>` behält alle elf Schlüssel (1.6); `klassenarbeit` füllt nur `titel` und `klasse` | nein (im Bestand 0 Köpfe von klassenarbeit); `stufe` siehe nächste Zeile | A.2 deklariert sie nicht; Zweifelsfall 4 |
| `stufe` (zwei Bedeutungen je nach Quellversion) | – | entfernt | **Quelle bis 0.1.1** (`"I"` \| `"II"` \| `false`: Notenschlüssel der Bögen, 0.0.8 Z. 157–161; in 0.0.2–0.0.8 zugleich Art des Erwartungshorizonts): (a) Bögen aktiv und `stufe: "I"` → Schlüssel `stage: "sek-1"` in das **eine** `answer-sheets`-Dictionary einfügen (aus `klausurboegen: true` wird `answer-sheets: (stage: "sek-1")`), `stufe` löschen; (b) Bögen aktiv und `stufe: "II"` oder `false` → `stufe` löschen (`"sek-2"` ist die Vorgabe); (c) Bögen aus oder nicht angegeben → `stufe` ersatzlos löschen, Bericht. Es entsteht nie ein zweites Argument `answer-sheets` (Typst: duplicate argument) und nie ein Dictionary bei ausgeschalteten Bögen (W6: Dictionary = an). **Quelle ab 0.1.2:** klassenarbeit liest `stufe` nicht mehr (die Bögen lesen `sek1` im Dictionary); in 0.4.0 ist es die Bildungsstufe für `<ab-meta>` → Argument löschen, Bericht. **Laufzeit, nach dem Wert unterschieden:** `"I"`, `"II"`, `false` → ``klassenarbeit.klassenarbeit: `stufe` gibt es nicht mehr – der Notenschlüssel steht in `answer-sheets: (stage: "sek-1")` ``; jeder andere Wert → ``klassenarbeit.klassenarbeit: `stufe` gibt es nicht mehr – Bibliotheks-Metadaten gibt es nur in `arbeitsblatt` `` | teilweise (Kontext: Quellversion und `klausurboegen`) | K 8.3, K 9.2 (Pflichteintrag), W6; 80 Köpfe im Bestand (lokal 68 mit `"I"`/`"II"`, alle 0.0.3–0.1.2, davon 24 ohne aktive Bögen) |
| `vorschau-alle` (heute schon Fehler aus arbeitsblatt) | – | entfernt | Fehler mit Hinweis auf `preview-variant` | nein | G 58 |

#### Namen aus älteren Versionen (Compat-Umfang nach K 9.2)

| alt (Version) | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `schueler` (0.0.x) | `student` | umbenannt | `""` → löschen | ja | G 20 |
| `table: ()` (bis 0.1.1, 68 Köpfe) zusammen mit dem bool-Schalter `info-table` (0.0.8–0.1.1, Vorgabe `true`) | `info-table` | zusammengelegt | `info-table: false` → **beide** Argumente löschen (die Tabelle war ausgeblendet; lokal 7 Köpfe); `info-table: true` oder nicht angegeben → das bool-Argument löschen, `table: X` → `info-table: X`; `table: ()` → löschen; flach → Paare. Ohne diese Regel entstünden zwei Argumente `info-table` (duplicate argument) oder eine bisher ausgeblendete Tabelle erschiene | teilweise (Kontext: Quellversion) | A.2, K 9.1 (alter Name mit neuer Bedeutung) |
| `header-font-size` (12 Köpfe) | `title-font-size` | umbenannt | – | ja | G 49 |
| `bewertung: true` (0.0.x, 8 Köpfe) | – | entfernt | Fehler: ``… `bewertung` gibt es nicht mehr – die Punkteübersicht ist `show-points-table()`, die Spalte zum Eintragen `expectations: (achieved: true)` `` | nein | G 7 (verbotenes Synonym); `bewertung.typ` ist tot |
| `ergebnisse` als Kopfparameter (bis 0.1.1) | Schlüssel `results` und `overprint` im einen `answer-sheets`-Dictionary | zusammengelegt | Bögen aktiv: `ergebnisse: x` → `results: x, overprint: true` einfügen; `ergebnisse: none` → löschen. **Bögen aus oder nicht angegeben** (`ergebnisse` wirkt nur innerhalb `#if klausurboegen`; lokal 4 von 20 Köpfen): Argument löschen, Bericht, kein Dictionary erzeugen | teilweise (Kontext: `klausurboegen`) | G 82, W6 (Dictionary = an) |
| `klausurboegen-settings: (…)` (0.0.5–0.1.1, 38 Köpfe) | Schlüssel im einen `answer-sheets`-Dictionary | zusammengelegt | `klausurboegen: true` → ein Dictionary aus den Schlüsseln (nach 1.2 und 2.1; in 0.0.8 zusätzlich `move` → `offset`). **`klausurboegen: false` oder nicht angegeben** (lokal 11 von 25 Köpfen): `klausurboegen-settings` löschen, Bericht, `answer-sheets` bleibt aus. **Abweichende Vorgabe:** `(sub: false, numbering: "a)", rand: 6cm, weißer-rand: true)` → sind die Bögen aktiv und fehlt `klausurboegen-settings`, ergänzt der Codemod `correction-margin: 6cm` (neu 5cm); ein angegebenes Dictionary ersetzt die Vorgabe ganz, dann gilt schon heute `rand: 5cm` aus `klausurbögen` | teilweise (Kontext: `klausurboegen`, Quellversion) | G 12, W6, L25 |
| `bogen: false \| true \| (…)` (0.3.1, 7 Köpfe) | `answer-sheet-pages: false \| true \| (…)` | umbenannt | Schlüssel nach 2.2 | ja (AST) | G 12 (`bogen` verboten); Zweifelsfall 6 |
| kein `logo` im Kopf (Quelle bis 0.1.0; Vorgabe dort `""` = kein Logo, ab 0.1.1 `"angela"`) | `logo: none` ergänzen | Default geändert | – | teilweise (Kontext: Quellversion) | L25 |
| kein `erwartungen` im Kopf (Quelle bis 0.1.1; Vorgabe dort `false`) | `expectations: false` ergänzen | Default geändert | siehe Zeile `erwartungen` | teilweise (Kontext: Quellversion) | L25 |

### 1.2 Schlüssel im Dictionary `answer-sheets: (…)` (heute `klausurboegen: (…)`)

Nach W6 sind die Schlüssel genau die benannten Parameter des Bausteins `klausurboegen` (Abschnitt 2.1) und werden mit derselben Tabelle geprüft; die Meldung trägt den Präfix `klassenarbeit.klassenarbeit:` und nennt den Schlüssel als `answer-sheets.<schlüssel>`.

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `show` | – | entfernt | `(show: false, …)` → `answer-sheets: false`; `(show: true, …)` → Schlüssel löschen | ja (AST) | K 5.1 („W6 kennt keinen Schlüssel show"), L4 |
| `ergebnisse` | `results` und `overprint` | umbenannt, ein Schlüssel wird zwei | `ergebnisse: x` → `results: x, overprint: true`; `ergebnisse: none` → löschen | ja (AST) | G 82; W6 (Schlüssel = Parameter, keine stille Ableitung von `result`) |
| `students`, `result` (heute als zweiter Weg möglich) | `results`, `overprint` | umbenannt | `result: true` → `overprint: true` | ja (AST) | G 82, K 4.4 Nr. 4 |
| `exam`, `subexam` (Überschreiben der abgeleiteten Werte) | `title`, `subtitle` | umbenannt | – | ja (AST) | G 13, G 14 |
| `teacher`, `class`, `date` | gleich | unverändert | `""` → löschen | ja | G 15, 18, 19 |
| alle weiteren, je nach Quellversion: klassenarbeit 0.1.2/0.3.0 reichen an klausurboegen 0.0.3, 0.3.1 an 0.0.4, 0.3.2/0.4.0 an 0.0.5 (KA Z. 23). **In allen:** `sek1`, `rand`, `scale`, `sub`, `numbering`, `mv`, `weißer-rand`, `result-table`, `vorschlag`, `line-stroke`. **Nur aus 0.3.1:** `vordruck`, `namen`. **Nur aus 0.3.2/0.4.0:** `muster`, `linienabstand`, `korrekturrand`. Im jeweils anderen Ast endet der Schlüssel heute in Typsts „unexpected argument" | siehe 2.1 | siehe 2.1 | die Wertabbildungen aus 2.1 gelten unverändert für die Dictionary-Schlüssel (Vererbungsregel im Anhang) | ja (AST) | siehe 2.1 |
| `move` (nur in `klausurboegen-settings` von 0.0.8, Z. 28; 11 Dokumente pinnen 0.0.8) | `offset` | umbenannt | Schlüssel `dx`, `dy` bleiben | ja (AST) | G 74 |
| `stufe: "I"` (nur in der Doku, im Code nie vorhanden) | `stage: "sek-1"` | Doku-Fehler behoben | `"I"` → `"sek-1"`, `"II"` → `"sek-2"` | ja | G 23 |

Von `klassenarbeit` an den Baustein `klausurboegen` gesetzt (im Dictionary `answer-sheets` überschreibbar, das Dictionary gewinnt wie heute): `title`, `subtitle`, `teacher`, `class`, `date`, **neu** `logo` und **neu** `subtask-numbering` (heute nicht gekoppelt, Inventar 1.9).

### 1.3 Schlüssel im Dictionary `expectations: (…)` (heute `erwartungen: (…)`)

Schlüssel = Parameter von `aufgaben.show-expectations(select: "current", blocks: (), grouped: false, achieved: false)` in der Fassung der aufgaben-Tabelle 1.11. Diese weicht von A.5 ab (`blocks: auto | none | array` wurde dort nach Prüfung durch `select` und `blocks` ersetzt); beide Tabellen benutzen dieselbe Regel. Die Vorgabe bleibt „aktueller Block, ungeteilt": `expectations: true` wirkt wie heute `erwartungen: true`, auch in Dokumenten mit `reset-aufgaben()`.

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `show` | – | entfernt | `(show: false)` → `expectations: false`; `show: true` → Schlüssel löschen | ja (AST) | K 5.1, K 9.2 (Pflichteintrag) |
| `new-page` | – | entfernt | **Quelle 0.4.0:** Schlüssel löschen (dort still verworfen, KA 321). **Quelle 0.3.2:** wirksam (`show-erwartungen(new-page: true, ..erwartungen-einstellungen)`, Z. 296; `new-page` ist ein echter Parameter von `show-erwartungen`, aufgaben/0.3.1 Z. 534) → `new-page: true` löschen; `new-page: false` löschen **mit Bericht** (der Horizont steht künftig immer auf eigener Seite). Laufzeit: ``klassenarbeit.klassenarbeit: `expectations.new-page` gibt es nicht mehr – der Erwartungshorizont beginnt immer auf einer neuen Seite`` | teilweise (Kontext: Quellversion) | Inventar 4.1/5; K 8.1 (nichts still übergehen) |
| `grouped` | `grouped` | unverändert | – | – | aufgaben 1.11, W1 |
| `erreicht` | `achieved` | umbenannt | – | ja (AST) | aufgaben 1.11, K 4.3 |
| `alle` | `select` | umbenannt, Typ geändert (bool → Auswahl) | `alle: true` → `select: "all"`; `alle: false` → Schlüssel löschen (Vorgabe `"current"`) | ja (AST) | aufgaben 1.11, G 86 (`alle` ist dort verbotenes Synonym) |
| `teile` | `blocks` | umbenannt | mit `alle: true`: `teile: T` → `blocks: T`; ohne `alle: true` war `teile` wirkungslos → Schlüssel löschen (neu ist `blocks` ohne `select: "all"` eine unzulässige Kombination, K 8.3) | ja (AST; Kontext im selben Dictionary) | aufgaben 1.11, L9 |

Versionshinweise: Ein Dictionary wird erst ab 0.3.2 ausgewertet; in 0.3.0/0.3.1 (und davor) zählt nur `erwartungen == true`, ein Dictionary schaltet den Horizont dort ab (Regel in 1.1). `alle` und `teile` gibt es erst ab aufgaben 0.3.1.

### 1.4 Unterschlüssel von `points-format` (heute `punkte-template`) und Options-Schlüssel

| alt | neu | Art | Codemod | Begründung |
|---|---|---|---|---|
| `punkte-template.aufgabe` | `points-format.task` | umbenannt | ja (AST) | K 6 (W7), G 3 |
| `punkte-template.teilaufgabe` | `points-format.subtask` | umbenannt | ja (AST) | G 4 |
| Options-Schlüssel `punkte-template-aufgabe`, `punkte-template-teilaufgabe` (per `set-options` gesetzt, KA 217–220) | ein Options-Schlüssel `points-format` mit `(task:, subtask:)` | zusammengelegt | intern | K 5.4 (State-Schlüssel = Kopfparameter), L17 |
| Standard-Formate `punkte => [*#punkte BE*]`, `punkte => [*[#punkte BE]*]` (doppelt in KA 208–209 und aufgaben 50–51) | nur noch in aufgaben; `points-format: auto` | entfernt aus klassenarbeit | – | Inventar 4.1/8 |

### 1.5 Enum-Werte, Varianten, Dateinamen

| Sache | alt | neu | Art | Codemod | Begründung |
|---|---|---|---|---|---|
| Variante | `"druck"` | `"print"` | umbenannt | ja | K 5.3 |
| Variante | `"loesung"` | `"solutions"` | umbenannt | ja | K 5.3, G 5 |
| Variante | `"klausurboegen"` | `"answer-sheets"` | umbenannt | ja | K 5.3, G 12 |
| `variants: auto` | `("druck", "loesung")`, bei aktiven Bögen zusätzlich `"klausurboegen"` | `("print", "solutions")`, zusätzlich `"answer-sheets"` | Wirkung unverändert | – | K 5.5 |
| `variants` als ausdrückliche Liste bei aktiven Bögen | `"klausurboegen"` wird auch an eine ausdrücklich angegebene Liste angehängt (KA 452–454 stehen hinter der Auto-Auflösung; `varianten: ("druck",)` mit `klausurboegen: true` erzeugt trotzdem die Bögen-Datei) | `"answer-sheets"` wird ebenso angehängt; das steht künftig im Docstring. Wer die Bögen-Datei nicht will, setzt `answer-sheets: false` | Wirkung unverändert | – | L25; Zweifelsfall 16 |
| `preview-variant: auto` | geerbte Variante, sonst `"druck"` | geerbte Variante, sonst `"print"` | Wirkung unverändert | – | – |
| `variants` als Dictionary | wird heute nicht angenommen | bleibt abgelehnt; `klassenarbeit` hat kein `variant-overrides` | unverändert | – | A.2 |
| `page-counter` (ex `page-numbering`) | `true`, `"reset"` | `"restart"` | zusammengelegt | ja | Zweifelsfall 2 |
| `page-counter` | `"continuous"` | `"continuous"` | unverändert | – | Zweifelsfall 2 |
| `page-counter` | `false` | `none` | Typ geändert | ja | K 5.2 |
| `logo` | `"angela"` | `"angela"` (Eigenname), Vorgabe `auto` | unverändert als Wert | – | K 2.1, `names.txt` |
| Bündel-Dateien | `<name>.pdf`, `<name> - Lösung.pdf`, `<name> - Klausurbögen.pdf` | unverändert | unverändert | – | eingefrorene Außenschnittstelle im Sinn von K 2.1; Zweifelsfall 8 |
| Ersatz-Basisname | `"Klassenarbeit " + str(id)` | unverändert | unverändert | – | Ausgabe ist deutsch (K 2.1) |
| Dateiname aus content-Titel | nur bei `type(title) == str` | auch aus content mit reinem Text | Fehler behoben | – | Inventar 4.1/2 |
| Fuß | „Seite x von y" | unverändert | unverändert | – | K 2.1 |
| PDF-Dokumenttitel der Bündel-Dateien | `[#title – Lösung]`, `[#title – Klausurbögen]` (KA 471, 482) | unverändert | unverändert | – | Ausgabe ist deutsch (K 2.1) |

### 1.6 Interne Funktionen, State, Counter, Labels, Theme-Schlüssel

Alles in dieser Tabelle steht künftig in `src/internal.typ` und ist nur als `klassenarbeit.internal.<name>` erreichbar (K 7.2). Codemod: entfällt, kein Dokument schreibt diese Namen; im Anhang stehen sie im Block `intern`, den der Codemod nie auf Dokumente anwendet.

| alt | neu | Art | Begründung |
|---|---|---|---|
| `_ka-counter` = `counter("klassenarbeit")` | `internal.exam-counter` = `counter("schule/klassenarbeit/exam-counter@1")` | umbenannt | K 7.2, K 7.3, L20 |
| `_state_ka_variante` = `state("ka-variante", none)` | `internal.variant-state` = `state("schule/klassenarbeit/variant@1", none)`; gespeicherte Werte `"print"`, `"solutions"` | umbenannt | K 7.3; neues Schema, weil sich die Werte ändern |
| `_state_ab_scope` (aus arbeitsblatt, `state("ab-scope")`) | `arbeitsblatt.internal.scope-state`, Schlüssel `"schule/arbeitsblatt/scope@1"` | umbenannt | K 7.3 (Beispiel dort) |
| `_theme-aufloesen` (aus arbeitsblatt) | `arbeitsblatt.internal.<…>` (Name legt die arbeitsblatt-Tabelle fest) | intern | K 7.2 |
| `_klassenarbeit-einzeln(variante:, scope:, ka-id:, …)` | `internal.exam-single(variant:, scope:, exam-id:, …)`; übrige Parameter wie `klassenarbeit` | umbenannt | K 7.2 (interne Namen sind immer englisch; `exam` ist das Parameterwort zu `klassenarbeit`, K 2.1b), L5 (`ka` ist keine erlaubte Abkürzung) |
| – Parameter `variante: "druck"` | `variant: "print"` (`"print"` \| `"solutions"`) | umbenannt | G 58 |
| – Parameter `scope: none` | `scope: none` | unverändert | Wortliste B |
| – Parameter `ka-id: 1` | `exam-id: 1` | umbenannt | L5 |
| `_klausurboegen-inhalt(title:, subtitle:, teacher:, class:, date:, einstellungen:)` | `internal.answer-sheets-variant(title:, subtitle:, teacher:, class:, date:, logo:, subtask-numbering:, settings:)` (erzeugt die Variante `"answer-sheets"`) | umbenannt | K 7.2; `einstellungen` → `settings` (Wortliste B); Abstand zu `klausurboegen.internal.exam-on-sheet` (2.2) bewusst groß, L10 sinngemäß |
| lokale Funktion `header(title:, subtitle:, class:, date:, teacher:, logo:)` (KA 139) | `internal.exam-header(…)`, gleiche Parameter, Vorgaben `none` | umbenannt | L12 (kein Name aus `std` überdecken), K 5.2 |
| `logos` (Dictionary in `logos.typ`, Schlüssel `angela`) | `internal.logos`, Schlüssel `angela` | intern | K 2.1 (Eigenname) |
| Label `ende-arbeitsblatt-id-<id>-<variante>` | `<schule-klassenarbeit-end-<id>-<variant>>` | umbenannt | K 7.3; behebt Inventar 3.1/14 |
| `metadata("ende-des-dokuments")` | `metadata("schule/klassenarbeit/document-end")` | umbenannt | K 2.1 (englisch), analog K 7.3 |
| `<ab-meta>` (geschrieben von `arbeitsblatt-einzeln`, arbeitsblatt.typ Z. 590–602): immer alle elf Schlüssel `titel`, `klasse`, `fach`, `thema`, `jahrgang`, `stufe`, `niveau`, `typ`, `stichworte`, `kerncurriculum`, `stand`; klassenarbeit setzt `typ` nicht (bleibt `none`) | unverändert elf Schlüssel (eingefroren; Namen und Abbildung in der arbeitsblatt-Tabelle, `arbeitsblatt.internal.meta-keys`); `klassenarbeit` füllt `titel` und `klasse`, die übrigen neun sind `none`, auch `typ` | eingefroren | K 2.1, K 7.3; Zweifelsfall 4 |
| Scope-Werte `"ka-<id>-druck"`, `"ka-<id>-loesung"` | `"exam-<id>-print"`, `"exam-<id>-solutions"` | umbenannt | K 5.3 |
| aus dem Theme entfernte Schlüssel `kopf`, `fuss`, `hintergrund`, `rand`, `header-ascent` (KA 88) | `header`, `footer`, `background`, `margin`, `header-ascent` | umbenannt (folgt A.12) | K 5.4, L18 |
| aus dem Theme gelesene Schlüssel `schrift.text`, `schrift.mathe` (KA 92, 96–97) | `font`, `math-font` | umbenannt (folgt A.12) | G 48, K 5.4 (kein verschachteltes `fonts`) |
| Aufruf `arbeitsblatt-einzeln(…)` | `arbeitsblatt-einzeln(…)` (Name bleibt, K 2.1a) mit `header:`, `print: true`, `scope:`, `page-settings:` | folgt arbeitsblatt | A.1 |
| Aufruf `set-options((punkte-template-aufgabe:, punkte-template-teilaufgabe:))` | `set-options(points-format: …)` | folgt aufgaben | A.5 |
| Aufruf `show-offene-loesungen()` | `show-solutions(select: "pending")` | folgt aufgaben | G 86, A.5 |
| Aufruf `show-erwartungen(..einstellungen)` | `show-expectations(..)` nach Prüfung der Schlüssel | folgt aufgaben | A.5, K 8.4 |
| lokale Variablen (`kopf-abstand`, `tpl-aufgabe`, `weitere-args`, `schrift`, `th`, `table` …) | englisch, kebab-case; `table` entfällt als Variablenname | umbenannt | K 2.1, L13 |

### 1.7 Fehlermeldungen

| alt (wörtlich) | neu | Begründung |
|---|---|---|
| ``klassenarbeit: ungültiger Wert für `page-numbering`: <repr> – erlaubt: true, false, "reset", "continuous"`` | ``klassenarbeit.klassenarbeit: `page-numbering` heißt jetzt `page-counter` `` bzw. ``klassenarbeit.klassenarbeit: `page-counter: "reset"` heißt jetzt `"restart"` `` bzw. ``klassenarbeit.klassenarbeit: `page-counter: <repr>` ist kein gültiger Wert – erlaubt: `none`, `"restart"`, `"continuous"` `` | K 8.2, K 8.3 |
| ``klassenarbeit: `erwartungen` muss true, false oder ein Dictionary sein, erhalten: <repr>`` | ``klassenarbeit.klassenarbeit: `expectations` erwartet `true`, `false` oder ein Dictionary, bekam `<repr>` (<typ>) – zum Beispiel `expectations: (achieved: true)` ``; für `"keine"`, `"false"`, `"none"`, `none` als falsches Aus: ``klassenarbeit.klassenarbeit: `expectations: "keine"` – das Aus ist `false` `` | K 8.3 (falscher Typ, falsches Aus), K 5.2 |
| `Unbekannte Klassenarbeit-Variante: <repr>` (per `panic`) | ``klassenarbeit.klassenarbeit: `variants: "druck"` heißt jetzt `"print"` `` bzw. ``… ist kein gültiger Wert – erlaubt: `"print"`, `"solutions"`, `"answer-sheets"` ``; für den deutschen Bausteinnamen als Wert: ``klassenarbeit.klassenarbeit: `variants: "klausurboegen"` ist kein gültiger Wert – meintest du `"answer-sheets"`? erlaubt: `"print"`, `"solutions"`, `"answer-sheets"` `` und ebenso ``klassenarbeit.klassenarbeit: `variants: "loesung"` ist kein gültiger Wert – meintest du `"solutions"`? erlaubt: `"print"`, `"solutions"`, `"answer-sheets"` `` (`loesung` ist Baustein nach K 2.1a, Parameterwort `solutions`); nur `"druck"` behält die Form „heißt jetzt“ | K 8.1 (kein `panic`), L21, K 8.3 (Meldungsart „deutscher Bausteinname als Wert“) |
| ``arbeitsblatt: unbekannte Option(en): … – Tippfehler?`` (für Tippfehler im KA-Kopf) | ``klassenarbeit.klassenarbeit: unbekannter Parameter `…` – meintest du `…`?`` | K 8.2 (Paket und Funktion des Aufrufs) |
| Typst „unexpected argument" bei unbekanntem Schlüssel in `klausurboegen: (…)` | ``klassenarbeit.klassenarbeit: unbekannter Parameter `answer-sheets.weisser-rand` – `weißer-rand` heißt jetzt `correction-margin-blank` `` | K 8.4 (Prüfung vor Weitergabe, Umlaut-Faltung) |

### 1.8 Vorlage `template/ka.typ`

| alt | neu |
|---|---|
| `#import "@schule/klassenarbeit:0.4.0": *` | `#import "@schule/klassenarbeit:0.4.1": *` |
| `#show: klassenarbeit.with(` | unverändert (Baustein) |
| `title: [Klassenarbeit]` … `teacher: [SLZ]` | unverändert (content bleibt erlaubt) |
| `punkte: "alle"` | `points: "all"` |
| `loesungen: "keine"` | Zeile entfällt (Vorgabe `none`) |
| `erwartungen: (erreicht: true)` | `expectations: (achieved: true)` |
| `klausurboegen: (muster: "kariert", korrekturrand: "aussen")` | `answer-sheets: (pattern: "squares", correction-margin-side: "outside")` |
| Z. 9, 10: Kommentare mit Wertelisten (falsch: `aufgabe, teilaufgabe`) | aus `internal.option-schema` erzeugt oder gestrichen |
| Z. 11: Kommentar `// true, false oder Einstellungen für show-erwartungen; erreicht: …` | `// true, false oder Einstellungen für show-expectations; achieved: „_ / X" zum Eintragen` |
| Z. 13: Kommentar `// kariert, liniert` | `// "squares", "lines"` |
| Z. 14: Kommentar `// aussen (am Blattrand), innen (an der Falz)` | `// "outside" (am Blattrand), "inside" (an der Falz)` |
| Z. 16–18: Kommentar verspricht `"{Titel}.pdf"`, nennt `klausurboegen: true` | Dateinamen wie in 1.5, `answer-sheets: true` |
| Z. 19: `// Einzelkompilation: variante: "druck" \| "loesung" \| "klausurboegen"` | `// Einzelkompilation: preview-variant: "print" \| "solutions" \| "answer-sheets"` |

---

## 2. klausurboegen 0.0.4 + 0.0.5 → 0.4.1

Die Zusammenführung der Äste geschieht **vor** der Umbenennung (K 9.4 Nr. 1): Basis ist 0.0.4 (ausgelagerte Kopf- und Tabellen-Helfer, Vordruck, Namen, Arbeit auf dem Bogen, Filter für leere CSV-Zeilen), darauf aus 0.0.5 die drei Muster-Optionen (`muster`, `linienabstand`, `korrekturrand`) **und das Seitenlayout** mit den Helfern `falz-links`, `rand-links`, `schreibfeld`, `halbseite`, die es nur in 0.0.5 gibt (0.0.4 setzt die Hälften mit verschachtelten `table` und `kariert(height: 30cm, …)`, Z. 434–460).

### 2.1 `klausurbögen` → `klausurboegen`

Alt 0.0.5 (wörtlich, `klausurboegen.typ` 37–58):

```typ
#let klausurbögen(
  exam: "",
  subexam: "",
  teacher: "SLZ",
  class: "PH1",
  date: "09.10.2023",
  students: (),
  sek1: false,
  result: false,
  rand: 5cm,
  scale: 1,
  sub: false,
  numbering: "a)",
  mv: (dx: 0cm, dy: 0cm),
  weißer-rand: true,
  result-table: true,
  vorschlag: false,
  line-stroke: 1pt + rgb("FF0613"),
  muster: "kariert",
  linienabstand: 8mm,
  korrekturrand: "aussen",
) = [
```

Alt 0.0.4 (wörtlich, 390–410): dieselben ersten 17 Parameter, statt der letzten drei:

```typ
  vordruck: false,
  namen: false,
) = [
```

Neu (A.6 wörtlich, dazu zwei Zeilen aus dem Ast 0.0.4, markiert; `subtask-numbering` nach der aufgaben-Tabelle 2.1 als W3 mit Paketregel):

```typ
#let klausurboegen(
  title: none,                  // W4 str | content; none = Blankobogen ohne Kopf und Seitenzahlen
  subtitle: none,               // W4
  teacher: none,                // W4
  class: none,                  // W4
  date: none,                   // W4
  logo: auto,                   // W8 content | str; auto = Schullogo, none = keins
  results: (),                  // W3 CSV-Zeilen: Kopfzeile, Maximalpunkte, je Schüler (Name, Note, Punkte …)
  overprint: false,             // W1 nur Tabelle und Note zum Überdrucken
  overprint-name: false,        // W1 AUS 0.0.4 (namen): beim Überdrucken den Schülernamen aus Spalte 0 hinter „Name:" setzen; wirkt nur mit overprint
  stage: "sek-2",               // W2 "sek-1" | "sek-2"; bestimmt den Notenschlüssel
  continuation: false,          // W1 Folgebogen ohne Ergebnisbereich
  points-table: true,           // W1 Platz für die Punktetabelle (wirkt nur mit continuation)
  points-table-preprinted: false, // W1 AUS 0.0.4 (vordruck: "werte"): Tabelle steht schon auf dem Bogen
  proposal: none,               // W4 str | content
  subtask-numbering: "a)",      // W3 str, Regel wie aufgaben 2.1
  pattern: "squares",           // W2 "squares" | "lines"; Enum-Wert englisch (K 5.3), gemeint sind kariert und liniert
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

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `klausurbögen` (Funktion) | `klausurboegen`; `klausurbögen` wird abbrechender Stub in `src/removed.typ` mit ``klausurboegen.klausurbögen: `klausurbögen` heißt jetzt `klausurboegen` `` | umbenannt (nur Umschrift ö → oe) | – | ja | G 12, K 2.3, K 9.3 (Tabelle der Bausteine mit geänderter Schreibweise; Funktionsname gleich Paketname). Eine Funktion `klausurboegen` hat es in keiner Version gegeben (0.0.1–0.0.5 definieren nur `klausurbögen`; im Bestand 0 Aufrufe `klausurboegen(`), der neue Name trifft also auf keinen Bestandsaufruf mit anderer Bedeutung; Zweifelsfall 12 |
| `exam: ""` | `title: none` | umbenannt, Default geändert | `""` → Argument löschen (Blankobogen bleibt Blankobogen) | ja | G 13, G 2 (`exam:` als Titel verboten), K 5.2 |
| `subexam: ""` | `subtitle: none` | umbenannt, Default geändert | `""` → löschen | ja | G 14 |
| `teacher: "SLZ"` | `teacher: none` | Default geändert | fehlt das Argument und ist `exam` gesetzt, ergänzt der Codemod `teacher: "SLZ"` (gleiches PDF) | ja (AST) | G 19 („Vorgabe SLZ entfällt") |
| `class: "PH1"` | `class: none` | Default geändert | fehlt das Argument: Codemod ergänzt `class: "PH1"` | ja (AST) | G 15, Inventar 4.2/28 |
| `date: "09.10.2023"` | `date: none` | Default geändert | fehlt das Argument: Codemod ergänzt `date: "09.10.2023"` | ja (AST) | G 18 („Vorgabe entfällt") |
| – (fest `image("logo.svg")`) | `logo: auto` | neu | `auto` = heutiges Bild | – | A.6, W8; behebt Inventar 1.9 (Logo nicht durchgereicht) |
| `students: ()` | `results: ()` | umbenannt | Gestalt der Zeilen unverändert | ja | G 82 (`students` als Notendaten verboten) |
| `sek1: false` | `stage: "sek-2"` | umbenannt, Typ geändert (W2) | `false` → Argument löschen; `true` → `"sek-1"` | ja | G 23, K 9.2 (Pflichteintrag), L5 |
| `result: false` | `overprint: false` | umbenannt | – | ja | A.6, G 82 (`result` verboten) |
| `rand: 5cm` | `correction-margin: 5cm` | umbenannt | – | ja | G 53 |
| `scale: 1` | `grid-size: 0.5cm` | umbenannt, Typ geändert (Faktor → Länge) | `scale: n` → `grid-size: n * 0.5cm` (`1` → löschen, `1.2` → `0.6cm`) | teilweise (Literalzahlen) | G 63, K 5.5 (keine Faktoren), K 9.2 |
| `sub: false` | `continuation: false` | umbenannt | Wert bleibt (nicht umgedreht) | ja | A.6, K 4.3, L5 |
| `numbering: "a)"` | `subtask-numbering: "a)"` | umbenannt, Typ präzisiert (W3 mit Paketregel) | `"a)"` → löschen; `"1."` → `"1.1"`; jeder andere Wert (heute „Ziffern") → `"1.1"` mit Bericht | teilweise | G 39, K 6, aufgaben 2.1; Zweifelsfall 9 |
| `mv: (dx: 0cm, dy: 0cm)` | `offset: (dx: 0cm, dy: 0cm)` | umbenannt | Schlüssel `dx`, `dy` bleiben (Typst) | ja | G 74, K 5.4 |
| `weißer-rand: true` | `correction-margin-blank: true` | umbenannt | Wert bleibt | ja | G 53, K 2.3 |
| `result-table: true` | `points-table: true` | umbenannt | Wert bleibt; wirkt weiter nur mit `continuation: true` | ja | A.6 |
| `vorschlag: false` | `proposal: none` | umbenannt, Typ geändert (W4) | `false` → Argument löschen; str/content bleibt | ja | G 83, K 5.2 |
| `line-stroke: 1pt + rgb("FF0613")` | `correction-margin-stroke: 1pt + rgb("FF0613")` | umbenannt | – | ja | G 30 (`<ziel>-stroke`), G 53 |
| `muster: "kariert"` | `pattern: "squares"` | umbenannt | `"kariert"` → `"squares"` (bzw. löschen); `"liniert"` → `"lines"` | ja | G 62 |
| `linienabstand: 8mm` | `line-height: 8mm` | umbenannt | – | ja | G 64 |
| `korrekturrand: "aussen"` | `correction-margin-side: "outside"` | umbenannt | `"aussen"`, `"außen"` → `"outside"` (bzw. löschen); `"innen"` → `"inside"` | ja | G 53, G 73, K 9.3 (keine Wert-Aliase) |
| `vordruck: false` (0.0.4) | `points-table-preprinted: false` | umbenannt, Typ geändert (W1) | `false` → löschen; `true` → löschen (wirkt heute wie `false`, per Kompilieren bestätigt); `"werte"` → `true` | ja | K 11.4 **[prüfen]** aufgelöst: Wirkung ist nicht dieselbe wie `overprint`; Zweifelsfall 5 |
| `namen: false` (0.0.4) | `overprint-name: false` | umbenannt | Wert bleibt; wirkt weiter nur mit `overprint: true` (0.0.4 Docstring Z. 386–388: druckt den Namen aus der ersten Spalte hinter „Name:", zur Kontrolle der Reihenfolge) | ja | K 4.3 (der Name sagt, was bei `true` geschieht: es entstehen keine Felder); Geschwister von `overprint`; Abstand zu `name-field` in `klassenarbeit`; weicht von K 11.4 (`name-fields`) ab, Zweifelsfall 5 |
| – | `..deprecated` | neu | fängt alle alten Namen dieser Tabelle mit „heißt jetzt" | – | K 4.4 Nr. 5c, K 9.2 |

Rückgabe: content, unverändert. Feste Werte bleiben: A3 quer, Rand 0, zwei Hälften 21 cm × 29,7 cm; Kopfhöhen 8 cm / 6 cm / 3 cm; Notenschlüssel Sek I `(0.875, 0.75, 0.625, 0.5, 0.2, 0)` und Sek II (16 Stufen). Feste Ausgabetexte (deutsch, K 2.1): „Aufgabe", „mögliche Punkte", „erreichte Punkte", „Note", „Punktegrenzen" (Sek I) und „Punktegrenze ≥" (Sek II, KB 288), die Notenwörter „sehr gut" bis „ungenügend" (KB 303), „ Punkt" / „ Punkte" (KB 313–315), „Name:", „Ergebnis:"; aus 0.0.4 „Bitte frei lassen" (Z. 792), „Platz für Nebenrechnungen" (Z. 848) und der rote Warntext „Die Arbeit passt nicht auf einen Klausurbogen: …" (Z. 841).

CSV-Konvention von `results` (Daten, unverändert): Spalte 0 Name, Spalte 1 Note, ab Spalte 2 Aufgaben; Teilaufgaben in der Kopfzeile als `"A1 a)"` oder `"A1.1"`; Zellen mit Leerzeichen werden übersprungen; leere Zelle zählt 0. Leere Zeilen werden herausgefiltert wie in 0.0.4 (Z. 569 `students.filter(r => r.len() > 1 and r.any(c => c.trim() != ""))`); 0.0.5 filtert nicht, die zusammengeführte Fassung übernimmt den Filter.

### 2.2 Ast 0.0.4: `bogen-seiten`, `klausurbogen-arbeit`

Alt (wörtlich, 0.0.4 Z. 741–759 und 889):

```typ
#let bogen-seiten(
  exam: "",
  subexam: "",
  teacher: "",
  class: "",
  date: "",
  sek1: false,
  sub: false,
  result-table: true,
  vorschlag: false,
  numbering: "a)",
  mv: (dx: 0cm, dy: 0cm),
  aufgaben: none,
  tabelle: false,
  rueckseite: auto,
  rand: 12mm,
  unten: 16mm,
  abstand: 4mm,
) = {

#let klausurbogen-arbeit(..args, body) = {
```

Neu: nach K 11.4 (Empfehlung) nicht mehr exportiert, sondern in `klausurboegen/src/internal.typ`. Erreichbar für Dokumente über `klassenarbeit(answer-sheet-pages: …)`; weil dessen Dictionary-Schlüssel öffentlich sind (K 2.1), folgen die Parameternamen dem Glossar.

```typ
// klausurboegen/src/internal.typ
#let answer-sheet-pages(
  title: none,
  subtitle: none,
  teacher: none,
  class: none,
  date: none,
  logo: auto,
  stage: "sek-2",
  continuation: false,
  points-table: true,
  points-table-preprinted: false,   // muss beim späteren klausurboegen(overprint: true) gleich stehen
  proposal: none,
  subtask-numbering: "a)",
  offset: (dx: 0cm, dy: 0cm),
  task-points: (),                  // array aus Paaren (name, points) oder (name, (points …))
  back-page: auto,                  // W5 content; auto = „Platz für Nebenrechnungen"
  margin: (top: 12mm, bottom: 16mm, x: 12mm),   // W7 length | (top:, bottom:, x:); andere Schlüssel sind ein Fehler
  header-spacing: 4mm,              // Abstand zwischen Kopfbereich und erster Aufgabe (ein v(…), nicht page.header-ascent)
  ..deprecated,
) = { }                             // -> (page: …, gutter: …, preamble: …)

#let exam-on-sheet(..args, body) = { }   // ex klausurbogen-arbeit
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `bogen-seiten` (öffentlich) | `internal.answer-sheet-pages`; öffentlich bleibt eine abbrechende Funktion `bogen-seiten` mit Hinweis auf `klassenarbeit(answer-sheet-pages: …)` | intern | – | nein | K 11.4, K 7.2, K 9.3 letzter Punkt |
| `klausurbogen-arbeit(..args, body)` | `internal.exam-on-sheet(..args, body)`; öffentlich bleibt eine abbrechende Funktion `klausurbogen-arbeit` mit Hinweis auf `klassenarbeit.with(answer-sheet-pages: true)` | intern | – | nein (1 Dokument auf 0.0.4) | K 11.4; Name mit Abstand zu `klassenarbeit.internal.answer-sheets-variant` (vorher unterschieden sich `answer-sheet-document` und `answer-sheets-document` nur um ein `s`) |
| `exam`, `subexam` | `title`, `subtitle` | umbenannt, Default `""` → `none` | `""` → löschen | ja (AST) | G 13, G 14 |
| `teacher: ""`, `class: ""`, `date: ""` | `none` | Default geändert | `""` → löschen | ja | K 5.2 |
| `sek1`, `sub`, `result-table`, `vorschlag`, `numbering`, `mv` | `stage`, `continuation`, `points-table`, `proposal`, `subtask-numbering`, `offset` | wie 2.1 | wie 2.1 | ja (AST) | L6 (gleicher Name, gleicher Typ in allen Funktionen) |
| `aufgaben: none` | `task-points: ()` | umbenannt, Default geändert | `none` → löschen | ja (AST) | G 3 (`aufgaben-` verboten), L9 (Vorgabe `()` verlangt Plural), K 4.5 letzter Punkt (das bloße Parameterwort `tasks` nicht ohne Zusatz, es ließe den Typ nicht erkennen) |
| `tabelle: false` | `points-table-preprinted: false` | umbenannt | Wert bleibt (nicht umgedreht) | ja (AST) | K 4.3; derselbe Name und Wert wie beim späteren Ergebnisdruck |
| `rueckseite: auto` | `back-page: auto` | umbenannt | – | ja (AST) | K 2.3, Leitregel; neues Wort `back` |
| `rand: 12mm`, `unten: 16mm` | `margin: (top: 12mm, bottom: 16mm, x: 12mm)` | zusammengelegt, Typ geändert (W7: eine Länge für alle drei oder Dictionary mit den festen Schlüsseln `top`, `bottom`, `x`) | `rand: r` → `margin: (top: r, bottom: 16mm, x: r)`; `unten: u` → `margin: (top: 12mm, bottom: u, x: 12mm)`; beide → `margin: (top: r, bottom: u, x: r)`. Andere Typst-Schlüssel (`left`, `right`, `inside`, `outside`, `y`, `rest`) sind ein Fehler mit Abhilfe: ``… `margin.left` gibt es hier nicht – erlaubt: `top`, `bottom`, `x` ``, weil das Paket mit dem Wert rechnet (Spaltenabstand `2 * x`, Vorschub `… - top + header-spacing`; KB4 860, 874) | teilweise (Kontext, Literale) | G 52 (`rand` verboten), K 5.4; **W7 statt W9**: der Durchreichtest scheitert (der Wert wird verrechnet, nicht nur durchgereicht); Zweifelsfall 15 |
| `abstand: 4mm` | `header-spacing: 4mm` | umbenannt | – | ja (AST) | G 34 (`spacing` = Abstand zwischen gestapelten Einträgen: Kopfbereich und erste Aufgabe); **nicht** `header-ascent`: das ist Typsts `page(header-ascent:)` und steht im selben `klassenarbeit`-Aufruf in `page-settings` mit dieser Bedeutung, `abstand` ist dagegen ein `v(…)` (KB4 860), `page.header` ist dort `none` (Leitregel „ein Wort, eine Bedeutung") |
| Rückgabe-Schlüssel `page` | `page` | unverändert | – | – | Typst-Wort |
| Rückgabe-Schlüssel `gutter` | `gutter` | unverändert | – | – | G 33 |
| Rückgabe-Schlüssel `anfang` | `preamble` | umbenannt | – | intern | K 7.2 (intern, ohne Glossarpflicht) |

Schlüssel im Dictionary `klassenarbeit(answer-sheet-pages: (…))`, heute `klassenarbeit 0.3.1 (bogen: (…))`. Das Dictionary wird zuletzt gespreizt (klassenarbeit/0.3.1 Z. 263–271 `..einstellungen`), es kann also auch die von klassenarbeit gesetzten Werte überschreiben; deshalb sind **alle** Parameter von `bogen-seiten` gültige Schlüssel.

| alt | neu | Art | Codemod | Begründung |
|---|---|---|---|---|
| `sek1`, `sub`, `result-table`, `vorschlag`, `numbering`, `mv`, `tabelle`, `rueckseite`, `abstand` | `stage`, `continuation`, `points-table`, `proposal`, `subtask-numbering`, `offset`, `points-table-preprinted`, `back-page`, `header-spacing`; Wertabbildungen wie oben | wie oben | ja (AST) | W6 |
| `exam`, `subexam`, `teacher`, `class`, `date`, `aufgaben` (von klassenarbeit gesetzt, im Dictionary überschreibbar) | `title`, `subtitle`, `teacher`, `class`, `date`, `task-points`; `""` → löschen, `aufgaben: none` → löschen | wie oben | ja (AST) | W6, L24 |
| `rand`, `unten` | `margin: (top:, bottom:, x:)` | zusammengelegt | teilweise (Kontext) | wie oben. Achtung Doppeldeutigkeit: in `klausurboegen: (rand: 5cm)` ist `rand` der Korrekturrand (→ `correction-margin`), in `bogen: (rand: 12mm)` der Seitenrand (→ `margin`); der Codemod entscheidet nach dem umgebenden Parameter |
| `seite4` (Aufgaben auf der Rückseite, von klassenarbeit verarbeitet) | `back-page-tasks` (W4 content) | umbenannt | ja (AST) | Leitregel, L1 (keine Ziffer als Wort) **[prüfen]** |
| `seite4` und `rueckseite` zugleich (heute überschreibt `seite4` ein gesetztes `rueckseite` still, 0.3.1 Z. 241–251) | `back-page` und `back-page-tasks` zugleich ist ein Fehler: ``klassenarbeit.klassenarbeit: `answer-sheet-pages.back-page` und `back-page-tasks` zugleich – eines von beiden angeben`` | Fehler behoben | Bericht | K 8.1 (nichts still übergehen), K 8.3 (unzulässige Kombination), K 4.4 Nr. 4 |
| `teilaufgaben: true` (Spalte je Teilaufgabe in der Punktetabelle; `false`: nur Aufgabensummen) | `points-table-subtasks: true` (W1) | umbenannt | ja (AST) | Geschwister von `points-table`; benennt, was bei `true` in der Tabelle steht (K 4.3). **Nicht** `subtask-columns`: `columns` ist nach G 36, K 5.5 und L22 eine Anzahl oder Typst-Spaltenangabe |
| von klassenarbeit gesetzt: `exam`, `subexam`, `class`, `date`, `teacher`, `aufgaben` | `title`, `subtitle`, `class`, `date`, `teacher`, `logo`, `subtask-numbering`, `task-points` | intern | – | – |

### 2.3 Helfer (alle nach `internal`, kein Dokument schreibt sie)

Die Kopf-, Noten- und Tabellen-Helfer kommen aus 0.0.4 (dort ausgelagert), die vier Layout-Helfer aus 0.0.5 (in 0.0.4 gibt es sie nicht). `points-table` ist im ganzen Paket ausschließlich der W1-Schalter; Inhalte heißen `…-content`, damit kein Name zwei Typen hat (L6) und kein Parameter wie eine Funktion des Pakets heißt (K 4.5).

| alt 0.0.5 (lokal in `klausurbögen`) | alt 0.0.4 | neu in `internal` | Art |
|---|---|---|---|
| `klausurbogen(result:, name:, note-content:, student-table:, grade-table:, mv:, sub:, vorschlag:, line-stroke:)` | (lokal, gleich) | `sheet(settings, overprint:, name:, grade-content:, points-content:, grade-table:)` – **wie umgesetzt (0.5.0):** `settings` ist das Dictionary aller Parameter von `klausurboegen`; `offset`, `continuation`, `proposal`, `correction-margin-stroke` stehen darin und sind keine eigenen Parameter | umbenannt |
| `header(title:, subtitle:, class:, date:, teacher:, logo: [])` | `_bogen-kopf(…, result: false)` | `sheet-header(title:, subtitle:, class:, date:, teacher:, logo: none, overprint: false)`; eine gemeinsame Fassung mit `klassenarbeit.internal.exam-header` | umbenannt, zusammengelegt |
| – | `_bogen-namenszeile(result:, sub:, vorschlag:, note-content:, name:)` | `name-line(overprint:, continuation:, proposal:, grade-content:, name:)` | umbenannt |
| – | `_bogen-kopfbox(kopf:, namenszeile:, student-table:, grade-table:, sub:, heigth:)` | `header-box(header:, name-line-content:, points-content:, grade-table:, continuation:, height:)` | umbenannt (Tippfehler `heigth` behoben) |
| (inline, Z. 108–114) | `_bogen-kopfhoehe(sub:, result-table:)` | `header-height(continuation:, points-table:)` (`points-table` hier bool wie in `klausurboegen`) | umbenannt |
| `gradeBoundaries(maxPoints: 100)` | `_notentabelle(maxPoints:, sek1:, result:, mv:)` | `grade-boundaries(max-points:, stage:, overprint:, offset:)` | umbenannt (G 22) |
| `note-display(percentage:, note:)` | `_note-anzeige(percentage:, note:, sek1:, sub:, mv:)` | `grade-display(percentage:, grade:, stage:, continuation:, offset:)` | umbenannt (G 22) |
| `createTable(cols:, maxPoints:, achievedPoints:, result:)` | `_punktetabelle(cols:, maxPoints:, achievedPoints:, result:, sek1:, numbering:, mv:, teil:)` | `points-table-content(columns:, max-points:, achieved-points:, overprint:, stage:, subtask-numbering:, offset:, part:)` | umbenannt |
| – | `teil: "alles" \| "rahmen" \| "werte"` | `part: "all" \| "frame" \| "values"` | umbenannt |
| `studentHeader(name:, percentage:, note:)` (Z. 333) | `studentHeader(…)` (Z. 544, lokal) | – | entfernt (lokale Funktion, in beiden Ästen nie aufgerufen) |
| `falz-links(seite)`, `rand-links(seite)` | – (nur 0.0.5) | `is-fold-left(page-number)`, `is-margin-left(page-number, side: "outside")` (**wie umgesetzt:** `side` ist `correction-margin-side`, weil der Helfer auf Dateiebene steht und die Lage nicht mehr aus dem Funktionsrumpf liest) | umbenannt |
| `schreibfeld(seite, hoehe)` | – (nur 0.0.5) | `writing-area(page-number, height, pattern: "squares", grid-size: 0.5cm, line-height: 8mm)`; ruft `patterns.kariert`. **Wie umgesetzt, bewusste Abweichung von konvention.md („`klausurboegen` benutzt `liniert` und `kariert` statt eines Nachbaus“):** die Linierung zeichnet der Helfer weiter selbst wie 0.0.5, weil die Linien von `patterns.liniert` anders liegen (halbe Zeile Vorschub, Abstand darunter) und „gleiches PDF“ Vorrang hat | umbenannt |
| `halbseite(seite, oben:, kopf:, nummer:)` | – (nur 0.0.5) | `half-page(page-number, settings, overprint:, top:, header:, number:)` (**wie umgesetzt:** `settings` wie bei `sheet`) | umbenannt |
| lokale camelCase-Variablen (`insetPageNumber`, `gradeBordersSek1`, `seperationLines` …) | – | kebab-case, englisch | umbenannt (K 2.4) |

**Prüfhelfer für `klassenarbeit` (wie umgesetzt in klausurboegen 0.5.0, `src/internal.typ`).** `internal.check-names(package-name, function, named, values: (:), prefix: "")` und `internal.check-values(package-name, function, values, prefix: "")` prüfen Namen bzw. Typen und Werte mit denselben Tabellen wie der Baustein (`internal.renamed-parameters`, `internal.allowed-parameters`, `internal.parameter-defaults`). Für das Dictionary `answer-sheets` ruft klassenarbeit beide mit `prefix: "answer-sheets."` und dem ganzen Dictionary als `named` bzw. `values`; die Meldungen lauten dann ``klassenarbeit.klassenarbeit: `answer-sheets.weißer-rand` heißt jetzt `answer-sheets.correction-margin-blank` ``, ``… `answer-sheets.muster: "kariert"` heißt jetzt `answer-sheets.pattern: "squares"` `` und ``… unbekannter Schlüssel `answer-sheets.patern` – meintest du `answer-sheets.pattern`?`` (Form von `check-named`; die in 1.7 skizzierte Mischform „unbekannter Parameter … – … heißt jetzt“ erzeugt `check.typ` nicht). `internal` exportiert außerdem die Prüffunktionen aus `check.typ` (`fail`, `check-named` …), aber keinen Namen aus `patterns` oder `tablex`.

**Über die Fehlerliste hinaus (klausurboegen 0.5.0):** `overprint: true` mit weniger als drei Zeilen in `results` bricht ab (0.0.5: leere Seite); `overprint: true` oder nichtleere `results` ohne `title` bricht ab (0.0.4/0.0.5: still ein Blankobogen). Beides steht im Handbuch unter „Was sich sonst geändert hat“.

### 2.4 Enum-Werte und Fehlermeldungen

| Sache | alt | neu | Begründung |
|---|---|---|---|
| `pattern` | `"kariert"`, `"liniert"` | `"squares"`, `"lines"` | G 62, K 5.3 (der Wert ist das Parameterwort aus K 2.1b, nie der deutsche Bausteinname; ein Muster-Enum gibt es nur hier und im Dictionary `answer-sheets` von `klassenarbeit`) |
| `correction-margin-side` | `"innen"`, `"aussen"`, Alias `"außen"` | `"inside"`, `"outside"`; kein Alias | G 73, K 9.3 |
| `stage` | `sek1: true` / `false` | `"sek-1"` / `"sek-2"` | G 23 |
| `subtask-numbering` | `"a)"`, „alles andere = Ziffern" | str mit Paketregel wie aufgaben-Tabelle 2.1, geprüft | W3 (Zweifelsfall 9) |
| `points-table-preprinted` | `vordruck: false \| true \| "werte"`, `tabelle: false \| true` | `false` \| `true` | W1 |
| Meldung | ``klausurbögen: muster muss "kariert" oder "liniert" sein, nicht <repr>`` | ``klausurboegen.klausurboegen: `muster` heißt jetzt `pattern` `` bzw. ``klausurboegen.klausurboegen: `pattern: "kariert"` ist kein gültiger Wert – meintest du `"squares"`? erlaubt: `"squares"`, `"lines"` `` (Meldungsart „deutscher Bausteinname als Wert“, wörtlich aus K 8.3; sie ersetzt für `"kariert"` und `"liniert"` die „heißt jetzt“-Form) bzw. ``… `pattern: <repr>` ist kein gültiger Wert – erlaubt: `"squares"`, `"lines"` `` | K 8.2, K 8.3, K 8.4 (Vorschlag über `wortpaare.json`) |
| Meldung | ``klausurbögen: korrekturrand muss "innen" oder "aussen" sein, nicht <repr>`` | ``klausurboegen.klausurboegen: `korrekturrand` heißt jetzt `correction-margin-side` `` bzw. Wertmeldung mit `"inside"`, `"outside"` | K 8.3 |
| Meldung (0.0.4, `_punktetabelle`) | `teil: "alles", "rahmen" oder "werte"` | über `internal.fail` | L21 |
| neu geprüft | `subtask-numbering`, `proposal`, Gestalt von `results`, Schlüssel von `offset`, Typen der Längen | Meldungen nach K 8.3 | K 8.4 |

---

## 3. patterns 0.0.2 → 0.4.1

### 3.1 `kariert` (Funktionsname bleibt)

Alt (wörtlich, `patterns.typ` 43–55):

```typ
#let kariert(
  rows: 1,
  width: auto,
  items: (),
  items-spacing: 2,
  grid-size: 0.5cm,
  height: none,
  annotations: (),
  line-stroke: (paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt),
  fill-color: white,
  content: [],
  ..args,
) = {
```

Neu (Parameter und Vorgaben nach A.7; `rows` als optionales führendes Hauptargument im Sink, siehe Zweifelsfall 1; eine Zeile geht über A.7 hinaus und ist markiert):

```typ
#let kariert(
  columns: auto,                // W5 int: Breite in Kästchen
  width: auto,                  // W5 length: Breite als Länge. ÜBER A.7 HINAUS (Zweifelsfall 11); columns und width zugleich ist ein Fehler
  height: auto,                 // W5 length; statt rows, beides zugleich ist ein Fehler
  grid-size: 0.5cm,
  items: (),
  item-rows: 2,                 // int
  annotations: (),
  overlay: none,                // W4 content
  stroke: (paint: rgb("#AAAAAA").lighten(10%), thickness: 0.5pt),
  fill: white,
  ..args,                       // (rows) int | fraction, Vorgabe 1; sonst nichts (zugleich Abfang alter Namen)
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `kariert` (Funktion) | `kariert` | unverändert (Baustein, deutsch auf Dauer) | – | – (nichts umzustellen) | G 62, K 2.1a, K 9.3 (kein englischer Zwilling `squares`, kein Alias; `"squares"` bleibt Enum-Wert von `pattern`, K 5.3) |
| `rows: 1` (benannt oder 1. Positionsargument) | führendes Positionsargument `rows`, Vorgabe 1 | Typ geändert (nur noch positional) | `kariert(rows: 4)` → `kariert(4)`; `kariert(4)` bleibt; `rows: 1fr` → `kariert(1fr)` | ja (AST) | A.7, K 4.4 Nr. 2 und 4 (ein Weg), G 37 |
| `width: auto` (nimmt heute Länge **und** Kästchenzahl; auch als 2. Positionsargument) | `width: auto` (nur Länge) und `columns: auto` (nur int) | aufgeteilt nach Typ, Typ geprüft | **Längenliteral bleibt `width:`** (`kariert(2, width: 5cm)` bleibt; `kariert(2, 5cm)` → `kariert(2, width: 5cm)`); **Ganzzahl-Literal wird `columns:`** (`width: 12` → `columns: 12`; `kariert(4, 12)` → `kariert(4, columns: 12)`); alles andere (`scale * 1980mm`, Variablen) → Bericht. Laufzeit: ``patterns.kariert: `width` erwartet eine Länge, bekam `12` (integer) – die Kästchenzahl steht in `columns:` ``; `width` und `columns` zugleich ist eine unzulässige Kombination. Heute bricht eine Länge nur zusammen mit `content` ab (PAT 126); neu geht `width` als Länge auch mit `overlay` | teilweise (Literale) | G 31 (`width` ist Länge), G 36 (verboten ist nur `width` als Kästchenzahl), K 9.2 (der Pflichteintrag `kariert(4, 12)` bleibt gültig), K 5.5/L25 (gleiches PDF): im lokalen Bestand sind alle 16 gefundenen `kariert(… width: …)` Längen (12× 5cm, 2× 7cm, 3cm, `scale * 1980mm`), keine Kästchenzahl; **geht über A.7 hinaus**, Zweifelsfall 11 |
| `items: ()` | `items: ()` | unverändert | – | – | G 78 |
| `items-spacing: 2` | `item-rows: 2` | umbenannt | Wert bleibt (Einheit Kästchen); nicht ganzzahlige Werte laufen heute in `kariert` (auch mit `items`) → Bericht, von Hand | teilweise | G 37, L11 (Bestimmungswort im Singular), K 5.5; Zweifelsfall 10 |
| `grid-size: 0.5cm` | `grid-size: 0.5cm` | unverändert | – | – | G 63 |
| `height: none` | `height: auto` | Default geändert | `height: none` → Argument löschen | ja | A.7 (W5), G 32 |
| `annotations: ()` | `annotations: ()` | unverändert | – | – | Wortliste B |
| `line-stroke: (paint: …, dash: "solid", thickness: 0.5pt)` | `stroke: (paint: rgb("#AAAAAA").lighten(10%), thickness: 0.5pt)` | umbenannt | `dash: "solid"` ist Typsts Vorgabe, Bild unverändert | ja | G 30 (`line-stroke` verboten), Durchreichtest |
| `fill-color: white` | `fill: white` | umbenannt | – | ja | G 27, L4 (`-color`) |
| `content: []` | `overlay: none` | umbenannt, Default geändert | `content: []` → löschen | ja | G 80, K 5.2 |
| `..args` (verschluckt alles) | `..args` (geprüft) | Typ geändert | genau ein Positionsargument erlaubt; zweites: ``patterns.kariert: zweites Positionsargument – die Breite steht in `columns:` (Kästchen) oder `width:` (Länge)``; unbekannte benannte: Meldung nach K 8.3; `rows:` benannt: ``patterns.kariert: `rows` steht vorn ohne Namen – `kariert(4)` schreiben`` | – | K 4.4 Nr. 5b, 5c, Nr. 6 |
| `cnt` (7 Aufrufe im Bestand, heute still verschluckt) | – | entfernt | Fehler „unbekannter Parameter `cnt`"; Codemod löscht das Argument (hatte nie Wirkung) | ja | G 38, K 8.1 |

### 3.2 `liniert` (Funktionsname bleibt)

Alt (wörtlich, `patterns.typ` 155–163):

```typ
#let liniert(
  rows: 1,
  width: auto,
  items: (),
  items-spacing: 1,
  line-height: 1cm,
  line-stroke: (paint: black.lighten(50%), thickness: 0.5pt),
  ..args,
) = {
```

Neu:

```typ
#let liniert(
  width: auto,                  // W5 length
  line-height: 1cm,
  items: (),
  item-rows: 1,                 // int
  stroke: (paint: black.lighten(50%), thickness: 0.5pt),
  ..args,                       // (rows) int | fraction, Vorgabe 1
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `liniert` (Funktion) | `liniert` | unverändert (Baustein, deutsch auf Dauer) | – | – (nichts umzustellen) | G 62, K 2.1a, K 9.3 (kein englischer Zwilling `lines`, kein Alias; `"lines"` bleibt Enum-Wert von `pattern`, K 5.3) |
| `rows: 1` | führendes Positionsargument `rows`, Vorgabe 1 | Typ geändert (nur positional) | `liniert(rows: 3)` → `liniert(3)` | ja (AST) | A.7, K 4.4 |
| `width: auto` (benannt: Länge **oder Zahl** in Zeilenhöhen, PAT 204–206; als 2. Positionsargument nur, wenn Länge) | `width: auto` | Typ geprüft (nur length); nur noch benannt | `liniert(3, 5cm)` → `liniert(3, width: 5cm)`; `liniert(3, 10)` → `liniert(3)` (die Zahl wurde ignoriert); benannt `width: n` mit Zahl-Literal → `width: n * <line-height>` (das `line-height` desselben Aufrufs, sonst `n * 1cm`), sonst Bericht. Laufzeit: eine Zahl ist „falscher Typ" mit Abhilfe | teilweise (Literale) | G 31, K 5.5, K 4.4 Nr. 3; lokal 46 benannte Längen, 0 Zahlen |
| `items: ()` | `items: ()` | unverändert | – | – | G 78 |
| `items-spacing: 1` | `item-rows: 1` | umbenannt | Wert bleibt (Einheit Zeilen). Ohne `items` wird `items-spacing` heute nicht gelesen → ein float dort: Argument löschen. Mit `items` bricht heute jeder float ab (auch `2 × 1.5 = 3.0`), solche Aufrufe gibt es in lauffähigen Dokumenten nicht | ja | G 37; Zweifelsfall 10 |
| `line-height: 1cm` | `line-height: 1cm` | unverändert | – | – | G 64, K 5.5 |
| `lineheight` (0.0.1, in 0.0.2 still verschluckt; 2 Aufrufe im Bestand) | `line-height` | umbenannt | – | ja | G 64 |
| `line-stroke: (paint: black.lighten(50%), thickness: 0.5pt)` | `stroke: (…)` | umbenannt | – | ja | G 30 |
| `..args` | `..args` (geprüft) | Typ geändert | wie 3.1 | – | K 4.4 Nr. 6 |

### 3.3 Flex-Helfer

| alt (wörtlich) | neu (wörtlich) | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `#let flex-feld(hoehe, zeichne) = block(` | `#let flex-area(height, body) = { }` | umbenannt | `height`: fraction; `body`: Funktion `length => content` (so wörtlich in A.7; widerspricht G 79 „`body` ist content" und L6 – als Änderungsantrag gemeldet, Abschnitt 8, nicht still übernommen); alter Name bleibt als abbrechende Funktion | ja | A.7, G 32, K 9.3 letzter Punkt |
| `#let ist-flex-feld(inhalt) = (` | `#let is-flex-area(body) = { }` | umbenannt | Rückgabe bool; alter Name als abbrechende Funktion | ja | A.7, K 4.1 (`is-<adjektiv>`), L24 |
| Vertrag „flexibles Feld = `block` mit `height` vom Typ `fraction`" | unverändert | unverändert | – | – | verbindet `kariert(1fr)` mit `aufgabe(workspace: …)` |
| Kopie `_ist-flex-workspace` in aufgaben (Z. 867) | bleibt als `aufgaben.internal.is-flex-area` (dazu `fixed-flex-area`), weil aufgaben kein @schule-Paket importiert (aufgaben-Tabelle 2.5); Vertrag identisch mit `patterns.is-flex-area`, ein Test vergleicht beide an denselben Eingaben | unverändert (zwei Fassungen, ein Vertrag) | – | – | Inventar 3.7; gleiche Festlegung in beiden Tabellen; zusammenführen, sobald aufgaben patterns importieren darf |

patterns hat keine Enum-Werte, keinen State, keinen Counter, kein Label und keine eigenen Fehlermeldungen (heute keine einzige; neu alle nach K 8.3 mit Präfix `patterns.kariert:` / `patterns.liniert:`).

---

## 4. Öffentliche Oberfläche

### 4.1 klassenarbeit (`src/lib.typ`)

| Gruppe | Namen |
|---|---|
| eigene, exportiert | `klassenarbeit` (Baustein, K 2.1a) |
| Modul | `internal` (`exam-single`, `answer-sheets-variant`, `exam-header`, `exam-counter`, `variant-state`, `logos`, `fail`, `check`). klassenarbeit exportiert **nur das eigene** `internal`; an das von arbeitsblatt, aufgaben und klausurboegen kommt der Paketquelltext über den Modulimport (`#import "@schule/arbeitsblatt:0.4.1" as arbeitsblatt`, dann `arbeitsblatt.internal.…`), `internal` wird nie namentlich importiert |
| namentlich durchgereicht | die Exportliste von arbeitsblatt **ohne dessen `internal`** (Bausteine und englische Namen, die Stubs aus dessen `removed.typ`, die acht Namen aus `fremdnamen.txt`: `canvas`, `draw`, `plot`, `qty`, `num`, `unit`, `stickybox`, `fa-icon`) – K 7.1 |
| wird intern | `_ka-counter`, `_state_ka_variante`, `_klausurboegen-inhalt`, `_klassenarbeit-einzeln` (heute per `*` sichtbar) |
| nicht exportiert | der Baustein `klausurboegen`, wie heute (klassenarbeit importiert ihn nur lokal, KA 23): Nach K 7.1 reicht klassenarbeit die Exportliste von arbeitsblatt durch, und die Bögen schaltet der Parameter `answer-sheets` ein. Der frühere zweite Grund ist entfallen (L14: Funktion und Parameter hießen beide `answer-sheets`). Wer Bögen ohne Klassenarbeit braucht, schreibt `#import "@schule/klausurboegen:0.4.1": klausurboegen` |

Entfallende Re-Exporte (heute über `#import "@schule/arbeitsblatt:0.4.0": *`):

| heute sichtbar | künftig |
|---|---|
| alles aus cetz, cetz-plot, fontawesome, colorful-boxes, gentle-clues, codly, zero, eqalc außer den acht Fremdnamen | das Dokument importiert das Preview-Paket selbst, zum Beispiel `#import "@preview/cetz:0.4.2"` |
| `random` mit `a`, `m`, `lcg` …, `informatik`, `physik`, `mathematik`, `operatoren`, `insert-a-word`, `energy-sketch` | `#import "@schule/<paket>:0.4.1": …` im Dokument, soweit arbeitsblatt sie nicht namentlich weiterreicht (regelt die arbeitsblatt-Tabelle) |
| `_state_ab_scope`, `_theme-aufloesen`, `_state_options`, `print-state`, `c_canvas`, `tasks`, `lücke`, `loesungsmodus` | `internal` bzw. abbrechende Stubs nach K 9.3 (`lücke` heißt jetzt `luecke`, `tasks` heißt jetzt `teilaufgaben`, `loesungsmodus` heißt jetzt `has-solutions`) |
| `arbeitsblatt-einzeln` | entfällt nicht: bleibt unter diesem Namen (Baustein, K 2.1a) und wird namentlich durchgereicht |

### 4.2 klausurboegen (`src/lib.typ`, heute `klausurboegen.typ` im Wurzelverzeichnis)

| Gruppe | Namen |
|---|---|
| eigene, exportiert | `klausurboegen` (Baustein, K 2.1a; Funktionsname gleich Paketname) |
| abbrechende Stubs in `src/removed.typ` (Laufzeit der Compat-Tabelle) | `klausurbögen`, `bogen-seiten`, `klausurbogen-arbeit` |
| Modul | `internal` (`answer-sheet-pages`, `exam-on-sheet`, `sheet`, `sheet-header`, `name-line`, `header-box`, `header-height`, `grade-boundaries`, `grade-display`, `points-table-content`, `writing-area`, `half-page`, `is-fold-left`, `is-margin-left`) |
| Importe | `@schule/patterns:0.4.1`: `kariert`, `liniert` namentlich; `@preview/tablex` entfällt (`std.table`) |

### 4.3 patterns (`src/lib.typ`, heute `patterns.typ`)

| Gruppe | Namen |
|---|---|
| eigene, exportiert | `kariert`, `liniert` (Bausteine, K 2.1a), `flex-area`, `is-flex-area` (englisch: Layout-Helfer und Abfrage, K 2.1) |
| abbrechende Stubs in `src/removed.typ` | `flex-feld`, `ist-flex-feld` |
| Modul | `internal` |
| Importe | cetz namentlich und lokal; kein Name aus cetz wird exportiert |

Die Namen `kariert`, `liniert`, `klassenarbeit`, `flex-area`, `is-flex-area` kollidieren nach der Prüfung (kompiliert mit 0.15.1) nicht mit `dir(std)`, cetz, cetz.draw, gentle-clues oder colorful-boxes; L12 ist erfüllt. `klausurboegen` als Funktionsname war nicht Teil dieser Prüfung und ist beim Zusammenführen nachzuprüfen. Die englischen Zwillinge `exam`, `answer-sheets`, `squares`, `lines` werden nicht exportiert (L27c, `zwillinge.txt`); wer sie schreibt, bekommt Typsts „unknown variable“ und keinen Stub (K 9.3).

**`internal` bei `: *`-Importen.** Jedes der drei Pakete exportiert nach K 7.1 ein Modul `internal`. Importiert ein Dokument mehrere Pakete mit `: *` (1474 von 1576 Importen; 12 Dateien rufen `klausurbögen(` neben anderen Paketen auf), überschreibt das zuletzt importierte `internal` die früheren ohne Meldung. Für Dokumente ist das folgenlos, solange sie `internal` nicht benutzen (K 7.2). Vorschlag an K 7.1 (Abschnitt 8): `internal` nicht in den `*`-Export aufnehmen, sondern nur als Modulfeld erreichbar machen.

**Abbrechende Stubs mit alten Namen.** `klausurbögen`, `bogen-seiten`, `klausurbogen-arbeit`, `flex-feld`, `ist-flex-feld` stehen nach K 9.3 im Block `src/removed.typ`; das Lint nimmt ihn von L1 und L27 aus (Umlaut in `klausurbögen`), L19 zählt ihn zur Exportmenge. Der frühere Hinweis an L1 und L19 ist damit erledigt. Offen bleibt die Meldungsform: K 9.3 kennt für Stubs nur „heißt jetzt“; `bogen-seiten` und `klausurbogen-arbeit` haben keinen Nachfolger für Dokumente und brauchen „gibt es nicht mehr – …“ (Abschnitt 8).

---

## 5. Im Zuge der Umbenennung zu behebende Fehler und Altlasten (nur API)

Fundstellen: KA = `klassenarbeit/0.4.0/src/klassenarbeit.typ`, TPL = `klassenarbeit/0.4.0/template/ka.typ`, KB = `klausurboegen/0.0.5/klausurboegen.typ`, KB4 = `klausurboegen/0.0.4/klausurboegen.typ`, PAT = `patterns/0.0.2/patterns.typ`.

| Nr. | Fehler | Fundstelle | Behebung |
|---|---|---|---|
| 1 | `title` und `class` werden gelesen, aber nicht deklariert | KA 412–413 | in `klassenarbeit` deklariert (1.1) |
| 2 | Docstring nennt `table`, verschweigt `name-field`, beschreibt `logo` und `info-table` falsch | KA 348–357 | Docstring aus der Signatur (L26) |
| 3 | `klausurboegen` ohne Typprüfung: `none`, `"ja"` aktivieren die Bögen | KA 431–434 | W6 geprüft |
| 4 | `info-table: true` wirkungslos (ab 0.1.2; in 0.0.8–0.1.1 ist es der bool-Schalter neben `table`) | KA 76–78, 256; klassenarbeit/0.1.1 49, 146 | Typ W4, `true` ist ein Fehler; Kontextregel nach Quellversion (1.1) |
| 5 | `erwartungen.new-page` wird in 0.4.0 still verworfen, in 0.3.2 wirkt es | KA 321; klassenarbeit/0.3.2 296 | Schlüssel entfernt, Meldung; `new-page: false` aus 0.3.2 mit Bericht |
| 6 | Nutzerargumente überschreiben `print`, `custom-header`, `header-ascent`, `scope` | KA 227–246 | kein Durchreich-Sink mehr; `print`, `custom-header`, `scope` entfernt |
| 7 | Zugriff auf `_theme-aufloesen`, `_state_ab_scope` des Nachbarpakets | KA 86, 319 | `arbeitsblatt.internal.…` |
| 8 | Positionale Extra-Argumente werden verschluckt | KA 401, 429 | `..deprecated` meldet sie |
| 9 | Tippfehler im Kopf melden `arbeitsblatt:` statt `klassenarbeit:` | KA 227 ff. | Prüfung in `klassenarbeit` vor der Weitergabe |
| 10 | `panic` für unbekannte Varianten, ohne Paketpräfix und Werteliste | KA 493, 519 | `internal.fail` |
| 11 | Dateiname des Bündels ignoriert content-Titel; `title not in ("", none)` für content immer wahr | KA 439, 460; TPL 4 | Text aus content gewinnen; `none` statt `""` |
| 12 | `page-numbering`: bool und String gemischt, `true` = `"reset"`; der Name meint bei Typst das Muster | KA 68, 252 | `page-counter` (W2), ein Wert |
| 13 | zwei Wege für Ergebnisdaten (`ergebnisse` und `students` + `result`) | KA 26–38 | nur `results` und `overprint` |
| 14 | `teilaufgabe-numbering` und `numbering` der Bögen nicht gekoppelt; `logo`, `font` nicht durchgereicht | KA 30–39; KB 64, 163 | `klassenarbeit` reicht `subtask-numbering` und `logo` weiter; Schrift bleibt fest (A.6 hat keinen Parameter dafür, als Altlast vermerkt) |
| 15 | Standard-BE-Formate doppelt definiert | KA 208–209, aufgaben 50–51 | nur in aufgaben |
| 16 | Vorlage: falsche Wertelisten in Kommentaren, `"{Titel}.pdf"` versprochen, alte Namen und Werte in weiteren Kommentaren | TPL 9–11, 13, 14, 16–19 | Vorlage neu (1.8) |
| 17 | Doku-Beispiel `name-field: "Name:"` ergibt „Name::" | `klassenarbeit/0.4.0/docs/content.typ` 115 | Beispiel korrigieren; Tests kompilieren Doku-Beispiele |
| 18 | Doku-Beispiel `klausurboegen: (stufe: "I")` kompiliert nicht (5 Stellen) | klassenarbeit-Doku | `answer-sheets: (stage: "sek-1")` |
| 19 | Dokumentiertes Beispiel von `klausurbögen` stürzt ab (`students` als Namensliste) | KB 9–12, 534; `klausurboegen/0.0.5/docs/content.typ` 32, 58, 74, 110, 126, 140 | `results` mit geprüfter Gestalt, Meldung statt `invalid float` |
| 20 | Persönliche Vorgaben `"SLZ"`, `"PH1"`, `"09.10.2023"` | KB 40–42 | `none` |
| 21 | Umlaut und ß im Bezeichner; Alias `"außen"` | KB 37, 51, 60 | `klausurboegen` (Umschrift, K 2.3), `correction-margin-blank`, kein Alias |
| 22 | `vorschlag` dokumentiert als bool, ist Beschriftung; `sek1` falsch beschrieben | KB 21, 30 | `proposal: none` (W4), `stage` |
| 23 | `scale` wirkt nur auf Kästchen | KB 47, 130 | `grid-size` (Länge) |
| 24 | `sub: true` schaltet ab, `result-table` wirkt nur mit `sub` | KB 108–114 | `continuation`, `points-table`; Abhängigkeit im Docstring |
| 25 | `result: true` mit leerem `students` und gesetztem Titel: fast leere Seite, Dummy-Aufruf mit Zahlen statt Arrays | KB 474 | Meldung: ``klausurboegen.klausurboegen: `overprint: true` ohne `results` – Ergebniszeilen übergeben`` |
| 26 | Äste 0.0.4 und 0.0.5 mit verschiedenem Umfang | KB4 390–410, 741, 889; KB 37–58 | zusammengeführt (2.1, 2.2) |
| 27 | `vordruck: true` wirkt wie `false`, obwohl der Kommentar es als Ergebnisdruck auf Vordruck beschreibt | KB4 560, 707 | W1 `points-table-preprinted` |
| 28 | `liniert` nachgebaut statt aus patterns; Pin auf patterns 0.0.1; tablex 0.0.9 | KB 1, 76, 124–128 | `patterns.liniert`, Pin 0.4.1, `std.table` |
| 29 | Kopf doppelt implementiert (klassenarbeit und klausurboegen) | KA 139–182, KB 74–106 | eine Fassung, `logo: none` statt `[]` |
| 30 | `typst.toml` ohne `authors`, Platzhalter-Beschreibung, Einstieg nicht unter `src/` | `klausurboegen/0.0.5/typst.toml`, `patterns/0.0.2/typst.toml` | `src/lib.typ` (K 7.1), Felder füllen |
| 31 | `width` mit zwei Einheiten: `kariert` nimmt Länge und Kästchenzahl (eine Länge bricht nur zusammen mit `content` ab), `liniert` nimmt benannt Länge und Zahl (Zeilenhöhen); Docstring `kariert.width (length)` verschweigt die Kästchenzahl | PAT 32, 63, 126, 171, 204–206 | `width` nur Länge (beide Funktionen), `columns` nur int (`kariert`) |
| 32 | `..args` verschluckt Tippfehler und alte Namen (`lineheight`, `cnt`, `grid-sice`) | PAT 54, 162 | Sink geprüft |
| 33 | zweites Positionsargument: bei `kariert` ungeprüft, bei `liniert` nur als Länge | PAT 63, 171 | nur ein Positionsargument |
| 34 | `height` „überschreibt `rows`" stimmt nicht (items gewinnen, bei `1fr` geht `height` verloren) | PAT 72–73, 79–80 | `rows` und `height` zugleich ist ein Fehler |
| 35 | `rows: 1fr` mit `items`: `kariert` kann es, `liniert` fällt still auf feste Zeilen zurück | PAT 69–74, 177 | gleiches Verhalten oder Meldung **[prüfen]** |
| 36 | `liniert` bricht mit Typst-Fehler ab, sobald `items` gesetzt ist und `items-spacing` ein float ist (auch bei ganzzahligem Produkt); ohne `items` wird `items-spacing` gar nicht gelesen | PAT 192–194, 209 | `item-rows` als int geprüft |
| 37 | Parameter `content` überdeckt cetz `content` | PAT 53, 92 | `overlay` |
| 38 | Notiz des Autors über dem Docstring von `flex-feld` („Was ist items?") | PAT 2 | streichen; `items` ist Glossar 78 |
| 39 | `flex-feld`, `ist-flex-feld` deutsch mit `hoehe`, `zeichne`, `inhalt`; Kopie in aufgaben | PAT 7, 16; aufgaben 867 | `flex-area`, `is-flex-area`; die Kopie bleibt als `aufgaben.internal.is-flex-area` mit identischem Vertrag, ein Test vergleicht beide |
| 40 | kein Test für klausurboegen und patterns | `tests/` | je Compat-Zeile ein Fehlertest (K 8.4, L24) |
| 41 | `seite4` überschreibt ein gesetztes `rueckseite` still | klassenarbeit/0.3.1 241–251 | `back-page` und `back-page-tasks` zugleich ist ein Fehler |
| 42 | 0.0.5 filtert leere CSV-Zeilen nicht, 0.0.4 schon | KB4 569 | Filter in die zusammengeführte Fassung |
| 43 | `stufe` hat je nach Version zwei Bedeutungen (Notenschlüssel bis 0.1.1, Bildungsstufe in 0.4.0) | klassenarbeit/0.0.8 141–161; arbeitsblatt/0.4.0 297, 1018 | entfernt, zwei Meldungen nach Wert, Kontextregel |
| 44 | Schlüssel des jeweils anderen Asts im `klausurboegen`-Dictionary enden in Typsts „unexpected argument" | KA 23; klassenarbeit/0.3.1 23 | Prüfung in `klassenarbeit` vor der Weitergabe |
| 45 | `"klausurboegen"` wird auch an eine ausdrücklich angegebene `varianten`-Liste angehängt, undokumentiert | KA 452–454 | bleibt, steht im Docstring (Zweifelsfall 16) |
| 46 | Strings wie `erwartungen: "keine"` wirken als aus, ohne Meldung (bis 0.1.2) | klassenarbeit/0.1.2 244 | W6 geprüft, Meldung „falsches Aus" |

---

## 6. Maschinenlesbarer Anhang

**Lesart.** Schlüssel unter `parameter` und `werte` sind die **alten** Funktionsnamen (bei `klassenarbeit`, `kariert` und `liniert` zugleich die neuen); `a.b` bezeichnet den Dictionary-Parameter `b` der Funktion `a`. Ein Wert `null` heißt „Argument löschen". Enthält der neue Wert einen Doppelpunkt nach einem Namen (`"solutions: …, solutions-pagebreak: …"`), ersetzt er das ganze Argument. Positionsargumente stehen als `#0`, `#1`.

**Blöcke und ihre Entsprechung in K 9.2.** `funktionen` (öffentliche Funktionsnamen: Codemod und Laufzeit „heißt jetzt"), `parameter` = `renamed`, `werte` = `values`, `entfernt` = `removed` (alter Name → Hinweistext), `kontext` = `context` (nur Codemod). `funktionen` enthält nur noch echte Umbenennungen; jeder alte Name dort wird ein Stub in `src/removed.typ`. Dazu: `bausteine-unveraendert` (Bausteine dieser Tabelle, deren Funktionsname bleibt: der Codemod fasst den Namen nicht an, nur die Argumente; einen Block `uebergangsnamen` gibt es nicht mehr, K 9.3), `entfernte-funktionen` (abbrechende Funktionen ohne Nachfolger für Dokumente, mit Hinweistext), `intern` und `intern-parameter` (nur Paketquelltext; **der Codemod wendet diese beiden Blöcke nie auf Dokumente an**), `nur-kontext` (Namen, für die es keine einfache Regel gibt). Die drei Tabellen (arbeitsblatt, aufgaben, klassenarbeit) benutzen noch verschiedene Blocknamen; die Vereinheitlichung auf die Feldnamen aus K 9.2 geschieht beim Zusammenführen zu `regeln.json` (Zweifelsfall 14).

**Vorrang.** Steht ein Name unter `nur-kontext`, gilt für ihn keine Regel aus `parameter` oder `werte`, sondern nur der passende Eintrag unter `kontext`. Kontextregeln mit `quelle` gelten nur für Dokumente, deren Importzeile diese Version von klassenarbeit pinnt.

**Vererbung.** Die Werte unter `klausurbögen.x` gelten unverändert für den Dictionary-Schlüssel `klassenarbeit.klausurboegen.x` (auch für die Schlüssel in `klausurboegen-settings`); die Werte unter `bogen-seiten.x` gelten für `klassenarbeit.bogen.x`. Der Vorlagenfall aus 1.8 folgt daraus: `klausurboegen: (muster: "kariert", korrekturrand: "aussen")` → `answer-sheets: (pattern: "squares", correction-margin-side: "outside")`.

```json
{
  "funktionen": {
    "klausurbögen": "klausurboegen",
    "flex-feld": "flex-area",
    "ist-flex-feld": "is-flex-area"
  },
  "bausteine-unveraendert": ["klassenarbeit", "kariert", "liniert"],
  "entfernte-funktionen": {
    "bogen-seiten": "ist jetzt intern – die Arbeit direkt auf dem Bogen schaltet `klassenarbeit(answer-sheet-pages: …)` ein",
    "klausurbogen-arbeit": "ist jetzt intern – `#show: klassenarbeit.with(answer-sheet-pages: true)` schreiben"
  },
  "intern": {
    "_klassenarbeit-einzeln": "internal.exam-single",
    "_klausurboegen-inhalt": "internal.answer-sheets-variant",
    "_ka-counter": "internal.exam-counter",
    "_state_ka_variante": "internal.variant-state",
    "logos": "internal.logos",
    "bogen-seiten": "internal.answer-sheet-pages",
    "klausurbogen-arbeit": "internal.exam-on-sheet",
    "_bogen-kopf": "internal.sheet-header",
    "_bogen-namenszeile": "internal.name-line",
    "_bogen-kopfbox": "internal.header-box",
    "_bogen-kopfhoehe": "internal.header-height",
    "_notentabelle": "internal.grade-boundaries",
    "_note-anzeige": "internal.grade-display",
    "_punktetabelle": "internal.points-table-content",
    "studentHeader": null
  },
  "intern-parameter": {
    "_klassenarbeit-einzeln": {
      "variante": "variant",
      "scope": "scope",
      "ka-id": "exam-id"
    },
    "_klausurboegen-inhalt": {
      "title": "title",
      "subtitle": "subtitle",
      "teacher": "teacher",
      "class": "class",
      "date": "date",
      "einstellungen": "settings"
    },
    "_bogen-kopfbox": {
      "kopf": "header",
      "namenszeile": "name-line-content",
      "student-table": "points-content",
      "grade-table": "grade-table",
      "sub": "continuation",
      "heigth": "height"
    }
  },
  "parameter": {
    "klassenarbeit": {
      "subtitle": "subtitle",
      "date": "date",
      "logo": "logo",
      "teacher": "teacher",
      "student": "student",
      "name-field": "name-field",
      "name-repeat": "name-repeat",
      "info-table": "info-table",
      "page-numbering": "page-counter",
      "klausurboegen": "answer-sheets",
      "erwartungen": "expectations",
      "punkte-template": "points-format",
      "varianten": "variants",
      "variante": "preview-variant",
      "dateiname": "filename",
      "title": "title",
      "class": "class",
      "paper": "paper",
      "landscape": "landscape",
      "duplex": "duplex",
      "page-settings": "page-settings",
      "theme": "theme",
      "akzent": "accent",
      "font": "font",
      "math-font": "math-font",
      "font-size": "font-size",
      "title-font-size": "title-font-size",
      "figure-font-size": "figure-font-size",
      "workspaces": "workspaces",
      "loesungen": "solutions",
      "materialien": "materials",
      "punkte": "points",
      "aufgaben-shortcodes": "shortcodes",
      "teilaufgabe-numbering": "subtask-numbering",
      "schueler": "student",
      "header-font-size": "title-font-size",
      "bogen": "answer-sheet-pages"
    },
    "klassenarbeit.klausurboegen": {
      "students": "results",
      "result": "overprint",
      "exam": "title",
      "subexam": "subtitle",
      "teacher": "teacher",
      "class": "class",
      "date": "date",
      "sek1": "stage",
      "stufe": "stage",
      "rand": "correction-margin",
      "scale": "grid-size",
      "sub": "continuation",
      "numbering": "subtask-numbering",
      "mv": "offset",
      "move": "offset",
      "weißer-rand": "correction-margin-blank",
      "result-table": "points-table",
      "vorschlag": "proposal",
      "line-stroke": "correction-margin-stroke",
      "muster": "pattern",
      "linienabstand": "line-height",
      "korrekturrand": "correction-margin-side",
      "vordruck": "points-table-preprinted",
      "namen": "overprint-name"
    },
    "klassenarbeit.erwartungen": {
      "grouped": "grouped",
      "erreicht": "achieved",
      "alle": "select"
    },
    "klassenarbeit.punkte-template": {
      "aufgabe": "task",
      "teilaufgabe": "subtask"
    },
    "klassenarbeit.bogen": {
      "exam": "title",
      "subexam": "subtitle",
      "teacher": "teacher",
      "class": "class",
      "date": "date",
      "sek1": "stage",
      "sub": "continuation",
      "result-table": "points-table",
      "vorschlag": "proposal",
      "numbering": "subtask-numbering",
      "mv": "offset",
      "aufgaben": "task-points",
      "tabelle": "points-table-preprinted",
      "rueckseite": "back-page",
      "abstand": "header-spacing",
      "seite4": "back-page-tasks",
      "teilaufgaben": "points-table-subtasks"
    },
    "klausurbögen": {
      "exam": "title",
      "subexam": "subtitle",
      "teacher": "teacher",
      "class": "class",
      "date": "date",
      "students": "results",
      "sek1": "stage",
      "result": "overprint",
      "rand": "correction-margin",
      "scale": "grid-size",
      "sub": "continuation",
      "numbering": "subtask-numbering",
      "mv": "offset",
      "weißer-rand": "correction-margin-blank",
      "result-table": "points-table",
      "vorschlag": "proposal",
      "line-stroke": "correction-margin-stroke",
      "muster": "pattern",
      "linienabstand": "line-height",
      "korrekturrand": "correction-margin-side",
      "vordruck": "points-table-preprinted",
      "namen": "overprint-name"
    },
    "bogen-seiten": {
      "exam": "title",
      "subexam": "subtitle",
      "teacher": "teacher",
      "class": "class",
      "date": "date",
      "sek1": "stage",
      "sub": "continuation",
      "result-table": "points-table",
      "vorschlag": "proposal",
      "numbering": "subtask-numbering",
      "mv": "offset",
      "aufgaben": "task-points",
      "tabelle": "points-table-preprinted",
      "rueckseite": "back-page",
      "abstand": "header-spacing"
    },
    "kariert": {
      "rows": "#0",
      "items": "items",
      "items-spacing": "item-rows",
      "grid-size": "grid-size",
      "height": "height",
      "annotations": "annotations",
      "line-stroke": "stroke",
      "fill-color": "fill",
      "content": "overlay"
    },
    "liniert": {
      "rows": "#0",
      "items": "items",
      "items-spacing": "item-rows",
      "line-height": "line-height",
      "lineheight": "line-height",
      "line-stroke": "stroke"
    },
    "flex-feld": {
      "hoehe": "height",
      "zeichne": "body"
    },
    "ist-flex-feld": {
      "inhalt": "body"
    }
  },
  "nur-kontext": [
    "klassenarbeit.stufe",
    "klassenarbeit.table",
    "klassenarbeit.ergebnisse",
    "klassenarbeit.klausurboegen-settings",
    "klassenarbeit.header-ascent",
    "klassenarbeit.klausurboegen.ergebnisse",
    "klassenarbeit.klausurboegen.show",
    "klassenarbeit.erwartungen.show",
    "klassenarbeit.erwartungen.teile",
    "klassenarbeit.erwartungen.new-page",
    "klassenarbeit.bogen.rand",
    "klassenarbeit.bogen.unten",
    "bogen-seiten.rand",
    "bogen-seiten.unten",
    "kariert.width",
    "kariert.#1",
    "liniert.width",
    "liniert.#1"
  ],
  "werte": {
    "klassenarbeit.subtitle": {"\"\"": null},
    "klassenarbeit.date": {"\"\"": null},
    "klassenarbeit.teacher": {"\"\"": null},
    "klassenarbeit.student": {"\"\"": null},
    "klassenarbeit.schueler": {"\"\"": null},
    "klassenarbeit.title": {"\"\"": null},
    "klassenarbeit.class": {"\"\"": null},
    "klassenarbeit.logo": {"\"angela\"": null, "\"\"": "none"},
    "klassenarbeit.info-table": {"false": null, "()": null},
    "klassenarbeit.page-numbering": {"true": null, "\"reset\"": "\"restart\"", "\"continuous\"": "\"continuous\"", "false": "none"},
    "klassenarbeit.erwartungen": {"\"keine\"": "false", "\"false\"": "false", "\"true\"": "false"},
    "klassenarbeit.punkte-template": {"none": null},
    "klassenarbeit.varianten": {"\"druck\"": "\"print\"", "\"loesung\"": "\"solutions\"", "\"klausurboegen\"": "\"answer-sheets\""},
    "klassenarbeit.variante": {"\"druck\"": "\"print\"", "\"loesung\"": "\"solutions\"", "\"klausurboegen\"": "\"answer-sheets\""},
    "klassenarbeit.theme": {"none": null, "\"standard\"": null},
    "klassenarbeit.loesungen": {
      "\"keine\"": null, "\"false\"": null, "false": null, "none": null,
      "\"sofort\"": "\"in-place\"",
      "\"folgend\"": "\"after-task\"",
      "\"reinquetschen\"": "\"at-end\"",
      "\"seite\"": "solutions: \"at-end\", solutions-pagebreak: \"before\"",
      "\"seiten\"": "solutions: \"at-end\", solutions-pagebreak: \"per-task\"",
      "\"nur\"": "\"only\""
    },
    "klassenarbeit.materialien": {
      "\"seiten\"": null,
      "\"sofort\"": "materials: \"after-task\", materials-pagebreak: none",
      "\"folgend\"": "materials: \"after-task\", materials-pagebreak: none",
      "\"seite\"": "\"at-end\"",
      "\"reinquetschen\"": "materials: \"at-end\", materials-pagebreak: none",
      "\"keine\"": "none", "\"false\"": "none", "false": "none"
    },
    "klassenarbeit.punkte": {
      "\"keine\"": "none",
      "\"aufgaben\"": null,
      "\"teilaufgaben\"": "\"subtasks\"",
      "\"alle\"": "\"all\"",
      "\"keine-summe\"": "points: \"all\", points-total: false"
    },
    "klassenarbeit.punkte.position": {"\"ende\"": "\"end\"", "\"rand\"": "\"margin\""},
    "klassenarbeit.aufgaben-shortcodes": {"\"keine\"": "none", "\"aufgaben\"": "\"tasks\"", "\"teilaufgaben\"": null, "\"alle\"": "\"all\""},
    "klassenarbeit.teilaufgabe-numbering": {"\"a)\"": null, "\"1.\"": "\"1.1\""},
    "klassenarbeit.print": {"true": null},
    "klassenarbeit.klausurboegen.stufe": {"\"I\"": "\"sek-1\"", "\"II\"": "\"sek-2\""},
    "klassenarbeit.erwartungen.alle": {"true": "\"all\"", "false": null},
    "klausurbögen.exam": {"\"\"": null},
    "klausurbögen.subexam": {"\"\"": null},
    "klausurbögen.teacher": {"\"\"": null},
    "klausurbögen.class": {"\"\"": null},
    "klausurbögen.date": {"\"\"": null},
    "klausurbögen.sek1": {"false": null, "true": "\"sek-1\""},
    "klausurbögen.scale": {"1": null},
    "klausurbögen.numbering": {"\"a)\"": null, "\"1.\"": "\"1.1\""},
    "klausurbögen.vorschlag": {"false": null},
    "klausurbögen.muster": {"\"kariert\"": "\"squares\"", "\"liniert\"": "\"lines\""},
    "klausurbögen.korrekturrand": {"\"aussen\"": "\"outside\"", "\"außen\"": "\"outside\"", "\"innen\"": "\"inside\""},
    "klausurbögen.vordruck": {"false": null, "true": null, "\"werte\"": "true"},
    "bogen-seiten.exam": {"\"\"": null},
    "bogen-seiten.subexam": {"\"\"": null},
    "bogen-seiten.teacher": {"\"\"": null},
    "bogen-seiten.class": {"\"\"": null},
    "bogen-seiten.date": {"\"\"": null},
    "bogen-seiten.sek1": {"false": null, "true": "\"sek-1\""},
    "bogen-seiten.numbering": {"\"a)\"": null, "\"1.\"": "\"1.1\""},
    "bogen-seiten.vorschlag": {"false": null},
    "bogen-seiten.aufgaben": {"none": null},
    "kariert.height": {"none": null},
    "kariert.content": {"[]": null}
  },
  "entfernt": {
    "klassenarbeit.print": "eine Klassenarbeit ist immer Druckfassung",
    "klassenarbeit.custom-header": "der Kopf entsteht aus `title`, `subtitle`, `class`, `date`, `teacher`, `logo`; ein eigener Kopf ist der Theme-Hook `header`",
    "klassenarbeit.scope": "intern",
    "klassenarbeit.copyright": "`copyright-url` gibt es nur in `arbeitsblatt`",
    "klassenarbeit.zweifach": "zwei Seiten je Bogen (`two-up`) gibt es nur in `arbeitsblatt`",
    "klassenarbeit.fach": "Bibliotheks-Metadaten gibt es nur in `arbeitsblatt`",
    "klassenarbeit.thema": "Bibliotheks-Metadaten gibt es nur in `arbeitsblatt`",
    "klassenarbeit.jahrgang": "Bibliotheks-Metadaten gibt es nur in `arbeitsblatt`",
    "klassenarbeit.niveau": "Bibliotheks-Metadaten gibt es nur in `arbeitsblatt`",
    "klassenarbeit.typ": "Bibliotheks-Metadaten gibt es nur in `arbeitsblatt`",
    "klassenarbeit.stichworte": "Bibliotheks-Metadaten gibt es nur in `arbeitsblatt`",
    "klassenarbeit.kerncurriculum": "Bibliotheks-Metadaten gibt es nur in `arbeitsblatt`",
    "klassenarbeit.stand": "Bibliotheks-Metadaten gibt es nur in `arbeitsblatt`",
    "klassenarbeit.stufe": "Wert \"I\", \"II\", false: der Notenschlüssel steht in `answer-sheets: (stage: \"sek-1\")`; jeder andere Wert: Bibliotheks-Metadaten gibt es nur in `arbeitsblatt`",
    "klassenarbeit.vorschau-alle": "die Vorschau wählt `preview-variant`",
    "klassenarbeit.bewertung": "die Punkteübersicht ist `show-points-table()`, die Spalte zum Eintragen `expectations: (achieved: true)`",
    "klassenarbeit.klausurboegen.show": "`answer-sheets: false` schaltet die Bögen ab",
    "klassenarbeit.erwartungen.show": "`expectations: false` schaltet den Erwartungshorizont ab",
    "klassenarbeit.erwartungen.new-page": "der Erwartungshorizont beginnt immer auf einer neuen Seite",
    "kariert.cnt": "hatte nie eine Wirkung"
  },
  "kontext": [
    {"alt": "klassenarbeit: punkte fehlt", "quelle": "alle", "neu": "points: none ergänzen", "grund": "Vorgabe von klassenarbeit ist \"tasks\"; in allen Quellversionen war die wirksame Vorgabe \"keine\""},
    {"alt": "klassenarbeit.punkte: (anzeige: a, position: p)", "neu": "points: a', points-position: p'"},
    {"alt": "klassenarbeit.header-ascent: x", "neu": "page-settings: (header-ascent: x)"},
    {"alt": "klassenarbeit.info-table: (a, b, c, d)", "quelle": ">= 0.1.2", "neu": "info-table: ((a, b), (c, d))"},
    {"alt": "klassenarbeit.info-table: false neben table: x", "quelle": "0.0.8-0.1.1", "neu": "beide Argumente löschen", "grund": "info-table war dort ein bool-Schalter, die Tabelle war ausgeblendet"},
    {"alt": "klassenarbeit.info-table: true oder fehlend, table: x", "quelle": "<= 0.1.1", "neu": "bool-Argument löschen; info-table: x (flach -> Paare); table: () -> löschen", "grund": "sonst duplicate argument"},
    {"alt": "klassenarbeit.varianten: \"druck\"", "neu": "variants: (\"print\",)"},
    {"alt": "klassenarbeit.klausurboegen: (show: false, ..)", "neu": "answer-sheets: false"},
    {"alt": "klassenarbeit.klausurboegen: (show: true, ..)", "neu": "Schlüssel show löschen"},
    {"alt": "klassenarbeit.klausurboegen: (ergebnisse: x)", "neu": "answer-sheets: (results: x, overprint: true); ergebnisse: none -> Schlüssel löschen"},
    {"alt": "klassenarbeit.stufe: \"I\", Bögen aktiv", "quelle": "<= 0.1.1", "neu": "Schlüssel stage: \"sek-1\" in das eine answer-sheets-Dictionary einfügen (true -> (stage: \"sek-1\")); stufe löschen"},
    {"alt": "klassenarbeit.stufe: \"II\" oder false, Bögen aktiv", "quelle": "<= 0.1.1", "neu": "stufe löschen", "grund": "\"sek-2\" ist die Vorgabe"},
    {"alt": "klassenarbeit.stufe, Bögen aus oder nicht angegeben", "quelle": "<= 0.1.1", "neu": "stufe löschen, Bericht", "grund": "ein Dictionary hieße nach W6 an"},
    {"alt": "klassenarbeit.stufe", "quelle": ">= 0.1.2", "neu": "Argument löschen, Bericht", "grund": "wird nicht mehr gelesen bzw. ist in 0.4.0 die Bildungsstufe für <ab-meta>"},
    {"alt": "klassenarbeit.ergebnisse: x, Bögen aktiv", "quelle": "<= 0.1.1", "neu": "results: x, overprint: true in das eine answer-sheets-Dictionary einfügen; ergebnisse: none -> löschen"},
    {"alt": "klassenarbeit.ergebnisse, Bögen aus oder nicht angegeben", "quelle": "<= 0.1.1", "neu": "Argument löschen, Bericht"},
    {"alt": "klassenarbeit.klausurboegen-settings: (..), klausurboegen: true", "quelle": "0.0.5-0.1.1", "neu": "Schlüssel (umbenannt nach klassenarbeit.klausurboegen) in das eine answer-sheets-Dictionary"},
    {"alt": "klassenarbeit.klausurboegen-settings: (..), klausurboegen: false oder nicht angegeben", "quelle": "0.0.5-0.1.1", "neu": "Argument löschen, Bericht; answer-sheets bleibt aus"},
    {"alt": "klassenarbeit: klausurboegen: true ohne klausurboegen-settings", "quelle": "0.0.5-0.1.1", "neu": "correction-margin: 6cm in das answer-sheets-Dictionary", "grund": "Vorgabe dort rand: 6cm, neu 5cm"},
    {"alt": "klassenarbeit: erwartungen fehlt", "quelle": "<= 0.1.1", "neu": "expectations: false ergänzen", "grund": "Vorgabe dort false, neu true"},
    {"alt": "klassenarbeit.erwartungen: true ohne stufe \"I\" oder \"II\"", "quelle": "0.0.2-0.0.8", "neu": "expectations: false, Bericht", "grund": "der Horizont erschien dort nur mit stufe"},
    {"alt": "klassenarbeit.erwartungen: (..) als Dictionary", "quelle": "<= 0.3.1", "neu": "expectations: false, Bericht", "grund": "dort zählte nur == true"},
    {"alt": "klassenarbeit.erwartungen: \"true\"", "neu": "expectations: false, Bericht", "grund": "String wirkte als aus"},
    {"alt": "klassenarbeit: figure-font-size fehlt", "quelle": "0.0.8-0.1.1", "neu": "figure-font-size: 12pt ergänzen"},
    {"alt": "klassenarbeit: logo fehlt", "quelle": "<= 0.1.0", "neu": "logo: none ergänzen", "grund": "Vorgabe dort \"\" = kein Logo"},
    {"alt": "klassenarbeit.erwartungen: (show: false)", "neu": "expectations: false"},
    {"alt": "klassenarbeit.erwartungen: (alle: true, teile: t)", "neu": "expectations: (select: \"all\", blocks: t)"},
    {"alt": "klassenarbeit.erwartungen: (teile: t) ohne alle: true", "neu": "Schlüssel teile löschen", "grund": "war wirkungslos"},
    {"alt": "klassenarbeit.erwartungen: (new-page: ..)", "quelle": "0.4.0", "neu": "Schlüssel löschen"},
    {"alt": "klassenarbeit.erwartungen: (new-page: true)", "quelle": "0.3.2", "neu": "Schlüssel löschen"},
    {"alt": "klassenarbeit.erwartungen: (new-page: false)", "quelle": "0.3.2", "neu": "Schlüssel löschen, Bericht", "grund": "der Horizont steht künftig immer auf eigener Seite"},
    {"alt": "klassenarbeit.bogen: (rand: r, unten: u)", "neu": "margin: (top: r, bottom: u, x: r); fehlt einer: 12mm bzw. 16mm"},
    {"alt": "klassenarbeit.bogen: (seite4: .., rueckseite: ..)", "neu": "Bericht, von Hand", "grund": "seite4 überschrieb rueckseite still; neu ein Fehler"},
    {"alt": "klausurbögen: teacher, class, date fehlen und exam ist gesetzt", "neu": "teacher: \"SLZ\", class: \"PH1\", date: \"09.10.2023\" ergänzen"},
    {"alt": "klausurbögen.scale: n", "neu": "grid-size: n * 0.5cm"},
    {"alt": "klausurbögen.numbering: <anderer Wert>", "neu": "subtask-numbering: \"1.1\", Bericht"},
    {"alt": "bogen-seiten: rand: r, unten: u", "neu": "margin: (top: r, bottom: u, x: r)", "grund": "nur Paketquelltext und Vererbung an klassenarbeit.bogen"},
    {"alt": "kariert(rows: r)", "neu": "kariert(r)"},
    {"alt": "kariert.width: <Längenliteral>", "neu": "width: <Länge>"},
    {"alt": "kariert.width: <Ganzzahl-Literal>", "neu": "columns: <Zahl>"},
    {"alt": "kariert.width: <kein Literal>", "neu": "Bericht, von Hand"},
    {"alt": "kariert(r, w) mit w als Längenliteral", "neu": "kariert(r, width: w)"},
    {"alt": "kariert(r, n) mit n als Ganzzahl-Literal", "neu": "kariert(r, columns: n)"},
    {"alt": "kariert(r, x) mit x als Ausdruck", "neu": "Bericht, von Hand"},
    {"alt": "kariert.items-spacing: nicht ganzzahlig", "neu": "Bericht, von Hand"},
    {"alt": "liniert(rows: r)", "neu": "liniert(r)"},
    {"alt": "liniert.width: <Längenliteral>", "neu": "width: <Länge>"},
    {"alt": "liniert.width: <Zahl-Literal n>", "neu": "width: n * <line-height des Aufrufs, sonst 1cm>"},
    {"alt": "liniert.width: <kein Literal>", "neu": "Bericht, von Hand"},
    {"alt": "liniert(r, w) mit w als Länge", "neu": "liniert(r, width: w)"},
    {"alt": "liniert(r, n) mit n als Zahl", "neu": "liniert(r)", "grund": "die Zahl wurde ignoriert"},
    {"alt": "liniert.items-spacing: float ohne items", "neu": "Argument löschen", "grund": "wurde nicht gelesen"}
  ]
}
```

---

## 7. Zweifelsfälle und Entscheidungen

1. **`rows` in `kariert` und `liniert`: A.7 schreibt `rows,` als Pflicht-Positionsparameter, sagt aber zugleich „`height` statt `rows`".** In Typst kann ein Positionsparameter keine Vorgabe haben; mit A.7 wörtlich wären `kariert(height: 2cm)` (106 Aufrufe mit `height:` im Bestand) und `kariert(items: …)` Fehler, und die heutige Vorgabe `rows: 1` ginge verloren (L25). Entscheidung: `rows` ist ein optionales führendes Hauptargument im geprüften Sink `..args` (K 4.4 Nr. 5b), der zugleich die alten Namen abfängt (5c). Parameternamen, Typen und Vorgaben sind die aus A.7.
2. **Zählweise der Seitenzahlen: `page-counter` statt `page-numbering`.** Glossar 39 legt `page-numbering` als Nummerierungsmuster (str, Typst-Muster) fest, A.2 benutzt denselben Namen als Auswahl `"restart"` | `"continuous"`. In der Signatur von `klassenarbeit` hätte das Suffix `-numbering` damit zwei Typen (`subtask-numbering` ist ein Muster), und der Name hieße wie Typsts `page(numbering:)`, ohne sich so zu verhalten. **Entscheidung (geändert nach Prüfung):** `page-counter: "restart" | "continuous"`, aus ist `none`; beide Segmente stehen in `words-en.txt`, `page-numbering` bleibt für das Muster frei. Das weicht von A.2 ab; A.2 und das Glossar brauchen die Zeile „Zählweise der Seitenzahlen" (Abschnitt 8).
3. **Vorgabe `points` in `klassenarbeit`.** K 6 und A.2 setzen `"tasks"`; klassenarbeit zeigt ohne Angabe in keiner Version Punkte (0.4.0 per Kompilieren bestätigt, wirksam ist `punkte: "keine"` aus `arbeitsblatt-einzeln`; 0.0.8–0.1.1 deklarieren `punkte: "keine"` selbst). Entscheidung: Die Konvention gilt; die Änderung steht als ausdrücklicher Eintrag in `regeln.json` (L25), und der Codemod ergänzt `points: none`, wenn `punkte` im alten Kopf fehlt, **ohne Versionsbedingung**. Mit einer Beschränkung auf 0.3.x/0.4.0 bekämen 51 der 53 lokal gezählten Köpfe ohne `punkte` neu BE-Angaben.
4. **Was `klassenarbeit` nicht mehr annimmt.** A.2 lässt `print`, `header`, `scope`, `two-up`, `copyright-url` und alle Metadaten weg. Entscheidung: wörtlich nach A.2, alle als „entfernt" mit Abhilfe. Folgen: `print: false` (digitale Klassenarbeit) geht nicht mehr, 44 Köpfe mit `print:` sind zu prüfen. `<ab-meta>` ist eingefroren und behält alle elf Schlüssel; `klassenarbeit` füllt `titel` und `klasse`, die übrigen sind `none`. Auch `typ` bleibt `none` wie heute (klassenarbeit setzt es nicht); ob `klassenarbeit` dort künftig den festen Wert `"klausur"` schreiben soll, ist eine Entscheidung des Autors und wäre eine Änderung der Ausgabe. Im Bestand setzt kein Klassenarbeitskopf Metadaten.
5. **`vordruck` und `namen` (0.0.4).** K 11.4 will `vordruck: "werte"` dem Schalter `overprint` zuschlagen, „falls die Wirkung dieselbe ist". Sie ist es nicht: `"werte"` ist ein Untermodus des Ergebnisdrucks (nur erreichte Punkte, weil die Tabelle schon auf dem Bogen steht). Entscheidung: eigener Schalter `points-table-preprinted` (W1), mit demselben Namen und Wert in `klausurboegen` und `internal.answer-sheet-pages` (dort ex `tabelle`), ohne einen Schalter umzudrehen. **Geändert nach Prüfung:** `namen` wird `overprint-name`, nicht `name-fields` (K 11.4). Gründe: Bei `true` entstehen keine Felder, sondern der Schülername aus Spalte 0 wird beim Ergebnisdruck hinter „Name:" gesetzt und wirkt nur mit `overprint`; `name-fields` stünde im selben `klassenarbeit`-Aufruf mit Abstand 1 neben `name-field` (anderer Typ), der Tippfehlervorschlag aus K 8.4 schlüge jeweils den falschen vor; ein Plural ohne Sammlung widerspricht K 4.2.
6. **Arbeit direkt auf dem Bogen (`bogen:` in klassenarbeit 0.3.1, `bogen-seiten` in klausurboegen 0.0.4).** A.2 kennt dafür keinen Parameter, K 11.4 schiebt die Funktionen nach `internal`; ohne Einstieg wäre das Merkmal nicht mehr erreichbar, obwohl es laut Commit `0cdcf95` in echten Dokumenten benutzt wird. Entscheidung: `klassenarbeit` bekommt über A.2 hinaus das W6-Merkmal `answer-sheet-pages` (der Name stammt aus der Alternative in K 11.4); die Funktion liegt in `klausurboegen.internal`. Die zwei von klassenarbeit selbst verarbeiteten Schlüssel (`back-page-tasks`, `points-table-subtasks`) sind keine Parameter dieser Funktion; das weicht von „Schlüssel = Parameter" (W6) ab und ist **[prüfen]**. `back-page` und `back-page-tasks` zugleich ist ein Fehler.
7. **`expectations` und die Blöcke.** Die erste Fassung dieser Tabelle deutete `blocks: auto` aus A.5 um und schrieb nur bedingt `blocks: none`; die aufgaben-Tabelle hat `show-expectations` nach ihrer Prüfung auf `select: "current" | "all"` und `blocks: ()` umgestellt (dort Zweifelsfall 1). **Entscheidung (geändert nach Prüfung):** Diese Tabelle übernimmt die Regel der aufgaben-Tabelle unverändert (1.3). Die Vorgabe bleibt „aktueller Block"; es gibt keine Regel mehr, die vom Vorkommen von `reset-aufgaben(` im Dokument abhängt (per AST nicht entscheidbar). `teile` enthält heute content; die aufgaben-Tabelle führt `blocks` als Array aus str | content.
8. **Dateinamen der Bündelausgabe.** K 2.1 friert nur die Endungen von arbeitsblatt ein (`-druck`, `-loesung` …); klassenarbeit erzeugt `<name>.pdf`, `<name> - Lösung.pdf`, `<name> - Klausurbögen.pdf`. Entscheidung: unverändert, weil Dateinamen außerhalb des Repos gelesen werden; die drei Formen gehören in die Liste in K 2.1.
9. **`subtask-numbering` in `klausurboegen`.** Heute `"a)"` oder „alles andere = Ziffern", bei `sek1: true` ignoriert. Entscheidung: dieselbe Form und Regel wie in der aufgaben-Tabelle 2.1 (W3 str mit Paketregel, nicht W9; `"1."` wird `"1.1"` und ist während der Compat-Laufzeit gesperrt); in der Punktetabelle steht nur der Teil des Musters für die Teilaufgabe. Dass `stage: "sek-1"` die Angabe übergeht, bleibt in der Zielversion (gleiches PDF) und steht im Docstring.
10. **`item-rows` als int.** `kariert(items-spacing: 1.5)` läuft heute, auch mit `items`. `liniert` bricht mit einem float nur ab, wenn `items` gesetzt ist (dann bei jedem float, auch wenn das Produkt ganzzahlig ist); ohne `items` wird der Wert nicht gelesen. Glossar 37 legt int fest. Entscheidung: int in beiden Funktionen, ein float ist ein Fehler mit Abhilfe; der Codemod meldet floats in `kariert` und löscht einen float in `liniert` ohne `items` (Anteil unter den 37 Aufrufen nicht gezählt).
11. **`kariert` behält `width` als Länge (über A.7 hinaus).** A.7 gibt `kariert` nur `columns` (int); K 4.4 Nr. 4 sagt „die Spaltenzahl steht nur in `columns:`"; G 36 verbietet `width` als Kästchenzahl. `kariert` nimmt heute aber auch eine Länge (kompiliert geprüft), und im lokalen Bestand sind alle 16 gefundenen Aufrufe mit `width:` Längen, einer davon ein Ausdruck (`scale * 1980mm`). Eine reine Umbenennung `width` → `columns` machte daraus `columns: 5cm`, also einen Fehler in jedem dieser Dokumente; eine Umrechnung Länge durch `grid-size` geht nur bei Literalen und nur bei ganzzahligem Ergebnis. **Entscheidung:** `kariert` hat `columns: auto` (int) **und** `width: auto` (length, G 31, wie in `liniert`); beides zugleich ist ein Fehler. Kein Wort bekommt dadurch zwei Typen. A.7 braucht die Zeile.
12. **`klausurbögen` wird `klausurboegen` (entschieden, K 9.3).** Die frühere Fassung dieser Tabelle strich hier den Übergangsnamen `klausurboegen = answer-sheets`. Mit der Entscheidung vom 2026-11-15 gibt es weder Übergangsnamen noch eine Funktion `answer-sheets`: Der Baustein heißt `klausurboegen` wie sein Paket, `klausurbögen` ist der abbrechende Stub. Der neue Name trifft auf keinen Bestandsaufruf (0.0.1–0.0.5 definieren nur `klausurbögen`; 0 Aufrufe `klausurboegen(`). Geblieben ist der Hinweis aus der Prüfung: Das Wort hat drei Träger (Paket und Modul, Funktion, alter Kopfparameter `klausurboegen:` von klassenarbeit, der `answer-sheets` wird). Nach `#import "@schule/klausurboegen:0.4.1"` und einem späteren `: *`-Import desselben Pakets überschreibt die Funktion die Modulbindung, `klausurboegen.internal` ist dann nicht mehr erreichbar. Für Dokumente ist das folgenlos (K 7.2); Paketquelltext importiert das Modul unter anderem Namen (`as kb`).
13. **Compat-Umfang für Quellen bis 0.1.1.** K 9.2 nimmt die häufigen älteren Namen in den Umfang, K 5.5 verlangt „gleiches Dokument, gleiches PDF". Für Quellen bis 0.1.1 ist das zweite nicht erreichbar. Entscheidung: Die Kontextregeln sichern dort nur, dass kein Merkmal neu an- oder abgeschaltet wird und keine Vorgabe still kippt (`points`, `expectations`, `info-table`, `logo`, `figure-font-size`, `correction-margin`, Bögen); das PDF-Kriterium gilt für Quellen ab 0.3.0. Alternative für den Autor: Dokumente bis 0.1.1 gar nicht anheben und die alten Namen dort nur mit „heißt jetzt" melden.
14. **Schema des Anhangs.** K 9.2 nennt je Funktion die Felder `renamed`, `values`, `removed`, `context`; die drei Tabellen benutzen eigene, voneinander verschiedene Blocknamen. Entscheidung für diese Tabelle: Die Blöcke sind eindeutig auf die Felder aus K 9.2 abgebildet (Lesart), `entfernt` trägt die Hinweistexte, interne Namen stehen getrennt und gelten nie für Dokumente. Die tatsächliche Vereinheitlichung ist ein eigener Schritt beim Zusammenführen zu `regeln.json`; sie ist hier nicht erledigt.
15. **`margin` in `answer-sheet-pages`.** G 52 sagt „dictionary wie Typst", die Theme-Schlüssel sind `(top, bottom, inside, outside)` (A.12). Hier wird der Wert verrechnet (Spaltenabstand `2 * x`), also besteht er den Durchreichtest nicht. Entscheidung: W7 mit den festen Schlüsseln `top`, `bottom`, `x` (alle drei sind auch Typst-Schlüssel), andere Schlüssel sind ein Fehler mit Abhilfe. Alternative: vor der Rechnung über eine gemeinsame Normalisierung in `arbeitsblatt.internal` alle Typst-Formen annehmen.
16. **`"answer-sheets"` wird an jede Variantenliste angehängt.** Heute erzeugen aktive Bögen die Bögen-Datei auch dann, wenn `varianten` ausdrücklich ohne sie angegeben ist. Entscheidung: bleibt (L25, gleiche Ausgabe), wird im Docstring genannt. Alternative: eine ausdrückliche Liste gilt wörtlich; das wäre eine Verhaltensänderung mit eigenem Eintrag in `regeln.json`.

## 8. Glossarlücken und Hinweise an die Konvention

- „Vordruck" (Tabelle steht schon auf dem Bogen): neu `points-table-preprinted`; das Wort `preprinted` fehlt in `words-en.txt`.
- „Rückseite" des Bogens: neu `back-page`, `back-page-tasks`; das Wort `back` fehlt in `words-en.txt`.
- „Arbeit direkt auf dem Klausurbogen": kein Glossareintrag und kein Parameter in A.2; hier `answer-sheet-pages`.
- „Zählweise der Seitenzahlen": Glossar 39 nennt `page-numbering` als Muster, A.2 benutzt es als Auswahl; hier `page-counter` (Zweifelsfall 2).
- „Punkte je Aufgabe als Datenliste" (`aufgaben:` in `bogen-seiten`): hier `task-points`.
- „Abstand zwischen Kopfbereich und erstem Inhalt": hier `header-spacing` nach G 34; G 34 sollte den Fall ausdrücklich nennen.
- „Teilaufgaben in der Punktetabelle ausweisen" (`teilaufgaben:` im `bogen`-Dictionary): hier `points-table-subtasks`.
- „Name beim Ergebnisdruck" (`namen`): hier `overprint-name`; K 11.4 nennt `name-fields`.
- „Seitenrand, mit dem das Paket rechnet": G 52 kennt nur „dictionary wie Typst"; hier W7 mit `top`, `bottom`, `x`.
- Die Aspektliste in K 1.2 Schritt 3 enthält weder `blank` noch `preprinted`, obwohl A.6 `correction-margin-blank` bildet. `blank` ist zugleich das Parameterwort des Bausteins `luecke` (K 2.1b, Glossar 11) und hier Aspekt „ohne Muster“; L27d („meint ein Segment einen Baustein …“) greift nicht, weil hier keine Lücke gemeint ist. Der Name bleibt wie in A.6, die Doppelbelegung ist gemeldet.
- A.7 `flex-area(height, body)`: `body` ist dort eine Funktion `length => content`, nach G 79 ist `body` überall content (L6). Der Name bleibt wie in A.7; G 79 braucht die Ausnahme oder A.7 einen anderen Namen.
- A.7 ist mit Typst nicht wörtlich umsetzbar (Positionsparameter `rows` mit Vorgabe), siehe Zweifelsfall 1; A.7 gibt `kariert` keine Breite als Länge, siehe Zweifelsfall 11.
- A.5 (`blocks: auto`) ist durch die aufgaben-Tabelle überholt (`select`, `blocks: ()`); K 6 nennt als Schlüssel von `expectations` noch die alte Form.
- K 9.2, Pflichteintrag „`stufe` im Kopf von klassenarbeit: entfernt, mit Hinweis auf `answer-sheets: (stage: …)`": deckt nur die Bedeutung bis 0.1.1; in 0.4.0 ist `stufe` ein Metadatum.
- Erledigt durch die Entscheidung vom 2026-11-15: K 9.3 und L23 führen keinen Übergangsnamen mehr; `klausurboegen` ist der Baustein (Zweifelsfall 12).
- Erledigt: Die abbrechenden Stubs (`klausurbögen` mit Umlaut, `bogen-seiten`, `klausurbogen-arbeit`, `flex-feld`, `ist-flex-feld`) stehen nach K 9.3 in `src/removed.typ` und sind von L1 und L27 ausgenommen, L19 zählt sie zur Exportmenge. Neu offen: K 9.3 gibt dem Stub nur die Form „heißt jetzt“; `bogen-seiten` und `klausurbogen-arbeit` haben keinen öffentlichen Nachfolger und brauchen die Form „gibt es nicht mehr – …“ mit dem Hinweistext aus `entfernte-funktionen`.
- K 8.3 nennt für `pattern: "kariert"` die Meldungsart „deutscher Bausteinname als Wert“; `"kariert"`, `"liniert"` und die Varianten `"klausurboegen"` und `"loesung"` sind zugleich alte Werte der Compat-Tabelle („heißt jetzt“). Diese Tabelle folgt dem Beispiel aus K 8.3; K 8.3 sollte den Vorrang ausdrücklich nennen.
- klassenarbeit reicht den Baustein `klausurboegen` nicht durch (4.1). Der frühere Grund (L14) ist entfallen; K 7.1 sagt nicht, ob klassenarbeit außer der Liste von arbeitsblatt weitere Bausteine durchreichen darf.
- Funktion und Paket heißen beide `klausurboegen`; ein Modulimport und ein späterer `: *`-Import desselben Pakets überschreiben einander (Zweifelsfall 12).
- K 7.1 exportiert `internal` aus jedem Paket; bei `: *`-Importen mehrerer Pakete überschreibt das letzte die anderen. „klassenarbeit exportiert alles, was arbeitsblatt exportiert" kann `internal` nicht einschließen.
- K 9.2 legt Feldnamen für `regeln.json` fest, die keine der drei Tabellen benutzt (Zweifelsfall 14).
- K 2.1 nennt die Dateinamen der Bündelausgabe von klassenarbeit nicht.
- K 5.5 („gleiches PDF") und K 9.2 (Umfang bis 0.0.x) passen für Quellen bis 0.1.1 nicht zusammen (Zweifelsfall 13).

## 9. Prüfprotokoll

Zwei Prüfer (Vollständigkeit 17, Regeltreue 21), 38 Befunde. Jeder wurde gegen den Quelltext geprüft (`klassenarbeit` 0.0.5, 0.0.8, 0.1.0, 0.1.1, 0.1.2, 0.3.0–0.4.0; `klausurboegen` 0.0.1–0.0.5; `patterns/0.0.2`; `aufgaben` 0.3.0/0.3.1; `arbeitsblatt` 0.2.4/0.4.0; `template/ka.typ`), die Aussagen zu patterns zusätzlich durch Kompilieren mit Typst 0.15.1 (Probedateien im Scratchpad, danach gelöscht). Die Zählungen im lokalen Bestand (68 Köpfe mit `stufe`, 53 ohne `punkte`, 16 `kariert`-Aufrufe mit `width:` usw.) stammen von den Prüfern und wurden nicht nachgezählt. Ergebnis: 36 übernommen, 2 teilweise übernommen (V8, R13), keiner verworfen. Drei Übernahmen weichen bewusst vom Wortlaut der Konvention ab (R1/A.7, R7/A.2, R14/K 11.4) und sind in Abschnitt 8 gemeldet; die vierte (R19/K 9.3) ist seit der Entscheidung vom 2026-11-15 gegenstandslos. Nebenbei angeglichen: `subtask-numbering` und die Schlüssel von `expectations` folgen dem Stand der aufgaben-Tabelle.

| Nr. | Prüfer, Schwere | Befund | Ergebnis |
|---|---|---|---|
| V1 | Vollständigkeit, hoch | `stufe` hat zwei Bedeutungen; JSON-Regel erzeugt ein zweites `answer-sheets` und schaltet Bögen ein | übernommen: arbeitsblatt/0.4.0 Z. 297, 596, 1018 und klassenarbeit/0.0.8 Z. 141–161 bestätigt; Zeile in 1.1 neu, aus `werte` nach `kontext`, zwei Meldungen. |
| V2 | Vollständigkeit, hoch | `info-table` und `table` sind in 0.0.8–0.1.1 zwei Parameter mit anderer Bedeutung | übernommen: 0.0.8 Z. 21, 103 und 0.1.1 Z. 49, 146 bestätigt; Kontextregel, `table` unter `nur-kontext`. |
| V3 | Vollständigkeit, mittel | Wertabbildungen fehlen für die Dictionary-Schlüssel; vier Lösch-Einträge fehlen | übernommen: Vererbungsregel in der Lesart, `bogen-seiten.*` ausgeschrieben, `schueler`, `ergebnisse: none`, `table: ()`, `teacher/class/date: ""` ergänzt. |
| V4 | Vollständigkeit, mittel | `klassenarbeit.bogen` unvollständig, `rand` doppeldeutig | übernommen: klassenarbeit/0.3.1 Z. 263–271 bestätigt; 2.2 und JSON vollständig, Hinweis zur Doppeldeutigkeit. |
| V5 | Vollständigkeit, mittel | „Länge ist ein Fehler" bei `kariert.width` stimmt nur mit `content` | übernommen: per Kompilieren bestätigt; statt der vorgeschlagenen Umrechnung in `columns` gilt die Lösung aus R1 (`width` bleibt Länge). |
| V6 | Vollständigkeit, mittel | `liniert(items-spacing: 1.5)` bricht nur mit `items` ab | übernommen: per Kompilieren bestätigt; Kopf, 3.2, Abschnitt 5 Nr. 36, Zweifelsfall 10 berichtigt. |
| V7 | Vollständigkeit, mittel | abweichende Vorgaben älterer Versionen fehlen | übernommen: an den Signaturen 0.0.5–0.1.1 bestätigt; fünf Kontextregeln (`expectations`, `correction-margin`, `figure-font-size`, `logo`, `points`), dazu Zweifelsfall 13. |
| V8 | Vollständigkeit, mittel | `new-page` wirkt in älteren Versionen | teilweise übernommen: für 0.3.2 bestätigt (Z. 296) und eingearbeitet; für 0.3.0 trifft es nicht zu (Z. 290–291 werten nur `erwartungen == true` aus, kein Dictionary). Der Hinweis „Dictionary = aus" gilt deshalb für 0.3.0 und 0.3.1. |
| V9 | Vollständigkeit, mittel | Schlüsselliste in 1.2 mischt zwei Äste | übernommen: Importzeilen (Z. 23) aller Versionen bestätigt; Quellversion je Schlüssel. |
| V10 | Vollständigkeit, niedrig | Spalte „alt 0.0.4" in 2.3 falsch | übernommen: `studentHeader` in 0.0.4 Z. 544 gefunden, die vier Layout-Helfer dort nicht; Tabelle und Einleitung von Abschnitt 2 berichtigt. |
| V11 | Vollständigkeit, niedrig | JSON `funktionen` schreibt Dokumente auf interne Namen um | übernommen: Blöcke `intern`, `entfernte-funktionen`; `klausurboegen` als alter Name gestrichen. |
| V12 | Vollständigkeit, niedrig | Bögen-Variante wird auch an ausdrückliche Listen angehängt | übernommen: KA 452–454 bestätigt; Zeile in 1.5, Zweifelsfall 16 (bleibt). |
| V13 | Vollständigkeit, niedrig | Vorlage: weitere Zeilen mit alten Namen | übernommen: Z. 11, 13, 14, 19 in 1.8. |
| V14 | Vollständigkeit, niedrig | feste Ausgabetexte unvollständig, CSV-Filter | übernommen: Texte an KB 288, 303 und KB4 792, 841, 848 bestätigt; Filter aus 0.0.4 Z. 569 übernommen. |
| V15 | Vollständigkeit, niedrig | `liniert.width` nimmt benannt auch eine Zahl | übernommen: per Kompilieren bestätigt; Zeile 3.2, Kontextregel. |
| V16 | Vollständigkeit, niedrig | `<ab-meta>` falsch wiedergegeben | übernommen: arbeitsblatt Z. 590–602 bestätigt; Zeile in 1.6, Zweifelsfall 4 (`typ` bleibt `none`). |
| V17 | Vollständigkeit, niedrig | Schlüssel `move` aus 0.0.8 fehlt | übernommen: 0.0.8 Z. 28 bestätigt; `move` → `offset`. |
| R1 | Regeltreue, hoch | `width` → `columns` bricht alle Aufrufe mit Länge | übernommen: `kariert` behält `width` (length) und bekommt `columns` (int); geht über A.7 hinaus, Zweifelsfall 11. |
| R2 | Regeltreue, hoch | `stufe`-Regel schaltet Bögen ein oder erzeugt ein doppeltes Argument | übernommen: zusammen mit V1. |
| R3 | Regeltreue, hoch | `points: none` nur für 0.3.x/0.4.0 ergänzt | übernommen: Vorgabe `"keine"` in 0.0.8, 0.1.0, 0.1.1 und arbeitsblatt 0.2.4 Z. 220 bestätigt; Regel ohne Versionsbedingung. |
| R4 | Regeltreue, hoch | `klausurboegen-settings` und `ergebnisse` schalten die Bögen ein | übernommen: 0.0.8 Z. 148 (`#if klausurboegen`) bestätigt; Kontextregeln nach Zustand der Bögen. |
| R5 | Regeltreue, mittel | `header-ascent` für `abstand` hat zwei Bedeutungen | übernommen: KB4 Z. 860 ist ein `v(…)`; `header-spacing`. |
| R6 | Regeltreue, mittel | `margin` ist nicht W9 | übernommen: W7 mit festen Schlüsseln, Fehler für andere; `rand`/`unten` nur noch unter `kontext` und `nur-kontext`; Zweifelsfall 15. |
| R7 | Regeltreue, mittel | `page-numbering` mit zwei Typen in einer Signatur | übernommen: `page-counter`; weicht von A.2 ab, Zweifelsfall 2. |
| R8 | Regeltreue, mittel | `table`/`info-table` bekommen neue Bedeutung | übernommen: zusammen mit V2. |
| R9 | Regeltreue, mittel | Strings bei `erwartungen` ohne Wertabbildung | übernommen: 0.1.2 Z. 244 (`== true`) bestätigt; `werte`, Meldung „falsches Aus", Abschnitt 5 Nr. 46. |
| R10 | Regeltreue, mittel | `alle`/`teile` anders geregelt als in der aufgaben-Tabelle | übernommen: Regel der aufgaben-Tabelle in ihrem heutigen Stand (`select`, `blocks: ()`), nicht in der im Befund zitierten älteren Form (`blocks: none`); Zweifelsfall 7 ersetzt. |
| R11 | Regeltreue, mittel | `is-flex-area` in zwei Tabellen verschieden | übernommen: Kopie bleibt als `aufgaben.internal.is-flex-area`, wie in der aufgaben-Tabelle. |
| R12 | Regeltreue, mittel | `points-table` mit drei Typen | übernommen: `points-content`, `name-line-content`, Funktion `points-table-content`. |
| R13 | Regeltreue, mittel | JSON: interne Namen, drei Schemata, `studentHeader` | teilweise übernommen: Punkte 1 und 3 ganz (Block `intern`, `entfernte-funktionen`, `studentHeader` nur intern); Punkt 2 nur als Abbildung auf die Felder aus K 9.2 und mit Hinweistexten in `entfernt` – ein gemeinsames Schema lässt sich nicht in einer der drei Tabellen allein festlegen (Zweifelsfall 14). |
| R14 | Regeltreue, mittel | `name-fields` neben `name-field` | übernommen: `overprint-name` (0.0.4 Docstring Z. 386–388 bestätigt); weicht von K 11.4 ab, Zweifelsfall 5. |
| R15 | Regeltreue, mittel | `subtask-columns` als bool | übernommen: `points-table-subtasks`. |
| R16 | Regeltreue, niedrig | `seite4` überschreibt `rueckseite` still | übernommen: klassenarbeit/0.3.1 Z. 241–251 bestätigt; Fehler bei beiden zugleich, Abschnitt 5 Nr. 41. |
| R17 | Regeltreue, niedrig | zwei interne Namen mit Abstand 1 | übernommen: `answer-sheets-variant` und `exam-on-sheet`. |
| R18 | Regeltreue, niedrig | `internal` kollidiert zwischen Paketen | übernommen: Klarstellung in 4.1, Absatz nach 4.3, Hinweis an K 7.1. |
| R19 | Regeltreue, niedrig | Übergangsname `klausurboegen` überbrückt nichts | übernommen: `grep '#let klausurboegen'` über alle fünf Versionen ohne Treffer; gestrichen, weicht von K 9.3/L23 ab, Zweifelsfall 12. (Überholt am 2026-11-15: `klausurboegen` ist jetzt der Bausteinname, Übergangsnamen gibt es nicht mehr.) |
| R20 | Regeltreue, niedrig | `liniert(3, width: 10)` läuft heute | übernommen: zusammen mit V15. |
| R21 | Regeltreue, niedrig | `body` als Funktion, `blank` doppelt belegt, Wörter fehlen | übernommen als Meldung: Namen bleiben wie in A.6/A.7, die Widersprüche stehen in 3.3 und Abschnitt 8. |

**2026-11-15: Entscheidung deutsche Bausteine eingearbeitet.** Die Tabelle folgt jetzt der Entscheidung des Autors (K 1.1, K 2.1a, K 9.3): `klassenarbeit`, `kariert` und `liniert` behalten ihren Funktionsnamen, `klausurbögen` wird nur wegen der Umschrift `klausurboegen`; die englischen Zwillinge `exam`, `answer-sheets`, `squares`, `lines` kommen als Funktionsnamen nicht mehr vor. Gestrichen sind die Übergangsnamen samt JSON-Block `uebergangsnamen`, der Codemod-Schalter `--aliase` und die Abweichung von K 9.3 in Zweifelsfall 12; neu ist der JSON-Block `bausteine-unveraendert`, und die Fehlermeldungen tragen die Präfixe `klassenarbeit.klassenarbeit:`, `klausurboegen.klausurboegen:`, `patterns.kariert:`, `patterns.liniert:`. Parameter, Schlüssel, Enum-Werte, Aktionen und die internen Namen sind unverändert englisch geblieben (`answer-sheets:`, `pattern: "squares"`, `internal.exam-single`); Verweise auf K 11.6 zeigen jetzt auf K 11.4, die Versionsnummer auf K 11.1. Für deutsche Bausteinnamen als Wert (`"kariert"`, `"liniert"`, die Varianten `"klausurboegen"` und `"loesung"`) steht die Meldungsart aus K 8.3. Es wurde nur diese Datei geändert und nichts neu kompiliert; dass `klausurboegen` als Funktionsname mit keinem Fremdexport kollidiert, ist nicht nachgeprüft, und vier neue Hinweise an die Konvention stehen in Abschnitt 8.

**2026-11-15: Nachprüfung nach der Entscheidung (ein Prüfer, 5 Befunde, alle übernommen, keiner verworfen).** (1) Einleitung dieses Abschnitts: drei statt vier Abweichungen, R19/K 9.3 ist gegenstandslos. (2) Die Variante `"loesung"` bekommt in 1.7 dieselbe Meldung „deutscher Bausteinname als Wert“ wie `"klausurboegen"` (K 2.1a, K 8.4); Abschnitt 8 und der Vermerk oben zählen sie mit auf. Der JSON-Anhang bleibt, beide stehen dort weiter als alte Werte für den Codemod. (3) Laufzeitmeldung zu `stufe` in 1.1 und im JSON wörtlich wie K 8.3 („der Notenschlüssel steht in …“, ohne „der Klausurbögen“). (4) 2.2, `task-points`: Begründung K 4.5 statt L14, weil klausurboegen keine Funktion `tasks` exportiert. (5) 2.4, `subtask-numbering`: W3 mit Paketregel statt W9, wie 2.1 und Zweifelsfall 9. Kein Befund zeigte einen Fehler in der Konvention.
