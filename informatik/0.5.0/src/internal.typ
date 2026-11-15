// Interne Namen des Pakets. Keine zugesicherte Schnittstelle: Was hier steht,
// darf sich in jeder Version ändern. Dokumente benutzen es nicht.

/// Setzt Inhalt in „SF Mono“ (Zellen der ASCII-Tabelle).
///
/// - body (content): Inhalt
/// -> content
#let mono(body) = text(font: "SF Mono", body)
