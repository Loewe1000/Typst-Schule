#import "@schule/schuldocs:0.3.1": info, show-code, show-module, tip, warning

= Über dieses Paket

Ein *Trimino* ist ein Legespiel aus dreieckigen Kärtchen. An jeder inneren
Kante der fertigen Figur treffen eine Aufgabe und ihre Lösung aufeinander:
die Aufgabe auf dem einen Kärtchen, die Lösung auf dem Nachbarkärtchen.
Liegt alles richtig, entsteht die Figur. Das Spiel kontrolliert sich so
selbst.

`trimino` setzt zwei Teile:

- das *Lösungsbild*: die fertige Figur mit allen Beschriftungen, für die Lehrkraft
- den *Schnittbogen*: dieselben Kärtchen gemischt und gedreht, zum Ausschneiden

Jede Beschriftung steht vom Inneren ihres Kärtchens aus gesehen aufrecht.
Auf dem Schnittbogen ist darum keine Kante bevorzugt.

= Schnellstart

#show-code(```typ
#import "@schule/trimino:0.5.0": trimino

#set page(paper: "a4", margin: 1.5cm)

#trimino(title: [Einmaleins], pairs: (
  ([3 · 4], [12]), ([6 · 7], [42]), ([8 · 8], [64]),
  ([9 · 3], [27]), ([7 · 5], [35]), ([4 · 9], [36]),
))
```)

Sechs Paare ergeben ein Sechseck aus sechs Kärtchen. Auf der ersten Seite
steht das Lösungsbild, danach der Schnittbogen.

= Formen

Jede innere Kante trägt genau ein Paar. Eine Form passt deshalb nur, wenn sie
so viele innere Kanten hat, wie es Paare gibt. Mit `shape: auto` probiert das
Paket die Formen in dieser Reihenfolge und nimmt die erste, die passt:

#table(columns: 4, inset: 6pt, stroke: 0.5pt + luma(70%),
  [*Form*], [*`shape`*], [*`shape-size`*], [*Paare (Kärtchen)*],
  [Dreieck], [`"triangle"`], [Kärtchen je Seite: 2, 3, 4, 5], [3 (4), 9 (9), 18 (16), 30 (25)],
  [Sechseck], [`"hexagon"`], [Kärtchen je Seite: 1, 2], [6 (6), 30 (24)],
  [Stern], [`"star"`], [1, 2], [12 (12), 60 (48)],
  [Raute], [`"rhombus"`], [`(Breite, Höhe)`], [8 (8), 13 (12), 18 (16), 21 (18), …],
  [Trapez], [`"trapezoid"`], [`(Seite, abgeschnittene Spitze)`], [8 (8), 13 (12), 17 (15), 18 (16), …],
  [Streifen], [`"strip"`], [Zahl der Kärtchen], [jede Zahl: $n - 1$ Paare bei $n$ Kärtchen],
)

Der Streifen passt immer und ist deshalb die letzte Möglichkeit. Welche
Formen es für eine Paarzahl gibt, liefert `trimino-shapes`:

#show-code(```typ
#import "@schule/trimino:0.5.0": trimino-shapes
#for e in trimino-shapes(13) [
  #e.shape #repr(e.shape-size): #e.cards Kärtchen \
]
```)

#tip[Für die Klasse eignen sich 9 Paare (Dreieck), 12 Paare (Stern) oder
18 Paare (großes Dreieck). Wer eine andere Zahl hat, ergänzt ein Paar oder
streicht eines, statt beim Streifen zu landen.]

= Ablenker

Die Außenkanten bleiben leer. Dadurch erkennt man Randkärtchen leicht. Mit
`distractors` stehen dort falsche Ergebnisse, die nirgends passen:

```typ
#trimino(pairs: paare, distractors: ([48], [0,5], [120 %]))
```

= Gestaltung

Ohne weitere Angaben (`theme: auto`, entspricht `"riso"`) bekommt jede
Beschriftung ein weißes Feld, und die Kärtchen sind nach ihrem Ring um die
Mitte der Figur eingefärbt: innen zartgelb, außen zart lachsfarben. Liegt
alles richtig, ergeben die Hintergründe Farbringe.

Dazu kommen zweifarbige Eckspitzen (`corners: true`). Wo die Kärtchen
richtig zusammenliegen, ergeben sie Sterne.

#table(columns: 2, inset: 6pt, stroke: 0.5pt + luma(70%),
  [*`theme`*], [*Wirkung*],
  [`auto`, `"riso"`], [Ringfarben, weiße Felder, kräftige Schrift],
  [`"klar"`], [schwarz-weiß, druckt sparsam],
  [`"leiste"`], [weiße Kärtchen mit violettem Rand, in dem die Beschriftungen stehen],
  [`"bauhaus"`], [kräftige Farbbänder je Kante, weiße Schrift],
)

Ein Dictionary ändert einzelne Schlüssel von `"riso"`, zum Beispiel
`theme: (corner: rgb("#16877a"))` für grüne Eckspitzen. Die Schlüssel stehen
in der API-Referenz.

#tip[Die Ringfarben verraten, ob ein Kärtchen eher innen oder außen liegt,
aber nicht, welche Aufgabe zu welcher Lösung gehört. Wer das nicht möchte,
schreibt `theme: (fill: "single")` für einen einheitlichen Ton.]

= Rückseite

Mit `back: true` folgt auf jeden Schnittbogen eine Rückseite: auf jedem
Kärtchen ein weißes Etikett mit dem Schriftzug „TRIMINO“, dem Titel
und einer kleinen Nummer,
dahinter ein ruhiges Muster aus kleinen Dreiecken. Die farbige Fläche liegt
nur unter den Kärtchenreihen und ragt ringsum 4 mm über sie hinaus. Die
Plätze sind waagerecht gespiegelt, damit Vorder- und Rückseite beim
beidseitigen Druck übereinanderliegen. Der Drucker muss dafür *an der langen
Kante* wenden. Der Schnittbogen beginnt immer auf einer ungeraden Seite
(notfalls bleibt die Seite hinter dem Lösungsbild leer), so lässt sich das
ganze Dokument beidseitig drucken.

```typ
#trimino(title: [Prozentrechnung], pairs: paare, back: true)
```

Statt des Titels kann unter „TRIMINO“ ein eigener Text stehen:

```typ
#trimino(pairs: paare, back: [*Prozentrechnung*\ Grundaufgaben])
```

Beidseitiger Druck sitzt selten genau. Deshalb hat die Rückseite keine
Rahmen oder Linien, die an den Kärtchen ausgerichtet sein müssten: Das Muster
hat kein Raster, die Fläche reicht über die Schnittkanten hinaus, und die
Etiketten halten mindestens 2,5 mm Abstand zu den Kanten. Ihre Größe richtet
sich nach dem Platz im Dreieck: Sie sitzen etwas zur breiten Seite hin und
werden so groß, wie es der Abstand erlaubt. Ein Versatz bis etwa 2,5 mm
fällt so nicht auf. Der Schriftzug steht in Futura
(sonst Avenir Next oder Montserrat), im Theme `riso` in den Ringfarben.

#tip[Die Spiegelung setzt gleiche Ränder links und rechts voraus. Mit
`cut-marks: true` ist das immer so; die Rückseite bekommt dann keine
Passermarken.]

= Mehrere Sätze

`copies` legt mehrere Sätze Kärtchen auf denselben Schnittbogen, etwa für
zwei Gruppen. Jeder Satz ist neu gemischt. Auf der Rückseite trägt jedes
Kärtchen klein den Buchstaben seines Satzes und seine Nummer: A1–A12, B1–B12
und so weiter. So landet kein Kärtchen in der falschen Gruppe. Die Nummern
folgen der zufälligen Lage auf dem Bogen und verraten nichts über die
Lösung. Damit zwei Sätze eines Sterns auf ein A4-Blatt passen, braucht es
kleinere Kärtchen:

```typ
#trimino(pairs: paare, copies: 2, side: 5cm, cut-marks: true, back: true)
```

#tip[Mit Passermarken passen auf A4 bei 6 cm Kantenlänge 16 Kärtchen (4 Reihen
zu 4), bei 5 cm 25 (5 Reihen zu 5). Die Schrift wächst und schrumpft mit
`side`.]

= Schneideplotter

Mit `cut-marks: true` schneidet ein Silhouette-Schneideplotter (Cameo,
Portrait) die Kärtchen aus. Auf jeden Schnittbogen kommen dann Passermarken
im Silhouette-Format: links oben ein Quadrat, rechts oben und links unten je
ein Winkel, 10 mm vom Blattrand. Damit der Plotter die Marken sicher findet,
bekommt der Schnittbogen einen Rand von 30 mm und weder Kopf- noch Fußzeile;
das Lösungsbild bleibt, wie es ist. Rechts unten steht ein kleines
Prüfkreuz: Der Plotter fährt nach der Markensuche darüber, und man sieht, ob
die Messerspitze genau trifft, bevor geschnitten wird.

```typ
#trimino(pairs: paare, cut-marks: true)
```

Auf dem Schnittbogen liegen die Reihen ohne Abstand aneinander, jede zweite
um eine halbe Kante versetzt. So liegen alle Kanten auf durchgehenden
Geraden: Ein Schnitt trennt immer zwei Kärtchen, und der Plotter schneidet
lange Geraden am Stück, statt ständig neu anzusetzen.

Die Schnittlinien stehen zugleich unsichtbar im Dokument, als `metadata` mit
dem Label `<cut-data>`, einmal je Schnittbogen. Jeder Eintrag nennt die
Seite, die Lage der Marken und die Strecken in Millimetern, gemessen von der
linken oberen Ecke der Marken. Gemeinsame Kanten zweier Kärtchen stehen nur
einmal darin, der Plotter schneidet sie also nur einmal. Dazu kommen die
Umrisse der Kärtchen (`pieces`) und die Lage des Prüfkreuzes (`check`). An
den Umrissen erkennt ein Schneideprogramm, wo es an spitzen Ecken etwas über
das Ende hinausschneiden darf, ohne ein Nachbarkärtchen anzuritzen.

```sh
typst eval 'query(<cut-data>).map(m => m.value)' --in trimino.typ --format json
```

Mit dem Bündelexport von Typst 0.15 (noch experimentell) legt
`trimino-cut-file` die Schnittvorlage zusätzlich als eigene Datei neben das
PDF: als `.json` mit denselben Daten oder als `.svg` mit Passermarken in
Schwarz und Schnittlinien in Rot (`#ff0000`). Der Aufruf gehört auf die
oberste Ebene, neben `document(…)`:

