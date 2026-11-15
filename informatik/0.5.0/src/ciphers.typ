// Klassische Chiffren. Alle haben dieselbe Aufrufform: chiffre(text, key: …).
#import "internal/check.typ": fail, check-named, check-type, check-positional, show-value

#let plain-alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

// Buchstaben A–Z eines Schlüsselworts, groß, ohne Wiederholungen.
#let unique-letters(word) = {
  let result = ""
  let seen = ()
  for c in upper(word).codepoints() {
    if c not in seen and c.match(regex("[A-Z]")) != none {
      result += c
      seen.push(c)
    }
  }
  result
}

// Buchstaben A–Z eines Schlüsselworts, groß, mit Wiederholungen.
#let letters(word) = upper(word).codepoints().filter(c => c.match(regex("[A-Z]")) != none).join("")

// Prüft `key` und meldet einen Text ohne Buchstaben.
#let check-key(function, key, kinds, example) = {
  if key == none {
    fail("informatik", function, "`key` fehlt – zum Beispiel `" + example + "` schreiben")
  }
  check-type("informatik", function, "key", key, kinds, example: if int in kinds { "3" } else { "\"LEMON\"" })
  if type(key) == str and letters(key) in (none, "") {
    fail("informatik", function, "`key: " + show-value(key) + "` ist kein Schlüsselwort – " + if int in kinds and key.match(regex("^[0-9]+$")) != none {
      "für eine Verschiebung `key: " + str(int(key)) + "` schreiben"
    } else {
      "ein Wort mit mindestens einem Buchstaben A–Z schreiben"
    })
  }
}

// Meldet alt und neu zugleich (`keyword` neben `key`).
#let check-keyword(function, key, named) = {
  if key != none and "keyword" in named {
    fail("informatik", function, "`keyword` (alt) und `key` (neu) zugleich – nur `key` schreiben")
  }
}

// Liefert den Text, das einzige Positionsargument einer Chiffre. Fehlt er,
// liegt meist die alte Aufrufform `chiffre(…)("abc")` vor: `remedy` nennt die
// neue.
#let read-text(function, positional, remedy, example) = {
  if positional.len() == 0 {
    fail("informatik", function, "der Text fehlt – " + remedy)
  }
  let text = positional.first()
  check-type("informatik", function, "text", text, str, example: example)
  text
}

// Geheimtextalphabet der Caesar-Chiffre zu einer Verschiebung (int) oder
// einem Schlüsselwort (str).
#let caesar-alphabet(key) = {
  if type(key) == int {
    let shift = calc.rem(key, 26)
    return plain-alphabet.slice(shift) + plain-alphabet.slice(0, shift)
  }

  let word = unique-letters(key)
  let remaining = ""
  for char in plain-alphabet.codepoints() {
    if char not in word.codepoints() {
      remaining += char
    }
  }

  // Der Rest des Alphabets beginnt hinter dem letzten Buchstaben des Schlüsselworts.
  let start = plain-alphabet.codepoints().position(c => c == word.at(word.len() - 1))
  let start-after = calc.rem(start + 1, 26)
  for i in range(0, 26) {
    let candidate = plain-alphabet.at(calc.rem(start-after + i, 26))
    let position = remaining.codepoints().position(c => c == candidate)
    if position != none {
      return word + remaining.slice(position) + remaining.slice(0, position)
    }
  }
  word + remaining
}

// Ersetzt jeden Buchstaben aus `source` durch den an gleicher Stelle in
// `target`; die Groß- und Kleinschreibung bleibt, alles andere bleibt stehen.
#let substitute(text, source, target) = {
  let result = ""
  for char in text.codepoints() {
    let letter = upper(char)
    let position = source.codepoints().position(c => c == letter)
    if position != none {
      let replaced = target.at(position)
      result += if char == letter { replaced } else { lower(replaced) }
    } else {
      result += char
    }
  }
  result
}

