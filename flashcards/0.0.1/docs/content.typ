#import "../../../schuldocs/0.1.0/lib.typ": show-example, show-module, show-code

= Über dieses Paket

Das `flashcards`-Paket erstellt *beidseitige Lernkarten im 8-up-Format* auf Letter-Papier
(21,6 × 27,9 cm). Pro Seite werden acht Karten (2 Spalten × 4 Zeilen) angeordnet.
Nach dem Ausdruck werden die Bögen entlang der Mittellinie gefaltet, sodass Vorder-
und Rückseite jeder Karte exakt übereinanderliegen.

Jede Karte besteht aus:
- *Kopfzeile* (`header`) — z. B. Fachbezeichnung oder Kartenset-Name
- *Fußzeile* (`footer`) — z. B. Thema oder Kapitel
- *Frage* (`question`) — Vorderseite der Karte
- *Antwort* (`answer`) — Rückseite der Karte

Das Paket verwendet die `locate`-API von Typst ≥ 0.11 und ist für den Einsatz
auf Letter-Papier optimiert.

= Schnellstart

#show-code[```typ
#import "@schule/flashcards:0.0.1": card, letter8up

// Karten definieren:
#card(
  header: "Physik",
  footer: "Kinematik",
  question: [Was beschreibt die Gleichung $s = v dot t$?],
  answer: [Den zurückgelegten Weg $s$ bei gleichförmiger Bewegung
           mit Geschwindigkeit $v$ in der Zeit $t$.],
)
#card(
  header: "Physik",
  footer: "Kinematik",
  question: [Einheit der Geschwindigkeit?],
  answer: [$[v] = "m/s"$],
)
#card(
  header: "Physik",
  footer: "Dynamik",
  question: [Was besagt das zweite Newtonsche Gesetz?],
  answer: [$F = m dot a$ — Kraft ist Masse mal Beschleunigung.],
)
#card(
  header: "Physik",
  footer: "Dynamik",
  question: [Einheit der Kraft?],
  answer: [$[F] = "N" = "kg" dot "m/s"^2$],
)

// Karten im 8-up-Format auf Letter ausgeben:
#letter8up
```]

*Wichtig:* `#letter8up` muss am Ende der Datei stehen, *nachdem* alle `#card(...)`-Aufrufe
erfolgt sind, da es die intern gespeicherten Karten abfragt.

= Aufbau einer Karte

#show-code[```typ
#card(
  header: "Fach",       // str oder content: Erscheint oben auf der Karte (klein, smallcaps)
  footer: "Thema",      // str oder content: Erscheint unten (kursiv)
  question: [Frage],    // content: Vorderseite — größer, fett dargestellt
  answer:   [Antwort],  // content: Rückseite — regular, Fließtext
)
```]

Karten werden intern in einem Typst-State gespeichert; die Reihenfolge der
`#card(...)`-Aufrufe im Dokument bestimmt die Reihenfolge auf dem Ausdruck.
Jede Karte erhält automatisch eine Nummer (z. B. „3/8").

= Mehrere Kartensets

Verschiedene Fächer oder Themen können in einer einzigen Datei kombiniert werden:

#show-code[```typ
#import "@schule/flashcards:0.0.1": card, letter8up

// Set 1: Physik
#card(header: "Physik", footer: "Optik",      question: [Was ist Reflexion?],      answer: [Zurückwurf von Licht an einer Grenzfläche.])
#card(header: "Physik", footer: "Optik",      question: [Brechungsgesetz?],         answer: [$n_1 sin(alpha_1) = n_2 sin(alpha_2)$])
#card(header: "Physik", footer: "Elektrik",   question: [Ohmsches Gesetz?],         answer: [$U = R dot I$])
#card(header: "Physik", footer: "Elektrik",   question: [Einheit des Widerstands?], answer: [$[R] = Omega$])

// Set 2: Mathematik
#card(header: "Mathe", footer: "Analysis",    question: [Ableitung von $x^n$?],     answer: [$n dot x^(n-1)$])
#card(header: "Mathe", footer: "Analysis",    question: [Ableitung von $sin(x)$?],  answer: [$cos(x)$])
#card(header: "Mathe", footer: "Algebra",     question: [Mitternachtsformel?],       answer: [$x_(1,2) = (-b plus.minus sqrt(b^2 - 4 a c)) / (2a)$])
#card(header: "Mathe", footer: "Algebra",     question: [Binomischer Lehrsatz $(a+b)^2$?], answer: [$a^2 + 2 a b + b^2$])

#letter8up
```]

= Formeln und Aufzählungen

Alle Felder akzeptieren beliebigen Typst-Content — also auch Formeln, Listen und Tabellen:

#show-code[```typ
#card(
  header: "Physik",
  footer: "Energieformen",
  question: [Nenne drei Energieformen.],
  answer: [
    - Kinetische Energie: $E_"kin" = 1/2 m v^2$
    - Potentielle Energie: $E_"pot" = m g h$
    - Thermische Energie: $Q = m c Delta T$
  ],
)
```]

= Druck-Hinweise

- Papierformat: *Letter* (21,6 × 27,9 cm) — Druckertreiber entsprechend einstellen.
- Beidseitiger Druck aktivieren: *„an der kurzen Seite spiegeln"* (Hochformat).
- Nach dem Druck entlang der Mittellinie falten:
  Vorder- und Rückseite liegen dann übereinander.
- Die Karten können entlang der Raster-Linien ausgeschnitten werden.
- Für stabilere Karten: auf 160 g/m²-Papier oder Karton drucken.

= API-Referenz

#show-module(read("../flashcards.typ"), name: "flashcards")
