// Interne Helfer von trimino. Keine zugesicherte Schnittstelle:
// Namen und Gestalt dürfen sich in jeder Version ändern.
//
// Geometrie: Alle Kärtchen liegen auf einem Dreiecksgitter. Ein Gitterpunkt
// (a, b) liegt bei x = a + b/2, y = b · √3/2 (Kantenlänge 1). Ein Dreieck ist
// (a: …, b: …, up: true/false):
//   up    – Ecken (a, b), (a+1, b), (a, b+1)
//   down  – Ecken (a+1, b), (a+1, b+1), (a, b+1)
// Beide Eckenlisten laufen gegen den Uhrzeigersinn. Kante i geht von Ecke i
// zu Ecke i+1; das Innere liegt links von ihr. Darauf beruht, dass jede
// Beschriftung vom Kärtcheninneren aus aufrecht steht.

#import "internal/check.typ": fail, check-named, check-value, check-type

#let height = calc.sqrt(3) / 2

/// Die Formen in der Reihenfolge, in der `auto` sie probiert.
#let shape-names = ("triangle", "hexagon", "star", "rhombus", "trapezoid", "strip")

// ---------------------------------------------------------------------------
// Zufall: lineare Kongruenz, damit jede Seed-Zahl dasselbe Spiel liefert.
// ---------------------------------------------------------------------------

#let next-random(state) = calc.rem(state * 1103515245 + 12345, 2147483648)

/// Mischt `items` (Fisher-Yates). Liefert (gemischt, neuer Zustand).
#let shuffle(items, state) = {
  let result = items
  let s = state
  for i in range(result.len() - 1, 0, step: -1) {
    s = next-random(s)
    let j = calc.rem(calc.quo(s, 65536), i + 1)
    let tmp = result.at(i)
    result.at(i) = result.at(j)
    result.at(j) = tmp
  }
  (result, s)
}

// ---------------------------------------------------------------------------
// Formen
// ---------------------------------------------------------------------------

#let vertices(t) = if t.up {
  ((t.a, t.b), (t.a + 1, t.b), (t.a, t.b + 1))
} else {
  ((t.a + 1, t.b), (t.a + 1, t.b + 1), (t.a, t.b + 1))
}

#let both(a, b) = ((a: a, b: b, up: true), (a: a, b: b, up: false))

// Alle Dreiecke im Bereich, deren drei Ecken `inside` erfüllen.
#let select(low, high, inside) = {
  let result = ()
  for b in range(low, high + 1) {
    for a in range(low, high + 1) {
      for t in both(a, b) {
        if vertices(t).all(((x, y)) => inside(x, y)) { result.push(t) }
      }
    }
  }
  result
}

#let hex-distance(x, y) = calc.max(calc.abs(x), calc.abs(y), calc.abs(x + y))

/// Die Dreiecke einer Form. `size` ist eine Zahl, bei `rhombus` und
/// `trapezoid` ein Paar.
#let shape-triangles(name, size) = {
  if name == "triangle" {
    select(0, size, (x, y) => x >= 0 and y >= 0 and x + y <= size)
  } else if name == "hexagon" {
    select(-size, size, (x, y) => hex-distance(x, y) <= size)
  } else if name == "star" {
    let k = size
    let result = ()
    for t in select(-k, 3 * k, (x, y) => true) {
      let c = vertices(t)
      let upward = c.all(((x, y)) => x >= 0 and y >= 0 and x + y <= 3 * k)
      let downward = c.all(((x, y)) => x <= 2 * k and y <= 2 * k and x + y >= k)
      if upward or downward { result.push(t) }
    }
    result
  } else if name == "rhombus" {
    let (m, n) = size
    let result = ()
    for b in range(n) { for a in range(m) { result += both(a, b) } }
    result
  } else if name == "trapezoid" {
    let (k, m) = size
    select(0, k, (x, y) => x >= 0 and y >= 0 and x + y <= k).filter(
      t => vertices(t).map(((x, y)) => y).fold(k, calc.min) < k - m)
  } else if name == "strip" {
    range(size).map(i => (a: calc.quo(i, 2), b: 0, up: calc.even(i)))
  }
}

#let edge-key(p, q) = {
  let before = p.at(0) < q.at(0) or (p.at(0) == q.at(0) and p.at(1) < q.at(1))
  let (first, second) = if before { (p, q) } else { (q, p) }
  first.map(str).join(",") + ";" + second.map(str).join(",")
}

/// Kanten einer Dreiecksliste: (inner: ((t, i, t2, i2), …), outer: ((t, i), …)).
#let edges(triangles) = {
  let seen = (:)
  let order = ()
  for (t, tri) in triangles.enumerate() {
    let c = vertices(tri)
    for i in range(3) {
      let key = edge-key(c.at(i), c.at(calc.rem(i + 1, 3)))
      if key in seen { seen.at(key).push((t, i)) } else {
        seen.insert(key, ((t, i),))
        order.push(key)
      }
    }
  }
  let inner = ()
  let outer = ()
  for key in order {
    let sides = seen.at(key)
    if sides.len() == 2 { inner.push(sides.at(0) + sides.at(1)) } else { outer.push(sides.at(0)) }
  }
  (inner: inner, outer: outer)
}

/// Alle Formen, die das Paket anbietet, mit Kärtchen- und Paarzahl.
#let catalogue() = {
  let entries = ()
  for k in range(2, 8) { entries.push(("triangle", k)) }
  for k in range(1, 4) { entries.push(("hexagon", k)) }
  for k in range(1, 3) { entries.push(("star", k)) }
  for m in range(2, 7) { for n in range(2, m + 1) { entries.push(("rhombus", (m, n))) } }
  for k in range(3, 8) { for m in range(1, k - 1) { entries.push(("trapezoid", (k, m))) } }
  for n in range(2, 61) { entries.push(("strip", n)) }
  entries.map(((name, size)) => {
    let tris = shape-triangles(name, size)
    (shape: name, shape-size: size, cards: tris.len(), pairs: edges(tris).inner.len())
  })
}

// ---------------------------------------------------------------------------
// Belegung
// ---------------------------------------------------------------------------

/// Verteilt Paare und Ablenker auf die Kanten. Liefert je Dreieck ein Array
/// aus drei Beschriftungen (`none` für leer) und den Zufallszustand.
#let fill-edges(triangles, pairs, distractors, state) = {
  let e = edges(triangles)
  let labels = triangles.map(_ => (none, none, none))
  let (order, s) = shuffle(range(e.inner.len()), state)
  for (k, pair) in pairs.enumerate() {
    let (t1, i1, t2, i2) = e.inner.at(order.at(k))
    s = next-random(s)
    let swap = calc.rem(calc.quo(s, 65536), 2) == 1
    let (task, answer) = if swap { (pair.at(1), pair.at(0)) } else { (pair.at(0), pair.at(1)) }
    labels.at(t1).at(i1) = task
    labels.at(t2).at(i2) = answer
  }
  let (outer, s2) = shuffle(e.outer, s)
  for (k, d) in distractors.enumerate() {
    if k >= outer.len() { break }
    let (t, i) = outer.at(k)
    labels.at(t).at(i) = d
  }
  (labels, s2)
}

/// Eckfarben zur Selbstkontrolle (`corners: "wheel"`). An jeder Gitterecke
/// stoßen bis zu sechs Kärtchen zusammen; ihre Eckspitzen bekommen dort
/// verschiedene Farben (eine gemischte Reihenfolge von 0–5). Richtig gelegt
/// enthält deshalb jeder Stern jede Farbe höchstens einmal, ein voller Stern
/// jede genau einmal. Liefert je Dreieck drei Farbnummern (je Ecke i).
#let wheel-corners(triangles, state) = {
  let seen = (:)
  let order = ()
  for (t, tri) in triangles.enumerate() {
    for (i, c) in vertices(tri).enumerate() {
      let key = c.map(str).join(",")
      if key in seen { seen.at(key).push((t, i)) } else {
        seen.insert(key, ((t, i),))
        order.push(key)
      }
    }
  }
  let result = triangles.map(_ => (0, 0, 0))
  let s = state
  for key in order {
    let (perm, s2) = shuffle(range(6), s)
    s = s2
    for (k, (t, i)) in seen.at(key).enumerate() { result.at(t).at(i) = perm.at(k) }
  }
  result
}

// ---------------------------------------------------------------------------
// Zeichnen
// ---------------------------------------------------------------------------

#let point((x, y), unit) = ((x + y / 2) * unit, y * height * unit)

// Farben, die mehrere Themes teilen. Was nur ein Theme braucht, steht in
// seinem Dictionary (`themes`).
#let ink-color = rgb("#1a1a1a")       // Text, Formeln, Kurven
#let line-color = rgb("#5e5e5e")      // Umriss = Schnittlinie
#let accent-color = rgb("#c8553d")    // Akzent von riso (Koralle)
#let answer-color = rgb("#d62839")    // Rahmen der Lösung (Domino): hell, dünn, rund
#let task-color = rgb("#1d5fa8")      // Rahmen der Aufgabe (Domino): dunkel, kräftig, eckig
#let navy = rgb("#22313f")            // dunkle Augen auf hellen Eckspitzen
#let field-color = white              // Fläche bei `label: "field"`
/// Fachfarbe Mathematik, wie in @schule/arbeitsblatt: Akzent der Themes
/// atlas, skizze, labor und kontur.
#let ma-blue = rgb("#2f6fb5")
// Pastelltöne je Kärtchen (`fill: "tint"`).
#let pastels = (rgb("#fde2e4"), rgb("#e2ece9"), rgb("#dfe7fd"), rgb("#fff1c1"), rgb("#e8dff5"), rgb("#d7f0f7"))
// Leisten bei `band: "edge"`: helle Töne, beim Zeichnen um 60 % aufgehellt.
#let edge-colors = (rgb("#e9a596"), rgb("#a3bbdd"), rgb("#9ccbc1"))
// Ringfarben: hell je Ring (`fill: "ring"`), aufgehellt Konfetti der
// riso-Rückseite, abgedunkelt die Buchstaben ihres Schriftzugs.
#let ring-colors = (rgb("#ffd166"), rgb("#ef8354"), rgb("#4ea8de"), rgb("#7bc47f"), rgb("#b388eb"), rgb("#f28482"))
// Eckfarben für `corners: "wheel"` (Vorgabe bei `wheel: auto`): sechs
// kräftige, gut unterscheidbare Töne. Farbe k trägt k + 1 Würfelaugen; die
// Augen sind der zweite, unabhängige Code (schwarz-weiß, Farbsehschwäche).
// Ihre Farbe folgt aus der Helligkeit der Spitze (`pip-ink`).
#let wheel-colors = (rgb("#d62839"), rgb("#ea6a1f"), rgb("#c99a06"), rgb("#2a9d5c"), rgb("#1d5fa8"), rgb("#8e4fb5"))
// Graustufen für Themes ohne Farbe (`wheel: none`): eine Helligkeitsleiter.
#let wheel-greys = (luma(18%), luma(36%), luma(52%), luma(68%), luma(82%), luma(93%))
#let wheel-grey-pips = (white, white, white, black, black, black)

/// Helligkeit einer Farbe (OKLab L, 0 … 1).
#let lightness(c) = c.oklab().components().first() / 100%

/// Farbe der Würfelaugen auf einer Eckspitze: weiß auf dunklen, dunkel auf
/// sehr hellen Tönen (OKLab L > 0,8, etwa Hellgelb); das Gold von riso trägt weiße Augen.
#let pip-ink(c) = if lightness(c) > 0.8 { navy } else { white }

