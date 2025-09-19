#let d_ew_bewertung() = box(width: 100%)[
	#set align(center)
	= Bewertung <bewertung>

	#let cell-highlight-color = luma(240)
	#locate(loc => {
		let _ew_cells() = {
			__s_aufgaben.final(loc)
				.map(aufg => {
					let cells = ()
					cells.push(cellx(fill: cell-highlight-color)[*#{aufg.nummer}*])
					for i in range(aufg.teile) {
						cells.push(cellx(fill: white)[#{aufg.nummer}.#{numbering("1", i + 1)}])
					}
					cells
				})
				.flatten()
		}
		let _ew_cells-m-punkte() = {
			__s_aufgaben.final(loc)
				.map(aufg => {
					let cells-m-punkte = ()
					cells-m-punkte.push(cellx(fill: cell-highlight-color)[*#d_ew_punkte(aufg.nummer, teil:none)*])
					for i in range(aufg.teile) {
						cells-m-punkte.push(cellx(fill: white)[#d_ew_punkte(aufg.nummer, teil:i + 1)])
					}
					cells-m-punkte
				})
				.flatten()
		}
		let _ew_cells-punkte() = {
			__s_aufgaben.final(loc)
				.map(aufg => {
					let cells-punkte = ()
					cells-punkte.push(cellx(fill: cell-highlight-color)[])
					for i in range(aufg.teile) {
						cells-punkte.push(cellx(fill: white)[])
					}
					cells-punkte
				})
				.flatten()
		}
		align(center,tablex(
			columns: (1.9cm, ..(_ew_cells().len()) * (auto,), 1.5cm),
			inset: 7pt,
			stroke: 1pt+black,
			align:  (col, row) => {
				if col == 0 {left+horizon}
				else {
					horizon+center
				}
			},
			
			cellx(fill: cell-highlight-color)[*Aufgabe*],
			.._ew_cells(),
			cellx(fill: cell-highlight-color)[*Insgesamt*:], 
			cellx(fill: cell-highlight-color)[*mögl. \ Punkte*],
			.._ew_cells-m-punkte(),
			cellx(fill: cell-highlight-color)[*#d_ew_gesamt()*], 
			cellx(fill: cell-highlight-color)[*Punkte*],
			.._ew_cells-punkte(),
			cellx(fill: cell-highlight-color)[#v(6mm)], 
		))
	})
]