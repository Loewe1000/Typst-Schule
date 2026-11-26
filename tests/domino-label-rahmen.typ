// erwartet: pill ok
// "pill" und "outline" rahmen auch beim Domino den Inhalt (wie bei den Triminos).
#import "/trimino/0.5.0/src/internal.typ": themes
#import "/trimino/0.5.0/src/domino.typ": domino-body

#context {
  let plain = measure(domino-body([27], 11pt, themes.riso + (label: "plain")))
  let pill = measure(domino-body([27], 11pt, themes.riso + (label: "pill")))
  let outline = measure(domino-body([27], 11pt, themes.riso + (label: "outline")))
  assert(pill.width > plain.width + 5pt, message: "pill ohne Kapsel")
  assert(outline.width > plain.width + 5pt, message: "outline ohne Rahmen")
  [pill ok]
}
