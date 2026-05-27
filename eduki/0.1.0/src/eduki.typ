// eduki.typ - Paket fuer Eduki Material-Boxen

#import "@preview/shadowed:0.2.0": shadowed

// ============================================================================
// HELPER: Text-Groesse automatisch an Container anpassen
// ============================================================================
#let fill-height-with-text(min: 0.3em, max: 5em, eps: 0.1em, it) = layout(size => {
  let fits(text-size, it) = {
    (
      measure(
        width: size.width,
        {
          set text(text-size)
          it
        },
      ).height
        <= size.height
    )
  }

  if not fits(min, it) { panic("Content doesn't fit even at minimum text size") }
  if fits(max, it) {
    set text(max)
    it
  }

  let (a, b) = (min, max)
  while b - a > eps {
    let new = 0.5 * (a + b)
    if fits(new, it) {
      a = new
    } else {
      b = new
    }
  }

  set text(a)
  it
})

// ============================================================================
// HELPER: Normalisiert verschiedene Eingabeformate zu einheitlichem Dictionary
// ============================================================================
#let parse-page-spec(spec) = {
  if type(spec) == str {
    (path: spec, page: 1)
  } else if type(spec) == bytes {
    (data: spec, page: 1)
  } else if type(spec) == array {
    let source = spec.at(0)
    let page = spec.at(1, default: 1)
    if type(source) == bytes {
      (data: source, page: page)
    } else {
      (path: source, page: page)
    }
  } else {
    spec
  }
}

#let resolve-path(path, base-path: none) = {
  if base-path == none or path.starts-with("/") {
    path
  } else if base-path.ends-with("/") {
    base-path + path
  } else {
    base-path + "/" + path
  }
}

#let resolve-page-spec(spec, base-path: none) = {
  let parsed = parse-page-spec(spec)
  if "path" in parsed.keys() {
    parsed + (path: resolve-path(parsed.path, base-path: base-path),)
  } else {
    parsed
  }
}

// ============================================================================
// HELPER: Ermittelt Seitenverhaeltnis und Dimensionen eines Bildes
// ============================================================================
#let get-page-info(spec) = {
  let parsed = parse-page-spec(spec)
  let img = if "data" in parsed.keys() {
    image(parsed.data, page: parsed.page)
  } else {
    image(parsed.path, page: parsed.page)
  }
  let size = measure(img)
  let aspect = size.width / size.height
  (
    spec: parsed,
    natural-size: size,
    aspect: aspect,
    is-landscape: aspect > 1.05,
    is-wide: aspect > 1.5,
    is-portrait: aspect <= 1.05,
  )
}

// ============================================================================
// Rendert ein einzelnes Bild mit Schatten, automatisch skaliert
// ============================================================================
#let page-shadow-image(spec, scale: 0.66, radius: 5pt) = {
  let parsed = parse-page-spec(spec)
  let img = if "data" in parsed.keys() {
    image(parsed.data, page: parsed.page)
  } else {
    image(parsed.path, page: parsed.page)
  }

  context {
    let natural-size = measure(img)
    let aspect = natural-size.width / natural-size.height

    // Basis-Referenz: A4-Hoehe (29.7cm) als 100%
    // Die Groesse wird nur durch scale bestimmt, Seitenverhaeltnis bleibt erhalten
    let reference-height = 29.7cm
    let target-height = reference-height * scale
    let target-width = target-height * aspect

    shadowed(
      radius: radius,
      inset: 0pt,
      shadow: 10mm,
      color: gray.transparentize(50%),
      box(
        width: target-width,
        height: target-height,
        radius: radius,
        clip: true,
        fill: white,
        if "data" in parsed.keys() {
          image(parsed.data, page: parsed.page, width: 100%, height: 100%)
        } else {
          image(parsed.path, page: parsed.page, width: 100%, height: 100%)
        },
      ),
    )
  }
}

// ============================================================================
// KONKRETE LAYOUTS FUER VERSCHIEDENE SEITENKOMBINATIONEN
// ============================================================================

#let layout-1P(pages) = {
  place(top + center, dx: 5mm, dy: 0cm,
    rotate(4deg, page-shadow-image(pages.at(0), scale: 75%)))
}

