"""Schnittreihenfolge: Strecken entdoppeln, zu geraden Schnitten verbinden,
an spitzen Ecken trennen, in den Abfall überschneiden, ordnen.

- Doppelte Strecken (gemeinsame Kanten zweier Teile) werden nur einmal
  geschnitten.
- Ein Schnitt läuft nur so lange weiter, wie die Richtung sich kaum ändert
  (höchstens `corner` Grad). An einer spitzen Ecke biegt das Messer nicht ab:
  Der Schnitt endet, und die nächste Kante wird neu angesetzt. Ein
  Schleppmesser reißt beim Abbiegen sonst die Ecke aus.
- Überschnitt: Jedes Schnittende wird um `overcut` mm verlängert, wenn die
  Verlängerung in den Abfall läuft, also in keinem Teil liegt. So treffen sich
  die Schnitte an den Ecken sicher. Ohne bekannte Teile gibt es keinen
  Überschnitt.
- Zwischen den Schnitten fährt der Kopf zum nächstgelegenen Ende; ein
  Schnitt darf dafür auch rückwärts laufen.
"""

from __future__ import annotations

import math
from dataclasses import dataclass

from .job import Point, Polyline

GRID = 0.01  # mm; Punkte näher als das gelten als gleich


def _key(p: Point) -> tuple[int, int]:
    return (round(p[0] / GRID), round(p[1] / GRID))


def segments(paths: list[Polyline]) -> list[tuple[Point, Point]]:
    """Alle Strecken, doppelte und entartete entfernt."""
    seen = set()
    out = []
    for path in paths:
        for a, b in zip(path, path[1:]):
            ka, kb = _key(a), _key(b)
            if ka == kb:
                continue
            k = (ka, kb) if ka < kb else (kb, ka)
            if k in seen:
                continue
            seen.add(k)
            out.append((a, b))
    return out


def _angle(a: Point, b: Point) -> float:
    return math.atan2(b[1] - a[1], b[0] - a[0])


def _turn(d1: float, d2: float) -> float:
    d = abs(d2 - d1) % (2 * math.pi)
    return min(d, 2 * math.pi - d)


def simplify(path: Polyline, eps: float = 0.005) -> Polyline:
    """Entfernt Zwischenpunkte, die auf einer Geraden liegen."""
    if len(path) < 3:
        return path
    out = [path[0]]
    for p, q in zip(path[1:], path[2:]):
        a = out[-1]
        cross = (p[0] - a[0]) * (q[1] - a[1]) - (p[1] - a[1]) * (q[0] - a[0])
        dot = (p[0] - a[0]) * (q[0] - p[0]) + (p[1] - a[1]) * (q[1] - p[1])
        if abs(cross) / max(math.dist(a, q), 1e-9) < eps and dot > 0:
            continue
        out.append(p)
    out.append(path[-1])
    return out


# ---------------------------------------------------------------------------
# Teile: Punkt im Polygon
# ---------------------------------------------------------------------------


def _inside(p: Point, poly: Polyline) -> bool:
    x, y = p
    hit = False
    n = len(poly)
    for i in range(n):
        (x1, y1), (x2, y2) = poly[i], poly[(i + 1) % n]
        if (y1 > y) != (y2 > y):
            if x < x1 + (y - y1) * (x2 - x1) / (y2 - y1):
                hit = not hit
    return hit


def _dist_to_outline(p: Point, poly: Polyline) -> float:
    best = math.inf
    n = len(poly)
    for i in range(n):
        a, b = poly[i], poly[(i + 1) % n]
        dx, dy = b[0] - a[0], b[1] - a[1]
        L2 = dx * dx + dy * dy
        t = 0.0 if L2 == 0 else max(0.0, min(1.0, ((p[0] - a[0]) * dx + (p[1] - a[1]) * dy) / L2))
        best = min(best, math.dist(p, (a[0] + t * dx, a[1] + t * dy)))
    return best


def in_waste(p: Point, pieces: list[Polyline], margin: float = 0.05) -> bool:
    """Liegt `p` außerhalb aller Teile (mit etwas Abstand zu ihren Rändern)?"""
    for poly in pieces:
        if _inside(p, poly) and _dist_to_outline(p, poly) > margin:
            return False
    return True


def _extend(line: Polyline, overcut: float, pieces: list[Polyline],
            frame: tuple[float, float] | None) -> Polyline:
    def ext(p: Point, q: Point) -> Point | None:
        # Verlängerung von q über p hinaus
        L = math.dist(p, q)
        if L == 0:
            return None
        ux, uy = (p[0] - q[0]) / L, (p[1] - q[1]) / L
        e = (p[0] + ux * overcut, p[1] + uy * overcut)
        if frame and not (0 <= e[0] <= frame[0] and 0 <= e[1] <= frame[1]):
            return None
        samples = [(p[0] + ux * overcut * f, p[1] + uy * overcut * f) for f in (0.25, 0.5, 0.75, 1.0)]
        return e if all(in_waste(s, pieces) for s in samples) else None

    out = list(line)
    a = ext(line[0], line[1])
    b = ext(line[-1], line[-2])
    if a:
        out.insert(0, a)
    if b:
        out.append(b)
    return out


# ---------------------------------------------------------------------------
# Planung
# ---------------------------------------------------------------------------


