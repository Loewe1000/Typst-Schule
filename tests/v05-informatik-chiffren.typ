// informatik 0.5.0: alle Chiffren in der Aufrufform chiffre(text, key: …),
// Schlüsseltabelle, Häufigkeitsanalyse mit den Schlüsseln counts,
// frequencies, items, chart, text.
// erwartet: C1 Kdoor Zhow, 123!
// erwartet: C2 Hallo Welt, 123!
// erwartet: C3 Pgttw Fmtb
// erwartet: C4 Hallo Welt
// erwartet: C5 KDOOR
// erwartet: GA D E F G H I J K L M N O P Q R S T U V W X Y Z A B C
// erwartet: GA I N F O R M A T K L P Q S U V W X Y Z B C D E G H J
// erwartet: V1 Lxfopv ef Rnhr
// erwartet: V2 Attack at Dawn
// erwartet: R1 Unyyb Jryg
// erwartet: R2 Hallo Welt
// erwartet: A1 Szool Dvog 42
// erwartet: A2 Hallo Welt 42
// erwartet: H1 3 1 33 26
// erwartet: H2 Hallo Welt
// nicht: heißt jetzt
#import "@schule/informatik:0.5.0": caesar, caesar-table, vigenere, atbash, rot13, haeufigkeitsanalyse

C1 #caesar("Hallo Welt, 123!", key: 3)

C2 #caesar("Kdoor Zhow, 123!", key: 3, inverse: true)

C3 #caesar("Hallo Welt", key: "GEHEIM")

C4 #caesar("Pgttw Fmtb", key: "GEHEIM", inverse: true)

#let drei = caesar.with(key: 3)
C5 #drei("HALLO")

#caesar-table(key: 3)
#caesar-table(key: "INFORMATIK")

V1 #vigenere("Attack at Dawn", key: "Le Mon 7")

V2 #vigenere("Lxfopv ef Rnhr", key: "LEMON", inverse: true)

R1 #rot13("Hallo Welt")

R2 #rot13(rot13("Hallo Welt"))

A1 #atbash("Hallo Welt 42")

A2 #atbash(atbash("Hallo Welt 42"))

#let analysis = haeufigkeitsanalyse("Hallo Welt")
H1 #analysis.counts.L #analysis.counts.at("O") #calc.round(analysis.frequencies.L) #analysis.items.len()

H2 #analysis.text

#analysis.chart
