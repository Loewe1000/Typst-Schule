// executable.typ — Ausführbare Scratch-Blöcke für blockst-run()
// Diese Blöcke geben Dictionaries zurück, die vom Interpreter ausgeführt werden

// =====================================================
// BEWEGUNG (Motion) - Turtle Graphics
// =====================================================

#let gehe(schritte: 10) = (type: "move", steps: schritte)
#let drehe-rechts(grad: 15) = (type: "turn-right", degrees: grad)
#let drehe-links(grad: 15) = (type: "turn-left", degrees: grad)
#let setze-richtung(richtung: 90) = (type: "set-direction", angle: richtung)
#let gehe-zu(x: 0, y: 0) = (type: "goto", x: x, y: y)
#let setze-x(x: 0) = (type: "set-x", x: x)
#let setze-y(y: 0) = (type: "set-y", y: y)
#let aendere-x(dx: 10) = (type: "change-x", dx: dx)
#let aendere-y(dy: 10) = (type: "change-y", dy: dy)

// Reporter (geben Werte zurück)
#let x-position() = (type: "get", property: "x")
#let y-position() = (type: "get", property: "y")
#let richtung() = (type: "get", property: "angle")

// =====================================================
// MALSTIFT (Pen)
// =====================================================

#let loesche-alles() = (type: "clear")
#let hinterlasse-abdruck() = (type: "stamp")
#let schalte-stift-ein() = (type: "pen-down")
#let stift-ein() = (type: "pen-down")  // Alias
#let schalte-stift-aus() = (type: "pen-up")
#let stift-aus() = (type: "pen-up")  // Alias
#let setze-stiftfarbe-auf(farbe: black) = (type: "set-color", color: farbe)
#let setze-farbe(farbe: black) = (type: "set-color", color: farbe)  // Alias
#let aendere-stiftdicke(dicke: 1) = (type: "change-size", delta: dicke)
#let setze-stiftdicke(dicke: 1) = (type: "set-size", size: dicke)
#let setze-dicke(dicke: 1) = (type: "set-size", size: dicke)  // Alias

// Stift-Parameter (Farbe, Sättigung, Helligkeit, Transparenz)
#let aendere-stift-param(param, wert: 10) = (
  type: "change-pen-param",
  param: param,
  delta: wert
)
#let setze-stift-param(param, wert: 50) = (
  type: "set-pen-param", 
  param: param,
  value: wert
)

// =====================================================
// VARIABLEN & OPERATOREN
// =====================================================

// Variablen setzen/ändern
#let setze-variable(name, wert) = (type: "set-var", name: name, value: wert)
#let aendere-variable(name, delta) = (type: "change-var", name: name, delta: delta)

// Variable lesen (gibt Wert zurück)
#let variable(name) = (type: "get-var", name: name)

// Operatoren
#let plus(a, b) = (type: "add", a: a, b: b)
#let minus(a, b) = (type: "subtract", a: a, b: b)
#let mal(a, b) = (type: "multiply", a: a, b: b)
#let geteilt(a, b) = (type: "divide", a: a, b: b)
#let zufallszahl(von: 1, bis: 10) = (type: "random", from: von, to: bis)
#let modulo(a, b) = (type: "mod", a: a, b: b)
#let runde(zahl) = (type: "round", value: zahl)

// Vergleiche
#let groesser(a, b) = (type: "greater", a: a, b: b)
#let kleiner(a, b) = (type: "less", a: a, b: b)
#let gleich(a, b) = (type: "equals", a: a, b: b)

// Logik
#let und(a, b) = (type: "and", a: a, b: b)
#let oder(a, b) = (type: "or", a: a, b: b)
#let nicht(a) = (type: "not", a: a)

// =====================================================
// STEUERUNG (Control Flow)
// =====================================================

// Hinweis: Diese werden in Typst-Code direkt verwendet (if/for/while)
// aber wir bieten auch Scratch-style Wrapper

#let warte(sekunden: 1) = (type: "wait", duration: sekunden)

// Für wiederhole, falls, etc. nutzen wir native Typst-Konstrukte:
// - for i in range(n) { ... } statt wiederhole(n)
// - if bedingung { ... } statt falls(bedingung)
// - while bedingung { ... } statt wiederhole-bis(bedingung)

// =====================================================
// AUSSEHEN (Looks) - Für Debugging/Anzeige
// =====================================================

#let sage(nachricht) = (type: "say", message: nachricht)
#let denke(nachricht) = (type: "think", message: nachricht)

// =====================================================
// HILFSFUNKTIONEN
// =====================================================

// Makros für häufige Muster
#let quadrat(groesse: 50) = {
  for i in range(4) {
    (gehe(schritte: groesse), drehe-rechts(grad: 90))
  }
}

#let dreieck(groesse: 50) = {
  for i in range(3) {
    (gehe(schritte: groesse), drehe-rechts(grad: 120))
  }
}

#let kreis(radius: 50, schritte: 36) = {
  let umfang = 2 * calc.pi * radius
  let schritt-groesse = umfang / schritte
  let winkel = 360 / schritte
  
  for i in range(schritte) {
    (gehe(schritte: schritt-groesse), drehe-rechts(grad: winkel))
  }
}

#let stern(groesse: 50, zacken: 5) = {
  let winkel = 360 / zacken
  for i in range(zacken) {
    (gehe(schritte: groesse), drehe-rechts(grad: 180 - winkel))
  }
}

// Spirale
#let spirale(start: 5, ende: 100, schritte: 50) = {
  let winkel = 360 / schritte
  for i in range(schritte) {
    let groesse = start + (ende - start) * i / schritte
    (gehe(schritte: groesse), drehe-rechts(grad: winkel))
  }
}

// Export für einfachen Import
#let exec = (
  // Bewegung
  gehe: gehe,
  drehe-rechts: drehe-rechts,
  drehe-links: drehe-links,
  setze-richtung: setze-richtung,
  gehe-zu: gehe-zu,
  setze-x: setze-x,
  setze-y: setze-y,
  aendere-x: aendere-x,
  aendere-y: aendere-y,
  x-position: x-position,
  y-position: y-position,
  richtung: richtung,
  
  // Malstift
  loesche-alles: loesche-alles,
  hinterlasse-abdruck: hinterlasse-abdruck,
  stift-ein: stift-ein,
  stift-aus: stift-aus,
  schalte-stift-ein: schalte-stift-ein,
  schalte-stift-aus: schalte-stift-aus,
  setze-farbe: setze-farbe,
  setze-stiftfarbe-auf: setze-stiftfarbe-auf,
  setze-dicke: setze-dicke,
  setze-stiftdicke: setze-stiftdicke,
  aendere-stiftdicke: aendere-stiftdicke,
  aendere-stift-param: aendere-stift-param,
  setze-stift-param: setze-stift-param,
  
  // Variablen
  setze-variable: setze-variable,
  aendere-variable: aendere-variable,
  variable: variable,
  
  // Operatoren
  plus: plus,
  minus: minus,
  mal: mal,
  geteilt: geteilt,
  zufallszahl: zufallszahl,
  modulo: modulo,
  runde: runde,
  groesser: groesser,
  kleiner: kleiner,
  gleich: gleich,
  und: und,
  oder: oder,
  nicht: nicht,
  
  // Steuerung
  warte: warte,
  
  // Aussehen
  sage: sage,
  denke: denke,
  
  // Hilfsfunktionen
  quadrat: quadrat,
  dreieck: dreieck,
  kreis: kreis,
  stern: stern,
  spirale: spirale,
)
