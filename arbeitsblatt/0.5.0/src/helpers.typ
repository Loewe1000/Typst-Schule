// helpers.typ – Lücken, Arbeitsflächen, Spalten, Seitenumbrüche, QR-Codes,
// Links, Einheiten und die Zeichenfläche

#import "@preview/cetz:0.4.2": draw
#import "@preview/colorful-boxes:1.4.3": stickybox
#import "@preview/unify:0.8.1": num as unify-num, qty as unify-qty, unit as unify-unit
#import "@schule/aufgaben:0.5.0" as aufgaben
#import "@schule/aufgaben:0.5.0": has-solutions, is-print
#import "internal/check.typ": check-named, check-positional, check-type, check-value
#import "internal.typ": cetz-canvas, fail, normalize-unit, package-name, to-unit-text, zebra-qrcode

// Länge, Anteil und ihre Summe sind in Typst drei Typen.
#let is-relative(value) = type(value) in (length, ratio, relative)

/// Eine Lücke im Text: eine Linie, so breit wie der Inhalt.
///
/// Ohne Lösungen bleibt die Linie leer, der Inhalt bestimmt nur ihre Breite.
/// Sind Lösungen sichtbar (`solutions` nicht `none`), steht der Inhalt auf der
/// Linie.
///
/// ```typ
/// Die Hauptstadt von Frankreich ist #luecke[Paris].
/// Der Wert ist #luecke(tight: true)[42].
/// ```
///
/// - tight (bool): ohne den Einzug von 2em vor dem Inhalt
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Lösungswort; bestimmt die Breite der Lücke
/// -> content
#let luecke(tight: false, ..deprecated, body) = {
  check-positional(package-name, "luecke", (none,) * 1 + deprecated.pos(), max: 1, hint: "nur der Inhalt der Lücke steht ohne Namen")
  check-named(
    package-name,
    "luecke",
    deprecated,
    removed: (
      length: "die Breite bestimmt der Inhalt",
      len: "die Breite bestimmt der Inhalt",
      breite: "die Breite bestimmt der Inhalt",
      width: "die Breite bestimmt der Inhalt",
    ),
    allowed: ("tight",),
  )
  check-type(package-name, "luecke", "tight", tight, bool)
  box(
    move(
      dy: 0.33em,
      box(
        stroke: (bottom: 0.5pt),
        [
          #if not tight {
            h(2em)
          }
          #context if has-solutions() { body } else { hide(body) }
        ],
      ),
    ),
  )
}

/// Inhalt, der nur mit sichtbaren Lösungen erscheint – etwa ausgefüllte
/// Tabellenwerte oder die Nummern einer Zuordnung.
///
/// Anders als `loesung[…]` steht der Inhalt an Ort und Stelle, nicht in einem
/// Lösungskasten. Ohne Lösungen bleibt der Platz frei, damit sich das Layout
/// zwischen Blatt und Lösung nicht verschiebt; mit `reserve: false` fällt er
/// weg (für Beschriftungen wie „2:"). Mit `fallback` steht im Blatt
/// stattdessen anderer Inhalt – etwa Schreiblinien, wo die Lösung einen Satz
/// zeigt.
///
/// ```typ
/// #table(columns: 3, [$x$], [1], [2], [$x^2$], lsg[1], lsg[4])
/// #lsg(fallback: liniert(2))[Die Graphen sind gespiegelt.]
/// ```
///
/// - reserve (bool): den Platz im Blatt freihalten
/// - fallback (content, none): Inhalt nur für das Blatt; ersetzt den freien Platz
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Lösungsinhalt
/// -> content
#let lsg(reserve: true, fallback: none, ..deprecated, body) = {
  check-positional(package-name, "lsg", (none,) * 1 + deprecated.pos(), max: 1, hint: "nur der Lösungsinhalt steht ohne Namen")
  let given = deprecated.named()
  if reserve != true { given.insert("reserve", reserve) }
  if fallback != none { given.insert("fallback", fallback) }
  check-named(
    package-name,
    "lsg",
    given,
    renamed: (platz: "reserve", sonst: "fallback"),
    allowed: ("reserve", "fallback"),
  )
  check-type(package-name, "lsg", "reserve", reserve, bool)
  context {
    if has-solutions() { body } else if fallback != none { fallback } else if reserve {
      hide(body)
    }
  }
}

