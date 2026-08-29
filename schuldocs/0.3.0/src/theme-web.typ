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
#let seiten-marke = <schuldocs-seite>

#let _entries() = {
  let vergeben = (:)
  let liste = ()
  let datei = ""
  for el in query(selector.or(heading, seiten-marke).before(pdf-mark)) {
    if el.func() == metadata {
      datei = el.value
      continue
    }
    let h = el
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
      datei: datei,
      loc: h.location(),
      outlined: h.outlined,
    ))
  }
  liste
}

// Verschachtelte Liste für das Inhaltsverzeichnis.
#let _toc-list(eintraege, von, ebene, wurzel: "") = {
  let punkte = ()
  let i = von
  while i < eintraege.len() and eintraege.at(i).level >= ebene {
    let e = eintraege.at(i)
    let unten = _toc-list(eintraege, i + 1, e.level + 1, wurzel: wurzel)
    punkte.push(html.elem("li", {
      html.elem("a", attrs: (href: wurzel + e.datei + "#" + e.slug), e.body)
      unten.content
    }))
    i = unten.next
  }
  (
    content: if punkte.len() > 0 { html.elem("ul", punkte.join()) },
    next: i,
  )
}

#let _toc(eintraege, tiefe, dateien, wurzel: "", hier: none) = {
  let sichtbar = eintraege.filter(e => e.outlined and e.level <= tiefe)
  // Die Gesamtseite steht neben den Kapiteln im selben Introspektionsraum;
  // ihre Ueberschriften gehoeren nicht ins Verzeichnis.
  if dateien.len() > 0 { sichtbar = sichtbar.filter(e => dateien.contains(e.datei)) }
  // Aufgeklappt statt aufgezaehlt: alle Kapitel stehen da, ihre Abschnitte aber
  // nur fuer das Kapitel, auf dem man ist. Sonst traegt jede Seite das
  // Verzeichnis aller anderen mit -- an typstage gemessen 91 Eintraege, von
  // denen hoechstens dreizehn zur gelesenen Seite gehoerten.
  //
  // Nebenbei sagt die Liste damit, *wo* man ist; vorher sahen alle zwoelf
  // Seiten gleich aus. `hier: none` heisst "alles zeigen" und gilt fuer die
  // Gesamtseite und fuer ein ungeteiltes Handbuch.
  if hier != none {
    sichtbar = sichtbar.filter(e => e.level == 1 or e.datei == hier)
  }
  if sichtbar.len() == 0 { return none }
  html.elem(
    "nav",
    attrs: (class: "inhalt", "aria-label": "Inhaltsverzeichnis"),
    {
      context html.elem("h2", attrs: (class: "inhalt-titel"), word("contents"))
      _toc-list(sichtbar, 0, sichtbar.first().level, wurzel: wurzel).content
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
  seiten: (),
  aktuell: -1,
  // Wie weit diese Seite von der Wurzel der Website entfernt liegt, als
  // Praefix: "" fuer eine Seite oben, "../" fuer eine in einem Ordner. Alle
  // Verweise gehen durch ihn hindurch. Ohne das zeigte ein Verweis aus
  // `en/geogebra.html` auf `en/index.html`, obwohl `index.html` oben liegt.
  wurzel: "",
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
      html.elem("link", attrs: (rel: "stylesheet", href: wurzel + css-name))
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
        context _toc(
          _entries(), depth, seiten.map(s => s.datei),
          wurzel: wurzel,
          hier: if aktuell >= 0 and seiten.len() > 1 { seiten.at(aktuell).datei },
        )

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

      if seiten.len() > 1 and aktuell >= 0 {
        html.elem("nav", attrs: (class: "blaettern", "aria-label": "Kapitel"), {
          if aktuell > 0 {
            let v = seiten.at(aktuell - 1)
            html.elem("a", attrs: (class: "zurueck", rel: "prev", href: wurzel + v.datei),
              "\u{2190} " + v.titel)
          }
          if aktuell + 1 < seiten.len() {
            let w = seiten.at(aktuell + 1)
            html.elem("a", attrs: (class: "weiter", rel: "next", href: wurzel + w.datei),
              w.titel + " \u{2192}")
          }
        })
      }

      html.elem("footer", {
        html.elem("p", {
          titel
          if license != "" [ #sym.dot.c #license]
          [ #sym.dot.c Mit Typst gesetzt]
        })
      })

      // Wo man gerade steht, in der Liste links. Nicht als Stilfrage, sondern
      // als Orientierung: auf einer Seite mit dreizehn Abschnitten sagt sonst
      // nichts, an welcher Stelle man liest.
      //
      // Inline und nicht als eigene Datei: es sind vierzig Zeilen, und eine
      // zweite Anfrage dafuer waere teurer als sie selbst. Ohne JavaScript
      // bleibt alles wie vorher -- die Liste steht, nur ohne Markierung.
      html.elem("script", ```
(function () {
  var nav = document.querySelector("nav.inhalt");
  if (!nav) return;
  var zuId = {};
  nav.querySelectorAll("a[href]").forEach(function (a) {
    var i = a.getAttribute("href").indexOf("#");
    if (i >= 0) zuId[a.getAttribute("href").slice(i + 1)] = a;
  });
  // Nur Marken, die auch in der Liste stehen. `main [id]` faengt sonst auch
  // Anker, die dort nichts zu suchen haben.
  var marken = [].slice.call(document.querySelectorAll("main [id]"))
    .filter(function (e) { return zuId[e.id]; });
  if (!marken.length) return;

  var jetzt = null;
  function stellen() {
    // Die oberste Ueberschrift, die noch ueber der Grenze steht. Nicht die
    // naechste darunter: beim Lesen steht der Abschnitt, in dem man ist,
    // gerade *oberhalb* des Blickfelds.
    var grenze = 120, treffer = marken[0];
    for (var i = 0; i < marken.length; i++) {
      if (marken[i].getBoundingClientRect().top <= grenze) treffer = marken[i];
      else break;
    }
    var a = zuId[treffer.id];
    if (a === jetzt) return;
    if (jetzt) jetzt.removeAttribute("aria-current");
    a.setAttribute("aria-current", "true");
    jetzt = a;
    // Mitziehen, aber nur wenn der Eintrag aus dem Sichtfeld der Liste
    // gelaufen ist. Eine Liste, die bei jedem Rollen selbst mitspringt, ist
    // unruhiger als eine, die stehen bleibt.
    var nr = nav.getBoundingClientRect(), ar = a.getBoundingClientRect();
    if (ar.top < nr.top + 8 || ar.bottom > nr.bottom - 8) {
      nav.scrollTop += ar.top - nr.top - nr.height / 3;
    }
  }
  addEventListener("scroll", stellen, { passive: true });
  addEventListener("resize", stellen);
  stellen();
})();
```.text)

    })
  })
}
