"""Schnittaufträge: Datenmodell und Einlesen aus Typst, JSON und SVG.

Alle Längen in Millimetern. Hat ein Bogen Passermarken, sind die Koordinaten
von der linken oberen Ecke der Marken aus gemessen (x nach rechts, y nach
unten); so erwartet sie der Plotter nach der Markensuche. Ohne Marken gelten
sie von der linken oberen Ecke des Blatts aus.
"""

from __future__ import annotations

import json
import math
import re
import shutil
import subprocess
from dataclasses import dataclass, field
from pathlib import Path

Point = tuple[float, float]
Polyline = list[Point]


@dataclass
class Marks:
    """Passermarken im Silhouette-Format (Quadrat links oben, Winkel rechts
    oben und links unten)."""

    left: float = 10.0  # Abstand der Marken vom linken Blattrand
    top: float = 10.0  # Abstand vom oberen Blattrand
    width: float = 190.0  # von Marke zu Marke waagerecht
    length: float = 277.0  # von Marke zu Marke senkrecht
    square: float = 5.0
    line: float = 20.0
    thickness: float = 0.5

    @classmethod
    def for_page(cls, page_size: tuple[float, float], inset: float = 10.0) -> "Marks":
        w, h = page_size
        return cls(left=inset, top=inset, width=w - 2 * inset, length=h - 2 * inset)


@dataclass
class Sheet:
    """Ein Bogen: eine Seite mit ihren Schnittlinien."""

    paths: list[Polyline]
    page_size: tuple[float, float] = (210.0, 297.0)
    marks: Marks | None = None
    page: int | None = None  # Seitenzahl im Quelldokument, falls bekannt
    source: str = ""
    # Umrisse der Teile (geschlossen); daran erkennt die Planung, wo ein
    # Überschnitt in den Abfall läuft und wo er ein Teil anritzen würde.
    pieces: list[Polyline] = field(default_factory=list)
    # Prüfkreuz (gleiche Koordinaten wie `paths`), falls mitgedruckt
    check: Point | None = None

    def page_paths(self) -> list[Polyline]:
        """Die Linien in Blattkoordinaten (für Vorschauen)."""
        dx, dy = (self.marks.left, self.marks.top) if self.marks else (0.0, 0.0)
        return [[(x + dx, y + dy) for x, y in p] for p in self.paths]

    def bbox(self) -> tuple[float, float, float, float]:
        xs = [x for p in self.paths for x, _ in p]
        ys = [y for p in self.paths for _, y in p]
        if not xs:
            return (0.0, 0.0, 0.0, 0.0)
        return (min(xs), min(ys), max(xs), max(ys))

    def warnings(self) -> list[str]:
        """Warnungen, wenn Linien außerhalb des Markenrahmens liegen."""
        out = []
        if self.marks is None:
            return out
        x0, y0, x1, y1 = self.bbox()
        if x0 < 0 or y0 < 0 or x1 > self.marks.width or y1 > self.marks.length:
            out.append(
                "Linien reichen über den Rahmen der Passermarken hinaus "
                f"(x {x0:.1f}…{x1:.1f}, y {y0:.1f}…{y1:.1f} mm, Rahmen "
                f"{self.marks.width:.1f} × {self.marks.length:.1f} mm); der Plotter schneidet dort nicht."
            )
        return out


class JobError(Exception):
    pass


# ---------------------------------------------------------------------------
# cut-data (Typst-Metadaten, JSON)
# ---------------------------------------------------------------------------


