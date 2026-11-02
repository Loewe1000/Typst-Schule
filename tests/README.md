# Regressionstests

Kleine Typst-Dokumente, die je einen behobenen Fehler oder eine Funktion
absichern. Ausführen aus dem Repo-Root:

```bash
bash tests/run.sh
```

Jede Datei `tests/*.typ` wird kompiliert und ihr Text (per `pdftotext`) gegen
Kommentarzeilen am Dateianfang geprüft:

- `// erwartet: <regex>` – muss im Text vorkommen (erweiterter regulärer Ausdruck)
- `// nicht: <regex>` – darf im Text nicht vorkommen
- `// fehler: <text>` – das Kompilieren muss mit dieser Meldung scheitern

Ohne solche Zeilen muss die Datei nur fehlerfrei kompilieren.

Benötigt: `typst` (≥ 0.15) und `pdftotext` (poppler).
