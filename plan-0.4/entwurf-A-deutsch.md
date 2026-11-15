# Konvention A: Deutsch zuerst (Entwurf für die 0.4.x-Linie der @schule-Pakete)

Stand 2026-11-14. Grundlage: die Inventare unter `scratchpad/inventar/` (Signaturen, Zeilennummern, Nutzungszahlen) und die Prototypen unter `scratchpad/technik/` (`compat.typ`, `sig.py`, `codemod.py`). Am Repo wurde nichts geändert.

Leitsatz: **Wer ein Arbeitsblatt schreibt, liest und schreibt nur Deutsch.** Jeder öffentliche Name (Funktion, Parameter, Optionsschlüssel, Enum-Wert, Theme-Schlüssel, Hook-Argument) ist ein deutsches Wort aus einem festen Glossar. Englisch erscheint nur noch dort, wo ein Wert *unverändert* bei Typst oder einem Fremdpaket ankommt.

Zielversion: `arbeitsblatt 0.4.1`, `klassenarbeit 0.4.1`, `aufgaben 0.4.1`, `klausurboegen 0.4.1`, `patterns 0.4.1` (0.4.1 ist überall frei; 0.4.0 bleibt als Themes-Zwischenstand liegen, die 58 Dokumente darauf sind nicht betroffen, solange sie nicht umgepinnt werden).

Nicht selbst geprüft und vor der Umsetzung am Code nachzusehen (im Text jeweils markiert mit **[prüfen]**): die genaue Bedeutung von `loesungen: "sofort"` gegenüber `"folgend"` und von `punkte: "keine-summe"`; beide sind hier aus den Inventaren erschlossen.

---

## 1. Sprach- und Schreibregeln (lintbar)

Alle Regeln sind so gefasst, dass `sig.py --lint` sie gegen die Signaturliste prüfen kann. Die Wortlisten liegen als Textdateien im Repo (`namen/glossar.txt`, `namen/verboten.txt`, `namen/lehnwoerter.txt`, `namen/fremdfunktionen.txt`); ein neues Wort braucht einen Eintrag im Glossar, sonst schlägt der Lint fehl. Das Glossar ist damit zugleich die Durchsetzung von "ein Wort je Begriff".

### R1 Zeichen und Schreibweise

Jeder öffentliche Name passt auf

```
^[a-z][a-z0-9]*(-[a-z0-9]+)*$
```

Also: nur kebab-case, nur Kleinbuchstaben, keine Unterstriche, kein camelCase, keine Ziffer am Anfang eines Namens. Interne Namen bekommen genau einen führenden Unterstrich und sonst dieselbe Form (`^_[a-z]...`), auch States und Zähler (`_zustand-optionen` statt `_state_options`).

### R2 Umlaute: Umschrift `ae/oe/ue/ss` in allen Bezeichnern und Enum-Werten

Regel: In Bezeichnern, Dictionary-Schlüsseln, Enum-Werten, State-Schlüsseln, Labels und `sys.inputs` stehen **keine** `ä ö ü ß`. Echte Umlaute stehen nur in sichtbarem Text: Ausgabe im PDF, Fehlermeldungen, Doku, Namen der erzeugten PDF-Dateien (`... - Lösung.pdf`).

Lint: R1 erzwingt das bereits (Zeichenklasse `[a-z0-9-]`).

Begründung:

1. Paket- und Dateinamen müssen ASCII sein. Mit Umlauten im Code hieße dasselbe Ding weiter dreifach: Paket `klausurboegen`, Funktion `klausurbögen`, Parameter `klausurboegen`. Mit Umschrift gibt es genau eine Schreibweise für Paket, Funktion, Parameter und Variantenwert.
2. Der Bestand steht schon überwiegend so: `loesungen` in 483 Dokumentköpfen, `klausurboegen` in 91, `loesung(` 85 Aufrufe, Theme-Schlüssel `groesse`/`aussen`. Mit Umlaut gibt es im Kern nur `lücke` (111 Aufrufe), `klausurbögen`, `weißer-rand`, `häufigkeitsanalyse`. Die Umschrift ändert weniger.
3. `größe` und `groesse` sind für Typst verschiedene Namen. Jede Mischform verdoppelt den Raum möglicher Tippfehler; eine feste Regel halbiert ihn.
4. Enum-Werte wandern in Kommandozeilen (`--input`), Labels, Dateinamen-Bausteine und Sync-Dienste (macOS/Synology zerlegen Umlaute teils in Grundbuchstabe plus Trema; ein so kopiertes `ü` ist ein anderer Bezeichner).
5. Der Lint wird zu einem regulären Ausdruck.

Kosten, ehrlich: Gerade die häufigsten deutschen Wörter sehen umschrieben unschön aus (`loesungen`, `arbeitsflaeche`, `luecke`, `hoehe`, `schriftgroesse`, `aussen`). "Deutsch zuerst" in nicht ganz deutscher Rechtschreibung ist die sichtbarste Schwäche dieses Ansatzes (siehe Abschnitt 8).

Abfederung: Die Optionsprüfung faltet unbekannte Namen probeweise (`ä→ae`, `ö→oe`, `ü→ue`, `ß→ss`) und meldet dann gezielt ``arbeitsblatt: `lösungen` schreibt sich `loesungen` ``. Es gibt keine Umlaut-Aliase (der heutige Alias `"außen"` in klausurboegen entfällt).

### R3 Sprache: Glossarpflicht

Ein Name wird an den Bindestrichen zerlegt. Jedes Segment muss in genau einer dieser Listen stehen:

| Liste | Inhalt | Beispiele |
|---|---|---|
| `glossar.txt` | deutsche Wörter des Projekts, je Zeile `wort; numerus; begriff` | `titel`, `klasse`, `loesung`, `loesungen`, `arbeitsflaeche`, `schriftgroesse`, `nummerierung` |
| `lehnwoerter.txt` | im Duden geführte Lehnwörter, die im Schulalltag deutsch benutzt werden | `logo`, `icon`, `icons`, `info`, `code`, `weblink`, `material`, `format`, `variante` |
| Kurzwörter (in `lehnwoerter.txt` markiert) | höchstens fünf, fest | `qr`, `url`, `lsg`, `kc`, `pdf` |
| `fremdfunktionen.txt` | Namen, die unverändert aus Fremdpaketen weitergereicht werden | `canvas`, `draw`, `plot`, `qty`, `num`, `unit`, `codly`, `fa-*` |

Zusammengesetzte Wörter (`schriftgroesse`, `kopfabstand`, `teilaufgabe`) stehen als ganzes Wort im Glossar; der Lint zerlegt keine Komposita. Bindestrich nur zwischen eigenständigen Gliedern (`teilaufgaben-nummerierung`, `marke-breite`, `vorschau-alle`).

### R4 Verbotsliste (Englisch und Synonyme)

`verboten.txt` bildet jedes verbotene Segment auf das Glossarwort ab. Der Lint meldet "`title` → `titel`". Ausgangsbestand (alle Wörter stammen aus den heutigen Signaturen):

```
title→titel            subtitle→untertitel     class→klasse           date→datum
teacher→lehrkraft      student→name            body→inhalt            content→inhalt
text→inhalt            width→breite            height→hoehe           size→groesse
color→farbe            colour→farbe            fill→hintergrund       background→hintergrund
stroke→linie           spacing→abstand         gutter→abstand         gap→abstand
margin→rand            numbering→nummerierung  number→nummeriert|nummer
label→anker            caption→beschriftung    print→druck            page→seite
paper→papier           landscape→querformat    flipped→querformat     duplex→beidseitig
font→schrift           header→kopf             footer→fuss            rows→zeilen
columns→spalten        items→eintraege         tasks→eintraege        points→punkte
solution→loesung       solutions→loesungen     task→aufgabe           workspace→arbeitsflaeche
workspaces→arbeitsflaechen                     theme→gestaltung       themes→gestaltungen
setup→einrichtung      method→sozialform       large→gross            tight→eng
inline→kasten(umgekehrt)                       grouped→gruppiert      compact→kompakt
full→summenspalte      curr→nur-aktuelle       idx→(entfaellt)        exam→titel
subexam→untertitel     students→ergebnisse     result→nur-ergebnis    scale→kaestchengroesse
show→zeige             set→setze               get→lies               reset→setze-…-zurueck
breakable→umbrechbar   headless→(titel: none)  accent→farbe           copyright→quelle
scope→bereich          template→vorlage        shortcodes→kurzschreibweise
annotations→zeichnung  only→nur                non→(Positivschalter)  hide→(Positivschalter)
```

Deutsche Synonyme, die ebenfalls verboten sind, damit es je Begriff ein Wort gibt: `ueberschrift`→`titel`, `kurs`→`klasse`, `lehrer`→`lehrkraft`, `zeilenhoehe`/`linienhoehe`→`linienabstand`, `spaltenabstand`/`zwischenraum`→`abstand`, `platzhalter`→`luecke`, `workspace`/`platz`(als Inhalt)→`arbeitsflaeche`, `design`/`stil`/`thema`(als Gestaltung)→`gestaltung`, `be`/`bewertungseinheiten`→`punkte`, `position`→`ort`, `verweis`/`marke`(als Sprungziel)→`anker`.

### R5 Keine Überdeckung von Typst-Namen

Kein Parameter und keine öffentliche Funktion heißt wie ein Typst-Builtin, das im selben Paket gebraucht wird: `text`, `table`, `page`, `image`, `block`, `box`, `grid`, `figure`, `align`, `label`, `content`, `symbol`, `columns`, `numbering`, `link`, `footnote`, `heading`. (Heute: lokale Variable `table` in klassenarbeit, Parameter `content` in `kariert`, `text` in `operator`.) Deshalb auch `icon`/`icons` statt `symbol`/`symbole`.

### R6 Wo Englisch erlaubt bleibt (abschließend)

