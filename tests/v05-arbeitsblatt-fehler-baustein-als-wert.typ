// fehler: arbeitsblatt.arbeitsblatt: `kind: "klassenarbeit"` ist kein gültiger Wert – meintest du `"exam"`? erlaubt: `none`, `"worksheet"`, `"practice"`, `"stations"`, `"exam"`
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(kind: "klassenarbeit")
