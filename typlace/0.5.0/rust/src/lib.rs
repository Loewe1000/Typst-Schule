//! Sitzordnungs-Optimierer als WASM-Plugin für typlace.
//!
//! Diese Datei ist eine 1:1-Übertragung von `optimierer.typ` und der
//! Bewertung aus `bewertung.typ` – gleicher Zufallsgenerator, gleiche
//! Reihenfolge der Tausche, gleiche Reihenfolge der Additionen. Dadurch
//! liefern beide Fassungen bei gleichem Seed denselben Plan, und die
//! Typst-Fassung bleibt die überprüfbare Referenz.
//!
//! Übergeben wird ein einziger Text aus durch Leerzeichen getrennten
//! Zahlen (siehe `wasm.typ`), zurück kommt die Platzbelegung.

#[link(wasm_import_module = "typst_env")]
extern "C" {
    fn wasm_minimal_protocol_send_result_to_host(ptr: *const u8, len: usize);
    fn wasm_minimal_protocol_write_args_to_buffer(ptr: *mut u8);
}

fn sende(text: &str) {
    unsafe { wasm_minimal_protocol_send_result_to_host(text.as_ptr(), text.len()) }
}

// ── Zufall: identisch zu optimierer.typ ────────────────────────────

const M: i64 = 2_147_483_648;

fn weiter(z: i64) -> i64 {
    (z * 1_103_515_245 + 12_345).rem_euclid(M)
}

/// Zufallszahl aus [0, n) – aus den oberen Bits, siehe `_wahl` in
/// optimierer.typ: die unteren Bits eines LCG mit Zweierpotenz-Modul sind
/// fast periodisch und würden die Startpläne einander angleichen.
fn wahl(z: i64, n: usize) -> usize {
    ((z / 65_536) as usize) % n
}

fn mischen(liste: &mut Vec<usize>, mut z: i64) -> i64 {
    let mut i = liste.len();
    while i > 1 {
        i -= 1;
        z = weiter(z);
        let j = wahl(z, i + 1);
        liste.swap(i, j);
    }
    z
}

// ── Daten ──────────────────────────────────────────────────────────

struct Platz {
    zeile: i64,
    spalte: i64,
    tisch: i64,
    tiefe: i64,
    seite: i64,
}

#[derive(Default)]
struct Schueler {
    wuensche: Vec<usize>,
    ablehnungen: Vec<usize>,
    getrennt: Vec<usize>,
    zusammen: Vec<usize>,
    pos_tiefe: i64,
    pos_seite: i64,
    meidet_tiefe: u32,
    meidet_seite: u32,
}

struct Gewichte {
    direkt: f64,
    tisch: f64,
    fairness: f64,
    ablehnung: f64,
    hart: f64,
    position: f64,
    position_meidet: f64,
    raenge: [f64; 3],
    stufen: [f64; 3],
    /// Faktor nach Anzahl der *genannten* Wünsche (einer, zwei, drei+).
    wunschzahl: [f64; 3],
}

struct Aufgabe {
    plaetze: Vec<Platz>,
    schueler: Vec<Schueler>,
    gewichte: Gewichte,
    beziehung: Vec<u8>, // 0 fern, 1 selber Tisch, 2 direkt benachbart
    /// Wer ändert seine Punktzahl, wenn Schüler i den Platz wechselt?
    /// Gleiche Bauart und gleiche Reihenfolge wie `rueckwaerts` in
    /// bewertung.typ – erst alle, die ihn gewünscht haben, dann die
    /// übrigen Nennungen.
    rueckwaerts: Vec<Vec<usize>>,
    erlaubt: Vec<bool>,
    fest: Vec<i64>,
    versuche: usize,
    max_schritte: usize,
    seed: i64,
}

impl Aufgabe {
    fn anzahl_plaetze(&self) -> usize {
        self.plaetze.len()
    }
    fn anzahl_schueler(&self) -> usize {
        self.schueler.len()
    }
    fn bez(&self, p: usize, q: usize) -> u8 {
        self.beziehung[p * self.plaetze.len() + q]
    }
    fn darf(&self, i: usize, p: usize) -> bool {
        self.erlaubt[i * self.plaetze.len() + p]
    }

