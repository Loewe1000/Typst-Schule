# Inventar Hilfspakete (@schule)

Stand: 2026-11-14, Typst 0.15.1. Pfade relativ zu
`/Users/alexander/Library/Application Support/typst/packages/schule`.
Alle Dateien wurden vollständig gelesen; die Kompilierbarkeit wurde je Paket
mit einem Minimaldokument geprüft (Ergebnis in Abschnitt 0).

Legende Spalte **Art**: pos = positional, named = benannt, sink = `..args`.
Legende Spalte **Sprache**: de / en / gemischt / Abk.

---

## 0. Überblick

| Paket | Version(en) im Repo | Entrypoint | API-Sprache | Schreibweise | Kompiliert unter 0.15.1? | Noch benutzt von |
|---|---|---|---|---|---|---|
| options | 0.0.5 | `options.typ` | en | zusammengeschrieben (`addconfig`, `getconfig`), `__snake`-intern | NEIN (`locate(func)` entfernt, `type(x) == "string"`) | nur Altversionen: arbeitsblatt 0.0.2–0.0.7, 0.1.0, 0.1.1, 0.1.3; aufgaben 0.0.1 |
| typopst | 0.0.1 | `typopst.typ` | en | kebab-case (`add-option`), teils zusammen (`getconfig`), `_unknown` mit Unterstrich | NEIN (wie options) | nur Altversionen: arbeitsblatt 0.1.4–0.1.9; aufgaben 0.0.2–0.0.4 |
| summify | 0.0.1, 0.0.2, 0.0.3, 0.1.0 | `summify.typ` (0.0.1/0.0.2: `cheatsheets.typ`) | en | kebab-case | ja, aber `hide-content: true` / `hide: true` bricht ab (Bug) | niemand außer der eigenen Doku |
| gutachten | 0.0.1, 0.0.2 | `gutachten.typ` | gemischt (de-Namen, `set-`-Präfix, `print`, `font`) | kebab-case + Umlaut (`kürzel`); `bewertung.typ`: snake_case | Entrypoint ja; `bewertung.typ` NEIN | niemand (nur eigene Doku/Beispiel) |
| flashcards | 0.0.1 | `flashcards.typ` | en | zusammengeschrieben (`cardnumber`, `letter8up`) | NEIN (`locate(func)`) | niemand (nur eigene Doku) |
| typlace | 0.0.1, 0.0.2 | `typlace.typ` | de (konsequent), `seed`/`layout`/`rotation` en | kebab-case, ae/oe/ue statt Umlaut | ja | niemand (nur eigene Doku) |
| eduki | 0.1.0 | `src/eduki.typ` | en (eine Ausnahme: `strichbox`) | kebab-case, `layout-1P-1L` mit Großbuchstaben | ja (Font-Warnungen) | niemand |
| angela | 0.0.1 | `angela.typ` | gemischt (`brief` de, `angela-dark` en) | kebab-case | ja (Font-Warnung „calibri“) | niemand (nur eigene Doku) |
| abbozza | 0.0.1 | `hathi-render.typ` | en | kebab-case | ja | niemand (nur eigene Doku) |

Kein einziges der neun Pakete wird von einer aktuellen Version von
arbeitsblatt (0.4.0), aufgaben (0.3.1), klassenarbeit (0.4.0) oder
klausurboegen (0.0.5) importiert.

---

## 1. options 0.0.5 — `options/0.0.5/options.typ` (208 Zeilen)

Zweck: globaler Options-Speicher (State `@options`) plus deklarative
Argumentprüfung (State `@config`). Vorläufer von typopst.
Nutzung: `#import "@schule/options:0.0.5"` (Modul-Import, Aufruf als `options.get(...)`).

### 1.1 Öffentliche Namen

Kein Top-Level-Name ohne Unterstrich ist „privat“; die mit `__`/`___`
beginnenden Namen sind technisch importierbar, aber als intern gemeint.

| Zeile | Name | Art | Signatur (wörtlich) |
|---|---|---|---|
| 1 | `___s_options` | State (intern, 3 Unterstriche) | `state("@options", (__version: "0.0.5"))` |
| 5 | `__getlocal` | intern | `__getlocal( name, loc )` |
| 15 | `__getfinal` | intern | `__getfinal( name, loc )` |
| 25 | `__get` | intern | `__get( name, func, default, final, loc )` |
| 42 | `get` | Funktion | `get( name, func, default:none, final:false, loc:none )` |
| 52 | `update` | Funktion | `update( name, value )` |
| 59 | `remove` | Funktion | `remove( name )` |
| 66 | `display` | Funktion | `display( name, format: value => value, default:none, final:false )` |
| 71 | `__s_config` | State (intern, 2 Unterstriche) | `state("@config", (:))` |
| 73 | `addconfig` | Funktion | `addconfig(name, type: ("string", "content"), required: false, default: none, valid: none, store: true, pipe: none, code: none)` |
| 99 | `getconfig` | Funktion | `getconfig( name, final:false )` |
| 111 | `parseconfig` | Funktion | `parseconfig( unknown:none, ..args )` |
| 185 | `ignore` | Variable | `none` |
| 186 | `store` | Funktion | `store(k, v)` |
| 187 | `fail` | Funktion | `fail(k, v)` |
| 192 | `arg` | Funktion | `arg( var, key, default )` |
| 197 | `extract` | Funktion | `extract( var, prefix:"", ..keys )` |

### 1.2 Parameter

**`get` (Z. 42)**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `name` | pos | – | str | en | Optionsschlüssel |
| `func` | pos | – | function oder `none` | en/Abk. | Callback, erhält den Wert |
| `default` | named | `none` | any | en | Ersatzwert, wenn Option fehlt/`none` |
| `final` | named | `false` | bool | en | `state.final` statt `state.at` |
| `loc` | named | `none` | location/`none` | Abk. en | Ort; ohne → `locate(...)` |

**`update` (Z. 52)**: `name` (pos, str, en), `value` (pos, any, en).

**`remove` (Z. 59)**: `name` (pos, str, en).

**`display` (Z. 66)**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `name` | pos | – | str | en | Optionsschlüssel |
| `format` | named | `value => value` | function | en | Formatierer (heißt in `get` `func`!) |
| `default` | named | `none` | any | en | Ersatzwert |
| `final` | named | `false` | bool | en | Endwert |

**`addconfig` (Z. 73)**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `name` | pos | – | str | en | Optionsname |
| `type` | named | `("string", "content")` | Typname-String oder Array davon (alte String-Typnamen!) | en | erlaubte Typen; überschattet Builtin `type` |
| `required` | named | `false` | bool | en | Pflichtoption |
| `default` | named | `none` | any | en | Standardwert |
| `valid` | named | `none` | Array/`none` | en | erlaubte Werte (in typopst: `choices`) |
| `store` | named | `true` | bool | en | Wert in `@options` ablegen |
| `pipe` | named | `none` | Array von Paaren/`none` | en | setzt Folgeoptionen (TODO-Kommentar Z. 161) |
| `code` | named | `none` | function/`none` | en | Transformationsfunktion |

Gespeicherter Dictionary-Eintrag (Z. 84–94): Schlüssel `option` (immer
`"option"`), `type`, `name`, `required`, `default`, `valid`, `store`,
`pipe`, `code`; später ergänzt um `value` (Z. 156).

**`getconfig` (Z. 99)**: `name` (pos, str), `final` (named, `false`, bool) —
`final` wird ignoriert (Z. 101 auskommentiert).

**`parseconfig` (Z. 111)**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `unknown` | named | `none` | function `(k, v) =>` / `none` | en | Handler für unbekannte Optionen: `ignore`, `store`, `fail` |
| `..args` | sink | – | nur named genutzt | en | übergebene Optionen (positionale „Not supported for now“, Z. 113) |

**`store(k, v)` / `fail(k, v)`**: beide pos; `k`, `v` = Abkürzungen (en).

**`arg` (Z. 192)**: `var` (pos, arguments), `key` (pos), `default` (pos — hier positional, überall sonst named).

**`extract` (Z. 197)**: `var` (pos, arguments), `prefix` (named, `""`, str), `..keys` (sink, named = Schlüssel mit Defaults).

### 1.3 Schlüssel / States

- State `"@options"` (Initialwert `(__version: "0.0.5")`), State `"@config"`.
  **Kollision:** typopst 0.0.1 benutzt exakt dieselben State-Namen
  `"@options"`/`"@config"` mit anderem Initialwert `(:)`.
- Typ-Enum als Strings: `"string"`, `"content"`, `"none"`, `"array"`,
  `"function"`, `"location"` (alte Typst-Typnamen).

