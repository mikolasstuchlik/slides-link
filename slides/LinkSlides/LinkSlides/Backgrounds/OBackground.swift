import SwiftUI

struct OBackground: View, Background {
    static var offset: CGVector = CGVector(dx: 2 / 2, dy: 5.5)
    static var relativeSize: CGSize = CGSize(width: 2, height: 1.5) / scale
    static var scale: CGFloat = 4.0
    
    init() { }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(systemName: "memorychip")
                .resizable()
                .frame(width: 375 / Self.scale, height: 375 / Self.scale)
                .foregroundStyle(.green).padding(40 / Self.scale)
            RoundedRectangle(cornerRadius: 40 / Self.scale).stroke(.green, style: StrokeStyle(lineWidth: 20 / Self.scale, dash: [])).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct OBackground_Previews: PreviewProvider {
    static var previews: some View {
        OBackground()
    }
}
