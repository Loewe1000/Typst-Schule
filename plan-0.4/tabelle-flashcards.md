# Umbenennungstabelle flashcards 0.0.1 → 0.5.0

Stand 2026-11-15. Grundlage: `UMSETZUNG-0.5.0.md` (Vorrang), `konvention.md`,
Ist-Zustand aus `inventar-hilfspakete.md` Abschnitt 5 und dem Quelltext
`flashcards/0.0.1/flashcards.typ` (341 Zeilen). `tabelle-fachpakete.md`
Abschnitt 8 sah für flashcards „archivieren" vor; `UMSETZUNG-0.5.0.md` zählt das
Paket zum Umfang und geht vor.

Verweise: § = Abschnitt der Konvention, G = Glossarzeile, L = Lint-Regel, W = Wertform (§ 5.1).

## 0. Ausgangslage

- 0.0.1 kompiliert unter Typst 0.15.1 nicht (`locate(loc => …)` Z. 39 und 195,
  `query(<card>, loc)`, `counter.final(loc)`). Die Reparatur gehört zur
  Umsetzung (Vorgabe 4 in `UMSETZUNG-0.5.0.md`).
- Einstiegsdatei `flashcards.typ`, acht öffentliche Namen: ein Counter, vier
  States, eine Funktion, zwei Inhaltswerte.
- Kein Paket und kein Dokument im Repo importiert flashcards; das eigene
  Handbuch ist der einzige Benutzer. Es ruft `card(header: …, footer: …,
  question: …, answer: …)` mit benannten Argumenten auf, die die Funktion nie
  angenommen hat (alle vier sind Positionsparameter), und nennt `a48up` nicht.
- `letter8up` (Z. 30–183) und `a48up` (Z. 186–339) sind bis auf fünf Werte
  dieselben 150 Zeilen; in jeder Fassung ist der Zweig für gerade und ungerade
  Karten nochmals wortgleich.

## 1. Öffentliche Namen

| alt | neu | Art | Begründung |
|---|---|---|---|
| `card` | `card` | unverändert (Aufrufform neu, siehe 2) | englischer Helfer, der ein Ding setzt: Substantiv im Singular (§ 4.1). Kein Baustein, siehe 6 Nr. 1. |
| `letter8up` (Inhaltswert) | `show-cards(paper: "us-letter")` | umbenannt, Wert → Funktion | § 2.4 (keine Ziffer als Wort, nicht zusammengeschrieben); Aktion „Gesammeltes ausgeben" heißt `show-<plural>` (§ 4.1); das Papier ist ein Parameter (G50 `paper`, W8). |
| `a48up` (Inhaltswert) | `show-cards(paper: "a4")` | umbenannt, Wert → Funktion | wie oben; `a48up` ist zudem nicht lesbar (A4, 8-up). |
| `cardnumber` (Counter `"cardnumber"`) | entfällt | entfernt | § 7.2, § 7.3; die Nummer ergibt sich aus der Stelle im State `cards`. |
| `cardheader` (State `"header"`) | `internal.cards` (Feld `header`) | intern | § 7.2, § 7.3 |
| `cardfooter` (State `"footer"`) | `internal.cards` (Feld `footer`) | intern | § 7.2, § 7.3 |
| `cardquestion` (State `"question"`) | `internal.cards` (Feld `question`) | intern | § 7.2, § 7.3 |
| `cardanswer` (State `"answer"`) | `internal.cards` (Feld `answer`) | intern | § 7.2, § 7.3 |
| – | `internal` (Modul) | neu | § 7.2 |

## 2. `card`

```typ
// alt (flashcards.typ Z. 21)
#let card(header, footer, question, answer) = [ … ]
// neu (src/flashcards.typ)
#let card(
  header: none,     // W4 content | str | none, Kopfzeile der Vorderseite
  footer: none,     // W4 content | str | none, Fußzeile der Vorderseite
  ..deprecated,
  question,         // content | str, Vorderseite
  answer,           // content | str, Rückseite
) = { }
```

