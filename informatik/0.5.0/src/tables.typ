// Textblöcke und ASCII-Tabelle.
#import "internal/check.typ": fail, check-named, check-value, check-type, check-positional, show-value
#import "internal.typ": mono
#import "numbers.typ": dec-to-bin, dec-to-hex

/// Teilt die Buchstaben eines Textes in Blöcke fester Länge, getrennt durch
/// Leerzeichen.
///
/// Alles außer A–Z und a–z entfällt. Ein Text ohne Buchstaben ergibt `""`.
///
/// ```typ
/// #text-to-blocks("HALLO WELT HEUTE")                 // "HALLO WELTH EUTE"
/// #text-to-blocks("HALLO WELT", character-count: 3)   // "HAL LOW ELT"
/// ```
///
/// - text (str): Text, der zerlegt wird
/// - character-count (int): Zeichen je Block
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> str
#let text-to-blocks(text, character-count: 5, ..deprecated) = {
  check-positional("informatik", "text-to-blocks", deprecated,
    hint: "die Blocklänge benannt schreiben – `character-count: 5`")
  check-named("informatik", "text-to-blocks", deprecated,
    renamed: (block-size: "character-count"),
    allowed: ("character-count",))
  check-type("informatik", "text-to-blocks", "text", text, str, example: "\"HALLO WELT\"")
  check-type("informatik", "text-to-blocks", "character-count", character-count, int, example: "5")
  if character-count < 1 {
    fail("informatik", "text-to-blocks", "`character-count: " + show-value(character-count) + "` ist zu klein – mindestens `1` schreiben")
  }

  let characters = text.codepoints().filter(c => c.match(regex("[A-Za-z]")) != none)
  let blocks = ()
  let current = ""
  for (i, char) in characters.enumerate() {
    current += char
    if calc.rem(i + 1, character-count) == 0 {
      blocks.push(current)
      current = ""
    }
  }
  if current.len() > 0 {
    blocks.push(current)
  }
  blocks.join(" ", default: "")
}

#let field-headers = (character: "Zeichen", dec: "Dezimal", bin: "Binär", hex: "Hex")

#let field-fills = (
  rgb("#1F77B4").lighten(50%).saturate(40%).transparentize(70%), // Blau
  rgb("#D62728").lighten(50%).saturate(40%).transparentize(70%), // Rot
  rgb("#2CA02C").lighten(50%).saturate(40%).transparentize(70%), // Grün
  rgb("#FF7F0E").lighten(50%).saturate(40%).transparentize(70%), // Orange
  rgb("#9467BD").lighten(50%).saturate(40%).transparentize(70%), // Violett
  rgb("#8C564B").lighten(50%).saturate(40%).transparentize(70%), // Braun
  rgb("#E377C2").lighten(50%).saturate(40%).transparentize(70%), // Pink
  rgb("#7F7F7F").lighten(50%).saturate(40%).transparentize(70%), // Grau
  rgb("#BCBD22").lighten(50%).saturate(40%).transparentize(70%), // Olivgrün
  rgb("#17BECF").lighten(50%).saturate(40%).transparentize(70%), // Cyan
)

#let field-grays = (
  white.darken(5%),
  white.darken(10%),
  white.darken(15%),
  white.darken(20%),
)

// Ein einzelnes Zeichen? Sonst Abbruch mit Abhilfe.
#let check-character(value, domain) = {
  if type(value) != str or value.clusters().len() != 1 {
    fail("informatik", "ascii-table", "`domains` enthält `" + show-value(domain) + "` – ein Bereich ist ein einzelnes Zeichen (`\"a\"`) oder ein Paar aus zwei Zeichen (`(\"a\", \"z\")`)")
  }
}

