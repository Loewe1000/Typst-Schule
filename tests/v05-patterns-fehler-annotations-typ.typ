// patterns 0.5.0: annotations nimmt CeTZ-Elemente (Liste) oder none
// fehler: patterns.kariert: `annotations` erwartet eine Liste oder `none`, bekam `5` (int) – zum Beispiel `{ draw.line((0, 0), (4, 2)) }`
#import "@schule/patterns:0.5.0": *
#kariert(3, annotations: 5)
