// schuldocs — Hinweiskästen für beide Ausgaben
//
// `gentle-clues` baut seine Kästen aus einem `grid`. Im HTML-Export verwirft
// Typst das („grid was ignored during HTML export"), und übrig bleibt ein
// Kasten ohne Aufbau. Diese Fassung geht denselben Weg wie `show-example`:
// im Web echte Auszeichnung, im Handbuch echter Satz.
//
// Auf der Website über diese Klassen gestaltet:
//
//   .sd-callout                 Hülle
//   .sd-callout--tip|--info|…   Art
//   .sd-callout-title           die Zeile mit Zeichen und Titel
//   .sd-callout-body            der Text

#import "config.typ": colors, doc-target

#let _arten = (
  tip: (zeichen: "→", titel: "Tipp", farbe: rgb("#0f7a5a")),
  info: (zeichen: "i", titel: "Hinweis", farbe: rgb("#14537f")),
  warning: (zeichen: "!", titel: "Achtung", farbe: rgb("#b45309")),
  caution: (zeichen: "!", titel: "Vorsicht", farbe: rgb("#a3232b")),
  note: (zeichen: "•", titel: "Notiz", farbe: rgb("#5b6670")),
)

/// Ein Hinweiskasten.
///
/// `kind` ist einer von `"tip"`, `"info"`, `"warning"`, `"caution"`, `"note"`.
/// `title` überschreibt die vorgegebene Überschrift der Art.
#let callout(body, kind: "info", title: auto) = context {
  let art = _arten.at(kind, default: _arten.info)
  let kopf = if title == auto { art.titel } else { title }

  if doc-target() == "web" {
    html.div(
      class: "sd-callout sd-callout--" + kind,
      {
        html.div(class: "sd-callout-title", kopf)
        html.div(class: "sd-callout-body", body)
      },
    )
  } else {
    // Handbuch: farbige Kante links, damit der Kasten im Satz nicht wie ein
    // Fremdkörper wirkt, sondern wie eine Randbemerkung.
    block(
      width: 100%,
      inset: (left: 0.9em, y: 0.7em, right: 0.7em),
      fill: art.farbe.lighten(94%),
      stroke: (left: 2.5pt + art.farbe),
      radius: (right: 3pt),
      {
        text(size: 0.86em, weight: "bold", fill: art.farbe, upper(kopf))
        v(0.35em, weak: true)
        body
      },
    )
  }
}

/// Die fünf Arten als eigene Funktionen — namensgleich mit `gentle-clues`,
/// damit ein Umstieg nur die Importzeile kostet.
#let tip(body, title: auto) = callout(body, kind: "tip", title: title)
#let info(body, title: auto) = callout(body, kind: "info", title: title)
#let warning(body, title: auto) = callout(body, kind: "warning", title: title)
#let caution(body, title: auto) = callout(body, kind: "caution", title: title)
#let note(body, title: auto) = callout(body, kind: "note", title: title)
