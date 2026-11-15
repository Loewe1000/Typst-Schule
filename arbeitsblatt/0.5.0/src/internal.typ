// =============================================================================
// internal.typ – interne Schnittstelle von @schule/arbeitsblatt 0.5.0
// =============================================================================
//
// Zugriff aus anderen @schule-Paketen ausschließlich als Modul:
//
//   #import "@schule/arbeitsblatt:0.5.0" as worksheet-package
//   worksheet-package.internal.scope-state.get()
//
// Dokumente benutzen dieses Modul nicht; es ist keine zugesicherte Schnittstelle
// und darf sich mit jeder Version ändern (konvention.md 7.2). Jeder State des
// Pakets wird genau hier angelegt.
//
// -----------------------------------------------------------------------------
// 1. FÜR KLASSENARBEIT  (ersetzt `_state_ab_scope`, `_theme-aufloesen` und das
//    Durchreichen von `..args` an `arbeitsblatt-einzeln` aus 0.4.0)
// -----------------------------------------------------------------------------
//
//   Die ganze öffentliche Oberfläche weiterreichen (Lint-Ausnahme L19 für
//   klassenarbeit ← arbeitsblatt): in der Einstiegsdatei von klassenarbeit
//
//       #import "@schule/arbeitsblatt:0.5.0": *
//       #import "klassenarbeit.typ": klassenarbeit      // Eigenes danach
//       #import "internal.typ"                          // überdeckt arbeitsblatt.internal
//
//   Der Wildcard bindet alles, was src/lib.typ exportiert: die eigenen Namen,
//   die Bausteine und Aktionen aus aufgaben, die Muster, die Fachbausteine, die
//   acht Fremdnamen und die abbrechenden Stubs. Das Modul `internal` von
//   arbeitsblatt wird dabei mitgebunden; klassenarbeit überdeckt es mit seinem
//   eigenen `internal` und greift in den Implementierungsdateien über den
//   Modulnamen zu (`worksheet-package.internal.…`).
//
//   scope-state            state "schule/arbeitsblatt/scope@1": Kennung der laufenden
//                          Fassung im Bündel oder `none` (ein einzelnes Dokument).
//                          Geschrieben von `arbeitsblatt-einzeln(scope: …)`.
//                          Die Kennung ist `[<filename>-]<Name der Fassung>` mit dem
//                          NEUEN Namen der Fassung ("solutions", nicht "loesung").
//   resolve-theme(theme, accent: auto, class: none, package: …, function: …)
//                          `none` (klassische Darstellung) oder das geprüfte
//                          Theme-Dictionary. Braucht keinen `context`.
//   worksheet-parameters   Parametertabelle Name → (default:, types:, only:, text:),
//                          die einzige Quelle der Kopfparameter (internal/parameters.typ).
//   single-parameter-names Namen der Parameter von `arbeitsblatt-einzeln` (mit `scope`)
//   bundle-parameter-names Namen der Parameter von `arbeitsblatt`
//   worksheet-renames      alter Kopfparameter → neuer Name, für `check-named(renamed: …)`
//   worksheet-removed      entfernter Kopfparameter → Hinweis, für `check-named(removed: …)`
//   check-worksheet-options(package, function, options)
//                          prüft Typen, Werte und Kombinationen eines Dictionary
//                          Kopfparameter → Wert (beliebige Teilmenge) und meldet unter
//                          `<package>.<function>`. klassenarbeit ruft es mit den Werten,
//                          die es an `arbeitsblatt-einzeln` weitergibt; dann nennt die
//                          Meldung `klassenarbeit.klassenarbeit`.
//   variant-presets        vordefinierte Fassungen: Name → abweichende Kopfparameter
//   variant-suffixes       Name der Fassung → eingefrorener Teil des Dateinamens
//                          (`solutions` → `loesung`)
//   variant-renames        alter Name einer Fassung → neuer Name
//   resolve-variants(variants, variant-overrides, package: …, function: …)
//                          Array aus (Name, Overrides)-Paaren, geprüft
//   variant-path(name, filename)  Ausgabepfad `[<filename>-]<Endung>.pdf`
//   variant-scope(name, filename) Scope-Kennung `[<filename>-]<Name>`
//   preview-all-requested()       `--input vorschau=alle` gesetzt?
//
//   Eine einzelne Fassung setzt klassenarbeit wie bisher mit
//   `show: worksheet-package.arbeitsblatt-einzeln.with(title: …, scope: …, …)`.
//
// -----------------------------------------------------------------------------
// 2. STATES, LABELS, METADATEN
// -----------------------------------------------------------------------------
//
//   scope-state            siehe oben
//   scope-start-label(scope), scope-end-label(scope)
//                          <schule-arbeitsblatt-start-{scope}> / <schule-arbeitsblatt-end-{scope}>
//                          an `metadata("worksheet-start")` / `metadata("worksheet-end")`
//   two-up-top-label, two-up-end-label
//                          <schule-arbeitsblatt-two-up-top>, <schule-arbeitsblatt-two-up-end>
//   meta-label             <ab-meta> (eingefrorene Außenschnittstelle, konvention.md 2.1)
//   meta-keys              Kopfparameter → deutscher Schlüssel in <ab-meta>
//   meta-values            Rückabbildung englischer Werte auf die deutschen (`level`, `kind`)
//   meta-record(options)   das Dictionary für <ab-meta>
//
//   Druckmodus, Optionen, Theme und Aufgabenzähler liegen in aufgaben
//   (`aufgaben.internal.print-state`, `options-state`, `theme-state`, …).
//
// -----------------------------------------------------------------------------
// 3. THEME-VERTRAG  (konvention.md A.12)
// -----------------------------------------------------------------------------
//
//   theme-keys             alle erlaubten Schlüssel eines Theme-Dictionary
//   theme-key-renames      alter Schlüssel (0.4.0) → neuer Schlüssel
//   theme-key-removed      entfernter Schlüssel → Hinweis
//
//   Schlüssel                Typ, Bedeutung, Vorgabe ohne Eintrag
//   name                     str, Name des Themes (nur für Meldungen)
//   font                     str | array, Textschrift ("Myriad Pro")
//   math-font                str | array, Formelschrift ("Fira Math")
//   font-size                length (12pt)
//   title-font-size          length (16pt)
//   margin                   dictionary mit `top`, `bottom`, `inside`, `outside`
//                            (2.3cm im Druck sonst 2.2cm; 1cm; 2.25cm; 1.25cm)
//   header-top               length, Abstand Blattkante – Kopf (1.2cm); nur mit Hook `header`
//   header-ascent            length | ratio, Abstand Kopf – Text (0.8cm mit Hook `header`, sonst 20%)
//   footer-descent           length | ratio (30%)
//   header                   (title: none, class: none, copyright-url: none, font-size: auto) => content
//   footer                   (duplex: true) => content; nur in der Druckfassung
//   background               (print: true, margin: (:), header-top: 0cm) => content;
//                            `margin` ist das aufgelöste margin-Dictionary der Seite,
//                            `header-top` der obere Seitenrand
//   callout                  (kind: "info", title: none, accent: auto, breakable: false,
//                            width: auto, body) => content
//   setup                    body => content, weitere Show-Regeln
//   task, task-marker, task-marker-width, subtask, solution, solution-heading,
//   material-heading         wertet aufgaben aus (aufgaben.internal, Abschnitt 4)
//
// -----------------------------------------------------------------------------
// 4. HELFER
// -----------------------------------------------------------------------------
//
//   fail(function, message)                 bricht ab mit "arbeitsblatt.<function>: <message>"
//   plain-text(value)                       Klartext eines Inhalts oder `none`
//   normalize-unit(value), to-unit-text(value)   Einheiten für unify
//   paper-sizes, next-paper                 Maße A3–A6; nächstgrößeres Format
//   count-pagebreaks(body)                  ausdrückliche Umbrüche im Inhaltsbaum
//   resolve-margin(margin)                  (left:, right:, top:, bottom:)
//   subject-accents, subject-names          Fachkürzel → Farbe / Fachname (öffentlich)
//   parse-class(class)                      (subject:, name:, year:)
//   subject-line(class)                     „Mathematik · Klasse 5" oder `none`
//   class-accent(class)                     Fachfarbe zum Klassenkürzel
//   palette                                 (green:, yellow:, orange:, red:, violet:, teal:)
//   callout-style-table, callout-kinds, callout-titles
//   callout-style(kind, worksheet-accent: auto, accent: auto, ..deprecated)   (öffentlich)
//   callout-classic(kind)                   gentle-clues-Kasten der Art
//   callout(kind, function: …, title: auto, accent: auto, breakable: false, width: auto, body)
//   outside-aligned(duplex: true, format)   Seitenzahl in der äußeren Ecke
//   side-margins(margin, page-number)       (links, rechts) der Seite
//   badge, shadow-box, shadow-block, solution-inline   Bausteine der eingebauten Themes
//   copyright-code(url, size: …, fill: …)   kleiner QR-Code für die Kopfzeile
//   default-header(title: none, class: none, copyright-url: none, font-size: auto)
//   cetz-canvas                             `canvas` aus cetz 0.4.2 (unverpackt)
//   zebra-qrcode                            `qrcode` aus zebra 0.1.0
// =============================================================================

