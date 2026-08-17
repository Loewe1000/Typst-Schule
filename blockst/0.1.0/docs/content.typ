#import "@schule/schuldocs:0.2.0": show-example, show-module, show-code
#import "../lib.typ": scratch, set-blockst, blockst
#import scratch.de: *
#set-blockst(scale: 82%)

#let scratch-table(entries) = context {
  if target() == "html" {
    html.elem("div", attrs: (style: "margin-bottom: 1.75rem; border: 1px solid #e5e7eb; border-radius: 6px; overflow: hidden;"),
      html.elem("table", attrs: (style: "width: 100%; border-collapse: collapse;"),
        entries.map(e => html.elem("tr", {
          html.elem("td", attrs: (style: "padding: 4px 8px; border-bottom: 1px solid #e5e7eb; font-size: 0.85em; vertical-align: middle; white-space: nowrap;"),
            raw(lang: "typ", e.at(0))
          )
          html.elem("td", attrs: (style: "padding: 4px 8px; border-bottom: 1px solid #e5e7eb; vertical-align: middle;"),
            html.frame(std.block(e.at(1)))
          )
        })).join()
      )
    )
  } else {
    table(
      columns: (auto, auto),
      align: (left + horizon, left + horizon),
      row-gutter: 4pt,
      inset: (x: 6pt, y: 5pt),
      stroke: (x, y) => (top: if y > 0 { 0.4pt + luma(215) } else { none }, bottom: none, left: none, right: none),
      ..entries.map(e => (raw(lang: "typ", e.at(0)), e.at(1))).flatten()
    )
  }
}

= Über dieses Paket

Das `blockst`-Paket rendert *Scratch-Programmierblöcke* in Typst-Dokumente —
ideal für Informatik-Unterrichtsmaterialien, Arbeitsblätter und Klausuren.

Die Blöcke stehen in drei Sprachen zur Verfügung:

- `scratch.de` — Deutsch (z. B. `wenn-gruene-flagge-geklickt`, `gehe`, `wiederhole`)
- `scratch.en` — Englisch (z. B. `when-flag-clicked`, `move`, `repeat`)
- `scratch.fr` — Französisch

Zusätzlich stehen drei visuelle Themes zur Auswahl: `"normal"`, `"dark"` und `"high-contrast"`.

= Schnellstart

#show-example(
  rendered: {
    import "../lib.typ": blockst, scratch
    blockst[
      #import scratch.de: *
      #wenn-gruene-flagge-geklickt[
        #gehe(schritte: 10)
        #warte(dauer: 1)
        #sage("Hallo!")
      ]
    ]
  },
  source: ```typ
#import "@schule/blockst:0.1.0": blockst, scratch

#blockst[
  #import scratch.de: *
  #wenn-gruene-flagge-geklickt[
    #gehe(schritte: 10)
    #warte(dauer: 1)
    #sage("Hallo!")
  ]
]
  ```,
)

Das `blockst[...]`-Environment aktiviert die Scratch-Darstellung. Innerhalb
des Blocks werden zuerst die Sprachbausteine importiert, dann die Blöcke zusammengesetzt.

= Schleifen und Bedingungen

== Wiederholung

#show-example(
  rendered: {
    import "../lib.typ": blockst, scratch
    blockst[
      #import scratch.de: *
      #wenn-gruene-flagge-geklickt[
        #wiederhole(anzahl: 4)[
          #gehe(schritte: 100)
          #drehe-rechts(grad: 90)
        ]
      ]
    ]
  },
  source: ```typ
#blockst[
  #import scratch.de: *
  #wenn-gruene-flagge-geklickt[
    #wiederhole(anzahl: 4)[
      #gehe(schritte: 100)
      #drehe-rechts(grad: 90)
    ]
  ]
]
  ```,
)

== Bedingung mit Sonst-Zweig

#show-example(
  rendered: {
    import "../lib.typ": blockst, scratch
    blockst[
      #import scratch.de: *
      #wenn-gruene-flagge-geklickt[
        #falls-sonst("wird Taste 'Leertaste' gedrückt?")[
          #gehe(schritte: 10)
        ][
          #sage("Stopp!")
        ]
      ]
    ]
  },
  source: ```typ
#blockst[
  #import scratch.de: *
  #wenn-gruene-flagge-geklickt[
    #falls-sonst("wird Taste 'Leertaste' gedrückt?")[
      #gehe(schritte: 10)
    ][
      #sage("Stopp!")
    ]
  ]
]
  ```,
)

