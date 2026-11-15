// klassenarbeit.typ – die Vorlage `klassenarbeit`

#import "internal.typ": (
  answer-sheets-variant, check-exam-names, check-exam-values, exam-counter, exam-single, variant-state,
  worksheet-package,
)

/// Die Vorlage für eine Klassenarbeit, Klausur oder einen Test: Kopf mit Logo,
/// Titel, Datum, Klasse und Lehrkraft, Namensfeld, „Seite x von y“, Aufgaben
/// mit Punkten und am Ende der Erwartungshorizont. Eine Klassenarbeit ist immer
/// Druckfassung.
///
/// Angewendet wird sie mit `#show: klassenarbeit.with(…)`; für mehrere
/// Klassenarbeiten in einer Datei als `#klassenarbeit(…)[…]`. Ein gewöhnliches
/// `typst compile` erzeugt genau ein Dokument, `preview-variant` wählt, welches.
/// Im Bündel-Export (`typst compile --features bundle --format bundle`)
/// entstehen aus derselben Quelle mehrere Dateien:
///
/// - `<Name>.pdf`: die Klassenarbeit (Fassung `"print"`)
/// - `<Name> - Lösung.pdf`: Lösungen und Erwartungshorizont (`"solutions"`)
/// - `<Name> - Klausurbögen.pdf`: nur mit `answer-sheets` (`"answer-sheets"`)
///
/// `<Name>` ist `filename`, sonst der Text von `title`, sonst
/// „Klassenarbeit 1“.
///
/// ```typ
/// #import "@schule/klassenarbeit:0.5.0": *
///
/// #show: klassenarbeit.with(
///   title: [Klassenarbeit Nr. 2],
///   subtitle: [Quadratische Funktionen],
///   class: [9a],
///   date: [15.03.2026],
///   teacher: [MÜ],
///   points: "all",
/// )
///
/// #aufgabe(title: [Nullstellen])[
///   Bestimme die Nullstellen von $f(x) = x^2 - 5x + 6$.
///   #erwartung(3)[beide Nullstellen berechnet]
/// ]
/// ```
///
/// - title (str, content, none): Titel im Kopf; auch Dokumenttitel und Dateiname im Bündel
/// - subtitle (str, content, none): Untertitel unter dem Titel (nur mit Logo)
/// - class (str, content, none): Klasse oder Kurs, rechts im Kopf; ein Kürzel wie `"MA-09"` bestimmt mit einem Theme die Fachfarbe
/// - date (str, content, none): Datum, rechts im Kopf
/// - teacher (str, content, none): Kürzel oder Name der Lehrkraft, hinter der Klasse
/// - student (str, content, none): Name, der im Namensfeld schon eingetragen ist
/// - logo (auto, str, content, none): Logo links im Kopf: `auto` oder `"angela"` = Schullogo, eigener Inhalt wie `image("logo.svg")`, `none` = kein Logo
/// - name-field (str, content, none): Beschriftung des Namensfelds (den Doppelpunkt setzt das Paket); `none` = kein Namensfeld
/// - name-repeat (bool): Namensfeld im Kopf jeder Seite wiederholen
/// - info-table (array, none): Tabelle unter dem Namensfeld als Array aus Paaren `(Beschriftung, Wert)`, zum Beispiel `(([Hilfsmittel], [Taschenrechner]),)`; `none` = keine Tabelle
/// - page-counter (str, none): Seitenzahlen „Seite x von y“: `"restart"` (jede Klassenarbeit beginnt bei 1), `"continuous"` (mehrere Klassenarbeiten einer Datei zählen durch), `none` (keine Seitenzahlen)
/// - expectations (bool, dictionary): Erwartungshorizont auf einer eigenen Seite am Ende (im Bündel nur im Lösungsdokument). Ein Dictionary schaltet ihn ein und nimmt die Parameter von `show-expectations`: `select`, `blocks`, `grouped`, `achieved`, zum Beispiel `(achieved: true)` für „\_ / X“ zum Eintragen
/// - answer-sheets (bool, dictionary): Klausurbögen als eigene Fassung `"answer-sheets"`. Ein Dictionary schaltet sie ein und nimmt die Parameter des Bausteins `klausurboegen`, zum Beispiel `(pattern: "lines", stage: "sek-1")`; `title`, `subtitle`, `teacher`, `class`, `date`, `logo` und `subtask-numbering` kommen aus der Klassenarbeit. Mit `results` und `overprint: true` entsteht der Ergebnisdruck
/// - answer-sheet-pages (bool, dictionary): die Arbeit direkt auf den Klausurbogen setzen (A3 quer, gefaltet; Aufgaben auf den Seiten 1 bis 3). Die Lösung bleibt A4. Ein Dictionary schaltet es ein: `stage`, `continuation`, `points-table`, `points-table-preprinted`, `proposal`, `offset`, `back-page`, `margin`, `header-spacing`, dazu `back-page-tasks` (Aufgaben für Seite 4) und `points-table-subtasks` (`false`: nur Aufgabensummen in der Punktetabelle)
/// - solutions (str, none): Lösungen: `none`, `"in-place"` (nach jeder Teilaufgabe), `"after-task"` (nach jeder Aufgabe), `"at-end"` (am Dokumentende), `"only"` (nur Lösungen). Die Fassung `"solutions"` setzt immer `"only"`
/// - solutions-pagebreak (str, none): Umbruch bei `solutions: "at-end"`: `none`, `"before"` (Seitenumbruch vor dem Lösungsteil), `"per-task"` (jede Aufgabe auf eigener Seite)
/// - materials (str, none): Material: `none`, `"after-task"` (nach der Aufgabe), `"at-end"` (am Dokumentende)
/// - materials-pagebreak (str, none): `"before"`: Material steht auf eigener Seite (bei `"at-end"`: ein Umbruch vor dem Materialteil); `none`: kein Umbruch
/// - points (str, none): Punkteanzeige (BE): `none`, `"tasks"`, `"subtasks"`, `"all"`
/// - points-total (bool): Summe im Aufgabenkopf zeigen
/// - points-position (str): Punkte der Teilaufgaben am Zeilenende (`"end"`) oder am Seitenrand (`"margin"`)
/// - points-format (auto, function, dictionary): Vorlage der Punkteanzeige: `auto`, eine Funktion `points => content` oder `(task: f, subtask: g)`; gilt nur für diese Klassenarbeit
/// - workspaces (bool): Arbeitsflächen (`workspace`, `workspace:`) setzen
/// - shortcodes (str, none): Kurzschreibweise: `"tasks"` (`= Titel` wird eine Aufgabe), `"subtasks"` (`+ Text` wird eine Teilaufgabe), `"all"` oder `none`
/// - subtask-numbering (str): Nummerierung der Teilaufgaben als Typst-Muster, zum Beispiel `"a)"` oder `"1.1"`; gilt auch für die Klausurbögen
/// - variants (auto, array): Fassungen im Bündel-Export aus `"print"`, `"solutions"`, `"answer-sheets"`; `auto` = `("print", "solutions")`. Mit eingeschaltetem `answer-sheets` kommt `"answer-sheets"` immer dazu, auch zu einer ausdrücklichen Liste
/// - preview-variant (auto, str): außerhalb des Bündels: welche Fassung das eine Dokument zeigt, `"print"`, `"solutions"` oder `"answer-sheets"`; `auto` = `"print"`
/// - filename (str, none): Name der Ausgabedateien im Bündel ohne Endung; `none` = der Titel. Bei mehreren Klassenarbeiten in einer Datei muss er eindeutig sein
/// - paper (str): Papierformat wie bei `page`
/// - landscape (bool): Querformat
/// - duplex (bool): wechselnde Ränder für beidseitigen Druck (wirkt nur ohne die Ränder der Klassenarbeit, also mit einem eigenen `page-settings.margin` aus `inside` und `outside`)
/// - page-settings (dictionary): weitere Argumente für `set page`, zum Beispiel `margin` (Vorgabe: oben und unten 1 cm, links und rechts 1,5 cm) oder `header-ascent` (Abstand Kopf – Text, Vorgabe 14 pt)
/// - theme (auto, str, dictionary, function): Gestaltung von Aufgaben, Kästen, Lösungen und Schrift wie in `arbeitsblatt`; Kopf, Ränder, Fußzeile und Hintergrund bleiben die der Klassenarbeit
/// - accent (auto, color): Akzentfarbe eines Themes; `auto` = Fachfarbe aus dem Klassenkürzel
/// - font (auto, str, array): Textschrift; `auto` = Schrift des Themes, sonst `"Myriad Pro"`
/// - math-font (auto, str, array): Formelschrift; `auto` = Schrift des Themes, sonst `"Fira Math"`
/// - font-size (auto, length): Grundschriftgröße; `auto` = Größe des Themes, sonst `12pt`
/// - title-font-size (auto, length): Titelgröße des Themes; der Kopf der Klassenarbeit setzt den Titel immer in `16pt`
/// - figure-font-size (auto, length): Schriftgröße der Bildunterschriften; `auto` = `9pt`
/// - ..deprecated (arguments): fängt alte Namen ab und meldet den neuen; nimmt nichts an
/// - body (content): die Arbeit
/// -> content
#let klassenarbeit(
  title: none,
  subtitle: none,
  class: none,
  date: none,
  teacher: none,
  student: none,
  logo: auto,
  name-field: "Name",
  name-repeat: false,
  info-table: none,
  page-counter: "restart",
  expectations: true,
  answer-sheets: false,
  answer-sheet-pages: false,
  solutions: none,
  solutions-pagebreak: none,
  materials: "after-task",
  materials-pagebreak: "before",
  points: none,
  points-total: true,
  points-position: "end",
  points-format: auto,
  workspaces: true,
  shortcodes: "subtasks",
  subtask-numbering: "a)",
  variants: auto,
  preview-variant: auto,
  filename: none,
  paper: "a4",
  landscape: false,
  duplex: true,
  page-settings: (:),
  theme: auto,
  accent: auto,
  font: auto,
  math-font: auto,
  font-size: auto,
  title-font-size: auto,
  figure-font-size: auto,
  ..deprecated,
  body,
) = {
  let settings = (
    title: title,
    subtitle: subtitle,
    class: class,
    date: date,
    teacher: teacher,
    student: student,
    logo: logo,
    name-field: name-field,
    name-repeat: name-repeat,
    info-table: info-table,
    page-counter: page-counter,
    expectations: expectations,
    answer-sheets: answer-sheets,
    answer-sheet-pages: answer-sheet-pages,
    solutions: solutions,
    solutions-pagebreak: solutions-pagebreak,
    materials: materials,
    materials-pagebreak: materials-pagebreak,
    points: points,
    points-total: points-total,
    points-position: points-position,
    points-format: points-format,
    workspaces: workspaces,
    shortcodes: shortcodes,
    subtask-numbering: subtask-numbering,
    variants: variants,
    preview-variant: preview-variant,
    filename: filename,
    paper: paper,
    landscape: landscape,
    duplex: duplex,
    page-settings: page-settings,
    theme: theme,
    accent: accent,
    font: font,
    math-font: math-font,
    font-size: font-size,
    title-font-size: title-font-size,
    figure-font-size: figure-font-size,
  )
  // 1. Sink prüfen, 2. Typen und Werte – beides vor jeder Weitergabe.
  check-exam-names(deprecated, settings)
  check-exam-values(settings)

  // Zähler ZUERST erhöhen, damit die Nummer der Klassenarbeit stimmt.
  exam-counter.step()

  context {
    let exam-id = exam-counter.get().first()
    let sheet-settings = if type(answer-sheets) == dictionary { answer-sheets } else { (:) }
    let sheets() = answer-sheets-variant(
      title: title,
      subtitle: subtitle,
      teacher: teacher,
      class: class,
      date: date,
      logo: logo,
      subtask-numbering: subtask-numbering,
      settings: sheet-settings,
    )

    if target() == "bundle" {
      let title-text = worksheet-package.internal.plain-text(title)
      let base = if filename != none {
        filename
      } else if title-text != none and title-text.trim() != "" {
        title-text.trim()
      } else {
        "Klassenarbeit " + str(exam-id)
      }

      let names = if variants == auto { ("print", "solutions") } else { variants }
      if answer-sheets != false and "answer-sheets" not in names {
        names = names + ("answer-sheets",)
      }

      for name in names {
        if name == "print" {
          document(
            base + ".pdf",
            ..if title != none { (title: [#title]) },
            exam-single(variant: "print", scope: "exam-" + str(exam-id) + "-print", exam-id: exam-id, settings, body),
          )
        } else if name == "solutions" {
          document(
            base + " - Lösung.pdf",
            title: [#title – Lösung],
            exam-single(
              variant: "solutions",
              scope: "exam-" + str(exam-id) + "-solutions",
              exam-id: exam-id,
              settings,
              body,
            ),
          )
        } else {
          document(base + " - Klausurbögen.pdf", title: [#title – Klausurbögen], sheets())
        }
      }
    } else {
      // Fassung bestimmen: ausdrücklich > vom umgebenden Dokument geerbt
      // (verschachtelte Klassenarbeit im Bündel) > "print"
      let inherited = variant-state.get()
      let variant = if preview-variant != auto {
        preview-variant
      } else if inherited != none {
        inherited
      } else {
        "print"
      }
      if variant == "answer-sheets" {
        sheets()
      } else {
        exam-single(variant: variant, scope: none, exam-id: exam-id, settings, body)
      }
    }
  }
}
