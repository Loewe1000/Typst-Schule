// Alte Funktionsnamen. Jeder Aufruf bricht mit dem neuen Namen ab.
#import "internal/check.typ": fail, stub

#let häufigkeitsanalyse = stub("informatik", "häufigkeitsanalyse", "haeufigkeitsanalyse")
#let bin2dec = stub("informatik", "bin2dec", "bin-to-dec")
#let dec2bin = stub("informatik", "dec2bin", "dec-to-bin")
#let hex2dec = stub("informatik", "hex2dec", "hex-to-dec")
#let dec2hex = stub("informatik", "dec2hex", "dec-to-hex")
#let mono(..args) = fail("informatik", "mono", "`mono` gibt es nicht mehr – `raw(\"…\")` schreiben")
