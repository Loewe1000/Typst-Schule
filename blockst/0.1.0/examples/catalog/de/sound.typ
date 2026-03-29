#import "header.typ": c, t
#import "/blockst/0.1.0/lib.typ": set-blockst
#import "/blockst/0.1.0/lib.typ": scratch
#import scratch.de: *
#set-blockst(scale: 82%)
#t(
  c("#spiele-klang-ganz(\"Miau\")"),                     spiele-klang-ganz("Miau"),
  c("#spiele-klang(\"Miau\")"),                          spiele-klang("Miau"),
  c("#stoppe-alle-klaenge()"),                           stoppe-alle-klaenge(),
  c("#aendere-klangeffekt(\"Tonhöhe\", wert: 10)"),      aendere-klangeffekt("Tonhöhe", wert: 10),
  c("#setze-klangeffekt(\"Tonhöhe\", wert: 100)"),       setze-klangeffekt("Tonhöhe", wert: 100),
  c("#schalte-klangeffekte-aus()"),                      schalte-klangeffekte-aus(),
  c("#aendere-lautstaerke(lautstaerke: -10)"),           aendere-lautstaerke(lautstaerke: -10),
  c("#setze-lautstaerke(lautstaerke: 100)"),             setze-lautstaerke(lautstaerke: 100),
  c("#lautstaerke()"),                                   lautstaerke(),
)
