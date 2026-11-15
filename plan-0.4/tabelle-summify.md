# Umbenennungstabelle summify 0.1.0 → 0.5.0

Grundlage: `UMSETZUNG-0.5.0.md` (Vorrang), `konvention.md`, Ist-Zustand aus
`inventar-hilfspakete.md` Abschnitt 3 und `summify/0.1.0/summify.typ`.
Abkürzungen in der Spalte „Begründung": G = Glossarzeile (Konvention 3),
§ = Abschnitt der Konvention, L = Lint-Regel (Konvention 10).

summify ist bereits englisch und kebab-case. Geändert wird nur, was eine Regel
der Konvention verlangt; alles andere bleibt. Kein Funktionsname von summify ist
ein Baustein (kein Eintrag in `bausteine-de.txt`): `topic`, `section`, `cell`
sind Layouthelfer einer Vorlage mit englischem Eigennamen.

## 1. Öffentliche Namen

| alt | neu | Art | Begründung |
|---|---|---|---|
| `summify` | `summify` | unverändert | Funktionsname = Paketname |
| `themes` | `themes` | unverändert | Wert (§ 2.1, Werte und Konstanten) |
| `set-theme` | `set-theme` | unverändert | Aktion `set-…` (§ 4.1) |
| `update-theme` | `set-theme-overrides` | umbenannt, Stub | § 4.1: erlaubte Verben sind `show set reset get has is format`; der Name nimmt das Wort des Kopfparameters `theme-overrides` auf |
| `compose` | `cell-grid` | umbenannt, Stub | § 4.1: Helfer ist ein Substantiv, kein Imperativ außerhalb der Verbliste |
| `beside` | `beside` | unverändert | englisch, kein Verb; Wort in `words-en-zusatz.txt` |
| `below` | `below` | unverändert | wie `beside` |
| `cols` | `cell-columns` | umbenannt, Stub | § 2.2: `cols` ist eine nicht zugelassene Abkürzung; `columns` allein überdeckte das Builtin (§ 4.5) |
| `rows` | `cell-rows` | umbenannt, Stub | Gegenstück zu `cell-columns`; ein Paar mit zwei Bildungsweisen wäre nicht mehr einheitlich |
| `topic` | `topic` | unverändert | englisch, Substantiv |
| `section` | `section` | unverändert | englisch, Substantiv; Wort in `words-en-zusatz.txt` |
| `content` | `cell` | umbenannt, Stub | § 4.5: kein exportierter Name heißt wie ein Name aus `std` (`content` ist der Typ); G79 führt `content` als verbotenes Synonym |
| `_state-hide-content`, `_state-theme`, `_merge-dict` | `internal.visible-state`, `internal.theme-state`, `internal.merge` | intern | § 7.2, L19: kein exportierter Unterstrich-Name |

## 2. Signaturen

### 2.1 `summify`

```typ
// alt (summify.typ Z. 218)
#let summify(title: "", paper: "a3", flipped: true, hide-content: false,
  theme: "default", theme-overrides: (:), body) = context { }
// neu
#let summify(
  title: none,            // W4 content | str | none
  paper: "a3",            // W9
  landscape: true,        // W1
  visible: true,          // W1 Inhalte der Zellen zeigen
  theme: "default",       // W8 str | dictionary | none
  theme-overrides: (:),   // dictionary, Gruppen colors, spacing, sizes, typography
  ..deprecated,
  body,
) = { }
```

| alt | neu | Art | Wertabbildung | Begründung |
|---|---|---|---|---|
| `title: ""` | `title: none` | Vorgabe | `""` → Argument löschen | § 5.2, L8: leerer Text ist `none`; PDF gleich (leere Kopfzeile) |
| `paper` | `paper` | unverändert | – | G50 |
| `flipped: true` | `landscape: true` | umbenannt | – | G51 |
| `hide-content: false` | `visible: true` | umbenannt, gewendet | `false` → löschen; `true` → `visible: false` | § 4.3, L4: Präfix `hide-`; ein Name mit `cell(visible:)` |
| `theme` | `theme` | unverändert | – | G61 |
| `theme-overrides` | `theme-overrides` | unverändert | Schlüssel nach 2.7 | wie `variant-overrides` |
| – | `..deprecated` | neu | – | § 8.4, § 9 |
| `body` | `body` | unverändert | – | G79 |

### 2.2 `set-theme`, `set-theme-overrides`