#import "@preview/cetz:0.4.2": canvas as cetz-canvas
#import "@preview/zebra:0.1.0": qrcode as zebra-qrcode
#import "@schule/aufgaben:0.5.0" as aufgaben
#import "internal/check.typ": check-named, check-not-empty, check-positional, check-type, check-value, fail as check-fail, fold-name
#import "internal/parameters.typ": worksheet-parameters

#let package-name = "arbeitsblatt"

/// Bricht mit `arbeitsblatt.<function>: <message>` ab.
///
/// - function (str): Funktionsname
/// - message (str): Befund und Abhilfe, getrennt durch ` – `
/// -> none
#let fail(function, message) = check-fail(package-name, function, message)

// ----------------------------------------------------------------------------
// States und Labels
// ----------------------------------------------------------------------------

// Aktive Scope-Kennung im Bündel. Als State (statt Closure), damit
// verschachtelte Aufrufe (eine zweite Klassenarbeit innerhalb des
// Varianten-Dokuments der ersten) die dokumentlokale Verweisauflösung erben.
#let scope-state = state("schule/arbeitsblatt/scope@1", none)

// Wird `true`, sobald die Vorlage ihre Optionen in den State von aufgaben
// geschrieben hat. Bis dahin (im ersten Layout-Durchlauf also überall) nimmt
// die Kurzschreibweise den Wert aus dem Vorlagenaufruf; das spart einen
// Durchlauf gegenüber dem reinen Lesen aus dem State und liefert dasselbe.
#let started-state = state("schule/arbeitsblatt/started@1", false)

#let scope-start-label(scope) = label("schule-arbeitsblatt-start-" + scope)
#let scope-end-label(scope) = label("schule-arbeitsblatt-end-" + scope)
#let two-up-top-label = <schule-arbeitsblatt-two-up-top>
#let two-up-end-label = <schule-arbeitsblatt-two-up-end>
#let meta-label = <ab-meta>

