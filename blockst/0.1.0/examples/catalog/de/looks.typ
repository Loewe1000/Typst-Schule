#import "header.typ": c, t
#import "/blockst/0.1.0/lib.typ": set-blockst
#import "/blockst/0.1.0/lib.typ": scratch
#import scratch.de: *
#set-blockst(scale: 82%)
#t(
  c("#sage-fuer-sekunden(\"Hallo!\", sekunden: 2)"),  sage-fuer-sekunden("Hallo!", sekunden: 2),
  c("#sage(\"Hallo!\")"),                             sage("Hallo!"),
  c("#denke-fuer-sekunden(\"Hmm...\", sekunden: 2)"), denke-fuer-sekunden("Hmm...", sekunden: 2),
  c("#denke(\"Hmm...\")"),                            denke("Hmm..."),
  c("#wechsle-zu-kostuem(\"Kostüm1\")"),              wechsle-zu-kostuem("Kostüm1"),
  c("#naechstes-kostuem()"),                          naechstes-kostuem(),
  c("#wechsle-zu-buehnenbild(\"Bühne1\")"),           wechsle-zu-buehnenbild("Bühne1"),
  c("#naechstes-buehnenbild()"),                      naechstes-buehnenbild(),
  c("#aendere-groesse(aenderung: 10)"),               aendere-groesse(aenderung: 10),
  c("#setze-groesse(groesse: 100)"),                  setze-groesse(groesse: 100),
  c("#aendere-effekt(\"Farbe\", aenderung: 25)"),     aendere-effekt("Farbe", aenderung: 25),
  c("#setze-effekt(\"Farbe\", wert: 0)"),             setze-effekt("Farbe", wert: 0),
  c("#schalte-grafikeffekte-aus()"),                  schalte-grafikeffekte-aus(),
  c("#zeige-dich()"),                                 zeige-dich(),
  c("#verstecke-dich()"),                             verstecke-dich(),
  c("#gehe-zu-ebene(\"vorne\")"),                     gehe-zu-ebene("vorne"),
  c("#go-ebenen(anzahl: 1, \"vorwärts\")"),           gehe-ebenen(anzahl: 1, "vorwärts"),
  c("#kostuem-eigenschaft(\"Nummer\")"),              kostuem-eigenschaft("Nummer"),
  c("#buehnenbild-eigenschaft(\"Nummer\")"),          buehnenbild-eigenschaft("Nummer"),
  c("#groesse()"),                                    groesse(),
)
