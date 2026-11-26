#import "@schule/schuldocs:0.3.1": info, show-code, show-module, tip, warning

= Überblick

`trimino` setzt zwei Legespiele für den Unterricht, beide aus einer Liste von
Paaren `(Aufgabe, Lösung)`:

- *Triminos* (`trimino`): dreieckige Kärtchen. An jeder inneren Kante der
  fertigen Figur treffen eine Aufgabe und ihre Lösung aufeinander. Die Form
  (Dreieck, Sechseck, Stern, Raute, Trapez, Streifen) wählt das Paket nach der
  Zahl der Paare.
- *Dominos* (`domino`): rechteckige Kärtchen mit zwei Hälften, links die
  Lösung der vorigen, rechts die nächste Aufgabe. Sie bilden eine Kette mit
  Abbiegungen oder einen Stapel.

Zu jedem Spiel entstehen das *Lösungsbild* für die Lehrkraft, der
*Schnittbogen* mit gemischten Kärtchen und auf Wunsch eine *Rückseite* für den
beidseitigen Druck. Eingebaute Selbstkontrollen helfen den Schülerinnen und
Schülern: Farbkreise an den Trimino-Ecken, offene Anlegerahmen bei der
Domino-Kette und ein Lösungswort auf den Rückseiten des Stapels. Sieben Themes
passen zu den Themes von `@schule/arbeitsblatt`.


#figure(image("assets/trimino-loesung.png", width: 80%, alt: "Lösungsbild eines Triminos mit Farbkreisen (Theme „riso“)"), caption: [Lösungsbild eines Triminos mit Farbkreisen (Theme „riso“)])


== Schnellstart

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

Ein Domino aus denselben Bausteinen:

#show-code(```typ
#import "@schule/trimino:0.5.0": domino

