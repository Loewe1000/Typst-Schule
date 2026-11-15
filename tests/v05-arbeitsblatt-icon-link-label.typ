// `icon-link` nimmt wie `link` auch ein Label als Ziel.
// erwartet: Zum Ziel
// erwartet: Hier ist das Ziel
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(title: [Verweis], class: "MA-05")
#icon-link(<ziel>)[Zum Ziel]

Hier ist das Ziel <ziel>
