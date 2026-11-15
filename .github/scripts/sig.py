#!/usr/bin/env python3
"""Signaturliste und Namens-Lint für die @schule-Pakete (ohne Typst-Parser).

Aufrufe (aus beliebigem Verzeichnis):

  sig.py <paket> [version]          öffentliche Oberfläche als JSON
  sig.py --lint <paket> [version]   Lint nach plan-0.4/konvention.md, Abschnitt 10;
                                    je Verstoß eine Zeile
                                    "paket/version/datei:zeile: Regel: Text", Exit 1
  sig.py --eval <paket> [version]   vergleicht die statisch ermittelten Exporte mit
                                    der Laufzeit (typst eval), Exit 1 bei Abweichung

Ohne Version gilt der höchste Versionsordner des Pakets.

Das Skript liest die Einstiegsdatei aus typst.toml und folgt allen Importen.
Öffentlich ist, was die Einstiegsdatei auf oberster Ebene bindet: `#let` in
Spalte 0, namentliche Importe, `as`-Namen, Modulnamen und Wildcard-Importe
lokaler Dateien. Namen mit führendem Unterstrich gelten als privat.

Wortlisten: .github/namen/{words-en,names,bausteine-de,fremdnamen,zwillinge}.txt.
Zu jeder Liste darf es eine Datei <liste>-zusatz.txt geben (ein Wort je Zeile);
Paket-Agenten ergänzen fehlende englische Wörter in words-en-zusatz.txt.
"""
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent.parent
NAMEN = REPO / ".github" / "namen"
IDENT = r"[^\W\d][\w\-]*"
NAME_RE = re.compile(r"^[a-z][a-z0-9]*(-[a-z0-9]+)*$")
SINKS = {"deprecated", "cells", "items", "args"}
AXES = {"x", "y"}  # Achsenbezeichner, konvention.md 2.4
PREFIXES = ("no", "non", "not", "hide", "without", "disable", "custom", "my")
SUFFIXES = ("only", "alt", "old", "neu", "new", "2", "color", "state", "dict", "list", "array", "flag", "str")
BAD_DEFAULTS = {'""', '"none"', '"false"', '"keine"'}
FREMDNAMEN_PAKETE = {"arbeitsblatt", "klassenarbeit"}  # UMSETZUNG-0.5.0.md, Vorgabe 2


# --- Wortlisten -------------------------------------------------------------

def wortliste(name):
    """Liest <name>.txt und <name>-zusatz.txt: ein Eintrag je Zeile, # = Kommentar."""
    out = []
    for datei in (NAMEN / f"{name}.txt", NAMEN / f"{name}-zusatz.txt"):
        if datei.exists():
            for zeile in datei.read_text(encoding="utf-8").splitlines():
                zeile = zeile.split("#")[0].strip()
                if zeile:
                    out.append(zeile)
    return out


# --- Quelltext lesen --------------------------------------------------------

def strip_comments(s):
    """Entfernt Kommentare, behält Zeilenumbrüche (Zeilennummern bleiben)."""
    out = []
    i = 0
    n = len(s)
    in_str = False
    while i < n:
        c = s[i]
        # Ein `"` im Fließtext darf die Zeichenketten-Erkennung nicht auf Dauer
        # kippen: an jedem `#let`/`#import` in Spalte 0 beginnt sie neu.
        if c == "#" and (i == 0 or s[i - 1] == "\n") and (s.startswith("#let ", i) or s.startswith("#import ", i)):
            in_str = False
        if in_str:
            out.append(c)
            if c == "\\" and i + 1 < n:
                out.append(s[i + 1])
                i += 2
                continue
            if c == '"':
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True
            out.append(c)
            i += 1
            continue
        if s.startswith("//", i) and not (i > 0 and s[i - 1] == ":"):  # nicht in URLs
            j = s.find("\n", i)
            i = n if j < 0 else j
            continue
        if s.startswith("/*", i):
            d = 1
            i += 2
            while i < n and d:
                if s.startswith("/*", i):
                    d += 1
                    i += 2
                elif s.startswith("*/", i):
                    d -= 1
                    i += 2
                else:
                    if s[i] == "\n":
                        out.append("\n")
                    i += 1
            continue
        out.append(c)
        i += 1
    return "".join(out)


