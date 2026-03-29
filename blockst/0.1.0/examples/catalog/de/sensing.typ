#import "header.typ": c, t
#import "/blockst/0.1.0/lib.typ": set-blockst
#import "/blockst/0.1.0/lib.typ": scratch
#import scratch.de: *
#set-blockst(scale: 82%)
#t(
  c("#wird-beruehrt(\"Kante\")"),                    wird-beruehrt("Kante"),
  c("#wird-farbe-beruehrt(blue)"),                   wird-farbe-beruehrt(blue),
  c("#farbe-beruehrt-farbe(blue, green)"),           farbe-beruehrt-farbe(blue, green),
  c("#entfernung-von(\"Mauszeiger\")"),              entfernung-von("Mauszeiger"),
  c("#frage(\"Wie heißt du?\")"),                    frage("Wie heißt du?"),
  c("#antwort()"),                                   antwort(),
  c("#taste-gedrueckt(\"Leertaste\")"),              taste-gedrueckt("Leertaste"),
  c("#maustaste-gedrueckt()"),                       maustaste-gedrueckt(),
  c("#maus-x()"),                                    maus-x(),
  c("#maus-y()"),                                    maus-y(),
  c("#setze-ziehbarkeit(\"ziehbar\")"),              setze-ziehbarkeit("ziehbar"),
  c("#lautstaerke-fuehlen()"),                       lautstaerke-fuehlen(),
  c("#stoppuhr()"),                                  stoppuhr(),
  c("#setze-stoppuhr-zurueck()"),                    setze-stoppuhr-zurueck(),
  c("#eigenschaft-von(\"x-Position\", \"Figur1\")"), eigenschaft-von("x-Position", "Figur1"),
  c("#aktuell(\"Jahr\")"),                           aktuell("Jahr"),
  c("#tage-seit-2000()"),                            tage-seit-2000(),
  c("#benutzername()"),                              benutzername(),
)