    /// Wert einer Beziehung, wie `_beziehungswert` in bewertung.typ.
    fn wert(&self, p: usize, q: usize) -> f64 {
        match self.bez(p, q) {
            2 => self.gewichte.direkt,
            1 => self.gewichte.tisch,
            _ => 0.0,
        }
    }

    /// Entspricht `punkte-wert`. Die Reihenfolge der Additionen ist
    /// bewusst dieselbe wie in Typst, damit beide Fassungen aufs Bit
    /// genau übereinstimmen.
    fn punkte(&self, platz_von: &[i64], i: usize) -> f64 {
        let p = platz_von[i];
        if p < 0 {
            return 0.0;
        }
        let p = p as usize;
        let g = &self.gewichte;
        let s = &self.schueler[i];
        let mut summe = 0.0;
        let mut sozial = 0.0;
        let mut treffer = 0usize;

        for (rang, &w) in s.wuensche.iter().enumerate() {
            let q = platz_von[w];
            if q < 0 {
                continue;
            }
            let wert = self.wert(p, q as usize);
            if wert <= 0.0 {
                continue;
            }
            let rg = g.raenge[rang.min(2)];
            let stufe = g.stufen[treffer.min(2)];
            sozial += rg * wert * stufe;
            treffer += 1;
        }
        if treffer > 0 {
            sozial += g.fairness;
        }
        // Wer wenige Namen genannt hat, hat keine Ausweichwünsche
        let faktor = if s.wuensche.is_empty() {
            1.0
        } else {
            g.wunschzahl[(s.wuensche.len() - 1).min(2)]
        };
        summe += faktor * sozial;

        for &a in &s.ablehnungen {
            let q = platz_von[a];
            if q < 0 {
                continue;
            }
            let wert = self.wert(p, q as usize);
            if wert > 0.0 {
                summe += g.ablehnung * wert;
            }
        }

        let tisch = self.plaetze[p].tisch;
        for &x in &s.getrennt {
            let q = platz_von[x];
            if q >= 0 && self.plaetze[q as usize].tisch == tisch {
                summe += g.hart;
            }
        }
        for &x in &s.zusammen {
            let q = platz_von[x];
            if q >= 0 && self.plaetze[q as usize].tisch != tisch {
                summe += g.hart;
            }
        }

        let (tiefe, seite) = (self.plaetze[p].tiefe, self.plaetze[p].seite);
        if s.pos_tiefe == tiefe {
            summe += g.position;
        }
        if s.meidet_tiefe & (1 << tiefe) != 0 {
            summe += g.position_meidet;
        }
        if s.pos_seite == seite {
            summe += g.position;
        }
        if s.meidet_seite & (1 << seite) != 0 {
            summe += g.position_meidet;
        }

        summe
    }

    /// Hat dieser Schüler noch etwas zu gewinnen? Entspricht der
    /// Vorauswahl in `_verbessern`.
    fn potenzial(&self, platz_von: &[i64], i: usize) -> bool {
        let p = platz_von[i];
        if p < 0 {
            return true;
        }
        let p = p as usize;
        let s = &self.schueler[i];

        let mut erfuellt = 0usize;
        for &w in &s.wuensche {
            let q = platz_von[w];
            if q >= 0 && self.wert(p, q as usize) > 0.0 {
                erfuellt += 1;
            }
        }
        if erfuellt < s.wuensche.len() {
            return true;
        }
        for &a in &s.ablehnungen {
            let q = platz_von[a];
            if q >= 0 && self.wert(p, q as usize) > 0.0 {
                return true;
            }
        }
        let tisch = self.plaetze[p].tisch;
        for &x in &s.getrennt {
            let q = platz_von[x];
            if q >= 0 && self.plaetze[q as usize].tisch == tisch {
                return true;
            }
        }
        for &x in &s.zusammen {
            let q = platz_von[x];
            if q >= 0 && self.plaetze[q as usize].tisch != tisch {
                return true;
            }
        }

        let (tiefe, seite) = (self.plaetze[p].tiefe, self.plaetze[p].seite);
        if s.meidet_tiefe & (1 << tiefe) != 0 || s.meidet_seite & (1 << seite) != 0 {
            return true;
        }
        if s.pos_tiefe >= 0 && s.pos_tiefe != tiefe {
            return true;
        }
        if s.pos_seite >= 0 && s.pos_seite != seite {
            return true;
        }
        false
    }
}

