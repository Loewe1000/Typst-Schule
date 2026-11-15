# Typst-Technik für die 0.4.x-Vereinheitlichung (@schule)

Alle Aussagen stammen aus echten Läufen mit **typst 0.15.1** (macOS, Homebrew), außerdem lokal vorhanden:
`tinymist` (Build 2026-06-22), `typstyle 0.15.1`, `cargo` (mit `typst-syntax 0.14.2` im Offline-Cache), `ast-grep`, `rg`, `python3`.
Nicht vorhanden: Python-Modul `typst`, `tree_sitter`.

Experimente (alle Dateien, nichts im Repo geändert):
`/private/tmp/claude-501/-Users-alexander--claude-spares-spare-T3hcxg/d64ba95e-5a74-47f7-8977-d9b919f98567/scratchpad/technik/`
(`run.sh` = kompilieren + PDF-Text zeigen; `compat.typ`, `sig.py`, `codemod.py`, `regeln.json`, `astdump/`, `pakete/t/…` = Testpakete).

---

## 1. Bezeichner

### Umlaute/ß, kebab-case, snake_case – in Code alles erlaubt

`t1a.typ`:
```typ
#let lösung(größe: 1, straße-nr: 2, maß_zahl: 3) = [größe=#größe straße-nr=#straße-nr maß_zahl=#maß_zahl]
#lösung(größe: 2)
#let l2 = lösung.with(größe: 5, straße-nr: 7)
#l2(maß_zahl: 9)
#let d = (größe: 1, "mit leer": 2, lösungs-art: 3, snake_case: 4)
#d.größe #d.lösungs-art #d.snake_case #d.at("mit leer")
#lösung(..(größe: 8, straße-nr: 1))
#let f(..a) = a.named()
#repr(f(größe: 1, über-schrift: 2, a_b: 3))
#let ÄÖÜ = 1
#let camelCase = 2
```
Ausgabe (exit 0):
```
größe=2 straße-nr=2 maß_zahl=3 größe=5 straße-nr=7 maß_zahl=9 1 3 4 2 größe=8 straße-nr=1 maß_zahl=3
lösung ( größe: 1, "mit leer": 2, lösungs-art: 3, snake_case: 4 ) (größe: 1, über-schrift: 2, a_b: 3) 1 2
```
Auch `typst eval 'let lösung(größe: 1) = größe; (lösung(größe: 2), (a-b: 1).a-b, (a_b: 1).a_b)'` → `[2,1,1]`.

Ergebnis:
- Umlaute und ß sind in Funktions-, Parameter-, Variablennamen, Dictionary-Schlüsseln, `.with(..)`, Spread (`..dict`) und Sink (`..args` → `args.named()`) **uneingeschränkt** nutzbar. Das Repo nutzt das bereits: `lücke` (arbeitsblatt.typ:1145), `klausurbögen` (klausurboegen.typ:37).
- kebab-case, snake_case, camelCase sind syntaktisch alle gültig. `größe` und `groesse` sind verschiedene Namen (`t1f.typ`: `error: unexpected argument: größe`).
- Dictionary-Schlüssel mit Leerzeichen gehen nur als String (`"mit leer"`), kein Feldzugriff.

### Fallstricke

| Test | Ergebnis |
|---|---|
| `#(x-b)` mit `x`, `b` definiert (`t1b.typ`) | `error: unknown variable: x-b` + Hinweis „try adding spaces around the minus sign“ – kebab frisst das Minus |
| `#let f(a-: 1, -b: 2)` (`t1e.typ`) | `error: unexpected minus` |
| `#let 1a = 2` (`t1d.typ`) | `error: invalid number suffix: a` |
| `#f(1, b: 2, b: 3)` (`t1g.typ`) | `error: duplicate argument: b` |
| `f.with(x: 1)` mit unbekanntem `x` (`t1h.typ`) | **kein Fehler bei `.with`**, erst beim Aufruf: `unexpected argument: x` |

Mathemodus (`t1m.typ`, `t1n.typ`), Funktionsname muss dort mehrbuchstabig sein:

