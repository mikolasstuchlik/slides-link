import SwiftUI

struct End: View, Slide {
    static let offset = CGVector(dx: -1.5, dy: -1.5)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("**Děkuji za pozornost!!!**")
                .font(.system(size: 80))
                .frame(idealWidth: .infinity, idealHeight: .infinity, alignment: .center)
            Text("... a těste se na iOS meet ;)")
        }
        .padding()
    }
}

struct End_Previews: PreviewProvider {
    static var previews: some View {
        End()
    }
}
