// schuldocs — API-Referenz aus den `///`-Kommentaren
//
// `tidy.parse-module()` ist reine Rechnung und läuft in beiden Ausgaben; seine
// eigene Darstellung (`tidy.show-module()`) zerbricht dagegen im HTML-Export
// („label <modul-name> does not exist", dazu „pad was ignored"). Deshalb wird
// hier nur geparst und alles Weitere selbst gesetzt.
//
// `parse-module` liefert
//
//   (name, label-prefix, scope, preamble, description, functions, variables)
//
// mit `functions: ((name, description, args, return-types, [parent]), …)` und
// `args: (parametername: (description, [types], [default]), …)`. Die Namen und
// Vorgabewerte stammen aus der Signatur im Quelltext, Typen und Beschreibungen
// aus `///`-Zeilen unmittelbar vor dem jeweiligen Parameter. Ältere Pakete
// beschreiben ihre Parameter stattdessen als Liste `- name (typ): Text` im
// Beschreibungstext; solche Zeilen werden hier herausgelöst und den Parametern
// zugeordnet. Fehlt beides, bleibt die Beschreibung leer — die Darstellung
// lässt dann die entsprechenden Spalten weg.
//
// Klassen der Website (Aussehen kommt aus `docs.css`):
//
//   .sd-api          Hülle um eine Modulreferenz
//   .sd-index        Verzeichnis der Funktionen am Anfang
//   .sd-fn           eine Funktion; trägt die Sprungmarke als `id`
//   .sd-var            dasselbe für eine Variable
//   .sd-sig          Signatur (enthält <pre><code>)
//   .sd-params       Parametertabelle
//   .sd-type         einzelner Typ
//   .sd-returns      Zeile mit dem Rückgabetyp

#import "@preview/tidy:0.4.2" as tidy
#import "config.typ": colors, doc-target

// ─── Beschreibungen auswerten ───────────────────────────────────────────────

// Quelltext-Spannen (```…``` und `…`) bleiben unangetastet.
#let _raw-span = regex("(?s)```.*?```|`[^`]*`")

// Außerhalb solcher Spannen wird alles entschärft, was Typst als Verweis läse:
// `@@name` ist tidys Querverweis, ein einzelnes `@name` wäre ein Verweis auf
// eine Marke, die es nicht gibt — und ein fehlender Verweis bricht den ganzen
// Satz ab.
#let _defuse-refs(text) = {
  let out = text.replace(regex("@@([\\w\\d\\-_]+)"), m => m.captures.at(0))
  out.replace(regex("@([\\p{L}\\d_])"), m => "\\@" + m.captures.at(0))
}

#let _protect(text) = {
  let out = ""
  let pos = 0
  for m in text.matches(_raw-span) {
    out += _defuse-refs(text.slice(pos, m.start))
    out += m.text
    pos = m.end
  }
  out + _defuse-refs(text.slice(pos))
}

// Beschreibungen sind Typst-Markup und werden als solches gesetzt.
#let _doc(text, scope: (:)) = {
  if text == none { return none }
  let trimmed = text.trim()
  if trimmed == "" { return none }
  eval(_protect(trimmed), mode: "markup", scope: scope)
}

// ─── Parameter aus der Beschreibung lösen ───────────────────────────────────

// `- name (typ, typ): Text` — die Schreibweise älterer Pakete.
#let _param-line = regex("^\\s*-\\s+`?([\\w\\d\\-_.]+)`?\\s*(?:\\(([^)]*)\\))?\\s*:\\s*(.*)$")

// Trennt solche Zeilen ab, aber nur, wenn der Name wirklich ein Parameter der
// Funktion ist. Eine gewöhnliche Aufzählung im Fließtext bleibt so erhalten.
#let _split-description(description, arg-names) = {
  let intro = ()
  let params = (:)
  let current = none

  for line in description.split("\n") {
    let m = line.match(_param-line)
    if m != none and arg-names.contains(m.captures.at(0)) {
      current = m.captures.at(0)
      let types = m.captures.at(1)
      params.insert(
        current,
        (
          types: if types == none { () } else { types.split(",").map(str.trim).filter(t => t != "") },
          description: m.captures.at(2).trim(),
        ),
      )
    } else if current != none and line.trim() != "" and line.starts-with(regex("\\s\\s+")) {
      // eingerückte Fortsetzung der laufenden Parameterbeschreibung
      params.at(current).description += "\n" + line.trim()
    } else {
      if line.trim() != "" { current = none }
      intro.push(line)
    }
  }

  (description: intro.join("\n").trim(), params: params)
}

