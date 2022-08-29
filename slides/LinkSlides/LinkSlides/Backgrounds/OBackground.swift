import SwiftUI

struct OBackground: View, Background {
    static var offset: CGVector = CGVector(dx: 2 / 2, dy: 5.5)
    static var relativeSize: CGSize = CGSize(width: 2, height: 1.5)
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(systemName: "memorychip")
                .resizable()
                .frame(width: 375, height: 375)
                .foregroundStyle(.green).padding(40)
            RoundedRectangle(cornerRadius: 40).stroke(.green, style: StrokeStyle(lineWidth: 20, dash: [])).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct OBackground_Previews: PreviewProvider {
    static var previews: some View {
        OBackground()
    }
}
