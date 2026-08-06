#import "@schule/aufgaben:0.3.0": *
#import "@schule/random:0.0.1": *
#import "@schule/insert-a-word:0.0.3": *
#import "@schule/energy-sketch:0.0.2": *
#import "@schule/patterns:0.0.2": *
#import "@preview/eqalc:0.1.3": *
#import "@preview/zero:0.5.0": *
#import "@schule/mathematik:0.0.2": geogebra-algebra, geogebra-cell, graphen, kreisdiagramm, steckbrief, teilaufgaben
#import "@schule/informatik:0.0.2": *
#import "@schule/physik:0.0.2": (
  // Tabellen und Daten
  berechnung,
  datensatz,
  messdaten,
  messwerttabelle,
  pk,
  // Regression
  lineare_regression,
  quadratische_regression,
  wurzel_regression,
  exponentielle_regression,
  polynom_regression,
  potenz_regression,
  // Schaltkreis-Basis
  schaltkreis,
  zap,
  // Komponenten
  source,
  multimeter,
  lamp,
  amperemeter,
  voltmeter,
  motor,
  generator,
)
#import "@schule/operatoren:0.0.1": operator, operatoren-liste
#import "@preview/fontawesome:0.6.0": *
#import "@preview/zebra:0.1.0": qrcode as qr-code-zebra
#import "@preview/cetz:0.4.2": *
#import "@preview/cetz-plot:0.1.2": *
#import "@preview/codly:1.3.0": *
#import "@preview/colorful-boxes:1.4.3": *
#import "@preview/unify:0.8.1": add-unit, num as unify-num, qty as unify-qty, unit as unify-unit

#let _to-unify-str(value) = {
  if type(value) in (str, int, float) {
    str(value)
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

#let _named-with-default-per(named) = {
  if named.at("per", default: none) == none {
    named + (per: "fraction")
  } else {
    named
  }
}

/// Erstellt einen QR-Code mit schulfreundlichen Standardwerten.
///
/// Dünne Wrapper-Funktion um `zebra`'s `qrcode`. Der Hintergrund ist
/// standardmäßig transparent, damit sich der QR-Code in farbige Boxen
/// einfügt. Wird intern u. a. von `qrbox()` und `arbeitsblatt()` verwendet.
///
/// - ..args (any): Positionargumente an `qrcode` weitergereicht (z. B. URL).
/// - light-color (color): Hintergrundfarbe der hellen QR-Felder. Standard: vollständig transparent.
/// - dark-color (color): Vordergrundfarbe der dunklen QR-Felder. Standard: `black`.
/// - alt (string): Alternativtext für Barrierefreiheit.
/// -> content
#let qr-code(..args, light-color: white.transparentize(100%), dark-color: black, alt: "") = {
  qr-code-zebra(..args, fill: dark-color, background-fill: light-color)
}

/// Wrapper um `unify`'s `qty` mit Rückwärtskompatibilität zu `fancy-units`.
///
/// Alte Aufrufe wie `#qty[9.81][m/s^2]` übergeben in Typst `content`. Diese
/// Werte werden in Strings konvertiert und an `unify.qty` weitergereicht.
/// Unterstützt weiterhin auch die Kurzschreibweise mit zwei
/// Positionsargumenten:
///
/// ```typ
/// #qty[9.81][m/s^2]   // alte fancy-units-Syntax
/// #qty("9.81", "m/s^2") // Kurzschreibweise
/// ```
///
/// - ..args (any): Weitergegeben an `unify.qty`.
/// -> content
#let qty(..args) = {
  let positional = args.pos()
  let named = _named-with-default-per(args.named())
  if positional.len() == 2 {
    let value = _to-unify-str(positional.at(0))
    let unit = _to-unify-str(positional.at(1))
    return unify-qty(value, unit, ..named)
  } else {
    return unify-qty(..positional, ..named)
  }
}