// Führt zusammen, was die Signatur (Name, Vorgabewert) und was die Kommentare
// (Typ, Beschreibung) hergeben.
#let _collect(fn) = {
  let arg-names = fn.args.keys()
  let split = _split-description(fn.description, arg-names)
  let params = ()

  for (name, info) in fn.args {
    let extra = split.params.at(name, default: (types: (), description: ""))
    let types = info.at("types", default: ())
    if types.len() == 0 { types = extra.types }
    let description = info.at("description", default: "").trim()
    if description == "" { description = extra.description }

    params.push((
      name: name,
      types: types,
      description: description,
      default: info.at("default", default: none),
      has-default: "default" in info,
    ))
  }

  (description: split.description, params: params)
}

// ─── Bausteine ──────────────────────────────────────────────────────────────

#let _one-line(value) = value.split("\n").map(str.trim).filter(s => s != "").join(" ")

// Vollständige Signatur als Quelltext. Passt sie nicht in eine Zeile, steht
// jeder Parameter in einer eigenen — das ist der Fall, in dem tidys einzeilige
// Fassung unlesbar wird.
#let _signature(fn, params) = {
  let items = params.map(p => {
    if p.has-default { p.name + ": " + _one-line(p.default) } else { p.name }
  })
  let returns = {
    let types = fn.at("return-types", default: none)
    if types == none { "" } else { " -> " + types.join(" | ") }
  }
  let inline = fn.name + "(" + items.join(", ") + ")" + returns
  if inline.len() <= 60 {
    inline
  } else {
    fn.name + "(\n  " + items.join(",\n  ") + ",\n)" + returns
  }
}

#let _type-chip(t, web) = {
  if web { html.elem("code", attrs: (class: "sd-type"), t) } else { raw(t, lang: none) }
}

#let _types-cell(types, web) = {
  if types.len() == 0 { text(fill: colors.muted)[–] } else { types.map(t => _type-chip(t, web)).join(" | ") }
}

#let _dash = text(fill: colors.muted)[–]

// Parametertabelle. Spalten, für die es nirgends etwas zu zeigen gibt, fallen
// weg; bleibt nur der Name übrig, entfällt die Tabelle ganz — die Signatur
// darüber nennt die Namen bereits.
/// Fügt breitenlose Bruchstellen ein, damit ein langer Vorgabewert in seiner
/// Spalte umbricht statt über sie hinaus.
#let _breakable(text) = {
  let out = text
  for zeichen in ("(", ",", ".", ":") {
    out = out.replace(zeichen, zeichen + "\u{200B}")
  }
  out
}

