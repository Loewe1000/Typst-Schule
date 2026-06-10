#import "@schule/klassenarbeit:0.3.0": *

#show: klassenarbeit.with(
  title: [Klassenarbeit],
  subtitle: [Untertitel],
  class: [10a],
  date: [01.01.2025],
  teacher: [SLZ],
  punkte: "alle", // aufgabe, teilaufgabe, alle, keine
  loesungen: "keine", //seite, seiten, sofort, folgend, keine
  erwartungen: true,
  // Bundle-Export (typst compile --features bundle --format bundle) erzeugt
  // automatisch "{Titel}.pdf" und "{Titel} - Lösung.pdf"; mit
  // klausurboegen: true zusätzlich "{Titel} - Klausurbögen.pdf".
  // Einzelkompilation: variante: "druck" | "loesung" | "klausurboegen"
)