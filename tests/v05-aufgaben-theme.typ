// Theme-Vertrag: die Hooks task, subtask, solution, task-marker aus internal.theme-state.
// erwartet: KOPF 1 Titel 2 BE
// erwartet: \(a\)\) erste
// erwartet: LSG Lösung a\): L1
// erwartet: »2« ohne Titel
#import "@schule/aufgaben:0.5.0": *
#internal.theme-state.update((
  task: (marker: none, title: none, icons: (), points: none, large: true) => [KOPF #marker #title #points],
  subtask: marker => [(#marker)],
  solution: (title: none, body) => [LSG #title: #body],
  task-marker: task-number => [»#task-number«],
  task-marker-width: 3em,
))
#set-options(solutions: "in-place", points: "tasks")
#aufgabe(title: [Titel])[#teilaufgabe[erste #loesung[L1] #erwartung(2)[x]]]
#aufgabe[ohne Titel]
