import SwiftUI
import SlideUIViews
import SlideUI
import SlideUICommons

struct KnihovnyDylibVSA: View, Slide {
    // @offset(KnihovnyDylibVSA)
    static var offset = CGVector(dx: 1.5, dy: 1.75)
    
    // @hint(KnihovnyDylibVSA){
    static var hint: String? =
"""

"""
    // }@hint(KnihovnyDylibVSA)
    
    init() {}

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Knihovna").font(.presentationHeadline)
                Text("Pohled z výšky: *statická* vs. *dynamická*").font(.presentationSubHeadline)
            }
            HStack {
                VStack {
                    Text("Statická").font(.presentationBody)
                    Image("static").resizable().scaledToFit()
                    Text("přípona `.a`").font(.presentationBody)
                }
                VStack {
                    Text("Dynamická").font(.presentationBody)
                    Image("dynamic").resizable().scaledToFit()
                    Text("přípona `.dylib` (na linuxu `.so`)").font(.presentationBody)
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            Text("`Static linker`  není označení běžně používané, spíše doporučuji  `linker editor`").font(.presentationNote).frame(alignment: .leading)
        }.padding()
    }
}

struct KnihovnyDylibVSA_Previews: PreviewProvider {
    static var previews: some View {
        KnihovnyDylibVSA().frame(width: 1024, height: 768)
    }
}
