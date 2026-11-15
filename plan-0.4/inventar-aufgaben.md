# Inventar `@schule/aufgaben:0.3.1`

Quelle: `aufgaben/0.3.1/aufgaben.typ` (1404 Zeilen, vollständig gelesen), `aufgaben/0.3.1/typst.toml`.
Vergleich: `aufgaben/0.3.0/aufgaben.typ` (1176 Zeilen), `aufgaben/0.3.1/aufgaben.typ.orig` (1226 Zeilen).
Alle Zeilennummern beziehen sich auf `aufgaben/0.3.1/aufgaben.typ`, sofern nicht anders angegeben.

Sprach-Kürzel: **de** = deutsch, **en** = englisch, **mix** = gemischt (denglisch), **abk** = Abkürzung.

---

## 0. Paket-Metadaten und Importe

`typst.toml` (0.3.1):

```toml
[package]
name = "aufgaben"
version = "0.3.1"
entrypoint = "aufgaben.typ"
description = "Ein Paket zur Erstellung strukturierter Aufgaben mit Teilaufgaben, Lösungen, Materialien und Bewertungsschemata für den Schulbereich."
license = "MIT"
repository = "https://github.com/Loewe1000/Typst-Schule"
```

- Kein `compiler`-Feld, keine `authors`, obwohl der Code Typst-0.13+/0.15-Funktionen voraussetzt (`figure.where`, `std.label`, Bundle-Export laut Z. 121).
- `README.md` ist leer (0 Byte), in 0.3.0 ebenso.
- Einzige Quelldatei; der Entrypoint ist die Implementierung (kein `src/`, anders als `arbeitsblatt/0.4.0/src/`, `klassenarbeit/0.4.0/src/`).

Importe (Z. 1-2):

| Zeile | Import | Wirkung |
|---|---|---|
| 1 | `#import "@preview/fontawesome:0.6.0": *` | alle `fa-*`-Namen landen im Modul und werden mit `import "@schule/aufgaben": *` weitergereicht. Genutzt werden nur `fa-user-large`, `fa-user-group`, `fa-users` (Z. 936-938). |
| 2 | `#import "@preview/gentle-clues:1.2.0": *` | alle Clue-Funktionen (`goal`, `tip`, `info`, `clue`, ...) werden weitergereicht. Genutzt wird nur `goal` (Z. 39). |

Kein Import anderer `@schule`-Pakete. Die Kopplung läuft umgekehrt: `arbeitsblatt` importiert `aufgaben` mit `*` (siehe Abschnitt 7).

---

## 1. Alle Top-Level-Definitionen (Übersicht)

Typst kennt keine privaten Namen: `import ...: *` reicht auch Namen mit führendem Unterstrich weiter. `arbeitsblatt/0.4.0` greift tatsächlich auf mehrere `_`-Namen zu (Spalte "extern genutzt").

### 1.1 Öffentlich (ohne Unterstrich)

| Zeile | Name | Signatur (wörtlich) | Doc-Kommentar | extern genutzt |
|---|---|---|---|---|
| 56 | `get-punkte-anzeige` | `get-punkte-anzeige(opts)` | nur `//` | nein (intern Z. 989, 1011, 1094) |
| 65 | `get-punkte-position` | `get-punkte-position(opts)` | nur `//` | nein, **nirgends aufgerufen** |
| 86 | `format-punkte` | `format-punkte(teil: false, points)` | nur `//` | nein |
| 113 | `set-options` | `set-options(options)` | `///` | arbeitsblatt 0.4.0 Z. 573, klassenarbeit 0.4.0 Z. 217 |
| 133 | `reset-aufgaben` | `reset-aufgaben()` | `///` | arbeitsblatt 0.4.0 Z. 615, Docs |
| 151 | `show-loesung` | `show-loesung(aufg, teil: false)` | keiner | nein |
| 215 | `show-loesung-inline` | `show-loesung-inline(aufg)` | nur `//` | nein |
| 279 | `show-offene-loesungen` | `show-offene-loesungen()` | `///` | arbeitsblatt Z. 707, klassenarbeit Z. 305 |
| 299 | `show-loesungen` | `show-loesungen(curr: false, teil: false, inline: false)` | `///` | arbeitsblatt Z. 716 |
| 373 | `get-points` | `get-points(aufg, teil: none, idx: none)` | `///` (ohne `idx`) | Nutzer-API |
| 534 | `show-erwartungen` | `show-erwartungen(grouped: false, new-page: false, erreicht: false, alle: false, teile: ())` | `///` | klassenarbeit Z. 327 |
| 595 | `show-bewertung` | `show-bewertung(..args, compact: false, full: false)` | `///` | Nutzer-API / klassenarbeit |
| 785 | `show-material` | `show-material(aufg, start: 0)` | nur `//` | nein |
| 810 | `show-materialien` | `show-materialien(curr: false)` | `///` | arbeitsblatt Z. 712 |
| 838 | `material` | `material(body, caption: none, label: none)` | `///` | Nutzer-API |
| 896 | `aufgabe` | `aufgabe(title: none, method: "", icons: (), large: true, number: true, workspace: none, label: none, ..args)` | `///` | Nutzer-API |
| 1122 | `teilaufgabe` | `teilaufgabe(item-label: none, label: none, workspace: none, body)` | `///` | Nutzer-API, arbeitsblatt `teilaufgaben` |
| 1310 | `loesung` | `loesung(body)` | `///` | Nutzer-API |
| 1363 | `erwartung` | `erwartung(..args)` | `///` | Nutzer-API |

Dazu durch `*`-Importe weitergereicht: gesamtes `fontawesome:0.6.0` und `gentle-clues:1.2.0`.

### 1.2 Formal privat (führender Unterstrich), aber per `*` sichtbar

