#import "@schule/klassenarbeit:0.5.0": *

#show: klassenarbeit.with(
  title: [Klassenarbeit],
  subtitle: [Untertitel],
  class: [10a],
  date: [01.01.2025],
  teacher: [SLZ],
  points: "all", // none, "tasks", "subtasks", "all"
  // solutions: none, "in-place", "after-task", "at-end", "only"
  expectations: (achieved: true), // true, false oder Einstellungen für show-expectations; achieved: „_ / X“ zum Eintragen
  answer-sheets: (
    pattern: "squares", // "squares", "lines"
    correction-margin-side: "outside", // "outside" (am Blattrand), "inside" (an der Falz)
  ),
  // Bündel-Export (typst compile --features bundle --format bundle) erzeugt
  // „Klassenarbeit.pdf“ und „Klassenarbeit - Lösung.pdf“, mit answer-sheets
  // zusätzlich „Klassenarbeit - Klausurbögen.pdf“. Der Name ist der Titel
  // oder `filename`.
  // Einzelkompilation: preview-variant: "print" | "solutions" | "answer-sheets"
)
