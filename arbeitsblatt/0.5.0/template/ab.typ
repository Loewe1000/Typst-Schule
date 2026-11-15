#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(
  title: [Titel],
  class: "MA-05",
  print: true,
  // theme: "klar",          // klar | atlas | skizze | labor | kontur | leiste | riso | bauhaus
  // solutions: "at-end",    // none | "in-place" | "after-task" | "at-end" | "only"
  // points: "all",          // none | "tasks" | "subtasks" | "all"
  // Bündel-Export (typst compile --features bundle --format bundle):
  // variants: ("print", "digital", "solutions"),
  // Alle Fassungen in der Vorschau: preview-variant: "all" oder im Editor den
  // System-Input vorschau=alle setzen (Handbuch, „Alle Fassungen in der Vorschau").
)

#aufgabe[
  Aufgabe ohne Titel
]

#aufgabe(title: [Titel der Aufgabe])[
  + Teilaufgabe
  + Teilaufgabe
]
