import SwiftUI

struct SwiftBackground: View, Background {
    static var offset: CGVector = CGVector(dx: 3 / 2, dy: 9.5)
    static var relativeSize: CGSize = CGSize(width: 3, height: 1.5)
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 40) {
                Image(systemName: "swift")
                    .resizable()
                    .frame(width: 375, height: 375)
                    .foregroundStyle(Color(red: 240.0/255.0, green: 140.0/255.0, blue: 40.0/255.0))
                Text("Swift")
                    .font(.system(size: 375, weight: .light))
                    .foregroundColor(Color(red: 240.0/255.0, green: 140.0/255.0, blue: 40.0/255.0))
            }.padding(40)
            LinearGradient(
                colors: [.init(red: 233.0/255.0, green: 100.0/255.0, blue: 50.0/255.0), .init(red: 240.0/255.0, green: 140.0/255.0, blue: 40.0/255.0)],
                startPoint: .bottom,
                endPoint: .top
            ).mask(RoundedRectangle(cornerRadius: 40).stroke(style: StrokeStyle(lineWidth: 20, dash: []))).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct SwiftBackground_Previews: PreviewProvider {
    static var previews: some View {
        SwiftBackground()
    }
}
