// schuldocs — ein Lauf, alle Ausgaben
//
// `docs()` ist eine Show-Regel. Sie setzt denselben Körper zweimal: einmal als
// Website, einmal als Handbuch, und legt die Stilvorlage daneben. Gebaut wird
// das mit dem Bündel-Export von Typst 0.15:
//
//     typst compile docs.typ build --format bundle --features bundle,html --root /

// `doc-target` wird hier nur weitergereicht, damit es sowohl aus `config.typ`
// als auch aus `bundle.typ` zu haben ist.
#import "config.typ": css-name, doc-target, pdf-mark, target-state
#import "theme-pdf.typ": pdf-manual
#import "theme-web.typ": _plain, _slug, seiten-marke, web-page

// Beide Ausgaben teilen sich einen Introspektions-Raum. Zähler laufen deshalb
// vom ersten in das zweite Dokument weiter und werden zu Beginn jeder Ausgabe
// zurückgesetzt.
/// Was vor jeder Ausgabe zurückgesetzt wird.
///
/// Beide Ausgaben eines Bündellaufs teilen sich einen Introspektionsraum. Die
/// eigenen Zähler stellt `schuldocs` selbst zurück; die Zustände fremder
/// Pakete kann es nicht kennen. Ein Paket, dessen Beispiele durchnummeriert
/// werden, reicht deshalb seine eigene Rücksetzung über `reset:` herein —
/// sonst zählt das Handbuch dort weiter, wo die Website aufgehört hat.
#let _reset-counters() = {
  counter(heading).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: raw)).update(0)
  counter(math.equation).update(0)
  counter(footnote).update(0)
  counter(page).update(1)
}

// Die `[package]`-Tabelle aus `typst.toml`; ein bereits ausgepacktes
// Wörterbuch wird ebenfalls angenommen.
#let _package(data) = {
  if type(data) != dictionary { return (:) }
  if "package" in data { data.package } else { data }
}

#let _text-of(wert) = if wert == none { "" } else { str(wert) }

// Erzeugt die Ausgaben. `o` enthält die Angaben aus `docs()`.
#let _build(o, body) = {
  let pkg = _package(o.toml)
  let name = _text-of(pkg.at("name", default: "paket"))
  let version = _text-of(pkg.at("version", default: ""))
  let description = _text-of(pkg.at("description", default: ""))
  let license = _text-of(pkg.at("license", default: ""))
  let autoren = if o.authors.len() > 0 { o.authors } else { pkg.at("authors", default: ()) }
  let pdf-datei = if o.pdf-name == auto { name + ".pdf" } else { o.pdf-name }
  let titel = if version != "" { name + " " + version } else { name }

  // Die Reihenfolge ist bindend: die Website steht vor der Marke `pdf-mark`,
  // das Handbuch dahinter. Nur so lassen sich die Überschriften der beiden
  // Ausgaben auseinanderhalten.
  document(
    o.html-name,
    title: [#titel],
    description: [#description],
    author: autoren,
  )[
    #target-state.update("web")
    #_reset-counters()
    #(o.reset)()
    #web-page(
      name: name,
      version: version,
      description: description,
      license: license,
      authors: autoren,
      links: o.links,
      notices: o.notices,
      body,
    )
  ]


  document(
    pdf-datei,
    title: [#titel],
    description: [#description],
    author: autoren,
  )[
    #target-state.update("pdf")
    #_reset-counters()
    #(o.reset)()
    #metadata("schuldocs") #pdf-mark
    #pdf-manual(
      name: name,
      version: version,
      authors: autoren,
      license: license,
      description: description,
      abstract: o.abstract,
      links: o.links,
      body,
    )
  ]

  asset(css-name, read("assets/" + css-name, encoding: none))
}


// ─── Mehrseitig ─────────────────────────────────────────────────────────────

// Zerlegt den Koerper an den Ueberschriften der obersten Ebene. Alles vor der
// ersten Ueberschrift gehoert zum ersten Kapitel.
#let _flatten(c) = {
  // `#include` liefert eine Sequenz in einer Sequenz. Reine Sequenzen sind
  // bloße Aneinanderreihung und dürfen deshalb aufgelöst werden; alles andere
  // (auch `styled`) bleibt, wie es ist.
  if c.func() == [].func() and c.has("children") {
    c.children.map(_flatten).flatten()
  } else {
    (c,)
  }
}

#let _chapters(body) = {
  let kinder = _flatten(body)
  let kapitel = ()
  let aktuell = ()
  for k in kinder {
    let ist-kapitel = k.func() == heading and k.at("depth", default: 1) == 1
    if ist-kapitel and aktuell.any(x => x.func() == heading) {
      kapitel.push(aktuell)
      aktuell = (k,)
    } else {
      aktuell.push(k)
    }
  }
  if aktuell.len() > 0 { kapitel.push(aktuell) }
  kapitel
}

// Titel eines Kapitels: die erste Ueberschrift der obersten Ebene darin.
#let _chapter-title(kap) = {
  let h = kap.find(k => k.func() == heading and k.at("depth", default: 1) == 1)
  if h == none { none } else { h.body }
}