/// Wrapper um `unify`'s `num` mit Rückwärtskompatibilität zu `fancy-units`.
///
/// Wie `qty`, aber für reine Zahlen ohne Einheit. Alte Aufrufe mit
/// `#num[...]` werden als String weitergegeben.
///
/// ```typ
/// #num[3.14]          // alte fancy-units-Syntax
/// #num("3.14")        // Kurzschreibweise
/// ```
///
/// - ..args (any): Weitergegeben an `unify.num`.
/// -> content
#let num(..args) = {
  let positional = args.pos()
  if positional.len() == 1 {
    let named = args.named()
    let value = _to-unify-str(positional.at(0))
    if named != () { return unify-num(value, ..named) }
    return unify-num(value)
  } else {
    return unify-num(..args)
  }
}

/// Wrapper um `unify`'s `unit` mit Rückwärtskompatibilität zu `fancy-units`.
///
/// Wie `qty`, aber für reine Einheiten ohne Zahlenwert. Alte Aufrufe mit
/// `#unit[...]` werden als String weitergegeben.
///
/// ```typ
/// #unit[N/m^2]        // alte fancy-units-Syntax
/// #unit("N/m^2")      // Kurzschreibweise
/// ```
///
/// - ..args (any): Weitergegeben an `unify.unit`.
/// -> content
#let unit(..args) = {
  let positional = args.pos()
  let named = _named-with-default-per(args.named())
  if positional.len() == 1 {
    let value = _to-unify-str(positional.at(0))
    return unify-unit(value, ..named)
  } else {
    return unify-unit(..positional, ..named)
  }
}

#let print-state = state("print", false)

// Aktive Bundle-Scope-Kennung. Als State (statt Closure), damit verschachtelte
// Aufrufe (z. B. eine zweite Klassenarbeit innerhalb des Varianten-Dokuments
// der ersten) die dokumentlokale Referenz-Auflösung erben.
#let _state_ab_scope = state("ab-scope", none)