| Im Mathemodus | Ergebnis |
|---|---|
| `$ ff(größe: 3) $`, `$ lösung(größe: 3) $` | ok – Umlaute in Name und Parameter funktionieren |
| `$ gg(max-wert: 7) $`, `$ gg(max_wert: 7) $` | ok – kebab/snake als **Parametername** funktionieren |
| `$ lös-ung(größe: 3) $` | `error: unknown variable: lös` – kebab-**Funktionsname** ohne `#` nicht aufrufbar |
| `$ lös_ung(a: 3) $` | `error: unknown variable: lös` – snake-Funktionsname ebenso nicht |
| `$ #lösungs-art $` | ok (mit `#`) |

Konsequenz für die Namensregel: kebab-case durchgehend (ist Typst-Standard), kein snake_case/camelCase; Funktionen, die typischerweise in Formeln ohne `#` aufgerufen werden, sollten einwortig sein. Umlaute sind technisch kein Risiko, nur eine Tipp-/Tastaturfrage (und ein zusätzlicher Variantenraum `loesung`/`lösung`).

---

## 2. Alias- und Deprecation-Muster

### (a) Alter Name als zweite Funktion
`#let alt-name = neu` genügt, `.with(..)` und Show-Rules funktionieren (`t2f.typ` → `A/inline/B`). Kostet nichts, erzeugt aber keinerlei Hinweis.

### (b) Alte benannte Parameter über Sink abfangen
Zwei Varianten getestet.

Variante 1 – neue Parameter explizit, Sink nur für Altlasten (`t2f.typ`, Signatur bleibt für Autovervollständigung erhalten):
```typ
#let neu(title: "", solutions: "none", ..alt, body) = {
  let a = alt.named()
  let map = (titel: "title", loesungen: "solutions")
  for (k, v) in a {
    assert(k in map, message: "neu: unbekannte Option `" + k + "`")
    if map.at(k) == "title" { title = v } else { solutions = v }
  }
  [#title/#solutions/#body]
}
#show: alt-name.with(titel: "A", solutions: "inline")   // → A/inline/B
```

Variante 2 – generische Tabelle mit Wertabbildung und Tippfehlervorschlag (`compat.typ`, `args-migrieren(paket, named, erlaubt:, umbenannt:, entfernt:, streng:)`, Levenshtein in reinem Typst). Test `t2b.typ`:
```typ
#let _umb = (loesungen: (name: "solutions", wert: v => if v in ("false", false, "keine") { "none" } else { v }), punkte: "points", titel: "title")
#show: ab.with(titel: "Hallo", loesungen: "false", points: "alle")
```
Ausgaben:
```
normal:            ALT=(("titel", "title"), ("loesungen", "solutions")) T=Hallo S=none P=alle Text
--input streng=1:  error: assertion failed: arbeitsblatt: `titel` heißt jetzt `title`
ab(solutons: 1):   error: panicked with: arbeitsblatt: unbekannte Option `solutons` – meintest du `solutions`?
ab(duplex: 1):     error: panicked with: arbeitsblatt: `duplex` gibt es nicht mehr – nutze `page-settings`
ab(xyzzy: 1):      error: panicked with: arbeitsblatt: unbekannte Option `xyzzy` – erlaubt: title, solutions, points
ab(titel:.., title:..): error: assertion failed: arbeitsblatt: `titel` (alt) und `title` (neu) gleichzeitig angegeben
```
Der Schalter „streng“ per `sys.inputs` funktioniert auch aus einem Paket heraus (`--input streng=1`), eignet sich also für CI und für „zeige mir alles Veraltete“.

Einschränkungen:
- Der Fehlerort zeigt in das Paket, nicht in die Nutzerzeile. Bei Show-Rules fehlt die Nutzerdatei im Trace ganz – real getestet mit dem heutigen Paket (`t2e.typ`):
  ```
  error: assertion failed: arbeitsblatt: unbekannte Option(en): `aufgaben-shortcode` – Tippfehler?
      ┌─ @schule/arbeitsblatt:0.4.0/src/arbeitsblatt.typ:323:2
    while calling `arbeitsblatt-einzeln` at @schule/arbeitsblatt:0.4.0/src/arbeitsblatt.typ:1128:4
  ```
  Die Meldung selbst muss deshalb Paket, Funktion, alten und neuen Namen nennen.