1. **Durchreich-Sink.** Benannte Argumente, die eine Funktion nicht deklariert und 1:1 an eine Typst- oder Fremdfunktion gibt. Der Sink heißt immer `..weitere`; die Doku nennt das Ziel ("weitere benannte Argumente gehen an `table`").
2. **Durchreich-Dictionary.** Ein deutsch benannter Parameter, dessen *Schlüssel* Typst-Argumente sind: `seite: (margin: 1cm, columns: 2)` (geht an `set page`), `versatz: (dx: 0cm, dy: 0cm)` (geht an `move`). Im Glossar als `durchgereicht → page` markiert.
3. **Typst-Werte.** `horizon`, `top + right`, `"a4"`, `1fr`, Nummerierungsmuster `"a)"`, `"1.1"`.
4. **Fremdfunktionen**, die unverändert oder nur mit Voreinstellungen weitergereicht werden (`canvas`, `qty`, `num`, `unit`).

Nirgends sonst. Insbesondere gibt es keinen deklarierten englischen Parameter mehr, auch wenn er "eigentlich nur durchgereicht" wird: `breite` statt `width`, `ausrichtung` statt `align`.

### R7 Export-Disziplin (Voraussetzung dafür, dass R1–R6 prüfbar sind)

Der Lint prüft die Menge der tatsächlich exportierten Namen (`typst eval`), nicht nur die `#let` im Quelltext.

- Kein `import "...": *` von Fremdpaketen im Entrypoint. Fremdpakete werden gezielt (`import "@preview/cetz:0.4.2": canvas, draw`) oder als Modul (`import "@preview/cetz:0.4.2"`) durchgereicht; die erlaubten Namen stehen in `fremdfunktionen.txt`.
- Paketübergreifend benötigte Interna liegen in einem Modul `intern` (`#import "@schule/aufgaben:0.4.1": intern`), nicht als `_name` im Hauptnamensraum. `klassenarbeit` greift dann auf `intern.einzeln`, `intern.zustand-bereich` zu statt auf `_state_ab_scope`.
- `random` (`a`, `m`, snake_case) wird nicht mehr per `*` durchgereicht.

---

## 2. Grammatik der Namen

### 2.1 Funktionen

| Art | Muster | Beispiele |
|---|---|---|
| Baustein (erzeugt Inhalt an Ort und Stelle) | Substantiv im Singular | `aufgabe`, `teilaufgabe`, `loesung`, `erwartung`, `material`, `luecke`, `arbeitsflaeche`, `seitenumbruch`, `weblink`, `qr-code`, `qr-kasten` |
| Baustein, der mehrere gleichartige setzt | Substantiv im Plural | `teilaufgaben`, `klausurboegen` |
| Muster/Fläche | Partizip oder Adverb | `kariert`, `liniert`, `nebeneinander` |
| Dokumentvorlage (Show-Regel) | Substantiv Singular = Paketname | `arbeitsblatt`, `klassenarbeit` |
| Ausgabe gesammelter Inhalte | `zeige-` + Plural | `zeige-loesungen`, `zeige-materialien`, `zeige-erwartungen`, `zeige-bewertung` |
| Zustand ändern | `setze-` + Objekt (+ `-zurueck`) | `setze-optionen`, `setze-aufgaben-zurueck` |
| Wert abfragen (braucht `context`) | `lies-` + Objekt | `lies-punkte` |
| Ja/Nein-Abfrage | `ist-` + Eigenschaft | `ist-loesungsfassung`, `ist-fuellfeld` |
| Kasten | deutscher Standardtitel als Name | `merke`, `tipp`, `achtung`, `beispiel` (siehe 5.12) |

Genau vier Verbvorsilben: `zeige-`, `setze-`, `lies-`, `ist-`. Lint: Ein Name, dessen erstes Segment ein Verb aus einer Verbliste ist (`show`, `set`, `get`, `reset`, `format`, `create`, `make`, `hole`, `gib`, `mache`, `erzeuge`, `pruefe` …), muss eine der vier Vorsilben tragen. Der Imperativ vorn ist bewusst gewählt: er entspricht dem heutigen `show-`/`set-`/`get-` (Umstellung ist ein reiner Vorsilbentausch), gruppiert in der Autovervollständigung nach Tätigkeit und ist aus den deutschen Scratch-Blöcken ("zeige", "setze") vertraut.

Keine Abkürzungen außer den fünf Kurzwörtern aus R3. `aufg`, `teil`, `curr`, `idx`, `opts`, `mv`, `sub`, `sek1`, `ka-id` verschwinden.

### 2.2 Singular und Plural

- **Singular**: ein Baustein, ein Wert, ein Schalter (`titel`, `breite`, `arbeitsflaeche`, `anker`, `gestaltung`).
- **Plural**: (a) Parameter, deren Wert eine Liste ist (`icons`, `eintraege`, `stichworte`, `jahrgaenge`, `varianten`, `ergebnisse`); (b) Dokumentoptionen, die *alle* Bausteine einer Art betreffen (`loesungen`, `materialien`, `punkte`, `arbeitsflaechen`, `erwartungen`, `klausurboegen`).
- Lint: Vorgabe `()` verlangt ein Wort mit Glossar-Numerus `pl`; Vorgabe vom Typ Länge/Farbe/Inhalt verlangt `sg`.
- Zwei Namen, die sich nur im Plural-Buchstaben unterscheiden, dürfen nie nebeneinander als Parameter derselben Funktion oder als Werte desselben Enums stehen (heute: `variante`/`varianten`, `"seite"`/`"seiten"`). Lint: Levenshtein-Abstand 1 innerhalb einer Signatur oder Werteliste ist ein Fehler.

### 2.3 Schalter

- Immer positiv: der Name sagt, was bei `true` zu sehen ist. Verboten als erstes Segment: `kein`, `keine`, `ohne`, `nicht`, `no`, `non`, `hide`, `un`.
- Form: Adjektiv/Partizip (`gross`, `eng`, `nummeriert`, `beidseitig`, `kompakt`, `gruppiert`, `umbrechbar`) oder Substantiv für "ist vorhanden" (`druck`, `querformat`, `summenspalte`, `ergebnisfeld`).
- Einschränkende Vorsilbe `nur-` ist erlaubt, weil sie nichts verneint (`nur-aktuelle`, `nur-ergebnis`).
- Heutige versteckte Negativschalter werden gedreht: `weißer-rand: true` → `rand-kariert: false`; `sub: true` → `ergebnisfeld: false`; `inline: true` → `kasten: false`; `hide-words` → `wortkasten: true`; `non-print-pagebreak` → `seitenumbruch(druck: false)`.

### 2.4 Feste Wörter (Auszug aus dem Glossar)

Ein Wort je Begriff, paketübergreifend. Die rechte Spalte nennt, was heute alles dafür steht.

| Begriff | Wort | ersetzt heute |
|---|---|---|
| Überschrift eines Dokuments/Bausteins | `titel` | `title`, `titel`, `exam` |
| zweite Überschrift | `untertitel` | `subtitle`, `subexam` |
| Lerngruppe | `klasse` | `class` |
| Datum | `datum` | `date` |
| Lehrkraft(kürzel) | `lehrkraft` | `teacher` |
| eingetragener Schülername | `name` | `student`, `schueler` |
| Namensfeld | `namensfeld` | `name-field` |
| Inhalt eines Bausteins (Positionsargument) | `inhalt` | `body`, `content`, `text`, `inhalt` |
| Farbe eines Elements | `farbe` | `color`, `accent-color`, `dark-color`, `farbe` |
| Akzentfarbe des ganzen Dokuments | `akzent` | `akzent` |
| Flächenfüllung | `hintergrund` | `fill-color`, `light-color`, `background` |
| Linienstil (Typst-`stroke`) | `linie`, zusammengesetzt `randlinie` | `line-stroke` |
| Breite / Höhe als Länge | `breite`, `hoehe` | `width`, `height`, `hoehe` |
| Anzahl Zeilen / Spalten | `zeilen`, `spalten` | `rows`, `columns`, `width` (in `kariert`), `height` (in `ascii-table`) |
| jeder Zwischenraum | `abstand`, zusammengesetzt `linienabstand`, `eintragsabstand`, `kopfabstand`, `fussabstand` | `gutter`, `spacing`, `line-height`, `lineheight`, `linienabstand`, `items-spacing`, `header-ascent`, `footer-descent` |
| Kästchengröße | `kaestchengroesse` | `grid-size`, `scale` |
| Seitenrand | `rand` | `margin`, `rand` |
| Korrekturrand | `korrekturrand` (Lage), `randbreite` (Länge) | `korrekturrand`, `rand` |
| Nummerierungsmuster | `nummerierung` | `numbering`, `teilaufgabe-numbering` |
| Nummer als Wert | `nummer` | `nummer` |
| "trägt eine Nummer" | `nummeriert` | `number` |
| eigene Kennung einer Teilaufgabe | `kennung` | `item-label` |
| Sprungziel für `@verweise` | `anker` | `label` |
| Bildunterschrift | `beschriftung` | `caption` |
| Lösung (Baustein) / Lösungsausgabe (Option) | `loesung` / `loesungen` | `loesung`, `loesungen`, `lsg`, `solution` |
| Punkte | `punkte` | `punkte`, `points`, `be` |
| Platz zum Schreiben | `arbeitsflaeche` / `arbeitsflaechen` | `workspace`, `workspaces` |
| Druckfassung | `druck` | `print` |
| beidseitiger Druck | `beidseitig` | `duplex` |
| Querformat | `querformat` | `landscape`, `flipped` |
| Papierformat | `papier` | `paper` |
| Schriftart | `schrift`, `formelschrift` | `font`, `math-font`, `schrift.text`, `schrift.mathe` |
| Schriftgröße | `schriftgroesse`, `titelgroesse`, `beschriftungsgroesse` | `font-size`, `title-font-size`, `header-font-size`, `figure-font-size`, `schrift.groesse` |
| Kopf-/Fußzeile | `kopf`, `fuss` | `custom-header`, `header`, `kopf`, `fuss` |
| Gestaltung (Theme) | `gestaltung` | `theme` |
| Ausgabefassung | `variante` / `varianten` | `variante`, `varianten` |
| Ort einer Ausgabe | `ort` | `position`, `punkte-position` |
| Darstellungsvorlage (Funktion) | `vorlage` | `template` |
| Listeneintrag | `eintraege` | `items`, `tasks` |
| Icon | `icon` / `icons` | `icon`, `icons` |
| Sozialform | `sozialform` | `method` |
| Muster des Schreibfelds | `muster` | `muster` |
| Abschnitt zwischen zwei Zurücksetzungen | `block` (nur in `alle-bloecke`, `blocktitel`) | `teile`, `alle` |