// ----------------------------------------------------------------------------
// Text und Einheiten
// ----------------------------------------------------------------------------

/// Klartext eines Inhalts: `[ A]` → `" A"`, `[$Omega$]` → `"Ω"`. `none`, wenn
/// sich kein Text lesen lässt.
///
/// - value (any): Inhalt, Text oder Zahl
/// -> str, none
#let plain-text(value) = {
  if value == none { return none }
  if type(value) == str { return value }
  if type(value) != content { return str(value) }
  if value.func() == [ ].func() { return " " }
  if value.has("text") { return value.text }
  if value.has("children") { return value.children.map(plain-text).join(default: "") }
  if value.has("body") { return plain-text(value.body) }
  none
}

/// Schreibweisen, die unify ohne Meldung weglässt, auf seine Namen abbilden.
///
/// - value (str): Einheit
/// -> str
#let normalize-unit(value) = {
  value.trim().replace("°C", "dC").replace("Ω", "Ohm").replace("µ", "u").replace("μ", "u")
}

/// Wert oder Einheit als Text für unify.
///
/// - value (any): Text, Zahl oder Inhalt
/// -> str
#let to-unit-text(value) = {
  if type(value) in (str, int, float) {
    str(value)
  } else if type(value) == content and plain-text(value) != none {
    plain-text(value).trim()
  } else if type(value) == content {
    let rendered = repr(value)
    if rendered.starts-with("[") and rendered.ends-with("]") and rendered.len() >= 2 {
      rendered.slice(1, rendered.len() - 1)
    } else {
      rendered
    }
  } else {
    repr(value)
  }
}

// ----------------------------------------------------------------------------
// Papier und Ränder
// ----------------------------------------------------------------------------

// Maße der unterstützten Papierformate im Hochformat (Breite, Höhe). Typst
// kennt die Formate nur als Namen; für `two-up` werden die Zahlen gebraucht.
#let paper-sizes = (
  a3: (297mm, 420mm),
  a4: (210mm, 297mm),
  a5: (148mm, 210mm),
  a6: (105mm, 148mm),
)

// Nächstgrößeres Format – zwei Seiten ergeben einen Bogen dieser Größe.
#let next-paper = (a6: "a5", a5: "a4", a4: "a3")

/// Zählt die ausdrücklichen Seitenumbrüche in einem Inhaltsbaum.
///
/// `two-up` schätzt die Spaltenzahl aus der gemessenen Höhe. Ein `pagebreak()`
/// ist höhenlos und schiebt den Inhalt trotzdem eine Spalte weiter; jeder
/// Umbruch zählt darum als eine zusätzliche Spalte. Umbrüche in
/// `context`-Blöcken bleiben unsichtbar; dagegen sichert die Kontrolle nach der
/// Sonde ab.
///
/// - body (any): Inhalt
/// -> int
#let count-pagebreaks(body) = {
  if type(body) != content { return 0 }
  if body.func() == pagebreak { return 1 }
  let fields = body.fields()
  let total = 0
  for name in ("children", "child", "body") {
    if name in fields {
      let value = fields.at(name)
      total += if type(value) == array {
        value.map(count-pagebreaks).sum(default: 0)
      } else {
        count-pagebreaks(value)
      }
    }
  }
  total
}

/// Löst die margin-Angabe einer Seite zu allen vier Rändern auf. Im
/// `two-up`-Rahmen gibt es keine Bindung, daher gilt `inside` wie `left` und
/// `outside` wie `right`.
///
/// - margin (length, dictionary): Angabe wie bei `set page(margin: …)`
/// -> dictionary
#let resolve-margin(margin) = {
  if type(margin) != dictionary { return (left: margin, right: margin, top: margin, bottom: margin) }
  let rest = margin.at("rest", default: 0cm)
  let x = margin.at("x", default: rest)
  let y = margin.at("y", default: rest)
  (
    left: margin.at("left", default: margin.at("inside", default: x)),
    right: margin.at("right", default: margin.at("outside", default: x)),
    top: margin.at("top", default: y),
    bottom: margin.at("bottom", default: y),
  )
}

// ----------------------------------------------------------------------------
// Fächer
// ----------------------------------------------------------------------------

/// Fachfarben nach Kürzel. Unbekannte Fächer bekommen das Mathe-Blau.
#let subject-accents = (
  MA: rgb("#2f6fb5"),
  PH: rgb("#d4572a"),
  IF: rgb("#13866f"),
  CH: rgb("#8b3fa3"),
  BI: rgb("#3f8a2c"),
  NW: rgb("#0e7f8c"),
  DE: rgb("#c0392b"),
  EN: rgb("#b5176d"),
  KLS: rgb("#5b6b7f"),
)

/// Fachnamen nach Kürzel, für die Zeile „Fach · Klasse" über dem Titel.
#let subject-names = (
  MA: "Mathematik",
  PH: "Physik",
  IF: "Informatik",
  CH: "Chemie",
  BI: "Biologie",
  NW: "Naturwissenschaften",
  DE: "Deutsch",
  EN: "Englisch",
  KLS: "Klassenleitung",
)

/// Zerlegt ein Klassenkürzel wie `"MA-05"`, `"PH-7"` oder `"IF-11"`.
///
/// - class (str, content, none): Klassenkürzel
/// -> dictionary
#let parse-class(class) = {
  let class-text = plain-text(class)
  // Nur Großbuchstaben: "if3" ist ein Kurs, kein Jahrgang 3.
  let found = if class-text == none { none } else { class-text.match(regex("^([A-Z]{2,3})-?0*(\d+)")) }
  if found == none { (subject: none, name: none, year: none) } else {
    let subject = upper(found.captures.at(0))
    (subject: subject, name: subject-names.at(subject, default: none), year: int(found.captures.at(1)))
  }
}

