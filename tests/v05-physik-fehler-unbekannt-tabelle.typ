// physik 0.5.0: messwerttabelle verschluckt unbekannte benannte Argumente nicht mehr.
// fehler: physik.messwerttabelle: unbekannter Parameter `kopf` – erlaubt: `count`, `row-height`, `header`, `width`, `digits`
#import "@schule/physik:0.5.0": datensatz, messwerttabelle

#messwerttabelle(datensatz((1, 2, 3)), kopf: ([A],))