`teil` als Parameter gibt es nicht mehr (heute vier Bedeutungen); eine Teilaufgabe heißt in Parametern immer `teilaufgabe`.

---

## 3. Wertekonvention

### 3.1 Welcher Typ wofür

| Situation | Typ | Beispiel |
|---|---|---|
| genau zwei Zustände, an/aus | `bool` | `druck: false`, `gross: true` |
| "das Paket entscheidet / aus dem Zusammenhang" | `auto` | `akzent: auto`, `schrift: auto`, `varianten: auto`, `kopf: auto` |
| "gibt es nicht / nichts anzeigen" bei Parametern, die sonst einen Wert tragen | `none` | `loesungen: none`, `kopf: none`, `logo: none`, `anker: none` |
| drei oder mehr Zustände, oder zwei gleichrangige Arten | String-Enum | `loesungen: "seite"`, `muster: "kariert"`, `korrekturrand: "innen"` |
| Merkmal mit Einstellungen | `false` \| `true` \| Dictionary | `klausurboegen: (muster: "liniert")`, `erwartungen: (erreicht: true)` |
| Kurzform und Langform derselben Option | Enum-Wert \| Dictionary mit Schlüssel `anzeige` | `punkte: "alle"` = `punkte: (anzeige: "alle")` |

### 3.2 Ein einziges "aus"

- Ist `true` ein gültiger Wert, dann heißt aus `false`.
- In allen anderen Fällen heißt aus `none`.
- **Kein String bedeutet "aus".** Lint: Wertelisten dürfen `"keine"`, `"kein"`, `"aus"`, `"nein"`, `"ohne"`, `"false"`, `"none"`, `"standard"` nicht enthalten.
- In Einstellungs-Dictionaries gibt es keinen Schlüssel `show`; wer das Merkmal nicht will, schreibt `false`.
- Kein Wert ist Alias eines anderen (heute: `true` = `"reset"`, `"folgend"` = `"sofort"` bei Material, `none` = `"standard"` bei `theme`).

Damit bleiben zwei Schreibweisen für "aus" (`false` und `none`), aber sie sind vom Typ des Parameters eindeutig bestimmt und nie beide an derselben Stelle gültig.

### 3.3 Enum-Werte

- Deutsch, klein, kebab-case, Umschrift wie R2 (`"aussen"`, `"einzelseiten"`).
- Wortart einheitlich je Enum: Ortsangaben für "wo" (`"direkt"`, `"aufgabe"`, `"ende"`, `"seite"`, `"rand"`), Substantive im Plural für "was" (`"aufgaben"`, `"teilaufgaben"`, `"alle"`).
- Werte benennen, was gezeigt wird, nie, was fehlt (`"keine-summe"` entfällt).
- Abkürzungen als Werte nur aus einer festen Liste amtlicher Kürzel: `"sek-1"`, `"sek-2"`, `"ea"`, `"ga"` (Niveau).
- Ausnahme vom Deutschgebot: Werte, die Typst so versteht (`"a4"`, Nummerierungsmuster). Das Muster für Teilaufgaben wird ein echtes Muster: `"a)"` und `"1.1"` (heute `"1."`, gemeint ist aber "Aufgabe.Teilaufgabe").
- Jede Funktion prüft ihre Enum-Werte selbst; einheitliche Meldung: ``<paket>: `<name>` darf <liste> sein, erhalten: <repr>``.

### 3.4 Einheiten

- Maße sind immer `length` (oder `fraction`, wo ein Anteil gemeint ist), nie nackte Zahlen. `kariert(breite: 5cm)`; die Anzahl Kästchen heißt `spalten`.
- Anzahlen sind `int` und tragen ein Zählwort im Plural (`zeilen`, `spalten`).
- Ein Faktor heißt `faktor`. Der heutige `scale` in klausurboegen wird zur Länge `kaestchengroesse`.
- Gleiche Dinge, gleiche Vorgabe und gleiche Einheit: `abstand` in `teilaufgaben` und `nebeneinander` beide in `em`; `linienabstand` überall `8mm` (heute 1cm in patterns, 8mm in klausurboegen) **[Vorgabe festlegen]**.

### 3.5 Positional und benannt

1. Positional ist nur, was den Baustein ausmacht und immer angegeben wird: höchstens zwei Pflichtangaben plus `inhalt`.
2. `inhalt` ist immer der **letzte** Positionsparameter, damit die Klammer `[...]` hinter dem Aufruf funktioniert: `#teilaufgabe(arbeitsflaeche: kariert(4))[...]`.
3. Alles Optionale ist benannt. Benannte Parameter stehen in der Signatur vor den positionalen.
4. Listen gleichartiger Inhalte sind variadisch: `#nebeneinander[links][rechts]`, `#teilaufgaben(spalten: 2)[...][...]`; ein fertiges Array wird gespreizt (`..liste`). Sink-Name: `..eintraege` bzw. `..inhalte`.
5. Genau ein Weg je Angabe: der Titel einer Aufgabe ist nur noch `titel:` (heute zusätzlich als erstes von zwei Positionsargumenten); die Punkte einer Erwartung stehen nur noch vorn (`#erwartung(2)[...]`, heute beliebige Reihenfolge).
6. Optionen werden als benannte Argumente gesetzt, nie als positional übergebenes Dictionary: `#setze-optionen(loesungen: "direkt")`.
7. Jede Funktion mit Sink lehnt Unbekanntes ab; Positionsüberschüsse sind ein Fehler. Alte Namen werden über die Tabelle aus `technik/compat.typ` mit "`x` heißt jetzt `y`" beantwortet (Typst hat keine Warnungen; die Tabelle ist identisch mit `regeln.json` für den Codemod).

---

## 4. Gemeinsames Options-Schema: Lösungen, Material, Punkte, Arbeitsflächen

Gilt wortgleich für `setze-optionen` (aufgaben), `arbeitsblatt` und `klassenarbeit`. Definiert wird es **einmal** in `aufgaben` (Werte, Vorgaben, Prüfung); die beiden Vorlagen deklarieren dieselben vier Parameter und reichen sie durch. Vorgaben, die eine Vorlage anders haben will, stehen sichtbar in deren Signatur.

```
loesungen:        none | "direkt" | "aufgabe" | "ende" | "seite" | "einzelseiten" | "nur"
materialien:      none | "direkt" | "aufgabe" | "ende" | "seite" | "einzelseiten"
punkte:           none | "aufgaben" | "teilaufgaben" | "alle"
                  | (anzeige: <wie links>, ort: "ende" | "rand", summe: true, vorlage: auto)
arbeitsflaechen:  true | false
```

### 4.1 `loesungen` und `materialien`: eine Ortsangabe

Der Wert beantwortet "Wo stehen sie?".

| Wert | Bedeutung | heute |
|---|---|---|
| `none` | werden nicht ausgegeben | `"keine"`, `"false"`, `false`, `none` |
| `"direkt"` | unmittelbar hinter der Stelle, an der sie notiert sind | `"sofort"` **[prüfen]** |
| `"aufgabe"` | gesammelt am Ende jeder Aufgabe | `"folgend"` **[prüfen]**; bei Material heute gleichbedeutend mit `"sofort"`, künftig echt unterschieden oder mit klarer Meldung abgelehnt |
| `"ende"` | am Ende des Dokuments, ohne Seitenumbruch | `"reinquetschen"` |
| `"seite"` | am Ende des Dokuments, ab einer neuen Seite | `"seite"` |
| `"einzelseiten"` | am Ende, je Aufgabe eine eigene Seite | `"seiten"` |
| `"nur"` | (nur `loesungen`) Lösungsblatt: Aufgabentext entfällt | `"nur"` |

### 4.2 `punkte`

| Schlüssel | Werte | Vorgabe | heute |
|---|---|---|---|
| Kurzform / `anzeige` | `none`, `"aufgaben"`, `"teilaufgaben"`, `"alle"` | `none` | `punkte` als String bzw. `punkte.anzeige`; `"keine"` |
| `ort` | `"ende"`, `"rand"` | `"ende"` | `punkte-position`, `punkte.position` |
| `summe` | `true`, `false` | `true` | `"keine-summe"` = `(anzeige: "alle", summe: false)` **[prüfen]** |
| `vorlage` | `auto`, Funktion `punkte => inhalt`, oder `(aufgabe: fn, teilaufgabe: fn)` | `auto` | `punkte-template` (klassenarbeit), `punkte-template-aufgabe`, `punkte-template-teilaufgabe` (aufgaben) |

Unbekannte Schlüssel im Dictionary sind ein Fehler.

### 4.3 `arbeitsflaechen`

Reiner Schalter. Der Baustein heißt `arbeitsflaeche` (Funktion und Parameter von `aufgabe`/`teilaufgabe`), die Option im Plural `arbeitsflaechen`.

### 4.4 Vorgaben (eine Quelle)

