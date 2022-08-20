import SwiftUI


@_cdecl("greeting")
public func ahoj() -> Any {
    return "Miki"
}


public struct MyView: View {
    @State var isPushed: Bool = false

    public var body: some View {
        VStack(spacing: 8) {
            Text("Ahoj")
            Button("Zmáčkni mě", action: { isPushed.toggle() })
        }.background(
            isPushed ? .green : .red
        )
    }
}


@_cdecl("getView")
public func getView() -> Any {
    return AnyView(MyView())
}

