// schuldocs – Dokumentations-Brücke für das Schule-Paket-Ökosystem
//
// Kombiniert:
//   • mantys    → PDF-Manuals    (#with-pdf, #show-example in PDF-Modus)
//   • manifesto → Web-Docs       (#with-web + template-fn, #show-example in Web-Modus)
//   • tidy      → API-Extraktion (#show-module)
//
// ARCHITEKTUR:
//   manual.typ  →  #import "@schule/schuldocs:0.1.0": with-pdf, show-example, show-module
//                  #show: with-pdf(name: "pkg", version: "1.0.0", ...)
//                  #include "content.typ"
//
//   web.typ     →  #import "@preview/manifesto:0.1.1": template
//                  #import "@schule/schuldocs:0.1.0": with-web, show-example, show-module
//                  #show: with-web(template-fn: template, toml: toml("../typst.toml"), ...)
//                  #include "content.typ"
//
//   content.typ →  #import "@schule/schuldocs:0.1.0": show-example, show-module
//                  (identischer Inhalt für PDF und Web)
//
// HINWEIS: manifesto wird hier NICHT importiert, da es HTML-Export-Modus
// erfordert und daher nicht in PDF-Kompilierungen geladen werden kann.
// Stattdessen übergibt web.typ die manifesto-template-Funktion explizit.

#import "@preview/mantys:1.0.2" as _mantys
#import "@preview/tidy:0.4.2" as _tidy

// ─── Mode State ─────────────────────────────────────────────────────────────

// Aktiver Dokumentations-Modus: "pdf" oder "web"
// Wird durch #with-pdf() oder #with-web() gesetzt.
#let _docs-mode = state("schuldocs-mode", "web")

// ─── PDF Bridge (mantys) ─────────────────────────────────────────────────────

/// Richtet das PDF-Manual ein (mantys-Brücke).
///
/// Wrapper um `mantys()`, der zusätzlich den Dokumentations-Modus auf `"pdf"`
/// setzt, sodass `show-example()` automatisch als mantys-`example[]` rendert.
///
/// Wird in `manual.typ` via `#show: with-pdf(...)` verwendet.
///
/// ```typ
/// // manual.typ
/// #import "@schule/schuldocs:0.1.0": with-pdf, show-example
/// #import "../src/lib.typ" as mymod
///
/// #show: with-pdf(
///   name: "meinpaket",
///   version: "1.0.0",
///   authors: ("Max Muster",),
///   license: "MIT",
///   description: "Mein Paket.",
///   abstract: [Ausführliche Beschreibung.],
///   examples-scope: (scope: (m: mymod), imports: (m: "*")),
/// )
/// #include "content.typ"
/// ```
///
/// - name (string): Paketname (z. B. `"aufgaben"`)
/// - version (string): Paketversion (z. B. `"0.1.2"`)
/// - authors (array): Liste der Autoren als Strings
/// - license (string): Lizenz-Bezeichner (z. B. `"MIT"`)
/// - description (string): Kurzbeschreibung des Pakets
/// - abstract (content): Ausführlicher Beschreibungstext für die Titelseite
/// - examples-scope (dictionary): Scope für `example[]`-Blöcke in mantys
///   Format: `(scope: (mod: import), imports: (mod: "*"))`
/// - ..rest (any): Weitere Argumente direkt an `mantys()` weitergegeben
/// -> function
#let with-pdf(
  name: "",
  version: "",
  authors: (),
  license: "MIT",
  description: "",
  abstract: [],
  examples-scope: (:),
  ..rest,
) = body => {
  _docs-mode.update("pdf")
  show: _mantys.mantys(
    name: name,
    version: version,
    authors: authors,
    license: license,
    description: description,
    abstract: abstract,
    examples-scope: examples-scope,
    ..rest,
  )
  body
}

// ─── Web Bridge (manifesto) ──────────────────────────────────────────────────

