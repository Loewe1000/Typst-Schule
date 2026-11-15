// mathematik 0.5.0: die Einträge von `labels` werden geprüft.
// fehler: mathematik.graphen: `labels` erwartet Inhalt oder einen Text (`str`) oder `auto` oder `none`, bekam `1` (int) – zum Beispiel `([$t$ in s], auto)`
#import "@schule/mathematik:0.5.0": *

#graphen($x$, labels: (1, 2))
