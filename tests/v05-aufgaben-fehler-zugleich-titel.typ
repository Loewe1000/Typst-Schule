// Alter und neuer Parametername eines Bausteins im selben Aufruf.
// fehler: aufgaben.aufgabe: `titel` (alt) und `title` (neu) zugleich – nur `title` schreiben
#import "@schule/aufgaben:0.5.0": *
#aufgabe(titel: [A], title: [B])[Text]
