// Gemeinsame Prüfmechanik (.github/namen/check.typ): gültige Aufrufe laufen durch.
// erwartet: Aufgabe Titel Rumpf
// erwartet: Abstand 2
// erwartet: Vorschlag title
#import "/.github/namen/check.typ": check-named, check-positional, check-type, check-value, check-not-empty, nearest, edit-distance

#let aufgabe(title: none, method: none, large: true, ..deprecated, body) = {
  check-positional("aufgaben", "aufgabe", deprecated)
  check-named("aufgaben", "aufgabe", deprecated, renamed: (titel: "title"), allowed: ("title", "method", "large"))
  check-type("aufgaben", "aufgabe", "title", title, (content, str, none))
  check-type("aufgaben", "aufgabe", "large", large, bool)
  check-value("aufgaben", "aufgabe", "method", method, (none, "individual", "pair", "group"))
  check-not-empty("aufgaben", "aufgabe", "title", title, "kein Titel")
  [Aufgabe #title #body]
}

#show: aufgabe.with(title: [Titel], method: "pair")
Rumpf

Abstand #edit-distance("lösung", "loesung")

Vorschlag #nearest("Titl", ("method", "title"))