/// Rendert genau ein Arbeitsblatt-Dokument (eine Variante).
///
/// Dies ist der bisherige Kern von `arbeitsblatt()`. Normalerweise wird statt
/// dieser Funktion die Show-Rule `arbeitsblatt()` verwendet, die im
/// Bundle-Export (Typst 0.15+) automatisch mehrere Varianten als eigene
/// Ausgabedateien erzeugt und außerhalb des Bundles direkt hierher
/// durchreicht. `arbeitsblatt-einzeln` ist öffentlich, damit aufbauende
/// Pakete (z. B. `klassenarbeit`) innerhalb ihrer eigenen
/// Bundle-Dokumente eine einzelne Variante rendern können.
///
/// Parameter wie bei `arbeitsblatt()`, zusätzlich:
///
/// - scope (string, none): Eindeutige Kennung des Varianten-Dokuments im
///   Bundle. Wenn gesetzt, werden alle Aufgaben-Zähler und -Zustände am
///   Dokumentanfang zurückgesetzt, Anfang/Ende des Dokuments mit
///   Marker-Labels versehen und Referenzen (`@label`) dokumentlokal
///   aufgelöst (im Bundle sind Labels global, gleicher Inhalt in mehreren
///   Varianten erzeugt also Duplikate). Standard: `none`.
/// -> function
#let arbeitsblatt-einzeln(
  title: "",
  class: "",
  paper: "a4",
  print: false,
  duplex: true,
  workspaces: true,
  font-size: 12pt,
  font: "Myriad Pro",
  math-font: "Fira Math",
  title-font-size: 16pt,
  figure-font-size: 9pt,
  landscape: false,
  custom-header: none,
  teilaufgabe-numbering: "a)",
  page-settings: (:),
  loesungen: "false",
  materialien: "seiten",
  punkte: "keine",
  aufgaben-shortcodes: "teilaufgaben",
  copyright: none,
  scope: none,
  ..args,
  body,
) = {
  font = (font, "Fira Sans", "New Computer Modern Sans", "DejaVu Sans")
  math-font = (math-font, "New Computer Modern Sans Math")
  // Set document title and authors in metadata
  // Set font and text properties
  set par(justify: true, leading: 0.65em, linebreaks: "optimized")

  add-unit("Watt hours", "Wh", "upright(\"Wh\")")

  set text(font-size, font: font, hyphenate: true, lang: "de")
  show math.equation: set text(font: math-font)

  show math.equation: it => {
    show regex("\d+\.\d+"): num => num.text.replace(".", ",")
    it
  }

  show ref: it => context {
    // Im Bundle existiert dasselbe Label in jedem Varianten-Dokument.
    // `it.element` liefert dann `none`, daher dokumentlokal zwischen den
    // Scope-Markern auflösen. Der Scope kommt aus dem State, damit auch
    // verschachtelte Vorlagen-Aufrufe ihn erben.
    let scope = _state_ab_scope.get()
    let el = if scope == none {
      it.element
    } else {
      let kandidaten = query(
        selector(it.target)
          .after(std.label("_ab-start-" + scope), inclusive: false)
          .before(std.label("_ab-ende-" + scope), inclusive: false),
      )
      if kandidaten.len() == 0 {
        // Ziel existiert nicht in diesem Varianten-Dokument (z. B. wird das
        // Material im Lösungsmodus "nur" nie angezeigt). Bundle-weit suchen:
        // Da alle Varianten denselben Inhalt rendern, stimmt die Nummerierung
        // des ersten Treffers.
        kandidaten = query(selector(it.target))
      }
      if kandidaten.len() > 0 { kandidaten.first() } else { none }
    }
    if el != none and el.func() == figure and el.kind == "material" {
      {
        let current-aufgabe = _state_current_material_aufgabe.at(el.location())
        let material-index = _state_current_material_index.at(el.location())

        // Fallback falls nicht in Material-Sektion
        if current-aufgabe == 0 {
          current-aufgabe = _counter_aufgaben.get().at(0)
          material-index = counter(figure.where(kind: "material")).at(el.location()).first()
        }

        link(el.location(), "M" + str(current-aufgabe) + "-" + numbering("A", material-index))
      }
    } else if el != none and el.func() == figure and el.kind == "teilaufgabe" {
      {
        let nummer = if _state_options.get().at("teilaufgabe-numbering", default: "1.") == "1." {
          numbering(
            "1.1",
            counter(figure.where(kind: "aufgabe")).at(el.location()).first(),
            counter(figure.where(kind: "teilaufgabe")).at(el.location()).first(),
          )
        } else if _state_options.get().at("teilaufgabe-numbering", default: "1.") == "a)" {
          numbering("a)", counter(figure.where(kind: "teilaufgabe")).at(el.location()).first())
        }
        link(el.location(), nummer)
      }
    } else if el != none and el.func() == figure and (el.kind == image or el.kind == table) {
      if scope == none {
        "A" + it
      } else {
        link(el.location(), "A" + str(counter(figure.where(kind: el.kind)).at(el.location()).first()))
      }
    } else if scope != none and el != none and el.func() == heading {
      // Dokumentlokale Überschriften-Referenz im Bundle
      link(el.location(), if el.numbering != none {
        numbering(el.numbering, ..counter(heading).at(el.location()))
      } else {
        el.body
      })
    } else if scope != none and query(selector(it.target)).len() > 1 {
      // Bundle mit dupliziertem Label und unbekanntem Zieltyp: Die
      // Standard-Referenz würde hart fehlschlagen, daher bestmöglicher
      // Ersatz als Link auf den dokumentlokalen Treffer.
      if el != none and el.func() == figure {
        link(el.location(), str(counter(figure.where(kind: el.kind)).at(el.location()).first()))
      } else if el != none {
        link(el.location(), text(red)[#it.target])
      } else {
        text(red)[#it.target]
      }
    } else {
      // Other references as usual.
      it
    }
  }

  let header(title: none, class: none, font-size: 16pt, copyright: none) = {
    text(font-size, weight: "semibold")[#title]
    h(1fr)

    if copyright != none {
      box(qr-code(copyright, width: 0.9em, dark-color: rgb("#828282"), alt: "QR-Code für Copyright-Informationen"))
      h(0.5em)
    }

    text(
      font-size,
      weight: "semibold",
      fill: luma(130),
    )[#class]
    move(dy: -.4em, line(length: 100%, stroke: 0.5pt + luma(200)))
  }

  context {
    let header-height = measure(custom-header, width: page.width).height
    // Set page properties
    set page(
      paper: paper,
      ..if not print {
        if landscape {
          (width: auto)
        } else {
          (height: auto)
        }
      },
      flipped: landscape,
      header-ascent: if "header-ascent" in args.named().keys() {
        args.named().at("header-ascent")
      } else {
        20%
      },
      // Margin-Logik: Prüfe zuerst page-settings.margin, dann Standard-Margins
      margin: if "margin" in page-settings.keys() {
        // Wenn explizit ein Margin in page-settings gesetzt wurde, verwende dieses
        let top = if type(page-settings.margin) == dictionary { page-settings.margin.at("top", default: 0cm) } else {
          page-settings.margin
        }
        let values = page-settings.margin
        let _ = if type(values) == dictionary {
          values.remove("top")
          values.insert("top", top + header-height)
        }
        values
      } else {
        // Ansonsten verwende die Standard-Margins basierend auf print/landscape/duplex
        if print {
          if landscape {
            (top: 2.3cm + header-height, x: 1.75cm, bottom: 1cm)
          } else {
            if duplex {
              (top: 2.3cm + header-height, inside: 2.25cm, outside: 1.25cm, bottom: 1cm)
            } else {
              (top: 2.3cm + header-height, left: 2.25cm, right: 1.25cm, bottom: 1cm)
            }
          }
        } else {
          (top: 2.2cm + header-height, x: 1.75cm, bottom: 1cm)
        }
      },
      header: if custom-header == none {
        header(title: title, class: class, font-size: title-font-size, copyright: copyright)
      } else {
        custom-header
      },
      // Alle anderen page-settings außer margin anwenden
      ..{
        let filtered-settings = (:)
        for (key, value) in page-settings.pairs() {
          if key != "margin" {
            filtered-settings.insert(key, value)
          }
        }
        filtered-settings
      },
    )

    set-options((
      "loesungen": loesungen,
      "materialien": materialien,
      "workspaces": workspaces,
      "punkte": punkte,
      "print": print,
      "teilaufgabe-numbering": teilaufgabe-numbering,
    ))

    print-state.update(_ => {
      print
    })

    // Bundle-Variante: Anfang markieren und alle Aufgaben-Zustände
    // zurücksetzen, da States/Counter im Bundle global sind.
    if scope != none {
      _state_ab_scope.update(scope)
      [#metadata("arbeitsblatt-start") #std.label("_ab-start-" + scope)]
      reset-aufgaben()
    }

    // Setting captions and numberings for figures
    set figure(numbering: "1", supplement: none)

    show figure.where(kind: image).or(figure.where(kind: table)): it => {
      let type = repr(it.kind)
      let supplement = ("image": "A", "table": "T").at(type, default: "M")
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

    show figure.where(kind: "material"): it => {
      context {
        let current-aufgabe = _state_current_material_aufgabe.get()
        let material-index = _state_current_material_index.get()

        // Fallback falls nicht in Material-Sektion
        if current-aufgabe == 0 {
          current-aufgabe = _counter_aufgaben.get().at(0)
          material-index = counter(figure.where(kind: "material")).at(it.location()).first()
        }

        let thm_num = "M" + str(current-aufgabe) + "-" + numbering("A", material-index)

        align(center)[
          #it.body
          #v(5pt)
          #align(left, grid(
            columns: 2,
            column-gutter: 0.5em,
            text(size: figure-font-size, strong(thm_num) + ":"), text(size: figure-font-size, it.caption),
          ))
        ]
      }
    }

    show figure.where(kind: "teilaufgabe"): it => align(
      left,
      box(width: 100%, [
        #it.body
      ]),
    )

    show: codly-init.with()
    codly(display-name: false)
    set raw(syntaxes: "processing.sublime-syntax")

    show heading.where(level: 1): it => if aufgaben-shortcodes in ("alle", "aufgaben") {
      set text(font-size, weight: 700)
      aufgabe(title: it.body, large: true)[]
    } else { block(below: 0.75em, it) }
    show enum.item: it => context {
      if aufgaben-shortcodes in ("alle", "teilaufgaben") and not _state_in_loesung.get() {
        teilaufgabe(it.body)
      } else {
        it
      }
    }

    body

    // "nur"-Modus: restliche Lösungen ausgeben (die vorherigen wurden
    // jeweils beim Beginn der nächsten Aufgabe angezeigt; idempotent).
    context if loesungen == "nur" {
      show-offene-loesungen()
    }

    // To show materials on a separate page
    context if materialien in ("seite", "reinquetschen") and _state_aufgaben.get().len() > 0 {
      show-materialien()
    }
    // To show solutions on a seperate page
    context if loesungen in ("seite", "seiten", "reinquetschen") and _state_aufgaben.get().len() > 0 {
      show-loesungen()
    }

    // Bundle-Variante: Ende des Varianten-Dokuments markieren
    if scope != none {
      [#metadata("arbeitsblatt-ende") #std.label("_ab-ende-" + scope)]
    }
  }
}

/// Vordefinierte Bundle-Varianten und ihre Options-Overrides.
#let _varianten-vorlagen = (
  druck: (print: true),
  digital: (print: false),
  loesung: (print: true, loesungen: "nur", workspaces: false),
)

/// Normalisiert den `varianten`-Parameter zu einem Array aus
/// (Name, Overrides)-Paaren.
#let _varianten-aufloesen(varianten) = {
  if varianten == auto {
    (("digital", (:)), ("loesung", (:)))
  } else if type(varianten) == str {
    ((varianten, (:)),)
  } else if type(varianten) == array {
    varianten.map(name => (name, (:)))
  } else if type(varianten) == dictionary {
    varianten.pairs()
  } else {
    panic("varianten muss auto, ein String, ein Array oder ein Dictionary sein, erhalten: " + repr(varianten))
  }
}

/// Erstellt ein Arbeitsblatt – die zentrale Show-Rule des Pakets.
///
/// Wird via `#show: arbeitsblatt.with(...)` angewendet und richtet Schrift,
/// Seitenformat, Kopfzeile, Aufgaben-Shortcodes, Lösungs- und Materialmodus
/// sowie die Bewertungsfunktionen ein.
///
/// Beim Bundle-Export (Typst 0.15+, `typst compile --features bundle
/// --format bundle`) erzeugt dieselbe Quelldatei automatisch mehrere
/// Ausgabedateien – standardmäßig `digital.pdf` und `loesung.pdf`. Über
/// `varianten:` lassen sich die Varianten wählen und pro Variante beliebige
/// Parameter überschreiben. Außerhalb des Bundles (normales
/// `typst compile`) verhält sich alles wie bisher und es entsteht genau ein
/// Dokument.
///
/// ```typ
/// #import "@schule/arbeitsblatt:0.3.0": *
///
/// #show: arbeitsblatt.with(
///   title: "Quadratische Funktionen",
///   class: "9a",
///   punkte: "alle",
///   // Bundle: Digital- und Lösungsfassung plus Druckfassung
///   varianten: ("druck", "digital", "loesung"),
/// )
///
/// = Grundlagen
/// + Bestimme die Nullstellen von $f(x) = x^2 - 4x + 3$.
///   #loesung[$x_1 = 1$, $x_2 = 3$]
/// ```
///
/// - title (string): Titel des Dokuments, erscheint in der Kopfzeile.
/// - class (string): Klassenbezeichnung (z. B. `"9a"` oder `"IF-11"`), rechts in der Kopfzeile.
/// - paper (string): Papierformat (z. B. `"a4"`, `"a5"`). Standard: `"a4"`.
/// - print (boolean): Druckmodus – aktiviert DIN-A4-Begrenzung und breitere Heftungsränder.
/// - duplex (boolean): Abwechselnde Seitenränder für beidseitigen Druck (wirkt nur mit `print: true`).
/// - workspaces (boolean): Ob Arbeitsbereiche (`workspace()`) angezeigt werden. Standard: `true`.
/// - font-size (length): Grundschriftgröße. Standard: `12pt`.
/// - font (string): Primäre Textschrift. Standard: `"Myriad Pro"`.
/// - math-font (string): Schriftart für Formeln. Standard: `"Fira Math"`.
/// - title-font-size (length): Schriftgröße des Titels in der Kopfzeile. Standard: `16pt`.
/// - figure-font-size (length): Schriftgröße für Abbildungsbeschriftungen. Standard: `9pt`.
/// - landscape (boolean): Querformat. Standard: `false`.
/// - custom-header (content, none): Eigene Kopfzeile; ersetzt den Standardkopf vollständig.
/// - teilaufgabe-numbering (string): Nummerierungsschema: `"a)"` (a, b, c…) oder `"1."` (1.1, 1.2…).
/// - page-settings (dictionary): Zusätzliche Argumente an `page` (z. B. `margin`, `columns`).
/// - loesungen (string): Lösungsmodus: `"keine"` | `"sofort"` | `"folgend"` | `"seite"` | `"seiten"` | `"nur"`.
/// - materialien (string): Materialmodus: `"sofort"` | `"seiten"` | `"reinquetschen"`.
/// - punkte (string): Punkteanzeige: `"keine"` | `"aufgaben"` | `"teilaufgaben"` | `"alle"`.
/// - aufgaben-shortcodes (string): Automatische Umwandlung: `"keine"` | `"aufgaben"` | `"teilaufgaben"` | `"alle"`.
/// - copyright (string, none): URL für Copyright-QR-Code in der Kopfzeile. Standard: `none`.
/// - varianten (auto, string, array, dictionary): Bundle-Varianten. `auto` →
///   `("digital", "loesung")`. Vordefiniert: `"druck"`, `"digital"`,
///   `"loesung"`. Als Dictionary können pro Variante Parameter überschrieben
///   und eigene Varianten definiert werden, z. B.
///   `(druck: (punkte: "alle"), loesung: (:))`. Mit dem Override-Schlüssel
///   `datei:` lässt sich der Ausgabepfad einer Variante komplett ersetzen.
///   Wirkt nur im Bundle-Export. Standard: `auto`.
/// - dateiname (string, none): Präfix für die Ausgabedateien im Bundle
///   (z. B. `"quadratische-funktionen"` → `quadratische-funktionen-digital.pdf`).
///   Standard: `none`.
/// - ..args (any): Weitere benannte Argumente (z. B. `header-ascent`).
/// -> function
#let arbeitsblatt(
  title: "",
  class: "",
  paper: "a4",
  print: false,
  duplex: true,
  workspaces: true,
  font-size: 12pt,
  font: "Myriad Pro",
  math-font: "Fira Math",
  title-font-size: 16pt,
  figure-font-size: 9pt,
  landscape: false,
  custom-header: none,
  teilaufgabe-numbering: "a)",
  page-settings: (:),
  loesungen: "false",
  materialien: "seiten",
  punkte: "keine",
  aufgaben-shortcodes: "teilaufgaben",
  copyright: none,
  varianten: auto,
  dateiname: none,
  ..args,
  body,
) = {
  let basis = (
    title: title,
    class: class,
    paper: paper,
    print: print,
    duplex: duplex,
    workspaces: workspaces,
    font-size: font-size,
    font: font,
    math-font: math-font,
    title-font-size: title-font-size,
    figure-font-size: figure-font-size,
    landscape: landscape,
    custom-header: custom-header,
    teilaufgabe-numbering: teilaufgabe-numbering,
    page-settings: page-settings,
    loesungen: loesungen,
    materialien: materialien,
    punkte: punkte,
    aufgaben-shortcodes: aufgaben-shortcodes,
    copyright: copyright,
  ) + args.named()

  context if target() == "bundle" {
    let praefix = if dateiname != none { dateiname + "-" } else { "" }
    for (name, overrides) in _varianten-aufloesen(varianten) {
      let opts = basis + _varianten-vorlagen.at(name, default: (:)) + overrides
      let pfad = opts.at("datei", default: praefix + name + ".pdf")
      let _ = if "datei" in opts { opts.remove("datei") }
      document(
        pfad,
        ..if opts.title not in ("", none, []) { (title: [#opts.title]) },
        arbeitsblatt-einzeln(..opts, scope: praefix + name, body),
      )
    }
  } else {
    arbeitsblatt-einzeln(..basis, body)
  }
}

/// Erzeugt eine Lücke für Lückentexte.
///
/// Zeigt `body` unsichtbar an und unterstreicht ihn, sodass eine ausgefüllte
/// Leerstelle entsteht. Ideal für Einsetzübungen.
///
/// ```typ
/// Die Hauptstadt ist #lücke[Berlin].
/// Der Wert ist #lücke(tight: true)[42].
/// ```
///
/// - body (content): Text, der die Lücke ausfüllt (bestimmt die Breite).
/// - tight (boolean): Kompaktmodus ohne seitlichen Einzug. Standard: `false`.
/// -> content
#let lücke(body, tight: false) = {
  box(
    move(
      dy: 0.33em,
      box(
        stroke: (bottom: 0.5pt),
        [
          #if not tight {
            h(2em)
          }
          #hide(body)
        ],
      ),
    ),
  )
}

#let c_canvas = canvas
#let canvas(..args, body) = {
  c_canvas(
    ..args,
    {
      import draw: *
      set-style(
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

/// Fügt einen Seitenumbruch ein, der nur im Druckmodus wirkt.
///
/// Nützlich, um Seitenumbrüche gezielt nur für die gedruckte Version
/// einzufügen, ohne die Web-/Bildschirmansicht zu beeinflussen.
///
/// - loesungen-only (boolean): Wenn `true`, wirkt der Umbruch nur wenn `loesungen: "nur"` gesetzt ist. Default: `false`
/// ```typ
/// #print-pagebreak()
/// #print-pagebreak(loesungen-only: true)
/// ```
/// -> content
#let print-pagebreak(loesungen-only: false) = {
  context {
    let print = print-state.get()
    let loesungen = state("options", (:)).get().at("loesungen", default: "keine")
    let loesungen-aktiv = loesungen == "nur"
    if loesungen-only and not loesungen-aktiv { return }
    if print {
      pagebreak()
    }
  }
}

/// Fügt einen Seitenumbruch ein, der nur außerhalb des Druckmodus wirkt.
///
/// Nützlich, um Inhalte in der Web-/Bildschirmansicht zu trennen, ohne
/// den Druck-Seitenfluss zu stören.
///
/// - loesungen-only (boolean): Wenn `true`, wirkt der Umbruch nur wenn `loesungen: "nur"` gesetzt ist. Default: `false`
/// ```typ
/// #non-print-pagebreak()
/// #non-print-pagebreak(loesungen-only: true)
/// ```
/// -> content
#let non-print-pagebreak(loesungen-only: false) = {
  context {
    let print = print-state.get()
    let loesungen = state("options", (:)).get().at("loesungen", default: "keine")
    let loesungen-aktiv = loesungen == "nur"
    if loesungen-only and not loesungen-aktiv { return }
    if not print {
      pagebreak()
    }
  }
}

/// Mehrspalten-Layout-Helfer (Minipage).
///
/// Verteilt beliebig viele Inhaltsblöcke horizontal in Spalten. Spaltenbreiten
/// können explizit angegeben oder automatisch (gleichmäßig) berechnet werden.
///
/// ```typ
/// // Explizite Spaltenbreiten:
/// #minipage(columns: (1fr, 2fr), spacing: 1cm)[
///   Linke Spalte
/// ][
///   Rechte Spalte (doppelt so breit)
/// ]
///
/// // Automatische Gleichverteilung:
/// #minipage[Spalte 1][Spalte 2][Spalte 3]
/// ```
///
/// - columns (array, auto): Spaltenbreiten-Array (z. B. `(1fr, 2fr)`). `auto` → gleichmäßig.
/// - align (alignment): Vertikale Ausrichtung innerhalb der Spalten. Standard: `horizon`.
/// - spacing (length): Abstand zwischen den Spalten. Standard: `5mm`.
/// - ..args (any): Positionsargumente = Inhaltsblöcke; benannte Argumente an `table` weitergereicht.
/// -> content
#let minipage(columns: auto, align: horizon, spacing: 5mm, ..args) = {
  // Sammle alle Body-Argumente
  let bodies = args.pos()

  // Bestimme die Anzahl der Spalten automatisch, wenn nicht angegeben
  let effective-columns = if columns == auto {
    // Erstelle Array mit 1fr für jede übergebene Body
    (1fr,) * bodies.len()
  } else {
    columns
  }

  table(
    stroke: none,
    columns: effective-columns,
    align: align,
    inset: 0pt,
    column-gutter: spacing,
    ..args.named(),
    ..bodies,
  )
}

/// Erstellt einen anklickbaren Icon+Text-Hyperlink.
///
/// Kombiniert ein Icon (Emoji oder beliebigen Content) mit einem farbigen
/// Linknamen zu einem klickbaren Element.
///
/// ```typ
/// #icon-link("https://example.com", "Zur Website")
/// #icon-link("https://example.com", "GitHub", icon: "🐙", color: black)
/// ```
///
/// - url (string): Ziel-URL des Links.
/// - name (string): Angezeigter Linktext.
/// - icon (content): Icon vor dem Linktext. Standard: `emoji.chain` (🔗).
/// - color (color): Textfarbe des Linknamens. Standard: `blue`.
/// -> content
#let icon-link(url, name, icon: emoji.chain, color: blue) = {
  //fa-external-link(fill: blue)
  link(url)[#icon #text(fill: color, [#name])]
}

/// Erstellt eine QR-Code-Box mit Linktext.
///
/// Kombiniert einen QR-Code mit einem klickbaren `icon-link` in einer
/// `stickybox`. Die Schriftgröße des Links wird automatisch an die Boxbreite
/// angepasst.
///
/// ```typ
/// #qrbox("https://example.com", "Zur Website", width: 3cm)
/// ```
///
/// - url (string): URL für QR-Code und Hyperlink.
/// - name (string): Angezeigter Linktext unter dem QR-Code.
/// - width (length): Gesamtbreite der Box. Standard: `3cm`.
/// - ..args (any): Weitere benannte Argumente an `stickybox` weitergereicht.
/// -> content
#let qrbox(url, name, width: 3cm, ..args) = {
  stickybox(width: width, ..args)[
    #set align(center)
    #qr-code(url, width: 0.75 * width, light-color: white.transparentize(100%), quiet-zone: false, alt: "QR-Code")
    #align(
      center,
      context {
        let text-size = 12pt
        let content-link = text(text-size, icon-link(url, name))
        let icon = true
        while measure(text(size: text-size, icon-link(url, name))).width > 0.8 * width and text-size > 10pt {
          text-size = text-size - 0.1pt
          content-link = text(text-size, icon-link(url, name))
        }
        if text-size <= 10pt {
          content-link = text(text-size, blue, link(url, name))
          icon = false
          while measure(text(size: text-size, link(url, name))).width < 0.8 * width and text-size < 12pt {
            text-size = text-size + 0.1pt
            content-link = text(text-size, blue, link(url, name))
          }
        }
        text(
          size: text-size,
          [
            #v(-1em)
            #v(0.05 * width)
            #content-link
            #if icon { v(0.05 * width) }
          ],
        )
      },
    )
  ]
}

/// Setzt Text in Monospace-Schrift (SF Mono).
///
/// Nützlich für Code-Snippets, Dateinamen oder andere technische Inhalte
/// im Fließtext.
///
/// ```typ
/// Öffne die Datei #mono[ab.typ] im Editor.
/// ```
///
/// - body (content): Inhalt, der in Monospace gesetzt wird.
/// -> content
#let mono(body) = text(font: "SF Mono", body)

/// Zeigt einen Arbeitsbereich für Schülerantworten (nur wenn `workspaces: true`).
///
/// Der Inhalt wird nur gerendert, wenn in `arbeitsblatt()` der Parameter
/// `workspaces: true` gesetzt ist. Damit kann derselbe Quelltext mit und
/// ohne Arbeitsbereiche kompiliert werden.
///
/// ```typ
/// #workspace(height: 5cm)[
///   #kariert(2)  // 2 mm-Karos als Zeichenfläche
/// ]
/// ```
///
/// - height (length): Standardhöhe des Arbeitsbereichs (wird an `body` übergeben). Standard: `5cm`.
/// - body (content): Inhalt des Arbeitsbereichs (z. B. kariertes Papier).
/// -> content
#let workspace(height: 5cm, body) = {
  context {
    let options = _state_options.get()
    if options.at("workspaces", default: false) {
      body
    }
  }
}