| Option | aufgaben / arbeitsblatt | klassenarbeit |
|---|---|---|
| `loesungen` | `none` | `none` |
| `materialien` | `"einzelseiten"` (wie heute `"seiten"`) | `"einzelseiten"` |
| `punkte` | `none` | `"aufgaben"` |
| `arbeitsflaechen` | `true` | `true` |

Heute widersprechen sich die Vorgaben (`loesungen`: `"false"` gegen `"keine"`; `punkte`: `"keine"` gegen `"aufgaben"`; `workspaces`: `true` gegen Rückfallwert `false`).

### 4.5 Merkmale mit Einstellungen in `klassenarbeit`

```
erwartungen:    true | false | (gruppiert: false, erreicht: false, alle-bloecke: false, blocktitel: ())
klausurboegen:  false | true | (ergebnisse: (), <jeder Parameter von klausurboegen()>)
```

Kein `show`, kein `new-page` (wird heute stillschweigend verworfen), kein englischer Zweitweg `students`/`result`.

---

## 5. Neue Signaturen

Alle Vorgaben wie heute, sofern nicht in Abschnitt 4 vereinheitlicht.

### 5.1 `arbeitsblatt`

```typ
#let arbeitsblatt(
  // Kopf
  titel: "",
  klasse: "",
  kopf: auto,                    // auto = Kopf der Gestaltung, none = ohne, sonst eigener Inhalt
  kopfabstand: auto,
  quelle: none,                  // URL, erscheint als QR-Code im Kopf
  // Seite
  papier: "a4",
  querformat: false,
  druck: false,
  beidseitig: true,
  zweifach: false,
  seite: (:),                    // durchgereicht an `set page`
  // Gestaltung
  gestaltung: none,              // none | "klar" | "atlas" | "skizze" | "labor" | "kontur" | "leiste" | "riso" | "bauhaus" | Funktion | Dictionary
  akzent: auto,
  schrift: auto,
  formelschrift: auto,
  schriftgroesse: auto,
  titelgroesse: auto,
  beschriftungsgroesse: auto,
  // Aufgaben (Schema aus Abschnitt 4)
  loesungen: none,
  materialien: "einzelseiten",
  punkte: none,
  arbeitsflaechen: true,
  teilaufgaben-nummerierung: "a)",    // "a)" | "1.1"
  kurzschreibweise: "teilaufgaben",   // none | "aufgaben" | "teilaufgaben" | "alle"
  // Ausgabe
  varianten: auto,               // auto | Name | Liste | (name: (…Optionen…))
  vorschau-alle: true,
  dateiname: none,
  // Metadaten
  fach: none,
  thema: none,
  jahrgaenge: (),
  stufe: none,                   // "sek-1" | "sek-2"
  niveau: none,                  // "einfuehrung" | "vertiefung" | "ea" | "ga"
  art: none,                     // "arbeitsblatt" | "uebung" | "stationsarbeit" | "klausur"
  stichworte: (),
  kerncurriculum: (),
  stand: none,
  inhalt,
) = { .. }
```

Die Parameterliste wird einmal gepflegt (Dictionary `_vorgaben`), nicht dreifach. Vordefinierte Varianten: `"druck"`, `"digital"`, `"loesung"`, `"zweifach"`; ein unbekannter Variantenname ohne Dictionary ist ein Fehler (heute entsteht bei `"lösung"` still eine Variante ohne Lösungen). Schlüssel im Varianten-Dictionary: die Optionen von `arbeitsblatt` plus `datei`.

`arbeitsblatt-einzeln` wird `intern.einzeln(bereich: none, ..optionen, inhalt)`.

### 5.2 `klassenarbeit`

```typ
#let klassenarbeit(
  titel: "",
  untertitel: "",
  klasse: "",
  datum: "",
  lehrkraft: "",
  logo: "angela",                // Name aus der Logo-Sammlung | Inhalt | none
  name: none,
  namensfeld: "Name",            // none = ohne Namensfeld
  namensfeld-je-seite: false,
  infotabelle: none,             // none | Liste aus (Bezeichnung, Wert)-Paaren
  seitenzahlen: "einzeln",       // none | "einzeln" | "durchgehend"
  klausurboegen: false,          // false | true | Dictionary
  erwartungen: true,             // true | false | Dictionary
  punkte: "aufgaben",
  varianten: auto,               // auto | Name | Liste aus "druck", "loesung", "klausurboegen"
  vorschau-variante: auto,
  dateiname: none,
  ..weitere,                     // übrige Optionen von arbeitsblatt (deutsch); geprüft mit Präfix "klassenarbeit:"
  inhalt,
) = { .. }
```

`titel` und `klasse` sind jetzt deklariert. `druck`, `kopf` und `kopfabstand` setzt die Klassenarbeit fest; wer sie angibt, bekommt einen Fehler statt einer stillen Überschreibung.

### 5.3 `aufgabe`, `teilaufgabe`, `teilaufgaben`

```typ
#let aufgabe(
  titel: none,
  sozialform: none,              // none | "einzel" | "partner" | "gruppe"
  icons: (),
  gross: true,
  nummeriert: true,
  arbeitsflaeche: none,
  anker: none,
  inhalt,
) = { .. }

#let teilaufgabe(
  kennung: none,
  arbeitsflaeche: none,
  anker: none,
  inhalt,
) = { .. }

#let teilaufgaben(
  spalten: auto,
  nummerierung: "a)",
  abstand: 1.25em,
  loesungen: (),
  ..eintraege,                   // positional: die Teilaufgaben; benannt: durchgereicht an `table`
) = { .. }
```

Der Alias `tasks` entfällt. Die Doppelimplementierung in `mathematik` entfällt (dort Pin auf aufgaben 0.1.2).

### 5.4 `loesung`, `erwartung`, `material`

```typ
#let loesung(inhalt) = { .. }

#let erwartung(..punkte, inhalt) = { .. }
// #erwartung[Text]      0 Punkte
// #erwartung(2)[Text]   2 Punkte
// `..punkte` nimmt höchstens eine Zahl; benannte Argumente und alles andere sind ein Fehler.

#let material(
  beschriftung: none,
  anker: none,
  inhalt,
) = { .. }
```

### 5.5 Die `zeige-`/`setze-`/`lies-`-Familie (aufgaben)

```typ
#let setze-optionen(..optionen) = { .. }          // nur benannt; Schlüssel und Werte geprüft (Abschnitt 4)
#let setze-aufgaben-zurueck() = { .. }

#let zeige-loesungen(
  nur-aktuelle: false,
  teilaufgabe: none,             // none | Nummer
  kasten: true,
) = { .. }
#let zeige-offene-loesungen() = { .. }
#let zeige-materialien(nur-aktuelle: false) = { .. }
#let zeige-erwartungen(
  gruppiert: false,
  neue-seite: false,
  erreicht: false,
  alle-bloecke: false,
  blocktitel: (),
) = { .. }
#let zeige-bewertung(
  moegliche-punkte: "werte",     // "werte" | "leer" | none (Zeile entfällt)
  kompakt: false,
  summenspalte: false,
) = { .. }

#let lies-punkte(
  aufgabe: auto,                 // auto = aktuelle Aufgabe | Nummer
  teilaufgabe: none,             // none = Summe der Aufgabe | Nummer
) = { .. }
#let ist-loesungsfassung() = { .. }
```

Nicht mehr öffentlich (nach `intern`): `show-loesung`, `show-loesung-inline`, `show-material`, `get-punkte-anzeige`, `get-punkte-position`, `format-punkte`, `print-state`, alle `_state_*`, `_counter_aufgaben`, `c_canvas`.

### 5.6 `klausurboegen`

```typ
#let klausurboegen(
  titel: "",
  untertitel: "",
  klasse: "",
  datum: "",
  lehrkraft: "",
  ergebnisse: (),                // CSV-Zeilen: Kopfzeile, Höchstpunkte, je Schüler eine Zeile
  nur-ergebnis: false,           // Ergebnisdruck zum Überdrucken
  stufe: "sek-2",                // "sek-1" (Noten 1–6) | "sek-2" (0–15 Punkte)
  muster: "kariert",             // "kariert" | "liniert"
  kaestchengroesse: 5mm,
  linienabstand: 8mm,
  korrekturrand: "aussen",       // "innen" | "aussen"
  randbreite: 5cm,
  rand-kariert: false,
  randlinie: 1pt + rgb("FF0613"),
  teilaufgaben-nummerierung: "a)",
  ergebnisfeld: true,
  punktetabelle: true,
  vorschlag: none,               // none | Bezeichnung
  versatz: (dx: 0cm, dy: 0cm),   // durchgereicht an `move`
  vordruck: none,                // aus 0.0.4: none | "werte"
  namen: false,                  // aus 0.0.4
) = { .. }
```

Paket, Funktion, Parameter in `klassenarbeit` und Variantenwert heißen jetzt gleich. Die Vorgaben `"SLZ"`, `"PH1"`, `"09.10.2023"` entfallen. Aus 0.0.4 werden `bogen-seiten` → `bogenseiten(…, aufgaben: none, tabelle: false, rueckseite: auto, seitenrand: 12mm, unten: 16mm, abstand: 4mm)` und `klausurbogen-arbeit(..weitere, inhalt)` übernommen (`rand` dort ist ein Seitenrand und darf nicht wie der Korrekturrand heißen).

### 5.7 `kariert`, `liniert`, Füllfelder (patterns)