/// Die sechs Eckfarben eines Themes samt Augenfarbe: `(colors, pips)`.
#let wheel-palette(theme) = {
  let w = theme.at("wheel", default: auto)
  if w == none { (colors: wheel-greys, pips: wheel-grey-pips) }
  else {
    let cs = if w == auto { wheel-colors } else { w }
    (colors: cs, pips: cs.map(pip-ink))
  }
}

/// Schriften für alles, was das Paket selbst schreibt (Kopf, Start/Ende,
/// Nummern, Rückseite), wenn das Theme keine nennt: eine Neo-Grotesk, die
/// erste vorhandene gilt.
#let chrome-fonts = ("Inter", "IBM Plex Sans", "Fira Sans", "Helvetica Neue", "Arial", "DejaVu Sans")
/// Geometrische Grotesk für Schriftzug und Start/Ende der klassischen Themes.
#let geo-fonts = ("Futura", "Avenir Next", "Montserrat", "Gill Sans", "Fira Sans")
#let back-fonts = geo-fonts

/// Schrift für Kopf, Fußnote und Rückseitentext (Theme-Schlüssel `chrome`).
#let chrome-font(theme) = {
  let f = theme.at("chrome", default: auto)
  if f == auto { chrome-fonts } else { f }
}
/// Auszeichnungsschrift: Titel, Schriftzug, Start/Ende (`display`).
#let display-font(theme) = {
  let f = theme.at("display", default: auto)
  if f == auto { chrome-font(theme) } else { f }
}
/// Schrift für Nummern und START/ENDE (`code`); ohne: die Auszeichnungsschrift.
#let code-font(theme) = {
  let f = theme.at("code", default: none)
  if f == none { display-font(theme) } else { f }
}

/// Ohne Farbe (Theme `klar`): Rückseite, Zeichen und Schriftzug in Grau.
#let mono(theme) = theme.at("wheel", default: auto) == none

/// Schriftpaare für Beschriftungen: Text passend zur Matheschrift.
#let font-pairs = (
  klassisch: (text: ("New Computer Modern",), math: "New Computer Modern Math", weight: 450),
  serifenlos: (text: ("Fira Sans",), math: "Fira Math", weight: 400),
  libertinus: (text: ("Libertinus Serif",), math: "Libertinus Math", weight: 400),
  stix: (text: ("STIX Two Text",), math: "STIX Two Math", weight: 400),
)
/// Matheschrift → passende Textschrift.
#let math-to-text = (
  "New Computer Modern Math": "New Computer Modern",
  "Fira Math": "Fira Sans",
  "STIX Two Math": "STIX Two Text",
  "Libertinus Math": "Libertinus Serif",
  "Noto Sans Math": "Noto Sans",
  "TeX Gyre Pagella Math": "TeX Gyre Pagella",
)
// Textschrift (klein geschrieben) → Matheschrift.
#let text-to-math = {
  let d = (:)
  for (m, t) in math-to-text { d.insert(lower(t), m) }
  d
}

/// Schriften der Beschriftungen: `(text:, math:, weight:)`; `math: none` lässt
/// die Matheschrift des Dokuments unberührt. Braucht bei `font: auto` und
/// `math: auto` den `context` (liest die Dokumentschrift).
///
/// Reihenfolge: Paarname; Schriftname (mit Partner-Matheschrift, wenn
/// bekannt); Dictionary; `math` gesetzt → Textschrift dazu; sonst die
/// Dokumentschrift, wenn zu ihr eine Matheschrift bekannt ist (New Computer
/// Modern also nur, wenn das Dokument sie setzt). In allen übrigen Fällen –
/// auch bei Typsts Vorgabe Libertinus Serif – das Paar Fira Sans + Fira Math:
/// serifenlos, gut lesbar, ohne Hochschulanmutung.
#let label-fonts(theme) = {
  let f = theme.at("font", default: auto)
  let m = theme.at("math", default: auto)
  if type(f) == str and f in font-pairs { return font-pairs.at(f) }
  if type(f) == str {
    let partner = text-to-math.at(lower(f), default: none)
    return (text: (f,), math: partner, weight: 400)
  }
  if type(f) == dictionary {
    let t = f.at("text")
    return (text: if type(t) == str { (t,) } else { t }, math: f.at("math", default: none),
      weight: f.at("weight", default: 400))
  }
  if m != auto {
    let t = math-to-text.at(m, default: none)
    return if t == none { (text: font-pairs.serifenlos.text, math: m, weight: 400) }
      else if t == "New Computer Modern" { (text: (t,), math: m, weight: 450) }
      else { (text: (t,), math: m, weight: 400) }
  }
  let doc = text.font
  let doc = lower(if type(doc) == array { doc.first() } else { doc })
  let partner = text-to-math.at(doc, default: none)
  if doc == "new computer modern" { font-pairs.klassisch }
  else if partner != none and doc != "libertinus serif" {
    (text: (math-to-text.at(partner),), math: partner, weight: 400)
  } else { font-pairs.serifenlos }
}

/// Formeln in Beschriftungen in Displaygröße: Brüche bleiben so groß wie
/// der Text daneben.
#let displayed(body) = {
  if type(body) != content { return body }
  if body.func() == math.equation and not body.block {
    math.equation(block: false, math.display(body.body))
  } else if body.has("children") {
    body.children.map(displayed).join()
  } else { body }
}

