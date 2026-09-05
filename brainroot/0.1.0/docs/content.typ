#import "@schule/schuldocs:0.2.0": show-example, show-module, show-code

= Über dieses Paket

Eine Mindmap, wie sie an der Tafel entsteht: ein Begriff in der Mitte, die
Oberbegriffe rechts und links daneben, dahinter die Beispiele. `brainroot`
setzt so eine Karte aus einer verschachtelten Liste. Jeder Ast bekommt eine
Farbe, die er bis in seine Blätter weitergibt; die Kästen sind in einem
helleren Ton derselben Farbe gefüllt, die Verbindungen laufen als weiche
Kurven.

Das Paket basiert auf *CeTZ*. Die Kästen werden gemessen, deshalb passen
sie sich der Schrift des umgebenden Dokuments an.

= Schnellstart

#show-code[```typ
#import "@schule/brainroot:0.1.0": brainroot, branch
```]

Die einfachste Eingabe ist eine Liste: jeder Punkt wird zu einem Knoten,
eingerückte Punkte zu seinen Kindern.

#show-example(
  rendered: {
    import "../lib.typ": *
    set text(size: 8pt)
    brainroot(title: [Energiearten])[
      - Bewegungsenergie
        - Kinetische Energie
        - Windenergie
      - Spannenergie
        - Dehnungsenergie
      - Wärmeenergie
        - Feuerenergie
      - Höhenenergie
        - Schwerkraftenergie
        - Gewichtenergie
    ]
  },
  source: ```typ
#brainroot(title: [Energiearten])[
  - Bewegungsenergie
    - Kinetische Energie
    - Windenergie
  - Spannenergie
    - Dehnungsenergie
  - Wärmeenergie
    - Feuerenergie
  - Höhenenergie
    - Schwerkraftenergie
    - Gewichtenergie
]
  ```,
  width: 100%,
)

Wer einen Ast genauer bestimmen will, schreibt ihn als `branch(label, ..kinder)`.
Ein Kind ist dann entweder Content, also ein Blatt, oder wieder ein
`branch(...)`. Liste und `branch`-Aufrufe dürfen nebeneinander stehen; ohne
`title` gilt das erste Argument als Wurzel.

= Seiten und Farben

Ohne Angabe verteilt `brainroot` die Äste selbst: die ersten gehen nach
rechts, bis die rechte Seite etwa halb so hoch ist wie alle Äste zusammen,
die übrigen nach links. `side: left` oder `side: right` legt einen Ast fest,
`color` gibt ihm eine eigene Farbe statt der nächsten aus der Palette.

#show-example(
  rendered: {
    import "../lib.typ": *
    set text(size: 8pt)
    brainroot([Fotosynthese], root-fill: green.lighten(50%), max-width: 3cm,
      branch([Lichtreaktion], branch([Fotolyse], [Wasser wird gespalten]), [ATP], side: right),
      branch([Dunkelreaktion], [Calvin-Zyklus], [Glucose], color: purple),
      branch([Voraussetzungen], [Licht], [Wasser], [CO₂], side: left),
    )
  },
  source: ```typ
#brainroot([Fotosynthese], root-fill: green.lighten(50%), max-width: 3cm,
  branch([Lichtreaktion], branch([Fotolyse], [Wasser wird gespalten]), [ATP], side: right),
  branch([Dunkelreaktion], [Calvin-Zyklus], [Glucose], color: purple),
  branch([Voraussetzungen], [Licht], [Wasser], [CO₂], side: left),
)
  ```,
  width: 100%,
)

= Anordnungen

`layout` bestimmt, wie die Äste um die Wurzel liegen. `both` ist die
zweiseitige Karte von oben, `right` und `left` legen alles auf eine Seite.
`down` und `up` setzen einen Baum von oben nach unten oder umgekehrt, wie ein
Organigramm; `radial` verteilt die Äste im Kreis, die Teilbäume wachsen
waagerecht nach außen.

#let karte = [
  - Bewegungsenergie
    - Kinetische Energie
    - Windenergie
  - Spannenergie
    - Dehnungsenergie
  - Wärmeenergie
    - Feuerenergie
  - Höhenenergie
    - Schwerkraftenergie
    - Gewichtenergie
]

#show-example(
  rendered: {
    import "../lib.typ": *
    set text(size: 8pt)
    brainroot(title: [Energiearten], layout: "down", karte)
  },
  source: ```typ