```typ
#let kariert(
  zeilen: 1,                     // Anzahl | Anteil (1fr)
  spalten: auto,                 // Anzahl Kästchen
  breite: auto,                  // Länge
  hoehe: none,                   // Länge; hat Vorrang vor `zeilen`
  kaestchengroesse: 5mm,
  eintraege: (),
  eintragsabstand: 2,            // in Kästchen
  zeichnung: (),                 // CeTZ-Befehle über dem Raster
  linie: (paint: rgb("#AAAAAA").lighten(10%), thickness: 0.5pt),
  hintergrund: white,
  beschriftung: none,
  ..kurz,                        // nur positional: zeilen, dann spalten
) = { .. }

#let liniert(
  zeilen: 1,
  breite: auto,
  hoehe: none,
  linienabstand: 8mm,
  eintraege: (),
  eintragsabstand: 1,            // in Zeilen
  linie: (paint: black.lighten(50%), thickness: 0.5pt),
  ..kurz,                        // nur positional: zeilen, dann breite
) = { .. }

#let fuellfeld(anteil, zeichne) = { .. }      // heute flex-feld(hoehe, zeichne)
#let ist-fuellfeld(inhalt) = { .. }           // heute ist-flex-feld
```

Unbekannte benannte Argumente sind ein Fehler (heute werden sie verschluckt, so ging `lineheight:` beim Wechsel 0.0.1 → 0.0.2 still verloren).

### 5.8 `luecke`, `lsg`

```typ
#let luecke(eng: false, inhalt) = { .. }
#let lsg(platz: true, sonst: none, inhalt) = { .. }
```

`lsg` bleibt als eines der fünf Kurzwörter (127 Aufrufe im Fließtext).

### 5.9 `arbeitsflaeche`, `nebeneinander`

```typ
#let arbeitsflaeche(inhalt) = { .. }          // heute workspace(height:, body); `height` war wirkungslos

#let nebeneinander(
  breiten: auto,                 // auto | Anzahl | Liste von Breiten
  ausrichtung: horizon,
  abstand: 1.25em,
  ..inhalte,                     // positional: Spalteninhalte; benannt: durchgereicht an `table`
) = { .. }
```

### 5.10 Seitenumbruch

```typ
#let seitenumbruch(
  druck: auto,                   // auto = in jeder Fassung | true = nur Druck | false = nur digital
  loesung: auto,                 // auto = egal | true = nur im Lösungsblatt | false = nie im Lösungsblatt
) = { .. }
```

Ersetzt `print-pagebreak` (= `seitenumbruch(druck: true)`) und `non-print-pagebreak` (= `seitenumbruch(druck: false)`); `loesungen-only: true` wird `loesung: true`.

### 5.11 QR-Code und Weblink

```typ
#let qr-code(
  farbe: black,
  hintergrund: none,
  url,
  ..weitere,                     // benannt: durchgereicht an zebra (`width`, `quiet-zone`, …)
) = { .. }

#let qr-kasten(
  breite: 3cm,
  url,
  text,
  ..weitere,                     // benannt: durchgereicht an `stickybox` (z. B. `rotation`)
) = { .. }

#let weblink(
  icon: emoji.chain,
  farbe: blue,
  url,
  text,
) = { .. }
```

Anmerkung zu R5: `text` als Positionsname ist für Aufrufer unsichtbar; in der Umsetzung heißt er `linktext`, damit `text` nicht überdeckt wird.

### 5.12 Kästen

Der Funktionsname ist der deutsche Standardtitel. Gemeinsame Signatur:

```typ
#let merke(
  titel: auto,                   // auto = Standardtitel, none = ohne Kopf
  farbe: auto,
  umbrechbar: false,
  breite: auto,
  inhalt,
) = { .. }
```

| heute | neu | heute | neu | heute | neu |
|---|---|---|---|---|---|
| `abstract` | `einfuehrung` | `info` | `info` | `question` | `frage` |
| `memo` | `merke` | `conclusion` | `zusammenfassung` | `tip` | `tipp` |
| `success` | `erledigt` | `warning` | `achtung` | `error` | `fehler` |
| `example` | `beispiel` | `goal` | `ziel` | `idea` | `idee` |
| `experiment` | `experiment` | `notify` | `mitteilung` | `danger` | `gefahr` |

`task`/`code` aus gentle-clues werden nicht mehr durchgereicht. Dieselben Wörter sind die Werte von `art` im Kasten-Hook.

### 5.13 Gestaltungs-Dictionary (Theme) und Hook-Signaturen

```
name            Zeichenkette
schrift         (text:, formel:, groesse:, titel:, beschriftung:)
rand            (oben:, unten:, innen:, aussen:, kopf-oben:)
kopfabstand     Länge
fussabstand     Länge | Anteil
kopf            (titel:, klasse:, quelle:, schriftgroesse:) => inhalt
fuss            (beidseitig:) => inhalt
hintergrund     (druck:, oben:, rand:) => inhalt        `rand` ist das Typst-Randdictionary (durchgereicht)
marke           (nummer) => inhalt
marke-breite    Länge
aufgabe         (nummer:, titel:, icons:, punkte:, gross:, nummeriert:) => inhalt
teilaufgabe     (kennung) => inhalt
loesung         (titel, inhalt) => inhalt
loesung-kopf    (titel) => inhalt
material-kopf   (titel) => inhalt
kasten          (art:, titel:, farbe:, umbrechbar:, breite:, inhalt) => inhalt
einrichtung     inhalt => inhalt                        weitere Show-Regeln
```

Öffentliches Dictionary `gestaltungen` (heute `themes`); Helfer `fachfarbe(klasse)`, `kuerzel(klasse)`. Unbekannte Schlüssel in einer Gestaltung sind ein Fehler.

---

## 6. Tabelle alt → neu

"ändert sich?" bezieht sich auf das, was im Dokument getippt wird (Name oder Werte). Zahlen in Klammern: Vorkommen in Dokumenten außerhalb des Repos, soweit gezählt.

### 6.1 `arbeitsblatt` / `arbeitsblatt-einzeln`

| alt | neu | ändert sich? | Anmerkung |
|---|---|---|---|
| `title` (1186) | `titel` | ja | |
| `class` (1187) | `klasse` | ja | |
| `paper` (1128) | `papier` | ja | Werte bleiben (`"a4"`) |
| `print` (714) | `druck` | ja | |
| `duplex` (33) | `beidseitig` | ja | |
| `workspaces` (682) | `arbeitsflaechen` | ja | |
| `theme` (37) | `gestaltung` | ja | Wert `"standard"` entfällt, dafür `none` |
| `akzent` | `akzent` | nein | |
| `font-size` (1133) | `schriftgroesse` | ja | |
| `font` (27) | `schrift` | ja | |
| `math-font` | `formelschrift` | ja | |
| `title-font-size` (19), älter `header-font-size` (1063) | `titelgroesse` | ja | |
| `figure-font-size` (2) | `beschriftungsgroesse` | ja | Vorgabe `auto`, neuer Theme-Schlüssel `schrift.beschriftung` |
| `landscape` (152) | `querformat` | ja | |
| `custom-header` (130) | `kopf` | ja | zusätzlich `auto` = Standardkopf |
| `header-ascent` (im Sink) | `kopfabstand` | ja | jetzt deklariert |
| `teilaufgabe-numbering` (6) | `teilaufgaben-nummerierung` | ja | Wert `"1."` → `"1.1"` |
| `page-settings` (164) | `seite` | ja | Schlüssel darin bleiben englisch (Typst) |
| `loesungen` (390) | `loesungen` | Name nein, Werte ja | siehe 6.8 |
| `materialien` (3) | `materialien` | Name nein, Werte ja | siehe 6.8 |
| `punkte` (13) | `punkte` | Name nein, Werte teils | siehe 6.8 |
| `aufgaben-shortcodes` (253) | `kurzschreibweise` | ja | `"keine"` → `none` |
| `copyright` | `quelle` | ja | |
| `zweifach` (2) | `zweifach` | nein | |
| `scope` (nur `-einzeln`) | `bereich` (in `intern.einzeln`) | ja (nur intern) | |
| `varianten` (113) | `varianten` | nein | Namen `"druck"`, `"digital"`, `"loesung"`, `"zweifach"` bleiben; Schlüssel in Override-Dictionaries folgen dieser Tabelle |
| `vorschau-alle` | `vorschau-alle` | nein | |
| `dateiname` (60) | `dateiname` | nein | |
| `fach`, `thema`, `stufe`, `niveau`, `stichworte`, `kerncurriculum`, `stand` | unverändert | nein | |
| `jahrgang` (1) | `jahrgaenge` | ja | Liste → Plural |
| `typ` (1) | `art` | ja | `typ` liest sich wie "Typst"/Datentyp; `art` ist schon das Wort im Kasten-Hook |
| `..args` | entfällt | – | alles ist deklariert |
| `body` | `inhalt` | nein (positional) | |

### 6.2 `klassenarbeit`

| alt | neu | ändert sich? | Anmerkung |
|---|---|---|---|
| `title` (108, aus `..args`) | `titel` | ja | jetzt deklariert |
| `subtitle` (106) | `untertitel` | ja | |
| `class` (108, aus `..args`) | `klasse` | ja | jetzt deklariert |
| `date` (107) | `datum` | ja | |
| `teacher` (107) | `lehrkraft` | ja | |
| `logo` (83) | `logo` | nein | |
| `student` | `name` | ja | |
| `name-field` (2) | `namensfeld` | ja | |
| `name-repeat` (4) | `namensfeld-je-seite` | ja | |
| `info-table` (29), älter `table` (68) | `infotabelle` | ja | `false` → `none` |
| `page-numbering` | `seitenzahlen` | ja | `false`→`none`, `true`/`"reset"`→`"einzeln"`, `"continuous"`→`"durchgehend"` |
| `klausurboegen` (91) | `klausurboegen` | Name nein, Schlüssel ja | älter `klausurboegen-settings` (38), `ergebnisse` (20), `bogen` (7) gehen im Dictionary auf |
| `klausurboegen.show` | entfällt | ja | `false` schreiben |
| `klausurboegen.ergebnisse` | `ergebnisse` | nein | einziger Weg; `students`/`result` nicht mehr annehmbar |
| `erwartungen` (96) | `erwartungen` | Name nein, Schlüssel teils | |
| `erwartungen.show` | entfällt | ja | |
| `erwartungen.new-page` | entfällt | ja | war wirkungslos |
| `erwartungen.grouped` | `gruppiert` | ja | |
| `erwartungen.erreicht` | `erreicht` | nein | |
| `erwartungen.alle` | `alle-bloecke` | ja | |
| `erwartungen.teile` | `blocktitel` | ja | |
| `punkte-template` (18) | `punkte: (vorlage: …)` | ja | |
| `varianten` (1) | `varianten` | nein | |
| `variante` | `vorschau-variante` | ja | nicht mehr einen Buchstaben neben `varianten` |
| `dateiname` (17) | `dateiname` | nein | |
| `..args` | `..weitere` | – | Namen darin wie 6.1 |
| `body` | `inhalt` | nein | |

