// Eigenes Theme als Funktion: Hooks mit den Signaturen des Theme-Vertrags.
// erwartet: KOPF Eigenes PH-09
// erwartet: AUFGABE 1 Titel
// erwartet: \[a\)\] Teil
// erwartet: LSG Lösung a\): gelöst
// erwartet: KASTEN tip Tipp: Inhalt
// erwartet: circle-info
#import "@schule/arbeitsblatt:0.5.0": *
#let mein-theme(accent: auto, class: none) = (
  name: "mein",
  font: "Libertinus Serif",
  header: (title: none, class: none, copyright-url: none, font-size: auto) => [KOPF #title #class],
  task: (marker: none, title: none, icons: (), points: none, large: true) => [AUFGABE #marker #title],
  subtask: marker => [[#marker]],
  solution: (title: none, body) => [LSG #title: #body],
  callout: (kind: "info", title: none, accent: auto, breakable: false, width: auto, body) => [KASTEN #kind #title: #body],
)
#show: arbeitsblatt.with(title: [Eigenes], class: "PH-09", theme: mein-theme, solutions: "in-place")
#aufgabe(title: [Titel])[
  + Teil #loesung[gelöst]
]
#tip[Inhalt]
#callout-style("info", worksheet-accent: subject-accents.PH).icon-name
