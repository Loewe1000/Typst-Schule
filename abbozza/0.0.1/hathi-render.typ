#import "@preview/cetz:0.3.4": *



#let render-hathi-level(level, extra-tiles:(), scale: 1, print: false, replace: (:)) = {
  let _scale = scale

// Hauptfunktion: Hex-Farbe mit neuem Hue
let change-hue(hex, new-hue) = {
  let (old-hue, s, l, a) = color.hsl(rgb(hex)).components()
  let new = color.hsl(new-hue * 1deg, s, l, a)
  new.to-hex()
}

  // Hilfsfunktion zum Ersetzen eines Kacheltyps basierend auf dem replace-Dictionary
  let replace-tile-type(tile-type) = {
    if tile-type in replace.keys() {
      return replace.at(tile-type)
    }
    return tile-type
  }
  
  let extra-tiles = extra-tiles.map(c => {
      let tile-type = replace-tile-type(c.type)
      let data = (
        type: tile-type,
        pos: ((int(c.pos.at(0)) - int(c.pos.at(1))), -1 * (int(c.pos.at(0)) + int(c.pos.at(1))) / 2),
      )
      if "capacity" in c {
        data.capacity = c.capacity
      }
      if "hue" in c {
        data.hue = c.hue
      }
      if "direction" in c {
        data.direction = c.direction
      }
      return data
    })

  let level-tiles = level
    .at(0)
    .children
    .find(e => e.tag == "world")
    .children
    .at(0)
    .children
    .filter(e => type(e) == dictionary and (e.tag == "tile" or e.tag == "item"))
    .map(c => {
      // Wende die Ersetzungslogik beim Mapping der Kacheln an
      let tile-type = replace-tile-type(c.attrs.type)
      
      let data = (
        type: tile-type,
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

  let level-tiles = level-tiles + extra-tiles

  let tiles(type, size: _scale * 25mm) = {
    return (
      "grass": if print {
        image("assets/grass_print.svg", height: size)
      } else {
        image("assets/grass.svg", height: size)
      },
      "ice": image("assets/ice.svg", height: size),
      "water": if print {
        image("assets/water_print.svg", height: size)
      } else {
        image("assets/water.svg", height: size)
      },
      "rock": image("assets/rock.svg", height: size),
      "tree": image("assets/tree.svg", height: size),
      "flag": read("assets/flag.svg"),
      "hathi_0": image("assets/hathi_0.svg", height: size),
      "hathi_1": image("assets/hathi_1.svg", height: size),
      "hathi_2": image("assets/hathi_2.svg", height: size),
      "hathi_3": image("assets/hathi_3.svg", height: size),
      "hartmut_0": image("assets/hartmut_0.svg", height: size),
      "hartmut_1": image("assets/hartmut_1.svg", height: size),
      "hartmut_2": image("assets/hartmut_2.svg", height: size),
      "hartmut_3": image("assets/hartmut_3.svg", height: size),
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
        if tile.type in ("grass", "water", "tree", "rock", "lion", "ice") {
          content(tile.pos, tiles(tile.type))
        } else if tile.type in ("bananas", "crate") {
          let changed = tiles(tile.type).replace(
            "9999",
            str(tile.capacity),
          )
          content(tile.pos, image(bytes(changed), height: _scale * 25mm))
        } else if tile.type == "flag" {
          let data = if "hue" in tile {tiles(tile.type).replace("#0000FF", change-hue("#0000FF", tile.hue))} else { tiles(tile.type) }
          content(tile.pos, image(bytes(data), height: _scale * 25mm))
        } else if tile.type == "hathi" {
          content(tile.pos, tiles(tile.type + "_" + tile.direction))
        } else if tile.type == "hartmut" {
          content(tile.pos, tiles(tile.type + "_" + tile.direction))
        }
      }
    },
  )
}