### 6.3 `aufgabe`, `teilaufgabe`, `teilaufgaben`

| Funktion | alt | neu | ändert sich? | Anmerkung |
|---|---|---|---|---|
| `aufgabe` | `title` (1623; ältere Fassungen `titel` 342) | `titel` | ja (1623), nein (342) | |
| | Titel als 1. Positionsargument | `titel:` | ja | nur noch benannt |
| | `method` (4) | `sozialform` | ja | `"EA"`→`"einzel"`, `"PA"`→`"partner"`, `"GA"`→`"gruppe"`, `""`→`none` |
| | `icons` (älter `icon` 20) | `icons` | nein | |
| | `large` (1933) | `gross` | ja | |
| | `number` (1710) | `nummeriert` | ja | |
| | `workspace` (1106) | `arbeitsflaeche` | ja | |
| | `label` (6) | `anker` | ja | |
| | `..args` (Rumpf) | `inhalt` | nein | |
| `teilaufgabe` | `item-label` (30) | `kennung` | ja | |
| | `label` (4) | `anker` | ja | |
| | `workspace` (2435) | `arbeitsflaeche` | ja | `false` nicht mehr erlaubt, nur `none` |
| | `body` | `inhalt` | nein | |
| `teilaufgaben` | `tasks` (56) | `..eintraege` (positional) | ja | `tasks: (a, b)` → `..(a, b)` oder `[a][b]` |
| | Listen-Rumpf im Sink | entfällt | ja | ein Weg |
| | `columns` (36) | `spalten` | ja | |
| | `numbering` | `nummerierung` | ja | |
| | `gutter` (14) | `abstand` | ja | |
| | `loesungen` (35) | `loesungen` | nein | Grenzfall, siehe 8.9 |
| | `..args` benannt (`inset` 12, `align` 4, `row-gutter` 2) | `..eintraege` benannt | nein | durchgereicht an `table`, bleibt englisch |
| Alias `tasks` | – | entfällt | ja | |

### 6.4 `loesung`, `erwartung`, `material`, Familie `show-`/`set-`/`get-`

| alt | neu | ändert sich? |
|---|---|---|
| `loesung(body)` | `loesung(inhalt)` | nein |
| `erwartung(..args)` | `erwartung(..punkte, inhalt)` | nein für `#erwartung(2)[…]`; ja, wenn die Punkte hinten stehen |
| `material(body, caption:, label:)` | `material(beschriftung:, anker:, inhalt)` | ja (`caption` 7, `label` 7) |
| `set-options(options)` | `setze-optionen(..optionen)` | ja (Name und Form) |
| `reset-aufgaben()` | `setze-aufgaben-zurueck()` | ja |
| `show-loesungen(curr:, teil:, inline:)` | `zeige-loesungen(nur-aktuelle:, teilaufgabe:, kasten:)` | ja; `inline: true` → `kasten: false`, `teil: false` → `teilaufgabe: none` |
| `show-offene-loesungen()` | `zeige-offene-loesungen()` | ja |
| `show-materialien(curr:)` | `zeige-materialien(nur-aktuelle:)` | ja |
| `show-erwartungen(grouped:, new-page:, erreicht:, alle:, teile:)` | `zeige-erwartungen(gruppiert:, neue-seite:, erreicht:, alle-bloecke:, blocktitel:)` | ja, außer `erreicht` |
| `show-bewertung(<pos>, compact:, full:)` | `zeige-bewertung(moegliche-punkte:, kompakt:, summenspalte:)` | ja; `true`→`"werte"`, `false`→`"leer"`, `none`→`none` |
| `get-points(aufg, teil:, idx:)` | `lies-punkte(aufgabe:, teilaufgabe:)` | ja; `idx` entfällt |
| `loesungsmodus()` | `ist-loesungsfassung()` | ja |
| `show-loesung(aufg, teil:)`, `show-loesung-inline(aufg)`, `show-material(aufg, start:)` | `intern.*` | ja (nicht mehr öffentlich) |
| `get-punkte-anzeige(opts)`, `get-punkte-position(opts)`, `format-punkte(teil:, points)` | `intern.*` | ja (nicht mehr öffentlich) |
| `print-state` | `intern.*` | ja |

Schlüssel in `setze-optionen`: `loesungen`, `materialien`, `punkte` (nein) · `workspaces` → `arbeitsflaechen` · `teilaufgabe-numbering` → `teilaufgaben-nummerierung` · `punkte-position` → `punkte.ort` · `punkte-template-aufgabe` / `-teilaufgabe` → `punkte.vorlage.aufgabe` / `.teilaufgabe` · `print` → `druck`.

### 6.5 `klausurbögen` → `klausurboegen`

| alt | neu | ändert sich? | Anmerkung |
|---|---|---|---|
| Funktion `klausurbögen` | `klausurboegen` | ja | |
| `exam` | `titel` | ja | |
| `subexam` | `untertitel` | ja | |
| `teacher` | `lehrkraft` | ja | Vorgabe `""` |
| `class` | `klasse` | ja | Vorgabe `""` |
| `date` | `datum` | ja | Vorgabe `""` |
| `students` | `ergebnisse` | ja | |
| `result` | `nur-ergebnis` | ja | |
| `sek1` | `stufe` | ja | `true` → `"sek-1"`, `false` → `"sek-2"` |
| `rand` | `randbreite` | ja | |
| `scale` | `kaestchengroesse` | ja | Faktor → Länge (`scale * 0.5cm`) |
| `sub` | `ergebnisfeld` | ja | umgekehrt: `sub: true` → `ergebnisfeld: false` |
| `numbering` | `teilaufgaben-nummerierung` | ja | wird aus `klassenarbeit` automatisch übernommen |
| `mv` | `versatz` | ja | Schlüssel `dx`/`dy` bleiben (Typst) |
| `weißer-rand` | `rand-kariert` | ja | umgekehrt |
| `result-table` | `punktetabelle` | ja | |
| `vorschlag` | `vorschlag` | Name nein, Wert ja | `false` → `none` |
| `line-stroke` | `randlinie` | ja | |
| `muster` | `muster` | nein | |
| `linienabstand` | `linienabstand` | nein | |
| `korrekturrand` | `korrekturrand` | nein | Alias `"außen"` entfällt |
| (0.0.4) `vordruck` | `vordruck` | Name nein, Wert ja | `false` → `none` |
| (0.0.4) `namen` | `namen` | nein | |
| (0.0.4) `bogen-seiten(…, rand:, …)` | `bogenseiten(…, seitenrand:, …)` | ja | |

### 6.6 `kariert`, `liniert`, Füllfelder

| Funktion | alt | neu | ändert sich? | Anmerkung |
|---|---|---|---|---|
| `kariert` | `rows` (100) | `zeilen` | ja | positional `kariert(4)` bleibt |
| | `width` (20) | `spalten` | ja | war Kästchenzahl; neu zusätzlich `breite` als Länge |
| | `items` (49) | `eintraege` | ja | |
| | `items-spacing` (37) | `eintragsabstand` | ja | |
| | `grid-size` | `kaestchengroesse` | ja | |
| | `height` (106) | `hoehe` | ja | |
| | `annotations` (16) | `zeichnung` | ja | |
| | `line-stroke` | `linie` | ja | |
| | `fill-color` | `hintergrund` | ja | |
| | `content` | `beschriftung` | ja | |
| | `..args` | `..kurz` | nein | benannte Unbekannte jetzt Fehler |
| `liniert` | `rows` (163) | `zeilen` | ja | |
| | `width` (42) | `breite` | ja | |
| | `items` (4) | `eintraege` | ja | |
| | `items-spacing` (4) | `eintragsabstand` | ja | |
| | `line-height` (älter `lineheight` 2) | `linienabstand` | ja | |
| | `line-stroke` | `linie` | ja | |
| | – | `hoehe` | neu | Gleichstand mit `kariert` |
| `flex-feld(hoehe, zeichne)` | `fuellfeld(anteil, zeichne)` | | ja | |
| `ist-flex-feld(inhalt)` | `ist-fuellfeld(inhalt)` | | ja | |

### 6.7 Übrige Kernfunktionen von arbeitsblatt

