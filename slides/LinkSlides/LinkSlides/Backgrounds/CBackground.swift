import SwiftUI

struct CBackground: View, Background {
    static var offset: CGVector = CGVector(dx: 4 / 2, dy: 3.5)
    static var relativeSize: CGSize = CGSize(width: 4, height: 1.5)
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Text("C")
                .font(.system(size: 400, weight: .bold))
                .foregroundColor(.blue)
                .padding(.leading, 40)
            LinearGradient(
                colors: [.blue, .blue.opacity(0.8)],
                startPoint: .bottom,
                endPoint: .top
            ).mask(RoundedRectangle(cornerRadius: 40).stroke(style: StrokeStyle(lineWidth: 20, dash: []))).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CBackground2: View, Background {
    static var offset: CGVector = CGVector(dx: 2 / 2, dy: 7.5)
    static var relativeSize: CGSize = CGSize(width: 2, height: 1.5)
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Text("C")
                .font(.system(size: 400, weight: .bold))
                .foregroundColor(.blue)
                .padding(.leading, 40)
            LinearGradient(
                colors: [.blue, .blue.opacity(80)],
                startPoint: .bottom,
                endPoint: .top
            ).mask(RoundedRectangle(cornerRadius: 40).stroke(style: StrokeStyle(lineWidth: 20, dash: []))).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CBackground_Previews: PreviewProvider {
    static var previews: some View {
        CBackground()
    }
}
