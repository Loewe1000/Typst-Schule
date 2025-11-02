// Scratch-Blöcke
#import "scratch.typ": *

// Konvertiert eine Binärzahl (als String oder Zahl) zu Dezimal
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

// Konvertiert eine Dezimalzahl zu Binär
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

// Führt eine Häufigkeitsanalyse durch
// Verwendung:
//   let hf = häufigkeitsanalyse("Beispieltext")
//   hf.absolut      // Dictionary mit absoluten Häufigkeiten
//   hf.relativ      // Dictionary mit relativen Häufigkeiten (%)
//   hf.diagramm     // Säulendiagramm (CeTZ)
//   hf.data         // Array für CeTZ: (([Label], Wert), ...)
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

// Legacy: Alte Funktionssignatur für Kompatibilität
#let häufigkeitsanalyse-alt(text, rel: false, cetz: true) = {
  let hf = häufigkeitsanalyse(text)
  if not cetz {
    if rel { hf.relativ } else { hf.absolut }
  } else {
    hf.data
  }
}

// Caesar-Chiffre - erstellt ein Objekt mit Methoden
// Verwendung (advanced: false):
//   let c = caesar(key: 3)
//   c("Klartext")           => Kodiert
//   c("Geheimtext", true)   => Dekodiert
//   c()                     => Gibt die Tabelle aus
// Verwendung (advanced: true):
//   let c = caesar(key: 3, advanced: true)
//   (c.encode)("KLARTEXT")
//   (c.decode)("GEHEIMTEXT")
//   c.table
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

#set par(leading: 1.1em)
#let mono(body) = text(font: "SF Mono", body)

// Vigenère-Chiffre
// Verwendung (advanced: false):
//   let v = vigenere("SCHLUESSEL")
//   v("Klartext")           => Kodiert
//   v("Geheimtext", true)   => Dekodiert
// Verwendung (advanced: true):
//   let v = vigenere("SCHLUESSEL", advanced: true)
//   (v.encode)("KLARTEXT")
//   (v.decode)("GEHEIMTEXT")
//   v.keyword
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

// ROT13 - Spezialfall von Caesar
#let rot13 = caesar(key: 13)

// Hilfsfunktion: Text in Blöcke aufteilen
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

// Atbash-Chiffre (A↔Z, B↔Y, etc.)
// Verwendung (advanced: false):
//   let a = atbash()
//   a("Klartext")           => Kodiert/Dekodiert (identisch)
// Verwendung (advanced: true):
//   let a = atbash(advanced: true)
//   (a.encode)("KLARTEXT")
//   (a.decode)("GEHEIMTEXT")
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

// Hexadezimal zu Dezimal
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

// Dezimal zu Hexadezimal
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

// ASCII-Tabelle generieren
// Bereiche: Array von Tupeln (start, end) oder einzelnen Zeichen
// Varianten: "char" (Zeichen), "dec" (Dezimal), "bin" (Binär), "hex" (Hexadezimal)
// Beispiele:
//   ascii-table(ranges: ((("a", "z"),)), variants: ("char", "dec"))
//   ascii-table(ranges: ((("A", "Z"),)), variants: ("char", "dec", "bin"))
//   ascii-table(ranges: ((("0", "9"),)), variants: ("char", "dec", "hex"))
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
