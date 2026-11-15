#!/usr/bin/env python3
"""umstellen.py – Codemod: hebt Dokumente auf die @schule-Pakete 0.5.0.

Aufruf:
  umstellen.py <datei|ordner>… [--schreiben] [--bericht]

  ohne --schreiben   nur Diff auf stdout, keine Datei wird verändert
  --schreiben        schreibt die Dateien zurück
  --bericht          listet alles, was nicht sicher umstellbar ist, als
                     "datei:zeile: [art] text" auf stdout

Regeln: .github/namen/regeln.json (einzige Quelle; Format siehe dort "_format").
Anleitung: .github/namen/UMSTIEG.md.

Der Quelltext wird so weit zerlegt, dass Strings, Kommentare, Raw-Blöcke und
Fließtext unberührt bleiben und benannte Argumente nur im passenden Aufruf
ersetzt werden (auch `.with(...)`, mehrzeilig, verschachtelt). Was nicht
statisch entscheidbar ist (Spread, dynamische Werte, eigene Wrapper,
Dictionary-Variablen), wird nicht geraten, sondern gemeldet.
Nur Standardbibliothek."""
import difflib
import json
import os
import re
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
REGELN_PFAD = os.path.join(HIER, "..", "namen", "regeln.json")

# ════════════════════════════════════════════════════════════════════════════
# Zerlegung
# ════════════════════════════════════════════════════════════════════════════

ID_RE = re.compile(r"[^\W\d][\w\-]*")
NUM_RE = re.compile(r"(?:\d+\.\d+|\d+\.(?![\w.])|\.\d+|\d+)(?:[eE][+-]?\d+)?(?:%|[a-zA-Z]+)?")
LABEL_RE = re.compile(r"<[\w\-.:]+>")
KEYWORDS = {"let", "set", "show", "import", "include", "if", "else", "for", "while", "in", "return", "context", "as",
            "and", "or", "not", "break", "continue"}
LITERALS = {"none", "true", "false", "auto"}
ZWEI = ("..", "=>", "==", "!=", "<=", ">=", "+=", "-=", "*=", "/=")
FORTSETZUNG = {"=", "=>", ",", ":", "+", "-", "*", "/", "and", "or", "not", "in", "==", "!=", "<=", ">=", "+=", "-=", "<", ">"}


class Tok:
    """k: id | kw | lit | str | num | p (Zeichen) | label | grp;  s: Text bzw. bei grp die öffnende Klammer."""
    __slots__ = ("k", "a", "b", "s", "sub", "_items", "fertig")

    def __init__(self, k, a, b, s, sub=None):
        self.k, self.a, self.b, self.s, self.sub, self._items = k, a, b, s, sub, None
        self.fertig = False

    def __repr__(self):
        return f"<{self.k} {self.s!r} {self.a}:{self.b}>"


class Zerleger:
    def __init__(self, s):
        self.s = s
        self.n = len(s)

    # ---- Hilfen ----
    def _kommentar(self, i):
        s, n = self.s, self.n
        if s.startswith("//", i):
            j = s.find("\n", i)
            return n if j < 0 else j
        if s.startswith("/*", i):
            tiefe, j = 1, i + 2
            while j < n and tiefe:
                if s.startswith("/*", j):
                    tiefe += 1
                    j += 2
                elif s.startswith("*/", j):
                    tiefe -= 1
                    j += 2
                else:
                    j += 1
            return j
        return i

    def _raw(self, i):
        s, n = self.s, self.n
        k = i
        while k < n and s[k] == "`":
            k += 1
        zaehl = k - i
        if zaehl == 2:
            return k
        j = s.find("`" * zaehl, k)
        return n if j < 0 else j + zaehl

    def _string(self, i):
        s, n = self.s, self.n
        j = i + 1
        while j < n and s[j] != '"':
            j += 2 if s[j] == "\\" else 1
        return min(j + 1, n)

    # ---- Markup ----
    def markup(self, i, in_block):
        """Liest Markup ab i. in_block: endet am schließenden `]`. Liefert (tokens, ende)."""
        s, n = self.s, self.n
        out = []
        tiefe = 0
        while i < n:
            c = s[i]
            if c == "\\":
                i += 2
            elif c == "/" and s.startswith("//", i) and not (i and s[i - 1] == ":"):
                i = self._kommentar(i)
            elif c == "/" and s.startswith("/*", i):
                i = self._kommentar(i)
            elif c == "`":
                i = self._raw(i)
            elif c == "$":
                t, i = self.mathe(i)
                out.append(t)
            elif c == "#":
                i = self.eingebettet(i + 1, out)
            elif c == "[":
                tiefe += 1
                i += 1
            elif c == "]":
                if tiefe == 0 and in_block:
                    return out, i
                tiefe = max(0, tiefe - 1)
                i += 1
            else:
                i += 1
        return out, i

    def mathe(self, i):
        s, n = self.s, self.n
        a = i
        i += 1
        sub = []
        while i < n:
            c = s[i]
            if c == "\\":
                i += 2
            elif c == "$":
                i += 1
                break
            elif c == '"':
                i = self._string(i)
            elif c == "#":
                i = self.eingebettet(i + 1, sub)
            elif c == "/" and (s.startswith("//", i) or s.startswith("/*", i)):
                i = self._kommentar(i)
            else:
                i += 1
        return Tok("grp", a, i, "$", sub), i

    # ---- Code ----
    def gruppe(self, i):
        """s[i] ist ( [ oder {. Liefert (Tok, ende)."""
        s = self.s
        c = s[i]
        if c == "[":
            sub, j = self.markup(i + 1, True)
            j = min(j + 1, self.n)
            return Tok("grp", i, j, "[", sub), j
        zu = ")" if c == "(" else "}"
        sub, j = self.code(i + 1, zu)
        j = min(j + 1, self.n)
        return Tok("grp", i, j, c, sub), j

    def code(self, i, zu):
        s, n = self.s, self.n
        out = []
        while i < n:
            c = s[i]
            if c == zu:
                return out, i
            if c in ")]}":  # verirrte Klammer: überspringen
                i += 1
                continue
            i = self.token(i, out)
        return out, i

    def token(self, i, out):
        """Liest ein Code-Token ab i (Leerraum und Kommentare werden übersprungen)."""
        s, n = self.s, self.n
        c = s[i]
        if c.isspace():
            return i + 1
        if c == "/" and (s.startswith("//", i) or s.startswith("/*", i)):
            return self._kommentar(i)
        if c == '"':
            j = self._string(i)
            out.append(Tok("str", i, j, s[i:j]))
            return j
        if c == "`":
            j = self._raw(i)
            out.append(Tok("raw", i, j, s[i:j]))
            return j
        if c == "$":
            t, j = self.mathe(i)
            out.append(t)
            return j
        if c in "([{":
            t, j = self.gruppe(i)
            out.append(t)
            return j
        if c == "<":
            m = LABEL_RE.match(s, i)
            if m:
                out.append(Tok("label", i, m.end(), m.group()))
                return m.end()
        m = ID_RE.match(s, i)
        if m:
            name = m.group()
            while name.endswith("-"):
                name = name[:-1]
            j = i + len(name)
            art = "kw" if name in KEYWORDS else "lit" if name in LITERALS else "id"
            out.append(Tok(art, i, j, name))
            return j
        if c.isdigit() or (c == "." and i + 1 < n and s[i + 1].isdigit() and not (out and out[-1].b == i and out[-1].k in ("id", "grp", "num"))):
            m = NUM_RE.match(s, i)
            if m:
                out.append(Tok("num", i, m.end(), m.group()))
                return m.end()
        for z in ZWEI:
            if s.startswith(z, i):
                out.append(Tok("p", i, i + 2, z))
                return i + 2
        out.append(Tok("p", i, i + 1, c))
        return i + 1

    def _nachsatz(self, i, out):
        """Feldzugriffe, Argumentlisten und Inhaltsblöcke direkt hinter einem Ausdruck."""
        s, n = self.s, self.n
        while i < n:
            c = s[i]
            if c == "." and i + 1 < n and ID_RE.match(s, i + 1):
                out.append(Tok("p", i, i + 1, "."))
                i = self.token(i + 1, out)
            elif c == "(" or c == "[":
                t, i = self.gruppe(i)
                out.append(t)
            else:
                break
        return i

    def eingebettet(self, i, out):
        """Code-Ausdruck hinter `#` im Markup."""
        s, n = self.s, self.n
        if i >= n:
            return i
        c = s[i]
        m = ID_RE.match(s, i)
        if m:
            name = m.group()
            while name.endswith("-"):
                name = name[:-1]
            if name in ("let", "set", "show", "import", "include", "if", "for", "while", "return", "context"):
                return self.anweisung(i, out, name)
            j = i + len(name)
            if name in KEYWORDS:
                out.append(Tok("kw", i, j, name))
                return j
            out.append(Tok("lit" if name in LITERALS else "id", i, j, name))
            return self._nachsatz(j, out)
        if c in "([":
            t, j = self.gruppe(i)
            out.append(t)
            return self._nachsatz(j, out)
        if c == "{":
            t, j = self.gruppe(i)
            out.append(t)
            return j
        if c == '"':
            j = self._string(i)
            out.append(Tok("str", i, j, s[i:j]))
            return j
        return i

    def anweisung(self, i, out, kw):
        """Anweisung im Markup (`#let …`, `#show: …`, `#if … [..] else [..]`): endet am Zeilenende,
        an `;`, an der schließenden Klammer des umgebenden Blocks oder – bei if/for/while/set –
        hinter dem Rumpf."""
        s, n = self.s, self.n
        start = len(out)
        erwartet_bedingung = False
        while i < n:
            c = s[i]
            if c in " \t\r":
                i += 1
                continue
            if c == "\n":
                letzter = out[-1] if len(out) > start else None
                if letzter is not None and letzter.k in ("p", "kw") and letzter.s in FORTSETZUNG:
                    i += 1
                    continue
                if letzter is not None and letzter.k == "grp" and re.match(r"\s*else\b", s[i:i + 200]):
                    i += 1
                    continue
                break
            if c == ";":
                i += 1
                break
            if c in ")]}":
                break
            vorher = len(out)
            vor_ende = out[-1].b if len(out) > start else -1
            i = self.token(i, out)
            if len(out) == vorher:
                continue
            t = out[-1]
            if t.k == "kw" and t.s in ("if", "while", "for"):
                erwartet_bedingung = True
                continue
            if kw in ("if", "while", "for"):
                if t.k == "grp" and not erwartet_bedingung and (t.s == "{" or (t.s == "[" and t.a != vor_ende)):
                    # Rumpf gelesen: weiter nur bei else
                    m = re.match(r"\s*else\b", s[i:i + 200])
                    if not m:
                        break
                    continue
                if not (t.k == "kw"):
                    erwartet_bedingung = False
            elif kw == "set":
                if t.k == "grp" and t.s == "(":
                    if not re.match(r"[ \t]*if\b", s[i:i + 50]):
                        break
        return i


# ════════════════════════════════════════════════════════════════════════════
# Argumentlisten
# ════════════════════════════════════════════════════════════════════════════

class Item:
    """Ein Eintrag einer runden Klammer: benannt (name), Spread oder Positionsargument."""
    __slots__ = ("name", "name_tok", "val", "a", "b", "spread", "komma", "idx")

    def __init__(self):
        self.name = None
        self.name_tok = None
        self.val = []
        self.a = self.b = 0
        self.spread = False
        self.komma = None
        self.idx = 0


def items(grp):
    if grp._items is not None:
        return grp._items
    res = []
    akt = []

    def ab(komma):
        if not akt:
            return
        it = Item()
        it.idx = len(res)
        it.a, it.b = akt[0].a, akt[-1].b
        it.komma = komma
        if len(akt) >= 2 and akt[0].k in ("id", "str", "kw", "lit") and akt[1].k == "p" and akt[1].s == ":":
            it.name_tok = akt[0]
            it.name = akt[0].s[1:-1] if akt[0].k == "str" else akt[0].s
            it.val = akt[2:]
        elif akt[0].k == "p" and akt[0].s == "..":
            it.spread = True
            it.val = akt[1:]
        else:
            it.val = akt[:]
        res.append(it)

    for t in grp.sub:
        if t.k == "p" and t.s == ",":
            ab(t)
            akt = []
        else:
            akt.append(t)
    ab(None)
    grp._items = res
    return res


def statisch(val):
    """Besteht der Wert nur aus Literalen (keine Bezeichner, keine Aufrufe)?"""
    for t in val:
        if t.k in ("id", "kw") or (t.k == "p" and t.s == "=>"):
            return False
        if t.k == "grp" and t.s == "(":
            if any(it.spread or not statisch(it.val) for it in items(t)):
                return False
        elif t.k == "grp" and t.s == "{":
            return False
    return True


def berechnet(val):
    """Ist der Wert ein Ausdruck, der erst zur Laufzeit feststeht (Variable, Aufruf, sys.inputs)?
    Funktionen (`x => …`), Inhaltsblöcke und Klammer-Literale zählen nicht dazu."""
    if not val or any(t.k == "p" and t.s == "=>" for t in val):
        return False
    if len(val) == 1 and val[0].k == "grp":
        return False
    return not statisch(val)


# ════════════════════════════════════════════════════════════════════════════
# Regeln
# ════════════════════════════════════════════════════════════════════════════

class Regeln:
    def __init__(self, pfad=REGELN_PFAD):
        with open(pfad, encoding="utf-8") as f:
            self.d = json.load(f)
        d = self.d
        self.ziel = d["ziel"]
        self.pakete = d["pakete"]
        self.funktionen = d["funktionen"]
        self.parameter = d["parameter"]
        self.werte = d["werte"]
        self.schluessel = d["schluessel"]
        self.entfernt = d["entfernt"]
        self.entfernte_namen = d["entfernte-namen"]
        self.weggefallen = d["weggefallen"]
        self.vorgaben = d.get("vorgaben", {})
        self.positional = d.get("positional", {})
        self.rueckgabe = d.get("rueckgabe", {})
        # je Paket: Funktionsnamen, für die es irgendeine Regel gibt
        self.namen = {p: set() for p in self.pakete}
        for p, m in self.funktionen.items():
            self.namen[p].update(m)
        for p, m in self.entfernte_namen.items():
            self.namen[p].update(m)
        for tabelle in (self.parameter, self.werte, self.schluessel, self.entfernt, self.positional, self.rueckgabe):
            for key in tabelle:
                if ">" in key:
                    continue
                p, rest = key.split(".", 1)
                # Paketnamen enthalten keinen Punkt, Funktionsnamen auch nicht
                self.namen[p].add(rest.split(".")[0])
        for key in KONTEXT:
            p, f = key.split(".", 1)
            self.namen[p].add(f)


