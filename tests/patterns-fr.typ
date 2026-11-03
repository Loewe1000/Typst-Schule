// kariert/liniert mit rows: 1fr teilen sich den freien Platz (Druck) bzw.
// bekommen 3 cm je fr (Digitalfassung mit automatischer Seitenhöhe).
// erwartet: Teil eins
// erwartet: Teil drei
#import "@schule/arbeitsblatt:0.3.2": *
#show: arbeitsblatt.with(title: [Flexible Felder], class: "X", print: true, workspaces: true, aufgaben-shortcodes: "keine")
#aufgabe(title: [Erste])[
  #teilaufgabe(workspace: kariert(rows: 3))[Fest]
  #teilaufgabe(workspace: kariert(rows: 1fr))[Teil eins]
  #teilaufgabe(workspace: liniert(rows: 2fr))[Teil zwei]
]
#aufgabe(title: [Zweite], workspace: kariert(rows: 1fr))[Teil drei]
