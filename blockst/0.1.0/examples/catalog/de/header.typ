#import "/blockst/0.1.0/lib.typ": scratch, set-blockst
#import scratch.de: *
#set-blockst(scale: 82%)

#let c(s) = raw(lang: "typ", s)
#let t(..rows) = table(
  columns: (auto, auto),
  align: (left + horizon, left + horizon),
  row-gutter: 4pt,
  inset: (x: 6pt, y: 5pt),
  stroke: (x, y) => (top: if y > 0 { 0.4pt + luma(215) } else { none }, bottom: none, left: none, right: none),
  ..rows,
)