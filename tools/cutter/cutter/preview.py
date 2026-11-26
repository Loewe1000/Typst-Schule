"""Vorschau eines Schnittplans als SVG: Blatt, Passermarken, Schnittlinien in
ihrer Reihenfolge (Farbverlauf blau → rot, Nummern am Anfang) und Leerfahrten
gestrichelt."""

from __future__ import annotations

from .job import Polyline, Sheet


def _color(i: int, n: int) -> str:
    t = i / max(n - 1, 1)
    r, g, b = int(40 + 200 * t), int(90 - 40 * t), int(220 - 180 * t)
    return f"#{r:02x}{g:02x}{b:02x}"


def marks_svg(sheet: Sheet) -> str:
    m = sheet.marks
    if not m:
        return ""
    r, b, s, L = m.left + m.width, m.top + m.length, m.thickness, m.line
    rects = [
        (m.left, m.top, m.square, m.square),
        (r - L, m.top, L, s), (r - s, m.top, s, L),
        (m.left, b - s, L, s), (m.left, b - L, s, L),
    ]
    return "".join(f'<rect x="{x:.2f}" y="{y:.2f}" width="{w:.2f}" height="{h:.2f}" fill="#000"/>'
                   for x, y, w, h in rects)


def plan_svg(sheet: Sheet, lines: list[Polyline], background: str | None = None) -> str:
    w, h = sheet.page_size
    dx, dy = (sheet.marks.left, sheet.marks.top) if sheet.marks else (0.0, 0.0)
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" '
           f'width="{w}mm" height="{h}mm" viewBox="0 0 {w} {h}">',
           f'<rect width="{w}" height="{h}" fill="#fff" stroke="#999" stroke-width="0.3"/>']
    if background:
        out.append(f'<image href="{background}" xlink:href="{background}" x="0" y="0" width="{w}" '
                   f'height="{h}" opacity="0.35"/>')
    out.append(marks_svg(sheet))
    pos = (-dx, -dy) if sheet.marks else (0.0, 0.0)
    n = len(lines)
    for i, line in enumerate(lines):
        (x0, y0) = line[0]
        out.append(f'<line x1="{pos[0] + dx:.2f}" y1="{pos[1] + dy:.2f}" x2="{x0 + dx:.2f}" y2="{y0 + dy:.2f}" '
                   'stroke="#888" stroke-width="0.25" stroke-dasharray="1 1"/>')
        pts = " ".join(f"{x + dx:.2f},{y + dy:.2f}" for x, y in line)
        c = _color(i, n)
        out.append(f'<polyline points="{pts}" fill="none" stroke="{c}" stroke-width="0.5" '
                   'stroke-linejoin="round"/>')
        out.append(f'<circle cx="{x0 + dx:.2f}" cy="{y0 + dy:.2f}" r="1" fill="{c}"/>'
                   f'<text x="{x0 + dx + 1.4:.2f}" y="{y0 + dy - 1.2:.2f}" font-size="3" '
                   f'font-family="Helvetica" fill="{c}">{i + 1}</text>')
        pos = line[-1]
    out.append("</svg>")
    return "\n".join(out)
