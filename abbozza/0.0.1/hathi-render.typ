#import "@preview/cetz:0.2.2": *

#let render-hathi-level(level, scale: 1) = {
  let _scale = scale
  let level-tiles = level.at(0).children.find(e => e.tag == "world").children.at(0).children.filter(e => type(e) == dictionary and (e.tag == "tile" or e.tag == "item")).map(c => {
    let data = (
      type: c.attrs.type,
      pos: ((int(c.attrs.x) - int(c.attrs.y)), -1 * (int(c.attrs.x) + int(c.attrs.y)) / 2),
    )
    if "capacity" in c.attrs {
      data.capacity = c.attrs.capacity
    }
    if "direction" in c.attrs {
      data.direction = c.attrs.direction
    }
    return data
  })

  let tiles(type, size: _scale * 25mm) = {
    return (
      "grass": image("assets/grass.svg", height: size),
      "water": image("assets/water.svg", height: size),
      "rock": image("assets/rock.svg", height: size),
      "tree": image("assets/tree.svg", height: size),
      "flag": image("assets/flag.svg", height: size),
      "hathi_0": image("assets/hathi_0.svg", height: size),
      "hathi_1": image("assets/hathi_1.svg", height: size),
      "hathi_2": image("assets/hathi_2.svg", height: size),
      "hathi_3": image("assets/hathi_3.svg", height: size),
      "lion": image("assets/lion_0.svg", height: size),
      "bananas": read("assets/bananas.svg"),
      "crate": read("assets/crate.svg"),
    ).at(type)
  }

  return canvas(
    length: _scale * 5mm,
    {
      import draw: *
      for tile in level-tiles {
        if tile.type in ("grass", "water", "tree", "flag", "rock", "lion") {
          content(tile.pos, tiles(tile.type))
        } else if tile.type in ("bananas", "crate") {
          let changed = tiles(tile.type).replace(
            "9999",
            str(tile.capacity),
          )
          content(tile.pos, image.decode(changed, height: _scale * 25mm))
        } else if tile.type == "hathi" {
          content(tile.pos, tiles(tile.type + "_" + tile.direction))
        }
      }
    },
  )
}