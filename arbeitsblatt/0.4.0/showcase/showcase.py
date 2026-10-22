#!/usr/bin/env python3
"""Baut die Showcase-Seite (HTML mit eingebetteten Vorschaubildern).

    python3 showcase.py <render-ordner> <fach-ordner> <ausgabe.html>

<render-ordner> enthält T-blatt-1.png, T-blatt-2.png, T-lsg-1.png (render.sh),
<fach-ordner> die Kopf-Ausschnitte T-PH-07-1.png und T-IF-11-1.png.
"""
import base64, io, sys, html
from pathlib import Path
from PIL import Image

render, fach, ziel = map(Path, sys.argv[1:4])

def bild(pfad, breite=900, q=80):
    im = Image.open(pfad).convert("RGB")
    if im.width > breite:
        im = im.resize((breite, round(im.height * breite / im.width)), Image.LANCZOS)
    buf = io.BytesIO()
    im.save(buf, "JPEG", quality=q, optimize=True, progressive=True)
    return "data:image/jpeg;base64," + base64.b64encode(buf.getvalue()).decode()

THEMES = [
    ("klar", "Sparsam und modern",
     "Linien statt Flächen, viel Weißraum, quadratische Nummern. Die Weiterentwicklung der 5a-Übungsblätter und das tonerfreundlichste Theme.",
     "Avenir Next · Fira Math", "Alltag, alle Stufen, viel Kopieren"),
    ("atlas", "Farbig wie ein Schulbuch",
     "Titelkarte in der Fachfarbe, getönte Karten mit Reitern, runde Ecken. Myriad Pro wie bisher.",
     "Myriad Pro · Fira Math", "Einstiege, Wissensblätter, Farbdruck"),
    ("skizze", "Verspielt für die Unterstufe",
     "Handschrift-Überschriften, Titel auf Klebeband, Kürzel als schräger Zettel, gestrichelte Kästen, Merke als gelber Zettel und Namensfeld auf Seite 1.",
     "Playpen Sans · SF Pro Rounded", "Klasse 5–7, Stationen, Übungen"),
    ("labor", "Technisch für MINT",
     "Umrandete Titelleiste mit Messskala, Monospace-Marken A1, A2 …, Kästen wie Datenblätter.",
     "Fira Sans · Fira Code · Fira Math", "Informatik, Physik, Versuche"),
    ("kontur", "Plakativ in Schwarz",
     "Dicke schwarze Rahmen, harte versetzte Schatten in der Fachfarbe, Futura in Versalien. Bleibt auch als Schwarz-Weiß-Kopie kräftig.",
     "Futura · Helvetica Neue · Fira Math", "Oberstufe, Plakate, Überblicksblätter"),
    ("leiste", "Kennung am Rand",
     "Eine helle Leiste in der Fachfarbe an der Außenkante trägt Kürzel und Seitenzahl. Der Inhalt bleibt luftig, Nummern sind rund.",
     "Montserrat · Lato · Lato Math", "Skripte, längere Blätter, Mappen"),
    ("riso", "Wie im Zweifarbdruck",
     "Fachfarbe plus Pink, leicht versetzter Titel, Rasterpunkte und Rasterschatten, kräftige Slab-Schrift.",
     "Rockwell · PT Sans · Fira Math", "Einstiege, Projekte, Mittelstufe"),
    ("bauhaus", "Geometrisch",
     "Nummern wechseln zwischen Kreis, Quadrat und Dreieck, ein Signet aus allen drei Formen im Kopf, Kästen mit Viertelkreis in der Ecke.",
     "Gill Sans · Futura-Ziffern · Fira Math", "Mathematik, Geometrie, alle Stufen"),
]

