// ================================================================
// Scratch-Blöcke für Typst
//
// Dieses Paket rendert Scratch-ähnliche Blöcke und Reporter in Typst.
// Die Darstellung ist global über einen State konfigurierbar (Theme & Linienbreite).
//
// Schnellstart:
//   - Globale Optionen setzen:  #set-scratch(theme: "high-contrast", stroke-width: 1pt)
//   - Blöcke verwenden:         #bewegung[ ... ], #steuerung[ ... ], #ereignis[ ... ] usw.
//   - Reporter/Werte:            #zahl-oder-content(42, colors.bewegung) oder #bewegung-reporter[ ... ]
//
// Inhaltsverzeichnis (Sektionen):
//   1) Konfiguration & State
//   2) Assets & Icons
//   3) Farbpaletten (normal / high-contrast)
//   4) Theme-/Stroke-Helpers
//   5) Hilfsfunktionen für Benutzer (get-colors, get-stroke)
//   6) Geometrie & Layout-Konstanten
//   7) Pill-Primitives (Basis + Varianten)
//   8) Wert-/Content-Helfer
//   9) Blockpfade & Rendering (scratch-block, bedingung)
//  10) Kategorie-Wrapper (bewegung, aussehen, ...)
//  11) Ereignisse
//  12) Reporter (generisch + je Kategorie)
//  13) Kontrollstrukturen (wiederhole, falls, ...)
//  14) Bewegungsblöcke
//  15) Aussehen
//  16) Klang
//  17) Malstift
//  18) Fühlen (Sensoren)
//  19) Variablen
//  20) Listen
//  21) Eigene Blöcke
//  22) Operatoren
// ================================================================

// ------------------------------------------------
// 1) Konfiguration & State
// ------------------------------------------------
// State für globale Scratch-Einstellungen
#let scratch-block-options = state("scratch-block-options", (
  theme: "normal", // "normal" oder "high-contrast"
  stroke-width: auto, // auto oder spezifische Länge (z.B. 1pt)
  scale: 100%, // Skalierung der Blöcke
))

// Funktion zum Setzen der globalen Scratch-Optionen
#let set-scratch(theme: auto, stroke-width: auto, scale: auto) = {
  scratch-block-options.update(current => {
    let new-state = current
    if theme != auto {
      new-state.theme = theme
    }
    if stroke-width != auto {
      new-state.stroke-width = stroke-width
    }
    if scale != auto {
      new-state.scale = scale
    }
    new-state
  })
}