#let layout-1L(pages) = {
  place(top + center, dx: 0cm, dy: 1cm,
    rotate(2deg, page-shadow-image(pages.at(0), scale: 38%)))
}

#let layout-1L-stacked(pages) = {
  place(top + center, dx: 0cm, dy: 3cm,
    rotate(2deg, page-shadow-image(pages.at(0), scale: 55%)))
}

#let layout-2P(pages) = {
  place(top + center, dx: 1cm, dy: 0cm,
    rotate(6deg, page-shadow-image(pages.at(1), scale: 68%)))
  place(top + center, dx: -2.5cm, dy: 4cm,
    rotate(-4deg, page-shadow-image(pages.at(0), scale: 58%)))
}

#let layout-2L(pages) = {
  place(top + center, dx: -0.5cm, dy: 1cm,
    rotate(3deg, page-shadow-image(pages.at(1), scale: 32%)))
  place(top + center, dx: 0.5cm, dy: 6cm,
    rotate(-3deg, page-shadow-image(pages.at(0), scale: 30%)))
}

#let layout-2L-stacked(pages) = {
  place(top + center, dx: 2cm, dy: 0cm,
    rotate(5deg, page-shadow-image(pages.at(1), scale: 52%)))
  place(top + center, dx: -1cm, dy: 5cm,
    rotate(-3deg, page-shadow-image(pages.at(0), scale: 50%)))
}

#let layout-1P-1L(pages, p-indices, l-indices) = {
  let p-idx = p-indices.at(0)
  let l-idx = l-indices.at(0)
  place(top + center, dx: 0cm, dy: 0cm,
    rotate(3deg, page-shadow-image(pages.at(p-idx), scale: 68%)))
  place(top + center, dx: 0.5cm, dy: 10cm,
    rotate(-2deg, page-shadow-image(pages.at(l-idx), scale: 32%)))
}

#let layout-3P(pages) = {
  place(top + center, dx: 2.5cm, dy: 0cm,
    rotate(10deg, page-shadow-image(pages.at(2), scale: 54%)))
  place(top + center, dx: -0.5cm, dy: 3.5cm,
    rotate(0deg, page-shadow-image(pages.at(1), scale: 51%)))
  place(top + center, dx: -3.5cm, dy: 7cm,
    rotate(-8deg, page-shadow-image(pages.at(0), scale: 48%)))
}

#let layout-3L(pages) = {
  place(top + center, dx: -0.5cm, dy: 0cm,
    rotate(-3deg, page-shadow-image(pages.at(2), scale: 32%)))
  place(top + center, dx: 0.5cm, dy: 4.5cm,
    rotate(2deg, page-shadow-image(pages.at(1), scale: 30%)))
  place(top + center, dx: -0.3cm, dy: 9.5cm,
    rotate(-2deg, page-shadow-image(pages.at(0), scale: 28%)))
}

#let layout-3L-stacked(pages) = {
  place(top + center, dx: 3cm, dy: -1cm,
    rotate(8deg, page-shadow-image(pages.at(2), scale: 48%)))
  place(top + center, dx: 0cm, dy: 3cm,
    rotate(0deg, page-shadow-image(pages.at(1), scale: 46%)))
  place(top + center, dx: -2cm, dy: 7cm,
    rotate(-5deg, page-shadow-image(pages.at(0), scale: 44%)))
}

#let layout-2P-1L(pages, p-indices, l-indices) = {
  let p0 = p-indices.at(0)
  let p1 = p-indices.at(1)
  let l0 = l-indices.at(0)
  place(top + center, dx: 2.5cm, dy: 0cm,
    rotate(6deg, page-shadow-image(pages.at(p1), scale: 62%)))
  place(top + center, dx: -2cm, dy: 2cm,
    rotate(-5deg, page-shadow-image(pages.at(p0), scale: 55%)))
  place(top + center, dx: 0cm, dy: 8cm,
    rotate(-2deg, page-shadow-image(pages.at(l0), scale: 32%)))
}