#domino(title: [Einmaleins], pairs: (
  ([3 · 4], [12]), ([6 · 7], [42]), ([8 · 8], [64]), ([9 · 3], [27]),
))
```)

Übersetzt wird wie jedes Typst-Dokument; mit `back: true` folgt auf jeden
Schnittbogen seine Rückseite.

== Themes auf einen Blick


#figure(image("assets/themes-trimino.png", width: 100%, alt: "Trimino-Lösungen in allen sieben Themes"), caption: [Trimino-Lösungen in allen sieben Themes])


#figure(image("assets/themes-domino.png", width: 100%, alt: "Domino-Ketten in allen sieben Themes"), caption: [Domino-Ketten in allen sieben Themes])


Mehr dazu im Kapitel „Gestaltung“.


= Triminos

Ein Trimino legt man zu einer Figur. Auf dem Schnittbogen sind die Kärtchen gemischt und gedreht; jede Beschriftung steht vom Inneren ihres Kärtchens aus gesehen aufrecht, darum ist keine Kante bevorzugt.


#figure(image("assets/trimino-schnittbogen.png", width: 80%, alt: "Schnittbogen desselben Triminos"), caption: [Schnittbogen desselben Triminos])



== Formen

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


== Ablenker

Die Außenkanten bleiben leer. Dadurch erkennt man Randkärtchen leicht. Mit
`distractors` stehen dort falsche Ergebnisse, die nirgends passen:

```typ
#trimino(pairs: paare, distractors: ([48], [0,5], [120 %]))
```


== Beschriftungen

Jede Beschriftung hat ihr eigenes Feld: das Dreieck aus ihrer Kante und der
Kärtchenmitte. Darin steht sie unten auf der Kante (gut 2 mm Abstand bei
6 cm Kante) und berührt mit den oberen Ecken die Linien zur Mitte; die
unteren Ecken bleiben neben den Eckmarken. Formeln stehen in Displaygröße,
Brüche also so groß wie der Text daneben.

Ein Satz hat eine Schriftgröße: höchstens das 1,05-Fache des Medians der
Größen, die jede Beschriftung für sich bekäme, und höchstens das 1,25-Fache
der kleinsten lesbaren. Nur, was dann noch nicht passt, wird einzeln kleiner.
Eine einzelne sehr lange Beschriftung (die für sich unter 9 pt bliebe) zieht
den Satz also nicht mit hinunter: Sie allein wird kleiner, am besten kürzt man
sie oder setzt einen Zeilenumbruch. So sind
Aufgabe und Lösung gleich groß, und die Größe verrät nichts. Bei 6 cm Kante
stehen „50 %“ und Brüche wie $1/4$ in etwa 13–16 pt. Eine feste
Schriftgröße setzt `label-size`, etwa `label-size: 11pt`.

Reine Zahlen mit 6 oder 9 (66, 69, 96 …) bekommen einen feinen Unterstrich,
damit sie gedreht nicht verwechselt werden; das gilt auch für eine Formel
aus einer einzigen Zahl wie `[$69$]` und für Zähler und Nenner eines Bruchs,
die nur aus einer solchen Zahl bestehen (`[$9/2$]`: der Strich steht unter
der 9, kürzer als der Bruchstrich).

Den Rahmen wählt der Theme-Schlüssel `label`:

#table(columns: 2, inset: 6pt, stroke: 0.5pt + luma(70%),
  [*`label`*], [*Wirkung*],
  [`"field"`], [Fläche (`field`, auf Wunsch mit Rand `field-stroke`), die das Feld bis an die Eckmarken oder -spitzen ausfüllt (Standard bei `"riso"`, `"atlas"`, `"skizze"`)],
  [`"plain"`], [nur Text (Standard bei `"klar"`, `"leiste"`, `"kontur"`)],
  [`"pill"`], [Feld mit runden Enden und feinem Rand],
  [`"outline"`], [umrandet, ohne Füllung (Standard bei `"labor"`; Domino: feiner Rahmen um den Inhalt)],
  [`"tab"`], [Lasche auf der Kante; zwei passende Kärtchen ergänzen sich zu einem Feld über die Kante],
)

```typ
#trimino(pairs: paare, theme: (label: "plain"))
```


== Selbstkontrolle an den Ecken

Mit `corners: "wheel"` bekommt jede Eckspitze eine von sechs Farben, auf
Wunsch mit ein bis sechs Würfelaugen: Rot 1, Orange 2, Gold 3, Grün 4, Blau 5,
Violett 6 (die Themes zu `@schule/arbeitsblatt` haben eigene sechs Töne, ein
eigenes Theme setzt sie mit `wheel: (…)`). Die Augen sind ein zweiter,
unabhängiger Code, auch schwarz-weiß und bei Farbsehschwäche; sie sind weiß
auf dunklen und dunkel auf hellen Spitzen. An jeder Ecke der fertigen Figur tragen die zusammenstoßenden
Kärtchen verschiedene Farben. Die Regel für die Schüler steht unter dem
Lösungsbild, beim Kreis etwa:

#align(center)[_In keinem Kreis kommt eine Farbe oder Augenzahl doppelt vor._]

Jeden fertigen Kreis kann man sofort prüfen, auch mitten im Legen. Ein
einzelnes Kärtchen verrät dabei fast nichts über seinen Platz: Wer nur nach
Farben legen wollte, müsste viele Kärtchen zugleich bedenken. Ein falsch
gelegtes Kärtchen fällt an einer vollen Ecke zu fünf Sechsteln auf, an drei
vollen Ecken fast immer; am Rand mit halben Formen seltener.

```typ
#trimino(pairs: paare, corners: "wheel")
```

Zwei Theme-Schlüssel stellen die Spitzen ein:

#table(columns: 2, inset: 6pt, stroke: 0.5pt + luma(70%),
  [*Schlüssel*], [*Werte*],
  [`tip`], [`"circle"` (Kreis, Standard), `"ring"` (Ring; berührt die Kärtchenecke nicht und übersteht deshalb den Eckenrunder), `"hexagon"` (Sechseck, Standard bei `"labor"`)],
  [`pips`], [`true` (Würfelaugen, Standard) oder `false` (nur Farben)],
)

```typ
#trimino(pairs: paare, corners: "wheel", theme: (tip: "ring", pips: false))
```

Zwischen den Spitzen liegt eine feine weiße Fuge (`tip-edge`, bei
`"kontur"` schwarz); sehr helle Töne haben eine graue Haarlinie, damit sie
sich vom Weiß abheben. Die Spitzen sind groß (Kreis 0,225, Sechseck 0,235 der
Kante), damit auch sechs Augen luftig darin stehen: Die Augen haben auf dem
Schnittbogen mindestens 1,2 mm Durchmesser (1,5 mm bei 6 cm Kante), stehen
mindestens einen Durchmesser auseinander und bleiben ab 5 cm Kante gut 0,6 mm, ab 4 cm knapp 0,5 mm von
beiden Schnittkanten entfernt, damit ein leicht schiefer Schnitt kein Auge anschneidet;
dort stehen sie immer. Im Lösungsbild werden sie bei Bedarf kleiner (bis
0,7 mm); ist es kleiner als 4 cm Kante, fehlen sie dort, die Farben bleiben,
und der Hinweis unter dem Lösungsbild nennt nur noch die Farbe. Wer das
Lösungsbild schwarz-weiß kopiert, nimmt dann besser eine größere Kante oder
das Theme `"klar"`.

Beim Theme `"klar"` sind die Spitzen eine Grauleiter in sechs Stufen, dazu
die Augen; dort lassen sich die Augen nicht abschalten. Ein eigenes Theme
schaltet mit `wheel: none` auf die Grauleiter um.


== Mischen

`seed` legt fest, wie Paare auf Kanten verteilt und Kärtchen gemischt
werden. Dieselbe Zahl liefert dasselbe Spiel; eine andere Zahl ein neues mit
denselben Paaren, etwa für eine zweite Gruppe.

#info[Auf dem Lösungsbild steht in der Mitte jedes Kärtchens seine Nummer. Auf
dem Schnittbogen fehlt sie absichtlich: Eine aufrechte Zahl auf einem
gedrehten Kärtchen würde verraten, wie es in der Lösung liegt. Mit
`number: false` verschwindet sie auch auf dem Lösungsbild.]


= Dominos

Ein Domino-Kärtchen hat zwei quadratische Hälften: links die Lösung der
vorigen Aufgabe, rechts die nächste Aufgabe. Das erste Kärtchen trägt links
„START“ mit einem Pfeil zur ersten Aufgabe, das letzte rechts „ENDE“ mit
einem kleinen Quadrat (Text über `start` und `end`). Wer richtig anlegt,
kommt vom Start lückenlos zum Ende.

#show-code(```typ
#import "@schule/trimino:0.5.0": domino