// ------------------------------------------------
// 2) Assets & Icons
// ------------------------------------------------
#let icons = (
  dropdown-arrow: bytes(
    "<svg id=\"Layer_1\" data-name=\"Layer 1\" xmlns=\"http://www.w3.org/2000/svg\" width=\"12.71\" height=\"8.79\" viewBox=\"0 0 12.71 8.79\"><title>dropdown-arrow</title><g opacity=\"0.1\"><path d=\"M12.71,2.44A2.41,2.41,0,0,1,12,4.16L8.08,8.08a2.45,2.45,0,0,1-3.45,0L0.72,4.16A2.42,2.42,0,0,1,0,2.44,2.48,2.48,0,0,1,.71.71C1,0.47,1.43,0,6.36,0S11.75,0.46,12,.71A2.44,2.44,0,0,1,12.71,2.44Z\" fill=\"#231f20\"/></g><path d=\"M6.36,7.79a1.43,1.43,0,0,1-1-.42L1.42,3.45a1.44,1.44,0,0,1,0-2c0.56-.56,9.31-0.56,9.87,0a1.44,1.44,0,0,1,0,2L7.37,7.37A1.43,1.43,0,0,1,6.36,7.79Z\" fill=\"#fff\"/></svg>",
  ),
  rotate-right: bytes(
    "<svg id=\"rotate-counter-clockwise\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><defs><style>.cls-1{fill:#3d79cc;}.cls-2{fill:#fff;}</style></defs><title>rotate-counter-clockwise</title><path class=\"cls-1\" d=\"M22.68,12.2a1.6,1.6,0,0,1-1.27.63H13.72a1.59,1.59,0,0,1-1.16-2.58l1.12-1.41a4.82,4.82,0,0,0-3.14-.77,4.31,4.31,0,0,0-2,.8,4.25,4.25,0,0,0-1.34,1.73,5.06,5.06,0,0,0,.54,4.62A5.58,5.58,0,0,0,12,17.74h0a2.26,2.26,0,0,1-.16,4.52A10.25,10.25,0,0,1,3.74,18,10.14,10.14,0,0,1,2.25,8.78,9.7,9.7,0,0,1,5.08,4.64,9.92,9.92,0,0,1,9.66,2.5a10.66,10.66,0,0,1,7.72,1.68l1.08-1.35a1.57,1.57,0,0,1,1.24-.6,1.6,1.6,0,0,1,1.54,1.21l1.7,7.37A1.57,1.57,0,0,1,22.68,12.2Z\"/><path class=\"cls-2\" d=\"M21.38,11.83H13.77a.59.59,0,0,1-.43-1l1.75-2.19a5.9,5.9,0,0,0-4.7-1.58,5.07,5.07,0,0,0-4.11,3.17A6,6,0,0,0,7,15.77a6.51,6.51,0,0,0,5,2.92,1.31,1.31,0,0,1-.08,2.62,9.3,9.3,0,0,1-7.35-3.82A9.16,9.16,0,0,1,3.17,9.12,8.51,8.51,0,0,1,5.71,5.4,8.76,8.76,0,0,1,9.82,3.48a9.71,9.71,0,0,1,7.75,2.07l1.67-2.1a.59.59,0,0,1,1,.21L22,11.08A.59.59,0,0,1,21.38,11.83Z\"/></svg>",
  ),
  rotate-left: bytes(
    "<svg id=\"rotate-clockwise\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><defs><style>.cls-1{fill:#3d79cc;}.cls-2{fill:#fff;}</style></defs><title>rotate-clockwise</title><path class=\"cls-1\" d=\"M20.34,18.21a10.24,10.24,0,0,1-8.1,4.22,2.26,2.26,0,0,1-.16-4.52h0a5.58,5.58,0,0,0,4.25-2.53,5.06,5.06,0,0,0,.54-4.62A4.25,4.25,0,0,0,15.55,9a4.31,4.31,0,0,0-2-.8A4.82,4.82,0,0,0,10.4,9l1.12,1.41A1.59,1.59,0,0,1,10.36,13H2.67a1.56,1.56,0,0,1-1.26-.63A1.54,1.54,0,0,1,1.13,11L2.85,3.57A1.59,1.59,0,0,1,4.38,2.4,1.57,1.57,0,0,1,5.62,3L6.7,4.35a10.66,10.66,0,0,1,7.72-1.68A9.88,9.88,0,0,1,19,4.81,9.61,9.61,0,0,1,21.83,9,10.08,10.08,0,0,1,20.34,18.21Z\"/><path class=\"cls-2\" d=\"M19.56,17.65a9.29,9.29,0,0,1-7.35,3.83,1.31,1.31,0,0,1-.08-2.62,6.53,6.53,0,0,0,5-2.92,6.05,6.05,0,0,0,.67-5.51,5.32,5.32,0,0,0-1.64-2.16,5.21,5.21,0,0,0-2.48-1A5.86,5.86,0,0,0,9,8.84L10.74,11a.59.59,0,0,1-.43,1H2.7a.6.6,0,0,1-.6-.75L3.81,3.83a.59.59,0,0,1,1-.21l1.67,2.1a9.71,9.71,0,0,1,7.75-2.07,8.84,8.84,0,0,1,4.12,1.92,8.68,8.68,0,0,1,2.54,3.72A9.14,9.14,0,0,1,19.56,17.65Z\"/></svg>",
  ),
  green-flag: bytes(
    "<svg id=\"Layer_1\" data-name=\"Layer 1\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 16.63 17.5\"><defs><style>.cls-1,.cls-2{fill:#4cbf56;stroke:#45993d;stroke-linecap:round;stroke-linejoin:round;}.cls-2{stroke-width:1.5px;}</style></defs><title>icon--green-flag</title><path class=\"cls-1\" d=\"M.75,2A6.44,6.44,0,0,1,8.44,2h0a6.44,6.44,0,0,0,7.69,0V12.4a6.44,6.44,0,0,1-7.69,0h0a6.44,6.44,0,0,0-7.69,0\"/><line class=\"cls-2\" x1=\"0.75\" y1=\"16.75\" x2=\"0.75\" y2=\"0.75\"/></svg>",
  ),
  repeat: bytes(
    "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<!-- Generator: Adobe Illustrator 21.0.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
<svg version=\"1.1\" id=\"repeat\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\"
	 viewBox=\"0 0 24 24\" style=\"enable-background:new 0 0 24 24;\" xml:space=\"preserve\">
<style type=\"text/css\">
	.st0{fill:#CF8B17;}
	.st1{fill:#FFFFFF;}
</style>
<path class=\"st0\" d=\"M23.3,11c-0.3,0.6-0.9,1-1.5,1h-1.6c-0.1,1.3-0.5,2.5-1.1,3.6c-0.9,1.7-2.3,3.2-4.1,4.1
	c-1.7,0.9-3.6,1.2-5.5,0.9c-1.8-0.3-3.5-1.1-4.9-2.3c-0.7-0.7-0.7-1.9,0-2.6c0.6-0.6,1.6-0.7,2.3-0.2H7c0.9,0.6,1.9,0.9,2.9,0.9
	s1.9-0.3,2.7-0.9c1.1-0.8,1.8-2.1,1.8-3.5h-1.5c-0.9,0-1.7-0.7-1.7-1.7c0-0.4,0.2-0.9,0.5-1.2l4.4-4.4c0.7-0.6,1.7-0.6,2.4,0L23,9.2
	C23.5,9.7,23.6,10.4,23.3,11z\"/>
<path class=\"st1\" d=\"M21.8,11h-2.6c0,1.5-0.3,2.9-1,4.2c-0.8,1.6-2.1,2.8-3.7,3.6c-1.5,0.8-3.3,1.1-4.9,0.8c-1.6-0.2-3.2-1-4.4-2.1
	c-0.4-0.3-0.4-0.9-0.1-1.2c0.3-0.4,0.9-0.4,1.2-0.1l0,0c1,0.7,2.2,1.1,3.4,1.1s2.3-0.3,3.3-1c0.9-0.6,1.6-1.5,2-2.6
	c0.3-0.9,0.4-1.8,0.2-2.8h-2.4c-0.4,0-0.7-0.3-0.7-0.7c0-0.2,0.1-0.3,0.2-0.4l4.4-4.4c0.3-0.3,0.7-0.3,0.9,0L22,9.8
	c0.3,0.3,0.4,0.6,0.3,0.9S22,11,21.8,11z\"/>
</svg>
",
  ),
  pen: bytes(
    "<svg width=\"40\" height=\"40\" viewBox=\"0 0 40 40\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\"><path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M8.7529 34.6025L4.5019 36.3805L6.2859 32.1445C7.5039 29.2535 9.1929 26.7225 11.3159 24.6075L31.0669 4.9295C31.9119 4.0875 33.7169 4.5205 35.0979 5.8965C36.4789 7.2725 36.9139 9.0705 36.0679 9.9125L16.3179 29.5905C14.1949 31.7055 11.6539 33.3885 8.7529 34.6025Z\" fill=\"white\"/><path d=\"M8.7529 34.6025L4.5019 36.3805L6.2859 32.1445C7.5039 29.2535 9.1929 26.7225 11.3159 24.6075L31.0669 4.9295C31.9119 4.0875 33.7169 4.5205 35.0979 5.8965C36.4789 7.2725 36.9139 9.0705 36.0679 9.9125L16.3179 29.5905C14.1949 31.7055 11.6539 33.3885 8.7529 34.6025\" stroke=\"#0B8E69\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/><path d=\"M29.4092 6.1113C29.4092 6.1113 24.9602 3.7323 21.2082 11.8823C19.4742 15.6483 16.8582 13.4283 16.8582 13.4283\" stroke=\"#0B8E69\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/><path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M36.4209 8.8251C36.4209 9.2881 36.2799 9.6981 35.9879 9.9891L26.6529 19.2901C26.9349 18.9991 27.0639 18.6221 27.0639 18.1691C27.0639 17.2961 26.5559 16.2071 25.6569 15.3021C24.2949 13.9441 22.5099 13.5021 21.6549 14.3111L30.9899 5.0101C31.8339 4.1691 33.6409 4.6001 35.0249 5.9691C35.9229 6.8741 36.4209 7.9521 36.4209 8.8251Z\" fill=\"#4C97FF\"/><path d=\"M36.4209 8.8251C36.4209 9.2881 36.2799 9.6981 35.9879 9.9891L26.6529 19.2901C26.9349 18.9991 27.0639 18.6221 27.0639 18.1691C27.0639 17.2961 26.5559 16.2071 25.6569 15.3021C24.2949 13.9441 22.5099 13.5021 21.6549 14.3111L30.9899 5.0101C31.8339 4.1691 33.6409 4.6001 35.0249 5.9691C35.9229 6.8741 36.4209 7.9521 36.4209 8.8251\" stroke=\"#0B8E69\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/><path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M10.5146 33.7739C9.9416 34.0759 9.3576 34.3449 8.7506 34.6039L4.4996 36.3819L6.2856 32.1469C6.5436 31.5429 6.8146 30.9609 7.1186 30.3899C7.8096 30.5729 8.5676 31.0149 9.2276 31.6719C9.8866 32.3299 10.3296 33.0839 10.5146 33.7739Z\" fill=\"#4C97FF\"/><path d=\"M10.5146 33.7739C9.9416 34.0759 9.3576 34.3449 8.7506 34.6039L4.4996 36.3819L6.2856 32.1469C6.5436 31.5429 6.8146 30.9609 7.1186 30.3899C7.8096 30.5729 8.5676 31.0149 9.2276 31.6719C9.8866 32.3299 10.3296 33.0839 10.5146 33.7739\" stroke=\"#0B8E69\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/><g opacity=\"0.15\"><path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M36.498 8.7485C36.498 9.2115 36.357 9.6215 36.065 9.9125L16.323 29.5925C14.192 31.7045 11.65 33.3855 8.751 34.6035L4.5 36.3815L5.474 34.0645L7.399 33.2565C10.298 32.0385 12.84 30.3575 14.971 28.2455L34.713 8.5655C35.005 8.2745 35.145 7.8645 35.145 7.4015C35.145 6.7545 34.875 6.0005 34.366 5.2785C34.615 5.4505 34.864 5.6555 35.102 5.8925C36 6.7975 36.498 7.8755 36.498 8.7485Z\" fill=\"#0B8E69\"/><path d=\"M36.498 8.7485C36.498 9.2115 36.357 9.6215 36.065 9.9125L16.323 29.5925C14.192 31.7045 11.65 33.3855 8.751 34.6035L4.5 36.3815L5.474 34.0645L7.399 33.2565C10.298 32.0385 12.84 30.3575 14.971 28.2455L34.713 8.5655C35.005 8.2745 35.145 7.8645 35.145 7.4015C35.145 6.7545 34.875 6.0005 34.366 5.2785C34.615 5.4505 34.864 5.6555 35.102 5.8925C36 6.7975 36.498 7.8755 36.498 8.7485\" stroke=\"#0B8E69\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/></g><path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M18.4502 12.831C18.4502 13.33 18.0462 13.735 17.5462 13.735C17.0472 13.735 16.6412 13.33 16.6412 12.831C16.6412 12.331 17.0472 11.927 17.5462 11.927C18.0462 11.927 18.4502 12.331 18.4502 12.831Z\" fill=\"#0B8E69\" stroke=\"#0B8E69\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/></svg>",
  ),
  pencil: bytes(
    "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" width=\"101.69145250320435\" height=\"120.35980272293091\" viewBox=\"0.397601842880249 0.12278616428375244 101.69145250320435 120.35980272293091\">
  <g id=\"ID0.9544714530929923\">
    <path id=\"ID0.8586977859959006\" fill=\"#FF9400\" stroke=\"none\" stroke-linecap=\"round\" d=\"M 86.25 1.5 C 89.721 1.494 93.54 2.946 96.25 5.25 C 98.556 7.212 100.771 10.423 100.5 13.5 C 100.25 16.292 96.861 18.188 94.75 20.25 C 93.067 21.907 91.485 25.7 89 25.25 C 85.831 24.648 84.583 20.296 82 18.25 C 80.109 16.75 75.501 17.345 75.5 15 C 75.624 11.077 79.9 8.44 82.25 5.5 C 83.426 4.029 84.36 1.503 86.25 1.5 Z\" stroke-width=\"1\"/>
    <path id=\"ID0.9701001369394362\" fill=\"#B5B5B5\" stroke=\"none\" stroke-linecap=\"round\" d=\"M 78.75 11.75 C 82.13 11.33 85.667 13.17 88.369 15.248 C 90.513 16.896 93.354 19.745 92.75 22.5 C 91.76 26.994 87.681 30.741 84 33.75 C 83.095 34.496 82.26 32.369 81.25 31.75 C 79.885 30.62 78.513 29.467 76.881 28.502 C 74.221 26.927 70.127 26.77 68.75 24 C 67.695 21.867 69.81 19.394 71.25 17.75 C 73.259 15.169 75.673 12.129 78.75 11.75 Z\" stroke-width=\"1\"/>
    <path id=\"ID0.8783496841788292\" fill=\"#FFFFCC\" stroke=\"none\" stroke-linecap=\"round\" d=\"M 9.5 94.5 C 12.718 92.255 17.414 87.839 20.5 90.25 C 24.907 93.617 26.269 101.118 24.75 106.5 C 23.666 110.342 17.776 110.636 14.25 112.75 C 12.03 113.884 9.751 114.915 7.5 116.25 C 5.989 117.143 4.755 118.304 3 119 C 2.505 119.195 1.178 120.097 1.5 118.5 C 2.792 112.131 4.929 105.895 7 99.75 C 7.595 97.982 7.923 95.628 9.5 94.5 Z\" stroke-width=\"1\"/>
    <path id=\"ID0.3507009046152234\" fill=\"#FFFF00\" stroke=\"#000000\" stroke-width=\"2\" stroke-linecap=\"round\" d=\"M 9.5 94 C 8.158 96.061 11.644 94.776 12.75 95.25 C 13.523 95.574 14.721 95.304 15.25 96 C 15.801 96.822 15.349 97.758 15.25 98.5 C 15.186 100.095 14.058 101.86 14.75 103 C 15.307 103.908 16.918 103.337 18 103.25 C 19.026 103.168 19.985 102.324 21 102.5 C 22.069 102.686 22.902 103.572 23.75 104.25 C 24.577 104.912 24.95 106.535 26 106.5 C 27.079 106.451 26.933 105.52 28.25 103.75 C 33.715 97.18 39.021 90.487 44.5 83.75 C 57.528 67.731 70.9 51.85 83.75 35.75 C 86.95 31.6 86.15 33.05 86 31.5 C 85.7 28.95 84.15 26.55 82.5 24.75 C 80.8 22.85 78.6 21.45 76.25 20.75 C 74.15 20.1 71.9 20 70 20.75 C 68.6 21.25 70.24 20.098 67 24 C 54.088 39.614 41.258 55.203 28.5 70.75 C 22.111 78.513 14.847 85.707 9.5 94 Z\"/>
    <path id=\"ID0.26528497599065304\" fill=\"none\" stroke=\"#000000\" stroke-width=\"2\" stroke-linecap=\"round\" d=\"M 70.75 34.75 L 16.5 102.5\"/>
    <path id=\"ID0.8384811817668378\" fill=\"none\" stroke=\"#000000\" stroke-width=\"2\" stroke-linecap=\"round\" d=\"M 8.5 95.5 C 8.5 95.5 7.454 98.487 7 100 C 6.704 100.986 6.536 102.011 6.25 103 C 5.62 105.175 4.932 107.34 4.25 109.5 C 3.933 110.504 3.553 111.491 3.25 112.5 C 2.803 113.99 2.393 115.495 2 117 C 1.893 117.411 1.75 118.25 1.75 118.25\"/>
    <path id=\"ID0.8209637436084449\" fill=\"none\" stroke=\"#000000\" stroke-width=\"2\" stroke-linecap=\"round\" d=\"M 26.25 106.5 C 26.25 106.5 24.756 107.347 24 107.75 C 22.259 108.679 20.533 109.653 18.75 110.5 C 17.2 111.236 15.535 111.732 14 112.5 C 11.866 113.567 9.829 114.831 7.75 116 C 7.165 116.329 6.565 116.637 6 117 C 5.398 117.387 4.852 117.863 4.25 118.25 C 3.685 118.613 3.113 118.977 2.5 119.25 C 2.347 119.318 2 119.25 2 119.25\"/>
    <path id=\"ID0.03616796713322401\" fill=\"none\" stroke=\"#000000\" stroke-width=\"2\" stroke-linecap=\"round\" d=\"M 1.75 118.5 L 2.05 118.8\"/>
    <path id=\"ID0.21085595898330212\" fill=\"none\" stroke=\"#000000\" stroke-width=\"2\" stroke-linecap=\"round\" d=\"M 70 20 C 70 20 73.879 14.797 76 12.25 C 76.463 11.682 76.631 11.26 77.25 11.25 C 79.273 11.213 81.389 11.368 83.25 12.25 C 85.83 13.477 88.215 15.395 90 17.75 C 91.478 19.43 91.816 21.87 92.75 24 C 92.984 24.532 93.216 23.932 93 24.25 C 92.185 25.484 91.197 26.532 90.25 27.75 C 88.866 29.446 86 33 86 33\"/>
    <path id=\"ID0.21085595898330212\" fill=\"none\" stroke=\"#000000\" stroke-width=\"2.1052632331848145\" stroke-linecap=\"round\" d=\"M 77.5079 10.9947 C 77.5079 10.9947 81.6342 5.2453 83.9816 2.7316 C 84.5111 2.0758 84.9205 1.3074 85.7184 1.2579 C 87.4984 1.0895 89.369 1.1242 91.0342 1.8895 C 93.7279 3.1284 96.3868 4.719 98.4026 6.8895 C 99.8795 8.4947 100.5711 10.6421 100.9816 12.7316 C 101.2247 13.4253 100.6016 14.119 100.2447 14.7316 C 99.4742 16.0547 98.6637 17.3558 97.7184 18.4684 C 96.0805 20.5358 92.5079 24.2579 92.5079 24.2579\"/>
    <path id=\"ID0.41866302071139216\" fill=\"none\" stroke=\"#000000\" stroke-width=\"2\" stroke-linecap=\"round\" d=\"M 89 26.75 C 89 26.75 88.364 25.069 88 24.25 C 87.698 23.57 87.44 22.85 87 22.25 C 86.513 21.585 85.854 21.061 85.25 20.5 C 84.688 19.978 84.104 19.474 83.5 19 C 82.937 18.558 82.382 18.087 81.75 17.75 C 81.122 17.415 80.416 17.25 79.75 17 C 79.583 16.938 79.75 17 79.75 17\"/>
    <path id=\"ID0.1270556254312396\" fill=\"#000000\" stroke=\"none\" stroke-linecap=\"round\" d=\"M 6.75 110.5 C 7.393 110.555 8.035 110.846 8.517 111.269 C 9.05 111.738 9.403 112.368 9.7 113 C 9.898 113.423 10.06 113.99 9.85 114.5 C 9.784 114.782 9.515 114.702 9 115 C 6.935 116.195 4.037 119.166 2.75 118.5 C 1.57 117.834 2.722 114.645 3 112.75 C 3.113 112.052 3.129 111.13 3.75 110.75 C 4.599 110.248 5.789 110.413 6.75 110.5 Z\" stroke-width=\"1\"/>
  </g>
</svg>",
  ),
)
// ------------------------------------------------
// 3) Farbpaletten (normal / high-contrast)
// ------------------------------------------------
// Standard Scratch-Farben (mit offizieller Blockly-Namenskonvention)
#let colors-normal = (
  text-color: rgb("#FFFFFF"),
  bewegung: (primary: rgb("#4C97FF"), secondary: rgb("#4280D7"), tertiary: rgb("#3373CC"), quaternary: rgb("#3373CC")),
  aussehen: (primary: rgb("#9966FF"), secondary: rgb("#855CD6"), tertiary: rgb("#774DCB"), quaternary: rgb("#774DCB")),
  klang: (primary: rgb("#CF63CF"), secondary: rgb("#C94FC9"), tertiary: rgb("#BD42BD"), quaternary: rgb("#BD42BD")),
  ereignisse: (primary: rgb("#FFBF00"), secondary: rgb("#E6AC00"), tertiary: rgb("#CC9900"), quaternary: rgb("#CC9900")),
  steuerung: (primary: rgb("#FFAB19"), secondary: rgb("#EC9C13"), tertiary: rgb("#CF8B17"), quaternary: rgb("#CF8B17")),
  fühlen: (primary: rgb("#5CB1D6"), secondary: rgb("#47A8D1"), tertiary: rgb("#2E8EB8"), quaternary: rgb("#2E8EB8")),
  operatoren: (primary: rgb("#59C059"), secondary: rgb("#46B946"), tertiary: rgb("#389438"), quaternary: rgb("#389438")),
  variablen: (primary: rgb("#FF8C1A"), secondary: rgb("#FF8000"), tertiary: rgb("#DB6E00"), quaternary: rgb("#DB6E00")),
  listen: (primary: rgb("#FF661A"), secondary: rgb("#FF5500"), tertiary: rgb("#E64D00"), quaternary: rgb("#E64D00")),
  eigene: (primary: rgb("#FF6680"), secondary: rgb("#FF4D6A"), tertiary: rgb("#FF3355"), quaternary: rgb("#FF3355")),
  malstift: (primary: rgb("#0FBD8C"), secondary: rgb("#0DA57A"), tertiary: rgb("#0B8E69"), quaternary: rgb("#0B8E69")),
)