def lines_from(paths: list[Polyline], corner: float = 30.0) -> list[Polyline]:
    """Verbindet Strecken zu Schnitten, die höchstens um `corner` Grad abknicken."""
    segs = segments(paths)
    adj: dict[tuple[int, int], list[int]] = {}
    for i, (a, b) in enumerate(segs):
        adj.setdefault(_key(a), []).append(i)
        adj.setdefault(_key(b), []).append(i)
    used = [False] * len(segs)
    limit = math.radians(corner)

    def grow(line: Polyline) -> None:
        # verlängert `line` an ihrem Ende, solange es geradeaus weitergeht
        while True:
            end, prev = line[-1], line[-2]
            d = _angle(prev, end)
            best = None
            for i in adj[_key(end)]:
                if used[i]:
                    continue
                a, b = segs[i]
                nxt = b if _key(a) == _key(end) else a
                t = _turn(d, _angle(end, nxt))
                if t <= limit and (best is None or t < best[0]):
                    best = (t, i, nxt)
            if best is None:
                return
            used[best[1]] = True
            line.append(best[2])

    out = []
    for i, (a, b) in enumerate(segs):
        if used[i]:
            continue
        used[i] = True
        line = [a, b]
        grow(line)
        line.reverse()
        grow(line)
        out.append(simplify(line))
    return out


def order(lines: list[Polyline], start: Point = (0.0, 0.0)) -> list[Polyline]:
    """Nächstes Ende zuerst; Schnitte dürfen dafür umgedreht werden."""
    rest = list(lines)
    pos = start
    out = []
    while rest:
        best = None
        for i, l in enumerate(rest):
            for rev in (False, True):
                p = l[-1] if rev else l[0]
                d = math.dist(pos, p)
                if best is None or d < best[0]:
                    best = (d, i, rev)
        _, i, rev = best
        l = rest.pop(i)
        if rev:
            l = l[::-1]
        out.append(l)
        pos = l[-1]
    return out


def _horizontal(line: Polyline) -> bool:
    return all(abs(p[1] - line[0][1]) < 0.01 for p in line)


def order_rows_first(lines: list[Polyline], start: Point = (0.0, 0.0)) -> list[Polyline]:
    """Erst alle waagerechten Schnitte von oben nach unten (im Zickzack),
    dann die übrigen nach kurzen Leerfahrten.

    Waagerecht heißt hier: quer zum Vorschub. Diese Schnitte sitzen damit,
    bevor sich ein Rutschen der Matte unter den schrägen Schnitten
    aufsummieren kann.
    """
    flat = sorted((l for l in lines if _horizontal(l)), key=lambda l: l[0][1])
    rest = [l for l in lines if not _horizontal(l)]
    out = []
    for i, l in enumerate(flat):
        left_to_right = l[0][0] <= l[-1][0]
        out.append(l if left_to_right == (i % 2 == 0) else l[::-1])
    return out + order(rest, out[-1][-1] if out else start)


def plan(paths: list[Polyline], start: Point = (0.0, 0.0), corner: float = 30.0,
         overcut: float = 0.0, pieces: list[Polyline] | None = None,
         frame: tuple[float, float] | None = None) -> list[Polyline]:
    """Ordnet die Linien zu einer Schnittfolge."""
    lines = lines_from(paths, corner)
    if overcut > 0 and pieces:
        # Der Überschnitt verlängert eine Gerade; zusammenfassen, damit jede
        # gerade Linie nur Anfang und Ende hat.
        lines = [simplify(_extend(l, overcut, pieces, frame)) for l in lines]
    return order_rows_first(lines, start)


def plan_sheet(sheet, corner: float = 30.0, overcut: float = 1.0) -> list[Polyline]:
    frame = (sheet.marks.width, sheet.marks.length) if sheet.marks else None
    return plan(sheet.paths, corner=corner, overcut=overcut, pieces=sheet.pieces, frame=frame)


def outline(pieces: list[Polyline], paths: list[Polyline] | None = None) -> list[Polyline]:
    """Äußerer Umriss: alle Kanten, die nur zu einem Teil gehören, zu
    geschlossenen Zügen verbunden. Ohne Teile das umschließende Rechteck."""
    if not pieces:
        pts = [p for path in (paths or []) for p in path]
        if not pts:
            return []
        xs, ys = [p[0] for p in pts], [p[1] for p in pts]
        x0, y0, x1, y1 = min(xs), min(ys), max(xs), max(ys)
        return [[(x0, y0), (x1, y0), (x1, y1), (x0, y1), (x0, y0)]]
    count: dict = {}
    for poly in pieces:
        ring = list(poly) if _key(poly[0]) != _key(poly[-1]) else list(poly[:-1])
        for a, b in zip(ring, ring[1:] + ring[:1]):
            ka, kb = _key(a), _key(b)
            k = (ka, kb) if ka < kb else (kb, ka)
            count[k] = count.get(k, (0, a, b))
            count[k] = (count[k][0] + 1, count[k][1], count[k][2])
    border = [(a, b) for n, a, b in count.values() if n == 1]
    loops = lines_from([[a, b] for a, b in border], corner=180.0)
    return [simplify(l) for l in loops]


@dataclass
class Stats:
    lines: int
    cut_mm: float
    travel_mm: float


def stats(lines: list[Polyline], start: Point = (0.0, 0.0)) -> Stats:
    cut = sum(math.dist(a, b) for p in lines for a, b in zip(p, p[1:]))
    travel = 0.0
    pos = start
    for p in lines:
        travel += math.dist(pos, p[0])
        pos = p[-1]
    return Stats(lines=len(lines), cut_mm=cut, travel_mm=travel)
