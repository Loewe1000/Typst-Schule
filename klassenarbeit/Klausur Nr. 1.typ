#import "@schule/klassenarbeit:0.0.3": *
#import "@preview/metro:0.1.0": *
#import "@schule/random:0.0.1": *

#show: klassenarbeit.with(
  title: "Physikklausur Nr. 1",
  subtitle: "Elektrische Felder & Kondensatorentladung",
  class: "PH1",
  date: "06.10.2023",
  teacher: "SLZ",
  font-size: 10pt,
  logo: image("logo.svg"),
  stufe: "II",
  table: (
    ("Hinweise", [Die Lösungen sind nachvollziehbar und in einer sauberen äußeren Form anzufertigen. Skizzen werden mit Lineal und Bleistift angefertigt. Wenn nicht anders angegeben, werden Ergebnisse auf zwei Nachkommastellen angegeben.]),
    ("Hilfsmittel", "Ti Nspire & Das große Tafelwerk 2.0"),
    ("Bearbeitungszeit","ca. 90 Minuten")
  ),
  loesungen: "keine"
)

#let _teilaufgabe = teilaufgabe
#let teilaufgabe( ..args ) = {
  _teilaufgabe(numb:"klausur", ..args.pos(), ..args.named())
}

#aufgabe(large: true, titel:"Elektrisches Feld zwischen zwei Punktladungen")[
In dieser Aufgabe geht es um die Darstellung elektrischer Felder mithilfe von Feldlinien, sowie das elektrische Feld zwischen zwei Punktladungen (Coulomb-Gesetz).

#teilaufgabe[
In Material @m1 sind zwei unterschiedlich geladene Körper abgebildet.

Skizzieren Sie möglichst vollständig in die Abbildung das entsprechende Feldlinienbild.
#erwartung("zeichnet senkrecht auf die Oberfläche treffende Feldlinien (1) vom Plus- zum Minuspol (0,5) mit nach außen hin abnehmender Dichte (0,5).", 2)
]

#teilaufgabe[
Begründen Sie, dass sich zwei Feldlinien nicht kreuzen dürfen.
#erwartung("begründet, dass Feldlinien die Richtung der Kraft auf eine positive Probeladung angeben (1). Diese muss eindeutig sein (1).", 2)
]

#teilaufgabe[
Zwei elektrischen Ladungen befinden sich in einem Abstand von $r= qty(2, e:0, "cm")$ voneinander. Die beiden Ladungen wirken aufeinander eine Kraft von $F_upright(C) = qty(3.4, e:0, "mN")$ aus. Die erste Ladung hat einen Betrag von $q_1 = qty(12, e:0, "nC")$.

Berechnen Sie den Betrag $q_2$ der zweiten Ladung.
#erwartung("gibt die Gleichung für die Coulumb-Kraft richtig an (1), stellt sie passend um (2) und setzt die gegebenen Werte passend ein (0,5), um den Betrag der Ladung zu erhalten (0,5).", 4)
]

#teilaufgabe(use:false)[
Begründen Sie, dass eine Halbierung des Abstands zwischen zwei punktförmigen Ladungen eine Vervierfachung der Kraft zwischen beiden Ladungen bewirkt.
#erwartung([setzt für den Radius $1/2r$ in die Formel der Coulomb-Kraft ein und erhält $4 dot F_upright(C)$.],2)
]
]

#aufgabe(large: true, number:true, titel: "Kondensatorentladung")[
Ein Kondensator mit einer Kapazität $C$ wird mit einer Spannung von $U = qty(4, e:0, "V")$ aufgeladen und anschließend über einen Widerstand $R = qty(33, e:0, "k ohm")$ entladen. 
Dabei wird die Kondensatorspannung $U(t)$ abhängig von der Zeit $t$ mit einem Messverstärker gemessen.

