# Umbenennungstabelle: `@schule/arbeitsblatt` 0.4.0 → Zielversion (Kern und `themes.typ`)

Stand 2026-11-15 (nach adversarialer Prüfung überarbeitet, siehe Abschnitt 9). Grundlage: `konvention.md` (im Folgenden „K"), Inventare `inventar-arbeitsblatt-kern.md` und `inventar-arbeitsblatt-themes.md`, bei Zweifel der Quelltext `arbeitsblatt/0.4.0/src/arbeitsblatt.typ` (kurz `ab.typ`) und `src/themes.typ` (Arbeitsstand, mit der uncommitteten `atlas`-Änderung). Am Repo wurde nichts geändert.

> **Entscheidung vom 2026-11-15 eingearbeitet** (K, Kasten am Anfang, 2.1a, 2.1b, 9.3): Die Bausteine behalten auf Dauer ihren deutschen Namen. In dieser Tabelle sind das `arbeitsblatt`, `arbeitsblatt-einzeln`, `lsg`, `teilaufgaben` (unverändert) und `luecke` (bisher `lücke`, nur Umschrift). Englische Zwillinge (`worksheet`, `worksheet-single`, `blank`, `inline-solution`, `subtasks`) und Übergangsnamen gibt es nicht. Englisch bleibt alles in den Klammern (Parameter, Schlüssel, Enum-Werte, Theme-Hooks), ebenso Aktionen, Abfragen und Helfer. Wo unten `worksheet`, `exam`, `task`, `subtask`, `solution` oder `blank` steht, ist es das Parameterwort (K 2.1b), kein eigener Funktionsname. Ausnahmen: `task` als Name des gentle-clues-Kastens (1.18, 4.5, Abschnitt 5, Lücke 27, Kontextregel im JSON) und die im Prüfprotokoll (Abschnitt 9) genannten früheren Zielnamen wie `blank`.

Lesehilfe:

- Spalte **Art**: unverändert / umbenannt / Typ geändert / Default geändert / entfernt / neu / zusammengelegt (mehrere Angaben möglich).
- Spalte **Codemod**: **ja** = reine Ersetzung am Aufruf; **Kontext** = automatisch, aber die Regel hängt vom Wert ab (Feld `context` in `regeln.json`, K 9.2); **AST** = nur mit dem AST-Werkzeug (K 9.4 Nr. 2), bei dynamischen Werten Bericht; **nein** = Handarbeit, das Paket meldet die Stelle beim Kompilieren.
- Regelverweise: „K 3/26" = Glossarzeile 26, „K 4.4 Nr. 5" = Abschnitt, „L16" = Lint-Regel, „A.1" = Anhang A.1.
- **[prüfen]** = Wirkung nicht am Code bestätigt (aus K übernommen oder hier neu vermerkt).
- **Bericht** = der Codemod ändert die Stelle nicht (oder nur den Namen) und listet sie mit Datei und Zeile im Codemod-Bericht.
- Zahlen mit dem Zusatz „Prüferzählung" stammen aus der Prüfung (Suche im Bestand außerhalb des Repos), nicht aus `inventar-nutzung-ausserhalb.md`.
- **[Lücke n]** verweist auf Abschnitt 7 (Glossar- und Regellücken).
- **Baustein** = Funktion aus `bausteine-de.txt` (K 2.1a), sie heißt deutsch. **Parameterwort** = das englische Wort, das in Parametern, Schlüsseln, Werten und Hooks für einen Baustein steht (K 2.1b).

Inhalt: 1 Funktionen des Kerns · 2 `themes.typ` · 3 Schlüssel, Werte, States, Labels · 4 Öffentliche Oberfläche · 5 Fehler und Altlasten · 6 Zweifelsfälle · 7 Lücken der Konvention · 8 Maschinenlesbarer Anhang · 9 Prüfprotokoll

---

## 1. Funktionen des Kerns (`src/arbeitsblatt.typ`)

### 1.1 `arbeitsblatt` (Name unverändert; Z. 1030–1069)

Alt (wörtlich):

```typ
#let arbeitsblatt(
  title: "", class: "", paper: "a4", print: false, duplex: true, workspaces: true,
  theme: none, akzent: auto, font-size: auto, font: auto, math-font: auto,
  title-font-size: auto, figure-font-size: 9pt, landscape: false, custom-header: none,
  teilaufgabe-numbering: "a)", page-settings: (:), loesungen: "false",
  materialien: "seiten", punkte: "keine", aufgaben-shortcodes: "teilaufgaben",
  copyright: none, zweifach: false,
  varianten: auto, vorschau-alle: true, dateiname: none,
  fach: none, thema: none, jahrgang: (), stufe: none, niveau: none, typ: none,
  stichworte: (), kerncurriculum: (), stand: none,
  ..args, body,
)
```

Neu (wörtlich, = K A.1):

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
  math-font: auto,              // W5 str | array
  font-size: auto,              // W5 length
  title-font-size: auto,        // W5 length
  figure-font-size: auto,       // W5 length
  // Options-Schema (K 6)
  solutions: none,              // W2 none | "in-place" | "after-task" | "at-end" | "only"
  solutions-pagebreak: none,    // W2 none | "before" | "per-task"
  materials: "after-task",      // W2 none | "after-task" | "at-end"
  materials-pagebreak: "before",// W2 none | "before"
  points: none,                 // W2 none | "tasks" | "subtasks" | "all"
  points-total: true,           // W1
  points-position: "end",       // W2 "end" | "margin"
  points-format: auto,          // W7 auto | function | (task: f, subtask: g)
  workspaces: true,             // W1
  shortcodes: "subtasks",       // W2 none | "tasks" | "subtasks" | "all"
  subtask-numbering: "a)",      // W9
  // Varianten und Ausgabe
  variants: auto,               // W5 array aus str
  variant-overrides: (:),       // W3 dictionary: Name -> Optionen; Sonderschlüssel path
  preview-variant: auto,        // W5 str | none; "all" zeigt alle
  filename: none,               // W4 str
  // Metadaten (werden deutsch nach <ab-meta> geschrieben)
  subject: none,                // W4 str
  topic: none,                  // W4 str
  years: (),                    // W3 array aus int
  stage: none,                  // W2 "sek-1" | "sek-2"
  level: none,                  // W2 "introduction" | "consolidation" | "ea" | "ga"
  kind: none,                   // W2 "worksheet" | "practice" | "stations" | "exam"
  keywords: (),                 // W3 array aus str
  curriculum: (),               // W3 array
  revision: none,               // W4 str "JJJJ-MM-TT"
  ..deprecated,
  body,
) = { }
```

Der Funktionsname bleibt `arbeitsblatt` (Baustein, K 2.1a); einen englischen Zwilling `worksheet` gibt es nicht. `worksheet` ist nur das Parameterwort (K 2.1b), etwa in `kind: "worksheet"`. Geändert wird allein, was in den Klammern steht.

| alt | neu | Art | Wertabbildung (alt → neu) | Codemod | Begründung |
|---|---|---|---|---|---|
| `arbeitsblatt` (Funktion) | `arbeitsblatt` | unverändert | – | – (kein Eingriff; der Codemod lässt den Aufruf stehen) | K 2.1a (Baustein), K 3/1, K 9.3 „Unverändert bleiben" |
| `title: ""` | `title: none` | Default geändert | `""` → Argument löschen; `[]` → Argument löschen; sonst gleich. Nach `<ab-meta>` wird bei `none` weiter `""` geschrieben (3.5) | Kontext | K 3/13, K 5.2 (leerer Text ist `none`), K 9.2 Pflichteintrag, L8 |
| `class: ""` | `class: none` | Default geändert | `""` → Argument löschen; sonst gleich (1187 Köpfe unverändert). Nach `<ab-meta>` wird bei `none` weiter `""` geschrieben (3.5) | Kontext | K 3/15, K 5.2, L8; K 9.2 nennt `class` nicht unter den `""`-Feldern, die Regel 5.2 gilt trotzdem |
| `paper: "a4"` | `paper: "a4"` | unverändert | – | – | K 3/50, W9 Durchreichtest; künftig geprüft (bei `two-up` nur `"a4"`, `"a5"`, `"a6"`) |
| `print: false` | `print: false` | unverändert | – | – | K 3/55, W1 |
| `duplex: true` | `duplex: true` | unverändert | – | – | K 3/56, W1 |
| `workspaces: true` | `workspaces: true` | unverändert | – | – | K 3/10, K 6 |
| `theme: none` | `theme: auto` | Default geändert, Typ geändert (`none` entfällt) | `none` → Argument löschen; `"standard"` → Argument löschen; `"klar"` … `"bauhaus"` gleich; Dictionary: Schlüssel nach 2.3; Funktion: Signatur nach 2.2 | Kontext für `none`/`"standard"`/Namen; **nein** für eigene Dictionaries und Funktionen (Bericht) | K 3/61 (`"standard"` verboten), W8, K Anhang C („`theme: none` für Standard"), K 5.1 (`auto` = Paket entscheidet). Wirkung der Vorgabe bleibt: klassische Darstellung (L25) |
| `akzent: auto` | `accent: auto` | umbenannt | Werte gleich | ja | K 3/26, W5 |
| `font-size: auto` | `font-size: auto` | unverändert | – ; `auto` ohne Theme = 12pt (`ab.typ` Z. 334), mit Theme dessen `font-size` | – | K 3/49 (1133 Köpfe) |
| `font: auto` | `font: auto` | unverändert | – ; `auto` ohne Theme = `"Myriad Pro"` (Z. 332) | – | K 3/48 |
| `math-font: auto` | `math-font: auto` | unverändert | – ; `auto` ohne Theme = `"Fira Math"` (Z. 333) | – | K 3/48 |
| `title-font-size: auto` | `title-font-size: auto` | unverändert | – ; `auto` ohne Theme = 16pt (Z. 335) | – | K 3/49 |
| `figure-font-size: 9pt` | `figure-font-size: auto` | Default geändert | Werte gleich; `auto` = 9pt (kein Theme-Schlüssel, PDF gleich) | – | K 3/49, W5, A.1; Eintrag in `regeln.json` nötig (L25) |
| `landscape: false` | `landscape: false` | unverändert | – | – | K 3/51 |
| `custom-header: none` | `header: auto` | umbenannt, Default geändert | `custom-header: none` → Argument löschen (heute Standardkopf; `header: none` hieße „kein Kopf"); `custom-header: <inhalt>` → `header: <inhalt>` | Kontext | K 3/54, L4 (`custom-`), K 9.2 Pflichteintrag |
| `teilaufgabe-numbering: "a)"` | `subtask-numbering: "a)"` | umbenannt | `"a)"` gleich; `"1."` → `"1.1"` (am Code bestätigt: `"1."` setzt `numbering("1.1", aufgabe, n)`, aufgaben.typ Z. 1173); heute sind nur diese zwei Werte erlaubt (`ab.typ` Z. 319) | Kontext | K 3/39, K 6 |
| `page-settings: (:)` | `page-settings: (:)` | unverändert (nimmt zusätzlich `header-ascent` auf) | – | – | K 4.4 Nr. 5 (einzige Durchreich-Ausnahme), A.1 |
| `loesungen: "false"` | `solutions: none` und `solutions-pagebreak: none` | umbenannt, Typ geändert, Default geändert (Schreibweise), aufgeteilt | `"false"`, `"keine"`, `false`, `none` → Argument löschen; `"sofort"` → `"in-place"`; `"folgend"` → `"after-task"`; `"reinquetschen"` → `"at-end"`; `"seite"` → `solutions: "at-end", solutions-pagebreak: "before"`; `"seiten"` → `solutions: "at-end", solutions-pagebreak: "per-task"`; `"nur"` → `"only"`. Am Code bestätigt (aufgaben.typ): `"seite"` = ein `pagebreak(weak: true)` vor dem Lösungsblock (Z. 304–306); `"seiten"` = jede Aufgabenlösung mit `page(…)` auf einer eigenen Seite (Z. 311–312). `"per-task"` muss deshalb als eigene Seite je Aufgabe (`page(…)`) umgesetzt werden, nicht als bloßer Umbruch davor | Kontext (390 Köpfe; Literalwerte) | K 3/5, K 6, K 5.2, K 9.2 Pflichteintrag |
| – | `solutions-pagebreak: none` | neu (aus `loesungen` abgespalten) | siehe `loesungen` | – | K 1.2 Schritt 3, K 6 |
| `materialien: "seiten"` | `materials: "after-task"` und `materials-pagebreak: "before"` | umbenannt, Typ geändert, aufgeteilt | `"seiten"` → Argument löschen (Vorgabe); `"keine"`, `"false"`, `false`, `none` → `materials: none`; `"sofort"`, `"folgend"` → `materials: "after-task", materials-pagebreak: none` (am Code bestätigt: beide Werte werden bei Material gleich behandelt, aufgaben.typ Z. 1076, 1290); `"reinquetschen"` → `materials: "at-end", materials-pagebreak: none`; `"seite"` → `materials: "at-end"` (Umbruch ist Vorgabe). **Wirkung von `"before"` je Lage (so muss es umgesetzt werden, damit das PDF gleich bleibt):** bei `"after-task"` steht jedes Aufgabenmaterial mit `page(…)` auf einer eigenen Seite, also Umbruch davor und danach (Z. 819–820, 1296); bei `"at-end"` ein einziger weicher Umbruch vor dem ganzen Materialteil (Z. 814–816). Der Wertname sagt nur „davor", siehe [Lücke 13] | Kontext | K 3/9, K 6, K 9.2 Pflichteintrag |
| – | `materials-pagebreak: "before"` | neu (aus `materialien` abgespalten) | siehe `materialien` | – | K 6 |
| `punkte: "keine"` | `points: none`, `points-total: true`, `points-position: "end"` | umbenannt, Typ geändert (kein Dictionary mehr), aufgeteilt | `"keine"` → Argument löschen; `"aufgaben"` → `"tasks"`; `"teilaufgaben"` → `"subtasks"`; `"alle"` → `"all"`; `"keine-summe"` → `points: "all", points-total: false`; `(anzeige: X, position: P)` → `points: <X abgebildet>, points-position: <P abgebildet>`; fehlt `anzeige` im Dictionary → `points: "tasks"` (heutiger Fallback Z. 314) | Kontext (String), AST (Dictionary) | K 3/8, K 5.1 (kein Parameter ist Auswahl und Dictionary), K 6, K 9.2 |
| `punkte.anzeige` (Schlüssel) | `points` | zusammengelegt | wie `punkte` | AST | K 5.1 |
| `punkte.position` (Schlüssel) | `points-position` | umbenannt (flaches Geschwister) | `"ende"` → `"end"`; `"rand"` → `"margin"` | AST | K 1.2 Schritt 3, K 3/72, K 6 |
| – | `points-total: true` | neu (aus `"keine-summe"`) | siehe `punkte` | – | K 5.3 (Wert benennt nie, was fehlt), K 6 |
| – | `points-format: auto` | neu im Kopf von `arbeitsblatt` (bisher nur klassenarbeit `punkte-template`, State `punkte-template-aufgabe`/`-teilaufgabe`) | – | – | W7, K 6, L17 |
| `aufgaben-shortcodes: "teilaufgaben"` | `shortcodes: "subtasks"` | umbenannt, Typ geändert (`none` als Aus) | `"teilaufgaben"` → Argument löschen (Vorgabe); `"keine"` → `none`; `"aufgaben"` → `"tasks"`; `"alle"` → `"all"` | Kontext (253 Köpfe) | K 3/90, K 5.2, K 6 |
| `copyright: none` | `copyright-url: none` | umbenannt | Werte gleich | ja | A.1; Name sagt, was erwartet wird (URL für den QR-Code), Inventar 7.3 |
| `zweifach: false` | `two-up: false` | umbenannt | Werte gleich; `two-up: true` ohne `print: true` ist künftig ein Fehler „unzulässige Kombination" | ja | K 3/57, K 8.3 |
| `varianten: auto` | `variants: auto` und `variant-overrides: (:)` | umbenannt, Typ geändert (nur noch Array), aufgeteilt | `auto` gleich (= `("digital", "solutions")`); `"x"` → `("x",)`; Array gleich; Dictionary `(name: (…))` → `variants: ("name",)` und `variant-overrides: (name: (…))` (leere Overrides entfallen); Namen: `"druck"` → `"print"`, `"digital"` gleich, `"loesung"` → `"solutions"`, `"zweifach"` → `"two-up"`; eigene Namen bleiben | Kontext (String, Array aus Literalen), AST (Dictionary; 113 Köpfe) | K 3/58, K 5.3, K 9.2 Pflichteintrag, Anhang C |
| – | `variant-overrides: (:)` | neu (aus `varianten`-Dictionary) | Schlüssel der Overrides: alle Parameter von `arbeitsblatt-einzeln` außer `scope`, nach dieser Tabelle umbenannt, samt Wertabbildung; Sonderschlüssel `datei` → `path` | AST | K 3/60, A.1, K 8.4 (Overrides werden geprüft) |
| `vorschau-alle: true` | `preview-variant: auto` | umbenannt, Typ geändert (bool → Auswahl) | `true` → Argument löschen; `false` → `preview-variant: none` (nie Varianten in der Vorschau); neu möglich: `"all"` (immer alle), `"<name>"` (genau diese Variante) | Kontext | K 3/58, A.1; Wert `none` siehe [Lücke 9] |
| `dateiname: none` | `filename: none` | umbenannt | Werte gleich (60 Köpfe) | ja | K 3/59 |
| `fach: none` | `subject: none` | umbenannt | Werte gleich; `<ab-meta>`-Schlüssel bleibt `fach` | ja | K 3/16, K 2.1 |
| `thema: none` | `topic: none` | umbenannt | Werte gleich; Meta-Schlüssel `thema` bleibt | ja | K 3/17 |
| `jahrgang: ()` | `years: ()` | umbenannt | Werte gleich; Meta-Schlüssel `jahrgang` bleibt | ja | K 3/21, L9 |
| `stufe: none` | `stage: none` | umbenannt | `"sek-1"`, `"sek-2"` gleich; künftig geprüft | ja | K 3/23 |
| `niveau: none` | `level: none` | umbenannt, Typ geändert (heute dokumentierter, aber ungeprüfter String → geprüfte Auswahl) | `"einfuehrung"` → `"introduction"`; `"vertiefung"` → `"consolidation"`; `"ea"`, `"ga"` gleich; jeder andere Wert: keine automatische Abbildung, **Bericht**; nach `<ab-meta>` wird der alte deutsche Wert geschrieben (3.5) | Kontext | K 3/24, A.1, K 2.1 |
| `typ: none` | `kind: none` | umbenannt, Typ geändert (heute freier, ungeprüfter String „Materialart, z. B. …", `ab.typ` Z. 1022 → geschlossene Auswahl) | `"arbeitsblatt"` → `"worksheet"`; `"uebung"` → `"practice"`; `"stationsarbeit"` → `"stations"`; `"klausur"` → `"exam"`; **jeder andere Wert: keine automatische Abbildung, Bericht** (für ihn gibt es weder einen neuen Wert noch einen Rückweg nach `<ab-meta>`, siehe Zweifelsfall 16); nach `<ab-meta>` der alte deutsche Wert (3.5) | Kontext | K 3/25, A.1, K 5.3 |
| `stichworte: ()` | `keywords: ()` | umbenannt | Werte gleich | ja | K 3/88 |
| `kerncurriculum: ()` | `curriculum: ()` | umbenannt | Werte gleich | ja | K 3/88; Singular bei Vorgabe `()` verstößt formal gegen L9, siehe [Lücke 21] |
| `stand: none` | `revision: none` | umbenannt | Werte gleich | ja | K 3/87 |
| `..args` | `..deprecated` | umbenannt, Typ geändert (nimmt nichts an) | `header-ascent: X` → `page-settings: (header-ascent: X)` (in ein vorhandenes `page-settings` einfügen); alles andere: Meldung nach K 8.3; überzählige Positionsargumente: Fehler | Kontext / AST | K 4.4 Nr. 5 c und Nr. 6, L16, A.1 |
| `body` | `body` | unverändert | – | – | K 3/79 |
| (älter) `header-font-size` (1063 Köpfe) | je nach gepinnter Quellversion: `title-font-size` oder – | **Quelle 0.0.2–0.0.7:** umbenannt (dort echter Parameter, z. B. `0.0.7/arbeitsblatt.typ` Z. 16). **Quelle 0.1.0–0.3.2:** entfernt – der Name fiel dort in den Sink `..args` und war wirkungslos, der Titel stand fest auf `title-font-size` (16pt). **Quelle 0.4.0:** kommt nicht vor (dort Fehler „unbekannte Option", Z. 322–326) | Quelle ≤ 0.0.7: Wert gleich nach `title-font-size`. Quelle 0.1.0–0.3.2: Argument löschen (PDF gleich); der Bericht nennt jede Stelle mit einem Wert ≠ 16pt (rund 40 Dokumente, Prüferzählung: 0.3.2: 18, 0.2.4: 13, 0.2.1: 4, 0.2.2: 3), weil dort jemand eine andere Titelgröße wollte und nie bekam | Kontext (Regel hängt an der gepinnten Quellversion; in `regeln.json` unter `context`, nicht unter `renamed`) | K 9.2 Umfang, K 5.5 (gleiches PDF). Laufzeitmeldung: ``arbeitsblatt.arbeitsblatt: `header-font-size` gibt es nicht mehr – war seit 0.1.0 wirkungslos; Titelgröße: `title-font-size` `` |
| (älter) `subtitle`, `erwartungen`, `klausurboegen` im `arbeitsblatt`-Kopf (12/2/2 Dateien) | – | entfernt (Compat `removed` mit Hinweis auf `klassenarbeit`); vor 0.4.0 wurden sie von `..args` still verschluckt, waren also wirkungslos | Argument löschen (PDF gleich) | ja, mit Bericht (der Bericht nennt die Stelle, weil `erwartungen`/`klausurboegen` auf eine gemeinte Klassenarbeit hindeuten) | K 9.2, K 8.3 „entfernt", K 5.5 |

### 1.2 `arbeitsblatt-einzeln` (Name unverändert; Z. 268–305)

Alt (wörtlich):

```typ
#let arbeitsblatt-einzeln(
  title: "", class: "", paper: "a4", print: false, duplex: true, workspaces: true,
  theme: none, akzent: auto, font-size: auto, font: auto, math-font: auto,
  title-font-size: auto, figure-font-size: 9pt, landscape: false, custom-header: none,
  teilaufgabe-numbering: "a)", page-settings: (:), loesungen: "false",
  materialien: "seiten", punkte: "keine", aufgaben-shortcodes: "teilaufgaben",
  copyright: none, zweifach: false, scope: none,
  fach: none, thema: none, jahrgang: (), stufe: none, niveau: none, typ: none,
  stichworte: (), kerncurriculum: (), stand: none,
  ..args, body,
)
```

Neu (wörtlich):

```typ
#let arbeitsblatt-einzeln(
  title: none, class: none, header: auto, copyright-url: none,
  paper: "a4", landscape: false, print: false, duplex: true, two-up: false, page-settings: (:),
  theme: auto, accent: auto, font: auto, math-font: auto,
  font-size: auto, title-font-size: auto, figure-font-size: auto,
  solutions: none, solutions-pagebreak: none, materials: "after-task", materials-pagebreak: "before",
  points: none, points-total: true, points-position: "end", points-format: auto,
  workspaces: true, shortcodes: "subtasks", subtask-numbering: "a)",
  scope: none,                  // W4 str; Kennung der Variante im Bündel
  subject: none, topic: none, years: (), stage: none, level: none, kind: none,
  keywords: (), curriculum: (), revision: none,
  ..deprecated,
  body,
) = { }
```

Beide Signaturen und das heutige `basis`-Dictionary (Z. 1070–1103) entstehen aus einer einzigen Parametertabelle (K A.1).

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `arbeitsblatt-einzeln` (Funktion) | `arbeitsblatt-einzeln` | unverändert (13. Kernbaustein; kein Stub nötig) | – | – | K 2.1a (`worksheet-single` entfällt als Zwilling, `arbeitsblatt-single` wäre ein Mischname), A.1, K 9.3 „Unverändert bleiben" |
| alle Parameter außer `scope` | wie 1.1 | wie 1.1 | wie 1.1 | wie 1.1 | wie 1.1 |
| `scope: none` | `scope: none` | unverändert | – | – | Wort der Gruppe B (K 2.2), A.1 |
| innere Funktion `header(title: none, class: none, font-size: 16pt, copyright: none)` (Z. 434) | `internal.default-header(title: none, class: none, copyright-url: none, font-size: auto)` | intern, umbenannt; gleiche Signatur wie der Theme-Hook `header` | – | – | K 7.2, K 4.4 Nr. 7 |

### 1.3 `qr-code` (Z. 102)

Alt: `#let qr-code(..args, light-color: white.transparentize(100%), dark-color: black, alt: "", background: none)`

