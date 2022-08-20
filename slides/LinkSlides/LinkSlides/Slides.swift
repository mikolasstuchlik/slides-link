import SwiftUI

struct LinkSlides: View {
    @EnvironmentObject var presentation: PresentationProperties
    @State var selectedFocus: Int = 0
    
    
    @State var currentLiveView: AnyView?
    @State var exception: String?
    @State var isLoading: Bool = false

    var body: some View {
        ZStack {
            Button(
                "",
                action: {
                    selectedFocus += 1
                }
            )
            .hidden()
            .keyboardShortcut(.return)

            Button(
                "",
                action: {
                    selectedFocus -= 1
                }
            )
            .hidden()
            .keyboardShortcut("p")

            GeometryReader { geometry in
                Presentation(
                    slides: [
                        Beginning(),
                        WhatIsFTD(),
                        FTDExample(currentLiveView: $currentLiveView, exception: $exception, isLoading: $isLoading),
                        End()
                    ],
                    focuses: [
                        [Beginning.self],
                        [WhatIsFTD.self],
                        [Beginning.self, WhatIsFTD.self],
                        [FTDExample.self],
                        [End.self],
                        [Beginning.self, WhatIsFTD.self, FTDExample.self, End.self],
                    ],
                    selectedFocus: $selectedFocus
                ).onChange(of: geometry.size) { newSize in
                    presentation.screenSize = newSize
                    presentation.frameSize = newSize
                }
            }
        }
    }
}