== Endlosschleife mit Variablen

#show-example(
  rendered: {
    import "../lib.typ": blockst, scratch
    blockst[
      #import scratch.de: *
      #wenn-gruene-flagge-geklickt[
        #setze-variable("Punkte", 0)
        #wiederhole-fortlaufend[
          #aendere-variable("Punkte", 1)
          #warte(dauer: 1)
        ]
      ]
    ]
  },
  source: ```typ
#blockst[
  #import scratch.de: *
  #wenn-gruene-flagge-geklickt[
    #setze-variable("Punkte", 0)
    #wiederhole-fortlaufend[
      #aendere-variable("Punkte", 1)
      #warte(dauer: 1)
    ]
  ]
]
  ```,
)

= Englische Blöcke

Für internationale Kontexte oder englischsprachige Schulen kann `scratch.en` importiert werden:

#show-example(
  rendered: {
    import "../lib.typ": blockst, scratch
    blockst[
      #import scratch.en: *
      #when-flag-clicked[
        #repeat(times: 10)[
          #move(steps: 10)
          #turn-right(degrees: 36)
        ]
      ]
    ]
  },
  source: ```typ
#blockst[
  #import scratch.en: *
  #when-flag-clicked[
    #repeat(count: 10)[
      #move(steps: 10)
      #turn-right(degrees: 36)
    ]
  ]
]
  ```,
)

= Themes und Skalierung

Mit `theme` und `scale` lassen sich Aussehen und Größe der Blöcke anpassen:

#show-code[```typ
// Dunkles Theme, 120% Größe
#blockst(theme: "dark", scale: 120%)[
  #import scratch.de: *
  #wenn-gruene-flagge-geklickt[
    #gehe(schritte: 10)
  ]
]

// Kontrastarmes Theme für Projektion
#blockst(theme: "high-contrast")[
  #import scratch.de: *
  #sage("Guten Morgen!")
]
```]

Globale Einstellungen für alle Blöcke auf einer Seite:

#show-code[```typ
#import "@schule/blockst:0.1.0": blockst, scratch, set-blockst

// Alle folgenden blockst()-Aufrufe verwenden dieses Theme und diese Größe
#set-blockst(theme: "dark", scale: 80%)
```]

= Verfügbare Blöcke (Deutsch)

#show-code[```typ
// Ereignisse (Hut-Blöcke)
#wenn-gruene-flagge-geklickt[...]
#wenn-taste-gedrueckt("Leertaste")[...]
#wenn-diese-figur-angeklickt[...]
#wenn-nachricht-empfangen("start")[...]

// Bewegung
#gehe(schritte: 10)
#drehe-rechts(grad: 15)
#drehe-links(grad: 15)
#gehe-zu(x: 0, y: 0)
#aendere-x(dx: 10)
#aendere-y(dy: 10)

// Steuerung
#warte(dauer: 1)
#wiederhole(anzahl: 10)[...]
#wiederhole-fortlaufend[...]
#falls("Bedingung")[...]
#falls-sonst("Bedingung")[...][...]

// Variablen
#setze-variable("Name", 0)
#aendere-variable("Name", 1)

// Aussehen
#sage("Text")
#sage-fuer-sekunden("Text", sekunden: 2)
#denke("Hmm...")
#zeige-dich()
#verstecke-dich()

// Kommunikation
#sende-nachricht("start")
#sende-nachricht-und-warte("fertig")
```]

= Parameter

#show-code[```typ
#blockst(
  theme: auto,   // str: "normal", "dark" oder "high-contrast" (auto = globale Einstellung)
  scale: auto,   // ratio: Skalierung der Blöcke (auto = globale Einstellung)
)[
  // Scratch-Blöcke …
]

// Globale Einstellung (gilt für alle nachfolgenden blockst()-Aufrufe)
#set-blockst(
  theme: none,        // str: Theme setzen (none = unverändert)
  scale: none,        // ratio: Skalierung setzen (none = unverändert)
  stroke-width: none, // length: Linienstärke (none = unverändert)
)
```]

= API-Referenz

== blockst-Container

#show-module(read("../lib.typ"), name: "blockst")

== Scratch-Blöcke (scratch.de)

Die deutschen Scratch-Blöcke sind in Kategorien gegliedert. Alle Blöcke werden
innerhalb von `#blockst[#import scratch.de: * ...]` verwendet.
Die linke Spalte zeigt den Typst-Aufruf, die rechte den gerenderten Block.