/// Reine Zahlen mit 6 oder 9 (66, 69, 96 …), als Text oder als Formel aus
/// einer Zahl, bekommen einen Unterstrich, damit sie gedreht nicht verwechselt
/// werden. `show` ist der Inhalt, wie er gesetzt wird (etwa in Displaygröße).
#let six-nine-number(body) = {
  if type(body) == str { body = [#body] }
  if type(body) != content { return false }
  if body.func() == math.equation { body = body.body }
  if body.func() == text {
    let t = body.text.trim()
    return t.match(regex("^[0-9]+$")) != none and (t.contains("6") or t.contains("9"))
  }
  false
}
// Ebenso Zähler und Nenner eines Bruchs, die nur aus einer Zahl mit 6 oder 9
// bestehen (9/2 gedreht ist sonst 6 unter dem Bruchstrich). Der Strich hält
// etwas Abstand zum Bruchstrich.
#let six-nine-part(b) = b.func() == text and b.text.match(regex("^[0-9]+$")) != none and (b.text.contains("6") or b.text.contains("9"))
#let mark-six-nine(body, shown: auto) = {
  let shown = if shown == auto { if type(body) == str { [#body] } else { body } } else { shown }
  if six-nine-number(body) { return underline(offset: 0.12em, stroke: 0.06em, shown) }
  show math.frac: it => {
    if not (six-nine-part(it.num) or six-nine-part(it.denom)) { return it }
    // Mathe-Unterstrich (bleibt in der Größe von Zähler/Nenner); im Zähler
    // schiebt eine unsichtbare Stütze den Bruchstrich etwas tiefer, damit der
    // Unterstrich nicht am Bruchstrich klebt.
    let strut = box(baseline: 0.22em, width: 0pt, height: 0.22em)
    let u(b, num) = if six-nine-part(b) {
      if num { math.underline(b) + strut } else { math.underline(b) }
    } else { b }
    math.frac(u(it.num, true), u(it.denom, false))
  }
  shown
}

/// Die Themes. Schlüssel eines Theme-Dictionarys (jeder Wert darf auch eine
/// Funktion der Akzentfarbe sein, etwa `a => a.lighten(80%)`; so folgen
/// abgeleitete Farben einem geänderten `accent`):
///
/// Kärtchen
///   fill         – Füllung: none, Farbe, Array aus Farben (eine je Kärtchen, gemischt),
///                  "set" (ein Ton aus `palette` für den ganzen Satz, nach `seed`), "tint" (ein Ton aus `palette` je Kärtchen), "ring" (hell je Ring), "parity" oder "single"
///   stroke       – Umriss (zugleich Schnittlinie)
///   band         – Leiste an den Kanten: none, Farbe oder "edge" (heller Ton je Kante)
///   band-depth   – Breite der Leiste als Anteil der Kantenlänge; ab 0,1 stehen die Beschriftungen darin
///   inner        – Umriss des inneren Dreiecks: none oder Stroke
///   corner       – Farbe der Eckmarken (`corners: true`)
///   corner-mark  – Form der Eckmarken: "arc" (Bogen), "kite" (zweifarbiger Drachen), "triangle"
///                  (flaches Dreieck), "dot" (Kreissektor, im Lösungsbild ein Kreis), "ticks"
///                  (Messskala an beiden Kanten) oder none
///   tip          – Form der Eckspitzen bei `corners: "wheel"`: "circle", "ring" oder "hexagon"
///   tip-edge     – Fuge zwischen den Eckspitzen: auto (weiß) oder Stroke
///   wheel        – Eckfarben: auto (sechs kräftige Farben), none (Grauleiter) oder Array aus
///                  sechs Farben; die Augenfarbe folgt aus der Helligkeit
///   pips         – Würfelaugen auf den Eckspitzen: true oder false
/// Beschriftungen
///   label        – Rahmen: "plain", "pill", "outline", "field" oder "tab"
///   pill         – Hinterlegung bei `label: "pill"`/"tab": none (weiß) oder Farbe
///   field        – Fläche bei `label: "field"` (auch Felder der Dominos): Farbe
///   field-stroke – Rand dieser Fläche: none oder Stroke (auch gestrichelt)
///   ink          – Schriftfarbe
///   weight       – Schriftstärke (auto: passend zum Schriftpaar)
///   font         – Schrift: auto, "klassisch", "serifenlos", "libertinus", "stix", ein
///                  Schriftname oder (text:, math:, weight:); `text` darf eine Liste mit
///                  Ersatzschriften sein
///   math         – Matheschrift des Dokuments, wenn sie nicht die Vorgabe ist (auto oder Name)
/// Domino
///   answer       – Rahmenfarbe der Lösung: dünn, runde Ecken
///   task         – Rahmenfarbe der Aufgabe: kräftig, eckig
///   divider      – Trennlinie der Hälften: "line", "dashed", "ticks" (Messskala) oder none
///   shadow       – harter, versetzter Schatten hinter Feldern, Etiketten und Kopfkasten: none oder Farbe
/// Blatt und Rückseite
///   accent       – Akzentfarbe: Spielname im Kopf, Strich unterm Lösungsbuchstaben, Grundton
///                  abgeleiteter Farben
///   chrome       – Schrift für Kopf, Fußnote und Rückseite: auto (Neo-Grotesk) oder Schriftliste
///   display      – Schrift für Titel, Schriftzug und Start/Ende: auto (wie `chrome`) oder Liste
///   code         – Schrift für Nummern und START/ENDE: none (wie `display`) oder Liste (etwa Fira Code)
///   head         – Kopf über Lösung und Schnittbogen: "rule" (Titel links, Spiel und Art klein
///                  rechts, feine Linie), "band" (Titelband in der Akzentfarbe mit Kreisen),
///                  "tape" (Titel auf Klebeband), "frame" (Rahmen mit Kennzeile und Messskala)
///                  oder "poster" (Versalien, Schattenkasten, dicke Linie)
///   back-style   – Rückseite: "pastel" (Creme, Pastellkonfetti), "mono" (weiß, grau), "tint"
///                  (Akzent hell), "circles" (Kreise in Akzenttönen), "crayon" (bunte
///                  Dreiecke, Kleckse, Sterne), "grid" (Millimeterpapier, Quadrate und Kreuze)
///                  oder "poster" (Schwarz und Akzent)
///   wordmark     – Schriftzug „TRIMINO“/„DOMINO“ auf dem Etikett der Rückseite: "rainbow"
///                  (Buchstaben bunt), "accent", "mono", "tile" (weiß auf Akzentkachel),
///                  "hand" (Handschrift, bunt), "code" (Monospace) oder "poster" (Versalien im
///                  Schattenkasten)
/// Nur in einem Dictionary:
///   base         – Theme, dessen Schlüssel das Dictionary ändert (Vorgabe "riso")
#let theme-sources = (
  // Standard: Pastell je Kärtchen, weiße Felder mit Haarlinie, zweifarbige
  // Drachen in den Ecken; Rückseite creme mit Pastellkonfetti.
  riso: (fill: "set", palette: pastels, stroke: 0.9pt + luma(40%), band: none, band-depth: 0.15, inner: none,
    corner: accent-color, corner-mark: "kite", tip: "circle", tip-edge: auto, wheel: auto, pips: true,
    label: "field", pill: none, field: white, field-stroke: 0.4pt + luma(70%), ink: luma(10%), weight: auto,
    font: auto, math: auto,
    answer: answer-color, task: task-color, divider: "dashed", shadow: none,
    accent: accent-color, chrome: auto, display: geo-fonts, code: none, head: "rule",
    back-style: "pastel", wordmark: "rainbow"),
  // Schwarz-weiß, kopierfest; ab Klasse 9 und für Kopien.
  klar: (fill: none, stroke: 0.6pt + black, band: none, band-depth: 0.15, inner: none,
    corner: black, corner-mark: "arc", tip: "circle", tip-edge: auto, wheel: none, pips: true,
    label: "plain", pill: none, field: luma(96%), field-stroke: none, ink: black, weight: auto,
    font: auto, math: auto,
    answer: luma(45%), task: black, divider: "line", shadow: none,
    accent: black, chrome: auto, display: auto, code: none, head: "rule",
    back-style: "mono", wordmark: "mono"),
  // Violette Leiste an jeder Kante, die Beschriftungen stehen darin.
  leiste: (fill: white, stroke: 1pt + rgb("#5b4bb7"), band: rgb("#e8e3fb"), band-depth: 0.15, inner: none,
    corner: rgb("#5b4bb7"), corner-mark: "kite", tip: "circle", tip-edge: auto, wheel: auto, pips: true,
    label: "plain", pill: none, field: white, field-stroke: none, ink: rgb("#2d2464"), weight: auto,
    font: auto, math: auto,
    answer: answer-color, task: rgb("#2d2464"), divider: "line", shadow: none,
    accent: rgb("#5b4bb7"), chrome: auto, display: geo-fonts, code: none, head: "rule",
    back-style: "tint", wordmark: "accent"),
  // Wie ein modernes Schulbuch (arbeitsblatt: atlas): Kärtchen in der
  // Fachfarbe getönt, weiße runde Felder, Titelband mit Kreisen.
  atlas: (fill: a => a.lighten(89%), stroke: a => 0.8pt + a.darken(8%), band: none, band-depth: 0.15, inner: none,
    corner: a => a, corner-mark: "dot", tip: "circle", tip-edge: auto,
    wheel: (rgb("#2f6fb5"), rgb("#e8573c"), rgb("#f2b632"), rgb("#2e9e5b"), rgb("#8a5cc7"), rgb("#19a7bd")),
    pips: true, label: "field", pill: none, field: white, field-stroke: none, ink: rgb("#1f2933"), weight: auto,
    font: (text: ("Myriad Pro", "Fira Sans"), math: "Fira Math", weight: 400), math: auto,
    answer: rgb("#e8573c"), task: a => a.darken(38%), divider: "line", shadow: none,
    accent: ma-blue, chrome: ("Myriad Pro", "Fira Sans"), display: ("Myriad Pro", "Fira Sans"), code: none,
    head: "band", back-style: "circles", wordmark: "tile"),
  // Verspielt für die Unterstufe (arbeitsblatt: skizze): Kreidetöne,
  // gestrichelte Felder, Handschrift, Titel auf Klebeband.
  skizze: (fill: "set", palette: (rgb("#fff3dc"), rgb("#fde6ea"), rgb("#e3f1fb"), rgb("#e8f5df"), rgb("#f1e8fa")),
    stroke: 1pt + rgb("#3d3a35"), band: none, band-depth: 0.15, inner: none,
    corner: rgb("#e4572e"), corner-mark: "arc", tip: "circle", tip-edge: auto,
    wheel: (rgb("#e4572e"), rgb("#f4a300"), rgb("#7cb518"), rgb("#2b9bd8"), rgb("#9b5de5"), rgb("#f15bb5")),
    pips: true, label: "field", pill: none, field: white,
    field-stroke: a => (paint: a.lighten(15%), thickness: 0.8pt, dash: (2.2pt, 1.6pt)), ink: rgb("#2f2b26"),
    weight: auto, font: (text: ("SF Pro Rounded", "Fira Sans"), math: "Fira Math", weight: 400), math: auto,
    answer: rgb("#e4572e"), task: rgb("#24467a"), divider: "dashed", shadow: none,
    accent: ma-blue, chrome: ("Playpen Sans", "Fira Sans"), display: ("Playpen Sans", "Fira Sans"), code: none,
    head: "tape", back-style: "crayon", wordmark: "hand"),
  // Technisch für MINT (arbeitsblatt: labor): Nachtblau, Haarlinien,
  // Messskalen in den Ecken, Fira Code für Nummern und START/ENDE.
  labor: (fill: none, stroke: 0.7pt + rgb("#1c2230"), band: none, band-depth: 0.15, inner: none,
    corner: rgb("#1c2230"), corner-mark: "ticks", tip: "hexagon", tip-edge: auto,
    wheel: (rgb("#1c2230"), rgb("#2f6fb5"), rgb("#13866f"), rgb("#e3752a"), rgb("#f2c14e"), rgb("#d9e2ec")),
    pips: true, label: "outline", pill: none, field: rgb("#f5f7fa"), field-stroke: none, ink: rgb("#1c2230"),
    weight: auto, font: (text: ("Fira Sans",), math: "Fira Math", weight: 400), math: auto,
    answer: rgb("#e3752a"), task: rgb("#1c2230"), divider: "ticks", shadow: none,
    accent: ma-blue, chrome: ("Fira Sans",), display: ("Fira Sans",), code: ("Fira Code",),
    head: "frame", back-style: "grid", wordmark: "code"),
  // Plakativ (arbeitsblatt: kontur): dicke schwarze Umrisse, harte Schatten
  // in der Akzentfarbe, Futura in Versalien.
  kontur: (fill: white, stroke: 1.4pt + luma(12%), band: none, band-depth: 0.15, inner: none,
    corner: a => a, corner-mark: "triangle", tip: "circle", tip-edge: 0.7pt + luma(12%),
    wheel: (luma(12%), rgb("#2f6fb5"), rgb("#e63946"), rgb("#ffd23f"), rgb("#2a9d5c"), white),
    pips: true, label: "plain", pill: none, field: white, field-stroke: none, ink: luma(10%), weight: auto,
    font: (text: ("Helvetica Neue", "Fira Sans"), math: "Fira Math", weight: 400), math: auto,
    answer: rgb("#e63946"), task: luma(12%), divider: "line", shadow: a => a,
    accent: ma-blue, chrome: ("Helvetica Neue", "Fira Sans"), display: ("Futura", "Fira Sans"), code: none,
    head: "poster", back-style: "poster", wordmark: "poster"),
)

/// Werte, die Funktionen der Akzentfarbe sind, ausrechnen.
#let resolve-style(t) = {
  let accent = t.accent
  if type(accent) == function { accent = accent(ma-blue) }
  let out = t
  out.accent = accent
  for (k, v) in t {
    if k != "accent" and type(v) == function { out.insert(k, v(accent)) }
  }
  out
}

/// Fertige Themes (alle Schlüssel, Farben ausgerechnet).
#let themes = {
  let d = (:)
  for (name, t) in theme-sources { d.insert(name, resolve-style(t)) }
  d
}

/// Themes, die es nicht mehr gibt: Name → Hinweis.
#let removed-themes = (bauhaus: "das Theme `bauhaus` gibt es nicht mehr")

/// Das Theme eines Aufrufs prüfen und ausrechnen: auto, Name oder Dictionary
/// (mit `base`). Bricht mit einer Meldung ab, wenn etwas nicht stimmt.
#let resolve-theme(pkg, fn, theme) = {
  check-type(pkg, fn, "theme", theme, (str, dictionary, auto), example: "\"klar\"")
  let names = themes.keys()
  let list = names.map(n => "`\"" + n + "\"`").join(", ")
  let known(name, what) = {
    if name in removed-themes {
      fail(pkg, fn, removed-themes.at(name) + " – eines davon wählen: " + list)
    }
    check-value(pkg, fn, what, name, names)
  }
  let source = if theme == auto { theme-sources.riso } else if type(theme) == str {
    known(theme, "theme")
    theme-sources.at(theme)
  } else {
    check-named(pkg, fn, theme, allowed: theme-sources.riso.keys() + ("base",), what: "Schlüssel")
    let base = theme.at("base", default: "riso")
    check-type(pkg, fn, "theme.base", base, str, example: "\"atlas\"")
    known(base, "theme.base")
    let t = theme-sources.at(base) + theme
    let _ = t.remove("base", default: none)
    t
  }
  let style = resolve-style(source)
  check-value(pkg, fn, "theme.label", style.label, ("pill", "plain", "outline", "field", "tab"))
  check-value(pkg, fn, "theme.tip", style.tip, ("circle", "ring", "hexagon"))
  check-type(pkg, fn, "theme.pips", style.pips, bool)
  check-value(pkg, fn, "theme.corner-mark", style.corner-mark, ("arc", "kite", "triangle", "dot", "ticks", none))
  check-type(pkg, fn, "theme.math", style.math, (str, auto), example: "\"Fira Math\"")
  check-type(pkg, fn, "theme.wheel", style.wheel, (array, auto, none), example: "none")
  if type(style.wheel) == array and (style.wheel.len() != 6 or style.wheel.any(c => type(c) != color)) {
    fail(pkg, fn, "`theme.wheel` braucht genau sechs Farben – etwa `(red, orange, olive, green, blue, purple)`")
  }
  check-type(pkg, fn, "theme.accent", style.accent, color, example: "rgb(\"#2f6fb5\")")
  check-type(pkg, fn, "theme.shadow", style.shadow, (color, none), example: "rgb(\"#2f6fb5\")")
  check-value(pkg, fn, "theme.head", style.head, ("rule", "band", "tape", "frame", "poster"))
  check-value(pkg, fn, "theme.back-style", style.back-style, ("pastel", "mono", "tint", "circles", "crayon", "grid", "poster"))
  check-value(pkg, fn, "theme.wordmark", style.wordmark, ("rainbow", "accent", "mono", "tile", "hand", "code", "poster"))
  check-value(pkg, fn, "theme.divider", style.divider, ("line", "dashed", "ticks", none))
  let pal = style.at("palette", default: pastels)
  if type(pal) != array or pal.len() == 0 or pal.any(c => type(c) != color) {
    fail(pkg, fn, "`theme.palette` braucht ein Array aus Farben – etwa `(rgb(\"#fde2e4\"), rgb(\"#dfe7fd\"))`")
  }
  if type(style.fill) == array and (style.fill.len() == 0 or style.fill.any(c => type(c) != color)) {
    fail(pkg, fn, "`theme.fill` als Array braucht Farben – etwa `(rgb(\"#fde2e4\"), rgb(\"#dfe7fd\"))`")
  }
  style
}

// ---------------------------------------------------------------------------
// Beschriftungen: Rahmen und Platz
// ---------------------------------------------------------------------------
//
// Jede Kante hat ein eigenes Feld: das Dreieck aus der Kante und der
// Kärtchenmitte, seitlich also Geraden unter 30° zur Kante. Davon gehen die
// Eckmarken oder Eckspitzen ab (Radius `r`, als Anteil der Kante) und oben ein
// Rest um die Mitte (für die Nummer im Lösungsbild). Alle Maße sind Anteile
// der Kante.

