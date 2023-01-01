import SwiftUI
import SlideUIViews
import SlideUI
import SlideUICommons

struct UvodOTematu: View, Slide {
    // @offset(UvodOTematu)
    static var offset = CGVector(dx: 1.0, dy: 0.0)
    
    // @hint(UvodOTematu){
    static var hint: String? =
"""

"""
    // }@hint(UvodOTematu)
    
    init() {}

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Úvod").font(.presentationHeadline)
                Text("O čem se budeme bavit").font(.presentationSubHeadline)
            }
            Text(
"""
**Nástin**

 - Ve **všech** našich programech používáme knihovny
 - Téměř všechno za nás řeší Xcode nebo Swift Package Manager
 - Co když dojde k chybě?

**Co všechno si ukážeme**

 - Ukážeme si, co jsou *statické* a *dynamické* knihovny
 - Ukážeme si, jak je vytvářet
 - Ukážeme si, jak je používat

"""
            ).font(.presentationBody).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }.padding()
    }
}

struct UvodOTematu_Previews: PreviewProvider {
    static var previews: some View {
        UvodOTematu().frame(width: 1024, height: 768)
    }
}
