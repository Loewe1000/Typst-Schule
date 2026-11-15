// Levenshtein-Distanz (rein, ohne Plugins)
#let _lev(a, b) = {
  let a = a.clusters(); let b = b.clusters()
  let prev = range(b.len() + 1)
  for (i, ca) in a.enumerate() {
    let cur = (i + 1,)
    for (j, cb) in b.enumerate() {
      cur.push(calc.min(prev.at(j + 1) + 1, cur.at(j) + 1, prev.at(j) + if ca == cb { 0 } else { 1 }))
    }
    prev = cur
  }
  prev.last()
}
#let _vorschlag(name, erlaubt) = {
  let best = erlaubt.map(e => (_lev(name, e), e)).sorted(key: p => p.at(0))
  if best.len() > 0 and best.first().at(0) <= calc.max(2, calc.floor(name.len() / 3)) { best.first().at(1) } else { none }
}
/// Prüft/übersetzt benannte Argumente.
/// - umbenannt: (alt: "neu") oder (alt: (name: "neu", wert: v => ..))
/// - entfernt: (alt: "Hinweistext")
/// - streng: true = alte Namen sind Fehler; false = alte Namen werden still abgebildet
#let args-migrieren(paket, named, erlaubt: (), umbenannt: (:), entfernt: (:), streng: false) = {
  let neu = (:)
  let alt-benutzt = ()
  for (k, v) in named {
    if k in umbenannt {
      let ziel = umbenannt.at(k)
      let (n, w) = if type(ziel) == str { (ziel, v) } else { (ziel.name, (ziel.wert)(v)) }
      assert(not streng, message: paket + ": `" + k + "` heißt jetzt `" + n + "`")
      assert(n not in named, message: paket + ": `" + k + "` (alt) und `" + n + "` (neu) gleichzeitig angegeben")
      neu.insert(n, w); alt-benutzt.push((k, n))
    } else if k in entfernt {
      panic(paket + ": `" + k + "` gibt es nicht mehr – " + entfernt.at(k))
    } else if k in erlaubt {
      neu.insert(k, v)
    } else {
      let v2 = _vorschlag(k, erlaubt + umbenannt.keys())
      panic(paket + ": unbekannte Option `" + k + "`" + if v2 != none { " – meintest du `" + v2 + "`?" } else { " – erlaubt: " + erlaubt.join(", ") })
    }
  }
  (args: neu, alt: alt-benutzt)
}
