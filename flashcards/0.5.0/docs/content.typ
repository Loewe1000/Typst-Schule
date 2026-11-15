#import "@schule/schuldocs:0.3.1": info, show-code, show-example, show-module, tip, warning
#import "../src/internal.typ": answer-side, formats, question-side

// Vorschau einer Karte für das Handbuch: Vorder- und Rückseite nebeneinander,
// verkleinert und mit dem Schnittraster als Rand. Gesetzt wird mit denselben
// Helfern, die `show-cards` benutzt.
#let preview(paper, ..items) = {
  let format = formats.at(paper)
  let total = items.pos().len()
  let frame = box.with(stroke: (thickness: 0.5pt, dash: "dashed", paint: luma(150)))
  let cells = ()
  for (index, item) in items.pos().enumerate() {
    cells.push(frame(question-side(format, item, index + 1, total)))
    cells.push(frame(answer-side(format, item, index + 1, total)))
  }
  scale(60%, reflow: true, grid(columns: 2, gutter: 6mm, ..cells))
}

= Über dieses Paket

Das `flashcards`-Paket setzt *Lernkarten zum Ausdrucken*. Auf eine Seite
passen acht Karten (2 Spalten, 4 Zeilen). Auf jede Seite mit Fragen folgt eine
Seite mit den Antworten; dort sind die beiden Spalten vertauscht, sodass beim
beidseitigen Druck jede Antwort genau hinter ihrer Frage liegt.

Eine Karte besteht aus vier Teilen:

- *Frage*: Vorderseite, in der Mitte der Karte
- *Antwort*: Rückseite
- *Kopfzeile* (`header`): oben links auf der Vorderseite, zum Beispiel das Fach
- *Fußzeile* (`footer`): unten rechts auf der Vorderseite, zum Beispiel das Thema

Dazu kommt auf beiden Seiten die Nummer der Karte in der Form „3/8“.

Das Paket hat zwei Funktionen: `card` legt eine Karte an, `show-cards` setzt
alle Karten des Dokuments als Druckbögen.

= Schnellstart

#show-code(```typ
#import "@schule/flashcards:0.5.0": card, show-cards

// Die Karten füllen die ganze Seite: Papier wie in `show-cards`, kein Rand.
#set page(paper: "a4", margin: 0pt)

#card(header: [Physik], footer: [Kinematik])[
  Was beschreibt die Gleichung $s = v dot t$?
][
  Den zurückgelegten Weg $s$ bei gleichförmiger Bewegung
  mit der Geschwindigkeit $v$ in der Zeit $t$.
]
#card(header: [Physik], footer: [Kinematik])[Einheit der Geschwindigkeit?][
  $[v] = "m/s"$
]
#card(header: [Physik], footer: [Dynamik])[Was besagt das zweite Newtonsche Gesetz?][
  $F = m dot a$ — Kraft ist Masse mal Beschleunigung.
]
#card(header: [Physik], footer: [Dynamik])[Einheit der Kraft?][
  $[F] = "N" = "kg" dot "m/s"^2$
]

#show-cards()
```)

Das Ergebnis sind zwei Seiten: die vier Fragen und die vier Antworten.

#warning[
  `show-cards` stellt die Seite nicht selbst ein. Ohne
  `#set page(paper: "a4", margin: 0pt)` behält die Seite ihren Rand, und die
  acht Karten passen nicht mehr auf eine Seite.
]

= Eine Karte anlegen

`card` bekommt die Frage und die Antwort als zwei Inhalte. Kopf- und Fußzeile
sind benannt und dürfen fehlen.

#show-example(
  rendered: preview("a4", (
    header: [Physik],
    footer: [Energieformen],
    question: [Nenne drei Energieformen.],
    answer: [
      - Kinetische Energie: $E_"kin" = 1/2 m v^2$
      - Potentielle Energie: $E_"pot" = m g h$
      - Thermische Energie: $Q = m c Delta T$
    ],
  )),
  source: ```typ
  #import "@schule/flashcards:0.5.0": card, show-cards
  #set page(paper: "a4", margin: 0pt)

  #card(header: [Physik], footer: [Energieformen])[
    Nenne drei Energieformen.
  ][
    - Kinetische Energie: $E_"kin" = 1/2 m v^2$
    - Potentielle Energie: $E_"pot" = m g h$
    - Thermische Energie: $Q = m c Delta T$
  ]

  #show-cards()
  ```,
)