def version_tupel(v):
    return tuple(int(x) for x in re.findall(r"\d+", v))


# ════════════════════════════════════════════════════════════════════════════
# Lauf über eine Datei
# ════════════════════════════════════════════════════════════════════════════

IMPORT_RE = re.compile(r'^"@schule/([\w\-]+):(\d+\.\d+\.\d+)"$')
FREMD_RE = re.compile(r'^"@(?:preview|local|schule)/([\w\-]+):')


class Lauf:
    def __init__(self, text, regeln, name="<text>"):
        self.s = text
        self.r = regeln
        self.name = name
        self.edits = []      # (a, b, text)
        self.meldungen = []  # (pos, art, text)
        self.toks, _ = Zerleger(text).markup(0, False)
        self.gebunden = set()
        self.importe = []    # dict(paket, version, tok, alias, stern, namen, ende)
        self.fremd = set()   # Namen fremder Pakete, die das Dokument selbst importiert (z. B. "cetz")
        self.aktiv = []      # Pakete, deren Regeln gelten (Reihenfolge = Vorrang)
        self.direkt = {}     # paket -> alte Version (direkt importiert, unter Zielversion)
        self.module = {}     # Modulname im Dokument -> Paket
        self.in_import = []  # (a, b) Spannen der Importlisten
        self.brauche = {}    # Importpfad -> Namen
        self.gemeldet = set()
        self.unverändert = False
        self.punkte_gesetzt = False  # set-options(punkte: …) kommt im Dokument vor
        self.alias = {}      # Name im Dokument -> Paketname (`import …: energy-sketch as es`)
        self.herkunft = {}   # Variable -> "paket.funktion" (`#let plan = sitzordnung(…)`)
        self.geloescht = {}  # id(grp) -> (grp, {idx})
        self.bezeichner = set()  # alle Bezeichner im Code des Dokuments ("#include" = bindet weitere Dateien ein)
        self.chiffren = {}   # Variable -> (Funktion, Schlüsselargumente) aus `#let c = caesar(key: 3)`

    # ---- Grundwerkzeug ----
    def zeile(self, pos):
        return self.s.count("\n", 0, pos) + 1

    def melde(self, pos, art, text):
        m = (self.zeile(pos), art, text)
        if m not in self.gemeldet:
            self.gemeldet.add(m)
            self.meldungen.append(m)

    def edit(self, a, b, text):
        if a == b and text == "":
            return
        self.edits.append((a, b, text))

    def roh(self, a, b):
        return self.s[a:b]

    def neu(self, a, b):
        """Text von [a, b) mit den darin schon vorgemerkten Änderungen; diese werden dabei verbraucht."""
        self._loeschungen(a, b)
        innen = [e for e in self.edits if a <= e[0] and e[1] <= b]
        self.edits = [e for e in self.edits if not (a <= e[0] and e[1] <= b)]
        return anwenden(self.s[a:b], [(x - a, y - a, t) for x, y, t in innen])

    def literal(self, val):
        if not val or not statisch(val):
            return None
        a, b = val[0].a, val[-1].b
        if len(val) == 1 and val[0].k == "grp" and val[0].s == "[":
            return "[]" if not self.s[a + 1:b - 1].strip() else self.s[a:b]
        return re.sub(r"\s+", " ", self.s[a:b]).strip()

    def rohwert(self, val):
        return re.sub(r"\s+", " ", self.s[val[0].a:val[-1].b]).strip() if val else ""

    def loesche(self, grp, it):
        """Merkt ein Argument zum Löschen vor (samt Komma; steht es allein auf seiner Zeile, verschwindet die Zeile)."""
        self.geloescht.setdefault(id(grp), (grp, set()))[1].add(it.idx)

    def _loeschungen(self, a=None, b=None):
        """Setzt vorgemerkte Löschungen in Änderungen um (alle oder nur die der Klammern innerhalb [a, b))."""
        s = self.s
        for key in list(self.geloescht):
            grp, weg = self.geloescht[key]
            if a is not None and not (a <= grp.a and grp.b <= b):
                continue
            del self.geloescht[key]
            lst = items(grp)
            n = len(lst)

            def zeilenanfang(pos):
                z = s.rfind("\n", 0, pos) + 1
                return z if not s[z:pos].strip() and z > grp.a else None

            def zeilenende(pos, grenze):
                """Position hinter dem Zeilenumbruch nach pos, wenn bis dahin nur Leerraum und ein Kommentar steht."""
                m = re.compile(r"[ \t]*(?://[^\n]*)?\n").match(s, pos)
                return m.end() if m and m.end() <= grenze else None

            i = 0
            while i < n:
                if i not in weg:
                    i += 1
                    continue
                j = i
                while j + 1 < n and (j + 1) in weg:
                    j += 1
                erstes, letztes = lst[i], lst[j]
                if j + 1 < n:
                    naechstes = lst[j + 1]
                    za = zeilenanfang(erstes.a)
                    ze = zeilenende(letztes.komma.b, naechstes.a) if letztes.komma is not None else None
                    if za is not None and ze is not None:
                        self.edit(za, ze, "")
                    else:
                        self.edit(erstes.a, naechstes.a, "")
                else:
                    ende = letztes.komma.b if letztes.komma is not None else letztes.b
                    if i > 0:
                        davor = lst[i - 1]
                        za = zeilenanfang(erstes.a)
                        ze = zeilenende(ende, grp.b) if letztes.komma is not None else None
                        if za is not None and ze is not None:
                            self.edit(za, ze, "")
                        elif letztes.komma is not None:
                            self.edit(davor.komma.b, ende, "")
                        else:
                            self.edit(davor.komma.a if davor.komma is not None else davor.b, ende, "")
                    else:
                        self.edit(erstes.a, ende, "")
                i = j + 1

    def ersetze_wert(self, it, text):
        self.edit(it.val[0].a, it.val[-1].b, text)

    def benenne(self, it, neu):
        t = it.name_tok
        if t is None or it.name == neu:
            return
        self.edit(t.a, t.b, neu)

    # ---- Vorlauf: Importe und gebundene Namen ----
    def vorlauf(self):
        self._sammle(self.toks)
        r = self.r
        zu_tief = []
        for imp in self.importe:
            p, v = imp["paket"], imp["version"]
            if p not in r.pakete or version_tupel(v) >= version_tupel(r.ziel):
                continue
            unter = r.pakete[p]["untergrenze"]
            if unter and version_tupel(v) < version_tupel(unter):
                zu_tief.append(imp)
            self.direkt.setdefault(p, v)
        if zu_tief:
            for imp in zu_tief:
                self.melde(imp["tok"].a, "untergrenze",
                           f"@schule/{imp['paket']}:{imp['version']} liegt unter der Untergrenze "
                           f"{r.pakete[imp['paket']]['untergrenze']} – Dokument bleibt unverändert und läuft mit seinem Pin weiter")
            self.unverändert = True
            return False
        if not self.direkt:
            self.unverändert = True
            return False
        for p in self.direkt:
            if p not in self.aktiv:
                self.aktiv.append(p)
        for p in list(self.direkt):
            for q in r.pakete[p]["reicht-weiter"]:
                if q not in self.aktiv:
                    self.aktiv.append(q)
        self._herkunft(self.toks)
        return True

    def _herkunft(self, toks):
        """`#let v = funktion(…)`: merkt sich, aus welcher Paketfunktion v stammt (für Feldnamen der Rückgabe)."""
        n = len(toks)
        for i, t in enumerate(toks):
            if t.k == "grp":
                self._herkunft(t.sub)
            elif (t.k == "kw" and t.s == "let" and i + 4 < n and toks[i + 1].k == "id" and toks[i + 2].k == "p" and toks[i + 2].s == "="
                  and toks[i + 3].k == "id" and toks[i + 4].k == "grp" and toks[i + 4].s == "(" and toks[i + 4].a == toks[i + 3].b):
                fn = self.alias.get(toks[i + 3].s, toks[i + 3].s)
                if fn in self.gebunden:
                    continue
                p = self.besitzer(fn)
                # nicht, wenn hinter dem Aufruf noch ein Feldzugriff oder weiterer Aufruf folgt
                danach = toks[i + 5] if i + 5 < n else None
                if p and not (danach is not None and danach.a == toks[i + 4].b and (danach.k == "grp" or (danach.k == "p" and danach.s == "."))):
                    var = toks[i + 1].s
                    self.herkunft[var] = None if var in self.herkunft and self.herkunft[var] != f"{p}.{fn}" else f"{p}.{fn}"

    def _sammle(self, toks):
        n = len(toks)
        for i, t in enumerate(toks):
            if t.k == "id":
                self.bezeichner.add(t.s)
            elif t.k == "kw" and t.s == "include":
                self.bezeichner.add("#include")
            if t.k == "grp":
                self._sammle(t.sub)
                if t.s == "(" and i + 1 < n and toks[i + 1].k == "p" and toks[i + 1].s == "=>":
                    self._binde_gruppe(t)
            elif t.k == "id" and i + 1 < n and toks[i + 1].k == "p" and toks[i + 1].s == "=>":
                self.gebunden.add(t.s)
            elif t.k == "kw" and t.s == "let" and i + 1 < n:
                z = toks[i + 1]
                if z.k == "id":
                    self.gebunden.add(z.s)
                    if i + 2 < n and toks[i + 2].k == "grp" and toks[i + 2].s == "(" and toks[i + 2].a == z.b:
                        self._binde_gruppe(toks[i + 2])
                elif z.k == "grp" and z.s == "(":
                    self._binde_gruppe(z)
            elif t.k == "kw" and t.s == "for":
                j = i + 1
                while j < n and not (toks[j].k == "kw" and toks[j].s == "in"):
                    if toks[j].k == "id":
                        self.gebunden.add(toks[j].s)
                    elif toks[j].k == "grp":
                        self._binde_gruppe(toks[j])
                    j += 1
            elif t.k == "kw" and t.s == "import" and i + 1 < n and toks[i + 1].k == "str":
                self._import(toks, i)

    def _binde_gruppe(self, grp):
        for it in items(grp):
            if it.name:
                self.gebunden.add(it.name)
            elif it.val and it.val[0].k == "id" and (len(it.val) == 1 or it.spread):
                self.gebunden.add(it.val[0].s)
            elif len(it.val) == 1 and it.val[0].k == "grp" and it.val[0].s == "(":
                self._binde_gruppe(it.val[0])

    def _import(self, toks, i):
        s = self.s
        st = toks[i + 1]
        m = re.compile(r"\s*(?:as\s+([^\W\d][\w\-]*))?\s*(?::\s*(\*|\([^)]*\)|[^\n;\]\}]*))?").match(s, st.b)
        alias = m.group(1)
        liste = m.group(2)
        ende = m.end()
        namen = []
        stern = False
        if liste is not None:
            if liste.strip() == "*":
                stern = True
            else:
                for teil in re.sub(r"//[^\n]*", "", liste.strip("() \t\n")).split(","):
                    teil = teil.strip()
                    if not teil:
                        continue
                    mm = re.match(r"([^\W\d][\w\-.]*)(?:\s+as\s+([^\W\d][\w\-]*))?$", teil)
                    if mm:
                        namen.append((mm.group(1), mm.group(2)))
        ms = IMPORT_RE.match(st.s)
        mf = FREMD_RE.match(st.s)
        if ms:
            paket = ms.group(1)
            self.importe.append(dict(paket=paket, version=ms.group(2), tok=st, alias=alias, stern=stern, namen=namen,
                                     ende=ende, kw=toks[i]))
            if liste is None:
                self.module[alias or paket] = paket
            for name, als in namen:
                if als:
                    self.alias[als] = name
            if liste is not None and not stern:
                self.in_import.append((st.b, ende))
        else:
            if mf:
                self.fremd.add(mf.group(1))
            if liste is None:
                if alias:
                    self.gebunden.add(alias)
                elif mf:
                    self.gebunden.add(mf.group(1))
            for name, als in namen:
                self.gebunden.add(als or name)

    # ---- Namensauflösung ----
    def besitzer(self, name, fest=None):
        for p in ([fest] if fest else self.aktiv):
            if name in self.r.namen.get(p, ()):
                return p
        return None

    def im_import(self, tok):
        return any(a <= tok.a < b for a, b in self.in_import)

    # ---- Hauptlauf ----
    def lauf(self):
        if not self.vorlauf():
            return
        for imp in self.importe:
            p = imp["paket"]
            if p in self.direkt and version_tupel(imp["version"]) < version_tupel(self.r.ziel):
                t = imp["tok"]
                self.edit(t.a, t.b, f'"@schule/{p}:{self.r.ziel}"')
        self.gehe(self.toks)
        nachlauf(self)
        self._importe_ergaenzen()

    def gehe(self, toks, ist_argliste=False, grp=None):
        if ist_argliste:
            for it in items(grp):
                self.gehe(it.val)
            return
        n = len(toks)
        i = 0
        while i < n:
            t = toks[i]
            if t.k == "kw" and t.s == "let" and i + 1 < n and toks[i + 1].k == "id":
                # Definition: Name überspringen, Parameterliste normal durchlaufen
                i += 2
                continue
            if t.k == "kw" and t.s == "import" and i + 1 < n and toks[i + 1].k == "str":
                if not IMPORT_RE.match(toks[i + 1].s):
                    # Importliste eines fremden Pakets: Namen nicht anfassen
                    m = re.compile(r"[^\n;]*").match(self.s, toks[i + 1].b)
                    ende = m.end()
                    i += 2
                    while i < n and toks[i].a < ende:
                        i += 1
                    continue
            if t.k == "id":
                vor = toks[i - 1] if i else None
                ist_feld = vor is not None and vor.k == "p" and vor.s == "." and vor.b == t.a
                kette = [t]
                j = i + 1
                while (j + 1 < n and toks[j].k == "p" and toks[j].s == "." and toks[j].a == kette[-1].b
                       and toks[j + 1].k == "id" and toks[j + 1].a == toks[j].b):
                    kette.append(toks[j + 1])
                    j += 2
                args = None
                inhalte = []
                if j < n and toks[j].k == "grp" and toks[j].s == "(" and toks[j].a == kette[-1].b:
                    args = toks[j]
                    j += 1
                while j < n and toks[j].k == "grp" and toks[j].s == "[" and toks[j].a == toks[j - 1].b:
                    inhalte.append(toks[j])
                    j += 1
                if args is not None:
                    self.gehe(None, True, args)
                for c in inhalte:
                    self.gehe(c.sub)
                if not ist_feld:
                    self.aufruf(Aufruf(kette, args, inhalte, toks, i, j))
                i = j
                continue
            if t.k == "grp" and not t.fertig:
                if t.s == "(":
                    self.gehe(None, True, t)
                else:
                    self.gehe(t.sub)
            i += 1

    def aufruf(self, c):
        namen = [t.s for t in c.kette]
        r = self.r
        # Sonderketten
        if namen[0] in SONDERKETTEN and namen[0] not in self.gebunden:
            if SONDERKETTEN[namen[0]](self, c):
                return
        if namen[0] in self.chiffren and len(c.kette) == 1 and c.args is not None:
            chiffre_variable(self, c)
            return
        if self.herkunft.get(namen[0]) and len(c.kette) > 1:
            self.felder(self.herkunft[namen[0]], c.kette[1:])
            if len(c.kette) == 2 and namen[1] == "at" and c.args is not None:
                tab = r.rueckgabe.get(self.herkunft[namen[0]], {})
                erstes = items(c.args)[0] if items(c.args) else None
                if erstes is not None and len(erstes.val) == 1 and erstes.val[0].k == "str" and isinstance(tab.get(erstes.val[0].s[1:-1]), str):
                    neu = tab[erstes.val[0].s[1:-1]]
                    if "." in neu:
                        self.melde(erstes.a, "rueckgabe", f"`.at({erstes.val[0].s})` heißt jetzt `.{neu}` – von Hand umstellen")
                    else:
                        self.ersetze_wert(erstes, json.dumps(neu, ensure_ascii=False))
            return
        c.mit_with = len(namen) >= 2 and namen[-1] == "with" and c.args is not None
        ziel = c.kette[-2] if c.mit_with else c.kette[-1]
        vorn = c.kette[:-2] if c.mit_with else c.kette[:-1]
        fest = None
        if vorn:
            if len(vorn) == 1 and vorn[0].s in self.module and vorn[0].s not in self.gebunden:
                fest = self.module[vorn[0].s]
                if fest not in self.aktiv:
                    return
            elif namen[:2] == ["figure", "where"] and c.args is not None and "aufgaben" in self.aktiv:
                for it in items(c.args):
                    if it.name == "kind":
                        lit = self.literal(it.val)
                        if lit in ('"aufgabe"', '"teilaufgabe"'):
                            self.ersetze_wert(it, '"task"' if lit == '"aufgabe"' else '"subtask"')
                        elif lit is None:
                            self.melde(it.a, "dynamisch", "`figure.where(kind: …)` mit berechnetem Wert – die Art heißt jetzt `\"task\"` bzw. `\"subtask\"`")
                return
            else:
                if not self.im_import(c.kette[0]):
                    if namen[0].startswith("_") and len(namen[0]) > 1 and namen[0] not in self.gebunden:
                        self.melde(c.kette[0].a, "intern", f"`{namen[0]}` ist ein interner Name der alten Pakete – 0.5.0 exportiert keine Namen mit Unterstrich; von Hand ersetzen")
                    else:
                        self.pruefe_weggefallen(c.kette[0])
                return
        c.ziel = ziel
        c.alias = ziel.s in self.alias and not vorn
        name = self.alias[ziel.s] if c.alias else ziel.s
        paket = self.besitzer(name, fest)
        if name.startswith("_") and not vorn and name not in self.gebunden and len(name) > 1 and not self.im_import(ziel):
            self.melde(ziel.a, "intern", f"`{name}` ist ein interner Name der alten Pakete – 0.5.0 exportiert keine Namen mit Unterstrich; von Hand ersetzen")
            return
        if name in self.gebunden and not fest and not c.alias:
            if paket:
                self.melde(ziel.a, "eigene-funktion",
                           f"`{name}` ist im Dokument selbst definiert – Aufrufe bleiben unverändert (Regeln von {paket}.{name} nicht angewandt)")
            return
        if paket is None:
            self.pruefe_weggefallen(ziel)
            return
        c.paket = paket
        c.key = f"{paket}.{name}"
        if name in r.entfernte_namen.get(paket, {}):
            self.melde(ziel.a, "entfernt", f"`{name}` gibt es nicht mehr – {r.entfernte_namen[paket][name]}")
            return
        erledigt = set()
        h = KONTEXT.get(c.key)
        if h is not None and (c.args is not None or c.inhalte):
            res = h(self, c)
            if res is False:
                return
            erledigt = res or set()
        if c.args is None and not c.inhalte and not self.im_import(ziel) and (
                c.key in r.positional or c.key in r.parameter or c.key in KONTEXT):
            self.melde(ziel.a, "dynamisch", f"`{name}` wird als Wert weitergereicht (ohne Klammern) – Aufrufe über die Variable stellt der Codemod nicht um; "
                       "deren Argumente von Hand prüfen")
        if c.args is not None:
            self.positionsargumente(c)
            self.argumente(c.key, c.args, items(c.args), erledigt)
        if not c.alias:
            self.funktionsname(c)
        # Feldzugriff direkt hinter dem Aufruf: sitzordnung(…).namen
        if c.key in r.rueckgabe and c.j + 1 < len(c.toks):
            rest = []
            j = c.j
            while (j + 1 < len(c.toks) and c.toks[j].k == "p" and c.toks[j].s == "." and c.toks[j].a == c.toks[j - 1].b
                   and c.toks[j + 1].k == "id"):
                rest.append(c.toks[j + 1])
                j += 2
            if rest:
                self.felder(c.key, rest)

    def felder(self, key, kette):
        """Feldnamen einer Rückgabe umbenennen (regeln.rueckgabe; Unterebenen unter `key>feld`)."""
        r = self.r.rueckgabe
        for t in kette:
            tab = r.get(key)
            if tab is None:
                return
            if t.s in tab:
                z = tab[t.s]
                if isinstance(z, dict):
                    self.melde(t.a, "rueckgabe", f"`.{t.s}`: {z['hinweis']}")
                    if z.get("neu"):
                        self.edit(t.a, t.b, z["neu"])
                elif z is None:
                    self.melde(t.a, "entfernt", f"Feld `.{t.s}` der Rückgabe von `{key.split('.', 1)[1].split('>')[0]}` gibt es nicht mehr")
                elif z != t.s:
                    self.edit(t.a, t.b, z)
            key = f"{key}>{t.s}"

    def positionsargumente(self, c):
        regel = self.r.positional.get(c.key)
        if not regel or c.mit_with:
            return
        pos = c.positional()
        if any(it.spread for it in items(c.args)):
            return
        if len(pos) < regel.get("ab", 1):
            return
        for it, name in zip(pos, regel["namen"]):
            if name and c.benannt(name) is None:
                self.edit(it.a, it.a, name + ": ")

    def funktionsname(self, c):
        ziel = c.ziel
        regel = self.r.funktionen.get(c.paket, {}).get(ziel.s)
        if regel is None:
            return
        if isinstance(regel, str):
            self.edit(ziel.a, ziel.b, regel)
            return
        neu, arg = regel["neu"], regel.get("argumente", "")
        self.edit(ziel.a, ziel.b, neu)
        if self.im_import(ziel):
            return
        if c.args is not None:
            weg = self.geloescht.get(id(c.args), (None, ()))[1]
            hat = any(it.idx not in weg for it in items(c.args))
            self.edit(c.args.a + 1, c.args.a + 1, arg + (", " if hat else ""))
        elif c.inhalte:
            self.edit(ziel.b, ziel.b, f"({arg})")
        elif regel.get("wert"):
            self.edit(ziel.b, ziel.b, f"({arg})")
        else:
            self.edit(ziel.b, ziel.b, f".with({arg})")

    # ---- benannte Argumente ----
    def argumente(self, key, grp, lst, erledigt=()):
        pmap = self.r.parameter.get(key, {})
        for it in lst:
            if it in erledigt or self.schon_ersetzt(grp, it):
                continue
            if it.spread:
                self.melde(it.a, "spread", f"Spread `..{self.rohwert(it.val)}` in `{key.split('.', 1)[1]}(…)` – Schlüssel des Dictionary von Hand umstellen")
                continue
            if it.name is None:
                continue
            self.argument(key, grp, it, pmap)

    def argument(self, key, grp, it, pmap):
        r = self.r
        alt = it.name
        neu = pmap.get(alt, alt)
        wk = r.werte.get(f"{key}.{alt}")
        ek = r.entfernt.get(f"{key}.{alt}")
        sk = r.schluessel.get(f"{key}.{alt}")
        lit = self.literal(it.val)
        roh = self.rohwert(it.val)
        fn = key.split(".", 1)[1]
        if wk is not None:
            treffer = lit if (lit is not None and lit in wk) else roh if roh in wk else None
            if treffer is not None:
                z = wk[treffer]
                if z is None:
                    self.loesche(grp, it)
                    return
                if isinstance(z, dict):
                    self.edit(it.a, it.b, ", ".join(f"{k}: {v}" for k, v in z.items()))
                    return
                self.ersetze_wert(it, z)
                ek = None
            elif berechnet(it.val) and any(v is not None for v in wk.values()) and not self._eigener_aufruf(it.val):
                self._vorgabe_im_ausdruck(f"{key}.{alt}", it.val, wk)
                self.melde(it.a, "dynamisch",
                           f"`{fn}({alt}: {kurz(roh)})`: Wert ist nicht statisch – alte Werte ({', '.join(list(wk)[:6])}{' …' if len(wk) > 6 else ''}) "
                           f"von Hand auf die neuen umstellen" + (f"; der Parameter heißt jetzt `{neu}`" if neu != alt else ""))
        if ek is not None:
            if ek["loeschen"]:
                self.loesche(grp, it)
                self.melde(it.a, "entfernt", f"`{fn}({alt}: …)` gelöscht – {ek['hinweis']}")
            else:
                self.melde(it.a, "entfernt", f"`{fn}({alt}: …)` gibt es nicht mehr – {ek['hinweis']}")
            return
        if sk is not None:
            self.dict_schluessel(f"{key}.{alt}", it, sk, f"{fn}({alt}: …)")
        if neu != alt:
            self.benenne(it, neu)

    def _vorgabe_im_ausdruck(self, key, val, wk):
        """`sys.inputs.at("loesungen", default: "keine")`: das Literal hinter `default:` wird mit umgestellt."""
        vg = self.r.vorgaben.get(key, {})
        for t in val:
            if t.k != "grp" or t.s != "(":
                continue
            for e in items(t):
                if e.name == "default":
                    lit = self.literal(e.val)
                    if lit is None:
                        continue
                    z = wk.get(lit, vg.get(lit))
                    if z is None:
                        z = vg.get(lit)
                    if isinstance(z, str):
                        self.ersetze_wert(e, z)
                else:
                    self._vorgabe_im_ausdruck(key, e.val, wk)

    def _eigener_aufruf(self, val):
        """Wert ist ein Aufruf eines Bausteins der Pakete (kariert(4), liniert(…)) – kein alter Optionswert."""
        return bool(val) and val[0].k == "id" and len(val) >= 2 and val[1].k == "grp" and self.besitzer(val[0].s) is not None

    def dict_schluessel(self, key, it, sk, wo):
        """Schlüssel eines Dictionary-Literals umbenennen (sk: Eintrag aus regeln.schluessel)."""
        if len(it.val) == 1 and it.val[0].k in ("lit", "str", "num"):
            return
        if not (len(it.val) == 1 and it.val[0].k == "grp" and it.val[0].s == "("):
            if not berechnet(it.val):
                return
            self.melde(it.a, "dynamisch", f"`{wo}`: Wert ist kein Dictionary-Literal – Schlüssel "
                       f"({', '.join(list(sk['schluessel'])[:8])}{' …' if len(sk['schluessel']) > 8 else ''}) von Hand umstellen")
            return
        grp = it.val[0]
        if sk.get("eintraege"):
            for e in items(grp):
                ziel = e.val
                if len(ziel) == 1 and ziel[0].k == "grp" and ziel[0].s == "(":
                    self._schluessel(ziel[0], sk, wo)
                elif e.spread or (ziel and not statisch(ziel)):
                    self.melde(e.a, "dynamisch", f"`{wo}`: Eintrag ist kein Dictionary-Literal – Schlüssel von Hand umstellen")
        else:
            self._schluessel(grp, sk, wo)

    def schon_ersetzt(self, grp, it):
        """Ist der Eintrag schon als Ganzes ersetzt oder zum Löschen vorgemerkt?"""
        if it.idx in self.geloescht.get(id(grp), (None, ()))[1]:
            return True
        return any(e[0] == it.a and e[1] == it.b and e[0] != e[1] for e in self.edits)

    def _schluessel(self, grp, sk, wo):
        for e in items(grp):
            if self.schon_ersetzt(grp, e):
                continue
            if e.spread:
                self.melde(e.a, "spread", f"Spread in `{wo}` – Schlüssel von Hand umstellen")
                continue
            if e.name is None:
                continue
            w = sk["werte"].get(e.name)
            if e.name in sk["entfernt"]:
                self.melde(e.a, "entfernt", f"`{wo}`: Schlüssel `{e.name}` gibt es nicht mehr – {sk['entfernt'][e.name]}")
                continue
            if w is not None:
                lit = self.literal(e.val)
                if lit is not None and lit in w:
                    if w[lit] is None:
                        self.loesche(grp, e)
                        continue
                    self.ersetze_wert(e, w[lit])
                elif berechnet(e.val):
                    self.melde(e.a, "dynamisch", f"`{wo}`: Wert von `{e.name}` ist nicht statisch – von Hand prüfen")
            neu = sk["schluessel"].get(e.name)
            if neu and neu != e.name:
                self.benenne(e, neu)

    # ---- weggefallene Weiterreichungen ----
    def pruefe_weggefallen(self, tok):
        name = tok.s
        if name in self.gebunden or self.im_import(tok):
            return
        for p in self.direkt:
            if p == "aufgaben" and ("arbeitsblatt" in self.direkt or "klassenarbeit" in self.direkt):
                continue
            for g in self.r.weggefallen.get(p, ()):
                if name in g.get("namen", ()) or ("praefix" in g and name.startswith(g["praefix"])):
                    imp = g.get("import")
                    if imp:
                        fremdname = re.match(r"@\w+/([\w\-]+):", imp).group(1)
                        if fremdname in self.fremd or any(i["paket"] == fremdname for i in self.importe):
                            return
                        self.brauche.setdefault(imp, [])
                        if g.get("modul"):
                            self.melde(tok.a, "import", f"`{name}` reicht {p} {self.r.ziel} nicht mehr weiter – Importzeile `#import \"{imp}\"` ergänzt")
                            return
                        if name not in self.brauche[imp]:
                            self.brauche[imp].append(name)
                        self.melde(tok.a, "import", f"`{name}` reicht {p} {self.r.ziel} nicht mehr weiter – Importzeile `#import \"{imp}\": {name}` ergänzt"
                                   + (f" ({g['hinweis']})" if g.get("hinweis") else ""))
                    else:
                        self.melde(tok.a, "weggefallen", f"`{name}` reicht {p} {self.r.ziel} nicht mehr weiter – {g.get('hinweis', 'selbst importieren')}")
                    return

    def brauche_name(self, paket, name):
        """Sorgt dafür, dass `name` aus `paket` 0.5.0 importiert ist (wenn das Dokument das Paket nicht selbst mit `*` einbindet)."""
        for imp in self.importe:
            if imp["paket"] == paket and (imp["stern"] or any(n == name for n, _ in imp["namen"])):
                return
        pfad = f"@schule/{paket}:{self.r.ziel}"
        self.brauche.setdefault(pfad, [])
        if name not in self.brauche[pfad]:
            self.brauche[pfad].append(name)

    def _importe_ergaenzen(self):
        if not self.brauche:
            return
        ziel = [i for i in self.importe if i["paket"] in self.direkt]
        if not ziel:
            return
        letzter = max(ziel, key=lambda i: i["ende"])
        pos = self.s.find("\n", letzter["ende"])
        pos = len(self.s) if pos < 0 else pos
        raute = "#" if letzter["kw"].a > 0 and self.s[letzter["kw"].a - 1] == "#" else ""
        zeilenanfang = self.s.rfind("\n", 0, letzter["kw"].a) + 1
        einzug = re.match(r"[ \t]*", self.s[zeilenanfang:]).group()
        text = "".join(f'\n{einzug}{raute}import "{pfad}"' + (f': {", ".join(namen)}' if namen else "") for pfad, namen in self.brauche.items())
        self.edit(pos, pos, text)

    def ergebnis(self):
        self._loeschungen()
        return anwenden(self.s, self.edits, self)


