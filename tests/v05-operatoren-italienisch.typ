// operatoren 0.5.0: Sprache "it" wählt die italienische CSV und Überschrift;
// der Sprachcode wird wie bisher ohne Rand und in Kleinbuchstaben gelesen.
// Ein Name mit Leerzeichen bekommt ein Label mit Bindestrich.
// erwartet: Elenco degli operatori
// erwartet: rappresentare graficamente +La rappresentazione
// erwartet: Ziel: 1
#import "@schule/operatoren:0.5.0": operator, operatoren-liste

#operator("rappresentare graficamente")
#operatoren-liste(language: " IT")

#context [Ziel: #query(<schule-operatoren-rappresentare-graficamente>).len()]
