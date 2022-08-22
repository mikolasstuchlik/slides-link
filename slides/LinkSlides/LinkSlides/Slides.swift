import SwiftUI

struct LinkSlides: View {
    @EnvironmentObject var presentation: PresentationProperties

    @State var ftdStdIn: String = "ls"
    @State var ftdTerminal: TerminalView.State = .idle
    
    let workingPath: URL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
    @State var ftdCode: String = FTDExample.defaultCode
    @State var ftcCompiler: CodeView.State = .idle
    

    var slides: [any Slide] {
        [
            Beginning(),
            WhatIsFTD(),
            FTDExample(workingPath: workingPath, code: $ftdCode, compilerState: $ftcCompiler, stdIn: $ftdStdIn, terminalStatus: $ftdTerminal),
            End()
        ]
    }

    var focuses: [Focus] {
        [
            .slides([Beginning.self]),
            .slides([WhatIsFTD.self]),
            .slides([Beginning.self, WhatIsFTD.self]),
            .slides([FTDExample.self]),
            .slides([End.self]),
            .slides([Beginning.self, WhatIsFTD.self, FTDExample.self, End.self]),
        ]
    }
    
    var body: some View {
        Presentation(slides: slides, focuses: focuses)
    }
}

