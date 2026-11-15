// Einstiegsdatei von @schule/aufgaben: bindet nur Eigenes, und nur namentlich.
#import "aufgaben.typ": (
  aufgabe, teilaufgabe, teilaufgaben, loesung, erwartung, material,
  set-options, reset-tasks,
  show-solutions, show-materials, show-expectations, show-points-table,
  get-points, format-points, has-solutions, is-print,
)
// Interne Schnittstelle für abhängige @schule-Pakete (aufgaben.internal.…);
// Beschreibung am Kopf von internal.typ. Dokumente benutzen sie nicht.
#import "internal.typ"
// Alte Funktionsnamen: brechen mit „heißt jetzt" oder „gibt es nicht mehr" ab.
#import "removed.typ": (
  reset-aufgaben, show-loesungen, show-offene-loesungen, show-materialien, show-erwartungen, show-bewertung,
  format-punkte, show-loesung, show-loesung-inline, show-material, get-punkte-anzeige, get-punkte-position,
)