=== Ereignisse

#scratch-table((
  ("#wenn-gruene-flagge-geklickt[...]",         wenn-gruene-flagge-geklickt([])),
  ("#wenn-taste-gedrueckt(\"Leertaste\")[...]",  wenn-taste-gedrueckt("Leertaste", [])),
  ("#wenn-diese-figur-angeklickt[...]",          wenn-diese-figur-angeklickt([])),
  ("#wenn-buehnenbildwechsel(\"Szene1\")[...]",  wenn-buehnenbildwechsel("Szene1", [])),
  ("#wenn-nachricht-empfangen(\"start\")[...]",  wenn-nachricht-empfangen("start", [])),
  ("#sende-nachricht(\"start\")",                sende-nachricht("start")),
  ("#sende-nachricht-und-warte(\"fertig\")",     sende-nachricht-und-warte("fertig")),
))

=== Bewegung

#scratch-table((
  ("#gehe(schritte: 10)",                    gehe(schritte: 10)),
  ("#drehe-rechts(grad: 15)",                drehe-rechts(grad: 15)),
  ("#drehe-links(grad: 15)",                 drehe-links(grad: 15)),
  ("#gehe-zu-position(\"Zufallsposition\")", gehe-zu-position("Zufallsposition")),
  ("#gehe-zu(x: 0, y: 0)",                  gehe-zu(x: 0, y: 0)),
  ("#gleite-zu(sekunden: 1, x: 0, y: 0)",   gleite-zu(sekunden: 1, x: 0, y: 0)),
  ("#setze-richtung(richtung: 90)",          setze-richtung(richtung: 90)),
  ("#drehe-dich-zu(\"Mauszeiger\")",         drehe-dich-zu("Mauszeiger")),
  ("#aendere-x(dx: 10)",                     aendere-x(dx: 10)),
  ("#setze-x(x: 0)",                         setze-x(x: 0)),
  ("#aendere-y(dy: 10)",                     aendere-y(dy: 10)),
  ("#setze-y(y: 0)",                         setze-y(y: 0)),
  ("#pralle-vom-rand-ab()",                  pralle-vom-rand-ab()),
  ("#setze-drehtyp(\"links-rechts\")",       setze-drehtyp("links-rechts")),
  ("#x-position()",                          x-position()),
  ("#y-position()",                          y-position()),
  ("#richtung()",                            richtung()),
))

=== Aussehen

#scratch-table((
  ("#sage-fuer-sekunden(\"Hallo!\", sekunden: 2)",  sage-fuer-sekunden("Hallo!", sekunden: 2)),
  ("#sage(\"Hallo!\")",                             sage("Hallo!")),
  ("#denke-fuer-sekunden(\"Hmm...\", sekunden: 2)", denke-fuer-sekunden("Hmm...", sekunden: 2)),
  ("#denke(\"Hmm...\")",                            denke("Hmm...")),
  ("#wechsle-zu-kostuem(\"Kostüm1\")",              wechsle-zu-kostuem("Kostüm1")),
  ("#naechstes-kostuem()",                          naechstes-kostuem()),
  ("#wechsle-zu-buehnenbild(\"Bühne1\")",           wechsle-zu-buehnenbild("Bühne1")),
  ("#naechstes-buehnenbild()",                      naechstes-buehnenbild()),
  ("#aendere-groesse(aenderung: 10)",               aendere-groesse(aenderung: 10)),
  ("#setze-groesse(groesse: 100)",                  setze-groesse(groesse: 100)),
  ("#aendere-effekt(\"Farbe\", aenderung: 25)",     aendere-effekt("Farbe", aenderung: 25)),
  ("#setze-effekt(\"Farbe\", wert: 0)",             setze-effekt("Farbe", wert: 0)),
  ("#schalte-grafikeffekte-aus()",                  schalte-grafikeffekte-aus()),
  ("#zeige-dich()",                                 zeige-dich()),
  ("#verstecke-dich()",                             verstecke-dich()),
  ("#gehe-zu-ebene(\"vorne\")",                     gehe-zu-ebene("vorne")),
  ("#gehe-ebenen(anzahl: 1, \"vorwärts\")",         gehe-ebenen(anzahl: 1, "vorwärts")),
  ("#kostuem-eigenschaft(\"Nummer\")",              kostuem-eigenschaft("Nummer")),
  ("#buehnenbild-eigenschaft(\"Nummer\")",          buehnenbild-eigenschaft("Nummer")),
  ("#groesse()",                                    groesse()),
))

