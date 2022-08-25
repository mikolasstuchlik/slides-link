import SwiftUI

struct End: View, Slide {
    // @offset(End)
    static var offset = CGVector(dx: -1.5, dy: -1.5)
    
    init() {}

    var body: some View {
        VStack(alignment: .leading) {
            Text("**Děkuji za pozornost!!!**")
                .font(.presentationTitle)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            Text("... a těste se na iOS meet ;)")
                .font(.presentationNote)
        }
        .padding()
    }
}

struct End_Previews: PreviewProvider {
    static var previews: some View {
        End()
    }
}
