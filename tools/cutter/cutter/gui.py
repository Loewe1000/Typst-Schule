"""Ein schlichtes Fenster (tkinter): Datei wählen, Bogen ansehen, Plotter
prüfen, abfahren, schneiden. Jede Aktion am Gerät fragt vorher nach."""

from __future__ import annotations

import queue
import tempfile
import threading
import tkinter as tk
from dataclasses import replace
from pathlib import Path
from tkinter import filedialog, messagebox, ttk

from .device import MATERIALS, MATS, DeviceError, list_plotters, open_plotter
from .geometry import plan_sheet, stats
from .job import JobError, Sheet, load, render_page_png, svg_colors


class App:
    def __init__(self, root: tk.Tk, file: Path | None):
        self.root = root
        root.title("cutter – Silhouette")
        self.file: Path | None = None
        self.sheets: list[Sheet] = []
        self.lines = []
        self.busy = False
        self.events: queue.Queue = queue.Queue()
        self._bg = None

        top = ttk.Frame(root, padding=8)
        top.pack(fill="x")
        ttk.Button(top, text="Datei öffnen …", command=self.choose).pack(side="left")
        self.file_label = ttk.Label(top, text="keine Datei")
        self.file_label.pack(side="left", padx=8)

        opts = ttk.Frame(root, padding=(8, 0))
        opts.pack(fill="x")
        ttk.Label(opts, text="Bogen").pack(side="left")
        self.sheet_var = tk.StringVar()
        self.sheet_box = ttk.Combobox(opts, textvariable=self.sheet_var, width=14, state="readonly")
        self.sheet_box.pack(side="left", padx=(4, 12))
        self.sheet_box.bind("<<ComboboxSelected>>", lambda e: self.show())
        ttk.Label(opts, text="SVG-Farben").pack(side="left")
        self.color_var = tk.StringVar(value="#ff0000")
        e = ttk.Entry(opts, textvariable=self.color_var, width=18)
        e.pack(side="left", padx=(4, 4))
        e.bind("<Return>", lambda ev: self.reload())
        self.marks_var = tk.BooleanVar(value=True)
        ttk.Checkbutton(opts, text="Passermarken (10 mm)", variable=self.marks_var,
                        command=self.reload).pack(side="left", padx=8)

        st = ttk.Frame(root, padding=8)
        st.pack(fill="x")
        ttk.Label(st, text="Material").pack(side="left")
        self.material = tk.StringVar(value="karton")
        mb = ttk.Combobox(st, textvariable=self.material, values=sorted(MATERIALS), width=10, state="readonly")
        mb.pack(side="left", padx=(4, 12))
        mb.bind("<<ComboboxSelected>>", lambda e: self.apply_material())
        self.speed, self.force, self.depth, self.passes = (tk.IntVar() for _ in range(4))
        for label, var, hi in (("Tempo", self.speed, 30), ("Druck", self.force, 33),
                               ("Tiefe", self.depth, 10), ("Durchgänge", self.passes, 5)):
            ttk.Label(st, text=label).pack(side="left")
            ttk.Spinbox(st, from_=0 if label == "Tiefe" else 1, to=hi, textvariable=var, width=4).pack(
                side="left", padx=(4, 12))
        ttk.Label(st, text="Matte").pack(side="left")
        self.mat = tk.StringVar(value="cameo-12x12")
        ttk.Combobox(st, textvariable=self.mat, values=sorted(MATS), width=13, state="readonly").pack(
            side="left", padx=4)
        self.apply_material()

        self.canvas = tk.Canvas(root, width=420, height=594, bg="#eee", highlightthickness=0)
        self.canvas.pack(padx=8, pady=4)
        self.summary = ttk.Label(root, text="", padding=(8, 0))
        self.summary.pack(fill="x")

        btn = ttk.Frame(root, padding=8)
        btn.pack(fill="x")
        ttk.Button(btn, text="Plotter prüfen", command=self.check).pack(side="left")
        ttk.Button(btn, text="Abfahren, dann schneiden", command=lambda: self.go(trace=True)).pack(side="left", padx=6)
        ttk.Button(btn, text="Schneiden", command=lambda: self.go(trace=False)).pack(side="left")
        self.progress = ttk.Progressbar(btn, length=160, maximum=1.0)
        self.progress.pack(side="right")

        self.log_box = tk.Text(root, height=7, width=70, state="disabled", font=("Menlo", 11))
        self.log_box.pack(fill="both", expand=True, padx=8, pady=(0, 8))

        root.after(100, self.poll)
        if file:
            self.open(Path(file))

    # Hilfen ---------------------------------------------------------------

    def log(self, msg: str) -> None:
        self.events.put(("log", msg))

    def poll(self) -> None:
        while not self.events.empty():
            kind, val = self.events.get()
            if kind == "log":
                self.log_box.configure(state="normal")
                self.log_box.insert("end", val + "\n")
                self.log_box.see("end")
                self.log_box.configure(state="disabled")
            elif kind == "progress":
                self.progress["value"] = val
            elif kind == "ask":
                question, box = val
                box["answer"] = messagebox.askyesno("Weiter?", question)
                box["event"].set()
            elif kind == "done":
                self.busy = False
        self.root.after(100, self.poll)

    def apply_material(self) -> None:
        s = MATERIALS[self.material.get()]
        self.speed.set(s.speed)
        self.force.set(s.force)
        self.depth.set(s.depth or 0)
        self.passes.set(s.passes)

    def settings(self):
        s = replace(MATERIALS[self.material.get()])
        s.speed, s.force, s.depth, s.passes = self.speed.get(), self.force.get(), self.depth.get(), self.passes.get()
        s.mat = self.mat.get()
        return s

    # Datei ----------------------------------------------------------------

    def choose(self) -> None:
        f = filedialog.askopenfilename(filetypes=[("Schnittdaten", "*.typ *.json *.svg"), ("Alle", "*")])
        if f:
            self.open(Path(f))

    def open(self, f: Path) -> None:
        self.file = f
        self.file_label.configure(text=str(f))
        if f.suffix.lower() == ".svg":
            try:
                found = svg_colors(f)
                self.log("Strichfarben in der SVG: " + ", ".join(f"{c} ({n}×)" for c, n in found.items()))
            except Exception as e:
                self.log(f"SVG nicht lesbar: {e}")
        self.reload()

    def reload(self) -> None:
        if not self.file:
            return
        try:
            colors = [c.strip() for c in self.color_var.get().split(",") if c.strip()]
            self.sheets = load(self.file, colors=colors, mark_inset=10.0 if self.marks_var.get() else None)
        except JobError as e:
            self.sheets = []
            messagebox.showerror("cutter", str(e))
            return
        names = [f"Seite {s.page}" if s.page else f"Bogen {i + 1}" for i, s in enumerate(self.sheets)]
        self.sheet_box.configure(values=names)
        self.sheet_box.current(0)
        self.show()

    def current(self) -> Sheet | None:
        if not self.sheets:
            return None
        return self.sheets[max(self.sheet_box.current(), 0)]

    def show(self) -> None:
        sheet = self.current()
        c = self.canvas
        c.delete("all")
        if not sheet:
            return
        w, h = sheet.page_size
        k = min(420 / w, 594 / h)
        c.configure(width=w * k, height=h * k)
        c.create_rectangle(0, 0, w * k, h * k, fill="white", outline="#999")
        self._bg = None
        if self.file and self.file.suffix.lower() == ".typ" and sheet.page:
            try:
                png = Path(tempfile.gettempdir()) / f"cutter-vorschau-{sheet.page}.png"
                render_page_png(self.file, sheet.page, png, ppi=int(k * 25.4))
                self._bg = tk.PhotoImage(file=str(png))
                c.create_image(0, 0, image=self._bg, anchor="nw")
            except Exception as e:
                self.log(f"Seitenbild nicht verfügbar: {e}")
        m = sheet.marks
        if m:
            r, b = m.left + m.width, m.top + m.length
            c.create_rectangle(m.left * k, m.top * k, (m.left + m.square) * k, (m.top + m.square) * k, fill="black")
            c.create_line((r - m.line) * k, m.top * k, r * k, m.top * k, r * k, (m.top + m.line) * k, width=2)
            c.create_line(m.left * k, (b - m.line) * k, m.left * k, b * k, (m.left + m.line) * k, b * k, width=2)
        self.lines = plan_sheet(sheet)
        dx, dy = (m.left, m.top) if m else (0, 0)
        n = len(self.lines)
        for i, line in enumerate(self.lines):
            t = i / max(n - 1, 1)
            col = f"#{int(40 + 200 * t):02x}{int(90 - 40 * t):02x}{int(220 - 180 * t):02x}"
            c.create_line(*[v for x, y in line for v in ((x + dx) * k, (y + dy) * k)], fill=col, width=2)
        st = stats(self.lines)
        msg = f"{len(sheet.paths)} Strecken → {st.lines} Linienzüge, Schnitt {st.cut_mm / 10:.1f} cm"
        warn = sheet.warnings()
        self.summary.configure(text=msg + ("  ⚠ " + warn[0] if warn else ""))

    # Gerät ----------------------------------------------------------------

    def background(self, job) -> None:
        if self.busy:
            return
        self.busy = True

        def work():
            try:
                job()
            except (DeviceError, JobError) as e:
                self.log(f"Fehler: {e}")
            except Exception as e:  # USB-Fehler und Ähnliches
                self.log(f"Fehler: {type(e).__name__}: {e}")
            finally:
                self.events.put(("done", None))

        threading.Thread(target=work, daemon=True).start()

    def ask(self, question: str) -> bool:
        """Aus dem Arbeits-Thread: Frage im Fenster stellen und warten."""
        box = {"event": threading.Event(), "answer": False}
        self.events.put(("ask", (question, box)))
        box["event"].wait()
        return box["answer"]

    def check(self) -> None:
        if not messagebox.askyesno("Plotter prüfen", "Den Plotter suchen und Firmware, Status und "
                                   "Werkzeug abfragen? Dabei bewegt sich nichts."):
            return

        def job():
            found = list_plotters()
            if not found:
                self.log("Kein Silhouette-Plotter gefunden.")
                return
            p = open_plotter(dry_run=False, log=self.log)
            try:
                for key, v in p.info().items():
                    self.log(f"{key}: {v}")
            finally:
                p.t.close()

        self.background(job)

    def go(self, trace: bool) -> None:
        sheet = self.current()
        if not sheet:
            messagebox.showinfo("cutter", "Erst eine Datei mit Schnittdaten öffnen.")
            return
        s = self.settings()
        what = ("Passermarken suchen, die Linien mit angehobenem Messer abfahren und danach fragen, "
                "ob geschnitten wird" if trace else
                "Passermarken suchen und über das Prüfkreuz fahren; geschnitten wird erst nach Rückfrage")
        what += f" (Tempo {s.speed}, Druck {s.force}, Tiefe {s.depth}, Durchgänge {s.passes})"
        if not messagebox.askyesno("Plotter starten", f"Bogen eingelegt? Jetzt {what}?"):
            return
        lines = self.lines

        def job():
            p = open_plotter(dry_run=False, log=self.log)
            try:
                p.run(lines, s, sheet.marks, sheet.page_size, trace=trace,
                      check=sheet.check, decide=self.ask,
                      progress=lambda f: self.events.put(("progress", f)))
            finally:
                p.t.close()

        self.background(job)


def run(file: Path | None = None) -> None:
    root = tk.Tk()
    App(root, file)
    root.mainloop()
