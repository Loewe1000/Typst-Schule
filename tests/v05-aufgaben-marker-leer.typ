// `marker: ""` setzt wie `item-label: ""` in 0.3.1 eine Teilaufgabe ohne sichtbare Marke;
// per-task allein (ohne at-end) bleibt wirkungslos und bricht nicht ab.
// erwartet: Erste Teilaufgabe
// erwartet: b\) Zweite Teilaufgabe
// nicht: a\) Erste
#import "@schule/aufgaben:0.5.0": *
#set-options(solutions-pagebreak: "per-task")
#aufgabe[
  #teilaufgabe(marker: "")[Erste Teilaufgabe]
  #teilaufgabe[Zweite Teilaufgabe]
  #teilaufgaben(items: ([x], [y]), align: center, inset: (x: 2pt), gutter: 1fr, numbering: n => [(#n)])
]
