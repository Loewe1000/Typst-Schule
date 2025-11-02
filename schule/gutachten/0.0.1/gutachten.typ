#import "./bewertung.typ": *

#let __s_sachgebiete = state("sachgebiete", ())
#let __s_pflichtteil = state("pflichtteil", ())
#let __s_anrede = state("anrede", "")
#let __s_gutachten-optionen = state("gutachten-optionen", "")

#let pflichtteil(punkte: 0, BE: 40, wahl: (), body) = {
  context __s_pflichtteil.update({
    (punkte: punkte, BE: BE, wahl: wahl)
  })

  body

  par([Insgesamt erreicht #context __s_anrede.get().vn im Prüfungsteil A *$#punkte$* von *$#BE$* Punkten.])
  v(3mm)
}

#let sachgebiet(title: "Analysis", punkte: 0, BE: 40, wahl: "A", body) = {
  context{
  __s_sachgebiete.update(s => {
    s.push((t: title, be: BE, punkte: punkte, w: wahl))
    s
  })
  par[=== #title (#{__s_sachgebiete.get().len()+1}#wahl)]
  } 
  

  body

  par([Insgesamt erreicht #context __s_anrede.get().vn im Block #emph(title) *$#punkte$* von *$#BE$* Punkten.])
  v(0.5em)
}

#let name = {
  context __s_anrede.get().vn
}

#let gutachten-optionen(
  ..args
) = {
  context __s_gutachten-optionen.update({
    args
  })
}

#let __gutachten-header(name: "Herr Test") = {
  context{
  let args = __s_gutachten-optionen.final().named()
  let __niveau = ""
  if lower(args.niveau) == "ea" {
    __niveau = "erhöhtem"
  } else {
    __niveau = "grundlegendem"
  }

  align(center,text(11pt, [#text(20pt, weight: "bold", "Gutachten")\  zur schriftlichen Abiturprüfung #args.jahr des Prüflings\ #text(14pt, weight: "bold", name)\ im Fach #args.fach auf #__niveau Niveau]))

  
  [*Prüfungsgruppe:* #args.kurs]
  h(1fr)
  [*Prüfer#{if lower(args.prüfer).contains("frau "){"in"}}:* #args.prüfer]
  h(1fr)
  [*Korreferent#{if lower(args.korreferent).contains("frau "){"in"}}* #args.korreferent]
  } 
}

#let gutachten(
  vorname: "Max",
  name: "Mustermann",
  geschlecht: "m",
  jahr: datetime.today().display("[year]"),
  fach: "Mathematik",
  niveau: "ea",
  kurs: "MA3",
  prüfer: "Herr Test",
  korreferent: "Frau Test",
  BE: 100,
  ..args,
  body,
) = page(
  margin: (top:2.6cm, bottom: 2cm, left: 2cm, right: 2cm),
  header-ascent: 15%,
  header: [
    #stack(dir:ttb,spacing: 3mm,
    text(font:"Lucida Grande", size:20pt, [Angelaschule Osnabrück]),
    text(font: "Arial", stretch: 75%, size: 8pt,[Staatlich anerkanntes Gymnasium der Schulstiftung im Bistum Osnabrück]))
    #v(-2mm)
    #line(length: 100%, stroke: 0.25pt)
    #place(top+right, dy: 0.5cm, image("logo.svg", height: 1.7cm))
  ],{
  __s_sachgebiete.update({()})
  __s_pflichtteil.update({()})
  set text(11pt, font: "Myriad Pro", hyphenate: true, lang: "de")
  set par(leading: 0.8em, justify: true)
  //set text(hyphenate: true)
  show math.equation: set text(font: "Fira Math")
    show math.equation: it => {
    show regex("\d+\.\d+"): it => {
      show ".": { "," + h(0pt) }
      it
    }
    it
  }

  let __anrede = (:)
  __anrede.vn = vorname
  if lower(geschlecht) == "w" {
    __anrede.nn = "Frau " + name
  } else {
    __anrede.nn = "Herr " + name
  }
  __s_anrede.update({__anrede})

  let __wahl_a() = {
      [*Aufgabenwahl im Prüfungsteil A: *]
      context{
        let __aufgaben_wahl = __s_pflichtteil.at(label(vorname+name))
        if __aufgaben_wahl != () {
          __aufgaben_wahl.wahl.map(q => {[#q]}).join("; ")
        }
      }
  }

  let __wahl_b() = {
    [*Aufgabenwahl im Prüfungsteil B: *]
    context{
      let __aufgaben_wahl = ()
      for (key, s) in __s_sachgebiete.at(label(vorname+name)).enumerate() {
      __aufgaben_wahl.push([#str((key + 1))#str(s.w)])
      }
      __aufgaben_wahl.join("; ")
    } 
  }

  let ew_verteilung_oberstufe = (
	.0,
	.20, .27, .33,
	.40, .45, .50,
	.55, .60, .65,
	.70, .75, .80,
	.85, .90, .95,
)

let ew_namen_oberstufe = (
	"ungenügend",
	"mangelhaft","mangelhaft","mangelhaft",
	"ausreichend","ausreichend","ausreichend",
	"befriedigend","befriedigend","befriedigend",
	"gut","gut","gut",
	"sehr gut","sehr gut","sehr gut"
)

  let __auswertung() = {
    context{
      let punkte = __s_sachgebiete.at(label(vorname+name)).map(s => s.punkte).sum()
      let __aufgaben_wahl = __s_pflichtteil.at(label(vorname+name))
      let be-maximal = __s_sachgebiete.at(label(vorname+name)).map(s => s.be).sum()
      if __aufgaben_wahl != () {
        punkte += __aufgaben_wahl.punkte
        be-maximal += __aufgaben_wahl.BE
      }
      let prozent = calc.round(100 * (punkte / be-maximal), digits: 2)
      let notenpunkte = 0
      let notenpunkte-key = 0
      while ew_verteilung_oberstufe.at(notenpunkte-key) <= (punkte / be-maximal) {
       notenpunkte-key += 1 
      }
      notenpunkte-key -= 1
      let notenpunkte-name = ew_namen_oberstufe.at(notenpunkte-key)
      v(1.5em)
      box({
      par([Insgesamt zeigt #__s_anrede.get().vn eine in Form und Inhalt #{notenpunkte-name+"e"} Leistung.\
      #if lower(geschlecht) == "w" { "Sie" } else {"Er"} erreicht *$#punkte$* von *$#be-maximal$* Punkten; das entspricht *$#prozent%$*.
      ])
      v(1em)
      par([Die gezeigte Leistung wird daher mit der Note])
      v(0.5em)
      box(width: 100%, par(align(center,text(20pt, weight: "bold", [#notenpunkte-name (#notenpunkte-key #if notenpunkte-key == 1 {"Punkt"} else {"Punkte"})]))))
      v(0.5em)
      par([bewertet.])
      })
    }
  }

  let __unterschriften() = {
    v(4em)
    line(length: 7cm)
    v(-0.7em)
    context [
      #let referent = __s_gutachten-optionen.final().named().prüfer
      #let korreferent = __s_gutachten-optionen.final().named().korreferent
      Ort, Datum, Unterschrift (Referent#{if lower(prüfer).contains("frau "){"in"}})
      #v(4em)
      #line(length: 100%)  
      #v(3em)
      #line(length: 100%)  
      #v(4em)
      #line(length: 7cm)  
      #v(-0.7em)
      Ort, Datum, Unterschrift (Korreferent#{if lower(korreferent).contains("frau "){"in"}})
      #label(vorname+name)
    ]
  }

  __gutachten-header(name: vorname + " " + name)

  v(0.25em)

  //grid(columns: 2*(1fr,),
    __wahl_a()
    h(1fr)
    __wahl_b()
  //)

  v(0.5em)

  body

  __auswertung()

  v(1fr)

  box({
  __unterschriften()
  })
})