| alt | neu | ändert sich? | Anmerkung |
|---|---|---|---|
| `lücke(body, tight:)` (111) | `luecke(eng:, inhalt)` | ja | ältere Namen `luecke` (32), `lueck` (58) fallen zusammen |
| `lsg(body, platz:, sonst:)` (127) | `lsg(platz:, sonst:, inhalt)` | nein | |
| `workspace(height:, body)` (118) | `arbeitsflaeche(inhalt)` | ja | `height` entfällt |
| `minipage` (1575) | `nebeneinander` | ja | |
| `minipage(columns:)` | `breiten` | ja | |
| `minipage(align:)` | `ausrichtung` | ja | |
| `minipage(spacing:)` | `abstand` | ja | Vorgabe wie `teilaufgaben` |
| `print-pagebreak()` (21) | `seitenumbruch(druck: true)` | ja | |
| `non-print-pagebreak()` (106) | `seitenumbruch(druck: false)` | ja | |
| `loesungen-only` | `loesung` | ja | |
| `qr-code(..args)` | `qr-code(url, ..weitere)` | nein | |
| `qr-code(light-color:)`, `background:` | `hintergrund` | ja | zwei Namen werden einer |
| `qr-code(dark-color:)` | `farbe` | ja | |
| `qr-code(alt:)` | entfällt | ja | war wirkungslos |
| `qrbox` (125) | `qr-kasten` | ja | |
| `qrbox(width:)` (66) | `breite` | ja | |
| `qrbox(rotation:)` (83) | `rotation` (im Sink, an `stickybox`) | nein | durchgereicht |
| `icon-link` (204) | `weblink` | ja | |
| `icon-link(icon:)` | `icon` | nein | |
| `icon-link(color:)` | `farbe` | ja | |
| Kästen `abstract` … `danger` | siehe 5.12 | ja außer `info`, `experiment` | |
| Kasten `title:` (156 bei `info`) | `titel` | ja | |
| Kasten `accent-color:` (17) | `farbe` | ja | |
| Kasten `headless: true` | `titel: none` | ja | |
| Kasten `breakable:` | `umbrechbar` | ja | |
| Kasten `width:` | `breite` | ja | |
| Kasten `icon:` (17) | `icon` | nein | heute mit Theme verworfen; künftig Hook-Argument oder klarer Fehler |
| `themes` | `gestaltungen` | ja | |
| `tasks`, `c_canvas`, `mono` (Dublette zu informatik) | entfallen | ja | |
| `canvas`, `qty`, `num`, `unit` | unverändert | nein | Fremdfunktionen |

### 6.8 Enum-Werte

| Option | alt | neu | ändert sich? |
|---|---|---|---|
| `loesungen` | `"keine"`, `"false"`, `false`, `none` | `none` | ja außer `none` |
| | `"sofort"` | `"direkt"` | ja |
| | `"folgend"` | `"aufgabe"` | ja |
| | `"reinquetschen"` | `"ende"` | ja |
| | `"seite"` | `"seite"` | nein |
| | `"seiten"` | `"einzelseiten"` | ja |
| | `"nur"` | `"nur"` | nein |
| `materialien` | wie oben ohne `"nur"` | wie oben | wie oben |
| `punkte` | `"keine"` | `none` | ja |
| | `"aufgaben"`, `"teilaufgaben"`, `"alle"` | unverändert | nein |
| | `"keine-summe"` | `(anzeige: "alle", summe: false)` | ja |
| | `(anzeige:, position:)` | `(anzeige:, ort:)` | ja (`position`) |
| `aufgaben-shortcodes` → `kurzschreibweise` | `"keine"` | `none` | ja |
| | `"aufgaben"`, `"teilaufgaben"`, `"alle"` | unverändert | nein |
| `teilaufgabe-numbering` | `"a)"` / `"1."` | `"a)"` / `"1.1"` | nein / ja |
| `theme` → `gestaltung` | `none`, `"standard"` | `none` | ja für `"standard"` |
| | `"klar"` … `"bauhaus"` | unverändert | nein |
| `page-numbering` → `seitenzahlen` | `true`, `"reset"` / `"continuous"` / `false` | `"einzeln"` / `"durchgehend"` / `none` | ja |
| Varianten | `"druck"`, `"digital"`, `"loesung"`, `"zweifach"`, `"klausurboegen"` | unverändert | nein |
| `korrekturrand` | `"innen"`, `"aussen"`, `"außen"` | `"innen"`, `"aussen"` | nein (Alias entfällt) |
| `muster` | `"kariert"`, `"liniert"` | unverändert | nein |
| `stufe`, `niveau` | `"sek-1"`, `"sek-2"`, `"einfuehrung"`, `"vertiefung"`, `"ea"`, `"ga"` | unverändert | nein |

### 6.9 Gestaltungs-Dictionary

| alt | neu | ändert sich? |
|---|---|---|
| `schrift.text`, `schrift.groesse`, `schrift.titel` | unverändert | nein |
| `schrift.mathe` | `schrift.formel` | ja |
| – | `schrift.beschriftung` | neu |
| `rand.top` / `rand.bottom` | `rand.oben` / `rand.unten` | ja |
| `rand.innen`, `rand.aussen`, `rand.kopf-oben` | unverändert | nein |
| `header-ascent` | `kopfabstand` | ja |
| `footer-descent` | `fussabstand` | ja |
| `kopf(title:, class:, copyright:, font-size:)` | `kopf(titel:, klasse:, quelle:, schriftgroesse:)` | ja |
| `fuss(duplex:)` | `fuss(beidseitig:)` | ja |
| `hintergrund(print:, oben:, rand:)` | `hintergrund(druck:, oben:, rand:)` | ja (`print`) |
| `marke`, `marke-breite`, `loesung-kopf`, `material-kopf` | unverändert | nein |
| `aufgabe(nummer:, titel:, icons:, punkte:, large:, number:)` | `aufgabe(nummer:, titel:, icons:, punkte:, gross:, nummeriert:)` | ja (`large`, `number`) |
| `teilaufgabe(lbl)` | `teilaufgabe(kennung)` | nein (positional) |
| `loesung(titel, body)` | `loesung(titel, inhalt)` | nein (positional) |
| `kasten(art:, titel:, farbe:, breakable:, width:, body)` | `kasten(art:, titel:, farbe:, umbrechbar:, breite:, inhalt)` | ja (`breakable`, `width`) |
| `kasten.art`-Werte `"info"`, `"memo"`, `"tip"`, … | `"info"`, `"merke"`, `"tipp"`, … | ja |
| `setup` | `einrichtung` | ja |
| `name` | `name` | nein |

---

## 7. Umstellungsaufwand

Wichtig vorab: Dokumente pinnen ihre Version, alte Versionsordner bleiben liegen. **Kein Bestandsdokument bricht.** Die Zahlen unten beschreiben, was anfällt, *wenn* ein Dokument auf 0.4.1 gehoben wird. Basis: 1457 lokal gelesene Dokumente (weitere rund 4600 Cloud-Platzhalter wurden nicht gelesen und sind vermutlich großteils dieselben Dateien).

### 7.1 Dokumentköpfe

| | Köpfe | gezählte Parameter-Vorkommen | davon mit neuem Namen | Anteil |
|---|---|---|---|---|
| `arbeitsblatt.with(…)` | 1204 | 8490 | 7914 | **93 %** |
| `klassenarbeit.with(…)` | 109 | 1463 | rund 930 | **64 %** |
| zusammen | 1313 | 9953 | rund 8840 | **89 %** |

- Unverändert im arbeitsblatt-Kopf bleiben nur `loesungen` (390), `varianten` (113), `dateiname` (60), `punkte` (13). Bei `loesungen` ändert sich in den meisten Fällen aber der Wert (`"false"`, `"keine"`, `"sofort"`, `"seiten"`, `"folgend"`), sodass praktisch 97–98 % der Kopfparameter angefasst werden.
- Im klassenarbeit-Kopf bleiben `erwartungen` (96), `loesungen` (93), `klausurboegen` (91), `logo` (83), `stufe` (80), `punkte` (39), `ergebnisse` (20), `dateiname` (17) dem Namen nach stehen.
- **Jeder Kopf ist betroffen** (`class`/`title` stehen in 98,6 % der arbeitsblatt-Köpfe und in 99 % der klassenarbeit-Köpfe).
- Ein großer Teil davon fiele bei *jeder* Anhebung an: `header-font-size` (1075 Vorkommen) gibt es schon in 0.4.0 nicht mehr.

### 7.2 `aufgabe` und `teilaufgabe`

| Funktion | Aufrufe | benannte Parameter gesamt | mit neuem Namen | Anteil |
|---|---|---|---|---|
| `#aufgabe(` | 2340 | 6751 | rund 6400 (`large` 1933, `number` 1710, `title` 1623, `workspace` 1106, Rest 30) | **95 %** |
| `#aufgabe[` (ohne Klammer) | 273 | 0 | 0, außer bei der Form `[Titel][Rumpf]` | – |
| `#teilaufgabe(` | 2480 | 2480 | 2475 (`workspace` 2435, `item-label` 30, `label` 4, …) | **99,8 %** |

Von den rund 4820 Aufrufen mit Klammer brauchen damit mindestens **96 %** wenigstens eine Änderung (bei `teilaufgabe` 98 %, weil `workspace` in 2435 von 2480 Aufrufen steht; bei `aufgabe` mindestens 83 % allein durch `large`, mit `number`/`title` realistisch über 95 %). Unverändert bleiben im Wesentlichen die 342 Aufrufe aus alten Fassungen, die schon `titel:` schreiben.

### 7.3 Übrige Bausteine

| Baustein | Aufrufe | betroffen |
|---|---|---|
| `minipage` → `nebeneinander` | 1575 | 100 % (Funktionsname) |
| `erwartung` | 823 | praktisch 0 % |
| `liniert` / `kariert` | 259 / 234 | alle Aufrufe mit benanntem Parameter (zusammen rund 550 Parameter); `kariert(4)` bleibt |
| `icon-link` → `weblink` | 204 | 100 % |
| `info` und andere Kästen | 156+ | `info` bleibt, `title:` (156) ändert sich |
| `lsg` | 127 | 0 % |
| `qrbox` → `qr-kasten` | 125 | 100 % |
| `workspace` → `arbeitsflaeche` | 118 | 100 % |
| `lücke` → `luecke` | 111 | 100 % |
| `non-print-pagebreak` / `print-pagebreak` | 106 / 21 | 100 % |
| `loesung` | 85 | 0 % |
| `teilaufgaben` | 56 | 100 % (`tasks`) |

### 7.4 Gesamtbild