class Aufruf:
    __slots__ = ("kette", "args", "inhalte", "toks", "i", "j", "mit_with", "ziel", "paket", "key", "alias")

    def __init__(self, kette, args, inhalte, toks, i, j):
        self.kette, self.args, self.inhalte, self.toks, self.i, self.j = kette, args, inhalte, toks, i, j
        self.mit_with = False
        self.alias = False
        self.ziel = kette[-1]
        self.paket = self.key = None

    def benannt(self, name):
        if self.args is None:
            return None
        for it in items(self.args):
            if it.name == name:
                return it
        return None

    def positional(self):
        if self.args is None:
            return []
        return [it for it in items(self.args) if it.name is None and not it.spread]


def kurz(text, n=40):
    return text if len(text) <= n else text[:n - 1] + "…"


def anwenden(s, edits, lauf=None):
    """Wendet (a, b, text)-Änderungen von hinten nach vorn an. Überlappende Löschungen werden vereinigt;
    eine Änderung innerhalb einer Löschung entfällt; sonstige Überlappungen werden gemeldet und die
    spätere verworfen."""
    es = sorted(set(edits), key=lambda e: (e[0], e[1]))
    sauber = []
    for e in es:
        if sauber:
            v = sauber[-1]
            ueberlappt = e[0] < v[1] or (e[0] == v[0] and e[1] == v[1] and e[0] != e[1])
            if ueberlappt:
                if v[2] == "" and e[2] == "":
                    sauber[-1] = (v[0], max(v[1], e[1]), "")
                    continue
                if v[2] == "" and e[1] <= v[1]:
                    continue
                if e[2] == "" and v[0] >= e[0] and v[1] <= e[1]:
                    sauber[-1] = e
                    continue
                if lauf is not None:
                    lauf.melde(e[0], "konflikt", f"sich überschneidende Änderungen bei `{kurz(s[v[0]:max(v[1], e[1])])}` – Stelle von Hand prüfen")
                continue
        sauber.append(e)
    for a, b, t in reversed(sauber):
        s = s[:a] + t + s[b:]
    return s