=== Klang

#scratch-table((
  ("#spiele-klang-ganz(\"Miau\")",                     spiele-klang-ganz("Miau")),
  ("#spiele-klang(\"Miau\")",                          spiele-klang("Miau")),
  ("#stoppe-alle-klaenge()",                           stoppe-alle-klaenge()),
  ("#aendere-klangeffekt(\"Tonhöhe\", wert: 10)",      aendere-klangeffekt("Tonhöhe", wert: 10)),
  ("#setze-klangeffekt(\"Tonhöhe\", wert: 100)",       setze-klangeffekt("Tonhöhe", wert: 100)),
  ("#schalte-klangeffekte-aus()",                      schalte-klangeffekte-aus()),
  ("#aendere-lautstaerke(lautstaerke: -10)",           aendere-lautstaerke(lautstaerke: -10)),
  ("#setze-lautstaerke(lautstaerke: 100)",             setze-lautstaerke(lautstaerke: 100)),
  ("#lautstaerke()",                                   lautstaerke()),
))

=== Malstift

#scratch-table((
  ("#loesche-alles()",                              loesche-alles()),
  ("#hinterlasse-abdruck()",                        hinterlasse-abdruck()),
  ("#schalte-stift-ein()",                          schalte-stift-ein()),
  ("#schalte-stift-aus()",                          schalte-stift-aus()),
  ("#setze-stiftfarbe-auf(blue)",                   setze-stiftfarbe-auf(blue)),
  ("#aendere-stift-param(\"Farbe\", wert: 10)",     aendere-stift-param("Farbe", wert: 10)),
  ("#setze-stift-param(\"Farbe\", wert: 50)",       setze-stift-param("Farbe", wert: 50)),
  ("#aendere-stiftdicke(dicke: 1)",                 aendere-stiftdicke(dicke: 1)),
  ("#setze-stiftdicke(dicke: 1)",                   setze-stiftdicke(dicke: 1)),
))

=== Steuerung

#scratch-table((
  ("#warte(dauer: 1)",                              warte(dauer: 1)),
  ("#wiederhole(anzahl: 10)[...]",                  wiederhole(anzahl: 10, [])),
  ("#wiederhole-fortlaufend[...]",                  wiederhole-fortlaufend([])),
  ("#falls(\"Bedingung?\")[...]",                   falls("Bedingung?", [])),
  ("#falls-sonst(\"Bedingung?\")[...][...]",        falls-sonst("Bedingung?", [], [])),
  ("#warte-bis(\"Bedingung?\")",                    warte-bis("Bedingung?")),
  ("#wiederhole-bis(\"Bedingung?\")[...]",          wiederhole-bis("Bedingung?", [])),
  ("#stoppe(\"alle\")",                             stoppe("alle")),
  ("#wenn-ich-als-klon-entstehe[...]",              wenn-ich-als-klon-entstehe([])),
  ("#erzeuge-klon(\"mich selbst\")",               erzeuge-klon("mich selbst")),
  ("#loesche-diesen-klon()",                        loesche-diesen-klon()),
))

=== Fühlen

#scratch-table((
  ("#wird-beruehrt(\"Kante\")",                    wird-beruehrt("Kante")),
  ("#wird-farbe-beruehrt(blue)",                   wird-farbe-beruehrt(blue)),
  ("#farbe-beruehrt-farbe(blue, green)",           farbe-beruehrt-farbe(blue, green)),
  ("#entfernung-von(\"Mauszeiger\")",              entfernung-von("Mauszeiger")),
  ("#frage(\"Wie heißt du?\")",                    frage("Wie heißt du?")),
  ("#antwort()",                                   antwort()),
  ("#taste-gedrueckt(\"Leertaste\")",              taste-gedrueckt("Leertaste")),
  ("#maustaste-gedrueckt()",                       maustaste-gedrueckt()),
  ("#maus-x()",                                    maus-x()),
  ("#maus-y()",                                    maus-y()),
  ("#setze-ziehbarkeit(\"ziehbar\")",              setze-ziehbarkeit("ziehbar")),
  ("#lautstaerke-fuehlen()",                       lautstaerke-fuehlen()),
  ("#stoppuhr()",                                  stoppuhr()),
  ("#setze-stoppuhr-zurueck()",                    setze-stoppuhr-zurueck()),
  ("#eigenschaft-von(\"x-Position\", \"Figur1\")", eigenschaft-von("x-Position", "Figur1")),
  ("#aktuell(\"Jahr\")",                           aktuell("Jahr")),
  ("#tage-seit-2000()",                            tage-seit-2000()),
  ("#benutzername()",                              benutzername()),
))