#domino(title: [Summenregel], tags: ([$f'(x)$], [$f(x)$]), pairs: (
  ([$x^5 + x^(-3)$], [$5x^4 - 3/x^4$]),
  ([$x^7 - x^3$], [$7x^6 - 3x^2$]),
  ([$x^2 + x^(-5)$], [$2x - 5/x^6$]),
))
```)

- *Lösungsbild:* Die Kette läuft als Treppe nach rechts, oben und unten,
  nie nach links; so steht keine Schrift auf dem Kopf, und die Kette kreuzt
  sich nie. Aus vielen zufälligen Ketten wählt das Paket die, die im Platz am
  größten gezeichnet werden kann. Ein anderer `seed` gibt eine andere Form.
- *Anlegerahmen:* Jedes Feld ist nur an drei Seiten gerahmt. Lösungen haben
  einen dünnen roten Rahmen mit runden Ecken, Aufgaben einen kräftigen
  dunkelblauen mit eckigen. Der Unterschied bleibt so auch auf einer
  Schwarz-Weiß-Kopie sichtbar (bei `"klar"`: grau und dünn gegen schwarz und
  kräftig; die Farben wählt das Theme mit `answer` und `task`). Die offene Seite zeigt, wo das Nachbarkärtchen anliegt:
  bei der Lösung immer links, bei der Aufgabe rechts (geradeaus), oben oder
  unten (die Kette biegt ab). Erst mit dem passenden Nachbarn schließt sich
  der Rahmen. So ist die Legerichtung eindeutig, ohne dass verraten wird,
  welche Aufgabe zu welcher Lösung gehört.
- *Inhalte:* Text, Formeln und Grafiken (etwa Funktionsgraphen aus CeTZ).
  Ein Satz hat eine Größe (dieselbe Regel wie bei den Triminos), höchstens
  0,2 × `side` (20 pt bei 3,5 cm).
- *`tags`:* kleine Überschriften der Hälften, etwa `([$f'(x)$], [$f(x)$])`,
  in der Kette oben links im Feld, beim Stapel als Zeilenkopf links. Höchstens
  0,1 × `side` groß und nie größer als der kleinste Inhalt; lange
  Überschriften werden bis 6 pt kleiner, bis sie in eine Zeile passen (danach
  bricht die Kette sie um, und beim Stapel wird der Zeilenkopf breiter). Der
  Inhalt rückt dafür zur Seite und überdeckt die Überschrift nie.
- *Ausrichtung:* Jeder Inhalt ist so gedreht, dass er im fertig gelegten
  Domino aufrecht steht. Zwei zusammengehörige Hälften haben so immer
  dieselbe Ausrichtung (bei Graphen zeigen die x-Achsen in dieselbe Richtung).
  Auf dem Schnittbogen stehen die Inhalte senkrecht liegender Kärtchen darum
  quer.
- *`loop: true`:* geschlossene Kette ohne Start und Ende; das erste Kärtchen
  trägt links die letzte Lösung.
- *`side`:* Kantenlänge einer Hälfte (Standard 3,5 cm, ein Kärtchen also
  7 × 3,5 cm).


#figure(image("assets/domino-kette.png", width: 80%, alt: "Domino-Kette mit Funktionsgraphen: Lösungsbild"), caption: [Domino-Kette mit Funktionsgraphen: Lösungsbild])


#figure(image("assets/domino-kette-schnittbogen.png", width: 80%, alt: "Schnittbogen der Kette: die offenen Rahmenseiten zeigen, wo angelegt wird"), caption: [Schnittbogen der Kette: die offenen Rahmenseiten zeigen, wo angelegt wird])


== Stapel

Mit `layout: "stack"` sind die Kärtchen breit und flach: oben die Lösung der
vorigen Aufgabe, unten die nächste Aufgabe. Sie werden zu einem Stapel
untereinandergelegt; das passt gut für lange Terme.

```typ
#domino(layout: "stack", tags: ([$f'(x)$], [$f(x)$]), pairs: paare)
```

Zur Kontrolle tragen die Rückseiten ein *Lösungswort*: Ist der Stapel
fertig, dreht man die Kärtchen der Reihe nach an Ort und Stelle um und liest
das Wort von oben nach unten. Vorher sieht man es nicht, also kann man auch
nicht nach ihm legen. `word: auto` wählt ein Wort mit so vielen Buchstaben,
wie es Kärtchen gibt (Paare + 1, mit `loop: true` so viele wie Paare);
`word: "Gut gemacht"` setzt eines von Hand (Leerzeichen zählen nicht),
`word: none` schaltet es ab. Das Wort steht auch unter dem Lösungsbild. Die
Rückseite wird mit Lösungswort immer gesetzt.

#tip[Die Kärtchen mit der Vorderseite nach oben austeilen, sonst lässt sich
das Wort schon beim Auslegen lesen.]

Auch bei der Kette lässt sich ein Lösungswort setzen (`word: "…"`); es folgt
dann der Reihenfolge der Kette.

Unter dem Lösungsbild steht das Wort in Kästchen. Auf den Rückseiten steht
der Buchstabe groß, mit Serifen-I, darunter ein Strich in der Akzentfarbe: Er zeigt, wo
unten ist, damit I, N, Z und S eindeutig bleiben.

Themes, Rahmen (`label`), `back`, `copies`, `first-copy` und `cut-marks`
wirken wie beim Trimino. Die Rückseite trägt Konfetti aus winzigen
Dominosteinen (oder die Formen des Themes) und den Schriftzug „DOMINO“;
`trimino-cut-file` schreibt auch die Schnittvorlage eines Dominos.


#figure(image("assets/domino-stapel.png", width: 80%, alt: "Domino-Stapel zur Summenregel mit Lösungswort"), caption: [Domino-Stapel zur Summenregel mit Lösungswort])


#figure(image("assets/domino-stapel-rueckseite.png", width: 80%, alt: "Rückseiten des Stapels: von oben nach unten gelesen ergibt sich das Lösungswort"), caption: [Rückseiten des Stapels: von oben nach unten gelesen ergibt sich das Lösungswort])


== Graphen

Farbe gehört zum Rahmen, nicht zum Inhalt. Funktionsgraphen deshalb in Tinte
zeichnen: Kurve etwa 1,6 pt in `#1a1a1a`, Gitter 0,4 pt hellgrau, Achsen
0,8 pt schwarz mit deutlichen Pfeilspitzen. Der Graph soll das Feld fast
ganz füllen; für Graphen-Dominos `side: 4cm` oder mehr nehmen. Stehen einmal
$f$ und $f'$ auf einem Kärtchen, unterscheidet sie die Strichart, nicht die
Farbe.

```typ
#let graph(f) = cetz.canvas(length: 0.28cm, {
  import cetz.draw: *
  grid((0, -4), (10, 4), step: 1, stroke: 0.4pt + luma(72%))
  line((0, 0), (10.4, 0), mark: (end: ">", fill: black), stroke: 0.8pt)
  line((0, -4), (0, 4.4), mark: (end: ">", fill: black), stroke: 0.8pt)
  line(..range(101).map(i => (i / 10, calc.max(-4, calc.min(4, f(i / 10))))),
    stroke: 1.6pt + rgb("#1a1a1a"))
})
#domino(side: 4cm, tags: ([$f'$], [$f$]), pairs: fs.map(((f, d)) => (graph(f), graph(d))))
```

Das Beispiel `examples/graphen-domino.typ` zeigt eine ganze Kette.

#info[Der Schnittbogen einer Kette übernimmt die Drehungen aus dem
Lösungsbild: Die Inhalte senkrecht liegender Kärtchen stehen dort quer. Ein
Bogen mit lauter aufrechten Inhalten bräuchte ein anderes Schnittraster.]