/// Eine Arbeitsfläche, die mit `workspaces: false` entfällt.
///
/// So setzt dieselbe Quelle das Blatt mit Schreibflächen und die
/// Lösungsfassung ohne sie.
///
/// ```typ
/// #workspace[#kariert(4)]
/// ```
///
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt der Arbeitsfläche, zum Beispiel `kariert(4)`
/// -> content
#let workspace(..deprecated, body) = {
  check-positional(package-name, "workspace", (none,) * 1 + deprecated.pos(), max: 1, hint: "nur der Inhalt der Arbeitsfläche steht ohne Namen")
  check-named(
    package-name,
    "workspace",
    deprecated,
    removed: (height: "war wirkungslos; die Höhe bestimmt der Inhalt, zum Beispiel `kariert(4)`"),
    allowed: (),
  )
  context {
    if aufgaben.internal.options-state.get().workspaces {
      body
    }
  }
}

/// Setzt mehrere Inhalte nebeneinander in Spalten.
///
/// ```typ
/// #minipage[Linke Spalte][Rechte Spalte]
///
/// #minipage(columns: (1fr, 2fr), gutter: 1cm)[
///   Schmale Spalte
/// ][
///   Breite Spalte
/// ]
/// ```
///
/// - columns (auto, int, array): Spalten wie bei `table`; `auto` gibt jedem Inhalt eine gleich breite Spalte
/// - align (alignment, array, function): Ausrichtung in den Zellen wie bei `table`
/// - gutter (length, relative, ratio, fraction): Abstand zwischen Spalten und zwischen Zeilen
/// - inset (length, relative, ratio, dictionary, array, function): Innenabstand der Zellen wie bei `table`
/// - ..cells (arguments): die Inhalte, je einer pro Zelle
/// -> content
#let minipage(columns: auto, align: horizon, gutter: 5mm, inset: 0pt, ..cells) = {
  let given = cells.named()
  if gutter != 5mm { given.insert("gutter", gutter) }
  check-named(
    package-name,
    "minipage",
    given,
    renamed: (spacing: "gutter"),
    removed: (
      row-gutter: "`gutter` gilt für Spalten und Zeilen",
      column-gutter: "`gutter` gilt für Spalten und Zeilen",
      stroke: "für ein eigenes Raster `grid` oder `table` schreiben",
      fill: "für ein eigenes Raster `grid` oder `table` schreiben",
      rows: "für ein eigenes Raster `grid` oder `table` schreiben",
    ),
    allowed: ("columns", "align", "gutter", "inset"),
  )
  check-type(package-name, "minipage", "columns", columns, (auto, int, array), example: "(1fr, 2fr)")
  check-type(package-name, "minipage", "align", align, (alignment, array, function), example: "top")
  if not is-relative(gutter) and type(gutter) != fraction {
    check-type(package-name, "minipage", "gutter", gutter, (relative, fraction), example: "5mm")
  }
  if not is-relative(inset) and type(inset) not in (dictionary, array, function) {
    check-type(package-name, "minipage", "inset", inset, (relative, dictionary, array, function), example: "5pt")
  }
  let bodies = cells.pos()
  table(
    stroke: none,
    columns: if columns == auto { (1fr,) * bodies.len() } else { columns },
    align: align,
    inset: inset,
    column-gutter: gutter,
    row-gutter: gutter,
    ..bodies,
  )
}

/// Ein Seitenumbruch, der nur in bestimmten Fassungen wirkt.
///
/// Ohne Bedingung ist es ein gewöhnlicher Umbruch. Mehrere Bedingungen müssen
/// alle zutreffen.
///
/// ```typ
/// #conditional-pagebreak(print: true)              // nur in der Druckfassung
/// #conditional-pagebreak(print: false)             // nur am Bildschirm
/// #conditional-pagebreak(solutions-visible: true)  // nur mit sichtbaren Lösungen
/// ```
///
/// - print (auto, bool): `true` = nur in der Druckfassung, `false` = nur in der Bildschirmfassung, `auto` =
///   in beiden
/// - solutions-visible (auto, bool): `true` = nur wenn Lösungen sichtbar sind, `false` = nur ohne Lösungen,
///   `auto` = in beiden Fällen
/// - weak (bool): schwacher Umbruch wie bei `pagebreak`
/// - to (str, none): `"even"` oder `"odd"` wie bei `pagebreak`
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> content
#let conditional-pagebreak(print: auto, solutions-visible: auto, weak: false, to: none, ..deprecated) = {
  check-positional(package-name, "conditional-pagebreak", deprecated)
  check-named(
    package-name,
    "conditional-pagebreak",
    deprecated,
    removed: (
      loesungen-only: "`solutions-visible: true` gilt für jede sichtbare Lösung; `loesungen-only` galt nur für die reine Lösungsfassung",
    ),
    allowed: ("print", "solutions-visible", "weak", "to"),
  )
  check-type(package-name, "conditional-pagebreak", "print", print, (auto, bool))
  check-type(package-name, "conditional-pagebreak", "solutions-visible", solutions-visible, (auto, bool))
  check-type(package-name, "conditional-pagebreak", "weak", weak, bool)
  check-value(package-name, "conditional-pagebreak", "to", to, (none, "even", "odd"))
  context {
    if print != auto and is-print() != print { return }
    if solutions-visible != auto and has-solutions() != solutions-visible { return }
    pagebreak(weak: weak, to: to)
  }
}

