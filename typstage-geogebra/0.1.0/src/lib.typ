// typstage-geogebra — GeoGebra applets for typstage.
//
// The construction is built by GeoGebra, the dramaturgy comes from the slides.
// Its own package so a presentation without applets carries none of this: the
// bridge script and the applet document are several kilobytes that would
// otherwise ride along in every deck.
//
// Everything here rests on two public parts of the core: `embed(bridge: …)`
// marks a frame as a target, and `bridge-job` sends it something on a step.
// The core reads none of it.

#import "@schule/typstage:0.1.0": bridge-job, bridge-targets, embed, paper
#import "applet.typ": applet-document, rgb255

/// The name of the applet a command is meant for.
///
/// `auto` means: the one applet on this slide. With none or several there is
/// nothing to infer, and guessing would silently drop the command — so it says
/// so instead.
///
/// Must be called in a context.
#let resolve-target(target) = {
  if target != auto {
    return if type(target) == label { str(target) } else { target }
  }
  let found = bridge-targets()
  if found.len() == 1 { return found.first() }
  if found.len() == 0 {
    panic("typstage-geogebra: no applet on this slide — put a #geogebra(…) "
          + "on it, or name the target explicitly with target: \"…\".")
  }
  panic("typstage-geogebra: " + str(found.len()) + " applets on this slide ("
        + found.join(", ") + ") — say which one is meant, e.g. target: \""
        + found.first() + "\".")
}

/// Guard against the old calling convention, where the applet came first and
/// unnamed. Silently taking it for a command would drop it without a trace.
#let no-stray-target(args) = {
  let first = if args.len() > 0 and type(args.first()) == label {
    str(args.first())
  } else if args.len() > 0 { args.first() } else { none }
  if type(first) == str and first in bridge-targets() {
    panic("typstage-geogebra: the applet is given as target: \""
          + first + "\" now, not as the first argument — or left out "
          + "entirely when the slide holds only one.")
  }
}

/// A GeoGebra applet in the slide.
///
/// - `seamless` takes the frame off the applet and puts its drawing area in
///   the slide's colour, so it no longer looks like a window of its own.
/// - `fallback` and `link` only take effect in the PDF: there is no applet on
///   paper, so what stands there is either a drawing of your own or at least
///   the way to the live one.
///
/// The `id` is only needed when a slide holds more than one applet — the
/// commands then say which one they mean. A single applet needs no name.
///
/// A `.ggb` file cannot be embedded: Typst has no base64 encoding, and without
/// it the file content never reaches the HTML. Build the construction with
/// `ggb-run` or load it through `material`.
#let geogebra(
  ..name,
  id: "ggb",
  material: none,
  app: "classic",
  perspective: none,
  language: none,
  grid: auto,
  axes: auto,
  seamless: true,
  background: auto,
  animation-button: false,
  codebase: "https://www.geogebra.org/apps/",
  width: 100%,
  height: 260pt,
  at: "1-",
  fallback: none,
  link: none,
) = context {
  assert(name.pos().len() <= 1,
         message: "typstage-geogebra: geogebra() takes at most a name")
  let id = if name.pos().len() == 1 { name.pos().first() } else { id }
  let id = if type(id) == label { str(id) } else { id }
  let bg = if background == auto { paper } else { background }
  embed(
    html: applet-document(id, material, app, perspective, language, grid, axes,
                          seamless, bg, animation-button, codebase,
                          260.0, height.pt()),
    bridge: id,
    width: width, height: height, at: at,
    fallback: fallback, link: link,
    label: [GeoGebra applet],
  )
}

/// Set values in the applet.
#let ggb-set(values, target: auto, at: "1-") = context bridge-job(
  resolve-target(target), ("set": values), at: at)

/// Run GeoGebra commands.
///
/// GeoGebra's scripting commands — `SetColor`, `SetValue` and relatives — are
/// *not* accepted by `evalCommand` and would come to nothing here. That is what
/// `ggb-style`, `ggb-set`, `ggb-show` and `ggb-hide` are for: they reach for
/// the JavaScript interface, which can do it.
#let ggb-run(..commands, target: auto, at: "1-") = context {
  no-stray-target(commands.pos())
  bridge-job(resolve-target(target), (cmd: commands.pos()), at: at)
}

