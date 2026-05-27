# Eduki

Typst-Paket fuer Eduki-Materialboxen.

## Verwendung

```typ
#import "@schule/eduki:0.1.0": material-box

#material-box(
  "Oberstufenmathematik",
  "Materialpaket",
  rgb("#F0E371"),
  (
    "pages/Mathe LK/Umkehrfunktionen - print.pdf",
  ),
  base-path: "/absoluter/pfad/zu/deinem/projekt",
)
```

## Hinweis

Dieses Paket verwendet `@preview/shadowed:0.2.0` fuer Schattendarstellung der Seitenvorschauen.

`icon` ist optional. Wenn kein Icon gesetzt wird, wird die Box ohne Icon-Ecke gerendert.