/// „Mathematik · Klasse 5" – die Zeile über dem Titel; `none` bei unbekanntem Fach.
///
/// - class (str, content, none): Klassenkürzel
/// -> str, none
#let subject-line(class) = {
  let parsed = parse-class(class)
  if parsed.name == none { none } else {
    let year = parsed.year
    if year < 5 or year > 13 { parsed.name } else {
      parsed.name + " · " + (if year >= 11 { "Jahrgang " } else { "Klasse " }) + str(year)
    }
  }
}

/// Fachfarbe zum Klassenkürzel; unbekanntes Fach bekommt `subject-accents.MA`.
///
/// - class (str, content, none): Klassenkürzel
/// -> color
#let class-accent(class) = {
  let subject = parse-class(class).subject
  if subject == none { subject-accents.MA } else { subject-accents.at(subject, default: subject-accents.MA) }
}

// ----------------------------------------------------------------------------
// Kästen
// ----------------------------------------------------------------------------

#let palette = (
  green: rgb("#2b9348"),
  yellow: rgb("#a36a00"),
  orange: rgb("#e3752a"),
  red: rgb("#c62e3a"),
  violet: rgb("#6c4fb0"),
  teal: rgb("#0e8a8a"),
)

// Kastenart → (FontAwesome-Name, Farbe); `auto` = Akzentfarbe des Blatts.
#let callout-style-table = (
  info: ("circle-info", auto),
  memo: ("thumbtack", auto),
  abstract: ("align-left", auto),
  conclusion: ("flag-checkered", auto),
  goal: ("bullseye", auto),
  notify: ("bell", auto),
  tip: ("lightbulb", palette.yellow),
  success: ("circle-check", palette.green),
  idea: ("lightbulb", palette.yellow),
  example: ("pen-to-square", palette.violet),
  question: ("circle-question", palette.orange),
  warning: ("triangle-exclamation", palette.orange),
  danger: ("bolt", palette.red),
  error: ("circle-xmark", palette.red),
  experiment: ("flask", palette.teal),
)

// Deutsche Standardtitel (Ausgabe), in der Reihenfolge der Exporte.
#let callout-titles = (
  abstract: "Einführung",
  info: "Info",
  question: "Frage",
  memo: "Merke",
  conclusion: "Zusammenfassung",
  tip: "Tipp",
  success: "Erledigt",
  warning: "Achtung",
  error: "Fehler",
  example: "Beispiel",
  goal: "Ziel",
  idea: "Idee",
  experiment: "Experiment",
  notify: "Mitteilung",
  danger: "Gefahr",
)

#let callout-kinds = callout-titles.keys()

/// Symbol und Farbe einer Kastenart, für eigene Themes (Hook `callout`).
///
/// ```typ
/// callout: (kind: "info", title: none, accent: auto, breakable: false, width: auto, body) => {
///   let style = callout-style(kind, worksheet-accent: blue, accent: accent)
///   block(stroke: (left: 2pt + style.accent), inset: 8pt, breakable: breakable, body)
/// }
/// ```
///
/// - kind (str): Kastenart, der Name der Funktion: `"info"`, `"memo"`, `"tip"`, `"warning"` …
/// - worksheet-accent (auto, color): Akzentfarbe des Blatts; `auto` = `subject-accents.MA`
/// - accent (auto, color): eigene Farbe dieses Kastens; `auto` = Farbe der Kastenart, bei Arten ohne eigene
///   Farbe der Blattakzent
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> dictionary
#let callout-style(kind, worksheet-accent: auto, accent: auto, ..deprecated) = {
  check-positional(
    package-name,
    "callout-style",
    (none,) + deprecated.pos(),
    max: 1,
    hint: "nur die Kastenart steht ohne Namen; den Blattakzent als `worksheet-accent:` schreiben",
  )
  check-named(
    package-name,
    "callout-style",
    deprecated,
    renamed: (farbe: "accent", akzent: "worksheet-accent", art: "kind"),
    allowed: ("worksheet-accent", "accent"),
  )
  check-value(package-name, "callout-style", "kind", kind, callout-kinds)
  check-type(package-name, "callout-style", "worksheet-accent", worksheet-accent, (auto, color))
  check-type(package-name, "callout-style", "accent", accent, (auto, color))
  let (icon-name, kind-accent) = callout-style-table.at(kind)
  let sheet = if worksheet-accent == auto { subject-accents.MA } else { worksheet-accent }
  (
    icon-name: icon-name,
    accent: if accent != auto { accent } else if kind-accent == auto { sheet } else { kind-accent },
  )
}

/// Der gentle-clues-Kasten einer Art (klassische Darstellung).
///
/// - kind (str): Kastenart
/// -> function
#let callout-classic(kind) = {
  // Import im Rumpf: Die 15 Kastennamen von gentle-clues sollen nicht über
  // `internal` sichtbar sein.
  import "@preview/gentle-clues:1.2.0" as clues
  dictionary(clues).at(kind)
}

