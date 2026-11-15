// operatoren 0.5.0: Der Physik-Operator „Hypothesen aufstellen" steht mit
// großem H in Physik.csv und ist in jeder Schreibweise benutzbar; die Liste
// zeigt die Schreibweise der CSV-Datei, das Label ist kleingeschrieben.
// erwartet: Stelle Hypothesen auf
// erwartet: Hypothesen aufstellen +eine Vermutung über einen unbekannten
// erwartet: Links: 2, Ziel: 1
// nicht: hypothesen aufstellen
#import "@schule/operatoren:0.5.0": operator, operatoren-liste

#operator("Hypothesen aufstellen", caption: [Stelle Hypothesen auf]) zum Ausgang.
Noch einmal: #operator("hypothesen aufstellen", caption: [Hypothesen]).

#operatoren-liste(subject: "Physik")

#context [Links: #query(link).len(), Ziel: #query(<schule-operatoren-hypothesen-aufstellen>).len()]
