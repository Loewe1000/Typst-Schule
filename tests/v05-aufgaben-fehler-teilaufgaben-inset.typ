// Typprüfung der durchgereichten Tabellenparameter.
// fehler: aufgaben.teilaufgaben: `inset` erwartet eine Länge oder einen Anteil oder ein Dictionary oder eine Liste oder eine Funktion, bekam `"x"` (str) – zum Beispiel `5pt`
#import "@schule/aufgaben:0.5.0": *
#aufgabe[#teilaufgaben(items: ([a],), inset: "x")]
