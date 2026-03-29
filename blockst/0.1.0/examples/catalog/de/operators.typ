#import "header.typ": c, t
#import "/blockst/0.1.0/lib.typ": set-blockst
#import "/blockst/0.1.0/lib.typ": scratch
#import scratch.de: *
#set-blockst(scale: 82%)
#t(
  c("#addiere(5, 3)"),                          addiere(5, 3),
  c("#subtrahiere(10, 4)"),                     subtrahiere(10, 4),
  c("#multipliziere(3, 4)"),                    multipliziere(3, 4),
  c("#dividiere(10, 2)"),                       dividiere(10, 2),
  c("#zufallszahl(von: 1, bis: 10)"),           zufallszahl(von: 1, bis: 10),
  c("#groesser-als(5, 3)"),                     groesser-als(5, 3),
  c("#kleiner-als(3, 5)"),                      kleiner-als(3, 5),
  c("#gleich(5, 5)"),                           gleich(5, 5),
  c("#und(operand1, operand2)"),                und([], []),
  c("#oder(operand1, operand2)"),               oder([], []),
  c("#nicht(operand)"),                         nicht([]),
  c("#verbinde(\"Hallo \", \"Welt\")"),         verbinde("Hallo ", "Welt"),
  c("#zeichen-von(1, \"Welt\")"),              zeichen-von(1, "Welt"),
  c("#laenge-von(\"Welt\")"),                  laenge-von("Welt"),
  c("#enthaelt(\"Apfel\", \"a\")"),            enthaelt("Apfel", "a"),
  c("#modulo(10, 3)"),                          modulo(10, 3),
  c("#runde(3.14)"),                            runde(3.14),
  c("#mathematik(\"Wurzel\", 9)"),             mathematik("Wurzel", 9),
)
