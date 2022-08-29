import SwiftUI

struct CShrnuti: View, Slide {
    // @offset(CShrnuti)
    static var offset = CGVector(dx: 1, dy: -4)
    
    // @hint(CShrnuti){
    static var hint: String? =
"""

"""
    // }@hint(CShrnuti)
    
    init() {}

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Jazyk C").font(.presentationHeadline)
                Text("Rychlokurz - Shrnutí").font(.presentationSubHeadline)
            }.frame(maxWidth: .infinity, alignment: .leading)
            Image("compilation").resizable().scaledToFit()
        }.padding()
    }
}

struct CShrnuti_Previews: PreviewProvider {
    static var previews: some View {
        CShrnuti().frame(width: 1024, height: 768)
    }
}