def match_paren(s, i):
    """s[i] ist eine öffnende Klammer; liefert den Index der schließenden."""
    d = 0
    in_str = False
    n = len(s)
    while i < n:
        c = s[i]
        if in_str:
            if c == "\\":
                i += 2
                continue
            if c == '"':
                in_str = False
        elif c == '"':
            in_str = True
        elif c in "([{":
            d += 1
        elif c in ")]}":
            d -= 1
            if d == 0:
                return i
        i += 1
    return -1


def split_top(s):
    """Teilt an Kommas der obersten Klammerebene."""
    parts = []
    d = 0
    in_str = False
    cur = []
    i = 0
    while i < len(s):
        c = s[i]
        if in_str:
            cur.append(c)
            if c == "\\" and i + 1 < len(s):
                cur.append(s[i + 1])
                i += 1
            elif c == '"':
                in_str = False
        elif c == '"':
            in_str = True
            cur.append(c)
        elif c in "([{":
            d += 1
            cur.append(c)
        elif c in ")]}":
            d -= 1
            cur.append(c)
        elif c == "," and d == 0:
            parts.append("".join(cur))
            cur = []
        else:
            cur.append(c)
        i += 1
    parts.append("".join(cur))
    return [p.strip() for p in parts if p.strip()]


def parse_params(text):
    params = []
    for p in split_top(text):
        if p.startswith(".."):
            params.append({"name": p, "kind": "sink"})
            continue
        m = re.match(r"(" + IDENT + r")\s*:\s*(.*)$", p, re.S)
        if m:
            params.append({"name": m.group(1), "kind": "named", "default": " ".join(m.group(2).split())})
        else:
            params.append({"name": " ".join(p.split()), "kind": "positional"})
    return params


def docstring(raw_lines, line):
    """Die `///`-Zeilen direkt über Zeile `line` (1-basiert)."""
    doc = []
    i = line - 2
    while i >= 0 and raw_lines[i].lstrip().startswith("///"):
        doc.append(raw_lines[i].strip())
        i -= 1
    return list(reversed(doc))


