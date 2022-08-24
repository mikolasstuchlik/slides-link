import SwiftUI

struct OutlineView<C: View>: View {
    let title: String
    @ViewBuilder var content: () -> C
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Group {
                content()
            }
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.gray, style: StrokeStyle(lineWidth: 1, dash: [3]))
            )
            .padding(6)
            Text(title)
                .background( EffectView(material: .windowBackground))
                .padding(.leading, 16)
                .foregroundColor(.gray)
                .font(.system(.footnote))
        }
    }
}

struct OutlineView_Previews: PreviewProvider {
    static var previews: some View {
        OutlineView(title: "Ahoj" ) { Text("Hello") }
    }
}