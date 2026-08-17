// schuldocs — Dokumentation für das Schule-Ökosystem
//
// Handbuch (PDF) und Website (HTML) aus einer Quelle, in einem Lauf:
//
//     typst compile docs/docs.typ build --format bundle --features bundle,html --root /
//
// Diese Datei sammelt nur die öffentlichen Namen ein.

#import "config.typ": doc-target, version as schuldocs-version
#import "bundle.typ": docs
#import "display.typ": show-code, show-example
#import "api.typ": show-module
#import "callout.typ": callout, caution, info, note, tip, warning
