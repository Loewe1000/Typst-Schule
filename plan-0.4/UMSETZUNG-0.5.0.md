# Umsetzung als 0.5.0 – verbindliche Vorgaben (2026-11-15)

Diese Datei hat Vorrang vor allen anderen Dateien in diesem Ordner. Wo
`konvention.md`, die Tabellen oder `architektur-release.md` etwas anderes
sagen (Versionsnummer 0.4.1, Paket `kern`, dreizehn Zugpakete, Zug-Skripte,
`eingefroren.json`, Phasenplan mit 60 bis 104 Tagen), gilt diese Datei.

## Entscheidungen des Autors

1. **Deutsche Bausteinnamen auf Dauer**, alles in den Klammern englisch
   (in `konvention.md` und den Tabellen bereits eingearbeitet).
2. **Version 0.5.0** für jedes überarbeitete Paket, im neuen Ordner
   `<paket>/0.5.0/`. Überall, wo die Unterlagen 0.4.1 sagen, ist 0.5.0 gemeint.
3. **Umfang: nur Pakete mit Handbuch auf der Website**, ohne blockst und
   typstage. Das sind 17 Pakete:
   arbeitsblatt, aufgaben, klassenarbeit, klausurboegen, patterns,
   mathematik, physik, informatik, operatoren, insert-a-word, energy-sketch,
   typlace, summify, gutachten, flashcards, angela, abbozza.
4. **Nicht angefasst:** blockst, typstage, typstage-geogebra, random, options,
   typopst, messwerttabellen, eduki, schuldocs und alle bestehenden
   Versionsordner. Nichts wird gelöscht, nichts in alten Ordnern geändert.

## Folgerungen

- **Kein Paket `kern`.** Die gemeinsame Prüf- und Fehlermechanik
  (`fail`, Optionsprüfung mit Tippfehlervorschlag, „heißt jetzt"-Meldungen)
  liegt als eine Datei `.github/namen/check.typ` vor und wird wortgleich nach
  `<paket>/0.5.0/src/internal/check.typ` kopiert. `.github/scripts/check-sync.sh`
  prüft, dass alle Kopien gleich sind. Wo die Unterlagen `kern` importieren,
  ist diese Datei gemeint.
- **random bleibt 0.0.1.** Wer es braucht, importiert namentlich nur die
  benötigten Funktionen; nichts aus random wird weitergereicht. Die in
  `tabelle-fachpakete.md` für random geplanten neuen Namen entfallen.
- **Abhängigkeiten innerhalb des Umfangs zeigen auf 0.5.0**
  (`@schule/aufgaben:0.5.0` usw.), nie auf ältere Versionen.
- **Kein Zug-Werkzeug**, kein `eingefroren.json`, kein Bündel-Skript. Es
  genügen: `check.typ`, `sig.py` (Signaturliste und Namens-Lint),
  `umstellen.py` (Codemod für Dokumente), die Tests unter `tests/`.
- **Hilfspakete** (typlace, summify, gutachten, flashcards, angela, abbozza)
  hatten bisher keine Umbenennungstabelle. Wer sie umsetzt, schreibt zuerst
  `tabelle-<paket>.md` nach den Regeln der Konvention und setzt dann um.
  Neue deutsche Bausteinnamen werden nach dem Bausteintest der Konvention
  entschieden und gemeldet.
- **Übrige offene Punkte nach Empfehlung:** die acht Fremdnamen (`canvas`,
  `draw`, `plot`, `qty`, `num`, `unit`, `stickybox`, `fa-icon`) werden von
  arbeitsblatt weitergereicht; zweite Wege (`""` statt `none`,
  `kariert(4, 12)`, `aufgabe[Titel][Rumpf]`) sind Fehler mit Abhilfe;
  klausurboegen führt die Äste 0.0.4 und 0.0.5 zusammen.

## Was jedes Paket in 0.5.0 erfüllen muss

1. Ordner `<paket>/0.5.0/` als Kopie der neuesten Version, `typst.toml` mit
   `version = "0.5.0"`, sinnvoller `description` und `compiler = "0.15.0"`.
2. Öffentliche Namen, Parameter, Schlüssel und Werte nach Tabelle und
   Konvention. Namentliche Exporte, keine Wildcard-Durchreichung fremder
   Pakete (Ausnahme: die acht Fremdnamen in arbeitsblatt; klassenarbeit reicht
   die Oberfläche von arbeitsblatt bewusst weiter).
3. Jede öffentliche Funktion lehnt unbekannte benannte Argumente ab; alte
   Namen brechen mit „`alt` heißt jetzt `neu`" ab. Alte Funktionsnamen sind
   abbrechende Stubs.
4. Gleiches Dokument, gleiches PDF: Außer den Namen ändert sich kein
   Verhalten und keine Vorgabe. Fehler werden nur behoben, wenn die Tabelle
   es verlangt oder das Paket sonst unter Typst 0.15 nicht kompiliert.
5. Handbuch `docs/docs.typ` auf schuldocs 0.3.0 mit Docstrings an jeder
   öffentlichen Funktion; es baut fehlerfrei, und jedes Beispiel darin
   kompiliert. README, `template/`, `examples/`, `showcase/` nachgezogen.
6. Tests unter `tests/` mit dem Präfix `v05-<paket>-`: mindestens ein Test
   der Hauptfunktionen, einer für eine „heißt jetzt"-Meldung, einer für eine
   unbekannte Option. `bash tests/run.sh` bleibt vollständig grün.
7. Ein Vergleichsbeleg: ein Dokument mit der alten Version und dasselbe
   Dokument mit 0.5.0 (nur Namen angepasst) liefern denselben PDF-Text und
   dieselbe Seitenzahl.