// ── Suche ──────────────────────────────────────────────────────────

struct Lauf {
    zuordnung: Vec<i64>,
    schritte: usize,
    geprueft: usize,
    z: i64,
}

fn startplan(a: &Aufgabe, mut z: i64) -> Option<(Vec<i64>, i64)> {
    let np = a.anzahl_plaetze();
    let mut zuordnung = vec![-1i64; np];
    let mut belegt = vec![false; np];

    for (i, &p) in a.fest.iter().enumerate() {
        if p >= 0 {
            zuordnung[p as usize] = i as i64;
            belegt[p as usize] = true;
        }
    }

    let mut offen: Vec<usize> = (0..a.anzahl_schueler()).filter(|&i| a.fest[i] < 0).collect();
    z = mischen(&mut offen, z);
    // stabil sortieren: am stärksten eingeschränkte Schüler zuerst
    offen.sort_by_key(|&i| (0..np).filter(|&p| a.darf(i, p)).count());

    for i in offen {
        let frei: Vec<usize> = (0..np).filter(|&p| !belegt[p] && a.darf(i, p)).collect();
        if frei.is_empty() {
            return None;
        }
        z = weiter(z);
        let p = frei[wahl(z, frei.len())];
        zuordnung[p] = i as i64;
        belegt[p] = true;
    }
    Some((zuordnung, z))
}

fn verbessern(a: &Aufgabe, mut zuordnung: Vec<i64>, beweglich: &[usize], mut z: i64) -> Lauf {
    let np = a.anzahl_plaetze();
    let mut platz_von = vec![-1i64; a.anzahl_schueler()];
    for (p, &s) in zuordnung.iter().enumerate() {
        if s >= 0 {
            platz_von[s as usize] = p as i64;
        }
    }

    let mut schritte = 0usize;
    let mut geprueft = 0usize;
    let mut weiter_suchen = true;
    let mut betroffen: Vec<usize> = Vec::with_capacity(16);

    while weiter_suchen && schritte < a.max_schritte {
        weiter_suchen = false;

        let mut interessant: Vec<usize> = Vec::new();
        for &p in beweglich {
            let i = zuordnung[p];
            if i < 0 || a.potenzial(&platz_von, i as usize) {
                interessant.push(p);
            }
        }
        if interessant.is_empty() {
            break;
        }

        z = mischen(&mut interessant, z);
        let mut partner: Vec<usize> = beweglich.to_vec();
        z = mischen(&mut partner, z);

        'aussen: for &p in &interessant {
            for &q in &partner {
                if p == q {
                    continue;
                }
                let i = zuordnung[p];
                let j = zuordnung[q];
                if i < 0 && j < 0 {
                    continue;
                }
                if i >= 0 && !a.darf(i as usize, q) {
                    continue;
                }
                if j >= 0 && !a.darf(j as usize, p) {
                    continue;
                }

                geprueft += 1;

                // Betroffen sind die Umziehenden und alle, die sie genannt
                // haben – über den vorberechneten Index, nicht durch Suchen.
                betroffen.clear();
                for s in [i, j] {
                    if s < 0 {
                        continue;
                    }
                    let s = s as usize;
                    if !betroffen.contains(&s) {
                        betroffen.push(s);
                    }
                    for &r in &a.rueckwaerts[s] {
                        if !betroffen.contains(&r) {
                            betroffen.push(r);
                        }
                    }
                }

                let vorher: f64 = betroffen.iter().map(|&s| a.punkte(&platz_von, s)).sum();
                if i >= 0 {
                    platz_von[i as usize] = q as i64;
                }
                if j >= 0 {
                    platz_von[j as usize] = p as i64;
                }
                let nachher: f64 = betroffen.iter().map(|&s| a.punkte(&platz_von, s)).sum();

                if nachher - vorher > 1e-6 {
                    zuordnung[p] = j;
                    zuordnung[q] = i;
                    schritte += 1;
                    weiter_suchen = true;
                    if schritte >= a.max_schritte {
                        break 'aussen;
                    }
                } else {
                    // zurücknehmen
                    if i >= 0 {
                        platz_von[i as usize] = p as i64;
                    }
                    if j >= 0 {
                        platz_von[j as usize] = q as i64;
                    }
                }
            }
        }
        let _ = np;
    }

    Lauf { zuordnung, schritte, geprueft, z }
}

