// summify 0.5.0: `visible: false` blendet die Inhalte der Zellen aus (in 0.1.0
// brach der Lernmodus ab, weil der Parameter `hide` das Builtin verdeckte).
// Überschriften bleiben; eine Zelle mit `visible: true` bleibt sichtbar.
// erwartet: Lernblatt
// erwartet: Kraftgesetz
// erwartet: Ausnahme
// nicht: Geheim
#import "@schule/summify:0.5.0": *

#show: summify.with(title: [Lernblatt], paper: "a4", visible: false)

#topic(title: [Mechanik])[
  #cell-columns[
    #cell(title: [Kraftgesetz])[Geheim]
  ][
    #cell(visible: true)[Ausnahme]
  ]
]
