import SwiftUI
import SlideUIViews
import SlideUI
import SlideUICommons

struct End: View, Slide {
    // @offset(End)
    static var offset = CGVector(dx: -1.0, dy: 0.0)
    
    // @hint(End){
    static var hint: String? =
"""

"""
    // }@hint(End)
    
    init() {}

    var body: some View {
        Text("**Děkuji za pozornost.**")
            .font(.presentationTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct End_Previews: PreviewProvider {
    static var previews: some View {
        End()
    }
}
