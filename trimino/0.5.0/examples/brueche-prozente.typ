// Neun Paare Bruch ↔ Prozent ergeben ein Dreieck aus neun Kärtchen.
// Drei Ablenker stehen auf den Außenkanten.
#import "@schule/trimino:0.5.0": trimino

#set page(paper: "a4", margin: 1.5cm)
#set text(lang: "de")

#trimino(
  title: [Brüche und Prozente],
  pairs: (
    ([$1/2$], [50 %]), ([$1/4$], [25 %]), ([$3/4$], [75 %]),
    ([$1/5$], [20 %]), ([$1/10$], [10 %]), ([$1/20$], [5 %]),
    ([$2/5$], [40 %]), ([$1/25$], [4 %]), ([$3/10$], [30 %]),
  ),
  distractors: ([15 %], [$1/3$], [80 %]),
)
