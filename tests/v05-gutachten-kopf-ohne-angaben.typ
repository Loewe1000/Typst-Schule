// gutachten 0.5.0: Ohne `teacher` (Vorgabe `none`) steht der Kopf wie in 0.0.2 mit `kürzel: ""`: „Physik (E) -“, nichts dahinter.
// Die Lage der Zeile (gleiches PDF wie 0.0.2) prüft der PDF-Vergleich, hier nur der Text.
// erwartet: Abitur 2027
// erwartet: Physik \(E\) -$
// nicht: none
#import "@schule/gutachten:0.5.0": *

#set-options(subject: "Physik", level: "E", max-points: 10, year: 2027)
#set-tasks(("A": (max-points: 10)))

#gutachten[#aufgabe("A", points: 5)[x]]
