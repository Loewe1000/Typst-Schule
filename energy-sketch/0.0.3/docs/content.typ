#import "@schule/schuldocs:0.2.0": show-example, show-module, show-code

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

Import des Pakets:

#show-code[```typ
#import "@schule/energy-sketch:0.0.3": energy-sketch
```]

Das folgende Beispiel erzeugt drei nebeneinanderstehende Energiefelder mit Formel-Beschriftungen:

#show-example(
  rendered: {
    import "../lib.typ": energy-sketch
    energy-sketch(($E_"kin"$, $E_"pot"$, $E_"ges"$))
  },
  source: ```typ
#energy-sketch(($E_"kin"$, $E_"pot"$, $E_"ges"$))
  ```,
  width: 10cm,
)

Jedes Element des Arrays wird als CeTZ-`content` unter den zugehörigen Balken gesetzt.
Die Beschriftungen können beliebige Typst-Inhalte sein — auch Formeln im Math-Modus.

= Varianten

== Beschriftungen ausblenden

Mit `hide-letters: true` werden die Bezeichnungen ausgeblendet. Das eignet sich für
Lückentext-Aufgaben, bei denen die Schülerinnen und Schüler die Energieform erst selbst
eintragen sollen:

#show-example(
  rendered: {
    import "../lib.typ": energy-sketch
    energy-sketch(
      ($E_"kin"$, $E_"pot"$, $E_"ges"$),
      hide-letters: true,
    )
  },
  source: ```typ
#energy-sketch(
  ($E_"kin"$, $E_"pot"$, $E_"ges"$),
  hide-letters: true,
)
  ```,
  width: 10cm,
)

== Höhe anpassen

Mit dem Parameter `height` wird die Gesamthöhe der Balken gesteuert. Die interne
Rasterschrittweite skaliert automatisch mit, sodass das Raster immer 10 Zeilen umfasst:

#show-example(
  rendered: {
    import "../lib.typ": energy-sketch
    energy-sketch(
      ($E_"kin"$, $E_"pot"$, $E_"ges"$),
      height: 5cm,
    )
  },
  source: ```typ
#energy-sketch(
  ($E_"kin"$, $E_"pot"$, $E_"ges"$),
  height: 5cm,
)
  ```,
  width: 12cm,
)

== Abstand zwischen Spalten

Mit `gap` lässt sich zusätzlicher Abstand zwischen den Energiespalten einfügen:

#show-example(
  rendered: {
    import "../lib.typ": energy-sketch
    energy-sketch(
      ($E_"kin"$, $E_"pot"$, $E_"ges"$),
      gap: 6pt,
    )
  },
  source: ```typ
#energy-sketch(
  ($E_"kin"$, $E_"pot"$, $E_"ges"$),
  gap: 6pt,
)
  ```,
  width: 11cm,
)

== Viele Energieformen

Das Array kann beliebig viele Einträge enthalten. Die Balken werden automatisch
nebeneinander angeordnet:

#show-example(
  rendered: {
    import "../lib.typ": energy-sketch
    energy-sketch((
      $E_1$, $E_2$, $E_3$, $E_4$, $E_5$,
    ), height: 3cm)
  },
  source: ```typ
#energy-sketch((
  $E_1$, $E_2$, $E_3$, $E_4$, $E_5$,
), height: 3cm)
  ```,
  width: 14cm,
)

== Labels als Typst-Content

Beschriftungen dürfen nicht nur Strings sein, sondern beliebiger Typst-Content:

#show-example(
  rendered: {
    import "../lib.typ": energy-sketch
    energy-sketch((
      [*kinetisch*],
      [potenziell],
      [$E_("ges")$],
    ))
  },
  source: ```typ
#energy-sketch((
  [*kinetisch*],
  [potenziell],
  [$E_("ges")$],
))
  ```,
  width: 10cm,
)

== Integration in ein Arbeitsblatt

#show-code[```typ
#import "@schule/arbeitsblatt:0.2.4": *
#import "@schule/energy-sketch:0.0.3": energy-sketch

#show: arbeitsblatt.with(title: "Energieerhaltung", class: "9a")

= Energiebetrachtung am freien Fall

Zeichne die Energiebalken für die drei Zeitpunkte ein.

#align(center)[
  #energy-sketch(
    ($E_"kin"$, $E_"pot"$, $E_"ges"$),
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
  gap: 0pt,             // length: Abstand zwischen zwei Energiespalten
)
```]

- `energy-name` — *Pflichtparameter.* Ein Array aus Strings oder Content-Werten.
  Jedes Element erzeugt eine eigene karierte Spalte mit Basislinie und Beschriftung.
  Formeln werden im Math-Modus angegeben, zum Beispiel mit #raw("$E_\"kin\"$").

- `hide-letters` — Blendet alle Beschriftungen aus. Die Basislinien bleiben sichtbar.
  Standardwert: `false`.

- `height` — Höhe jedes Balkens. Die Rasterbreite einer Zelle ergibt sich automatisch
  als `height / 10`. Standardwert: `3cm`.

- `gap` — Abstand zwischen zwei Energiespalten. Standardwert: `0pt`.

= Robustes Verhalten

Das Paket validiert die wichtigsten Eingaben früh:

- `energy-name` muss ein nicht-leeres Array sein.
- `hide-letters` muss ein boolescher Wert sein.
- `height` muss eine positive Länge sein.
- `gap` muss eine nicht-negative Länge sein.

Zusätzlich werden Abstände, Strichstärken und Schriftgröße intern aus der Höhe abgeleitet.
Dadurch bleiben kleine und große Varianten konsistenter als bei fest verdrahteten Werten.

= API-Referenz

#show-module(read("../lib.typ"), name: "energy-sketch")