- Positionsparameter lassen sich nicht umbenennen/abfangen, nur benannte.
- Schlüssel in Options-Dictionaries (`set-options((loesungen: ..))`, `punkte: (anzeige: ..)`) laufen nicht durch die Signatur; sie brauchen dieselbe Tabelle an der Stelle, wo das Dictionary gelesen wird.
- Kosten: 2000 Aufrufe von `args-migrieren` mit 60 erlaubten Namen: 0,05 s Gesamtlaufzeit, nicht messbar über dem Leerlauf (`t4g.typ`). Levenshtein läuft nur im Fehlerfall.

### (c) Warnung statt Fehler
Es gibt **keine** Diagnose-API für Pakete (`t2w.typ`):
```
warn("x")                  error: unknown variable: warn
std.warn("x")              error: module `global` does not contain `warn`
sys.warn("x")              error: module `sys` does not contain `warn`
deprecated("x")            error: unknown variable: deprecated
assert(false, message: "m", level: "warning")   error: unexpected argument: level
```
`dictionary(std)` (158 Einträge) enthält an Diagnosefunktionen nur `panic` und `assert`; `sys` nur `version` und `inputs`. `typst compile` kennt nur `--diagnostic-format`, keinen Schalter „Warnungen als Fehler“.

Funktionierender Umweg (Hack, `t2w2.typ`, `t2d.typ`): eine unbekannte Schriftfamilie erzeugt eine Compiler-Warnung, deren Text frei wählbar ist – auch aus einem Paket heraus und mit berechnetem String:
```typ
#let warnung(msg) = text(font: ("WARNUNG " + msg, "Libertinus Serif"), size: 0pt)[]
```
```
warning: unknown font family: warnung aa: loesungen heisst jetzt solutions
  ┌─ @t/kern:0.1.0/lib.typ:7:31
[exit 0]
```
Nachteile: Text wird kleingeschrieben, Präfix „unknown font family“, Fundstelle im Paket statt beim Nutzer, undokumentiertes Verhalten (kann sich mit jeder Typst-Version ändern). Als Zusatzkanal brauchbar, nicht als tragende Lösung.

Sauberer Ersatz – maschinenlesbarer Bericht (`t2r.typ`): das Paket legt bei jedem alten Namen ein `metadata` mit Label ab, abgefragt per CLI:
```typ
#let _veraltet(alt, neu) = [#metadata((paket: "aa", alt: alt, neu: neu))<schule-veraltet>]
```
```
$ typst eval --package-path pakete --in t2r.typ 'query(<schule-veraltet>).map(m => m.value + (seite: m.location().page()))'
[{"paket":"aa","alt":"loesungen","neu":"solutions","seite":1},{"paket":"aa","alt":"loesungen","neu":"solutions","seite":2}]
```
Liefert Seite, aber keine Quellzeile. `typst query` ist in 0.15.1 selbst veraltet („use `typst eval … --in`“).

### (d) Sichtbare Hinweise nur im Entwurf
Geht über `sys.inputs` (`t2d.typ`):
```typ
#let hinweis(msg) = if sys.inputs.at("entwurf", default: "0") == "1" { place(top + right, box(fill: yellow, inset: 2pt, text(8pt, red)[VERALTET: #msg])) }
```
```
ohne Schalter:        aa-alt ok
--input entwurf=1:    aa-alt ok   VERALTET: loesungen → solutions
```
Alternativ an eine vorhandene Paketoption koppeln (z. B. nur wenn `print: false`). Über die Kommandozeile gesteuert bleibt die Druckfassung garantiert sauber.

---

## 3. Heutige Optionsprüfung (Commit 4e49bf7)

**arbeitsblatt/0.4.0/src/arbeitsblatt.typ**, in `arbeitsblatt-einzeln` (Signatur Z. 268–305, Prüfung Z. 306–326):
- lokaler Helfer `_pruefe(name, wert, erlaubt)` = `assert(wert in erlaubt, message: "arbeitsblatt: ungültiger Wert für `name`: … – erlaubt: …")`, angewandt auf `loesungen`, `materialien`, `punkte` (String oder `punkte.anzeige`), `punkte.position`, `aufgaben-shortcodes`, `teilaufgabe-numbering`.
- Unbekannte benannte Argumente: `args.named().keys().filter(k => k not in ("header-ascent",))` muss leer sein, sonst „unbekannte Option(en): … – Tippfehler?“ (ohne Vorschlag).
- Die Wertelisten zeigen die Altlast direkt: `loesungen` akzeptiert `"keine", "false", false, none, "sofort", "folgend", "seite", "seiten", "nur", "reinquetschen"`, der Standardwert ist der String `"false"`.