Die Abbildung zeigt links die Vorderseite und rechts die Rückseite der Karte,
verkleinert. Frage und Antwort nehmen beliebigen Inhalt auf: Formeln, Listen,
Tabellen, Bilder.

Eine Karte erscheint nicht an der Stelle ihres Aufrufs. Die Reihenfolge der
Aufrufe bestimmt die Reihenfolge und die Nummern auf den Bögen.

== Karten ohne Kopf- und Fußzeile

#show-example(
  rendered: preview("a4", (
    header: none,
    footer: none,
    question: [Hauptstadt von Frankreich?],
    answer: [Paris],
  )),
  source: ```typ
  #import "@schule/flashcards:0.5.0": card, show-cards
  #set page(paper: "a4", margin: 0pt)

  #card[Hauptstadt von Frankreich?][Paris]

  #show-cards()
  ```,
)

== Karten aus Daten

`card` ist eine gewöhnliche Funktion und lässt sich in einer Schleife aufrufen,
zum Beispiel für Vokabeln:

#show-code(```typ
#import "@schule/flashcards:0.5.0": card, show-cards
#set page(paper: "a4", margin: 0pt)

#let vocabulary = (
  ("the house", "das Haus"),
  ("the tree", "der Baum"),
  ("to learn", "lernen"),
  ("the school", "die Schule"),
)

#for (english, german) in vocabulary {
  card(header: [Englisch], footer: [Unit 1], english, german)
}

#show-cards()
```)

= Die Karten setzen

`show-cards` setzt alle Karten des Dokuments. Die Stelle des Aufrufs ist frei:
Es erscheinen auch Karten, die erst danach angelegt werden. Üblich ist die
letzte Zeile des Dokuments.

Bei mehr als acht Karten entstehen mehrere Bögen, immer im Wechsel eine Seite
Fragen und eine Seite Antworten. Bei ungerader Kartenzahl bleibt die letzte
Zelle leer.

== Papierformat

`paper` wählt Kartengröße und Schrift. Die Seite selbst stellt das Dokument
mit `set page` auf dasselbe Format und ohne Rand ein.

#table(
  columns: 4,
  table.header[`paper`][Karte][Frage][Antwort],
  [`"a4"` (Vorgabe)], [105 mm × 74,25 mm], [12 pt, in der Mitte der Karte], [12 pt],
  [`"us-letter"`], [4,25 in × 2,75 in], [13,75 pt, fett, oben], [13,75 pt],
)

#show-example(
  rendered: preview("us-letter", (
    header: [Mathe],
    footer: [Analysis],
    question: [Ableitung von $x^n$?],
    answer: [$n dot x^(n-1)$],
  )),
  source: ```typ
  #import "@schule/flashcards:0.5.0": card, show-cards
  #set page(paper: "us-letter", margin: 0pt)

  #card(header: [Mathe], footer: [Analysis])[Ableitung von $x^n$?][
    $n dot x^(n-1)$
  ]

  #show-cards(paper: "us-letter")
  ```,
)

== Mehrere Fächer in einem Dokument

Kopf- und Fußzeile gehören zur einzelnen Karte. Karten verschiedener Fächer
stehen deshalb einfach hintereinander:

#show-code(```typ
#import "@schule/flashcards:0.5.0": card, show-cards
#set page(paper: "a4", margin: 0pt)

// Physik
#card(header: [Physik], footer: [Optik])[Was ist Reflexion?][
  Zurückwurf von Licht an einer Grenzfläche.
]
#card(header: [Physik], footer: [Optik])[Brechungsgesetz?][
  $n_1 sin(alpha_1) = n_2 sin(alpha_2)$
]
#card(header: [Physik], footer: [Elektrik])[Ohmsches Gesetz?][$U = R dot I$]
#card(header: [Physik], footer: [Elektrik])[Einheit des Widerstands?][$[R] = Omega$]

// Mathematik
#card(header: [Mathe], footer: [Analysis])[Ableitung von $x^n$?][$n dot x^(n-1)$]
#card(header: [Mathe], footer: [Analysis])[Ableitung von $sin(x)$?][$cos(x)$]
#card(header: [Mathe], footer: [Algebra])[Mitternachtsformel?][
  $x_(1,2) = (-b plus.minus sqrt(b^2 - 4 a c)) / (2a)$
]
#card(header: [Mathe], footer: [Algebra])[Binomische Formel $(a+b)^2$?][
  $a^2 + 2 a b + b^2$
]