| Zeile | Name | Art | Definition (wörtlich) | extern genutzt |
|---|---|---|---|---|
| 5 | `_state_aufgaben` | State | `state("aufgaben", ())` | arbeitsblatt 0.4.0 Z. 711, 715 |
| 6 | `_state_current_material_aufgabe` | State | `state("current_material_aufgabe", 0)` | arbeitsblatt Z. 378, 656 (in aufgaben nur geschrieben) |
| 7 | `_state_current_material_index` | State | `state("current_material_index", 0)` | arbeitsblatt Z. 379, 657 (in aufgaben nur geschrieben) |
| 8 | `_state_in_loesung` | State | `state("in_loesung", false)` | arbeitsblatt Z. 695 |
| 9 | `_state_current_aufgabe_index` | State | `state("current_aufgabe_index", -1)` | nein |
| 10 | `_state_loesungen_gezeigt` | State | `state("loesungen_gezeigt", 0)` | nein |
| 13 | `_state_in_aufgabe` | State | `state("in_aufgabe", false)` | nein |
| 14 | `_state_in_teilaufgabe` | State | `state("in_teilaufgabe", false)` | nein |
| 17 | `_state_ta_material_vorher` | State | `state("ta_material_vorher", 0)` | nein |
| 27 | `_state_theme` | State | `state("ab-theme", none)` | arbeitsblatt Z. 616 (schreibt), 1522 (liest) |
| 28 | `_theme-hook` | Funktion | `_theme-hook(name)` | nein |
| 33 | `_zusammen` | Funktion | `_zusammen(inhalt, above: auto, below: auto)` | nein |
| 37 | `_loesung-kasten` | Funktion | `_loesung-kasten(titel, body)` | nein |
| 41 | `_state_options` | State | `state("options", (...))` | arbeitsblatt Z. 391, 397, 1494; zusätzlich über den rohen Namen `state("options", (:))` Z. 1179, 1307, 1330 |
| 74 | `_be-runden` | Funktion | `_be-runden(p)` | nein |
| 80 | `_be-anzeige` | Funktion | `_be-anzeige(p)` | nein |
| 98 | `_counter_aufgaben` | Counter | `counter("aufgaben")` | arbeitsblatt Z. 383, 661 |
| 327 | `_aufgaben-final` | Funktion | `_aufgaben-final()` | nein |
| 340 | `_rechter-textrand` | Funktion | `_rechter-textrand()` | nein |
| 394 | `_erwartungen-zeilen` | Funktion | `_erwartungen-zeilen(all, opts, grouped, erreicht)` | nein |
| 867 | `_ist-flex-workspace` | Funktion | `_ist-flex-workspace(ws)` | nein |
| 873 | `_flex-fest` | Funktion | `_flex-fest(ws)` | nein |

Schreibweisen im Überblick: States/Counter `_state_snake_case` / `_counter_snake_case`, Hilfsfunktionen `_kebab-case`. State-**Schlüssel** in snake_case (`"current_material_aufgabe"`), einzige Ausnahme `"ab-theme"` (kebab, mit Paketkürzel). Lokale Variablen mischen `curr_aufg`/`curr_teil`/`curr_idx`/`ct_aufgaben` (snake) mit `pos-args`/`actual-title`/`teil-label`/`gesamt-punkte` (kebab).

---

## 2. Öffentliche Funktionen im Detail

### 2.1 `set-options` (Z. 113)

