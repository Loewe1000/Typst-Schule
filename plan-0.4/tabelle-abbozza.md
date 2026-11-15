# Umbenennungstabelle abbozza 0.0.1 → 0.5.0

Stand 2026-11-15. Grundlage: `UMSETZUNG-0.5.0.md` (Vorrang), `konvention.md`, Ist-Zustand aus `inventar-hilfspakete.md` Abschnitt 9 und `abbozza/0.0.1/hathi-render.typ`. `tabelle-fachpakete.md` Abschnitt 8 sah für abbozza „unverändert lassen" vor; `UMSETZUNG-0.5.0.md` nimmt das Paket in den Umfang (Entscheidung 3), damit gilt die Konvention ganz.

Lesart wie in `tabelle-fachpakete.md`: **Art** = unverändert / umbenannt / Typ geändert / entfernt / neu. **Begründung**: G-Nr. = Glossarzeile (Konvention Abschnitt 3), § = Abschnitt der Konvention, L-Nr. = Lint-Regel.

---

## 1. Öffentliche Namen

Alte Signatur (`hathi-render.typ` Z. 20):

```typ
#let render-hathi-level(level, extra-tiles:(), scale: 1, print: false, replace: (:))
```

Neue Signatur (`src/hathi-level.typ`):

```typ
#let hathi-level(level, extra-tiles: (), tile-size: 25mm, print: false, replacements: (:), ..deprecated)
```

| alt | neu | Art | Begründung |
|---|---|---|---|
| `render-hathi-level` | `hathi-level` | umbenannt | § 4.1: ein englischer Helfer, der ein Ding setzt, ist ein Substantiv (`<merkmal>-<substantiv>`, wie `qr-code`); `render` ist kein erlaubtes Verb (erlaubt: `show set reset get has is format`). Kein Baustein: „Hathi" ist ein Eigenname (§ 2.1, Ausschluss B3 „Eigen- und Fremdnamen"), der Name bleibt englisch. Alter Name ist abbrechender Stub (§ 9.3). |
| Einstiegsdatei `hathi-render.typ` | `src/lib.typ` | umbenannt | § 7.1: Einstieg `src/lib.typ`, nur namentliche Exporte |
| alle Namen aus `@preview/cetz:0.3.4` (`canvas`, `draw`, `coordinate`, `matrix`, `vector`, … über `import …: *` in der Einstiegsdatei mit exportiert) | – | entfernt | § 7.1: keine Wildcard-Durchreichung fremder Pakete; die acht Fremdnamen reicht nur arbeitsblatt weiter (L19). Wer `canvas`/`draw` bisher über abbozza bezog, importiert cetz selbst. Kein Stub: es waren nie eigene Namen. |

## 2. Parameter von `hathi-level`

