#import "@preview/manifesto:0.1.1": template, schema
#import "../../../schuldocs/0.1.0/lib.typ": with-web, show-example as _show-example, show-module, show-code

#let pkg = toml("../typst.toml")

// Override show-example to use manifesto's schema for Web rendering
#let show-example = _show-example.with(schema-fn: schema)

#show: with-web(
  template-fn: template,
  toml: pkg,
  universe: "https://typst.app/universe/package/" + pkg.package.name,
  notices: ([Entwickelt für das Schule-Typst-Ökosystem],),
  links: ((name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),),
)

#include "content.typ"
