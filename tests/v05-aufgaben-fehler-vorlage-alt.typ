// Die früheren Vorlagen-Optionen sind ein Schlüssel von points-format.
// fehler: aufgaben.set-options: `punkte-template-aufgabe` heißt jetzt `points-format: (task: …)`
#import "@schule/aufgaben:0.5.0": *
#set-options(punkte-template-aufgabe: p => [#p])
