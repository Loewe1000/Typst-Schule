// physik 0.5.0: ein Text, der keine Zahl ist, bricht mit einer Meldung des Pakets ab.
// fehler: physik.konstante: `value: "abc"` ist keine Zahl – zum Beispiel `"9.81"` oder `"2.998e8"`
#import "@schule/physik:0.5.0": konstante

#konstante("abc", name: "g")