#let label-wedge = 2 * calc.sqrt(3)   // Breitenverlust je Höhe: 2 · cot 30°

/// Radius der Eckspitzen bei `corners: "wheel"` (Anteil der Kante).
/// Groß genug, dass auch sechs Würfelaugen luftig darin stehen.
#let tip-radius(theme) = if theme.tip == "hexagon" { 0.235 } else if theme.tip == "ring" { 0.225 } else { 0.225 }
/// Innenradius des Rings (`tip: "ring"`).
#let ring-hole = 0.09

/// Form der Eckmarken bei `corners: true`.
#let corner-mark(theme) = theme.at("corner-mark", default: "arc")

/// Freier Platz für die Beschriftungen: Unterkante `y0`, Oberkante `top`,
/// Radius der Eckmarken oder -spitzen `r`. `number`: in der Mitte steht eine
/// Nummer (Lösungsbild), dann bleibt oben etwas mehr frei.
#let label-room(theme, corners, number: true) = {
  let r = if corners == "wheel" { tip-radius(theme) } else if corners == true {
    let m = corner-mark(theme)
    if m == "kite" { 0.16 } else if m == "ticks" { 0.125 } else if m in ("triangle", "dot") { 0.09 }
      else if m == "arc" { 0.085 } else { 0.04 }
  } else { 0.04 }
  // Unterkante gut 2 mm über der Schnittlinie (bei 6 cm Kante), oben nur die
  // Geraden zur Mitte (Spitze bei 1/(2·√3) ≈ 0,289) und Platz für die Nummer.
  let top = if number { 0.27 } else { 0.285 }
  let y0 = if theme.label == "tab" { 0.0 } else { 0.04 }
  // Schmale Leiste an der Kante: Text darüber; breites Band: Text darin.
  if theme.band != none {
    (y0, top) = if theme.band-depth < 0.1 { (theme.band-depth + 0.03, top) } else { (0.03, theme.band-depth - 0.015) }
  }
  let gap = if theme.label == "field" { 0.03 } else { 0.0 }
  if theme.label == "field" { y0 = calc.max(y0, 0.045) }
  (y0: y0, top: top, r: r, gap: gap)
}

/// Die Beschriftung samt Rahmen in Schriftgröße `size`. Text in der Schrift,
/// die zur Matheschrift passt; Formeln in Displaygröße; alles in einer Stärke.
/// Braucht `context`, wenn die Schrift aus dem Dokument folgt.
#let label-body(label, size, theme) = {
  let fonts = label-fonts(theme)
  let weight = if theme.weight == auto { fonts.weight } else { theme.weight }
  let body = {
    set text(font: fonts.text, size: size, fill: theme.ink, weight: weight,
      number-type: "lining", top-edge: "bounds", bottom-edge: "bounds")
    show math.equation: set text(font: fonts.math) if fonts.math != none
    mark-six-nine(label, shown: displayed(label))
  }
  let paint = if theme.pill == none { white } else { theme.pill }
  if theme.label == "pill" {
    box(fill: paint, inset: (x: 0.4em, y: 0.32em), radius: 0.8em, stroke: 0.4pt + luma(70%), body)
  } else if theme.label == "outline" {
    box(inset: (x: 0.4em, y: 0.32em), radius: 2pt, stroke: 0.5pt + theme.ink.lighten(35%), body)
  } else if theme.label == "tab" {
    box(fill: paint, inset: (x: 0.5em, top: 0.38em, bottom: 0.3em), radius: (top-left: 2pt, top-right: 2pt),
      stroke: (top: 0.4pt + luma(70%), left: 0.4pt + luma(70%), right: 0.4pt + luma(70%)), body)
  } else if theme.label == "field" {
    box(inset: (x: 0.15em, y: 0.15em), body)
  } else { box(inset: (x: 0.1em, y: 0.1em), body) }
}

/// Median einer sortierten Liste.
#let median(sorted) = {
  let n = sorted.len()
  if calc.odd(n) { sorted.at(calc.quo(n, 2)) } else { (sorted.at(calc.quo(n, 2) - 1) + sorted.at(calc.quo(n, 2))) / 2 }
}

/// Eine Größe für den ganzen Satz: höchstens 1,05 × Median der Größen, die
/// jede Beschriftung für sich bekäme, und höchstens 1,25 × die kleinste. So
/// ist die größte nie mehr als 1,25 × die kleinste, und alle sind so groß, wie
/// der Median erlaubt. Nur, was nicht passt, wird einzeln kleiner.
/// `floor`: Größe, unter der eine Beschriftung als Ausreißer gilt (etwa ein
/// sehr langes Wort). Ausreißer ziehen den Satz nicht mit hinunter; sie
/// werden allein kleiner, die übrigen bleiben gut lesbar.
#let set-cap(fits, floor: 0) = {
  let all = fits.filter(x => x != none).sorted()
  if all.len() == 0 { return none }
  let regular = all.filter(x => x >= floor)
  let smallest = if regular.len() == 0 { all.first() } else { regular.first() }
  calc.min(median(all) * 1.05, smallest * 1.25)
}

/// Lesbare Mindestgröße der Beschriftungen auf dem Schnittbogen, in pt.
#let readable-size = 9

/// Schriftgrößen je Kärtchen und Kante, als Größe je cm Kantenlänge (Regel
/// in `set-cap`). Aufgabe und Lösung sind also gleich groß, und die Größe sagt
/// nichts über die Wichtigkeit. `fixed` setzt eine feste Größe je cm.
/// `number` wie bei `label-room`. Braucht `context` (misst die Beschriftungen).
#let fit-sizes(labels, theme, corners, fixed: none, number: true, side: none) = {
  if fixed != none { return labels.map(l => (fixed, fixed, fixed)) }
  let room = label-room(theme, corners, number: number)
  let (y0, top, r) = (room.y0, room.top, room.r)
  let probe = 10pt
  let factor(label) = {
    let m = measure(label-body(label, probe, theme))
    let (w, h) = (m.width / 1cm, m.height / 1cm)
    let k = calc.min(
      // obere Ecken auf den Geraden: w·k = 1 − 2√3·(y0 + h·k)
      (1 - 2.3 * room.gap - label-wedge * y0) / (w + label-wedge * h),
      // untere Ecken außerhalb der Eckmarken
      (1 - 2 * calc.sqrt(calc.max(r * r - y0 * y0, 0)) - 0.04) / w,
      (top - y0) / h,
    )
    probe * k * 0.95
  }
  let each = labels.map(l => l.map(x => if x == none { none } else { factor(x) }))
  let cap = set-cap(each.flatten(), floor: if side == none { 0pt } else { readable-size * 1pt / side })
  if cap == none { return labels.map(l => (probe / 6, probe / 6, probe / 6)) }
  each.map(l => l.map(x => if x == none { cap } else { calc.min(x, cap) }))
}

// Würfelaugen: Raster quer (v) und längs (u) zur Achse Ecke → Mitte.
#let pip-patterns = (
  ((0, 0),),
  ((-1, -1), (1, 1)),
  ((-1, -1), (0, 0), (1, 1)),
  ((-1, -1), (-1, 1), (1, -1), (1, 1)),
  ((-1, -1), (-1, 1), (0, 0), (1, -1), (1, 1)),
  ((-1, -1), (-1, 0), (-1, 1), (1, -1), (1, 0), (1, 1)),
)
#let pip-radius = 0.0125
#let pip-pitch = 0.042     // längs der Achse Ecke → Mitte
#let pip-across = 0.026    // quer dazu
#let pip-min = 0.06        // kleinster Radius auf dem Schnittbogen, in cm
#let pip-min-solution = 0.035 // kleinster Radius im Lösungsbild, in cm

/// Lage der Würfelaugen in einer Eckspitze (Anteile der Kantenlänge):
/// Mitte `d0` (Abstand von der Ecke), äußerste Grenze `far` der Spitze.
/// So gewählt, dass die Augen auch neben der Ecke gut 0,8 mm (bei 6 cm
/// Kante) von beiden Schnittkanten entfernt bleiben (0,5·u − 0,866·|v| − r)
/// und rundum Luft zum Rand der Spitze haben.
#let pip-frame(theme) = {
  let tr = tip-radius(theme)
  if theme.tip == "hexagon" { (d0: 0.14, far: tr * calc.cos(30deg)) }
  else if theme.tip == "ring" { (d0: 0.158, far: tr) }
  else { (d0: 0.15, far: tr) }
}

/// Wachstum des Augenrasters bei Kante `unit` (cm) und ob die Augen
/// gezeichnet werden. Augen nie kleiner als `pip-min`: das ganze Raster
/// wächst dann von der Ecke aus mit, höchstens bis an den Rand der Spitze.
/// Auf dem Schnittbogen bleiben sie immer; im Lösungsbild entfallen sie unter
/// 4 cm Kante oder wenn sie kleiner als `pip-min-solution` würden.
#let pip-layout(theme, unit, solution: false) = {
  let f = pip-frame(theme)
  let limit = (f.far - 0.004) / (f.d0 + pip-pitch + pip-radius)
  let want = calc.max(1, (if solution { pip-min-solution } else { pip-min }) / (pip-radius * unit))
  let grow = calc.min(want, limit)
  let visible = theme.pips and (not solution or (unit >= 4 and pip-radius * grow * unit >= pip-min-solution - 0.0005))
  (grow: grow, visible: visible, d0: f.d0)
}