/// Setzt einen Kasten: mit dem Hook `callout` des Themes, sonst als
/// gentle-clues-Kasten wie bis 0.3.x.
///
/// - kind (str): Kastenart, zugleich Funktionsname für Meldungen
/// - title (auto, content, str, none): Titel; `auto` = deutscher Standardtitel, `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite
/// - deprecated (arguments): Sink der aufrufenden Funktion
/// - body (content): Inhalt
/// -> content
#let callout(kind, title: auto, accent: auto, breakable: false, width: auto, deprecated: arguments(), body) = {
  let given = deprecated.named()
  if title != auto { given.insert("title", title) }
  if accent != auto { given.insert("accent", accent) }
  if deprecated.pos().len() > 0 {
    fail(
      kind,
      str(deprecated.pos().len() + 1)
        + " Inhaltsargumente, erlaubt ist eines – den Titel als `title: [...]` schreiben",
    )
  }
  if given.at("headless", default: none) == true {
    fail(kind, "`headless: true` heißt jetzt `title: none`")
  }
  check-named(
    package-name,
    kind,
    given,
    renamed: (accent-color: "accent"),
    removed: (
      headless: "die Titelzeile ist die Vorgabe; ohne Titelzeile `title: none` schreiben",
      icon: "das Symbol bestimmt das Theme",
      header-color: "die Farben bestimmt das Theme; eine Farbe für den ganzen Kasten setzt `accent`",
      border-color: "die Farben bestimmt das Theme; eine Farbe für den ganzen Kasten setzt `accent`",
      body-color: "die Farben bestimmt das Theme; eine Farbe für den ganzen Kasten setzt `accent`",
    ),
    allowed: ("title", "accent", "breakable", "width"),
  )
  check-not-empty(package-name, kind, "title", title, "keine Titelzeile")
  check-type(package-name, kind, "title", title, (auto, content, str, none), example: "[Merke]")
  check-type(package-name, kind, "accent", accent, (auto, color), example: "red")
  check-type(package-name, kind, "breakable", breakable, bool)
  if type(width) not in (type(auto), length, ratio, relative, fraction) {
    check-type(package-name, kind, "width", width, (auto, relative), example: "8cm")
  }
  context {
    let hook = aufgaben.internal.theme-hook("callout")
    if hook == none {
      // Nur weitergeben, was gesetzt ist: sonst gelten die Vorgaben von
      // gentle-clues (auch eine dokumentweite Einstellung) nicht mehr.
      let named = (:)
      if title == none { named.insert("headless", true) } else if title != auto { named.insert("title", title) }
      if accent != auto { named.insert("accent-color", accent) }
      if breakable { named.insert("breakable", true) }
      if width != auto { named.insert("width", width) }
      callout-classic(kind)(..named, body)
    } else {
      hook(
        kind: kind,
        title: if title == auto { callout-titles.at(kind) } else { title },
        accent: accent,
        breakable: breakable,
        width: width,
        body,
      )
    }
  }
}

// ----------------------------------------------------------------------------
// Bausteine der eingebauten Themes
// ----------------------------------------------------------------------------

/// Seitenzahl in der äußeren Ecke (bei einseitigem Druck immer rechts).
///
/// - duplex (bool): beidseitiger Druck
/// - format (function): `page-number => content`
/// -> content
#let outside-aligned(duplex: true, format) = context {
  let page-number = counter(page).get().first()
  if duplex and calc.even(page-number) { align(left, format(page-number)) } else { align(right, format(page-number)) }
}

/// Linker und rechter Seitenrand der Seite aus dem margin-Dictionary.
///
/// - margin (length, dictionary): margin-Angabe der Seite
/// - page-number (int): Seitenzahl (entscheidet bei `inside`/`outside`)
/// -> array
#let side-margins(margin, page-number) = {
  if type(margin) != dictionary { return (margin, margin) }
  if "inside" in margin {
    let (inside, outside) = (margin.inside, margin.at("outside", default: margin.inside))
    if calc.odd(page-number) { (inside, outside) } else { (outside, inside) }
  } else {
    let x = margin.at("x", default: 1.75cm)
    (margin.at("left", default: x), margin.at("right", default: x))
  }
}

/// Gefüllte Marke (Kachel) – Grundform für Kürzel, Seitenzahl und Nummer. Die
/// Ziffern reichen von der Grundlinie bis zur Versalhöhe, so ist der
/// Innenabstand oben und unten gleich. Alle em-Maße beziehen sich auf `size`.
///
/// - fill (color, tiling): Füllung
/// - size (length): Schriftgröße
/// - radius (length): Eckenradius
/// - font (auto, str): Schrift
/// - weight (int): Schriftstärke
/// - width (auto, length): feste Breite
/// - inset (dictionary): Innenabstand
/// - stroke (none, stroke): Rahmen
/// - text-fill (color): Schriftfarbe
/// - body (content): Beschriftung
/// -> content
#let badge(
  fill: black,
  size: 1em,
  radius: 1.5pt,
  font: auto,
  weight: 700,
  width: auto,
  inset: (x: 0.5em, y: 0.4em),
  stroke: none,
  text-fill: white,
  body,
) = text(size, box(
  fill: fill,
  stroke: stroke,
  radius: radius,
  inset: inset,
  width: width,
  align(center, text(
    fill: text-fill,
    weight: weight,
    ..if font != auto { (font: font) },
    top-edge: "cap-height",
    bottom-edge: "baseline",
    body,
  )),
))

/// Harter, versetzter Schatten hinter einem Element mit natürlicher Größe.
///
/// - distance (length): Versatz des Schattens
/// - fill (color): Farbe des Schattens
/// - body (content): Element
/// -> content
#let shadow-box(distance: 2.5pt, fill: black, body) = context {
  let size = measure(body)
  box(width: size.width + distance, height: size.height + distance, baseline: distance, {
    place(top + left, dx: distance, dy: distance, rect(width: size.width, height: size.height, fill: fill, radius: 0pt))
    place(top + left, body)
  })
}

