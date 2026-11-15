// physik 0.5.0: ein alter Parametername bricht mit „heißt jetzt" ab.
// fehler: physik.messwerttabelle: `amount` heißt jetzt `count`
#import "@schule/physik:0.5.0": datensatz, messwerttabelle

#messwerttabelle(datensatz((1, 2, 3), name: "Zeit", unit: "s"), amount: 2)
