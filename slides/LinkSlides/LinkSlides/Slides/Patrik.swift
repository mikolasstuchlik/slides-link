import SwiftUI

struct Patrik: View, Slide {
    // @offset(Patrik)
    static var offset = CGVector(dx: 0, dy: 0)
    
    // @hint(Patrik){
    static var hint: String? =
"""

"""
    // }@hint(Patrik)
    
    init() {}

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Nadpis").font(.presentationHeadline)
                Text("Podnadpis").font(.presentationSubHeadline)
            }
            Text(
"""
Tělo
"""
            ).font(.presentationBody).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }.padding()
    }
}

struct Patrik_Previews: PreviewProvider {
    static var previews: some View {
        Patrik().frame(width: 1024, height: 768)
    }
}
