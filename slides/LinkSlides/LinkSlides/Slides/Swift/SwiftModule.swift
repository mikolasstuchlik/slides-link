import SwiftUI
import SlideUIViews
import SlideUI
import SlideUICommons

struct SwiftModule: View, Slide {
    // @offset(SwiftModule)
    static var offset = CGVector(dx: 1.5, dy: 9.75)
    
    // @hint(SwiftModule){
    static var hint: String? =
"""

"""
    // }@hint(SwiftModule)
    
    init() {}

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Swift").font(.presentationHeadline)
                Text("`.swiftmodule` hlavičkový soubor na steroidech").font(.presentationSubHeadline)
            }
            Text(
"""
**Co to je**
"""
            ).font(.presentationBody).frame(maxWidth: .infinity, alignment: .topLeading)
            Image("swiftmodule").resizable().scaledToFit()
            Text(
"""
 - AST (abstract syntax tree), v podstatě veřejné deklarace
 - SIL (Swift intermediate language), předpokládám pro "inlinovatelné" funkce
 - Je zakódován v **LLVM Bitcode**, tj. není čitelný textovým editorem

**Jak jej číst**
 - Neukážeme si, je to dobré vědět pokud děláme s nástroji (Docc)
 - Můžeme použít `sourcekitten` (viz opory)
 - `xcrun swift-api-digester -dump-sdk -module <Jméno modulu> -o foo -I"$(pwd)"`
"""
            ).font(.presentationBody).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }.padding()
    }
}

struct SwiftModule_Previews: PreviewProvider {
    static var previews: some View {
        SwiftModule().frame(width: 1024, height: 768)
    }
}