#brainroot(title: [Energiearten], layout: "down", karte)
  ```,
  width: 100%,
)

#show-example(
  rendered: {
    import "../lib.typ": *
    set text(size: 8pt)
    brainroot(title: [Energiearten], layout: "radial", karte,
      branch([Druckenergie]), branch([Strahlungsenergie], [Lichtenergie]))
  },
  source: ```typ
#brainroot(title: [Energiearten], layout: "radial", karte,
  branch([Druckenergie]), branch([Strahlungsenergie], [Lichtenergie]))
  ```,
  width: 100%,
)

Bei `radial` steht der erste Ast bei `start` (Standard `60deg`), die weiteren
folgen im Uhrzeigersinn. Der Radius beginnt bei `root-gap` und wächst, bis
sich keine zwei Teilbäume überschneiden.

= Paletten

`palette` liefert die Farben der Äste und der Wurzel; die Kästen bekommen die
Astfarbe um `tint` aufgehellt. Zehn Paletten sind eingebaut, alle mit derselben
Karte gezeigt:

#let paletten = (
  poster: [Kräftig bunt, wie Filzstifte an der Tafel. Der Standard.],
  pastel: [Zarte, gedämpfte Töne.],
  grayscale: [Nur Graustufen, für den Schwarzweißdruck.],
  mono: [Ein Blau in wechselnder Helligkeit.],
  plain: [Eine dunkle Tinte für alles, wie mit dem Füller gezeichnet.],
  earth: [Erdtöne: Terrakotta, Ocker, Oliv, Sand.],
  ocean: [Meer: Türkis, Petrol, Seegrün.],
  sunset: [Abendhimmel: Rot, Orange, Rosa, Violett.],
  forest: [Wald: Grün mit etwas Braun.],
  neon: [Grelle, gesättigte Farben.],
)
#for (name, beschreibung) in paletten [
  == #raw(name)
  #beschreibung
  #show-example(
    rendered: {
      import "../lib.typ": *
      set text(size: 8pt)
      brainroot(title: [Energiearten], palette: name, karte)
    },
    source: raw(lang: "typ", "#brainroot(title: [Energiearten], palette: \"" + name + "\", karte)"),
    width: 100%,
  )
]

Eigene Farben gehen als Array, `palette: (red, blue, green)`, oder mit
Wurzelfarbe als Dictionary, `palette: (colors: (red, blue), root: black)`.
`root-fill` überschreibt die Wurzelfarbe in jedem Fall.

= Themes

Ein Theme bestimmt, wie Kästen und Kanten aussehen; die Farben kommen
weiterhin aus der Palette. Zehn sind eingebaut:

#for (name, beschreibung) in (
  soft: [Pastellkästen mit runden Ecken, weiche S-Kurven. Die Vorlage von der Tafel.],
  outline: [Weiße Kästen mit farbigem Rahmen, Kurven.],
  blocks: [Vollfarbige eckige Kästen mit weißer Schrift, rechte Winkel: Organigramm-Optik.],
  lines: [Keine Kästen: der Text steht auf seiner farbigen Linie, die Kanten münden hinein. Die klassische Mindmap.],
  sketch: [Dünner Rahmen ohne Füllung, gestrichelte Geraden.],
  bubbles: [Pillen mit Pastellfüllung und geraden Verbindungen.],
  hand: [Wie `soft`, aber handgezeichnet: jede Linie wackelt leicht.],
  scribble: [Gekritzelt: keine Füllung, jede Linie zweimal gezogen.],
  marker: [Filzstift: volle Farbe, breite gerade Striche mit langem Wackeln.],
  pencil: [Bleistift: dünne Linien mit feinem Zittern, rechte Winkel.],
) [
  == #raw(name)
  #beschreibung
  #show-example(
    rendered: {
      import "../lib.typ": *
      set text(size: 8pt)
      brainroot(title: [Energiearten], theme: name, karte)
    },
    source: raw(lang: "typ", "#brainroot(title: [Energiearten], theme: \"" + name + "\", karte)"),
    width: 100%,
  )
]

== Handgezeichnet

Die Themes `hand`, `scribble`, `marker` und `pencil` wackeln jede Linie nach
dem Muster der TikZ-Dekoration `sketch`: der Pfad wird in kleinen Schritten
abgelaufen, jeder Punkt senkrecht dazu um eine langsam laufende Sinuswelle
versetzt, deren Takt ein Zufallslauf bestimmt. Der Zufall ist reproduzierbar,
dieselbe Karte sieht bei jedem Übersetzen gleich aus. Eine Handschrift wie
"Patrick Hand" oder "Kalam" passt dazu; sie kommt per `set text(font: ...)`
oder über das Theme-Feld `font`.

`wobble` regelt die Stärke: `wobble: 0.5` wackelt halb so stark, `wobble: 2`
doppelt. Das Feld `hand` steuert das Wackeln im Einzelnen: `amplitude` (Ausschlag in pt),
`wavelength` (Wellenlänge in pt), `randomness` (Unregelmäßigkeit, 1 ist ein
reiner Sinus), `segment` (Schrittweite in pt) und `passes` (wie oft jede
Linie gezogen wird). Jedes Theme lässt sich damit handgezeichnet machen:

#show-example(
  rendered: {
    import "../lib.typ": *
    set text(size: 8pt, font: "Patrick Hand")
    brainroot(title: [Energiearten],
      theme: (base: "blocks", hand: (amplitude: 1, wavelength: 60, randomness: 2, segment: 1.5, passes: 1)),
      karte)
  },
  source: ```typ