Neu: `#let qr-code(url, width: auto, quiet-zone: false, fill: black, background-fill: none) = { }`

Entschieden bei der Umsetzung 0.5.0 (abweichend von K A.10, dort steht `quiet-zone: true`): Die Vorgabe ist `false`. zebra 0.1.0 gibt `quiet-zone: 0` vor und 0.4.0 setzte nichts; `true` hätte jedes PDF mit QR-Code geändert (Vorgabe 4 der Umsetzung: gleiches Dokument, gleiches PDF).

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `qr-code` | `qr-code` | unverändert | – | – | K 4.1 `<merkmal>-<substantiv>` |
| `..args` positional (URL) | `url` (führendes Hauptargument) | Typ geändert (Sink → deklariert) | – | – (Aufruf bleibt `qr-code("https://…")`) | K 4.4 Nr. 2 und Nr. 5 |
| `..args` benannt `width:` | `width: auto` | deklariert | gleich | – | K 3/31, K 4.4 Nr. 5 |
| `..args` benannt `quiet-zone:` | `quiet-zone: false` | deklariert | gleich | – | K 4.4 Nr. 5 (nennt `quiet-zone` ausdrücklich) |
| `..args` übrige zebra-Argumente | – | entfernt | Fehler „unbekannter Parameter" | nein | K 4.4 Nr. 5, L16 |
| `light-color: white.transparentize(100%)` | `background-fill: none` | umbenannt, Default geändert (Schreibweise; durchsichtig = `none`, PDF gleich) | `white.transparentize(100%)` → Argument löschen; Farbe gleich | Kontext | K 3/28, L4 (`-color`), L25-Eintrag nötig |
| `dark-color: black` | `fill: black` | umbenannt | gleich | ja | K 3/27, L4 |
| `alt: ""` | – | entfernt (toter Parameter, nie an zebra gereicht) | Argument löschen | ja | Inventar 8 (Z. 102–104), L8 (`""`) |
| `background: none` | `background-fill: none` | zusammengelegt (Altname von `light-color`) | gleich | ja | K 3/28 (`background` bei qr-code verboten), K 3/29 |

### 1.4 `qty`, `num`, `unit` (Z. 121, 145, 169)

Alt: `#let qty(..args)` · `#let num(..args)` · `#let unit(..args)`

Neu:

```typ
#let qty(value, unit, per: "fraction") = { }   // value: str | int | float | content; unit: str | content
#let num(value) = { }
#let unit(unit, per: "fraction") = { }         // unit: str | content; im Rumpf nur internal.unify-unit, nie der bare Name
```