/// Setzt einen QR-Code.
///
/// Der Hintergrund ist durchsichtig, damit sich der Code in farbige Kästen
/// einfügt.
///
/// ```typ
/// #qr-code("https://typst.app", width: 2cm)
/// ```
///
/// - url (str): Adresse oder Text des Codes
/// - width (auto, length): Breite
/// - quiet-zone (bool, int): weißer Rand um den Code; `true` = vier Felder, eine Zahl = so viele Felder
/// - fill (color, gradient): Farbe der dunklen Felder
/// - background-fill (color, gradient, none): Farbe hinter dem Code; `none` = durchsichtig
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> content
#let qr-code(url, width: auto, quiet-zone: false, fill: black, background-fill: none, ..deprecated) = {
  check-positional(package-name, "qr-code", (none,) * 1 + deprecated.pos(), max: 1, hint: "nur die Adresse steht ohne Namen")
  let given = deprecated.named()
  if fill != black { given.insert("fill", fill) }
  if background-fill != none { given.insert("background-fill", background-fill) }
  check-named(
    package-name,
    "qr-code",
    given,
    renamed: (light-color: "background-fill", background: "background-fill", dark-color: "fill"),
    removed: (
      alt: "war wirkungslos",
      options: "`qrcode` aus `@preview/zebra:0.1.0` selbst importieren",
      height: "`qrcode` aus `@preview/zebra:0.1.0` selbst importieren",
      module-size: "`qrcode` aus `@preview/zebra:0.1.0` selbst importieren",
    ),
    allowed: ("width", "quiet-zone", "fill", "background-fill"),
  )
  check-type(package-name, "qr-code", "url", url, (str, bytes), example: "\"https://typst.app\"")
  check-type(package-name, "qr-code", "width", width, (auto, length), example: "2cm")
  check-type(package-name, "qr-code", "quiet-zone", quiet-zone, (bool, int))
  check-type(package-name, "qr-code", "fill", fill, (color, gradient), example: "black")
  check-type(package-name, "qr-code", "background-fill", background-fill, (color, gradient, none), example: "white")
  zebra-qrcode(
    url,
    ..if width != auto { (width: width) },
    // zebra setzt ohne Angabe keinen Rand
    ..if quiet-zone != false { (quiet-zone: quiet-zone) },
    fill: fill,
    background-fill: if background-fill == none { white.transparentize(100%) } else { background-fill },
  )
}

/// Ein Link mit Symbol davor.
///
/// ```typ
/// #icon-link("https://typst.app")[Zur Typst-App]
/// #icon-link("https://github.com", icon: emoji.cat, fill: black)[GitHub]
/// ```
///
/// - url (str, label, location, dictionary): Zieladresse oder Sprungziel im Dokument – alles, was `link` annimmt
/// - icon (auto, content, str, symbol): Symbol vor dem Text; `auto` = Kettenglied
/// - fill (color): Farbe des Linktexts
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content, str): Linktext
/// -> content
#let icon-link(url, icon: auto, fill: blue, ..deprecated, body) = {
  check-positional(package-name, "icon-link", (none,) * 2 + deprecated.pos(), max: 2, hint: "nur Adresse und Linktext stehen ohne Namen")
  let given = deprecated.named()
  if fill != blue { given.insert("fill", fill) }
  check-named(package-name, "icon-link", given, renamed: (color: "fill"), allowed: ("icon", "fill"))
  check-type(package-name, "icon-link", "url", url, (str, label, location, dictionary), example: "\"https://typst.app\"")
  check-type(package-name, "icon-link", "icon", icon, (auto, content, str, symbol), example: "emoji.chain")
  check-type(package-name, "icon-link", "fill", fill, color, example: "blue")
  let shown = if icon == auto { emoji.chain } else { icon }
  link(url)[#shown #text(fill: fill, [#body])]
}