=== Operatoren

#scratch-table((
  ("#addiere(5, 3)",                          addiere(5, 3)),
  ("#subtrahiere(10, 4)",                     subtrahiere(10, 4)),
  ("#multipliziere(3, 4)",                    multipliziere(3, 4)),
  ("#dividiere(10, 2)",                       dividiere(10, 2)),
  ("#zufallszahl(von: 1, bis: 10)",           zufallszahl(von: 1, bis: 10)),
  ("#groesser-als(5, 3)",                     groesser-als(5, 3)),
  ("#kleiner-als(3, 5)",                      kleiner-als(3, 5)),
  ("#gleich(5, 5)",                           gleich(5, 5)),
  ("#und(operand1, operand2)",                und([], [])),
  ("#oder(operand1, operand2)",               oder([], [])),
  ("#nicht(operand)",                         nicht([])),
  ("#verbinde(\"Hallo \", \"Welt\")",         verbinde("Hallo ", "Welt")),
  ("#zeichen-von(1, \"Welt\")",              zeichen-von(1, "Welt")),
  ("#laenge-von(\"Welt\")",                  laenge-von("Welt")),
  ("#enthaelt(\"Apfel\", \"a\")",            enthaelt("Apfel", "a")),
  ("#modulo(10, 3)",                          modulo(10, 3)),
  ("#runde(3.14)",                            runde(3.14)),
  ("#mathematik(\"Wurzel\", 9)",             mathematik("Wurzel", 9)),
))

=== Variablen

#scratch-table((
  ("#setze-variable(\"Punkte\", 0)",             setze-variable("Punkte", 0)),
  ("#aendere-variable(\"Punkte\", 1)",           aendere-variable("Punkte", 1)),
  ("#zeige-variable(\"Punkte\")",                zeige-variable("Punkte")),
  ("#verstecke-variable(\"Punkte\")",            verstecke-variable("Punkte")),
  ("#variable(name: \"Punkte\", wert: 42)",      variable(name: "Punkte", wert: 42)),
))

=== Listen

#scratch-table((
  ("#fuege-zu-liste-hinzu(\"x\", \"Liste\")",     fuege-zu-liste-hinzu("x", "Liste")),
  ("#entferne-aus-liste(1, \"Liste\")",            entferne-aus-liste(1, "Liste")),
  ("#entferne-alles-aus-liste(\"Liste\")",         entferne-alles-aus-liste("Liste")),
  ("#fuege-bei-ein(\"x\", 1, \"Liste\")",          fuege-bei-ein("x", 1, "Liste")),
  ("#ersetze-element(1, \"Liste\", \"y\")",        ersetze-element(1, "Liste", "y")),
  ("#element-von-liste(1, \"Liste\")",             element-von-liste(1, "Liste")),
  ("#nummer-von-element(\"x\", \"Liste\")",        nummer-von-element("x", "Liste")),
  ("#laenge-von-liste(\"Liste\")",                 laenge-von-liste("Liste")),
  ("#liste-enthaelt(\"Liste\", \"x\")",            liste-enthaelt("Liste", "x")),
  ("#zeige-liste(\"Liste\")",                      zeige-liste("Liste")),
  ("#verstecke-liste(\"Liste\")",                  verstecke-liste("Liste")),
))

=== Eigene Blöcke

#scratch-table((
  ("#let mein-block = eigener-block(\"springe \", (name: \"h\"), \" px\")",  {let mein-block = eigener-block("springe ", (name: "h"), " px"); mein-block(40)}),
  ("#definiere(mein-block, body)",   {let mein-block = eigener-block("springe ", (name: "h"), " px"); definiere(mein-block, aendere-y(dy: eigene-eingabe("h")))}),
  ("#mein-block(40)",               {let mein-block = eigener-block("springe ", (name: "h"), " px"); mein-block(40)}),
  ("#eigene-eingabe(\"h\")",         eigene-eingabe("h")),
))