/// Zeichnet ein Kärtchen mit den Ecken `pts` (in cm, gegen den Uhrzeigersinn).
/// `tint` ist die Füllfarbe des Kärtchens, `edge-tints` die Farben je Kante,
/// `sizes` die Schriftgröße je Kante und cm Kantenlänge (aus `fit-sizes`).
/// `solution`: Lösungsbild (dort entfallen zu kleine Würfelaugen).
#let draw-card(draw, pts, labels, unit, text-size, number: none, theme: themes.klar,
  tint: none, edge-tints: none, corners: false, corner-tints: none, sizes: none, solution: false) = {
  let c = (pts.map(p => p.at(0)).sum() / 3, pts.map(p => p.at(1)).sum() / 3)
  let toward(p, target, f) = (p.at(0) + (target.at(0) - p.at(0)) * f, p.at(1) + (target.at(1) - p.at(1)) * f)
  let fill = if type(theme.fill) == array or theme.fill in ("set", "tint", "ring", "parity", "single") { tint } else { theme.fill }
  let room = label-room(theme, corners, number: number != none)
  let mark = corner-mark(theme)
  // Punkt im örtlichen System der Kante i: x längs (Anteil), y nach innen (Anteil).
  let edge-frame(i) = {
    let p = pts.at(i)
    let q = pts.at(calc.rem(i + 1, 3))
    let (dx, dy) = (q.at(0) - p.at(0), q.at(1) - p.at(1))
    let length = calc.sqrt(dx * dx + dy * dy)
    let (nx, ny) = (-dy / length, dx / length)
    (at: (x, y) => (p.at(0) + dx * x + nx * y * unit, p.at(1) + dy * x + ny * y * unit), angle: calc.atan2(dx, dy))
  }

  draw.line(..pts, close: true, stroke: none, fill: fill)
  // Breite Leiste (ab 0,1): an jeder Kante über die ganze Länge, Eckmarken
  // und -spitzen liegen darüber. Schmale Leiste: nur an beschrifteten
  // Kanten, vor den Eckmarken und -spitzen abgeschnitten.
  let wide = theme.band != none and theme.band-depth >= 0.1
  let cut = if wide { 0 } else if corners == "wheel" { tip-radius(theme) } else if corners == true and mark != none { room.r } else { 0 }
  if theme.band != none {
    let d = theme.band-depth
    for i in range(3) {
      if labels.at(i) == none and not wide { continue }
      let paint = if theme.band == "edge" { edge-tints.at(i).lighten(60%) } else { theme.band }
      let e = edge-frame(i)
      let xi = calc.max(d * calc.sqrt(3), calc.sqrt(calc.max(cut * cut - d * d, 0)))
      draw.line((e.at)(cut, 0), (e.at)(1 - cut, 0), (e.at)(1 - xi, d), (e.at)(xi, d),
        close: true, stroke: none, fill: paint)
    }
  }
  if theme.inner != none {
    let f = theme.band-depth / 0.2887
    draw.line(..pts.map(p => toward(p, c, f)), close: true, stroke: theme.inner)
  }
  if corners == "wheel" and corner-tints != none {
    // Eckspitzen zur Selbstkontrolle: einfarbige Form (`theme.tip`), auf Wunsch mit Würfelaugen.
    let tr = tip-radius(theme)
    let pl = pip-layout(theme, unit, solution: solution)
    let (grow, show-pips, d0) = (pl.grow, pl.visible, pl.d0)
    let near = ring-hole
    let palette = wheel-palette(theme)
    for i in range(3) {
      let p = pts.at(i)
      let k = corner-tints.at(i)
      let (paint, ink) = (palette.colors.at(k), palette.pips.at(k))
      // Örtliches System: u zeigt von der Ecke zur Kärtchenmitte, die beiden
      // Kanten liegen bei ±30°. `polar(r, phi)` liefert einen Punkt darin.
      let (ux, uy) = (c.at(0) - p.at(0), c.at(1) - p.at(1))
      let len = calc.sqrt(ux * ux + uy * uy)
      let (ux, uy) = (ux / len, uy / len)
      let (vx, vy) = (-uy, ux)
      let base = calc.atan2(ux, uy)
      let polar(r, phi) = (p.at(0) + r * unit * calc.cos(base + phi), p.at(1) + r * unit * calc.sin(base + phi))
      let arc(r, from, to, n: 16) = range(n + 1).map(j => polar(r, from + (to - from) * j / n))
      let outline = if theme.tip == "hexagon" {
        (p, polar(tr, -30deg), polar(tr, 30deg))
      } else if theme.tip == "ring" {
        arc(near, -30deg, 30deg) + arc(tr, 30deg, -30deg)
      } else {
        (p,) + arc(tr, -30deg, 30deg)
      }
      // Weiße Fuge zwischen den Spitzen; sehr helle Töne bekommen statt
      // dessen eine Haarlinie, damit sie sich vom Weiß abheben.
      let te = theme.at("tip-edge", default: auto)
      let edge = if te != auto { te } else if lightness(paint) > 0.88 { 0.4pt + luma(62%) } else { 0.6pt + white }
      draw.line(..outline, close: true, stroke: edge, fill: paint)
      if not show-pips { continue }
      let q = (p.at(0) + ux * d0 * grow * unit, p.at(1) + uy * d0 * grow * unit)
      let (g, ga) = (pip-pitch * grow * unit, pip-across * grow * unit)
      for (gv, gu) in pip-patterns.at(k) {
        draw.circle((q.at(0) + vx * gv * ga + ux * gu * g, q.at(1) + vy * gv * ga + uy * gu * g),
          radius: pip-radius * grow * unit, stroke: none, fill: ink)
      }
    }
  } else if corners == true and mark == "arc" {
    // Eckmarke: feiner Bogen um die Ecke. Im Lösungsbild schließen sich die
    // sechs Bögen einer Ecke zu einem kleinen Kreis: richtig gelegt.
    for i in range(3) {
      let p = pts.at(i)
      let (ux, uy) = (c.at(0) - p.at(0), c.at(1) - p.at(1))
      let base = calc.atan2(ux, uy)
      draw.line(..range(13).map(j => {
        let phi = base - 30deg + 60deg * j / 12
        (p.at(0) + 0.075 * unit * calc.cos(phi), p.at(1) + 0.075 * unit * calc.sin(phi))
      }), stroke: (paint: theme.corner, thickness: 0.6pt, cap: "butt"))
    }
  } else if corners == true and mark == "kite" {
    // Eckmarke: zweifarbiger Drachen aus Ecke, Kante und Mittellinie. Richtig
    // gelegt ergeben die Drachen einer Ecke einen Stern.
    for i in range(3) {
      let p = pts.at(i)
      let a = toward(p, pts.at(calc.rem(i + 1, 3)), 0.12)
      let b = toward(p, pts.at(calc.rem(i + 2, 3)), 0.12)
      let m = toward(p, c, 0.32)
      draw.line(p, a, m, close: true, stroke: none, fill: theme.corner)
      draw.line(p, m, b, close: true, stroke: none, fill: theme.corner.lighten(35%))
    }
  } else if corners == true and mark == "dot" {
    // Eckmarke: Kreissektor; im Lösungsbild schließen sich die Sektoren einer
    // Ecke zu einem Kreis.
    for i in range(3) {
      let p = pts.at(i)
      let (ux, uy) = (c.at(0) - p.at(0), c.at(1) - p.at(1))
      let base = calc.atan2(ux, uy)
      draw.line(p, ..range(13).map(j => {
        let phi = base - 30deg + 60deg * j / 12
        (p.at(0) + 0.07 * unit * calc.cos(phi), p.at(1) + 0.07 * unit * calc.sin(phi))
      }), close: true, stroke: none, fill: theme.corner)
    }
  } else if corners == true and mark == "ticks" {
    // Eckmarke: kleine Messskala an beiden Kanten jeder Ecke (Striche alle
    // 0,02 der Kante, der mittlere länger).
    for i in range(3) {
      for (j, e) in ((i, 1), (calc.rem(i + 2, 3), -1)) {
        let f = edge-frame(j)
        for (n, s) in (0.04, 0.06, 0.08, 0.10, 0.12).enumerate() {
          let x = if e == 1 { s } else { 1 - s }
          let len = if n == 2 { 0.032 } else { 0.017 }
          draw.line((f.at)(x, 0), (f.at)(x, len), stroke: (paint: theme.corner, thickness: 0.5pt, cap: "butt"))
        }
      }
    }
  } else if corners == true and mark == "triangle" {
    // Eckmarke: kleines, flaches Dreieck, 0,6 mm vor der Ecke gekappt
    // (Spielraum beim Schneiden).
    let f0 = 0.06 / unit
    for i in range(3) {
      let p = pts.at(i)
      let (q1, q2) = (pts.at(calc.rem(i + 1, 3)), pts.at(calc.rem(i + 2, 3)))
      draw.line(toward(p, q1, f0), toward(p, q1, 0.06), toward(p, q2, 0.06), toward(p, q2, f0),
        close: true, stroke: none, fill: theme.corner)
    }
  }
  draw.line(..pts, close: true, stroke: theme.stroke, fill: none)

  for i in range(3) {
    let label = labels.at(i)
    if label == none { continue }
    let e = edge-frame(i)
    let size = if sizes == none { text-size } else { sizes.at(i) * unit }
    let shown = label-body(label, size, theme)
    let h = measure(shown).height / 1cm
    if theme.label == "field" {
      // Fast weiße Fläche ohne Rand im Keil der Kante, bis an die Eckmarken;
      // kleine runde Ecken (eingerückter Umriss, runder Strich gleicher Farbe).
      let rad = 1.5pt / 1cm / unit
      let (yb, yt) = (0.03 + rad, calc.min(room.top, 0.25) - rad)
      let side(y) = calc.max(label-wedge / 2 * y + 0.03 + 2 * rad,
        calc.sqrt(calc.max(room.r * room.r - y * y, 0)) + 0.03 + rad)
      let steps = range(9).map(j => yb + (yt - yb) * j / 8)
      let outline = steps.map(y => (e.at)(side(y), y)) + steps.rev().map(y => (e.at)(1 - side(y), y))
      let paint = theme.at("field", default: field-color)
      let fs = theme.at("field-stroke", default: none)
      if fs != none {
        let fs = stroke(fs)
        if fs.dash == auto or fs.dash == none {
          // Rand: breiter runder Strich in der Randfarbe, darüber die Fläche.
          let w = if fs.thickness == auto { 0.4pt } else { fs.thickness }
          draw.line(..outline, close: true, fill: none,
            stroke: (paint: fs.paint, thickness: 3pt + 2 * w, join: "round"))
        }
      }
      draw.line(..outline, close: true, fill: paint, stroke: (paint: paint, thickness: 3pt, join: "round"))
      if fs != none and stroke(fs).dash not in (auto, none) {
        // Gestrichelt: Umriss um den halben runden Strich nach außen.
        let o = rad * 1.0
        let side2(y) = side(y) - o
        let (yb2, yt2) = (yb - o, yt + o)
        let steps2 = range(9).map(j => yb2 + (yt2 - yb2) * j / 8)
        let outer = steps2.map(y => (e.at)(side2(y), y)) + steps2.rev().map(y => (e.at)(1 - side2(y), y))
        draw.line(..outer, close: true, fill: none, stroke: fs)
      }
    }
    draw.content((e.at)(0.5, room.y0 + 0.002 + h / unit / 2), anchor: "center", angle: e.angle, shown)
  }
  if number != none {
    // Nummer nur für die Lehrkraft: klein, grau, ohne Rahmen (labor:
    // Monospace mit T und zwei Stellen).
    let shown = if theme.at("code", default: none) != none {
      "T" + (if number < 10 { "0" } else { "" }) + str(number)
    } else { str(number) }
    draw.content(c, text(font: code-font(theme), size: calc.max(6.5pt, calc.min(8pt, 0.045 * unit * 1cm)),
      fill: luma(40%), number-type: "lining", number-width: "tabular", top-edge: "bounds", bottom-edge: "bounds", shown))
  }
}

// ---------------------------------------------------------------------------
// Schneideplotter: Passermarken im Silhouette-Format und Schnittlinien
// ---------------------------------------------------------------------------
//
// Die Marken folgen Silhouette Studio (Typ „Cameo, Portrait“): links oben ein
// gefülltes Quadrat, rechts oben und links unten je ein Winkel. Die Winkel
// sind 0,5 mm stark, wie es der Plotter bei der Suche erwartet (TB53,10);
// dünnere Linien fand er unter Laminierfolie nicht zuverlässig. Der Abstand der
// Marken vom Blattrand ist `mark-inset`; um die Marken herum bleibt ein
// Schutzraum frei, deshalb setzt der Schnittbogen dann den Rand `mark-margin`.

#let mark-inset = 10mm
#let mark-square = 5mm
#let mark-line = 20mm
#let mark-thickness = 0.5mm
#let mark-margin = 30mm
// Prüfkreuz: Mitte so weit von der rechten unteren Blattecke. Der Plotter
// fährt nach der Markensuche dorthin; steht das Messer genau darüber, stimmt
// die Lage.
#let check-inset = 20mm
#let check-size = 8mm

/// Lage der Marken in mm, wie sie der Plotter für die Suche braucht.
#let mark-geometry(width, height) = {
  let mm(l) = calc.round(l / 1mm, digits: 3)
  (
    style: "silhouette",
    left: mm(mark-inset),
    top: mm(mark-inset),
    width: mm(width - 2 * mark-inset),
    length: mm(height - 2 * mark-inset),
    square: mm(mark-square),
    line: mm(mark-line),
    thickness: mm(mark-thickness),
  )
}

/// Mitte des Prüfkreuzes in mm, gemessen von der Marke links oben.
#let check-point(width, height) = {
  let mm(l) = calc.round(l / 1mm, digits: 3)
  (mm(width - check-inset - mark-inset), mm(height - check-inset - mark-inset))
}