#let _param-table(params, web, scope) = {
  if params.len() == 0 { return none }

  let has-types = params.any(p => p.types.len() > 0)
  let has-defaults = params.any(p => p.has-default)
  let has-descriptions = params.any(p => p.description.trim() != "")
  if not (has-types or has-defaults or has-descriptions) { return none }

  let header = ([Name],)
  if has-types { header.push([Typ]) }
  if has-defaults { header.push([Vorgabe]) }
  if has-descriptions { header.push([Beschreibung]) }

  let rows = params.map(p => {
    let cells = (raw(p.name, lang: none),)
    if has-types { cells.push(_types-cell(p.types, web)) }
    if has-defaults {
      cells.push(if p.has-default {
        // Quelltext bricht nur an Leerzeichen. Ein Vorgabewert wie
        // `(paint: black.lighten(50%), thickness: 0.5pt)` ragte deshalb im
        // Handbuch in die Nachbarspalte. Nach Klammer, Komma und Punkt darf
        // er jetzt umbrechen — sichtbar ändert das nichts, das Zeichen ist
        // breitenlos.
        raw(_breakable(_one-line(p.default)), lang: "typc")
      } else { _dash })
    }
    if has-descriptions {
      let d = _doc(p.description, scope: scope)
      cells.push(if d == none { _dash } else { d })
    }
    cells
  })

  if web {
    html.elem(
      "table",
      attrs: (class: "sd-params"),
      {
        html.elem("thead", html.elem("tr", header.map(h => html.elem("th", h)).join()))
        html.elem("tbody", rows.map(r => html.elem("tr", r.map(c => html.elem("td", c)).join())).join())
      },
    )
  } else {
    // `auto` für alles außer der Beschreibung lief aus dem Satzspiegel: ein
    // langer, nicht umbrechbarer Vorgabewert — etwa
    // `(paint: black.lighten(50%), thickness: 0.5pt)` — bläht seine Spalte auf,
    // bis die Beschreibung auf wenige Zeichen zusammenfällt und die Tabelle
    // über den Rand steht. Deshalb bekommen alle Spalten Bruchteile: der Name
    // wenig, Typ und Vorgabe je nach Bedarf, die Beschreibung den Rest.
    let letzte = header.len() - 1
    let widths = header.enumerate().map(((i, h)) => {
      if has-descriptions and i == letzte { 1.6fr }
      else if i == 0 { auto }
      else { 1fr }
    })
    table(
      columns: widths,
      inset: (x: 0.55em, y: 0.45em),
      align: left + top,
      stroke: (x, y) => (bottom: 0.5pt + colors.rule),
      fill: (x, y) => if y == 0 { colors.surface },
      table.header(..header.map(h => strong(h))),
      ..rows.flatten(),
    )
  }
}

// ─── Eine Funktion ──────────────────────────────────────────────────────────

