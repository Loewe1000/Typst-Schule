# Typst-Schule

Die Typst-Pakete des Schule-Ökosystems, als örtliches Paketverzeichnis für den
Namensraum `@schule`, und die Website mit den Handbüchern:
<https://loewe1000.github.io/Typst-Schule/>.

## Aufbau

    <paket>/<version>/typst.toml     ein Paket in einer Version
    <paket>/<version>/docs/docs.typ  sein Handbuch (schuldocs)
    <paket>/<version>/examples/      Beispiele, bei typstage auch als Website
    schuldocs/<version>/             die Vorlage, aus der Handbuch und Website entstehen

Ein Paket, das in einem eigenen Repo lebt (typstage, typstage-geogebra,
blockst), liegt als Submodul unter seiner Versionsnummer — nach dem Klonen
`git submodule update --init --recursive`.

Zum Arbeiten das Repo als Paketpfad einhängen, dann findet Typst
`@schule/<paket>:<version>`:

    mkdir -p ~/.local/share/typst/packages && ln -s "$PWD" ~/.local/share/typst/packages/schule

(macOS: `~/Library/Application Support/typst/packages/schule`.)

## Versionen

Jede Version eines Pakets hat ihren eigenen Ordner, und die Website zeigt
jede davon: `<paket>/<version>/` ist die Adresse eines Handbuchs,
`<paket>/` leitet auf die neueste Version weiter, eine Leiste über jedem
Handbuch wechselt zwischen den Versionen.

**Eine veröffentlichte Version ist eingefroren.** Sobald eine Version per PR
an [typst/packages](https://github.com/typst/packages) auf Typst Universe
steht, wird ihr Ordner nicht mehr geändert — auch nicht der Zeiger eines
Submoduls. Alles, was danach kommt, gehört in eine neue Version:

    bash .github/scripts/neue-version.sh <paket> <version>

Das Skript nimmt die bisher neueste Version als Vorlage: ein Ordner wird
kopiert und umbenannt (Version in `typst.toml`, eigene Importe in Doku und
Beispielen), ein Submodul wird als neues Submodul unter der neuen Nummer
eingebunden. Die Website baut die neue Version beim nächsten Lauf mit und
zeigt sie als aktuelle; die alte bleibt, wie sie veröffentlicht wurde.

Die Regel prüft ein Workflow bei jedem PR und jedem Push auf `main`
(`.github/workflows/versionen.yml`, `.github/scripts/versionen-pruefen.py`):

1. `typst.toml` und Ordnername nennen dieselbe Version.
2. Geändert wurde nichts unter einer Version, die auf Universe steht —
   maßgeblich ist `https://packages.typst.org/preview/index.json`.

Pakete, die nur hier im Namensraum `@schule` leben, sind nie auf Universe;
für sie gilt Regel 2 nicht, und eine neue Version ist dort eine Frage der
Ordnung, nicht der Pflicht.

## Website

`.github/workflows/build-docs.yml` baut bei jedem Push auf `main` alle
Handbücher (`.github/scripts/build.sh`) und veröffentlicht sie über GitHub
Pages. Örtlich:

    bash .github/scripts/build.sh      # → .docs-site/

Gebaut wird jeder Versionsordner mit einer `docs/docs.typ`, über den
Bündel-Export von Typst 0.15: Website, Handbuch (PDF) und Stilvorlage in
einem Lauf. Die Versionsleiste bauen Handbücher aus schuldocs 0.3.0 selbst,
aus den Eingaben, die `build.sh` übergibt; ältere bekommen sie per Skript
angehängt.