```typ
// alt (Z. 161, 188)
#let set-theme(theme) = { }
#let update-theme(..params) = context { }
// neu
#let set-theme(theme) = { }            // str | dictionary, führendes Hauptargument
#let set-theme-overrides(
  colors: (:), spacing: (:), sizes: (:), typography: (:),
  ..deprecated,
) = { }
```

| alt | neu | Art | Begründung |
|---|---|---|---|
| `set-theme(theme)` | unverändert | – | ein führendes Hauptargument (§ 4.4) |
| `update-theme(..params)` | `set-theme-overrides(colors:, spacing:, sizes:, typography:, ..deprecated)` | umbenannt, Sink aufgelöst | § 4.4 Nr. 5: kein Durchreich-Sink; die vier Gruppen sind deklariert. Eine leere Gruppe ändert nichts, das Verhalten bleibt |
| englische `panic`-Texte (Z. 167, 173) | Meldungen über `check-value` | – | § 8, L21 |

### 2.3 `cell-grid`, `beside`, `below`, `cell-columns`, `cell-rows`

```typ
// alt (Z. 292–390)
#let compose(direction: "horizontal", lines: false, gap: auto, ratios: none, ..children) = context { }
#let beside(gap: auto, ratios: none, ..children) = { }
#let below(gap: auto, ratios: none, ..children) = { }
#let cols(gap: auto, ratios: none, ..children) = context { }
#let rows(gap: auto, ratios: none, ..children) = context { }
// neu
#let cell-grid(direction: "horizontal", dividers: false, gutter: auto, ratios: none, ..cells) = { }
#let beside(gutter: auto, ratios: none, ..cells) = { }
#let below(gutter: auto, ratios: none, ..cells) = { }
#let cell-columns(gutter: auto, ratios: none, ..cells) = { }
#let cell-rows(gutter: auto, ratios: none, ..cells) = { }
```

