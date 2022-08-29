import SwiftUI

struct CBackground: View, Background {
    static var offset: CGVector = CGVector(dx: 4 / 2, dy: 3.5)
    static var relativeSize: CGSize = CGSize(width: 4, height: 1.5) / scale
    static var scale: CGFloat = 4.0
    
    init() { }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Text("C")
                .font(.system(size: 375 / Self.scale, weight: .bold))
                .foregroundColor(.blue)
                .padding(.leading, 40 / Self.scale)
            RoundedRectangle(cornerRadius: 40 / Self.scale).stroke(.blue, style: StrokeStyle(lineWidth: 20 / Self.scale, dash: [])).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CBackground2: View, Background {
    static var offset: CGVector = CGVector(dx: 2 / 2, dy: 7.5)
    static var relativeSize: CGSize = CGSize(width: 2, height: 1.5) / scale
    static var scale: CGFloat = 4.0
    
    init() { }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Text("C")
                .font(.system(size: 375 / Self.scale, weight: .bold))
                .foregroundColor(.blue)
                .padding(.leading, 40 / Self.scale)
            RoundedRectangle(cornerRadius: 40 / Self.scale).stroke(.blue, style: StrokeStyle(lineWidth: 20 / Self.scale, dash: [])).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CBackground_Previews: PreviewProvider {
    static var previews: some View {
        CBackground()
    }
}
