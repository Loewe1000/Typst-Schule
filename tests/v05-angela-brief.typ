// angela 0.5.0: `#show: brief` setzt den Briefkopf; die Schulfarben sind Farbwerte.
// erwartet: Angelaschule Osnabrück
// erwartet: Staatlich anerkanntes Gymnasium der Schulstiftung im Bistum Osnabrück
// erwartet: Sehr geehrte Eltern
// erwartet: Ablauf
// erwartet: dunkel rgb\("#28509b"\) hell rgb\("#96b4dd"\)
#import "@schule/angela:0.5.0": brief, angela-dark, angela-light

#show: brief

#text(8pt, fill: angela-dark)[Angelaschule Osnabrück · Große Domsfreiheit 33 · 49074 Osnabrück]

*Betreff: Elternbrief zur Klassenfahrt*

Sehr geehrte Eltern,

die Klassenfahrt findet vom 14. bis 18. Oktober statt.

== Ablauf

Der Bus fährt um 8:00 Uhr vom Schulhof ab.

#block(fill: angela-light, inset: 4pt)[dunkel #repr(angela-dark) hell #repr(angela-light)]