#let layout-1P-2L(pages, p-indices, l-indices) = {
  let p0 = p-indices.at(0)
  let l0 = l-indices.at(0)
  let l1 = l-indices.at(1)
  place(top + center, dx: 0cm, dy: 0cm,
    rotate(2deg, page-shadow-image(pages.at(p0), scale: 75%)))
  place(top + center, dx: -0.5cm, dy: 10cm,
    rotate(-3deg, page-shadow-image(pages.at(l1), scale: 28%)))
  place(top + center, dx: 0.5cm, dy: 13cm,
    rotate(2deg, page-shadow-image(pages.at(l0), scale: 26%)))
}

#let layout-4P(pages) = {
  place(top + center, dx: 4cm, dy: 0cm,
    rotate(14deg, page-shadow-image(pages.at(3), scale: 48%)))
  place(top + center, dx: 1cm, dy: 3.5cm,
    rotate(5deg, page-shadow-image(pages.at(2), scale: 46%)))
  place(top + center, dx: -2.5cm, dy: 7cm,
    rotate(-4deg, page-shadow-image(pages.at(1), scale: 44%)))
  place(top + center, dx: -5cm, dy: 10.5cm,
    rotate(-12deg, page-shadow-image(pages.at(0), scale: 42%)))
}

#let layout-4L(pages) = {
  place(top + center, dx: 1.5cm, dy: 0cm,
    rotate(4deg, page-shadow-image(pages.at(3), scale: 24%)))
  place(top + center, dx: -1.5cm, dy: 4cm,
    rotate(-3deg, page-shadow-image(pages.at(2), scale: 24%)))
  place(top + center, dx: 1cm, dy: 8cm,
    rotate(3deg, page-shadow-image(pages.at(1), scale: 24%)))
  place(top + center, dx: -1cm, dy: 12cm,
    rotate(-4deg, page-shadow-image(pages.at(0), scale: 24%)))
}

#let layout-4L-stacked(pages) = {
  place(top + center, dx: 4cm, dy: -2cm,
    rotate(10deg, page-shadow-image(pages.at(3), scale: 44%)))
  place(top + center, dx: 1cm, dy: 1cm,
    rotate(3deg, page-shadow-image(pages.at(2), scale: 42%)))
  place(top + center, dx: -1.5cm, dy: 4.5cm,
    rotate(-3deg, page-shadow-image(pages.at(1), scale: 40%)))
  place(top + center, dx: -3cm, dy: 8cm,
    rotate(-7deg, page-shadow-image(pages.at(0), scale: 38%)))
}

#let layout-3P-1L(pages, p-indices, l-indices) = {
  let l0 = l-indices.at(0)
  place(top + center, dx: 2cm, dy: 0cm,
    rotate(9deg, page-shadow-image(pages.at(p-indices.at(2)), scale: 52%)))
  place(top + center, dx: -1cm, dy: 3cm,
    rotate(0deg, page-shadow-image(pages.at(p-indices.at(1)), scale: 49%)))
  place(top + center, dx: -3.5cm, dy: 6cm,
    rotate(-7deg, page-shadow-image(pages.at(p-indices.at(0)), scale: 46%)))
  place(top + center, dx: -0.5cm, dy: 11cm,
    rotate(2deg, page-shadow-image(pages.at(l0), scale: 26%)))
}

#let layout-2P-2L(pages, p-indices, l-indices) = {
  place(top + center, dx: 1cm, dy: 0cm,
    rotate(5deg, page-shadow-image(pages.at(p-indices.at(1)), scale: 58%)))
  place(top + center, dx: -2.5cm, dy: 3.5cm,
    rotate(-4deg, page-shadow-image(pages.at(p-indices.at(0)), scale: 50%)))
  place(top + center, dx: -1.5cm, dy: 9cm,
    rotate(-3deg, page-shadow-image(pages.at(l-indices.at(1)), scale: 26%)))
  place(top + center, dx: -0.5cm, dy: 11.5cm,
    rotate(2deg, page-shadow-image(pages.at(l-indices.at(0)), scale: 24%)))
}

