// Dreizehn Karten aus zwei Fächern: zwei Bögen, der zweite nur zum Teil
// gefüllt. Die ungerade Kartenzahl zeigt die leere Zelle der letzten Zeile.
#import "@schule/flashcards:0.5.0": card, show-cards

#set page(paper: "a4", margin: 0pt)

// Physik
#card(header: [Physik], footer: [Kinematik])[Was beschreibt die Gleichung $s = v dot t$?][
  Den zurückgelegten Weg $s$ bei gleichförmiger Bewegung mit der
  Geschwindigkeit $v$ in der Zeit $t$.
]
#card(header: [Physik], footer: [Kinematik])[Einheit der Geschwindigkeit?][$[v] = "m/s"$]
#card(header: [Physik], footer: [Dynamik])[Was besagt das zweite Newtonsche Gesetz?][
  $F = m dot a$ — Kraft ist Masse mal Beschleunigung.
]
#card(header: [Physik], footer: [Dynamik])[Einheit der Kraft?][$[F] = "N" = "kg" dot "m/s"^2$]
#card(header: [Physik], footer: [Optik])[Was ist Reflexion?][Zurückwurf von Licht an einer Grenzfläche.]
#card(header: [Physik], footer: [Optik])[Brechungsgesetz?][$n_1 sin(alpha_1) = n_2 sin(alpha_2)$]
#card(header: [Physik], footer: [Elektrik])[Ohmsches Gesetz?][$U = R dot I$]
#card(header: [Physik], footer: [Elektrik])[Einheit des Widerstands?][$[R] = Omega$]
#card(header: [Physik], footer: [Energieformen])[Nenne drei Energieformen.][
  - Kinetische Energie: $E_"kin" = 1/2 m v^2$
  - Potentielle Energie: $E_"pot" = m g h$
  - Thermische Energie: $Q = m c Delta T$
]

// Mathematik
#card(header: [Mathe], footer: [Analysis])[Ableitung von $x^n$?][$n dot x^(n-1)$]
#card(header: [Mathe], footer: [Analysis])[Ableitung von $sin(x)$?][$cos(x)$]
#card(header: [Mathe], footer: [Algebra])[Mitternachtsformel?][
  $x_(1,2) = (-b plus.minus sqrt(b^2 - 4 a c)) / (2a)$
]
#card(header: [Mathe], footer: [Algebra])[Binomische Formel $(a+b)^2$?][$a^2 + 2 a b + b^2$]

#show-cards(paper: "a4")