/// Richtet die Web-Dokumentation ein (manifesto-Brücke).
///
/// Setzt den Dokumentations-Modus auf `"web"` und wendet optional die
/// manifesto-Template-Funktion an. Da `manifesto` nur im HTML-Export-Modus
/// geladen werden kann, wird sie als Parameter übergeben (nicht importiert).
///
/// Wird in `web.typ` via `#show: with-web(...)` verwendet.
///
/// ```typ
/// // web.typ
/// #import "@preview/manifesto:0.1.1": template, schema
/// #import "@schule/schuldocs:0.1.0": with-web, show-example
///
/// #let pkg = toml("../typst.toml")
///
/// #show: with-web(
///   template-fn: template,
///   toml: pkg,
///   universe: "https://typst.app/universe/package/" + pkg.package.name,
///   links: ((name: "GitHub", url: pkg.package.repository),),
/// )
/// #include "content.typ"
/// ```
///
/// - template-fn (function): Die `template`-Funktion aus manifesto
///   (`#import "@preview/manifesto:0.1.1": template`)
/// - toml (dictionary): Paket-Metadaten aus `typst.toml`
/// - universe (string): URL zur Typst-Universe-Seite (optional)
/// - notices (array): Hinweistexte als content-Liste
/// - links (array): Zusätzliche Links als `(name: ..., url: ...)` Dictionaries
/// - ..rest (any): Weitere Argumente direkt an `template()` weitergegeben
/// -> function
#let with-web(
  template-fn: none,
  toml: (:),
  universe: none,
  notices: (),
  links: (),
  ..rest,
) = body => {
  _docs-mode.update("web")

  if template-fn != none {
    let web-args = (toml: toml, notices: notices, links: links)
    if universe != none { web-args.insert("universe", universe) }
    // Merge rest named args into web-args
    for (k, v) in rest.named() { web-args.insert(k, v) }

    show: it => template-fn(it, ..web-args)
    body
  } else {
    body
  }
}

// ─── Universal Example Wrapper ────────────────────────────────────────────────

/// Universeller Beispiel-Wrapper – Single Source of Truth für Codebeispiele.
///
/// Rendert ein Beispiel je nach Dokumentations-Modus unterschiedlich:
///
/// *PDF-Modus* (via `#with-pdf`): Delegiert an mantys' `#example[source]`.
/// mantys evaluiert den Quellcode im konfigurierten `examples-scope` und
/// zeigt Quellcode und Ergebnis nebeneinander.
///
/// *Web-Modus* (via `#with-web`): Erwartet eine `schema-fn` (manifesto's
/// `schema`-Funktion) als Parameter oder rendert als natives Layout
/// (Vorschau-Box + Quellcode-Block).
///
/// ```typ
/// // content.typ (identisch für PDF und Web)
/// #show-example(
///   rendered: {
///     import "/src/lib.typ": meine-funktion
///     meine-funktion[Beispieltext]
///   },
///   source: ```typ
///   #meine-funktion[Beispieltext]
///   ```,
///   width: 14cm,
/// )
/// ```
///
/// ```typ
/// // web.typ – manifesto-schema für Web nutzen:
/// #import "@preview/manifesto:0.1.1": schema
/// #let show-example = show-example.with(schema-fn: schema)
/// ```
///
/// - rendered (content): Ausgeführter/gerenderter Inhalt (für Web-Modus)
/// - source (raw): Raw-Block mit dem Typst-Quellcode (für beide Modi)
/// - width (length): Breite des Vorschau-Rahmens im Web-Modus
/// - schema-fn (function): Optional: manifesto's `schema`-Funktion für
///   Web-Modus. Wenn gesetzt, wird `schema-fn(rendered, code: source, width: width)`
///   aufgerufen. Wenn `none`, wird ein natives Fallback-Layout genutzt.
/// -> content
#let show-example(
  rendered: none,
  source: none,
  width: 14cm,
  schema-fn: none,
) = context {
  let mode = _docs-mode.get()
  if mode == "pdf" {
    (_mantys.example)(source)
  } else if schema-fn != none {
    schema-fn(rendered, code: source, width: width)
  } else {
    // Nativer Fallback: Vorschau-Box + Quellcode-Block
    block(
      width: width,
      stroke: 0.5pt + luma(180),
      inset: 0.8em,
      radius: 3pt,
      rendered,
    )
    if source != none {
      block(
        width: width,
        fill: luma(245),
        inset: 0.8em,
        radius: 3pt,
        raw(source.text, lang: "typ", block: true),
      )
    }
  }
}

