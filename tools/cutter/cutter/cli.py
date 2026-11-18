"""Kommandozeile.

    cutter plan  DATEI   Trockenlauf ohne Gerät: Schnittfolge, Vorschau, Befehle
    cutter info          Plotter suchen und Status lesen (schneidet nichts)
    cutter cut   DATEI   Passermarken suchen und schneiden (fragt vorher nach)
    cutter gui   [DATEI] Fenster
"""

from __future__ import annotations

import argparse
import sys
from dataclasses import replace
from pathlib import Path

from . import __version__
from .device import MATERIALS, MATS, DeviceError, Settings, open_plotter, list_plotters
from .geometry import plan_sheet, stats
from .job import JobError, Sheet, load
from .preview import plan_svg


def _add_source(p: argparse.ArgumentParser) -> None:
    p.add_argument("file", type=Path, help=".typ (mit <cut-data>), .json oder .svg")
    p.add_argument("--page", type=int, action="append",
                   help="nur diese Seite des Dokuments (mehrfach möglich)")
    p.add_argument("--color", action="append",
                   help="SVG: Strichfarbe der Schnittlinien, z. B. '#ff0000' (mehrfach möglich; Standard rot)")
    p.add_argument("--tolerance", type=int, default=24, help="SVG: Farbabweichung je Kanal (0–255)")
    p.add_argument("--mark-inset", type=float, default=10.0,
                   help="SVG: Abstand der Passermarken vom Blattrand in mm (Standard 10)")
    p.add_argument("--no-marks", action="store_true",
                   help="SVG: Blatt ohne Passermarken, Ursprung links oben auf der Matte")
    p.add_argument("--check", help="SVG: Mitte eines mitgedruckten Prüfkreuzes, 'x,y' in mm ab Blattecke")
    p.add_argument("--corner", type=float, default=30.0,
                   help="größter Knick in Grad, um den das Messer weiterschneidet; "
                        "an spitzeren Ecken wird neu angesetzt (Standard 30)")
    p.add_argument("--overcut", type=float, default=1.0,
                   help="Überschnitt in mm an Schnittenden, nur in den Abfall (Standard 1; 0 aus)")


def _add_settings(p: argparse.ArgumentParser) -> None:
    p.add_argument("--material", choices=sorted(MATERIALS), default="karton",
                   help="Startwerte für Tempo, Druck und Tiefe (Standard: karton)")
    p.add_argument("--speed", type=int, help="Tempo 1–30")
    p.add_argument("--force", type=int, help="Druck 1–33")
    p.add_argument("--depth", type=int, help="AutoBlade-Tiefe 0–10")
    p.add_argument("--passes", type=int, help="Durchgänge")
    p.add_argument("--mat", choices=sorted(MATS), help="Schneidematte (Standard cameo-12x12)")
    p.add_argument("--tool", type=int, choices=(1, 2), help="Werkzeughalter")
    p.add_argument("--mark-at",
                   help="Lage der Marke links oben ab Rand der Schneidefläche in mm, 'x,y' oder ein Wert "
                        "für beide (Standard: wie auf dem Blatt, 10); laminierte Bögen liegen oft bei 20")
    p.add_argument("--mark-search", type=float,
                   help="so viele mm vor der ersten Marke beginnt die Suche (Standard 10; "
                        "bei laminierten Bögen kleiner, etwa 4, damit der Sensor nicht das Mattenraster liest)")
    p.add_argument("--track-enhancing", action=argparse.BooleanOptionalAction, default=None,
                   help="Spurverstärkung gegen Rutschen (Standard je Material; bei folie an)")


def settings_from(a: argparse.Namespace) -> Settings:
    s = replace(MATERIALS[a.material])
    if getattr(a, "mark_at", None):
        v = [float(x) for x in a.mark_at.split(",")]
        s.mark_at = (v[0], v[-1])
    for key, attr in (("speed", "speed"), ("force", "force"), ("depth", "depth"),
                      ("passes", "passes"), ("mat", "mat"), ("tool", "toolholder"),
                      ("track_enhancing", "track_enhancing"), ("mark_search", "mark_search")):
        v = getattr(a, key, None)
        if v is not None:
            setattr(s, attr, v)
    return s


def sheets_from(a: argparse.Namespace) -> list[Sheet]:
    check = tuple(float(v) for v in a.check.split(",")) if a.check else None
    sheets = load(a.file, colors=a.color, mark_inset=None if a.no_marks else a.mark_inset,
                  tolerance=a.tolerance, check=check)
    if a.page:
        chosen = [s for s in sheets if s.page in a.page]
        if not chosen:
            pages = ", ".join(str(s.page) for s in sheets)
            raise JobError(f"keine Schnittdaten auf Seite {a.page} – vorhanden: {pages}")
        sheets = chosen
    return sheets


