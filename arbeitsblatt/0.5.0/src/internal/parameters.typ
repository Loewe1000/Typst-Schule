// parameters.typ – die Parametertabelle von `arbeitsblatt` und `arbeitsblatt-einzeln`
//
// EINZIGE QUELLE für Namen, Reihenfolge, Vorgaben, Typen und Docstrings der
// Kopfparameter. Aus dieser Tabelle entstehen
//
//   - zur Laufzeit: die Typprüfung, die erlaubten Namen für `check-named`, die
//     erlaubten Schlüssel von `variant-overrides` (internal.typ) und die
//     Parametertabelle, die klassenarbeit über `arbeitsblatt.internal` liest;
//   - im Quelltext: die Signaturen, Docstring-Zeilen und Weitergabe-Dictionaries
//     in src/worksheet.typ zwischen den Marken `// <erzeugt …>` und
//     `// </erzeugt>`. Sie schreibt scripts/signaturen.py:
//
//       python3 arbeitsblatt/0.5.0/scripts/signaturen.py           # schreibt
//       python3 arbeitsblatt/0.5.0/scripts/signaturen.py --check   # prüft, Exit 1 bei Abweichung
//
// Wer einen Parameter ändert, ändert ihn hier und lässt das Skript laufen.
//
// Format: genau eine Zeile je Parameter (das Skript liest zeilenweise):
//
//   name: (default: <Typst-Ausdruck>, types: (<Typen für check-type>), only: <none | "arbeitsblatt" | "arbeitsblatt-einzeln">, text: "<Docstring>"),
//
// `types` nennt Typen sowie `auto` und `none`. Die elf Optionen des Schemas
// prüft `aufgaben.internal.check-options`; Auswahlen (`stage`, `level`, `kind`)
// und Sonderfälle (`theme`, `variants`) prüft internal.typ zusätzlich.