/// Zeichnet die Marken für eine Seite der Größe `width` × `height`.
#let mark-drawing(width, height) = {
  let ink = black
  let s = mark-thickness
  let right = width - mark-inset
  let bottom = height - mark-inset
  // Linien als gefüllte Rechtecke: so sitzen die Kanten genau.
  let bar(x, y, w, h) = place(top + left, dx: x, dy: y, rect(width: w, height: h, fill: ink, stroke: none))
  bar(mark-inset, mark-inset, mark-square, mark-square)
  // rechts oben: Arme nach links und nach unten
  bar(right - mark-line, mark-inset, mark-line, s)
  bar(right - s, mark-inset, s, mark-line)
  // links unten: Arme nach rechts und nach oben
  bar(mark-inset, bottom - s, mark-line, s)
  bar(mark-inset, bottom - mark-line, s, mark-line)
  // Prüfkreuz mit Ring
  let (cx, cy) = (width - check-inset, height - check-inset)
  let t = 0.2mm
  bar(cx - check-size / 2, cy - t / 2, check-size, t)
  bar(cx - t / 2, cy - check-size / 2, t, check-size)
  place(top + left, dx: cx - check-size * 0.3, dy: cy - check-size * 0.3,
    circle(radius: check-size * 0.3, stroke: t + ink, fill: none))
}

/// Kanten aller Kärtchen, gemeinsame Kanten nur einmal. `cards` enthält je
/// Kärtchen seine Ecken (in cm, Dreieck oder Rechteck). Liefert Strecken
/// `((x1, y1), (x2, y2))`.
#let cut-segments(cards) = {
  let key(p) = str(calc.round(p.at(0), digits: 3)) + "," + str(calc.round(p.at(1), digits: 3))
  let seen = (:)
  let result = ()
  for pts in cards {
    for i in range(pts.len()) {
      let p = pts.at(i)
      let q = pts.at(calc.rem(i + 1, pts.len()))
      let (k1, k2) = (key(p), key(q))
      let k = if k1 < k2 { k1 + ";" + k2 } else { k2 + ";" + k1 }
      if k not in seen {
        seen.insert(k, true)
        result.push((p, q))
      }
    }
  }
  result
}

/// SVG-Schnittvorlage eines `cut-data`-Eintrags: Blatt in mm, Marken
/// schwarz, Schnittlinien rot.
#let cut-svg(d) = {
  let (w, h) = d.page-size
  let m = d.marks
  let n(x) = str(calc.round(x, digits: 2))
  let rect(x, y, rw, rh) = "<rect x=\"" + n(x) + "\" y=\"" + n(y) + "\" width=\"" + n(rw) + "\" height=\"" + n(rh) + "\" fill=\"#000000\"/>"
  let (r, b, s, l) = (m.left + m.width, m.top + m.length, m.thickness, m.line)
  let marks = (
    rect(m.left, m.top, m.square, m.square),
    rect(r - l, m.top, l, s), rect(r - s, m.top, s, l),
    rect(m.left, b - s, l, s), rect(m.left, b - l, s, l),
  ).join("\n")
  let check = if "check" in d {
    let (cx, cy) = (d.check.at(0) + m.left, d.check.at(1) + m.top)
    "\n" + rect(cx - 4, cy - 0.1, 8, 0.2) + "\n" + rect(cx - 0.1, cy - 4, 0.2, 8)
      + "\n<circle cx=\"" + n(cx) + "\" cy=\"" + n(cy) + "\" r=\"2.4\" fill=\"none\" stroke=\"#000000\" stroke-width=\"0.2\"/>"
  } else { "" }
  // Je Kärtchen ein geschlossener Umriss; gemeinsame Kanten entdoppelt der
  // Leser. Ohne Umrisse die einzelnen Strecken.
  let outlines = if "pieces" in d { d.pieces.map(p => p + (p.first(),)) } else { d.paths }
  let lines = outlines.map(p => "<polyline points=\"" + p.map(((x, y)) => n(x + m.left) + "," + n(y + m.top)).join(" ")
    + "\" fill=\"none\" stroke=\"#ff0000\" stroke-width=\"0.25\"/>").join("\n")
  ("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + n(w) + "mm\" height=\"" + n(h) + "mm\" viewBox=\"0 0 "
    + n(w) + " " + n(h) + "\">\n<g id=\"regmarks\">\n" + marks + check + "\n</g>\n<g id=\"cut\">\n" + lines + "\n</g>\n</svg>\n")
}

// ---------------------------------------------------------------------------
// Kopf, Fußnote, Schriftzug
// ---------------------------------------------------------------------------

/// Harter, versetzter Schatten (Theme `kontur`): `body` mit einer Fläche in
/// `paint` dahinter, um `d` nach rechts unten verschoben.
#let shadow-box(body, paint, d: 3pt) = {
  if paint == none { return body }
  box(inset: (right: d, bottom: d), {
    place(top + left, dx: d, dy: d, box(fill: paint, hide(body)))
    body
  })
}

/// Klebeband mit gezackten Enden (Theme `skizze`).
#let tape-strip(width, height, paint) = {
  let z = 6
  let dy = height / z
  let left-side = range(z + 1).map(i => (if calc.even(i) { 0pt } else { 3pt }, i * dy))
  let right-side = range(z + 1).rev().map(i => (width - (if calc.even(i) { 0pt } else { 3pt }), i * dy))
  polygon(fill: paint, stroke: none, ..left-side, ..right-side)
}

/// Messskala: Striche alle 3 mm, jeder fünfte länger (Theme `labor`).
#let tick-scale(paint: luma(63%)) = layout(room => box(width: 100%, height: 4pt, {
  for i in range(0, int(room.width / 3mm) + 1) {
    place(left + top, dx: i * 3mm, line(start: (0pt, 0pt),
      end: (0pt, if calc.rem(i, 5) == 0 { 4pt } else { 2pt }), stroke: 0.4pt + paint))
  }
}))

/// Kopf über Lösung und Schnittbogen. Der Titel ist das, woran die Lehrkraft
/// den Satz erkennt; Spiel und Art des Blatts stehen klein dabei. Ohne Titel
/// steht der Spielname an seiner Stelle. Die Gestalt wählt `theme.head`:
///   "rule"   – Titel links, rechts Spiel und Art in Versalien, feine Linie
///   "band"   – Titelband in der Akzentfarbe mit hellen Kreisen, Art im weißen Kästchen
///   "tape"   – Titel in Handschrift auf Klebeband, Art auf einem schrägen Zettel
///   "frame"  – Rahmen mit Kennzeile in Monospace, Art als Marke, Messskala darunter
///   "poster" – Kennung im schwarzen Kasten, Titel in Versalien, Art im
///              Schattenkasten, dicke Linie
#let sheet-head(game, caption, title, theme) = {
  let accent = theme.at("accent", default: accent-color)
  let style = theme.at("head", default: "rule")
  let chrome = chrome-font(theme)
  let display = display-font(theme)
  let shown = if title != none { title } else { game }
  set text(font: chrome, number-type: "lining", number-width: "tabular")
  set par(justify: false)
  if style == "band" {
    block(below: 5mm, width: 100%, fill: accent, radius: 7pt, clip: true, inset: (x: 0.5cm, y: 0.38cm), {
      place(top + right, dx: 1.6cm, dy: -1.9cm, circle(radius: 2.2cm, fill: white.transparentize(86%)))
      place(bottom + right, dx: -3.6cm, dy: 1.1cm, circle(radius: 1cm, fill: white.transparentize(89%)))
      place(top + left, dx: 40%, dy: -0.9cm, circle(radius: 0.55cm, fill: white.transparentize(90%)))
      grid(columns: (1fr, auto), column-gutter: 1em, align: (left + bottom, right + bottom),
        stack(spacing: 0.45em,
          text(size: 7.5pt, weight: 600, tracking: 0.1em, fill: white.transparentize(15%), upper(game)),
          text(font: display, size: 17pt, weight: 700, fill: white, shown)),
        box(fill: white, radius: 0.35em, inset: (x: 0.65em, y: 0.45em),
          text(size: 9.5pt, weight: 700, fill: accent, top-edge: "cap-height", bottom-edge: "baseline", caption)))
    })
  } else if style == "tape" {
    let ink = theme.at("ink", default: ink-color)
    block(below: 5mm, width: 100%, grid(columns: (1fr, auto), column-gutter: 1.2em, align: (left + bottom, right + bottom),
      stack(spacing: 0.6em,
        text(font: display, size: 9pt, weight: 500, fill: accent, game),
        context {
          let t = text(font: display, size: 17pt, weight: 700, fill: ink, shown)
          let m = measure(t)
          box(rotate(-1deg, reflow: true, box({
            place(top + left, dx: -0.5em, dy: 0.22em, tape-strip(m.width + 1em, m.height + 0.3em, accent.lighten(74%)))
            t
          })))
        }),
      rotate(3deg, reflow: true, box(fill: accent, inset: (x: 0.75em, top: 0.6em, bottom: 0.5em),
        text(font: display, size: 10.5pt, weight: 700, fill: white, caption)))))
  } else if style == "frame" {
    let night = theme.at("ink", default: ink-color)
    let code = code-font(theme)
    block(below: 5mm, width: 100%, {
      block(width: 100%, stroke: 0.9pt + night, radius: 3pt, inset: (x: 11pt, y: 8pt),
        grid(columns: (1fr, auto), column-gutter: 1em, align: (left + horizon, right + horizon),
          stack(spacing: 0.5em,
            text(font: code, size: 7pt, weight: 500, tracking: 0.04em, fill: accent, upper(game + " / " + caption)),
            text(font: display, size: 15pt, weight: 600, fill: night, shown)),
          box(fill: accent, radius: 2pt, inset: (x: 0.5em, y: 0.4em),
            text(font: code, size: 8.5pt, weight: 600, fill: white, top-edge: "cap-height", bottom-edge: "baseline",
              upper(caption)))))
      v(-0.3em)
      tick-scale()
    })
  } else if style == "poster" {
    let black = luma(12%)
    let shadow = theme.at("shadow", default: none)
    let shadow = if shadow == none { accent } else { shadow }
    block(below: 5mm, width: 100%, {
      grid(columns: (1fr, auto), column-gutter: 1em, align: (left + bottom, right + bottom),
        stack(spacing: 0.6em,
          box(fill: black, inset: (x: 0.5em, y: 0.38em), text(size: 7pt, weight: 700, tracking: 0.12em, fill: white,
            top-edge: "cap-height", bottom-edge: "baseline", upper(game))),
          text(font: display, size: 19pt, weight: 700, fill: black, top-edge: "cap-height", upper(shown))),
        shadow-box(box(fill: white, stroke: 1.4pt + black, inset: (x: 0.6em, y: 0.45em),
          text(font: display, size: 9.5pt, weight: 700, tracking: 0.04em, fill: black,
            top-edge: "cap-height", bottom-edge: "baseline", upper(caption))), shadow, d: 3pt))
      v(0.5em, weak: false)
      line(length: 100%, stroke: 3pt + black)
    })
  } else {
    block(below: 4mm, {
      grid(columns: (1fr, auto), align: (left + bottom, right + bottom), column-gutter: 1em,
        text(font: display, size: 13pt, weight: "semibold", fill: theme.at("ink", default: ink-color), shown),
        text(size: 7.5pt, tracking: 0.1em, fill: luma(35%), {
          text(weight: "semibold", fill: accent, upper(game))
          h(2em)
          upper(caption)
        }),
      )
      v(2mm, weak: false)
      line(length: 100%, stroke: 0.4pt + luma(68%))
    })
  }
}

