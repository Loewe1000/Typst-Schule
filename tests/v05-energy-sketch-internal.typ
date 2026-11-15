// `internal` trägt genau die elf Helfer – weder `draw` (CeTZ) noch die Prüffunktionen.
// erwartet: clamp-length, column-frame, column-geometry, column-grid, column-label, column-label-line, energy-column, normalize-labels, resolve-layout, resolve-style, rows
// nicht: draw
// nicht: fail
// nicht: check-type
#import "@schule/energy-sketch:0.5.0" as es
#set page(width: 40cm)

#dictionary(es.internal).keys().sorted().join(", ")