#set text(font: "Patrick Hand")
#brainroot(title: [Energiearten],
  theme: (base: "blocks", hand: (amplitude: 1, wavelength: 60, randomness: 2, segment: 1.5, passes: 1)),
  karte)
  ```,
  width: 100%,
)

== Ein Theme anpassen

Ein Dictionary überschreibt einzelne Felder; `base` wählt das Ausgangstheme,
sonst gilt `soft`. Felder: `edge` (`"curve"`, `"elbow"`, `"straight"`),
`fill` (`"tint"`, `"solid"`, `"white"`, `"none"`), `stroke`, `radius`,
`underline`, `dash`, `font`, `hand` und `root` mit Überschreibungen nur für
die Wurzel. `layout` legt alle Äste auf eine Seite.

#show-example(
  rendered: {
    import "../lib.typ": *
    set text(size: 8pt)
    brainroot(title: [Energiearten], layout: "right",
      theme: (base: "outline", edge: "elbow", radius: 0pt), karte)
  },
  source: ```typ
#brainroot(title: [Energiearten], layout: "right",
  theme: (base: "outline", edge: "elbow", radius: 0pt), karte)
  ```,
  width: 100%,
)

= Gestalt

- `ink` ist die Schriftfarbe. Bei `auto` wählt jeder Kasten nach der
  Helligkeit seiner Füllung zwischen `ink-dark` und `ink-light`, die Grenze
  setzt `ink-threshold`. So bleibt die Schrift auch auf dunklen Paletten wie
  `grayscale` oder `mono` lesbar.
- `scale` gibt die Schriftgröße je Ebene relativ zur Umgebung an, `bold-depth`
  die Zahl der fetten Ebenen ab der Wurzel.
- `thickness` gibt die Linienstärke je Ebene an; der letzte Wert gilt für
  alle tieferen Ebenen.
- `tint` hellt die Astfarbe für die Kästen auf; `tint-min` sorgt dafür, dass
  auch dunkle Palettenfarben helle Kästen ergeben. `root-fill` färbt die Wurzel.
- `level-gap` und `root-gap` sind die Abstände in Wachstumsrichtung (Eltern
  zu Kind, Wurzel zu Ast), `sibling-gap` und `branch-gap` die quer dazu
  (zwischen Geschwistern, zwischen den Ästen der ersten Ebene).
- `max-width` begrenzt die Breite einer Beschriftung; längerer Text wird
  umgebrochen. `none` bricht nie um.
- `inset` ist der Innenabstand der Kästen.

= Funktionen

#show-module("../lib.typ")
