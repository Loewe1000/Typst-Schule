#import "@schule/klassenarbeit:0.1.1": *

#show: klassenarbeit.with(
  title: [Klassenarbeit],
  subtitle: [Untertitel],
  class: [10a],
  date: [01.01.2025],
  teacher: [SLZ],
  punkte: "alle",
  erwartungen: true,
)

#aufgabe(title: [Rechnen])[
  Bearbeiten Sie die folgenden Teilaufgaben:

  #teilaufgabe[
    Berechnen Sie $2 + 3$.
    #erwartung(1, [Rechenweg korrekt])
    #loesung[$2 + 3 = 5$]
  ]

  #teilaufgabe[
    Berechnen Sie $5 times 7$.
    #erwartung(1, [Ergebnis korrekt])
    #loesung[$5 times 7 = 35$]
  ]
]

#aufgabe(title: [Gleichungen lösen])[
  Lösen Sie die Gleichung $2x + 5 = 13$.
  
  #erwartung(2, [Äquivalenzumformungen korrekt])
  #erwartung(1, [Endergebnis korrekt])
  
  #loesung[
    $2x + 5 = 13$\
    $2x = 8$\
    $x = 4$
  ]
]
