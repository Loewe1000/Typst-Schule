# schuldocs 0.2.0

Dokumentation für das Schule-Paket-Ökosystem: Handbuch (PDF) und Website (HTML)
entstehen aus einer Quelle, in einem einzigen Lauf.

Gegenüber 0.1.0 entfallen `mantys` und `manifesto` als Abhängigkeiten. Beide
Ausgaben kommen aus dem Bündel-Export von Typst 0.15; eine Nachbearbeitung der
erzeugten Dateien ist nicht mehr nötig.

## Bauen

    typst compile docs/docs.typ build --format bundle --features bundle,html --root /

Im Zielverzeichnis liegen danach:

    build/index.html      die Website
    build/docs.css        ihre Stilvorlage, im <head> verlinkt
    build/<paket>.pdf     das Handbuch

## Eine Doku anlegen

`docs/docs.typ` — die einzige Quelldatei:

```typ
#import "@schule/schuldocs:0.2.0": docs, doc-target, show-code, show-example, show-module

#show: docs.with(
  toml: toml("../typst.toml"),
  authors: ("Lukas Köhl", "Alexander Schulz"),
  abstract: [Wofür das Paket gedacht ist, in zwei bis vier Sätzen.],
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
  notices: ([Teil des Schule-Ökosystems],),
)

#include "content.typ"
```

Name, Version, Beschreibung und Lizenz stammen aus `typst.toml`. Der Körper
wird zweimal gesetzt — einmal je Ausgabe.

## Öffentliche Namen

| Name | Kurz |
| --- | --- |
| `docs(…)` | Show-Regel, erzeugt das Bündel |
| `show-example(…)` | Beispiel: Quelltext und gesetztes Ergebnis |
| `show-code(…)` | nur Quelltext |
| `show-module(…)` | API-Referenz aus den `///`-Kommentaren |
| `doc-target()` | `"web"` oder `"pdf"` — welche Ausgabe gerade läuft |

### docs()

```typ
#let docs(
  toml: none,             // toml("../typst.toml")
  authors: (),            // Zeichenketten; leer heißt: die aus typst.toml
  abstract: [],           // Fließtext für die Titelseite
  links: (),              // ((name: "GitHub", url: "…"),)
  notices: (),            // kurze Hinweise für den Kopf der Website
  pdf-name: auto,         // Vorgabe: "<paketname>.pdf"
  html-name: "index.html",
) = …
```

Beide Schreibweisen der Show-Regel sind zulässig: `#show: docs.with(toml: …)`
und `#show: docs(toml: …)`.

### doc-target()

Liefert `"web"` oder `"pdf"`. Steht in einem Zustand und muss deshalb in einem
`context` abgefragt werden:

```typ
#context {
  if doc-target() == "web" { html.frame(zeichnung) } else { zeichnung }
}
```

Nicht `target()` benutzen: innerhalb von `html.frame` meldet es fälschlich
`paged`. `doc-target()` stimmt auch dort.

## Beides im Blick behalten

* Im HTML-Export gibt es kein Seitenlayout. Gesetzter Inhalt — CeTZ-Zeichnungen,
  alles mit fester Breite — gehört dort in `html.frame(…)`, sonst warnt Typst
  („pad was ignored during HTML export") oder verliert ihn.
* Beide Ausgaben teilen sich einen Introspektions-Raum. `docs()` setzt die
  Zähler zu Beginn jeder Ausgabe zurück und trennt die Überschriften der beiden
  Durchgänge über eine Marke am Anfang des Handbuchs. Wer selbst `query()`
  benutzt, muss diese Trennung mitdenken (`schuldocs-pdf-anfang`).

## Aufbau

    src/lib.typ         nur Re-Export der öffentlichen Namen
    src/config.typ      Farben, Maße, Schriften, Ausgabe-Zustand
    src/bundle.typ      docs() — beide Dokumente und die Stilvorlage
    src/theme-pdf.typ   Handbuch: Titelseite, Verzeichnis, Kopf- und Fußzeile
    src/theme-web.typ   Website: <head>, Kopfbereich, Navigation, Anker
    src/assets/docs.css Aussehen der Website
    src/display.typ     show-example, show-code
    src/api.typ         show-module

## Klassen der Website

Das Aussehen kommt aus `docs.css`. Wer in `display.typ` oder `api.typ` neue
Klassen vergibt, muss sie dort ergänzen. Belegt sind:

    .kopf .kopf-inhalt .version .beschreibung .hinweise .verweise
    .rahmen  nav.inhalt  .inhalt-titel  .anker
    .sd-code  .sd-example  .sd-example--split
    .sd-example-code  .sd-example-render

## Umstieg von 0.1.0

`with-pdf()` und `with-web()` entfallen; an ihre Stelle tritt `docs()`. Aus
`docs/manual.typ` und `docs/web.typ` wird eine Datei. `show-example()`,
`show-code()` und `show-module()` behalten ihre Namen und ihre bisherigen
Argumente.

## Keine Marken im Inhalt

Der Inhalt wird zweimal ausgegeben — einmal als Website, einmal als Handbuch —
und Marken gelten im Bündel dokumentübergreifend. Eine Marke in `content.typ`
erscheint deshalb doppelt, und Typst bricht ab:

    error: label <auf-papier> occurs multiple times in the document

Interne Querverweise über `<marke>` und `#link(<marke>)` sind mit dieser
Bauweise also nicht möglich. Verweise im Text auf das Kapitel beim Namen; auf
der Website trägt jede Überschrift ohnehin einen eigenen Anker.