# ════════════════════════════════════════════════════════════════════════════
# Kontextregeln (konvention.md 9.2; Liste und Wortlaut in regeln.json "kontextregeln")
# ════════════════════════════════════════════════════════════════════════════

def zahl(text):
    """Zahl-Literal ohne Einheit → float, sonst None."""
    return float(text) if text is not None and re.fullmatch(r"-?\s*\d+(?:\.\d+)?", text) else None


def laenge(text):
    return text is not None and re.fullmatch(r"-?\s*\d+(?:\.\d+)?(?:pt|mm|cm|in|em)", text) is not None


def fmt(x):
    return ("%.4f" % x).rstrip("0").rstrip(".")


def ist_dict(val):
    return len(val) == 1 and val[0].k == "grp" and val[0].s == "("


def punkte_dictionary(L, grp, lst, key):
    """punkte: (anzeige: A, position: P) → points: A', points-position: P'. Liefert die erledigten Items."""
    erledigt = set()
    pk = next((it for it in lst if it.name == "punkte"), None)
    if pk is None or not ist_dict(pk.val):
        return erledigt
    inner = pk.val[0]
    teile = items(inner)
    if any(e.name not in ("anzeige", "position") for e in teile):
        L.melde(pk.a, "dynamisch", "`punkte: (…)` mit unerwarteten Einträgen – von Hand in `points`, `points-position` umstellen")
        return {pk}
    anzeige = next((e for e in teile if e.name == "anzeige"), None)
    position = next((e for e in teile if e.name == "position"), None)
    W = L.r.werte
    wa = W.get(f"{key}.punkte", {})
    wp = W.get("aufgaben.set-options.punkte-position", {})
    stuecke = []
    if anzeige is not None:
        lit = L.literal(anzeige.val)
        z = wa.get(lit, lit) if lit is not None else None
        if lit is None:
            L.melde(anzeige.a, "dynamisch", "`punkte: (anzeige: …)`: Wert ist nicht statisch – von Hand prüfen")
            stuecke.append("points: " + L.rohwert(anzeige.val))
        elif z is None:
            stuecke.append("points: none")
        elif isinstance(z, dict):
            stuecke += [f"{k}: {v}" for k, v in z.items()]
        else:
            stuecke.append("points: " + z)
    else:
        stuecke.append('points: "tasks"')
    if position is not None:
        lit = L.literal(position.val)
        if lit is None:
            L.melde(position.a, "dynamisch", "`punkte: (position: …)`: Wert ist nicht statisch – von Hand prüfen")
        stuecke.append("points-position: " + (wp.get(lit, lit) if lit is not None else L.rohwert(position.val)))
        neben = next((it for it in lst if it.name == "punkte-position"), None)
        if neben is not None:
            L.loesche(grp, neben)
            erledigt.add(neben)
    L.edit(pk.a, pk.b, ", ".join(stuecke))
    erledigt.add(pk)
    return erledigt


def header_ascent(L, grp, lst):
    ha = next((it for it in lst if it.name == "header-ascent"), None)
    if ha is None:
        return set()
    ps = next((it for it in lst if it.name == "page-settings"), None)
    wert = L.neu(ha.val[0].a, ha.val[-1].b)
    if ps is None:
        L.edit(ha.a, ha.b, f"page-settings: (header-ascent: {wert})")
    elif ist_dict(ps.val):
        d = ps.val[0]
        if items(d) and any(e.name for e in items(d)):
            L.edit(d.a + 1, d.a + 1, f"header-ascent: {wert}, ")
        else:
            L.edit(d.a, d.b, f"(header-ascent: {wert})")
        L.loesche(grp, ha)
    else:
        L.melde(ha.a, "dynamisch", "`header-ascent` gehört jetzt in `page-settings: (header-ascent: …)`; `page-settings` ist kein Literal – von Hand einfügen")
    return {ha}


def varianten(L, grp, lst, key, paket):
    it = next((x for x in lst if x.name == "varianten"), None)
    if it is None:
        return set()
    namen = L.r.d["_varianten"][paket]

    def neu_name(lit):
        return json.dumps(namen.get(lit[1:-1], lit[1:-1]), ensure_ascii=False)

    lit = L.literal(it.val)
    if len(it.val) == 1 and it.val[0].k == "lit":
        L.benenne(it, "variants")
        return {it}
    if len(it.val) == 1 and it.val[0].k == "str":
        L.edit(it.a, it.b, f"variants: ({neu_name(lit)},)")
        return {it}
    if not ist_dict(it.val):
        L.melde(it.a, "dynamisch", "`varianten: …` ist kein Literal – von Hand in `variants: (\"…\",)` und `variant-overrides: (…)` umstellen; der Parameter heißt jetzt `variants`")
        L.benenne(it, "variants")
        return {it}
    d = it.val[0]
    teile = items(d)
    if all(e.name is None and len(e.val) == 1 and e.val[0].k == "str" for e in teile):
        for e in teile:
            L.ersetze_wert(e, neu_name(e.val[0].s))
        L.benenne(it, "variants")
        return {it}
    if not teile or not all(e.name is not None for e in teile):
        if not teile:
            L.melde(it.a, "dynamisch", "`varianten: (:)` – leere Variantenliste von Hand prüfen")
        else:
            L.melde(it.a, "dynamisch", "`varianten: (…)` mischt Formen – von Hand in `variants` und `variant-overrides` umstellen")
        L.benenne(it, "variants")
        return {it}
    # Dictionary Name → Overrides
    kopf_key = "arbeitsblatt.arbeitsblatt-einzeln" if paket == "arbeitsblatt" else key
    liste, overrides = [], []
    for e in teile:
        n = namen.get(e.name, e.name)
        liste.append(json.dumps(n, ensure_ascii=False))
        if ist_dict(e.val):
            inner = e.val[0]
            il = items(inner)
            if il and L.roh(inner.a, inner.b).replace(" ", "") != "(:)":
                erl = punkte_dictionary(L, inner, il, kopf_key)
                for x in il:
                    if x.name == "datei":
                        L.benenne(x, "path")
                        erl.add(x)
                L.argumente(kopf_key, inner, il, erl)
                schluessel = n if ID_RE.fullmatch(n) else json.dumps(n, ensure_ascii=False)
                overrides.append(f"{schluessel}: {L.neu(inner.a, inner.b)}")
        else:
            L.melde(e.a, "dynamisch", f"`varianten: ({e.name}: …)`: Overrides sind kein Dictionary-Literal – von Hand prüfen")
            overrides.append(f"{n}: {L.neu(e.val[0].a, e.val[-1].b)}")
    text = f"variants: ({', '.join(liste)}{',' if len(liste) == 1 else ''})"
    if overrides:
        einzug = re.match(r"[ \t]*", L.s[L.s.rfind(chr(10), 0, it.a) + 1:]).group()
        mehrzeilig = "\n" in L.s[it.a:it.b]
        if mehrzeilig:
            text += f",\n{einzug}variant-overrides: (\n{einzug}  " + f",\n{einzug}  ".join(overrides) + f",\n{einzug})"
        else:
            text += f", variant-overrides: ({', '.join(overrides)})"
    L.edit(it.a, it.b, text)
    return {it}


def theme_wert(L, lst):
    it = next((x for x in lst if x.name == "theme"), None)
    if it is None or not it.val:
        return
    if berechnet(it.val):
        L._vorgabe_im_ausdruck("arbeitsblatt.arbeitsblatt.theme", it.val, {})
        L.melde(it.a, "theme", f"`theme: {kurz(L.rohwert(it.val))}` ist kein Literal – ein Name `\"standard\"` heißt jetzt `auto`; ist es ein eigenes Theme "
                "(Dictionary oder Funktion), Schlüssel (rand → margin, kopf → header, aufgabe → task, schrift entfällt …) und Hook-Parameter von Hand umstellen")
    elif any(t.k == "p" and t.s == "=>" for t in it.val):
        L.melde(it.a, "theme", "`theme:` ist eine Funktion – sie wird jetzt als `(accent: auto, class: none) => (…)` aufgerufen; "
                "Parameter (`akzent` → `accent`) und Schlüssel des gelieferten Dictionary von Hand umstellen")
    elif ist_dict(it.val) and any(e.name for e in items(it.val[0])):
        tk = L.r.d["_theme-schluessel"]
        for e in items(it.val[0]):
            if e.name in tk:
                L.benenne(e, tk[e.name])
            if e.name == "schrift":
                L.melde(e.a, "theme", "Theme-Schlüssel `schrift` gibt es nicht mehr – `font`, `math-font`, `font-size`, `title-font-size` stehen direkt im Theme")
            if e.name == "rand":
                L.melde(e.a, "theme", "Theme-Schlüssel `rand` heißt jetzt `margin` mit `top`, `bottom`, `inside`, `outside`; `kopf-oben` steht als `header-top` direkt im Theme – Unterschlüssel von Hand prüfen")
        L.melde(it.a, "theme", "eigenes Theme-Dictionary: Hooks (`task`, `subtask`, `solution`, `callout` …) haben neue Parameternamen – von Hand prüfen (Handbuch arbeitsblatt, Abschnitt Themes)")


def k_arbeitsblatt(L, c):
    grp, lst, key = c.args, items(c.args) if c.args is not None else [], c.key
    if c.args is None:
        return set()
    erl = set()
    ch = c.benannt("custom-header")
    if ch is not None:
        if L.literal(ch.val) == "none":
            L.loesche(grp, ch)
        else:
            L.benenne(ch, "header")
        erl.add(ch)
    erl |= punkte_dictionary(L, grp, lst, key)
    erl |= header_ascent(L, grp, lst)
    if c.ziel.s == "arbeitsblatt":
        erl |= varianten(L, grp, lst, key, "arbeitsblatt")
    theme_wert(L, lst)
    return erl