#teilaufgabe(use: false)[
Zeichnen Sie die Schaltskizze eines Versuchsaufbaus, in dem die Messung der Spannung am Kondensator bei der beschriebenen Kondensatorentladung möglich ist.
#erwartung([zeichnet die 4 Bauteile (2) (Spannungsquelle, Widerstand, Kondensator, Messgerät)so, dass Spannungsquelle, Widerstand und Kondensator in Reihe (0,5) und das Messgerät parallel zum Kondensator (0,5) geschaltet sind.],3)
]

#teilaufgabe[
Die Messdaten des Entladevorgangs sind in @tabellekondensator dargestellt.

Ermitteln Sie aus dem $t$-$U$-Diagramm möglichst genau die Halbwertszeit $t_(1/2)$ für diesen Entladevorgang,\ wobei Sie Ihren Lösungsweg geeignet dokumentieren.
#erwartung([ermittelt den korrekten Wert der Halbwertszeit (1) möglichst genau durch Mittelwertbildung über mehrere Halbwertzeiten (1) und dokumentiert sein/ihr Vorgehen dabei nachvollziehbar, z. B. durch Einzeichnen des Punktes $(3t_(1/2) | U_0/8)$ (1).],3)
]

#teilaufgabe[
In einem weiteren Versuch wurde die Spannung $U$ beim Aufladen des Kondensators variiert und jeweils die auf dem Kondensator gespeicherte Ladung $Q$ gemessen.
Die Messdaten sind in @kapazität-messwerte dargestellt.

Ermitteln Sie aus den Messdaten mithilfe des Taschenrechners einen funktionalen Zusammenhang $Q(U)$, wobei Sie Ihr Vorgehen in der im Unterricht vereinbarten Weise dokumentieren.
#erwartung([führt eine lineare Regression mit geeigneter Dokumentation durch (5).], 5)
]
]

#teilaufgabe[
Geben Sie die Kapazität $C$ des Kondensators an.
#erwartung([liest aus dem ermittelten Zusammenhang $U(Q)$ die Proportionalitätskonstate ab (1).], 1)
]

#aufgabe(large: true, number:true, titel: [Bewegte Ladung im Feld])[
Durch eine kleine Öffnung A gelangen Elektronen mit vernachlässigbarer Anfangsgeschwindigkeit in einen Plattenkondensator (vgl. @teilchen-im-kondensator).
Im homogenen Feld werden sie zur gegenüberliegenden Öffnung B beschleunigt.
Zwischen den Platten liegt eine Spannung von $U = qty(5.0, e:0, "kV")$, der Plattenabstand beträgt $d = qty(10.0, e:0, "cm")$.

#teilaufgabe[
Berechnen Sie die elektrische Kraft $F_"el"$ des Feldes des Plattenkondensators, die auf ein Elektron wirkt.//Feldstärke $accent(E,arrow)$ des elektrischen Felds des Plattenkondensators.
#erwartung([berechnet die elektrische Kraft (0,5) mit $F_"el"= Q dot accent(E,arrow) = e dot accent(E,arrow)$ (1) wobei $accent(E,arrow) = U/d$ (1) mit den richtig eingesetzten Größen (0,5) .],3)
]

#teilaufgabe[
Leiten Sie für die Geschwindigkeit $v_B$ der Elektronen beim Verlassen des Kondensators folgende Gleichung her:
$v_B = sqrt((2 dot e dot U)/m_e)$, wobei $e$ die Ladung des Elektrons und $m_e$ seine Masse ist.
#erwartung([stellt über die Energieerhaltung $E_"pot" = E_"kin"$ (1) mit $E_"pot" = e dot U$ (0,5) und $E_"kin" = 1/2 dot m dot v^2$ (0,5) die geforderte Gleichung (1) auf.], 3)

]
#teilaufgabe[
Zeigen Sie mithilfe einer Einheitenkontrolle, dass die Berechnung mit der angegebenen Formel die Einheit $unit("m/s")$ ergibt.
#erwartung([setzt die Einheiten der Größen $e$, $U$ und $m_e$ in die Formel ein (1) und zeigt durch Umformen (2), dass diese $unit("m/s")$ ergeben.], 3)
]

