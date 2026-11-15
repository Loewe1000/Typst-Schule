// fehler: arbeitsblatt.arbeitsblatt: `varianten` (alt) und `variants` (neu) zugleich – nur `variants` schreiben
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(varianten: ("druck",), variants: ("print",))
