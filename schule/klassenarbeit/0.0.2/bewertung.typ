
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
	#set page(
		header: kopfzeile(mitte:()=>[Erwartungshorizont]),
		footer: none
	)
	#pagebreak()
	= Erwartungshorizont <erwartungshorizont>
	\
	Name: #luecke(symbol: ".")

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

		table(
			columns: (auto, 1fr, auto),
			inset: 5pt,
			fill: (col, row) => {
				white
			},
			align:  (col, row) => {
				if col in (0, 2, 3) { center + horizon }
				else if col == 1 { left + horizon }
				else { left }
			},
			[*Aufg.*], [*Die Schülerin / Der Schüler kann #sym.dots.h*],
			[*mögl. \ Punkte*], [*erreicht*],
			.._ew_cells(),
			[],  [
				#set align(right)
				*Insgesamt*:
			], [*#d_ew_gesamt()*], [],
		)
	})
]

#let d_ew_oberstufe() = page()[
	= Erwartungshorizont <erwartungshorizont>

	#locate(loc => {
		let _ew_cells() = {
			__s_aufgaben.final(loc)
				.map(aufg => {
					let cells = (
						[*#{aufg.nummer}*],
						[_#{aufg.titel}_],
						[*#d_ew_punkte(aufg.nummer, teil:none)*],
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
		table(
			columns: (auto, 1fr, auto),
			inset: 5pt,
			align:  (col, row) => {
				if col in (0, 2, 3) { center + horizon }
				else if row == 0 {
					horizon
				}
				else { left }
			},
			[*Aufg.*], [Die Schülerin / Der Schüler #sym.dots.h],
			[*mögl. \ Punkte*],
			.._ew_cells(),
			[],  [
				#set align(right)
				*Insgesamt*:
			], [*#d_ew_gesamt()*], 
		)
	})
]
