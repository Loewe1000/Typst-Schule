// Text zwischen zwei Klassenarbeiten verschiebt das Zurücksetzen der
// Seitenzahl nicht auf die vorige Seite.
// erwartet: Seite 1 von 1
// nicht: Seite 2 von
#import "@schule/klassenarbeit:0.4.0": *
#klassenarbeit(title: [KA A], erwartungen: false)[#aufgabe[A]]
= Zwischentext
#klassenarbeit(title: [KA B], erwartungen: false)[#aufgabe[B]]
