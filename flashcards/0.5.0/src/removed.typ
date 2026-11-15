// Alte Namen aus flashcards 0.0.1. Beide waren Werte (`#letter8up` ohne
// Klammern), keine Funktionen; deshalb brechen sie ab, sobald sie gesetzt
// werden, und nicht erst bei einem Aufruf.
#import "internal/check.typ": fail

#let letter8up = context fail("flashcards", "letter8up",
  "`letter8up` heißt jetzt `show-cards(paper: \"us-letter\")`")

#let a48up = context fail("flashcards", "a48up",
  "`a48up` heißt jetzt `show-cards(paper: \"a4\")`")
