"""Silhouette-Schneideplotter über USB (GPGL-Befehle).

Die Befehlsfolgen folgen dem, was das Projekt inkscape-silhouette
(https://github.com/fablabnbg/inkscape-silhouette) für Cameo 3/4 und Portrait
dokumentiert hat; der Code hier ist eine eigene, schlanke Umsetzung.

Koordinaten: Der Plotter misst in Silhouette-Einheiten (20 je mm). Ein
Befehl `M y,x` fährt, `D y,x` schneidet; y läuft in Vorschubrichtung (auf
dem Blatt nach unten), x quer dazu. Nach der Markensuche liegt (0, 0) in der
linken oberen Ecke der Passermarke.

Jede Ausgabe läuft über einen `Transport`. `RecordingTransport` schickt nichts
an ein Gerät, sondern schreibt mit – das ist der Trockenlauf. Er geht durch
genau denselben Code wie ein echter Schnitt.
"""

from __future__ import annotations

import time
from dataclasses import dataclass, field, replace
from typing import Callable

from .job import Marks, Polyline

ETX = b"\x03"
ESC = b"\x1b"
EOT = b"\x04"  # Gerät zurücksetzen
ENQ = b"\x05"  # Status abfragen
NAK = b"\x15"  # eingesetzte Werkzeuge abfragen (Cameo 4)

VENDOR_GRAPHTEC = 0x0B4D
MODELS = {
    0x1121: "Cameo",
    0x112B: "Cameo 2",
    0x112F: "Cameo 3",
    0x1137: "Cameo 4",
    0x1138: "Cameo 4 Plus",
    0x1139: "Cameo 4 Pro",
    0x1123: "Portrait",
    0x1132: "Portrait 2",
    0x113A: "Portrait 3",
}
CAMEO4 = {0x1137, 0x1138, 0x1139}
CAMEO3_ON = CAMEO4 | {0x112F}
TWO_TOOLS = CAMEO4 | {0x112F}

STATUS = {b"0": "bereit", b"1": "in Bewegung", b"2": "kein Material eingelegt"}
TOOLS = {"0": "leer", "1": "Ratchet-Messer", "2": "AutoBlade", "3": "Tiefschnittmesser",
         "4": "Kraft-Messer", "5": "Rotationsmesser", "7": "Stift", "255": "Fehler"}

# Schneidematten: (Code, Breite, Länge in Zoll)
MATS = {
    "none": ("0", None, None),
    "cameo-12x12": ("1", 12, 12),
    "cameo-12x24": ("2", 12, 24),
    "portrait-8x12": ("3", 8, 12),
}


def su(mm: float) -> int:
    """mm → Silhouette-Einheiten."""
    return int(round(mm * 20.0))


class DeviceError(Exception):
    pass


# ---------------------------------------------------------------------------
# Transport
# ---------------------------------------------------------------------------


class Transport:
    product_id: int | None = None
    name: str = ""

    def write(self, data: bytes, timeout: int = 10000) -> None:
        raise NotImplementedError

    def read(self, size: int = 64, timeout: int = 5000) -> bytes:
        raise NotImplementedError

    def close(self) -> None:
        pass


def _usb_backend():
    import usb.backend.libusb1 as libusb1

    paths = ["/opt/homebrew/lib/libusb-1.0.dylib", "/usr/local/lib/libusb-1.0.dylib"]

    def find(name):
        import ctypes.util
        import os

        hit = ctypes.util.find_library(name)
        if hit:
            return hit
        for p in paths:
            if os.path.exists(p):
                return p
        return None

    backend = libusb1.get_backend(find_library=find)
    if backend is None:
        raise DeviceError("libusb nicht gefunden – mit `brew install libusb` installieren")
    return backend


def list_plotters() -> list[tuple[int, str]]:
    import usb.core

    found = usb.core.find(find_all=True, idVendor=VENDOR_GRAPHTEC, backend=_usb_backend())
    return [(d.idProduct, MODELS.get(d.idProduct, f"Graphtec 0x{d.idProduct:04x}")) for d in found]


