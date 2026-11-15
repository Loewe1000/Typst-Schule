// fehler: klassenarbeit.klassenarbeit: `points-format.aufgabe` heißt jetzt `points-format.task`
#import "@schule/klassenarbeit:0.5.0": *
#show: klassenarbeit.with(points-format: (aufgabe: p => [#p]))