| alt | neu | Art | Begründung |
|---|---|---|---|
| `level` (positional) | `level` (positional) | unverändert | Hauptargument (§ 4.4 Nr. 2), Typ `array` (Ergebnis von `xml(…)`). Das Wort ist gleichlautend mit G24 (`level` = Anforderungsniveau); hier meint es das Spiellevel. Als Positionsargument tippt es kein Dokument, eine Verwechslung in einer Signatur ist ausgeschlossen (abbozza hat kein Niveau). |
| `extra-tiles: ()` | `extra-tiles: ()` | unverändert | englisch, kebab-case, Plural bei Vorgabe `()` (§ 4.2). Neue Wörter `extra`, `tiles`. |
| `scale: 1` | `tile-size: 25mm` | umbenannt, Typ geändert (Faktor → Länge) | § 5.5 („Längen sind Typst-Längen, nie nackte Zahlen", keine Faktoren), G63 (`scale` als Faktor verboten; `grid-size` ist das Muster für `<ding>-size`), Präzedenz `graphen(scale:)` in `tabelle-fachpakete.md`. Der Wert ist die Höhe einer Kachel; `scale: s` entspricht genau `tile-size: s * 25mm`, die Vorgabe `25mm` ist `scale: 1` (gleiches PDF). Die Fehlermeldung rechnet um: ``abbozza.hathi-level: `scale: 1.3` heißt jetzt `tile-size: 32.5mm` ``. Geht die Rechnung nicht auf drei Nachkommastellen auf (`scale: 1/3`), nennt die Meldung das Produkt (`tile-size: 0.3333333333333333 * 25mm`) statt eines gerundeten Werts, der ein anderes PDF gäbe. Stehen `scale` und ein von der Vorgabe abweichendes `tile-size` zugleich, lautet die Meldung „`scale` (alt) und `tile-size` (neu) zugleich" (§ 8.3); ebenso `replace`/`replacements`. Ein ausdrücklich geschriebener Vorgabewert (`tile-size: 25mm`, `replacements: (:)`) ist vom Weglassen nicht zu unterscheiden, dann bleibt es bei „heißt jetzt". Neues Wort `tile`. |
| `print: false` | `print: false` | unverändert | G55, Schalter W1 |
| `replace: (:)` | `replacements: (:)` | umbenannt | § 4.1: kein Imperativ als Parametername; Numerus-Vermerk nach dem Glossar: Vorgabe `(:)` steht im Plural. Neues Wort `replacements`. |
| – | `..deprecated` | neu | § 4.4 Nr. 5 c: fängt alte Namen und überzählige Positionsargumente ab, nimmt nichts an |

## 3. Schlüssel der Einträge von `extra-tiles`

| alt | neu | Art | Begründung |
|---|---|---|---|
| `type` | `kind` | umbenannt | G25 (Art, Sorte: `kind`; `typ` verboten) |
| `pos` | `at` | umbenannt | G72 verbietet `pos`; `position` ist dort eine Auswahl (Ort an einem Ding). Koordinatenpaar heißt `at` wie in `graphen(marks: ((at: …),))` (`tabelle-fachpakete.md`, mathematik) – gleicher Name, gleicher Typ in allen Paketen (§ 5.1). |
| `capacity` | `capacity` | unverändert | englisch; neues Wort |
| `hue` | `hue` | unverändert | englisch; neues Wort. Wirkt weiterhin nur bei `kind: "flag"`. |
| `direction` | `direction` | unverändert | englisch; neues Wort. Nicht `rotation` (G75): der Wert ist kein Winkel, sondern die Blickrichtung `"0"` bis `"3"` aus dem Dateiformat. |

Die Schlüssel werden geprüft (§ 5.4): unbekannte Schlüssel brechen ab, `type` und `pos` mit „heißt jetzt".

## 4. Werte

| alt | neu | Art | Begründung |
|---|---|---|---|
| Kachelarten `"grass"`, `"ice"`, `"water"`, `"rock"`, `"tree"`, `"flag"`, `"lion"`, `"bananas"`, `"crate"`, `"hathi"`, `"hartmut"` (in `extra-tiles[].kind`, als Schlüssel und Werte von `replacements`) | dieselben | unverändert | Vokabular des Abbozza-Dateiformats (Attribut `type` in `<tile>`/`<item>`), also Daten nach § 2.1; englisch und kebab-fähig. Unbekannte Arten werden wie bisher still ausgelassen (das Handbuch nutzt das für leere Felder), deshalb keine Werteprüfung. |
| `direction: "0"` … `"3"` | dieselben | unverändert | Dateiformat (Attribut `direction`); weiterhin Zeichenketten |
| XML-Tags `world`, `tile`, `item`; Attribute `type`, `x`, `y`, `capacity`, `direction` | dieselben | unverändert | Fremdformat, keine Bezeichner des Pakets |

## 5. States, Counter, Labels, Rückgabe

Keine. `hathi-level` liefert Inhalt (ein cetz-`canvas`).

## 6. Abhängigkeiten

`@preview/cetz:0.3.4` bleibt (gleiches PDF; ein Wechsel auf 0.5.x ist eine Pflegeaufgabe, keine Namensfrage), wird aber namentlich importiert (`canvas`, `draw`) und nicht mehr weitergereicht.

## 7. Neue Wörter

- `words-en-zusatz.txt`: `extra`, `tile`, `tiles`, `replacements`, `capacity`, `hue`, `direction`
- `names-zusatz.txt` (Eigenname, als Segment eines Funktionsnamens): `hathi`
- kein neuer deutscher Baustein

## 8. Verhalten, das sich nicht ändert

- Gleiche Kachelgröße, gleiche Lage, gleiche Bilder; `print: true` tauscht weiterhin nur `grass` und `water`.
- Neu sind allein Prüfungen mit deutscher Meldung an Stellen, an denen 0.0.1 mit einer Typst-Meldung abbrach (falscher Typ, fehlende Schlüssel, fehlendes `<world>`, fehlende `capacity`/`direction`).
- Die Werte in `extra-tiles` werden dort geprüft, wo 0.0.1 sie benutzte: `at` (zwei Einträge, je Zahl oder Ziffern als Text) immer, `capacity` (`int`, `float`, `str`) nur bei `"bananas"`/`"crate"`, `hue` (`int`, `float`) nur bei `"flag"`, `direction` nur bei `"hathi"`/`"hartmut"` (eine Zahl `0` bis `3` bekommt den Hinweis auf die Anführungszeichen). Was 0.0.1 annahm, wird weiter angenommen: Kommazahlen in `at` werden wie bisher abgeschnitten, ein `hue` an einer anderen Kachel bleibt ohne Wirkung und ungeprüft.

---

## Anhang: maschinenlesbar

```json
{
  "paket": "abbozza",
  "von": "0.0.1",
  "nach": "0.5.0",
  "funktionen": {
    "abbozza.render-hathi-level": "abbozza.hathi-level"
  },
  "neu": [],
  "stubs": ["abbozza.render-hathi-level"],
  "import-noetig": {
    "abbozza": ["hathi-level"]
  },
  "parameter": {
    "abbozza.render-hathi-level": {"scale": "tile-size", "replace": "replacements"},
    "abbozza.render-hathi-level.extra-tiles[]": {"type": "kind", "pos": "at"}
  },
  "werte": {
    "abbozza.render-hathi-level.scale": {"1": null, "*": "tile-size: $v * 25mm"}
  },
  "kontext": [
    {"alt": "render-hathi-level(…, scale: S)", "regel": "tile-size: S * 25mm; bei Zahl-Literal ausrechnen (scale: 1.3 → tile-size: 32.5mm), scale: 1 löschen"},
    {"alt": "extra-tiles: (… (type: T, pos: P) …) als Literal im Aufruf", "regel": "kind: T, at: P; steht das Array nicht als Literal im Aufruf: Bericht, die Laufzeitprüfung meldet die Schlüssel"},
    {"alt": "#import \"@schule/abbozza:0.0.1\": * mit Nutzung von canvas, draw oder anderen cetz-Namen", "regel": "Bericht: cetz selbst importieren (#import \"@preview/cetz:0.3.4\": canvas, draw)"}
  ],
  "states": {},
  "labels": {},
  "entfernt": [
    "abbozza.<alle über import * durchgereichten Namen aus @preview/cetz:0.3.4>"
  ],
  "woerter": {
    "words-en-zusatz.txt": ["extra", "tile", "tiles", "replacements", "capacity", "hue", "direction"],
    "names-zusatz.txt": ["hathi"]
  }
}
```
