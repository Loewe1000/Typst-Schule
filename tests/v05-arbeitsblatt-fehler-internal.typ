// fehler: klassenarbeit.klassenarbeit: `solutions: "sofort"` heißt jetzt `"in-place"`
#import "@schule/arbeitsblatt:0.5.0" as worksheet-package
#worksheet-package.internal.check-worksheet-options("klassenarbeit", "klassenarbeit", (solutions: "sofort"))