def describe(i: int, n: int, sheet: Sheet, lines) -> str:
    st = stats(lines)
    where = f"Seite {sheet.page}" if sheet.page else Path(sheet.source).name
    marks = (f"Marken {sheet.marks.left:g}/{sheet.marks.top:g} mm, Rahmen "
             f"{sheet.marks.width:g} × {sheet.marks.length:g} mm") if sheet.marks else "ohne Marken"
    return (f"Bogen {i + 1}/{n} ({where}): {len(sheet.paths)} Strecken → {st.lines} Linienzüge, "
            f"Schnitt {st.cut_mm / 10:.1f} cm, Leerfahrt {st.travel_mm / 10:.1f} cm; {marks}")


def cmd_plan(a: argparse.Namespace) -> int:
    sheets = sheets_from(a)
    out = a.out or a.file.with_suffix("")
    settings = settings_from(a)
    for i, sheet in enumerate(sheets):
        lines = plan_sheet(sheet, corner=a.corner, overcut=a.overcut)
        print(describe(i, len(sheets), sheet, lines))
        for w in sheet.warnings():
            print("  Achtung:", w)
        suffix = f"-bogen{i + 1}" if len(sheets) > 1 else ""
        svg = Path(f"{out}{suffix}-schnitt.svg")
        svg.write_text(plan_svg(sheet, lines), encoding="utf-8")
        print(f"  Vorschau: {svg}")
        plotter = open_plotter(dry_run=True, log=lambda m: None)
        plotter.run(lines, settings, sheet.marks, sheet.page_size)
        txt = Path(f"{out}{suffix}-befehle.txt")
        txt.write_text(plotter.t.text(), encoding="utf-8")
        print(f"  Befehle:  {txt} ({len(plotter.t.text().splitlines())} Zeilen)")
    return 0


def cmd_info(a: argparse.Namespace) -> int:
    found = list_plotters()
    if not found:
        print("Kein Silhouette-Plotter gefunden. USB-Kabel und Einschalter prüfen.")
        return 1
    for pid, name in found:
        print(f"gefunden: {name} (USB-ID 0b4d:{pid:04x})")
    if a.query:
        p = open_plotter(dry_run=False)
        try:
            for k, v in p.info().items():
                print(f"  {k}: {v}")
        finally:
            p.t.close()
    return 0


def confirm(question: str) -> bool:
    try:
        return input(question + " [j/N] ").strip().lower() in ("j", "ja", "y", "yes")
    except EOFError:
        return False


def cmd_cut(a: argparse.Namespace) -> int:
    sheets = sheets_from(a)
    settings = settings_from(a)
    what = " und Linien abfahren (Messer oben)" if a.trace else ""
    print(f"Einstellungen: Tempo {settings.speed}, Druck {settings.force}, Tiefe {settings.depth}, "
          f"Durchgänge {settings.passes}, Matte {settings.mat}, Halter {settings.toolholder}, "
          f"Spurverstärkung {'an' if settings.track_enhancing else 'aus'}, Marke bei "
          f"{'%g/%g mm' % settings.mark_at if settings.mark_at else 'Blattlage'}, Suche {settings.mark_search:g} mm davor")
    plotter = None
    try:
        for i, sheet in enumerate(sheets):
            lines = plan_sheet(sheet, corner=a.corner, overcut=a.overcut)
            print(describe(i, len(sheets), sheet, lines))
            for w in sheet.warnings():
                print("  Achtung:", w)
            if not a.yes and not confirm(f"Bogen {i + 1} eingelegt? Jetzt Marken suchen{what}?"):
                print("Abgebrochen, nichts gesendet.")
                return 1
            if plotter is None:
                plotter = open_plotter(dry_run=False)
            plotter.run(lines, settings, sheet.marks, sheet.page_size, trace=a.trace,
                        check=sheet.check, pieces=sheet.pieces, decide=None if a.yes else confirm,
                        report=lambda f, text: print(f"\r  {text}   ", end="", flush=True))
            print()
    finally:
        if plotter:
            plotter.t.close()
    return 0


