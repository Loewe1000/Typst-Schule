# schuldocs

**Dokumentations-Brücke für das Schule-Paket-Ökosystem.**

Kombiniert [tidy](https://typst.app/universe/package/tidy), [mantys](https://typst.app/universe/package/mantys) und [manifesto](https://typst.app/universe/package/manifesto) in einem universellen Single-Source-of-Truth-System: Eine einzige `content.typ` erzeugt sowohl das PDF-Manual als auch die Web-Dokumentation.

## Architektur

```
docs/
  content.typ   ← Single Source of Truth (Text, Beispiele, API-Referenz)
  manual.typ    ← PDF-Brücke  → importiert content.typ, setzt mantys-Setup
  web.typ       ← Web-Brücke  → importiert content.typ, setzt manifesto-Setup
```

## Verwendung

### `manual.typ` (PDF-Brücke)

```typ
#import "@schule/schuldocs:0.1.0": with-pdf, show-example, show-module

#let pkg = toml("../typst.toml")
#import "../src/lib.typ" as mymod

#show: with-pdf(
  name: pkg.package.name,
  version: pkg.package.version,
  authors: pkg.package.authors,
  license: pkg.package.license,
  description: pkg.package.description,
  abstract: [Langer Beschreibungstext...],
  examples-scope: (
    scope: (mymod: mymod),
    imports: (mymod: "*"),
  ),
)

#include "content.typ"
```

### `web.typ` (Web-Brücke)

```typ
#import "@schule/manifesto:0.1.0": with-web, show-example, show-module

#let pkg = toml("../typst.toml")

#show: with-web(
  toml: pkg,
  universe: "https://typst.app/universe/package/" + pkg.package.name,
  links: (
    (name: "GitHub", url: pkg.package.repository),
  ),
)

#include "content.typ"
```

### `content.typ` (Single Source of Truth)

```typ
#import "@schule/schuldocs:0.1.0": show-example, show-module

= Über dieses Paket

Beschreibungstext der in beiden Formaten identisch erscheint.

== Einfaches Beispiel

#show-example(
  rendered: {
    import "/src/lib.typ": meine-funktion
    meine-funktion[Beispielinhalt]
  },
  source: ```typ
  #meine-funktion[Beispielinhalt]
  ```,
  width: 14cm,
)

= API-Referenz

#show-module(read("/src/lib.typ"), name: "meinpaket")
```

## Funktionen

| Funktion | Beschreibung |
|---|---|
| `with-pdf(..args)` | Show-Rule-Wrapper: setzt mantys auf + aktiviert PDF-Modus |
| `with-web(..args)` | Show-Rule-Wrapper: setzt manifesto auf + aktiviert Web-Modus |
| `show-example(rendered, source, width)` | Universeller Beispiel-Wrapper (→ mantys `example[]` / manifesto `schema()`) |
| `show-module(text, name, filter, ...)` | tidy-API-Extraktion (beide Modi) |
| `pkg-name(name)` | Paketname-Styling (`package[]` / `raw`) |
| `dtype(name)` | Typ-Styling (`dtype[]` / `raw`) |
| `show-code(body)` | Code-Block ohne Ausführung (`sourcecode[]` / plain) |

## Abhängigkeiten

- `@preview/mantys:1.0.2`
- `@preview/manifesto:0.1.1`
- `@preview/tidy:0.4.2`
