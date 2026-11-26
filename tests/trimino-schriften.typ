// erwartet: Vorgabe: fira sans 400 Fira Math
// erwartet: Fira: fira sans 400 Fira Math
// erwartet: Libertinus-Dokument: fira sans 400 Fira Math
// erwartet: NCM-Dokument: new computer modern 450 New Computer Modern Math
// erwartet: klassisch: new computer modern 450 New Computer Modern Math
// erwartet: math-Schlüssel: stix two text 400 STIX Two Math
// erwartet: Paar: fira sans 400 Fira Math
// erwartet: Name: stix two text 400 STIX Two Math
// Schriften der Beschriftungen (`font: auto`): das Paar Fira Sans + Fira Math
// als Vorgabe (auch zu Typsts Libertinus Serif), sonst das Paar zur
// Dokumentschrift; New Computer Modern nur, wenn das Dokument sie setzt oder
// `font: "klassisch"`.
#import "/trimino/0.5.0/src/internal.typ": themes, label-fonts

#let zeige(name, f) = [#name: #lower(f.text.first()) #f.weight #if f.math == none [Dokumentmathe] else [#f.math] \ ]

#context zeige("Vorgabe", label-fonts(themes.riso))
#[
  #set text(font: "Fira Sans")
  #context zeige("Fira", label-fonts(themes.riso))
]
#[
  #set text(font: "Libertinus Serif")
  #context zeige("Libertinus-Dokument", label-fonts(themes.klar))
]
#[
  #set text(font: "New Computer Modern")
  #context zeige("NCM-Dokument", label-fonts(themes.riso))
]
#context zeige("klassisch", label-fonts(themes.riso + (font: "klassisch")))
#context zeige("math-Schlüssel", label-fonts(themes.riso + (math: "STIX Two Math")))
#context zeige("Paar", label-fonts(themes.riso + (font: "serifenlos")))
#context zeige("Name", label-fonts(themes.riso + (font: "STIX Two Text")))
