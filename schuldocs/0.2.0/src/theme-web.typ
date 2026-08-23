// schuldocs — Vorlage für die Website
//
// Baut den vollständigen HTML-Baum: eigener `<head>` mit Verweis auf die
// Stilvorlage, Kopfbereich, Inhaltsverzeichnis als Navigation, Körper.
// Das Aussehen steckt in `assets/docs.css`, nicht hier.

#import "config.typ": css-name, pdf-mark, version as schuldocs-version, word

// Reiner Text aus beliebigem Inhalt — für Anker und Verzeichnis.
#let _plain(c) = {
  if c == none {
    ""
  } else if type(c) in (str, int, float) {
    str(c)
  } else if type(c) == content {
    if c.has("text") { c.text } else if c.has("children") {
      c.children.map(_plain).join("")
    } else if c.has("body") { _plain(c.body) } else if c == [ ] { " " } else { "" }
  } else {
    ""
  }
}

// Ankername aus einer Überschrift.
#let _slug(s) = {
  let t = lower(s.trim())
  t = t.replace("ä", "ae").replace("ö", "oe").replace("ü", "ue").replace("ß", "ss")
  t = t.replace("é", "e").replace("è", "e").replace("à", "a").replace("ç", "c")
  t = t.replace(regex("[^a-z0-9]+"), "-").trim("-")
  if t == "" { "abschnitt" } else { t }
}

// Alle Überschriften dieser Ausgabe mit eindeutigem Anker, in Reihenfolge.
// Die Marke `pdf-mark` steht am Anfang des Handbuchs; alles davor gehört zur
// Website. Ohne diese Trennung mischen sich die Überschriften beider Ausgaben.
#let _entries() = {
  let vergeben = (:)
  let liste = ()
  for h in query(selector(heading).before(pdf-mark)) {
    let anker = _slug(_plain(h.body))
    if anker in vergeben {
      vergeben.at(anker) += 1
      anker = anker + "-" + str(vergeben.at(anker))
    } else {
      vergeben.insert(anker, 1)
    }
    liste.push((
      level: h.level,
      body: h.body,
      slug: anker,
      loc: h.location(),
      outlined: h.outlined,
    ))
  }
  liste
}

// Verschachtelte Liste für das Inhaltsverzeichnis.
#let _toc-list(eintraege, von, ebene) = {
  let punkte = ()
  let i = von
  while i < eintraege.len() and eintraege.at(i).level >= ebene {
    let e = eintraege.at(i)
    let unten = _toc-list(eintraege, i + 1, e.level + 1)
    punkte.push(html.elem("li", {
      html.elem("a", attrs: (href: "#" + e.slug), e.body)
      unten.content
    }))
    i = unten.next
  }
  (
    content: if punkte.len() > 0 { html.elem("ul", punkte.join()) },
    next: i,
  )
}

#let _toc(eintraege, tiefe) = {
  let sichtbar = eintraege.filter(e => e.outlined and e.level <= tiefe)
  if sichtbar.len() == 0 { return none }
  html.elem(
    "nav",
    attrs: (class: "inhalt", "aria-label": "Inhaltsverzeichnis"),
    {
      context html.elem("h2", attrs: (class: "inhalt-titel"), word("contents"))
      _toc-list(sichtbar, 0, sichtbar.first().level).content
    },
  )
}

/// Setzt den Körper als Website.
///
/// - name (string): Paketname
/// - version (string): Paketversion
/// - description (string): Kurzbeschreibung für Kopf und `<head>`
/// - license (string): Lizenz
/// - authors (array): Autoren
/// - links (array): `(name: …, url: …)`
/// - notices (array): kurze Hinweise für den Kopfbereich
/// - depth (int): tiefste Ebene im Inhaltsverzeichnis
/// - body (content): Inhalt der Dokumentation
/// -> content
#let web-page(
  name: "",
  version: "",
  description: "",
  license: "",
  authors: (),
  links: (),
  notices: (),
  depth: 3,
  body,
) = {
  let titel = if version != "" { name + " " + version } else { name }

  // Die Sprache steht am Dokument und nicht fest im Gerüst: eine Seite, die
  // englisch geschrieben ist, soll sich auch englisch ankündigen.
  context html.elem("html", attrs: (lang: text.lang), {
    html.elem("head", {
      html.elem("meta", attrs: (charset: "utf-8"))
      html.elem("meta", attrs: (name: "viewport", content: "width=device-width, initial-scale=1"))
      html.elem("title", titel + " — " + word("docs"))
      if description != "" {
        html.elem("meta", attrs: (name: "description", content: description))
      }
      if authors.len() > 0 {
        html.elem("meta", attrs: (name: "author", content: authors.map(a => str(a)).join(", ")))
      }
      html.elem("meta", attrs: (name: "generator", content: "schuldocs " + schuldocs-version))
      html.elem("meta", attrs: (name: "color-scheme", content: "light dark"))
      html.elem("link", attrs: (rel: "stylesheet", href: css-name))
    })

    html.elem("body", {
      html.elem("header", attrs: (class: "kopf"), html.elem("div", attrs: (class: "kopf-inhalt"), {
        html.elem("h1", {
          name
          if version != "" {
            html.elem("span", attrs: (class: "version"), version)
          }
        })
        if description != "" {
          html.elem("p", attrs: (class: "beschreibung"), description)
        }
        if notices.len() > 0 {
          html.elem(
            "ul",
            attrs: (class: "hinweise"),
            notices.map(n => html.elem("li", n)).join(),
          )
        }
        if links.len() > 0 {
          html.elem(
            "nav",
            attrs: (class: "verweise", "aria-label": "Verweise"),
            links
              .map(l => link(l.at("url", default: ""), l.at("name", default: "Link")))
              .join(),
          )
        }
      }))

      html.elem("div", attrs: (class: "rahmen"), {
        context _toc(_entries(), depth)

        html.elem("main", {
          // Überschriften bekommen einen sprechenden Anker und einen
          // Sprungverweis darauf.
          show heading: it => context {
            let eintraege = _entries()
            let i = eintraege.position(e => e.loc == it.location())
            let anker = if i == none { _slug(_plain(it.body)) } else { eintraege.at(i).slug }
            html.elem(
              "h" + str(calc.min(it.level + 1, 6)),
              attrs: (id: anker),
              {
                it.body
                html.elem(
                  "a",
                  attrs: (
                    class: "anker",
                    href: "#" + anker,
                    "aria-label": "Verweis auf diesen Abschnitt",
                  ),
                  "#",
                )
              },
            )
          }
          body
        })
      })

      html.elem("footer", {
        html.elem("p", {
          titel
          if license != "" [ #sym.dot.c #license]
          [ #sym.dot.c Mit Typst gesetzt]
        })
      })
    })
  })
}
