// patterns – karierte und linierte Schreibfelder
//
// Einstiegsdatei: bindet nur die öffentlichen Namen. Die Bausteine `kariert`
// und `liniert` heißen deutsch, alles in den Klammern ist englisch
// (plan-0.4/konvention.md, Anhang A.7).

#import "patterns.typ": flex-area, is-flex-area, kariert, liniert
// Alte Funktionsnamen: jeder Aufruf bricht mit „heißt jetzt" ab.
#import "removed.typ": flex-feld, ist-flex-feld
// Keine zugesicherte Schnittstelle; Dokumente benutzen das Modul nicht.
#import "internal.typ"