#let worksheet-parameters = (
  title: (default: none, types: (str, content, none), only: none, text: "Titel des Blatts in der Kopfzeile; `none` = kein Titel"),
  class: (default: none, types: (str, content, none), only: none, text: "Klasse oder Kurs, rechts in der Kopfzeile; ein Kürzel wie `\"MA-05\"` bestimmt mit einem Theme Fachfarbe und Fachzeile"),
  header: (default: auto, types: (auto, content, none), only: none, text: "eigene Kopfzeile; `auto` = Kopf der Vorlage oder des Themes, `none` = kein Kopf"),
  copyright-url: (default: none, types: (str, none), only: none, text: "Adresse für den kleinen QR-Code in der Kopfzeile (Lizenz- oder Quellenangabe)"),
  paper: (default: "a4", types: (str,), only: none, text: "Papierformat wie bei `page`; mit `two-up: true` nur `\"a4\"`, `\"a5\"`, `\"a6\"`"),
  landscape: (default: false, types: (bool,), only: none, text: "Querformat"),
  print: (default: false, types: (bool,), only: none, text: "Druckfassung: feste Seitenhöhe und Heftrand; ohne sie eine endlose Bildschirmseite"),
  duplex: (default: true, types: (bool,), only: none, text: "wechselnde Ränder für beidseitigen Druck (wirkt mit `print: true`)"),
  two-up: (default: false, types: (bool,), only: none, text: "jede Seite zweimal auf einen Bogen der nächsten Größe (Kopiervorlage zum Zerschneiden); verlangt `print: true`"),
  page-settings: (default: (:), types: (dictionary,), only: none, text: "weitere Argumente für `set page`, zum Beispiel `margin`, `columns`, `header-ascent`"),
  theme: (default: auto, types: (auto, str, dictionary, function), only: none, text: "Gestaltung: `auto` = klassisch, ein Name aus `themes` (`\"klar\"`, `\"atlas\"`, `\"skizze\"`, `\"labor\"`, `\"kontur\"`, `\"leiste\"`, `\"riso\"`, `\"bauhaus\"`), ein Theme-Dictionary oder eine Funktion `(accent: auto, class: none) => dictionary`"),
  accent: (default: auto, types: (auto, color), only: none, text: "Akzentfarbe eines Themes; `auto` = Fachfarbe aus dem Klassenkürzel"),
  font: (default: auto, types: (auto, str, array), only: none, text: "Textschrift; `auto` = Schrift des Themes, sonst `\"Myriad Pro\"`"),
  math-font: (default: auto, types: (auto, str, array), only: none, text: "Formelschrift; `auto` = Schrift des Themes, sonst `\"Fira Math\"`"),
  font-size: (default: auto, types: (auto, length), only: none, text: "Grundschriftgröße; `auto` = Größe des Themes, sonst `12pt`"),
  title-font-size: (default: auto, types: (auto, length), only: none, text: "Größe des Titels in der Kopfzeile; `auto` = Größe des Themes, sonst `16pt`"),
  figure-font-size: (default: auto, types: (auto, length), only: none, text: "Schriftgröße der Bildunterschriften; `auto` = `9pt`"),
  solutions: (default: none, types: (str, none), only: none, text: "Lösungen: `none`, `\"in-place\"` (nach jeder Teilaufgabe), `\"after-task\"` (nach jeder Aufgabe), `\"at-end\"` (am Dokumentende), `\"only\"` (nur Lösungen)"),
  solutions-pagebreak: (default: none, types: (str, none), only: none, text: "Umbruch bei `solutions: \"at-end\"`: `none`, `\"before\"` (Seitenumbruch vor dem Lösungsteil), `\"per-task\"` (jede Aufgabe auf eigener Seite)"),
  materials: (default: "after-task", types: (str, none), only: none, text: "Material: `none`, `\"after-task\"` (nach der Aufgabe), `\"at-end\"` (am Dokumentende)"),
  materials-pagebreak: (default: "before", types: (str, none), only: none, text: "`\"before\"`: Material steht auf eigener Seite (bei `\"at-end\"`: ein Umbruch vor dem Materialteil); `none`: kein Umbruch"),
  points: (default: none, types: (str, none), only: none, text: "Punkteanzeige: `none`, `\"tasks\"`, `\"subtasks\"`, `\"all\"`"),
  points-total: (default: true, types: (bool,), only: none, text: "Summe im Aufgabenkopf zeigen"),
  points-position: (default: "end", types: (str,), only: none, text: "Punkte der Teilaufgaben am Zeilenende (`\"end\"`) oder am Seitenrand (`\"margin\"`)"),
  points-format: (default: auto, types: (auto, function, dictionary), only: none, text: "Vorlage der Punkteanzeige: `auto`, eine Funktion `points => content` oder `(task: f, subtask: g)`"),
  workspaces: (default: true, types: (bool,), only: none, text: "Arbeitsflächen (`workspace`, `workspace:`) setzen"),
  shortcodes: (default: "subtasks", types: (str, none), only: none, text: "Kurzschreibweise: `\"tasks\"` (`= Titel` wird eine Aufgabe), `\"subtasks\"` (`+ Text` wird eine Teilaufgabe), `\"all\"` oder `none`"),
  subtask-numbering: (default: "a)", types: (str,), only: none, text: "Nummerierung der Teilaufgaben als Typst-Muster, zum Beispiel `\"a)\"` oder `\"1.1\"`"),
  scope: (default: none, types: (str, none), only: "arbeitsblatt-einzeln", text: "Kennung der Fassung im Bündel: setzt Zähler zurück, markiert Anfang und Ende und löst Verweise innerhalb der Fassung auf"),
  variants: (default: auto, types: (auto, array), only: "arbeitsblatt", text: "Fassungen im Bündel-Export; `auto` = `(\"digital\", \"solutions\")`. Vordefiniert: `\"print\"`, `\"digital\"`, `\"solutions\"`, `\"two-up\"`; eigene Namen brauchen einen Eintrag in `variant-overrides`"),
  variant-overrides: (default: (:), types: (dictionary,), only: "arbeitsblatt", text: "Name einer Fassung → Dictionary abweichender Kopfparameter; der Schlüssel `path` ersetzt den Ausgabepfad"),
  preview-variant: (default: auto, types: (auto, str, none), only: "arbeitsblatt", text: "Fassungen in der Vorschau: `auto` = alle, wenn der Editor `--input vorschau=alle` setzt, `\"all\"` = immer alle, ein Name = genau diese Fassung, `none` = nie"),
  filename: (default: none, types: (str, none), only: "arbeitsblatt", text: "Vorsatz der Ausgabedateien im Bündel (`\"brueche\"` → `brueche-digital.pdf`)"),
  subject: (default: none, types: (str, none), only: none, text: "Fach für die Materialbibliothek, zum Beispiel `\"physik\"`"),
  topic: (default: none, types: (str, none), only: none, text: "Thema als Pfad in der Materialbibliothek, zum Beispiel `\"physik/energie\"`"),
  years: (default: (), types: (array,), only: none, text: "Jahrgänge, in denen das Blatt eingesetzt wird, zum Beispiel `(9, 11)`"),
  stage: (default: none, types: (str, none), only: none, text: "Schulstufe: `\"sek-1\"` oder `\"sek-2\"`"),
  level: (default: none, types: (str, none), only: none, text: "Anforderungsniveau: `\"introduction\"`, `\"consolidation\"`, `\"ea\"`, `\"ga\"`"),
  kind: (default: none, types: (str, none), only: none, text: "Materialart: `\"worksheet\"`, `\"practice\"`, `\"stations\"`, `\"exam\"`"),
  keywords: (default: (), types: (array,), only: none, text: "freie Stichworte"),
  curriculum: (default: (), types: (array,), only: none, text: "Bezüge zum Kerncurriculum"),
  revision: (default: none, types: (str, none), only: none, text: "Datum der letzten Überarbeitung als `\"JJJJ-MM-TT\"`"),
)
