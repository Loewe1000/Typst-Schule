// Alter Parametername, auch über `.with`.
// fehler: summify.summify: `flipped` heißt jetzt `landscape`
#import "@schule/summify:0.5.0": *

#show: summify.with(flipped: false)
Text
