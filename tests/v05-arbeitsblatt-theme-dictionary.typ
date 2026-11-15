// Theme als Dictionary: nur einzelne Schlüssel, der Rest bleibt klassisch.
// erwartet: Aufgabe 1 − Titel
// erwartet: «a\)» Teil
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(title: [D], theme: (subtask: marker => [«#marker»], margin: (bottom: 2cm)))
#aufgabe(title: [Titel])[
  + Teil
]
