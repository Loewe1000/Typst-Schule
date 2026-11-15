// Zahlensysteme: Umwandlung zwischen Binär-, Dezimal- und Hexadezimalzahlen.
#import "internal/check.typ": fail, check-type, show-value

#let hex-digits = "0123456789ABCDEF"

// Liest eine nicht negative Dezimalzahl aus int, float oder str.
#let read-decimal(function, value) = {
  check-type("informatik", function, "value", value, (int, float, str), example: "42")
  if type(value) == str and value.match(regex("^[+-]?[0-9]+$")) == none {
    fail("informatik", function, "`" + show-value(value) + "` ist keine Dezimalzahl – eine ganze Zahl schreiben, zum Beispiel `42`")
  }
  let number = int(value)
  if number < 0 {
    fail("informatik", function, "`" + show-value(value) + "` ist negativ – eine Zahl ab `0` schreiben")
  }
  number
}

/// Wandelt eine Binärzahl in eine Dezimalzahl um.
///
/// ```typ
/// #bin-to-dec("1010") // 10
/// ```
///
/// Andere Ziffern als `0` und `1` sind ein Fehler. Der leere Text ergibt `0`.
///
/// - value (str, int): Binärzahl, zum Beispiel `"1010"` oder `1010`
/// -> int
#let bin-to-dec(value) = {
  check-type("informatik", "bin-to-dec", "value", value, (str, int), example: "\"1010\"")
  let digits = str(value)
  if digits.match(regex("^[01]*$")) == none {
    fail("informatik", "bin-to-dec", "`" + show-value(value) + "` ist keine Binärzahl – nur die Ziffern `0` und `1` schreiben")
  }
  let result = 0
  for (i, bit) in digits.codepoints().enumerate() {
    if bit == "1" {
      result += calc.pow(2, digits.len() - i - 1)
    }
  }
  result
}

/// Wandelt eine Dezimalzahl in eine Binärzahl um.
///
/// ```typ
/// #dec-to-bin(42) // "101010"
/// ```
///
/// - value (int, float, str): Dezimalzahl ab 0; von einer Kommazahl zählt nur der ganzzahlige Anteil (`3.7` wie `3`)
/// -> str
#let dec-to-bin(value) = {
  let number = read-decimal("dec-to-bin", value)
  if number == 0 { return "0" }
  let result = ""
  while number > 0 {
    result = str(calc.rem(number, 2)) + result
    number = calc.quo(number, 2)
  }
  result
}

/// Wandelt eine Hexadezimalzahl in eine Dezimalzahl um.
///
/// Groß- und Kleinschreibung spielen keine Rolle.
///
/// ```typ
/// #hex-to-dec("FF") // 255
/// ```
///
/// Andere Zeichen als `0` bis `9` und `A` bis `F` sind ein Fehler. Der leere
/// Text ergibt `0`.
///
/// - value (str, int): Hexadezimalzahl, zum Beispiel `"FF"` oder `"2a"`
/// -> int
#let hex-to-dec(value) = {
  check-type("informatik", "hex-to-dec", "value", value, (str, int), example: "\"FF\"")
  let digits = upper(str(value))
  if digits.match(regex("^[0-9A-F]*$")) == none {
    fail("informatik", "hex-to-dec", "`" + show-value(value) + "` ist keine Hexadezimalzahl – nur die Ziffern `0` bis `9` und `A` bis `F` schreiben")
  }
  let result = 0
  for char in digits.codepoints() {
    result = result * 16 + hex-digits.position(char)
  }
  result
}

/// Wandelt eine Dezimalzahl in eine Hexadezimalzahl mit Großbuchstaben um.
///
/// ```typ
/// #dec-to-hex(255) // "FF"
/// ```
///
/// - value (int, float, str): Dezimalzahl ab 0; von einer Kommazahl zählt nur der ganzzahlige Anteil (`3.7` wie `3`)
/// -> str
#let dec-to-hex(value) = {
  let number = read-decimal("dec-to-hex", value)
  if number == 0 { return "0" }
  let result = ""
  while number > 0 {
    result = hex-digits.at(calc.rem(number, 16)) + result
    number = calc.quo(number, 16)
  }
  result
}