### 1.4 Validierung / Fehlermeldungen (alle englisch)

| Zeile | Meldung |
|---|---|
| 6, 16 | `"loc needs to be a valid location"` |
| 127 | `"Option '<name>' not provided but is required."` |
| 139 | `"Wrong type for option '<name>': got '<typ>', but expected one of '<…>'"` |
| 144 | `"Value for option '<name>' not allowed: got '<v>' but expected one of '<…>'"` |
| 188 | `"Unexpected option '<k>'"` (nur wenn `unknown: fail`) |

Unbekannte Optionen werden nur geprüft, wenn der Aufrufer `unknown:` setzt (Z. 175–181).

### 1.5 Altlasten / Fehler

- Bricht unter Typst 0.15.1 ab: `locate(l => …)` (Z. 44, 100, 114) →
  „only element functions can be used as selectors“.
- `type(loc) == "location"`, `type(func) == "function"`, `type(def.pipe) == "array"`
  (Z. 6, 16, 150, 163): String-Typvergleiche, seit Typst 0.14 immer `false`.
- Z. 194: `key in var.pos()` prüft Wert-Mitgliedschaft, nicht Index → `arg()` für positionale Argumente falsch.
- Z. 126–127: `assert(name in provided, …)` im Zweig, in dem `name` nicht in `provided` ist (funktioniert, aber umständlich).
- Z. 101, 115, 132–135: auskommentierte Varianten. Z. 161: offenes TODO „Handle with pipe option“.
- `getconfig(final:)` ohne Wirkung.

---

## 2. typopst 0.0.1 — `typopst/0.0.1/{typopst,options,states}.typ`

Entrypoint `typopst.typ` (1 Zeile ohne Zeilenumbruch am Ende von Z. 1–2):

```typ
#import "options.typ"
#import "states.typ"
```

Öffentlich sind also genau zwei Module: `typopst.options` und `typopst.states`.
Nutzung in den Altpaketen: `#import "@schule/typopst:0.0.1": *` → `options.get(...)`, `states.new(...)`.

### 2.1 Modul `options` (`options.typ`, 297 Zeilen)

| Zeile | Name | Art | Signatur (wörtlich) |
|---|---|---|---|
| 7 | `__s_options` | State (intern) | `state("@options", (:))` |
| 9 | `__s_config` | State (intern) | `state("@config", (:))` |
| 16 | `__ns` | intern | `__ns(name, ns)` |
| 33 | `__get-local` | intern | `__get-local( name, loc, default )` |
| 39 | `__get-final` | intern | `__get-final( name, loc, default )` |
| 45 | `__get` | intern | `__get( name, func, default, final, loc )` |
| 57 | `get` | Funktion | `get( name, func, default:none, final:false, loc:none, ns:none )` |
| 68 | `update` | Funktion | `update( name, value, ns:none )` |
| 76 | `update-all` | Funktion | `update-all( values, ns:none )` |
| 81 | `remove` | Funktion | `remove( name, ns:none )` |
| 89 | `display` | Funktion | `display( name, format: value => value, default:none, final:false, ns:none )` |
| 92 | `load` | Funktion | `load( filename )` |
| 116 | `add-option` | Funktion | `add-option(name, type: ("string", "content"), required: false, default: none, choices: none, store: true, pipe: none, code: none)` |
| 142 | `add-argument` | Funktion | `add-argument(name, type: ("string", "content"), required: false, default: none, choices: none, store: true, pipe: none, code: none)` |
| 168 | `getconfig` | Funktion | `getconfig( name, final:false )` |
| 180 | `parseconfig` | Funktion | `parseconfig( _unknown:none, _opts:none, ..args )` |
| 273 | `ignore` | Variable | `none` |
| 274 | `store` | Funktion | `store(k, v)` |
| 275 | `fail` | Funktion | `fail(k, v)` |
| 285 | `extract` | Funktion | `extract( var, _prefix:"", _positional:false, ..keys )` |

Parameter (soweit von options 0.0.5 abweichend):

| Funktion | Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|---|
| `get`, `update`, `update-all`, `remove`, `display` | `ns` | named | `none` | str/`none` | Abk. en | Namensraum; Schlüssel wird `"ns:<ns>,<name>"`; alternativ `"ns.name"` im Namen (Z. 20–25) |
| `update-all` | `values` | pos | – | dictionary | en | mehrere Optionen setzen |
| `load` | `filename` | pos | – | str, Endung `yml`/`yaml`/`toml`/`json` | en | Optionen aus Datei laden; Dict-Werte werden Namensräume |
| `add-option`, `add-argument` | `choices` | named | `none` | Array/`none` | en | erlaubte Werte (in options 0.0.5: `valid`) |
| `add-option`, `add-argument` | `name`, `type`, `required`, `default`, `store`, `pipe`, `code` | wie `addconfig` | wie oben | wie oben | en | wie `addconfig` |
| `parseconfig` | `_unknown` | named | `none` | function/`none` | en, führender `_` | Handler unbekannter Optionen (options 0.0.5: `unknown`) |
| `parseconfig` | `_opts` | named | `none` | Array von Funktionen | Abk. en, führender `_` | Zusatzkonfigurationen, die vorab ausgeführt werden |
| `parseconfig` | `..args` | sink | – | pos + named | en | zu parsende Argumente |
| `extract` | `_prefix` | named | `""` | str | en, führender `_` | Schlüsselpräfix (options 0.0.5: `prefix`) |
| `extract` | `_positional` | named | `false` | bool | en, führender `_` | Rückgabe als Array statt Dict |

Gespeicherter Konfig-Eintrag (Z. 127–137 / 153–163): `_option`
(`"positional"` bzw. `"named"`), `type`, `name`, `required`, `default`,
`choices`, `store`, `pipe`, `code`, später `value`.

Fehlermeldungen (alle englisch): Z. 34/40 `"loc needs to be a valid location"`;
Z. 206 `"Positional argument '<name>' not provided but is required."`;
Z. 214 `"Ma,ed argument '<name>' not provided but is required."` (**Tippfehler** für „Named“);
Z. 227 `"Wrong type for option …"`; Z. 232 `"Value for option … not allowed …"`; Z. 276 `"Unexpected option '<k>'"`.

### 2.2 Modul `states` (`states.typ`, 245 Zeilen)

| Zeile | Name | Signatur (wörtlich) | Bedeutung |
|---|---|---|---|
| 7 | `ident` | `ident(e)` | Identität |
| 18 | `new` | `new( name, value )` | State anlegen |
| 25 | `new-arr` | `new-arr( name )` | State mit `()` |
| 34 | `new-dict` | `new-dict( name )` | State mit `(:)` |
| 43 | `del` | `del( name )` | State auf `none` |
| 55 | `update` | `update( name, value )` | State setzen |
| 68 | `enq` | `enq( name, value )` | an Array anhängen |
| 88 | `deq` | `deq( name, func:ident )` | letztes Element entfernen |
| 98 | `ins` | `ins( name, key, value, func:ident )` | einfügen (`func` ungenutzt) |
| 108 | `rem` | `rem( name, key )` | entfernen |
| 142 | `__get` | `__get( name, loc, func:ident, final:false, key:none, default:none )` | intern |
| 154 | `get` | `get( name, func, final:false, key:none, default:none )` | |
| 160 | `get-final` | `get-final( name, func, key:none, default:none )` | |
| 166 | `get-at` | `get-at( name, loc, func:ident, final:false, key:none, default:none )` | |
| 170 | `get-final-at` | `get-final-at( name, loc, func:ident, key:none, default:none )` | |
| 188 | `get-first` | `get-first( name, func:ident, final:false )` | |
| 202 | `get-last` | `get-last( name, func:ident, final:false )` | |

Alle Parameternamen englisch bzw. Abkürzungen (`func`, `loc`, `del`, `enq`,
`deq`, `ins`, `rem`, `arr`, `dict`). `func` ist in `get`/`get-final` positional,
in `get-at`/`get-final-at`/`get-first`/`get-last`/`deq` named.

### 2.3 Altlasten / Fehler typopst