= Gestaltung

Sieben Themes stehen zur Wahl. Drei klassische (`"riso"`, `"klar"`,
`"leiste"`) und vier, die zu den Themes von `@schule/arbeitsblatt` passen
(`"atlas"`, `"skizze"`, `"labor"`, `"kontur"`): gleiche Schriften, gleiche
Motive, Akzent in der Fachfarbe Mathematik (`#2f6fb5`). So sehen Arbeitsblatt
und Legespiel aus einem Guss aus. Jedes Theme gestaltet Kärtchen, Kopf,
Dominos und Rückseite.

#table(columns: 2, inset: 6pt, stroke: 0.5pt + luma(70%),
  [*`theme`*], [*Wirkung*],
  [`auto`, `"riso"`], [Standard: alle Kärtchen eines Satzes in einem Pastellton (er wechselt mit `seed`, `color` setzt ihn fest), Beschriftungen auf weißen Feldern mit Haarlinie, zweifarbige Drachen in den Ecken (sie ergeben im Lösungsbild Sterne), kräftige Eckspitzen; Rückseite creme mit Pastellkonfetti und buntem Schriftzug],
  [`"klar"`], [schwarz-weiß und kopierfest; ab Klasse 9 und für Kopien. Eckspitzen als Grauleiter mit Würfelaugen],
  [`"leiste"`], [weiße Kärtchen mit violettem Rand, an jeder Kante eine helle violette Leiste, in der die Beschriftungen stehen; violette Drachen],
  [`"atlas"`], [farbig wie ein modernes Schulbuch: Kärtchen in der Fachfarbe getönt, weiße runde Felder, Kreissektoren in den Ecken, Kopf als Titelband mit hellen Kreisen; Rückseite mit Kreiskonfetti. Schrift Myriad Pro (sonst Fira Sans)],
  [`"skizze"`], [verspielt für die Unterstufe: Kreidetöne je Kärtchen, gestrichelte Felder, Titel in Playpen Sans auf Klebeband, Start/Ende in Handschrift; Rückseite mit bunten Dreiecken, Klecksen und Sternen. Beschriftungen in SF Pro Rounded (sonst Fira Sans)],
  [`"labor"`], [technisch für MINT: Haarlinien in Nachtblau, umrandete Beschriftungen, Messskalen in den Ecken, Sechseck-Spitzen, Nummern und START/ENDE in Fira Code, Kopf mit Rahmen und Messskala; Rückseite auf Millimeterpapier],
  [`"kontur"`], [plakativ: dicke schwarze Umrisse, harte Schatten in der Akzentfarbe (Dominofelder, Etiketten, Kopf), Titel in Futura-Versalien über einer dicken Linie; Rückseite mit schwarzem und blauem Konfetti],
)

