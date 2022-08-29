import SwiftUI

struct KnihovnyHighLvl: View, Slide {
    // @offset(KnihovnyHighLvl)
    static var offset = CGVector(dx: 0, dy: 1)
    
    // @hint(KnihovnyHighLvl){
    static var hint: String? =
"""

"""
    // }@hint(KnihovnyHighLvl)
    
    init() {}

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Knihovna").font(.presentationHeadline)
                Text("Pohled z výšky: co to je knihovna").font(.presentationSubHeadline)
            }
            Text(
"""
**Z praxe**

- My se setkáváme s knihovnami nejčastěji ve formě modulů, které si buďto stahujeme z internetu, nebo jsou součástí iOS
- Např:  `import SwiftUI`  nám zpřístupní funkcionalitu SwiftUI

**Co to znamená pro Xcode?**

- Aby jsme mohli modul používat, musíme vědět co v něm je. Za tímto účelem Xcode načte buďto *hlavičky* nebo *swiftmodule*.
- "Kód" modulu má pak formu *statické nebo dynamické knihovny*

**Kde se knihovna vezme?**

- Pokud se jedná o "systémový framework" je přímo na zařízení
- Pokud se jedná o open-source Package, zkompilujeme ji zároveň s aplikací a přibalíme k ní
- Pokud se jedná o nesvobodnou knihovnu (např. GoogleMaps), zkompiluje nám ji Google a my ji jenom přibalíme.
"""
            ).font(.presentationBody).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }.padding()
    }
}

struct KnihovnyHighLvl_Previews: PreviewProvider {
    static var previews: some View {
        KnihovnyHighLvl().frame(width: 1024, height: 768)
    }
}
