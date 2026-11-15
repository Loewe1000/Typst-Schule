// Einstiegsdatei von @schule/arbeitsblatt 0.5.0. Alles wird namentlich
// gebunden; ein Dokument schreibt `#import "@schule/arbeitsblatt:0.5.0": *`.
//
// Die Bausteine heißen deutsch (`arbeitsblatt`, `aufgabe`, `luecke` …), alles
// in den Klammern und alle Aktionen, Abfragen und Helfer sind englisch
// (plan-0.4/konvention.md).

// ── Eigenes ──────────────────────────────────────────────────────────────────
#import "worksheet.typ": arbeitsblatt, arbeitsblatt-einzeln
#import "helpers.typ": (
  canvas, conditional-pagebreak, icon-link, lsg, luecke, minipage, num, qr-box, qr-code, qty, unit, workspace,
)
#import "callouts.typ": (
  abstract, conclusion, danger, error, example, experiment, goal, idea, info, memo, notify, question, success, tip,
  warning,
)
#import "themes.typ": themes
#import "internal.typ": callout-style, subject-accents, subject-names
// Keine zugesicherte Schnittstelle; Dokumente benutzen das Modul nicht.
// klassenarbeit liest hier Scope, Theme und Parametertabelle (Kopf von internal.typ).
#import "internal.typ"

// ── Die acht Fremdnamen (.github/namen/fremdnamen.txt) ───────────────────────
// `canvas`, `qty`, `num`, `unit` sind eigene Wrapper unter dem Fremdnamen.
#import "@preview/cetz:0.4.2": draw
#import "@preview/cetz-plot:0.1.3": plot
#import "@preview/colorful-boxes:1.4.3": stickybox
#import "@preview/fontawesome:0.6.0": fa-icon

// ── Aus den Schwesterpaketen weitergereicht ──────────────────────────────────
#import "@schule/aufgaben:0.5.0": (
  aufgabe, erwartung, format-points, get-points, has-solutions, is-print, loesung, material, reset-tasks, set-options,
  show-expectations, show-materials, show-points-table, show-solutions, teilaufgabe, teilaufgaben,
)
#import "@schule/patterns:0.5.0": flex-area, is-flex-area, kariert, liniert
#import "@schule/insert-a-word:0.5.0": iaword, insert-a-word, reset-iaword
#import "@schule/energy-sketch:0.5.0": energy-sketch
#import "@schule/mathematik:0.5.0": geogebra-algebra, geogebra-cell, graphen, kreisdiagramm, steckbrief
#import "@schule/physik:0.5.0": (
  berechnung, constants, datensatz, exponentielle-regression, lineare-regression, messdaten, messwerttabelle,
  polynom-regression, potenz-regression, quadratische-regression, schaltkreis, wurzel-regression,
)
#import "@schule/informatik:0.5.0": (
  ascii-table, atbash, bin-to-dec, caesar, dec-to-bin, dec-to-hex, haeufigkeitsanalyse, hex-to-dec, rot13,
  text-to-blocks, vigenere,
)
#import "@schule/operatoren:0.5.0": operator, operatoren-liste

// ── Alte Funktionsnamen: brechen mit „heißt jetzt" ab ────────────────────────
#import "removed.typ": c_canvas, loesungsmodus, lücke, non-print-pagebreak, print-pagebreak, qrbox, tasks
// Stubs der Schwesterpakete, deren alte Namen arbeitsblatt bis 0.4.0 weiterreichte.
#import "@schule/aufgaben:0.5.0": (
  format-punkte, get-punkte-anzeige, get-punkte-position, reset-aufgaben, show-bewertung, show-erwartungen,
  show-loesung, show-loesung-inline, show-loesungen, show-material, show-materialien, show-offene-loesungen,
)
#import "@schule/patterns:0.5.0": flex-feld, ist-flex-feld
#import "@schule/insert-a-word:0.5.0": iaword-neu
#import "@schule/informatik:0.5.0": bin2dec, dec2bin, dec2hex, hex2dec, häufigkeitsanalyse
#import "@schule/physik:0.5.0": (
  exponentielle_regression, lineare_regression, polynom_regression, potenz_regression, quadratische_regression,
  wurzel_regression,
)