Jeder Code, den ein Theme in Farbe zeigt, steht auch ohne Farbe
(Strichstärke, Ecken, Form, Würfelaugen); `"klar"` zeigt ihn nur so.

Ein Dictionary ändert einzelne Schlüssel eines Themes: von `"riso"` oder,
mit `base`, von einem anderen. Jeder Wert darf eine Funktion der
Akzentfarbe sein (`a => a.lighten(80%)`); die mitgelieferten Themes leiten so
Tönung, Rahmen und Schatten aus `accent` ab. Eine andere Fachfarbe färbt
also das ganze Theme um:

```typ
#trimino(pairs: paare, theme: (base: "atlas", accent: rgb("#d4572a")))  // Physik-Orange
#trimino(pairs: paare, theme: (corner-mark: "triangle"))
#trimino(pairs: paare, theme: "klar", corners: false)
```

#table(columns: 2, inset: 6pt, stroke: 0.5pt + luma(70%),
  [*Schlüssel*], [*Wirkung*],
  [`base`], [Theme, dessen Schlüssel das Dictionary ändert (Standard `"riso"`)],
  [`fill`, `palette`, `stroke`, `ink`], [Füllung der Kärtchen (`none`, Farbe, Array aus Farben – eine je Kärtchen –, `"set"` ein Ton aus `palette` für den ganzen Satz, `"tint"` ein Ton aus `palette` je Kärtchen, `"ring"` Ton nach Ring), Töne für `"set"`/`"tint"`, Umriss (= Schnittlinie), Schriftfarbe],
  [`band`, `band-depth`], [Leiste an den Kanten (Farbe oder `"edge"` für einen hellen Ton je Kante) und ihre Breite; ab 0,1 stehen die Beschriftungen darin],
  [`inner`, `pill`, `weight`], [Umriss des inneren Dreiecks, Hinterlegung bei `label: "pill"`, Schriftstärke (`auto`: passend zur Schrift)],
  [`field`, `field-stroke`], [Fläche bei `label: "field"` (auch die Felder der Dominos) und ihr Rand (`none` oder Stroke, auch gestrichelt)],
  [`corner`, `corner-mark`], [Farbe und Form der Eckmarken bei `corners: true`: `"arc"` (Bogen), `"kite"` (zweifarbiger Drachen), `"triangle"` (flaches Dreieck, 0,6 mm vor der Ecke gekappt), `"dot"` (Kreissektor), `"ticks"` (Messskala) oder `none`],
  [`tip`, `tip-edge`, `pips`, `wheel`], [Form der Eckspitzen, Fuge zwischen ihnen (`auto`: weiß), Würfelaugen, Eckfarben (`auto`, `none` für die Grauleiter oder sechs eigene Farben)],
  [`label`], [Rahmen der Beschriftungen, siehe unten],
  [`font`, `math`], [Schrift der Beschriftungen und Matheschrift des Dokuments, siehe Abschnitt „Schriften“],
  [`answer`, `task`, `divider`, `shadow`], [Dominos: Rahmenfarbe der Lösung (dünn, rund) und der Aufgabe (kräftig, eckig), Trennlinie der Hälften (`"line"`, `"dashed"`, `"ticks"`, `none`), harter Schatten hinter Feldern, Etiketten und Kopfkasten (`none` oder Farbe)],
  [`accent`], [Akzentfarbe: Spielname im Kopf, Strich unter dem Lösungsbuchstaben, Grundton abgeleiteter Farben],
  [`chrome`, `display`, `code`], [Schriften, die das Paket selbst schreibt: Kopf, Fußnote und Etikett; Titel, Schriftzug, Start/Ende; Nummern und START/ENDE (`none`: wie `display`)],
  [`head`], [Kopf über Lösung und Schnittbogen: `"rule"` (Titel links, Spiel und Blatt klein rechts, feine Linie), `"band"`, `"tape"`, `"frame"`, `"poster"`],
  [`back-style`, `wordmark`], [Rückseite (`"pastel"`, `"mono"`, `"tint"`, `"circles"`, `"crayon"`, `"grid"`, `"poster"`) und Gestalt des Schriftzugs (`"rainbow"`, `"accent"`, `"mono"`, `"tile"`, `"hand"`, `"code"`, `"poster"`)],
)

