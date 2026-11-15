// Interne Namen von typlace. Was hier steht, ist keine zugesicherte
// Schnittstelle und darf sich in jeder Version ändern; Dokumente benutzen
// es nicht. Zugriff: `typlace.internal.<name>`.

#import "geometry.typ": (
  analyze-layout, auto-chars, desk-chars, free-chars, is-desk, is-free, is-seat, is-table, layout-matrix, table-cells,
  table-chars, table-ids,
)
#import "data.typ": check-students, parse-students
#import "scoring.typ": (
  build-problem, normalize-constraints, score-plan, seat-of-students, statistics, student-points, student-score,
  swap-delta,
)
#import "wasm.typ": encode, wasm-search