/// Reveal objects that were hidden before.
#let ggb-show(..objects, target: auto, at: "1-") = context {
  no-stray-target(objects.pos())
  bridge-job(resolve-target(target),
             (vis: (objects: objects.pos(), on: true)), at: at)
}
/// Hide objects — the counterpart to `ggb-show`.
#let ggb-hide(..objects, target: auto, at: "1-") = context {
  no-stray-target(objects.pos())
  bridge-job(resolve-target(target),
             (vis: (objects: objects.pos(), on: false)), at: at)
}

/// Appearance — `color` takes a Typst colour, so the construction carries the
/// colours of your slides instead of GeoGebra's palette.
#let ggb-style(
  ..objects, target: auto, at: "1-",
  color: none, thickness: none, line-style: none, filling: none,
  point-size: none, trace: none, label: none, label-mode: none,
  fixed: none, caption: none, layer: none, position: none,
) = context {
  no-stray-target(objects.pos())
  bridge-job(resolve-target(target), (style: (
  objects: objects.pos(),
  ..if color != none { (color: rgb255(color)) },
  ..if thickness != none { (thickness: thickness) },
  ..if line-style != none { (lineStyle: line-style) },
  ..if filling != none { (filling: filling) },
  ..if point-size != none { (pointSize: point-size) },
  ..if trace != none { (trace: trace) },
  ..if label != none { (label: label) },
  ..if label-mode != none { (labelMode: label-mode) },
  ..if fixed != none { (fixed: fixed) },
  ..if caption != none { (caption: caption) },
  ..if layer != none { (layer: layer) },
  ..if position != none { (coords: position) },
)), at: at)
}

/// Viewport, grid, axes.
#let ggb-view(target: auto, at: "1-", x: none, y: none, grid: none,
              axes: none) = context bridge-job(
  resolve-target(target), (view: (:
    ..if x != none and y != none { (coords: (x.at(0), x.at(1), y.at(0), y.at(1))) },
    ..if grid != none { (grid: grid) },
    ..if axes != none { (axes: (axes, axes)) },
  )), at: at)

/// GeoGebra's own animation — it runs back and forth without end.
#let ggb-animate(
  ..objects, target: auto, at: "1-", speed: none, playing: true, trace: (),
) = context {
  no-stray-target(objects.pos())
  bridge-job(resolve-target(target), (anim: (
    objects: objects.pos(), playing: playing, trace: trace,
    ..if speed != none { (speed: speed) },
  )), at: at)
}

/// Once from A to B — the construction draws itself.
///
/// GeoGebra's own animation runs back and forth for ever. Drawing needs the
/// opposite — once from 0 to 1 and then stop — so here the browser counts the
/// value up frame by frame. Build an object that depends on it and it grows
/// along: a segment whose endpoint travels, an arc whose angle follows.
///
/// `at` points at *one* step — that is where it is drawn. On the steps after
/// it the value simply sits at its target, so jumping back shows the finished
/// drawing instead of the movement a second time.
#let ggb-tween(..name, target: auto, to: 1.0, from: none, at: 1,
               duration: 650, easing: "ease-in-out") = context {
  let given = name.pos()
  // Two names used to mean applet first, value second.
  assert(given.len() == 1,
         message: "typstage-geogebra: ggb-tween() takes the name of the value; "
                + "the applet goes in target:")
  assert(type(at) == int,
         message: "typstage-geogebra: ggb-tween() needs a step number")
  let who = resolve-target(target)
  let value = given.first()
  let ending = (:)
  ending.insert(value, to)
  bridge-job(who, (tween: (
    name: value, to: to, duration: duration, easing: easing,
    ..if from != none { (from: from) },
  )), at: str(at))
  bridge-job(who, ("set": ending), at: str(at + 1) + "-")
}