class UsbTransport(Transport):
    EP_OUT = 0x01
    EP_IN = 0x82

    def __init__(self):
        import usb.core
        import usb.util

        dev = usb.core.find(idVendor=VENDOR_GRAPHTEC, backend=_usb_backend())
        if dev is None:
            raise DeviceError("kein Silhouette-Plotter gefunden – USB-Kabel und Einschalter prüfen, "
                              "Silhouette Studio schließen")
        self.dev = dev
        self.product_id = dev.idProduct
        self.name = MODELS.get(dev.idProduct, f"Graphtec 0x{dev.idProduct:04x}")
        try:
            if dev.is_kernel_driver_active(0):
                dev.detach_kernel_driver(0)
        except (NotImplementedError, usb.core.USBError):
            pass
        try:
            dev.set_configuration()
        except usb.core.USBError:
            pass  # unter macOS oft schon gesetzt
        try:
            usb.util.claim_interface(dev, 0)
        except usb.core.USBError as e:
            raise DeviceError(f"Plotter belegt ({e}) – läuft Silhouette Studio noch?") from e

    def write(self, data: bytes, timeout: int = 10000) -> None:
        o = 0
        while o < len(data):
            n = self.dev.write(self.EP_OUT, data[o:o + 4096], timeout=timeout)
            if n <= 0:
                raise DeviceError("Schreiben zum Plotter fehlgeschlagen")
            o += n

    def read(self, size: int = 64, timeout: int = 5000) -> bytes:
        return bytes(self.dev.read(self.EP_IN, size, timeout=timeout))

    def close(self) -> None:
        import usb.util

        try:
            usb.util.release_interface(self.dev, 0)
            usb.util.dispose_resources(self.dev)
        except Exception:
            pass


class RecordingTransport(Transport):
    """Trockenlauf: schreibt mit, antwortet wie ein bereiter Cameo 4."""

    def __init__(self, product_id: int = 0x1137):
        self.product_id = product_id
        self.name = MODELS.get(product_id, "?") + " (Trockenlauf)"
        self.log: list[bytes] = []
        self._reply: bytes | None = None

    def write(self, data: bytes, timeout: int = 10000) -> None:
        self.log.append(data)
        if data == ESC + ENQ:
            self._reply = b"0" + ETX
        elif data == ESC + NAK:
            self._reply = b"2,0" + ETX
        elif data.startswith(b"FG"):
            self._reply = b"TROCKENLAUF" + ETX
        elif data.startswith((b"TB123,", b"TB23,")):
            self._reply = b"    0" + ETX
        elif data.startswith((b"TB71", b"FA")):
            self._reply = b"    0,    0" + ETX

    def read(self, size: int = 64, timeout: int = 5000) -> bytes:
        r, self._reply = self._reply, None
        if r is None:
            raise DeviceError("keine Antwort (Trockenlauf)")
        return r

    def text(self) -> str:
        """Mitschrift, ein Befehl je Zeile."""
        lines = []
        for chunk in self.log:
            if chunk.startswith(ESC):
                names = {ENQ: "Status?", EOT: "Reset", NAK: "Werkzeug?"}
                lines.append(f"ESC {names.get(chunk[1:2], chunk[1:].hex())}")
                continue
            lines += [c.decode() for c in chunk.split(ETX) if c]
        return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# Einstellungen
# ---------------------------------------------------------------------------


@dataclass
class Settings:
    speed: int = 5  # 1…30 (Cameo 4), 1…10 (ältere)
    force: int = 10  # 1…33
    depth: int | None = 2  # AutoBlade-Tiefe 0…10; None lässt sie unverändert
    toolholder: int = 1
    mat: str = "cameo-12x12"
    passes: int = 1
    blade_offset: float = 0.9  # mm; Ausgleich der nachlaufenden Messerspitze
    sharpen_corners: bool = True


MATERIALS = {
    # Startwerte – vor dem ersten echten Bogen einen Testschnitt machen.
    "papier": Settings(speed=5, force=10, depth=2),  # 80–120 g/m²
    "karton": Settings(speed=5, force=27, depth=4),  # 160–250 g/m²
    "fotopapier": Settings(speed=4, force=20, depth=3),
}


# ---------------------------------------------------------------------------
# Plotter
# ---------------------------------------------------------------------------


Log = Callable[[str], None]


