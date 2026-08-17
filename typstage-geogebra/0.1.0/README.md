# typstage-geogebra

GeoGebra applets for [typstage](../typstage). The construction is built by
GeoGebra, the dramaturgy comes from the slides.

```typ
#import "@schule/typstage:0.1.0": *
#import "@schule/typstage-geogebra:0.1.0": *

#presentation(
  slide([Remote controlled], {
    geogebra(app: "classic", perspective: "G", height: 240pt,
             link: "https://www.geogebra.org/calculator")
    ggb-run("a=1", "f(x)=a*x^2")
    ggb-set((a: 3), at: 2)
  }),
)
```

`ggb-run`, `-set`, `-show`, `-hide`, `-style`, `-view`, `-animate`, `-tween`
all take a step selector and reach the applet when that step is entered. On the
way back the run is replayed from its start, so commands should be repeatable.

## Which applet is meant

Nothing says `"probe"` above: with one applet on the slide there is nothing to
choose between, and the commands find it by themselves — no matter whether they
stand above or below it in the source.

Two applets on one slide need names, and then the commands need `target`:

```typ
geogebra("left", height: 200pt)
geogebra("right", height: 200pt)
ggb-run("A=(0,0)", target: "left")
ggb-run("B=(1,1)", target: "right")
```

Leave `target` out there and it does not guess — it says which applets it found
and stops. A dropped command is far harder to notice than a failed build.

`ggb-tween` counts a value up frame by frame — build an object that depends on
it and the construction draws itself.

A `.ggb` file cannot be embedded: Typst has no base64 encoding. Build the
construction with `ggb-run` or load it through `material`.

In the PDF there is no applet. `fallback` puts your own drawing there instead,
`link` at least the way to the live one.
