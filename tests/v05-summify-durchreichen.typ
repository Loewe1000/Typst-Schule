// Werte, die wie in 0.1.0 unverändert an `grid` und `box` gehen.
// erwartet: Anzahl
// erwartet: Einzelmass
// erwartet: Ecke
// erwartet: Danach
#import "@schule/summify:0.5.0": *

#set page(width: 12cm, height: 12cm)
#beside(ratios: 2)[Anzahl][b]
#below(ratios: auto)[Automatisch][b]
#cell-columns(ratios: 1fr)[#cell[Einzelmass]][#cell[b]]
#cell-rows(ratios: 50%)[#cell[a]][#cell[b]]
#topic(height: 2cm, radius: (top-left: 3pt))[#cell[Ecke]]
#section(none)
Danach