// Hoher Kontrast Variante (Offizielle Scratch High-Contrast-Farben)
#let colors-high-contrast = (
  text-color: rgb("#000000"),
  bewegung: (primary: rgb("#80B5FF"), secondary: rgb("#B3D2FF"), tertiary: rgb("#3373CC"), quaternary: rgb("#CCE1FF")),
  aussehen: (primary: rgb("#CCB3FF"), secondary: rgb("#DDCCFF"), tertiary: rgb("#774DCB"), quaternary: rgb("#EEE5FF")),
  klang: (primary: rgb("#E19DE1"), secondary: rgb("#FFB3FF"), tertiary: rgb("#BD42BD"), quaternary: rgb("#FFCCFF")),
  ereignisse: (primary: rgb("#FFD966"), secondary: rgb("#FFECB3"), tertiary: rgb("#CC9900"), quaternary: rgb("#FFF2CC")),
  steuerung: (primary: rgb("#FFBE4C"), secondary: rgb("#FFDA99"), tertiary: rgb("#CF8B17"), quaternary: rgb("#FFE3B3")),
  fühlen: (primary: rgb("#85C4E0"), secondary: rgb("#AED8EA"), tertiary: rgb("#2E8EB8"), quaternary: rgb("#C2E2F0")),
  operatoren: (primary: rgb("#7ECE7E"), secondary: rgb("#B5E3B5"), tertiary: rgb("#389438"), quaternary: rgb("#DAF1DA")),
  variablen: (primary: rgb("#FFA54C"), secondary: rgb("#FFCC99"), tertiary: rgb("#DB6E00"), quaternary: rgb("#FFE5CC")),
  listen: (primary: rgb("#FF9966"), secondary: rgb("#FFCAB0"), tertiary: rgb("#E64D00"), quaternary: rgb("#FFDDCC")),
  eigene: (primary: rgb("#FF99AA"), secondary: rgb("#FFCCD5"), tertiary: rgb("#FF3355"), quaternary: rgb("#FFE5EA")),
  malstift: (primary: rgb("#13ECAF"), secondary: rgb("#75F0CD"), tertiary: rgb("#0B8E69"), quaternary: rgb("#A3F5DD")),
)

