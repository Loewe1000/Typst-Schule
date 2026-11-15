// Einstiegsdatei von @schule/klassenarbeit 0.5.0. Alles wird namentlich
// gebunden; ein Dokument schreibt `#import "@schule/klassenarbeit:0.5.0": *`.
//
// Der Baustein `klassenarbeit` heißt deutsch wie sein Paket, alles in den
// Klammern ist englisch (plan-0.4/konvention.md, Anhang A.2).

// ── Eigenes ──────────────────────────────────────────────────────────────────
#import "klassenarbeit.typ": klassenarbeit
// Keine zugesicherte Schnittstelle; Dokumente benutzen das Modul nicht.
#import "internal.typ"

// ── Die Oberfläche von arbeitsblatt, namentlich weitergereicht ───────────────
// Genau die Exportliste von @schule/arbeitsblatt:0.5.0 ohne dessen `internal`
// (konvention.md 7.1). tests/v05-klassenarbeit-oberflaeche.typ vergleicht beide
// Listen: Kommt in arbeitsblatt ein Name dazu, schlägt der Test fehl.
#import "@schule/arbeitsblatt:0.5.0": (
  // Vorlagen und Helfer
  arbeitsblatt, arbeitsblatt-einzeln, callout-style, conditional-pagebreak, icon-link, lsg, luecke, minipage,
  qr-box, qr-code, subject-accents, subject-names, themes, workspace,
  // Kästen
  abstract, conclusion, danger, error, example, experiment, goal, idea, info, memo, notify, question, success, tip,
  warning,
  // die acht Fremdnamen (.github/namen/fremdnamen.txt)
  canvas, draw, fa-icon, num, plot, qty, stickybox, unit,
  // aufgaben
  aufgabe, erwartung, format-points, get-points, has-solutions, is-print, loesung, material, reset-tasks,
  set-options, show-expectations, show-materials, show-points-table, show-solutions, teilaufgabe, teilaufgaben,
  // patterns, insert-a-word, energy-sketch
  flex-area, is-flex-area, kariert, liniert, iaword, insert-a-word, reset-iaword, energy-sketch,
  // mathematik
  geogebra-algebra, geogebra-cell, graphen, kreisdiagramm, steckbrief,
  // physik
  berechnung, constants, datensatz, exponentielle-regression, lineare-regression, messdaten, messwerttabelle,
  polynom-regression, potenz-regression, quadratische-regression, schaltkreis, wurzel-regression,
  // informatik
  ascii-table, atbash, bin-to-dec, caesar, dec-to-bin, dec-to-hex, haeufigkeitsanalyse, hex-to-dec, rot13,
  text-to-blocks, vigenere,
  // operatoren
  operator, operatoren-liste,
  // alte Funktionsnamen: brechen mit „heißt jetzt" oder „gibt es nicht mehr" ab
  c_canvas, loesungsmodus, lücke, non-print-pagebreak, print-pagebreak, qrbox, tasks,
  format-punkte, get-punkte-anzeige, get-punkte-position, reset-aufgaben, show-bewertung, show-erwartungen,
  show-loesung, show-loesung-inline, show-loesungen, show-material, show-materialien, show-offene-loesungen,
  flex-feld, ist-flex-feld, iaword-neu, bin2dec, dec2bin, dec2hex, hex2dec, häufigkeitsanalyse,
  exponentielle_regression, lineare_regression, polynom_regression, potenz_regression, quadratische_regression,
  wurzel_regression,
)
