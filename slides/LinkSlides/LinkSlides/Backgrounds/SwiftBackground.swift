import SwiftUI
import SlideUIViews
import SlideUI
import SlideUICommons

struct SwiftBackground: View, Background {
    static var offset: CGVector = CGVector(dx: 3 / 2, dy: 9.5)
    static var relativeSize: CGSize = CGSize(width: 3, height: 1.5) / scale
    static var scale: CGFloat = 4.0
    
    init() { }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 40 / Self.scale) {
                Image(systemName: "swift")
                    .resizable()
                    .frame(width: 375 / Self.scale, height: 375 / Self.scale)
                    .foregroundStyle(Color(red: 240.0/255.0, green: 140.0/255.0, blue: 40.0/255.0))
                Text("Swift")
                    .font(.system(size: 375 / Self.scale, weight: .light))
                    .foregroundColor(Color(red: 240.0/255.0, green: 140.0/255.0, blue: 40.0/255.0))
            }.padding(40 / Self.scale)
            LinearGradient(
                colors: [.init(red: 233.0/255.0, green: 100.0/255.0, blue: 50.0/255.0), .init(red: 240.0/255.0, green: 140.0/255.0, blue: 40.0/255.0)],
                startPoint: .bottom,
                endPoint: .top
            ).mask(RoundedRectangle(cornerRadius: 40 / Self.scale).stroke(style: StrokeStyle(lineWidth: 20 / Self.scale, dash: []))).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct SwiftBackground_Previews: PreviewProvider {
    static var previews: some View {
        SwiftBackground()
    }
}
