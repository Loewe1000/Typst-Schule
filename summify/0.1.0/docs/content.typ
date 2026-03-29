#import "../../../schuldocs/0.1.0/lib.typ": show-example, show-module, show-code

= Über dieses Paket

Das `summify`-Paket ist ein *Cheatsheet- und Zusammenfassungs-System* für den Schulunterricht.
Es erzeugt strukturierte Dokumente im A3-Querformat mit farbigen Themenboxen, Abschnitten
und flexiblem Rasterlayout.

Kernkonzepte:

- `summify(...)` — Richtet die Seite ein (A3 quer, Header, Theme).
- `topic(...)` — Eine Themenbox mit farbiger Kopfleiste.
- `section(...)` — Ein Unterabschnitt innerhalb eines Topics.
- `content(...)` — Inhaltsbaustein mit optionaler Überschrift.
- `beside()` / `cols()` — Nebeneinander-Anordnung von Topics oder Inhalten.
- `below()` / `rows()` — Untereinander-Anordnung.
- `themes` — Vordefiniertes Theme-Dictionary (`"modern-blue"`, `"warm-sunset"`, `"dark-pro"`, `"default"`).

Das System eignet sich besonders für Physik-, Mathe- und Chemie-Formelsammlungen,
Abitur-Zusammenfassungen und Klausurvorbereitung.

= Schnellstart

Da `summify(...)` eine vollständige Seite mit `set page(...)` einrichtet, zeigen wir hier
ein komplettes Dokumentbeispiel mit `show-code`:

#show-code[```typ
#import "@schule/summify:0.1.0": *

#show: summify.with(
  title: "Physik – Mechanik",
  theme: "modern-blue",
)

#beside[
  #topic(title: "Kinematik", height: 10cm)[
    #section("Gleichförmige Bewegung")
    #content[$s = v dot t$]
    #section("Gleichmäßig beschleunigte Bewegung")
    #content[$s = 1/2 a t^2$]
    #content[$v = a dot t$]
  ]
][
  #topic(title: "Dynamik", height: 10cm)[
    #section("Newtonsche Gesetze")
    #content[
      1. #emph[Trägheitsprinzip]: Kein $F$ → kein $a$\
      2. $F = m dot a$\
      3. Actio = Reactio
    ]
    #section("Arbeit und Energie")
    #content[$W = F dot s dot cos(alpha)$]
    #content[$E_"kin" = 1/2 m v^2$]
  ]
]
```]

= Themenboxen

Themenboxen lassen sich mit `topic`, `section` und `content` direkt verwenden.
Im folgenden Beispiel sehen Sie den Aufbau einer typischen Themenbox:

#show-code[```typ
#import "@schule/summify:0.1.0": topic, section, content

// (innerhalb von #show: summify.with(...))
#topic(title: "Mechanik", height: 5cm)[
  #section("Newtonsche Gesetze")
  #content[$F = m dot a$]
  #content[$p = m dot v$]
  #section("Energie")
  #content[$E_"kin" = 1/2 m v^2$]
]
```]

= Themes

== Verfügbare Themes

Das `themes`-Dictionary enthält vier vordefinierte Farbthemes:

#show-code[```typ
#show: summify.with(
  title: "Meine Zusammenfassung",
  theme: "modern-blue",   // Professionelles Blau (Standard-Empfehlung)
  // theme: "warm-sunset", // Energetisches Bernstein/Orange
  // theme: "dark-pro",    // Elegantes Dunkelgrau für dunkle Hintergründe
  // theme: "default",     // Einfaches Standard-Theme
)
```]

Eigenschaften der Themes:

#show-code[```typ
// Struktur eines Theme-Dictionary (Auszug):
(
  colors: (
    primary:    rgb("…"),  // Kopfleisten-Farbe der Themenboxen
    on-primary: white,     // Textfarbe auf primary
    surface:    rgb("…"),  // Hintergrundfarbe des Themenbox-Inhalts
    border:     rgb("…"),  // Rahmenfarbe
  ),
  sizes: (
    title:  (height: 6mm, text: 12pt),
    header: (height: 6.5mm, text: 9pt),
    border: 1.5pt,
    radius: 8pt,
  ),
)
```]

== Theme-Overrides

Einzelne Theme-Eigenschaften können überschrieben werden:

#show-code[```typ
#show: summify.with(
  title: "Physik",
  theme: "modern-blue",
  theme-overrides: (
    colors: (primary: rgb("#e74c3c")),  // Rote Kopfleisten
    sizes: (radius: 0pt),              // Keine abgerundeten Ecken
  ),
)
```]

= Layout

== Nebeneinander (`beside` / `cols`)

`beside` und `cols` ordnen mehrere Topics oder Inhalte nebeneinander an:

#show-code[```typ
#beside[
  #topic(title: "Thema 1")[…]
][
  #topic(title: "Thema 2")[…]
][
  #topic(title: "Thema 3")[…]
]

// Mit angepassten Breiten-Verhältnissen:
#cols(ratios: (2, 1))[
  #topic(title: "Breiteres Thema")[…]
][
  #topic(title: "Schmaleres Thema")[…]
]
```]

== Untereinander (`below` / `rows`)

`below` und `rows` stapeln Inhalte vertikal:

#show-code[```typ
#below[
  #topic(title: "Oben")[…]
][
  #topic(title: "Unten")[…]
]
```]

== Inhalt ausblenden

Mit `hide-content: true` werden die Inhalte der `content(...)`-Blöcke ausgeblendet
und durch Lücken ersetzt — ideal für Übungsblätter:

#show-code[```typ
#show: summify.with(
  title: "Physik – Übungsblatt",
  theme: "warm-sunset",
  hide-content: true,   // Inhalte durch Lücken ersetzen
)
```]

= Parameter

== `summify`

#show-code[```typ
#show: summify.with(
  title: "",            // str: Titel in der Seitenkopfzeile
  paper: "a3",          // str: Papierformat (Standard: A3)
  flipped: true,        // bool: Querformat (Standard: true)
  hide-content: false,  // bool: Inhalte in content()-Blöcken ausblenden
  theme: "default",     // str oder dict: Theme-Name oder Theme-Dictionary
  theme-overrides: (:), // dict: Selektive Überschreibungen des gewählten Themes
)
```]

== `topic`

#show-code[```typ
#topic(
  title: none,    // str: Titel der Themenbox (erscheint in der farbigen Kopfleiste)
  height: 100%,   // length oder relative: Höhe der Box
  width: 100%,    // length oder relative: Breite der Box
  fill: auto,     // color: Hintergrundfarbe (auto = Theme)
  stroke: auto,   // stroke: Rahmen (auto = Theme)
  radius: auto,   // length: Eckenradius (auto = Theme)
)[Inhalt]
```]

== `section`

#show-code[```typ
#section(
  title,          // str: Abschnittsüberschrift
  fill: auto,     // color: Hintergrundfarbe (auto = Theme)
  height: auto,   // length: Höhe des Section-Balkens
)
```]

== `content`

#show-code[```typ
#content(
  title: none,          // str: Optionaler Inhaltstitel
  inset: auto,          // inset: Innenabstand (auto = Theme)
  align-content: start, // alignment: Ausrichtung des Inhalts
  hide: auto,           // bool: Inhalt ausblenden (auto = summify-hide-content)
)[Inhalt]
```]

= API-Referenz

#show-module(read("../summify.typ"), name: "summify")