def cmd_test(a: argparse.Namespace) -> int:
    """Testdreiecke im freien Streifen unter den Teilen."""
    sheets = sheets_from(a)
    sheet = sheets[0]
    settings = settings_from(a)
    depths = [int(v) for v in a.depths.split(",")]
    forces = [int(v) for v in a.forces.split(",")] if a.forces else None
    repeats = [int(v) for v in a.repeats.split(",")] if a.repeats else None
    if forces:
        settings.depth = None  # Tiefe von Hand eingestellt
    size = 10.0
    width = len(forces or repeats or depths) * (size + 6) - 6
    # unter dem untersten Teil, mit 6 mm Abstand; links neben der Marke unten
    _, _, x1, y1 = sheet.bbox()
    y0 = y1 + 6 + size * 0.8660254 + (a.row - 1) * (size * 0.8660254 + 2)
    x0 = a.start_x if a.start_x is not None else (30.0 if sheet.marks else 20.0)
    # Abstand zur unteren Markenlinie und zum Prüfkreuz rechts unten; die
    # Marke links unten reicht nur bis 20 mm, die Dreiecke beginnen bei 30 mm.
    limit_y = (sheet.marks.length - 6) if sheet.marks else sheet.page_size[1] - 10
    limit_x = ((sheet.check[0] - 15) if sheet.check else sheet.marks.width - 25) if sheet.marks \
        else sheet.page_size[0] - 15
    if y0 > limit_y + 0.01 or x0 + width > limit_x:
        raise JobError("unter den Teilen ist kein Platz für die Testdreiecke")
    what = (f"Druck {', '.join(map(str, forces))}, Tiefe von Hand" if forces
            else f"Durchgänge {', '.join(map(str, repeats))}, Tiefe {depths[0]}, Druck {settings.force}" if repeats
            else f"Tiefen {', '.join(map(str, depths))}, Druck {settings.force}")
    passes_txt = "" if repeats else f", {settings.passes} Durchgang/Durchgänge"
    print(f"Testdreiecke {size:g} mm, {what}, Tempo {settings.speed}{passes_txt}, "
          f"Halter {settings.toolholder}; "
          "unter den Kärtchen, von links nach rechts")
    if not a.yes and not confirm("Bogen eingelegt? Jetzt Marken suchen?"):
        print("Abgebrochen, nichts gesendet.")
        return 1
    plotter = open_plotter(dry_run=a.dry_run)
    try:
        plotter.test_cut(settings, sheet.marks, sheet.page_size, depths, (x0, y0), size,
                         check=sheet.check, decide=None if a.yes else confirm, forces=forces,
                         repeats=repeats)
        if a.dry_run:
            print(plotter.t.text())
    finally:
        plotter.t.close()
    return 0


def cmd_gui(a: argparse.Namespace) -> int:
    from .gui import run

    run(a.file)
    return 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="cutter", description="Silhouette-Schneideplotter mit Passermarken")
    ap.add_argument("--version", action="version", version=__version__)
    sub = ap.add_subparsers(dest="command", required=True)

    p = sub.add_parser("plan", help="Trockenlauf ohne Gerät: Vorschau-SVG und Befehlsliste")
    _add_source(p)
    _add_settings(p)
    p.add_argument("--out", type=Path, help="Dateistamm für Vorschau und Befehle")
    p.set_defaults(func=cmd_plan)

    p = sub.add_parser("info", help="Plotter suchen (ohne --query wird nichts gesendet)")
    p.add_argument("--query", action="store_true", help="Firmware, Status und Werkzeuge abfragen")
    p.set_defaults(func=cmd_info)

    p = sub.add_parser("cut", help="Passermarken suchen und schneiden")
    _add_source(p)
    _add_settings(p)
    p.add_argument("--trace", action="store_true", help="vor dem Schnitt die Linien mit angehobenem Messer abfahren, danach nachfragen")
    p.add_argument("--yes", action="store_true", help="ohne Rückfragen schneiden")
    p.set_defaults(func=cmd_cut)

    p = sub.add_parser("test", help="Testdreiecke mit verschiedenen Tiefen im freien Streifen unter den Teilen")
    _add_source(p)
    _add_settings(p)
    p.add_argument("--depths", default="5,6,7,8", help="Tiefen, durch Komma getrennt (Standard 5,6,7,8)")
    p.add_argument("--forces", help="statt der Tiefe den Druck variieren, etwa 20,26,33 "
                   "(für Messer, deren Tiefe von Hand eingestellt wird)")
    p.add_argument("--repeats", help="je Dreieck so viele Durchgänge, etwa 3,4 (Tiefe aus --depths, erster Wert)")
    p.add_argument("--row", type=int, choices=(1, 2), default=1,
                   help="Reihe im freien Streifen: 1 direkt unter den Teilen, 2 darunter")
    p.add_argument("--start-x", type=float,
                   help="linke Kante des ersten Dreiecks in mm ab der Marke (Standard 30); für einen "
                        "weiteren Test daneben etwa 100")
    p.add_argument("--dry-run", action="store_true", help="nichts senden, nur die Befehle zeigen")
    p.add_argument("--yes", action="store_true", help="ohne Rückfragen")
    p.set_defaults(func=cmd_test)

    p = sub.add_parser("gui", help="Fenster öffnen")
    p.add_argument("file", type=Path, nargs="?")
    p.set_defaults(func=cmd_gui)

    a = ap.parse_args(argv)
    try:
        return a.func(a)
    except (JobError, DeviceError) as e:
        print(f"Fehler: {e}", file=sys.stderr)
        return 2
    except KeyboardInterrupt:
        print("\nAbgebrochen.", file=sys.stderr)
        return 130
