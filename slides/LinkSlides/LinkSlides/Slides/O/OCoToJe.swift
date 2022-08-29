import SwiftUI

struct OCoToJe: View, Slide {
    // @offset(OCoToJe)
    static var offset = CGVector(dx: 0.5, dy: 5.75)
    
    // @hint(OCoToJe){
    static var hint: String? =
"""

"""
    // }@hint(OCoToJe)
    
    init() {}

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Objektový soubor").font(.presentationHeadline)
                Text("Laická definice").font(.presentationSubHeadline)
            }
            Text(
"""
**Co je Objektový soubor**
 - Výstup kompilátoru/assembleru
 - Přípona `.o`
 - Obsahuje *objektový kód*

**Objektový kód**
 - Části *strojového kódu*, které ještě nebyly *slinkovány* do kompletního programu.
 - Obsahuje *placeholdery*. Offsety a skoky ještě nemusí být zcela dopočítány.
 - **Obsahuje _Symbol Table Section_, která obsahuje seznam definovaných symbolů a referencí na symboly**

**Symbol, definice symbolu a reference na symbol**
 - Symbol má jméno (řetězec) a definici
 - Definice symbolu obsahuje vyhrazené místo pro obsah proměnné, strojovým kódem funkce, ...
 - Reference na symbol je použití symbolu
"""
            ).font(.presentationBody).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }.padding()
    }
}
 
struct OCoToJe_Previews: PreviewProvider {
    static var previews: some View {
        OCoToJe().frame(width: 1024, height: 768)
    }
}