- Bricht unter Typst 0.15.1 ab (`locate(func)`, `options.typ` Z. 59, 169, 189; `states.typ` Z. 155, 161, 189, 203).
- String-Typvergleiche (`"location"`, `"dict"`, `"array"`, `"function"`), `options.typ` Z. 34, 40, 105, 183, 238, 251.
- `options.typ` Z. 206: `assert(pos < provided-pos, …)` vergleicht int mit Array (Fehler; gemeint `provided-pos.len()`).
- `options.typ` Z. 235: `code`-Funktion wird nur für named ausgewertet, nie für positional.
- `options.typ` Z. 89: `display` wendet `__ns` an und ruft dann `get`, das `__ns` nochmals anwendet (doppelte Namensraum-Auflösung; funktioniert nur, solange der eigentliche Optionsname keinen Punkt enthält).
- `states.typ` Z. 43: `del` ruft `update`, das erst in Z. 55 definiert wird. Verifiziert: `states.del("x")` → `error: unknown variable: update` (states.typ:43:19).
- `states.typ` Z. 18: `new` setzt per `.update(value)`; Kommentar „initial value can't be none“.
- Auskommentierte Altvarianten in camelCase: `options.typ` Z. 220–223, 280–284 (`arg`); `states.typ` Z. 116–128 (`insertDict`, `removeDict`), 174–186 (`getArr`, `getArrAt`), 196–200 (`getFirstAt`), 210–246 (`getLastAt`, `getDict`, `getDictAt`, `getDictFinal`, `getDictFinalAt`).
- Benennung uneinheitlich im selben Modul: `add-option`/`add-argument` (kebab) neben `getconfig`/`parseconfig` (zusammengeschrieben); `_unknown`/`_opts`/`_prefix`/`_positional` mit Unterstrich, übrige Parameter ohne.
- `add-option` erzeugt `_option: "positional"`, `add-argument` erzeugt `_option: "named"` — inhaltlich eher vertauscht (Option = named, Argument = positional wäre die übliche Lesart).
- Tippfehler in Kommentaren: „optoin“ (Z. 14), „Utilitiy“ (Z. 32, 38, 44), „inital“ (states Z. 21, 30).

---

## 3. summify 0.1.0 — `summify/0.1.0/summify.typ` (570 Zeilen)

Zweck: Zusammenfassungen/Cheatsheets im Raster. Altversionen 0.0.1/0.0.2 mit
Entrypoint `cheatsheets.typ` (früherer Paketname-Gedanke „cheatsheets“), 0.0.3 `summify.typ`.

### 3.1 Öffentliche Namen

| Zeile | Name | Art | Signatur (wörtlich) |
|---|---|---|---|
| 10 | `_state-hide-content` | State (intern) | `state("summify-hide", false)` |
| 22 | `themes` | Variable (dictionary) | Schlüssel `"modern-blue"`, `"warm-sunset"`, `"dark-pro"`, `"default"` |
| 133 | `_state-theme` | State (intern) | `state("summify-theme", themes.default)` |
| 136 | `_merge-dict` | intern | `_merge-dict(base, override)` |
| 161 | `set-theme` | Funktion | `set-theme(theme)` |
| 188 | `update-theme` | Funktion | `update-theme(..params)` |
| 218 | `summify` | Funktion (Template) | `summify(title: "", paper: "a3", flipped: true, hide-content: false, theme: "default", theme-overrides: (:), body)` |
| 292 | `compose` | Funktion | `compose(direction: "horizontal", lines: false, gap: auto, ratios: none, ..children)` |
| 344 | `beside` | Funktion | `beside(gap: auto, ratios: none, ..children)` |
| 358 | `below` | Funktion | `below(gap: auto, ratios: none, ..children)` |
| 372 | `cols` | Funktion | `cols(gap: auto, ratios: none, ..children)` |
| 387 | `rows` | Funktion | `rows(gap: auto, ratios: none, ..children)` |
| 413 | `topic` | Funktion | `topic(title: none, height: 100%, width: 100%, fill: auto, stroke: auto, radius: auto, body)` |
| 487 | `section` | Funktion | `section(title, fill: auto, height: auto)` |
| 522 | `content` | Funktion | `content(title: none, inset: auto, align-content: left, hide: auto, body)` |

### 3.2 Parameter

**`set-theme` (Z. 161)**: `theme` (pos, str aus `themes.keys()` oder dictionary, en).

**`update-theme` (Z. 188)**: `..params` (sink, named; Theme-Schlüssel, en).

**`summify` (Z. 218)**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `title` | named | `""` | str/content | en | Seitentitel (Kopfzeile, fest 20pt) |
| `paper` | named | `"a3"` | Typst-Papierformat | en | Papier |
| `flipped` | named | `true` | bool | en | Querformat |
| `hide-content` | named | `false` | bool | en | Lernmodus: Inhalte ausblenden |
| `theme` | named | `"default"` | `"modern-blue"`, `"warm-sunset"`, `"dark-pro"`, `"default"`, dictionary, `none` | en | Thema |
| `theme-overrides` | named | `(:)` | dictionary | en | Teil-Überschreibungen |
| `body` | pos | – | content | en | Inhalt |

**`compose` (Z. 292)**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `direction` | named | `"horizontal"` | `"horizontal"`, `"vertical"` (alles andere = vertikal) | en | Richtung |
| `lines` | named | `false` | bool | en | Trennlinien |
| `gap` | named | `auto` | auto/length | en | Abstand; `auto` = `theme.spacing.topic` |
| `ratios` | named | `none` | Array von Spurgrößen/`none` | en | Spalten-/Zeilenmaße |
| `..children` | sink | – | content (pos) | en | Inhalte |

**`beside` / `below` / `cols` / `rows`**: jeweils `gap` (named, `auto`),
`ratios` (named, `none`), `..children` (sink). Unterschied: `beside`/`below`
ohne Linien, `gap: auto` = `spacing.topic`; `cols`/`rows` mit Linien,
`gap: auto` = `spacing.section`.

**`topic` (Z. 413)**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `title` | named | `none` | content/`none` | en | Titel der Box |
| `height` | named | `100%` | relative length | en | Höhe |
| `width` | named | `100%` | relative length | en | Breite |
| `fill` | named | `auto` | auto/color | en | Füllung Titelleiste; `auto` = `colors.primary` |
| `stroke` | named | `auto` | auto/stroke | en | Rahmen; `auto` = `colors.border + sizes.border` |
| `radius` | named | `auto` | auto/length | en | Eckenradius |
| `body` | pos | – | content | en | Inhalt |

**`section` (Z. 487)**: `title` (**pos**, content), `fill` (named, `auto`), `height` (named, `auto`).

**`content` (Z. 522)**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `title` | named | `none` | content/`none` | en | Titel (erzeugt `section`) |
| `inset` | named | `auto` | auto/length | en | Innenabstand; `auto` = `spacing.content` |
| `align-content` | named | `left` | alignment | en | Ausrichtung |
| `hide` | named | `auto` | auto/bool | en | ausblenden; `auto` = globaler `hide-content` |
| `body` | pos | – | content | en | Inhalt |

### 3.3 Themen-Schlüssel (Z. 22–131)

```
colors:     primary, on-primary, surface, border
spacing:    page (x, y, top), topic, section, content
sizes:      title (height, text), header (height, text), border, radius
typography: font, math-font, base-size, weights (title, header)
```

States: `"summify-hide"`, `"summify-theme"` (sauber mit Paketpräfix).

### 3.4 Validierung / Fehlermeldungen (englisch, obwohl Doku deutsch)

- Z. 167: `panic("Unknown theme: <x>. Available themes: …")`
- Z. 173: `panic("Theme must be a string (theme name) or dictionary (custom theme)")`
- Keine Prüfung unbekannter Schlüssel in `theme-overrides`/`update-theme` (werden stillschweigend hinzugefügt); `direction` wird nicht geprüft.

### 3.5 Inkonsistenzen / Fehler

- **Bug Z. 522/538:** Parameter `hide` überschattet die Builtin-Funktion `hide`; `hide(box(...))` in Z. 538 schlägt fehl. Verifiziert: `#summify(hide-content: true)[…#content[…]]` → `error: expected function, found auto` (summify.typ:538:6). Der dokumentierte Lernmodus funktioniert also nicht.
- `hide-content` (in `summify`) vs. `hide` (in `content`) für denselben Schalter.
- `title`: named in `summify`, `topic`, `content` — positional in `section` (Z. 487).
- `align-content` (Z. 525) vs. sonst blanke Typst-Namen (`fill`, `stroke`, `inset`); Typst-üblich wäre `align`.
- `set-theme`/`update-theme` (Verb-Präfix) vs. Variable `themes`; `theme` und `theme-overrides` als Parameter.
- `cols`/`rows` vs. `beside`/`below`: zwei Namenspaare für dasselbe, Unterschied (Linien + anderer Gap-Default) steckt nicht im Namen.
- `content` überschattet beim `import: *` den Typst-Typ `content`; `rows`/`cols`/`section`/`topic` sind sehr generische Namen.
- Z. 304–308: lokale Variablen `cols`, `rows` in `compose` überschatten die später definierten Funktionen (harmlos).
- Doku-Kommentare deutsch, Bezeichner/Fehlermeldungen/Zeilenkommentare englisch.
- Seitentitelgröße fest `20pt` (Z. 261), nicht aus `sizes.title.text`.
- `theme` = `none` erlaubt (Z. 228), aber nicht dokumentiert.