- Würden alle rund 1300 Dokumente gehoben: rund **20 000 Änderungsstellen** (etwa 8800 Kopfparameter, 8900 Parameter in `aufgabe`/`teilaufgabe`, 1575 `minipage`, rund 1700 sonstige).
- Davon sind über 95 % reine Wort-für-Wort-Ersetzungen innerhalb eines bekannten Aufrufs und damit Sache des vorhandenen Codemods (`technik/codemod.py` mit `regeln.json`; die Tabellen aus Abschnitt 6 sind genau dessen Regelsatz).
- Nicht rein mechanisch und einzeln zu prüfen: Wertabbildung bei `loesungen`/`materialien`/`punkte` (kontextabhängig, aber tabellierbar); `aufgabe[Titel][Rumpf]`; umgekehrte Schalter (`inline`, `sub`, `weißer-rand`); `scale` → Länge; `teilaufgaben(tasks: …)`; `klausurboegen`-Dictionaries aus alten `klausurboegen-settings`/`ergebnisse`; `seite: (…)` mit selbst gebauten Rändern; Dokumente, die private Namen (`_state_…`) oder Namen aus den Wildcard-Re-Exporten benutzen.
- Realistisch wird nur gehoben, was ohnehin wieder angefasst wird. Rund 360 Dokumente stehen auf 0.3.x/0.4.0 und sind die naheliegenden Kandidaten; für sie sind es rund 5500 Stellen.
- Daneben: 19 Tests in `tests/`, Vorlagen `ab.typ`/`ka.typ`, die Doku aller Kernpakete (baut für arbeitsblatt 0.4.0 ohnehin nicht), die vendorierte Kopie für die iPad-App, `material.toml`-Pins in `eduki`, die Agenten-Anleitung in `AO/AGENTS.md`.

Kurz: Der Ansatz A ändert fast alles, was man im Kopf und an Aufgaben tippt. Der Preis ist nur tragbar, weil (a) nichts Bestehendes bricht und (b) die Umstellung maschinell geht.

---

## 8. Schwächen und Grenzfälle

1. **Größtmöglicher Bruch.** 89 % der Kopfparameter und 96 % der `aufgabe`/`teilaufgabe`-Aufrufe ändern sich. Die Varianten "Englisch zuerst" oder "Bestand festschreiben" kämen mit deutlich weniger aus, weil die meistbenutzten Namen (`title`, `class`, `font-size`, `paper`, `print`, `large`, `number`, `workspace`) heute englisch sind.
2. **Muskelgedächtnis und Hilfsmittel.** Wer zwischen alten (gepinnten) und neuen Dokumenten wechselt, hat auf Jahre zwei Vokabulare im Kopf. KI-Assistenten und Snippets kennen den alten Stand; `AGENTS.md`-artige Anleitungen müssen neu geschrieben werden.
3. **Typst bleibt englisch.** Im selben Dokument steht `#set text(size: 11pt)`, `#grid(columns: 2)`, `#image(width: 50%)` neben `#nebeneinander(breiten: 2)`. Der Sprachwechsel verschwindet nicht, er verschiebt sich an die Paketgrenze. Wer Typst gut kennt, muss für `breite`/`width` jeweils wissen, auf welcher Seite der Grenze er ist.
4. **Durchreich-Stellen bleiben zweisprachig.** `seite: (margin: …)`, `versatz: (dx: …)`, `#teilaufgaben(spalten: 2, inset: 5pt)`, `#qr-kasten(rotation: 5deg)`. Die Regel R6 ist klar, aber im Einzelfall muss man wissen, was deklariert und was durchgereicht ist. Die Grenze kann wandern: Sobald ein Paket ein durchgereichtes Argument selbst auswertet, müsste es deutsch werden (`inset` → `innenabstand`) und bricht erneut.
5. **Umschrift statt Rechtschreibung.** `loesungen`, `arbeitsflaeche`, `luecke`, `schriftgroesse`, `kaestchengroesse`, `aussen`. Die Gegenvariante mit echten Umlauten wäre besseres Deutsch, zerreißt aber Paketname und Funktionsname und ändert mehr Bestand. Beides zugleich (Aliase) verbietet sich, weil Typst nicht warnen kann und dann zwei Schreibweisen ewig leben.
6. **Lange Wörter an den häufigsten Stellen.** `arbeitsflaeche` (14 Zeichen, rund 3500-mal getippt) statt `workspace` (9); `teilaufgaben-nummerierung`, `beschriftungsgroesse`, `kaestchengroesse`, `setze-aufgaben-zurueck`. Kürzere deutsche Wörter (`platz`, `feld`) sind schon anders belegt.
7. **Deutsche Homonyme und Flexion.** `art` (Kastenart, Dokumentart), `rand` (Seitenrand, Korrekturrand: deshalb `randbreite`, `rand-kariert`, `seitenrand`), `seite` (Typst-Seiteneinstellungen und Enum-Wert `"seite"`), `name` (Schülername und Theme-Name), `loesung`/`loesungen`, `teilaufgabe`/`teilaufgaben`, `aufgabe`/`aufgaben` unterscheiden sich weiter nur in ein, zwei Buchstaben. Die Abstandsregel aus 2.2 verhindert das innerhalb einer Signatur, nicht zwischen Funktionen.
8. **Lehnwörter sind eine Ermessensliste.** `info`, `logo`, `icon`, `weblink`, `qr-code`, `code`, `format` gelten als deutsch, `theme`, `duplex`, `layout`, `link` nicht. Die Grenze ist begründbar (Duden, Schulalltag, Kollision mit Typst-Namen), aber nicht zwingend; `gestaltung` für `theme` ist die strittigste Einzelentscheidung, zumal das Wort `thema` schon als Metadatum belegt ist.
9. **`loesungen` bleibt doppelt belegt.** In `arbeitsblatt` eine Ortsangabe, in `teilaufgaben` die Liste der Lösungen. Beides ist gutes Deutsch und 35 bzw. 483 Verwendungen sprechen gegen eine Umbenennung, aber es verletzt "ein Name, eine Bedeutung".
10. **Imperativ-Vorsilben sind eine Stilentscheidung.** `zeige-loesungen` ist verständlich, aber kein übliches Deutsch für Funktionsnamen; `loesungen-zeigen` wäre natürlicher, sortiert aber nach Objekt und macht den Codemod komplizierter. `setze-aufgaben-zurueck` trennt das Verb auf.
11. **`none` und `false` als zwei "aus".** Die Regel ist eindeutig, aber `loesungen: false` bleibt ein naheliegender Fehlgriff. Er muss mit einer gezielten Meldung beantwortet werden, nicht mit der allgemeinen Werteliste.
12. **`[prüfen]`-Stellen.** Die Abbildung `"sofort"`/`"folgend"` → `"direkt"`/`"aufgabe"` und `"keine-summe"` → `summe: false` ist aus den Inventaren erschlossen, nicht am Code oder an Ausgaben nachgeprüft. Bei `materialien` verhalten sich `"sofort"` und `"folgend"` heute gleich; das neue Schema verspricht dort einen Unterschied, den es erst zu bauen gilt.
13. **Fachpakete nur angerissen.** `physik` (`lineare_regression`, zap-Bauteile `source`, `lamp`, `motor`), `informatik` (`bin2dec`, `caesar`, `ascii-table`, `häufigkeitsanalyse`), `random` (`randint`, `shuffle`), `insert-a-word` (`iaword`, Paketname selbst englisch), `energy-sketch`, `patterns` (Paketname englisch) folgen denselben Regeln, sind hier aber nicht ausbuchstabiert. Gerade dort stößt "Deutsch zuerst" an Grenzen: `caesar`, `rot13`, `vigenere`, `ascii` sind Eigennamen; Schaltzeichen heißen im Fremdpaket englisch; `randint`/`shuffle` sind aus Python-Unterricht bekannte Wörter. Englische Paketnamen ließen sich nur über neue Pakete (`muster`, `lueckentext`, `zufall`) bereinigen.
14. **Fremdnamen im selben Namensraum.** Auch mit Export-Disziplin (R7) bleiben `canvas`, `draw`, `plot`, `qty`, `fa-…` sichtbar. Wird der Wildcard-Re-Export gekappt, brechen beim Anheben zusätzlich Dokumente, die sich auf durchgereichte Fremdnamen verlassen (cetz in 390, colorful-boxes in 210 Dokumenten zusätzlich direkt importiert, der Rest unbekannt). Das ist kein Namensproblem, fällt aber in dieselbe Version.
15. **Weitergabe.** Zwei der Pakete stehen auf Typst Universe (`blockst`, `typstage`) und bleiben englisch; ein Mitautor ist eingetragen. Deutsche Bezeichner machen die Kernpakete für nicht deutschsprachige Nutzer praktisch unbrauchbar. Für ein Schulpaket mit deutschen Operatoren und Kerncurriculum ist das vertretbar, schließt aber eine spätere Veröffentlichung unter demselben Namen aus.
16. **Keine sanfte Migration innerhalb 0.4.x.** Typst kennt keine Warnungen. Alte Namen können nur mit Fehler ("`title` heißt jetzt `titel`") oder still angenommen werden. Stilles Annehmen hält die Mischung am Leben, die der Ansatz abschaffen will; also Fehler plus Codemod. Die 47 + 11 Dokumente auf 0.4.0 erleben beim Sprung auf 0.4.1 trotz gleicher Minor-Linie einen vollständigen Namensbruch; sauberer wäre, die Umbenennung als 0.5.0 zu veröffentlichen.
17. **Gestaltungen Dritter.** Wer schon ein eigenes Theme-Dictionary oder eine Theme-Funktion geschrieben hat (Signatur `(akzent, class) => dict`, Hooks mit `title:`, `large:`, `breakable:`), muss es vollständig umschreiben; Hook-Argumente kann kein Codemod sicher erkennen.
18. **Glossarpflege.** Die Regeln sind nur so gut wie die Wortlisten. Jedes neue Feature braucht eine Wortentscheidung, bevor der Lint grün wird. Das ist gewollt, bremst aber spontane Erweiterungen.
