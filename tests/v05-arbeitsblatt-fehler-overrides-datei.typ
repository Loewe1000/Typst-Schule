// fehler: arbeitsblatt.arbeitsblatt: `datei` heißt jetzt `path`
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(variant-overrides: (print: (datei: "x.pdf")))