// ------------------------------------------------
// 4) Theme-/Stroke-Helpers
// ------------------------------------------------
// Hilfsfunktionen zum Auslesen der Farben und Stroke-Dicke aus den Optionen
#let get-colors-from-options(options) = {
  if options.theme == "high-contrast" {
    colors-high-contrast
  } else {
    colors-normal
  }
}

#let get-stroke-from-options(options) = {
  if options.stroke-width != auto {
    options.stroke-width
  } else if options.theme == "high-contrast" {
    1.0pt
  } else {
    0.5pt
  }
}

// ------------------------------------------------
// 5) Hilfsfunktionen für Benutzer (benötigen context!)
// ------------------------------------------------
// Hilfsfunktion: Gibt das aktuelle colors-Dictionary zurück (benötigt context!)
// Verwendung: #context { let colors = get-colors(); bedingung(colorschema: colors.operatoren)[] }
#let get-colors() = {
  let options = scratch-block-options.get()
  get-colors-from-options(options)
}

// Hilfsfunktion: Gibt die aktuelle Stroke-Dicke zurück (benötigt context!)
#let get-stroke() = {
  let options = scratch-block-options.get()
  get-stroke-from-options(options)
}

// ------------------------------------------------
// 6) Geometrie & Layout-Konstanten
// ------------------------------------------------
// Notch (Auskerbung/Puzzle-Verbinder) Dimensionen
#let notch-height = 1.5mm              // Vertikale Höhe der Auskerbung
#let notch-inner-width = 2.2mm         // Breite des flachen Mittelteils
#let notch-curve-control = 0.75mm      // Bézierkurven-Kontrollpunkt für Rundung
#let notch-spacing = 1.3mm             // Horizontaler Abstand vor/nach Notch
#let notch-total-width = notch-inner-width + 2 * (notch-height + notch-curve-control)  // Gesamtbreite inkl. Kurven
#let notch-reserved-space = notch-inner-width + notch-spacing  // Reservierter Platz in Breitenberechnungen (Approximation)

// Block-Dimensionen
#let block-height = 10mm
#let corner-radius = 0.75mm
#let block-offset-y = 1.5mm  // Vertikaler Offset für Anweisungsblöcke
#let block-left-indent = 5 * corner-radius  // Linker Einzug für Notch (≈3.75mm)

// Hat (Kappe) Dimensionen für Ereignis-Block
#let hat-cp1-x = 4mm
#let hat-cp1-y = 3.1mm
#let hat-cp2-x = 5.2mm

// Pill Dimensionen
#let pill-height = 6mm
#let pill-inset-x = 2.5mm
#let pill-inset-y = 1.25mm
#let pill-spacing = pill-inset-x * 0.66

// Layout
#let content-inset = 5pt

// Notch-Pfade (für Puzzle-Verbinder unten)
#let notch-path = (
  curve.cubic((-notch-curve-control, 0mm), (-notch-height, notch-height), (-notch-height - notch-curve-control, notch-height), relative: true),
  curve.line((-notch-inner-width, 0mm), relative: true),
  curve.cubic((-notch-curve-control, 0mm), (-notch-height, -notch-height), (-notch-height - notch-curve-control, -notch-height), relative: true),
)

// Invertierte Notch-Pfade (für Puzzle-Verbinder oben)
#let inverted-notch-path = (
  curve.cubic((notch-curve-control, 0mm), (notch-height, notch-height), (notch-height + notch-curve-control, notch-height), relative: true),
  curve.line((notch-inner-width, 0mm), relative: true),
  curve.cubic((notch-curve-control, 0mm), (notch-height, -notch-height), (notch-height + notch-curve-control, -notch-height), relative: true),
)

