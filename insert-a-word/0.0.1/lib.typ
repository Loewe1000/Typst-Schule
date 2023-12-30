#import "@schule/random:0.0.1": *

#let iaword(body) = {
  box(move(dy: 6pt)[
    #box(stroke: (bottom: 0.5pt + luma(130)), inset: (x: 1.5em, y: 0pt))[
      #hide(body) #label("iaword")
    ]
  ])
}

#let insert-a-word(hide-words: false, line-spacing: 1.5em, body) = {
  let colors = (
    rgb("#B3D4EC"),
    rgb("#D5E3B5"),
    rgb("#EEAA95"),
    rgb("#FAD3AD"),
    rgb("#CBADC8"),
    rgb("#FFE3A8"),
  )

  align(center, locate(loc => {
    let elems = query(<iaword>, loc)
    if not hide-words {
      for (index, word) in shuffle(elems, 42).enumerate() [
        #h(0.4em)
        #box(block(
          fill: colors.at(calc.rem(index, colors.len())),
          inset: 8pt,
          radius: 4pt,
        )[#word.body])
        #h(0.4em)
      ]
    }
  }))
  par(leading: line-spacing, body)
}