def k_klassenarbeit(L, c):
    if c.args is None:
        return set()
    grp, lst, key = c.args, items(c.args), c.key
    version = version_tupel(L.direkt.get("klassenarbeit", "9.9.9"))
    erl = set()
    erl |= punkte_dictionary(L, grp, lst, key)
    erl |= header_ascent(L, grp, lst)
    erl |= varianten(L, grp, lst, key, "klassenarbeit")
    theme_wert(L, lst)
    # Erwartungshorizont
    ew = c.benannt("erwartungen")
    if ew is not None:
        lit = L.literal(ew.val)
        if lit == '"true"':
            L.melde(ew.a, "wert", '`erwartungen: "true"` (Text) wirkte bisher als aus – umgestellt auf `expectations: false`')
        if ist_dict(ew.val) and any(e.name for e in items(ew.val[0])):
            d = ew.val[0]
            teile = items(d)
            nach = {e.name: e for e in teile}
            show = nach.get("show")
            if version < (0, 3, 2):
                L.edit(ew.a, ew.b, "expectations: false")
                L.melde(ew.a, "wert", "`erwartungen: (…)` als Dictionary wirkte vor 0.3.2 als aus – umgestellt auf `expectations: false`")
                erl.add(ew)
            elif show is not None and L.literal(show.val) == "false":
                L.edit(ew.a, ew.b, "expectations: false")
                erl.add(ew)
            else:
                rest = len(teile)
                if show is not None:
                    if L.literal(show.val) == "true":
                        L.loesche(d, show)
                        rest -= 1
                    else:
                        L.melde(show.a, "dynamisch", "`erwartungen: (show: …)` ist nicht statisch – `expectations: false` schaltet den Erwartungshorizont ab")
                np = nach.get("new-page")
                if np is not None:
                    if L.literal(np.val) == "false" and version < (0, 4, 0):
                        L.melde(np.a, "wert", "`erwartungen: (new-page: false)` gelöscht – der Erwartungshorizont beginnt jetzt immer auf einer neuen Seite")
                    L.loesche(d, np)
                    rest -= 1
                alle = nach.get("alle")
                teil = nach.get("teile")
                if teil is not None and not (alle is not None and L.literal(alle.val) == "true"):
                    L.loesche(d, teil)
                    rest -= 1
                if alle is not None and L.literal(alle.val) == "false":
                    rest -= 1
                if rest == 0:
                    L.edit(ew.a, ew.b, "expectations: true")
                    erl.add(ew)
    # bis 0.3.2 entfiel der Erwartungshorizont, wenn die Arbeit kein `erwartung` enthielt; ab 0.4.0 steht dann eine leere Seite
    if version < (0, 4, 0) and ew not in erl and "erwartung" not in L.bezeichner and not any(it.spread for it in lst):
        lit = L.literal(ew.val) if ew is not None else "true"
        if lit != "false" and (ew is None or lit == "true" or ist_dict(ew.val)):
            if "#include" in L.bezeichner or any(i["paket"] not in L.r.pakete for i in L.importe):
                L.melde(grp.a, "vorgabe", "die Arbeit enthält kein `erwartung(…)`: bis 0.3.2 entfiel dann der Erwartungshorizont, jetzt steht eine leere Seite – "
                        "`expectations: false` setzen, falls auch die eingebundenen Dateien keine Erwartungen enthalten")
            else:
                if ew is not None:
                    L.edit(ew.a, ew.b, "expectations: false")
                    erl.add(ew)
                elif lst:
                    letzter = lst[-1]
                    if letzter.komma is not None:
                        einzug = re.match(r"[ \t]*", L.s[L.s.rfind("\n", 0, letzter.a) + 1:]).group() if "\n" in L.s[grp.a:grp.b] else None
                        L.edit(letzter.komma.b, letzter.komma.b, (f"\n{einzug}expectations: false," if einzug is not None else " expectations: false,"))
                    else:
                        L.edit(letzter.b, letzter.b, ", expectations: false")
                else:
                    L.edit(grp.a + 1, grp.a + 1, "expectations: false")
                L.melde(grp.a, "vorgabe", "die Arbeit enthält kein `erwartung(…)`: bis 0.3.2 entfiel dann der Erwartungshorizont, jetzt stünde eine leere Seite – "
                        "`expectations: false` gesetzt; löschen, sobald Erwartungen dazukommen")
    # Klausurbögen
    kb = c.benannt("klausurboegen")
    if kb is not None and ist_dict(kb.val) and any(e.name for e in items(kb.val[0])):
        d = kb.val[0]
        teile = items(d)
        nach = {e.name: e for e in teile}
        show = nach.get("show")
        if show is not None and L.literal(show.val) == "false":
            L.edit(kb.a, kb.b, "answer-sheets: false")
            erl.add(kb)
        else:
            rest = len(teile)
            if show is not None:
                if L.literal(show.val) == "true":
                    L.loesche(d, show)
                    rest -= 1
                else:
                    L.melde(show.a, "dynamisch", "`klausurboegen: (show: …)` ist nicht statisch – `answer-sheets: false` schaltet die Bögen ab, ein Dictionary schaltet sie ein")
            eg = nach.get("ergebnisse")
            if eg is not None:
                if L.literal(eg.val) == "none":
                    L.loesche(d, eg)
                    rest -= 1
                else:
                    L.edit(eg.a, eg.b, f"results: {L.neu(eg.val[0].a, eg.val[-1].b)}, overprint: true")
            sc = nach.get("scale")
            if sc is not None:
                raster(L, d, sc)
            if rest == 0:
                L.edit(kb.a, kb.b, "answer-sheets: true")
                erl.add(kb)
    # info-table: flach → Paare
    for name in ("info-table", "table"):
        tb = c.benannt(name)
        if tb is None or not tb.val:
            continue
        if ist_dict(tb.val):
            teile = items(tb.val[0])
            if teile and all(e.name is None and not e.spread for e in teile):
                schon = all(len(e.val) == 1 and e.val[0].k == "grp" and e.val[0].s == "(" for e in teile)
                if not schon:
                    if len(teile) % 2:
                        L.melde(tb.a, "wert", "`info-table` mit ungerader Zahl von Einträgen – von Hand in Paare `((Beschriftung, Wert), …)` umstellen")
                    else:
                        for e in teile:
                            if e.idx % 2 == 0:
                                L.edit(e.a, e.a, "(")
                            else:
                                L.edit(e.b, e.b, ")")
        elif L.literal(tb.val) not in ("false", "none"):
            L.melde(tb.a, "dynamisch", "`info-table` ist kein Array-Literal – erwartet werden jetzt Paare `((Beschriftung, Wert), …)`")
    bg = c.benannt("bogen")
    if bg is not None and ist_dict(bg.val):
        n = {e.name for e in items(bg.val[0])}
        if "seite4" in n and "rueckseite" in n:
            L.melde(bg.a, "wert", "`bogen: (seite4: …, rueckseite: …)` zugleich – `seite4` überschrieb `rueckseite` still; jetzt ein Fehler, eines von beiden löschen")
    return erl


def raster(L, grp, it):
    """scale: n → grid-size: n * 0.5cm."""
    lit = L.literal(it.val)
    z = zahl(lit)
    if z is not None:
        if z == 1:
            L.loesche(grp, it)
        else:
            L.edit(it.a, it.b, f"grid-size: {fmt(z * 0.5)}cm")
    else:
        L.edit(it.a, it.b, f"grid-size: ({L.neu(it.val[0].a, it.val[-1].b)}) * 0.5cm")


def k_klausurboegen(L, c):
    if c.args is None:
        return set()
    grp, lst = c.args, items(c.args)
    erl = set()
    sc = c.benannt("scale")
    if sc is not None:
        raster(L, grp, sc)
        erl.add(sc)
    nu = c.benannt("numbering")
    if nu is not None:
        lit = L.literal(nu.val)
        if lit not in ('"a)"', '"1."'):
            L.edit(nu.a, nu.b, 'subtask-numbering: "1.1"')
            L.melde(nu.a, "wert", f"`numbering: {L.rohwert(nu.val)}`: jeder andere Wert als \"a)\" wirkte wie \"1.\" – umgestellt auf `subtask-numbering: \"1.1\"`")
            erl.add(nu)
    ex = c.benannt("exam")
    if ex is not None and L.literal(ex.val) != '""':
        fehlend = [(n, v) for n, v in (("teacher", '"SLZ"'), ("class", '"PH1"'), ("date", '"09.10.2023"')) if c.benannt(n) is None]
        if fehlend and not any(it.spread for it in lst):
            text = ", ".join(f"{n}: {v}" for n, v in fehlend)
            if lst:
                letzter = lst[-1]
                if letzter.komma is not None:
                    L.edit(letzter.komma.b, letzter.komma.b, " " + text + ",")
                else:
                    L.edit(letzter.b, letzter.b, ", " + text)
            else:
                L.edit(grp.a + 1, grp.a + 1, text)
            L.melde(grp.a, "vorgabe", "`klausurbögen` hatte die Vorgaben teacher: \"SLZ\", class: \"PH1\", date: \"09.10.2023\"; "
                    "sie sind ausgeschrieben worden, damit der Kopf gleich bleibt – anpassen oder löschen")
    return erl


def k_aufgabe(L, c):
    if c.mit_with:
        return set()
    if c.benannt("title") is not None or c.benannt("titel") is not None:
        return set()
    pos = c.positional()
    if any(it.spread for it in (items(c.args) if c.args is not None else [])):
        return set()
    if len(pos) + len(c.inhalte) != 2:
        return set()
    if pos:
        L.edit(pos[0].a, pos[0].a, "title: ")
    elif c.args is None:
        t = c.inhalte[0]
        L.edit(t.a, t.a, "(title: ")
        L.edit(t.b, t.b, ")")
    else:
        t = c.inhalte[0]
        text = L.neu(t.a, t.b)
        L.edit(t.a, t.b, "")
        lst = items(c.args)
        if not lst:
            L.edit(c.args.b - 1, c.args.b - 1, f"title: {text}")
        elif lst[-1].komma is not None:
            L.edit(lst[-1].komma.b, lst[-1].komma.b, f" title: {text},")
        else:
            L.edit(lst[-1].b, lst[-1].b, f", title: {text}")
    return set()


def k_erwartung(L, c):
    if c.args is None:
        return set()
    lst = items(c.args)
    pk = c.benannt("punkte")
    pos = c.positional()
    if pk is not None:
        if lst[0] is pk:
            L.edit(pk.name_tok.a, pk.val[0].a, "")
        else:
            wert = L.neu(pk.val[0].a, pk.val[-1].b)
            L.loesche(c.args, pk)
            L.edit(lst[0].a, lst[0].a, wert + ", ")
        return {pk}
    if len(pos) == 2 and not c.inhalte:
        l0, l1 = L.literal(pos[0].val), L.literal(pos[1].val)
        if zahl(l1) is not None and zahl(l0) is None:
            t0, t1 = L.neu(pos[0].a, pos[0].b), L.neu(pos[1].a, pos[1].b)
            L.edit(pos[0].a, pos[0].b, t1)
            L.edit(pos[1].a, pos[1].b, t0)
    return set()


def k_set_options(L, c):
    if c.args is None:
        return set()
    lst = items(c.args)
    pos = c.positional()
    if any(it.name in ("punkte", "points") for it in lst) or any(
            ist_dict(p.val) and any(e.name == "punkte" for e in items(p.val[0])) for p in pos) or any(
            berechnet(p.val) for p in pos) or any(it.spread for it in lst):
        L.punkte_gesetzt = True
    if len(pos) == 1 and len(lst) == 1:
        p = pos[0]
        if ist_dict(p.val):
            inner = p.val[0]
            il = items(inner)
            if il and all(e.name is not None or e.spread for e in il):
                L.edit(inner.a, inner.a + 1, "")
                L.edit(inner.b - 1, inner.b, "")
                erl = optionen(L, inner, il, c.key)
                L.argumente(c.key, inner, il, erl)
                return set(lst)
            if L.roh(inner.a, inner.b).replace(" ", "") == "(:)":
                L.edit(inner.a, inner.b, "")
                return set(lst)
        if p.val:
            L.edit(p.a, p.a, "..")
            L.melde(p.a, "dynamisch", f"`set-options({kurz(L.rohwert(p.val))})`: Dictionary ist kein Literal – als `..{kurz(L.rohwert(p.val))}` übergeben; "
                    "seine Schlüssel und Werte (loesungen, punkte …) von Hand umstellen")
        return set(lst)
    return optionen(L, c.args, lst, c.key)


def optionen(L, grp, lst, key):
    erl = punkte_dictionary(L, grp, lst, key)
    ta = next((it for it in lst if it.name == "punkte-template-aufgabe"), None)
    tt = next((it for it in lst if it.name == "punkte-template-teilaufgabe"), None)
    if ta is not None or tt is not None:
        stuecke = []
        if ta is not None:
            stuecke.append("task: " + L.neu(ta.val[0].a, ta.val[-1].b))
        if tt is not None:
            stuecke.append("subtask: " + L.neu(tt.val[0].a, tt.val[-1].b))
        erster = ta if ta is not None else tt
        L.edit(erster.a, erster.b, f"points-format: ({', '.join(stuecke)})")
        if ta is not None and tt is not None:
            L.loesche(grp, tt)
        erl |= {x for x in (ta, tt) if x is not None}
    return erl


def k_show_bewertung(L, c):
    if c.args is None:
        return set()
    pos = c.positional()
    if len(pos) == 1:
        lit = L.literal(pos[0].val)
        if lit == "true":
            L.loesche(c.args, pos[0])
        elif lit == "false":
            L.edit(pos[0].a, pos[0].b, 'possible: "fields"')
        elif lit == "none":
            L.edit(pos[0].a, pos[0].b, "possible: none")
        else:
            L.melde(pos[0].a, "dynamisch", "`show-bewertung(X)`: Positionsargument ist nicht statisch – `possible: \"shown\"`, `\"fields\"` oder `none` von Hand setzen")
    elif len(pos) >= 2:
        for p in pos:
            L.loesche(c.args, p)
    return set(pos)


def k_show_erwartungen(L, c):
    if c.args is None:
        return set()
    erl = set()
    alle, teile, np = c.benannt("alle"), c.benannt("teile"), c.benannt("new-page")
    if teile is not None and not (alle is not None and L.literal(alle.val) == "true"):
        L.loesche(c.args, teile)
        erl.add(teile)
    if np is not None:
        if L.literal(np.val) == "false":
            L.loesche(c.args, np)
        else:
            L.melde(np.a, "entfernt", "`show-erwartungen(new-page: …)` gibt es nicht mehr – `#pagebreak(weak: true)` vor und nach dem Aufruf schreiben")
        erl.add(np)
    return erl


