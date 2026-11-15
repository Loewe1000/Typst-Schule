// klausurboegen – Klausurbögen im A3-Querformat
//
// Einstiegsdatei: bindet nur die öffentlichen Namen. Der Baustein
// `klausurboegen` heißt deutsch wie sein Paket, alles in den Klammern ist
// englisch (plan-0.4/konvention.md, Anhang A.6).

#import "klausurboegen.typ": klausurboegen
// Alte Funktionsnamen: jeder Aufruf bricht mit einer Meldung ab.
#import "removed.typ": bogen-seiten, klausurbogen-arbeit, klausurbögen
// Keine zugesicherte Schnittstelle; Dokumente benutzen das Modul nicht.
#import "internal.typ"