**klassenarbeit/0.4.0/src/klassenarbeit.typ**: nur zwei Einzelprüfungen (`page-numbering` Z. 67–70, `erwartungen` Z. 403–406). Alles Übrige wird als `..args` blind an `arbeitsblatt-einzeln` gereicht (Z. 224–242, 428) und per `args.named().at("title", …)` herausgefischt; unbekannte Namen fängt erst arbeitsblatt, mit dem Präfix „arbeitsblatt:“ statt „klassenarbeit:“.

**aufgaben/0.3.1/aufgaben.typ**: keine Optionsprüfung. `set-options(options)` (Z. 113) mischt ein beliebiges Dictionary in `state("options", …)` – Tippfehler in Schlüsseln werden still verschluckt. Nur drei `panic` zur Anzahl der Positionsargumente (Z. 919, 1380, 1383), englisch formuliert und Z. 1383 mit falschem Funktionsnamen („aufgabe expects …“ in `erwartung`).

**Ausbau zur Umbenennungstabelle:** ja, direkt. `compat.typ` ist genau das verallgemeinerte Muster (erlaubte Namen + `umbenannt` alt→neu inkl. Wertabbildung + `entfernt` + Levenshtein-Vorschlag) und ersetzt sowohl `_pruefe` als auch den `unbekannt`-Filter. Dieselbe Tabelle (als Typst-Dictionary oder JSON/TOML, per `json()`/`toml()` lesbar) kann drei Dinge speisen: Laufzeitprüfung im Paket, Codemod (`regeln.json`), Namens-Lint. Wichtig: auch `set-options` und verschachtelte Dictionaries (`punkte: (anzeige:, position:)`) durch dieselbe Prüfung schicken.

---

## 4. Gemeinsames Kernpaket

Testaufbau `pakete/t/`: `kern` 0.1.0 und 0.2.0 (State, Counter, Namenstabelle, Hinweisfunktionen), `aa` importiert kern 0.1.0, `bb` importiert kern 0.2.0.

- **Teilen funktioniert**: ein Paket kann beliebige andere per `#import "@ns/kern:x.y.z"` einbinden; `typst.toml` kennt keine Abhängigkeitsdeklaration, die Version steht fest im Import.
- **Zyklen sind verboten** (`t4b.typ`):
  ```
  error: cyclic import
    ┌─ @t/cyc2:0.1.0/lib.typ:1:8
    while importing `@t/cyc2:0.1.0` at @t/cyc1:0.1.0/lib.typ:1:1
  ```
  Das Kernpaket darf also nichts aus aufgaben/arbeitsblatt/klassenarbeit importieren. Die heutige Kette ist azyklisch: klassenarbeit → arbeitsblatt → aufgaben (+ random, insert-a-word, energy-sketch, patterns, mathematik, informatik, physik, operatoren); klassenarbeit zusätzlich → klausurboegen.
- **State und Counter werden über Paketversionen hinweg geteilt**, weil nur der Schlüssel-String zählt (`t4a.typ`):
  ```
  aa sieht: init-0.1.0 / versioniert: init-0.1.0 / zähler 0
  bb sieht: aa(kern 0.1.0) / versioniert: init-0.2.0 / zähler 1
  aa sieht: bb(kern 0.2.0) / versioniert: aa(kern 0.1.0) / zähler 3
  bb sieht: bb(kern 0.2.0) / versioniert: bb(kern 0.2.0) / zähler 3
  ```
  `state("kern-optionen")` aus kern 0.1.0 und 0.2.0 ist derselbe State; ein Schlüssel mit Versionsanteil (`"kern-optionen@0.2"`) trennt sie. Folgen:
  - Gewollt nutzbar: arbeitsblatt und klassenarbeit sehen denselben Optionsstand, auch wenn sie das Kernpaket getrennt importieren.
  - Gefährlich: lädt ein Dokument zwei Versionen von `aufgaben` (z. B. direkt 0.3.0 und über arbeitsblatt 0.3.1), schreiben beide in `state("options")`. Ändert 0.4.x das Schema (neue Schlüsselnamen), bricht die ältere Version. Die heutigen Schlüssel sind zudem sehr generisch: `"options"`, `"aufgaben"`, `"in_loesung"` (aufgaben.typ:5–41) und `"@options"` im Paket `options`.
  - Empfehlung: State-Schlüssel mit Paketpräfix und Schema-Version (`"schule/aufgaben/optionen@1"`), zentral im Kernpaket definiert.
