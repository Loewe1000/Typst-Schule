// fehler: klassenarbeit.klassenarbeit: `punkte: "alle"` heißt jetzt `points: "all"`
// Bekannte Grenze (bewusstes Verhalten): Ein ausdrücklich geschriebener
// Vorgabewert (`points: none`) ist nicht von einem weggelassenen Parameter zu
// unterscheiden; „alt und neu zugleich" kommt nur, wenn der neue Name von
// seiner Vorgabe abweicht (siehe v05-klassenarbeit-fehler-zugleich).
#import "@schule/klassenarbeit:0.5.0": *
#klassenarbeit(points: none, punkte: "alle")[x]