#let layout-1P-3L(pages, p-indices, l-indices) = {
  let p0 = p-indices.at(0)
  place(top + center, dx: 0cm, dy: 0cm,
    rotate(2deg, page-shadow-image(pages.at(p0), scale: 72%)))
  place(top + center, dx: -0.5cm, dy: 9cm,
    rotate(-3deg, page-shadow-image(pages.at(l-indices.at(2)), scale: 24%)))
  place(top + center, dx: 0.3cm, dy: 11.5cm,
    rotate(2deg, page-shadow-image(pages.at(l-indices.at(1)), scale: 23%)))
  place(top + center, dx: -0.3cm, dy: 14cm,
    rotate(-2deg, page-shadow-image(pages.at(l-indices.at(0)), scale: 22%)))
}

#let layout-5P(pages) = {
  place(top + center, dx: 2.5cm, dy: 0cm,
    rotate(10deg, page-shadow-image(pages.at(4), scale: 52%, radius: 3pt)))
  place(top + center, dx: -0.5cm, dy: 1cm,
    rotate(0deg, page-shadow-image(pages.at(3), scale: 52%, radius: 3pt)))
  place(top + center, dx: -3.5cm, dy: 2cm,
    rotate(-8deg, page-shadow-image(pages.at(2), scale: 48%, radius: 3pt)))
  place(top + center, dx: 1.5cm, dy: 9.5cm,
    rotate(5deg, page-shadow-image(pages.at(1), scale: 56%, radius: 3pt)))
  place(top + center, dx: -2.5cm, dy: 11cm,
    rotate(-4deg, page-shadow-image(pages.at(0), scale: 54%, radius: 3pt)))
}

#let layout-5L(pages) = {
  place(top + center, dx: -2.5cm, dy: 0cm,
    rotate(-5deg, page-shadow-image(pages.at(4), scale: 24%, radius: 3pt)))
  place(top + center, dx: 0cm, dy: 1.5cm,
    rotate(0deg, page-shadow-image(pages.at(3), scale: 24%, radius: 3pt)))
  place(top + center, dx: 2.5cm, dy: 3cm,
    rotate(5deg, page-shadow-image(pages.at(2), scale: 24%, radius: 3pt)))
  place(top + center, dx: -1.5cm, dy: 8cm,
    rotate(-4deg, page-shadow-image(pages.at(1), scale: 24%, radius: 3pt)))
  place(top + center, dx: 1.5cm, dy: 9.5cm,
    rotate(4deg, page-shadow-image(pages.at(0), scale: 24%, radius: 3pt)))
}

#let layout-5L-stacked(pages) = {
  place(top + center, dx: 4.5cm, dy: -3cm,
    rotate(12deg, page-shadow-image(pages.at(4), scale: 40%, radius: 3pt)))
  place(top + center, dx: 1.5cm, dy: 0cm,
    rotate(5deg, page-shadow-image(pages.at(3), scale: 38%, radius: 3pt)))
  place(top + center, dx: -0.5cm, dy: 3cm,
    rotate(-2deg, page-shadow-image(pages.at(2), scale: 36%, radius: 3pt)))
  place(top + center, dx: -2.5cm, dy: 6cm,
    rotate(-5deg, page-shadow-image(pages.at(1), scale: 34%, radius: 3pt)))
  place(top + center, dx: -4cm, dy: 9cm,
    rotate(-10deg, page-shadow-image(pages.at(0), scale: 32%, radius: 3pt)))
}

#let layout-4P-1L(pages, p-indices, l-indices) = {
  place(top + center, dx: 3.5cm, dy: 0cm,
    rotate(12deg, page-shadow-image(pages.at(p-indices.at(3)), scale: 46%, radius: 3pt)))
  place(top + center, dx: 0.5cm, dy: 2cm,
    rotate(4deg, page-shadow-image(pages.at(p-indices.at(2)), scale: 43%, radius: 3pt)))
  place(top + center, dx: -2.5cm, dy: 4cm,
    rotate(-4deg, page-shadow-image(pages.at(p-indices.at(1)), scale: 40%, radius: 3pt)))
  place(top + center, dx: -5cm, dy: 6cm,
    rotate(-10deg, page-shadow-image(pages.at(p-indices.at(0)), scale: 38%, radius: 3pt)))
  place(top + center, dx: -0.5cm, dy: 12.5cm,
    rotate(2deg, page-shadow-image(pages.at(l-indices.at(0)), scale: 28%, radius: 3pt)))
}