---

## 4. gutachten 0.0.2 — `gutachten/0.0.2/{gutachten,bewertung}.typ`

### 4.1 `gutachten.typ` (Entrypoint, 290 Zeilen)

Importiert `@preview/unify:0.7.0` mit `*` (wird im Entrypoint nicht verwendet,
aber dadurch an Nutzer mit `import: *` weitergereicht: `num`, `qty`, `unit`, …).

| Zeile | Name | Art | Signatur (wörtlich) |
|---|---|---|---|
| 22 | `set-gutachten-infos` | Funktion | `set-gutachten-infos(fach: "", niveau: "", kürzel: "", anonym: false, print: false, be: 1, font: "New Computer Modern Sans", math-font: "Fira Math", jahr: auto)` |
| 44 | `_anonym-name-placeholder` | intern | `_anonym-name-placeholder()` |
| 46 | `_format-punkte-wert` | intern | `_format-punkte-wert(punkte)` |
| 54 | `name` | Variable (context-Content) | Vorname des aktuellen Schülers bzw. Platzhalter „Schüler“ |
| 74 | `set-aufgaben` | Funktion | `set-aufgaben(aufgaben)` |
| 86 | `bewertungsskala` | Funktion | `bewertungsskala(prozent)` |
| 129 | `aufgabe` | Funktion | `aufgabe(name, punkte, body)` |
| 166 | `gutachten` | Funktion (Template) | `gutachten(vorname: "Max", nachname: "Mustermann", wahl: (), body)` |

**`set-gutachten-infos` (Z. 22)**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `fach` | named | `""` | str | de | Fach |
| `niveau` | named | `""` | str (z. B. `"E"`, `"G"`) | de | Kursniveau |
| `kürzel` | named | `""` | str | de, **Umlaut** | Lehrkraft-Kürzel |
| `anonym` | named | `false` | bool | de | Namen anonymisieren |
| `print` | named | `false` | bool | **en** | Druckfassung (Unterschriftslinie statt grauem Text) |
| `be` | named | `1` | int | de, Abk. | maximale Bewertungseinheiten gesamt |
| `font` | named | `"New Computer Modern Sans"` | str | **en** | Schrift |
| `math-font` | named | `"Fira Math"` | str | **en** | Formelschrift |
| `jahr` | named | `auto` | auto/int | de | Abiturjahr |

**`set-aufgaben` (Z. 74)**: `aufgaben` (pos, dictionary, de). Eintragsschlüssel:
`be` (Pflicht), `dativ` (optional, Z. 144, Dativform des Namens), `name`
(optional, Z. 231/247, Anzeigename bei `wahl`). `dativ` und `name` sind im
Doc-Kommentar nicht dokumentiert.

**`bewertungsskala` (Z. 86)**: `prozent` (pos, float 0–1, de). Rückgabe:
String wie `"gut (11 Punkte)"`. Schwellen 0.95 … 0.0 fest verdrahtet
(Z. 89–106); interne Schlüssel `prozent`, `punkte` (wobei `punkte` hier den
Notentext enthält).

**`aufgabe` (Z. 129)**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `name` | pos | – | str (Schlüssel aus `set-aufgaben`) | en/de | Aufgabenname; überschattet die öffentliche Variable `name` |
| `punkte` | pos | – | int/float | de | erreichte Punkte |
| `body` | pos | – | content | **en** | Kommentar |

**`gutachten` (Z. 166)**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `vorname` | named | `"Max"` | str | de | Vorname |
| `nachname` | named | `"Mustermann"` | str | de | Nachname |
| `wahl` | named | `()` | array von Aufgabenschlüsseln **oder** dictionary (Bereich → Array) | de | gewählte Aufgaben |
| `body` | pos | – | content | **en** | Inhalt |

States (alle ohne Paketpräfix, per String angesprochen):
`"gutachten-infos"`, `"schüler"` (Umlaut; Felder `vorname`, `nachname`),
`"aufgaben"`, `"punkte"`.
Label-Konvention: `<vorname>-<nachname>-pages` (Z. 205, 287; „pages“ englisch).

Validierung: keine. Unbekannte Aufgabennamen führen zu einem rohen
Typst-Fehler („dictionary does not contain key“, Z. 142). Feste deutsche
Texte: „Gutachten über die schriftliche Prüfung von“, „Abitur <jahr>“,
„Mit Korrektur und Bewertung einverstanden“, „Ort, Datum, Unterschrift“.

### 4.2 `bewertung.typ` (338 Zeilen; NICHT vom Entrypoint importiert)

Importe: `@preview/tablex:0.0.5` (`*`), `@schule/klausurboegen:0.0.2` (`*`,
**veraltet**, aktuell 0.0.5; exportiert `klausurbögen`, wird hier nicht benutzt).

| Zeile | Name | Art | Signatur (wörtlich) |
|---|---|---|---|
| 7 | `__foreach` | intern | `__foreach(s, func, filter: elem => true, final: true, loc: none)` |
| 41 | `__s_erwartungen` | State (intern) | `state("erwartungen", ())` |
| 42 | `__s_aufgaben` | State (intern) | `state("aufgaben", ())` |
| 43 | `__foreach_erw` | intern | `__foreach.with(__s_erwartungen, final:true)` |
| 48 | `__d__erwartung` | intern | `__d__erwartung(text, punkte, last)` |
| 52 | `d_ew_erwartungen` | Funktion | `d_ew_erwartungen(aufg, teil: 0, format: __d__erwartung)` |
| 64 | `d_ew_text` | Funktion | `d_ew_erwartungen.with(format: (t, p, last) => …)` |
| 69 | `d_ew_punkte` | Funktion | `d_ew_punkte(aufg, teil: 0, format: p=>if p > 0 [#p] else [])` |
| 82 | `d_ew_gesamt` | Funktion | `d_ew_gesamt( format: p=>[#p] )` |
| 87 | `ew_verteilung_oberstufe` | Variable | Array 16 Schwellen (0 … 0.95) |
| 96 | `ew_namen_oberstufe` | Variable | `(0, 1, …, 15)` |
| 105 | `ew_verteilung_unterstufe` | Variable | identisch zu Oberstufe |
| 113 | `ew_namen_unterstufe` | Variable | `("6", "5-", …, "1+")` |
| 122 | `ew_verteilung_ohne_tendenz` | Variable | `(.0, .20, .40, .55, .70, .85)` |
| 130 | `ew_namen_ohne_tendenz` | Variable | `("6", …, "1")` |
| 140 | `d_ew_notenspiegel` | Funktion | `d_ew_notenspiegel(verteilung: ew_verteilung_oberstufe, namen: ew_namen_oberstufe)` |
| 180 | `d_ew_unterstufe` | Funktion | `d_ew_unterstufe()` |
| 226 | `d_ew_oberstufe` | Funktion | `d_ew_oberstufe()` |
| 275 | `d_ew_bewertung` | Funktion | `d_ew_bewertung()` |

Parameter: `aufg` (pos, Aufgabennummer, de-Abk.), `teil` (named, `0`,
int/`none`; `none` = alle Teile, `0` = Aufgabenebene), `format` (named,
function, en), `verteilung`/`namen` (named, Arrays, de).
Präfix-Konvention: `d_` = „display“, `ew_` = „Erwartung(shorizont)“ —
snake_case mit Abkürzungen, gemischt de/en.
Erwartete State-Einträge: Erwartung `(aufgabe, teil, text, punkte)`,
Aufgabe `(nummer, teile, title)` — `title` englisch neben `nummer`/`teile`.
Labels: `<erwartungshorizont>` (Z. 182, 227), `<bewertung>` (Z. 277).
Fehlermeldung Z. 147 (deutsch): „Die Verteilung und Namen müssen gleichviele Elemente enthalten.“

### 4.3 Inkonsistenzen / Altlasten gutachten

