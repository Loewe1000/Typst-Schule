# energy-sketch

`energy-sketch` erzeugt Energieniveau-Diagramme für Arbeitsblätter und Unterrichtsmaterial in Physik und Chemie.

## Verwendung

```typ
#import "@schule/energy-sketch:0.0.3": energy-sketch

#energy-sketch(($E_"kin"$, $E_"pot"$, $E_"ges"$))
```

## Parameter

- `energy-name`: Nicht-leeres Array aus Strings oder Typst-Content.
- `hide-letters`: Blendet die Beschriftungen aus. Standard: `false`.
- `height`: Höhe des Diagramms. Standard: `3cm`.
- `gap`: Abstand zwischen zwei Energiespalten. Standard: `0pt`.

## Beispiele

```typ
#energy-sketch(
  ($E_"kin"$, $E_"pot"$, $E_"ges"$),
  hide-letters: true,
)
```

```typ
#energy-sketch((
  [*kinetisch*],
  [potenziell],
  [$E_("ges")$],
), height: 5cm)
```

```typ
#energy-sketch(
  ($E_"kin"$, $E_"pot"$, $E_"ges"$),
  gap: 6pt,
)
```

Die ausführliche Dokumentation im Paketordner unter `docs/` enthält zusätzlich gerenderte Beispiele.
