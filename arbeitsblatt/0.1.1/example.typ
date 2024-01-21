#import "@schule/arbeitsblatt:0.1.0": *

#show: arbeitsblatt.with(
  title: "Die Affen aus dem Knusiland I - Codierung",
  class: "IF-11",
  author: "Lukas Köhl",
  loesungen: "sofort",
)

#minipage(
  columns: (2fr, 1.4fr),
  spacing: 16pt,
  align: top,
)[
  Informationen jeglicher Art werden ständig von einem Sender über einen
  Kommunikationskanal verschickt und von einem Empfänger erhalten. Ein einfaches
  Beispiel ist Sprechen. Der Rednersdfsdf formuliert eine Information mit Worten,
  welche durch die Luft weitergeleitet werden, und ein Empfänger kann diese mit
  seinen Ohren wahrnehmen. Doch was ist, wenn die Entfernung zum Hören zu groß
  ist? Stellen wir uns vor, zwei Affenstämme leben auf zwei Seiten einer tiefen
  Schlucht. Um miteinander zu kommunizieren, stehen ihnen ein großes, grünes
  Bananenblatt und ein großes, braunes Stück Baumrinde zur Verfügung, die sie wie
  zwei Flaggen hochhalten wollen.
][#image("assets/apes.jpeg", width: 100%)]

#aufgabe(
  large: false,
)[
  #teilaufgabe[
    Entwickle mit einem Partner eine Möglichkeit, die verschiedenen, in der unten
    abgebildeten Codeworttabelle enthaltenen Begriffe durch Signale mit der Rinde
    (R) und dem Bananenbatt (B) darzustellen. Notiere deine Überlegungen.

    Es ist nur zulässig, entweder das Blatt oder die Rinde zu heben und nicht beide
    gleichzeitig.

    #table(
      columns: (1.4fr, 1fr,) * 4,
      inset: 10pt,
      align: center + horizon,
      stroke: 0.5pt,
      fill: (col, _) => if calc.even(col) { luma(240) } else { white },
      "Gefahr",
      "",
      "Tag",
      "",
      "Angriff",
      "",
      "Alphatier",
      "",
      "Feuer",
      "",
      "Nacht",
      "",
      "Waffe",
      "",
      "Baum",
      "",
      "Wasser",
      "",
      "Morgen",
      "",
      "Nachricht",
      "",
      "Ast",
      "",
      "Hilfe",
      "",
      "Abend",
      "",
      "Schlucht",
      "",
      "Läuse",
      "",
      "Banane",
      "",
      "Feind",
      "",
      "Westen",
      "",
      "Osten",
    )
  ]

  #teilaufgabe[Codiert mit Hilfe eurer Codeworttabelle eine selbst gewählte Nachricht und
    übergebt diese einer anderen Partnergruppe. Diese soll die empfangene Nachricht
    eurer Gruppe übersetzen, auch decodieren genannt.

    Tauscht euch anschließend mit der anderen Partnergruppe über eure Erfolgschancen
    aus.

    #loesung[
      Hier ist eine Lösung
    ]
  ]

  #teilaufgabe[Diskutiert die folgenden Szenarien hinsichtlich möglicher Schwierigkeiten eurer
    Codierung:

    + Ein Affe möchte zusätzlich mit einem weiteren Affen von der anderen Seite
      kommunizieren.
    + Entlang der ganzen Schlucht stehen überall Affen, die auf Entfernung ständig mit
      ihren Blättern kommunizieren. Nun kommt ein angreifender Stamm und der einzige
      Wächter-Affe am Waldrand möchte dies schnell dem Alphatier melden.
    + Ein Spion observiert die Schlucht über einige Zeit. Er sieht, wie Blätter
      geschwenkt werden und andere reagieren.
    + Das Alphatier sieht von der anderen Seite der Schlucht Hilfesignale kommen.
      Allerdings kann sie nicht erkennen, wer diese sendet.
    + Beim Senden einer Nachricht wird ein Teil der Nachricht durch Rauch von einem
      Waldbrand überdeckt und es sind einzelne Zeichen nicht zu erkennen.]
]

#pagebreak()

#kariert(rows: 2)
dsdf
#kariert(rows: 2, grid-size: 1cm)

ssdf
#liniert(rows: 2)
sdfsdf

Fill the blanks:
#insert-a-word()[
  dfghfghdfgh #iaword("sdf") sdfsdfh #iaword("dvbssdf")
]

#energy-sketch(("H", "B", "G"))

#minipage(columns: (1fr,) * 4)[
  #energy-sketch(("H", "B", "G"))
][
  #energy-sketch(("H", "B", "G"), hide-letters: true)
][
  #energy-sketch(("H", "B", "G"), hide-letters: true)
][
  #energy-sketch(("H", "B", "G"), hide-letters: false)
]

#lorem(50)

#pagebreak()
#figure(
  image("assets/apes.jpeg", width: 3cm),
  caption: "Bild von Affen dfsnbdf sd\nsdfsdfsd",
  numbering: none,
)<test>

#lorem(50)

#kariert(
  rows: 4,
  grid-size: 2cm,
  height: 8cm,
  items: ("dsfsd", "sdfj"),
  line-stroke: (thickness: 7pt),
)

#tasks(tasks: ("ads", "sdf", "sdf"))

#qrbox("www.google.de", "Link zur Website", width: 3cm)

#qrbox("www.eissdgsdfsdfsdfsfdd.de", "Link zur Website", width: 3cm)

#icon-link("sdf", "sdf")