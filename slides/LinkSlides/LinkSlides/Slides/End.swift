import SwiftUI

struct End: View, Slide {
    static let offset = CGVector(dx: -1.5, dy: -1.5)
    
    var body: some View {
        ZStack {
            Color.white
            VStack(alignment: .leading, spacing: 16) {
                Text("**Děkuji za pozornost!!!**")
                    .foregroundColor(.black)
                    .font(.system(size: 80))
                    .frame(idealWidth: .infinity, idealHeight: .infinity, alignment: .center)
                Text("... a těste se na iOS meet ;)")
                    .foregroundColor(.black)
            }
            .padding()
        }
    }
}

struct End_Previews: PreviewProvider {
    static var previews: some View {
        End()
    }
}
