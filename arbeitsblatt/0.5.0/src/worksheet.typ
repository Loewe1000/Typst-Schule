// worksheet.typ – die Vorlagen `arbeitsblatt` und `arbeitsblatt-einzeln`
//
// Signaturen, Docstring-Zeilen der Parameter und die Dictionaries zwischen
// `// <erzeugt …>` und `// </erzeugt>` schreibt scripts/signaturen.py aus
// src/internal/parameters.typ. Nicht von Hand ändern.

#import "@preview/codly:1.3.0": codly, codly-init
#import "@preview/unify:0.8.1": add-unit
#import "@schule/aufgaben:0.5.0" as aufgaben
#import "@schule/aufgaben:0.5.0": aufgabe, reset-tasks, set-options, show-materials, show-solutions, teilaufgabe
#import "@schule/insert-a-word:0.5.0": reset-iaword
#import "internal/check.typ": check-named, check-positional, check-type, check-value
#import "internal.typ": (
  bundle-parameter-names, check-worksheet-options, count-pagebreaks, default-header, fail, meta-label, meta-record,
  next-paper, package-name, paper-sizes, preview-all-requested, resolve-margin, resolve-theme, resolve-variants,
  scope-end-label, scope-start-label, scope-state, single-parameter-names, started-state, two-up-end-label, two-up-top-label,
  variant-path, variant-presets, variant-scope, worksheet-parameters, worksheet-removed, worksheet-renames,
)

// Prüft den Sink einer Vorlage: Positionsargumente, alte und unbekannte Namen.
// `values` sind die deklarierten Parameter mit ihren Werten; was von der
// Vorgabe abweicht, geht mit in die Namensprüfung (Meldung „alt und neu
// zugleich").
#let check-head(function, deprecated, values, allowed) = {
  check-positional(
    package-name,
    function,
    deprecated,
    hint: "außer dem Inhalt alle Angaben benannt schreiben, zum Beispiel `title: [...]`",
  )
  let given = deprecated.named()
  if "custom-header" in given and given.at("custom-header") == none {
    fail(function, "`custom-header: none` gibt es nicht mehr – das Argument löschen (`header: none` hieße „kein Kopf\")")
  }
  if "vorschau-alle" in given and type(given.at("vorschau-alle")) == bool {
    fail(
      function,
      "`vorschau-alle: " + repr(given.at("vorschau-alle")) + "` heißt jetzt `preview-variant: " + (if given.at("vorschau-alle") { "auto" } else { "none" }) + "`",
    )
  }
  for (name, value) in values {
    if value != worksheet-parameters.at(name).default { given.insert(name, value) }
  }
  check-named(
    package-name,
    function,
    given,
    renamed: worksheet-renames.pairs().filter(((old, new)) => new in allowed or new.contains(":")).to-dict(),
    removed: worksheet-removed,
    allowed: allowed,
  )
}

