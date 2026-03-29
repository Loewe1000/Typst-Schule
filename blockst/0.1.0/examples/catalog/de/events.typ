#import "header.typ": c, t
#import "/blockst/0.1.0/lib.typ": set-blockst
#import "/blockst/0.1.0/lib.typ": scratch
#import scratch.de: *
#set-blockst(scale: 82%)
#t(
  c("#wenn-gruene-flagge-geklickt[...]"),           wenn-gruene-flagge-geklickt([]),
  c("#wenn-taste-gedrueckt(\"Leertaste\")[...]"),   wenn-taste-gedrueckt("Leertaste", []),
  c("#wenn-diese-figur-angeklickt[...]"),           wenn-diese-figur-angeklickt([]),
  c("#wenn-buehnenbildwechsel(\"Szene1\")[...]"),   wenn-buehnenbildwechsel("Szene1", []),
  c("#wenn-nachricht-empfangen(\"start\")[...]"),   wenn-nachricht-empfangen("start", []),
  c("#sende-nachricht(\"start\")"),                 sende-nachricht("start"),
  c("#sende-nachricht-und-warte(\"fertig\")"),      sende-nachricht-und-warte("fertig"),
)
