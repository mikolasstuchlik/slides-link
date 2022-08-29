import SwiftUI

struct LibBackground: View, Background {
    static var offset: CGVector = CGVector(dx: 3 / 2, dy: 1.5)
    static var relativeSize: CGSize = CGSize(width: 3, height: 1.5)
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(systemName: "building.columns.fill")
                .resizable()
                .frame(width: 400, height: 400)
                .foregroundStyle(.red).padding(40)
            LinearGradient(
                colors: [.red, .red.opacity(0.8)],
                startPoint: .bottom,
                endPoint: .top
            ).mask(RoundedRectangle(cornerRadius: 40).stroke(style: StrokeStyle(lineWidth: 20, dash: []))).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct LibBackground_Previews: PreviewProvider {
    static var previews: some View {
        LibBackground()
    }
}