/// Fußzeile unter dem Lösungsbild: kleine Versalien als Etikett, dann der Text.
#let sheet-note(label, body, theme: (:)) = block(above: 4mm, {
  let accent = theme.at("accent", default: luma(40%))
  set text(font: chrome-font(theme), size: 9pt, fill: ink-color, number-type: "lining")
  line(length: 100%, stroke: 0.4pt + luma(70%))
  v(1.5mm)
  text(size: 7pt, weight: "semibold", tracking: 0.1em, fill: if mono(theme) { luma(40%) } else { accent }, upper(label))
  h(1em)
  body
})

/// Buchstabenfarben bunter Schriftzüge.
#let rainbow-inks(theme) = {
  if theme.at("wordmark", default: none) == "hand" and type(theme.at("wheel", default: auto)) == array {
    theme.wheel.filter(c => lightness(c) < 0.85).map(c => c.darken(12%))
  } else { ring-colors.map(c => c.darken(22%)) }
}

/// Schriftzug der Rückseite in der Gestalt `theme.wordmark` (siehe `themes`).
#let wordmark(word, theme, size) = {
  let style = theme.at("wordmark", default: "mono")
  let accent = theme.at("accent", default: accent-color)
  let ink = theme.at("ink", default: ink-color)
  let letters = word.clusters()
  let display = display-font(theme)
  let cap = (top-edge: "cap-height", bottom-edge: "baseline")
  if style == "rainbow" or style == "hand" {
    let inks = rainbow-inks(theme)
    text(font: display, weight: "bold", size: size, tracking: if style == "hand" { 0.02em } else { 0.05em }, ..cap,
      letters.enumerate().map(((i, ch)) => text(fill: inks.at(calc.rem(i, inks.len())), ch)).join())
  } else if style == "accent" {
    text(font: display, weight: "bold", size: size, tracking: 0.1em, fill: accent, ..cap, word)
  } else if style == "tile" {
    box(fill: accent, radius: 0.3em, inset: (x: 0.45em, y: 0.32em),
      text(font: display, weight: "bold", size: size, tracking: 0.08em, fill: white, ..cap, word))
  } else if style == "code" {
    text(font: code-font(theme), weight: 600, size: size * 0.92, ..cap, {
      text(fill: accent, "//")
      h(0.35em)
      text(fill: ink, tracking: 0.04em, word)
    })
  } else if style == "poster" {
    text(font: display, weight: "bold", size: size, tracking: 0.05em, fill: luma(12%), ..cap, word)
  } else {
    text(font: chrome-font(theme), weight: "semibold", size: size, tracking: 0.22em, fill: black, ..cap, {
      word
      h(-0.22em)
    })
  }
}

/// Grund, Konfettitöne, Formen und Raster der Rückseite (`theme.back-style`).
/// `shapes: auto` heißt: die Form des Spiels (Dreiecke, Dominosteine).
#let back-palette(theme) = {
  let style = theme.at("back-style", default: if mono(theme) { "mono" } else { "pastel" })
  let accent = theme.at("accent", default: accent-color)
  let ink = theme.at("ink", default: ink-color)
  if style == "mono" { (ground: white, colors: (luma(80%), luma(88%)), shapes: auto, grid: none) }
  else if style == "tint" {
    (ground: accent.lighten(91%), colors: (accent.lighten(55%), accent.lighten(72%)), shapes: auto, grid: none)
  } else if style == "circles" {
    (ground: accent.lighten(90%), colors: (accent.lighten(20%), accent.lighten(48%), accent.lighten(70%), white),
      shapes: ("circle",), grid: none)
  } else if style == "crayon" {
    let w = theme.at("wheel", default: auto)
    let base = if type(w) == array { w } else { wheel-colors }
    (ground: rgb("#fff7e8"), colors: base.filter(c => lightness(c) < 0.85).map(c => c.lighten(25%)),
      shapes: ("triangle", "blob", "star"), grid: none)
  } else if style == "grid" {
    (ground: white, colors: (accent.lighten(30%), accent.lighten(58%), ink.lighten(55%)),
      shapes: ("square", "plus"), grid: (minor: accent.lighten(86%), major: accent.lighten(68%)))
  } else if style == "poster" {
    (ground: white, colors: (luma(12%), accent, accent.lighten(45%)), shapes: auto, grid: none)
  } else {
    (ground: rgb("#fbf3ea"), colors: ring-colors.map(c => c.lighten(55%)), shapes: auto, grid: none)
  }
}

// ---------------------------------------------------------------------------
// Rückseite
// ---------------------------------------------------------------------------

/// Zugabe der Rückseitenfläche um die Kärtchen, in cm. Ein versetzter
/// Duplexdruck lässt so keine weißen Ränder an den Kärtchen.
#let back-bleed = 0.4

/// Mindestabstand der Rückseiten-Etiketten zu den Schnittkanten, in cm
/// (Duplex verrutscht um bis zu 1,5 mm).
#let back-safe = 0.3

/// Rand im Grundton um jedes Etikett, in dem kein Konfetti liegt, in cm.
#let back-margin = 0.15

// Umriss einer Reihe (konvex, gegen den Uhrzeigersinn) um `d` nach außen
// versetzt: jede Kante parallel verschieben, Nachbarkanten schneiden.
#let offset-outline(pts, d) = {
  let n = pts.len()
  let lines = range(n).map(i => {
    let (p, q) = (pts.at(i), pts.at(calc.rem(i + 1, n)))
    let (dx, dy) = (q.at(0) - p.at(0), q.at(1) - p.at(1))
    let l = calc.sqrt(dx * dx + dy * dy)
    let (nx, ny) = (dy / l * d, -dx / l * d) // nach außen (rechts der Kante)
    ((p.at(0) + nx, p.at(1) + ny), (dx, dy))
  })
  range(n).map(i => {
    let ((p1, d1), (p2, d2)) = (lines.at(calc.rem(i + n - 1, n)), lines.at(i))
    let den = d1.at(0) * d2.at(1) - d1.at(1) * d2.at(0)
    let t = ((p2.at(0) - p1.at(0)) * d2.at(1) - (p2.at(1) - p1.at(1)) * d2.at(0)) / den
    (p1.at(0) + t * d1.at(0), p1.at(1) + t * d1.at(1))
  })
}

#let inside-convex(p, pts) = {
  let n = pts.len()
  range(n).all(i => {
    let (a, b) = (pts.at(i), pts.at(calc.rem(i + 1, n)))
    (b.at(0) - a.at(0)) * (p.at(1) - a.at(1)) - (b.at(1) - a.at(1)) * (p.at(0) - a.at(0)) >= 0
  })
}

// Abstand eines Punkts zu einem Rechteck (x0, y0, x1, y1); 0 innen.
#let rect-distance((x, y), (x0, y0, x1, y1)) = {
  let dx = calc.max(x0 - x, 0, x - x1)
  let dy = calc.max(y0 - y, 0, y - y1)
  calc.sqrt(dx * dx + dy * dy)
}

// Konfetti: Versuche je cm² und Mindestabstand zweier Stücke (über die
// Umkreise hinaus), in cm. Stücke berühren sich so nie.
#let confetti-tries = 6
#let confetti-gap = 0.05

/// Lage des Etiketts `shown` auf der Rückseite eines Dreiecks: so groß wie
/// möglich (bis 1,9-fach) an der breiten Seite, mit `back-safe` Abstand zu
/// allen Kanten. Liefert Ankerpunkt, Anker, Abstand, Maßstab und das belegte
/// Rechteck (in cm). Braucht `context`.
#let back-label-layout(pts, unit, shown) = {
  let c = (pts.map(p => p.at(0)).sum() / 3, pts.map(p => p.at(1)).sum() / 3)
  let up = pts.filter(p => p.at(1) < c.at(1)).len() == 2
  let H = unit * height
  let m = back-safe
  let ys = pts.map(p => p.at(1))
  let wide = if up { calc.min(..ys) } else { calc.max(..ys) }
  let size = measure(shown)
  let (w, h) = (size.width / 1cm, size.height / 1cm)
  let gap = m + 0.06 * unit
  let f = calc.min(0.9 * (unit * (1 - gap / H) - 2 * m / calc.sin(60deg)) / (w + unit * h / H), 1.9)
  let (sw, sh) = (w * f, h * f)
  let rect = if up { (c.at(0) - sw / 2, wide + gap, c.at(0) + sw / 2, wide + gap + sh) }
    else { (c.at(0) - sw / 2, wide - gap - sh, c.at(0) + sw / 2, wide - gap) }
  (at: (c.at(0), wide), anchor: if up { "south" } else { "north" }, up: up, gap: gap, scale: f, rect: rect)
}

/// Sperrfläche fürs Konfetti: das Etikett samt Rand `back-margin`.
#let back-label-zone(rect) = {
  let (x0, y0, x1, y1) = rect
  (x0 - back-margin, y0 - back-margin, x1 + back-margin, y1 + back-margin)
}

/// Umriss der Rückseitenfläche einer Reihe: die Kärtchen plus `back-bleed`.
#let back-row-outline(cards) = {
  let all = cards.flatten().chunks(2)
  let y0 = calc.min(..all.map(p => p.at(1)))
  let y1 = calc.max(..all.map(p => p.at(1)))
  let low = all.filter(p => calc.abs(p.at(1) - y0) < 0.001).map(p => p.at(0))
  let high = all.filter(p => calc.abs(p.at(1) - y1) < 0.001).map(p => p.at(0))
  // Eine Reihe aus nur einem Kärtchen ist ein Dreieck: doppelte Ecken weg.
  let pts = ((calc.min(..low), y0), (calc.max(..low), y0), (calc.max(..high), y1), (calc.min(..high), y1))
  let pts = pts.enumerate().filter(((i, p)) => {
    let q = pts.at(calc.rem(i + 1, 4))
    calc.abs(p.at(0) - q.at(0)) + calc.abs(p.at(1) - q.at(1)) > 0.0001
  }).map(((i, p)) => p)
  offset-outline(pts, back-bleed)
}