```typ
#let spiel = trimino(pairs: paare, cut-marks: true)
#document("trimino.pdf", spiel)
#trimino-cut-file("trimino-schnitt.svg")
```

```sh
typst compile trimino.typ ausgabe --format bundle --features bundle
```

#info[Das Werkzeug `tools/cutter` im Repository liest diese Daten, lässt den
Plotter die Marken suchen und schneidet dann genau an den Kanten. Es kann auch
Schnittlinien einer bestimmten Farbe aus einer SVG-Datei schneiden.]

#tip[Den Schnittbogen ohne Skalierung drucken („Tatsächliche Größe“), sonst
passen Marken und Linien nicht mehr zu den Daten.]

= Mischen

`seed` legt fest, wie Paare auf Kanten verteilt und Kärtchen gemischt
werden. Dieselbe Zahl liefert dasselbe Spiel; eine andere Zahl ein neues mit
denselben Paaren, etwa für eine zweite Gruppe.

#info[Auf dem Lösungsbild steht in der Mitte jedes Kärtchens seine Nummer. Auf
dem Schnittbogen fehlt sie absichtlich: Eine aufrechte Zahl auf einem
gedrehten Kärtchen würde verraten, wie es in der Lösung liegt. Mit
`number: false` verschwindet sie auch auf dem Lösungsbild.]

= API-Referenz

#show-module(read("../src/trimino.typ"), name: "trimino")
