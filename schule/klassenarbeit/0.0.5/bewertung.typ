#import "@preview/tablex:0.0.5": *
#import "@schule/klausurboegen:0.0.2": *

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %       Hilfsfunktionen        %
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#let __foreach(
	s,
	func,
	filter: elem => true,
	final: true,
	loc: none,
) = {
	assert(type(s) == "state")
	assert(type(func) == "function")

	let it = l => {
		let data = none
		if final {
			data = s.final(l)
		} else {
			data = s.at(l)
		}
		data = data.filter(filter)

		let i = 0
		for elem in data {
			func(i, elem, data.len())
			i += 1
		}
	}

	if loc == none {
		locate(it)
	} else {
		assert(type(loc) == "location")
		it(loc)
	}
}

#let __s_erwartungen    = state("erwartungen", ())
#let __s_aufgaben       = state("aufgaben", ())
#let __foreach_erw = __foreach.with(__s_erwartungen, final:true)

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %     Erwartungshorizonte      %
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#let __d__erwartung(text, punkte, last) = {
	if last [#text (#punkte)]
	else [#text (#punkte)\ ]
}
#let d_ew_erwartungen(aufg, teil: 0, format: __d__erwartung) = {
	__foreach_erw(
		filter: erw => {
				erw.aufgabe == aufg and (
					teil == none or teil == erw.teil
				)
			},
		(i, erw, count) => {
			format(erw.text, erw.punkte, i == count - 1)
		}
	)
}
#let d_ew_text = d_ew_erwartungen.with(format:(t, p, last) => {
	if last [#sym.dots #t]
	else [#sym.dots #t\ ]
})

#let d_ew_punkte(aufg, teil: 0, format: p=>if p > 0 [#p] else []) = {
	locate(loc => {
		let p = __s_erwartungen.final(loc)
			.filter(erw => {
				erw.aufgabe == aufg and (
					teil == none or teil == erw.teil
				)
			})
			.fold(0, (p, erw) => p + erw.punkte)
		format(p)
	})
}

#let d_ew_gesamt( format: p=>[#p] ) = locate(loc => {
	format(__s_erwartungen.final(loc)
		.fold(0, (p, erw) => p + erw.punkte))
})

#let ew_verteilung_oberstufe = (
	.0,
	.20, .27, .33,
	.40, .45, .50,
	.55, .60, .65,
	.70, .75, .80,
	.85, .90, .95,
)
#let ew_namen_oberstufe = (
	0,
	1,2,3,
	4,5,6,
	7,8,9,
	10,11,12,
	13,14,15
)

#let ew_verteilung_unterstufe = (
	.0,
	.20, .27, .33,
	.40, .45, .50,
	.55, .60, .65,
	.70, .75, .80,
	.85, .90, .95,
)
#let ew_namen_unterstufe = (
	"6",
	"5-", "5", "5+",
	"4-", "4", "4+",
	"3-", "3", "3+",
	"2-", "2", "2+",
	"1-", "1", "1+",
)

#let ew_verteilung_ohne_tendenz = (
	.0,
	.20,
	.40,
	.55,
	.70,
	.85,
)
#let ew_namen_ohne_tendenz = (
	"6",
	"5",
	"4",
	"3",
	"2",
	"1",
)


#let d_ew_notenspiegel(
	verteilung: ew_verteilung_oberstufe,
	namen:      ew_namen_oberstufe,
) = {
	locate(loc => {
		assert(
			verteilung.len() == namen.len(),
			message:"Die Verteilung und Namen müssen gleichviele Elemente enthalten."
		)

		let punkte = __s_erwartungen.final(loc)
			.fold(0, (p, erw) => p + erw.punkte)

		let cells = ([Note],)
		for note in namen.rev() {
			cells.push([#note])
		}
		cells.push([Prozent])
		for schwelle in verteilung.rev() {
			cells.push([#{calc.round(schwelle*100)}%])
		}
		cells.push([Schwelle])
		for schwelle in verteilung.rev() {
			cells.push([#{calc.floor(punkte*schwelle)}])
		}

		set text(size: 8pt)
		table(
			columns: verteilung.len() + 1,
			//inset: 5pt,
			fill: (col, row) => {
				white
			},
			align: center + horizon,
			..cells
		)
	})

}

#let d_ew_unterstufe() = [
	#pagebreak()
	= Erwartungshorizont <erwartungshorizont>

	#let cell-highlight-color = luma(240)
	#locate(loc => {
		let _ew_cells() = {
			__s_aufgaben.final(loc)
				.map(aufg => {
					let cells = ([*#{aufg.nummer}*],
					[#d_ew_text(aufg.nummer)],
					[#d_ew_punkte(aufg.nummer)],
					)

					for i in range(aufg.teile) {
						cells.push(numbering("a)", i + 1))
						cells.push(d_ew_text(aufg.nummer, teil:i + 1))
						cells.push(d_ew_punkte(aufg.nummer, teil:i + 1))
					}

					cells
				})
				.flatten()
		}

		tablex(
			columns: (auto, 1fr, auto),
			inset: 7pt,
			align:  (col, row) => {
				if col in (0, 2, 3) { center + horizon }
				else if row == 0 {
					horizon
				}
				else { left }
			},
			cellx(fill: cell-highlight-color)[*Aufg.*], cellx(fill: cell-highlight-color)[Die Schülerin / Der Schüler #sym.dots.h],
			cellx(fill: cell-highlight-color)[*mögl. \ Punkte*],
			.._ew_cells(),
			cellx(fill: cell-highlight-color)[],  cellx(fill: cell-highlight-color)[
				#set align(right)
				*Insgesamt*:
			], cellx(fill: cell-highlight-color)[*#d_ew_gesamt()*], 
		)
	})
]

#let d_ew_oberstufe() = page()[
	= Erwartungshorizont <erwartungshorizont>

	#let cell-highlight-color = luma(240)
	#locate(loc => {
		let _ew_cells() = {
			__s_aufgaben.final(loc)
				.map(aufg => {
					let cells = (
						cellx(fill: cell-highlight-color)[*#{aufg.nummer}*],
						cellx(fill: cell-highlight-color)[_#{aufg.titel}_],
						cellx(fill: cell-highlight-color)[*#d_ew_punkte(aufg.nummer, teil:none)*],
					)
					
					if aufg.teile == 0 {
						cells.push(([],d_ew_text(aufg.nummer, teil:none), d_ew_punkte(aufg.nummer, teil:none)))
					}

					for i in range(aufg.teile) {
						cells.push([#{aufg.nummer}.#{numbering("1", i + 1)}])
						cells.push(d_ew_text(aufg.nummer, teil:i + 1))
						cells.push(d_ew_punkte(aufg.nummer, teil:i + 1))
					}

					cells
				})
				.flatten()
		}
		tablex(
			columns: (auto, 1fr, auto),
			inset: 7pt,
			align:  (col, row) => {
				if col in (0, 2, 3) { center + horizon }
				else if row == 0 {
					horizon
				}
				else { left }
			},
			cellx(fill: cell-highlight-color)[*Aufg.*], cellx(fill: cell-highlight-color)[Die Schülerin / Der Schüler #sym.dots.h],
			cellx(fill: cell-highlight-color)[*mögl. \ Punkte*],
			.._ew_cells(),
			cellx(fill: cell-highlight-color)[],  cellx(fill: cell-highlight-color)[
				#set align(right)
				*Insgesamt*:
			], cellx(fill: cell-highlight-color)[*#d_ew_gesamt()*], 
		)
	})
]

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