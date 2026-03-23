/// Re-exportierte Symbole aus `@schule/blockst:0.0.1`:
/// `blockst`, `blockst-run`, `scratch`, `set-blockst`, `set-scratch`,
/// `set-blockst-run`, `executable`.
// tidy-ignore
#import "@schule/blockst:0.0.1": blockst, blockst-run, scratch, set-blockst, set-scratch, set-blockst-run, executable

/// Konvertiert eine Binärzahl (als String oder Integer) in eine Dezimalzahl.
///
/// ```typ
/// #str(bin2dec("1010")) // → 10
/// ```
///
/// - zahl (string, integer): Die Binärzahl (z.B. `"1010"` oder `1010`).
/// -> integer
#let bin2dec(zahl) = {
  let binary = str(zahl)
  let ergebnis = 0

  for (i, bit) in binary.codepoints().enumerate() {
    if bit == "1" {
      ergebnis += calc.pow(2, binary.len() - i - 1)
    }
  }

  ergebnis
}

/// Konvertiert eine Dezimalzahl in einen Binärstring.
///
/// ```typ
/// #dec2bin(42) // → "101010"
/// ```
///
/// - zahl (integer): Die Dezimalzahl (≥ 0).
/// -> string
#let dec2bin(zahl) = {
  let zahl = int(zahl)
  if zahl == 0 { return "0" }

  let ergebnis = ""
  while zahl > 0 {
    ergebnis = str(calc.rem(zahl, 2)) + ergebnis
    zahl = calc.quo(zahl, 2)
  }

  ergebnis
}

