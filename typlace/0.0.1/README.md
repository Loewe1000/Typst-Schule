# typlace

Erstellt ein **Tischlayout für einen Klassenraum** aus einem einfachen mehrzeiligen String.  
Namen können zeilenweise auf die Sitzplätze verteilt werden.

## Layout-Zeichen

| Zeichen | Bedeutung |
|---------|-----------|
| `X` | Freier Platz (unsichtbar) |
| `T` | Ein Tisch / Sitzplatz |
| `P` | Teil eines großen Lehrerpults – aufeinanderfolgende `P`s in einer Zeile werden zu **einem** breiten Pult zusammengeführt |

## Verwendung

```typst
#import "@local/typlace:0.0.1": typlace

#let layout = "
XTTTTXXTTTTX
XXXXXXXXXXXX
XTTTTXXTTTTX
XXXXXXXXXXXX
XTTTTXXTTTTX
XXXXXXXXXXXX
XTTTTXXTTTTX
XXXXXXXXXXXX
XXXXPPPXXXX
"

#let namen = (
  "Anna", "Ben",  "Clara", "David",
  "Eva",  "Felix","Greta", "Hans",
  "Ida",  "Jonas","Klara", "Leon",
  "Mia",  "Nico", "Olivia","Paul",
)

#typlace(layout, namen: namen)
```

## Parameter

| Parameter | Typ | Standard | Beschreibung |
|-----------|-----|---------|--------------|
| `layout` | `str` | – | Mehrzeiliger Layout-String (Pflichtfeld) |
| `namen` | `array` | `()` | Namen, zeilenweise auf `T`-Plätze verteilt |
| `tisch-breite` | `length` | `2cm` | Breite einer Tischzelle |
| `tisch-hoehe` | `length` | `1.2cm` | Höhe einer Tischzelle |
| `tisch-farbe` | `color` | `rgb("#cce0f5")` | Füllfarbe der Tische |
| `pult-farbe` | `color` | `rgb("#6b4c2a")` | Füllfarbe des Lehrerpults |
| `rotation` | `int` | `0` | Rotation im Uhrzeigersinn: `0`, `90`, `180` oder `270` |

## Hinweise

- Jedes `T` ist **ein** Tischplatz; `TT` sind zwei nebeneinander.
- Mehrere aufeinanderfolgende `P` in **einer Zeile** ergeben ein einziges breites Pult.
- Zeilen mit unterschiedlicher Länge werden automatisch mit `X` aufgefüllt.
- Sind weniger Namen als Sitzplätze vorhanden, bleiben übrige Tische leer.
