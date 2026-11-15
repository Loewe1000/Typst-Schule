// Alter Schlüssel zwei Ebenen tief, über `set-theme-overrides`.
// fehler: summify.set-theme-overrides: Schlüssel `sizes.title.text` heißt jetzt `sizes.title.font-size`
#import "@schule/summify:0.5.0": *

#set-theme-overrides(sizes: (title: (text: 12pt)))
