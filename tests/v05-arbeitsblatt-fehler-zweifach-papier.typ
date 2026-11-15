// fehler: arbeitsblatt.arbeitsblatt: `two-up: true` geht nicht mit `paper: "a3"` – erlaubt: `"a4"`, `"a5"`, `"a6"`
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(two-up: true, print: true, paper: "a3")
