// Alter Schlüssel im Thema: die Meldung nennt den ganzen Weg.
// fehler: summify.summify: Schlüssel `spacing.content` in `theme-overrides` heißt jetzt `spacing.cell`
#import "@schule/summify:0.5.0": *

#show: summify.with(theme-overrides: (spacing: (content: 3mm)))
Text