def k_muster(L, c):
    """kariert, liniert: rows wird Positionsargument, width wird Länge bzw. columns."""
    if c.args is None:
        return set()
    grp = c.args
    liniert = c.ziel.s == "liniert"
    erl = set()
    rows = c.benannt("rows")
    pos = c.positional()
    if rows is not None:
        L.edit(rows.name_tok.a, rows.val[0].a, "")  # ein Positionsargument darf hinter benannten stehen
        erl.add(rows)
    if len(pos) >= 2:
        w = pos[1]
        lit = L.literal(w.val)
        if laenge(lit):
            L.edit(w.a, w.a, "width: ")
        elif zahl(lit) is not None:
            if liniert:
                L.loesche(grp, w)
            else:
                L.edit(w.a, w.a, "columns: ")
        else:
            L.melde(w.a, "dynamisch", f"`{c.ziel.s}(r, {kurz(L.rohwert(w.val))})`: zweites Positionsargument ist kein Literal – "
                    + ("als `width: <Länge>` schreiben" if liniert else "als `columns: <Zahl>` oder `width: <Länge>` schreiben"))
    w = c.benannt("width")
    if w is not None:
        lit = L.literal(w.val)
        if lit == "auto" or laenge(lit) or (lit is not None and re.fullmatch(r"\d+(\.\d+)?(%|fr)", lit)):
            pass
        elif zahl(lit) is not None:
            if liniert:
                lh = c.benannt("line-height") or c.benannt("lineheight")
                lhw = L.rohwert(lh.val) if lh is not None else "1cm"
                L.ersetze_wert(w, f"{lit} * {lhw}")
            elif zahl(lit) != int(zahl(lit)):
                # Kommazahl: Breite in Kästchen → Länge
                gs = c.benannt("grid-size")
                gsw = L.literal(gs.val) if gs is not None else "0.5cm"
                m = re.fullmatch(r"(\d+(?:\.\d+)?)(pt|mm|cm|in|em)", gsw or "")
                L.ersetze_wert(w, f"{fmt(zahl(lit) * float(m.group(1)))}{m.group(2)}" if m else f"{lit} * ({L.rohwert(gs.val)})")
            else:
                L.benenne(w, "columns")
        else:
            L.melde(w.a, "dynamisch", f"`{c.ziel.s}(width: {kurz(L.rohwert(w.val))})`: kein Literal – eine Zahl hieß Kästchen bzw. Zeilenhöhen "
                    + ("(jetzt `width: n * line-height`)" if liniert else "(jetzt `columns: n`)") + ", eine Länge bleibt `width`")
        erl.add(w)
    hoehe = c.benannt("height")
    zeilen = rows.val if rows is not None else pos[0].val if pos else None
    if zeilen is not None:
        z = zahl(L.literal(zeilen))
        if z is not None and z != int(z):
            L.melde(zeilen[0].a, "wert", f"`{c.ziel.s}({L.rohwert(zeilen)})`: die Zeilenzahl muss jetzt eine ganze Zahl oder ein Anteil wie `1fr` sein")
        if hoehe is not None and L.literal(hoehe.val) not in ("none", "auto"):
            L.melde(hoehe.a, "wert", f"`{c.ziel.s}` mit Zeilenzahl und `height` zugleich ist jetzt ein Fehler – eines von beiden löschen (bisher gewann `height`)")
    sp = c.benannt("items-spacing")
    if sp is not None:
        z = zahl(L.literal(sp.val))
        if z is not None and z != int(z):
            L.melde(sp.a, "wert", f"`items-spacing: {L.rohwert(sp.val)}` ist nicht ganzzahlig – `item-rows` erwartet eine ganze Zahl")
    return erl


def k_kasten(L, c):
    if c.args is None:
        return set()
    hl = c.benannt("headless")
    if hl is None:
        return set()
    lit = L.literal(hl.val)
    if lit == "true":
        ti = c.benannt("title")
        if ti is not None:
            L.ersetze_wert(ti, "none")
            L.loesche(c.args, hl)
            return {hl, ti}
        L.edit(hl.a, hl.b, "title: none")
        return {hl}
    if lit == "false":
        return set()
    L.melde(hl.a, "dynamisch", "`headless: …` ist nicht statisch – ohne Titelzeile heißt jetzt `title: none`")
    return {hl}


def k_pagebreak(L, c):
    lo = c.benannt("loesungen-only")
    if lo is not None and L.literal(lo.val) != "false":
        L.melde(c.ziel.a, "bedeutung", f"`{c.ziel.s}(loesungen-only: {L.rohwert(lo.val)})` bleibt stehen – `conditional-pagebreak(solutions-visible: true)` "
                "gilt für jede sichtbare Lösung, `loesungen-only` galt nur für die reine Lösungsfassung; von Hand entscheiden")
        return False
    return set()


def k_luecke(L, c):
    if "luecke" in L.gebunden:
        L.melde(c.ziel.a, "eigene-funktion", "`lücke(…)` bleibt stehen – das Dokument definiert `luecke` selbst, der neue Name wäre die dokumenteigene Funktion")
        return False
    if c.args is not None and any(it.name not in (None, "tight") for it in items(c.args)):
        L.melde(c.ziel.a, "eigene-funktion", "`lücke(…)` mit fremden Argumenten bleibt stehen – vermutlich eine dokumenteigene Funktion")
        return False
    L.melde(c.ziel.a, "bedeutung", "`lücke` heißt jetzt `luecke`; mit sichtbaren Lösungen zeigt `luecke` den Inhalt (bisher immer versteckt)")
    return set()


def k_minipage(L, c):
    sp = c.benannt("spacing")
    if sp is not None:
        L.melde(sp.a, "bedeutung", "`minipage(spacing: …)` heißt jetzt `gutter` und gilt auch zwischen Zeilen")
    return set()


def k_teilaufgaben(L, c):
    if c.inhalte and c.benannt("tasks") is None:
        L.melde(c.ziel.a, "form", "`teilaufgaben[+ a + b]` gibt es nicht mehr – als `teilaufgaben(items: ([a], [b]))` schreiben")
    return set()


def k_insert_a_word(L, c):
    ss = c.benannt("show-solution")
    if ss is not None and L.literal(ss.val) != "false":
        L.melde(ss.a, "entfernt", "`insert-a-word(show-solution: …)` gibt es nicht mehr – die Lücken folgen der Lösungsoption des Dokuments (`set-options(solutions: \"in-place\")`)")
        L.loesche(c.args, ss)
        return {ss}
    return set()


DATEN = ("physik.datensatz", "physik.messdaten", "physik.berechnung")


def k_physik_daten(L, c):
    if c.ziel.s == "berechnung" and not c.mit_with:
        pos = c.positional()
        if len(pos) >= 4 and c.benannt("datensaetze") is None and c.benannt("datasets") is None:
            d = pos[2]
            if len(d.val) == 1 and d.val[0].k == "id":
                if L.herkunft.get(d.val[0].s) in DATEN:
                    L.edit(d.val[0].a, d.val[0].b, f"({d.val[0].s},)")
                else:
                    L.melde(d.a, "dynamisch", f"`berechnung(…, {d.val[0].s}, …)`: `datasets` erwartet jetzt ein Array – ist `{d.val[0].s}` ein einzelner Datensatz, `({d.val[0].s},)` schreiben")
    pos = c.positional()
    if not c.mit_with and len(pos) >= 3 and L.literal(pos[1].val) == '""':
        L.ersetze_wert(pos[1], "none")  # leere Einheit
    eh = c.benannt("einheit")
    if eh is not None and L.literal(eh.val) == '""':
        L.ersetze_wert(eh, "none")
    pr, ae = c.benannt("prefix"), c.benannt("auto-einheit")
    if pr is not None and ae is not None and L.literal(pr.val) != '"1"':
        L.loesche(c.args, ae)
        return {ae}
    return set()


def k_caesar(L, c):
    """caesar, vigenere, atbash lieferten bis 0.0.2 eine Funktion: caesar(key: 3)("TEXT"), c("TEXT", true), c()."""
    name = c.ziel.s
    if c.mit_with or c.args is None:
        return set()
    lst = items(c.args)
    pos = c.positional()
    erl = set()
    if name == "vigenere" and len(pos) == 1 and c.benannt("keyword") is None and c.benannt("key") is None:
        L.edit(pos[0].a, pos[0].a, "key: ")
    elif pos:
        return set()  # schon die neue Form (Text als Positionsargument)
    for it in lst:
        if it.name == "keyword":
            L.benenne(it, "key")
            erl.add(it)
        elif it.name == "advanced":
            L.loesche(c.args, it)
            erl.add(it)
    j = c.j
    nach = c.toks[j] if j < len(c.toks) else None
    schluessel = L.neu(c.args.a + 1, c.args.b - 1).strip().rstrip(",").strip()
    if nach is not None and nach.k == "grp" and nach.s == "(" and nach.a == c.toks[j - 1].b:
        L.gehe(None, True, nach)  # innere Aufrufe zuerst, ihr Text wird gleich verschoben
        nach.fertig = True
        zweite = items(nach)
        if not zweite:
            if name == "caesar":
                L.edit(c.ziel.a, nach.b, f"caesar-table({schluessel})")
                L.brauche_name("informatik", "caesar-table")
            else:
                L.melde(c.ziel.a, "form", f"`{name}(…)()` gibt es nicht mehr – eine Tabelle setzt nur `caesar-table(key: …)`")
        else:
            text = chiffre_argumente(L, nach)
            L.edit(c.args.a, nach.b, "(" + text + (", " + schluessel if schluessel else "") + ")")
    elif nach is not None and nach.k == "p" and nach.s == "." and nach.a == c.toks[j - 1].b:
        L.melde(c.ziel.a, "form", f"`{name}(…).{c.toks[j + 1].s if j + 1 < len(c.toks) else ''}`: die Funktion liefert jetzt den Text direkt – "
                f"`{name}(text, key: …)` bzw. `inverse: true` schreiben; die Tabelle setzt `caesar-table(key: …)`")
    else:
        if schluessel:
            L.edit(c.args.a, c.args.b, f".with({schluessel})")
        else:
            L.edit(c.args.a, c.args.b, "")
        i = c.i
        if i >= 3 and c.toks[i - 1].k == "p" and c.toks[i - 1].s == "=" and c.toks[i - 2].k == "id" and c.toks[i - 3].k == "kw" and c.toks[i - 3].s == "let":
            L.chiffren[c.toks[i - 2].s] = (name, schluessel)
        else:
            L.melde(c.ziel.a, "form", f"`{name}({kurz(schluessel)})` lieferte eine Funktion; umgestellt auf `{name}.with(…)` – Aufrufe mit zweitem Argument `true` "
                    "heißen jetzt `inverse: true`, der Aufruf ohne Argument (Tabelle) `caesar-table(key: …)`")
    return set(lst)


def chiffre_argumente(L, grp):
    """Argumente eines Chiffre-Aufrufs: zweites Positionsargument true → inverse: true, false → entfällt."""
    pos = [it for it in items(grp) if it.name is None and not it.spread]
    if len(pos) == 2:
        lit = L.literal(pos[1].val)
        if lit == "true":
            L.edit(pos[1].a, pos[1].b, "inverse: true")
        elif lit == "false":
            L.loesche(grp, pos[1])
        else:
            L.edit(pos[1].a, pos[1].a, "inverse: ")
    return L.neu(grp.a + 1, grp.b - 1).strip().rstrip(",").strip()


def chiffre_variable(L, c):
    """Aufruf einer Variablen, die aus caesar(…), vigenere(…) oder atbash() stammt."""
    name, schluessel = L.chiffren[c.kette[0].s]
    if not items(c.args):
        if name == "caesar":
            L.edit(c.kette[0].a, c.args.b, f"caesar-table({schluessel})")
            L.brauche_name("informatik", "caesar-table")
        else:
            L.melde(c.kette[0].a, "form", f"`{c.kette[0].s}()` (Tabelle) gibt es für `{name}` nicht mehr")
        return
    pos = [it for it in items(c.args) if it.name is None and not it.spread]
    if len(pos) == 2:
        lit = L.literal(pos[1].val)
        if lit == "true":
            L.edit(pos[1].a, pos[1].b, "inverse: true")
        elif lit == "false":
            L.loesche(c.args, pos[1])
        else:
            L.edit(pos[1].a, pos[1].a, "inverse: ")


def k_rot13(L, c):
    if c.args is None or c.mit_with:
        return set()
    lst = items(c.args)
    pos = c.positional()
    if not lst:
        L.edit(c.ziel.a, c.args.b, "caesar-table(key: 13)")
        L.brauche_name("informatik", "caesar-table")
        return False
    if len(pos) == 2:
        L.loesche(c.args, pos[1])
    return set()


def k_kreisdiagramm(L, c):
    ra = c.benannt("radius")
    if ra is None:
        return set()
    lit = L.literal(ra.val)
    z = zahl(lit)
    if z is not None:
        L.edit(ra.a, ra.b, f"width: {fmt(2 * z)}cm")
    elif laenge(lit):
        L.edit(ra.a, ra.b, f"width: 2 * {lit}")
    else:
        L.edit(ra.a, ra.b, f"width: 2 * ({L.neu(ra.val[0].a, ra.val[-1].b)}) * 1cm")
        L.melde(ra.a, "dynamisch", "`kreisdiagramm(radius: …)` heißt jetzt `width` (Durchmesser als Länge) – umgestellt als `2 * (…) * 1cm`; ist der Wert schon eine Länge, `* 1cm` streichen")
    return {ra}


def k_messwerttabelle(L, c):
    pos = c.positional()
    if len(pos) == 1 and ist_dict(pos[0].val):
        d = pos[0].val[0]
        teile = items(d)
        if teile and all(e.name is None and not e.spread for e in teile):
            L.edit(d.a, d.a + 1, "")
            L.edit(d.b - 1, d.b, "")
            if teile[-1].komma is not None:
                L.edit(teile[-1].komma.a, teile[-1].komma.b, "")
    elif len(pos) == 2 and zahl(L.literal(pos[1].val)) is not None and c.benannt("amount") is None:
        L.edit(pos[1].a, pos[1].a, "count: ")
        if len(pos[0].val) == 1 and pos[0].val[0].k == "id":
            L.edit(pos[0].a, pos[0].a, "..")
    return set()


def k_ascii(L, c):
    v = c.benannt("variants")
    if v is not None and ist_dict(v.val):
        for e in items(v.val[0]):
            if L.literal(e.val) == '"char"':
                L.ersetze_wert(e, '"character"')
    return set()


def k_gutachten_aufgabe(L, c):
    pos = c.positional()
    if len(pos) == 2 and c.benannt("punkte") is None and c.benannt("points") is None:
        L.edit(pos[1].a, pos[1].a, "points: ")
    return set()


