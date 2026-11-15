// fehler: arbeitsblatt.arbeitsblatt: `punkte` heißt jetzt `points`
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(variant-overrides: (print: (punkte: "alle")))
