// `two-up`: jede A5-Seite zweimal auf einem A4-Bogen.
// erwartet: Doppelt +Doppelt
// erwartet: Aufgabe 1 .*Aufgabe 1
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(title: [Doppelt], paper: "a5", print: true, two-up: true)
#aufgabe[Text]