/// Führt eine Häufigkeitsanalyse der Großbuchstaben (A–Z) im Text durch.
///
/// Gibt ein Dictionary zurück:
/// - `absolut` -- Dictionary mit absoluten Häufigkeiten pro Buchstabe
/// - `relativ` -- Dictionary mit relativen Häufigkeiten in Prozent
/// - `diagramm` -- Säulendiagramm als Content (via CeTZ)
/// - `data` -- Array für CeTZ: `(([Label], Wert), ...)`
/// - `text` -- Der ursprüngliche Eingabetext
///
/// ```typ
/// #let hf = häufigkeitsanalyse("Hallo Welt")
/// #hf.diagramm
/// ```
///
/// - text (string): Der zu analysierende Text.
/// -> dictionary
#let häufigkeitsanalyse(text) = {
  let alphabet = (:)
  for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".codepoints() {
    alphabet.insert(char, 0)
  }

  for char in text.codepoints() {
    let upper-char = upper(char)
    if upper-char in alphabet.keys() {
      alphabet.at(upper-char) += 1
    }
  }

  let sum = alphabet.values().sum()

  // Absolute Häufigkeiten
  let absolut = alphabet

  // Relative Häufigkeiten
  let relativ = (:)
  for (key, value) in alphabet {
    relativ.insert(key, if sum > 0 { 100.0 * value / sum } else { 0.0 })
  }

  // Daten für CeTZ
  let data = ()
  for (key, value) in relativ {
    data.push(([#key], value))
  }

  // Diagramm als Content
  let diagramm-content = {
    import "@preview/cetz:0.4.2": canvas, draw
    import "@preview/cetz-plot:0.1.3": chart

    canvas(
      length: 1cm,
      {
        import draw: *
        set-style(
          axis: (
            y: (
              tick: (stroke: none),  // Keine Striche bei Ticks
              stroke: none,           // Keine Achsenlinie
            )
          ),
        )
        chart.columnchart(
          data,
          size: (11, 4),
          bar-style: (
            fill: rgb("#008000"),
            stroke: none,
          ),
          y-tick-step: none,
        )
      },
    )
  }

  (
    absolut: absolut,
    relativ: relativ,
    data: data,
    diagramm: diagramm-content,
    text: text,
  )
}

/// Legacy-Wrapper für `häufigkeitsanalyse` mit alter Signatur (Kompatibilität).
///
/// - text (string): Der zu analysierende Text.
/// - rel (boolean): Gibt relative statt absolute Häufigkeiten zurück (nur bei `cetz: false`).
/// - cetz (boolean): Gibt CeTZ-Daten-Array zurück wenn `true`, sonst das Häufigkeits-Dictionary.
/// -> array, dictionary
#let häufigkeitsanalyse-alt(text, rel: false, cetz: true) = {
  let hf = häufigkeitsanalyse(text)
  if not cetz {
    if rel { hf.relativ } else { hf.absolut }
  } else {
    hf.data
  }
}

/// Erstellt eine Caesar-Chiffre-Funktion.
///
/// Im einfachen Modus (`advanced: false`) wird eine Funktion zurückgegeben,
/// die `(text)` enkodiert, `(text, true)` dekodiert oder ohne Argumente die
/// Schlüsseltabelle als Content zurückgibt.
///
/// Im erweiterten Modus (`advanced: true`) wird ein Dictionary zurückgegeben:
/// `(encode: function, decode: function, table: content, key: any, keyword: any,
/// alphabet: string, geheimtext-alphabet: string)`
///
/// ```typ
/// #caesar(key: 3)("HALLO")        // → "KDOOR"
/// #caesar(key: 3)("KDOOR", true)  // → "HALLO"
/// #caesar(key: 3)()               // → Schlüsseltabelle
/// ```
///
/// - key (integer, none): Verschiebung (0–25). Entweder `key` oder `keyword` muss gesetzt sein.
/// - keyword (string, none): Schlüsselwort für alphabetbasierte Verschlüsselung.
/// - advanced (boolean): Gibt erweiterten Dictionary-Modus zurück wenn `true`.
/// -> function
#let caesar(key: none, keyword: none, advanced: false) = {
  let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let geheimtext-alphabet = ""

  // Hilfsfunktion: Doppelte Buchstaben entfernen
  let remove-doubles(text) = {
    let result = ""
    let seen = ()
    for c in upper(text).codepoints() {
      if c not in seen and c.match(regex("[A-Z]")) != none {
        result += c
        seen.push(c)
      }
    }
    result
  }

  // Geheimtext-Alphabet erstellen
  if keyword != none {
    // Schlüsselwort-basierte Caesar-Chiffre
    let clean-keyword = remove-doubles(keyword)
    let remaining = ""

    for char in alphabet.codepoints() {
      if char not in clean-keyword.codepoints() {
        remaining += char
      }
    }

    // Startposition nach dem letzten Buchstaben des Schlüsselworts
    if clean-keyword.len() > 0 {
      let last-char = clean-keyword.at(clean-keyword.len() - 1)
      let start = alphabet.codepoints().position(c => c == last-char)
      if start != none {
        let start-plus = calc.rem(start + 1, 26)

        // Finde nächste Position in remaining
        for i in range(0, 26) {
          let check-pos = calc.rem(start-plus + i, 26)
          let check-char = alphabet.at(check-pos)
          let pos = remaining.codepoints().position(c => c == check-char)
          if pos != none {
            geheimtext-alphabet = clean-keyword + remaining.slice(pos) + remaining.slice(0, pos)
            break
          }
        }
      }
    }

    if geheimtext-alphabet == "" {
      geheimtext-alphabet = clean-keyword + remaining
    }
  } else if key != none {
    // Einfache Verschiebung
    let shift = calc.rem(int(key), 26)
    geheimtext-alphabet = alphabet.slice(shift) + alphabet.slice(0, shift)
  } else {
    panic("Entweder 'key' oder 'keyword' muss angegeben werden!")
  }

  // Encoder-Funktion
  let do-encode(klartext) = {
    let result = ""
    for char in klartext.codepoints() {
      let upper-char = upper(char)
      let pos = alphabet.codepoints().position(c => c == upper-char)
      if pos != none {
        let encoded = geheimtext-alphabet.at(pos)
        result += if char == upper-char { encoded } else { lower(encoded) }
      } else {
        result += char
      }
    }
    result
  }

  // Decoder-Funktion
  let do-decode(geheimtext) = {
    let result = ""
    for char in geheimtext.codepoints() {
      let upper-char = upper(char)
      let pos = geheimtext-alphabet.codepoints().position(c => c == upper-char)
      if pos != none {
        let decoded = alphabet.at(pos)
        result += if char == upper-char { decoded } else { lower(decoded) }
      } else {
        result += char
      }
    }
    result
  }

  // Tabelle als Content (kein Funktionsaufruf nötig)
  let table-content = {
    let cells = ([*KA*],) + alphabet.codepoints().map(c => [#c])
    cells += ([*GA*],) + geheimtext-alphabet.codepoints().map(c => [#c])

    table(
      columns: 27,
      align: center,
      inset: 5pt,
      stroke: 0.5pt,
      ..cells
    )
  }

  // Im einfachen Modus: Gib aufrufbare Funktion zurück
  if not advanced {
    // Wrapper-Funktion für einfache Nutzung
    let simple-function(..args) = {
      let pos-args = args.pos()
      let named-args = args.named()
      
      if pos-args.len() == 0 {
        // Ohne Argumente: Tabelle anzeigen
        table-content
      } else if pos-args.len() == 2 and pos-args.at(1) == true {
        // Mit zwei Argumenten und zweites ist true: Dekodieren
        do-decode(pos-args.at(0))
      } else if pos-args.len() >= 1 {
        // Mit einem Argument: Enkodieren
        do-encode(pos-args.at(0))
      } else {
        table-content
      }
    }
    return simple-function
  }

  // Im advanced Modus: Rückgabe des Objekts mit Methoden
  (
    encode: do-encode,
    decode: do-decode,
    table: table-content, // Direkt Content, keine Funktion!
    key: key,
    keyword: keyword,
    alphabet: alphabet,
    geheimtext-alphabet: geheimtext-alphabet,
  )
}

/// Setzt Text in SF Mono (Monospace-Schrift).
///
/// - body (content): Der darzustellende Inhalt.
/// -> content
#let mono(body) = text(font: "SF Mono", body)

/// Erstellt eine Vigenère-Chiffre-Funktion.
///
/// Im einfachen Modus (`advanced: false`) wird eine Funktion zurückgegeben,
/// die `(text)` enkodiert oder `(text, true)` dekodiert.
///
/// Im erweiterten Modus (`advanced: true`) wird ein Dictionary zurückgegeben:
/// `(encode: function, decode: function, keyword: string)`
///
/// ```typ
/// #vigenere("SCHLUESSEL")("HALLO") // → enkodierter Text
/// ```
///
/// - keyword (string): Das Schlüsselwort (nur Buchstaben A–Z).
/// - advanced (boolean): Gibt erweiterten Dictionary-Modus zurück wenn `true`.
/// -> function
#let vigenere(keyword, advanced: false) = {
  let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let clean-keyword = upper(keyword).codepoints().filter(c => c.match(regex("[A-Z]")) != none).join("")

  if clean-keyword.len() == 0 {
    panic("Schlüsselwort muss mindestens einen Buchstaben enthalten!")
  }

  let do-encode(klartext) = {
    let result = ""
    let key-index = 0

    for char in klartext.codepoints() {
      let upper-char = upper(char)
      let pos = alphabet.codepoints().position(c => c == upper-char)

      if pos != none {
        let key-char = clean-keyword.at(calc.rem(key-index, clean-keyword.len()))
        let key-pos = alphabet.codepoints().position(c => c == key-char)
        let encoded-pos = calc.rem(pos + key-pos, 26)
        let encoded = alphabet.at(encoded-pos)
        result += if char == upper-char { encoded } else { lower(encoded) }
        key-index += 1
      } else {
        result += char
      }
    }
    result
  }

  let do-decode(geheimtext) = {
    let result = ""
    let key-index = 0

    for char in geheimtext.codepoints() {
      let upper-char = upper(char)
      let pos = alphabet.codepoints().position(c => c == upper-char)

      if pos != none {
        let key-char = clean-keyword.at(calc.rem(key-index, clean-keyword.len()))
        let key-pos = alphabet.codepoints().position(c => c == key-char)
        let decoded-pos = calc.rem(pos - key-pos + 26, 26)
        let decoded = alphabet.at(decoded-pos)
        result += if char == upper-char { decoded } else { lower(decoded) }
        key-index += 1
      } else {
        result += char
      }
    }
    result
  }

  // Im einfachen Modus: Gib aufrufbare Funktion zurück
  if not advanced {
    let simple-function(..args) = {
      let pos-args = args.pos()
      
      if pos-args.len() == 0 {
        panic("Mindestens ein Text-Argument erforderlich!")
      } else if pos-args.len() == 2 and pos-args.at(1) == true {
        // Mit zwei Argumenten und zweites ist true: Dekodieren
        do-decode(pos-args.at(0))
      } else if pos-args.len() >= 1 {
        // Mit einem Argument: Enkodieren
        do-encode(pos-args.at(0))
      }
    }
    return simple-function
  }

  // Im advanced Modus: Rückgabe des Objekts mit Methoden
  (
    encode: do-encode,
    decode: do-decode,
    keyword: clean-keyword,
  )
}

/// Vorkonfigurierter Caesar-Chiffre mit Verschiebung 13 (ROT13).
///
/// Da ROT13 selbst-invers ist, kann dieselbe Funktion zum En- und Dekodieren
/// verwendet werden.
///
/// ```typ
/// #rot13("Hallo") // → "Uryyb"
/// #rot13("Uryyb") // → "Hallo"
/// ```
///
/// -> function
#let rot13 = caesar(key: 13)

/// Teilt einen Text in Blöcke fester Größe auf (nur Buchstaben, leerzeichen-getrennt).
///
/// Nicht-alphabetische Zeichen werden ignoriert. Nützlich für
/// Kryptographie-Aufgaben auf Arbeitsblättern.
///
/// ```typ
/// #text-to-blocks("HALLO WELT")     // → "HALLO WELT"
/// #text-to-blocks("HALLO", block-size: 3) // → "HAL LO"
/// ```
///
/// - text (string): Der zu zerlegende Text.
/// - block-size (integer): Anzahl der Zeichen pro Block (Standard: `5`).
/// -> content
#let text-to-blocks(text, block-size: 5) = {
  let clean = text.codepoints().filter(c => c.match(regex("[A-Za-z]")) != none).join("")
  let blocks = ()
  let current = ""

  for (i, char) in clean.codepoints().enumerate() {
    current += char
    if calc.rem(i + 1, block-size) == 0 {
      blocks.push(current)
      current = ""
    }
  }

  if current.len() > 0 {
    blocks.push(current)
  }

  blocks.join(" ")
}

/// Erstellt eine Atbash-Chiffre-Funktion (A↔Z, B↔Y, …).
///
/// Da Atbash symmetrisch ist, sind Enkodierung und Dekodierung identisch.
///
/// Im einfachen Modus (`advanced: false`) wird eine Funktion zurückgegeben,
/// die `(text)` transformiert.
///
/// Im erweiterten Modus (`advanced: true`) wird ein Dictionary zurückgegeben:
/// `(encode: function, decode: function)`
///
/// ```typ
/// #atbash()("HALLO") // → "SVOOL"
/// #atbash()("SVOOL") // → "HALLO"
/// ```
///
/// - advanced (boolean): Gibt erweiterten Dictionary-Modus zurück wenn `true`.
/// -> function
#let atbash(advanced: false) = {
  let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let reversed = alphabet.codepoints().rev().join("")

  let do-transform(text) = {
    let result = ""
    for char in text.codepoints() {
      let upper-char = upper(char)
      let pos = alphabet.codepoints().position(c => c == upper-char)
      if pos != none {
        let transformed = reversed.at(pos)
        result += if char == upper-char { transformed } else { lower(transformed) }
      } else {
        result += char
      }
    }
    result
  }

  // Im einfachen Modus: Gib aufrufbare Funktion zurück
  if not advanced {
    let simple-function(..args) = {
      let pos-args = args.pos()
      
      if pos-args.len() == 0 {
        panic("Mindestens ein Text-Argument erforderlich!")
      } else {
        // Atbash ist symmetrisch, encode = decode
        do-transform(pos-args.at(0))
      }
    }
    return simple-function
  }

  // Im advanced Modus: Rückgabe des Objekts mit Methoden
  (
    encode: do-transform,
    decode: do-transform, // Bei Atbash ist encode = decode
  )
}

/// Konvertiert einen Hexadezimalstring in eine Dezimalzahl.
///
/// Groß- und Kleinschreibung wird ignoriert.
///
/// ```typ
/// #str(hex2dec("FF"))  // → "255"
/// #str(hex2dec("ff"))  // → "255"
/// ```
///
/// - hex (string): Der Hexadezimalstring (z.B. `"FF"` oder `"ff"`).
/// -> integer
#let hex2dec(hex) = {
  let hex-str = upper(str(hex))
  let result = 0
  let hex-chars = "0123456789ABCDEF"

  for char in hex-str.codepoints() {
    let value = hex-chars.codepoints().position(c => c == char)
    if value != none {
      result = result * 16 + value
    }
  }

  result
}

