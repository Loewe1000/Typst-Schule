#import "header.typ": c, t
#import "/blockst/0.1.0/lib.typ": set-blockst
#import "/blockst/0.1.0/lib.typ": scratch
#import scratch.de: *
#set-blockst(scale: 82%)
#t(
  c("#gehe(schritte: 10)"),                    gehe(schritte: 10),
  c("#drehe-rechts(grad: 15)"),                drehe-rechts(grad: 15),
  c("#drehe-links(grad: 15)"),                 drehe-links(grad: 15),
  c("#gehe-zu-position(\"Zufallsposition\")"), gehe-zu-position("Zufallsposition"),
  c("#gehe-zu(x: 0, y: 0)"),                  gehe-zu(x: 0, y: 0),
  c("#gleite-zu(sekunden: 1, x: 0, y: 0)"),   gleite-zu(sekunden: 1, x: 0, y: 0),
  c("#setze-richtung(richtung: 90)"),          setze-richtung(richtung: 90),
  c("#drehe-dich-zu(\"Mauszeiger\")"),         drehe-dich-zu("Mauszeiger"),
  c("#aendere-x(dx: 10)"),                     aendere-x(dx: 10),
  c("#setze-x(x: 0)"),                         setze-x(x: 0),
  c("#aendere-y(dy: 10)"),                     aendere-y(dy: 10),
  c("#setze-y(y: 0)"),                         setze-y(y: 0),
  c("#pralle-vom-rand-ab()"),                  pralle-vom-rand-ab(),
  c("#setze-drehtyp(\"links-rechts\")"),       setze-drehtyp("links-rechts"),
  c("#x-position()"),                          x-position(),
  c("#y-position()"),                          y-position(),
  c("#richtung()"),                            richtung(),
)
