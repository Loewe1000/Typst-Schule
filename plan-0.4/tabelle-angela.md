# Umbenennungstabelle: angela 0.0.1 → 0.5.0

Stand 2026-11-15. Grundlage: `UMSETZUNG-0.5.0.md` (Vorrang), `konvention.md`
(K), `inventar-hilfspakete.md` Abschnitt 8 und der Quelltext
`angela/0.0.1/angela.typ` (48 Zeilen).

**Ergebnis in einem Satz:** Kein öffentlicher Name ändert sich. Das Paket
hat drei Namen (`brief`, `angela-dark`, `angela-light`); alle drei bestehen
die Konvention, sobald `brief` als Baustein eingetragen ist und die Wörter
`dark` und `light` in der Wortliste stehen. Neu sind nur die Paketstruktur
(`src/lib.typ`), die Prüfung der Argumente und die Versionsnummer.

## 1. Signaturen

```typ
// alt (angela/0.0.1/angela.typ)
#let angela-dark = rgb(40, 80, 155)          // Z. 1
#let angela-light = rgb(150, 180, 221)       // Z. 2
#let brief(body) = { }                       // Z. 16

// neu (angela/0.5.0/src/brief.typ, exportiert von src/lib.typ)
#let angela-dark = rgb(40, 80, 155)
#let angela-light = rgb(150, 180, 221)
#let brief(..deprecated, body) = { }         // Sink nimmt nichts an (K 4.4 Nr. 5c, Nr. 6)
```

## 2. Tabelle

| alt | neu | Art | Begründung |
|---|---|---|---|
| `brief` (Funktion) | `brief` | unverändert; neuer Baustein | Bausteintest K 2.1: B1 erfüllt (`#show: brief`, liefert die Vorlage wie `arbeitsblatt` und `klassenarbeit`); B2 erfüllt („Brief", „Elternbrief" ist das Wort, das Lehrkräfte und Sekretariat benutzen); B3 erfüllt (keine Aktion, keine Umwandlung, kein Layout-Helfer, kein Eigenname). Entscheidungsbaum K 1.2 Schritt 4. Eintrag in `bausteine-de-zusatz.txt`. Der englische Zwilling `letter` wird nicht exportiert. |
| `brief(body)` | `brief(..deprecated, body)` | Sink ergänzt | K 4.4 Nr. 5c und Nr. 6, K 8.4: jede öffentliche Funktion lehnt unbekannte benannte und überzählige Positionsargumente mit deutscher Meldung ab. Bisher meldete Typst selbst (englisch) „unexpected argument". Kein Aufruf, der bisher lief, bricht dadurch. |
| `body` (positional) | `body` | unverändert | Glossar Nr. 79, steht zuletzt (L15). |
| `angela-dark` (Wert, color) | `angela-dark` | unverändert | K 2.1 „Werte und Konstanten" sind englisch: `angela` steht in `names.txt` (Eigenname der Schule und des Logos), `dark` ist englisch. Kein verbotenes Affix (L4: nicht `-color`). Wort `dark` neu in `words-en-zusatz.txt`. Siehe Zweifelsfall 1. |
| `angela-light` (Wert, color) | `angela-light` | unverändert | wie `angela-dark`; Wort `light` neu in `words-en-zusatz.txt`. Im Paket selbst unbenutzt (Inventar), bleibt als zweite Schulfarbe exportiert, weil die Doku von 0.0.1 sie bewirbt. |
| Einstiegsdatei `angela.typ` | `src/lib.typ`, Implementierung `src/brief.typ` | Struktur | K 7.1: Einstiegsdatei `src/lib.typ`, nur namentliche Exporte. Für Dokumente unsichtbar (Import über `@schule/angela:0.5.0`). |
| `image("logo.svg")` | `image("../logo.svg")` | intern | `logo.svg` bleibt im Paketwurzelordner; der Pfad folgt der neuen Lage der Quelldatei. |
| – | `src/internal/check.typ` | neu | wortgleiche Kopie von `.github/namen/check.typ`. |
| – | kein `src/removed.typ` | – | Es gibt keinen alten Funktionsnamen, also keinen Stub (K 9.3). |
| – | kein Modul `internal` exportiert | – | Das Paket hat keine internen Namen, keinen State, keinen Counter, kein Label (K 7.2, 7.3). |

Vorgaben, die bleiben (gleiches Dokument, gleiches PDF): A4, Ränder oben
5cm, unten 2cm, links und rechts 2.5cm, `header-ascent: 35%`, Schriften
„Lucida Grande" 20pt, „Arial" 8pt gestaucht, „Calibri" 11pt, `lang: "de"`,
Blocksatz, `leading: 0.75em`, Silbentrennung, Überschriftenabstände, Logo 4cm.

## 3. Fehlermeldungen (neu)

