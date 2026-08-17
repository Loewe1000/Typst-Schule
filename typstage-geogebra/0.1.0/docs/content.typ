#import "@schule/schuldocs:0.2.0": show-example, show-module, show-code, tip, info, warning

= Über dieses Paket

`typstage-geogebra` setzt GeoGebra-Applets in die Folien von `typstage` und
steuert sie Schritt für Schritt: die Konstruktion baut GeoGebra, die
Dramaturgie kommt aus den Folien. Auf jedem Schritt können Aufträge liegen --
Werte setzen, Objekte zeigen oder verbergen, Farben ändern, den Ausschnitt
verschieben, eine Bewegung anstoßen.

Dass das ein eigenes Paket ist, hat einen einfachen Grund: eine Präsentation
ohne Applets soll das Brückenskript nicht mitschleppen. Das Bootskript und das
Applet-Dokument sind einige Kilobyte, die sonst in jedem Foliensatz mitreisen
würden. Aus dem Kern braucht dieses Paket nur zwei öffentliche Teile --
`embed(bridge: …)` meldet einen Rahmen als Ziel an, `bridge-job` schickt ihm
auf einem Schritt etwas zu. Was in den Aufträgen steht, liest der Kern nicht.

Dieses Handbuch gliedert sich wie folgt:

+ *Schnellstart* -- ein Applet auf einer Folie
+ *Welches Applet gemeint ist* -- Namen und `target`
+ *Die Konstruktion aufbauen* -- `ggb-run` und seine Grenze
+ *Werte, Aussehen, Ausschnitt* -- `ggb-set`, `ggb-style`, `ggb-view`
+ *Bewegung* -- `ggb-animate` gegen `ggb-tween`
+ *Auf Papier* -- `fallback` und `link`
+ *Aussehen des Applets* -- `seamless`, `background`, Größe

= Schnellstart

Ein Applet steht mit `geogebra()` auf der Folie, die Befehle stehen im selben
Folienrumpf -- dort werden sie eingesammelt. Sie geben selbst nichts aus.

#show-code[```typ
#import "@schule/typstage:0.1.0": *
#import "@schule/typstage-geogebra:0.1.0": *

#presentation(
  slide([Ferngesteuert], {
    geogebra(app: "classic", perspective: "G", height: 240pt,
             link: "https://www.geogebra.org/calculator")
    ggb-run("a=1", "f(x)=a*x^2")
    ggb-set((a: 3), at: 2)
  }),
)
```]

Die Parabel steht von Anfang an da; auf Schritt 2 wird `a` auf 3 gesetzt und
sie zieht sich zusammen.

`at` ist bei allen Befehlen ein Schrittwähler wie bei `anim`: `2` heißt „ab
Schritt zwei“, `"1-2"`, `"2,4"` und `"-2"` heißen, was sie sagen. Vorgabe ist
`"1-"`, denn die meisten Aufträge richten die Konstruktion beim Betreten der
Folie ein. Der Applet-Rahmen selbst verbraucht keinen Schritt und schiebt auch
nichts weiter: die Stichpunkte neben ihm gehören auf Schritt eins, nicht hinter
seine Aufträge.

#info[
  Das Applet lebt nur im HTML-Export. Im PDF steht an seiner Stelle, was
  das Kapitel _Auf Papier_ beschreibt.
]

= Welches Applet gemeint ist

Im Schnellstart steht bei keinem Befehl ein Name. Mit einem Applet auf der
Folie gibt es nichts zu wählen, und die Befehle finden es von selbst -- gleich,
ob sie im Quelltext darüber oder darunter stehen.

Zwei Applets auf einer Folie brauchen Namen, und dann brauchen die Befehle
`target`. Der Name darf eine Zeichenkette sein oder eine Marke -- Typst färbt
sie als das, was sie ist:

#show-code[```typ
geogebra(<links>, height: 200pt)
geogebra(<rechts>, height: 200pt)
ggb-run("A=(0,0)", target: <links>)
ggb-run("B=(1,1)", target: "rechts")
```]

Fehlt die Angabe bei mehreren Applets, wird nicht geraten. Der Bau bricht ab
und nennt, was er gefunden hat:

#show-code[```
error: panicked with: typstage-geogebra: 2 applets on this slide
(links, rechts) — say which one is meant, e.g. target: "links".
```]

Ebenso, wenn auf der Folie überhaupt kein Applet steht. Ein stillschweigend
fallengelassener Befehl ist weit schwerer zu bemerken als ein
fehlgeschlagener Bau.

= Die Konstruktion aufbauen

`ggb-run` nimmt beliebig viele GeoGebra-Befehle und gibt sie einzeln an
`evalCommand` weiter. Die Reihenfolge zählt: was gebraucht wird, muss vorher
entstanden sein.

#show-code[```typ
ggb-run(at: "1-",
        "k: x^2+y^2=4", "t=Slider(0,6.283,0.01)",
        "P=(2cos(t),2sin(t))", "s=Segment((0,0),P)")
