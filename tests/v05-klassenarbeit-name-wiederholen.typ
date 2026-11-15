// name-repeat: das Namensfeld steht im Kopf jeder Seite.
// erwartet: Kürzel:
// erwartet: Seite 2 von 2
#import "@schule/klassenarbeit:0.5.0": *
#show: klassenarbeit.with(title: [K], name-repeat: true, name-field: "Kürzel", expectations: false)
#aufgabe[A]
#pagebreak()
#aufgabe[B]