#let _build-multi(o, body) = {
  let pkg = _package(o.toml)
  let name = _text-of(pkg.at("name", default: "paket"))
  let version = _text-of(pkg.at("version", default: ""))
  let description = _text-of(pkg.at("description", default: ""))
  let license = _text-of(pkg.at("license", default: ""))
  let autoren = if o.authors.len() > 0 { o.authors } else { pkg.at("authors", default: ()) }
  let pdf-datei = if o.pdf-name == auto { name + ".pdf" } else { o.pdf-name }
  let titel = if version != "" { name + " " + version } else { name }

  let kapitel = _chapters(body)
  let seiten = kapitel.enumerate().map(((i, kap)) => {
    let t = _chapter-title(kap)
    let roh = if t == none { "kapitel-" + str(i + 1) } else { _plain(t) }
    (
      datei: if i == 0 { o.html-name } else { _slug(roh) + ".html" },
      titel: roh,
    )
  })

  for (i, kap) in kapitel.enumerate() {
    let seite = seiten.at(i)
    document(
      seite.datei,
      title: [#titel — #seite.titel],
      description: [#description],
      author: autoren,
    )[
      #target-state.update("web")
      #_reset-counters()
      #(o.reset)()
      #metadata(seite.datei)#seiten-marke
      #web-page(
        name: name,
        version: version,
        description: description,
        license: license,
        authors: autoren,
        links: o.links,
        notices: o.notices,
        seiten: seiten,
        aktuell: i,
        kap.join(),
      )
    ]
  }

  // Zusätzlich das ganze Handbuch auf einer Seite — für Strg-F und zum Drucken.
  document(
    "alles.html",
    title: [#titel],
    description: [#description],
    author: autoren,
  )[
    #target-state.update("web")
    #_reset-counters()
    #(o.reset)()
    #metadata("alles.html")#seiten-marke
    #web-page(
      name: name,
      version: version,
      description: description,
      license: license,
      authors: autoren,
      links: o.links,
      notices: o.notices,
      seiten: seiten,
      aktuell: -1,
      body,
    )
  ]

  document(
    pdf-datei,
    title: [#titel],
    description: [#description],
    author: autoren,
  )[
    #target-state.update("pdf")
    #_reset-counters()
    #(o.reset)()
    #metadata("schuldocs") #pdf-mark
    #pdf-manual(
      name: name,
      version: version,
      authors: autoren,
      license: license,
      description: description,
      abstract: o.abstract,
      links: o.links,
      body,
    )
  ]

  asset(css-name, read("assets/" + css-name, encoding: none))
}

/// Erzeugt Handbuch, Website und Stilvorlage in einem Lauf.
///
/// Als Show-Regel ganz oben in der Quelldatei einsetzen; alles danach ist der
/// Körper und wird für beide Ausgaben gesetzt.
///
/// ```typ
/// #import "@schule/schuldocs:0.2.0": docs, show-example, show-module
///
/// #show: docs.with(
///   toml: toml("../typst.toml"),
///   authors: ("Lukas Köhl",),
///   abstract: [Was das Paket kann.],
///   links: ((name: "GitHub", url: "https://github.com/…"),),
///   notices: ([Teil des Schule-Ökosystems],),
/// )
///
/// #include "content.typ"
/// ```
///
/// - toml (dictionary): Inhalt von `typst.toml` — Name, Version, Beschreibung,
///   Lizenz. Fehlt der Wert, greifen Vorgaben.
/// - authors (array): Autoren; leer bedeutet: die aus `typst.toml`
/// - abstract (content): Fließtext für die Titelseite des Handbuchs
/// - links (array): `(name: …, url: …)` für Kopf der Website und Titelseite
/// - notices (array): kurze Hinweise für den Kopf der Website
/// - pdf-name (auto | string): Dateiname des Handbuchs; `auto` ergibt
///   `<paketname>.pdf`
/// - html-name (string): Dateiname der Website
/// - reset (function): wird vor jeder der beiden Ausgaben aufgerufen. Für
///   Pakete mit eigenem Zustand, etwa `reset: () => reset-aufgaben()`.
/// -> function
///
/// Beide Schreibweisen der Show-Regel sind zulässig:
/// `#show: docs.with(toml: …)` und `#show: docs(toml: …)`. Im ersten Fall
/// kommt der Körper als einziges positionsgebundenes Argument an, im zweiten
/// Fall wird eine Funktion zurückgegeben, die ihn später erhält.
#let docs(
  toml: none,
  authors: (),
  abstract: [],
  links: (),
  notices: (),
  pdf-name: auto,
  html-name: "index.html",
  reset: () => none,
  split: false,
  ..rest,
) = {
  let einstellungen = (
    toml: toml,
    authors: authors,
    abstract: abstract,
    links: links,
    notices: notices,
    pdf-name: pdf-name,
    reset: reset,
    html-name: html-name,
  )
  let bauen = if split { _build-multi } else { _build }
  if rest.pos().len() == 0 {
    body => bauen(einstellungen, body)
  } else {
    bauen(einstellungen, rest.pos().first())
  }
}
