// Naturkonstanten.
#import "@preview/fancy-units:0.1.1": qty as fancy-qty, unit as fancy-unit
#import "internal/check.typ": fail, check-named, check-type, check-not-empty

/// Legt eine Konstante mit Wert und Einheit an.
///
/// Das Ergebnis ist ein Dictionary:
/// - `name`: Bezeichnung
/// - `value`: Zahlenwert als `float`
/// - `symbol`: Formelzeichen
/// - `unit`: gesetzte Einheit
/// - `qty`: gesetzter Wert mit Einheit
///
/// ```typ
/// #let c = konstante("2.99792458e8", name: "Lichtgeschwindigkeit", unit: [m/s], symbol: $c$)
/// #c.symbol = #c.qty
/// ```
///
/// - value (str, float, int): Zahlenwert; als Text bleiben alle Stellen erhalten (`"2.99792458e8"`)
/// - name (str, none): Bezeichnung, zum Beispiel `"Lichtgeschwindigkeit"`
/// - unit (str, content, none): Einheit, zum Beispiel `[m/s]`
/// - symbol (content, none): Formelzeichen, zum Beispiel `$c$`
/// - ..deprecated (arguments): fängt alte Namen ab, nimmt nichts an
/// -> dictionary
#let konstante(value, name: none, unit: none, symbol: none, ..deprecated) = {
  if deprecated.pos().len() > 0 {
    fail(
      "physik",
      "konstante",
      str(deprecated.pos().len() + 1)
        + " Positionsargumente, erlaubt ist eines – den Wert zuerst, Name und Einheit benannt: `konstante(value, name: …, unit: …)`",
    )
  }
  check-named(
    "physik",
    "konstante",
    deprecated,
    renamed: (wert: "value", einheit: "unit"),
    removed: (beschreibung: "die Beschreibung wurde nie verwendet, Argument löschen"),
    allowed: ("name", "unit", "symbol"),
  )
  check-type("physik", "konstante", "value", value, (str, float, int), example: "konstante(\"9.81\", name: \"Erdbeschleunigung\", unit: [m/s²])")
  if type(value) == str and value.trim().match(regex("^[+\\-−]?(\\d+\\.?\\d*|\\.\\d+)([eE][+\\-−]?\\d+)?$|^[+\\-−]?(inf|nan)$")) == none {
    fail("physik", "konstante", "`value: " + repr(value) + "` ist keine Zahl – zum Beispiel `\"9.81\"` oder `\"2.998e8\"`")
  }
  check-type("physik", "konstante", "name", name, (str, none))
  check-not-empty("physik", "konstante", "name", name, "keine Bezeichnung")
  check-not-empty("physik", "konstante", "unit", unit, "keine Einheit")
  check-type("physik", "konstante", "unit", unit, (str, content, none), example: "[m/s]")
  check-type("physik", "konstante", "symbol", symbol, (content, str, none), example: "$c$")

  (
    name: name,
    value: float(value),
    symbol: symbol,
    unit: if unit == none { none } else { fancy-unit(per-mode: "fraction")[#unit] },
    qty: if unit == none { [#value] } else { fancy-qty(per-mode: "fraction")[#value][#unit] },
  )
}

/// Vordefinierte Naturkonstanten. Jeder Eintrag ist ein Dictionary wie aus
/// `konstante` mit den Schlüsseln `name`, `value`, `symbol`, `unit`, `qty`.
///
/// ```typ
/// #constants.c.symbol = #constants.c.qty \
/// #calc.round(constants.g.value * 2, digits: 2)
/// ```
///
/// Schlüssel: `h`, `h_eV`, `e`, `c`, `g`, `G`, `k_B`, `N_A`, `R`,
/// `epsilon_0`, `mu_0`, `m_e`, `m_p`, `m_n`, `u`, `v_sound`.
#let constants = (
  h: konstante("6.62607015e-34", name: "Planck-Konstante", unit: [J s], symbol: $h$),
  h_eV: konstante("4.135667696e-15", name: "Planck-Konstante in eV", unit: [eV s], symbol: $h$),
  e: konstante("1.602176634e-19", name: "Elementarladung", unit: [C], symbol: $e$),
  c: konstante("2.99792458e8", name: "Lichtgeschwindigkeit", unit: [m/s], symbol: $c$),
  g: konstante("9.81", name: "Erdbeschleunigung", unit: [m/s²], symbol: $g$),
  G: konstante("6.67430e-11", name: "Gravitationskonstante", unit: [m^3/(kg s^2)], symbol: $G$),
  k_B: konstante("1.380649e-23", name: "Boltzmann-Konstante", unit: [J/K], symbol: $k_B$),
  N_A: konstante("6.02214076e23", name: "Avogadro-Konstante", unit: [1/mol], symbol: $N_A$),
  R: konstante("8.314462618", name: "Allgemeine Gaskonstante", unit: [J/(mol K)], symbol: $R$),
  epsilon_0: konstante("8.8541878128e-12", name: "Elektrische Feldkonstante", unit: [F/m], symbol: $epsilon_0$),
  mu_0: konstante("1.25663706212e-6", name: "Magnetische Feldkonstante", unit: [N/A^2], symbol: $mu_0$),
  m_e: konstante("9.1093837015e-31", name: "Elektronenmasse", unit: [kg], symbol: $m_e$),
  m_p: konstante("1.67262192369e-27", name: "Protonenmasse", unit: [kg], symbol: $m_p$),
  m_n: konstante("1.67492749804e-27", name: "Neutronenmasse", unit: [kg], symbol: $m_n$),
  u: konstante("1.66053906660e-27", name: "Atomare Masseneinheit", unit: [kg], symbol: $u$),
  v_sound: konstante("343", name: "Schallgeschwindigkeit in Luft (20 °C)", unit: [m/s], symbol: $v_"Schall"$),
)
