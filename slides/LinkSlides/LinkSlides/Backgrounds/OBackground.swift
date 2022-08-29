import SwiftUI

struct OBackground: View, Background {
    static var offset: CGVector = CGVector(dx: 2 / 2, dy: 5.5)
    static var relativeSize: CGSize = CGSize(width: 2, height: 1.5)
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(systemName: "memorychip")
                .resizable()
                .frame(width: 400, height: 400)
                .foregroundStyle(.green).padding(40)
            LinearGradient(
                colors: [.green, .green.opacity(0.8)],
                startPoint: .bottom,
                endPoint: .top
            ).mask(RoundedRectangle(cornerRadius: 40).stroke(style: StrokeStyle(lineWidth: 20, dash: []))).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct OBackground_Previews: PreviewProvider {
    static var previews: some View {
        OBackground()
    }
}