/// Dasselbe für einen Block über die volle Breite (nicht umbrechbar).
///
/// - distance (length): Versatz des Schattens
/// - fill (color): Farbe des Schattens
/// - body (content): Blockinhalt
/// -> content
#let shadow-block(distance: 4pt, fill: black, body) = layout(available => {
  let inner = block(width: available.width - distance, body)
  let size = measure(inner)
  block(width: available.width, height: size.height + distance, breakable: false, {
    place(top + left, dx: distance, dy: distance, rect(width: size.width, height: size.height, fill: fill))
    place(top + left, inner)
  })
})

/// Lösung mit Bezeichnung in der ersten Zeile (spart Platz im Lösungsblatt).
///
/// - title (content, none): Bezeichnung („Lösung a)")
/// - marker-style (function): `title => content`
/// - body (content): Lösung
/// -> content
#let solution-inline(title: none, marker-style: it => it, body) = {
  marker-style(title)
  h(0.6em)
  body
}

/// Kleiner QR-Code für die Kopfzeile (`copyright-url`).
///
/// - url (str): Adresse
/// - size (length): Kantenlänge
/// - fill (color): Farbe der dunklen Felder
/// -> content
#let copyright-code(url, size: 0.9em, fill: rgb("#828282")) = box(zebra-qrcode(
  url,
  width: size,
  fill: fill,
  background-fill: white.transparentize(100%),
))

/// Kopfzeile der klassischen Darstellung; dieselbe Signatur wie der
/// Theme-Hook `header`.
///
/// - title (content, str, none): Titel
/// - class (content, str, none): Klasse
/// - copyright-url (str, none): Adresse für den QR-Code
/// - font-size (auto, length): Titelgröße; `auto` = 16pt
/// -> content
#let default-header(title: none, class: none, copyright-url: none, font-size: auto) = {
  let size = if font-size == auto { 16pt } else { font-size }
  text(size, weight: "semibold")[#title]
  h(1fr)

  if copyright-url != none {
    copyright-code(copyright-url)
    h(0.5em)
  }

  text(
    size,
    weight: "semibold",
    fill: luma(130),
  )[#class]
  move(dy: -.4em, line(length: 100%, stroke: 0.5pt + luma(200)))
}

// ----------------------------------------------------------------------------
// Theme auflösen und prüfen
// ----------------------------------------------------------------------------

#let theme-keys = (
  "name",
  "font",
  "math-font",
  "font-size",
  "title-font-size",
  "margin",
  "header-top",
  "header-ascent",
  "footer-descent",
  "header",
  "footer",
  "background",
  "callout",
  "setup",
  ..aufgaben.internal.theme-hook-names,
)

#let theme-key-renames = (
  rand: "margin",
  kopf: "header",
  fuss: "footer",
  hintergrund: "background",
  kasten: "callout",
  ..aufgaben.internal.theme-hook-renames,
)

#let theme-key-removed = (
  schrift: "`font`, `math-font`, `font-size` und `title-font-size` stehen direkt im Theme",
)

/// Löst den Parameter `theme` auf: `auto` → klassisch (`none`), Name →
/// eingebautes Theme, Funktion → eigenes Theme, Dictionary → fertig. Prüft
/// die Schlüssel des Dictionary.
///
/// - theme (auto, str, dictionary, function): Wert des Kopfparameters
/// - accent (auto, color): Akzentfarbe; `auto` = Fachfarbe aus `class`
/// - class (str, content, none): Klassenkürzel
/// - package (str): Paketname für Meldungen
/// - function (str): Funktionsname für Meldungen
/// -> dictionary, none
#let resolve-theme(theme, accent: auto, class: none, package: package-name, function: "arbeitsblatt") = {
  // Import im Rumpf: themes.typ importiert diese Datei.
  import "themes.typ": themes
  if theme == auto { return none }
  if theme == none { check-fail(package, function, "`theme: none` – die Vorgabe ist `auto`") }
  if theme == "standard" { check-fail(package, function, "`theme: \"standard\"` heißt jetzt `theme: auto`") }
  check-type(package, function, "theme", theme, (auto, str, dictionary, std.function), example: "\"klar\"")
  let resolved-accent = if accent == auto { class-accent(class) } else { accent }
  let resolved = if type(theme) == str {
    check-value(package, function, "theme", theme, (auto, ..themes.keys()))
    (themes.at(theme))(accent: resolved-accent, class: class)
  } else if type(theme) == std.function {
    let result = theme(accent: resolved-accent, class: class)
    if type(result) != dictionary {
      check-fail(
        package,
        function,
        "die Theme-Funktion lieferte `" + repr(type(result)) + "` – sie muss ein Theme-Dictionary liefern, zum Beispiel `(accent: auto, class: none) => (font: \"Lato\")`",
      )
    }
    result
  } else {
    theme
  }
  check-named(
    package,
    function,
    resolved,
    renamed: theme-key-renames,
    removed: theme-key-removed,
    allowed: theme-keys,
    what: "Schlüssel",
  )
  let margin = resolved.at("margin", default: (:))
  check-type(package, function, "theme.margin", margin, dictionary, example: "(bottom: 1.8cm)")
  check-named(
    package,
    function,
    margin,
    renamed: (innen: "inside", aussen: "outside"),
    removed: (kopf-oben: "`header-top` steht direkt im Theme, nicht in `margin`"),
    allowed: ("top", "bottom", "inside", "outside"),
    what: "Schlüssel",
  )
  for name in ("header", "footer", "background", "callout", "setup", "task", "task-marker", "subtask", "solution", "solution-heading", "material-heading") {
    if name in resolved {
      check-type(package, function, "theme." + name, resolved.at(name), (std.function, none))
    }
  }
  resolved
}

