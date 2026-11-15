// gutachten 0.5.0: alter und neuer Name zugleich.
// fehler: gutachten.gutachten: `vorname` (alt) und `first-name` (neu) zugleich – nur `first-name` schreiben
#import "@schule/gutachten:0.5.0": *

#set-options(max-points: 10)
#gutachten(first-name: "Anna", vorname: "Lena")[x]
