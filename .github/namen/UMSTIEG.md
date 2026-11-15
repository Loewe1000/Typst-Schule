# Umstieg auf die @schule-Pakete 0.5.0

Bestehende Dokumente laufen mit ihrer gepinnten Version weiter. Wer ein
Dokument auf 0.5.0 heben will, benutzt `.github/scripts/umstellen.py`
(Python 3, nur Standardbibliothek). Regeln: `.github/namen/regeln.json`.

## Aufruf

```sh
python3 .github/scripts/umstellen.py blatt.typ             # nur ansehen: Diff auf stdout
python3 .github/scripts/umstellen.py blatt.typ --bericht   # dazu: was von Hand zu tun bleibt
python3 .github/scripts/umstellen.py ordner/ --schreiben --bericht   # Dateien umschreiben
```

Ordner werden rekursiv nach `*.typ` durchsucht. Ohne `--schreiben` ändert sich
keine Datei. Vorher sichern oder committen; danach kompilieren. Ein zweiter
Lauf ändert nichts mehr: Dateien, die schon 0.5.0 importieren, bleiben stehen.

## Was automatisch geht

- **Importe:** `@schule/<paket>:<alt>` wird `:0.5.0` für die 17 Pakete des
  Umfangs. Untergrenzen: arbeitsblatt ab 0.2.3, klassenarbeit ab 0.1.2,
  aufgaben ab 0.1.0. Liegt ein Import darunter, bleibt die ganze Datei
  unverändert und steht im Bericht.
- **Funktionsnamen:** `lücke` → `luecke`, `qrbox` → `qr-box`,
  `loesungsmodus` → `has-solutions`, `show-loesungen` → `show-solutions`,
  `print-pagebreak` → `conditional-pagebreak(print: true)`,
  `lineare_regression` → `lineare-regression`, `bin2dec` → `bin-to-dec` usw.
  Die Bausteine (`aufgabe`, `teilaufgabe`, `kariert` …) heißen wie bisher.
- **Parameter im richtigen Aufruf**, auch in `.with(...)`, mehrzeilig und
  verschachtelt: `loesungen` → `solutions`, `punkte` → `points`,
  `titel` → `title`; `title`, `class`, `print` bleiben.
- **Werte:** `"sofort"` → `"in-place"`, `"PA"` → `"pair"`, `"kariert"` →
  `"squares"`; ein Wert, der jetzt zwei Optionen ist
  (`loesungen: "seite"` → `solutions: "at-end", solutions-pagebreak: "before"`);
  Werte, die die Vorgabe sind oder nicht mehr erlaubt (`title: ""`,
  `theme: "standard"`, `materialien: "seiten"`), werden gelöscht.
- **Kontextregeln** (Liste in `regeln.json`, `kontextregeln`), zum Beispiel
  `aufgabe[Titel][Rumpf]` → `aufgabe(title: [Titel])[Rumpf]`,
  `set-options((punkte: "alle"))` → `set-options(points: "all")`,
  `punkte: (anzeige:, position:)`, `varianten: (druck: (…))` →
  `variants` und `variant-overrides`, `kariert(rows: 3, width: 12)` →
  `kariert(3, columns: 12)`, `klausurboegen: (show: false)` →
  `answer-sheets: false`, `datensatz(name, einheit, werte)` → benannt,
  `caesar(key: 3)("T")` → `caesar("T", key: 3)`, `graphen(x:, y:)` → `domain`.
- **Rückgabefelder:** nach `#let plan = sitzordnung(…)` wird `plan.namen` zu
  `plan.names` (ebenso `steckbrief`, `datensatz`, Regressionen,
  `häufigkeitsanalyse`, `konstante`).
- **Fremdimporte:** Namen, die die alten Pakete über `*` mitlieferten
  (`fa-…`, `task`, `colorbox`, `lamp`, `rand`, `zap` …), bekommen eine eigene
  Importzeile hinter dem @schule-Import.

Strings, Kommentare, Raw-Blöcke, Formeln und Fließtext bleiben unberührt.
Kommentare in Vorlagen (`// seite, seiten, sofort …`) nennen also weiter die
alten Werte.

## Was der Bericht meldet

Jede Zeile: `datei:zeile: [art] text`. Nichts davon wird geraten.

| Art | Bedeutung | Was tun |
|---|---|---|
| `untergrenze` | Import unter der Untergrenze | Dokument mit altem Pin weiterbenutzen |
| `dynamisch` | Wert ist kein Literal (Variable, `sys.inputs`, Ausdruck, Dictionary-Variable) | alte Werte und Schlüssel dort von Hand umstellen |
| `spread` | `..args` im Aufruf | Schlüssel des Dictionary von Hand umstellen |
| `eigene-funktion` | das Dokument definiert den Namen selbst (`#let lücke`, eigener Wrapper) | Aufrufe blieben stehen; prüfen |
| `entfernt` | Name, Parameter oder Schlüssel ohne Nachfolger; „gelöscht“ heißt: war wirkungslos | Hinweis in der Meldung befolgen |
| `bedeutung` | umgestellt, aber die Wirkung ist anders (`luecke` zeigt mit Lösungen den Inhalt, `gutter` gilt auch zwischen Zeilen, `loesungen-only`) | Ergebnis ansehen |
| `vorgabe` | eine alte Vorgabe wurde ausgeschrieben, damit das PDF gleich bleibt (`set-options(points: "tasks")`, `expectations: false`, Kopf von `klausurbögen`) | lassen oder löschen |
| `wert`, `form` | alte Schreibweise ohne eindeutige neue (ungerade `info-table`, `teilaufgaben[+ a]`, Kommazahl als Zeilenzahl) | Stelle umschreiben |
| `theme` | eigenes Theme (Dictionary oder Funktion) | Schlüssel und Hook-Parameter nach dem Handbuch von arbeitsblatt |
| `rueckgabe`, `zustand`, `intern` | tiefere Felder von Rückgaben, `state("print")`, Namen mit Unterstrich | von Hand, siehe Meldung |
| `import`, `weggefallen` | Fremdname: Importzeile ergänzt bzw. selbst zu importieren | Importzeile prüfen |
| `konflikt` | zwei Regeln trafen dieselbe Stelle | Stelle von Hand prüfen |

Was der Codemod übersieht, meldet das Paket beim ersten Kompilieren mit
„`alt` heißt jetzt `neu`“; ein alter Name wird nie still angenommen.

## Grenzen

- Über Dateigrenzen hinweg wird nichts verfolgt (`#include`, eigene Module).
- Aufrufe über eigene Variablen (`#let f = lineare_regression`, `f(x, y)`)
  und Dictionaries, die erst später übergeben werden, bleiben stehen.
- Zwei bekannte Verhaltensänderungen stellt kein Codemod her: `luecke` zeigt
  bei sichtbaren Lösungen den Inhalt; `insert-a-word(show-solution: true)`
  folgt jetzt der Lösungsoption des Dokuments.
- Nicht über Dateien laufen lassen, die absichtlich eine alte Version neben
  0.5.0 einbinden (`tests/v05-aufgaben-neben-031.typ`).
