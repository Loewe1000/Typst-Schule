# abbozza

Setzt Level des Lernspiels Hathi (Abbozza! Worlds) als Bild, für Arbeitsblätter
und Klassenarbeiten im Informatikunterricht.

```typ
#import "@schule/abbozza:0.5.0": hathi-level

#hathi-level(
  xml("level.abz"),
  tile-size: 20mm,
  print: true,
  replacements: (lion: "grass"),
  extra-tiles: ((kind: "flag", at: (1, 3), hue: 344),),
)
```

Das Handbuch liegt unter `docs/docs.typ`, Beispiele unter `examples/`.

Umstieg von älteren Versionen: Namen siehe Handbuch, Abschnitt „Umstieg auf 0.5.0".