#let _show-function(fn, level, anchor, web, scope) = {
  let collected = _collect(fn)
  let signature = _signature(fn, collected.params)

  let body = {
    let title = [#heading(level: level, raw(fn.name, lang: none))#if not web { label(anchor) }]
    if web {
      title
      html.div(class: "sd-sig", raw(signature, lang: "typc", block: true))
    } else {
      title
      // Aussehen kommt von der Vorlage; der Block hier hält nur Überschrift,
      // Signatur und Beschreibung auf derselben Seite zusammen.
      block(sticky: true, width: 100%, raw(signature, lang: "typc", block: true))
    }

    let description = _doc(collected.description, scope: scope)
    if description != none { description }

    let params = _param-table(collected.params, web, scope)
    if params != none { params }

    let returns = fn.at("return-types", default: none)
    if returns != none {
      let line = [Rückgabe: #returns.map(t => _type-chip(t, web)).join(" | ")]
      if web { html.div(class: "sd-returns", line) } else { block(text(fill: colors.muted, line)) }
    }
  }

  if web { html.div(class: "sd-fn", id: anchor, body) } else { body; v(1.4em, weak: true) }
}

// ─── Eine Variable ──────────────────────────────────────────────────────────

#let _show-variable(item, level, anchor, web, scope) = {
  let body = {
    let title = [#heading(level: level, raw(item.name, lang: none))#if not web { label(anchor) }]
    title

    let type = item.at("type", default: none)
    if type != none {
      let line = [Typ: #_type-chip(type, web)]
      if web { html.div(class: "sd-returns", line) } else { block(text(fill: colors.muted, line)) }
    }

    let description = _doc(item.description, scope: scope)
    if description != none { description }
  }

  if web { html.div(class: "sd-var", id: anchor, body) } else { body; v(1.4em, weak: true) }
}

// ─── Öffentliche Funktion ───────────────────────────────────────────────────

/// Setzt die API-Referenz eines Moduls aus seinen `///`-Kommentaren.
///
/// Gelesen wird mit `tidy.parse-module()`, gesetzt wird hier — tidys eigene
/// Darstellung übersteht den HTML-Export nicht. Je Funktion erscheinen Name,
/// vollständige Signatur, Beschreibung, eine Parametertabelle mit Typ und
/// Vorgabewert sowie der Rückgabetyp.
///
/// ```typ
/// == Messwerttabellen
/// #show-module(read("../messwerttabellen.typ"), name: "messwerttabellen")
///
/// // nur einzelne Funktionen:
/// #show-module(read("../lib.typ"), name: "aufgaben", only: ("aufgabe", "loesung"))
/// ```
///
/// Beide Schreibweisen der Parameterdokumentation werden verstanden: `///` vor
/// dem einzelnen Parameter (tidy 0.4) und die Liste `- name (typ): Text` im
/// Beschreibungstext (ältere Pakete). Reiner Fließtext ohne jede
/// Parameterangabe ist ebenfalls zulässig; dann entfallen die leeren Spalten.
///
/// - src (string): Quelltext der Datei, etwa `read("../src/lib.typ")`.
/// - name (string, none): Modulname. Er wird den Sprungmarken vorangestellt,
///   damit mehrere Module in einem Dokument nebeneinander bestehen.
/// - only (array, none): Nur diese Namen dokumentieren. `none` heißt: alle.
/// - exclude (array): Diese Namen auslassen.
/// - filter (array): Alter Name für `only`; eine leere Liste heißt „alle".
/// - sort (bool): Alphabetisch ordnen statt in der Reihenfolge der Datei.
/// - include-private (bool): Auch Namen mit führendem Unterstrich zeigen.
/// - heading-level (auto, int): Stufe der Funktionsüberschriften. `auto` nimmt
///   eine Stufe unterhalb der letzten vorangehenden Überschrift.
/// - show-index (auto, bool): Verzeichnis der Funktionen am Anfang. `auto`
///   heißt: auf der Website ja, im Handbuch nein (dort führt das
///   Inhaltsverzeichnis).
/// - show-name (bool): Den Modulnamen als eigene Überschrift voranstellen.
/// - scope (dictionary): Zusätzliche Namen für die Auswertung der
///   Beschreibungen.
/// - ..rest (any): Wird nicht ausgewertet; hält ältere Aufrufe am Leben.
/// -> content
#let show-module(
  src,
  name: none,
  only: none,
  exclude: (),
  filter: (),
  sort: true,
  include-private: false,
  heading-level: auto,
  show-index: auto,
  show-name: false,
  scope: (:),
  ..rest,
) = context {
  let module-name = if name == none { "" } else { name }
  let docs = tidy.parse-module(src, name: module-name, scope: scope)

  let keep = only
  if keep == none and filter.len() > 0 { keep = filter }

  let select(items) = {
    let out = items
    if not include-private { out = out.filter(x => not x.name.starts-with("_")) }
    if keep != none { out = out.filter(x => keep.contains(x.name)) }
    if exclude.len() > 0 { out = out.filter(x => not exclude.contains(x.name)) }
    if sort { out = out.sorted(key: x => x.name) }
    out
  }

  let functions = select(docs.functions)
  let variables = select(docs.variables)

  let web = doc-target() == "web"
  let prefix = if module-name == "" { "fn-" } else { module-name + "-" }
  let anchor(item) = prefix + item.name

  // Eine Stufe unter der letzten Überschrift davor. Die Abfrage steht am Anfang
  // des Blocks, also vor allen Überschriften, die hier selbst entstehen.
  let level = if heading-level != auto { heading-level } else {
    let before = query(selector(heading).before(here()))
    if before.len() == 0 { 2 } else { calc.min(before.last().level + 1, 6) }
  }

  // Ohne eigene Modulüberschrift stehen die Funktionen selbst auf dieser Stufe.
  let named = show-name and module-name != ""
  let item-level = calc.min(if named { level + 1 } else { level }, 6)

  let body = {
    if named { heading(level: level, raw(module-name, lang: none)) }

    let description = _doc(docs.at("description", default: none), scope: scope)
    if description != none { description }

    let index-wanted = if show-index == auto { web } else { show-index }
    if index-wanted and functions.len() + variables.len() > 1 {
      let entry(item) = {
        let beschriftung = raw(item.name, lang: none)
        if web { link("#" + anchor(item), beschriftung) } else { link(label(anchor(item)), beschriftung) }
      }
      let entries = (functions + variables).map(entry)
      if web {
        html.div(class: "sd-index", list(..entries))
      } else {
        block(list(..entries))
      }
    }

    for fn in functions {
      _show-function(fn, item-level, anchor(fn), web, docs.scope)
    }
    for item in variables {
      _show-variable(item, item-level, anchor(item), web, docs.scope)
    }
  }

  if web { html.div(class: "sd-api", body) } else { body }
}
