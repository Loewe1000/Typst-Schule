# patterns

Karierte und linierte Schreibfelder für Arbeitsblätter, Klassenarbeiten und
Klausurbögen: mit fester Zeilenzahl, mit fester Höhe oder als flexible Felder,
die sich den freien Platz der Seite teilen.

```typ
#import "@schule/patterns:0.5.0": kariert, liniert

#kariert(5)                          // fünf Zeilen Kästchen
#kariert(height: 3cm, columns: 12)   // feste Höhe, zwölf Kästchen breit
#liniert(3, line-height: 1.2cm)      // drei Schreibzeilen
#kariert(1fr)                        // füllt den Rest der Seite
```

Öffentliche Namen: `kariert`, `liniert`, `flex-area`, `is-flex-area`.
Die Bausteine heißen deutsch, alles in den Klammern ist englisch.

Umstieg von älteren Versionen: Namen siehe Handbuch, Abschnitt „Umstieg auf 0.5.0".