class Plotter:
    def __init__(self, transport: Transport, log: Log = print):
        self.t = transport
        self.log = log

    @property
    def pid(self) -> int | None:
        return self.t.product_id

    # Grundbefehle --------------------------------------------------------

    def send(self, *cmds: str) -> None:
        self.t.write(b"".join(c.encode() + ETX for c in cmds))

    def query(self, cmd: str, timeout: int = 2000) -> str | None:
        self.send(cmd)
        try:
            r = self.t.read(timeout=timeout)
        except Exception:
            return None
        return r[:-1].decode(errors="replace") if r.endswith(ETX) else r.decode(errors="replace")

    def status(self) -> str:
        self.t.write(ESC + ENQ)
        r = self.t.read(timeout=5000)
        return STATUS.get(r[:-1], r[:-1].decode(errors="replace"))

    def tools(self) -> str:
        if self.pid not in CAMEO4:
            return "unbekannt"
        self.t.write(ESC + NAK)
        try:
            r = self.t.read(timeout=1000)[:-1].decode()
        except Exception:
            return "unbekannt"
        return ", ".join(f"Halter {i + 1}: {TOOLS.get(x.strip(), x)}" for i, x in enumerate(r.split(",")))

    def tool_code(self) -> int | None:
        if self.pid not in CAMEO4:
            return None
        self.t.write(ESC + NAK)
        try:
            return int(self.t.read(timeout=1000)[:-1].decode().split(",")[0])
        except Exception:
            return None

    def wait_ready(self, timeout: float = 120, poll: float = 0.25) -> None:
        end = time.monotonic() + timeout
        warned = False
        while True:
            s = self.status()
            if s == "bereit":
                return
            if s == "kein Material eingelegt" and not warned:
                self.log("Bitte die Matte mit dem Bogen einlegen (Taste „Laden“ am Plotter) …")
                warned = True
            if time.monotonic() > end:
                raise DeviceError(f"Plotter nicht bereit: {s}")
            time.sleep(poll)

    def send_paced(self, cmds: list[str], progress: Callable[[float], None] | None = None) -> None:
        """Lange Befehlsfolgen in Stücken bis 1 KiB, dazwischen warten."""
        data = b"".join(c.encode() + ETX for c in cmds)
        o = 0
        while o < len(data):
            chunk = data[o:o + 1024]
            chunk = chunk[: chunk.rfind(ETX) + 1]
            self.t.write(chunk)
            o += len(chunk)
            self.wait_ready(timeout=300, poll=0.05)
            if progress:
                progress(o / len(data))

    def trace_lines(self, lines: list[Polyline], frame: tuple[float, float] | None,
                    progress: Callable[[float], None] | None = None, pause: float = 0.15) -> None:
        """Linien mit angehobenem Messer abfahren.

        Die Firmware fasst aufeinanderfolgende Fahrbefehle zusammen und fährt
        gleich zum letzten Ziel. Darum je Eckpunkt einen Befehl schicken und
        den Stillstand abwarten. Gerade Linien haben nur Anfang und Ende, die
        Fahrt läuft also in einem Zug.
        """
        real = not isinstance(self.t, RecordingTransport)
        pts = [p for line in lines for p in line]
        done = 0
        for line in lines:
            for p in line:
                if frame:
                    p = (min(max(p[0], 0), frame[0]), min(max(p[1], 0), frame[1]))
                self.send(f"M{su(p[1])},{su(p[0])}")
                if real:
                    time.sleep(0.1)  # bis der Status auf „in Bewegung“ wechselt
                self.wait_ready(timeout=120, poll=0.05)
                done += 1
                if progress:
                    progress(done / len(pts))
            if real:
                time.sleep(pause)

    # Ablauf ---------------------------------------------------------------

    def initialize(self) -> str:
        self.t.write(ESC + EOT)
        version = self.query("FG", timeout=10000) or "?"
        if self.pid in CAMEO3_ON:
            self.query("TB71")
            self.query("FA")
        return version

    def setup(self, s: Settings, height_mm: float, width_mm: float) -> None:
        tool = s.toolholder
        mat = MATS.get(s.mat)
        if mat is None:
            raise DeviceError(f"unbekannte Matte {s.mat!r} – möglich: {', '.join(MATS)}")
        if self.pid in CAMEO3_ON:
            code, mw, ml = mat
            self.send("TG" + code, "FN0", "TB50,0")
            if mw:
                self.send("\\0,0", f"Z{round(ml * 508)},{round(mw * 508)}")
            else:
                self.send("\\0,0", f"Z{su(height_mm)},{su(width_mm)}")
        if self.pid in TWO_TOOLS:
            self.send(f"J{tool}")
        speed = max(1, min(30 if self.pid in CAMEO4 else 10, s.speed))
        force = max(1, min(33, s.force))
        corner = 1 if s.sharpen_corners else 0
        self.send(
            f"FX{force},{tool}", "TJ0", f"!{speed},{tool}", f"FC0,1,{tool}", f"FE0,{tool}",
            f"FF{corner},0,{tool}", f"FF{corner},{corner},{tool}",
            f"FX{force},{tool}", "TJ3", f"FC{su(s.blade_offset)},1,{tool}",
        )
        if s.depth is not None and self.pid in CAMEO3_ON:
            code = self.tool_code()
            if code in (None, 0, 2) and tool == 1:
                self.send(f"TF{max(0, min(10, s.depth))},{tool}")
            else:
                self.log(f"Werkzeug in Halter {tool} ist keine AutoBlade – Tiefe von Hand einstellen.")

    def find_marks(self, m: Marks) -> None:
        """Passermarken suchen; danach liegt (0, 0) an der Marke links oben."""
        self.send("TB50,0", "TB99", "TB52,2", "TB51,400", "TB53,10", "TB55,1")
        self.send(f"TB123,{su(m.length)},{su(m.width)},{su(max(m.top - 10, 0))},{su(max(m.left - 10, 0))}")
        try:
            r = self.t.read(timeout=40000)
        except Exception as e:
            raise DeviceError(f"Passermarken nicht gefunden (keine Antwort: {e})") from e
        if r != b"    0" + ETX:
            raise DeviceError(f"Passermarken nicht gefunden (Antwort {r!r}) – Lage auf der Matte, "
                              "Druck in Originalgröße und Licht prüfen")

    def path_commands(self, lines: list[Polyline], frame: tuple[float, float] | None, move_only=False) -> list[str]:
        cmds = []
        for line in lines:
            pts = line
            if frame:
                w, h = frame
                pts = [(min(max(x, 0), w), min(max(y, 0), h)) for x, y in line]
            x, y = pts[0]
            cmds.append(f"M{su(y)},{su(x)}")
            for x, y in pts[1:]:
                cmds.append(f"{'M' if move_only else 'D'}{su(y)},{su(x)}")
        return cmds

    def home(self) -> None:
        if self.pid in CAMEO3_ON:
            self.send("L0", "\\0,0", "M0,0", "J0", "FN0", "TB50,0")
        else:
            self.send("H")

    def move_to(self, p: tuple[float, float]) -> None:
        self.send(f"M{su(p[1])},{su(p[0])}")
        if not isinstance(self.t, RecordingTransport):
            time.sleep(0.15)
        self.wait_ready(timeout=120, poll=0.05)

    def run(self, lines: list[Polyline], settings: Settings, marks: Marks | None,
            page_size: tuple[float, float], trace: bool = False,
            check: tuple[float, float] | None = None,
            decide: Callable[[str], bool] | None = None,
            progress: Callable[[float], None] | None = None) -> bool:
        """Ganzer Auftrag: Gerät vorbereiten, Marken suchen, schneiden.

        `trace=True` fährt die Linien vorher mit angehobenem Messer ab.
        `check`: Prüfkreuz; der Kopf fährt nach der Markensuche (und dem
        Abfahren) darüber. `decide(frage)` entscheidet danach, ob geschnitten
        wird; ohne `decide` wird geschnitten. Liefert, ob geschnitten wurde.
        """
        version = self.initialize()
        self.log(f"{self.t.name}, Firmware {version}")
        self.wait_ready()
        w, h = page_size
        self.setup(settings, h, w)
        frame = None
        if marks:
            self.log("Suche Passermarken …")
            self.find_marks(marks)
            self.log("Passermarken gefunden.")
            frame = (marks.width, marks.length)
        if trace:
            # Langsam, damit man mitsehen kann. Die Firmware fasst
            # aufeinanderfolgende Fahrbefehle zusammen und fährt gleich zum
            # letzten Ziel; darum jeden Punkt einzeln schicken, Stillstand
            # abwarten und kurz verharren.
            self.send(f"!2,{settings.toolholder}")
            self.log("Fahre die Linien ab (ohne Schnitt) …")
            self.trace_lines(lines, frame, progress)
            self.send(f"!{settings.speed},{settings.toolholder}")
        question = None
        if check:
            self.move_to(check)
            question = "Der Kopf steht über dem Prüfkreuz. Steht die Messerspitze genau auf der Mitte? Jetzt schneiden?"
        elif trace:
            question = "Abfahren fertig. Jetzt schneiden?"
        go = True
        if question and decide is not None:
            go = decide(question)
        if go:
            cmds = self.path_commands(lines, frame)
            if settings.passes > 1:
                cmds = cmds * settings.passes
            self.log("Schneide …")
            self.send_paced(cmds, progress)
        else:
            self.log("Abgebrochen, nichts geschnitten.")
        self.home()
        self.wait_ready(timeout=300)
        self.log("Fertig." if go else "Kopf zurück in der Ausgangslage.")
        return go

    def info(self) -> dict:
        version = self.initialize()
        return {"Modell": self.t.name, "Firmware": version, "Status": self.status(),
                "Werkzeuge": self.tools()}


def open_plotter(dry_run: bool, log: Log = print) -> Plotter:
    return Plotter(RecordingTransport() if dry_run else UsbTransport(), log=log)