fn gesamtpunkte(a: &Aufgabe, zuordnung: &[i64]) -> f64 {
    let mut platz_von = vec![-1i64; a.anzahl_schueler()];
    for (p, &s) in zuordnung.iter().enumerate() {
        if s >= 0 {
            platz_von[s as usize] = p as i64;
        }
    }
    (0..a.anzahl_schueler()).map(|i| a.punkte(&platz_von, i)).sum()
}

// ── Ein-/Ausgabe ───────────────────────────────────────────────────

struct Leser<'a> {
    teile: std::str::SplitAsciiWhitespace<'a>,
}

impl<'a> Leser<'a> {
    fn neu(text: &'a str) -> Self {
        Leser { teile: text.split_ascii_whitespace() }
    }
    fn i(&mut self) -> Result<i64, String> {
        self.teile
            .next()
            .ok_or_else(|| "Eingabe zu kurz".to_string())?
            .parse::<i64>()
            .map_err(|e| format!("Zahl erwartet: {e}"))
    }
    fn f(&mut self) -> Result<f64, String> {
        self.teile
            .next()
            .ok_or_else(|| "Eingabe zu kurz".to_string())?
            .parse::<f64>()
            .map_err(|e| format!("Kommazahl erwartet: {e}"))
    }
    fn liste(&mut self) -> Result<Vec<usize>, String> {
        let k = self.i()? as usize;
        (0..k).map(|_| Ok(self.i()? as usize)).collect()
    }
}

