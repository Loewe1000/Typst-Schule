// typlace 0.5.0: Sitzplan zeichnen mit den neuen Parameternamen.
// erwartet: Anna
// erwartet: Hans
// erwartet: Pult
// erwartet: Platz-A
// erwartet: Vierteldrehung-ok
// nicht: Platz-I
#import "@schule/typlace:0.5.0": typlace

#typlace(
  "XXXXXX
   TTXXTT
   TTXXTT
   XXXXXX
   XXPPXX",
  names: ("Anna", "Ben", "Clara", "David", "Eva", "Felix", "Greta", "Hans"),
  cell-width: 2cm,
  cell-height: 1.2cm,
  seat-fill: rgb("#d4edda"),
  desk-fill: rgb("#856404"),
  table-fill: none,
  number: true,
)

// Namen über die Plätze hinaus fallen weg; alle Vierteldrehungen gehen durch.
#for winkel in (0deg, 90deg, 180deg, 270deg, -90deg, 360deg) {
  typlace("11.22\n11.22\n..P..", names: range(9).map(i => "Platz-" + "ABCDEFGHI".at(i)), rotation: winkel, cell-width: 1.6cm)
}
Vierteldrehung-ok
