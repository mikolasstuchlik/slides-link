import SwiftUI

private let timeDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    formatter.dateFormat = .none
    return formatter
}()

struct SlideControlPanel: View {

    @EnvironmentObject var presentation: PresentationProperties
    @Environment(\.openWindow) private var openWindow
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var now: Date = Date()
    @State var stateTime: Date?

    var body: some View {
        VStack(spacing: 16) {
            Text("Obecné").frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 16) {
                dateCounter
                Spacer()
                timeCounter
                runButton
            }
            Text("Ovládání prezentace").frame(maxWidth: .infinity, alignment: .leading)
            presentationControl
            Text("Poznámky pro zaostřené").frame(maxWidth: .infinity, alignment: .leading)
            Text("Příslušenství").frame(maxWidth: .infinity, alignment: .leading)
        }.padding()
    }

    private var runButton: some View {
        Button {
            stateTime = Date()
            openWindow(id: "slides")
        } label: {
            Image(systemName: "play.circle.fill")
                .resizable()
                .foregroundStyle(.primary, .secondary, .green)
                .frame(width: 50, height: 50)
        }
        .buttonStyle(.plain)
        .frame(width: 50, height: 50)
    }
    
    private var dateCounter: some View {
        Text(timeDateFormatter.string(from: now)).onReceive(timer) { _ in
            now = Date()
        }.font(.largeTitle)
    }
    
    @ViewBuilder private var timeCounter: some View {
        if let stateTime {
            Text(
                timeDateFormatter.string(
                    from: Date(timeIntervalSince1970: -stateTime.timeIntervalSinceNow - 3600)
                )
            ).font(.largeTitle)
        } else {
            Text("00:00:00").font(.largeTitle)
        }
    }
    
    @ViewBuilder private var presentationControl: some View {
        VStack {
            HStack {
                Button("Předchozí") {
                    presentation.selectedFocus -= 1
                }
                Button("Následující") {
                    presentation.selectedFocus += 1
                }
            }
        }
    }
}

struct SlideControlPanel_Previews: PreviewProvider {
    static var previews: some View {
        SlideControlPanel()
    }
}
