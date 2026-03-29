#import "header.typ": c, t
#import "/blockst/0.1.0/lib.typ": set-blockst
#import "/blockst/0.1.0/lib.typ": scratch
#import scratch.de: *
#set-blockst(scale: 82%)
#t(
  c("#warte(dauer: 1)"),                              warte(dauer: 1),
  c("#wiederhole(anzahl: 10)[...]"),                  wiederhole(anzahl: 10, []),
  c("#wiederhole-fortlaufend[...]"),                  wiederhole-fortlaufend([]),
  c("#falls(\"Bedingung?\")[...]"),                   falls("Bedingung?", []),
  c("#falls-sonst(\"Bedingung?\")[...][...]"),        falls-sonst("Bedingung?", [], []),
  c("#warte-bis(\"Bedingung?\")"),                    warte-bis("Bedingung?"),
  c("#wiederhole-bis(\"Bedingung?\")[...]"),          wiederhole-bis("Bedingung?", []),
  c("#stoppe(\"alle\")"),                             stoppe("alle"),
  c("#wenn-ich-als-klon-entstehe[...]"),              wenn-ich-als-klon-entstehe([]),
  c("#erzeuge-klon(\"mich selbst\")"),               erzeuge-klon("mich selbst"),
  c("#loesche-diesen-klon()"),                        loesche-diesen-klon(),
)
