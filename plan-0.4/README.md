# Plan und Stand: einheitliche Namen in den @schule-Paketen

**Stand 2026-11-15: als 0.5.0 umgesetzt** (Branch `linie-0.5.0`, nichts committet).
Maßgeblich sind `UMSETZUNG-0.5.0.md` (Umfang, Vorgaben) und `konvention.md`
(deutsche Bausteinnamen auf Dauer, alles in den Klammern englisch). Umgesetzt
sind 17 Pakete je im Ordner `<paket>/0.5.0/`; Werkzeuge liegen unter
`.github/namen/` (Regeln, `UMSTIEG.md`) und `.github/scripts/` (`sig.py`,
`check-sync.sh`, `umstellen.py`).

Der Rest dieser Datei ist die ursprüngliche Planfassung vom Vortag. Sie nennt
noch 0.4.1, englische Bausteinnamen, ein Paket `kern` und dreizehn Pakete;
das ist überholt.

---

# Ursprüngliche Planfassung

Stand 2026-11-15. Dieser Ordner ist der Plan, nichts davon ist umgesetzt. Am
Paketcode wurde nichts geändert.

## Die Unterlagen

| Datei | Inhalt |
|---|---|
| `konvention.md` | Die Namensregeln: Leitregel, Glossar „ein Begriff, ein Wort" (90 Zeilen), Wertformen, gemeinsames Options-Schema, Fehlermeldungen, Umgang mit alten Namen, 26 Lint-Regeln, neue Signaturen des Kerns (Anhang A) |
| `tabelle-arbeitsblatt.md` | alt → neu für arbeitsblatt und Themes, jeder Parameter, mit JSON-Anhang |
| `tabelle-aufgaben.md` | alt → neu für aufgaben |
| `tabelle-klassenarbeit.md` | alt → neu für klassenarbeit, klausurboegen (Äste 0.0.4 und 0.0.5 zusammengeführt), patterns |
| `tabelle-fachpakete.md` | alt → neu für mathematik, physik, informatik, operatoren, insert-a-word, random, energy-sketch; Entscheidung je Hilfspaket |
| `architektur-release.md` | Zielbild, Versionsschema, Werkzeuge, Testplan, Arbeitspakete Phase 0 bis 10, Risiken, Definition of Done |
| `inventar-*.md` | Ist-Zustand: jede öffentliche Signatur mit Zeilennummer, Nutzungszahlen, Historie, Typst-Technik |
| `entwurf-*.md`, `urteil-*.md` | die drei Konventionsentwürfe (deutsch, englisch, Hybrid) und die drei Gutachten |
| `prototyp-*` | lauffähige Skizzen aus der Technik-Erkundung: Signatur-Snapshot mit Lint (`sig.py`), Codemod, Compat-Schicht, Regeltabelle |

Jede Tabelle und der Release-Plan enden mit einem Prüfprotokoll: zwei
unabhängige Prüfer je Datei, 171 von 173 Befunden eingearbeitet.

## Befund in Kürze

- Die neun Kernpakete exportieren 138 eigene Namen; durch Wildcard-Importe
  landen aber rund 5500 Namen im Dokument (ganz cetz, gentle-clues,
  fontawesome, dazu `a` und `m` aus random).
- Der Kopf von `arbeitsblatt` hat 16 englische, 16 deutsche und 3 gemischte
  Parameter. `loesungen` kennt vier Schreibweisen für „aus" (`"keine"`,
  `"false"`, `false`, `none`); Vorgaben widersprechen sich zwischen
  arbeitsblatt und aufgaben.
- Gleiche Dinge heißen verschieden (Farbe: `akzent`, `color`, `farbe`,
  `accent-color`, `clr`; Abstand: `gutter`, `spacing`; Nachkommastellen:
  `digits`, `max-digits`, `precision`), und gleiche Wörter bedeuten
  Verschiedenes (`teil` hat vier Bedeutungen, `width` ist bei `kariert` eine
  Anzahl und bei `liniert` eine Länge).
- Umlaute sind gemischt (`lücke`, `klausurbögen`, `weißer-rand` neben
  `loesung`, `klausurboegen`, `hoehe`), die Schreibweise auch (snake_case in
  physik und random, camelCase in klausurboegen).
- Geprüft wird fast nichts: nur `arbeitsblatt` lehnt unbekannte Optionen ab,
  `set-options` und alle `..args`-Senken verschlucken Tippfehler.