| alt | neu | Art | Begründung |
|---|---|---|---|
| `direction` | `direction` | unverändert | Werte `"horizontal"`, `"vertical"` bleiben; jeder andere Wert ist jetzt ein Fehler (früher still „vertikal") – § 8.4 |
| `lines: false` (nur `compose`) | `dividers: false` (nur `cell-grid`) | umbenannt | `lines` ist das Parameterwort des Bausteins `liniert` (§ 2.1b) und meint hier kein Linienmuster (Vorbild: R12 in `tabelle-fachpakete.md`) |
| `lines:` bei `beside`, `below`, `cols`, `rows` (undokumentiert, über den Sink an `compose` durchgereicht) | entfällt | entfernt mit Hinweis | § 4.4 Nr. 5: kein Durchreich-Sink. Meldung „`lines` gibt es nicht mehr" nennt den gleichwertigen Aufruf `cell-grid(direction: …, dividers: true)` bzw. `cell-grid(direction: …)`. Ebenso entfällt das durchgereichte `direction:` (unbekannter Parameter) |
| `gap: auto` | `gutter: auto` | umbenannt | G33; G11 führt `gap` als verbotenes Synonym |
| `ratios` | `ratios` | unverändert | Wort in `words-en-zusatz.txt`. Geht wie bisher an `columns`/`rows` von `grid`; geprüft wird deshalb auf dessen Typen: `array`, `int`, `length`, `ratio`, `relative`, `fraction`, `auto`, dazu `none` (gleichmäßig) |
| `..children` | `..cells` | Sink umbenannt | L16; für Aufrufe unsichtbar. Der Sink nimmt die Inhalte und fängt alte Namen ab |

### 2.4 `topic`

```typ
// alt (Z. 413) und neu, bis auf den Sink gleich
#let topic(title: none, height: 100%, width: 100%, fill: auto, stroke: auto, radius: auto,
  ..deprecated, body) = { }
```

Alle Parameter unverändert (G13, G31, G32, G27, G30; `radius` besteht den
Durchreichtest). Neu: `..deprecated`, Typprüfung, `title: ""` ist ein Fehler
mit Abhilfe (§ 5.2). `radius` nimmt wie bisher ein Maß oder `auto`, ohne
`title` auch ein Dictionary mit einzelnen Ecken (geht unverändert an `box`);
mit `title` war ein Dictionary schon in 0.1.0 ein Typst-Fehler und hat jetzt
eine eigene Meldung.

### 2.5 `section`

```typ
// alt (Z. 487)
#let section(title, fill: auto, height: auto) = context { }
// neu
#let section(fill: auto, height: auto, ..deprecated, body) = { }
```

| alt | neu | Art | Begründung |
|---|---|---|---|
| `title` (positional) | `body` (positional, zuletzt) | umbenannt | G79, § 4.4, L15: der einzige Inhalt heißt `body` und steht zuletzt. Für Aufrufe unsichtbar: `section[Text]`, `section("Text")` und `section(none)` (leere Leiste) bleiben |
| `fill`, `height` | unverändert | – | G27, G32 |

### 2.6 `cell` (alt `content`)

```typ
// alt (Z. 522)
#let content(title: none, inset: auto, align-content: left, hide: auto, body) = { }
// neu
#let cell(title: none, inset: auto, align: left, visible: auto, ..deprecated, body) = { }
```

| alt | neu | Art | Wertabbildung | Begründung |
|---|---|---|---|---|
| `title` | `title` | unverändert | – | G13 |
| `inset` | `inset` | unverändert | – | Durchreichtest |
| `align-content: left` | `align: left` | umbenannt | – | § 1.2 Schritt 2: heißt wie Typst; im Rumpf steht `std.align` |
| `hide: auto` | `visible: auto` | umbenannt, gewendet | `auto` → löschen; `true` → `visible: false`; `false` → `visible: true` | § 4.3; behebt zugleich den Überdeckungsfehler (der Parameter `hide` verdeckte das Builtin, `hide(box(…))` brach mit „expected function, found auto" ab) |

### 2.7 Thema-Dictionary (`themes`, `theme`, `theme-overrides`, `set-theme-overrides`)

```
colors:     primary, on-primary, surface, border
spacing:    page (x, y, top), topic, section, cell
sizes:      title (height, font-size), header (height, font-size), border, radius
typography: font, math-font, font-size, weights (title, header)
```

| alt | neu | Art | Begründung |
|---|---|---|---|
| `spacing.content` | `spacing.cell` | umbenannt | der Schlüssel heißt wie die Funktion, deren Abstand er setzt (wie `spacing.topic`, `spacing.section`) |
| `sizes.title.text`, `sizes.header.text` | `sizes.title.font-size`, `sizes.header.font-size` | umbenannt | G49 |
| `typography.base-size` | `typography.font-size` | umbenannt | G49 |
| alle übrigen Schlüssel | unverändert | – | englisch, kebab-case |
| Themennamen `"modern-blue"`, `"warm-sunset"`, `"dark-pro"`, `"default"` | unverändert | – | Eigennamen als Werte (§ 2.1) |

Meldung für alte Schlüssel mit ganzem Weg: „Schlüssel `spacing.content` in
`theme-overrides` heißt jetzt `spacing.cell`" (bei `set-theme-overrides` ohne
„in …", dort sind die Gruppen selbst Parameter).

Neu: unbekannte Schlüssel sind auf jeder Ebene ein Fehler (früher still
hinzugefügt); ein eigenes Thema-Dictionary muss vollständig sein (§ 5.4, § 8.4).

### 2.8 States

| alt | neu | Begründung |
|---|---|---|
| `state("summify-hide", false)` | `state("schule/summify/visible@1", true)` | § 7.3; Wert gewendet wie der Parameter |
| `state("summify-theme", themes.default)` | `state("schule/summify/theme@1", themes.default)` | § 7.3 |

## 3. Behobene Fehler

| Fehler | Behebung |
|---|---|
| `content(hide:)` verdeckt das Builtin `hide`; der Lernmodus (`hide-content: true`) bricht mit „expected function, found auto" ab (Inventar 3.5) | der Parameter heißt `visible`, der Rumpf ruft das Builtin `hide` |

## 4. Neue Wörter

In `words-en-zusatz.txt` angehängt: `colors`, `sizes`, `typography`
(Gruppen des Themas, jetzt Parameter von `set-theme-overrides`), `dividers`,
`ratios`, `radius`, `beside`, `below`, `section`, `horizontal`, `vertical`.
Mitbenutzt: `direction` (stand schon dort). Kein neuer deutscher Baustein.

## 5. Maschinenlesbarer Anhang

Lesart wie in `tabelle-fachpakete.md` Abschnitt 12: Schlüssel sind die alten
Namen, mit dem Paket qualifiziert; `funktionen` bildet auf die neuen ab; in
`werte` steht `null` für „Argument löschen"; Positionsparameter stehen nicht in
`parameter`.

```json
{
  "funktionen": {
    "summify.content": "summify.cell",
    "summify.cols": "summify.cell-columns",
    "summify.rows": "summify.cell-rows",
    "summify.compose": "summify.cell-grid",
    "summify.update-theme": "summify.set-theme-overrides",
    "summify._state-hide-content": "summify.internal.visible-state",
    "summify._state-theme": "summify.internal.theme-state",
    "summify._merge-dict": "summify.internal.merge"
  },
  "stubs": {
    "summify.content": "cell",
    "summify.cols": "cell-columns",
    "summify.rows": "cell-rows",
    "summify.compose": "cell-grid",
    "summify.update-theme": "set-theme-overrides"
  },
  "parameter": {
    "summify.summify": { "flipped": "landscape", "hide-content": "visible" },
    "summify.compose": { "lines": "dividers", "gap": "gutter" },
    "summify.beside": { "gap": "gutter" },
    "summify.below": { "gap": "gutter" },
    "summify.cols": { "gap": "gutter" },
    "summify.rows": { "gap": "gutter" },
    "summify.content": { "align-content": "align", "hide": "visible" },
    "summify.summify.theme-overrides[]": { "spacing.content": "spacing.cell", "sizes.title.text": "sizes.title.font-size", "sizes.header.text": "sizes.header.font-size", "typography.base-size": "typography.font-size" },
    "summify.summify.theme[]": { "spacing.content": "spacing.cell", "sizes.title.text": "sizes.title.font-size", "sizes.header.text": "sizes.header.font-size", "typography.base-size": "typography.font-size" },
    "summify.set-theme.args[0][]": { "spacing.content": "spacing.cell", "sizes.title.text": "sizes.title.font-size", "sizes.header.text": "sizes.header.font-size", "typography.base-size": "typography.font-size" },
    "summify.update-theme": { "spacing.content": "spacing.cell", "sizes.title.text": "sizes.title.font-size", "sizes.header.text": "sizes.header.font-size", "typography.base-size": "typography.font-size" }
  },
  "werte": {
    "summify.summify": {
      "title": { "\"\"": null },
      "hide-content": { "false": null, "true": "false" }
    },
    "summify.content": {
      "hide": { "auto": null, "true": "false", "false": "true" }
    }
  },
  "entfernt": {
    "summify.beside": { "lines": "cell-grid(direction: \"horizontal\", dividers: true)" },
    "summify.below": { "lines": "cell-grid(direction: \"vertical\", dividers: true)" },
    "summify.cols": { "lines": "cell-grid(direction: \"horizontal\")" },
    "summify.rows": { "lines": "cell-grid(direction: \"vertical\")" }
  },
  "kontext": [
    { "funktion": "summify.section", "regel": "Positionsparameter `title` heißt `body`; Aufrufe bleiben unverändert" },
    { "funktion": "summify.compose|beside|below|cols|rows", "regel": "Sink `..children` heißt `..cells`; Aufrufe bleiben unverändert" }
  ],
  "states": {
    "summify-hide": "schule/summify/visible@1",
    "summify-theme": "schule/summify/theme@1"
  },
  "neu": {
    "summify.summify": ["..deprecated"],
    "summify.set-theme-overrides": ["colors", "spacing", "sizes", "typography", "..deprecated"],
    "summify.topic": ["..deprecated"],
    "summify.section": ["..deprecated"],
    "summify.cell": ["..deprecated"]
  }
}
```

## 6. Zweifelsfälle

1. **`content` → `cell`.** Die Funktion ist die meistbenutzte des Pakets; die
   Umbenennung trifft jedes Dokument. Sie folgt aus § 4.5 (Name aus `std`).
   Solange der Stub `content` exportiert wird, verdeckt ein Wildcard-Import
   weiterhin den Typ `content` – wie in 0.1.0. Wer das nicht will, importiert
   namentlich.
2. **`cols`/`rows` → `cell-columns`/`cell-rows`.** Zwingend ist nur `cols`
   (Abkürzung). `rows` zieht mit, damit das Paar gleich gebildet bleibt.
3. **Schlüssel `sizes.header`, `weights.header`.** Gemeint ist die Leiste von
   `section`; `header` ist im Glossar der Seitenkopf (G54). Nicht umbenannt,
   weil keine Regel den Schlüssel verbietet; für eine spätere Fassung wäre
   `section` der folgerichtige Name.
4. **Schlüssel `spacing.topic`, `spacing.section`, `spacing.cell`** heißen wie
   Funktionen des Pakets (L14 nennt auch Schlüssel). Belassen: die Schlüssel
   sagen genau, wessen Abstand sie setzen, und ein Schlüssel überdeckt nichts.
5. **`theme: none`** bedeutet „aktives Thema stehen lassen", nicht „kein
   Thema" (W8 sähe dafür `auto` vor). Belassen, weil eine Umdeutung das
   Verhalten änderte.
