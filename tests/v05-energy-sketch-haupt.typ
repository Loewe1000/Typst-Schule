// energy-sketch 0.5.0: Beschriftungen, `labeled: false`, `height`, `gutter`.
// erwartet: kinetisch
// erwartet: potenziell
// erwartet: Anfang
// erwartet: Ende
// nicht: verborgen
#import "@schule/energy-sketch:0.5.0": energy-sketch

#energy-sketch(([kinetisch], [potenziell], $E_"ges"$))

#energy-sketch(("verborgen", "verborgen"), labeled: false)

#energy-sketch(("Anfang", "B", none, "Ende"), height: 5cm, gutter: 6pt)

#energy-sketch.with(height: 2cm)(("X",), labeled: true)