#let layout-3P-2L(pages, p-indices, l-indices) = {
  place(top + center, dx: 2cm, dy: 0cm,
    rotate(8deg, page-shadow-image(pages.at(p-indices.at(2)), scale: 52%, radius: 3pt)))
  place(top + center, dx: -1cm, dy: 3cm,
    rotate(0deg, page-shadow-image(pages.at(p-indices.at(1)), scale: 49%, radius: 3pt)))
  place(top + center, dx: -3.5cm, dy: 6cm,
    rotate(-6deg, page-shadow-image(pages.at(p-indices.at(0)), scale: 46%, radius: 3pt)))
  place(top + center, dx: -1.5cm, dy: 11cm,
    rotate(-3deg, page-shadow-image(pages.at(l-indices.at(1)), scale: 22%, radius: 3pt)))
  place(top + center, dx: -0.5cm, dy: 13cm,
    rotate(2deg, page-shadow-image(pages.at(l-indices.at(0)), scale: 21%, radius: 3pt)))
}

#let layout-2P-3L(pages, p-indices, l-indices) = {
  place(top + center, dx: 1cm, dy: 0cm,
    rotate(5deg, page-shadow-image(pages.at(p-indices.at(1)), scale: 58%)))
  place(top + center, dx: -2.5cm, dy: 3.5cm,
    rotate(-4deg, page-shadow-image(pages.at(p-indices.at(0)), scale: 50%)))
  place(top + center, dx: -1.5cm, dy: 9cm,
    rotate(-3deg, page-shadow-image(pages.at(l-indices.at(2)), scale: 22%)))
  place(top + center, dx: -0.7cm, dy: 11cm,
    rotate(2deg, page-shadow-image(pages.at(l-indices.at(1)), scale: 21%)))
  place(top + center, dx: -1.3cm, dy: 13cm,
    rotate(-2deg, page-shadow-image(pages.at(l-indices.at(0)), scale: 20%)))
}

#let layout-1P-4L(pages, p-indices, l-indices) = {
  let p0 = p-indices.at(0)
  place(top + center, dx: 0cm, dy: 0cm,
    rotate(2deg, page-shadow-image(pages.at(p0), scale: 68%)))
  place(top + center, dx: -1.5cm, dy: 8cm,
    rotate(-4deg, page-shadow-image(pages.at(l-indices.at(3)), scale: 21%)))
  place(top + center, dx: 1.5cm, dy: 10cm,
    rotate(3deg, page-shadow-image(pages.at(l-indices.at(2)), scale: 20%)))
  place(top + center, dx: -1cm, dy: 12cm,
    rotate(-3deg, page-shadow-image(pages.at(l-indices.at(1)), scale: 19%)))
  place(top + center, dx: 1cm, dy: 14cm,
    rotate(3deg, page-shadow-image(pages.at(l-indices.at(0)), scale: 18%)))
}

// ============================================================================
// DISPATCHER: Waehlt das passende Layout basierend auf Seitentypen
// l-style: "spread" (alles sichtbar) oder "stacked" (gross, ueberlappend)
// ============================================================================