// Setzt genau eine Fassung. `options` ist das vollständige Dictionary der
// Kopfparameter (ohne `scope` und ohne die Bündelparameter), `function` der
// Name der aufrufenden Vorlage für Meldungen.
#let render-worksheet(function, options, scope, body) = {
  check-worksheet-options(package-name, function, options)
  check-type(package-name, function, "scope", scope, (str, none))

  let title = options.title
  let class = options.class
  let paper = options.paper
  let print = options.print
  let duplex = options.duplex
  let landscape = options.landscape
  let two-up = options.two-up
  let page-settings = options.page-settings
  let copyright-url = options.copyright-url
  let custom-header = if options.header == auto { none } else { options.header }
  let has-header = options.header != none

  // Theme auflösen: `none` = klassische Darstellung wie bis 0.3.x. Ausdrücklich
  // gesetzte Schriftparameter haben Vorrang vor dem Theme.
  // Theme-Funktion und Theme-Kopf bekommen für „nicht gesetzt" wie bis 0.4.0
  // den leeren Text (leere Titelzeile, leere Klassenmarke) – sonst änderte sich
  // das Layout der Themes.
  let theme-title = if title == none { "" } else { title }
  let theme-class = if class == none { "" } else { class }
  let theme = resolve-theme(options.theme, accent: options.accent, class: theme-class, function: function)
  let themed(name, default) = if theme != none { theme.at(name, default: default) } else { default }
  let theme-header = if options.header == auto { themed("header", none) } else { none }
  let font = if options.font == auto { themed("font", "Myriad Pro") } else { options.font }
  let math-font = if options.math-font == auto { themed("math-font", "Fira Math") } else { options.math-font }
  let font-size = if options.font-size == auto { themed("font-size", 12pt) } else { options.font-size }
  let title-font-size = if options.title-font-size == auto { themed("title-font-size", 16pt) } else {
    options.title-font-size
  }
  let figure-font-size = if options.figure-font-size == auto { 9pt } else { options.figure-font-size }
  let as-list(value) = if type(value) == array { value } else { (value,) }
  font = (..as-list(font), "Fira Sans", "New Computer Modern Sans", "DejaVu Sans")
  math-font = (..as-list(math-font), "New Computer Modern Sans Math")

  // Abstand Kopf – Text: `page-settings`, dann Theme, dann die Vorgabe (20 %
  // ohne Theme-Kopf, 0,8 cm mit). Derselbe Wert gilt für die Randberechnung,
  // für `set page` und für `two-up`.
  let header-ascent = if "header-ascent" in page-settings { page-settings.at("header-ascent") } else {
    themed("header-ascent", if theme-header != none { 0.8cm } else { 20% })
  }

  set par(justify: true, leading: 0.65em, linebreaks: "optimized")

  add-unit("Watt hours", "Wh", "upright(\"Wh\")")

  set text(font-size, font: font, hyphenate: true, lang: "de")
  show math.equation: set text(font: math-font)

  show math.equation: it => {
    show regex("\d+\.\d+"): number => number.text.replace(".", ",")
    it
  }

  let records-state = aufgaben.internal.records-state
  let task-kind = aufgaben.internal.task-figure-kind
  let subtask-kind = aufgaben.internal.subtask-figure-kind
  let material-kind = aufgaben.internal.material-figure-kind

  // Kennung eines Materials: „M2-A" (Aufgabe 2, erstes Material).
  let material-marker(location) = {
    let task-number = aufgaben.internal.material-task-number-state.at(location)
    let material-number = aufgaben.internal.material-number-state.at(location)
    // Rückfall, falls das Material nicht in einem Materialteil steht
    if task-number == 0 {
      task-number = aufgaben.internal.task-counter.get().at(0)
      material-number = counter(figure.where(kind: material-kind)).at(location).first()
    }
    "M" + str(task-number) + "-" + numbering("A", material-number)
  }

  show ref: it => context {
    // Im Bündel existiert dasselbe Label in jeder Fassung. `it.element`
    // liefert dann `none`, daher innerhalb der Fassung zwischen den
    // Scope-Marken auflösen. Der Scope kommt aus dem State, damit auch
    // verschachtelte Vorlagen-Aufrufe ihn erben.
    let scope = scope-state.get()
    let element = if scope == none {
      it.element
    } else {
      let candidates = query(
        selector(it.target)
          .after(scope-start-label(scope), inclusive: false)
          .before(scope-end-label(scope), inclusive: false),
      )
      if candidates.len() == 0 {
        // Das Ziel gibt es in dieser Fassung nicht (das Material wird mit
        // `solutions: "only"` nie gezeigt). Im ganzen Bündel suchen: Da alle
        // Fassungen denselben Inhalt setzen, stimmt die Nummer des ersten
        // Treffers.
        candidates = query(selector(it.target))
      }
      if candidates.len() > 0 { candidates.first() } else { none }
    }
    if element != none and element.func() == figure and element.kind == material-kind {
      link(element.location(), material-marker(element.location()))
    } else if element != none and element.func() == figure and element.kind == subtask-kind {
      link(element.location(), aufgaben.internal.subtask-number-text(
        counter(figure.where(kind: task-kind)).at(element.location()).first(),
        counter(figure.where(kind: subtask-kind)).at(element.location()).first(),
      ))
    } else if element != none and element.func() == figure and (element.kind == image or element.kind == table) {
      // Wie in der Beschriftung: Abbildungen „A", Tabellen „T".
      let prefix = if element.kind == table { "T" } else { "A" }
      if scope == none {
        prefix + it
      } else {
        link(element.location(), prefix + str(counter(figure.where(kind: element.kind)).at(element.location()).first()))
      }
    } else if scope != none and element != none and element.func() == heading {
      // Verweis auf eine Überschrift innerhalb der Fassung
      link(element.location(), if element.numbering != none {
        numbering(element.numbering, ..counter(heading).at(element.location()))
      } else {
        element.body
      })
    } else if scope != none and query(selector(it.target)).len() > 1 {
      // Bündel mit mehrfachem Label und unbekanntem Zieltyp: Der gewöhnliche
      // Verweis schlüge fehl, daher bestmöglicher Ersatz als Link auf den
      // Treffer in dieser Fassung.
      if element != none and element.func() == figure {
        link(element.location(), str(counter(figure.where(kind: element.kind)).at(element.location()).first()))
      } else if element != none {
        link(element.location(), text(red)[#it.target])
      } else {
        text(red)[#it.target]
      }
    } else {
      // alle anderen Verweise wie gewohnt
      it
    }
  }

  context {
    let header-height = measure(custom-header, width: page.width).height

    // Kopfzeile als Wert – sie wird von der Seitenkopfzeile und (mit
    // `two-up`) von jedem Rahmen gebraucht.
    let page-header = if not has-header {
      none
    } else if theme-header != none {
      {
        // Titel im Theme-Kopf nicht trennen
        set text(hyphenate: false)
        theme-header(title: theme-title, class: theme-class, copyright-url: copyright-url, font-size: title-font-size)
      }
    } else if custom-header == none {
      default-header(title: title, class: class, copyright-url: copyright-url, font-size: title-font-size)
    } else {
      custom-header
    }

    // Ränder: zuerst `page-settings.margin`, sonst die Ränder der Vorlage
    let page-margin = if "margin" in page-settings.keys() {
      // `top` kann auch über `y` oder `rest` gesetzt sein.
      let top = if type(page-settings.margin) == dictionary {
        let given = page-settings.margin
        given.at("top", default: given.at("y", default: given.at("rest", default: 0cm)))
      } else {
        page-settings.margin
      }
      let values = page-settings.margin
      let _ = if type(values) == dictionary {
        values.insert("top", top + header-height)
      }
      values
    } else {
      // Ränder nach print/landscape/duplex. Themes können den oberen und
      // unteren Rand vorgeben (größerer Kopf, Fußzeile mit Seitenzahl).
      let theme-margin = themed("margin", (:))
      let top = theme-margin.at("top", default: if print { 2.3cm } else { 2.2cm })
      // Seitenränder: innen (Heftrand) und außen; ein Theme kann den äußeren
      // Rand vergrößern, zum Beispiel für eine Randleiste. Ohne Druck und im
      // Querformat gilt 1,75 cm, außen mindestens so viel wie gewünscht.
      let inside = theme-margin.at("inside", default: 2.25cm)
      let outside = theme-margin.at("outside", default: 1.25cm)
      let right = calc.max(1.75cm, outside)
      // Theme-Kopf: Rand aus der gemessenen Kopfhöhe, damit auch zweizeilige
      // Titel nicht oben aus der Seite ragen. header-top = Abstand Blattkante –
      // Kopf, header-ascent = Abstand Kopf – Text.
      if theme-header != none {
        let sizes = paper-sizes.at(paper, default: paper-sizes.a4)
        let side-margin = if print and not landscape { inside + outside } else { 1.75cm + right }
        let width = (if landscape { sizes.at(1) } else { sizes.at(0) }) - side-margin
        let head-height = measure(block(width: width, page-header)).height
        let ascent = if type(header-ascent) == length { header-ascent } else { themed("header-ascent", 0.8cm) }
        top = themed("header-top", 1.2cm) + head-height + ascent
      }
      let bottom = theme-margin.at("bottom", default: 1cm)
      if print {
        if landscape {
          (top: top + header-height, left: 1.75cm, right: right, bottom: bottom)
        } else {
          if duplex {
            (top: top + header-height, inside: inside, outside: outside, bottom: bottom)
          } else {
            (top: top + header-height, left: inside, right: outside, bottom: bottom)
          }
        }
      } else {
        (top: top + header-height, left: 1.75cm, right: right, bottom: bottom)
      }
    }

    // Seiteneinrichtung: mit `two-up` der nächstgrößere Bogen ohne Ränder –
    // Kopfzeile und Ränder zeichnet dann jeder Rahmen selbst.
    let page-arguments = if two-up {
      (
        paper: next-paper.at(paper),
        flipped: not landscape,
        margin: 0pt,
        header: none,
        footer: none,
      )
    } else {
      (
        paper: paper,
        ..if not print {
          if landscape {
            (width: auto)
          } else {
            (height: auto)
          }
        },
        flipped: landscape,
        header-ascent: header-ascent,
        margin: page-margin,
        header: page-header,
        ..if themed("footer", none) != none and print {
          (footer: (theme.footer)(duplex: duplex), footer-descent: themed("footer-descent", 30%))
        },
        ..if themed("background", none) != none {
          let top = if type(page-margin) == dictionary { page-margin.at("top", default: 2.3cm) } else { page-margin }
          (background: (theme.background)(print: print, margin: page-margin, header-top: top))
        },
        // alle anderen page-settings
        ..{
          let remaining = (:)
          for (key, value) in page-settings.pairs() {
            if key not in ("margin", "header-ascent") {
              remaining.insert(key, value)
            }
          }
          remaining
        },
      )
    }
    set page(..page-arguments)

    set-options(
      solutions: options.solutions,
      solutions-pagebreak: options.solutions-pagebreak,
      materials: options.materials,
      materials-pagebreak: options.materials-pagebreak,
      points: options.points,
      points-total: options.points-total,
      points-position: options.points-position,
      points-format: options.points-format,
      workspaces: options.workspaces,
      shortcodes: options.shortcodes,
      subtask-numbering: options.subtask-numbering,
    )

    started-state.update(true)
    aufgaben.internal.print-state.update(_ => print)

    // Metadaten für `typst query '<ab-meta>' --field value`. Immer
    // ausgegeben, auch wenn nichts gesetzt ist – so lassen sich Blätter ohne
    // Angaben maschinell finden. `metadata` ist unsichtbar und ändert das
    // Layout nicht.
    [#metadata(meta-record(options)) #meta-label]

    // Fassung im Bündel: Anfang markieren. States und Counter sind im Bündel
    // global, darum werden sie unten zurückgesetzt.
    if scope != none {
      scope-state.update(scope)
      [#metadata("worksheet-start") #scope-start-label(scope)]
    }

    // Inhalt als Wert: im Normalfall einmal ausgegeben, mit `two-up` je
    // Rahmen erneut gesetzt. `reset-tasks()` steht bewusst innerhalb, damit
    // jede Kopie wieder bei Aufgabe 1 beginnt.
    let content-flow = {
      reset-tasks()
      aufgaben.internal.theme-state.update(_ => theme)
      show: if themed("setup", none) != none { theme.setup } else { it => it }
      // Lückentexte je Fassung wie in einem einzelnen Dokument mischen.
      reset-iaword()
      set figure(numbering: "1", supplement: none)
      // Bildschirmfassung mit automatischer Seitenhöhe: Typst 0.15 lässt die
      // Blöcke um ein v(1fr) überlappen, statt den Abstand wegfallen zu lassen.
      // Blätter für den Druck nutzen v(1fr) oft – am Bildschirm wird daraus ein
      // kleiner Abstand.
      show v: it => if not print and not landscape and not two-up and type(it.amount) == fraction {
        v(0.65em, weak: true)
      } else { it }

      show figure.where(kind: image).or(figure.where(kind: table)): it => {
        let kind-name = repr(it.kind)
        let supplement = ("image": "A", "table": "T").at(kind-name, default: "M")
        let number = counter(figure.where(kind: it.kind)).get().first()
        it.body
        context {
          if it.caption != none {
            align(center)[
              #v(5pt)
              #align(left, grid(
                columns: 2,
                column-gutter: 0.5em,
                text(size: figure-font-size, grid(
                  columns: 2,
                  align: top,
                  column-gutter: 0.25em,
                  [*#supplement#number:*], it.caption,
                )),
              ))
            ]
          }
        }
      }

      show figure.where(kind: material-kind): it => {
        context {
          let marker = material-marker(it.location())

          align(center)[
            #it.body
            #v(5pt)
            #align(left, grid(
              columns: 2,
              column-gutter: 0.5em,
              text(size: figure-font-size, strong(marker) + ":"), text(size: figure-font-size, it.caption),
            ))
          ]
        }
      }

      show figure.where(kind: subtask-kind): it => align(
        left,
        box(width: 100%, [
          #it.body
        ]),
      )

      show: codly-init.with()
      codly(display-name: false)
      set raw(syntaxes: "processing.sublime-syntax")

      // Kurzschreibweise: Die Option steht im State, `set-options(shortcodes: …)`
      // wirkt also auch mitten im Dokument.
      let current-shortcodes() = if started-state.get() {
        aufgaben.internal.options-state.get().shortcodes
      } else {
        options.shortcodes
      }
      show heading.where(level: 1): it => context {
        if current-shortcodes() in ("all", "tasks") {
          set text(font-size, weight: 700)
          aufgabe(title: it.body, large: true)[]
        } else { block(below: 0.75em, it) }
      }
      show enum.item: it => context {
        if (
          current-shortcodes() in ("all", "subtasks")
            and not aufgaben.internal.in-solution-state.get()
        ) {
          teilaufgabe(it.body)
        } else {
          it
        }
      }

      body

      // "only": restliche Lösungen ausgeben (die vorherigen erschienen jeweils
      // beim Beginn der nächsten Aufgabe).
      context if options.solutions == "only" {
        show-solutions(select: "pending")
      }

      // Material am Dokumentende
      context if options.materials == "at-end" and records-state.get().len() > 0 {
        show-materials()
      }
      // Lösungen am Dokumentende
      context if options.solutions == "at-end" and records-state.get().len() > 0 {
        show-solutions()
      }
    }

    // Ausgabe: als gewöhnlicher Seitenfluss – oder mit `two-up` jede Seite
    // zweimal auf einem Bogen der nächsten Größe.
    if not two-up {
      content-flow
    } else {
      let sizes = paper-sizes.at(paper)
      let (sheet-width, sheet-height) = if landscape { (sizes.at(1), sizes.at(0)) } else { sizes }
      let stacked = sheet-width > sheet-height
      let margin = resolve-margin(page-margin)
      let inner-width = sheet-width - margin.left - margin.right
      let inner-height = sheet-height - margin.top - margin.bottom
      let gap = 20mm

      // Die Kopfzeile sitzt im oberen Rand, genau so weit über dem
      // Textbereich, wie `header-ascent` es auf einer echten Seite vorgibt.
      let head-height = measure(page-header, width: inner-width).height
      let head-dy = (
        margin.top - (if type(header-ascent) == ratio { header-ascent * margin.top } else { header-ascent }) - head-height
      )

      // Ausdrückliche Seitenumbrüche sind in Containern verboten – als
      // Spaltenumbrüche wirken sie hier aber genau richtig, denn eine Spalte
      // ist eine Seite. Das deckt `page(..)` ohne Argumente mit ab: Das ist
      // intern nichts anderes als zwei schwache Seitenumbrüche um den Inhalt.
      let column-flow = {
        show pagebreak: it => colbreak(weak: it.at("weak", default: false))
        content-flow
      }

      // Spalten in den Textmaßen der Seite brechen zeilengenau wie echte
      // Seiten, also entspricht jede Spalte einer Seite. Wie viele es sind,
      // verrät eine unsichtbare Sonde mit Reserve: In welcher Spalte endet der
      // Inhalt?
      let column-limit = (
        calc.ceil(measure(block(width: inner-width, column-flow)).height / inner-height)
          + count-pagebreaks(column-flow)
          + 2
      )
      let probe = place(
        top + left,
        box(width: 0pt, height: 0pt, clip: true, block(
          width: column-limit * inner-width + (column-limit - 1) * gap,
          height: inner-height,
          {
            // Bezug auf die Oberkante der Spalten. `place` steht außerhalb
            // des Flusses und lässt die erste Spalte darum leer – ein
            // führender schwacher Umbruch wird weiterhin verschluckt.
            place(top + left, [#metadata(none)#two-up-top-label])
            columns(column-limit, gutter: gap, {
              column-flow
              [#metadata(none)#two-up-end-label]
            })
          },
        )),
      )

      context {
        let end-marks = query(two-up-end-label)
        let top-marks = query(two-up-top-label)
        let end = if end-marks.len() > 0 { end-marks.last().location().position() } else { none }
        let last-column = if end == none { 1 } else { calc.floor(end.x / (inner-width + gap)) + 1 }

        // Die Sonde hat Reserve. Endet der Inhalt trotzdem in ihrer letzten
        // Spalte, ist er dort angeschlagen und der Rest fiele ohne Meldung
        // weg – lieber abbrechen als Material verlieren. Die Prüfung steht
        // bewusst vor der Leerspalten-Korrektur: Sonst könnte deren Abzug
        // einen abgeschnittenen Inhalt unter die Schwelle drücken.
        if last-column >= column-limit {
          fail(
            function,
            "Inhalt zu lang für `two-up` (mehr als "
              + str(column-limit)
              + " Seiten; Seitenumbrüche in einem `context`-Block lassen sich vorab nicht zählen) – einen solchen Umbruch nach außen ziehen, das Dokument teilen oder `two-up: false` setzen",
          )
        }

        // Ein Seitenumbruch am Ende des Inhalts – etwa der, den `page(..)`
        // hinter seinem Inhalt mitschickt – schiebt die Endmarke in eine
        // frische Spalte. Im Seitenfluss verwirft Typst so einen Umbruch,
        // hier bliebe sonst ein leerer Bogen übrig. Erkennbar ist der Fall
        // daran, dass die Marke ganz oben in ihrer Spalte sitzt, also nichts
        // vor ihr steht.
        let column-count = if (
          end != none
            and last-column > 1
            and top-marks.len() > 0
            and end.y - top-marks.last().location().position().y < 1pt
        ) { last-column - 1 } else { last-column }

        let column-block = block(
          width: column-count * inner-width + (column-count - 1) * gap,
          height: inner-height,
          columns(column-count, gutter: gap, column-flow),
        )

        // Ein Rahmen: Kopfzeile plus das Fenster auf Spalte k.
        //
        // Das Fenster reicht über den Textbereich hinaus bis an die
        // Seitenkanten: Unterlängen und `place(bottom: ..)` ragen auf einer
        // echten Seite in den Rand, und ein Schnitt an der Textkante würde
        // sie kappen. Nach unten ist das gefahrlos, dort liegt nichts mehr.
        // Zur Seite reicht es höchstens bis zur Stegmitte, damit die
        // Nachbarspalte nicht hereinlugt. Oben bleibt es an der Textkante,
        // denn darüber sitzt die Kopfzeile.
        let overhang-left = calc.min(margin.left, gap / 2)
        let overhang-right = calc.min(margin.right, gap / 2)
        let frame(index) = block(width: sheet-width, height: sheet-height, {
          place(top + left, dx: margin.left, dy: head-dy, box(width: inner-width, page-header))
          place(
            top + left,
            dx: margin.left - overhang-left,
            dy: margin.top,
            box(
              width: inner-width + overhang-left + overhang-right,
              height: inner-height + margin.bottom,
              clip: true,
              place(
                top + left,
                dx: overhang-left - index * (inner-width + gap),
                column-block,
              ),
            ),
          )
        })

        // Bogenmaße selbst rechnen: `page.width` liefert die Breite ohne
        // Drehung und übergeht `flipped`.
        let target-size = paper-sizes.at(next-paper.at(paper))
        let (paper-width, paper-height) = if landscape { target-size } else { (target-size.at(1), target-size.at(0)) }
        let offset-x = (paper-width - if stacked { sheet-width } else { 2 * sheet-width }) / 2
        let offset-y = (paper-height - if stacked { 2 * sheet-height } else { sheet-height }) / 2

        for index in range(column-count) {
          place(top + left, dx: offset-x, dy: offset-y, frame(index))
          place(
            top + left,
            dx: offset-x + if stacked { 0pt } else { sheet-width },
            dy: offset-y + if stacked { sheet-height } else { 0pt },
            frame(index),
          )
          // Schnittlinie zwischen den beiden Kopien
          place(
            top + left,
            dx: if stacked { 0pt } else { offset-x + sheet-width },
            dy: if stacked { offset-y + sheet-height } else { 0pt },
            line(
              length: if stacked { paper-width } else { paper-height },
              angle: if stacked { 0deg } else { 90deg },
              stroke: (paint: luma(150), thickness: 0.4pt, dash: "dashed"),
            ),
          )
          if index + 1 < column-count { pagebreak() }
        }
      }

      // Sonde bewusst zuletzt: So zeigen Verweise auf die sichtbaren Kopien
      // und nicht in die unsichtbare Messfassung.
      probe
    }

    // Fassung im Bündel: Ende markieren
    if scope != none {
      [#metadata("worksheet-end") #scope-end-label(scope)]
    }
  }
}

/// Setzt genau ein Arbeitsblatt, also eine einzelne Fassung.
///
/// Gewöhnlich schreibt man `#show: arbeitsblatt.with(…)`; `arbeitsblatt` ruft
/// diese Funktion je Fassung auf. `arbeitsblatt-einzeln` ist öffentlich, damit
/// aufbauende Vorlagen (`klassenarbeit`) in ihren eigenen Bündel-Dokumenten
/// eine einzelne Fassung setzen können. Die Parameter sind die von
/// `arbeitsblatt` ohne `variants`, `variant-overrides`, `preview-variant` und
/// `filename`, dazu `scope`.
///
/// ```typ
/// #show: arbeitsblatt-einzeln.with(title: [Brüche], class: "MA-06", print: true)
/// ```
///
/// - title (str, content, none): Titel des Blatts in der Kopfzeile; `none` = kein Titel
/// - class (str, content, none): Klasse oder Kurs, rechts in der Kopfzeile; ein Kürzel wie `"MA-05"` bestimmt mit einem Theme Fachfarbe und Fachzeile
/// - header (auto, content, none): eigene Kopfzeile; `auto` = Kopf der Vorlage oder des Themes, `none` = kein Kopf
/// - copyright-url (str, none): Adresse für den kleinen QR-Code in der Kopfzeile (Lizenz- oder Quellenangabe)
/// - paper (str): Papierformat wie bei `page`; mit `two-up: true` nur `"a4"`, `"a5"`, `"a6"`
/// - landscape (bool): Querformat
/// - print (bool): Druckfassung: feste Seitenhöhe und Heftrand; ohne sie eine endlose Bildschirmseite
/// - duplex (bool): wechselnde Ränder für beidseitigen Druck (wirkt mit `print: true`)
/// - two-up (bool): jede Seite zweimal auf einen Bogen der nächsten Größe (Kopiervorlage zum Zerschneiden); verlangt `print: true`
/// - page-settings (dictionary): weitere Argumente für `set page`, zum Beispiel `margin`, `columns`, `header-ascent`
/// - theme (auto, str, dictionary, function): Gestaltung: `auto` = klassisch, ein Name aus `themes` (`"klar"`, `"atlas"`, `"skizze"`, `"labor"`, `"kontur"`, `"leiste"`, `"riso"`, `"bauhaus"`), ein Theme-Dictionary oder eine Funktion `(accent: auto, class: none) => dictionary`
/// - accent (auto, color): Akzentfarbe eines Themes; `auto` = Fachfarbe aus dem Klassenkürzel
/// - font (auto, str, array): Textschrift; `auto` = Schrift des Themes, sonst `"Myriad Pro"`
/// - math-font (auto, str, array): Formelschrift; `auto` = Schrift des Themes, sonst `"Fira Math"`
/// - font-size (auto, length): Grundschriftgröße; `auto` = Größe des Themes, sonst `12pt`
/// - title-font-size (auto, length): Größe des Titels in der Kopfzeile; `auto` = Größe des Themes, sonst `16pt`
/// - figure-font-size (auto, length): Schriftgröße der Bildunterschriften; `auto` = `9pt`
/// - solutions (str, none): Lösungen: `none`, `"in-place"` (nach jeder Teilaufgabe), `"after-task"` (nach jeder Aufgabe), `"at-end"` (am Dokumentende), `"only"` (nur Lösungen)
/// - solutions-pagebreak (str, none): Umbruch bei `solutions: "at-end"`: `none`, `"before"` (Seitenumbruch vor dem Lösungsteil), `"per-task"` (jede Aufgabe auf eigener Seite)
/// - materials (str, none): Material: `none`, `"after-task"` (nach der Aufgabe), `"at-end"` (am Dokumentende)
/// - materials-pagebreak (str, none): `"before"`: Material steht auf eigener Seite (bei `"at-end"`: ein Umbruch vor dem Materialteil); `none`: kein Umbruch
/// - points (str, none): Punkteanzeige: `none`, `"tasks"`, `"subtasks"`, `"all"`
/// - points-total (bool): Summe im Aufgabenkopf zeigen
/// - points-position (str): Punkte der Teilaufgaben am Zeilenende (`"end"`) oder am Seitenrand (`"margin"`)
/// - points-format (auto, function, dictionary): Vorlage der Punkteanzeige: `auto`, eine Funktion `points => content` oder `(task: f, subtask: g)`
/// - workspaces (bool): Arbeitsflächen (`workspace`, `workspace:`) setzen
/// - shortcodes (str, none): Kurzschreibweise: `"tasks"` (`= Titel` wird eine Aufgabe), `"subtasks"` (`+ Text` wird eine Teilaufgabe), `"all"` oder `none`
/// - subtask-numbering (str): Nummerierung der Teilaufgaben als Typst-Muster, zum Beispiel `"a)"` oder `"1.1"`
/// - scope (str, none): Kennung der Fassung im Bündel: setzt Zähler zurück, markiert Anfang und Ende und löst Verweise innerhalb der Fassung auf
/// - subject (str, none): Fach für die Materialbibliothek, zum Beispiel `"physik"`
/// - topic (str, none): Thema als Pfad in der Materialbibliothek, zum Beispiel `"physik/energie"`
/// - years (array): Jahrgänge, in denen das Blatt eingesetzt wird, zum Beispiel `(9, 11)`
/// - stage (str, none): Schulstufe: `"sek-1"` oder `"sek-2"`
/// - level (str, none): Anforderungsniveau: `"introduction"`, `"consolidation"`, `"ea"`, `"ga"`
/// - kind (str, none): Materialart: `"worksheet"`, `"practice"`, `"stations"`, `"exam"`
/// - keywords (array): freie Stichworte
/// - curriculum (array): Bezüge zum Kerncurriculum
/// - revision (str, none): Datum der letzten Überarbeitung als `"JJJJ-MM-TT"`
/// - ..deprecated (arguments): fängt alte Namen ab und meldet den neuen; nimmt nichts an
/// - body (content): Inhalt des Blatts
/// -> content
#let arbeitsblatt-einzeln(
  // <erzeugt signatur arbeitsblatt-einzeln>
  title: none,
  class: none,
  header: auto,
  copyright-url: none,
  paper: "a4",
  landscape: false,
  print: false,
  duplex: true,
  two-up: false,
  page-settings: (:),
  theme: auto,
  accent: auto,
  font: auto,
  math-font: auto,
  font-size: auto,
  title-font-size: auto,
  figure-font-size: auto,
  solutions: none,
  solutions-pagebreak: none,
  materials: "after-task",
  materials-pagebreak: "before",
  points: none,
  points-total: true,
  points-position: "end",
  points-format: auto,
  workspaces: true,
  shortcodes: "subtasks",
  subtask-numbering: "a)",
  scope: none,
  subject: none,
  topic: none,
  years: (),
  stage: none,
  level: none,
  kind: none,
  keywords: (),
  curriculum: (),
  revision: none,
  // </erzeugt>
  ..deprecated,
  body,
) = {
  let options = (
    // <erzeugt optionen arbeitsblatt-einzeln>
    title: title,
    class: class,
    header: header,
    copyright-url: copyright-url,
    paper: paper,
    landscape: landscape,
    print: print,
    duplex: duplex,
    two-up: two-up,
    page-settings: page-settings,
    theme: theme,
    accent: accent,
    font: font,
    math-font: math-font,
    font-size: font-size,
    title-font-size: title-font-size,
    figure-font-size: figure-font-size,
    solutions: solutions,
    solutions-pagebreak: solutions-pagebreak,
    materials: materials,
    materials-pagebreak: materials-pagebreak,
    points: points,
    points-total: points-total,
    points-position: points-position,
    points-format: points-format,
    workspaces: workspaces,
    shortcodes: shortcodes,
    subtask-numbering: subtask-numbering,
    subject: subject,
    topic: topic,
    years: years,
    stage: stage,
    level: level,
    kind: kind,
    keywords: keywords,
    curriculum: curriculum,
    revision: revision,
    // </erzeugt>
  )
  check-head("arbeitsblatt-einzeln", deprecated, options + (scope: scope), single-parameter-names)
  render-worksheet("arbeitsblatt-einzeln", options, scope, body)
}

/// Die Vorlage für ein Arbeitsblatt: Schrift, Seite, Kopfzeile, Aufgaben mit
/// Lösungen und Material, Themes und mehrere Fassungen aus einer Quelle.
///
/// Angewendet wird sie mit `#show: arbeitsblatt.with(…)`. Ein gewöhnliches
/// `typst compile` erzeugt genau ein Dokument. Im Bündel-Export
/// (`typst compile --features bundle --format bundle`) entsteht aus derselben
/// Quelle je Fassung eine Datei, ohne weitere Angabe `digital.pdf` und
/// `loesung.pdf`. `variants` wählt die Fassungen, `variant-overrides` ändert
/// je Fassung einzelne Kopfparameter.
///
/// Der Editor kann alle Fassungen hintereinander zeigen: mit dem System-Input
/// `vorschau=alle` (VS Code: `"tinymist.preview.sysInputs": { "vorschau": "alle" }`)
/// oder mit `preview-variant: "all"`.
///
/// ```typ
/// #import "@schule/arbeitsblatt:0.5.0": *
///
/// #show: arbeitsblatt.with(
///   title: [Quadratische Funktionen],
///   class: "MA-09",
///   points: "all",
///   variants: ("print", "digital", "solutions"),
/// )
///
/// = Grundlagen
/// + Bestimme die Nullstellen von $f(x) = x^2 - 4x + 3$.
///   #loesung[$x_1 = 1$, $x_2 = 3$]
/// ```
///
/// - title (str, content, none): Titel des Blatts in der Kopfzeile; `none` = kein Titel
/// - class (str, content, none): Klasse oder Kurs, rechts in der Kopfzeile; ein Kürzel wie `"MA-05"` bestimmt mit einem Theme Fachfarbe und Fachzeile
/// - header (auto, content, none): eigene Kopfzeile; `auto` = Kopf der Vorlage oder des Themes, `none` = kein Kopf
/// - copyright-url (str, none): Adresse für den kleinen QR-Code in der Kopfzeile (Lizenz- oder Quellenangabe)
/// - paper (str): Papierformat wie bei `page`; mit `two-up: true` nur `"a4"`, `"a5"`, `"a6"`
/// - landscape (bool): Querformat
/// - print (bool): Druckfassung: feste Seitenhöhe und Heftrand; ohne sie eine endlose Bildschirmseite
/// - duplex (bool): wechselnde Ränder für beidseitigen Druck (wirkt mit `print: true`)
/// - two-up (bool): jede Seite zweimal auf einen Bogen der nächsten Größe (Kopiervorlage zum Zerschneiden); verlangt `print: true`
/// - page-settings (dictionary): weitere Argumente für `set page`, zum Beispiel `margin`, `columns`, `header-ascent`
/// - theme (auto, str, dictionary, function): Gestaltung: `auto` = klassisch, ein Name aus `themes` (`"klar"`, `"atlas"`, `"skizze"`, `"labor"`, `"kontur"`, `"leiste"`, `"riso"`, `"bauhaus"`), ein Theme-Dictionary oder eine Funktion `(accent: auto, class: none) => dictionary`
/// - accent (auto, color): Akzentfarbe eines Themes; `auto` = Fachfarbe aus dem Klassenkürzel
/// - font (auto, str, array): Textschrift; `auto` = Schrift des Themes, sonst `"Myriad Pro"`
/// - math-font (auto, str, array): Formelschrift; `auto` = Schrift des Themes, sonst `"Fira Math"`
/// - font-size (auto, length): Grundschriftgröße; `auto` = Größe des Themes, sonst `12pt`
/// - title-font-size (auto, length): Größe des Titels in der Kopfzeile; `auto` = Größe des Themes, sonst `16pt`
/// - figure-font-size (auto, length): Schriftgröße der Bildunterschriften; `auto` = `9pt`
/// - solutions (str, none): Lösungen: `none`, `"in-place"` (nach jeder Teilaufgabe), `"after-task"` (nach jeder Aufgabe), `"at-end"` (am Dokumentende), `"only"` (nur Lösungen)
/// - solutions-pagebreak (str, none): Umbruch bei `solutions: "at-end"`: `none`, `"before"` (Seitenumbruch vor dem Lösungsteil), `"per-task"` (jede Aufgabe auf eigener Seite)
/// - materials (str, none): Material: `none`, `"after-task"` (nach der Aufgabe), `"at-end"` (am Dokumentende)
/// - materials-pagebreak (str, none): `"before"`: Material steht auf eigener Seite (bei `"at-end"`: ein Umbruch vor dem Materialteil); `none`: kein Umbruch
/// - points (str, none): Punkteanzeige: `none`, `"tasks"`, `"subtasks"`, `"all"`
/// - points-total (bool): Summe im Aufgabenkopf zeigen
/// - points-position (str): Punkte der Teilaufgaben am Zeilenende (`"end"`) oder am Seitenrand (`"margin"`)
/// - points-format (auto, function, dictionary): Vorlage der Punkteanzeige: `auto`, eine Funktion `points => content` oder `(task: f, subtask: g)`
/// - workspaces (bool): Arbeitsflächen (`workspace`, `workspace:`) setzen
/// - shortcodes (str, none): Kurzschreibweise: `"tasks"` (`= Titel` wird eine Aufgabe), `"subtasks"` (`+ Text` wird eine Teilaufgabe), `"all"` oder `none`
/// - subtask-numbering (str): Nummerierung der Teilaufgaben als Typst-Muster, zum Beispiel `"a)"` oder `"1.1"`
/// - variants (auto, array): Fassungen im Bündel-Export; `auto` = `("digital", "solutions")`. Vordefiniert: `"print"`, `"digital"`, `"solutions"`, `"two-up"`; eigene Namen brauchen einen Eintrag in `variant-overrides`
/// - variant-overrides (dictionary): Name einer Fassung → Dictionary abweichender Kopfparameter; der Schlüssel `path` ersetzt den Ausgabepfad
/// - preview-variant (auto, str, none): Fassungen in der Vorschau: `auto` = alle, wenn der Editor `--input vorschau=alle` setzt, `"all"` = immer alle, ein Name = genau diese Fassung, `none` = nie
/// - filename (str, none): Vorsatz der Ausgabedateien im Bündel (`"brueche"` → `brueche-digital.pdf`)
/// - subject (str, none): Fach für die Materialbibliothek, zum Beispiel `"physik"`
/// - topic (str, none): Thema als Pfad in der Materialbibliothek, zum Beispiel `"physik/energie"`
/// - years (array): Jahrgänge, in denen das Blatt eingesetzt wird, zum Beispiel `(9, 11)`
/// - stage (str, none): Schulstufe: `"sek-1"` oder `"sek-2"`
/// - level (str, none): Anforderungsniveau: `"introduction"`, `"consolidation"`, `"ea"`, `"ga"`
/// - kind (str, none): Materialart: `"worksheet"`, `"practice"`, `"stations"`, `"exam"`
/// - keywords (array): freie Stichworte
/// - curriculum (array): Bezüge zum Kerncurriculum
/// - revision (str, none): Datum der letzten Überarbeitung als `"JJJJ-MM-TT"`
/// - ..deprecated (arguments): fängt alte Namen ab und meldet den neuen; nimmt nichts an
/// - body (content): Inhalt des Blatts
/// -> content
#let arbeitsblatt(
  // <erzeugt signatur arbeitsblatt>
  title: none,
  class: none,
  header: auto,
  copyright-url: none,
  paper: "a4",
  landscape: false,
  print: false,
  duplex: true,
  two-up: false,
  page-settings: (:),
  theme: auto,
  accent: auto,
  font: auto,
  math-font: auto,
  font-size: auto,
  title-font-size: auto,
  figure-font-size: auto,
  solutions: none,
  solutions-pagebreak: none,
  materials: "after-task",
  materials-pagebreak: "before",
  points: none,
  points-total: true,
  points-position: "end",
  points-format: auto,
  workspaces: true,
  shortcodes: "subtasks",
  subtask-numbering: "a)",
  variants: auto,
  variant-overrides: (:),
  preview-variant: auto,
  filename: none,
  subject: none,
  topic: none,
  years: (),
  stage: none,
  level: none,
  kind: none,
  keywords: (),
  curriculum: (),
  revision: none,
  // </erzeugt>
  ..deprecated,
  body,
) = {
  let options = (
    // <erzeugt optionen arbeitsblatt>
    title: title,
    class: class,
    header: header,
    copyright-url: copyright-url,
    paper: paper,
    landscape: landscape,
    print: print,
    duplex: duplex,
    two-up: two-up,
    page-settings: page-settings,
    theme: theme,
    accent: accent,
    font: font,
    math-font: math-font,
    font-size: font-size,
    title-font-size: title-font-size,
    figure-font-size: figure-font-size,
    solutions: solutions,
    solutions-pagebreak: solutions-pagebreak,
    materials: materials,
    materials-pagebreak: materials-pagebreak,
    points: points,
    points-total: points-total,
    points-position: points-position,
    points-format: points-format,
    workspaces: workspaces,
    shortcodes: shortcodes,
    subtask-numbering: subtask-numbering,
    variants: variants,
    variant-overrides: variant-overrides,
    preview-variant: preview-variant,
    filename: filename,
    subject: subject,
    topic: topic,
    years: years,
    stage: stage,
    level: level,
    kind: kind,
    keywords: keywords,
    curriculum: curriculum,
    revision: revision,
    // </erzeugt>
  )
  check-head("arbeitsblatt", deprecated, options, bundle-parameter-names)
  // Bündelparameter aus den Optionen einer Fassung herausnehmen
  for name in ("variants", "variant-overrides", "preview-variant", "filename") {
    let _ = options.remove(name)
  }
  check-worksheet-options(package-name, "arbeitsblatt", options + (filename: filename))
  let resolved = resolve-variants(variants, variant-overrides, function: "arbeitsblatt")
  let names = resolved.map(pair => pair.first())
  check-type(package-name, "arbeitsblatt", "preview-variant", preview-variant, (auto, str, none), example: "\"all\"")
  if type(preview-variant) == str {
    check-value(package-name, "arbeitsblatt", "preview-variant", preview-variant, ("all", ..names))
  }
  // Optionen einer Fassung: Kopf, dann Vorlage der Fassung, dann eigene Abweichungen
  let variant-options(name, overrides) = {
    let merged = options + variant-presets.at(name, default: (:)) + overrides
    let _ = if "path" in merged { merged.remove("path") }
    merged
  }

  context if target() == "bundle" {
    for (name, overrides) in resolved {
      let merged = variant-options(name, overrides)
      document(
        overrides.at("path", default: variant-path(name, filename)),
        ..if merged.title not in (none, []) { (title: [#merged.title]) },
        render-worksheet("arbeitsblatt", merged, variant-scope(name, filename), body),
      )
    }
  } else if preview-variant == "all" or (preview-variant == auto and preview-all-requested()) {
    // Vorschau: alle Fassungen hintereinander, damit auch die Lösungsfassung
    // beim Schreiben sichtbar ist. Mit `auto` absichtlich an den System-Input
    // gekoppelt – sonst liefen die Lösungen auch bei einem gewöhnlichen
    // `typst compile` mit.
    for (name, overrides) in resolved {
      render-worksheet("arbeitsblatt", variant-options(name, overrides), name, body)
    }
  } else if type(preview-variant) == str {
    let (name, overrides) = resolved.find(pair => pair.first() == preview-variant)
    render-worksheet("arbeitsblatt", variant-options(name, overrides), name, body)
  } else {
    render-worksheet("arbeitsblatt", options, none, body)
  }
}
