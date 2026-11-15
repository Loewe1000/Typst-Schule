#import "@schule/abbozza:0.5.0": hathi-level

#let level = xml("level.abz")

*Aufgabe 1.* Hathi (blau) soll die Bananen einsammeln und danach die Flagge
hissen. Hartmut (pink) hilft ihr dabei.

#align(center, hathi-level(
  level,
  tile-size: 30mm,
  print: true,
  // Der Löwe steht in der Datei, soll hier aber nicht stören.
  replacements: (lion: "grass"),
  // Hartmut und seine Flagge kommen dazu.
  extra-tiles: (
    (kind: "hartmut", at: (5, 1), direction: "2"),
    (kind: "flag", at: (0, 2), hue: 344),
  ),
))

+ Wie viele Schritte braucht Hathi mindestens bis zu den Bananen?
+ Schreibe die Blockfolge auf, mit der Hathi die Flagge erreicht.
