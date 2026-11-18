"""Tests ohne Gerät: python -m unittest discover tests"""

import tempfile
import unittest
from pathlib import Path

from cutter.device import RecordingTransport, Plotter, Settings
from cutter.geometry import _inside, outline, plan, segments, stats
from cutter.job import Marks, load_svg


class Geometry(unittest.TestCase):
    def test_shared_edges_once(self):
        a = [(0, 0), (10, 0), (5, 8.66), (0, 0)]
        b = [(10, 0), (15, 8.66), (5, 8.66), (10, 0)]  # teilt eine Kante mit a
        self.assertEqual(len(segments([a, b])), 5)
        lines = plan([a, b])
        self.assertAlmostEqual(stats(lines).cut_mm, 50, delta=0.01)

    def test_collinear_merged(self):
        lines = plan([[(0, 0), (10, 0)], [(10, 0), (20, 0)]])
        self.assertEqual(lines, [[(0, 0), (20, 0)]])


    def test_sharp_corner_split_and_overcut(self):
        tri = [(0, 0), (60, 0), (30, 51.96), (0, 0)]
        lines = plan([tri], corner=30)
        self.assertEqual(len(lines), 3)  # an jeder Ecke neu ansetzen
        over = plan([tri], corner=30, overcut=1.0, pieces=[tri[:3]])
        self.assertAlmostEqual(stats(over).cut_mm, stats(lines).cut_mm + 6, delta=0.01)

    def test_no_overcut_into_neighbour(self):
        a = [(0, 0), (60, 0), (30, 51.96)]
        b = [(60, 0), (90, 51.96), (30, 51.96)]  # Nachbar teilt die Kante (60,0)–(30,51.96)
        lines = plan([a + [a[0]], b + [b[0]]], corner=30, overcut=1.0, pieces=[a, b])
        # Unterkante von a: am rechten Ende liegt die Verlängerung frei (Abfall)
        # Gemeinsame Kante: oben links Verlängerung im Abfall, unten rechts auch
        for line in lines:
            for p in (line[0], line[-1]):
                inside = any(_inside(p, poly) for poly in (a, b))
                self.assertFalse(inside, f"Überschnitt in ein Teil bei {p}")


    def test_rows_first(self):
        lines = plan([[(0, 10), (50, 10)], [(0, 0), (50, 0)], [(0, 0), (5, 10)]], corner=30)
        self.assertTrue(all(abs(l[0][1] - l[-1][1]) < 0.01 for l in lines[:2]))
        self.assertEqual(lines[0][0][1], 0)  # oben zuerst


    def test_outline(self):
        a = [(0, 0), (60, 0), (30, 51.96)]
        b = [(60, 0), (90, 51.96), (30, 51.96)]
        (ring,) = outline([a, b])
        self.assertEqual(len(ring), 5)  # Raute: vier Ecken, geschlossen
        self.assertAlmostEqual(stats([ring]).cut_mm, 240, delta=0.1)


class Device(unittest.TestCase):
    def test_dry_run_commands(self):
        t = RecordingTransport()
        p = Plotter(t, log=lambda m: None)
        p.run([[(0, 0), (10, 5)]], Settings(speed=5, force=27, depth=4), Marks(), (210, 297))
        text = t.text()
        self.assertIn("TB123,5540,3800,0,0", text)
        self.assertIn("M0,0\nD100,200", text)  # y vor x, 20 Einheiten je mm
        self.assertIn("FX27,1", text)
        self.assertNotIn("FY0", text)
        self.assertIn("FY1", text)

    def test_mark_search(self):
        t = RecordingTransport()
        Plotter(t, log=lambda m: None).run([[(0, 0), (10, 5)]], Settings(mark_search=4), Marks(), (210, 297))
        self.assertIn("TB123,5540,3800,120,120", t.text())

    def test_mark_at(self):
        t = RecordingTransport()
        Plotter(t, log=lambda m: None).run([[(0, 0), (10, 5)]], Settings(mark_search=4, mark_at=(20, 20)),
                                           Marks(), (210, 297))
        self.assertIn("TB123,5540,3800,320,320", t.text())

    def test_track_enhancing(self):
        t = RecordingTransport()
        Plotter(t, log=lambda m: None).run([[(0, 0), (10, 5)]], Settings(track_enhancing=True), Marks(), (210, 297))
        self.assertIn("FY0", t.text())

    def test_trace_then_decline(self):
        t = RecordingTransport()
        asked = []
        went = Plotter(t, log=lambda m: None).run(
            [[(0, 0), (10, 5)]], Settings(), Marks(), (210, 297), trace=True,
            check=(180, 267), decide=lambda q: asked.append(q) or False)
        self.assertFalse(went)
        self.assertEqual(len(asked), 1)
        self.assertNotIn("\nD", t.text())
        self.assertIn("M5340,3600", t.text())  # Prüfkreuz angefahren

    def test_check_then_cut(self):
        t = RecordingTransport()
        went = Plotter(t, log=lambda m: None).run(
            [[(0, 0), (10, 5)]], Settings(), Marks(), (210, 297), check=(180, 267), decide=lambda q: True)
        self.assertTrue(went)
        self.assertIn("D100,200", t.text())


class Svg(unittest.TestCase):
    def test_color_filter(self):
        svg = ('<svg xmlns="http://www.w3.org/2000/svg" width="210mm" height="297mm" viewBox="0 0 210 297">'
               '<line x1="20" y1="20" x2="50" y2="20" stroke="#ff0000"/>'
               '<line x1="20" y1="40" x2="50" y2="40" stroke="#000000"/></svg>')
        with tempfile.TemporaryDirectory() as d:
            f = Path(d) / "a.svg"
            f.write_text(svg)
            (sheet,) = load_svg(f, ["#ff0000"], mark_inset=10)
        self.assertEqual(len(sheet.paths), 1)
        (x0, y0), (x1, y1) = sheet.paths[0]
        self.assertAlmostEqual(x0, 10, places=3)
        self.assertAlmostEqual(y0, 10, places=3)
        self.assertAlmostEqual(x1, 40, places=3)


if __name__ == "__main__":
    unittest.main()