karten = []
for name, motto, text, schrift, einsatz in THEMES:
    seiten = [
        (bild(render / f"{name}-blatt-1.png"), "Blatt, Seite 1"),
        (bild(render / f"{name}-blatt-2.png"), "Blatt, Seite 2"),
        (bild(render / f"{name}-lsg-1.png"), "Mit Lösungen"),
    ]
    faecher = [
        (bild(fach / f"{name}-PH-07-1.png", 700, 78), "PH-07"),
        (bild(fach / f"{name}-IF-11-1.png", 700, 78), "IF-11"),
    ]
    figs = "".join(
        f'<figure><button class="seite" type="button" aria-label="{name}: {cap} vergrößern">'
        f'<img src="{src}" alt="{name}: {cap}" loading="lazy"></button><figcaption>{cap}</figcaption></figure>'
        for src, cap in seiten)
    fachfigs = "".join(
        f'<figure><img src="{src}" alt="{name} mit Kürzel {k}" loading="lazy"><figcaption>{k}</figcaption></figure>'
        for src, k in faecher)
    karten.append(f'''
<section class="theme" id="{name}">
  <header class="theme-kopf">
    <div>
      <p class="motto">{html.escape(motto)}</p>
      <h2>{name}</h2>
    </div>
    <code class="aufruf">theme: "{name}"</code>
  </header>
  <div class="theme-text">
    <p>{html.escape(text)}</p>
    <dl><div><dt>Schrift</dt><dd>{schrift}</dd></div><div><dt>Passt zu</dt><dd>{einsatz}</dd></div></dl>
  </div>
  <div class="seiten">{figs}</div>
  <details class="faecher"><summary>Andere Fachfarben ansehen</summary><div class="fach-bilder">{fachfigs}</div></details>
</section>''')

nav = "".join(f'<a href="#{n}">{n}</a>' for n, *_ in THEMES)

