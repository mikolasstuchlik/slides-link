import SwiftUI

struct KnihovnyHandoff: View, Slide {
    // @offset(KnihovnyHandoff)
    static var offset = CGVector(dx: 0, dy: 0)
    
    // @hint(KnihovnyHandoff){
    static var hint: String? =
"""

"""
    // }@hint(KnihovnyHandoff)
    
    init() {}

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Knihovna").font(.presentationHeadline)
                Text("Pohled do hloubky").font(.presentationSubHeadline)
            }
            Text(
"""
Abychom mohli pochopit co je uvnitř souborů `.a` a `.dylib`, musíme nejdřív ukázat **některé** kroky při sestavování programu.

Tyto kroky si nejdříve ukážeme v C a pak ve Swiftu. Oba jazyky dělají v podstatě to stejné, ale C je jednodušší.
"""
            ).font(.presentationBody).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }.padding()
    }
}

struct KnihovnyHandoff_Previews: PreviewProvider {
    static var previews: some View {
        KnihovnyHandoff().frame(width: 1024, height: 768)
    }
}
