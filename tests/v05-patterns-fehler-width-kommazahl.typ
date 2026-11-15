// patterns 0.5.0: width als Kommazahl (früher Kästchen) nennt die passende Länge
// fehler: patterns.kariert: `width` erwartet eine Länge, bekam `2.5` (float) – Kästchenzahl mal Kästchengröße schreiben, hier `width: 1.25cm`
#import "@schule/patterns:0.5.0": *
#kariert(4, width: 2.5)
