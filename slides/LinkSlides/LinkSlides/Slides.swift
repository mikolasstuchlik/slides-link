import SwiftUI

struct LinkSlides: View {
    @EnvironmentObject var presentation: PresentationProperties
    
    @State var ftdStdIn: String = "ls"
    @State var ftdTerminal: TerminalView.State = .idle
    
    let workingPath: URL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
    @State var ftdCode: String = FTDExample.defaultCode
    @State var ftcCompiler: CodeView.State = .idle
    
    let backgrounds: [any Background] = [
        XcodeBackground(),
        SwiftBackground()
    ]
    
    var slides: [any Slide] {
        [
            Beginning(),
            WhatIsFTD(),
            FTDExample(workingPath: workingPath, code: $ftdCode, compilerState: $ftcCompiler, stdIn: $ftdStdIn, terminalStatus: $ftdTerminal),
            End(),
        ]
    }

    let focuses: [Focus] = [
        .slides([Beginning.self]),
        .slides([WhatIsFTD.self]),
        .properties(.init(offset: CGVector(dx: 0, dy: -4), scale: 0.2, hint: nil)),
        .properties(.init(offset: CGVector(dx: 0, dy: -3.5), scale: 0.9, hint: nil)),
        .slides([Beginning.self, WhatIsFTD.self]),
        .slides([FTDExample.self]),
        .slides([End.self]),
        .slides([Beginning.self, WhatIsFTD.self, FTDExample.self, End.self]),
    ]
    
    
    var body: some View {
        Presentation(
            backgrounds: backgrounds,
            slides: slides,
            focuses: focuses
        )
    }
}

