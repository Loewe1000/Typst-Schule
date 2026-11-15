// Alter Name mit einem Wert, der kein Schalter ist: die Meldung bleibt die des Pakets.
// fehler: summify.summify: `hide-content` heißt jetzt `visible`
#import "@schule/summify:0.5.0": *

#show: summify.with(hide-content: none)
Text
