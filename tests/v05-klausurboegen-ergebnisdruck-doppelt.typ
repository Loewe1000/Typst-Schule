// klausurboegen 0.5.0: Ergebnisdruck mit gleichnamigen Teilaufgaben ("A2 c)"
// zweimal, wie aus iDoceo, wenn c) aufgeteilt bewertet wurde). Die Teile werden
// zu einer Spalte addiert; Summenspalten ("A2" mit "6.00  6/7") fallen weg.
// erwartet: mögliche Punkte +5 +2 +2 +3 +12
// erwartet: erreichte Punkte +4 +2 +1,5 +1,5 +9
// erwartet: erreichte Punkte +0 +0 +0 +2 +2
// erwartet: a\) +b\) +c\)
// nicht: d\)
#import "@schule/klausurboegen:0.5.0": klausurboegen

#klausurboegen(
  title: "Physik",
  stage: "sek-1",
  overprint: true,
  results: (
    ("Name", "Note", "A1", "A2", "A2 a)", "A2 b)", "A2 c)", "A2 c)", ""),
    ("A", "1", "5", "7.00  7/7", "2", "2", "1", "2", ""),
    ("Mia", "2", "4", "5.00  5/7", "2", "1.5", "1", "0.5", ""),
    ("Tom", "6", "", "2.00  2/7", "", "", "", "2", ""),
  ),
)