#let pageboxes(pages, l-style: "spread", base-path: none) = {
  if pages.len() == 0 { return }

  let count = calc.min(pages.len(), 5)
  let display-pages = pages.slice(0, count).map(spec => resolve-page-spec(spec, base-path: base-path))

  let page-infos = display-pages.map(get-page-info)
  let p-indices = ()
  let l-indices = ()

  for (i, info) in page-infos.enumerate() {
    if info.is-portrait {
      p-indices.push(i)
    } else {
      l-indices.push(i)
    }
  }

  let p-count = p-indices.len()
  let l-count = l-indices.len()
  let has-wide-landscape = page-infos.any(info => info.is-wide)
  let effective-l-style = if l-style == "spread" and p-count == 0 and not has-wide-landscape {
    "stacked"
  } else {
    l-style
  }

  if count == 1 {
    if p-count == 1 { layout-1P(display-pages) }
    else if effective-l-style == "stacked" { layout-1L-stacked(display-pages) }
    else { layout-1L(display-pages) }
  } else if count == 2 {
    if p-count == 2 { layout-2P(display-pages) }
    else if l-count == 2 and effective-l-style == "stacked" { layout-2L-stacked(display-pages) }
    else if l-count == 2 { layout-2L(display-pages) }
    else { layout-1P-1L(display-pages, p-indices, l-indices) }
  } else if count == 3 {
    if p-count == 3 { layout-3P(display-pages) }
    else if l-count == 3 and effective-l-style == "stacked" { layout-3L-stacked(display-pages) }
    else if l-count == 3 { layout-3L(display-pages) }
    else if p-count == 2 { layout-2P-1L(display-pages, p-indices, l-indices) }
    else { layout-1P-2L(display-pages, p-indices, l-indices) }
  } else if count == 4 {
    if p-count == 4 { layout-4P(display-pages) }
    else if l-count == 4 and effective-l-style == "stacked" { layout-4L-stacked(display-pages) }
    else if l-count == 4 { layout-4L(display-pages) }
    else if p-count == 3 { layout-3P-1L(display-pages, p-indices, l-indices) }
    else if p-count == 2 { layout-2P-2L(display-pages, p-indices, l-indices) }
    else { layout-1P-3L(display-pages, p-indices, l-indices) }
  } else if count == 5 {
    if p-count == 5 { layout-5P(display-pages) }
    else if l-count == 5 and effective-l-style == "stacked" { layout-5L-stacked(display-pages) }
    else if l-count == 5 { layout-5L(display-pages) }
    else if p-count == 4 { layout-4P-1L(display-pages, p-indices, l-indices) }
    else if p-count == 3 { layout-3P-2L(display-pages, p-indices, l-indices) }
    else if p-count == 2 { layout-2P-3L(display-pages, p-indices, l-indices) }
    else { layout-1P-4L(display-pages, p-indices, l-indices) }
  }
}

// ============================================================================
// TITELBOX MIT GESTRICHELTEM RAHMEN
// ============================================================================

#let strichbox(title, subtitle) = box(
  width: 100%,
  height: 7.5cm,
  fill: white,
  inset: 5mm,
  box(
    width: 100%,
    height: 100%,
    inset: (x: 6mm, y: 12mm),
    stroke: (paint: black, thickness: 6pt, dash: (15pt, 6pt)),
    align(
      center + horizon,
      [
        #grid(
          row-gutter: 1.5em,
          rows: 7.5cm / 4,
          text(font: "Londrina Solid", 70pt, fill-height-with-text(title)),
          text(font: "Kalam", weight: "bold", 50pt, fill-height-with-text(subtitle)),
        )
      ],
    ),
  ),
)

// ============================================================================
// HAUPTKOMPONENTE: Material-Box
// l-style: "spread" (alles sichtbar) oder "stacked" (gross, ueberlappend)
// ============================================================================

#let material-box(
  title,
  subtitle,
  color,
  images,
  icon: none,
  l-style: "spread",
  base-path: none,
) = context {
  box(
    width: 100%,
    height: 100%,
    stroke: 12pt + black,
    fill: color.lighten(25%),
    inset: 11mm,
    clip: true,
  )[
    #place(top + center, dy: 7.5cm + 5mm)[
      #block(
        width: 100%,
        height: 100%,
        clip: false,
      )[
        #pageboxes(images, l-style: l-style, base-path: base-path)
      ]
    ]

    #place(top + left)[
      #strichbox(title, subtitle)
    ]

    #if icon != none {
      place(
        bottom + right,
        dx: 11mm,
        dy: 11mm,
        box(
          width: 4.5cm,
          height: 4.5cm,
          stroke: 6pt + black,
          radius: (top-left: 10%),
          fill: color.darken(5%).saturate(50%),
          align(center + bottom, image(icon, width: 80%)),
        ),
      )
    }
  ]
}