seite = f'''<title>Arbeitsblatt-Themes</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Atkinson+Hyperlegible:ital,wght@0,400;0,700;1,400&family=Bricolage+Grotesque:opsz,wght@12..96,500;12..96,700&family=JetBrains+Mono:wght@500&display=swap">
<style>
/* Layout: schmale Textspalte oben, darunter je Theme eine Reihe aus drei Blattvorschauen wie ausgelegte Kopien. */
:root {{
  --papier: #eef1f5;
  --blatt: #ffffff;
  --tinte: #1d2433;
  --leise: #5b6577;
  --linie: #d5dbe5;
  --mathe: #2f6fb5;
  --lsg: #2b9348;
  --display: "Bricolage Grotesque", "Avenir Next", system-ui, sans-serif;
  --text: "Atkinson Hyperlegible", "Helvetica Neue", Arial, sans-serif;
  --mono: "JetBrains Mono", "SF Mono", Menlo, monospace;
}}
@media (prefers-color-scheme: dark) {{ :root:not([data-theme="light"]) {{
  --papier: #141922; --blatt: #1d2430; --tinte: #e7ebf2; --leise: #9aa4b5; --linie: #2e3746; --mathe: #6fa3e0; --lsg: #5cc17c; color-scheme: dark; }} }}
:root[data-theme="dark"] {{
  --papier: #141922; --blatt: #1d2430; --tinte: #e7ebf2; --leise: #9aa4b5; --linie: #2e3746; --mathe: #6fa3e0; --lsg: #5cc17c; color-scheme: dark; }}
* {{ box-sizing: border-box; }}
body {{ background: var(--papier); color: var(--tinte); font: 400 1rem/1.55 var(--text); }}
.wrap {{ max-width: 76rem; margin: 0 auto; padding-inline: max(16px, 3vw); padding-block: 2.5rem 4rem; display: grid; gap: 3rem; }}
.intro {{ display: grid; gap: 1.25rem; max-width: 46rem; }}
.kicker {{ font: 700 .75rem/1 var(--text); letter-spacing: .14em; text-transform: uppercase; color: var(--mathe); margin: 0; }}
h1 {{ font: 700 clamp(2rem, 5vw, 3.2rem)/1.05 var(--display); margin: 0; text-wrap: balance; display: flex; flex-wrap: wrap; gap: .4em .6em; align-items: center; }}
.kachel {{ font: 700 .9rem/1 var(--text); background: var(--mathe); color: #fff; padding: .45em .6em; border-radius: 3px; }}
.intro p {{ margin: 0; max-width: 65ch; }}
.dna {{ display: grid; gap: .6rem; padding: 1.1rem 1.25rem; background: var(--blatt); border: 1px solid var(--linie); border-radius: 6px; }}
.dna h2 {{ font: 700 1rem/1.2 var(--display); margin: 0; }}
.dna ul {{ margin: 0; padding-left: 1.1rem; display: grid; gap: .3rem; }}
.werkzeug {{ display: flex; flex-wrap: wrap; gap: .75rem 1.5rem; align-items: center; position: sticky; top: env(safe-area-inset-top, 0px); z-index: 2; background: var(--papier); padding-block: .75rem; border-bottom: 1px solid var(--linie); }}
.werkzeug nav {{ display: flex; flex-wrap: wrap; gap: .4rem; }}
.werkzeug a {{ font: 500 .85rem/1 var(--mono); color: var(--tinte); text-decoration: none; padding: .45rem .7rem; border: 1px solid var(--linie); border-radius: 999px; background: var(--blatt); }}
.werkzeug a:hover, .werkzeug a:focus-visible {{ border-color: var(--mathe); color: var(--mathe); outline: none; }}
.schalter {{ display: inline-flex; gap: .5rem; align-items: center; font-size: .9rem; cursor: pointer; margin-left: auto; }}
.schalter input {{ width: 1.1rem; height: 1.1rem; accent-color: var(--mathe); }}
body.kopie .seiten img, body.kopie .fach-bilder img {{ filter: grayscale(1) contrast(1.15); }}
.theme {{ display: grid; gap: 1.1rem; scroll-margin-top: 5rem; }}
.theme-kopf {{ display: flex; flex-wrap: wrap; justify-content: space-between; align-items: end; gap: .75rem; border-bottom: 2px solid var(--tinte); padding-bottom: .6rem; }}
.motto {{ margin: 0; color: var(--leise); font-size: .9rem; }}
.theme h2 {{ font: 700 2rem/1 var(--display); margin: .15rem 0 0; }}
.aufruf {{ font: 500 .9rem/1 var(--mono); background: var(--blatt); border: 1px solid var(--linie); padding: .5rem .7rem; border-radius: 4px; }}
.theme-text {{ display: grid; grid-template-columns: minmax(0, 1.4fr) minmax(0, 1fr); gap: 1rem 2rem; }}
.theme-text p {{ margin: 0; max-width: 62ch; }}
.theme-text dl {{ margin: 0; display: grid; gap: .4rem; font-size: .92rem; }}
.theme-text dl div {{ display: grid; grid-template-columns: 5.5rem 1fr; gap: .5rem; }}
dt {{ color: var(--leise); }} dd {{ margin: 0; }}
.seiten {{ display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 1rem; }}
figure {{ margin: 0; display: grid; gap: .4rem; }}
figcaption {{ font-size: .8rem; color: var(--leise); }}
.seite {{ padding: 0; border: 0; background: none; cursor: zoom-in; display: block; }}
.seite img {{ display: block; width: 100%; height: auto; background: #fff; box-shadow: 0 1px 2px rgba(20,30,50,.18), 0 8px 24px -12px rgba(20,30,50,.35); border-radius: 2px; transition: transform .15s ease; }}
.seite:hover img, .seite:focus-visible img {{ transform: translateY(-3px); }}
.seite:focus-visible {{ outline: 2px solid var(--mathe); outline-offset: 4px; }}
.faecher summary {{ cursor: pointer; font-size: .9rem; color: var(--mathe); }}
.fach-bilder {{ display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 1rem; margin-top: .75rem; }}
.fach-bilder img {{ background: #fff; border: 1px solid var(--linie); border-radius: 2px; }}
.befehle {{ display: grid; gap: .9rem; max-width: 52rem; }}
.befehle h2 {{ font: 700 1.5rem/1.1 var(--display); margin: 0; }}
.befehle p {{ margin: 0; max-width: 65ch; }}
pre {{ margin: 0; overflow-x: auto; background: var(--blatt); border: 1px solid var(--linie); border-radius: 6px; padding: 1rem 1.2rem; font: 500 .85rem/1.6 var(--mono); }}
.lupe {{ position: fixed; inset: 0; background: rgba(10,14,22,.86); display: grid; place-items: center; padding: max(16px, 3vw); z-index: 10; cursor: zoom-out; }}
.lupe img {{ max-height: 100%; max-width: min(100%, 60rem); width: auto; background: #fff; }}
@media (max-width: 760px) {{
  .seiten {{ grid-template-columns: repeat(3, minmax(9rem, 1fr)); overflow-x: auto; padding-bottom: .5rem; }}
  .theme-text {{ grid-template-columns: 1fr; }}
  .fach-bilder {{ grid-template-columns: 1fr; }}
  .schalter {{ margin-left: 0; }}
}}
@media (prefers-reduced-motion: reduce) {{ .seite img {{ transition: none; }} }}
</style>
<div class="wrap">
  <header class="intro">
    <p class="kicker">@schule/arbeitsblatt 0.4.0</p>
    <h1>Acht Themes, ein Blatt <span class="kachel">MA-05</span></h1>
    <p>Dasselbe Übungsblatt „Größen umrechnen“ in allen acht Themes. Der Quelltext ist jedes Mal identisch, nur eine Zeile in <code>arbeitsblatt.with(…)</code> ändert sich. Die Vorschauen zeigen Seite 1 und 2 der Schülerfassung und die erste Seite mit Lösungen.</p>
    <div class="dna">
      <h2>Daran erkennt man in jedem Theme deine Blätter</h2>
      <ul>
        <li>Die Fachfarbe wird aus dem Kürzel abgeleitet: MA blau, PH orange, IF grün, CH violett, BI grün, DE rot, EN magenta.</li>
        <li>Über dem Titel steht die Zeile „Mathematik · Klasse 5“, ebenfalls aus dem Kürzel.</li>
        <li>Kürzel oben rechts, Seitenzahl unten außen und Aufgabennummer sind immer gefüllte Marken in der Fachfarbe.</li>
        <li>Lösungen sind immer grün. Aufgaben ohne Titel bekommen die Nummer neben die erste Zeile.</li>
      </ul>
    </div>
  </header>

  <div class="werkzeug">
    <nav aria-label="Themes">{nav}</nav>
    <label class="schalter" for="kopie"><input type="checkbox" id="kopie"> Als Schwarz-Weiß-Kopie ansehen</label>
  </div>

  {"".join(karten)}

  <section class="befehle">
    <h2>Benutzung</h2>
    <p>Alle Befehle bleiben gleich: <code>aufgabe</code>, Teilaufgaben mit <code>+</code>, <code>loesung</code>, <code>teilaufgaben</code>, <code>workspace</code>, <code>info</code>, <code>tip</code>, <code>memo</code>, <code>warning</code> und alle anderen. Ohne <code>theme</code> sieht ein Blatt genau so aus wie bisher.</p>
<pre>#import "@schule/arbeitsblatt:0.4.0": *

#show: arbeitsblatt.with(
  title: "Größen umrechnen",
  class: "MA-05",
  print: true,
  theme: "klar",      // klar | atlas | skizze | labor | kontur | leiste | riso | bauhaus
  // akzent: rgb("#8b3fa3"),   // optional: eigene Farbe statt Fachfarbe
)</pre>
    <p>Explizit gesetzte Schriftparameter (<code>font</code>, <code>font-size</code> …) haben Vorrang vor dem Theme. Mit Theme werden kurze Aufgaben unter 9 cm nicht über den Seitenwechsel gerissen.</p>
  </section>
</div>
<script>
(function () {{
  var box = document.getElementById("kopie");
  try {{ box.checked = localStorage.getItem("kopie") === "1"; }} catch (e) {{}}
  function setzen() {{ document.body.classList.toggle("kopie", box.checked); try {{ localStorage.setItem("kopie", box.checked ? "1" : "0"); }} catch (e) {{}} }}
  box.addEventListener("change", setzen); setzen();
  document.querySelectorAll(".seite").forEach(function (b) {{
    b.addEventListener("click", function () {{
      var l = document.createElement("div"); l.className = "lupe"; l.setAttribute("role", "dialog"); l.tabIndex = -1;
      var i = b.querySelector("img").cloneNode(); if (document.body.classList.contains("kopie")) i.style.filter = "grayscale(1) contrast(1.15)";
      l.appendChild(i); document.body.appendChild(l); l.focus();
      function zu() {{ l.remove(); b.focus(); }}
      l.addEventListener("click", zu); l.addEventListener("keydown", function (e) {{ if (e.key === "Escape") zu(); }});
    }});
  }});
}})();
</script>
'''
ziel.write_text(seite, encoding="utf-8")
print(ziel, round(len(seite) / 1e6, 2), "MB")
