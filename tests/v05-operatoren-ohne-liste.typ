// operatoren 0.5.0: Ohne Operatorenliste steht der Operator als Text ohne
// Link (0.0.1 brach hier mit „label does not exist“ ab).
// erwartet: Berechne den Wert
// erwartet: Links: 0
#import "@schule/operatoren:0.5.0": operator

#operator("berechnen", caption: [Berechne]) den Wert.

#context [Links: #query(link).len()]
