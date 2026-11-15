// `preview-variant: "all"` setzt alle Fassungen hintereinander; eigene Fassung über `variant-overrides`.
// erwartet: Aufgabe 1 − Erste
// erwartet: Lösung 1
// erwartet: 2 BE
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(
  title: [V],
  variants: ("digital", "solutions", "kontrolle"),
  variant-overrides: (kontrolle: (points: "all", solutions: "after-task")),
  preview-variant: "all",
)
#aufgabe(title: [Erste])[Rechne. #loesung[42] #erwartung(2)[richtig]]