Die Farbe der Kärtchen lässt sich auch direkt setzen, unabhängig vom Theme:

```typ
#domino(pairs: paare, color: rgb("#dfe7fd"))          // alle Kärtchen hellblau
#trimino(pairs: paare, theme: (fill: "tint"))          // wie früher: jedes Kärtchen ein anderer Ton
```

#tip[`fill: "ring"` gibt jedem Kärtchen einen Ton nach seinem Ring um die
Mitte. Das sieht schön aus, verrät aber, ob ein Kärtchen innen oder außen
liegt.]

Das frühere Theme `"bauhaus"` gibt es nicht mehr; der Aufruf bricht mit einer
Meldung ab, die die vorhandenen Themes nennt.


== Schriften

Die Beschriftungen stehen in einer Textschrift, die zur Matheschrift passt:
gleiche Ziffern, gleiche Strichstärke. Standard ist das Paar *Fira Sans +
Fira Math*: serifenlos, gut lesbar, für die Schule gemacht statt für die
Hochschule.

#table(columns: 3, inset: 6pt, stroke: 0.5pt + luma(70%),
  [*`font`*], [*Text*], [*Mathe*],
  [`"serifenlos"`], [Fira Sans], [Fira Math],
  [`"klassisch"`], [New Computer Modern (Book)], [New Computer Modern Math],
  [`"libertinus"`], [Libertinus Serif], [Libertinus Math],
  [`"stix"`], [STIX Two Text], [STIX Two Math],
)