/// Ein Zettel mit QR-Code und Link darunter.
///
/// Die Schrift des Links passt sich der Breite an.
///
/// ```typ
/// #qr-box("https://typst.app", width: 3cm)[Typst-App]
/// ```
///
/// - url (str): Adresse für QR-Code und Link
/// - width (length): Breite des Zettels
/// - rotation (auto, angle): Drehung des Zettels; `auto` = ungedreht
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content, str): Linktext unter dem Code
/// -> content
#let qr-box(url, width: 3cm, rotation: auto, ..deprecated, body) = {
  check-positional(package-name, "qr-box", (none,) * 2 + deprecated.pos(), max: 2, hint: "nur Adresse und Linktext stehen ohne Namen")
  check-named(
    package-name,
    "qr-box",
    deprecated,
    removed: (
      fill: "`stickybox` direkt benutzen",
      tape: "`stickybox` direkt benutzen",
    ),
    allowed: ("width", "rotation"),
  )
  check-type(package-name, "qr-box", "url", url, str, example: "\"https://typst.app\"")
  check-type(package-name, "qr-box", "width", width, length, example: "3cm")
  check-type(package-name, "qr-box", "rotation", rotation, (auto, angle), example: "5deg")
  stickybox(width: width, ..if rotation != auto { (rotation: rotation) })[
    #set std.align(center)
    #qr-code(url, width: 0.75 * width)
    #std.align(
      center,
      layout(available => {
        // Zielbreite: 80 % des Zettels, höchstens aber der Platz innerhalb
        // seines Innenabstands – sonst trennte der Linktext („App-let").
        let target-width = calc.min(0.8 * width, available.width)
        let with-icon(size) = text(size, hyphenate: false, icon-link(url, body))
        let without-icon(size) = text(size, blue, hyphenate: false, link(url, body))
        let text-size = 12pt
        let shown = with-icon(text-size)
        let has-icon = true
        while measure(with-icon(text-size)).width > target-width and text-size > 10pt {
          text-size = text-size - 0.1pt
          shown = with-icon(text-size)
        }
        if text-size <= 10pt {
          has-icon = false
          while measure(without-icon(text-size)).width < target-width and text-size < 12pt {
            text-size = text-size + 0.1pt
          }
          // Passt der Text auch ohne Symbol nicht, bis 8 pt verkleinern; danach
          // bricht er an Leerzeichen oder Bindestrich um, getrennt wird nicht.
          while measure(without-icon(text-size)).width > target-width and text-size > 8pt {
            text-size = text-size - 0.1pt
          }
          shown = without-icon(text-size)
        }
        text(
          size: text-size,
          [
            #v(-1em)
            #v(0.05 * width)
            #shown
            #if has-icon { v(0.05 * width) }
          ],
        )
      }),
    )
  ]
}

// Hinweis für Argumente, die an unify gingen.
#let unify-hint = "`unify` selbst importieren: `#import \"@preview/unify:0.8.1\" as unify`"
#let unify-removed = (
  thousandsep: unify-hint,
  multiplier: unify-hint,
  space: unify-hint,
  rawunit: unify-hint,
  num-unit-space: unify-hint,
  e: unify-hint,
  per-mode: unify-hint,
  digits: unify-hint,
)

/// Setzt eine Größe aus Zahl und Einheit.
///
/// Zahl und Einheit dürfen Text oder Inhalt sein.
///
/// ```typ
/// #qty[9.81][m/s^2]
/// #qty("230", "V")
/// ```
///
/// - value (str, int, float, content): Zahlenwert
/// - units (str, content): Einheit, zum Beispiel `"m/s^2"`
/// - per (str): Bruch in der Einheit: `"fraction"` (Bruchstrich), `"symbol"` (Schrägstrich) oder
///   `"power"` (negativer Exponent)
/// - ..deprecated (arguments): fängt Argumente ab, die früher an unify gingen; nimmt nichts an
/// -> content
#let qty(value, units, per: "fraction", ..deprecated) = {
  check-positional(package-name, "qty", (none,) * 2 + deprecated.pos(), max: 2, hint: "nur Zahl und Einheit stehen ohne Namen")
  check-named(package-name, "qty", deprecated, removed: unify-removed, allowed: ("per",))
  check-type(package-name, "qty", "value", value, (str, int, float, content), example: "\"9.81\"")
  check-type(package-name, "qty", "units", units, (str, content), example: "\"m/s^2\"")
  check-type(package-name, "qty", "per", per, str, example: "\"symbol\"")
  unify-qty(to-unit-text(value), normalize-unit(to-unit-text(units)), per: per)
}

