// patterns 0.5.0: flexible Felder (1fr) teilen sich den freien Platz;
// is-flex-area erkennt sie, flex-area baut eigene.
// erwartet: Oben
// erwartet: Eigenes Feld
// erwartet: Vertrag true false true false false
#import "@schule/patterns:0.5.0": flex-area, is-flex-area, kariert, liniert
#set page(paper: "a5")
Oben
#kariert(1fr)
#liniert(2fr, line-height: 0.8cm)
#kariert(1fr, columns: 10, items: ("A", "B"))
#flex-area(1fr, height => rect(width: 100%, height: height)[Eigenes Feld])
Vertrag #is-flex-area(kariert(1fr)) #is-flex-area(kariert(3)) #is-flex-area(liniert(1fr)) #is-flex-area([x]) #is-flex-area(none)