- `gutachten.typ:22–31`: de/en gemischt in einer Signatur (`fach`, `niveau`, `kürzel`, `anonym`, `be`, `jahr` vs. `print`, `font`, `math-font`).
- `gutachten.typ:25`: Umlaut `kürzel`; arbeitsblatt 0.4.0 schreibt `kuerzel` (themes.typ:67), typlace durchgehend ae/oe/ue (`tisch-hoehe`, `schueler`, `qualitaet`). State `"schüler"` (Z. 55) ebenfalls mit Umlaut.
- `set-gutachten-infos`/`set-aufgaben`: englisches Verb-Präfix + deutscher Rest („denglisch“); „infos“ ist Plural-Anglizismus.
- `gutachten.typ:54` vs. `:129`: öffentliche Variable `name` und Parameter `name` in `aufgabe` – verschiedene Bedeutung (Schülervorname vs. Aufgabenname). `name` als Export ist bei `import: *` kollisionsträchtig.
- `be` bedeutet in `set-gutachten-infos` Gesamt-BE, in `set-aufgaben` BE je Aufgabe; die Gesamtsumme wird nicht aus den Aufgaben berechnet (Default `be: 1` liefert unsinnige Prozentwerte, wenn vergessen).
- `aufgabe(name, punkte, body)` rein positional; `gutachten(vorname:, nachname:, …)` named.
- `wahl`: Array oder Dictionary (Z. 226/238), Doku nennt nur Array.
- `gutachten.typ:209`: `margin: (top: 3cm, y: 3cm)` – `top` und `y` gleichzeitig (redundant).
- `gutachten.typ:284`: auskommentiertes `//#label()`.
- **State-Kollision:** `state("aufgaben")` wird in `gutachten.typ:74` als Dictionary, in `bewertung.typ:42` als Array geführt; derselbe State-Name `"aufgaben"` wird auch von aufgaben 0.3.1 benutzt. `state("punkte")`, `state("schüler")` ebenfalls ohne Präfix.
- `bewertung.typ` ist eine verwaiste Kopie aus klassenarbeit (2 Zeilen Unterschied zu klassenarbeit 0.0.6–0.0.8 `bewertung.typ`); zwischen gutachten 0.0.1 und 0.0.2 unverändert. Niemand befüllt in gutachten die States `erwartungen`/`aufgaben` im erwarteten Format.
- `bewertung.typ` kompiliert unter 0.15.1 nicht (`locate(func)` Z. 34, 70, 82, 144, 185, 230, 280; `type(s) == "state"` Z. 14; tablex 0.0.5).
- `gutachten/0.0.2/docs/content.typ:147` dokumentiert `#import "@schule/gutachten:0.0.2/bewertung.typ": *` – diese Import-Syntax ist ungültig („`2/bewertung` is not a valid patch version“).
- `ew_verteilung_unterstufe` (Z. 105) ist identisch mit `ew_verteilung_oberstufe` (Z. 87) – Doppelung.
- `@preview/unify:0.7.0` wird importiert, aber nicht verwendet.
- Notenskala (15-Punkte) doppelt: `bewertungsskala` in `gutachten.typ:89` und `ew_verteilung_oberstufe` in `bewertung.typ:87`.

---

## 5. flashcards 0.0.1 — `flashcards/0.0.1/flashcards.typ` (341 Zeilen)

| Zeile | Name | Art | Signatur (wörtlich) |
|---|---|---|---|
| 1 | `cardnumber` | Counter | `counter("cardnumber")` |
| 2 | `cardheader` | State | `state("header", "init")` |
| 3 | `cardfooter` | State | `state("footer", "init")` |
| 4 | `cardquestion` | State | `state("question", "init")` |
| 5 | `cardanswer` | State | `state("answer", "init")` |
| 21 | `card` | Funktion | `card(header, footer, question, answer)` |
| 30 | `letter8up` | Variable (Content, kein Funktionsaufruf) | US-Letter, 2×4 Karten |
| 186 | `a48up` | Variable (Content) | A4, 2×4 Karten |

**`card` (Z. 21)**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `header` | pos | – | content | en | Kopfzeile |
| `footer` | pos | – | content | en | Fußzeile |
| `question` | pos | – | content | en | Frage (Vorderseite) |
| `answer` | pos | – | content | en | Antwort (Rückseite) |

Konventionen: Label `<card>` (Z. 27), Query `query(<card>, loc)`;
State-Namen `"header"`, `"footer"`, `"question"`, `"answer"` ohne Präfix
(Variablennamen dagegen mit `card`-Präfix). Keine Validierung, keine Fehlermeldungen.

Altlasten / Fehler:
- Kompiliert unter 0.15.1 nicht: `locate(loc => …)` (Z. 39, 195), `query(<card>, loc)`.
- `letter8up` (Z. 30–183) und `a48up` (Z. 186–339) sind bis auf Kartenmaße, Fragegröße (`large` vs. `12pt`) und Frage-Platzierung (`top + center, dy: 1.5cm` vs. `horizon + center`) Zeile für Zeile dupliziert; innerhalb jeder Variante ist der odd/even-Zweig nochmals identisch dupliziert.
- Ungenutzte Variablen `small`, `tiny`, `huge`, `count` (Z. 34–37, 133 bzw. 190–193, 289).
- `letter8up`/`a48up` sind Werte, keine Funktionen – nicht konfigurierbar (kein Papier-/Spaltenparameter); `a48up` fehlt in der Doku (docs importieren nur `card, letter8up`).
- Doc-Kommentar deutsch, API englisch, alles zusammengeschrieben ohne Bindestrich (`cardnumber`), Name `a48up` schwer lesbar (A4, 8-up).
- Fremdpaket (offensichtlich übernommene Vorlage), kein @schule-Bezug.

---

## 6. typlace 0.0.2 — `typlace/0.0.2/typlace.typ` (211 Zeilen; nur Entrypoint-API)

### 6.1 Öffentliche Namen des Entrypoints

Eigene Definition:

| Zeile | Name | Signatur (wörtlich) |
|---|---|---|
| 44 | `typlace` | `typlace(layout, namen: (), tisch-breite: 2cm, tisch-hoehe: 1.2cm, tisch-farbe: rgb("#cce0f5"), pult-farbe: rgb("#6b4c2a"), koerper-farbe: auto, nummern: false, rotation: 0)` |

Re-Exporte (Z. 1–10, benannte Importe, dadurch öffentlich):

| Quelle | Name | Signatur (wörtlich) |
|---|---|---|
| geometrie.typ:23 | `ist-frei` | `ist-frei(ch)` |
| geometrie.typ:25 | `ist-koerper` | `ist-koerper(ch)` |
| geometrie.typ:26 | `ist-platz` | `ist-platz(ch)` |
| geometrie.typ:24 | `ist-pult` | `ist-pult(ch)` |
| geometrie.typ:268 | `koerper-zellen` | `koerper-zellen(geo)` |
| geometrie.typ:33 | `layout-matrix` | `layout-matrix(layout)` |
| geometrie.typ:122 | `plaetze-analysieren` | `plaetze-analysieren(layout, vorne: auto, perspektive: "schueler")` |
| geometrie.typ:21 | `tisch-ids` | Variable (Array der Tischkennzeichen) |
| daten.typ:86 | `schueler-lesen` | `schueler-lesen(quelle, trenner: auto, kopfzeile: auto)` |
| daten.typ:256 | `schueler-pruefen` | `schueler-pruefen(daten, plaetze: none, max-wuensche: 3, streng: true)` |
| daten.typ:353 | `wunschliste` | `wunschliste(quelle, trenner: auto, kopfzeile: auto, plaetze: none, max-wuensche: 3, streng: true)` |
| optimierer.typ:266 | `sitzordnung` | `sitzordnung(layout, schueler, vorgaben: (:), gewichte: (:), position-anteil: auto, seed: 42, qualitaet: "normal", versuche: auto, max-schritte: auto, vorne: auto, perspektive: "schueler", streng: true, dauer: none, motor: "wasm")` |
| wasm.typ:77 | `wasm-suchen` | `wasm-suchen(kontext, geo, spielraum, versuche: 8, max-schritte: 500, seed: 42)` |
| bericht.typ:72 | `sitzplan-bericht` | `sitzplan-bericht(plan, details: true)` |
| bericht.typ:7 | `sitzplan-kennzahlen` | `sitzplan-kennzahlen(plan)` |
| bewertung.typ:350 | `bewerte` | `bewerte(kontext, zuordnung)` |
| bewertung.typ:67 | `kontext-erstellen` | `kontext-erstellen(geo, schueler, gewichte: (:), vorgaben: (:), position-anteil: auto)` |
| bewertung.typ:54 | `normalisiere-vorgaben` | `normalisiere-vorgaben(vorgaben)` |
| bewertung.typ:338 | `platz-von-schueler` | `platz-von-schueler(kontext, zuordnung)` |
| bewertung.typ:184 | `punkte-schueler` | `punkte-schueler(kontext, platz-von, i)` |
| bewertung.typ:281 | `punkte-wert` | `punkte-wert(kontext, platz-von, i)` |
| bewertung.typ:39 | `standard-gewichte` | Variable (dictionary) |
| bewertung.typ:367 | `tausch-delta` | `tausch-delta(kontext, zuordnung, platz-von, p, q)` |
| bewertung.typ:402 | `statistik` | `statistik(kontext, ergebnis)` |