Mit `font: auto` (Standard bei `"riso"`, `"klar"`, `"leiste"`) richtet sich
die Schrift nach dem Dokument: Ist die Dokumentschrift STIX Two Text, Noto
Sans oder TeX Gyre Pagella, nimmt das Paket das passende Paar; ist sie New
Computer Modern, das Paar `"klassisch"`. In allen anderen Fällen, auch bei
Typsts Vorgabe Libertinus Serif, steht Fira Sans mit Fira Math. Ein
Schriftname (`font: "Fira Sans"`) oder ein Dictionary `(text:, math:,
weight:)` setzt die Schrift von Hand; `text` darf eine Liste mit
Ersatzschriften sein.

Die vier Themes zu `@schule/arbeitsblatt` bringen ihre Schriften mit, Mathe
immer in Fira Math: `"atlas"` Myriad Pro, `"skizze"` SF Pro Rounded und für
Titel, Start/Ende und Schriftzug Playpen Sans, `"labor"` Fira Sans und Fira
Code, `"kontur"` Helvetica Neue und Futura. Fehlt eine Schrift, steht Fira
Sans (Typst meldet dann „unknown font family“, etwa für SF Pro Rounded).

Was das Paket selbst schreibt (Kopf, Nummern, START/ENDE, Rückseite), steht
in der Schrift des Themes (Schlüssel `chrome`, `display`, `code`); bei den
klassischen Themes in Inter (sonst IBM Plex Sans, Fira Sans, Helvetica Neue,
Arial), Schriftzug und Start/Ende bei `"riso"` und `"leiste"` in Futura.

#warning[Typst kann die Matheschrift nicht abfragen. Wer nur
`show math.equation: set text(font: "STIX Two Math")` setzt, gibt sie dem
Paket mit: `theme: (math: "STIX Two Math")` oder `theme: (font: "stix")`.]

Empfohlene Schriften (freie Lizenz, nur bei Bedarf selbst installieren): Fira
Sans, Fira Math und Fira Code (github.com/mozilla/Fira,
github.com/firamath/firamath), Playpen Sans (Google Fonts), Inter
(rsms.me/inter), Libertinus Math für das Paar `"libertinus"`.


= Rückseite und Sätze

== Rückseite

