// callouts.typ – die 15 Kästen
//
// Dieselben Namen wie in gentle-clues, aber eigene Funktionen mit einer
// gemeinsamen Signatur. Ohne Theme (oder mit einem Theme ohne Hook `callout`)
// zeichnet gentle-clues wie bis 0.3.x; sonst zeichnet das Theme.

#import "internal.typ": callout

/// Kasten „Einführung": Überblick oder Einführung.
///
/// ```typ
/// #abstract[Inhalt des Kastens]
/// #abstract(title: [Eigener Titel])[Inhalt des Kastens]
/// ```
///
/// - title (auto, content, str, none): Titel; `auto` = „Einführung", `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens; `auto` = Farbe der Kastenart oder des Themes
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite; `auto` = volle Breite
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt
/// -> content
#let abstract(title: auto, accent: auto, breakable: false, width: auto, ..deprecated, body) = callout(
  "abstract",
  title: title,
  accent: accent,
  breakable: breakable,
  width: width,
  deprecated: deprecated,
  body,
)

/// Kasten „Info": Hinweis.
///
/// ```typ
/// #info[Inhalt des Kastens]
/// #info(title: [Eigener Titel])[Inhalt des Kastens]
/// ```
///
/// - title (auto, content, str, none): Titel; `auto` = „Info", `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens; `auto` = Farbe der Kastenart oder des Themes
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite; `auto` = volle Breite
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt
/// -> content
#let info(title: auto, accent: auto, breakable: false, width: auto, ..deprecated, body) = callout(
  "info",
  title: title,
  accent: accent,
  breakable: breakable,
  width: width,
  deprecated: deprecated,
  body,
)

/// Kasten „Frage": Frage.
///
/// ```typ
/// #question[Inhalt des Kastens]
/// #question(title: [Eigener Titel])[Inhalt des Kastens]
/// ```
///
/// - title (auto, content, str, none): Titel; `auto` = „Frage", `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens; `auto` = Farbe der Kastenart oder des Themes
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite; `auto` = volle Breite
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt
/// -> content
#let question(title: auto, accent: auto, breakable: false, width: auto, ..deprecated, body) = callout(
  "question",
  title: title,
  accent: accent,
  breakable: breakable,
  width: width,
  deprecated: deprecated,
  body,
)

/// Kasten „Merke": Merksatz.
///
/// ```typ
/// #memo[Inhalt des Kastens]
/// #memo(title: [Eigener Titel])[Inhalt des Kastens]
/// ```
///
/// - title (auto, content, str, none): Titel; `auto` = „Merke", `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens; `auto` = Farbe der Kastenart oder des Themes
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite; `auto` = volle Breite
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt
/// -> content
#let memo(title: auto, accent: auto, breakable: false, width: auto, ..deprecated, body) = callout(
  "memo",
  title: title,
  accent: accent,
  breakable: breakable,
  width: width,
  deprecated: deprecated,
  body,
)

/// Kasten „Zusammenfassung": Zusammenfassung.
///
/// ```typ
/// #conclusion[Inhalt des Kastens]
/// #conclusion(title: [Eigener Titel])[Inhalt des Kastens]
/// ```
///
/// - title (auto, content, str, none): Titel; `auto` = „Zusammenfassung", `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens; `auto` = Farbe der Kastenart oder des Themes
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite; `auto` = volle Breite
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt
/// -> content
#let conclusion(title: auto, accent: auto, breakable: false, width: auto, ..deprecated, body) = callout(
  "conclusion",
  title: title,
  accent: accent,
  breakable: breakable,
  width: width,
  deprecated: deprecated,
  body,
)

/// Kasten „Tipp": Tipp.
///
/// ```typ
/// #tip[Inhalt des Kastens]
/// #tip(title: [Eigener Titel])[Inhalt des Kastens]
/// ```
///
/// - title (auto, content, str, none): Titel; `auto` = „Tipp", `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens; `auto` = Farbe der Kastenart oder des Themes
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite; `auto` = volle Breite
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt
/// -> content
#let tip(title: auto, accent: auto, breakable: false, width: auto, ..deprecated, body) = callout(
  "tip",
  title: title,
  accent: accent,
  breakable: breakable,
  width: width,
  deprecated: deprecated,
  body,
)

/// Kasten „Erledigt": Bestätigung.
///
/// ```typ
/// #success[Inhalt des Kastens]
/// #success(title: [Eigener Titel])[Inhalt des Kastens]
/// ```
///
/// - title (auto, content, str, none): Titel; `auto` = „Erledigt", `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens; `auto` = Farbe der Kastenart oder des Themes
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite; `auto` = volle Breite
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt
/// -> content
#let success(title: auto, accent: auto, breakable: false, width: auto, ..deprecated, body) = callout(
  "success",
  title: title,
  accent: accent,
  breakable: breakable,
  width: width,
  deprecated: deprecated,
  body,
)