/// Konvertiert eine Dezimalzahl in einen Hexadezimalstring (Großbuchstaben).
///
/// ```typ
/// #dec2hex(255) // → "FF"
/// #dec2hex(42)  // → "2A"
/// ```
///
/// - num (integer): Die Dezimalzahl (≥ 0).
/// -> string
#let dec2hex(num) = {
  let num = int(num)
  if num == 0 { return "0" }

  let hex-chars = "0123456789ABCDEF"
  let result = ""

  while num > 0 {
    result = hex-chars.at(calc.rem(num, 16)) + result
    num = calc.quo(num, 16)
  }

  result
}

/// Rendert eine ASCII-Tabelle für die angegebenen Zeichenbereiche.
///
/// Jeder Bereich in `ranges` ist entweder ein einzelner String oder ein
/// Tupel `(start, end)` aus zwei Zeichen.
///
/// ```typ
/// #ascii-table()                         // a–z, Zeichen + Dezimal
/// #ascii-table(ranges: (("A", "Z"),))    // A–Z
/// #ascii-table(variants: ("char", "dec", "hex", "bin"))
/// ```
///
/// - ranges (array): Zeichenbereiche als `(start, end)`-Tupel oder Strings (Standard: `(("a", "z"),)`).
/// - height (integer): Anzahl der Zeilen pro Spaltenblock (Standard: `5`).
/// - variants (array): Anzuzeigende Spalten: `"char"`, `"dec"`, `"bin"`, `"hex"` (Standard: `("char", "dec")`).
/// - colored (boolean): Farbige Spalten-Hintergründe (Standard: `true`).
/// -> content
#let ascii-table(ranges: (("a", "z"),), height: 5, variants: ("char", "dec"), colored: true) = {
  // Sammle alle Zeichen aus den Bereichen
  let chars = ()
  for range-spec in ranges {
    if type(range-spec) == str {
      chars.push(range-spec)
    } else if type(range-spec) == array and range-spec.len() == 2 {
      let start = range-spec.at(0).to-unicode()
      let end = range-spec.at(1).to-unicode()
      for code in range(start, end + 1) {
        chars.push(str.from-unicode(code))
      }
    }
  }

  // Berechne Spaltenanzahl
  let width = calc.ceil(chars.len() / height)
  let cols-per-char = variants.len()

  let colors = (
    rgb("#1F77B4").lighten(50%).saturate(40%).transparentize(70%), // Blau
    rgb("#D62728").lighten(50%).saturate(40%).transparentize(70%), // Rot
    rgb("#2CA02C").lighten(50%).saturate(40%).transparentize(70%), // Grün
    rgb("#FF7F0E").lighten(50%).saturate(40%).transparentize(70%), // Orange
    rgb("#9467BD").lighten(50%).saturate(40%).transparentize(70%), // Violett
    rgb("#8C564B").lighten(50%).saturate(40%).transparentize(70%), // Braun
    rgb("#E377C2").lighten(50%).saturate(40%).transparentize(70%), // Pink
    rgb("#7F7F7F").lighten(50%).saturate(40%).transparentize(70%), // Grau
    rgb("#BCBD22").lighten(50%).saturate(40%).transparentize(70%), // Olivgrün/Gelb
    rgb("#17BECF").lighten(50%).saturate(40%).transparentize(70%), // Cyan
  )

  let gray-colors = (
    white.darken(5%),
    white.darken(10%),
    white.darken(15%),
    white.darken(20%),
  )

  // Erstelle Header
  let header = ()
  for col in range(0, width) {
    for (key, variant) in variants.enumerate() {
      let header-text = if variant == "char" {
        "Zeichen"
      } else if variant == "dec" {
        "Dezimal"
      } else if variant == "bin" {
        "Binär"
      } else if variant == "hex" {
        "Hex"
      } else {
        upper(variant)
      }
      header.push(table.cell(fill: if colored { colors.at(calc.rem(key, colors.len())) } else { gray-colors.at(calc.rem(key, gray-colors.len())) }, text(0.9em, [*#header-text*])))
      header.push(table.hline(stroke: 1.5pt + black))
    }
  }

  // Erstelle Datenzeilen
  let cells = header

  for row in range(0, height) {
    for col in range(0, width) {
      let idx = col * height + row // Spaltenweise Indexierung!
      if idx < chars.len() {
        let char = chars.at(idx)
        let unicode-val = char.to-unicode()

        for (key, variant) in variants.enumerate() {
          let cell-content = if variant == "char" {
            // Zeige Leerzeichen als sichtbares Symbol
            if char == " " {
              [#mono[␣]]
            } else {
              [#mono[#char]]
            }
          } else if variant == "dec" {
            [#mono[#unicode-val]]
          } else if variant == "bin" {
            [#mono[#dec2bin(unicode-val)]]
          } else if variant == "hex" {
            [#mono[#dec2hex(unicode-val)]]
          } else {
            [?]
          }
          cells.push(table.cell(fill: if colored { colors.at(calc.rem(key, colors.len())) } else { gray-colors.at(calc.rem(key, gray-colors.len())) }, cell-content))
        }
      } else {
        // Leere Zellen für nicht vorhandene Zeichen
        for (key, variant) in variants.enumerate() {
          cells.push(table.cell(fill: if colored { colors.at(calc.rem(key, colors.len())) } else { gray-colors.at(calc.rem(key, gray-colors.len())) }, []))
        }
      }
      // Füge dicke Trennlinie nach jeder Zeichengruppe hinzu (außer der letzten)
      if col < width - 1 {
        cells.push(table.vline(stroke: 1.5pt + black))
      }
    }
  }
  table(
    columns: width * cols-per-char,
    align: center,
    inset: 5pt,
    stroke: 0.5pt,
    ..cells
  )
}
