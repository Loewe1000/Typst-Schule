#import "header.typ": c, t
#import "/blockst/0.1.0/lib.typ": set-blockst
#import "/blockst/0.1.0/lib.typ": scratch
#import scratch.de: *
#set-blockst(scale: 82%)
#let mein-block = eigener-block("springe ", (name: "h"), " px")
#t(
  c("#let mein-block = eigener-block(\"springe \", (name: \"h\"), \" px\")"),  mein-block(40),
  c("#definiere(mein-block, body)"),   definiere(mein-block, aendere-y(dy: eigene-eingabe("h"))),
  c("#mein-block(40)"),               mein-block(40),
  c("#eigene-eingabe(\"h\")"),         eigene-eingabe("h"),
)