/// Kasten „Achtung": Warnung.
///
/// ```typ
/// #warning[Inhalt des Kastens]
/// #warning(title: [Eigener Titel])[Inhalt des Kastens]
/// ```
///
/// - title (auto, content, str, none): Titel; `auto` = „Achtung", `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens; `auto` = Farbe der Kastenart oder des Themes
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite; `auto` = volle Breite
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt
/// -> content
#let warning(title: auto, accent: auto, breakable: false, width: auto, ..deprecated, body) = callout(
  "warning",
  title: title,
  accent: accent,
  breakable: breakable,
  width: width,
  deprecated: deprecated,
  body,
)

/// Kasten „Fehler": typischer Fehler.
///
/// ```typ
/// #error[Inhalt des Kastens]
/// #error(title: [Eigener Titel])[Inhalt des Kastens]
/// ```
///
/// - title (auto, content, str, none): Titel; `auto` = „Fehler", `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens; `auto` = Farbe der Kastenart oder des Themes
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite; `auto` = volle Breite
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt
/// -> content
#let error(title: auto, accent: auto, breakable: false, width: auto, ..deprecated, body) = callout(
  "error",
  title: title,
  accent: accent,
  breakable: breakable,
  width: width,
  deprecated: deprecated,
  body,
)

/// Kasten „Beispiel": Beispiel.
///
/// ```typ
/// #example[Inhalt des Kastens]
/// #example(title: [Eigener Titel])[Inhalt des Kastens]
/// ```
///
/// - title (auto, content, str, none): Titel; `auto` = „Beispiel", `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens; `auto` = Farbe der Kastenart oder des Themes
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite; `auto` = volle Breite
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt
/// -> content
#let example(title: auto, accent: auto, breakable: false, width: auto, ..deprecated, body) = callout(
  "example",
  title: title,
  accent: accent,
  breakable: breakable,
  width: width,
  deprecated: deprecated,
  body,
)

/// Kasten „Ziel": Lernziel.
///
/// ```typ
/// #goal[Inhalt des Kastens]
/// #goal(title: [Eigener Titel])[Inhalt des Kastens]
/// ```
///
/// - title (auto, content, str, none): Titel; `auto` = „Ziel", `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens; `auto` = Farbe der Kastenart oder des Themes
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite; `auto` = volle Breite
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt
/// -> content
#let goal(title: auto, accent: auto, breakable: false, width: auto, ..deprecated, body) = callout(
  "goal",
  title: title,
  accent: accent,
  breakable: breakable,
  width: width,
  deprecated: deprecated,
  body,
)

/// Kasten „Idee": Idee.
///
/// ```typ
/// #idea[Inhalt des Kastens]
/// #idea(title: [Eigener Titel])[Inhalt des Kastens]
/// ```
///
/// - title (auto, content, str, none): Titel; `auto` = „Idee", `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens; `auto` = Farbe der Kastenart oder des Themes
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite; `auto` = volle Breite
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt
/// -> content
#let idea(title: auto, accent: auto, breakable: false, width: auto, ..deprecated, body) = callout(
  "idea",
  title: title,
  accent: accent,
  breakable: breakable,
  width: width,
  deprecated: deprecated,
  body,
)

/// Kasten „Experiment": Versuch.
///
/// ```typ
/// #experiment[Inhalt des Kastens]
/// #experiment(title: [Eigener Titel])[Inhalt des Kastens]
/// ```
///
/// - title (auto, content, str, none): Titel; `auto` = „Experiment", `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens; `auto` = Farbe der Kastenart oder des Themes
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite; `auto` = volle Breite
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt
/// -> content
#let experiment(title: auto, accent: auto, breakable: false, width: auto, ..deprecated, body) = callout(
  "experiment",
  title: title,
  accent: accent,
  breakable: breakable,
  width: width,
  deprecated: deprecated,
  body,
)

/// Kasten „Mitteilung": Mitteilung.
///
/// ```typ
/// #notify[Inhalt des Kastens]
/// #notify(title: [Eigener Titel])[Inhalt des Kastens]
/// ```
///
/// - title (auto, content, str, none): Titel; `auto` = „Mitteilung", `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens; `auto` = Farbe der Kastenart oder des Themes
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite; `auto` = volle Breite
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt
/// -> content
#let notify(title: auto, accent: auto, breakable: false, width: auto, ..deprecated, body) = callout(
  "notify",
  title: title,
  accent: accent,
  breakable: breakable,
  width: width,
  deprecated: deprecated,
  body,
)

/// Kasten „Gefahr": Gefahrenhinweis.
///
/// ```typ
/// #danger[Inhalt des Kastens]
/// #danger(title: [Eigener Titel])[Inhalt des Kastens]
/// ```
///
/// - title (auto, content, str, none): Titel; `auto` = „Gefahr", `none` = ohne Titelzeile
/// - accent (auto, color): Farbe des Kastens; `auto` = Farbe der Kastenart oder des Themes
/// - breakable (bool): darf über den Seitenwechsel umbrechen
/// - width (auto, relative): Breite; `auto` = volle Breite
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// - body (content): Inhalt
/// -> content
#let danger(title: auto, accent: auto, breakable: false, width: auto, ..deprecated, body) = callout(
  "danger",
  title: title,
  accent: accent,
  breakable: breakable,
  width: width,
  deprecated: deprecated,
  body,
)
