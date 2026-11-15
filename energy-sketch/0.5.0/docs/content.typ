#import "@schule/schuldocs:0.3.1": show-example, show-module, show-code

= Über dieses Paket

Das `energy-sketch`-Paket zeichnet Energiekonten für den Physik- und Chemieunterricht.
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
#import "@schule/energy-sketch:0.5.0": energy-sketch
```]

Das folgende Beispiel erzeugt drei nebeneinanderstehende Energiefelder mit Formel-Beschriftungen:

#show-example(
  rendered: {
    import "../src/lib.typ": energy-sketch
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

Mit `labeled: false` werden die Bezeichnungen ausgeblendet. Das eignet sich für
Lückentext-Aufgaben, bei denen die Schülerinnen und Schüler die Energieform erst selbst
eintragen sollen:

#show-example(
  rendered: {
    import "../src/lib.typ": energy-sketch
    energy-sketch(
      ($E_"kin"$, $E_"pot"$, $E_"ges"$),
      labeled: false,
    )
  },
  source: ```typ
#energy-sketch(
  ($E_"kin"$, $E_"pot"$, $E_"ges"$),
  labeled: false,
)
  ```,
  width: 10cm,
)

== Höhe anpassen

Mit dem Parameter `height` wird die Gesamthöhe der Balken gesteuert. Die interne
Rasterschrittweite skaliert automatisch mit, sodass das Raster immer 10 Zeilen umfasst:

#show-example(
  rendered: {
    import "../src/lib.typ": energy-sketch
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

Mit `gutter` lässt sich zusätzlicher Abstand zwischen den Energiespalten einfügen:

#show-example(
  rendered: {
    import "../src/lib.typ": energy-sketch
    energy-sketch(
      ($E_"kin"$, $E_"pot"$, $E_"ges"$),
      gutter: 6pt,
    )
  },
  source: ```typ
#energy-sketch(
  ($E_"kin"$, $E_"pot"$, $E_"ges"$),
  gutter: 6pt,
)
  ```,
  width: 11cm,
)

== Viele Energieformen

Das Array kann beliebig viele Einträge enthalten. Die Balken werden automatisch
nebeneinander angeordnet:

#show-example(
  rendered: {
    import "../src/lib.typ": energy-sketch
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
    import "../src/lib.typ": energy-sketch
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
#import "@schule/arbeitsblatt:0.5.0": arbeitsblatt
#import "@schule/energy-sketch:0.5.0": energy-sketch

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
  labels,          // array:  Beschriftungen der Spalten (Inhalt, Text oder none)
  labeled: true,   // bool:   Beschriftungen setzen; false lässt nur die Linien stehen
  height: 3cm,     // length: Höhe des Rasters (immer 10 Zeilen)
  gutter: 0pt,     // length: Abstand zwischen zwei Spalten
)
```]

- `labels` — *Pflichtparameter.* Ein Array aus Texten oder Inhalten, je Spalte ein Eintrag.
  Jeder Eintrag erzeugt eine eigene karierte Spalte mit Linie und Beschriftung; `none` lässt
  eine einzelne Spalte unbeschriftet. Formeln werden im Math-Modus angegeben, zum Beispiel
  mit #raw("$E_\"kin\"$").

- `labeled` — Setzt die Beschriftungen. Mit `false` bleiben nur die Linien stehen.
  Vorgabe: `true`.

- `height` — Höhe des Rasters. Die Höhe einer Rasterzelle ist `height / 10`, eine Spalte
  ist vier Zellen breit. Vorgabe: `3cm`.

- `gutter` — Abstand zwischen zwei Spalten. Vorgabe: `0pt`.

= Fehlermeldungen

Falsche Eingaben brechen mit einer deutschen Meldung im Format
`energy-sketch.energy-sketch: Befund – Abhilfe` ab:

- `labels` muss ein Array mit mindestens einem Eintrag sein.
- `labeled` muss `true` oder `false` sein.
- `height` muss eine Länge größer als `0pt` sein.
- `gutter` muss eine Länge von mindestens `0pt` sein.
- Unbekannte Parameter werden abgelehnt; bei einem Tippfehler nennt die Meldung den
  gemeinten Namen.

#show-code[```
energy-sketch.energy-sketch: unbekannter Parameter `guter` – meintest du `gutter`?
energy-sketch.energy-sketch: `height` erwartet eine Länge, bekam `3` (int) – zum Beispiel `3cm`
```]

Abstände, Strichstärken und Schriftgröße werden aus der Höhe abgeleitet. Dadurch bleiben
kleine und große Varianten im gleichen Verhältnis.

= Umstieg auf 0.5.0

Version 0.5.0 ändert nur Namen; ein Dokument sieht nach dem Umstieg genauso aus wie vorher.
Alte Namen brechen mit einer Meldung ab, die den neuen nennt.

#table(
  columns: (1.2fr, 1fr, 1.6fr),
  align: left,
  table.header([*bisher (0.0.3)*], [*jetzt (0.5.0)*], [*Hinweis*]),
  [`energy-name` (erstes Argument)], [`labels` (erstes Argument)], [Nur der Name in der Dokumentation; der Aufruf bleibt gleich.],
  [`hide-letters: true`], [`labeled: false`], [Der Schalter ist gewendet.],
  [`hide-letters: false`], [`labeled: true`], [Das ist die Vorgabe und kann entfallen.],
  [`gap: 6pt`], [`gutter: 6pt`], [],
  [`height: 3cm`], [`height: 3cm`], [unverändert],
  [`canvas`, `draw`], [entfallen], [Wurden bisher bei `import …: *` aus CeTZ mitgeliefert. Wer sie braucht, importiert sie aus `@preview/cetz:0.5.2`.],
  [`_resolve-layout`, `_draw-energy-column` und die übrigen Namen mit Unterstrich], [`internal.…`], [Interne Helfer, keine zugesicherte Schnittstelle.],
)

#show-code[```typ
// bisher
#import "@schule/energy-sketch:0.0.3": *
#energy-sketch(($E_"kin"$, $E_"pot"$), hide-letters: true, gap: 6pt)

// jetzt
#import "@schule/energy-sketch:0.5.0": energy-sketch
#energy-sketch(($E_"kin"$, $E_"pot"$), labeled: false, gutter: 6pt)
```]

= API-Referenz

#show-module(read("../src/energy-sketch.typ"), name: "energy-sketch")
