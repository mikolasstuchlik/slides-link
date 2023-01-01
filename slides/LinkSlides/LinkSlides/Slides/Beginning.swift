import SwiftUI
import SlideUIViews
import SlideUI
import SlideUICommons
 
struct Beginning: View, Slide {
    // @offset(Beginning)
    static var offset = CGVector(dx: 0.0, dy: 0.0)
    
    // @hint(Beginning){
    static var hint: String? =
"""

"""
    // }@hint(Beginning)

    init() {}

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Text("Sestavování projektu")
                    .font(.presentationTitle)
                Text("Hlavičky a linkování")
                    .font(.presentationSubTitle)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            Text("Mikoláš Stuchlík, Futured.app, 2022")
                .font(.presentationNote)
        }
        .padding()
    }
}

struct Beginning_Previews: PreviewProvider {
    static var previews: some View {
        Beginning()
    }
}