/// Verschlüsselt einen Text mit der Caesar-Chiffre.
///
/// `key` ist entweder eine Verschiebung (Zahl) oder ein Schlüsselwort (Text).
/// Bei einem Schlüsselwort beginnt das Geheimtextalphabet mit dessen
/// Buchstaben; der Rest des Alphabets folgt ab dem letzten Buchstaben des
/// Schlüsselworts. Groß- und Kleinschreibung bleiben erhalten, alles außer
/// A–Z bleibt stehen.
///
/// ```typ
/// #caesar("HALLO", key: 3)                 // "KDOOR"
/// #caesar("KDOOR", key: 3, inverse: true)  // "HALLO"
/// #caesar("HALLO", key: "GEHEIM")
/// ```
///
/// Eine Chiffre mit festem Schlüssel entsteht mit `caesar.with(key: 3)`.
///
/// - key (int, str): Pflicht. Verschiebung (`3`) oder Schlüsselwort (`"GEHEIM"`)
/// - inverse (bool): entschlüsseln statt verschlüsseln
/// - ..args (arguments): genau ein Positionsargument: der Text (`str`), mit `inverse: true` der Geheimtext. Alte Namen werden hier abgefangen.
/// -> str
#let caesar(key: none, inverse: false, ..args) = {
  check-positional("informatik", "caesar", args, max: 1,
    hint: "entschlüsseln mit `inverse: true` – `caesar(\"KDOOR\", key: 3, inverse: true)` schreiben")
  check-keyword("caesar", key, args.named())
  check-named("informatik", "caesar", args,
    renamed: (keyword: "key"),
    removed: (advanced: "`caesar(text, key: …)` liefert den Text direkt, die Tabelle setzt `caesar-table(key: …)`"),
    allowed: ("key", "inverse"))
  let shown = if type(key) in (int, str) { show-value(key) } else { "3" }
  let text = read-text("caesar", args.pos(),
    "`caesar(\"abc\", key: " + shown + ")` schreiben; die Schlüsseltabelle setzt `caesar-table(key: " + shown + ")`, eine Chiffre mit festem Schlüssel `caesar.with(key: " + shown + ")`",
    "\"HALLO\"")
  check-key("caesar", key, (int, str), "caesar(\"HALLO\", key: 3)")
  check-type("informatik", "caesar", "inverse", inverse, bool)

  let cipher-alphabet = caesar-alphabet(key)
  if inverse {
    substitute(text, cipher-alphabet, plain-alphabet)
  } else {
    substitute(text, plain-alphabet, cipher-alphabet)
  }
}

