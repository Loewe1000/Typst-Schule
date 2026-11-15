// fehler: arbeitsblatt.arbeitsblatt: `points: "alle"` heißt jetzt `"all"`
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(variant-overrides: (print: (points: "alle")))