- 0.4.0 ist eine reine Themes-Version ohne Namensänderung und als Release
  Baustelle; das arbeitsblatt-Handbuch wird seit 0.3.1 nicht mehr gebaut.
- Bestand: rund 1460 Dokumente, davon 1276 mit arbeitsblatt über 25
  Versionen. Jedes pinnt seine Version, also bricht keines, solange die alten
  Ordner bleiben.

## Die Regel (Vorschlag)

1. **Was man tippt, ist englisch; was man liest, ist deutsch.** Bezeichner
   (Funktionen, Parameter, Schlüssel, Enum-Werte) englisch, ASCII, kebab-case;
   PDF-Texte, Fehlermeldungen und Doku deutsch.
2. **Ein Begriff hat genau ein Wort, und ein Wort hat genau einen Typ**, in
   allen Paketen.
3. **Heißt wie Typst, wenn es sich wie Typst verhält.** „Aus" ist `false` beim
   Schalter und `none` bei allem anderen.

Englisch gewann in der Jury 19 : 18 : 14,5 gegen Deutsch und Hybrid, vor allem
weil die meistbenutzten Parameter heute schon englisch sind (`title`, `class`,
`print`, `workspace`, `large`, `number`) und durchgereichte Typst-Argumente
(`columns`, `gutter`, `align`) dann nie die Sprache wechseln. Das Gutachten aus
Sicht der Lehrkraft sah den Hybrid knapp vorn.

So sähe ein Dokument aus:

```typ
#import "@schule/arbeitsblatt:0.4.1": *

#show: worksheet.with(
  title: [Lineare Funktionen],
  class: "MA-08",
  print: true,
  solutions: "at-end",
  points: "subtasks",
  points-position: "margin",
)

#task(title: [Steigung bestimmen], method: "pair")[
  #subtask(workspace: squares(4))[
    Bestimme die Steigung von $f$.
    #solution[$m = 2$]
  ]
]
```

Für zwölf Bausteine gibt es deutsche Übergangsnamen (`aufgabe = task`,
`teilaufgabe`, `loesung`, `erwartung`, `kariert`, `liniert`, …).

## Was vor dem Start zu entscheiden ist

Die Unterlagen sind auf Variante (a) ausgearbeitet. Entscheidung 1 ändert die
Tabellen nur im Alias-Block; eine Entscheidung für durchgehend deutsche Namen
würde `entwurf-A-deutsch.md` zur Grundlage machen und die vier Tabellen müssten
neu geschrieben werden.

1. **Deutsche Bausteine auf Dauer oder nur als Übergang?**
   (a) kanonisch englisch, zwölf deutsche Namen befristet;
   (b) `aufgabe`, `teilaufgabe`, `loesung`, `kariert` … bleiben auf Dauer die
   einzigen Namen, alles in den Klammern ist englisch. (b) spart rund 5100
   Ersetzungen und entspricht dem, was heute in den Dokumenten steht.
2. **0.4.1 oder 0.5.0?** 0.4.1 ist in allen Paketen frei und entspricht dem
   Wunsch 0.4.X; es ist aber ein Namensbruch in der Patch-Stelle gegenüber
   0.4.0 (58 Dokumente).
3. **`task` oder `exercise`** (nur bei 1a). `task` kollidiert mit dem
   gleichnamigen Kasten aus gentle-clues, der dann nicht mehr durchgereicht
   wird.
4. **Durchgereichte Fremdnamen:** acht ausgewählte (`canvas`, `draw`, `plot`,
   `qty`, `num`, `unit`, `stickybox`, `fa-icon`) oder gar keine.
5. **Härte gegen zweite Wege:** `""` statt `none`, `kariert(4, 12)`,
   `aufgabe[Titel][Rumpf]` als Fehler mit Abhilfe oder weiter erlaubt.
6. **klausurboegen:** was aus dem Ast 0.0.4 überlebt (`bogen-seiten`,
   `vordruck`, `namen`).
7. **Umfang:** alle dreizehn Pakete in einem Zug oder erst das Kernbündel
   (Schnitt B, siehe unten).

## Zielbild

- Ein neues, kleines Paket `kern` (zustandslos): Fehlermeldungen,
  Optionsprüfung mit Tippfehlervorschlag, Compat-Tabelle.
- Dreizehn Pakete fahren als „Zug" mit derselben Nummer: kern, aufgaben,
  arbeitsblatt, klassenarbeit, klausurboegen, patterns, mathematik, physik,
  informatik, operatoren, insert-a-word, random, energy-sketch.
