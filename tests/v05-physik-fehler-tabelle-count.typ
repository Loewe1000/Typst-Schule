// physik 0.5.0: die Form von messwerttabellen 0.0.1 mit der Spaltenzahl als Positionsargument.
// fehler: physik.messwerttabelle: Positionsargument `5` ist kein Datensatz – die Spaltenzahl steht in `count: 5`
#import "@schule/physik:0.5.0": datensatz, messwerttabelle

#messwerttabelle(datensatz((1, 2)), 5)