### 6.2 Parameter `typlace` (Z. 44)

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `layout` | pos | – | str (mehrzeilig) | en/de | Raumlayout |
| `namen` | named | `()` | array von str | de | Namen in Lesereihenfolge |
| `tisch-breite` | named | `2cm` | length | de | Zellbreite |
| `tisch-hoehe` | named | `1.2cm` | length | de, **oe** | Zellhöhe |
| `tisch-farbe` | named | `rgb("#cce0f5")` | color | de | Platzfarbe |
| `pult-farbe` | named | `rgb("#6b4c2a")` | color | de | Pultfarbe |
| `koerper-farbe` | named | `auto` | auto/color/`none` | de, **oe** | Tischflächenfarbe; `none` = aus |
| `nummern` | named | `false` | bool | de | Platznummern anzeigen |
| `rotation` | named | `0` | `0`, `90`, `180`, `270` (int, Grad; anderes = 0, ungeprüft) | en/de | Drehung im Uhrzeigersinn |

### 6.3 Parameter `sitzordnung` (optimierer.typ:266)

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `layout` | pos | – | str | en/de | Raumlayout |
| `schueler` | pos | – | str / array / dictionary | de, **ue** | Wunschliste |
| `vorgaben` | named | `(:)` | dictionary; Schlüssel `fest`, `muss-vorne`, `muss-mitte`, `muss-hinten`, `muss-links`, `muss-rechts`, `getrennt`, `zusammen` | de | harte Vorgaben |
| `gewichte` | named | `(:)` | dictionary; Schlüssel wie `standard-gewichte` | de | Gewichtungen |
| `position-anteil` | named | `auto` | auto/ratio/float (0 ≤ x < 100 %) | gemischt | Anteil der Positionswünsche |
| `seed` | named | `42` | int | **en** | Zufallsstartwert |
| `qualitaet` | named | `"normal"` | `"schnell"`, `"normal"`, `"gruendlich"` | de, **ae/ue** | Suchaufwand |
| `versuche` | named | `auto` | auto/int | de | Startpläne |
| `max-schritte` | named | `auto` | auto/int | gemischt (`max-`) | Schritte je Versuch |
| `vorne` | named | `auto` | auto, `"oben"`, `"unten"`, `"links"`, `"rechts"` | de | Vorderseite des Raums |
| `perspektive` | named | `"schueler"` | `"schueler"`, `"plan"` | de | links/rechts-Bezug |
| `streng` | named | `true` | bool | de | bei unbekannten Namen abbrechen |
| `dauer` | named | `none` | none/str | de | Rechenzeit-Text für Bericht |
| `motor` | named | `"wasm"` | `"wasm"`, `"typst"` | de | Rechenkern |

Weitere benannte Parameter der Re-Exporte: `trenner` (auto/str), `kopfzeile`
(auto/bool), `plaetze` (none/int), `max-wuensche` (int, `3`), `details` (bool, `true`).

`standard-gewichte` (bewertung.typ:39): `direkt`, `tisch`, `raenge`, `stufen`,
`wunschzahl`, `fairness`, `ablehnung`, `hart`, `position`, `position-meidet`.

Layout-Zeichen (geometrie.typ:14–17): frei `X x . _ ␣`; Pult `P p`;
Tischkörper `o O #`; Auto-Platz `T`; übrige alphanumerische Zeichen = Tisch-ID.
Positions-Shortcodes der Wunschliste (daten.typ:26–45): `v/vorne/vorn`,
`m/mitte/mittig`, `h/hinten/hinter`, `l/links`, `r/rechts`,
`mitte-quer/quermitte/seitenmitte`; Präfix `!` = meiden / Ablehnung.

### 6.4 Validierung

Durchgehend deutsche `panic`-Meldungen mit Präfix `typlace: …`
(geometrie.typ:124, 146; daten.typ:100, 107, 114, 270, 278, 343;
bewertung.typ:57, 88, 126; optimierer.typ:70, 79, 82, 106, 137, 283, 286,
331, 357; wasm.typ:80). Enum-Werte `motor`/`qualitaet` werden geprüft;
unbekannte Schlüssel in `vorgaben`/`gewichte` und ungültige `rotation`
werden im Entrypoint nicht geprüft.

### 6.5 Inkonsistenzen typlace

- Bestes Vorbild im Repo: deutsch, kebab-case, ae/oe/ue, Präfix in Fehlermeldungen. Ausnahmen: `seed`, `layout`, `rotation`, `max-…`, `details`, `wasm-suchen`; Paket- und Funktionsname `typlace` englisch-künstlich.
- Verb-Stellung uneinheitlich: `schueler-lesen`, `plaetze-analysieren`, `kontext-erstellen` (Objekt-Verb) vs. `normalisiere-vorgaben`, `bewerte` (Imperativ vorn).
- Der Entrypoint exportiert viele Interna (`tausch-delta`, `punkte-wert`, `wasm-suchen`, `kodieren` nicht, aber `ist-*`), die eher Implementierungsdetails sind.
- `typlace.typ:107`: ungültige `rotation` (z. B. 45) wird stillschweigend zu 0.
- `typlace.typ:173`: Beschriftung „Pult“ fest verdrahtet.
- Interne Variablen in `typlace` gemischt de/en (`zeile`, `fuellung`, `koerper` vs. `char-matrix`, `full-matrix`, `rotated`, `p-info`, `cells`).

---

## 7. eduki 0.1.0 — `eduki/0.1.0/src/eduki.typ` (551 Zeilen)

Import: `@preview/shadowed:0.2.0: shadowed`. Datei `src/mathemensch.png` liegt bei, wird im Code nicht referenziert.

### 7.1 Öffentliche Namen (alle Top-Level, kein Unterstrich → alles öffentlich)

| Zeile | Name | Signatur (wörtlich) |
|---|---|---|
| 8 | `fill-height-with-text` | `fill-height-with-text(min: 0.3em, max: 5em, eps: 0.1em, it)` |
| 45 | `parse-page-spec` | `parse-page-spec(spec)` |
| 63 | `resolve-path` | `resolve-path(path, base-path: none)` |
| 73 | `resolve-page-spec` | `resolve-page-spec(spec, base-path: none)` |
| 85 | `get-page-info` | `get-page-info(spec)` |
| 107 | `page-shadow-image` | `page-shadow-image(spec, scale: 0.66, radius: 5pt)` |
| 150 | `layout-1P` | `layout-1P(pages)` |
| 155 | `layout-1L` | `layout-1L(pages)` |
| 160 | `layout-1L-stacked` | `layout-1L-stacked(pages)` |
| 165 | `layout-2P` | `layout-2P(pages)` |
| 172 | `layout-2L` | `layout-2L(pages)` |
| 179 | `layout-2L-stacked` | `layout-2L-stacked(pages)` |
| 186 | `layout-1P-1L` | `layout-1P-1L(pages, p-indices, l-indices)` |
| 195 | `layout-3P` | `layout-3P(pages)` |
| 204 | `layout-3L` | `layout-3L(pages)` |
| 213 | `layout-3L-stacked` | `layout-3L-stacked(pages)` |
| 222 | `layout-2P-1L` | `layout-2P-1L(pages, p-indices, l-indices)` |
| 234 | `layout-1P-2L` | `layout-1P-2L(pages, p-indices, l-indices)` |
| 246 | `layout-4P` | `layout-4P(pages)` |
| 257 | `layout-4L` | `layout-4L(pages)` |
| 268 | `layout-4L-stacked` | `layout-4L-stacked(pages)` |
| 279 | `layout-3P-1L` | `layout-3P-1L(pages, p-indices, l-indices)` |
| 291 | `layout-2P-2L` | `layout-2P-2L(pages, p-indices, l-indices)` |
| 302 | `layout-1P-3L` | `layout-1P-3L(pages, p-indices, l-indices)` |
| 314 | `layout-5P` | `layout-5P(pages)` |
| 327 | `layout-5L` | `layout-5L(pages)` |
| 340 | `layout-5L-stacked` | `layout-5L-stacked(pages)` |
| 353 | `layout-4P-1L` | `layout-4P-1L(pages, p-indices, l-indices)` |
| 366 | `layout-3P-2L` | `layout-3P-2L(pages, p-indices, l-indices)` |
| 379 | `layout-2P-3L` | `layout-2P-3L(pages, p-indices, l-indices)` |
| 392 | `layout-1P-4L` | `layout-1P-4L(pages, p-indices, l-indices)` |
| 411 | `pageboxes` | `pageboxes(pages, l-style: "spread", base-path: none)` |
| 475 | `strichbox` | `strichbox(title, subtitle)` |
| 504 | `material-box` | `material-box(title, subtitle, color, images, icon: none, l-style: "spread", base-path: none)` |