/// Setzt die Schlüsseltabelle einer Caesar-Chiffre: oben das Klartextalphabet
/// (KA), darunter das Geheimtextalphabet (GA).
///
/// ```typ
/// #caesar-table(key: 3)
/// ```
///
/// - key (int, str): Pflicht. Verschiebung oder Schlüsselwort wie bei `caesar`
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> content
#let caesar-table(key: none, ..deprecated) = {
  check-positional("informatik", "caesar-table", deprecated,
    hint: "den Schlüssel benannt schreiben – `caesar-table(key: 3)`")
  check-keyword("caesar-table", key, deprecated.named())
  check-named("informatik", "caesar-table", deprecated,
    renamed: (keyword: "key"),
    allowed: ("key",))
  check-key("caesar-table", key, (int, str), "caesar-table(key: 3)")

  let cells = ([*KA*],) + plain-alphabet.codepoints().map(c => [#c])
  cells += ([*GA*],) + caesar-alphabet(key).codepoints().map(c => [#c])

  table(
    columns: 27,
    align: center,
    inset: 5pt,
    stroke: 0.5pt,
    ..cells
  )
}

/// Verschlüsselt einen Text mit der Vigenère-Chiffre.
///
/// Vom Schlüsselwort zählen nur die Buchstaben A–Z. Groß- und Kleinschreibung
/// des Textes bleiben erhalten, alles außer A–Z bleibt stehen und verbraucht
/// keinen Buchstaben des Schlüsselworts.
///
/// ```typ
/// #vigenere("HALLO WELT", key: "LEMON")
/// #vigenere("SEXZB HIXH", key: "LEMON", inverse: true)
/// ```
///
/// Eine Chiffre mit festem Schlüssel entsteht mit `vigenere.with(key: "LEMON")`.
///
/// - key (str): Pflicht. Schlüsselwort mit mindestens einem Buchstaben
/// - inverse (bool): entschlüsseln statt verschlüsseln
/// - ..args (arguments): genau ein Positionsargument: der Text (`str`), mit `inverse: true` der Geheimtext. Alte Namen werden hier abgefangen.
/// -> str
#let vigenere(key: none, inverse: false, ..args) = {
  check-positional("informatik", "vigenere", args, max: 1,
    hint: "erst der Text, dann der Schlüssel – `vigenere(\"HALLO\", key: \"LEMON\")` schreiben, zum Entschlüsseln `inverse: true`")
  check-keyword("vigenere", key, args.named())
  check-named("informatik", "vigenere", args,
    renamed: (keyword: "key"),
    removed: (advanced: "`vigenere(text, key: …)` liefert den Text direkt"),
    allowed: ("key", "inverse"))
  let shown = if type(key) == str { show-value(key) } else { "\"LEMON\"" }
  let text = read-text("vigenere", args.pos(),
    "`vigenere(\"abc\", key: " + shown + ")` schreiben; eine Chiffre mit festem Schlüssel entsteht mit `vigenere.with(key: " + shown + ")`",
    "\"HALLO\"")
  if type(key) == int {
    fail("informatik", "vigenere", "`key: " + show-value(key) + "` ist kein Schlüsselwort – ein Wort schreiben, zum Beispiel `key: \"LEMON\"`")
  }
  check-key("vigenere", key, (str,), "vigenere(\"HALLO\", key: \"LEMON\")")
  check-type("informatik", "vigenere", "inverse", inverse, bool)

  let word = letters(key)
  let result = ""
  let key-index = 0
  for char in text.codepoints() {
    let letter = upper(char)
    let position = plain-alphabet.codepoints().position(c => c == letter)
    if position != none {
      let key-char = word.at(calc.rem(key-index, word.len()))
      let key-position = plain-alphabet.codepoints().position(c => c == key-char)
      let moved = if inverse {
        calc.rem(position - key-position + 26, 26)
      } else {
        calc.rem(position + key-position, 26)
      }
      let replaced = plain-alphabet.at(moved)
      result += if char == letter { replaced } else { lower(replaced) }
      key-index += 1
    } else {
      result += char
    }
  }
  result
}

/// Verschlüsselt einen Text mit der Atbash-Chiffre (A↔Z, B↔Y, …).
///
/// Atbash ist selbstinvers: Dieselbe Funktion ver- und entschlüsselt.
///
/// ```typ
/// #atbash("HALLO") // "SZOOL"
/// ```
///
/// - ..args (arguments): genau ein Positionsargument: der Text (`str`), Klartext oder Geheimtext. Alte Namen werden hier abgefangen.
/// -> str
#let atbash(..args) = {
  check-positional("informatik", "atbash", args, max: 1,
    hint: "Atbash ist selbstinvers – nur den Text übergeben, `atbash(\"HALLO\")`")
  check-named("informatik", "atbash", args,
    removed: (advanced: "`atbash(text)` liefert den Text direkt"),
    allowed: ())
  let text = read-text("atbash", args.pos(),
    "`atbash(\"abc\")` schreiben; als Funktion weitergeben heißt `atbash` ohne Klammern",
    "\"HALLO\"")
  substitute(text, plain-alphabet, plain-alphabet.codepoints().rev().join(""))
}

/// Verschlüsselt einen Text mit ROT13, der Caesar-Chiffre mit Verschiebung 13.
///
/// ROT13 ist selbstinvers: Dieselbe Funktion ver- und entschlüsselt. Die
/// Schlüsseltabelle setzt `caesar-table(key: 13)`.
///
/// ```typ
/// #rot13("Hallo") // "Unyyb"
/// ```
///
/// - ..args (arguments): genau ein Positionsargument: der Text (`str`), Klartext oder Geheimtext. Alte Namen werden hier abgefangen.
/// -> str
#let rot13(..args) = {
  check-positional("informatik", "rot13", args, max: 1,
    hint: "ROT13 ist selbstinvers – das zweite Argument löschen, `rot13(\"Unyyb\")`")
  check-named("informatik", "rot13", args,
    removed: (
      key: "die Verschiebung ist immer 13; für andere Schlüssel `caesar(text, key: …)` schreiben",
      inverse: "ROT13 ist selbstinvers, `rot13(text)` entschlüsselt auch",
    ),
    allowed: ())
  let text = read-text("rot13", args.pos(),
    "`rot13(\"abc\")` schreiben; die Schlüsseltabelle setzt `caesar-table(key: 13)`",
    "\"Hallo\"")
  substitute(text, plain-alphabet, caesar-alphabet(13))
}
