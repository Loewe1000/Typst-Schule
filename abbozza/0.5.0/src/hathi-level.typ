#import "@preview/cetz:0.3.4": canvas, draw
#import "internal/check.typ": fail, check-named, check-value, check-type, check-positional

// Paket- und Funktionsname für die Fehlermeldungen.
#let package-name = "abbozza"
#let function-name = "hathi-level"

// Kachelarten, die als fertiges Bild gesetzt werden.
#let image-kinds = ("grass", "water", "tree", "rock", "lion", "ice")
// Kachelarten, deren SVG vor dem Setzen angepasst wird (Zahl bzw. Farbe).
#let counted-kinds = ("bananas", "crate")
// Figuren mit Blickrichtung.
#let figure-kinds = ("hathi", "hartmut")
#let directions = ("0", "1", "2", "3")

// Farbe als Hex-Text mit neuem Farbton (in Grad), Sättigung und Helligkeit bleiben.
#let change-hue(hex, hue) = {
  let (_, saturation, lightness, alpha) = color.hsl(rgb(hex)).components()
  color.hsl(hue * 1deg, saturation, lightness, alpha).to-hex()
}

// Feldkoordinaten (x, y) des Levels → Punkt auf der Zeichenfläche.
#let to-canvas-point(x, y) = (int(x) - int(y), -1 * (int(x) + int(y)) / 2)

// Prüft einen Eintrag von `extra-tiles` und bringt ihn in die interne Form.
#let read-extra-tile(tile, replace-kind) = {
  check-type(package-name, function-name, "extra-tiles", tile, dictionary,
    example: "((kind: \"flag\", at: (2, 3)),)")
  check-named(package-name, function-name, tile,
    renamed: (type: "kind", pos: "at"),
    allowed: ("kind", "at", "capacity", "hue", "direction"),
    what: "Schlüssel")
  if "kind" not in tile or "at" not in tile {
    fail(package-name, function-name,
      "Eintrag in `extra-tiles` ohne `" + (if "kind" not in tile { "kind" } else { "at" })
        + "` – jede Kachel braucht `kind` und `at`, zum Beispiel `(kind: \"flag\", at: (2, 3))`")
  }
  check-type(package-name, function-name, "kind", tile.kind, str, example: "\"flag\"")
  let field = tile.at("at")
  check-type(package-name, function-name, "at", field, array, example: "(2, 3)")
  if field.len() != 2 {
    fail(package-name, function-name,
      "`at` hat " + str(field.len()) + " Einträge – genau zwei schreiben: `at: (x, y)`")
  }
  for entry in field {
    // Wie in der Level-Datei: Zahl oder Ziffern als Text.
    let is-number = (
      type(entry) in (int, float)
        or (type(entry) == str and entry.match(regex("^[-−]?[0-9]+$")) != none)
    )
    if not is-number {
      fail(package-name, function-name,
        "`at: " + repr(field) + "` – beide Einträge sind ganze Zahlen, zum Beispiel `at: (2, 3)`")
    }
  }
  let data = (kind: replace-kind(tile.kind), point: to-canvas-point(..field))
  for key in ("capacity", "hue", "direction") {
    if key in tile { data.insert(key, tile.at(key)) }
  }
  data
}

// Liest die Kacheln aus dem geparsten XML eines Levels.
#let read-level-tiles(level, replace-kind) = {
  let is-element = entry => type(entry) == dictionary
  let root = level.find(is-element)
  let world = if root != none {
    root.children.find(entry => is-element(entry) and entry.tag == "world")
  }
  let field = if world != none { world.children.find(is-element) }
  if field == none {
    fail(package-name, function-name,
      "`level` enthält kein `<world>`-Element mit Kacheln – die Level-Datei mit `xml(\"….abz\")` laden und unverändert übergeben")
  }
  field
    .children
    .filter(entry => is-element(entry) and entry.tag in ("tile", "item"))
    .map(entry => {
      let attrs = entry.attrs
      let data = (kind: replace-kind(attrs.type), point: to-canvas-point(attrs.x, attrs.y))
      for key in ("capacity", "direction") {
        if key in attrs { data.insert(key, attrs.at(key)) }
      }
      data
    })
}

// Setzt eine Kachel als Inhalt; `none` für unbekannte Arten.
#let tile-content(tile, tile-size, print) = {
  let kind = tile.kind
  let asset = name => "../assets/" + name + ".svg"
  if kind in image-kinds {
    let name = if kind == "lion" {
      "lion_0"
    } else if print and kind in ("grass", "water") {
      kind + "_print"
    } else {
      kind
    }
    image(asset(name), height: tile-size)
  } else if kind in counted-kinds {
    if "capacity" not in tile {
      fail(package-name, function-name,
        "Kachel `\"" + kind + "\"` ohne `capacity` – die Anzahl angeben, zum Beispiel `capacity: 3`")
    }
    check-type(package-name, function-name, "capacity", tile.capacity, (int, float, str),
      example: "3")
    let source = read(asset(kind)).replace("9999", str(tile.capacity))
    image(bytes(source), height: tile-size)
  } else if kind == "flag" {
    let source = read(asset("flag"))
    if "hue" in tile {
      check-type(package-name, function-name, "hue", tile.hue, (int, float), example: "344")
      source = source.replace("#0000FF", change-hue("#0000FF", tile.hue))
    }
    image(bytes(source), height: tile-size)
  } else if kind in figure-kinds {
    if "direction" not in tile {
      fail(package-name, function-name,
        "Kachel `\"" + kind + "\"` ohne `direction` – die Blickrichtung angeben: `direction: \"0\"` bis `\"3\"`")
    }
    if type(tile.direction) == int and str(tile.direction) in directions {
      fail(package-name, function-name,
        "`direction: " + str(tile.direction) + "` – die Blickrichtung ist ein Text: `direction: \""
          + str(tile.direction) + "\"` schreiben")
    }
    check-value(package-name, function-name, "direction", tile.direction, directions)
    image(asset(kind + "_" + tile.direction), height: tile-size)
  }
}