### 7.2 Parameter

**`material-box` (Z. 504)**

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `title` | pos | – | content/str | en | Titel |
| `subtitle` | pos | – | content/str | en | Untertitel |
| `color` | pos | – | color | en | Grundfarbe; überschattet Builtin `color` |
| `images` | pos | – | Array von Seitenspezifikationen (max. 5 werden gezeigt) | en | Vorschauseiten (heißt in `pageboxes` `pages`) |
| `icon` | named | `none` | Pfad/bytes/`none` | en | Icon unten rechts |
| `l-style` | named | `"spread"` | `"spread"`, `"stacked"` | en, Abk. (`l` = landscape) | Stil für Querformatseiten |
| `base-path` | named | `none` | str/`none` | en | Basispfad für relative Pfade |

**`pageboxes` (Z. 411)**: `pages` (pos, array), `l-style` (named, `"spread"`), `base-path` (named, `none`).

**`strichbox` (Z. 475)**: `title`, `subtitle` (beide pos). Feste Fonts „Londrina Solid“ und „Kalam“.

**`page-shadow-image` (Z. 107)**: `spec` (pos), `scale` (named, `0.66`, float/ratio — Aufrufer übergeben `75%`), `radius` (named, `5pt`).

**`fill-height-with-text` (Z. 8)**: `min` (named, `0.3em`), `max` (named, `5em`), `eps` (named, `0.1em`), `it` (pos, content).

**`parse-page-spec` / `resolve-page-spec` / `get-page-info`**: `spec` (pos) =
str (Pfad) | bytes | Array `(quelle, seite)` | dictionary; `base-path` (named, `none`).
Ergebnis-Schlüssel: `path` oder `data`, `page`; `get-page-info` liefert
`spec`, `natural-size`, `aspect`, `is-landscape`, `is-wide`, `is-portrait`.

**`layout-…`**: `pages` (pos), bei gemischten Layouts zusätzlich `p-indices`, `l-indices` (pos).
Namensschema `layout-<n>P[-<m>L][-stacked]` (P = portrait, L = landscape; Großbuchstaben im sonst kebab-case-Namen).

### 7.3 Validierung

Nur Z. 22: `panic("Content doesn't fit even at minimum text size")` (englisch).
`l-style` wird nicht geprüft (alles außer `"stacked"` = spread); mehr als 5
Bilder werden stillschweigend abgeschnitten (Z. 414).

### 7.4 Inkonsistenzen / Altlasten eduki

- `strichbox` (Z. 475) ist der einzige deutsche Bezeichner in einer sonst englischen API.
- `images` (`material-box`, Z. 508) vs. `pages` (`pageboxes`, Z. 411) für dieselbe Liste.
- `pageboxes` (zusammengeschrieben) vs. `material-box`, `page-shadow-image` (kebab).
- 25 `layout-*`-Funktionen und alle Helfer sind öffentlich, obwohl nur `material-box` (README) gedacht ist; kein `_`-Präfix.
- Kommentare deutsch in ASCII-Umschrift („Groesse“, „fuer“), auch `typst.toml`-Beschreibung.
- Z. 23–26: Im Zweig `if fits(max, it) { set text(max); it }` fehlt ein `return`; danach läuft die Bisektion weiter und gibt den Inhalt nochmals zurück (verifiziert: `fill-height-with-text(max: 1em)[Hallo]` gibt „HalloHallo“ aus, sobald der Inhalt schon in Maximalgröße passt).
- Z. 512: `material-box` ist in `context` gewickelt, benötigt den Kontext selbst aber nicht (nur `get-page-info`/`measure` weiter unten).
- `l-count == N and effective-l-style == "stacked"`-Kaskade (Z. 438–468) als lange if-Kette; `effective-l-style` schaltet bei reinem Querformat ohne breite Seiten automatisch auf `"stacked"` (Z. 432) – überschreibt den Nutzerwunsch `"spread"` stillschweigend.
- `src/mathemensch.png` ungenutzt. Fonts „Londrina Solid“/„Kalam“ nicht installiert → Warnungen.

---

## 8. angela 0.0.1 — `angela/0.0.1/angela.typ` (48 Zeilen)

| Zeile | Name | Art | Signatur (wörtlich) |
|---|---|---|---|
| 1 | `angela-dark` | Variable (color) | `rgb(40, 80, 155)` |
| 2 | `angela-light` | Variable (color) | `rgb(150, 180, 221)` |
| 16 | `brief` | Funktion (Template) | `brief(body)` |

`brief`: einziger Parameter `body` (pos, content, en). Keine Optionen, keine
Validierung. Fest verdrahtet: A4, Ränder (oben 5cm, unten 2cm, links/rechts
2.5cm), Fonts „Lucida Grande“, „Arial“, „Calibri“ 11pt, `lang: "de"`, Logo `logo.svg`.

Inkonsistenzen: Funktionsname deutsch (`brief`), Farbvariablen englisch
(`angela-dark`, `angela-light`), Parameter `body` englisch. `angela-light`
wird nirgends verwendet. „Calibri“ auf diesem Rechner nicht vorhanden
(Warnung). Keine Parameter für Empfänger/Datum/Betreff.

---

## 9. abbozza 0.0.1 — `abbozza/0.0.1/hathi-render.typ` (137 Zeilen)

Import: `@preview/cetz:0.3.4` mit `*` (**veraltet**; die übrigen Pakete und
der CeTZ-Skill arbeiten mit 0.5.x). Durch `import: *` beim Nutzer werden
sämtliche CeTZ-Namen (`canvas`, `draw`, …) mit durchgereicht.

| Zeile | Name | Signatur (wörtlich) |
|---|---|---|
| 20 | `render-hathi-level` | `render-hathi-level(level, extra-tiles:(), scale: 1, print: false, replace: (:))` |

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `level` | pos | – | Ergebnis von `xml(...)` (Array) | en | Leveldaten |
| `extra-tiles` | named | `()` | Array von Dicts mit `type`, `pos` (x, y), optional `capacity`, `hue`, `direction` | en | zusätzliche Kacheln |
| `scale` | named | `1` | float | en | Skalierung (Kachelhöhe `scale * 25mm`) |
| `print` | named | `false` | bool | en | Druckfassung (nur `grass`/`water` haben `_print`-Varianten) |
| `replace` | named | `(:)` | dictionary Typ → Typ | en | Kacheltypen ersetzen |

Kacheltyp-Enum (Z. 85–109, 118–133): `"grass"`, `"ice"`, `"water"`, `"rock"`,
`"tree"`, `"flag"`, `"lion"`, `"bananas"`, `"crate"`, `"hathi"`, `"hartmut"`
(letztere mit `direction` `0`–`3` → `hathi_0` … `hartmut_3`). XML-Tags:
`world`, `tile`, `item`; Attribute `type`, `x`, `y`, `capacity`, `direction`.
Platzhalter in SVGs: `9999` (Kapazität), `#0000FF` (Flaggenfarbe, `hue`).

Validierung: keine; unbekannte Kacheltypen werden stillschweigend ausgelassen.

Inkonsistenzen / Altlasten:
- Paketname `abbozza`, Entrypoint `hathi-render.typ`, Funktion `render-hathi-level` – drei verschiedene Wortstellungen/Namen.
- `print: false` wie in gutachten und arbeitsblatt 0.4.0 (dort `print`), aber ohne gemeinsamen Mechanismus.
- Doku sagt „isometrisches Hex-Diagramm“ und Ersetzungsbeispiel `("W": "grass")`, Code kennt nur ausgeschriebene Typnamen.
- `hue` ist nur für `extra-tiles` möglich (Z. 47), nicht für XML-Kacheln; nicht im Doc-Kommentar erwähnt, ebenso `direction`.
- Z. 23–28: falsch eingerückter Block `change-hue`; ungenutzte Variable `old-hue`.
- Z. 21: `_scale = scale` als Umweg, weil CeTZ-`*`-Import/`draw` `scale` überschattet.
- Z. 81: `level-tiles` wird per erneutem `let` überschattet.
- Z. 83–111: `tiles(type, …)` lädt bei jedem Aufruf alle 17 Bilder/Dateien.
- Z. 129–133: `hathi`- und `hartmut`-Zweig identisch.

---

## 10. Wer benutzt options, typopst, summify?

