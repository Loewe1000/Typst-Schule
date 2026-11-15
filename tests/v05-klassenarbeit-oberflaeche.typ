// klassenarbeit reicht genau die Oberfläche von arbeitsblatt weiter (ohne dessen
// `internal`) und fügt nur `klassenarbeit` und das eigene `internal` hinzu.
// erwartet: fehlt: \(\)
// erwartet: zusätzlich: \("klassenarbeit",\)
// erwartet: eigenes internal: true
#import "@schule/klassenarbeit:0.5.0" as exam
#import "@schule/arbeitsblatt:0.5.0" as worksheet
#let exam-names = dictionary(exam).keys()
#let worksheet-names = dictionary(worksheet).keys()
fehlt: #repr(worksheet-names.filter(name => name not in exam-names))

zusätzlich: #repr(exam-names.filter(name => name not in worksheet-names))

eigenes internal: #repr("exam-single" in dictionary(exam.internal) and exam.aufgabe == worksheet.aufgabe)
