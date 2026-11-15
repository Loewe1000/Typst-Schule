// Beispiel: Zusammenfassung zur Mechanik auf A3 quer.
#import "@schule/summify:0.5.0": *

#show: summify.with(
  title: [Physik – Mechanik],
  theme: "modern-blue",
  // visible: false,   // Lernmodus: Inhalte der Zellen ausblenden
)

#below(ratios: (3fr, 2fr))[
  #beside(ratios: (2fr, 1fr))[
    #topic(title: [Kinematik])[
      #section[Gleichförmige Bewegung]
      #cell[$s = v dot t$]
      #section[Gleichmäßig beschleunigte Bewegung]
      #cell-columns[
        #cell(title: [Weg], align: center)[$s = 1/2 a t^2$]
      ][
        #cell(title: [Geschwindigkeit], align: center)[$v = a dot t$]
      ]
    ]
  ][
    #topic(title: [Dynamik])[
      #section[Newtonsche Gesetze]
      #cell-rows[
        #cell[Trägheitsprinzip: ohne Kraft keine Beschleunigung]
      ][
        #cell[$F = m dot a$]
      ][
        #cell[Actio = Reactio]
      ]
    ]
  ]
][
  #beside[
    #topic(title: [Arbeit])[
      #cell(title: [Definition])[$W = F dot s dot cos(alpha)$]
    ]
  ][
    #topic(title: [Energie])[
      #cell(title: [kinetisch])[$E_"kin" = 1/2 m v^2$]
      #cell(title: [potenziell])[$E_"pot" = m g h$]
    ]
  ][
    #topic(title: [Impuls])[
      #cell(title: [Definition])[$p = m dot v$]
    ]
  ]
]
