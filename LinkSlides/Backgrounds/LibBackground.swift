import SwiftUI
import SlideUIViews
import SlideUI
import SlideUICommons

struct LibBackground: View, Background {
    static var offset: CGVector = CGVector(dx: 3 / 2, dy: 1.5)
    static var relativeSize: CGSize = CGSize(width: 3, height: 1.5) / scale
    static var scale: CGFloat = 4.0
    
    init() { }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(systemName: "building.columns.fill")
                .resizable()
                .frame(width: 375 / Self.scale, height: 375 / Self.scale)
                .foregroundStyle(.red).padding(40 / Self.scale)
            RoundedRectangle(cornerRadius: 40 / Self.scale).stroke(.red, style: StrokeStyle(lineWidth: 20 / Self.scale, dash: [])).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct LibBackground_Previews: PreviewProvider {
    static var previews: some View {
        LibBackground()
    }
}
