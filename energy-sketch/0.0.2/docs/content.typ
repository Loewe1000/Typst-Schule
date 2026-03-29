#import "../../../schuldocs/0.1.0/lib.typ": show-example, show-module, show-code

= Über dieses Paket

Das `energy-sketch`-Paket zeichnet Energieniveau-Diagramme für den Physik- und Chemieunterricht.
Jede Energieform erhält eine eigene karierte Spalte mit einer fetten Basislinie und einer Beschriftung darunter —
ideal für Energiebetrachtungen (z. B. kinetische, potentielle und Gesamtenergie), Phasendiagramme
oder Zustandsänderungen.

Das Paket basiert auf *CeTZ* und erzeugt skalierbare Vektorgrafiken, die sich problemlos in Arbeitsblätter
und Klausuren einfügen lassen.

Typische Einsatzgebiete:

- Energieformen vergleichen (Federenergie, Lageenergie, kinetische Energie)
- Energieerhaltungssatz visualisieren
- Lückentext-Aufgaben, bei denen Schülerinnen und Schüler die Balken selbst einzeichnen

= Schnellstart

Das folgende Beispiel erzeugt drei nebeneinanderstehende Energiefelder mit Formel-Beschriftungen:

#show-code[```typ
#import "@schule/energy-sketch:0.0.2": energy-sketch

#energy-sketch(("$E_kin$", "$E_pot$", "$E_ges$"))
```]

Jedes Element des Arrays wird als CeTZ-`content` unter den zugehörigen Balken gesetzt.
Die Beschriftungen können beliebige Typst-Inhalte sein — auch Formeln im Math-Modus.

= Varianten

== Beschriftungen ausblenden

Mit `hide-letters: true` werden die Bezeichnungen ausgeblendet. Das eignet sich für
Lückentext-Aufgaben, bei denen die Schülerinnen und Schüler die Energieform erst selbst
eintragen sollen:

#show-code[```typ
#energy-sketch(
  ("$E_kin$", "$E_pot$", "$E_ges$"),
  hide-letters: true,
)
```]

== Höhe anpassen

Mit dem Parameter `height` wird die Gesamthöhe der Balken gesteuert. Die interne
Rasterschrittweite skaliert automatisch mit, sodass das Raster immer 10 Zeilen umfasst:

#show-code[```typ
#energy-sketch(
  ("$E_kin$", "$E_pot$", "$E_ges$"),
  height: 5cm,
)
```]

== Viele Energieformen

Das Array kann beliebig viele Einträge enthalten. Die Balken werden automatisch
nebeneinander angeordnet:

#show-code[```typ
#energy-sketch((
  "$E_1$", "$E_2$", "$E_3$", "$E_4$", "$E_5$",
), height: 3cm)
```]

== Integration in ein Arbeitsblatt

#show-code[```typ
#import "@schule/arbeitsblatt:0.2.4": *
#import "@schule/energy-sketch:0.0.2": energy-sketch

#show: arbeitsblatt.with(title: "Energieerhaltung", class: "9a")

= Energiebetrachtung am freien Fall

Zeichne die Energiebalken für die drei Zeitpunkte ein.

#align(center)[
  #energy-sketch(
    ("$E_kin$", "$E_pot$", "$E_ges$"),
    height: 5cm,
  )
]

Welche Energieform bleibt konstant? Begründe.
```]

= Parameter

#show-code[```typ
#energy-sketch(
  energy-name,          // array: Beschriftungen der Energiespalten (Typst-Content)
  hide-letters: false,  // bool:  Beschriftungen ausblenden (für Lückentexte)
  height: 3cm,          // length: Gesamthöhe jedes Balkens (Raster hat immer 10 Zeilen)
)
```]

- `energy-name` — *Pflichtparameter.* Ein Array aus Strings oder Content-Werten.
  Jedes Element erzeugt eine eigene karierte Spalte mit Basislinie und Beschriftung.
  Formeln werden im Math-Modus angegeben: `"$E_kin$"`.

- `hide-letters` — Blendet alle Beschriftungen aus. Die Basislinien bleiben sichtbar.
  Standardwert: `false`.

- `height` — Höhe jedes Balkens. Die Rasterbreite einer Zelle ergibt sich automatisch
  als `height / 10`. Standardwert: `3cm`.

= API-Referenz

#show-module(read("../lib.typ"), name: "energy-sketch")