// ------------------------------------------------
// 7) Pill-Primitives (Basis + Varianten)
// ------------------------------------------------
// Interne Basis-Funktion für alle Pills
// Akzeptiert explizite colors und stroke-thickness Parameter
#let _pill-base-internal(
  fill: white,
  stroke: auto,
  text-color: auto,
  radius: 50%,
  inset: 0mm,
  height: auto,
  dropdown: false,
  body,
  colors: colors-normal,
  stroke-thickness: 0.5pt,
) = {
  // Standard-Stroke wenn auto
  let final-stroke = if stroke == auto {
    (paint: black, thickness: stroke-thickness)
  } else {
    stroke
  }

  // Automatische Textfarbe:
  // - Bei expliziter Angabe: verwende die angegebene Farbe
  // - Bei weißem Hintergrund: verwende dunkelgrau (normal) oder schwarz (high-contrast)
  // - Bei farbigem Hintergrund: verwende Theme-Farbe (weiß für normal, schwarz für high-contrast)
  let final-text-color = if text-color != auto {
    text-color
  } else if fill == white or fill == rgb("#FFFFFF") {
    // Weiße Pills brauchen dunkle Schrift
    if colors == colors-high-contrast {
      black // Schwarz bei high-contrast
    } else {
      rgb("#575E75") // Dunkelgrau bei normal
    }
  } else {
    colors.text-color // Theme-Farbe für farbige Hintergründe
  }

  set text(font: "Helvetica Neue", weight: 500)
  box(
    fill: fill,
    stroke: final-stroke,
    radius: radius,
    height: auto,
    inset: inset,
    align(horizon, if dropdown {
      context {
        let height = measure(body).height
        let height = if height < pill-height {
          pill-height
        } else {
          height
        }
        let width = pill-inset-x
        stack(dir: ltr, spacing: pill-spacing, box(height: height, text(final-text-color, body)), image(icons.dropdown-arrow, height: 2mm))
      }
    } else {
      context [
        #let height = measure(body).height
        #let height = if height < pill-height {
          pill-height
        } else {
          height
        }
        #box(height: height, text(final-text-color, body))
      ]
    }),
  )
}

// Öffentliche Basis-Funktion für alle Pills (nutzt State)
#let _pill-base(
  fill: white,
  stroke: auto,
  text-color: auto,
  radius: 50%,
  inset: 0mm,
  height: auto,
  dropdown: false,
  body,
) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  _pill-base-internal(
    fill: fill,
    stroke: stroke,
    text-color: text-color,
    radius: radius,
    inset: inset,
    height: height,
    dropdown: dropdown,
    body,
    colors: colors,
    stroke-thickness: stroke-thickness,
  )
}

// Weiße Input-Pills (feste Höhe 8.4mm, keine Insets)
// Hinweis: Textfarbe wird abhängig von Theme/Hintergrund automatisch gewählt.
#let pill-round(body, stroke: auto, inset: (x: 1.3 * pill-inset-x, y: 1mm), fill: white, text-color: auto) = _pill-base(
  fill: fill,
  stroke: stroke,
  text-color: text-color,
  radius: 50%,
  inset: inset,
  height: auto,
  dropdown: false,
  body,
)

// Farbige Reporter-Pills (auto-höhe, reduzierte Insets, Mindesthöhe 0.8 * block-height)
#let pill-reporter(body, fill: white, stroke: auto, text-color: auto, dropdown: false, inline: false) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  // Mindesthöhe für Reporter
  let min-height = 0.8 * block-height

  // Body mit Mindesthöhe vorbereiten
  let prepared-body = context {
    let measured = measure(body)
    if measured.height < min-height {
      box(height: min-height, align(horizon, body))
    } else {
      body
    }
  }

  _pill-base-internal(
    fill: fill,
    stroke: stroke,
    text-color: text-color,
    radius: 50%,
    inset: if inline {
      (x: pill-inset-x, y: 0.7 * pill-inset-y)
    } else {
      (x: 0.4 * pill-inset-x, y: 0.7 * pill-inset-y)
    },
    height: if inline { 100% } else { auto },
    dropdown: dropdown,
    prepared-body,
    colors: colors,
    stroke-thickness: stroke-thickness,
  )
}

// Rechteckige Dropdown-Pills (auto-höhe, reduzierte Insets)
#let pill-rect(body, fill: white, stroke: auto, text-color: auto, dropdown: false, inline: false) = _pill-base(
  fill: fill,
  stroke: stroke,
  text-color: text-color,
  radius: 10%,
  inset: (x: 0.75 * pill-inset-x, y: if inline { 0mm } else { 0.75 * pill-inset-y }),
  height: 0.5 * pill-height,
  dropdown: dropdown,
  body,
)

// Farb-Pills (für Farbauswahl)
#let pill-color(body, fill: white) = context {
  let options = scratch-block-options.get()
  let stroke-thickness = get-stroke-from-options(options)

  _pill-base(
    fill: fill,
    stroke: white + stroke-thickness,
    text-color: auto,
    radius: 50%,
    inset: 0mm,
    height: 1.2 * pill-height,
    dropdown: false,
    body,
  )
}

// Alte pill() Funktion als Wrapper für Kompatibilität
#let pill(..args, type: "round", stroke: auto, text-color: auto, body, dropdown: false, inset: auto, height: auto, fill: white) = {
  if type == "round" {
    pill-round(body, stroke: stroke, fill: fill, text-color: text-color)
  } else if type == "single" or type == "reporter" {
    pill-reporter(body, fill: fill, stroke: stroke, text-color: text-color, dropdown: dropdown)
  } else if type == "rect" {
    pill-rect(body, fill: fill, stroke: stroke, text-color: text-color, dropdown: dropdown)
  } else if type == "color" {
    pill-color(body, fill: fill)
  }
}
// ------------------------------------------------
// 8) Wert-/Content-Helfer
// ------------------------------------------------
// Helper-Funktion: Wert oder Content
// Wandelt einfache Werte (String, Int, Float) in Pills um,
// lässt Content (Blöcke, Reporter, etc.) unverändert
#let zahl-oder-content(value, colorschema) = {
  let value-type = type(value)
  if value-type == str or value-type == int or value-type == float {
    context {
      let options = scratch-block-options.get()
      let stroke-thickness = get-stroke-from-options(options)

      pill-round(str(value), stroke: colorschema.tertiary + stroke-thickness, inset: (x: 1.3 * pill-inset-x, y: 0.5mm))
    }
  } else {
    value
  }
}