Entschieden bei der Umsetzung 0.5.0: Der Positionsparameter heißt im Code `units` (`qty(value, units, per:)`, `unit(units, per:)`), weil das Lint L14 keinen Parameter zulässt, der wie eine eigene Funktion heißt, und die Ausnahme aus [Lücke 16] nicht eingerichtet wurde. Im Aufruf ist der Name unsichtbar (nur positional); Handbuch und Docstrings nennen `units`.

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `qty`, `num`, `unit` (Namen) | gleich | unverändert | – | – | K 7.1 `fremdnamen.txt` („Einheiten-Wrapper"), Abkürzungsliste K 2.2 |
| `qty(..args)`: 2 Positionsargumente | `value`, `unit` | deklariert | Aufrufe `#qty[9.81][m/s^2]`, `#qty("9.81", "m/s^2")` unverändert | – | K 3/68, K 3/67, K 4.4 Nr. 5; Parametername `unit` neben der Funktion `unit` verstößt formal gegen L14, siehe Zweifelsfall 8 und [Lücke 16] |
| `qty(..args)`: benannt `per:` | `per: "fraction"` | deklariert (Vorgabe wie heute über `_named-with-default-per`) | gleich | – | K 4.4 Nr. 5, L16; Wert `"fraction"` fehlt in der Wortliste ([Lücke 4]) |
| `qty(..args)`: übrige Argumente | – | entfernt | Fehler mit Abhilfe „`unify` selbst importieren". Im Bestand (Prüferzählung): `thousandsep:` 9, `e:` 15, `per-mode:` 14, `digits:` 2 | nein (Bericht mit diesen Stellen) | K 4.4 Nr. 5; ob `thousandsep` deklariert wird, ist offen (Zweifelsfall 8) |
| `num(..args)`: 1 Positionsargument | `value` | deklariert | Aufruf unverändert | – | K 3/68 |
| `num(..args)`: benannte Argumente | – | entfernt | wie oben; im Bestand (Prüferzählung) `e:` 1, `per-mode:` zusammen mit `unit` 3 | nein (Bericht) | K 4.4 Nr. 5 |
| `unit(..args)`: 1 Positionsargument | `unit` | deklariert | Aufruf unverändert | – | K 3/67: dieselbe Sache (die Einheit) heißt in `qty` und in `unit` gleich; nur positional, im Aufruf unsichtbar; L14-Ausnahme siehe [Lücke 16] |
| `unit(..args)`: benannt `per:` | `per: "fraction"` | deklariert | gleich | – | K 4.4 Nr. 5 |
| `unit(..args)`: übrige | – | entfernt | wie oben | nein | K 4.4 Nr. 5 |

### 1.5 `print-state` (Z. 180)

Alt: `#let print-state = state("print", false)`

Neu: entfällt in arbeitsblatt. Es gibt künftig genau einen Print-State, und er liegt in aufgaben: `aufgaben.internal.print-state = state("schule/aufgaben/print@1", false)` (so `tabelle-aufgaben.md` 2.4 und 3.2). `arbeitsblatt-einzeln` schreibt `aufgaben.internal.print-state.update(print)`; gelesen wird nur über `is-print()` (aufgaben, K A.5). Der Fremdschlüssel `"print"` im Options-State (`ab.typ` Z. 578, im Repo nirgends gelesen) entfällt, weil das Options-Schema geschlossen ist (L17).

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `print-state` (Name) | – ; lesend `is-print()` | entfernt aus arbeitsblatt, umgezogen nach `aufgaben.internal.print-state` | `print-state.get()` → `is-print()` (89 Aufrufe in 51 lokal gelesenen Dokumenten); `print-state.update(…)` (1 Stelle, Prüferzählung) → Bericht | ja für `print-state.get()`; Bericht für jede andere Verwendung. Kein Stub möglich: ein übersehener Aufruf endet in Typsts `unknown variable: print-state` ([Lücke 14]) | K 3/55 (`print-state` verboten), L4 (`-state`), K 4.1 `is-<adjektiv>` |
| State-Schlüssel `"print"` | `"schule/aufgaben/print@1"` (in aufgaben) | umbenannt, umgezogen | Dokumente lesen den State auch direkt über den Schlüsselstring: `state("print", false).get()` (4 Stellen, Prüferzählung) → `is-print()`. Ohne Codemod liefern diese Aufrufe nach dem Schlüsselwechsel still `false`, ohne Fehler | Kontext (Muster `state("print"…).get()`); jede andere Form Bericht | K 7.3, L17, L20; `tabelle-aufgaben.md` 2.4 |
| Schlüssel `"print"` im Options-State (`ab.typ` Z. 578) | – | entfernt | nie gelesen | – | L17 (Schema-Menge ist geschlossen), [Lücke 1] |

### 1.6 `_state_ab_scope` (Z. 185)

Alt: `#let _state_ab_scope = state("ab-scope", none)`

Neu: `internal.scope-state = state("schule/arbeitsblatt/scope@1", none)` (in `src/internal.typ`)

Nachtrag Gesamtabnahme 2026-11-15: zusätzlich `internal.started-state = state("schule/arbeitsblatt/started@1", false)`. Die Vorlage setzt ihn auf `true`, sobald sie ihre Optionen in den State von aufgaben geschrieben hat; bis dahin (im ersten Layout-Durchlauf) nimmt die Kurzschreibweise `shortcodes` aus dem Vorlagenaufruf. Ohne ihn brauchte ein Blatt mit `shortcodes: "all"`, `"tasks"` oder `none` einen Durchlauf mehr als 0.4.0 und meldete in Grenzfällen „did not converge“; das PDF ist gleich. Test `tests/v05-arbeitsblatt-kurzschreibweise-durchlauf.typ`.

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `_state_ab_scope` | `internal.scope-state` | umbenannt, intern | – | – (kein Dokument benutzt ihn; klassenarbeit Z. 319 wird im Paket angepasst) | K 7.2 |
| State-Schlüssel `"ab-scope"` | `"schule/arbeitsblatt/scope@1"` | umbenannt | – | – | K 7.3, L20 |

### 1.7 `lücke` → `luecke` (Z. 1145)

Alt: `#let lücke(body, tight: false)`

Neu (= K A.8): `#let luecke(tight: false, body) = { }`

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `lücke` | `luecke`; `lücke` als abbrechender Stub in `src/removed.typ` (``arbeitsblatt.lücke: `lücke` heißt jetzt `luecke` ``) | umbenannt (nur Umschrift nach K 2.3; der Baustein bleibt deutsch) | – | **Kontext + Bericht** (119 Aufrufe: `#lücke(` 111, `#lücke[` 8). Umbenannt wird nur, wenn das Dokument kein eigenes `#let lücke` und kein eigenes `#let luecke` hat und außer `tight:` kein benanntes Argument vorkommt; die 6 Aufrufe mit `length:` (4) und `len:` (2) gehören zu dokumenteigenen Funktionen (keine Paketversion hatte diese Parameter) und bleiben unberührt. Jede umbenannte Stelle steht im Bericht, weil sich die Lösungsfassung ändert (letzte Zeile) | K 3/11, K 2.1a, K 2.3, K 9.3 (Tabelle der Umschrift-Umbenennungen); Stub mit Umlaut siehe Zweifelsfall 9 |
| – (`luecke` war nie ein Paketname: kein `#let luecke` in irgendeinem Versionsordner) | `luecke` ist ab der Zielversion der Bausteinname | neu als Paketname | Im Bestand stehen 32 Aufrufe `#luecke(` mit `breite:` (8) und `at:` (7), dazu `#lueck(` 58: dokumenteigene Funktionen gleichen Namens. Eine lokale Definition nach dem Import überdeckt den Baustein, das Dokument verhält sich wie bisher. Vorhandene `luecke(`-Aufrufe in Quelldokumenten gehören deshalb nie dem Paket; der Codemod fasst sie nicht an. In einem solchen Dokument benennt er auch `lücke(` nicht um (das Ziel wäre die dokumenteigene Funktion), sondern berichtet die Stelle | nein (vorhandene `luecke(`-Aufrufe nie anfassen); Bericht | K 9.3 (Codemod-Bedingung bei `lücke`); siehe Zweifelsfall 11 und [Lücke 15] |
| `body` (positional, vorn) | `body` (positional, zuletzt) | unverändert im Aufruf | – | – | K 4.4 Nr. 1, L15 |
| `tight: false` | `tight: false` | unverändert | – | – | K 4.3 |
| (Verhalten) zeigt die Lösung nie: `lücke` ruft in jedem Modus `hide(body)` (am Code bestätigt, `ab.typ` Z. 1145–1159) | folgt `has-solutions()`: mit sichtbaren Lösungen steht das Wort auf der Linie | **Verhalten geändert** (kein Name) | das PDF jeder Lösungsfassung ändert sich an allen 119 Stellen; die Fassungen ohne Lösungen bleiben gleich | Bericht; Eintrag in `regeln.json` als Verhaltensänderung (L25); Seitenvergleich nur für Fassungen ohne Lösungen als Abnahme | K 6 „abhängige Funktionen" (dort ausdrücklich `luecke`); Widerspruch zu K 5.5 siehe Zweifelsfall 12 und [Lücke 17] |

### 1.8 `loesungsmodus` → `has-solutions` (Z. 1176)

Alt: `#let loesungsmodus()`

Neu (= K A.5, liegt in aufgaben, arbeitsblatt reicht es namentlich durch): `#let has-solutions() = { }`

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `loesungsmodus` | `has-solutions` (aufgaben); alter Name abbrechender Stub | umbenannt, nach aufgaben verlegt | Rückgabe bool wie heute; wahr bei `solutions` ≠ `none` | ja | K 3/5 (`loesungsmodus` verboten), K 4.1 `has-<plural>`, K 9.3 |

### 1.9 `lsg` (Name unverändert; Z. 1202)

Alt: `#let lsg(body, platz: true, sonst: none)`

Neu (= K A.8): `#let lsg(reserve: true, fallback: none, body) = { }`

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `lsg` | `lsg` | unverändert (127 Aufrufe bleiben) | – | – | K 2.1a, K 3/6 (Parameterwort `inline`, kein Funktionsname `inline-solution`), K 9.3 „Unverändert bleiben" |
| `body` (vorn) | `body` (zuletzt) | unverändert im Aufruf | – | – | L15 |
| `platz: true` | `reserve: true` | umbenannt | gleich | ja | K 3/10 (`platz` verboten), K 4.3 |
| `sonst: none` | `fallback: none` | umbenannt | gleich | ja | A.8, Wortliste N |

### 1.10 `teilaufgaben` (Name unverändert), Alias `tasks` entfällt (Z. 1228, 1263)

Alt:

```typ
#let teilaufgaben(tasks: (), columns: auto, numbering: "a)", gutter: 1.25em, loesungen: (), ..args)
#let tasks = teilaufgaben
```

Neu (= K A.3 bis auf die Vorgabe von `align`; liegt künftig in aufgaben, arbeitsblatt reicht es namentlich durch):

```typ
#let teilaufgaben(
  items: (),                    // array aus content
  item-solutions: (),           // array aus content, in der Reihenfolge der items
  columns: auto,                // W9
  numbering: "a)",              // W9
  gutter: 1.25em,
  align: auto,                  // W9; A.3 schreibt left, siehe Tabelle
  inset: 0pt,                   // W9
  ..deprecated,
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `teilaufgaben` | `teilaufgaben` | Name unverändert; nach aufgaben verlegt (arbeitsblatt reicht ihn durch) | – | – (56 Aufrufe bleiben) | K 2.1a, K 3/4, K 9.3 „Unverändert bleiben", Anhang B (Doppelimplementierung mit mathematik entfällt) |
| `tasks` (Alias) | – ; abbrechender Stub „`tasks` heißt jetzt `teilaufgaben`" | entfernt (zweiter Name eines Bausteins) | – | ja (`tasks(` → `teilaufgaben(`) | K 3/4 (`tasks` als Funktion verboten), K 9.3 (kein Baustein hat einen zweiten Namen) |
| `tasks: ()` | `items: ()` | umbenannt | gleich (56 Aufrufe) | ja | K 3/78 |
| `columns: auto` | `columns: auto` | unverändert | – | – | K 3/36, W9 |
| `numbering: "a)"` | `numbering: "a)"` | unverändert | – | – | K 3/39 |
| `gutter: 1.25em` | `gutter: 1.25em` | unverändert | – | – | K 3/33, K 5.5 |
| `loesungen: ()` | `item-solutions: ()` | umbenannt | gleich (35 Aufrufe) | ja | K 4.5 (kein Parameter heißt wie eine Funktion), K 5.1 (`solutions` nur Auswahl), Anhang C |
| `..args` positional (Enum-Inhalt `[+ a + b]`) | – | entfernt (zweiter Weg) | `teilaufgaben[+ a + b]` → `teilaufgaben(items: ([a], [b]))` | AST (nur bei wörtlicher Aufzählung), sonst nein | K 4.4 Nr. 4 („ein Weg je Angabe"), A.3 |
| `..args` benannt `align:` (4) | `align: auto` | deklariert | gleich. Heute setzt `teilaufgaben` kein `align`; es gilt die `table`-Vorgabe `auto`, die die umgebende Ausrichtung erbt (`ab.typ` Z. 1251–1259). A.3 schreibt `align: left`; das wäre eine neue Vorgabe (anderes PDF innerhalb von `align(center)[…]`). Entschieden: `auto` (K 5.5), Abweichung von A.3 gemeldet ([Lücke 18]) | – | K 4.4 Nr. 5, W9, K 5.5 |
| `..args` benannt `inset:` (12) | `inset: 0pt` | deklariert | gleich | – | K 3/35, W9 |
| `..args` benannt `row-gutter:` (2) und übrige `table`-Argumente | – | entfernt | Fehler mit Abhilfe (`gutter` gilt für Spalten und Zeilen) | nein | K 4.4 Nr. 5, L16 |
| – | `..deprecated` | neu | – | – | K 4.4 Nr. 5 c |

### 1.11 `c_canvas`, `canvas` (Z. 1265–1266)

Alt:

```typ
#let c_canvas = canvas
#let canvas(..args, body)
```

Neu:

```typ
#let canvas(length: 1cm, padding: none, ..deprecated, body) = { }   // internal.cetz-canvas hält das Original
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `c_canvas` | `internal.cetz-canvas`; alter Name abbrechender Stub „`c_canvas` gibt es nicht mehr – `cetz.canvas` nach `#import "@preview/cetz:0.4.2"`" | umbenannt, intern | – | nein (Nutzung im Bestand nicht bekannt; Bericht) | K 2.4, K 7.2, L1; Stub in `src/removed.typ` wie `lücke` (einheitliche Regel, Zweifelsfall 9) |
| `canvas` | `canvas` | unverändert (eigener Wrapper mit Achsenstil unter dem Fremdnamen) | – | – | K 7.1 `fremdnamen.txt`, L12; gleiches PDF (K 5.5) |
| `..args` benannt `length:` | `length: 1cm` | deklariert (Vorgabe wie cetz) | gleich (667 Aufrufe `canvas(length: …)`, Prüferzählung; Umbenennen scheidet deshalb aus) | – | K 4.4 Nr. 5, [Lücke 4]. Der Parameter überdeckt im Rumpf den Typst-Typ `length` (`type(1cm) == length` ist dort falsch): im Rumpf nur `std.length` schreiben, siehe [Lücke 19] |
| `..args` benannt `padding:` | `padding: none` | deklariert | gleich | – | K 4.4 Nr. 5, [Lücke 4] |
| `..args` übrige (`baseline`, `debug`, `background`, `stroke`) | – | entfernt | Fehler mit Abhilfe „`cetz.canvas` selbst importieren" | nein (Bericht) **[prüfen]** Häufigkeit | K 4.4 Nr. 5, L16 |
| `body` | `body` | unverändert | – | – | K 3/79 |

### 1.12 `print-pagebreak`, `non-print-pagebreak` → `conditional-pagebreak` (Z. 1304, 1327)

Alt:

```typ
#let print-pagebreak(loesungen-only: false)
#let non-print-pagebreak(loesungen-only: false)
```

Neu (= K A.9, wörtlich übernommen; die Signatur verstößt gegen K 5.1 und L11, siehe [Lücke 20]):

```typ
#let conditional-pagebreak(
  print: auto,                  // W5 bool: true = nur Druck, false = nur digital
  solutions-visible: auto,      // W5 bool: true = nur wenn Lösungen sichtbar sind
  weak: false,                  // W9
  to: none,                     // W9
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `print-pagebreak` | `conditional-pagebreak(print: true)`; alter Name abbrechender Stub | zusammengelegt | `print-pagebreak()` → `conditional-pagebreak(print: true)` | ja (21 Aufrufe) | K 4.1, A.9, K 9.3 |
| `non-print-pagebreak` | `conditional-pagebreak(print: false)`; alter Name abbrechender Stub | zusammengelegt | `non-print-pagebreak()` → `conditional-pagebreak(print: false)` | ja (106 Aufrufe) | K 4.3 (Präfix `non-` verboten), L4, A.9 |
| `loesungen-only: false` | `solutions-visible: auto` | umbenannt, Typ geändert (bool → bool \| auto), Default geändert, **Bedeutung geändert** | `false` → Argument löschen (automatisch). `true` → **keine automatische Abbildung**: heute wirkt der Umbruch nur bei `loesungen == "nur"` (Z. 1308, 1331), `solutions-visible: true` wirkt bei jeder sichtbaren Lösung; für die alte Bedeutung gibt es im neuen API keinen Ausdruck | `false`: Kontext. `true`: **nein (Bericht)**, 5 Aufrufe im Bestand (4× `non-print-pagebreak`, 1× `print-pagebreak`, Prüferzählung); der Codemod lässt den ganzen Aufruf stehen (alter Funktionsname samt Argument), sodass beim Kompilieren der Stub mit der Standardmeldung „`print-pagebreak` heißt jetzt `conditional-pagebreak(print: true)`" (bei `non-print-pagebreak` entsprechend mit `print: false`) abbricht (K 9.3); den Hinweis „`loesungen-only: true` galt nur für `solutions: "only"` – `solutions-visible: true` gilt für jede sichtbare Lösung" gibt der Codemod-Bericht, nicht das Paket, denn `conditional-pagebreak` hat nach A.9 kein `..deprecated` (siehe [Lücke 28]) | K 4.3 (Suffix `-only`), L4, Anhang C; siehe Zweifelsfall 6 |
| – | `print: auto` | neu (ersetzt die zwei Funktionsnamen) | – | – | K 3/55 |
| – | `weak: false` | neu (Durchreichung an `pagebreak`) | – | – | W9, [Lücke 4] (`weak` fehlt in der Wortliste) |
| – | `to: none` | neu (Durchreichung) | – | – | W9 |

### 1.13 `minipage` (Z. 1361)

Alt: `#let minipage(columns: auto, align: horizon, spacing: 5mm, ..args)`

Neu (= K A.8):

```typ
#let minipage(
  columns: auto,                // W9 auto | int | array
  align: horizon,               // W9
  gutter: 5mm,
  inset: 0pt,                   // W9
  ..cells,                      // nur positional
) = { }
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `minipage` | `minipage` | unverändert (1575 Aufrufe) | – | – | Gruppe B |
| `columns: auto` | `columns: auto` | unverändert | – | – | K 3/36 |
| `align: horizon` | `align: horizon` | unverändert | – | – | W9, K 4.5 (`std.align` im Rumpf) |
| `spacing: 5mm` | `gutter: 5mm` | umbenannt; **Wirkung bei mehrzeiligen Aufrufen geändert** | Wert gleich (Vorgabe bleibt 5mm). Heute geht `spacing` nur an `column-gutter` (`ab.typ` Z. 1379), der Zeilenabstand ist 0. `gutter` gilt wie in Typst und wie bei `teilaufgaben` für Spalten **und** Zeilen (K 3/33, Leitregel 3). Einzeilige Aufrufe (Zellenzahl ≤ Spaltenzahl, der Normalfall mit `columns: auto`) bleiben gleich; mehrzeilige (`columns:` mit weniger Spalten als Zellen) bekommen 5mm Zeilenabstand, auch ohne `spacing:`-Argument | ja für den Namen; **Bericht** für jeden Aufruf mit ausdrücklichem `columns:` und mehr Zellen als Spalten (bei nicht wörtlichem `columns` immer Bericht); Eintrag als Verhaltensänderung in `regeln.json` (L25); diese Aufrufe gehören in den Seitenvergleich | K 3/33 (`spacing` bei minipage verboten), K 5.5, Zweifelsfall 13 |
| `..args` positional | `..cells` | umbenannt (Sink-Name, unsichtbar) | – | – | K 4.4 Nr. 5 a, L16 |
| `..args` benannt `inset:` | `inset: 0pt` | deklariert | gleich | – | K 3/35 |
| `..args` übrige `table`-Argumente (`stroke`, `row-gutter`, …) | – | entfernt | Fehler mit Abhilfe (`grid`/`table` direkt benutzen) | nein (Bericht; Häufigkeit nicht gezählt) **[prüfen]** | K 4.4 Nr. 5, L16 |

### 1.14 `icon-link` (Z. 1399)

Alt: `#let icon-link(url, name, icon: emoji.chain, color: blue)`

Neu (= K A.10): `#let icon-link(url, icon: auto, fill: blue, body) = { }`

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `icon-link` | `icon-link` | unverändert (204 Aufrufe) | – | – | K 4.1 |
| `url` (positional) | `url` | unverändert | – | – | K 4.4 Nr. 2 |
| `name` (positional) | `body` (positional, zuletzt) | umbenannt (im Aufruf unsichtbar) | `icon-link("u", "Text")` und `icon-link("u")[Text]` bleiben gültig | – | K 3/13 (`name` als Linktext verboten), K 3/79 |
| `icon: emoji.chain` | `icon: auto` | Default geändert (Schreibweise; `auto` = `emoji.chain`, PDF gleich) | gleich | – | K 3/77, W5, L25-Eintrag |
| `color: blue` | `fill: blue` | umbenannt | gleich | ja | K 3/27 (`color` verboten), L4 |

### 1.15 `qrbox` → `qr-box` (Z. 1419)

Alt: `#let qrbox(url, name, width: 3cm, ..args)`

Neu (= K A.10): `#let qr-box(url, width: 3cm, rotation: auto, body) = { }`

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `qrbox` | `qr-box`; alter Name abbrechender Stub | umbenannt | – | ja (125 Aufrufe) | K 4.1 `qr-box`, K 2.4, K 9.3 |
| `url` | `url` | unverändert | – | – | K 4.4 Nr. 2 |
| `name` (positional) | `body` (positional, zuletzt) | umbenannt (unsichtbar) | – | – | K 3/13, K 3/79 |
| `width: 3cm` | `width: 3cm` | unverändert | – | – | K 3/31 |
| `..args` benannt `rotation:` (83) | `rotation: auto` | deklariert; `auto` = Vorgabe von `stickybox` | gleich | – | K 3/75, K 4.4 Nr. 5 (nennt `rotation`) |
| `..args` übrige `stickybox`-Argumente | – | entfernt | Fehler mit Abhilfe (`stickybox` direkt; ist Fremdname) | nein | K 4.4 Nr. 5, L16 |

### 1.16 `mono` (Z. 1475)

Alt: `#let mono(body) = text(font: "SF Mono", body)`

Neu: entfällt in arbeitsblatt. **Kein Stub**: ein abbrechender Stub `mono` würde nach `import …: *` Typsts `math.mono` überdecken (`$ mono(x) $` bräche mit der Stub-Meldung ab, in der Prüfung getestet) und mit dem lebenden `informatik.mono` kollidieren.

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `mono` (136 Aufrufe: `#mono(` 73, `#mono[` 63, Prüferzählung) | – (nur `regeln.json` unter `removed`, wie `print-state`) | entfernt, ohne Stub | `mono(X)` → `text(font: "SF Mono", X)`; `mono[X]` → `text(font: "SF Mono")[X]` (wörtlich die heutige Definition, Z. 1475, PDF gleich). Nur im Code- und Markup-Modus ersetzen, nie in Formeln (`$ mono(x) $` ist `math.mono`); nicht ersetzen, wenn das Dokument `mono` selbst definiert oder `@schule/informatik` direkt importiert | ja (Kontext: Modus und Importe) | Doppelung zu `informatik.mono` (Inventar 8; `informatik/0.0.2/lib.typ` Z. 314), feste macOS-Schrift, Segment `mono` nicht in der Wortliste (L2), [Lücke 3] |
| `body` | – | entfernt | – | – | – |

### 1.17 `workspace` (Z. 1492)

Alt: `#let workspace(height: 5cm, body)`

Neu (= K A.8): `#let workspace(body) = { }`

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `workspace` | `workspace` | unverändert (118 Aufrufe) | – | – | K 3/10 |
| `height: 5cm` | – | entfernt (toter Parameter) | Argument löschen (keine Wirkung, PDF gleich) | ja | Inventar 8 (Z. 1492), A.8 |
| `body` | `body` | unverändert | – | – | K 3/79 |

### 1.18 Kästen (Z. 1539–1553)

Alt (15 Zeilen dieser Form):

```typ
#let abstract(..args) = _kasten("abstract", ..args)
// ebenso: info, question, memo, conclusion, tip, success, warning, error,
//         example, goal, idea, experiment, notify, danger
```

Neu (= K A.11; alle 15 mit genau dieser Signatur):

```typ
#let info(
  title: auto,                  // W5 content; none = ohne Titelzeile
  accent: auto,                 // W5 color
  breakable: false,             // W9
  width: auto,                  // W9
  ..deprecated,
  body,
) = { }
// ebenso: abstract, question, memo, conclusion, tip, success, warning, error,
//         example, goal, idea, experiment, notify, danger
```

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `abstract`, `info`, `question`, `memo`, `conclusion`, `tip`, `success`, `warning`, `error`, `example`, `goal`, `idea`, `experiment`, `notify`, `danger` (Namen) | gleich | unverändert | – | – | K 7.1, L12 `kollisionen-erlaubt.txt`; Wortliste siehe [Lücke 4] |
| `..args` 1. Positionsargument | `body` | deklariert; **mit Theme heute optional** (`args.pos().at(0, default: [])`, Z. 1535), ohne Theme Pflicht (gentle-clues); künftig immer Pflicht | `info()` ohne Inhalt ist künftig immer ein Fehler (Typst-Meldung „missing argument: body") | nein (im Bestand nicht gezählt; ein leerer Kasten ist ein Sonderfall) | K 3/79, L15 |
| `..args` benannt `title:` (Vorgabe: deutscher Titel je Kasten) | `title: auto` | deklariert, Default geändert (Schreibweise; `auto` = deutscher Standardtitel) | gleich (156 Aufrufe bei `info`) | – | K 3/13, W5 |
| `..args` benannt `headless: true` | `title: none` | zusammengelegt | `headless: true` → `title: none`; `headless: false` → Argument löschen; `headless: true` zusammen mit `title:` → `title: none` | Kontext | K 4.3 (einmalige Wendung), Anhang C |
| `..args` benannt `accent-color:` (17) | `accent: auto` | umbenannt | gleich | ja | K 3/26, L4 (`-color`) |
| `..args` benannt `breakable:` | `breakable: false` | deklariert | gleich | – | Gruppe T, W9 |
| `..args` benannt `width:` | `width: auto` | deklariert | gleich | – | K 3/31 |
| `..args` benannt `icon:` (17 Aufrufe bei `info`) | – | entfernt | Fehler „gibt es nicht mehr – das Symbol bestimmt das Theme" | nein | A.11 („genau diese Signatur"), siehe Zweifelsfall 5 |
| `..args` übrige gentle-clues-Argumente (`header-color`, `border-color`, `body-color`, `stroke-width`, …) | – | entfernt (wurden mit Theme schon heute still verworfen) | Fehler „unbekannter Parameter" | nein | K 4.4 Nr. 5 und 6, Inventar 4.17 |
| – | `..deprecated` | neu | fängt `headless`, `accent-color`, `icon` ab | – | K 4.4 Nr. 5 c |
| `task` (gentle-clues, über `aufgaben` durchgereicht, ohne Wrapper) | – | entfernt aus dem Namensraum (wie `code`) | Es gibt keine eigene Funktion `task` (die Aufgabe heißt `aufgabe`), also keine Kollision und keine still geänderte Bedeutung: Ein übersehenes `#task[…]` endet in Typsts „unknown variable: task". Abhilfe namentlich: `#import "@preview/gentle-clues:1.2.0": task` (PDF gleich) | ja (der Codemod fügt die namentliche Importzeile ein, wenn `task(` oder `task[` vorkommt und das Dokument `task` nicht selbst definiert; 1 Dokument im Bestand, Prüferzählung; Bericht) | K 7.1 (`task` steht nicht in `fremdnamen.txt`; „gewöhnlicher Typst-Fehler"; K 7.1 begründet das mit „kein Bestand", die Prüferzählung findet 1 Dokument, siehe [Lücke 27]), K 11 Nr. 2, L12 (`task` steht nicht mehr in `kollisionen-erlaubt.txt`) |
| `code` (gentle-clues, über `aufgaben` durchgereicht, ohne Wrapper; 12 Aufrufe `#code(`, Prüferzählung) | – | entfernt aus dem Namensraum | Abhilfe **nur namentlich**: `#import "@preview/gentle-clues:1.2.0": code`. Nie `gentle-clues…: *`: das exportiert alle 15 Kastennamen und überdeckt nach dem `@schule`-Import still die gethemten Kästen (in der Prüfung getestet: kompiliert fehlerfrei, setzt aber den Clue-Kasten). Die Prüfung nennt in ihrer Meldung genau diese Importzeile | ja (Codemod fügt die namentliche Importzeile ein, wenn `code(` vorkommt); der Bericht warnt bei jedem `gentle-clues…: *` oder `zero…: *` nach dem `@schule`-Import | K 7.1, K 11 Nr. 2 |

Deutsche Standardtitel (`_kasten-titel`, Z. 1507–1513) sind Ausgabe und bleiben: „Einführung", „Info", „Frage", „Merke", „Zusammenfassung", „Tipp", „Erledigt", „Achtung", „Fehler", „Beispiel", „Ziel", „Idee", „Experiment", „Mitteilung", „Gefahr". Die Einträge `task` („Aufgabe") und `code` („Code") entfallen.

### 1.19 `themes` (re-exportiert, Z. 45)

Siehe 2.5. Name und Schlüssel bleiben.

### 1.20 Interne Helfer des Kerns (alle nach `src/internal.typ`, Modul `internal`)

| alt | neu | Art | Begründung |
|---|---|---|---|
| `_klartext(value)` (Z. 50; zweite Fassung themes.typ Z. 58) | `internal.plain-text(value)` | umbenannt, zusammengelegt (eine Fassung) | K 7.2, L19 |
| `_unify-einheit(s)` (Z. 61) | `internal.normalize-unit(value)` | umbenannt | K 7.2, K 2.4 |
| `_to-unify-str(value)` (Z. 65) | `internal.to-unit-text(value)` | umbenannt | K 7.2, L4 (`-str`) |
| `_named-with-default-per(named)` (Z. 82) | – | entfernt (`per` ist deklariert) | K 4.4 Nr. 5 |
| `_papier-masse` (Z. 191) | `internal.paper-sizes` | umbenannt | K 7.2 |
| `_papier-groesser` (Z. 199) | `internal.next-paper` | umbenannt | K 7.2 |
| `_umbrueche-zaehlen(c)` (Z. 209) | `internal.count-pagebreaks(body)` | umbenannt | K 7.2 |
| `_margin-aufloesen(m)` (Z. 232) | `internal.resolve-margin(margin)` | umbenannt | K 7.2 |
| `_varianten-vorlagen` (Z. 900) | `internal.variant-presets` | umbenannt; Schlüssel und Inhalte siehe 3.3 | K 7.2, K 5.3 |
| `_varianten-aufloesen(varianten)` (Z. 909) | `internal.resolve-variants(variants, variant-overrides)` | umbenannt | K 7.2 |
| `_vorschau-alle-aktiv()` (Z. 928) | `internal.preview-all-requested()` | umbenannt; liest weiter `--input vorschau=alle` | K 7.2, K 2.1 (eingefroren) |
| `_kasten-titel` (Z. 1507) | `internal.callout-titles` | umbenannt | K 3/76 |
| `_kasten-original` (Z. 1514) | `internal.callout-classic` | umbenannt | K 3/76 |
| `_kasten(art, ..args)` (Z. 1521) | `internal.callout(kind, title: auto, accent: auto, breakable: false, width: auto, body)` | umbenannt, Sink entfällt | K 3/76, K 3/25, K 4.4 Nr. 5 |
| `_pruefe(name, wert, erlaubt)` (Z. 308, lokal) | `internal.check` / `internal.fail` | ersetzt | K 8.1, K 8.4 |
| `_gc` (Modul gentle-clues, Z. 44) | nur in `internal.typ` importiert, nicht exportiert | entfernt aus dem Namensraum | L19 |
| `qr-code-zebra` (Importalias, Z. 39) | nur in `internal.typ` | entfernt aus dem Namensraum | L19 |
| `add-unit`, `unify-num`, `unify-qty`, `unify-unit` (Z. 46) | nur in `internal.typ` | entfernt aus dem Namensraum | L19 |
| `_theme-aufloesen` (aus themes.typ) | `internal.resolve-theme` | siehe 2.6 | K 7.2 |

---

## 2. `src/themes.typ`

### 2.1 Öffentliche Namen

| alt (Signatur wörtlich) | neu (Signatur wörtlich) | Art | Wertabbildung / Rückgabe | Codemod | Begründung |
|---|---|---|---|---|---|
| `#let fachfarben = (MA: …, PH: …, IF: …, CH: …, BI: …, NW: …, DE: …, EN: …, KLS: …)` (Z. 35) | `#let subject-accents = (MA: …, PH: …, IF: …, CH: …, BI: …, NW: …, DE: …, EN: …, KLS: …)` | umbenannt; künftig exportiert | Schlüssel (Fachkürzel) und Farben unverändert (Daten, K 2.1) | – (heute nicht erreichbar) | A.12, K 3/16, K 3/26, Anhang C (`subject-accents`) |
| `#let fachnamen = (MA: "Mathematik", …)` (Z. 46) | `#let subject-names = (MA: "Mathematik", …)` | umbenannt; künftig exportiert | unverändert (Ausgabe deutsch) | – | A.12, K 3/16 |
| `#let kuerzel(class)` (Z. 67) | `internal.parse-class(class)` | umbenannt, intern | Rückgabe `(fach:, name:, jahrgang:)` → `(subject:, name:, year:)` | – | A.12 („Zerlegung des Klassen-Strings liegt in `internal`"), Anhang C (`parse-class`), K 3/16 |
| `#let kicker(class)` (Z. 77) | `internal.subject-line(class)` | umbenannt, intern | Rückgabe unverändert (`none` oder „Mathematik · Klasse 5") | – | A.12 (abschließende Liste der öffentlichen Namen), siehe Zweifelsfall 10 |
| `#let fachfarbe(class)` (Z. 85) | `internal.class-accent(class)` | umbenannt, intern | Rückgabe Farbe; unbekanntes Fach weiter `subject-accents.MA` | – | A.12, K 3/26; nicht `subject-accent`, weil sich der Name vom öffentlichen Dictionary `subject-accents` nur durch ein Plural-s unterschiede |
| `#let kasten-stil(art, akzent, farbe: auto)` (Z. 116) | `#let callout-style(kind, worksheet-accent: auto, accent: auto) = { }` | umbenannt; künftig exportiert | siehe Tabelle unten | – (heute nicht erreichbar) | A.12, K 3/76 |
| `#let themes = (klar: klar, atlas: atlas, skizze: skizze, labor: labor, kontur: kontur, leiste: leiste, riso: riso, bauhaus: bauhaus)` (Z. 1138) | gleich | unverändert | Schlüssel sind Eigennamen (K 2.1) | – | A.12, `names.txt` |

`callout-style`:

| alt | neu | Art | Wertabbildung | Begründung |
|---|---|---|---|---|
| `art` (positional) | `kind` (führendes Hauptargument) | umbenannt | Werte: die 15 Kastennamen; `"task"`, `"code"` entfallen; unbekannter Wert ist künftig ein Fehler (heute Fallback `info`) | K 3/25, K 8.1 |
| `akzent` (positional) | `worksheet-accent: auto` (benannt) | umbenannt, positional → benannt | `auto` = `subject-accents.MA` (heutiger Fallback von `fachfarbe`) | K 4.4 Nr. 2 (höchstens ein führendes Hauptargument), L15; `worksheet` ist das Parameterwort für den Baustein `arbeitsblatt` (K 2.1b, K 3/1), `sheet` steht nur für den Klausurbogen (K 3/12); siehe [Lücke 5] |
| `farbe: auto` | `accent: auto` | umbenannt | gleich (`auto` = Farbe der Kastenart, sonst Blattakzent) | K 3/26 |
| Rückgabe `icon` (str, FontAwesome-Name) | `icon-name` (str) | umbenannt | gleich | K 3/77 (`icon` ist content), K 5.1 (gleicher Name, gleicher Grundtyp), K 5.4 |
| Rückgabe `farbe` (color) | `accent` (color) | umbenannt | gleich | K 3/26 |

### 2.2 Theme-Funktionen

Alt (alle acht wörtlich): `#let klar(akzent, class) = {` (ebenso `atlas`, `skizze`, `labor`, `kontur`, `leiste`, `riso`, `bauhaus`; Z. 183, 294, 410, 547, 657, 780, 896, 1020)

Neu: `#let klar(accent: auto, class: none) = { }` (ebenso die sieben anderen); allgemeine Form `(accent: auto, class: none) => dictionary` (A.12)

| alt | neu | Art | Wertabbildung | Codemod | Begründung |
|---|---|---|---|---|---|
| `klar`, `atlas`, `skizze`, `labor`, `kontur`, `leiste`, `riso`, `bauhaus` (Top-Level-Namen in themes.typ, nur als `themes.<name>` erreichbar) | gleich, weiter nur über `themes.<name>` | unverändert | – | – | K 2.1 Eigennamen |
| `akzent` (positional) | `accent: auto` (benannt) | umbenannt, positional → benannt | Wert ist beim Aufruf schon aufgelöst (Farbe) | nein für eigene Theme-Funktionen in Dokumenten (`(akzent, class) => …` → `(accent: auto, class: none) => …`; Bericht) | K 3/26, A.12 |
| `class` (positional) | `class: none` (benannt) | positional → benannt | gleich | wie oben | K 3/15, A.12 |

### 2.3 Theme-Dictionary: Schlüssel

Neu (= K A.12):

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

Die Werte im Block oben sind Platzhalter der Konvention. Die heutigen Vorgaben (sie gelten, wenn ein Theme den Schlüssel nicht setzt) stehen in der Spalte „Vorgabe heute". Codemod „AST" gilt für wörtlich geschriebene Theme-Dictionaries in Dokumenten; der Rumpf eigener Hooks und eigener Theme-Funktionen ist immer Handarbeit (Bericht), so auch `tabelle-aufgaben.md` 2.6. Die Schlüssel und Hooks bleiben englisch, auch wo sie einen Baustein zeichnen: Ein Hook trägt das Parameterwort seines Bausteins (`task` für `aufgabe`, `subtask` für `teilaufgabe`, `solution` für `loesung`; K 2.1b, K 4.4 Nr. 7, L18, A.12). Deutsche Hook-Namen gibt es in der Zielversion nicht; sie schlagen in L27 an.

| alt (Schlüssel) | neu (Schlüssel) | Art | Wertabbildung | Vorgabe heute (Fundstelle) | Codemod | Begründung |
|---|---|---|---|---|---|---|
| `name` | `name` | unverändert (heute tot; künftig für Fehlermeldungen benutzt) | Eigenname des Themes | – | – | A.12 |
| `schrift` | – | entfernt (Verschachtelung aufgelöst) | Unterschlüssel werden Geschwister | `(:)` | AST | K 5.4 („kein verschachteltes `fonts`") |
| `schrift.text` | `font` | umbenannt | gleich | `"Myriad Pro"` (`ab.typ` Z. 332) | AST | K 3/48, K 5.4 |
| `schrift.mathe` | `math-font` | umbenannt | gleich | `"Fira Math"` (Z. 333) | AST | K 3/48 |
| `schrift.groesse` | `font-size` | umbenannt | gleich | 12pt (Z. 334) | AST | K 3/49 |
| `schrift.titel` | `title-font-size` | umbenannt | gleich | 16pt (Z. 335); Themes: klar 20, atlas 21, skizze 21, labor 18, kontur 26, leiste 22, riso 27, bauhaus 25 | AST | K 3/49 |
| `rand` | `margin` | umbenannt | Dictionary mit Typsts Schlüsseln | `(:)` (Z. 487) | AST | K 3/52, K 5.4 |
| `rand.top` | `margin.top` | unverändert (Unterschlüssel) | gleich; von keinem Theme gesetzt | 2.3cm bei `print`, sonst 2.2cm (Z. 488); mit Theme-Kopf berechnet (Z. 503) | AST | K 5.4 |
| `rand.bottom` | `margin.bottom` | unverändert (Unterschlüssel) | gleich | 1cm (Z. 505) | AST | K 5.4 |
| `rand.innen` | `margin.inside` | umbenannt | gleich | 2.25cm (Z. 492) | AST | K 5.4 (Typsts Schlüssel) |
| `rand.aussen` | `margin.outside` | umbenannt | gleich (nur `leiste` setzt es) | 1.25cm (Z. 493) | AST | K 5.4 |
| `rand.kopf-oben` | `header-top` (oberste Ebene) | umbenannt, verschoben | gleich | 1.2cm (Z. 503) | AST | A.12; kein Typst-margin-Schlüssel, darf deshalb nicht in `margin` stehen (K 5.4) |
| `header-ascent` | `header-ascent` | unverändert | – | **zwei verschiedene:** 0.8cm in der Randberechnung (Z. 503), 20% bei `set page` (Z. 548) und im Zweifach-Modus (Z. 746). Künftig eine: `page-settings` → Theme → 20% ohne Theme-Kopf, 0.8cm mit Theme-Kopf, an beiden Stellen derselbe aufgelöste Wert (5 Nr. 37) | – | A.12, Wortliste N (`ascent`) |
| `footer-descent` | `footer-descent` | unverändert (künftig dokumentiert) | – | 30% (Z. 553) | – | A.12 |
| `kopf` | `header` | umbenannt | Hook, siehe 2.4 | `none` (klassischer Kopf) | AST | K 3/54, K 4.4 Nr. 7 |
| `fuss` | `footer` | umbenannt | Hook, siehe 2.4 | `none` | AST | K 3/54 |
| `hintergrund` | `background` | umbenannt | Hook, siehe 2.4 | `none` | AST | K 3/29 |
| `marke` | `task-marker` | umbenannt | Hook, siehe 2.4 | `none` | AST | K 3/43, A.12 |
| `marke-breite` | `task-marker-width` | umbenannt | gleich (Länge in em) | 2.2em (aufgaben.typ Z. 1053) | AST | K 1.2 Schritt 3 (`-width`), K 3/31 |
| `aufgabe` | `task` | umbenannt | Hook, siehe 2.4 | `none` | AST | K 3/3, K 4.4 Nr. 7 |
| `teilaufgabe` | `subtask` | umbenannt | Hook, siehe 2.4 | `none` | AST | K 3/4 |
| `loesung` | `solution` | umbenannt | Hook, siehe 2.4 | `none` | AST | K 3/5 |
| `loesung-kopf` | `solution-heading` | umbenannt | Hook, siehe 2.4 | `none` | AST | K 4.2 (Bestimmungswort im Singular), Anhang C |
| `material-kopf` | `material-heading` | umbenannt | Hook, siehe 2.4 | `none` | AST | K 4.2, Anhang C |
| `kasten` | `callout` | umbenannt | Hook, siehe 2.4 | `none` (klassischer gentle-clues-Kasten) | AST | K 3/76 |
| `setup` | `setup` | unverändert | – | `none` | – | Gruppe B |
| (jeder andere Schlüssel) | – | Fehler „unbekannter Parameter" mit Tippfehlervorschlag (heute still ignoriert) | – | – | – | A.12, K 8.4, L18 |

Hinweis `figure-font-size`: bleibt ohne Theme-Schlüssel (A.12 führt keinen); `auto` im Kopf heißt 9pt.

### 2.4 Hook-Signaturen

| Hook alt (Signatur wörtlich) | Hook neu (Signatur wörtlich) | Parameter alt → neu | Art | Begründung |
|---|---|---|---|---|
| `kopf: (title: none, class: none, copyright: none, font-size: <pt>) => content` | `header: (title: none, class: none, copyright-url: none, font-size: auto) => { }` | `title` → `title` (unverändert); `class` → `class` (unverändert); `copyright` → `copyright-url` (umbenannt; heute in keinem Theme gezeichnet, siehe 5 Nr. 17); `font-size: 18pt…27pt` (je Theme gleich `schrift.titel`: klar 20, atlas 21, skizze 21, labor 18, kontur 26, leiste 22, riso 27, bauhaus 25) → `font-size: auto` (Default geändert: die je Theme wiederholte Titelgröße entfällt, der Aufrufer reicht immer `title-font-size` herein) | umbenannt, Default geändert | A.12 wörtlich; zur Benennung `font-size` siehe Zweifelsfall 1 |
| `fuss: (duplex: true) => content` | `footer: (duplex: true) => { }` | `duplex` → `duplex` (unverändert) | umbenannt (nur Schlüssel) | K 3/54, K 3/56 |
| `hintergrund: (print: true, oben: <cm>, rand: (:)) => content` | `background: (print: true, margin: (:), header-top: 0cm) => { }` | `print` → `print` (unverändert); `rand` → `margin` (umbenannt; Typst-margin-Dictionary); `oben` → `header-top` (umbenannt; trägt weiter den oberen Seitenrand, siehe Zweifelsfall 2) | umbenannt | A.12 wörtlich, K 3/52 |
| `marke: n => content` (im Quelltext `n`, themes.typ Z. 208; nur im Kopfkommentar Z. 15 `(nummer)`) | `task-marker: task-number => { }` | `n` → `task-number` (positional, int) | umbenannt | K 3/41, K 4.4 Nr. 7 (ein Argument positional) |
| `marke-breite: length` | `task-marker-width: length` | – | umbenannt | siehe 2.3 |
| `aufgabe: (nummer: 1, titel: none, icons: (), punkte: none, large: true, number: true) => content` | `task: (marker: none, title: none, icons: (), points: none, large: true) => { }` | `nummer` (int) und `number` (bool) → `marker` (content \| none; `none` = keine Nummer) (zusammengelegt, Typ geändert); `titel` → `title`; `icons` → `icons` (unverändert); `punkte` → `points` (fertig formatierter Inhalt oder `none`); `large` → `large` (unverändert) | umbenannt, zusammengelegt | A.12, Anhang C („Hook `task` bekommt `marker`"), K 3/43; Folge für `bauhaus`/`labor` siehe Zweifelsfall 3 |
| `teilaufgabe: lbl => content` (im Quelltext `lbl`, Z. 225; nur im Kopfkommentar Z. 18 `(label)`) | `subtask: marker => { }` | `lbl` → `marker` (positional) | umbenannt | K 3/43 (`label` nie für Sichtbares, K 3/44) |
| `loesung: (titel, body) => content` | `solution: (title: none, body) => { }` | `titel` (positional) → `title: none` (benannt); `body` → `body` | umbenannt, positional → benannt | A.12, K 4.4 Nr. 7 (benannt, `body` zuletzt) |
| `loesung-kopf: titel => content` | `solution-heading: title => { }` | `titel` → `title` (positional) | umbenannt | K 3/13 |
| `material-kopf: titel => content` | `material-heading: title => { }` | `titel` → `title` (positional) | umbenannt | K 3/13 |
| `kasten: (art: "info", titel: none, farbe: auto, breakable: false, width: auto, body) => content` | `callout: (kind: "info", title: none, accent: auto, breakable: false, width: auto, body) => { }` | `art` → `kind`; `titel` → `title`; `farbe` → `accent`; `breakable`, `width`, `body` unverändert | umbenannt | A.11, A.12, K 3/25, K 3/26 |
| `setup: body => content` | `setup: body => { }` | `body` unverändert | unverändert | A.12 |

Werte von `callout(kind:)` (heute `art`): `"abstract"`, `"info"`, `"question"`, `"memo"`, `"conclusion"`, `"tip"`, `"success"`, `"warning"`, `"error"`, `"example"`, `"goal"`, `"idea"`, `"experiment"`, `"notify"`, `"danger"` – alle unverändert (Wert = Funktionsname, K 5.3). `"task"` und `"code"` entfallen (toter Eintrag, Z. 104–105).

### 2.5 `themes` und der Wert von `theme`

| alt | neu | Art | Begründung |
|---|---|---|---|
| `themes` (Dictionary) | `themes` | unverändert | A.12 |
| Schlüssel `klar`, `atlas`, `skizze`, `labor`, `kontur`, `leiste`, `riso`, `bauhaus` | gleich | unverändert | K 2.1 Eigennamen als Werte |
| Wert `theme: none` | `theme: auto` | Wert umbenannt | Anhang C |
| Wert `theme: "standard"` | – (→ `auto`) | entfernt | K 3/61 |
| Wert `theme: <dictionary>`: `akzent` wird still ignoriert | bleibt so, wird dokumentiert | unverändert | Inventar Themes 8 Nr. 7 |

### 2.6 Private Namen in `themes.typ` (alle nach `internal`)

| alt (Signatur wörtlich) | neu | Art | Begründung |
|---|---|---|---|
| `_theme-aufloesen(theme, akzent, class)` (Z. 1151) | `internal.resolve-theme(theme, accent: auto, class: none)` | umbenannt; Rückgabe weiter `none` (klassisch) oder Theme-Dictionary; prüft künftig die Schlüssel | K 7.2, K 8.4; klassenarbeit Z. 86 greift künftig über `arbeitsblatt.internal` zu |
| `_klartext(x)` (Z. 58) | `internal.plain-text(value)` | zusammengelegt mit der Fassung aus `ab.typ` | K 7.2 |
| `_gruen`, `_gelb`, `_orange`, `_rot`, `_violett`, `_tuerkis` (Z. 91–96) | `internal.palette` = `(green:, yellow:, orange:, red:, violet:, teal:)` | umbenannt, zusammengelegt | K 7.2, K 2.3 |
| `_kasten-stil` (Dictionary, Z. 97) | `internal.callout-style-table` | umbenannt; Einträge `task`, `code` entfallen; nicht `callout-styles`, weil sich der Name von der öffentlichen Funktion `callout-style` nur durch ein Plural-s unterschiede | K 3/76 |
| `_aussen(duplex, inhalt)` (Z. 122) | `internal.outside-aligned(duplex: true, format)` mit `format: page-number => content` | umbenannt: `inhalt` → `format`. `inhalt` ist eine Rückruffunktion, kein Inhalt: der Rumpf ruft `inhalt(n)` mit der Seitenzahl auf (Z. 124; Aufrufer Z. 207: `n => kachel(str(n), …)`); `body` wäre falsch | K 7.2; `format` wie in `points-format` (W7: Funktion) |
| `_seitenrand(m, n)` (Z. 128) | `internal.side-margins(margin, page-number)` | umbenannt | K 2.2 (keine Einbuchstaben-Namen) |
| `_marke(inhalt, fill: black, size: 1em, radius: 1.5pt, font: auto, weight: 700, breite: auto, inset: (x: 0.5em, y: 0.4em), stroke: none, farbe: white)` (Z. 143) | `internal.badge(fill: black, size: 1em, radius: 1.5pt, font: auto, weight: 700, width: auto, inset: (x: 0.5em, y: 0.4em), stroke: none, text-fill: white, body)` | umbenannt: `inhalt` → `body`, `breite` → `width`, `farbe` → `text-fill` | K 3/31, K 3/27, K 3/79 |
| `_schatten-box(inhalt, versatz: 2.5pt, farbe: black)` (Z. 154) | `internal.shadow-box(distance: 2.5pt, fill: black, body)` | umbenannt | K 3/27; `offset` wäre nach K 3/74 ein Dictionary |
| `_schatten-block(inhalt, versatz: 4pt, farbe: black)` (Z. 163) | `internal.shadow-block(distance: 4pt, fill: black, body)` | umbenannt | wie oben |
| `_loesung-inline(titel, body, label-stil: it => it)` (Z. 173) | `internal.solution-inline(title: none, marker-style: it => it, body)` | umbenannt | K 3/13, K 3/43 |

Lokale Helfer in den Theme-Funktionen (nicht exportiert; sie folgen K 2.4 ohne Glossarpflicht):

| Theme | alt | neu |
|---|---|---|
| klar, atlas, kontur | `kachel(inhalt, size: 1em)` | `tile(size: 1em, body)` |
| atlas | `reiter(titel, farbe, icon, rand: none)` | `tab(title: none, fill: black, icon-name: none, stroke: none)` (`rand` war eine Strichstärke; `icon` bekommt den FontAwesome-Namen als String, `st.icon`, Z. 379, deshalb `icon-name` wie in der Rückgabe von `callout-style`) |
| skizze | `klebeband(breite, hoehe, fill)` | `tape(width: auto, height: auto, fill: none)` |
| skizze | `klecks(inhalt, size: 1em)` | `blot(size: 1em, body)` |
| labor | `tag(inhalt, fill: akzent, size: 0.8em)` | `tag(fill: accent, size: 0.8em, body)` |
| kontur | `versal(x)` | `uppercase(body)` |
| leiste | `rund(inhalt, size: 1em)` | `round-badge(size: 1em, body)` |
| riso | `raster(f, d: 2.2mm, r: 0.42mm)` | `halftone(fill, spacing: 2.2mm, radius: 0.42mm)` |
| riso | `doppelt(baue, dx: 1.6pt, dy: 1.3pt)` | `doubled(offset: (dx: 1.6pt, dy: 1.3pt), draw)` mit `draw: fill => content` (`baue` ist eine Rückruffunktion, die zweimal mit je einer Farbe aufgerufen wird, Z. 902–905; kein `body`) |
| riso | `kreis(inhalt, size: 1em)` | `rounded-badge(size: 1em, body)` (zeichnet ein abgerundetes Quadrat) |
| bauhaus | `form(n, inhalt, size: 1em)` | `shape(task-number, size: 1em, body)` |
| bauhaus | `viertel(f, r: 0.9cm)` | `quarter(fill, radius: 0.9cm)` |
| Konstanten | `tinte`/`schwarz`, `hand`/`mono`/`disp`, `nacht`, `rahmen`, `band-b`, `notizgelb`, `pink`, `grau` | `ink`, `display-font`, `night`, `frame-stroke`, `band-width`, `note-yellow`, `pink`, `frame-gray` (nicht `gray`: das überdeckte in der ganzen Theme-Datei die Typst-Farbe `gray`) |

---

## 3. Schlüssel, Werte, States, Labels (Querschnitt)

### 3.1 Options-State (von `arbeitsblatt-einzeln` an aufgaben übergeben)

| alt (Schlüssel in `state("options")`) | neu (Schlüssel in `"schule/aufgaben/options@1"`) | Art | Begründung |
|---|---|---|---|
| `"loesungen"` | `solutions`, `solutions-pagebreak` | umbenannt, aufgeteilt | K 6, K 5.4 |
| `"materialien"` | `materials`, `materials-pagebreak` | umbenannt, aufgeteilt | K 6 |
| `"workspaces"` | `workspaces` | unverändert | K 6 |
| `"punkte"` (String oder Dictionary) | `points`, `points-total`, `points-position` | umbenannt, aufgeteilt | K 6 |
| `"punkte-position"` | `points-position` | zusammengelegt | K 6 |
| `"punkte-template-aufgabe"`, `"punkte-template-teilaufgabe"` | `points-format` (`f` oder `(task: f, subtask: g)`) | zusammengelegt | W7 |
| `"print"` (Fremdschlüssel, `ab.typ` Z. 578, nie gelesen) | – | entfernt aus dem Options-State; der Druckmodus steht in `aufgaben.internal.print-state` (`"schule/aufgaben/print@1"`), siehe 1.5 | L17 (Schema ist geschlossen), `tabelle-aufgaben.md` 2.1, [Lücke 1] |
| `"teilaufgabe-numbering"` | `subtask-numbering` | umbenannt | K 3/39 |
| – (`aufgaben-shortcodes` heute nur Closure) | `shortcodes` | neu im State | K 5.4, L17 |

### 3.2 Enum-Werte (vollständig)

| Parameter alt | Wert alt | Parameter neu | Wert neu |
|---|---|---|---|
| `loesungen` | `"keine"`, `"false"`, `false`, `none` | `solutions` | `none` |
| `loesungen` | `"sofort"` | `solutions` | `"in-place"` |
| `loesungen` | `"folgend"` | `solutions` | `"after-task"` |
| `loesungen` | `"reinquetschen"` | `solutions` | `"at-end"` |
| `loesungen` | `"seite"` | `solutions` + `solutions-pagebreak` | `"at-end"` + `"before"` (ein weicher Umbruch vor dem Block, Z. 304–306) |
| `loesungen` | `"seiten"` | `solutions` + `solutions-pagebreak` | `"at-end"` + `"per-task"` (je Aufgabe eine eigene Seite mit `page(…)`, aufgaben.typ Z. 311–312) |
| `loesungen` | `"nur"` | `solutions` | `"only"` |
| `materialien` | `"keine"`, `"false"`, `false`, `none` | `materials` | `none` |
| `materialien` | `"sofort"`, `"folgend"` | `materials` + `materials-pagebreak` | `"after-task"` + `none` (beide alten Werte bei Material gleich, aufgaben.typ Z. 1076, 1290) |
| `materialien` | `"seiten"` | `materials` + `materials-pagebreak` | `"after-task"` + `"before"` (Vorgabe); Wirkung: jedes Aufgabenmaterial auf einer eigenen Seite, `page(…)` (Z. 819–820, 1296) |
| `materialien` | `"reinquetschen"` | `materials` + `materials-pagebreak` | `"at-end"` + `none` |
| `materialien` | `"seite"` | `materials` + `materials-pagebreak` | `"at-end"` + `"before"`; Wirkung: ein weicher Umbruch vor dem ganzen Materialteil (Z. 814–816) |
| `punkte`, `punkte.anzeige` | `"keine"` | `points` | `none` |
| `punkte`, `punkte.anzeige` | `"aufgaben"` | `points` | `"tasks"` |
| `punkte`, `punkte.anzeige` | `"teilaufgaben"` | `points` | `"subtasks"` |
| `punkte`, `punkte.anzeige` | `"alle"` | `points` | `"all"` |
| `punkte`, `punkte.anzeige` | `"keine-summe"` | `points` + `points-total` | `"all"` + `false` |
| `punkte.position` | `"ende"` | `points-position` | `"end"` |
| `punkte.position` | `"rand"` | `points-position` | `"margin"` |
| `aufgaben-shortcodes` | `"keine"` | `shortcodes` | `none` |
| `aufgaben-shortcodes` | `"aufgaben"` | `shortcodes` | `"tasks"` |
| `aufgaben-shortcodes` | `"teilaufgaben"` | `shortcodes` | `"subtasks"` |
| `aufgaben-shortcodes` | `"alle"` | `shortcodes` | `"all"` |
| `teilaufgabe-numbering` | `"a)"` | `subtask-numbering` | `"a)"` |
| `teilaufgabe-numbering` | `"1."` | `subtask-numbering` | `"1.1"` (aufgaben.typ Z. 1173) |
| `theme` | `none`, `"standard"` | `theme` | `auto` |
| `theme` | `"klar"`, `"atlas"`, `"skizze"`, `"labor"`, `"kontur"`, `"leiste"`, `"riso"`, `"bauhaus"` | `theme` | gleich |
| `varianten` | `"druck"` | `variants` | `"print"` |
| `varianten` | `"digital"` | `variants` | `"digital"` |
| `varianten` | `"loesung"` | `variants` | `"solutions"` |
| `varianten` | `"zweifach"` | `variants` | `"two-up"` |
| `vorschau-alle` | `true` / `false` | `preview-variant` | `auto` / `none`; neu `"all"`, `"<name>"` |
| `paper` (bei `zweifach`) | `"a3"`, `"a4"`, `"a5"`, `"a6"` | `paper` (bei `two-up`) | `"a4"`, `"a5"`, `"a6"` gleich. `"a3"`: heute **kein Fehler**, sondern stiller Rückfall auf einen A4-Bogen, auf den zwei A3-Rahmen gelegt werden (`_papier-groesser.at(paper, default: "a4")`, Z. 526, 859; die `panic` Z. 727–732 greift nur bei Formaten außerhalb von `_papier-masse` und nennt a3 sogar als erlaubt); künftig Fehler (5 Nr. 38) |
| `stufe` | `"sek-1"`, `"sek-2"` | `stage` | gleich |
| `niveau` | `"einfuehrung"`, `"vertiefung"`, `"ea"`, `"ga"` (heute ungeprüft) | `level` | `"introduction"`, `"consolidation"`, `"ea"`, `"ga"`; anderer Wert: Bericht |
| `typ` | `"arbeitsblatt"`, `"uebung"`, `"stationsarbeit"`, `"klausur"`; heute freier String, jeder andere Wert möglich | `kind` | `"worksheet"`, `"practice"`, `"stations"`, `"exam"`; anderer Wert: Bericht, keine Abbildung |
| Kasten `art` | 15 Namen, dazu `"task"`, `"code"` | `kind` | 15 Namen; `"task"`, `"code"` entfallen |

### 3.3 Varianten-Vorlagen (`_varianten-vorlagen` → `internal.variant-presets`)

| alt | neu | Overrides alt | Overrides neu | Ausgabedatei (eingefroren, K 2.1) |
|---|---|---|---|---|
| `druck` | `"print"` | `(print: true)` | `(print: true)` | `[<filename>-]druck.pdf` |
| `digital` | `"digital"` | `(print: false)` | `(print: false)` | `[<filename>-]digital.pdf` |
| `loesung` | `"solutions"` | `(print: true, loesungen: "nur", workspaces: false)` | `(print: true, solutions: "only", workspaces: false)` | `[<filename>-]loesung.pdf` |
| `zweifach` | `"two-up"` | `(print: true, zweifach: true)` | `(print: true, two-up: true)` | `[<filename>-]zweifach.pdf` |
| Override-Schlüssel `datei` | `path` | ganzer Ausgabepfad | gleich | – |
| eigener Name ohne Eintrag (Tippfehler `"lösung"`) | Fehler: Name muss vordefiniert sein oder in `variant-overrides` stehen; Umlaut-Faltung liefert „heißt jetzt `solutions`" | still Variante ohne Overrides | Fehler | – |

Der Pfad ist heute `praefix + name + ".pdf"` mit `praefix = dateiname + "-"` oder `""` (`ab.typ` Z. 1106, 1109): ohne `filename` heißt die Datei `druck.pdf`, nicht `-druck.pdf`; der Bindestrich gehört zum Präfix. Die Abbildung englischer Variantenname → deutscher Dateiname-Teil (`print` → `druck`, `solutions` → `loesung`, `two-up` → `zweifach`) steht in einer Tabelle `internal.variant-suffixes` (wie `internal.meta-keys`, K 2.1). Eigene Variantennamen werden unverändert benutzt.

Kopplungen am Variantennamen (alle im Paketquelltext, kein Codemod):

- **Scope-Kennung.** Heute `scope: praefix + name` im Bundle (Z. 1114) und `scope: name` in der Vorschau (Z. 1125). Entschieden: die Scope-Kennung wird aus dem **neuen** Variantennamen gebildet (`[<filename>-]solutions`); sie geht in die Labels `<schule-arbeitsblatt-start-{scope}>`/`…-end-{scope}>` ein (3.5), die ohnehin umbenannt werden. Nur der Dateiname bleibt deutsch.
- **klassenarbeit.** `klassenarbeit/0.4.0/src/klassenarbeit.typ` Z. 319 vergleicht den Variantennamen wörtlich: `variante == "loesung"`. Die Stelle wird auf `"solutions"` umgestellt (Tabelle klassenarbeit); ohne die Anpassung fehlt der Erwartungshorizont in der Lösungsfassung still.

### 3.4 States und Counter

| alt (Variable, Schlüssel) | neu (Variable, Schlüssel) | Art | Begründung |
|---|---|---|---|
| `print-state`, `"print"` | `aufgaben.internal.print-state`, `"schule/aufgaben/print@1"` | umgezogen nach aufgaben, umbenannt; in arbeitsblatt entfernt | 1.5, L17 |
| `_state_ab_scope`, `"ab-scope"` | `internal.scope-state`, `"schule/arbeitsblatt/scope@1"` | umbenannt | K 7.3 |
| anonym `state("options", (:))` (Z. 1179, 1307, 1330) | `aufgaben.internal.options-state`, `"schule/aufgaben/options@1"` | ersetzt | K 7.2, K 7.3, L20 |
| `_state_options` (aufgaben), `"options"` | `aufgaben.internal.options-state`, `"schule/aufgaben/options@1"` | umbenannt (Tabelle aufgaben) | K 7.3 |
| `_state_theme` (aufgaben), `"ab-theme"`; geschrieben in `ab.typ` Z. 616 | `aufgaben.internal.theme-state`, `"schule/aufgaben/theme@1"` | umbenannt (Tabelle aufgaben; Schema-Zähler wichtig, weil die Hook-Signaturen sich ändern) | K 7.3 |
| `_state_aufgaben`, `_state_in_loesung`, `_state_current_material_aufgabe`, `_state_current_material_index`, `_counter_aufgaben` (aufgaben, hier gelesen) | über `aufgaben.internal.*` (Namen legt die Tabelle aufgaben fest; K nennt `"schule/aufgaben/records@1"`, `"schule/aufgaben/task-counter@1"`) | umbenannt | K 7.2, K 7.3 |

**Direkte State-Zugriffe in Dokumenten.** Weil States über den Schlüsselstring geteilt werden, lesen einige Dokumente sie ohne den Paketnamen (Prüferzählung): `state("print", false).get()` 4 Stellen (z. B. `#let druck-blatt() = state("print", false).get() and not loesungsmodus()`), `state("options", (:)).get().at("loesungen", …)` 2 Stellen, `print-state.update(…)` 1 Stelle. Nach dem Schlüsselwechsel liefern diese Aufrufe still die Vorgabe (`false`, `(:)`), ohne Fehler; kein Stub kann das abfangen. Codemod-Regeln (JSON `kontext`):

| Muster | Regel | Codemod |
|---|---|---|
| `state("print"…).get()` | `is-print()` | Kontext |
| `state("options"…).get().at("loesungen"…)` | Bericht mit Hinweis auf `has-solutions()` (Vergleiche mit einzelnen Werten sind nicht mechanisch übersetzbar) | nein (Bericht) |
| `print-state.update(…)` | Bericht (der Druckmodus wird nur noch im Kopf gesetzt) | nein (Bericht) |
| jedes andere `state("print"`, `state("options"`, `state("ab-scope"`, `state("ab-theme"` | Bericht | nein (Bericht) |

### 3.5 Labels, Metadaten, Figure-Kinds, System-Inputs

| alt | neu | Art | Begründung |
|---|---|---|---|
| `<ab-meta>` mit `titel`, `klasse`, `fach`, `thema`, `jahrgang`, `stufe`, `niveau`, `typ`, `stichworte`, `kerncurriculum`, `stand` | unverändert (Label, Schlüssel, deutsche Werte von `niveau` und `typ`, und `""` für fehlenden Titel/Klasse) | eingefroren | K 2.1; Abbildung in `internal.meta-keys` und `internal.meta-values`, Tabelle unten |
| `<_ab-start-{scope}>`, Wert `"arbeitsblatt-start"` | `<schule-arbeitsblatt-start-{scope}>`, Wert `"worksheet-start"` | umbenannt | K 7.3 |
| `<_ab-ende-{scope}>`, Wert `"arbeitsblatt-ende"` | `<schule-arbeitsblatt-end-{scope}>`, Wert `"worksheet-end"` | umbenannt | K 7.3 |
| `<_zweifach-oben>` | `<schule-arbeitsblatt-two-up-top>` | umbenannt | K 7.3 |
| `<_zweifach-ende>` | `<schule-arbeitsblatt-two-up-end>` | umbenannt | K 7.3 |
| Figure-Kinds `"aufgabe"`, `"teilaufgabe"`, `"material"` (in aufgaben gesetzt, hier in Show-Regeln und Verweisen gelesen, Z. 376–431, 630–684) | `"task"`, `"subtask"`, `"material"` (Tabelle aufgaben entscheidet) | umbenannt (Kopplung) | K 3/3, K 3/4 |
| Verweiskürzel „M1-A", „a)", „1.1", Präfixe „A", „T", „M" | unverändert | Ausgabe | K 2.1 |
| `--input vorschau=alle` | unverändert | eingefroren | K 2.1 |
| Showcase-Inputs `theme`, `class`, `loesungen` (`showcase/beispiel.typ` Z. 10–13) | `theme`, `class`, `solutions` | umbenannt (nur Showcase und sein Build-Skript) | K 2.1 friert nur `vorschau` ein |
| Template-Datei `template/ab.typ` | unverändert | – | K 9.3 nennt `ab.typ` als Vorlage |

`internal.meta-keys` (Parameter neu → Schlüssel in `<ab-meta>`, vollständig; heute schreibt `ab.typ` Z. 590–602 die Parameter ungefiltert):

| Parameter neu | Meta-Schlüssel (eingefroren) | Wert nach `<ab-meta>` |
|---|---|---|
| `title` | `titel` | wie übergeben; **`none` wird als `""` geschrieben** (heutige Vorgabe; sonst bekäme eine Abfrage `null` statt `""`) |
| `class` | `klasse` | wie übergeben; `none` wird als `""` geschrieben |
| `subject` | `fach` | gleich |
| `topic` | `thema` | gleich |
| `years` | `jahrgang` | gleich |
| `stage` | `stufe` | gleich (`"sek-1"`, `"sek-2"`) |
| `level` | `niveau` | Rückabbildung: `"introduction"` → `"einfuehrung"`, `"consolidation"` → `"vertiefung"`, `"ea"` → `"ea"`, `"ga"` → `"ga"` |
| `kind` | `typ` | Rückabbildung: `"worksheet"` → `"arbeitsblatt"`, `"practice"` → `"uebung"`, `"stations"` → `"stationsarbeit"`, `"exam"` → `"klausur"` |
| `keywords` | `stichworte` | gleich |
| `curriculum` | `kerncurriculum` | gleich |
| `revision` | `stand` | gleich |


### 3.6 Fehlermeldungen (alle über `internal.fail`, Format `arbeitsblatt.<funktion>: <Befund> – <Abhilfe>`)

| alt (Fundstelle, Wortlaut gekürzt) | neu |
|---|---|
| Z. 308–319 `"arbeitsblatt: ungültiger Wert für `<name>`: … – erlaubt: …"` (`assert`) | ``arbeitsblatt.arbeitsblatt: `points: "task"` ist kein gültiger Wert – meintest du `"tasks"`? erlaubt: …`` |
| Z. 322–326 `"arbeitsblatt: unbekannte Option(en): … – Tippfehler?"` | ``arbeitsblatt.arbeitsblatt: unbekannter Parameter `solutoins` – meintest du `solutions`?``; alte Namen: ``… `loesungen` heißt jetzt `solutions` `` |
| Z. 727–732 `panic("zweifach unterstützt nur a3, a4, a5, a6 – erhalten: …")` | ``arbeitsblatt.arbeitsblatt: `two-up: true` geht nicht mit `paper: "b5"` – erlaubt: `"a4"`, `"a5"`, `"a6"` `` |
| Z. 799–805 `panic("zweifach: Der Inhalt passt nicht in die Messsonde …")` | ``arbeitsblatt.arbeitsblatt: Inhalt zu lang für `two-up` (mehr als N Seiten) – Dokument teilen oder `two-up: false` `` |
| Z. 919 `panic("varianten muss auto, ein String, ein Array oder ein Dictionary sein …")` | ``arbeitsblatt.arbeitsblatt: `variants` erwartet ein Array aus Namen, bekam … – zum Beispiel `("print", "solutions")` `` |
| themes.typ Z. 1155 `"Unbekanntes Theme … Verfügbar: standard, …"` | ``arbeitsblatt.arbeitsblatt: `theme: "klr"` ist kein gültiger Wert – meintest du `"klar"`? erlaubt: `auto`, `"klar"`, … `` |
| themes.typ Z. 1162 `panic("theme muss none, ein Name, eine Funktion oder ein Dictionary sein …")` | ``arbeitsblatt.arbeitsblatt: `theme` erwartet `auto`, einen Namen, ein Dictionary oder eine Funktion, bekam … – zum Beispiel `"klar"` `` |
| neu | ``arbeitsblatt.arbeitsblatt: `two-up: true` wirkt nur mit `print: true` – eines von beiden ändern`` |
| neu | ``arbeitsblatt.arbeitsblatt: `theme: none` – die Vorgabe ist `auto` `` |
| neu | ``arbeitsblatt.arbeitsblatt: unbekannter Theme-Schlüssel `kopf` – `kopf` heißt jetzt `header` `` |
| neu (alter Funktionsname, K 8.3) | ``arbeitsblatt.lücke: `lücke` heißt jetzt `luecke` ``; ebenso ``arbeitsblatt.tasks: `tasks` heißt jetzt `teilaufgaben` `` |
| neu (deutscher Bausteinname als Wert, K 8.3) | ``arbeitsblatt.arbeitsblatt: `kind: "klassenarbeit"` ist kein gültiger Wert – meintest du `"exam"`? erlaubt: `none`, `"worksheet"`, `"practice"`, `"stations"`, `"exam"` `` |

---

## 4. Öffentliche Oberfläche der Zielversion

Einstieg wird `src/lib.typ` (K 7.1); `typst.toml: entrypoint = "src/lib.typ"`. Kein `import …: *` mehr.

### 4.1 Exportiert: eigene Namen

| Gruppe | Namen |
|---|---|
| Bausteine (deutsch, `bausteine-de.txt`) | `arbeitsblatt`, `arbeitsblatt-einzeln`, `luecke`, `lsg` |
| Helfer (englisch) | `workspace`, `minipage`, `conditional-pagebreak`, `qr-code`, `qr-box`, `icon-link` |
| Kästen | `abstract`, `info`, `question`, `memo`, `conclusion`, `tip`, `success`, `warning`, `error`, `example`, `goal`, `idea`, `experiment`, `notify`, `danger` |
| Themes | `themes`, `subject-accents`, `subject-names`, `callout-style` |
| Modul | `internal` |
| Fremdnamen (`fremdnamen.txt`, K 7.1) | `canvas` (eigener Wrapper unter dem cetz-Namen), `draw` (cetz), `plot` (cetz-plot), `qty`, `num`, `unit` (Einheiten-Wrapper), `stickybox` (colorful-boxes; 45 Aufrufe), `fa-icon` (fontawesome). Nicht aufgenommen: `slanted-colorbox` (52 Aufrufe) und `colorbox` (48), obwohl sie nach demselben Maß über `stickybox` liegen; der Codemod fügt für sie die Importzeile ein (4.5, Zweifelsfall 14) |

Übergangsnamen und Aliase gibt es nicht (K 9.3). Die englischen Zwillinge `worksheet`, `worksheet-single`, `blank`, `inline-solution` werden nie exportiert; das Lint prüft es gegen `zwillinge.txt` (L27 c).

### 4.2 Exportiert: namentlich durchgereichte `@schule`-Namen ([Lücke 2])

| Paket | Namen (neu), Einzelheiten in der jeweiligen Tabelle |
|---|---|
| aufgaben | Bausteine `aufgabe`, `teilaufgabe`, `teilaufgaben`, `loesung`, `erwartung`; dazu `material`, `set-options`, `reset-tasks`, `show-solutions`, `show-materials`, `show-expectations`, `show-points-table`, `get-points`, `format-points`, `has-solutions`, `is-print` |
| patterns | Bausteine `kariert`, `liniert`; dazu `flex-area`, `is-flex-area` |
| insert-a-word | `insert-a-word`, `iaword`, `reset-iaword` und die übrigen öffentlichen `iaword-*` nach der Tabelle des Pakets |
| random | `random-number`, `random-integer`, `shuffle`, `default-seed` |
| energy-sketch | `energy-sketch` (Pin auf die neue Version, heute veraltet 0.0.2) |
| mathematik | Bausteine `graphen`, `steckbrief`, `kreisdiagramm`; dazu `geogebra-algebra`, `geogebra-cell` |
| physik | Bausteine `datensatz`, `messdaten`, `berechnung`, `messwerttabelle`, `lineare-regression`, `quadratische-regression`, `wurzel-regression`, `exponentielle-regression`, `polynom-regression`, `potenz-regression`, `schaltkreis`; dazu der Wert `constants` (bisher `pk`) |
| informatik | Baustein `haeufigkeitsanalyse`; dazu `bin-to-dec`, `dec-to-bin`, `hex-to-dec`, `dec-to-hex`, `caesar`, `vigenere`, `atbash`, `rot13`, `ascii-table`, `text-to-blocks` |
| operatoren | Baustein `operatoren-liste`; dazu `operator` |

### 4.3 Abbrechende Stubs („heißt jetzt", solange die Compat-Tabelle läuft, K 9.3)

`lücke` → `luecke` · `loesungsmodus` → `has-solutions` · `tasks` → `teilaufgaben` · `print-pagebreak` → `conditional-pagebreak(print: true)` · `non-print-pagebreak` → `conditional-pagebreak(print: false)` · `qrbox` → `qr-box` · `c_canvas` → „gibt es nicht mehr – `cetz.canvas`". Dazu die Stubs der Nachbarpakete, die arbeitsblatt bisher durchreichte (`show-loesungen`, `reset-aufgaben`, `format-punkte`, `flex-feld`, `häufigkeitsanalyse`, `lineare_regression`, …; Liste in den jeweiligen Tabellen).

Keinen Stub bekommen die unveränderten Bausteine (`arbeitsblatt`, `arbeitsblatt-einzeln`, `lsg`, `teilaufgaben`, `graphen`, `messwerttabelle`, …), denn ihr Name bleibt, und die englischen Zwillinge, denn sie standen in keiner veröffentlichten Version (K 9.3); wer `#worksheet` schreibt, bekommt Typsts „unknown variable".

Regel (einheitlich): Jeder alte **öffentliche** Funktionsname bekommt einen Stub in `src/removed.typ`, wenn sich sein Name ändert, unabhängig vom Zeichenvorrat (`lücke` mit Umlaut, `c_canvas` mit Unterstrich, `non-print-pagebreak` mit `non-`); das Lint nimmt die Datei aus (K 9.3, Zweifelsfall 9).

Ausnahmen, nur in `regeln.json` unter `removed`:

- `print-state`: ist ein State, kein Aufruf; eine Variable kann keine „heißt jetzt"-Meldung tragen ([Lücke 14]).
- `mono`: ein Stub überdeckte `math.mono` in Formeln und kollidierte mit `informatik.mono` (1.16).
- alle `_`-Namen: waren nie zugesichert.

### 4.4 Wird intern (Modul `internal`, keine zugesicherte Schnittstelle)

`scope-state`, `resolve-theme`, `parse-class`, `subject-line`, `class-accent`, `callout`, `callout-titles`, `callout-classic`, `callout-style-table`, `palette`, `default-header`, `plain-text`, `normalize-unit`, `to-unit-text`, `paper-sizes`, `next-paper`, `count-pagebreaks`, `resolve-margin`, `variant-presets`, `variant-suffixes`, `resolve-variants`, `preview-all-requested`, `meta-keys`, `meta-values`, `cetz-canvas`, `outside-aligned`, `side-margins`, `badge`, `shadow-box`, `shadow-block`, `solution-inline`, `check`, `fail`. Die acht Theme-Funktionen bleiben nur über `themes.<name>` erreichbar.

### 4.5 Re-Exporte, die entfallen

| Bisher im Namensraum durch | Entfällt | So bekommt man es stattdessen |
|---|---|---|
| `@preview/cetz:0.4.2: *` (Z. 40) | alles außer `canvas`, `draw` (`matrix`, `vector`, `coordinate`, `styles`, …) | `#import "@preview/cetz:0.4.2"` im Dokument (390 Dokumente tun das schon) |
| `@preview/cetz-plot:0.1.3: *` (Z. 41) | alles außer `plot` (`chart`, …) | `#import "@preview/cetz-plot:0.1.3": chart` |
| `@preview/codly:1.3.0: *` (Z. 42) | `codly`, `codly-init`, `local`, … | `#import "@preview/codly:1.3.0": *` |
| `@preview/colorful-boxes:1.4.3: *` (Z. 43) | `colorbox` (48 Aufrufe), `slanted-colorbox` (52), `colorbox-rounded`, `outline-colorbox`, `showybox`, `box-colors` (Exportliste am Paket geprüft; Zahlen Prüferzählung) | Der Codemod fügt bei Vorkommen `#import "@preview/colorful-boxes:1.4.3": colorbox, slanted-colorbox` (nur die benutzten Namen) ein, Codemod **ja**; `stickybox` bleibt Fremdname |
| `@preview/fontawesome:0.6.0: *` (Z. 38, auch über aufgaben) | alle `fa-*`-Kurzformen außer `fa-icon` | `fa-icon("name")` oder eigener Import |
| `@preview/zero:0.5.0: *` (Z. 7) | gesamtes zero (`num` war ohnehin überschrieben) | `#import "@preview/zero:0.5.0" as zero` (als Modul, **nie** `: *`: das überschriebe das eigene `num`); 3 Dokumente im Bestand schreiben `zero: *` selbst (Prüferzählung), der Bericht warnt dort |
| `@preview/eqalc:0.1.3: *` (Z. 6) | gesamtes eqalc | eigener Import (13 Dokumente tun das schon) |
| `@preview/gentle-clues:1.2.0: *` über aufgaben; Modul `_gc` (Z. 44) | `task`, `code`, `clue`, `quotation` und alle übrigen gentle-clues-Namen | **namentlich** importieren: `#import "@preview/gentle-clues:1.2.0": code` bzw. `clue`. Nie `: *` nach dem `@schule`-Import (überdeckt die 15 Kästen still, siehe 1.18); die 15 Kästen sind eigene Funktionen |
| `@preview/zebra` als `qr-code-zebra` (Z. 39) | `qr-code-zebra` | `qr-code` oder eigener Import |
| `@preview/unify:0.8.1` (Z. 46) | `add-unit`, `unify-num`, `unify-qty`, `unify-unit` | eigener Import von unify |
| `@schule/random:0.0.1: *` (Z. 2) | `a`, `m`, `lcg`, `low_cminstd_rand`, `low_cminstd_randint`, `step_seed`, `fisher_yates_shuffle` | `random.internal` (Anhang B) |
| `@schule/energy-sketch:0.0.2: *` (Z. 4) | dessen `canvas`, `draw` (cetz 0.3.1) | entfällt ersatzlos |
| `@schule/physik` (Z. 10–36) | zap-Bauteile `zap`, `source`, `simple-source`, `multimeter`, `lamp`, `amperemeter`, `voltmeter`, `motor`, `generator` | `#import "@schule/physik:<Zielversion>": …` oder `schaltkreis` (siehe Zweifelsfall 7) |
| `@schule/informatik: *` (Z. 9) | `blockst`, `scratch`, `set-blockst`, `blockst-run-options`, `set-scratch-run`, `scratch-run`, `mono`, `häufigkeitsanalyse-alt` | `#import "@preview/blockst:…"` (47 Dokumente tun das schon) oder informatik direkt; `mono`: der Codemod ersetzt die Aufrufe durch `text(font: "SF Mono", …)` (1.16), ob informatik sein `mono` behält, entscheidet die Tabelle der Fachpakete |
| `@schule/mathematik` (Z. 8, namentlich) | `teilaufgaben`, `tasks` waren schon ausgeschlossen; `graphen`, `kreisdiagramm`, `steckbrief` bleiben unter ihrem Namen durchgereicht (4.2) | `teilaufgaben` aus aufgaben |
| `@schule/aufgaben:0.3.1: *` (Z. 1) | alles außer den in 4.2 genannten Zielnamen. Es entfallen oder werden intern (Einzelheiten `tabelle-aufgaben.md`, Abschnitte 2.4, 3 und 4): `show-loesung`, `show-loesung-inline`, `show-offene-loesungen`, `show-material`, `show-bewertung`, `get-punkte-anzeige`, `get-punkte-position`, `_theme-hook`, `_zusammen`, `_loesung-kasten`, die States `_state_*` (11) und `_counter_aufgaben`, `_be-runden`, `_be-anzeige`, `_aufgaben-final`, `_rechter-textrand`, `_erwartungen-zeilen`, `_ist-flex-workspace`, `_flex-fest`; dazu alles, was aufgaben selbst per Wildcard hereinholt (gentle-clues, fontawesome) | öffentliche Zielnamen aus 4.2; Internes nur über `aufgaben.internal` |
| `@schule/insert-a-word:0.0.3: *` (Z. 3) | die States und Zähler `iaword-list`, `iaword-solution`, `iaword-counter`, `iaword-uniform`, `iaword-start`, `iaword-show` (`lib.typ` Z. 4–19), `iaword-neu` (Z. 26; wird `reset-iaword`), und nochmals `random: *` | `insert-a-word`, `iaword`, `reset-iaword` (4.2); welche `iaword-*` öffentlich bleiben, legt die Tabelle des Pakets fest |
| `@preview/zebra:0.1.0` (Z. 39) und `@preview/unify:0.8.1` (Z. 46) | siehe die beiden Zeilen oben (`qr-code-zebra`; `add-unit`, `unify-num`, `unify-qty`, `unify-unit`) | – |
| eigene `_`-Namen und `c_canvas`, `print-state` | siehe 4.3, 4.4 | – |

klassenarbeit exportiert dieselbe Menge namentlich (K 7.1) und greift nur über `arbeitsblatt.internal.scope-state` und `arbeitsblatt.internal.resolve-theme` auf Internes zu (heute `_state_ab_scope` Z. 319, `_theme-aufloesen` Z. 86).

---

## 5. Fehler und Altlasten, die mit der Umbenennung behoben werden (nur API)

| Nr. | Fundstelle | Befund | Behebung |
|---|---|---|---|
| 1 | `ab.typ` Z. 286, 1048 | Vorgabe `loesungen: "false"` als String; vier Schreibweisen für „aus" | `solutions: none`; `false`, `"false"`, `"keine"` melden „das Aus ist `none`" (K 5.2) |
| 2 | Z. 288 | `punkte` ist String oder Dictionary | drei flache Optionen (K 5.1) |
| 3 | Z. 286 | `"seite"` und `"seiten"` unterscheiden sich nur im Plural-n | `solutions-pagebreak: "before"` / `"per-task"` (L10) |
| 4 | Z. 102–104 | `qr-code(alt:)` toter Parameter; `background` Altname von `light-color` | `alt` entfernt; ein Name `background-fill` |
| 5 | Z. 1492 | `workspace(height:)` ohne Wirkung; Doku Z. 1484–1489 behauptet das Gegenteil | Parameter und Doku-Beispiel entfernt |
| 6 | Z. 1263 und 1229 | `tasks` ist Alias und Parametername zugleich | Alias entfällt, Parameter heißt `items` |
| 7 | Z. 1233 gegen Z. 286 | `loesungen` mit zwei Typen (Modus-String, Array) | `solutions` gegen `item-solutions` (L6) |
| 8 | Z. 1232 gegen Z. 1361 | `gutter` gegen `spacing` für dasselbe | beide `gutter`, Vorgaben bleiben (K 5.5) |
| 9 | Z. 1265 | `c_canvas` öffentlich, snake_case | `internal.cetz-canvas` |
| 10 | Z. 1475 | `mono` doppelt (auch `informatik/0.0.2/lib.typ:314`), Schrift fest | in arbeitsblatt entfernt, ohne Stub; Codemod ersetzt die 136 Aufrufe durch `text(font: "SF Mono", …)` |
| 11 | Z. 180 gegen Z. 578 | Druckmodus doppelt geführt (`print-state`, `_state_options.print`; der zweite wird nie gelesen) | ein State `aufgaben.internal.print-state`, Abfrage `is-print()`; Schlüssel `print` aus dem Options-State entfernt |
| 12 | Z. 1179, 1307, 1330 | `state("options", (:))` direkt statt `_state_options` | `aufgaben.internal.options-state` (L20) |
| 13 | Z. 1308, 1331 | `loesungen-only` prüft nur `== "nur"` | `solutions-visible` folgt `has-solutions()` (Bedeutungsänderung; `true` wird nicht automatisch abgebildet, Zweifelsfall 6) |
| 14 | Z. 322 | überzählige Positionsargumente in `..args` nicht gemeldet; nur `header-ascent` erlaubt | `..deprecated` nimmt nichts an; `header-ascent` in `page-settings` |
| 15 | Z. 900–925 | unbekannter Variantenname (`"lösung"`) erzeugt still eine Variante ohne Overrides, also ohne Lösungen | Fehler; Umlaut-Faltung (K 8.4) |
| 16 | Z. 1507–1520 gegen 1539–1553; themes.typ Z. 104–105 | `task`, `code` in den Kasten-Tabellen, aber kein Wrapper; bleiben im gentle-clues-Stil | Einträge entfernt; gentle-clues-`task` nicht mehr durchgereicht |
| 17 | themes.typ Z. 191, 332, 435, 557, 676, 821, 923, 1041 | Hook `kopf` bekommt `copyright`, kein Theme zeichnet es; mit Theme verschwindet der QR-Code | Parameter heißt `copyright-url`; jedes eingebaute Theme zeichnet ihn (sonst ist der Kopfparameter mit Theme wirkungslos) |
| 18 | Z. 1521–1536 | Kasten-Argumente außer fünf werden mit Theme still verworfen | deklarierte Signatur, unbekannte Namen sind Fehler |
| 19 | Z. 268–304, 1030–1068, 1070–1103 | Parameterliste dreifach gepflegt | eine Parametertabelle erzeugt beide Signaturen (A.1) |
| 20 | Z. 990–999 | Parameterdoku unvollständig (`"reinquetschen"`, `"keine-summe"`, Dictionary-Form, `"zweifach"`) | Docstring aus der Tabelle, L26 |
| 21 | Z. 1195 | Doku-Beispiel `#lsg(sonst: linien(2))`, `linien` gibt es nicht | `#lsg(fallback: liniert(2))[…]` |
| 22 | Z. 727–732, 291 | `zweifach: true` ohne `print: true` ungeprüft; `paper` ungeprüft | Kombinations- und Wertprüfung (K 8.3); zu `"a3"` siehe Nr. 38 |
| 23 | Z. 543–549 gegen 743–747 | `header-ascent` des Themes wird im Zweifach-Modus ignoriert | eine Auflösung `page-settings` → Theme → Vorgabe für beide Wege |
| 24 | Z. 4 | Pin `energy-sketch:0.0.2` (cetz 0.3.1) veraltet; `canvas`/`draw` daraus im Namensraum | Pin heben (K 9.4 Nr. 1), namentlicher Import |
| 25 | Z. 1–46 | 13 Wildcard-Importe, rund 5500 durchgereichte Namen, `a` und `m` global | namentliche Exporte (L19), Abschnitt 4 |
| 26 | themes.typ Z. 10, 189 ff.; `ab.typ` Z. 488–505 | `rand` dokumentiert als `(top:, bottom:)`, gesetzt wird `kopf-oben`, gelesen zusätzlich `innen`, `aussen`; drei Bedeutungen von `rand` in einer Datei (Z. 300) | `margin` mit Typsts Schlüsseln, `header-top` daneben; `reiter(rand:)` wird `stroke` |
| 27 | themes.typ Z. 187 ff. | Schlüssel `name` tot; `footer-descent` gelesen, aber weder dokumentiert noch gesetzt | beide in `theme-keys` dokumentiert und geprüft |
| 28 | themes.typ Z. 210 ff. | Hook `aufgabe` mit `nummer` (int) und `number` (bool) in einer Signatur | ein Parameter `marker` (L10) |
| 29 | themes.typ Z. 191 ff. | Vorgabe `kopf(font-size:)` wiederholt `schrift.titel` in jedem Theme | Vorgabe `auto`, eine Quelle `title-font-size` |
| 30 | themes.typ Z. 98–118 | `none` (in `_kasten-stil`) und `auto` (Parameter `farbe`) für dieselbe Aussage | nur `auto` (K 5.1) |
| 31 | themes.typ Z. 1152, 1155 | `"standard"` ist Alias von `none`, kein Schlüssel in `themes`, steht aber in der Fehlermeldung | `theme: auto`; `"standard"` meldet „heißt jetzt" |
| 32 | themes.typ gesamt; `ab.typ` Z. 45 | Hilfen für Theme-Autoren (`kasten-stil`, `fachfarben`, …) nicht importierbar, obwohl eigene Themes beworben werden | `callout-style`, `subject-accents`, `subject-names` exportiert |
| 33 | themes.typ Z. 430 ff. (Inventar 5) | Schlüssel eigener Theme-Dictionaries ungeprüft (`fuß`, `lösung` still ignoriert) | Schlüsselprüfung mit Umlaut-Faltung (K 8.4, L18) |
| 34 | `ab.typ` Z. 308–326, 727, 799, 919; themes.typ Z. 1155, 1162 | `assert` und `panic` gemischt, sechs verschiedene Präfixe | `internal.fail`, ein Format (K 8.2, L21) |
| 35 | `typst.toml` | `compiler` fehlt trotz `target() == "bundle"` | `compiler = "0.15.0"` eintragen (kein Name, aber Teil der Paketschnittstelle) |
| 36 | `template/ab.typ` Z. 4–5 | `title: [Titel]`, `class: [Klasse]` als Inhalt, Doku sagt String; Kommentar ohne `zweifach` | Vorlage mit den Namen der Zielversion neu schreiben (K 9.3) |
| 37 | Z. 503 gegen Z. 548, 746 | `header-ascent` hat zwei Vorgaben für denselben Schlüssel: 0.8cm in der Randberechnung, 20% bei `set page` und im Zweifach-Modus. Ein Theme-Dictionary mit `kopf`, aber ohne `header-ascent`, rechnet den Rand mit 0.8cm und setzt den Kopf mit 20% | eine Auflösung, ein Wert für beide Stellen: `page-settings` → Theme → Vorgabe (20% ohne Theme-Kopf, 0.8cm mit Theme-Kopf). Die acht eingebauten Themes setzen den Schlüssel, ihr PDF bleibt gleich; betroffen sind nur eigene Theme-Dictionaries ohne den Schlüssel (Zweifelsfall 15) |
| 38 | Z. 526, 859 gegen Z. 727–732 | `zweifach: true` mit `paper: "a3"`: `_papier-groesser.at(paper, default: "a4")` fällt still auf einen A4-Bogen zurück, auf den zwei A3-Rahmen gelegt werden; die Fehlermeldung nennt a3 als erlaubt | Fehler „`two-up: true` geht nicht mit `paper: "a3"`" (3.6) |
| 39 | Versionen 0.1.0–0.3.2, Sink `..args` | `header-font-size` (1063 Köpfe), `subtitle`, `erwartungen`, `klausurboegen` wurden still verschluckt; rund 40 Dokumente verlangen eine Titelgröße ≠ 16pt und bekamen sie nie | `..deprecated` nimmt nichts an; Codemod löscht die wirkungslosen Argumente und berichtet sie (1.1) |
| 40 | Z. 1145–1159 | `lücke` versteckt den Inhalt in jedem Modus, auch in der Lösungsfassung | `luecke` folgt `has-solutions()` (K 6); Verhaltensänderung, Zweifelsfall 12 |
| 41 | Z. 1379 gegen Z. 1255–1256 | `minipage(spacing:)` setzt nur den Spaltenabstand, `teilaufgaben(gutter:)` Spalten und Zeilen | beide `gutter` mit Typsts Bedeutung; Verhaltensänderung bei mehrzeiligen `minipage`-Aufrufen (Zweifelsfall 13) |
| 42 | Z. 1535 | Kasten ohne Inhalt: mit Theme erlaubt (`default: []`), ohne Theme Fehler | `body` ist immer Pflicht |
| 43 | Z. 1022, 1020 | `typ` und `niveau` dokumentieren Werte, prüfen sie aber nicht | geprüfte Auswahl (Zweifelsfall 16) |

---

## 6. Zweifelsfälle und Entscheidungen

1. **Hook `header`: `font-size` oder `title-font-size`.** A.12 schreibt `font-size`, übergeben wird die Titelgröße; nach K 3/49 und K 5.4 hieße sie `title-font-size`. Entscheidung: A.12 wörtlich (`font-size`), damit diese Tabelle und die von klassenarbeit dieselbe Signatur haben. Empfehlung an den Autor: A.12 auf `title-font-size` ändern.
2. **Hook `background`: `header-top` trägt den oberen Seitenrand.** Der Theme-Schlüssel `header-top` (alt `rand.kopf-oben`) ist der Abstand Blattkante–Kopf; der Hook-Parameter (alt `oben`, Vorgaben 3,6 cm und 3 cm) ist der obere Seitenrand. Ein Name, zwei Größen. Entscheidung: A.12 wörtlich. Empfehlung: Hook-Parameter streichen und `margin.top` lesen (der Aufrufer übergibt dann immer ein aufgelöstes Dictionary).
3. **Hook `task` verliert die Nummer als Zahl.** `bauhaus` wählt die Form nach der Nummer (`form(n, …)`), `labor` setzt „A" davor. Mit `marker` (Inhalt) geht das Zweite, das Erste nicht. Entscheidung: A.12 wörtlich; `bauhaus` liest die Zahl aus `aufgaben.internal` (Aufgabenzähler). Empfehlung: `task-number: 1` im Hook ergänzen (K 3/41).
4. **`canvas` als eigener Wrapper unter einem Fremdnamen.** `fremdnamen.txt` führt `canvas (cetz)`, heute ist es ein Wrapper mit Achsenstil. Entscheidung: Wrapper bleibt (gleiches PDF), Sink wird durch `length`, `padding` ersetzt; übrige cetz-Argumente sind Fehler mit Abhilfe.
5. **`icon:` an Kästen (17 Aufrufe bei `info`).** A.11 kennt kein `icon`. Entscheidung: entfernt, Meldung mit Abhilfe. Empfehlung: `icon: auto` in A.11 aufnehmen (K 3/77 hat das Wort), sonst verlieren 17 Stellen ihr Symbol.
6. **`loesungen-only: true` → `solutions-visible: true` ändert die Wirkung.** Heute nur bei `"nur"`, künftig bei jeder sichtbaren Lösung (K A.9, dort **[prüfen]**; am Code bestätigt: Z. 1308, 1331). Entscheidung: Name und Bedeutung nach K A.9; der Codemod bildet `true` **nicht** automatisch ab, sondern berichtet die 5 Stellen (4× `non-print-pagebreak`, 1× `print-pagebreak`), denn für die alte Bedeutung „nur in der reinen Lösungsfassung" gibt es im neuen API keinen Ausdruck. Betroffen wären Dokumente mit `"sofort"`, `"folgend"`, `"seite"`, `"seiten"`, `"reinquetschen"`. Frage an den Autor: Soll die alte Bedeutung ausdrückbar bleiben (dann müsste der Parameter eine Auswahl werden, siehe [Lücke 20])?
7. **Welche `@schule`-Namen arbeitsblatt durchreicht.** K 7.1 zählt nur Eigenes, `internal`, Fremdnamen und die Stubs auf; dass klassenarbeit „alles, was arbeitsblatt exportiert" weitergibt und L23 (a) das Durchreichen kennt, setzt durchgereichte `@schule`-Namen voraus, nennt sie aber nicht. Entscheidung: die öffentlichen Funktionen der Schwesterpakete, die heute durchgereicht werden, bleiben namentlich durchgereicht (4.2); Fremdes, das nur über ein Schwesterpaket hereinkam (zap-Bauteile, blockst), entfällt.
8. **`qty(value, unit)` und `unit(unit)`: Parameter heißt wie die Funktion `unit`.** L14 verbietet das; die frühere Begründung „Fremdname" trägt nicht, denn `qty`/`unit` sind nach K 7.1 eigene Einheiten-Wrapper. Zugleich verlangt K 3/67 für die Einheit das Wort `unit`; in der ersten Fassung hieß sie in `qty` `unit` und in `unit` `body` (zwei Wörter für einen Begriff). Entscheidung: an beiden Stellen `unit`, nur positional, im Rumpf nie der bare Funktionsname; die nötige L14-Ausnahme „rein positionaler Parameter" ist als [Lücke 16] gemeldet. Offen: `thousandsep:` (9 Stellen im Bestand) entfällt wie die übrigen Fremdargumente (`e:` 15, `per-mode:` 14, `digits:` 2); der Autor kann es stattdessen deklarieren lassen.
9. **Stubs mit verbotenen Zeichen oder Affixen (`lücke`, `non-print-pagebreak`, `c_canvas`).** K 9.3 verlangt die ersten beiden als abbrechende Funktionen, K 2.3/L1 und L4 verbieten Umlaut und `non-`. Entscheidung: eine Regel für alle – jeder alte öffentliche Funktionsname bekommt einen Stub in `src/removed.typ`, das das Lint ausnimmt (K 9.3: von L1 und L27; für L4 fehlt die Ausnahme, [Lücke 11]); deshalb auch `c_canvas`, für den die erste Fassung mit derselben Begründung keinen Stub vorsah. Ausnahmen mit Sachgrund: `print-state` (Variable) und `mono` (überdeckte `math.mono`), siehe 4.3.
10. **`kicker` und `fachfarbe` nicht öffentlich.** A.12 zählt die öffentlichen Namen aus `themes.typ` abschließend auf. Entscheidung: beide nach `internal` (`subject-line`, `class-accent`); eigene Themes bekommen den Akzent schon aufgelöst, die Fachzeile müssen sie selbst bauen. Empfehlung: `subject-line` später öffentlich machen.
11. **`luecke`: Der Paketname trifft dokumenteigene Funktionen.** K 2.1a macht `luecke` zum Bausteinnamen (Umschrift von `lücke`, K 2.3). Einen Paketnamen `luecke` gab es bisher nie (kein `#let luecke` im Repo); geschrieben wurde `lücke` (119 Aufrufe), und der bricht als Stub mit „heißt jetzt `luecke`" ab. Im Bestand stehen dagegen 32 Aufrufe einer dokumenteigenen Funktion `luecke(breite:, at:)`. Entscheidung nach K 9.3: Lokale Definitionen überdecken den Baustein und bleiben gültig; der Codemod fasst vorhandene `luecke(`-Aufrufe nie an und benennt `lücke` nur um, wenn das Dokument weder `#let luecke` noch `#let lücke` selbst definiert, sonst Bericht. Die frühere Empfehlung, den Übergangsnamen `luecke` zu streichen, ist gegenstandslos: Übergangsnamen gibt es nicht mehr ([Lücke 15]).
12. **`luecke` zeigt künftig die Lösung.** K 6 nennt `luecke` ausdrücklich unter den Funktionen, die `has-solutions()` folgen; heute versteckt `lücke` immer. Das ändert das PDF jeder Lösungsfassung an 119 Stellen und steht gegen K 5.5 (gleiches Dokument, gleiches PDF). Entscheidung: K 6 wörtlich, als Verhaltensänderung ausgewiesen (Changelog, `regeln.json`, Codemod-Bericht); der Seitenvergleich gilt für diese Dokumente nur in den Fassungen ohne Lösungen. Alternative für den Autor: `luecke` versteckt weiter immer, das Füllen bleibt Sache von `lsg` (dann bleibt jedes PDF gleich).
13. **`minipage(gutter:)`: Spalten oder Spalten und Zeilen.** Heute nur Spalten (`column-gutter`), Zeilenabstand 0. Entscheidung: Typsts Bedeutung (Spalten und Zeilen), weil ein Parameter mit Typst-Namen sich wie sein Namensvetter verhalten muss (Leitregel 3) und `teilaufgaben(gutter:)` es schon so hält. Folge: mehrzeilige `minipage`-Aufrufe bekommen 5mm Zeilenabstand; der Codemod berichtet sie, sie gehören in den Seitenvergleich. Alternative: nur `column-gutter` setzen (PDF gleich, aber `gutter` hieße dann in zwei Funktionen Verschiedenes).
14. **`colorbox` und `slanted-colorbox` nicht in `fremdnamen.txt`.** `stickybox` steht dort mit 45 Aufrufen; `slanted-colorbox` (52) und `colorbox` (48) liegen darüber. Entscheidung: die Liste aus K 7.1 bleibt, der Codemod fügt für beide die namentliche Importzeile ein (kein Dokument bricht). Alternative: beide aufnehmen ([Lücke 24]).
15. **Vorgabe von `header-ascent`.** Zwei heutige Vorgaben (0.8cm, 20%; 5 Nr. 37). Entscheidung: 20% ohne Theme-Kopf (klassisch, unverändert), 0.8cm mit Theme-Kopf, an Randberechnung und `set page` derselbe Wert. Das ändert das PDF nur für eigene Theme-Dictionaries mit `kopf`, aber ohne `header-ascent` (dort passt heute der Rand nicht zum Kopfabstand).
16. **`kind` und `level` als geschlossene Auswahl.** `typ` ist heute ein freier String; A.1 macht `kind` zu W2 mit vier Werten. Für jeden anderen Wert gibt es keine Abbildung und keinen deutschen Rückweg nach `<ab-meta>`. Entscheidung: A.1 wörtlich, unbekannte Werte berichtet der Codemod. Frage an den Autor: Welche weiteren Materialarten kommen im Bestand vor, und sollen sie Werte werden ([Lücke 26])?
17. **Scope-Kennung und Variantennamen.** Die Kennung wird aus dem neuen Variantennamen gebildet, der Dateiname aus dem deutschen Teil (3.3). `klassenarbeit` vergleicht den Namen wörtlich mit `"loesung"` und muss mitziehen.

---

## 7. Lücken der Konvention (gemeldet, hier nach der Leitregel entschieden)

1. **`print` und das Options-Schema.** K 5.4 sagt „Schlüssel des Options-States = Kopfparameter", L17 sagt „= Parameter von `set-options`"; `print` ist Kopfparameter, fehlt aber in `set-options`, und `is-print()` liegt in aufgaben. Entschieden wie in `tabelle-aufgaben.md`: `print` steht **nicht** im Options-State (L17, Schema geschlossen), sondern in einem eigenen State `aufgaben.internal.print-state` (`"schule/aufgaben/print@1"`); K 5.4 braucht dafür die Ausnahme „außer `print`".
2. **Durchgereichte `@schule`-Namen** fehlen in der Aufzählung von K 7.1 und in L19; nur L23 (a) erwähnt das Durchreichen (siehe Zweifelsfall 7).
3. **Kein Glossarwort für Festbreitenschrift** (`mono`). Entschieden: entfernt, ohne Stub (ein Stub überdeckte `math.mono`).
4. **Wortliste `words-en.txt` deckt nicht:** `length`, `padding` (canvas), `weak` (A.9), `style` (`callout-style`, A.12), den Wert `fraction` (`per: "fraction"`), die Plurale `themes`, `accents`, `names`, und 14 Kastennamen (`abstract`, `question`, `memo`, `conclusion`, `tip`, `success`, `warning`, `error`, `example`, `goal`, `idea`, `experiment`, `notify`, `danger`; nur `info` steht drin).
5. **Kein Wort für „Akzent des Blatts" neben dem Akzent des Kastens** in `callout-style`. Entschieden: `worksheet-accent` (`worksheet` ist nach K 2.1b und K 3/1 das Parameterwort für den Baustein `arbeitsblatt`; `sheet` steht nach K 3/12 nur für den Klausurbogen, die erste Fassung `sheet-accent` war deshalb falsch). Eine Glossarzeile fehlt, ebenso der Eintrag `worksheet-accent` unter den Vorkommen in K 2.1b.
6. **Rückgabeschlüssel für einen Symbolnamen als String.** `icon` ist nach K 3/77 Inhalt. Entschieden: `icon-name`.
7. **Theme-Schlüssel und Hooks gegen L18 / K 4.4 Nr. 7.** L18 verlangt: jeder Schlüssel ist Kopfparameter oder Hook; jeder Hook heißt wie ein Kopfparameter, wie das Parameterwort eines Bausteins oder ist ein Kompositum daraus und hat nur Parameter, die der gezeichnete Baustein oder Kopfparameter auch hat. A.12 verletzt das mehrfach: (a) Hooks, die nichts davon sind: `background`, `setup`, `callout`, `material-heading` (`material` ist sprachgleich und steht nicht in `wortpaare.json`); `task-marker` und `solution-heading` sind seit der Neufassung von L18 als Komposita gedeckt; (b) Schlüssel, die weder Kopfparameter noch Hook sind: `name`, `margin`, `header-top`, `header-ascent`, `footer-descent`, `task-marker-width`; (c) Hook `task` bekommt `marker` und `points`, die der Baustein `aufgabe` so nicht hat, und `points` ist im Hook Inhalt, nach K 3/8 eine Zahl; (d) `footer: (duplex: true) => …` hat genau ein Argument, das nach K 4.4 Nr. 7 positional sein müsste; (e) `header` trägt drei Grundtypen (Kopfparameter: Inhalt; Theme-Schlüssel: Funktion; Anhang B/Glossar 81: Array) entgegen L6. Hier A.12 wörtlich übernommen.
8. **`header-top` doppelt belegt** (Zweifelsfall 2) und **`font-size` im Hook `header`** (Zweifelsfall 1).
9. **Wert für „keine Variantenvorschau"** bei `preview-variant` (alt `vorschau-alle: false`). Entschieden: `none`.
10. **`class: ""`** fehlt in der Liste der `""`-Felder von K 9.2. Entschieden nach K 5.2: `none`.
11. **Stubs mit verbotenen Zeichen oder Affixen** (Zweifelsfall 9): K 9.3 nimmt `src/removed.typ` von L1 und L27 aus; für L4 (`non-print-pagebreak`) fehlt die Ausnahme noch.
12. **Bedeutung von `theme: auto`** ist in K nicht ausgeschrieben. Entschieden: klassische Darstellung wie heute `none`; `theme: none` ist ein Fehler.
13. **`materials-pagebreak: "before"` und `solutions-pagebreak: "per-task"` sagen nicht, was der Code tut.** K 6 beschreibt `"before"` als „Seitenumbruch (weich) vor jedem Materialblock". Der Code setzt bei `materialien: "seiten"` (der Vorgabe) jedes Material mit `page(…)` auf eine eigene Seite, also Umbruch davor **und** danach (aufgaben.typ Z. 819–820, 1296); bei `"seite"` einen einzigen weichen Umbruch vor dem Materialteil (Z. 814–816). Ebenso `loesungen: "seiten"` = `page(…)` je Aufgabe (Z. 311–312). Hier entschieden: `"before"` bedeutet bei `"after-task"` „eigene Seite je Material", bei `"at-end"` „ein Umbruch vor dem Block"; `"per-task"` bedeutet „eigene Seite je Aufgabe". K 6 sollte den Wert so benennen (etwa `"own-page"`) oder die Beschreibung ändern. Bestätigt und damit erledigt: `"sofort"` und `"folgend"` sind bei Material gleich; `"1."` ist `numbering("1.1")`.
14. **Kein „heißt jetzt" für Variablen und Schlüsselstrings.** `print-state` ist ein State; ein übersehener Aufruf endet in Typsts `unknown variable`. Direkte Zugriffe `state("print"…)`, `state("options"…)` liefern nach dem Schlüsselwechsel still die Vorgabe. K 9.1/9.3 kennen nur Funktionsstubs; für beide Fälle bleibt nur der Codemod-Bericht (3.4).
15. **Der Paketname `luecke` trifft dokumenteigene Funktionen gleichen Namens** (32 Aufrufe, Zweifelsfall 11). K 9.3 regelt den Codemod (nur ohne dokumenteigenes `#let luecke`); die zweite Bedingung dieser Tabelle, „kein benanntes Argument außer `tight:`", steht dort nicht.
16. **Glossar 67 gegen L14.** Die Einheit heißt `unit`, die Funktion auch. Nötig: L14-Ausnahme für rein positionale Parameter (Zweifelsfall 8).
17. **K 6 gegen K 5.5 bei `luecke`** (Zweifelsfall 12): „folgt `has-solutions()`" ändert das PDF jeder Lösungsfassung.
18. **A.3 `align: left`** ist eine neue Vorgabe; heute gilt `auto` (erbt die Umgebung). Hier `auto` (K 5.5).
19. **Parameter `length` überdeckt den Typ `length`.** L13 erfasst nur Aufrufe `name(`, keine Typvergleiche; K 4.5 erlaubt Typst-Namen nur bei Durchreichung an einen Typst-Parameter, hier geht er an cetz. Nötig: K 4.5 auf Durchreichung an Fremdpakete erweitern, L13 auf Typnamen ausdehnen (`std.length` im Rumpf).
20. **A.9 verstößt gegen K 5.1 und L11.** `print: auto` und `solutions-visible: auto` sind dreiwertige Schalter; `auto` darf nach K 5.1 nur zu W3, W7, W8, W9 treten, `print` ist W1 und hat hier eine andere Form als im Kopf (L6/L7). `solutions-visible` beginnt mit einem Plural, `solutions` ist aber kein Parameter derselben Signatur (L11). Hier A.9 wörtlich übernommen. Zu entscheiden: K 5.1 um „W1 mit `auto` = egal" erweitern und L11 ausnehmen, oder eine Auswahl (W2) verwenden, die auch die alte Bedeutung „nur reine Lösungsfassung" trägt (Zweifelsfall 6).
21. **L9 (Vorgabe `()`/`(:)` verlangt Plural)** trifft `curriculum: ()` und den Hook-Parameter `margin: (:)`. Beide brauchen einen Eintrag in der L9-Ausnahmeliste (wie `points`), oder der Hook schreibt `margin` aus (`(top: 0cm, …)` wie im Theme-Schlüssel).
22. **K 9.3, Liste der abbrechenden Stubs:** `c_canvas` fehlt dort; `mono` kann keinen Stub bekommen. `arbeitsblatt-einzeln` braucht keinen mehr, weil der Name bleibt. Die Stub-Regel sollte „alle alten öffentlichen Funktionsnamen, deren Name sich ändert; Ausnahmen mit Sachgrund" lauten (4.3).
23. **K 9.2 kennt keine Regeln, die von der gepinnten Quellversion abhängen.** `header-font-size` braucht eine (1.1): umbenennen bis 0.0.7, löschen ab 0.1.0. Der Codemod muss die Quellversion aus der Importzeile lesen.
24. **Maß für `fremdnamen.txt`** (K 7.1) ist nicht festgelegt: `stickybox` (45 Aufrufe) steht drin, `slanted-colorbox` (52) und `colorbox` (48) nicht (Zweifelsfall 14).
25. **Abhilfe „selbst importieren" braucht eine Formvorschrift.** Ein eigener `: *`-Import von gentle-clues oder zero nach dem `@schule`-Import überdeckt still die 15 Kästen und `num`. K 7.1/K 11 Nr. 2 sollten vorschreiben: namentlich oder `as modul`.
26. **`kind`/`level` als W2 gegen den freien String `typ`** (Zweifelsfall 16): K A.1 nennt keine Regel für Werte außerhalb der vier.
27. **Erledigt durch die Entscheidung vom 2026-11-15.** `task` wäre der einzige alte Name gewesen, der mit neuer Bedeutung weiterlebt (gentle-clues-Kasten → Aufgabe). Es gibt keine Funktion `task`; der Kasten fällt wie `code` aus dem Namensraum, und ein übersehener Aufruf ist ein gewöhnlicher Typst-Fehler (1.18, K 7.1). Offen bleibt eine Berichtigung: K 7.1 begründet das Weglassen aus `fremdnamen.txt` mit „weil kein Bestand ihn belegt"; die Prüferzählung findet 1 Dokument. K 7.1 sollte „kein Bestand" in „1 Dokument (Prüferzählung)" berichtigen; die Regel selbst (kein Durchreichen, namentliche Importzeile) bleibt.
28. **K 9.3 lässt offen, was ein Stub mit Argumenten tut.** „Er nimmt keine Argumente an" hieße wörtlich, dass `print-pagebreak(loesungen-only: true)` mit Typsts „unexpected argument" endet statt mit „heißt jetzt". Der Stub sollte beliebige Argumente schlucken (`..args`) und dann mit der Standardmeldung abbrechen. Eine eigene Meldung für `loesungen-only` im Paket gäbe es nur, wenn `conditional-pagebreak` in A.9 ein `..deprecated` bekäme; hier nicht vorgesehen, der Hinweis steht im Codemod-Bericht (1.12, JSON `kontext`).

---

## 8. Maschinenlesbarer Anhang

Schlüssel in `parameter` und `werte` sind die **alten** Funktionsnamen, wie sie der Codemod im Dokument findet, mit vier Ausnahmen, die keine Funktionsnamen sind: `kasten` steht für die 15 Kastenfunktionen aus `gruppen.kasten` (der Codemod wendet die Einträge auf jeden dieser Namen an, also auf `info(headless: true)` ebenso wie auf `tip(accent-color: …)`); `varianten-overrides` und `punkte-dictionary` sind Dictionaries im Kopf; `theme-funktion` ist die Signatur eigener Theme-Funktionen. Das Feld `wie` sagt, welche Einträge für `arbeitsblatt-einzeln` und die Varianten-Overrides mitgelten (gleiche Schlüssel und Werte wie der Kopf). `funktionen` bildet auf die neuen Namen ab; ein Name steht dort auch dann, wenn er einen Stub bekommt (`stubs`). Deutsche Bausteine bilden auf sich selbst ab (`arbeitsblatt`, `arbeitsblatt-einzeln`, `lsg`, `teilaufgaben`) oder auf ihre Umschrift (`lücke` → `luecke`); das Feld `bausteine` führt beide Gruppen, damit der Codemod die Aufrufe der ersten nie anfasst. Englische Zwillinge und ein Feld `uebergangsnamen` gibt es nicht. Ein Zielwert `null` heißt „Argument löschen". Ein Objekt als Zielwert heißt „wird zu mehreren Argumenten". Namen mit Punkt (`internal.x`) sind intern. `hooks` führt die Parameternamen aus dem Quelltext (`n`, `lbl`); die Namen aus dem Kopfkommentar stehen in `hooks-doku-namen`. Einträge in `kontext` mit dem Feld `bedingung` gelten nur, wenn die Bedingung zutrifft (Quellversion aus der Importzeile). Die Zusatzfelder `bausteine`, `gruppen`, `wie`, `kontext`, `theme-schluessel`, `hooks`, `rueckgabe`, `states`, `labels`, `varianten`, `stubs`, `kein-stub`, `meta-schluessel`, `meta-werte`, `theme-vorgaben-heute`, `verhaltensaenderungen`, `reexporte-entfallen` ergänzen das geforderte Schema.

```json
{
  "funktionen": {
    "arbeitsblatt": "arbeitsblatt",
    "arbeitsblatt-einzeln": "arbeitsblatt-einzeln",
    "qr-code": "qr-code",
    "qty": "qty",
    "num": "num",
    "unit": "unit",
    "lücke": "luecke",
    "loesungsmodus": "has-solutions",
    "lsg": "lsg",
    "teilaufgaben": "teilaufgaben",
    "tasks": "teilaufgaben",
    "canvas": "canvas",
    "c_canvas": "internal.cetz-canvas",
    "print-pagebreak": "conditional-pagebreak",
    "non-print-pagebreak": "conditional-pagebreak",
    "minipage": "minipage",
    "icon-link": "icon-link",
    "qrbox": "qr-box",
    "workspace": "workspace",
    "abstract": "abstract",
    "info": "info",
    "question": "question",
    "memo": "memo",
    "conclusion": "conclusion",
    "tip": "tip",
    "success": "success",
    "warning": "warning",
    "error": "error",
    "example": "example",
    "goal": "goal",
    "idea": "idea",
    "experiment": "experiment",
    "notify": "notify",
    "danger": "danger",
    "themes": "themes",
    "fachfarben": "subject-accents",
    "fachnamen": "subject-names",
    "kasten-stil": "callout-style",
    "kuerzel": "internal.parse-class",
    "kicker": "internal.subject-line",
    "fachfarbe": "internal.class-accent",
    "_theme-aufloesen": "internal.resolve-theme",
    "_state_ab_scope": "internal.scope-state",
    "_klartext": "internal.plain-text",
    "_unify-einheit": "internal.normalize-unit",
    "_to-unify-str": "internal.to-unit-text",
    "_papier-masse": "internal.paper-sizes",
    "_papier-groesser": "internal.next-paper",
    "_umbrueche-zaehlen": "internal.count-pagebreaks",
    "_margin-aufloesen": "internal.resolve-margin",
    "_varianten-vorlagen": "internal.variant-presets",
    "_varianten-aufloesen": "internal.resolve-variants",
    "_vorschau-alle-aktiv": "internal.preview-all-requested",
    "_kasten-titel": "internal.callout-titles",
    "_kasten-original": "internal.callout-classic",
    "_kasten": "internal.callout",
    "_kasten-stil": "internal.callout-style-table",
    "_aussen": "internal.outside-aligned",
    "_seitenrand": "internal.side-margins",
    "_marke": "internal.badge",
    "_schatten-box": "internal.shadow-box",
    "_schatten-block": "internal.shadow-block",
    "_loesung-inline": "internal.solution-inline",
    "_gruen": "internal.palette.green",
    "_gelb": "internal.palette.yellow",
    "_orange": "internal.palette.orange",
    "_rot": "internal.palette.red",
    "_violett": "internal.palette.violet",
    "_tuerkis": "internal.palette.teal",
    "themes.klar": "themes.klar",
    "themes.atlas": "themes.atlas",
    "themes.skizze": "themes.skizze",
    "themes.labor": "themes.labor",
    "themes.kontur": "themes.kontur",
    "themes.leiste": "themes.leiste",
    "themes.riso": "themes.riso",
    "themes.bauhaus": "themes.bauhaus"
  },
  "parameter": {
    "arbeitsblatt": {
      "title": "title",
      "class": "class",
      "paper": "paper",
      "print": "print",
      "duplex": "duplex",
      "workspaces": "workspaces",
      "theme": "theme",
      "akzent": "accent",
      "font-size": "font-size",
      "font": "font",
      "math-font": "math-font",
      "title-font-size": "title-font-size",
      "figure-font-size": "figure-font-size",
      "landscape": "landscape",
      "custom-header": "header",
      "teilaufgabe-numbering": "subtask-numbering",
      "page-settings": "page-settings",
      "loesungen": "solutions",
      "materialien": "materials",
      "punkte": "points",
      "aufgaben-shortcodes": "shortcodes",
      "copyright": "copyright-url",
      "zweifach": "two-up",
      "varianten": "variants",
      "vorschau-alle": "preview-variant",
      "dateiname": "filename",
      "fach": "subject",
      "thema": "topic",
      "jahrgang": "years",
      "stufe": "stage",
      "niveau": "level",
      "typ": "kind",
      "stichworte": "keywords",
      "kerncurriculum": "curriculum",
      "stand": "revision",
      "header-ascent": "page-settings.header-ascent",
      "body": "body"
    },
    "arbeitsblatt-einzeln": {
      "title": "title",
      "class": "class",
      "paper": "paper",
      "print": "print",
      "duplex": "duplex",
      "workspaces": "workspaces",
      "theme": "theme",
      "akzent": "accent",
      "font-size": "font-size",
      "font": "font",
      "math-font": "math-font",
      "title-font-size": "title-font-size",
      "figure-font-size": "figure-font-size",
      "landscape": "landscape",
      "custom-header": "header",
      "teilaufgabe-numbering": "subtask-numbering",
      "page-settings": "page-settings",
      "loesungen": "solutions",
      "materialien": "materials",
      "punkte": "points",
      "aufgaben-shortcodes": "shortcodes",
      "copyright": "copyright-url",
      "zweifach": "two-up",
      "scope": "scope",
      "fach": "subject",
      "thema": "topic",
      "jahrgang": "years",
      "stufe": "stage",
      "niveau": "level",
      "typ": "kind",
      "stichworte": "keywords",
      "kerncurriculum": "curriculum",
      "stand": "revision",
      "header-ascent": "page-settings.header-ascent",
      "body": "body"
    },
    "varianten-overrides": {
      "datei": "path"
    },
    "punkte-dictionary": {
      "anzeige": "points",
      "position": "points-position"
    },
    "qr-code": {
      "light-color": "background-fill",
      "background": "background-fill",
      "dark-color": "fill",
      "width": "width",
      "quiet-zone": "quiet-zone"
    },
    "qty": {
      "per": "per"
    },
    "unit": {
      "<1. Positionsargument>": "units",
      "per": "per"
    },
    "lücke": {
      "tight": "tight",
      "body": "body"
    },
    "lsg": {
      "platz": "reserve",
      "sonst": "fallback",
      "body": "body"
    },
    "teilaufgaben": {
      "tasks": "items",
      "loesungen": "item-solutions",
      "columns": "columns",
      "numbering": "numbering",
      "gutter": "gutter",
      "align": "align",
      "inset": "inset"
    },
    "canvas": {
      "length": "length",
      "padding": "padding",
      "body": "body"
    },
    "print-pagebreak": {
      "loesungen-only": "solutions-visible"
    },
    "non-print-pagebreak": {
      "loesungen-only": "solutions-visible"
    },
    "minipage": {
      "columns": "columns",
      "align": "align",
      "spacing": "gutter",
      "inset": "inset"
    },
    "icon-link": {
      "url": "url",
      "name": "body",
      "icon": "icon",
      "color": "fill"
    },
    "qrbox": {
      "url": "url",
      "name": "body",
      "width": "width",
      "rotation": "rotation"
    },
    "workspace": {
      "body": "body"
    },
    "kasten": {
      "title": "title",
      "headless": "title",
      "accent-color": "accent",
      "breakable": "breakable",
      "width": "width"
    },
    "kasten-stil": {
      "art": "kind",
      "akzent": "worksheet-accent",
      "farbe": "accent"
    },
    "theme-funktion": {
      "akzent": "accent",
      "class": "class"
    },
    "_theme-aufloesen": {
      "theme": "theme",
      "akzent": "accent",
      "class": "class"
    },
    "_aussen": {
      "duplex": "duplex",
      "inhalt": "format"
    },
    "_seitenrand": {
      "m": "margin",
      "n": "page-number"
    },
    "_marke": {
      "inhalt": "body",
      "breite": "width",
      "farbe": "text-fill"
    },
    "_schatten-box": {
      "inhalt": "body",
      "versatz": "distance",
      "farbe": "fill"
    },
    "_schatten-block": {
      "inhalt": "body",
      "versatz": "distance",
      "farbe": "fill"
    },
    "_loesung-inline": {
      "titel": "title",
      "label-stil": "marker-style",
      "body": "body"
    },
    "_kasten": {
      "art": "kind"
    },
    "arbeitsblatt-einzeln.header (innere Funktion)": {
      "title": "title",
      "class": "class",
      "font-size": "font-size",
      "copyright": "copyright-url"
    }
  },
  "gruppen": {
    "kasten": [
      "abstract",
      "info",
      "question",
      "memo",
      "conclusion",
      "tip",
      "success",
      "warning",
      "error",
      "example",
      "goal",
      "idea",
      "experiment",
      "notify",
      "danger"
    ]
  },
  "wie": {
    "parameter.arbeitsblatt-einzeln": "parameter.arbeitsblatt ohne varianten, vorschau-alle, dateiname; dazu scope",
    "werte.arbeitsblatt-einzeln.*": "werte.arbeitsblatt.*",
    "parameter.varianten-overrides": "parameter.arbeitsblatt-einzeln ohne scope; dazu datei -> path",
    "werte.varianten-overrides.*": "werte.arbeitsblatt.*"
  },
  "werte": {
    "arbeitsblatt.title": {
      "\"\"": null,
      "[]": null
    },
    "arbeitsblatt.class": {
      "\"\"": null
    },
    "arbeitsblatt.theme": {
      "none": null,
      "\"standard\"": null
    },
    "arbeitsblatt.custom-header": {
      "none": null
    },
    "arbeitsblatt.loesungen": {
      "\"false\"": null,
      "\"keine\"": null,
      "false": null,
      "none": null,
      "\"sofort\"": "\"in-place\"",
      "\"folgend\"": "\"after-task\"",
      "\"reinquetschen\"": "\"at-end\"",
      "\"seite\"": {
        "solutions": "\"at-end\"",
        "solutions-pagebreak": "\"before\""
      },
      "\"seiten\"": {
        "solutions": "\"at-end\"",
        "solutions-pagebreak": "\"per-task\""
      },
      "\"nur\"": "\"only\""
    },
    "arbeitsblatt.materialien": {
      "\"seiten\"": null,
      "\"keine\"": "none",
      "\"false\"": "none",
      "false": "none",
      "none": "none",
      "\"sofort\"": {
        "materials": "\"after-task\"",
        "materials-pagebreak": "none"
      },
      "\"folgend\"": {
        "materials": "\"after-task\"",
        "materials-pagebreak": "none"
      },
      "\"reinquetschen\"": {
        "materials": "\"at-end\"",
        "materials-pagebreak": "none"
      },
      "\"seite\"": "\"at-end\""
    },
    "arbeitsblatt.punkte": {
      "\"keine\"": null,
      "\"aufgaben\"": "\"tasks\"",
      "\"teilaufgaben\"": "\"subtasks\"",
      "\"alle\"": "\"all\"",
      "\"keine-summe\"": {
        "points": "\"all\"",
        "points-total": "false"
      }
    },
    "arbeitsblatt.punkte.anzeige": {
      "\"keine\"": "none",
      "\"aufgaben\"": "\"tasks\"",
      "\"teilaufgaben\"": "\"subtasks\"",
      "\"alle\"": "\"all\"",
      "\"keine-summe\"": {
        "points": "\"all\"",
        "points-total": "false"
      }
    },
    "arbeitsblatt.punkte.position": {
      "\"ende\"": "\"end\"",
      "\"rand\"": "\"margin\""
    },
    "arbeitsblatt.aufgaben-shortcodes": {
      "\"teilaufgaben\"": null,
      "\"keine\"": "none",
      "\"aufgaben\"": "\"tasks\"",
      "\"alle\"": "\"all\""
    },
    "arbeitsblatt.teilaufgabe-numbering": {
      "\"1.\"": "\"1.1\""
    },
    "arbeitsblatt.varianten": {
      "\"druck\"": "\"print\"",
      "\"digital\"": "\"digital\"",
      "\"loesung\"": "\"solutions\"",
      "\"zweifach\"": "\"two-up\""
    },
    "arbeitsblatt.vorschau-alle": {
      "true": null,
      "false": "none"
    },
    "arbeitsblatt.niveau": {
      "\"einfuehrung\"": "\"introduction\"",
      "\"vertiefung\"": "\"consolidation\"",
      "\"ea\"": "\"ea\"",
      "\"ga\"": "\"ga\""
    },
    "arbeitsblatt.typ": {
      "\"arbeitsblatt\"": "\"worksheet\"",
      "\"uebung\"": "\"practice\"",
      "\"stationsarbeit\"": "\"stations\"",
      "\"klausur\"": "\"exam\""
    },
    "arbeitsblatt.stufe": {
      "\"sek-1\"": "\"sek-1\"",
      "\"sek-2\"": "\"sek-2\""
    },
    "qr-code.light-color": {
      "white.transparentize(100%)": null
    },
    "print-pagebreak.loesungen-only": {
      "false": null
    },
    "non-print-pagebreak.loesungen-only": {
      "false": null
    },
    "kasten.headless": {
      "true": "none",
      "false": null
    }
  },
  "kontext": [
    {
      "alt": "arbeitsblatt(custom-header: none)",
      "regel": "Argument löschen"
    },
    {
      "alt": "arbeitsblatt(custom-header: X)",
      "regel": "header: X"
    },
    {
      "alt": "arbeitsblatt(header-ascent: X)",
      "regel": "page-settings: (header-ascent: X), in vorhandenes Dictionary einfügen"
    },
    {
      "alt": "arbeitsblatt(punkte: (anzeige: A, position: P))",
      "regel": "points: A', points-position: P'; fehlt anzeige: points: \"tasks\""
    },
    {
      "alt": "arbeitsblatt(varianten: \"x\")",
      "regel": "variants: (\"x'\",)"
    },
    {
      "alt": "arbeitsblatt(varianten: (n: (..), m: (:)))",
      "regel": "variants: (\"n'\", \"m'\"), variant-overrides: (n': (..')); leere Overrides weglassen; Override-Schlüssel und -Werte wie arbeitsblatt"
    },
    {
      "alt": "print-pagebreak(..)",
      "regel": "conditional-pagebreak(print: true, ..)"
    },
    {
      "alt": "non-print-pagebreak(..)",
      "regel": "conditional-pagebreak(print: false, ..)"
    },
    {
      "alt": "print-state.get()",
      "regel": "is-print()"
    },
    {
      "alt": "teilaufgaben[+ a + b]",
      "regel": "teilaufgaben(items: ([a], [b])); nur bei wörtlicher Aufzählung, sonst Bericht"
    },
    {
      "alt": "kasten(headless: true, title: X)",
      "regel": "title: none"
    },
    {
      "alt": "workspace(height: X)[..]",
      "regel": "height löschen"
    },
    {
      "alt": "qr-code(alt: X)",
      "regel": "alt löschen"
    },
    {
      "alt": "theme: (akzent, class) => ..",
      "regel": "Bericht: (accent: auto, class: none) => .., Schlüssel nach theme-schluessel"
    },
    {
      "alt": "arbeitsblatt(header-font-size: X)",
      "bedingung": "gepinnte Quellversion 0.0.2–0.0.7",
      "regel": "title-font-size: X"
    },
    {
      "alt": "arbeitsblatt(header-font-size: X)",
      "bedingung": "gepinnte Quellversion 0.1.0–0.3.2",
      "regel": "Argument löschen (war wirkungslos); Bericht, wenn X != 16pt"
    },
    {
      "alt": "arbeitsblatt(subtitle: X | erwartungen: X | klausurboegen: X)",
      "bedingung": "gepinnte Quellversion < 0.4.0",
      "regel": "Argument löschen (war wirkungslos); Bericht mit Hinweis auf klassenarbeit"
    },
    {
      "alt": "arbeitsblatt(typ: X | niveau: X)",
      "bedingung": "X nicht in werte",
      "regel": "Bericht, keine Abbildung"
    },
    {
      "alt": "lücke(..)",
      "bedingung": "kein eigenes #let lücke und kein eigenes #let luecke im Dokument; kein benanntes Argument außer tight",
      "regel": "luecke(..); immer Bericht (Lösungsfassung ändert sich)"
    },
    {
      "alt": "lücke(length: .. | len: ..)",
      "regel": "nicht anfassen (dokumenteigene Funktion); Bericht"
    },
    {
      "alt": "lücke(..)",
      "bedingung": "Dokument definiert #let luecke selbst",
      "regel": "nicht umbenennen (das Ziel wäre die dokumenteigene Funktion); Bericht"
    },
    {
      "alt": "luecke(..), lueck(..)",
      "regel": "nie anfassen (vorhandene Aufrufe gehören dokumenteigenen Funktionen; luecke war vor der Zielversion kein Paketname)"
    },
    {
      "alt": "mono(X) | mono[X]",
      "bedingung": "Code- oder Markup-Modus, nicht in Formeln; kein eigenes #let mono; kein direkter Import von @schule/informatik",
      "regel": "text(font: \"SF Mono\", X) | text(font: \"SF Mono\")[X]"
    },
    {
      "alt": "task(..) | task[..]",
      "bedingung": "Name kommt über @schule herein (gentle-clues-Kasten); kein eigenes #let task",
      "regel": "#import \"@preview/gentle-clues:1.2.0\": task einfügen; Bericht"
    },
    {
      "alt": "code(..)",
      "bedingung": "Name kommt über @schule herein",
      "regel": "#import \"@preview/gentle-clues:1.2.0\": code einfügen"
    },
    {
      "alt": "colorbox(..) | slanted-colorbox(..) | colorbox-rounded(..) | outline-colorbox(..)",
      "bedingung": "kein eigener Import von colorful-boxes",
      "regel": "#import \"@preview/colorful-boxes:1.4.3\": <benutzte Namen> einfügen"
    },
    {
      "alt": "#import \"@preview/gentle-clues…\": * | #import \"@preview/zero…\": *",
      "bedingung": "steht nach dem @schule-Import",
      "regel": "Bericht: überdeckt die 15 Kästen bzw. num; namentlich oder als Modul importieren"
    },
    {
      "alt": "state(\"print\"..).get()",
      "regel": "is-print()"
    },
    {
      "alt": "state(\"options\"..).get().at(\"loesungen\"..)",
      "regel": "Bericht mit Hinweis auf has-solutions()"
    },
    {
      "alt": "print-state.update(..)",
      "regel": "Bericht"
    },
    {
      "alt": "state(\"print\" | \"options\" | \"ab-scope\" | \"ab-theme\"..) in jeder anderen Form",
      "regel": "Bericht"
    },
    {
      "alt": "print-pagebreak(loesungen-only: true) | non-print-pagebreak(loesungen-only: true)",
      "regel": "nicht anfassen (alter Funktionsname und Argument bleiben stehen, der Stub bricht mit der Standardmeldung ab); Bericht mit dem Hinweis, dass solutions-visible: true für jede sichtbare Lösung gilt (Bedeutung nicht abbildbar)"
    },
    {
      "alt": "minipage(columns: N, ..) mit mehr Zellen als Spalten",
      "regel": "spacing -> gutter; Bericht (Zeilenabstand künftig = gutter)"
    },
    {
      "alt": "info() ohne Inhalt (alle 15 Kästen)",
      "regel": "Bericht (body ist Pflicht)"
    }
  ],
  "theme-schluessel": {
    "name": "name",
    "schrift": null,
    "schrift.text": "font",
    "schrift.mathe": "math-font",
    "schrift.groesse": "font-size",
    "schrift.titel": "title-font-size",
    "rand": "margin",
    "rand.top": "margin.top",
    "rand.bottom": "margin.bottom",
    "rand.innen": "margin.inside",
    "rand.aussen": "margin.outside",
    "rand.kopf-oben": "header-top",
    "header-ascent": "header-ascent",
    "footer-descent": "footer-descent",
    "kopf": "header",
    "fuss": "footer",
    "hintergrund": "background",
    "marke": "task-marker",
    "marke-breite": "task-marker-width",
    "aufgabe": "task",
    "teilaufgabe": "subtask",
    "loesung": "solution",
    "loesung-kopf": "solution-heading",
    "material-kopf": "material-heading",
    "kasten": "callout",
    "setup": "setup"
  },
  "hooks": {
    "kopf": {
      "title": "title",
      "class": "class",
      "copyright": "copyright-url",
      "font-size": "font-size"
    },
    "fuss": {
      "duplex": "duplex"
    },
    "hintergrund": {
      "print": "print",
      "oben": "header-top",
      "rand": "margin"
    },
    "marke": {
      "n": "task-number"
    },
    "aufgabe": {
      "nummer": "marker",
      "number": "marker",
      "titel": "title",
      "icons": "icons",
      "punkte": "points",
      "large": "large"
    },
    "teilaufgabe": {
      "lbl": "marker"
    },
    "loesung": {
      "titel": "title",
      "body": "body"
    },
    "loesung-kopf": {
      "titel": "title"
    },
    "material-kopf": {
      "titel": "title"
    },
    "kasten": {
      "art": "kind",
      "titel": "title",
      "farbe": "accent",
      "breakable": "breakable",
      "width": "width",
      "body": "body"
    },
    "setup": {
      "body": "body"
    }
  },
  "rueckgabe": {
    "kasten-stil": {
      "icon": "icon-name",
      "farbe": "accent"
    },
    "kuerzel": {
      "fach": "subject",
      "name": "name",
      "jahrgang": "year"
    }
  },
  "states": {
    "print": "schule/aufgaben/print@1",
    "ab-scope": "schule/arbeitsblatt/scope@1",
    "options": "schule/aufgaben/options@1",
    "ab-theme": "schule/aufgaben/theme@1"
  },
  "options-state": {
    "loesungen": [
      "solutions",
      "solutions-pagebreak"
    ],
    "materialien": [
      "materials",
      "materials-pagebreak"
    ],
    "workspaces": [
      "workspaces"
    ],
    "punkte": [
      "points",
      "points-total",
      "points-position"
    ],
    "punkte-position": [
      "points-position"
    ],
    "punkte-template-aufgabe": [
      "points-format"
    ],
    "punkte-template-teilaufgabe": [
      "points-format"
    ],
    "teilaufgabe-numbering": [
      "subtask-numbering"
    ]
  },
  "labels": {
    "ab-meta": "ab-meta",
    "_ab-start-{scope}": "schule-arbeitsblatt-start-{scope}",
    "_ab-ende-{scope}": "schule-arbeitsblatt-end-{scope}",
    "_zweifach-oben": "schule-arbeitsblatt-two-up-top",
    "_zweifach-ende": "schule-arbeitsblatt-two-up-end"
  },
  "varianten": {
    "druck": {
      "name": "print",
      "endung": "druck",
      "overrides": {
        "print": "true"
      }
    },
    "digital": {
      "name": "digital",
      "endung": "digital",
      "overrides": {
        "print": "false"
      }
    },
    "loesung": {
      "name": "solutions",
      "endung": "loesung",
      "overrides": {
        "print": "true",
        "solutions": "\"only\"",
        "workspaces": "false"
      }
    },
    "zweifach": {
      "name": "two-up",
      "endung": "zweifach",
      "overrides": {
        "print": "true",
        "two-up": "true"
      }
    }
  },
  "bausteine": {
    "unveraendert": [
      "arbeitsblatt",
      "arbeitsblatt-einzeln",
      "lsg",
      "teilaufgaben"
    ],
    "umschrift": {
      "lücke": "luecke"
    }
  },
  "stubs": {
    "lücke": "luecke",
    "loesungsmodus": "has-solutions",
    "tasks": "teilaufgaben",
    "print-pagebreak": "conditional-pagebreak(print: true)",
    "non-print-pagebreak": "conditional-pagebreak(print: false)",
    "qrbox": "qr-box",
    "c_canvas": "gibt es nicht mehr – cetz.canvas"
  },
  "kein-stub": {
    "print-state": "Variable, kein Aufruf",
    "mono": "überdeckte math.mono und informatik.mono"
  },
  "entfernt": [
    "print-state",
    "mono",
    "qr-code.alt",
    "qr-code.<übrige zebra-Argumente>",
    "qty.<unify-Argumente außer per>",
    "num.<unify-Argumente>",
    "unit.<unify-Argumente außer per>",
    "workspace.height",
    "teilaufgaben.<Enum-Inhalt positional>",
    "teilaufgaben.row-gutter",
    "teilaufgaben.<übrige table-Argumente>",
    "minipage.<table-Argumente außer inset>",
    "qrbox.<stickybox-Argumente außer rotation>",
    "canvas.<cetz-Argumente außer length, padding>",
    "kasten.icon",
    "kasten.<übrige gentle-clues-Argumente>",
    "kasten-art.task",
    "kasten-art.code",
    "arbeitsblatt.theme=\"standard\"",
    "arbeitsblatt.<Sink außer header-ascent>",
    "arbeitsblatt.subtitle",
    "arbeitsblatt.erwartungen",
    "arbeitsblatt.klausurboegen",
    "theme.schrift",
    "_named-with-default-per",
    "_gc",
    "qr-code-zebra",
    "add-unit",
    "unify-num",
    "unify-qty",
    "unify-unit",
    "options-state.print",
    "arbeitsblatt.header-font-size (Quelle 0.1.0–0.3.2)"
  ],
  "reexporte-entfallen": [
    "aufgaben:* außer den namentlich durchgereichten Zielnamen (entfallen u. a.: show-loesung, show-loesung-inline, show-offene-loesungen, show-material, show-bewertung, get-punkte-anzeige, get-punkte-position, _theme-hook, _zusammen, _loesung-kasten, _state_* (11), _counter_aufgaben, _be-runden, _be-anzeige, _aufgaben-final, _rechter-textrand, _erwartungen-zeilen, _ist-flex-workspace, _flex-fest)",
    "insert-a-word:* außer insert-a-word, iaword, reset-iaword (entfallen: iaword-list, iaword-solution, iaword-counter, iaword-uniform, iaword-start, iaword-show, iaword-neu)",
    "cetz:* außer canvas, draw",
    "cetz-plot:* außer plot",
    "codly:*",
    "colorful-boxes:* außer stickybox (colorbox, slanted-colorbox, colorbox-rounded, outline-colorbox, showybox, box-colors)",
    "fontawesome:* außer fa-icon",
    "zero:*",
    "eqalc:*",
    "gentle-clues:* (auch task, code, clue, quotation; task und code bekommen eine namentliche Importzeile)",
    "zebra: qr-code-zebra",
    "unify: add-unit, unify-num, unify-qty, unify-unit",
    "random: a, m, lcg, low_cminstd_rand, low_cminstd_randint, step_seed, fisher_yates_shuffle",
    "energy-sketch: canvas, draw",
    "physik: zap, source, simple-source, multimeter, lamp, amperemeter, voltmeter, motor, generator",
    "informatik: blockst, scratch, set-blockst, blockst-run-options, set-scratch-run, scratch-run, mono, häufigkeitsanalyse-alt",
    "mathematik: teilaufgaben, tasks (waren schon ausgeschlossen)"
  ],
  "hooks-doku-namen": {
    "marke": {
      "nummer": "n"
    },
    "teilaufgabe": {
      "label": "lbl"
    }
  },
  "varianten-pfad": {
    "datei": "[<filename>-]<endung>.pdf",
    "scope": "[<filename>-]<name neu>",
    "kopplung": "klassenarbeit.typ Z. 319: variante == \"loesung\" -> \"solutions\""
  },
  "meta-schluessel": {
    "title": "titel",
    "class": "klasse",
    "subject": "fach",
    "topic": "thema",
    "years": "jahrgang",
    "stage": "stufe",
    "level": "niveau",
    "kind": "typ",
    "keywords": "stichworte",
    "curriculum": "kerncurriculum",
    "revision": "stand"
  },
  "meta-werte": {
    "title": {
      "none": "\"\""
    },
    "class": {
      "none": "\"\""
    },
    "level": {
      "\"introduction\"": "\"einfuehrung\"",
      "\"consolidation\"": "\"vertiefung\"",
      "\"ea\"": "\"ea\"",
      "\"ga\"": "\"ga\""
    },
    "kind": {
      "\"worksheet\"": "\"arbeitsblatt\"",
      "\"practice\"": "\"uebung\"",
      "\"stations\"": "\"stationsarbeit\"",
      "\"exam\"": "\"klausur\""
    }
  },
  "theme-vorgaben-heute": {
    "schrift.text": "\"Myriad Pro\"",
    "schrift.mathe": "\"Fira Math\"",
    "schrift.groesse": "12pt",
    "schrift.titel": "16pt",
    "rand.top": "2.3cm bei print, sonst 2.2cm",
    "rand.bottom": "1cm",
    "rand.innen": "2.25cm",
    "rand.aussen": "1.25cm",
    "rand.kopf-oben": "1.2cm",
    "header-ascent": "0.8cm (Randberechnung) / 20% (set page, zweifach); künftig ein Wert",
    "footer-descent": "30%",
    "marke-breite": "2.2em"
  },
  "verhaltensaenderungen": [
    "luecke: zeigt mit sichtbaren Lösungen den Inhalt (lücke versteckte immer)",
    "minipage: gutter gilt für Spalten und Zeilen (spacing nur für Spalten)",
    "conditional-pagebreak: solutions-visible gilt für jede sichtbare Lösung (loesungen-only nur für \"nur\")",
    "arbeitsblatt: two-up mit paper \"a3\" ist ein Fehler (bisher stiller A4-Bogen)",
    "arbeitsblatt: kind und level sind geprüfte Auswahlen (bisher freie Strings)",
    "Kästen: body ist immer Pflicht (mit Theme bisher optional)",
    "header-ascent: eine Vorgabe für Randberechnung und set page (betrifft nur eigene Theme-Dictionaries ohne den Schlüssel)"
  ]
}
```

---

## 9. Prüfprotokoll

Zwei Prüfer (Vollständigkeit, Regeltreue) haben die erste Fassung adversarial geprüft: 34 Befunde. Jeder wurde gegen Quelltext und Inventar nachgeprüft. Ergebnis: 33 übernommen, 1 im Kern verworfen (R12, Teil übernommen). Zahlen aus dem Bestand außerhalb des Repos, die nur die Prüfer erhoben haben, sind im Text als „Prüferzählung" markiert; sie wurden hier nicht nachgezählt. `konvention.md` wurde bei dieser Prüfung nicht geändert (die Neufassung vom 2026-11-15 ist im Abschnitt „Entscheidung deutsche Bausteine eingearbeitet" unten berücksichtigt); was die Konvention selbst betrifft, steht in Abschnitt 7 (Lücken 13–28).

### Prüfer Vollständigkeit

| Nr. | Befund (kurz) | Ergebnis | Begründung in einem Satz |
|---|---|---|---|
| V1 | `header-font-size` → `title-font-size` ist nicht wertgleich | übernommen | Am Repo bestätigt (Parameter nur in 0.0.2–0.0.7, danach im Sink verschluckt): Regel jetzt nach Quellversion, `subtitle`/`erwartungen`/`klausurboegen` werden gelöscht statt von Hand bearbeitet (1.1, 5 Nr. 39, JSON `kontext`). |
| V2 | JSON-Schlüssel `kasten` u. a. sind keine Funktionsnamen; Werte für `arbeitsblatt-einzeln` und Overrides fehlen | übernommen | Felder `gruppen` und `wie` ergänzt, Vorbemerkung berichtigt. |
| V3 | Alte Vorgaben der Theme-Schlüssel fehlen; `header-ascent` hat zwei Vorgaben | übernommen | Spalte „Vorgabe heute" in 2.3 mit Fundstellen, `auto`-Auflösung in 1.1, Altlast 5 Nr. 37 und Zweifelsfall 15. |
| V4 | `lücke`: dokumenteigene Neudefinitionen (`length:`, `len:`) und belegter Name `luecke` | übernommen | Inventar bestätigt (Z. 245–246, 275): Codemod jetzt „Kontext + Bericht", vorhandene `luecke(`-Aufrufe werden nie angefasst (1.7, Zweifelsfall 11). |
| V5 | `materialien`/`loesungen`: [prüfen] entscheidbar; `"before"` deckt zwei Wirkungen | übernommen | Am Code bestätigt (aufgaben.typ Z. 304–312, 814–820, 1076, 1290–1296): [prüfen] gestrichen, Wirkung je Lage festgeschrieben, Lücke 13. |
| V6 | `<ab-meta>`: `none` statt `""`, Abbildung unvollständig | übernommen | Tabelle `internal.meta-keys` mit 11 Paaren und Rückabbildung in 3.5, `none` wird als `""` geschrieben, JSON `meta-schluessel`/`meta-werte`. |
| V7 | Entfallende Re-Exporte unvollständig (aufgaben, insert-a-word, zebra, unify, mathematik) | übernommen | Zeilen in 4.5 und JSON-Liste ergänzt (Importe `ab.typ` Z. 1, 3 bestätigt). |
| V8 | Hook `kopf`: Bereich `20pt…27pt` falsch | übernommen | themes.typ Z. 557: labor hat 18pt; jetzt „18pt…27pt" mit allen acht Werten. |
| V9 | `zweifach` mit `"a3"` ist heute kein Fehler | übernommen | Z. 526, 859 bestätigt (stiller Rückfall auf A4); 3.2 berichtigt, Altlast 5 Nr. 38. |
| V10 | JSON: innere Widersprüche (`tasks`, `hook.aufgabe.number`, Palette, Hook-Parameternamen, interne Helfer) | übernommen | `tasks` nur noch in `funktionen` und `stubs`, Palette abgebildet, Hooks mit `n`/`lbl`, Parameter der internen Helfer ergänzt, Theme-Funktionen aufgenommen. |
| V11 | `_aussen` und `doppelt`: Rückruffunktionen als `body` wiedergegeben | übernommen | themes.typ Z. 124, 902–905 bestätigt; jetzt `format` bzw. `draw`. |
| V12 | `align: left` ist neue Vorgabe; Kasten-`body` heute mit Theme optional | übernommen | `align: auto` (Abweichung von A.3 als Lücke 18 gemeldet); Pflicht-`body` als Änderung vermerkt (1.18, 5 Nr. 42). |
| V13 | Ausgabedatei ohne `filename`, Scope-Kennung, Kopplung klassenarbeit | übernommen | `[<filename>-]druck.pdf`, Endung im JSON ohne Bindestrich, Scope aus dem neuen Namen, klassenarbeit Z. 319 genannt (3.3, Zweifelsfall 17). |

### Prüfer Regeltreue

| Nr. | Befund (kurz) | Ergebnis | Begründung in einem Satz |
|---|---|---|---|
| R1 | `header-font-size` verletzt „gleiches PDF" | übernommen | Deckungsgleich mit V1; Laufzeitmeldung wörtlich aufgenommen. |
| R2 | Druckmodus widerspricht `tabelle-aufgaben.md` | übernommen | Fassung der aufgaben-Tabelle übernommen (eigener State `"schule/aufgaben/print@1"`, `print` nicht im Options-State): 1.5, 3.1, 3.4, 5 Nr. 11, Lücke 1, JSON. |
| R3 | Abhilfe „gentle-clues/zero selbst importieren" überdeckt bei `: *` die neuen Namen | übernommen | Namentliche Importzeilen vorgeschrieben, Codemod-Bericht warnt (1.18, 4.5, Lücke 25); `task` in gentle-clues 1.2.0 am Paket bestätigt. |
| R4 | Stub `mono` überdeckt `math.mono`, 136 Aufrufe, Codemod möglich | übernommen | Kein Stub, Codemod „ja" mit wörtlicher Ersetzung (Definition Z. 1475 bestätigt), nur außerhalb von Formeln. |
| R5 | `lücke` → `luecke` (damals unter dem Zielnamen `blank` geprüft) ändert jede Lösungsfassung | übernommen | `hide(body)` in jedem Modus bestätigt; als Verhaltensänderung mit „Kontext + Bericht" geführt, weil K 6 `luecke` ausdrücklich nennt; Alternative „immer verstecken" als Frage an den Autor (Zweifelsfall 12, Lücke 17). |
| R6 | `loesungen-only: true` ist nicht bedeutungsgleich abbildbar | übernommen | `true` wird nicht mehr automatisch abgebildet, 5 Stellen im Bericht (1.12, JSON `werte` und `kontext`). |
| R7 | Signatur von `conditional-pagebreak` verstößt gegen K 5.1 und L11 | übernommen | Als Lücke 20 gemeldet; Signatur bleibt wörtlich A.9, weil die Konvention hier nicht geändert wird. |
| R8 | Direkte State-Zugriffe über Schlüsselstrings | übernommen | Codemod-Regeln und Berichtsfälle in 1.5, 3.4 und JSON `kontext`; Lücke 14. |
| R9 | colorful-boxes: falsche Namen, 100 brechende Aufrufe | übernommen | Exportliste am Paket 1.4.3 bestätigt; 4.5 berichtigt, Codemod fügt die Importzeile ein (Zweifelsfall 14). |
| R10 | `materials-pagebreak: "before"` = eigene Seite | übernommen | Deckungsgleich mit V5; Wirkung festgeschrieben, K 6 als Lücke 13 gemeldet. |
| R11 | `task` lebt still mit neuer Bedeutung weiter | übernommen; seit 2026-11-15 gegenstandslos | Es gibt keine Funktion `task` mehr; der gentle-clues-Kasten fällt wie `code` aus dem Namensraum und bekommt eine namentliche Importzeile (1.18, Lücke 27). |
| R12 | Übergangsname `luecke` streichen; Stub-Regel einheitlich | verworfen (Kern), Teil übernommen; seit 2026-11-15 überholt | Damals: Streichen geht nicht, K 9.3 schrieb den Übergangsnamen vor, und „0 Aufrufe im Bestand" stimmt nicht (Inventar: 32 Aufrufe einer dokumenteigenen Funktion); übernommen sind die einheitliche Stub-Regel samt `c_canvas` und die Meldung als Lücke 15. Heute ist `luecke` kein Übergangsname, sondern der Bausteinname (Zweifelsfall 11). |
| R13 | Parameter `length` überdeckt den Typ `length` | übernommen | Pflicht `std.length` im Rumpf in 1.11, Lücke 19. |
| R14 | `qty`/`unit`: L14, zwei Wörter für die Einheit, Zahlen, `fraction` | übernommen | Beide Male `unit` (positional), Konflikt als Lücke 16, Prüferzahlen eingetragen, `fraction` in Lücke 4; `thousandsep` bleibt Frage an den Autor. |
| R15 | `sheet-accent` benutzt das Bogen-Wort | übernommen | Jetzt `worksheet-accent` (Parameterwort nach K 2.1b; K 3/1 gegen K 3/12 bestätigt). |
| R16 | `minipage`: `spacing` → `gutter` ist nicht wirkungsgleich | übernommen | Z. 1379 bestätigt (nur `column-gutter`); Typst-Bedeutung festgelegt, als Verhaltensänderung mit Bericht (1.13, Zweifelsfall 13). |
| R17 | `typ` ist ein freier String | übernommen | Docstring Z. 1022 und fehlende Prüfung bestätigt; „unbekannter Wert → Bericht", Art um „Typ geändert" ergänzt (1.1, 3.2, Zweifelsfall 16). |
| R18 | `curriculum: ()` und `margin: (:)` gegen L9 | übernommen | Der falsche Verweis „L9" bei `curriculum` ist berichtigt, beide Namen sind als Lücke 21 gemeldet. |
| R19 | Lücke 7 unvollständig | übernommen | Lücke 7 um alle genannten Hooks, Schlüssel, `footer` und den L6-Konflikt bei `header` ergänzt. |
| R20 | `gray` überdeckt die Typst-Farbe; `tab(icon:)`; Namenspaare mit Plural-s | übernommen | `frame-gray`, `tab(icon-name:)`, `internal.class-accent`, `internal.callout-style-table`. |
| R21 | JSON: `teilaufgaben` als Übergangsname, `tasks` doppelt, Codemod-Einstufung der Theme-Schlüssel | übernommen | `teilaufgaben` aus `uebergangsnamen` gestrichen (gehört aufgaben; das Feld ist seit 2026-11-15 ganz entfallen), `tasks` bereinigt, Einstufung „AST, Theme-Rumpf nein" in 2.3 festgehalten. |

### 2026-11-15: Entscheidung deutsche Bausteine eingearbeitet

Die Tabelle folgt jetzt der Entscheidung des Autors (K, Kasten am Anfang, 2.1a, 2.1b, 9.3): `arbeitsblatt`, `arbeitsblatt-einzeln`, `lsg` und `teilaufgaben` behalten ihren Namen, `lücke` wird wegen der Umschrift zu `luecke`, und die englischen Zielnamen `worksheet`, `worksheet-single`, `blank`, `inline-solution`, `subtasks` sind aus Signaturen, Tabellenzeilen, Beispielen, Fehlermeldungen (`arbeitsblatt.arbeitsblatt: …`) und dem JSON-Anhang entfernt. Gestrichen sind die Übergangsnamen samt JSON-Feld `uebergangsnamen`, der Codemod-Schalter `--aliase` und der Stub für `arbeitsblatt-einzeln`; `tasks` verweist als Stub auf `teilaufgaben`. Parameter, Schlüssel, Enum-Werte, Theme-Schlüssel und Hooks (`task`, `subtask`, `solution`, `kind: "worksheet"`, `worksheet-accent`) sind unverändert englisch, ebenso alle Wertabbildungen und Zählungen. Der gentle-clues-Kasten `task` ändert nicht mehr still seine Bedeutung, sondern fällt wie `code` aus dem Namensraum; die Kontextregel fügt die namentliche Importzeile ein, Lücke 27 und Befund R11 sind erledigt. Abschnitt 4.2 nennt die durchgereichten Fachbausteine mit ihren deutschen Namen nach K Anhang B.1; maßgeblich bleiben die Tabellen der jeweiligen Pakete. Neu geprüft wurde nur gegen `konvention.md`, nicht erneut gegen Quelltext oder Bestand; offen bleibt, dass K 9.3 die Bedingung „kein benanntes Argument außer `tight:`" für `lücke` und einen Stub für `c_canvas` nicht nennt (Lücken 15 und 22).

### 2026-11-15: Nachprüfung nach der Einarbeitung

Ein Prüfer hat die Fassung mit deutschen Bausteinen gegen `konvention.md` geprüft: 5 Befunde, 4 übernommen, 1 ohne Änderungsbedarf. `konvention.md` wurde nicht geändert.

| Nr. | Befund (kurz) | Ergebnis | Begründung in einem Satz |
|---|---|---|---|
| N1 | 1.18 nennt für `task` „1 Dokument im Bestand", K 7.1 begründet mit „kein Bestand" | übernommen | Abweichung in 1.18 ausgewiesen und in Lücke 27 als Berichtigung an K 7.1 gemeldet; die Regel bleibt. |
| N2 | Pauschalsatz im Entscheidungskasten stimmt für `task` (gentle-clues-Kasten) und `blank` (früherer Zielname) nicht | übernommen | Satz um die beiden Ausnahmen ergänzt. |
| N3 | Veraltete Pfade `entwurf/KONVENTION.md`, `inventar/…`; „`KONVENTION.md` wurde nicht geändert" | übernommen | Dateinamen am Ordner bestätigt und berichtigt (`konvention.md`, `inventar-arbeitsblatt-kern.md`, `inventar-arbeitsblatt-themes.md`, `inventar-nutzung-ausserhalb.md`). |
| N4 | `loesungen-only: true`: „der Stub meldet …" widerspricht K 9.3, der JSON-Regel und A.9 | übernommen | Variante ohne Abweichung von A.9 gewählt: Der Codemod fasst den Aufruf nicht an, der Stub bricht mit der Standardmeldung ab, der Hinweis zur Bedeutung steht im Codemod-Bericht (1.12, JSON `kontext`); die offene Stub-Frage ist Lücke 28. |
| N5 | Negativbefund: keine englischen Bausteinnamen, keine eingedeutschten Zielnamen, keine Alias-Mechanik, JSON gültig | keine Änderung | Der Befund verlangt keine Korrektur; dass 4.2 `konstante` und `geogebra-style` nicht führt, entspricht dem Ist-Zustand. |
