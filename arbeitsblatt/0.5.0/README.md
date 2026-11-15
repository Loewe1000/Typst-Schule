# arbeitsblatt

Vorlage für Arbeitsblätter im Schulunterricht: Kopfzeile, Aufgaben mit Lösungen, Material und Punkten, Lücken, Kästen, acht Themes und mehrere Fassungen (Druck, Bildschirm, Lösung) aus einer Quelle. Das Paket reicht die Bausteine der Schwesterpakete weiter (`aufgaben`, `patterns`, `mathematik`, `physik`, `informatik`, `operatoren`, `insert-a-word`, `energy-sketch`); wer `arbeitsblatt` importiert, importiert sie nicht selbst.

## Import

```typ
#import "@schule/arbeitsblatt:0.5.0": *
```

## Beispiel

```typ
#import "@schule/arbeitsblatt:0.5.0": *

#show: arbeitsblatt.with(
  title: [Größen umrechnen],
  class: "MA-05",
  print: true,
  theme: "klar",
  points: "all",
  variants: ("print", "digital", "solutions"),
)

#memo[Zur nächstkleineren Einheit multiplizierst du mit der Umrechnungszahl.]

#aufgabe(title: [Längen umrechnen], method: "pair")[
  + $4 "m" =$ #luecke[400] cm #erwartung(1)[400 cm]
  + $3 "km" =$ #luecke[3000] m #loesung[3000 m]
  #workspace[#kariert(4)]
]
```

Die Bausteine heißen deutsch (`arbeitsblatt`, `aufgabe`, `teilaufgabe`, `loesung`, `luecke`, `lsg`, `kariert` …), alles in den Klammern ist englisch. Ein gewöhnliches `typst compile` erzeugt ein Dokument; `typst compile --features bundle --format bundle ab.typ ausgabe/` erzeugt je Fassung eine Datei (`druck.pdf`, `digital.pdf`, `loesung.pdf`).

## Themes

`theme: auto` (Vorgabe) setzt die klassische Darstellung. Eingebaut sind `"klar"`, `"atlas"`, `"skizze"`, `"labor"`, `"kontur"`, `"leiste"`, `"riso"` und `"bauhaus"`; die Fachfarbe kommt aus dem Klassenkürzel (`"MA-05"` blau, `"PH-09"` orange …) oder aus `accent:`. Eigene Themes beschreibt das Handbuch. `showcase/render.sh` setzt `showcase/beispiel.typ` in allen Themes.

## Umstieg von älteren Versionen

Namen siehe Handbuch, Abschnitt „Umstieg auf 0.5.0“. Alte Namen und Werte brechen mit einer Meldung ab, die den neuen Namen nennt (``arbeitsblatt.arbeitsblatt: `loesungen` heißt jetzt `solutions` ``). Fremde Pakete (cetz, gentle-clues, codly …) reicht `arbeitsblatt` nicht mehr als Ganzes weiter, nur noch `canvas`, `draw`, `plot`, `qty`, `num`, `unit`, `stickybox` und `fa-icon`.

## Entwicklung

Die Kopfparameter von `arbeitsblatt` und `arbeitsblatt-einzeln` stehen einmal in `src/internal/parameters.typ`. Signaturen und Docstrings in `src/worksheet.typ` schreibt `python3 scripts/signaturen.py` (mit `--check` nur prüfen).
