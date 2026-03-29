#import "header.typ": c, t
#import "/blockst/0.1.0/lib.typ": set-blockst
#import "/blockst/0.1.0/lib.typ": scratch
#import scratch.de: *
#set-blockst(scale: 82%)
#t(
  c("#setze-variable(\"Punkte\", 0)"),             setze-variable("Punkte", 0),
  c("#aendere-variable(\"Punkte\", 1)"),           aendere-variable("Punkte", 1),
  c("#zeige-variable(\"Punkte\")"),                zeige-variable("Punkte"),
  c("#verstecke-variable(\"Punkte\")"),            verstecke-variable("Punkte"),
  c("#variable(name: \"Punkte\", wert: 42)"),      variable(name: "Punkte", wert: 42),
)
