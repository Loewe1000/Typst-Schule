// Namen aus den Schwesterpaketen und die acht Fremdnamen sind gebunden.
// erwartet: 5
// erwartet: FDHVDU
// erwartet: Zettel
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(title: [W], print: true)
#aufgabe(workspace: liniert(2))[
  #teilaufgaben(items: ([a], [b]))
  #bin-to-dec("101") #caesar("CAESAR", key: 3)
  #stickybox(width: 3cm)[Zettel] #fa-icon("star")
  #canvas({ draw.rect((0, 0), (1, 1)) })
  #canvas({ plot.plot(size: (2, 2), { plot.add(x => x, domain: (0, 1)) }) })
  #kariert(2)
]
#(type(graphen), type(messwerttabelle), type(datensatz), type(energy-sketch), type(operator), type(insert-a-word)).len()
