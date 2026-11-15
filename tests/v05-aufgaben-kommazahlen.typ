// Punktsummen aus Kommazahlen: gerundet und mit Dezimalkomma.
// erwartet: \[0,3 BE\]
// erwartet: 3,3 BE
// nicht: 0\.3
// erwartet: GP0: 0
#import "@schule/aufgaben:0.5.0": *
#set-options(points: "all")
#aufgabe(title: [Floats])[
  #teilaufgabe[a #erwartung(0.1)[x] #erwartung(0.2)[y]]
  #teilaufgabe[b #erwartung(3)[z]]
]
#context [GP0: #get-points(0)]