- **Wildcard-Importe lecken**: `#import "…": *` im Paket re-exportiert alles.
  ```
  $ typst eval 'import "@schule/aufgaben:0.3.1" as m; … '
  {"gesamt":5350,"eigen":41,"oeffentlich":[19 Namen],"privat-aber-exportiert":22}
  $ typst eval 'import "@schule/arbeitsblatt:0.4.0" as m; (dictionary(m).len(), …)'   →  [5526, 5482]
  ```
  aufgaben exportiert 5350 Namen, davon 41 eigene (fontawesome + gentle-clues machen den Rest); arbeitsblatt 5526. Auch `_`-Namen sind von außen erreichbar (`_`-Präfix ist nur Konvention). Für 0.4.x: Einstiegsdatei `lib.typ` mit ausschließlich expliziten Importen/Re-Exporten.
- **Kosten**: Leerdokument 0,05–0,06 s; Import von `aa`+`bb` (zwei Kernversionen) 0,05 s; `@schule/aufgaben:0.3.1` 0,06 s; komplettes `arbeitsblatt` 0,11–0,13 s. Ein kleines Kernpaket ist zeitlich irrelevant. Organisatorischer Preis: jede Kernänderung braucht neue Versionsnummern in allen abhängigen Paketen, und Versionen müssen synchron gehalten werden (sonst zwei Kernversionen im Dokument, siehe State).
- Das vorhandene Paket `options/0.0.5` ist kein Kandidat: es nutzt `type(loc) == "location"` und `locate(l => …)` (in 0.15 nicht mehr gültig) und wird von keinem der drei Pakete importiert.

---

## 5. Automatische Migration von Nutzerdokumenten

Getestet an `t5a.typ` (Kommentar, String mit `loesungen:`, Raw-Block, verschachteltes Dictionary mit gleichnamigem Schlüssel, Variable als Wert, Spread `..opts`, Fließtext mit dem Wort „loesung“, Mathemodus, `set-options`).

### Regex/Token-Codemod in Python (`codemod.py` + `regeln.json`)
Maskiert Strings, Kommentare, Raw; sucht `fn(`/`fn.with(`, ersetzt nur Argumentnamen auf oberster Klammerebene; statische Werte werden mit abgebildet.
```
WARNUNG t5a.typ:10: Spread `..` in arbeitsblatt(…): Dictionary-Schlüssel von Hand prüfen
-  loesungen: "false", punkte : "alle",
+  solutions: "none", points : "alle",
-  materialien: modus,
+  materials: modus,
-#aufgabe(title: [Die #lücke[Lücke] `loesungen: 1`])[
-  Text mit loesung im Fließtext und #loesung[Antwort] und #show-loesungen(curr: true)
+#aufgabe(titel: [Die #gap[Lücke] `loesungen: 1`])[
+  Text mit loesung im Fließtext und #solution[Antwort] und #solutions(curr: true)
```
Richtig: Kommentar, String, Raw, `page-settings: (punkte: 3)` bleiben unberührt; Spread wird gemeldet.
Grenzen:
- Erste Fassung benannte auch das Wort „loesung“ im Fließtext um; behoben durch die Regel „nur `#name`, `name(`, `name[`, `name.with`“ – dadurch wird ein Bezeichner im Mathemodus (`$ loesung + x $`) nicht mehr erfasst.
- Nicht erfasst: `#let opts = (loesungen: …)` + `..opts`, `#set-options((loesungen: …))`, dynamische Werte (`materialien: modus`), umbenannte Importe (`#import … : arbeitsblatt as ab`), eigene Wrapper.
- Einschätzung: für den Standardfall `#show: arbeitsblatt.with(name: "literal", …)` zuverlässig, für alles Indirekte nur mit Warnliste und Nachkontrolle.

