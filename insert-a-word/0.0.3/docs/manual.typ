#import "../../../schuldocs/0.1.0/lib.typ": with-pdf, show-example, show-module, show-code

#let pkg = toml("../typst.toml")

#show: with-pdf(
  name: pkg.package.name,
  version: pkg.package.version,
  license: pkg.package.license,
  description: pkg.package.description,
  abstract: [Das \`insert-a-word\`-Paket erstellt Lückentext-Aufgaben, bei denen zufällig angeordnete Wörter in den Text eingesetzt werden müssen.],
)

#include "content.typ"
