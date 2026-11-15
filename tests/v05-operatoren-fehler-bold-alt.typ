// operatoren 0.5.0: alter Parametername, auch über `.with`.
// fehler: operatoren.operatoren-liste: `operator-text-bold` heißt jetzt `bold`
#import "@schule/operatoren:0.5.0": operatoren-liste
#let liste = operatoren-liste.with(operator-text-bold: true)
#liste()
