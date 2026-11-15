// Ohne `title` und `class` bekommen Theme-Funktion und Hook `header` wie bis
// 0.4.0 den leeren Text, nicht `none` (sonst änderte sich das Layout der Themes).
// erwartet: Funktion-Klasse=""
// erwartet: Kopf-Titel="" Kopf-Klasse=""
// erwartet: Rumpftext
// nicht: none
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(
  print: true,
  theme: (accent: auto, class: none) => {
    let theme-class = class
    (header: (title: none, class: none, copyright-url: none, font-size: auto) => [
      Funktion-Klasse=#repr(theme-class) \
      Kopf-Titel=#repr(title) Kopf-Klasse=#repr(class)
    ])
  },
)
Rumpftext
