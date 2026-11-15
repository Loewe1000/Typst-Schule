// physik 0.5.0: `error` ist ein Anteil; eine nackte Zahl wird mit Abhilfe abgelehnt.
// fehler: physik.berechnung: `error` erwartet einen Anteil, bekam `5` (int) – zum Beispiel `5%`
#import "@schule/physik:0.5.0": berechnung, datensatz

#berechnung(x => x, datasets: (datensatz((1, 2)),), error: 5)
