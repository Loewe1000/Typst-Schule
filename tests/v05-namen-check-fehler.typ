// Gemeinsame Prüfmechanik: ein alter Name im Sink bricht auch über `.with` ab.
// fehler: aufgaben.aufgabe: `lösungen` heißt jetzt `solutions`
#import "/.github/namen/check.typ": check-named

#let aufgabe(title: none, ..deprecated, body) = {
  check-named("aufgaben", "aufgabe", deprecated, renamed: (loesungen: "solutions"), allowed: ("title",))
  body
}

#show: aufgabe.with(lösungen: "sofort")
Rumpf