```typ
#let set-options(options) = {
  _state_options.update(curr => {
    curr + options
  })
}
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `options` | positional | (Pflicht) | dictionary | en | Schlüssel-Wert-Paare, die in den Options-State gemischt werden |

- Name **en** (`set-options`), Inhalte **de/mix** (siehe Abschnitt 3).
- Keinerlei Validierung: unbekannte Schlüssel und Werte werden stillschweigend übernommen. `arbeitsblatt/0.4.0` Z. 573-580 schreibt z. B. zusätzlich `"print"` hinein, einen Schlüssel, den `aufgaben` gar nicht kennt.
- Einzige Funktion, die ein Dictionary positional verlangt (`set-options((loesungen: "sofort"))`, doppelte Klammern) statt benannter Argumente.

### 2.2 `reset-aufgaben` (Z. 133)

```typ
#let reset-aufgaben() = {
```

Keine Parameter. Name **mix** (`reset` en + `aufgaben` de). Setzt eine Marke `[#metadata("aufgaben-reset") <_aufgaben-reset>]` (Z. 136) und setzt zurück: `_counter_aufgaben` auf `(0, 0)`, Figure-Zähler für `kind: "aufgabe"`, `"teilaufgabe"`, `"material"`, `image`, `table`, sowie `_state_aufgaben`, `_state_current_aufgabe_index`, `_state_current_material_aufgabe`, `_state_current_material_index`, `_state_in_loesung`, `_state_loesungen_gezeigt`.

**Nicht** zurückgesetzt: `_state_in_aufgabe`, `_state_in_teilaufgabe`, `_state_ta_material_vorher`, `_state_options`, `_state_theme`.

### 2.3 `get-punkte-anzeige` (Z. 56) und `get-punkte-position` (Z. 65)

```typ
#let get-punkte-anzeige(opts) = {
#let get-punkte-position(opts) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `opts` | positional | (Pflicht) | dictionary (Options-State) | en, abk | Options-Dictionary |

Rückgabe: String aus `opts.punkte` bzw. `opts.punkte.anzeige` / `opts.punkte.position` / `opts.punkte-position`. Name **mix** (`get-` en + `punkte-anzeige` de). Eigentlich interne Helfer ohne Unterstrich. `get-punkte-position` wird nirgends aufgerufen; `teilaufgabe` rechnet beides inline neu (Z. 1153-1162, Kommentar "Inline-Berechnung für bessere Kompatibilität").

### 2.4 `format-punkte` (Z. 86)

```typ
#let format-punkte(teil: false, points) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `teil` | named | `false` | bool | de | `true` = Vorlage für Teilaufgaben, sonst für Aufgaben |
| `points` | positional | (Pflicht) | int / float | en | Punktzahl |

Name **mix**; in einer Signatur `teil` (de) neben `points` (en); benannter Parameter steht vor dem positionalen. Braucht `context` (liest `_state_options`), nicht dokumentiert.

### 2.5 `show-loesung` (Z. 151)

```typ
#let show-loesung(aufg, teil: false) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `aufg` | positional | (Pflicht) | dictionary (Aufgaben-Datensatz, siehe 3.3) | de, abk | Aufgabe, deren Lösung ausgegeben wird |
| `teil` | named | `false` | `false` oder int (0 = Aufgabe selbst, n = Teilaufgabe) | de | `false`: ganze Aufgabe mit allen Teillösungen in einem Kasten; Zahl: nur Lösungen dieser Teilaufgabe |

Kein Doc-Kommentar. Interner Renderer, aber öffentlich benannt.

### 2.6 `show-loesung-inline` (Z. 215)

```typ
#let show-loesung-inline(aufg) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `aufg` | positional | (Pflicht) | dictionary | de, abk | Aufgaben-Datensatz |

Name **mix** aus drei Teilen (`show` en, `loesung` de, `inline` en).

### 2.7 `show-offene-loesungen` (Z. 279)

```typ
#let show-offene-loesungen() = {
```

Keine Parameter. Name **mix**. Wirkt unabhängig vom Modus (die Doc sagt "im Lösungsmodus `"nur"`", geprüft wird das aber nur beim Aufrufer, Z. 926).

### 2.8 `show-loesungen` (Z. 299)

```typ
#let show-loesungen(curr: false, teil: false, inline: false) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `curr` | named | `false` | bool | en, abk | nur die zuletzt angelegte Aufgabe |
| `teil` | named | `false` | `false` oder int | de | nur Lösungen dieser Teilaufgabe (Doc Z. 296 nennt den Typ "boolean" und beschreibt dann eine Zahl) |
| `inline` | named | `false` | bool | en | ohne Kasten, wie Aufgaben formatiert |

Liest zusätzlich die Option `loesungen` (`"seite"` -> Seitenumbruch davor, `"seiten"` -> je Aufgabe eigene Seite).

### 2.9 `get-points` (Z. 373)

```typ
#let get-points(aufg, teil: none, idx: none) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `aufg` | positional | (Pflicht) | int (1-basiert) oder `none` | de, abk | Aufgabennummer |
| `teil` | named | `none` | `none` oder int (1-basiert, 0 = Aufgabe selbst) | de | Teilaufgabe; `none` = Summe der Aufgabe |
| `idx` | named | `none` | `none` oder int (0-basiert) | en, abk | Index im Aufgaben-Array; hat Vorrang vor `aufg` (undokumentiert) |

Name komplett **en** (`get-points`), während die Nachbarn `get-punkte-anzeige`, `format-punkte` heißen. Braucht `context`.

### 2.10 `show-erwartungen` (Z. 534)

```typ
#let show-erwartungen(grouped: false, new-page: false, erreicht: false, alle: false, teile: ()) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `grouped` | named | `false` | bool | en | Erwartungen einer Teilaufgabe in einer Zeile |
| `new-page` | named | `false` | bool | en, kebab | Erwartungshorizont auf eigener Seite |
| `erreicht` | named | `false` | bool | de | `__ / X` statt `X` |
| `alle` | named | `false` | bool | de | alle Blöcke des Dokuments zusammenfassen (neu in 0.3.1) |
| `teile` | named | `()` | array of content | de | Überschriften der Blöcke bei `alle: true` (neu in 0.3.1) |

Zwei englische und drei deutsche Schalter in einer Signatur. Feste Texte: "Erwartungshorizont", "Nr.", "Inhalt", "BE", "Summe", "Gesamtsumme", "Teil A".

### 2.11 `show-bewertung` (Z. 595)

```typ
#let show-bewertung(..args, compact: false, full: false) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `..args` | sink (nur 1. Positionsargument ausgewertet) | intern `punkte = true` | `true` / `false` / `none` | en | Dreiwert-Schalter: `true` mögliche Punkte zeigen, `false` Zeile leer, `none` Zeile weglassen |
| `compact` | named | `false` | bool | en | kleinere Schrift, niedrigere Zeilen |
| `full` | named | `false` | bool | en | zusätzliche Summenspalte je Aufgabe mit Teilaufgaben |

Benannte Argumente im Sink und mehr als ein Positionsargument werden stillschweigend ignoriert. Feste Texte: "Aufgabe", "mögliche Punkte" / "mögl. \nPunkte", "erreichte Punkte" / "Punkte".

### 2.12 `show-material` (Z. 785)

```typ
#let show-material(aufg, start: 0) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `aufg` | positional | (Pflicht) | dictionary | de, abk | Aufgaben-Datensatz |
| `start` | named | `0` | int | en/de | Versatz der Materialnummer (neu in 0.3.1, für Teilaufgaben nach dem Rumpf) |

### 2.13 `show-materialien` (Z. 810)

```typ
#let show-materialien(curr: false) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `curr` | named | `false` | bool | en, abk | nur Material der zuletzt angelegten Aufgabe |

Liest die Option `materialien` (`"seite"` Z. 814, `"seiten"` Z. 819).

### 2.14 `material` (Z. 838)

```typ
#let material(body, caption: none, label: none) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `body` | positional | (Pflicht) | content | en | Inhalt |
| `caption` | named | `none` | content / `none` | en | Beschriftung |
| `label` | named | `none` | label oder str | en | Verweisziel |

Erzeugt `figure(kind: "material", supplement: none)`. Die versprochene Beschriftung "M1-A" entsteht nicht hier, sondern in `arbeitsblatt` (liest `_state_current_material_aufgabe/_index`).

### 2.15 `aufgabe` (Z. 896)

```typ
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

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `title` | named | `none` | content / str / `none` | en | Titel; wird vom 1. Positionsargument überschrieben, wenn zwei übergeben werden |
| `method` | named | `""` | `"EA"`, `"PA"`, `"GA"`, sonst ignoriert | en (Werte de, abk) | Sozialform, setzt ein FontAwesome-Icon |
| `icons` | named | `()` | array of content | en | zusätzliche Icons |
| `large` | named | `true` | bool | en | Überschrift 1.4em statt 1.2em |
| `number` | named | `true` | bool | en | Nummer anzeigen |
| `workspace` | named | `none` | content / `none` | en | Arbeitsfläche |
| `label` | named | `none` | label oder str | en | Verweisziel |
| `..args` | sink | (Pflicht: 1 oder 2 positional) | `body` oder `title, body` | en | Rumpf, optional mit Titel davor |

Signatur durchgehend **en**, Funktionsname **de**. `method` hat als "kein Wert" den Leerstring, alle anderen `none`. Fester Text: "Aufgabe N".

### 2.16 `teilaufgabe` (Z. 1122)

```typ
#let teilaufgabe(
  item-label: none,
  label: none,
  workspace: none,
  body,
) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `item-label` | named | `none` | content / `none` | en, kebab | eigene Beschriftung statt a), b) |
| `label` | named | `none` | label oder str | en | Verweisziel |
| `workspace` | named | `none` | content / `none` / `false` | en | Arbeitsfläche; `false` wird hier ausdrücklich wie `none` behandelt (Z. 1242) |
| `body` | positional | (Pflicht) | content | en | Inhalt |

Erzeugt `figure(kind: "teilaufgabe", supplement: "Teilaufgabe")`.

### 2.17 `loesung` (Z. 1310)

```typ
#let loesung(body) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `body` | positional | (Pflicht) | content | en | Lösungstext |

Name mit `oe` statt Umlaut (durchgehend im Paket: `loesung`, `loesungen`, `moegliche-punkte-row`, `haengend`, `bloecke`).

### 2.18 `erwartung` (Z. 1363)

```typ
#let erwartung(..args) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `..args` | sink (1 oder 2 positional) | Punkte intern `0` | `body` **oder** `punkte, body` **oder** `body, punkte` | en | Erwartungstext mit optionaler Punktzahl (int/float), Reihenfolge beliebig |

Benannte Argumente werden stillschweigend ignoriert; `erwartung(punkte: 2)[...]` gibt keinen Fehler, sondern 0 Punkte.

---

## 3. Optionen, States, Schlüssel, Enum-Werte

### 3.1 Options-State `state("options", ...)` (Z. 41-53)

```typ
#let _state_options = state(
  "options",
  (
    loesungen: "keine", //
    materialien: "seiten", // "keine", "sofort", "folgend", "seiten"
    workspaces: true,
    teilaufgabe-numbering: "a)",
    punkte: "aufgaben", // "keine", "aufgaben", "teilaufgaben", "alle", "keine-summe" oder Dictionary
    punkte-position: "ende", // "ende", "rand" (nur für Teilaufgaben relevant)
    punkte-template-aufgabe: punkte => [*#punkte BE*],
    punkte-template-teilaufgabe: punkte => [*[#punkte BE]*],
  ),
)
```

| Schlüssel | Default | Im Code tatsächlich ausgewertete Werte | Sprache | Bemerkung |
|---|---|---|---|---|
| `loesungen` | `"keine"` | `"sofort"` (Z. 313, 1083, 1272, 1323, 1325), `"folgend"` (Z. 313, 1087, 1287, 1323), `"seite"` (Z. 304), `"seiten"` (Z. 311), `"nur"` (Z. 926, 966, 1049, 1065, 1076, 1261, 1285, 1323); alles andere = aus | de | Kommentar Z. 44 ist leer. `arbeitsblatt` kennt zusätzlich `"reinquetschen"`, `"false"`, `false`, `none` |
| `materialien` | `"seiten"` | `"sofort"`, `"folgend"`, `"seiten"` (Z. 1076, 1290), `"seite"` (Z. 814); alles andere = aus | de | Kommentar Z. 45 nennt `"seite"` nicht. `"folgend"` verhält sich exakt wie `"sofort"` |
| `workspaces` | `true` | bool | en, Plural | Parameter heißt `workspace` (Singular) |
| `teilaufgabe-numbering` | `"a)"` | `"a)"`, `"1."` | mix | kein echtes Numbering-Muster: `"1."` bedeutet `"1.1"` (Aufgabe.Teil) |
| `punkte` | `"aufgaben"` | `"keine"`, `"aufgaben"`, `"teilaufgaben"`, `"alle"`, `"keine-summe"` oder Dictionary `(anzeige:, position:)` | de | zwei Formen für dasselbe |
| `punkte-position` | `"ende"` | `"ende"`, `"rand"` | mix (`position` de/en) | doppelt zu `punkte.position`; Dictionary gewinnt (Z. 67, 1158-1162) |
| `punkte-template-aufgabe` | `punkte => [*#punkte BE*]` | function(punkte) -> content | mix | |
| `punkte-template-teilaufgabe` | `punkte => [*[#punkte BE]*]` | function(punkte) -> content | mix | |

Unterschlüssel des `punkte`-Dictionarys: `anzeige` (Default `"aufgaben"`), `position` (Default: `punkte-position`, sonst `"ende"`).

Fremd-Schlüssel im selben State: `"print"` (von `arbeitsblatt/0.4.0` Z. 577 hineingeschrieben, von `aufgaben` nie gelesen).

### 3.2 States und Counter (Namen = globale Schlüssel)

| Variable | State-Schlüssel | Startwert | Inhalt |
|---|---|---|---|
| `_state_aufgaben` | `"aufgaben"` | `()` | Array der Aufgaben-Datensätze |
| `_state_current_material_aufgabe` | `"current_material_aufgabe"` | `0` | Aufgabennummer des gerade gesetzten Materials |
| `_state_current_material_index` | `"current_material_index"` | `0` | laufende Materialnummer (1-basiert) |
| `_state_in_loesung` | `"in_loesung"` | `false` | gerade wird ein Lösungskasten gesetzt |
| `_state_current_aufgabe_index` | `"current_aufgabe_index"` | `-1` | 0-basierter Index der aktuellen Aufgabe |
| `_state_loesungen_gezeigt` | `"loesungen_gezeigt"` | `0` | Anzahl im Modus "nur" bereits ausgegebener Aufgaben |
| `_state_in_aufgabe` | `"in_aufgabe"` | `false` | Rumpf einer Aufgabe läuft |
| `_state_in_teilaufgabe` | `"in_teilaufgabe"` | `false` | Rumpf einer Teilaufgabe läuft |
| `_state_ta_material_vorher` | `"ta_material_vorher"` | `0` | Materialanzahl vor der aktuellen Teilaufgabe |
| `_state_theme` | `"ab-theme"` | `none` | Theme-Dictionary, gesetzt von `arbeitsblatt` |
| `_state_options` | `"options"` | siehe 3.1 | Optionen |
| `_counter_aufgaben` | `counter("aufgaben")` | | zweistufig: (Aufgabe, Teilaufgabe) |

Die Schlüssel `"options"`, `"aufgaben"`, `"in_loesung"` sind ohne Paketpräfix und damit kollisionsgefährdet; `counter("aufgaben")` und `state("aufgaben")` teilen sich denselben Namen (verschiedene Arten, technisch getrennt, aber verwirrend).

### 3.3 Datensätze

Aufgabe (angelegt Z. 945-952):

```typ
(nummer: ct_aufgaben, title: actual-title, teile: 0, loesung: (), materialien: (), erwartungen: ())
```

| Schlüssel | Typ | Sprache | Bemerkung |
|---|---|---|---|
| `nummer` | int | de | |
| `title` | content / `none` | **en** | einziger englischer Schlüssel; der Theme-Hook bekommt denselben Wert als `titel:` |
| `teile` | int | de | Anzahl Teilaufgaben |
| `loesung` | array | de, **Singular** | Einträge `(teil: int, body: content)` |
| `materialien` | array | de, Plural | Einträge `(body: content)` |
| `erwartungen` | array | de, Plural | Einträge `(teil: int, text: content, punkte: int/float)` |

Derselbe Inhalt heißt in `loesung`-Einträgen `body`, in `erwartungen`-Einträgen `text`.

### 3.4 Theme-Hooks (`state("ab-theme")`, Z. 19-31)

Dokumentiert im Kommentar Z. 22-26:

| Schlüssel | Aufruf im Paket | Zeile | Sprache der Argumente |
|---|---|---|---|
| `aufgabe` | `theme-kopf(nummer:, titel:, icons:, punkte:, large:, number:)` | 992-999 | **mix**: `nummer`, `titel`, `punkte` de neben `icons`, `large`, `number` en; `nummer` (Zahl) und `number` (bool) in einer Signatur |
| `teilaufgabe` | `h(lbl)` | 1179-1180 | |
| `loesung` | `h(titel, body)` | 38-39 | mix (`titel` de, `body` en) |
| `loesung-kopf` | `kopf-hook(kopf-titel)` | 220-223 | |
| `material-kopf` | `h[Material zu Aufgabe N]` | 790-791 | |

Genutzt, aber im Kommentar **nicht** dokumentiert:

| Schlüssel | Aufruf | Zeile |
|---|---|---|
| `marke` | `(t.marke)(nummer)`; Vorhandensein schaltet die "hängende" Darstellung für Aufgaben ohne Titel und ohne Label ein | 962, 1057 |
| `marke-breite` | Länge, Default `2.2em` | 1053 |

Nebenwirkung: Sobald irgendein Theme gesetzt ist (`_state_theme.get() != none`), werden Aufgabenrümpfe unter 9 cm unteilbar (`_zusammen`, Z. 33-36, 1061) und der Kopf `sticky` (Z. 1027, 1040). Dieser Schalter ist an keinen Hook-Namen gebunden.

### 3.5 Figure-Arten, Labels, Query-Konventionen

| Konvention | Zeile | Bedeutung |
|---|---|---|
| `figure(kind: "aufgabe", supplement: none)` | 969, 983 | Aufgabenkopf; Zähler wird in "hängend" manuell geschaltet (Z. 979) |
| `figure(kind: "teilaufgabe", supplement: "Teilaufgabe")` | 1255, 1257 | Teilaufgabe, Numbering `"a)"` oder Funktion für `"1.1"` |
| `figure(kind: "material", supplement: none)` | 839-843 | Material |
| `<_aufgaben-reset>` an `metadata("aufgaben-reset")` | 136, 328, 545 | Blockgrenze für `_aufgaben-final()` und `show-erwartungen(alle: true)` |
| `label:`-Parameter | 844, 971, 1030, 1255 | akzeptiert `label` oder `str` (wird mit `std.label` umgewandelt) |

Shortcodes (`= Titel`, `+ ...`) gibt es in `aufgaben` selbst nicht; sie liegen in `arbeitsblatt` (`aufgaben-shortcodes`), `aufgaben` enthält nur Sonderbehandlungen dafür (Z. 15-17, 922-925, 1279-1300).

### 3.6 String-Enums und Kürzel

| Stelle | Werte |
|---|---|
| `aufgabe(method:)` | `"EA"`, `"PA"`, `"GA"`, Default `""` |
| Option `loesungen` | `"keine"`, `"sofort"`, `"folgend"`, `"seite"`, `"seiten"`, `"nur"` |
| Option `materialien` | `"keine"`, `"sofort"`, `"folgend"`, `"seite"`, `"seiten"` |
| Option `punkte` / `punkte.anzeige` | `"keine"`, `"aufgaben"`, `"teilaufgaben"`, `"alle"`, `"keine-summe"` |
| Option `punkte-position` / `punkte.position` | `"ende"`, `"rand"` |
| Option `teilaufgabe-numbering` | `"a)"`, `"1."` |
| `show-bewertung(<pos>)` | `true`, `false`, `none` |
| `show-loesung(teil:)`, `show-loesungen(teil:)` | `false` oder int |
| `get-points(teil:)` | `none` oder int |

Feste Einheit in den Vorlagen: "BE" (Z. 50-51, 578); in `show-bewertung` dagegen "Punkte" (Z. 618, 620); im Code `punkte`, `points`, `be`.

---

## 4. Validierung und Fehlermeldungen

| Zeile | Meldung (wörtlich) | Sprache | Bemerkung |
|---|---|---|---|
| 919 | `panic("aufgabe expects 1 or 2 positional arguments")` | en | |
| 1380 | `panic("erwartung expects the second positional argument to be points (int or float)")` | en | sachlich ungenau: geprüft werden beide Positionen |
| 1383 | `panic("aufgabe expects 1 or 2 positional arguments")` | en | **Fehler**: steht in `erwartung`, nennt aber `aufgabe` (Kopie von Z. 919) |

Weitere Prüfungen gibt es nicht:

- `set-options` prüft weder Schlüssel noch Werte. Ein Tippfehler wie `loesungen: "sofrt"` schaltet Lösungen kommentarlos aus.
- `aufgabe(method: "XY")`, `teilaufgabe-numbering: "i)"`, `punkte: "alles"` laufen ohne Meldung in einen Fallback.
- `show-bewertung` und `erwartung` schlucken unbekannte benannte Argumente im Sink.
- Die eigentliche Optionsprüfung sitzt in `arbeitsblatt/0.4.0/src/arbeitsblatt.typ` Z. 308-319 (`_pruefe(...)`, deutsche Meldungen), also nur wirksam, wenn `aufgaben` über `arbeitsblatt` genutzt wird. Dort sind für `loesungen` und `materialien` zusätzlich `"false"`, `false`, `none`, `"reinquetschen"` erlaubt.
- Fehlermeldungen in `aufgaben` sind englisch, in `arbeitsblatt` deutsch.

---

## 5. Inkonsistenzen (mit Zeile)

### 5.1 Sprache

1. Funktionsnamen: Verb englisch, Objekt deutsch: `set-options` (113, ganz en), `reset-aufgaben` (133), `show-loesung` (151), `show-loesung-inline` (215), `show-offene-loesungen` (279), `show-loesungen` (299), `show-erwartungen` (534), `show-bewertung` (595), `show-material` (785), `show-materialien` (810), `format-punkte` (86), `get-punkte-anzeige` (56), `get-punkte-position` (65) gegenüber rein englischem `get-points` (373) und rein deutschen `aufgabe`, `teilaufgabe`, `loesung`, `erwartung`, `material`.
2. `get-points` (373) vs. `get-punkte-anzeige` (56) vs. `format-punkte(…, points)` (86): `points` und `punkte` für dieselbe Größe, dazu "BE" in der Ausgabe.
3. `show-erwartungen(grouped:, new-page:, erreicht:, alle:, teile:)` (534): en, en, de, de, de.
4. `format-punkte(teil: false, points)` (86): de + en.
5. `get-points(aufg, teil:, idx:)` (373): de-Abkürzung, de, en-Abkürzung.
6. `aufgabe(title:, method:, icons:, large:, number:, workspace:, label:)` (896-904): alles en, aber `method`-Werte `"EA"/"PA"/"GA"` sind deutsche Abkürzungen.
7. Theme-Hook `aufgabe(nummer:, titel:, icons:, punkte:, large:, number:)` (992-999): de/en gemischt; `nummer` und `number` gleichzeitig mit verschiedener Bedeutung.
8. Datensatz-Schlüssel `title` (947) vs. Hook-Argument `titel` (994) vs. Hilfsfunktionen `_loesung-kasten(titel, body)` (37).
9. Options-Schlüssel: `loesungen`, `materialien`, `punkte` (de) neben `workspaces` (en) und gemischten `teilaufgabe-numbering`, `punkte-template-aufgabe`, `punkte-template-teilaufgabe` (41-52).
10. Fehlermeldungen englisch (919, 1380, 1383), Doc-Kommentare und Ausgabetexte deutsch.
11. Code-Kommentare gemischt (`// Parse positional arguments` 906, `// Icon handling` 934, `// Update state` 941, `// Store solution` 1335 neben deutschen Kommentaren).

### 5.2 Gleiche Sache, verschiedene Namen / Typen

12. `teil` hat vier Bedeutungen: bool "ist Teilaufgabe" in `format-punkte` (86); `false`-oder-Index in `show-loesung` (151) und `show-loesungen` (299); `none`-oder-Index in `get-points` (373); Index im Datensatz (1342, 1396). Dazu `teile` = Anzahl (948) und `teile` = Array von Blocküberschriften in `show-erwartungen` (534).
13. "Kein Wert" uneinheitlich: `teil: false` (151, 299) vs. `teil: none` (373); `method: ""` (898) vs. `none` überall sonst.
14. `curr` (299, 810) vs. `idx` (373) vs. interner `curr_idx`: drei Wege, "die aktuelle Aufgabe" zu adressieren; `aufg` ist mal Datensatz (151, 215, 785), mal Nummer (373).
15. `workspace` (Parameter, Singular, 902, 1125) vs. `workspaces` (Option, Plural, 46).
16. `workspace: false` wird in `teilaufgabe` abgefangen (`not workspace in (none, false)`, 1242), in `aufgabe` nicht (`workspace != none`, 1065): dort würde `false` als Text gesetzt.
17. `label` (Verweisziel, 903, 1124, 838) vs. `item-label` (sichtbare Beschriftung, 1123) vs. interner Hook-Parameter `label`/`lbl` (23, 1167).
18. Punkteanzeige doppelt konfigurierbar: `punkte: "..."` + `punkte-position: "..."` oder `punkte: (anzeige:, position:)` (48-49, 56-71).
19. `"seite"` vs. `"seiten"`: nur ein Buchstabe Unterschied, verschiedene Bedeutung (304/311, 814/819).
20. `materialien: "folgend"` ist ein Alias für `"sofort"` (1076, 1290), bei `loesungen` sind das zwei verschiedene Modi (1083-1089).
21. Default `loesungen: "keine"` vs. `materialien: "seiten"` (44-45): gleichartige Schalter, gegensätzliche Voreinstellung.
22. Datensatz `loesung` Singular (949) vs. `materialien`, `erwartungen` Plural (950-951); Einträge `body` (1343) vs. `text` (1397).
23. `teilaufgabe-numbering`: Fallback bei unbekanntem Wert ist in `teilaufgabe` `"a)"` (1171-1177), in Lösungen, Erwartungshorizont und Bewertungstabelle aber `"1.1"` (177, 198-202, 255, 439-443, 713-717, 1329), in Verweisen wieder `"a)"` (1251-1253).
24. Gedankenstrich im Titel: `--` (158, 221) vs. `$-$` (232, 1007) für dieselbe Überschrift "Lösung N - Titel" / "Aufgabe N - Titel".
25. Punktzahl mal in Mathe-Modus (`$#_be-anzeige(...)$`, 421, 460, 464, 688, 702, 732), mal als Text (540, 663, 749).
26. Überschriftengrößen: `1.4em` (230, 1002, 1103), `1.25em` (572), `14pt` absolut (792).

### 5.3 Positional vs. named

27. `material(body, caption:, label:)` (838): Rumpf zuerst. `teilaufgabe(item-label:, label:, workspace:, body)` (1122-1127): Rumpf zuletzt. `aufgabe(..., ..args)` (896): Rumpf im Sink.
28. Titel der Aufgabe sowohl named (`title:`) als auch positional (`[Titel][Rumpf]`), positional gewinnt stillschweigend (914-917).
29. `erwartung(..args)` (1363): Punktzahl nur positional und in beliebiger Reihenfolge (1373-1378); `show-bewertung(..args)` (595): Dreiwert-Schalter als unbenanntes Positionsargument.
30. `set-options(options)` (113): Dictionary positional statt benannter Argumente.
31. `format-punkte(teil: false, points)` (86): named vor positional.

### 5.4 Schalter-Typen

32. Bool (`large`, `number`, `curr`, `inline`, `grouped`, `new-page`, `erreicht`, `alle`, `compact`, `full`, `workspaces`), String-Enum (`loesungen`, `materialien`, `punkte`), Dreiwert `true/false/none` (`show-bewertung`), `false`-oder-int (`teil`) nebeneinander.
33. Negativ-Wert im Enum: `punkte: "keine-summe"` (48, 1094) beschreibt, was nicht gezeigt wird, während die anderen Werte benennen, was gezeigt wird.
34. Positivschalter `number: true` (901) vs. Options-Enum mit `"keine"` für "aus" (44, 48); `arbeitsblatt` lässt zusätzlich `false`, `"false"`, `none` zu.

---

## 6. Kopplungen zu anderen `@schule`-Paketen

| Paket / Datei | Import | Was wird genutzt bzw. durchgereicht |
|---|---|---|
| `arbeitsblatt/0.4.0/src/arbeitsblatt.typ` Z. 1 | `#import "@schule/aufgaben:0.3.1": *` | reicht die gesamte API (und damit auch fontawesome/gentle-clues) an Nutzer weiter |
| ebd. Z. 573-580 | `set-options(("loesungen": loesungen, "materialien": materialien, "workspaces": workspaces, "punkte": punkte, "print": print, "teilaufgabe-numbering": teilaufgabe-numbering))` | Parameter von `arbeitsblatt()` heißen 1:1 wie die Options-Schlüssel; `print` ist fremd |
| ebd. Z. 308-319 | `_pruefe(...)` | Validierung der Werte, die `aufgaben` selbst nicht prüft; erlaubt mehr Werte (`"reinquetschen"`, `false`, `"false"`, `none`) als `aufgaben` kennt |
| ebd. Z. 378-379, 656-657 | `_state_current_material_aufgabe`, `_state_current_material_index` | Beschriftung "M1-A" der Materialien |
| ebd. Z. 383, 661 | `_counter_aufgaben` | Nummerierung von Verweisen und Shortcodes |
| ebd. Z. 391, 397, 1494 | `_state_options` | liest `teilaufgabe-numbering` (dort mit Default `"1."`, in `aufgaben` ist der Default `"a)"`) und `workspaces` |
| ebd. Z. 1179, 1307, 1330 | `state("options", (:))` | Zugriff auf den Options-State über den rohen Namen statt über `_state_options` |
| ebd. Z. 616, 1522 | `_state_theme` | Theme setzen und lesen |
| ebd. Z. 695 | `_state_in_loesung` | Shortcodes in Lösungen unterdrücken |
| ebd. Z. 707, 712, 716 | `show-offene-loesungen()`, `show-materialien()`, `show-loesungen()` | Ausgabe am Dokumentende für `"seite"`, `"seiten"`, `"reinquetschen"`, `"nur"` |
| ebd. Z. 615 | `reset-aufgaben()` | je Variante im Bundle |
| `arbeitsblatt/0.4.0/src/themes.typ` | (kein Import) | liefert Dictionaries mit `aufgabe`, `teilaufgabe`, `loesung`, `loesung-kopf`, `material-kopf`, `marke`, `marke-breite` |
| `klassenarbeit/0.4.0/src/klassenarbeit.typ` Z. 1 | `#import "@schule/arbeitsblatt:0.4.0": *` | bekommt `aufgaben` nur indirekt |
| ebd. Z. 62, 205-220 | Parameter `punkte-template` (function oder `(aufgabe:, teilaufgabe:)`) | wird zu `set-options((punkte-template-aufgabe: ..., punkte-template-teilaufgabe: ...))`; dritter Name/Form für dieselbe Einstellung |
| ebd. Z. 314-327 | Parameter `erwartungen` (bool oder Dictionary) | Dictionary wird als `show-erwartungen(..einstellungen)` durchgereicht, die en/de-gemischten Namen `grouped`, `new-page`, `erreicht`, `alle`, `teile` sind damit Teil der klassenarbeit-API |
| `mathematik/0.0.2/mathematik.typ` Z. 39 | `import "@schule/aufgaben:0.1.2": loesung, teilaufgabe` | **veraltet**: eigene, ältere Instanz mit eigenen States; `arbeitsblatt/0.4.0` Z. 1209 ff. ersetzt deshalb `teilaufgaben` durch eine eigene Fassung |
| `mathematik/0.0.1/mathematik.typ` Z. 3 | `@schule/aufgaben:0.0.4` | veraltet |
| `aufgaben/0.3.1/docs/content.typ` Z. 23, 35 | Beispieltext `#import "@schule/aufgaben:0.3.0": *` | Doku der 0.3.1 nennt noch 0.3.0; Z. 315 nennt den Wert `"reingequetscht"`, der Code kennt `"reinquetschen"` |
| `klassenarbeit/0.4.0/docs/content.typ` Z. 289, 480 | `import "@schule/aufgaben:0.3.0": reset-aufgaben` | **veraltet**: wirkt auf dieselben States (Schlüssel identisch), setzt aber die Reset-Marke `<_aufgaben-reset>` nicht, die `_aufgaben-final()` und `show-erwartungen(alle: true)` in 0.3.1 brauchen |
| `schuldocs/0.2.0`, `0.3.0` `src/display.typ` Z. 136 | Doc-Beispiel mit `aufgaben:0.3.0` | veraltet |
| `tests/aufgaben-*.typ` (5 Dateien) | `@schule/aufgaben:0.3.1` | aktuell |

Ältere `arbeitsblatt`-Versionen binden `aufgaben` 0.0.1 bis 0.3.0 ein (0.3.0-0.3.2 -> `aufgaben:0.3.0`).

---

## 7. Vergleich der Versionen

### 7.1 `0.3.0` -> `0.3.1` (öffentliche Signaturen)

| Funktion | 0.3.0 | 0.3.1 |
|---|---|---|
| `show-erwartungen` | `(grouped: false, new-page: false, erreicht: false)` | `(grouped: false, new-page: false, erreicht: false, alle: false, teile: ())` |
| `show-material` | `(aufg)` | `(aufg, start: 0)` |
| alle übrigen | unverändert | unverändert |

Neu in 0.3.1 (intern): `_state_ta_material_vorher`, `_state_theme` + `_theme-hook`, `_zusammen`, `_loesung-kasten`, `_be-runden`, `_be-anzeige`, `_aufgaben-final`, `_rechter-textrand`, `_erwartungen-zeilen`, Reset-Marke `<_aufgaben-reset>`. Optionen und Defaults sind identisch. 0.3.0 wird parallel weitergepflegt (Commit d1af5b0 vom 03.11. änderte beide Versionen: `_ist-flex-workspace`, `_flex-fest`).

### 7.2 `aufgaben.typ.orig`

- Nicht versioniert (`?? aufgaben/0.3.1/aufgaben.typ.orig`), 1226 Zeilen, Datum 02.11.
- Entspricht dem Stand des Commits 76a9e28 ("arbeitsblatt 0.4.0, aufgaben 0.3.1: Themes") plus genau zwei Zeilen (`// Mindestabstand zum Text ...` / `h(1.5em)`). Typischer Sicherungsrest eines `patch`-Laufs.
- Gegenüber der aktuellen Datei fehlen (462 Diff-Zeilen): `_state_ta_material_vorher`, `_be-runden`/`_be-anzeige`, Reset-Marke, `_aufgaben-final`, `_rechter-textrand`, `_erwartungen-zeilen`, `show-erwartungen(alle:, teile:)`, `show-material(start:)`, `_ist-flex-workspace`/`_flex-fest`, die Shortcode-Nachbehandlung in `teilaufgabe`, der `aufg < 1`-Schutz in `get-points`.
- Enthält nichts, was in der aktuellen Datei fehlt. Kann gelöscht werden.

---

## 8. Altlasten, toter Code, Fehler

| Zeile | Befund |
|---|---|
| 65-71 | `get-punkte-position` wird nirgends aufgerufen (toter Code). |
| 1153-1162 | Kopie der Logik von `get-punkte-anzeige`/`get-punkte-position` inline in `teilaufgabe`. |
| 313-317 | `else if ... in ("sofort", "folgend") { show-loesung(...) } else { show-loesung(...) }`: beide Zweige identisch. |
| 687-693 | `if punkte == true {...} else if punkte == false {...} else if punkte == true {...}`: dritter Zweig unerreichbar. |
| 757-780 | Beide Tabellenvarianten nennen `rows: (auto, auto, row-height, row-height)`, auch die dreizeilige; fast vollständige Doppelung. |
| 472-482 | `else { 0.5pt }` unerreichbar (die drei Bedingungen davor decken alle Fälle ab); Kommentar Z. 478 ist eine falsche Kopie von Z. 475. |
| 488-498 | Zwei Zweige mit identischen drei `rows.push`-Zeilen. |
| 151-212 / 215-268 | `show-loesung` und `show-loesung-inline` duplizieren das Gruppieren der Teillösungen (166-186 vs. 243-264); dasselbe Gruppierungsmuster noch einmal in 425-432 und 630-638. |
| 1020-1043 | Zwei fast identische `block(...)`-Aufrufe, nur wegen des Labels. |
| 1213-1219 | `else if punkte-position == "rand" { body } else { body }`: zwei identische Zweige. |
| 1273 | `let curr_aufg = ...` in `teilaufgabe` unbenutzt. |
| 1383 | Falsche Fehlermeldung (`aufgabe` statt `erwartung`). |
| 1372 | Kommentar `// Two arguments: title, body` in `erwartung` (Kopie aus `aufgabe`). |
| 44 | Kommentar zu `loesungen` leer; Z. 45 unvollständig (`"seite"` fehlt). |
| 22-26 | Hook-Dokumentation ohne `marke`, `marke-breite`. |
| 292-297 | Doc von `show-loesungen`: `teil (boolean)` mit Beschreibung "Wenn eine Zahl". |
| 360-372 | Doc von `get-points` ohne `idx`. |
| 831 | Doc von `material` verspricht "M1-A"; die Beschriftung entsteht erst in `arbeitsblatt`. Ohne `arbeitsblatt` ist die Figure unnummeriert beschriftet. |
| 6-7, 788, 797 | `_state_current_material_*` werden in `aufgaben` nur geschrieben, gelesen ausschließlich in `arbeitsblatt`: verdeckte Schnittstelle. |
| 133-149 | `reset-aufgaben` lässt `_state_in_aufgabe`, `_state_in_teilaufgabe`, `_state_ta_material_vorher` aus. |
| 141-142 | `reset-aufgaben` setzt auch die globalen Zähler für `image`- und `table`-Figures zurück (Nebenwirkung außerhalb des Pakets). |
| 1-2 | `*`-Importe von fontawesome und gentle-clues verschmutzen den Namensraum aller abhängigen Pakete; `arbeitsblatt/0.4.0` importiert fontawesome noch einmal mit `*` (Z. 38) und gentle-clues bewusst als `_gc` (Z. 44), bekommt die Namen über `aufgaben` aber trotzdem. |
| 50-51, 578, 618-620 | "BE" fest verdrahtet, an anderer Stelle "Punkte"; nicht einstellbar außer über die beiden Template-Funktionen. |
| 1065 vs. 1242 | `workspace: false` in `aufgabe` nicht abgefangen. |
| 1076 | `_state_aufgaben.get().last()` ohne Leerprüfung (unkritisch, weil direkt nach `push`, aber fragil). |
| Datei | `aufgaben.typ.orig` unversioniert im Paketordner (siehe 7.2). |
| Datei | `README.md` leer; `typst.toml` ohne `compiler`/`authors`. |
| docs | `docs/content.typ` der 0.3.1 zeigt `@schule/aufgaben:0.3.0` und den nicht existierenden Wert `"reingequetscht"`. |
