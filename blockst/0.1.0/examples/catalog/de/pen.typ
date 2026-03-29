#import "header.typ": c, t
#import "/blockst/0.1.0/lib.typ": set-blockst
#import "/blockst/0.1.0/lib.typ": scratch
#import scratch.de: *
#set-blockst(scale: 82%)
#t(
  c("#loesche-alles()"),                              loesche-alles(),
  c("#hinterlasse-abdruck()"),                        hinterlasse-abdruck(),
  c("#schalte-stift-ein()"),                          schalte-stift-ein(),
  c("#schalte-stift-aus()"),                          schalte-stift-aus(),
  c("#setze-stiftfarbe-auf(blue)"),                   setze-stiftfarbe-auf(blue),
  c("#aendere-stift-param(\"Farbe\", wert: 10)"),     aendere-stift-param("Farbe", wert: 10),
  c("#setze-stift-param(\"Farbe\", wert: 50)"),       setze-stift-param("Farbe", wert: 50),
  c("#aendere-stiftdicke(dicke: 1)"),                 aendere-stiftdicke(dicke: 1),
  c("#setze-stiftdicke(dicke: 1)"),                   setze-stiftdicke(dicke: 1),
)