// ----------------------------------------------------------------------------
// Kopfparameter
// ----------------------------------------------------------------------------

#let single-parameter-names = worksheet-parameters.pairs().filter(((name, entry)) => entry.only != "arbeitsblatt").map(pair => pair.first())

#let bundle-parameter-names = worksheet-parameters.pairs().filter(((name, entry)) => entry.only != "arbeitsblatt-einzeln").map(pair => pair.first())

#let worksheet-renames = (
  ..aufgaben.internal.option-renames,
  akzent: "accent",
  custom-header: "header",
  copyright: "copyright-url",
  zweifach: "two-up",
  varianten: "variants",
  vorschau-alle: "preview-variant",
  dateiname: "filename",
  fach: "subject",
  thema: "topic",
  jahrgang: "years",
  stufe: "stage",
  niveau: "level",
  typ: "kind",
  stichworte: "keywords",
  kerncurriculum: "curriculum",
  stand: "revision",
  header-ascent: "page-settings: (header-ascent: …)",
)

#let worksheet-removed = (
  header-font-size: "war seit 0.1.0 wirkungslos; Titelgröße: `title-font-size`",
  subtitle: "war wirkungslos; einen Untertitel hat nur `klassenarbeit`",
  erwartungen: "war wirkungslos; den Erwartungshorizont setzt `klassenarbeit` (`expectations`)",
  klausurboegen: "war wirkungslos; Klausurbögen setzt `klassenarbeit` (`answer-sheets`)",
)

// Auswahlen außerhalb des Options-Schemas: Name → (values:, renamed:).
#let worksheet-choices = (
  stage: (values: (none, "sek-1", "sek-2"), renamed: (sek1: "sek-1", sek2: "sek-2")),
  level: (
    values: (none, "introduction", "consolidation", "ea", "ga"),
    renamed: (einfuehrung: "introduction", vertiefung: "consolidation"),
  ),
  kind: (
    values: (none, "worksheet", "practice", "stations", "exam"),
    renamed: (arbeitsblatt: "worksheet", uebung: "practice", stationsarbeit: "stations", klausur: "exam"),
  ),
)

#let two-up-papers = ("a4", "a5", "a6")

/// Prüft Typen, Werte und Kombinationen eines Dictionary Kopfparameter → Wert.
/// Unbekannte Schlüssel werden übersprungen (die Namen prüft der Aufrufer mit
/// `check-named`).
///
/// - package (str): Paketname für Meldungen
/// - function (str): Funktionsname für Meldungen
/// - options (dictionary): Kopfparameter → Wert, beliebige Teilmenge
/// -> none
#let check-worksheet-options(package, function, options) = {
  for (name, value) in options {
    if name not in worksheet-parameters { continue }
    if name in aufgaben.internal.option-schema { continue } // prüft check-options unten
    let entry = worksheet-parameters.at(name)
    if name == "title" { check-not-empty(package, function, name, value, "kein Titel") }
    if name == "class" { check-not-empty(package, function, name, value, "keine Klasse") }
    if name in ("copyright-url", "filename", "subject", "topic", "revision") {
      check-not-empty(package, function, name, value, "keine Angabe")
    }
    if name == "theme" {
      if value == none { check-fail(package, function, "`theme: none` – die Vorgabe ist `auto`") }
      if value == "standard" { check-fail(package, function, "`theme: \"standard\"` heißt jetzt `theme: auto`") }
      check-type(package, function, name, value, entry.types, example: "\"klar\"")
      continue
    }
    if name == "variants" {
      check-type(package, function, name, value, entry.types, example: "(\"print\", \"solutions\")")
      continue
    }
    if name in worksheet-choices {
      let choice = worksheet-choices.at(name)
      check-value(package, function, name, value, choice.values, renamed: choice.renamed)
      continue
    }
    check-type(package, function, name, value, entry.types)
  }
  aufgaben.internal.check-options(package, function, options)

  let two-up = options.at("two-up", default: false)
  if two-up == true {
    if options.at("print", default: true) != true {
      check-fail(package, function, "`two-up: true` wirkt nur mit `print: true` – eines von beiden ändern")
    }
    let paper = options.at("paper", default: "a4")
    if paper not in two-up-papers {
      check-fail(
        package,
        function,
        "`two-up: true` geht nicht mit `paper: " + repr(paper) + "` – erlaubt: " + two-up-papers.map(name => "`" + repr(name) + "`").join(", "),
      )
    }
  }
}

// ----------------------------------------------------------------------------
// Metadaten für die Materialbibliothek (<ab-meta>, eingefroren)
// ----------------------------------------------------------------------------

#let meta-keys = (
  title: "titel",
  class: "klasse",
  subject: "fach",
  topic: "thema",
  years: "jahrgang",
  stage: "stufe",
  level: "niveau",
  kind: "typ",
  keywords: "stichworte",
  curriculum: "kerncurriculum",
  revision: "stand",
)

#let meta-values = (
  level: (introduction: "einfuehrung", consolidation: "vertiefung", ea: "ea", ga: "ga"),
  kind: (worksheet: "arbeitsblatt", practice: "uebung", stations: "stationsarbeit", exam: "klausur"),
)

/// Das Dictionary, das nach `<ab-meta>` geschrieben wird: deutsche Schlüssel,
/// deutsche Werte bei `niveau` und `typ`, `""` für fehlenden Titel und fehlende Klasse.
///
/// - options (dictionary): Kopfparameter → Wert
/// -> dictionary
#let meta-record(options) = {
  let record = (:)
  for (name, key) in meta-keys {
    let value = options.at(name)
    if name in ("title", "class") and value == none { value = "" }
    if name in meta-values and type(value) == str { value = meta-values.at(name).at(value, default: value) }
    record.insert(key, value)
  }
  record
}