// ------------------------------------------------
// 9) Blockpfade & Rendering (scratch-block, bedingung)
// ------------------------------------------------
#let block-path(height, width, type, top-notch: true, bottom-notch: true) = {
  return (
    ereignis: (
      curve.line((0mm, 0mm), relative: true),
      curve.quad((hat-cp1-x, -hat-cp1-y), (block-height, -hat-cp1-y), relative: true),
      curve.quad((hat-cp2-x, 0mm), (block-height, hat-cp1-y), relative: true),
      curve.line((width - 2 * block-height - corner-radius, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, height - 2 * corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + corner-radius + notch-spacing + notch-total-width, 0mm), relative: true),
      ..notch-path,
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, -corner-radius), relative: true),
      curve.close(),
    ),
    definiere: (
      curve.quad((0mm, -5 * corner-radius), (5 * corner-radius, -5 * corner-radius), relative: true),
      curve.line((width - 10 * corner-radius, 0mm), relative: true),
      curve.quad((5 * corner-radius, 0mm), (5 * corner-radius, 5 * corner-radius), relative: true),
      curve.line((0mm, height - corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + corner-radius + notch-total-width + notch-spacing, 0mm), relative: true),
      ..notch-path,
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, -corner-radius), relative: true),
      curve.close(),
    ),
    anweisung: (
      curve.line((0mm, -block-offset-y + corner-radius), relative: true),
      curve.quad((0mm, -corner-radius), (corner-radius, -corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..if top-notch {
        (inverted-notch-path,)
      } else {
        (curve.line((notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((width - block-left-indent - notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, +block-offset-y - corner-radius), relative: true),
      curve.line((0mm, height - block-offset-y - corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, -corner-radius), relative: true),
      curve.close(),
    ),
    bedingung: (
      curve.move((0.5 * height, 0mm)),
      curve.line((width - 0.5 * height, 0mm), relative: true),
      curve.line((0.5 * height, -0.5 * height), relative: true),
      curve.line((-0.5 * height, -0.5 * height), relative: true),
      curve.line((-width + 0.5 * height, 0mm), relative: true),
      curve.line((-0.5 * height, 0.5 * height), relative: true),
      curve.line((0.5 * height, 0.5 * height), relative: true),
    ),
    loop-header: (
      curve.line((0mm, -block-offset-y + corner-radius), relative: true),
      curve.quad((0mm, -corner-radius), (corner-radius, -corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..inverted-notch-path,
      curve.line((width - block-left-indent - notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, +block-offset-y - corner-radius), relative: true),
      curve.line((0mm, height - block-offset-y - corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + 3 * notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, corner-radius), relative: true),
    ),
    loop-footer: (
      curve.quad((0mm, corner-radius), (corner-radius, corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..inverted-notch-path,
      curve.line((width - block-left-indent - 3 * notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, 3mm), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + 1 * notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, -corner-radius), relative: true),
      curve.close(),
    ),
    falls-header: (
      curve.line((0mm, -block-offset-y + corner-radius), relative: true),
      curve.quad((0mm, -corner-radius), (corner-radius, -corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..if top-notch {
        (inverted-notch-path,)
      } else {
        (curve.line((notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((width - block-left-indent - notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, +block-offset-y - corner-radius), relative: true),
      curve.line((0mm, height - block-offset-y - corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + 3 * notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, corner-radius), relative: true),
    ),
    falls-middle: (
      curve.quad((0mm, corner-radius), (corner-radius, corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..if top-notch {
        (inverted-notch-path,)
      } else {
        (curve.line((notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((width - block-left-indent - 3 * notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, height - corner-radius), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + 3 * notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, corner-radius), relative: true),
    ),
    falls-footer: (
      curve.quad((0mm, corner-radius), (corner-radius, corner-radius), relative: true),
      curve.line((notch-spacing - corner-radius, 0mm), relative: true),
      ..if top-notch {
        (inverted-notch-path,)
      } else {
        (curve.line((notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((width - block-left-indent - 3 * notch-spacing - notch-reserved-space, 0mm), relative: true),
      curve.quad((corner-radius, 0mm), (corner-radius, corner-radius), relative: true),
      curve.line((0mm, 3mm), relative: true),
      curve.quad((0mm, corner-radius), (-corner-radius, corner-radius), relative: true),
      curve.line((-width + block-left-indent + 1 * notch-spacing + notch-reserved-space, 0mm), relative: true),
      ..if bottom-notch {
        (notch-path,)
      } else {
        (curve.line((-notch-total-width, 0mm), relative: true),)
      }.flatten(),
      curve.line((-notch-spacing + corner-radius, 0mm), relative: true),
      curve.quad((-corner-radius, 0mm), (-corner-radius, -corner-radius), relative: true),
      curve.close(),
    ),
  ).at(type, default: "anweisung")
}


// Interne Funktion für Scratch-Blöcke (akzeptiert explizite colors und stroke-thickness)
#let scratch-block-internal(colorschema, type: "ereignis", top-notch: true, bottom-notch: true, dx: 0mm, dy: 0mm, body, children-array, colors, stroke-thickness) = block(
  above: 0em + if (type == "ereignis" or type == "definiere") { 6mm } else { 0mm },
  below: 0mm + if (type == "ereignis" or type == "definiere") { 6mm } else { 0mm },
)[
  #set text(font: "Helvetica Neue", colors.text-color, weight: 500)
  #let content-box = align(horizon, box(
    inset: content-inset,
    height: if type == "definiere" { 1.5 * block-height } else { auto },
    [
      #context [
        #let content-height = measure(body).height
        #let min-height = 0.75 * block-height
        #box(body, height: calc.max(content-height, min-height))
      ]
    ],
  ))
  #context [
    #let (width, height) = measure(content-box)
    #place(top + left, dx: dx, dy: dy)[
      #curve(
        fill: colorschema.primary,
        stroke: (paint: colorschema.tertiary, thickness: stroke-thickness),
        ..block-path(height, width, type, bottom-notch: bottom-notch, top-notch: top-notch),
      )
    ]
  ]
  #content-box
  #v(dy, weak: true)
  #if children-array.len() != none {
    for child in children-array {
      if std.type(child) == content {
        child
      }
    }
  }
]

// Öffentliche Funktion für Scratch-Blöcke (nutzt State)
#let scratch-block(colorschema: auto, type: "ereignis", top-notch: true, bottom-notch: true, dx: 0mm, dy: 0mm, body, ..children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  let final-colorschema = if colorschema == auto { colors.bewegung } else { colorschema }

  scratch-block-internal(
    final-colorschema,
    type: type,
    top-notch: top-notch,
    bottom-notch: bottom-notch,
    dx: dx,
    dy: dy,
    body,
    children.pos(),
    colors,
    stroke-thickness,
  )
}

// Bedingung (Diamant-Form für boolesche Werte)
#let bedingung(colorschema: auto, type: "bedingung", body, nested: false) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  let final-colorschema = if colorschema == auto { colors.steuerung } else { colorschema }

  set text(font: "Helvetica Neue", colors.text-color, weight: 500)
  box([
    // nested kann bool (beide Seiten gleich) oder (left, right) array sein
    #let nested-type = std.type(nested)
    #let (nested-left, nested-right) = if nested-type == array {
      (nested.at(0), nested.at(1))
    } else {
      (nested, nested)
    }
    #let x-inset-left = if nested-left { -0.5 } else { -0.1 }
    #let x-inset-right = if nested-right { -0.25 } else { -0.05 }
    #let content-box = if body != [] {
      let body = if std.type(body) != array { (body,) } else { body }
      box(inset: (left: pill-inset-x * x-inset-left, right: pill-inset-x * x-inset-right, y: pill-inset-y), align(horizon, [
        #grid(
          columns: (body.len() * 2 + 1) * (auto,),
          column-gutter: 1fr,
          align: center + horizon,
          h(pill-spacing),
          ..body.map(x => { (x, h(0.25em)) }).flatten(),
          h(pill-spacing),
        )
      ]))
    } else { box(height: pill-height, width: pill-height) }

    #context [
      #let (width, height) = measure(content-box, height: auto)
      #let height = if height < block-height and body != [] {
        block-height * 0.9
      } else if height < block-height {
        pill-height
      } else {
        height
      }
      #place(bottom + left)[
        #if body != [] {
          curve(
            fill: final-colorschema.primary,
            stroke: (paint: final-colorschema.tertiary, thickness: stroke-thickness),
            ..block-path(height, width, type),
          )
        } else {
          curve(
            fill: final-colorschema.tertiary,
            stroke: none,
            ..block-path(pill-height, pill-height, type),
          )
        }
      ]
      #box(width: width + 0.5 * height, height: height, align(horizon, content-box))
    ]
  ])
}

// ------------------------------------------------
// 10) Kategorie-Wrapper (bewegung, aussehen, klang, fühlen, steuerung, variablen, listen, eigene)
// ------------------------------------------------
#let bewegung(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.bewegung,
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}

#let aussehen(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.aussehen,
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}

#let klang(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.klang,
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}

#let fühlen(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.fühlen,
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}

#let steuerung(body, bottom-notch: true) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.steuerung,
    type: "anweisung",
    dy: block-offset-y,
    bottom-notch: bottom-notch,
    body,
  )
}

#let variablen(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.variablen,
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}

#let listen(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.listen,
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}

#let eigene(body, dark: false) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: if dark {
      (primary: colors.eigene.secondary, tertiary: colors.eigene.tertiary)
    } else {
      colors.eigene
    },
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}

#let malstift(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.malstift,
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}


// ------------------------------------------------
// 11) Ereignisse
// ------------------------------------------------
#let ereignis(body, children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "ereignis",
    body,
    children,
  )
}

// Wenn die grüne Flagge angeklickt wird
#let ereignis-grüne-flagge(children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "ereignis",
    grid(
      columns: 3,
      gutter: 0.5em,
      align: horizon,
      [Wenn], box(image(icons.green-flag)), [angeklickt wird],
    ),
    children,
  )
}

// Wenn Taste <taste> gedrückt wird
#let ereignis-taste(taste, children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "ereignis",
    stack(dir: ltr, spacing: 1.5mm, "Wenn", pill-rect(taste, fill: colors.ereignisse.primary, stroke: colors.ereignisse.tertiary + stroke-thickness, dropdown: true), "gedrückt wird"),
    children,
  )
}