```]

#warning[
  GeoGebras Skriptbefehle -- `SetColor`, `SetValue`, `SetVisibleInView` und
  Verwandte -- nimmt `evalCommand` *nicht* an; in `ggb-run` blieben sie
  wirkungslos. Dafür gibt es `ggb-set`, `ggb-style`, `ggb-show` und
  `ggb-hide`: sie greifen zur JavaScript-Schnittstelle, die das kann.
]

Was GeoGebra ablehnt, verschwindet nicht lautlos: das Applet meldet die
abgewiesenen Befehle zurück, und die Laufzeit schreibt sie in die Konsole des
Browsers.

Beim Betreten einer Folie und beim Zurückblättern wird der Lauf von seinem
Anfang an wiederholt -- das Applet geht dazu in seinen Ausgangszustand zurück.
Befehle sollten deshalb wiederholbar sein. Aus demselben Grund lohnt es sich,
die Farbe gleich auf `"1-"` festzulegen: beim Neuaufbau vergäbe GeoGebra sonst
die nächste Farbe seiner Palette, und die Folie sähe nach dem Zurückblättern
anders aus.

#show-code[```typ
ggb-run("a=1", "f(x)=a*x^2", at: "1-")
ggb-style("f", at: "1-", color: dark, thickness: 3)
```]

#info[
  Eine `.ggb`-Datei lässt sich nicht einbetten: Typst kennt keine
  base64-Kodierung, und ohne sie kommt der Inhalt der Datei nie in die
  HTML-Datei. Die Konstruktion entsteht deshalb mit `ggb-run` -- oder sie wird
  über `material` von GeoGebra geladen: `geogebra(material: "abc123xy")`.
]

= Werte, Aussehen, Ausschnitt

`ggb-set` nimmt ein Wörterbuch aus Objektname und Wert, `ggb-show` und
`ggb-hide` beliebig viele Objektnamen. Üblich ist, alles zu Beginn aufzubauen
und erst sichtbar zu machen, wenn es an der Reihe ist:

#show-code[```typ
ggb-hide("P", "s", "t", at: "1-")
ggb-show("P", "s", at: 2)
ggb-set((a: 3), at: 2)
ggb-set((a: -2, b: 0.5), at: 3)
```]

== Aussehen

`ggb-style` nimmt die Objektnamen und dazu, was sich ändern soll. Alle Angaben
sind einzeln zu haben; was nicht genannt wird, bleibt, wie es ist.

#table(
  columns: (auto, 1fr),
  align: (left, left),
  stroke: 0.4pt + luma(75%),
  table.header([*Angabe*], [*Wirkung*]),
  [`color`], [Farbe -- eine Typst-Farbe, keine GeoGebra-Farbe],
  [`thickness`], [Strichstärke],
  [`line-style`], [Strichart als Zahl (durchgezogen, gestrichelt, gepunktet …)],
  [`filling`], [Füllung, 0 bis 1],
  [`point-size`], [Punktgröße],
  [`trace`], [Spur an oder aus],
  [`label`], [Beschriftung sichtbar oder nicht],
  [`label-mode`], [Art der Beschriftung als Zahl (Name, Wert, Beschriftung …)],
  [`fixed`], [gegen Verschieben festhalten],
  [`caption`], [eigene Beschriftung],
  [`layer`], [Ebene, also was vor was liegt],
  [`position`], [Ort als `(x, y)`],
)

Dass `color` eine Typst-Farbe nimmt, ist der Punkt daran: die Konstruktion
trägt die Farben der Folien statt GeoGebras Palette.

#show-code[```typ
ggb-style("P", at: 2, color: accent, point-size: 6)
ggb-style("s", at: 2, color: dark, thickness: 3)
ggb-style("d", at: 3, color: accent, filling: 0.18, thickness: 4)
```]

== Ausschnitt

`ggb-view` setzt den sichtbaren Bereich sowie Gitter und Achsen. `x` und `y`
wirken nur zusammen -- beide sind Paare aus kleinstem und größtem Wert.

#show-code[```typ
ggb-view(at: 2, x: (-3, 3), y: (-3, 3), grid: false)
ggb-view(at: 3, axes: false)
```]

= Bewegung

Es gibt zwei Arten, etwas in Bewegung zu setzen, und sie tun Verschiedenes.

`ggb-animate` startet GeoGebras eigene Animation. Sie läuft ohne Ende hin und
her, bis die Folie verlassen wird -- richtig für einen Punkt, der auf einem
Kreis umläuft, oder einen Schieberegler, der einen Zusammenhang vorführt.
`trace` schaltet die Spur der genannten Objekte ein, `speed` regelt das Tempo,
`playing: false` hält an.

#show-code[```typ
ggb-animate("t", at: 3, speed: 1.2, trace: ("P",))
```]

`ggb-tween` geht einmal von A nach B und bleibt dort. Der Browser zählt den
Wert Bild für Bild hoch; ein Objekt, das von ihm abhängt, wächst mit -- eine
Strecke, deren Endpunkt wandert, ein Bogen, dessen Winkel folgt. So zeichnet
sich die Konstruktion selbst. `from` gibt den Anfangswert, wenn er nicht der
gerade geltende sein soll, `duration` die Dauer in Millisekunden, `easing` den
Verlauf (`"ease-in-out"` oder `"linear"`).

#show-code[```typ
ggb-run("t_1=0", "s=Segment(A,(4*t_1,0))", at: "1-")
ggb-tween("t_1", at: 2, to: 1, duration: 700)
```]

#warning[
  `ggb-tween` braucht eine Schrittnummer, keinen Bereich: `at: 2`, nicht
  `at: "2-"`. Sonst bricht der Bau mit „`ggb-tween() needs a step number`“ ab.

  Und ein Tween auf Schritt 1 käme nie als Bewegung an: beim Betreten einer
  Folie spielt die Laufzeit den Lauf bis zum aktuellen Schritt sofort nach, und
  Tweens werden dabei auf ihren Zielwert gesetzt statt abgespielt. Schritt 1
  ist zum Aufbauen da; gezeichnet wird ab Schritt 2.
]

Ab dem Schritt nach dem Tween sitzt der Wert ohnehin auf seinem Ziel. Wer
zurückblättert, sieht deshalb die fertige Zeichnung und nicht die Bewegung ein
zweites Mal.

= Auf Papier

Im PDF gibt es kein Applet. Ohne weitere Angabe bleibt ein beschrifteter
Platzhalter in der Größe des Rahmens; `link` setzt darunter den Weg zum
lebenden Applet, anklickbar im PDF.

#show-example(
  rendered: {
    import "../src/lib.typ": geogebra
    geogebra(height: 90pt, link: "https://www.geogebra.org/calculator")
  },
  source: ```typ
  #geogebra(height: 90pt, link: "https://www.geogebra.org/calculator")
  ```,
  width: 12cm,
)

Besser ist eine eigene Zeichnung an seiner Stelle. `fallback` nimmt beliebigen
Inhalt -- ein Bild, eine Tabelle, und vor allem eine Zeichnung mit CeTZ:

#show-example(
  rendered: {
    import "../src/lib.typ": geogebra
    import "@schule/typstage:0.1.0": dark
    import "@preview/cetz:0.4.2"
    geogebra(height: 120pt, link: "https://www.geogebra.org/calculator",
      fallback: cetz.canvas(length: 0.8cm, {
        import cetz.draw: *
        line((-2.6, 0), (2.6, 0), stroke: luma(70%))
        line((0, -0.4), (0, 2.6), stroke: luma(70%))
        line(..range(0, 45).map(i => (-2.2 + i * 0.1, 0.5 * calc.pow(-2.2 + i * 0.1, 2))),
             stroke: dark + 1.6pt)
      }))
  },
  source: ```typ
  #geogebra(height: 120pt, link: "https://www.geogebra.org/calculator",
    fallback: cetz.canvas(length: 0.8cm, {
      import cetz.draw: *
      line((-2.6, 0), (2.6, 0), stroke: luma(70%))
      line((0, -0.4), (0, 2.6), stroke: luma(70%))
      line(..range(0, 45).map(i => (-2.2 + i * 0.1, 0.5 * calc.pow(-2.2 + i * 0.1, 2))),
           stroke: dark + 1.6pt)
    }))
  ```,
  width: 12cm,
)

Beide Angaben wirken nur im PDF; im Browser steht dort das Applet selbst.

= Aussehen des Applets

Vorgabe ist `seamless: true`: das Applet trägt keinen eigenen Rahmen, und
seine Zeichenfläche bekommt die Farbe der Folie. Es sieht dann nicht mehr wie
ein Fenster im Fenster aus, sondern wie ein Teil der Folie. `background`
bestimmt diese Farbe; `auto` nimmt das Papierweiß der Präsentation, was auf
einer getönten Folie zu ändern ist.

#show-code[```typ
geogebra(height: 240pt, background: rgb("#f4f1ea"))
geogebra(height: 240pt, seamless: false)   // mit GeoGebras eigenem Rahmen
```]

`grid` und `axes` lassen GeoGebras Vorgabe stehen, solange sie `auto` sind,
und erzwingen sonst das eine oder andere. `perspective: "G"` zeigt nur die
Grafik-Ansicht, `app` wählt die GeoGebra-App (Vorgabe `"classic"`), `language`
die Sprache der Oberfläche, `animation-button` blendet GeoGebras Abspielknopf
ein.

#info[
  Das Applet wird von `codebase` geladen, ab Werk von `geogebra.org`. Ohne
  Netz bleibt der Rahmen leer; wer offline vorführt, legt GeoGebras Dateien
  daneben und zeigt mit `codebase` darauf.
]

== Größe

`width` und `height` geben die Größe in den Maßen der Folie -- nicht in
Bildschirmpunkten. Um das Applet kümmert sich die Laufzeit: sie setzt den
Rahmen auf die Foliengröße und vergrößert ihn dann mit `zoom`, nicht mit
`transform: scale()`.

Der Unterschied ist zu sehen. Eine Skalierung dehnt das fertige Rasterbild:
das Applet hat 400 Pixel breit gezeichnet und würde auf 460 aufgeblasen --
unscharf. `zoom` wirkt vor dem Rastern; das innere Fenster bleibt bei 400
Punkten, seine Pixeldichte steigt mit. Das Applet sieht so auf jeder
Bildschirmgröße denselben Ausschnitt, gestochen scharf.

#tip[
  Zwei Applets nebeneinander stehen am besten in einem `grid`, jedes mit
  `width: 100%` und eigener Höhe.
]

= API-Referenz

Erzeugt aus den Kommentaren der Quelldatei. `resolve-target` und
`no-stray-target` gehören zum Innenleben und stehen deshalb nicht dabei.

#show-module(read("../src/lib.typ"), name: "typstage-geogebra",
             exclude: ("resolve-target", "no-stray-target"))
