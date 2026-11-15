// <ab-meta> bleibt deutsch: Schlüssel und die Werte von niveau und typ; fehlende Klasse als "".
// erwartet: titel=Meta
// erwartet: klasse=\[\]
// erwartet: fach=physik
// erwartet: jahrgang=9,11
// erwartet: niveau=einfuehrung
// erwartet: typ=uebung
// erwartet: stand=2026-01-01
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(
  title: "Meta", subject: "physik", topic: "physik/energie", years: (9, 11), stage: "sek-1",
  level: "introduction", kind: "practice", keywords: ("Energie",), revision: "2026-01-01",
)
#context {
  let meta = query(<ab-meta>).first().value
  [titel=#meta.titel klasse=[#meta.klasse] fach=#meta.fach jahrgang=#meta.jahrgang.map(str).join(",")
  niveau=#meta.niveau typ=#meta.typ stand=#meta.stand]
}
