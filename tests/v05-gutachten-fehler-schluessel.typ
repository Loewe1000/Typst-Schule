// gutachten 0.5.0: Ein Schlüssel, den `set-tasks` nicht kennt, bricht ab (0.0.2 überging ihn still).
// fehler: gutachten.set-tasks: unbekannter Schlüssel `thema` – erlaubt: `max-points`, `dative`, `title`
#import "@schule/gutachten:0.5.0": *

#set-tasks(("A": (max-points: 10, thema: "x")))
