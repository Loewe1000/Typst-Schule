// informatik 0.5.0: Zahlensysteme, Textblöcke (auch leerer Text), ASCII-Tabelle
// mit domains, rows, fields.
// erwartet: Z1 101010 11111111 0 10000000000
// erwartet: Z2 10 255 0
// erwartet: Z3 FF BEEF 0
// erwartet: Z4 255 42 48879
// erwartet: B1 HALLO WELTH EUTE
// erwartet: B2 Hal loW elt
// erwartet: B3 \[\]
// erwartet: Zeichen Dezimal Hex Binär
// erwartet: A 65 41 1000001
// erwartet: E 69 45 1000101
// erwartet: z 122
// nicht: \?
#import "@schule/informatik:0.5.0": bin-to-dec, dec-to-bin, hex-to-dec, dec-to-hex, text-to-blocks, ascii-table

Z1 #dec-to-bin(42) #dec-to-bin(255) #dec-to-bin(0) #dec-to-bin("1024")

Z2 #bin-to-dec("1010") #bin-to-dec(11111111) #bin-to-dec("0")

Z3 #dec-to-hex(255) #dec-to-hex(48879) #dec-to-hex(0)

Z4 #hex-to-dec("FF") #hex-to-dec("2a") #hex-to-dec("beef")

B1 #text-to-blocks("HALLO WELT HEUTE")

B2 #text-to-blocks("Hallo, Welt!", character-count: 3)

B3 [#text-to-blocks("")#text-to-blocks("123 !")]

#ascii-table(domains: (("A", "E"),), rows: 5, fields: ("character", "dec", "hex", "bin"))

#ascii-table()

#ascii-table(domains: ((" ", "/"), "a", ("x", "z")), rows: 4, fields: ("character", "bin"), colored: false)