// ─── Tidy Module Documentation ────────────────────────────────────────────────

/// Zeigt API-Referenz aus tidy-Kommentaren (`///`) eines Moduls.
///
/// Liest und parst tidy-Kommentare aus dem übergebenen Modultext und rendert
/// eine strukturierte Funktionsreferenz. Funktioniert in beiden Modi (PDF + Web).
///
/// ```typ
/// // content.typ
/// = API-Referenz
/// #show-module(read("/src/lib.typ"), name: "meinpaket")
///
/// // Nur bestimmte Funktionen:
/// #show-module(
///   read("/src/lib.typ"),
///   name: "meinpaket",
///   filter: ("aufgabe", "teilaufgabe"),
/// )
/// ```
///
/// - module-text (string): Quelltext des Moduls (via `read("../src/lib.typ")`)
/// - name (string): Angezeigter Modulname (optional)
/// - filter (array): Nur diese Funktionsnamen dokumentieren (leer = alle)
/// - show-outline (boolean): Inhaltsverzeichnis der dokumentierten Funktionen
/// - sort-functions (boolean): Funktionen alphabetisch sortieren
/// -> content
#let show-module(
  module-text,
  name: none,
  filter: (),
  show-outline: true,
  sort-functions: false,
) = {
  let docs = _tidy.parse-module(
    module-text,
    name: name,
    scope: (:),
  )

  let filtered = if filter.len() > 0 {
    (..docs, functions: docs.functions.filter(f => filter.contains(f.name)))
  } else {
    docs
  }

  let sorted = if sort-functions {
    (..filtered, functions: filtered.functions.sorted(key: f => f.name))
  } else {
    filtered
  }

  _tidy.show-module(sorted, show-outline: show-outline, style: _tidy.styles.default)
}

// ─── Gemeinsame Styling-Utilities ────────────────────────────────────────────

/// Zeigt einen Paket-Namen stilisiert.
/// PDF-Modus: mantys-`package[]`; Web-Modus: `raw(name)`.
///
/// - name (string): Paketname
/// -> content
#let pkg-name(name) = context {
  if _docs-mode.get() == "pdf" {
    (_mantys.package)(name)
  } else {
    raw(name)
  }
}

/// Zeigt einen Typst-Typ stilisiert.
/// PDF-Modus: mantys-`dtype[]`; Web-Modus: `raw(type-name)`.
///
/// - type-name (string): Typname (z. B. `"string"`, `"content"`, `"length"`)
/// -> content
#let dtype(type-name) = context {
  if _docs-mode.get() == "pdf" {
    (_mantys.dtype)(type-name)
  } else {
    raw(type-name)
  }
}

/// Zeigt einen Code-Block ohne Live-Ausführung.
/// PDF-Modus: mantys-`sourcecode[]`; Web-Modus: passthrough.
///
/// - body (content): Inhalt (Raw-Block)
/// -> content
#let show-code(body) = context {
  if _docs-mode.get() == "pdf" {
    (_mantys.sourcecode)(body)
  } else {
    body
  }
}

// ─── Re-exports ──────────────────────────────────────────────────────────────

/// Direktzugriff auf das tidy-Modul für erweiterte Nutzung.
#let tidy = _tidy

/// Direktzugriff auf das mantys-Modul für erweiterte Nutzung in manual.typ.
#let mantys = _mantys.mantys
