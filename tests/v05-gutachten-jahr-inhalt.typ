// gutachten 0.5.0: `year` und die Angaben im Kopf nehmen auch Inhalt, `font` nimmt wie `text(font: …)` auch ein Dictionary (kompilierte so in 0.0.2).
// erwartet: Abitur 2027
// erwartet: Physik \(E\) - MS
#import "@schule/gutachten:0.5.0": *

#set-options(
  subject: [Physik],
  level: [E],
  teacher: [MS],
  max-points: 10,
  year: [2027],
  font: (name: "New Computer Modern Sans", covers: "latin-in-cjk"),
  math-font: ((name: "Fira Math", covers: "latin-in-cjk"), "New Computer Modern Math"),
)
#set-tasks(("A": (max-points: 10)))

#gutachten[#aufgabe("A", points: 5)[x]]