def sheet_from_cut_data(d: dict, source: str = "") -> Sheet:
    if d.get("format") != "cut-data":
        raise JobError("kein cut-data-Eintrag (Schlüssel `format` fehlt oder ist falsch)")
    if d.get("unit", "mm") != "mm":
        raise JobError(f"unbekannte Einheit {d.get('unit')!r}, erwartet wird mm")
    m = d.get("marks")
    marks = None
    if m:
        marks = Marks(
            left=float(m["left"]),
            top=float(m["top"]),
            width=float(m["width"]),
            length=float(m["length"]),
            square=float(m.get("square", 5)),
            line=float(m.get("line", 20)),
            thickness=float(m.get("thickness", 0.5)),
        )
    paths = [[(float(x), float(y)) for x, y in p] for p in d.get("paths", [])]
    size = d.get("page-size", (210, 297))
    pieces = [[(float(x), float(y)) for x, y in p] for p in d.get("pieces", [])]
    check = tuple(float(v) for v in d["check"]) if d.get("check") else None
    return Sheet(
        paths=paths,
        pieces=pieces,
        check=check,
        page_size=(float(size[0]), float(size[1])),
        marks=marks,
        page=d.get("page"),
        source=source or d.get("source", ""),
    )


def load_json(path: Path) -> list[Sheet]:
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    if isinstance(data, dict):
        data = [data]
    # Ausgabe von `typst query` (Elemente mit "value") ebenfalls annehmen
    data = [d.get("value", d) if isinstance(d, dict) and "func" in d else d for d in data]
    return [sheet_from_cut_data(d, source=str(path)) for d in data]


def find_typst() -> str:
    exe = shutil.which("typst")
    if exe:
        return exe
    for cand in ("/opt/homebrew/bin/typst", "/usr/local/bin/typst"):
        if Path(cand).exists():
            return cand
    raise JobError("`typst` nicht gefunden – Typst installieren oder in den PATH legen")


def load_typst(path: Path, typst: str | None = None, root: Path | None = None) -> list[Sheet]:
    """Liest alle `<cut-data>`-Einträge eines Typst-Dokuments."""
    path = Path(path).resolve()
    cmd = [typst or find_typst(), "eval", "query(<cut-data>).map(m => m.value)",
           "--in", str(path), "--format", "json"]
    if root:
        cmd += ["--root", str(root)]
    r = subprocess.run(cmd, capture_output=True, text=True, cwd=path.parent)
    if r.returncode != 0:
        raise JobError("Typst meldet einen Fehler:\n" + r.stderr.strip())
    data = json.loads(r.stdout)
    if not data:
        raise JobError(
            "keine Schnittdaten im Dokument – bei trimino `cut-marks: true` setzen "
            "(andere Dokumente brauchen `metadata(...) <cut-data>`)"
        )
    return [sheet_from_cut_data(d, source=str(path)) for d in data]


def render_page_png(path: Path, page: int, out: Path, ppi: int = 60, typst: str | None = None) -> Path:
    """Setzt eine Seite eines Typst-Dokuments als PNG (für die Vorschau)."""
    path = Path(path).resolve()
    cmd = [typst or find_typst(), "compile", str(path), str(out), "--pages", str(page),
           "--ppi", str(ppi), "--format", "png"]
    r = subprocess.run(cmd, capture_output=True, text=True, cwd=path.parent)
    if r.returncode != 0:
        raise JobError("Typst meldet einen Fehler:\n" + r.stderr.strip())
    return out


# ---------------------------------------------------------------------------
# SVG: Linien bestimmter Farben
# ---------------------------------------------------------------------------


def parse_color(text: str) -> tuple[int, int, int]:
    named = {"red": "#ff0000", "rot": "#ff0000", "blue": "#0000ff", "blau": "#0000ff",
             "green": "#00ff00", "grün": "#00ff00", "black": "#000000", "schwarz": "#000000",
             "magenta": "#ff00ff", "cyan": "#00ffff"}
    t = named.get(text.strip().lower(), text.strip())
    m = re.fullmatch(r"#?([0-9a-fA-F]{6}|[0-9a-fA-F]{3})", t)
    if not m:
        raise JobError(f"Farbe {text!r} nicht verstanden – zum Beispiel `#ff0000` oder `rot`")
    h = m.group(1)
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))


def _close(c1, c2, tol: int) -> bool:
    return all(abs(a - b) <= tol for a, b in zip(c1, c2))