/// Setzt ein Hathi-Level als Bild aus Kacheln in Schrägansicht.
///
/// Liest die Kacheln aus einer Level-Datei von Abbozza! Worlds (XML, mit
/// `xml(…)` geladen) und zeichnet sie mit CeTZ. Kachelarten, die das Paket nicht
/// kennt, werden ausgelassen.
///
/// ```typ
/// #hathi-level(xml("level.abz"), tile-size: 20mm)
/// ```
///
/// - level (array): Die geladene Level-Datei, also das Ergebnis von `xml("level.abz")`.
/// - extra-tiles (array): Zusätzliche Kacheln, je ein Dictionary mit `kind` (Kachelart) und `at` (Feld `(x, y)`), dazu nach Bedarf `capacity` (Anzahl bei `"bananas"` und `"crate"`), `hue` (Farbton der Flagge in Grad) und `direction` (Blickrichtung `"0"` bis `"3"` bei `"hathi"` und `"hartmut"`).
/// - tile-size (length): Höhe einer Kachel. Die ganze Zeichnung wächst mit.
/// - print (bool): Druckfassung: Gras und Wasser in hellen, druckbaren Farben.
/// - replacements (dictionary): Ersetzt Kachelarten vor dem Zeichnen, zum Beispiel `(bananas: "grass")`. Schlüssel ist die Art in der Datei, Wert die Art, die gezeichnet wird.
/// - ..deprecated (arguments): Fängt alte Namen ab und nimmt nichts an.
/// -> content
#let hathi-level(
  level,
  extra-tiles: (),
  tile-size: 25mm,
  print: false,
  replacements: (:),
  ..deprecated,
) = {
  // 1. Sink prüfen: Positionsargumente, dann alte und unbekannte Namen.
  check-positional(package-name, function-name, deprecated,
    hint: "nur die Level-Datei steht vorn – alles Weitere benannt schreiben (`tile-size: 20mm`)")
  let old-names = deprecated.named()
  // Alt und neu zugleich: Die neuen Namen sind deklariert und landen nie im
  // Sink, deshalb hier von Hand (Konvention 8.3). Erkennbar ist der neue Name
  // nur, wenn sein Wert von der Vorgabe abweicht.
  for (old, new, given) in (
    ("scale", "tile-size", tile-size != 25mm),
    ("replace", "replacements", replacements != (:)),
  ) {
    if old in old-names and given {
      fail(package-name, function-name,
        "`" + old + "` (alt) und `" + new + "` (neu) zugleich – nur `" + new + "` schreiben")
    }
  }
  if "scale" in old-names and type(old-names.scale) in (int, float) {
    // Der Faktor ist jetzt eine Länge; die Meldung rechnet um. Geht die
    // Rechnung nicht auf drei Stellen auf (1/3), bleibt sie als Produkt stehen.
    let factor = old-names.scale
    let height = calc.round(factor * 25, digits: 3)
    let new-value = if height / 25 == factor {
      str(height) + "mm"
    } else {
      repr(factor) + " * 25mm"
    }
    fail(package-name, function-name,
      "`scale: " + repr(factor) + "` heißt jetzt `tile-size: " + new-value + "`")
  }
  check-named(package-name, function-name, deprecated,
    renamed: (scale: "tile-size", replace: "replacements"),
    allowed: ("extra-tiles", "tile-size", "print", "replacements"))

  // 2. Typen der deklarierten Parameter prüfen.
  check-type(package-name, function-name, "level", level, array, example: "xml(\"level.abz\")")
  check-type(package-name, function-name, "extra-tiles", extra-tiles, array,
    example: "((kind: \"flag\", at: (2, 3)),)")
  check-type(package-name, function-name, "tile-size", tile-size, length, example: "25mm")
  check-type(package-name, function-name, "print", print, bool)
  check-type(package-name, function-name, "replacements", replacements, dictionary,
    example: "(bananas: \"grass\")")

  // 3. Kacheln einsammeln: erst die der Datei, dann die zusätzlichen.
  let replace-kind = kind => replacements.at(kind, default: kind)
  let tiles = (
    read-level-tiles(level, replace-kind)
      + extra-tiles.map(tile => read-extra-tile(tile, replace-kind))
  )

  // 4. Zeichnen. Fünf Längeneinheiten der Zeichenfläche sind eine Kachelhöhe.
  canvas(
    length: tile-size / 5,
    {
      for tile in tiles {
        let body = tile-content(tile, tile-size, print)
        if body != none { draw.content(tile.point, body) }
      }
    },
  )
}