#show-cards()
```)

= Drucken und Schneiden

- Im Druckdialog das Papierformat aus `paper` wählen und *ohne Skalierung*
  drucken („Tatsächliche Größe“, 100 %), sonst verschieben sich Vorder- und
  Rückseite gegeneinander.
- *Beidseitig* drucken und *an der langen Kante wenden* (Hochformat). Die
  Antwortseite hat vertauschte Spalten und passt nur so hinter die Fragen.
- Entlang der gestrichelten Linien schneiden.
- Für stabile Karten eignet sich Papier ab 160 g/m².

#tip[
  Vor dem Druck eines ganzen Stapels einen Bogen zur Probe drucken und gegen
  das Licht halten: Die Nummern auf Vorder- und Rückseite müssen
  übereinstimmen.
]

= Fehlermeldungen

Beide Funktionen prüfen ihre Argumente und brechen mit einer deutschen Meldung
ab, die den Fehler und die Abhilfe nennt:

#table(
  columns: 2,
  table.header[Eingabe][Meldung],
  [`#show-cards(papier: "a4")`],
  [``flashcards.show-cards: unbekannter Parameter `papier` – meintest du `paper`?``],
  [`#show-cards(paper: "a5")`],
  [``flashcards.show-cards: `paper: "a5"` ist kein gültiger Wert – meintest du `"a4"`? erlaubt: `"a4"`, `"us-letter"` ``],
  [`#card(header: "")[Frage][Antwort]`],
  [``flashcards.card: `header: ""` – für „keine Kopfzeile" `none` schreiben oder weglassen``],
)

= Umstieg auf 0.5.0 <umstieg>

Version 0.5.0 folgt den gemeinsamen Namensregeln der `@schule`-Pakete und
läuft unter Typst 0.15 (0.0.1 kompiliert dort nicht mehr). Das Aussehen der
Karten ist unverändert. Geändert haben sich die Namen und die Aufrufform:

#table(
  columns: 3,
  table.header[alt (0.0.1)][neu (0.5.0)][Hinweis],
  [`#card[Kopf][Fuß][Frage][Antwort]`],
  [`#card(header: [Kopf], footer: [Fuß])[Frage][Antwort]`],
  [Kopf- und Fußzeile sind benannt und dürfen fehlen.],
  [`#letter8up`],
  [`#show-cards(paper: "us-letter")`],
  [Funktion statt Wert, deshalb mit Klammern.],
  [`#a48up`],
  [`#show-cards(paper: "a4")` oder kurz `#show-cards()`],
  [A4 ist die Vorgabe.],
  [`cardnumber`, `cardheader`, `cardfooter`, `cardquestion`, `cardanswer`],
  [entfallen],
  [Interne Zähler und Zustände; kein Dokument braucht sie.],
)

Die alten Namen werden nicht still angenommen. `#letter8up` und `#a48up`
brechen mit der Meldung „heißt jetzt“ ab, die alte Aufrufform von `card` mit
vier Inhalten ebenso:

#table(
  columns: 2,
  table.header[Eingabe][Meldung],
  [`#letter8up`],
  [``flashcards.letter8up: `letter8up` heißt jetzt `show-cards(paper: "us-letter")` ``],
  [`#a48up`],
  [``flashcards.a48up: `a48up` heißt jetzt `show-cards(paper: "a4")` ``],
  [`#card[Kopf][Fuß][Frage][Antwort]`],
  [``flashcards.card: 4 Positionsargumente, erlaubt ist höchstens 2 – Kopf- und Fußzeile stehen benannt vor Frage und Antwort – `card(header: [...], footer: [...])[Frage][Antwort]` schreiben``],
)

#info[
  Das Handbuch von 0.0.1 zeigte
  `card(header: …, footer: …, question: …, answer: …)`
  mit vier benannten Argumenten. Diese Schreibweise hat das Paket
  nie angenommen; Frage und Antwort stehen als Inhalte hinter den Klammern.
]

= API-Referenz

#show-module(read("../src/flashcards.typ"), name: "flashcards")
