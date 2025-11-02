#import "@preview/fancy-units:0.1.1": qty, unit

#let konstante(name, wert, einheit, symbol: none, beschreibung: none) = (
  name: name,
  wert: float(wert),
  symbol: symbol,
  einheit: unit(per-mode: "fraction")[#einheit],
  mit-einheit: qty(per-mode: "fraction")[#wert][#einheit],
)

// Vordefinierte Konstanten
#let pk = (
  // Häufig verwendete Konstanten (direkt zugänglich)
  h: konstante("Planck-Konstante", "6.62607015e-34", [J s], symbol: $h$),
  h_eV: konstante("Planck-Konstante in eV", "4.135667696e-15", [eV s], symbol: $h$),
  e: konstante("Elementarladung", "1.602176634e-19", [C], symbol: $e$),
  c: konstante("Lichtgeschwindigkeit", "2.99792458e8", [m/s], symbol: $c$),
  g: konstante("Erdbeschleunigung", "9.81", [m/s²], symbol: $g$),
  G: konstante("Gravitationskonstante", "6.67430e-11", [m^3/(kg s^2)], symbol: $G$),
  k_B: konstante("Boltzmann-Konstante", "1.380649e-23", [J/K], symbol: $k_B$),
  N_A: konstante("Avogadro-Konstante", "6.02214076e23", [1/mol], symbol: $N_A$),
  R: konstante("Allgemeine Gaskonstante", "8.314462618", [J/(mol K)], symbol: $R$),
  epsilon_0: konstante("Elektrische Feldkonstante", "8.8541878128e-12", [F/m], symbol: $epsilon_0$),
  mu_0: konstante("Magnetische Feldkonstante", "1.25663706212e-6", [N/A^2], symbol: $mu_0$),
  
  // Massen (gruppiert)
  m: (
    elektron: konstante("Elektronenmasse", "9.1093837015e-31", [kg], symbol: $m_e$),
    proton: konstante("Protonenmasse", "1.67262192369e-27", [kg], symbol: $m_p$),
    neutron: konstante("Neutronenmasse", "1.67492749804e-27", [kg], symbol: $m_n$),
    u: konstante("Atomare Masseneinheit", "1.66053906660e-27", [kg], symbol: $u$),
  ),
  
  // Geschwindigkeiten (gruppiert)
  v: (
    schall: konstante("Schallgeschwindigkeit in Luft (20 °C)", "343", [m/s], symbol: $v_"Schall"$),
  ),
)