def svg_colors(path: Path) -> dict[str, int]:
    """Alle Strichfarben einer SVG-Datei mit ihrer Häufigkeit (für die Auswahl)."""
    from svgelements import SVG, Shape

    counts: dict[str, int] = {}
    for el in SVG.parse(str(path)).elements():
        if isinstance(el, Shape) and el.stroke is not None and el.stroke.value is not None:
            key = el.stroke.hex[:7]
            counts[key] = counts.get(key, 0) + 1
    return dict(sorted(counts.items(), key=lambda kv: -kv[1]))


def load_svg(path: Path, colors: list[str], tolerance: int = 24,
             mark_inset: float | None = None, step: float = 0.5,
             check: Point | None = None) -> list[Sheet]:
    """Schneidet die Linien, deren Strichfarbe einer der `colors` entspricht.

    `mark_inset`: Abstand der Silhouette-Passermarken vom Blattrand in mm,
    wenn das Blatt welche trägt (Standard 10); `None` heißt ohne Marken.
    `step`: größte Sehnenlänge beim Annähern von Kurven in mm.
    `check`: Mitte eines mitgedruckten Prüfkreuzes in mm ab Blattecke.
    Geschlossene Linienzüge gelten als Teile (für den Überschnitt).
    """
    from svgelements import SVG, Close, Line, Move, Path as SvgPath, Shape

    targets = [parse_color(c) for c in colors]
    svg = SVG.parse(str(path), ppi=96.0)
    px = 25.4 / 96.0  # svgelements rechnet in px zu 96 dpi
    page = (float(svg.width) * px, float(svg.height) * px)

    paths: list[Polyline] = []
    for el in svg.elements():
        if not isinstance(el, Shape) or el.stroke is None or el.stroke.value is None:
            continue
        c = (el.stroke.red, el.stroke.green, el.stroke.blue)
        if not any(_close(c, t, tolerance) for t in targets):
            continue
        p = abs(SvgPath(el))  # Transformationen anwenden
        current: Polyline = []
        for seg in p:
            if isinstance(seg, Move):
                if len(current) > 1:
                    paths.append(current)
                current = [(seg.end.x * px, seg.end.y * px)]
            elif isinstance(seg, (Line, Close)):
                if seg.end is None:
                    continue
                if not current:
                    current = [(seg.start.x * px, seg.start.y * px)]
                current.append((seg.end.x * px, seg.end.y * px))
            else:
                length = seg.length(error=1e-3) * px
                n = max(2, int(length / step) + 1)
                if not current:
                    current = [(seg.start.x * px, seg.start.y * px)]
                for i in range(1, n + 1):
                    q = seg.point(i / n)
                    current.append((q.x * px, q.y * px))
        if len(current) > 1:
            paths.append(current)

    if not paths:
        found = ", ".join(svg_colors(path)) or "keine"
        raise JobError(f"keine Linien in den Farben {', '.join(colors)} – vorhandene Strichfarben: {found}")

    pieces = [p for p in paths if len(p) > 3 and math.dist(p[0], p[-1]) < 0.05]
    marks = None
    if mark_inset is not None:
        marks = Marks.for_page(page, mark_inset)
        shift = lambda pts: [(x - marks.left, y - marks.top) for x, y in pts]
        paths = [shift(p) for p in paths]
        pieces = [shift(p) for p in pieces]
        if check:
            check = (check[0] - marks.left, check[1] - marks.top)
    return [Sheet(paths=paths, page_size=page, marks=marks, source=str(path),
                  pieces=pieces, check=check)]


def load(path: Path, colors: list[str] | None = None, mark_inset: float | None = 10.0,
         tolerance: int = 24, check: Point | None = None) -> list[Sheet]:
    """Liest eine Datei nach ihrer Endung."""
    path = Path(path)
    ext = path.suffix.lower()
    if ext == ".typ":
        return load_typst(path)
    if ext == ".json":
        return load_json(path)
    if ext == ".svg":
        return load_svg(path, colors or ["#ff0000"], tolerance=tolerance, mark_inset=mark_inset,
                        check=check)
    raise JobError(f"unbekannter Dateityp {ext!r} – erwartet .typ, .json oder .svg")
