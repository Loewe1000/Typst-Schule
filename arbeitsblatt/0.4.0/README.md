# @schule/arbeitsblatt 0.4.0

Neu in 0.4.0: **Themes**. Alle Befehle bleiben gleich, nur `theme:` in
`arbeitsblatt.with(…)` wählt die Gestaltung:

```typ
#import "@schule/arbeitsblatt:0.4.0": *
#show: arbeitsblatt.with(title: "Größen umrechnen", class: "MA-05", print: true, theme: "klar")
```

| Theme     | Charakter                                                      |
|-----------|----------------------------------------------------------------|
| `none`    | klassisch wie bis 0.3.x (Standard)                             |
| `klar`    | sparsam und modern, Linien statt Flächen, tonerfreundlich      |
| `atlas`   | farbig wie ein Schulbuch, Titelkarte, Karten mit Reitern       |
| `skizze`  | verspielt für die Unterstufe, Handschrift, Klebeband, Namensfeld |
| `labor`   | technisch für MINT, Monospace-Marken, Messskala                |
| `kontur`  | plakativ, dicke schwarze Rahmen, harte Schatten, Futura-Versalien |
| `leiste`  | Fachfarben-Leiste an der Außenkante mit Kürzel und Seitenzahl  |
| `riso`    | Zweifarbdruck-Optik (Fachfarbe + Pink), versetzter Titel, Raster |
| `bauhaus` | geometrisch: Kreis, Quadrat, Dreieck als Nummern, Viertelkreis-Kästen |

Gemeinsam in allen Themes: Fachfarbe aus dem Kürzel (`MA` blau, `PH` orange,
`IF` grün, …; überschreibbar mit `akzent:`), Kopfzeile „Fach · Klasse“,
Kürzel/Seitenzahl/Aufgabennummer als gefüllte Marken, Lösungen grün. Mit Theme
werden kurze Aufgaben (< 9 cm) nicht über den Seitenwechsel gerissen.

Showcase: `showcase/render.sh` rendert `showcase/beispiel.typ` in allen Themes.
Benötigt `@schule/aufgaben:0.3.1` (Theme-Hooks).
