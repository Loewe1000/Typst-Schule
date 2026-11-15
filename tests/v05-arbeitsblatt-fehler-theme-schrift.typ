// fehler: arbeitsblatt.arbeitsblatt: `schrift` gibt es nicht mehr – `font`, `math-font`, `font-size` und `title-font-size` stehen direkt im Theme
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(theme: (schrift: (text: "Lato")))