#teilaufgabe[
Bestimmen Sie die Geschwindigkeit $v_B$, mit der die Elektronen durch Öffnung B treten.
#erwartung([setzt die gegebenen Größen in die Formel ein (1) und berechnet die Geschwindigkeit $v_B$ (1).],2)
]

#teilaufgabe[
Beschreiben Sie, wie sich die Geschwindigkeit $v_B$ verändert, wenn...
#enum(numbering: "i)",[...die Spannung $U$ vervierfacht wird.],[...der Plattenabstand $d$ halbiert wird.])

#erwartung([beschreibt (mithilfe der Gleichung), dass bei Vervierfachung der Spannung die Geschwindigkeit verdoppelt wird (1) und dass ein Verändern des Plattenabstands keine Auswirkungen auf die Geschwindigkeit hat (1).],2)
]
]

#pagebreak()

= Anhang
#figure(numbering: "1", caption:"Abbildung unterschiedlich geladener Körper")[
  #canvas({
    import draw: *
    rect((0,0),(14,5), stroke: 0pt)
    let a = (5,3)
    let b = (9,3)
    let c = (8,3)

    circle(a, radius: 0.5cm, fill: white)
    circle(b, radius: 0.5cm, fill: white, name:"b")
    
    line(c, (element: "b", point: c, solution: 1), b, (element: "b", point: c, solution: 2), c, fill: white, stroke: (thickness: 0pt))
    line((element: "b", point: c, solution: 2), c, (element: "b", point: c, solution: 1))
    content(a, [*$+$*])
    content(b, [*$-$*])
  })
] <m1>

#v(5mm)
#line(length: 100%)
#v(5mm)

#let zeit = range(0,65, step: 5)

#let kapazität = 0.75*calc.pow(10,-3)
#let widerstand = 33*calc.pow(10,3)
#let spannung = zeit.map(t => calc.round(4 * calc.pow(calc.e,(-((rand(42*t) - 0.5)+t))/(kapazität * widerstand)), digits: 2))

#figure(numbering: "1", caption: [Spannung $U(t)$ beim Entladen])[
  /*#tablex(columns:(1fr,) * (zeit.len() + 1), align:center,
    [$t$ in s], ..zeit.map(x => $#x$),
    [$U$ in V], ..spannung.map(x => $#x$)
  )*/

  #canvas(length: 1cm, {
    plot.plot(size: (12, 8),
      axis-style: "school-book",
      x-tick-step: 5,
      y-tick-step: 0.5,
      x-label:[$t$ in s],
      y-label:[$U$ in V],
      x-min: 0,
      y-min: 0,
      y-max: 4.1,
      x-grid: "both",
      y-grid: "both",
      {
        plot.add(
          style:(stroke: blue+0pt),
          mark: "x",
          mark-size: 0.2,
          domain: (0, calc.max(zeit)),
          zeit.enumerate().map(key => {
            (key.at(1), if key.at(1) == 50 {0.5} else {spannung.at(key.at(0))})
          })
        )
      }
    )
  })
] <tabellekondensator>

#line(length: 100%)
#v(2mm)

#let spannung = range(1,11, step: 1)
#let ladung = spannung.map(U => calc.round(0.1 * (rand(U * 42) - 0.5) + U * kapazität * calc.pow(10,3), digits: 2))

#figure(numbering: "1", caption: [gespeicherte Ladung auf dem Kondensator in Abhängigkeit der angelegten Spannung])[
  #tablex(columns:(1fr,) * (spannung.len() + 1), align:center,
    [$U$ in V], ..spannung.map(x => $#x$),
    [$Q$ in #unit("mC")], ..ladung.map(x => $#x$)
  )
] <kapazität-messwerte>

#line(length: 100%)
#v(2mm)

#figure(numbering: "1", caption: [Beschleunigte Elektronen im Plattenkondensator])[
  #centering[
    #image("teilchen_im_kondensator_2.svg", width: 42.5%)
  ]
] <teilchen-im-kondensator>