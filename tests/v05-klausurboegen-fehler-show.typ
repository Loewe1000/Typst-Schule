// klausurboegen 0.5.0: als Show-Regel benutzt (der Dokumentrumpf ist ein Positionsargument)
// fehler: klausurboegen.klausurboegen: 1 Positionsargument, erlaubt ist keines – `klausurboegen` nimmt keinen Rumpf – Werte benannt schreiben und als `#klausurboegen(title: …)` aufrufen, nicht mit `#show:`
#import "@schule/klausurboegen:0.5.0": *
#show: klausurboegen.with(title: "P")