### Echter Parser: `typst-syntax` lokal baubar
`typst-syntax 0.14.2` liegt im Cargo-Cache; ein 40-Zeilen-Werkzeug (`astdump/`) baute **offline in 5,9 s** (`cargo build --offline --release`). Ausgabe für `t5a.typ`:
```
named   arbeitsblatt.with  title          211 216
named   arbeitsblatt.with  loesungen      267 276
named   arbeitsblatt.with  punkte         287 293
named   arbeitsblatt.with  page-settings  306 319
named   arbeitsblatt.with  materialien    354 365
spread  arbeitsblatt.with  ..opts         376 382
named   aufgabe            title          395 400
named   show-loesungen     curr           516 520
ident   loesungen 124 133   (Dictionary-Schlüssel in #let opts)
ident   lücke 408 414 / loesung 479 486 / show-loesungen 501 515
ident   loesung 562 569     (Mathemodus)
ident   meine-loesung 583 596
ident   loesungen 615 624   (set-options-Dictionary)
```
Byte-genaue Bereiche, Fließtext/Kommentar/String/Raw sind von selbst ausgeschlossen, Mathe-Bezeichner und Dictionary-Schlüssel werden gefunden. Der 0.14.2-Parser liest die drei Paketquellen ohne Syntaxfehler (arbeitsblatt 181, aufgaben 291, klassenarbeit 100 benannte Argumente) und Umlaut-Bezeichner problemlos. Das ist die belastbare Basis für einen Codemod (Rust-Werkzeug liefert Positionen, Python ersetzt von hinten nach vorn).

### Weiteres Tooling
- `tinymist` hat `lint`, `test`, `compile`, `lsp` – kein Refactoring-Kommando auf der CLI. Umbenennen ginge nur über das LSP (`textDocument/rename`); **nicht getestet**.
- `typstyle` formatiert nur (nach dem Codemod sinnvoll), bietet keinen AST-Zugriff.
- `ast-grep` ist installiert, bringt aber keine Typst-Grammatik mit; nicht getestet.

### Absicherung
1. Vorher/nachher kompilieren und PDF-Text vergleichen (das Muster von `tests/run.sh` mit `pdftotext`).
2. Nach der Migration mit `--input streng=1` kompilieren: jeder verbliebene alte Name wird zum Fehler.
3. Bericht per `typst eval 'query(<schule-veraltet>)' --in datei.typ` findet auch indirekte Fälle (Spread, `set-options`), die der Codemod nicht sieht.

---

## 6. Signatur-Snapshot und Namens-Lint

| Weg | Test | Ergebnis |
|---|---|---|
| Typst-Introspektion | `typst eval '… m.aufgabe.fields()'` | `error: cannot access fields on user-defined functions` – Parameter sind zur Laufzeit nicht abfragbar; `repr(f)` liefert nur den Namen |
| Modul-Namensliste | `typst eval 'import "@schule/aufgaben:0.3.1" as m; dictionary(m)…'` | funktioniert: Namen + Typ (function/dictionary/…); fremde Namen müssen herausgerechnet werden (Wildcard-Leck) |
| tidy 0.4.3 (`t6a.typ`, `tidy.parse-module` + `typst query`) | `sig-aufgaben-tidy.json` | nur **15** Funktionen – tidy sieht ausschließlich mit `///` dokumentierte Definitionen; es fehlen u. a. `get-punkte-anzeige`, `format-punkte`, `show-loesung`, `show-material`, dafür sind private `_ist-flex-workspace`, `_flex-fest` enthalten |
| Python-Skript `sig.py` (Kommentare entfernen, Klammern zählen) | aufgaben: 41 Top-Level-Definitionen, **19 öffentlich** | deckungsgleich mit der Laufzeit-Liste aus `typst eval` (19 Namen); arbeitsblatt: 51/36, klassenarbeit: 5/1 |
| `astdump` (typst-syntax) | s. o. | exakt, erweiterbar auf `LetBinding`/`Params` |
| `read("@schule/aufgaben:0.3.1/aufgaben.typ")` | `error: file not found` | Paketdateien sind per `read` nicht adressierbar; für tidy `--root /` + absoluter Pfad nötig |