Ergebnis von `grep -rn "@schule/(options|typopst|summify)"` über das ganze Repo:

| Paket | Importiert von | Importform |
|---|---|---|
| options 0.0.5 | arbeitsblatt 0.0.2, 0.0.3, 0.0.4, 0.0.5, 0.0.6, 0.0.7, 0.1.0, 0.1.1, 0.1.3 (jeweils `arbeitsblatt.typ:2`); aufgaben 0.0.1 (`aufgaben.typ:1`) | `#import "@schule/options:0.0.5"` |
| typopst 0.0.1 | arbeitsblatt 0.1.4, 0.1.5, 0.1.6, 0.1.7, 0.1.8, 0.1.9 (`arbeitsblatt.typ:1`); aufgaben 0.0.2, 0.0.3, 0.0.4 (`aufgaben.typ:1`) | `#import "@schule/typopst:0.0.1": *` |
| summify 0.1.0 | nur `summify/0.1.0/docs/content.typ` (Z. 28, 64) | – |

Keine aktuelle Version (arbeitsblatt ≥ 0.2.0, aufgaben ≥ 0.1.0, klassenarbeit,
klausurboegen, schuldocs) importiert options, typopst oder summify.
arbeitsblatt 0.4.0 führt stattdessen eigene States `"options"`, `"print"`,
`"ab-scope"` (`src/arbeitsblatt.typ`). Da options und typopst unter Typst
0.15.1 ohnehin nicht mehr kompilieren, sind beide Pakete samt der davon
abhängigen Altversionen faktisch tot. `blockst/*/libs/scratch/options.typ`
ist eine unabhängige Datei gleichen Namens.

Andere Hilfspakete dieses Inventars werden ebenfalls nur von ihrer eigenen
Doku importiert (gutachten: zusätzlich `gutachten/0.0.1/Beispiel.typ`).

---

## 11. Paketübergreifende Befunde

### 11.1 Dieselbe Sache, verschiedene Namen

| Konzept | Varianten (Fundstelle) |
|---|---|
| Druck-/Printmodus | `print: false` (gutachten.typ:27, hathi-render.typ:20; ebenso arbeitsblatt 0.4.0 `src/arbeitsblatt.typ:272`), dort zusätzlich Variante `druck: (print: true)` (arbeitsblatt.typ:901) |
| Inhalte ausblenden | `hide-content` (summify.typ:222) vs. `hide` (summify.typ:526) |
| Schrift | `font`/`math-font` (gutachten.typ:29–30, summify-Theme `typography.font`/`math-font`); arbeitsblatt 0.4.0 `math-font` neben Theme-Schlüssel `schrift.mathe` |
| Kürzel | `kürzel` (gutachten.typ:25) vs. `kuerzel` (arbeitsblatt 0.4.0 themes.typ:67) |
| Titel | `title` named (summify, topic, content) / positional (section, material-box, strichbox); `title` als Aufgabenfeld in gutachten/bewertung.typ:236 neben deutschem `nummer`, `teile` |
| Inhalt | `body` (summify, gutachten, angela), `it` (eduki fill-height-with-text), `..children` (summify compose) |
| erlaubte Werte einer Option | `valid` (options.typ:78) vs. `choices` (typopst options.typ:121) |
| Handler unbekannter Optionen | `unknown` (options.typ:111) vs. `_unknown` (typopst options.typ:180) |
| Präfix | `prefix` (options.typ:197) vs. `_prefix` (typopst options.typ:285) |
| Callback | `func` (options/typopst get), `format` (display, d_ew_*), `code` (addconfig) |
| Punkte/BE | `be` (gutachten), `punkte` (gutachten aufgabe, bewertung.typ) |
| Schüler | `schüler` (State, gutachten.typ:55) vs. `schueler` (typlace) |
| Bildliste | `images` (material-box) vs. `pages` (pageboxes) |
| Thema setzen | `set-theme`/`update-theme` (summify) vs. `set-gutachten-infos`/`set-aufgaben` (gutachten) vs. State `"ab-theme"` (aufgaben 0.3.1) |

### 11.2 Schreibweisen

- kebab-case: summify, typlace, eduki, angela, abbozza, gutachten-Entrypoint, typopst (teilweise).
- snake_case: gutachten `bewertung.typ` (`d_ew_notenspiegel`, `ew_verteilung_oberstufe`), interne `__s_options`.
- zusammengeschrieben: options (`addconfig`, `getconfig`, `parseconfig`), flashcards (`cardnumber`, `letter8up`, `a48up`), eduki `pageboxes`, `strichbox`.
- camelCase: nur auskommentiert in typopst `states.typ`.
- Großbuchstaben im Bezeichner: eduki `layout-1P-1L`.
- Umlaut: gutachten `kürzel`, State `"schüler"`; ae/oe/ue: typlace (`tisch-hoehe`, `koerper-farbe`, `qualitaet`, `"gruendlich"`, `schueler`, `plaetze`).

### 11.3 State-/Label-Namensräume

| Paket | States / Counter / Labels | Präfix? |
|---|---|---|
| options | `"@options"`, `"@config"` | `@`, kollidiert mit typopst |
| typopst | `"@options"`, `"@config"` | `@`, kollidiert mit options |
| summify | `"summify-hide"`, `"summify-theme"` | ja |
| gutachten | `"gutachten-infos"`, `"schüler"`, `"aufgaben"`, `"punkte"`; Label `<vor>-<nach>-pages` | nur der erste; `"aufgaben"` kollidiert mit aufgaben 0.3.1 und mit `bewertung.typ` |
| gutachten/bewertung | `"erwartungen"`, `"aufgaben"`; Labels `<erwartungshorizont>`, `<bewertung>` | nein |
| flashcards | Counter `"cardnumber"`, States `"header"`, `"footer"`, `"question"`, `"answer"`; Label `<card>` | nein |
| typlace, eduki, angela, abbozza | keine | – |

### 11.4 Fehlermeldungen

- deutsch mit Paketpräfix: typlace (`"typlace: …"`).
- deutsch ohne Präfix: gutachten `bewertung.typ:147`.
- englisch: options, typopst, summify, eduki.
- keine Validierung: gutachten-Entrypoint, flashcards, angela, abbozza.
- Prüfung unbekannter Optionen: nur options/typopst (optional über `unknown`/`_unknown`); in keinem der aktiven Hilfspakete.

### 11.5 Veraltete Abhängigkeiten

| Datei | Import | Bemerkung |
|---|---|---|
| gutachten/0.0.2/bewertung.typ:1 | `@preview/tablex:0.0.5` | veraltet (klausurboegen 0.0.2 nutzt 0.0.8; Typst hat native Tabellenzellen) |
| gutachten/0.0.2/bewertung.typ:2 | `@schule/klausurboegen:0.0.2` | aktuell 0.0.5; Import ungenutzt |
| gutachten/0.0.2/gutachten.typ:1 | `@preview/unify:0.7.0` | ungenutzt |
| abbozza/0.0.1/hathi-render.typ:1 | `@preview/cetz:0.3.4` | veraltet |
| eduki/0.1.0/src/eduki.typ:3 | `@preview/shadowed:0.2.0` | – |

### 11.6 Kompilierstatus (Typst 0.15.1, Minimaldokument)

| Paket | Ergebnis |
|---|---|
| options 0.0.5 | Fehler `only element functions can be used as selectors` (options.typ:44) |
| typopst 0.0.1 | derselbe Fehler (options.typ:59) |
| flashcards 0.0.1 | derselbe Fehler (flashcards.typ:39) |
| gutachten 0.0.2 `bewertung.typ` | derselbe Fehler (bewertung.typ:82) |
| gutachten 0.0.2 Entrypoint | ok |
| summify 0.1.0 | ok; mit `hide-content: true`: `expected function, found auto` (summify.typ:538) |
| typlace 0.0.2 | ok |
| eduki 0.1.0 | ok (Warnung: Font „londrina solid“ fehlt) |
| angela 0.0.1 | ok (Warnung: Font „calibri“ fehlt) |
| abbozza 0.0.1 | Import ok (Rendering ohne Level-XML nicht geprüft) |

### 11.7 Sonstige Altlasten im Repo (aus `git status`)

- `aufgaben/0.3.1/aufgaben.typ.orig` (unversioniert, enthält dieselben State-Namen wie `aufgaben.typ`).
- Alte Versionsordner: summify 0.0.1–0.0.3 (0.0.1/0.0.2 mit Entrypoint `cheatsheets.typ`), gutachten 0.0.1, typlace 0.0.1.
- `typst.toml`-Beschreibungen meist Platzhalter „Package for <name>“ (options, typopst, summify, gutachten, flashcards, abbozza).