| alt | neu | Art | Begründung |
|---|---|---|---|
| `header` (1. Positionsargument) | `header: none` (benannt) | Aufrufform | § 4.4 Nr. 3: benannt ist alles außer dem Inhalt; G `header` (Typst-Wort, Gruppe T). Vorgabe `none` ist neu, weil ein benannter Parameter eine Vorgabe braucht; `none` setzt nichts (W4, § 5.2). |
| `footer` (2. Positionsargument) | `footer: none` (benannt) | Aufrufform | wie `header` |
| `question` (3. Positionsargument) | `question` (1. Positionsargument) | unverändert, rückt vor | § 4.4 Nr. 2: Liste gleichartiger Inhalte, hier die zwei Seiten der Karte; `question` steht in `words-en.txt`. |
| `answer` (4. Positionsargument) | `answer` (2. Positionsargument) | unverändert, rückt vor | wie `question`; `answer` steht in `words-en.txt` (Gruppe N). |

Aufruf alt → neu: `#card[Kopf][Fuß][Frage][Antwort]` → `#card(header: [Kopf], footer: [Fuß])[Frage][Antwort]`.

Prüfungen (§ 8.4), alle über `check.typ`:

Gezählt werden alle Positionsargumente des Aufrufs, also der Sink samt Frage
und Antwort (`check-positional(…, deprecated.pos() + (question, answer), max: 2)`);
sonst hieße es bei vier geschriebenen Inhalten „2 Positionsargumente, erlaubt
ist keines".

| Eingabe | Meldung |
|---|---|
| `#card[Kopf][Fuß][Frage][Antwort]` (Form von 0.0.1) | ``flashcards.card: 4 Positionsargumente, erlaubt ist höchstens 2 – Kopf- und Fußzeile stehen benannt vor Frage und Antwort – `card(header: [...], footer: [...])[Frage][Antwort]` schreiben`` |
| `#card(titel: [x])[F][A]` | ``flashcards.card: unbekannter Parameter `titel` – erlaubt: `header`, `footer` `` |
| `#card(heade: [x])[F][A]` | ``flashcards.card: unbekannter Parameter `heade` – meintest du `header`?`` |
| `#card(header: "")[F][A]` | ``flashcards.card: `header: ""` – für „keine Kopfzeile" `none` schreiben oder weglassen`` (ebenso `footer`, „keine Fußzeile") |
| `#card(header: 3)[F][A]` | ``flashcards.card: `header` erwartet Inhalt oder einen Text (`str`) oder `none`, bekam `3` (int) – zum Beispiel `[Text]` `` (ebenso `footer`; `question` und `answer` ohne `none`) |

Rückgabe: unverändert unsichtbarer Inhalt (heute Counter-Schritt und vier
State-Updates mit Label `<card>`, künftig ein Update von `internal.cards`).

## 3. `show-cards`

```typ
// alt (flashcards.typ Z. 30 und Z. 186): zwei Werte, kein Aufruf
#let letter8up = { … locate(loc => { … }) }
#let a48up     = { … locate(loc => { … }) }
// neu (src/flashcards.typ)
#let show-cards(
  paper: "a4",      // W8/W2 "a4" | "us-letter"
  ..deprecated,
) = { }
```

| alt | neu | Art | Wertabbildung | Begründung |
|---|---|---|---|---|
| `#letter8up` | `#show-cards(paper: "us-letter")` | umbenannt | – | § 2.4, § 4.1; Wert wie Typsts `page(paper:)` (G50) |
| `#a48up` | `#show-cards(paper: "a4")` oder `#show-cards()` | umbenannt | – | § 2.4, § 4.1; `"a4"` steht in `names.txt` |
| – | Vorgabe `paper: "a4"` | neu | – | Es gab keine Vorgabe (zwei gleichrangige Werte). `"a4"` ist die Vorgabe von `paper` in allen Kernpaketen (Anhang A.1, A.2). |

