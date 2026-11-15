// typlace – Sitzpläne für Klassenräume.
// Einstiegsdatei: bindet ausschließlich eigene Namen, namentlich.

#import "typlace.typ": typlace
#import "optimizer.typ": sitzordnung
#import "data.typ": wunschliste
#import "report.typ": seating-report, seating-summary
#import "scoring.typ": default-weights
#import "internal.typ"
#import "removed.typ": (
  bewerte, ist-frei, ist-koerper, ist-platz, ist-pult, koerper-zellen, kontext-erstellen, normalisiere-vorgaben,
  plaetze-analysieren, platz-von-schueler, punkte-schueler, punkte-wert, schueler-lesen, schueler-pruefen,
  sitzplan-bericht, sitzplan-kennzahlen, statistik, tausch-delta, wasm-suchen,
)