fn lies(text: &str) -> Result<Aufgabe, String> {
    let mut l = Leser::neu(text);

    let np = l.i()? as usize;
    let ns = l.i()? as usize;
    let versuche = l.i()? as usize;
    let max_schritte = l.i()? as usize;
    let seed = l.i()?;

    let gewichte = Gewichte {
        direkt: l.f()?,
        tisch: l.f()?,
        fairness: l.f()?,
        ablehnung: l.f()?,
        hart: l.f()?,
        position: l.f()?,
        position_meidet: l.f()?,
        raenge: [l.f()?, l.f()?, l.f()?],
        stufen: [l.f()?, l.f()?, l.f()?],
        wunschzahl: [l.f()?, l.f()?, l.f()?],
    };

    let mut plaetze = Vec::with_capacity(np);
    for _ in 0..np {
        plaetze.push(Platz {
            zeile: l.i()?,
            spalte: l.i()?,
            tisch: l.i()?,
            tiefe: l.i()?,
            seite: l.i()?,
        });
    }

    // Beziehungsmatrix genau nach der Regel aus geometrie.typ
    let mut beziehung = vec![0u8; np * np];
    for p in 0..np {
        for q in 0..np {
            beziehung[p * np + q] = if p == q {
                0
            } else if plaetze[p].tisch != plaetze[q].tisch {
                0
            } else {
                let dr = plaetze[p].zeile - plaetze[q].zeile;
                let dc = plaetze[p].spalte - plaetze[q].spalte;
                if dr * dr + dc * dc <= 2 {
                    2
                } else {
                    1
                }
            };
        }
    }

    let mut schueler = Vec::with_capacity(ns);
    for _ in 0..ns {
        schueler.push(Schueler {
            wuensche: l.liste()?,
            ablehnungen: l.liste()?,
            getrennt: l.liste()?,
            zusammen: l.liste()?,
            pos_tiefe: l.i()?,
            pos_seite: l.i()?,
            meidet_tiefe: l.i()? as u32,
            meidet_seite: l.i()? as u32,
        });
    }

    // Rückwärtskanten in derselben Reihenfolge wie bewertung.typ aufbauen:
    // zuerst alle Wunschnennungen, danach Ablehnungen, getrennt, zusammen.
    let mut rueckwaerts: Vec<Vec<usize>> = vec![Vec::new(); ns];
    for (i, s) in schueler.iter().enumerate() {
        for &w in &s.wuensche {
            rueckwaerts[w].push(i);
        }
    }
    for feld in 0..3 {
        for (i, s) in schueler.iter().enumerate() {
            let liste = match feld {
                0 => &s.ablehnungen,
                1 => &s.getrennt,
                _ => &s.zusammen,
            };
            for &w in liste {
                if !rueckwaerts[w].contains(&i) {
                    rueckwaerts[w].push(i);
                }
            }
        }
    }

    let mut fest = Vec::with_capacity(ns);
    for _ in 0..ns {
        fest.push(l.i()?);
    }

    let mut erlaubt = vec![false; ns * np];
    for i in 0..ns {
        for p in 0..np {
            erlaubt[i * np + p] = l.i()? != 0;
        }
    }

    Ok(Aufgabe {
        plaetze,
        schueler,
        gewichte,
        beziehung,
        rueckwaerts,
        erlaubt,
        fest,
        versuche,
        max_schritte,
        seed,
    })
}

fn rechne(text: &str) -> Result<String, String> {
    let a = lies(text)?;
    let np = a.anzahl_plaetze();
    let beweglich: Vec<usize> = (0..np).filter(|p| !a.fest.contains(&(*p as i64))).collect();

    let mut z = (a.seed.abs() + 1).rem_euclid(M);
    let mut bestes: Option<(Vec<i64>, f64, usize)> = None;
    let mut geprueft_gesamt = 0usize;

    for _ in 0..a.versuche {
        let (start, z1) = startplan(&a, z).ok_or_else(|| {
            "Die Vorgaben lassen sich nicht alle gleichzeitig erfüllen.".to_string()
        })?;
        z = z1;
        let lauf = verbessern(&a, start, &beweglich, z);
        z = lauf.z;
        geprueft_gesamt += lauf.geprueft;
        let punkte = gesamtpunkte(&a, &lauf.zuordnung);
        if bestes.as_ref().map_or(true, |(_, p, _)| punkte > *p) {
            bestes = Some((lauf.zuordnung, punkte, lauf.schritte));
        }
    }

    let (zuordnung, punkte, schritte) = bestes.ok_or("kein Versuch gelaufen")?;
    let mut aus = format!("{punkte} {schritte} {geprueft_gesamt}");
    for s in zuordnung {
        aus.push(' ');
        aus.push_str(&s.to_string());
    }
    Ok(aus)
}

#[no_mangle]
pub extern "C" fn optimiere(len: usize) -> i32 {
    let mut puffer = vec![0u8; len];
    unsafe { wasm_minimal_protocol_write_args_to_buffer(puffer.as_mut_ptr()) };

    let text = match std::str::from_utf8(&puffer) {
        Ok(t) => t,
        Err(_) => {
            sende("Eingabe ist kein gültiges UTF-8");
            return 1;
        }
    };

    match rechne(text) {
        Ok(ausgabe) => {
            sende(&ausgabe);
            0
        }
        Err(fehler) => {
            sende(&fehler);
            1
        }
    }
}
