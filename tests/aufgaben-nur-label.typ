// loesungen "nur": @label-Verweise auf Aufgaben brechen nicht ab.
// erwartet: Siehe 1
#import "@schule/aufgaben:0.3.1": *
#set-options((loesungen: "nur"))
#aufgabe(label: <a1>)[Titel][Text #loesung[Siehe @a1]]
#show-offene-loesungen()