class Datei:
    """Eine Quelldatei: Definitionen und Importe der obersten Ebene."""

    def __init__(self, path):
        self.path = path
        raw = path.read_text(encoding="utf-8")
        self.raw_lines = raw.splitlines()
        self.code = strip_comments(raw)
        self.lets = []     # dict(name, kind, line, params, doc)
        self.imports = []  # dict(source, line, alias, items | "*" | None)
        self.all_sources = []  # jede Importquelle, auch in Funktionsrümpfen
        self._parse()

    def _line(self, pos):
        return self.code.count("\n", 0, pos) + 1

    def _parse(self):
        s = self.code
        for m in re.finditer(r"(?<![\w\-])import\s+\"([^\"]+)\"", s):
            self.all_sources.append(m.group(1))
        for m in re.finditer(r"^#let\s+", s, re.M):
            self._parse_let(m.end(), self._line(m.start()))
        for m in re.finditer(r"^#import\s+\"([^\"]+)\"", s, re.M):
            self._parse_import(m.group(1), m.end(), self._line(m.start()))

    def _parse_let(self, pos, line):
        s = self.code
        doc = docstring(self.raw_lines, line)
        stub = self.path.name == "removed.typ"
        if s[pos] == "(":  # Destrukturierung
            e = match_paren(s, pos)
            for p in split_top(s[pos + 1:e]):
                name = p.split(":")[-1].strip().lstrip(".")
                if re.fullmatch(IDENT, name):
                    self.lets.append({"name": name, "kind": "variable", "line": line, "params": [], "doc": doc})
            return
        m = re.compile(IDENT).match(s, pos)
        if not m:
            return
        name = m.group(0)
        rest = m.end()
        entry = {"name": name, "kind": "variable", "line": line, "params": [], "doc": doc}
        if rest < len(s) and s[rest] == "(":
            e = match_paren(s, rest)
            entry["kind"] = "function"
            entry["params"] = parse_params(s[rest + 1:e])
        else:
            mm = re.compile(r"\s*=\s*").match(s, rest)
            if mm:
                rhs = mm.end()
                if s.startswith("(", rhs):
                    e = match_paren(s, rhs)
                    if e > 0 and re.match(r"\s*=>", s[e + 1:e + 20]):
                        entry["kind"] = "function"
                        entry["params"] = parse_params(s[rhs + 1:e])
                elif re.compile(r"(\.\.)?" + IDENT + r"\s*=>").match(s, rhs):
                    arg = re.compile(r"(\.\.)?" + IDENT).match(s, rhs).group(0)
                    entry["kind"] = "function"
                    entry["params"] = parse_params(arg)
                elif re.compile(r"(check\.)?stub\s*\(").match(s, rhs):
                    stub = True
        if stub:
            entry["kind"] = "stub"
        self.lets.append(entry)

    def _parse_import(self, source, pos, line):
        s = self.code
        entry = {"source": source, "line": line, "alias": None, "items": None}
        m = re.compile(r"[ \t]+as[ \t]+(" + IDENT + ")").match(s, pos)
        if m:
            entry["alias"] = m.group(1)
            pos = m.end()
        m = re.compile(r"[ \t]*:[ \t]*").match(s, pos)
        if m:
            pos = m.end()
            if s.startswith("*", pos):
                entry["items"] = "*"
            else:
                if s.startswith("(", pos):
                    e = match_paren(s, pos)
                    text = s[pos + 1:e]
                else:
                    e = s.find("\n", pos)
                    text = s[pos:(len(s) if e < 0 else e)]
                items = []
                for p in split_top(text):
                    mm = re.fullmatch(r"(" + IDENT + r"(?:\." + IDENT + r")*)(?:\s+as\s+(" + IDENT + "))?", p)
                    if mm:
                        path = mm.group(1)
                        items.append((path, mm.group(2) or path.split(".")[-1]))
                entry["items"] = items
        self.imports.append(entry)


# --- Pakete und Exporte ------------------------------------------------------

def version_key(v):
    return [int(x) if x.isdigit() else 0 for x in re.split(r"[.\-]", v)]


def neueste_version(paket):
    ordner = [d.name for d in (REPO / paket).iterdir() if d.is_dir() and re.fullmatch(r"\d+\.\d+\.\d+", d.name)]
    if not ordner:
        sys.exit(f"sig.py: kein Versionsordner in {paket}/")
    return sorted(ordner, key=version_key)[-1]


def toml_package(pkgdir):
    """Liest die Schlüssel des Abschnitts [package] aus typst.toml."""
    datei = pkgdir / "typst.toml"
    if not datei.exists():
        sys.exit(f"sig.py: {datei} fehlt")
    try:
        import tomllib
        return tomllib.loads(datei.read_text(encoding="utf-8")).get("package", {})
    except ImportError:
        werte = {}
        abschnitt = None
        for zeile in datei.read_text(encoding="utf-8").splitlines():
            m = re.match(r"\s*\[(.+)\]", zeile)
            if m:
                abschnitt = m.group(1)
            m = re.match(r'\s*([\w\-]+)\s*=\s*"(.*)"', zeile)
            if m and abschnitt == "package":
                werte[m.group(1)] = m.group(2)
        return werte


