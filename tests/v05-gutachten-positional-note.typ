// gutachten 0.5.0: `format-grade` nimmt genau einen Anteil; gezählt wird das Pflichtargument mit.
// fehler: gutachten.format-grade: 2 Positionsargumente, erlaubt ist höchstens 1 – nur den Anteil übergeben: `format-grade(0.75)`
#import "@schule/gutachten:0.5.0": *

#format-grade(0.5, 0.6)
