// The English manual, website and PDF in one run:
//
//   typst compile manual-en.typ build --format bundle --features bundle,html --root ../../..
//
// A second entry point rather than a switch inside `docs.typ`: `docs()` is a
// show rule and emits exactly two documents, so one file cannot carry both
// languages. The content sits in `content-en.typ`; the German manual is
// `docs.typ` with `content.typ`.

#import "@schule/schuldocs:0.2.0": *

#set text(lang: "en")

#show: docs.with(
  toml: toml("../typst.toml"),
  html-name: "en.html",
  pdf-name: "brainroot-en.pdf",
  abstract: [The `brainroot` package draws two-sided mind maps: the root in the middle, coloured branches to the right and left, leaves to any depth. The layout is automatic.],
  links: (
    (name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),
    (name: "Deutsch", url: "index.html"),
  ),
  notices: ([Part of the Schule Typst ecosystem],),
)

#include "content-en.typ"
