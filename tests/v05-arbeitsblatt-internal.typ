// Interne Schnittstelle für klassenarbeit: Scope-State, Theme, Parametertabelle, Pfade der Fassungen.
// erwartet: Scope: solutions
// erwartet: Theme: klar
// erwartet: Pfad: ka-loesung.pdf
// erwartet: Kennung: ka-solutions
// erwartet: scope ja, variants nein
#import "@schule/arbeitsblatt:0.5.0": *
#import "@schule/arbeitsblatt:0.5.0" as worksheet-package
#let theme = worksheet-package.internal.resolve-theme("klar", class: "MA-07", package: "klassenarbeit", function: "klassenarbeit")
#worksheet-package.internal.check-worksheet-options("klassenarbeit", "klassenarbeit", (solutions: none, points: "tasks"))
#show: arbeitsblatt-einzeln.with(title: [KA], class: "MA-07", print: true, theme: "klar", scope: "solutions")
#aufgabe(title: [A])[Text]
#context [Scope: #worksheet-package.internal.scope-state.get()]

Theme: #theme.name

Pfad: #worksheet-package.internal.variant-path("solutions", "ka")

Kennung: #worksheet-package.internal.variant-scope("solutions", "ka")

#let names = worksheet-package.internal.single-parameter-names
scope #if "scope" in names [ja] else [nein], variants #if "variants" in names [ja] else [nein]
