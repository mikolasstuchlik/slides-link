import SwiftUI

struct UvodProc: View, Slide {
    // @offset(UvodProc)
    static var offset = CGVector(dx: 1, dy: 0)
    
    // @hint(UvodProc){
    static var hint: String? =
"""

"""
    // }@hint(UvodProc)
    
    init() {}

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Úvod").font(.presentationHeadline)
                Text("Motivace").font(.presentationSubHeadline)
            }
            Text(
"""
**Proč se tímto tématem zabývat**

 - Porozumnění chybovým hláškám a řešení chyb
 - Hodí se znát při nastavování projektu
 - Pochopení/připomenutí jak fungují knihovny
 - Dobrý základ pro další témata užitečná při vývoji
 - Budoucnost nám věští Miltiplatform (KMM) a to může být častý zdroj chyb

"""
            ).font(.presentationBody).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }.padding()
    }
}

struct UvodProc_Previews: PreviewProvider {
    static var previews: some View {
        UvodProc().frame(width: 1024, height: 768)
    }
}