// Wenn die Figur angeklickt wird
#let ereignis-figur-angeklickt(children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "ereignis",
    stack(dir: ltr, spacing: 1.5mm, "Wenn diese Figur angeklickt wird"),
    children,
  )
}

// Wenn das Bühnenbild zu <name> wechselt
#let ereignis-bühnenbild-wechselt-zu(taste, children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "ereignis",
    stack(dir: ltr, spacing: 1.5mm, "Wenn das Bühnenbild zu", pill-rect(taste, fill: colors.ereignisse.primary, stroke: colors.ereignisse.tertiary + stroke-thickness, dropdown: true), "wechselt"),
    children,
  )
}

// Wenn <Element> einen Schwellwert überschreitet (z. B. Lautstärke > 10)
#let ereignis-über(element, wert, children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "ereignis",
    stack(dir: ltr, spacing: 1.5mm, "Wenn", pill-rect(element, fill: colors.ereignisse.primary, stroke: colors.ereignisse.tertiary + stroke-thickness, dropdown: true), ">", zahl-oder-content(
      wert,
      colors.ereignisse,
    )),
    children,
  )
}

// Wenn ich eine Nachricht empfange
#let ereignis-nachricht-empfangen(nachricht, children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "ereignis",
    stack(dir: ltr, spacing: 1.5mm, "Wenn ich", pill-rect(nachricht, fill: colors.ereignisse.primary, stroke: colors.ereignisse.tertiary + stroke-thickness, dropdown: true), "empfange"),
    children,
  )
}

#let ereignis-anweisung(body) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.ereignisse,
    type: "anweisung",
    dy: block-offset-y,
    body,
  )
}

#let sende-nachricht-an-alle(nachricht, wait: false) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  ereignis-anweisung(
    stack(dir: ltr, spacing: 1.5mm, "sende", pill-reporter(nachricht, fill: colors.ereignisse.secondary, stroke: colors.ereignisse.tertiary + stroke-thickness, dropdown: true, inline: true), if wait {
      "an alle und warte"
    } else { "an alle" }),
  )
}

// Wenn ich als Klon entstehe (Ereignis-Form mit Steuerung-Farben)
#let wenn-ich-als-klon-entstehe(children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.steuerung,
    type: "ereignis",
    [Wenn ich als Klon entstehe],
    children,
  )
}

#let erstelle-klon-von(element: "mir selbst") = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  steuerung(
    stack(dir: ltr, spacing: 1.5mm, "erstelle Klon von", pill-reporter(element, fill: colors.steuerung.secondary, stroke: colors.steuerung.tertiary + stroke-thickness, dropdown: true, inline: true)),
  )
}

// ------------------------------------------------
// 12) Reporter (generisch + je Kategorie)
// ------------------------------------------------
// Reporter-Blöcke (Werte)
// Allgemeine Reporter-Funktion für alle Kategorien
// Optional: dropdown-content rendert einen In-Reporter-Dropdown rechts.
#let reporter(colorschema: auto, body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)
  let final-colorschema = if colorschema == auto { colors.aussehen } else { colorschema }

  pill-reporter(
    fill: final-colorschema.primary,
    stroke: final-colorschema.tertiary + stroke-thickness,
    text-color: colors.text-color,
    if dropdown-content != none {
      pill-round(fill: none, stroke: none, text-color: colors.text-color, inset: (x: 0mm, y: 0.5mm), stack(dir: ltr, spacing: pill-spacing, box(inset: (left: pill-inset-x), body), pill-reporter(
        dropdown-content,
        fill: final-colorschema.secondary,
        stroke: final-colorschema.tertiary + stroke-thickness,
        text-color: colors.text-color,
        dropdown: true,
        inline: true,
      )))
    } else {
      pill-round(body, fill: none, stroke: none, text-color: colors.text-color, inset: (x: 1.5mm, y: 0.5mm))
    },
  )
}

// Bewegungs-Reporter
#let bewegung-reporter(body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  reporter(
    colorschema: colors.bewegung,
    body,
    dropdown-content: dropdown-content,
  )
}

// Aussehen-Reporter
#let aussehen-reporter(body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  reporter(
    colorschema: colors.aussehen,
    body,
    dropdown-content: dropdown-content,
  )
}

// Klang-Reporter
#let klang-reporter(body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  reporter(
    colorschema: colors.klang,
    body,
    dropdown-content: dropdown-content,
  )
}

// Fühlen-Reporter
#let fühlen-reporter(body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  reporter(
    colorschema: colors.fühlen,
    body,
    dropdown-content: dropdown-content,
  )
}

// Variablen-Reporter
#let variablen-reporter(body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  reporter(
    colorschema: colors.variablen,
    body,
    dropdown-content: dropdown-content,
  )
}

// Listen-Reporter
#let listen-reporter(body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  reporter(
    colorschema: colors.listen,
    body,
    dropdown-content: dropdown-content,
  )
}

// Eigene-Reporter (für Platzhalter/Reporter in eigenen Blöcken)
#let eigene-reporter(body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  reporter(
    colorschema: colors.eigene,
    body,
    dropdown-content: dropdown-content,
  )
}

// Malstift-Reporter
#let malstift-reporter(body, dropdown-content: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  reporter(
    colorschema: colors.malstift,
    body,
    dropdown-content: dropdown-content,
  )
}

// Parameter-Reporter (pink) für eigene Block-Parameter
// Nutzung: #parameter("Anzahl")
// Verwendet die gleichen Insets wie eigene-eingabe() für konsistente Höhe
#let parameter(name) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  pill-round(name, fill: colors.eigene.primary, stroke: colors.eigene.tertiary + stroke-thickness)
}

// ------------------------------------------------
// 13) Kontrollstrukturen (Grundgerüst + Blöcke)
// ------------------------------------------------
// Gemeinsame Hilfsfunktion für Schleifen- und Bedingungs-Blöcke
#let conditional-block(
  header-label,
  first-body: none, // Der erste Körper (Schleifeninhalt oder "dann"-Zweig)
  middle-notch: false,
  middle-label: none, // Das "sonst"-Label (nur bei falls-Block)
  second-body: none, // Der zweite Körper (nur "sonst"-Zweig bei falls-Block)
  bottom-notch: true,
  first-inset-notch: true,
  second-inset-notch: true,
  block-type: "loop", // "loop" oder "falls"
) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  block(
    above: 0em,
    below: 0mm,
  )[
    #set text(font: "Helvetica Neue", colors.text-color, weight: 500)

    #let first-body = if first-body not in (none, []) {
      first-body
    } else { box(height: 0.5 * block-height, width: 0cm) }

    #let second-body = if second-body not in (none, []) {
      second-body
    } else { box(height: 0.5 * block-height, width: 0cm) }

    #let header-box = align(horizon, box(inset: content-inset, height: auto, header-label))
    #let middle-box = if middle-label != none {
      align(horizon, box(inset: content-inset, height: 0.5 * block-height + corner-radius, middle-label))
    } else { none }

    #context [
      #let header-box-sizes = measure(header-box)
      #let middle-box-sizes = if middle-box != none { measure(middle-box) } else { none }

      #let header-height = if header-box-sizes.height > block-height {
        header-box-sizes.height
      } else {
        block-height
      }

      #let middle-height = if middle-box-sizes != none {
        if middle-box-sizes.height > 0.5 * block-height {
          middle-box-sizes.height
        } else {
          block-height
        }
      } else { 0mm }

      #let first-body-sizes = measure(first-body)
      #let second-body-sizes = measure(second-body)

      #let first-height = if first-body != none { first-body-sizes.height - corner-radius - corner-radius } else { 0mm }
      #let second-height = if second-body != none { second-body-sizes.height - corner-radius - corner-radius } else { 0mm }

      // Pfad-Präfix basierend auf Block-Typ
      #let path-prefix = if block-type == "falls" { "falls" } else { "loop" }

      // Header und Körper zeichnen
      #place(top + left, dy: block-offset-y)[
        #curve(
          fill: colors.steuerung.primary,
          stroke: (paint: colors.steuerung.tertiary, thickness: stroke-thickness),
          ..block-path(header-height, header-box-sizes.width, path-prefix + "-header"),
          curve.line((0mm, first-height), relative: true),
          ..if middle-label != none {
            (
              ..block-path(middle-height, header-box-sizes.width, path-prefix + "-middle", bottom-notch: first-inset-notch),
              curve.line((0mm, second-height), relative: true),
            )
          },
          ..block-path(header-height, header-box-sizes.width, path-prefix + "-footer", bottom-notch: bottom-notch, top-notch: second-inset-notch),
        )
      ]
      #if block-type == "loop" {
        place(bottom + left, dx: header-box-sizes.width - 0.5 * block-height)[
          #image(icons.repeat, height: 0.5 * block-height)
        ]
      }

      // Content rendern - jedes Element mit seiner eigenen Höhe
      #box(height: header-height, header-box)
      #block(
        above: 0em,
        below: 0em,
        inset: (bottom: if middle-label == none { 3mm + 2 * corner-radius } else { corner-radius }),
        move(dx: 2 * notch-spacing, first-body),
      )
      #if middle-label != none {
        box(height: middle-height, middle-box)
        block(
          above: 0em,
          below: 0em,
          inset: (bottom: 3mm + 2 * corner-radius),
          move(dx: 2 * notch-spacing, second-body),
        )
      }
    ]
  ]
}