class Analyse:
    def __init__(self, paket, version):
        self.paket = paket
        self.version = version
        self.pkgdir = REPO / paket / version
        if not self.pkgdir.is_dir():
            sys.exit(f"sig.py: {paket}/{version}/ gibt es nicht")
        self.toml = toml_package(self.pkgdir)
        self.entry = (self.pkgdir / self.toml.get("entrypoint", "lib.typ")).resolve()
        if not self.entry.exists():
            sys.exit(f"sig.py: Einstiegsdatei {self.entry} fehlt")
        self.dateien = {}
        self.cache = {}
        self.wildcards = []       # fremde Wildcards, die in den Exporten landen
        self.lokale_wildcards = []  # lokale Wildcards in exportierten Dateien
        self.exports = self.exporte(self.entry, direkt=True)

    def datei(self, path):
        path = path.resolve()
        if path not in self.dateien:
            self.dateien[path] = Datei(path)
        return self.dateien[path]

    def rel(self, path):
        try:
            return str(Path(path).resolve().relative_to(REPO))
        except ValueError:
            return str(path)

    def aufloesen(self, source, von):
        """Liefert ("datei", Path) | ("schule", name, version, Path|None) | ("fremd", spec)."""
        if source.startswith("@"):
            m = re.fullmatch(r"@([\w\-]+)/([\w\-]+):([\w.\-]+)", source)
            if m and m.group(1) == "schule":
                pdir = REPO / m.group(2) / m.group(3)
                if (pdir / "typst.toml").exists():
                    einstieg = pdir / toml_package(pdir).get("entrypoint", "lib.typ")
                    return ("schule", m.group(2), m.group(3), einstieg if einstieg.exists() else None)
                return ("schule", m.group(2), m.group(3), None)
            return ("fremd", source)
        wurzel = self.paketwurzel(von)
        ziel = (wurzel / source.lstrip("/")) if source.startswith("/") else (von.parent / source)
        return ("datei", ziel.resolve())

    def paketwurzel(self, path):
        p = Path(path).resolve().parent
        while p != p.parent:
            if (p / "typst.toml").exists():
                return p
            p = p.parent
        return self.pkgdir

    def eigen(self, path):
        try:
            Path(path).resolve().relative_to(self.pkgdir.resolve())
            return True
        except ValueError:
            return False

    def exporte(self, path, direkt=False, stapel=()):
        """Name -> Eintrag für alles, was die Datei auf oberster Ebene bindet.
        `direkt`: Die Bindungen dieser Datei landen in den Exporten des Pakets."""
        path = path.resolve()
        if path in self.cache:
            return self.cache[path]
        if path in stapel or not path.exists():
            return {}
        d = self.datei(path)
        out = {}
        herkunft = None if self.eigen(path) else self.rel(self.paketwurzel(path))
        for imp in d.imports:
            ziel = self.aufloesen(imp["source"], path)
            modulname = imp["alias"]
            if modulname is None and imp["items"] is None:
                if ziel[0] == "datei":
                    modulname = ziel[1].stem
                elif ziel[0] == "schule":
                    modulname = ziel[1]
                else:
                    modulname = re.sub(r"^@[\w\-]+/([\w\-]+):.*$", r"\1", imp["source"])
            if modulname:
                out[modulname] = {"name": modulname, "kind": "module", "file": self.rel(path), "line": imp["line"],
                                  "params": [], "doc": [], "from": imp["source"] if ziel[0] != "datei" else herkunft,
                                  "foreign": ziel[0] == "fremd"}
            if imp["items"] is None:
                continue
            if ziel[0] == "fremd":
                if imp["items"] == "*":
                    if direkt:
                        self.wildcards.append({"from": imp["source"], "file": self.rel(path), "line": imp["line"]})
                else:
                    for quelle, name in imp["items"]:
                        out[name] = {"name": name, "kind": "foreign", "file": self.rel(path), "line": imp["line"],
                                     "params": [], "doc": [], "from": imp["source"], "foreign": True}
                continue
            quelle_pfad = ziel[1] if ziel[0] == "datei" else ziel[3]
            if quelle_pfad is None or not quelle_pfad.exists():
                if imp["items"] != "*":
                    for quelle, name in imp["items"]:
                        out[name] = {"name": name, "kind": "unknown", "file": self.rel(path), "line": imp["line"],
                                     "params": [], "doc": [], "from": imp["source"], "foreign": False}
                elif direkt:
                    self.wildcards.append({"from": imp["source"] + " (nicht im Repo)", "file": self.rel(path), "line": imp["line"]})
                continue
            ist_wild = imp["items"] == "*"
            if ist_wild and direkt:
                if ziel[0] == "datei":
                    self.lokale_wildcards.append({"from": imp["source"], "file": self.rel(path), "line": imp["line"]})
                else:
                    self.wildcards.append({"from": imp["source"], "file": self.rel(path), "line": imp["line"], "resolved": True})
            quelle_exporte = self.exporte(quelle_pfad, direkt=direkt and ist_wild, stapel=stapel + (path,))
            if ist_wild:
                for name, e in quelle_exporte.items():
                    out[name] = dict(e, **({"from": imp["source"]} if ziel[0] == "schule" else {}))
            else:
                for quelle, name in imp["items"]:
                    e = quelle_exporte.get(quelle.split(".")[0])
                    if e is None or "." in quelle:
                        out[name] = {"name": name, "kind": "unknown", "file": self.rel(path), "line": imp["line"],
                                     "params": [], "doc": [], "from": imp["source"], "foreign": False}
                    else:
                        out[name] = dict(e, name=name, **({"from": imp["source"]} if ziel[0] == "schule" else {}))
                        if name != e["name"]:
                            out[name]["original"] = e["name"]
        for let in d.lets:
            out[let["name"]] = dict(let, file=self.rel(path), **{"from": herkunft, "foreign": False})
        self.cache[path] = out
        return out

    def erreichbare_dateien(self):
        """Alle Dateien des Pakets, die von der Einstiegsdatei aus importiert werden."""
        gesehen = []
        offen = [self.entry]
        while offen:
            p = offen.pop().resolve()
            if p in gesehen or not p.exists() or not self.eigen(p):
                continue
            gesehen.append(p)
            for source in self.datei(p).all_sources:
                if not source.startswith("@"):
                    ziel = self.aufloesen(source, p)
                    if ziel[1].suffix == ".typ":
                        offen.append(ziel[1])
        return gesehen

    # --- Ausgabe ---

    def als_json(self):
        def knapp(e):
            out = {"name": e["name"], "file": e["file"], "line": e["line"]}
            if e["kind"] in ("function",):
                out["params"] = e["params"]
                out["doc"] = bool(e["doc"])
            if e.get("original"):
                out["original"] = e["original"]
            return out

        gruppen = {"functions": [], "values": [], "stubs": [], "modules": [], "reexports": [], "private": []}
        for name, e in self.exports.items():
            if name.startswith("_"):
                gruppen["private"].append(name)
            elif e["from"] is not None:
                gruppen["reexports"].append(dict(knapp(e), kind=e["kind"], **{"from": e["from"]}))
            elif e["kind"] == "function":
                gruppen["functions"].append(knapp(e))
            elif e["kind"] == "stub":
                gruppen["stubs"].append(knapp(e))
            elif e["kind"] == "module":
                gruppen["modules"].append(knapp(e))
            else:
                gruppen["values"].append(knapp(e))
        return {
            "package": self.paket,
            "version": self.version,
            "entrypoint": self.rel(self.entry),
            **gruppen,
            "wildcards": self.wildcards + self.lokale_wildcards,
        }

    # --- Lint ---

    def lint(self):
        woerter = set(wortliste("words-en"))
        namen = wortliste("names")
        namen_segmente = {n for n in namen if "-" not in n}
        namen_ganz = set(namen)
        bausteine = set(wortliste("bausteine-de"))
        baustein_segmente = {seg for b in bausteine for seg in b.split("-")}
        fremdnamen = set(wortliste("fremdnamen"))
        zwillinge = set(wortliste("zwillinge"))
        befunde = []

        def melde(datei, zeile, regel, text):
            befunde.append((datei, zeile, regel, text))

        def pruefe_name(name, datei, zeile, wo, funktion=False):
            """L1, L2, L4, L27 für einen englischen Namen."""
            if funktion and (name in bausteine or name == self.paket or name in fremdnamen):
                return
            if name in namen_ganz:
                return
            if not funktion and name in AXES:
                return
            if not NAME_RE.match(name):
                grund = []
                if re.search(r"[äöüßÄÖÜ]", name):
                    grund.append("Umlaut")
                if "_" in name:
                    grund.append("Unterstrich")
                if re.search(r"[A-Z]", name):
                    grund.append("Großbuchstabe")
                melde(datei, zeile, "L1", f"`{name}`{wo}: kein kebab-case/ASCII" + (f" ({', '.join(grund)})" if grund else ""))
            segmente = [s for s in re.split(r"[-_]", name.lower()) if s]
            deutsch = [s for s in segmente if s in baustein_segmente]
            if deutsch:
                melde(datei, zeile, "L27", f"`{name}`{wo}: Mischname, enthält den deutschen Baustein `{'`, `'.join(deutsch)}` – ganz deutsch (bausteine-de.txt) oder das Parameterwort aus wortpaare.json")
            fehlt = [s for s in segmente if s not in woerter and s not in namen_segmente and s not in baustein_segmente]
            if fehlt:
                englisch = [s for s in segmente if s in woerter]
                misch = f" (Mischname neben englisch `{'`, `'.join(englisch)}`)" if englisch else ""
                melde(datei, zeile, "L2", f"`{name}`{wo}: `{'`, `'.join(fehlt)}` nicht in words-en.txt/names.txt{misch}")
            if len(segmente) > 1:
                if segmente[0] in PREFIXES:
                    melde(datei, zeile, "L4", f"`{name}`{wo}: verbotenes Präfix `{segmente[0]}-`")
                if segmente[-1] in SUFFIXES:
                    melde(datei, zeile, "L4", f"`{name}`{wo}: verbotenes Suffix `-{segmente[-1]}`")

        eigene_funktionen = {n for n, e in self.exports.items()
                             if e["from"] is None and e["kind"] == "function" and not n.startswith("_")}

        for name, e in self.exports.items():
            datei, zeile = e["file"], e["line"]
            if name in zwillinge:
                melde(datei, zeile, "L27", f"`{name}`: englischer Zwilling eines Bausteins (zwillinge.txt) darf nicht exportiert werden")
            if e["kind"] == "stub":
                continue
            if not self.eigen(REPO / datei):
                continue  # kommt aus einem anderen @schule-Paket; dort geprüft
            if e.get("foreign"):
                if not (name in fremdnamen and self.paket in FREMDNAMEN_PAKETE) and not name.startswith("_"):
                    melde(datei, zeile, "L19", f"`{name}`: Fremdname aus {e['from']} wird exportiert – Import in eine Datei unter src/ verlegen und in der Einstiegsdatei nur Eigenes namentlich exportieren")
                elif name.startswith("_"):
                    melde(datei, zeile, "L19", f"`{name}`: Unterstrich-Name ist von außen erreichbar – nach src/internal verlegen")
                continue
            if e["from"] is not None:
                continue  # aus einem anderen @schule-Paket; dort geprüft
            if name.startswith("_"):
                melde(datei, zeile, "L19", f"`{name}`: Unterstrich-Name ist von außen erreichbar – nach src/internal verlegen und namentlich importieren")
                continue
            if e["kind"] == "module":
                if name != "internal":
                    melde(datei, zeile, "L19", f"`{name}`: Modul wird exportiert – nur `internal` ist als Modul erlaubt")
                continue
            if e["kind"] == "unknown":
                melde(datei, zeile, "L19", f"`{name}`: Herkunft nicht auflösbar ({e['from']})")
                continue
            pruefe_name(name, datei, zeile, "", funktion=True)
            if e["kind"] != "function":
                continue
            # L26 Docstring
            params = e["params"]
            if not e["doc"]:
                melde(datei, zeile, "L26", f"`{name}`: Docstring fehlt (`///` direkt über `#let`)")
            else:
                dok = set()
                for z in e["doc"]:
                    m = re.match(r"///\s*-\s*(?:\.\.)?([^\s(:]+)\s*\(", z)
                    if m:
                        dok.add(m.group(1))
                sig = [p["name"].lstrip(".") for p in params if p["name"].lstrip(".") and re.fullmatch(IDENT, p["name"].lstrip("."))]
                for p in sig:
                    if p not in dok:
                        melde(datei, zeile, "L26", f"`{name}`: Parameter `{p}` fehlt im Docstring (`/// - {p} (typ): Text`)")
                for p in sorted(dok - set(sig)):
                    melde(datei, zeile, "L26", f"`{name}`: Docstring nennt `{p}`, die Signatur nicht")
            # Parameter
            for i, p in enumerate(params):
                wo = f" (Parameter von `{name}`)"
                if p["kind"] == "sink":
                    sink = p["name"][2:]
                    if sink not in SINKS:
                        melde(datei, zeile, "L16", f"`{p['name']}`{wo}: ein Sink heißt `deprecated`, `cells`, `items` oder `args`")
                    continue
                if not re.fullmatch(IDENT, p["name"]):
                    continue  # Destrukturierung
                pruefe_name(p["name"], datei, zeile, wo)
                if p["name"] in eigene_funktionen:
                    melde(datei, zeile, "L14", f"`{p['name']}`{wo}: heißt wie eine Funktion desselben Pakets")
                if p["kind"] == "named" and p["default"] in BAD_DEFAULTS:
                    melde(datei, zeile, "L8", f"`{p['name']}: {p['default']}`{wo}: das Aus ist `none` (Auswahl, Wert) oder `false` (Schalter)")
                if p["name"] == "body" and i != len(params) - 1:
                    melde(datei, zeile, "L15", f"`body`{wo}: steht nicht an letzter Stelle")

        # L19 Wildcards
        for w in self.wildcards:
            if self.paket == "klassenarbeit" and re.match(r"@schule/arbeitsblatt:", w["from"]):
                continue  # UMSETZUNG-0.5.0.md: reicht die Oberfläche von arbeitsblatt bewusst weiter
            melde(w["file"], w["line"], "L19", f"Wildcard-Re-Export `{w['from']}: *` – namentlich importieren")
        for w in self.lokale_wildcards:
            melde(w["file"], w["line"], "L19", f"Wildcard-Import `{w['from']}: *` in einer exportierten Datei – namentlich exportieren")

        # L21 Fehlermechanik
        for path in self.erreichbare_dateien():
            if path.name == "check.typ":
                continue
            d = self.datei(path)
            for m in re.finditer(r"(?<![\w\-.])(panic|assert)\s*(\.\s*(eq|ne)\s*)?\(", d.code):
                melde(self.rel(path), d._line(m.start()), "L21", f"`{m.group(1)}(` im Paketquelltext – Meldungen nur über `fail` aus src/internal/check.typ")

        # check.typ-Kopie
        quelle = NAMEN / "check.typ"
        kopie = self.pkgdir / "src" / "internal" / "check.typ"
        if not kopie.exists():
            melde(self.rel(kopie), 1, "check", "Kopie von .github/namen/check.typ fehlt")
        elif quelle.exists() and kopie.read_bytes() != quelle.read_bytes():
            melde(self.rel(kopie), 1, "check", "weicht von .github/namen/check.typ ab – neu kopieren")

        # typst.toml
        toml = self.rel(self.pkgdir / "typst.toml")
        if self.toml.get("version") != self.version:
            melde(toml, 1, "toml", f"version = \"{self.toml.get('version')}\" passt nicht zum Ordner {self.version}")
        if self.toml.get("name") != self.paket:
            melde(toml, 1, "toml", f"name = \"{self.toml.get('name')}\" passt nicht zum Ordner {self.paket}")

        if version_key(self.version) >= [0, 5, 0] and self.toml.get("compiler") != "0.15.0":
            melde(toml, 1, "toml", f"compiler = \"{self.toml.get('compiler')}\" – verlangt ist \"0.15.0\"")

        return sorted(set(befunde), key=lambda b: (b[0], b[1], b[2], b[3]))

    # --- Laufzeitvergleich ---

    def eval_vergleich(self):
        with tempfile.TemporaryDirectory() as tmp:
            os.symlink(REPO, Path(tmp) / "schule")
            ausdruck = (f'import "@schule/{self.paket}:{self.version}" as m; '
                        'dictionary(m).pairs().map(((k, v)) => (k, repr(type(v))))')
            lauf = subprocess.run(["typst", "eval", "--package-path", tmp, "--root", str(REPO), ausdruck],
                                  capture_output=True, text=True)
        if lauf.returncode != 0:
            print(lauf.stderr.strip(), file=sys.stderr)
            return 2
        laufzeit = dict(json.loads(lauf.stdout))
        statisch = self.exports
        fehler = 0
        for name in sorted(set(statisch) - set(laufzeit)):
            print(f"nur statisch: {name} ({statisch[name]['file']}:{statisch[name]['line']})")
            fehler += 1
        offene = [w for w in self.wildcards if not w.get("resolved")]
        if offene:
            print(f"Hinweis: {len(offene)} Wildcard-Importe fremder Pakete; "
                  f"{len(set(laufzeit) - set(statisch))} Laufzeitnamen stammen von dort und werden nicht verglichen",
                  file=sys.stderr)
        else:
            for name in sorted(set(laufzeit) - set(statisch)):
                print(f"nur zur Laufzeit: {name} ({laufzeit[name]})")
                fehler += 1
        for name, e in statisch.items():
            if name in laufzeit and e["kind"] in ("function", "stub") and laufzeit[name] != "function":
                print(f"Art weicht ab: {name} ist statisch {e['kind']}, zur Laufzeit {laufzeit[name]}")
                fehler += 1
            if name in laufzeit and e["kind"] == "variable" and e["from"] is None and laufzeit[name] == "function":
                print(f"Hinweis: {name} ist zur Laufzeit eine Funktion, statisch ohne Signatur ({e['file']}:{e['line']})",
                      file=sys.stderr)
        print(f"{len(statisch)} Namen statisch, {len(laufzeit)} zur Laufzeit, {fehler} Abweichungen", file=sys.stderr)
        return 1 if fehler else 0


def main(argv):
    flags = [a for a in argv if a.startswith("--")]
    args = [a for a in argv if not a.startswith("--")]
    unbekannt = [f for f in flags if f not in ("--lint", "--eval", "--help")]
    if "--help" in flags or not args or len(args) > 2 or unbekannt:
        print(__doc__.strip(), file=sys.stderr)
        return 0 if "--help" in flags else 2
    paket = args[0].strip("/")
    if "/" in paket and len(args) == 1:
        paket, version = paket.split("/", 1)
    else:
        version = args[1] if len(args) == 2 else None
    if not (REPO / paket).is_dir():
        sys.exit(f"sig.py: Paket {paket}/ gibt es nicht")
    analyse = Analyse(paket, version or neueste_version(paket))
    if "--eval" in flags:
        return analyse.eval_vergleich()
    if "--lint" in flags:
        befunde = analyse.lint()
        for datei, zeile, regel, text in befunde:
            print(f"{datei}:{zeile}: {regel}: {text}")
        print(f"{analyse.paket} {analyse.version}: {len(befunde)} Verstöße", file=sys.stderr)
        return 1 if befunde else 0
    print(json.dumps(analyse.als_json(), ensure_ascii=False, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
