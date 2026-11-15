// fehler: arbeitsblatt.arbeitsblatt: `variants` nennt die Fassung `kontrolle`, die weder vordefiniert ist noch in `variant-overrides` steht
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(variants: ("kontrolle",))