// Wiederhole n-mal
#let wiederhole(anzahl: 10, body: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  conditional-block(
    [#stack(dir: ltr, spacing: 1.5mm, "wiederhole", zahl-oder-content(anzahl, colors.steuerung), "mal")],
    first-body: body,
  )
}

// Wiederhole bis Bedingung
#let wiederhole-bis(bdg, body: none) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  conditional-block(
    [#stack(dir: ltr, spacing: 1.5mm, "wiederhole bis", if bdg != [] { bdg } else { bedingung(colorschema: colors.steuerung, []) })],
    first-body: body,
  )
}

// Wiederhole fortlaufend (Endlosschleife)
#let wiederhole-fortlaufend(body) = conditional-block(
  [#stack(dir: ltr, spacing: 1.5mm, "wiederhole fortlaufend")],
  first-body: body,
  bottom-notch: false,
)

// Falls-Dann-Sonst Block
#let falls(bdg, dann: none, sonst: none, dann-end: false, sonst-end: false) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  conditional-block(
    [#stack(dir: ltr, spacing: 1.5mm, "falls", if bdg != [] { bdg } else { bedingung(colorschema: colors.steuerung, []) }, ", dann")],
    first-body: dann,
    middle-label: if sonst != none { [#stack(dir: ltr, spacing: 1.5mm, "sonst")] } else { none },
    second-body: sonst,
    block-type: "falls",
    first-inset-notch: not sonst-end,
    second-inset-notch: not dann-end,
  )
}


// ------------------------------------------------
// 20) Eigene Blöcke
// ------------------------------------------------
// Eigene Blöcke
// Weißer Argument-Platzhalter für eigene Blöcke
#let eigene-eingabe(text) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  pill-round(text, stroke: colors.eigene.tertiary + stroke-thickness)
}

// Erzeugt einen eigenen Anweisungsblock mit Text und Platzhaltern.
// Verwendung:
//   #let mein-block = eigener-block("drehe", eigene-eingabe("Grad"))
//   #mein-block(45)[ ... ]
#let eigener-block(..body) = {
  let items = body.pos()
  return (dark: true, ..values) => context {
    let options = scratch-block-options.get()
    let colors = get-colors-from-options(options)
    let stroke-thickness = get-stroke-from-options(options)

    eigene(dark: dark, {
      let values = values.pos()
      stack(
        dir: ltr,
        spacing: 1.5mm,
        ..if values.len() == 0 {
          for item in items {
            if std.type(item) == str {
              (item,)
            } else if std.type(item) == dictionary {
              (pill-round(stroke: colors.eigene.tertiary, fill: colors.eigene.primary, text-color: colors.text-color, item.name),)
            } else {
              (pill-round(stroke: colors.eigene.tertiary, fill: colors.eigene.primary, text-color: colors.text-color, str("number or text")),)
            }
          }
        } else {
          let key = 0
          for item in items {
            if std.type(item) == str {
              (item,)
            } else {
              (zahl-oder-content(values.at(calc.rem(key, values.len())), colors.eigene),)
              key += 1
            }
          }
        },
      )
    })
  }
}

// Kopf einer eigenen Block-Definition inkl. Label (Signatur)
#let definiere(block-label, ..children) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)

  scratch-block(
    colorschema: colors.eigene,
    type: "definiere",
    dy: 2.5 * corner-radius,
    stack(
      dir: ltr,
      spacing: 1.5mm,
      "Definiere",
      block-label(dark: true),
    ),
    ..children,
  )
}

// ------------------------------------------------
// Visuelle Variablen-Darstellung (Monitor wie in Scratch)
// ------------------------------------------------
// Kernfunktion (sprachneutral). Lokalisierte Aliase in lang/de.typ (#variable)
// und lang/en.typ (#variable-display) rufen diese Funktion auf.
#let variable-monitor(name: "Variable", value: 0) = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  box(
    fill: rgb("#E5F0FF"),
    stroke: (paint: gray, thickness: 0.5pt),
    radius: 5pt,
    inset: (x: 5pt, y: 3pt),
  )[
    #set text(size: 9pt, font: "Helvetica Neue", weight: 500)
    #grid(
      columns: (auto, auto),
      column-gutter: 4pt,
      align: left + horizon,
      // Variablenname
      text(fill: rgb("#4C4C4C"), weight: 600, name),
      // Wert in oranger Pill (wie Variablen-Reporter / Variablen-Farbe)
      box(
        fill: colors.variablen.primary,
        stroke: colors.variablen.tertiary + stroke-thickness,
        radius: 4pt,
        inset: (x: 5pt, y: 2pt),
        text(fill: colors.text-color, str(value)),
      ),
    )
  ]
}

// ------------------------------------------------
// Visuelle Listen-Darstellung (Monitor wie in Scratch)
// ------------------------------------------------
// Kernfunktion (sprachneutral). Lokalisierte Aliase in lang/de.typ (#liste)
// und lang/en.typ (#list) rufen diese Funktion auf.
#let list-monitor(name: "List", items: (), width: 4cm, height: auto, length-label: "Length") = context {
  let options = scratch-block-options.get()
  let colors = get-colors-from-options(options)
  let stroke-thickness = get-stroke-from-options(options)

  // Berechne Länge
  let len = items.len()

  box(
    width: width,
    fill: rgb("#E5F0FF"),
    stroke: (paint: gray, thickness: 0.5pt),
    radius: 5pt,
    clip: true,
  )[
    #set text(size: 9pt, font: "Helvetica Neue", weight: 500)
    // Kopfzeile mit Namen
    #box(
      fill: white,
      width: 100%,
      inset: 5pt,
      align(center)[
        #text(fill: rgb("#4C4C4C"), weight: 600, name)
      ],
    )
    // Listenelemente
    #box(height: height, clip: true, inset: (x: 2mm))[
      #grid(
        columns: (auto, 1fr),
        column-gutter: 8pt,
        row-gutter: 2pt,
        align: left + horizon,
        ..items
          .enumerate()
          .map(((index, item)) => {
            (
              grid.cell(str(index + 1)),
              grid.cell(box(
                width: 100%,
                height: 5mm,
                fill: colors.listen.primary,
                stroke: colors.listen.tertiary + stroke-thickness,
                radius: 3pt,
                inset: 3pt,
                align(left, text(fill: colors.text-color, item)),
              )),
            )
          })
          .flatten(),
      )
    ]
    // Fußzeile mit Länge
    #box(
      fill: white,
      width: 100%,
      align(center)[
        #grid(
          columns: (auto, 1fr, auto),
          column-gutter: 5pt,
          inset: 5pt,
          align: (left + horizon, center + horizon, right + horizon),
          text(fill: rgb("#4C4C4C"), size: 8pt, "+"), text(fill: rgb("#4C4C4C"), size: 8pt, weight: 600, [#length-label: #len]), text(fill: rgb("#4C4C4C"), size: 8pt, "="),
        )
      ],
    )
  ]
}
