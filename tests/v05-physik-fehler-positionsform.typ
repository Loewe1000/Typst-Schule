// physik 0.5.0: die alte Aufrufform mit drei Positionsargumenten nennt die neue.
// fehler: physik.datensatz: 3 Positionsargumente, erlaubt ist eines – Name und Einheit benannt schreiben: `datensatz(values, name: …, unit: …)`
#import "@schule/physik:0.5.0": datensatz

#datensatz("Zeit", "s", (0, 1, 2))