- Jedes Paket hat `src/lib.typ` mit namentlichen Exporten, kein `import: *`
  mehr; Internes liegt in einem Modul `internal` statt hinter Unterstrichen.
- State-Schlüssel tragen Paketnamen und Schema-Version, damit zwei
  Paketversionen im selben Dokument sich nicht stören.
- Eine Datei `regeln.json` ist die einzige Quelle für Laufzeitprüfung
  („`loesungen` heißt jetzt `solutions`"), Codemod und Lint. Typst hat keine
  Warnungen; ein alter Name wird deshalb nie still angenommen.
- options, typopst, messwerttabellen, flashcards und gutachten/bewertung
  werden archiviert; typstage, blockst, schuldocs, typlace, eduki bleiben
  unberührt.
- 0.4.0 wird eingefroren und bleibt liegen.

## Die Arbeitspakete

| Phase | Inhalt | Tage |
|---|---|---|
| 0 | Entscheidungen treffen, aufräumen (`themes.typ` committen oder verwerfen, `.orig` löschen), Bestand einfrieren | 1–2 |
| 1 | Sicherheitsnetz: Golddokumente (gleiches Dokument, gleiche Seiten), Signatur-Snapshot je Paket, Tests ohne feste Version, Doku-Build bricht bei Fehlern ab | 8,5–13,5 |
| 2 | Werkzeuge: `regeln.json`, `kern`, Codemod auf typst-syntax, Lint, Bündel-Skript `neuer-zug.sh` | 7,5–12,5 |
| 3 | Rohlinge 0.4.1 mit alten Namen: Pins heben, Wildcard-Exporte abbauen, `internal`-Module, klausurboegen-Äste zusammenführen | 7,5–12,5 |
| – | **Entscheidungspunkt:** voller Umfang oder Schnitt B | |
| 4 | Blattpakete umbenennen (random, patterns, energy-sketch, insert-a-word, operatoren, physik, mathematik, informatik) | 6–10 |
| 5 | aufgaben | 2,5–4,5 |
| 6 | arbeitsblatt samt Themes-Vertrag | 13–23 |
| 7 | klausurboegen und klassenarbeit | 4–7 |
| 8 | Doku mit ausgeführten Beispielen, Vorlagen, READMEs, CHANGELOG | 8–16 |
| 9 | Freigabe: Lint leer, Gold grün, Zug einfrieren | 1,5–2,5 |
| 10 | Umfeld: eigene Dokumente bei Wiederverwendung heben, iPad-Kopie (Typist), eduki-Pins, typstage-app | laufend |

Summe bis zur Freigabe: rund 60 bis 104 Arbeitstage für eine Person mit
Assistenz. Die Phasen 0 und 1 landen auf `main` und nützen auch dann, wenn der
Umbau danach nicht weitergeht. **Schnitt B** nach Phase 3: Zug 0.4.1 enthält
nur das Kernbündel (kern, aufgaben, arbeitsblatt, klassenarbeit,
klausurboegen, patterns, dazu insert-a-word und random) mit neuen Namen; die
Fachpakete fahren mit alten Namen mit und folgen in 0.4.2.

Schritte, Dateien, Abhängigkeiten und Abnahmekriterien je Phase stehen in
`architektur-release.md`, Abschnitt 5.

## Was nicht dazugehört

Keine neuen Funktionen oder Themes, keine Paketumbenennungen, keine Hebung
externer Pakete (cetz, codly, zero), kein Universe-Release, keine
Massenumstellung des Archivs. Abnahmekriterium der ganzen Linie: gleiches
Dokument, gleiches PDF.

## Bekannte Lücken dieses Plans

- Stellen mit **[prüfen]** in den Unterlagen sind am Code noch nicht
  bestätigt (unter anderem die Abbildung der alten `loesungen`-Werte
  `"seite"`/`"seiten"` auf `solutions-pagebreak` und `vordruck` in
  klausurboegen).
- Die Nutzungszahlen decken nur die 2833 lokal vorhandenen .typ-Dateien ab;
  4643 Cloud-Platzhalter wurden nicht gelesen.
- Die Tagesangaben sind Schätzungen aus Teilgrößen, nicht gemessen.
- `inventar-nutzung-ausserhalb.md` nennt lokale Ordnernamen; vor einem Commit
  in das öffentliche Repo durchsehen.