/// Setzt eine Zahl mit Dezimalkomma und Tausendertrennung.
///
/// ```typ
/// #num[3.14]
/// #num("12345.6")
/// ```
///
/// - value (str, int, float, content): Zahl
/// - ..deprecated (arguments): fängt Argumente ab, die früher an unify gingen; nimmt nichts an
/// -> content
#let num(value, ..deprecated) = {
  check-positional(package-name, "num", (none,) * 1 + deprecated.pos(), max: 1, hint: "nur die Zahl steht ohne Namen")
  check-named(package-name, "num", deprecated, removed: unify-removed, allowed: ())
  check-type(package-name, "num", "value", value, (str, int, float, content), example: "\"3.14\"")
  unify-num(to-unit-text(value))
}

/// Setzt eine Einheit ohne Zahl.
///
/// ```typ
/// #unit[N/m^2]
/// #unit("km/h")
/// ```
///
/// - units (str, content): Einheit, zum Beispiel `"N/m^2"`
/// - per (str): Bruch in der Einheit: `"fraction"`, `"symbol"` oder `"power"`
/// - ..deprecated (arguments): fängt Argumente ab, die früher an unify gingen; nimmt nichts an
/// -> content
#let unit(units, per: "fraction", ..deprecated) = {
  check-positional(package-name, "unit", (none,) * 1 + deprecated.pos(), max: 1, hint: "nur die Einheit steht ohne Namen")
  check-named(package-name, "unit", deprecated, removed: unify-removed, allowed: ("per",))
  check-type(package-name, "unit", "units", units, (str, content), example: "\"N/m^2\"")
  check-type(package-name, "unit", "per", per, str, example: "\"symbol\"")
  unify-unit(normalize-unit(to-unit-text(units)), per: per)
}

/// Zeichenfläche von cetz mit den Achsen der Schule-Pakete: Teilstriche nach
/// innen, graues Gitter, Pfeilspitzen, Achsenbeschriftung an den Enden.
///
/// ```typ
/// #canvas(length: 0.8cm, {
///   draw.line((0, 0), (3, 2))
///   draw.circle((3, 2), radius: 0.2)
/// })
/// ```
///
/// - length (length): Länge einer Einheit
/// - padding (none, int, float, length, array, dictionary): Rand um die Zeichnung wie bei `cetz.canvas`
/// - ..deprecated (arguments): fängt weitere cetz-Argumente ab, nimmt nichts an
/// - body (array): Zeichenbefehle aus `draw`
/// -> content
#let canvas(length: 1cm, padding: none, ..deprecated, body) = {
  let cetz-hint = "`cetz.canvas` nach `#import \"@preview/cetz:0.4.2\"` benutzen"
  check-positional(package-name, "canvas", (none,) * 1 + deprecated.pos(), max: 1, hint: "nur die Zeichenbefehle stehen ohne Namen")
  check-named(
    package-name,
    "canvas",
    deprecated,
    removed: (baseline: cetz-hint, debug: cetz-hint, background: cetz-hint, stroke: cetz-hint),
    allowed: ("length", "padding"),
  )
  check-type(package-name, "canvas", "length", length, std.length, example: "1cm")
  cetz-canvas(
    length: length,
    padding: padding,
    {
      draw.set-style(
        axes: (
          tick: (offset: -50%, minor-offset: -25%, minor-length: 100%),
          grid: (
            stroke: (paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt),
            fill: none,
          ),
          minor-grid: (
            stroke: (paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt),
            fill: none,
          ),
          mark: (end: "straight"),
          x: (label: (anchor: "south-east", offset: -0.2)),
          y: (label: (anchor: "north-west", offset: -0.2)),
          overshoot: 8pt,
        ),
      )
      body
    },
  )
}
