#import "header.typ": c, t
#import "/blockst/0.1.0/lib.typ": set-blockst
#import "/blockst/0.1.0/lib.typ": scratch
#import scratch.de: *
#set-blockst(scale: 82%)
#t(
  c("#fuege-zu-liste-hinzu(\"x\", \"Liste\")"),     fuege-zu-liste-hinzu("x", "Liste"),
  c("#entferne-aus-liste(1, \"Liste\")"),            entferne-aus-liste(1, "Liste"),
  c("#entferne-alles-aus-liste(\"Liste\")"),         entferne-alles-aus-liste("Liste"),
  c("#fuege-bei-ein(\"x\", 1, \"Liste\")"),          fuege-bei-ein("x", 1, "Liste"),
  c("#ersetze-element(1, \"Liste\", \"y\")"),        ersetze-element(1, "Liste", "y"),
  c("#element-von-liste(1, \"Liste\")"),             element-von-liste(1, "Liste"),
  c("#nummer-von-element(\"x\", \"Liste\")"),        nummer-von-element("x", "Liste"),
  c("#laenge-von-liste(\"Liste\")"),                 laenge-von-liste("Liste"),
  c("#liste-enthaelt(\"Liste\", \"x\")"),            liste-enthaelt("Liste", "x"),
  c("#zeige-liste(\"Liste\")"),                      zeige-liste("Liste"),
  c("#verstecke-liste(\"Liste\")"),                  verstecke-liste("Liste"),
)