Was `paper` festlegt (alles unverändert aus 0.0.1 übernommen, § 5.5 „eine Umbenennung ändert keine Vorgabe"):

| | `"a4"` (früher `a48up`) | `"us-letter"` (früher `letter8up`) |
|---|---|---|
| Karte | 105 mm × 74,25 mm | 4,25 in × 2,75 in |
| Frage | 12 pt, `horizon + center` | 13,75 pt, fett, `top + center` mit `dy: 1.5cm` |
| Antwort | 12 pt | 13,75 pt |
| Kopfzeile, Fußzeile, Nummer | 11 pt | 11 pt |

Unverändert bleibt auch: `show-cards` stellt die Seite nicht ein (kein
`set page`); das Dokument schreibt `#set page(paper: …, margin: 0pt)` selbst.
Die Stelle des Aufrufs ist frei, gesetzt werden alle Karten des Dokuments.

Prüfungen:

| Eingabe | Meldung |
|---|---|
| `#show-cards(papier: "a4")` | ``flashcards.show-cards: unbekannter Parameter `papier` – meintest du `paper`?`` |
| `#show-cards(paper: "a5")` | ``flashcards.show-cards: `paper: "a5"` ist kein gültiger Wert – meintest du `"a4"`? erlaubt: `"a4"`, `"us-letter"` `` |
| `#show-cards("a4")` | ``flashcards.show-cards: 1 Positionsargument, erlaubt ist keines – das Papierformat benannt schreiben (`paper: "a4"`)`` |

## 4. Alte Namen (`src/removed.typ`)

| alt | Meldung | Mechanik |
|---|---|---|
| `letter8up` | ``flashcards.letter8up: `letter8up` heißt jetzt `show-cards(paper: "us-letter")` `` | `context fail(…)` |
| `a48up` | ``flashcards.a48up: `a48up` heißt jetzt `show-cards(paper: "a4")` `` | `context fail(…)` |

Beide alten Namen waren Werte und wurden ohne Klammern gesetzt (`#letter8up`).
Ein Funktions-Stub aus `check.stub` bräche dabei nicht ab: Typst setzt eine
Funktion im Fließtext als `(..) => ..`. Deshalb sind beide Namen Inhaltswerte,
die beim Setzen über `fail` abbrechen; der Import allein bricht nicht ab.
Folge: `sig.py --eval` meldet für beide „statisch stub, zur Laufzeit content".

`cardnumber`, `cardheader`, `cardfooter`, `cardquestion`, `cardanswer`
bekommen keinen Stub: Ein Dokument konnte sie nur über Methoden benutzen
(`cardnumber.step()`), und dafür gibt es keinen abbrechenden Ersatz. Sie stehen
im JSON unter `entfernt`; wer sie importiert, bekommt Typsts „unresolved
import".

## 5. States, Counter, Labels (§ 7.3)

| alt | neu |
|---|---|
| Counter `"cardnumber"` | entfällt (Nummer = Stelle im Array + 1, Gesamtzahl = Länge) |
| State `"header"`, `"footer"`, `"question"`, `"answer"` (Anfangswert `"init"`) | ein State `"schule/flashcards/cards@1"`, Wert: Array aus `(header:, footer:, question:, answer:)` |
| Label `<card>` | entfällt (`show-cards` liest `internal.cards.final()`) |

Interne Namen in `src/internal.typ` (keine zugesicherte Schnittstelle):
`cards`, `cards-per-page`, `base-size`, `cut-paint`, `formats`, `card-size`,
`question-side`, `answer-side`, `sheet`, `sheets`.

## 6. Zweifelsfälle und Entscheidung

1. **`card` oder ein deutscher Baustein `lernkarte`?** Der Bausteintest (§ 2.1)
   ließe sich für `lernkarte` bejahen (B1 Aufrufform, B2 Schulbegriff). Dagegen
   steht: `bausteine-de.txt` ist abschließend, jeder Baustein braucht eine
   Zeile in `wortpaare.json`, und die steht wortgleich als `word-pairs` in
   `check.typ`, das in dieser Runde nicht geändert wird; der Paketname ist
   englisch; `card` ist der Bestandsname. Entscheidung: `card` bleibt, kein
   neuer Baustein. Dem Autor zur Bestätigung gemeldet.
2. **Zwei Inhalte am Ende statt eines `body`.** § 4.4 Nr. 2 erlaubt neben
   `body` eine Liste gleichartiger Inhalte (`minipage[a][b]`); Vorder- und
   Rückseite einer Karte sind eine solche Liste fester Länge. Die Parameter
   heißen `question` und `answer` und nicht `body`, weil keiner von beiden der
   Rumpf des anderen ist. L15 ist erfüllt (kein Parameter `body`).
3. **Vorgabe `paper: "a4"`.** Siehe 3. Wer von `letter8up` kommt, wird durch die
   Meldung auf `paper: "us-letter"` geführt, nicht auf die Vorgabe.
4. **`show-cards` stellt die Seite nicht ein.** Ein `set page` im Paket wäre
   bequemer, änderte aber das Verhalten (Vorgabe 4). Das Handbuch nennt die
   Zeile `#set page(paper: …, margin: 0pt)` in jedem Beispiel.
5. **Wörter.** `card` und `cards` fehlen in `words-en.txt` und sind in
   `words-en-zusatz.txt` angehängt. Der Wert `"us-letter"` ist Typsts
   Papiername und wird vom Lint nicht geprüft.

## 7. Vergleichsbeleg

0.0.1 lässt sich unter Typst 0.15.1 nicht kompilieren. Verglichen wird deshalb
gegen eine Kopie von 0.0.1 im Scratch-Ordner, in der nur die drei
Introspektionsaufrufe ersetzt sind (`locate(loc => { … })` → `context { … }`,
`query(<card>, loc)` → `query(<card>)`, `cardnumber.final(loc.location())` →
`cardnumber.final()`; je zweimal). Ein Dokument mit 13 Karten (Formeln, Liste,
`str` und Inhalt als Kopfzeile) ergibt mit `letter8up` und `a48up` je 4 Seiten;
dasselbe Dokument mit 0.5.0 ergibt denselben Text (`pdftotext -layout`),
dieselbe Seitenzahl und bei 60 dpi bildgleiche Seiten.

## 8. Maschinenlesbarer Anhang

Lesart wie in `tabelle-fachpakete.md` Abschnitt 12: Schlüssel sind die alten
Namen, mit dem Paket qualifiziert. Positionsparameter stehen nicht in
`parameter`; ihre Umstellung steht unter `kontext`, und zur Laufzeit meldet der
Sink die überzähligen Positionsargumente.

```json
{
  "funktionen": {
    "flashcards.letter8up": "flashcards.show-cards",
    "flashcards.a48up": "flashcards.show-cards",
    "flashcards.cardheader": "flashcards.internal.cards",
    "flashcards.cardfooter": "flashcards.internal.cards",
    "flashcards.cardquestion": "flashcards.internal.cards",
    "flashcards.cardanswer": "flashcards.internal.cards"
  },
  "parameter": {},
  "werte": {},
  "entfernt": {
    "flashcards.cardnumber": "die Nummer einer Karte ergibt sich aus ihrer Stelle im Dokument",
    "flashcards.cardheader": "interner Zustand, steht in `internal.cards`",
    "flashcards.cardfooter": "interner Zustand, steht in `internal.cards`",
    "flashcards.cardquestion": "interner Zustand, steht in `internal.cards`",
    "flashcards.cardanswer": "interner Zustand, steht in `internal.cards`"
  },
  "kontext": [
    {"alt": "card(H, F, Q, A) mit vier Positionsargumenten", "regel": "card(header: H, footer: F, Q, A); bei Inhaltsklammern card(header: [H], footer: [F])[Q][A]"},
    {"alt": "#letter8up (Wert, ohne Klammern)", "regel": "#show-cards(paper: \"us-letter\")"},
    {"alt": "#a48up (Wert, ohne Klammern)", "regel": "#show-cards(paper: \"a4\")"},
    {"alt": "import \"@schule/flashcards:0.0.1\": card, letter8up bzw. a48up", "regel": "import \"@schule/flashcards:0.5.0\": card, show-cards"}
  ],
  "neu": {
    "flashcards.card": {"header": "none", "footer": "none"},
    "flashcards.show-cards": {"paper": "\"a4\""}
  },
  "stubs": {
    "flashcards.letter8up": "show-cards(paper: \"us-letter\")",
    "flashcards.a48up": "show-cards(paper: \"a4\")"
  },
  "states": {
    "cardnumber": null,
    "header": "schule/flashcards/cards@1",
    "footer": "schule/flashcards/cards@1",
    "question": "schule/flashcards/cards@1",
    "answer": "schule/flashcards/cards@1"
  },
  "state-felder": {
    "schule/flashcards/cards@1": ["header", "footer", "question", "answer"]
  },
  "labels": {
    "card": null
  }
}
```