def k_set_aufgaben(L, c):
    pos = c.positional()
    sk = L.r.d["_gutachten-aufgaben"]
    for p in pos:
        if ist_dict(p.val):
            for e in items(p.val[0]):
                if ist_dict(e.val):
                    for f in items(e.val[0]):
                        if f.name in sk:
                            L.benenne(f, sk[f.name])
                        elif f.name is not None and f.name not in sk.values():
                            L.melde(f.a, "entfernt", f"`set-aufgaben`: Schlüssel `{f.name}` kennt `set-tasks` nicht (erlaubt: title, max-points, dative) – löschen")
                elif e.name in sk:
                    L.benenne(e, sk[e.name])
        elif p.val:
            L.melde(p.a, "dynamisch", "`set-aufgaben(…)`: Liste ist kein Literal – Schlüssel `name` → `title`, `be` → `max-points`, `dativ` → `dative` von Hand umstellen")
    return set()


def k_card(L, c):
    if c.benannt("header") is not None or c.benannt("footer") is not None:
        return set()
    pos = c.positional()
    if len(pos) + len(c.inhalte) != 4:
        return set()
    if len(pos) >= 2:
        L.edit(pos[0].a, pos[0].a, "header: ")
        L.edit(pos[1].a, pos[1].a, "footer: ")
    elif len(pos) == 0 and c.args is None:
        h, f = c.inhalte[0], c.inhalte[1]
        L.edit(h.a, h.a, "(header: ")
        L.edit(h.b, f.a, ", footer: ")
        L.edit(f.b, f.b, ")")
    else:
        L.melde(c.ziel.a, "form", "`card(…)` mit gemischten Positionsargumenten – als `card(header: H, footer: F)[Frage][Antwort]` schreiben")
    return set()


def k_hathi(L, c):
    sc = c.benannt("scale")
    if sc is None:
        return set()
    z = zahl(L.literal(sc.val))
    if z is not None:
        if z == 1:
            L.loesche(c.args, sc)
        else:
            L.edit(sc.a, sc.b, f"tile-size: {fmt(z * 25)}mm")
    else:
        L.edit(sc.a, sc.b, f"tile-size: ({L.neu(sc.val[0].a, sc.val[-1].b)}) * 25mm")
    return {sc}


SUMMIFY_PFADE = {("spacing", "content"): "cell", ("sizes", "title", "text"): "font-size", ("sizes", "header", "text"): "font-size",
                 ("typography", "base-size"): "font-size"}


def summify_schluessel(L, grp, pfad=()):
    for e in items(grp):
        if e.spread:
            L.melde(e.a, "spread", "Spread in einem summify-Theme – Schlüssel `spacing.content` → `spacing.cell`, `sizes.*.text` → `font-size`, `typography.base-size` → `font-size` von Hand prüfen")
        if e.name is None:
            continue
        hier = pfad + (e.name,)
        if hier in SUMMIFY_PFADE:
            L.benenne(e, SUMMIFY_PFADE[hier])
        elif ist_dict(e.val):
            summify_schluessel(L, e.val[0], hier)


def k_summify_reihe(L, c):
    """beside/below/cols/rows(lines: …) → cell-grid(direction: …, dividers: …)."""
    li = c.benannt("lines")
    if li is None or c.mit_with:
        return set()
    richtung = "horizontal" if c.ziel.s in ("beside", "cols") else "vertical"
    L.edit(c.ziel.a, c.ziel.b, "cell-grid")
    L.edit(c.args.a + 1, c.args.a + 1, f'direction: "{richtung}", ')
    L.benenne(li, "dividers")
    for it in items(c.args):
        if it.name == "gap":
            L.benenne(it, "gutter")
    return False


def k_summify_theme(L, c):
    if c.args is None:
        return set()
    if c.ziel.s == "summify":
        for n in ("theme", "theme-overrides"):
            it = c.benannt(n)
            if it is not None and ist_dict(it.val):
                summify_schluessel(L, it.val[0])
            elif it is not None and berechnet(it.val):
                L.melde(it.a, "dynamisch", f"`{n}: …` ist kein Literal – Schlüssel `spacing.content` → `spacing.cell`, `sizes.title.text`/`sizes.header.text` → `font-size`, "
                        "`typography.base-size` → `font-size` von Hand prüfen")
    elif c.ziel.s == "update-theme":
        summify_schluessel(L, c.args)
    else:
        for it in c.positional():
            if ist_dict(it.val):
                summify_schluessel(L, it.val[0])
    return set()


def k_typlace(L, c):
    ro = c.benannt("rotation")
    if ro is not None:
        lit = L.literal(ro.val)
        if zahl(lit) is not None:
            L.ersetze_wert(ro, fmt(zahl(lit)) + "deg")
            return {ro}
    return set()


ZONEN = {'"vorne"': '"front"', '"mitte"': '"middle"', '"hinten"': '"back"', '"links"': '"left"', '"rechts"': '"right"'}
SCHUELER = {"wuensche": "wishes", "ablehnungen": "rejections", "position-meidet": "position-avoided"}


def k_sitzordnung(L, c):
    pos = c.positional()
    if len(pos) < 2:
        return set()
    sch = pos[1]

    def eintrag(d):
        for e in items(d):
            if e.name in ("position", "position-meidet") and ist_dict(e.val):
                for x in items(e.val[0]):
                    if x.name in ("tiefe", "seite"):
                        L.benenne(x, "depth" if x.name == "tiefe" else "side")
                        if ist_dict(x.val):
                            for y in items(x.val[0]):
                                lit = L.literal(y.val)
                                if lit in ZONEN:
                                    L.ersetze_wert(y, ZONEN[lit])
                        else:
                            lit = L.literal(x.val)
                            if lit in ZONEN:
                                L.ersetze_wert(x, ZONEN[lit])
            if e.name in SCHUELER:
                L.benenne(e, SCHUELER[e.name])

    def liste(grp):
        for e in items(grp):
            if ist_dict(e.val) and any(x.name for x in items(e.val[0])):
                eintrag(e.val[0])

    if ist_dict(sch.val):
        d = sch.val[0]
        if any(e.name for e in items(d)):
            for e in items(d):
                if e.name == "schueler":
                    L.benenne(e, "students")
                    if ist_dict(e.val):
                        liste(e.val[0])
                elif e.name == "hinweise":
                    L.benenne(e, "notes")
        else:
            liste(d)
    return set()


# ---- graphen (mathematik) ----

def k_graphen(L, c):
    if c.args is None:
        return set()
    grp, lst = c.args, items(c.args)
    G = L.r.d["_graphen"]
    erl = set()
    nach = {it.name: it for it in lst if it.name}

    def wert(it):
        return L.neu(it.val[0].a, it.val[-1].b)

    def farbe(e):
        z = zahl(L.literal(e.val))
        if z is not None and z == int(z) and z >= 1:
            L.ersetze_wert(e, G["palette"][(int(z) - 1) % 10])

    def eintrag(d, karte, art):
        for e in items(d):
            if e.spread:
                L.melde(e.a, "spread", "Spread in einem `graphen`-Dictionary – Schlüssel von Hand umstellen")
                continue
            if e.name is None:
                continue
            if e.name in ("color", "clr"):
                farbe(e)
            if art == "term" and e.name == "label":
                if ist_dict(e.val) and any(x.name for x in items(e.val[0])):
                    for x in items(e.val[0]):
                        if x.name == "position":
                            lit = L.literal(x.val)
                            if lit in G["label-position"]:
                                L.ersetze_wert(x, G["label-position"][lit])
                            elif lit is not None and lit.startswith('"'):
                                L.melde(x.a, "wert", f"`label: (position: {lit})` wirkte bisher als Mischform – Lage der Beschriftung von Hand prüfen")
                        elif x.name == "size" and L.literal(x.val) == "none":
                            L.loesche(e.val[0], x)
                        elif x.name in ("color",):
                            farbe(x)
                            L.benenne(x, G["label"][x.name])
                        elif x.name in G["label"]:
                            L.benenne(x, G["label"][x.name])
                    L.edit(e.val[0].a, e.val[0].a, "(")
                    L.edit(e.val[0].b, e.val[0].b, ",)")
                elif L.literal(e.val) == "none":
                    L.loesche(d, e)
                    continue
                elif e.val:
                    L.melde(e.a, "dynamisch", "`label: …` eines Graphen ist kein Dictionary-Literal – jetzt `labels: ((x: …, body: …),)`; Schlüssel content → body, size → font-size, color → text-fill, padding → distance, angle → rotation")
            if art == "marks":
                if e.name == "position":
                    if ist_dict(e.val):
                        L.benenne(e, "at")
                        continue
                    L.melde(e.a, "dynamisch", "`marks: (position: …)`: war das die Koordinate, heißt der Schlüssel jetzt `at`; die Lage der Beschriftung bleibt `position`")
                    continue
                if e.name == "anchor":
                    lit = L.literal(e.val)
                    if lit in G["marks-anchor"]:
                        L.ersetze_wert(e, G["marks-anchor"][lit])
                    L.benenne(e, "position")
                    continue
            if art == "fills":
                if e.name == "auto-domain":
                    lit = L.literal(e.val)
                    if lit == "true":
                        L.edit(e.a, e.b, 'domain: "intersections"')
                    elif lit == "false":
                        L.loesche(d, e)
                    else:
                        L.melde(e.a, "dynamisch", "`auto-domain: …` ist nicht statisch – jetzt `domain: \"intersections\"`")
                    continue
                if e.name == "domain" and L.literal(e.val) == '"auto"':
                    L.ersetze_wert(e, '"intersections"')
            if art == "datensaetze":
                if e.name in ("marker", "mark-style") and ist_dict(e.val) and any(x.name for x in items(e.val[0])):
                    innen = e.val[0]
                    andere = next((o for o in items(d) if o.name in ("marker", "mark-style") and o is not e and ist_dict(o.val)), None)
                    if e.name == "mark-style" and andere is not None:
                        doppelt = {x.name for x in items(innen)} & {x.name for x in items(andere.val[0])}
                        for x in items(innen):
                            if x.name in doppelt:
                                L.loesche(innen, x)  # das marker-Dictionary gewinnt
                    text = L.neu(innen.a + 1, innen.b - 1).strip().rstrip(",").strip()
                    if text:
                        L.edit(e.a, e.b, text)
                    else:
                        L.loesche(d, e)
                    continue
                if e.name == "mark-style":
                    L.melde(e.a, "form", "`mark-style: …` – `fill` und `stroke` stehen jetzt direkt im Datensatz; von Hand auflösen")
                    continue
            if e.name in karte:
                L.benenne(e, karte[e.name])

    # Terme als Positionsargumente
    for it in lst:
        if it.name is None and not it.spread and ist_dict(it.val) and any(x.name for x in items(it.val[0])):
            eintrag(it.val[0], G["term"], "term")
        elif it.spread:
            pass
        elif it.name is None and it.val and it.val[0].k == "id":
            L.melde(it.a, "dynamisch", f"`graphen({kurz(L.rohwert(it.val))}, …)`: Term steht nicht als Literal im Aufruf – ist es ein Dictionary, die Schlüssel (color → accent, label → labels …) von Hand umstellen")

    # Listen aus Dictionaries
    for name, karte, art in (("fills", G["fills"], "fills"), ("marks", G["marks"], "marks"),
                             ("datensätze", G["datensaetze"], "datensaetze"), ("datensaetze", G["datensaetze"], "datensaetze")):
        it = nach.get(name)
        if it is None:
            continue
        if not ist_dict(it.val):
            if art == "fills" and it.val and ((len(it.val) == 1 and it.val[0].k == "grp" and it.val[0].s == "$") or any(t.k == "p" and t.s == "=>" for t in it.val)):
                L.ersetze_wert(it, f'((term: {L.neu(it.val[0].a, it.val[-1].b)}, domain: "intersections"),)')
            elif art == "fills" and L.literal(it.val) == "none":
                L.loesche(grp, it)
                erl.add(it)
            else:
                L.melde(it.a, "dynamisch", f"`graphen({name}: …)` ist kein Literal – Form und Schlüssel der Einträge von Hand prüfen"
                        + ("; die Kurzform `fills: f` heißt jetzt `areas: ((term: f, domain: \"intersections\"),)`" if art == "fills" else ""))
            continue
        d = it.val[0]
        teile = items(d)
        if any(e.name for e in teile):
            # ein einzelnes Dictionary → Liste mit einem Eintrag
            eintrag(d, karte, art)
            L.edit(d.a, d.a, "(")
            L.edit(d.b, d.b, ",)")
            continue
        if art == "marks":
            lits = [L.literal(e.val) for e in teile]
            if len(teile) == 2 and all(zahl(x) is not None for x in lits):
                L.edit(d.a, d.b, f"((at: {L.roh(d.a, d.b)}),)")
                continue
        def daten(e):
            if ist_dict(e.val):
                return not any(x.name for x in items(e.val[0])) and all(zahl(L.literal(x.val)) is not None for x in items(e.val[0]))
            return len(e.val) == 1 and e.val[0].k == "id" and L.herkunft.get(e.val[0].s) in DATEN
        if art == "datensaetze" and len(teile) == 2 and all(daten(e) for e in teile):
            L.edit(d.a, d.b, f"((x: {L.neu(teile[0].a, teile[0].b)}, y: {L.neu(teile[1].a, teile[1].b)}),)")
            continue
        if art == "fills" and teile and not any(ist_dict(e.val) for e in teile):
            def term(val):
                return bool(val) and ((len(val) == 1 and val[0].k == "grp" and val[0].s == "$") or any(t.k == "p" and t.s == "=>" for t in val))
            if len(teile) == 2 and all(term(e.val) for e in teile):
                L.edit(d.a, d.b, f'((between: {L.neu(d.a, d.b)}, domain: "intersections"),)')
            else:
                L.melde(it.a, "form", "`fills: (f, g)` – die Kurzform gibt es nicht mehr: `areas: ((between: (f, g), domain: \"intersections\"),)` bzw. je Fläche ein Dictionary schreiben")
            continue
        for e in teile:
            if e.spread:
                L.melde(e.a, "spread", f"Spread in `graphen({name}: …)` – Einträge von Hand prüfen")
            elif ist_dict(e.val):
                ed = e.val[0]
                et = items(ed)
                if any(x.name for x in et):
                    eintrag(ed, karte, art)
                elif art == "marks":
                    # (x, y) oder ((x, y), body)
                    if len(et) == 2 and ist_dict(et[0].val):
                        L.edit(et[0].a, et[0].a, "at: ")
                        L.edit(et[1].a, et[1].a, "body: ")
                    elif len(et) == 2:
                        L.edit(ed.a, ed.b, f"(at: {L.neu(ed.a, ed.b)})")
            elif e.val and not statisch(e.val):
                if not (art == "fills"):
                    L.melde(e.a, "dynamisch", f"`graphen({name}: …)`: Eintrag ist kein Literal – von Hand prüfen")

    # x, y → domain
    x, y = nach.get("x"), nach.get("y")
    hat_daten = nach.get("datensätze") is not None or nach.get("datensaetze") is not None
    bleibt = []
    for achse, it in (("x", x), ("y", y)):
        if it is None:
            continue
        erl.add(it)
        lit = L.literal(it.val)
        if lit == "auto" or (hat_daten and lit == "(-5, 5)"):
            L.loesche(grp, it)
            continue
        if lit is None:
            L.melde(it.a, "dynamisch", f"`graphen({achse}: {kurz(L.rohwert(it.val))})`: kein Literal – `auto` hieße jetzt „Argument weglassen“; "
                    "der Wert `(-5, 5)` galt zusammen mit `datensätze` als nicht gesetzt")
        bleibt.append((achse, it))
    if bleibt:
        L.edit(bleibt[0][1].a, bleibt[0][1].b, "domain: (" + ", ".join(f"{a}: {wert(i)}" for a, i in bleibt) + ")")
        for _, i in bleibt[1:]:
            L.loesche(grp, i)

    # x-label, y-label → labels
    xl, yl = nach.get("x-label"), nach.get("y-label")
    if xl is not None or yl is not None:
        vorhanden = [it for it in (xl, yl) if it is not None]
        a = wert(xl) if xl is not None else "auto"
        b = wert(yl) if yl is not None else "auto"
        L.edit(vorhanden[0].a, vorhanden[0].b, f"labels: ({a}, {b})")
        if len(vorhanden) == 2:
            L.loesche(grp, vorhanden[1])
        erl |= set(vorhanden)

    # grid, x-grid, y-grid → grid-lines
    g, xg, yg = nach.get("grid"), nach.get("x-grid"), nach.get("y-grid")

    def gw(it):
        lit = L.literal(it.val)
        if lit is None:
            L.melde(it.a, "dynamisch", f"`graphen({it.name}: …)`: kein Literal – die Werte heißen jetzt `\"all\"`, `\"major\"`, `\"minor\"`, `none`")
            return wert(it)
        return G["grid"].get(lit, lit)

    achsen = [(a, it) for a, it in (("x", xg), ("y", yg)) if it is not None and L.literal(it.val) != "none"]
    for it in (xg, yg):
        if it is not None:
            erl.add(it)
            if L.literal(it.val) == "none":
                L.loesche(grp, it)
    if g is not None:
        erl.add(g)
    if achsen:
        gg = gw(g) if g is not None else '"all"'
        teile = {"x": gg, "y": gg}
        for a, it in achsen:
            teile[a] = gw(it)
        erster = g if g is not None else achsen[0][1]
        L.edit(erster.a, erster.b, f"grid-lines: (x: {teile['x']}, y: {teile['y']})")
        for _, it in achsen:
            if it is not erster:
                L.loesche(grp, it)
    elif g is not None:
        L.edit(g.a, g.b, f"grid-lines: {gw(g)}")

    # step, x-step, y-step → step
    st, xs_, ys_ = nach.get("step"), nach.get("x-step"), nach.get("y-step")
    achsen = [(a, it) for a, it in (("x", xs_), ("y", ys_)) if it is not None and L.literal(it.val) != "none"]
    for it in (xs_, ys_):
        if it is not None:
            erl.add(it)
            if L.literal(it.val) == "none":
                L.loesche(grp, it)
    if achsen:
        # `step: 1` war die Vorgabe und galt als „nicht gesetzt“: die Achse ohne eigenen Schritt bleibt dann weg
        sw = wert(st) if st is not None and L.literal(st.val) != "1" else None
        teile = {"x": sw, "y": sw}
        for a, it in achsen:
            teile[a] = wert(it)
        erster = st if st is not None else achsen[0][1]
        L.edit(erster.a, erster.b, "step: (" + ", ".join(f"{a}: {v}" for a, v in teile.items() if v is not None) + ")")
        for _, it in achsen:
            if it is not erster:
                L.loesche(grp, it)
        if st is not None:
            erl.add(st)

    # size, scale → width, height
    sz, sc = nach.get("size"), nach.get("scale")
    if sz is not None or sc is not None:
        f = 1.0
        ok = True
        if sc is not None:
            z = zahl(L.literal(sc.val))
            if z is None:
                ok = False
            else:
                f = z
        if sz is not None and ok:
            lit = L.literal(sz.val)
            if lit == "none":
                L.loesche(grp, sz)
                if sc is not None:
                    ok = False
            elif zahl(lit) is not None:
                L.edit(sz.a, sz.b, f"width: {fmt(zahl(lit) * f)}cm, height: {fmt(zahl(lit) * f)}cm")
                if sc is not None:
                    L.loesche(grp, sc)
            elif ist_dict(sz.val) and len(items(sz.val[0])) == 2 and all(zahl(L.literal(e.val)) is not None for e in items(sz.val[0])):
                b, h = (zahl(L.literal(e.val)) for e in items(sz.val[0]))
                L.edit(sz.a, sz.b, f"width: {fmt(b * f)}cm, height: {fmt(h * f)}cm")
                if sc is not None:
                    L.loesche(grp, sc)
            else:
                ok = False
        elif sz is None:
            ok = False
        if not ok:
            for it in (sz, sc):
                if it is not None:
                    L.melde(it.a, "form", f"`graphen({it.name}: {kurz(L.rohwert(it.val))})` gibt es nicht mehr – die Größe setzen `width` und `height` als Längen; von Hand umrechnen (Einheit war 1 cm mal `scale`)")
        erl |= {it for it in (sz, sc) if it is not None}
    return erl