`sig.py`-Ausgabe für aufgaben 0.3.1 (Zeile, Signatur):
```
   56 get-punkte-anzeige(opts)                 86 format-punkte(teil: false, points)
  113 set-options(options)                    133 reset-aufgaben()
  151 show-loesung(aufg, teil: false)         215 show-loesung-inline(aufg)
  279 show-offene-loesungen()                 299 show-loesungen(curr: false, teil: false, inline: false)
  373 get-points(aufg, teil: none, idx: none)
  534 show-erwartungen(grouped: false, new-page: false, erreicht: false, alle: false, teile: ())
  595 show-bewertung(..args, compact: false, full: false)
  785 show-material(aufg, start: 0)           810 show-materialien(curr: false)
  838 material(body, caption: none, label: none)
  896 aufgabe(title: none, method: "", icons: (), large: true, number: true, workspace: none, label: none, ..args)
 1122 teilaufgabe(item-label: none, label: none, workspace: none, body)
 1310 loesung(body)                          1363 erwartung(..args)
```

Lint (`sig.py --lint`, Regeln: camelCase, snake_case, Umlaut, Sprachmischung über zwei Wortlisten, `--strict` meldet Wörter außerhalb des Wörterbuchs):
```
aufgaben.typ:56:  `get-punkte-anzeige`: gemischt de(punkte,anzeige)+en(get)
aufgaben.typ:86:  `format-punkte`: gemischt de(punkte)+en(format)
aufgaben.typ:133: `reset-aufgaben`: gemischt de(aufgaben)+en(reset)
aufgaben.typ:151…810: `show-loesung`, `show-loesung-inline`, `show-offene-loesungen`, `show-loesungen`, `show-erwartungen`, `show-bewertung`, `show-material`, `show-materialien`
arbeitsblatt.typ:268/1030: `teilaufgabe-numbering` (Parameter von arbeitsblatt-einzeln / arbeitsblatt): gemischt de+en
arbeitsblatt.typ:1145: `lücke`: Umlaut
arbeitsblatt.typ:1265: `c_canvas`: snake_case
```
Was der Snapshot nicht sieht und eigens erfasst werden muss: Schlüssel von Options-Dictionaries (`set-options`, `punkte: (anzeige:, position:)`), erlaubte String-Werte (`"keine"`, `"sofort"`, …), aus `args.named().at("…")` gefischte Pseudo-Parameter (klassenarbeit: `title`, `class`, `theme`, `akzent`, `font`, `math-font`, `page-settings`) und Namen, die nur über Wildcard-Re-Export öffentlich sind.

Als CI-Baustein tauglich: `sig.py --json` als eingecheckter Snapshot (Diff = API-Änderung), `--lint` als Prüfschritt neben `tests/run.sh`; `tinymist lint` existiert zusätzlich für allgemeine Code-Hinweise.

---

## Kurzfazit

1. Namen: technisch ist alles erlaubt; kebab-case ist die einzige Schreibweise ohne Reibung, Umlaute funktionieren überall in Code.
2. Sanfte Migration: Alias + Sink-Abbildung mit Tabelle funktioniert vollständig; echte Warnungen gibt es nicht (nur Font-Hack), dafür Strict-Schalter per `--input`, Entwurfshinweise und ein per `typst eval` abfragbarer Veraltet-Bericht.
3. Die vorhandene Optionsprüfung (`_pruefe` + `unbekannt`-Filter) ist der richtige Keim; sie fehlt in aufgaben ganz und in klassenarbeit fast ganz.
4. Kernpaket ist möglich und billig; Zyklen verboten; States teilen sich über Versionen (Schlüssel versionieren); Wildcard-Importe blähen die öffentliche API auf 5000+ Namen.
5. Codemod: Regex reicht für den Standardaufruf, ein AST-Werkzeug auf `typst-syntax` ist lokal in Sekunden baubar und deutlich sicherer.
6. Signaturen: Laufzeit-Introspektion gibt es nicht, tidy ist unvollständig; ein kleines Skript bzw. `typst-syntax` liefert Snapshot und Lint.