| Aufruf | Meldung |
|---|---|
| `#show: brief.with(titel: [x])` | ``angela.brief: unbekannter Parameter `titel` – weglassen, `brief` kennt keine benannten Argumente`` |
| `#brief[a][b]` | ``angela.brief: 1 Positionsargument, erlaubt ist keines – `brief` nimmt nur den Brief selbst an – als `#show: brief` einbinden`` |

Bekannte Grenze: `#brief()` ganz ohne Inhalt meldet weiterhin Typsts eigenes
`missing argument: body` (wie 0.0.1). `body` ist ein Pflichtargument; Typst
prüft es vor dem Rumpf, `check-positional` wird nicht erreicht. Das gilt für
jede Funktion mit der Form `(..deprecated, body)` aus Anhang A der Konvention
und bleibt so, solange der Autor die Signatur nicht ändert (möglich wäre
`brief(..args)` mit `check-positional(min: 1, max: 1)`).

Eine „heißt jetzt"-Meldung gibt es in diesem Paket nicht, weil es keinen
alten Namen gibt: `renamed`, `removed` und `values` sind leer.

## 4. Zweifelsfälle

1. **`angela-dark`, `angela-light` oder `…-accent`.** Das Glossar führt die
   Akzentfarbe als `accent` (Nr. 26), und arbeitsblatt nennt seine
   Farbtabelle `subject-accents`. Ein nacktes `accent` scheidet aus (überdeckt
   bei `import: *` Typsts `accent` im Mathemodus, K 4.5). Möglich wäre
   `angela-accent` und `angela-accent-light`. Dagegen spricht: (a) die beiden
   Werte sind zwei Töne desselben Schulblaus, und das unterscheidende Wort
   (`dark`, `light`) bräuchte man ohnehin; (b) für einen Wert gibt es keinen
   abbrechenden Stub (K 9.3, Zeile `pk`), eine Umbenennung endete also in
   Typsts „unknown variable" ohne „heißt jetzt"; (c) beide Namen bestehen L1,
   L2 und L4 unverändert. Entscheidung: Namen bleiben. Der Autor kann anders
   entscheiden; dann sind es zwei Zeilen unter `werte-umbenannt` im Anhang.
2. **`brief` als Baustein.** `brief` ist auch ein englisches Wort („kurz"),
   wird hier aber deutsch gelesen. Als englischer Helfername wäre es falsch
   benannt (`letter`), als deutscher Baustein ist es der Schulbegriff. Der
   Eintrag steht in `bausteine-de-zusatz.txt`; `wortpaare.json` und die
   Konstante `word-pairs` in `check.typ` bekommen die Zeile `"brief": []`
   erst vom Autor (beide Dateien sind für Paket-Agenten gesperrt). Ein
   Parameterwort ist nicht vergeben, weil kein Parameter den Brief meint;
   wird eines gebraucht, ist es `letter`.
3. **Hinweis in der Doku von 0.0.1, „`logo.svg` im selben Verzeichnis wie die
   Quelldatei" sei nötig.** Das stimmt nicht: Das Paket liest sein eigenes
   Logo. Die Doku von 0.5.0 sagt es richtig. Kein Eingriff ins Verhalten.

## 5. Hinweise an die Konvention

- Neuer Baustein `brief` (Paket angela), Parameterwort keines (bei Bedarf
  `letter`). Nachzutragen in K 2.1a, K 2.1b, `wortpaare.json`, `check.typ`
  (`word-pairs`) und `zwillinge.txt` (`letter`).
- Neue Wörter `dark`, `light` (Gruppe B: Bestand, Namen der beiden
  Schulfarben seit 0.0.1).

## 6. Maschinenlesbarer Anhang

**Lesart** wie in den anderen Tabellen: `funktionen` = alte → neue
Funktionsnamen (Stub und Codemod), `parameter` = `renamed`, `werte` =
`values`, `entfernt` = `removed`. Alle vier sind leer; der Codemod ändert an
einem angela-Dokument nur die Versionsnummer der Importzeile.

```json
{
  "paket": "angela",
  "von": "0.0.1",
  "nach": "0.5.0",
  "import": {
    "@schule/angela:0.0.1": "@schule/angela:0.5.0"
  },
  "funktionen": {},
  "bausteine-unveraendert": ["brief"],
  "bausteine-neu": {
    "brief": { "parameterwort": [], "zwilling": "letter" }
  },
  "werte-unveraendert": ["angela-dark", "angela-light"],
  "parameter": {
    "brief": {}
  },
  "werte": {},
  "entfernt": {},
  "kontext": [],
  "erlaubt": {
    "brief": []
  },
  "positionsargumente": {
    "brief": { "min": 0, "max": 0, "body": true }
  },
  "stubs": [],
  "states": [],
  "labels": [],
  "woerter-neu": ["dark", "light"],
  "oeffentlich": ["brief", "angela-dark", "angela-light"]
}
```
