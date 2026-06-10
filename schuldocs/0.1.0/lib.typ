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

  let heading-style-css = "article :is(h1, h2, h3) { color: rgb(20, 83, 127) !important; } article h2 { color: rgb(12, 74, 110) !important; } article h3 { color: rgb(3, 105, 161) !important; margin-top: 2.1rem !important; } @media (prefers-color-scheme: dark) { article :is(h1, h2, h3) { color: rgb(125, 211, 252) !important; } article h2 { color: rgb(147, 197, 253) !important; } article h3 { color: rgb(103, 232, 249) !important; } }"

  let copy-script-js = "(function(){function addCopyButton(pre){var code=pre&&pre.querySelector('code');if(!code||pre.querySelector('.schuldocs-copy-btn')){return;}pre.style.position='relative';var btn=document.createElement('button');btn.type='button';btn.className='schuldocs-copy-btn';btn.title='Code kopieren';btn.setAttribute('aria-label','Code kopieren');btn.style.cssText='position:absolute;top:0;right:0;z-index:10;border:1px solid rgb(212,212,216);border-radius:.375rem;background:rgba(255,255,255,.92);padding:.3rem;line-height:0;display:inline-flex;align-items:center;justify-content:center;cursor:pointer;';var icon=document.createElementNS('http://www.w3.org/2000/svg','svg');icon.setAttribute('viewBox','0 0 24 24');icon.setAttribute('width','14');icon.setAttribute('height','14');icon.setAttribute('aria-hidden','true');icon.setAttribute('focusable','false');var path=document.createElementNS('http://www.w3.org/2000/svg','path');path.setAttribute('fill','currentColor');path.setAttribute('d','M16 1H6a2 2 0 0 0-2 2v12h2V3h10V1zm3 4H10a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h9a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2zm0 16H10V7h9v14z');icon.appendChild(path);btn.appendChild(icon);function extractCodeText(node){var clone=node.cloneNode(true);var brs=clone.querySelectorAll('br');for(var j=0;j<brs.length;j+=1){brs[j].replaceWith('\\n');}return clone.textContent||'';}btn.onclick=function(){if(!navigator.clipboard){return;}navigator.clipboard.writeText(extractCodeText(code)).then(function(){btn.style.opacity='0.65';setTimeout(function(){btn.style.opacity='1';},900);});};pre.appendChild(btn);}var root=document.currentScript&&document.currentScript.parentElement;var preBlocks=root?root.querySelectorAll('pre'):document.querySelectorAll('pre');for(var i=0;i<preBlocks.length;i+=1){addCopyButton(preBlocks[i]);}})();"

  // Versions-Dropdown: lädt zur Laufzeit {paket}/versions.json (von
  // build.sh erzeugt) und bietet einen Wechsel zwischen den dokumentierten
  // Versionen an. Erscheint nur, wenn mindestens zwei Versionen existieren.
  // HINWEIS: build.sh enthält denselben Code als Injection-Fallback für
  // Seiten, die nicht über with-web gebaut wurden – bei Änderungen beide
  // Stellen synchron halten (Marker: schuldocs-versionen).
  let version-dropdown-js = "(function(){if(document.getElementById('schuldocs-versionen')){return;}var p=location.pathname.replace(/index\\.html$/,'');if(p.slice(-1)!=='/'){p+='/';}var vm=p.match(/\\/(\\d+\\.\\d+\\.\\d+)\\/$/);var root=vm?p.slice(0,p.length-vm[1].length-1):p;var current=vm?vm[1]:null;fetch(root+'versions.json').then(function(r){if(!r.ok){throw 0;}return r.json();}).then(function(versions){if(!Array.isArray(versions)||versions.length<2){return;}var style=document.createElement('style');style.textContent='#schuldocs-versionen{position:fixed;top:.75rem;right:.75rem;z-index:50;padding:.3rem .5rem;border:1px solid rgb(212,212,216);border-radius:.375rem;background:rgba(255,255,255,.92);font:500 .8rem/1.2 Inter,system-ui,sans-serif;color:rgb(63,63,70);cursor:pointer;}@media (prefers-color-scheme:dark){#schuldocs-versionen{background:rgba(39,39,42,.92);color:rgb(212,212,216);border-color:rgb(63,63,70);}}';document.head.appendChild(style);var sel=document.createElement('select');sel.id='schuldocs-versionen';sel.title='Dokumentations-Version';sel.setAttribute('aria-label','Dokumentations-Version wählen');versions.forEach(function(v,i){var o=document.createElement('option');o.value=v;o.textContent=i===0?v+' (neueste)':v;sel.appendChild(o);});sel.value=current||versions[0];sel.onchange=function(){location.href=root+sel.value+'/';};document.body.appendChild(sel);}).catch(function(){});})();"

  let body-with-copy-buttons = {
    body
    html.elem("style", heading-style-css)
    html.elem("script", copy-script-js)
    html.elem("script", version-dropdown-js)
  }

  if template-fn != none {
    let web-args = (toml: toml, notices: notices, links: links)
    if universe != none { web-args.insert("universe", universe) }
    // Merge rest named args into web-args
    for (k, v) in rest.named() { web-args.insert(k, v) }

    show: it => template-fn(it, ..web-args)
    body-with-copy-buttons
  } else {
    body-with-copy-buttons
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

  let code-block = if source != none {
    source
  } else {
    none
  }

  if mode == "pdf" {
    (_mantys.example)(source)
  } else if schema-fn != none {
    schema-fn(rendered, code: code-block, width: width)
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
        if code-block != none {
          code-block
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

  // Private Funktionen und Variablen (Unterstrich-Präfix) nie dokumentieren –
  // ihr Name würde im Markup-Heading-eval zudem als unbalancierte Emphasis
  // scheitern.
  let docs = (
    ..docs,
    functions: docs.functions.filter(f => not f.name.starts-with("_")),
    variables: docs.variables.filter(v => not v.name.starts-with("_")),
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
    local-names: (parameters: [Parameter], default: [Default]),
    scope: sorted.scope,
  )

  // "Parameters"- und Parameter-Einzel-Headings aus der Navigation ausschließen
  show heading.where(level: 4): set heading(outlined: false)
  show heading.where(level: 5): set heading(outlined: false)

  let normalize-default-text = (value, is-string-type: false) => {
    let unescaped = value.trim().replace("\\\"", "\"")

    // Fälle wie ""false"" oder ""EA"" auf "false" bzw. "EA" reduzieren.
    let doubled-quoted = unescaped.match(regex("^\"\"(.*)\"\"$"))
    let undoubled = if doubled-quoted != none {
      "\"" + doubled-quoted.captures.at(0) + "\""
    } else {
      unescaped
    }

    let normalized = undoubled

    // Nur bei String-Parametern bleiben Anführungszeichen erhalten.
    if not is-string-type {
      let quoted-any = normalized.match(regex("^\"(.*)\"$"))
      if quoted-any != none {
        normalized = quoted-any.captures.at(0)
      }
    }

    normalized
  }

  for fn in sorted.functions.sorted(key: fn => fn.name) {
    // Markup-Heading → depth 2 in manifesto-Nav (funktioniert korrekt)
    // Label wird in den Heading-String eingebettet (als Markup)
    eval("== " + fn.name + " <" + sorted.label-prefix + fn.name + ">", mode: "markup")

    let description-lines = fn.description.split("\n")
    let intro-lines = ()
    let parsed-params = (:)

    for line in description-lines {
      let match = line.match(regex("^\\s*-\\s*([^:(][^:(]*)\\s*\\(([^)]*)\\):\\s*(.*)$"))
      if match != none {
        let p-name = match.captures.at(0).trim()
        let p-type = match.captures.at(1).trim()
        let p-description = match.captures.at(2).trim()
        parsed-params.insert(p-name, (type: p-type, description: p-description))
      } else {
        intro-lines.push(line)
      }
    }

    let cleaned-description = intro-lines.join("\n").trim()
    if cleaned-description != "" {
      eval-docstring(cleaned-description, style-args)
    }

    block(breakable: style-args.break-param-descriptions, {
      heading(style-args.local-names.parameters, level: style-args.first-heading-level + 2)
      let rows = ()

      for (name, info) in fn.args {
        if style-args.omit-private-parameters and name.starts-with("_") { continue }

        let parsed = parsed-params.at(name, default: (type: "", description: ""))
        let parsed-type = parsed.type
        let parsed-description = parsed.description

        let types = info.at("types", default: ())
        let info-description = info.at("description", default: "")

        let type-cell = if parsed-type != "" {
          raw(parsed-type)
        } else if types.len() > 0 {
          raw(types.map(t => str(t)).join(", "))
        } else {
          [–]
        }

        let parsed-type-text = if parsed-type != none { str(parsed-type) } else { "" }
        let is-string-type = if parsed-type-text == "string" or parsed-type-text == "str" {
          true
        } else {
          types.filter(t => {
            let t-text = str(t)
            t-text == "string" or t-text == "str"
          }).len() > 0
        }

        let description-text = if parsed-description != "" {
          parsed-description
        } else {
          info-description
        }

        let default-from-description = none
        let description-for-cell = description-text
        let default-match = description-text.match(regex("^(.*)\\s+Default:\\s+(.+)$"))
        if default-match != none {
          description-for-cell = default-match.captures.at(0).trim()
          default-from-description = default-match.captures.at(1).trim()
        }

        let description-cell = if description-for-cell != "" {
          eval-docstring(description-for-cell, style-args)
        } else {
          [–]
        }

        let default-cell = if default-from-description != none {
          eval-docstring(normalize-default-text(default-from-description, is-string-type: is-string-type), style-args)
        } else if "default" in info {
          raw(normalize-default-text(repr(info.at("default", default: none)), is-string-type: is-string-type))
        } else {
          [–]
        }

        rows.push(raw(name))
        rows.push(type-cell)
        rows.push(description-cell)
        rows.push(default-cell)
      }

      if rows.len() == 0 {
        [Keine Parameter.]
      } else {
        table(
          columns: (1.2fr, 1fr, 2.4fr, 1fr),
          align: (left, left, left, left),
          inset: 0.45em,
          table.header(
            strong([Name]),
            strong([Typ]),
            strong([Beschreibung]),
            strong([Default]),
          ),
          ..rows,
        )
      }
    })
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