/// Konfetti der Rückseite: kleine Formen in `colors` innerhalb des konvexen
/// Umrisses `outline` (y-Bereich `ys`), nach einer Regel statt wahllos:
/// Dreiecke nur in den beiden Lagen des Trimino-Gitters (`"triangle"`), kleine
/// Dominosteine 2 : 1 mit weißer Mittellinie nur waagerecht oder senkrecht
/// (`"tile"`), dazu Kreise, Quadrate, Kreuze, Sterne und Kleckse (`"circle"`,
/// `"square"`, `"plus"`, `"star"`, `"blob"`), je drei feste Größen. `shape`
/// ist eine Form oder ein Array, aus dem jedes Stück eine zieht. Ein Stück,
/// das einem anderen zu nahe käme, entfällt (keine Klumpen). `avoid`:
/// Rechtecke `(x0, y0, x1, y1)`, die kein Stück berührt (die Etiketten samt
/// Rand).
#let draw-confetti(draw, outline, seed, colors, ys, shape: "triangle", avoid: ()) = {
  // Ein Umriss oder eine Liste von Umrissen (je Reihe); ein Stück muss ganz
  // in einem von ihnen liegen.
  let outlines = if type(outline.at(0).at(0)) == array { outline } else { (outline,) }
  let xs = outlines.flatten().chunks(2).map(p => p.at(0))
  let (x-lo, x-hi) = (calc.min(..xs), calc.max(..xs))
  let (y-lo, y-hi) = ys
  let shapes = if type(shape) == array { shape } else { (shape,) }
  let r = seed
  let n = int((x-hi - x-lo) * (y-hi - y-lo) * confetti-tries)
  let placed = ()
  for k in range(n) {
    r = next-random(r)
    let x = x-lo + calc.rem(calc.quo(r, 7), 10000) / 10000 * (x-hi - x-lo)
    r = next-random(r)
    let y = y-lo + calc.rem(calc.quo(r, 7), 10000) / 10000 * (y-hi - y-lo)
    r = next-random(r)
    let pick = calc.rem(calc.quo(r, 65536), 3)
    r = next-random(r)
    let flip = calc.even(calc.quo(r, 65536))
    r = next-random(r)
    let paint = colors.at(calc.rem(calc.quo(r, 65536), colors.len()))
    r = next-random(r)
    let kind = shapes.at(calc.rem(calc.quo(r, 65536), shapes.len()))
    r = next-random(r)
    let phase = calc.rem(calc.quo(r, 7), 360) * 1deg
    let tile = kind in ("tile", "domino")
    let size = (if tile { (0.15, 0.22, 0.32) } else { (0.16, 0.24, 0.34) }).at(pick)
    let ring(m, f) = range(m).map(i => {
      let phi = phase + i * 360deg / m
      let rr = f(i)
      (x + rr * calc.cos(phi), y + rr * calc.sin(phi))
    })
    // Ecken (für die Lage), Umkreisradius, gezeichnete Form
    let (corners, radius) = if tile {
      let (a, b) = (size / 2, size / 4)
      (((-a, -b), (a, -b), (a, b), (-a, b)).map(((u, v)) => if flip { (x + v, y + u) } else { (x + u, y + v) }),
        calc.sqrt(a * a + b * b))
    } else if kind == "circle" {
      let rr = size * 0.55
      (range(10).map(i => (x + rr * calc.cos(i * 36deg), y + rr * calc.sin(i * 36deg))), rr)
    } else if kind == "square" {
      let a = size * 0.42
      let pts = if flip { ((-a, -a), (a, -a), (a, a), (-a, a)) }
        else { ((0, -a * 1.3), (a * 1.3, 0), (0, a * 1.3), (-a * 1.3, 0)) }
      (pts.map(((u, v)) => (x + u, y + v)), a * 1.42)
    } else if kind == "plus" {
      let (a, b) = (size * 0.55, size * 0.18)
      (((-b, -a), (b, -a), (b, -b), (a, -b), (a, b), (b, b), (b, a), (-b, a), (-b, b), (-a, b), (-a, -b), (-b, -b))
        .map(((u, v)) => (x + u, y + v)), a * 1.06)
    } else if kind == "star" {
      let (a, b) = (size * 0.62, size * 0.26)
      (ring(10, i => if calc.even(i) { a } else { b }), a)
    } else if kind == "blob" {
      let a = size * 0.5
      (ring(12, i => a * (1 + 0.16 * calc.sin(i * 90deg + phase))), a * 1.16)
    } else {
      let turn = if flip { 90deg } else { 270deg }
      (range(3).map(i => (x + size * calc.cos(turn + i * 120deg), y + size * calc.sin(turn + i * 120deg))), size)
    }
    if not avoid.all(z => rect-distance((x, y), z) > radius) { continue }
    if not outlines.any(o => corners.all(p => inside-convex(p, o))) { continue }
    let near = placed.any(((px, py, pr)) => {
      let (dx, dy) = (px - x, py - y)
      calc.sqrt(dx * dx + dy * dy) < pr + radius + confetti-gap
    })
    if near { continue }
    placed.push((x, y, radius))
    if kind == "circle" {
      draw.circle((x, y), radius: radius, stroke: none, fill: paint)
    } else if kind == "blob" {
      draw.catmull(..corners, close: true, stroke: none, fill: paint)
    } else {
      draw.line(..corners, close: true, stroke: none, fill: paint)
    }
    if tile {
      let m1 = ((corners.at(0).at(0) + corners.at(1).at(0)) / 2, (corners.at(0).at(1) + corners.at(1).at(1)) / 2)
      let m2 = ((corners.at(2).at(0) + corners.at(3).at(0)) / 2, (corners.at(2).at(1) + corners.at(3).at(1)) / 2)
      draw.line(m1, m2, stroke: 0.3pt + white)
    }
  }
}

/// Formen des Konfettis: aus dem Theme oder die des Spiels.
#let confetti-shapes(theme, game) = {
  let s = back-palette(theme).shapes
  if s != auto { s } else if game == "domino" { ("tile",) } else { ("triangle",) }
}

// Schnittpunkte einer senkrechten (axis 0) oder waagerechten (axis 1)
// Geraden bei `v` mit einem konvexen Umriss: (von, bis) oder none.
#let clip-span(pts, axis, v) = {
  let other = 1 - axis
  let hits = ()
  let n = pts.len()
  for i in range(n) {
    let (p, q) = (pts.at(i), pts.at(calc.rem(i + 1, n)))
    let (a, b) = (p.at(axis), q.at(axis))
    if (a - v) * (b - v) <= 0 and a != b {
      let t = (v - a) / (b - a)
      hits.push(p.at(other) + t * (q.at(other) - p.at(other)))
    }
  }
  if hits.len() < 2 { none } else { (calc.min(..hits), calc.max(..hits)) }
}

/// Grund der Rückseite in den Umrissen `outlines`, bei `back-style: "grid"`
/// mit Millimeterpapier (fein alle 2,5 mm, kräftiger alle 1 cm).
#let draw-back-paper(draw, outlines, theme) = {
  let pal = back-palette(theme)
  for o in outlines { draw.line(..o, close: true, stroke: none, fill: pal.ground) }
  if pal.grid == none { return }
  let all = outlines.flatten().chunks(2)
  let (x0, x1) = (calc.min(..all.map(p => p.at(0))), calc.max(..all.map(p => p.at(0))))
  let (y0, y1) = (calc.min(..all.map(p => p.at(1))), calc.max(..all.map(p => p.at(1))))
  for major in (false, true) {
    let paint = if major { pal.grid.major } else { pal.grid.minor }
    let st = (paint: paint, thickness: if major { 0.45pt } else { 0.25pt })
    for axis in (0, 1) {
      let (lo, hi) = if axis == 0 { (x0, x1) } else { (y0, y1) }
      for k in range(int(calc.floor(lo * 4)), int(calc.ceil(hi * 4)) + 1) {
        if calc.rem(k, 4) == 0 != major { continue }
        let v = k / 4
        for o in outlines {
          let span = clip-span(o, axis, v)
          if span == none { continue }
          let (a, b) = span
          if axis == 0 { draw.line((v, a), (v, b), stroke: st) } else { draw.line((a, v), (b, v), stroke: st) }
        }
      }
    }
  }
}

/// Rückseitenfläche aller Reihen: erst der Grund jeder Reihe, dann das
/// Konfetti über alle Reihen in einem Zug. Die Flächen benachbarter Reihen
/// überlappen um `back-bleed`; so verdeckt keine Reihe das Konfetti der
/// vorigen, und kein Stück wird an einer Reihengrenze abgeschnitten.
/// Nicht unter den Etiketten (`zones`).
#let draw-back-ground(draw, rows, seed, theme, zones: ()) = {
  let pal = back-palette(theme)
  let outlines = rows.map(back-row-outline)
  draw-back-paper(draw, outlines, theme)
  let ys = outlines.flatten().chunks(2).map(p => p.at(1))
  draw-confetti(draw, outlines, seed * 48271, pal.colors, (calc.min(..ys), calc.max(..ys)), avoid: zones,
    shape: confetti-shapes(theme, "trimino"))
}

/// Etikett der Rückseite: Fläche nach `theme.wordmark` (weiß, mit Haarlinie,
/// gestrichelt oder im Schattenkasten); darin Schriftzug, feine Linie, Thema,
/// Nummer. Mit `letter` groß der Buchstabe des Lösungsworts, ein Strich
/// darunter, klein Schriftzug und Nummer.
#let back-card-label(word, theme, size, below: none, number: none, letter: none) = {
  let accent = theme.at("accent", default: accent-color)
  let ink = theme.at("ink", default: ink-color)
  let style = theme.at("wordmark", default: "mono")
  let num = if number != none {
    text(font: code-font(theme), size: calc.max(7pt, size * 0.68), fill: luma(40%), number-type: "lining",
      number-width: "tabular", number)
  }
  let (stroke, radius) = if style == "rainbow" { (none, 0.5em) }
    else if style == "accent" { (0.6pt + accent.lighten(35%), 0.4em) }
    else if style == "tile" { (none, 0.6em) }
    else if style == "hand" { ((paint: accent.lighten(15%), thickness: 0.8pt, dash: (2.2pt, 1.6pt)), 0.8em) }
    else if style == "code" { (0.6pt + ink, 2pt) }
    else if style == "poster" { (1.3pt + luma(12%), 0pt) }
    else { (0.4pt + luma(70%), 1.5pt) }
  let body = box(fill: white, stroke: stroke, radius: radius, inset: (x: 0.6em, y: 0.5em), {
    set text(font: chrome-font(theme), size: size)
    set align(center)
    if letter != none {
      // Großer Buchstabe des Lösungsworts: Serifen-I (ss02); der Strich
      // darunter zeigt, wo unten ist (I, N, Z, S).
      let big = text(font: display-font(theme), weight: "bold", size: size * 3, fill: ink, features: ("ss02",),
        top-edge: "cap-height", bottom-edge: "baseline", letter)
      stack(spacing: 0.5em,
        context {
          let w = measure(big).width
          stack(spacing: 0.25em, big, line(length: w, stroke: 1.2pt + (if mono(theme) { black } else { accent })))
        },
        wordmark(word, theme, size * 0.72),
        num)
    } else {
      let mark = wordmark(word, theme, size * 1.15)
      stack(spacing: 0.5em,
        mark,
        if below != none {
          stack(spacing: 0.45em,
            context line(length: 0.4 * measure(mark).width, stroke: 0.4pt + luma(70%)),
            text(size: size * 0.8, fill: ink, hyphenate: false, below))
        },
        num)
    }
  })
  if style == "poster" { shadow-box(body, theme.at("shadow", default: accent), d: 0.28 * size) } else { body }
}

/// Rückseiten der Triminos: je Kärtchen das Etikett nach `layouts` (aus
/// `back-label-layout`), mit Thema und Nummer.
#let back-label-content(theme, size, title, custom: none, number: none) = {
  let below = if custom != none { custom } else { title }
  back-card-label("TRIMINO", theme, size, below: below,
    number: if number == none { none } else { str(number) })
}

#let draw-back(draw, labels, layouts) = {
  for (shown, lay) in labels.zip(layouts) {
    draw.content(lay.at, anchor: lay.anchor,
      pad(top: if lay.up { 0cm } else { lay.gap * 1cm }, bottom: if lay.up { lay.gap * 1cm } else { 0cm },
        scale(lay.scale * 100%, reflow: true, shown)))
  }
}

/// Breite und Höhe des Satzspiegels der aktuellen Seite (nur im `context`).
/// Ersetzt `layout(…)`, in dem keine Seitenumbrüche erlaubt sind.
#let content-area() = {
  let (w, h) = (page.width, page.height)
  let m = page.margin
  let standard = 2.5 / 21 * calc.min(w, h)
  let side(key, axis) = {
    if m == auto { return standard }
    if type(m) != dictionary { return m.length + m.ratio * w }
    let v = m.at(key, default: m.at(axis, default: m.at("rest", default: auto)))
    if key in ("left", "right") and v == auto {
      v = m.at(if key == "left" { "inside" } else { "outside" }, default: auto)
    }
    if v == auto { standard } else { v.length + v.ratio * w }
  }
  (
    width: w - side("left", "x") - side("right", "x"),
    height: h - side("top", "y") - side("bottom", "y"),
  )
}
