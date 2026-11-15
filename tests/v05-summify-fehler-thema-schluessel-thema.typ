// Alter Schlüssel in einem eigenen Thema.
// fehler: summify.set-theme: Schlüssel `typography.base-size` in `theme` heißt jetzt `typography.font-size`
#import "@schule/summify:0.5.0": *

#let alt = themes.default
#let _ = alt.typography.insert("base-size", alt.typography.remove("font-size"))
#set-theme(alt)