KONTEXT = {
    "arbeitsblatt.arbeitsblatt": k_arbeitsblatt,
    "arbeitsblatt.arbeitsblatt-einzeln": k_arbeitsblatt,
    "klassenarbeit.klassenarbeit": k_klassenarbeit,
    "klausurboegen.klausurbögen": k_klausurboegen,
    "aufgaben.aufgabe": k_aufgabe,
    "aufgaben.erwartung": k_erwartung,
    "aufgaben.set-options": k_set_options,
    "aufgaben.show-bewertung": k_show_bewertung,
    "aufgaben.show-erwartungen": k_show_erwartungen,
    "patterns.kariert": k_muster,
    "patterns.liniert": k_muster,
    "arbeitsblatt.print-pagebreak": k_pagebreak,
    "arbeitsblatt.non-print-pagebreak": k_pagebreak,
    "arbeitsblatt.lücke": k_luecke,
    "arbeitsblatt.minipage": k_minipage,
    "arbeitsblatt.teilaufgaben": k_teilaufgaben,
    "arbeitsblatt.tasks": k_teilaufgaben,
    "insert-a-word.insert-a-word": k_insert_a_word,
    "physik.datensatz": k_physik_daten,
    "physik.berechnung": k_physik_daten,
    "informatik.caesar": k_caesar,
    "informatik.rot13": k_rot13,
    "mathematik.kreisdiagramm": k_kreisdiagramm,
    "physik.messwerttabelle": k_messwerttabelle,
    "physik.messdaten": k_physik_daten,
    "typlace.typlace": k_typlace,
    "typlace.sitzordnung": k_sitzordnung,
    "informatik.vigenere": k_caesar,
    "informatik.atbash": k_caesar,
    "informatik.ascii-table": k_ascii,
    "mathematik.graphen": k_graphen,
    "gutachten.aufgabe": k_gutachten_aufgabe,
    "gutachten.set-aufgaben": k_set_aufgaben,
    "flashcards.card": k_card,
    "abbozza.render-hathi-level": k_hathi,
    "summify.summify": k_summify_theme,
    "summify.beside": k_summify_reihe,
    "summify.below": k_summify_reihe,
    "summify.cols": k_summify_reihe,
    "summify.rows": k_summify_reihe,
    "summify.update-theme": k_summify_theme,
    "summify.set-theme": k_summify_theme,
}
for _k in ("abstract", "info", "question", "memo", "conclusion", "tip", "success", "warning", "error", "example", "goal",
           "idea", "experiment", "notify", "danger"):
    KONTEXT["arbeitsblatt." + _k] = k_kasten


# ---- Sonderketten: print-state.get(), pk.<k>.<feld>, state("print") ----

def s_print_state(L, c):
    if "arbeitsblatt" not in L.aktiv:
        return False
    namen = [t.s for t in c.kette]
    if namen == ["print-state", "get"] and c.args is not None and not items(c.args):
        L.edit(c.kette[0].a, c.args.b, "is-print()")
    else:
        L.melde(c.kette[0].a, "entfernt", "`print-state` gibt es nicht mehr – Abfrage mit `is-print()`; diese Form von Hand umstellen")
    return True


PK_FELDER = {"wert": "value", "einheit": "unit", "mit-einheit": "qty"}
PK_NAMEN = {("m", "elektron"): "m_e", ("m", "proton"): "m_p", ("m", "neutron"): "m_n", ("m", "u"): "u", ("v", "schall"): "v_sound"}


def s_pk(L, c):
    if "physik" not in L.aktiv:
        return False
    k = c.kette
    L.edit(k[0].a, k[0].b, "constants")
    if len(k) >= 3 and (k[1].s, k[2].s) in PK_NAMEN:
        L.edit(k[1].a, k[2].b, PK_NAMEN[(k[1].s, k[2].s)])
        rest = k[3:]
    else:
        rest = k[2:]
    if len(k) == 1:
        L.melde(k[0].a, "form", "`pk` heißt jetzt `constants`; Feldzugriffe auf gespeicherte Konstanten (`.wert`, `.einheit`, `.mit-einheit`) heißen `.value`, `.unit`, `.qty` – von Hand prüfen")
    for t in rest:
        if t.s in PK_FELDER:
            L.edit(t.a, t.b, PK_FELDER[t.s])
    return True


def s_state(L, c):
    if c.args is None or "aufgaben" not in L.aktiv:
        return False
    lst = items(c.args)
    if lst and lst[0].name is None and L.literal(lst[0].val) in ('"print"', '"options"', '"ab-scope"', '"ab-theme"', '"aufgaben"'):
        L.melde(c.kette[0].a, "zustand", f"`state({L.literal(lst[0].val)}, …)` greift auf einen internen Zustand der Pakete zu; die Schlüssel heißen jetzt anders – "
                "`is-print()`, `has-solutions()` benutzen")
    return False


SONDERKETTEN = {"print-state": s_print_state, "pk": s_pk, "state": s_state}


def nachlauf(L):
    """Regeln, die das ganze Dokument betreffen."""
    if "aufgaben" in L.direkt and "arbeitsblatt" not in L.direkt and "klassenarbeit" not in L.direkt:
        alt = [i for i in L.importe if i["paket"] == "aufgaben" and version_tupel(i["version"]) < version_tupel(L.r.ziel)
               and (i["stern"] or i["namen"])]
        imp = alt[0] if alt else None
        if imp is not None and not L.punkte_gesetzt and imp["kw"].a > 0 and L.s[imp["kw"].a - 1] == "#":
            pos = L.s.find("\n", imp["ende"])
            pos = len(L.s) if pos < 0 else pos
            L.edit(pos, pos, '\n#set-options(points: "tasks")')
            L.melde(imp["tok"].a, "vorgabe", "aufgaben ohne arbeitsblatt: die Vorgabe der Punkteanzeige war \"aufgaben\" und ist jetzt `none` – "
                    "`#set-options(points: \"tasks\")` ergänzt, damit die BE wie bisher an den Aufgaben stehen; löschen, wenn sie nicht erscheinen sollen")


# ════════════════════════════════════════════════════════════════════════════
# Kommandozeile
# ════════════════════════════════════════════════════════════════════════════

def stelle_um(text, regeln, name="<text>"):
    """Liefert (neuer Text, Meldungen [(zeile, art, text)])."""
    L = Lauf(text, regeln, name)
    L.lauf()
    if L.unverändert:
        return text, L.meldungen
    neu = L.ergebnis()
    return neu, sorted(L.meldungen)


def dateien(pfade):
    for p in pfade:
        if os.path.isdir(p):
            for wurzel, ordner, namen in os.walk(p):
                ordner[:] = sorted(d for d in ordner if not d.startswith("."))
                for n in sorted(namen):
                    if n.endswith(".typ"):
                        yield os.path.join(wurzel, n)
        else:
            yield p


def main(argv):
    schalter = [a for a in argv if a.startswith("--")]
    pfade = [a for a in argv if not a.startswith("--")]
    unbekannt = [a for a in schalter if a not in ("--schreiben", "--bericht", "--help")]
    if "--help" in schalter or not pfade or unbekannt:
        print(__doc__)
        return 0 if "--help" in schalter else 2
    regeln = Regeln()
    schreiben, bericht = "--schreiben" in schalter, "--bericht" in schalter
    geaendert = gemeldet = fehler = 0
    for pfad in dateien(pfade):
        try:
            with open(pfad, encoding="utf-8") as f:
                alt = f.read()
        except (OSError, UnicodeDecodeError) as e:
            print(f"{pfad}: nicht lesbar ({e})", file=sys.stderr)
            fehler += 1
            continue
        try:
            neu, meldungen = stelle_um(alt, regeln, pfad)
        except Exception as e:  # ein Dokument darf den Lauf nicht abbrechen
            print(f"{pfad}: interner Fehler ({type(e).__name__}: {e}) – Datei bleibt unverändert", file=sys.stderr)
            fehler += 1
            continue
        if neu != alt:
            geaendert += 1
            if schreiben:
                with open(pfad, "w", encoding="utf-8") as f:
                    f.write(neu)
            else:
                sys.stdout.writelines(difflib.unified_diff(alt.splitlines(True), neu.splitlines(True), pfad, pfad + " (0.5.0)", n=1))
                if not neu.endswith("\n"):
                    sys.stdout.write("\n")
        gemeldet += len(meldungen)
        if bericht:
            for zeile, art, text in meldungen:
                print(f"{pfad}:{zeile}: [{art}] {text}")
    print(f"{geaendert} Datei(en) {'geschrieben' if schreiben else 'mit Änderungen'}, {gemeldet} Meldung(en)"
          + ("" if bericht or not gemeldet else " (mit --bericht anzeigen)") + (f", {fehler} Fehler" if fehler else ""), file=sys.stderr)
    return 1 if fehler else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