Mit `back: true` folgt auf jeden Schnittbogen eine Rückseite: auf jedem
Kärtchen ein weißes Etikett mit dem Schriftzug „TRIMINO“, dem Titel und einer
kleinen Nummer, dahinter Konfetti. Bei `"riso"` sind die Buchstaben bunt und
das Konfetti besteht aus Pastelldreiecken auf Creme; die anderen Themes
haben ihre eigene Rückseite (`back-style`, `wordmark`): Kreise in
Akzenttönen (`"atlas"`), bunte Dreiecke, Kleckse und Sterne mit Schriftzug in
Handschrift (`"skizze"`), Millimeterpapier mit Quadraten und Kreuzen
(`"labor"`), schwarzes und blaues Konfetti mit Etikett im Schattenkasten
(`"kontur"`). Dreiecke folgen dem Gitter der Triminos (Spitze oben oder
unten); das Konfetti hat drei Größen, klumpt nicht und lässt um jedes
Etikett einen Rand frei. Die farbige Fläche liegt
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
Rahmen oder Linien, die an den Kärtchen ausgerichtet sein müssten: Das
Konfetti liegt frei, die Fläche reicht über die Schnittkanten hinaus, und die
Etiketten halten mindestens 3 mm Abstand zu den Kanten. Ihre Größe richtet
sich nach dem Platz im Dreieck: Sie sitzen etwas zur breiten Seite hin und
werden so groß, wie es der Abstand erlaubt. Ein Versatz bis etwa 2,5 mm
fällt so nicht auf. Beim Theme `"klar"` ist die Rückseite weiß mit grauem
Konfetti.

#tip[Die Spiegelung setzt gleiche Ränder links und rechts voraus. Mit
`cut-marks: true` ist das immer so; die Rückseite bekommt dann keine
Passermarken.]


#figure(image("assets/trimino-rueckseite.png", width: 80%, alt: "Rückseite eines Trimino-Schnittbogens (Theme „riso“)"), caption: [Rückseite eines Trimino-Schnittbogens (Theme „riso“)])


== Mehrere Sätze

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

Für mehrere Bögen zählt `first-copy` die Buchstaben weiter: Der zweite Bogen
mit `copies: 2, first-copy: 3` trägt die Sätze C und D, der dritte mit
`first-copy: 5` E und F.

#tip[Mit Passermarken passen auf A4 bei 6 cm Kantenlänge 16 Kärtchen (4 Reihen
zu 4), bei 5 cm 25 (5 Reihen zu 5). Die Schrift wächst und schrumpft mit
`side`.]


= Drucken und Schneiden

== Drucken

- Papier mit 120–160 g/m² nehmen; für beidseitigen Druck im Treiber „dickes
  Papier“ und eine längere Trocknungszeit wählen.
- Matt laminieren (Folie 80–125 µm). Erst schneiden, dann laminieren,
  verschweißt die Kanten nur mit Abstand zwischen den Kärtchen; ohne Abstand
  zuerst laminieren, dann schneiden.
- Vor einem großen Satz ein Probeblatt drucken und schwarz-weiß kopieren:
  Ocker- und Himmelblau-Spitzen, die Rahmen (1,0 gegen 1,7 pt) und die
  Würfelaugen prüfen.

#info[Geplant, noch nicht umgesetzt: ein Abstand `gap` zwischen den
Kärtchen auf dem Schnittbogen (zum Laminieren mit verschweißten Kanten),
Schrägbrüche für einstellige Brüche an schrägen Kanten und ein Schnittbogen
mit aufrechten Inhalten für Domino-Ketten.]

== Schneideplotter

Mit `cut-marks: true` schneidet ein Silhouette-Schneideplotter (Cameo,
Portrait) die Kärtchen aus. Auf jeden Schnittbogen kommen dann Passermarken
im Silhouette-Format: links oben ein Quadrat, rechts oben und links unten je
ein Winkel mit 0,5 mm starken Linien, 10 mm vom Blattrand. Damit der Plotter die Marken sicher findet,
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


= API-Referenz

#show-module(read("../src/trimino.typ"), name: "trimino", only: ("trimino", "trimino-cut-file", "trimino-shapes"))

#show-module(read("../src/domino.typ"), name: "domino", only: ("domino",))
