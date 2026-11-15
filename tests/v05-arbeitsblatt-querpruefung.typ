// Querprüfung der Paketgrenzen: ein Blatt mit Bausteinen aus allen Paketen,
// die arbeitsblatt 0.5.0 weiterreicht (aufgaben, patterns, mathematik, physik,
// informatik, operatoren, insert-a-word, energy-sketch, Fremdnamen).
// erwartet: Kurzschreibweise
// erwartet: Steigung
// erwartet: M2-A
// erwartet: Weg in m 0 2 4 6
// erwartet: Äpfel
// erwartet: Kdoor
// erwartet: berechnen
// erwartet: Merksatz
// erwartet: Zur App
// erwartet: Nach Reset
// erwartet: LOESUNG-A
// erwartet: LUECKENWORT
// erwartet: Erwartungshorizont
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(
  title: [Querprüfung], class: "MA-08", theme: "atlas",
  solutions: "at-end", solutions-pagebreak: "before", points: "all", shortcodes: "all",
  subject: "Mathematik", topic: "Geraden", years: (8,), stage: "sek-1", level: "introduction", kind: "worksheet",
  keywords: ("Gerade",), revision: "2026-11-15",
)
= Kurzschreibweise
+ Kürze $4/8$. #loesung[KURZLOESUNG]
+ Erweitere $1/2$.

#aufgabe(title: [Steigung], method: "pair", label: "steigung")[
  Gegeben ist die Gerade durch $A(0|1)$ und $B(2|5)$.
  #material(caption: [Wertetabelle], label: "m1")[MATERIALTEXT #messwerttabelle(
    datensatz((0, 1, 2, 3), name: "Zeit", unit: "s"),
    berechnung(t => 2 * t, datasets: (datensatz((0, 1, 2, 3), name: "t", unit: "s"),), name: "Weg", unit: "m"),
    messdaten(4, name: "Tempo", unit: "m/s"),
  )]
  #teilaufgabe(workspace: kariert(6))[
    Berechne die Steigung $m$.
    #erwartung(2)[Steigungsdreieck]
    #loesung[LOESUNG-A $m = 2$]
  ]
  #teilaufgabe(workspace: liniert(2), marker: [★])[
    Die Gerade schneidet die $y$-Achse bei #luecke[LUECKENWORT]. Begründe. #lsg[LSGWORT]
    #erwartung(1.5)[Begründung]
  ]
  #teilaufgabe(workspace: kariert(1fr))[Skizziere. #erwartung(3)[Skizze] #loesung[LOESUNG-C #graphen($2 x + 1$, domain: (-2, 2), width: 5cm, height: 4cm)]]
]
#aufgabe(title: [Rechnen], large: false, workspace: liniert(3))[
  #teilaufgaben(columns: 2, items: ([$2 + 3$], [$5 dot 7$]), item-solutions: ([$5$], [$35$]))
  #erwartung(2)[beide]
]
#aufgabe(number: false)[Ohne Nummer. #operator("berechnen") den Wert, #operator("skizzieren", caption: [Skizziere]).
  #loesung[LOESUNG-3]]

#conditional-pagebreak(print: true)
#conditional-pagebreak(solutions-visible: true, weak: true)

== Fachpakete
#graphen($x^2 - 1$, $x$, domain: (x: (-3, 3), y: (-2, 6)),
  areas: ((between: ($x^2 - 1$, $x$), domain: "intersections"),),
  marks: ((at: (0, -1), body: [S], position: "bottom-right"),),
  datasets: ((x: (0, 1, 2), y: (0, 1, 4)),), width: 7cm, height: 5cm)
#graphen(datasets: ((x: datensatz((0, 1, 2), name: $U$, unit: "V"), y: datensatz((0, 10, 20), name: $I$, unit: "A", prefix: "m")),), width: 6cm, height: 4cm)
#let sb = steckbrief("f(0)=2", "f'(0)=0", "f(2)=0", "f'(2)=0")
#sb.math
#kreisdiagramm((("Äpfel", 35), ("Birnen", 45), ("Kirschen", 20)), width: 5cm)
#geogebra-algebra($a = 2$, $b = 3$)
#geogebra-cell($f(x) = x^2$)

#let reg = lineare-regression(x: datensatz((1, 2, 3), name: "t", unit: "s"), y: datensatz((2, 4.1, 5.9), name: "s", unit: "m"))
Regression: #type(reg) #constants.keys().len()

#insert-a-word[Der #iaword[Hund] bellt, die #iaword[Katze] miaut.]
#reset-iaword()
#energy-sketch(([kinetisch], [potenziell]))
C: #caesar("Hallo", key: 3) #vigenere("Hallo", key: "AB") #atbash("abc") #rot13("abc") #dec-to-bin(5) #bin-to-dec("101") #dec-to-hex(255) #hex-to-dec("ff")
#ascii-table()
#text-to-blocks("HALLO WELT")
#haeufigkeitsanalyse("Hallo Welt").chart
#operatoren-liste(subject: "Mathe")

== Kästen und Helfer
#info[Info] #memo(title: [Merksatz])[Merke] #tip[Tipp] #warning[W] #danger[D] #success[S] #error[E] #example[Bsp] #question[Frage] #idea[Idee] #goal[Ziel] #experiment[Exp] #abstract[Abs] #conclusion[Fazit] #notify(title: none)[N]
#minipage(columns: (1fr, 2fr))[links][rechts]
#qty[9.81][m/s^2] #num[3.14] #unit[N/m^2]
#icon-link("https://typst.app")[Zur App]
#qr-box("https://typst.app", width: 3cm)[QR]
#qr-code("https://typst.app", width: 2cm)
#workspace[#kariert(2)]
#stickybox[Zettel] #fa-icon("star")
#canvas({ draw.circle((0, 0), radius: 0.5); plot.plot(size: (2, 2), { plot.add(domain: (0, 1), x => x) }) })

#show-materials()
#show-solutions()
#show-points-table(subtotals: true)
#show-expectations(achieved: true)
#context [P1: #get-points(1) F: #format-points(3) L: #has-solutions() D: #is-print()]
#set-options(points: "subtasks")
#reset-tasks()
#aufgabe[Nach Reset #erwartung(1)[x]]