/// Setzt eine ASCII-Tabelle für einzelne Zeichen oder Zeichenbereiche.
///
/// Die Zeichen laufen spaltenweise: nach `rows` Zeilen beginnt ein neuer
/// Spaltenblock. Je Zeichen erscheinen die Spalten aus `fields`:
/// `"character"` (Zeichen), `"dec"` (Dezimal), `"bin"` (Binär), `"hex"`
/// (Hexadezimal).
///
/// ```typ
/// #ascii-table()
/// #ascii-table(domains: (("A", "Z"),), rows: 9)
/// #ascii-table(domains: (("a", "e"), "z"), fields: ("character", "dec", "hex", "bin"))
/// ```
///
/// - domains (array): Bereiche: einzelne Zeichen (`"a"`) oder Paare `(von, bis)`
/// - rows (int): Zeilen je Spaltenblock
/// - fields (array): Spalten je Zeichen aus `"character"`, `"dec"`, `"bin"`, `"hex"`
/// - colored (bool): farbige statt grauer Spaltenhintergründe
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> content
#let ascii-table(
  domains: (("a", "z"),),
  rows: 5,
  fields: ("character", "dec"),
  colored: true,
  ..deprecated,
) = {
  check-positional("informatik", "ascii-table", deprecated)
  check-named("informatik", "ascii-table", deprecated,
    renamed: (ranges: "domains", height: "rows", variants: "fields"),
    allowed: ("domains", "rows", "fields", "colored"))
  check-type("informatik", "ascii-table", "domains", domains, array, example: "((\"a\", \"z\"),)")
  check-type("informatik", "ascii-table", "rows", rows, int, example: "5")
  check-type("informatik", "ascii-table", "fields", fields, array, example: "(\"character\", \"dec\")")
  check-type("informatik", "ascii-table", "colored", colored, bool)
  if rows < 1 {
    fail("informatik", "ascii-table", "`rows: " + show-value(rows) + "` ist zu klein – mindestens `1` schreiben")
  }
  if domains.len() == 0 {
    fail("informatik", "ascii-table", "`domains: ()` ist leer – mindestens einen Bereich angeben, zum Beispiel `((\"a\", \"z\"),)`")
  }
  if fields.len() == 0 {
    fail("informatik", "ascii-table", "`fields: ()` ist leer – mindestens eine Spalte angeben, zum Beispiel `(\"character\", \"dec\")`")
  }
  for field in fields {
    check-value("informatik", "ascii-table", "fields", field,
      ("character", "dec", "bin", "hex"),
      renamed: (char: "character"))
  }

  // Alle Zeichen aus den Bereichen sammeln
  let characters = ()
  for domain in domains {
    if type(domain) == str {
      check-character(domain, domain)
      characters.push(domain)
    } else if type(domain) == array and domain.len() == 2 {
      check-character(domain.at(0), domain)
      check-character(domain.at(1), domain)
      if domain.at(0).to-unicode() > domain.at(1).to-unicode() {
        fail("informatik", "ascii-table", "`domains` enthält `" + show-value(domain) + "` – der Bereich läuft rückwärts, das kleinere Zeichen zuerst schreiben")
      }
      for code in range(domain.at(0).to-unicode(), domain.at(1).to-unicode() + 1) {
        characters.push(str.from-unicode(code))
      }
    } else {
      check-character(none, domain)
    }
  }

  let width = calc.ceil(characters.len() / rows)
  let fill-at(index) = if colored {
    field-fills.at(calc.rem(index, field-fills.len()))
  } else {
    field-grays.at(calc.rem(index, field-grays.len()))
  }

  // Kopfzeile
  let cells = ()
  for column in range(0, width) {
    for (index, field) in fields.enumerate() {
      cells.push(table.cell(fill: fill-at(index), std.text(0.9em, [*#field-headers.at(field)*])))
      cells.push(table.hline(stroke: 1.5pt + black))
    }
  }

  // Datenzeilen, spaltenweise gefüllt
  for row in range(0, rows) {
    for column in range(0, width) {
      let position = column * rows + row
      if position < characters.len() {
        let character = characters.at(position)
        let code = character.to-unicode()
        for (index, field) in fields.enumerate() {
          let cell-content = if field == "character" {
            // Leerzeichen als sichtbares Zeichen
            if character == " " { [#mono[␣]] } else { [#mono[#character]] }
          } else if field == "dec" {
            [#mono[#code]]
          } else if field == "bin" {
            [#mono[#dec-to-bin(code)]]
          } else {
            [#mono[#dec-to-hex(code)]]
          }
          cells.push(table.cell(fill: fill-at(index), cell-content))
        }
      } else {
        for (index, field) in fields.enumerate() {
          cells.push(table.cell(fill: fill-at(index), []))
        }
      }
      // Dicke Trennlinie nach jedem Spaltenblock außer dem letzten
      if column < width - 1 {
        cells.push(table.vline(stroke: 1.5pt + black))
      }
    }
  }

  table(
    columns: width * fields.len(),
    align: center,
    inset: 5pt,
    stroke: 0.5pt,
    ..cells
  )
}