// ----------------------------------------------------------------------------
// Fassungen (Varianten)
// ----------------------------------------------------------------------------

// Vordefinierte Fassungen und ihre abweichenden Kopfparameter.
#let variant-presets = (
  print: (print: true),
  digital: (print: false),
  solutions: (print: true, solutions: "only", workspaces: false),
  two-up: (print: true, two-up: true),
)

// Der Dateiname bleibt deutsch (eingefrorene Außenschnittstelle).
#let variant-suffixes = (
  print: "druck",
  digital: "digital",
  solutions: "loesung",
  two-up: "zweifach",
)

#let variant-renames = (druck: "print", loesung: "solutions", loesungen: "solutions", zweifach: "two-up")

/// Normalisiert `variants` und `variant-overrides` zu einem Array aus
/// (Name, Overrides)-Paaren und prüft Namen und Schlüssel.
///
/// - variants (auto, array): Namen der Fassungen
/// - variant-overrides (dictionary): Name → abweichende Kopfparameter
/// - package (str): Paketname für Meldungen
/// - function (str): Funktionsname für Meldungen
/// - allowed (array): erlaubte Schlüssel in den Overrides (ohne `path`)
/// -> array
#let resolve-variants(
  variants,
  variant-overrides,
  package: package-name,
  function: "arbeitsblatt",
  allowed: single-parameter-names.filter(name => name != "scope"),
) = {
  if type(variants) == dictionary {
    check-fail(
      package,
      function,
      "`variants` als Dictionary gibt es nicht mehr – die Namen als `variants: (\"print\", \"solutions\")` und die Abweichungen als `variant-overrides: (print: (…))` schreiben",
    )
  }
  if type(variants) == str {
    check-fail(package, function, "`variants` erwartet ein Array aus Namen, bekam `" + repr(variants) + "` (str) – zum Beispiel `" + {
      // Beispiel mit dem heutigen Namen der Fassung, sonst das feste Beispiel
      let name = variant-renames.at(variants, default: variants)
      if name in variant-presets or name in variant-overrides { "(" + repr(name) + ",)" } else { "(\"print\", \"solutions\")" }
    } + "`")
  }
  check-type(package, function, "variants", variants, (auto, array), example: "(\"print\", \"solutions\")")
  check-type(package, function, "variant-overrides", variant-overrides, dictionary, example: "(print: (points: \"all\"))")
  let names = if variants == auto { ("digital", "solutions") } else { variants }
  let known = (..variant-presets.keys(), ..variant-overrides.keys())
  for (name, overrides) in variant-overrides {
    if name not in variant-presets and name in variant-renames {
      check-fail(package, function, "`variant-overrides: (" + name + ": …)` heißt jetzt `variant-overrides: (" + variant-renames.at(name) + ": …)`")
    }
    check-type(package, function, "variant-overrides." + name, overrides, dictionary, example: "(points: \"all\")")
    check-named(
      package,
      function,
      overrides,
      renamed: (..worksheet-renames, datei: "path"),
      removed: worksheet-removed,
      allowed: (..allowed, "path"),
      what: "Schlüssel",
    )
    check-worksheet-options(package, function, overrides)
    if "path" in overrides { check-type(package, function, "variant-overrides." + name + ".path", overrides.path, str, example: "\"blatt.pdf\"") }
  }
  for name in names {
    check-type(package, function, "variants", name, str, example: "(\"print\", \"solutions\")")
    if name not in known and fold-name(name) not in variant-renames {
      check-fail(
        package,
        function,
        "`variants` nennt die Fassung `" + name + "`, die weder vordefiniert ist noch in `variant-overrides` steht – vordefiniert: " + variant-presets.keys().map(key => "`\"" + key + "\"`").join(", ") + "; eine eigene Fassung als `variant-overrides: (" + name + ": (…))` anlegen",
      )
    }
    check-value(package, function, "variants", name, known, renamed: variant-renames)
  }
  if variants != auto {
    for name in variant-overrides.keys() {
      if name not in names {
        check-fail(package, function, "`variant-overrides` nennt die Fassung `" + name + "`, die nicht in `variants` steht – `variants: (…, \"" + name + "\")` ergänzen oder den Eintrag entfernen")
      }
    }
  }
  names.map(name => (name, variant-overrides.at(name, default: (:))))
}

/// Ausgabepfad einer Fassung im Bündel: `[<filename>-]<Endung>.pdf`.
///
/// - name (str): Name der Fassung
/// - filename (str, none): Vorsatz
/// -> str
#let variant-path(name, filename) = {
  (if filename != none { filename + "-" } else { "" }) + variant-suffixes.at(name, default: name) + ".pdf"
}

/// Scope-Kennung einer Fassung im Bündel: `[<filename>-]<Name>`.
///
/// - name (str): Name der Fassung
/// - filename (str, none): Vorsatz
/// -> str
#let variant-scope(name, filename) = (if filename != none { filename + "-" } else { "" }) + name

/// Hat der Editor die Vorschau aller Fassungen angefordert? Gesteuert über den
/// System-Input `vorschau=alle` (VS Code: `"tinymist.preview.sysInputs":
/// { "vorschau": "alle" }`). Normale Compile-Läufe setzen ihn nicht.
///
/// -> bool
#let preview-all-requested() = sys.inputs.at("vorschau", default: none) == "alle"
