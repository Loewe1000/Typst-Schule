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
//   content.typ →  #import "@schule/schuldocs:0.1.0": show-module, show-code
//                  (show-example ist über den Parent-Scope verfügbar; im Web-Modus
//                   wird manifesto-schema automatisch verwendet)
//
// HINWEIS: manifesto wird hier importiert, um schema in show-example automatisch
// im Web-Modus zu verwenden. Der Import ist sicher, da schema nur bei mode=="web"
// aufgerufen wird (HTML-Export-Modus) und keine Top-Level html.*-Aufrufe enthält.

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
    // Web-Modus ohne schema-fn: manifesto-kompatibles Layout via html.*
    html.div(
      class: "mb-7 rounded-md text-base border mb-4 flex-col flex *:m-0 *:block *:w-full *:even:rounded-t-none",
      {
        html.div(
          class: "bg-white rounded-md overflow-hidden print:p-4 p-7 [&_svg]:max-w-full [&_svg]:h-auto"
            + if source != none { " rounded-b-none" } else { "" },
          html.frame(block(width: width, rendered)),
        )
        if source != none {
          html.div(
            class: "*:rounded-t-none *:border-none border-t *:m-0 dark:border-mist-800 *:border-none overflow-x-scroll",
            source,
          )
        }
      },
    )
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

  // Workaround für Typst HTML-Export: Programmatische Headings haben immer depth 1 in
  // manifesto's Query. eval("== ...", mode: "markup") erzeugt depth-2-Headings korrekt.
  // Wir rendern Funktionsnamen via eval und den Body direkt ohne tidy's show-module Block.

  let eval-docstring = _tidy.utilities.eval-docstring
  let style-fns = _tidy.utilities.get-style-functions(_tidy.styles.default)
  let style-args = (
    style: style-fns,
    label-prefix: sorted.label-prefix,
    first-heading-level: 2,
    break-param-descriptions: false,
    omit-empty-param-descriptions: true,
    omit-private-parameters: false,
    colors: _tidy.styles.default.colors,
    enable-cross-references: false,
    local-names: (parameters: [Parameters], default: [Default]),
    scope: sorted.scope,
  )

  // "Parameters"- und Parameter-Einzel-Headings aus der Navigation ausschließen
  show heading.where(level: 4): set heading(outlined: false)
  show heading.where(level: 5): set heading(outlined: false)

  for fn in sorted.functions.sorted(key: fn => fn.name) {
    // Markup-Heading → depth 2 in manifesto-Nav (funktioniert korrekt)
    // Label wird in den Heading-String eingebettet (als Markup)
    eval("== " + fn.name + " <" + sorted.label-prefix + fn.name + ">", mode: "markup")

    eval-docstring(fn.description, style-args)

    block(breakable: style-args.break-param-descriptions, {
      heading(style-args.local-names.parameters, level: style-args.first-heading-level + 2)
      (style-fns.show-parameter-list)(fn, style-args: style-args)
    })

    for (name, info) in fn.args {
      if style-args.omit-private-parameters and name.starts-with("_") { continue }
      let types = info.at("types", default: ())
      let description = info.at("description", default: "")
      if description == "" and style-args.omit-empty-param-descriptions { continue }
      (style-fns.show-parameter-block)(
        name, types, eval-docstring(description, style-args),
        style-args,
        show-default: "default" in info,
        default: info.at("default", default: none),
        function-name: style-args.label-prefix + fn.name,
      )
    }
    v(4.8em, weak: true)
  }

  for v-item in sorted.variables {
    eval("== " + v-item.name, mode: "markup")
    {
      show heading.where(level: 3): set heading(outlined: false)
      (style-fns.show-variable)(v-item, style-args)
    }
  }
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
