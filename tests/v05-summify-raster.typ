// summify 0.5.0: Vorlage, Themenbox, Abschnitt, Zelle und alle Anordnungen.
// erwartet: Physik – Mechanik
// erwartet: Kinematik
// erwartet: Gleichförmige Bewegung
// erwartet: Geschwindigkeit
// erwartet: Actio = Reactio
// erwartet: Ohne Reiter
// erwartet: Impuls
#import "@schule/summify:0.5.0": *

#show: summify.with(
  title: [Physik – Mechanik],
  paper: "a4",
  landscape: true,
  theme: "modern-blue",
  theme-overrides: (colors: (primary: rgb("#e74c3c")), spacing: (cell: 3mm), sizes: (title: (font-size: 10pt))),
)

#below(ratios: (1fr, 1fr), gutter: 3mm)[
  #beside(ratios: (2fr, 1fr))[
    #topic(title: [Kinematik])[
      #section[Gleichförmige Bewegung]
      #cell[$s = v dot t$]
      #cell-columns(ratios: (1fr, 2fr))[
        #cell(title: [Weg])[lang]
      ][
        #cell(title: [Geschwindigkeit], align: center, inset: 1mm)[schnell]
      ]
    ]
  ][
    #topic(title: "Dynamik", fill: green, stroke: 1pt + red, radius: 0pt)[
      #section(fill: yellow, height: 6mm)[Newton]
      #cell-rows(gutter: 1mm)[#cell[Trägheit]][#cell[Actio = Reactio]]
    ]
  ]
][
  #cell-grid(direction: "horizontal", dividers: true, gutter: 5mm)[
    #topic(height: 3cm, width: 80%)[#cell[Ohne Reiter]]
  ][
    #set-theme("warm-sunset")
    #set-theme-overrides(colors: (surface: aqua))
    #topic(title: [Impuls])[#cell(title: "Definition")[$p = m dot v$]]
  ]
]
