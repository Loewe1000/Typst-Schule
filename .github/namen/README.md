# Namen und Prüfmechanik der @schule-Pakete (ab 0.5.0)

Regeln: `plan-0.4/UMSETZUNG-0.5.0.md` (Vorrang) und `plan-0.4/konvention.md`.

| Datei | Inhalt |
|---|---|
| `check.typ` | Quelle der gemeinsamen Prüf- und Fehlermechanik. Ohne Importe, ohne State. |
| `bausteine-de.txt` | Die 30 deutschen Bausteinnamen (Funktionen), abschließend. |
| `words-en.txt` | Erlaubte englische Wörter für jedes Segment aller übrigen Namen. |
| `words-en-zusatz.txt` | Ergänzungen aus der Umsetzung, ein Wort je Zeile. Wer ein Wort braucht, hängt es an und meldet es. |
| `names.txt` | Eigennamen (Themes, Chiffren, `sek-1`, zap-Vokabular). |
| `fremdnamen.txt` | Die acht Fremdnamen, die arbeitsblatt weiterreicht. |
| `zwillinge.txt` | Englische Zwillinge der Bausteine; dürfen nie exportiert werden. |
| `wortpaare.json` | Baustein → Parameterwort (`aufgabe` → `task`, `tasks`). Steht wortgleich als `word-pairs` in `check.typ`. |

Zu jeder `.txt`-Liste liest das Lint auch `<liste>-zusatz.txt`, wenn es sie gibt.

## check.typ in einem Paket

```sh
mkdir -p <paket>/0.5.0/src/internal
cp .github/namen/check.typ <paket>/0.5.0/src/internal/check.typ
bash .github/scripts/check-sync.sh     # alle Kopien byte-gleich?
```

Die Kopie wird nie geändert. Änderungen gehen in die Quelle, danach wird neu kopiert.

```typ
#import "internal/check.typ": fail, check-named, check-value, check-type, check-positional

#let aufgabe(title: none, method: none, ..deprecated, body) = {
  check-positional("aufgaben", "aufgabe", deprecated,
    hint: "Titel als zweites Inhaltsargument – `aufgabe(title: [...])[...]` schreiben")
  check-named("aufgaben", "aufgabe", deprecated,
    renamed: (titel: "title"), removed: (farbe: "die Farbe bestimmt das Theme"),
    allowed: ("title", "method"))
  check-value("aufgaben", "aufgabe", "method", method,
    (none, "individual", "pair", "group"), renamed: (PA: "pair"))
  body
}

// src/removed.typ
#let lücke = stub("arbeitsblatt", "lücke", "luecke")
```

`#aufgabe(titel: [A])[…]` und `#show: aufgabe.with(titel: [A])` brechen ab mit
``aufgaben.aufgabe: `titel` heißt jetzt `title` ``. Die vollständige API mit allen
Meldungstexten steht im Kopf von `check.typ`. Freie Meldungen laufen über
`fail(paket, funktion, "Befund – Abhilfe")`; `panic` und `assert` stehen sonst nirgends.

## Prüfen

```sh
python3 .github/scripts/sig.py <paket> [version]          # öffentliche Oberfläche als JSON
python3 .github/scripts/sig.py --lint <paket> [version]   # Namens-Lint, Exit 1 bei Verstößen
python3 .github/scripts/sig.py --eval <paket> [version]   # Abgleich mit den Exporten zur Laufzeit
```

Tests dazu: `tests/v05-namen-check-*.typ`.
