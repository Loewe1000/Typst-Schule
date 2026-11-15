// Ohne Lösungen: `lsg` zeigt `fallback`, `workspaces: false` nimmt Arbeitsflächen heraus.
// erwartet: NUR-IM-BLATT
// nicht: FLAECHE
// nicht: sichtbar
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(title: [L], workspaces: false)
#aufgabe[Text #lsg(fallback: [NUR-IM-BLATT])[sichtbar] #workspace[FLAECHE]]
