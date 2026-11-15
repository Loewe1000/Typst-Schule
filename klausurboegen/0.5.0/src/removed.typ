// Alte Funktionsnamen als abbrechende Stubs (konvention.md 9.3).

#import "internal/check.typ": fail, stub

#let klausurbögen = stub("klausurboegen", "klausurbögen", "klausurboegen")

// `bogen-seiten` und `klausurbogen-arbeit` (Ast 0.0.4) haben für Dokumente
// keinen Nachfolger mit eigenem Namen: Die Arbeit direkt auf dem Bogen
// schaltet `klassenarbeit` ein. Deshalb „gibt es nicht mehr" statt „heißt jetzt".
#let bogen-seiten(..args) = fail(
  "klausurboegen",
  "bogen-seiten",
  "`bogen-seiten` gibt es nicht mehr – die Arbeit direkt auf dem Bogen schaltet `klassenarbeit(answer-sheet-pages: …)` ein",
)
#let klausurbogen-arbeit(..args) = fail(
  "klausurboegen",
  "klausurbogen-arbeit",
  "`klausurbogen-arbeit` gibt es nicht mehr – `#show: klassenarbeit.with(answer-sheet-pages: true)` schreiben",
)
